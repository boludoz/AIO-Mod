
; #FUNCTION# ====================================================================================================================
; Name ..........: chkShieldStatus
; Description ...: Reads Shield & Personal Break time to update global values for user management of Personal Break
; Syntax ........: chkShieldStatus([$bForceChkShield = False[, $bForceChkPBT = False]])
; Parameters ....: $bForceChkShield     - [optional] a boolean value. Default is False.
; ...............; $bForceChkPBT        - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: MonkeyHunter (2016-02), Team AIO Mod++ (2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_sPBOriginalStartTime = ""
Func chkShieldStatus($bChkShield = True, $bForceChkPBT = False)
    ; Legend trophy protection - Team AIO Mod++
    If $g_bLeagueAttack = True Then Return

    If ($g_bForceSinglePBLogoff = False And ($g_bChkBotStop = True And $g_iCmbBotCond >= 19) = False) And $g_bCloseWhileTrainingEnable = False And Not $g_bRequestCCDefense Or Not (IsMainPage()) Then
		SetDebugLog("chkShieldStatus is OFF")
		Return
	EndIf

	; Buy shield - Team AiO MOD++
	If $g_bChkBuyGuard Then
		BuyGuard()
	EndIf

	SetDebugLog("-- chkShieldStatus --")
	SetDebugLog("$g_sPBStartTime : " & $g_sPBStartTime)
	SetDebugLog("chkShieldStatus: " & _ArrayToString($g_asShieldStatus, "|"))
	Local $result, $iTimeTillPBTstartSec, $ichkTime = 0, $ichkSTime = 0, $ichkPBTime = 0
	If $bChkShield Or $g_asShieldStatus[0] = "" Or $g_asShieldStatus[1] = "" Or $g_asShieldStatus[2] = "" Or $g_sPBStartTime = "" Or $g_bGForcePBTUpdate = True Then
		$result = getShieldInfo()
		If @error Then SetLog("chkShieldStatus Shield OCR error= " & @error & "Extended= " & @extended, $COLOR_ERROR)
		If _Sleep($DELAYRESPOND) Then Return
		If IsArray($result) Then
			Local $iShieldExp = _DateDiff('n', $result[2], _NowCalc())
			If Abs($iShieldExp) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_NowCalc(), $result[2], 4)
				SetLog("Shield expires in: " & $sFormattedDiff)
			Else
				SetLog("Shield has expired")
			EndIf
			If _DateIsValid($g_asShieldStatus[2]) Then
				$ichkTime = Abs(Int(_DateDiff('s', $g_asShieldStatus[2], $result[2])))
				If $ichkTime > 60 Then
					$bForceChkPBT = True
					SetDebugLog("Shield time changed: " & $ichkTime & " Sec, Force PBT OCR: " & $bForceChkPBT, $COLOR_WARNING)
				EndIf
			EndIf
			$g_asShieldStatus = $result
			If $g_bChkBotStop = True And $g_iCmbBotCond >= 19 Then
				If $g_asShieldStatus[0] = "shield" Then
					SetLog("Shield found, Halt Attack Now!", $COLOR_INFO)
					$g_bWaitShield = True
					$g_bIsClientSyncError = False
					$g_bIsSearchLimit = False
				Else
					$g_bWaitShield = False
					If $g_bMeetCondStop = True Then
						SetLog("Shield expired, resume attacking", $COLOR_INFO)
						$g_bTrainEnabled = True
						$g_bDonationEnabled = True
						$g_bMeetCondStop = False
					Else
						SetDebugLog("Halt With Shield: Shield not found...", $COLOR_DEBUG)
					EndIf
				EndIf
			EndIf
		Else
			SetDebugLog("Bad getShieldInfo() return value: " & $result, $COLOR_ERROR)
			If _Sleep($DELAYRESPOND) Then Return
			For $i = 0 To UBound($g_asShieldStatus) - 1
				$g_asShieldStatus[$i] = ""
			Next
		EndIf
	EndIf
	If Not $g_bForceSinglePBLogoff And Not $g_bRequestCCDefense Then Return
	If _DateIsValid($g_sPBStartTime) Then
		$ichkPBTime = Int(_DateDiff('s', $g_sPBStartTime, _NowCalc()))
		If $ichkPBTime >= 295 Then
			$bForceChkPBT = True
			SetDebugLog("Found old PB time= " & $ichkPBTime & " Seconds, Force update:" & $bForceChkPBT, $COLOR_WARNING)
		EndIf
	EndIf
	If $bForceChkPBT Or $g_bGForcePBTUpdate Or $g_sPBStartTime = "" Then
		$g_bGForcePBTUpdate = False
		$result = getPBTime()
		If @error Then SetLog("chkShieldStatus getPBTime OCR error= " & @error & ", Extended= " & @extended, $COLOR_ERROR)
		If _Sleep($DELAYRESPOND) Then Return
		If _DateIsValid($result) Then
			$g_sPBOriginalStartTime = $result
			Local $iTimeTillPBTstartMin = Int(_DateDiff('n', $result, _NowCalc()))
			If Abs($iTimeTillPBTstartMin) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_DateAdd("n", -1, _NowCalc()), $result, 4)
				SetLog("Personal Break starts in: " & $sFormattedDiff)
				Local $CorrectstringPB_GUI = StringReplace($sFormattedDiff, StringInStr($sFormattedDiff, " hours ") >= 1 ? " hours " : " hour ", "h")
				$CorrectstringPB_GUI = StringReplace($CorrectstringPB_GUI, StringInStr($CorrectstringPB_GUI, " minutes ") >= 1 ? " minutes " : " minute ", "'")
;~ 				$g_aiPersonalBreak[$g_iCurAccount] = $CorrectstringPB_GUI
			Else
;~ 				$g_aiPersonalBreak[$g_iCurAccount] = ""
			EndIf
			If $iTimeTillPBTstartMin < -(Int($g_iSinglePBForcedEarlyExitTime)) Then
				$g_sPBStartTime = _DateAdd('n', -(Int($g_iSinglePBForcedEarlyExitTime)), $result)
			ElseIf $iTimeTillPBTstartMin < 0 Then
				$g_sPBStartTime = $result
			Else
				$g_sPBStartTime = ""
				$g_sPBOriginalStartTime = ""
			EndIf
			SetDebugLog("Early Log Off time=" & $g_sPBStartTime & ", In " & _DateDiff('n', $g_sPBStartTime, _NowCalc()) & " Minutes", $COLOR_DEBUG)
		Else
			SetLog("Bad getPBTtime() return value: " & $result, $COLOR_ERROR)
			$g_sPBStartTime = ""
			$g_sPBOriginalStartTime = ""
;~ 			$g_aiPersonalBreak[$g_iCurAccount] = ""
		EndIf
	EndIf
	If checkObstacles() Then checkMainScreen(False)
	SetDebugLog("$g_sPBStartTime : " & $g_sPBStartTime)
	SetDebugLog("chkShieldStatus: " & _ArrayToString($g_asShieldStatus, "|"))
;~ 	SetDebugLog("$g_aiPersonalBreak[$g_iCurAccount]: " & $g_aiPersonalBreak[$g_iCurAccount])
	SetDebugLog("$g_sPBOriginalStartTime: " & $g_sPBOriginalStartTime)
	SetDebugLog("$g_iSinglePBForcedEarlyExitTime: " & $g_iSinglePBForcedEarlyExitTime)
	SetDebugLog("-- chkShieldStatus ends --")
EndFunc   ;==>chkShieldStatus

; Returns formatted difference between two dates
; $iGrain from 0 To 5, to control level of detail that is returned
Func _Date_Difference($sStartDate, Const $sEndDate, Const $iGrain)
	Local $aUnit[6] = ["Y", "M", "D", "h", "n", "s"]
	Local $aType[6] = ["year", "month", "day", "hour", "minute", "second"]
	Local $sReturn = "", $iUnit

	For $i = 0 To $iGrain
		$iUnit = _DateDiff($aUnit[$i], $sStartDate, $sEndDate)
		If $iUnit <> 0 Then
			$sReturn &= $iUnit & " " & $aType[$i] & ($iUnit > 1 ? "s" : "") & " "
		EndIf
		$sStartDate = _DateAdd($aUnit[$i], Int($iUnit), $sStartDate)
	Next

	Return $sReturn
EndFunc   ;==>_Date_Difference

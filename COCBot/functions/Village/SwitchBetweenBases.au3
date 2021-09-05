; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base.
; Syntax ........: SwitchBetweenBases()
; Parameters ....:
; Return values .: True: Successfully switched Bases  -  False: Failed to switch Bases
; Author ........: Fliegerfaust (05-2017), Boldina (05-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#Region - Custom - Team AIO Mod++
Func SwitchBetweenBases($bCheckMainScreen = True)
	Local $sSwitchFrom, $sSwitchTo, $bIsOnBuilderBase = False, $aButtonCoords
	Local $sTile, $sTileDir, $sRegionToSearch
	Local $bSwitched = False
	If Not $g_bRunState Then Return
	Static $Failed = 0
	For $i = 0 To 1

		If isOnBuilderBase(True) Then
			$sSwitchFrom = "Builder Base"
			$sSwitchTo = "Normal Village"
			$bIsOnBuilderBase = True
			$sTile = "BoatBuilderBase"
			$sTileDir = $g_sImgBoatBB
			$sRegionToSearch = "487,44,708,242"
			If $g_bStayOnBuilderBase = True Then Return True

		Else
			; Deconstructed boat.
			Local $sNoBoat = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Noboat\"
			If QuickMIS("BC1", $sNoBoat, 66, 432, 388, 627, True) Then
				SetLog("Builder base locked.", $COLOR_INFO)
				$g_bStayOnBuilderBase = False
				Return False
			EndIf
			$sSwitchFrom = "Normal Village"
			$sSwitchTo = "Builder Base"
			$bIsOnBuilderBase = False
			$sTile = "BoatNormalVillage"
			$sTileDir = $g_sImgBoat
			$sRegionToSearch = "66,432,388,627"
			If $g_bStayOnBuilderBase = False Then Return True
		EndIf
		ZoomOut()
		If _Sleep(1000) Then Return
		If Not $g_bRunState Then Return
		$aButtonCoords = decodeSingleCoord(FindImageInPlace($sTile, $sTileDir, $sRegionToSearch))
		If UBound($aButtonCoords) > 1 Then
			SetLog("[" & $i & "] Going to " & $sSwitchTo, $COLOR_INFO)
			ClickP($aButtonCoords)
			If _Sleep($DELAYSWITCHBASES1) Then Return
			Local $hTimerHandle = __TimerInit()
			$bSwitched = False
			While __TimerDiff($hTimerHandle) < 3000 And Not $bSwitched
				If _Sleep(250) Then Return
				If Not $g_bRunState Then Return
				ForceCaptureRegion()
				$bSwitched = isOnBuilderBase(True) <> $bIsOnBuilderBase
			WEnd
			If $bSwitched Then
				If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase)
				$Failed = 0
				Return True
			Else
				SetLog("Failed to go to the " & $sSwitchTo, $COLOR_ERROR)
				$Failed += 1
				If $Failed > 15 Then
					SetLog("Rebooting " & $g_sAndroidEmulator & " due to problems Switch Bases!", $COLOR_ERROR)
					; AndroidAdbResetErrors()
					If Not RebootAndroid() Then Return False
				EndIf
			EndIf
		Else
			SetLog("[" & $i & "] SwitchBetweenBases Tile: " & $sTile, $COLOR_ERROR)
			SetLog("[" & $i & "] SwitchBetweenBases isOnBuilderBase: " & isOnBuilderBase(True), $COLOR_ERROR)
			If $bIsOnBuilderBase Then
				SetLog("Cannot find the Boat on the Coast", $COLOR_ERROR)
			Else
				SetLog("Cannot find the Boat on the Coast. Maybe it is still broken or not visible", $COLOR_ERROR)
			EndIf
		EndIf
	Next
	Return False
EndFunc   ;==>SwitchBetweenBases
#EndRegion - Custom - Team AIO Mod++

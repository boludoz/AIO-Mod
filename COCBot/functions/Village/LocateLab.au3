; #FUNCTION# ====================================================================================================================
; Name ..........: LocateLab
; Description ...:
; Syntax ........: LocateLab()
; Parameters ....:
; Return values .: None
; Author ........: KnowJack (June 2015)
; Modified ......: Sardo 2015-08
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateLab($bDummy = True)
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateLab 1")
	Local $result = _LocateLab()
	$g_bRunState = $wasRunState
	AndroidShield("LocateLab 2")
	Return $result
EndFunc   ;==>LocateLab

Func _LocateLab()
	Local $sText, $MsgBox, $iStupid = 0, $iSilly = 0, $sErrorText = ""
	If Int($g_iTownHallLevel) < 3 Then Return

	SetLog("Locating Laboratory...", $COLOR_INFO)
	ZoomOut()
	Collect(False, False)
	$g_aiLaboratoryPos[0] = -1
	$g_aiLaboratoryPos[1] = -1
	If DetectedLabs() Then Return True
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 600)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_01", "Click OK then click on your Laboratory building") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_02", "Locate Laboratory at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickP($aAway, 1, 0, "#0379")
			Local $aPos = FindPos()
			$g_aiLaboratoryPos[0] = Int($aPos[0])
			$g_aiLaboratoryPos[1] = Int($aPos[1])
			If isInsideDiamond($g_aiLaboratoryPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Laboratory Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Laboratory Location.", $COLOR_ERROR)
						ClickP($aAway, 1, 0, "#0380")
						Return False
					Case Else
						SetLog(" Operator Error - Bad Laboratory Location.", $COLOR_ERROR)
						$g_aiLaboratoryPos[0] = -1
						$g_aiLaboratoryPos[1] = -1
						ClickP($aAway, 1, 0, "#0381")
						Return False
				EndSelect
			EndIf
		Else
			SetLog("Locate Laboratory Cancelled", $COLOR_INFO)
			ClickP($aAway, 1, 0, "#0382")
			Return
		EndIf
		Local $sLabInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
		If $sLabInfo[0] > 1 Or $sLabInfo[0] = "" Then
			If StringInStr($sLabInfo[1], "Lab") = 0 Then
				Local $sLocMsg = ($sLabInfo[0] = "" ? "Nothing" : $sLabInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the laboratory?, It was a " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 2
						$sErrorText = "Quit joking, That was " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 3
						$sErrorText = "This is not funny, why did you click " & $sLocMsg & "? Please stop!" & @CRLF
						ContinueLoop
					Case $iSilly = 4
						$sErrorText = $sLocMsg & " ?!?!?!" & @CRLF & @CRLF & "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iSilly > 4
						SetLog("Quit joking, Click the Army Camp, or restart bot and try again", $COLOR_ERROR)
						$g_aiLaboratoryPos[0] = -1
						$g_aiLaboratoryPos[1] = -1
						ClickP($aAway, 1, 0, "#0383")
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Laboratory Location: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_ERROR)
			$g_aiLaboratoryPos[0] = -1
			$g_aiLaboratoryPos[1] = -1
			ClickP($aAway, 1, 0, "#0384")
			Return False
		EndIf
		SetLog("Locate Laboratory Success: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickP($aAway, 2, 0, "#0207")
EndFunc   ;==>_LocateLab

Func DetectedLabs()
	Local $aResult = QuickMIS("NxCx", $g_sImgLocationLabs, 100, 55, 775, 624, True, False)
	If $aResult = 0 Then Return False
	For $i = 0 To UBound($aResult) - 1
		Local $N17070 = $aResult[$i][0]
		Local $aAllCoords = $aResult[$i][1]
		SetDebugLog("How Many Coordinates? " & UBound($aAllCoords))
		Local $aFinalCoords = $aAllCoords[0]
		Local $aPOSITION[2] = [$aFinalCoords[0] + 10 + 100, $aFinalCoords[1] + 10 + 55]
		Local $level = $aResult[$i][2]
		FClick($aPOSITION[0], $aPOSITION[1])
		SetDebugLog($aPOSITION[0] & "x" & $aPOSITION[1])
		SetLog("Laboratory Lv" & $level & " detected...", $COLOR_SUCCESS)
		If _Sleep(500) Then Return False
		Local $sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
		If @error Then SetError(0, 0, 0)
		Local $CountGetInfo = 0
		While IsArray($sInfo) = False
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
			If @error Then SetError(0, 0, 0)
			If _Sleep(100) Then Return False
			$CountGetInfo += 1
			If $CountGetInfo = 50 Then Return False
		WEnd
		SetDebugLog($sInfo[1] & " " & $sInfo[2])
		If @error Then Return SetError(0, 0, 0)
		If StringInStr($sInfo[1], "Lab") > 0 Then
			$g_aiLaboratoryPos[0] = $aPOSITION[0]
			$g_aiLaboratoryPos[1] = $aPOSITION[1]
			ClickP($aAway, 1, 200, "#0327")
			If _Sleep(1000) Then Return
			IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosX", $g_aiClanCastlePos[0])
			IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosY", $g_aiClanCastlePos[1])
			SetLog($N17070 & " Lv" & $level & " Position Saved!", $COLOR_SUCCESS)
			Return True
		Else
			SetDebugLog("Lab incorrect position!", $COLOR_ERROR)
		EndIf
	Next
	Return False
EndFunc   ;==>DetectedLabs

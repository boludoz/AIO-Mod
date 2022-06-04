; #FUNCTION# ====================================================================================================================
; Name ..........: LocateQueenAltar & LocateKingAltar & LocateWardenAltar
; Description ...:
; Syntax ........: LocateKingAltar() & LocateQueenAltar() &  LocateWardenAltar() & LocateChampionAltar()
; Parameters ....:
; Return values .: None
; Author ........: ProMac(07/2015)
; Modified ......: Boldina (26/1/2022)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateQueenAltar($bFromButton = False)
	If Int($g_iTownHallLevel) < 9 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateQueenAltar 1")
	Local $result = _LocateQueenAltar($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateQueenAltar 2")
	Return $result
EndFunc   ;==>LocateQueenAltar

Func _LocateQueenAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = ""
	WinGetAndroidHandle()
	checkMainScreen(False)
	$g_aiQueenAltarPos[0] = -1
	$g_aiQueenAltarPos[1] = -1
	ZoomOut()
	$g_bDisableBreakCheck = True
	Collect(False, False)
	$g_bDisableBreakCheck = False
	SetLog("Locating Queen Altar...", $COLOR_INFO)
	If DetectedAltar($eHeroQueen) Then Return True
	If Number($g_iTownHallLevel) > 0 And Number($g_iTownHallLevel) < 9 Then
		SetLog('Skipping manual "Queen" locate (requires TH9)', $COLOR_WARNING)
		Return
	EndIf
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Queen_Altar_01", "Click OK then click on your Queen Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Queen_Altar_02", "Locate Queen Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiQueenAltarPos[0] = $aPos[0]
			$g_aiQueenAltarPos[1] = $aPos[1]
			If isInsideDiamond($g_aiQueenAltarPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Queen Altar Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")?" & @CRLF & "  Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Queen Altar Location: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_ERROR)
						ClickAway()
						Return False
					Case Else
						SetLog(" Operator Error - Bad Queen Altar Location: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiQueenAltarPos[0] = -1
						$g_aiQueenAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
			SetLog("Queen Altar: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Queen Altar Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		
		Local $sInfo = ""
		For $iCountGetInfo = 0 To 10
			If _Sleep(500) Then Return
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
			If IsArray($sInfo) Then ExitLoop
		Next
		
		If $iCountGetInfo > 9 Then
			SetLog("No hero located.", $COLOR_INFO)
			Return
		EndIf
		
		SetDebugLog($sInfo[1] & $sInfo[2])
		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			
			If StringInStr($sInfo[1], "Quee") = 0 Then
				Local $sLocMsg = ($sInfo[0] = "" ? "Nothing" : $sInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the Queen Altar?, It was a " & $sLocMsg & @CRLF
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
						SetLog("Quit joking, Click the Queen Altar, or restart bot and try again", $COLOR_ERROR)
						$g_aiQueenAltarPos[0] = -1
						$g_aiQueenAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Queen Altar Location: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiQueenAltarPos[0] = -1
			$g_aiQueenAltarPos[1] = -1
			ClickAway()
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickAway()
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xQueenAltarPos", $g_aiQueenAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yQueenAltarPos", $g_aiQueenAltarPos[1])
	Return True
EndFunc   ;==>_LocateQueenAltar

Func LocateKingAltar($bFromButton = False)
	; If Int($g_iTownHallLevel) < 7 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateKingAltar 1")
	Local $result = _LocateKingAltar($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateKingAltar 2")
	Return $result
EndFunc   ;==>LocateKingAltar

Func _LocateKingAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = ""
	WinGetAndroidHandle()
	checkMainScreen(False)
	ZoomOut()
	$g_bDisableBreakCheck = True
	Collect(False, False)
	$g_bDisableBreakCheck = False
	$g_aiKingAltarPos[0] = -1
	$g_aiKingAltarPos[1] = -1
	SetLog("Locating King Altar...", $COLOR_INFO)
	If DetectedAltar($eHeroKing) Then Return True
	If Number($g_iTownHallLevel) > 0 And Number($g_iTownHallLevel) < 7 Then
		SetLog('Skipping manual "Barbarian King" locate (requires TH7)', $COLOR_WARNING)
		Return
	EndIf
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		ClickAway()
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_King_Altar_01", "Click OK then click on your King Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", "Do not move mouse quickly after clicking location") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", "Make sure the building name is visible for me!") & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_King_Altar_02", "Locate King Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			Local $aPos = FindPos()
			$g_aiKingAltarPos[0] = $aPos[0]
			$g_aiKingAltarPos[1] = $aPos[1]
			If isInsideDiamond($g_aiKingAltarPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "King Altar Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")?" & @CRLF & "  Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad King Altar Location: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_ERROR)
						ClickAway()
						Return False
					Case Else
						SetLog(" Operator Error - Bad King Altar Location: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiKingAltarPos[0] = -1
						$g_aiKingAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
			SetLog("King Altar: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate King Altar Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf

		Local $sInfo = ""
		For $iCountGetInfo = 0 To 10
			If _Sleep(500) Then Return
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
			If IsArray($sInfo) Then ExitLoop
		Next
		
		If $iCountGetInfo > 9 Then
			SetLog("No hero located.", $COLOR_INFO)
			Return
		EndIf
		
		SetDebugLog($sInfo[1] & $sInfo[2])

		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			If (StringInStr($sInfo[1], "Barb") = 0) And (StringInStr($sInfo[1], "King") = 0) Then
				Local $sLocMsg = ($sInfo[0] = "" ? "Nothing" : $sInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the King Altar?, It was a " & $sLocMsg & @CRLF
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
						SetLog("Quit joking, Click the King Altar, or restart bot and try again", $COLOR_ERROR)
						$g_aiKingAltarPos[0] = -1
						$g_aiKingAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad King Altar Location: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiKingAltarPos[0] = -1
			$g_aiKingAltarPos[1] = -1
			ClickAway()
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickAway()
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xKingAltarPos", $g_aiKingAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yKingAltarPos", $g_aiKingAltarPos[1])
	Return True
EndFunc   ;==>_LocateKingAltar

Func LocateWardenAltar($bFromButton = False)
	; If Int($g_iTownHallLevel) < 11 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateWardenAltar 1")
	Local $result = _LocateWardenAltar($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateWardenAltar 2")
	Return $result
EndFunc   ;==>LocateWardenAltar

Func _LocateWardenAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = ""

	WinGetAndroidHandle()
	checkMainScreen(False)
	ZoomOut()
	$g_bDisableBreakCheck = True
	Collect(False, False)
	$g_bDisableBreakCheck = False
	$g_aiWardenAltarPos[0] = -1
	$g_aiWardenAltarPos[1] = -1
	SetLog("Locating Grand Warden Altar... work in progress!", $COLOR_INFO)
	If DetectedAltar($eHeroWarden) Then Return True
	If Number($g_iTownHallLevel) > 0 And Number($g_iTownHallLevel) < 11 Then
		SetLog('Skipping manual "Grand Warden" locate (requires TH11)', $COLOR_WARNING)
		Return
	EndIf
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		ClickAway()
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Warden_Altar_01", "Click OK then click on your Grand Warden Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", "Do not move mouse quickly after clicking location") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", "Make sure the building name is visible for me!") & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Warden_Altar_02", "Locate Grand Warden Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			Local $aPos = FindPos()
			$g_aiWardenAltarPos[0] = $aPos[0]
			$g_aiWardenAltarPos[1] = $aPos[1]
			If isInsideDiamond($g_aiWardenAltarPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Grand Warden Altar Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")?" & @CRLF & "  Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Grand Warden Altar Location: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_ERROR)
						ClickAway()
						Return False
					Case Else
						SetLog(" Operator Error - Bad Grand Warden Altar Location: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiWardenAltarPos[0] = -1
						$g_aiWardenAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
			SetLog("Grand Warden Altar: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Grand Warden Altar Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		
		Local $sInfo = ""
		For $iCountGetInfo = 0 To 10
			If _Sleep(500) Then Return
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
			If IsArray($sInfo) Then ExitLoop
		Next
		
		If $iCountGetInfo > 9 Then
			SetLog("No hero located.", $COLOR_INFO)
			Return
		EndIf
		
		SetDebugLog($sInfo[1] & $sInfo[2])

		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			
			If StringInStr($sInfo[1], "Warden") = 0 Then
				Local $sLocMsg = ($sInfo[0] = "" ? "Nothing" : $sInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the Grand Warden Altar?, It was a " & $sLocMsg & @CRLF
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
						SetLog("Quit joking, Click the Grand Warden Altar, or restart bot and try again", $COLOR_ERROR)
						$g_aiWardenAltarPos[0] = -1
						$g_aiWardenAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Grand Warden Altar Location: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiWardenAltarPos[0] = -1
			$g_aiWardenAltarPos[1] = -1
			ClickAway()
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickAway()
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xWardenAltarPos", $g_aiWardenAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yWardenAltarPos", $g_aiWardenAltarPos[1])
	Return True
EndFunc   ;==>_LocateWardenAltar

Func LocateChampionAltar($bFromButton = False)
	; If Int($g_iTownHallLevel) < 13 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateChampionAltar 1")
	Local $result = _LocateChampionAltar()
	$g_bRunState = $wasRunState
	AndroidShield("LocateChampionAltar 2")
	Return $result
EndFunc   ;==>LocateChampionAltar

Func _LocateChampionAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = ""
	WinGetAndroidHandle()
	checkMainScreen(False)
	ZoomOut()
	$g_bDisableBreakCheck = True
	Collect(False, False)
	$g_bDisableBreakCheck = False
	$g_aiChampionAltarPos[0] = -1
	$g_aiChampionAltarPos[1] = -1
	SetLog("Locating Royal Champion Altar...", $COLOR_INFO)
	If DetectedAltar($eHeroChampion) Then Return True
	If Number($g_iTownHallLevel) > 0 And Number($g_iTownHallLevel) < 13 Then
		SetLog('Skipping manual "Royal Champion" locate (requires TH13)', $COLOR_WARNING)
		Return
	EndIf
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Champion_Altar_01", "Click OK then click on your Royal Champion Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Champion_Altar_02", "Locate Royal Champion Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
			Local $aPos = FindPos()
			$g_aiChampionAltarPos[0] = $aPos[0]
			$g_aiChampionAltarPos[1] = $aPos[1]
			If isInsideDiamond($g_aiChampionAltarPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Royal Champion Altar Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")?" & @CRLF & "  Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Royal Champion!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Royal Champion Altar Location: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_ERROR)
						ClickAway()
						Return False
					Case Else
						SetLog(" Operator Error - Bad Royal Champion Altar Location: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiChampionAltarPos[0] = -1
						$g_aiChampionAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
			SetLog("Royal Champion Altar: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Royal Champion Altar Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf

		Local $sInfo = ""
		For $iCountGetInfo = 0 To 10
			If _Sleep(500) Then Return
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
			If IsArray($sInfo) Then ExitLoop
		Next
		
		If $iCountGetInfo > 9 Then
			SetLog("No hero located.", $COLOR_INFO)
			Return
		EndIf
		
		SetDebugLog($sInfo[1] & $sInfo[2])

		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			
			If StringInStr($sInfo[1], "Champ") = 0 Then
				Local $sLocMsg = ($sInfo[0] = "" ? "Nothing" : $sInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the Champion Altar?, It was a " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 2
						$sErrorText = "Quit joking, That was " & $sLocMsg & @CRLF
						ContinueLoop
					Case $iSilly = 3
						$sErrorText = "This is not funny, why did you click " & $sLocMsg & "? Please stop!" & @CRLF
						ContinueLoop
					Case $iSilly = 4
						$sErrorText = $sLocMsg & " ?!?!?!" & @CRLF & @CRLF & "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Royal Champion!" & @CRLF
						ContinueLoop
					Case $iSilly > 4
						SetLog("Quit joking, Click the Royal Champion Altar, or restart bot and try again", $COLOR_ERROR)
						$g_aiChampionAltarPos[0] = -1
						$g_aiChampionAltarPos[1] = -1
						ClickAway()
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Royal Champion Altar Location: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiChampionAltarPos[0] = -1
			$g_aiChampionAltarPos[1] = -1
			ClickAway()
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickAway()
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xChampionAltarPos", $g_aiChampionAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yChampionAltarPos", $g_aiChampionAltarPos[1])
	Return True
EndFunc   ;==>_LocateChampionAltar

Func DetectedAltar($eHeroIndex = $eHeroNone)
	ZoomOut()
	Local $sTemplateDir = ""
	Local $aDetectedPosition[2] = [-1, -1]
	Local $sHeroName = "", $sOCRString = ""
	Switch $eHeroIndex
		Case $eHeroKing
			$sTemplateDir = $g_sImgLocationKing
			$sHeroName = "King"
			$sOCRString = "King"
		Case $eHeroQueen
			$sTemplateDir = $g_sImgLocationQueen
			$sHeroName = "Queen"
			$sOCRString = "Quee"
		Case $eHeroWarden
			$sTemplateDir = $g_sImgLocationWarden
			$sHeroName = "Warden"
			$sOCRString = "Warden"
		Case $eHeroChampion
			$sTemplateDir = $g_sImgLocationChamp
			$sHeroName = "Champ"
			$sOCRString = "Champ"
		Case Else
			SetDebugLog("Hero Altar name error!", $COLOR_ERROR)
			Return False
	EndSwitch

	SetDebugLog($sHeroName & " Template Dir: " & $sTemplateDir, $COLOR_INFO)

	Local $bStatus = $g_bUseRandomClick	
	If $sTemplateDir <> "" Then
		For $i = 0 To 1
			If QuickMIS("BC1", $sTemplateDir, 100, 55, 775, 580, True, False) Then ; Resolution changed
				SetLog($sHeroName & " Altar detected...", $COLOR_SUCCESS)
				$g_bUseRandomClick = False
				PureClick($g_iQuickMISX, $g_iQuickMISY)
				If _Sleep(500) Then Return False
				$g_bUseRandomClick = $bStatus

				Local $sInfo = ""
				For $iCountGetInfo = 0 To 10
					If _Sleep(500) Then Return
					$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
					If IsArray($sInfo) Then ExitLoop
				Next
				
				If $iCountGetInfo > 9 Then
					SetLog("No hero located.", $COLOR_INFO)
					Return
				EndIf
				
				SetDebugLog($sInfo[1] & $sInfo[2])
				
				If StringInStr($sInfo[1], $sOCRString) > 0 Then
					$aDetectedPosition[0] = $g_iQuickMISX
					$aDetectedPosition[1] = $g_iQuickMISY
					ClickAway()
					If _Sleep(1000) Then Return
					ExitLoop
				Else
					SetDebugLog($sHeroName & " Altar incorrect position!", $COLOR_ERROR)
					If $i = 0 Then
						If _Sleep(3000) Then Return False
						ContinueLoop
					EndIf
					Return False
				EndIf
			Else
				SetDebugLog($sHeroName & " Altar not detected!", $COLOR_ERROR)
				If $i = 0 Then
					If _Sleep(3000) Then Return False
					ContinueLoop
				EndIf
				Return False
			EndIf
		Next
	Else
		Return False
	EndIf
	
	; Only save pos if is OK, original Boldina logic.
	ConvertFromVillagePos($aDetectedPosition[0], $aDetectedPosition[1])
	If $aDetectedPosition[0] > 0 Then
		Switch $eHeroIndex
			Case $eHeroKing
				$g_aiKingAltarPos[0] = $aDetectedPosition[0]
				$g_aiKingAltarPos[1] = $aDetectedPosition[1]
				IniWrite($g_sProfileBuildingPath, "other", "KingAltarPosX", $g_aiKingAltarPos[0])
				IniWrite($g_sProfileBuildingPath, "other", "KingAltarPosY", $g_aiKingAltarPos[1])
			Case $eHeroQueen
				$g_aiQueenAltarPos[0] = $aDetectedPosition[0]
				$g_aiQueenAltarPos[1] = $aDetectedPosition[1]
				IniWrite($g_sProfileBuildingPath, "other", "QueenAltarPosX", $g_aiQueenAltarPos[0])
				IniWrite($g_sProfileBuildingPath, "other", "QueenAltarPosY", $g_aiQueenAltarPos[1])
			Case $eHeroWarden
				$g_aiWardenAltarPos[0] = $aDetectedPosition[0]
				$g_aiWardenAltarPos[1] = $aDetectedPosition[1]
				IniWrite($g_sProfileBuildingPath, "other", "WardenAltarPosX", $g_aiWardenAltarPos[0])
				IniWrite($g_sProfileBuildingPath, "other", "WardenAltarPosY", $g_aiWardenAltarPos[1])
			Case $eHeroChampion
				$g_aiChampionAltarPos[0] = $aDetectedPosition[0]
				$g_aiChampionAltarPos[1] = $aDetectedPosition[1]
				IniWrite($g_sProfileBuildingPath, "other", "ChampionAltarPosX", $g_aiChampionAltarPos[0])
				IniWrite($g_sProfileBuildingPath, "other", "ChampionAltarPosY", $g_aiChampionAltarPos[1])
			Case Else
				SetDebugLog("Hero Altar index error!", $COLOR_ERROR)
				Return False
		EndSwitch

		SetLog($sHeroName & " Altar Position Saved!", $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>DetectedAltar

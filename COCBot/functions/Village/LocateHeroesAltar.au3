; #FUNCTION# ====================================================================================================================
; Name ..........: LocateQueenAltar & LocateKingAltar & LocateWardenAltar
; Description ...:
; Syntax ........: LocateKingAltar() & LocateQueenAltar() &  LocateWardenAltar() & LocateChampionAltar()
; Parameters ....:
; Return values .: None
; Author ........: ProMac(07/2015)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
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
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = "", $sInfo
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
	If $bFromButton = False And $g_bChkBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Queen_Altar_01", "Click OK then click on your Queen Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Queen_Altar_02", "Locate Queen Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickP($aAway)
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
						ClickP($aAway)
						Return False
					Case Else
						SetLog(" Operator Error - Bad Queen Altar Location: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiQueenAltarPos[0] = -1
						$g_aiQueenAltarPos[1] = -1
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
			SetLog("Queen Altar: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Queen Altar Cancelled", $COLOR_INFO)
			ClickP($aAway)
			Return
		EndIf
		$sInfo = BuildingInfo(242, 464)
		If @error Then SetError(0, 0, 0)
		Local $CountGetInfo = 0
		While IsArray($sInfo) = False
			$sInfo = BuildingInfo(242, 464)
			If @error Then SetError(0, 0, 0)
			If _Sleep(100) Then Return
			$CountGetInfo += 1
			If $CountGetInfo = 50 Then Return
		WEnd
		If $g_bDebugSetlog Then SetDebugLog($sInfo[1] & $sInfo[2])
		If @error Then Return SetError(0, 0, 0)
		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			If @error Then Return SetError(0, 0, 0)
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
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Queen Altar Location: " & "(" & $g_aiQueenAltarPos[0] & "," & $g_aiQueenAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiQueenAltarPos[0] = -1
			$g_aiQueenAltarPos[1] = -1
			ClickP($aAway)
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickP($aAway, 1, 200, "#0327")
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xQueenAltarPos", $g_aiQueenAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yQueenAltarPos", $g_aiQueenAltarPos[1])
EndFunc   ;==>_LocateQueenAltar

Func LocateKingAltar($bFromButton = False)
	If Int($g_iTownHallLevel) < 7 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateKingAltar 1")
	Local $result = _LocateKingAltar($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateKingAltar 2")
	Return $result
EndFunc   ;==>LocateKingAltar

Func _LocateKingAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = "", $sInfo
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
	If $bFromButton = False And $g_bChkBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		ClickP($aAway)
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
						ClickP($aAway)
						Return False
					Case Else
						SetLog(" Operator Error - Bad King Altar Location: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiKingAltarPos[0] = -1
						$g_aiKingAltarPos[1] = -1
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
			SetLog("King Altar: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate King Altar Cancelled", $COLOR_INFO)
			ClickP($aAway)
			Return
		EndIf
		$sInfo = BuildingInfo(242, 464)
		If @error Then SetError(0, 0, 0)
		Local $CountGetInfo = 0
		While IsArray($sInfo) = False
			$sInfo = BuildingInfo(242, 464)
			If @error Then SetError(0, 0, 0)
			If _Sleep(100) Then Return
			$CountGetInfo += 1
			If $CountGetInfo = 50 Then Return
		WEnd
		If $g_bDebugSetlog Then SetDebugLog($sInfo[1] & $sInfo[2])
		If @error Then Return SetError(0, 0, 0)
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
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad King Altar Location: " & "(" & $g_aiKingAltarPos[0] & "," & $g_aiKingAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiKingAltarPos[0] = -1
			$g_aiKingAltarPos[1] = -1
			ClickP($aAway)
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickP($aAway, 1, 200, "#0327")
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xKingAltarPos", $g_aiKingAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yKingAltarPos", $g_aiKingAltarPos[1])
EndFunc   ;==>_LocateKingAltar

Func LocateWardenAltar($bFromButton = False)
	If Int($g_iTownHallLevel) < 11 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateWardenAltar 1")
	Local $result = _LocateWardenAltar($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateWardenAltar 2")
	Return $result
EndFunc   ;==>LocateWardenAltar

Func _LocateWardenAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = "", $sInfo
	If Number($g_iTownHallLevel) < 11 Then
		SetLog("Grand Warden requires TH11, Cancel locate Altar!", $COLOR_ERROR)
		Return
	EndIf
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
	If $bFromButton = False And $g_bChkBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		ClickP($aAway)
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
						ClickP($aAway)
						Return False
					Case Else
						SetLog(" Operator Error - Bad Grand Warden Altar Location: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiWardenAltarPos[0] = -1
						$g_aiWardenAltarPos[1] = -1
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
			SetLog("Grand Warden Altar: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Grand Warden Altar Cancelled", $COLOR_INFO)
			ClickP($aAway)
			Return
		EndIf
		$sInfo = BuildingInfo(242, 464)
		If @error Then SetError(0, 0, 0)
		Local $CountGetInfo = 0
		While IsArray($sInfo) = False
			$sInfo = BuildingInfo(242, 464)
			If @error Then SetError(0, 0, 0)
			If _Sleep(100) Then Return
			$CountGetInfo += 1
			If $CountGetInfo = 50 Then Return
		WEnd
		If $g_bDebugSetlog Then SetDebugLog($sInfo[1] & $sInfo[2])
		If @error Then Return SetError(0, 0, 0)
		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			If @error Then Return SetError(0, 0, 0)
			If StringInStr($sInfo[1], "Grand") = 0 Then
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
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Grand Warden Altar Location: " & "(" & $g_aiWardenAltarPos[0] & "," & $g_aiWardenAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiWardenAltarPos[0] = -1
			$g_aiWardenAltarPos[1] = -1
			ClickP($aAway)
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickP($aAway, 1, 200, "#0327")
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xWardenAltarPos", $g_aiWardenAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yWardenAltarPos", $g_aiWardenAltarPos[1])
EndFunc   ;==>_LocateWardenAltar

Func LocateChampionAltar($bFromButton = False)
	If Int($g_iTownHallLevel) < 13 Then Return
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateChampionAltar 1")
	Local $result = _LocateChampionAltar()
	$g_bRunState = $wasRunState
	AndroidShield("LocateChampionAltar 2")
	Return $result
EndFunc   ;==>LocateChampionAltar

Func _LocateChampionAltar($bFromButton = False)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = "", $sInfo
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
	If $bFromButton = False And $g_bChkBuildingsLocate Or $g_bChkOnlyFarm Then Return
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Champion_Altar_01", "Click OK then click on your Royal Champion Altar") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Champion_Altar_02", "Locate Royal Champion Altar at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickP($aAway)
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
						ClickP($aAway)
						Return False
					Case Else
						SetLog(" Operator Error - Bad Royal Champion Altar Location: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_ERROR)
						$g_aiChampionAltarPos[0] = -1
						$g_aiChampionAltarPos[1] = -1
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
			SetLog("Royal Champion Altar: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Royal Champion Altar Cancelled", $COLOR_INFO)
			ClickP($aAway)
			Return
		EndIf
		$sInfo = BuildingInfo(242, 464)
		If @error Then SetError(0, 0, 0)
		Local $CountGetInfo = 0
		While IsArray($sInfo) = False
			$sInfo = BuildingInfo(242, 464)
			If @error Then SetError(0, 0, 0)
			If _Sleep(100) Then Return
			$CountGetInfo += 1
			If $CountGetInfo = 50 Then Return
		WEnd
		If $g_bDebugSetlog Then SetDebugLog($sInfo[1] & $sInfo[2])
		If @error Then Return SetError(0, 0, 0)
		If $sInfo[0] > 1 Or $sInfo[0] = "" Then
			If @error Then Return SetError(0, 0, 0)
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
						ClickP($aAway)
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Royal Champion Altar Location: " & "(" & $g_aiChampionAltarPos[0] & "," & $g_aiChampionAltarPos[1] & ")", $COLOR_ERROR)
			$g_aiChampionAltarPos[0] = -1
			$g_aiChampionAltarPos[1] = -1
			ClickP($aAway)
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickP($aAway, 1, 200, "#0327")
	If _Sleep(1000) Then Return
	IniWrite($g_sProfileBuildingPath, "other", "xChampionAltarPos", $g_aiChampionAltarPos[0])
	IniWrite($g_sProfileBuildingPath, "other", "yChampionAltarPos", $g_aiChampionAltarPos[1])
EndFunc   ;==>_LocateChampionAltar

Func DetectedAltar($eHeroIndex = $eHeroNone)
	Local $sTemplateDir = ""
	Local $aDetectedPosition[2] = [-1, -1]
	Local $sHeroName = ""
	Switch $eHeroIndex
		Case $eHeroKing
			$sTemplateDir = $g_sImgLocationKing
			$sHeroName = "King"
		Case $eHeroQueen
			$sTemplateDir = $g_sImgLocationQueen
			$sHeroName = "Queen"
		Case $eHeroWarden
			$sTemplateDir = $g_sImgLocationWarden
			$sHeroName = "Warden"
		Case $eHeroChampion
			$sTemplateDir = $g_sImgLocationChamp
			$sHeroName = "Champ"
		Case Else
			SetDebugLog("Hero Altar name error!", $COLOR_ERROR)
			Return False
	EndSwitch

	SetDebugLog($sHeroName & " Template Dir: " & $sTemplateDir, $COLOR_INFO)

	If $sTemplateDir <> "" Then
		For $i = 0 To 1
			If QuickMIS("BC1", $sTemplateDir, 100, 55, 775, 580 + 44, True, False) Then
				SetLog($sHeroName & " Altar detected...", $COLOR_SUCCESS)
				PureClick($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
				If _Sleep(500) Then Return False
				Local $sInfo = BuildingInfo(242, 464)
				If @error Then SetError(0, 0, 0)
				Local $CountGetInfo = 0
				While IsArray($sInfo) = False
					$sInfo = BuildingInfo(242, 464)
					If @error Then SetError(0, 0, 0)
					If _Sleep(100) Then Return False
					$CountGetInfo += 1
					If $CountGetInfo = 50 Then Return False
				WEnd
				SetDebugLog($sInfo[1] & $sInfo[2])
				If @error Then Return SetError(0, 0, 0)
				If StringInStr($sInfo[1], $sHeroName) > 0 Then
					$aDetectedPosition[0] = $g_iQuickMISWOffSetX
					$aDetectedPosition[1] = $g_iQuickMISWOffSetY
					ClickP($aAway, 1, 200, "#0327")
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
				SetDebugLog("Hero Altar name error!", $COLOR_ERROR)
				Return False
		EndSwitch

		SetLog($sHeroName & " Altar Position Saved!", $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>DetectedAltar

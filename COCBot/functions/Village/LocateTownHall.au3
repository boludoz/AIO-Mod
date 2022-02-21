
; #FUNCTION# ====================================================================================================================
; Name ..........: LocateTownHall
; Description ...: Locates TownHall
; Syntax ........: LocateTownHall()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (July 2015) Sardo 2015-08
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateTownHall($bLocationOnly = False, $bFromButton = False)
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateTownHall 1")
	Local $result = _LocateTownHall($bLocationOnly, $bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateTownHall 2")
	Return $result
EndFunc   ;==>LocateTownHall

Func _LocateTownHall($bLocationOnly = False, $bFromButton = False)
	Local $sText, $MsgBox, $Success, $sLocMsg
	Local $iStupid = 0, $iSilly = 0, $sErrorText = ""
	SetLog("Locating Town Hall ...", $COLOR_INFO)
	ZoomOut()
	Collect(False, False)
	
	If $bLocationOnly Or $bFromButton = False Then
		If DetectedTH() Then
			chklocations()
			Return True
		EndIf
		If $bLocationOnly Then Return False
	EndIf
	
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return

	$g_aiTownHallPos[0] = -1
	$g_aiTownHallPos[1] = -1
	
	While 1
		_ExtMsgBoxSet(1 + 64, 1, 0x004080, 0xFFFF00, 12, "Tahoma", 600)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_TownHall_01", "Click OK then click on your Town Hall") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_TownHall_02", "Locate TownHall at ") & $g_sAndroidTitle, $sText, 30)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway(); ClickP($aAway, 1, 0, "#0391")
			Local $aPos = FindPos()
			$g_aiTownHallPos[0] = $aPos[0]
			$g_aiTownHallPos[1] = $aPos[1]
			If _Sleep($DELAYLOCATETH1) Then Return
			If isInsideDiamond($g_aiTownHallPos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "TownHall Location not valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & ")?" & @CRLF & "Please stop!" & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Townhall Location: " & "(" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & ")", $COLOR_ERROR)
						$g_aiTownHallPos[0] = -1
						$g_aiTownHallPos[1] = -1
						ClickAway(); ClickP($aAway, 1, 0, "#0392")
						Return False
				EndSelect
			EndIf
			SetLog("Townhall: " & "(" & $g_aiTownHallPos[0] & "," & $g_aiTownHallPos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate TownHall Cancelled", $COLOR_INFO)
			ClickAway(); ClickP($aAway, 1, 0, "#0393")
			Return False
		EndIf
		
		$Success = GetTownHallLevel()
		$iSilly += 1
		If IsArray($Success) Or $Success = False Then
			If $Success = False Then
				$sLocMsg = "Nothing"
			Else
				$sLocMsg = $Success[1]
			EndIf
			Select
				Case $iSilly = 1
					$sErrorText = "Wait, That is not a TownHall?, It was a " & $sLocMsg & @CRLF
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
					SetLog("Quit joking, Click on the TH, or restart bot and try again", $COLOR_ERROR)
					$g_aiTownHallPos[0] = -1
					$g_aiTownHallPos[1] = -1
					ClickAway(); ClickP($aAway, 1, 0, "#0394")
					Return False
			EndSelect
		Else
			SetLog("Locate TH Success!", $COLOR_SUCCESS)
		EndIf
		ExitLoop
	WEnd
	ClickAway(); ClickP($aAway, 1, 50, "#0209")
	Return True
EndFunc   ;==>_LocateTownHall

Func DetectedTH()
	Local $returnProps = "objectname,objectlevel,objectpoints"
	Local $xdirectorya = @ScriptDir & "\imgxml\Buildings\Townhall"
	Local $xdirectoryb = @ScriptDir & "\imgxml\Buildings\Townhall2"
	Local $aPaths = [$xdirectorya, $xdirectoryb]
	For $sPath In $aPaths
		Local $aResults = findMultiple($sPath, "ECD", "", 6, 14, 1, $returnProps, True)

		If IsArray($aResults) Then
			For $matchedValues In $aResults
				Local $aPoints = decodeMultipleCoords($matchedValues[2])
				Local $level = $matchedValues[1]
				Local $Name = $matchedValues[0]
				For $i = 0 To UBound($aPoints) - 1
					Local $aPOSITION = $aPoints[$i]
					$aPOSITION[0] = $aPOSITION[0]
					$aPOSITION[1] = $aPOSITION[1]
					PureClick($aPOSITION[0], $aPOSITION[1])
					SetLog($Name & " Lv" & $level & " detected...", $COLOR_SUCCESS)
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
					SetDebugLog($sInfo[1] & $sInfo[2])
					If @error Then Return SetError(0, 0, 0)
					If StringInStr($sInfo[1], "Tow") > 0 Then
						$g_aiTownHallPos[0] = $aPOSITION[0]
						$g_aiTownHallPos[1] = $aPOSITION[1]
						$g_iTownHallLevel = $level
						ClickAway(); ClickP($aAway, 1, 200, "#0327")
						If _Sleep(1000) Then Return
						IniWrite($g_sProfileBuildingPath, "other", "TownHallPosX", $g_aiTownHallPos[0])
						IniWrite($g_sProfileBuildingPath, "other", "TownHallPosY", $g_aiTownHallPos[1])
						IniWrite($g_sProfileBuildingPath, "other", "LevelTownHall", $level)
						SetLog($Name & " Lv" & $level & " Position & Level Saved!", $COLOR_SUCCESS)
						Return True
					Else
						SetDebugLog("TownHall incorrect position!", $COLOR_ERROR)
					EndIf
				Next
			Next
		EndIf
		ClickAway()
		If Not IsMainPage(2) Then ExitLoop
	Next
	Return False
EndFunc   ;==>DetectedTH

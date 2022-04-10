
; #FUNCTION# ====================================================================================================================
; Name ..........: LocateClanCastle
; Description ...: Locates Clan Castle manually (Temporary)
; Syntax ........: LocateClanCastle()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (06/2015) Sardo (08/2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func LocateClanCastle($bForceOff = True)
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateClanCastle 1")
	Local $result = _LocateClanCastle($bForceOff)
	$g_bRunState = $wasRunState
	AndroidShield("LocateClanCastle 2")
	Return $result
EndFunc   ;==>LocateClanCastle

Func _LocateClanCastle($bForceOff = True)
	Local $sText, $MsgBox, $iSilly = 0, $iStupid = 0, $sErrorText = "", $sInfo
	If Int($g_iTownHallLevel) < 3 Then Return
	SetLog("Locating Clan Castle.", $COLOR_INFO)
	If DetectedCastle() Then Return True
	If $bForceOff = True And ($g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm) Then Return False ; Va con prisa !
	
	ZoomOut()
	Collect(False, False)
	$g_aiClanCastlePos[0] = -1
	$g_aiClanCastlePos[1] = -1
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 500)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Clan_Castle_01", "Click OK then click on your Clan Castle") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", "Do not move mouse quickly after clicking location") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", "Make sure the building name is visible for me!") & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Clan_Castle_02", "Locate Clan Castle at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0373")
			Local $aPos = FindPos()
			$g_aiClanCastlePos[0] = $aPos[0]
			$g_aiClanCastlePos[1] = $aPos[1]
			If isInsideDiamond($g_aiClanCastlePos) = False Then
				$iStupid += 1
				Select
					Case $iStupid = 1
						$sErrorText = "Clan Castle Location Not Valid!" & @CRLF
						SetLog("Location not valid, try again", $COLOR_ERROR)
						ContinueLoop
					Case $iStupid = 2
						$sErrorText = "Please try to click inside the grass field!" & @CRLF
						ContinueLoop
					Case $iStupid = 3
						$sErrorText = "This is not funny, why did you click @ (" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")?" & @CRLF & "  Please stop!" & @CRLF & @CRLF
						ContinueLoop
					Case $iStupid = 4
						$sErrorText = "Last Chance, DO NOT MAKE ME ANGRY, or" & @CRLF & "I will give ALL of your gold to Barbarian King," & @CRLF & "And ALL of your Gems to the Archer Queen!" & @CRLF
						ContinueLoop
					Case $iStupid > 4
						SetLog(" Operator Error - Bad Clan Castle Location: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_ERROR)
						ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0374")
						Return False
					Case Else
						SetLog(" Operator Error - Bad Clan Castle Location: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_ERROR)
						$g_aiClanCastlePos[0] = -1
						$g_aiClanCastlePos[1] = -1
						ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0375")
						Return False
				EndSelect
			EndIf
			SetLog("Clan Castle: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_SUCCESS)
		Else
			SetLog("Locate Clan Castle Cancelled", $COLOR_INFO)
			ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0376")
			Return
		EndIf
		$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
		If IsArray($sInfo) And ($sInfo[0] > 1 Or $sInfo[0] = "") Then
			If StringInStr($sInfo[1], "clan") = 0 Then
				Local $sLocMsg = ($sInfo[0] = "" ? "Nothing" : $sInfo[1])
				$iSilly += 1
				Select
					Case $iSilly = 1
						$sErrorText = "Wait, That is not the Clan Castle?, It was a " & $sLocMsg & @CRLF
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
						SetLog("Quit joking, Click the Clan Castle, or restart bot and try again", $COLOR_ERROR)
						$g_aiClanCastlePos[0] = -1
						$g_aiClanCastlePos[1] = -1
						ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0377")
						Return False
				EndSelect
			EndIf
			If $sInfo[2] = "Broken" Then
				SetLog("You did not rebuild your Clan Castle yet.", $COLOR_ACTION)
			Else
				SetLog("Your Clan Castle is at level: " & $sInfo[2], $COLOR_SUCCESS)
			EndIf
		Else
			SetLog(" Operator Error - Bad Clan Castle Location: " & "(" & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1] & ")", $COLOR_ERROR)
			$g_aiClanCastlePos[0] = -1
			$g_aiClanCastlePos[1] = -1
			ClickAway() ; ClickAway(); ClickP($aAway, 1, 0, "#0378")
			Return False
		EndIf
		ExitLoop
	WEnd
	ClickAway()
	Return True
EndFunc   ;==>_LocateClanCastle

Func DetectedCastle()
	ZoomOut()
	
	Local $aResult = _ImageSearchXML($g_sImgLocationCastle, 0, "ECD")
	If UBound($aResult) < 1 Or @error Then Return False
	
	$aResult = CenterSort($aResult)
	
	Local $bStatus = $g_bUseRandomClick	
	Local $aClick[2] = [0, 0]
	For $i = 0 To UBound($aResult) - 1
		If $i > 0 Then CheckMainScreen(False)
		
		$aClick[0] = Int($aResult[$i][0])
		$aClick[1] = Int($aResult[$i][1])

		If isInsideDiamondInt($aClick[0], $aClick[1])  Then
			$g_bUseRandomClick = False
			PureClickP($aClick)
			If _Sleep(500) Then Return False
			$g_bUseRandomClick = $bStatus

			Local $sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
			If @error Then SetError(0, 0, 0)
			Local $iCountGetInfo = 0
			While IsArray($sInfo) = False
				$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
				If @error Then SetError(0, 0, 0)
				If _Sleep(100) Then Return False
				$iCountGetInfo += 1
				If $iCountGetInfo = 15 Then Return False
			WEnd
			SetDebugLog($sInfo[1] & " " & $sInfo[2])
			If @error Then Return SetError(0, 0, 0)

			If StringInStr($sInfo[1], "Cast") > 0 Then
				$g_aiClanCastlePos[0] = $aResult[$i][0]
				$g_aiClanCastlePos[1] = $aResult[$i][1]
				ConvertFromVillagePos($g_aiClanCastlePos[0], $g_aiClanCastlePos[1])
				ClickAway()
				If _Sleep(200) Then Return
				IniWrite($g_sProfileBuildingPath, "other", "CCPosX", $g_aiClanCastlePos[0])
				IniWrite($g_sProfileBuildingPath, "other", "CCPosY", $g_aiClanCastlePos[1])
				SetLog("Castle level " & $sInfo[2] & " Position Saved!", $COLOR_SUCCESS)
				Return True
			Else
				SetDebugLog("Castle incorrect position!", $COLOR_ERROR)
			EndIf

		EndIf
	Next
	
	Return False
EndFunc   ;==>DetectedCastle

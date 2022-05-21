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
Func LocateLab($bFromButton = False)
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	AndroidShield("LocateLab 1")
	Local $result = _LocateLab($bFromButton)
	$g_bRunState = $wasRunState
	AndroidShield("LocateLab 2")
	Return $result
EndFunc   ;==>LocateLab

Func _LocateLab($bFromButton = False)
	Local $sText, $MsgBox, $iStupid = 0, $iSilly = 0, $sErrorText = ""
	If Int($g_iTownHallLevel) < 3 Then Return
	SetLog("Locating Laboratory...", $COLOR_INFO)
	
	If $bFromButton = False Then
		If DetectedLabs() Then
			chklocations()
			Return True
		EndIf
	EndIf
	
	If $bFromButton = False And $g_bChkAvoidBuildingsLocate Or $g_bChkOnlyFarm Then Return

	ZoomOut()
	Collect(False, False)
	$g_aiLaboratoryPos[0] = -1
	$g_aiLaboratoryPos[1] = -1
	
	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 600)
		$sText = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_01", "Click OK then click on your Laboratory building") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_02", "Locate Laboratory at ") & $g_sAndroidTitle, $sText, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway()
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
						ClickAway(Default, True)
						Return False
					Case Else
						SetLog(" Operator Error - Bad Laboratory Location.", $COLOR_ERROR)
						$g_aiLaboratoryPos[0] = -1
						$g_aiLaboratoryPos[1] = -1
						ClickAway(Default, True)
						Return False
				EndSelect
			EndIf
		Else
			SetLog("Locate Laboratory Cancelled", $COLOR_INFO)
			ClickAway()
			Return
		EndIf
		Local $sLabInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
		If $sLabInfo[0] > 1 Or $sLabInfo[1] = "" Then
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
						ClickAway(Default, True)
						Return False
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Laboratory Location: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_ERROR)
			$g_aiLaboratoryPos[0] = -1
			$g_aiLaboratoryPos[1] = -1
			ClickAway()
			Return False
		EndIf
		SetLog("Locate Laboratory Success: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway()
	Return True
EndFunc   ;==>_LocateLab

Func CenterSort($aResult)
	Local $iDis = -1
	Local $iVillageCenter[2] = [$DiamondMiddleX, $DiamondMiddleY]
	Local $aMostly[0][3]
	For $i = 0 To UBound($aResult) - 1
		ReDim $aMostly[UBound($aMostly) + 1][4]
		$aMostly[UBound($aMostly) - 1][0] = Int($aResult[$i][1])
		$aMostly[UBound($aMostly) - 1][1] = Int($aResult[$i][2])
		$aMostly[UBound($aMostly) - 1][2] = Int(Pixel_Distance($iVillageCenter[0], $iVillageCenter[1], $aResult[$i][1], $aResult[$i][2]))
	Next
	_ArraySort($aMostly, 0, 0, 0, 2)
	Return $aMostly
EndFunc

Func DetectedLabs()
	
	Local $aResult = _ImageSearchXML($g_sImgLocationLabs, 0, $CocDiamondECD, True, False, True, 25)
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
			ClickP($aClick, 1)
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

			If StringInStr($sInfo[1], "Lab") > 0 Then
				$g_aiLaboratoryPos[0] = $aResult[$i][0]
				$g_aiLaboratoryPos[1] = $aResult[$i][1]
				ClickAway()
				If _Sleep(200) Then Return
				IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosX", $g_aiLaboratoryPos[0])
				IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosY", $g_aiLaboratoryPos[1])
				SetLog("Laboratory level " & $sInfo[2] & " Position Saved!", $COLOR_SUCCESS)
				Return True
			Else
				SetDebugLog("Lab incorrect position!", $COLOR_ERROR)
			EndIf

		EndIf
	Next
	
	Return False
EndFunc   ;==>DetectedLabs

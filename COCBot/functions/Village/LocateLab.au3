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
Func LocateLab($bCollect = True)
	Local $stext, $MsgBox, $iStupid = 0, $iSilly = 0, $sErrorText = ""
	
	If $g_iTownHallLevel < 3 And Not $g_iTownHallLevel < 1 Then
		SetLog("Townhall Lvl " & $g_iTownHallLevel & " has no Lab, so skip locating.", $COLOR_ACTION)
		Return
	EndIf
	
	; Avoid Locate - Team AIO Mod++ 
	If ($g_bAvoidLocate Or $g_bChkOnlyFarm) and $g_bIsReallyOn Then
		$g_aiLaboratoryPos[0] = -1
		$g_aiLaboratoryPos[1] = -1
		SetLog("Avoid Locate Laboratory...", $COLOR_INFO)
		Return False
	EndIf

	SetLog("Locating Laboratory", $COLOR_INFO)

    ; auto locate 
    ; ImgLocateLab()
	
	; GG MYBOT ! 
	#Region - Auto locate builds - Team AIO Mod++
	CheckMainScreen(Default, False)
	ClickAway()
	
	Local $aLabPos[2], $sInfo = ""
	Local $aLocateBuilds = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\AutoLocate\Lab\", 0, "FV")
	If UBound($aLocateBuilds) > 0 And not @error Then
		For $i = 0 To UBound($aLocateBuilds) -1
			$aLabPos[0] = $aLocateBuilds[$i][1]
			$aLabPos[1] = $aLocateBuilds[$i][2]
			
			If IsInsideDiamond($aLabPos) = False Then ContinueLoop
			
			ClickP($aLabPos)
			
			Local $iCountGetInfo = 0
			Do
				$sInfo = BuildingInfo(242, 550)
				If @error Then SetError(0, 0, 0)
				If _Sleep(100) Then Return
				$iCountGetInfo += 1
				If $iCountGetInfo = 10 Then Return
			Until IsArray($sInfo)
			
			If $g_bDebugSetlog Then SetDebugLog($sInfo[1] & $sInfo[2])
			If @error Then Return SetError(0, 0, 0)
		
			If $sInfo[0] > 1 Or $sInfo[0] = "" Then
				If @error Then Return SetError(0, 0, 0)
		
				If StringInStr($sInfo[1], "Lab") > 0 Then
					$g_aiLaboratoryPos = $aLabPos
					ConvertFromVillagePos($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
					IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosX", $g_aiLaboratoryPos[0])
					IniWrite($g_sProfileBuildingPath, "upgrade", "LabPosY", $g_aiLaboratoryPos[1])
					Setlog("Laboratory located", $COLOR_SUCCESS)
					ClickAway(True)
					Return True
				EndIf
				
			EndIf
			
			ClickAway(True)
			If _Sleep(500) Then Return
			
		Next
	EndIf
	
	If ($g_bAvoidLocate And $g_aiLaboratoryPos[0] < 1) and $g_bIsReallyOn Then
		SetLog("Avoid Locate Lab.", $COLOR_INFO)
		Return
	EndIf
	#EndRegion - Auto locate builds - Team AIO Mod++

	WinGetAndroidHandle()
	checkMainScreen()
	If $bCollect Then Collect(False)

	While 1
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Comic Sans MS", 600)
		$stext = $sErrorText & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_01", "Click OK then click on your Laboratory building") & @CRLF & @CRLF & _
				GetTranslatedFileIni("MBR Popups", "Locate_building_01", -1) & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Locate_building_02", -1) & @CRLF
		$MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Func_Locate_Laboratory_02", "Locate Laboratory"), $stext, 15)
		If $MsgBox = 1 Then
			WinGetAndroidHandle()
			ClickAway(True)
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
						ClickAway(True)
						Return False
				EndSelect
			EndIf
		Else
			SetLog("Locate Laboratory Cancelled", $COLOR_INFO)
			ClickAway(True)
			Return
		EndIf
		Local $sLabInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY); 860x780
		If $sLabInfo[0] > 1 Or $sLabInfo[1] = "" Then ; Team AIO Mod++
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
						SetLog("Ok, you really think that's a Laboratory?" & @CRLF & "I don't care anymore, go ahead with it!", $COLOR_ERROR)
						ClickAway(True)
						ExitLoop
				EndSelect
			EndIf
		Else
			SetLog(" Operator Error - Bad Laboratory Location: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_ERROR)
			$g_aiLaboratoryPos[0] = -1
			$g_aiLaboratoryPos[1] = -1
			ClickAway(True)
			Return False
		EndIf
		SetLog("Locate Laboratory Success: " & "(" & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1] & ")", $COLOR_SUCCESS)
		ExitLoop
	WEnd
	ClickAway(True)

EndFunc   ;==>LocateLab

#CS
; Image Search for Pet House
Func ImgLocateLab()
    Local $sImgDir = @ScriptDir & "\imgxml\Buildings\Laboratory\"

    Local $sSearchArea = "FV"
    Local $avLab = findMultiple($sImgDir, $sSearchArea, $sSearchArea, 0, 1000, 1, "objectname,objectpoints", True)

    If Not IsArray($avLab) Or UBound($avLab, $UBOUND_ROWS) <= 0 Then
        SetLog("Couldn't find Laboratory on main village", $COLOR_ERROR)
        If $g_bDebugImageSave Then SaveDebugImage("Laboratory", False)
        Return False
    EndIf

    Local $avLabRes, $aiLabCoords
    
    ; active/inactive Laboratory have different images
    ; loop thro the detected images
    For $i = 0 To UBound($avLab, $UBOUND_ROWS) - 1
        $avLabRes = $avLab[$i]
        SetLog("Laboratory Search find : " & $avLabRes[0])
        $aiLabCoords = decodeSingleCoord($avLabRes[1])
    Next

    If IsArray($aiLabCoords) And UBound($aiLabCoords, $UBOUND_ROWS) > 1 Then
        $g_aiLaboratoryPos[0] = $aiLabCoords[0]
        $g_aiLaboratoryPos[1] = $aiLabCoords[1]
        Return True
    EndIf
    
    Return False
EndFunc
#CE
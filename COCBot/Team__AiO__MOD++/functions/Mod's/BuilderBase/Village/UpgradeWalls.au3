; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseUpgradeWalls
; Description ...:
; Author ........: SpartanUBPT
; Modified ......:
; Remarks .......: This file is part of MultiBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MultiBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestRunWallsUpgradeBB()
	SetDebugLog("** TestRunWallsUpgradeBB START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	Local $wasWallsBB = $g_bChkBBUpgradeWalls
	$g_bRunState = True
	$g_bChkBBUpgradeWalls = True
	WallsUpgradeBB()
	$g_bRunState = $Status
	$g_bChkBBUpgradeWalls = $wasWallsBB
	SetDebugLog("** TestRunWallsUpgradeBB END**", $COLOR_DEBUG)
EndFunc   ;==>TestRunWallsUpgradeBB

Func WallsUpgradeBB()
	If Not $g_bRunState Then Return
	If Not $g_bChkBBUpgradeWalls Then Return

	FuncEnter(WallsUpgradeBB)

	Local $bBuilderBase = True

	If isOnBuilderBase() Then ; Double Check to see if Bot is on builder base
		SetLog("Start Upgrade BB Wall!", $COLOR_INFO)
		; Timer
		Local $hWallBBTimer = __TimerInit()

		; Get Builders available and gold report
		If Not getBuilderCount(False, $bBuilderBase) Then Return ; update builder data, return if problem
		If $g_aiCurrentLootBB[$eLootGoldBB] = 0 Then BuilderBaseReport() ; BB Gold is 0 then check builderbase report
		If _Sleep($DELAYRESPOND) Then Return

		; For new image detection
		Local $hStarttime = _Timer_Init()

		; Wall search level, 0 is not a level , this is the selected level to upgrade
		Local $iBBWallLevel = $g_iCmbBBWallLevel + 1
		; $iBBWallLevel + 1 will be correct values for the next level
		Local $iBBNextLevelCost = $g_aiWallBBInfoPerLevel[$iBBWallLevel + 1][1]

		SetDebugLog("Wall(s) to search lvl " & $iBBWallLevel)
		SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " Current Gold: " & $g_aiCurrentLootBB[$eLootGoldBB])

		If $g_iFreeBuilderCountBB > 0 And $g_bChkBBUpgradeWalls = True And Number($g_aiCurrentLootBB[$eLootGoldBB]) > $iBBNextLevelCost Then
			; Reurn an Array [xx][0] = Name , [xx][1] = Xaxis , [xx][2] = Yaxis , [xx][3] = Level
			Local $WallsBBNXY = _ImageSearchXML($g_sBundleWallsBB, $g_aBundleWallsBBParms[0], $g_aBundleWallsBBParms[1], $g_aBundleWallsBBParms[2], $g_bDebugBBattack, True, "10", $iBBWallLevel)
			If $g_bDebugSetlog Then SetDebugLog("Image Detection for Walls in Builder Base : " & Round(_Timer_Diff($hStarttime), 2) & "'ms")
			If IsArray($WallsBBNXY) And UBound($WallsBBNXY) > 0 Then
				SetDebugLog("Total Walls Found: " & UBound($WallsBBNXY))
				For $i = 0 To UBound($WallsBBNXY) - 1
					If $g_bDebugSetlog Then SetDebugLog($WallsBBNXY[$i][0] & " found at (" & $WallsBBNXY[$i][1] & "," & $WallsBBNXY[$i][2] & ")", $COLOR_SUCCESS)
					If IsMainPageBuilderBase() Then Click($WallsBBNXY[$i][1], $WallsBBNXY[$i][2], 1, 0, "#902") ; Click in Wall
					If _Sleep($DELAYCOLLECT3) Then Return
					Local $aResult = BuildingInfo(245, 520 - 30 + $g_iBottomOffsetY) ; Get building name and level with OCR
					If $aResult[0] = 2 Then ; We found a valid building name
						If StringInStr($aResult[1], "wall") = True And Number($aResult[2]) = $iBBWallLevel Then ; we found a wall
							SetLog("Position : " & $WallsBBNXY[$i][1] & ", " & $WallsBBNXY[$i][2] & " is a Wall Level: " & $iBBWallLevel & ".")
							If IsMainPageBuilderBase() Then Click($aWallUpgrade[0], $aWallUpgrade[1], 1, 0, "#903") ; Click upgrade button to upgrade
							If _Sleep($DELAYCHECKTOMBS2) Then Return
							If isGemOpen(True) Then
								ClickP($aAway, 1, 0, "#0932") ; click away
								SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
								ExitLoop
							ElseIf _ColorCheck(_GetPixelColor($aWallUpgradeOK[0], $aWallUpgradeOK[1], True), Hex($aWallUpgradeOK[2], 6), $aWallUpgradeOK[3]) = True Then ; color yellow "wall possible for bh level"
								SetLog("Builder Base Wall Upgrade Successfully!")
								Click($aWallUpgradeOK[0], $aWallUpgradeOK[1], 1, 0, "#904") ; Confirm Upgrade
								If _Sleep($DELAYRESPOND) Then Return
								ClickP($aAway, 1, 0, "#0932") ;Click Away
							Else
								SetLog("Builder Base Wall reached the maximum level allowed!", $COLOR_ERROR)
								ClickP($aAway, 1, 0, "#0932") ;Click Away
								ExitLoop
							EndIf
						EndIf
					Else
						SetLog("Position : " & $WallsBBNXY[$i][1] & ", " & $WallsBBNXY[$i][2] & " is not a Wall Level: " & $iBBWallLevel & ".", $COLOR_ERROR)
						ClickP($aAway, 1, 0, "#0932") ;Click Away
					EndIf
					If _Sleep($DELAYCHECKTOMBS2) Then Return
					; Check Gold for more then one wall.
					BuilderBaseReport() ; check builderbase report before upgrade another wall
					If _Sleep($DELAYRESPOND) Then Return
					If Number($g_aiCurrentLootBB[$eLootGoldBB]) < $iBBNextLevelCost Then
						SetLog("Upgrade stopped due to insufficient Gold!", $COLOR_INFO)
						ExitLoop
					EndIf
				Next
			Else
				SwitchToNextWallBBLevel()
			EndIf
		ElseIf $g_iFreeBuilderCountBB > 0 And $g_bChkBBUpgradeWalls = True And Number($g_aiCurrentLootBB[$eLootGoldBB]) < $iBBNextLevelCost Then
			SetLog("Upgrade stopped due to insufficient Gold", $COLOR_INFO)
		Else
			SetLog("Builder not available to upgrade Wall!")
		EndIf

		ClickP($aAway, 1, 300, "#0329") ;Click Away
	EndIf
	FuncReturn()
EndFunc   ;==>WallsUpgradeBB

Func SwitchToNextWallBBLevel()
	If $g_iCmbBBWallLevel >= 0 And $g_iCmbBBWallLevel < 7 Then
		EnableGuiControls()
		_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel + 1)
		cmbBBWall()
		SaveConfig()
		DisableGuiControls()
		Return True
	EndIf
	Return False
EndFunc   ;==>SwitchToNextWallBBLevel

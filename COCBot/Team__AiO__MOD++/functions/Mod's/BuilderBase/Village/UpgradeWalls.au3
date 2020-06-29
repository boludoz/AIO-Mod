; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseUpgradeWalls
; Description ...:
; Author ........: SpartanUBPT
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MultiBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;Builder Base Walls
Global $aWallUpgrade[4] = [521, 580 + $g_iMidOffsetY, 0x7B412B, 20] ; Upgrade Button main screen
Global $aWallUpgradeOK[4] = [483, 496 + $g_iMidOffsetY, 0xFFDC15, 20] ; Ok Button on main screen

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
Local $aWallBBInfoPerLevel[10][4] = [ _ ; Level, Gold, Qty, BH
		[0, 0, 0, 0], _
		[1, 4000, 20, 2], _
		[2, 10000, 50, 3], _
		[3, 100000, 50, 3], _
		[4, 300000, 75, 4], _
		[5, 800000, 100, 5], _
		[6, 1200000, 120, 6], _
		[7, 2000000, 140, 7], _
		[8, 3000000, 160, 8], _
		[9, 4000000, 170, 9]]

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
		Local $iBBNextLevelCost = $aWallBBInfoPerLevel[$iBBWallLevel + 1][1]

		SetDebugLog("Wall(s) to search lvl " & $iBBWallLevel)
		SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " Current Gold: " & $g_aiCurrentLootBB[$eLootGoldBB])

		If $g_iFreeBuilderCountBB > 0 And $g_bChkBBUpgradeWalls = True And Number($g_aiCurrentLootBB[$eLootGoldBB]) > $iBBNextLevelCost Then
			; Reurn an Array [xx][0] = Name , [xx][1] = Xaxis , [xx][2] = Yaxis , [xx][3] = Level
			Local $vWallsBBNXY = findMultipleQuick($g_sBundleWallsBB, Default, Default, Default, $iBBWallLevel, Default, 5, False)
			If $g_bDebugSetlog Then SetDebugLog("Image Detection for Walls in Builder Base : " & Round(_Timer_Diff($hStarttime), 2) & "'ms")
			If IsArray($vWallsBBNXY) And UBound($vWallsBBNXY) > 0 Then
				SetDebugLog("Total Walls Found: " & UBound($vWallsBBNXY))
				For $i = 0 To UBound($vWallsBBNXY) - 1
					If $g_bDebugSetlog Then SetDebugLog($vWallsBBNXY[$i][0] & " found at (" & $vWallsBBNXY[$i][1] & "," & $vWallsBBNXY[$i][2] & ")", $COLOR_SUCCESS)
					If Not isInDiamond($vWallsBBNXY[$i][1], $vWallsBBNXY[$i][2], 83, 156, 780, 680, 0) Then ContinueLoop
					If IsMainPageBuilderBase() Then Click($vWallsBBNXY[$i][1], $vWallsBBNXY[$i][2], 1, 0, "#902") ; Click in Wall
					If _Sleep($DELAYCOLLECT3) Then Return
					Local $aResult = BuildingInfo(245, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
					If $aResult[0] = 2 Then ; We found a valid building name
						If StringInStr($aResult[1], "wall") = True And Number($aResult[2]) = $iBBWallLevel Then ; we found a wall
							SetLog("Position : " & $vWallsBBNXY[$i][1] & ", " & $vWallsBBNXY[$i][2] & " is a Wall Level: " & $iBBWallLevel & ".")
							If IsMainPageBuilderBase() Then 
								Local $aButton = findMultipleQuick(@ScriptDir & "\imgxml\imglocbuttons", 1, "230,580,638,676", Default, "UpgradeBB", True, 5, False)
								If IsArray($aButton) Then 
									Click($aButton[0][1], $aButton[0][2])
									Else
									SetLog("WallsUpgradeBB | Error in imglocbuttons.", $COLOR_ERROR)
									ClickP($aAway, 1, 0, "#0932") ; click away
									ContinueLoop
								EndIf 
							EndIf
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
						SetLog("Position : " & $vWallsBBNXY[$i][1] & ", " & $vWallsBBNXY[$i][2] & " is not a Wall Level: " & $iBBWallLevel & ".", $COLOR_ERROR)
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
	If $g_iCmbBBWallLevel >= 0 And $g_iCmbBBWallLevel < 8 Then
		EnableGuiControls()
		_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel + 1)
		cmbBBWall()
		SaveConfig()
		DisableGuiControls()
		Return True
	EndIf
	Return False
EndFunc   ;==>SwitchToNextWallBBLevel

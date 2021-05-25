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

Func TestRunWallsUpgradeBB()
	SetDebugLog("** TestRunWallsUpgradeBB START**", $COLOR_DEBUG)
	Local $status = $g_bRunState
	Local $wasWallsBB = $g_bChkBBUpgradeWalls
	$g_bRunState = True
	$g_bChkBBUpgradeWalls = True
	WallsUpgradeBB()
	$g_bRunState = $status
	$g_bChkBBUpgradeWalls = $wasWallsBB
	SetDebugLog("** TestRunWallsUpgradeBB END**", $COLOR_DEBUG)
EndFunc   ;==>TestRunWallsUpgradeBB

Func WallsUpgradeBB()
EndFunc
#cs
	If Not $g_bRunState Then Return
	If Not $g_bChkBBUpgradeWalls Then Return
	FuncEnter(WallsUpgradeBB)
	Local $bBuilderBase = True
	If isOnBuilderIsland2() Then
		SetLog("Start Upgrade BB Wall!", $COLOR_INFO)
		Local $hWallBBTimer = __TimerInit()
		If Not getBuilderCount(False, $bBuilderBase) Then Return
		If $g_aiCurrentLootBB[$eLootGoldBB] = 0 Then BuilderBaseReport()
		If _Sleep($DELAYRESPOND) Then Return
		Local $hStarttime = _Timer_Init()
		Local $iBBWallLevel = $g_iCmbBBWallLevel + 1
		Local $iBBNextLevelCost = $g_aWallBBInfoPerLevel[$iBBWallLevel + 1][1]
		Local $bNextlevel = False
		SetDebugLog("Wall(s) to search lvl " & $iBBWallLevel)
		SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
		If $g_iFreeBuilderCountBB > 0 And $g_bChkBBWallRing Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Walls Rings loop " & $i)
				If DetectedWalls($iBBWallLevel) Then
					Local $aWallRing = findButton("WallRing")
					If $g_bDebugSetlog Then SetDebugLog("Array Wall Rings button --> " & _ArrayToString($aWallRing, " ", -1, -1, "|"))
					If IsArray($aWallRing) Then
						SetLog("Walls Ring found, let's Click it!", $COLOR_INFO)
						ClickP($aWallRing)
						If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
			Next
			ClickAway()
			BuilderBaseReport()
			SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
		EndIf
		If $g_iFreeBuilderCountBB > 0 And Number($g_aiCurrentLootBB[$eLootGoldBB]) > $iBBNextLevelCost And $g_bChkBBUpgWallsGold Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Gold loop " & $i)
				If Number($g_aiCurrentLootBB[$eLootGoldBB]) <= $iBBNextLevelCost Then ExitLoop
				If DetectedWalls($iBBWallLevel) Then
					If UpgradeCurrentWall("Gold") Then
						SetDebugLog("Wall level " & $iBBWallLevel & " Upgraded with Gold!")
					Else
						ExitLoop
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
				ClickAway()
				BuilderBaseReport()
				SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
			Next
		EndIf
		If $g_iFreeBuilderCountBB > 0 And Number($g_aiCurrentLootBB[$eLootElixirBB]) > $iBBNextLevelCost And $g_bChkBBUpgWallsElixir Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Elixir loop " & $i)
				If Number($g_aiCurrentLootBB[$eLootElixirBB]) <= $iBBNextLevelCost Then ExitLoop
				If DetectedWalls($iBBWallLevel) Then
					If UpgradeCurrentWall("Elixir") Then
						SetDebugLog("Wall level " & $iBBWallLevel & " Upgraded with Elixir!")
					Else
						ExitLoop
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
				ClickAway()
				BuilderBaseReport()
				SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
			Next
		EndIf
		ClickAway()
	EndIf
	FuncReturn()
EndFunc   ;==>WallsUpgradeBB

Func DetectedWalls($iBBWallLevel = 1)
	Local $hStarttime = _Timer_Init()
	ClickAway()
	Local $WallsBBNXY = _ImageSearchBundlesMultibot($g_sBundleWallsBB, $g_aBundleWallsBBParms[0], $g_aBundleWallsBBParms[1], $g_aBundleWallsBBParms[2], $F9087, True, "10", $iBBWallLevel)
	If $g_bDebugSetlog Then SetDebugLog("Image Detection for Walls in Builder Base : " & Round(_Timer_Diff($hStarttime), 2) & "'ms")
	If IsArray($WallsBBNXY) And UBound($WallsBBNXY) > 0 Then
		SetDebugLog("Total Walls Found: " & UBound($WallsBBNXY) & " --> " & _ArrayToString($WallsBBNXY, " ", -1, -1, "|"))
		For $i = 0 To UBound($WallsBBNXY) - 1
			If $g_bDebugSetlog Then SetDebugLog($WallsBBNXY[$i][0] & " found at (" & $WallsBBNXY[$i][1] & "," & $WallsBBNXY[$i][2] & ")", $COLOR_SUCCESS)
			If IsMainPageBuilderBase() Then Click($WallsBBNXY[$i][1], $WallsBBNXY[$i][2], 1, 0, "#902")
			If _Sleep($DELAYCOLLECT3) Then Return
			Local $aResult = BuildingInfo(245, 464)
			If $aResult[0] = 2 Then
				If StringInStr($aResult[1], "wall") = True And Number($aResult[2]) = $iBBWallLevel Then
					SetLog("Position : " & $WallsBBNXY[$i][1] & ", " & $WallsBBNXY[$i][2] & " is a Wall Level: " & $iBBWallLevel & ".")
					Return True
				EndIf
			EndIf
			ClickAway()
		Next
	EndIf
	Return False
EndFunc   ;==>DetectedWalls

Func UpgradeCurrentWall($resource = "Gold")
	Local $Directory2Search = $g_sImgAUpgradeDoubleHammerBtn
	Switch $resource
		Case "Gold"
			$Directory2Search = $g_sImgAUpgradeDoubleHammerBtnG
		Case "Elixir"
			$Directory2Search = $g_sImgAUpgradeDoubleHammerBtnE
		Case Else
			$Directory2Search = $g_sImgAUpgradeDoubleHammerBtn
	EndSwitch
	If IsMainPageBuilderBase() Then
		If QuickMIS("BC1", $Directory2Search, 120, 608 + $g_iBottomOffsetY, 740, 670 + $g_iBottomOffsetY) Then
			Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
		Else
			SetLog("Builder Base Wall Unable to find Upgrade Button!", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	If _Sleep($DELAYCHECKTOMBS2) Then Return
	If isGemOpen(True) Then
		ClickAway()
		SetLog("Upgrade stopped due no loot", $COLOR_ERROR)
	ElseIf _ColorCheck(_GetPixelColor($aWallUpgradeOK[0], $aWallUpgradeOK[1], True), Hex($aWallUpgradeOK[2], 6), $aWallUpgradeOK[3]) = True Then
		SetLog("Builder Base Wall Upgrade Successfully!")
		Click($aWallUpgradeOK[0], $aWallUpgradeOK[1], 1, 0, "#904")
		If _Sleep($DELAYRESPOND) Then Return
		ClickAway()
		Return True
	Else
		SetLog("Builder Base Wall reached the maximum level allowed!", $COLOR_ERROR)
		ClickAway()
	EndIf
	Return False
EndFunc   ;==>UpgradeCurrentWall

Func SwitchToNextWallBBLevel()
	If $g_iCmbBBWallLevel >= 0 And $g_iCmbBBWallLevel < 7 Then
		EnableGuiControls()
		_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel + 1)
		cmbBBWall()
		saveConfig()
		DisableGuiControls()
		Return True
	EndIf
	Return False
EndFunc   ;==>SwitchToNextWallBBLevel
#ce
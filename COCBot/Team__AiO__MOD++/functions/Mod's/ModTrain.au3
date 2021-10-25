;thx for Samkie from inspiration - Simple Mod ++ 2018

; Global $aTrainArmy[$eArmyCount] = [$aTrainBarb, $aTrainArch, $aTrainGiant, $aTrainGobl, $aTrainWall, $aTrainBall, $aTrainWiza, $aTrainHeal, $aTrainDrag, $aTrainPekk, $aTrainBabyD, $aTrainMine, $aTrainEDrag, $aTrainYeti, $aTrainMini, $aTrainHogs, $aTrainValk, $aTrainGole, $aTrainWitc, $aTrainLava, $aTrainBowl, $aTrainIceG, 0, 0, 0, 0, $aTrainLSpell, $aTrainHSpell, $aTrainRSpell, $aTrainJSpell, $aTrainFSpell, $aTrainCSpell, $aTrainPSpell, $aTrainESpell, $aTrainHaSpell, $aTrainSkSpell, $aTrainBaSpell]
Global Const $aButtonOpenTrainArmy[9]  	  	    = [ 25, 570,  50, 600,  50, 567, 0xEEAF45, 20, "=-= Open Train Army Page"] ; Main Screen, Army Train Button
Global Const $aButtonEditArmy_[9] = 		[723, 496 + 44, 834, 521 + 44, 754, 507 + 44, 0XB8E560, 20, "=-= Edit Army"]
Global Const $aButtonEditCancel[9] = 	[740, 456 + 44, 800, 476 + 44, 800, 471 + 44, 0XE91217, 20, "=-= Edit Army Cancel"]
Global Const $aButtonEditOkay[9] = 		[740, 518 + 44, 800, 538 + 44, 800, 516 + 44, 0XDDF685, 20, "=-= Edit Army Okay"]
Global Const $aButtonTrainArmy1[9] =	[730, 285 + 44, 820, 315 + 44, 775, 286 + 44, 0XDDF685, 20, "=-= Quick Train Army 1"]
Global Const $aButtonTrainArmy2[9] =	[730, 391 + 44, 820, 422 + 44, 775, 392 + 44, 0XDDF685, 20, "=-= Quick Train Army 2"]
Global Const $aButtonTrainArmy3[9] =	[730, 498 + 44, 820, 529 + 44, 775, 499 + 44, 0XDDF685, 20, "=-= Quick Train Army 3"]

Global $g_abIsQueueEmpty[2] = [False, False]
Global $g_abChkDonateReadyOnly[2] = [False, False]

;;;;;
Global $g_bFullCCTroops = False
Global $g_bFullCCSpells = False

Func RunRDNCSVScript()
#cs
	$g_aiScriptRNDAttack = GUICtrlRead($g_hCmbScriptNameAB)
	If $g_sTxtScriptName_Ramdom[0] = "" And $g_sTxtScriptName_Ramdom[1] = "" And $g_sTxtScriptName_Ramdom[2] = "" Then Return
	Local $tempRDN
	Do
		$tempRDN = Random(0, 2, 1)
	Until $g_sTxtScriptName_Ramdom[$tempRDN] <> ""
	$g_aiScriptNextRNDAttack = $g_sTxtScriptName_Ramdom[$tempRDN]
	ApplyRDNScript($g_aiScriptNextRNDAttack)
	$g_bChkEnableDeleteExcessTroops = False
	$g_bChkEnableDeleteExcessSieges = False
	$g_bPreciseBrew = False
	ApplyConfig_600_52_1("Read")
	ApplyConfig_600_52_2("Read")
	ApplyConfig_600_52_3("Read")
	SetSameCSVScriptAB()
	SaveConfig_600_29_DB_Scripted()
	ApplyScriptAB()
	$g_sRequestTroopsText = $P21903[$tempRDN]
	ApplyConfig_600_11("Read")
#ce
EndFunc   ;==>RunRDNCSVScript

Func RequestDefenseCC($A6453 = True)
#cs
	If $g_bIsLegendLeague Then Return False
	Local $bRequestDefense = False
	If $S12867 Then
		Local $sTime = $C12876 ? _DateAdd('n', -(Int($g_iSinglePBForcedEarlyExitTime)), $V12957) : $g_asShieldStatus[2]
		If Not $C12876 And $g_asShieldStatus[0] = "none" Then
			$bRequestDefense = True
			If $A6453 Then SetLog("No shield! Request troops for defense", $COLOR_INFO)
		ElseIf _DateIsValid($sTime) Then
			Local $iTime = Int(_DateDiff('n', _NowCalc(), $sTime))
			If $g_bDebugSetlog And $A6453 Then SetDebugLog("RequestDefenseCC->> $g_bRequestCCDefenseWhenPB: " & $C12876 & " | " & "$sTime: " & $sTime & " | " & "$iTime: " & $iTime)
			If Not $C12876 And $g_asShieldStatus[0] = "shield" Then $iTime += 30
			If $A6453 Then SetDebugLog(($C12876 ? "Personal Break time: " : "Guard time: ") & $sTime & "(" & $iTime & " minutes)")
			If $iTime <= $L12879 Then
				If $A6453 Then SetLog(($C12876 ? "P.Break is about to come!" : "Guard is about to expire!") & " Request troops for defense", $COLOR_INFO)
				$bRequestDefense = True
			EndIf
		EndIf
	Else
		If $g_bDebugSetlog And $A6453 Then SetDebugLog("RequestDefenseCC->> $g_bRequestCCDefense: " & $S12867 & " | " & "$g_bCanRequestCC: " & $g_bCanRequestCC)
	EndIf
	Return $bRequestDefense
#ce
EndFunc   ;==>RequestDefenseCC

#cs
Func RemoveCCTroopBeforeDefenseRequest($M7107 = False)
	If Not $S12867 Or Not $g_bChkRemoveCCForDefense Then
		If $g_bDebugSetlog Then SetDebugLog("RemoveCCTroopBeforeDefenseRequest->> $g_bRequestCCDefense: " & $S12867 & " | " & "$g_bCanRequestCC: " & $g_bCanRequestCC & " | " & "$g_bRemoveCCForDefense: " & $g_bChkRemoveCCForDefense)
		Return
	EndIf
	SetDebugLog("Getting current available troops in Clan Castle for Defense.")
	Local $iCount = 0
	Local $bFoundAnyWrongCCToRemove = False
	Local $aiCCTroopsDefenseToRemove[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $hHBitmap_Defense_CC_Slot[5] = [0, 0, 0, 0, 0]
	Local $hHBitmap_Defense_CC_SlotQty[5] = [0, 0, 0, 0, 0]
	While 1
		$iCount += 1
		If $iCount > 3 Then ExitLoop
		Local $aiCCDefenseTroopsInfo[5][3]
		Local $aPropsValues
		Local $bDeletedExcess = False
		Local $iTroopsCount = 0
		Local $iTroopIndex = -1
		GdiDeleteHBitmap($g_hHBitmap2)
		If _Sleep(250) Then ExitLoop
		If $g_bRunState = False Then ExitLoop
		_CaptureRegion2()
		For $i = 0 To UBound($MyTroops) - 1
			$N12861[$i] = 0
			$aiCCTroopsDefenseToRemove[$i] = 0
		Next
		For $i = 0 To 4
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			GdiDeleteHBitmap($hHBitmap_Defense_CC_Slot[$i])
			GdiDeleteHBitmap($hHBitmap_Defense_CC_SlotQty[$i])
			GdiDeleteHBitmap($D21711[$i])
			Local $iPixelDivider = ($V21597 - ($I21699[3] - $I21699[1])) / 2
			$hHBitmap_Defense_CC_Slot[$i] = GetHHBitmapArea($g_hHBitmap2, Int($I21699[0] + ($R21624 * $i) + (($R21624 - $V21597) / 2)), $I21699[1] - $iPixelDivider, Int($I21699[0] + ($R21624 * $i) + (($R21624 - $V21597) / 2) + $V21597), $I21699[3] + $iPixelDivider)
			Local $result = findMultiImage($hHBitmap_Defense_CC_Slot[$i], $g_sImgArmyOverviewCCTroops, "FV", "FV", 0, 1000, 1, "objectname")
			Local $bExitLoopFlag = False
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							If $aPropsValues[0] <> "0" Then
								$aiCCDefenseTroopsInfo[$i][0] = $aPropsValues[0]
								$aiCCDefenseTroopsInfo[$i][2] = $i + 1
								$iTroopsCount += 1
							EndIf
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect troops on Slot: " & $i + 1, $COLOR_INFO)
						SetLog("Troop: " & $aiCCDefenseTroopsInfo[$i][0], $COLOR_INFO)
						SetLog("Troop: " & $aPropsValues[0], $COLOR_INFO)
					Else
						$aPropsValues = $result[$j]
						SetLog("Troop: " & $aPropsValues[0], $COLOR_INFO)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then $bExitLoopFlag = True
			EndIf
			If $bExitLoopFlag = True Then ExitLoop
			$hHBitmap_Defense_CC_SlotQty[$i] = GetHHBitmapArea($g_hHBitmap2, Int($A21702[0] + ($R21624 * $i) + (($R21624 - $T21603) / 2)), $A21702[1], Int($A21702[0] + ($R21624 * $i) + (($R21624 - $T21603) / 2) + $T21603), $A21702[3])
			$aiCCDefenseTroopsInfo[$i][1] = getTSOcrFullComboQuantity($hHBitmap_Defense_CC_SlotQty[$i])
			If $aiCCDefenseTroopsInfo[$i][1] <> 0 Then
				$iTroopIndex = TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0])
				$N12861[$iTroopIndex] = $N12861[$iTroopIndex] + $aiCCDefenseTroopsInfo[$i][1]
			Else
				SetLog("Error detect Quantity no. On CC Troop: " & NameOfTroop(TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0]), $aiCCDefenseTroopsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			GdiDeleteHBitmap($hHBitmap_Defense_CC_Slot[$i])
			GdiDeleteHBitmap($hHBitmap_Defense_CC_SlotQty[$i])
			GdiDeleteHBitmap($D21711[$i])
		Next
		GdiDeleteHBitmap($g_hHBitmap2)
		If $iTroopsCount = 0 Then ExitLoop
		For $i = 0 To UBound($MyTroops) - 1
			If $g_bRunState = False Then ExitLoop
			Local $iTempTotal = $N12861[$i]
			If $iTempTotal > 0 Then
				SetLog(" - Clan Castle Troops - " & NameOfTroop(TroopIndexLookup($MyTroops[$i][0]), $N12861[$i]) & ": " & $N12861[$i], $COLOR_SUCCESS)
				Local $bIsTroopInKeepList = False
				If $X12864[0] Or $X12864[1] Or $X12864[2] Or $X12864[3] Then
					For $j = 0 To 3
						If TroopIndexLookup($MyTroops[$i][0]) + 1 = $X12864[$j] Then
							$bIsTroopInKeepList = True
							If $iTempTotal > $g_aiCCDefenseTroopWaitQty[$j] Then
								$aiCCTroopsDefenseToRemove[$i] = $iTempTotal - $g_aiCCDefenseTroopWaitQty[$j]
								$bDeletedExcess = True
							EndIf
							ExitLoop
						EndIf
					Next
					If $bIsTroopInKeepList = False Then
						$aiCCTroopsDefenseToRemove[$i] = $iTempTotal
						$bDeletedExcess = True
					EndIf
				EndIf
			EndIf
		Next
		If $bDeletedExcess Then
			$bFoundAnyWrongCCToRemove = True
			$bDeletedExcess = False
			SetLog(" >>> Remove UnWanted Clan Castle Troops.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 0 To 4
					If $aiCCDefenseTroopsInfo[$i][1] <> 0 Then
						Local $iUnitToRemove = $aiCCTroopsDefenseToRemove[TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0])]
						If $iUnitToRemove > 0 Then
							If $aiCCDefenseTroopsInfo[$i][1] > $iUnitToRemove Then
								SetLog("Remove " & NameOfTroop(TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0]), $aiCCDefenseTroopsInfo[$i][1]) & " at slot: " & $aiCCDefenseTroopsInfo[$i][2] & ", amount to remove: " & $iUnitToRemove, $COLOR_ACTION)
								RemoveOnTItem($aiCCDefenseTroopsInfo[$i][2] - 1, $iUnitToRemove, 0, "CCtroops")
								$iUnitToRemove = 0
								$aiCCTroopsDefenseToRemove[TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0])] = $iUnitToRemove
							Else
								SetLog("Remove " & NameOfTroop(TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0]), $aiCCDefenseTroopsInfo[$i][1]) & " at slot: " & $aiCCDefenseTroopsInfo[$i][2] & ", amount to remove: " & $aiCCDefenseTroopsInfo[$i][1], $COLOR_ACTION)
								RemoveOnTItem($aiCCDefenseTroopsInfo[$i][2] - 1, $aiCCDefenseTroopsInfo[$i][1], 0, "CCtroops")
								$iUnitToRemove -= $aiCCDefenseTroopsInfo[$i][1]
								$aiCCTroopsDefenseToRemove[TroopIndexLookup($aiCCDefenseTroopsInfo[$i][0])] = $iUnitToRemove
							EndIf
						EndIf
					EndIf
				Next
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				ExitLoop
			EndIf
			ClickOkay()
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				ContinueLoop
			Else
				If _Sleep(1000) Then ExitLoop
			EndIf
			ContinueLoop
		EndIf
		ExitLoop
	WEnd
	If Not $bFoundAnyWrongCCToRemove Then SetLog("No CC Troops Found To Remove For Defense.", $COLOR_INFO)
EndFunc   ;==>RemoveCCTroopBeforeDefenseRequest
#ce

Global $g_aiTroopsMaxCamp[2] = [0, 0]
Global $MyTroopsSetting[3][$eTroopCount][2]
Global $g_iMyTroopsSize = 0
Global $g_iTrainSystemErrors[8][3] = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
Global $g_bChkMyTroopsOrder = False
Global $g_bEnablePreTrainTroops = False
Global $g_bChkEnableDeleteExcessTroops = False
Global $g_bChkForcePreTrainTroops = False
Global $g_iForcePreTrainStrength = 95
Global $g_iCmbTroopSetting = 0
Global $g_iCmbMyQuickTrain = 0
Global $g_bDisableTrain = False
Global $V21450 = False
Global $Y21453 = False
Global $D21456 = False
Global $g_bResetArmyTroopsCombo = True
Global $g_iCmbNextTroopSetting[8] = [0, 0, 0, 0, 0, 0, 0, 0]

;name,order,size,unit quantity,train cost
Global $MyTroops[$eTroopCount][5]
#cs
Global $MyTroops[$eTroopCount][5] = _
[["Barb", 1, 1, 0, 0], _
["Arch", 2, 1, 0, 0], _
["Giant", 3, 5, 0, 0], _
["Gobl", 4, 1, 0, 0], _
["Wall", 5, 2, 0, 0], _
["Ball", 6, 5, 0, 0], _
["Wiza", 7, 4, 0, 0], _
["Heal", 8, 14, 0, 0], _
["Drag", 9, 20, 0, 0], _
["Pekk", 10, 25, 0, 0], _
["BabyD", 11, 10, 0, 0], _
["Mine", 12, 6, 0, 0], _
["EDrag", 13, 30, 0, 0], _
["Yeti", 14, 18, 0, 0], _
["SBarb", 15, 5, 0, 0], _
["SArch", 16, 12, 0, 0], _
["SGiant", 17, 10, 0, 0], _
["SGobl", 18, 3, 0, 0], _
["SWall", 19, 8, 0, 0], _
["InfernoD", 20, 15, 0, 0], _
["SWiza", 21, 10, 0, 0], _
["Mini", 22, 2, 0, 0], _
["Hogs", 23, 5, 0, 0], _
["Valk", 24, 8, 0, 0], _
["Gole", 25, 30, 0, 0], _
["Witc", 26, 12, 0, 0], _
["Lava", 27, 30, 0, 0], _
["Bowl", 28, 6, 0, 0], _
["IceG", 29, 15, 0, 0], _
["Hunt", 30, 6, 0, 0], _
["SWitc", 31, 40, 0, 0], _
["SMini", 32, 12, 0, 0], _
["SValk", 33, 20, 0, 0], _
["IceH", 34, 40, 0, 0], _
["RBall", 35, 8, 0, 0], _
["RDrag", 36, 25, 0, 0]]
#ce
Global $g_aiSpellsMaxCamp[2] = [0, 0]
Global $MySpellSetting[3][$eSpellCount][3]
Global $g_iMySpellsSize = 0
Global $O21480 = False ; SPELL ORDER
; Global $g_bPreciseBrew = False ALREADY IN AIO
; Global $g_bForcePreBrewSpells = False ALREADY IN AIO
Global $g_iTotalSpells = 0
Global $g_bDisableBrewSpell = False
Global $g_bEnablePreTrainSpells = False
Global $g_aSkipTrain[8] = [True, True, True, True, True, True, True, True]

;name,order,size,unit quantity,train cost, pre brew
Global $MySpells[$eSpellCount][6]
#cs
Global $MySpells[$eSpellCount][6] = _
[["LSpell", 1, 1, 0, 0, 0], _
["HSpell", 2, 2, 0, 0, 0], _
["RSpell", 3, 2, 0, 0, 0], _
["JSpell", 4, 2, 0, 0, 0], _
["FSpell", 5, 1, 0, 0, 0], _
["CSpell", 6, 3, 0, 0, 0], _
["ISpell", 7, 1, 0, 0, 0], _
["PSpell", 8, 1, 0, 0, 0], _
["ESpell", 9, 1, 0, 0, 0], _
["HaSpell", 10, 1, 0, 0, 0], _
["SkSpell", 11, 1, 0, 0, 0], _
["BtSpell", 12, 1, 0, 0, 0]]
#ce

Global $g_aiSiegesMaxCamp[2] = [0, 0]
Global $MySiegeSetting[3][$eSiegeMachineCount][3]
Global $g_iMySiegesSize = 0

;name,order,size,unit quantity,train cost, pre brew
Global $MySieges[$eSiegeMachineCount][7]
#cs
Global $MySieges[$eSiegeMachineCount][7] = _
[["WallW", 1, 1, 0, 0, 0, 0], _
["BattleB", 2, 1, 0, 0, 0, 0], _
["StoneS", 3, 1, 0, 0, 0, 0], _
["SiegeB", 4, 1, 0, 0, 0, 0], _
["LogL", 5, 1, 0, 0, 0, 0]]
#ce

Global $g_bFullArmySieges = False
Global $g_iCurrentSieges = 0, $g_iTotalSieges = 0
Global $O21525 = False, $U21528 = 3
Global $g_bDisableSiegeTrain = False
Global $D21534 = False
Global $g_bChkEnableDeleteExcessSieges = False
Global $g_bEnablePreTrainSieges = False
Global $W21543 = False
Global $V21546 = False
Global $g_iTrainArmyFullTroopPct = 100
; Global $g_bTotalCampForced = False, $g_iTotalCampForcedValue = 200
Global $g_iTotalSpellValue = 0
Global $g_iTroopButtonX = 0
Global $g_iTroopButtonY = 0
Global $g_bRestartCheckTroop = False
Global $g_bFullArmyHero = False
Global $g_aiCurrentTroops[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSpells[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSiegeMachines[$eSiegeMachineCount] = [0, 0, 0, 0]
Global $g_aiCurrentTroopsOnT[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSpellsOnT[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSiegeMachinesOnT[$eSiegeMachineCount] = [0, 0, 0, 0]
Global $g_aiCurrentTroopsOnQ[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSpellsOnQ[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSiegeMachinesOnQ[$eSiegeMachineCount] = [0, 0, 0, 0]
Global $g_aiCurrentTroopsReady[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSpellsReady[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentSiegeMachinesReady[$eSiegeMachineCount] = [0, 0, 0, 0]
Global $g_aiCurrentCCTroops[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentCCSpells[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_aiCurrentCCSiegeMachines[$eSiegeMachineCount] = [0, 0, 0, 0]

Global Const $g_iArmy_EnlargeRegionSizeForScan = 90
Global Const $g_iArmy_RegionSizeForScan = 20
Global Const $g_iArmy_ImageSizeForScan = 16
Global Const $g_iArmy_QtyWidthForScan = 60
Global Const $g_iArmy_OnTrainQtyWidthForScan = 40

Global Const $g_iArmy_Av_Spell_Slot_Width = 74
Global Const $g_iArmy_Av_Troop_Slot_Width = 74
Global Const $g_iArmy_Av_Siege_Slot_Width = 74

Global Const $g_iArmy_OnT_Troop_Slot_Width = 70.5

Global Const $g_iArmy_Av_CC_Slot_Width = 74
Global Const $g_iArmy_Av_CC_Spell_Slot_Width = 74
Global Const $g_iArmy_Av_CC_Siege_Slot_Width = 74

Global $g_hHBitmapArmyTab

; Troops
Global $g_hHBitmapArmyCap
Global $g_aiArmyCap[4] = [113, 123+44, 193, 137+44]
Global $g_hHBitmap_Av_Slot[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Av_SlotQty[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_Av_Slot[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_aiArmyAvailableSlot[4] = [22, 186+44, 537, 202+44]
Global $g_aiArmyAvailableSlotQty[4] = [24, 152 + 44, 840, 169+44]

; Spells
Global $g_hHBitmapSpellCap
Global $g_aiSpellCap[4] = [103, 269+44, 150, 284+44]
Global $g_hHBitmap_Av_Spell_Slot[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Av_Spell_SlotQty[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_Av_Spell_Slot[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_aiArmyAvailableSpellSlot[4] = [22, 328+44, 527, 344+44]
Global $g_aiArmyAvailableSpellSlotQty[4] = [24, 297+44, 526, 314+44]

; Sieges
Global $g_hHBitmapSiegeCap
Global $g_hHBitmap_Av_Siege_Slot[3] = [0, 0, 0]
Global $g_hHBitmap_Av_Siege_SlotQty[3] = [0, 0, 0]
Global $g_hHBitmap_Capture_Av_Siege_Slot[3] = [0, 0, 0]
Global $g_aiArmyAvailableSiegeSlot[4] = [604, 186+44, 838, 202+44]
Global $g_aiArmyAvailableSiegeSlotQty[4] = [606, 152 + 44, 821, 169+44]

; Castle
Global $g_aiArmyAvailableCCSlot[4] = [25, 488+44, 389, 504+44]
Global $g_aiArmyAvailableCCSlotQty[4] = [27, 453+44, 389, 471+44]

Global $g_hHBitmap_Av_CC_Slot[5] = [0, 0, 0, 0, 0]
Global $g_hArmyTab_CCTroop_NoUnit_Slot[5] = [0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_Av_CC_Slot[5] = [0, 0, 0, 0, 0]

Global $g_aiArmyAvailableCCSpellSlot[4] = [456, 485+44, 601, 500+44]
Global $g_aiArmyAvailableCCSpellSlotQty[4] = [458, 453+44, 601, 471+44]

Global $E21720[2] = [0, 0]
Global $g_hHBitmap_Av_CC_Spell_SlotQty[2] = [0, 0]
Global $g_hHBitmap_Capture_Av_CC_Spell_Slot[2] = [0, 0]

Global $g_aiArmyAvailableCCSiegeSlot[4] = [628, 488 + 44, 701, 504 + 44]
Global $g_aiArmyAvailableCCSiegeSlotQty[4] = [632, 453 + 44, 698, 471 + 44]

Global $g_hHBitmap_Av_CCSiege_Slot = 0
Global $g_hArmyTab_CCSiege_NoUnit_Slot = 0
Global $g_hHBitmap_Capture_Av_CCSiege_Slot = 0

; Troops
Global $g_hHBitmapTrainTab
Global $g_hHBitmapTrainCap
Global $g_aiTrainCap[4] = [45, 117+44, 115, 130+44]
Global $g_hHBitmap_OT_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_OT_SlotQty[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_OT_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_aiArmyOnTrainSlot[4] = [65, 168+44, 838, 184+44]
Global $g_aiArmyOnTrainSlotQty[4] = [67, 146+44, 838, 162+44] ;[67,190,838,206]

; Spells
Global $g_hHBitmapBrewTab
Global $g_hHBitmapBrewCap
Global $g_aiBrewCap[4] = [45, 117+44, 90, 130+44]
Global $g_hHBitmap_OB_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_OB_SlotQty[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_OB_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_aiArmyOnBrewSlot[4] = [65, 168+44, 838, 184+44]
Global $g_aiArmyOnBrewSlotQty[4] = [67, 146+44, 838, 162+44]

; Sieges
Global $g_hHBitmapSiegeTab
Global $g_hHBitmapSiegeCap
Global $g_hHBitmap_OS_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_OS_SlotQty[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hHBitmap_Capture_OS_Slot[11] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_aiArmyOnSiegeSlot[4] = [65, 168+44, 838, 184+44]
Global $g_aiArmyOnSiegeSlotQty[4] = [67, 146+44, 838, 162+44]

Global $F21816 = 2
Global $V21819 = False
Global $Q21822 = False
Global $L21825 = False
Global $E21828, $N21831, $V21834
Global $M21837 = False
Global $N21840 = False
Global $W21843 = False
Global $O21846[3] = [0, 0, 0]
Global $U21849[3] = [0, 0, 0]
Global $H21852[2] = [0, 0]
Global $B21855[2] = [0, 0]
Global $g_bChkWait4CC = False
Global $N21861 = 0
Global $X21864 = 0
Global $Q21867 = 0
Global $Y21870 = 100
Global $g_bFullCCTroops = False
Global $g_bChkWait4CCSpell = False
Global $N21879 = 0
Global $C21882 = 0
Global $g_bFullCCSpells = False
Global $g_bChkWait4CCSiege = False
Global $H21891
Global $B21894 = 0
Global $Y21897 = 0
Global $g_bFullCCSiegeMachine = False
Global $P21903[3]
Global $B21906[3][3][2]
Global $K21909[3][2][2]
Global $W21912[3]

Func _getArmyTroops($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("============Start _getArmyTroops ============")
	SetLog("Start check available unit...", $COLOR_INFO)

	Local $RemSlot[7] = [0, 0, 0, 0, 0, 0, 0]

	For $i = 0 To UBound($MyTroops) - 1
		$g_aiCurrentTroops[$i] = 0
		If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
			$MyTroops[$i][3] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][0]
			$MyTroops[$i][1] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][1]
		EndIf
	Next

	; 重建构_captureregion()里的?量$g_hHBitmap，$g_hBitmap，?_GetPixelColor()使用
	If $g_hHBitmap <> 0 Then
		GdiDeleteHBitmap($g_hHBitmap)
	EndIf
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	If $g_hBitmap <> 0 Then
		GdiDeleteBitmap($g_hBitmap)
	EndIf
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)

	Local $aiTroopsInfo[7][3]
	Local $AvailableCamp = 0
	Local $sDirectory = $g_sImgArmyOverviewTroops
	Local $returnProps="objectname"
	Local $aPropsValues
	Local $iTroopIndex = -1
	Local $sTroopName = ""
	Local $bDeletedExcess = False
	Local $bForceToDeleteUnknow = False

	For $i = 0 To 6
		If _ColorCheck(_GetPixelColor(Int(30 + ($g_iArmy_Av_Troop_Slot_Width * $i)),205,False), Hex(0X4689C8, 6), 20) Then
		;If Not _ColorCheck(_GetPixelColor(Int(30 + ($g_iArmy_Av_Troop_Slot_Width * $i)),205,False), Hex(0XCDCCC6, 6), 20) Then
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableSlot[3] - $g_aiArmyAvailableSlot[1])) / 2
			$g_hHBitmap_Av_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width- $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableSlot[1], Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width- $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableSlot[3])

			Local $result = findMultiImage($g_hHBitmap_Av_Slot[$i], $sDirectory ,"FV" ,"FV", 0, 1000, 1 , $returnProps)
			Local $bExitLoopFlag = False
			Local $bContinueNextLoop = False

			If IsArray($result) then
				For $j = 0 To UBound($result) -1
					If $j = 0 Then
						$aPropsValues = $result[$j] ; should be return objectname
						If UBound($aPropsValues) = 1 then
							$aiTroopsInfo[$i][0] = $aPropsValues[0] ; objectname
							;SetLog("objectname: " & $aiTroopsInfo[$i][0], $COLOR_DEBUG)
							$aiTroopsInfo[$i][2] = $i + 1
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect troops on slot: " & $i + 1 , $COLOR_ERROR)
						SetLog("Troop: " & $aiTroopsInfo[$i][0], $COLOR_ERROR)
						SetLog("Troop: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Troop: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
				If $aPropsValues[0]  = "0" Then $bExitLoopFlag = True
			Else
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableSlot[3] - $g_aiArmyAvailableSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSlot[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Troop_Av_Slot_" & $i + 1, True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_Slot[$i], "Troop_Slot_" & $i + 1 & "_Unknown_RenameThis_92", True)
				If $temphHBitmap <> 0 Then
					GdiDeleteHBitmap($temphHBitmap)
				EndIf
				SetLog("Error: Cannot detect what troops on slot: " & $i + 1 , $COLOR_ERROR)
				SetLog("Please check the filename: Troop_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_ERROR)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_ERROR)
				SetLog("And then restart the bot.", $COLOR_ERROR)
				$bContinueNextLoop = True
			EndIf

			If $bExitLoopFlag = True Then ExitLoop
			If $bContinueNextLoop Then
			; AIO
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				If $g_iTrainSystemErrors[$g_iCurAccount][0] > 5 Then
					If $g_bChkEnableDeleteExcessTroops Then
						SetLog("This Troop on slot " & $i + 1 & " needs to be removed!")
						$aiTroopsInfo[$i][0] = "UNKNOWN"
					EndIf
				Else
					ContinueLoop
				EndIf
			EndIf

			$g_hHBitmap_Av_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSlotQty[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width- 60) / 2)), $g_aiArmyAvailableSlotQty[1], Int($g_aiArmyAvailableSlotQty[0] + ($g_iArmy_Av_Troop_Slot_Width* $i) + (($g_iArmy_Av_Troop_Slot_Width- 60) / 2) + 60), $g_aiArmyAvailableSlotQty[3])

			$aiTroopsInfo[$i][1] = getTSOcrFullComboQuantity($g_hHBitmap_Av_SlotQty[$i])

			If $aiTroopsInfo[$i][1] <> 0 Then
				If $aiTroopsInfo[$i][0] = "UNKNOWN" Then
					$RemSlot[$i] = $aiTroopsInfo[$i][1]
					$bForceToDeleteUnknow = True
					$bDeletedExcess = True
				Else
					$iTroopIndex = TroopIndexLookup($aiTroopsInfo[$i][0])
					$sTroopName = GetTroopName($iTroopIndex, $aiTroopsInfo[$i][1])

					SetLog(" - No. of Available " & $sTroopName & ": " & $aiTroopsInfo[$i][1], $COLOR_SUCCESS)
					$g_aiCurrentTroops[$iTroopIndex] = $aiTroopsInfo[$i][1]

					; assign variable for drop trophy troops type
					For $j = 0 To UBound($g_avDTtroopsToBeUsed) - 1
						If $g_avDTtroopsToBeUsed[$j][0] = $aiTroopsInfo[$i][0] Then
							$g_avDTtroopsToBeUsed[$j][1] = $aiTroopsInfo[$i][1]
							ExitLoop
						EndIf
					Next

					$AvailableCamp += ($aiTroopsInfo[$i][1] * $MyTroops[$iTroopIndex][2])

					If $g_bChkEnableDeleteExcessTroops = 1 Then
						If $aiTroopsInfo[$i][1] > $MyTroops[$iTroopIndex][3] Then
							$bDeletedExcess = True
							SetLog(" >>> Excess: " & $aiTroopsInfo[$i][1] - $MyTroops[$iTroopIndex][3], $COLOR_WARNING)
							$RemSlot[$i] = $aiTroopsInfo[$i][1] - $MyTroops[$iTroopIndex][3]
							If $g_bDebugSetlogTrain Then SetLog("Set Remove Slot: " & $aiTroopsInfo[$i][2])
						EndIf
					EndIf

					; assign variable for drop trophy troops type
					For $j = 0 To UBound($g_avDTtroopsToBeUsed) - 1
						If $g_avDTtroopsToBeUsed[$j][0] = $aiTroopsInfo[$i][0] Then
							$g_avDTtroopsToBeUsed[$j][1] = $aiTroopsInfo[$i][1]
							ExitLoop
						EndIf
					Next
				EndIf
			Else
				SetLog("Error detect quantity no. On Troop: " & GetTroopName(TroopIndexLookup($aiTroopsInfo[$i][0]), $aiTroopsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
	Next

	If $AvailableCamp <> $g_CurrentCampUtilization And $bForceToDeleteUnknow = False Then
		If $g_bChkEnableDeleteExcessTroops = 1 Then
			SetLog("Error: Troops size for all available Unit: " & $AvailableCamp & "  -  Camp: " & $g_CurrentCampUtilization, $COLOR_RED)
			$g_bRestartCheckTroop = True
			If $g_bDebugSetlogTrain Then SetLog("return FALSE 1")
			$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
			Return False
		EndIf
	EndIf

		If $bDeletedExcess Then
			$bDeletedExcess = False
			If OpenTroopsTab() = False Then Return
			If _Sleep(1000) Then Return False
			If Not _ColorCheck(_GetPixelColor(823, 175 + $g_iMidOffsetY, True), Hex(0xCFCFC8, 6), 20) Then
				SetLog(" >>> stop train troops.", $COLOR_RED)
				RemoveAllTroopAlreadyTrain()
				If $g_bDebugSetlogTrain Then SetLog("return FALSE 2")
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				Return False
			EndIf

			If OpenArmyTab(True, "Train Troops Tab") = False Then Return
			If _Sleep(1000) Then Return False
			; If gotoArmy() = False Then Return
			SetLog(" >>> remove excess troops.", $COLOR_RED)
			If WaitforPixel($aButtonEditArmy_[4],$aButtonEditArmy_[5],$aButtonEditArmy_[4]+1,$aButtonEditArmy_[5]+1,Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7],20) Then
				Click($aButtonEditArmy_[0],$aButtonEditArmy_[1],1,0,"#EditArmy")
			Else
				If $g_bDebugSetlogTrain Then SetLog("return FALSE 3")
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				Return False
			EndIf

			If WaitforPixel($aButtonEditCancel[4],$aButtonEditCancel[5],$aButtonEditCancel[4]+1,$aButtonEditCancel[5]+1,Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7],20) Then
				For $i = 6 To 0 Step -1
					Local $RemoveSlotQty = $RemSlot[$i]
					If $g_bDebugSetlogTrain Then SetLog($i & " $RemoveSlotQty: " & $RemoveSlotQty)
					If $RemoveSlotQty > 0 Then
						Local $iRx = (80 + ($g_iArmy_Av_Troop_Slot_Width * $i))
						Local $iRy = 240 + $g_iMidOffsetY
						For $j = 1 To $RemoveSlotQty
							Click(Random($iRx-2,$iRx+2,1),Random($iRy-2,$iRy+2,1))
							If _Sleep($g_iTrainClickDelay) Then Return
						Next
						$RemSlot[$i] = 0
					EndIf
				Next
			Else
				If $g_bDebugSetlogTrain Then SetLog("return FALSE 4")
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				Return False
			EndIf

			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				If $g_bDebugSetlogTrain Then SetLog("return FALSE 5")
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				Return False
			EndIf

			ClickOkay()
			$g_bRestartCheckTroop = True
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				If $g_bDebugSetlogTrain Then SetLog("return FALSE 6")
				$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				Return False
			Else
				If _Sleep(1000) Then Return False
			EndIf
			If $g_bDebugSetlogTrain Then SetLog("return FALSE 7")
			$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
			Return False
		EndIf
		If $g_hHBitmap <> 0 Then
			GdiDeleteHBitmap($g_hHBitmap)
		EndIf
		If $g_hBitmap <> 0 Then
			GdiDeleteBitmap($g_hBitmap)
		EndIf
		Return True

	If $g_bDebugSetlogTrain Then SetLog("return FALSE 8")
	Return False
EndFunc   ;==>_getArmyTroops


#cs
Func getArmyTroopTime($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = True, $bSetLog = True, $bNeedCapture = True)

	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmyTroopTime():", $COLOR_DEBUG1)

	$g_aiTimeTrain[0] = 0 ; reset time

	If $bCheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "getArmyTroopTime()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf

	Local $sResultTroops = getRemainTrainTimer(495, 169, $bNeedCapture)
	$g_aiTimeTrain[0] = ConvertOCRTime("Troops", $sResultTroops, $bSetLog)

	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmyTroopTime
#ce

Func N29382($i)
	GdiDeleteHBitmap($g_hHBitmap_Av_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Av_SlotQty[$i])
EndFunc   ;==>N29382

Func getTrainSystemOcr($hHOCRBitmap, $language, $x_start, $y_start, $width, $height, $bImgLoc = False, $bRemoveSpace = False, $bReturnAsNumber = False)
	If _Sleep($DELAYRESPOND) Then Return ""
	Local $bDeleteHBitmapFlag = False
	If $hHOCRBitmap = 0 Then
		$bDeleteHBitmapFlag = True
		ForceCaptureRegion()
		_CaptureRegion2(Int($x_start), Int($y_start), Int($x_start + $width), Int($y_start + $height))
		$hHOCRBitmap = GetHHBitmapArea($g_hHBitmap2, 0, 0, $width, $height)
	EndIf
	Local $result
	If $bImgLoc Then
		$result = $hHOCRBitmap <> 0 ? getOcrImgLoc($hHOCRBitmap, $language) : getOcrImgLoc($g_hHBitmap2, $language)
	Else
		$result = $hHOCRBitmap <> 0 ? getOcr($hHOCRBitmap, $language) : getOcr($g_hHBitmap2, $language)
	EndIf
	If $bDeleteHBitmapFlag Then
		If $hHOCRBitmap <> 0 Then GdiDeleteHBitmap($hHOCRBitmap)
		If $g_hHBitmap2 <> 0 Then GdiDeleteHBitmap($g_hHBitmap2)
	EndIf
	$result = $bRemoveSpace ? StringReplace($result, " ", "") : StringStripWS($result, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	If $bReturnAsNumber Then
		If $result = "" Then $result = "0"
		$result = Number($result)
	EndIf
	Return $result
EndFunc   ;==>getTrainSystemOcr

Func getTSOcrArmyCap($hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-ms", 113, 122+44, 90, 17)
EndFunc   ;==>getTSOcrArmyCap
Func getTSOcrSpellCap($hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-ms", 102, 269+44, 45, 16)
EndFunc   ;==>getTSOcrSpellCap
Func getTSOcrSiegeCap($hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-ms", 759, 122+44, 40, 16)
EndFunc   ;==>getTSOcrSiegeCap
Func getTSOcrCCCap()
	Return getTrainSystemOcr(0, "coc-ms", 291, 422+44, 70, 18)
EndFunc   ;==>getTSOcrCCCap
Func getTSOcrCCSpellCap()
	Return getTrainSystemOcr(0, "coc-ms", 473, 422+44, 40, 18)
EndFunc   ;==>getTSOcrCCSpellCap
Func getTSOcrCCSiegeMachineCap()
	Return getTrainSystemOcr(0, "coc-ms", 650, 422+44, 40, 18)
EndFunc   ;==>getTSOcrCCSiegeMachineCap
Func getTSOcrTrainArmyOrBrewSpellCap($hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-NewCapacity", 46, 117+44, 87, 15)
EndFunc   ;==>getTSOcrTrainArmyOrBrewSpellCap
Func getTSOcrFullComboQuantity($hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-newarmy", 0, 0, 45, 18, False, True, True)
EndFunc   ;==>getTSOcrFullComboQuantity

Func getTSOcrFullComboOnQuantity($hHBitmap = 0, $bOnQueueTrain = False, $DebugOCR = False)
	Local $iQty
	Local $Area2Search = ""

	If $bOnQueueTrain Then
		$iQty = getMyOcr($hHBitmap, 0, 0, 0, 0, "spellqtypre", True)
	Else
		$iQty = StringReplace(getTrainSystemOcr($hHBitmap, "coc-qqtroop", 0, 0, 71, 22, False, True, True), "b", "")
	EndIf

	If $DebugOCR Or $g_bDebugOcr And $g_bDebugSetlogTrain Then
		Local $editedImage = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
		Local $libpath = @ScriptDir & "\lib\debug\ocr\"
		Local $time = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC
		Local $filename = "ocr_" & $time & " _getQueueTroopCount"
		_GDIPlus_ImageSaveToFile($editedImage, $libpath & $filename & ".png")
		FileWrite($libpath & $filename & ".txt", $iQty)
		_GDIPlus_BitmapDispose($editedImage)
	EndIf

	If StringIsSpace($iQty) Then SetLog("Dummy getTSOcrFullComboOnQuantity", $COLOR_ERROR)

	Return $iQty
EndFunc   ;==>getTSOcrFullComboOnQuantity

#Region - AIO
; #FUNCTION# ====================================================================================================================
; Name ..........: getMyOcr(BETA) 0.6
; Description ...: Reading characters using ImgLoc
; Syntax ........: getMyOcr($hHOCRBitmap,$x,$y,$width,$height,$bReturnAsNumber,$OCRType,$bFlagDecode)
; Parameters ....: $hHOCRBitmap             - HBitmap handle
;                  $x     					-
;                  $y    					-
;                  $width    				-
;                  $height    				-
;                  $OCRType    				- folder that store the character images.
;                  $bReturnAsNumber         - return as number
;                  $bFlagDecode             - is that need decode from config.ini
;				   $bFlagMulti	            - when use more than 1 image for determine one character.
; Return values .: String Or Number base on character images found.
; Author ........: Samkie (25 JUN 2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getMyOcr($hHOCRBitmap, $x, $y, $width, $height, $OCRType, $bReturnAsNumber = False, $bFlagDecode = False, $bFlagMulti = False)
;~ 	If $g_iSamM0dDebugOCR = 1 Then SetLog("========getMyOcr========", $COLOR_DEBUG)

	Local $aLastResult[1][4] ; col stored objectname, coorx, coory, level(width of the image)
	Local $sDirectory = ""
	Local $returnProps="objectname,objectpoints,objectlevel"
	Local $aCoor
	Local $aPropsValues
	Local $aCoorXY
	Local $result
	Local $sReturn = ""
	Local $iCount = 0
	Local $iMax = 0
	Local $jMax = 0
	Local $i, $j
	Local $bDeleteHBitmapFlag = False
	Local $tempOCRType = StringLower($OCRType)

	$sDirectory = @ScriptDir & "\COCBot\Team__AiO__MOD++\Bundles\OCR\SamTrainSys\" ; AIO

	If $hHOCRBitmap = 0 Then
		$bDeleteHBitmapFlag = True
		ForceCaptureRegion()
		_CaptureRegion2(Int($x), Int($y), int($x+$width), Int($y+$height))
		$hHOCRBitmap = GetHHBitmapArea($g_hHBitmap2,0,0,$width,$height)
	EndIf

	$result = findMultiImage($hHOCRBitmap, $sDirectory ,"FV" ,"FV", 0, 0, 0 , $returnProps)

	If IsArray($result) then
		$iMax = UBound($result) -1
		For $i = 0 To $iMax
			$aPropsValues = $result[$i] ; should be return objectname,objectpoints,objectlevel
			If UBound($aPropsValues) = 3 then
				;If $g_iSamM0dDebugOCR = 1 Then SetLog("$aPropsValues[0]: " & $aPropsValues[0], $COLOR_DEBUG)
				;If $g_iSamM0dDebugOCR = 1 Then SetLog("$aPropsValues[1]: " & $aPropsValues[1], $COLOR_DEBUG)
				;If $g_iSamM0dDebugOCR = 1 Then SetLog("$aPropsValues[2]: " & $aPropsValues[2], $COLOR_DEBUG)
				$aCoor = StringSplit($aPropsValues[1],"|",$STR_NOCOUNT) ; objectpoints, split by "|" to get multi coor x,y ; same image maybe can detect at different location.
				$jMax = UBound($aCoor) - 1
				For $j = 0 To $jMax  ; process every different location of image if found
					ReDim $aLastResult[$iCount + 1][4]
					If $bFlagDecode Then
						$aLastResult[$iCount][0] = TansCode($sDirectory,$OCRType,$aPropsValues[0])
					Else
						$aLastResult[$iCount][0] = StringReplace($aPropsValues[0],$tempOCRType,"",$STR_NOCASESENSE)

						If $bFlagMulti Then
							Local $asResult = StringRegExp($aLastResult[$iCount][0], '[0-9]', 1)
							If @error == 0 Then
								$aLastResult[$iCount][0] = $asResult[0]
							EndIf
						EndIf
					EndIf
					;If $g_iSamM0dDebugOCR = 1 Then SetLog("objectname: " & $aLastResult[$iCount][0], $COLOR_DEBUG)
					$aCoorXY = StringSplit($aCoor[$j],",",$STR_NOCOUNT) ; objectpoints, split by "," to get coor x,y
					If IsArray($aCoorXY) Then
						$aLastResult[$iCount][1] = Number($aCoorXY[0]) - (Number($aPropsValues[2] / 2))  ; get the imagelocation base on coor X
						$aLastResult[$iCount][2] = Number($aCoorXY[1]) ; get the imagelocation base on coor Y
					EndIf
					$aLastResult[$iCount][3] = Number($aPropsValues[2]) ; get image pixel width
					;If $g_iSamM0dDebugOCR = 1 Then SetLog("$aLastResult: obj-" & $aLastResult[$iCount][0] & " width-" & $aLastResult[$iCount][3] & " coor-"& $aLastResult[$iCount][1] & "," & $aLastResult[$iCount][2], $COLOR_DEBUG)
					$iCount += 1
				Next
			EndIf
		Next
		_ArraySort($aLastResult, 0, 0, 0, 1) ; rearrange order by coor X
		If $g_iSamM0dDebugOCR = 1 Then
			For $i = 0 To UBound($aLastResult) - 1
				SetLog("Afrer _ArraySort - Obj:" & $aLastResult[$i][0] & " Coor:" & $aLastResult[$i][1] & "," & $aLastResult[$i][2] & " Width:" & $aLastResult[$i][3], $COLOR_DEBUG)
			Next
		EndIf
		$iMax = UBound($aLastResult) - 1
		For $i = 0 To $iMax
			For $j = $i + 1 To $iMax
				If $aLastResult[$i][0] <> "" Then
					;If $g_iSamM0dDebugOCR = 1 Then SetLog("$i: " & $i & " - Check If CurX + Width: " & $aLastResult[$i][1] + $aLastResult[$i][3])
					;If $g_iSamM0dDebugOCR = 1 Then SetLog("$j: " & $j & " - Larger than Next ImageX: " & $aLastResult[$j][1])
					If ($aLastResult[$i][1] + $aLastResult[$i][3]) > $aLastResult[$j][1] Then
						; compare with width who the boss
						If $aLastResult[$i][3] > $aLastResult[$j][3] Then
							;If $g_iSamM0dDebugOCR = 1 Then SetLog("Remove $j: " & $j & " - " & $aLastResult[$j][0])
							$aLastResult[$j][0] = ""
						Else
							;If $g_iSamM0dDebugOCR = 1 Then SetLog("Remove $i: " & $i & " - " & $aLastResult[$i][0])
							$aLastResult[$i][0] = ""
							ExitLoop
						EndIf
					EndIf
				EndIf
			Next
			$sReturn = $sReturn & $aLastResult[$i][0]
		Next
	EndIf

	If $g_iSamM0dDebugOCR = 1 Or ($sReturn = "" And $tempOCRType <> "ccrequest") Then
		SetLog("getMyOcr $sReturn: " & $sReturn, $COLOR_DEBUG)
		_debugSaveHBitmapToImage($hHOCRBitmap, "getMyOcr_" & $OCRType & "_" & $sReturn & "_", True, True)
	EndIf

	If $bDeleteHBitmapFlag Then
		If $hHOCRBitmap <> 0 Then
			GdiDeleteHBitmap($hHOCRBitmap)
		EndIf
		If $g_hHBitmap2 <> 0 Then
			GdiDeleteHBitmap($g_hHBitmap2)
		EndIf
	EndIf

	If $bReturnAsNumber Then
		If $sReturn = "" Then $sReturn = "0"
		Return Number($sReturn)
	Else
		Return $sReturn
	EndIf
EndFunc ;==>getMyOcr

Func TansCode($sDirectory,$OCRType,$Msg)
	Local $result
	$result = IniRead($sDirectory & "\config.ini", StringLower($OCRType), $Msg, "")
	If $result = "" Then
		IniWrite($sDirectory & "\config.ini", StringLower($OCRType), $Msg, "")
	EndIf
	Return $result
EndFunc
#EndRegion - AIO

Func getTSOcrCostQuantity($x_start, $y_start, $hHBitmap = 0)
	Return getTrainSystemOcr($hHBitmap, "coc-NewCapacity", $x_start, $y_start, 68, 18, False, True, True) ; $x_start, $y_start
EndFunc   ;==>getTSOcrCostQuantity

Func CheckOnTrainTroops()
	Local $currentRunState = $g_bRunState
	$g_bRunState = True
	ClickP($aAway, 1, 0, "#0268")
	If _Sleep(200) Then Return
	If _Wait4Pixel($aButtonOpenTrainArmy[4], $aButtonOpenTrainArmy[5], $aButtonOpenTrainArmy[6], $aButtonOpenTrainArmy[7]) Then
		If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton", $COLOR_SUCCESS)
		If IsMainPage() Then
			If $g_bUseRandomClick = False Then
				Click($aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0, "#1293")
			Else
				ClickR($aArmyTrainButtonRND, $aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0)
			EndIf
		EndIf
	EndIf
	If _Sleep(250) Then Return
	DeleteTrainHBitmap()
	_CaptureRegion2()
	$g_hHBitmapArmyTab = GetHHBitmapArea($g_hHBitmap2)
	$g_hHBitmapArmyCap = GetHHBitmapArea($g_hHBitmapArmyTab, $g_aiArmyCap[0], $g_aiArmyCap[1], $g_aiArmyCap[2], $g_aiArmyCap[3])
	_getArmyTroopCapacity($g_hHBitmapArmyCap)
	_getArmyTroops($g_hHBitmapArmyTab)
	If _Sleep(250) Then Return
	If OpenTroopsTab() = False Then Return
	If _Sleep(100) Then Return
	_CaptureRegion2()
	$g_hHBitmapTrainTab = GetHHBitmapArea($g_hHBitmap2)
	$g_hHBitmapTrainCap = GetHHBitmapArea($g_hHBitmapTrainTab, $g_aiTrainCap[0], $g_aiTrainCap[1], $g_aiTrainCap[2], $g_aiTrainCap[3])
	getTroopCapacityMini($g_hHBitmapTrainCap)
	getArmyOnTroops($g_hHBitmapTrainTab)
	DeleteTrainHBitmap()
	$g_bRunState = $currentRunState
EndFunc   ;==>CheckOnTrainTroops
Func CheckOnTrainSpells()
	Local $currentRunState = $g_bRunState
	$g_bRunState = True
	ClickP($aAway, 1, 0, "#0268")
	If _Sleep(200) Then Return
	If _Wait4Pixel($aButtonOpenTrainArmy[4], $aButtonOpenTrainArmy[5], $aButtonOpenTrainArmy[6], $aButtonOpenTrainArmy[7]) Then
		If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton", $COLOR_SUCCESS)
		If IsMainPage() Then
			If $g_bUseRandomClick = False Then
				Click($aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0, "#1293")
			Else
				ClickR($aArmyTrainButtonRND, $aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0)
			EndIf
		EndIf
	EndIf
	If _Sleep(250) Then Return
	DeleteTrainHBitmap()
	_CaptureRegion2()
	$g_hHBitmapArmyTab = GetHHBitmapArea($g_hHBitmap2)
	$g_hHBitmapSpellCap = GetHHBitmapArea($g_hHBitmapArmyTab, $g_aiSpellCap[0], $g_aiSpellCap[1], $g_aiSpellCap[2], $g_aiSpellCap[3])
	_getArmySpellCapacity($g_hHBitmapSpellCap)
	getArmySpells2($g_hHBitmapArmyTab)
	If _Sleep(250) Then Return
	If OpenSpellsTab() = False Then Return
	If _Sleep(100) Then Return
	_CaptureRegion2()
	$g_hHBitmapBrewTab = GetHHBitmapArea($g_hHBitmap2)
	$g_hHBitmapBrewCap = GetHHBitmapArea($g_hHBitmapBrewTab, $g_aiBrewCap[0], $g_aiBrewCap[1], $g_aiBrewCap[2], $g_aiBrewCap[3])
	_getArmySpellCapacityMini($g_hHBitmapBrewCap)
	CheckOnBrewUnit($g_hHBitmapBrewTab)
	DeleteTrainHBitmap()
	$g_bRunState = $currentRunState
EndFunc   ;==>CheckOnTrainSpells

#CS
Func getArmySpells2($hHBitmap)
	If Not $g_bRunState Then Return
	If $g_bDebugSetlogTrain Then SetLog("getArmySpells2():", $COLOR_DEBUG)
	If Int($g_iTownHallLevel) < 5 Then Return
	Local $RemSpellSlot[7] = [0, 0, 0, 0, 0, 0, 0]
	SetLog("Check Army Spells", $COLOR_INFO)
	For $i = 0 To UBound($MySpells) - 1
		$g_aiCurrentSpells[$i] = 0
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiSpellsInfo[7][3]
	Local $AvailableCamp = 0
	Local $sDirectory = $g_sImgArmyOverviewSpells_
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iSpellIndex = -1
	Local $sSpellName = ""
	Local $bDeletedExcess = False
	Local $bForceToDeleteUnknow = False
	For $i = 0 To 6
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int(30 + ($g_iArmy_Av_Spell_Slot_Width * $i)), 301 + 44, False), Hex(0X7856E0, 6), 20) Then
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableSpellSlot[3] - $g_aiArmyAvailableSpellSlot[1])) / 2
			$g_hHBitmap_Av_Spell_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableSpellSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_Spell_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1], Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableSpellSlot[3])
			Local $result = findMultiImage($g_hHBitmap_Av_Spell_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$aiSpellsInfo[$i][0] = $aPropsValues[0]
							$aiSpellsInfo[$i][2] = $i + 1
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect spells on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Spell: " & $aiSpellsInfo[$i][0], $COLOR_ERROR)
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then
					O28380($i)
					ExitLoop
				EndIf
			ElseIf $g_bDebugSetlogTrain Or $g_iTrainSystemErrors[$g_iCurAccount][1] > 0 Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableSpellSlot[3] - $g_aiArmyAvailableSpellSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableSpellSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Spell_Av_Slot_" & $i + 1, "ArmyWindows\Spells\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_Spell_Slot[$i], "Spell_Slot_" & $i + 1 & "_Unknown_RenameThis_92", "ArmyWindows\Spells\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what spells on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: Spell_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				O28380($i)
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				If $g_iTrainSystemErrors[$g_iCurAccount][0] > 5 Then
					SetLog("This Spell on slot " & $i + 1 & " needs to be removed.")
					If $g_bPreciseBrew Then
						SetLog("This Spell on slot " & $i + 1 & " needs to be removed!")
						$aiSpellsInfo[$i][0] = "UNKNOWN"
					EndIf
				Else
					ContinueLoop
				EndIf
			Else
				SetLog("Enable Debug Mode", $COLOR_DEBUG)
				O28380($i)
				ContinueLoop
			EndIf
			$g_hHBitmap_Av_Spell_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlotQty[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2)), $g_aiArmyAvailableSpellSlotQty[1], Int($g_aiArmyAvailableSpellSlotQty[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2) + $g_iArmy_QtyWidthForScan), $g_aiArmyAvailableSpellSlotQty[3])
			$aiSpellsInfo[$i][1] = getTSOcrFullComboQuantity($g_hHBitmap_Av_Spell_SlotQty[$i])
			If $aiSpellsInfo[$i][1] <> 0 Then
				If $aiSpellsInfo[$i][0] = "UNKNOWN" Then
					$RemSpellSlot[$i] = $aiSpellsInfo[$i][1]
					$bForceToDeleteUnknow = True
					$bDeletedExcess = True
				Else
					$iSpellIndex = TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell
					$sSpellName = GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1])
					SetLog(" - No. of Available " & $sSpellName & ": " & $aiSpellsInfo[$i][1], $COLOR_SUCCESS)
					$g_aiCurrentSpells[$iSpellIndex] = $aiSpellsInfo[$i][1]
					$AvailableCamp += ($aiSpellsInfo[$i][1] * $MySpells[$iSpellIndex][2])
					If $g_bPreciseBrew Then
						If $aiSpellsInfo[$i][1] > $MySpells[$iSpellIndex][3] Then
							$bDeletedExcess = True
							SetLog(" >>> Excess: " & $aiSpellsInfo[$i][1] - $MySpells[$iSpellIndex][3], $COLOR_WARNING)
							$RemSpellSlot[$i] = $aiSpellsInfo[$i][1] - $MySpells[$iSpellIndex][3]
							If $g_bDebugSetlogTrain Then SetLog("Set Remove Slot: " & $aiSpellsInfo[$i][2])
						EndIf
					EndIf
				EndIf
			Else
				SetLog("Error detect quantity no. On Spell: " & GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		O28380($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $AvailableCamp <> $g_iCurrentSpells And $bForceToDeleteUnknow = False Then
		SetLog("Error: Spells size for all available Unit: " & $AvailableCamp & "  -  Camp: " & $g_iCurrentSpells, $COLOR_RED)
		$g_bRestartCheckTroop = True
		$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
		Return False
	Else
		If $bDeletedExcess Then
			$bDeletedExcess = False
			If OpenSpellsTab() = False Then Return False
			If Not _ColorCheck(_GetPixelColor(823, 175 + $g_iMidOffsetY, True), Hex(0xCFCFC8, 6), 20) Then
				SetLog(" >>> Stop Brew Spell.", $COLOR_WARNING)
				RemoveAllTroopAlreadyTrain()
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				Return False
			EndIf
			If OpenArmyTab(True, "Brew Spells Tab") = False Then Return
			SetLog(" >>> Remove Excess Spells.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				Return
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 6 To 0 Step -1
					Local $RemoveSlotQty = $RemSpellSlot[$i]
					If $g_bDebugSetlogTrain Then SetLog($i & " $RemoveSlotQty: " & $RemoveSlotQty)
					If $RemoveSlotQty > 0 Then
						Local $iRx = (80 + ($g_iArmy_Av_Spell_Slot_Width * $i))
						Local $iRy = 386 + $g_iMidOffsetY
						For $j = 1 To $RemoveSlotQty
							Click(Random($iRx - 2, $iRx + 2, 1), Random($iRy - 2, $iRy + 2, 1))
							If $g_bUseRandomClick = False Then
								If _Sleep($g_iTrainClickDelay) Then Return
							Else
								If $g_iTrainClickDelay < 100 Then $g_iTrainClickDelay += 100
								If $g_iTrainClickDelay > 400 Then $g_iTrainClickDelay -= 100
								If _Sleep(Random($g_iTrainClickDelay - 100, $g_iTrainClickDelay + 100, 1)) Then Return
							EndIf
						Next
						$RemSpellSlot[$i] = 0
					EndIf
				Next
			Else
				Return
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				Return
			EndIf
			ClickOkay()
			$g_bRestartCheckTroop = True
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				Return False
			Else
				If _Sleep(1000) Then Return False
			EndIf
			$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
			Return False
		EndIf
		GdiDeleteHBitmap($g_hHBitmap)
		GdiDeleteBitmap($g_hBitmap)
		Return True
	EndIf
	Return False
EndFunc   ;==>getArmySpells2
#CE
Func O28380($i)
	GdiDeleteHBitmap($g_hHBitmap_Av_Spell_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Spell_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Av_Spell_SlotQty[$i])
EndFunc   ;==>O28380
Func findMultiImage($hBitmap4Find, $directory, $sCocDiamond, $redLines, $minLevel = 0, $maxLevel = 1000, $maxReturnPoints = 0, $returnProps = "objectname,objectlevel,objectpoints")
	; same has findButton, but allow custom area instead of button area decoding
	; nice for dinamic locations
	If $g_bDebugSetlogTrain Then
		SetLog("******** findMultiImage *** START ***", $COLOR_ORANGE)
		SetLog("findMultiImage : directory : " & $directory, $COLOR_ORANGE)
		SetLog("findMultiImage : sCocDiamond : " & $sCocDiamond, $COLOR_ORANGE)
		SetLog("findMultiImage : redLines : " & $redLines, $COLOR_ORANGE)
		SetLog("findMultiImage : minLevel : " & $minLevel, $COLOR_ORANGE)
		SetLog("findMultiImage : maxLevel : " & $maxLevel, $COLOR_ORANGE)
		SetLog("findMultiImage : maxReturnPoints : " & $maxReturnPoints, $COLOR_ORANGE)
		SetLog("findMultiImage : returnProps : " & $returnProps, $COLOR_ORANGE)
		SetLog("******** findMultiImage *** START ***", $COLOR_ORANGE)
	EndIf

	If $g_bDebugSetlogTrain Then
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN & "." & @SEC
		_debugSaveHBitmapToImage($hBitmap4Find, "findMultiImage_" & $Date & "_" & $Time)
	EndIf

	Local $error, $extError

	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT)
	Local $returnLine[UBound($returnData)]
	Local $returnValues[0]


	; Capture the screen for comparison
	; Perform the search

	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $hBitmap4Find, "str", $directory, "str", $sCocDiamond, "Int", $maxReturnPoints, "str", $redLines, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		If $g_bDebugSetlogTrain Then SetLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return ""
	EndIf

	If checkImglocError($result, "findMultiImage") = True Then
		If $g_bDebugSetlogTrain Then SetLog("findMultiImage Returned Error or No values : ", $COLOR_DEBUG)
		If $g_bDebugSetlogTrain Then SetLog("******** findMultiImage *** END ***", $COLOR_ORANGE)
		Return ""
	Else
		If $g_bDebugSetlogTrain Then SetLog("findMultiImage found : " & $result[0])
	EndIf

	If $result[0] <> "" Then ;despite being a string, AutoIt receives a array[0]
		Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT)
		ReDim $returnValues[UBound($resultArr)]
		For $rs = 0 To UBound($resultArr) - 1
			For $rD = 0 To UBound($returnData) - 1 ; cycle props
				$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
				If $g_bDebugSetlogTrain Then SetLog("findMultiImage : " & $resultArr[$rs] & "->" & $returnData[$rD] & " -> " & $returnLine[$rD])
			Next
			$returnValues[$rs] = $returnLine
		Next

		;;lets check if we should get redlinedata
		If $redLines = "" Then
			$g_sImglocRedline = RetrieveImglocProperty("redline", "") ;global var set in imglocTHSearch
			If $g_bDebugSetlogTrain Then SetLog("findMultiImage : Redline argument is emty, seting global Redlines")
		EndIf
		If $g_bDebugSetlogTrain Then SetLog("******** findMultiImage *** END ***", $COLOR_ORANGE)
		Return $returnValues

	Else
		If $g_bDebugSetlogTrain Then SetLog(" ***  findMultiImage has no result **** ", $COLOR_ORANGE)
		If $g_bDebugSetlogTrain Then SetLog("******** findMultiImage *** END ***", $COLOR_ORANGE)
		Return ""
	EndIf

EndFunc   ;==>findMultiImage
Func getArmyOnTroops($hHBitmap)
	If Not $g_bRunState Then Return
	Local $aiCurrentTroopsRonT[$eTroopCount]
	Local $aiCurrentTroopsRonQ[$eTroopCount]

	For $i = 0 To $eTroopCount - 1
		$aiCurrentTroopsRonT[$i] = 0
		$aiCurrentTroopsRonQ[$i] = 0
	Next

	If $hHBitmap = 0 Then
		SetLog("Error: $hHBitmap = 0", $COLOR_ERROR)
		Return False
	EndIf
	If $g_bDebugSetlogTrain Then SetLog("Start getArmyOnTroops()", $COLOR_DEBUG)
	SetLog("Check Training Troops", $COLOR_INFO)
	For $i = 0 To UBound($MyTroops) - 1
		$g_aiCurrentTroopsOnT[$i] = 0
		$g_aiCurrentTroopsOnQ[$i] = 0
		$g_aiCurrentTroopsReady[$i] = 0
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiTroopInfo[11][4]
	Local $iAvailableCamp = 0
	Local $iOnQueueCamp = 0
	Local $iMyTroopsCampSize = 0
	Local $sDirectory
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iTroopIndex = -1, $iCount = 0
	Local $sTroopName = ""
	Local $bDeletedExcess = False, $bGotOnTrainFlag = False, $bGotOnQueueFlag = False
	For $i = 10 To 0 Step -1
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 152 + 44, False), Hex(0XCFCFC8, 6), 10) And _ColorCheck(_GetPixelColor(Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XCFCFC8, 6), 10) Then
			$aiTroopInfo[$i][0] = ""
			$aiTroopInfo[$i][1] = 0
			$aiTroopInfo[$i][2] = $i + 1
			$aiTroopInfo[$i][3] = False
			$iCount += 1
			If $g_bDebugSetlogTrain Then SetLog("Slot[" & $i & "] Is a Empty Slot", $COLOR_DEBUG)
		Else
			Local $bIsQueueTroop = False
			If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XD7AFA9, 6), 10) Then
				$sDirectory = $g_sImgArmyOnQueueTroops
				$bIsQueueTroop = True
				$g_abIsQueueEmpty[0] = True
				If $g_bDebugSetlogTrain Then SetLog("Slot[" & $i & "] Is a pre train unit", $COLOR_DEBUG)
			Else
				$sDirectory = $g_sImgArmyOnTrainTroops
			EndIf
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyOnTrainSlot[3] - $g_aiArmyOnTrainSlot[1])) / 2
			$g_hHBitmap_OT_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyOnTrainSlot[1] - $iPixelDivider, Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyOnTrainSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_OT_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyOnTrainSlot[1], Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyOnTrainSlot[3])
			Local $result = findMultiImage($g_hHBitmap_OT_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			Local $sObjectname = ""
			Local $iQty = 0
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $g_bDebugSetlogTrain Then SetLog("Slot[" & $i & "] Troops On Train Slots: " & _ArrayToString($result[$j]))
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$sObjectname = $aPropsValues[0]
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect troops on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Troop: " & $sObjectname, $COLOR_ERROR)
						SetLog("Troop: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Troop: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
			ElseIf $g_bDebugSetlogTrain Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyOnTrainSlot[3] - $g_aiArmyOnTrainSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyOnTrainSlot[1] - $iPixelDivider, Int($g_aiArmyOnTrainSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyOnTrainSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, ($bIsQueueTroop = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1, "TroopsWindows\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_OT_Slot[$i], ($bIsQueueTroop = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1 & "_Unknown_RenameThis_92", "TroopsWindows\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what troops on slot: " & $i, $COLOR_DEBUG)
				SetLog("Please check the filename: " & ($bIsQueueTroop = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				E28905($i)
				ContinueLoop
			Else
				SetLog("Enable Debug Mode.", $COLOR_DEBUG)
				E28905($i)
				ContinueLoop
			EndIf
			$g_hHBitmap_OT_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnTrainSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i)), $g_aiArmyOnTrainSlotQty[1], Int($g_aiArmyOnTrainSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + $g_iArmy_OnTrainQtyWidthForScan), $g_aiArmyOnTrainSlotQty[3])
			$iQty = $bIsQueueTroop ? getTSOcrFullComboOnQuantity($g_hHBitmap_OT_SlotQty[$i], True) : getTSOcrFullComboOnQuantity($g_hHBitmap_OT_SlotQty[$i])

			; If $bIsQueueTroop Then
				; $iQty = getMyOcr($g_hHBitmap_OT_SlotQty[$i],0,0,0,0,"spellqtypre", True)
				; SaveDebugImage("spellqtypre", $g_hHBitmap_OT_SlotQty[$i])
			; Else
				; $iQty = getMyOcr($g_hHBitmap_OT_SlotQty[$i],0,0,0,0,"spellqtybrew", True)
				; SaveDebugImage("spellqtybrew", $g_hHBitmap_OT_SlotQty[$i])
			; EndIf

			If $iQty <> 0 And $sObjectname <> "" Then
				$aiTroopInfo[$i][0] = $sObjectname
				$aiTroopInfo[$i][1] = $iQty
				$aiTroopInfo[$i][2] = $i + 1
				$aiTroopInfo[$i][3] = $bIsQueueTroop
				$iTroopIndex = TroopIndexLookup($aiTroopInfo[$i][0])
				$sTroopName = GetTroopName($iTroopIndex, $aiTroopInfo[$i][1])
				If $g_bDebugSetlogTrain Then SetLog("$sTroopName is " & $sTroopName & ", $iQty is " & $iQty & " is a Queued troop? " & $bIsQueueTroop)
				If $bIsQueueTroop Then
					$g_aiCurrentTroopsOnQ[$iTroopIndex] = $g_aiCurrentTroopsOnQ[$iTroopIndex] + $iQty
					Local $hHbitmap_ready = GetHHBitmapArea($hHBitmap, Int(112 + ($g_iArmy_OnT_Troop_Slot_Width * $i)), 196 + 44, Int(112 + ($g_iArmy_OnT_Troop_Slot_Width * $i) + 20), 204 + 44)
					_debugSaveHBitmapToImage($hHbitmap_ready, "hHbitmap_ready" & $i + 1, "TroopsWindows\Ready", True)
					$sDirectory = $g_sImgArmyReady
					$result = findMultiImage($hHbitmap_ready, $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
					GdiDeleteHBitmap($hHbitmap_ready)
					If IsArray($result) Then
						$g_aiCurrentTroopsReady[$iTroopIndex] = $g_aiCurrentTroopsReady[$iTroopIndex] + $iQty
					EndIf
				Else
					$g_aiCurrentTroopsOnT[$iTroopIndex] = $g_aiCurrentTroopsOnT[$iTroopIndex] + $iQty
				EndIf
				If $g_bDebugSetlogTrain Then SetLog("$g_aiCurrentTroopsOnT[$iTroopIndex] is " & $g_aiCurrentTroopsOnT[$iTroopIndex])
			Else
				SetLog("Error detect quantity no. On Troop: " & GetTroopName(TroopIndexLookup($sObjectname), $aiTroopInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		E28905($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $iCount = 11 Then
		SetLog("No Army in Train.", $COLOR_WARNING)
		Return True
	EndIf
	For $i = 0 To UBound($MyTroops) - 1
		If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
			$MyTroops[$i][3] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][0]
			$MyTroops[$i][1] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][1]
		EndIf
		Local $iTempTotal = $g_aiCurrentTroops[$i] + $g_aiCurrentTroopsOnT[$i]
		If $g_aiCurrentTroopsOnT[$i] > 0 Then
			SetLog(" - No. of On Train " & GetTroopName(TroopIndexLookup($MyTroops[$i][0]), $g_aiCurrentTroopsOnT[$i]) & ": " & $g_aiCurrentTroopsOnT[$i], $COLOR_ACTION)
			$bGotOnTrainFlag = True
		EndIf
		If $MyTroops[$i][3] < $iTempTotal Then
			If $g_bChkEnableDeleteExcessTroops Then
				SetLog("Error: " & GetTroopName(TroopIndexLookup($MyTroops[$i][0]), $g_aiCurrentTroopsOnT[$i]) & " need " & $MyTroops[$i][3] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
				$aiCurrentTroopsRonT[$i] = $iTempTotal - $MyTroops[$i][3]
				$bDeletedExcess = True
			EndIf
		EndIf
		If $iTempTotal > 0 Then
			$iAvailableCamp += $iTempTotal * $MyTroops[$i][2]
		EndIf
		If $MyTroops[$i][3] > 0 Then
			$iMyTroopsCampSize += $MyTroops[$i][3] * $MyTroops[$i][2]
		EndIf
	Next
	If $bDeletedExcess Then
		$bDeletedExcess = False
		SetLog(" >>> Some troops over train, Stop and Remove excess troops.", $COLOR_WARNING)
		If OpenTroopsTab() = False Then Return
		RemoveAllPreTrainTroops()
		_ArraySort($aiTroopInfo, 0, 0, 0, 2)
		For $i = 0 To 10
			If $aiTroopInfo[$i][1] <> 0 And $aiTroopInfo[$i][3] = False Then
				Local $iUnitToRemove = $aiCurrentTroopsRonT[TroopIndexLookup($aiTroopInfo[$i][0])]
				If $iUnitToRemove > 0 Then
					If $aiTroopInfo[$i][1] > $iUnitToRemove Then
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]) & " at slot: " & $aiTroopInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
						RemoveOnTItem($aiTroopInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
						$iUnitToRemove = 0
						$aiCurrentTroopsRonT[TroopIndexLookup($aiTroopInfo[$i][0])] = $iUnitToRemove
					Else
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]) & " at slot: " & $aiTroopInfo[$i][2] & ", unit to remove: " & $aiTroopInfo[$i][1], $COLOR_ACTION)
						RemoveOnTItem($aiTroopInfo[$i][2] - 1, $aiTroopInfo[$i][1], 0, "Troops")
						$iUnitToRemove -= $aiTroopInfo[$i][1]
						$aiCurrentTroopsRonT[TroopIndexLookup($aiTroopInfo[$i][0])] = $iUnitToRemove
					EndIf
				EndIf
			EndIf
		Next
		$g_bRestartCheckTroop = True
		If $g_bDebugSetlogTrain Then SetLog("Return False 1", $COLOR_INFO)
		$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
		Return False
	Else
		$bDeletedExcess = False
		$bGotOnQueueFlag = False
		For $i = 0 To UBound($MyTroops) - 1
			If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
				$MyTroops[$i][3] = $MyTroopsSetting[$g_iCmbNextTroopSetting[$g_iCurAccount]][$i][0]
				$MyTroops[$i][1] = $MyTroopsSetting[$g_iCmbNextTroopSetting[$g_iCurAccount]][$i][1]
			EndIf
			Local $iTempTotal = $g_aiCurrentTroopsOnQ[$i]
			If $iTempTotal > 0 Then
				SetLog(" - No. of On Queue " & GetTroopName(TroopIndexLookup($MyTroops[$i][0]), $g_aiCurrentTroopsOnQ[$i]) & ": " & $g_aiCurrentTroopsOnQ[$i] & " | Ready " & $g_aiCurrentTroopsReady[$i], $COLOR_ACTION1)
				$bGotOnQueueFlag = True
				If $MyTroops[$i][3] < $iTempTotal Then
					If $g_bChkEnableDeleteExcessTroops Then
						SetLog("Error: " & GetTroopName(TroopIndexLookup($MyTroops[$i][0]), $g_aiCurrentTroopsOnQ[$i]) & " need " & $MyTroops[$i][3] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
						$aiCurrentTroopsRonQ[$i] = $iTempTotal - $MyTroops[$i][3]
						$bDeletedExcess = True
					EndIf
				EndIf
				$iOnQueueCamp += $iTempTotal * $MyTroops[$i][2]
			EndIf
		Next
		If $bGotOnQueueFlag And Not $bGotOnTrainFlag Then
			If $g_bChkEnableDeleteExcessTroops Then
				If $iAvailableCamp < $iMyTroopsCampSize Or Not $g_bEnablePreTrainTroops Then
					If Not $g_bEnablePreTrainTroops Then
						SetLog("Pre-Train troops disable by user, remove all pre-train troops.[1]", $COLOR_WARNING)
					Else
						SetLog("Error: Troops size not correct but pretrain already.", $COLOR_ERROR)
						SetLog("Error: Detected Troops size = " & $iAvailableCamp & ", My Troops size = " & $iMyTroopsCampSize, $COLOR_ERROR)
					EndIf
					If OpenTroopsTab() = False Then Return
					RemoveAllPreTrainTroops()
					$g_bRestartCheckTroop = True
					If $g_bDebugSetlogTrain Then SetLog("Return False 2", $COLOR_INFO)
					$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
					Return False
				EndIf
			EndIf
		EndIf
		If $bDeletedExcess Then
			$bDeletedExcess = False
			SetLog(" >>> Some troops over train, stop and remove excess Pre-Train Troops.", $COLOR_WARNING)
			If OpenTroopsTab() = False Then Return
			_ArraySort($aiTroopInfo, 0, 0, 0, 2)
			For $i = 0 To 10
				If $aiTroopInfo[$i][1] <> 0 And $aiTroopInfo[$i][3] = True Then
					Local $iUnitToRemove = $aiCurrentTroopsRonQ[TroopIndexLookup($aiTroopInfo[$i][0])]
					If $iUnitToRemove > 0 Then
						If $aiTroopInfo[$i][1] > $iUnitToRemove Then
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]) & " at slot: " & $aiTroopInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
							RemoveOnTItem($aiTroopInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
							$iUnitToRemove = 0
							$aiCurrentTroopsRonQ[TroopIndexLookup($aiTroopInfo[$i][0])] = $iUnitToRemove
						Else
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]) & " at slot: " & $aiTroopInfo[$i][2] & ", unit to remove: " & $aiTroopInfo[$i][1], $COLOR_ACTION)
							RemoveOnTItem($aiTroopInfo[$i][2] - 1, $aiTroopInfo[$i][1], 0, "Troops")
							$iUnitToRemove -= $aiTroopInfo[$i][1]
							$aiCurrentTroopsRonQ[TroopIndexLookup($aiTroopInfo[$i][0])] = $iUnitToRemove
						EndIf
					EndIf
				EndIf
				If _Sleep(Random((250 * 90) / 100, (250 * 110) / 100, 1), False) Then Return False
			Next
			$g_bRestartCheckTroop = True
			If $g_bDebugSetlogTrain Then SetLog("Return False 3", $COLOR_INFO)
			$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
			Return False
		EndIf
		If $bGotOnQueueFlag And Not $bGotOnTrainFlag Then
			If $aiTroopInfo[0][1] > 0 Then
				If $g_bChkEnableDeleteExcessTroops Then
					If $iOnQueueCamp <> $iMyTroopsCampSize Then
						SetLog("Error: Pre-Train Troops size not correct.", $COLOR_ERROR)
						SetLog("Error: Detected Pre-Train Troops size = " & $iOnQueueCamp & ", My Troops size = " & $iMyTroopsCampSize, $COLOR_ERROR)
						If OpenTroopsTab() = False Then Return
						RemoveAllPreTrainTroops()
						$g_bRestartCheckTroop = True
						If $g_bDebugSetlogTrain Then SetLog("Return False 4", $COLOR_INFO)
						$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
						Return False
					EndIf
				EndIf
			EndIf
			If Not $g_bEnablePreTrainTroops Then
				SetLog("Pre-Train troops disable by user, remove all pre-train troops.[2]", $COLOR_WARNING)
				If OpenTroopsTab() = False Then Return
				RemoveAllPreTrainTroops()
			EndIf
		Else
			If $g_bChkMyTroopsOrder Then
				Local $aTempTroops[$eTroopCount][5]
				$aTempTroops = $MyTroops
				_ArraySort($aTempTroops, 0, 0, 0, 1)
				For $i = 0 To UBound($aTempTroops) - 1
					If $aTempTroops[$i][3] > 0 Then
						$aTempTroops[0][0] = $aTempTroops[$i][0]
						$aTempTroops[0][3] = $aTempTroops[$i][3]
						ExitLoop
					EndIf
				Next
				_ArraySort($aiTroopInfo, 1, 0, 0, 2)
				For $i = 0 To UBound($aiTroopInfo) - 1
					If $aiTroopInfo[$i][3] = True Then
						If $aiTroopInfo[$i][0] <> $aTempTroops[0][0] Then
							SetLog("Pre-Train First Slot: " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]), $COLOR_WARNING)
							SetLog("My first Order Troops: " & GetTroopName(TroopIndexLookup($aTempTroops[0][0]), $aTempTroops[0][3]), $COLOR_INFO)
							SetLog("Remove and Re-Training by order.", $COLOR_WARNING)
							RemoveAllPreTrainTroops()
							$g_bRestartCheckTroop = True
							If $g_bDebugSetlogTrain Then SetLog("Return False 5", $COLOR_INFO)
							$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
							Return False
						Else
							If $aiTroopInfo[$i][1] < $aTempTroops[0][3] Then
								SetLog("Pre-Train First slot: " & GetTroopName(TroopIndexLookup($aiTroopInfo[$i][0]), $aiTroopInfo[$i][1]) & " - Units: " & $aiTroopInfo[$i][1], $COLOR_WARNING)
								SetLog("My first Order Troops: " & GetTroopName(TroopIndexLookup($aTempTroops[0][0]), $aTempTroops[0][3]) & " - Units: " & $aTempTroops[0][3], $COLOR_INFO)
								SetLog("Not enough quantity, remove and re-training again.", $COLOR_WARNING)
								RemoveAllPreTrainTroops()
								$g_bRestartCheckTroop = True
								If $g_bDebugSetlogTrain Then SetLog("Return False 6", $COLOR_INFO)
								$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
								Return False
							EndIf
						EndIf
						ExitLoop
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	Return True
EndFunc   ;==>getArmyOnTroops
Func E28905($i)
	GdiDeleteHBitmap($g_hHBitmap_OT_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_OT_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_OT_SlotQty[$i])
EndFunc   ;==>E28905
Func getArmySiegeCapacity($hHBitmap, $bShowLog = True)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmySiegeCapacity():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	Local $aGetSiegeSize[3] = ["", "", ""]
	Local $sSiegeInfo = ""
	$g_iCurrentSieges = 0
	$g_iTotalSieges = 0
	For $i = 0 To UBound($MySieges) - 1
		$MySieges[$i][6] = 0
	Next
	Local $bIsWaitForSiegeEnable = False
	For $i = $DB To $LB
		If $g_abAttackTypeEnable[$i] Then
			If $g_abSearchSiegeWaitEnable[$i] Then
				SetLog(" " & $g_asModeText[$i] & " Setting - Waiting for siege ready.", $COLOR_ACTION)
				$bIsWaitForSiegeEnable = True
			EndIf
		EndIf
	Next
	If Int($g_iTownHallLevel) < 12 And Not $bIsWaitForSiegeEnable Then
		$g_bFullArmySieges = True
		Return
	EndIf
	$sSiegeInfo = getTSOcrSiegeCap($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("getArmySiegeCapacity $sSiegeInfo = " & $sSiegeInfo, $COLOR_DEBUG)
	$aGetSiegeSize = StringSplit($sSiegeInfo, "#")
	If IsArray($aGetSiegeSize) Then
		If $aGetSiegeSize[0] > 1 Then
			$g_iCurrentSieges = Number($aGetSiegeSize[1])
			$g_iTotalSieges = Number($aGetSiegeSize[2])
			If $MySieges[$eSiegeWallWrecker][5] = 1 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
				$MySieges[$eSiegeWallWrecker][6] = Number($aGetSiegeSize[2])
			ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 1 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
				$MySieges[$eSiegeBattleBlimp][6] = Number($aGetSiegeSize[2])
			ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 1 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
				$MySieges[$eSiegeStoneSlammer][6] = Number($aGetSiegeSize[2])
			ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 1 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
				$MySieges[$eSiegeBarracks][6] = Number($aGetSiegeSize[2])
			ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 1 Then
				$MySieges[$eSiegeLogLauncher][6] = Number($aGetSiegeSize[2])
			Else
				For $i = 0 To $eSiegeMachineCount - 1
					$MySieges[$i][6] = 0
				Next
			EndIf
		EndIf
	EndIf
	If $g_iTotalSieges <> 0 Then
		If $bShowLog Then SetLog("Sieges: " & $g_iCurrentSieges & "/" & $g_iTotalSieges)
	EndIf
	$g_bFullArmySieges = $g_iCurrentSieges >= 1
	If $g_bFullArmySieges = False Then
		If $bIsWaitForSiegeEnable = False Then
			SetLog("Not waiting for siege.", $COLOR_ACTION)
			$g_bFullArmySieges = True
		EndIf
	EndIf
EndFunc   ;==>getArmySiegeCapacity
Func getSiegeMachineCapacityMini($hHBitmap, $bShowLog = True)
	If $g_iTownHallLevel < 12 Then Return
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getSiegeMachineCapacityMini():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	Local $aTempSize
	Local $sSiegeInfo = ""
	$g_aiSiegesMaxCamp[0] = 0
	$g_aiSiegesMaxCamp[1] = 0
	$sSiegeInfo = getTSOcrTrainArmyOrBrewSpellCap($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("getSiegeMachineCapacityMini $sSiegeInfo = " & $sSiegeInfo, $COLOR_DEBUG)
	$aTempSize = StringSplit($sSiegeInfo, "#", $STR_NOCOUNT)
	If IsArray($aTempSize) Then
		If UBound($aTempSize) = 2 Then
			$g_aiSiegesMaxCamp[0] = Number($aTempSize[0])
			$g_aiSiegesMaxCamp[1] = Number($aTempSize[1])
		EndIf
	EndIf
	If $g_aiSiegesMaxCamp[1] <> 0 Then
		If $bShowLog Then SetLog("Max Sieges: " & $g_aiSiegesMaxCamp[0] & "/" & $g_aiSiegesMaxCamp[1])
	EndIf
EndFunc   ;==>getSiegeMachineCapacityMini
Func getArmySiegeTime($bSetLog = True, $bNeedCapture = True)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmySiegeTime():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	$g_aiTimeTrain[3] = 0
	Local $sResultSieges = getRemainTrainTimer(767, 118, $bNeedCapture)
	$g_aiTimeTrain[3] = ConvertOCRTime("Sieges", $sResultSieges, $bSetLog)
EndFunc   ;==>getArmySiegeTime
Func getBoostTimer($x_start, $y_start)
	Local $width = 70, $height = 12
	_CaptureRegion2($x_start, $y_start, $x_start + $width, $y_start + $height)
	_CaptureRegion($x_start, $y_start, $x_start + $width, $y_start + $height)
	Local $sDirectory = "boostsuper-bundle"
	Local $sReturnProps = "objectname,objectpoints"
	Local $aResult = ""
	Local $aChar[0][2]
	Local $string = ""
	Local $aCharsSize = [["0", 5], ["1", 3], ["2", 4], ["3", 4], ["4", 4], ["5", 5], ["6", 4], ["7", 3], ["8", 4], ["9", 5], ["d", 4], ["H", 4], ["m", 6]]
	$aResult = findMultiple($sDirectory, "FV", "FV", 0, 0, 1, $sReturnProps, False)
	If IsArray($aResult) And UBound($aResult) > 0 Then
		For $char = 0 To UBound($aResult) - 1
			SetDebugLog(_ArrayToString($aResult[$char], "-", -1, -1, " "))
			Local $aTemp = $aResult[$char]
			Local $sObjectname = String($aTemp[0])
			SetDebugLog("Char: " & $sObjectname, $COLOR_INFO)
			Local $aObjectpoints = $aTemp[1]
			If StringInStr($aObjectpoints, "|") Then
				$aObjectpoints = StringReplace($aObjectpoints, "||", "|")
				Local $X15288 = StringRight($aObjectpoints, 1)
				If $X15288 = "|" Then $aObjectpoints = StringTrimRight($aObjectpoints, 1)
				Local $tempObbj = StringSplit($aObjectpoints, "|", $STR_NOCOUNT)
				For $i = 0 To UBound($tempObbj) - 1
					ReDim $aChar[UBound($aChar) + 1][2]
					$aChar[UBound($aChar) - 1][0] = $sObjectname
					Local $tempObbjs = StringSplit($tempObbj[$i], ",", $STR_NOCOUNT)
					$aChar[UBound($aChar) - 1][1] = Number($tempObbjs[0])
				Next
			Else
				ReDim $aChar[UBound($aChar) + 1][2]
				$aChar[UBound($aChar) - 1][0] = $sObjectname
				Local $tempObbj = StringSplit($aObjectpoints, ",", $STR_NOCOUNT)
				$aChar[UBound($aChar) - 1][1] = Number($tempObbj[0])
			EndIf
		Next
		SetDebugLog("Final String without X sort: " & _ArrayToString($aChar, "-", -1, -1, " "))
		_ArraySort($aChar, 0, 0, 0, 1)
		SetDebugLog("Final String after X sort: " & _ArrayToString($aChar, "-", -1, -1, " "))
		Local $lastPOsition = 0
		For $i = 0 To UBound($aChar) - 1
			If $i = 0 Then
				$lastPOsition = $aChar[$i][1]
				$string &= $aChar[$i][0]
			Else
				Local $Size = 3
				For $xx = 0 To UBound($aCharsSize) - 1
					If $aChar[$i][0] = $aCharsSize[$xx][0] Then $Size = $aCharsSize[$xx][1]
				Next
				If $lastPOsition + Floor($Size / 2) > $aChar[$i][1] Then
					SetDebugLog("Same Char? '" & $aChar[$i][0] & "' at X:" & $aChar[$i][1] & " and '" & $aChar[$i - 1][0] & "' at X:" & $aChar[$i - 1][1])
				Else
					$lastPOsition = $aChar[$i][1]
					$string &= $aChar[$i][0]
				EndIf
			EndIf
		Next
	Else
		SetLog("Error getting the " & $sDirectory, $COLOR_DEBUG)
	EndIf
	If $g_bDebugSetlogTrain Or $g_bDebugOcr Then
		Local $subDirectory = @ScriptDir & "\OCR_Boosted\"
		DirCreate($subDirectory)
		Local $date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN & "." & @SEC
		Local $fileNameUntouched = "OCR_Boosted" & "_" & $date & "_" & $Time & "___" & $string & ".png"
		_GDIPlus_ImageSaveToFile($g_hBitmap, $subDirectory & $fileNameUntouched)
	EndIf
	Return $string
EndFunc   ;==>getBoostTimer
Func CheckOnBrewUnit($hHBitmap)
	If Not $g_bRunState Then Return
	If Int($g_iTownHallLevel) < 5 Then Return
	If $hHBitmap = 0 Then
		SetLog("Error: $hHBitmap = 0", $COLOR_ERROR)
		Return False
	EndIf
	Local $aiCurrentSpellsRonT[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCurrentSpellsRonQ[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	If $g_bDebugSetlogTrain Then SetLog("============Start CheckOnBrewUnit ============")
	SetLog("Check Training Spells", $COLOR_INFO)
	For $i = 0 To UBound($MySpells) - 1
		$g_aiCurrentSpellsOnT[$i] = 0
		$g_aiCurrentSpellsOnQ[$i] = 0
		$g_aiCurrentSpellsReady[$i] = 0
		$aiCurrentSpellsRonT[$i] = 0
		$aiCurrentSpellsRonQ[$i] = 0
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiSpellInfo[11][4]
	Local $iAvailableCamp = 0
	Local $iMySpellsCampSize = 0
	Local $iOnQueueCamp = 0
	Local $iMyPreBrewSpellSize = 0
	Local $sDirectory
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iSpellIndex = -1
	Local $sSpellName = ""
	Local $bDeletedExcess = False
	Local $bGotOnBrewFlag = False
	Local $bGotOnQueueFlag = False
	Local $iCount = 0
	For $i = 10 To 0 Step -1
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 152 + 44, False), Hex(0XCFCFC8, 6), 10) And _ColorCheck(_GetPixelColor(Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XCFCFC8, 6), 10) Then
			$aiSpellInfo[$i][0] = ""
			$aiSpellInfo[$i][1] = 0
			$aiSpellInfo[$i][2] = $i + 1
			$aiSpellInfo[$i][3] = False
			$iCount += 1
		Else
			Local $bIsQueueSpell = False
			If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XD7AFA9, 6), 10) Then
				$sDirectory = $g_sImgArmyOnQueueSpells
				$bIsQueueSpell = True
				$g_abIsQueueEmpty[1] = True
			Else
				$sDirectory = $g_sImgArmyOnTrainSpells
			EndIf
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyOnBrewSlot[3] - $g_aiArmyOnBrewSlot[1])) / 2
			$g_hHBitmap_OB_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyOnBrewSlot[1] - $iPixelDivider, Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyOnBrewSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_OB_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyOnBrewSlot[1], Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyOnBrewSlot[3])
			Local $result = findMultiImage($g_hHBitmap_OB_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			Local $sObjectname = ""
			Local $iQty = 0
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$sObjectname = $aPropsValues[0]
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect spells on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Spell: " & $sObjectname, $COLOR_ERROR)
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
			ElseIf $g_bDebugSetlogTrain Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyOnBrewSlot[3] - $g_aiArmyOnBrewSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyOnBrewSlot[1] - $iPixelDivider, Int($g_aiArmyOnBrewSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyOnBrewSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, ($bIsQueueSpell = True ? "Spell_Queue_Slot_" : "Spell_Brew_Slot_") & $i + 1, "SpellsWindows\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_OB_Slot[$i], ($bIsQueueSpell = True ? "Spell_Queue_Slot_" : "Spell_Brew_Slot_") & $i + 1 & "_Unknown_RenameThis_92", "SpellsWindows\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what spells on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: " & ($bIsQueueSpell = True ? "Spell_Queue_Slot_" : "Spell_Brew_Slot_") & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				C28089($i)
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				ContinueLoop
			Else
				SetLog("Enable Debug Mode.", $COLOR_DEBUG)
				C28089($i)
				ContinueLoop
			EndIf
			$g_hHBitmap_OB_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnBrewSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i)), $g_aiArmyOnBrewSlotQty[1], Int($g_aiArmyOnBrewSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + 40), $g_aiArmyOnBrewSlotQty[3])
			$iQty = $bIsQueueSpell ? getTSOcrFullComboOnQuantity($g_hHBitmap_OB_SlotQty[$i], True) : getTSOcrFullComboOnQuantity($g_hHBitmap_OB_SlotQty[$i])

			; If $bIsQueueSpell Then
				; $iQty = getMyOcr($g_hHBitmap_OB_SlotQty[$i],0,0,0,0,"spellqtypre", True)
				; SaveDebugImage("spellqtypre", $g_hHBitmap_OB_SlotQty[$i])
			; Else
				; $iQty = getMyOcr($g_hHBitmap_OB_SlotQty[$i],0,0,0,0,"spellqtybrew", True)
				; SaveDebugImage("spellqtybrew", $g_hHBitmap_OB_SlotQty[$i])
			; EndIf

			If $iQty <> 0 And $sObjectname <> "" Then
				$aiSpellInfo[$i][0] = $sObjectname
				$aiSpellInfo[$i][1] = $iQty
				$aiSpellInfo[$i][2] = $i + 1
				$aiSpellInfo[$i][3] = $bIsQueueSpell
				$iSpellIndex = TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell
				$sSpellName = GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1])
				If $bIsQueueSpell Then
					$g_aiCurrentSpellsOnQ[$iSpellIndex] = $g_aiCurrentSpellsOnQ[$iSpellIndex] + $iQty
					Local $hHbitmap_ready = GetHHBitmapArea($hHBitmap, Int(122 + ($g_iArmy_OnT_Troop_Slot_Width * $i)), 197 + 44, Int(122 + ($g_iArmy_OnT_Troop_Slot_Width * $i) + 5), 202 + 44)
					_debugSaveHBitmapToImage($hHbitmap_ready, "hHbitmap_ready" & $i + 1, "SpellsWindows\Ready", True)
					$sDirectory = $g_sImgArmyReady
					$result = findMultiImage($hHbitmap_ready, $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
					GdiDeleteHBitmap($hHbitmap_ready)
					If IsArray($result) Then
						$g_aiCurrentSpellsReady[$iSpellIndex] = $g_aiCurrentSpellsReady[$iSpellIndex] + $iQty
					EndIf
				Else
					$g_aiCurrentSpellsOnT[$iSpellIndex] = $g_aiCurrentSpellsOnT[$iSpellIndex] + $iQty
				EndIf
			Else
				SetLog("Error detect quantity no. On Spell: " & GetTroopName(TroopIndexLookup($sObjectname), $iQty), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		C28089($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $iCount = 11 Then
		SetLog("No Spell in Brew.", $COLOR_WARNING)
		Return True
	EndIf
	$bGotOnBrewFlag = False
	For $i = 0 To UBound($MySpells) - 1
		Local $iTempTotal = $g_aiCurrentSpells[$i] + $g_aiCurrentSpellsOnT[$i]
		If $g_aiCurrentSpellsOnT[$i] > 0 Then
			SetLog(" - No. of On Brew " & GetTroopName(TroopIndexLookup($MySpells[$i][0]), $g_aiCurrentSpellsOnT[$i]) & ": " & $g_aiCurrentSpellsOnT[$i], $COLOR_ACTION)
			$bGotOnBrewFlag = True
		EndIf
		If $MySpells[$i][3] < $iTempTotal Then
			If $g_bPreciseBrew Then
				SetLog("Error: " & GetTroopName(TroopIndexLookup($MySpells[$i][0]), $g_aiCurrentSpellsOnT[$i]) & " need " & $MySpells[$i][3] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
				$aiCurrentSpellsRonT[$i] = $iTempTotal - $MySpells[$i][3]
				$bDeletedExcess = True
			EndIf
		EndIf
		If $iTempTotal > 0 Then
			$iAvailableCamp += $iTempTotal * $MySpells[$i][2]
		EndIf
		If $MySpells[$i][3] > 0 Then
			$iMySpellsCampSize += $MySpells[$i][3] * $MySpells[$i][2]
		EndIf
	Next
	If $bDeletedExcess Then
		$bDeletedExcess = False
		If OpenSpellsTab() = False Then Return
		SetLog(" >>> Some Spells over train, stop and remove Spells.", $COLOR_WARNING)
		RemoveAllPreTrainTroops()
		_ArraySort($aiSpellInfo, 0, 0, 0, 2)
		For $i = 0 To 10
			If $aiSpellInfo[$i][1] <> 0 And $aiSpellInfo[$i][3] = False Then
				Local $iUnitToRemove = $aiCurrentSpellsRonT[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell]
				If $iUnitToRemove > 0 Then
					If $aiSpellInfo[$i][1] > $iUnitToRemove Then
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]) & " at slot: " & $aiSpellInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
						RemoveOnTItem($aiSpellInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
						$iUnitToRemove = 0
						$aiCurrentSpellsRonT[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell] = $iUnitToRemove
					Else
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]) & " at slot: " & $aiSpellInfo[$i][2] & ", unit to remove: " & $aiSpellInfo[$i][1], $COLOR_ACTION)
						RemoveOnTItem($aiSpellInfo[$i][2] - 1, $aiSpellInfo[$i][1], 0, "Troops")
						$iUnitToRemove -= $aiSpellInfo[$i][1]
						$aiCurrentSpellsRonT[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell] = $iUnitToRemove
					EndIf
				EndIf
			EndIf
		Next
		$g_bRestartCheckTroop = True
		$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
		Return False
	Else
		$bDeletedExcess = False
		$bGotOnQueueFlag = False
		For $i = 0 To UBound($MySpells) - 1
			Local $iTempTotal = $g_aiCurrentSpellsOnQ[$i]
			If $iTempTotal > 0 Then
				SetLog(" - No. of On Queue " & GetTroopName(TroopIndexLookup($MySpells[$i][0]), $g_aiCurrentSpellsOnQ[$i]) & ": " & $g_aiCurrentSpellsOnQ[$i] & " | Ready " & $g_aiCurrentSpellsReady[$i], $COLOR_ACTION1)
				$bGotOnQueueFlag = True
				If $MySpells[$i][5] = 1 Then
					If $MySpells[$i][3] < $iTempTotal Then
						If $g_bPreciseBrew Then
							SetLog("Error: " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $g_aiCurrentSpellsOnQ[$i]) & " need " & $MySpells[$i][3] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
							$aiCurrentSpellsRonQ[$i] = $iTempTotal - $MySpells[$i][3]
							$bDeletedExcess = True
						EndIf
					EndIf
					$iMyPreBrewSpellSize += $iTempTotal * $MySpells[$i][2]
				Else
					SetLog("Error: " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $g_aiCurrentSpellsOnQ[$i]) & " not needed to pre brew, remove all.", $COLOR_ERROR)
					$aiCurrentSpellsRonQ[$i] = $iTempTotal
					$bDeletedExcess = True
				EndIf
				$iOnQueueCamp += $iTempTotal * $MySpells[$i][2]
			EndIf
		Next
		If $bGotOnQueueFlag And Not $bGotOnBrewFlag Then
			If $iAvailableCamp < $iMySpellsCampSize Or Not $g_bEnablePreTrainSpells Then
				If Not $g_bEnablePreTrainSpells Then
					SetLog("Pre-Brew spells disable by user, remove all pre-train spells.", $COLOR_WARNING)
				Else
					SetLog("Error: Spells size not correct but pretrain already.", $COLOR_ERROR)
					SetLog("Error: Detected Spells size = " & $iAvailableCamp & ", My Spells size = " & $iMySpellsCampSize, $COLOR_ERROR)
				EndIf
				If OpenSpellsTab() = False Then Return
				RemoveAllPreTrainTroops()
				$g_bRestartCheckTroop = True
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				Return False
			EndIf
		EndIf
		If $bDeletedExcess Then
			$bDeletedExcess = False
			If OpenSpellsTab() = False Then Return
			SetLog(" >>> Some spells over train, stop and remove pre-train Spells.", $COLOR_WARNING)
			_ArraySort($aiSpellInfo, 0, 0, 0, 2)
			For $i = 0 To 10
				If $aiSpellInfo[$i][1] <> 0 And $aiSpellInfo[$i][3] = True Then
					Local $iUnitToRemove = $aiCurrentSpellsRonQ[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell]
					If $iUnitToRemove > 0 Then
						If $aiSpellInfo[$i][1] > $iUnitToRemove Then
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]) & " at slot: " & $aiSpellInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
							RemoveOnTItem($aiSpellInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
							$iUnitToRemove = 0
							$aiCurrentSpellsRonQ[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell] = $iUnitToRemove
						Else
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]) & " at slot: " & $aiSpellInfo[$i][2] & ", unit to remove: " & $aiSpellInfo[$i][1], $COLOR_ACTION)
							RemoveOnTItem($aiSpellInfo[$i][2] - 1, $aiSpellInfo[$i][1], 0, "Troops")
							$iUnitToRemove -= $aiSpellInfo[$i][1]
							$aiCurrentSpellsRonQ[TroopIndexLookup($aiSpellInfo[$i][0]) - $eLSpell] = $iUnitToRemove
						EndIf
					EndIf
				EndIf
			Next
			$g_bRestartCheckTroop = True
			$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
			Return False
		EndIf
		If $bGotOnQueueFlag And Not $bGotOnBrewFlag Then
			If $aiSpellInfo[0][1] > 0 Then
				If $iOnQueueCamp <> $iMyPreBrewSpellSize Then
					SetLog("Error: Pre-Brew Spells size not correct.", $COLOR_ERROR)
					SetLog("Error: Detected Pre-Brew Spells size = " & $iOnQueueCamp & ", My Spells size = " & $iMyPreBrewSpellSize, $COLOR_ERROR)
					If OpenSpellsTab() = False Then Return
					RemoveAllPreTrainTroops()
					$g_bRestartCheckTroop = True
					$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
					Return False
				EndIf
			EndIf
			If $g_bEnablePreTrainSpells = 0 Then
				SetLog("Pre-brew spell disable by user, remove all pre-brew spell.", $COLOR_WARNING)
				If OpenSpellsTab() = False Then Return
				RemoveAllPreTrainTroops()
			EndIf
		Else
			If $O21480 Then
				Local $aTempSpells[$eSpellCount][5]
				$aTempSpells = $MySpells
				_ArraySort($aTempSpells, 0, 0, 0, 1)
				For $i = 0 To UBound($aTempSpells) - 1
					If $aTempSpells[$i][3] > 0 Then
						$aTempSpells[0][0] = $aTempSpells[$i][0]
						$aTempSpells[0][3] = $aTempSpells[$i][3]
						ExitLoop
					EndIf
				Next
				_ArraySort($aiSpellInfo, 1, 0, 0, 2)
				For $i = 0 To UBound($aiSpellInfo) - 1
					If $aiSpellInfo[$i][3] = True Then
						If $aiSpellInfo[$i][0] <> $aTempSpells[0][0] Then
							SetLog("Pre-Brew Spell first slot: " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]), $COLOR_ERROR)
							SetLog("My first order spells: " & GetTroopName(TroopIndexLookup($aTempSpells[0][0]), $aTempSpells[0][3]), $COLOR_ERROR)
							SetLog("Remove and re-brew by order.", $COLOR_ERROR)
							RemoveAllPreTrainTroops()
							$g_bRestartCheckTroop = True
							$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
							Return False
						Else
							If $aiSpellInfo[$i][1] < $aTempSpells[0][3] Then
								SetLog("Pre-Brew Spell first slot: " & GetTroopName(TroopIndexLookup($aiSpellInfo[$i][0]), $aiSpellInfo[$i][1]) & " - Units: " & $aiSpellInfo[$i][1], $COLOR_ERROR)
								SetLog("My first order spells: " & GetTroopName(TroopIndexLookup($aTempSpells[0][0]), $aTempSpells[0][3]) & " - Units: " & $aTempSpells[0][3], $COLOR_ERROR)
								SetLog("Not enough quantity, remove and re-brew again.", $COLOR_ERROR)
								RemoveAllPreTrainTroops()
								$g_bRestartCheckTroop = True
								$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
								Return False
							EndIf
						EndIf
						ExitLoop
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	For $i = $DB To $LB
		If $g_abAttackTypeEnable[$i] Then
			If $g_abSearchSpellsWaitEnable[$i] Then
				For $s = 0 To UBound($MySpells) - 1
					If $g_aiCurrentSpells[$s] < $MySpells[$s][3] Then
						SetLog($g_asModeText[$i] & " - Waiting " & GetTroopName(TroopIndexLookup($MySpells[$s][0]), $MySpells[$s][3] - $g_aiCurrentSpells[$s]) & " to brew finish before start next attack.", $COLOR_WARNING)
					EndIf
				Next
			EndIf
		EndIf
	Next
	If $g_bDebugSetlogTrain Then SetLog("$bFullArmySpells: " & $g_bFullArmySpells & ", $iTotalSpellSpace:$iMyTotalTrainSpaceSpell " & $iAvailableCamp & "|" & $g_iMySpellsSize, $COLOR_DEBUG)
	Return True
EndFunc   ;==>CheckOnBrewUnit
Func C28089($i)
	GdiDeleteHBitmap($g_hHBitmap_OB_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_OB_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_OB_SlotQty[$i])
EndFunc   ;==>C28089

Func _getArmyTroopCapacity($hHBitmap, $bShowLog = True, $bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = True)

	If $g_bDebugSetlogTrain Then SetLog("_getArmyTroopCapacity():", $COLOR_DEBUG1)
	If $bCheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			ClickP($aAway, 1, 0, "#0000")
			If _Sleep($DELAYCHECKARMYCAMP4) Then Return
			If Not OpenArmyOverview(True, "_getArmyTroopCapacity()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	Local $aGetArmySize[3] = ["", "", ""]
	Local $sArmyInfo = ""
	Local $tmpTotalCamp = 0, $tmpCurCamp = 0
	Local $sInputbox
	$tmpCurCamp = 0
	$tmpTotalCamp = 0
	$sArmyInfo = getTSOcrArmyCap($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("_getArmyTroopCapacity $sArmyInfo = " & $sArmyInfo, $COLOR_DEBUG)
	$aGetArmySize = StringSplit($sArmyInfo, "#")
	If IsArray($aGetArmySize) And $aGetArmySize[0] > 1 Then
		If Number($aGetArmySize[2]) < 20 Or Mod(Number($aGetArmySize[2]), 5) <> 0 Then
			If $g_bDebugSetlogTrain Then SetLog(" OCR value is not valid camp size", $COLOR_RED)
		Else
			$tmpCurCamp = Number($aGetArmySize[1])
			$tmpTotalCamp = Number($aGetArmySize[2])
		EndIf
	EndIf
	$g_CurrentCampUtilization = $tmpCurCamp
	$g_iTotalCampSpace = $tmpTotalCamp
	If $g_iTotalCampSpace = 0 Or ($g_iTotalCampSpace <> Number($aGetArmySize[2])) Then
		If Not $g_bTotalCampForced Then
			Local $proposedTotalCamp = Number($aGetArmySize[2])
			If $g_iTotalCampSpace > Number($aGetArmySize[2]) Then $proposedTotalCamp = $g_iTotalCampSpace
			$sInputbox = InputBox("Question", "Enter your total Army Camp capacity." & @CRLF & @CRLF & "Please check it matches with total Army Camp capacity" & @CRLF & "you see in Army Overview right now in Android Window:" & @CRLF & $g_sAndroidTitle & @CRLF & @CRLF & "(This window closes in 2 Minutes with value of " & $proposedTotalCamp & ")", $proposedTotalCamp, "", 330, 220, Default, Default, 120, $g_hFrmBot)
			Local $error = @error
			If $error = 1 Then
				SetLog("Army Camp User input cancelled, still using " & $g_iTotalCampSpace, $COLOR_ACTION)
			Else
				If $error = 2 Then
					$g_iTotalCampSpace = $proposedTotalCamp
				Else
					$g_iTotalCampSpace = Number($sInputbox)
				EndIf
				If $error = 0 Then
					$g_iTotalCampForcedValue = $g_iTotalCampSpace
					$g_bTotalCampForced = True
					SetLog("Army Camp User input = " & $g_iTotalCampSpace, $COLOR_INFO)
				Else
					SetLog("Army Camp proposed value = " & $g_iTotalCampSpace, $COLOR_ACTION)
				EndIf
			EndIf
		Else
			$g_iTotalCampSpace = Number($g_iTotalCampForcedValue)
		EndIf
	EndIf
	If $g_bTotalCampForced Then $g_iTotalCampSpace = Number($g_iTotalCampForcedValue)
	If IsArray($aGetArmySize) And $aGetArmySize[0] > 1 Then
		If Number($aGetArmySize[2]) > $g_iTotalCampSpace And $g_bTotalCampForced Then
			SetLog("Your Camp settings are wrong![SET:" & $g_iTotalCampSpace & "|CURRENT:" & Number($aGetArmySize[2]) & "]", $COLOR_RED)
			If $g_bEnablePreTrainTroops Then
				SetLog("Turned Off the Double Train!")
				$g_bEnablePreTrainTroops = False
				; GUICtrlSetState($g_hChkEnablePretrainTroops, $GUI_UNCHECKED)
			EndIf
			If Not $g_bChkEnableDeleteExcessTroops Then
				$g_bChkEnableDeleteExcessTroops = True
				; GUICtrlSetState($g_hChkEnableDeleteExcessTroops, $GUI_CHECKED)
				SetLog("Turned On the Precise Train!")
			EndIf
		EndIf
	EndIf
	If $g_iMyTroopsSize <> $g_iTotalCampSpace And $g_iMyTroopsSize <> 0 Then
		SetLog("Your Army settings are wrong! [CAMP:" & $g_iTotalCampSpace & "|GUI:" & $g_iMyTroopsSize & "]", $COLOR_RED)
		If $g_bEnablePreTrainTroops Then
			SetLog("Turned Off the Double Train!")
			$g_bEnablePreTrainTroops = False
			; GUICtrlSetState($g_hChkEnablePretrainTroops, $GUI_UNCHECKED)
		EndIf
		If Not $g_bChkEnableDeleteExcessTroops Then
			$g_bChkEnableDeleteExcessTroops = True
			; GUICtrlSetState($g_hChkEnableDeleteExcessTroops, $GUI_CHECKED)
			SetLog("Turned On the Precise Train!")
		EndIf
		$g_iTotalCampSpace = $g_iMyTroopsSize
	EndIf
	If $g_iTotalCampSpace > 0 Then
		If $bShowLog Then SetLog("Troops: " & $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace & " (" & Int($g_CurrentCampUtilization / $g_iTotalCampSpace * 100) & "%)")
		$g_iArmyCapacity = Int($g_CurrentCampUtilization / $g_iTotalCampSpace * 100)
	Else
		If $bShowLog Then SetLog("Troops: " & $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace)
		$g_iArmyCapacity = 0
	EndIf
	If $g_CurrentCampUtilization >= Int(($g_iMyTroopsSize * $g_iTrainArmyFullTroopPct) / 100) Then
		$g_bFullArmy = True
	Else
		$g_bFullArmy = False
	EndIf
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>_getArmyTroopCapacity

Func getTroopCapacityMini($hHBitmap, $bShowLog = True)
	If $g_bDebugSetlogTrain Then SetLog("getTroopCapacityMini():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	Local $aTempSize
	Local $sArmyInfo = ""
	$g_aiTroopsMaxCamp[0] = 0
	$g_aiTroopsMaxCamp[1] = 0
	$sArmyInfo = getTSOcrTrainArmyOrBrewSpellCap($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("getTroopCapacityMini $sArmyInfo = " & $sArmyInfo, $COLOR_DEBUG)
	$aTempSize = StringSplit($sArmyInfo, "#", $STR_NOCOUNT)
	If IsArray($aTempSize) Then
		If UBound($aTempSize) = 2 Then
			If Number($aTempSize[1]) < 20 Or Mod(Number($aTempSize[1]), 5) <> 0 Then
				If $g_bDebugSetlogTrain Then SetLog(" OCR value is not valid camp size", $COLOR_RED)
			Else
				$g_aiTroopsMaxCamp[0] = Number($aTempSize[0])
				$g_aiTroopsMaxCamp[1] = Number($aTempSize[1])
			EndIf
		EndIf
	EndIf
	If $g_aiTroopsMaxCamp[1] <> 0 Then
		If $bShowLog Then SetLog("Max Troops: " & $g_aiTroopsMaxCamp[0] & "/" & $g_aiTroopsMaxCamp[1])
	EndIf
EndFunc   ;==>getTroopCapacityMini
Func getArmyOnSiegeMachines($hHBitmap)
	If Not $g_bRunState Then Return
	Local $aiCurrentSiegeMachinesRonT[$eSiegeMachineCount] = [0, 0, 0, 0]
	Local $aiCurrentSiegeMachinesRonQ[$eSiegeMachineCount] = [0, 0, 0, 0]
	If $hHBitmap = 0 Then
		SetLog("Error: $hHBitmap = 0", $COLOR_ERROR)
		Return False
	EndIf
	For $i = 0 To UBound($MySieges) - 1
		$g_aiCurrentSiegeMachinesOnT[$i] = 0
		$g_aiCurrentSiegeMachinesOnQ[$i] = 0
		$g_aiCurrentSiegeMachinesReady[$i] = 0
		$aiCurrentSiegeMachinesRonT[$i] = 0
		$aiCurrentSiegeMachinesRonT[$i] = 0
	Next
	If Int($g_iTownHallLevel) < 12 Then Return
	If $g_bDebugSetlogTrain Then SetLog("============Start getArmyOnSiegeMachines ============")
	SetLog("Check Training Siege Machines", $COLOR_INFO)
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiSiegeInfo[11][4]
	Local $iAvailableCamp = 0
	Local $iOnQueueCamp = 0
	Local $iMySiegesCampSize = 0
	Local $sDirectory
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iSiegeIndex = -1
	Local $bDeletedExcess = False
	Local $bGotOnTrainFlag = False
	Local $bGotOnQueueFlag = False
	Local $iCount = 0
	For $i = 10 To 0 Step -1
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 152 + 44, False), Hex(0XCFCFC8, 6), 10) And _ColorCheck(_GetPixelColor(Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XCFCFC8, 6), 10) Then
			$aiSiegeInfo[$i][0] = ""
			$aiSiegeInfo[$i][1] = 0
			$aiSiegeInfo[$i][2] = $i + 1
			$aiSiegeInfo[$i][3] = False
			$iCount += 1
		Else
			Local $bIsQueueMachine = False
			If _ColorCheck(_GetPixelColor(Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + ($g_iArmy_OnT_Troop_Slot_Width / 2)), 142 + 44, False), Hex(0XD7AFA9, 6), 10) Then
				$sDirectory = $g_sImgArmyOnQueueSieges
				$bIsQueueMachine = True
			Else
				$sDirectory = $g_sImgArmyOnTrainSieges
			EndIf
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyOnSiegeSlot[3] - $g_aiArmyOnSiegeSlot[1])) / 2
			$g_hHBitmap_OS_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyOnSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyOnSiegeSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_OS_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyOnSiegeSlot[1], Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyOnSiegeSlot[3])
			Local $result = findMultiImage($g_hHBitmap_OS_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			Local $sObjectname = ""
			Local $iQty = 0
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$sObjectname = $aPropsValues[0]
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect machines on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Machine: " & $sObjectname, $COLOR_ERROR)
						SetLog("Machine: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Machine: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
			ElseIf $g_bDebugSetlogTrain Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyOnSiegeSlot[3] - $g_aiArmyOnSiegeSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyOnSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyOnSiegeSlot[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + (($g_iArmy_OnT_Troop_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyOnSiegeSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, ($bIsQueueMachine = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1, "SiegesWindows\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_OS_Slot[$i], ($bIsQueueMachine = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1 & "_Unknown_RenameThis_92", "SiegesWindows\Replace", True)
				SetLog("Error: Cannot detect what troops on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: " & ($bIsQueueMachine = True ? "Troop_Queue_Slot_" : "Troop_Train_Slot_") & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				GdiDeleteHBitmap($temphHBitmap)
				K27369($i)
				ContinueLoop
			Else
				SetLog("Enable Debug Mode.", $COLOR_DEBUG)
				K27369($i)
				ContinueLoop
			EndIf

			$g_hHBitmap_OS_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyOnSiegeSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i)), $g_aiArmyOnSiegeSlotQty[1], Int($g_aiArmyOnSiegeSlotQty[0] + ($g_iArmy_OnT_Troop_Slot_Width * $i) + $g_iArmy_OnTrainQtyWidthForScan), $g_aiArmyOnSiegeSlotQty[3])
			$iQty = $bIsQueueMachine ? getTSOcrFullComboOnQuantity($g_hHBitmap_OS_SlotQty[$i], True) : getTSOcrFullComboOnQuantity($g_hHBitmap_OS_SlotQty[$i])

			; If $bIsQueueMachine Then
				; $iQty = getMyOcr($g_hHBitmap_OS_SlotQty[$i],0,0,0,0,"spellqtypre", True)
				; SaveDebugImage("spellqtypre", $g_hHBitmap_OS_SlotQty[$i])
			; Else
				; $iQty = getMyOcr($g_hHBitmap_OS_SlotQty[$i],0,0,0,0,"spellqtybrew", True)
				; SaveDebugImage("spellqtybrew", $g_hHBitmap_OS_SlotQty[$i])
			; EndIf

			If $iQty <> 0 And $sObjectname <> "" Then
				$aiSiegeInfo[$i][0] = $sObjectname
				$aiSiegeInfo[$i][1] = $iQty
				$aiSiegeInfo[$i][2] = $i + 1
				$aiSiegeInfo[$i][3] = $bIsQueueMachine
				$iSiegeIndex = TroopIndexLookup($aiSiegeInfo[$i][0]) - $eWallW
				If $bIsQueueMachine Then
					$g_aiCurrentSiegeMachinesOnQ[$iSiegeIndex] = $g_aiCurrentSiegeMachinesOnQ[$iSiegeIndex] + $iQty
					Local $hHbitmap_ready = GetHHBitmapArea($hHBitmap, Int(122 + ($g_iArmy_OnT_Troop_Slot_Width * $i)), 197 + 44, Int(122 + ($g_iArmy_OnT_Troop_Slot_Width * $i) + 12), 202)
					_debugSaveHBitmapToImage($hHbitmap_ready, "hHbitmap_ready" & $i + 1, "SiegesWindows\Ready", True)
					$sDirectory = $g_sImgArmyReady
					$result = findMultiImage($hHbitmap_ready, $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
					GdiDeleteHBitmap($hHbitmap_ready)
					If IsArray($result) Then
						$g_aiCurrentSiegeMachinesReady[$iSiegeIndex] = $g_aiCurrentSiegeMachinesReady[$iSiegeIndex] + $iQty
					EndIf
				Else
					$g_aiCurrentSiegeMachinesOnT[$iSiegeIndex] = $g_aiCurrentSiegeMachinesOnT[$iSiegeIndex] + $iQty
				EndIf
			Else
				SetLog("Error detect quantity no. On Machine: " & GetTroopName(TroopIndexLookup($sObjectname), $iQty), $COLOR_ERROR)
				ExitLoop
			EndIf
		EndIf
		K27369($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $iCount = 11 Then
		SetLog("No Machine On Train.", $COLOR_WARNING)
		Return True
	EndIf
	For $i = 0 To UBound($MySieges) - 1
		Local $iTempTotal = $g_aiCurrentSiegeMachines[$i] + $g_aiCurrentSiegeMachinesOnT[$i]
		If $g_aiCurrentSiegeMachinesOnT[$i] > 0 Then
			SetLog(" - No. of On Train " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentSiegeMachinesOnT[$i]) & ": " & $g_aiCurrentSiegeMachinesOnT[$i], $COLOR_ACTION)
			$bGotOnTrainFlag = True
		EndIf
		If $MySieges[$i][3] < $iTempTotal Then
			If $g_bChkEnableDeleteExcessSieges Then
				SetLog("Error: " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentSiegeMachinesOnT[$i]) & " need " & $MySieges[$i][3] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
				$aiCurrentSiegeMachinesRonT[$i] = $iTempTotal - $MySieges[$i][3]
				$bDeletedExcess = True
			EndIf
		EndIf
		If $iTempTotal > 0 Then
			$iAvailableCamp += $iTempTotal * $MySieges[$i][2]
		EndIf
		If $MySieges[$i][3] > 0 Then
			$iMySiegesCampSize += $MySieges[$i][3] * $MySieges[$i][2]
		EndIf
	Next
	If $bDeletedExcess Then
		$bDeletedExcess = False
		SetLog(" >>> Some machines over train, stop and remove excess machines.", $COLOR_WARNING)
		If OpenSiegeMachinesTab() = False Then Return
		RemoveAllPreTrainTroops()
		_ArraySort($aiSiegeInfo, 0, 0, 0, 2)
		For $i = 0 To 10
			$iSiegeIndex = TroopIndexLookup($aiSiegeInfo[$i][0]) - $eWallW
			If $aiSiegeInfo[$i][1] <> 0 And $aiSiegeInfo[$i][3] = False Then
				Local $iUnitToRemove = $aiCurrentSiegeMachinesRonT[$iSiegeIndex]
				If $iUnitToRemove > 0 Then
					If $aiSiegeInfo[$i][1] > $iUnitToRemove Then
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]) & " at slot: " & $aiSiegeInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
						RemoveOnTItem($aiSiegeInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
						$iUnitToRemove = 0
						$aiCurrentSiegeMachinesRonT[$iSiegeIndex] = $iUnitToRemove
					Else
						SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]) & " at slot: " & $aiSiegeInfo[$i][2] & ", unit to remove: " & $aiSiegeInfo[$i][1], $COLOR_ACTION)
						RemoveOnTItem($aiSiegeInfo[$i][2] - 1, $aiSiegeInfo[$i][1], 0, "Troops")
						$iUnitToRemove -= $aiSiegeInfo[$i][1]
						$aiCurrentSiegeMachinesRonT[$iSiegeIndex] = $iUnitToRemove
					EndIf
				EndIf
			EndIf
		Next
		$g_bRestartCheckTroop = True
		Return False
	Else
		Local $iTempSiegeQty = 0
		$bDeletedExcess = False
		$bGotOnQueueFlag = False
		If T27375() Then
			$iTempSiegeQty = 3
		Else
			$iTempSiegeQty = 6
		EndIf
		For $i = 0 To UBound($MySieges) - 1
			Local $iTempTotal = $g_aiCurrentSiegeMachinesOnQ[$i]
			If $iTempTotal > 0 Then
				SetLog(" - No. of On Queue " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentSiegeMachinesOnQ[$i]) & ": " & $g_aiCurrentSiegeMachinesOnQ[$i] & " | Ready " & $g_aiCurrentSiegeMachinesReady[$i], $COLOR_ACTION1)
				$bGotOnQueueFlag = True
				If ($MySieges[$i][5] = 1) Or $g_bEnablePreTrainSieges Then
					If $MySieges[$i][$iTempSiegeQty] < $iTempTotal Then
						If $g_bChkEnableDeleteExcessSieges Then
							SetLog("Error: " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentSiegeMachinesOnQ[$i]) & " need " & $MySieges[$i][$iTempSiegeQty] & " only, and i made " & $iTempTotal, $COLOR_ERROR)
							$aiCurrentSiegeMachinesRonQ[$i] = $iTempTotal - $MySieges[$i][$iTempSiegeQty]
							$bDeletedExcess = True
						EndIf
					EndIf
					$iOnQueueCamp += $iTempTotal * $MySieges[$i][2]
				Else
					SetLog("Error: " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentSiegeMachinesOnQ[$i]) & " not needed to Pre Train, remove all.", $COLOR_ERROR)
					$aiCurrentSiegeMachinesRonQ[$i] = $iTempTotal
					$bDeletedExcess = True
				EndIf
			EndIf
		Next
		If $bGotOnQueueFlag And Not $bGotOnTrainFlag Then
			If $g_bChkEnableDeleteExcessSieges Then
				If $iAvailableCamp < $iMySiegesCampSize Or (Not $g_bEnablePreTrainSieges And Not $V21546) Then
					If Not $g_bEnablePreTrainSieges And Not $V21546 Then
						SetLog("Pre-Train machines disable by user, remove all pre-train machines.", $COLOR_WARNING)
					Else
						SetLog("Error: Machines size not correct but pretrain already.", $COLOR_ERROR)
						SetLog("Error: Detected Machines size = " & $iAvailableCamp & ", My Machines size = " & $iMySiegesCampSize, $COLOR_ERROR)
					EndIf
					If OpenSiegeMachinesTab() = False Then Return
					RemoveAllPreTrainTroops()
					$g_bRestartCheckTroop = True
					Return False
				EndIf
			EndIf
		EndIf
		If $bDeletedExcess Then
			$bDeletedExcess = False
			SetLog(" >>> Some machines over train, stop and remove excess pre-train machines.", $COLOR_WARNING)
			If OpenSiegeMachinesTab() = False Then Return
			_ArraySort($aiSiegeInfo, 0, 0, 0, 2)
			For $i = 0 To 10
				$iSiegeIndex = TroopIndexLookup($aiSiegeInfo[$i][0]) - $eWallW
				If $aiSiegeInfo[$i][1] <> 0 And $aiSiegeInfo[$i][3] = True Then
					Local $iUnitToRemove = $aiCurrentSiegeMachinesRonQ[$iSiegeIndex]
					If $iUnitToRemove > 0 Then
						If $aiSiegeInfo[$i][1] > $iUnitToRemove Then
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]) & " at slot: " & $aiSiegeInfo[$i][2] & ", unit to remove: " & $iUnitToRemove, $COLOR_ACTION)
							RemoveOnTItem($aiSiegeInfo[$i][2] - 1, $iUnitToRemove, 0, "Troops")
							$iUnitToRemove = 0
							$aiCurrentSiegeMachinesRonQ[$iSiegeIndex] = $iUnitToRemove
						Else
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]) & " at slot: " & $aiSiegeInfo[$i][2] & ", unit to remove: " & $aiSiegeInfo[$i][1], $COLOR_ACTION)
							RemoveOnTItem($aiSiegeInfo[$i][2] - 1, $aiSiegeInfo[$i][1], 0, "Troops")
							$iUnitToRemove -= $aiSiegeInfo[$i][1]
							$aiCurrentSiegeMachinesRonQ[$iSiegeIndex] = $iUnitToRemove
						EndIf
					EndIf
				EndIf
				If _Sleep(Random((250 * 90) / 100, (250 * 110) / 100, 1), False) Then Return False
			Next
			$g_bRestartCheckTroop = True
			Return False
		EndIf
		If $bGotOnQueueFlag And Not $bGotOnTrainFlag Then
			If $aiSiegeInfo[0][1] > 0 Then
				If $g_bChkEnableDeleteExcessSieges Then
					If $iOnQueueCamp <> $iMySiegesCampSize Then
						SetLog("Error: Pre-Train Machines size not correct.", $COLOR_ERROR)
						SetLog("Error: Detected Pre-Train Machines size = " & $iOnQueueCamp & ", My Machines size = " & $iMySiegesCampSize, $COLOR_ERROR)
						If OpenSiegeMachinesTab() = False Then Return
						RemoveAllPreTrainTroops()
						$g_bRestartCheckTroop = True
						Return False
					EndIf
				EndIf
			EndIf
			If Not $g_bEnablePreTrainSieges And Not $V21546 Then
				SetLog("Pre-Train Siege Machines disable by user, remove all pre-train machines.", $COLOR_WARNING)
				If OpenSiegeMachinesTab() = False Then Return
				RemoveAllPreTrainTroops()
			EndIf
		Else
			If $D21534 Then
				Local $aTempSieges[$eSiegeMachineCount][5]
				$aTempSieges = $MySieges
				_ArraySort($aTempSieges, 0, 0, 0, 1)
				For $i = 0 To UBound($aTempSieges) - 1
					If $aTempSieges[$i][3] > 0 Then
						$aTempSieges[0][0] = $aTempSieges[$i][0]
						$aTempSieges[0][3] = $aTempSieges[$i][3]
						ExitLoop
					EndIf
				Next
				_ArraySort($aiSiegeInfo, 1, 0, 0, 2)
				For $i = 0 To UBound($aiSiegeInfo) - 1
					If $aiSiegeInfo[$i][3] = True And T27375() Then
						If $aiSiegeInfo[$i][0] <> $aTempSieges[0][0] Then
							SetLog("Pre-Train first slot: " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]), $COLOR_ERROR)
							SetLog("My first order machines: " & GetTroopName(TroopIndexLookup($aTempSieges[0][0]), $aTempSieges[0][3]), $COLOR_ERROR)
							SetLog("Remove and re training by order.", $COLOR_ERROR)
							RemoveAllPreTrainTroops()
							$g_bRestartCheckTroop = True
							Return False
						Else
							If $aiSiegeInfo[$i][1] < $aTempSieges[0][3] Then
								SetLog("Pre-Train first slot: " & GetTroopName(TroopIndexLookup($aiSiegeInfo[$i][0]), $aiSiegeInfo[$i][1]) & " - Units: " & $aiSiegeInfo[$i][1], $COLOR_ERROR)
								SetLog("My first order machines: " & GetTroopName(TroopIndexLookup($aTempSieges[0][0]), $aTempSieges[0][3]) & " - Units: " & $aTempSieges[0][3], $COLOR_ERROR)
								SetLog("Not enough quantity, remove and re-training again.", $COLOR_ERROR)
								RemoveAllPreTrainTroops()
								$g_bRestartCheckTroop = True
								Return False
							EndIf
						EndIf
						ExitLoop
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	For $i = $DB To $LB
		If $g_abAttackTypeEnable[$i] Then
			If $g_abSearchSiegeWaitEnable[$i] Then
				For $s = 0 To UBound($MySieges) - 1
					If $g_aiCurrentSiegeMachines[$s] < $MySieges[$s][3] Then
						SetLog($g_asModeText[$i] & " - Waiting " & GetTroopName(TroopIndexLookup($MySieges[$s][0]), $MySieges[$s][3] - $g_aiCurrentSiegeMachines[$s]) & " to finish before start next attack.", $COLOR_WARNING)
					EndIf
				Next
			EndIf
		EndIf
	Next
	If $g_bDebugSetlogTrain Then SetLog("$bFullArmySieges: " & $g_bFullArmySieges, $COLOR_DEBUG)
	Return True
EndFunc   ;==>getArmyOnSiegeMachines
Func K27369($i)
	GdiDeleteHBitmap($g_hHBitmap_OS_SlotQty[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_OS_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_OS_Slot[$i])
EndFunc   ;==>K27369
Func T27375()
	If $MySieges[$eSiegeWallWrecker][5] = 1 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
		Return False
	ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 1 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
		Return False
	ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 1 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
		Return False
	ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 1 And $MySieges[$eSiegeLogLauncher][5] = 0 Then
		Return False
	ElseIf $MySieges[$eSiegeWallWrecker][5] = 0 And $MySieges[$eSiegeBattleBlimp][5] = 0 And $MySieges[$eSiegeStoneSlammer][5] = 0 And $MySieges[$eSiegeBarracks][5] = 0 And $MySieges[$eSiegeLogLauncher][5] = 1 Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>T27375
Func _debugSaveHBitmapToImage($hHBitmap, $sFileName, $TxtNameSubFolder = "", $bForceSave = False, $bDateTime = False, $makesubfolder = True)
	If $g_bDebugSetlogTrain And $g_bDebugImageSave Then
		Local $savefolder = $g_sProfileTempDebugPath & "TrainSystem\"
		If $makesubfolder = True And $TxtNameSubFolder <> "" Then
			$savefolder = $g_sProfileTempDebugPath & "TrainSystem\" & $TxtNameSubFolder & "\"
			DirCreate($savefolder)
		EndIf
		If $hHBitmap <> 0 Then
			Local $EditedImage = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
			If $bDateTime Then
				Local $date = @MDAY & "." & @MON & "." & @YEAR
				Local $Time = @HOUR & "." & @MIN & "." & @SEC & "." & @MSEC
				$sFileName = $sFileName & "-" & $date & "-" & $Time
			EndIf
			_GDIPlus_ImageSaveToFile($EditedImage, $savefolder & "" & $sFileName & ".png")
			_GDIPlus_BitmapDispose($EditedImage)
		Else
			SetLog("_debugSaveHBitmapToImage Error at BitMap!")
		EndIf
	EndIf
EndFunc   ;==>_debugSaveHBitmapToImage
Func _getArmyCCTroops()
	If $g_bDebugSetlogTrain Then SetLog("_getArmyCCTroops():", $COLOR_DEBUG)
	If Int($g_iTownHallLevel) < 3 Then Return
	SetLog("Check Clan Castle Troops", $COLOR_INFO)
	Local $iCount = 0
	Local $aiCurrentCCTroopsRemove[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	While 1
		$iCount += 1
		If $iCount > 3 Then ExitLoop
		Local $aiTroopsInfo[5][3]
		Local $sDirectory = $g_sImgArmyOverviewCCTroops
		Local $returnProps = "objectname"
		Local $aPropsValues
		Local $bDeletedExcess = False
		Local $iTroopsCount = 0
		Local $iTroopIndex = -1
		If _Sleep(250) Then ExitLoop
		If $g_bRunState = False Then ExitLoop
		GdiDeleteHBitmap($g_hHBitmap2)
		_CaptureRegion2()
		For $i = 0 To UBound($MyTroops) - 1
			$g_aiCurrentCCTroops[$i] = 0
			$aiCurrentCCTroopsRemove[$i] = 0
		Next
		For $i = 0 To 4
			P26535($i)
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableCCSlot[3] - $g_aiArmyAvailableCCSlot[1])) / 2
			$g_hHBitmap_Av_CC_Slot[$i] = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableCCSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableCCSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_CC_Slot[$i] = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableCCSlot[1], Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableCCSlot[3])
			Local $result = findMultiImage($g_hHBitmap_Av_CC_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			Local $bExitLoopFlag = False
			Local $bContinueNextLoop = False
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							If $aPropsValues[0] <> "0" Then
								$aiTroopsInfo[$i][0] = $aPropsValues[0]
								$aiTroopsInfo[$i][2] = $i + 1
								$iTroopsCount += 1
							EndIf
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect troops on Slot: " & $i + 1, $COLOR_INFO)
						SetLog("Troop: " & $aiTroopsInfo[$i][0], $COLOR_INFO)
						SetLog("Troop: " & $aPropsValues[0], $COLOR_INFO)
					Else
						$aPropsValues = $result[$j]
						SetLog("Troop: " & $aPropsValues[0], $COLOR_INFO)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then $bExitLoopFlag = True
			ElseIf $g_bDebugSetlogTrain Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableCCSlot[3] - $g_aiArmyAvailableCCSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableCCSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableCCSlot[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableCCSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Troop_Av_CC_Slot_" & $i + 1, "ArmyWindows\CCTroops\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CC_Slot[$i], "Troop_CC_Slot_" & $i + 1 & "_Unknown_RenameThis_92", "ArmyWindows\CCTroops\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what cc troops on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: Troop_CC_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				$bContinueNextLoop = True
			Else
				SetLog("Enable Debug Mode.", $COLOR_DEBUG)
				$bContinueNextLoop = True
			EndIf
			If $bExitLoopFlag = True Then ExitLoop
			If $bContinueNextLoop Then
				ContinueLoop
			EndIf
			$g_hArmyTab_CCTroop_NoUnit_Slot[$i] = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSlotQty[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_QtyWidthForScan) / 2)), $g_aiArmyAvailableCCSlotQty[1], Int($g_aiArmyAvailableCCSlotQty[0] + ($g_iArmy_Av_CC_Slot_Width * $i) + (($g_iArmy_Av_CC_Slot_Width - $g_iArmy_QtyWidthForScan) / 2) + $g_iArmy_QtyWidthForScan), $g_aiArmyAvailableCCSlotQty[3])
			$aiTroopsInfo[$i][1] = getTSOcrFullComboQuantity($g_hArmyTab_CCTroop_NoUnit_Slot[$i])
			If $aiTroopsInfo[$i][1] <> 0 Then
				$iTroopIndex = TroopIndexLookup($aiTroopsInfo[$i][0])
				$g_aiCurrentCCTroops[$iTroopIndex] = $g_aiCurrentCCTroops[$iTroopIndex] + $aiTroopsInfo[$i][1]
			Else
				SetLog("Error detect Quantity no. On CC Troop: " & GetTroopName(TroopIndexLookup($aiTroopsInfo[$i][0]), $aiTroopsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			If $g_bDebugImageSave Then
				_debugSaveHBitmapToImage($g_hHBitmap_Av_CC_Slot[$i], "ArmyTab_CCTroop_Slot" & $i, "ArmyWindows\CCTroops")
				_debugSaveHBitmapToImage($g_hArmyTab_CCTroop_NoUnit_Slot[$i], "ArmyTab_CCTroop_NoUnit_Slot" & $i, "ArmyWindows\CCTroops")
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CC_Slot[$i], "RenameIt2ImgLocFormat_ArmyTab_CCTroop_Slot" & $i, "ArmyWindows\CCTroops")
			EndIf
			P26535($i)
		Next
		GdiDeleteHBitmap($g_hHBitmap2)
		If $iTroopsCount = 0 Then
			SetLog("No Army in Clan Castle.", $COLOR_WARNING)
			ExitLoop
		EndIf
		For $i = 0 To UBound($MyTroops) - 1
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			Local $iTempTotal = $g_aiCurrentCCTroops[$i]
			If $iTempTotal > 0 Then
				SetLog(" - Clan Castle Troops - " & GetTroopName(TroopIndexLookup($MyTroops[$i][0]), $g_aiCurrentCCTroops[$i]) & ": " & $g_aiCurrentCCTroops[$i], $COLOR_SUCCESS)
				Local $bIsTroopInKeepList = False
				If $O21846[0] Or $O21846[1] Or $O21846[2] Then
					For $j = 1 To 3
						If TroopIndexLookup($MyTroops[$i][0]) + 1 = $O21846[$j - 1] Then
							$bIsTroopInKeepList = True
							If $iTempTotal > $U21849[$j - 1] Then
								$aiCurrentCCTroopsRemove[$i] = $iTempTotal - $U21849[$j - 1]
								$bDeletedExcess = True
							EndIf
							ExitLoop
						EndIf
					Next
					If $bIsTroopInKeepList = False Then
						$aiCurrentCCTroopsRemove[$i] = $iTempTotal
						$bDeletedExcess = True
					EndIf
				EndIf
			EndIf
		Next
		If $bDeletedExcess Then
			$bDeletedExcess = False
			SetLog(" >>> Remove UnWanted Clan Castle Troops.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 0 To 4
					If $aiTroopsInfo[$i][1] <> 0 Then
						Local $iUnitToRemove = $aiCurrentCCTroopsRemove[TroopIndexLookup($aiTroopsInfo[$i][0])]
						If $iUnitToRemove > 0 Then
							If $aiTroopsInfo[$i][1] > $iUnitToRemove Then
								SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopsInfo[$i][0]), $aiTroopsInfo[$i][1]) & " at slot: " & $aiTroopsInfo[$i][2] & ", amount to remove: " & $iUnitToRemove, $COLOR_ACTION)
								RemoveOnTItem($aiTroopsInfo[$i][2] - 1, $iUnitToRemove, 0, "CCtroops")
								$iUnitToRemove = 0
								$aiCurrentCCTroopsRemove[TroopIndexLookup($aiTroopsInfo[$i][0])] = $iUnitToRemove
							Else
								SetLog("Remove " & GetTroopName(TroopIndexLookup($aiTroopsInfo[$i][0]), $aiTroopsInfo[$i][1]) & " at slot: " & $aiTroopsInfo[$i][2] & ", amount to remove: " & $aiTroopsInfo[$i][1], $COLOR_ACTION)
								RemoveOnTItem($aiTroopsInfo[$i][2] - 1, $aiTroopsInfo[$i][1], 0, "CCtroops")
								$iUnitToRemove -= $aiTroopsInfo[$i][1]
								$aiCurrentCCTroopsRemove[TroopIndexLookup($aiTroopsInfo[$i][0])] = $iUnitToRemove
							EndIf
						EndIf
					EndIf
				Next
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				ExitLoop
			EndIf
			ClickOkay()
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				ContinueLoop
			Else
				If _Sleep(1000) Then ExitLoop
			EndIf
			ContinueLoop
		EndIf
		ExitLoop
	WEnd
EndFunc   ;==>_getArmyCCTroops
Func getArmyCCTroopCapacity()
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyCCTroopCapacity:", $COLOR_DEBUG1)
	$g_bFullCCTroops = False
	Local $aGetCCSize[3] = ["", "", ""]
	Local $sCCInfo = ""
	Local $iCount
	$iCount = 0
	While 1
		$sCCInfo = getTSOcrCCCap()
		If $g_bDebugSetlog Then SetLog("$sCCInfo = " & $sCCInfo, $COLOR_DEBUG)
		$aGetCCSize = StringSplit($sCCInfo, "#")
		If IsArray($aGetCCSize) Then
			If $aGetCCSize[0] > 1 Then
				If Number($aGetCCSize[2]) < 10 Or Mod(Number($aGetCCSize[2]), 5) <> 0 Then
					If $g_bDebugSetlog Then SetLog(" OCR value is not valid cc camp size", $COLOR_DEBUG)
					ContinueLoop
				EndIf
				$X21864 = Number($aGetCCSize[2])
				$N21861 = Number($aGetCCSize[1])
				$Q21867 = Int($N21861 / $X21864 * 100)
				SetLog("Total Clan Castle Troops: " & $N21861 & "/" & $X21864 & " (" & $Q21867 & "%)")
				ExitLoop
			Else
				$N21861 = 0
				$X21864 = 0
			EndIf
		Else
			$N21861 = 0
			$X21864 = 0
		EndIf
		$iCount += 1
		If $iCount > 30 Then ExitLoop
		If _Sleep(250) Then Return
	WEnd
	If $N21861 = 0 And $X21864 = 0 Then
		SetLog("CC Troop size read error...", $COLOR_ERROR)
		$g_bFullCCTroops = False
		Return
	EndIf
	If ($N21861 >= ($X21864 * $Y21870 / 100)) Then
		$g_bFullCCTroops = True
	EndIf
	If $g_bFullCCTroops = False Then
		If $g_bChkWait4CC Then
			SetLog("Waiting Clan Castle Troops.", $COLOR_ACTION)
		Else
			SetLog("Not Waiting for Clan Castle Troops.", $COLOR_ACTION)
			$g_bFullCCTroops = True
		EndIf
	EndIf
	If $V21819 Then
		$M21837 = $N21861 < ($X21864 * $E21828 / 100)
	EndIf
EndFunc   ;==>getArmyCCTroopCapacity
Func P26535($i)
	GdiDeleteHBitmap($g_hHBitmap_Av_CC_Slot[$i])
	GdiDeleteHBitmap($g_hArmyTab_CCTroop_NoUnit_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_Av_CC_Slot[$i])
EndFunc   ;==>P26535

Func DoRevampTroops($bDoPreTrain = False)
	If Not IsTrainSystemOK() Then Return
	Local $iIndexForDarkTroops = $eSWiza
	If _Sleep(500) Then Return
	Local $bReVampFlag = False
	Local $aTempTroops[$eTroopCount][5]
	Local $aiCurrentTroopsDif[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCurrentTroopsAdd[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	#cs
	If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
		For $i = 0 To UBound($MyTroops) - 1
			$MyTroops[$i][3] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][0]
			$MyTroops[$i][1] = $MyTroopsSetting[$g_iCmbTroopSetting][$i][1]
		Next
		If ($g_bEnablePreTrainTroops Or $g_bChkForcePreTrainTroops) Then $V21450 = True
	EndIf
	#ce
	$aTempTroops = $MyTroops
	If $g_bDebugSetlogTrain Then SetLog("$g_iTrainSystemErrors[" & $g_iCurAccount & "][Troops]: " & $g_iTrainSystemErrors[$g_iCurAccount][0])
	Static $aBtnCoordinates[8][$eTroopCount][2]
	If $V21450 Or $g_iTrainSystemErrors[$g_iCurAccount][0] > 5 Then
		For $i = 0 To $eTroopCount - 1
			$aBtnCoordinates[$g_iCurAccount][$i][0] = Null
			$aBtnCoordinates[$g_iCurAccount][$i][1] = Null
		Next
		$V21450 = False
		$g_iTrainSystemErrors[$g_iCurAccount][0] = 0
	EndIf
	If $g_bChkMyTroopsOrder Then
		_ArraySort($aTempTroops, 0, 0, 0, 1)
	EndIf
	For $i = 0 To UBound($aTempTroops) - 1
		If $g_bDebugSetlogTrain Then SetLog("$aTempTroops[" & $i & "]: " & $aTempTroops[$i][0] & " - " & $aTempTroops[$i][1])
		; AIO
		Local $iTroopIndexLookup = TroopIndexLookup($aTempTroops[$i][0])
		; Setlog(String($iTroopIndexLookup))
		; _ArrayDisplay($aTempTroops)
		$aiCurrentTroopsDif[$iTroopIndexLookup] = 0
		$aiCurrentTroopsAdd[$iTroopIndexLookup] = 0
	Next
	If $bDoPreTrain = False Then
		For $i = 0 To UBound($aTempTroops) - 1
			Local $tempCurComp = $aTempTroops[$i][3]
			Local $tempCur = $g_aiCurrentTroops[TroopIndexLookup($aTempTroops[$i][0])] + $g_aiCurrentTroopsOnT[TroopIndexLookup($aTempTroops[$i][0])]
			If $g_bDebugSetlogTrain Then SetLog("$tempMyTroops: " & $tempCurComp)
			If $g_bDebugSetlogTrain Then SetLog("$tempCur: " & $tempCur)
			If $tempCurComp <> $tempCur Then
				$aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])] = $tempCurComp - $tempCur
			EndIf
		Next
	Else
		If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
			For $i = 0 To UBound($MyTroops) - 1
				$MyTroops[$i][3] = $MyTroopsSetting[$g_iCmbNextTroopSetting[$g_iCurAccount]][$i][0]
				$MyTroops[$i][1] = $MyTroopsSetting[$g_iCmbNextTroopSetting[$g_iCurAccount]][$i][1]
			Next
			$aTempTroops = $MyTroops
			If $g_bChkMyTroopsOrder Then
				_ArraySort($aTempTroops, 0, 0, 0, 1)
			EndIf
		EndIf
		For $i = 0 To UBound($aTempTroops) - 1
			If $aTempTroops[$i][3] <> $g_aiCurrentTroopsOnQ[TroopIndexLookup($aTempTroops[$i][0])] Then
				$aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])] = $aTempTroops[$i][3] - $g_aiCurrentTroopsOnQ[TroopIndexLookup($aTempTroops[$i][0])]
			EndIf
		Next
	EndIf
	For $i = 0 To UBound($aTempTroops) - 1
		If $aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])] > 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some troops haven't train: " & $aTempTroops[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempTroops[$i][0] & " troops: " & $aTempTroops[$i][3])
			$aiCurrentTroopsAdd[TroopIndexLookup($aTempTroops[$i][0])] = $aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])]
			$bReVampFlag = True
		ElseIf $aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])] < 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some troops over train: " & $aTempTroops[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempTroops[$i][0] & " troops: " & $aTempTroops[$i][3])
			If $g_bDebugSetlogTrain Then SetLog("Current Qty Of " & $aTempTroops[$i][0] & " troops: " & $aTempTroops[$i][3] - $aiCurrentTroopsDif[TroopIndexLookup($aTempTroops[$i][0])])
		EndIf
	Next
	If $bReVampFlag Then
		If OpenTroopsTab() = False Then Return
		If _Sleep(100) Then Return
		Local $iRemainTroopsCapacity = 0
		Local $bFlagOutOfResource = False
		If $bDoPreTrain Then
			If Not IsArray($g_aiTroopsMaxCamp) Then getTroopCapacityMini(0)
			$iRemainTroopsCapacity = $g_aiTroopsMaxCamp[1] - $g_aiTroopsMaxCamp[0]
			If $iRemainTroopsCapacity <= 0 Then
				SetLog("Troops full with Pre-Train.", $COLOR_SUCCESS1)
				Return
			EndIf
		Else
			$iRemainTroopsCapacity = $g_iTotalCampSpace - $g_CurrentCampUtilization
			If $iRemainTroopsCapacity <= 0 Then
				SetLog("Troops Full.", $COLOR_SUCCESS1)
				Return
			EndIf
		EndIf
		For $i = 0 To UBound($aTempTroops) - 1
			Local $iOnQQty = $aiCurrentTroopsAdd[TroopIndexLookup($aTempTroops[$i][0])]
			If $iOnQQty > 0 Then
				SetLog("Prepare for train number Of" & " " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0]), $iOnQQty) & " x" & $iOnQQty, $COLOR_ACTION)
				If IsSuperTroop($aTempTroops[$i][0]) Then
					$aBtnCoordinates[$g_iCurAccount][$i][0] = Null
				EndIf
			EndIf
		Next
		Local $iCurElixir = $g_aiCurrentLoot[$eLootElixir]
		Local $iCurDarkElixir = $g_aiCurrentLoot[$eLootDarkElixir]
		Local $iCurGemAmount = $g_iGemAmount
		SetLog("Elixir: " & $iCurElixir & "   Dark Elixir: " & $iCurDarkElixir & "   Gem: " & $iCurGemAmount, $COLOR_INFO)
		For $i = 0 To UBound($aTempTroops) - 1
			$g_iTroopButtonX = 0
			$g_iTroopButtonY = 0
			Local $Troop4Add = $aiCurrentTroopsAdd[TroopIndexLookup($aTempTroops[$i][0])]
			If $Troop4Add > 0 And $iRemainTroopsCapacity > 0 Then
				If $aBtnCoordinates[$g_iCurAccount][$i][0] = Null Or $aBtnCoordinates[$g_iCurAccount][$i][0] = 0 Then
					If MyTrainClick($aTempTroops[$i][0]) Then
						$aBtnCoordinates[$g_iCurAccount][$i][0] = $g_iTroopButtonX
						$aBtnCoordinates[$g_iCurAccount][$i][1] = $g_iTroopButtonY
						If $g_bDebugSetlogTrain Then SetLog("First " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0])) & " Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
					Else
						SetLog("Locate Troop button failed for " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0])), $COLOR_ERROR)
						If IsSuperTroop($aTempTroops[$i][0]) Then
							$g_bForceCheckBoostedTroops = True
							SetLog("Train Exit, Forcing to Boost troops!!", $COLOR_WARNING)
							Return
						EndIf
						ExitLoop
					EndIf
				Else
					$g_iTroopButtonX = $aBtnCoordinates[$g_iCurAccount][$i][0]
					$g_iTroopButtonY = $aBtnCoordinates[$g_iCurAccount][$i][1]
					If $g_bDebugSetlogTrain Then SetLog(GetTroopName(TroopIndexLookup($aTempTroops[$i][0])) & " Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
					If Not DragIfNeeded($aTempTroops[$i][0]) Then ExitLoop
					If _Sleep(250) Then ExitLoop
				EndIf
				If $g_iTroopButtonX <> 0 And $g_iTroopButtonY <> 0 Then
					Local $fixRemain = 0
					Local $iCost
					If $aTempTroops[$i][4] = 0 Then
						$iCost = getTSOcrCostQuantity($g_iTroopButtonX - 55, $g_iTroopButtonY + 26)
						If $iCost = 0 Or $iCost = "" Then
							Local $iMaxTroopLevel = $g_aiTroopCostPerLevel[TroopIndexLookup($aTempTroops[$i][0])][0]
							$iCost = $g_aiTroopCostPerLevel[TroopIndexLookup($aTempTroops[$i][0])][$iMaxTroopLevel]
						EndIf
						$MyTroops[TroopIndexLookup($aTempTroops[$i][0])][4] = $iCost
					Else
						$iCost = $aTempTroops[$i][4]
					EndIf
					If $g_bDebugSetlogTrain Then SetLog("$iCost: " & $iCost)
					Local $iBuildCost = (TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops ? $iCurDarkElixir : $iCurElixir)
					If $g_bDebugSetlogTrain Then SetLog("$iBuildCost: " & $iBuildCost)
					If $g_bDebugSetlogTrain Then SetLog("Total need: " & ($Troop4Add * $iCost))
					If ($Troop4Add * $iCost) > $iBuildCost Then
						$bFlagOutOfResource = True
						SetLog("Not enough" & " " & (TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops ? "Dark Elixir" : "Elixir") & " " & "to train" & " " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0]), 0), $COLOR_WARNING)
						SetLog("Current " & (TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops ? "Dark" : "") & " Elixir: " & $iBuildCost, $COLOR_WARNING)
						SetLog("Total need: " & $Troop4Add * $iCost, $COLOR_WARNING)
					EndIf
					If $bFlagOutOfResource Then
						$g_bOutOfElixir = True
						SetLog("Switching to Halt Attack, Stay Online Mode...", $COLOR_WARNING)
						$g_bChkBotStop = True
						$g_iCmbBotCond = 18
						If Not ($g_bFullArmy = True) Then $g_bRestart = True
						Return
					EndIf
					SetLog("Ready to train" & " " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0]), $Troop4Add) & " x" & $Troop4Add & " " & "with total" & " " & (TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops ? "Dark Elixir" : "Elixir") & ": " & ($Troop4Add * $iCost), $COLOR_ACTION1)
					If ($aTempTroops[$i][2] * $Troop4Add) <= $iRemainTroopsCapacity Then
						If _TrainClick($g_iTroopButtonX, $g_iTroopButtonY, $Troop4Add, $g_iTrainClickDelay, "#TT01") Then
							If TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops Then
								$iCurDarkElixir -= ($Troop4Add * $iCost)
							Else
								$iCurElixir -= ($Troop4Add * $iCost)
							EndIf
							$iRemainTroopsCapacity -= ($aTempTroops[$i][2] * $Troop4Add)
						EndIf
					Else
						Local $iReduceCap = Int($iRemainTroopsCapacity / $aTempTroops[$i][2])
						SetLog("Troops above cannot fit to max capicity, reduce to train " & GetTroopName(TroopIndexLookup($aTempTroops[$i][0]), $iReduceCap) & " x" & $iReduceCap, $COLOR_WARNING)
						If _TrainClick($g_iTroopButtonX, $g_iTroopButtonY, $iReduceCap, $g_iTrainClickDelay, "#TT01") Then
							If TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops Then
								$iCurDarkElixir -= ($iReduceCap * $iCost)
							Else
								$iCurElixir -= ($iReduceCap * $iCost)
							EndIf
							$iRemainTroopsCapacity -= ($iRemainTroopsCapacity - ($iReduceCap * $aTempTroops[$i][2]))
						Else
							$fixRemain = $iRemainTroopsCapacity - ($iReduceCap * $aTempTroops[$i][2])
						EndIf
					EndIf
					If $fixRemain > 0 Then
						If $g_aiTroopsMaxCamp[0] > $g_iTotalCampSpace Then
							SetLog(" >>> Some troops over train, Stop and Remove excess troops.", $COLOR_WARNING)
							RemoveAllPreTrainTroops()
							If _Sleep(500) Then Return
						EndIf
						If MyTrainClick("Arch") Then
							If _TrainClick($g_iTroopButtonX, $g_iTroopButtonY, $fixRemain, $g_iTrainClickDelay, "#TT01") Then
								Local $iMaxArchLevel = $g_aiTroopCostPerLevel[$eTroopArcher][0]
								If TroopIndexLookup($aTempTroops[$i][0]) > $iIndexForDarkTroops Then
									$iCurDarkElixir -= ($fixRemain * $g_aiTroopCostPerLevel[$eTroopArcher][$iMaxArchLevel])
								Else
									$iCurElixir -= ($fixRemain * $g_aiTroopCostPerLevel[$eTroopArcher][$iMaxArchLevel])
								EndIf
								$iRemainTroopsCapacity -= $fixRemain
							EndIf
						Else
							SetLog("Locate Troop button failed for Arch", $COLOR_ERROR)
							ExitLoop
						EndIf
					EndIf
				Else
					SetLog("Cannot find button (2): " & GetTroopName(TroopIndexLookup($aTempTroops[$eTroopArcher][0])) & " for click", $COLOR_ERROR)
					$g_iTrainSystemErrors[$g_iCurAccount][0] += 1
				EndIf
				If _Sleep(500) Then Return
			EndIf
		Next
	EndIf
	If $bDoPreTrain Then
		$g_bDisableTrain = True
	EndIf
EndFunc   ;==>DoRevampTroops
Func IsSuperTroop($sName)
	Switch GetTroopName(TroopIndexLookup($sName))
		Case "Super Barbarian"
			Return True
		Case "Super Archer"
			Return True
		Case "Super Giant"
			Return True
		Case "Sneaky Goblin"
			Return True
		Case "Super Wall Breaker"
			Return True
		Case "Inferno Dragon"
			Return True
		Case "Super Witch"
			Return True
		Case "Super Minion"
			Return True
		Case "Super Valkyrie"
			Return True
		Case "Super Wizard"
			Return True
		Case "Ice Hound"
			Return True
		Case "Super Bowler"
			Return True
	EndSwitch
	Return False
EndFunc   ;==>IsSuperTroop

Func DoMyQuickTrain($MyTrainArmy)
	If _Sleep(200) Then Return
	If OpenQuickTrainTab() = True Then
		Local $aButtonTemp[9]
		Switch $MyTrainArmy
			Case 1
				$aButtonTemp = $aButtonTrainArmy1
			Case 2
				$aButtonTemp = $aButtonTrainArmy2
			Case 3
				$aButtonTemp = $aButtonTrainArmy3
		EndSwitch
		If _Sleep(200) Then Return
		ForceCaptureRegion()
		_CaptureRegion()
		If _ColorCheck(_GetPixelColor($aButtonTemp[4], $aButtonTemp[5], False), Hex($aButtonTemp[6], 6), $aButtonTemp[7]) Then
			Local $x, $y
			ClickPR($aButtonTemp, $x, $y)
			Click($x, $y)
			SetLog("Train army using quick train army " & $MyTrainArmy & " button.", $COLOR_SUCCESS)
			If $g_CurrentCampUtilization <> 0 Then
				$g_bDisableTrain = True
			EndIf
			If _Sleep(200) Then Return
		Else
			If _ColorCheck(_GetPixelColor(50, $aButtonTemp[5], False), Hex(0XD3D3CB, 6), 6) Then
				Return
			Else
				SetLog("Failed to locate Quick Train Army " & $MyTrainArmy & " button.", $COLOR_ERROR)
				SetLog("Try using custom Train for Train Troops.", $COLOR_INFO)
				If $g_CurrentCampUtilization <> 0 And $g_CurrentCampUtilization < $g_iTotalCampSpace Then
					DoRevampTroops()
				ElseIf $g_aiTroopsMaxCamp[0] > Int((($g_aiTroopsMaxCamp[1] / 2) * $g_iTrainArmyFullTroopPct) / 100) And $g_iTrainArmyFullTroopPct = 100 Then
					DoRevampTroops(True)
				EndIf
			EndIf
		EndIf
	Else
		SetLog("Cannot open Quick Train Tab page.", $COLOR_ERROR)
	EndIf
EndFunc   ;==>DoMyQuickTrain


#cs
Func IsDarkTroop($Troop)
	Local $iIndex = TroopIndexLookup($Troop, "IsDarkTroop")
	If $iIndex >= $eMini And $iIndex <= $eHunt Then Return True
	Return False
EndFunc   ;==>IsDarkTroop

Func DragIfNeeded($Troop)

	If Not $g_bRunState Then Return
	Local $bCheckPixel = False

	If IsDarkTroop($Troop) Then
		If _ColorCheck(_GetPixelColor(834, 403, True), Hex(0xD3D3CB, 6), 5) Then $bCheckPixel = True
		If $g_bDebugSetlogTrain Then SetLog("DragIfNeeded Dark Troops: " & $bCheckPixel)
		For $i = 1 To 3
			If Not $bCheckPixel Then
				ClickDrag(715, 445 + $g_iMidOffsetY, 220, 445 + $g_iMidOffsetY, 2000)
				If _Sleep(1500) Then Return
				If _ColorCheck(_GetPixelColor(834, 403, True), Hex(0xD3D3CB, 6), 5) Then $bCheckPixel = True
			Else
				Return True
			EndIf
		Next
	Else
		If _ColorCheck(_GetPixelColor(22, 403, True), Hex(0xD3D3CB, 6), 5) Then $bCheckPixel = True
		If $g_bDebugSetlogTrain Then SetLog("DragIfNeeded Normal Troops: " & $bCheckPixel)
		For $i = 1 To 3
			If Not $bCheckPixel Then
				ClickDrag(220, 445 + $g_iMidOffsetY, 725, 445 + $g_iMidOffsetY, 2000)
				If _Sleep(1500) Then Return
				If _ColorCheck(_GetPixelColor(22, 403, True), Hex(0xD3D3CB, 6), 5) Then $bCheckPixel = True
			Else
				Return True
			EndIf
		Next
	EndIf
	SetLog("Failed to Verify Troop " & $g_asTroopNames[TroopIndexLookup($Troop, "DragIfNeeded")] & " Position or Failed to Drag Successfully", $COLOR_ERROR)
	Return False
EndFunc   ;==>DragIfNeeded
Func _WhatZone()
	Local $aResult = _ImageSearchBundlesMyBot($g_sImgArmyWhatZone, 0, "17,320,825,220", True, False, True, 10, 0)
	If IsArray($aResult) And UBound($aResult) > 0 Then
		If $aResult[0][0] = "DarkZone" Then
			SetDebugLog("[_WhatZone] Found DarkZone Image.", $COLOR_INFO)
			Return "Dark"
		EndIf
		If $aResult[0][0] = "RegularZone" Then
			SetDebugLog("[_WhatZone] Found RegularZone Image.", $COLOR_INFO)
			Return "Regular"
		EndIf
	Else
		SetDebugLog("[_WhatZone] Zone not Found at Tain Tab.", $COLOR_ERROR)
	EndIf
	Return -1
EndFunc   ;==>_WhatZone

Func DragIfNeeded($sName)
	If Not $g_bRunState Then Return
	Local $Zona = _WhatZone()
	If $g_bDebugSetlogTrain Then SetLog("DragIfNeeded Train Zone: " & $Zona)
	If IsDarkTroop($sName) Then
		For $i = 1 To 3
			If $Zona = "Dark" Then Return True
			ClickDrag(715, 327, 220, 327, 2000, False, True)
			If _Sleep(1500) Then Return False
			If Not $g_bRunState Then Return False
			For $j = 0 To 1
				$Zona = _WhatZone()
				If $Zona = "Dark" Then Return True
				If _Sleep(1500) Then Return False
			Next
		Next
	Else
		For $i = 1 To 3
			If $Zona = "Regular" Then Return True
			ClickDrag(220, 327, 715, 327, 2000, False, True)
			If _Sleep(1500) Then Return False
			If Not $g_bRunState Then Return False
			For $j = 0 To 1
				$Zona = _WhatZone()
				If $Zona = "Regular" Then Return True
				If _Sleep(1500) Then Return False
			Next
		Next
	EndIf
	Local $iIndex = TroopIndexLookup($sName, "DragIfNeeded")
	If $iIndex <> -1 And $iIndex < UBound($g_asTroopNames) Then SetLog("Failed to Verify Troop " & $g_asTroopNames[$iIndex] & " Position or Failed to Drag Successfully", $COLOR_ERROR)
	Return False
EndFunc   ;==>DragIfNeeded
#ce
Func DoRevampSpells($bDoPreTrain = False, $R25719 = False)
	If Not IsTrainSystemOK() Then Return False
	If $g_bDisableBrewSpell Then Return False
	If _Sleep(500) Then Return True
	Local $bReVampFlag = False
	Local $aTempSpells[$eSpellCount][6]
	Local $aiCurrentSpellsDif[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCurrentSpellsAdd[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	If $g_bDebugSetlogTrain Then SetLog("$g_iTrainSystemErrors[" & $g_iCurAccount & "][Spells]: " & $g_iTrainSystemErrors[$g_iCurAccount][1])
	$aTempSpells = $MySpells
	Local Static $aBtnCoordinates[8][$eSpellCount][2]
	If $Y21453 Or $g_iTrainSystemErrors[$g_iCurAccount][1] > 5 Then
		For $i = 0 To $eSpellCount - 1
			$aBtnCoordinates[$g_iCurAccount][$i][0] = Null
			$aBtnCoordinates[$g_iCurAccount][$i][1] = Null
		Next
		$Y21453 = False
		$g_iTrainSystemErrors[$g_iCurAccount][1] = 0
	EndIf
	If $O21480 Then
		_ArraySort($aTempSpells, 0, 0, 0, 1)
	EndIf
	For $i = 0 To UBound($aTempSpells) - 1
		If $g_bDebugSetlogTrain Then SetLog("$aTempSpells[" & $i & "]: " & $aTempSpells[$i][0] & " - " & $aTempSpells[$i][1])
		$aiCurrentSpellsDif[$i] = 0
		$aiCurrentSpellsAdd[$i] = 0
	Next
	If $bDoPreTrain = False Then
		For $i = 0 To UBound($aTempSpells) - 1
			Local $tempCurComp = $aTempSpells[$i][3]
			Local $tempCur = $g_aiCurrentSpells[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] + $g_aiCurrentSpellsOnT[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
			If $g_bDebugSetlogTrain Then SetLog("$tempMySpells: " & $tempCurComp)
			If $g_bDebugSetlogTrain Then SetLog("$tempCur: " & $tempCur)
			If $tempCurComp <> $tempCur Then
				$aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] = $tempCurComp - $tempCur
			EndIf
		Next
	ElseIf $R25719 = True Then
		For $i = 0 To UBound($aTempSpells) - 1
			If L25722($aTempSpells[$i][0]) > 0 Then
				If $aTempSpells[$i][3] <> $g_aiCurrentSpellsOnQ[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] Then
					$aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] = $aTempSpells[$i][3] - $g_aiCurrentSpellsOnQ[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
				EndIf
			EndIf
		Next
	Else
		For $i = 0 To UBound($aTempSpells) - 1
			If $aTempSpells[$i][5] = 1 Then
				If $aTempSpells[$i][3] <> $g_aiCurrentSpellsOnQ[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] Then
					$aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] = $aTempSpells[$i][3] - $g_aiCurrentSpellsOnQ[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
				EndIf
			EndIf
		Next
	EndIf
	For $i = 0 To UBound($aTempSpells) - 1
		If $aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] > 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some spells haven't train: " & $aTempSpells[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempSpells[$i][0] & " spells: " & $aTempSpells[$i][3])
			$aiCurrentSpellsAdd[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] = $aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
			$bReVampFlag = True
		ElseIf $aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell] < 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some spells over train: " & $aTempSpells[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempSpells[$i][0] & " spells: " & $aTempSpells[$i][3])
			If $g_bDebugSetlogTrain Then SetLog("Current Qty Of " & $aTempSpells[$i][0] & " spells: " & $aTempSpells[$i][3] - $aiCurrentSpellsDif[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell])
		EndIf
	Next
	If $bReVampFlag Then
		If OpenSpellsTab() = False Then Return False
		If _Sleep(100) Then Return True
		Local $iRemainSpellsCapacity = 0
		Local $bFlagOutOfResource = False
		If $bDoPreTrain Then
			If Not IsArray($g_aiSpellsMaxCamp) Then _getArmySpellCapacityMini(0)
			$iRemainSpellsCapacity = $g_aiSpellsMaxCamp[1] - $g_aiSpellsMaxCamp[0]
			If $iRemainSpellsCapacity <= 0 Then
				SetLog("Spells Full with Pre-Train.", $COLOR_SUCCESS1)
				Return True
			EndIf
		Else
			$iRemainSpellsCapacity = $g_iTotalSpellValue - $g_aiSpellsMaxCamp[0]
			If $iRemainSpellsCapacity <= 0 Then
				SetLog("Spells Full.", $COLOR_SUCCESS1)
				Return True
			EndIf
		EndIf
		For $i = 0 To UBound($aTempSpells) - 1
			Local $iOnQQty = $aiCurrentSpellsAdd[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
			If $iOnQQty > 0 Then
				SetLog("Prepare for brew number Of" & " " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0]), $iOnQQty) & " x" & $iOnQQty, $COLOR_ACTION)
			EndIf
		Next
		Local $iCurElixir = $g_aiCurrentLoot[$eLootElixir]
		Local $iCurDarkElixir = $g_aiCurrentLoot[$eLootDarkElixir]
		Local $iCurGemAmount = $g_iGemAmount
		SetLog("Elixir: " & $iCurElixir & "   Dark Elixir: " & $iCurDarkElixir & "   Gem: " & $iCurGemAmount, $COLOR_INFO)
		For $i = 0 To UBound($aTempSpells) - 1
			$g_iTroopButtonX = 0
			$g_iTroopButtonY = 0
			Local $tempSpell = $aiCurrentSpellsAdd[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell]
			If $tempSpell > 0 And $iRemainSpellsCapacity > 0 Then
				If $aBtnCoordinates[$g_iCurAccount][$i][0] = Null Or $aBtnCoordinates[$g_iCurAccount][$i][0] = 0 Then
					If MyTrainClick($aTempSpells[$i][0], True) Then
						$aBtnCoordinates[$g_iCurAccount][$i][0] = $g_iTroopButtonX
						$aBtnCoordinates[$g_iCurAccount][$i][1] = $g_iTroopButtonY
						If $g_bDebugSetlogTrain Then SetLog("First " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0])) & " Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
					Else
						SetLog("Locate Spell Btn failed for " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0])), $COLOR_ERROR)
						ExitLoop
					EndIf
				Else
					$g_iTroopButtonX = $aBtnCoordinates[$g_iCurAccount][$i][0]
					$g_iTroopButtonY = $aBtnCoordinates[$g_iCurAccount][$i][1]
					If $g_bDebugSetlogTrain Then SetLog(GetTroopName(TroopIndexLookup($aTempSpells[$i][0])) & " Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
				EndIf
				If $g_iTroopButtonX <> 0 And $g_iTroopButtonY <> 0 Then
					Local $iCost
					If $aTempSpells[$i][4] = 0 Then
						$iCost = getTSOcrCostQuantity($g_iTroopButtonX - 55, $g_iTroopButtonY + 26)
						If $iCost = 0 Or $iCost = "" Then
							Local $iMaxSpellLevel = $g_aiSpellCostPerLevel[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell][0]
							$iCost = $g_aiSpellCostPerLevel[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell][$iMaxSpellLevel]
						EndIf
						$MySpells[TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell][4] = $iCost
					Else
						$iCost = $aTempSpells[$i][4]
					EndIf
					If $g_bDebugSetlogTrain Then SetLog("$iCost: " & $iCost)
					Local $iBuildCost = (TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell > 5 ? $iCurDarkElixir : $iCurElixir)
					If $g_bDebugSetlogTrain Then SetLog("$BuildCost: " & $iBuildCost)
					If $g_bDebugSetlogTrain Then SetLog("Total need: " & ($tempSpell * $iCost))
					If ($tempSpell * $iCost) > $iBuildCost Then
						$bFlagOutOfResource = True
						SetLog("Not enough " & TroopIndexLookup($aTempSpells[$i][0] - $eLSpell > 5 ? "Dark Elixir" : "Elixir") & " to brew " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0]), 0), $COLOR_WARNING)
						SetLog("Current " & TroopIndexLookup($aTempSpells[$i][0] - $eLSpell > 5 ? "Dark Elixir" : "Elixir") & ": " & $iBuildCost, $COLOR_WARNING)
						SetLog("Total need: " & $tempSpell * $iCost, $COLOR_WARNING)
					EndIf
					If $bFlagOutOfResource Then
						$g_bOutOfElixir = True
						SetLog("Switching to Halt Attack, Stay Online Mode...", $COLOR_WARNING)
						$g_bChkBotStop = True
						$g_iCmbBotCond = 18
						If Not ($g_bFullArmy = True) Then $g_bRestart = True
						Return False
					EndIf
					SetLog("Ready to brew" & " " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0]), $tempSpell) & " x" & $tempSpell & " with total " & (TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell > 5 ? "Dark Elixir" : "Elixir") & ": " & ($tempSpell * $iCost), $COLOR_ACTION1)
					If ($aTempSpells[$i][2] * $tempSpell) <= $iRemainSpellsCapacity Then
						If _TrainClick($g_iTroopButtonX, $g_iTroopButtonY, $tempSpell, $g_iTrainClickDelay, "#BS01") Then
							If TroopIndexLookup($aTempSpells[$i][0]) - $eLSpell > 5 Then
								$iCurDarkElixir -= ($tempSpell * $iCost)
							Else
								$iCurElixir -= ($tempSpell * $iCost)
							EndIf
							$iRemainSpellsCapacity -= ($aTempSpells[$i][2] * $tempSpell)
						EndIf
					Else
						SetLog("Error: remaining space cannot fit to brew " & GetTroopName(TroopIndexLookup($aTempSpells[$i][0]), 0), $COLOR_ERROR)
					EndIf
				Else
					SetLog("Cannot find button: " & $aTempSpells[$i][0] & " for click", $COLOR_ERROR)
					$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				EndIf
			EndIf
		Next
	EndIf
	If $bDoPreTrain Then
		$g_bDisableBrewSpell = True
	EndIf
	Return True
EndFunc   ;==>DoRevampSpells
Func L25722($J25725)
	Local $ToReturn = -1
	If Not $g_bRunState Then Return
	For $Base = $DB To $LB
		If $g_abAttackTypeEnable[$Base] And $g_aiAttackAlgorithm[$Base] = 1 Then
			If V25737($J25725, $Base) Then
				$ToReturn = M25728($J25725, $Base)
				If $ToReturn = 0 Then $ToReturn = -1
			Else
				$ToReturn = -1
			EndIf
		Else
			$ToReturn = -1
		EndIf
	Next
	Return $ToReturn
EndFunc   ;==>L25722
Func M25728($J25725, $M25734)
	Local $ToReturn = 0
	If Not $g_bRunState Then Return
	If $M25734 <> $DB And $M25734 <> $LB Then Return 0
	Local $rownum = 0
	If FileExists($g_sCSVAttacksPath & "\" & $g_sAttackScrScriptName[$M25734] & ".csv") Then
		Local $f, $line, $acommand, $command
		Local $value1, $sName
		$f = FileOpen($g_sCSVAttacksPath & "\" & $g_sAttackScrScriptName[$M25734] & ".csv", 0)
		While 1
			If Not $g_bRunState Then Return
			$line = FileReadLine($f)
			$rownum += 1
			If @error = -1 Then ExitLoop
			$acommand = StringSplit($line, "|")
			If $acommand[0] >= 8 Then
				$command = StringStripWS(StringUpper($acommand[1]), 2)
				$sName = StringStripWS(StringUpper($acommand[5]), 2)
				If $sName = $J25725 Then $ToReturn += 1
			EndIf
		WEnd
		FileClose($f)
	Else
		$ToReturn = 0
	EndIf
	Return $ToReturn
EndFunc   ;==>M25728
Func V25737($J25725, $M25734)
	Local $sSpell = ""
	Local $aVal = 0
	If Not $g_bRunState Then Return
	Switch TroopIndexLookup($J25725, "V25737")
		Case $eLSpell
			$sSpell = "Lightning"
			$aVal = $g_abAttackUseLightSpell
		Case $eHSpell
			$sSpell = "Heal"
			$aVal = $g_abAttackUseHealSpell
		Case $eRSpell
			$sSpell = "Rage"
			$aVal = $g_abAttackUseRageSpell
		Case $eJSpell
			$sSpell = "Jump"
			$aVal = $g_abAttackUseJumpSpell
		Case $eFSpell
			$sSpell = "Freeze"
			$aVal = $g_abAttackUseFreezeSpell
		Case $eCSpell
			$sSpell = "Clone"
			$aVal = $g_abAttackUseCloneSpell
		Case $ePSpell
			$sSpell = "Poison"
			$aVal = $g_abAttackUsePoisonSpell
		Case $eESpell
			$sSpell = "Earthquake"
			$aVal = $g_abAttackUseEarthquakeSpell
		Case $eHaSpell
			$sSpell = "Haste"
			$aVal = $g_abAttackUseHasteSpell
		Case $eSkSpell
			$sSpell = "Skeleton"
			$aVal = $g_abAttackUseSkeletonSpell
		Case $eBtSpell
			$sSpell = "Bat"
			$aVal = $g_abAttackUseBatSpell
		Case $eISpell
			$sSpell = "Invisible"
			$aVal = $g_abAttackUseInvisibilitySpell
	EndSwitch
	If IsArray($aVal) Then Return $aVal[$M25734]
	Return False
EndFunc   ;==>V25737
Func DoRevampSieges($bDoPreTrain = False)
	If Not IsTrainSystemOK() Then Return False
	If $g_bDisableSiegeTrain Then Return False
	If _Sleep(500) Then Return True
	Local $bReVampFlag = False
	Local $aTempSieges[$eSiegeMachineCount][5]
	Local $aiCurrentSiegesDif[$eSiegeMachineCount] = [0, 0, 0, 0]
	Local $aiCurrentSiegesAdd[$eSiegeMachineCount] = [0, 0, 0, 0]
	If $g_bDebugSetlogTrain Then SetLog("$g_iTrainSystemErrors[" & $g_iCurAccount & "][Sieges]: " & $g_iTrainSystemErrors[$g_iCurAccount][2])
	$aTempSieges = $MySieges
	Local Static $aBtnCoordinates[8][$eSiegeMachineCount][2]
	If $D21456 Or $g_iTrainSystemErrors[$g_iCurAccount][2] > 5 Then
		For $i = 0 To $eSiegeMachineCount - 1
			$aBtnCoordinates[$g_iCurAccount][$i][0] = Null
			$aBtnCoordinates[$g_iCurAccount][$i][1] = Null
		Next
		$D21456 = False
		$g_iTrainSystemErrors[$g_iCurAccount][2] = 0
	EndIf
	If $D21534 Then
		_ArraySort($aTempSieges, 0, 0, 0, 1)
	EndIf
	For $i = 0 To UBound($aTempSieges) - 1
		If $g_bDebugSetlogTrain Then SetLog("$aTempSieges[" & $i & "]: " & $aTempSieges[$i][0] & " - " & $aTempSieges[$i][1])
		$aiCurrentSiegesDif[$i] = 0
		$aiCurrentSiegesAdd[$i] = 0
	Next
	If $bDoPreTrain = False Then
		For $i = 0 To UBound($aTempSieges) - 1
			Local $tempCurComp = $aTempSieges[$i][3]
			Local $tempCur = $g_aiCurrentSiegeMachines[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] + $g_aiCurrentSiegeMachinesOnT[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
			If $g_bDebugSetlogTrain Then SetLog("$tempMySieges: " & $tempCurComp)
			If $g_bDebugSetlogTrain Then SetLog("$tempCur: " & $tempCur)
			If $tempCurComp <> $tempCur Then
				$aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] = $tempCurComp - $tempCur
			EndIf
		Next
	Else
		If $g_bEnablePreTrainSieges Then
			For $i = 0 To UBound($aTempSieges) - 1
				If $aTempSieges[$i][3] <> $g_aiCurrentSiegeMachinesOnQ[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] Then
					$aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] = $aTempSieges[$i][3] - $g_aiCurrentSiegeMachinesOnQ[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
				EndIf
			Next
		Else
			If $aTempSieges[$eSiegeWallWrecker][5] = 1 And $aTempSieges[$eSiegeBattleBlimp][5] = 0 And $aTempSieges[$eSiegeStoneSlammer][5] = 0 And $aTempSieges[$eSiegeBarracks][5] = 0 And $aTempSieges[$eSiegeLogLauncher][5] = 0 Then
				If $aTempSieges[$eSiegeWallWrecker][6] <> $g_aiCurrentSiegeMachinesOnQ[$eSiegeWallWrecker] Then
					$aiCurrentSiegesDif[$eSiegeWallWrecker] = $aTempSieges[$eSiegeWallWrecker][6] - $g_aiCurrentSiegeMachinesOnQ[$eSiegeWallWrecker]
				EndIf
			ElseIf $aTempSieges[$eSiegeWallWrecker][5] = 0 And $aTempSieges[$eSiegeBattleBlimp][5] = 1 And $aTempSieges[$eSiegeStoneSlammer][5] = 0 And $aTempSieges[$eSiegeBarracks][5] = 0 And $aTempSieges[$eSiegeLogLauncher][5] = 0 Then
				If $aTempSieges[$eSiegeBattleBlimp][6] <> $g_aiCurrentSiegeMachinesOnQ[$eSiegeBattleBlimp] Then
					$aiCurrentSiegesDif[$eSiegeBattleBlimp] = $aTempSieges[$eSiegeBattleBlimp][6] - $g_aiCurrentSiegeMachinesOnQ[$eSiegeBattleBlimp]
				EndIf
			ElseIf $aTempSieges[$eSiegeWallWrecker][5] = 0 And $aTempSieges[$eSiegeBattleBlimp][5] = 0 And $aTempSieges[$eSiegeStoneSlammer][5] = 1 And $aTempSieges[$eSiegeBarracks][5] = 0 And $aTempSieges[$eSiegeLogLauncher][5] = 0 Then
				If $aTempSieges[$eSiegeStoneSlammer][6] <> $g_aiCurrentSiegeMachinesOnQ[$eSiegeStoneSlammer] Then
					$aiCurrentSiegesDif[$eSiegeStoneSlammer] = $aTempSieges[$eSiegeStoneSlammer][6] - $g_aiCurrentSiegeMachinesOnQ[$eSiegeStoneSlammer]
				EndIf
			ElseIf $aTempSieges[$eSiegeWallWrecker][5] = 0 And $aTempSieges[$eSiegeBattleBlimp][5] = 0 And $aTempSieges[$eSiegeStoneSlammer][5] = 0 And $aTempSieges[$eSiegeBarracks][5] = 1 And $aTempSieges[$eSiegeLogLauncher][5] = 0 Then
				If $aTempSieges[$eSiegeBarracks][6] <> $g_aiCurrentSiegeMachinesOnQ[$eSiegeBarracks] Then
					$aiCurrentSiegesDif[$eSiegeBarracks] = $aTempSieges[$eSiegeBarracks][6] - $g_aiCurrentSiegeMachinesOnQ[$eSiegeBarracks]
				EndIf
			ElseIf $aTempSieges[$eSiegeWallWrecker][5] = 0 And $aTempSieges[$eSiegeBattleBlimp][5] = 0 And $aTempSieges[$eSiegeStoneSlammer][5] = 0 And $aTempSieges[$eSiegeBarracks][5] = 0 And $aTempSieges[$eSiegeLogLauncher][5] = 1 Then
				If $aTempSieges[$eSiegeLogLauncher][6] <> $g_aiCurrentSiegeMachinesOnQ[$eSiegeLogLauncher] Then
					$aiCurrentSiegesDif[$eSiegeLogLauncher] = $aTempSieges[$eSiegeLogLauncher][6] - $g_aiCurrentSiegeMachinesOnQ[$eSiegeLogLauncher]
				EndIf
			Else
				For $i = 0 To UBound($aTempSieges) - 1
					If $aTempSieges[$i][5] = 1 Then
						If $aTempSieges[$i][3] <> $g_aiCurrentSiegeMachinesOnQ[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] Then
							$aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] = $aTempSieges[$i][3] - $g_aiCurrentSiegeMachinesOnQ[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	For $i = 0 To UBound($aTempSieges) - 1
		If $aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] > 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some machines haven't train: " & $aTempSieges[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempSieges[$i][0] & " machines: " & $aTempSieges[$i][3])
			$aiCurrentSiegesAdd[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] = $aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
			$bReVampFlag = True
		ElseIf $aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW] < 0 Then
			If $g_bDebugSetlogTrain Then SetLog("Some machines over train: " & $aTempSieges[$i][0])
			If $g_bDebugSetlogTrain Then SetLog("Setting Qty Of " & $aTempSieges[$i][0] & " machines: " & $aTempSieges[$i][3])
			If $g_bDebugSetlogTrain Then SetLog("Current Qty Of " & $aTempSieges[$i][0] & " machines: " & $aTempSieges[$i][3] - $aiCurrentSiegesDif[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW])
		EndIf
	Next
	If $bReVampFlag Then
		If OpenSiegeMachinesTab() = False Then Return True
		If _Sleep(100) Then Return True
		Local $iRemainSiegesCapacity = 0
		Local $bFlagOutOfResource = False
		If $bDoPreTrain Then
			If Not IsArray($g_aiSiegesMaxCamp) Then getSiegeMachineCapacityMini(0)
			$iRemainSiegesCapacity = $g_aiSiegesMaxCamp[1] - $g_aiSiegesMaxCamp[0]
			If $iRemainSiegesCapacity <= 0 Then
				SetLog("Siege Machines Full with Pre-Train.", $COLOR_SUCCESS1)
				Return True
			EndIf
		Else
			$iRemainSiegesCapacity = $U21528 - $g_aiSiegesMaxCamp[0]
			If $iRemainSiegesCapacity <= 0 Then
				SetLog("Siege Machines Full.", $COLOR_SUCCESS1)
				Return True
			EndIf
		EndIf
		For $i = 0 To UBound($aTempSieges) - 1
			Local $iOnQQty = $aiCurrentSiegesAdd[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
			If $iOnQQty > 0 Then
				SetLog("Prepare for train number Of" & " " & GetTroopName(TroopIndexLookup($aTempSieges[$i][0]), $iOnQQty) & " x" & $iOnQQty, $COLOR_ACTION)
			EndIf
		Next
		Local $iCurGold = $g_aiCurrentLoot[$eLootGold]
		SetLog("Gold: " & $iCurGold, $COLOR_INFO)
		For $i = 0 To UBound($aTempSieges) - 1
			$g_iTroopButtonX = 0
			$g_iTroopButtonY = 0
			Local $Machine4Add = $aiCurrentSiegesAdd[TroopIndexLookup($aTempSieges[$i][0]) - $eWallW]
			If $Machine4Add > 0 And $iRemainSiegesCapacity > 0 Then
				If $aBtnCoordinates[$g_iCurAccount][$i][0] = Null Or $aBtnCoordinates[$g_iCurAccount][$i][0] = 0 Then
					If MyTrainClick($aTempSieges[$i][0], False, True) Then
						$aBtnCoordinates[$g_iCurAccount][$i][0] = $g_iTroopButtonX
						$aBtnCoordinates[$g_iCurAccount][$i][1] = $g_iTroopButtonY
						If $g_bDebugSetlogTrain Then SetLog("First " & GetTroopName(TroopIndexLookup($aTempSieges[$i][0])) & " Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
					Else
						SetLog("Locate Siege button failed for " & GetTroopName(TroopIndexLookup($aTempSieges[$i][0])), $COLOR_ERROR)
						$g_iTrainSystemErrors[$g_iCurAccount][2] += 1
						ExitLoop
					EndIf
				Else
					$g_iTroopButtonX = $aBtnCoordinates[$g_iCurAccount][$i][0]
					$g_iTroopButtonY = $aBtnCoordinates[$g_iCurAccount][$i][1]
					If $g_bDebugSetlogTrain Then SetLog(GetTroopName(TroopIndexLookup($aTempSieges[$i][0])) & "Button detection: " & $g_iTroopButtonX & "," & $g_iTroopButtonY)
				EndIf
				If $g_iTroopButtonX <> 0 And $g_iTroopButtonY <> 0 Then
					Local $iCost
					Local $iSiegeIndex = TroopIndexLookup($aTempSieges[$i][0]) - $eWallW
					If $aTempSieges[$i][4] = 0 Then
						$iCost = $g_aiSiegeMachineCostPerLevel[$iSiegeIndex][1]
						$MySieges[$iSiegeIndex][4] = $iCost
					Else
						$iCost = $aTempSieges[$i][4]
					EndIf
					If $g_bDebugSetlogTrain Then SetLog("$iCost: " & $iCost)
					Local $iBuildCost = $iCurGold
					If $g_bDebugSetlogTrain Then SetLog("$iBuildCost: " & $iBuildCost)
					If $g_bDebugSetlogTrain Then SetLog("Total need: " & ($Machine4Add * $iCost))
					If ($Machine4Add * $iCost) > $iBuildCost Then
						$bFlagOutOfResource = True
						SetLog("Not enough Gold to train" & " " & GetTroopName(TroopIndexLookup($aTempSieges[$i][0]), 0), $COLOR_WARNING)
						SetLog("Current Gold: " & $iBuildCost, $COLOR_WARNING)
						SetLog("Total need: " & $Machine4Add * $iCost, $COLOR_WARNING)
					EndIf
					If $bFlagOutOfResource Then
						$g_bOutOfGold = True
						SetLog("Switching to Halt Attack, Stay Online Mode...", $COLOR_WARNING)
						$g_bChkBotStop = True
						$g_iCmbBotCond = 18
						If Not ($g_bFullArmy = True) Then $g_bRestart = True
						Return False
					EndIf
					SetLog("Ready to train" & " " & GetTroopName(TroopIndexLookup($aTempSieges[$i][0]), $Machine4Add) & " x" & $Machine4Add & " " & "with total Gold" & ": " & ($Machine4Add * $iCost), $COLOR_ACTION1)
					If ($aTempSieges[$i][2] * $Machine4Add) <= $iRemainSiegesCapacity Then
						If _TrainClick($g_iTroopButtonX, $g_iTroopButtonY, $Machine4Add, $g_iTrainClickDelay, "#TT01") Then
							$iCurGold -= ($Machine4Add * $iCost)
							$iRemainSiegesCapacity -= ($aTempSieges[$i][2] * $Machine4Add)
						EndIf
					EndIf
				Else
					SetLog("Cannot find button (2): " & $aTempSieges[$i][0] & " for click", $COLOR_ERROR)
					$g_iTrainSystemErrors[$g_iCurAccount][2] += 1
				EndIf
				If _Sleep(500) Then Return True
			EndIf
		Next
	EndIf
	If $bDoPreTrain Then
		$g_bDisableSiegeTrain = True
	EndIf
	Return True
EndFunc   ;==>DoRevampSieges
#cs
Func SmartWait4Train($J24756 = Default)
	If Not $g_bRunState Then Return
	Static $ichkCloseWaitSpell = 0, $ichkCloseWaitHero = 0
	Local $N8676 = ($J24756 <> Default)
	SetDebugLog("[SmartWait4Train] Initial Function", $COLOR_DEBUG1)
	If Not $g_bCloseWhileTrainingEnable Then Return
	Local $iExitCount = 0
	If _Sleep($DELAYSMARTWAIT) Then Return
	While IsMainPage(2) = False
		If _Sleep($DELAYIDLE1) Then Return
		$iExitCount += 1
		If $iExitCount > 25 Then
			SetLog("SmartWait4Train not finding Main Page, skip function!", $COLOR_ERROR)
			Return
		EndIf
	WEnd
	If Not $g_bCloseWhileTrainingEnable And Not $g_bCloseWithoutShield Then Return
	If ProfileSwitchAccountEnabled() And $g_bChkSmartSwitch = False Then
		SetDebugLog("[SmartWait4Train] $g_bChkSmartSwitch: " & $g_bChkSmartSwitch)
		Return
	EndIf
	Local $aResult, $iActiveHero
	Local $aHeroResult[$eHeroCount]
	Local Const $TRAINWAIT_NOWAIT = 0x00
	Local Const $TRAINWAIT_SHIELD = 0x01
	Local Const $TRAINWAIT_TROOP = 0x02
	Local Const $TRAINWAIT_SPELL = 0x04
	Local Const $TRAINWAIT_HERO = 0x08
	Local $iTrainWaitCloseFlag = $TRAINWAIT_NOWAIT
	Local $sNowTime = "", $sTrainEndTime = ""
	Local $iShieldTime = 0, $iDiffDateTime = 0, $iDiffTime = 0
	Local $RandomAddPercent = Random(0, $g_iCloseRandomTimePercent / 100)
	Local $MinimumTimeClose = Number($g_iCloseMinimumTime * 60)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Random add percent = " & StringFormat("%.4f", $RandomAddPercent), $COLOR_DEBUG)
	If $g_bDebugSetlog Then SetDebugLog("[SmartWait4Train] $MinimumTimeClose = " & $MinimumTimeClose & "s", $COLOR_DEBUG)
	Local $StopEmulator = False
	Local $bFullRestart = False
	Local $bSuspendComputer = False
	If $g_bCloseRandom Then $StopEmulator = "random"
	If $g_bCloseEmulator Then $StopEmulator = True
	If $g_bSuspendComputer Then $bSuspendComputer = True
	If IsArray($g_asShieldStatus) And (StringInStr($g_asShieldStatus[0], "shield", $STR_NOCASESENSEBASIC) Or StringInStr($g_asShieldStatus[0], "guard", $STR_NOCASESENSEBASIC)) Then
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Have shield till " & $g_asShieldStatus[2] & ", close game while wait for train)", $COLOR_DEBUG)
		$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_SHIELD)
	EndIf
	If _Sleep($DELAYRESPOND) Then Return
	If IsArray($g_asShieldStatus) = 0 Or $g_asShieldStatus[0] = "" Or $g_asShieldStatus[0] = "none" Then
		$aResult = getShieldInfo()
		If @error Then
			SetLog("SmartWait4Train Shield OCR error = " & @error & "Extended = " & @extended, $COLOR_ERROR)
			Return False
		Else
			$g_asShieldStatus = $aResult
		EndIf
		If IsArray($g_asShieldStatus) And (StringInStr($g_asShieldStatus[0], "shield", $STR_NOCASESENSEBASIC) Or StringInStr($g_asShieldStatus[0], "guard", $STR_NOCASESENSEBASIC)) Then
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Have shield till " & $g_asShieldStatus[2] & ", close game while wait for train)", $COLOR_DEBUG)
			$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_SHIELD)
		EndIf
	EndIf
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog And IsArray($g_asShieldStatus) Then SetLog("Shield Status:" & $g_asShieldStatus[0] & ", till " & $g_asShieldStatus[2], $COLOR_DEBUG)
	Local $result = OpenArmyOverview(True, "SmartWait4Train()")
	If Not $result Then
		If $g_bDebugImageSave Or $g_bDebugSetlogTrain Then DebugImageSave("SmartWait4Troop2_")
	EndIf
	If _Sleep($DELAYRESPOND) Then Return
	If ProfileSwitchAccountEnabled() Then
		SetLog("Checking Troops, Spells and Times - Close while Train!", $COLOR_INFO)
		CheckTroopTimeAllAccount()
		Local $LessTime = 999, $account = -1
		Local $abAccountNo = AccountNoActive()
		For $i = 0 To $g_iTotalAcc
			If $abAccountNo[$i] And Not $g_abDonateOnly[$i] Then
				If $g_aiRemainTrainTime[$i] < $LessTime Then
					$LessTime = $g_aiRemainTrainTime[$i]
					$account = $i
				EndIf
			EndIf
		Next
		SetDebugLog("[SmartWait4Train] |$LessTime: " & $LessTime)
		SetDebugLog("[SmartWait4Train] |$g_iCloseMinimumTime: " & $g_iCloseMinimumTime)
		SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
		If $LessTime < $g_iCloseMinimumTime Then
			If $LessTime = -999 Then
				SetLog("SmartWait will not run, acc " & $g_asProfileName[$account] & " never ran.")
			Else
				SetLog("SmartWait will not run, acc " & $g_asProfileName[$account] & " is ready to attack!")
			EndIf
			ClickP($aAway, 1, 0, "#0000")
			If _Sleep($DELAYCHECKARMYCAMP4) Then Return
			Return
		Else
			SetLog("SmartWait will proceed with acc " & $g_asProfileName[$account] & " will be ready with " & $LessTime & "min")
			$g_aiTimeTrain[0] = $LessTime
			$g_aiTimeTrain[1] = 0
			$g_aiTimeTrain[2] = 0
			$g_aiTimeTrain[3] = 0
		EndIf
	EndIf
	SetDebugLog("[SmartWait4Train] |$g_aiTimeTrain: " & _ArrayToString($g_aiTimeTrain))
	SetDebugLog("[SmartWait4Train] |$g_iCCRemainTime: " & $g_iCCRemainTime)
	SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	If $g_bCloseWithoutShield Or BitAND($iTrainWaitCloseFlag, $TRAINWAIT_SHIELD) = $TRAINWAIT_SHIELD Then
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$g_bCloseWithoutShield enabled", $COLOR_DEBUG)
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmyTroopTime returned: " & $g_aiTimeTrain[0], $COLOR_DEBUG)
		If _Sleep($DELAYRESPOND) Then Return
		If $g_aiTimeTrain[0] > 0 Then
			If $g_bCloseRandomTime Then
				$g_aiTimeTrain[0] += $g_aiTimeTrain[0] * $RandomAddPercent
			EndIf
			$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_TROOP)
		EndIf
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$iTrainWaitCloseFlag:" & $iTrainWaitCloseFlag & ", troop time = " & StringFormat("%.2f", $g_aiTimeTrain[0]), $COLOR_DEBUG)
	EndIf
	SetDebugLog("[SmartWait4Train] |$g_aiTimeTrain: " & _ArrayToString($g_aiTimeTrain))
	SetDebugLog("[SmartWait4Train] |$g_iCCRemainTime: " & $g_iCCRemainTime)
	SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	If ($g_bCloseWithoutShield Or BitAND($iTrainWaitCloseFlag, $TRAINWAIT_SHIELD) = $TRAINWAIT_SHIELD) And IsWaitforSpellsActive() Then
		$ichkCloseWaitSpell = 1
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$ichkCloseWaitSpell enabled", $COLOR_DEBUG)
		getArmySpellTime()
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmySpellTime returned: " & $g_aiTimeTrain[1], $COLOR_DEBUG)
		If _Sleep($DELAYRESPOND) Then Return
		If $g_aiTimeTrain[1] > 0 Then
			If $g_bCloseRandomTime Then
				$g_aiTimeTrain[1] += $g_aiTimeTrain[1] * $RandomAddPercent
			EndIf
			$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_SPELL)
		EndIf
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$iTrainWaitCloseFlag:" & $iTrainWaitCloseFlag & ", spell time = " & StringFormat("%.2f", $g_aiTimeTrain[1]), $COLOR_DEBUG)
	Else
		$ichkCloseWaitSpell = 0
	EndIf
	SetDebugLog("[SmartWait4Train] |$g_aiTimeTrain: " & _ArrayToString($g_aiTimeTrain))
	SetDebugLog("[SmartWait4Train] |$g_iCCRemainTime: " & $g_iCCRemainTime)
	SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	If ($g_bCloseWithoutShield Or BitAND($iTrainWaitCloseFlag, $TRAINWAIT_SHIELD) = $TRAINWAIT_SHIELD) And IsWaitforHeroesActive() Then
		$ichkCloseWaitHero = 1
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$ichkCloseWaitHero enabled", $COLOR_DEBUG)
		For $j = 0 To UBound($aResult) - 1
			$aHeroResult[$j] = 0
		Next
		If _Sleep($DELAYRESPOND) Then Return
		$aHeroResult = getArmyHeroTime("all")
		If @error Then
			SetLog("getArmyHeroTime return error: " & @error & ", exit SmartWait!", $COLOR_ERROR)
			Return
		EndIf
		If Not IsArray($aHeroResult) Then
			SetLog("getArmyHeroTime OCR fail, exit SmartWait!", $COLOR_ERROR)
			Return
		EndIf
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmyHeroTime returned: " & $aHeroResult[0] & ":" & $aHeroResult[1] & ":" & $aHeroResult[2] & ":" & $aHeroResult[3], $COLOR_DEBUG)
		If _Sleep($DELAYRESPOND) Then Return
		If $aHeroResult[0] > 0 Or $aHeroResult[1] > 0 Or $aHeroResult[2] > 0 Or $aHeroResult[3] > 0 Then
			For $pTroopType = $eKing To $eChampion
				Local $iHeroIdx = $pTroopType - $eKing
				For $pMatchMode = $DB To $LB
					If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then
						SetLog("$pTroopType: " & GetTroopName($pTroopType) & ", $pMatchMode: " & $g_asModeText[$pMatchMode], $COLOR_DEBUG)
						SetLog("TroopToBeUsed: " & IsUnitUsed($pMatchMode, $pTroopType) & ", Hero Wait Status= " & IsSearchModeActiveMini($pMatchMode) & " & " & IsUnitUsed($pMatchMode, $pTroopType) & " & " & ($g_iHeroUpgrading[$iHeroIdx] <> 1) & " & " & ($g_iHeroWaitAttackNoBit[$pMatchMode][$iHeroIdx] = 1), $COLOR_DEBUG)
						SetLog("$g_aiAttackUseHeroes[" & $pMatchMode & "]= " & $g_aiAttackUseHeroes[$pMatchMode] & ", $g_aiSearchHeroWaitEnable[" & $pMatchMode & "]= " & $g_aiSearchHeroWaitEnable[$pMatchMode] & ", $g_iHeroUpgradingBit=" & $g_iHeroUpgradingBit, $COLOR_DEBUG)
					EndIf
					$iActiveHero = -1
					If IsSearchModeActiveMini($pMatchMode) And IsUnitUsed($pMatchMode, $pTroopType) And $g_iHeroUpgrading[$iHeroIdx] <> 1 And $g_iHeroWaitAttackNoBit[$pMatchMode][$iHeroIdx] = 1 Then
						$iActiveHero = $iHeroIdx
					EndIf
					If $iActiveHero <> -1 And $aHeroResult[$iActiveHero] > 0 Then
						If $g_bCloseRandomTime And $g_aiTimeTrain[2] < $aHeroResult[$iActiveHero] Then
							$g_aiTimeTrain[2] = $aHeroResult[$iActiveHero] + ($aHeroResult[$iActiveHero] * $RandomAddPercent)
						ElseIf $g_bCloseExactTime And $g_aiTimeTrain[2] < $aHeroResult[$iActiveHero] Then
							$g_aiTimeTrain[2] = $aHeroResult[$iActiveHero]
						EndIf
						$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_HERO)
						If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then
							SetLog("Wait enabled: " & GetTroopName($pTroopType) & ":" & $g_asModeText[$pMatchMode] & ", $iTrainWaitCloseFlag:" & $iTrainWaitCloseFlag & ", Hero Time:" & $aHeroResult[$iActiveHero] & ", Wait Time: " & StringFormat("%.2f", $g_aiTimeTrain[2]), $COLOR_DEBUG)
						EndIf
					EndIf
				Next
				If _Sleep($DELAYRESPOND) Then Return
			Next
		Else
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("getArmyHeroTime return all zero hero wait times", $COLOR_DEBUG)
		EndIf
		If $g_aiTimeTrain[2] > 0 Then
			If $g_bCloseRandomTime Then
				$g_aiTimeTrain[2] += $g_aiTimeTrain[2] * $RandomAddPercent
			EndIf
			$iTrainWaitCloseFlag = BitOR($iTrainWaitCloseFlag, $TRAINWAIT_HERO)
		EndIf
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$iTrainWaitCloseFlag:" & $iTrainWaitCloseFlag & ", hero time = " & StringFormat("%.2f", $g_aiTimeTrain[2]), $COLOR_DEBUG)
	Else
		$ichkCloseWaitHero = 0
		$g_aiTimeTrain[2] = 0
	EndIf
	If $g_iCCRemainTime = 0 And IsToRequestCC(False) Then
		getArmyCCStatus()
	EndIf
	SetDebugLog("[SmartWait4Train] |$g_aiTimeTrain: " & _ArrayToString($g_aiTimeTrain))
	SetDebugLog("[SmartWait4Train] |$g_iCCRemainTime: " & $g_iCCRemainTime)
	SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	ClickP($aAway, 1, 0, "#0000")
	If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	If $iTrainWaitCloseFlag = $TRAINWAIT_NOWAIT Then Return
	Local $iTrainWaitTime
	Switch $iTrainWaitCloseFlag
		Case 14 To 15
			$iTrainWaitTime = _ArrayMax($g_aiTimeTrain, 1, 0, 2, 0)
		Case 12 To 13
			$iTrainWaitTime = _Max($g_aiTimeTrain[1], $g_aiTimeTrain[2])
		Case 10 To 11
			$iTrainWaitTime = _Max($g_aiTimeTrain[0], $g_aiTimeTrain[2])
		Case 8 To 9
			$iTrainWaitTime = $g_aiTimeTrain[2]
		Case 6 To 7
			$iTrainWaitTime = _Max($g_aiTimeTrain[0], $g_aiTimeTrain[1])
		Case 4 To 5
			$iTrainWaitTime = $g_aiTimeTrain[1]
		Case 2 To 3
			$iTrainWaitTime = $g_aiTimeTrain[0]
		Case 1
			If $g_aiTimeTrain[0] <= 1 And Not $N8676 Then
				ClickP($aAway, 1, 0, "#0000")
				If _Sleep($DELAYCHECKARMYCAMP4) Then Return
				SetLog("No smart troop wait needed", $COLOR_SUCCESS)
				Return
			Else
				$iTrainWaitTime = $g_aiTimeTrain[0]
			EndIf
		Case Else
			SetLog("SmartWait cannot determine time to close CoC!", $COLOR_ERROR)
			Return
	EndSwitch
	If $S12855 Then
		SetLog("Train time = " & StringFormat("%.2f", $iTrainWaitTime) & " minutes, Max Logout Time Enabled = " & Number($G12858) & " mins", $COLOR_SUCCESS)
		$iTrainWaitTime = _Min($iTrainWaitTime, Number($G12858) - 0.4)
	EndIf
	SetDebugLog("[SmartWait4Train] |$g_aiTimeTrain: " & _ArrayToString($g_aiTimeTrain))
	SetDebugLog("[SmartWait4Train] |$iTrainWaitTime: " & $iTrainWaitTime)
	SetDebugLog("[SmartWait4Train] |$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Or $N8676 Then
		SetLog("Training time values: " & StringFormat("%.2f", $g_aiTimeTrain[0]) & " : " & StringFormat("%.2f", $g_aiTimeTrain[1]) & " : " & StringFormat("%.2f", $g_aiTimeTrain[2]), $COLOR_DEBUG)
		SetLog("$iTrainWaitTime = " & StringFormat("%.2f", $iTrainWaitTime) & " minutes", $COLOR_DEBUG)
		SetLog("$iTrainWaitCloseFlag: " & $iTrainWaitCloseFlag)
	EndIf
	If $g_bRequestTroopsEnable And $g_iCCRemainTime > 0 And $g_iCCRemainTime < $iTrainWaitTime Then
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Wait time reduced for CC from: " & StringFormat("%.2f", $iTrainWaitTime) & " To " & StringFormat("%.2f", $g_iCCRemainTime), $COLOR_DEBUG)
		$iTrainWaitTime = $g_iCCRemainTime
	EndIf
	$iTrainWaitTime = $iTrainWaitTime * 60
	$sNowTime = _NowCalc()
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Train end time: " & _DateAdd("s", Int($iTrainWaitTime), $sNowTime), $COLOR_DEBUG)
	If IsArray($g_asShieldStatus) And _DateIsValid($g_asShieldStatus[2]) Then
		$iShieldTime = _DateDiff("s", $sNowTime, $g_asShieldStatus[2])
		If @error Then _logErrorDateDiff(@error)
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Shield time remain: " & $iShieldTime & " seconds", $COLOR_DEBUG)
		If $iShieldTime < 45 Then
			$iShieldTime = 0
		Else
			$iShieldTime -= 45
		EndIf
	EndIf
	$iDiffTime = $iShieldTime - ($iTrainWaitTime)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Time Train:Shield:Diff " & ($iTrainWaitTime) & ":" & $iShieldTime & ":" & $iDiffTime, $COLOR_DEBUG)
	If ($iTrainWaitTime >= $MinimumTimeClose) Or $N8676 Then
		If $iShieldTime > 0 Then
			If $iDiffTime <= 0 Then
				SetLog("Smart wait while shield time = " & StringFormat("%.2f", $iShieldTime / 60) & " Minutes", $COLOR_INFO)
				If $g_bNotifyTGEnable And $g_bNotifyAlertSmartWaitTime Then R5907($g_sNotifyOrigin & " : " & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_01", "Smart Wait While Shield Time = ") & StringFormat("%.2f", $iShieldTime / 60) & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_02", " Minutes") & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_03", "Wait For Troops Ready"))
				If $N8676 Then $iShieldTime = $J24756
				UniversalCloseWaitOpenCoC($iShieldTime * 1000, "SmartWait4Train_", $StopEmulator, $bFullRestart, $bSuspendComputer)
				$g_bRestart = True
				K24759()
			Else
				SetLog("Smart wait train time = " & StringFormat("%.2f", $iTrainWaitTime / 60) & " Minutes", $COLOR_INFO)
				If $g_bNotifyTGEnable And $g_bNotifyAlertSmartWaitTime Then R5907($g_sNotifyOrigin & " : " & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_04", "Smart Wait Train Time = ") & StringFormat("%.2f", $iTrainWaitTime / 60) & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_02", " Minutes") & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_03", "Wait For Troops Ready"))
				If $N8676 Then $iTrainWaitTime = $J24756
				UniversalCloseWaitOpenCoC($iTrainWaitTime * 1000, "SmartWait4Train_", $StopEmulator, $bFullRestart, $bSuspendComputer)
				$g_bRestart = True
				K24759()
			EndIf
		ElseIf ($g_bCloseWithoutShield And $g_aiTimeTrain[0] > 0) Or ($ichkCloseWaitSpell = 1 And $g_aiTimeTrain[1] > 0) Or ($ichkCloseWaitHero = 1 And $g_aiTimeTrain[2] > 0) Then
			SetLog("Smart Wait time = " & StringFormat("%.2f", $iTrainWaitTime / 60) & " Minutes", $COLOR_INFO)
			If $g_bNotifyTGEnable And $g_bNotifyAlertSmartWaitTime Then R5907($g_sNotifyOrigin & " : " & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_05", "Smart Wait Time = ") & StringFormat("%.2f", $iTrainWaitTime / 60) & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_02", " Minutes") & '%0A' & GetTranslatedFileIni("MBR Func_Notify", "Smart-Wait-Time_Info_03", "Wait For Troops Ready"))
			If $N8676 Then $iTrainWaitTime = $J24756
			UniversalCloseWaitOpenCoC($iTrainWaitTime * 1000, "SmartWait4TrainNoShield_", $StopEmulator, $bFullRestart, $bSuspendComputer)
			$g_bRestart = True
			K24759()
		Else
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$ichkCloseWaitSpell=" & $ichkCloseWaitSpell & ", $g_aiTimeTrain[1]=" & $g_aiTimeTrain[1], $COLOR_DEBUG)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("$ichkCloseWaitHero=" & $ichkCloseWaitHero & ", $g_aiTimeTrain[2]=" & $g_aiTimeTrain[2], $COLOR_DEBUG)
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Troop training with time remaining not enabled, skip SmartWait game exit", $COLOR_DEBUG)
		EndIf
		CheckTroopTimeAllAccount(True)
	Else
		SetLog("Smart Wait Time < Minimum Time Required To Close [" & ($MinimumTimeClose / 60) & " Min]", $COLOR_INFO)
		SetLog("Wait Train Time = " & StringFormat("%.2f", $iTrainWaitTime / 60) & " Minutes", $COLOR_INFO)
		SetLog("Remain Shield Time = " & StringFormat("%.2f", $iShieldTime / 60) & " Minutes", $COLOR_INFO)
		SetLog("Not Close CoC Just Wait In The Main Screen", $COLOR_INFO)
		If ($iShieldTime < $iTrainWaitTime) And ($g_bCloseWithoutShield = False) Then
			_SleepStatus($iShieldTime * 1000)
		Else
			_SleepStatus($iTrainWaitTime * 1000)
		EndIf
		K24759()
	EndIf
EndFunc   ;==>SmartWait4Train
Func K24759()
	For $i = 0 To UBound($g_aiTimeTrain) - 1
		$g_aiTimeTrain[$i] = 0
	Next
EndFunc   ;==>K24759
#ce
Func getArmyCCSieges()
	If $g_bDebugSetlogTrain Then SetLog("getArmyCCSieges():", $COLOR_DEBUG)
	If Int($g_iTownHallLevel) < 3 Then Return
	SetLog("Check Clan Castle Machine", $COLOR_INFO)
	Local $iCount = 0
	Local $aiCurrentCCSiegesRemove[$eSiegeMachineCount] = [0, 0, 0, 0]
	While 1
		$iCount += 1
		If $iCount > 3 Then ExitLoop
		If Not $g_bRunState Then Return
		Local $aiSiegesInfo[3]
		Local $sDirectory = $g_sImgArmyOverviewCCSieges
		Local $returnProps = "objectname"
		Local $aPropsValues
		Local $bDeletedExcess = False
		Local $iSiegesCount = 0
		Local $iSiegeIndex = -1
		Q25995()
		If _Sleep(250) Then ExitLoop
		If $g_bRunState = False Then ExitLoop
		_CaptureRegion2()
		For $i = 0 To UBound($MySieges) - 1
			$g_aiCurrentCCSiegeMachines[$i] = 0
			$aiCurrentCCSiegesRemove[$i] = 0
		Next
		Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableCCSiegeSlot[3] - $g_aiArmyAvailableCCSiegeSlot[1])) / 2
		$g_hHBitmap_Av_CCSiege_Slot = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableCCSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableCCSiegeSlot[3] + $iPixelDivider)
		$g_hHBitmap_Capture_Av_CCSiege_Slot = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableCCSiegeSlot[1], Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableCCSiegeSlot[3])
		Local $result = findMultiImage($g_hHBitmap_Av_CCSiege_Slot, $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
		Local $bExitLoopFlag = False, $bContinueNextLoop = False
		If IsArray($result) Then
			For $j = 0 To UBound($result) - 1
				If $j = 0 Then
					$aPropsValues = $result[$j]
					If UBound($aPropsValues) = 1 Then
						If $aPropsValues[0] <> "0" Then
							$aiSiegesInfo[0] = $aPropsValues[0]
							$aiSiegesInfo[2] = 1
							$iSiegesCount += 1
						EndIf
					EndIf
				ElseIf $j = 1 Then
					$aPropsValues = $result[$j]
					SetLog("Error: Multiple detect machines on slot: 1", $COLOR_INFO)
					SetLog("Siege: " & $aiSiegesInfo[0], $COLOR_INFO)
					SetLog("Siege: " & $aPropsValues[0], $COLOR_INFO)
				Else
					$aPropsValues = $result[$j]
					SetLog("Siege: " & $aPropsValues[0], $COLOR_INFO)
				EndIf
			Next
			If $aPropsValues[0] = "0" Then $bExitLoopFlag = True
		ElseIf $g_bDebugSetlogTrain Then
			Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableCCSiegeSlot[3] - $g_aiArmyAvailableCCSiegeSlot[1])) / 2
			Local $temphHBitmap = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableCCSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableCCSiegeSlot[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableCCSiegeSlot[3] + $iPixelDivider)
			_debugSaveHBitmapToImage($temphHBitmap, "Siege_Av_CC_Slot_1", "ArmyWindows\CCSiege\Replace", True)
			_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CCSiege_Slot, "Siege_CC_Slot_1_Unknown_RenameThis_92", "ArmyWindows\CCSiege\Replace", True)
			GdiDeleteHBitmap($temphHBitmap)
			SetLog("Error: Cannot detect what cc Machine on slot: 1", $COLOR_DEBUG)
			SetLog("Please check the filename: Siege_CC_Slot_1_Unknown_RenameThis_92.png", $COLOR_DEBUG)
			SetLog("Locate at:" & @ScriptDir & "\profiles\" & $g_sProfileCurrentName & "\Debug\Images\", $COLOR_DEBUG)
			SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
			SetLog("And then restart the bot.", $COLOR_DEBUG)
			$bContinueNextLoop = True
		Else
			SetLog("Enable Debug Mode.", $COLOR_DEBUG)
			$bContinueNextLoop = True
		EndIf
		If $bExitLoopFlag = True Then ExitLoop
		If $bContinueNextLoop Then ContinueLoop
		$g_hArmyTab_CCSiege_NoUnit_Slot = GetHHBitmapArea($g_hHBitmap2, Int($g_aiArmyAvailableCCSiegeSlotQty[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_QtyWidthForScan) / 2)), $g_aiArmyAvailableCCSiegeSlotQty[1], Int($g_aiArmyAvailableCCSiegeSlotQty[0] + (($g_iArmy_Av_CC_Siege_Slot_Width - $g_iArmy_QtyWidthForScan) / 2) + $g_iArmy_QtyWidthForScan), $g_aiArmyAvailableCCSiegeSlotQty[3])
		$aiSiegesInfo[1] = getTSOcrFullComboQuantity($g_hArmyTab_CCSiege_NoUnit_Slot)
		If $aiSiegesInfo[1] <> 0 Then
			$iSiegeIndex = TroopIndexLookup($aiSiegesInfo[0]) - $eWallW
			$g_aiCurrentCCSiegeMachines[$iSiegeIndex] = $g_aiCurrentCCSiegeMachines[$iSiegeIndex] + $aiSiegesInfo[1]
		Else
			SetLog("Error detect Quantity no. On CC Siege: " & GetTroopName(TroopIndexLookup($aiSiegesInfo[0]), $aiSiegesInfo[1]), $COLOR_RED)
			ExitLoop
		EndIf
		If $iSiegesCount = 0 Then
			SetLog("No Machine On Clan Castle.", $COLOR_WARNING)
			ExitLoop
		EndIf
		For $i = 0 To UBound($MySieges) - 1
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			Local $iTempTotal = $g_aiCurrentCCSiegeMachines[$i]
			If $iTempTotal > 0 Then
				SetLog(" - Clan Castle Machine - " & GetTroopName(TroopIndexLookup($MySieges[$i][0]), $g_aiCurrentCCSiegeMachines[$i]) & ": " & $g_aiCurrentCCSiegeMachines[$i], $COLOR_SUCCESS)
				Local $bIsSiegeInKeepList = False
				If $H21891 Then
					If (TroopIndexLookup($MySieges[$i][0]) - $eWallW) + 1 = $H21891 Then
						$bIsSiegeInKeepList = True
						ExitLoop
					EndIf
					If $bIsSiegeInKeepList = False Then
						$aiCurrentCCSiegesRemove[$i] = $iTempTotal
						$bDeletedExcess = True
					EndIf
				EndIf
			EndIf
		Next
		If $bDeletedExcess Then
			$bDeletedExcess = False
			SetLog(" >>> Remove UnWanted Clan Castle Machine.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				If $aiSiegesInfo[1] <> 0 Then
					Local $iUnitToRemove = $aiCurrentCCSiegesRemove[$iSiegeIndex]
					If $iUnitToRemove > 0 Then
						If $aiSiegesInfo[1] > $iUnitToRemove Then
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegesInfo[0]), $aiSiegesInfo[1]) & " at slot: " & $aiSiegesInfo[2] & ", amount to remove: " & $iUnitToRemove, $COLOR_ACTION)
							RemoveOnTItem($aiSiegesInfo[2] - 1, $iUnitToRemove, $g_aiArmyAvailableCCSiegeSlot[0], "Sieges")
							$iUnitToRemove = 0
							$aiCurrentCCSiegesRemove[$iSiegeIndex] = $iUnitToRemove
						Else
							SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSiegesInfo[0]), $aiSiegesInfo[1]) & " at slot: " & $aiSiegesInfo[2] & ", amount to remove: " & $aiSiegesInfo[1], $COLOR_ACTION)
							RemoveOnTItem($aiSiegesInfo[2] - 1, $aiSiegesInfo[1], $g_aiArmyAvailableCCSiegeSlot[0], "Sieges")
							$iUnitToRemove -= $aiSiegesInfo[1]
							$aiCurrentCCSiegesRemove[$iSiegeIndex] = $iUnitToRemove
						EndIf
					EndIf
				EndIf
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				ExitLoop
			EndIf
			ClickOkay()
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				ContinueLoop
			Else
				If _Sleep(1000) Then ExitLoop
			EndIf
			ContinueLoop
		EndIf
		ExitLoop
	WEnd
	If $g_bDebugImageSave Then
		_debugSaveHBitmapToImage($g_hHBitmap_Av_CCSiege_Slot, "ArmyTab_CCSiege_Slot", "ArmyWindows\CCSiege")
		_debugSaveHBitmapToImage($g_hArmyTab_CCSiege_NoUnit_Slot, "ArmyTab_CCSiege_NoUnit_Slot", "ArmyWindows\CCSiege")
		_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CCSiege_Slot, "RenameIt2ImgLocFormat_ArmyTab_CCSiege_Slot", "ArmyWindows\CCSiege")
	EndIf
	Q25995()
EndFunc   ;==>getArmyCCSieges
Func getArmyCCSiegeMachinesCapacity()
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyCCSiegeMachinesCapacity:", $COLOR_DEBUG1)
	$g_bFullCCSiegeMachine = False
	Local $aGetCCSiegeMachineSize[3] = ["", "", ""]
	Local $sCCSiegeMachineInfo = ""
	Local $iCount
	$iCount = 0
	While 1
		If Not $g_bRunState Then Return
		$sCCSiegeMachineInfo = getTSOcrCCSiegeMachineCap()
		If $g_bDebugSetlogTrain Then SetLog("$sCCSiegeMachineInfo = " & $sCCSiegeMachineInfo, $COLOR_DEBUG)
		If $sCCSiegeMachineInfo = "" And $iCount > 1 Then ExitLoop
		$aGetCCSiegeMachineSize = StringSplit($sCCSiegeMachineInfo, "#")
		If IsArray($aGetCCSiegeMachineSize) Then
			If $aGetCCSiegeMachineSize[0] > 1 Then
				If Number($aGetCCSiegeMachineSize[2]) > 2 And $aGetCCSiegeMachineSize[2] = 0 Then
					If $g_bDebugSetlogTrain Then SetLog(" OCR value is not valid cc siege machine camp size", $COLOR_DEBUG)
					ContinueLoop
				EndIf
				$Y21897 = Number($aGetCCSiegeMachineSize[2])
				$B21894 = Number($aGetCCSiegeMachineSize[1])
				SetLog("Total Clan Castle Machine: " & $B21894 & "/" & $Y21897)
				ExitLoop
			Else
				$B21894 = 0
				$Y21897 = 0
			EndIf
		Else
			$B21894 = 0
			$Y21897 = 0
		EndIf
		$iCount += 1
		If $iCount > 30 Then ExitLoop
		If _Sleep(250) Then Return
		If $g_bRunState = False Then Return
	WEnd
	If $B21894 = 0 And $Y21897 = 0 Then
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("CC Siege Machine size read error or maybe not available.", $COLOR_ERROR)
	EndIf
	If $B21894 >= $Y21897 Then $g_bFullCCSiegeMachine = True
	If $g_bFullCCSiegeMachine = False Then
		If $g_bChkWait4CCSiege Then
			SetLog("Waiting for Clan Castle Machine", $COLOR_ACTION)
		Else
			SetLog("Not waiting for Clan Castle Machine.", $COLOR_ACTION)
			$g_bFullCCSiegeMachine = True
		EndIf
	EndIf
	If $L21825 Then
		$W21843 = $B21894 < $V21834
	EndIf
EndFunc   ;==>getArmyCCSiegeMachinesCapacity
Func Q25995()
	GdiDeleteHBitmap($g_hHBitmap2)
	GdiDeleteHBitmap($g_hHBitmap_Av_CCSiege_Slot)
	GdiDeleteHBitmap($g_hArmyTab_CCSiege_NoUnit_Slot)
	GdiDeleteHBitmap($g_hHBitmap_Capture_Av_CCSiege_Slot)
EndFunc   ;==>Q25995
Func _getArmySiegeMachines($hHBitmap)
	If Not $g_bRunState Then Return
	If $g_bDebugSetlogTrain Then SetLog("_getArmySiegeMachines():", $COLOR_DEBUG)
	Local $RemSlot[$eSiegeMachineCount] = [0, 0, 0, 0]
	SetLog("Check Army Siege Machines", $COLOR_INFO)
	For $i = 0 To UBound($MySieges) - 1
		$g_aiCurrentSiegeMachines[$i] = 0
	Next
	If Int($g_iTownHallLevel) < 12 Then Return
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiSiegesInfo[3][3]
	Local $AvailableCamp = 0
	Local $sDirectory = $g_sImgArmyOverviewSieges
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iSiegeIndex = -1
	Local $sSiegeName = ""
	Local $bDeletedExcess = False
	Local $bForceToDeleteUnknow = False
	For $i = 0 To 2
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int(612 + ($g_iArmy_Av_Siege_Slot_Width * $i)), 205, False), Hex(0X4689C8, 6), 20) Then
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableSiegeSlot[3] - $g_aiArmyAvailableSiegeSlot[1])) / 2
			$g_hHBitmap_Av_Siege_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableSiegeSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_Siege_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableSiegeSlot[1], Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableSiegeSlot[3])
			Local $result = findMultiImage($g_hHBitmap_Av_Siege_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$aiSiegesInfo[$i][0] = $aPropsValues[0]
							$aiSiegesInfo[$i][2] = $i + 1
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect machines on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Machine: " & $aiSiegesInfo[$i][0], $COLOR_ERROR)
						SetLog("Machine: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Machine: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then
					U27660($i)
					ExitLoop
				EndIf
			ElseIf $g_bDebugSetlogTrain Or $g_iTrainSystemErrors[$g_iCurAccount][2] > 0 Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableSiegeSlot[3] - $g_aiArmyAvailableSiegeSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableSiegeSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSiegeSlot[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableSiegeSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Siege_Av_Slot_" & $i + 1, "ArmyWindows\Sieges\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_Siege_Slot[$i], "Siege_Slot_" & $i + 1 & "_Unknown_RenameThis_92", "ArmyWindows\Sieges\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what machines on slot: " & $i + 1, $COLOR_ERROR)
				SetLog("Please check the filename: Siege_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_ERROR)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_ERROR)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_ERROR)
				SetLog("And then restart the bot.", $COLOR_ERROR)
				U27660($i)
				$g_iTrainSystemErrors[$g_iCurAccount][2] += 1
				If $g_iTrainSystemErrors[$g_iCurAccount][2] > 5 Then
					SetLog("This Siege on slot " & $i + 1 & " needs to be removed")
					If $g_bChkEnableDeleteExcessSieges Then
						SetLog("This Siege on slot " & $i + 1 & " needs to be removed!")
						$aiSiegesInfo[$i][0] = "UNKNOWN"
					EndIf
				Else
					ContinueLoop
				EndIf
			Else
				SetLog("Enable Debug Mode", $COLOR_DEBUG)
				U27660($i)
				ContinueLoop
			EndIf
			$g_hHBitmap_Av_Siege_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSiegeSlotQty[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - 60) / 2)), $g_aiArmyAvailableSiegeSlotQty[1], Int($g_aiArmyAvailableSiegeSlotQty[0] + ($g_iArmy_Av_Siege_Slot_Width * $i) + (($g_iArmy_Av_Siege_Slot_Width - 60) / 2) + 60), $g_aiArmyAvailableSiegeSlotQty[3])
			$aiSiegesInfo[$i][1] = getTSOcrFullComboQuantity($g_hHBitmap_Av_Siege_SlotQty[$i])
			If $aiSiegesInfo[$i][1] <> 0 Then
				If $aiSiegesInfo[$i][0] = "UNKNOWN" Then
					$RemSlot[$i] = $aiSiegesInfo[$i][1]
					$bForceToDeleteUnknow = True
					$bDeletedExcess = True
				Else
					$iSiegeIndex = TroopIndexLookup($aiSiegesInfo[$i][0]) - $eWallW
					$sSiegeName = GetTroopName(TroopIndexLookup($aiSiegesInfo[$i][0]), $aiSiegesInfo[$i][1])
					SetLog(" - No. of Available " & $sSiegeName & ": " & $aiSiegesInfo[$i][1], $COLOR_SUCCESS)
					$g_aiCurrentSiegeMachines[$iSiegeIndex] = $aiSiegesInfo[$i][1]
					$AvailableCamp += ($aiSiegesInfo[$i][1] * $MySieges[$iSiegeIndex][2])
					If $g_bChkEnableDeleteExcessSieges Then
						If $aiSiegesInfo[$i][1] > $MySieges[$iSiegeIndex][3] Then
							$bDeletedExcess = True
							SetLog(" >>> Excess: " & $aiSiegesInfo[$i][1] - $MySieges[$iSiegeIndex][3], $COLOR_WARNING)
							$RemSlot[$i] = $aiSiegesInfo[$i][1] - $MySieges[$iSiegeIndex][3]
							If $g_bDebugSetlogTrain Then SetLog("Set Remove Slot: " & $aiSiegesInfo[$i][2])
						EndIf
					EndIf
				EndIf
			Else
				SetLog("Error detect quantity no. On Machine: " & GetTroopName(TroopIndexLookup($aiSiegesInfo[$i][0]), $aiSiegesInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		U27660($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $AvailableCamp <> $g_iCurrentSieges And $bForceToDeleteUnknow = False Then
		If $g_bChkEnableDeleteExcessSieges Then
			SetLog("Error: Machines size for all available Unit: " & $AvailableCamp & "  -  Camp: " & $g_iCurrentSieges, $COLOR_RED)
			$g_bRestartCheckTroop = True
			$g_iTrainSystemErrors[$g_iCurAccount][2] += 1
			Return False
		EndIf
	Else
		If $bDeletedExcess Then
			$bDeletedExcess = False
			If OpenSiegeMachinesTab() = False Then Return
			If Not _ColorCheck(_GetPixelColor(823, 175 + $g_iMidOffsetY, True), Hex(0xCFCFC8, 6), 20) Then
				SetLog(" >>> Stop Train Siege Machines.", $COLOR_WARNING)
				RemoveAllTroopAlreadyTrain()
				Return False
			EndIf
			If OpenArmyTab(True, "Siege Machines Tab") = False Then Return
			SetLog(" >>> Remove Excess Siege Machines.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				Return False
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 2 To 0 Step -1
					Local $RemoveSlotQty = $RemSlot[$i]
					If $g_bDebugSetlogTrain Then SetLog($i & " $RemoveSlotQty: " & $RemoveSlotQty)
					If $RemoveSlotQty > 0 Then
						Local $iRx = (659 + ($g_iArmy_Av_Siege_Slot_Width * $i))
						Local $iRy = 240 + $g_iMidOffsetY
						For $j = 1 To $RemoveSlotQty
							Click(Random($iRx - 2, $iRx + 2, 1), Random($iRy - 2, $iRy + 2, 1))
							If $g_bUseRandomClick = False Then
								If _Sleep($g_iTrainClickDelay) Then Return
							Else
								If $g_iTrainClickDelay < 100 Then $g_iTrainClickDelay += 100
								If $g_iTrainClickDelay > 400 Then $g_iTrainClickDelay -= 100
								If _Sleep(Random($g_iTrainClickDelay - 100, $g_iTrainClickDelay + 100, 1)) Then Return
							EndIf
						Next
						$RemSlot[$i] = 0
					EndIf
				Next
			Else
				Return False
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				Return False
			EndIf
			ClickOkay()
			$g_bRestartCheckTroop = True
			$g_iTrainSystemErrors[$g_iCurAccount][2] += 1
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Return False
			Else
				If _Sleep(1000) Then Return False
			EndIf
			Return False
		EndIf
		GdiDeleteHBitmap($g_hHBitmap)
		GdiDeleteBitmap($g_hBitmap)
		Return True
	EndIf
	Return False
EndFunc   ;==>_getArmySiegeMachines

Func U27660($i)
	GdiDeleteHBitmap($g_hHBitmap_Av_Siege_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Siege_Slot[$i])
	GdiDeleteHBitmap($g_hHBitmap_Av_Siege_SlotQty[$i])
EndFunc   ;==>U27660

Func SetupTrainVars()
	#Region - Troops
	;name,order,size,unit quantity,train cost
	For $i = 0 To $eTroopCount - 1		
		$MyTroops[$i][0] = String($g_asTroopShortNames[$i]) ; name
		$MyTroops[$i][1] = Number($g_aiCmbCustomTrainOrder[$i]) ; order
		$MyTroops[$i][2] = Number($g_aiTroopSpace[$i]) ; size
		$MyTroops[$i][3] = Number($g_aiArmyCustomTroops[$i]) ; unit quantity
		$MyTroops[$i][4] = Number($MyTroops[$i][4]) 
	Next

	$g_iMyTroopsSize = 0
	For $i = 0 To UBound($MyTroops) - 1
		$g_iMyTroopsSize += $MyTroops[$i][3] * $MyTroops[$i][2]
	Next
	
	If $g_iMyTroopsSize = 0 Then
		SetLog("Please Setup your Army!", $COLOR_ERROR)
		Return
	EndIf
	#EndRegion - Troops

	#Region - Spells
	;name,order,size,unit quantity,train cost
	For $i = 0 To $eSpellCount - 1		
		$MySpells[$i][0] = String($g_asSpellShortNames[$i]) ; name
		$MySpells[$i][1] = Number($g_aiCmbCustomBrewOrder[$i]) ; order
		$MySpells[$i][2] = Number($g_aiSpellSpace[$i]) ; size
		$MySpells[$i][3] = Number($g_aiArmyCompSpells[$i]) ; unit quantity
		$MySpells[$i][4] = Number($MySpells[$i][4]) 
		$MySpells[$i][5] = Number($MySpells[$i][5]) 
	Next
	$g_iMySpellsSize = 0
	For $i = 0 To UBound($MySpells) - 1
		$g_iMySpellsSize += $MySpells[$i][3] * $MySpells[$i][2]
	Next
	#EndRegion - Spells

	#Region - Sieges
	;name,order,size,unit quantity,train cost
	For $i = 0 To $eSiegeMachineCount - 1		
		$MySieges[$i][0] = String($g_asSiegeMachineShortNames[$i]) ; name
		$MySieges[$i][1] = $i ;Number($g_aiCmbSiegeMachineOrder[$i]) ; order
		$MySieges[$i][2] = Number($g_aiSiegeMachineSpace[$i]) ; size
		$MySieges[$i][3] = Number($g_aiArmyCustomSiegeMachines[$i]) ; unit quantity
		$MySieges[$i][4] = Number($MySieges[$i][4]) 
		$MySieges[$i][5] = Number($MySieges[$i][5]) 
	Next
	#EndRegion - Sieges

EndFunc

Func TrainSystem($bForceDoubleTrain = False)
	SetupTrainVars()
	
	If $g_bDebugSetlogTrain Then SetLog("Start TrainSystem()", $COLOR_DEBUG)
	If $g_bTrainEnabled = False Then
		If $g_bDebugSetlogTrain Then SetLog("TrainSystem is disabled.", $COLOR_DEBUG)
		Return
	EndIf
	; GetBoostedFrom()

	If Not BoostSuperTroop() Then Return

	Local $iCount = 0
	If Not $g_bRunState Then Return
	StartGainCost()
	If _Sleep(100) Then Return
	ClickP($aAway, 1, 0, "#0268")
	If _Sleep(200) Then Return
	If _Sleep($DELAYRESPOND) Then Return
	checkAttackDisable($g_iTaBChkIdle)
	If $g_bIsSearchLimit Or $g_bRestart Or $g_bIsClientSyncError Then
		If $g_bDebugSetlogTrain Then SetLog("Skip TrainSystem Due To Any $g_bIsSearchLimit=" & String($g_bIsSearchLimit) & ",$g_bRestart=" & String($g_bRestart) & ",$g_bIsClientSyncError=" & String($g_bIsClientSyncError), $COLOR_DEBUG)
		Return
	EndIf
	SetLog("Start Training Army", $COLOR_INFO)
	$g_bWaitForCCTroopSpell = False
	If _Wait4Pixel($aButtonOpenTrainArmy[4], $aButtonOpenTrainArmy[5], $aButtonOpenTrainArmy[6], $aButtonOpenTrainArmy[7]) Then
		If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton", $COLOR_SUCCESS)
		If IsMainPage() Then
			If $g_bUseRandomClick = False Then
				Click($aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0, "#1293")
			Else
				ClickR($aArmyTrainButtonRND, $aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0)
			EndIf
		EndIf
	EndIf
	If _Sleep(250) Then Return
	If ProfileSwitchAccountEnabled() Then
		SetDebugLog("[TrainSystem] : " & $g_asProfileName[$g_iCurAccount])
		SetDebugLog("[TrainSystem] $g_bUseCVSAndRandomTroops[$DB]: " & $g_bUseCVSAndRandomTroops[$DB])
		SetDebugLog("[TrainSystem] $g_bUseCVSAndRandomTroops[$LB]: " & $g_bUseCVSAndRandomTroops[$LB])
		SetDebugLog("[TrainSystem] $g_bUseSmartFarmAndRandomTroops: " & $g_bUseSmartFarmAndRandomTroops)
		SetDebugLog("[TrainSystem] $g_iCmbNextTroopSetting[$g_iCurAccount]: " & $g_iCmbNextTroopSetting[$g_iCurAccount])
		SetDebugLog("[TrainSystem] $g_iCmbTroopSetting: " & $g_iCmbTroopSetting)
		SetDebugLog("[TrainSystem] $g_bResetArmyTroopsCombo: " & $g_bResetArmyTroopsCombo)
		SetDebugLog("[TrainSystem] $g_bIsSearchLimit: " & $g_bIsSearchLimit)
		SetDebugLog("[TrainSystem] $g_bRestart: " & $g_bRestart)
		SetDebugLog("[TrainSystem] $g_bIsClientSyncError: " & $g_bIsClientSyncError)
	EndIf
	If ($g_abAttackTypeEnable[$DB] And $g_bUseSmartFarmAndRandomTroops) Or $g_bUseCVSAndRandomTroops[$DB] Or $g_bUseCVSAndRandomTroops[$LB] Then
		If $g_bIsSearchLimit Or $g_bRestart Or $g_bIsClientSyncError Then Return
		If $g_bResetArmyTroopsCombo Then
			For $i = 0 To 10
				$g_iCmbNextTroopSetting[$g_iCurAccount] = Random(0, 2, 1)
				If $g_iCmbTroopSetting <> $g_iCmbNextTroopSetting[$g_iCurAccount] Then
					$g_bResetArmyTroopsCombo = False
					SetLog("Using the composition army " & $g_iCmbNextTroopSetting[$g_iCurAccount] + 1 & " for Next Attack!")
					ExitLoop
				EndIf
			Next
		EndIf
	EndIf
	If $g_bDebugSetlogTrain Then SetLog("Double Train Enabled?: " & $g_bEnablePreTrainTroops)
	$iCount = 0
	While 1
		If Not $g_bRunState Then Return
		getArmyTroopTime()
		If _Sleep($DELAYRESPOND) Then Return
		If $g_aiTimeTrain[0] > $F21816 Or $g_aiTimeTrain[0] <= 0 Then
			ExitLoop
		Else
			Local $iStickDelay
			If $g_aiTimeTrain[0] < 1 Then
				$iStickDelay = Int($g_aiTimeTrain[0] * 60000)
			ElseIf $g_aiTimeTrain[0] >= 2 Then
				$iStickDelay = 60000
			Else
				$iStickDelay = 30000
			EndIf
			SetLog("Waiting for Troops to be Ready...", $COLOR_INFO)
			If _Sleep($iStickDelay) Then Return
		EndIf
		$iCount += 1
		If $iCount > (10 + $F21816) Then ExitLoop
	WEnd
	If $g_bDebugSetlogTrain Then
		SetLog("Before $g_bDisableTrain: " & $g_bDisableTrain)
		SetLog("Before $g_bDisableBrewSpell: " & $g_bDisableBrewSpell)
		SetLog("Before $g_bDisableSiegeTrain: " & $g_bDisableSiegeTrain)
	EndIf

	If Not $g_aSkipTrain[$g_iCurAccount] Then Return

	Local $isToCheckTroops = True, $isToCheckSpells = True, $isToCheckSieges = True, $isToCheckHeroes = True
	Local $isToCheckCCTroops = True, $isToCheckCCSpells = True, $isToCheckCCSiege = True

	#Region - AIO
	ForceCaptureRegion()
	_CaptureRegion()

	; "Troops"
	If _ColorCheck(_GetPixelColor(27, 173, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckTroops = False
	EndIf

	; "Sieges"
	If _ColorCheck(_GetPixelColor(607, 173, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckSieges = False
		$g_bFullArmySieges = True
		$g_bDisableSiegeTrain = True
	EndIf

	; "Spells"
	If _ColorCheck(_GetPixelColor(30, 320, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckSpells = False
		$g_bFullArmySpells = True
		$g_bDisableBrewSpell = True
	EndIf

	; "Heroes"
	If _ColorCheck(_GetPixelColor(550, 320, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckHeroes = False
		$g_bFullArmyHero = True
	EndIf

	; "CCtroops"
	If _ColorCheck(_GetPixelColor(30, 476, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckCCTroops = False
		$g_bFullCCTroops = True
	EndIf

	; "CCSpells"
	If _ColorCheck(_GetPixelColor(460, 476, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckCCSpells = False
		$g_bFullCCSpells = True
	EndIf

	; "CCSiege"
	If _ColorCheck(_GetPixelColor(637, 477, False), Hex(0xD0D0C0, 6), 25) Then
		$isToCheckCCSiege = False
		$g_bFullCCSiegeMachine = True
	EndIf

	#EndRegion - AIO
	
	If $g_bDebugSetlogTrain Then
		SetLog("After $g_bDisableTrain: " & $g_bDisableTrain)
		SetLog("After $g_bDisableBrewSpell: " & $g_bDisableBrewSpell)
		SetLog("After $g_bDisableSiegeTrain: " & $g_bDisableSiegeTrain)
	EndIf
	
	If OpenArmyTab() = False Then Return
	
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $g_bDebugFuncTime Then StopWatchStart("getArmyTroopTime")
	If $isToCheckTroops Then getArmyTroopTime()
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $g_bDebugFuncTime Then StopWatchStart("getArmySpellTime")
	If $isToCheckSpells Then getArmySpellTime()
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If Not $g_bFullArmySieges And $g_iTownHallLevel >= 12 Then
		If OpenSiegeMachinesTab() = False Then Return
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return
		If $g_bDebugFuncTime Then StopWatchStart("getArmySiegeTime")
		getArmySiegeTime()
		If $g_bDebugFuncTime Then StopWatchStopLog()
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return
		If OpenArmyTab() = False Then Return
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	EndIf
	If $g_bDebugFuncTime Then StopWatchStart("getArmyHeroTime")
	If $isToCheckHeroes Then getArmyHeroTime("all")
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $g_bChkRemoveCCForDefense And RequestDefenseCC() Then
		RemoveCCTroopBeforeDefenseRequest()
	Else
		If $isToCheckCCTroops Then _getArmyCCTroops()
	EndIf
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckCCTroops Then getArmyCCTroopCapacity()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckCCSpells Then _getArmyCCSpells()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckCCSpells Then _getArmyCCSpellCapacity()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckCCSiege Then getArmyCCSieges()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckCCSiege Then getArmyCCSiegeMachinesCapacity()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $isToCheckHeroes Then getArmyHeroCount()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return

	#Region - AIO
	; add to the hereos available, the ones upgrading so that it ignores them... we need this logic or the bitwise math does not work out correctly
	$g_iHeroAvailable = BitOR($g_iHeroAvailable, $g_iHeroUpgradingBit)
	$g_bFullArmyHero = (BitAND($g_aiSearchHeroWaitEnable[$DB], $g_iHeroAvailable) = $g_aiSearchHeroWaitEnable[$DB] And $g_abAttackTypeEnable[$DB]) Or _
			(BitAND($g_aiSearchHeroWaitEnable[$LB], $g_iHeroAvailable) = $g_aiSearchHeroWaitEnable[$LB] And $g_abAttackTypeEnable[$LB]) Or _
			($g_aiSearchHeroWaitEnable[$DB] = $eHeroNone And $g_aiSearchHeroWaitEnable[$LB] = $eHeroNone)

	If $g_bDebugSetlogTrain Then
		Setlog("Heroes are Ready: " & String($g_bFullArmyHero))
		Setlog("Heroes Available Num: " & $g_iHeroAvailable) ;  	$eHeroNone = 0, $eHeroKing = 1, $eHeroQueen = 2, $eHeroWarden = 4, $eHeroChampion = 5
		Setlog("Search Hero Wait Enable [$DB] Num: " & $g_aiSearchHeroWaitEnable[$DB]) ; 	what you are waiting for : 1 is King , 3 is King + Queen , etc etc
		Setlog("Search Hero Wait Enable [$LB] Num: " & $g_aiSearchHeroWaitEnable[$LB])
		Setlog("Dead Base BitAND: " & BitAND($g_aiSearchHeroWaitEnable[$DB], $g_iHeroAvailable))
		Setlog("Live Base BitAND: " & BitAND($g_aiSearchHeroWaitEnable[$LB], $g_iHeroAvailable))
		Setlog("Are you 'not' waiting for Heroes: " & String($g_aiSearchHeroWaitEnable[$DB] = $eHeroNone And $g_aiSearchHeroWaitEnable[$LB] = $eHeroNone))
		Setlog("Is Wait for Heroes Active : " & IsWaitforHeroesActive())
	EndIf

	; If Drop Trophy with Heroes is checked and a Hero is Available or under the trophies range, then set $g_bFullArmyHero to True
	If Not IsWaitforHeroesActive() And $g_bDropTrophyUseHeroes Then $g_bFullArmyHero = True
	If Not IsWaitforHeroesActive() And Not $g_bDropTrophyUseHeroes And Not $g_bFullArmyHero Then
		If $g_iHeroAvailable > 0 Or Number($g_aiCurrentLoot[$eLootTrophy]) <= Number($g_iDropTrophyMax) Then
			$g_bFullArmyHero = True
		Else
			SetLog("Waiting for Heroes to drop trophies!", $COLOR_ACTION)
		EndIf
	EndIf
	#EndRegion - AIO

	getArmyCCStatus()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return
	If $g_bDebugSetlogTrain Then
		SetLog("Fullarmy = " & $g_bFullArmy & " CurCamp = " & $g_CurrentCampUtilization & " TotalCamp = " & $g_iTotalCampSpace & " - result = " & ($g_bFullArmy = True And $g_CurrentCampUtilization = $g_iTotalCampSpace), $COLOR_DEBUG)
		SetLog("$g_bfullArmy: " & $g_bFullArmy & " - $isToCheckTroops:" & $isToCheckTroops)
		SetLog("$g_bFullArmyHero: " & $g_bFullArmyHero & " - $isToCheckHeroes:" & $isToCheckHeroes)
		SetLog("$g_bFullArmySpells: " & $g_bFullArmySpells & " - $isToCheckSpells:" & $isToCheckSpells)
		SetLog("$g_bFullArmySieges: " & $g_bFullArmySieges & " - $isToCheckSieges:" & $isToCheckSieges)
		SetLog("$g_bFullCCTroops: " & $g_bFullCCTroops & " - $isToCheckCCTroops:" & $isToCheckCCTroops)
		SetLog("$g_bFullCCSpells: " & $g_bFullCCSpells & " - $isToCheckCCSpells:" & $isToCheckCCSpells)
		SetLog("$g_bFullCCSiegeMachine: " & $g_bFullCCSiegeMachine & " - $isToCheckCCSiege:" & $isToCheckCCSiege)
	EndIf
	If $g_bFullArmy And $g_bFullArmySpells And $g_bFullArmyHero And $g_bFullArmySieges Then
		If Not $g_bFullCCTroops Or Not $g_bFullCCSpells Then $g_bWaitForCCTroopSpell = True
	EndIf
	If $g_bFullArmy = True And $g_bFullArmyHero = True And $g_bFullArmySpells = True And $g_bFullCCSpells = True And $g_bFullCCTroops = True And $g_bFullArmySieges = True And $g_bFullCCSiegeMachine = True Then
		$g_bIsFullArmywithHeroesAndSpells = True
	Else
		$g_bIsFullArmywithHeroesAndSpells = False
	EndIf
	If $g_bDebugSetlogTrain Then SetLog("$g_bIsFullArmywithHeroesAndSpells: " & $g_bIsFullArmywithHeroesAndSpells)
	If $g_bIsFullArmywithHeroesAndSpells = True And $g_bTrainEnabled And $g_iCommandStop = 0 Then
		ClickP($aAway, 1, 250, "#0504")
		EndGainCost("Train")
		UpdateStats()
		SetLog("Your Army is ready, Online/Collect/Donate only")
		Return
	EndIf
	If $g_bIsFullArmywithHeroesAndSpells = False Then
		If $g_bChkUseRandomCSV Then RunRDNCSVScript()
		ArmyChecker($g_bDisableTrain, $g_bDisableBrewSpell, $g_bDisableSiegeTrain, $bForceDoubleTrain)
	Else
		SetLog("Your Army Camps are now Full", $COLOR_SUCCESS)
		If ($g_bNotifyTGEnable = True And $g_bNotifyAlertCampFull = True) Then PushMsg("CampFull")
	EndIf
	If _Sleep(200) Then Return
	ClickP($aAway, 1, 250, "#0504")
	If _Sleep(250) Then Return
	$g_bFirstStart = False
	If _Sleep(200) Then Return
	EndGainCost("Train")
	UpdateStats()
EndFunc   ;==>TrainSystem

Func ArmyChecker($bDisableTrain = True, $bDisableBrewSpell = True, $bDisableTrainSieges = True, $bForcePreTrain = False)

	If $bForcePreTrain Then SetLog("Lets make Troops Before Attack!")
	If $g_bDebugSetlogTrain Then SetLog("Begin ArmyChecker()", $COLOR_DEBUG1)
	Local $hTimer = __TimerInit()
	Local $iCount = 0
	Local $bDisableTDoubleTrain = False
	Local $bDisableSDoubleTrain = False
	While 1
		Local $iCount2 = 0
		Local $bTroopCheckOK = False
		Local $bSpellCheckOK = False
		Local $bSiegeCheckOK = False
		$g_bRestartCheckTroop = False
		$iCount += 1
		If $iCount > 8 Then
			ExitLoop
		EndIf
		DeleteTrainHBitmap()
		If OpenArmyTab() = False Then ExitLoop
		If _Sleep(250) Then ExitLoop
		$iCount2 = 0
		While IsQueueBlockByMsg($iCount2)
			If _Sleep(1000) Then ExitLoop
			$iCount2 += 1
			If $iCount2 >= 30 Then
				SetLog(IsQueueBlockByMsg($iCount2), $COLOR_INFO)
				ExitLoop
			EndIf
		WEnd
		_CaptureRegion2()
		$g_hHBitmapArmyTab = GetHHBitmapArea($g_hHBitmap2)
		; ($g_hHBitmapArmyTab)
		_getArmyTroopCapacity(0)
		_getArmySpellCapacity(0)
		getArmySiegeCapacity(0)
		GdiDeleteHBitmap($g_hHBitmap2)
		If Not $bDisableTrain And $g_iMyTroopsSize <> 0 Then
			If $bForcePreTrain Then
				If Not $g_bEnablePreTrainTroops Then
					SetLog("Turned ON the Double Train!")
					$g_bEnablePreTrainTroops = True
					$bDisableTDoubleTrain = True
				EndIf
			EndIf
			For $i = 0 To UBound($g_avDTtroopsToBeUsed, 1) - 1
				$g_avDTtroopsToBeUsed[$i][1] = 0
			Next
			For $i = 0 To UBound($MyTroops) - 1
				$g_aiCurrentTroops[$i] = 0
				$g_aiCurrentTroopsOnQ[$i] = 0
				$g_aiCurrentTroopsOnT[$i] = 0
				$g_aiCurrentTroopsReady[$i] = 0
			Next
			$g_abIsQueueEmpty[0] = False
			If Not OpenTroopsTab() Then ExitLoop
			If _Sleep(100) Then ExitLoop
			$iCount2 = 0
			While IsQueueBlockByMsg($iCount2)
				If _Sleep(1000) Then ExitLoop
				$iCount2 += 1
				If $iCount2 >= 30 Then
					SetLog(IsQueueBlockByMsg($iCount2), $COLOR_INFO)
					ExitLoop
				EndIf
			WEnd
			_CaptureRegion2()
			$g_hHBitmapTrainTab = GetHHBitmapArea($g_hHBitmap2)
			getTroopCapacityMini(0)
			If $g_bDebugSetlogTrain Then
				SetLog("$g_aiTroopsMaxCamp: " & $g_aiTroopsMaxCamp[0])
				SetLog("$g_iCmbMyQuickTrain: " & $g_iCmbMyQuickTrain)
			EndIf
			If $g_aiTroopsMaxCamp[0] = 0 Then
				Switch $g_iCmbMyQuickTrain
					Case 0
						DoRevampTroops()
					Case 4
						DoMyQuickTrain(1)
						DoMyQuickTrain(2)
						DoMyQuickTrain(3)
					Case Else
						DoMyQuickTrain($g_iCmbMyQuickTrain)
				EndSwitch
				If $bForcePreTrain Then
					ContinueLoop
				EndIf
			Else
				If _getArmyTroops($g_hHBitmapArmyTab) Then
					If getArmyOnTroops($g_hHBitmapTrainTab) Then
						Local $bPreTrainFlag = $bForcePreTrain
						If $g_bChkForcePreTrainTroops Then
							If $g_iArmyCapacity >= $g_iForcePreTrainStrength Then
								$bPreTrainFlag = True
							EndIf
						EndIf
						Local $iFullArmyCamp = Int(($g_iMyTroopsSize * $g_iTrainArmyFullTroopPct) / 100)
						Select
							Case $g_CurrentCampUtilization = $iFullArmyCamp And $g_aiTroopsMaxCamp[0] = $iFullArmyCamp
								SetDebugLog("[ArmyChecker] Train Case One...")
								If $g_bDebugSetlogTrain Then
									SetLog("$bPreTrainFlag: " & $bPreTrainFlag)
									SetLog("$g_bEnablePreTrainTroops: " & $g_bEnablePreTrainTroops)
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0])
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
								EndIf
								Switch $g_iCmbMyQuickTrain
									Case 0
										If Not $g_bEnablePreTrainTroops Then
											SetLog("Pre-Train Troops Disable.", $COLOR_INFO)
											$g_bDisableTrain = True
										Else
											DoRevampTroops(True)
											If $g_abChkDonateReadyOnly[0] Then $g_abIsQueueEmpty[0] = True
										EndIf
									Case 4
										DoMyQuickTrain(1)
										DoMyQuickTrain(2)
										DoMyQuickTrain(3)
									Case Else
										DoMyQuickTrain($g_iCmbMyQuickTrain)
								EndSwitch
							Case $g_CurrentCampUtilization >= $iFullArmyCamp And $g_aiTroopsMaxCamp[0] > $iFullArmyCamp
								SetDebugLog("[ArmyChecker] Train Case Two...")
								If $g_bDebugSetlogTrain Then
									SetLog("$bPreTrainFlag: " & $bPreTrainFlag)
									SetLog("$g_bEnablePreTrainTroops: " & $g_bEnablePreTrainTroops)
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0])
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
								EndIf
								If Not $g_bEnablePreTrainTroops Then
									SetLog("Pre-Train Troops Disable.", $COLOR_INFO)
									$g_bDisableTrain = True
								Else
									DoRevampTroops(True)
								EndIf
							Case $g_CurrentCampUtilization < $iFullArmyCamp And $g_aiTroopsMaxCamp[0] > $iFullArmyCamp
								SetDebugLog("[ArmyChecker] Train Case Three...")
								If $g_bDebugSetlogTrain Then
									SetLog("$bPreTrainFlag: " & $bPreTrainFlag)
									SetLog("$g_bEnablePreTrainTroops: " & $g_bEnablePreTrainTroops)
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0])
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
								EndIf
								If $bPreTrainFlag Then
									If Not $g_bEnablePreTrainTroops Then
										SetLog("Pre-Train Troops Disable.", $COLOR_INFO)
										$g_bDisableTrain = True
									Else
										DoRevampTroops(True)
									EndIf
								Else
									DoRevampTroops()
								EndIf
							Case $g_CurrentCampUtilization < $iFullArmyCamp And $g_aiTroopsMaxCamp[0] = $iFullArmyCamp
								SetDebugLog("[ArmyChecker] Train Case Four...")
								If $g_bDebugSetlogTrain Then
									SetLog("$bPreTrainFlag: " & $bPreTrainFlag)
									SetLog("$g_bEnablePreTrainTroops: " & $g_bEnablePreTrainTroops)
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0])
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
								EndIf
								If $bPreTrainFlag Then
									Switch $g_iCmbMyQuickTrain
										Case 0
											If Not $g_bEnablePreTrainTroops Then
												SetLog("Pre-Train Troops Disable.", $COLOR_INFO)
												$g_bDisableTrain = True
											Else
												DoRevampTroops(True)
												If $g_abChkDonateReadyOnly[0] Then $g_abIsQueueEmpty[0] = True
											EndIf
										Case 4
											DoMyQuickTrain(1)
											DoMyQuickTrain(2)
											DoMyQuickTrain(3)
										Case Else
											DoMyQuickTrain($g_iCmbMyQuickTrain)
									EndSwitch
								EndIf
							Case $g_CurrentCampUtilization < $iFullArmyCamp And $g_aiTroopsMaxCamp[0] < $iFullArmyCamp
								SetDebugLog("[ArmyChecker] Train Case Five...")
								If $g_bDebugSetlogTrain Then
									SetLog("$bPreTrainFlag: " & $bPreTrainFlag)
									SetLog("$g_bEnablePreTrainTroops: " & $g_bEnablePreTrainTroops)
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0])
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp)
								EndIf
								DoRevampTroops()
								If Not $g_aSkipTrain[$g_iCurAccount] Then ExitLoop
								If $bPreTrainFlag Then
									ContinueLoop
								EndIf
							Case Else
								SetDebugLog("[ArmyChecker] Train Case Else...Line 514")
								SetLog("Error: Cannot meet any condition to revamp Troops.", $COLOR_RED)
								If $g_bDebugSetlogTrain Then
									SetLog("$g_CurrentCampUtilization: " & $g_CurrentCampUtilization, $COLOR_RED)
									SetLog("$iFullArmyCamp: " & $iFullArmyCamp, $COLOR_RED)
									SetLog("$g_aiTroopsMaxCamp[0]: " & $g_aiTroopsMaxCamp[0], $COLOR_RED)
									SetLog("$g_aiTroopsMaxCamp[1]: " & $g_aiTroopsMaxCamp[1], $COLOR_RED)
								EndIf
						EndSelect
						$bTroopCheckOK = True
					Else
						SetDebugLog("[ArmyChecker] getArmyOnTroops error!", $COLOR_WARNING)
						_debugSaveHBitmapToImage($g_hHBitmapTrainTab, "getArmyOnTroops", "getArmyOnTroops")
						SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][0])
					EndIf
				Else
					SetDebugLog("[ArmyChecker] _getArmyTroops error!", $COLOR_WARNING)
					_debugSaveHBitmapToImage($g_hHBitmapArmyTab, "_getArmyTroops", "_getArmyTroops")
					SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][0])
				EndIf
			EndIf
			If $g_bRestartCheckTroop Then ContinueLoop
		Else
			$bTroopCheckOK = True
		EndIf
		GdiDeleteHBitmap($g_hHBitmapTrainTab)
		If Not $g_aSkipTrain[$g_iCurAccount] Then ExitLoop
		If Not $bDisableBrewSpell And $g_iMySpellsSize <> 0 And $g_iTownHallLevel >= 5 Then
			If $bForcePreTrain Then
				If Not $g_bEnablePreTrainSpells Then
					$g_bEnablePreTrainSpells = True
					$bDisableSDoubleTrain = True
				EndIf
			EndIf
			For $i = 0 To UBound($MySpells) - 1
				$g_aiCurrentSpells[$i] = 0
				$g_aiCurrentSpellsOnQ[$i] = 0
				$g_aiCurrentSpellsOnT[$i] = 0
				$g_aiCurrentSpellsReady[$i] = 0
			Next
			$g_abIsQueueEmpty[1] = False
			If OpenSpellsTab() = False Then ExitLoop
			If _Sleep(100) Then ExitLoop
			$iCount2 = 0
			While IsQueueBlockByMsg($iCount2)
				If _Sleep(1000) Then ExitLoop
				$iCount2 += 1
				If $iCount2 >= 30 Then
					SetLog(IsQueueBlockByMsg($iCount2), $COLOR_INFO)
					ExitLoop
				EndIf
			WEnd
			_CaptureRegion2()
			$g_hHBitmapBrewTab = GetHHBitmapArea($g_hHBitmap2)
			_getArmySpellCapacityMini(0)
			If $g_aiSpellsMaxCamp[0] = 0 Then
				If Not DoRevampSpells() Then
					$bDisableBrewSpell = True
					$bSpellCheckOK = True
				EndIf
				If $bForcePreTrain Then
					ContinueLoop
				EndIf
			Else
				If getArmySpells2($g_hHBitmapArmyTab) Then
					If CheckOnBrewUnit($g_hHBitmapBrewTab) Then
						Select
							Case $g_iCurrentSpells >= $g_iMySpellsSize And $g_aiSpellsMaxCamp[0] >= $g_iMySpellsSize
								If Not $g_bEnablePreTrainSpells Then
									SetLog("Pre-Brew Spell Disable.", $COLOR_INFO)
									$g_bDisableBrewSpell = True
								Else
									If Not DoRevampSpells(True, $bForcePreTrain) Then
										$bDisableBrewSpell = True
										$bSpellCheckOK = True
									EndIf
									If $g_abChkDonateReadyOnly[1] Then $g_abIsQueueEmpty[1] = True
								EndIf
							Case $g_iCurrentSpells < $g_iMySpellsSize And $g_aiSpellsMaxCamp[0] >= $g_iMySpellsSize
								If $g_bForcePreBrewSpells Then
									If Not $g_bEnablePreTrainSpells Then
										SetLog("Pre-Brew Spell Disable.", $COLOR_INFO)
										$g_bDisableBrewSpell = True
									Else
										If Not DoRevampSpells(True) Then
											$bDisableBrewSpell = True
											$bSpellCheckOK = True
										EndIf
									EndIf
								EndIf
							Case $g_iCurrentSpells < $g_iMySpellsSize And $g_aiSpellsMaxCamp[0] < $g_iMySpellsSize
								If Not DoRevampSpells() Then
									$bDisableBrewSpell = True
									$bSpellCheckOK = True
								EndIf
								If $g_bForcePreBrewSpells Then
									ContinueLoop
								EndIf
							Case Else
								SetLog("Error: Cannot meet any condition to revamp Spells.", $COLOR_RED)
								If $g_bDebugSetlogTrain Then
									SetLog("$g_iCurrentSpells: " & $g_iCurrentSpells, $COLOR_RED)
									SetLog("$g_iMySpellsSize: " & $g_iMySpellsSize, $COLOR_RED)
									SetLog("$g_aiSpellsMaxCamp[0]: " & $g_aiSpellsMaxCamp[0], $COLOR_RED)
									SetLog("$g_aiSpellsMaxCamp[1]: " & $g_aiSpellsMaxCamp[1], $COLOR_RED)
								EndIf
						EndSelect
						$bSpellCheckOK = True
					Else
						SetDebugLog("[ArmyChecker] getArmyOnSpells error!", $COLOR_WARNING)
						_debugSaveHBitmapToImage($g_hHBitmapBrewTab, "CheckOnBrewUnit", "getArmyOnTroops")
						SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][1])
					EndIf
				Else
					SetDebugLog("[ArmyChecker] getArmyOnSpells error!", $COLOR_WARNING)
					_debugSaveHBitmapToImage($g_hHBitmapArmyTab, "getArmySpells2", "getArmySpells2")
					SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][1])
				EndIf
			EndIf
			If $g_bRestartCheckTroop Then ContinueLoop
		Else
			$bSpellCheckOK = True
		EndIf
		GdiDeleteHBitmap($g_hHBitmapBrewTab)
		If Not $bDisableTrainSieges And $g_iMySiegesSize <> 0 And $g_iTownHallLevel >= 12 Then
			For $i = 0 To UBound($MySieges) - 1
				$g_aiCurrentSiegeMachines[$i] = 0
				$g_aiCurrentSiegeMachinesOnQ[$i] = 0
				$g_aiCurrentSiegeMachinesOnT[$i] = 0
				$g_aiCurrentSiegeMachinesReady[$i] = 0
			Next
			If OpenSiegeMachinesTab() = False Then ExitLoop
			If _Sleep(100) Then ExitLoop
			$iCount2 = 0
			While IsQueueBlockByMsg($iCount2)
				If _Sleep(1000) Then ExitLoop
				$iCount2 += 1
				If $iCount2 >= 30 Then
					SetLog(IsQueueBlockByMsg($iCount2), $COLOR_INFO)
					ExitLoop
				EndIf
			WEnd
			_CaptureRegion2()
			$g_hHBitmapSiegeTab = GetHHBitmapArea($g_hHBitmap2)
			getSiegeMachineCapacityMini(0)
			If $g_aiSiegesMaxCamp[0] = 0 Then
				If Not DoRevampSieges() Then
					$bDisableTrainSieges = True
					$bSiegeCheckOK = True
				EndIf
				If $bForcePreTrain Then
					ContinueLoop
				EndIf
			Else
				If _getArmySiegeMachines($g_hHBitmapArmyTab) Then
					If getArmyOnSiegeMachines($g_hHBitmapSiegeTab) Then
						Local $bPreTrainFlag = $bForcePreTrain
						If $W21543 Then
							$bPreTrainFlag = True
						EndIf
						Select
							Case $g_iCurrentSieges = $g_iMySiegesSize And $g_aiSiegesMaxCamp[0] = $g_iMySiegesSize
								If Not $g_bEnablePreTrainSieges And Not $V21546 Then
									SetLog("Machines Pre-Train Disable.", $COLOR_INFO)
									$g_bDisableSiegeTrain = True
								Else
									If Not DoRevampSieges(True) Then
										$bDisableTrainSieges = True
										$bSiegeCheckOK = True
									EndIf
								EndIf
							Case $g_iCurrentSieges >= $g_iMySiegesSize And $g_aiSiegesMaxCamp[0] > $g_iMySiegesSize
								If Not $g_bEnablePreTrainSieges And Not $V21546 Then
									SetLog("Machines Pre-Train Disable.", $COLOR_INFO)
									$g_bDisableSiegeTrain = True
								Else
									If Not DoRevampSieges(True) Then
										$bDisableTrainSieges = True
										$bSiegeCheckOK = True
									EndIf
								EndIf
							Case $g_iCurrentSieges < $g_iMySiegesSize And $g_aiSiegesMaxCamp[0] > $g_iMySiegesSize
								If $bPreTrainFlag Then
									If Not $g_bEnablePreTrainSieges And Not $V21546 Then
										SetLog("Machines Pre-Train Disable.", $COLOR_INFO)
										$g_bDisableSiegeTrain = True
									Else
										If Not DoRevampSieges(True) Then
											$bDisableTrainSieges = True
											$bSiegeCheckOK = True
										EndIf
									EndIf
								EndIf
							Case $g_iCurrentSieges < $g_iMySiegesSize And $g_aiSiegesMaxCamp[0] = $g_iMySiegesSize
								If $bPreTrainFlag Then
									If Not $g_bEnablePreTrainSieges And Not $V21546 Then
										SetLog("Machines Pre-Train Disable.", $COLOR_INFO)
										$g_bDisableSiegeTrain = True
									Else
										If Not DoRevampSieges(True) Then
											$bDisableTrainSieges = True
											$bSiegeCheckOK = True
										EndIf
									EndIf
								EndIf
							Case $g_iCurrentSieges < $g_iMySiegesSize And $g_aiSiegesMaxCamp[0] < $g_iMySiegesSize
								If Not DoRevampSieges() Then
									$bDisableTrainSieges = True
									$bSiegeCheckOK = True
								EndIf
								If $bPreTrainFlag Then
									ContinueLoop
								EndIf
							Case Else
								SetLog("Error: Cannot meet any condition to revamp Machines.", $COLOR_RED)
								If $g_bDebugSetlogTrain Then
									SetLog("$g_iCurrentSieges: " & $g_iCurrentSieges, $COLOR_RED)
									SetLog("$g_iMySiegesSize: " & $g_iMySiegesSize, $COLOR_RED)
									SetLog("$g_aiSiegesMaxCamp[0]: " & $g_aiSiegesMaxCamp[0], $COLOR_RED)
									SetLog("$g_aiSiegesMaxCamp[1]: " & $g_aiSiegesMaxCamp[1], $COLOR_RED)
								EndIf
						EndSelect
						$bSiegeCheckOK = True
					Else
						SetDebugLog("[ArmyChecker] getArmyOnSiegeMachines error!", $COLOR_WARNING)
						_debugSaveHBitmapToImage($g_hHBitmapSiegeTab, "getArmyOnSiegeMachines", "getArmyOnSiegeMachines")
						SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][2])
					EndIf
				Else
					SetDebugLog("[ArmyChecker] _getArmySiegeMachines error!", $COLOR_WARNING)
					_debugSaveHBitmapToImage($g_hHBitmapArmyTab, "_getArmySiegeMachines", "_getArmySiegeMachines")
					SetDebugLog("[ArmyChecker] How Many errors? " & $g_iTrainSystemErrors[$g_iCurAccount][2])
				EndIf
			EndIf
			If $g_bRestartCheckTroop Then ContinueLoop
		Else
			$bSiegeCheckOK = True
		EndIf
		GdiDeleteHBitmap($g_hHBitmapSiegeTab)
		If $g_bDebugSetlogTrain Then SetLog("$bTroopCheckOK: " & $bTroopCheckOK & " - $bSpellCheckOK: " & $bSpellCheckOK & " - $bSiegeCheckOK: " & $bSiegeCheckOK)
		If $bTroopCheckOK And $bSpellCheckOK And $bSiegeCheckOK Then ExitLoop
	WEnd
	DeleteTrainHBitmap()
	If $g_bDebugSetlogTrain Then SetLog("$hTimer: " & Round(__TimerDiff($hTimer) / 1000, 2))
	If Not $g_aSkipTrain[$g_iCurAccount] Then Return
	If $bForcePreTrain Then
		SetLog("Turned OFF the Double Train!")
		If $bDisableTDoubleTrain Then
			$g_bEnablePreTrainTroops = False
			$bDisableTDoubleTrain = False
		EndIf
		If $bDisableSDoubleTrain Then
			$g_bEnablePreTrainSpells = False
			$bDisableSDoubleTrain = False
		EndIf
	EndIf
EndFunc   ;==>ArmyChecker

Func IsQueueBlockByMsg($iCount)
	ForceCaptureRegion()
	_CaptureRegion()

	Select
		; Msg: Troops removed
		Case _ColorCheck(_GetPixelColor(391, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(487, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6)
			Return SetLogAndReturn(1)

		; Msg: Spells removed
		Case _ColorCheck(_GetPixelColor(392, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(458, 209, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6)
			Return SetLogAndReturn(2)

		; Msg: Gold storages full (red text)
		Case _ColorCheck(_GetPixelColor(242, 209, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6) And _ColorCheck(_GetPixelColor(317, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6)
			Return SetLogAndReturn(3)

		; Msg: Elixir storages full (red text)
		Case _ColorCheck(_GetPixelColor(318, 213, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6) And _ColorCheck(_GetPixelColor(391, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6)
			Return SetLogAndReturn(4)

		; Msg: Dark Elixir storages full (red text)
		Case _ColorCheck(_GetPixelColor(168, 214, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6) And _ColorCheck(_GetPixelColor(242, 214, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6)
			Return SetLogAndReturn(5)

		; Msg: The request was sent!
		Case _ColorCheck(_GetPixelColor(316, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(462, 209, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6)
			Return SetLogAndReturn(6)

		; Msg: Army added to training queues!
		Case _ColorCheck(_GetPixelColor(324, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(460, 209, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6)
			Return SetLogAndReturn(7)

		; Msg: Not enough space in training queues (red text)
		Case _ColorCheck(_GetPixelColor(258, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6) And _ColorCheck(_GetPixelColor(485, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6)
			Return SetLogAndReturn(8)

		; Msg: Not enough storage space (red text)
		Case _ColorCheck(_GetPixelColor(319, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6) And _ColorCheck(_GetPixelColor(537, 215, $g_bNoCapturePixel), Hex(0xFF1919, 6), 6)
			Return SetLogAndReturn(9)

		; Msg: Shield
		Case _ColorCheck(_GetPixelColor(167, 193, $g_bNoCapturePixel), Hex(0xff1919, 6), 6) And _ColorCheck(_GetPixelColor(285, 211, $g_bNoCapturePixel), Hex(0xff1919, 6), 6)
			Return SetLogAndReturn(10)

		; donate message
;~ 		Case _ColorCheck(_GetPixelColor(245, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(301 + 44, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor(360, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6)
;~ 			Return SetLogAndReturn(99)
		Case Else
			For $i = 130 To 330 Step + 2
				If _ColorCheck(_GetPixelColor($i, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) And _ColorCheck(_GetPixelColor($i + 42, 215, $g_bNoCapturePixel), Hex(0xFEFEFE, 6), 6) Then
					If $iCount = 0 And ($g_bChkWait4CC Or $g_bChkWait4CCSpell Or $g_bChkWait4CCSiege) Then
						Local $hClone = _GDIPlus_BitmapCloneArea($g_hBitmap, 20, 198, 820, 24, $GDIP_PXF24RGB)
						Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
						Local $Time = @HOUR & "." & @MIN & "." & @SEC
						Local $Filename = String($g_sProfileTempDebugPath & "Msg Block_" & $date & "_" & $Time & ".png")
						_GDIPlus_ImageSaveToFile($hClone, $filename)
						_GDIPlus_BitmapDispose($hClone)
					EndIf
					Return SetLogAndReturn(99)
				EndIf
			Next
	EndSelect
	If _Sleep(1000) Then Return	False
	Return False
EndFunc

Func IsSearchModeActive($g_iMatchMode, $nocheckHeroes = False, $A6453 = True)
	Local $bMatchModeEnabled = False
	Switch $g_iMatchMode
		Case $DB
			$bMatchModeEnabled = $g_abAttackTypeEnable[$DB]
		Case $LB
			$bMatchModeEnabled = $g_abAttackTypeEnable[$LB]
		Case Else
			$bMatchModeEnabled = False
	EndSwitch
	If $bMatchModeEnabled = False Then Return False
	Local $currentCCCampsFull = $Q21867 >= $Y21870
	Local $checkCCTroops = ($g_bFullCCTroops And $g_bChkWait4CC) Or ($currentCCCampsFull And $g_bChkWait4CC) Or Not $g_bChkWait4CC
	Local $checkCCSpells = $g_bChkWait4CCSpell Or ($g_bFullCCSpells And $g_bChkWait4CCSpell)
	Local $checkCCSieges = $g_bChkWait4CCSiege Or ($g_bFullCCSiegeMachine And $g_bChkWait4CCSiege)
	Local $currentSearch = $g_iSearchCount + 1
	Local $currentTropies = $g_aiCurrentLoot[$eLootTrophy]
	Local $currentArmyCamps = Int($g_CurrentCampUtilization / $g_iTotalCampSpace * 100)
	Local $checkSearches = Int($currentSearch) >= Int($g_aiSearchSearchesMin[$g_iMatchMode]) And Int($currentSearch) <= Int($g_aiSearchSearchesMax[$g_iMatchMode]) And $g_abSearchSearchesEnable[$g_iMatchMode]
	Local $checkTropies = Int($currentTropies) >= Int($g_aiSearchTrophiesMin[$g_iMatchMode]) And Int($currentTropies) <= Int($g_aiSearchTrophiesMax[$g_iMatchMode]) And $g_abSearchTropiesEnable[$g_iMatchMode]
	Local $checkArmyCamps = Int($currentArmyCamps) >= Int($g_aiSearchCampsPct[$g_iMatchMode]) And $g_abSearchCampsEnable[$g_iMatchMode]
	Local $checkHeroes = Not ($g_aiSearchHeroWaitEnable[$g_iMatchMode] > $eHeroNone And (BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $g_aiSearchHeroWaitEnable[$g_iMatchMode], $g_iHeroAvailable) = $g_aiSearchHeroWaitEnable[$g_iMatchMode]) = False) Or $nocheckHeroes
	Local $TotalSpellsToBrew = 0
	Local $totalAvailableSpell = 0
	For $i = 0 To $eSpellCount - 1
		$TotalSpellsToBrew += $MySpells[$i][3] * $MySpells[$i][2]
		$totalAvailableSpell += $g_aiCurrentSpells[$i]
	Next
	Local $bCheckSpells = False
	If $totalAvailableSpell = $TotalSpellsToBrew And $g_abSearchSpellsWaitEnable[$g_iMatchMode] Then
		$bCheckSpells = True
	ElseIf $g_bFullArmySpells And $g_abSearchSpellsWaitEnable[$g_iMatchMode] Then
		$bCheckSpells = True
	ElseIf $g_abSearchSpellsWaitEnable[$g_iMatchMode] = False Then
		$bCheckSpells = True
	Else
		$bCheckSpells = False
	EndIf
	Local $bCheckSiege = False
	If $g_bFullArmySieges And $g_abSearchSiegeWaitEnable[$g_iMatchMode] Then
		$bCheckSiege = True
	ElseIf $g_abSearchSiegeWaitEnable[$g_iMatchMode] Then
		If (($g_aiAttackUseSiege[$g_iMatchMode] = 1 And ($g_aiCurrentSiegeMachines[$eSiegeWallWrecker] > 0 Or $g_aiCurrentCCSiegeMachines[$eSiegeWallWrecker] > 0)) Or ($g_aiAttackUseSiege[$g_iMatchMode] = 2 And ($g_aiCurrentSiegeMachines[$eSiegeBattleBlimp] > 0 Or $g_aiCurrentCCSiegeMachines[$eSiegeBattleBlimp] > 0)) Or ($g_aiAttackUseSiege[$g_iMatchMode] = 3 And ($g_aiCurrentSiegeMachines[$eSiegeStoneSlammer] > 0 Or $g_aiCurrentCCSiegeMachines[$eSiegeStoneSlammer] > 0)) Or ($g_aiAttackUseSiege[$g_iMatchMode] = 4 And ($g_aiCurrentSiegeMachines[$eSiegeBarracks] > 0 Or $g_aiCurrentCCSiegeMachines[$eSiegeBarracks] > 0)) Or ($g_aiAttackUseSiege[$g_iMatchMode] = 5 And ($g_aiCurrentSiegeMachines[$eSiegeLogLauncher] > 0 Or $g_aiCurrentCCSiegeMachines[$eSiegeLogLauncher] > 0)) Or $g_aiAttackUseSiege[$g_iMatchMode] = 0) Then
			$bCheckSiege = True
		EndIf
	Else
		$bCheckSiege = True
	EndIf
	If $checkHeroes And $bCheckSpells And $checkCCTroops And $bCheckSiege Then
		If ($checkSearches Or $g_abSearchSearchesEnable[$g_iMatchMode] = False) And ($checkTropies Or $g_abSearchTropiesEnable[$g_iMatchMode] = False) And ($checkArmyCamps Or $g_abSearchCampsEnable[$g_iMatchMode] = False) Then
			If $g_bDebugSetlog And $A6453 Then SetLog($g_asModeText[$g_iMatchMode] & " active! ($checkSearches=" & $checkSearches & ",$checkTropies=" & $checkTropies & ",$checkArmyCamps=" & $checkArmyCamps & ",$checkHeroes=" & $checkHeroes & ",$bCheckSpells=" & $bCheckSpells & ",$bCheckSiege=" & $bCheckSiege & ")", $COLOR_INFO)
			Return True
		Else
			If $g_bDebugSetlog And $A6453 Then
				SetLog($g_asModeText[$g_iMatchMode] & " not active!", $COLOR_INFO)
				Local $txtsearches = "Fail"
				If $checkSearches Then $txtsearches = "Success"
				Local $txttropies = "Fail"
				If $checkTropies Then $txttropies = "Success"
				Local $txtArmyCamp = "Fail"
				If $checkArmyCamps Then $txtArmyCamp = "Success"
				Local $txtHeroes = "Fail"
				If $checkHeroes Then $txtHeroes = "Success"
				If $g_abSearchSearchesEnable[$g_iMatchMode] Then SetLog("Searches range: " & $g_aiSearchSearchesMin[$g_iMatchMode] & "-" & $g_aiSearchSearchesMax[$g_iMatchMode] & "  actual value: " & $currentSearch & " - " & $txtsearches, $COLOR_INFO)
				If $g_abSearchTropiesEnable[$g_iMatchMode] Then SetLog("Tropies range: " & $g_aiSearchTrophiesMin[$g_iMatchMode] & "-" & $g_aiSearchTrophiesMax[$g_iMatchMode] & "  actual value: " & $currentTropies & " | " & $txttropies, $COLOR_INFO)
				If $g_abSearchCampsEnable[$g_iMatchMode] Then SetLog("Army camps % range >=: " & $g_aiSearchCampsPct[$g_iMatchMode] & " actual value: " & $currentArmyCamps & " | " & $txtArmyCamp, $COLOR_INFO)
				If $g_aiSearchHeroWaitEnable[$g_iMatchMode] > $eHeroNone Then SetLog("Hero status " & BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $g_aiSearchHeroWaitEnable[$g_iMatchMode], $g_iHeroAvailable) & " " & $g_iHeroAvailable & " | " & $txtHeroes, $COLOR_INFO)
				Local $txtSpells = "Fail"
				If $bCheckSpells Then $txtSpells = "Success"
				If $g_abSearchSpellsWaitEnable[$g_iMatchMode] Then SetLog("Full spell status: " & $g_bFullArmySpells & " | " & $txtSpells, $COLOR_INFO)
				Local $txtSieges = $bCheckSiege = True ? "Success" : "Fail"
				If $g_abSearchSiegeWaitEnable[$g_iMatchMode] Then SetLog("Full Siege Machines Status: " & $g_bFullArmySieges & " | " & $txtSieges, $COLOR_INFO)
			EndIf
			Return False
		EndIf
	Else
		If $g_bDebugSetlog And $A6453 Then
			SetDebugLog("Settings Of : " & $g_asModeText[$g_iMatchMode], $COLOR_INFO)
			SetDebugLog("ArmyCamps Condition: " & $checkArmyCamps, $COLOR_INFO)
			SetDebugLog("Spell Condition: " & $bCheckSpells, $COLOR_INFO)
			SetDebugLog("Siege Machine Condition: " & $bCheckSiege, $COLOR_INFO)
			SetDebugLog("CC Troops Condition: " & $checkCCTroops, $COLOR_INFO)
			SetDebugLog("CC Spells Condition: " & $checkCCSpells, $COLOR_INFO)
			SetDebugLog("CC Siege Machine Condition: " & $checkCCSieges, $COLOR_INFO)
			SetDebugLog("Heroes Condition: " & $checkHeroes, $COLOR_INFO)
			SetDebugLog("----------------------------------", $COLOR_INFO)
		EndIf
		Return False
	EndIf
EndFunc   ;==>IsSearchModeActive

Func SetLogAndReturn($iMsg)
	Local $sMsg
	Switch $iMsg
		Case 1
			$sMsg = "Troops removed"
		Case 2
			$sMsg = "Spells removed"
		Case 3
			$sMsg = "Gold Storages Full"
		Case 4
			$sMsg = "Elixir Storages Full"
		Case 5
			$sMsg = "Dark Elixir Storages Full"
		Case 6
			$sMsg = "The request was sent!"
		Case 7
			$sMsg = "Army added to training queues!"
		Case 8
			$sMsg = "Not enough space in training queues"
		Case 9
			$sMsg = "Not enough storage space"
		Case 10
			$sMsg = "You have been without shield too long."
		Case Else
			$sMsg = "Donate or other message"
	EndSwitch
	If $g_bDebugSetlog Or $g_bDebugSetlogTrain Then SetLog("[" & $sMsg & "] - block for detection troops or spells.",$COLOR_RED)
	Return True
EndFunc

Func Q23724($I23727 = "")
	If $I23727 = "troops" Or $I23727 = "all" Then
		For $i = 0 To $eTroopCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentTroops[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
	EndIf
	If $I23727 = "Spells" Or $I23727 = "all" Then
		For $i = 0 To $eSpellCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentSpells[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
	EndIf
	If $I23727 = "SiegeMachines" Or $I23727 = "all" Then
		For $i = 0 To $eSiegeMachineCount - 1
			If Not $g_bRunState Then Return
			$g_aiCurrentSiegeMachines[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
	EndIf
	If $I23727 = "donated" Or $I23727 = "all" Then
		For $i = 0 To $eTroopCount - 1
			If Not $g_bRunState Then Return
			$g_aiDonateTroops[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
		For $i = 0 To $eSpellCount - 1
			If Not $g_bRunState Then Return
			$g_aiDonateSpells[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
		For $i = 0 To $eSiegeMachineCount - 1
			If Not $g_bRunState Then Return
			$g_aiDonateSiegeMachines[$i] = 0
			If _Sleep($DELAYTRAIN6) Then Return
		Next
	EndIf
EndFunc   ;==>Q23724

Func TrainSystemStatus()
	Local $aTempArmyWindowStatus
	Local $bStopTrainSystem = False
	Local $sArmyWindowDiamond = GetDiamondFromRect("21,241,380,294")
	Local $aArmyWindowStatus = findMultiple(@ScriptDir & "\imgxml\ArmyOverview\Status", $sArmyWindowDiamond, $sArmyWindowDiamond, 0, 1000, 0, "objectname,objectpoints", True)
	Static $UpgradingSpells[8] = [False, False, False, False, False, False, False, False]
	Static $UpgradingSieges[8] = [False, False, False, False, False, False, False, False]
	Static $abDisableBrewSpell[8] = [-1, -1, -1, -1, -1, -1, -1, -1]
	Static $abDisableSiegeTrain[8] = [-1, -1, -1, -1, -1, -1, -1, -1]
	If _Sleep(100) Then Return
	If UBound($aArmyWindowStatus, 1) >= 1 Then
		For $i = 0 To UBound($aArmyWindowStatus, 1) - 1
			$aTempArmyWindowStatus = $aArmyWindowStatus[$i]
			If $aTempArmyWindowStatus[0] = "Barracks" Then
				Local $X15288, $tempObbj, $tempObbjs, $iHowManyUpg, $iHowManyYouHave = 4
				Local $StringCoordinates = $aTempArmyWindowStatus[1]
				If StringInStr($StringCoordinates, "|") Then
					$StringCoordinates = StringReplace($StringCoordinates, "||", "|")
					$X15288 = StringRight($StringCoordinates, 1)
					If $X15288 = "|" Then $StringCoordinates = StringTrimRight($StringCoordinates, 1)
					$tempObbjs = StringSplit($StringCoordinates, "|", $STR_NOCOUNT)
					$iHowManyUpg = UBound($tempObbjs)
				Else
					$iHowManyUpg = 1
				EndIf
				SetLog("You have " & $iHowManyUpg & " Barracks in upgrade.")
				If $g_iTownHallLevel >= 7 Then
					$iHowManyYouHave = 4
				ElseIf $g_iTownHallLevel < 7 And $g_iTownHallLevel > 3 Then
					$iHowManyYouHave = 3
				Else
					$iHowManyYouHave = 2
				EndIf
				If $iHowManyUpg >= $iHowManyYouHave Then
					For $i = $eTroopBarbarian To $eTroopSuperWizard
						If $MyTroops[$i][3] <> 0 Then
							SetLog("All Barracks Upgrading... Review your Settings!")
							$bStopTrainSystem = True
						EndIf
					Next
				EndIf
			ElseIf $aTempArmyWindowStatus[0] = "DarkBarracks" Then
				Local $X15288, $tempObbj, $tempObbjs, $iHowManyUpg, $iHowManyYouHave = 2
				Local $StringCoordinates = $aTempArmyWindowStatus[1]
				If StringInStr($StringCoordinates, "|") Then
					$StringCoordinates = StringReplace($StringCoordinates, "||", "|")
					$X15288 = StringRight($StringCoordinates, 1)
					If $X15288 = "|" Then $StringCoordinates = StringTrimRight($StringCoordinates, 1)
					$tempObbjs = StringSplit($StringCoordinates, "|", $STR_NOCOUNT)
					$iHowManyUpg = UBound($tempObbjs)
				Else
					$iHowManyUpg = 1
				EndIf
				SetLog("You have " & $iHowManyUpg & " dark Barracks in upgrade.")
				If $g_iTownHallLevel >= 8 Then
					$iHowManyYouHave = 2
				ElseIf $g_iTownHallLevel < 8 And $g_iTownHallLevel > 6 Then
					$iHowManyYouHave = 1
				Else
					$iHowManyYouHave = 0
				EndIf
				If $iHowManyUpg >= $iHowManyYouHave Then
					For $i = $eTroopMinion To $eTroopIceHound
						If $MyTroops[$i][3] <> 0 Then
							SetLog("All Dark Barracks Upgrading... Review your Settings!", $COLOR_ERROR)
							$bStopTrainSystem = True
						EndIf
					Next
				EndIf
			ElseIf $aTempArmyWindowStatus[0] = "SpellFactory" Then
				For $i = $eSpellLightning To $eSpellClone
					If $MySpells[$i][3] <> 0 Then
						If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
							SetLog("Spell Factory Upgrading... Review your Settings!", $COLOR_ERROR)
							$bStopTrainSystem = True
						Else
							For $match = $DB To $LB
								If $g_iMatchMode = $match And $g_abSearchSpellsWaitEnable[$match] Then
									$g_abSearchSpellsWaitEnable[$match] = False
									If $match = $DB Then GUICtrlSetState($g_hChkDBSpellsWait, $g_abSearchSpellsWaitEnable[$match])
									If $match = $LB Then GUICtrlSetState($g_hChkABSpellsWait, $g_abSearchSpellsWaitEnable[$match])
									SetLog($g_asModeText[$match] & "... Wait for Spells Turned Off!", $COLOR_ERROR)
									$abDisableBrewSpell[$g_iCurAccount] = $g_bDisableBrewSpell
									$g_bDisableBrewSpell = True
									$UpgradingSpells[$g_iCurAccount] = True
								ElseIf $g_iMatchMode = $DB And Not $g_abSearchSpellsWaitEnable[$match] Then
									$abDisableBrewSpell[$g_iCurAccount] = $g_bDisableBrewSpell
									$g_bDisableBrewSpell = True
									$UpgradingSpells[$g_iCurAccount] = True
									SetLog("Spell Factory is upgrading, Spells will be turnOFF", $COLOR_ERROR)
								EndIf
							Next
						EndIf
					EndIf
				Next
			ElseIf $aTempArmyWindowStatus[0] = "DarkSpellFactory" Then
				For $i = $eSpellPoison To $eSpellBat
					If $MySpells[$i][3] <> 0 Then
						If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
							SetLog("Dark Spell Factory Upgrading... Review your Settings!", $COLOR_ERROR)
							$bStopTrainSystem = True
						Else
							For $match = $DB To $LB
								If $g_iMatchMode = $match And $g_abSearchSpellsWaitEnable[$match] Then
									$g_abSearchSpellsWaitEnable[$match] = False
									If $match = $DB Then GUICtrlSetState($g_hChkDBSpellsWait, $g_abSearchSpellsWaitEnable[$match])
									If $match = $LB Then GUICtrlSetState($g_hChkABSpellsWait, $g_abSearchSpellsWaitEnable[$match])
									SetLog($g_asModeText[$match] & "... Wait for Spells Turned Off!", $COLOR_ERROR)
									$abDisableBrewSpell[$g_iCurAccount] = $g_bDisableBrewSpell
									$g_bDisableBrewSpell = True
									$UpgradingSpells[$g_iCurAccount] = True
								ElseIf $g_iMatchMode = $DB And Not $g_abSearchSpellsWaitEnable[$match] Then
									$abDisableBrewSpell[$g_iCurAccount] = $g_bDisableBrewSpell
									$g_bDisableBrewSpell = True
									$UpgradingSpells[$g_iCurAccount] = True
									SetLog("Spell Factory is upgrading, Spells will be turnOFF", $COLOR_ERROR)
								EndIf
							Next
						EndIf
					EndIf
				Next
			ElseIf $aTempArmyWindowStatus[0] = "Workshop" Then
				For $i = 0 To UBound($MySieges) - 1
					If $MySieges[$i][3] <> 0 Then
						If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
							SetLog("Workshop Factory Upgrading... Review your Settings!", $COLOR_ERROR)
							$bStopTrainSystem = True
						Else
							For $match = $DB To $LB
								If $g_iMatchMode = $match And $g_abSearchSiegeWaitEnable[$match] Then
									$g_abSearchSiegeWaitEnable[$match] = False
									If $match = $DB Then GUICtrlSetState($g_hChkDBSiegeWait, $g_abSearchSiegeWaitEnable[$match])
									If $match = $LB Then GUICtrlSetState($g_hChkABSiegeWait, $g_abSearchSiegeWaitEnable[$match])
									SetLog($g_asModeText[$match] & "... Wait for Sieges Turned Off!", $COLOR_ERROR)
									$abDisableSiegeTrain[$g_iCurAccount] = $g_bDisableSiegeTrain
									$g_bDisableSiegeTrain = True
									$UpgradingSieges[$g_iCurAccount] = True
								ElseIf $g_iMatchMode = $DB And Not $g_abSearchSiegeWaitEnable[$match] Then
									$abDisableSiegeTrain[$g_iCurAccount] = $g_bDisableSiegeTrain
									$g_bDisableSiegeTrain = True
									$UpgradingSieges[$g_iCurAccount] = True
									SetLog("WorkShop is upgrading, Sieges will be turnOFF", $COLOR_ERROR)
								EndIf
							Next
						EndIf
					EndIf
				Next
			EndIf
		Next
	Else
		If $abDisableBrewSpell[$g_iCurAccount] = -1 Then $abDisableBrewSpell[$g_iCurAccount] = $g_bDisableBrewSpell
		If $abDisableSiegeTrain[$g_iCurAccount] = -1 Then $abDisableSiegeTrain[$g_iCurAccount] = $g_bDisableSiegeTrain
		If $UpgradingSpells[$g_iCurAccount] Then $g_bDisableBrewSpell = $abDisableBrewSpell[$g_iCurAccount]
		If $UpgradingSieges[$g_iCurAccount] Then $g_bDisableSiegeTrain = $abDisableSiegeTrain[$g_iCurAccount]
		If $g_bDebugSetlogTrain Then
			SetDebugLog("[TrainSystemStatus] $abDisableBrewSpell[$g_iCurAccount]: " & $abDisableBrewSpell[$g_iCurAccount])
			SetDebugLog("[TrainSystemStatus] $abDisableSiegeTrain[$g_iCurAccount] : " & $abDisableSiegeTrain[$g_iCurAccount])
			SetDebugLog("[TrainSystemStatus] $UpgradingSpells[$g_iCurAccount]: " & $UpgradingSpells[$g_iCurAccount])
			SetDebugLog("[TrainSystemStatus] $UpgradingSieges[$g_iCurAccount]: " & $UpgradingSieges[$g_iCurAccount])
		EndIf
	EndIf
	If $bStopTrainSystem Then
		If IsDeclared("g_iTownHallLevel") Then SetDebugLog("[TrainSystemStatus] $g_iTownHallLevel: " & $g_iTownHallLevel)
		If IsDeclared("aTempArmyWindowStatus") And IsArray($aTempArmyWindowStatus) Then SetDebugLog("[TrainSystemStatus] $aTempArmyWindowStatus: " & _ArrayToString($aTempArmyWindowStatus))
		If IsDeclared("StringCoordinates") And IsArray($StringCoordinates) Then SetDebugLog("[TrainSystemStatus] $StringCoordinates: " & _ArrayToString($StringCoordinates))
	EndIf
	Return $bStopTrainSystem
EndFunc   ;==>TrainSystemStatus

Func IsTrainSystemOK()
	If TrainSystemStatus() Then
		If ProfileSwitchAccountEnabled() Then
			$g_aSkipTrain[$g_iCurAccount] = False
			Return False
		Else
			btnStop()
			Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>IsTrainSystemOK

Func MyTrainClick($Troop, $bIsSpell = False, $bIsSiege = False)
	If IsTrainPage() Then
		Local $aRegionForScan[4] = [26, 365+44, 840, 492+44]
		Local $aButtonXY
		Local $sRegionForScan
		Local $bDragIfNeeded = False
		Local $sDirectory
		If $bIsSpell Then
			$sDirectory = $g_sImgTrainSpells_
			$sRegionForScan = "Spells"
		ElseIf $bIsSiege Then
			$sDirectory = $g_sImgTrainSieges
			$sRegionForScan = "Sieges"
			Local $aRegionForScan[4] = [0, 357+44, 825, 357 + 82+44]
		Else
			$sDirectory = $g_sImgTrainTroops_
			$sRegionForScan = "Troops"
			$bDragIfNeeded = True
		EndIf
		If $bDragIfNeeded Then
			If Not DragIfNeeded($Troop) Then
				Return False
			EndIf
		EndIf
		If _Sleep(1000) Then Return False
		_CaptureRegion2($aRegionForScan[0], $aRegionForScan[1], $aRegionForScan[2], $aRegionForScan[3])
		Local $aFileToScan = _FileListToArrayRec($sDirectory, $Troop & "*.*", $FLTAR_FILES, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
		If UBound($aFileToScan) > 1 Then
			For $i = 1 To UBound($aFileToScan) - 1
				If $g_bDebugSetlogTrain Then SetLog("$aFileToScan[" & $i & "]: " & $aFileToScan[$i])
				If StringInStr($aFileToScan[$i], $Troop) Then
					Local $result = FindImageInPlace($Troop, $sDirectory & "\" & $aFileToScan[$i], "0,0," & $aRegionForScan[2] - $aRegionForScan[0] & "," & $aRegionForScan[3] - $aRegionForScan[1], False)
					If StringInStr($result, ",") > 0 Then
						$aButtonXY = StringSplit($result, ",", $STR_NOCOUNT)
						ExitLoop
					EndIf
				EndIf
			Next
		Else
			SetLog("Cannot find image file " & $Troop & " for scan", $COLOR_ERROR)
			Return False
		EndIf
		_debugSaveHBitmapToImage($g_hHBitmap2, "RegionForScan" & $sRegionForScan, "RegionForScan")
		GdiDeleteHBitmap($g_hHBitmap2)
		If IsArray($aButtonXY) Then
			$g_iTroopButtonX = $aRegionForScan[0] + $aButtonXY[0]
			$g_iTroopButtonY = $aRegionForScan[1] + $aButtonXY[1]
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>MyTrainClick

Func _TrainClick($x, $y, $iTimes = 1, $iSpeed = 0, $sDebugTxt = "")
	If IsTrainPage() Then
		Local $iClickMin = 7, $iClickMax = 14, $isldClickDelayTime = 400
		Local $iRandNum = Random($iClickMin - 1, $iClickMax - 1, 1)
		Local $iRandX = Random($x - 5, $x + 5, 1)
		Local $iRandY = Random($y - 5, $y + 5, 1)
		If isProblemAffect(True) Then Return
		For $i = 0 To ($iTimes - 1)
			PureClick(Random($iRandX - 2, $iRandX + 2, 1), Random($iRandY - 2, $iRandY + 2, 1))
			If $i >= $iRandNum Then
				$iRandNum = $iRandNum + Random($iClickMin, $iClickMax, 1)
				$iRandX = Random($x - 5, $x + 5, 1)
				$iRandY = Random($y - 5, $y + 5, 1)
				If _Sleep(Random(($isldClickDelayTime * 90) / 100, ($isldClickDelayTime * 110) / 100, 1), False) Then ExitLoop
			Else
				If _Sleep(Random(($iSpeed * 90) / 100, ($iSpeed * 110) / 100, 1), False) Then ExitLoop
			EndIf
		Next
	EndIf
EndFunc   ;==>_TrainClick

Func RemoveAllTroopAlreadyTrain()
	If $g_bDebugSetlogTrain Then SetLog("====Start Delete Troops====", $COLOR_DEBUG)
	Local $iRanX = Random(817, 829, 1)
	Local $iRanY = Random(166 + $g_iMidOffsetY, 177 + $g_iMidOffsetY, 1)
	Local $iRanX2 = Random(746, 758, 1)
	Local $iRanX3 = Random(677, 688, 1)
	Local $iRanX4 = Random(606, 616, 1)
	Local $iCount = 0
	ForceCaptureRegion()
	While Not _ColorCheck(_GetPixelColor(823, 175 + $g_iMidOffsetY, True), Hex(0xCFCFC8, 6), 20)
		If isProblemAffectBeforeClick($iCount) Then ExitLoop
		Local $iRanTime = Random(8, 12, 1)
		For $i = 0 To $iRanTime
			PureClick(Random($iRanX - 2, $iRanX + 2, 1), Random($iRanY - 2, $iRanY + 2, 1), 1, 0, "#0702")
			PureClick(Random($iRanX2 - 2, $iRanX2 + 2, 1), Random($iRanY - 2, $iRanY + 2, 1), 1, 0, "#0702")
			PureClick(Random($iRanX3 - 2, $iRanX3 + 2, 1), Random($iRanY - 2, $iRanY + 2, 1), 1, 0, "#0702")
			PureClick(Random($iRanX4 - 2, $iRanX4 + 2, 1), Random($iRanY - 2, $iRanY + 2, 1), 1, 0, "#0702")
			If _Sleep(Random(($g_iTrainClickDelay * 90) / 100, ($g_iTrainClickDelay * 110) / 100, 1), False) Then ExitLoop
		Next
		$iCount += 1
		If $iCount > 30 Then ExitLoop
	WEnd
	For $i = 0 To UBound($MyTroops) - 1
		$g_aiCurrentTroopsOnQ[$i] = 0
	Next
	For $i = 0 To UBound($MyTroops) - 1
		$g_aiCurrentTroopsOnT[$i] = 0
	Next
	If $g_bDebugSetlogTrain Then SetLog("====Ended Delete Troops====", $COLOR_DEBUG)
EndFunc   ;==>RemoveAllTroopAlreadyTrain

Func RemoveAllPreTrainTroops()
	Local $bExipLoop = False
	Local $iLoopCount = 0
	Local $iRandX[11] = [False, False, False, False, False, False, False, False, False, False, False]
	While $bExipLoop = False
		_CaptureRegion()
		For $i = 0 To 10
			$iRandX[$i] = False
		Next
		Local $bStillNeedRemove = False
		For $i = 0 To 10
			If _ColorCheck(_GetPixelColor(120 + ($i * 70.5), 157 + $g_iMidOffsetY, False), Hex(0xD7AFA9, 6), 10) Then
				$iRandX[$i] = True
				$bStillNeedRemove = True
			EndIf
		Next
		If $bStillNeedRemove Then
			Local $iRanTime = Random(8, 12, 1)
			For $j = 0 To $iRanTime
				For $i = 0 To 10
					If $iRandX[$i] Then
						PureClick(Random(120 + ($i * 70.5) - 2, 120 + ($i * 70.5) + 2, 1), Random(156 + 44, 160 + 44, 1), 1, 0, "#0702")
					EndIf
				Next
				If _Sleep(Random(($g_iTrainClickDelay * 90) / 100, ($g_iTrainClickDelay * 110) / 100, 1), False) Then ExitLoop
			Next
		Else
			$bExipLoop = True
		EndIf
		$iLoopCount += 1
		If $iLoopCount > 30 Then ExitLoop
	WEnd
	For $i = 0 To UBound($MyTroops) - 1
		$g_aiCurrentTroopsOnQ[$i] = 0
	Next
EndFunc   ;==>RemoveAllPreTrainTroops

Func RemoveOnTItem($i, $iCount, $iOffsetSlot = 0, $sItem = "Troops")
	Local $iLoopCount = 0
	If $sItem = "Spells" Or $sItem = "Sieges" Then $iOffsetSlot += 58
	While $iLoopCount < $iCount
		Switch $sItem
			Case "Troops"
				PureClick(Random(118 + ($i * 70.5) - 2, 118 + ($i * 70.5) + 2, 1), Random(156 + 44, 160 + 44, 1), 1, 0, "#RTS")
			Case "CCtroops"
				PureClick(Random(80 + ($i * 74) - 2, 80 + ($i * 74) + 2, 1), Random(527 + 44, 531 + 44, 1), 1, 0, "#RTS")
			Case "Spells", "Sieges"
				PureClick(Random($iOffsetSlot + ($i * 74) - 2, $iOffsetSlot + ($i * 74) + 2, 1), Random(527 + 44, 531 + 44, 1), 1, 0, "#RTS")
		EndSwitch
		If _Sleep(Random(($g_iTrainClickDelay * 90) / 100, ($g_iTrainClickDelay * 110) / 100, 1), False) Then ExitLoop
		$iLoopCount += 1
	WEnd
EndFunc   ;==>RemoveOnTItem

Func _getArmyCCSpells()
	If $g_bDebugSetlogTrain Then SetLog("_getArmyCCSpells():", $COLOR_DEBUG)
	If Int($g_iTownHallLevel) < 3 Then Return
	SetLog("Check Clan Castle Spells", $COLOR_INFO)
	Local $iCount = 0
	Local $aiCurrentCCSpellsRemove[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	While 1
		$iCount += 1
		If $iCount > 3 Then ExitLoop
		Local $aiSpellsInfo[2][3]
		Local $sDirectory = $g_sImgArmyOverviewCCSpells
		Local $returnProps = "objectname"
		Local $aPropsValues
		Local $bDeletedExcess = False
		Local $iOffsetSlot = 0
		Local $iSpellsCount = 0
		Local $iSpellIndex = -1
		If _Sleep(250) Then ExitLoop
		If $g_bRunState = False Then Return
		GdiDeleteHBitmap($g_hHBitmap2)
		_CaptureRegion2()
		For $i = 0 To UBound($MySpells) - 1
			$g_aiCurrentCCSpells[$i] = 0
			$aiCurrentCCSpellsRemove[$i] = 0
		Next
		Local $iSlotCount = 0
		If _ColorCheck(_GetPixelColor(481, 466, True), Hex(0XCECDC5, 6), 10) And _ColorCheck(_GetPixelColor(551, 466, True), Hex(0XCDCDC5, 6), 10) = False Then
			$iOffsetSlot = $g_aiArmyAvailableCCSpellSlot[0] + 39
			$iSlotCount = 0
		Else
			$iOffsetSlot = $g_aiArmyAvailableCCSpellSlot[0]
			$iSlotCount = 1
		EndIf
		Q26253()
		For $i = 0 To $iSlotCount
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableCCSpellSlot[3] - $g_aiArmyAvailableCCSpellSlot[1])) / 2
			$E21720[$i] = GetHHBitmapArea($g_hHBitmap2, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableCCSpellSlot[1] - $iPixelDivider, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableCCSpellSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_CC_Spell_Slot[$i] = GetHHBitmapArea($g_hHBitmap2, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableCCSpellSlot[1], Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableCCSpellSlot[3])
			Local $result = findMultiImage($E21720[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			Local $bExitLoopFlag = False
			Local $bContinueNextLoop = False
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							If $aPropsValues[0] <> "0" Then
								$aiSpellsInfo[$i][0] = $aPropsValues[0]
								$aiSpellsInfo[$i][2] = $i + 1
								$iSpellsCount += 1
							EndIf
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect spells on slot: " & $i + 1, $COLOR_INFO)
						SetLog("Spell: " & $aiSpellsInfo[$i][0], $COLOR_INFO)
						SetLog("Spell: " & $aPropsValues[0], $COLOR_INFO)
					Else
						$aPropsValues = $result[$j]
						SetLog("Spell: " & $aPropsValues[0], $COLOR_INFO)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then $bExitLoopFlag = True
			ElseIf $g_bDebugSetlogTrain Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableCCSpellSlot[3] - $g_aiArmyAvailableCCSpellSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($g_hHBitmap2, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableCCSpellSlot[1] - $iPixelDivider, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableCCSpellSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Spell_Av_CC_Slot_" & $i + 1, "ArmyWindows\CCSpells\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CC_Spell_Slot[$i], "Spell_CC_Slot_" & $i + 1 & "_Unknown_RenameThis_92", "ArmyWindows\CCSpells\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what cc spells on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: Spell_CC_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & @ScriptDir & "\profiles\" & $g_sProfileCurrentName & "\Debug\Images\", $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				$bContinueNextLoop = True
			Else
				SetLog("Enable Debug Mode.", $COLOR_DEBUG)
				$bContinueNextLoop = True
			EndIf
			If $bExitLoopFlag = True Then ExitLoop
			If $bContinueNextLoop Then
				ContinueLoop
			EndIf
			$g_hHBitmap_Av_CC_Spell_SlotQty[$i] = GetHHBitmapArea($g_hHBitmap2, Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2)), $g_aiArmyAvailableCCSpellSlotQty[1], Int($iOffsetSlot + ($g_iArmy_Av_CC_Spell_Slot_Width * $i) + (($g_iArmy_Av_CC_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2) + $g_iArmy_QtyWidthForScan), $g_aiArmyAvailableCCSpellSlotQty[3])
			$aiSpellsInfo[$i][1] = getTSOcrFullComboQuantity($g_hHBitmap_Av_CC_Spell_SlotQty[$i])
			If $aiSpellsInfo[$i][1] <> 0 Then
				$iSpellIndex = TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell
				$g_aiCurrentCCSpells[$iSpellIndex] = $g_aiCurrentCCSpells[$iSpellIndex] + $aiSpellsInfo[$i][1]
			Else
				SetLog("Error detect Quantity no. On CC Spell: " & GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			If $g_bDebugImageSave Then
				_debugSaveHBitmapToImage($E21720[$i], "ArmyTab_CCSpell_Slot" & $i, "ArmyWindows\CCSpells")
				_debugSaveHBitmapToImage($g_hHBitmap_Av_CC_Spell_SlotQty[$i], "ArmyTab_CCSpell_NoUnit_Slot" & $i, "ArmyWindows\CCSpells")
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_CC_Spell_Slot[$i], "RenameIt2ImgLocFormat_ArmyTab_CCSpell_Slot" & $i, "ArmyWindows\CCSpells")
			EndIf
			Q26253()
		Next
		GdiDeleteHBitmap($g_hHBitmap2)
		If $iSpellsCount = 0 Then
			SetLog("No Spell in Clan Castle.", $COLOR_WARNING)
			ExitLoop
		EndIf
		For $i = 0 To UBound($MySpells) - 1
			If $g_bRunState = False Then ExitLoop
			If _Sleep(50) Then ExitLoop
			Local $iTempTotal = $g_aiCurrentCCSpells[$i]
			If $iTempTotal > 0 Then
				SetLog(" - Clan Castle Spells - " & GetTroopName(TroopIndexLookup($MySpells[$i][0]), $g_aiCurrentCCSpells[$i]) & ": " & $g_aiCurrentCCSpells[$i], $COLOR_SUCCESS)
				Local $bIsSpellInKeepList = False
				If $H21852[0] Or $H21852[1] Then
					For $j = 1 To 2
						If (TroopIndexLookup($MySpells[$i][0]) - $eLSpell) + 1 = $H21852[$j - 1] Then
							$bIsSpellInKeepList = True
							If $iTempTotal > $B21855[$j - 1] Then
								$aiCurrentCCSpellsRemove[$i] = $iTempTotal - $B21855[$j - 1]
								$bDeletedExcess = True
							EndIf
							ExitLoop
						EndIf
					Next
					If $bIsSpellInKeepList = False Then
						$aiCurrentCCSpellsRemove[$i] = $iTempTotal
						$bDeletedExcess = True
					EndIf
				EndIf
			EndIf
		Next
		If $bDeletedExcess Then
			$bDeletedExcess = False
			SetLog(" >>> Remove UnWanted Clan Castle Spells.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 0 To $iSlotCount
					If $aiSpellsInfo[$i][1] <> 0 Then
						Local $iUnitToRemove = $aiCurrentCCSpellsRemove[TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell]
						If $iUnitToRemove > 0 Then
							If $aiSpellsInfo[$i][1] > $iUnitToRemove Then
								SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1]) & " at slot: " & $aiSpellsInfo[$i][2] & ", amount to remove: " & $iUnitToRemove, $COLOR_ACTION)
								RemoveOnTItem($aiSpellsInfo[$i][2] - 1, $iUnitToRemove, $iOffsetSlot, "Spells")
								$iUnitToRemove = 0
								$aiCurrentCCSpellsRemove[TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell] = $iUnitToRemove
							Else
								SetLog("Remove " & GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1]) & " at slot: " & $aiSpellsInfo[$i][2] & ", amount to remove: " & $aiSpellsInfo[$i][1], $COLOR_ACTION)
								RemoveOnTItem($aiSpellsInfo[$i][2] - 1, $aiSpellsInfo[$i][1], $iOffsetSlot, "Spells")
								$iUnitToRemove -= $aiSpellsInfo[$i][1]
								$aiCurrentCCSpellsRemove[TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell] = $iUnitToRemove
							EndIf
						EndIf
					EndIf
				Next
			Else
				ExitLoop
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				ExitLoop
			EndIf
			ClickOkay()
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				ContinueLoop
			Else
				If _Sleep(1000) Then ExitLoop
			EndIf
			ContinueLoop
		EndIf
		ExitLoop
	WEnd
	Q26253()
EndFunc   ;==>_getArmyCCSpells

Func _getArmyCCSpellCapacity()
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin _getArmyCCSpellCapacity:", $COLOR_DEBUG1)
	$g_bFullCCSpells = False
	Local $aGetCCSpellSize[3] = ["", "", ""]
	Local $sCCSpellInfo = ""
	Local $iCount
	$iCount = 0
	While 1
		$sCCSpellInfo = getTSOcrCCSpellCap()
		If $g_bDebugSetlogTrain Then SetLog("$sCCSpellInfo = " & $sCCSpellInfo, $COLOR_DEBUG)
		If $sCCSpellInfo = "" And $iCount > 1 Then ExitLoop
		$aGetCCSpellSize = StringSplit($sCCSpellInfo, "#")
		If IsArray($aGetCCSpellSize) Then
			If $aGetCCSpellSize[0] > 1 Then
				If Number($aGetCCSpellSize[2]) > 2 And $aGetCCSpellSize[2] = 0 Then
					If $g_bDebugSetlogTrain Then SetLog(" OCR value is not valid cc spell camp size", $COLOR_DEBUG)
					ContinueLoop
				EndIf
				$C21882 = Number($aGetCCSpellSize[2])
				$N21879 = Number($aGetCCSpellSize[1])
				SetLog("Total Clan Castle Spells: " & $N21879 & "/" & $C21882)
				ExitLoop
			Else
				$N21879 = 0
				$C21882 = 0
			EndIf
		Else
			$N21879 = 0
			$C21882 = 0
		EndIf
		$iCount += 1
		If $iCount > 30 Then ExitLoop
		If _Sleep(250) Then Return
		If $g_bRunState = False Then Return
	WEnd
	If $N21879 = 0 And $C21882 = 0 Then
		If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("CC Spell size read error or maybe not available.", $COLOR_ERROR)
	EndIf
	If $N21879 >= $C21882 Then
		$g_bFullCCSpells = True
	EndIf
	If $g_bFullCCSpells = False Then
		If $g_bChkWait4CCSpell Then
			SetLog("Waiting for Clan Castle Spells.", $COLOR_ACTION)
		Else
			SetLog("Not Waiting for Clan Castle Spells.", $COLOR_ACTION)
			$g_bFullCCSpells = True
		EndIf
	EndIf
	If $Q21822 Then
		$N21840 = $N21879 < $N21831
	EndIf
EndFunc   ;==>_getArmyCCSpellCapacity

Func Q26253()
	For $i = 0 To 1
		GdiDeleteHBitmap($E21720[$i])
		GdiDeleteHBitmap($g_hHBitmap_Av_CC_Spell_SlotQty[$i])
		GdiDeleteHBitmap($g_hHBitmap_Capture_Av_CC_Spell_Slot[$i])
	Next
EndFunc   ;==>Q26253
Func _getArmySpellCapacity($hHBitmap, $bShowLog = True, $bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = True)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("_getArmySpellCapacity():", $COLOR_DEBUG1)
	If Int($g_iTownHallLevel) < 5 Then Return
	If $bCheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			ClickP($aAway, 1, 0, "#0000")
			If _Sleep($DELAYCHECKARMYCAMP4) Then Return
			If Not OpenArmyOverview(True, "_getArmySpellCapacity()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	Local $aGetSpellSize[3] = ["", "", ""]
	Local $sSpellInfo = ""
	If $g_iTotalSpellValue > 0 Then
		$g_iCurrentSpells = 0
		$g_iTotalSpells = 0
		$sSpellInfo = getTSOcrSpellCap($hHBitmap)
		If $g_bDebugSetlogTrain Then SetLog("_getArmySpellCapacity $sSpellInfo = " & $sSpellInfo, $COLOR_DEBUG)
		$aGetSpellSize = StringSplit($sSpellInfo, "#")
		If IsArray($aGetSpellSize) Then
			If $aGetSpellSize[0] > 1 Then
				$g_iCurrentSpells = Number($aGetSpellSize[1])
				$g_iTotalSpells = Number($aGetSpellSize[2])
			EndIf
		EndIf
		If $g_iTotalSpells <> 0 Then
			If $bShowLog Then SetLog("Spells: " & $g_iCurrentSpells & "/" & $g_iTotalSpells)
		EndIf
		$g_bFullArmySpells = $g_iCurrentSpells >= $g_iMySpellsSize
	EndIf
	If $g_bFullArmySpells = False Then
		Local $bIsWaitForSpellEnable = False
		For $i = $DB To $LB
			If $g_abAttackTypeEnable[$i] Then
				If $g_abSearchSpellsWaitEnable[$i] Then
					SetLog(" " & $g_asModeText[$i] & " Setting - Waiting for spells ready.", $COLOR_ACTION)
					$bIsWaitForSpellEnable = True
				EndIf
			EndIf
		Next
		If $bIsWaitForSpellEnable = False Then
			SetLog("Not waiting for spell.", $COLOR_ACTION)
			$g_bFullArmySpells = True
		EndIf
	EndIf
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>_getArmySpellCapacity

Func _getArmySpellCapacityMini($hHBitmap, $bShowLog = True)
	If $g_iTotalSpellValue = 0 Then Return
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("_getArmySpellCapacityMini():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	Local $aTempSize
	Local $sSpellInfo = ""
	$g_aiSpellsMaxCamp[0] = 0
	$g_aiSpellsMaxCamp[1] = 0
	$sSpellInfo = getTSOcrTrainArmyOrBrewSpellCap($hHBitmap)
	If $g_bDebugSetlogTrain Then SetLog("_getArmySpellCapacityMini $sSpellInfo = " & $sSpellInfo, $COLOR_DEBUG)
	$aTempSize = StringSplit($sSpellInfo, "#", $STR_NOCOUNT)
	If IsArray($aTempSize) Then
		If UBound($aTempSize) = 2 Then
			$g_aiSpellsMaxCamp[0] = Number($aTempSize[0])
			$g_aiSpellsMaxCamp[1] = Number($aTempSize[1])
		EndIf
	EndIf
	If $g_aiSpellsMaxCamp[1] <> 0 Then
		If $bShowLog Then SetLog("Max Spells: " & $g_aiSpellsMaxCamp[0] & "/" & $g_aiSpellsMaxCamp[1])
	EndIf
EndFunc   ;==>_getArmySpellCapacityMini

Func DeleteTrainHBitmap()
	If $g_hHBitmap <> 0 Then
		GdiDeleteHBitmap($g_hHBitmap)
	EndIf
	If $g_hBitmap <> 0 Then
		GdiDeleteBitmap($g_hBitmap)
	EndIf
	If $g_hHBitmap2 <> 0 Then
		GdiDeleteHBitmap($g_hHBitmap2)
	EndIf

	; Army overview windows
	;------------------------------------------------
	If $g_hHBitmapArmyTab <> 0 Then
		GdiDeleteHBitmap($g_hHBitmapArmyTab)
	EndIf

	If $g_hHBitmapArmyCap <> 0 Then
		GdiDeleteHBitmap($g_hHBitmapArmyCap)
	EndIf

	If $g_hHBitmapSpellCap <> 0 Then
		GdiDeleteHBitmap($g_hHBitmapSpellCap)
	EndIf

	If $g_hHBitmapSiegeCap <> 0 Then
		GdiDeleteHBitmap($g_hHBitmapSiegeCap)
	EndIf

	; Slots
	For $i = 0 To UBound($g_hHBitmap_Av_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Av_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_Av_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Av_Spell_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_Spell_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Av_Spell_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_Spell_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_Av_Spell_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Spell_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Av_Siege_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_Siege_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Av_Siege_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_Av_Siege_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_Av_Siege_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_Av_Siege_Slot[$i])
	Next
	GdiDeleteHBitmap($g_hHBitmapTrainTab)
	GdiDeleteHBitmap($g_hHBitmapTrainCap)
	For $i = 0 To UBound($g_hHBitmap_OT_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_OT_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_OT_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_OT_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_OT_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_OT_Slot[$i])
	Next
	GdiDeleteHBitmap($g_hHBitmapBrewTab)
	GdiDeleteHBitmap($g_hHBitmapBrewCap)
	For $i = 0 To UBound($g_hHBitmap_OB_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_OB_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_OB_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_OB_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_OB_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_OB_Slot[$i])
	Next
	GdiDeleteHBitmap($g_hHBitmapSiegeTab)
	GdiDeleteHBitmap($g_hHBitmapSiegeCap)
	For $i = 0 To UBound($g_hHBitmap_OS_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_OS_Slot[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_OS_SlotQty) - 1
		GdiDeleteHBitmap($g_hHBitmap_OS_SlotQty[$i])
	Next
	For $i = 0 To UBound($g_hHBitmap_Capture_OS_Slot) - 1
		GdiDeleteHBitmap($g_hHBitmap_Capture_OS_Slot[$i])
	Next
EndFunc   ;==>DeleteTrainHBitmap

#cs
Func OpenArmyOverview($bCheckMain = True, $sWhereFrom = "Undefined")
	If $bCheckMain Then
		If Not IsMainPage() Then
			SetLog("Cannot open Army Overview window", $COLOR_ERROR)
			SetError(1)
			Return False
		EndIf
	EndIf
	If WaitforPixel(23, 505 + $g_iBottomOffsetY, 53, 507 + $g_iBottomOffsetY, Hex(0xEEB344, 6), 5, 10) Then
		If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton" & " (Called from " & $sWhereFrom & ")", $COLOR_SUCCESS)
		If Not $g_bUseRandomClick Then
			ClickP($aArmyTrainButton, 1, 0, "#0293")
		Else
			ClickR($aArmyTrainButtonRND, $aArmyTrainButton[0], $aArmyTrainButton[1], 1, 0)
		EndIf
	EndIf
	If _Sleep($DELAYRUNBOT6) Then Return
	If Not IsTrainPage() Then
		SetError(1)
		Return False
	EndIf
	Return True
EndFunc   ;==>OpenArmyOverview
Func OpenArmyTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Army Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenArmyTab
Func OpenTroopsTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Train Troops Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenTroopsTab
Func OpenSpellsTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Brew Spells Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenSpellsTab
Func OpenSiegeMachinesTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Build Siege Machines Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenSiegeMachinesTab
Func OpenQuickTrainTab($bSetLog = True, $sWhereFrom = "Undefined")
	Return OpenTrainTab("Quick Train Tab", $bSetLog, $sWhereFrom)
EndFunc   ;==>OpenQuickTrainTab
Func OpenTrainTab($sTab, $bSetLog = True, $sWhereFrom = "Undefined")
	If Not IsTrainPage() Then
		SetDebugLog("[OpenTrainTab] Error in OpenTrainTab: Cannot find the Army Overview Window", $COLOR_ERROR)
		SetError(1)
		Return False
	EndIf
	If $bSetLog Or $g_bDebugSetlogTrain Then SetLog("Open " & $sTab & ($g_bDebugSetlogTrain ? " (Called from " & $sWhereFrom & ")" : ""), $COLOR_INFO)
	Local $aTabButton = findButton(StringStripWS($sTab, 8), Default, 1, True)
	If IsArray($aTabButton) And UBound($aTabButton, 1) = 2 Then
		$aIsTabOpen[0] = $aTabButton[0]
		If Not _CheckPixel($aIsTabOpen, True) Then
			ClickP($aTabButton)
			If Not _WaitForCheckPixel($aIsTabOpen, True) Then
				SetLog("Error in OpenTrainTab: Cannot open " & $sTab & ". Pixel to check did not appear", $COLOR_ERROR)
				SetError(1)
				Return False
			EndIf
		EndIf
	Else
		SetDebugLog("[OpenTrainTab] Error in OpenTrainTab: $aTabButton is no valid Array", $COLOR_ERROR)
		SetError(1)
		Return False
	EndIf
	If _Sleep(200) Then Return
	Return True
EndFunc   ;==>OpenTrainTab
Func PopulateComboScriptsFilesDB()
	Local $FileSearch, $NewFile
	$FileSearch = FileFindFirstFile($g_sCSVAttacksPath & "\*.csv")
	Local $output = ""
	While True
		$NewFile = FileFindNextFile($FileSearch)
		If @error Then ExitLoop
		$output = $output & StringLeft($NewFile, StringLen($NewFile) - 4) & "|"
	WEnd
	FileClose($FileSearch)
	$output = StringLeft($output, StringLen($output) - 1)
	_GUICtrlComboBox_ResetContent($g_hCmbScriptNameDB)
	GUICtrlSetData($g_hCmbScriptNameDB, $output)
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameDB, ""))
	GUICtrlSetData($g_hLblNotesScriptDB, "")
EndFunc   ;==>PopulateComboScriptsFilesDB
Func PopulateComboScriptsFilesAB()
	Local $FileSearch, $NewFile
	$FileSearch = FileFindFirstFile($g_sCSVAttacksPath & "\*.csv")
	Local $output = ""
	While True
		$NewFile = FileFindNextFile($FileSearch)
		If @error Then ExitLoop
		$output = $output & StringLeft($NewFile, StringLen($NewFile) - 4) & "|"
	WEnd
	FileClose($FileSearch)
	$output = StringLeft($output, StringLen($output) - 1)
	_GUICtrlComboBox_ResetContent($g_hCmbScriptNameAB)
	GUICtrlSetData($g_hCmbScriptNameAB, $output)
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, ""))
	GUICtrlSetData($g_hLblNotesScriptAB, "")
EndFunc   ;==>PopulateComboScriptsFilesAB
Func cmbScriptNameDB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameDB)
	Local $Filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB) + 1]
	Local $f, $result = ""
	Local $tempvect, $line, $t
	If FileExists($g_sCSVAttacksPath & "\" & $Filename & ".csv") Then
		$f = FileOpen($g_sCSVAttacksPath & "\" & $Filename & ".csv", 0)
		While 1
			$line = FileReadLine($f)
			If @error = -1 Then ExitLoop
			$tempvect = StringSplit($line, "|", 2)
			If UBound($tempvect) >= 2 Then
				If StringStripWS(StringUpper($tempvect[0]), 2) = "NOTE" Then $result &= $tempvect[1] & @CRLF
			EndIf
		WEnd
		FileClose($f)
	EndIf
	GUICtrlSetData($g_hLblNotesScriptDB, $result)
EndFunc   ;==>cmbScriptNameDB
Func cmbScriptNameAB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameAB)
	Local $Filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB) + 1]
	Local $f, $result = ""
	Local $tempvect, $line, $t
	If FileExists($g_sCSVAttacksPath & "\" & $Filename & ".csv") Then
		$f = FileOpen($g_sCSVAttacksPath & "\" & $Filename & ".csv", 0)
		While 1
			$line = FileReadLine($f)
			If @error = -1 Then ExitLoop
			$tempvect = StringSplit($line, "|", 2)
			If UBound($tempvect) >= 2 Then
				If StringStripWS(StringUpper($tempvect[0]), 2) = "NOTE" Then $result &= $tempvect[1] & @CRLF
			EndIf
		WEnd
		FileClose($f)
	EndIf
	GUICtrlSetData($g_hLblNotesScriptAB, $result)
EndFunc   ;==>cmbScriptNameAB
Func UpdateComboScriptNameDB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB)
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbScriptNameDB, $indexofscript, $scriptname)
	PopulateComboScriptsFilesDB()
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameDB, $scriptname))
	cmbScriptNameDB()
EndFunc   ;==>UpdateComboScriptNameDB
Func UpdateComboScriptNameAB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB)
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbScriptNameAB, $indexofscript, $scriptname)
	PopulateComboScriptsFilesAB()
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, $scriptname))
	cmbScriptNameAB()
EndFunc   ;==>UpdateComboScriptNameAB
Func EditScriptDB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameDB)
	Local $Filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB) + 1]
	If FileExists($g_sCSVAttacksPath & "\" & $Filename & ".csv") Then
		ShellExecute("notepad.exe", $g_sCSVAttacksPath & "\" & $Filename & ".csv")
	EndIf
EndFunc   ;==>EditScriptDB
Func EditScriptAB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameAB)
	Local $Filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB) + 1]
	If FileExists($g_sCSVAttacksPath & "\" & $Filename & ".csv") Then
		ShellExecute("notepad.exe", $g_sCSVAttacksPath & "\" & $Filename & ".csv")
	EndIf
EndFunc   ;==>EditScriptAB
Func AttackCSVAssignDefaultScriptName()
	Local $FileSearch, $NewFile
	$FileSearch = FileFindFirstFile($g_sCSVAttacksPath & "\*.csv")
	Local $output = ""
	$NewFile = FileFindNextFile($FileSearch)
	If @error Then $output = ""
	$output = StringLeft($NewFile, StringLen($NewFile) - 4)
	FileClose($FileSearch)
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameDB, $output))
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, $output))
	cmbScriptNameDB()
	cmbScriptNameAB()
EndFunc   ;==>AttackCSVAssignDefaultScriptName
Global $temp1 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Create", "Create New Script File"), $temp2 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_0", "New Script Filename")
Global $temp3 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", "File exists, please input a new name"), $temp4 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", "An error occurred when creating the file.")
Global $temp1 = 0, $temp2 = 0, $temp3 = 0, $temp4 = 0
Func NewScriptDB()
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Create", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_0", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileOpen($g_sCSVAttacksPath & "\" & $filenameScript & ".csv", $FO_APPEND)
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptName[$DB] = $filenameScript
				UpdateComboScriptNameDB()
				UpdateComboScriptNameAB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>NewScriptDB
Func NewScriptAB()
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Create", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_0", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileOpen($g_sCSVAttacksPath & "\" & $filenameScript & ".csv", $FO_APPEND)
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptName[$LB] = $filenameScript
				UpdateComboScriptNameAB()
				UpdateComboScriptNameDB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>NewScriptAB
Global $temp1 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_0", "Copy to New Script File"), $temp2 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_1", "Copy"), $temp3 = GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_1", "to New Script Filename")
Global $temp1 = 0, $temp2 = 0, $temp3 = 0
Func DuplicateScriptDB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB)
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbScriptNameDB, $indexofscript, $scriptname)
	$g_sAttackScrScriptName[$DB] = $scriptname
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_0", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_1", -1) & ": <" & $g_sAttackScrScriptName[$DB] & ">" & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_1", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileCopy($g_sCSVAttacksPath & "\" & $g_sAttackScrScriptName[$DB] & ".csv", $g_sCSVAttacksPath & "\" & $filenameScript & ".csv")
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptName[$DB] = $filenameScript
				UpdateComboScriptNameDB()
				UpdateComboScriptNameAB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>DuplicateScriptDB
Func DuplicateScriptAB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB)
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbScriptNameAB, $indexofscript, $scriptname)
	$g_sAttackScrScriptName[$LB] = $scriptname
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_0", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_1", -1) & ": <" & $g_sAttackScrScriptName[$LB] & ">" & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_1", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileCopy($g_sCSVAttacksPath & "\" & $g_sAttackScrScriptName[$LB] & ".csv", $g_sCSVAttacksPath & "\" & $filenameScript & ".csv")
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptName[$LB] = $filenameScript
				UpdateComboScriptNameAB()
				UpdateComboScriptNameDB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>DuplicateScriptAB
Func ApplyScriptDB()
	If $g_bChkUseRandomCSV Then
		SetSameCSVScriptDB()
		PreSelectCmbTroop()
	EndIf
	Local $iApply = 0
	Local $aiCSVTroops[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVSpells[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVHeros[$eHeroCount][2] = [[0, 0], [0, 0], [0, 0], [0, 0]]
	Local $iCSVRedlineRoutineItem = 0, $iCSVDroplineEdgeItem = 0
	Local $sCSVCCReq = ""
	Local $aTemp = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameDB)
	Local $sFileName = $aTemp[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB) + 1]
	SetLog("CSV settings apply starts: " & $sFileName, $COLOR_INFO)
	$iApply = ParseAttackCSV_Settings_variables($aiCSVTroops, $aiCSVSpells, $aiCSVHeros, $iCSVRedlineRoutineItem, $iCSVDroplineEdgeItem, $sCSVCCReq, $sFileName)
	If Not $iApply Then
		SetLog("CSV settings apply failed", $COLOR_ERROR)
		Return
	EndIf
	$iApply = 0
	For $i = 0 To UBound($aiCSVTroops) - 1
		If $aiCSVTroops[$i] > 0 Then $iApply += 1
	Next
	For $i = 0 To UBound($aiCSVSpells) - 1
		If $aiCSVSpells[$i] > 0 Then $iApply += 1
	Next
	If $iApply > 0 Then
		For $t = 0 To $eTroopCount - 1
			$MyTroops[$t][3] = $aiCSVTroops[$t]
		Next
		For $s = 0 To $eSpellCount - 1
			$MySpells[$s][3] = $aiCSVSpells[$s]
		Next
		cmbTroopSetting()
		ApplyConfig_600_52_1("Read")
		ApplyConfig_600_52_2("Read")
		SetLog("CSV Train settings applied", $COLOR_SUCCESS)
	EndIf
	$iApply = 0
	For $i = 0 To UBound($aiCSVHeros) - 1
		If $aiCSVHeros[$i][0] > 0 Then $iApply += 1
	Next
	If $iApply > 0 Then
		For $h = 0 To UBound($aiCSVHeros) - 1
			If $aiCSVHeros[$h][0] > 0 Then
				Switch $h
					Case $eHeroBarbarianKing
						$g_iActivateKing = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateKing = $aiCSVHeros[$h][1]
					Case $eHeroArcherQueen
						$g_iActivateQueen = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateQueen = $aiCSVHeros[$h][1]
					Case $eHeroGrandWarden
						$g_iActivateWarden = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateWarden = $aiCSVHeros[$h][1]
					Case $eHeroRoyalChampion
						$g_iActivateChampion = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateChampion = $aiCSVHeros[$h][1]
				EndSwitch
			EndIf
		Next
		radHerosApply()
		SetLog("CSV Hero Ability settings applied", $COLOR_SUCCESS)
		GUICtrlSetState($g_hChkDBKingAttack, $aiCSVHeros[$eHeroBarbarianKing][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkDBKingAttack))
		GUICtrlSetState($g_hChkDBQueenAttack, $aiCSVHeros[$eHeroArcherQueen][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkDBQueenAttack))
		GUICtrlSetState($g_hChkDBWardenAttack, $aiCSVHeros[$eHeroGrandWarden][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkDBWardenAttack))
		GUICtrlSetState($g_hChkDBChampionAttack, $aiCSVHeros[$eHeroRoyalChampion][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkDBChampionAttack))
		SetLog("CSV 'Attack with' Hero settings applied", $COLOR_SUCCESS)
	EndIf
	If $sCSVCCReq <> "" Then
		GUICtrlSetState($g_hChkDBDropCC, $GUI_CHECKED)
		SetLog("CSV 'Attack with' CC settings applied", $COLOR_SUCCESS)
	EndIf
	$iApply = 0
	Local $ahChkDBSpell = StringSplit($g_aGroupAttackDBSpell, "#", 2)
	If IsArray($ahChkDBSpell) Then
		For $i = 0 To UBound($ahChkDBSpell) - 1
			GUICtrlSetState($ahChkDBSpell[$i], $aiCSVSpells[$i] > 0 ? $GUI_CHECKED : $GUI_UNCHECKED)
			If $aiCSVSpells[$i] > 0 Then $iApply += 1
		Next
		If $iApply > 0 Then SetLog("CSV 'Attack with' Spell settings applied", $COLOR_SUCCESS)
	EndIf
	If $iCSVRedlineRoutineItem > 0 And $iCSVRedlineRoutineItem <= _GUICtrlComboBox_GetCount($g_hCmbScriptRedlineImplDB) + 1 Then
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptRedlineImplDB, $iCSVRedlineRoutineItem - 1)
		cmbScriptRedlineImplDB()
		SetLog("CSV Red Line settings applied", $COLOR_SUCCESS)
	Else
		If $iCSVRedlineRoutineItem <> 0 Then SetLog("CSV Red Line settings out of bounds", $COLOR_ERROR)
	EndIf
	If $iCSVDroplineEdgeItem > 0 And $iCSVDroplineEdgeItem <= _GUICtrlComboBox_GetCount($g_hCmbScriptDroplineDB) + 1 Then
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptDroplineDB, $iCSVDroplineEdgeItem - 1)
		cmbScriptDroplineDB()
		SetLog("CSV Drop Line settings applied", $COLOR_SUCCESS)
	Else
		If $iCSVDroplineEdgeItem <> 0 Then SetLog("CSV Drop Line settings out of bounds", $COLOR_ERROR)
	EndIf
	If $sCSVCCReq <> "" Then
		$g_bRequestTroopsEnable = True
		$g_sRequestTroopsText = $sCSVCCReq
		$P21903[$g_iCmbTroopSetting] = $sCSVCCReq
		ApplyConfig_600_11("Read")
		SetLog("CSV CC Request settings applied", $COLOR_SUCCESS)
	EndIf
	BtnSaveprofile()
EndFunc   ;==>ApplyScriptDB
Func ApplyScriptAB()
	If $g_bChkUseRandomCSV Then
		SetSameCSVScriptAB()
		PreSelectCmbTroop()
	EndIf
	Local $iApply = 0
	Local $aiCSVTroops[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVSpells[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVHeros[$eHeroCount][2] = [[0, 0], [0, 0], [0, 0], [0, 0]]
	Local $iCSVRedlineRoutineItem = 0, $iCSVDroplineEdgeItem = 0
	Local $sCSVCCReq = ""
	Local $aTemp = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameAB)
	Local $sFileName = $aTemp[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB) + 1]
	SetLog("CSV settings apply starts: " & $sFileName, $COLOR_INFO)
	$iApply = ParseAttackCSV_Settings_variables($aiCSVTroops, $aiCSVSpells, $aiCSVHeros, $iCSVRedlineRoutineItem, $iCSVDroplineEdgeItem, $sCSVCCReq, $sFileName)
	If Not $iApply Then
		SetLog("CSV settings apply failed", $COLOR_ERROR)
		Return
	EndIf
	$iApply = 0
	For $i = 0 To UBound($aiCSVTroops) - 1
		If $aiCSVTroops[$i] > 0 Then $iApply += 1
	Next
	For $i = 0 To UBound($aiCSVSpells) - 1
		If $aiCSVSpells[$i] > 0 Then $iApply += 1
	Next
	If $iApply > 0 Then
		For $t = 0 To $eTroopCount - 1
			$MyTroops[$t][3] = $aiCSVTroops[$t]
		Next
		For $s = 0 To $eSpellCount - 1
			$MySpells[$s][3] = $aiCSVSpells[$s]
		Next
		cmbTroopSetting()
		ApplyConfig_600_52_1("Read")
		ApplyConfig_600_52_2("Read")
		SetLog("CSV Train settings applied", $COLOR_SUCCESS)
	EndIf
	$iApply = 0
	For $i = 0 To UBound($aiCSVHeros) - 1
		If $aiCSVHeros[$i][0] > 0 Then $iApply += 1
	Next
	If $iApply > 0 Then
		For $h = 0 To UBound($aiCSVHeros) - 1
			If $aiCSVHeros[$h][0] > 0 Then
				Switch $h
					Case $eHeroBarbarianKing
						$g_iActivateKing = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateKing = $aiCSVHeros[$h][1]
					Case $eHeroArcherQueen
						$g_iActivateQueen = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateQueen = $aiCSVHeros[$h][1]
					Case $eHeroGrandWarden
						$g_iActivateWarden = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateWarden = $aiCSVHeros[$h][1]
					Case $eHeroRoyalChampion
						$g_iActivateChampion = $aiCSVHeros[$h][0] - 1
						If $aiCSVHeros[$h][1] > 0 Then $g_iDelayActivateChampion = $aiCSVHeros[$h][1]
				EndSwitch
			EndIf
		Next
		radHerosApply()
		SetLog("CSV Hero Ability settings applied", $COLOR_SUCCESS)
		GUICtrlSetState($g_hChkABKingAttack, $aiCSVHeros[$eHeroBarbarianKing][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkABKingAttack))
		GUICtrlSetState($g_hChkABQueenAttack, $aiCSVHeros[$eHeroArcherQueen][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkABQueenAttack))
		GUICtrlSetState($g_hChkABWardenAttack, $aiCSVHeros[$eHeroGrandWarden][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkABWardenAttack))
		GUICtrlSetState($g_hChkABChampionAttack, $aiCSVHeros[$eHeroRoyalChampion][0] > 0 ? $GUI_CHECKED : GUICtrlGetState($g_hChkABChampionAttack))
		SetLog("CSV 'Attack with' Hero settings applied", $COLOR_SUCCESS)
	EndIf
	If $sCSVCCReq <> "" Then
		GUICtrlSetState($g_hChkABDropCC, $GUI_CHECKED)
		SetLog("CSV 'Attack with' CC settings applied", $COLOR_SUCCESS)
	EndIf
	$iApply = 0
	Local $ahChkABSpell = StringSplit($groupAttackABSpell, "#", 2)
	If IsArray($ahChkABSpell) Then
		For $i = 0 To UBound($ahChkABSpell) - 1
			GUICtrlSetState($ahChkABSpell[$i], $aiCSVSpells[$i] > 0 ? $GUI_CHECKED : $GUI_UNCHECKED)
			If $aiCSVSpells[$i] > 0 Then $iApply += 1
		Next
		If $iApply > 0 Then SetLog("CSV 'Attack with' Spell settings applied", $COLOR_SUCCESS)
	EndIf
	If $iCSVRedlineRoutineItem > 0 And $iCSVRedlineRoutineItem <= _GUICtrlComboBox_GetCount($g_hCmbScriptRedlineImplAB) + 1 Then
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptRedlineImplAB, $iCSVRedlineRoutineItem - 1)
		cmbScriptRedlineImplAB()
		SetLog("CSV Red Line settings applied", $COLOR_SUCCESS)
	Else
		If $iCSVRedlineRoutineItem <> 0 Then SetLog("CSV Red Line settings out of bounds", $COLOR_ERROR)
	EndIf
	If $iCSVDroplineEdgeItem > 0 And $iCSVDroplineEdgeItem <= _GUICtrlComboBox_GetCount($g_hCmbScriptDroplineAB) + 1 Then
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptDroplineAB, $iCSVDroplineEdgeItem - 1)
		cmbScriptDroplineAB()
		SetLog("CSV Drop Line settings applied", $COLOR_SUCCESS)
	Else
		If $iCSVDroplineEdgeItem <> 0 Then SetLog("CSV Drop Line settings out of bounds", $COLOR_ERROR)
	EndIf
	If $sCSVCCReq <> "" Then
		$g_bRequestTroopsEnable = True
		$g_sRequestTroopsText = $sCSVCCReq
		$P21903[$g_iCmbTroopSetting] = $sCSVCCReq
		ApplyConfig_600_11("Read")
		SetLog("CSV CC Request settings applied", $COLOR_SUCCESS)
	EndIf
	BtnSaveprofile()
EndFunc   ;==>ApplyScriptAB
Func AddRDNCSVScriptDB()
	Local $NbrRDN = InputBox(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript", "Add a random CSV"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Value", "Select value between 1 to 3, it will be affect to the same number Composition Troops / Spells"))
	If (($NbrRDN >= 1) And ($NbrRDN <= 3)) Then
		GUICtrlSetData($g_hTxtScriptNameAB_Ramdom[$NbrRDN - 1], GUICtrlRead($g_hCmbScriptNameDB))
		GUICtrlSetData($g_hTxtScriptNameDB_Ramdom[$NbrRDN - 1], GUICtrlRead($g_hCmbScriptNameDB))
		$g_sTxtScriptName_Ramdom[$NbrRDN - 1] = GUICtrlRead($g_hCmbScriptNameDB)
	Else
		MsgBox(0, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Error", "Range error"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Value", "Select value between 1 to 3"))
		Return
	EndIf
	SetSameCSVScriptDB()
	SaveConfig_600_29_DB_Scripted()
EndFunc   ;==>AddRDNCSVScriptDB
Func AddRDNCSVScriptAB()
	Local $NbrRDN = InputBox(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript", "Add a random CSV"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Value", "Select value between 1 to 3, it will be affect to the same number Composition Troops / Spells"))
	If (($NbrRDN >= 1) And ($NbrRDN <= 3)) Then
		GUICtrlSetData($g_hTxtScriptNameAB_Ramdom[$NbrRDN - 1], GUICtrlRead($g_hCmbScriptNameAB))
		GUICtrlSetData($g_hTxtScriptNameDB_Ramdom[$NbrRDN - 1], GUICtrlRead($g_hCmbScriptNameAB))
		$g_sTxtScriptName_Ramdom[$NbrRDN - 1] = GUICtrlRead($g_hCmbScriptNameAB)
	Else
		MsgBox(0, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Error", "Range error"), GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "AddRDNScript_Value", "Select value between 1 to 3"))
		Return
	EndIf
	SetSameCSVScriptAB()
	SaveConfig_600_29_DB_Scripted()
EndFunc   ;==>AddRDNCSVScriptAB
Func RunRDNCSVScript()
	$g_aiScriptRNDAttack = GUICtrlRead($g_hCmbScriptNameAB)
	If $g_sTxtScriptName_Ramdom[0] = "" And $g_sTxtScriptName_Ramdom[1] = "" And $g_sTxtScriptName_Ramdom[2] = "" Then Return
	Local $tempRDN
	Do
		$tempRDN = Random(0, 2, 1)
	Until $g_sTxtScriptName_Ramdom[$tempRDN] <> ""
	$g_aiScriptNextRNDAttack = $g_sTxtScriptName_Ramdom[$tempRDN]
	ApplyRDNScript($g_aiScriptNextRNDAttack)
	$g_bChkEnableDeleteExcessTroops = False
	$g_bChkEnableDeleteExcessSieges = False
	$g_bPreciseBrew = False
	ApplyConfig_600_52_1("Read")
	ApplyConfig_600_52_2("Read")
	ApplyConfig_600_52_3("Read")
	SetSameCSVScriptAB()
	SaveConfig_600_29_DB_Scripted()
	ApplyScriptAB()
	$g_sRequestTroopsText = $P21903[$tempRDN]
	ApplyConfig_600_11("Read")
EndFunc   ;==>RunRDNCSVScript
Func SetSameCSVScriptDB()
	Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, GUICtrlRead($g_hCmbScriptNameDB))
	If $tempindex = -1 Then $tempindex = 0
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, $tempindex)
	cmbScriptNameAB()
EndFunc   ;==>SetSameCSVScriptDB
Func SetSameCSVScriptAB()
	Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameDB, GUICtrlRead($g_hCmbScriptNameAB))
	If $tempindex = -1 Then $tempindex = 0
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, $tempindex)
	cmbScriptNameDB()
EndFunc   ;==>SetSameCSVScriptAB
Func PreSelectCmbTroop()
	Local $ScriptRNDSelect = GUICtrlRead($g_hCmbScriptNameAB)
	Local $idTab = 0
	For $idTabSelect = 0 To 2
		If $g_sTxtScriptName_Ramdom[$idTabSelect] = $ScriptRNDSelect Then $idTab = $idTabSelect
	Next
	If $g_iCmbTroopSetting <> $idTab Then
		$g_iCmbTroopSetting = $idTab
		If $g_bDebugSetlogTrain Then SetLog("Using the composition army " & $g_iCmbTroopSetting + 1 & " on this attack!")
	EndIf
	_GUICtrlComboBox_SetCurSel($g_hCmbTroopSetting, $g_iCmbTroopSetting)
EndFunc   ;==>PreSelectCmbTroop
Func ApplyRDNScript($RNDType)
	Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, $RNDType)
	If $tempindex = -1 Then $tempindex = 0
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, $tempindex)
	cmbScriptNameAB()
	PreSelectCmbTroop()
	SetSameCSVScriptAB()
	$g_sAttackScrScriptName[$LB] = $RNDType
	$g_sAttackScrScriptName[$DB] = $RNDType
	If $g_bDebugSetlog Then SetLog("Apply Attack With Script: " & $g_sAttackScrScriptName[$LB] & ".csv", $COLOR_INFO)
EndFunc   ;==>ApplyRDNScript
Func cmbScriptRedlineImplDB()
	$g_aiAttackScrRedlineRoutine[$DB] = _GUICtrlComboBox_GetCurSel($g_hCmbScriptRedlineImplDB)
	If $g_aiAttackScrRedlineRoutine[$DB] = 3 Then
		GUICtrlSetState($g_hCmbScriptDroplineDB, $GUI_HIDE)
		$g_aiAttackScrDroplineEdge[$DB] = $DROPLINE_FULL_EDGE_FIXED
	Else
		GUICtrlSetState($g_hCmbScriptDroplineDB, $GUI_SHOW)
	EndIf
EndFunc   ;==>cmbScriptRedlineImplDB
Func cmbScriptRedlineImplAB()
	$g_aiAttackScrRedlineRoutine[$LB] = _GUICtrlComboBox_GetCurSel($g_hCmbScriptRedlineImplAB)
	If $g_aiAttackScrRedlineRoutine[$LB] = 3 Then
		GUICtrlSetState($g_hCmbScriptDroplineAB, $GUI_HIDE)
		$g_aiAttackScrDroplineEdge[$LB] = $DROPLINE_FULL_EDGE_FIXED
	Else
		GUICtrlSetState($g_hCmbScriptDroplineAB, $GUI_SHOW)
	EndIf
EndFunc   ;==>cmbScriptRedlineImplAB
Func cmbScriptDroplineDB()
	$g_aiAttackScrDroplineEdge[$DB] = _GUICtrlComboBox_GetCurSel($g_hCmbScriptDroplineDB)
EndFunc   ;==>cmbScriptDroplineDB
Func cmbScriptDroplineAB()
	$g_aiAttackScrDroplineEdge[$LB] = _GUICtrlComboBox_GetCurSel($g_hCmbScriptDroplineAB)
EndFunc   ;==>cmbScriptDroplineAB
Func AttackNow()
	SetLog("Begin Live Base Attack TEST", $COLOR_INFO)
	Local $tempbRunState = $g_bRunState
	Local $tempSieges = $g_aiCurrentSiegeMachines
	$g_bRunState = True
	While $g_bRunState
		$g_iMatchMode = $LB
		$g_aiAttackAlgorithm[$LB] = 1
		If $g_iGuiMode = 1 Then $g_sAttackScrScriptName[$LB] = GUICtrlRead($g_hCmbScriptNameAB)
		$g_aiCurrentSiegeMachines[$eSiegeWallWrecker] = 1
		$g_aiCurrentSiegeMachines[$eSiegeBattleBlimp] = 1
		$g_aiCurrentSiegeMachines[$eSiegeStoneSlammer] = 1
		$g_aiCurrentSiegeMachines[$eSiegeBarracks] = 1
		$g_aiCurrentSiegeMachines[$eSiegeLogLauncher] = 1
		SetLog("Script Name : " & $g_sAttackScrScriptName[$LB], $COLOR_INFO)
		Local $Scenery = IsNewTheme()
		If $Scenery > 0 Then
			If $Scenery = 1 Then
				SetLog("'Clashy Constructs' Theme Village detected.")
			EndIf
			If $Scenery = 2 Then
				SetLog("'Pirate Scenery' Theme Village detected.")
			EndIf
			If $Scenery = 3 Then
				SetLog("'Epic Winter' Theme Village detected.")
			EndIf
			If $Scenery = 4 Then
				SetLog("'Hog Mountain' Theme Village detected.")
			EndIf
			If $Scenery = 5 Then
				SetLog("'Jungle' Theme Village detected.")
			EndIf
			If $Scenery = 6 Then
				SetLog("'EpicJungle' Theme Village detected.")
			EndIf
			If $Scenery = 99 Then
				SetLog("'WAR' Theme Village detected.", $COLOR_INFO)
				SetLog("If you need a bot for WAR, this game is not made for you!", $COLOR_ERROR)
				Return
			EndIf
		Else
			SetLog("'Classic' Theme Village detected.")
		EndIf
		ResetTHsearch()
		_ObjDeleteKey($g_oBldgAttackInfo, "")
		If _Sleep($DELAYRESPOND) Then ExitLoop
		FindTownHall(True)
		; If _Sleep($DELAYRESPOND) Then ExitLoop
		; V7170(True)
		If _Sleep($DELAYRESPOND) Then ExitLoop
		PrepareAttack($g_iMatchMode)
		If _Sleep($DELAYRESPOND) Then ExitLoop
		Attack()
		If _Sleep($DELAYRESPOND) Then ExitLoop
		SetLog("Check Heroes Health and waiting battle for end.", $COLOR_INFO)
		While IsAttackPage() And ($g_bCheckKingPower Or $g_bCheckQueenPower Or $g_bCheckWardenPower Or $g_bCheckChampionPower)
			CheckHeroesHealth()
			If _Sleep(500) Then ExitLoop
		WEnd
		$g_bRunState = $tempbRunState
	WEnd
	SetLog("End Live Base Attack TEST", $COLOR_INFO)
	$g_aiCurrentSiegeMachines = $tempSieges
	$g_bRunState = $tempbRunState
EndFunc   ;==>AttackNow
Func TestUsePotions()
	Local $bCurrentRunState = $g_bRunState
	Local $bCurrentDebugOcr = $g_bDebugOcr
	$g_bDebugOcr = True
	$g_bRunState = True
	SetLog("Use Potions Test starts")
	UsePotions()
	SetLog("Use Potions Test ended")
	$g_bRunState = $bCurrentRunState
	$g_bDebugOcr = $bCurrentDebugOcr
EndFunc   ;==>TestUsePotions
Func UsePotions()
	If Not $g_bChkBuilderPotion And Not $g_bChkResearchPotion Then Return
	SetLog("Let's see if we can use potion to boost your Builders / Laboratory", $COLOR_INFO)
	ClickP($aAway, 2, $DELAYLABORATORY4, "#0359")
	checkMainScreen()
	If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
		SetLog("I don't have any laboratory position. Skip using the Research Potion", $COLOR_INFO)
		Return
	EndIf
	If $g_iTownHallLevel < 3 Then
		SetLog("Townhall Lvl " & $g_iTownHallLevel & " has no Lab.", $COLOR_ERROR)
		Return
	EndIf
	If $g_bChkResearchPotion Then
		If V8688() Then
			SetLog("Let's help your laboratory research with a little boost! ", $COLOR_INFO)
			UseResearchPotion()
		Else
			SetLog("There is nothing to boost here, skip using Research Potion", $COLOR_INFO)
		EndIf
	EndIf
	ClickP($aAway, 1, $DELAYLABORATORY4, "#0359")
	If $g_iFreeBuilderCount <= 1 And $g_bChkBuilderPotion Then
		SetLog("Enough builders are busy, let's boost them", $COLOR_INFO)
		UseBuilderPotion()
	Else
		SetLog("Not enough of your builders are busy, skip using Builder Potion", $COLOR_INFO)
	EndIf
	ZoomOut()
	ClickP($aAway, 1, $DELAYLABORATORY4, "#0359")
EndFunc   ;==>UsePotions
Func UseBuilderPotion()
	Local $iStopcheck = 0
	Local $i = 0
	SetLog("Let's see if we can use a Builder Potion to boost your builders", $COLOR_INFO)
	If Not (_ColorCheck(_GetPixelColor(275, 15, True), Hex(0xF5F5ED, 6), 20) = True) Then
		SetLog("Unable to find the Builder button menu ... Exiting Boost...", $COLOR_ERROR)
		Return
	EndIf
	For $i = 0 To 5
		If $iStopcheck = 0 Then
			Click(295, 30)
			If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
			Click(388, 124)
			If _Sleep($DELAYAUTOUPGRADEBUILDING2) Then Return
			Local $aBuilderBoost = findButton("BoostBuilder")
			If IsArray($aBuilderBoost) Then
				SetLog("Builder Potion found, let's Click it!", $COLOR_INFO)
				ClickP($aBuilderBoost)
				If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
				If _ColorCheck(_GetPixelColor(396, 390, True), Hex(0x808dff, 6), 10) Then
					Click(396, 390, 1)
					SetLog("Builders boosted!", $COLOR_SUCCESS)
					Return
				Else
					SetLog("Failed to find the BOOST window button", $COLOR_SUCCESS)
					Return
				EndIf
			Else
				SetLog("Couldn't find the builder potion, you are sure you have one?!", $COLOR_ERROR)
				$iStopcheck = 1
				Return
			EndIf
		ElseIf $iStopcheck = 1 Then
			SetLog("You don't have any Builder Potion left, let's stop checking.", $COLOR_INFO)
			ExitLoop
		EndIf
	Next
EndFunc   ;==>UseBuilderPotion
Func UseResearchPotion()
	Local $iStopcheck = False
	Local $i = 0
	SetLog("Let's see if we can use a Research Potion to boost Laboratory", $COLOR_INFO)
	For $i = 0 To 5
		If $iStopcheck = False Then
			BuildingClickP($g_aiLaboratoryPos, "#0197 + 44")
			If _Sleep($DELAYAUTOUPGRADEBUILDING2) Then Return
			Local $aLabBoost = findButton("BoostLab")
			If IsArray($aLabBoost) Then
				SetLog("Research Potion found, let's Click it!", $COLOR_INFO)
				ClickP($aLabBoost)
				If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
				If _ColorCheck(_GetPixelColor(396, 390, True), Hex(0x808dff, 6), 10) Then
					Click(396, 390, 1)
					SetLog("Laboratory boosted!", $COLOR_SUCCESS)
					Return
				Else
					SetLog("Failed to find the BOOST window button", $COLOR_SUCCESS)
					Return
				EndIf
			Else
				SetLog("Couldn't find the research potion, you are sure you have one?!", $COLOR_ERROR)
				$iStopcheck = True
				Return
			EndIf
			ClickP($aAway, 1, $DELAYLABORATORY4, "#0359")
		ElseIf $iStopcheck Then
			SetLog("You don't have any Research Potion left, let's stop checking.", $COLOR_INFO)
			ExitLoop
		EndIf
	Next
EndFunc   ;==>UseResearchPotion
#ce
#cs
Func getArmyHeroCount($bOpenArmyWindow = False, $bCloseArmyWindow = False, $CheckWindow = True, $bSetLog = True)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyHeroCount:", $COLOR_DEBUG)
	If $CheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "getArmyHeroCount()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf
	$g_iHeroAvailable = $eHeroNone
	Local $iDebugArmyHeroCount = 0
	Local $sResult
	Local $sMessage = ""
	Local $aTempUpgradingHeroes[$eHeroCount] = [$eHeroNone, $eHeroNone, $eHeroNone, $eHeroNone]
	For $i = 0 To $eHeroCount - 1
		$sResult = ArmyHeroStatus($i)
		If $sResult <> "" Then
			Select
				Case StringInStr($sResult, "king", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " - Barbarian King Available", $COLOR_SUCCESS)
					$g_iHeroUpgrading[0] = 0
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroKing)
				Case StringInStr($sResult, "queen", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " - Archer Queen Available", $COLOR_SUCCESS)
					$g_iHeroUpgrading[1] = 0
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroQueen)
				Case StringInStr($sResult, "warden", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " - Grand Warden Available", $COLOR_SUCCESS)
					$g_iHeroUpgrading[2] = 0
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroWarden)
				Case StringInStr($sResult, "champion", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " - Royal Champion Available", $COLOR_SUCCESS)
					$g_iHeroUpgrading[3] = 0
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroChampion)
				Case StringInStr($sResult, "heal", $STR_NOCASESENSEBASIC)
					Switch $i
						Case 0
							$sMessage = " - Barbarian King"
							$g_iHeroUpgrading[0] = 0
						Case 1
							$sMessage = " - Archer Queen"
							$g_iHeroUpgrading[1] = 0
						Case 2
							$sMessage = " - Grand Warden"
							$g_iHeroUpgrading[2] = 0
						Case 3
							$sMessage = " - Royal Champion"
							$g_iHeroUpgrading[3] = 0
						Case Else
							$sMessage = " - Very Bad Monkey Needs"
					EndSwitch
					SetLog("Hero slot: " & $i + 1 & $sMessage & " Healing", $COLOR_DEBUG)
				Case StringInStr($sResult, "upgrade", $STR_NOCASESENSEBASIC)
					Switch $i
						Case 0
							$sMessage = " - Barbarian King"
							$aTempUpgradingHeroes[0] = $eHeroKing
							$g_iHeroUpgrading[0] = 1
							$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroKing)
							_GUI_Value_STATE("SHOW", $groupKingSleeping)
						Case 1
							$sMessage = " - Archer Queen"
							$aTempUpgradingHeroes[1] = $eHeroQueen
							$g_iHeroUpgrading[1] = 1
							$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroQueen)
							_GUI_Value_STATE("SHOW", $groupQueenSleeping)
						Case 2
							$sMessage = " - Grand Warden"
							$aTempUpgradingHeroes[2] = $eHeroWarden
							$g_iHeroUpgrading[2] = 1
							$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroWarden)
							_GUI_Value_STATE("SHOW", $groupWardenSleeping)
						Case 3
							$sMessage = " - Royal Champion"
							$aTempUpgradingHeroes[3] = $eHeroChampion
							$g_iHeroUpgrading[3] = 1
							$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroChampion)
							_GUI_Value_STATE("SHOW", $groupChampionSleeping)
						Case Else
							$sMessage = " - Need to Get Monkey"
					EndSwitch
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & $sMessage & " Upgrade in Process", $COLOR_DEBUG)
				Case StringInStr($sResult, "none", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " - " & $g_asHeroNames[$i] & " Not Available", $COLOR_INFO)
				Case Else
					If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " bad OCR string returned!", $COLOR_ERROR)
			EndSelect
		Else
			If $bSetLog Then SetLog("Hero slot: " & $i + 1 & " status read problem!", $COLOR_ERROR)
		EndIf
	Next
	$g_iHeroUpgradingBit = BitOR($aTempUpgradingHeroes[0], $aTempUpgradingHeroes[1], $aTempUpgradingHeroes[2], $aTempUpgradingHeroes[3])
	$g_bFullArmyHero = True
	For $i = $DB To $LB
		If $g_abAttackTypeEnable[$i] Then
			If $g_aiSearchHeroWaitEnable[$i] > 0 Then
				If BitAND($g_aiSearchHeroWaitEnable[$i], $eHeroKing) = $eHeroKing And BitAND($g_iHeroAvailable, $eHeroKing) <> $eHeroKing Then
					SetLog(" " & $g_asModeText[$i] & " Setting - Waiting Barbarian King to recover before start attack.", $COLOR_ACTION)
					$g_bFullArmyHero = False
				EndIf
				If BitAND($g_aiSearchHeroWaitEnable[$i], $eHeroQueen) = $eHeroQueen And BitAND($g_iHeroAvailable, $eHeroQueen) <> $eHeroQueen Then
					SetLog(" " & $g_asModeText[$i] & " Setting - Waiting Archer Queen to recover before start attack.", $COLOR_ACTION)
					$g_bFullArmyHero = False
				EndIf
				If BitAND($g_aiSearchHeroWaitEnable[$i], $eHeroWarden) = $eHeroWarden And BitAND($g_iHeroAvailable, $eHeroWarden) <> $eHeroWarden Then
					SetLog(" " & $g_asModeText[$i] & " Setting - Waiting Grand Warden to recover before start attack.", $COLOR_ACTION)
					$g_bFullArmyHero = False
				EndIf
				If BitAND($g_aiSearchHeroWaitEnable[$i], $eHeroChampion) = $eHeroWarden And BitAND($g_iHeroAvailable, $eHeroChampion) <> $eHeroChampion Then
					SetLog(" " & $g_asModeText[$i] & " Setting - Waiting Royal Champion to recover before start attack.", $COLOR_ACTION)
					$g_bFullArmyHero = False
				EndIf
			EndIf
		EndIf
	Next
	If $g_bDebugSetlogTrain Then SetLog("$g_bFullArmyHero: " & $g_bFullArmyHero)
	If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero Status K|Q|W|C : " & BitAND($g_iHeroAvailable, $eHeroKing) & "|" & BitAND($g_iHeroAvailable, $eHeroQueen) & "|" & BitAND($g_iHeroAvailable, $eHeroWarden) & "|" & BitAND($g_iHeroAvailable, $eHeroChampion), $COLOR_DEBUG)
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmyHeroCount
Func ArmyHeroStatus($i)
	Local $sImageDir = "trainwindow-HeroStatus-bundle", $sResult = ""
	Local Const $aHeroesRect[$eHeroCount][4] = [[580, 340, 615, 370], [655, 340, 690, 370], [730, 340, 765, 370], [805, 340, 840, 370]]
	_CaptureRegion2($aHeroesRect[$i][0], $aHeroesRect[$i][1], $aHeroesRect[$i][2], $aHeroesRect[$i][3])
	Local $res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sImageDir, "str", "FV", "Int", 0, "str", "FV", "Int", 0, "Int", 1000)
	If $res[0] <> "" Then
		Local $aKeys = StringSplit($res[0], "|", $STR_NOCOUNT)
		If StringInStr($aKeys[0], "xml", $STR_NOCASESENSEBASIC) Then
			Local $aResult = StringSplit($aKeys[0], "_", $STR_NOCOUNT)
			$sResult = $aResult[0]
			Return $sResult
		EndIf
	EndIf
	Switch $i
		Case 0, 1, 2, 3
			Return "none"
	EndSwitch
EndFunc   ;==>ArmyHeroStatus
Func getArmyHeroTime($iHeroType, $bOpenArmyWindow = False, $bCloseArmyWindow = False)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyHeroTime:", $COLOR_DEBUG)
	$g_asHeroHealTime[0] = ""
	$g_asHeroHealTime[1] = ""
	$g_asHeroHealTime[2] = ""
	$g_asHeroHealTime[3] = ""
	If $iHeroType <> $eHeroKing And $iHeroType <> $eHeroQueen And $iHeroType <> $eHeroWarden And $iHeroType <> $eHeroChampion And StringInStr($iHeroType, "all", $STR_NOCASESENSEBASIC) = 0 Then
		SetLog("getHeroTime slipped on banana, get doctor, tell him: " & $iHeroType, $COLOR_ERROR)
		SetError(1)
		Return
	EndIf
	If Not $bOpenArmyWindow And Not IsTrainPage() Then
		SetError(2)
		Return
	ElseIf $bOpenArmyWindow Then
		If Not OpenArmyOverview(True, "getArmyHeroTime()") Then
			SetError(3)
			Return
		EndIf
		If _Sleep($DELAYCHECKARMYCAMP5) Then Return
	EndIf
	Local $iRemainTrainHeroTimer = 0, $sResultHeroTime
	Local $sResult
	Local $aResultHeroes[$eHeroCount] = ["", "", "", ""]
	Local Const $aHeroRemainData[$eHeroCount][4] = [[559, 414, "King", $eHeroKing], [633, 414, "Queen", $eHeroQueen], [708, 414, "Warden", $eHeroWarden], [781, 414, "Champion", $eHeroChampion]]
	For $M20640 = 0 To UBound($aHeroRemainData) - 1
		If StringInStr($iHeroType, "all", $STR_NOCASESENSEBASIC) = 0 And $iHeroType <> $aHeroRemainData[$M20640][3] Then ContinueLoop
		$sResult = ArmyHeroStatus($M20640)
		If $sResult <> "" Then
			If StringInStr($sResult, "heal", $STR_NOCASESENSEBASIC) = 0 Then
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then
					SetLog("Hero slot#" & $M20640 + 1 & " status: " & $sResult & " :skip time read", $COLOR_PURPLE)
				EndIf
				ContinueLoop
			Else
				If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Hero slot#" & $M20640 + 1 & " status: " & $sResult, $COLOR_DEBUG)
			EndIf
		Else
			SetLog("Hero slot#" & $M20640 + 1 & " Status read problem!", $COLOR_ERROR)
		EndIf
		$sResult = getRemainTHero($aHeroRemainData[$M20640][0], $aHeroRemainData[$M20640][1])
		If $sResult <> "" Then
			$aResultHeroes[$M20640] = ConvertOCRTime($aHeroRemainData[$M20640][2] & " recover", $sResult, False, "min.sec")
			SetLog("Remaining " & $aHeroRemainData[$M20640][2] & " recover time: " & StringFormat("%.2f", $aResultHeroes[$M20640]), $COLOR_INFO)
			If $iHeroType = $aHeroRemainData[$M20640][3] Then
				$iRemainTrainHeroTimer = $aResultHeroes[$M20640]
				ExitLoop
			EndIf
		Else
			If $iHeroType = $aHeroRemainData[$M20640][3] Then
				SetLog("Can not read remaining " & $aHeroRemainData[$M20640][2] & " recover time", $COLOR_RED)
			Else
				For $pMatchMode = $DB To $g_iMatchMode - 1
					If IsUnitUsed($pMatchMode, $aHeroRemainData[$M20640][3]) And BitAND($g_aiAttackUseHeroes[$pMatchMode], $g_aiSearchHeroWaitEnable[$pMatchMode]) = $g_aiSearchHeroWaitEnable[$pMatchMode] Then
						SetLog("Can not read remaining " & $aHeroRemainData[$M20640][2] & " train time", $COLOR_ERROR)
						ExitLoop
					Else
						If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Bad read remain " & $aHeroRemainData[$M20640][2] & " recover time, but not enabled", $COLOR_DEBUG)
					EndIf
				Next
			EndIf
		EndIf
	Next
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
	If $iHeroType = $eHeroKing Or $iHeroType = $eHeroQueen Or $iHeroType = $eHeroWarden Or $iHeroType = $eHeroChampion Then
		Return $iRemainTrainHeroTimer
	ElseIf StringInStr($iHeroType, "all", $STR_NOCASESENSEBASIC) > 0 Then
		For $i = 0 To $eHeroCount - 1
			If $aResultHeroes[$i] <> "" And $aResultHeroes[$i] > 0 Then $g_asHeroHealTime[$i] = _DateAdd("s", Min2Sec($aResultHeroes[$i]), _NowCalc())
			SetDebugLog("[getArmyHeroTime] " & $aHeroRemainData[$i][2] & " heal time: " & $g_asHeroHealTime[$i])
		Next
		Return $aResultHeroes
	EndIf
EndFunc   ;==>getArmyHeroTime

Func chkDebugTrain()
	$g_bDebugSetlogTrain = (GUICtrlRead($g_hChkdebugTrain) = $GUI_CHECKED)
	SetDebugLog("DebugTrain " & ($g_bDebugSetlogTrain ? "enabled" : "disabled"))
EndFunc   ;==>chkDebugTrain
Func getArmySpellTime($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = True, $bSetLog = True, $bNeedCapture = True)
	If $g_bDebugSetlogTrain Then SetLog("getArmySpellTime():", $COLOR_DEBUG1)
	If Not $g_bRunState Then Return
	$g_aiTimeTrain[1] = 0
	If Int($g_iTownHallLevel) < 5 Then Return
	If $bCheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "getArmySpellTime()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf
	Local $sResultSpells = getRemainTrainTimer(440, 315, $bNeedCapture)
	$g_aiTimeTrain[1] = ConvertOCRTime("Spells", $sResultSpells, $bSetLog)
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmySpellTime

Func ConvertOCRTime($WhereRead, $ToConvert, $bSetLog = True, $sReturnFormat = "min")
	Local $iRemainTimer = 0, $aResult, $iDay = 0, $iHour = 0, $iMinute = 0, $iSecond = 0
	Local $ToConvertForLog = $ToConvert
	Local $bFromTrain = $WhereRead = "Troops" Or $WhereRead = "Spells" Or $WhereRead = "Sieges"
	$bSetLog = $bSetLog Or $g_bDebugSetlogTrain Or $g_bDebugSetlog
	If _IsValideOCR($ToConvert) Then
		If StringInStr($ToConvert, "d") > 1 Then
			$aResult = StringSplit($ToConvert, "d", $STR_NOCOUNT)
			$iDay = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "h") > 1 Then
			$aResult = StringSplit($ToConvert, "h", $STR_NOCOUNT)
			$iHour = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "m") > 1 Then
			$aResult = StringSplit($ToConvert, "m", $STR_NOCOUNT)
			$iMinute = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "s") > 1 Then
			$aResult = StringSplit($ToConvert, "s", $STR_NOCOUNT)
			$iSecond = Number($aResult[0])
			If $iSecond = 0 And $ToConvert = "0s" Then $iSecond = 1
		EndIf
		Local $iSeconds = ($iDay * 24 * 3600) + ($iHour * 3600) + ($iMinute * 60) + $iSecond
		Switch StringLower($sReturnFormat)
			Case "time"
				$iRemainTimer = Sec2Time($iSeconds)
			Case "hour"
				$iRemainTimer = Int($iSeconds / 3600)
			Case "min"
				$iRemainTimer = Int($iSeconds / 60)
			Case "min.sec"
				$iRemainTimer = Round($iSeconds / 60, 2)
			Case "sec"
				$iRemainTimer = $iSeconds
			Case Else
				SetLog("Return Format (" & $sReturnFormat & ") is undefined.", $COLOR_ERROR)
				SetError(3, "Error processing time string")
				Return $iRemainTimer
		EndSwitch
		If $bSetLog Then SetDebugLog($WhereRead & ": OCR string ('" & $ToConvertForLog & "') -> " & $iRemainTimer, $COLOR_INFO)
		If $bSetLog And Not $bFromTrain And $iRemainTimer = 0 And StringInStr($iRemainTimer, ":") = 0 Then SetDebugLog($WhereRead & ": Bad OCR string ('" & $ToConvertForLog & "') For Format('" & $sReturnFormat & "')", $COLOR_ERROR)
	Else
		If $bSetLog And Not $bFromTrain Then SetDebugLog($WhereRead & ": Bad OCR string ('" & $ToConvertForLog & "') For Format('" & $sReturnFormat & "')", $COLOR_ERROR)
	EndIf
	Return $iRemainTimer
EndFunc   ;==>ConvertOCRTime
Func Min2Sec($iMinutes)
	Return Int($iMinutes * 60)
EndFunc   ;==>Min2Sec
Func Sec2Time($iSeconds)
	Local $sec2time_hour = Int($iSeconds / 3600)
	Local $sec2time_min = Int(($iSeconds - $sec2time_hour * 3600) / 60)
	Local $sec2time_sec = $iSeconds - $sec2time_hour * 3600 - $sec2time_min * 60
	Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
EndFunc   ;==>Sec2Time
Func Min2Time($iSeconds)
	$iSeconds = Abs(Int($iSeconds * 60))
	Local $sec2timer_day = Int($iSeconds / (3600 * 24))
	Local $sec2time_hour = Int(($iSeconds - ($sec2timer_day * (3600 * 24))) / 3600)
	Local $sec2time_min = Int(($iSeconds - ($sec2timer_day * 3600 * 24) - ($sec2time_hour * 3600)) / 60)
	Local $sec2time_sec = $iSeconds - ($sec2timer_day * 3600 * 24) - ($sec2time_hour * 3600) - ($sec2time_min * 60)
	Return StringFormat('%02dd %02dh %02dm %02ds', Abs($sec2timer_day), Abs($sec2time_hour), Abs($sec2time_min), Abs($sec2time_sec))
EndFunc   ;==>Min2Time
Func _IsValideOCR($X15288)
	If StringInStr($X15288, "d") > 0 Or StringInStr($X15288, "h") > 0 Or StringInStr($X15288, "m") > 0 Or StringInStr($X15288, "s") > 0 Then Return True
	Return False
EndFunc   ;==>_IsValideOCR
Func isProblemAffect($bNeedCaptureRegion = False)
	Local $iGray = 0x282828
	If $g_iAndroidVersionAPI >= $g_iAndroidLollipop Then $iGray = 0x424242
	If Not _ColorCheck(_GetPixelColor(253, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not _ColorCheck(_GetPixelColor(373, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not _ColorCheck(_GetPixelColor(473, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not _ColorCheck(_GetPixelColor(283, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not _ColorCheck(_GetPixelColor(320, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not _ColorCheck(_GetPixelColor(594, 395 + $g_iMidOffsetY, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf _ColorCheck(_GetPixelColor(823, 32, $bNeedCaptureRegion), Hex(0xF8FCFF, 6), 10) Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>isProblemAffect

Func IsWaitforSpellsActive()
	For $i = $DB To $g_iModeCount - 1
		If $g_abAttackTypeEnable[$i] And $g_abSearchSpellsWaitEnable[$i] Then
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("IsWaitforSpellsActive = True", $COLOR_DEBUG)
			Return True
		EndIf
	Next
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("IsWaitforSpellsActive = False", $COLOR_DEBUG)
	Return False
EndFunc   ;==>IsWaitforSpellsActive
Func IsWaitforHeroesActive()
	For $i = $DB To $g_iModeCount - 1
		If $g_abAttackTypeEnable[$i] And ($g_aiSearchHeroWaitEnable[$i] > $eHeroNone And (BitAND($g_aiAttackUseHeroes[$i], $g_aiSearchHeroWaitEnable[$i]) = $g_aiSearchHeroWaitEnable[$i]) And (Abs($g_aiSearchHeroWaitEnable[$i] - $g_iHeroUpgradingBit) > $eHeroNone)) Then
			If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("IsWaitforHeroesActive = True", $COLOR_DEBUG)
			Return True
		EndIf
	Next
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("IsWaitforHeroesActive = False", $COLOR_DEBUG)
	Return False
EndFunc   ;==>IsWaitforHeroesActive
Func getArmyCCStatus($bOpenArmyWindow = False, $bCloseArmyWindow = False, $CheckWindow = True, $bSetLog = True, $bNeedCapture = True)
	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyCCStatus:", $COLOR_DEBUG1)
	$g_iCCRemainTime = 0
	If $CheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then
			SetError(1)
			Return
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "getArmyCCStatus()") Then
				SetError(2)
				Return
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf
	$g_bCanRequestCC = IsToRequestCC()
	If $g_bDebugSetlog Then SetDebugLog("[getArmyCCStatus] Can Request CC: " & $g_bCanRequestCC, $COLOR_DEBUG)
	RequestCC(False)
	If $bCloseArmyWindow Then
		ClickP($aAway, 1, 0, "#0000")
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmyCCStatus

#ce

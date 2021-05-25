; #FUNCTION# ====================================================================================================================
; Name ..........: applyConfig.au3
; Description ...: Applies all of the  variable to the GUI
; Syntax ........: applyConfig()
; Parameters ....: $bRedrawAtExit = True, redraws bot window after config was applied
; Return values .: NA
; Author ........: Team AiO MOD++ (2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;<><><> Team AiO MOD++ (2019) <><><>
Func ApplyConfig_MOD_CustomArmyBB($TypeReadSave)
	; <><><> CustomArmyBB <><><>
	Switch $TypeReadSave
		Case "Read"
			; BB Upgrade Walls - Team AiO MOD++
			GUICtrlSetState($g_hChkBBUpgradeWalls, $g_bChkBBUpgradeWalls ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel)
			GUICtrlSetData($g_hBBWallNumber, $g_iBBWallNumber)
			GUICtrlSetState($g_hChkBBWallRing, $g_bChkBBWallRing = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBUpgWallsGold, $g_bChkBBUpgWallsGold = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBUpgWallsElixir, $g_bChkBBUpgWallsElixir = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkBBWalls()
			cmbBBWall()
			
			For $i = 0 To UBound($g_hComboTroopBB) - 1
				_GUICtrlComboBox_SetCurSel($g_hComboTroopBB[$i], $g_iCmbCampsBB[$i])
				_GUICtrlSetImage($g_hIcnTroopBB[$i], $g_sLibIconPath, $g_avStarLabTroops[$g_iCmbCampsBB[$i] + 1][4])
			Next

			GUICtrlSetState($g_hChkPlacingNewBuildings, $g_iChkPlacingNewBuildings = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkActivateBBSuggestedUpgrades()
			chkActivateBBSuggestedUpgradesGold()
			chkActivateBBSuggestedUpgradesElixir()
			chkPlacingNewBuildings()
			GUICtrlSetState($g_hChkBuilderAttack, $g_bChkBuilderAttack ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBStopAt3, $g_bChkBBStopAt3 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBTrophiesRange, $g_bChkBBTrophiesRange ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBCustomAttack, $g_bChkBBCustomAttack ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkBuilderAttack()
			PopulateComboScriptsFilesBB()
			For $i = 0 To 2
				Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], $g_sAttackScrScriptNameBB[$i])
				If $tempindex = -1 Then
					$tempindex = 0
					SetLog("Previous saved BB Scripted Attack not found (deleted, renamed?)", $COLOR_ERROR)
					SetLog("Automatically setted a default script, please check your config", $COLOR_ERROR)
				EndIf
				_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], $tempindex)
			Next
			cmbScriptNameBB()
			GUICtrlSetData($g_hTxtBBDropTrophiesMin, $g_iTxtBBDropTrophiesMin)
			GUICtrlSetData($g_hTxtBBDropTrophiesMax, $g_iTxtBBDropTrophiesMax)
			chkBBtrophiesRange()
			; -- AIO BB
			GUICtrlSetState($g_hChkOnlyBuilderBase, $g_bOnlyBuilderBase ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkOnlyBuilderBase()
			GUICtrlSetState($g_hChkBBGetFromCSV, $g_bChkBBGetFromCSV ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkBBGetFromArmy, $g_bChkBBGetFromArmy ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBAttack, $g_iCmbBBAttack) ; switching between smart and csv attack
			GUICtrlSetData($g_hTxtBBMinAttack, $g_iBBMinAttack)
			GUICtrlSetData($g_hTxtBBMaxAttack, $g_iBBMaxAttack)
			cmbBBAttack()
			ChkBBGetFromArmy()
			ChkBBGetFromCSV()
			ChkBBCustomAttack()
			ChkBBAttackLoops()
			
		Case "Save"
			; BB Upgrade Walls - Team AiO MOD++
			$g_bChkBBUpgradeWalls = (GUICtrlRead($g_hChkBBUpgradeWalls) = $GUI_CHECKED)
			$g_iCmbBBWallLevel = _GUICtrlComboBox_GetCurSel($g_hCmbBBWallLevel)
			$g_iBBWallNumber = Int(GUICtrlRead($g_hBBWallNumber))
			$g_bChkBBWallRing = (GUICtrlRead($g_hChkBBWallRing) = $GUI_CHECKED)
			$g_bChkBBUpgWallsGold = (GUICtrlRead($g_hChkBBUpgWallsGold) = $GUI_CHECKED)
			$g_bChkBBUpgWallsElixir = (GUICtrlRead($g_hChkBBUpgWallsElixir) = $GUI_CHECKED)
			
			For $i = 0 To UBound($g_hComboTroopBB) - 1
				$g_iCmbCampsBB[$i] = _GUICtrlComboBox_GetCurSel($g_hComboTroopBB[$i])
			Next

			$g_iChkPlacingNewBuildings = (GUICtrlRead($g_hChkPlacingNewBuildings) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBuilderAttack = (GUICtrlRead($g_hChkBuilderAttack) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBStopAt3 = (GUICtrlRead($g_hChkBBStopAt3) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBTrophiesRange = (GUICtrlRead($g_hChkBBTrophiesRange) = $GUI_CHECKED) ? 1 : 0
			$g_bChkBBCustomAttack = (GUICtrlRead($g_hChkBBCustomAttack) = $GUI_CHECKED) ? 1 : 0
			For $i = 0 To 2
				Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
				Local $scriptname
				_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
				$g_sAttackScrScriptNameBB[$i] = $scriptname
				IniWriteS($g_sProfileConfigPath, "BuilderBase", "ScriptBB" & $i, $g_sAttackScrScriptNameBB[$i])
			Next
			$g_iTxtBBDropTrophiesMin = Int(GUICtrlRead($g_hTxtBBDropTrophiesMin))
			$g_iTxtBBDropTrophiesMax = Int(GUICtrlRead($g_hTxtBBDropTrophiesMax))
			; -- AIO BB
			$g_bChkBBGetFromArmy = (GUICtrlRead($g_hChkBBGetFromArmy) = $GUI_CHECKED)
			$g_bChkBBGetFromCSV = (GUICtrlRead($g_hChkBBGetFromCSV) = $GUI_CHECKED)
			$g_iCmbBBAttack = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttack)
			$g_iBBMinAttack = Int(GUICtrlRead($g_hTxtBBMinAttack))
			$g_iBBMaxAttack = Int(GUICtrlRead($g_hTxtBBMaxAttack))
			$g_bOnlyBuilderBase = (GUICtrlRead($g_hChkOnlyBuilderBase) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_CustomArmyBB

Func ApplyConfig_MOD_MiscTab($TypeReadSave)
	; <><><> MiscTab <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hUseSleep, $g_bUseSleep = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hIntSleep, $g_iIntSleep)
			GUICtrlSetState($g_hUseRandomSleep, $g_bUseRandomSleep = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hNoAttackSleep, $g_bNoAttackSleep = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hDisableColorLog, $g_bDisableColorLog = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hAvoidLocation, $g_bAvoidLocation = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hEdgeObstacle, $g_bEdgeObstacle = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)

			For $i = $DB To $LB
				GUICtrlSetState($g_hDeployCastleFirst[$i], $g_bDeployCastleFirst[$i] = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			
			; Setlog limit
			GUICtrlSetState($g_hTxtLogLineLimit, ($g_bChkBotLogLineLimit) ? ($GUI_ENABLE) : ($GUI_DISABLE))
			GUICtrlSetData($g_hTxtLogLineLimit, $g_iTxtLogLineLimit)

			; Skip first check
			GUICtrlSetState($g_hAvoidLocate, $g_bAvoidLocate ? $GUI_CHECKED : $GUI_UNCHECKED)
			
			; DeployDelay
			GUICtrlSetData($g_hDeployDelay[0], $g_iDeployDelay[0])
			GUICtrlSetData($g_hDeployDelay[1], $g_iDeployDelay[1])
			GUICtrlSetData($g_hDeployDelay[2], $g_iDeployDelay[2])

			; DeployWave
			GUICtrlSetData($g_hDeployWave[0], $g_iDeployWave[0])
			GUICtrlSetData($g_hDeployWave[1], $g_iDeployWave[1])
			GUICtrlSetData($g_hDeployWave[2], $g_iDeployWave[2])

			; ChkEnableRandom
			GUICtrlSetState($g_hChkEnableRandom[0], $g_bChkEnableRandom[0] = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkEnableRandom[1], $g_bChkEnableRandom[1] = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkEnableRandom[2], $g_bChkEnableRandom[2] = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)

			; Max sides
			GUICtrlSetState($g_hMaxSidesSF, $g_bMaxSidesSF = (1) ? ($GUI_CHECKED) : ($GUI_UNCHECKED))
			GUICtrlSetData($g_hCmbMaxSidesSF, $g_iCmbMaxSidesSF)

			; Custom SmartFarm
			GUICtrlSetState($g_hChkSmartFarmAndRandomDeploy, $g_bUseSmartFarmAndRandomDeploy = (1) ? ($GUI_CHECKED) : ($GUI_UNCHECKED))

			; War Preparation
			GUICtrlSetState($g_hChkStopForWar, $g_bStopForWar ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbStopTime, Abs($g_iStopTime))
			_GUICtrlComboBox_SetCurSel($g_hCmbStopBeforeBattle, $g_iStopTime < 0 ? 0 : 1)
			_GUICtrlComboBox_SetCurSel($g_hCmbReturnTime, $g_iReturnTime)

			GUICtrlSetState($g_hChkTrainWarTroop, $g_bTrainWarTroop ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkUseQuickTrainWar, $g_bUseQuickTrainWar ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_ahChkArmyWar[0], $g_aChkArmyWar[0] ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_ahChkArmyWar[1], $g_aChkArmyWar[1] ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_ahChkArmyWar[2], $g_aChkArmyWar[2] ? $GUI_CHECKED : $GUI_UNCHECKED)

			For $i = 0 To $eTroopCount - 1
				GUICtrlSetData($g_ahTxtTrainWarTroopCount[$i], $g_aiWarCompTroops[$i])
			Next
			
			For $j = 0 To $eSpellCount - 1
				GUICtrlSetData($g_ahTxtTrainWarSpellCount[$j], $g_aiWarCompSpells[$j])
			Next
			GUICtrlSetState($g_hChkRequestCCForWar, $g_bRequestCCForWar ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtRequestCCForWar, $g_sTxtRequestCCForWar)

			; Request form chat / on a loop / Type once - Team AIO Mod++
			GUICtrlSetState($g_hChkReqCCAlways, $g_bChkReqCCAlways ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkReqCCFromChat, $g_bChkReqCCFromChat ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkRequestOneTimeEnable, $g_bRequestOneTimeEnable ? $GUI_CHECKED : $GUI_UNCHECKED)

			; Donation records.
			GUICtrlSetData($g_hDayLimitTroops, _NumberFormat($g_iDayLimitTroops, True))
			GUICtrlSetData($g_hDayLimitSpells, _NumberFormat($g_iDayLimitSpells, True))
			GUICtrlSetData($g_hDayLimitSieges, _NumberFormat($g_iDayLimitSieges, True))
			GUICtrlSetData($g_hCmbRestartEvery, _NumberFormat($g_iCmbRestartEvery, True))
			
			
			For $i = 0 To $eTroopCount - 1
				GUICtrlSetData($g_hLblDayTroop[$i], _NumberFormat($g_aiDonateStatsTroops[$i][0], True)) ; Donation records - Team AIO Mod++
			Next

			GUICtrlSetData($g_hDayTotalTroops, _NumberFormat($g_iTotalDonateStatsTroops, True)) ; Donation records - Team AIO Mod++

			For $i = 0 To $eSpellCount - 1
				GUICtrlSetData($g_hLblDaySpell[$i], _NumberFormat($g_aiDonateStatsSpells[$i][0], True)) ; Donation records - Team AIO Mod++
			Next
			
			GUICtrlSetData($g_hDayTotalSpells, _NumberFormat($g_iTotalDonateStatsSpells, True)) ; Donation records - Team AIO Mod++

			For $i = 0 To $eSiegeMachineCount - 1
				GUICtrlSetData($g_hLblDaySiege[$i], _NumberFormat($g_aiDonateStatsSieges[$i][0], True)) ; Donation records - Team AIO Mod++
			Next

			GUICtrlSetData($g_hDayTotalSieges, _NumberFormat($g_iTotalDonateStatsSiegeMachines, True)) ; Donation records - Team AIO Mod++

			#Region - Return Home by Time - Team AIO Mod++
			GUICtrlSetState($g_hChkReturnTimerEnable, $g_bReturnTimerEnable ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtReturnTimer, $g_iTxtReturnTimer)
			chkReturnTimer()
			#EndRegion - Return Home by Time - Team AIO Mod++

			#Region - No Upgrade In War - Team AIO Mod++
			GUICtrlSetState($g_hChkNoUpgradeInWar, $g_bNoUpgradeInWar ? $GUI_CHECKED : $GUI_UNCHECKED)
			#EndRegion - No Upgrade In War - Team AIO Mod++
			
			#Region - Legend trophy protection - Team AIO Mod++
			GUICtrlSetState($g_hChkProtectInLL, $g_bProtectInLL ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkForceProtectLL, $g_bForceProtectLL ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkProtectInLL()
			#EndRegion - Legend trophy protection - Team AIO Mod++

			#Region - Custom Improve - Team AIO Mod++
			For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
				GUICtrlSetState($g_hChkBBUpgradesToIgnore[$i], $g_iChkBBUpgradesToIgnore[$i] = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			chkBBUpgradesToIgnore()
			#EndRegion - Custom Improve - Team AIO Mod++

			#Region - Buy Guard - Team AIO Mod++
			GUICtrlSetState($g_hChkBuyGuard, $g_bChkBuyGuard ? $GUI_CHECKED : $GUI_UNCHECKED)
			#EndRegion - Buy Guard - Team AIO Mod++

			#Region - Colorful attack log - Team AIO Mod++
			GUICtrlSetState($g_hChkColorfulAttackLog, $g_bChkColorfulAttackLog ? $GUI_CHECKED : $GUI_UNCHECKED)
			#EndRegion - Colorful attack log - Team AIO Mod++

			chkMaxSidesSF()
			ChkReqCCAlways()
			ChkReqCCFromChat()
			ReadConfig_600_52_2()
			ChkStopForWar()
			chkDelayMod()
			chkEdgeObstacle()
			InputRecords()
		Case "Save"
			$g_bUseSleep = (GUICtrlRead($g_hUseSleep) = $GUI_CHECKED) ? 1 : 0
			$g_iIntSleep = Int(GUICtrlRead($g_hIntSleep))
			$g_bUseRandomSleep = (GUICtrlRead($g_hUseRandomSleep) = $GUI_CHECKED) ? 1 : 0
			$g_bNoAttackSleep = (GUICtrlRead($g_hNoAttackSleep) = $GUI_CHECKED) ? 1 : 0
			$g_bDisableColorLog = (GUICtrlRead($g_hDisableColorLog) = $GUI_CHECKED) ? 1 : 0
			$g_bAvoidLocation = (GUICtrlRead($g_hAvoidLocation) = $GUI_CHECKED) ? 1 : 0
			
			For $i = $DB To $LB
				$g_bDeployCastleFirst[$i] = (GUICtrlRead($g_hDeployCastleFirst[$i]) = $GUI_CHECKED) ? 1 : 0
			Next
			
			; Setlog limit
			$g_bChkBotLogLineLimit = (GUICtrlRead($g_hChkBotLogLineLimit) = $GUI_CHECKED) ? (True) : (False)
			$g_iTxtLogLineLimit = Int(GUICtrlRead($g_hTxtLogLineLimit))

			; Skip first check
			$g_bAvoidLocate = GUICtrlRead($g_hAvoidLocate) = $GUI_CHECKED
			
			; Remove edge obstacles
			$g_bEdgeObstacle = GUICtrlRead($g_hEdgeObstacle) = $GUI_CHECKED
			
			; DeployDelay
			$g_iDeployDelay[0] = Int(GUICtrlRead($g_hDeployDelay[0]))
			$g_iDeployDelay[1] = Int(GUICtrlRead($g_hDeployDelay[1]))
			$g_iDeployDelay[2] = Int(GUICtrlRead($g_hDeployDelay[2]))
			
			; DeployWave
			$g_iDeployWave[0] = Int(GUICtrlRead($g_hDeployWave[0]))
			$g_iDeployWave[1] = Int(GUICtrlRead($g_hDeployWave[1]))
			$g_iDeployWave[2] = Int(GUICtrlRead($g_hDeployWave[2]))

			; ChkEnableRandom
			$g_bChkEnableRandom[0] = (GUICtrlRead($g_hChkEnableRandom[0]) = $GUI_CHECKED) ? 1 : 0
			$g_bChkEnableRandom[1] = (GUICtrlRead($g_hChkEnableRandom[1]) = $GUI_CHECKED) ? 1 : 0
			$g_bChkEnableRandom[2] = (GUICtrlRead($g_hChkEnableRandom[2]) = $GUI_CHECKED) ? 1 : 0

			; Max sides
			$g_bMaxSidesSF = (GUICtrlRead($g_hMaxSidesSF) = $GUI_CHECKED) ? 1 : 0
			$g_iCmbMaxSidesSF = Int(GUICtrlRead($g_hCmbMaxSidesSF))

			; Custom SmartFarm
			$g_bUseSmartFarmAndRandomDeploy = (GUICtrlRead($g_hChkSmartFarmAndRandomDeploy) = $GUI_CHECKED) ? 1 : 0

			; War Preparation
			$g_bStopForWar = GUICtrlRead($g_hChkStopForWar) = $GUI_CHECKED

			$g_iStopTime = _GUICtrlComboBox_GetCurSel($g_hCmbStopTime)
			If _GUICtrlComboBox_GetCurSel($g_hCmbStopBeforeBattle) = 0 Then $g_iStopTime = $g_iStopTime * -1
			$g_iReturnTime = _GUICtrlComboBox_GetCurSel($g_hCmbReturnTime)

			$g_bTrainWarTroop = GUICtrlRead($g_hChkTrainWarTroop) = $GUI_CHECKED
			$g_bUseQuickTrainWar = GUICtrlRead($g_hChkUseQuickTrainWar) = $GUI_CHECKED
			$g_aChkArmyWar[0] = GUICtrlRead($g_ahChkArmyWar[0]) = $GUI_CHECKED
			$g_aChkArmyWar[1] = GUICtrlRead($g_ahChkArmyWar[1]) = $GUI_CHECKED
			$g_aChkArmyWar[2] = GUICtrlRead($g_ahChkArmyWar[2]) = $GUI_CHECKED
			For $i = 0 To $eTroopCount - 1
				$g_aiWarCompTroops[$i] = GUICtrlRead($g_ahTxtTrainWarTroopCount[$i])
			Next
			For $j = 0 To $eSpellCount - 1
				$g_aiWarCompSpells[$j] = GUICtrlRead($g_ahTxtTrainWarSpellCount[$j])
			Next

			$g_bRequestCCForWar = GUICtrlRead($g_hChkRequestCCForWar) = $GUI_CHECKED
			$g_sTxtRequestCCForWar = GUICtrlRead($g_hTxtRequestCCForWar)

			; Request form chat / on a loop / Type once - Team AIO Mod++
			$g_bChkReqCCAlways = GUICtrlRead($g_hChkReqCCAlways) = $GUI_CHECKED
			$g_bChkReqCCFromChat = GUICtrlRead($g_hChkReqCCFromChat) = $GUI_CHECKED
			$g_bRequestOneTimeEnable = GUICtrlRead($g_hChkRequestOneTimeEnable) = $GUI_CHECKED

			; Donation records.
			$g_iDayLimitTroops = GUICtrlRead($g_hDayLimitTroops)
			$g_iDayLimitSpells = GUICtrlRead($g_hDayLimitSpells)
			$g_iDayLimitSieges = GUICtrlRead($g_hDayLimitSieges)
			$g_iCmbRestartEvery = GUICtrlRead($g_hCmbRestartEvery)
			
			; Tooops;
			For $i = 0 To $eTroopCount - 1
				$g_aiDonateStatsTroops[$i][0] = GUICtrlRead($g_hLblDayTroop[$i])
			Next
			$g_iTotalDonateStatsTroops = GUICtrlRead($g_hDayTotalTroops)
			
			; Spell;
			For $i = 0 To $eSpellCount - 1
				$g_aiDonateStatsSpells[$i][0] = GUICtrlRead($g_hLblDaySpell[$i])
			Next
			$g_iTotalDonateStatsSpells = GUICtrlRead($g_hDayTotalSpells)
			
			; Siege;
			For $i = 0 To $eSiegeMachineCount - 1
				$g_aiDonateStatsSieges[$i][0] = GUICtrlRead($g_hLblDaySiege[$i])
			Next
			$g_iTotalDonateStatsSiegeMachines = GUICtrlRead($g_hDayTotalSieges)
			; ------------;
			
			#Region - Return Home by Time - Team AIO Mod++
			$g_bReturnTimerEnable = (GUICtrlRead($g_hChkReturnTimerEnable) = $GUI_CHECKED)
			$g_iTxtReturnTimer = GUICtrlRead($g_hTxtReturnTimer)
			#EndRegion - Return Home by Time - Team AIO Mod++
		
			#Region - Legend trophy protection - Team AIO Mod++
			$g_bProtectInLL = (GUICtrlRead($g_hChkProtectInLL) = $GUI_CHECKED)
			$g_bForceProtectLL = (GUICtrlRead($g_hChkForceProtectLL) = $GUI_CHECKED)
			#EndRegion - Legend trophy protection - Team AIO Mod++
			
			#Region - No Upgrade In War - Team AIO Mod++
			$g_bNoUpgradeInWar = (GUICtrlRead($g_hChkNoUpgradeInWar) = $GUI_CHECKED)
			#EndRegion - No Upgrade In War - Team AIO Mod++
			
			#Region - Custom Improve - Team AIO Mod++
			For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
				$g_iChkBBUpgradesToIgnore[$i] = GUICtrlRead($g_hChkBBUpgradesToIgnore[$i]) = $GUI_CHECKED ? 1 : 0
			Next
			#EndRegion - Custom Improve - Team AIO Mod++
			
			#Region - Buy Guard - Team AIO Mod++
			$g_bChkBuyGuard = (GUICtrlRead($g_hChkBuyGuard) = $GUI_CHECKED)
			#EndRegion - Buy Guard - Team AIO Mod++

			#Region - Colorful attack log - Team AIO Mod++
			$g_bChkColorfulAttackLog = (GUICtrlRead($g_hChkColorfulAttackLog) = $GUI_CHECKED)
			#EndRegion - Colorful attack log - Team AIO Mod++
	EndSwitch

EndFunc   ;==>ApplyConfig_MOD_MiscTab

Func ApplyConfig_MOD_SuperXP($TypeReadSave)
	; <><><> SuperXP / GoblinXP <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkEnableSuperXP, $g_bEnableSuperXP ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkEnableSuperXP()
			GUICtrlSetState($g_hChkSkipZoomOutSX, $g_bSkipZoomOutSX ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkFastSuperXP, $g_bFastSuperXP ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkSkipDragToEndSX, $g_bSkipDragToEndSX ? $GUI_CHECKED : $GUI_UNCHECKED)
			radActivateOptionSX()
			radGoblinMapOptSX()
			radLblGoblinMapOpt()

			GUICtrlSetData($g_hTxtMaxXPToGain, $g_iMaxXPtoGain)
			GUICtrlSetState($g_hChkBKingSX, $g_bBKingSX = $eHeroKing ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkAQueenSX, $g_bAQueenSX = $eHeroQueen ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkGWardenSX, $g_bGWardenSX = $eHeroWarden ? $GUI_CHECKED : $GUI_UNCHECKED)
		Case "Save"
			$g_bEnableSuperXP = (GUICtrlRead($g_hChkEnableSuperXP) = $GUI_CHECKED)
			$g_bSkipZoomOutSX = (GUICtrlRead($g_hChkSkipZoomOutSX) = $GUI_CHECKED)
			$g_bFastSuperXP = (GUICtrlRead($g_hChkFastSuperXP) = $GUI_CHECKED)
			$g_bSkipDragToEndSX = (GUICtrlRead($g_hChkSkipDragToEndSX) = $GUI_CHECKED)
			If GUICtrlRead($g_hRdoTrainingSX) = $GUI_CHECKED Then
				$g_iActivateOptionSX = 1
			ElseIf GUICtrlRead($g_hRdoAttackingSX) = $GUI_CHECKED Then
				$g_iActivateOptionSX = 2
			EndIf
			If GUICtrlRead($g_hRdoGoblinPicnic) = $GUI_CHECKED Then
				$g_iGoblinMapOptSX = 1
			ElseIf GUICtrlRead($g_hRdoTheArena) = $GUI_CHECKED Then
				$g_iGoblinMapOptSX = 2
			EndIf

			$g_iMaxXPtoGain = GUICtrlRead($g_hTxtMaxXPToGain)
			$g_bBKingSX = (GUICtrlRead($g_hChkBKingSX) = $GUI_CHECKED) ? $eHeroKing : $eHeroNone
			$g_bAQueenSX = (GUICtrlRead($g_hChkAQueenSX) = $GUI_CHECKED) ? $eHeroQueen : $eHeroNone
			$g_bGWardenSX = (GUICtrlRead($g_hChkGWardenSX) = $GUI_CHECKED) ? $eHeroWarden : $eHeroNone
	EndSwitch

EndFunc   ;==>ApplyConfig_MOD_SuperXP

Func ApplyConfig_MOD_MagicItems($TypeReadSave)
	; <><><> MagicItems <><><>

	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetData($g_hInputGoldItems, $g_iInputGoldItems)
			GUICtrlSetData($g_hInputElixirItems, $g_iInputElixirItems)
			GUICtrlSetData($g_hInputDarkElixirItems, $g_iInputDarkElixirItems)

			GUICtrlSetData($g_hInputBuilderPotion, $g_iInputBuilderPotion)
			GUICtrlSetData($g_hInputLabPotion, $g_iInputLabPotion)

			_GUICtrlComboBox_SetCurSel($g_hComboClockTowerPotion, $g_iComboClockTowerPotion)
			_GUICtrlComboBox_SetCurSel($g_hComboHeroPotion, $g_iComboHeroPotion)
			_GUICtrlComboBox_SetCurSel($g_hComboPowerPotion, $g_iComboPowerPotion)

			GUICtrlSetState($g_hChkCollectMagicItems, $g_bChkCollectMagicItems = True ? $GUI_CHECKED : $GUI_UNCHECKED)

			GUICtrlSetState($g_hChkBuilderPotion, $g_bChkBuilderPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkClockTowerPotion, $g_bChkClockTowerPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkHeroPotion, $g_bChkHeroPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkLabPotion, $g_bChkLabPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkPowerPotion, $g_bChkPowerPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkResourcePotion, $g_bChkResourcePotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)

		Case "Save"
			$g_iInputGoldItems = GUICtrlRead($g_hInputGoldItems)
			$g_iInputElixirItems = GUICtrlRead($g_hInputElixirItems)
			$g_iInputDarkElixirItems = GUICtrlRead($g_hInputDarkElixirItems)

			$g_iInputBuilderPotion = GUICtrlRead($g_hInputBuilderPotion)
			$g_iInputLabPotion = GUICtrlRead($g_hInputLabPotion)

			$g_iComboPowerPotion = _GUICtrlComboBox_GetCurSel($g_hComboPowerPotion)
			$g_iComboHeroPotion = _GUICtrlComboBox_GetCurSel($g_hComboHeroPotion)
			$g_iComboClockTowerPotion = _GUICtrlComboBox_GetCurSel($g_hComboClockTowerPotion)

			$g_bChkCollectMagicItems = (GUICtrlRead($g_hChkCollectMagicItems) = $GUI_CHECKED)

			$g_bChkBuilderPotion = (GUICtrlRead($g_hChkBuilderPotion) = $GUI_CHECKED)
			$g_bChkClockTowerPotion = (GUICtrlRead($g_hChkClockTowerPotion) = $GUI_CHECKED)
			$g_bChkHeroPotion = (GUICtrlRead($g_hChkHeroPotion) = $GUI_CHECKED)
			$g_bChkLabPotion = (GUICtrlRead($g_hChkLabPotion) = $GUI_CHECKED)
			$g_bChkPowerPotion = (GUICtrlRead($g_hChkPowerPotion) = $GUI_CHECKED)
			$g_bChkResourcePotion = (GUICtrlRead($g_hChkResourcePotion) = $GUI_CHECKED)
	EndSwitch

EndFunc   ;==>ApplyConfig_MOD_MagicItems

Func ApplyConfig_MOD_ChatActions($TypeReadSave)
	; <><><> ChatActions <><><>
	Switch $TypeReadSave
		Case "Read"
			_GUICtrlComboBox_SetCurSel($g_acmbPriority[10], $g_iacmbPriority[10])
			_GUICtrlComboBox_SetCurSel($g_acmbPriority[11], $g_iacmbPriority[11])

			; GUICtrlSetState($g_hChkClanChat, $g_bChatClan = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDelayTimeClan, $g_sDelayTimeClan)
			GUICtrlSetState($g_hChkUseResponses, $g_bClanUseResponses = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkUseGeneric, $g_bClanUseGeneric = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkCleverbot, $g_bCleverbot = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkChatNotify, $g_bUseNotify = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkPbSendNewChats, $g_bPbSendNew = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			cmbChatActionsChat()

			; GUICtrlSetState($g_hChkEnableFriendlyChallenge, $g_bEnableFriendlyChallenge = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDelayTimeFC, $g_sDelayTimeFC)
			GUICtrlSetState($g_hChkOnlyOnRequest, $g_bOnlyOnRequest = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			For $i = 0 To 5
				GUICtrlSetState($g_hChkFriendlyChallengeBase[$i], $g_bFriendlyChallengeBase[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			For $i = 0 To 23
				GUICtrlSetState($g_ahChkFriendlyChallengeHours[$i], $g_abFriendlyChallengeHours[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			cmbChatActionsFC()
			ChatGuiEditUpdate()
		Case "Save"
			$g_iacmbPriority[10] = _GUICtrlComboBox_GetCurSel($g_acmbPriority[10])
			$g_iacmbPriority[11] = _GUICtrlComboBox_GetCurSel($g_acmbPriority[11])

			; $g_bChatClan = (GUICtrlRead($g_hChkClanChat) = $GUI_CHECKED)
			$g_sDelayTimeClan = GUICtrlRead($g_hTxtDelayTimeClan)
			$g_bClanUseResponses = (GUICtrlRead($g_hChkUseResponses) = $GUI_CHECKED)
			$g_bClanUseGeneric = (GUICtrlRead($g_hChkUseGeneric) = $GUI_CHECKED)
			$g_bCleverbot = (GUICtrlRead($g_hChkCleverbot) = $GUI_CHECKED)
			$g_bUseNotify = (GUICtrlRead($g_hChkChatNotify) = $GUI_CHECKED)
			$g_bPbSendNew = (GUICtrlRead($g_hChkPbSendNewChats) = $GUI_CHECKED)

			; $g_bEnableFriendlyChallenge = (GUICtrlRead($g_hChkEnableFriendlyChallenge) = $GUI_CHECKED)
			$g_sDelayTimeFC = GUICtrlRead($g_hTxtDelayTimeFC)
			$g_bOnlyOnRequest = (GUICtrlRead($g_hChkOnlyOnRequest) = $GUI_CHECKED)
			For $i = 0 To 5
				$g_bFriendlyChallengeBase[$i] = (GUICtrlRead($g_hChkFriendlyChallengeBase[$i]) = $GUI_CHECKED)
			Next
			For $i = 0 To 23
				$g_abFriendlyChallengeHours[$i] = (GUICtrlRead($g_ahChkFriendlyChallengeHours[$i]) = $GUI_CHECKED)
			Next
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_ChatActions

Func ApplyConfig_MOD_600_6($TypeReadSave)
	; <><><> Daily Discounts + Builder Base Attack + Builder Base Drop Order <><><>
	Switch $TypeReadSave
		Case "Read"
			For $i = 0 To $g_iDDCount - 1
				GUICtrlSetState($g_ahChkDD_Deals[$i], $g_abChkDD_Deals[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			;GUICtrlSetBkColor($g_hBtnMagicItemsConfig, $g_bChkCollectMagicItems = True ? $COLOR_GREEN : $COLOR_RED)
			btnDDApply()
		Case "Save"
			For $i = 0 To $g_iDDCount - 1
				$g_abChkDD_Deals[$i] = (GUICtrlRead($g_ahChkDD_Deals[$i]) = $GUI_CHECKED)
			Next

			$g_bChkEnableBBAttack = (GUICtrlRead($g_hChkEnableBBAttack) = $GUI_CHECKED)
			$g_bChkBBTrophyRange = (GUICtrlRead($g_hChkBBTrophyRange) = $GUI_CHECKED)
			$g_iTxtBBTrophyLowerLimit = GUICtrlRead($g_hTxtBBTrophyLowerLimit)
			$g_iTxtBBTrophyUpperLimit = GUICtrlRead($g_hTxtBBTrophyUpperLimit)
			$g_bChkBBAttIfLootAvail = (GUICtrlRead($g_hChkBBAttIfLootAvail) = $GUI_CHECKED)
			; $g_bChkBBWaitForMachine = (GUICtrlRead($g_hChkBBWaitForMachine) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_6

Func ApplyConfig_MOD_600_12($TypeReadSave)
	; <><><> GTFO <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkGTFOClanHop, $g_bChkGTFOClanHop = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkGTFOReturnClan, $g_bChkGTFOReturnClan = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtCyclesGTFO, $g_iTxtCyclesGTFO)
			GUICtrlSetState($g_hChkUseGTFO, $g_bChkUseGTFO = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtMinSaveGTFO_Elixir, $g_iTxtMinSaveGTFO_Elixir)
			GUICtrlSetData($g_hTxtMinSaveGTFO_DE, $g_iTxtMinSaveGTFO_DE)
			GUICtrlSetData($g_hTxtClanID, $g_sTxtClanID)
			ApplyGTFO()

			GUICtrlSetState($g_hChkUseKickOut, $g_bChkUseKickOut = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDonatedCap, $g_iTxtDonatedCap)
			GUICtrlSetData($g_hTxtReceivedCap, $g_iTxtReceivedCap)
			GUICtrlSetState($g_hChkKickOutSpammers, $g_bChkKickOutSpammers = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtKickLimit, $g_iTxtKickLimit)
			ApplyKickOut()

		Case "Save"
			$g_bChkGTFOClanHop = (GUICtrlRead($g_hChkGTFOClanHop) = $GUI_CHECKED)
			$g_bChkGTFOReturnClan = (GUICtrlRead($g_hChkGTFOReturnClan) = $GUI_CHECKED)
			$g_iTxtCyclesGTFO = Number(GUICtrlRead($g_hTxtCyclesGTFO))
			$g_sTxtClanID = GUICtrlRead($g_hTxtClanID)

			$g_bChkUseGTFO = (GUICtrlRead($g_hChkUseGTFO) = $GUI_CHECKED)
			$g_bExitAfterCyclesGTFO = (GUICtrlRead($g_hExitAfterCyclesGTFO) = $GUI_CHECKED)
			$g_iTxtMinSaveGTFO_Elixir = Number(GUICtrlRead($g_hTxtMinSaveGTFO_Elixir))
			$g_iTxtMinSaveGTFO_DE = Number(GUICtrlRead($g_hTxtMinSaveGTFO_DE))
			$g_bChkUseKickOut = (GUICtrlRead($g_hChkUseKickOut) = $GUI_CHECKED)
			$g_iTxtDonatedCap = Number(GUICtrlRead($g_hTxtDonatedCap))
			$g_iTxtReceivedCap = Number(GUICtrlRead($g_hTxtReceivedCap))
			$g_bChkKickOutSpammers = (GUICtrlRead($g_hChkKickOutSpammers) = $GUI_CHECKED)
			$g_iTxtKickLimit = Number(GUICtrlRead($g_hTxtKickLimit))
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_12

Func ApplyConfig_MOD_600_28($TypeReadSave)
	; <><><> Max logout time <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkTrainLogoutMaxTime, $g_bTrainLogoutMaxTime = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkTrainLogoutMaxTime()
			GUICtrlSetData($g_hTxtTrainLogoutMaxTime, $g_iTrainLogoutMaxTime)

			; Check No League for Dead Base
			GUICtrlSetState($g_hChkDBNoLeague, $g_bChkNoLeague[$DB] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
		Case "Save"
			$g_bTrainLogoutMaxTime = (GUICtrlRead($g_hChkTrainLogoutMaxTime) = $GUI_CHECKED)
			$g_iTrainLogoutMaxTime = GUICtrlRead($g_hTxtTrainLogoutMaxTime)

			; Check No League for Dead Base
			$g_bChkNoLeague[$DB] = (GUICtrlRead($g_hChkDBNoLeague) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_28

Func ApplyConfig_MOD_600_29($TypeReadSave)
	; <><><> Classic Four Finger + CSV Deploy Speed <><><>
	Switch $TypeReadSave
		Case "Read"
			cmbStandardDropSidesAB()
			cmbStandardDropSidesDB()

			_GUICtrlComboBox_SetCurSel($cmbCSVSpeed[$LB], $icmbCSVSpeed[$LB])
			_GUICtrlComboBox_SetCurSel($cmbCSVSpeed[$DB], $icmbCSVSpeed[$DB])
		Case "Save"
			$icmbCSVSpeed[$LB] = _GUICtrlComboBox_GetCurSel($cmbCSVSpeed[$LB])
			$icmbCSVSpeed[$DB] = _GUICtrlComboBox_GetCurSel($cmbCSVSpeed[$DB])
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_29

Func ApplyConfig_MOD_600_31($TypeReadSave)
	; <><><> Check Collectors Outside <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkDBMeetCollectorOutside, $g_bDBMeetCollectorOutside = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkDBCollectorNone, $g_bDBCollectorNone = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDBMinCollectorOutsidePercent, $g_iDBMinCollectorOutsidePercent)

			GUICtrlSetState($g_hChkDBCollectorNearRedline, $g_bDBCollectorNearRedline = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbRedlineTiles, $g_iCmbRedlineTiles)

			GUICtrlSetState($g_hChkSkipCollectorCheck, $g_bSkipCollectorCheck = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtSkipCollectorGold, $g_iTxtSkipCollectorGold)
			GUICtrlSetData($g_hTxtSkipCollectorElixir, $g_iTxtSkipCollectorElixir)
			GUICtrlSetData($g_hTxtSkipCollectorDark, $g_iTxtSkipCollectorDark)

			GUICtrlSetState($g_hChkSkipCollectorCheckTH, $g_bSkipCollectorCheckTH = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbSkipCollectorCheckTH, $g_iCmbSkipCollectorCheckTH)
			aplCollectorsAndRedLines()
		Case "Save"
			$g_bDBMeetCollectorOutside = (GUICtrlRead($g_hChkDBMeetCollectorOutside) = $GUI_CHECKED)
			$g_bDBCollectorNone = (GUICtrlRead($g_hChkDBCollectorNone) = $GUI_CHECKED)
			$g_iDBMinCollectorOutsidePercent = GUICtrlRead($g_hTxtDBMinCollectorOutsidePercent)

			$g_bDBCollectorNearRedline = (GUICtrlRead($g_hChkDBCollectorNearRedline) = $GUI_CHECKED)
			$g_iCmbRedlineTiles = _GUICtrlComboBox_GetCurSel($g_hCmbRedlineTiles)

			$g_bSkipCollectorCheck = (GUICtrlRead($g_hChkSkipCollectorCheck) = $GUI_CHECKED)
			$g_iTxtSkipCollectorGold = GUICtrlRead($g_hTxtSkipCollectorGold)
			$g_iTxtSkipCollectorElixir = GUICtrlRead($g_hTxtSkipCollectorElixir)
			$g_iTxtSkipCollectorDark = GUICtrlRead($g_hTxtSkipCollectorDark)

			$g_bSkipCollectorCheckTH = (GUICtrlRead($g_hChkSkipCollectorCheckTH) = $GUI_CHECKED)
			$g_iCmbSkipCollectorCheckTH = _GUICtrlComboBox_GetCurSel($g_hCmbSkipCollectorCheckTH)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_31

Func ApplyConfig_MOD_600_35_1($TypeReadSave)
	; <><><> Auto Dock, Hide Emulator & Bot <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkEnableAuto, $g_bEnableAuto = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkEnableAuto()
			GUICtrlSetState($g_hChkAutoDock, $g_bChkAutoDock = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkAutoHideEmulator, $g_bChkAutoHideEmulator = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			btnEnableAuto()
			GUICtrlSetState($g_hChkAutoMinimizeBot, $g_bChkAutoMinimizeBot = True ? $GUI_CHECKED : $GUI_UNCHECKED)

			; <><><> Only Farm <><><>
			GUICtrlSetState($g_hChkOnlyFarm, $g_bChkOnlyFarm = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			UpdateChkOnlyFarm() ;Applies it to farm button

		Case "Save"
			$g_bEnableAuto = (GUICtrlRead($g_hChkEnableAuto) = $GUI_CHECKED)
			$g_bChkAutoDock = (GUICtrlRead($g_hChkAutoDock) = $GUI_CHECKED)
			$g_bChkAutoHideEmulator = (GUICtrlRead($g_hChkAutoHideEmulator) = $GUI_CHECKED)
			$g_bChkAutoMinimizeBot = (GUICtrlRead($g_hChkAutoMinimizeBot) = $GUI_CHECKED)

			; <><><> Only Farm <><><>
			$g_bChkOnlyFarm = (GUICtrlRead($g_hChkOnlyFarm) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_35_1

Func ApplyConfig_MOD_600_35_2($TypeReadSave)
	; <><><><> Switch Profiles <><><><>
	Switch $TypeReadSave
		Case "Read"
			For $i = 0 To 3
				GUICtrlSetState($g_ahChk_SwitchMax[$i], $g_abChkSwitchMax[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				GUICtrlSetState($g_ahChk_SwitchMin[$i], $g_abChkSwitchMin[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				_GUICtrlComboBox_SetCurSel($g_ahCmb_SwitchMax[$i], $g_aiCmbSwitchMax[$i])
				_GUICtrlComboBox_SetCurSel($g_ahCmb_SwitchMin[$i], $g_aiCmbSwitchMin[$i])

				GUICtrlSetState($g_ahChk_BotTypeMax[$i], $g_abChkBotTypeMax[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				GUICtrlSetState($g_ahChk_BotTypeMin[$i], $g_abChkBotTypeMin[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				_GUICtrlComboBox_SetCurSel($g_ahCmb_BotTypeMax[$i], $g_aiCmbBotTypeMax[$i])
				_GUICtrlComboBox_SetCurSel($g_ahCmb_BotTypeMin[$i], $g_aiCmbBotTypeMin[$i])

				GUICtrlSetData($g_ahTxt_ConditionMax[$i], $g_aiConditionMax[$i])
				GUICtrlSetData($g_ahTxt_ConditionMin[$i], $g_aiConditionMin[$i])
			Next
			chkSwitchProfile()
			chkSwitchBotType()
		Case "Save"
			For $i = 0 To 3
				$g_abChkSwitchMax[$i] = (GUICtrlRead($g_ahChk_SwitchMax[$i]) = $GUI_CHECKED)
				$g_abChkSwitchMin[$i] = (GUICtrlRead($g_ahChk_SwitchMin[$i]) = $GUI_CHECKED)
				$g_aiCmbSwitchMax[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_SwitchMax[$i])
				$g_aiCmbSwitchMin[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_SwitchMin[$i])

				$g_abChkBotTypeMax[$i] = (GUICtrlRead($g_ahChk_BotTypeMax[$i]) = $GUI_CHECKED)
				$g_abChkBotTypeMin[$i] = (GUICtrlRead($g_ahChk_BotTypeMin[$i]) = $GUI_CHECKED)
				$g_aiCmbBotTypeMax[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_BotTypeMax[$i])
				$g_aiCmbBotTypeMin[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_BotTypeMin[$i])

				$g_aiConditionMax[$i] = GUICtrlRead($g_ahTxt_ConditionMax[$i])
				$g_aiConditionMin[$i] = GUICtrlRead($g_ahTxt_ConditionMin[$i])
			Next
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_35_2

Func ApplyConfig_MOD_Humanization($TypeReadSave)
	; <><><><> Humanization <><><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkUseBotHumanization, $g_bUseBotHumanization ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkUseAltRClick, $g_bUseAltRClick ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkLookAtRedNotifications, $g_bLookAtRedNotifications ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkUseBotHumanization()
			For $i = 0 To UBound($g_iacmbPriority) -1
				If $i > 9 Then ExitLoop
				_GUICtrlComboBox_SetCurSel($g_acmbPriority[$i], $g_iacmbPriority[$i])
			Next
			For $i = 0 To 1
				_GUICtrlComboBox_SetCurSel($g_acmbMaxSpeed[$i], $g_iacmbMaxSpeed[$i])
			Next
			For $i = 0 To 1
				_GUICtrlComboBox_SetCurSel($g_acmbPause[$i], $g_iacmbPause[$i])
			Next
			; For $i = 0 To 1
				; GUICtrlSetData($g_ahumanMessage[$i], $g_iahumanMessage[$i])
			; Next
			_GUICtrlComboBox_SetCurSel($g_hCmbMaxActionsNumber, $g_iCmbMaxActionsNumber)
			; GUICtrlSetData($g_hChallengeMessage, $g_iTxtChallengeMessage)
			cmbStandardReplay()
			cmbWarReplay()
		Case "Save"
			$g_bUseBotHumanization = (GUICtrlRead($g_hChkUseBotHumanization) = $GUI_CHECKED)
			$g_bUseAltRClick = (GUICtrlRead($g_hChkUseAltRClick) = $GUI_CHECKED)
			$g_bLookAtRedNotifications = (GUICtrlRead($g_hChkLookAtRedNotifications) = $GUI_CHECKED)
			For $i = 0 To UBound($g_iacmbPriority) -1
				If $i > 9 Then ExitLoop
				$g_iacmbPriority[$i] = _GUICtrlComboBox_GetCurSel($g_acmbPriority[$i])
			Next
			For $i = 0 To 1
				$g_iacmbMaxSpeed[$i] = _GUICtrlComboBox_GetCurSel($g_acmbMaxSpeed[$i])
			Next
			For $i = 0 To 1
				$g_iacmbPause[$i] = _GUICtrlComboBox_GetCurSel($g_acmbPause[$i])
			Next
			; For $i = 0 To 1
				; $g_iahumanMessage[$i] = GUICtrlRead($g_ahumanMessage[$i])
			; Next
			$g_iCmbMaxActionsNumber = _GUICtrlComboBox_GetCurSel($g_iCmbMaxActionsNumber)
			; $g_iTxtChallengeMessage = GUICtrlRead($g_hChallengeMessage)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_Humanization

Func ApplyConfig_MOD_SmartMilk($TypeReadSave)
	Switch $TypeReadSave
		Case "Read"
			_GUICtrlComboBox_SetCurSel($g_hCmbMilkStrategyArmy, $g_iMilkStrategyArmy)
			GUICtrlSetState($g_hChkMilkForceDeployHeroes, $g_bChkMilkForceDeployHeroes ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkMilkForceAllTroops, $g_bChkMilkForceAllTroops ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkDebugSmartMilk, $g_bDebugSmartMilk ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlSetImage($g_ahPicMilk, $g_sLibIconPath, $g_hIcnMilk[$g_iMilkStrategyArmy])
		Case "Save"
			$g_iMilkStrategyArmy = _GUICtrlComboBox_GetCurSel($g_hCmbMilkStrategyArmy)
			$g_bChkMilkForceDeployHeroes = (GUICtrlRead($g_hChkMilkForceDeployHeroes) = $GUI_CHECKED)
			$g_bChkMilkForceAllTroops = (GUICtrlRead($g_hChkMilkForceAllTroops) = $GUI_CHECKED)
			$g_bDebugSmartMilk = (GUICtrlRead($g_hChkDebugSmartMilk) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_SmartMilk
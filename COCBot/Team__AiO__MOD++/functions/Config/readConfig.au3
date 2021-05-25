; #FUNCTION# ====================================================================================================================
; Name ..........: readConfig.au3
; Description ...: Reads config file and sets variables
; Syntax ........: readConfig()
; Parameters ....: NA
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
Func ReadConfig_MOD_CustomArmyBB()
	; <><><> CustomArmyBB <><><>
	;IniReadS($g_bChkBBCustomArmyEnable, $g_sProfileConfigPath, "BBCustomArmy", "ChkBBCustomArmyEnable", $g_bChkBBCustomArmyEnable, "Bool")
	
	For $i = 0 To UBound($g_hComboTroopBB) - 1
		IniReadS($g_iCmbCampsBB[$i], $g_sProfileConfigPath, "BBCustomArmy", "ComboTroopBB" & $i, $g_iCmbCampsBB[$i], "Int")
	Next

	; BB Upgrade Walls - Team AiO MOD++
	IniReadS($g_bChkBBUpgradeWalls, $g_sProfileConfigPath, "other", "ChkBBUpgradeWalls", False, "Bool")
	IniReadS($g_iCmbBBWallLevel, $g_sProfileConfigPath, "other", "CmbBBWallLevel", 10, "int")
	IniReadS($g_iBBWallNumber, $g_sProfileConfigPath, "other", "BBWallNumber", 0, "Int")
	IniReadS($g_bChkBBWallRing, $g_sProfileBuildingPath, "other", "ChkBBWallRing", False, "Bool")
	IniReadS($g_bChkBBUpgWallsGold, $g_sProfileBuildingPath, "other", "ChkBBUpgWallsGold", $g_bChkBBUpgWallsGold, "Bool")
	IniReadS($g_bChkBBUpgWallsElixir, $g_sProfileBuildingPath, "other", "ChkBBUpgWallsElixir", False, "Bool")
	
	For $i = 0 To 2
		IniReadS($g_sAttackScrScriptNameBB[$i], $g_sProfileConfigPath, "BuilderBase", "ScriptBB" & $i, "Barch four fingers")
	Next
	
	IniReadS($g_bChkUpgradeMachine, $g_sProfileConfigPath, "other", "ChkUpgradeMachine", False, "Bool") ; samm0d
	IniReadS($g_bChkBBStopAt3, $g_sProfileConfigPath, "BuilderBase", "BBStopAt3", False, "Bool")
	IniReadS($g_bChkBuilderAttack, $g_sProfileConfigPath, "BuilderBase", "BuilderAttack", False, "Bool")
	IniReadS($g_bChkBBCustomAttack, $g_sProfileConfigPath, "BuilderBase", "BBRandomAttack", False, "Bool")
	IniReadS($g_bChkBBTrophiesRange, $g_sProfileConfigPath, "BuilderBase", "BBTrophiesRange", False, "Bool")
	
	IniReadS($g_iTxtBBDropTrophiesMin, $g_sProfileConfigPath, "BuilderBase", "BBDropTrophiesMin", 1250, "Int")
	IniReadS($g_iTxtBBDropTrophiesMax, $g_sProfileConfigPath, "BuilderBase", "BBDropTrophiesMax", 2000, "Int")
	; -- AIO BB
	IniReadS($g_bChkBBGetFromCSV, $g_sProfileConfigPath, "BuilderBase", "ChkBBGetFromCSV", False, "Bool")
	IniReadS($g_bChkBBGetFromArmy, $g_sProfileConfigPath, "BuilderBase", "ChkBBGetFromArmy", False, "Bool")
	IniReadS($g_iCmbBBAttack, $g_sProfileConfigPath, "BuilderBase", "CmbBBAttack", $g_iCmbBBAttack, "Int")
	IniReadS($g_iBBMinAttack, $g_sProfileConfigPath, "BuilderBase", "IntBBMinAttack", $g_iBBMinAttack, "Int")
	IniReadS($g_iBBMaxAttack, $g_sProfileConfigPath, "BuilderBase", "IntBBMaxAttack", $g_iBBMaxAttack, "Int")
	IniReadS($g_bOnlyBuilderBase, $g_sProfileConfigPath, "general", "PlayBBOnly", False, "Bool")

EndFunc   ;==>ReadConfig_MOD_CustomArmyBB

Func ReadConfig_MOD_MiscTab()
	; <><><> MiscTab <><><>
	IniReadS($g_bUseSleep, $g_sProfileConfigPath, "MiscTab", "UseSleep", $g_bUseSleep, "Bool")
	IniReadS($g_iIntSleep, $g_sProfileConfigPath, "MiscTab", "IntSleep", $g_iIntSleep, "Int")
	IniReadS($g_bUseRandomSleep, $g_sProfileConfigPath, "MiscTab", "UseRandomSleep", $g_bUseRandomSleep, "Bool")
	IniReadS($g_bNoAttackSleep, $g_sProfileConfigPath, "MiscTab", "NoAttackSleep", $g_bNoAttackSleep, "Bool")
	IniReadS($g_bDisableColorLog, $g_sProfileConfigPath, "MiscTab", "DisableColorLog", $g_bDisableColorLog, "Bool")
	IniReadS($g_bAvoidLocation, $g_sProfileConfigPath, "MiscTab", "AvoidLocation", $g_bAvoidLocation, "Bool")
	
	For $i = $DB To $LB
		IniReadS($g_bDeployCastleFirst[$i], $g_sProfileConfigPath, "MiscTab", "DeployCastleFirst" & $i, $g_bDeployCastleFirst[$i], "Bool")
	Next
	
	; Read - Setlog limit - Team AIO Mod++
	IniReadS($g_bChkBotLogLineLimit, $g_sProfileConfigPath, "BotLogLineLimit", "Enable", True, "Bool")
	IniReadS($g_iTxtLogLineLimit, $g_sProfileConfigPath, "BotLogLineLimit", "LimitValue", "500","Int")

	; Skip first check
	IniReadS($g_bAvoidLocate, $g_sProfileConfigPath, "MiscTab", "AvoidLocate", $g_bAvoidLocate, "Bool")

	; Remove edge obstacles
	IniReadS($g_bEdgeObstacle, $g_sProfileConfigPath, "MiscTab", "EdgeObstacle", $g_bEdgeObstacle, "Bool")

	; DeployDelay
	IniReadS($g_iDeployDelay[0], $g_sProfileConfigPath, "MiscTab", "DeployDelay0", $g_iDeployDelay[0], "Int")
	IniReadS($g_iDeployDelay[1], $g_sProfileConfigPath, "MiscTab", "DeployDelay1", $g_iDeployDelay[1], "Int")
	IniReadS($g_iDeployDelay[2], $g_sProfileConfigPath, "MiscTab", "DeployDelay2", $g_iDeployDelay[2], "Int")

	; DeployWave
	IniReadS($g_iDeployWave[0], $g_sProfileConfigPath, "MiscTab", "DeployWave0", $g_iDeployWave[0], "Int")
	IniReadS($g_iDeployWave[1], $g_sProfileConfigPath, "MiscTab", "DeployWave1", $g_iDeployWave[1], "Int")
	IniReadS($g_iDeployWave[2], $g_sProfileConfigPath, "MiscTab", "DeployWave2", $g_iDeployWave[2], "Int")
	
	; Max sides
	IniReadS($g_bMaxSidesSF, $g_sProfileConfigPath, "MaxSidesSF", "Enable", $g_bMaxSidesSF, "Bool")
	IniReadS($g_iCmbMaxSidesSF, $g_sProfileConfigPath, "MaxSidesSF", "CmbMaxSidesSF", $g_iCmbMaxSidesSF, "Int")

	; Custom SmartFarm
	IniReadS($g_bUseSmartFarmAndRandomDeploy, $g_sProfileConfigPath, "UseSmartFarmAndRandomDeploy", "Enable", $g_bUseSmartFarmAndRandomDeploy, "Bool")

	; ChkEnableRandom
	IniReadS($g_bChkEnableRandom[0], $g_sProfileConfigPath, "MiscTab", "ChkEnableRandom0", $g_bChkEnableRandom[0], "Bool")
	IniReadS($g_bChkEnableRandom[1], $g_sProfileConfigPath, "MiscTab", "ChkEnableRandom1", $g_bChkEnableRandom[1], "Bool")
	;IniReadS($g_bChkEnableRandom[2], $g_sProfileConfigPath, "MiscTab", "ChkEnableRandom2", $g_bChkEnableRandom[2], "Bool")

	; Village / Misc - War Preparation (Demen)
	IniReadS($g_bStopForWar, $g_sProfileConfigPath, "war preparation", "Enable", False, "Bool")
	IniReadS($g_iStopTime, $g_sProfileConfigPath, "war preparation", "Stop Time", 0, "Int")
	IniReadS($g_iReturnTime, $g_sProfileConfigPath, "war preparation", "Return Time", 0, "Int")
	IniReadS($g_bTrainWarTroop, $g_sProfileConfigPath, "war preparation", "Train War Troop", False, "Bool")
	IniReadS($g_bUseQuickTrainWar, $g_sProfileConfigPath, "war preparation", "QuickTrain War Troop", False, "Bool")
	IniReadS($g_aChkArmyWar[0], $g_sProfileConfigPath, "war preparation", "QuickTrain War Army1", False, "Bool")
	IniReadS($g_aChkArmyWar[1], $g_sProfileConfigPath, "war preparation", "QuickTrain War Army2", False, "Bool")
	IniReadS($g_aChkArmyWar[2], $g_sProfileConfigPath, "war preparation", "QuickTrain War Army3", False, "Bool")

	For $i = 0 To $eTroopCount - 1
		IniReadS($g_aiWarCompTroops[$i], $g_sProfileConfigPath, "war preparation", $g_asTroopShortNames[$i], 0, "Int")
	Next
	For $j = 0 To $eSpellCount - 1
		IniReadS($g_aiWarCompSpells[$j], $g_sProfileConfigPath, "war preparation", $g_asSpellShortNames[$j], 0, "Int")
	Next

	IniReadS($g_bRequestCCForWar, $g_sProfileConfigPath, "war preparation", "RequestCC War", False, "Bool")
	$g_sTxtRequestCCForWar = IniRead($g_sProfileConfigPath, "war preparation", "RequestCC War Text", "War troop please")

	; Request form chat / on a loop / Type once - Team AIO Mod++
	IniReadS($g_bChkReqCCAlways, $g_sProfileConfigPath, "ReqCCOptions", "ReqCCAlways", $g_bChkReqCCAlways, "Bool")
	IniReadS($g_bChkReqCCFromChat, $g_sProfileConfigPath, "ReqCCOptions", "ReqCCFromChat", $g_bChkReqCCFromChat, "Bool")
	IniReadS($g_bRequestOneTimeEnable, $g_sProfileConfigPath, "ReqCCOptions", "RequestOneTime", $g_bRequestOneTimeEnable, "Bool")

	; Donation records.
	IniReadS($g_iDayLimitTroops, $g_sProfileConfigPath, "DonRecords", "DayLimitTroops", $g_iDayLimitTroops, "Int")
	IniReadS($g_iDayLimitSpells, $g_sProfileConfigPath, "DonRecords", "DayLimitSpells", $g_iDayLimitSpells, "Int")
	IniReadS($g_iDayLimitSieges, $g_sProfileConfigPath, "DonRecords", "DayLimitSieges", $g_iDayLimitSieges, "Int")
	IniReadS($g_iCmbRestartEvery, $g_sProfileConfigPath, "DonRecords", "CmbRestartEvery", $g_iCmbRestartEvery, "Int")
	IniReadS($g_sRestartTimer, $g_sProfileConfigPath, "DonRecords", "RestartTimer", $g_sRestartTimer)
	
	; Tooops;
	For $i = 0 To $eTroopCount - 1
		IniReadS($g_aiDonateStatsTroops[$i][0], $g_sProfileConfigPath, "DonRecords", "DonateStatsTroops" & $i, $g_aiDonateStatsTroops[$i][0], "Int")
	Next
	IniReadS($g_iTotalDonateStatsTroops, $g_sProfileConfigPath, "DonRecords", "TotalDonateStatsTroops", $g_iTotalDonateStatsTroops, "Int")
	
	; Spell;
	For $i = 0 To $eSpellCount - 1
		IniReadS($g_aiDonateStatsSpells[$i][0], $g_sProfileConfigPath, "DonRecords", "DonateStatsSpells" & $i, $g_aiDonateStatsSpells[$i][0], "Int")
	Next
	IniReadS($g_iTotalDonateStatsSpells, $g_sProfileConfigPath, "DonRecords", "TotalDonateStatsSpells", $g_iTotalDonateStatsSpells, "Int")

	; Siege;
	For $i = 0 To $eSiegeMachineCount - 1
		IniReadS($g_aiDonateStatsSieges[$i][0], $g_sProfileConfigPath, "DonRecords", "DonateStatsSieges" & $i, $g_aiDonateStatsSieges[$i][0], "Int")
	Next
	IniReadS($g_iTotalDonateStatsSiegeMachines, $g_sProfileConfigPath, "DonRecords", "TotalDonateStatsSieges", $g_iTotalDonateStatsSiegeMachines, "Int")
	; ------------;

	#Region - Return Home by Time - Team AIO Mod++
	IniReadS($g_bReturnTimerEnable, $g_sProfileConfigPath, "search", "ChkReturnTimerEnable", False, "Bool")
	IniReadS($g_iTxtReturnTimer, $g_sProfileConfigPath, "search", "ReturnTimer", 5, "int")
	#EndRegion - Return Home by Time - Team AIO Mod++

	#Region - Legend trophy protection - Team AIO Mod++
	IniReadS($g_bProtectInLL, $g_sProfileConfigPath, "attack", "ChkProtectInLL", $g_bProtectInLL, "Bool")
	IniReadS($g_bForceProtectLL, $g_sProfileConfigPath, "attack", "ChkForceProtectLL", $g_bForceProtectLL, "Bool")
	#EndRegion - Legend trophy protection - Team AIO Mod++

	#Region - No Upgrade In War - Team AIO Mod++
	IniReadS($g_bNoUpgradeInWar, $g_sProfileConfigPath, "attack", "ChkNoUpgradeInWar", $g_bNoUpgradeInWar, "Bool")
	#EndRegion - No Upgrade In War - Team AIO Mod++
	
	#Region - Custom Improve - Team AIO Mod++
	For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
		IniReadS($g_iChkBBUpgradesToIgnore[$i], $g_sProfileConfigPath, "other", "chkBBUpgradesToIgnore" & $i, 0, "int")
	Next
	#EndRegion - Custom Improve - Team AIO Mod++
	
	#Region - Buy Guard - Team AIO Mod++
	IniReadS($g_bChkBuyGuard, $g_sProfileConfigPath, "attack", "ChkBuyGuard", $g_bChkBuyGuard, "Bool")
	#EndRegion - Buy Guard - Team AIO Mod++

	#Region - Colorful attack log - Team AIO Mod++
	IniReadS($g_bChkColorfulAttackLog, $g_sProfileConfigPath, "attack", "ChkColorfulAttackLog", $g_bChkColorfulAttackLog, "Bool")
	#EndRegion - Colorful attack log - Team AIO Mod++
EndFunc   ;==>ReadConfig_MOD_MiscTab

Func ReadConfig_MOD_SuperXP()
	; <><><> SuperXP / GoblinXP <><><>
	IniReadS($g_bEnableSuperXP, $g_sProfileConfigPath, "SuperXP", "EnableSuperXP", $g_bEnableSuperXP, "Bool")
	IniReadS($g_bSkipZoomOutSX, $g_sProfileConfigPath, "SuperXP", "SkipZoomOutSX", $g_bSkipZoomOutSX, "Bool")
	IniReadS($g_bFastSuperXP, $g_sProfileConfigPath, "SuperXP", "FastSuperXP", $g_bFastSuperXP, "Bool")
	IniReadS($g_bSkipDragToEndSX, $g_sProfileConfigPath, "SuperXP", "SkipDragToEndSX", $g_bSkipDragToEndSX, "Bool")
	IniReadS($g_iActivateOptionSX, $g_sProfileConfigPath, "SuperXP", "ActivateOptionSX", $g_iActivateOptionSX, "int")
	IniReadS($g_iGoblinMapOptSX, $g_sProfileConfigPath, "SuperXP", "GoblinMapOptSX", $g_iGoblinMapOptSX, "int")

	IniReadS($g_iMaxXPtoGain, $g_sProfileConfigPath, "SuperXP", "MaxXPtoGain", $g_iMaxXPtoGain, "int")
	IniReadS($g_bBKingSX, $g_sProfileConfigPath, "SuperXP", "BKingSX", $eHeroNone)
	IniReadS($g_bAQueenSX, $g_sProfileConfigPath, "SuperXP", "AQueenSX", $eHeroNone)
	IniReadS($g_bGWardenSX, $g_sProfileConfigPath, "SuperXP", "GWardenSX", $eHeroNone)
EndFunc   ;==>ReadConfig_MOD_SuperXP

Func ReadConfig_MOD_MagicItems()
	; <><><> MagicItems <><><>
	IniReadS($g_iInputGoldItems, $g_sProfileConfigPath, "MagicItems", "InputGoldItems", $g_iInputGoldItems, "int")
	IniReadS($g_iInputElixirItems, $g_sProfileConfigPath, "MagicItems", "InputElixirItems", $g_iInputElixirItems, "int")
	IniReadS($g_iInputDarkElixirItems, $g_sProfileConfigPath, "MagicItems", "InputDarkElixirItems", $g_iInputDarkElixirItems, "int")

	IniReadS($g_iInputBuilderPotion, $g_sProfileConfigPath, "MagicItems", "InputBuilderPotion", $g_iInputBuilderPotion, "int")
	IniReadS($g_iInputLabPotion, $g_sProfileConfigPath, "MagicItems", "InputLabPotion", $g_iInputLabPotion, "int")

	IniReadS($g_iComboClockTowerPotion, $g_sProfileConfigPath, "MagicItems", "ComboClockTowerPotion", $g_iComboClockTowerPotion, "int")
	IniReadS($g_iComboHeroPotion, $g_sProfileConfigPath, "MagicItems", "ComboHeroPotion", $g_iComboHeroPotion, "int")
	IniReadS($g_iComboPowerPotion, $g_sProfileConfigPath, "MagicItems", "ComboPowerPotion", $g_iComboPowerPotion, "int")

	IniReadS($g_bChkCollectMagicItems, $g_sProfileConfigPath, "MagicItems", "CollectMagicItems", $g_bChkCollectMagicItems, "Bool")

	IniReadS($g_bChkBuilderPotion, $g_sProfileConfigPath, "MagicItems", "ChkBuilderPotion", $g_bChkBuilderPotion, "Bool")
	IniReadS($g_bChkClockTowerPotion, $g_sProfileConfigPath, "MagicItems", "ChkClockTowerPotion", $g_bChkClockTowerPotion, "Bool")
	IniReadS($g_bChkHeroPotion, $g_sProfileConfigPath, "MagicItems", "ChkHeroPotion", $g_bChkHeroPotion, "Bool")
	IniReadS($g_bChkLabPotion, $g_sProfileConfigPath, "MagicItems", "ChkLabPotion", $g_bChkLabPotion, "Bool")
	IniReadS($g_bChkPowerPotion, $g_sProfileConfigPath, "MagicItems", "ChkPowerPotion", $g_bChkPowerPotion, "Bool")
	IniReadS($g_bChkResourcePotion, $g_sProfileConfigPath, "MagicItems", "ChkResourcePotion", $g_bChkResourcePotion, "Bool")

EndFunc   ;==>ReadConfig_MOD_MagicItems

Func ReadConfig_MOD_ChatActions()
	; <><><> ChatActions <><><>
	IniReadS($g_iacmbPriority[10], $g_sProfileConfigPath, "ChatActions", "cmbPriority[" & 1 & "]", $g_iacmbPriority[0], "int")
	IniReadS($g_iacmbPriority[11], $g_sProfileConfigPath, "ChatActions", "cmbPriority[" & 2 & "]", $g_iacmbPriority[11], "int")
	
	; IniReadS($g_bChatClan, $g_sProfileConfigPath, "ChatActions", "EnableChatClan", $g_bChatClan, "Bool")
	IniReadS($g_sDelayTimeClan, $g_sProfileConfigPath, "ChatActions", "DelayTimeClan", $g_sDelayTimeClan, "Int")
	IniReadS($g_bClanUseResponses, $g_sProfileConfigPath, "ChatActions", "UseResponsesClan", $g_bClanUseResponses, "Bool")
	IniReadS($g_bClanUseGeneric, $g_sProfileConfigPath, "ChatActions", "UseGenericClan", $g_bClanUseGeneric, "Bool")
	IniReadS($g_bCleverbot, $g_sProfileConfigPath, "ChatActions", "Cleverbot", $g_bCleverbot, "Bool")
	IniReadS($g_bUseNotify, $g_sProfileConfigPath, "ChatActions", "ChatNotify", $g_bUseNotify, "Bool")
	IniReadS($g_bPbSendNew, $g_sProfileConfigPath, "ChatActions", "PbSendNewChats", $g_bPbSendNew, "Bool")

	; IniReadS($g_bEnableFriendlyChallenge, $g_sProfileConfigPath, "ChatActions", "EnableFriendlyChallenge", $g_bEnableFriendlyChallenge, "Bool")
	IniReadS($g_sDelayTimeFC, $g_sProfileConfigPath, "ChatActions", "DelayTimeFriendlyChallenge", $g_sDelayTimeFC, "Int")
	IniReadS($g_bOnlyOnRequest, $g_sProfileConfigPath, "ChatActions", "EnableOnlyOnRequest", $g_bOnlyOnRequest, "Bool")
	$g_bFriendlyChallengeBase = StringSplit(IniRead($g_sProfileConfigPath, "ChatActions", "FriendlyChallengeBaseForShare", "0|0|0|0|0|0"), "|", $STR_NOCOUNT)
	For $i = 0 To 5
		$g_bFriendlyChallengeBase[$i] = ($g_bFriendlyChallengeBase[$i] = "1")
	Next
	$g_abFriendlyChallengeHours = StringSplit(IniRead($g_sProfileConfigPath, "ChatActions", "FriendlyChallengePlannedRequestHours", "1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1"), "|", $STR_NOCOUNT)
	For $i = 0 To 23
		$g_abFriendlyChallengeHours[$i] = ($g_abFriendlyChallengeHours[$i] = "1")
	Next

	IniReadS($g_sIAVar, $g_sProfileConfigPath, "ChatActions", "String2D", $g_sIAVar, Default)
	Local $aPreIAVar = StringSplit($g_sIAVar, "#", $STR_NOCOUNT)
	
	Global $g_aIAVar[0][2]
	For $i = 0 To UBound($aPreIAVar) - 1
		Local $aSplitTmp = StringSplit($aPreIAVar[$i], ",", $STR_NOCOUNT)
		Local $aTemp[1][2] = [[$aSplitTmp[0], $aSplitTmp[1]]]
		_ArrayAdd($g_aIAVar, $aTemp)
	Next
	
EndFunc   ;==>ReadConfig_MOD_ChatActions

Func ReadConfig_MOD_600_6()
	; <><><> Daily Discounts + Builder Base Attack + Builder Base Drop Order <><><>
	For $i = 0 To $g_iDDCount - 1
		IniReadS($g_abChkDD_Deals[$i], $g_sProfileConfigPath, "DailyDiscounts", "ChkDD_Deals" & String($i), $g_abChkDD_Deals[$i], "Bool")
	Next
EndFunc   ;==>ReadConfig_MOD_600_6

Func ReadConfig_MOD_600_12()
	; <><><> GTFO <><><>
	IniReadS($g_bChkGTFOClanHop, $g_sProfileConfigPath, "GTFO", "chkGTFOClanHop", $g_bChkGTFOClanHop, "Bool")
	IniReadS($g_bChkGTFOReturnClan, $g_sProfileConfigPath, "GTFO", "chkGTFOReturnClan", $g_bChkGTFOReturnClan, "Bool")
	IniReadS($g_bChkUseGTFO, $g_sProfileConfigPath, "GTFO", "chkUseGTFO", $g_bChkUseGTFO, "Bool")
	IniReadS($g_sTxtClanID, $g_sProfileConfigPath, "GTFO", "txtClanID", $g_sTxtClanID)

	IniReadS($g_bChkUseKickOut, $g_sProfileConfigPath, "GTFO", "chkUseKickOut", $g_bChkUseKickOut, "Bool")
	IniReadS($g_iTxtMinSaveGTFO_Elixir, $g_sProfileConfigPath, "GTFO", "TxtMinSaveGTFO_Elixir", $g_iTxtMinSaveGTFO_Elixir, "Int")
	IniReadS($g_iTxtCyclesGTFO, $g_sProfileConfigPath, "GTFO", "txtCyclesGTFO", $g_iTxtCyclesGTFO, "Int")
	IniReadS($g_iTxtMinSaveGTFO_DE, $g_sProfileConfigPath, "GTFO", "TxtMinSaveGTFO_DE", $g_iTxtMinSaveGTFO_DE, "Int")
	IniReadS($g_bExitAfterCyclesGTFO, $g_sProfileConfigPath, "GTFO", "chkCyclesGTFO", $g_bExitAfterCyclesGTFO, "Bool")
	IniReadS($g_iTxtDonatedCap, $g_sProfileConfigPath, "GTFO", "txtDonatedCap", $g_iTxtDonatedCap, "Int")
	IniReadS($g_iTxtReceivedCap, $g_sProfileConfigPath, "GTFO", "txtReceivedCap", $g_iTxtReceivedCap, "Int")
	IniReadS($g_bChkKickOutSpammers, $g_sProfileConfigPath, "GTFO", "chkKickOutSpammers", $g_bChkKickOutSpammers, "Bool")
	IniReadS($g_iTxtKickLimit, $g_sProfileConfigPath, "GTFO", "txtKickLimit", $g_iTxtKickLimit, "Int")

EndFunc   ;==>ReadConfig_MOD_600_12

Func ReadConfig_MOD_600_28()
	; <><><> Max logout time <><><>
	IniReadS($g_bTrainLogoutMaxTime, $g_sProfileConfigPath, "other", "chkTrainLogoutMaxTime", $g_bTrainLogoutMaxTime, "Bool")
	IniReadS($g_iTrainLogoutMaxTime, $g_sProfileConfigPath, "other", "txtTrainLogoutMaxTime", $g_iTrainLogoutMaxTime, "int")

	; Check No League for Dead Base
	IniReadS($g_bChkNoLeague[$DB], $g_sProfileConfigPath, "search", "DBNoLeague", $g_bChkNoLeague[$DB], "Bool")

EndFunc   ;==>ReadConfig_MOD_600_28

Func ReadConfig_MOD_600_29()
	; <><><> CSV Deploy Speed <><><>
	IniReadS($icmbCSVSpeed[$LB], $g_sProfileConfigPath, "attack", "cmbCSVSpeedLB", $icmbCSVSpeed[$LB], "int")
	IniReadS($icmbCSVSpeed[$DB], $g_sProfileConfigPath, "attack", "cmbCSVSpeedDB", $icmbCSVSpeed[$DB], "int")
	For $i = $DB To $LB
		If $icmbCSVSpeed[$i] < 5 Then
			$g_CSVSpeedDivider[$i] = 0.5 + $icmbCSVSpeed[$i] * 0.25        ; $g_CSVSpeedDivider = 0.5, 0.75, 1, 1.25, 1.5
		Else
			$g_CSVSpeedDivider[$i] = 2 + $icmbCSVSpeed[$i] - 5            ; $g_CSVSpeedDivider = 2, 3, 4, 5
		EndIf
	Next
EndFunc   ;==>ReadConfig_MOD_600_29

Func ReadConfig_MOD_600_31()
	; <><><> Check Collectors Outside <><><>
	IniReadS($g_bDBMeetCollectorOutside, $g_sProfileConfigPath, "search", "DBMeetCollectorOutside", $g_bDBMeetCollectorOutside, "Bool")
	IniReadS($g_bDBCollectorNone, $g_sProfileConfigPath, "search", "DBCollectorNone", $g_bDBCollectorNone, "Bool")
	IniReadS($g_iDBMinCollectorOutsidePercent, $g_sProfileConfigPath, "search", "TxtDBMinCollectorOutsidePercent", $g_iDBMinCollectorOutsidePercent, "int")

	IniReadS($g_bDBCollectorNearRedline, $g_sProfileConfigPath, "search", "DBCollectorNearRedline", $g_bDBCollectorNearRedline, "Bool")
	IniReadS($g_iCmbRedlineTiles, $g_sProfileConfigPath, "search", "CmbRedlineTiles", $g_iCmbRedlineTiles, "int")

	IniReadS($g_bSkipCollectorCheck, $g_sProfileConfigPath, "search", "SkipCollectorCheck", $g_bSkipCollectorCheck, "Bool")
	IniReadS($g_iTxtSkipCollectorGold, $g_sProfileConfigPath, "search", "TxtSkipCollectorGold", $g_iTxtSkipCollectorGold, "int")
	IniReadS($g_iTxtSkipCollectorElixir, $g_sProfileConfigPath, "search", "TxtSkipCollectorElixir", $g_iTxtSkipCollectorElixir, "int")
	IniReadS($g_iTxtSkipCollectorDark, $g_sProfileConfigPath, "search", "TxtSkipCollectorDark", $g_iTxtSkipCollectorDark, "int")

	IniReadS($g_bSkipCollectorCheckTH, $g_sProfileConfigPath, "search", "SkipCollectorCheckTH", $g_bSkipCollectorCheckTH, "Bool")
	IniReadS($g_iCmbSkipCollectorCheckTH, $g_sProfileConfigPath, "search", "CmbSkipCollectorCheckTH", $g_iCmbSkipCollectorCheckTH, "int")
EndFunc   ;==>ReadConfig_MOD_600_31

Func ReadConfig_MOD_600_35_1()
	; <><><> Auto Dock, Hide Emulator & Bot <><><>
	IniReadS($g_bEnableAuto, $g_sProfileConfigPath, "general", "EnableAuto", $g_bEnableAuto, "Bool")
	IniReadS($g_bChkAutoDock, $g_sProfileConfigPath, "general", "AutoDock", $g_bChkAutoDock, "Bool")
	IniReadS($g_bChkAutoHideEmulator, $g_sProfileConfigPath, "general", "AutoHide", $g_bChkAutoHideEmulator, "Bool")
	IniReadS($g_bChkAutoMinimizeBot, $g_sProfileConfigPath, "general", "AutoMinimize", $g_bChkAutoMinimizeBot, "Bool")

	; <><><> Only Farm <><><>
	IniReadS($g_bChkOnlyFarm, $g_sProfileConfigPath, "general", "OnlyFarm", $g_bChkOnlyFarm, "Bool")

EndFunc   ;==>ReadConfig_MOD_600_35_1

Func ReadConfig_MOD_600_35_2()
	; <><><> Switch Profiles <><><>
	For $i = 0 To 3
		IniReadS($g_abChkSwitchMax[$i], $g_sProfileConfigPath, "SwitchProfile", "SwitchProfileMax" & $i, $g_abChkSwitchMax[$i], "Bool")
		IniReadS($g_abChkSwitchMin[$i], $g_sProfileConfigPath, "SwitchProfile", "SwitchProfileMin" & $i, $g_abChkSwitchMin[$i], "Bool")
		IniReadS($g_aiCmbSwitchMax[$i], $g_sProfileConfigPath, "SwitchProfile", "TargetProfileMax" & $i, $g_aiCmbSwitchMax[$i], "Int")
		IniReadS($g_aiCmbSwitchMin[$i], $g_sProfileConfigPath, "SwitchProfile", "TargetProfileMin" & $i, $g_aiCmbSwitchMin[$i], "Int")

		IniReadS($g_abChkBotTypeMax[$i], $g_sProfileConfigPath, "SwitchProfile", "ChangeBotTypeMax" & $i, $g_abChkBotTypeMax[$i], "Bool")
		IniReadS($g_abChkBotTypeMin[$i], $g_sProfileConfigPath, "SwitchProfile", "ChangeBotTypeMin" & $i, $g_abChkBotTypeMin[$i], "Bool")
		IniReadS($g_aiCmbBotTypeMax[$i], $g_sProfileConfigPath, "SwitchProfile", "TargetBotTypeMax" & $i, $g_aiCmbBotTypeMax[$i], "Int")
		IniReadS($g_aiCmbBotTypeMin[$i], $g_sProfileConfigPath, "SwitchProfile", "TargetBotTypeMin" & $i, $g_aiCmbBotTypeMin[$i], "Int")

		IniReadS($g_aiConditionMax[$i], $g_sProfileConfigPath, "SwitchProfile", "ConditionMax" & $i, $g_aiConditionMax[$i], "Int")
		IniReadS($g_aiConditionMin[$i], $g_sProfileConfigPath, "SwitchProfile", "ConditionMin" & $i, $g_aiConditionMin[$i], "Int")
	Next
EndFunc   ;==>ReadConfig_MOD_600_35_2

Func ReadConfig_MOD_Humanization()
	; <><><> Humanization <><><>
	IniReadS($g_bUseBotHumanization, $g_sProfileConfigPath, "Bot Humanization", "chkUseBotHumanization", $g_bUseBotHumanization, "Bool")
	IniReadS($g_bUseAltRClick, $g_sProfileConfigPath, "Bot Humanization", "chkUseAltRClick", $g_bUseAltRClick, "Bool")
	IniReadS($g_bLookAtRedNotifications, $g_sProfileConfigPath, "Bot Humanization", "chkLookAtRedNotifications", $g_bLookAtRedNotifications, "Bool")
	For $i = 0 To UBound($g_iacmbPriority) -1
		If $i > 9 Then ExitLoop
		IniReadS($g_iacmbPriority[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbPriority[" & $i & "]", $g_iacmbPriority[$i], "int")
	Next
	For $i = 0 To 1
		IniReadS($g_iacmbMaxSpeed[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbMaxSpeed[" & $i & "]", $g_iacmbMaxSpeed[$i], "int")
	Next
	For $i = 0 To 1
		IniReadS($g_iacmbPause[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbPause[" & $i & "]", $g_iacmbPause[$i], "int")
	Next
	; For $i = 0 To 1
		; IniReadS($g_iahumanMessage[$i], $g_sProfileConfigPath, "Bot Humanization", "humanMessage[" & $i & "]", $g_iahumanMessage[$i])
	; Next
	IniReadS($g_iCmbMaxActionsNumber, $g_sProfileConfigPath, "Bot Humanization", "cmbMaxActionsNumber", $g_iCmbMaxActionsNumber, "int")
	; IniReadS($g_iTxtChallengeMessage, $g_sProfileConfigPath, "Bot Humanization", "challengeMessage", $g_iTxtChallengeMessage)
EndFunc   ;==>ReadConfig_MOD_Humanization

Func ReadConfig_MOD_SmartMilk()
	IniReadS($g_iMilkStrategyArmy, $g_sProfileConfigPath, "SmartMilk", "MilkStrategyArmy", 0, "int")
	IniReadS($g_bChkMilkForceDeployHeroes, $g_sProfileConfigPath, "SmartMilk", "MilkForceDeployHeroes", False, "Bool")
	IniReadS($g_bChkMilkForceAllTroops, $g_sProfileConfigPath, "SmartMilk", "ChkMilkForceAllTroops", False, "Bool")
	IniReadS($g_bDebugSmartMilk, $g_sProfileConfigPath, "SmartMilk", "DebugSmartMilk", False, "Bool")
EndFunc   ;==>ReadConfig_MOD_SmartMilk

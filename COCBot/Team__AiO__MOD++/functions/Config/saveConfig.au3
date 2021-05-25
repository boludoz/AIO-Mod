; #FUNCTION# ====================================================================================================================
; Name ..........: saveConfig.au3
; Description ...: Saves all of the GUI values to the config.ini and building.ini files
; Syntax ........: saveConfig()
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
Func SaveConfig_MOD_CustomArmyBB()
	; <><><> CustomArmyBB <><><>
	ApplyConfig_MOD_CustomArmyBB(GetApplyConfigSaveAction())
	;_Ini_Add("BBCustomArmy", "ChkBBCustomArmyEnable", $g_bChkBBCustomArmyEnable)
	
	For $i = 0 To UBound($g_hComboTroopBB) - 1
		_Ini_Add("BBCustomArmy", "ComboTroopBB" & $i, $g_iCmbCampsBB[$i])
	Next

	; BB Upgrade Walls - Team AiO MOD++
	_Ini_Add("other", "ChkBBUpgradeWalls", $g_bChkBBUpgradeWalls ? 1 : 0)
	_Ini_Add("other", "CmbBBWallLevel", $g_iCmbBBWallLevel)
	_Ini_Add("other", "BBWallNumber", $g_iBBWallNumber)
	_Ini_Add("other", "ChkBBWallRing", $g_bChkBBWallRing ? 1 : 0)
	_Ini_Add("other", "ChkBBUpgWallsGold", $g_bChkBBUpgWallsGold ? 1 : 0)
	_Ini_Add("other", "ChkBBUpgWallsElixir", $g_bChkBBUpgWallsElixir ? 1 : 0)

	For $i = 0 To 2
		_Ini_Add("BuilderBase", "ScriptBB" & $i, $g_sAttackScrScriptNameBB[$i])
	Next
	
	_Ini_Add("other", "ChkUpgradeMachine", $g_bChkUpgradeMachine ? 1 : 0)
	_Ini_Add("other", "ChkPlacingNewBuildings", $g_iChkPlacingNewBuildings)
	_Ini_Add("BuilderBase", "BuilderAttack", $g_bChkBuilderAttack ? 1 : 0)
	_Ini_Add("BuilderBase", "BBStopAt3", $g_bChkBBStopAt3 ? 1 : 0)
	_Ini_Add("BuilderBase", "BBTrophiesRange", $g_bChkBBTrophiesRange ? 1 : 0)
	_Ini_Add("BuilderBase", "BBRandomAttack", $g_bChkBBCustomAttack ? 1 : 0)
	
	_Ini_Add("BuilderBase", "BBDropTrophiesMin", $g_iTxtBBDropTrophiesMin)
	_Ini_Add("BuilderBase", "BBDropTrophiesMax", $g_iTxtBBDropTrophiesMax)
	_Ini_Add("BuilderBase", "BBArmy1", $g_iCmbBBArmy1)
	_Ini_Add("BuilderBase", "BBArmy2", $g_iCmbBBArmy2)
	_Ini_Add("BuilderBase", "BBArmy3", $g_iCmbBBArmy3)
	_Ini_Add("BuilderBase", "BBArmy4", $g_iCmbBBArmy4)
	_Ini_Add("BuilderBase", "BBArmy5", $g_iCmbBBArmy5)
	_Ini_Add("BuilderBase", "BBArmy6", $g_iCmbBBArmy6)
	; -- AIO BB
	_Ini_Add("BuilderBase", "ChkBBGetFromCSV", $g_bChkBBGetFromCSV)
	_Ini_Add("BuilderBase", "ChkBBGetFromArmy", $g_bChkBBGetFromArmy)
	_Ini_Add("BuilderBase", "CmbBBAttack", $g_iCmbBBAttack)
	_Ini_Add("BuilderBase", "IntBBMinAttack", $g_iBBMinAttack)
	_Ini_Add("BuilderBase", "IntBBMaxAttack", $g_iBBMaxAttack)
	_Ini_Add("general", "PlayBBOnly", $g_bOnlyBuilderBase ? 1 : 0)
EndFunc   ;==>SaveConfig_MOD_CustomArmyBB

Func SaveConfig_MOD_MiscTab()
	; <><><> MiscTab <><><>
	ApplyConfig_MOD_MiscTab(GetApplyConfigSaveAction())
	_Ini_Add("MiscTab", "UseSleep", $g_bUseSleep)
	_Ini_Add("MiscTab", "IntSleep", $g_iIntSleep)
	_Ini_Add("MiscTab", "UseRandomSleep", $g_bUseRandomSleep)
	_Ini_Add("MiscTab", "NoAttackSleep", $g_bNoAttackSleep)
	_Ini_Add("MiscTab", "DisableColorLog", $g_bDisableColorLog)
	_Ini_Add("MiscTab", "AvoidLocation", $g_bAvoidLocation)
	
	For $i = $DB To $LB
		_Ini_Add("MiscTab", "DeployCastleFirst" & $i, $g_bDeployCastleFirst[$i])
	Next
	
	; Save - Setlog limit - Team AIO Mod++
	_Ini_Add("BotLogLineLimit", "Enable", (GUICtrlRead($g_hChkBotLogLineLimit) = ($GUI_CHECKED) ? (True) : (False) ))
	_Ini_Add("BotLogLineLimit", "LimitValue", GUICtrlRead($g_hTxtLogLineLimit))

	; Skip first check
	_Ini_Add("AvoidLocate", "Enable", $g_bAvoidLocate ? 1 : 0)

	; Remove edge obstacles
	_Ini_Add("MiscTab", "EdgeObstacle", $g_bEdgeObstacle ? 1 : 0)

	; DeployDelay
	_Ini_Add("MiscTab", "DeployDelay0", $g_iDeployDelay[0])
	_Ini_Add("MiscTab", "DeployDelay1", $g_iDeployDelay[1])
	_Ini_Add("MiscTab", "DeployDelay2", $g_iDeployDelay[2])
	
	; DeployWave
	_Ini_Add("MiscTab", "DeployWave0", $g_iDeployWave[0])
	_Ini_Add("MiscTab", "DeployWave1", $g_iDeployWave[1])
	_Ini_Add("MiscTab", "DeployWave2", $g_iDeployWave[2])

	; ChkEnableRandom
	_Ini_Add("MiscTab", "ChkEnableRandom0", $g_bChkEnableRandom[0])
	_Ini_Add("MiscTab", "ChkEnableRandom1", $g_bChkEnableRandom[1])
	_Ini_Add("MiscTab", "ChkEnableRandom2", $g_bChkEnableRandom[2])

	; Max sides
	_Ini_Add("MaxSidesSF", "Enable", $g_bMaxSidesSF ? 1 : 0)
	_Ini_Add("MaxSidesSF", "CmbMaxSidesSF", $g_iCmbMaxSidesSF)

	; Custom SmartFarm
	_Ini_Add("UseSmartFarmAndRandomDeploy", "Enable", $g_bUseSmartFarmAndRandomDeploy ? 1 : 0)

	; Village / Misc - War Preparation (Demen)
	_Ini_Add("war preparation", "Enable", $g_bStopForWar ? 1 : 0)
	_Ini_Add("war preparation", "Stop Time", $g_iStopTime)
	_Ini_Add("war preparation", "Return Time", $g_iReturnTime)
	_Ini_Add("war preparation", "Train War Troop", $g_bTrainWarTroop ? 1 : 0)
	_Ini_Add("war preparation", "QuickTrain War Troop", $g_bUseQuickTrainWar ? 1 : 0)
	_Ini_Add("war preparation", "QuickTrain War Army1", $g_aChkArmyWar[0] ? 1 : 0)
	_Ini_Add("war preparation", "QuickTrain War Army2", $g_aChkArmyWar[1] ? 1 : 0)
	_Ini_Add("war preparation", "QuickTrain War Army3", $g_aChkArmyWar[2] ? 1 : 0)

	For $i = 0 To $eTroopCount - 1
		_Ini_Add("war preparation", $g_asTroopShortNames[$i], $g_aiWarCompTroops[$i])
	Next
	For $j = 0 To $eSpellCount - 1
		_Ini_Add("war preparation", $g_asSpellShortNames[$j], $g_aiWarCompSpells[$j])
	Next

	_Ini_Add("war preparation", "RequestCC War", $g_bRequestCCForWar ? 1 : 0)
	_Ini_Add("war preparation", "RequestCC War Text", $g_sTxtRequestCCForWar)

	; Request form chat / on a loop / Type once - Team AIO Mod++
	_Ini_Add("ReqCCOptions", "ReqCCAlways", $g_bChkReqCCAlways)
	_Ini_Add("ReqCCOptions", "ReqCCFromChat", $g_bChkReqCCFromChat)
	_Ini_Add("ReqCCOptions", "RequestOneTime", $g_bRequestOneTimeEnable)

	; Donation records.
	_Ini_Add("DonRecords", "DayLimitTroops", $g_iDayLimitTroops)
	_Ini_Add("DonRecords", "DayLimitSpells", $g_iDayLimitSpells)
	_Ini_Add("DonRecords", "DayLimitSieges", $g_iDayLimitSieges)
	_Ini_Add("DonRecords", "CmbRestartEvery", $g_iCmbRestartEvery)
	_Ini_Add("DonRecords", "RestartTimer", $g_sRestartTimer)

	; Tooops;
	For $i = 0 To $eTroopCount - 1
		_Ini_Add("DonRecords", "DonateStatsTroops" & $i, $g_aiDonateStatsTroops[$i][0])
	Next
	_Ini_Add("DonRecords", "TotalDonateStatsTroops", $g_iTotalDonateStatsTroops)
	
	; Spell;
	For $i = 0 To $eSpellCount - 1
		_Ini_Add("DonRecords", "DonateStatsSpells" & $i, $g_aiDonateStatsSpells[$i][0])
	Next
	_Ini_Add("DonRecords", "TotalDonateStatsSpells", $g_iTotalDonateStatsSpells)

	; Siege;
	For $i = 0 To $eSiegeMachineCount - 1
		_Ini_Add("DonRecords", "DonateStatsSieges" & $i, $g_aiDonateStatsSieges[$i][0])
	Next
	_Ini_Add("DonRecords", "TotalDonateStatsSieges", $g_iTotalDonateStatsSiegeMachines)
	; ------------;

	#Region - Return Home by Time - Team AIO Mod++
	_Ini_Add("search", "ChkReturnTimerEnable", $g_bReturnTimerEnable ? 1 : 0)
	_Ini_Add("search", "ReturnTimer", $g_iTxtReturnTimer)
	#EndRegion - Return Home by Time - Team AIO Mod++

	#Region - Legend trophy protection - Team AIO Mod++
	_Ini_Add("attack", "ChkProtectInLL", $g_bProtectInLL ? 1 : 0)
	_Ini_Add("attack", "ChkForceProtectLL", $g_bForceProtectLL ? 1 : 0)
	#EndRegion - Legend trophy protection - Team AIO Mod++

	#Region - No Upgrade In War - Team AIO Mod++
	_Ini_Add("attack", "ChkNoUpgradeInWar", $g_bNoUpgradeInWar ? 1 : 0)
	#EndRegion - No Upgrade In War - Team AIO Mod++
	
	#Region - Custom Improve - Team AIO Mod++
	For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
		_Ini_Add("other", "chkBBUpgradesToIgnore" & $i, $g_iChkBBUpgradesToIgnore[$i])
	Next
	#EndRegion - Custom Improve - Team AIO Mod++

	#Region - Buy Guard - Team AIO Mod++
	_Ini_Add("attack", "ChkBuyGuard", $g_bChkBuyGuard ? 1 : 0)
	#EndRegion - Buy Guard - Team AIO Mod++

	#Region - Colorful attack log - Team AIO Mod++
	_Ini_Add("attack", "ChkColorfulAttackLog", $g_bChkColorfulAttackLog ? 1 : 0)
	#EndRegion - Colorful attack log - Team AIO Mod++

EndFunc   ;==>SaveConfig_MOD_MiscTab

Func SaveConfig_MOD_SuperXP()
	; <><><> SuperXP / GoblinXP <><><>
	ApplyConfig_MOD_SuperXP(GetApplyConfigSaveAction())
	_Ini_Add("SuperXP", "EnableSuperXP", $g_bEnableSuperXP ? 1 : 0)
	_Ini_Add("SuperXP", "SkipZoomOutSX", $g_bSkipZoomOutSX ? 1 : 0)
	_Ini_Add("SuperXP", "FastSuperXP", $g_bFastSuperXP ? 1 : 0)
	_Ini_Add("SuperXP", "SkipDragToEndSX", $g_bSkipDragToEndSX ? 1 : 0)
	_Ini_Add("SuperXP", "ActivateOptionSX", $g_iActivateOptionSX)
	_Ini_Add("SuperXP", "GoblinMapOptSX", $g_iGoblinMapOptSX)

	_Ini_Add("SuperXP", "MaxXPtoGain", $g_iMaxXPtoGain)
	_Ini_Add("SuperXP", "BKingSX", $g_bBKingSX)
	_Ini_Add("SuperXP", "AQueenSX", $g_bAQueenSX)
	_Ini_Add("SuperXP", "GWardenSX", $g_bGWardenSX)
EndFunc   ;==>SaveConfig_MOD_SuperXP

Func SaveConfig_MOD_MagicItems()
	; <><><> MagicItems <><><>
	ApplyConfig_MOD_MagicItems(GetApplyConfigSaveAction())
	_Ini_Add("MagicItems", "InputGoldItems", $g_iInputGoldItems)
	_Ini_Add("MagicItems", "InputElixirItems", $g_iInputElixirItems)
	_Ini_Add("MagicItems", "InputDarkElixirItems", $g_iInputDarkElixirItems)

	_Ini_Add("MagicItems", "InputBuilderPotion", $g_iInputBuilderPotion)
	_Ini_Add("MagicItems", "InputLabPotion", $g_iInputLabPotion)

	_Ini_Add("MagicItems", "ComboClockTowerPotion", $g_iComboClockTowerPotion)
	_Ini_Add("MagicItems", "ComboHeroPotion", $g_iComboHeroPotion)
	_Ini_Add("MagicItems", "ComboPowerPotion", $g_iComboPowerPotion)

	_Ini_Add("MagicItems", "CollectMagicItems", $g_bChkCollectMagicItems ? 1 : 0)

	_Ini_Add("MagicItems", "ChkBuilderPotion", $g_bChkBuilderPotion ? 1 : 0)
	_Ini_Add("MagicItems", "ChkClockTowerPotion", $g_bChkClockTowerPotion ? 1 : 0)
	_Ini_Add("MagicItems", "ChkHeroPotion", $g_bChkHeroPotion ? 1 : 0)
	_Ini_Add("MagicItems", "ChkLabPotion", $g_bChkLabPotion ? 1 : 0)
	_Ini_Add("MagicItems", "ChkPowerPotion", $g_bChkPowerPotion ? 1 : 0)
	_Ini_Add("MagicItems", "ChkResourcePotion", $g_bChkResourcePotion ? 1 : 0)
EndFunc   ;==>SaveConfig_MOD_MagicItems

Func SaveConfig_MOD_ChatActions()
	; <><><> ChatActions <><><>
	ApplyConfig_MOD_ChatActions(GetApplyConfigSaveAction())
	_Ini_Add("ChatActions", "cmbPriority[" & 1 & "]", _GUICtrlComboBox_GetCurSel($g_acmbPriority[10]))
	_Ini_Add("ChatActions", "cmbPriority[" & 2 & "]", _GUICtrlComboBox_GetCurSel($g_acmbPriority[11]))

	; _Ini_Add("ChatActions", "EnableChatClan", $g_bChatClan ? 1 : 0)
	_Ini_Add("ChatActions", "DelayTimeClan", $g_sDelayTimeClan)
	_Ini_Add("ChatActions", "UseResponsesClan", $g_bClanUseResponses ? 1 : 0)
	_Ini_Add("ChatActions", "UseGenericClan", $g_bClanUseGeneric ? 1 : 0)
	_Ini_Add("ChatActions", "Cleverbot", $g_bCleverbot ? 1 : 0)
	_Ini_Add("ChatActions", "ChatNotify", $g_bUseNotify ? 1 : 0)
	_Ini_Add("ChatActions", "PbSendNewChats", $g_bPbSendNew ? 1 : 0)

	_Ini_Add("ChatActions", "EnableFriendlyChallenge", $g_bEnableFriendlyChallenge ? 1 : 0)
	_Ini_Add("ChatActions", "DelayTimeFriendlyChallenge", $g_sDelayTimeFC)
	_Ini_Add("ChatActions", "EnableOnlyOnRequest", $g_bOnlyOnRequest ? 1 : 0)
	Local $string = ""
	For $i = 0 To 5
		$string &= ($g_bFriendlyChallengeBase[$i] ? "1" : "0") & "|"
	Next
	_Ini_Add("ChatActions", "FriendlyChallengeBaseForShare", $string)
	$string = ""
	For $i = 0 To 23
		$string &= ($g_abFriendlyChallengeHours[$i] ? "1" : "0") & "|"
	Next
	_Ini_Add("ChatActions", "FriendlyChallengePlannedRequestHours", $string)

	Local $sPreIAVar = _ArrayToString($g_aIAVar, ",", -1, -1, "#")
	_Ini_Add("ChatActions", "String2D", $sPreIAVar)

	_Ini_Add("ChatActions", "ResponseMsgClan", $g_sClanResponses)
	_Ini_Add("ChatActions", "GenericMsgClan", $g_sClanGeneric)
	_Ini_Add("ChatActions", "FriendlyChallengeText", $g_sChallengeText)
	_Ini_Add("ChatActions", "FriendlyChallengeKeyword", $g_sKeywordFcRequest)

EndFunc   ;==>SaveConfig_MOD_ChatActions

Func SaveConfig_MOD_600_6()
	; <><><> Daily Discounts + Builder Base Attack + Builder Base Drop Order <><><>
	ApplyConfig_MOD_600_6(GetApplyConfigSaveAction())
	For $i = 0 To $g_iDDCount - 1
		_Ini_Add("DailyDiscounts", "ChkDD_Deals" & String($i), $g_abChkDD_Deals[$i] ? 1 : 0)
	Next
EndFunc   ;==>SaveConfig_MOD_600_6

Func SaveConfig_MOD_600_12()
	; <><><> GTFO <><><>
	ApplyConfig_MOD_600_12(GetApplyConfigSaveAction())
	_Ini_Add("GTFO", "chkGTFOClanHop", $g_bChkGTFOClanHop)
	_Ini_Add("GTFO", "chkGTFOReturnClan", $g_bChkGTFOReturnClan)
	_Ini_Add("GTFO", "chkUseGTFO", $g_bChkUseGTFO)

	_Ini_Add("GTFO", "txtClanID", $g_sTxtClanID)
	_Ini_Add("GTFO", "txtMinSaveGTFO_Elixir", $g_iTxtMinSaveGTFO_Elixir)
	_Ini_Add("GTFO", "chkCyclesGTFO", $g_bExitAfterCyclesGTFO)
	_Ini_Add("GTFO", "txtCyclesGTFO", $g_iTxtCyclesGTFO)
	_Ini_Add("GTFO", "TxtMinSaveGTFO_DE", $g_iTxtMinSaveGTFO_DE)
	_Ini_Add("GTFO", "chkUseKickOut", $g_bChkUseKickOut)
	_Ini_Add("GTFO", "txtDonatedCap", $g_iTxtDonatedCap)
	_Ini_Add("GTFO", "txtReceivedCap", $g_iTxtReceivedCap)
	_Ini_Add("GTFO", "chkKickOutSpammers", $g_bChkKickOutSpammers)
	_Ini_Add("GTFO", "txtKickLimit", $g_iTxtKickLimit)

EndFunc   ;==>SaveConfig_MOD_600_12

Func SaveConfig_MOD_600_28()
	; <><><> Max logout time <><><>
	ApplyConfig_MOD_600_28(GetApplyConfigSaveAction())
	_Ini_Add("other", "chkTrainLogoutMaxTime", $g_bTrainLogoutMaxTime ? 1 : 0)
	_Ini_Add("other", "txtTrainLogoutMaxTime", $g_iTrainLogoutMaxTime)

	; Check No League for Dead Base
	_Ini_Add("search", "DBNoLeague", $g_bChkNoLeague[$DB] ? 1 : 0)

EndFunc   ;==>SaveConfig_MOD_600_28

Func SaveConfig_MOD_600_29()
	; <><><> CSV Deploy Speed <><><>
	ApplyConfig_MOD_600_29(GetApplyConfigSaveAction())
	_Ini_Add("attack", "cmbCSVSpeedLB", $icmbCSVSpeed[$LB])
	_Ini_Add("attack", "cmbCSVSpeedDB", $icmbCSVSpeed[$DB])
EndFunc   ;==>SaveConfig_MOD_600_29

Func SaveConfig_MOD_600_31()
	; <><><> Check Collectors Outside <><><>
	ApplyConfig_MOD_600_31(GetApplyConfigSaveAction())
	_Ini_Add("search", "DBMeetCollectorOutside", $g_bDBMeetCollectorOutside ? 1 : 0)
	_Ini_Add("search", "DBCollectorNone", $g_bDBCollectorNone ? 1 : 0)
	_Ini_Add("search", "TxtDBMinCollectorOutsidePercent", $g_iDBMinCollectorOutsidePercent)

	_Ini_Add("search", "DBCollectorNearRedline", $g_bDBCollectorNearRedline ? 1 : 0)
	_Ini_Add("search", "CmbRedlineTiles", $g_iCmbRedlineTiles)

	_Ini_Add("search", "SkipCollectorCheck", $g_bSkipCollectorCheck ? 1 : 0)
	_Ini_Add("search", "TxtSkipCollectorGold", $g_iTxtSkipCollectorGold)
	_Ini_Add("search", "TxtSkipCollectorElixir", $g_iTxtSkipCollectorElixir)
	_Ini_Add("search", "TxtSkipCollectorDark", $g_iTxtSkipCollectorDark)

	_Ini_Add("search", "SkipCollectorCheckTH", $g_bSkipCollectorCheckTH ? 1 : 0)
	_Ini_Add("search", "CmbSkipCollectorCheckTH", $g_iCmbSkipCollectorCheckTH)
EndFunc   ;==>SaveConfig_MOD_600_31

Func SaveConfig_MOD_600_35_1()
	; <><><> Auto Dock, Hide Emulator & Bot <><><>
	ApplyConfig_MOD_600_35_1(GetApplyConfigSaveAction())
	_Ini_Add("general", "EnableAuto", $g_bEnableAuto ? 1 : 0)
	_Ini_Add("general", "AutoDock", $g_bChkAutoDock ? 1 : 0)
	_Ini_Add("general", "AutoHide", $g_bChkAutoHideEmulator ? 1 : 0)
	_Ini_Add("general", "AutoMinimize", $g_bChkAutoMinimizeBot ? 1 : 0)

	; <><><> Only Farm <><><>
	_Ini_Add("general", "OnlyFarm", $g_bChkOnlyFarm ? 1 : 0)

EndFunc   ;==>SaveConfig_MOD_600_35_1

Func SaveConfig_MOD_600_35_2()
	; <><><> Switch Profiles <><><>
	ApplyConfig_MOD_600_35_2(GetApplyConfigSaveAction())
	For $i = 0 To 3
		_Ini_Add("SwitchProfile", "SwitchProfileMax" & $i, $g_abChkSwitchMax[$i] ? 1 : 0)
		_Ini_Add("SwitchProfile", "SwitchProfileMin" & $i, $g_abChkSwitchMin[$i] ? 1 : 0)
		_Ini_Add("SwitchProfile", "TargetProfileMax" & $i, $g_aiCmbSwitchMax[$i])
		_Ini_Add("SwitchProfile", "TargetProfileMin" & $i, $g_aiCmbSwitchMin[$i])

		_Ini_Add("SwitchProfile", "ChangeBotTypeMax" & $i, $g_abChkBotTypeMax[$i] ? 1 : 0)
		_Ini_Add("SwitchProfile", "ChangeBotTypeMin" & $i, $g_abChkBotTypeMin[$i] ? 1 : 0)
		_Ini_Add("SwitchProfile", "TargetBotTypeMax" & $i, $g_aiCmbBotTypeMax[$i])
		_Ini_Add("SwitchProfile", "TargetBotTypeMin" & $i, $g_aiCmbBotTypeMin[$i])

		_Ini_Add("SwitchProfile", "ConditionMax" & $i, $g_aiConditionMax[$i])
		_Ini_Add("SwitchProfile", "ConditionMin" & $i, $g_aiConditionMin[$i])
	Next
EndFunc   ;==>SaveConfig_MOD_600_35_2

Func SaveConfig_MOD_Humanization()
	; <><><> Humanization <><><>
	_Ini_Add("Bot Humanization", "chkUseBotHumanization", $g_bUseBotHumanization ? True : False)
	_Ini_Add("Bot Humanization", "chkUseAltRClick", $g_bUseAltRClick ? True : False)
	_Ini_Add("Bot Humanization", "chkLookAtRedNotifications", $g_bLookAtRedNotifications ? True : False)
	For $i = 0 To 12
		If $i > 9 Then ExitLoop
		_Ini_Add("Bot Humanization", "cmbPriority[" & $i & "]", _GUICtrlComboBox_GetCurSel($g_acmbPriority[$i]))
	Next
	For $i = 0 To 1
		_Ini_Add("Bot Humanization", "cmbMaxSpeed[" & $i & "]", _GUICtrlComboBox_GetCurSel($g_acmbMaxSpeed[$i]))
	Next
	For $i = 0 To 1
		_Ini_Add("Bot Humanization", "cmbPause[" & $i & "]", _GUICtrlComboBox_GetCurSel($g_acmbPause[$i]))
	Next
	; For $i = 0 To 1
		; _Ini_Add("Bot Humanization", "humanMessage[" & $i & "]", GUICtrlRead($g_ahumanMessage[$i]))
	; Next
	_Ini_Add("Bot Humanization", "cmbMaxActionsNumber", _GUICtrlComboBox_GetCurSel($g_hCmbMaxActionsNumber))
	_Ini_Add("Bot Humanization", "challengeMessage", GUICtrlRead($g_hChallengeMessage))
EndFunc   ;==>SaveConfig_MOD_Humanization

Func SaveConfig_MOD_SmartMilk()
	_Ini_Add("SmartMilk", "MilkStrategyArmy", $g_iMilkStrategyArmy)
	_Ini_Add("SmartMilk", "MilkForceDeployHeroes", $g_bChkMilkForceDeployHeroes)
	_Ini_Add("SmartMilk", "ChkMilkForceAllTroops", $g_bChkMilkForceAllTroops)
	_Ini_Add("SmartMilk", "DebugSmartMilk", $g_bDebugSmartMilk)
EndFunc   ;==>SaveConfig_MOD_SmartMilk
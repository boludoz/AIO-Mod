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
	IniReadS($g_bChkBBCustomArmyEnable, $g_sProfileConfigPath, "BBCustomArmy", "ChkBBCustomArmyEnable", $g_bChkBBCustomArmyEnable, "Bool")
	
	For $i = 0 To UBound($g_hComboTroopBB) - 1
		IniReadS($g_iCmbCampsBB[$i], $g_sProfileConfigPath, "BBCustomArmy", "ComboTroopBB" & $i, $g_iCmbCampsBB[$i], "Int")
	Next

EndFunc   ;==>SaveConfig_MOD_CustomArmyBB

Func ReadConfig_MOD_MiscTab()
	; <><><> MiscTab <><><>
	IniReadS($g_bUseSleep, $g_sProfileConfigPath, "MiscTab", "UseSleep", $g_bUseSleep, "Bool")
	IniReadS($g_iIntSleep, $g_sProfileConfigPath, "MiscTab", "IntSleep", $g_iIntSleep, "Int")
	IniReadS($g_bUseRandomSleep, $g_sProfileConfigPath, "MiscTab", "UseRandomSleep", $g_bUseRandomSleep, "Bool")
	IniReadS($g_bNoAttackSleep, $g_sProfileConfigPath, "MiscTab", "NoAttackSleep", $g_bNoAttackSleep, "Bool")
	IniReadS($g_bDeployCastleFirst, $g_sProfileConfigPath, "MiscTab", "DeployCastleFirst", $g_bDeployCastleFirst, "Bool")
	IniReadS($g_bDisableColorLog, $g_sProfileConfigPath, "MiscTab", "DisableColorLog", $g_bDisableColorLog, "Bool")
	IniReadS($g_bAvoidLocation, $g_sProfileConfigPath, "MiscTab", "AvoidLocation", $g_bAvoidLocation, "Bool")
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

	IniReadS($g_bChkCollectMagicItems , $g_sProfileConfigPath, "MagicItems", "CollectMagicItems", $g_bChkCollectMagicItems, "Bool")
	IniReadS($g_bChkCollectFree , $g_sProfileConfigPath, "MagicItems", "ChkCollectFree", $g_bChkCollectFree, "Bool")

	IniReadS($g_bChkBuilderPotion , $g_sProfileConfigPath, "MagicItems", "ChkBuilderPotion", $g_bChkBuilderPotion, "Bool")
	IniReadS($g_bChkClockTowerPotion , $g_sProfileConfigPath, "MagicItems", "ChkClockTowerPotion", $g_bChkClockTowerPotion, "Bool")
	IniReadS($g_bChkHeroPotion , $g_sProfileConfigPath, "MagicItems", "ChkHeroPotion", $g_bChkHeroPotion, "Bool")
	IniReadS($g_bChkLabPotion , $g_sProfileConfigPath, "MagicItems", "ChkLabPotion", $g_bChkLabPotion, "Bool")
	IniReadS($g_bChkPowerPotion , $g_sProfileConfigPath, "MagicItems", "ChkPowerPotion", $g_bChkPowerPotion, "Bool")
	IniReadS($g_bChkResourcePotion , $g_sProfileConfigPath, "MagicItems", "ChkResourcePotion", $g_bChkResourcePotion, "Bool")

EndFunc   ;==>ReadConfig_MOD_MagicItems

Func ReadConfig_MOD_ChatActions()
	; <><><> ChatActions <><><>
	IniReadS($g_bChatClan, $g_sProfileConfigPath, "ChatActions", "EnableChatClan", $g_bChatClan, "Bool")
	IniReadS($g_sDelayTimeClan, $g_sProfileConfigPath, "ChatActions", "DelayTimeClan", $g_sDelayTimeClan, "Int")
	IniReadS($g_bClanUseResponses, $g_sProfileConfigPath, "ChatActions", "UseResponsesClan", $g_bClanUseResponses, "Bool")
	IniReadS($g_bClanUseGeneric, $g_sProfileConfigPath, "ChatActions", "UseGenericClan", $g_bClanUseGeneric, "Bool")
	IniReadS($g_bCleverbot, $g_sProfileConfigPath, "ChatActions", "Cleverbot", $g_bCleverbot, "Bool")
	IniReadS($g_bUseNotify, $g_sProfileConfigPath, "ChatActions", "ChatNotify", $g_bUseNotify, "Bool")
	IniReadS($g_bPbSendNew, $g_sProfileConfigPath, "ChatActions", "PbSendNewChats", $g_bPbSendNew, "Bool")

	IniReadS($g_bEnableFriendlyChallenge, $g_sProfileConfigPath, "ChatActions", "EnableFriendlyChallenge", $g_bEnableFriendlyChallenge, "Bool")
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

	IniReadS($g_sIAVar, $g_sProfileConfigPath, "ChatActions", "String", '0|0|0|0|0', Default)
	$g_aIAVar = StringSplit($g_sIAVar, "|", $STR_NOCOUNT)
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

	IniReadS($g_iTxtMinSaveGTFO_Elixir, $g_sProfileConfigPath, "GTFO", "TxtMinSaveGTFO_Elixir", $g_iTxtMinSaveGTFO_Elixir, "Int")
	IniReadS($g_iTxtCyclesGTFO, $g_sProfileConfigPath, "GTFO", "txtCyclesGTFO", $g_iTxtCyclesGTFO, "Int")
	IniReadS($g_iTxtMinSaveGTFO_DE, $g_sProfileConfigPath, "GTFO", "TxtMinSaveGTFO_DE", $g_iTxtMinSaveGTFO_DE, "Int")
	IniReadS($g_bChkUseKickOut, $g_sProfileConfigPath, "GTFO", "chkUseKickOut", $g_bChkUseKickOut, "Bool")
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
	IniReadS($g_bCollectAchievements, $g_sProfileConfigPath, "Bot Humanization", "chkCollectAchievements", $g_bCollectAchievements, "Bool")
	IniReadS($g_bLookAtRedNotifications, $g_sProfileConfigPath, "Bot Humanization", "chkLookAtRedNotifications", $g_bLookAtRedNotifications, "Bool")
	For $i = 0 To 12
		IniReadS($g_iacmbPriority[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbPriority[" & $i & "]", $g_iacmbPriority[$i], "int")
	Next
	For $i = 0 To 1
		IniReadS($g_iacmbMaxSpeed[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbMaxSpeed[" & $i & "]", $g_iacmbMaxSpeed[$i], "int")
	Next
	For $i = 0 To 1
		IniReadS($g_iacmbPause[$i], $g_sProfileConfigPath, "Bot Humanization", "cmbPause[" & $i & "]", $g_iacmbPause[$i], "int")
	Next
	For $i = 0 To 1
		IniReadS($g_iahumanMessage[$i], $g_sProfileConfigPath, "Bot Humanization", "humanMessage[" & $i & "]", $g_iahumanMessage[$i])
	Next
	IniReadS($g_iCmbMaxActionsNumber, $g_sProfileConfigPath, "Bot Humanization", "cmbMaxActionsNumber", $g_iCmbMaxActionsNumber, "int")
	IniReadS($g_iTxtChallengeMessage, $g_sProfileConfigPath, "Bot Humanization", "challengeMessage", $g_iTxtChallengeMessage)
EndFunc   ;==>ReadConfig_MOD_Humanization
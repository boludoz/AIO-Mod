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
#cs
	Global $g_hChkCollectMagicItems, $g_hChkCollectFree, _
	$g_hChkBuilderPotion, $g_hChkClockTowerPotion, $g_hChkHeroPotion, $g_hChkLabPotion, $g_hChkPowerPotion, $g_hChkResourcePotion, _
	$g_hComboBuilderPotion, $g_hComboClockTowerPotion, $g_hComboHeroPotion, $g_hComboLabPotion, $g_hComboPowerPotion, _
	$g_hInputGoldItems, $g_hInputElixirItem, $g_hInputDarkElixirItem
                $res = GUICtrlRead($Combo1)
	_Ini_Add("MagicItems", "DelayTimeClan", $g_sDelayTimeClan)
            Case $Save
                $res = GUICtrlRead($Combo1)
                IniWrite($IniFile, "Display Properties", "Resolution", $res)
            Case $Load
                ; last parameter '1024x768' is default value if nothing found in ini file
                $IniRead = IniRead($IniFile, "Display Properties", "Resolution", "1024x768")
                GUICtrlSetData($Combo1,$IniRead)
        EndSwitch
		#ce
EndFunc   ;==>SaveConfig_MOD_MagicItems

Func SaveConfig_MOD_ChatActions()
	; <><><> ChatActions <><><>
	ApplyConfig_MOD_ChatActions(GetApplyConfigSaveAction())
	_Ini_Add("ChatActions", "EnableChatClan", $g_bChatClan ? 1 : 0)
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

	$g_sIAVar = _ArrayToString($g_aIAVar)
	_Ini_Add("ChatActions", "String", $g_sIAVar)
	
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
	_Ini_Add("DailyDiscounts", "DD_DealsSet", $g_bDD_DealsSet ? 1 : 0)

	; BB Suggested Upgrades
	_Ini_Add("other", "ChkBBIgnoreWalls", $g_bChkBBIgnoreWalls ? 1 : 0)
EndFunc   ;==>SaveConfig_MOD_600_6

Func SaveConfig_MOD_600_12()
	; <><><> GTFO <><><>
	ApplyConfig_MOD_600_12(GetApplyConfigSaveAction())
	_Ini_Add("GTFO", "chkGTFOClanHop", $g_bChkGTFOClanHop)
	_Ini_Add("GTFO", "chkGTFOReturnClan", $g_bChkGTFOReturnClan)
	_Ini_Add("GTFO", "chkUseGTFO", $g_bChkUseGTFO)

	_Ini_Add("GTFO", "txtClanID", $g_sTxtClanID)
	_Ini_Add("GTFO", "txtMinSaveGTFO_Elixir", $g_iTxtMinSaveGTFO_Elixir)
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

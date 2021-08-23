; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Design
; Description ...: This file creates the "MOD" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: NguyenAnhHD
; Modified ......: Team AiO MOD++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_MOD = 0
Global $g_hGUI_MOD_TAB = 0, $g_hGUI_MOD_TAB_ITEM1 = 0, $g_hGUI_MOD_TAB_ITEM2 = 0, $g_hGUI_MOD_TAB_ITEM3 = 0, $g_hGUI_MOD_TAB_ITEM4 = 0, $g_hGUI_MOD_TAB_ITEM5 = 0, $g_hGUI_MOD_TAB_ITEM6 = 0, $g_hGUI_MOD_TAB_ITEM7 = 0

#include "MOD GUI Design - SuperXP.au3"
#include "MOD GUI Design - Humanization.au3"
#include "MOD GUI Design - ChatActions.au3"
#include "MOD GUI Design - GTFO.au3"
#include "MOD GUI Design - AiO-Debug.au3"
#include "MOD GUI Design - WarPreparation.au3"

Func CreateMODTab()

	$g_hGUI_MOD = _GUICreate("", $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $_GUI_CHILD_LEFT, $_GUI_CHILD_TOP, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hFrmBotEx)

	GUISwitch($g_hGUI_MOD)
	$g_hGUI_MOD_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $TCS_RIGHTJUSTIFY)

		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_00", "Super XP"))
			TabSuperXPGUI()
		$g_hGUI_MOD_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_02", "Humanization"))
			TabHumanizationGUI()
		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_03", "Chat"))
			TabChatActionsGUI()
		$g_hGUI_MOD_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_04", "GTFO"))
			TabGTFOGUI()
		$g_hGUI_MOD_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_05", "Prewar"))
			TabWarPreparationGUI()
		$g_hGUI_MOD_TAB_ITEM6 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_06", "Misc"))
			TabMiscGUI()

	If $g_bDevMode Then
		$g_hGUI_MOD_TAB_ITEM7 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_07", "Debug"))
			TabDebugGUI()
		EndIf

	GUICtrlCreateTabItem("")
EndFunc   ;==>CreateMODTab

; Tab Misc GUI - Team AiO MOD++
 Func TabMiscGUI()
	SplashStep("Loading mod - misc options ...")

	Local $iX = 32, $iY = 45

	GUICtrlCreateGroup("Misc options", $iX - 28, $iY, 415 + 28, 164)

	$iY += 25

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "AttackLabel",  "Attack"), $iX, $iY, 408, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "AttackTip",  "Attacks extra functions."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$iY += 30
	
	$g_hChkSkipFirstAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "ChkSkipFirstAttack", "Skip attack first."), $iX, $iY, 244, 17)
  	GUICtrlSetOnEvent(-1, "chkMiscModOptions")
  	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "ChkBuildingsLocateTip", "Skip first check without attack first."))

	$iY += 25

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "OtherSettingsLabel", "Other"), $iX, $iY, 408, 22, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "OtherSettingsTip", "Other settings"))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)
	$iY += 30

  	$g_hChkBuildingsLocate = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "ChkBuildingsLocate",  "Skip buildings location."), 32, $iY, 244, 17)
	GUICtrlSetOnEvent(-1, "chkMiscModOptions")
	$iY += 25

	$g_hChkBotLogLineLimit = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "BotLogLineLimit", "Disable clear bot log, and line limit to: "), $iX, $iY, -1, -1)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "BotLogLineLimitTips", "Bot log will never clear after battle, and clear bot log will replace will line limit."))
	GUICtrlSetOnEvent(-1, "chkBotLogLineLimit")
	
	$g_hTxtLogLineLimit = _GUICtrlCreateInput("240", $iX + 300, $iY + 2, 35, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "BotLogLineLimitValue", "Please enter how many line to limit for the bot log."))
	GUICtrlSetLimit(-1, 4)
	GUICtrlSetOnEvent(-1, "txtLogLineLimit")
	
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	GUICtrlCreateTabItem("")
EndFunc   ;==>TabMiscGUI

Global $g_hChkCollectMagicItems, _ ;$g_hChkCollectFree, _
$g_hBtnMagicItemsConfig, $g_hChkBuilderPotion, $g_hChkHeroPotion, $g_hChkLabPotion, $g_hChkPowerPotion, $g_hChkResourcePotion, _
$g_hComboHeroPotion, $g_hComboPowerPotion, $g_hInputBuilderPotion, $g_hInputLabPotion, $g_hInputGoldItems, $g_hInputElixirItems, $g_hInputDarkElixirItems;, $g_hCmbClockTowerPotion, $g_hChkClockTowerPotion

Func CreateMiscMagicSubTab()

	; GUI SubTab
	Local $x = 15, $y = 45

	GUICtrlCreateGroup("Collect Items", 16, 24, 408, 78)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnShop, 24, 46, 25, 25)
	$g_hChkCollectMagicItems = GUICtrlCreateCheckbox("Collect magic items", 56, 48, 105, 17)
	GUICtrlSetOnEvent(-1, "btnDDApply")
	$g_hChkFreeMagicItems = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkFreeMagicItems", "Collect Free Magic Items"), 56, 73, 200, 17)
	GUICtrlSetOnEvent(-1, "ChkFreeMagicItems")
	$g_hBtnMagicItemsConfig = GUICtrlCreateButton("Settings", 176, 48, 97, 25)
	GUICtrlSetOnEvent(-1, "btnDailyDiscounts")

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("Magic Items", 16, 104, 408, 155)

	$y = 128
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModBuilderP, 24, $y - 5, 25, 25)
	$g_hChkBuilderPotion = GUICtrlCreateCheckbox("Use builder potion when busy builders is > = : ", 56, $y, 225, 17)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
	$g_hInputBuilderPotion = _GUICtrlCreateInput("Number", 320, $y, 41, 21)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")

	$y += 32
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnLabP, 24, $y - 5, 25, 25)
	$g_hChkLabPotion = GUICtrlCreateCheckbox("Use research potion when laboratory hours is >= ", 56, $y, 233, 17)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
	$g_hInputLabPotion = _GUICtrlCreateInput("Hours", 320, $y, 41, 21)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
		
	$y += 32
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModResourceP, 24, $y - 5, 25, 25)
	$g_hChkResourcePotion = GUICtrlCreateCheckbox("Use resource potion only if storage are :", 56, $y, 225, 17)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")	
	
	$y += 36
	$g_hInputGoldItems = _GUICtrlCreateInput("1000000", 88, $y, 73, 21)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
	$g_hInputElixirItems = _GUICtrlCreateInput("1000000", 192, $y, 73, 21)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
	$g_hInputDarkElixirItems = _GUICtrlCreateInput("1000", 296, $y, 49, 21)
	GUICtrlSetOnEvent(-1, "MagicItemsRefresh")
	GUICtrlCreateLabel("Lower : ", 40, $y, 42, 17)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnGoldP, 163, $y - 2, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnDarkP, 345, $y - 2, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnElixirP, 265, $y - 2, 25, 25)

	; $y += 32
	; $g_hChkHeroPotion = GUICtrlCreateCheckbox("Use hero potion whem are avariable : ", 56, $y, 217, 17)
	; GUICtrlSetState (-1, $GUI_DISABLE)
	; $y += 32
	; $g_hChkPowerPotion = GUICtrlCreateCheckbox("Use power potion during : ", 56, 256, 225, 17)
	; GUICtrlSetState (-1, $GUI_DISABLE)
	; $g_hComboPowerPotion = GUICtrlCreateCombo("Select", 296, 256, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	; GUICtrlSetState (-1, $GUI_DISABLE)
	; $g_hComboHeroPotion = GUICtrlCreateCombo("Select", 296, 192, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	; GUICtrlSetState (-1, $GUI_HIDE)
	; _GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModPowerP, 24, 254, 25, 25)
	; _GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModHeroP, 24, 190, 25, 25)

EndFunc   ;==>CreateMiscMagicSubTab
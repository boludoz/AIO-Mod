; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Design
; Description ...: This file creates the "MOD" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: NguyenAnhHD
; Modified ......: Team AiO MOD++ (2019)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_MOD = 0
Global $g_hGUI_MOD_TAB = 0, $g_hGUI_MOD_TAB_ITEM1 = 0, $g_hGUI_MOD_TAB_ITEM2 = 0, $g_hGUI_MOD_TAB_ITEM3 = 0, $g_hGUI_MOD_TAB_ITEM4 = 0, $g_hGUI_MOD_TAB_ITEM5 = 0, _
$g_hGUI_MOD_TAB_ITEM6 = 0

#include "MOD GUI Design - SuperXP.au3"
#include "MOD GUI Design - Humanization.au3"
#include "MOD GUI Design - ChatActions.au3"
#include "MOD GUI Design - GTFO.au3"
#include "MOD GUI Design - AiO-Debug.au3"

Func CreateMODTab()

	$g_hGUI_MOD = _GUICreate("", $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $_GUI_CHILD_LEFT, $_GUI_CHILD_TOP, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hFrmBotEx)

	GUISwitch($g_hGUI_MOD)
	$g_hGUI_MOD_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
;		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_01", "Misc Mod"))
;		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_03", "War Preparation"))

		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_00", "Super XP"))
			TabSuperXPGUI()
		$g_hGUI_MOD_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_02", "Humanization"))
			TabHumanizationGUI()
		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_03", "Chat"))
			TabChatActionsGUI()
		$g_hGUI_MOD_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_04", "GTFO"))
			TabGTFOGUI()
		$g_hGUI_MOD_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_05", "Misc"))
			TabMiscGUI()

	If $g_bDevMode Then
		$g_hGUI_MOD_TAB_ITEM6 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_06", "Debug"))
			TabDebugGUI()
		EndIf

	GUICtrlCreateTabItem("")
EndFunc   ;==>CreateMODTab

; Tab Misc GUI - Team AiO MOD++
 Func TabMiscGUI()
	SplashStep("Loading M0d - Misc...")

	;Local $x = 10, $y = 45

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "DelayLabel",  "Delay"), 7, 45, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "DelayTip",  "Delay before performing each action. You can add time before each action to improve performance and lower CPU usage."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hUseSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseSleep",  "Custom delay; CPU: - : higher, / + : lower."), 32, 80, 365, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hIntSleep = GUICtrlCreateSlider(32, 104, 250, 25, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS))
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "UseSleep", "Increase for all delay setting, more stabilize for slow PC/Multi Emulators."))
	_GUICtrlSlider_SetTipSide(-1, $TBTS_BOTTOM)
	_GUICtrlSlider_SetTicFreq(-100, 100)
	GUICtrlSetLimit(-1, 200, -99)
	GUICtrlSetData(-1, 20)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hDelayLabel = GUICtrlCreateLabel("20", 192 + 97, 112, 36, 17)

	$g_hUseRandomSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseRandomSleep",  "Random"), 32, 136, 81, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hNoAttackSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "NoAttackSleep",  "Do not use this during the attack."), 32, 160, 177, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "AttackLabel",  "Attack"), 7, 192, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "AttackTip",  "Attacks extra functions."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

;~ 	$g_hDeployCastleFirst = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "DeployCastleSiegeFirst",  "Deploy castle first (All modes)"), 32, 224, 161, 17)
;~ 	GUICtrlSetOnEvent(-1, "chkDelayMod")
;~ 	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "DeployCastleSiegeFirstTip", "Deploy CC / Sieges troops first, support for all modes."))

	$g_hDisableColorLog = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "DisableColorLog",  "No color attack log"), 32, 248, 113, 17)

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "OtherSettingsLabel", "Other"), 7, 280, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "OtherSettingsTip", "Other settings"))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hAvoidLocation = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "AvoidLocation", "Skip buildings location."), 32, 312, 105, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateTabItem("")
EndFunc   ;==>TabMiscGUI

Global $g_hChkCollectMagicItems, $g_hChkCollectFree, _
$g_hBtnMagicItemsConfig, _
$g_hChkBuilderPotion, $g_hChkClockTowerPotion, $g_hChkHeroPotion, $g_hChkLabPotion, $g_hChkPowerPotion, $g_hChkResourcePotion, _
$g_hComboClockTowerPotion, $g_hComboHeroPotion, $g_hComboPowerPotion, _
$g_hInputBuilderPotion, $g_hInputLabPotion, $g_hInputGoldItems, $g_hInputElixirItems, $g_hInputDarkElixirItems

Func CreateMiscMagicSubTab()

	; GUI SubTab
	Local $x = 15, $y = 45

	GUICtrlCreateGroup("Collect Items", 16, 24, 449, 65)
	$g_hChkCollectMagicItems = GUICtrlCreateCheckbox("Collect magic items", 56, 48, 113, 17)
	GUICtrlSetOnEvent(-1, "btnDDApply")
	$g_hChkCollectFree = GUICtrlCreateCheckbox("Collect FREE items", 320, 48, 113, 17)
	GUICtrlSetOnEvent(-1, "ChkFreeMagicItems")
	$g_hBtnMagicItemsConfig = GUICtrlCreateButton("Settings", 176, 48, 97, 25)
	GUICtrlSetOnEvent(-1, "btnDailyDiscounts")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("Magic Items", 16, 104, 449, 257)
	$g_hChkBuilderPotion = GUICtrlCreateCheckbox("Use builder potion when busy builders is equal or lower than : ", 56, 128, 225, 17)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hChkClockTowerPotion = GUICtrlCreateCheckbox("Use clock tower potion when :", 56, 160, 217, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkHeroPotion = GUICtrlCreateCheckbox("Use hero potion whem are avariable : ", 56, 192, 217, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkLabPotion = GUICtrlCreateCheckbox("Use research potion when laboratory time is > ", 56, 224, 233, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkPowerPotion = GUICtrlCreateCheckbox("Use power potion during : ", 56, 256, 225, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkResourcePotion = GUICtrlCreateCheckbox("Use resource potion only if storage are :", 56, 288, 225, 17)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hInputBuilderPotion = GUICtrlCreateInput("Number", 296, 128, 89, 25)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hComboClockTowerPotion = GUICtrlCreateCombo("Select", 296, 160, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hComboHeroPotion = GUICtrlCreateCombo("Select", 296, 192, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_HIDE)
	$g_hInputLabPotion = GUICtrlCreateInput("Hours", 296, 224, 41, 21)
	GUICtrlSetState (-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xD1DFE7)
	$g_hComboPowerPotion = GUICtrlCreateCombo("Select", 296, 256, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hInputGoldItems = GUICtrlCreateInput("1000000", 88, 320, 73, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	GUICtrlSetBkColor(-1, 0xD1DFE7)
	$g_hInputElixirItems = GUICtrlCreateInput("1000000", 192, 320, 73, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	GUICtrlSetBkColor(-1, 0xD1DFE7)
	$g_hInputDarkElixirItems = GUICtrlCreateInput("1000", 296, 320, 49, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	GUICtrlSetBkColor(-1, 0xD1DFE7)
	GUICtrlCreateLabel("Lower : ", 40, 320, 42, 17)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnShop, 24, 46, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModBuilderP, 24, 126, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModClockTowerP, 24, 158, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModHeroP, 24, 190, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnLabP, 24, 222, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModPowerP, 24, 254, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModResourceP, 24, 284, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnGoldP, 163, 318, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnElixirP, 265, 318, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnDarkP, 345, 318, 25, 25)

EndFunc   ;==>CreateMiscMagicSubTab

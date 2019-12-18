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

		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_0", "Super XP"))
			TabSuperXPGUI()
		$g_hGUI_MOD_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_2", "Humanization"))
			TabHumanizationGUI()
		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_3", "ChatActions"))
			TabChatActionsGUI()
        $g_hGUI_MOD_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_4", "GTFO"))
            TabGTFOGUI()
        $g_hGUI_MOD_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_5", "Misc"))
            TabMiscGUI()


		If $g_bDevMode Then
			$g_hGUI_MOD_TAB_ITEM6 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_6", "Debug"))
				TabDebugGUI()
		EndIf

	GUICtrlCreateTabItem("")
 EndFunc   ;==>CreateMODTab

; Tab Misc GUI - Team AiO MOD++
 Func TabMiscGUI()
	SplashStep("Loading M0d - Misc...")

	;Local $x = 10, $y = 45

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "DelayLabel",  "Delay"), 30, 45, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "DelayTip",  "Delay before performing each action. You can add time before each action to improve performance and lower CPU usage."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hUseSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseSleep",  "Custom delay; CPU: - : higher, / + : lower."), 32, 80, 365, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hIntSleep = GUICtrlCreateSlider(32, 104, 153, 25)
	GUICtrlSetLimit(-1, 100, -100)
	GUICtrlSetData(-1, 20)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hDelayLabel = GUICtrlCreateLabel("20", 192, 112, 36, 17)

	$g_hUseRandomSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseRandomSleep",  "Random"), 32, 136, 81, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hNoAttackSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "NoAttackSleep",  "Do not use this during the attack."), 32, 160, 177, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "AttackLabel",  "Attack"), 30, 192, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "AttackTip",  "Attacks extra functions."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hDeployCastleFirst = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "DeployCastleFirst",  "Deploy castle first"), 32, 224, 161, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "DeployCastleFirstTip", "Deploy CC troops first, support for all modes."))

	$g_hDisableColorLog = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "DisableColorLog",  "No color attack log"), 32, 248, 113, 17)

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "OtherSettingsLabel", "Other"), 30, 280, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "OtherSettingsTip", "Other settings"))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hAvoidLocation = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "AvoidLocation", "Skip buildings location."), 32, 312, 105, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateTabItem("")
EndFunc   ;==>TabMiscGUI

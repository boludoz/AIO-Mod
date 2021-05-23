; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Train Army" tab under the "Builder Base" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: ProMac (03-2018)
; Remarks .......: This file is part of MultiBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MultiBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_alblBldBaseStats[4] = ["", "", "", ""]
Global $g_hChkCollectBuilderBase = 0, $g_hChkStartClockTowerBoost = 0, $g_hChkCTBoostBlderBz = 0, $g_hChkCTBoostAtkAvailable = 0
Global $g_hChkCollectBldGE = 0, $g_hChkCollectBldGems = 0, $g_hChkActivateClockTower = 0, $g_hChkCleanBBYard = 0
Global $g_hBtnBBAtkLogClear = 0,$g_hBtnBBAtkLogCopyClipboard=0

Global $g_hChkOnlyBuilderBase, $g_hTxtBBMinAttack, $g_hTxtBBMaxAttack, $g_hDebugBBattack, $g_hbtnBBAttack ; AIO ++

Func CreateMiscBuilderBaseSubTab()
	Local $x = 15, $y = 45

	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "Group_01", "Collect && Activate"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 125)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGoldMineL5, $x + 7, $y - 5, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixirCollectorL5, $x + 32, $y - 5, 24, 24)
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnGemMine, $x + 57, $y - 5, 24, 24)
		$g_hChkCollectBuilderBase = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCollectBuilderBase", "Collect Resources"), $x + 100, $y - 1, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCollectBuilderBase_Info_01", "Check this to collect Resources on the Builder Base"))

	$y += 22
		GUICtrlCreateIcon($g_sLibIconPath, $eIcnClockTower, $x + 32, $y, 24, 24)
		$g_hChkStartClockTowerBoost = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkActivateClockTowerBoost", "Activate Clock Tower Boost"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkActivateClockTowerBoost_Info_01", "Check this to activate the Clock Tower Boost when it is available.\r\nThis option doesn't use your Gems"))
			GUICtrlSetOnEvent(-1, "chkStartClockTowerBoost")
	$y += 22
		$g_hChkCTBoostBlderBz = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCTBoostBlderBz", "Only when builder is busy"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCTBoostBlderBz_Info_01", "Boost only when the builder is busy"))
			GUICtrlSetOnEvent(-1, "chkCTBoostBlderBz")
			GUICtrlSetState (-1, $GUI_DISABLE)
	$y += 28
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTree, $x + 20, $y, 24, 24)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBark, $x + 45, $y, 24, 24)
		$g_hChkCleanBBYard = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCleanBBYard", "Remove Obstacles"), $x + 100, $y + 4, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkCleanYardBB_Info_01", "Check this to automatically clear Yard from Trees, Trunks etc. from Builder base."))
			;GUICtrlSetOnEvent(-1, "ChkCleanBBYard")
			GUICtrlSetState(-1, $GUI_UNCHECKED)

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y += 55

	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "Group_03", "Builders Base Loop"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 52)
		$g_hChkOnlyBuilderBase = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "ChkOnlyBuilderBase", "Only play in Builder Base"), $x + 50, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "ChkOnlyBuilderBase")

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "LblMaxLoopsAttackBB", "Attack cycles :"), $x + 220, $y + 4, -1, -1)

		$g_hTxtBBMinAttack = _GUICtrlCreateInput("1", $x + 318, $y, 40, -1, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetLimit(-1, 3, 1)
		GUICtrlSetOnEvent(-1, "ChkBBAttackLoops")

		GUICtrlCreateLabel("-", $x + 360, $y + 2)

		$g_hTxtBBMaxAttack = _GUICtrlCreateInput("4", $x + 365, $y, 40, -1, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetLimit(-1, 3, 1)
		GUICtrlSetOnEvent(-1, "ChkBBAttackLoops")

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y += 54

	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "Group_02", "Builders Base Stats"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 223)
		$y += 5
		_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnBBGold, $x , $y, 16, 16)
		$g_alblBldBaseStats[$eLootGoldBB] = GUICtrlCreateLabel("---", $x + 35, $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)
		$y += 30
		_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnBBElixir, $x , $y, 16, 16)
		$g_alblBldBaseStats[$eLootElixirBB] = GUICtrlCreateLabel("---", $x + 35 , $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)
		$y += 30
		_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnBBTrophies, $x , $y, 16, 16)
		$g_alblBldBaseStats[$eLootTrophyBB] = GUICtrlCreateLabel("---", $x + 35 , $y + 2, 100, -1)
			GUICtrlSetFont(-1, 9, $FW_BOLD, Default, "Arial", $CLEARTYPE_QUALITY)

		$y += 160 - 52

		$g_hBtnBBAtkLogClear = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "BtnBBAtkLogClear", "Clear Atk. Log"), $x + 245, $y - 1, 80, 23)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "BtnBBAtkLogClear_Info_01", "Use this to clear the Attack Log."))
			GUICtrlSetOnEvent(-1, "btnBBAtkLogClear")

		$g_hBtnBBAtkLogCopyClipboard = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "BtnBBAtkLogCopyClipboard", "Copy to Clipboard"), $x + 325, $y - 1, 100, 23)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Builder Base - Misc", "BtnBBAtkLogCopyClipboard_Info_01", "Use this to copy the Attack Log to the Clipboard (CTRL+C)"))
			GUICtrlSetOnEvent(-1, "btnBBAtkLogCopyClipboard")

		$g_hDebugBBattack = GUICtrlCreateCheckbox("Debug BB Attack", $x, $y - 55, -1, -1)
		If Not $g_bDevMode Then
			GUICtrlSetState(-1, $GUI_HIDE)
		EndIf
		GUICtrlSetOnEvent(-1, "chkDebugBBattack")
		$g_hbtnBBAttack = GUICtrlCreateButton("Debug UI", $x, $y - 25, 85, 25)
		If Not $g_bDevMode Then
			GUICtrlSetState(-1, $GUI_HIDE)
		EndIf
		GUICtrlSetOnEvent(-1, "DebugUI")

	GUICtrlCreateGroup("", -99, -99, 1, 1)


EndFunc   ;==>CreateMiscBuilderBaseSubTab

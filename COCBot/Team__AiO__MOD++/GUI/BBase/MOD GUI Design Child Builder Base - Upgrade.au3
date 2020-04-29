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

Global $g_hChkBBSuggestedUpgrades = 0, $g_hChkBBSuggestedUpgradesIgnoreGold = 0, $g_hChkBBSuggestedUpgradesIgnoreElixir, $g_hChkBBSuggestedUpgradesIgnoreHall = 0
Global $g_hChkPlacingNewBuildings = 0, $g_hChkUpgradeTroops = 0, $g_hChkUpgradeMachine = 0
Global $g_hDebugBBattack = 0, $g_hLblBBNextUpgrade = 0, $g_hCmbBBLaboratory = 0, $g_hPicBBLabUpgrade = ""
Global $g_hChkBBUpgradeWalls = 0, $g_hLblBBWallLevelInfo = 0, $g_hLblBBWallNumberInfo = 0, $g_hCmbBBWallLevel = 0, $g_hPicBBWallUpgrade = "", $g_hTxtBBWallNumber = 0, $g_hLblBBWallCostInfo = 0, $g_hLblBBWallCost = 0

Global $g_hChkBBSuggestedUpgrades = 0, $g_hChkBBSuggestedUpgradesIgnoreGold = 0 , $g_hChkBBSuggestedUpgradesIgnoreElixir , $g_hChkBBSuggestedUpgradesIgnoreHall = 0
Global $g_hChkPlacingNewBuildings = 0, $g_hChkBBSuggestedUpgradesIgnoreWall = 0

Func CreateUpgradeBuilderBaseSubTab()
	Local $x = 15, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "Group_01", "Buildings Upgrades"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 95)

		; _GUICtrlCreatePic($g_sIcnMBisland, $x , $y , 64, 64)
		_GUICtrlCreatePic($g_sIcnMBisland, $x , $y + 5, 48, 48)
		$g_hChkBBSuggestedUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkBBSuggestedUpgrades", "Suggested Upgrades"), $x + 70, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgrades")
		$g_hChkBBSuggestedUpgradesIgnoreGold = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkBBSuggestedUpgradesIgnore_01", "Ignore Gold values"), $x + 200, $y - 5, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
		$g_hChkBBSuggestedUpgradesIgnoreElixir = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkBBSuggestedUpgradesIgnore_02", "Ignore Elixir values"), $x + 200, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesElixir")
		$g_hChkBBSuggestedUpgradesIgnoreHall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkBBSuggestedUpgradesIgnore_03", "Ignore Builder Hall"), $x + 315, $y - 5, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
		$g_hChkPlacingNewBuildings = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkPlacingNewBuildings", "Build 'New' tagged buildings"), $x + 200, $y + 47, -1, -1)
			GUICtrlSetOnEvent(-1, "chkPlacingNewBuildings")
		$g_hChkBBSuggestedUpgradesIgnoreWall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Misc", "ChkBBSuggestedUpgradesIgnore_04", "Ignore Wall"), $x + 315, $y + 20, -1, -1)
			GUICtrlSetOnEvent(-1, "chkActivateBBSuggestedUpgradesGold")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 15
	$y = 45 + 100
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "Group_02", "Troops Upgrade"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 130)
		;_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnLabBB, $x , $y - 3, 48, 48)
		_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnMachine, $x , $y + 50, 48, 48)
		;$g_hChkUpgradeTroops = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkUpgradeTroops", "Upgrade Troops"), $x + 70, $y + 10, -1, -1)
		;	GUICtrlSetOnEvent(-1, "ChkBBLab")
		;$g_hLblBBNextUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBNextUpgrade", "Next one") & ":", $x + 80, $y + 38, 50, -1)
		;	GUICtrlSetState(-1, $GUI_DISABLE)
		;$g_hCmbBBLaboratory = GUICtrlCreateCombo("", $x + 135, $y + 35, 100, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
		;	GUICtrlSetData(-1, "Barb|Arch|Giant|Beta|Bomb|BabyDrag|Cannon|Night|Drop|Pekka|Any", GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any"))
		;	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "CmbBBLaboratory_Info_01", "Select the troop type to upgrade with this pull down menu") & @CRLF & _
		;					   GetTranslatedFileIni("MMBR GUI Design Child Builder Base - Upgrade", "CmbBBLaboratory_Info_02", "The troop icon will appear on the right."))
		;	GUICtrlSetState(-1, $GUI_DISABLE)
		;	GUICtrlSetOnEvent(-1, "cmbBBLab")

		$g_hChkUpgradeMachine = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkUpgradeMachine", "Upgrades Machine"), $x + 70, $y + 68, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkUpgradeMachine_Info_01", "Prioritize the Machine upgrades if 'Any' was selected."))

		$g_hPicBBLabUpgrade = _GUICtrlCreateIcon($g_sLibBBIconPath, 11, $x + 330, $y, 64, 64)
			GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 15
	$y = 45 + 100 + 135
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "Group_03", "Upgrade Walls"), $x - 10, $y - 20, $g_iSizeWGrpTab2, 130)
		_GUICtrlCreateIcon($g_sLibBBIconPath, $eIcnBBWallInfo, $x , $y + 20, 48, 48)
		$g_hChkBBUpgradeWalls = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "ChkBBUpgradeWalls", "Upgrade Walls"), $x + 60, $y + 10, -1, -1)
			GUICtrlSetOnEvent(-1, "ChkBBWalls")
		$g_hLblBBWallLevelInfo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBWallLevelInfo", "Search for Walls Level") & ":", $x + 70, $y + 38, 120, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hCmbBBWallLevel = GUICtrlCreateCombo("", $x + 185, $y + 35, 50, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, "1|2|3|4|5|6|7|8", GetTranslatedFileIni("MBR Global GUI Design", "Level1", "1"))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "CmbBBWallLevel_Info_01", "Select the wall level to upgrade with this pull down menu") & @CRLF & _
							   GetTranslatedFileIni("MMBR GUI Design Child Builder Base - Upgrade", "CmbBBWallLevel_Info_02", "The wall icon will appear below."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbBBWall")
		$g_hLblBBWallCostInfo =GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBNextWalllevelcosts", "Next Wall level costs") & ":", $x + 70, $y + 71, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBNextWalllevelcosts_Info_01", "Use this value as an indicator.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBNextWalllevelcosts_Info_02", "The value will update if you select an other wall level."))
		$g_hLblBBWallCost = GUICtrlCreateLabel("10 000", $x + 175, $y + 71, 50, -1, $SS_RIGHT)
		$g_hLblBBWallNumberInfo = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Builder Base - Upgrade", "LblBBWallNumberInfo", "Wall Counter") & ":", $x + 290, $y + 71, 80, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hTxtBBWallNumber = _GUICtrlCreateInput("0", $x + 360, $y + 68, 40, -1, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			GUICtrlSetState(-1, $GUI_HIDE)

		$g_hPicBBWallUpgrade = _GUICtrlCreateIcon($g_sLibBBIconPath, 11, $x + 345, $y, 64, 64)
			GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)


			; Just for Dev Debug purposes
		$g_hDebugBBattack = GUICtrlCreateCheckbox("Debug BB Attack", $x, $y + 130, -1, -1)
			If Not $g_bDevMode Then
				GUICtrlSetState(-1, $GUI_HIDE)
			EndIf
			GUICtrlSetOnEvent(-1, "chkDebugBBattack")

		Global $g_hbtnBBAttack = GUICtrlCreateButton("Debug UI", $x+120 , $y + 130, 85, 25)
			If Not $g_bDevMode Then
				GUICtrlSetState(-1, $GUI_HIDE)
			EndIf
			GUICtrlSetOnEvent(-1, "DebugUI")




EndFunc   ;==>CreateMiscBuilderBaseSubTab
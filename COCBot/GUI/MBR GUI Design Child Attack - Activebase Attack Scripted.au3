; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Scripted Attack" tab under the "Attack" tab under the "ActiveBase" tab under the "Search & Attack" tab under the "Attack Plan" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_ACTIVEBASE_ATTACK_SCRIPTED = 0
Global $g_hCmbScriptNameAB = 0, $g_hCmbScriptRedlineImplAB = 0, $g_hCmbScriptDroplineAB = 0
Global $g_hLblNotesScriptAB = 0, $g_hBtnAttNowAB = 0

; Random CSV - Team AIO Mod++
Global $g_hTabItemCrateCsvAB = 0, $g_hTabItemCrateCsvTab1AB = 0, $g_hTabItemCrateCsvTab2AB = 0

Func CreateAttackSearchActiveBaseScripted()
	$g_hGUI_ACTIVEBASE_ATTACK_SCRIPTED = _GUICreate("", $_GUI_MAIN_WIDTH - 195, $g_iSizeHGrpTab4, 150, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_ACTIVEBASE)
	;GUISetBkColor($COLOR_WHITE, $g_hGUI_ACTIVEBASE_ATTACK_SCRIPTED)

    Local $x = 25, $y = 20	

	$g_ahChkLinkThatAndUseIn[$LB] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Bottom", "ChkSyncAttackAndTrainAB_", "Sync DB and Train"), $x - 5 - 16, $y + 1 - 21, -1, -1)
		GUICtrlSetOnEvent(-1, "ChkLinkThatAndUseInAB")
		
	$g_hTabItemCrateCsvAB = GUICtrlCreateTab($x - 20, $y - 20 + 21, 270, $TCS_MULTILINE - 168 - 21)
	$g_hTabItemCrateCsvTab1AB = GUICtrlCreateTabItem( GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "DBTABScript_Main", "CSV Main"))
		
	$y += 25
		$g_hCmbScriptNameAB = GUICtrlCreateCombo("", $x, $y, 200, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "CmbScriptName", -1))
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "cmbScriptNameAB")
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnReload, $x + 210, $y + 2, 16, 16)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconReload_Info_01", -1))
			GUICtrlSetOnEvent(-1, 'UpdateComboScriptNameAB') ; Run this function when the secondary GUI [X] is clicked

	$y += 20
		$g_hLblNotesScriptAB =  GUICtrlCreateLabel("", $x, $y + 4, 200, 195)

		$g_hBtnAttNowAB = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "btnAttNow", -1), $x + 70, $y + 198, 91, 23)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "btnAttNow_Info_01", -1))
			GUICtrlSetBkColor(-1, 0xBAD9C8)
			GUICtrlSetOnEvent(-1, "AttackNowAB")

		$g_hCmbScriptRedlineImplAB = GUICtrlCreateCombo("", $x, $y + 225, 230, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "CmbScriptRedlineImpl", "ImgLoc Raw Redline (default)|ImgLoc Redline Drop Points|Original Redline|External Edges"))
			_GUICtrlComboBox_SetCurSel(-1, $g_aiAttackScrRedlineRoutine[$LB])
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "CmbScriptRedlineImpl_Info_01", "Choose the Redline implementation. ImgLoc Redline is default and best."))
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "cmbScriptRedlineImplAB")
		$g_hCmbScriptDroplineAB = GUICtrlCreateCombo("", $x, $y + 250, 230, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "CmbScriptDropline", "Drop line fix outer corner|Drop line fist Redline point|Full Drop line fix outer corner|Full Drop line fist Redline point|No Drop line"))
			_GUICtrlComboBox_SetCurSel(-1, $g_aiAttackScrDroplineEdge[$LB])
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "CmbScriptDropline_Info_01", "Choose the drop line edges. Default is outer corner and safer. First Redline point can improve attack."))
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "cmbScriptDroplineAB")

		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnEdit, $x + 210, $y + 2, 16, 16)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconShow-Edit_Info_01", -1))
			GUICtrlSetOnEvent(-1, "EditScriptAB")

	$y += 25
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnAddcvs, $x + 210, $y + 2, 16, 16)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconCreate_Info_01", -1))
			GUICtrlSetOnEvent(-1, "NewScriptAB")

	$y += 25
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCopy, $x + 210, $y + 2, 16, 16)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconCopy_Info_01", -1))
			GUICtrlSetOnEvent(-1, "DuplicateScriptAB")

	$y += 25
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTrain, $x + 210, $y + 2, 16, 16)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconApply_Info_01", -1))
			GUICtrlSetOnEvent(-1, "ApplyScriptAB")
	
	#Region - Random CSV
	$g_hTabItemCrateCsvTab2AB = GUICtrlCreateTabItem( GetTranslatedFileIni("MBR GUI Design Child Attack - Attack", "TABScript_Random", "Random CSV selector"))
	$x = 20
	$y = 44

	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnReload, $x + 215, $y + 3, 16, 16)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconReload_Info_01", -1))
		GUICtrlSetOnEvent(-1, 'UpdateComboScriptNameAB') ; Run this function when the secondary GUI [X] is clicked

	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnAddcvs, $x + 215, $y + 25 + 3, 16, 16)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "IconCreate_Info_01", -1))
		GUICtrlSetOnEvent(-1, "NewScriptAB")

	$y += 6

	For $i = 0 To 3
		GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - Attack Scripted", "RGroup_0" & $i + 1, -1), $x, $y, 208, 77 - 29)
		
		$y += 17
			$g_ahChkRandomCSVAB[$i] = GUICtrlCreateCheckbox(" ", $x + 3, $y)
			GUICtrlSetOnEvent(-1, "ChkRandomCSVAB")

			$g_ahCmbRandomCSVAB[$i] = GUICtrlCreateCombo("", $x + 27, $y, 173, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetOnEvent(-1, "ChkRandomCSVAB")
		$y += 59 - 29
		
		GUICtrlCreateGroup("", -99, -99, 1, 1)
	Next
	
	GUICtrlCreateTabItem("")
	#EndRegion - Random CSV

	;------------------------------------------------------------------------------------------
	;----- populate list of script and assign the default value if no exist profile -----------
	UpdateComboScriptNameAB()
	Local $tempindex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, $g_sAttackScrScriptName[$LB])
	If $tempindex = -1 Then $tempindex = 0
	_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, $tempindex)
	;------------------------------------------------------------------------------------------

EndFunc   ;==>CreateAttackSearchActiveBaseScripted

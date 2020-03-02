; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Fahid.Mahmood (2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once
Func ChkBBWalls()
	If GUICtrlRead($g_hChkBBUpgradeWalls) = $GUI_CHECKED Then
		$g_bChkBBUpgradeWalls = True
		GUICtrlSetState($g_hLblBBWallLevelInfo, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbBBWallLevel, $GUI_ENABLE)
		GUICtrlSetState($g_hLblBBWallCostInfo, $GUI_ENABLE)
		GUICtrlSetState($g_hLblBBWallCost, $GUI_ENABLE)
		GUICtrlSetState($g_hPicBBWallUpgrade, $GUI_SHOW)
		GUICtrlSetState($g_hTxtBBWallNumber, $GUI_SHOW)
		GUICtrlSetState($g_hLblBBWallNumberInfo, $GUI_SHOW)
	Else
		$g_bChkBBUpgradeWalls = False
		GUICtrlSetState($g_hLblBBWallLevelInfo, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbBBWallLevel, $GUI_DISABLE)
		GUICtrlSetState($g_hLblBBWallCostInfo, $GUI_DISABLE)
		GUICtrlSetState($g_hLblBBWallCost, $GUI_DISABLE)
		GUICtrlSetState($g_hPicBBWallUpgrade, $GUI_HIDE)
		GUICtrlSetState($g_hTxtBBWallNumber, $GUI_HIDE)
		GUICtrlSetState($g_hLblBBWallNumberInfo, $GUI_HIDE)
	EndIf
EndFunc ;==>ChkBBWalls

Func cmbBBWall()
	$g_iCmbBBWallLevel = _GUICtrlComboBox_GetCurSel($g_hCmbBBWallLevel)
	; Wall search level, 0 is not a level , this is the selected level to upgrade
	GUICtrlSetData($g_hLblBBWallCost, _NumberFormat($g_aiWallBBInfoPerLevel[$g_iCmbBBWallLevel + 2][1]))
	_GUICtrlSetImage($g_hPicBBWallUpgrade, $g_sLibBBIconPath, $g_iCmbBBWallLevel + 19)
EndFunc   ;==>cmbBBWall

Func btnBBAtkLogClear()
	_GUICtrlRichEdit_SetText($g_hTxtBBAtkLog, "")
	BBAtkLogHead()
EndFunc   ;==>btnBBAtkLogClear

Func checkIfBBLogIsEmptyInitialize()
	;TODO:As this logic is not working when Switching from mini to normal
	;If StringLen(_GUICtrlRichEdit_GetText($g_hTxtBBAtkLog)) = 0 Then BBAtkLogHead()
EndFunc   ;==>checkIfBBLogIsEmptyInitialize

Func btnBBAtkLogCopyClipboard()
	Local $text = _GUICtrlRichEdit_GetText($g_hTxtBBAtkLog)
	$text = StringReplace($text, @CR, @CRLF)
	ClipPut($text)
EndFunc   ;==>btnBBAtkLogCopyClipboard

Func chkStartClockTowerBoost()
	If GUICtrlRead($g_hChkStartClockTowerBoost) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkCTBoostBlderBz, $GUI_ENABLE)
		GUICtrlSetState($g_hChkCTBoostAtkAvailable, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkCTBoostBlderBz, $GUI_DISABLE)
		GUICtrlSetState($g_hChkCTBoostAtkAvailable, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkStartClockTowerBoost

Func chkCTBoostBlderBz()
	If GUICtrlRead($g_hChkCTBoostBlderBz) = $GUI_CHECKED Then
		_GUI_Value_STATE("UNCHECKED", $g_hChkCTBoostAtkAvailable)
	EndIf
EndFunc   ;==>chkCTBoostBlderBz

Func chkCTBoostAtkAvailable()
	If GUICtrlRead($g_hChkCTBoostAtkAvailable) = $GUI_CHECKED Then
		_GUI_Value_STATE("UNCHECKED", $g_hChkCTBoostBlderBz)
	EndIf
EndFunc   ;==>chkCTBoostAtkAvailable

Func chkDebugBBattack()
	If GUICtrlRead($g_hDebugBBattack) = $GUI_CHECKED Then
		$g_bDebugBBattack = True
	Else
		$g_bDebugBBattack = False
	EndIf
EndFunc   ;==>chkDebugBBattack

Func chkBuilderAttack()
	If BitAND(GUICtrlGetState($g_hGUI_BUILDER_BASE), $GUI_SHOW) And GUICtrlRead($g_hGUI_BUILDER_BASE_TAB) = 2 Then ; fix flickring
		If GUICtrlRead($g_hChkBuilderAttack) = $GUI_CHECKED Then
			$g_bChkBuilderAttack = True
			GUISetState(@SW_SHOWNOACTIVATE, $g_hGUI_ATTACK_PLAN_BUILDER_BASE)
			GUISetState(@SW_SHOWNOACTIVATE, $g_hGUI_ATTACK_PLAN_BUILDER_BASE_CSV)
			GUICtrlSetState($g_hLblBuilderAttackDisabled, $GUI_HIDE)
		Else
			$g_bChkBuilderAttack = False
			GUISetState(@SW_HIDE, $g_hGUI_ATTACK_PLAN_BUILDER_BASE)
			GUISetState(@SW_HIDE, $g_hGUI_ATTACK_PLAN_BUILDER_BASE_CSV)
			GUICtrlSetState($g_hLblBuilderAttackDisabled, $GUI_SHOW)
		EndIf
	EndIf
EndFunc   ;==>chkBuilderAttack

Func chkBBtrophiesRange()
	If GUICtrlRead($g_hChkBBTrophiesRange) = $GUI_CHECKED Then
		GUICtrlSetState($g_hTxtBBDropTrophiesMin, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtBBDropTrophiesMax, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hTxtBBDropTrophiesMin, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtBBDropTrophiesMax, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkBBtrophiesRange

Func chkBBArmyCamp()
	Local $combo1 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy1) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy1)
	Local $combo2 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy2) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy2)
	Local $combo3 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy3) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy3)
	Local $combo4 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy4) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy4)
	Local $combo5 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy5) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy5)
	Local $combo6 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy6) = 0 ? 11 : _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy6)
	_GUICtrlSetImage($g_hIcnBBarmy1, $g_sLibBBIconPath, $combo1)
	_GUICtrlSetImage($g_hIcnBBarmy2, $g_sLibBBIconPath, $combo2)
	_GUICtrlSetImage($g_hIcnBBarmy3, $g_sLibBBIconPath, $combo3)
	_GUICtrlSetImage($g_hIcnBBarmy4, $g_sLibBBIconPath, $combo4)
	_GUICtrlSetImage($g_hIcnBBarmy5, $g_sLibBBIconPath, $combo5)
	_GUICtrlSetImage($g_hIcnBBarmy6, $g_sLibBBIconPath, $combo6)
	$g_iCmbBBArmy1 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy1)
	$g_iCmbBBArmy2 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy2)
	$g_iCmbBBArmy3 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy3)
	$g_iCmbBBArmy4 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy4)
	$g_iCmbBBArmy5 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy5)
	$g_iCmbBBArmy6 = _GUICtrlComboBox_GetCurSel($g_hCmbBBArmy6)
EndFunc   ;==>chkBBArmyCamp

Func chkBBStyle()
	For $i = 0 To 2
		Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
		Local $scriptname
		_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
		$g_sAttackScrScriptNameBB[$i] = $scriptname
		SetDebugLog($g_sAttackScrScriptNameBB[$i] & " Loaded to use on BB attack!")
	Next
	cmbScriptNameBB()
EndFunc   ;==>chkBBStyle

Func PopulateComboScriptsFilesBB($spacficIndex = "-999") ;Define Impoisble Default Index
	Dim $FileSearch, $NewFile
	$FileSearch = FileFindFirstFile($g_sCSVBBAttacksPath & "\*.csv")
	Dim $output = ""
	While True
		$NewFile = FileFindNextFile($FileSearch)
		If @error Then ExitLoop
		$output = $output & StringLeft($NewFile, StringLen($NewFile) - 4) & "|"
	WEnd
	FileClose($FileSearch)
	;remove last |
	$output = StringLeft($output, StringLen($output) - 1)
	If $spacficIndex = "-999" Then
		;set 3 combo boxes
		For $i = 0 To 2
			;reset combo box
			_GUICtrlComboBox_ResetContent($g_hCmbBBAttackStyle[$i])
			GUICtrlSetData($g_hCmbBBAttackStyle[$i], $output)
			_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], ""))
			GUICtrlSetData($g_hLblNotesScriptBB[$i], "")
		Next
	Else
		;reset combo box For Spacfic Index We Need This Logic For Reload Button
		_GUICtrlComboBox_ResetContent($g_hCmbBBAttackStyle[$spacficIndex])
		GUICtrlSetData($g_hCmbBBAttackStyle[$spacficIndex], $output)
		_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$spacficIndex], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$spacficIndex], ""))
		GUICtrlSetData($g_hLblNotesScriptBB[$spacficIndex], "")
	EndIf
EndFunc   ;==>PopulateComboScriptsFilesBB

Func cmbScriptNameBB()
	For $i = 0 To 2
		Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbBBAttackStyle[$i])
		Local $filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i]) + 1]
		Local $f, $result = ""
		Local $tempvect, $line, $t

		If FileExists($g_sCSVBBAttacksPath & "\" & $filename & ".csv") Then
			$f = FileOpen($g_sCSVBBAttacksPath & "\" & $filename & ".csv", 0)
			; Read in lines of text until the EOF is reached
			While 1
				$line = FileReadLine($f)
				If @error = -1 Then ExitLoop
				$tempvect = StringSplit($line, "|", 2)
				If UBound($tempvect) >= 2 Then
					If StringStripWS(StringUpper($tempvect[0]), 2) = "NOTE" Then $result &= $tempvect[1] & @CRLF
				EndIf
			WEnd
			FileClose($f)
		EndIf
		GUICtrlSetData($g_hLblNotesScriptBB[$i], $result)
	Next
EndFunc   ;==>cmbScriptNameBB

Func UpdateComboScriptNameBB()
	For $i = 0 To 2
		Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[$i])
		Local $scriptname
		_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[$i], $indexofscript, $scriptname)
		PopulateComboScriptsFilesBB($i)
		_GUICtrlComboBox_SetCurSel($g_hCmbBBAttackStyle[$i], _GUICtrlComboBox_FindStringExact($g_hCmbBBAttackStyle[$i], $scriptname))
	Next
	cmbScriptNameBB()
EndFunc   ;==>UpdateComboScriptNameBB

Func EditScriptBB()
	Local $tempvect1 = _GUICtrlComboBox_GetListArray($g_hCmbBBAttackStyle[0])
	Local $filename = $tempvect1[_GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[0]) + 1]
	Local $f, $result = ""
	Local $tempvect, $line, $t
	If FileExists($g_sCSVBBAttacksPath & "\" & $filename & ".csv") Then
		ShellExecute("notepad.exe", $g_sCSVBBAttacksPath & "\" & $filename & ".csv")
	EndIf
EndFunc   ;==>EditScriptBB

Func NewScriptBB()
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Create", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_0", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileOpen($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv", $FO_APPEND)
			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptNameBB[0] = $filenameScript
				UpdateComboScriptNameBB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>NewScriptBB

Func DuplicateScriptBB()
	Local $indexofscript = _GUICtrlComboBox_GetCurSel($g_hCmbBBAttackStyle[0])
	Local $scriptname
	_GUICtrlComboBox_GetLBText($g_hCmbBBAttackStyle[0], $indexofscript, $scriptname)
	$g_sAttackScrScriptNameBB[0] = $scriptname
	Local $filenameScript = InputBox(GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_0", -1), GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Copy_1", -1) & ": <" & $g_sAttackScrScriptNameBB[0] & ">" & @CRLF & GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_New_1", -1) & ":")
	If StringLen($filenameScript) > 0 Then
		If FileExists($g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv") Then
			MsgBox("", "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_File-exists", -1))
		Else
			Local $hFileOpen = FileCopy($g_sCSVBBAttacksPath & "\" & $g_sAttackScrScriptNameBB[0] & ".csv", $g_sCSVBBAttacksPath & "\" & $filenameScript & ".csv")

			If $hFileOpen = -1 Then
				MsgBox($MB_SYSTEMMODAL, "", GetTranslatedFileIni("MBR Popups", "Func_AttackCSVAssignDefaultScriptName_Error", -1))
				Return False
			Else
				FileClose($hFileOpen)
				$g_sAttackScrScriptNameBB[0] = $filenameScript
				UpdateComboScriptNameBB()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>DuplicateScriptBB

Func ChkBBRandomAttack()
	If GUICtrlRead($g_hChkBBRandomAttack) = $GUI_CHECKED Then
		GUICtrlSetState($g_hCmbBBAttackStyle[1], $GUI_SHOW)
		GUICtrlSetState($g_hCmbBBAttackStyle[2], $GUI_SHOW)
		GUICtrlSetState($g_hLblNotesScriptBB[1], $GUI_SHOW)
		GUICtrlSetState($g_hLblNotesScriptBB[2], $GUI_SHOW)
		GUICtrlSetState($g_hGrpGuideScriptBB[1], $GUI_SHOW)
		GUICtrlSetState($g_hGrpGuideScriptBB[2], $GUI_SHOW)

		GUICtrlSetPos($g_hGrpOptionsBB, -1, -1, $g_iSizeWGrpTab2 - 2, 45)
		GUICtrlSetPos($g_hChkBBTrophiesRange, 100, 105)
		GUICtrlSetPos($g_hTxtBBDropTrophiesMin, 203, 105)
		GUICtrlSetPos($g_hLblBBDropTrophiesDash, 245, 105 + 2)
		GUICtrlSetPos($g_hTxtBBDropTrophiesMax, 250, 105)
		GUICtrlSetPos($g_hChkBBRandomAttack, 300, 105)

		WinMove($g_hGUI_ATTACK_PLAN_BUILDER_BASE_CSV, "", 0, 140, $g_iSizeWGrpTab2 - 2)
		GUICtrlSetPos($g_hGrpAttackStyleBB, -1, -1, $g_iSizeWGrpTab2 - 12, $g_iSizeHGrpTab4 - 90)
		GUICtrlSetState($g_hGrpGuideScriptBB[0], $GUI_SHOW)
		GUICtrlSetPos($g_hCmbBBAttackStyle[0], -1, 35, 130)
		GUICtrlSetPos($g_hLblNotesScriptBB[0], -1, 60, 130, 180)
		For $i = 0 To UBound($g_hIcnBBCSV) - 1
			GUICtrlSetPos($g_hIcnBBCSV[$i], 416)
		Next
		$g_bChkBBRandomAttack = True
	Else
		GUICtrlSetState($g_hCmbBBAttackStyle[1], $GUI_HIDE)
		GUICtrlSetState($g_hCmbBBAttackStyle[2], $GUI_HIDE)
		GUICtrlSetState($g_hLblNotesScriptBB[1], $GUI_HIDE)
		GUICtrlSetState($g_hLblNotesScriptBB[2], $GUI_HIDE)
		GUICtrlSetState($g_hGrpGuideScriptBB[1], $GUI_HIDE)
		GUICtrlSetState($g_hGrpGuideScriptBB[2], $GUI_HIDE)


		GUICtrlSetPos($g_hGrpOptionsBB, -1, -1, 200, 90)
		GUICtrlSetPos($g_hChkBBTrophiesRange, 5, 125)
		GUICtrlSetPos($g_hTxtBBDropTrophiesMin, 108, 126)
		GUICtrlSetPos($g_hLblBBDropTrophiesDash, 150, 126 + 2)
		GUICtrlSetPos($g_hTxtBBDropTrophiesMax, 155, 126)
		GUICtrlSetPos($g_hChkBBRandomAttack, 5, 145)

		WinMove($g_hGUI_ATTACK_PLAN_BUILDER_BASE_CSV, "", 200, 85, 240)
		GUICtrlSetPos($g_hGrpAttackStyleBB, -1, -1, 233, $g_iSizeHGrpTab4 - 35)
		GUICtrlSetState($g_hGrpGuideScriptBB[0], $GUI_HIDE)
		GUICtrlSetPos($g_hCmbBBAttackStyle[0], -1, 25, 195)
		GUICtrlSetPos($g_hLblNotesScriptBB[0], -1, 50, 195, 160)
		For $i = 0 To UBound($g_hIcnBBCSV) - 1
			GUICtrlSetPos($g_hIcnBBCSV[$i], 215)
		Next
		$g_bChkBBRandomAttack = False
	EndIf

EndFunc   ;==>ChkBBRandomAttack

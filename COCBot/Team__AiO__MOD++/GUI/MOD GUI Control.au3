; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Control
; Description ...: This file controls the "MOD" tab
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
#include "MOD GUI Control - Switch-Options.au3"
#include "MOD GUI Control - Daily-Discounts.au3"
#include "MOD GUI Control - SuperXP.au3"
#include "MOD GUI Control - Humanization.au3"
#include "MOD GUI Control - ChatActions.au3"
#include "MOD GUI Control - GTFO.au3"
#include "MOD GUI Control - AiO-Debug.au3"
#include "MOD GUI Control - MagicItems.au3"
#include "BBase\MOD GUI Control Tab - Builder Base.au3"

#Region - Setlog limit - Team AIO Mod++
Func LimitLines(ByRef $hRichText, $sDelimiter = @CR, $iMaxLength = 200) ;$iMaxLength
    Local $asText
    Local $iFirstLineLen
    Local $iMax
    Local $i
    $asText = StringSplit(_GUICtrlRichEdit_GetText($hRichText), $sDelimiter, 2)
    If UBound($asText) > ($iMaxLength + 1) Then ; $iMaxLength + 1 cause of 1 empty @CR on last text log
        $iMax = UBound($asText) - ($iMaxLength + 1)
        ;_SendMessage($hRichText, $WM_SETREDRAW, False, 0) ; disable redraw so logging has no visiual effect
        For $i = 1 To $iMax
            $iFirstLineLen = StringInStr(_GUICtrlRichEdit_GetText($hRichText), $sDelimiter)
            _GUICtrlRichEdit_SetSel($hRichText, 0, $iFirstLineLen)
            _GUICtrlRichEdit_ReplaceText($hRichText, "")
        Next
    EndIf
EndFunc

Func chkBotLogLineLimit()
	$g_bChkBotLogLineLimit = (GUICtrlRead($g_hChkBotLogLineLimit) = ($GUI_CHECKED) ? (True) : (False))
	GUICtrlSetState($g_hTxtLogLineLimit, ($g_bChkBotLogLineLimit) ? ($GUI_ENABLE) : ($GUI_DISABLE))
EndFunc   ;==>chkBotLogLineLimit

Func txtLogLineLimit()
	$g_iTxtLogLineLimit = GUICtrlRead($g_hTxtLogLineLimit)
EndFunc   ;==>txtLogLineLimit
#EndRegion - Setlog limit - Team AIO Mod++

; Donation records.
Func InputRecords()
		$g_iDiffRestartEvery = $g_iCmbRestartEvery
		$g_iDayLimitTroops = (GUICtrlRead($g_hDayLimitTroops))
		$g_iDayLimitSpells = (GUICtrlRead($g_hDayLimitSpells))
		$g_iDayLimitSieges = (GUICtrlRead($g_hDayLimitSieges))
		$g_iCmbRestartEvery = (GUICtrlRead($g_hCmbRestartEvery))
		If $g_iDiffRestartEvery <> $g_iCmbRestartEvery Then TimerRecordDonation(True)
EndFunc   ;==>ChkReqCCAlways

; Request form chat / on a loop - Team AiO MOD++
Func ChkReqCCAlways()
		$g_bChkReqCCAlways = (GUICtrlRead($g_hChkReqCCAlways) = $GUI_CHECKED)
EndFunc   ;==>ChkReqCCAlways

Func ChkReqCCFromChat()
		$g_bChkReqCCFromChat = (GUICtrlRead($g_hChkReqCCFromChat) = $GUI_CHECKED)
EndFunc   ;==>ChkReqCCFromChat

; Drop trophy - Team AiO MOD++
Func chkNoDropIfShield()
		$g_bChkNoDropIfShield = (GUICtrlRead($g_hChkNoDropIfShield) = $GUI_CHECKED)
EndFunc   ;==>chkNoDropIfShield

; Misc tab - Team AiO MOD++
Func chkEdgeObstacle()
	$g_bChkCleanYard = (GUICtrlRead($g_hChkCleanYard) = $GUI_CHECKED)
	$g_bEdgeObstacle = (GUICtrlRead($g_hEdgeObstacle) = $GUI_CHECKED)
	
	If $g_bChkCleanYard Then
		GUICtrlSetState($g_hEdgeObstacle, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hEdgeObstacle, $GUI_DISABLE + $GUI_UNCHECKED)
	EndIf

EndFunc

; Misc tab - Team AiO MOD++
Func chkDelayMod()
	; Skip first loop
	$g_bAvoidLocate = (GUICtrlRead($g_hAvoidLocate) = $GUI_CHECKED)

	For $i = 0 To UBound($g_hDeployWave) -1
		$g_bChkEnableRandom[$i] = (GUICtrlRead($g_hChkEnableRandom[$i]) = $GUI_CHECKED)

		GUICtrlSetState($g_hDeployWave[$i], ($g_bChkEnableRandom[$i]) ? ($GUI_ENABLE) : ($GUI_DISABLE))
		GUICtrlSetState($g_hDeployDelay[$i], ($g_bChkEnableRandom[$i]) ? ($GUI_ENABLE) : ($GUI_DISABLE))

		; Deploy wave
		$g_iDeployWave[$i] = Int(GUICtrlRead($g_hDeployWave[$i]))
		GUICtrlSetData($g_hDeployWave[$i], $g_iDeployWave[$i])

		; Deploy delay
		$g_iDeployDelay[$i] = Int(GUICtrlRead($g_hDeployDelay[$i]))
		GUICtrlSetData($g_hDeployDelay[$i], $g_iDeployDelay[$i])
	Next

	GUICtrlSetState($g_hDisableColorLog, $GUI_DISABLE)
	$g_bUseSleep = (GUICtrlRead($g_hUseSleep) = $GUI_CHECKED)
	$g_bUseRandomSleep = (GUICtrlRead($g_hUseRandomSleep) = $GUI_CHECKED)
	$g_bNoAttackSleep = (GUICtrlRead($g_hNoAttackSleep) = $GUI_CHECKED)
	$g_bDisableColorLog = (GUICtrlRead($g_hDisableColorLog) = $GUI_CHECKED)
	$g_bAvoidLocation = (GUICtrlRead($g_hAvoidLocation) = $GUI_CHECKED)

	$g_bDeployCastleFirst[$DB] = (GUICtrlRead($g_hDeployCastleFirst[$DB]) = $GUI_CHECKED)
	$g_bDeployCastleFirst[$LB] = (GUICtrlRead($g_hDeployCastleFirst[$LB]) = $GUI_CHECKED)

	$g_iIntSleep = Int(GUICtrlRead($g_hIntSleep))
	GUICtrlSetData($g_hDelayLabel, $g_iIntSleep)

	If $g_iIntSleep < -25 Then
		GUICtrlSetColor($g_hDelayLabel, $COLOR_RED)
	ElseIf $g_iIntSleep > 0 Then
		GUICtrlSetColor($g_hDelayLabel, $COLOR_GREEN)
	Else
		GUICtrlSetColor($g_hDelayLabel, -1)
	EndIf

	If $g_bUseSleep Then
		GUICtrlSetState($g_hIntSleep, $GUI_ENABLE)
		GUICtrlSetState($g_hUseRandomSleep, $GUI_ENABLE)
		GUICtrlSetState($g_hNoAttackSleep, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hIntSleep, $GUI_DISABLE)
		GUICtrlSetState($g_hUseRandomSleep, $GUI_DISABLE)
		GUICtrlSetState($g_hNoAttackSleep, $GUI_DISABLE)
	EndIf

EndFunc   ;==>chkDelayMod

Func chkMaxSidesSF()
	; Max Sides
	$g_iCmbMaxSidesSF = Int(GUICtrlRead($g_hCmbMaxSidesSF))
	$g_bMaxSidesSF = (GUICtrlRead($g_hMaxSidesSF) = $GUI_CHECKED)

	If $g_bMaxSidesSF Then
		GUICtrlSetState($g_hCmbMaxSidesSF, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hCmbMaxSidesSF, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkMaxSidesSF

; Classic Four Finger - Team AiO MOD++
Func cmbStandardDropSidesAB() ; avoid conflict between FourFinger and SmartAttack
	If _GUICtrlComboBox_GetCurSel($g_hCmbStandardDropSidesAB) = 4 Then
		GUICtrlSetState($g_hChkSmartAttackRedAreaAB, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	Else
		GUICtrlSetState($g_hChkSmartAttackRedAreaAB, $GUI_ENABLE)
	EndIf
	chkSmartAttackRedAreaAB()
EndFunc   ;==>g_hCmbStandardDropSidesAB

Func cmbStandardDropSidesDB() ; avoid conflict between FourFinger and SmartAttack
	If _GUICtrlComboBox_GetCurSel($g_hCmbStandardDropSidesDB) = 4 Then
		GUICtrlSetState($g_hChkSmartAttackRedAreaDB, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	Else
		GUICtrlSetState($g_hChkSmartAttackRedAreaDB, $GUI_ENABLE)
	EndIf
	chkSmartAttackRedAreaDB()
EndFunc   ;==>g_hCmbStandardDropSidesDB

; Check Collectors Outside
Func chkCollectorsAndRedLines()
	Select
		Case @GUI_CtrlId = $g_hChkDBCollectorNone
			_GUI_Value_STATE("DISABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hTxtDBMinCollectorOutsidePercent & "#" & $g_hCmbRedlineTiles)
		Case @GUI_CtrlId = $g_hChkDBCollectorNearRedline
			_GUI_Value_STATE("ENABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hCmbRedlineTiles)
			_GUI_Value_STATE("DISABLE", $g_hTxtDBMinCollectorOutsidePercent)
		Case @GUI_CtrlId = $g_hChkDBMeetCollectorOutside
			_GUI_Value_STATE("ENABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hTxtDBMinCollectorOutsidePercent)
			_GUI_Value_STATE("DISABLE", $g_hCmbRedlineTiles)
	EndSelect
	chkSkipCollectorCheck()
	chkSkipCollectorCheckTH()
EndFunc   ;==>chkCollectorsAndRedLines

Func aplCollectorsAndRedLines()
	Select
		Case $g_bDBCollectorNone
			_GUI_Value_STATE("DISABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hTxtDBMinCollectorOutsidePercent & "#" & $g_hCmbRedlineTiles)
		Case $g_bDBCollectorNearRedline
			_GUI_Value_STATE("ENABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hCmbRedlineTiles)
			_GUI_Value_STATE("DISABLE", $g_hTxtDBMinCollectorOutsidePercent)
		Case $g_bDBMeetCollectorOutside
			_GUI_Value_STATE("ENABLE", $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH & "#" & $g_hTxtDBMinCollectorOutsidePercent)
			_GUI_Value_STATE("DISABLE", $g_hCmbRedlineTiles)
	EndSelect
	chkSkipCollectorCheck()
	chkSkipCollectorCheckTH()
EndFunc   ;==>aplCollectorsAndRedLines

Func chkSkipCollectorCheck() ; Not put in cfg.
	If GUICtrlRead($g_hChkSkipCollectorCheck) = $GUI_CHECKED Then
		For $i = $g_hLblSkipCollectorCheck To $g_hTxtSkipCollectorDark
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		For $i = $g_hLblSkipCollectorCheck To $g_hTxtSkipCollectorDark
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkSkipCollectorCheck

Func chkSkipCollectorCheckTH() ; Not put in cfg.
	If GUICtrlRead($g_hChkSkipCollectorCheckTH) = $GUI_CHECKED Then
		For $i = $g_hLblSkipCollectorCheckTH To $g_hCmbSkipCollectorCheckTH
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		For $i = $g_hLblSkipCollectorCheckTH To $g_hCmbSkipCollectorCheckTH
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkSkipCollectorCheckTH

; Auto Dock, Hide Emulator & Bot - Team AiO MOD++
Func chkEnableAuto()
	If GUICtrlRead($g_hChkEnableAuto) = $GUI_CHECKED Then
		$g_bEnableAuto = True
		_GUI_Value_STATE("ENABLE", $g_hChkAutoDock & "#" & $g_hChkAutoHideEmulator)
	Else
		$g_bEnableAuto = False
		_GUI_Value_STATE("DISABLE", $g_hChkAutoDock & "#" & $g_hChkAutoHideEmulator)
	EndIf
EndFunc   ;==>chkEnableAuto

Func btnEnableAuto()
	If $g_bEnableAuto = True Then
		If GUICtrlRead($g_hChkAutoDock) = $GUI_CHECKED Then
			$g_bChkAutoDock = True
			$g_bChkAutoHideEmulator = False
		ElseIf GUICtrlRead($g_hChkAutoHideEmulator) = $GUI_CHECKED Then
			$g_bChkAutoDock = False
			$g_bChkAutoHideEmulator = True
		EndIf
	Else
		$g_bChkAutoDock = False
		$g_bChkAutoHideEmulator = False
	EndIf
EndFunc   ;==>btnEnableAuto

; Max logout time - Team AiO MOD++
Func chkTrainLogoutMaxTime()
	If GUICtrlRead($g_hChkTrainLogoutMaxTime) = $GUI_CHECKED Then
		_GUI_Value_STATE("ENABLE", $g_hTxtTrainLogoutMaxTime & "#" & $g_hLblTrainLogoutMaxTime)
	Else
		_GUI_Value_STATE("DISABLE", $g_hTxtTrainLogoutMaxTime & "#" & $g_hLblTrainLogoutMaxTime)
	EndIf
EndFunc   ;==>chkTrainLogoutMaxTime

; Only farm - Team AiO MOD++
Func chkOnlyFarm()
	If IsDeclared("g_hChkOnlyFarm") Then
		UpdateChkOnlyFarm()
	EndIf
EndFunc   ;==>chkOnlyFarm

Func UpdateChkOnlyFarm()
    $g_bChkOnlyFarm = (GUICtrlRead($g_hChkOnlyFarm) = $GUI_CHECKED)
EndFunc   ;==>UpdateChkOnlyFarm

; Check No League for Dead Base - Team AiO MOD++
Func chkDBNoLeague()
	$g_bChkNoLeague[$DB] = (GUICtrlRead($g_hChkDBNoLeague) = $GUI_CHECKED)
EndFunc   ;==>chkDBNoLeague

; Lab Priority System 
func chkPriorityResourceLab()
	$g_bChkPriorityLab = (GUICtrlRead($g_hChkPriorityLab) = $GUI_CHECKED)
	GUICtrlSetState($g_hCmbPriorityLab, ($g_bChkPriorityLab) ? ($GUI_ENABLE) : ($GUI_DISABLE))
EndFunc   ;==>chkPriorityResourceLab

func cmbPriorityResourceLab()
	; Hahaha I wonder how "_ GUICtrlComboBox_GetCurSel ($ g_hCm Priority System) ... Case "Elixir" " worked this if it returns the index.
	$g_iCmbPriorityLab = _GUICtrlComboBox_GetCurSel($g_hCmbPriorityLab)
EndFunc   ;==>cmbPriorityResourceLab

Func chkLabPriority()
	If _GUICtrlComboBox_GetCurSel($g_hCmbLaboratory) = 0 And (GUICtrlRead($g_hChkAutoLabUpgrades) = $GUI_CHECKED) Then
		GUICtrlSetState($g_hChkPriorityLab, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbPriorityLab, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkPriorityLab, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbPriorityLab, $GUI_DISABLE)
	EndIf
	chkPriorityResourceLab()
EndFunc   ;==>chkLabPriority

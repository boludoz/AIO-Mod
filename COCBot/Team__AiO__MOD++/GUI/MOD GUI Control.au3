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

#Region - Custom SmartFarm - Team AIO Mod++
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

Func chkUseSmartFarmAndRandomDeploy()
	If $g_iGuiMode <> 1 Then Return
	If GUICtrlRead($g_hChkSmartFarmAndRandomDeploy) = $GUI_CHECKED And $g_abAttackTypeEnable[$DB] And $g_aiAttackAlgorithm[$DB] = 2 And Not $g_abAttackTypeEnable[$LB] Then
		$g_bUseSmartFarmAndRandomDeploy = True
	Else
		GUICtrlSetState($g_hChkSmartFarmAndRandomDeploy, $GUI_UNCHECKED)
		$g_bUseSmartFarmAndRandomDeploy = False
	EndIf
EndFunc   ;==>chkUseSmartFarmAndRandomDeploy

Func chkUseSmartFarmAndRandomQuant()
	If $g_iGuiMode <> 1 Then Return
	If GUICtrlRead($g_hChkSmartFarmAndRandomQuant) = $GUI_CHECKED And $g_abAttackTypeEnable[$DB] And $g_aiAttackAlgorithm[$DB] = 2 And Not $g_abAttackTypeEnable[$LB] Then
		$g_bUseSmartFarmAndRandomQuant = True
	Else
		GUICtrlSetState($g_hChkSmartFarmAndRandomQuant, $GUI_UNCHECKED)
		$g_bUseSmartFarmAndRandomQuant = False
	EndIf
EndFunc   ;==>chkUseSmartFarmAndRandomQuant

Func ChkSmartFarmSpellsEnable()
	If $g_iGuiMode <> 1 Then Return
	If GUICtrlRead($g_hSmartFarmSpellsEnable) = $GUI_CHECKED And $g_abAttackTypeEnable[$DB] And $g_aiAttackAlgorithm[$DB] = 2 And Not $g_abAttackTypeEnable[$LB] Then
		$g_bSmartFarmSpellsEnable = True
		GUICtrlSetState($g_hCmbSmartFarmSpellsHowManySides, $GUI_ENABLE)
	Else
		$g_bSmartFarmSpellsEnable = False
		GUICtrlSetState($g_hCmbSmartFarmSpellsHowManySides, $GUI_DISABLE)
	EndIf
EndFunc   ;==>ChkSmartFarmSpellsEnable

Func cmbHowManySidesSpells()
	If $g_iGuiMode <> 1 Then Return
	$g_iSmartFarmSpellsHowManySides = _GUICtrlComboBox_GetCurSel($g_hCmbSmartFarmSpellsHowManySides) + 1
EndFunc   ;==>cmbHowManySidesSpells

Func CheckUseSmartFarmRedLine()
	If $g_iGuiMode <> 1 Then Return
	$g_bUseSmartFarmRedLine = (GUICtrlRead($g_hChkUseSmartFarmRedLine) = $GUI_CHECKED)
EndFunc   ;==>CheckUseSmartFarmRedLine
#EndRegion - Custom SmartFarm - Team AIO Mod++

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
	$g_bChkNoLeague[$DB] = GUICtrlRead($g_hChkDBNoLeague) = $GUI_CHECKED
EndFunc   ;==>chkDBNoLeague

func cmbPriorityResourceLab()
	; Hahaha I wonder how "_ GUICtrlComboBox_GetCurSel ($ g_hCm Priority System) ... Case "Elixir" " worked this if it returns the index.
	$g_iCmbPriorityLab = _GUICtrlComboBox_GetCurSel($g_hCmbPriorityLab)
EndFunc   ;==>cmbPriorityResourceLab

Func chkLabPriority()
	Local $hMode = ($g_iCmbLaboratory = 0 And $g_bAutoLabUpgradeEnable = True) ? ($GUI_ENABLE) : ($GUI_DISABLE)
	For $h = $g_hChkPriorityLab To $g_hChkPriorityLabSieges
		GUICtrlSetState($h, $hMode)
	Next
	chkPriorityResourceLab()
EndFunc   ;==>chkLabPriority

; Lab Priority System 
func chkPriorityResourceLab()
	$g_bPriorityLab = (GUICtrlRead($g_hChkPriorityLab) = $GUI_CHECKED)
	GUICtrlSetState($g_hCmbPriorityLab, ($g_bPriorityLab = True And $g_bAutoLabUpgradeEnable = True And $g_iCmbLaboratory = 0) ? ($GUI_ENABLE) : ($GUI_DISABLE))
EndFunc   ;==>chkPriorityResourceLab

#Region - Return Home by Time - Team AIO Mod++
Func chkReturnTimer()
	GUICtrlSetState($g_hTxtReturnTimer, GUICtrlRead($g_hChkReturnTimerEnable) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>chkReturnTimer
#EndRegion - Return Home by Time - Team AIO Mod++

#Region - Legend trophy protection - Team AIO Mod++
Func ChkProtectInLL()
	$g_bProtectInLL = (GUICtrlRead($g_hChkProtectInLL) = $GUI_CHECKED)
	GUICtrlSetState($g_hChkForceProtectLL, ($g_bProtectInLL = True) ? ($GUI_ENABLE) : ($GUI_DISABLE))
	$g_bForceProtectLL = (GUICtrlRead($g_hChkForceProtectLL) = $GUI_CHECKED)
EndFunc   ;==>ChkProtectInLL
#EndRegion - Legend trophy protection - Team AIO Mod++

#Region - No Upgrade In War - Team AIO Mod++
Func ChkNoUpgradeInWar()
	$g_bNoUpgradeInWar = (GUICtrlRead($g_hChkNoUpgradeInWar) = $GUI_CHECKED)
EndFunc   ;==>ChkNoUpgradeInWar
#EndRegion - No Upgrade In War - Team AIO Mod++

#Region - No Upgrade In War - Team AIO Mod++

Func chkNewDBSys()
	$g_bCollectorFilterDisable = (GUICtrlRead($g_hChkDBDisableCollectorsFilter) = $GUI_CHECKED)
	$g_bDefensesAlive = (GUICtrlRead($g_hChkDBCheckDefensesAlive) = $GUI_CHECKED)
	$g_bDefensesMix = (GUICtrlRead($g_hChkDBCheckDefensesMix) = $GUI_CHECKED)
	
	Local $bDisable = False, $bDisableOther = False
	Select
		Case $g_bCollectorFilterDisable And Not $g_bDefensesMix And Not $g_bDefensesAlive
			$bDisable = True
		; Case $g_bDefensesAlive And Not $g_bDefensesMix And Not $g_bCollectorFilterDisable
		Case $g_bDefensesMix And Not $g_bDefensesAlive And Not $g_bCollectorFilterDisable
			$bDisableOther = True
		Case $g_bCollectorFilterDisable And $g_bDefensesAlive And Not $g_bDefensesMix
			$bDisable = True
		Case $g_bDefensesAlive And $g_bDefensesMix And Not $g_bCollectorFilterDisable
			$bDisableOther = True
		Case $g_bDefensesMix And $g_bCollectorFilterDisable And Not $g_bDefensesAlive
			$bDisableOther = True
		Case $g_bCollectorFilterDisable And $g_bDefensesAlive And $g_bDefensesMix
			$bDisableOther = True
			$bDisable = False
	EndSelect
	
	GUICtrlSetState($g_hChkDBDisableCollectorsFilter, ($bDisableOther = True) ? ($GUI_DISABLE) : ($GUI_ENABLE))
	GUICtrlSetState($g_hChkDBCheckDefensesAlive, ($bDisableOther = True) ? ($GUI_DISABLE) : ($GUI_ENABLE))

	For $i = 7 To UBound($g_aiCollectorLevelFill) -1
		GUICtrlSetState($g_ahCmbDBCollectorLevel[$i], ($bDisable = True) ? ($GUI_DISABLE) : ($GUI_ENABLE))
		GUICtrlSetState($g_ahChkDBCollectorLevel[$i], ($bDisable = True) ? ($GUI_DISABLE) : ($GUI_ENABLE))
	Next
	GUICtrlSetState($g_hCmbMinCollectorMatches, ($bDisable = True) ? ($GUI_DISABLE) : ($GUI_ENABLE))

EndFunc   ;==>chkNewDBSys
#EndRegion - No Upgrade In War - Team AIO Mod++

#Region - SmartMilk
Func CmbMilkStrategyArmy()
	$g_iMilkStrategyArmy = _GUICtrlComboBox_GetCurSel($g_hCmbMilkStrategyArmy)
	_GUICtrlSetImage($g_ahPicMilk, $g_sLibIconPath, $g_hIcnMilk[$g_iMilkStrategyArmy])
EndFunc   ;==>CmbMilkStrategyArmy

Func MilkForceDeployHeroes()
	$g_bChkMilkForceDeployHeroes = (GUICtrlRead($g_hChkMilkForceDeployHeroes) = $GUI_CHECKED)
	$g_bChkMilkForceAllTroops = (GUICtrlRead($g_hChkMilkForceAllTroops) = $GUI_CHECKED)
EndFunc   ;==>MilkForceDeployHeroes

Func DebugSmartAttacks()
	$g_bDebugSmartMilk = (GUICtrlRead($g_hChkDebugSmartMilk) = $GUI_CHECKED)
	$g_bDebugSmartFarm = (GUICtrlRead($g_hChkDebugSmartFarm) = $GUI_CHECKED)
EndFunc   ;==>DebugSmartAttacks
#EndRegion - SmartMilk

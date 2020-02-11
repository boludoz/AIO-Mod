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

; Custom army - Team AiO MOD++
Func chkBBCustomArmy()
		$g_bChkBBCustomArmyEnable = (GUICtrlRead($g_hChkBBCustomArmyEnable) = $GUI_CHECKED)

		For $i = 0 To UBound($g_hComboTroopBB) - 1
			If $g_bChkBBCustomArmyEnable Then
				GUICtrlSetState($g_hComboTroopBB[$i], $GUI_ENABLE)
			Else
				GUICtrlSetState($g_hComboTroopBB[$i], $GUI_DISABLE)
			EndIf
		Next
EndFunc   ;==>chkBBCustomArmy

; Drop trophy - Team AiO MOD++
Func chkNoDropIfShield()
		$g_bChkNoDropIfShield = (GUICtrlRead($g_hChkNoDropIfShield) = $GUI_CHECKED)
EndFunc   ;==>chkNoDropIfShield

; Misc tab - Team AiO MOD++
Func chkDelayMod()
	; Skip first loop
	$g_bSkipfirstcheck = (GUICtrlRead($g_hSkipfirstcheck) = $GUI_CHECKED)
	
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
	
	$g_bDeployCastleFirst[$DB] = (GUICtrlRead($g_hDeployCastleFirstDB) = $GUI_CHECKED)
	$g_bDeployCastleFirst[$LB] = (GUICtrlRead($g_hDeployCastleFirstAB) = $GUI_CHECKED)
	

	
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
Func chkDBMeetCollectorOutside()
	If GUICtrlRead($g_hChkDBMeetCollectorOutside) = $GUI_CHECKED Then
		For $i = $g_hLblDBMinCollectorOutside To $g_hTxtDBMinCollectorOutsidePercent
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		_GUI_Value_STATE("ENABLE", $g_hChkDBCollectorNearRedline & "#" & $g_hChkSkipCollectorCheck & "#" & $g_hChkSkipCollectorCheckTH)
		chkDBCollectorNearRedline()
		chkSkipCollectorCheck()
		chkSkipCollectorCheckTH()
	Else
		For $i = $g_hLblDBMinCollectorOutside To $g_hCmbSkipCollectorCheckTH
			GUICtrlSetState($i, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		Next
	EndIf
EndFunc   ;==>chkDBMeetCollOutside

Func chkDBCollectorNearRedline()
	If GUICtrlRead($g_hChkDBCollectorNearRedline) = $GUI_CHECKED Then
		_GUI_Value_STATE("ENABLE", $g_hLblRedlineTiles & "#" & $g_hCmbRedlineTiles)
	Else
		_GUI_Value_STATE("DISABLE", $g_hLblRedlineTiles & "#" & $g_hCmbRedlineTiles)
	EndIf
EndFunc   ;==>chkDBCollectorsNearRedline

Func chkSkipCollectorCheck()
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

Func chkSkipCollectorCheckTH()
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

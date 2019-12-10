; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Control - Humanization
; Description ...: This file controls the "Humanization" tab
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

Func chkUseBotHumanization()
	If GUICtrlRead($g_hChkUseBotHumanization) = $GUI_CHECKED Then
		$g_bUseBotHumanization = True
		For $i = $g_hLabel1 To $g_hChkLookAtRedNotifications
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		cmbStandardReplay()
		cmbWarReplay()
	Else
		$g_bUseBotHumanization = False
		For $i = $g_hLabel1 To $g_hChkLookAtRedNotifications
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkUseBotHumanization
#cs
Func chkUseAltRClick()
	If GUICtrlRead($g_hChkUseAltRClick) = $GUI_CHECKED Then
		Local $UserChoice = MsgBox(4 + 48, "  •••  Warning !!", GetTranslatedFileIni("MOD GUI Design - BotHumanization", "chkUseAltRClick_Info_01", "Full Random Click Is a Good Feature To Be As Less Bot-Like As Possible Because It Makes All Bot Clicks Random.") & _
				@CRLF & "" & @CRLF & GetTranslatedFileIni("MOD GUI Design - BotHumanization", "chkUseAltRClick_Info_02", "It Still An Experimental Feature Which May Cause Unpredictable Problems.") & _
				@CRLF & "" & @CRLF & GetTranslatedFileIni("MOD GUI Design - BotHumanization", "chkUseAltRClick_Info_03", "So, Do You Want To Use It ?!"))
		If $UserChoice = 6 Then
			$g_bUseAltRClick = True
		Else
			$g_bUseAltRClick = False
			GUICtrlSetState($g_hChkUseAltRClick, $GUI_UNCHECKED)
		EndIf
	Else
		$g_bUseAltRClick = False
	EndIf
EndFunc   ;==>chkUseAltRClick
#ce
Func chkCollectAchievements()
	If GUICtrlRead($g_hChkCollectAchievements) = $GUI_CHECKED Then
		$g_bCollectAchievements = True
	Else
		$g_bCollectAchievements = False
	EndIf
EndFunc   ;==>chkCollectAchievements

Func chkLookAtRedNotifications()
	If GUICtrlRead($g_hChkLookAtRedNotifications) = $GUI_CHECKED Then
		$g_bLookAtRedNotifications = True
	Else
		$g_bLookAtRedNotifications = False
	EndIf
EndFunc   ;==>chkLookAtRedNotifications

Func cmbStandardReplay()
	If GUICtrlRead($g_hChkUseBotHumanization) = $GUI_CHECKED Then
		If (_GUICtrlComboBox_GetCurSel($g_acmbPriority[3]) > 0) Or (_GUICtrlComboBox_GetCurSel($g_acmbPriority[4]) > 0) Then
			For $i = $g_hLabel7 To $g_acmbPause[0]
				GUICtrlSetState($i, $GUI_ENABLE)
			Next
		Else
			For $i = $g_hLabel7 To $g_acmbPause[0]
				GUICtrlSetState($i, $GUI_DISABLE)
			Next
		EndIf
	EndIf
EndFunc   ;==>cmbStandardReplay

Func cmbWarReplay()
	If GUICtrlRead($g_hChkUseBotHumanization) = $GUI_CHECKED Then
		If _GUICtrlComboBox_GetCurSel($g_acmbPriority[10]) > 0 Then
			For $i = $g_hLabel13 To $g_acmbPause[1]
				GUICtrlSetState($i, $GUI_ENABLE)
			Next
		Else
			For $i = $g_hLabel13 To $g_acmbPause[1]
				GUICtrlSetState($i, $GUI_DISABLE)
			Next
		EndIf
	EndIf
EndFunc   ;==>cmbWarReplay

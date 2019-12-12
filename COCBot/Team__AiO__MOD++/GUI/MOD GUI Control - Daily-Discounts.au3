; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Control - Daily Discounts
; Description ...: Control sub gui for daily discounts
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill 2019
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func btnDailyDiscounts()
		GUICtrlSetState($g_hBtnMagicItemsConfig, $GUI_DISABLE)
		GUISetState(@SW_SHOW, $g_hGUI_DailyDiscounts)
EndFunc   ;==>btnDailyDiscounts

Func btnDDApply()
	GUISetState(@SW_HIDE, $g_hGUI_DailyDiscounts)
	
	Local $iDealsChecked = 0
	
	$g_bChkCollectMagicItems = (GUICtrlRead($g_hChkCollectMagicItems) = $GUI_CHECKED) ? (True) : (False)
	GUICtrlSetState($g_hBtnMagicItemsConfig, ($g_bChkCollectMagicItems) ? ($GUI_ENABLE) : ($GUI_DISABLE))
	
	For $i = 0 To $g_iDDCount - 1
		If $g_bChkCollectMagicItems = False Then
			$g_abChkDD_Deals[$i] = False
		ElseIf $g_bChkCollectMagicItems = True and GUICtrlRead($g_ahChkDD_Deals[$i]) = $GUI_CHECKED Then
			$g_abChkDD_Deals[$i] = True
			$iDealsChecked += 1
		Else
			$g_abChkDD_Deals[$i] = False
		EndIf
	Next

	If $g_bChkCollectMagicItems And $iDealsChecked <> 0 Then
		GUICtrlSetBkColor($g_hBtnMagicItemsConfig, $COLOR_GREEN)
	Else
		$g_bChkCollectMagicItems = False
		GUICtrlSetBkColor($g_hBtnMagicItemsConfig, $COLOR_RED)
	EndIf

	GUICtrlSetState($g_hBtnMagicItemsConfig, $GUI_ENABLE)
EndFunc   ;==>btnDDApply

Func btnDDClose()
	GUISetState(@SW_HIDE, $g_hGUI_DailyDiscounts)
	For $i = 0 To $g_iDDCount - 1
		If Not $g_abChkDD_Deals[$i] Then GUICtrlSetState($g_ahChkDD_Deals[$i], $GUI_UNCHECKED)
		If $g_abChkDD_Deals[$i] Then GUICtrlSetState($g_ahChkDD_Deals[$i], $GUI_CHECKED)
	Next
	GUICtrlSetState($g_hBtnMagicItemsConfig, $GUI_ENABLE)
EndFunc   ;==>btnDDClose

Func btnDDClear()
	For $i = 0 To $g_iDDCount - 1
		GUICtrlSetState($g_ahChkDD_Deals[$i], $GUI_UNCHECKED)
	Next
EndFunc   ;==>btnDDClear
; #FUNCTION# ====================================================================================================================
; Name ..........: Boost a troop to super troop
; Description ...:
; Syntax ........: BoostSuperTroop()
; Parameters ....:
; Return values .:
; Author ........: Fliegerfaust (04/2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostSuperTroop()
	
	; Start - 162, 313
	; 143 * (Slot) - X
	; 182 * (Slot) - Y
	; By line - 4
	
	; SecondPage - 77 
	
	;	Labels
	Local $iSlot = 0, $vPoint = 0
	Local $iSlotX = 143, $iSlotY = 182
	
	
	; GRAY
	; _MultiPixelSearch(148 + ($iSlotX * $iSlot), 242, 290 + ($iSlotX * $iSlot), 430, 2, 2, Hex(0xA9A9A9, 6), StringSplit2d("0x7E7E7E-106-0|0x7F7F7F-106-26"), 15)
	
	Local $aiCombo = $g_ahCmbSuperTroops
		
	$aiCombo[0] = _GUICtrlComboBox_GetCurSel($g_ahCmbSuperTroops[0])
	$aiCombo[1] = _GUICtrlComboBox_GetCurSel($g_ahCmbSuperTroops[1])

	For $i = 0 To $iSuperTroopsCount - 1
		
		
			; RED Label
			$vPoint = _MultiPixelSearch(148 + ($iSlotX * $iSlot), 242, 290 + ($iSlotX * $iSlot), 430, 2, 2, Hex(0xF58E8E, 6), StringSplit2d("0xE55151-106-0|0xE55351-106-26"), 15)
			
			If UBound($vPoint) = 2 And not @error Then
				
				
			EndIf
		
		
	Next
	
	
 EndFunc   ;==>BoostSuperTroop
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
	; 142 * (Slot) - X
	; 182 * (Slot) - Y
	; By line - 4
	
	; SecondPage - 77 
	
	;	Labels
	Local $bSecondPage
	Local $aTroopUbi[12] = ["SBarb", "SArch", "SGiant", "SGoblin", _
							"SWallBreaker", "RBalloon", "SWizard", "IDragon", _
							"SMinion", "SValk", "SWitch", "IHound"]
	Local $hHexActive = 0xDF4A4D
	Local $hHexDisabled = 0x767676

	Do
		If $bSecondPage Then
			
		EndIf
	Until True
	
	
 EndFunc   ;==>BoostSuperTroop
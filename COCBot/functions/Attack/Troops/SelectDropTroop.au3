
; #FUNCTION# ====================================================================================================================
; Name ..........: SelectDropTroop
; Description ...:
; Syntax ........: SelectDropTroop($iTroopIndex)
; Parameters ....: $iTroopIndex : Index of any Troop from Barbarian to Siege Machines
; Return values .: None
; Author ........:
; Modified ......: Fliegerfaust (12/2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func SelectDropTroop($iSlotIndex, $iClicks = 1, $iDelay = Default, $bCheckAttackPage = Default)
	If $iDelay = Default Then $iDelay = 0
	If $bCheckAttackPage = Default Then $bCheckAttackPage = True
	If Not $bCheckAttackPage Or IsAttackPage() Then ClickP(GetSlotPosition($iSlotIndex), $iClicks, $iDelay, "#0111")
EndFunc   ;==>SelectDropTroop

Global $g_islotocrcompensation = 13

Func GetXPosOfArmySlot($iSlotIndex, $bgetposxforclick = False, $bgetposxforocr = False, $bgetposxforheroesability = False)
	If $iSlotIndex > UBound($g_avattacktroops) - 1 OR $iSlotIndex < 0 Then
		SetLog("Error: GetXPosOfArmySlot Trying to check Slot: " & $iSlotIndex, $color_error)
		Return 0
	Else
		Local $t4362 = GetTroopName($g_avattacktroops[$iSlotIndex][0])
		If $g_bdraggedattackbar AND $iSlotIndex > -1 Then
			Local $i2ndpageslotstartxspace = 27
			Local $islotnewnumber = $iSlotIndex - ($g_itotalattackslot - 10)
			If $g_bdebugsetlog Then SetLog("[" & $t4362 & "] Dragged GetXPosOfArmySlot » " & $iSlotIndex & " » 2nd Page Slot No : " & $islotnewnumber)
			If ($iSlotIndex > 10) Then
				Local $itroopsslotstartposx = $g_avattacktroops[$iSlotIndex][2]
			Else
				Local $itroopsslotstartposx = $g_avattacktroops[$iSlotIndex][2] - $g_avattacktroops[$iSlotIndex - $islotnewnumber][2] + $i2ndpageslotstartxspace
			EndIf
			$iSlotIndex = $islotnewnumber
		Else
			Local $itroopsslotstartposx = $g_avattacktroops[$iSlotIndex][2]
		EndIf
		If $bgetposxforclick Then
			If $g_bdebugsetlog Then SetLog("[" & $t4362 & "] GetXPosOfArmySlot » " & $iSlotIndex & " » For Click: " & $itroopsslotstartposx + 32)
			Return $itroopsslotstartposx + 32
		EndIf
		If $bgetposxforheroesability Then
			If $g_bdebugsetlog Then SetLog("[" & $t4362 & "] GetXPosOfArmySlot » " & $iSlotIndex & " » For Heroes Ability: " & $itroopsslotstartposx + 26)
			Return $itroopsslotstartposx + 28
		EndIf
		If $bgetposxforocr Then
			If $g_bdebugsetlog Then SetLog("[" & $t4362 & "] GetXPosOfArmySlot » " & $iSlotIndex & " » For Ocr: " & $itroopsslotstartposx + $g_islotocrcompensation)
			Return $itroopsslotstartposx + $g_islotocrcompensation
		EndIf
		If $g_bdebugsetlog Then SetLog("[" & $t4362 & "] GetXPosOfArmySlot » " & $iSlotIndex & " » Slot Start X: " & $itroopsslotstartposx)
		Return $itroopsslotstartposx
	EndIf
EndFunc

Func GetSlotPosition($iSlotIndex, $bOCRPosition = False)
	Local $aiReturnPosition[2] = [0, 0]

	If $iSlotIndex < 0 Or $iSlotIndex > UBound($g_avAttackTroops, 1) - 1 Then 
		SetDebugLog("GetSlotPosition(" & $iSlotIndex & ", " & $bOCRPosition & "): Invalid slot index: " & $iSlotIndex)
		Return $aiReturnPosition ;Invalid Slot Index returns Click Position X: 0 And Y:0
	EndIf
		
	If Not $bOCRPosition Then
		$aiReturnPosition[0] = $g_avAttackTroops[$iSlotIndex][2]
		$aiReturnPosition[1] = $g_avAttackTroops[$iSlotIndex][3]
	Else
		$aiReturnPosition[0] = $g_avAttackTroops[$iSlotIndex][4]
		$aiReturnPosition[1] = $g_avAttackTroops[$iSlotIndex][5]
	EndIf
	Return $aiReturnPosition
EndFunc   ;==>GetSlotPosition

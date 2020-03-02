; #FUNCTION# ====================================================================================================================
; Name ..........: GetAttackBarBB
; Description ...: Gets the troops and there quantities for the current attack
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetAttackBarBB($bRemaining = False, $bFastToDrop = False)
	Local $iTroopBanners = 640 ; y location of where to find troop quantities
	Local $aSlot1 = [85, 640] ; location of first slot
	Local $iSlotOffset = 73 ; slots are 73 pixels apart
	Local $iBarOffset = 66 ; 66 pixels from side to attack bar

	; testing troop count logic
	;PureClickP($aSlot1)
	;local $iTroopCount = Number(getTroopCountSmall($aSlot1[0], $aSlot1[1]))
	;If $iTroopCount == 0 Then $iTroopCount = Number(getTroopCountBig($aSlot1[0], $aSlot1[1]-2))
	;SetLog($iTroopCount)
	;$iTroopCount = Number(getTroopCountSmall($aSlot1[0] + 144, $aSlot1[1]))
	;SetLog($iTroopCount)

	Local $aBBAttackBar[0][5]
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	Local $sSearchDiamond = GetDiamondFromRect("0,630,860,732"), $aBBAttackBarResult

	For $i = 0 To 5
		$aBBAttackBarResult = findMultiple($g_sImgDirBBTroops, $sSearchDiamond, $sSearchDiamond, 0, 1000, 0, "objectname,objectpoints", True)
		If UBound($aBBAttackBarResult) > 0 Then ExitLoop
	Next

	If Not $bRemaining And $i > 5 Then
		SetLog("Error in GetAttackBarBB(): Search did not return any results!", $COLOR_ERROR)
;~ 		DebugImageSave("ErrorBBAttackBarCheck", False, Default, Default, "#1")
		Return -1
		ElseIf $bRemaining Then
		Return ""
	EndIf

	; parse data into attackbar array... not done
	For $i = 0 To UBound($aBBAttackBarResult, 1) - 1
		Local $aTroop = $aBBAttackBarResult[$i]
		Local $aTempMultiCoords = decodeMultipleCoords($aTroop[1])
		For $j = 0 To UBound($aTempMultiCoords, 1) - 1
			Local $aTempCoords = $aTempMultiCoords[$j]
			If UBound($aTempCoords) < 2 Then ContinueLoop
			Local $iSlot = Int(($aTempCoords[0] - $iBarOffset) / $iSlotOffset)
			Local $iCount = ($aTroop[0] = "Machine") ? (1) : (Number(_getTroopCountSmall($aTempCoords[0], $iTroopBanners)))
			If $iCount < 1 Then $iCount = Number(_getTroopCountBig($aTempCoords[0], $iTroopBanners - 2))
			If $iCount < 1 Then
				SetLog("Could not get count for " & $aTroop[0] & " in slot " & String($iSlot), $COLOR_ERROR)
				ContinueLoop
			EndIf
			Local $aTempElement[1][5] = [[$aTroop[0], $aTempCoords[0], $aTempCoords[1], $iSlot, $iCount]] ; element to add to attack bar list
			If $aTroop[0] = "Machine" Then _ArrayAdd($g_aMachineBB, $aTempElement)
			_ArrayAdd($aBBAttackBar, $aTempElement)
			If $bFastToDrop Then Return $aBBAttackBar
		Next
	Next
	Local $Emtpy = True

	If UBound($aBBAttackBar, 1) > 0 Then _ArraySort($aBBAttackBar, 0, 0, 0, 3) ; sort by slot in case they do not want custom order. Default to drop in order of attackbar

	; Get troops on attack bar and their quantities
	Setlog("Attack Bar:", $COLOR_SUCCESS)
	For $i = 0 To UBound($aBBAttackBar) - 1
		If Not $g_bRunState Then Return
		If $aBBAttackBar[$i][0] <> "" Then
			SetLog("[" & $aBBAttackBar[$i][3] + 1 & "] - " & $aBBAttackBar[$i][4] & "x " & FullNametroops($aBBAttackBar[$i][0]), $COLOR_SUCCESS)
			$Emtpy = False
		EndIf
	Next
	If $Emtpy Then Return -1

	Return $aBBAttackBar
EndFunc   ;==>GetAttackBarBB


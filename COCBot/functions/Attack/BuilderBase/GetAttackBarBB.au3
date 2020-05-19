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

Func GetAttackBarBB($bRemaining = False)
	local $iTroopBanners = 640 ; y location of where to find troop quantities
	local $aSlot1 = [85, 640] ; location of first slot
	local $iSlotOffset = 73 ; slots are 73 pixels apart
	local $iBarOffset = 66 ; 66 pixels from side to attack bar
	If $bRemaining = False Then $g_aMachineBB = 0 ; Team AIO Mod++
	; testing troop count logic
	;PureClickP($aSlot1)
	;local $iTroopCount = Number(getTroopCountSmall($aSlot1[0], $aSlot1[1]))
	;If $iTroopCount == 0 Then $iTroopCount = Number(getTroopCountBig($aSlot1[0], $aSlot1[1]-2))
	;SetLog($iTroopCount)
	;$iTroopCount = Number(getTroopCountSmall($aSlot1[0] + 144, $aSlot1[1]))
	;SetLog($iTroopCount)

	local $aBBAttackBar[0][5]
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	local $sSearchDiamond = GetDiamondFromRect("0,630,860,732")
	local $aBBAttackBarResult = findMultiple($g_sImgDirBBTroops, $sSearchDiamond, $sSearchDiamond, 0, 1000, 0, "objectname,objectpoints", True)

	If UBound($aBBAttackBarResult) = 0 Then
		If Not $bRemaining Then
			SetLog("Error in BBAttackBarCheck(): Search did not return any results!", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("ErrorBBAttackBarCheck", False, Default, Default)
		EndIf
		Return -1
	EndIf

	; parse data into attackbar array... not done
	For $i = 0 To UBound($aBBAttackBarResult, 1) - 1
		local $aTroop = $aBBAttackBarResult[$i]

		local $aTempMultiCoords = decodeMultipleCoords($aTroop[1])
		For $j=0 To UBound($aTempMultiCoords, 1) - 1
			local $aTempCoords = $aTempMultiCoords[$j]
			If UBound($aTempCoords) < 2 Then ContinueLoop
			local $iSlot = Int(($aTempCoords[0] - $iBarOffset) / $iSlotOffset)
			Local $bIsMachine = (StringInStr($aTroop[0], "Machine") > 0) ; Team AIO Mod++
			
			If $bIsMachine Then 
				$iCount = 1 ; Team AIO Mod++
			Else
				For $i = 0 To 15
					local $iCount = Number(_getTroopCountSmall($aTempCoords[0], $iTroopBanners))
					If $iCount == 0 Then $iCount = Number(_getTroopCountBig($aTempCoords[0], $iTroopBanners-7))
					If $iCount <> 0 Then ExitLoop
					If _Sleep(50) Then Return
				Next
			EndIf
			
			If $iCount == 0 Then
				SetLog("Could not get count for " & $aTroop[0] & " in slot " & String($iSlot), $COLOR_ERROR)
				ContinueLoop
			EndIf

			Local $aTempElement[1][5] = [[$aTroop[0], $aTempCoords[0], $aTempCoords[1], $iSlot, $iCount]] ; element to add to attack bar list
			If not $bRemaining and $bIsMachine Then $g_aMachineBB = $aTempElement ; Team AIO Mod++
			_ArrayAdd($aBBAttackBar, $aTempElement)
		Next

	Next
	
	If UBound($aBBAttackBar) < 1 Then Return -1 ; Team AIO Mod++
	
	_ArraySort($aBBAttackBar, 0, 0, 0, 3)
	For $i=0 To UBound($aBBAttackBar, 1) - 1
		SetLog($aBBAttackBar[$i][0] & ", (" & String($aBBAttackBar[$i][1]) & "," & String($aBBAttackBar[$i][2]) & "), Slot: " & String($aBBAttackBar[$i][3]) & ", Count: " & String($aBBAttackBar[$i][4]), $COLOR_SUCCESS)
	Next
	Return $aBBAttackBar
EndFunc

Func _getTroopCountSmall($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return getOcrAndCapture("coc-t-s", $x_start, $y_start, 53, 16, True, Default, $bNeedNewCapture)
EndFunc   ;==>getTroopCountSmall

Func _getTroopCountBig($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for selected troop kind
	Return getOcrAndCapture("coc-t-b", $x_start, $y_start, 53, 17, True, Default, $bNeedNewCapture)
EndFunc   ;==>getTroopCountBig

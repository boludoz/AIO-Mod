; #FUNCTION# ====================================================================================================================
; Name ..........: getArmySpells
; Description ...: Obtain the current brewed Spells
; Syntax ........: getArmySpells()
; Parameters ....:
; Return values .:
; Author ........: Fliegerfaust(11-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getArmySpells($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bCheckWindow = False, $bSetLog = True, $bNeedCapture = True)

	If $g_bDebugSetlogTrain Then SetLog("getArmySpells():", $COLOR_DEBUG)

	If Not $bOpenArmyWindow Then
		If $bCheckWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		EndIf
	ElseIf $bOpenArmyWindow Then
		If Not OpenArmyOverview(True, "getArmySpells()") Then
			SetError(2)
			Return ; not open, requested to be open - error.
		EndIf
		If _Sleep($DELAYCHECKARMYCAMP5) Then Return
	EndIf

	Local $sSpellDiamond = GetDiamondFromRect("23,366,585,400")
	Local $aCurrentSpells = findMultiple(@ScriptDir & "\imgxml\ArmyOverview\Spells", $sSpellDiamond, $sSpellDiamond, 0, 1000, 0, "objectname,objectpoints", $bNeedCapture) ; Returns $aCurrentSpells[index] = $aArray[2] = ["SpellShortName", CordX,CordY]

	Local $aTempSpellArray, $aSpellCoords
	Local $sSpellName = ""
	Local $iSpellIndex = -1
	Local $aCurrentSpellsEmpty[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ; Local Copy to reset Spells Array
	Local $aCurrentSpellsLog[$eSpellCount][3] ; [0] = Name [1] = Quantities [3] Xaxis

	$g_aiCurrentSpells = $aCurrentSpellsEmpty ; Reset Current Spells Array

	If UBound($aCurrentSpells, 1) >= 1 Then
		For $i = 0 To UBound($aCurrentSpells, 1) - 1 ; Loop through found Spells
			$aTempSpellArray = $aCurrentSpells[$i] ; Declare Array to Temp Array

			$iSpellIndex = TroopIndexLookup($aTempSpellArray[0], "getArmySpells()") - $eLSpell ; Get the Index of the Spell from the ShortName

			If $iSpellIndex < 0 Then ContinueLoop

			$aSpellCoords = StringSplit($aTempSpellArray[1], ",", $STR_NOCOUNT) ; Split the Coordinates where the Spell got found into X and Y
			If UBound($aSpellCoords) < 2  Then ContinueLoop
			$g_aiCurrentSpells[$iSpellIndex] = Number(getBarracksNewTroopQuantity(Slot($aSpellCoords[0], $aSpellCoords[1]), 341, $bNeedCapture)) ; Get The Quantity of the Spell, Slot() Does return the exact spot to read the Number from

			$sSpellName = $g_aiCurrentSpells[$iSpellIndex] >= 2 ? $g_asSpellNames[$iSpellIndex] & " Spells" : $g_asSpellNames[$iSpellIndex] & " Spell" ; Select the right Spell Name, If more than one then use Spells at the end
			$aCurrentSpellsLog[$iSpellIndex][0] = $sSpellName
			$aCurrentSpellsLog[$iSpellIndex][1] = $g_aiCurrentSpells[$iSpellIndex]
			$aCurrentSpellsLog[$iSpellIndex][2] = Slot($aSpellCoords[0], $aSpellCoords[1])
		Next
	EndIf
	; Just a good log from left to right
	_ArraySort($aCurrentSpellsLog, 0, 0, 0, 2)
	For $index = 0 To UBound($aCurrentSpellsLog) - 1
		If $aCurrentSpellsLog[$index][1] > 0 And $bSetLog Then SetLog(" - " & $aCurrentSpellsLog[$index][1] & " " & $aCurrentSpellsLog[$index][0] & " Brewed", $COLOR_SUCCESS)
	Next

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf
EndFunc   ;==>getArmySpells2

Func getArmySpells2($hHBitmap)

	SetLog("Check army spells", $COLOR_INFO)
	For $i = 0 To UBound($MySpells) - 1
		$g_aiCurrentSpells[$i] = 0
	Next

	If $g_bDebugSetlogTrain Then SetLog("getArmySpells():", $COLOR_DEBUG)

	Local $sSpellDiamond = GetDiamondFromRect("23,366,585,400")
	Local $aCurrentSpells = findMultiImage($hHBitmap, @ScriptDir & "\imgxml\ArmyOverview\Spells", $sSpellDiamond, $sSpellDiamond, 0, 1000, 0, "objectname,objectpoints") ; Returns $aCurrentSpells[index] = $aArray[2] = ["SpellShortName", CordX,CordY]

	Local $aTempSpellArray, $aSpellCoords
	Local $sSpellName = ""
	Local $iSpellIndex = -1
	Local $aCurrentSpellsEmpty[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ; Local Copy to reset Spells Array
	Local $aCurrentSpellsLog[$eSpellCount][3] ; [0] = Name [1] = Quantities [3] Xaxis

	$g_aiCurrentSpells = $aCurrentSpellsEmpty ; Reset Current Spells Array
	
	; OCR
	$g_hHBitmap2 = GetHHBitmapArea($hHBitmap)
	If UBound($aCurrentSpells, 1) >= 1 Then
		For $i = 0 To UBound($aCurrentSpells, 1) - 1 ; Loop through found Spells
			$aTempSpellArray = $aCurrentSpells[$i] ; Declare Array to Temp Array

			$iSpellIndex = TroopIndexLookup($aTempSpellArray[0], "getArmySpells()") - $eLSpell ; Get the Index of the Spell from the ShortName

			If $iSpellIndex < 0 Then ContinueLoop

			$aSpellCoords = StringSplit($aTempSpellArray[1], ",", $STR_NOCOUNT) ; Split the Coordinates where the Spell got found into X and Y
			If UBound($aSpellCoords) < 2  Then ContinueLoop
			$g_aiCurrentSpells[$iSpellIndex] = Number(getBarracksNewTroopQuantity(Slot($aSpellCoords[0], $aSpellCoords[1]), 341, False)) ; Get The Quantity of the Spell, Slot() Does return the exact spot to read the Number from

			$sSpellName = $g_aiCurrentSpells[$iSpellIndex] >= 2 ? $g_asSpellNames[$iSpellIndex] & " Spells" : $g_asSpellNames[$iSpellIndex] & " Spell" ; Select the right Spell Name, If more than one then use Spells at the end
			$aCurrentSpellsLog[$iSpellIndex][0] = $sSpellName
			$aCurrentSpellsLog[$iSpellIndex][1] = $g_aiCurrentSpells[$iSpellIndex]
			$aCurrentSpellsLog[$iSpellIndex][2] = Slot($aSpellCoords[0], $aSpellCoords[1])
		Next
	EndIf
	; Just a good log from left to right
	_ArraySort($aCurrentSpellsLog, 0, 0, 0, 2)
	For $index = 0 To UBound($aCurrentSpellsLog) - 1
		If $aCurrentSpellsLog[$index][1] > 0 Then SetLog(" - " & $aCurrentSpellsLog[$index][1] & " " & $aCurrentSpellsLog[$index][0] & " Brewed", $COLOR_SUCCESS)
	Next
	Return True
EndFunc   ;==>getArmySpells2
#CS
Func getArmySpells2($hHBitmap)
	If Not $g_bRunState Then Return
	If $g_bDebugSetlogTrain Then SetLog("getArmySpells2():", $COLOR_DEBUG)
	If Int($g_iTownHallLevel) < 5 Then Return
	Local $RemSpellSlot[7] = [0, 0, 0, 0, 0, 0, 0]
	SetLog("Check Army Spells", $COLOR_INFO)
	For $i = 0 To UBound($MySpells) - 1
		$g_aiCurrentSpells[$i] = 0
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	$g_hHBitmap = GetHHBitmapArea($hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	$g_hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap)
	Local $aiSpellsInfo[7][3]
	Local $AvailableCamp = 0
	Local $sDirectory = @ScriptDir & "\imgxml\ArmyOverview\Spells"; $g_sImgArmyOverviewSpells_
	Local $returnProps = "objectname"
	Local $aPropsValues
	Local $iSpellIndex = -1
	Local $sSpellName = ""
	Local $bDeletedExcess = False
	Local $bForceToDeleteUnknow = False
	For $i = 0 To 6
		If Not $g_bRunState Then Return
		If _ColorCheck(_GetPixelColor(Int(30 + ($g_iArmy_Av_Spell_Slot_Width * $i)), 301 + 44, False), Hex(0X7856E0, 6), 20) Then
			Local $iPixelDivider = ($g_iArmy_RegionSizeForScan - ($g_aiArmyAvailableSpellSlot[3] - $g_aiArmyAvailableSpellSlot[1])) / 2
			$g_hHBitmap_Av_Spell_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_RegionSizeForScan) / 2) + $g_iArmy_RegionSizeForScan), $g_aiArmyAvailableSpellSlot[3] + $iPixelDivider)
			$g_hHBitmap_Capture_Av_Spell_Slot[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1], Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_ImageSizeForScan) / 2) + $g_iArmy_ImageSizeForScan), $g_aiArmyAvailableSpellSlot[3])
			Local $result = findMultiImage($g_hHBitmap_Av_Spell_Slot[$i], $sDirectory, "FV", "FV", 0, 1000, 1, $returnProps)
			If IsArray($result) Then
				For $j = 0 To UBound($result) - 1
					If $j = 0 Then
						$aPropsValues = $result[$j]
						If UBound($aPropsValues) = 1 Then
							$aiSpellsInfo[$i][0] = $aPropsValues[0]
							$aiSpellsInfo[$i][2] = $i + 1
						EndIf
					ElseIf $j = 1 Then
						$aPropsValues = $result[$j]
						SetLog("Error: Multiple detect spells on slot: " & $i + 1, $COLOR_ERROR)
						SetLog("Spell: " & $aiSpellsInfo[$i][0], $COLOR_ERROR)
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					Else
						$aPropsValues = $result[$j]
						SetLog("Spell: " & $aPropsValues[0], $COLOR_ERROR)
					EndIf
				Next
				If $aPropsValues[0] = "0" Then
					O28380($i)
					ExitLoop
				EndIf
			ElseIf $g_bDebugSetlogTrain Or $g_iTrainSystemErrors[$g_iCurAccount][1] > 0 Then
				Local $iPixelDivider = ($g_iArmy_EnlargeRegionSizeForScan - ($g_aiArmyAvailableSpellSlot[3] - $g_aiArmyAvailableSpellSlot[1])) / 2
				Local $temphHBitmap = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2)), $g_aiArmyAvailableSpellSlot[1] - $iPixelDivider, Int($g_aiArmyAvailableSpellSlot[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_EnlargeRegionSizeForScan) / 2) + $g_iArmy_EnlargeRegionSizeForScan), $g_aiArmyAvailableSpellSlot[3] + $iPixelDivider)
				_debugSaveHBitmapToImage($temphHBitmap, "Spell_Av_Slot_" & $i + 1, "ArmyWindows\Spells\Replace", True)
				_debugSaveHBitmapToImage($g_hHBitmap_Capture_Av_Spell_Slot[$i], "Spell_Slot_" & $i + 1 & "_Unknown_RenameThis_92", "ArmyWindows\Spells\Replace", True)
				GdiDeleteHBitmap($temphHBitmap)
				SetLog("Error: Cannot detect what spells on slot: " & $i + 1, $COLOR_DEBUG)
				SetLog("Please check the filename: Spell_Slot_" & $i + 1 & "_Unknown_RenameThis_92.png", $COLOR_DEBUG)
				SetLog("Locate at:" & $g_sProfileTempDebugPath, $COLOR_DEBUG)
				SetLog("Rename the correct filename and replace back to file location: " & $sDirectory, $COLOR_DEBUG)
				SetLog("And then restart the bot.", $COLOR_DEBUG)
				O28380($i)
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				If $g_iTrainSystemErrors[$g_iCurAccount][0] > 5 Then
					SetLog("This Spell on slot " & $i + 1 & " needs to be removed.")
					If $g_bPreciseBrew Then
						SetLog("This Spell on slot " & $i + 1 & " needs to be removed!")
						$aiSpellsInfo[$i][0] = "UNKNOWN"
					EndIf
				Else
					ContinueLoop
				EndIf
			Else
				SetLog("Enable Debug Mode", $COLOR_DEBUG)
				O28380($i)
				ContinueLoop
			EndIf
			$g_hHBitmap_Av_Spell_SlotQty[$i] = GetHHBitmapArea($hHBitmap, Int($g_aiArmyAvailableSpellSlotQty[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2)), $g_aiArmyAvailableSpellSlotQty[1], Int($g_aiArmyAvailableSpellSlotQty[0] + ($g_iArmy_Av_Spell_Slot_Width * $i) + (($g_iArmy_Av_Spell_Slot_Width - $g_iArmy_QtyWidthForScan) / 2) + $g_iArmy_QtyWidthForScan), $g_aiArmyAvailableSpellSlotQty[3])
			$aiSpellsInfo[$i][1] = getTSOcrFullComboQuantity($g_hHBitmap_Av_Spell_SlotQty[$i])
			If $aiSpellsInfo[$i][1] <> 0 Then
				If $aiSpellsInfo[$i][0] = "UNKNOWN" Then
					$RemSpellSlot[$i] = $aiSpellsInfo[$i][1]
					$bForceToDeleteUnknow = True
					$bDeletedExcess = True
				Else
					$iSpellIndex = TroopIndexLookup($aiSpellsInfo[$i][0]) - $eLSpell
					$sSpellName = GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1])
					SetLog(" - No. of Available " & $sSpellName & ": " & $aiSpellsInfo[$i][1], $COLOR_SUCCESS)
					$g_aiCurrentSpells[$iSpellIndex] = $aiSpellsInfo[$i][1]
					$AvailableCamp += ($aiSpellsInfo[$i][1] * $MySpells[$iSpellIndex][2])
					If $g_bPreciseBrew Then
						If $aiSpellsInfo[$i][1] > $MySpells[$iSpellIndex][3] Then
							$bDeletedExcess = True
							SetLog(" >>> Excess: " & $aiSpellsInfo[$i][1] - $MySpells[$iSpellIndex][3], $COLOR_WARNING)
							$RemSpellSlot[$i] = $aiSpellsInfo[$i][1] - $MySpells[$iSpellIndex][3]
							If $g_bDebugSetlogTrain Then SetLog("Set Remove Slot: " & $aiSpellsInfo[$i][2])
						EndIf
					EndIf
				EndIf
			Else
				SetLog("Error detect quantity no. On Spell: " & GetTroopName(TroopIndexLookup($aiSpellsInfo[$i][0]), $aiSpellsInfo[$i][1]), $COLOR_RED)
				ExitLoop
			EndIf
		EndIf
		O28380($i)
	Next
	GdiDeleteHBitmap($g_hHBitmap)
	GdiDeleteBitmap($g_hBitmap)
	If $AvailableCamp <> $g_iCurrentSpells And $bForceToDeleteUnknow = False Then
		SetLog("Error: Spells size for all available Unit: " & $AvailableCamp & "  -  Camp: " & $g_iCurrentSpells, $COLOR_RED)
		$g_bRestartCheckTroop = True
		$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
		Return False
	Else
		If $bDeletedExcess Then
			$bDeletedExcess = False
			If OpenSpellsTab() = False Then Return False
			If Not _ColorCheck(_GetPixelColor(823, 175 + $g_iMidOffsetY, True), Hex(0xCFCFC8, 6), 20) Then
				SetLog(" >>> Stop Brew Spell.", $COLOR_WARNING)
				RemoveAllTroopAlreadyTrain()
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				Return False
			EndIf
			If OpenArmyTab(True, "Brew Spells Tab") = False Then Return
			SetLog(" >>> Remove Excess Spells.", $COLOR_WARNING)
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				Click($aButtonEditArmy_[0], $aButtonEditArmy_[1], 1, 0, "#EditArmy")
			Else
				Return
			EndIf
			If WaitforPixel($aButtonEditCancel[4], $aButtonEditCancel[5], $aButtonEditCancel[4] + 1, $aButtonEditCancel[5] + 1, Hex($aButtonEditCancel[6], 6), $aButtonEditCancel[7], 20) Then
				For $i = 6 To 0 Step -1
					Local $RemoveSlotQty = $RemSpellSlot[$i]
					If $g_bDebugSetlogTrain Then SetLog($i & " $RemoveSlotQty: " & $RemoveSlotQty)
					If $RemoveSlotQty > 0 Then
						Local $iRx = (80 + ($g_iArmy_Av_Spell_Slot_Width * $i))
						Local $iRy = 386 + $g_iMidOffsetY
						For $j = 1 To $RemoveSlotQty
							Click(Random($iRx - 2, $iRx + 2, 1), Random($iRy - 2, $iRy + 2, 1))
							If $g_bUseRandomClick = False Then
								If _Sleep($g_iTrainClickDelay) Then Return
							Else
								If $g_iTrainClickDelay < 100 Then $g_iTrainClickDelay += 100
								If $g_iTrainClickDelay > 400 Then $g_iTrainClickDelay -= 100
								If _Sleep(Random($g_iTrainClickDelay - 100, $g_iTrainClickDelay + 100, 1)) Then Return
							EndIf
						Next
						$RemSpellSlot[$i] = 0
					EndIf
				Next
			Else
				Return
			EndIf
			If WaitforPixel($aButtonEditOkay[4], $aButtonEditOkay[5], $aButtonEditOkay[4] + 1, $aButtonEditOkay[5] + 1, Hex($aButtonEditOkay[6], 6), $aButtonEditOkay[7], 20) Then
				Click($aButtonEditOkay[0], $aButtonEditOkay[1], 1, 0, "#EditArmyOkay")
			Else
				Return
			EndIf
			ClickOkay()
			$g_bRestartCheckTroop = True
			If WaitforPixel($aButtonEditArmy_[4], $aButtonEditArmy_[5], $aButtonEditArmy_[4] + 1, $aButtonEditArmy_[5] + 1, Hex($aButtonEditArmy_[6], 6), $aButtonEditArmy_[7], 20) Then
				$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
				Return False
			Else
				If _Sleep(1000) Then Return False
			EndIf
			$g_iTrainSystemErrors[$g_iCurAccount][1] += 1
			Return False
		EndIf
		GdiDeleteHBitmap($g_hHBitmap)
		GdiDeleteBitmap($g_hBitmap)
		Return True
	EndIf
	Return False
EndFunc   ;==>getArmySpells2
#CE
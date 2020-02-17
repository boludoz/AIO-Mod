; #FUNCTION# ====================================================================================================================
; Name ..........: TNRQT
; Description ...: Train and Remove Queue Troops
; Author ........: Ahsan Iqbal
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $TroopsQueueFull = False
Global $g_bSmartQueueSystem = True
Global $g_sImgArmyOverviewSpellQueued = @ScriptDir & "\imgxml\ArmyOverview\SpellQueued\" ; \ at the end of the pasth is must - ADDED By SM MOD
Global $g_sImgArmyOverviewTroopQueued = @ScriptDir & "\imgxml\ArmyOverview\TroopQueued\" ; \ at the end of the pasth is must - ADDED By SM MOD

Local $Troopsdetect, $Spelldetect, $TroopCamp, $TroopCamp1


Func TNRQT($TroopsQueueFullOnly = False, $TroopsQueueTrain = True, $TroopsQueueRemove = True, $OpenTabForQueue = False)
	$Troopsdetect = ""
	$Spelldetect = ""

	If Not $g_bSmartQueueSystem Then Return

	SetLog("Starting Smart Queue System", $COLOR_INFO)

	If $OpenTabForQueue Then OpenArmyOverview(True, "TNRQT()")

	; Local $sArmyInfo = getArmyCampCap($aArmyCampSize[0], $aArmyCampSize[1], True)
	; Local $aGetArmyCap = StringSplit($sArmyInfo, "#")
	; If $aGetArmyCap[0] < $aGetArmyCap[2] Then
	; 	ClickP($aAway, 2, 0, "#0346")
	; 	Return False
	; EndIf

	OpenTroopsTab(False, "TNRQT()")
	$TroopCamp = GetCurrentArmy(48, 160) ; Troops
	OpenSpellsTab(False, "TNRQT()")
	$TroopCamp1 = GetCurrentArmy(45, 160) ; Spells
	If BCheckIsEmptyQueuedAndNotFullArmy() Then
		ClickP($aAway, 2, 0, "#0346")
		Return False
	EndIf

	If $g_bDebugSetlogTrain Then SetDebugLog("The Total Queue troops Quantity: " & $TroopCamp[0] & " " & $TroopCamp[1], $COLOR_DEBUG)
	If $g_bDebugSetlogTrain Then SetDebugLog("The Total Queue Spells Quantity: " & $TroopCamp1[0] & " " & $TroopCamp1[1], $COLOR_DEBUG)

	If $TroopCamp[0] <= $TroopCamp[1] And $TroopCamp1[0] <= $TroopCamp1[1] Then ; Check Total Camp
		If $g_bDebugSetlogTrain Then SetDebugLog("There are no Queue Troops And Spells !!!", $COLOR_INFO)
		ClickP($aAway, 2, 0, "#0346")
		Return False
	EndIf

	OpenTroopsTab(False, "TNRQT()")

	Local $XQueueStart = 839 ;	Troops Queue Position Check
	For $i = 0 To 10
		If _ColorCheck(_GetPixelColor(825 - $i * 70, 186, True), Hex(0xD7AFA9, 6), 20) Then ; Pink background found
			$XQueueStart -= 70.5 * $i
			ExitLoop
		ElseIf $i = 10 Then
			$XQueueStart = 18
		EndIf
	Next

	$Troopsdetect = CheckQueueTroops(True, True, $XQueueStart)
	OpenSpellsTab(False, "TNRQT()")
	$XQueueStart = 835 ;	Spells Queue Position Check
	For $i = 0 To 10
		If _ColorCheck(_GetPixelColor(825 - $i * 70, 186, True), Hex(0xD7AFA9, 6), 20) Then ; Pink background found
			$XQueueStart -= 70.5 * $i
			ExitLoop
		ElseIf $i = 10 Then
			$XQueueStart = 18
		EndIf
	Next

	$Spelldetect = CheckQueueSpells(True, True, $XQueueStart)

	If $Troopsdetect = "" And $Spelldetect = "" Then
		ClickP($aAway, 2, 0, "#0346")
		If _Sleep(2*1000) Then Return
		Return
	EndIf

	Local $TroopsToTrain = WhatToTrainQueue(False, False)
	Local $TroopsToRemove = WhatToTrainQueue(True, False)

	If ($TroopsToRemove[0][0] = "Arch" And $TroopsToRemove[0][1] = 0) And ($TroopsToTrain[0][0] = "Arch" And $TroopsToTrain[0][1] = 0) Then
		$TroopsQueueFull = True
	Else
		$TroopsQueueFull = False
	EndIf
	If $TroopsQueueFullOnly = True Then Return $TroopsQueueFull

	; If $g_bDebugSetlogTrain Then SetDebugLog("The Total Queue troops Quantity: " & $TroopCamp[0] & " " & $TroopCamp[0], $COLOR_DEBUG)
	If $Troopsdetect = "" Then SetLog("Troops are empty", $COLOR_DEBUG)
	If $TroopsToTrain[0][0] = "Arch" And $TroopsToTrain[0][1] = 0 Then
		SetLog("None Troops Left To Train", $COLOR_DEBUG)
	Else
		SetLog("Troops Left To Train : ", $COLOR_INFO)
		For $i = 0 To (UBound($TroopsToTrain) - 1)
			SetLog("  - " & $TroopsToTrain[$i][0] & ": " & $TroopsToTrain[$i][1] & "x", $COLOR_SUCCESS)
		Next
	EndIf

	If $TroopsToRemove[0][0] = "Arch" And $TroopsToRemove[0][1] = 0 Then
		SetLog("None Troops Left To Remove", $COLOR_DEBUG)
	Else
		SetLog("Troops Left To Remove : ", $COLOR_INFO)
		For $i = 0 To (UBound($TroopsToRemove) - 1)
			SetLog("  - " & $TroopsToRemove[$i][0] & ": " & $TroopsToRemove[$i][1] & "x", $COLOR_SUCCESS)
		Next
	EndIf

	If Not $g_bRunState Then Return

	If $TroopsQueueRemove Then RemoveQueueTroops($TroopsToRemove)

	If $TroopsQueueTrain = True Then
		TrainUsingWhatToTrainQueue($TroopsToTrain)
		TrainUsingWhatToTrainQueue($TroopsToTrain, True)
	EndIf
	SetLog("Smart Queue System accomplished")
	If not $OpenTabForQueue Then ClickP($aAway, 2, 0, "#0346")
	If _Sleep(2*250) Then Return

EndFunc   ;==>TNRQT

Func WhatToTrainQueue($ReturnExtraTroopsOnly = False, $bSetLog = True)
	OpenArmyTab(True, "WhatToTrainQueue()")
	Local $ToReturn[1][2] = [["Arch", 0]]
	Local $FoundRes = 0

	If $g_bIsFullArmywithHeroesAndSpells And Not $ReturnExtraTroopsOnly And IsQueueEmpty("Troops") And IsQueueEmpty("Spells") Then
		If $g_iCommandStop = 3 Or $g_iCommandStop = 0 Then
			If $g_bFirstStart Then $g_bFirstStart = False
			Return $ToReturn
		EndIf
		SetLog(" - Your Army is Full, let's Make Troops", $COLOR_INFO)
		; Elixir Troops
		$FoundRes = 0
		For $i = 0 To $eTroopCount - 1
			Local $troopIndex = $g_aiTrainOrder[$i]
			If $g_bDebugSetlogTrain Then SetDebugLog("WhatToTrainQueue i= " & $i & " $troopIndex = " & $troopIndex & " $g_aiArmyCompTroops = " & $g_asTroopShortNames[$troopIndex] & " " & $g_aiArmyCompTroops[$troopIndex] & "x" & " $Troopsdetect[$troopIndex] = " & $Troopsdetect[$troopIndex], $COLOR_DEBUG)
			If $g_aiArmyCompTroops[$troopIndex] > 0 Then
				If $g_bDebugSetlogTrain Then SetDebugLog("Check", $COLOR_DEBUG)
				If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
				$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
				$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex]
				$FoundRes += 1
			EndIf
		Next

		; Spells
		For $i = 0 To $eSpellCount - 1
			Local $BrewIndex = $g_aiBrewOrder[$i]
			If TotalSpellsToBrewInGUI() = 0 Then ExitLoop
			If $g_aiArmyCompSpells[$BrewIndex] > 0 Then
				If HowManyTimesWillBeUsed($g_asSpellShortNames[$BrewIndex]) > 0 Then
					If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex]
					$FoundRes += 1
				Else
					getArmySpells(False, False, False, False)
					If IsArray($Spelldetect) And $g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex] > 0 Then
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex]
						$FoundRes += 1
					Else
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = 9999
						$FoundRes += 1
					EndIf
				EndIf
			EndIf
		Next
		Return $ToReturn
	EndIf

	Switch $ReturnExtraTroopsOnly
		Case False
			; Check Elixir Troops Extra Quantity To Train
			$FoundRes = 0
			For $ii = 0 To $eTroopCount - 1
				If $Troopsdetect = "" Then ExitLoop
				Local $troopIndex = $g_aiTrainOrder[$ii]
				If $g_bDebugSetlogTrain Then SetDebugLog("WhatToTrainQueue i= " & $ii & " $troopIndex = " & $troopIndex & " $g_aiArmyCompTroops = " & $g_asTroopShortNames[$troopIndex] & " " & $g_aiArmyCompTroops[$troopIndex] & "x" & " $Troopsdetect[$troopIndex] = " & $Troopsdetect[$troopIndex], $COLOR_DEBUG)
				If $Troopsdetect[$troopIndex] > 0 Then
					If $g_bDebugSetlogTrain Then SetDebugLog("Check", $COLOR_DEBUG)
					If $g_aiArmyCompTroops[$troopIndex] - $Troopsdetect[$troopIndex] > 0 Then
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompTroops[$troopIndex] - $Troopsdetect[$troopIndex])
						$FoundRes += 1
					EndIf
				ElseIf $g_aiArmyCompTroops[$troopIndex] > 0 Then
					If $g_bDebugSetlogTrain Then SetDebugLog("g_aiArmyCompTroops Check", $COLOR_DEBUG)
					If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
					$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
					$ToReturn[UBound($ToReturn) - 1][1] = $g_aiArmyCompTroops[$troopIndex]
					$FoundRes += 1
				EndIf
			Next

			; Check Spells Extra Quantity To Train
			For $i = 0 To $eSpellCount - 1
				If $Spelldetect = "" Then ExitLoop
				Local $BrewIndex = $g_aiBrewOrder[$i]
				If TotalSpellsToBrewInGUI() = 0 Then ExitLoop
				If IsArray($Spelldetect) And $Spelldetect[$BrewIndex] > 0 Then
					If $g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex] > 0 Then
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex])
						$FoundRes += 1
					EndIf
				EndIf
			Next
		Case Else
			; Check Elixir Troops Extra Quantity To Remove
			$FoundRes = 0
			For $ii = 0 To $eTroopCount - 1
				If $Troopsdetect = "" Then ExitLoop
				Local $troopIndex = $g_aiTrainOrder[$ii]
				If $g_bDebugSetlogTrain Then SetDebugLog("WhatToTrainQueue i= " & $ii & " $troopIndex = " & $troopIndex & " $g_aiArmyCompTroops = " & $g_asTroopShortNames[$troopIndex] & " " & $g_aiArmyCompTroops[$troopIndex] & "x" & " $Troopsdetect[$troopIndex] = " & $Troopsdetect[$troopIndex], $COLOR_DEBUG)
				If $Troopsdetect[$troopIndex] > 0 Then
					If $g_bDebugSetlogTrain Then SetDebugLog("Check", $COLOR_DEBUG)
					If $g_aiArmyCompTroops[$troopIndex] - $Troopsdetect[$troopIndex] < 0 Then
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asTroopShortNames[$troopIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompTroops[$troopIndex] - $Troopsdetect[$troopIndex])
						$FoundRes += 1
					EndIf
				EndIf
			Next

			; Check Spells Extra Quantity To Remove
			For $i = 0 To $eSpellCount - 1
				If $Spelldetect = "" Then ExitLoop
				Local $BrewIndex = $g_aiBrewOrder[$i]
				If TotalSpellsToBrewInGUI() = 0 Then ExitLoop
				If IsArray($Spelldetect) And $Spelldetect[$BrewIndex] > 0 Then
					If $g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex] < 0 Then
						If $FoundRes > 0 Then ReDim $ToReturn[UBound($ToReturn) + 1][2]
						$ToReturn[UBound($ToReturn) - 1][0] = $g_asSpellShortNames[$BrewIndex]
						$ToReturn[UBound($ToReturn) - 1][1] = Abs($g_aiArmyCompSpells[$BrewIndex] - $Spelldetect[$BrewIndex])
						$FoundRes += 1
					EndIf
				EndIf
			Next
	EndSwitch
	Return $ToReturn
EndFunc   ;==>WhatToTrainQueue

Func RemoveQueueTroops($rWTT)

	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then
		Return True
	EndIf

	Local Const $y = 186, $yRemoveBtn = 200, $xDecreaseRemoveBtn = 10
	Local $bColorCheck = False, $bGotRemoved = False
	Local $x = 839

	OpenTroopsTab(False, "RemoveQueueTroops()")
	Local $XQueueStart = 839
	Local $vPinkPixel = MultiPSimple(840,261,18,256,Hex(0xD7AFA9, 6))
	If $vPinkPixel <> 0 Then $XQueueStart = $vPinkPixel[0]

	OpenSpellsTab(False, "RemoveQueueTroops()")
	Local $XQueueStart1 = 839
	Local $vPinkPixel1 = MultiPSimple(840,261,18,256,Hex(0xD7AFA9, 6))
	If $vPinkPixel1 <> 0 Then $XQueueStart1 = $vPinkPixel1[0]

	; Switch $g_bIsFullArmywithHeroesAndSpells
	; Case True
	For $i = 0 To (UBound($rWTT) - 1)
		Local $PositionQueue = -1
		Local $iIndex = TroopIndexLookup($rWTT[$i][0], "RemoveQueueTroops")
		Local $sRegion

		If $iIndex >= $eBarb And $iIndex <= $eIceG Then
			OpenTroopsTab(False, "RemoveQueueTroops()")
			$sRegion = "18,182," & $XQueueStart & ",261"
			$PositionQueue = FindImageInPlaces($rWTT[$i][0], $g_sImgArmyOverviewTroopQueued & $rWTT[$i][0], $sRegion);$g_sImgArmyOverviewTroopQueued & $rWTT[$i][0] becomes \imgxml\ArmyOverview\TroopQueued\Arch
		ElseIf $iIndex >= $eLSpell And $iIndex <= $eBtSpell Then
			OpenSpellsTab(False, "RemoveQueueTroops()")
			If $g_bDebugSetlogTrain Then SetDebugLog("$iIndex = " & $iIndex & "$eLSpell = " & $eLSpell & "$eTroopCount = " & $eTroopCount, $COLOR_DEBUG)
			If $g_bDebugSetlogTrain Then SetDebugLog("$g_aiArmyCompSpells [" & $iIndex - $eLSpell & "] = " & $g_aiArmyCompSpells[$iIndex - $eLSpell], $COLOR_DEBUG)
;~ 			If $g_bForceBrewSpells Then
				If $g_aiArmyCompSpells[$iIndex - $eLSpell] > 0 Then
					If $g_bDebugSetlogTrain Then SetDebugLog("Force Brew Spells is Turned On Skipping " & $rWTT[$i][0], $COLOR_INFO)
					ContinueLoop
;~ 				EndIf
			EndIf
			$sRegion = "18,182," & $XQueueStart1 & ",261"
			$PositionQueue = FindImageInPlaces($rWTT[$i][0], $g_sImgArmyOverviewSpellQueued & $rWTT[$i][0], $sRegion);$g_sImgArmyOverviewSpellQueued & $rWTT[$i][0] becomes \imgxml\ArmyOverview\SpellQueued\CSpell
		EndIf

		_ArraySort($PositionQueue)

		If $PositionQueue <> -1 And $PositionQueue <> "" And $PositionQueue <> 0 Then
			For $ii = 0 To (UBound($PositionQueue) - 1)
				Local $QCords = decodeSingleCoord($PositionQueue[$ii])
				Local $xQtnCords = 744
				Local $xQtnCordsBtn = $xQtnCords + 51
				$QCords[0] += 18
				$QCords[1] += 182
				For $x = 774 To 60 Step -70.5
					If $QCords[0] > $x And $QCords[0] < ($x + 63) Then
						$xQtnCords = $x
						$xQtnCordsBtn = $x + 51
						ExitLoop
					EndIf
				Next
				; Local $aQuantities = GetQueueQuantity($QCords, $x - 64)
				; _ArrayDisplay($aQuantities)
				Local $aQuantities = getQueueTroopsQuantity($xQtnCords, 192)
				If $g_bDebugSetlogTrain Then SetDebugLog("$aQuantities Of " & $rWTT[$i][0] & " = " & $aQuantities, $COLOR_SUCCESS)
				If $QCords[1] < 193 Or $QCords[1] > 208 Then $QCords[1] = 200
				If $g_bDebugSetlogTrain Then SetDebugLog("$xQtnCordsBtn = " & $xQtnCordsBtn & " $xQtnCords = " & $xQtnCords & " $QCords = " & $QCords[1], $COLOR_SUCCESS)
				If $aQuantities >= $rWTT[$i][1] Then
					Click($xQtnCordsBtn, $QCords[1], $rWTT[$i][1], $g_iTrainClickDelay)
					_Sleep(20)
					ExitLoop
				ElseIf $aQuantities < $rWTT[$i][1] Then
					Click($xQtnCordsBtn, $QCords[1], $aQuantities, $g_iTrainClickDelay)
					_Sleep(20)
					$rWTT[$i][1] -= $aQuantities
				EndIf
				; If $g_bDebugSetlogTrain Then SetDebugLog("  - " & $aQuantities[$ii][0], "RemoveQueueTroops " & ": " & $aQuantities[$ii][1] & "x", $COLOR_SUCCESS)
			Next
		EndIf
		_Sleep(700)
	Next
	; Case False
	; EndSwitch
EndFunc   ;==>RemoveQueueTroops

Func BCheckIsEmptyQueuedAndNotFullArmy()

	SetLog(" - Checking: Empty Queue and Not Full Army", $COLOR_ACTION1)
	Local $CheckTroop[4] = [825, 204, 0xCFCFC8, 15] ; the gray background at slot 0 troop
	Local $CheckTroop1[4] = [390, 130, 0x78BE2B, 15] ; the Green Arrow on Troop Training tab
	If Not $g_bRunState Then Return

	If Not OpenTroopsTab(False, "BCheckIsEmptyQueuedAndNotFullArmy()") Then Return

	Local $aArmyCamp = GetOCRCurrent(48, 160)
	If UBound($aArmyCamp) = 3 And $aArmyCamp[2] > 0 Then
		If _ColorCheck(_GetPixelColor($CheckTroop[0], $CheckTroop[1], True), Hex($CheckTroop[2], 6), $CheckTroop[3]) Then
			If Not _ColorCheck(_GetPixelColor($CheckTroop1[0], $CheckTroop1[1], True), Hex($CheckTroop1[2], 6), $CheckTroop1[3]) Then
				SetLog(" - Conditions met: Empty Queue and Not Full Army")
				Return True
			Else
				SetLog(" - Conditions NOT met: Empty queue and Not Full Army")
				Return False
			EndIf
		EndIf
	EndIf
EndFunc   ;==>BCheckIsEmptyQueuedAndNotFullArmy

Func BCheckIsFullQueuedAndNotFullArmy()

	SetLog(" - Checking: FULL Queue and Not Full Army", $COLOR_INFO)
	Local $CheckTroop[4] = [824, 243, 0x949522, 20] ; the green check symbol [bottom right] at slot 0 troop
	If Not $g_bRunState Then Return

	If Not OpenTroopsTab(False, "CheckIsFullQueuedAndNotFullArmy()") Then Return

	Local $aArmyCamp = GetOCRCurrent(48, 160)
	If UBound($aArmyCamp) = 3 And $aArmyCamp[2] < 0 Then
		If _ColorCheck(_GetPixelColor($CheckTroop[0], $CheckTroop[1], True), Hex($CheckTroop[2], 6), $CheckTroop[3]) Then
			SetLog(" - Conditions met: FULL Queue and Not Full Army")
			DeleteQueued("Troops")
			If _Sleep(2*500) Then Return
			$aArmyCamp = GetOCRCurrent(48, 160)
			Local $ArchToMake = $aArmyCamp[2]
			If IsArmyWindow(False, $TrainTroopsTAB) Then TrainIt($eArch, $ArchToMake, $g_iTrainClickDelay) ; PureClick($TrainArch[0], $TrainArch[1], $ArchToMake, 500)
			SetLog("Trained " & $ArchToMake & " archer(s)!")
		Else
			SetLog(" - Conditions NOT met: FULL queue and Not Full Army")
		EndIf
	EndIf

EndFunc   ;==>BCheckIsFullQueuedAndNotFullArmy

Func DragNDropQueue($reloop = 0)

	If Not $g_bSmartQueueSystem Then Return False

	If Not $g_bRunState Then Return

	If $reloop >= 3 Then
		If $g_bDebugSetlogTrain Then SetDebugLog("Tried Drag And Drop Queue 3 Time But Failed !!!", $COLOR_ERROR)
		Return False
	EndIf

	If $reloop = 0 Then SetLog("Starting Drag And Drop Queue", $COLOR_INFO)

	OpenArmyOverview(True, "DragNDropQueue()")

	Local $rWTT1 = WhatToTrain()
	Local $XQueueStart = 839
	Local $XQueueStart1 = 839
	Local $XQueueStart2 = 839
	Local $FoundRes = 0
	Local $ToTrain[1][2] = [["Arch", 0]]

	OpenTroopsTab(False, "DragNDropQueue()")
	For $i = 0 To (UBound($rWTT1) - 1)
		If $rWTT1[$i][1] < 1 Then ContinueLoop
		Local $PositionQueue = -1
		Local $iIndex = TroopIndexLookup($rWTT1[$i][0], "DragNDropQueue")
		Local $sRegion

		If $iIndex >= $eBarb And $iIndex <= $eIceG Then
			OpenTroopsTab(False, "DragNDropQueue()")
			$sRegion = "18,182," & $XQueueStart & ",261"
			$PositionQueue = FindImageInPlaces($rWTT1[$i][0], $g_sImgArmyOverviewTroopQueued & $rWTT1[$i][0], $sRegion);$g_sImgArmyOverviewTroopQueued & $rWTT1[$i][0] becomes \imgxml\ArmyOverview\TroopQueued\Arch
			$XQueueStart2 = $XQueueStart
		ElseIf $iIndex >= $eLSpell And $iIndex <= $eBtSpell Then
			OpenSpellsTab(False, "DragNDropQueue()")
			$sRegion = "18,182," & $XQueueStart1 & ",261"
			If $g_bDebugSetlogTrain Then SetDebugLog("$iIndex = " & $iIndex & "$eLSpell = " & $eLSpell & "$eTroopCount = " & $eTroopCount, $COLOR_DEBUG)
			If $g_bDebugSetlogTrain Then SetDebugLog("$g_aiArmyCompSpells [" & $iIndex - $eLSpell & "] = " & $g_aiArmyCompSpells[$iIndex - $eLSpell], $COLOR_DEBUG)
			$PositionQueue = FindImageInPlaces($rWTT1[$i][0], $g_sImgArmyOverviewSpellQueued & $rWTT1[$i][0], $sRegion);$g_sImgArmyOverviewSpellQueued & $rWTT1[$i][0] becomes \imgxml\ArmyOverview\SpellQueued\CSpell
			$XQueueStart2 = $XQueueStart1
		EndIf

		_ArraySort($PositionQueue)

		If $PositionQueue <> -1 And $PositionQueue <> "" And $PositionQueue <> 0 Then
			For $ii = 0 To (UBound($PositionQueue) - 1)
				Local $QCords = decodeSingleCoord($PositionQueue[$ii])
				Local $xQtnCords = 744
				$QCords[0] += 18
				$QCords[1] += 182
				For $x = 774 To 60 Step -70.5
					If $QCords[0] > $x And $QCords[0] < ($x + 63) Then
						$xQtnCords = $x
						ExitLoop
					EndIf
				Next
				Local $aQuantities = getQueueTroopsQuantity($xQtnCords, 192)
				If $g_bDebugSetlogTrain Then SetDebugLog("$aQuantities Of " & $rWTT1[$i][0] & " = " & $aQuantities, $COLOR_SUCCESS)
				If $g_bDebugSetlogTrain Then SetDebugLog("$QCords0 = " & $QCords[0] & " $QCords1 = " & $QCords[1] & " $XQueueStart2 = " & $XQueueStart2, $COLOR_SUCCESS)
				If $aQuantities >= $rWTT1[$i][1] Then
					Swipe($QCords[0], $QCords[1], $XQueueStart2, $QCords[1], 1000)
					$rWTT1[$i][1] -= $aQuantities
					ExitLoop
				ElseIf $aQuantities < $rWTT1[$i][1] Then
					Swipe($QCords[0], $QCords[1], $XQueueStart2, $QCords[1], 1000)
					$rWTT1[$i][1] -= $aQuantities
				EndIf
			Next
			If $rWTT1[$i][1] > 0 Then
				If $FoundRes > 0 Then ReDim $ToTrain[UBound($ToTrain) + 1][2]
				$ToTrain[UBound($ToTrain) - 1][0] = $rWTT1[$i][0]
				$ToTrain[UBound($ToTrain) - 1][1] = $rWTT1[$i][1]
				$FoundRes += 1
			EndIf
		Else
			If $FoundRes > 0 Then ReDim $ToTrain[UBound($ToTrain) + 1][2]
			$ToTrain[UBound($ToTrain) - 1][0] = $rWTT1[$i][0]
			$ToTrain[UBound($ToTrain) - 1][1] = $rWTT1[$i][1]
			$FoundRes += 1
		EndIf
		_Sleep(700)
	Next
	DragNDropTrain($ToTrain, $reloop)
	Return True
EndFunc   ;==>DragNDropQueue

Func DragNDropTrain($rWTT, $reloop)

	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then
		RemoveExtraTroopsDND()
		Return True
	EndIf

	Local $y = Random(213, 248, 1)

	OpenTroopsTab(False, "DragNDropTrain()")
	$TroopCamp = GetCurrentArmy(48, 160) ; Troops

	OpenSpellsTab(False, "DragNDropTrain()")
	$TroopCamp1 = GetCurrentArmy(45, 160) ; Spells

	If $g_bDebugSetlogTrain Then SetDebugLog("The Total Queue troops Quantity: " & $TroopCamp[0] & " " & $TroopCamp[1], $COLOR_DEBUG)
	If $g_bDebugSetlogTrain Then SetDebugLog("The Total Queue Spells Quantity: " & $TroopCamp1[0] & " " & $TroopCamp1[1], $COLOR_DEBUG)

	If $TroopCamp[0] <= $TroopCamp[1] Or $TroopCamp1[0] <= $TroopCamp1[1] Then ; Check Total Camp
		OpenTroopsTab(False, "DragNDropTrain()")
		$Troopsdetect = CheckQueueTroops(True, True)
		OpenSpellsTab(False, "DragNDropTrain()")
		$Spelldetect = CheckQueueSpells(True, True)
		Local $TroopsToRemove = WhatToTrainQueue(True, False)
		RemoveQueueTroops($TroopsToRemove)
		TrainUsingWhatToTrainQueue($rWTT)
		TrainUsingWhatToTrainQueue($rWTT, True)
	EndIf

	$reloop += 1
	RemoveExtraTroopsDND()
	DragNDropQueue($reloop)

EndFunc   ;==>DragNDropTrain

Func TrainUsingWhatToTrainQueue($rWTT, $bSpellsOnly = False)
	If Not $g_bRunState Then Return

	If UBound($rWTT) = 1 And $rWTT[0][0] = "Arch" And $rWTT[0][1] = 0 Then ; If was default Result of WhatToTrain
		Return True
	EndIf

	If Not $bSpellsOnly Then
		If Not OpenTroopsTab(False, "TrainUsingWhatToTrainQueue()") Then Return
	Else
		If Not OpenSpellsTab(False, "TrainUsingWhatToTrainQueue()") Then Return
	EndIf

	For $i = 0 To (UBound($rWTT) - 1)
		If Not $g_bRunState Then Return
		If $rWTT[$i][1] > 0 Then ; If Count to Train Was Higher Than ZERO
			If IsSpellToBrew($rWTT[$i][0]) Then
				If $bSpellsOnly Then BrewUsingWhatToTrain($rWTT[$i][0], $rWTT[$i][1])
				ContinueLoop
			Else
				If $bSpellsOnly Then ContinueLoop
			EndIf
			Local $NeededSpace = CalcNeededSpace($rWTT[$i][0], $rWTT[$i][1])
			Local $LeftSpace = LeftSpace(True)
			If Not $g_bRunState Then Return
			$LeftSpace = ($LeftSpace[1] * 2) - $LeftSpace[0]
			If $NeededSpace <= $LeftSpace Then ; If Needed Space was Equal Or Lower Than Left Space
				If Not DragIfNeeded($rWTT[$i][0]) Then
					Return False
				EndIf

				Local $iTroopIndex = TroopIndexLookup($rWTT[$i][0], "TrainUsingWhatToTrainQueue#3")

				Local $sTroopName = ($rWTT[$i][1] > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex])
				If CheckValuesCost($rWTT[$i][0], $rWTT[$i][1]) Then
					SetLog("Training " & $rWTT[$i][1] & "x " & $sTroopName, $COLOR_SUCCESS)
					TrainIt($iTroopIndex, $rWTT[$i][1], $g_iTrainClickDelay)
				Else
					SetLog("No resources to Train " & $rWTT[$i][1] & "x " & $sTroopName, $COLOR_ACTION)
					$g_bOutOfElixir = True
				EndIf
			Else ; If Needed Space was Higher Than Left Space
				Local $CountToTrain = 0
				Local $CanAdd = True
				Do
					$NeededSpace = CalcNeededSpace($rWTT[$i][0], $CountToTrain)
					If $NeededSpace <= $LeftSpace Then
						$CountToTrain += 1
					Else
						$CanAdd = False
					EndIf
				Until $CanAdd = False
				If $CountToTrain > 0 Then
					If Not DragIfNeeded($rWTT[$i][0]) Then
						Return False
					EndIf
				EndIf

				Local $iTroopIndex = TroopIndexLookup($rWTT[$i][0], "TrainUsingWhatToTrainQueue#4")

				Local $sTroopName = ($CountToTrain > 1 ? $g_asTroopNamesPlural[$iTroopIndex] : $g_asTroopNames[$iTroopIndex])
				If CheckValuesCost($rWTT[$i][0], $CountToTrain) Then
					SetLog("Training " & $CountToTrain & "x " & $sTroopName, $COLOR_SUCCESS)
					TrainIt($iTroopIndex, $CountToTrain, $g_iTrainClickDelay)
				Else
					SetLog("No resources to Train " & $CountToTrain & "x " & $sTroopName, $COLOR_ACTION)
					$g_bOutOfElixir = True
				EndIf
			EndIf
		EndIf
		If _Sleep(2*$DELAYRESPOND) Then Return ; add 5ms delay to catch TrainIt errors, and force return to back to main loop
	Next
	Return True
EndFunc   ;==>TrainUsingWhatToTrainQueue

Func RemoveExtraTroopsDND() ; Official Func Modified By Ahsan Iqbal
	Local $CounterToRemove = 0, $iResult = 0

	If Not OpenArmyTab(True, "RemoveExtraTroops()") Then Return ; was False EDITED By SM MOD
	Local $toRemove = WhatToTrain(True, False)

	If UBound($toRemove) = 1 And $toRemove[0][0] = "Arch" And $toRemove[0][1] = 0 Then Return

	Local $rGetSlotNumber = GetSlotNumber() ; Get all available Slot numbers with troops assigned on them
	Local $rGetSlotNumberSpells = GetSlotNumber(True)

	SetLog("Troops To Remove: ", $COLOR_INFO)
	$CounterToRemove = 0
	; Loop through Troops needed to get removed Just to write some Logs
	For $i = 0 To (UBound($toRemove) - 1)
		If IsSpellToBrew($toRemove[$i][0]) Then ExitLoop
		$CounterToRemove += 1
		SetLog(" - " & $g_asTroopNames[TroopIndexLookup($toRemove[$i][0])] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
	Next

	If TotalSpellsToBrewInGUI() > 0 Then
		If $CounterToRemove <= UBound($toRemove) Then
			SetLog("Spells To Remove: ", $COLOR_INFO)
			For $i = $CounterToRemove To (UBound($toRemove) - 1)
				SetLog(" - " & $g_asSpellNames[TroopIndexLookup($toRemove[$i][0]) - $eLSpell] & ": " & $toRemove[$i][1] & "x", $COLOR_SUCCESS)
			Next
		EndIf
	EndIf

	If Not _CheckPixel($aButtonEditArmy, True) Then ; If no 'Edit Army' Button found in army tab to edit troops
		SetLog("Cannot find/verify 'Edit Army' Button in Army tab", $COLOR_WARNING)
		Return False ; Exit function
	EndIf

	ClickP($aButtonEditArmy, 1) ; Click Edit Army Button
	If _Sleep(2*500) Then Return

	; Loop through troops needed to get removed
	$CounterToRemove = 0
	For $j = 0 To (UBound($toRemove) - 1)
		If IsSpellToBrew($toRemove[$j][0]) Then ExitLoop
		$CounterToRemove += 1
		For $i = 0 To (UBound($rGetSlotNumber) - 1) ; Loop through All available slots
			; $toRemove[$j][0] = Troop name, E.g: Barb, $toRemove[$j][1] = Quantity to remove
			If $toRemove[$j][0] = $rGetSlotNumber[$i] Then ; If $toRemove Troop Was the same as The Slot Troop
				Local $pos = GetSlotRemoveBtnPosition($i + 1) ; Get positions of - Button to remove troop
				ClickRemoveTroop($pos, $toRemove[$j][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
			EndIf
		Next
	Next

	If TotalSpellsToBrewInGUI() > 0 Then
		For $j = $CounterToRemove To (UBound($toRemove) - 1)
			For $i = 0 To (UBound($rGetSlotNumberSpells) - 1) ; Loop through All available slots
				; $toRemove[$j][0] = Troop name, E.g: Barb, $toRemove[$j][1] = Quantity to remove
				If $toRemove[$j][0] = $rGetSlotNumberSpells[$i] Then ; If $toRemove Troop Was the same as The Slot Troop
					Local $pos = GetSlotRemoveBtnPosition($i + 1, True) ; Get positions of - Button to remove troop
					ClickRemoveTroop($pos, $toRemove[$j][1], $g_iTrainClickDelay) ; Click on Remove button as much as needed
				EndIf
			Next
		Next
	EndIf

	If _Sleep(2*500) Then Return
	If Not _CheckPixel($aButtonRemoveTroopsOK1, True) Then; If no 'Okay' button found in army tab to save changes
		SetLog("Cannot find/verify 'Okay' Button in Army tab", $COLOR_WARNING)
		ClickP($aAway, 2, 0, "#0346") ; Click Away, Necessary! due to possible errors/changes
		If _Sleep(2*400) Then OpenArmyOverview(True, "RemoveExtraTroops()") ; Open Army Window AGAIN
		Return False ; Exit Function
	EndIf

	If Not $g_bRunState Then Return
	ClickP($aButtonRemoveTroopsOK1, 1) ; Click on 'Okay' button to save changes

	If _Sleep(2*1200) Then Return
	If Not _CheckPixel($aButtonRemoveTroopsOK2, True) Then; If no 'Okay' button found to verify that we accept the changes
		SetLog("Cannot find/verify 'Okay #2' Button in Army tab", $COLOR_WARNING)
		ClickP($aAway, 2, 0, "#0346") ;Click Away
		Return False ; Exit function
	EndIf

	ClickP($aButtonRemoveTroopsOK2, 1) ; Click on 'Okay' button to Save changes... Last button

	SetLog("All Extra troops removed", $COLOR_SUCCESS)
	If _Sleep(2*200) Then Return
	If $iResult = 0 Then $iResult = 1

	Return $iResult
 EndFunc   ;==>RemoveExtraTroopsDND

 Func LeftSpace($bReturnAll = False)
	; Need to be in 'Train Tab'
	Local $aRemainTrainSpace = GetOCRCurrent(48, 160)
	If Not $g_bRunState Then Return

	If Not $bReturnAll Then
		Return Number($aRemainTrainSpace[2])
	Else
		Return $aRemainTrainSpace
	EndIf
EndFunc   ;==>LeftSpace

Func CalcNeededSpace($Troop, $Quantity)
	If Not $g_bRunState Then Return -1

	Local $iIndex = TroopIndexLookup($Troop, "CalcNeededSpace")
	If $iIndex = -1 Then Return -1

	If $iIndex >= $eBarb And $iIndex <= $eIceG Then
		Return Number($g_aiTroopSpace[$iIndex] * $Quantity)
	EndIf

	If $iIndex >= $eLSpell And $iIndex <= $eBtSpell Then
		Return Number($g_aiSpellSpace[$iIndex - $eLSpell] * $Quantity)
	EndIf

	Return -1
EndFunc   ;==>CalcNeededSpace

Func FindImageInPlaces($sImageName, $sImageTile, $place, $bForceCaptureRegion = True, $AndroidTag = Default)
	;creates a reduced capture of the place area a finds the image in that area
	;returns string with X,Y of ACTUALL FULL SCREEN coordinates or Empty if not found
	If StringRight($sImageTile, 1) <> "*" Then $sImageTile = $sImageTile & "*" ;ADD * End of image e.g Arch* to check if multiimage (Arch_100_92.xml,Arch_100_91.xml) exist in directory will check both
	If $g_bDebugSetlog Then SetDebugLog("FindImageInPlaces : > " & $sImageName & " - " & $sImageTile & " - " & $place, $COLOR_INFO)
	Local $returnvalue = ""
	Local $aPlaces = GetRectArray($place)
	Local $sImageArea = GetDiamondFromRect($aPlaces)

	If $bForceCaptureRegion = True Then
		$sImageArea = "FV"
		_CaptureRegion2(Number($aPlaces[0]), Number($aPlaces[1]), Number($aPlaces[2]), Number($aPlaces[3]))
	EndIf
	Local $coords = findImage($sImageName, $sImageTile, $sImageArea, 10, False, $AndroidTag) ; reduce capture full image
	If $g_bDebugSetlog Then SetDebugLog("FindImageInPlaces : < $aPlaces : " & Number($aPlaces[0]) & "," & Number($aPlaces[1]) & "," & Number($aPlaces[2]) & "," & Number($aPlaces[3]) & " : " & $sImageName & " Found in $coords :" & $coords, $COLOR_INFO)
	If $coords = "" Then
		If $g_bDebugSetlog Then SetDebugLog("FindImageInPlaces : $sImageArea : " & $sImageArea & " : " & $sImageName & " NOT Found", $COLOR_INFO)
		Return ""
	EndIf
	If $bForceCaptureRegion Then
		Local $CoordsInArray = StringSplit($coords, "|", $STR_NOCOUNT) ; 2|357,33|709,33
		For $i = 1 To UBound($CoordsInArray) - 1 ;Start From 1 Index as 0 index has points value
			Local $aCoords = decodeSingleCoord($CoordsInArray[$i])
			$returnvalue &= Number($aCoords[0]) + Number($aPlaces[0]) & "," & Number($aCoords[1]) + Number($aPlaces[1]) & "|"
		Next
	Else
		Local $CoordsInArray = StringSplit($coords, "|", $STR_NOCOUNT) ; 2|357,33|709,33
		For $i = 1 To UBound($CoordsInArray) - 1 ;Start From 1 Index as 0 index has points value
			Local $aCoords = decodeSingleCoord($CoordsInArray[$i])
			$returnvalue &= Number($aCoords[0]) & "," & Number($aCoords[1]) & "|"
		Next
	EndIf
	If StringRight($returnvalue, 1) = "|" Then $returnvalue = StringLeft($returnvalue, (StringLen($returnvalue) - 1))
	If $g_bDebugSetlog Then SetDebugLog("FindImageInPlaces : < " & $sImageName & " Found in " & $returnvalue, $COLOR_INFO)
	Local $CoordsInArray = StringSplit($returnvalue, "|", $STR_NOCOUNT)
	
	Return $CoordsInArray
EndFunc   ;==>FindImageInPlaces

Func HowManyTimesWillBeUsed($Spell) ;ONLY ONLY ONLY FOR SPELLS, TO SEE IF NEEDED TO BREW, DON'T USE IT TO GET EXACT COUNT
	Local $ToReturn = -1
	If Not $g_bRunState Then Return

	$ToReturn = 2
	Return $ToReturn

	; Code For DeadBase
	If $g_abAttackTypeEnable[$DB] Then
		If $g_aiAttackAlgorithm[$DB] = 1 Then ; Scripted Attack is Selected
			$ToReturn = CountCommandsForSpell($Spell, $DB)
			If $ToReturn = 0 Then $ToReturn = -1
		Else ; Scripted Attack is NOT selected, And Starndard attacks not using Spells YET So The spell will not be used in attack
			$ToReturn = -1
		EndIf
	EndIf

	; Code For ActiveBase
	If $g_abAttackTypeEnable[$LB] Then
		If $g_aiAttackAlgorithm[$LB] = 1 Then ; Scripted Attack is Selected
			$ToReturn = CountCommandsForSpell($Spell, $LB)
			If $ToReturn = 0 Then $ToReturn = -1
		EndIf
	EndIf

	Return $ToReturn
EndFunc   ;==>HowManyTimesWillBeUsed

Func CountCommandsForSpell($Spell, $Mode)
	Local $ToReturn = 0
	Local $filename = ""
	If Not $g_bRunState Then Return
	If $Mode = $DB Then
		$filename = $g_sAttackScrScriptName[$DB]
	Else
		$filename = $g_sAttackScrScriptName[$LB]
	EndIf

	Local $rownum = 0
	If FileExists($g_sCSVAttacksPath & "\" & $filename & ".csv") Then
		Local $f, $line, $acommand, $command
		Local $value1, $Troop
		$f = FileOpen($g_sCSVAttacksPath & "\" & $filename & ".csv", 0)
		; Read in lines of text until the EOF is reached
		While 1
			$line = FileReadLine($f)
			$rownum += 1
			If @error = -1 Then ExitLoop
			$acommand = StringSplit($line, "|")
			If $acommand[0] >= 8 Then
				$command = StringStripWS(StringUpper($acommand[1]), 2)
				$Troop = StringStripWS(StringUpper($acommand[5]), 2)
				If $Troop = $Spell Then $ToReturn += 1
			EndIf
		WEnd
		FileClose($f)
	Else
		$ToReturn = 0
	EndIf
	Return $ToReturn
EndFunc   ;==>CountCommandsForSpell
; #FUNCTION# ====================================================================================================================
; Name ..........: Collect Free Magic Items from trader
; Description ...:
; Syntax ........: CollectFreeMagicItems()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018)
; Modified ......: Chill, Boldina (boludoz) - (7/5/2019), Dissociable (3/5/2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CollectFreeMagicItems($bTest = False)
	If Not BitOR($g_bChkCollectFree, $g_bChkCollectMagicItems) Then Return
	If Not $g_bRunState Then Return

	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	If (Not $bTest) And ($iLastTimeChecked[$g_iCurAccount] = @MDAY) Then Return

	ClickP($aAway, 1, 0, "#0332") ;Click Away
	If Not IsMainPage() Then Return

	Local $sSetLog = $g_bChkCollectMagicItems ? "Collecting Magic Items" : "Collecting Free Magic Items"
	SetLog($sSetLog, $COLOR_INFO)
	If _Sleep($DELAYCOLLECT2) Then Return

	; Check Trader Icon on Main Village
	If QuickMIS("BC1", $g_sImgTrader, 120, 155, 230, 250, True, False) Then
		SetLog("Trader available, Entering Daily Discounts", $COLOR_SUCCESS)
		Click($g_iQuickMISX + Random(115, 125, 1), $g_iQuickMISY + Random(150, 170, 1))
		If _Sleep(1500) Then Return
	ElseIf QuickMIS("BC1", $g_sImgTraderMod, 72, 113, 280, 220, True, False) Then
		SetLog("Trader available, Entering Daily Discounts", $COLOR_SUCCESS)
		Click($g_iQuickMISX - Random(70, 82, 1) + 72, $g_iQuickMISY + Random(0, 37, 1)  + 113)
		If _Sleep(1500) Then Return
	Else
		SetLog("Trader unavailable", $COLOR_INFO)
		Return
	EndIf

	; Check Daily Discounts Window
	If _Wait4PixelGone(430, 531, 0xF6F9EB, 15, 1500, 100, "Not Daily Discounts Window") Then
		ClickP($aAway, 1, 0, "#0332") ;Click Away
		Return False
	EndIf

	If Not $g_bRunState Then Return
	Local $aOcrPositions[3][2] = [[200, 439], [390, 439], [580, 439]]
	Local $aResults[3] = ["", "", ""]
	Local $aResultsProx[3] = ["", "", ""]

	If Not $bTest Then $iLastTimeChecked[$g_iCurAccount] = @MDAY

	_ImageSearchXML($g_sImgDirDailyDiscounts, 0, "140,230,720,485", True, False, True, 25)
	If $bTest Then _ArrayDisplay($g_aImageSearchXML)

	For $i = 0 To 2
		; Positioned precisely the item, and determines if this is enabled your purchase, if it is not enabled, add N / A, Exits the loop avoiding adding more than one item.
		For $iResult = 0 To UBound($g_aImageSearchXML) - 1
			If BitAND(($g_aImageSearchXML[$iResult][1]) > ($aOcrPositions[$i][0] - 41), ($g_aImageSearchXML[$iResult][1]) < ($aOcrPositions[$i][0] + 135)) Then
				$aResultsProx[$i] = ($g_abChkDD_Deals[GetDealIndex($g_aImageSearchXML[$iResult][0])] = True) ? ($g_aImageSearchXML[$iResult][0]) : ("#" & $i+1 & ": " & $g_aImageSearchXML[$iResult][0])
				_ArrayDelete($g_aImageSearchXML, $iResult) ; Optimization
				ExitLoop
			EndIf
		Next
		If $bTest Then _ArrayDisplay($aResultsProx)
		$aResults[$i] = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 80, 25, True)

		; 5D79C5 ; >Blue Background price
		If $aResults[$i] <> "" Then
			If (BitAND($g_bChkCollectMagicItems, $g_aImageSearchXML <> -1, 1 > StringInStr($aResultsProx[$i], "#" & $i+1), $aResultsProx[$i] <> "")) Or (BitAND($aResults[$i] = "FREE", $g_bChkCollectFree)) Then
				SetLog("Magic Item detected : " & $aResultsProx[$i], $COLOR_INFO)
				If Not $bTest Then
					Click($aOcrPositions[$i][0], $aOcrPositions[$i][1], 1, 0)
				Else
					SetLog("Daily Discounts: " & "X: " & $aOcrPositions[$i][0] & " | " & "Y: " & $aOcrPositions[$i][1], $COLOR_DEBUG)
				EndIf
				If _Sleep(200) Then Return
				If Not $bTest And $g_bChkCollectMagicItems Then
					If ConfirmPurchase() = True Then
						SetLog("Successfully purchased " & $aResultsProx[$i], $COLOR_SUCCESS)
					EndIf
				EndIf
				If _Sleep(500) Then Return
			Else
				If _ColorCheck(_GetPixelColor(200, 439 + 5, True), Hex(0x5D79C5, 6), 5) Or _ColorCheck(_GetPixelColor(200, 439 + 5, True), Hex(0x0D9A7C, 6), 5) Then
					$aResults[$i] = "(" & $aResults[$i] & " Gems)"
				Else
					$aResults[$i] = Int($aResults[$i]) > 0 ? "(No Space In Castle)" : "(Collected)"
				EndIf
			EndIf
		ElseIf $aResults[$i] = "" Then
			$aResults[$i] = "(No Gems)"
		EndIf

		If Not $g_bRunState Then Return
	Next

	SetLog("Daily Discounts: " & $aResultsProx[0] & " " & $aResults[0] & " | " & $aResultsProx[1] & " " & $aResults[1] & " | " & $aResultsProx[2] & " " & $aResults[2], $COLOR_INFO)
	ClickP($aAway, 2, 0, "#0332") ;Click Away
	If _Sleep(1000) Then Return
EndFunc   ;==>CollectFreeMagicItems

Func GetDealIndex($sName)
	Switch($sName)
		Case "TrainPotion"
			Return $g_eDDPotionTrain
		Case "ClockPotion"
			Return $g_eDDPotionClock
		Case "ResearchPotion"
			Return $g_eDDPotionResearch
		Case "ResourcePotion"
			Return $g_eDDPotionResource
		Case "BuilderPotion"
			Return $g_eDDPotionBuilder
		Case "PowerPotion"
			Return $g_eDDPotionPower
		Case "HeroPotion"
			Return $g_eDDPotionHero
		Case "WallRing"
			Local $sSearchDiamond = GetDiamondFromRect("140,240,720,485")
			If UBound(decodeSingleCoord(findImage("WallRingAmountx5", $g_sImgDDWallRingx5, $sSearchDiamond, 1, True))) > 1 Then
				Return $g_eDDWallRing5
			ElseIf UBound(decodeSingleCoord(findImage("WallRingAmountx10", $g_sImgDDWallRingx10, $sSearchDiamond, 1, True))) > 1 Then
				Return $g_eDDWallRing10
			EndIf
		Case "Shovel"
			Return $g_eDDShovel
		Case "BookHeros"
			Return $g_eDDBookHeros
		Case "BookFighting"
			Return $g_eDDBookFighting
		Case "BookSpells"
			Return $g_eDDBookSpells
		Case "BookBuilding"
			Return $g_eDDBookBuilding
		Case "RuneGold"
			Return $g_eDDRuneGold
		Case "RuneElixir"
			Return $g_eDDRuneElixir
		Case "RuneDarkElixir"
			Return $g_eDDRuneDarkElixir
		Case "RuneBBGold"
			Return $g_eDDRuneBBGold
		Case "RuneBBElixir"
			Return $g_eDDRuneBBElixir
		Case Else
			Return -1 ; error
	EndSwitch
EndFunc   ;==>GetDealIndex

Func ConfirmPurchase($bCheckOneTime = False)
	Local $i = 0
	If _Sleep($DELAYSPECIALCLICK1) Then Return False
	While 1
		Local $offColors[3][3] = [[0x0D0D0D, 65, 6], [0x659B24, 18, 39], [0x0D0D0D, 160, 40]]
		Local $ButtonPixel = _MultiPixelSearch(340, 385, 506, 461, 1, 1, Hex(0xE8E8E0, 6), $offColors, 20)
		If $g_bDebugSetlog Then SetDebugLog("ConfirmPurchase btn chk-#1: " & _GetPixelColor(340, 385 + $g_iMidOffsetY, True) & _
															", #2: " & _GetPixelColor(340 + $offColors[0][1], 385 + $offColors[0][2] + $g_iMidOffsetY, True) & _
															", #3: " & _GetPixelColor(340 + $offColors[1][1], 385 + $offColors[1][2] + $g_iMidOffsetY, True) & _
															", #4: " & _GetPixelColor(340 + $offColors[2][1], 385 + $offColors[2][2] + $g_iMidOffsetY, True), $COLOR_DEBUG)
		If IsArray($ButtonPixel) Then
			SetDebugLog("ButtonPixelLocation = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
			SetDebugLog("Pixel color found #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & _
										", #2: " & _GetPixelColor($ButtonPixel[0] + 144, $ButtonPixel[1], True) & _
										", #3: " & _GetPixelColor($ButtonPixel[0] + 13, $ButtonPixel[1] + 27, True) & _
										", #4: " & _GetPixelColor($ButtonPixel[0] + 133, $ButtonPixel[1] + 27, True), $COLOR_DEBUG)
			$ButtonPixel[0] += Random(50, 130, 1)
			$ButtonPixel[1] += Random(37, 55, 1)
			PureClick($ButtonPixel[0], $ButtonPixel[1], 1, 0)
			ExitLoop
		EndIf
		If $bCheckOneTime Then Return False ; enable external control of loop count or follow on actions, return false if not clicked
		If $i > 5 Then
			SetLog("Error: Could not Confirm Purchase", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("Confirm_ButtonCheck_")
			SetError(1, @extended, False)
			Return False
		EndIf
		$i += 1
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	WEnd
	Return True
EndFunc   ;==>ConfirmPurchase

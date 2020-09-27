Func HeroUpgrade($sModeHero = "")

	; If Not $g_bUpgradeHeroEnable Then Return

	; If Number($g_iTownHallLevel) <= 10 Then
		; SetLog("Must have TH 11 for Hero upgrade", $COLOR_ERROR)
		; Return
	; EndIf

	SetLog("Upgrade Hero")
	CheckMainScreen(False)
	If _Sleep($DELAYUPGRADEHERO2) Then Return

	;Get Hero info
	Local $sInfo = BuildingInfo(242, 520 + $g_iBottomOffsetY) ; 860x780
	If @error Then SetError(0, 0, 0)
	Local $CountGetInfo = 0
	While IsArray($sInfo) = False
		$sInfo = BuildingInfo(242, 520 + $g_iBottomOffsetY) ; 860x780
		If @error Then SetError(0, 0, 0)
		If _Sleep(100) Then Return
		$CountGetInfo += 1
		If $CountGetInfo = 50 Then Return
	WEnd
	If $g_bDebugSetlog Then SetDebugLog(_ArrayToString($sInfo, " "))
	If @error Then Return SetError(0, 0, 0)

	If $sInfo[2] <> "" Then
		$g_iHeroLevel = Number($sInfo[2]) ; grab hero level from building info array
		SetLog("Your Hero Hero Level read as: " & $g_iHeroLevel, $COLOR_SUCCESS)
	Else
		SetLog("Your Hero Level was not found!", $COLOR_INFO)
		Return
	EndIf

	If _Sleep($DELAYUPGRADEHERO1) Then Return

	;##### Get updated village elixir values
	VillageReport(True, True)
	If _Sleep($DELAYUPGRADEHERO2) Then Return
	Local $offColors[3][3] = [[0xBC5B31, 38, 32], [0xF84CF9, 72, 0], [0xF5F9F2, 79, 0]] ; 2nd pixel brown hammer, 3rd pixel pink, 4th pixel edge of button
	Local $ButtonPixel = _MultiPixelSearch(240, 563 + $g_iBottomOffsetY, 710, 620 + $g_iBottomOffsetY, 1, 1, Hex(0xF4F7F2, 6), $offColors, 30) ; first gray/white pixel of button
	If IsArray($ButtonPixel) Then
		If $g_bDebugSetlog And IsArray($ButtonPixel) Then
			SetLog("ButtonPixel = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
			SetLog("Color #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & ", #2: " & _GetPixelColor($ButtonPixel[0] + 41, $ButtonPixel[1] + 23, True) & ", #3: " & _GetPixelColor($ButtonPixel[0] + 72, $ButtonPixel[1], True) & ", #4: " & _GetPixelColor($ButtonPixel[0] + 79, $ButtonPixel[1], True), $COLOR_DEBUG)
		EndIf
		If _Sleep($DELAYUPGRADEHERO2) Then Return
		Click($ButtonPixel[0] + 20, $ButtonPixel[1] + 20, 1, 0, "#0305") ; Click Upgrade Button
		If _Sleep($DELAYUPGRADEHERO3) Then Return ; Wait for window to open
		If $g_bDebugSetlog Then DebugImageSave("UpgradeElixirBtn1")
		
		If $g_bDebugSetlog Then SetDebugLog("pixel: " & _GetPixelColor(718, 120 + $g_iMidOffsetY, True) & " expected " & Hex(0xDD0408, 6) & " result: " & _ColorCheck(_GetPixelColor(718, 120 + $g_iMidOffsetY, True), Hex(0xDD0408, 6), 20), $COLOR_DEBUG)
		
		; 1. 544, 560, E8E8E0 - If not return and set off update if th <> and not mod() <> 0.
		If _ColorCheck(_GetPixelColor(544, 560, True), Hex(0xE8E8E0, 6), 20) Then
			
			getUpgradeResources(
			
		EndIf
		;	$g_iNbrOfHeroesUpped += 1
		;	$g_iCostElixirBuilding += $g_afWardenUpgCost[$g_iWardenLevel - 1] * 1000
		;	$g_iWardenLevel += 1
		;	
		;	$g_iNbrOfHeroesUpped += 1
		;	$g_iCostDElixirHero += $g_afKingUpgCost[$aHeroLevel - 1] * 1000
		;	UpdateStats()

		Else
			SetLog("Upgrade Hero window open fail", $COLOR_ERROR)
		EndIf
	Else
		SetLog("Upgrade Hero error finding button", $COLOR_ERROR)
	EndIf

	ClickAway() ;Click Away to close windows
	CheckMainScreen(False)

EndFunc   ;==>HeroUpgrade
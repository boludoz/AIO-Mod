; #FUNCTION# ====================================================================================================================
; Name ..........: VillageReport
; Description ...: This function will report the village free and total builders, gold, elixir, dark elixir and gems.
;                  It will also update the statistics to the GUI.
; Syntax ........: VillageReport()
; Parameters ....: None
; Return values .: None
; Author ........: Hervidero (2015-feb-10)
; Modified ......: Safar46 (2015), Hervidero (2015), KnowJack (June-2015) , ProMac (2015), Sardo 2015-08, MonkeyHunter(6-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2022
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func VillageReport($bBypass = False, $bSuppressLog = False)
	ClickAway()
	If _Sleep($DELAYVILLAGEREPORT1) Then Return
	
	If $g_bpushedsharedprefs == True Then
		If PullSharedPrefs() Then
			$g_bpushedsharedprefs = False
		EndIf
	EndIf
	
	Switch $bBypass
		Case False
			If Not $bSuppressLog Then SetLog("Village Report", $COLOR_INFO)
		Case True
			If Not $bSuppressLog Then SetLog("Updating Village Resource Values", $COLOR_INFO)
		Case Else
			If Not $bSuppressLog Then SetLog("Village Report Error, You have been a BAD programmer!", $COLOR_ERROR)
	EndSwitch

	If Random(1, 100) > 75 Then
		CollectResourcesByPass()
		If _Sleep($DELAYPREPARESEARCH2) Then Return
	EndIf
	
	getBuilderCount($bSuppressLog) ; update builder data
	If _Sleep($DELAYRESPOND) Then Return
	
	_CaptureRegions()
	$g_aiCurrentLoot[$eLootTrophy] = _getTrophyMainScreen($aTrophies[0], $aTrophies[1])
	If Not $bSuppressLog Then SetLog(" [T]: " & _NumberFormat($g_aiCurrentLoot[$eLootTrophy]), $COLOR_SUCCESS)
	
	_CaptureRegion2Sync()
	If _CheckPixel($aVillageHasDarkElixir, False) Then ; check if the village have a Dark Elixir Storage
		_CaptureRegion2Sync()
		$g_aiCurrentLoot[$eLootGold] = _getResourcesMainScreen(696, 23)
		
		_CaptureRegion2Sync()
		$g_aiCurrentLoot[$eLootElixir] = _getResourcesMainScreen(696, 74)
		
		_CaptureRegion2Sync()
		$g_aiCurrentLoot[$eLootDarkElixir] = _getResourcesMainScreen(728, 123)

		_CaptureRegion2Sync()
		$g_iGemAmount = _getResourcesMainScreen(740, 171)
		
		If Not $bSuppressLog Then SetLog(" [G]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [D]: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & " [GEM]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
	Else
		$g_aiCurrentLoot[$eLootGold] = _getResourcesMainScreen(701, 23)

		_CaptureRegion2Sync()
		$g_aiCurrentLoot[$eLootElixir] = _getResourcesMainScreen(701, 74)

		_CaptureRegion2Sync()
		$g_iGemAmount = _getResourcesMainScreen(719, 123)
		
		If Not $bSuppressLog Then SetLog(" [G]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [GEM]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
		If ProfileSwitchAccountEnabled() Then $g_aiCurrentLoot[$eLootDarkElixir] = "" ; prevent applying Dark Elixir of previous account to current account
	EndIf

	If Not $bBypass Then BuilderPotionBoost() ; Magic items - Team AiO MOD++
	ClickAway()
	
	If $bBypass = False Then ; update stats
		UpdateStats()
	EndIf
	
	; Custom fix - Team AIO Mod++
	If _ColorCheck(_GetPixelColor(819, 39, True), Hex(0xF8FCFF, 6), 20) = True Then 
		Click(819, 39)
		If _Sleep($DELAYVILLAGEREPORT1) Then Return
	EndIf 
	
	; Insane and do nothing 500*20 = 10 seconds timeout
	#cs -  Custom fix - Team AIO Mod++
	Local $i = 0
	While _ColorCheck(_GetPixelColor(819, 39, True), Hex(0xF8FCFF, 6), 20) = True ; wait for Builder/shop to close
		$i += 1
		If _Sleep($DELAYVILLAGEREPORT1) Then Return
		If $i >= 20 Then ExitLoop
	WEnd
	#Ce - Custom fix - Team AIO Mod++
	
EndFunc   ;==>VillageReport

; Custom wall - Team AIO Mod++
Func VillageReportMini()
	getBuilderCount(True) ; update builder data
	; $g_aiCurrentLoot[$eLootTrophy] = getTrophyMainScreen($aTrophies[0], $aTrophies[1])
	If _CheckPixel($aVillageHasDarkElixir, $g_bCapturePixel) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(696, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(696, 74)
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(728, 123)
		; $g_iGemAmount = getResourcesMainScreen(740, 171)
	Else
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74)
		; $g_iGemAmount = getResourcesMainScreen(719, 123)
		If ProfileSwitchAccountEnabled() Then $g_aiCurrentLoot[$eLootDarkElixir] = "" ; prevent applying Dark Elixir of previous account to current account
	EndIf
EndFunc   ;==>VillageReportMini

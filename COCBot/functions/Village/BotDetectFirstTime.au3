; #FUNCTION# ====================================================================================================================
; Name ..........: BotDetectFirstTime
; Description ...: This script detects your builings on the first run
; Author ........: HungLe (04/2015)
; Modified ......: Hervidero (05/2015), HungLe (05/2015), KnowJack(07/2015), Sardo (08/2015), CodeSlinger69 (01/2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func BotDetectFirstTime()
	If $g_bIsClientSyncError Then Return ; if restart after OOS, and User stop/start bot, skip this.
	
	; Custom fix - Team AIO MOD++
	If $g_bOnlyBuilderBase = True Or $g_bStayOnBuilderBase = True Then Return
	
	ClickAway()
	If _Sleep($DELAYBOTDETECT1) Then Return

	SetLog("Detecting your Buildings", $COLOR_INFO)

	checkMainScreen()
	If $g_bRestart Then Return
	Collect(False)

	;;;;;Check Town Hall level
	Local $iTownHallLevel = $g_iTownHallLevel
	SetDebugLog("Detecting Town Hall level", $COLOR_INFO)
	SetDebugLog("Town Hall level is currently saved as " & $g_iTownHallLevel, $COLOR_INFO)
	imglocTHSearch(False, True, True) ;Sets $g_iTownHallLevel
	SetDebugLog("Detected Town Hall level is " & $g_iTownHallLevel, $COLOR_INFO)
	If $g_iTownHallLevel = $iTownHallLevel Then
		SetDebugLog("Town Hall level has not changed", $COLOR_INFO)
	Else
		If $g_iTownHallLevel < $iTownHallLevel Then
			SetDebugLog("Bad town hall level read...saving bigger old value", $COLOR_ERROR)
			$g_iTownHallLevel = $iTownHallLevel
			saveConfig()
			applyConfig()
		Else
			SetDebugLog("Town Hall level has changed!", $COLOR_INFO)
			SetDebugLog("New Town hall level detected as " & $g_iTownHallLevel, $COLOR_INFO)
			saveConfig()
			applyConfig()
		EndIf
	EndIf
	;;;;;;;;;;;;;;;;;;;;;;;;;;

	If $g_iTownHallLevel < 2 Or Not isInsideDiamond($g_aiTownHallPos) Then
		LocateTownHall(False, False)
		If _Sleep($DELAYBOTDETECT1) Then Return
		SaveConfig()
		applyConfig()
	EndIf
	
	If Number($g_iTownHallLevel) > 1 And Number($g_iTownHallLevel) < 6 Then
		SetLog("Warning: TownHall level below 6 NOT RECOMMENDED!", $COLOR_ERROR)
		SetLog("Proceed with caution as errors may occur.", $COLOR_ERROR)
	EndIf
	
	CheckImageType()
	If _Sleep($DELAYBOTDETECT1) Then Return

	If Not isInsideDiamond($g_aiClanCastlePos) Then
		LocateClanCastle(False)
		SaveConfig()
	EndIf

	If Not isInsideDiamond($g_aiLaboratoryPos) Then
		LocateLab(False)
		SaveConfig()
	EndIf

	If Number($g_iTownHallLevel) >= 14 Then
		If _Sleep($DELAYBOTDETECT3) Then Return
		If Not isInsideDiamond($g_aiPetHousePos) Then
			LocatePetHouse(False)
			SaveConfig()
		EndIf
	EndIf

	If Number($g_iTownHallLevel) >= 7 Then
		If ($g_iCmbBoostBarbarianKing > 0 Or $g_bUpgradeQueenEnable Or $g_bChkOneGemBoostHeroes) Then
			If Not isInsideDiamond($g_aiKingAltarPos) Then
				LocateKingAltar(False)
				SaveConfig()
			EndIf
		EndIf
	EndIf

	If Number($g_iTownHallLevel) >= 9 And ($g_iCmbBoostArcherQueen > 0 Or $g_bUpgradeQueenEnable Or $g_bChkOneGemBoostHeroes) Then
		If Not isInsideDiamond($g_aiQueenAltarPos) Then
			LocateQueenAltar(False)
			SaveConfig()
		EndIf
	EndIf

	If Number($g_iTownHallLevel) >= 11 And ($g_iCmbBoostWarden > 0 Or $g_bUpgradeWardenEnable Or $g_bChkOneGemBoostHeroes) Then
		If Not isInsideDiamond($g_aiWardenAltarPos) Then
			LocateWardenAltar(False)
			SaveConfig()
		EndIf
	EndIf

	If Number($g_iTownHallLevel) >= 13 And ($g_iCmbBoostChampion > 0 Or $g_bUpgradeChampionEnable Or $g_bChkOneGemBoostHeroes) Then
		If Not isInsideDiamond($g_aiChampionAltarPos) Then
			LocateChampionAltar(False)
			SaveConfig()
		EndIf
	EndIf
	
	chklocations()
	
	;Display Level TH in Stats
	GUICtrlSetData($g_hLblTHLevels, "")

	_GUI_Value_STATE("HIDE", $g_aGroupListTHLevels)
	SetDebugLog("Select TH Level:" & Number($g_iTownHallLevel), $COLOR_DEBUG)
	GUICtrlSetState($g_ahPicTHLevels[$g_iTownHallLevel], $GUI_SHOW)
	GUICtrlSetData($g_hLblTHLevels, $g_iTownHallLevel)
EndFunc   ;==>BotDetectFirstTime
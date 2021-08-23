; #FUNCTION# ====================================================================================================================
; Name ..........: OneGemBoost.au3
; Description ...: Check one gem boost.
; Author ........: Ahsan Iqbal (2018)
; Modified ......: Boldina (08/2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func OneGemBoost($bDebug = False)
	Static $aHeroBoostedStartTime[8][$eHeroCount], $aBuildingBoostedStartTime[8][3], $aLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	If $aLastTimeChecked[$g_iCurAccount] <> 0 And Not $bDebug Then
		Local $iDateCalc = _DateDiff('n', _NowCalc(), $aLastTimeChecked[$g_iCurAccount])
		If $iDateCalc <= 0 Then
			SetDebugLog("Forcing 1-Gem Event Boost Check After 2 Hours.", $COLOR_INFO)
			$g_bOneGemEventEnded = False
		EndIf
	EndIf
	If $g_bOneGemEventEnded Then
		SetLog("1-Gem Army Boost Event Ended. Skip It!", $COLOR_INFO)
		Return
	EndIf
	If $g_bChkOneGemBoostBarracks Or $g_bChkOneGemBoostSpells Or $g_bChkOneGemBoostHeroes Or $g_bChkOneGemBoostWorkshop Or $bDebug Then SetLog("Checking 1-Gem Army Event", $COLOR_INFO)
	If $g_bChkOneGemBoostHeroes Or $bDebug Then
		For $i = 0 To $eHeroCount - 1
			If $g_iHeroUpgrading[$i] <> 1 Then
				Local $iChkIfBoostHero = _DateDiff("s", $aHeroBoostedStartTime[$g_iCurAccount][$i], _NowCalc())
				If $g_bFirstStart Or $aHeroBoostedStartTime[$g_iCurAccount][$i] = "" Or $iChkIfBoostHero > 3600 Or $bDebug Then
					If CheckHeroOneGem($i, $bDebug) Then
						$aHeroBoostedStartTime[$g_iCurAccount][$i] = _NowCalc()
					EndIf
					If $g_bOneGemEventEnded Then ExitLoop
				Else
					SetDebugLog("Skip 1-Gem Boost For " & $g_asHeroNames[$i] & " $aHeroBoostedStartTime=" & $aHeroBoostedStartTime[$g_iCurAccount][$i] & ", $iChkIfBoostHero=" & $iChkIfBoostHero & " sec")
				EndIf
			Else
				SetDebugLog("Skip 1-Gem Boost Check For " & $g_asHeroNames[$i] & " as it's on upgrade.")
			EndIf
		Next
		SetDebugLog("$aHeroBoostedStartTime= " & $aHeroBoostedStartTime[$g_iCurAccount][0] & "|" & $aHeroBoostedStartTime[$g_iCurAccount][1] & "|" & $aHeroBoostedStartTime[$g_iCurAccount][2])
	EndIf
	If ($g_bChkOneGemBoostBarracks Or $g_bChkOneGemBoostSpells Or $g_bChkOneGemBoostWorkshop Or $bDebug) And Not $g_bOneGemEventEnded Then
		Local $aBoostBuildingNames = ["Barracks", "Spell Factory", "Workshop"]
		Local $aChkOneGemBoost = [$g_bChkOneGemBoostBarracks, $g_bChkOneGemBoostSpells, $g_bChkOneGemBoostWorkshop]
		For $i = 0 To 2
			Local $iChkIfBoostBuilding = _DateDiff("s", $aBuildingBoostedStartTime[$g_iCurAccount][$i], _NowCalc())
			If ($g_bFirstStart Or $aBuildingBoostedStartTime[$g_iCurAccount][$i] = "" Or $iChkIfBoostBuilding > 3600) And $aChkOneGemBoost[$i] Or $bDebug Then
				If OpenArmyOverview(False, "BoostTrainBuilding()") Then
					If BoostOneGemBuilding($aBoostBuildingNames[$i], $bDebug) Then
						$aBuildingBoostedStartTime[$g_iCurAccount][$i] = _NowCalc()
					EndIf
				EndIf
			ElseIf $aChkOneGemBoost[$i] Or $bDebug Then
				SetDebugLog("Skip 1-Gem Boost For " & $g_asHeroNames[$i] & " $aBuildingBoostedStartTime=" & $aBuildingBoostedStartTime[$g_iCurAccount][$i] & ", $iChkIfBoostBuilding=" & $iChkIfBoostBuilding & " sec")
			EndIf
		Next
		ClickAway()
		If _Sleep($DELAYBOOSTHEROES4) Then Return

		ClickAway()
		If _Sleep($DELAYBOOSTBARRACKS2) Then Return
		SetDebugLog("$aBuildingBoostedStartTime= " & $aBuildingBoostedStartTime[$g_iCurAccount][0] & "|" & $aBuildingBoostedStartTime[$g_iCurAccount][1] & "|" & $aBuildingBoostedStartTime[$g_iCurAccount][2])
	EndIf
	If $g_bOneGemEventEnded Then SetLog("1-Gem Army Boost Event Ended. Skip It!", $COLOR_INFO)
	$aLastTimeChecked[$g_iCurAccount] = _DateAdd('h', 2, _NowCalc())
EndFunc   ;==>OneGemBoost

Func CheckOneGem()
	If Number(StringStripWS(QuickMIS("OCR", $g_sImgOneGemBoostOCR, 370, 420, 500, 470), $STR_STRIPALL)) = 1 Then Return True
	SetLog("$bGemOcr Not Found", $COLOR_ERROR)
	Return False
EndFunc   ;==>CheckOneGem

Func CheckHeroOneGem($iIndex, $bDebug = False)
	Local $bHeroBoosted = False
	Local $aHerosPos[4] = [$g_aiKingAltarPos, $g_aiQueenAltarPos, $g_aiWardenAltarPos, $g_aiChampionAltarPos]

	If $iIndex >= UBound($aHerosPos) Then
		SetLog("CheckHeroOneGem bad index.", $COLOR_ERROR)
		Return $bHeroBoosted
	EndIf

	If $aHerosPos[$iIndex] = "" Or $aHerosPos[$iIndex] = -1 Then
		SetLog("Please Locate " & $g_asHeroNames[$i], $COLOR_ERROR)
		Return
	EndIf

	If _Sleep($DELAYBOOSTHEROES4) Then Return

	BuildingClickP($aHerosPos[$iIndex], "#0462")

	If _Sleep($DELAYBOOSTHEROES1) Then Return

	Local $aBoostBtn = findButton("BoostOne")
	If IsArray($aBoostBtn) Then
		If $g_bDebugSetlog Then SetDebugLog($g_asHeroNames[$iIndex] & " Boost Button X|Y = " & $aBoostBtn[0] & "|" & $aBoostBtn[1], $COLOR_DEBUG)
		ClickP($aBoostBtn)
		If _Sleep($DELAYBOOSTHEROES1) Then Return
		Local $aGemWindowBtn = findButton("GEM")
		If IsArray($aGemWindowBtn) Then
			If Not CheckOneGem() Then

				ClickAway()
				If _Sleep($DELAYBOOSTHEROES4) Then Return

				ClickAway()
				If _Sleep($DELAYBOOSTHEROES4) Then Return

				If Not $bDebug Then $g_bOneGemEventEnded = True
				Return
			EndIf
			If Not $bDebug Then
				ClickP($aGemWindowBtn)
			Else
				ClickAway()
			EndIf
			If _Sleep($DELAYBOOSTHEROES4) Then Return
			If WaitforPixel(280, 320, 310, 425, Hex(0xE0F297, 6), 25, 5) Then
				SetLog("Not enough gems to boost " & $g_asHeroNames[$iIndex], $COLOR_ERROR)
			Else
				$bHeroBoosted = True
				SetLog($g_asHeroNames[$iIndex] & " boosted successfully with 1-Gem", $COLOR_SUCCESS)
				$g_aiTimeTrain[2] = 0
			EndIf
		Else
			SetLog($g_asHeroNames[$iIndex] & " is already Boosted", $COLOR_SUCCESS)
		EndIf
	EndIf

	ClickAway()
	If _Sleep($DELAYBOOSTHEROES4) Then Return

	ClickAway()
	If _Sleep($DELAYBOOSTHEROES4) Then Return

	Return $bHeroBoosted
EndFunc   ;==>CheckHeroOneGem

Func BoostOneGemBuilding($sBoostBuildingNames, $bDebug = False)
	Local $bBuildingBoosted = False
	Local $sIsAre = "are"
	SetLog("Boosting " & $sBoostBuildingNames & " With 1-Gem", $COLOR_INFO)
	Switch $sBoostBuildingNames
		Case "Barracks"
			OpenTroopsTab(True, "BoostOneGemBuilding()")
		Case "Spell Factory"
			OpenSpellsTab(True, "BoostOneGemBuilding()")
			$sIsAre = "is"
		Case "Workshop"
			OpenSiegeMachinesTab(True, "BoostOneGemBuilding()")
			$sIsAre = "is"
		Case Else
			SetDebugLog("BoostOneGemBuilding(): $sName called with a wrong Value.", $COLOR_ERROR)
			ClickAway()
			If _Sleep($DELAYBOOSTBARRACKS2) Then Return
			Return
	EndSwitch

	Local $aBoostBtn = findButton("BoostBarrack")
	If IsArray($aBoostBtn) Then
		If $g_bDebugSetlog Then SetDebugLog($sBoostBuildingNames & " Boost Button X|Y = " & $aBoostBtn[0] & "|" & $aBoostBtn[1], $COLOR_DEBUG)
		ClickP($aBoostBtn)
		If _Sleep($DELAYBOOSTBARRACKS1) Then Return
		Local $aGemWindowBtn = findButton("GEM")
		If IsArray($aGemWindowBtn) Then
			If Not CheckOneGem() Then
				If _Sleep($DELAYBOOSTHEROES4) Then Return
				ClickAway()
				If _Sleep($DELAYBOOSTHEROES4) Then Return

				ClickAway()
				If _Sleep($DELAYBOOSTHEROES4) Then Return

				If Not $bDebug Then $g_bOneGemEventEnded = True
				Return
			EndIf
			If Not $bDebug Then
				ClickP($aGemWindowBtn)
			Else
				ClickAway()
			EndIf
			If _Sleep($DELAYBOOSTBARRACKS2) Then Return
			If WaitforPixel(280, 320, 310, 425, Hex(0xE0F297, 6), 25, 5) Then
				SetLog("Not enough gems to boost ", $COLOR_ERROR)
			Else
				$bBuildingBoosted = True
				SetLog($sBoostBuildingNames & " " & $sIsAre & " boosted successfully with 1-Gem", $COLOR_SUCCESS)
				If $sBoostBuildingNames = "Barracks" Then
					$g_aiTimeTrain[0] = 0
				ElseIf $sBoostBuildingNames = "Spell Factory" Then
					$g_aiTimeTrain[1] = 0
				ElseIf $sBoostBuildingNames = "Workshop" Then
					$g_aiTimeTrain[3] = 0
				EndIf
			EndIf
		EndIf
	Else
		If IsArray(findButton("BarrackBoosted")) Then
			SetLog($sBoostBuildingNames & " " & $sIsAre & " already boosted", $COLOR_SUCCESS)
		Else
			SetLog($sBoostBuildingNames & "boost button not found", $COLOR_ERROR)
		EndIf
	EndIf
	If _Sleep(250) Then Return
	Return $bBuildingBoosted
EndFunc   ;==>BoostOneGemBuilding
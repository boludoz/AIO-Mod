; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBotRun. Copyright 2015-2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================
Func AutoUpgrade($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = _AutoUpgrade()
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc

Func _AutoUpgrade()
	If Not $g_bAutoUpgradeEnabled Then Return

	SetLog("Starting Auto Upgrade", $COLOR_INFO)
	Local $iLoopAmount = 0
	Local $iLoopMax = 6

	While 1

		$iLoopAmount += 1
		If $iLoopAmount >= $iLoopMax Or $iLoopAmount >= 12 Then ExitLoop ; 6 loops max, to avoid infinite loop

		ClickAway()
		If _sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
		VillageReport(True, True)

		;Check if there is a free builder for Auto Upgrade
		If ($g_iFreeBuilderCount - ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0) - ReservedBuildersForHeroes()) <= 0 Then
			SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_WARNING)
			ExitLoop
		EndIf

		; check if builder head is clickable
		If Not (_ColorCheck(_GetPixelColor(275, 15, True), "F5F5ED", 20) = True) Then
			SetLog("Unable to find the Builder menu button... Exiting Auto Upgrade...", $COLOR_ERROR)
			ExitLoop
		EndIf

		; open the builders menu
		Click(295, 30)
		If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

		; search for 000 in builders menu, if 000 found, a possible upgrade is available
		If QuickMIS("BC1", $g_sImgAUpgradeZero, 180, 80 + $g_iNextLineOffset, 480, 350) Then
			SetLog("Possible upgrade found !", $COLOR_SUCCESS)
			$g_iCurrentLineOffset = $g_iNextLineOffset + $g_iQuickMISY
		Else
			SetLog("No upgrade available... Exiting Auto Upgrade...", $COLOR_INFO)
			ExitLoop
		EndIf

		; check in the line of the 000 if we can see "New" or the Gear of the equipment, in this case, will not do the upgrade
		If QuickMIS("NX",$g_sImgAUpgradeObst, 180, 80 + $g_iCurrentLineOffset - 15, 480, 80 + $g_iCurrentLineOffset + 15) <> "none" Then
			SetLog("This is a New Building or an Equipment, looking next...", $COLOR_WARNING)
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		; if it's an upgrade, will click on the upgrade, in builders menu
		Click(180 + $g_iQuickMISX, 80 + $g_iCurrentLineOffset)
		If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

		; check if any wrong click by verifying the presence of the Upgrade button (the hammer)
		Local $aUpgradeButton = findButton("Upgrade", Default, 1, True)
		If Not(IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2) Then
			SetLog("No upgrade here... Wrong click, looking next...", $COLOR_WARNING)
			;$g_iNextLineOffset = $g_iCurrentLineOffset -> not necessary finally, but in case, I keep lne commented
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
		$g_aUpgradeNameLevel = BuildingInfo(242, 490 + $g_iBottomOffsetY)
		If StringIsSpace($g_aUpgradeNameLevel[1]) Then
			SetLog("Error when trying to get upgrade name and level, looking next...", $COLOR_ERROR)
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		 ; Custom Improve - Team AIO Mod++
		Local $bMustIgnoreUpgrade = False
		Local $sEvaluateUpgrade = String($g_aUpgradeNameLevel[1])
		SetDebugLog("[_AutoUpgrade] " & $sEvaluateUpgrade)

		; It uses sensitive text with algorithm, like wikipedia bots for fix white spaces.
		Select
			Case IsHonestOCR($sEvaluateUpgrade, "Town Hall")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[0] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Gold Mine")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[1] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Elixir Collector")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[2] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Elixir Drill")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[3] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Gold Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[4] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Elixir Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[5] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Elixir Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[6] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Clan Castle")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[7] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Army Camp")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[8] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Barracks")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[9] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Barracks")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[10] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Spell Factory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[11] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Spell Factory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[12] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Laboratory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[13] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Workshop")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[14] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Pet House")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[15] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Barbarian King")
				If $g_iChkUpgradesToIgnore[16] = 1 Or $g_bUpgradeKingEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Archer Queen")
				If $g_iChkUpgradesToIgnore[17] = 1 Or $g_bUpgradeQueenEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Grand Warden")
				If $g_iChkUpgradesToIgnore[18] = 1 Or $g_bUpgradeWardenEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Royal Champion")
				If $g_iChkUpgradesToIgnore[19] = 1 Or $g_bUpgradeChampionEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Cannon")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[20] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Archer Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[21] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Mortar")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[22] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Air Defense")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[23] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Wizard Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[24] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Air Sweeper")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[25] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Hidden Tesla")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[26] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Bomb Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[27] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "X-Bow")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[28] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Inferno Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[29] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Eagle Artillery")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[30] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Scattershot")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[31] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Builder's Hut")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[32] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Wall")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[33] = 1 Or $g_bAutoUpgradeWallsEnable = True)
			Case IsHonestOCR($sEvaluateUpgrade, "Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Spring Trap") Or IsHonestOCR($sEvaluateUpgrade, "Giant Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Air Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Seeking Air Mine") Or IsHonestOCR($sEvaluateUpgrade, "Skeleton Trap") Or IsHonestOCR($sEvaluateUpgrade, "Tornado Trap")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[34] = 1)
			Case Else
				$bMustIgnoreUpgrade = False
		EndSelect

		; check if the upgrade name is on the list of upgrades that must be ignored
		If $bMustIgnoreUpgrade = True Then
			SetLog("This upgrade must be ignored, looking next...", $COLOR_WARNING)
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		; if upgrade don't have to be ignored, click on the Upgrade button to open Upgrade window
		ClickP($aUpgradeButton)
		If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return

		Switch $g_aUpgradeNameLevel[1]
			Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
				$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 690, 540, 730, 580) ; get resource
				$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(598, 522 + $g_iMidOffsetY) ; get cost
				$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(578, 465 + $g_iMidOffsetY) ; get duration
			Case Else
				$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 460, 510, 500, 550) ; get resource
				$g_aUpgradeResourceCostDuration[1] = getResourcesBonus(366, 487 + $g_iMidOffsetY) ; get cost
				$g_aUpgradeResourceCostDuration[2] = getBldgUpgradeTime(195, 307 + $g_iMidOffsetY) ; get duration
		EndSwitch

		; if one of the value is empty, there is an error, we must exit Auto Upgrade
		For $i = 0 To 2
			If $g_aUpgradeResourceCostDuration[$i] = "" Then
				SetLog("Error when trying to get upgrade details, looking next...", $COLOR_ERROR)
				$g_iNextLineOffset = $g_iCurrentLineOffset
				ContinueLoop 2
			EndIf
		Next

		Local $bMustIgnoreResource = False
		; matchmaking between resource name and the ignore list
		Switch $g_aUpgradeResourceCostDuration[0]
			Case "Gold"
				$bMustIgnoreResource = ($g_iChkResourcesToIgnore[0] = 1)
			Case "Elixir"
				$bMustIgnoreResource = ($g_iChkResourcesToIgnore[1] = 1)
			Case "Dark Elixir"
				$bMustIgnoreResource = ($g_iChkResourcesToIgnore[2] = 1)
			Case Else
				$bMustIgnoreResource = False
		EndSwitch

		; check if the resource of the upgrade must be ignored
		If $bMustIgnoreResource = True Then
			SetLog("This resource must be ignored, looking next...", $COLOR_WARNING)
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
		Local $bSufficentResourceToUpgrade = False
		; if Cost of upgrade + Value set in settings to be kept after upgrade > Current village resource, make boolean True and can continue
		Switch $g_aUpgradeResourceCostDuration[0]
			Case "Gold"
				If $g_aiCurrentLoot[$eLootGold] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinGold) Then $bSufficentResourceToUpgrade = True
			Case "Elixir"
				If $g_aiCurrentLoot[$eLootElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinElixir) Then $bSufficentResourceToUpgrade = True
			Case "Dark Elixir"
				If $g_aiCurrentLoot[$eLootDarkElixir] >= ($g_aUpgradeResourceCostDuration[1] + $g_iTxtSmartMinDark) Then $bSufficentResourceToUpgrade = True
		EndSwitch
		; if boolean still False, we can't launch upgrade, exiting...
		If Not $bSufficentResourceToUpgrade Then
            SetLog("Insufficent " & $g_aUpgradeResourceCostDuration[0] & " to launch this upgrade, looking Next...", $COLOR_WARNING)
			$g_iNextLineOffset = $g_iCurrentLineOffset
			ContinueLoop
		EndIf

		; final click on upgrade button, click coord is get looking at upgrade type (heroes have a diferent place for Upgrade button)
		Switch $g_aUpgradeNameLevel[1]
			Case "Barbarian King", "Archer Queen", "Grand Warden", "Royal Champion"
				Click(660, 560)
			Case Else
				Click(440, 530)
		EndSwitch

        ;Check for 'End Boost?' pop-up
        If _Sleep(1000) Then Return
        Local $aImgAUpgradeEndBoost = decodeSingleCoord(findImage("EndBoost", $g_sImgAUpgradeEndBoost, GetDiamondFromRect("350, 310, 570, 230"), 1, True))
        If UBound($aImgAUpgradeEndBoost) > 1 Then
            SetLog("End Boost? pop-up found", $COLOR_INFO)
            SetLog("Clicking OK", $COLOR_INFO)
            Local $aImgAUpgradeEndBoostOKBtn = decodeSingleCoord(findImage("EndBoostOKBtn", $g_sImgAUpgradeEndBoostOKBtn, GetDiamondFromRect("420, 470, 610, 380"), 1, True))
            If UBound($aImgAUpgradeEndBoostOKBtn) > 1 Then
                Click($aImgAUpgradeEndBoostOKBtn[0], $aImgAUpgradeEndBoostOKBtn[1])
                If _Sleep(1000) Then Return
            Else
                SetLog("Unable to locate OK Button", $COLOR_ERROR)
                If _Sleep(1000) Then Return
                ClickAway()
                Return
            EndIf
        EndIf

        ; Upgrade completed, but at the same line there might be more...		$g_iCurrentLineOffset -= $g_iQuickMISY
		$iLoopMax += 1

		; update Logs and History file
		SetLog("Launched upgrade of " & $g_aUpgradeNameLevel[1] & " to level " & $g_aUpgradeNameLevel[2] + 1 & " successfully !", $COLOR_SUCCESS)
		SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
		SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)

		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, _
				@CRLF & _NowDate() & " " & _NowTime() & _
				" - Upgrading " & $g_aUpgradeNameLevel[1] & _
				" to level " & $g_aUpgradeNameLevel[2] + 1 & _
				" for " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & _
				" " & $g_aUpgradeResourceCostDuration[0] & _
				" - Duration : " & $g_aUpgradeResourceCostDuration[2])

		_FileWriteLog($g_sProfileLogsPath & "\AutoUpgradeHistory.log", _
				"Upgrading " & $g_aUpgradeNameLevel[1] & _
				" to level " & $g_aUpgradeNameLevel[2] + 1 & _
				" for " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & _
				" " & $g_aUpgradeResourceCostDuration[0] & _
				" - Duration : " & $g_aUpgradeResourceCostDuration[2])

	WEnd

	; resetting the offsets of the lines
	$g_iCurrentLineOffset = 0
	$g_iNextLineOffset = 0

	SetLog("Auto Upgrade finished", $COLOR_INFO)
	ClickAway()

EndFunc   ;==>AutoUpgrade

; #cs
Func AutoUpdTest($sText = "")
		Local $bMustIgnoreUpgrade = False

		If $sText <> "" Then
			Local $aTest[3] = [1, $sText, 3]
			$g_aUpgradeNameLevel = $aTest
		Else
			$g_aUpgradeNameLevel = BuildingInfo(242, 490 + $g_iBottomOffsetY)
		EndIf

		Local $sEvaluateUpgrade = String($g_aUpgradeNameLevel[1])
		SetDebugLog("[AutoUpdtest] " & $sEvaluateUpgrade)
					
		; It uses sensitive text with algorithm, like wikipedia bots for fix white spaces.
		Select
			Case IsHonestOCR($sEvaluateUpgrade, "Town Hall")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[0] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Gold Mine")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[1] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Elixir Collector")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[2] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Elixir Drill")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[3] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Gold Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[4] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Elixir Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[5] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Elixir Storage")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[6] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Clan Castle")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[7] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Army Camp")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[8] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Barracks")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[9] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Barracks")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[10] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Dark Spell Factory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[11] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Spell Factory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[12] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Laboratory")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[13] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Workshop")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[14] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Pet House")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[15] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Barbarian King")
				If $g_iChkUpgradesToIgnore[16] = 1 Or $g_bUpgradeKingEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Archer Queen")
				If $g_iChkUpgradesToIgnore[17] = 1 Or $g_bUpgradeQueenEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Grand Warden")
				If $g_iChkUpgradesToIgnore[18] = 1 Or $g_bUpgradeWardenEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Royal Champion")
				If $g_iChkUpgradesToIgnore[19] = 1 Or $g_bUpgradeChampionEnable = True Then $bMustIgnoreUpgrade = True
			Case IsHonestOCR($sEvaluateUpgrade, "Cannon")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[20] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Archer Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[21] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Mortar")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[22] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Air Defense")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[23] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Wizard Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[24] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Air Sweeper")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[25] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Hidden Tesla")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[26] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Bomb Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[27] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "X-Bow")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[28] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Inferno Tower")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[29] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Eagle Artillery")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[30] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Scattershot")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[31] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Builder's Hut")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[32] = 1)
			Case IsHonestOCR($sEvaluateUpgrade, "Wall")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[33] = 1 Or $g_bAutoUpgradeWallsEnable = True)
			Case IsHonestOCR($sEvaluateUpgrade, "Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Spring Trap") Or IsHonestOCR($sEvaluateUpgrade, "Giant Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Air Bomb") Or IsHonestOCR($sEvaluateUpgrade, "Seeking Air Mine") Or IsHonestOCR($sEvaluateUpgrade, "Skeleton Trap") Or IsHonestOCR($sEvaluateUpgrade, "Tornado Trap")
				$bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[34] = 1)
			Case Else
				$bMustIgnoreUpgrade = False
		EndSelect

		SetLog("$bMustIgnoreUpgrade: " & $bMustIgnoreUpgrade)
		SetLog("$bMustIgnoreUpgrade: " & $sEvaluateUpgrade)

		Return $bMustIgnoreUpgrade
EndFunc
; #Ce

Func IsHonestOCR($sTring, $sItem, $iMaxDis = 1, $iEvery = 4)
	Local $iSting = Round(_Max(StringLen($sTring), StringLen($sItem)) / $iEvery)
	If $iSting < 1 Then $iSting = 1
	; SetLog("$sTring: " & $sTring)
	; SetLog("$sItem: " & $sItem)
	; SetLog("$iSting: " & $iSting)
	If _LevDis($sTring, $sItem) <= ($iMaxDis * $iSting) Then
		Return True
	EndIf
	Return False
EndFunc   ;==>IsHonestOCR

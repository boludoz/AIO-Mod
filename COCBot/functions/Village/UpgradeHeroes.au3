; #FUNCTION# ====================================================================================================================
; Name ..........: Upgrade Heroes Continuously
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: z0mbie (2015)
; Modified ......: Master1st (09/2015), ProMac (10/2015), MonkeyHunter (06/2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func UpgradeHeroes()

	If Not $g_bUpgradeKingEnable And Not $g_bUpgradeQueenEnable And Not $g_bUpgradeWardenEnable And Not $g_bUpgradeChampionEnable Then Return
	If _Sleep(500) Then Return

	checkMainScreen(False)

	If $g_bRestart Then Return

	If $g_bUpgradeKingEnable Then
		If Not isInsideDiamond($g_aiKingAltarPos) Then LocateKingAltar()
		If $g_aiKingAltarPos[0] = -1 Or $g_aiKingAltarPos[1] = -1 Then LocateKingAltar()
		SaveConfig()
	EndIf

	If $g_bUpgradeQueenEnable Then
		If Not isInsideDiamond($g_aiQueenAltarPos) Then LocateQueenAltar()
		If $g_aiQueenAltarPos[0] = -1 Or $g_aiQueenAltarPos[1] = -1 Then LocateQueenAltar()
		SaveConfig()
	EndIf

	If $g_bUpgradeWardenEnable Then
		If Not isInsideDiamond($g_aiWardenAltarPos) Then LocateWardenAltar()
		If $g_aiWardenAltarPos[0] = -1 Or $g_aiWardenAltarPos[1] = -1 Then LocateWardenAltar()
		SaveConfig()
	EndIf

	If $g_bUpgradeChampionEnable Then
		If Not isInsideDiamond($g_aiChampionAltarPos) Then LocateChampionAltar()
		If $g_aiChampionAltarPos[0] = -1 Or $g_aiChampionAltarPos[1] = -1 Then LocateChampionAltar()
		SaveConfig()
	EndIf

	SetLog("Upgrading Heroes", $COLOR_INFO)

	;Check if Auto Lab Upgrade is enabled and if a Dark Troop/Spell is selected for Upgrade. If yes, it has priority!
	If $g_bAutoLabUpgradeEnable And $g_iLaboratoryDElixirCost > 0 Then
		SetLog("Laboratory needs DE to Upgrade:  " & $g_iLaboratoryDElixirCost)
		SetLog("Skipping the Queen and King Upgrade!")
	Else
		; ### Archer Queen ###
		If $g_bUpgradeQueenEnable And BitAND($g_iHeroUpgradingBit, $eHeroQueen) <> $eHeroQueen Then
			If Not getBuilderCount() Then Return ; update builder data, return if problem
			If _Sleep($DELAYRESPOND) Then Return
			If $g_iFreeBuilderCount < 1 + ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0) Then
				SetLog("Not enough Builders available to upgrade the Archer Queen")
				Return
			EndIf
			HeroUpgrade("Queen") ; QueenUpgrade()

			If _Sleep($DELAYUPGRADEHERO1) Then Return
		EndIf
		; ### Barbarian King ###
		If $g_bUpgradeKingEnable And BitAND($g_iHeroUpgradingBit, $eHeroKing) <> $eHeroKing Then
			If Not getBuilderCount() Then Return ; update builder data, return if problem
			If _Sleep($DELAYRESPOND) Then Return
			If $g_iFreeBuilderCount < 1 + ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0) Then
				SetLog("Not enough Builders available to upgrade the Barbarian King")
				Return
			EndIf
			HeroUpgrade("King") ; KingUpgrade()

			If _Sleep($DELAYUPGRADEHERO1) Then Return
		EndIf
		; ### Royal Champion ###
		If $g_bUpgradeChampionEnable And BitAND($g_iHeroUpgradingBit, $eHeroChampion) <> $eHeroChampion Then
			If Not getBuilderCount() Then Return ; update builder data, return if problem
			If _Sleep($DELAYRESPOND) Then Return
			If $g_iFreeBuilderCount < 1 + ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0) Then
				SetLog("Not enough Builders available to upgrade the Royal Champion")
				Return
			EndIf
			HeroUpgrade("Champion") ; ChampionUpgrade()

			If _Sleep($DELAYUPGRADEHERO1) Then Return
		EndIf
	EndIf

	; ### Grand Warden ###
	;Check if Auto Lab Upgrade is enabled and if a Elixir Troop/Spell is selected for Upgrade. If yes, it has priority!
	If $g_bAutoLabUpgradeEnable And $g_iLaboratoryElixirCost > 0 Then
		SetLog("Laboratory needs Elixir to Upgrade:  " & $g_iLaboratoryElixirCost)
		SetLog("Skipping the Warden Upgrade!")
	ElseIf $g_bUpgradeWardenEnable And BitAND($g_iHeroUpgradingBit, $eHeroWarden) <> $eHeroWarden Then
		If Not getBuilderCount() Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
		If $g_iFreeBuilderCount < 1 + ($g_bAutoUpgradeWallsEnable And $g_bUpgradeWallSaveBuilder ? 1 : 0) Then
			SetLog("Not enough Builders available to upgrade the Grand Warden")
			Return
		EndIf
		HeroUpgrade("Warden") ; WardenUpgrade()
	EndIf
EndFunc   ;==>UpgradeHeroes

Func HeroUpgrade($sHero = "")
	If Not Execute("$g_bUpgrade" & $sHero & "Enable") Then Return
	If @error Then Return

	Static $s_KingMin[8] = [False, False, False, False, False, False, False, False]
	Static $s_QueenMin[8] = [False, False, False, False, False, False, False, False]
	Static $s_WardenMin[8] = [False, False, False, False, False, False, False, False]
	Static $s_ChampionMin[8] = [False, False, False, False, False, False, False, False]

	;##### Get updated village elixir values
	VillageReport(True, True)
	If _Sleep($DELAYUPGRADEHERO2) Then Return
	
	Local $vRequisite = Execute("$s_"& $sHero &"Min[$g_iCurAccount]")
	If @error Then Return
	If Not $vRequisite = False And $g_aiCurrentLoot[($sHero = "Warden") ? ($eLootElixir) : ($eLootDarkElixir)] < $vRequisite Then
		SetLog("You don't have enough resources to improve : " & $sHero & " skip.", $COLOR_INFO)
		ClickAway()
		CheckMainScreen(False)
		Return
	EndIf
	
	Local $aAltarPos = Execute("$g_ai" & $sHero & "AltarPos")
	If Not @error Then
		If $aAltarPos < 1 Then 
			SetDebugLog("Set " & $sHero & " Pos", $COLOR_ERROR)
			Return False
		EndIf
	Else
		SetDebugLog("Set " & $sHero & " Pos execute fail.", $COLOR_ERROR)
		Return False
	EndIf
	
	CheckMainScreen(False)
	SetLog("Upgrading " & $sHero, $COLOR_ACTION)
	
	BuildingClickP($aAltarPos)
	If _Sleep($DELAYUPGRADEHERO2) Then Return

	;Get Hero info
	Local $sInfo 
	Local $i = 0
	Do
		$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; 860x780
		If @error Then Return
		If _Sleep(100) Then Return
		$i += 1
	Until IsArray($sInfo) Or $i > 50
	
	If $g_bDebugSetlog Then SetDebugLog(_ArrayToString($sInfo, " "))
	If @error Then Return SetError(0, 0, 0)
	
	Local $iHeroLevel
	If $sInfo[2] <> "" Then
		$iHeroLevel = Number($sInfo[2]) ; grab hero level from building info array
		SetLog("Your Hero Level read as: " & $iHeroLevel, $COLOR_SUCCESS)
	Else
		SetLog("Your Hero Level was not found!", $COLOR_INFO)
		; ClickAway() ;Click Away to close windows
		; CheckMainScreen(False)
		; Return
	EndIf

	If _Sleep($DELAYUPGRADEHERO1) Then Return
	
	Local $aUpgradeButton = findButton("Upgrade", Default, 1, True)
	If IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2 Then
		
		If _Sleep($DELAYUPGRADEHERO2) Then Return
		ClickP($aUpgradeButton)
		If _Sleep($DELAYUPGRADEHERO3) Then Return ; Wait for window to open
		
		Local $iCost
		If _ColorCheck(_GetPixelColor(544, 560, True), Hex(0xE8E8E0, 6), 20) Then
			
			$iCost = Number(getUpgradeResources())
			If $iCost > 100 Then
				Local $aWhiteZeros = decodeSingleCoord(findImage("UpgradeWhiteZero" ,$g_sImgUpgradeWhiteZero, GetDiamondFromRect("408,519,747,606"), 1, True, Default))
				If IsArray($aWhiteZeros) And UBound($aWhiteZeros, 1) = 2 Then
					ClickP($aWhiteZeros, 1, 0) ; Click upgrade buttton
					ClickAway()

					If _Sleep($DELAYUPGRADEHERO1) Then Return
					If $g_bDebugImageSave Then SaveDebugImage("UpgradeHeroes")
					If _ColorCheck(_GetPixelColor(573, 256 + $g_iMidOffsetY, True), Hex(0xDB0408, 6), 20) Then ; Redundant Safety Check if the use Gem window opens
						SetLog("King Upgrade Fail! Gem Window popped up!", $COLOR_ERROR)
						ClickAway() ;Click Away to close windows
						CheckMainScreen(False)
						Return
					EndIf
					SetLog($sHero & " Upgrade complete", $COLOR_SUCCESS)
					$g_iNbrOfHeroesUpped += 1
					Switch $sHero
						Case "Warden"
							$g_iCostElixirBuilding += $iCost
							$g_iWardenLevel += 1
						Case Else
							$g_iCostDElixirHero += $iCost
					EndSwitch
					UpdateStats()
				EndIf
			Else
				$iCost = Number(getUpgradeResourcesRed())
				If $iCost > 100 Then
					; This is autoit AutoIt limit (Assign/eval bad work)...
					Setlog("You can't seem to improve " & $sHero & ", the goblins write down the cost for later.", $COLOR_INFO)
					Switch $sHero
						Case "King"
							$s_KingMin[$g_iCurAccount] = $iCost
						Case "Queen"
							$s_QueenMin[$g_iCurAccount] = $iCost
						Case "Warden"
							$s_WardenMin[$g_iCurAccount] = $iCost
						Case "Champion"
							$s_ChampionMin[$g_iCurAccount] = $iCost
					EndSwitch
				EndIf
			EndIf

		Else
			SetLog("Upgrade "&$sHero&" window open fail", $COLOR_ERROR)
		EndIf
	Else
		SetLog("Upgrade "&$sHero&" error finding button", $COLOR_ERROR)
	EndIf

	ClickAway() ;Click Away to close windows
	CheckMainScreen(False)

EndFunc   ;==>HeroUpgrade

Func ReservedBuildersForHeroes()
	Local $iUsedBuildersForHeroes = Number(BitAND($g_iHeroUpgradingBit, $eHeroKing) = $eHeroKing ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroQueen) = $eHeroQueen ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroWarden) = $eHeroWarden ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroChampion) = $eHeroChampion ? 1 : 0)
	If $iUsedBuildersForHeroes = 1 Then
		SetLog($iUsedBuildersForHeroes & " builder is upgrading your heroes.", $COLOR_INFO)
	Else
		SetLog($iUsedBuildersForHeroes & " builders are upgrading your heroes.", $COLOR_INFO)
	EndIf

	Local $iFreeBuildersReservedForHeroes = _Max(Number($g_iHeroReservedBuilder) - $iUsedBuildersForHeroes, 0)
	If $iFreeBuildersReservedForHeroes = 1 Then
		SetLog($iFreeBuildersReservedForHeroes & " free builder is reserved for heroes.", $COLOR_INFO)
	Else
		SetLog($iFreeBuildersReservedForHeroes & " free builders are reserved for heroes.", $COLOR_INFO)
	EndIf

	If $g_bDebugSetlog Then SetLog("HeroBuilders R|Rn|W|F: " & $g_iHeroReservedBuilder & "|" & Number($g_iHeroReservedBuilder) & "|" & $iUsedBuildersForHeroes & "|" & $iFreeBuildersReservedForHeroes, $COLOR_DEBUG)

	Return $iFreeBuildersReservedForHeroes
EndFunc   ;==>ReservedBuildersForHeroes

; #FUNCTION# ====================================================================================================================
; Name ..........: Upgrade Heroes Continuously
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: z0mbie (2015)
; Modified ......: Master1st (09/2015), ProMac (10/2015), MonkeyHunter (06/2016), Team AIO Mod++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom hero - Team AIO Mod++
Func UpgradeHeroesTime()
	Local $iSeconds = 0
	Local $sString = ""
	
	Local $sResult, $bResult, $iDateCalc
	CheckWarTime($sResult, $bResult)
	If Not @Error Then
		If $bResult Then
			$iSeconds = _DateDiff('s', _NowCalc(), $sResult)
		EndIf
	EndIf
	
	If $iSeconds < 3600 Then $iSeconds += Round(3600 * Random(1.4, 2.8)) ; 3600 Constant = 1 hour
	$g_sDateAndTimeHeroWUE = _DateAdd('s', $iSeconds, _NowCalcDate() & " " & _NowTime(5))
EndFunc   ;==>UpgradeHeroesTime

Func UpgradeHeroes()
	If $g_bRestart Then Return

	If Not $g_bUpgradeKingEnable And Not $g_bUpgradeQueenEnable And Not $g_bUpgradeWardenEnable And Not $g_bUpgradeChampionEnable Then Return
	If _Sleep(500) Then Return

	checkMainScreen(False)
	
	#Region - No Upgrade In War - Team AIO Mod++
	If $g_bNoUpgradeInWar Then
		
		#Region - Dates - Team AIO Mod++
		If _DateIsValid($g_sDateAndTimeHeroWUE) Then
			Local $iDateDiff = _DateDiff('s', _NowCalcDate() & " " & _NowTime(5), $g_sDateAndTimeHeroWUE)
			If $iDateDiff > 0 And ($g_sConstHeroWUESeconds < $iDateDiff) = False Then
				SetLog("Upgrade Heroes | You are in clan war or this is checked recently, skipped hero upgrade.", $COLOR_INFO)
				checkMainScreen(False)
				Return
			EndIf
		EndIf
		
		UpgradeHeroesTime()
		#EndRegion - Dates - Team AIO Mod++
	EndIf
	#EndRegion - No Upgrade In War - Team AIO Mod++

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
			HeroUpgrade("Queen") ; Custom hero - Team AIO Mod++

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
			HeroUpgrade("King") ; Custom hero - Team AIO Mod++

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
			HeroUpgrade("Champion") ; Custom hero - Team AIO Mod++

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
		HeroUpgrade("Warden") ; Custom hero - Team AIO Mod++
	EndIf
EndFunc   ;==>UpgradeHeroes

Func HeroUpgradeTime(ByRef $sHero, $sString = "")
	Local $aCharByChar
	Local $iSeconds = 0
	Local $sTmp = ""
	
	$aCharByChar = StringSplit($sString, "", $STR_NOCOUNT)
	
	If Not @error Then
		For $s In $aCharByChar
			If StringIsDigit($s) Then
				$sTmp &= $s
			Else
				Switch $s
					Case "m"
						$iSeconds += Number($sTmp) * 60
					Case "h"
						$iSeconds += Number($sTmp) * 3600
					Case "d"
						$iSeconds += Number($sTmp) * 86400
				EndSwitch
				$sTmp = ""
			EndIf
		Next
	EndIf

	If $iSeconds < 3600 Then $iSeconds += Round(3600 * Random(0.4, 1.8)) ; 3600 Constant = 1 hour with 40% - 180% random range.
	$sHero = _DateAdd('s', $iSeconds, _NowCalcDate() & " " & _NowTime(5))
EndFunc   ;==>HeroUpgradeTime

Global $s_KingMin[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $s_QueenMin[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $s_WardenMin[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $s_ChampionMin[8] = [0, 0, 0, 0, 0, 0, 0, 0]

Func HeroUpgrade($sHero = "")
	Local $sDateAndTime = "", $iCostHero = 0, $aAltarPos = 0
	
	Switch $sHero
		Case "King"
			If Not $g_bUpgradeKingEnable Then Return
			$sDateAndTime = $g_sDateAndTimeKing
			$aAltarPos = $g_aiKingAltarPos
		Case "Queen"
			If Not $g_bUpgradeQueenEnable Then Return
			$sDateAndTime = $g_sDateAndTimeQueen
			$aAltarPos = $g_aiQueenAltarPos
		Case "Warden"
			If Not $g_bUpgradeWardenEnable Then Return
			$sDateAndTime = $g_sDateAndTimeWarden
			$aAltarPos = $g_aiWardenAltarPos
		Case "Champion"
			If Not $g_bUpgradeChampionEnable Then Return
			$sDateAndTime = $g_sDateAndTimeChampion
			$aAltarPos = $g_aiChampionAltarPos
		Case Else
			SetLog("Invalid Hero 0x1", $COLOR_ERROR)
			Return False
	EndSwitch
	
	#Region - Dates - Team AIO Mod++
	If Not @error Then
		If _DateIsValid($sDateAndTime) Then
			Local $iDateDiff = _DateDiff('s', _NowCalcDate() & " " & _NowTime(5), $sDateAndTime)
			If $iDateDiff > 0 And ($g_sConstMaxHeroTime < $iDateDiff) = False Then
				SetLog("Hero Upgrade | We've been through here recently or " & $sHero & " is upgrading.", $COLOR_INFO)
				checkMainScreen(False)
				Return
			EndIf
		EndIf
	EndIf
	#EndRegion - Dates - Team AIO Mod++

	;##### Get updated village elixir values
	VillageReport(True, True)
	If _Sleep($DELAYUPGRADEHERO2) Then Return
	
	If @error Then Return

	For $i = 0 To $g_iTotalAcc
		If $i <> $g_iCurAccount Then ContinueLoop ; bypass Current account Or Feature disable
		
		Local $iLoot = $g_aiCurrentLoot[$eLootDarkElixir]
		Switch $sHero
			Case "King"
				$iCostHero = $s_KingMin[$i]
			Case "Queen"
				$iCostHero = $s_QueenMin[$i]
			Case "Champion"
				$iCostHero = $s_ChampionMin[$i]
			Case "Warden"
				$iCostHero = $s_WardenMin[$i]
				$iLoot = $g_aiCurrentLoot[$eLootElixir]
			Case Else
				SetLog("Invalid Hero 0x1", $COLOR_ERROR)
				Return False
		EndSwitch
		
		
		If $iCostHero = String("MAX|" & $g_iTownHallLevel) And $g_iTownHallLevel > 0 Then
			Local $a1 = StringSplit($iCostHero, "|", $STR_NOCOUNT)
			If Not @error Then
				If Number($g_iTownHallLevel) = Number($a1[1]) Then
					SetLog("Max level for this TH " & $sHero, $COLOR_SUCCESS)
					Return
				EndIf
			EndIf
		EndIf
		
		If Number($iCostHero) <= Number($iLoot) Then
			Switch $sHero
				Case "King"
					$s_KingMin[$i] = 0
				Case "Queen"
					$s_QueenMin[$i] = 0
				Case "Champion"
					$s_ChampionMin[$i] = 0
				Case "Warden"
					$s_WardenMin[$i] = 0
			EndSwitch
			
			ContinueLoop
		Else
			SetLog("You don't have enough resources to improve : " & $sHero & " skip.", $COLOR_INFO)
			Return
		EndIf
	Next

	
	CheckMainScreen(False)
	SetLog("Upgrading " & $sHero, $COLOR_ACTION)
	
	If Number($aAltarPos[0]) > 0 Then
		BuildingClickP($aAltarPos)
		
		If _Sleep($DELAYUPGRADEHERO2) Then Return
		
		;Get Hero info
		Local $sInfo
		Local $i = 0
		Do
			$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; 860x780
			If @error Then Return
			If _Sleep(500) Then Return
			$i += 1
		Until IsArray($sInfo) Or $i > 8
	EndIf

	If Not (StringInStr($sInfo[1], $sHero) > 0) Or Not (Number($aAltarPos[0]) > 0) Then
		ClickAway()
		
		Switch $sHero
			Case "King"
				_LocateKingAltar(True)
				$aAltarPos = $g_aiKingAltarPos
			Case "Queen"
				_LocateQueenAltar(True)
				$aAltarPos = $g_aiQueenAltarPos
			Case "Warden"
				_LocateWardenAltar(True)
				$aAltarPos = $g_aiWardenAltarPos
			Case "Champion"
				_LocateChampionAltar(True)
				$aAltarPos = $g_aiChampionAltarPos
		EndSwitch
		
		ClickAway()

		If Number($aAltarPos[0]) > 0 Then
			BuildingClickP($aAltarPos)
			If _Sleep($DELAYUPGRADEHERO2) Then Return
			
			$i = 0
			Do
				$sInfo = BuildingInfo(242, 490 + $g_iBottomOffsetY) ; 860x780
				If @error Then Return
				If _Sleep(500) Then Return
				$i += 1
			Until IsArray($sInfo) Or $i > 8
			
			If Not (StringInStr($sInfo[1], $sHero) > 0) Then
				SetLog("Upgrade " & $sHero & " error in hero locate (1)", $COLOR_ERROR)
				Return
			EndIf
		Else
			SetLog("Upgrade " & $sHero & " error in hero locate (2)", $COLOR_ERROR)
			Return
		EndIf
	EndIf

	If $g_bDebugSetlog Then SetDebugLog(_ArrayToString($sInfo, " "))
	If @error Then Return SetError(0, 0, 0)
	
	Local $iHeroLevel
	If $sInfo[2] <> "" Then
		$iHeroLevel = Number($sInfo[2]) ; grab hero level from building info array
		SetLog("Your Hero Level read as: " & $iHeroLevel, $COLOR_SUCCESS)
	Else
		SetLog("Your Hero Level was not found!", $COLOR_INFO)
		ClickAway() ;Click Away to close windows
		CheckMainScreen(False)
		Return
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
				Local $aWhiteZeros = decodeSingleCoord(findImage("UpgradeWhiteZero", $g_sImgUpgradeWhiteZero, GetDiamondFromRect("408,519,747,606"), 1, True, Default))
				If IsArray($aWhiteZeros) And UBound($aWhiteZeros, 1) = 2 Then
					Local $sTime = getHeroUpgradeTime(578, 465 + $g_iMidOffsetY)
					ClickP($aWhiteZeros, 1, 0) ; Click upgrade buttton
					ClickAway()

					If _Sleep($DELAYUPGRADEHERO1) Then Return
					If $g_bDebugImageSave Then SaveDebugImage("UpgradeHeroes")
					If _ColorCheck(_GetPixelColor(573, 256 + $g_iMidOffsetY, True), Hex(0xDB0408, 6), 20) Then ; Redundant Safety Check if the use Gem window opens
						SetLog($sHero & " Upgrade Fail! Gem Window popped up!", $COLOR_ERROR)
						ClickAway() ;Click Away to close windows
						CheckMainScreen(False)
						Return
					EndIf
					SetLog($sHero & " Upgrade complete", $COLOR_SUCCESS)
					$g_iNbrOfHeroesUpped += 1
					Switch $sHero
						Case "King"
							$g_iCostDElixirHero += $iCost
							HeroUpgradeTime($g_sDateAndTimeKing, $sTime)
							SetLog("Finish time: " & $g_sDateAndTimeKing, $COLOR_INFO)
						Case "Queen"
							$g_iCostDElixirHero += $iCost
							HeroUpgradeTime($g_sDateAndTimeQueen, $sTime)
							SetLog("Finish time: " & $g_sDateAndTimeQueen, $COLOR_INFO)
						Case "Warden"
							$g_iCostElixirBuilding += $iCost
							$g_iWardenCost = -1 ; Reset for walls.
							HeroUpgradeTime($g_sDateAndTimeWarden, $sTime)
							SetLog("Finish time: " & $g_sDateAndTimeWarden, $COLOR_INFO)
						Case "Champion"
							$g_iCostDElixirHero += $iCost
							HeroUpgradeTime($g_sDateAndTimeChampion, $sTime)
							SetLog("Finish time: " & $g_sDateAndTimeChampion, $COLOR_INFO)
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
							$g_iWardenCost = $iCost
						Case "Champion"
							$s_ChampionMin[$g_iCurAccount] = $iCost
					EndSwitch
				EndIf
			EndIf
		ElseIf _ColorCheck(_GetPixelColor(544, 560, True), Hex(0xE1433F, 6), 20) Then
			SetLog("Maximum " & $sHero & " level reached for this TH level.", $COLOR_ERROR)
			Switch $sHero
				Case "King"
					$s_KingMin[$g_iCurAccount] = "MAX|" & $g_iTownHallLevel
				Case "Queen"
					$s_QueenMin[$g_iCurAccount] = "MAX|" & $g_iTownHallLevel
				Case "Warden"
					$s_WardenMin[$g_iCurAccount] = "MAX|" & $g_iTownHallLevel
				Case "Champion"
					$s_ChampionMin[$g_iCurAccount] = "MAX|" & $g_iTownHallLevel
			EndSwitch
		Else
			SetLog("Upgrade " & $sHero & " window open fail", $COLOR_ERROR)
		EndIf
	Else
		SetLog("Upgrade " & $sHero & " error finding button", $COLOR_ERROR)
	EndIf

	ClickAway() ;Click Away to close windows
	; CheckMainScreen(False)
EndFunc   ;==>HeroUpgrade
#EndRegion - Custom hero - Team AIO Mod++

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

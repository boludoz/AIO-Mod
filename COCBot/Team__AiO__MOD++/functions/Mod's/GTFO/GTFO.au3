; #FUNCTION# ====================================================================================================================
; Name ..........: GTFO
; Description ...: This File contents for 'request and leave' algorithm , fast Donate'n'Train
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ProMac
; Modified ......: 06/2017 , MHK2012(05/2018), Boludoz(19/08/2018), Fahid.Mahmood(10/10/2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: ---
; ===============================================================================================================================

Global $g_iTroosNumber = 0
Global $g_iSpellsNumber = 0
Global $g_iClanlevel = 8
Global $g_OutOfTroops = False
Global $g_bSetDoubleArmy = False
Global $g_iLoop = 0
Global $g_bClanJoin = True
Global $g_bFirstHop = True
Global $g_bLeader = False
Global $g_aiDonatePixel

; Make a Main Loop , replacing the Original Main Loop / Necessary Functions : Train - Donate - CheckResourcesValues
Func MainGTFO()

	If $g_bChkUseGTFO = False Then Return

	PrepareDonateCC()
	Local $bDonateTroop = ($g_aiPrepDon[0] = 1), $bDonateAllTroop = ($g_aiPrepDon[1] = 1), _
	$bDonateSpell = ($g_aiPrepDon[2] = 1), $bDonateAllSpell = ($g_aiPrepDon[3] = 1), _
	$bDonateSiege = ($g_aiPrepDon[4] = 1), $bDonateAllSiege = ($g_aiPrepDon[5] = 1)

	Local $bDonate = BitOR($bDonateTroop, $bDonateAllTroop, $bDonateSpell, $bDonateAllSpell, $bDonateSiege, $bDonateAllSiege) > 0

	If BitAND($g_iTotalDonateStatsTroops >= $g_iDayLimitTroops and $g_iDayLimitTroops > 0, $g_iTotalDonateStatsSpells >= $g_iDayLimitSpells and $g_iDayLimitSpells > 0, _
	$g_iTotalDonateStatsSiegeMachines >= $g_iDayLimitSieges and $g_iDayLimitSieges > 0) Then

		SetLog("*** Donations : Day Limit. ***", $COLOR_ERROR)
		VillageReport()
		ProfileSwitch()
		CheckFarmSchedule()
		If ProfileSwitchAccountEnabled() Then checkSwitchAcc() ; Forced to switch
		Return False

	ElseIf BitOr(Not $g_bChkDonate, Not $bDonate, Not $g_bDonationEnabled) Then

		SetLog("*** Setup donations. ***", $COLOR_ERROR)
		VillageReport()
		ProfileSwitch()
		CheckFarmSchedule()
		If ProfileSwitchAccountEnabled() Then checkSwitchAcc() ; Forced to switch
		Return False

	EndIf

	; Donate Loop on Clan Chat
	If $g_iLoop > $g_iTxtCyclesGTFO and not $g_hExitAfterCyclesGTFO Then
		Setlog("Finished GTFO " & $g_iLoop & " Loop(s)", $COLOR_INFO)
;~ 		If $g_bClanJoin = True Then
;~ 			ClanHop()
;~ 			Return
;~ 		EndIf
	EndIf


	If $g_aiCurrentLoot[$eLootElixir] <> 0 And $g_aiCurrentLoot[$eLootElixir] < $g_iTxtMinSaveGTFO_Elixir Then
		SetLog("Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
		Return
	EndIf
	If $g_aiCurrentLoot[$eLootDarkElixir] <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] < $g_iTxtMinSaveGTFO_DE Then
		SetLog("Dark Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
		Return
	EndIf

	Local $_timer = TimerInit()
	Local $_diffTimer = 0
	Local $_bFirstLoop = True
	$g_iTroosNumber = 0
	$g_iSpellsNumber = 0

	; GTFO Main Loop
	While 1
		SetLogCentered(" GTFO v1.5 ", Default, Default, True)
		; Just a user log
		$_diffTimer = (TimerDiff($_timer) / 1000) / 60
		If Not $_bFirstLoop Then
			SetLog(" - Running GTFO for " & StringFormat("%.2f", $_diffTimer) & " min", $COLOR_DEBUG)
		EndIf

		; Function to take nmore responsive the GUI /STOP and PASUE
		If Not $g_bRunState Then Return
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkAndroidReboot() Then ContinueLoop
		; trap common error messages also check for reconnecting animation
		checkObstacles()
		; required here due to many possible exits
		checkMainScreen(False)
		; trap common error messages also check for reconnecting animation
		If isProblemAffect() Then ExitLoop
		; Early Take-A-Break detection
		checkAttackDisable($g_iTaBChkIdle)

		; Custom Train to be accurate
		VillageReport()
		$_bFirstLoop = False

		MainKickout()
		; **TODO** - verify is the train is Boosted , if is true the $g_aiTimeTrain[0] / 4 (x4 faster)

		SetLog("Let's wait for a few minutes!", $COLOR_INFO)
		Local $aRndFuncList = ['LabCheck', 'Collect', 'CheckTombs', 'CleanYard', 'CollectFreeMagicItems', "BuilderBase"]
		While $g_aiTimeTrain[0] > 10
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				__RunFunction($Index)
				If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			Next
		WEnd


		If $g_aiCurrentLoot[$eLootElixir] <> 0 And $g_aiCurrentLoot[$eLootElixir] < $g_iTxtMinSaveGTFO_Elixir Then
			SetLog("Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
			ExitLoop
		EndIf
		If $g_aiCurrentLoot[$eLootDarkElixir] <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] < $g_iTxtMinSaveGTFO_DE Then
			SetLog("Dark Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
			ExitLoop
		EndIf

		TrainGTFO()

		; Donate Loop on Clan Chat
		If Not DonateGTFO() Then
			Setlog("Finished GTFO", $COLOR_INFO)
			If $g_bChkGTFOClanHop and $g_bChkGTFOReturnClan Then LeaveClanHop()
			Return
		EndIf

		; Update the Resources values , compare with a Limit to stop The GTFO and return to Farm
		If Not IfIsToStayInGTFO() Then Return

	WEnd

EndFunc   ;==>MainGTFO

; Train Troops / Train Spells / Necessary Remain Train Time
Func TrainGTFO()

	$g_sTimeBeforeTrain = _NowCalc()
	StartGainCost()

	If $g_bQuickTrainEnable Then CheckQuickTrainTroop() ; update values of $g_aiArmyComTroops, $g_aiArmyComSpells

	CheckIfArmyIsReady()

	If $g_bQuickTrainEnable Then
		QuickTrain()
	Else
		TrainCustomArmy()
	EndIf

    TrainSiege()

	If $g_bDonationEnabled And $g_bChkDonate Then ResetVariables("donated")

	ClickP($aAway, 2, 0, "#0346") ;Click Away
	If _Sleep(500) Then Return ; Delay AFTER the click Away Prevents lots of coc restarts

	EndGainCost("Train")

EndFunc   ;==>TrainGTFO

; Open Chat / Click on Donate Button / Donate Slot 1 or 2 / Close donate window / stay on chat for [XX] remain train Troops
Func DonateGTFO()

	Opt("MouseClickDelay", 1)
	Opt("MouseClickDownDelay", 1)

	Local $_timer = TimerInit()
	Local $_diffTimer = 0, $iTime2Exit = 20
	Local $_bReturnT = False
	Local $_bReturnS = False
	Local $y = 90, $firstrun = True

	$g_OutOfTroops = False

;~ 	; Scroll Up
;~ 	ScrollUp()

	; +++++++++++++++++++++++++++++
	; MAIN DONATE LOOP ON CLAN CHAT
	; +++++++++++++++++++++++++++++
	Local $iSetLogFuse = 0
	Local $iLopardo = $g_iLoop
	Local $bFirstSub = True
	While 1
			If _Sleep(100) Then Return
				If not BitAND($g_bChkGTFOClanHop, $bFirstSub) Then ; Spend by...
						
				If $iSetLogFuse > Random(55, 100, 1) And $iLopardo <> $g_iLoop Then
					If IfIsToStayInGTFO() = False Then Return False
					TrainGTFO()
					$iLopardo = $g_iLoop
					$iSetLogFuse = 0
				EndIf
				
				Local $sDateSNew = _DateAdd('s', Ceiling(Random(25,55,1)), _NowCalc())
				
				While 1 ; Fake multitask.
					If _ColorCheck(_GetPixelColor(26, 342, True), Hex(0xEA0810, 6), 20) Then ExitLoop
					If Number(_DateDiff('s', $sDateSNew, _NowCalc())) <= 55 Then ContinueLoop
					$sDateSNew = _DateAdd('s', Ceiling(Random(25,55,1)), _NowCalc())
					SpecialAway()
					If _Sleep(Random(100,200,1)) Then Return False
				WEnd
				
				If $iSetLogFuse = 5 Then
					Setlog("Waiting chat. Training...", $COLOR_INFO)
				EndIf

				$iSetLogFuse += 1

				$g_iLoop += 1

			Else
				$g_iLoop += 1
			EndIf
			
			$bFirstSub = False


			OpenClanChat()
			If _Sleep($DELAYRUNBOT3) Then Return

			; Function to take more responsive the GUI /STOP and PASUE
			If Not $g_bRunState Then Return
			If _Sleep($DELAYRUNBOT3) Then Return

			; Verify if the remain train time is zero
			$_diffTimer = (TimerDiff($_timer) / 1000) / 60
			If $g_aiTimeTrain[0] <> 0 Then $iTime2Exit = $g_aiTimeTrain[0]
			If $g_aiTimeTrain[1] <> 0 And $g_aiTimeTrain[1] < $g_aiTimeTrain[0] Then $iTime2Exit = $g_aiTimeTrain[1]

			If $_diffTimer > $iTime2Exit Then ExitLoop


			If $g_iLoop > $g_iTxtCyclesGTFO and not $g_hExitAfterCyclesGTFO Then Return 


			$_bReturnT = False
			$_bReturnS = False
			$firstrun = False
			Setlog("Donate CC now.", $COLOR_INFO)

			PrepareDonateCC()
			Local $bDonateTroop = ($g_aiPrepDon[0] = 1), $bDonateAllTroop = ($g_aiPrepDon[1] = 1), _
			$bDonateSpell = ($g_aiPrepDon[2] = 1), $bDonateAllSpell = ($g_aiPrepDon[3] = 1), _
			$bDonateSiege = ($g_aiPrepDon[4] = 1), $bDonateAllSiege = ($g_aiPrepDon[5] = 1)

			Local $bDonate = BitOR($bDonateTroop, $bDonateAllTroop, $bDonateSpell, $bDonateAllSpell, $bDonateSiege, $bDonateAllSiege) > 0

			If BitAND($g_iTotalDonateStatsTroops >= $g_iDayLimitTroops and $g_iDayLimitTroops > 0, $g_iTotalDonateStatsSpells >= $g_iDayLimitSpells and $g_iDayLimitSpells > 0, $g_iTotalDonateStatsSiegeMachines >= $g_iDayLimitSieges and $g_iDayLimitSieges > 0) Then
				SetLog("Donate skip :  limit reached.", $COLOR_INFO)
				; LeaveClanHop()
				Return False
			ElseIf Not $g_bChkDonate Or Not $bDonate Or Not $g_bDonationEnabled Then
				If $g_bDebugSetlog Then SetDebugLog("Donate Clan Castle troops skip", $COLOR_DEBUG)
				; LeaveClanHop()
				Return False
			EndIf

			DonateCC()

			ClanHop() ; Hop!!!
;~ 			EndIf
	WEnd

	; The details differentiate me from you.
	Opt("MouseClickDelay", GetClickUpDelay())
	Opt("MouseClickDownDelay", GetClickDownDelay())

	CloseClanChat()

	If $g_iLoop > $g_iTxtCyclesGTFO and not $g_hExitAfterCyclesGTFO Then Return 
	
	Return True
EndFunc   ;==>DonateGTFO

Func ClanHop()
	If $g_bLeader Or not $g_bChkGTFOClanHop Then Return

	SetLog("Start Clan Hopping", $COLOR_INFO)
	Local $sTimeStartedHopping = _NowCalc()
	Local $iPosJoinedClans = 0, $iScrolls = 0, $iHopLoops = 0, $iErrors = 0


	$g_iCommandStop = 0 ; Halt Attacking

	While 1
		Local $bIsInClan = False

		If $iErrors >= 10 Then
			SetLog("Too Many Errors occured in current ClanHop Loop. Leaving ClanHopping!", $COLOR_ERROR)
			CloseClanChat()
			ExitLoop
		EndIf

		If not OpenClanChat() Then
			SetLog("ClanHop | OpenClanChat fail.", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf

		; Check rules
		UnderstandChatRules()

		#Region - If not is in clan
		If _Wait4PixelGoneArray($g_aIsClanChat) And _Wait4PixelArray($g_aClanBadgeNoClan) Then ; If not Still in Clan
			;CLick on green button if you dont is on clan, It is way 2
			Click(Random(104, 216, 1), Random(471, 515, 1))
			If _Sleep(250) Then Return
		EndIf
		#EndRegion

		#Region - If is in clan
		If _Wait4PixelArray($g_aIsClanChat) Then ; If Still in Clan
			$bIsInClan = True
			SetLog("Still in a Clan! Leaving the Clan now")
			ClickP($g_aIsClanChat)

			#Region - ClanHop return to clan alternative
			If $g_bFirstHop = True and $g_bChkGTFOReturnClan = True Then
				If _Wait4PixelArray($g_aShare) Then
					ClickP($g_aShare)
				Else
					SetLog("No Share Button", $COLOR_ERROR)
					Return False
				EndIf

				If _Wait4PixelArray($g_aCopy) Then
					Local $sData = ""
					ClickP($g_aCopy)
					Local $sData = ClipGet()
					If _Sleep(250) Then Return
					GUICtrlSetData($g_hTxtClanID, $sData)
					$g_sTxtClanID = $sData
					$g_bFirstHop = False
				Else
					SetLog("No Copy Button", $COLOR_ERROR)
					Return False
				EndIf
			EndIf
			#EndRegion


			If _Wait4PixelArray($g_aClanPage) Then
				; Click clans label, It is way 1
				ClickP($g_aClanLabel)
			Else
				SetLog("Clan Page did not open! Starting over again", $COLOR_ERROR)
				$iErrors += 1
				ContinueLoop
				;Setlog("GTFO|Error or you are a clan leader.", $COLOR_ERROR)
				;$g_bLeader = True
				;$sClanJoin = False
				;Return False
			EndIf
		EndIf
		#EndRegion

		If _Sleep(1500) Then Return

		; Open clans page
		Local $aIsOnClanLabel = [640, 205, 0xDDF685, 20]
		Local $aClansBtns = [359, 302, 0xBABB9C, 20]
		If _Wait4PixelArray($g_aClanLabel) Then
				; Announcement blue on clans page click
				Local $aBlueAnnouncementClick = [658, 283, 0xB9E484, 20]
				If _Wait4PixelArray($aIsOnClanLabel) Then
					ClickP($aBlueAnnouncementClick)
					If _Sleep(100) Then Return
				EndIf

				; Click on random clan
				If _Wait4PixelArray($aClansBtns) Then
					Click(295, 360 + (68 * Random(0, 6, 1)))
					Else
					$iErrors += 1
					ContinueLoop
				EndIf

				If _Sleep(100) Then Return

				If MultiPSimple(698, 397, 826, 426, Hex(0xDAF582, 6), 15) <> 0 Then
					Click(Random(698, 826, 1), Random(397, 426, 1))
					Else
					$iErrors += 1
					ContinueLoop
				EndIf

				If _Sleep(1000) Then Return

				If $bIsInClan Then ClickOkay("ClanHop")

				If _Sleep(1000) Then Return
				If $bIsInClan Then SetLog("GTFO|Leaved the clan for another.", $COLOR_INFO)

				;If OpenClanChat() Then
				If UnderstandChatRules() And OpenClanChat() Then
					Return True
				EndIf
			Else
			$iErrors += 1
			ContinueLoop
		EndIf
	WEnd

	Setlog("ClanSaveAndJoiner|End ERROR", $COLOR_ERROR)
	Return False

	ClickAwayChat(400)
EndFunc   ;==>ClanHop

Func LeaveClanHop()
	If not $g_bChkGTFOReturnClan Then Return

	OpenClanChat()

    Local $aSendRequest[4] = [528, 213, 0xE2F98A, 20]
	Local $g_aNoClanBtn[4] = [163, 515, 0x6DBB1F, 20] ; OK - Green Join Button on Chat Tab when you are not in a Clan

	Setlog("GTFO|Joining to native clan.", $COLOR_INFO)
	Local $g_sTxtClanID = GUICtrlRead($g_hTxtClanID)
	Local $sClaID = StringReplace($g_sTxtClanID, "#", "")
	Setlog("Send : " & $sClaID, $COLOR_INFO)
	AndroidAdbSendShellCommand("am start -n com.supercell.clashofclans/com.supercell.clashofclans.GameApp -a android.intent.action.VIEW -d 'https://link.clashofclans.com/?action=OpenClanProfile&tag=" & $sClaID & "'", Default)
	Setlog("Wait", $COLOR_INFO)
	If _Sleep(5500) Then Return
	$g_bLeader = True
	ClickP($g_aNoClanBtn)
	If _Sleep(200) Then Return
	ClickP($aSendRequest)

	Local $i = 10

	While $i > 0
		If ClickOkay("ClanHop") Then ExitLoop
		If _Sleep(1000) Then Return False
		$i -= 1
	WEnd

	If _Sleep(1000) Then Return False

	CloseClanChat()
	If ProfileSwitchAccountEnabled() Then checkSwitchAcc() ; Forced to switch
EndFunc ;==> LeaveClanHop

Func ClickAwayChat($iSleep = 10)
	If _Sleep($iSleep) Then Return False
	Return SpecialAway()
EndFunc   ;==>ClickAwayChat

; Will update the Stats and check the resources to exist from GTFO and Farm again
Func IfIsToStayInGTFO()
	; **TODO**
	; Main page
	; Report village
	; check values to keep
	; return false or true

	If _Sleep(2000) Then Return
	checkMainScreen(False)
	VillageReport()

	If $g_aiCurrentLoot[$eLootElixir] <> 0 And $g_aiCurrentLoot[$eLootElixir] < $g_iTxtMinSaveGTFO_Elixir Then
		SetLog("Reach the Elixir Limit , Let's Farm!!", $COLOR_INFO)
		; Force double army on GTFO
		If $g_bTotalCampForced = True And $g_bSetDoubleArmy Then
			$g_iTotalCampSpace = Number($g_iTotalCampForcedValue) / 2
			For $T = 0 To $eTroopCount - 1
				If $g_aiArmyCompTroops[$T] <> 0 Then
					$g_aiArmyCompTroops[$T] = $g_aiArmyCompTroops[$T] / 2
					SetLog("Set " & $g_asTroopShortNames[$T] & " To  [" & $g_aiArmyCompTroops[$T] & "]", $COLOR_INFO)
				EndIf
			Next
			SetLog("Set Custom Train to One Army to Farm [" & $g_iTotalCampSpace & "]", $COLOR_INFO)
		EndIf
		Return False
	ElseIf $g_aiCurrentLoot[$eLootDarkElixir] <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] < $g_itxtMinSaveGTFO_DE Then
		SetLog("Reach the Dark Elixir Limit , Let's Farm!!", $COLOR_INFO)
		; Force double army on GTFO
		If $g_bTotalCampForced And $g_bSetDoubleArmy Then
			$g_iTotalCampSpace = Number($g_iTotalCampForcedValue) / 2
			For $T = 0 To $eTroopCount - 1
				If $g_aiArmyCompTroops[$T] <> 0 Then
					$g_aiArmyCompTroops[$T] = $g_aiArmyCompTroops[$T] / 2
					SetLog("Set " & $g_asTroopShortNames[$T] & " To  [" & $g_aiArmyCompTroops[$T] & "]", $COLOR_INFO)
				EndIf
			Next
			SetLog("Set Custom Train to One Army to Farm [" & $g_iTotalCampSpace & "]", $COLOR_INFO)
		EndIf
		Return False
	EndIf

	Return True
EndFunc   ;==>IfIsToStayInGTFO


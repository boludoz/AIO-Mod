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
Global $g_iLoop2 = 0
Global $g_bClanJoin = True
Global $g_bFirstHop = True
Global $g_bLeader = False
Global $g_aiDonatePixel
; Make a Main Loop , replacing the Original Main Loop / Necessary Functions : Train - Donate - CheckResourcesValues
Func MainGTFO()

	If $g_bChkUseGTFO = False Then Return

	; Donate Loop on Clan Chat
	If $g_iLoop2 > $g_iTxtCyclesGTFO Then
		Setlog("Finished GTFO " & $g_iLoop2 & " Loop(s)", $COLOR_INFO)
		If $g_bClanJoin = True Then
			ClanHop(True)
			Return
		EndIf
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
		TrainGTFO()
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

		VillageReport()

		If $g_aiCurrentLoot[$eLootElixir] <> 0 And $g_aiCurrentLoot[$eLootElixir] < $g_iTxtMinSaveGTFO_Elixir Then
			SetLog("Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
			ExitLoop
		EndIf
		If $g_aiCurrentLoot[$eLootDarkElixir] <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] < $g_iTxtMinSaveGTFO_DE Then
			SetLog("Dark Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
			ExitLoop
		EndIf

		; Donate Loop on Clan Chat
		Local $bDonate = DonateGTFO()
		If Not $bDonate Then
			Setlog("Finished GTFO", $COLOR_INFO)
			If $g_bClanJoin = True Then
				ClanHop($g_bClanJoin)
				$g_bClanJoin = False
				Return
			EndIf
			Return
		EndIf

		; Update the Resources values , compare with a Limit to stop The GTFO and return to Farm
		If Not IfIsToStayInGTFO() Then
			; TurnOFF the GTFO
			; $g_ichkGTFO = false
			Return
		EndIf
	WEnd

EndFunc   ;==>MainGTFO

; Train Troops / Train Spells / Necessary Remain Train Time
Func TrainGTFO()

	; Check Resources values
	StartGainCost()
	If Not $g_bRunState Then Return


	If $g_bDoubleTrain Then
		DoubleTrain()
		Return
	EndIf

	; Is necessary to be Custom Train Troops to be accurate
	If Not OpenArmyOverview(True, "TrainGTFO()") Then Return

	If _Sleep(250) Then Return

	CheckArmyCamp(False, False, False, True)

	If Not $g_bRunState Then Return
	Local $rWhatToTrain = WhatToTrain(True, False) ; r in First means Result! Result of What To Train Function
	Local $rRemoveExtraTroops = RemoveExtraTroops($rWhatToTrain)

	If $rRemoveExtraTroops = 1 Or $rRemoveExtraTroops = 2 Then
		CheckArmyCamp(False, False, False, True)
		If $g_bFullArmy Then
			SetLog("- Your Army is Full , let's Donate", $COLOR_INFO)
			If $g_bFirstStart Then $g_bFirstStart = False
			Return
		EndIf
	EndIf

	If Not $g_bRunState Then Return

	If $rRemoveExtraTroops = 2 Then
		$rWhatToTrain = WhatToTrain(False, False)
		TrainUsingWhatToTrain($rWhatToTrain)
	EndIf
	If _Sleep($DELAYRESPOND) Then Return

	If IsQueueEmpty("Troops") Then
		If Not $g_bRunState Then Return
		If Not OpenArmyTab(True, "TrainGTFO()") Then Return

		$rWhatToTrain = WhatToTrain(False, False)
		TrainUsingWhatToTrain($rWhatToTrain)
	Else
		If Not $g_bRunState Then Return
		If Not OpenArmyTab(True, "TrainGTFO()") Then Return
	EndIf
	If _Sleep($DELAYRESPOND) Then Return

	$rWhatToTrain = WhatToTrain(False, False)
	If DoWhatToTrainContainSpell($rWhatToTrain) Then
		If IsQueueEmpty("Spells") Then
			TrainUsingWhatToTrain($rWhatToTrain, True)
		Else
			If Not OpenArmyTab(True, "TrainGTFO()") Then Return
		EndIf
	EndIf

	If Not OpenArmyTab(True, "TrainGTFO()") Then Return

	; After the train ...get the remain times
	CheckArmyCamp(False, False, False, True)

	If _Sleep(250) Then Return
	If Not $g_bRunState Then Return
	ClickP($aAway, 2, 0, "#0346") ;Click Away
	If _Sleep(250) Then Return

	EndGainCost("Train")

EndFunc   ;==>TrainGTFO

; Open Chat / Click on Donate Button / Donate Slot 1 or 2 / Close donate window / stay on chat for [XX] remain train Troops
Func DonateGTFO()

	AutoItSetOption("MouseClickDelay", 1)
	AutoItSetOption("MouseClickDownDelay", 1)

	Local $_timer = TimerInit()
	Local $_diffTimer = 0, $iTime2Exit = 20
	Local $_bReturnT = False
	Local $_bReturnS = False
	Local $y = 90, $firstrun = True

	$g_OutOfTroops = False

	; Open CHAT
	OpenClanChat()

	If _Sleep($DELAYRUNBOT3) Then Return

;~ 	; Scroll Up
;~ 	ScrollUp()

	; +++++++++++++++++++++++++++++
	; MAIN DONATE LOOP ON CLAN CHAT
	; +++++++++++++++++++++++++++++
	While 1

		; Function to take nmore responsive the GUI /STOP and PASUE
		If Not $g_bRunState Then Return
		If _Sleep($DELAYRUNBOT3) Then Return

		If $y < 620 And Not $firstrun Then
			$y += 30
		Else
			; Scroll Up
			ScrollUp()

			$y = 90
		EndIf

		; Verify if the remain train time is zero
		$_diffTimer = (TimerDiff($_timer) / 1000) / 60
		If $g_aiTimeTrain[0] <> 0 Then $iTime2Exit = $g_aiTimeTrain[0]
		If $g_aiTimeTrain[1] <> 0 And $g_aiTimeTrain[1] < $g_aiTimeTrain[0] Then $iTime2Exit = $g_aiTimeTrain[1]

		If $_diffTimer > $iTime2Exit Then ExitLoop

	If $g_iLoop2 > $g_iTxtCyclesGTFO Then
		LeaveClanHop()
		Return False
	EndIf

		; +++++++++++++++++++++++++
		; DONATE IT - WHEN EXIST REQUESTS
		; +++++++++++++++++++++++++
		While 1
			$g_iLoop += 1
			$g_iLoop2 += 1
			If $g_iLoop2 > $g_iTxtCyclesGTFO Then
				LeaveClanHop()
				Return False
			EndIf
			If $g_iLoop >= 2 Then ExitLoop

			$_bReturnT = False
			$_bReturnS = False
			$firstrun = False
			Setlog("Donate CC now.", $COLOR_INFO)
			
			If $g_iActiveDonate = -1 Then PrepareDonateCC()
			DonateCC()
			
			ClickAwayChat(Random(7500, 15000, 1))

			#cs
			; Check Donate Pixel
			$g_aiDonatePixel = _MultiPixelSearch(200, 90, 300, 700, -2, 1, Hex(0x6da725, 6), $aChatDonateBtnColors, 20)
			If IsArray($g_aiDonatePixel) Then
				$y = $g_aiDonatePixel[1] + 30

				; Open Donate Window
				If Not _DonateWindow() Then ContinueLoop

				; Donate It : Troops & Spells [slot 2] is the Third slot from the left : [0 ,1 ,2 ,3 ,4 ]
				If DonateIT(0) Then $_bReturnT = True ; Donated troops, lets Train it
				If $g_OutOfTroops Then
					ClickAwayChat()
					CloseClanChat()
					Return
				EndIf
				If DonateIT(10) Then $_bReturnS = True ; Donated Spells , lets Train it

				; Close Donate Window - Return to Chat
				ClickAwayChat()
			Else
				; Doesn't exist Requests lets exits from this loop
;~ 				ClickP($aAway, 1, 0)
				If ScrollDown() Then
					$y = 200
				Else
					$firstrun = True
				EndIf
				ExitLoop
			EndIf

			If ($_bReturnT = False And $_bReturnS = False) Then $y += 50

			; Check if exist other Donate button
			$g_aiDonatePixel = _MultiPixelSearch(200, $y, 230, 660 + $g_iBottomOffsetY, -2, 1, Hex(0x6da725, 6), $aChatDonateBtnColors, 20)
			If IsArray($g_aiDonatePixel) Then
				If $g_bDebugSetlog Then SetDebugLog("More Donate buttons found, new $g_aiDonatePixel: (" & $g_aiDonatePixel[0] & "," & $g_aiDonatePixel[1] & ")", $COLOR_DEBUG)
				ContinueLoop
			Else
				If ScrollDown() Then $y = 200
				ContinueLoop
			EndIf
		#ce
		WEnd

		; A click just to mantain the 'Game active'
		;If $g_iLoop >= 5 Then
			If $g_bChkGTFOClanHop = True Then
				ClanHop($g_bChkGTFOClanHop) ; Hop!!!
				$firstrun = True
				$g_iLoop = 0
			EndIf
		;Else
		;	If $g_iLoop >= 10 Then
		;		ClickAwayChat(250)
		;		$g_iLoop = 0
		;	EndIf
		;EndIf
	WEnd

	AutoItSetOption("MouseClickDelay", 10)
	AutoItSetOption("MouseClickDownDelay", 10)
	CloseClanChat()

	If $g_iLoop2 > $g_iTxtCyclesGTFO Then
		LeaveClanHop()
		Return False
	EndIf
EndFunc   ;==>DonateGTFO

Func ClanHop($sClanJoin = True)
	If BitOr($g_bLeader, not $sClanJoin) And (Not $g_bChkGTFOClanHop) Then Return

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

		If _Sleep(7500) Then Return

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
				If UnderstandChatRules() And BitOr(_WaitForCheckPixel($aChatTab, $g_bCapturePixel, Default, "Wait for Open ClanChat #1:"), _WaitForCheckPixel($aChatTab2, $g_bCapturePixel, Default, "Wait for Open ClanChat #2:"), _WaitForCheckPixel($aChatTab3, $g_bCapturePixel, Default, "Wait for Open ClanChat #3:")) Then
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

	If _Sleep(200) Then Return
	CloseClanChat()
	Return
EndFunc ;==> LeaveClanHop

Func ClickAwayChat($iSleep = 10)
	If _Sleep($iSleep) Then Return
	Return SpecialAway()
EndFunc   ;==>ClickAwayChat

Func ScrollUp()
	Local $aScroll, $i_attempts = 0

	For $i = 0 To Random(0, 20, 1)
		ForceCaptureRegion()
		Local $y = 90
		$aScroll = _PixelSearch(293, 8 + $y, 295, 23 + $y, Hex(0xFFFFFF, 6), 18)
		If IsArray($aScroll) And _ColorCheck(_GetPixelColor(300, 110, True), Hex(0x509808, 6), 20) Then ; a second pixel for the green
			Click($aScroll[0], $aScroll[1], 1, 0, "#0172")
			If _Sleep($DELAYDONATECC2 + 100) Then Return
			ContinueLoop
		EndIf
		ExitLoop
	Next

EndFunc   ;==>ScrollUp

Func ScrollDown()
	Local $Scroll
	; Scroll Down
	ForceCaptureRegion()
	$Scroll = _PixelSearch(293, 687 - 30, 295, 693 - 30, Hex(0xFFFFFF, 6), 10)
	If IsArray($Scroll) Then
		Click($Scroll[0], $Scroll[1], 1, 0, "#0172")
		If _Sleep($DELAYDONATECC2) Then Return
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>ScrollDown

Func DonateIT($Slot)

	Local $iTroopIndex = $Slot, $YComp = 0, $NumberClick = 5
	If $g_iClanlevel >= 4 Then $NumberClick = 6
	If $g_iClanlevel >= 8 Then $NumberClick = 8

	If $Slot < 9 Then

		; TODO :  make the unconditional click slot 1 fast x8 ,
		;         after that check if exist the next slot ... True click 8x
		;         than check if the slot 1 is empty return to train troops

		Click(395 + ($Slot * 68), $g_iDonationWindowY + 57 + $YComp, $NumberClick, $DELAYDONATECC3, "#0175")
		SetLog(" - Donated Troops on Slot " & $Slot + 1, $COLOR_INFO)

		$Slot += 1
		$iTroopIndex = $Slot

		Click(395 + ($Slot * 68), $g_iDonationWindowY + 57 + $YComp, $NumberClick, $DELAYDONATECC3, "#0175")
		SetLog(" - Donated Troops on Slot " & $Slot + 1, $COLOR_INFO)

		; dadad5 Out of troops on Slot 0
		If _ColorCheck(_GetPixelColor(350, $g_iDonationWindowY + 105 + $YComp, True), Hex(0xDADAD5, 6), 5) Then
			SetLog("No More troops let's train!", $COLOR_INFO)
			$g_OutOfTroops = True
			If _Sleep(1000) Then Return
			Return False
		Else
			Return True
		EndIf
		Return False
	EndIf

	; Spells
	If $Slot > 9 Then
		$Slot = $Slot - 10
		$iTroopIndex = $Slot
		$YComp = 203 ; correct 860x780
	EndIf

	If _ColorCheck(_GetPixelColor(350 + ($Slot * 68), $g_iDonationWindowY + 105 + $YComp, True), Hex(0x6d45bd, 6), 20) Then ; check for 'purple'  6d45bd

		Click(365 + ($Slot * 68), $g_iDonationWindowY + 57 + $YComp, 1, $DELAYDONATECC3, "#0175")

		SetLog(" - Donated 1 Spell on Slot " & $Slot + 1, $COLOR_INFO)
		$g_aiDonateStatsSpells[$iTroopIndex][0] += 1
		$g_iSpellsNumber += 1
		Return True
	Else
		SetLog(" - Spells Empty or Filled!", $COLOR_ERROR)
		Return False
	EndIf

EndFunc   ;==>DonateIT

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

Func _DonateWindow()
	If $g_bDebugSetlog Then SetLog("_DonateWindow Open Start", $COLOR_DEBUG)

	; Click on Donate Button and wait for the window
	Local $iLeft = 0, $iTop = 0, $iRight = 0, $iBottom = 0, $i
	For $i = 0 To UBound($aChatDonateBtnColors) - 1
		If $aChatDonateBtnColors[$i][1] < $iLeft Then $iLeft = $aChatDonateBtnColors[$i][1]
		If $aChatDonateBtnColors[$i][1] > $iRight Then $iRight = $aChatDonateBtnColors[$i][1]
		If $aChatDonateBtnColors[$i][2] < $iTop Then $iTop = $aChatDonateBtnColors[$i][2]
		If $aChatDonateBtnColors[$i][2] > $iBottom Then $iBottom = $aChatDonateBtnColors[$i][2]
	Next
	$iLeft += $g_aiDonatePixel[0]
	$iTop += $g_aiDonatePixel[1]
	$iRight += $g_aiDonatePixel[0] + 1
	$iBottom += $g_aiDonatePixel[1] + 1

	ForceCaptureRegion()
	If $g_bDebugSetlog Then
		SetDebugLog("$g_aiDonatePixel: " & _ArrayToString($g_aiDonatePixel), $COLOR_DEBUG)
		SetDebugLog("$iLeft: " & $iLeft, $COLOR_DEBUG)
		SetDebugLog("$iTop: " & $iTop, $COLOR_DEBUG)
		SetDebugLog("$iRight: " & $iRight, $COLOR_DEBUG)
		SetDebugLog("$iBottom: " & $iBottom, $COLOR_DEBUG)
	EndIf

	Local $g_aiDonatePixelCheck = _MultiPixelSearch($iLeft, $iTop - 4 , $iRight, $iBottom, -2, 1, Hex(0x6da725, 6), $aChatDonateBtnColors, 20)
	If IsArray($g_aiDonatePixelCheck) Then
		Click($g_aiDonatePixel[0] + 50, $g_aiDonatePixel[1] + 10, 1, 0, "#0174")
	Else
		If $g_bDebugSetlog Then SetDebugLog("Could not find the Donate Button!", $COLOR_DEBUG)
		Return False
	EndIf
	If _Sleep($DELAYDONATEWINDOW1) Then Return

	Local $iCount = 0
	While Not (_ColorCheck(_GetPixelColor(331, $g_aiDonatePixel[1], True, "DonateWindow"), Hex(0xffffff, 6), 0))
		If _Sleep($DELAYDONATEWINDOW2) Then Return
		ForceCaptureRegion()
		;_CaptureRegion(0, 0, 306, $g_aiDonatePixel[1] + 30 + $YComp)
		$icount += 1
		If $iCount = 20 Then ExitLoop
	WEnd

	; Determinate the right position of the new Donation Window
	; Will search in $Y column = 410 for the first pure white color and determinate that position the $DonationWindowTemp
	$g_iDonationWindowY = 0

	ForceCaptureRegion()
	Local $aDonWinOffColors[1][3] = [[0xFFFFFF, 0, 2]]
	Local $aDonationWindow = _MultiPixelSearch(628, 0, 630, $g_iGAME_HEIGHT, 1, 1, Hex(0xFFFFFF, 6), $aDonWinOffColors, 10)

	If IsArray($aDonationWindow) Then
		$g_iDonationWindowY = $aDonationWindow[1]
		If $g_bDebugSetlog Then SetDebugLog("$g_iDonationWindowY: " & $g_iDonationWindowY, $COLOR_DEBUG)
	Else
		SetLog("Could not find the Donate Window!", $COLOR_ERROR)
		Return False
	EndIf

	If $g_bDebugSetlog Then SetDebugLog("_DonateWindow Open Exit", $COLOR_DEBUG)
	Return True
EndFunc   ;==>_DonateWindow
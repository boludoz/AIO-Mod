; #FUNCTION# ====================================================================================================================
; Name ..........: GTFO
; Description ...: This File contents for 'request and leave' algorithm , fast Donate'n'Train
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ProMac
; Modified ......: 06/2017 , MHK2012(05/2018), Boludoz(19/08/2018), Fahid.Mahmood(10/10/2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
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
		SetLogCentered(" GTFO v1.4 ", Default, Default, True)
		; Just a user log
		$_diffTimer = (TimerDiff($_timer) / 1000) / 60
		If Not $_bFirstLoop Then
			SetLog(" - Running GTFO for " & StringFormat("%.2f", $_diffTimer) & " min", $COLOR_DEBUG)
		EndIf
		$_bFirstLoop = False

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

		MainKickout()
		; **TODO** - verify is the train is Boosted , if is true the $g_aiTimeTrain[0] / 4 (x4 faster)

		If $g_aiTimeTrain[0] > 10 Then
			SetLog("Let's wait for a few minutes!", $COLOR_INFO)
			Local $aRndFuncList = ['Collect', 'CheckTombs', 'ReArm', 'CleanYard', 'BuilderBase', 'Boost']
			While 1
				If Not $g_bRunState Then Return
				If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
				If UBound($aRndFuncList) > 1 Then
					Local $Index = Random(0, UBound($aRndFuncList), 1)
					If $Index > UBound($aRndFuncList) - 1 Then $Index = UBound($aRndFuncList) - 1
					_RunFunction($aRndFuncList[$Index])
					_ArrayDelete($aRndFuncList, $Index)
				Else
					_RunFunction($aRndFuncList[0])
					ExitLoop
				EndIf
				If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			WEnd
		EndIf

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

		If $g_iLoop2 > $g_iTxtCyclesGTFO Then ExitLoop

		; +++++++++++++++++++++++++
		; DONATE IT - WHEN EXIST REQUESTS
		; +++++++++++++++++++++++++
		While 1
			$g_iLoop += 1
			$g_iLoop2 += 1
			If $g_iLoop2 > $g_iTxtCyclesGTFO Then ExitLoop
			If $g_iLoop >= 10 Then ExitLoop

			$_bReturnT = False
			$_bReturnS = False
			$firstrun = False

			; Check Donate Pixel
			$g_aiDonatePixel = _MultiPixelSearch(200, $y, 230, 660 + $g_iBottomOffsetY, -2, 1, Hex(0x6da725, 6), $aChatDonateBtnColors, 20)
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
		WEnd

		; A click just to mantain the 'Game active'
		If $g_iLoop >= 5 Then
			If $g_bChkGTFOClanHop = True Then
				ClanHop() ; Hop!!!
				$firstrun = True
				$g_iLoop = 0
			EndIf
		Else
			If $g_iLoop >= 10 Then
				ClickAwayChat(250)
				$g_iLoop = 0
			EndIf
		EndIf
	WEnd

	AutoItSetOption("MouseClickDelay", 10)
	AutoItSetOption("MouseClickDownDelay", 10)
	CloseClanChat()

	If $g_iLoop2 > $g_iTxtCyclesGTFO Then Return False
EndFunc   ;==>DonateGTFO

Func ClanHop($sClanJoin = False)

	If Not $g_bChkGTFOClanHop Then Return

	If $g_bLeader = True Then Return
	SetLog("Start Clan Hopping", $COLOR_INFO)
	Local $sTimeStartedHopping = _NowCalc()
	Local $iPosJoinedClans = 0, $iScrolls = 0, $iHopLoops = 0, $iErrors = 0

	Local $aJoinClanBtn[4] = [157, 510, 0x6CBB1F, 20] ; Green Join Button on Chat Tab when you are not in a Clan
	Local $aClanPage[4] = [768, 398, 0xFD5D64, 20] ; Red Leave Clan Button on Clan Page
	Local $aClanPageJoin[4] = [768, 398, 0xDCF583, 20] ; Green Join Clan Button on Clan Page
	Local $aJoinClanPage[4] = [720, 310, 0xEBCC80, 20] ; Trophy Amount of Clan Background of first Clan
	Local $aClanChat[4] = [105, 650, 0x87C907, 40] ; *Your Name* joined the Clan Message Check to verify loaded Clan Chat
	Local $aChatTab[4] = [189, 24, 0x706C50, 20] ; Clan Chat Tab on Top, check if right one is selected
	Local $aGlobalTab[4] = [189, 24, 0x383828, 20] ; Global Chat Tab on Top, check if right one is selected
	Local $aClanBadgeNoClan[4] = [151, 307, 0xF05538, 20] ; Orange Tile of Clan Logo on Chat Tab if you are not in a Clan
	Local $aShare[4] = [438, 190, 0xFFFFFF, 20]
	Local $aCopy[4] = [598, 176, 0xD9F481, 20]
	Local $aClick[2] = [176, 216]
	Local $aSearchClan[4] = [569, 202, 0xDCF684, 20]
	Local $aClanNameBtn[2] = [89, 63] ; Button to open Clan Page from Chat Tab
	;Local $aClanMod[4] = [215, 297, 0xCECDC6, 20] ; Not in use
	Local $aSendRequest[4] = [528, 213, 0xE2F98A, 20]

	$g_iCommandStop = 0 ; Halt Attacking

	While 1
		If $iErrors >= 10 Then
			Local $y = 0
			SetLog("Too Many Errors occured in current ClanHop Loop. Leaving ClanHopping!", $COLOR_ERROR)
			While 1
				If _Sleep(50) Then Return
				If _ColorCheck(_GetPixelColor($aCloseChat[0], $aCloseChat[1], True), Hex($aCloseChat[2], 6), $aCloseChat[3]) Then
					; Clicks chat Button
					Click($aCloseChat[0], $aCloseChat[1], 1, 0, "#0173") ;Clicks chat close button
					ExitLoop
;~ 				ElseIf QuickMIS("BC1", $g_sImgDonateCloseWindow, 790, 0, 825, 220, True, False) Then ; RC Done
;~ 					SetLog("Closing the Donate troops window!...", $COLOR_SUCCESS)
;~ 					Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
;~ 					;Add delay so donate window will get close
;~ 					If _Sleep($DELAYDONATEWINDOW1) Then ExitLoop
				Else
					If _Sleep(100) Then Return
					$y += 1
					If $y > 30 Then
						SetLog("Error finding Clan Tab to close.", $COLOR_ERROR)
						AndroidPageError("ClanHop")
						ExitLoop
					EndIf
				EndIf
			WEnd
			Return
		EndIf

		If $iScrolls >= 8 Then
			CloseCoc(True) ; Restarting to get some new Clans
			$iScrolls = 0
			$iPosJoinedClans = 0
		EndIf

		ForceCaptureRegion()

		OpenClanChat()

		If $g_bClanJoin = True And $g_bChkGTFOClanHop = True Then
			If Not _CheckPixel($aClanBadgeNoClan, $g_bCapturePixel) Then ; If Still in Clan
				SetLog("Still in a Clan! Leaving the Clan now")
				ClickP($aClanNameBtn)
				If _WaitForCheckPixel($aClanPage, $g_bCapturePixel, Default, "Wait for Clan Page:") Then
					ClickP($aClanPage)
					If Not ClickOkay("ClanHop") Then
						$g_bLeader = True
						SetLog("Okay Button not found! Starting over again", $COLOR_ERROR)
						$iErrors += 1
						ContinueLoop
					Else
						SetLog("Successfully left Clan", $COLOR_SUCCESS)
						If _Sleep(400) Then Return
						Return
					EndIf
				Else
					SetLog("Clan Page did not open! Starting over again", $COLOR_ERROR)
					$iErrors += 1
					ContinueLoop
				EndIf
			EndIf

			If _Sleep(400) Then Return
			ClickP($aClick)
			If _Sleep(400) Then Return

			Local $g_sTxtClanID = GUICtrlRead($g_hTxtClanID)

			Local $sClaID = StringReplace($g_sTxtClanID, "#", "")
			Setlog("Send : " & $sClaID, $COLOR_INFO)
			AndroidAdbSendShellCommand("am start -n com.supercell.clashofclans/com.supercell.clashofclans.GameApp -a android.intent.action.VIEW -d 'https://link.clashofclans.com/?action=OpenClanProfile&tag=" & $sClaID & "'", Default)
			Setlog("Wait")
			If _Sleep(5500) Then Return
			$sClanJoin = False

			If _Sleep(100) Then Return
			ClickP($aClanPageJoin)
			If _Sleep(100) Then Return
			ClickP($aSendRequest)
			If _Sleep(100) Then Return

			CloseClanChat()
			Return

		EndIf

		If Not _CheckPixel($aClanBadgeNoClan, $g_bCapturePixel) Then ; If Still in Clan
			SetLog("Still in a Clan! Leaving the Clan now")
			ClickP($aClanNameBtn)
			If $g_bFirstHop = True Then
				If _WaitForCheckPixel($aShare, $g_bCapturePixel, Default, "Wait for Share") Then
					ClickP($aShare)
					If _WaitForCheckPixel($aCopy, $g_bCapturePixel, Default, "Wait for Copy") Then
						Local $sData = 0
						ClickP($aCopy)
						Local $sData = ClipGet()
						If _Sleep(250) Then Return
						GUICtrlSetData($g_hTxtClanID, $sData)
						$g_sTxtClanID = $sData
						$g_bFirstHop = False
					Else
						SetLog("No Copy Button", $COLOR_ERROR)
						$iErrors += 1
						ContinueLoop
					EndIf
				Else
					SetLog("No Share Button", $COLOR_ERROR)
					$iErrors += 1
					ContinueLoop
				EndIf
			EndIf

			If _WaitForCheckPixel($aClanPage, $g_bCapturePixel, Default, "Wait for Clan Page:") Then
				ClickP($aClanPage)
				If Not ClickOkay("ClanHop") Then
					$g_bLeader = True
					SetLog("Okay Button not found! Starting over again", $COLOR_ERROR)
					$iErrors += 1
					ContinueLoop
				Else
					SetLog("Successfully left Clan", $COLOR_SUCCESS)
					If _Sleep(400) Then Return
				EndIf
			Else
				SetLog("Clan Page did not open! Starting over again", $COLOR_ERROR)
				$iErrors += 1
				ContinueLoop
			EndIf
		EndIf

		If _CheckPixel($aJoinClanBtn, $g_bCapturePixel) Then ; Click on Green Join Button on Donate Window
			SetLog("Opening Join Clan Page", $COLOR_INFO)
			ClickP($aJoinClanBtn)
		Else
			SetLog("Join Clan Button not visible! Starting over again", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf

		If Not _WaitForCheckPixel($aJoinClanPage, $g_bCapturePixel, Default, "Wait For Join Clan Page:") Then ; Wait For The golden Trophy Background of the First Clan in list
			SetLog("Joinable Clans did not show.. Starting over again", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf

		;Go through all Clans of the list 1 by 1
		If $iPosJoinedClans >= 7 Then
			ClickDrag(333, 668, 333, 286, 300)
			$iScrolls += 1
			$iPosJoinedClans = 0
		EndIf

		Click(161, 286 + ($iPosJoinedClans * 55)) ; Open specific Clans Page
		$iPosJoinedClans += 1
		If _Sleep(300) Then Return
		If Not _WaitForCheckPixel($aClanPageJoin, $g_bCapturePixel, Default, "Wait For Clan Page:") Then ; Check if Clan Page itself opened up
			SetLog("Clan Page did not open. Starting over again", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf

		ClickP($aClanPageJoin) ; Join Clan
		If _Sleep(1000) Then Return
		UnderstandChatRules() ; December Update(2018)
		If Not _WaitForCheckPixel($aClanChat, $g_bCapturePixel, Default, "Wait For Clan Chat:") Then ; Check for your "joined the Clan" Message to verify that Chat loaded successfully
			SetLog("Could not verify loaded Clan Chat. Starting over again", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf
		Return
	WEnd
EndFunc   ;==>ClanHop


Func ClickAwayChat($iSleep = 10)
	_Sleep($iSleep)
Return SpecialAway()
#CS deprecated
	Local $ix = Random(90, 129, 1)
	Local $iy = Random(687, 724, 1)

	Click($ix, $iy, 1, 0)
#CE
EndFunc   ;==>ClickAwayChat

Func OpenClanChat()

	; OPEN CLAN CHAT and verbose in log
	ClickP($aAway, 1, 0, "#0167") ;Click Away
	If _Sleep($DELAYDONATECC4) Then Return
	SetLog("Checking for Donate Requests in Clan Chat", $COLOR_INFO)
	ClickP($aOpenChat, 1, 0, "#0168") ; Clicks chat tab
	If _Sleep($DELAYDONATECC4) Then Return
	Local $iLoopCount = 0
	While 1
		;If Clan tab is selected.
		If _ColorCheck(_GetPixelColor(189, 24, True), Hex(0x706C50, 6), 20) Then ; color med gray
			If _Sleep(200) Then Return ;small delay to allow tab to completely open
			;Clan tab already Selected no click needed
			ClickP($aClanTab, 1, 0, "#0169") ; clicking clan tab
			ExitLoop
		EndIf
		;If Global tab is selected.
		If _ColorCheck(_GetPixelColor(189, 24, True), Hex(0x383828, 6), 20) Then ; Darker gray
			If _Sleep($DELAYDONATECC1) Then Return ;small delay to allow tab to completely open
			ClickP($aClanTab, 1, 0, "#0169") ; clicking clan tab
			ExitLoop
		EndIf
		;counter for time approx 3 sec max allowed for tab to open
		$iLoopCount += 1
		If $iLoopCount >= 15 Then ; allows for up to a sleep of 3000
			SetLog("Clan Chat Did Not Open - Abandon Donate")
			AndroidPageError("DonateCC")
			CloseCoc(True) ; Restarting to get some new Clans
			WaitMainScreenMini()
			_Sleep(100)
			ClickP($aClanTab, 1, 0, "#0169") ; clicking clan tab
			_Sleep(100)
			$iLoopCount = 0
			ExitLoop
		EndIf
		If _Sleep($DELAYDONATECC1) Then Return ; delay Allow 15x
	WEnd
	UnderstandChatRules() ; December Update(2018)
EndFunc   ;==>OpenClanChat

Func CloseClanChat()
	Local $i = 0
	While 1
		If _Sleep(100) Then Return
		If _ColorCheck(_GetPixelColor($aCloseChat[0], $aCloseChat[1], True), Hex($aCloseChat[2], 6), $aCloseChat[3]) Then
			; Clicks chat thing
			Click($aCloseChat[0], $aCloseChat[1], 1, 0, "#0173") ;Clicks chat thing
			ExitLoop
;~ 		ElseIf QuickMIS("BC1", $g_sImgDonateCloseWindow, 790, 0, 825, 220, True, False) Then ; RC Done
;~ 			SetLog("Closing the Donate troops window!...", $COLOR_SUCCESS)
;~ 			Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
;~ 			;Add delay so donate window will get close
;~ 			If _Sleep($DELAYDONATEWINDOW1) Then ExitLoop
		Else
			If _Sleep(100) Then Return
			$i += 1
			If $i > 30 Then
				SetLog("Error finding Clan Tab to close...", $COLOR_ERROR)
				AndroidPageError("DonateCC")
				ExitLoop
			EndIf
		EndIf
	WEnd

EndFunc   ;==>CloseClanChat

Func ScrollUp()
	Local $Scroll, $i_attempts = 0

	While 1
		ForceCaptureRegion()
		Local $y = 90
		$Scroll = _PixelSearch(293, 8 + $y, 295, 23 + $y, Hex(0xFFFFFF, 6), 18)
		If IsArray($Scroll) And _ColorCheck(_GetPixelColor(300, 110, True), Hex(0x509808, 6), 20) Then ; a second pixel for the green
			Click($Scroll[0], $Scroll[1], 1, 0, "#0172")
			If _Sleep($DELAYDONATECC2 + 100) Then Return
			ContinueLoop
			$i_attempts += 1
			If $i_attempts > 20 Then ExitLoop
		EndIf
		ExitLoop
	WEnd

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
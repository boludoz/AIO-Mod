; #FUNCTION# ====================================================================================================================
; Name ..........: GTFO
; Description ...: This File contents for 'request and leave' algorithm , fast Donate'n'Train
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ProMac
; Modified ......: 06/2017 , MHK2012(05/2018), Boludoz(19/08/2018), Fahid.Mahmood(10/10/2018), Boludoz(19/05/2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: ---
; ===============================================================================================================================
Global $g_bDisableTrain
Global $g_bDisableBrewSpell
Global $g_bDisableSiegeTrain
Global $g_aiDonatePixel[2] = [Null, Null]

Global $g_iTroosNumber = 0
Global $g_iSpellsNumber = 0
Global $g_iClanlevel = 8
Global $g_OutOfTroops = False
Global $g_iLoop2 = 0
Global $g_sClanJoin = True
Global $g_bFirstHop = True
Global $g_bLeader = False

Func MainGTFO()
	If $g_bChkUseGTFO = False Then Return
	If $g_aiCurrentLoot[$eLootElixir] <> 0 And $g_aiCurrentLoot[$eLootElixir] < $g_iTxtMinSaveGTFO_Elixir Then
		SetLog("Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
		Return
	EndIf
	If $g_aiCurrentLoot[$eLootDarkElixir] <> 0 And $g_aiCurrentLoot[$eLootDarkElixir] < $g_iTxtMinSaveGTFO_DE Then
		SetLog("Dark Elixir Limits Reached!! Let's farm!", $COLOR_INFO)
		Return
	EndIf
	If $g_iTxtCyclesGTFO = 0 Then
		$g_iLoop2 = 0
	Else
		If $g_iLoop2 > $g_iTxtCyclesGTFO Then
			SetDebugLog("GTFO Cycles Done!", $COLOR_DEBUG)
			Return
		EndIf
	EndIf
	ClanHop()
	Local $_timer = TimerInit()
	Local $_diffTimer = 0
	Local $_bFirstLoop = True
	$g_iTroosNumber = 0
	$g_iSpellsNumber = 0
	While 1
		SetLogCentered(" GTFO v2.4 ", Default, Default, True)
		SetDebugLog("Cycles UI:" & $g_iTxtCyclesGTFO & " Loop(s)", $COLOR_DEBUG)
		If Not IsNumber($g_iTxtCyclesGTFO) Or $g_iTxtCyclesGTFO < 0 Then SetLog("Please config your cycles correctly! (UI:" & $g_iTxtCyclesGTFO & " Loop(s))", $COLOR_ERROR)
		If $g_iTxtCyclesGTFO = 0 Then
			SetLog("Cycles selected as '0', This feature will run indefinitely.", $COLOR_INFO)
			SetLog("Only trains, Donates and eventually other features, but never attacks!", $COLOR_INFO)
		EndIf
		$_diffTimer = (TimerDiff($_timer) / 1000) / 60
		If Not $_bFirstLoop Then
			SetLog(" - Running GTFO for " & StringFormat("%.2f", $_diffTimer) & " min", $COLOR_DEBUG)
		EndIf
		$_bFirstLoop = False
		$g_bDisableBrewSpell = False
		$g_bDisableTrain = False
		If Not $g_bRunState Then Return
		If _Sleep($DELAYRUNBOT3) Then Return
		If CheckAndroidReboot() Then ContinueLoop
		checkObstacles()
		checkMainScreen(False)
		If isProblemAffect() Then ExitLoop
		checkAttackDisable($g_iTaBChkIdle)
		TrainTroopsGTFO()
		If $g_aiTimeTrain[0] > 10 Then
			SetLog("Let's wait for a few minutes!", $COLOR_INFO)
			Local $aRndFuncList = ['LabCheck', 'Collect', 'CheckTombs', 'CleanYard', 'CollectFreeMagicItems', "BuilderBase"]
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				__RunFunction($Index)
				If $g_bRestart Then ContinueLoop 2 ; must be level 2 due to loop-in-loop
			Next
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
		Local $bDonate = DonateGTFO()
		If Not $bDonate Then
			SetLog("Finished GTFO", $COLOR_INFO)
			ClanHop()
			Return
		EndIf
		If Not IfIsToStayInGTFO() Then
			Return
		EndIf
	WEnd
EndFunc   ;==>MainGTFO

Func TrainTroopsGTFO()
	TrainSystem()
EndFunc   ;==>TrainTroopsGTFO

Func DonateGTFO()
	AutoItSetOption("MouseClickDelay", 1)
	AutoItSetOption("MouseClickDownDelay", 1)
	Local $_timer = TimerInit()
	Local $_diffTimer = 0, $iTime2Exit = 20
	Local $_bReturnT = False
	Local $_bReturnS = False
	Local $y = 90, $firstrun = True
	$g_OutOfTroops = False
	OpenClanChat()
	If _Sleep($DELAYRUNBOT3) Then Return
	Local $iDonateLoop = 0
	While 1
		SetDebugLog("While Main started DonateGTFO")
		If Not $g_bRunState Then Return
		If _Sleep($DELAYRUNBOT3) Then Return
		If $y < 620 And Not $firstrun Then
			$y += 50
		Else
			ScrollUp()
			$y = 80
		EndIf
		SetDebugLog("While Main y=" & $y)
		$_diffTimer = (TimerDiff($_timer) / 1000) / 60
		If $g_aiTimeTrain[0] <> 0 Then $iTime2Exit = $g_aiTimeTrain[0]
		If $g_aiTimeTrain[1] <> 0 And $g_aiTimeTrain[1] < $g_aiTimeTrain[0] Then $iTime2Exit = $g_aiTimeTrain[1]
		If $_diffTimer > $iTime2Exit Then ExitLoop
		SetDebugLog("While Main - Cycles Used:" & $g_iLoop2 & " Loop(s)", $COLOR_ERROR)
		If $g_iTxtCyclesGTFO > 0 And $g_iLoop2 > $g_iTxtCyclesGTFO Then ExitLoop
		Local $Buttons = 0
		While 1
			If Not $g_bRunState Then Return
			SetDebugLog("While Main $iDonateLoop: " & $iDonateLoop)
			Local $iTime = TimerInit()
			Local $iBenchmark
			$iDonateLoop += 1
			$g_iLoop2 += 1
			If $g_iTxtCyclesGTFO > 0 And $g_iLoop2 > $g_iTxtCyclesGTFO Then ExitLoop
			If $iDonateLoop >= 10 Then ExitLoop
			$_bReturnT = False
			$_bReturnS = False
			$firstrun = False
			SetDebugLog("[1] While Donation SearchButtons y=" & $y)
			SearchButtons($y)
			$iBenchmark = TimerDiff($iTime)
			SetDebugLog("While Donation Get all Buttons in " & StringFormat("%.2f", $iBenchmark) & "'ms", $COLOR_DEBUG)
			If $g_aiDonatePixel[0] <> Null And $g_aiDonatePixel[0] > 50 Then
				$Buttons += 1
				SetDebugLog("While Donation Request button number: " & $Buttons, $COLOR_ACTION)
				$y = $g_aiDonatePixel[1] + 50
				SetDebugLog("[2] While Donation SearchButtons y=" & $y)
				If Not _DonateWindow() Then ContinueLoop
				If DonateIT(0) Then $_bReturnT = True
				If $g_OutOfTroops Then
					ClickAwayChat()
					CloseClanChat()
					Return
				EndIf
				If DonateIT(14) Then $_bReturnS = True
				$g_aiDonatePixel[0] = Null
				$g_aiDonatePixel[1] = Null
				ClickAwayChat()
			Else
				If ScrollDown() Then
					$y = 200
				Else
					$firstrun = True
				EndIf
				ExitLoop
				SetDebugLog("While Donation EXIT")
			EndIf
			SetDebugLog("$_bReturnT= " & $_bReturnT & "$_bReturnS= " & $_bReturnS)
			If ($_bReturnT = False And $_bReturnS = False) Then $y += 80
			ForceCaptureRegion()
			SetDebugLog("[3] While Donation SearchButtons y=" & $y)
			SearchButtons($y)
			If $g_aiDonatePixel[0] <> Null And $g_aiDonatePixel[0] > 100 Then
				$y = $g_aiDonatePixel[1] - 100
				$g_aiDonatePixel[0] = Null
				$g_aiDonatePixel[1] = Null
				SetDebugLog("[4] While Donation SearchButtons y=" & $y)
			Else
				If ScrollDown() Then $y = 200
				SetDebugLog("While Donation ContinueLoop While Main")
			EndIf
		WEnd
		SetDebugLog("While Main DonateGTFO EXIT")
		If $iDonateLoop >= 5 Then
			If $g_bChkGTFOClanHop = True Then
				ClanHop()
				$firstrun = True
				$iDonateLoop = 0
			EndIf
		EndIf
		If $iDonateLoop >= 10 Then
			ClickAwayChat(250)
			$iDonateLoop = 0
		EndIf
	WEnd
	AutoItSetOption("MouseClickDelay", 10)
	AutoItSetOption("MouseClickDownDelay", 10)
	CloseClanChat()
	If $g_iTxtCyclesGTFO > 0 And $g_iLoop2 > $g_iTxtCyclesGTFO Then Return False
EndFunc   ;==>DonateGTFO

Func ClanHop()
	If $g_bLeader Or Not $g_bChkGTFOClanHop Then Return

	SetLog("Start Clan Hopping", $COLOR_INFO)
;~ 	Local $sTimeStartedHopping = _NowCalc()
	Local $iErrors = 0


	$g_iCommandStop = 0 ; Halt Attacking

	While 1
		Local $bIsInClan = False

		If $iErrors >= 10 Then
			SetLog("Too Many Errors occured in current ClanHop Loop. Leaving ClanHopping!", $COLOR_ERROR)
;~ 			CloseClanChat()
			ExitLoop
		EndIf

		If Not OpenClanChat() Then
			SetLog("ClanHop | OpenClanChat fail.", $COLOR_ERROR)
			$iErrors += 1
			ContinueLoop
		EndIf

		#Region - If not is in clan
		If _Wait4PixelGoneArray($g_aIsClanChat) And _Wait4PixelArray($g_aClanBadgeNoClan) Then ; If not Still in Clan
			;CLick on green button if you dont is on clan, It is way 2
			Click(Random(104, 216, 1), Random(471, 515, 1))
			If RandomSleep(250) Then Return
		EndIf
		#EndRegion - If not is in clan

		#Region - If is in clan
		If _Wait4PixelArray($g_aIsClanChat) Then ; If Still in Clan
			$bIsInClan = True
			SetLog("Still in a Clan! Leaving the Clan now")
			ClickP($g_aIsClanChat)

			#Region - ClanHop return to clan alternative
			If $g_bFirstHop = True And $g_bChkGTFOReturnClan = True Then
				If _Wait4PixelArray($g_aShare) Then
					ClickP($g_aShare)
				Else
					SetLog("No Share Button", $COLOR_ERROR)
					; Return False
				EndIf

				Local $sData = ""
				If _Wait4PixelArray($g_aCopy) Then
					Click($g_aCopy[0], $g_aCopy[1] + 25)
					$sData = ClipGet()
					If RandomSleep(250) Then Return
					GUICtrlSetData($g_hTxtClanID, $sData)
					$g_sTxtClanID = $sData
					$g_bFirstHop = False
				Else
					SetLog("No Copy Button", $COLOR_ERROR)
					; Return False
				EndIf
			EndIf
			#EndRegion - ClanHop return to clan alternative


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
		#EndRegion - If is in clan

		If RandomSleep(500) Then Return

		; Open clans page
		Local $aIsOnClanLabel = [640, 205, 0xDDF685, 20]
		If _Wait4PixelArray($g_aClanLabel) Then
			If RandomSleep(500) Then Return

			Local $hTimer = TimerInit()
			Local $aReturn = 0
			Do
				$aReturn = _PixelSearch(485, 270, 495, 670, Hex(0xF0E77B, 6), 15)
				If IsArray($aReturn) Then
					Click($aReturn[0], $aReturn[1] + (67 * Random(1, 4, 1)))
					If RandomSleep(250) Then Return
					ExitLoop
				EndIf
				If RandomSleep(250) Then Return
			Until (2000 < TimerDiff($hTimer))

			If IsArray($aReturn) Then

				If _Wait4PixelArray($g_aJoinClanBtn) Then
					Click($g_aJoinClanBtn[0] - Random(0, 25, 1), $g_aJoinClanBtn[1] + Random(0, 25, 1))
					If RandomSleep(250) Then Return
					
					; Strategy for no clan case.
					If ClickOkay("ClanHop", True) = False Then
						SetLog("GTFO | Clan not detected previously, joined in one.", $COLOR_INFO)
					Else
						SetLog("GTFO | Leaved from old clan by another.", $COLOR_INFO)
					EndIf
					
					If RandomSleep(250) Then Return
					
					If UnderstandChatRules() = False Then
						SetLog("Fail GTFO | UnderstandChatRules. (1).", $COLOR_ERROR)
						$iErrors += 1
						ContinueLoop
					EndIf

				Else
					SetLog("Fail GTFO | Join. (3).", $COLOR_ERROR)
					$iErrors += 1
					ContinueLoop
				EndIf

			Else
				SetLog("Fail GTFO | Join. (1).", $COLOR_ERROR)
				$iErrors += 1
				ContinueLoop
			EndIf

			If Not OpenClanChat() Then
				$iErrors += 1
				ContinueLoop
			EndIf

			SetLog("GTFO | Clan hop finished.", $COLOR_INFO)

			; CloseClanChat()
			Return True

		Else
			$iErrors += 1
			ContinueLoop
		EndIf
	WEnd

	If $iErrors >= 10 Then
		Setlog("ClanSaveAndJoiner|End ERROR", $COLOR_ERROR)
		Return False
	EndIf

	Return True
	ClickAwayChat(400)
EndFunc   ;==>ClanHop


Func ClickAwayChat($iSleep = 10)
	If RandomSleep($iSleep) Then Return
	Local $iX = Random(115, 140, 1)
	Local $iY = Random(595, 640, 1)
	Click($iX, $iY, 1, 0)
EndFunc   ;==>ClickAwayChat

;~ Func OpenClanChat()
;~ 	If _Sleep($DELAYDONATECC4) Then Return
;~ 	ClickP($aAway, 1, 0, "#0167")
;~ 	If _Sleep($DELAYDONATECC4) Then Return
;~ 	SetLog("Checking for Donate Requests in Clan Chat", $COLOR_INFO)
;~ 	If Not _CheckPixel($aChatTab, $g_bCapturePixel) Or Not _CheckPixel($aChatTab2, $g_bCapturePixel) Or Not _CheckPixel($aChatTab3, $g_bCapturePixel) Then ClickP($aOpenChat, 1, 0, "#0168")
;~ 	If _Sleep($DELAYDONATECC4) Then Return
;~ 	If Not _WaitForCheckPixel($C12918, $g_bCapturePixel, Default, "Wait For Chat To Open:") Then
;~ 		SetLog("Clan Chat Did Not Open - Abandon Donate")
;~ 		AndroidPageError("DonateCC")
;~ 		CloseCoC(True)
;~ 		waitMainScreenMini()
;~ 		If _Sleep(100) Then Return
;~ 		ClickP($aClanTab, 1, 0, "#0169")
;~ 		If _Sleep(100) Then Return
;~ 	EndIf
;~ 	UnderstandChatRules()
;~ EndFunc   ;==>OpenClanChat

;~ Func CloseClanChat()
;~ 	Local $i = 0
;~ 	While 1
;~ 		If _Sleep(100) Then Return
;~ 		If _ColorCheck(_GetPixelColor($aCloseChat[0], $aCloseChat[1], True), Hex($aCloseChat[2], 6), $aCloseChat[3]) Then
;~ 			Click($aCloseChat[0], $aCloseChat[1], 1, 0, "#0173")
;~ 			ExitLoop
;~ 		ElseIf QuickMIS("BC1", $g_sImgDonateCloseWindow, 730, 0, 825, 220, True, False) Then
;~ 			SetLog("Closing the Donate troops window!...", $COLOR_SUCCESS)
;~ 			Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
;~ 			If _Sleep($DELAYDONATEWINDOW1) Then ExitLoop
;~ 		Else
;~ 			If _Sleep(100) Then Return
;~ 			$i += 1
;~ 			If $i > 30 Then
;~ 				SetLog("Error finding Clan Tab to close...", $COLOR_ERROR)
;~ 				AndroidPageError("DonateCC")
;~ 				ExitLoop
;~ 			EndIf
;~ 		EndIf
;~ 	WEnd
;~ EndFunc   ;==>CloseClanChat

Func ScrollUp()
	Local $aScroll, $i_attempts = 0
	While 1
		ForceCaptureRegion()
		Local $y = 81
		$aScroll = _PixelSearch(293, $y, 295, 8 + $y, Hex(0xFFFFFF, 6), 10)
		If IsArray($aScroll) And _ColorCheck(_GetPixelColor(300, 95, True), Hex(0x5da515, 6), 15) Then
			Click($aScroll[0], $aScroll[1], 1, 0, "#0172")
			If _Sleep($DELAYDONATECC2 + 100) Then Return
			ContinueLoop
			$i_attempts += 1
			If $i_attempts > 20 Then ExitLoop
		EndIf
		ExitLoop
	WEnd
EndFunc   ;==>ScrollUp

Func ScrollDown()
	Local $aScroll
	ForceCaptureRegion()
	$aScroll = _PixelSearch(293, 563 + 44, 295, 571 + 44, Hex(0xFFFFFF, 6), 10)
	If IsArray($aScroll) Then
		Click($aScroll[0], $aScroll[1], 1, 0, "#0172")
		If _Sleep($DELAYDONATECC2) Then Return
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>ScrollDown

Func DonateIT($Slot)
	Local $iTroopIndex = $Slot, $yComp = 0, $NumberClick = 5
	If $g_iClanlevel >= 4 Then $NumberClick = 6
	If $g_iClanlevel >= 8 Then $NumberClick = 8
	If $Slot < 14 Then
		If Not _ColorCheck(_GetPixelColor(350, $g_iDonationWindowY + 105 + $yComp, True), Hex(0x3d79b5, 6), 15) Then
			SetLog("You can't donate more Troops for this request!", $COLOR_INFO)
			Return False
		EndIf
		Click(395 + ($Slot * 68), $g_iDonationWindowY + 57 + $yComp, $NumberClick, $DELAYDONATECC3, "#0175")
		SetLog(" - Donated Troops on Slot " & $Slot + 1, $COLOR_INFO)
		$Slot = 0
		$iTroopIndex = $Slot
		$g_bDisableTrain = False
		Click(395 + ($Slot * 68), $g_iDonationWindowY + 147 + $yComp, $NumberClick, $DELAYDONATECC3, "#0175")
		SetLog(" - Donated Troops on Slot " & $Slot + 1, $COLOR_INFO)
		If _ColorCheck(_GetPixelColor(350, $g_iDonationWindowY + 105 + $yComp, True), Hex(0xDADAD5, 6), 5) Then
			SetLog("No More troops let's train!", $COLOR_INFO)
			$g_OutOfTroops = True
			If _Sleep(1000) Then Return
			Return False
		Else
			Return True
		EndIf
		Return False
	EndIf
	If $Slot > 13 Then
		$Slot = $Slot - 14
		$iTroopIndex = $Slot
		$yComp = 206
	EndIf
	If _ColorCheck(_GetPixelColor(350 + ($Slot * 68), $g_iDonationWindowY + 105 + $yComp, True), Hex(0x6e6e6e, 6), 20) Then
		SetLog("You can't donate more Spells for this request!", $COLOR_INFO)
		Return False
	EndIf
	If _ColorCheck(_GetPixelColor(350 + ($Slot * 68), $g_iDonationWindowY + 105 + $yComp, True), Hex(0x6d45bd, 6), 20) Then
		Click(365 + ($Slot * 68), $g_iDonationWindowY + 57 + $yComp, 1, $DELAYDONATECC3, "#0175")
		SetLog(" - Donated 1 Spell on Slot " & $Slot + 1, $COLOR_INFO)
		$g_aiDonateStatsSpells[$iTroopIndex][0] += 1
		$g_iSpellsNumber += 1
		$g_bDisableBrewSpell = False
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
;~ 		If $g_bTotalCampForced = True And $g_bSetDoubleArmy Then
		If $g_bTotalCampForced = True Then
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
		If $g_bTotalCampForced Then
;~ 		If $g_bTotalCampForced And $g_bSetDoubleArmy Then
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
	Local $sSearchZone = "195," & $g_aiDonatePixel[1] - 50 & ",305," & $g_aiDonatePixel[1] + 109
	Local $aDonatePixel = _ImageSearchXML($g_sImgDonateCC & "DonateButton\", 1, $sSearchZone)
	SetDebugLog("DonateWindow $g_aiDonatePixel array: " & _ArrayToString($aDonatePixel, ",", -1, -1, "|"))
	If IsArray($aDonatePixel) Then
		Click($aDonatePixel[0][1], $aDonatePixel[0][2], 1, 0, "#0174")
	Else
		If $g_bDebugSetlog Then SetDebugLog("Could not find the Donate Button!", $COLOR_DEBUG)
		Return False
	EndIf
	If _Sleep($DELAYDONATEWINDOW1) Then Return
	Local $iCount = 0
	While Not (_ColorCheck(_GetPixelColor(331, $g_aiDonatePixel[1], True, "DonateWindow"), Hex(0xffffff, 6), 0))
		If _Sleep($DELAYDONATEWINDOW2) Then Return
		ForceCaptureRegion()
		$iCount += 1
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

Func SearchButtons($y = 50)
	$g_aiDonatePixel[0] = Null
	$g_aiDonatePixel[1] = Null
	Local $sSearchZone = "195," & $y & ",305," & 672 - $y
	Local $aDonatePixel = _ImageSearchXML($g_sImgDonateCC & "DonateButton\", 10, $sSearchZone)
	SetDebugLog("$g_aiDonatePixel array: " & _ArrayToString($aDonatePixel, ",", -1, -1, "|"))
	_ArraySort($aDonatePixel, 0, 0, 0, 2)
	SetDebugLog("$g_aiDonatePixel array: " & _ArrayToString($aDonatePixel, ",", -1, -1, "|"))
	If $aDonatePixel <> -1 And IsArray($aDonatePixel) And UBound($aDonatePixel) > 0 And $aDonatePixel[0][0] <> "" Then
		$g_aiDonatePixel[0] = $aDonatePixel[0][1]
		$g_aiDonatePixel[1] = $aDonatePixel[0][2]
	EndIf
EndFunc   ;==>SearchButtons

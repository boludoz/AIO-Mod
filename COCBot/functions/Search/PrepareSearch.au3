; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareSearch
; Description ...: Goes into searching for a match, breaks shield if it has to
; Syntax ........: PrepareSearch()
; Parameters ....:
; Return values .: None
; Author ........: Code Monkey #4
; Modified ......: KnowJack (Aug 2015), MonkeyHunter(2015-12)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func PrepareSearch($Mode = $DB) ;Click attack button and find match button, will break shield

	SetLog("Going to Attack", $COLOR_INFO)

	; RestartSearchPickupHero - Check Remaining Heal Time
	If $g_bSearchRestartPickupHero And $Mode <> $DT Then
		For $pTroopType = $eKing To $eChampion ; check all 4 hero
			For $pMatchMode = $DB To $g_iModeCount - 1 ; check all attack modes
				If IsUnitUsed($pMatchMode, $pTroopType) Then
					If Not _DateIsValid($g_asHeroHealTime[$pTroopType - $eKing]) Then
						getArmyHeroTime("All", True, True)
						ExitLoop 2
					EndIf
				EndIf
			Next
		Next
	EndIf

	ChkAttackCSVConfig()
	
	waitMainScreen() ; Custom - Team AIO Mod++ (@vDragon)
	
	If IsMainPage() Then
		If _Sleep($DELAYTREASURY4) Then Return
		If _CheckPixel($aAttackForTreasury, $g_bCapturePixel, Default, "Is attack for treasury:") Then
			SetLog("It isn't attack for Treasury :-(", $COLOR_SUCCESS)
			Return
		EndIf
		If _Sleep($DELAYTREASURY4) Then Return
		
		#Region - Custom findMatch - Team AIO Mod++ 
		; ZoomOut for update measurements
		ZoomOut()
		
		; Find attack button.
		For $i = 0 To 4
			Local $aAttack = findButton("AttackButton", Default, 1, True)
			If IsArray($aAttack) And UBound($aAttack, 1) = 2 Then
				ClickP($aAttack, 1, 0, "#0149")
				ExitLoop
			ElseIf $i > 3 Then
				SetLog("Couldn't find the Attack Button!", $COLOR_ERROR)
				If $g_bDebugImageSave Then SaveDebugImage("AttackButtonNotFound")
				Return False
			ElseIf $i = 1 Then
				CloseClanChat()
				CheckMainScreen()
			EndIf
		Next
		#EndRegion - Custom findMatch - Team AIO Mod++ 
	EndIf

	If _Sleep($DELAYPREPARESEARCH1) Then Return
	If Not IsWindowOpen($g_sImgGeneralCloseButton, 10, 200, GetDiamondFromRect("716,1,860,179")) Then
		SetLog("Attack Window did not open!", $COLOR_ERROR)
		AndroidPageError("PrepareSearch")
		checkMainScreen()
		$g_bRestart = True
		$g_bIsClientSyncError = False
		Return False
	EndIf

	$g_bCloudsActive = True ; early set of clouds to ensure no android suspend occurs that might cause infinite waits

	If Not IsMultiplayerTabOpen() Then
		SetLog("Error while checking if Multiplayer Tab is opened", $COLOR_ERROR)
		Return
	EndIf

	#Region - Custom findMatch - Team AIO Mod++ 
	$g_bLeagueAttack = False
	Do
		Local $bSignedUpLegendLeague = False
		Local $sSearchDiamond = GetDiamondFromRect("271,185,834,659")
		Local $avAttackButton = findMultiple($g_sImgPrepareLegendLeagueSearch, $sSearchDiamond, $sSearchDiamond, 0, 1000, 1, "objectname,objectpoints", True)
		If IsArray($avAttackButton) And UBound($avAttackButton, 1) > 0 Then
			Local $avAttackButtonSubResult = $avAttackButton[0]
			Local $sButtonState = $avAttackButtonSubResult[0]
			If StringInStr($sButtonState, "Normal", 0) < 1 Then $g_bLeagueAttack = True ; Custom fix - AIO Mod++
			If StringInStr($sButtonState, "Ended", 0) > 0 Then
				SetLog("League Day ended already! Trying again later", $COLOR_INFO)
				$g_bRestart = True
				ClickAway()
				$g_bForceSwitch = True     ; set this switch accounts next check
				Return
			ElseIf StringInStr($sButtonState, "Made", 0) > 0 Then
				SetLog("All Attacks already made! Returning home", $COLOR_INFO)
				$g_bRestart = True
				ClickAway()
				$g_bForceSwitch = True     ; set this switch accounts next check
				Return
			ElseIf StringInStr($sButtonState, "FindMatchLegend", 0) > 0 Then
				Local $aCoordinates = StringSplit($avAttackButtonSubResult[1], ",", $STR_NOCOUNT)
				ClickP($aCoordinates, 1, 0, "#0149")
				Local $aConfirmAttackButton
				For $i = 0 To 10
					If _Sleep(200) Then Return
					$aConfirmAttackButton = findButton("ConfirmAttack", Default, 1, True)
					If IsArray($aConfirmAttackButton) And UBound($aConfirmAttackButton, 1) = 2 Then
						ClickP($aConfirmAttackButton, 1, 0)
						ExitLoop
					EndIf
				Next
				If Not IsArray($aConfirmAttackButton) And UBound($aConfirmAttackButton, 1) < 2 Then
					SetLog("Couldn't find the confirm attack button!", $COLOR_ERROR)
					Return False
				EndIf
			ElseIf StringInStr($sButtonState, "Sign", 0) > 0 Then
				SetLog("Sign-up to Legend League", $COLOR_INFO)
				Local $aCoordinates = StringSplit($avAttackButtonSubResult[1], ",", $STR_NOCOUNT)
				ClickP($aCoordinates, 1, 0, "#0000")
				If _Sleep(1000) Then Return
				$aCoordinates = findButton("OK")
				If UBound($aCoordinates) > 1 Then
					SetLog("Sign-up to Legend League done", $COLOR_INFO)
					$bSignedUpLegendLeague = True
					ClickP($aCoordinates, 1, 0, "#0000")
					If _Sleep(1000) Then Return
				Else
					SetLog("Cannot find OK button to sign-up for Legend League", $COLOR_WARNING)
				EndIf
			ElseIf StringInStr($sButtonState, "Oppo", 0) > 0 Then
				SetLog("Finding opponents! Waiting 5 minutes and then try again to find a match", $COLOR_INFO)
				If _Sleep(300000) Then Return     ; Wait 5mins before searching again
				$bSignedUpLegendLeague = True
			ElseIf ClickFindMatch() = True Then
				If $g_bRestart = True Then Return False ; exit func
				SetLog("Looking for village!", $COLOR_SUCCESS)
				$bSignedUpLegendLeague = False
				$g_bLeagueAttack = False
				ExitLoop
			Else
				$g_bLeagueAttack = False
				If $g_bDebugImageSave Then SaveDebugImage("PrepareSearchFail") ; Custom findMatch - Team AIO Mod++
				SetLog("Unknown Find a Match Button State: " & $sButtonState, $COLOR_WARNING)
				Return False
			EndIf
		ElseIf Number($g_aiCurrentLoot[$eLootTrophy]) >= Number($g_asLeagueDetails[21][4]) Then
			SetLog("Couldn't find the Attack Button!", $COLOR_ERROR)
			Return False
		EndIf
	Until Not $bSignedUpLegendLeague
	#EndRegion - Custom findMatch - Team AIO Mod++ 

	If $g_iTownHallLevel <> "" And $g_iTownHallLevel > 0 Then
		$g_iSearchCost += $g_aiSearchCost[$g_iTownHallLevel - 1]
		$g_iStatsTotalGain[$eLootGold] -= $g_aiSearchCost[$g_iTownHallLevel - 1]
	EndIf
	UpdateStats()

	If _Sleep($DELAYPREPARESEARCH2) Then Return

	Local $Result = getAttackDisable(346, 182) ; Grab Ocr for TakeABreak check

	If isGemOpen(True) Then ; Check for gem window open)
		SetLog(" Not enough gold to start searching!", $COLOR_ERROR)
		Click(585, 252, 1, 0, "#0151") ; Click close gem window "X"
		If _Sleep($DELAYPREPARESEARCH1) Then Return
		Click(822, 32, 1, 0, "#0152") ; Click close attack window "X"
		If _Sleep($DELAYPREPARESEARCH1) Then Return
		$g_bOutOfGold = True ; Set flag for out of gold to search for attack
	EndIf

	checkAttackDisable($g_iTaBChkAttack, $Result) ;See If TakeABreak msg on screen

	If $g_bDebugSetlog Then SetDebugLog("PrepareSearch exit check $g_bRestart= " & $g_bRestart & ", $g_bOutOfGold= " & $g_bOutOfGold, $COLOR_DEBUG)

	If $g_bRestart Or $g_bOutOfGold Then ; If we have one or both errors, then return
		$g_bIsClientSyncError = False ; reset fast restart flag to stop OOS mode, collecting resources etc.
		Return
	EndIf
	If IsAttackWhileShieldPage(False) Then ; check for shield window and then button to lose time due attack and click okay
		Local $offColors[3][3] = [[0x000000, 144, 1], [0xFFFFFF, 54, 17], [0xFFFFFF, 54, 28]] ; 2nd Black opposite button, 3rd pixel white "O" center top, 4th pixel White "0" bottom center
		Local $ButtonPixel = _MultiPixelSearch(359, 404 + $g_iMidOffsetY, 510, 445 + $g_iMidOffsetY, 1, 1, Hex(0x000000, 6), $offColors, 20) ; first vertical black pixel of Okay
		If $g_bDebugSetlog Then SetDebugLog("Shield btn clr chk-#1: " & _GetPixelColor(441, 344 + $g_iMidOffsetY, True) & ", #2: " & _
				_GetPixelColor(441 + 144, 344 + $g_iMidOffsetY, True) & ", #3: " & _GetPixelColor(441 + 54, 344 + 17 + $g_iMidOffsetY, True) & ", #4: " & _
				_GetPixelColor(441 + 54, 344 + 10 + $g_iMidOffsetY, True), $COLOR_DEBUG)
		If IsArray($ButtonPixel) Then
			If $g_bDebugSetlog Then
				SetDebugLog("ButtonPixel = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
				SetDebugLog("Shld Btn Pixel color found #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & ", #2: " & _GetPixelColor($ButtonPixel[0] + 144, $ButtonPixel[1], True) & ", #3: " & _GetPixelColor($ButtonPixel[0] + 54, $ButtonPixel[1] + 17, True) & ", #4: " & _GetPixelColor($ButtonPixel[0] + 54, $ButtonPixel[1] + 27, True), $COLOR_DEBUG)
			EndIf
			Click($ButtonPixel[0] + 75, $ButtonPixel[1] + 25, 1, 0, "#0153") ; Click Okay Button
		EndIf
	EndIf
	
	#Region - Custom findMatch - Team AIO Mod++ 
	; Bad findmatch.
	Local $iCount
	_CaptureRegion()
	While _CheckPixel($aIsMainGrayed, False, Default, "IsMainGrayed") Or _CheckPixel($aIsMain, False, Default, "IsMain")
		_CaptureRegion()
		$iCount += 1
		If _Sleep($DELAYATTACKREPORT1) Then Return
		If $g_bDebugSetlog Then SetDebugLog("Waiting PrepareSearch, " & ($iCount / 2) & " Seconds.", $COLOR_DEBUG)
		If $iCount > 15 Then ExitLoop ; wait 15*500ms = 7,5 seconds max for the window to render
	WEnd
	
	If $iCount > 15 Then
		SetLog("Bad prepareSearch.", $COLOR_ERROR)
		CheckMainScreen()
		Return False
	EndIf	
	#EndRegion - Custom findMatch - Team AIO Mod++ 

	Return True
EndFunc   ;==>PrepareSearch

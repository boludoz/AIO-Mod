; #FUNCTION# ====================================================================================================================
; Name ..........: Clan Games
; Description ...: This file contains the Clan Games algorithm
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ViperZ And Uncle Xbenk 01-2018
; Modified ......: ProMac 02/2018 [v2 and v3] , ProMac 08/2018 v4, GrumpyHog 08/2020, xBebenk x boludoz (2021)
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

Global $g_bIsCaravanOn = "Undefined" ; Custom BB - Team AIO Mod++
Global $g_bYourAccScoreCG[8][3] = [[-1, True, False], [-1, True, False], [-1, True, False], [-1, True, False], [-1, True, False], [-1, True, False], [-1, True, False], [-1, True, False]]

Func ClanGamesStatus()
	If $g_bYourAccScoreCG[Int($g_iCurAccount)][2] = True Then
		SetLog("Maximum number of points achieved in clan games.", $COLOR_SUCCESS)
		Return "False"
	EndIf

	Switch $g_bIsCaravanOn
		Case "False"
			Return "False"
		Case "True"
			Return "True"
	EndSwitch

	Return "Undefined"
EndFunc

Func IsClanGamesWindow($getCapture = True, $bOnlyCheck = False)
	Local $sState, $bRet = False

	$g_bIsCaravanOn = "False"
	If QuickMIS("BC1", $g_sImgCaravan, 230, 55, 330, 155, $getCapture, False) Then
		$g_bIsCaravanOn = "True"
		SetLog("Caravan available! Entering Clan Games", $COLOR_SUCCESS)
		Click($g_iQuickMISX + 230, $g_iQuickMISY + 55)
		; Just wait for window open
		If _Sleep(2500) Then Return
		$sState = IsClanGamesRunning()
		Switch $sState
			Case "prepare"
				$bRet = False
			Case "running"
				$bRet = True
			Case "end"
				$bRet = False
				$g_bIsCaravanOn = "False"
		EndSwitch
	Else
		SetLog("Caravan not available", $COLOR_WARNING)
		$bRet = False
	EndIf

	If $bOnlyCheck = True Then
		ClickAway()
		If _Sleep(1500) Then Return

		CheckMainScreen(False, False)
	EndIf

	SetLog("Clan Games Event is : " & $sState, $COLOR_INFO)
	Return $bRet
EndFunc   ;==>IsClanGamesWindow

Func _ClanGames($test = False)

	#Region - Custom BB - Team AIO Mod++
	$g_bIsBBevent = False ; Reset

	; Check If this Feature is Enable on GUI.
	If Not $g_bChkClanGamesEnabled Then Return
	#EndRegion - Custom BB - Team AIO Mod++

	Local $sINIPath = StringReplace($g_sProfileConfigPath, "config.ini", "ClanGames_config.ini")

	; A user Log and a Click away just in case
	ClickAway()
	SetLog("Entering Clan Games", $COLOR_INFO)

	; Local and Static Variables
	Local $TabChallengesPosition[2] = [820, 130]
	Local $sTimeRemain = "", $sEventName = "", $getCapture = True

	; Initial Timer
	Local $hTimer = TimerInit()

	; Let's selected only the necessary images [Total=71]
	Local $sImagePath = @ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges"
	Local $sTempPath = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"
	; ClanGameImageCopy(@ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges", @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\", "BBD")
	;Remove All previous file (in case setting changed)
	DirRemove($sTempPath, $DIR_REMOVE)

	If $g_bChkClanGamesLoot Then ClanGameImageCopy($sImagePath, $sTempPath, "L") ;L for Loot
	If $g_bChkClanGamesBattle Then ClanGameImageCopy($sImagePath, $sTempPath, "B") ;B for Battle
	If $g_bChkClanGamesDes Then ClanGameImageCopy($sImagePath, $sTempPath, "D") ;D for Destruction
	If $g_bChkClanGamesAirTroop Then ClanGameImageCopy($sImagePath, $sTempPath, "A") ;A for AirTroops
	If $g_bChkClanGamesGroundTroop Then ClanGameImageCopy($sImagePath, $sTempPath, "G") ;G for GroundTroops

	If $g_bChkClanGamesMiscellaneous Then ClanGameImageCopy($sImagePath, $sTempPath, "M") ;M for Misc
    If $g_bChkClanGamesSpell Then ClanGameImageCopy($sImagePath, $sTempPath, "S") ;S for GroundTroops
    If $g_bChkClanGamesBBBattle Then ClanGameImageCopy($sImagePath, $sTempPath, "BBB") ;BBB for BB Battle
    If $g_bChkClanGamesBBDes Then ClanGameImageCopy($sImagePath, $sTempPath, "BBD") ;BBD for BB Destruction
	If $g_bChkClanGamesBBTroops Then ClanGameImageCopy($sImagePath, $sTempPath, "BBT") ;BBT for BB Troops

	; Enter on Clan Games window
	$g_bYourAccScoreCG[Int($g_iCurAccount)][2] = False

	If IsClanGamesWindow() Then

		; Let's get some information , like Remain Timer, Score and limit
		Local $aiScoreLimit = GetTimesAndScores()
		If $aiScoreLimit = -1 Or UBound($aiScoreLimit) <> 2 Then
			ClickAway() ;need clickaway, as we are leaving
			Return
		Else
			SetLog("Your Score is: " & $aiScoreLimit[0], $COLOR_INFO)
			Local $sTimeCG
			If $aiScoreLimit[0] = $aiScoreLimit[1] Then
				$g_bYourAccScoreCG[Int($g_iCurAccount)][2] = True
				SetLog("Your score limit is reached! Congrats")
				ClickAway()
				Return
			ElseIf $aiScoreLimit[0] + 300 > $aiScoreLimit[1] Then
				SetLog("Your almost reached max point")
				If $g_bChkClanGamesStopBeforeReachAndPurge Then
					If IsEventRunning() Then Return
					$sTimeCG = ConvertOCRTime("ClanGames()", $g_sClanGamesTimeRemaining, True)
					Setlog("Clan Games Minute Remain: " & $sTimeCG)
					If $g_bChkClanGamesPurgeAny And $sTimeCG > 1200 Then ; purge, but not purge on last day of clangames
						SetLog("Stop before completing your limit and only Purge")
						SetLog("Lets only purge 1 most top event", $COLOR_WARNING)
						ForcePurgeEvent(False, True)
						ClickAway()
						Return
					EndIf
				EndIf
			EndIf
			If $g_bYourAccScoreCG[$g_iCurAccount][0] = -1 Then $g_bYourAccScoreCG[$g_iCurAccount][0] = $aiScoreLimit[0]
		EndIf
	Else
		Return
	EndIf

	;check cooldown purge
	If CooldownTime() Then Return
	If Not $g_bRunState Then Return ;trap pause or stop bot
	If IsEventRunning() Then Return
	If Not $g_bRunState Then Return ;trap pause or stop bot

	UpdateStats()

	Local $HowManyImages = _FileListToArray($sTempPath, "*", $FLTA_FILES)
	If IsArray($HowManyImages) Then
		Setlog($HowManyImages[0] & " Events to search")
	Else
		Setlog("ClanGames-Error on $HowManyImages: " & @error)
		Return
	EndIf


	; To store the detections
	; [0]=ChallengeName [1]=EventName [2]=Xaxis [3]=Yaxis
	Local $aAllDetectionsOnScreen[0][4]

	Local $sClanGamesWindow = GetDiamondFromRect("300,155,765,550")
	Local $aCurrentDetection = findMultiple($sTempPath, $sClanGamesWindow, $sClanGamesWindow, 0, 1000, 0, "objectname,objectpoints", True)
	Local $aEachDetection

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames findMultiple (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Let's split Names and Coordinates and populate a new array
	If UBound($aCurrentDetection) > 0 Then

		; Temp Variables
		Local $FullImageName, $StringCoordinates, $sString, $tempObbj, $tempObbjs, $aNames
		Local $BBCheck[2] = ["BBD-WallDes", "BBD-BuildingDes"]

		For $i = 0 To UBound($aCurrentDetection) - 1
			If _Sleep(50) Then Return ; just in case of PAUSE
			If Not $g_bRunState Then Return ; Stop Button

			$aEachDetection = $aCurrentDetection[$i]
			; Justto debug
			SetDebugLog(_ArrayToString($aEachDetection))

			$FullImageName = String($aEachDetection[0])
			$StringCoordinates = $aEachDetection[1]

			If $FullImageName = "" Or $StringCoordinates = "" Then ContinueLoop

			; Exist more than One coordinate!?
			If StringInStr($StringCoordinates, "|") Then
				; Code to test the string if exist anomalies on string
				$StringCoordinates = StringReplace($StringCoordinates, "||", "|")
				$sString = StringRight($StringCoordinates, 1)
				If $sString = "|" Then $StringCoordinates = StringTrimRight($StringCoordinates, 1)
				; Split the coordinates
				$tempObbjs = StringSplit($StringCoordinates, "|", $STR_NOCOUNT)
				; Just get the first [0]
				$tempObbj = StringSplit($tempObbjs[0], ",", $STR_NOCOUNT) ;  will be a string : 708,360
				If UBound($tempObbj) <> 2 Then ContinueLoop
			Else
				$tempObbj = StringSplit($StringCoordinates, ",", $STR_NOCOUNT) ;  will be a string : 708,360
				If UBound($tempObbj) <> 2 Then ContinueLoop
			EndIf

			For $x = 0 To UBound($BBCheck) - 1
				If $FullImageName = $BBCheck[$x] Then
					If $g_bChkClanGamesDebug Then SetLog("Detection for " & $FullImageName & " :", $COLOR_INFO)
					If Not IsBBChallenge($tempObbj[0],$tempObbj[1]) Then
						If $g_bChkClanGamesDebug Then SetLog("False Detection, Skip this Challenge", $COLOR_ERROR)
						ContinueLoop 2
					Else
						If $g_bChkClanGamesDebug Then SetLog("OK, Continue", $COLOR_SUCCESS)
					Endif
				EndIf
			Next

			$aNames = StringSplit($FullImageName, "-", $STR_NOCOUNT)
			SetDebugLog("filename: " & $FullImageName & " $aNames[0] = " & $aNames[0] & " $aNames[1]= " & $aNames[1], $COLOR_ORANGE)
			ReDim $aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) + 1][4]
			$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][0] = $aNames[0] ; Challenge Name
			$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][1] = $aNames[1] ; Event Name
			$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][2] = $tempObbj[0] ; Xaxis
			$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][3] = $tempObbj[1] ; Yaxis
		Next
	EndIf

	Local $aSelectChallenges[0][5]

	If UBound($aAllDetectionsOnScreen) > 0 Then
		For $i = 0 To UBound($aAllDetectionsOnScreen) - 1
            ;If IsBBChallenge($aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3]) and $g_bChkClanGamesBBBattle == 0 and $g_bChkClanGamesBBDes == 0 Then ContinueLoop ; only skip if it is a BB challenge not supported

			Switch $aAllDetectionsOnScreen[$i][0]
				Case "L"
					If Not $g_bChkClanGamesLoot Then ContinueLoop
					;[0] = Path Directory , [1] = Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					; Local $g_aCGLootChallenges = $g_aCGLootChallenges
					For $j = 0 To UBound($g_aCGLootChallenges) - 1
						; If $g_aCGLootChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGLootChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $g_aCGLootChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $g_aCGLootChallenges[$j][3] = 0 Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray = [$g_aCGLootChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGLootChallenges[$j][3]]
						EndIf
					Next
				Case "A"
					If Not $g_bChkClanGamesAirTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					; Local $g_aCGAirTroopChallenges = $g_aCGAirTroopChallenges
					For $j = 0 To UBound($g_aCGAirTroopChallenges) - 1
						; If $g_aCGAirTroopChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGAirTroopChallenges[$j][0] Then
							; Verify if the Troops exist in your Army Composition
							Local $TroopIndex = Int(Eval("eTroop" & $g_aCGAirTroopChallenges[$j][1]))
							; If doesn't Exist the Troop on your Army
							If $g_aiCurrentTroops[$TroopIndex] < 1 Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGAirTroopChallenges[$j][1] & "] No " & $g_asTroopNames[$TroopIndex] & " on your army composition.")
								ExitLoop
								; If Exist BUT not is required quantities
							ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $g_aCGAirTroopChallenges[$j][3] Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGAirTroopChallenges[$j][1] & "] You need more " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $g_aCGAirTroopChallenges[$j][3] & "]")
								ExitLoop
							EndIf
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGAirTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], 1]
						EndIf
					Next

				Case "S" ; - grumpy
					If Not $g_bChkClanGamesSpell Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					; Local $g_aCGSpellChallenges = $g_aCGSpellChallenges ; load all spell challenges
					For $j = 0 To UBound($g_aCGSpellChallenges) - 1 ; loop through all challenges
						; If $g_aCGSpellChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGSpellChallenges[$j][0] Then
							; Verify if the Spell exist in your Army Composition
							Local $SpellIndex = Int(Eval("eSpell" & $g_aCGSpellChallenges[$j][1])) ; assign $SpellIndex enum second column of array is spell name line 740 in GlobalVariables
							; If doesn't Exist the Troop on your Army
							If $g_aiCurrentSpells[$SpellIndex] < 1 Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGSpellChallenges[$j][1] & "] No " & $g_asSpellNames[$SpellIndex] & " on your army composition.")
								ExitLoop
								; If Exist BUT not is required quantities
							ElseIf $g_aiCurrentSpells[$SpellIndex] > 0 And $g_aiCurrentSpells[$SpellIndex] < $g_aCGSpellChallenges[$j][3] Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGSpellChallenges[$j][1] & "] You need more " & $g_asSpellNames[$SpellIndex] & " [" & $g_aiCurrentSpells[$SpellIndex] & "/" & $g_aCGSpellChallenges[$j][3] & "]")
								ExitLoop
							EndIf
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGSpellChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], 1]
						EndIf
					Next

			   Case "G"
					If Not $g_bChkClanGamesGroundTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					; Local $g_aCGGroundTroopChallenges = $g_aCGGroundTroopChallenges
					For $j = 0 To UBound($g_aCGGroundTroopChallenges) - 1
						; If $g_aCGGroundTroopChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGGroundTroopChallenges[$j][0] Then
							; Verify if the Troops exist in your Army Composition
							Local $TroopIndex = Int(Eval("eTroop" & $g_aCGGroundTroopChallenges[$j][1]))
							; If doesn't Exist the Troop on your Army
							If $g_aiCurrentTroops[$TroopIndex] < 1 Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGGroundTroopChallenges[$j][1] & "] No " & $g_asTroopNames[$TroopIndex] & " on your army composition.")
								ExitLoop
								; If Exist BUT not is required quantities
							ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $g_aCGGroundTroopChallenges[$j][3] Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $g_aCGGroundTroopChallenges[$j][1] & "] You need more " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $g_aCGGroundTroopChallenges[$j][3] & "]")
								ExitLoop
							EndIf
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGGroundTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], 1]
						EndIf
					 Next

				Case "B"
					If Not $g_bChkClanGamesBattle Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					; Local $g_aCGBattleChallenges = $g_aCGBattleChallenges
					For $j = 0 To UBound($g_aCGBattleChallenges) - 1
						; If $g_aCGBattleChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGBattleChallenges[$j][0] Then
							; Verify the TH level and a few Challenge to destroy TH specific level
							If $g_aCGBattleChallenges[$j][1] = "Scrappy 6s" And ($g_iTownHallLevel < 5 Or $g_iTownHallLevel > 7) Then ExitLoop        ; TH level 5-6-7
							If $g_aCGBattleChallenges[$j][1] = "Super 7s" And ($g_iTownHallLevel < 6 Or $g_iTownHallLevel > 8) Then ExitLoop            ; TH level 6-7-8
							If $g_aCGBattleChallenges[$j][1] = "Exciting 8s" And ($g_iTownHallLevel < 7 Or $g_iTownHallLevel > 9) Then ExitLoop        ; TH level 7-8-9
							If $g_aCGBattleChallenges[$j][1] = "Noble 9s" And ($g_iTownHallLevel < 8 Or $g_iTownHallLevel > 10) Then ExitLoop        ; TH level 8-9-10
							If $g_aCGBattleChallenges[$j][1] = "Terrific 10s" And ($g_iTownHallLevel < 9 Or $g_iTownHallLevel > 11) Then ExitLoop    ; TH level 9-10-11
							If $g_aCGBattleChallenges[$j][1] = "Exotic 11s" And ($g_iTownHallLevel < 10 Or $g_iTownHallLevel > 12) Then ExitLoop     ; TH level 10-11-12
							If $g_aCGBattleChallenges[$j][1] = "Triumphant 12s" And $g_iTownHallLevel < 11 Then ExitLoop  ; TH level 11-12-13
						    If $g_aCGBattleChallenges[$j][1] = "Tremendous 13s" And $g_iTownHallLevel < 12 Then ExitLoop  ; TH level 12-13

							; Verify your TH level and Challenge
							If $g_iTownHallLevel < $g_aCGBattleChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $g_aCGBattleChallenges[$j][3] = 0 Then ExitLoop
							; If you are a TH13 , doesn't exist the TH14 yet
							If $g_aCGBattleChallenges[$j][1] = "Attack Up" And $g_iTownHallLevel >= 13 Then ExitLoop
							; Check your Trophy Range
							If $g_aCGBattleChallenges[$j][1] = "Slaying The Titans" And (Int($g_aiCurrentLoot[$eLootTrophy]) < 4100 or Int($g_aiCurrentLoot[$eLootTrophy]) > 5000) Then ExitLoop

						    If $g_aCGBattleChallenges[$j][1] = "Clash of Legends" And Int($g_aiCurrentLoot[$eLootTrophy]) < 5000 Then ExitLoop

							; Check if exist a probability to use any Spell
							; If $g_aCGBattleChallenges[$j][1] = "No-Magic Zone" And ($g_bSmartZapEnable = True Or ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) Then ExitLoop
							; same as above, but SmartZap as condition removed, cause SZ does not necessary triggers every attack
							If $g_aCGBattleChallenges[$j][1] = "No-Magic Zone" And (($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) Then ExitLoop
							; Check if you are using Heroes
							If $g_aCGBattleChallenges[$j][1] = "No Heroics Allowed" And ((Int($g_aiAttackUseHeroes[$DB]) > $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) > $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGBattleChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGBattleChallenges[$j][3]]
						EndIf
					Next
				Case "D"
					If Not $g_bChkClanGamesDes Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					; Local $g_aCGDestructionChallenges = $g_aCGDestructionChallenges
					For $j = 0 To UBound($g_aCGDestructionChallenges) - 1
						; If $g_aCGDestructionChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGDestructionChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $g_aCGDestructionChallenges[$j][2] Then ExitLoop

							; Disable this event from INI File
							If $g_aCGDestructionChallenges[$j][3] = 0 Then ExitLoop

							; Check if you are using Heroes
							If $g_aCGDestructionChallenges[$j][1] = "Hero Level Hunter" Or _
									$g_aCGDestructionChallenges[$j][1] = "King Level Hunter" Or _
									$g_aCGDestructionChallenges[$j][1] = "Queen Level Hunter" Or _
									$g_aCGDestructionChallenges[$j][1] = "Warden Level Hunter" And ((Int($g_aiAttackUseHeroes[$DB]) = $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) = $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGDestructionChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGDestructionChallenges[$j][3]]
						EndIf
					Next
				Case "M"
					If Not $g_bChkClanGamesMiscellaneous Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					; Local $g_aCGMiscChallenges = $g_aCGMiscChallenges
					For $j = 0 To UBound($g_aCGMiscChallenges) - 1
						; If $g_aCGMiscChallenges[$j][5] = False Then ContinueLoop
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $g_aCGMiscChallenges[$j][0] Then
							; Disable this event from INI File
							If $g_aCGMiscChallenges[$j][3] = 0 Then ExitLoop

							; Exceptions :
							; 1 - "Gardening Exercise" needs at least a Free Builder and "Remove Obstacles" enabled
							If $g_aCGMiscChallenges[$j][1] = "Gardening Exercise" And ($g_iFreeBuilderCount < 1 Or Not $g_bChkCleanYard) Then ExitLoop

							; 2 - Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $g_aCGMiscChallenges[$j][2] Then ExitLoop

							; 3 - If you don't Donate Troops
							If $g_aCGMiscChallenges[$j][1] = "Helping Hand" And Not $g_iActiveDonate Then ExitLoop

							; 4 - If you don't Donate Spells , $g_aiPrepDon[2] = Donate Spells , $g_aiPrepDon[3] = Donate All Spells [PrepareDonateCC()]
							If $g_aCGMiscChallenges[$j][1] = "Donate Spells" And ($g_aiPrepDon[2] = 0 And $g_aiPrepDon[3] = 0) Then ExitLoop

							; 5 - If you don't use Blimp
							If $g_aCGMiscChallenges[$j][1] = "Battle Blimp" And ($g_aiAttackUseSiege[$DB] = 2 Or $g_aiAttackUseSiege[$LB] = 2) And $g_aiArmyCompSiegeMachines[$eSiegeBattleBlimp] = 0 Then ExitLoop

							; 6 - If you don't use Wrecker
							If $g_aCGMiscChallenges[$j][1] = "Wall Wrecker" And ($g_aiAttackUseSiege[$DB] = 1 Or $g_aiAttackUseSiege[$LB] = 1) And $g_aiArmyCompSiegeMachines[$eSiegeWallWrecker] = 0 Then ExitLoop

							If $g_aCGMiscChallenges[$j][1] = "Stone Slammer" And ($g_aiAttackUseSiege[$DB] = 3 Or $g_aiAttackUseSiege[$LB] = 3) And $g_aiArmyCompSiegeMachines[$eSiegeStoneSlammer] = 0 Then ExitLoop

							If $g_aCGMiscChallenges[$j][1] = "Siege Barrack" And ($g_aiAttackUseSiege[$DB] = 4 Or $g_aiAttackUseSiege[$LB] = 4) And $g_aiArmyCompSiegeMachines[$eSiegeBarracks] = 0 Then ExitLoop

							If $g_aCGMiscChallenges[$j][1] = "Log Launcher" And ($g_aiAttackUseSiege[$DB] = 5 Or $g_aiAttackUseSiege[$LB] = 5) And $g_aiArmyCompSiegeMachines[$eSiegeLogLauncher] = 0 Then ExitLoop

							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$g_aCGMiscChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGMiscChallenges[$j][3]]
						EndIf
					Next
                Case "BBB" ; BB Battle challenges
                    If Not $g_bChkClanGamesBBBattle Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    ; Local $g_aCGBBBattleChallenges = $g_aCGBBBattleChallenges
                    For $j = 0 To UBound($g_aCGBBBattleChallenges) - 1
						; If $g_aCGBBBattleChallenges[$j][5] = False Then ContinueLoop
                        ; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $g_aCGBBBattleChallenges[$j][0] Then

                            ; Verify your TH level and Challenge kind
                            ; If $g_iBBTownHallLevel < $g_aCGDestructionChallenges[$j][2] Then ExitLoop ; adding soon

                            Local $aArray[4] = [$g_aCGBBBattleChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGBBBattleChallenges[$j][3]]
                        EndIf
                    Next
                Case "BBD" ; BB Destruction challenges
					If Not $g_bChkClanGamesBBDes Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    ; Local $g_aCGBBDestructionChallenges = $g_aCGBBDestructionChallenges
                    For $j = 0 To UBound($g_aCGBBDestructionChallenges) - 1
						; If $g_aCGBBDestructionChallenges[$j][5] = False Then ContinueLoop
						; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $g_aCGBBDestructionChallenges[$j][0] Then
							Local $aArray[4] = [$g_aCGBBDestructionChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGBBDestructionChallenges[$j][3]]
                        EndIf
                    Next
				Case "BBT" ; BB Troop challenges
					If Not $g_bChkClanGamesBBTroops Then ContinueLoop

                    ;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
                    ; Local $g_aCGBBTroopChallenges = $g_aCGBBTroopChallenges
                    For $j = 0 To UBound($g_aCGBBTroopChallenges) - 1
						; If $g_aCGBBTroopChallenges[$j][5] = False Then ContinueLoop
                        ; Match the names
                        If $aAllDetectionsOnScreen[$i][1] = $g_aCGBBTroopChallenges[$j][0] Then
							Local $aArray[4] = [$g_aCGBBTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $g_aCGBBTroopChallenges[$j][3]]
                        EndIf
                    Next
			EndSwitch
			If IsDeclared("aArray") And $aArray[0] <> "" Then
				ReDim $aSelectChallenges[UBound($aSelectChallenges) + 1][5]
				$aSelectChallenges[UBound($aSelectChallenges) - 1][0] = $aArray[0] ; Event Name Full Name
				$aSelectChallenges[UBound($aSelectChallenges) - 1][1] = $aArray[1] ; Xaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][2] = $aArray[2] ; Yaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][3] = $aArray[3] ; difficulty
				$aSelectChallenges[UBound($aSelectChallenges) - 1][4] = 0 ; timer minutes
				$aArray[0] = ""
			EndIf
		Next
	EndIf

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames aAllDetectionsOnScreen (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Sort by Yaxis , TOP to Bottom
	_ArraySort($aSelectChallenges, 0, 0, 0, 2)

	If UBound($aSelectChallenges) > 0 Then
		; let's get the Event timing
		For $i = 0 To UBound($aSelectChallenges) - 1
			Setlog("Detected " & $aSelectChallenges[$i][0] & " difficulty of " & $aSelectChallenges[$i][3])
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(1500) Then Return
			Local $EventHours = GetEventInformation()
			Setlog("Time: " & $EventHours & " min", $COLOR_INFO)
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(250) Then Return
			$aSelectChallenges[$i][4] = Number($EventHours)
		Next

		; let's get the 60 minutes events and remove from array
		Local $aTempSelectChallenges[0][5]
		For $i = 0 To UBound($aSelectChallenges) - 1
			If $aSelectChallenges[$i][4] = 60 And $g_bChkClanGames60 Then
				Setlog($aSelectChallenges[$i][0] & " unselected, is a 60min event!", $COLOR_INFO)
				ContinueLoop
			EndIf
			ReDim $aTempSelectChallenges[UBound($aTempSelectChallenges) + 1][5]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][0] = $aSelectChallenges[$i][0]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][1] = $aSelectChallenges[$i][1]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][2] = $aSelectChallenges[$i][2]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][3] = $aSelectChallenges[$i][3]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][4] = $aSelectChallenges[$i][4]
		Next

		; Drop to top again , because coordinates Xaxis and Yaxis
		ClickP($TabChallengesPosition, 2, 0, "#Tab")
		If _sleep(250) Then Return
		ClickDrag(807, 210, 807, 385, 500)
		If _Sleep(500) Then Return
	EndIf

	; After removing is necessary check Ubound
	If IsDeclared("aTempSelectChallenges") Then
		If UBound($aTempSelectChallenges) > 0 Then
			SetDebugLog("$aTempSelectChallenges: " & _ArrayToString($aTempSelectChallenges))
			; Sort by difficulties
			;_ArraySort($aTempSelectChallenges, 0, 0, 0, 3)

			; Sort by time
			_ArraySort($aTempSelectChallenges, 1, 4, 0, 3)

			Setlog("Next Event will be " & $aTempSelectChallenges[0][0] & " to make in " & $aTempSelectChallenges[0][4] & " min.")
			; Select and Start EVENT
			$sEventName = $aTempSelectChallenges[0][0]
			Click($aTempSelectChallenges[0][1], $aTempSelectChallenges[0][2])
			If _Sleep(1750) Then Return
			If ClickOnEvent($g_bYourAccScoreCG, $aiScoreLimit, $sEventName, $getCapture) Then Return
			; Some error occurred let's click on Challenges Tab and proceeds
			ClickP($TabChallengesPosition, 2, 0, "#Tab")
		EndIf
	EndIf

	; Lets test the Builder Base Challenges
	If $g_bChkClanGamesPurge Then
		If $g_iPurgeJobCount[$g_iCurAccount] + 1 < $g_iPurgeMax Or $g_iPurgeMax = 0 Then
			Local $Txt = $g_iPurgeMax
			If $g_iPurgeMax = 0 Then $Txt = "Unlimited"
			SetLog("Current Purge Jobs " & $g_iPurgeJobCount[$g_iCurAccount] + 1 & " at max of " & $Txt, $COLOR_INFO)
			$sEventName = "Builder Base Challenges to Purge"
			If PurgeEvent($g_sImgPurge, $sEventName, True) Then
				$g_iPurgeJobCount[$g_iCurAccount] += 1
			Else
				SetLog("No Builder Base Event found to Purge", $COLOR_WARNING)
			EndIf
		EndIf
		Return
	EndIf

	If $g_bChkClanGamesPurgeAny Then ; still have to purge, because no enabled event on setting found
		SetLog("Still have to purge, because no enabled event on setting found", $COLOR_WARNING)
		SetLog("No Event found, lets purge 1 most top event", $COLOR_WARNING)
		ForcePurgeEvent(False, True)
		ClickAway()
		If _Sleep(1000) Then Return
	Else
		SetLog("No Event found, Check your settings", $COLOR_WARNING)
		ClickAway()
		If _Sleep(2000) Then Return
	EndIf
EndFunc ;==>_ClanGames

Func ClanGameImageCopy($sImagePath, $sTempPath, $sImageType = Default)
	If $sImageType = Default Then Return
	Switch $sImageType
		Case "D"
			For $i = 0 To UBound($g_aCGDestructionChallenges) - 1
				If $g_aCGDestructionChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "DestructionChallenges: " & $g_aCGDestructionChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGDestructionChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "A"
			For $i = 0 To UBound($g_aCGAirTroopChallenges) - 1
				If $g_aCGAirTroopChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "AirTroopChallenges: " & $g_aCGAirTroopChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGAirTroopChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "G"
			For $i = 0 To UBound($g_aCGGroundTroopChallenges) - 1
				If $g_aCGGroundTroopChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "GroundTroopChallenges: " & $g_aCGGroundTroopChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGGroundTroopChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBD"
			For $i = 0 To UBound($g_aCGBBDestructionChallenges) - 1
				If $g_aCGBBDestructionChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBDestructionChallenges: " & $g_aCGBBDestructionChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGBBDestructionChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "BBT"
			For $i = 0 To UBound($g_aCGBBTroopChallenges) - 1
				If $g_aCGBBTroopChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "BBTroopChallenges: " & $g_aCGBBTroopChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGBBTroopChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case "S"
			For $i = 0 To UBound($g_aCGSpellChallenges) - 1
				If $g_aCGSpellChallenges[$i][5] = True Then
					If $g_bChkClanGamesDebug Then SetLog("[" & $i & "]" & "SpellChallenges: " & $g_aCGSpellChallenges[$i][0], $COLOR_DEBUG)
					FileCopy($sImagePath & "\" & $sImageType & "-" & $g_aCGSpellChallenges[$i][0] & "_*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
				EndIf
			Next
		Case Else
			If $g_bChkClanGamesDebug Then SetLog("Rest Challenges: " & $sImageType & "-" & "*.xml", $COLOR_DEBUG)
			FileCopy($sImagePath & "\" & $sImageType & "-" & "*.xml", $sTempPath, $FC_OVERWRITE + $FC_CREATEPATH)
	EndSwitch
EndFunc ;==>ClanGameImageCopy

Func IsClanGamesRunning($getCapture = True) ;to check whether clangames current state, return string of the state "prepare" "running" "end"
	Local $aGameTime[4] = [384, 388, 0xFFFFFF, 10]
	Local $sState = "running"
	If QuickMIS("BC1", $g_sImgWindow, 70, 100, 150, 150, $getCapture, False) Then
		SetLog("Window Opened", $COLOR_DEBUG)
		If QuickMIS("BC1", $g_sImgReward, 580, 480, 830, 570, $getCapture, False) Then
			SetLog("Your Reward is Ready", $COLOR_INFO)
			$sState = "end"
		EndIf
	Else
		If _CheckPixel($aGameTime, True) Then
			Local $sTimeRemain = getOcrTimeGameTime(380, 461) ; read Clan Games waiting time
			SetLog("Clan Games will start in " & $sTimeRemain, $COLOR_INFO)
			$g_sClanGamesTimeRemaining = $sTimeRemain
			$sState = "prepare"
		EndIf
		SetLog("Clan Games Window Not Opened", $COLOR_DEBUG)
		$sState = "Cannot open ClanGames"
	EndIf
	Return $sState
EndFunc ;==>IsClanGamesRunning

Func GetTimesAndScores()
	Local $iRestScore = -1, $sYourGameScore = "", $aiScoreLimit, $sTimeRemain = 0

	;Ocr for game time remaining
	$sTimeRemain = StringReplace(getOcrTimeGameTime(55, 470), " ", "") ; read Clan Games waiting time

	;Check if OCR returned a valid timer format
	If Not StringRegExp($sTimeRemain, "([0-2]?[0-9]?[DdHhSs]+)", $STR_REGEXPMATCH, 1) Then
		SetLog("getOcrTimeGameTime(): no valid return value (" & $sTimeRemain & ")", $COLOR_ERROR)
	EndIf

	SetLog("Clan Games time remaining: " & $sTimeRemain, $COLOR_INFO)

	; This Loop is just to check if the Score is changing , when you complete a previous events is necessary to take some time
	For $i = 0 To 10
		$sYourGameScore = getOcrYourScore(45, 530) ;  Read your Score
		If $g_bChkClanGamesDebug Then SetLog("Your OCR score: " & $sYourGameScore)
		$sYourGameScore = StringReplace($sYourGameScore, "#", "/")
		$aiScoreLimit = StringSplit($sYourGameScore, "/", $STR_NOCOUNT)
		If UBound($aiScoreLimit, 1) > 1 Then
			If $iRestScore = Int($aiScoreLimit[0]) Then ExitLoop
			$iRestScore = Int($aiScoreLimit[0])
		Else
			Return -1
		EndIf
		If _Sleep(800) Then Return
		If $i = 10 Then Return -1
	Next

	;Update Values
	$g_sClanGamesScore = $sYourGameScore
	$g_sClanGamesTimeRemaining = $sTimeRemain

	$aiScoreLimit[0] = Int($aiScoreLimit[0])
	$aiScoreLimit[1] = Int($aiScoreLimit[1])
	Return $aiScoreLimit
EndFunc   ;==>GetTimesAndScores

Func CooldownTime($getCapture = True)
	;check cooldown purge
	Local $aiCoolDown = decodeSingleCoord(findImage("Cooldown", $g_sImgCoolPurge & "\*.xml", GetDiamondFromRect("480,370,570,410"), 1, True, Default))
	If IsArray($aiCoolDown) And UBound($aiCoolDown, 1) >= 2 Then
		SetLog("Cooldown Purge Detected", $COLOR_INFO)
		ClickAway()
		Return True
	EndIf
	Return False
EndFunc   ;==>CooldownTime

Func IsEventRunning($bOpenWindow = False)
	Local $aEventFailed[4] = [300, 255, 0xEA2B24, 20]
	Local $aEventPurged[4] = [300, 266, 0x57c68f, 20]

	If $bOpenWindow Then
		ClickAway()
		SetLog("Entering Clan Games", $COLOR_INFO)
		If Not IsClanGamesWindow() Then Return
	EndIf

	; Check if any event is running or not
	If Not _ColorCheck(_GetPixelColor(300, 266, True), Hex(0x53E050, 6), 5) Then ; Green Bar from First Position
		;Check if Event failed
		If _CheckPixel($aEventFailed, True) Then
			SetLog("Couldn't finish last event! Lets trash it and look for a new one", $COLOR_INFO)
			If TrashFailedEvent() Then
				If _Sleep(3000) Then Return ;Add sleep here, to wait ClanGames Challenge Tile ordered again as 1 has been deleted
				Return False
			Else
				SetLog("Error happend while trashing failed event", $COLOR_ERROR)
				ClickAway()
				Return True
			EndIf
		ElseIf _CheckPixel($aEventPurged, True) Then
				SetLog("An event purge cooldown in progress!", $COLOR_WARNING)
				ClickAway()
				Return True
		Else
			SetLog("An event is already in progress!", $COLOR_SUCCESS)

			;check if its Enabled Challenge, if not = purge
			If QuickMIS("BC1", @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\", 300, 160, 380, 240, True, False) Then
				SetLog("Active Challenge is Enabled on Setting, OK!!", $COLOR_DEBUG)
				;check if Challenge is BB Challenge, enabling force BB attack
				If $g_bChkForceBBAttackOnClanGames Then

					Click(340,210)
					If _Sleep(1000) Then Return
					SetLog("Re-Check If Running Challenge is BB Event or No?", $COLOR_DEBUG)
					If QuickMIS("BC1", $g_sImgVersus, 425, 180, 700, 235, True, False) Then
						Setlog("Running Challenge is BB Challenge", $COLOR_INFO)
						$g_bIsBBevent = True
					Else
						Setlog("Running Challenge is MainVillage Challenge", $COLOR_INFO)
						$g_bIsBBevent = False
					EndIf
				EndIf
			Else
				Setlog("Active Challenge Not Enabled on Setting! started by mistake?", $COLOR_ERROR)
				ForcePurgeEvent(False, False)
			EndIf
			ClickAway()
			Return True
		EndIf
	Else
		SetLog("No event under progress", $COLOR_INFO)
		Return False
	EndIf
	Return False
EndFunc   ;==>IsEventRunning

Func ClickOnEvent(ByRef $g_bYourAccScoreCG, $ScoreLimits, $sEventName, $getCapture)
	If Not $g_bYourAccScoreCG[$g_iCurAccount][1] Then
		Local $Text = "", $color = $COLOR_SUCCESS
		If $g_bYourAccScoreCG[$g_iCurAccount][0] <> $ScoreLimits[0] Then
			$Text = "You on " & $ScoreLimits[0] - $g_bYourAccScoreCG[$g_iCurAccount][0] & "points in last Event"
		Else
			$Text = "You could not complete the last event!"
			$color = $COLOR_WARNING
		EndIf
		SetLog($Text, $color)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - " & $Text)
	EndIf
	$g_bYourAccScoreCG[$g_iCurAccount][1] = False
	$g_bYourAccScoreCG[$g_iCurAccount][0] = $ScoreLimits[0]
	If $g_bChkClanGamesDebug Then SetLog("ClickOnEvent $g_bYourAccScoreCG[" & $g_iCurAccount & "][1]: " & $g_bYourAccScoreCG[$g_iCurAccount][1])
	If $g_bChkClanGamesDebug Then SetLog("ClickOnEvent $g_bYourAccScoreCG[" & $g_iCurAccount & "][0]: " & $g_bYourAccScoreCG[$g_iCurAccount][0])
	If Not StartsEvent($sEventName, False, $getCapture, $g_bChkClanGamesDebug) Then Return False
	ClickAway()
	Return True
EndFunc   ;==>ClickOnEvent

Func StartsEvent($sEventName, $g_bPurgeJob = False, $getCapture = True, $g_bChkClanGamesDebug = False)
	If Not $g_bRunState Then Return

	Local $aStartButton = StartButton(True, $getCapture)
	If IsArray($aStartButton) Then
		Local $Timer = GetEventTimeInMinutes($aStartButton[0], $aStartButton[1])
		SetLog("Starting Event" & " [" & $Timer & " min]" & " Is builder base challenge? " & $g_bIsBBevent, $COLOR_SUCCESS)
		Click($aStartButton[0], $aStartButton[1])
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for " & $Timer & " min", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for " & $Timer & " min")

		If $g_bPurgeJob Then
			If _Sleep(2500) Then Return
			If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350, True, False) Then
				Click($g_iQuickMISX + 400, $g_iQuickMISY + 200)
				If _Sleep(1500) Then Return
				SetLog("Click Trash", $COLOR_INFO)
				If QuickMIS("BC1", $g_sImgOkayPurge, 440, 400, 580, 450, True, False) Then
					SetLog("Click OK", $COLOR_INFO)
					Click($g_iQuickMISX + 440, $g_iQuickMISY + 400)
					SetLog("StartsEvent and Purge job!", $COLOR_SUCCESS)
					GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ", 1)
					_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ")
					ClickAway()
				Else
					SetLog("$g_sImgOkayPurge Issue", $COLOR_ERROR)
					Return False
				EndIf
			Else
				SetLog("$g_sImgTrashPurge Issue", $COLOR_ERROR)
				Return False
			EndIf
		EndIf

		Return True
	Else
		SetLog("Didn't Get the Green Start Button Event", $COLOR_WARNING)
		If $g_bChkClanGamesDebug Then SetLog("[X: " & 220 & " Y:" & 150 & " X1: " & 830 & " Y1: " & 580 & "]", $COLOR_WARNING)
		ClickAway()
		Return False
	EndIf

EndFunc   ;==>StartsEvent

Func StartButton($bGetEventType = True, $getCapture = True)
	If $bGetEventType = True Then
		$g_bIsBBevent = False
	EndIf

    Local $aButtonPixel[2]
    If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, $getCapture, False) Then
		$aButtonPixel[0] = ($g_iQuickMISX + 220)
		$aButtonPixel[1] = ($g_iQuickMISY + 150)
		If $bGetEventType = True Then
			$g_bIsBBevent = (QuickMIS("Q1", $g_sImgBorderBB, $aButtonPixel[0] - 250, $aButtonPixel[1] - 70, $aButtonPixel[0] + 250, $aButtonPixel[1] + 70) > 0) ? (True) : (False)
		EndIf
		Return $aButtonPixel
	Else
		SetLog("Bad $g_sImgStart.", $COLOR_ERROR)
	EndIf
	Return 0
EndFunc   ;==>StartButton

Func PurgeEvent($directoryImage, $sEventName, $getCapture = True)
	SetLog("Checking Builder Base Challenges to Purge", $COLOR_DEBUG)
	; Screen coordinates for ScreenCapture
	Local $x = 281, $y = 150, $x1 = 775, $y1 = 545
	If QuickMIS("BC1", $directoryImage, $x, $y, $x1, $y1, $getCapture, False) Then
		Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
		; Start and Purge at same time
		SetLog("Starting Impossible Job to purge", $COLOR_INFO)
		If _Sleep(1500) Then Return
		If StartsEvent($sEventName, True, $getCapture, $g_bChkClanGamesDebug) Then
			ClickAway()
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>PurgeEvent

Func ForcePurgeEvent($bTest = False, $startFirst = True)
	Local $SearchArea

	Click(340,200) ;Most Top Challenge

	If _Sleep(1500) Then Return
	If $startFirst Then
		SetLog("ForcePurgeEvent: No event Found, Start and Purge a Challenge", $COLOR_INFO)
		If StartAndPurgeEvent($bTest) Then
			ClickAway()
			Return True
		EndIf
	Else
		SetLog("ForcePurgeEvent: Purge a Wrong Challenge", $COLOR_INFO)
		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350, True, False) Then
			Click($g_iQuickMISX + 400, $g_iQuickMISY + 200)
			If _Sleep(1200) Then Return
			SetLog("Click Trash", $COLOR_INFO)
			If QuickMIS("BC1", $g_sImgOkayPurge, 440, 400, 580, 450, True, False) Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click($g_iQuickMISX + 440, $g_iQuickMISY + 400)
				If _Sleep(1500) Then Return
				GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - ForcePurgeEvent: Purge a Wrong Challenge ", 1)
				_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - ForcePurgeEvent: Purge a Wrong Challenge ")
			Else
				SetLog("$g_sImgOkayPurge Issue", $COLOR_ERROR)
				Return False
			EndIf
		Else
			SetLog("$g_sImgTrashPurge Issue", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	Return False
EndFunc   ;==>ForcePurgeEvent

Func StartAndPurgeEvent($bTest = False)

	Local $aStartButton = StartButton(False)
	If IsArray($aStartButton) Then
		Local $Timer = GetEventTimeInMinutes($aStartButton[0], $aStartButton[1])
		SetLog("Starting  Event" & " [" & $Timer & " min]", $COLOR_SUCCESS)
		Click($aStartButton[0], $aStartButton[1])
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting Purge for " & $Timer & " min", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting Purge for " & $Timer & " min")

		If _Sleep(2500) Then Return
		If QuickMIS("BC1", $g_sImgTrashPurge, 400, 200, 700, 350, True, False) Then
			Click($g_iQuickMISX + 400, $g_iQuickMISY + 200)
			If _Sleep(2000) Then Return
			SetLog("Click Trash", $COLOR_INFO)
			If QuickMIS("BC1", $g_sImgOkayPurge, 440, 400, 580, 450, True, False) Then
				SetLog("Click OK", $COLOR_INFO)
				If $bTest Then Return
				Click($g_iQuickMISX + 440, $g_iQuickMISY + 400)
				SetLog("StartAndPurgeEvent event!", $COLOR_SUCCESS)
				GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - StartAndPurgeEvent: No event Found ", 1)
				_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - StartAndPurgeEvent: No event Found ")
				ClickAway()
			Else
				SetLog("$g_sImgOkayPurge Issue", $COLOR_ERROR)
				Return False
			EndIf
		Else
			SetLog("$g_sImgTrashPurge Issue", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	Return True
EndFunc

Func TrashFailedEvent()
	;Look for the red cross on failed event
	If Not ClickB("EventFailed") Then
		SetLog("Could not find the failed event icon!", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep(1000) Then Return

	;Look for the red trash event Button and press it
	If Not ClickB("TrashEvent") Then
		SetLog("Could not find the trash event button!", $COLOR_ERROR)
		Return False
	EndIf

	If _Sleep(500) Then Return
	Return True
EndFunc   ;==>TrashFailedEvent

Func GetEventTimeInMinutes($iXStartBtn, $iYStartBtn, $bIsStartBtn = True)

	Local $XAxis = $iXStartBtn - 163 ; Related to Start Button
	Local $YAxis = $iYStartBtn + 8 ; Related to Start Button

	If Not $bIsStartBtn Then
		$XAxis = $iXStartBtn - 163 ; Related to Trash Button
		$YAxis = $iYStartBtn + 8 ; Related to Trash Button
	EndIf

	Local $Ocr = getOcrEventTime($XAxis, $YAxis)
	If $Ocr = "1" Then $Ocr = "1d"
	If $Ocr = "2" Then $Ocr = "2d"
    Return ConvertOCRTime("ClanGames()", $Ocr, True)
EndFunc   ;==>GetEventTimeInMinutes

Func GetEventInformation()
	Local $aStartButton = StartButton(False)
	If IsArray($aStartButton) Then
		Return GetEventTimeInMinutes($aStartButton[0], $aStartButton[1])
	Else
		Return 0
	EndIf
EndFunc   ;==>GetEventInformation


Func IsBBChallenge($i = Default, $j = Default)

	Local $BorderX[4] = [292, 418, 546, 669]
	Local $BorderY[3] = [205, 363, 520]
	Local $iColumn, $iRow, $bReturn

	Switch $i
		Case $BorderX[0] To $BorderX[1]
			$iColumn = 1
		Case $BorderX[1] To $BorderX[2]
			$iColumn = 2
		Case $BorderX[1] To $BorderX[3]
			$iColumn = 3
		Case Else
			$iColumn = 4
	EndSwitch

	Switch $j
		Case $BorderY[0]-50 To $BorderY[1]-50
			$iRow = 1
		Case $BorderY[1]-50 To $BorderY[2]-50
			$iRow = 2
		Case Else
			$iRow = 3
	EndSwitch
	If $g_bChkClanGamesDebug Then SetLog("Row: " & $iRow & ", Column : " & $iColumn, $COLOR_DEBUG)
	For $y = 0 To 2
		For $x = 0 To 3
			If $iRow = ($y+1) And $iColumn = ($x+1) Then
				;Search image border, our image is MainVillage event border, so If found return False
				If QuickMIS("BC1", $g_sImgBorder, $BorderX[$x] - 50, $BorderY[$y] - 50, $BorderX[$x] + 50, $BorderY[$y] + 50, True, False) Then
					If $g_bChkClanGamesDebug Then SetLog("IsBBChallenge = False", $COLOR_ERROR)
					Return False
				Else
					If $g_bChkClanGamesDebug Then SetLog("IsBBChallenge = True", $COLOR_INFO)
					Return True
				EndIf
			EndIf
		Next
	Next

EndFunc ;==>IsBBChallenge

; Just for any button test
Func ClanGames($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $temp = $g_bChkClanGamesDebug
	Local $debug = $g_bDebugSetlog
	$g_bDebugSetlog = True
	$g_bChkClanGamesDebug = True
	Local $tempCurrentTroops = $g_aiCurrentTroops
	For $i = 0 To UBound($g_aiCurrentTroops) - 1
		$g_aiCurrentTroops[$i] = 50
	Next
	Local $Result = _ClanGames(True)
	$g_aiCurrentTroops = $tempCurrentTroops
	$g_bRunState = $bWasRunState
	$g_bChkClanGamesDebug = $temp
	$g_bDebugSetlog = $debug
	Return $Result
EndFunc   ;==>ClanGames

Func SaveClanGamesConfig()
	Local $aChallengesClanGamesVars = [$g_aCGLootChallenges, $g_aCGBattleChallenges, $g_aCGDestructionChallenges, $g_aCGMiscChallenges, $g_aCGAirTroopChallenges, $g_aCGGroundTroopChallenges, $g_aCGSpellChallenges, $g_aCGBBBattleChallenges, $g_aCGBBDestructionChallenges, $g_aCGBBTroopChallenges]

	_Ini_Clear()

	Local $aTmp, $iKey
	; Loop through the CG strings
	For $i = 0 To UBound($g_aChallengesClanGamesStrings) - 1

		; Loop through the CG Vars
		$aTmp = $aChallengesClanGamesVars[$i]

		For $j = 0 To UBound($aTmp) - 1

			; Write the new value to the file
			_Ini_Add($g_aChallengesClanGamesStrings[$i], $aTmp[$j][1], $aTmp[$j][3])

			; Write boolean status
			_Ini_Add($g_aChallengesClanGamesStrings[$i], $aTmp[$j][1] & " Chk", $aTmp[$j][5])

		Next

	Next

	_Ini_Save($g_sProfileClanGamesPath)
EndFunc   ;==>SaveClanGamesConfig


Func ReadClanGamesConfig()
	Local $aChallengesClanGamesVars = [$g_aCGLootChallenges, $g_aCGBattleChallenges, $g_aCGDestructionChallenges, $g_aCGMiscChallenges, $g_aCGAirTroopChallenges, $g_aCGGroundTroopChallenges, $g_aCGSpellChallenges, $g_aCGBBBattleChallenges, $g_aCGBBDestructionChallenges, $g_aCGBBTroopChallenges]

	SetDebugLog("Read Clan Games Config " & $g_sProfileClanGamesPath)

	Local $aTmp, $iKey
	; Loop through the CG strings
	For $i = 0 To UBound($g_aChallengesClanGamesStrings) - 1

		; Loop through the CG Vars
		$aTmp = $aChallengesClanGamesVars[$i]

		For $j = 0 To UBound($aTmp) - 1

			; Write the new value to the file
			IniReadSCG($g_aChallengesClanGamesStrings[$i], $j, 3, $g_sProfileClanGamesPath, $g_aChallengesClanGamesStrings[$i], 		$aTmp[$j][1], 	$aTmp[$j][3], "Int")

			; Write boolean status
			IniReadSCG($g_aChallengesClanGamesStrings[$i], $j, 5, $g_sProfileClanGamesPath, $g_aChallengesClanGamesStrings[$i], $aTmp[$j][1] & " Chk", 	$aTmp[$j][5], "Bool")

		Next

	Next

EndFunc   ;==>ReadClanGamesConfig

Func IniReadSCG($sTring, $i, $j, $PrimaryInputFile, $section, $key, $defaultvalue, $valueType = Default)

	Switch $sTring
		Case "Loot Challenges"
			IniReadS($g_aCGLootChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Air Troop Challenges"
			IniReadS($g_aCGAirTroopChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Ground Troop Challenges"
			IniReadS($g_aCGGroundTroopChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Battle Challenges"
			IniReadS($g_aCGBattleChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Destruction Challenges"
			IniReadS($g_aCGDestructionChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Misc Challenges"
			IniReadS($g_aCGMiscChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "Spell Challenges"
			IniReadS($g_aCGSpellChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "BB Battle Challenges"
			IniReadS($g_aCGBBBattleChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "BB Destruction Challenges"
			IniReadS($g_aCGBBDestructionChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case "BB Troop Challenges"
			IniReadS($g_aCGBBTroopChallenges[$i][$j], $PrimaryInputFile, $section, $key, $defaultvalue, $valueType)
		Case Else
			SetLog("Badly IniReadSCG: " & $sTring, $COLOR_ERROR)
	EndSwitch

EndFunc   ;==>IniReadSCG

; $g_hCGLootChallenges[6][6]
; $g_hCGAirTroopChallenges[14][6]
; $g_hCGGroundTroopChallenges[27][6]
; $g_hCGBattleChallenges[20][6]
; $g_hCGDestructionChallenges[32][6]
; $g_hCGMiscChallenges[3][6]
; $g_hCGSpellChallenges[11][6]
; $g_hCGBBBattleChallenges[4][6]
; $g_hCGBBDestructionChallenges[15][6]
; $g_hCGBBTroopChallenges[11][6]

; $g_aCGLootChallenges[6][6]
; $g_aCGAirTroopChallenges[14][6]
; $g_aCGGroundTroopChallenges[27][6]
; $g_aCGBattleChallenges[20][6]
; $g_aCGDestructionChallenges[32][6]
; $g_aCGMiscChallenges[3][6]
; $g_aCGSpellChallenges[11][6]
; $g_aCGBBBattleChallenges[4][6]
; $g_aCGBBDestructionChallenges[15][6]
; $g_aCGBBTroopChallenges[11][6]

Func ApplyConfig_ClanGames($TypeReadSave)
	; <><><><> ApplyConfig_ClanGames <><><><>
	Switch $TypeReadSave
		Case "Read"
			; $g_hCGLootChallenges
			For $i = 0 To Ubound($g_hCGLootChallenges) -1
				If $g_hCGLootChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGLootChallenges[$i], $g_aCGLootChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_aCGAirTroopChallenges
			For $i = 0 To Ubound($g_hCGAirTroopChallenges) -1
				If $g_hCGAirTroopChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGAirTroopChallenges[$i], $g_aCGAirTroopChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGGroundTroopChallenges
			For $i = 0 To Ubound($g_hCGGroundTroopChallenges) -1
				If $g_hCGGroundTroopChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGGroundTroopChallenges[$i], $g_aCGGroundTroopChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGBattleChallenges
			For $i = 0 To Ubound($g_hCGBattleChallenges) -1
				If $g_hCGBattleChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGBattleChallenges[$i], $g_aCGBattleChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGDestructionChallenges
			For $i = 0 To Ubound($g_hCGDestructionChallenges) -1
				If $g_hCGDestructionChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGDestructionChallenges[$i], $g_aCGDestructionChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGMiscChallenges
			For $i = 0 To Ubound($g_hCGMiscChallenges) -1
				If $g_hCGMiscChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGMiscChallenges[$i], $g_aCGMiscChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGSpellChallenges
			For $i = 0 To Ubound($g_hCGSpellChallenges) -1
				If $g_hCGSpellChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGSpellChallenges[$i], $g_aCGSpellChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGBBBattleChallenges
			For $i = 0 To Ubound($g_hCGBBBattleChallenges) -1
				If $g_hCGBBBattleChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGBBBattleChallenges[$i], $g_aCGBBBattleChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGBBDestructionChallenges
			For $i = 0 To Ubound($g_hCGBBDestructionChallenges) -1
				If $g_hCGBBDestructionChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGBBDestructionChallenges[$i], $g_aCGBBDestructionChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

			; $g_hCGBBTroopChallenges
			For $i = 0 To Ubound($g_hCGBBTroopChallenges) -1
				If $g_hCGBBTroopChallenges[$i] = "" Then ContinueLoop
				GUICtrlSetState($g_hCGBBTroopChallenges[$i], $g_aCGBBTroopChallenges[$i][5] ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next

		Case "Save"
			; $g_aCGLootChallenges
			For $i = 0 To Ubound($g_hCGLootChallenges) -1
				If $g_hCGLootChallenges[$i] = "" Then ContinueLoop
				$g_aCGLootChallenges[$i][5] = (GUICtrlRead($g_hCGLootChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGAirTroopChallenges
			For $i = 0 To Ubound($g_hCGAirTroopChallenges) -1
				If $g_hCGAirTroopChallenges[$i] = "" Then ContinueLoop
				$g_aCGAirTroopChallenges[$i][5] = (GUICtrlRead($g_hCGAirTroopChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGGroundTroopChallenges
			For $i = 0 To Ubound($g_hCGGroundTroopChallenges) -1
				If $g_hCGGroundTroopChallenges[$i] = "" Then ContinueLoop
				$g_aCGGroundTroopChallenges[$i][5] = (GUICtrlRead($g_hCGGroundTroopChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGBattleChallenges
			For $i = 0 To Ubound($g_hCGBattleChallenges) -1
				If $g_hCGBattleChallenges[$i] = "" Then ContinueLoop
				$g_aCGBattleChallenges[$i][5] = (GUICtrlRead($g_hCGBattleChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGDestructionChallenges
			For $i = 0 To Ubound($g_hCGDestructionChallenges) -1
				If $g_hCGDestructionChallenges[$i] = "" Then ContinueLoop
				$g_aCGDestructionChallenges[$i][5] = (GUICtrlRead($g_hCGDestructionChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGMiscChallenges
			For $i = 0 To Ubound($g_hCGMiscChallenges) -1
				If $g_hCGMiscChallenges[$i] = "" Then ContinueLoop
				$g_aCGMiscChallenges[$i][5] = (GUICtrlRead($g_hCGMiscChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGSpellChallenges
			For $i = 0 To Ubound($g_hCGSpellChallenges) -1
				If $g_hCGSpellChallenges[$i] = "" Then ContinueLoop
				$g_aCGSpellChallenges[$i][5] = (GUICtrlRead($g_hCGSpellChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGBBBattleChallenges
			For $i = 0 To Ubound($g_hCGBBBattleChallenges) -1
				If $g_hCGBBBattleChallenges[$i] = "" Then ContinueLoop
				$g_aCGBBBattleChallenges[$i][5] = (GUICtrlRead($g_hCGBBBattleChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGBBDestructionChallenges
			For $i = 0 To Ubound($g_hCGBBDestructionChallenges) -1
				If $g_hCGBBDestructionChallenges[$i] = "" Then ContinueLoop
				$g_aCGBBDestructionChallenges[$i][5] = (GUICtrlRead($g_hCGBBDestructionChallenges[$i]) = $GUI_CHECKED)
			Next

			; $g_aCGBBTroopChallenges
			For $i = 0 To Ubound($g_hCGBBTroopChallenges) -1
				If $g_hCGBBTroopChallenges[$i] = "" Then ContinueLoop
				$g_aCGBBTroopChallenges[$i][5] = (GUICtrlRead($g_hCGBBTroopChallenges[$i]) = $GUI_CHECKED)
			Next
	EndSwitch
EndFunc   ;==>ApplyConfig_ClanGames
; #FUNCTION# ====================================================================================================================
; Name ..........: Smart Milk
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: None
; Return values .: None
; Author ........: ProMac (2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_iRemainTimeToZap = 90

Func TestSmartMilk($bFast = True)

	$g_iDetectedImageType = 0

	; Getting the Run state
	Local $RuntimeA = $g_bRunState
	$g_bRunState = True

	Local $bDebugSmartFarmTemp = $g_bDebugSmartFarm
	Local $bDebugSmartMilkTemp = $g_bDebugSmartMilk
	$g_bDebugSmartMilk = True
	$g_bDebugSmartFarm = True

	Setlog("Starting the SmartMilk Attack Test()", $COLOR_INFO)
	If $bFast = False Then
		checkMainScreen(False)
		CheckIfArmyIsReady()
		ClickP($aAway, 2, 0, "") ;Click Away
		If _Sleep(100) Then Return FuncReturn()
		If (IsSearchModeActive($DB) And checkCollectors(True, False)) Or IsSearchModeActive($LB) Then
			If _Sleep(100) Then Return FuncReturn()
			PrepareSearch()
			If _Sleep(1000) Then Return FuncReturn()
			VillageSearch()
			If $g_bOutOfGold Then Return ; Check flag for enough gold to search
			If _Sleep(100) Then Return FuncReturn()
		Else
			SetLog("Your Army is not prepared, check the Attack/train options")
		EndIf
	EndIf
	PrepareAttack($g_iMatchMode)

	$g_bAttackActive = True

	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	SmartFarmMilk(True)

	ReturnHome($g_bTakeLootSnapShot, False)

	Setlog("Finish the SmartMilk Attack()", $COLOR_INFO)

	$g_bRunState = $RuntimeA
	$g_bDebugSmartFarm = $bDebugSmartFarmTemp
	$g_bDebugSmartMilk = $bDebugSmartMilkTemp

EndFunc   ;==>TestSmartFarm

Func SmartFarmMilk($bDebug = False)
	If $bDebug = False Then
		If $g_iMatchMode <> $DB And $g_aiAttackAlgorithm[$DB] <> 3 Then 
			Return
		EndIf
	EndIf
	
	$g_bIsCCDropped = False
	$g_aiDeployCCPosition[0] = -1
	$g_aiDeployCCPosition[1] = -1
	$g_bIsHeroesDropped = False
	$g_aiDeployHeroesPosition[0] = -1
	$g_aiDeployHeroesPosition[1] = -1

	Local $hTimer = TimerInit()
	_CaptureRegion2()
	ConvertInternalExternArea("ChkSmartMilk")
	SuspendAndroid()
	If $g_bUseSmartFarmRedLine Then
		SetDebugLog("Using Green Tiles -> Red Lines -> Edges")
		NewRedLines()
	Else
		SetDebugLog("Classic Redlines, mix with edges.")
		_GetRedArea()
	EndIf
	ResumeAndroid()
	SetLog(" ====== Start Smart Milking ====== ", $COLOR_INFO)
	Local Enum $eGiantSlot, $eBarbSlot, $eArchSlot, $eGoblSlot, $eBabyDSlot, $eMiniSlot
	Local $aSlots2deploy[6][4] = [[-1,-1,-1,-1], [-1,-1,-1,-1], [-1,-1,-1,-1], [-1,-1,-1,-1], [-1,-1,-1,-1], [-1,-1,-1,-1]]
	Local $UsedZap = False
	For $i = 0 To UBound($g_avAttackTroops) - 1
		Switch $g_avAttackTroops[$i][0]
			Case $eGiant, $eSGiant
				$aSlots2deploy[$eGiantSlot][0] = $i
				$aSlots2deploy[$eGiantSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eGiantSlot][2] = TranslateTroopsCount($eGiant, $eSGiant, $g_avAttackTroops[$i][0], Random(1, 2, 1))
				$aSlots2deploy[$eGiantSlot][3] = $g_avAttackTroops[$i][0]
			Case $eBarb, $eSBarb
				$aSlots2deploy[$eBarbSlot][0] = $i
				$aSlots2deploy[$eBarbSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eBarbSlot][2] = TranslateTroopsCount($eBarb, $eSBarb, $g_avAttackTroops[$i][0], Random(3, 6, 1))
				$aSlots2deploy[$eBarbSlot][3] = $g_avAttackTroops[$i][0]
			Case $eArch, $eSArch
				$aSlots2deploy[$eArchSlot][0] = $i
				$aSlots2deploy[$eArchSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eArchSlot][2] = TranslateTroopsCount($eArch, $eSArch, $g_avAttackTroops[$i][0], Random(3, 6, 1))
				$aSlots2deploy[$eArchSlot][3] = $g_avAttackTroops[$i][0]
			Case $eGobl, $eSGobl
				$aSlots2deploy[$eGoblSlot][0] = $i
				$aSlots2deploy[$eGoblSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eGoblSlot][2] = TranslateTroopsCount($eGobl, $eSGobl, $g_avAttackTroops[$i][0], Random(5, 6, 1))
				$aSlots2deploy[$eGoblSlot][3] = $g_avAttackTroops[$i][0]
			Case $eBabyD, $eInfernoD
				$aSlots2deploy[$eBabyDSlot][0] = $i
				$aSlots2deploy[$eBabyDSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eBabyDSlot][2] = TranslateTroopsCount($eBabyD, $eInfernoD, $g_avAttackTroops[$i][0], 1)
				$aSlots2deploy[$eBabyDSlot][3] = $g_avAttackTroops[$i][0]
			Case $eMini, $eSMini
				$aSlots2deploy[$eMiniSlot][0] = $i
				$aSlots2deploy[$eMiniSlot][1] = $g_avAttackTroops[$i][1]
				$aSlots2deploy[$eMiniSlot][2] = TranslateTroopsCount($eMini, $eSMini, $g_avAttackTroops[$i][0], Random(4, 6, 1))
				$aSlots2deploy[$eMiniSlot][3] = $g_avAttackTroops[$i][0]
		EndSwitch
	Next
	; _ArrayDisplay($aSlots2deploy)
	Switch $g_iMilkStrategyArmy
		Case 0
			If $aSlots2deploy[$eBabyDSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eBabyDSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eBabyDSlot][0])
			EndIf
		Case 1
			If $aSlots2deploy[$eBarbSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eBarbSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eBarbSlot][0])
			EndIf
		Case 2
			If $aSlots2deploy[$eArchSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eArchSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eArchSlot][0])
			EndIf
		Case 3
			If $aSlots2deploy[$eGiantSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eGiantSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eGiantSlot][0])
			EndIf
		Case 4
			If $aSlots2deploy[$eGoblSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eGoblSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eGoblSlot][0])
			EndIf
		Case 5
			If $aSlots2deploy[$eMiniSlot][0] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eMiniSlot][0])
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$eMiniSlot][0])
			EndIf
		Case Else
			If IsAttackPage() Then SelectDropTroop(0)
			If _Sleep($DELAYLAUNCHTROOP23) Then Return
			If IsAttackPage() Then SelectDropTroop(0)
	EndSwitch
	If $g_bDebugSmartMilk Then SetLog("$aSlots2deploy: " & _ArrayToString($aSlots2deploy, "-", -1, -1, "|"))
	If $g_bDebugSmartMilk Then SetLog("$g_iMilkStrategyArmy: " & $g_iMilkStrategyArmy)
	Local $allPossibleDeployPoints[0][2], $HeroesDeployJustInCase[2], $sSide = ""
	For $iLoops = 0 To 2
		$hTimer = TimerInit()
		Local $aCollectorsTL[0][6], $aCollectorsTR[0][6], $aCollectorsBL[0][6], $aCollectorsBR[0][6]
		If $g_bDebugSmartMilk Then SetLog("Attack loop: " & $iLoops)
		SuspendAndroid()
		Local $aCollectorsAll = SmartFarmDetection("Milk")
		SetDebugLog(" TOTAL detection Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
		ResumeAndroid()
		If IsArray($aCollectorsAll) And UBound($aCollectorsAll) > 0 Then
			For $collector = 0 To UBound($aCollectorsAll) - 1
				Switch $aCollectorsAll[$collector][4]
					Case "TL"
						ReDim $aCollectorsTL[UBound($aCollectorsTL) + 1][6]
						For $t = 0 To 5
							$aCollectorsTL[UBound($aCollectorsTL) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $iLoops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiTopLeftDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiTopLeftDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "TR"
						ReDim $aCollectorsTR[UBound($aCollectorsTR) + 1][6]
						For $t = 0 To 5
							$aCollectorsTR[UBound($aCollectorsTR) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $iLoops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiTopRightDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiTopRightDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "BL"
						ReDim $aCollectorsBL[UBound($aCollectorsBL) + 1][6]
						For $t = 0 To 5
							$aCollectorsBL[UBound($aCollectorsBL) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $iLoops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiBottomLeftDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiBottomLeftDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "BR"
						ReDim $aCollectorsBR[UBound($aCollectorsBR) + 1][6]
						For $t = 0 To 5
							$aCollectorsBR[UBound($aCollectorsBR) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $iLoops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiBottomRightDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiBottomRightDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
				EndSwitch
			Next
			If $g_bDebugSmartMilk And $iLoops = 0 Then
				SetLog("$aCollectorsAll: " & _ArrayToString($aCollectorsAll, "-", -1, -1, "|"))
				DebugImageSmartMilk($aCollectorsAll, Round(TimerDiff($hTimer) / 1000, 2) & "'s", $HeroesDeployJustInCase)
			EndIf
			Local $iRandom = Random(0, 3, 1)
			Local $aAllBySide[4]
			Switch $iRandom
				Case 0
					$aAllBySide[0] = $aCollectorsBL
					$aAllBySide[1] = $aCollectorsBR
					$aAllBySide[2] = $aCollectorsTR
					$aAllBySide[3] = $aCollectorsTL
				Case 1
					$aAllBySide[0] = $aCollectorsBR
					$aAllBySide[1] = $aCollectorsTR
					$aAllBySide[2] = $aCollectorsTL
					$aAllBySide[3] = $aCollectorsBL
				Case 2
					$aAllBySide[0] = $aCollectorsTR
					$aAllBySide[1] = $aCollectorsTL
					$aAllBySide[2] = $aCollectorsBL
					$aAllBySide[3] = $aCollectorsBR
				Case 3
					$aAllBySide[0] = $aCollectorsTL
					$aAllBySide[1] = $aCollectorsBL
					$aAllBySide[2] = $aCollectorsBR
					$aAllBySide[3] = $aCollectorsTR
			EndSwitch
			Local $iTroopsDistance = 70
			If $aSlots2deploy[$eBabyDSlot][0] = -1 Then
				$iTroopsDistance = 30
			EndIf
			Local $aLastPosition[2]
			For $sSide = 0 To 3
				If $g_bDebugSmartMilk Then SetLog("Attack Side :" & $sSide)
				Local $aSideCollectors = $aAllBySide[$sSide]
				If $g_bDebugSmartMilk Then SetLog("$aSideCollectors: " & _ArrayToString($aSideCollectors, "-", -1, -1, "|"))
				_ArraySort($aSideCollectors, 0, 0, 0, 0)
				If $g_bDebugSmartMilk Then SetLog("$aSideCollectors after sort: " & _ArrayToString($aSideCollectors, "-", -1, -1, "|"))
				Local $aLastPosition = [0, 0]
				For $collector = 0 To UBound($aSideCollectors) - 1
					If $g_bDebugSmartMilk Then SetLog("Pixel_Distance : " & Pixel_Distance($aSideCollectors[$collector][0], $aSideCollectors[$collector][1], $aLastPosition[0], $aLastPosition[1]))
					If Pixel_Distance($aSideCollectors[$collector][0], $aSideCollectors[$collector][1], $aLastPosition[0], $aLastPosition[1]) > $iTroopsDistance Then
						$aLastPosition[0] = $aSideCollectors[$collector][0]
						$aLastPosition[1] = $aSideCollectors[$collector][1]
						Local $aNear = $aSideCollectors[$collector][5]
						If $g_bDebugSmartMilk Then SetLog("$aNear: " & $aNear)
						Local $aNearPoints[0][2]
						Local $aTempObbj = StringSplit($aNear, "|")
						Local $aNearPoint, $iDPCount = 0
						For $t = 1 To $aTempObbj[0]
							ReDim $aNearPoints[$iDPCount + 1][2]
							$aNearPoint = StringSplit($aTempObbj[$t], ",")
							If $aNearPoint[0] <> 2 Then ContinueLoop
							$aNearPoints[$iDPCount][0] = $aNearPoint[1]
							$aNearPoints[$iDPCount][1] = $aNearPoint[2]
							$iDPCount += 1
						Next
						
						Local $iDPNP = (UBound($aNearPoints) > 2) ? (2) : (0)
						Local $aDeployPoint = [$aNearPoints[$iDPNP][0], $aNearPoints[$iDPNP][1]]
						
						If $iLoops = 0 Then
							ReDim $allPossibleDeployPoints[UBound($allPossibleDeployPoints) + 1][2]
							$allPossibleDeployPoints[UBound($allPossibleDeployPoints) - 1][0] = $aDeployPoint[0]
							$allPossibleDeployPoints[UBound($allPossibleDeployPoints) - 1][0] = $aDeployPoint[1]
						EndIf
						For $aTroopSlot = 0 To UBound($aSlots2deploy) - 1
							If $aSlots2deploy[$aTroopSlot][1] > 0 Then
								If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$aTroopSlot][0])
								If _Sleep($DELAYLAUNCHTROOP23 * 2) Then Return
								If $g_bDebugSmartMilk Then SetLog("AttackClick: " & $aDeployPoint[0] & "," & $aDeployPoint[1])
								AttackClick($aDeployPoint[0], $aDeployPoint[1], $aSlots2deploy[$aTroopSlot][2], 100, 0, "#0098")
								$aSlots2deploy[$aTroopSlot][1] -= $aSlots2deploy[$aTroopSlot][2]
								SetLog("Deployed " & GetTroopName($aSlots2deploy[$aTroopSlot][3], Number($aSlots2deploy[$aTroopSlot][2])) & " " & $aSlots2deploy[$aTroopSlot][2] & "x")
								If $g_bDebugSmartMilk Then SetLog("Remains - " & GetTroopName($aSlots2deploy[$aTroopSlot][3]) & " " & $aSlots2deploy[$aTroopSlot][1] & "x")
								If _Sleep($DELAYLAUNCHTROOP23) Then Return
							EndIf
						Next
						If _Sleep($DELAYLAUNCHTROOP23) Then Return
					Else
						If $g_bDebugSmartMilk Then SetLog("Pixel (" & $aSideCollectors[$collector][0] & "," & $aSideCollectors[$collector][1] & ") doesn't have the min distance to deploy..")
					EndIf
				Next
			Next
			For $f = 0 To 7
				If _Sleep(2000) Then Return
				$g_iPercentageDamage = Number(getOcrOverAllDamage(780, 527 + $g_iBottomOffsetY))
				Local $sTime = _getBattleEnds()
				Local $iTime = ConvertTime($sTime)
				SetLog("Overall Damage is " & $g_iPercentageDamage & "%", $COLOR_INFO)
				SetLog("Battle ends in: " & _getBattleEnds() & " | remain in seconds is " & $iTime & "s", $COLOR_INFO)
				If IsAttackPage() And (($g_iRemainTimeToZap > $iTime And $g_iRemainTimeToZap <> 0) Or $iTime < 45) And Not $UsedZap Then
					SetLog("let's ZAP, even with troops on the ground", $COLOR_INFO)
					smartZap()
					$UsedZap = True
				EndIf
				If ($g_bIsHeroesDropped) Then
					CheckHeroesHealth()
				EndIf
			Next
		EndIf
		$g_iPercentageDamage = Number(getOcrOverAllDamage(780, 527 + $g_iBottomOffsetY))
		If $g_iPercentageDamage > 50 Then
			If $iLoops = 0 Then
				SetLog("Reached " & $g_iPercentageDamage & "% lets Check if exist any resource!", $COLOR_SUCCESS)
				ContinueLoop
			Else
				SetLog("Reached " & $g_iPercentageDamage & "% lets Exit!", $COLOR_SUCCESS)
				ExitLoop
			EndIf
		EndIf
		If ($g_iPercentageDamage > 30 And $iLoops <> 0) Or ($g_bChkMilkForceDeployHeroes And $iLoops <> 0) Then
			Local $iKingSlot = Not $g_bDropKing ? $g_iKingSlot : -1
			Local $iQueenSlot = Not $g_bDropQueen ? $g_iQueenSlot : -1
			Local $iWardenSlot = Not $g_bDropWarden ? $g_iWardenSlot : -1
			Local $iChampionSlot = Not $g_bDropChampion ? $g_iChampionSlot : -1
			Local $iCC = Not $g_bIsCCDropped ? $g_iClanCastleSlot : -1
			If $iKingSlot <> -1 Or $iQueenSlot <> -1 Or $iWardenSlot <> -1 Or $iChampionSlot <> -1 Or $iCC <> -1 Then
				SetLog("Dropping Heros & CC at " & $sSide & " - " & _ArrayToString($HeroesDeployJustInCase, "|", -1, -1, " "), $COLOR_SUCCESS)
				dropHeroes($HeroesDeployJustInCase[0], $HeroesDeployJustInCase[1], $iKingSlot, $iQueenSlot, $iWardenSlot, $iChampionSlot, True)
				$g_bIsHeroesDropped = True
				dropCC($HeroesDeployJustInCase[0], $HeroesDeployJustInCase[1], $iCC)
				$g_bIsCCDropped = True
				CheckHeroesHealth()
			EndIf
			If IsAttackPage() And (($g_iRemainTimeToZap > $iTime And $g_iRemainTimeToZap <> 0) Or $iTime < 45) And Not $UsedZap Then
				SetLog("let's ZAP, even with troops on the ground", $COLOR_INFO)
				smartZap()
				$UsedZap = True
			EndIf
		EndIf
		If $iLoops = 2 And $g_bChkMilkForceAllTroops Then
			SetLog("Let's deploy all remain troops!", $COLOR_INFO)
			SetDebugLog("How many last deploy points: " & UBound($allPossibleDeployPoints))
			For $point = 0 To UBound($allPossibleDeployPoints) - 1
				CheckHeroesHealth()
				For $aTroopSlot = 0 To UBound($aSlots2deploy) - 1
					If $aSlots2deploy[$aTroopSlot][1] > 0 Then
						If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$aTroopSlot][0])
						If _Sleep($DELAYLAUNCHTROOP23 * 2) Then Return
						If $g_bDebugSmartMilk Then SetLog("AttackClick: " & $allPossibleDeployPoints[$point][0] & "," & $allPossibleDeployPoints[$point][1])
						AttackClick($allPossibleDeployPoints[$point][0], $allPossibleDeployPoints[$point][1], $aSlots2deploy[$aTroopSlot][2], 100, 0, "#0098")
						$aSlots2deploy[$aTroopSlot][1] -= $aSlots2deploy[$aTroopSlot][2]
						SetLog("Deployed " & GetTroopName($aSlots2deploy[$aTroopSlot][3], Number($aSlots2deploy[$aTroopSlot][2])) & " " & $aSlots2deploy[$aTroopSlot][2] & "x")
						If $g_bDebugSmartMilk Then SetLog("Remains - " & GetTroopName($aSlots2deploy[$aTroopSlot][3]) & " " & $aSlots2deploy[$aTroopSlot][1] & "x")
						If _Sleep($DELAYLAUNCHTROOP23) Then Return
					EndIf
				Next
			Next
			If _Sleep($DELAYALGORITHM_ALLTROOPS4) Then Return
			SetLog("Dropping left over troops", $COLOR_INFO)
			For $x = 0 To 1
				If PrepareAttack($g_iMatchMode, True) = 0 Then
					If $g_bDebugSetlog Then SetDebugLog("No Wast time... exit, no troops usable left", $COLOR_DEBUG)
					ExitLoop
				EndIf
				For $i = $eBarb To $eHunt
					If LaunchTroop($i, 2, 1, 1, 1) Then
						CheckHeroesHealth()
						If _Sleep($DELAYALGORITHM_ALLTROOPS5) Then Return
					EndIf
				Next
			Next
		EndIf
		If IsAttackPage() And (($g_iRemainTimeToZap > $iTime And $g_iRemainTimeToZap <> 0) Or $iTime < 45) And Not $UsedZap Then
			SetLog("let's ZAP, even with troops on the ground", $COLOR_INFO)
			smartZap()
			$UsedZap = True
		EndIf
	Next
	SetLog("Finished Attacking, waiting for the battle to end")
	Return True
EndFunc   ;==>SmartFarmMilk

Func TranslateTroopsCount($iLow, $iHigh, $iTroopID, $iLowCount)
	Local $iResult = 1
	If $iLow <> $iTroopID Then 
		$iResult = Abs(Round(($g_aiTroopSpace[$iLow] * $iLowCount) / $g_aiTroopSpace[$iHigh]))
	Else
		$iResult = $iLow
	EndIf
	If $iResult < 1 Then 
		$iResult = 1
	EndIf
	Return $iResult
EndFunc   ;==>TranslateTroopsCount

Func DebugImageSmartMilk($aCollectorsAll, $sTime, $HeroesDeployJustInCase)
	_CaptureRegion()
	Local $EditedImage = $g_hBitmap
	Local $subDirectory = $g_sProfileTempDebugPath & "\SmartMilk\"
	DirCreate($subDirectory)
	Local $date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $Filename = "SmartMilk" & "_" & $date & "_" & $Time & ".png"
	Local $fileNameUntouched = "SmartMilk" & "_" & $date & "_" & $Time & "_1.png"
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($EditedImage)
	Local $hPen = _GDIPlus_PenCreate(0xFFFF0000, 2)
	Local $hPen2 = _GDIPlus_PenCreate(0xFF000000, 2)
	$hPen2 = _GDIPlus_PenCreate(0xFFFFFFFF, 2)
	_GDIPlus_GraphicsDrawRect($hGraphic, $DiamondMiddleX - 5, $DiamondMiddleY - 5, 10, 10, $hPen2)
	$hPen2 = _GDIPlus_PenCreate(0xFFFFFFFF, 1)
	_GDIPlus_GraphicsDrawLine($hGraphic, 0, $DiamondMiddleY, 860, $DiamondMiddleY, $hPen2)
	_GDIPlus_GraphicsDrawLine($hGraphic, $DiamondMiddleX, 0, $DiamondMiddleX, 644, $hPen2)
	$hPen2 = _GDIPlus_PenCreate(0xFF000000, 2)
	Local $tempObbj, $tempObbjs
	If $HeroesDeployJustInCase[0] <> Null And $HeroesDeployJustInCase[1] > 0 Then
		_GDIPlus_GraphicsDrawRect($hGraphic, $HeroesDeployJustInCase[0] - 10, $HeroesDeployJustInCase[1] - 10, 20, 20, $hPen2)
	EndIf
	For $i = 0 To UBound($aCollectorsAll) - 1
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $aCollectorsAll[$i][0] - 7, $aCollectorsAll[$i][1] - 7, 14, 14, $hPen)
		If StringInStr($aCollectorsAll[$i][5], "|") Then
			$tempObbj = StringSplit($aCollectorsAll[$i][5], "|", $STR_NOCOUNT)
			For $t = 0 To UBound($tempObbj) - 1
				$tempObbjs = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
				Local $penn = $hPen2
				If $t = 2 Then $penn = $hPen
				If UBound($tempObbjs) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbjs[0] - 2, $tempObbjs[1] - 2, 4, 4, $penn)
			Next
		Else
			$tempObbj = StringSplit($aCollectorsAll[$i][5], ",", $STR_NOCOUNT)
			If UBound($tempObbj) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbj[0] - 2, $tempObbj[1] - 2, 4, 4, $hPen2)
		EndIf
		$tempObbj = Null
		$tempObbjs = Null
	Next
	$hPen2 = _GDIPlus_PenCreate(0xFF336EFF, 2)
	Local $pixel
	For $i = 0 To UBound($g_aiPixelTopLeft) - 1
		$pixel = $g_aiPixelTopLeft[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelTopRight) - 1
		$pixel = $g_aiPixelTopRight[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomLeft) - 1
		$pixel = $g_aiPixelBottomLeft[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomRight) - 1
		$pixel = $g_aiPixelBottomRight[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	$hPen2 = _GDIPlus_PenCreate(0xFF6EFF33, 2)
	For $i = 0 To UBound($g_aiPixelTopLeftFurther) - 1
		$pixel = $g_aiPixelTopLeftFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelTopRightFurther) - 1
		$pixel = $g_aiPixelTopRightFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomLeftFurther) - 1
		$pixel = $g_aiPixelBottomLeftFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomRightFurther) - 1
		$pixel = $g_aiPixelBottomRightFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	_GDIPlus_GraphicsDrawString($hGraphic, $sTime, 370, 70, "ARIAL", 20)
	_GDIPlus_ImageSaveToFile($EditedImage, $subDirectory & $Filename)
	_CaptureRegion()
	_GDIPlus_ImageSaveToFile($g_hBitmap, $subDirectory & $fileNameUntouched)
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_GraphicsDispose($hGraphic)
	SetLog(" » Debug Image saved!")
EndFunc   ;==>DebugImageSmartMilk

Func _getBattleEnds()
	Local $sReturn = getOcrAndCaptureDOCR($g_sASBattleEndsDOCRPath, 380, 26, 106, 39, True, True)
	$sReturn = StringReplace($sReturn, " ", "")
	If $g_bDebugOcr Then
		Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
		Local $sLibpath = @ScriptDir & "\lib\debug\ocr"
		DirCreate($sLibpath)
		Local $asTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC
		Local $sFilename = "ocr_" & $asTime & " _latinExtra"
		_GDIPlus_ImageSaveToFile($hEditedImage, $sLibpath & "\" & $sFilename & ".png")
		FileWrite($sLibpath & "\" & $sFilename & ".txt", $sReturn)
		_GDIPlus_BitmapDispose($hEditedImage)
	EndIf
	Return $sReturn
EndFunc   ;==>_getBattleEnds

Func ConvertTime($sString)
	Local $asTime = StringSplit($sString, "m", $STR_NOCOUNT)
	If Not @error Then
		Local $iMinutes = Int($asTime[0])
		Local $iSeconds = Int(StringReplace($asTime[1], "s", ""))
		Return ($iMinutes * 60) + $iSeconds
	Else
		Local $iSeconds = Int(StringReplace($sString, "s", ""))
		Return $iSeconds
	EndIf
EndFunc   ;==>ConvertTime
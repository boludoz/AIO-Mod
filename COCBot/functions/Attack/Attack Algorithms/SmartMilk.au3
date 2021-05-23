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

Func _getBattleEnds()
	Local $sReturn = getOcrAndCaptureDOCR($g_sASBattleEndsDOCRPath, 380, 26, 106, 39, True, True)
	$sReturn = StringReplace($sReturn, " ", "")
	If $g_bDebugOcr Then
		Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
		Local $libpath = @ScriptDir & "\lib\debug\ocr"
		DirCreate($libpath)
		Local $Time = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC
		Local $Filename = "ocr_" & $Time & " _latinExtra"
		_GDIPlus_ImageSaveToFile($hEditedImage, $libpath & "\" & $Filename & ".png")
		FileWrite($libpath & "\" & $Filename & ".txt", $sReturn)
		_GDIPlus_BitmapDispose($hEditedImage)
	EndIf
	Return $sReturn
EndFunc   ;==>_getBattleEnds

Func ConvertTime($string)
	Local $Time = StringSplit($string, "m", $STR_NOCOUNT)
	If Not @error Then
		Local $minutes = Int($Time[0])
		Local $seconds = Int(StringReplace($Time[1], "s", ""))
		Return ($minutes * 60) + $seconds
	Else
		Local $seconds = Int(StringReplace($string, "s", ""))
		Return $seconds
	EndIf
EndFunc   ;==>ConvertTime

Global $g_iRemainTimeToZap
Func SmartFarmMilkTest()
	Local $RuntimeA = $g_bRunState
	$g_bRunState = True
	TestSmartFarm()
	$g_bRunState = $RuntimeA
EndFunc   ;==>SmartFarmMilkTest

Func SmartFarmMilk()
	If $g_iMatchMode <> $DB And $g_aiAttackAlgorithm[$DB] <> 3 Then Return
	$g_bIsCCDropped = False
	$g_aiDeployCCPosition[0] = -1
	$g_aiDeployCCPosition[1] = -1
	$g_bIsHeroesDropped = False
	$g_aiDeployHeroesPosition[0] = -1
	$g_aiDeployHeroesPosition[1] = -1
	; Local $bFullBabyDragon = True, $bFullGoblins = True
	; For $i = 0 To UBound($g_aTrainedTroops) - 1
		; If $g_aTrainedTroops[$i][0] <> "BabyD" And $g_aTrainedTroops[$i][3] > 0 Then $bFullBabyDragon = False
	; Next
	; If $g_bDebugSmartMilk Then SetLog("$bFullBabyDragon: " & $bFullBabyDragon)
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
	Local $iGiantSlot = -1, $iBarbSlot = -1, $iArchSlot = -1, $iGoblSlot = -1, $iBabyDSlot = -1, $iMini = -1
	Local $aSlots[6] = [$iGiantSlot, $iBarbSlot, $iArchSlot, $iGoblSlot, $iBabyDSlot, $iMini]
	Local $aSlots2deploy[6][4]
	Local $UsedZap = False
	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] = $eBabyD Then
			$iBabyDSlot = $i
			$aSlots2deploy[$eBabyDSlot][0] = $i
			$aSlots2deploy[$eBabyDSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eBabyDSlot][2] = 1
			$aSlots2deploy[$eBabyDSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
		If $g_avAttackTroops[$i][0] = $eBarb Then
			$iBarbSlot = $i
			$aSlots2deploy[$eBarbSlot][0] = $i
			$aSlots2deploy[$eBarbSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eBarbSlot][2] = Random(3, 6, 1)
			$aSlots2deploy[$eBarbSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
		If $g_avAttackTroops[$i][0] = $eArch Then
			$iArchSlot = $i
			$aSlots2deploy[$eArchSlot][0] = $i
			$aSlots2deploy[$eArchSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eArchSlot][2] = Random(3, 6, 1)
			$aSlots2deploy[$eArchSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
		If $g_avAttackTroops[$i][0] = $eGiant Then
			$iGiantSlot = $i
			$aSlots2deploy[$eGiantSlot][0] = $i
			$aSlots2deploy[$eGiantSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eGiantSlot][2] = Random(1, 2, 1)
			$aSlots2deploy[$eGiantSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
		If $g_avAttackTroops[$i][0] = $eGobl Then
			$iGoblSlot = $i
			$aSlots2deploy[$eGoblSlot][0] = $i
			$aSlots2deploy[$eGoblSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eGoblSlot][2] = Random(5, 6, 1)
			$aSlots2deploy[$eGoblSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
		If $g_avAttackTroops[$i][0] = $eMini Then
			$iMini = $i
			$aSlots2deploy[$eMiniSlot][0] = $i
			$aSlots2deploy[$eMiniSlot][1] = $g_avAttackTroops[$i][1]
			$aSlots2deploy[$eMiniSlot][2] = Random(4, 6, 1)
			$aSlots2deploy[$eMiniSlot][3] = $g_avAttackTroops[$i][0]
		EndIf
	Next
	Switch $g_iMilkStrategyArmy
		Case 0
			If $aSlots[$eBabyDSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iBabyDSlot)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iBabyDSlot)
			EndIf
		Case 1
			If $aSlots[$eBarbSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iBarbSlot)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iBarbSlot)
			EndIf
		Case 2
			If $aSlots[$eArchSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iArchSlot)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iArchSlot)
			EndIf
		Case 3
			If $aSlots[$eGiantSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iGiantSlot)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iGiantSlot)
			EndIf
		Case 4
			If $aSlots[$eGoblSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iGoblSlot)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iGoblSlot)
			EndIf
		Case 5
			If $aSlots[$eMiniSlot] <> -1 Then
				If IsAttackPage() Then SelectDropTroop($iMini)
				If _Sleep($DELAYLAUNCHTROOP23) Then Return
				If IsAttackPage() Then SelectDropTroop($iMini)
			EndIf
		Case Else
			If IsAttackPage() Then SelectDropTroop(0)
			If _Sleep($DELAYLAUNCHTROOP23) Then Return
			If IsAttackPage() Then SelectDropTroop(0)
	EndSwitch
	If $g_bDebugSmartMilk Then SetLog("$aSlots2deploy: " & _ArrayToString($aSlots2deploy, "-", -1, -1, "|"))
	If $g_bDebugSmartMilk Then SetLog("$g_iMilkStrategyArmy: " & $g_iMilkStrategyArmy)
	Local $allPossibleDeployPoints[0][2], $HeroesDeployJustInCase[2], $sSide = ""
	For $loops = 0 To 2
		$hTimer = TimerInit()
		Local $aCollectorsTL[0][6], $aCollectorsTR[0][6], $aCollectorsBL[0][6], $aCollectorsBR[0][6]
		If $g_bDebugSmartMilk Then SetLog("Attack loop: " & $loops)
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
						If $loops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiTopLeftDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiTopLeftDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "TR"
						ReDim $aCollectorsTR[UBound($aCollectorsTR) + 1][6]
						For $t = 0 To 5
							$aCollectorsTR[UBound($aCollectorsTR) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $loops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiTopRightDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiTopRightDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "BL"
						ReDim $aCollectorsBL[UBound($aCollectorsBL) + 1][6]
						For $t = 0 To 5
							$aCollectorsBL[UBound($aCollectorsBL) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $loops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiBottomLeftDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiBottomLeftDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
					Case "BR"
						ReDim $aCollectorsBR[UBound($aCollectorsBR) + 1][6]
						For $t = 0 To 5
							$aCollectorsBR[UBound($aCollectorsBR) - 1][$t] = $aCollectorsAll[$collector][$t]
						Next
						If $loops = 0 Then
							$HeroesDeployJustInCase[0] = $g_aaiBottomRightDropPoints[3][0]
							$HeroesDeployJustInCase[1] = $g_aaiBottomRightDropPoints[3][1]
							$sSide = $aCollectorsAll[$collector][4]
						EndIf
				EndSwitch
			Next
			If $g_bDebugSmartMilk And $loops = 0 Then
				SetLog("$aCollectorsAll: " & _ArrayToString($aCollectorsAll, "-", -1, -1, "|"))
				DebugImageSmartMilk($aCollectorsAll, Round(TimerDiff($hTimer) / 1000, 2) & "'s", $HeroesDeployJustInCase)
			EndIf
			Local $random = Random(0, 3, 1)
			Switch $random
				Case 0
					Local $aAllBySide[4] = [$aCollectorsBL, $aCollectorsBR, $aCollectorsTR, $aCollectorsTL]
				Case 1
					Local $aAllBySide[4] = [$aCollectorsBR, $aCollectorsTR, $aCollectorsTL, $aCollectorsBL]
				Case 2
					Local $aAllBySide[4] = [$aCollectorsTR, $aCollectorsTL, $aCollectorsBL, $aCollectorsBR]
				Case 3
					Local $aAllBySide[4] = [$aCollectorsTL, $aCollectorsBL, $aCollectorsBR, $aCollectorsTR]
			EndSwitch
			Local $iTroopsDistance = 70
			If $iBabyDSlot = -1 Then $iTroopsDistance = 30
			Local $aLastPosition[2]
			For $H7644 = 0 To 3
				If $g_bDebugSmartMilk Then SetLog("Attack Side :" & $H7644)
				Local $aSideCollectors = $aAllBySide[$H7644]
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
						Local $nearPoints[0][2]
						If StringInStr($aNear, "|") Then
							Local $tempObbj = StringSplit($aNear, "|", $STR_NOCOUNT)
							For $t = 0 To UBound($tempObbj) - 1
								ReDim $nearPoints[UBound($nearPoints) + 1][2]
								Local $nearPoint = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
								$nearPoints[UBound($nearPoints) - 1][0] = $nearPoint[0]
								$nearPoints[UBound($nearPoints) - 1][1] = $nearPoint[1]
							Next
						Else
							Local $tempObbj = StringSplit($aNear, ",", $STR_NOCOUNT)
							ReDim $nearPoints[UBound($nearPoints) + 1][2]
							$nearPoints[UBound($nearPoints) - 1][0] = $tempObbj[0]
							$nearPoints[UBound($nearPoints) - 1][1] = $tempObbj[1]
						EndIf
						If UBound($nearPoints) > 2 Then
							Local $deployPoint = [$nearPoints[2][0], $nearPoints[2][1]]
						Else
							Local $deployPoint = [$nearPoints[0][0], $nearPoints[0][1]]
						EndIf
						If $loops = 0 Then
							ReDim $allPossibleDeployPoints[UBound($allPossibleDeployPoints) + 1][2]
							$allPossibleDeployPoints[UBound($allPossibleDeployPoints) - 1][0] = $deployPoint[0]
							$allPossibleDeployPoints[UBound($allPossibleDeployPoints) - 1][0] = $deployPoint[1]
						EndIf
						For $P25686 = 0 To UBound($aSlots2deploy) - 1
							If $aSlots2deploy[$P25686][1] > 0 Then
								If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$P25686][0])
								If _Sleep($DELAYLAUNCHTROOP23) Then Return
								If _Sleep($DELAYLAUNCHTROOP23) Then Return
								If $g_bDebugSmartMilk Then SetLog("AttackClick: " & $deployPoint[0] & "," & $deployPoint[1])
								AttackClick($deployPoint[0], $deployPoint[1], $aSlots2deploy[$P25686][2], 100, 0, "#0098")
								$aSlots2deploy[$P25686][1] -= $aSlots2deploy[$P25686][2]
								SetLog("Deployed " & GetTroopName($aSlots2deploy[$P25686][3], Number($aSlots2deploy[$P25686][2])) & " " & $aSlots2deploy[$P25686][2] & "x")
								If $g_bDebugSmartMilk Then SetLog("Remains - " & GetTroopName($aSlots2deploy[$P25686][3]) & " " & $aSlots2deploy[$P25686][1] & "x")
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
			If $loops = 0 Then
				SetLog("Reached " & $g_iPercentageDamage & "% lets Check if exist any resource!", $COLOR_SUCCESS)
				ContinueLoop
			Else
				SetLog("Reached " & $g_iPercentageDamage & "% lets Exit!", $COLOR_SUCCESS)
				ExitLoop
			EndIf
		EndIf
		If ($g_iPercentageDamage > 30 And $loops <> 0) Or ($g_bChkMilkForceDeployHeroes And $loops <> 0) Then
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
		If $loops = 2 And $g_bChkMilkForceAllTroops Then
			SetLog("Let's deploy all remain troops!", $COLOR_INFO)
			SetDebugLog("How many last deploy points: " & UBound($allPossibleDeployPoints))
			For $point = 0 To UBound($allPossibleDeployPoints) - 1
				CheckHeroesHealth()
				For $P25686 = 0 To UBound($aSlots2deploy) - 1
					If $aSlots2deploy[$P25686][1] > 0 Then
						If IsAttackPage() Then SelectDropTroop($aSlots2deploy[$P25686][0])
						If _Sleep($DELAYLAUNCHTROOP23) Then Return
						If _Sleep($DELAYLAUNCHTROOP23) Then Return
						If $g_bDebugSmartMilk Then SetLog("AttackClick: " & $allPossibleDeployPoints[$point][0] & "," & $allPossibleDeployPoints[$point][1])
						AttackClick($allPossibleDeployPoints[$point][0], $allPossibleDeployPoints[$point][1], $aSlots2deploy[$P25686][2], 100, 0, "#0098")
						$aSlots2deploy[$P25686][1] -= $aSlots2deploy[$P25686][2]
						SetLog("Deployed " & GetTroopName($aSlots2deploy[$P25686][3], Number($aSlots2deploy[$P25686][2])) & " " & $aSlots2deploy[$P25686][2] & "x")
						If $g_bDebugSmartMilk Then SetLog("Remains - " & GetTroopName($aSlots2deploy[$P25686][3]) & " " & $aSlots2deploy[$P25686][1] & "x")
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
Func DebugImageSmartMilk($aCollectorsAll, $sTime, $HeroesDeployJustInCase)
	_CaptureRegion()
	Local $EditedImage = $g_hBitmap
	Local $subDirectory = $g_sProfileTempDebugPath & "\SmartFarm\"
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

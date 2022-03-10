
; #FUNCTION# ====================================================================================================================
; Name ..........: LaunchTroop
; Description ...:
; Syntax ........: LaunchTroop($vTroopIndex, $iNumberSides, $iNumberWaves, $iMaxNumberWaves[, $iSlotsPerEdge = 0])
; Parameters ....: $vTroopIndex           - a dll struct value.
;                  $iNumberSides             - a general number value.
;                  $iNumberWaves              - an unknown value.
;                  $iMaxNumberWaves           - a map.
;                  $iSlotsPerEdge        - [optional] a string value. Default is 0.
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Smart Milk - Team AIO Mod++
Func LaunchTroop($vTroopIndex, $iNumberSides, $iNumberWaves, $iMaxNumberWaves, $iSlotsPerEdge = 0)
	Local $troop = -1
	Local $iTroopAmount = 0
	Local $name = ""
	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] = $vTroopIndex Then
			If $g_avAttackTroops[$i][1] < 1 Then Return False
			$troop = $i
			$iTroopAmount = Ceiling($g_avAttackTroops[$i][1] / $iMaxNumberWaves)
			Local $plural = 0
			If $iTroopAmount > 1 Then $plural = 1
			$name = GetTroopName($vTroopIndex, $plural)
			ExitLoop
		EndIf
	Next
	
	SetDebugLog("Dropping : " & $iTroopAmount & " " & $name, $COLOR_DEBUG)
	
	If $troop = -1 Or $iTroopAmount = 0 Then
		Return False
	EndIf
	
	Local $wavename = "first"
	If $iNumberWaves = 2 Then $wavename = "second"
	If $iNumberWaves = 3 Then $wavename = "third"
	If $iMaxNumberWaves = 1 Then $wavename = "only"
	If $iNumberWaves = 0 Then $wavename = "last"
	SetLog("Dropping " & $wavename & " wave of " & $iTroopAmount & " " & $sTroopName, $color_success)
	DropTroop($troop, $iNumberSides, $iTroopAmount, $iSlotsPerEdge)
	Return True
EndFunc   ;==>LaunchTroop

Func LaunchTroop2($listInfoDeploy, $iCC, $iKing, $iQueen, $iWarden, $ichampion)
	SetDebugLog("LaunchTroop2 with CC " & $iCC & ", K " & $iKing & ", Q " & $iQueen & ", W " & $iWarden & ", C " & $ichampion, $COLOR_DEBUG)
	Local $listlistInfoDeploytrooppixel[0]
	Local $pixelRandomDrop[2]
	Local $pixelRandomDropCC[2]
	
	If ($g_abAttackStdSmartAttack[$g_iMatchMode]) Then
		For $i = 0 To UBound($listInfoDeploy) - 1	
			Local $iFoundTroopAt = -1, $iTroopAmount = 0, $sTroopName
			Local $vTroopIndex = $listInfoDeploy[$i][0]
			Local $iNumberSides = $listInfoDeploy[$i][1]
			Local $iNumberWaves = $listInfoDeploy[$i][2]
			Local $iMaxNumberWaves = $listInfoDeploy[$i][3]
			Local $iSlotsPerEdge = $listInfoDeploy[$i][4]
			SetDebugLog("**listInfoDeploy row " & $i & ": USE " & $vTroopIndex & " SIDES " & $iNumberSides & " WAVE " & $iNumberWaves & " XWAVE " & $iMaxNumberWaves & " SLOTXEDGE " & $iSlotsPerEdge, $COLOR_DEBUG)
			If (IsNumber($vTroopIndex)) Then
				For $j = 0 To UBound($g_avattacktroops) - 1
					If $g_avattacktroops[$j][0] = $vTroopIndex Then
						$iFoundTroopAt = $j
						$iTroopAmount = Ceiling($g_avattacktroops[$j][1] / $iMaxNumberWaves)
						Local $plural = 0
						If $iTroopAmount > 1 Then $plural = 1
						$sTroopName = GetTroopName($vTroopIndex, $plural)
					EndIf
				Next
			EndIf
			If ($iFoundTroopAt <> -1 And $iTroopAmount > 0) Or IsString($vTroopIndex) Then
				Local $listInfoDeploytrooppixel
				If (UBound($listlistInfoDeploytrooppixel) < $iNumberWaves) Then
					ReDim $listlistInfoDeploytrooppixel[$iNumberWaves]
					Local $newlistInfoDeploytrooppixel[0]
					$listlistInfoDeploytrooppixel[$iNumberWaves - 1] = $newlistInfoDeploytrooppixel
				EndIf
				$listInfoDeploytrooppixel = $listlistInfoDeploytrooppixel[$iNumberWaves - 1]
				ReDim $listInfoDeploytrooppixel[UBound($listInfoDeploytrooppixel) + 1]
				If (IsString($vTroopIndex)) Then
					Local $arrccorheroes[1] = [$vTroopIndex]
					$listInfoDeploytrooppixel[UBound($listInfoDeploytrooppixel) - 1] = $arrccorheroes
				Else
					Local $infodroptroop = droptroop2($iFoundTroopAt, $iNumberSides, $iTroopAmount, $iSlotsPerEdge, $sTroopName)
					$listInfoDeploytrooppixel[UBound($listInfoDeploytrooppixel) - 1] = $infodroptroop
				EndIf
				$listlistInfoDeploytrooppixel[$iNumberWaves - 1] = $listInfoDeploytrooppixel
			EndIf
		Next
		
		If (($g_abattackstdsmartnearcollectors[$g_iMatchMode][0] Or $g_abattackstdsmartnearcollectors[$g_iMatchMode][1] Or $g_abattackstdsmartnearcollectors[$g_iMatchMode][2]) And UBound($g_aipixelnearcollector) = 0) Then
			SetLog("Error, no pixel found near collector => Normal attack near red line")
		EndIf
		
		If ($g_aiAttackStdSmartDeploy[$g_iMatchMode] = 0) Then
			For $numwave = 0 To UBound($listlistInfoDeploytrooppixel) - 1
				Local $listInfoDeploytrooppixel = $listlistInfoDeploytrooppixel[$numwave]
				For $i = 0 To UBound($listInfoDeploytrooppixel) - 1
					Local $infopixeldroptroop = $listInfoDeploytrooppixel[$i]
					If (IsString($infopixeldroptroop[0]) And ($infopixeldroptroop[0] = "CC" Or $infopixeldroptroop[0] = "HEROES")) Then
						Local $sPos = $i = 0 ? "First position" : $i
						If $i = UBound($listInfoDeploytrooppixel) - 1 Then $sPos = "Last position"
						Local $currentpixel[2] = [-1, -1]
						For $p8911 = 0 To UBound($listInfoDeploytrooppixel) - 1
							SetDebugLog("Heroes & CC at First : " & _ArrayToString($g_srAndomsidesnames))
							SetDebugLog("UBound : " & UBound($listInfoDeploytrooppixel) & " $index:" & $p8911)
							Local $tempinfotrooplistarrpixel = $listInfoDeploytrooppixel[$p8911]
							If Not IsString($tempinfotrooplistarrpixel[0]) Then
								Local $tempinfolistarrpixel = $tempinfotrooplistarrpixel[1]
								Local $listpixel = $tempinfolistarrpixel[0]
								Local $pixeldroptroop[1] = [$listpixel]
								Local $arrpixel = $pixeldroptroop[0]
								Local $iindex = Ceiling(UBound($arrpixel) / 2) <= UBound($arrpixel) - 1 ? Ceiling(UBound($arrpixel) / 2) : 0
								Local $currentpixel = $arrpixel[$iindex]
								Local $sBestSide = Side($currentpixel)
								SetDebugLog($iindex & " - Deploy Point check " & _ArrayToString($currentpixel) & " side: " & $sBestSide)
								SetDebugLog(UBound($arrpixel) & " deploy point(s) at " & $sBestSide, $COLOR_DEBUG)
								If $currentpixel[0] <> -1 Then ExitLoop
							EndIf
						Next
						$pixelRandomDrop[0] = $currentpixel[0] <> -1 ? $currentpixel[0] : $g_aideployheroesposition[0]
						$pixelRandomDrop[1] = $currentpixel[1] <> -1 ? $currentpixel[1] : $g_aideployheroesposition[1]
						If $pixelRandomDrop = -1 Then
							$pixelRandomDrop[0] = $g_aaiBottomLeftDropPoints[2][0]
							$pixelRandomDrop[1] = $g_aaiBottomLeftDropPoints[2][1]
						EndIf
						$pixelRandomDropCC[0] = $currentpixel[0] <> -1 ? $currentpixel[0] : $g_aideployccposition[0]
						$pixelRandomDropCC[1] = $currentpixel[1] <> -1 ? $currentpixel[1] : $g_aideployccposition[1]
						If $pixelRandomDropCC = -1 Then
							$pixelRandomDropCC[0] = $g_aaiBottomLeftDropPoints[2][0]
							$pixelRandomDropCC[1] = $g_aaiBottomLeftDropPoints[2][1]
						EndIf
						If ($infopixeldroptroop[0] = "CC") Then
							DropCC($pixelRandomDropCC[0], $pixelRandomDropCC[1], $iCC)
							$g_bisccdropped = True
						ElseIf ($infopixeldroptroop[0] = "HEROES") Then
							dropheroes($pixelRandomDrop[0], $pixelRandomDrop[1], $iKing, $iQueen, $iWarden, $ichampion)
							$g_bisheroesdropped = True
						EndIf
						If ($g_bisheroesdropped) Then
							If _Sleep($delaylaunchtroop22) Then Return
							checkheroeshealth()
						EndIf
					Else
						If _Sleep($delaylaunchtroop21) Then Return
						selectdroptroop($infopixeldroptroop[0])
						If _Sleep($delaylaunchtroop21) Then Return
						Local $wavename = "first"
						If $numwave + 1 = 2 Then $wavename = "second"
						If $numwave + 1 = 3 Then $wavename = "third"
						If $numwave + 1 = 0 Then $wavename = "last"
						SetLog("Dropping " & $wavename & " wave of " & $infopixeldroptroop[5] & " " & $infopixeldroptroop[4], $color_success)
						droponpixel($infopixeldroptroop[0], $infopixeldroptroop[1], $infopixeldroptroop[2], $infopixeldroptroop[3])
					EndIf
					If ($g_bisheroesdropped) Then
						If _Sleep($delaylaunchtroop22) Then Return
						checkheroeshealth()
					EndIf
					If _Sleep(SetSleep(1)) Then Return
				Next
			Next
		Else
			For $numwave = 0 To UBound($listlistInfoDeploytrooppixel) - 1
				Local $listInfoDeploytrooppixel = $listlistInfoDeploytrooppixel[$numwave]
				If (UBound($listInfoDeploytrooppixel) > 0) Then
					Local $infotrooplistarrpixel = $listInfoDeploytrooppixel[0]
					Local $numberSidesDropTroop = 1
					For $i = 0 To UBound($listInfoDeploytrooppixel) - 1
						$infotrooplistarrpixel = $listInfoDeploytrooppixel[$i]
						If (UBound($infotrooplistarrpixel) > 1) Then
							Local $infolistarrpixel = $infotrooplistarrpixel[1]
							$numberSidesDropTroop = UBound($infolistarrpixel)
							ExitLoop
						EndIf
					Next
					If ($numberSidesDropTroop > 0) Then
						For $i = 0 To $numberSidesDropTroop - 1
							For $j = 0 To UBound($listInfoDeploytrooppixel) - 1
								$infotrooplistarrpixel = $listInfoDeploytrooppixel[$j]
								If (IsString($infotrooplistarrpixel[0]) And ($infotrooplistarrpixel[0] = "CC" Or $infotrooplistarrpixel[0] = "HEROES")) Then
									Local $sPos = $j = 0 ? "First position" : $j
									If $j = UBound($listInfoDeploytrooppixel) - 1 Then $sPos = "Last position"
									SetDebugLog("Wave " & $numwave & " Side " & $i + 1 & "/" & $numberSidesDropTroop & " Dropping a CC & Heroes at " & $sPos)
									Local $currentpixel[2] = [-1, -1]
									For $p8911 = 0 To UBound($listInfoDeploytrooppixel) - 1
										SetDebugLog("Heroes & CC at First : " & _ArrayToString($g_srAndomsidesnames))
										SetDebugLog("UBound : " & UBound($listInfoDeploytrooppixel) & " $index:" & $p8911)
										Local $tempinfotrooplistarrpixel = $listInfoDeploytrooppixel[$p8911]
										If Not IsString($tempinfotrooplistarrpixel[0]) Then
											Local $tempinfolistarrpixel = $tempinfotrooplistarrpixel[1]
											Local $listpixel = $tempinfolistarrpixel[$i]
											Local $pixeldroptroop[1] = [$listpixel]
											Local $arrpixel = $pixeldroptroop[0]
											Local $iindex = Ceiling(UBound($arrpixel) / 2) <= UBound($arrpixel) - 1 ? Ceiling(UBound($arrpixel) / 2) : 0
											Local $currentpixel = $arrpixel[$iindex]
											Local $sBestSide = Side($currentpixel)
											SetLog($iindex & " - Deploy Point check " & _ArrayToString($currentpixel) & " side: " & $sBestSide)
											SetLog(UBound($arrpixel) & " deploy point(s) at " & $sBestSide, $COLOR_DEBUG)
											If $currentpixel[0] <> -1 Then ExitLoop
										EndIf
									Next
									$pixelRandomDrop[0] = $currentpixel[0] <> -1 ? $currentpixel[0] : $g_aideployheroesposition[0]
									$pixelRandomDrop[1] = $currentpixel[1] <> -1 ? $currentpixel[1] : $g_aideployheroesposition[1]
									If $pixelRandomDrop = -1 Then
										$pixelRandomDrop[0] = $g_aaiBottomLeftDropPoints[2][0]
										$pixelRandomDrop[1] = $g_aaiBottomLeftDropPoints[2][1]
									EndIf
									$pixelRandomDropCC[0] = $currentpixel[0] <> -1 ? $currentpixel[0] : $g_aideployccposition[0]
									$pixelRandomDropCC[1] = $currentpixel[1] <> -1 ? $currentpixel[1] : $g_aideployccposition[1]
									If $pixelRandomDropCC = -1 Then
										$pixelRandomDropCC[0] = $g_aaiBottomLeftDropPoints[2][0]
										$pixelRandomDropCC[1] = $g_aaiBottomLeftDropPoints[2][1]
									EndIf
									If ($g_bisccdropped = False And $infotrooplistarrpixel[0] = "CC") Then
										DropCC($pixelRandomDropCC[0], $pixelRandomDropCC[1], $iCC)
										$g_bisccdropped = True
									ElseIf ($g_bisheroesdropped = False And $infotrooplistarrpixel[0] = "HEROES" And $i = $numberSidesDropTroop - 1) Then
										dropheroes($pixelRandomDrop[0], $pixelRandomDrop[1], $iKing, $iQueen, $iWarden, $ichampion)
										$g_bisheroesdropped = True
									EndIf
									If ($g_bisheroesdropped) Then
										If _Sleep($delaylaunchtroop22) Then Return
										checkheroeshealth()
									EndIf
								Else
									$infolistarrpixel = $infotrooplistarrpixel[1]
									Local $listpixel = $infolistarrpixel[$i]
									If _Sleep($delaylaunchtroop21) Then Return
									selectdroptroop($infotrooplistarrpixel[0])
									If _Sleep($delaylaunchtroop23) Then Return
									SetLog("Dropping " & $infotrooplistarrpixel[2] & " of " & $infotrooplistarrpixel[5] & " Points Per Side: " & $infotrooplistarrpixel[3] & " (side " & $i + 1 & ")", $color_success)
									Local $pixeldroptroop[1] = [$listpixel]
									droponpixel($infotrooplistarrpixel[0], $pixeldroptroop, $infotrooplistarrpixel[2], $infotrooplistarrpixel[3])
								EndIf
								If ($g_bisheroesdropped) Then
									If _Sleep(1000) Then Return
									checkheroeshealth()
								EndIf
							Next
						Next
					EndIf
				EndIf
				If _Sleep(SetSleep(1)) Then Return
			Next
		EndIf
		For $numwave = 0 To UBound($listlistInfoDeploytrooppixel) - 1
			Local $listInfoDeploytrooppixel = $listlistInfoDeploytrooppixel[$numwave]
			For $i = 0 To UBound($listInfoDeploytrooppixel) - 1
				Local $infopixeldroptroop = $listInfoDeploytrooppixel[$i]
				If Not (IsString($infopixeldroptroop[0]) And ($infopixeldroptroop[0] = "CC" Or $infopixeldroptroop[0] = "HEROES")) Then
					Local $numberleft = readtroopquantity($infopixeldroptroop[0])
					If ($numberleft > 0) Then
						If _Sleep($delaylaunchtroop21) Then Return
						selectdroptroop($infopixeldroptroop[0])
						If _Sleep($delaylaunchtroop23) Then Return
						SetLog("Dropping last " & $numberleft & " of " & $infopixeldroptroop[5], $color_success)
						droponpixel($infopixeldroptroop[0], $infopixeldroptroop[1], Ceiling($numberleft / UBound($infopixeldroptroop[1])), $infopixeldroptroop[3])
						If ($g_bisheroesdropped) Then
							If _Sleep($delaylaunchtroop22) Then Return
							checkheroeshealth()
						EndIf
					EndIf
				EndIf
				If _Sleep(SetSleep(0)) Then Return
			Next
			If _Sleep(SetSleep(1)) Then Return
		Next
	Else
		For $i = 0 To UBound($listInfoDeploy) - 1
			If (IsString($listInfoDeploy[$i][0]) And ($listInfoDeploy[$i][0] = "CC" Or $listInfoDeploy[$i][0] = "HEROES")) Then
				If $g_iMatchMode = $LB And $g_aiAttackStdDropSides[$LB] >= 4 Then ; Used for DE or TH side attack
					Local $RandomEdge = $g_aaiEdgeDropPoints[$g_iBuildingEdge]
					Local $RandomXY = 2
				Else
					Local $RandomEdge = $g_aaiEdgeDropPoints[Round(Random(0, 3))]
					Local $RandomXY = Round(Random(1, 3))
				EndIf
				If ($listInfoDeploy[$i][0] = "CC") Then
					dropCC($RandomEdge[$RandomXY][0], $RandomEdge[$RandomXY][1], $iCC)
				ElseIf ($listInfoDeploy[$i][0] = "HEROES") Then
					dropHeroes($RandomEdge[$RandomXY][0], $RandomEdge[$RandomXY][1], $iKing, $iQueen, $iWarden, $iChampion)
				EndIf
			Else
				If LaunchTroop($listInfoDeploy[$i][0], $listInfoDeploy[$i][1], $listInfoDeploy[$i][2], $listInfoDeploy[$i][3], $listInfoDeploy[$i][4]) Then
					If _Sleep(SetSleep(1)) Then Return
				EndIf
			EndIf

		Next
	EndIf
	Return True
EndFunc   ;==>launchtroop2
#EndRegion - Smart Milk - Team AIO Mod++

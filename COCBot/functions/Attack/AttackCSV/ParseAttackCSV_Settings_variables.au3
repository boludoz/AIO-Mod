; #FUNCTION# ====================================================================================================================
; Name ..........: ParseAttackCSV_Settings_variables
; Description ...: Parse CSV settings and update byref var
; Syntax ........: ParseAttackCSV_Settings_variables(ByRef $aiCSVTroops, ByRef $aiCSVSpells, ByRef $aiCSVHeros, ByRef $iCSVRedlineRoutineItem, ByRef $iCSVDroplineEdgeItem, ByRef $sCSVCCReq, $sFilename)
; Parameters ....:
; Return values .: Success: 1
;				   Failure: 0
; Author ........: MMHK (01-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ParseAttackCSV_Settings_variables(ByRef $aiCSVTroops, ByRef $aiCSVSpells, ByRef $aiCSVSieges, ByRef $aiCSVHeros, ByRef $iCSVRedlineRoutineItem, ByRef $iCSVDroplineEdgeItem, ByRef $sCSVCCReq, $sFilename)
	If $g_bDebugAttackCSV Then SetLog("ParseAttackCSV_Settings_variables()", $COLOR_DEBUG)

	Local $asCommand
	If FileExists($g_sCSVAttacksPath & "\" & $sFilename & ".csv") Then
		Local $asLine = FileReadToArray($g_sCSVAttacksPath & "\" & $sFilename & ".csv")
		If @error Then
			SetLog("Attack CSV script not found: " & $g_sCSVAttacksPath & "\" & $sFilename & ".csv", $COLOR_ERROR)
			Return
		EndIf

		Local $sLine
		Local $iTHCol = 0, $iTH = 0
		Local $iTroopIndex, $iFlexTroopIndex = 999
		Local $iCommandCol = 1, $iTroopNameCol = 2, $iFlexCol = 3, $iTHBeginCol = 4
		Local $iHeroRadioItemTotal = 3, $iHeroTimedLimit = 99

		For $iLine = 0 To UBound($asLine) - 1
			$sLine = $asLine[$iLine]
			$asCommand = StringSplit($sLine, "|")
			If $asCommand[0] >= 8 Then
				$asCommand[$iCommandCol] = StringStripWS(StringUpper($asCommand[$iCommandCol]), $STR_STRIPTRAILING)
				If Not StringRegExp($asCommand[$iCommandCol], "(REDLN)|(DRPLN)|(CCREQ)|(BOOST)", $STR_REGEXPMATCH) Then ContinueLoop

				If $iTHCol = 0 Then ; select a command column TH based on camp space or skip all commands
					If $g_bDebugAttackCSV Then
						SetLog("Camp Total Space: " & $g_iTotalCampSpace, $COLOR_DEBUG)
						SetLog("Spell Total Space: " & $g_iTotalSpellValue, $COLOR_DEBUG)
					EndIf
					If $g_iTotalCampSpace = 0 Then
						SetLog("Has to run bot once first to get correct total camp space", $COLOR_ERROR)
						Return
					EndIf
					If $g_iTotalSpellValue = 0 Then
						SetLog("Has to set spell capacity first", $COLOR_ERROR)
						Return
					EndIf
					Switch $g_iTotalCampSpace
						#Region - Custom fix - Team AIO Mod++
						Case $g_iMaxCapTroopTH[13] + 5 To $g_iMaxCapTroopTH[14]	; TH14
							If $g_iTownHallLevel = 13 Then ContinueCase
							$iTHCol = $iTHBeginCol + 8
							$iTH = 14
						#EndRegion - Custom fix - Team AIO Mod++
						Case $g_iMaxCapTroopTH[12] + 5 To $g_iMaxCapTroopTH[13]	; TH13
							$iTHCol = $iTHBeginCol + 7
							$iTH = 13
						Case $g_iMaxCapTroopTH[11] + 5 To $g_iMaxCapTroopTH[12]	; TH12
							$iTHCol = $iTHBeginCol + 6
							$iTH = 12
						Case $g_iMaxCapTroopTH[10] + 5 To $g_iMaxCapTroopTH[11]	; TH11
							$iTHCol = $iTHBeginCol + 5
							$iTH = 11
						Case $g_iMaxCapTroopTH[9] + 5 To $g_iMaxCapTroopTH[10]	; TH10
							$iTHCol = $iTHBeginCol + 4
							$iTH = 10
						Case $g_iMaxCapTroopTH[8] + 5 To $g_iMaxCapTroopTH[9]	; TH9
							$iTHCol = $iTHBeginCol + 3
							$iTH = 9
						Case $g_iMaxCapTroopTH[6] + 5 To $g_iMaxCapTroopTH[8]	; TH7/8
							Switch $g_iTotalSpellValue
								Case $g_iMaxCapSpellTH[7] + 1 To $g_iMaxCapSpellTH[8]	; TH8
									$iTHCol = $iTHBeginCol + 2
									$iTH = 8
								Case $g_iMaxCapSpellTH[6] + 1 To $g_iMaxCapSpellTH[7]	; TH7
									$iTHCol = $iTHBeginCol + 1
									$iTH = 7
								Case Else
									SetLog("Invalid spell size ( <" & $g_iMaxCapSpellTH[6] + 1 & " or >" & $g_iMaxCapSpellTH[8] & " ): " & $g_iTotalSpellValue & " for CSV", $COLOR_ERROR)
									Return
							EndSwitch
						Case $g_iMaxCapTroopTH[5] + 5 To $g_iMaxCapTroopTH[6]	; TH6
							$iTHCol = $iTHBeginCol
							$iTH = 6
						Case Else
							SetLog("Invalid camp size ( <" & $g_iMaxCapTroopTH[5] + 5 & " or >" & $g_iMaxCapTroopTH[11] & " ): " & $g_iTotalCampSpace & " for CSV", $COLOR_ERROR)
							Return
					EndSwitch
				EndIf

				If $g_bDebugAttackCSV Then SetLog("Line: " & $iLine + 1 & " Command: " & $asCommand[$iCommandCol] & ($iTHCol >= $iTHBeginCol ? " Column: " & $iTHCol & " TH" & $iTH : ""), $COLOR_DEBUG)
				For $i = 2 To (UBound($asCommand) - 1)
					$asCommand[$i] = StringStripWS($asCommand[$i], $STR_STRIPTRAILING)
				Next
				Switch $asCommand[$iCommandCol]
					Case "TRAIN"
						$iTroopIndex = TroopIndexLookup($asCommand[$iTroopNameCol], "ParseAttackCSV_Settings_variables")
						If $iTroopIndex = -1 Then
							SetLog("CSV troop name '" & $asCommand[$iTroopNameCol] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop name
						EndIf
						If int($asCommand[$iTHCol]) <= 0 Then
							If $asCommand[$iTHCol] <> "0" Then SetLog("CSV troop amount/setting '" & $asCommand[$iTHCol] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop amount/setting ex. int(chars)=0, negative #. "0" won't get alerted
						EndIf
						Switch $iTroopIndex
							Case $eKing To $eChampion
								Local $iHeroRadioItem = int(StringLeft($asCommand[$iTHCol], 1))
								Local $iHeroTimed = Int(StringTrimLeft($asCommand[$iTHCol], 1))
								If $iHeroRadioItem <= 0 Or $iHeroRadioItem > $iHeroRadioItemTotal Or $iHeroTimed < 0 Or $iHeroTimed > $iHeroTimedLimit Then
									SetLog("CSV hero ability setting '" & $asCommand[$iTHCol] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
									ContinueLoop ; discard TRAIN commands due to prefix 0 or exceed # of radios
								EndIf
								$aiCSVHeros[$iTroopIndex - $eKing][0] = $iHeroRadioItem
								$aiCSVHeros[$iTroopIndex - $eKing][1] = $iHeroTimed * 1000
						EndSwitch
						If $g_bDebugAttackCSV Then SetLog("Train " & $asCommand[$iTHCol] & "x " & $asCommand[$iTroopNameCol], $COLOR_DEBUG)
					Case "REDLN"
						$iCSVRedlineRoutineItem = int($asCommand[$iTHCol])
						If $g_bDebugAttackCSV Then SetLog("Redline ComboBox #" & ($iCSVRedlineRoutineItem > 0 ? $iCSVRedlineRoutineItem : "None"), $COLOR_DEBUG)
					Case "DRPLN"
						$iCSVDroplineEdgeItem = int($asCommand[$iTHCol])
						If $g_bDebugAttackCSV Then SetLog("Dropline ComboBox #" & ($iCSVDroplineEdgeItem > 0 ? $iCSVDroplineEdgeItem : "None"), $COLOR_DEBUG)
					Case "CCREQ"
						$sCSVCCReq = $asCommand[$iTHCol]
						If $g_bDebugAttackCSV Then SetLog("CC Request: " & $sCSVCCReq, $COLOR_DEBUG)
				EndSwitch
			EndIf
		Next
		Return ParseTroopsCSV($aiCSVTroops, $aiCSVSpells, $aiCSVSieges, $asLine)
	Else
		SetLog("Cannot find attack file " & $g_sCSVAttacksPath & "\" & $sFilename & ".csv", $COLOR_ERROR)
		Return
	EndIf
	Return 1
EndFunc   ;==>ParseAttackCSV_Settings_variables

Func ParseTroopsCSV(ByRef $aiCSVTroops, ByRef $aiCSVSpells, ByRef $aiCSVSieges, $asLine)
	If $g_bDebugAttackCSV Then SetLog("Start of ParseTroopsCSV", $COLOR_DEBUG)

	Local $sLine
	Local $iTHCol = 0, $iTH = 0
	Local $iTroopIndex, $asCommand
	Local $iCommandCol = 1, $iTroopNameCol = 2
	Switch $g_iTotalCampSpace
		#Region - Custom fix - Team AIO Mod++
		Case $g_iMaxCapTroopTH[13] + 5 To $g_iMaxCapTroopTH[14]	; TH14
			If $g_iTownHallLevel = 13 Then ContinueCase
			$iTH = 14
		#EndRegion - Custom fix - Team AIO Mod++
		Case $g_iMaxCapTroopTH[12] + 5 To $g_iMaxCapTroopTH[13]	; TH13
			$iTH = 13
		Case $g_iMaxCapTroopTH[11] + 5 To $g_iMaxCapTroopTH[12]	; TH12
			$iTH = 12
		Case $g_iMaxCapTroopTH[10] + 5 To $g_iMaxCapTroopTH[11]	; TH11
			$iTH = 11
		Case $g_iMaxCapTroopTH[9] + 5 To $g_iMaxCapTroopTH[10]	; TH10
			$iTH = 10
		Case $g_iMaxCapTroopTH[8] + 5 To $g_iMaxCapTroopTH[9]	; TH9
			$iTH = 9
		Case $g_iMaxCapTroopTH[6] + 5 To $g_iMaxCapTroopTH[8]	; TH7/8
			Switch $g_iTotalSpellValue
				Case $g_iMaxCapSpellTH[7] + 1 To $g_iMaxCapSpellTH[8]	; TH8
					$iTH = 8
				Case $g_iMaxCapSpellTH[6] + 1 To $g_iMaxCapSpellTH[7]	; TH7
					$iTH = 7
			EndSwitch
		Case 5 To $g_iMaxCapTroopTH[6]	; TH6
			$iTH = 6
		Case Else
			SetLog("Invalid camp size ( <" & $g_iMaxCapTroopTH[5] + 5 & " or >" & $g_iMaxCapTroopTH[11] & " ): " & $g_iTotalCampSpace & " for CSV", $COLOR_ERROR)
			Return 0
	EndSwitch


	$iTHCol = $iTH - 2

	Local $i = 0
	Local $iCSVTotalCapTroops = 0, $iCSVTotalCapSpells = 0, $iCSVTotalCapSieges = 0

	Do
		If $i <> 0 Then
			$iTH = 5 + $i
			If $iTH > 14 Then ExitLoop
			$iTHCol = $iTH - 2
		EndIf

		For $iLine = 0 To UBound($asLine) - 1
			$sLine = $asLine[$iLine]
			$asCommand = StringSplit($sLine, "|")
			If $asCommand[0] >= 8 Then
				$asCommand[$iCommandCol] = StringStripWS(StringUpper($asCommand[$iCommandCol]), $STR_STRIPTRAILING)
				If Not StringRegExp($asCommand[$iCommandCol], "(TRAIN)", $STR_REGEXPMATCH) Then ContinueLoop

				For $i = 2 To (UBound($asCommand) - 1)
					$asCommand[$i] = StringStripWS($asCommand[$i], $STR_STRIPTRAILING)
				Next

				Switch $asCommand[$iCommandCol]
					Case "TRAIN"
						$iTroopIndex = TroopIndexLookup($asCommand[$iTroopNameCol], "ParseTroopsCSV")
						If $iTroopIndex = -1 Then
							SetLog("CSV troop name '" & $asCommand[$iTroopNameCol] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop name
						EndIf
						If int($asCommand[$iTHCol]) <= 0 Then
							If $asCommand[$iTHCol] <> "0" Then SetLog("CSV troop amount/setting '" & $asCommand[$iTHCol] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop amount/setting ex. int(chars)=0, negative #. "0" won't get alerted
						EndIf
						Switch $iTroopIndex
							Case $eBarb To $eTroopCount - 1
								$aiCSVTroops[$iTroopIndex] = Int($asCommand[$iTHCol])
							Case $eLSpell To $eSpellCount + $eLSpell - 1
								$aiCSVSpells[$iTroopIndex - $eLSpell] = int($asCommand[$iTHCol])
							Case $eWallW To $eSiegeMachineCount + $eWallW - 1
								$aiCSVSieges[$iTroopIndex - $eWallW] = int($asCommand[$iTHCol])
						EndSwitch
						If $g_bDebugAttackCSV Then SetLog("Train " & $asCommand[$iTHCol] & "x " & $asCommand[$iTroopNameCol], $COLOR_DEBUG)
				EndSwitch
			EndIf
		Next

		$iCSVTotalCapTroops = 0
		For $i = 0 To UBound($aiCSVTroops) - 1
			$iCSVTotalCapTroops += $aiCSVTroops[$i] * $g_aiTroopSpace[$i]
		Next
		
		If $iCSVTotalCapTroops > 0 Then
			$iCSVTotalCapSpells = 0
			For $i = 0 To UBound($aiCSVSpells) - 1
				$iCSVTotalCapSpells += $aiCSVSpells[$i] * $g_aiSpellSpace[$i]
			Next
		EndIf
		
		$i += 1
	Until $iCSVTotalCapTroops > 0
	
	; True AI
	Local $iTotalVector = 0, $iTotalIndexes = 0, $aTmp = Null, $aTmp2 = Null, $aComma = Null, $aMiddle = Null
	
	If $iCSVTotalCapTroops = 0 Then
		For $iLine = 0 To UBound($asLine) - 1
			$sLine = $asLine[$iLine]
			$asCommand = StringSplit($sLine, "|")
			If $asCommand[0] >= 8 Then
				$asCommand[$iCommandCol] = StringStripWS(StringUpper($asCommand[$iCommandCol]), $STR_STRIPTRAILING)
				If Not StringRegExp($asCommand[$iCommandCol], "(DROP)", $STR_REGEXPMATCH) Then ContinueLoop
				
				For $i = 2 To (UBound($asCommand) - 1)
					$asCommand[$i] = StringStripWS($asCommand[$i], $STR_STRIPTRAILING)
				Next
				
				Switch $asCommand[$iCommandCol]
					Case "DROP"
						$iTroopIndex = TroopIndexLookup($asCommand[5], "ParseTroopsCSV")
						If $iTroopIndex = -1 Then
							SetLog("CSV troop name '" & $asCommand[5] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop name
						EndIf
						
						If StringInStr($asCommand[4], "%") Then
							$iTotalVector = Null
							$iTotalIndexes = Null
							$aTmp = Null
							$aTmp2 = Null
							$aComma = Null
							$aMiddle = Null

							If StringInStr($asCommand[2], "-") Then
								$iTotalVector = StringSplit($asCommand[2], "-")[0]
							Else
								$iTotalVector = 1
							EndIf
							
							$aComma = StringInStr($asCommand[3], ",") > 0
							$aMiddle = StringInStr($asCommand[3], "-") > 0

							If $aComma And Not $aMiddle Then
								$aTmp = StringSplit($asCommand[3], ",", $STR_NOCOUNT)
								$iTotalIndexes += Int(UBound($aTmp))
							ElseIf $aMiddle Then
								$aTmp2 = StringSplit($asCommand[3], "-", $STR_NOCOUNT)
								$iTotalIndexes += Abs(Number($aTmp2[1]) - Number($aTmp2[0]))
							ElseIf $aComma Then
								$aTmp = StringSplit($asCommand[3], ",", $STR_NOCOUNT)
								For $i = 0 To UBound($aTmp) -1
									If StringInStr($aTmp[$i], "-") Then
										$aTmp2 = StringSplit($aTmp[$i], "-", $STR_NOCOUNT)
										$iTotalIndexes += Abs(Number($aTmp2[1]) - Number($aTmp2[0]))
									Else
										$iTotalIndexes += 1
									EndIf
								Next
							Else
								$iTotalIndexes += 1
							EndIf

							$asCommand[4] = Int($iTotalVector * $iTotalIndexes)
						EndIf
						
						If StringInStr($asCommand[4], "-") Then $asCommand[4] = StringSplit($asCommand[4], "-", $STR_NOCOUNT)[0]
						
						If int($asCommand[4]) <= 0 Then
							If $asCommand[4] <> "0" Then SetLog("CSV troop amount/setting '" & $asCommand[4] & "' is unrecognized - Line: " & $iLine + 1, $COLOR_ERROR)
							ContinueLoop ; discard TRAIN commands due to the invalid troop amount/setting ex. int(chars)=0, negative #. "0" won't get alerted
						EndIf
						
						Switch $iTroopIndex
							Case $eBarb To $eTroopCount - 1
								$aiCSVTroops[$iTroopIndex] = Int($asCommand[4])
							Case $eLSpell To $eSpellCount + $eLSpell - 1
								$aiCSVSpells[$iTroopIndex - $eLSpell] = int($asCommand[4])
							Case $eWallW To $eSiegeMachineCount + $eWallW - 1
								$aiCSVSieges[$iTroopIndex - $eWallW] = int($asCommand[4])
						EndSwitch
						If $g_bDebugAttackCSV Then SetLog("Train " & $asCommand[5] & "x " & $asCommand[4], $COLOR_DEBUG)
				EndSwitch
			EndIf
		Next

		$iCSVTotalCapTroops = 0
		For $i = 0 To UBound($aiCSVTroops) - 1
			$iCSVTotalCapTroops += $aiCSVTroops[$i] * $g_aiTroopSpace[$i]
		Next
		
		If $iCSVTotalCapTroops > 0 Then
			$iCSVTotalCapSpells = 0
			For $i = 0 To UBound($aiCSVSpells) - 1
				$iCSVTotalCapSpells += $aiCSVSpells[$i] * $g_aiSpellSpace[$i]
			Next
		EndIf
	EndIf
	
	If $g_bDebugAttackCSV Then SetLog("CSV troop total: " & $iCSVTotalCapTroops, $COLOR_DEBUG)
	If $iCSVTotalCapTroops > 0 Then
		; SetLog("CSV troops total: " & $iCSVTotalCapTroops)
		FixInDoubleTrain($aiCSVTroops, $g_iTotalCampSpace, $g_aiTroopSpace, TroopIndexLookup($g_sCmbFICTroops[$g_iCmbFillIncorrectTroopCombo][0], "ParseTroopsCSV Troops"))
		
		If $iCSVTotalCapSpells > 0 Then FixInDoubleTrain($aiCSVSpells, $g_iTotalSpellValue, $g_aiSpellSpace, TroopIndexLookup($g_sCmbFICSpells[$g_iCmbFillIncorrectSpellCombo][0], "ParseTroopsCSV Spells") - $eLSpell)
	Else
		Return 0
	EndIf

	Return 1
	If $g_bDebugAttackCSV Then SetLog("End of ParseTroopsCSV", $COLOR_DEBUG)
EndFunc   ;==>ParseTroopsCSV
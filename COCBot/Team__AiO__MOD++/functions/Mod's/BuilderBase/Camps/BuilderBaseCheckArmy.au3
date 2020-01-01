#comments-start
; #FUNCTION# ====================================================================================================================
; Name ..........: CheckArmyBuilderBase
; Description ...: Use on Builder Base attack
; Syntax ........: CheckArmyBuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (03-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestCheckArmyBuilderBase()
	SetDebugLog("** TestCheckArmyBuilderBase START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	CheckArmyBuilderBase(True)
	$g_bRunState = $Status
	SetDebugLog("** TestCheckArmyBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestCheckArmyBuilderBase

Func CheckArmyBuilderBase($bTestRun = False)

	FuncEnter(CheckArmyBuilderBase)
	If Not $g_bRunState Then Return
	If Not IsMainPageBuilderBase() Then Return
	Local $bWasVerified = False

	SetDebugLog("** Click Away **", $COLOR_DEBUG)

	ClickP($aAway, 1, 0, "#0332") ;Click Away

	If $bTestRun Then $bWasVerified = False

	If Not $g_bChkBuilderAttack Or $bWasVerified = True Or ($g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3) Or $g_bChkBBRandomAttack Then Return

	Setlog("Entering in Camps!", $COLOR_PURPLE)

	; Check the Train Button
	If Not _ColorCheck(_GetPixelColor($aArmyTrainButtonBB[0], $aArmyTrainButtonBB[1], True), _
			Hex($aArmyTrainButtonBB[2], 6), $aArmyTrainButtonBB[3]) Then Return

	SetDebugLog("** Check the Train Button Detected**", $COLOR_DEBUG)

	; Click on that Button
	Click($aArmyTrainButtonBB[0], $aArmyTrainButtonBB[1], 1)

	; Wait for Window
	If Not _WaitForCheckXML($g_sImgPathFillArmyCampsWindow, "278, 409, 411, 464", True, 10000, 100) Then ; DESRC Done
		Setlog("Can't Open The Fill Army Camps Window!", $COLOR_DEBUG)
		ClickP($aAway, 1, 0, "#0332") ;Click Away
		Return
	EndIf

	SetDebugLog("** Fill Army Camps Window Detected **", $COLOR_DEBUG)

	; Detect how many Camp do you have [Max 6]
	Local $b2Fill = 0
	; [0] = Name Troop ,[1] = Xaxis , [1] = Yaxis
	Local $aCampsCoordinates = DetectCamps($b2Fill)

	If $aCampsCoordinates <> -1 Then

		; Detecting Troops in Camps
		If DetectTroopsInCamps($aCampsCoordinates) <> -1 Or $b2Fill > 0 Then

			Setlog($b2Fill & " Empty Camps to fill.")

			; Detecting Available troops to fill Camps
			Local $TroopsResult = Null, $detected = False

			; GUI options for each Camp
			Local $aArmyCampSelected[6] = [$g_iCmbBBArmy1, $g_iCmbBBArmy2, $g_iCmbBBArmy3, $g_iCmbBBArmy4, $g_iCmbBBArmy5, $g_iCmbBBArmy6]

			; Lets verify EACH current camps
			For $a = 0 To UBound($aCampsCoordinates) - 1

				; Verify if exist a Queued troop and Camp is to fill
				If $aCampsCoordinates[$a][0] = "Queued" And ArmyCampSelectedNames($aArmyCampSelected[$a]) <> "EmptyCamp" Then
					;Setlog("Camp[" & $a + 1 & "] with Queued troop.")
					ContinueLoop
				EndIf

				; Verify if the Troop Selected on GUI is the correct on that Camp, if not , will delete the troop
				If $aCampsCoordinates[$a][0] <> "EmptyCamp" Then
					If $aCampsCoordinates[$a][0] <> ArmyCampSelectedNames($aArmyCampSelected[$a]) Then
						$b2Fill += 1
						DeleteTroop($aCampsCoordinates[$a][0], $aCampsCoordinates[$a][1], $aCampsCoordinates[$a][2])
						If _Sleep(1000) Then ExitLoop
						If ArmyCampSelectedNames($aArmyCampSelected[$a]) <> "EmptyCamp" Then
							Setlog("Camp[" & $a + 1 & "] with incorrect troop, removed!")
							If $TroopsResult = Null Then $TroopsResult = DetectTroopsAvailable(True)
							$detected = True
						Else
							Setlog("Camp[" & $a + 1 & "] with troops, removed!")
						EndIf
					EndIf
				EndIf

				; GUI selection was "Empty Camp"
				If ArmyCampSelectedNames($aArmyCampSelected[$a]) = "EmptyCamp" Then ContinueLoop

				; For Drop and Pekka is necessary a slide before
				If ArmyCampSelectedNames($aArmyCampSelected[$a]) = "Drop" Or ArmyCampSelectedNames($aArmyCampSelected[$a]) = "Pekka" Then
					ClickDrag(575, 522, 280, 522, 50) ; RC Done
					$TroopsResult = Null
					$detected = False
					If _Sleep(1500) Then Return
				EndIf

				If Not $detected And $b2Fill <> 0 Then
					If $TroopsResult = Null Then $TroopsResult = DetectTroopsAvailable(True)
					$detected = True
				EndIf

				If $TroopsResult <> -1 Then
					; GUI selection wasn't "Empty Camp" , Fill with correct Troop/Camp
					For $i = 0 To UBound($TroopsResult) - 1
						If ArmyCampSelectedNames($aArmyCampSelected[$a]) = $TroopsResult[$i][0] And $aCampsCoordinates[$a][0] = "EmptyCamp" Then
							Click($TroopsResult[$i][1], $TroopsResult[$i][2], 1)
							Setlog("Detected " & FullNametroops($TroopsResult[$i][0]) & " and clicked for Camp[" & $a + 1 & "]")
							If _Sleep(500) Then ExitLoop
							$b2Fill -= 1
							If $b2Fill = 0 Then
								Setlog("All Camps are filled!")
								ExitLoop
							EndIf
						EndIf
					Next
				EndIf

				; For Drop and Pekka is necessary a slide after
				If ArmyCampSelectedNames($aArmyCampSelected[$a]) = "Drop" Or ArmyCampSelectedNames($aArmyCampSelected[$a]) = "Pekka" Then
					ClickDrag(280, 522, 575, 522, 50) ; DESRC Done
					$detected = False
					$TroopsResult = Null
					If _Sleep(1500) Then Return
				EndIf
			Next
		Else
			Setlog("Detect Troops In Camps Result Problem!!", $COLOR_WARNING)
		EndIf
	Else
		Setlog("Detect Camps Result Problem!!", $COLOR_WARNING)
	EndIf

	Setlog("Exit from Camps!", $COLOR_PURPLE)
	$bWasVerified = True
	ClickP($aAway, 1, 0, "#0332") ;Click Away
	FuncReturn()

EndFunc   ;==>CheckArmyBuilderBase

Func DetectCamps(ByRef $b2Fill)
	; Detect how many Camp do you have [Max 6]
	Local $aCampsCoordinates[0][3]
	; $aResults[x][0] = Name , $aResults[x][1] = array with coordinates

	Local $DebugLog = False
	If $g_bDebugBBattack Then $DebugLog = True
	; $g_aBundlePathCamps[3] = [1000, "0,345,860,40", True]
	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $aResults = _ImageSearchXML($g_sImgPathCamps, 100, "40,187,820,400", True, $DebugLog)

	If $aResults = -1 Or Not IsArray($aResults) Then Return -1
	Setlog("Detected " & UBound($aResults) & " Camp(s).")

	_CaptureRegion()
	For $i = 0 To UBound($aResults) - 1
		ReDim $aCampsCoordinates[UBound($aCampsCoordinates) + 1][3]
		$aCampsCoordinates[UBound($aCampsCoordinates) - 1][0] = $aResults[$i][0]
		$aCampsCoordinates[UBound($aCampsCoordinates) - 1][1] = $aResults[$i][1]
		$aCampsCoordinates[UBound($aCampsCoordinates) - 1][2] = $aResults[$i][2]
		SetDebugLog("Camp Coordinates: " & $aResults[$i][1] & "," & $aResults[$i][2])
		If $aResults[$i][0] = "QueuedCamp" Then
			$aCampsCoordinates[UBound($aCampsCoordinates) - 1][0] = "Queued"
		Else
			SetDebugLog("[-] Color Check at (" & $aResults[$i][1] + 60 & "," & $aResults[$i][2] - 75 & "): " & _GetPixelColor($aResults[$i][1] + 60, $aResults[$i][2] - 75, False))
			If _ColorCheck(_GetPixelColor($aResults[$i][1] + 60, $aResults[$i][2] - 75, False), Hex(0xCDCDC6, 6), 15) Then ; RC Done
				$b2Fill += 1
				$aCampsCoordinates[UBound($aCampsCoordinates) - 1][0] = "EmptyCamp"
			EndIf
		EndIf
	Next

	_ArraySort($aCampsCoordinates, 0, 0, 0, 1)

	Return $aCampsCoordinates
EndFunc   ;==>DetectCamps

Func DetectTroopsInCamps(ByRef $aCampsCoordinates)
	; Max 6 armys
	Local $aResults = QuickMIS("NxCx", $g_sImgPathTroopsTrain, 40, 245, 817, 310, True, False)

	If $aResults = 0 Then Return -1

	Local $aCoordinates, $aCoord
	Local $camps = 1, $aTroopsCoordinates[0][3], $troop = 0

	For $i = UBound($aResults) - 1 To 0 Step -1
		$aCoordinates = Null
		$aCoordinates = $aResults[$i][1]
		For $j = 0 To UBound($aCoordinates) - 1
			$aCoord = Null
			ReDim $aTroopsCoordinates[UBound($aTroopsCoordinates) + 1][3]
			$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][0] = $aResults[$i][0]
			$aCoord = $aCoordinates[$j]
			$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][1] = Int($aCoord[0] + 40) ; Xaxis
			$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][2] = Int($aCoord[1] + 245) ; YAxis
		Next
	Next
	; Sort by X-axis
	_ArraySort($aTroopsCoordinates, 0, 0, 0, 1)
	For $a = 0 To UBound($aCampsCoordinates) - 1
		If $aCampsCoordinates[$a][0] = "EmptyCamp" Then
			Setlog(" - Camp " & $a + 1 & ": " & "Empty Camp")
			ContinueLoop
		EndIf
		If $aCampsCoordinates[$a][0] = "Queued" Then
			Setlog(" - Camp " & $a + 1 & ": " & "Queued Troops")
			ContinueLoop
		EndIf
		If $troop > UBound($aTroopsCoordinates) - 1 Then
			Setlog(" - Camp " & $a + 1 & ": " & "Troop Not Recognized")
			ContinueLoop
		EndIf
		$aCampsCoordinates[$a][0] = $aTroopsCoordinates[$troop][0]
		Setlog(" - Camp " & $a + 1 & ": " & FullNametroops($aCampsCoordinates[$a][0]))
		SetDebugLog("Camp [" & $a + 1 & "] - " & $aCampsCoordinates[$a][1] & "x" & $aCampsCoordinates[$a][2])
		$troop += 1
	Next
	Return $aCampsCoordinates
EndFunc   ;==>DetectTroopsInCamps

Func DeleteTroop(ByRef $Name, $X, $Y)
	; FD8992 Is Light Red button to delete the troop :  X+93 and Y-91 are the offsets to Red Button  ; FD898D
	SetDebugLog("Camp Coordinates: " & $X & "," & $Y)
	SetDebugLog("Red Color Check: " & _GetPixelColor($X + 93, $Y - 91, True))
	If _ColorCheck(_GetPixelColor($X + 93, $Y - 91, True), Hex(0xFD8992, 6), 40) Or _ColorCheck(_GetPixelColor($X + 93, $Y - 91, True), Hex(0xE50E0E, 6), 40) Then
		Click($X + 93, $Y - 91, 1)
		$Name = "EmptyCamp"
	EndIf
EndFunc   ;==>DeleteTroop

Func ArmyCampSelectedNames($g_iCmbBBArmy1)
	Local $Names[11] = ["EmptyCamp", "Barb", "Arch", "Giant", "Beta", "Bomb", "BabyDrag", "Cannon", "Night", "Drop", "Pekka"]
	Return $Names[$g_iCmbBBArmy1]
EndFunc   ;==>ArmyCampSelectedNames

Func DetectTroopsAvailable($log = False)

	Local $aResults = 0
	$aResults = QuickMIS("NxCx", $g_sImgPathTroopsTrain, 37, 240, 820, 346, True, False) ; RC Done

	If $aResults = 0 Then Return -1

	Local $aTroopsCoordinates[0][3], $aCoordinates, $aCoord
	Local $text = ""

	For $i = UBound($aResults) - 1 To 0 Step -1
		$aCoordinates = Null
		$aCoordinates = $aResults[$i][1]
		ReDim $aTroopsCoordinates[UBound($aTroopsCoordinates) + 1][3]
		$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][0] = $aResults[$i][0] ; NAME
		For $j = 0 To UBound($aCoordinates) - 1
			$aCoord = Null
			$aCoord = $aCoordinates[$j]
			SetDebugLog(" - " & $aCoord[0] + 45 & "x" & $aCoord[1] + 480)
			$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][1] = Int($aCoord[0] + 45) ; Xaxis
			$aTroopsCoordinates[UBound($aTroopsCoordinates) - 1][2] = Int($aCoord[1] + 480) ; YAxis
		Next
	Next
	; Sort by X-axis
	_ArraySort($aTroopsCoordinates, 0, 0, 0, 1)
	; Log
	For $i = 0 To UBound($aTroopsCoordinates) - 1
		$text = FullNametroops($aTroopsCoordinates[$i][0])
		If $log Then Setlog(" - Available " & $text & " ")
	Next

	Return $aTroopsCoordinates
EndFunc   ;==>DetectTroopsAvailable

Func FullNametroops($aResults)
	For $i = 0 To $eBBTroopCount - 1
		If $aResults = $g_asBBTroopShortNames[$i] Then Return $g_asBBTroopNames[$i]
	Next
EndFunc   ;==>FullNametroops
#comments-end


; #FUNCTION# ====================================================================================================================
; Name ..........: CheckArmyBuilderBase
; Description ...: Use on Builder Base attack
; Syntax ........: CheckArmyBuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (98 % like W. W.) (2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once
Global $g_aTroopButton = 0

Func TestCheckArmyBuilderBase()
	SetDebugLog("** TestCheckArmyBuilderBase START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	CheckArmyBuilderBase(True)
	$g_bRunState = $Status
	SetDebugLog("** TestCheckArmyBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestCheckArmyBuilderBase

Func CheckArmyBuilderBase($bDebug = False)

	FuncEnter(CheckArmyBuilderBase)
	If Not $g_bRunState Then Return
	If Not IsMainPageBuilderBase() Then Return

	SetDebugLog("** Click Away **", $COLOR_DEBUG)

	ClickP($aAway, 1, 0, "#0332") ;Click Away

	Setlog("Entering troops", $COLOR_PURPLE)

	; Check the Train Button
	If Not _ColorCheck(_GetPixelColor($aArmyTrainButtonBB[0], $aArmyTrainButtonBB[1], True), _
			Hex($aArmyTrainButtonBB[2], 6), $aArmyTrainButtonBB[3]) Then Return

	SetDebugLog("** Check the Train Button Detected**", $COLOR_DEBUG)

	; Click on that Button
	Click($aArmyTrainButtonBB[0], $aArmyTrainButtonBB[1], 1)

	; Wait for Window
	If Not _WaitForCheckXML($g_sImgPathFillArmyCampsWindow, "278, 409, 411, 464", True, 10000, 100) Then
		Setlog("Can't Open The Fill Army Camps Window!", $COLOR_DEBUG)
		ClickP($aAway, 1, 0, "#0332") ;Click Away
		Return
	EndIf

	SetDebugLog("** Fill Army Camps Window Detected **", $COLOR_DEBUG)

	DetectCamps()

	Setlog("Exit from Camps!", $COLOR_PURPLE)
	ClickP($aAway, 1, 0, "#0332") ;Click Away
	FuncReturn()

EndFunc   ;==>CheckArmyBuilderBase

Func DetectCamps()
	Local $iArmyCampsInBB[6] = [0, 0, 0, 0, 0, 0]
	Local $asAttackBarBB = _ArrayExtract($g_asAttackBarBB, 1, UBound($g_asAttackBarBB)-1)
	Local $DebugLog = False
	If $g_bDebugBBattack Then $DebugLog = True

	If _Sleep(Random(500, 1000, 1)) Then Return

	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $aResults = _ImageSearchXML($g_sImgPathCamps, 100, "40,187,820,400", True, $DebugLog) ; Cantidad de campametos

	If $aResults = -1 Or Not IsArray($aResults) Then Return -1
	Setlog("Detected " & UBound($aResults) & " Camp(s).")

	; Limit GUI camps and Camps ($iArmyCampsBB).
	Local $aCmbCampsInBBGUILimited = _ArrayExtract($g_iCmbCampsBB, 0, UBound($aResults)-1)

	; Limit Camps of game to detected
	Local $iArmyCampsInBBLimited = _ArrayExtract($iArmyCampsInBB, 0, UBound($aResults)-1)

	; Fill $iArmyCampsBB (only one capture like FreeMagicItems system)
	Local $aTroops = _ImageSearchXML($g_sImgPathTroopsTrain, 100, "40,245,817,310", True, $DebugLog) ; Troops in camps

	; Train matrix
	Local $aTrainLikeBoss[$g_iBBTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	For $i = 0 To UBound($aCmbCampsInBBGUILimited) -1
		$aTrainLikeBoss[$aCmbCampsInBBGUILimited[$i]] += 1
	Next

	_CaptureRegion()
	;Troops detect
	For $i = 0 To UBound($iArmyCampsInBBLimited) - 1
		Local $X = $aResults[$i][1], $Y = $aResults[$i][2], $iDiffSlot = Abs($aResults[0][1] - $aResults[1][1])

		If _ColorCheck(_GetPixelColor($X + 60, $Y  - 75, False), Hex(0xCDCDC6, 6), 15) Then ; check empty
			$iArmyCampsInBBLimited[$i] = -1
		ElseIf BitAnd($X < $aTroops[$i][1], Int($X + $iDiffSlot) > $aTroops[$i][1] ) Then
			$iArmyCampsInBBLimited[$i] = _ArraySearch($asAttackBarBB, $aTroops)

			Local $iIsInCamp = $iArmyCampsInBBLimited[$i]

			If $iIsInCamp <> -1 Then
				If $aTrainLikeBoss[$iIsInCamp] = 0 Then
					If DeleteTroop($X, $Y) Then $iArmyCampsInBBLimited[$i] = -1
				ElseIf $aTrainLikeBoss[$iIsInCamp] > 0 Then
					$aTrainLikeBoss[$iIsInCamp] -= 1
					If $aTrainLikeBoss[$iIsInCamp] <> -1 Then ContinueLoop
					If DeleteTroop($X, $Y) Then $iArmyCampsInBBLimited[$i] = -1
					$aTrainLikeBoss[$iIsInCamp] += 1
				EndIf
			Else
				If DeleteTroop($X, $Y) Then
					$iArmyCampsInBBLimited[$i] = -1
					Setlog("Builder base army: Troop not recognized, eliminated.", $COLOR_WARNING)
				EndIf
			EndIf
		EndIf

		If _Sleep(10) Then Return
	Next

	;Troops Train
	Local $bIsLlog = False
	For $i = 0 To UBound($aTrainLikeBoss) -1
		If $aTrainLikeBoss[$i] > 0 Then
			If LocateTroopButton($i) <> 0 Then
				If $bIsLlog = False Then
					SetLog("Builder base army - Train :", $COLOR_SUCCESS)
					$bIsLlog = True
				EndIf
				MyTrainClick($g_aTroopButton)
				SetLog("- x" & $aTrainLikeBoss[$i] & " " & $g_avStarLabTroops[$i+1][3], $COLOR_SUCCESS)
				Else
				SetLog("Builder base army: LocateTroopButton troop not unlocked or fail.", $COLOR_ERROR)
			EndIf
		EndIf
		If _Sleep(Random((400*90)/100, (400*110)/100, 1), False) Then Return
	Next

EndFunc   ;==>DetectCamps

Func DeleteTroop($X, $Y)
	; FD8992 Is Light Red button to delete the troop :  X+93 and Y-91 are the offsets to Red Button  ; FD898D
	SetDebugLog("Camp Coordinates: " & $X & "," & $Y)
	SetDebugLog("Red Color Check: " & _GetPixelColor($X + 93, $Y - 91, True))
	If _ColorCheck(_GetPixelColor($X + 93, $Y - 91, True), Hex(0xFD8992, 6), 40) Or _ColorCheck(_GetPixelColor($X + 93, $Y - 91, True), Hex(0xE50E0E, 6), 40) Then
		Click($X + 93, $Y - 91, 1)
		Return True
	EndIf
	Setlog("Builder base army: Fail DeleteTroop.", $COLOR_ERROR)
	Return False
EndFunc   ;==>DeleteTroop

; Samkie inspired code
Func LocateTroopButton($iTroopButton)
		Global $g_aTroopButton[2] = [0, 0]

		Local $asAttackBarBB = _ArrayExtract($g_asAttackBarBB, 1, UBound($g_asAttackBarBB)-1)

        Local $sRegionForScan = "37, 240, 820, 346"
		Local $sImgTrain = $g_sImgPathTroopsTrain
		Local $iButtonIsIn
		Local $bDebugLog = False

		If $iTroopButton > UBound($asAttackBarBB)-1 Then SetLog("Train army on BB: Troop not rocognized, it return first.", $COLOR_ERROR)

		For $i = 0 To 10
			Local $aTroopPosition = _ImageSearchXML($sImgTrain, 100, $sRegionForScan, True, $bDebugLog)
			If $aTroopPosition = 0 Or UBound($aTroopPosition) < 1 Then Return 0

			$iButtonIsIn = _ArraySearch($aTroopPosition, $asAttackBarBB[$iTroopButton])

			If $iButtonIsIn <> -1 Then
				$g_aTroopButton[0] = $aTroopPosition[$iButtonIsIn][1]
				$g_aTroopButton[1] = $aTroopPosition[$iButtonIsIn][2]
				Return $g_aTroopButton
			ElseIf _ArraySearch($asAttackBarBB, $aTroopPosition[0][0]) < $iTroopButton Then
				ClickDrag(575, 522, 280, 522, 50)
			ElseIf _ArraySearch($asAttackBarBB, $aTroopPosition[UBound($aTroopPosition)-1][0]) > $iTroopButton Then
				ClickDrag(280, 522, 575, 522, 50)
			EndIf

			If _Sleep(500) Then Return
		Next

		SetLog("Cannot find " & $asAttackBarBB[$iTroopButton] & " for scan", $COLOR_ERROR)

		Global $g_aTroopButton = 0
		Return 0

EndFunc

Func MyTrainClick($iXY, $iTimes = 1, $iSpeed = 0, $sdebugtxt="")
			If not IsArray($iXY) Then Return False
			Local $x = $iXY[0], $y = $iXY[1]
			Local $iHLFClickMin = 7, $iHLFClickMax = 14
			Local $isldHLFClickDelayTime = 400
			Local $iRandNum = Random($iHLFClickMin-1,$iHLFClickMax-1,1) ;Initialize value (delay awhile after $iRandNum times click)
			Local $iRandX = Random($x - 5,$x + 5,1),$iRandY = Random($y - 5,$y + 5,1)
			If isProblemAffect(True) Then Return
			For $i = 0 To ($iTimes - 1)
				PureClick(Random($iRandX-2,$iRandX+2,1), Random($iRandY-2,$iRandY+2,1))
				If $i >= $iRandNum Then
					$iRandNum = $iRandNum + Random($iHLFClickMin,$iHLFClickMax,1)
					$iRandX = Random($x - 5, $x + 5,1)
					$iRandY = Random($y - 5, $y + 5,1)
					If _Sleep(Random(($isldHLFClickDelayTime*90)/100, ($isldHLFClickDelayTime*110)/100, 1), False) Then Return
				Else
					If _Sleep(Random(($iSpeed*90)/100, ($iSpeed*110)/100, 1), False) Then Return
				EndIf
			Next
EndFunc   ;==>MyTrainClick

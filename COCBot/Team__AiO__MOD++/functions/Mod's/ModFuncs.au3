; #FUNCTION# ====================================================================================================================
; Name ..........: ModFuncs.au3
; Description ...: Avoid loss of functions during updates.
; Author ........: Boludoz (2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func _MultiPixelSearchMod($iLeft, $iTop, $iRight, $iBottom, $xSkip, $ySkip, $firstColor, $offColor, $iColorVariation)

	Local $aTmp = _MultiPixelSearch($iLeft, $iTop, $iRight, $iBottom, $xSkip, $ySkip, $firstColor, $offColor, $iColorVariation)

	If $aTmp <> 0 Then
		$g_iMultiPixelOffSet[0] = $aTmp[0]
		$g_iMultiPixelOffSet[1] = $aTmp[1]

		Return $g_iMultiPixelOffSet
	Else
		$g_iMultiPixelOffSet[0] = Null
		$g_iMultiPixelOffSet[1] = Null

		Return 0
	EndIf

EndFunc   ;==>_MultiPixelSearchMod

Func getOcrAndCapture($language, $x_start, $y_start, $width, $height, $removeSpace = Default, $bImgLoc = Default, $bForceCaptureRegion = Default)
	$g_sGetOcrMod = ""
	If $removeSpace = Default Then $removeSpace = False
	If $bImgLoc = Default Then $bImgLoc = False
	If $bForceCaptureRegion = Default Then $bForceCaptureRegion = $g_bOcrForceCaptureRegion
    Static $_hHBitmap = 0
    If $bForceCaptureRegion = True Then
        _CaptureRegion2($x_start, $y_start, $x_start + $width, $y_start + $height)
    Else
        $_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $x_start, $y_start, $x_start + $width, $y_start + $height)
    EndIf
    Local $result
    If $bImgLoc Then
		If $_hHBitmap <> 0 Then
			$result = getOcrImgLoc($_hHBitmap, $language)
		Else
			$result = getOcrImgLoc($g_hHBitmap2, $language)
		EndIf
	Else
		If $_hHBitmap <> 0 Then
			$result = getOcr($_hHBitmap, $language)
		Else
			$result = getOcr($g_hHBitmap2, $language)
		EndIf
	EndIf
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If ($removeSpace) Then
		$result = StringReplace($result, " ", "")
	Else
		$result = StringStripWS($result, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	EndIf
	$g_sGetOcrMod = $result
	Return $result
EndFunc   ;==>getOcrAndCapture

Func _ImageSearchXML($sDirectory, $Quantity2Match = 0, $saiArea2SearchOri = "0,0,860,732", $bForceCapture = True, $DebugLog = False, $checkDuplicatedpoints = False, $Distance2check = 25, $iLevel = 0)
	$g_aImageSearchXML = -1

	Local $iMax = 0

	Local $sSearchDiamond = GetDiamondFromRect($saiArea2SearchOri)
	Local $aResult = findMultiple($sDirectory , $sSearchDiamond, $sSearchDiamond, $iLevel, 1000, $Quantity2Match, "objectname,objectlevel,objectpoints", $bForceCapture)
	If Not IsArray($aResult) Then Return -1

	Local $iCount = 0

	$iMax = UBound($aResult) -1

	; Compatible with BuilderBaseBuildingsDetection()[old function] same return array
	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $AllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To $iMax
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) -1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)
			; Inspired in Chilly-chill
			Local $aTmpResults[1][4] = [[$aArrays[0], Int($aCommaCoord[0]), Int($aCommaCoord[1]), Int($aArrays[1])]]
			_ArrayAdd($AllResults, $aTmpResults)
		Next
		$iCount += 1
	Next
	If $iCount < 1 Then Return -1

	If $checkDuplicatedpoints And UBound($AllResults) > 0 Then
		; Sort by X axis
		_ArraySort($AllResults, 0, 0, 0, 1)

		; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
		Local $D2Check = $Distance2check

		; check if is a double Detection, near in 10px
		Local $Dime = 0
		For $i = 0 To UBound($AllResults) - 1
			If $i > UBound($AllResults) - 1 Then ExitLoop
			Local $LastCoordinate[4] = [$AllResults[$i][0], $AllResults[$i][1], $AllResults[$i][2], $AllResults[$i][3]]
			SetDebugLog("Coordinate to Check: " & _ArrayToString($LastCoordinate))
			If UBound($AllResults) > 1 Then
				For $j = 0 To UBound($AllResults) - 1
					If $j > UBound($AllResults) - 1 Then ExitLoop
					; SetDebugLog("$j: " & $j)
					; SetDebugLog("UBound($aAllResults) -1: " & UBound($aAllResults) - 1)
					Local $SingleCoordinate[4] = [$AllResults[$j][0], $AllResults[$j][1], $AllResults[$j][2], $AllResults[$j][3]]
					; SetDebugLog(" - Comparing with: " & _ArrayToString($SingleCoordinate))
					If $LastCoordinate[1] <> $SingleCoordinate[1] Or $LastCoordinate[2] <> $SingleCoordinate[2] Then
						If $SingleCoordinate[1] < $LastCoordinate[1] + $D2Check And $SingleCoordinate[1] > $LastCoordinate[1] - $D2Check Then
							; SetDebugLog(" - removed : " & _ArrayToString($SingleCoordinate))
							_ArrayDelete($AllResults, $j)
						EndIf
					Else
						If $LastCoordinate[1] = $SingleCoordinate[1] And $LastCoordinate[2] = $SingleCoordinate[2] And $LastCoordinate[3] <> $SingleCoordinate[3] Then
							; SetDebugLog(" - removed equal level : " & _ArrayToString($SingleCoordinate))
							_ArrayDelete($AllResults, $j)
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf

	If (UBound($AllResults) > 0) Then
	;_ArrayDisplay($AllResults)
		$g_aImageSearchXML = $AllResults
		Return $AllResults
	Else
		$g_aImageSearchXML = -1
		Return -1
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: ClickOther
; Description ...: checks for window with 'Find a Match', 'Remove Obstacles', 'Collect LootCard' button, and clicks it
; Syntax ........:
; Parameters ....: $bCheckOneTime       - (optional) Boolean flag - only checks for Find a Match button once
; Return values .: Returns True if button found, if button not found, then returns False and sets @error = 1
; Author ........: NguyenAnhHD (2019-06)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ClickFindMatch($bCheckOneTime = False)
	Local $i = 0
	If _Sleep($DELAYSPECIALCLICK1) Then Return False ; Wait for Find a Match button window
	While 1 ; Wait for window with Find a Match Button
		Local $offColors[2][3] = [[0xF56B1B, 4, 0], [0xFFD155, 15, 0]]
		Local $ButtonPixel = _MultiPixelSearch(570, 320 + $g_iMidOffsetY, 620, 400 + $g_iMidOffsetY, 1, 1, Hex(0xFFFBDE, 6), $offColors, 15)
		If IsArray($ButtonPixel) Then
			If $g_bDebugSetlog Then
				SetDebugLog("ButtonPixelLocation = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
				SetDebugLog("Pixel color found #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & _
											", #2: " & _GetPixelColor($ButtonPixel[0] + 4, $ButtonPixel[1], True) & _
											", #3: " & _GetPixelColor($ButtonPixel[0] + 15, $ButtonPixel[1], True), $COLOR_DEBUG)
			EndIf
			Local $aFindMatchButtonRND[4] = [$ButtonPixel[0] + 30, $ButtonPixel[1] + 20, $ButtonPixel[0] + 140, $ButtonPixel[1] + 50]
			If Not $g_bUseRandomClick Then
				PureClick($ButtonPixel[0] + 100, $ButtonPixel[1] + 30, 1, 0) ; Click Find a Match Button
			Else
				ClickR($aFindMatchButtonRND, $ButtonPixel[0] + 30, $ButtonPixel[1] + 20, 1, 0)
			EndIf
			ExitLoop
		EndIf
		If $bCheckOneTime Then Return False ; enable external control of loop count or follow on actions, return false if not clicked
		If $i > 5 Then
			SetLog("Can not find button for Find a Match, giving up", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("FindMatch_ButtonCheck_")
			SetError(1, @extended, False)
			Return
		EndIf
		$i += 1
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	WEnd
	Return True
EndFunc   ;==>ClickFindMatch

Func ClickCollect($bCheckOneTime = False)
	Local $i = 0
	If _Sleep($DELAYSPECIALCLICK1) Then Return False ; Wait for 'Collect LootCard' button window
	While 1 ; Wait for window with 'Collect LootCard' Button
		Local $offColors[3][3] = [[0x0D0D0D, 82, 0], [0xFFFFFF, 36, 53], [0xFFFFFF, 62, 53]]
		Local $ButtonPixel = _MultiPixelSearch(330, 555 + $g_iMidOffsetY, 530, 645 + $g_iMidOffsetY, 1, 1, Hex(0x0D0D0D, 6), $offColors, 15)
		If IsArray($ButtonPixel) Then
			If $g_bDebugSetlog Then
				SetDebugLog("ButtonPixelLocation = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
				SetDebugLog("Pixel color found #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & _
											", #2: " & _GetPixelColor($ButtonPixel[0] + 82, $ButtonPixel[1], True) & _
											", #3: " & _GetPixelColor($ButtonPixel[0] + 36, $ButtonPixel[1] + 53, True) & _
											", #4: " & _GetPixelColor($ButtonPixel[0] + 62, $ButtonPixel[1] + 53, True), $COLOR_DEBUG)
			EndIf
			PureClick($ButtonPixel[0] + 40, $ButtonPixel[1] + 20, 1, 0) ; Click 'Collect LootCard' Button
			ExitLoop
		EndIf
		If $bCheckOneTime Then Return False ; enable external control of loop count or follow on actions, return false if not clicked
		If $i > 5 Then
			SetLog("Can not find button for 'Collect LootCard', giving up", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("Collect_ButtonCheck_")
			SetError(1, @extended, False)
			Return
		EndIf
		$i += 1
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	WEnd
	Return True
EndFunc   ;==>ClickCollect

Func ClickRemoveObstacles($bCheckOneTime = False)
	Local $i = 0
	If _Sleep($DELAYSPECIALCLICK1) Then Return False ; Wait for 'Remove Obstacles' button window
	While 1 ; Wait for window with 'Remove Obstacles' Button
		Local $offColors[3][3] = [[0x0D0D0D, 82, 0], [0xFCFCFC, 17, 53], [0xFCFCFC, 35, 55]]
		Local $ButtonPixel = _MultiPixelSearch(330, 555 + $g_iMidOffsetY, 530, 645 + $g_iMidOffsetY, 1, 1, Hex(0x0D0D0D, 6), $offColors, 15)
		If IsArray($ButtonPixel) Then
			If $g_bDebugSetlog Then
				SetDebugLog("ButtonPixelLocation = " & $ButtonPixel[0] & ", " & $ButtonPixel[1], $COLOR_DEBUG) ;Debug
				SetDebugLog("Pixel color found #1: " & _GetPixelColor($ButtonPixel[0], $ButtonPixel[1], True) & _
											", #2: " & _GetPixelColor($ButtonPixel[0] + 82, $ButtonPixel[1], True) & _
											", #3: " & _GetPixelColor($ButtonPixel[0] + 17, $ButtonPixel[1] + 53, True) & _
											", #4: " & _GetPixelColor($ButtonPixel[0] + 35, $ButtonPixel[1] + 55, True), $COLOR_DEBUG)
			EndIf
			PureClick($ButtonPixel[0] + 40, $ButtonPixel[1] + 20, 1, 0) ; Click 'Remove Obstacles' Button
			ExitLoop
		EndIf
		If $bCheckOneTime Then Return False ; enable external control of loop count or follow on actions, return false if not clicked
		If $i > 5 Then
			SetLog("Can not find button for 'Remove Obstacles', giving up", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("Remove_ButtonCheck_")
			SetError(1, @extended, False)
			Return
		EndIf
		$i += 1
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	WEnd
	Return True
EndFunc   ;==>ClickRemoveObstacles

Func SearchNoLeague($bCheckOneTime = False)
	Local $i = 0
	If _Sleep($DELAYSPECIALCLICK1) Then Return False ; Wait for 'Remove Obstacles' button window
	While 1 ; Wait for window with 'Remove Obstacles' Button
		Local $offColors[2][3] = [[0xFBFDFB, 28, 0], [0x626462, 15, 5]]
		Local $NoLeaguePixel = _MultiPixelSearch(5, 10, 50, 50, 1, 1, Hex(0xFFFFFF, 6), $offColors, 15)
		If $g_bDebugSetlog Then SetDebugLog("NoLeague pixel chk-#1: " & _GetPixelColor(13, 24, True) & _
															", #2: " & _GetPixelColor(13 + 28, 24, True) & _
															", #3: " & _GetPixelColor(13 + 15, 24 + 5, True), $COLOR_DEBUG)
		If IsArray($NoLeaguePixel) Then
			If $g_bDebugSetlog Then
				SetDebugLog("NoLeaguePixelLocation = " & $NoLeaguePixel[0] & ", " & $NoLeaguePixel[1], $COLOR_DEBUG) ;Debug
				SetDebugLog("Pixel color found #1: " & _GetPixelColor($NoLeaguePixel[0], $NoLeaguePixel[1], True) & _
											", #2: " & _GetPixelColor($NoLeaguePixel[0] + 28, $NoLeaguePixel[1], True) & _
											", #3: " & _GetPixelColor($NoLeaguePixel[0] + 15, $NoLeaguePixel[1] + 5, True), $COLOR_DEBUG)
			EndIf
			ExitLoop
		EndIf
		If $bCheckOneTime Then Return False ; enable external control of loop count or follow on actions, return false if not clicked
		If $i > 5 Then
			SetDebugLog("Can not find pixel for 'No League', giving up", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("NoLeague_")
			SetError(1, @extended, False)
			Return
		EndIf
		$i += 1
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	WEnd
	Return True
EndFunc   ;==>SearchNoLeague

Func SpecialAway()
	_Sleep(Random(0,2000,1))
	Local $aSpecialAway[2] = [Random(1,4,1), Random(1,50,1)]
	If $g_bDebugClick Or TestCapture() Then SetLog("Click SpecialAway " & $aSpecialAway[0] & ", " & $aSpecialAway[1], $COLOR_ACTION, "Verdana", "7.5", 0)
	ClickP($aSpecialAway)
EndFunc

Func UnderstandChatRules()
	;LEFT - 68, 447, 92, 479
	;RIGHT - 223, 448, 249, 479
	;DDF685
	Local $aClanBadgeNoClan[4] = [151, 307, 0xF05538, 20] ; OK - Orange Tile of Clan Logo on Chat Tab if you are not in a Clan

	If IsArray(MultiPSimple(68, 447, 92, 479, Hex(0xDDF685, 6), 15, 5000)) AND NOT _WaitForCheckPixel($aClanBadgeNoClan, $g_bCapturePixel, Default, "") Then
		Click(Random(90, 248, 1), Random(448, 479, 1))
		If _Sleep(500) Then Return
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: IsSlotDead
; Description ...: If Is Slot Dead Return True
; Syntax ........: IsSlotDead($iSlotNumber)
; Parameters ....: $iSlotNumber               - an unknown value.
; Return values .: None
; Author ........: Boludoz/Boldina (8/3/2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: IsSlotDead(1)
; ===============================================================================================================================
Func IsSlotDead()
	; Fuse
	If $g_aIsDead[$g_iSlotNow] = 1 Then Return True
	
	Local $iX = Int($g_avAttackTroops[$g_iSlotNow][3])
	Local $iY = Int($g_avAttackTroops[$g_iSlotNow][4])
	
	If  _ColorCheck(_GetPixelColor($iX + 20, $iY + 20, True, "WAIT--> IsSlotDead"), Hex(0x474747, 6), 10) Then
		SetLog("Slot Dead X: " & $iX & " Y: " & $iY & " Slot: " & $g_iSlotNow, $COLOR_ORANGE)
			$g_aIsDead[$g_iSlotNow] = 1
		Return True
	EndIf
	Return False
EndFunc   ;==>IsSlotDead

Func AttackClick($x, $y, $times = 1, $speed = 0, $afterDelay = 0, $debugtxt = "")
	Local $timer = __TimerInit(), $bReturn = True
	; Protect the Attack Bar
	If $y > 555 + $g_iBottomOffsetY Then $y = 555 + $g_iBottomOffsetY
	AttackRemainingTime(False) ; flag attack started
	If $times = 1 Then
		$bReturn = PureClick($x, $y, 1, $speed, $debugtxt)
	Else 
		For $i = 1 To $times
			IsSlotDead()
			$bReturn = ($g_aIsDead[$g_iSlotNow] = 1) ? (True) : (PureClick($x, $y, 1, $speed, $debugtxt))
		Next
	EndIf
	Local $delay = $times * $speed + $afterDelay - __TimerDiff($timer)
	If IsKeepClicksActive() = False And $delay > 0 Then _Sleep($delay, False)
	Return $bReturn
EndFunc   ;==>AttackClick

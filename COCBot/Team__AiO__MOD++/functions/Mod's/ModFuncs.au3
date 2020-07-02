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

Func _ImageSearchXML($sDirectory, $iQuantity2Match = 0, $saiArea2SearchOri = "0,0,860,732", $bForceCapture = True, $bDebugLog = False, $bCheckDuplicatedpoints = False, $iDistance2check = 25, $iLevel = 0)
	FuncEnter(_ImageSearchXML)
	$g_aImageSearchXML = -1

	Local $sSearchDiamond = GetDiamondFromRect($saiArea2SearchOri)
	Local $aResult = findMultiple($sDirectory, $sSearchDiamond, $sSearchDiamond, $iLevel, 1000, $iQuantity2Match, "objectname,objectlevel,objectpoints", $bForceCapture)
	If Not IsArray($aResult) Then Return -1

	Local $iCount = 0

	; Compatible with BuilderBaseBuildingsDetection()[old function] same return array
	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $aAllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To UBound($aResult) - 1
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) - 1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)
			; Inspired in Chilly-chill
			Local $aTmpResults[1][4] = [[$aArrays[0], Int($aCommaCoord[0]), Int($aCommaCoord[1]), Int($aArrays[1])]]
			_ArrayAdd($aAllResults, $aTmpResults)
		Next
		$iCount += 1
		If ($iQuantity2Match < 0) And ($iCount <= $iQuantity2Match) Then ExitLoop
	Next
	;If $iCount < 1 Then Return -1 what

	If $bCheckDuplicatedpoints And UBound($aAllResults) > 0 Then
		; Sort by X axis
		_ArraySort($aAllResults, 0, 0, 0, 1)

		; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
		Local $iD2Check = $iDistance2check

		; check if is a double Detection, near in 10px
		For $i = 0 To UBound($aAllResults) - 1
			If $i > UBound($aAllResults) - 1 Then ExitLoop
			Local $LastCoordinate[4] = [$aAllResults[$i][0], $aAllResults[$i][1], $aAllResults[$i][2], $aAllResults[$i][3]]
			SetDebugLog("Coordinate to Check: " & _ArrayToString($LastCoordinate))
			If UBound($aAllResults) > 1 Then
				For $j = 0 To UBound($aAllResults) - 1
					If $j > UBound($aAllResults) - 1 Then ExitLoop
					; SetDebugLog("$j: " & $j)
					; SetDebugLog("UBound($aAllResults) -1: " & UBound($aAllResults) - 1)
					Local $SingleCoordinate[4] = [$aAllResults[$j][0], $aAllResults[$j][1], $aAllResults[$j][2], $aAllResults[$j][3]]
					; SetDebugLog(" - Comparing with: " & _ArrayToString($SingleCoordinate))
					If $LastCoordinate[1] <> $SingleCoordinate[1] Or $LastCoordinate[2] <> $SingleCoordinate[2] Then
						If $SingleCoordinate[1] < $LastCoordinate[1] + $iD2Check And $SingleCoordinate[1] > $LastCoordinate[1] - $iD2Check Then
							; SetDebugLog(" - removed : " & _ArrayToString($SingleCoordinate))
							_ArrayDelete($aAllResults, $j)
						EndIf
					Else
						If $LastCoordinate[1] = $SingleCoordinate[1] And $LastCoordinate[2] = $SingleCoordinate[2] And $LastCoordinate[3] <> $SingleCoordinate[3] Then
							; SetDebugLog(" - removed equal level : " & _ArrayToString($SingleCoordinate))
							_ArrayDelete($aAllResults, $j)
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf

	If (UBound($aAllResults) > 0) Then
		;_ArrayDisplay($aAllResults)
		$g_aImageSearchXML = $aAllResults
		Return $aAllResults
	Else
		$g_aImageSearchXML = -1
		Return -1
	EndIf
EndFunc   ;==>_ImageSearchXML

Func findMultipleQuick($sDirectory, $iQuantityMatch = Default, $vArea2SearchOri = Default, $bForceCapture = Default, $sOnlyFind = Default, $bExactFindP = Default, $iDistance2check = 25, $bDebugLog = False, $iLevel = 0, $iMaxLevel = 1000)
	FuncEnter(findMultipleQuick)
	$g_aImageSearchXML = -1

	Local $bCapture, $sArea2Search, $sIsOnlyFind, $iQuantToMach, $bExactFind, $iQuantity2Match
	$iQuantity2Match = ($iQuantityMatch = Default) ? (0) : ($iQuantityMatch)
	$bCapture = ($bForceCapture = Default) ? (True) : ($bForceCapture)
	$sIsOnlyFind = ($sOnlyFind = Default) ? ("") : ($sOnlyFind)
	$iQuantToMach = ($sOnlyFind = Default) ? ($iQuantity2Match) : (20)
	$bExactFind = ($bExactFindP = Default) ? ($bExactFind) : (False)

	If $vArea2SearchOri = Default Then
		$sArea2Search = "FV"
	ElseIf (IsArray($vArea2SearchOri)) Then
		$sArea2Search = (GetDiamondFromArray($vArea2SearchOri))
	Else
		Switch UBound(StringSplit($vArea2SearchOri, ",", $STR_NOCOUNT))
			Case 4
				$sArea2Search = GetDiamondFromRect($vArea2SearchOri)
			Case 0, 5
				$sArea2Search = $vArea2SearchOri
		EndSwitch
	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sDirectory, $sDrive, $sDir, $sFileName, $sExtension)
	If Not StringIsSpace($sExtension) Then
		Local $sStrS = StringSplit($sFileName, "_", $STR_NOCOUNT)
		Local $pa = decodeSingleCoord(findImage($sStrS[0], $sDirectory, $sArea2Search, 1, True))
		If (IsArray($pa) And UBound($pa, 1) = 2) And (UBound($sStrS) > 1) Then 
			Local $aFake[1][4] = [[$sStrS[0], $pa[0], $pa[1], $sStrS[1]]]
			$g_aImageSearchXML = $aFake
			Return $aFake
		EndIf
		Return (-1)
	EndIf
	
	Local $aResult = findMultiple($sDirectory, $sArea2Search, $sArea2Search, $iLevel, $iMaxLevel, $iQuantToMach, "objectname,objectlevel,objectpoints", $bCapture)
	If Not IsArray($aResult) Then Return -1

	Local $iCount = 0

	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $aAllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To UBound($aResult) - 1
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) - 1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)

			If $sIsOnlyFind <> "" Then
				If $bExactFind Then
					If StringCompare($sIsOnlyFind, $aArrays[0]) <> 0 Then ContinueLoop
				ElseIf Not $bExactFind Then
					If StringInStr($aArrays[0], $sIsOnlyFind) = 0 Then ContinueLoop
				EndIf
			EndIf
			
			; Inspired in Chilly-chill
			Local $aTmpResults[1][4] = [[$aArrays[0], Int($aCommaCoord[0]), Int($aCommaCoord[1]), Int($aArrays[1])]]
			If $iCount >= $iQuantity2Match And Not $iQuantity2Match = 0 Then ExitLoop 2
			_ArrayAdd($aAllResults, $aTmpResults)
			$iCount += 1
		Next
	Next
	
	; Sort by X axis
	_ArraySort($aAllResults, 0, 0, 0, 1)
	If $iDistance2check > 0 And UBound($aAllResults) > 1 Then
		; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
		Local $D2Check = $iDistance2check

		; check if is a double Detection, near in 10px
		Local $Dime = 0
		For $i = 0 To UBound($aAllResults) - 1
			If $i > UBound($aAllResults) - 1 Then ExitLoop
			Local $LastCoordinate[4] = [$aAllResults[$i][0], $aAllResults[$i][1], $aAllResults[$i][2], $aAllResults[$i][3]]
			SetDebugLog("Coordinate to Check: " & _ArrayToString($LastCoordinate))
			If UBound($aAllResults) > 1 Then
				For $j = 0 To UBound($aAllResults) - 1
					If $j > UBound($aAllResults) - 1 Then ExitLoop
					Local $SingleCoordinate[4] = [$aAllResults[$j][0], $aAllResults[$j][1], $aAllResults[$j][2], $aAllResults[$j][3]]
					If $LastCoordinate[1] <> $SingleCoordinate[1] Or $LastCoordinate[2] <> $SingleCoordinate[2] Then
						If Abs($SingleCoordinate[1] - $LastCoordinate[1]) <= $D2Check Or _
								Abs($SingleCoordinate[2] - $LastCoordinate[2]) <= $D2Check Then
							_ArrayDelete($aAllResults, $j)
						EndIf
					Else
						If $LastCoordinate[1] = $SingleCoordinate[1] And $LastCoordinate[2] = $SingleCoordinate[2] And not ($LastCoordinate[3] <> $SingleCoordinate[3] Or $LastCoordinate[0] <> $SingleCoordinate[0]) Then
							_ArrayDelete($aAllResults, $j)
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf
	
	$g_aImageSearchXML = (UBound($aAllResults) > 0) ? ($aAllResults) : (-1)
	Return $g_aImageSearchXML
EndFunc   ;==>findMultipleQuick

Func ClickFindMatch()
	Local $iLoop = 0, $bFail = True
	Do
		$iLoop += 1
		
		If _WaitForCheckXML(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Button\", "559, 315, 816, 541", Default, Default, Default, "FindMatch") Then
			SetDebugLog("ClickFindMatch | Clicking in find match.")
			PureClick(Random($g_aImageSearchXML[0][1] + 28, $g_aImageSearchXML[0][1] + 180, 1), Random($g_aImageSearchXML[0][2] + 10, $g_aImageSearchXML[0][2] + 94, 1), 1, 0, "#0150") ; Click Find a Match Button
			$bFail = False
		EndIf
		
		Select
			Case isGemOpen(True, True)
				Return (isGemOpen(True, True)) ? (False) : (True)
			Case Not _WaitForCheckXMLGone(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Obstacle\", "440, 106, 469, 123", Default, 2500, 100, "Mostaza")
				SetDebugLog("ClickFindMatch | ClickFindMatch fail.", $COLOR_ERROR)
				Click(Random(300, 740, 1), Random(67, 179, 1))
				$bFail = True
				ContinueLoop
			Case IsMainPage(1)
				Setlog("ClickFindMatch | Main located fail.", $COLOR_ERROR)
				$bFail = True
				ExitLoop
		EndSelect
		
		If ($bFail = False) Then Return True
		If _Sleep(500) Then Return
	
	Until (IsArray(findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch", 1, "559, 315, 816, 541", "FindMatch")) And not $bFail) Or ($iLoop > 10)

	If ($bFail = False) And not ($iLoop > 9) Then 
		SetDebugLog("ClickFindMatch | OK in loop : " & $iLoop)
		Return True
	Else
		SetDebugLog("ClickFindMatch | Fail in loop : " & $iLoop)
		AndroidPageError("PrepareSearch")
		If checkMainScreen() = False Then
			$g_bRestart = True
			$g_bIsClientSyncError = False
		EndIf
	EndIf
	
	Return False
EndFunc   ;==>ClickFindMatch

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
	Local $aSpecialAway = [Random(224, 256, 1), Random(9, 15, 1)]
	If $g_bDebugClick Or TestCapture() Then SetLog("Click SpecialAway " & $aSpecialAway[0] & ", " & $aSpecialAway[1], $COLOR_ACTION, "Verdana", "7.5", 0)
	Click($aSpecialAway[0], $aSpecialAway[1])
EndFunc   ;==>SpecialAway

Func UnderstandChatRules()
	;LEFT - 68, 447, 92, 479
	;RIGHT - 223, 448, 249, 479
	;DDF685
	Local $aClanBadgeNoClan[4] = [151, 307, 0xF05538, 20] ; OK - Orange Tile of Clan Logo on Chat Tab if you are not in a Clan
	Local $bReturn = False


	; check for "I Understand" button
	Local $aCoord = decodeSingleCoord(findImage("I Understand", $g_sImgChatIUnterstand, GetDiamondFromRect("50,400,280,550")))

	If UBound($aCoord) > 1 And _Wait4PixelGoneArray($aClanBadgeNoClan) Then
		SetLog('Clicking "I Understand" button', $COLOR_ACTION)
		ClickP($aCoord)
		If _Sleep($DELAYDONATECC2) Then Return
		$bReturn = True
	EndIf

	If _Sleep($DELAYDONATECC2) Then Return

	Return $bReturn
EndFunc   ;==>UnderstandChatRules

Func IsToRequestCC($ClickPAtEnd = True, $bSetLog = False, $bNeedCapture = True)
	Local $bNeedRequest = False
	Local $sCCRequestDiamond = GetDiamondFromRect("715, 576, 845, 617") ; Contains iXStart, $iYStart, $iXEnd, $iYEnd
	Local $aCurrentCCRequest = findMultiple($g_sImgArmyRequestCC, $sCCRequestDiamond, $sCCRequestDiamond, 0, 1000, 0, "objectname,objectpoints", $bNeedCapture)

	Local $aTempCCRequestArray, $aCCRequestCoords
	If UBound($aCurrentCCRequest, 1) >= 1 Then
		For $i = 0 To UBound($aCurrentCCRequest, 1) - 1 ; Loop through found
			$aTempCCRequestArray = $aCurrentCCRequest[$i] ; Declare Array to Temp Array
			$aCCRequestCoords = StringSplit($aTempCCRequestArray[1], ",", $STR_NOCOUNT) ; Split the Coordinates where the Button got found into X and Y

			If $g_bDebugSetlog Then
				SetDebugLog($aTempCCRequestArray[0] & " Found on Coord: (" & $aCCRequestCoords[0] & "," & $aCCRequestCoords[1] & ")")
			EndIf

			If $aTempCCRequestArray[0] = "RequestFilled" Then ; Clan Castle Full
				SetLog("Your Clan Castle is already full or you are not in a clan.", $COLOR_SUCCESS)
				$g_bCanRequestCC = False
			ElseIf $aTempCCRequestArray[0] = "Waiting4Request" Then ; Request has already been made
				SetLog("Request has already been made!", $COLOR_INFO)
				$g_bCanRequestCC = False
			ElseIf $aTempCCRequestArray[0] = "CanRequest" Then ; Can make a request
				If Not $g_abRequestType[0] And Not $g_abRequestType[1] And Not $g_abRequestType[2] Then
					SetDebugLog("Request for Specific CC is not enable!", $COLOR_INFO)
					$bNeedRequest = True
				ElseIf Not $ClickPAtEnd Then
					$bNeedRequest = True
				Else
					For $i = 0 To 2
						If Not IsFullClanCastleType($i) Then
							$bNeedRequest = True
							ExitLoop
						EndIf
					Next
				EndIf
			Else ; No button request found
				SetLog("Cannot detect button request troops.")
			EndIf
		Next
	EndIf
	Return $bNeedRequest

EndFunc   ;==>IsToRequestCC

; Donation Record TimerDiff
Func TimerRecordDonation($bUpdate = False)
	Local $iDateS = _DateDiff('s', $g_sRestartTimer, _NowCalc())
	Local $iDateH = _DateDiff('h', $g_sRestartTimer, _NowCalc())

	If $g_iCmbRestartEvery <= 0 Then $g_iCmbRestartEvery = 1

	If $iDateS <= 0 Or $iDateH > $g_iCmbRestartEvery Or $bUpdate Then
		$g_sRestartTimer = '1000/01/01 00:00:00'

		$g_sRestartTimer = _DateAdd('h', Ceiling($g_iCmbRestartEvery), _NowCalc())
		$g_iTotalDonateStatsTroops = 0
		$g_iTotalDonateStatsSpells = 0
		$g_iTotalDonateStatsSiegeMachines = 0

		GUICtrlSetData($g_hDayTotalTroops, _NumberFormat($g_iTotalDonateStatsTroops, True))
		GUICtrlSetData($g_hDayTotalSpells, _NumberFormat($g_iTotalDonateStatsSpells, True))
		GUICtrlSetData($g_hDayTotalSieges, _NumberFormat($g_iTotalDonateStatsSiegeMachines, True))

	EndIf
EndFunc   ;==>TimerRecordDonation

Func _GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle = -1, $vExStyle = -1)
	Local $hReturn = GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle, $vExStyle)
	GUICtrlSetBkColor($hReturn, 0xD1DFE7)
	Return $hReturn
EndFunc   ;==>_GUICtrlCreateInput

; Disastrous function, but it works for text.
Func _makerequestCustom($aButtonPosition = -1)
	;click button request troops
	
	If IsArray($aButtonPosition) Then ClickP($aButtonPosition, 1, 0, "0336") ;Select text for request

	Local $iMinXSort = 0, $iMinYSort = 0, $iMaxXSort = 0, $iMaxYSort = 0
	Local $aFindPencil, $aClickSend
	Local $aFixedMatrixWhite[4]
	Local $aFixedMatrixPencil[4]
	Local $aFixedMatrixSend[4]

	For $i = 0 To 5
		$aFindPencil = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Request\ReqSpec", 1, "0,207,656,568", Default, "edit", False, 25)
		If IsArray($aFindPencil) Then ExitLoop
		If _Sleep(Random(200, 400, 1)) Then Return
	Next
	
	If Not IsArray($aFindPencil) Then
		Setlog("SearchPixelDonate fail 0x1.", $COLOR_ERROR)
		CheckMainScreen(False) ;emergency exit
		Return False
	EndIf
	
	Local $ix = $aFindPencil[0][1], $iy = $aFindPencil[0][2]
	Local $aClickText[2] = [Random($ix - 320, $ix + 13,1), Random($iy + 108, $iy + 177, 1)]
	
	SetDebuglog("SearchPixelDonate FindWhite " & _ArrayToString($aClickText))
	SetDebuglog("SearchPixelDonate X, Y: " & $ix & "," & $iy)

	Local $aTmp[4] = [440, Int($iy + 190), 470, Int($iy + 220)] 
	$aClickSend = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Request\ReqSpec", 1, $aTmp, Default, "ReqSpec", False, 25)
	
	If Not IsArray($aClickSend) Then
		Setlog("SearchPixelDonate fail 0x2.", $COLOR_ERROR)
		CheckMainScreen(False) ;emergency exit
		Return False
	EndIf
	
	SetDebuglog("SearchPixelDonate FixedMatrixSend " & _ArrayToString($aClickSend))
	
	If $g_sRequestTroopsText <> "" Then
		If Not $g_bChkBackgroundMode And Not $g_bNoFocusTampering Then ControlFocus($g_hAndroidWindow, "", "")
		; fix for Android send text bug sending symbols like ``"
		AndroidSendText($g_sRequestTroopsText, True)
		Click($aClickText[0], $aClickText[1], 1, 0, "#0254") ;Select text for request
		If _Sleep($DELAYMAKEREQUEST2) Then Return
		If SendText($g_sRequestTroopsText) = 0 Then
			SetLog(" Request text entry failed, try again", $COLOR_ERROR)
			Return
		EndIf
	EndIf
	
	If _Sleep($DELAYMAKEREQUEST2) Then Return ; wait time for text request to complete
	
	If $g_bChkBackgroundMode = False And $g_bNoFocusTampering = False Then ControlFocus($g_hAndroidWindow, "", "") ; make sure Android has window focus
	Click($aClickSend[0][1], $aClickSend[0][2], 1, 100, "#0256") ; click send button
	$g_bCanRequestCC = False

EndFunc   ;==>_makerequestCustom

#Region - Custom Yard - Team AIO Mod++
Func _CleanYard($aIsBB = Default, $bTest = False)
	
	If $aIsBB Then
		; Check if is in Builder Base
		If Not IsMainPageBuilderBase() Then Return
	
		; Get Builders available
		If Not getBuilderCount(True, True) Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
	
		If $g_iFreeBuilderCountBB = 0 Then Return
	Else
		; Check if is in Village
		If Not IsMainPage() Then Return
	
		; Get Builders available
		If Not getBuilderCount() Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
	
		If $g_iFreeBuilderCount = 0 Then Return
	EndIf
	
	If (Number($g_aiCurrentLootBB[$eLootElixirBB]) > 50000 And $aIsBB) Or (Number($g_aiCurrentLoot[$eLootElixir]) > 50000 And not $aIsBB) Or $bTest Then
		Local $aResult, $aRTmp1, $aRTmp2
		
		If $aIsBB Then
			$aResult = findMultipleQuick($g_sImgCleanBBYard, 0, "0,0,860,732", Default, Default, Default, 1)
		Else
			$aRTmp1 = findMultipleQuick($g_sImgCleanYardSnow, 0, "0,0,860,732", Default, Default, Default, 1)
			$aRTmp2 = findMultipleQuick($g_sImgCleanYard, 0, "0,0,860,732", Default, Default, Default, 1)

			If IsArray($aRTmp1) Then 
				$aResult = $aRTmp1
				If IsArray($aRTmp2) Then _ArrayAdd($aResult, $aRTmp2)
			ElseIf IsArray($aRTmp2) Then
				$aResult = $aRTmp2
			EndIf
		EndIf
		
		;_ArrayDisplay($aResult)
		
		If Not IsArray($aResult) Then 
			Return False
		Else
			_ArrayShuffle($aResult)
		EndiF
		
		SetLog("- Removing some obstacles - Custom by AIO Mod ++.", $COLOR_ACTION)
		
		For $i = 0 To UBound($aResult) - 1
			If $g_bEdgeObstacle Then
				If (Not isInDiamond($aResult[$i][1], $aResult[$i][2], 83, 156, 780, 680) and $aIsBB) Or (Not isInDiamond($aResult[$i][1], $aResult[$i][2], 43, 50, 818, 634) And not $aIsBB) Then ContinueLoop
			Else
				If (Not isInDiamond($aResult[$i][1], $aResult[$i][2], 83, 156, 780, 680) and $aIsBB) Or (Not isInDiamond($aResult[$i][1], $aResult[$i][2]) And not $aIsBB) Then ContinueLoop
			EndIf
			
			If $g_bDebugSetlog Then SetDebugLog($aResult[$i][0] & " found (" & $aResult[$i][1] & "," & $aResult[$i][2] & ")", $COLOR_SUCCESS)
			If _Sleep($DELAYRESPOND) Then Return
			For $iSeconds = 0 To Random(50, 120, 1)
			getBuilderCount(True, (($aIsBB) ? (True) : (False)))
			If ($g_iFreeBuilderCountBB > 0 And $aIsBB) Or ($g_iFreeBuilderCount > 0 And not $aIsBB) Then
				If getBuilderCount(True, (($aIsBB) ? (True) : (False))) = False Then Return     ; This check IsMainPageX
				If ($g_iFreeBuilderCountBB > 0 And $aIsBB) Or ($g_iFreeBuilderCount > 0 And not $aIsBB) Then
					PureClick($aResult[$i][1], $aResult[$i][2], 1, 0, "#0430")
					If _Sleep(Random(500, 700, 1)) Then Return
					If ClickRemoveObstacle() Then
						ContinueLoop 2
					Else
						SetDebugLog(" - CleanYardAIO | 0x1 error.")
						ExitLoop
					EndIf
				EndIf
				Else
				If RandomSleep(3000) Then Return
			EndIf
			Next
			SetLog("- Removing some obstacles, wait. - Custom by AIO Mod ++.", $COLOR_INFO)
		Next
	EndIf
	UpdateStats()

EndFunc   ;==>CleanBBYard
#EndRegion - Custom Yard - Team AIO Mod++
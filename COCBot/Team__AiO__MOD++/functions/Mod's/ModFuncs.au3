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

#cs
Func ClickFindMatch()
	Local $iLoop = 0, $bFail = True
	Do
		$iLoop += 1
		
		If _WaitForCheckImg(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Button\", "559, 315, 816, 541", "FindMatch") Then
			If $g_bDebugSetlog Then SetDebugLog("ClickFindMatch | Clicking in find match.")
			PureClick(Random($g_aImageSearchXML[0][1] + 28, $g_aImageSearchXML[0][1] + 180, 1), Random($g_aImageSearchXML[0][2] + 10, $g_aImageSearchXML[0][2] + 94, 1), 1, 0, "#0150") ; Click Find a Match Button
			$bFail = False
		EndIf
		
		Select
			Case isGemOpen(True, True)
				Return (isGemOpen(True, True)) ? (False) : (True)
			Case Not _WaitForCheckImgGone(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Obstacle\", "440, 106, 469, 123", "Mostaza")
				If $g_bDebugSetlog Then SetDebugLog("ClickFindMatch | ClickFindMatch fail.", $COLOR_ERROR)
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
		
	Until (IsArray(findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch", 1, "559, 315, 816, 541", "FindMatch")) And Not $bFail) Or ($iLoop > 10)

	If ($bFail = False) And Not ($iLoop > 9) Then
		If $g_bDebugSetlog Then SetDebugLog("ClickFindMatch | OK in loop : " & $iLoop)
		Return True
	Else
		If $g_bDebugSetlog Then SetDebugLog("ClickFindMatch | Fail in loop : " & $iLoop)
		AndroidPageError("PrepareSearch")
		If checkMainScreen() = False Then
			$g_bRestart = True
			$g_bIsClientSyncError = False
		EndIf
	EndIf
	
	Return False
EndFunc   ;==>ClickFindMatch
#ce

Func SearchNoLeague()
	Local $offColors[2][3] = [[0xFBFDFB, 28, 0], [0x626462, 15, 5]]
	Local $vNoLeaguePixel = _MultiPixelSearch(5, 10, 50, 50, 1, 1, Hex(0xFFFFFF, 6), $offColors, 15)
	
	If $g_bDebugSetlog Then SetDebugLog("NoLeague pixel chk-#1: " & _GetPixelColor(13, 24, True) & _
			", #2: " & _GetPixelColor(13 + 28, 24, True) & _
			", #3: " & _GetPixelColor(13 + 15, 24 + 5, True), $COLOR_DEBUG)
	
	If IsArray($vNoLeaguePixel) Then Return True
	Return False
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
				If $g_bDebugSetlog Then SetDebugLog($aTempCCRequestArray[0] & " Found on Coord: (" & $aCCRequestCoords[0] & "," & $aCCRequestCoords[1] & ")")
			EndIf

			If $aTempCCRequestArray[0] = "RequestFilled" Then ; Clan Castle Full
				SetLog("Your Clan Castle is already full or you are not in a clan.", $COLOR_SUCCESS)
				$g_bCanRequestCC = False
			ElseIf $aTempCCRequestArray[0] = "Waiting4Request" Then ; Request has already been made
				SetLog("Request has already been made!", $COLOR_INFO)
				$g_bCanRequestCC = False
			ElseIf $aTempCCRequestArray[0] = "CanRequest" Then ; Can make a request
				If Not $g_abRequestType[0] And Not $g_abRequestType[1] And Not $g_abRequestType[2] Then
					If $g_bDebugSetlog Then SetDebugLog("Request for Specific CC is not enable!", $COLOR_INFO)
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
	Local $aClickText[2] = [Random($ix - 320, $ix + 13, 1), Random($iy + 108, $iy + 177, 1)]
	
	If $g_bDebugSetlog Then SetDebugLog("SearchPixelDonate FindWhite " & _ArrayToString($aClickText))
	If $g_bDebugSetlog Then SetDebugLog("SearchPixelDonate X, Y: " & $ix & "," & $iy)

	Local $aTmp[4] = [440, Int($iy + 190), 470, Int($iy + 220)]
	$aClickSend = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Request\ReqSpec", 1, $aTmp, Default, "ReqSpec", False, 25)
	
	If Not IsArray($aClickSend) Then
		Setlog("SearchPixelDonate fail 0x2.", $COLOR_ERROR)
		CheckMainScreen(False) ;emergency exit
		Return False
	EndIf
	
	If $g_bDebugSetlog Then SetDebugLog("SearchPixelDonate FixedMatrixSend " & _ArrayToString($aClickSend))
	
	; X[$g_sProfileCurrentName|$g_sRequestTroopsText]
	Static $aRequestTroopsText[0][2]
	
	If Not StringIsSpace($g_sRequestTroopsText) Then
		
		Local $iUbi = __ArraySearch($aRequestTroopsText, $g_sRequestTroopsText)
		Local $bCanReq = False
		If $iUbi = -1 Then
			$bCanReq = True
			Local $aMatrixText[1][2] = [[$g_sProfileCurrentName, $g_sRequestTroopsText]]
			_ArrayAdd($aRequestTroopsText, $aMatrixText)
		ElseIf $aRequestTroopsText[$iUbi][1] <> $g_sRequestTroopsText Then
			$bCanReq = True
			$aRequestTroopsText[$iUbi][1] = $g_sRequestTroopsText
		EndIf

		If $bCanReq Then
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
		
	EndIf
	
	If _Sleep($DELAYMAKEREQUEST2) Then Return ; wait time for text request to complete
	
	If $g_bChkBackgroundMode = False And $g_bNoFocusTampering = False Then ControlFocus($g_hAndroidWindow, "", "") ; make sure Android has window focus
	Click($aClickSend[0][1], $aClickSend[0][2], 1, 100, "#0256") ; click send button
	$g_bCanRequestCC = False

EndFunc   ;==>_makerequestCustom

#Region - Custom Yard - Team AIO Mod++
Func _CleanYard($bIsBB = Default, $bTest = False)
	If $bIsBB = Default Then $bIsBB = $g_bStayOnBuilderBase
	
	ZoomOut()
	
	If $bIsBB Then
		If Not $g_bChkCleanBBYard And Not $bTest Then Return
		
		; Check if is in Builder Base
		If Not IsMainPageBuilderBase() Then Return
		
		; Get Builders available
		If Not getBuilderCount(True, True) Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
		
		If $g_iFreeBuilderCountBB = 0 Then Return
	Else
		If Not $g_bChkCleanYard And Not $bTest Then Return

		; Check if is in Village
		If Not IsMainPage() Then Return
		
		; Get Builders available
		If Not getBuilderCount() Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
		
		If $g_iFreeBuilderCount = 0 Then Return
	EndIf
	
	If (Number($g_aiCurrentLootBB[$eLootElixirBB]) > 50000 And $bIsBB) Or (Number($g_aiCurrentLoot[$eLootElixir]) > 50000 And Not $bIsBB) Or $bTest Then
		Local $aResult, $aRTmp1, $aRTmp2
		
		If $bIsBB Then
			$aResult = findMultipleQuick($g_sImgCleanBBYard, 0, "83, 136, 844, 694", Default, Default, Default, 10)
		Else
			$aRTmp1 = findMultipleQuick($g_sImgCleanYardSnow, 0, "15, 31, 859, 648", Default, Default, Default, 10)
			$aRTmp2 = findMultipleQuick($g_sImgCleanYard, 0, "15, 31, 859, 648", Default, Default, Default, 10)

			If IsArray($aRTmp1) Then
				$aResult = $aRTmp1
				If IsArray($aRTmp2) Then _ArrayAdd($aResult, $aRTmp2)
			ElseIf IsArray($aRTmp2) Then
				$aResult = $aRTmp2
			EndIf
		EndIf

		If Not IsArray($aResult) Then
			Return False
		Else
			_ArrayShuffle($aResult)
		EndIf
		
		SetLog("- Removing some obstacles - Custom by AIO Mod ++.", $COLOR_ACTION)
		
		Local $iError = 0, $iMaxLoop = 0, $aDigits = ($bIsBB) ? ($aBuildersDigitsBuilderBase) : ($aBuildersDigits)
		Local $aSearch[4] = [0, 0, 0, 0] ; Edge - NV.
		ReturnPreVD($aSearch, $bIsBB, $g_bEdgeObstacle)
		For $i = 0 To UBound($aResult) - 1
			$iMaxLoop = 0
			If Not isInDiamond($aResult[$i][1], $aResult[$i][2], $aSearch[0], $aSearch[1], $aSearch[2], $aSearch[3]) Then ContinueLoop
			If $g_bDebugSetlog Then SetDebugLog("_CleanYard found : - Is BB? " & $bIsBB & "- Is Edge ? " & $g_bEdgeObstacle & " - Coordinates X: " & $aResult[$i][1] & " | Coordinates X: " & $aResult[$i][2], $COLOR_SUCCESS)
			
			SetLog("- Removing some obstacles, wait. - Custom by AIO Mod ++.", $COLOR_INFO)
			
			Do
				$iMaxLoop += 1
				If RandomSleep(1000) Then Return
				Local $aCondition = StringSplit(getBuilders($aDigits[0], $aDigits[1]), "#", $STR_NOCOUNT)
				If ($iMaxLoop > 50) Then Return
			Until Number($aCondition[0]) > 0
			
			If Not ($i = 0) And ($aResult[$i][1] > 428) Then ClickP($aAway)
			PureClick($aResult[$i][1], $aResult[$i][2], 1, 0, "#0430")
			If RandomSleep(500) Then Return
			If Not ClickRemoveObstacle() Then
				If isGemOpen(True) = True Then Return False
				Local $aiOkayButton = findButton("Okay", Default, 1, True)
				If IsArray($aiOkayButton) And UBound($aiOkayButton, 1) = 2 Then ClickP($aAway)
				If $g_bDebugSetlog Then SetDebugLog(" - CleanYardAIO | 0x1 error | Try x : " & $iError)
				$iError += 1
				If RandomSleep(250) Then Return
				If ($iError > 5) Then ContinueLoop
			EndIf
			
		Next
		
	EndIf
	UpdateStats()

EndFunc   ;==>_CleanYard
#EndRegion - Custom Yard - Team AIO Mod++

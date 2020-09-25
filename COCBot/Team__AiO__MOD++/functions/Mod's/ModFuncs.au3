; #FUNCTION# ====================================================================================================================
; Name ..........: ModFuncs.au3
; Description ...: Avoid loss of functions during updates.
; Author ........: Boludoz (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Michael Michta <MetalGX91 at GMail dot com>
; Modified.......: gcriaco <gcriaco at gmail dot com>; Ultima - 2D arrays supported, directional search, code cleanup, optimization; Melba23 - added support for empty arrays and row search; BrunoJ - Added compare option 3 to use a regex pattern
; Modified.......: Boldina !
; ===============================================================================================================================
Func __ArraySearch(Const ByRef $aArray, $vValue, $iStart = 0, $iEnd = 0, $iCase = 0, $iCompare = 0, $iForward = 1, $iSubItem = -1, $bRow = False)
	If Not IsArray($aArray) Then Return -1
	Select
		Case ($iCompare = 0)
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, 2, $iForward, $iSubItem, $bRow)
		Case ($iCompare = 2)
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, 0, $iForward, $iSubItem, $bRow)
		Case Else
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, $iCompare, $iForward, $iSubItem, $bRow)
	EndSelect
EndFunc   ;==>__ArraySearch

; Check if the filepath is a directory/folder. Does not validate if the directory/folder exists.
Func IsDir($sFilePath)
    Return StringInStr(FileGetAttrib($sFilePath), "D") > 0
EndFunc   ;==>IsDir

Func ClickFindMatch()
	If _WaitForCheckImg(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Button\", "559, 315, 816, 541", "FindMatch") Then ; findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\Button\", 50, "559, 315, 816, 541", True, "FindMatch")
		If $g_bDebugSetlog Then SetDebugLog("ClickFindMatch | Clicking in find match.")
		PureClick(Random($g_aImageSearchXML[0][1] + 28, $g_aImageSearchXML[0][1] + 180, 1), Random($g_aImageSearchXML[0][2] + 10, $g_aImageSearchXML[0][2] + 94, 1), 1, 0, "#0150") ; Click Find a Match Button
		Return True
	EndIf
	Return False
EndFunc   ;==>ClickFindMatch

Func SearchNoLeague($bForceCapture = False)
	Local $sImg = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ClickFindMatch\NoLeague\"
	Return IsArray(findMultipleQuick($sImg, Default, "6, 14, 45, 28", $bForceCapture))
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

Func _makerequestCustom($aRequestButtonPos)
	Local $sSendButtonArea = GetDiamondFromRect("220,150,650,650")

	ClickP($aRequestButtonPos, 1, 0, "0336") ;click button request troops

	If Not IsWindowOpen($g_sImgSendRequestButton, 20, 100, $sSendButtonArea) Then
		SetLog("Request has already been made, or request window not available", $COLOR_ERROR)
		ClickAway()
		If _Sleep($DELAYMAKEREQUEST2) Then Return
	Else
		#Region - Type once - Team AIO Mod++
		If Not StringIsSpace($g_sRequestTroopsText) Then
			
			; 	X[$g_sProfileCurrentName|$g_sRequestTroopsText]
			Local $bCanReq = True, $bAddNew = True
			
			If $g_bRequestOneTimeEnable Then
				For $i = 0 To UBound($g_aRequestTroopsTextOT) -1
					If $g_aRequestTroopsTextOT[$i][0] = $g_sProfileCurrentName Then
						$bAddNew = False
						
						If $g_aRequestTroopsTextOT[$i][1] = $g_sRequestTroopsText Then
							$bCanReq = False
						ElseIf $g_aRequestTroopsTextOT[$i][1] <> $g_sRequestTroopsText Then
							$g_aRequestTroopsTextOT[$i][1] = $g_sRequestTroopsText
						EndIf
						
						ExitLoop
					EndIf
				Next
				
				If $bAddNew = True Then
					Local $aMatrixText[1][2] = [[$g_sProfileCurrentName, $g_sRequestTroopsText]]
					_ArrayAdd($g_aRequestTroopsTextOT, $aMatrixText)
				EndIf
			EndIf
			
			If $bCanReq = True Then
				If Not $g_bChkBackgroundMode And Not $g_bNoFocusTampering Then ControlFocus($g_hAndroidWindow, "", "")
				; fix for Android send text bug sending symbols like ``"
				AndroidSendText($g_sRequestTroopsText, True)
				Click(Int($g_avWindowCoordinates[0]), Int($g_avWindowCoordinates[1] - 75), 1, 0, "#0254")
				If _Sleep($DELAYMAKEREQUEST2) Then Return
				If SendText($g_sRequestTroopsText) = 0 Then
					SetLog(" Request text entry failed, try again", $COLOR_ERROR)
					Return
				EndIf
			EndIf
		EndIf
		#EndRegion - Type once - Team AIO Mod++
		If _Sleep($DELAYMAKEREQUEST2) Then Return ; wait time for text request to complete

		If Not IsWindowOpen($g_sImgSendRequestButton, 20, 100, $sSendButtonArea) Then
			If $g_bDebugSetlog Then SetDebugLog("Send request button not found", $COLOR_DEBUG)
			CheckMainScreen(False) ;emergency exit
		EndIf

		If Not $g_bChkBackgroundMode And Not $g_bNoFocusTampering Then ControlFocus($g_hAndroidWindow, "", "") ; make sure Android has window focus
		ClickP($g_avWindowCoordinates, 1, 100, "#0256")
		$g_bCanRequestCC = False
	EndIf

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
			$aResult = findMultipleQuick($g_sImgCleanBBYard, 0, "FV", Default, Default, Default, 10)
		Else
			$aRTmp1 = findMultipleQuick($g_sImgCleanYardSnow, 0, "FV", Default, Default, Default, 10)
			$aRTmp2 = findMultipleQuick($g_sImgCleanYard, 0, "FV", Default, Default, Default, 10)

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
		
		Local $iError = 0, $iMaxLoop = 0, $aDigits = ($bIsBB = True) ? ($aBuildersDigitsBuilderBase) : ($aBuildersDigits)
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

Global $g_oTxtBBAtkLogInitText = ObjCreate("Scripting.Dictionary")

Func BBAtkLogHead()
	SetBBAtkLog(_PadStringCenter(" " & GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_01", "ATTACK LOG") & " ", 43, "="), "", $COLOR_BLACK, "MS Shell Dlg", 8.5)
	SetBBAtkLog(GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_02", '|     --------- VICTORY BONUS ----------   |'), "")
	SetBBAtkLog(GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_03", '|AC|TIME.|TROP.|   GOLD| ELIXIR|GTR|S|  %|S|'), "")
EndFunc   ;==>BBAtkLogHead

Func SetBBAtkLog($String1, $String2 = "", $Color = $COLOR_BLACK, $Font = "Lucida Console", $FontSize = 7.5) ;Sets the text for the log
	If $g_hBBAttackLogFile = 0 Then CreateBBAttackLogFile()
	_FileWriteLog($g_hBBAttackLogFile, $String1 & $String2)
	Local $a[6] = [$String1 & @CRLF, $Color, $Font, $FontSize, 0, 0]
	$g_oTxtBBAtkLogInitText($g_oTxtBBAtkLogInitText.Count + 1) = $a
EndFunc   ;==>SetBBAtkLog

Func CreateBBAttackLogFile()
	If $g_hBBAttackLogFile <> 0 Then
		FileClose($g_hBBAttackLogFile)
		$g_hBBAttackLogFile = 0
	EndIf

	Local $sBBAttackLogFName = "BBAttackLog" & "-" & @YEAR & "-" & @MON & ".log"
	Local $sBBAttackLogPath = $g_sProfileLogsPath & $sBBAttackLogFName
	$g_hBBAttackLogFile = FileOpen($sBBAttackLogPath, $FO_APPEND)
	If $g_bDebugSetlog Then SetDebugLog("Created BB attack log file: " & $sBBAttackLogPath)
EndFunc   ;==>CreateBBAttackLogFile

Func CheckPostponedLog($bNow = False)
	;If $g_bDebugSetlog Then SetDebugLog("CheckPostponedLog: Entered, $bNow=" & $bNow & ", count=" & $g_oTxtLogInitText.Count & ", $g_hTxtLog=" & $g_hTxtLog & ", $g_iGuiMode=" & $g_iGuiMode)
	Local $iLogs = 0
	If $g_bCriticalMessageProcessing Or ($bNow = False And __TimerDiff($g_hTxtLogTimer) < $g_iTxtLogTimerTimeout) Then Return 0

	If $g_oTxtLogInitText.Count > 0 And ($g_iGuiMode <> 1 Or $g_hTxtLog) Then
		If $g_hTxtLog And UBound($g_aLastStatusBar) > 0 And BitAND(WinGetState($g_hGUI_LOG), 2) = 0 Then
			; Update StatusBar at least
			UpdateStatusBar($g_aLastStatusBar[0])
			$g_aLastStatusBar = 0
		Else
			$iLogs += FlushGuiLog($g_hTxtLog, $g_oTxtLogInitText, True, "txtLog")
		EndIf
	EndIf

	If $g_oTxtAtkLogInitText.Count > 0 And ($g_iGuiMode <> 1 Or ($g_hTxtAtkLog And BitAND(WinGetState($g_hGUI_LOG), 2))) Then
		$iLogs += FlushGuiLog($g_hTxtAtkLog, $g_oTxtAtkLogInitText, False, "txtAtkLog")
	EndIf

	If $g_oTxtBBAtkLogInitText.Count > 0 And ($g_iGuiMode <> 1 Or ($g_hTxtBBAtkLog And BitAND(WinGetState($g_hGUI_LOG_BB), 2))) Then
		$iLogs += FlushGuiLog($g_hTxtBBAtkLog, $g_oTxtBBAtkLogInitText, False, "txtBBAtkLog")
	EndIf

	If $g_oTxtSALogInitText.Count > 0 And ($g_iGuiMode <> 1 Or ($g_hTxtSALog And BitAND(WinGetState($g_hGUI_LOG_SA), 2))) Then
		$iLogs += FlushGuiLog($g_hTxtSALog, $g_oTxtSALogInitText, False, "txtSALog")
	EndIf

	$g_hTxtLogTimer = __TimerInit()
	Return $iLogs
EndFunc   ;==>CheckPostponedLog

Func _DebugFailedImageDetection($Text)
	If $g_bDebugImageSave Or $g_bDebugSetlog Then
		_CaptureRegion2()
		Local $sSubDir = $g_sProfileTempDebugPath & "NewImageDetectionFails"
		DirCreate($sSubDir)
		Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY
		Local $sTime = @HOUR & "." & @MIN & "." & @SEC
		Local $sDebugImageName = String($sDate & "_" & $sTime & "__" & $Text & "_.png")
		Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
		_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $sDebugImageName)
		_GDIPlus_BitmapDispose($hEditedImage)
	EndIf
EndFunc   ;==>_DebugFailedImageDetection

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

Func _GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle = -1, $vExStyle = -1)
	Local $hReturn = GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle, $vExStyle)
	GUICtrlSetBkColor($hReturn, 0xD1DFE7)
	Return $hReturn
EndFunc   ;==>_GUICtrlCreateInput

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

Func StringSplit2D($sMatches = "Hola-2-5-50-50-100-100|Hola-6-200-200-100-100", Const $sDelim_Item = "-", Const $sDelim_Row = "|", $bFixLast = Default)
    Local $iValDim_1, $iValDim_2 = 0, $iColCount

    ; Fix last item or row.
	If $bFixLast <> False Then
		Local $sTrim = StringRight($sMatches, 1)
		If $sTrim = $sDelim_Row Or $sTrim = $sDelim_Item Then $sMatches = StringTrimRight($sMatches, 1)
	EndIf

    Local $aSplit_1 = StringSplit($sMatches, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
    $iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
    Local $aTmp[$iValDim_1][0], $aSplit_2
    For $i = 0 To $iValDim_1 - 1
        $aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
        $iColCount = UBound($aSplit_2)
        If $iColCount > $iValDim_2 Then
            $iValDim_2 = $iColCount
            ReDim $aTmp[$iValDim_1][$iValDim_2]
        EndIf
        For $j = 0 To $iColCount - 1
            $aTmp[$i][$j] = $aSplit_2[$j]
        Next
    Next
    Return $aTmp
EndFunc   ;==>StringSplit2D

Func IsDir($sFolderPath)
	Return (DirGetSize($sFolderPath) > 0 and not @error)
EndFunc   ;==>IsDir

Func IsFile($sFilePath)
	Return (FileGetSize($sFilePath) > 0 and not @error)
EndFunc   ;==>IsDir

;  	ProcessFindBy($g_sAndroidAdbPath), $sPort
;	ProcessFindBy("C:\...\lib\TempAdb\MEmu\", "", true, false)
Func ProcessFindBy($sPath = "", $sCommandline = "", $bAutoItMode = False, $bDontShootYourself = True)
	Local $bGetProcessPath, $bGetProcessCommandLine, $bFail, $aReturn[0]

	; In exe case, like emulator.
	If IsFile($sPath) = True Then
		Local $sFile = StringRegExpReplace($sPath, "^.*\\", "")
		$sFile = StringTrimRight($sFile, StringLen($sFile))
		_ConsoleWrite($sFile)
	EndIf

	$sPath = StringReplace($sPath, "\\", "\")
	If StringIsSpace($sPath) And StringIsSpace($sCommandline) Then Return $aReturn
	Local $sCommandlineParam
	Local $aiProcessList = ProcessList()
	If @error Then Return $aReturn
	For $i = 2 To UBound($aiProcessList) - 1
		$bGetProcessPath = StringInStr(_WinAPI_GetProcessFileName($aiProcessList[$i][1]), $sPath) > 0
		$sCommandlineParam = _WinAPI_GetProcessCommandLine($aiProcessList[$i][1])
		If $bGetProcessPath = False And $bAutoItMode Then $bGetProcessPath = StringInStr($sCommandlineParam, $sPath) > 0
		$bGetProcessCommandLine = StringInStr($sCommandlineParam, $sCommandline) > 0
		Local $iAdd = Int($aiProcessList[$i][1])
		If $iAdd > 0 Then
			Select
				Case $bGetProcessPath And $bGetProcessCommandLine
					If Not StringIsSpace($sPath) And Not StringIsSpace($sCommandline) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
				Case $bGetProcessPath And Not $bGetProcessCommandLine
					If StringIsSpace($sCommandline) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
				Case Not $bGetProcessPath And $bGetProcessCommandLine
					If StringIsSpace($sPath) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
			EndSelect
		EndIf
	Next

	For $i = UBound($aReturn) - 1 To 0 Step -1
		If $aReturn[$i] = @AutoItPID Then
			If $bDontShootYourself = True Then
				_ArrayDelete($aReturn, $i)
			Else
				Local $iNT = $i
				_ArrayAdd($aReturn, $aReturn[$i], $ARRAYFILL_FORCE_INT)
				_ArrayDelete($aReturn, $iNT)
			EndIf
			ExitLoop
		EndIf
	Next

	Return $aReturn
EndFunc   ;==>ProcessFindBy

Func CloseEmulatorForce($bOnlyAdb = False)
	Local $iPids[0], $a[0], $s

	If $bOnlyAdb = False Then
		$s = Execute("Get" & $g_sAndroidEmulator & "Path()")
		If not @error Then
			$a = ProcessFindBy($s, "")
			_ArrayAdd($iPids, $a)
		EndIf
		$a = ProcessFindBy($__VBoxManage_Path, "")
		_ArrayAdd($iPids, $a)
	EndIf

	$a = ProcessFindBy($g_sAndroidAdbPath)
	_ArrayAdd($iPids, $a)

	If UBound($iPids) > 0 and not @error Then
		For $i = 0 To UBound($iPids) -1 ; Custom fix - Team AIO Mod++
			KillProcess($iPids[$i], $g_sAndroidAdbPath)
		Next

		Return True
	EndIf

	Return False
EndFunc   ;==>ProcessFindBy

Func SecureClick($x, $y)
	If $x < 68 And $y > 316 Then ; coordinates where the game will click on the CHAT tab (safe margin)
		If $g_bDebugSetlog Then SetDebugLog("Coordinate Inside Village, but Exclude CHAT")
		Return False
	ElseIf $y < 63 Then ; coordinates where the game will click on the BUILDER button or SHIELD button (safe margin)
		If $g_bDebugSetlog Then SetDebugLog("Coordinate Inside Village, but Exclude BUILDER")
		Return False
	ElseIf $x > 692 And $y > 156 And $y < 210 Then ; coordinates where the game will click on the GEMS button (safe margin)
		If $g_bDebugSetlog Then SetDebugLog("Coordinate Inside Village, but Exclude GEMS")
		Return False
	ElseIf $x > 669 And $y > 489 Then ; coordinates where the game will click on the SHOP button (safe margin)
		If $g_bDebugSetlog Then SetDebugLog("Coordinate Inside Village, but Exclude SHOP")
		Return False
	EndIf
	Return True
EndFunc   ;==>SecureClick

;	https://link.clashofclans.com/en?action=CopyArmy&army=u20x3-3x23
; Func ()
	; 0xFF1919
	; AndroidAdbSendShellCommand("am start -n " & $g_sAndroidGamePackage & "/" & $g_sAndroidGameClass & " -a android.intent.action.VIEW -d ' "& $s & "'", Default)

; EndFunc   ;==>SecureClick

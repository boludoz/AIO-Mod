
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

Func SearchNoLeague($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False
	
	Local $bReturn = False
	Local $offColors[2][3] = [[0x606060, 15, 0], [0x687070, 15, 15]]
	Local $aNoLeaguePixel = _MultiPixelSearch(5, 10, 50, 50, 1, 1, Hex(0xFFFFFF, 6), $offColors, 25)
	
	For $i = 0 To 5
		
		If UBound($aNoLeaguePixel) > 0 And not @error Then
			$bReturn = True
			ExitLoop
		EndIf
		
		If $bCheckOneTime = True Then
			$bReturn = False
			ExitLoop
		EndIf
		
		If _Sleep($DELAYSPECIALCLICK2) Then Return False ; improve pause button response
	Next
	
	If $g_bDebugSetlog Then
		_CaptureRegion()
		SetDebugLog("NoLeague pixel chk-#1: " & _GetPixelColor(13, 24, False) & _
		", #2: " & _GetPixelColor(27, 24, False) & _
		", #3: " & _GetPixelColor(27, 38, False) & _
		", Is no league? " & $bReturn, $COLOR_DEBUG)
	EndIf
	
	Return $bReturn
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

Func _LevDis($s, $t)
	Local $m, $n, $iMaxM, $iMaxN

	$n = StringLen($s)
	$m = StringLen($t)
	$iMaxN = $n + 1
	$iMaxM = $m + 1
	Local $d[$iMaxN + 1][$iMaxM + 1]
	$d[0][0] = 0

	If $n = 0 Then
		Return $m
	ElseIf $m = 0 Then
		Return $n
	EndIf

	For $i = 1 To $n
		$d[$i][0] = $d[$i - 1][0] + 1
	Next
	For $j = 1 To $m
		$d[0][$j] = $d[0][$j - 1] + 1
	Next
	
	Local $jj, $ii, $iCost
	
	For $i = 1 To $n
		For $j = 1 To $m
			$jj = $j - 1
			$ii = $i - 1
			If (StringMid($s, $i, 1) = StringMid($t, $j, 1)) Then
				$iCost = 0
			Else
				$iCost = 1
			EndIf
			$d[$i][$j] = _Min(_Min($d[$ii][$j] + 1, $d[$i][$jj] + 1), $d[$ii][$jj] + $iCost)
		Next
	Next
	Return $d[$n][$m]
EndFunc   ;==>_LevDis

Func _CompareTexts($sText = "", $sText2 = "", $iPerc = 75)
	Local $iC = 0, $iC2 = 0
	Local $iText = StringLen($sText)
	Local $iText2 = StringLen($sText2)	
	Local $iLev = _LevDis($sText, $sText2)

	$iC = ((_Max($iText, $iText2) - $iLev) * 100)
	$iC2 = ((_Max($iText, $iText2)) * 100)
	$iC = (_Min($iC, $iC2) / _Max($iC, $iC2)) * 100
	
	If $iLev = 0 Or ($iC >= $iPerc) Then
		Return True
	EndIf
	
	Return False
EndFunc   ;==>_CompareTexts

;	https://link.clashofclans.com/en?action=CopyArmy&army=u20x3-3x23
; Func ()
	; 0xFF1919
	; AndroidAdbSendShellCommand("am start -n " & $g_sAndroidGamePackage & "/" & $g_sAndroidGameClass & " -a android.intent.action.VIEW -d ' "& $s & "'", Default)

; EndFunc   ;==>


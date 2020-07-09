; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseZoomOutOn
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseZoomOutOnAttack()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (03-2018), contains funcs maked by ProMac (03-2018), Fahid.Mahmood
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_oTxtBBAtkLogInitText = ObjCreate("Scripting.Dictionary")

Func BBAtkLogHead()
	SetBBAtkLog(_PadStringCenter(" " & GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_01", "ATTACK LOG") & " ", 43, "="), "", $COLOR_BLACK, "MS Shell Dlg", 8.5)
	SetBBAtkLog(GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_02", '|     --------- VICTORY BONUS ----------   |'), "")
	SetBBAtkLog(GetTranslatedFileIni("MBR Func_BBAtkLogHead", "BBAtkLogHead_Text_03", '|AC|TIME.|TROP.|   GOLD| ELIXIR|GTR|S|  %|S|'), "")
EndFunc   ;==>BBAtkLogHead

Func SetBBAtkLog($String1, $String2 = "", $Color = $COLOR_BLACK, $Font = "Lucida Console", $FontSize = 7.5) ;Sets the text for the log
	If $g_hBBAttackLogFile = 0 Then CreateBBAttackLogFile()
	;string1 see in video, string1&string2 put in file
	_FileWriteLog($g_hBBAttackLogFile, $String1 & $String2)

	;Local $txtLogMutex = AcquireMutex("txtBBAtkLog")
	Dim $a[6]
	$a[0] = $String1 & @CRLF
	$a[1] = $Color
	$a[2] = $Font
	$a[3] = $FontSize
	$a[4] = 0 ; no status bar update
	$a[5] = 0 ; no time
	$g_oTxtBBAtkLogInitText($g_oTxtBBAtkLogInitText.Count + 1) = $a
	;ReleaseMutex($txtLogMutex)

EndFunc   ;==>SetBBAtkLog

; #FUNCTION# ====================================================================================================================
; Name ..........: CreateBBAttackLogFile
; Description ...:
; Syntax ........: CreateBBAttackLogFile()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func CreateBBAttackLogFile()
	If $g_hBBAttackLogFile <> 0 Then
		FileClose($g_hBBAttackLogFile)
		$g_hBBAttackLogFile = 0
	EndIf

	Local $sBBAttackLogFName = "BBAttackLog" & "-" & @YEAR & "-" & @MON & ".log"
	Local $sBBAttackLogPath = $g_sProfileLogsPath & $sBBAttackLogFName
	$g_hBBAttackLogFile = FileOpen($sBBAttackLogPath, $FO_APPEND)
	SetDebugLog("Created BB attack log file: " & $sBBAttackLogPath)
EndFunc   ;==>CreateBBAttackLogFile

Func CheckPostponedLog($bNow = False)
	;SetDebugLog("CheckPostponedLog: Entered, $bNow=" & $bNow & ", count=" & $g_oTxtLogInitText.Count & ", $g_hTxtLog=" & $g_hTxtLog & ", $g_iGuiMode=" & $g_iGuiMode)
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

Func PointDeployBB($sDirectory = $g_sBundleDeployPointsBB, $Quantity2Match = 0, $iFurMin = 5, $iFurMax = 5, $iCenterX = 450, $iCenterY = 425, $bForceCapture = True, $DebugLog = False) ; Return a large amount of quality deploy point with random and safe further from without theorem.
	
	Local $aTopLeft[0][2], $aTopRight[0][2], $aBottomRight[0][2], $aBottomLeft[0][2]

	Local $aiPostFix[4] = [25, 103, 815, 712]

	If $bForceCapture Then _CaptureRegion2($aiPostFix[0], $aiPostFix[1], $aiPostFix[2], $aiPostFix[3])

	Local $aRes = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", GetDiamondFromArray($aiPostFix), "Int", $Quantity2Match, "str", GetDiamondFromArray($aiPostFix), "Int", 0, "Int", 1000)
	Local $KeyValue = StringSplit($aRes[0], "|", $STR_NOCOUNT)
	Local $Name = ""
	Local $aPositions, $aCoords, $aCord, $level, $aCoordsM
	SetDebugLog("Detected : " & UBound($KeyValue) & " tiles")
	Local $AllFilenamesFound[UBound($KeyValue)][3]
	For $i = 0 To UBound($KeyValue) - 1
		$aPositions = RetrieveImglocProperty($KeyValue[$i], "objectpoints")
		$aCoords = decodeMultipleCoords($aPositions, 0, 0, 0)
		For $iCoords = 0 To UBound($aCoords) - 1
			Local $aCoordsM = $aCoords[$iCoords]
			
			Local $iFur = Random($iFurMin, $iFurMax, 1)
			If Int($aiPostFix[0] + $aCoordsM[0]) < Int($iCenterX) Then
				If Int($aiPostFix[1] + $aCoordsM[1]) < Int($iCenterY) Then
					Local $vResult[1][2] = [[($aiPostFix[0] + $aCoordsM[0]) - $iFur, ($aiPostFix[1] + $aCoordsM[1]) - $iFur]]
					If _ColorCheck(_GetPixelColor($vResult[0][0], $vResult[0][1], True), Hex(0x447063, 6), 0) Then _ArrayAdd($aTopLeft, $vResult)
				Else
					Local $vResult[1][2] = [[($aiPostFix[0] + $aCoordsM[0]) - $iFur, ($aiPostFix[1] + $aCoordsM[1]) + $iFur]]
					If _ColorCheck(_GetPixelColor($vResult[0][0], $vResult[0][1], True), Hex(0x447063, 6), 0) Then _ArrayAdd($aBottomLeft, $vResult)
				EndIf
			Else
				If Int($aiPostFix[1] + $aCoordsM[1]) < Int($iCenterY) Then
					Local $vResult[1][2] = [[($aiPostFix[0] + $aCoordsM[0]) + $iFur, ($aiPostFix[1] + $aCoordsM[1]) - $iFur]]
					If _ColorCheck(_GetPixelColor($vResult[0][0], $vResult[0][1], True), Hex(0x447063, 6), 0) Then _ArrayAdd($aTopRight, $vResult)
				Else
					Local $vResult[1][2] = [[($aiPostFix[0] + $aCoordsM[0]) + $iFur, ($aiPostFix[1] + $aCoordsM[1]) + $iFur]]
					If _ColorCheck(_GetPixelColor($vResult[0][0], $vResult[0][1], True), Hex(0x447063, 6), 0) Then _ArrayAdd($aBottomRight, $vResult)
				EndIf
			EndIf
		Next
	Next
	If _Sleep(200) Then Return
	
	_ArraySort($aTopLeft, 0, 0, 0, 1)

	Local $iLastY = -1, $iMaxX = -1
	Local $aTopLeftNew[0][2]
	
	For $i2 = 0 To UBound($aTopLeft) - 1
		
		If $aTopLeft[$i2][1] <> $iLastY Then
			$iMaxX = $aTopLeft[$i2][0]
			$iLastY = $aTopLeft[$i2][1]
			
			Local $a3 = _ArrayFindAll($aTopLeft, $iLastY, Default, Default, Default, Default, 2)

			If $a3 <> -1 Then
				For $i = UBound($a3) - 1 To 0 Step -1
					If $aTopLeft[Int($a3[0])][0] > $iMaxX Then $iMaxX = $aTopLeft[$i][0]
				Next
			EndIf
			Local $aArray[1][2] = [[$iMaxX, $iLastY]]
			_ArrayAdd($aTopLeftNew, $aArray)
		EndIf
	Next
	
	For $i2 = UBound($aTopLeftNew) - 1 To 0 Step -1
		Local $iTmp[2] = [$aTopLeftNew[$i2][0], $aTopLeftNew[$i2][1]]
		For $i = UBound($aTopLeftNew) - 1 To 0 Step -1
			If $i2 = $i Then ContinueLoop
			Local $x = Abs($aTopLeftNew[$i][0] - $iTmp[0]), $y = Abs($aTopLeftNew[$i][1] - $iTmp[1])
			If ($x < 10 And $y < 10) And Not ($x > 5 And $y > 5) Then ContinueLoop 2
			If $i = 0 Then _ArrayDelete($aTopLeftNew, $i2)
		Next
	Next

	_ArraySort($aTopRight, 0, 0, 0, 1)
	
	Local $iLastY = -1, $iMaxX = -1
	Local $aTopRightNew[0][2]
	
	For $i2 = 0 To UBound($aTopRight) - 1
		
		If $aTopRight[$i2][1] <> $iLastY Then
			$iMaxX = $aTopRight[$i2][0]
			$iLastY = $aTopRight[$i2][1]
			
			Local $a3 = _ArrayFindAll($aTopRight, $iLastY, Default, Default, Default, Default, 2)

			If $a3 <> -1 Then
				For $i = UBound($a3) - 1 To 0 Step -1
					If $aTopRight[Int($a3[0])][0] < $iMaxX Then $iMaxX = $aTopRight[$i][0]
				Next
			EndIf
			Local $aArray[1][2] = [[$iMaxX, $iLastY]]
			_ArrayAdd($aTopRightNew, $aArray)
		EndIf
	Next
	
	For $i2 = UBound($aTopRightNew) - 1 To 0 Step -1
		Local $iTmp[2] = [$aTopRightNew[$i2][0], $aTopRightNew[$i2][1]]
		For $i = UBound($aTopRightNew) - 1 To 0 Step -1
			If $i2 = $i Then ContinueLoop
			Local $x = Abs($aTopRightNew[$i][0] - $iTmp[0]), $y = Abs($aTopRightNew[$i][1] - $iTmp[1])
			If ($x < 10 And $y < 10) And Not ($x > 5 And $y > 5) Then ContinueLoop 2
			If $i = 0 Then _ArrayDelete($aTopRightNew, $i2)
		Next
	Next

	_ArraySort($aBottomRight, 0, 0, 0, 1)
	
	Local $iLastY = -1, $iMaxX = -1
	Local $aBottomRightNew[0][2]
	
	For $i2 = 0 To UBound($aBottomRight) - 1
		
		If $aBottomRight[$i2][1] <> $iLastY Then
			$iMaxX = $aBottomRight[$i2][0]
			$iLastY = $aBottomRight[$i2][1]
			
			Local $a3 = _ArrayFindAll($aBottomRight, $iLastY, Default, Default, Default, Default, 2)

			If $a3 <> -1 Then
				For $i = UBound($a3) - 1 To 0 Step -1
					If $aBottomRight[Int($a3[0])][0] < $iMaxX Then $iMaxX = $aBottomRight[$i][0]
				Next
			EndIf
			Local $aArray[1][2] = [[$iMaxX, $iLastY]]
			_ArrayAdd($aBottomRightNew, $aArray)
		EndIf
	Next
	
	For $i2 = UBound($aBottomRightNew) - 1 To 0 Step -1
		Local $iTmp[2] = [$aBottomRightNew[$i2][0], $aBottomRightNew[$i2][1]]
		For $i = UBound($aBottomRightNew) - 1 To 0 Step -1
			If $i2 = $i Then ContinueLoop
			Local $x = Abs($aBottomRightNew[$i][0] - $iTmp[0]), $y = Abs($aBottomRightNew[$i][1] - $iTmp[1])
			If ($x < 10 And $y < 10) And Not ($x > 5 And $y > 5) Then ContinueLoop 2
			If $i = 0 Then _ArrayDelete($aBottomRightNew, $i2)
		Next
	Next

	_ArraySort($aBottomLeft, 0, 0, 0, 1)
	Local $iLastY = -1, $iMaxX = -1
	Local $aBottomLeftNew[0][2]
	
	For $i2 = 0 To UBound($aBottomLeft) - 1
		
		If $aBottomLeft[$i2][1] <> $iLastY Then
			$iMaxX = $aBottomLeft[$i2][0]
			$iLastY = $aBottomLeft[$i2][1]
			
			Local $a3 = _ArrayFindAll($aBottomLeft, $iLastY, Default, Default, Default, Default, 2)
			
			If $a3 <> -1 Then
				For $i = UBound($a3) - 1 To 0 Step -1
					If $aBottomLeft[Int($a3[0])][0] > $iMaxX Then $iMaxX = $aBottomLeft[$i][0]
				Next
			EndIf
			
			Local $aArray[1][2] = [[$iMaxX, $iLastY]]
			_ArrayAdd($aBottomLeftNew, $aArray)
		EndIf
	Next

	For $i2 = UBound($aBottomLeftNew) - 1 To 0 Step -1
		Local $iTmp[2] = [$aBottomLeftNew[$i2][0], $aBottomLeftNew[$i2][1]]
		For $i = UBound($aBottomLeftNew) - 1 To 0 Step -1
			If $i2 = $i Then ContinueLoop
			Local $x = Abs($aBottomLeftNew[$i][0] - $iTmp[0]), $y = Abs($aBottomLeftNew[$i][1] - $iTmp[1])
			If ($x < 10 And $y < 10) And Not ($x > 5 And $y > 5) Then ContinueLoop 2
			If $i = 0 Then _ArrayDelete($aBottomLeftNew, $i2)
		Next
	Next
	
	; In no 'DP' case.
	If UBound($aTopLeftNew) < 11 Or UBound($aTopRightNew) < 11 Or UBound($aBottomRightNew) < 11 Or UBound($aBottomLeftNew) < 11 Then 
		$g_aBuilderBaseOuterDiamond = BuilderBaseAttackOuterDiamond()
	
		If $g_aBuilderBaseOuterDiamond <> -1 Then
			Return BuilderBaseGetEdges($g_aBuilderBaseOuterDiamond, "Outer Edges")
		EndIf
	EndIf
	
	Local $aSides[4] = [$aTopLeftNew, $aTopRightNew, $aBottomRightNew, $aBottomLeftNew]

	Return $aSides
EndFunc   ;==>PointDeployBB

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

# _IsChecked, From: https://www.autoitscript.com/autoit3/docs/functions/GUICtrlCreateCheckbox.htm
Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

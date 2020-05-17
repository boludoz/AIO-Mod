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

Func _getTroopCountBig($x_start, $y_start, $DebugOCR = False)
	_CaptureRegion2($x_start, $y_start, $x_start + 53, $y_start + 17)
	Return getTroopCountBig($x_start, $y_start)
EndFunc   ;==>_getTroopCountBig

Func _getTroopCountSmall($x_start, $y_start, $DebugOCR = False)
	_CaptureRegion2($x_start, $y_start, $x_start + 53, $y_start + 16)
	Return getTroopCountSmall($x_start, $y_start)
EndFunc   ;==>_getTroopCountSmall

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

Func PointDeployBB($sDirectory = $g_sBundleDeployPointsBB, $Quantity2Match = 0, $bForceCapture = True, $DebugLog = False)
	Local $iMax = 0

	Local $aiPostFix[4] = [130, 210, 745, 630]

	Local $aResult = findMultiple($sDirectory, "ECD", "ECD", 0, 1000, $Quantity2Match, "objectname,objectlevel,objectpoints", $bForceCapture)

	If Not IsArray($aResult) Then Return -1

	Local $iCount = 0

	Local $aAllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To $iMax
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) - 1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)
			; Inspired in Chilly-chill
			If BitOR(($aiPostFix[0] > $aCommaCoord[0]), ($aiPostFix[1] > $aCommaCoord[1]), ($aiPostFix[2] < $aCommaCoord[0]), ($aiPostFix[3] < $aCommaCoord[1])) <> 0 Then ContinueLoop
			Local $aTmpResults[1][4] = [[$aArrays[0], Int($aCommaCoord[0]), Int($aCommaCoord[1]), Int($aArrays[1])]]
			_ArrayAdd($aAllResults, $aTmpResults)
		Next
		$iCount += 1
	Next
	If $iCount < 1 Then Return -1

	If UBound($aAllResults) > 0 Then
		; Sort by X axis
		_ArraySort($aAllResults, 0, 0, 0, 1)

		Local $iAngle = 25
		;Local $iDToCheck = 5

		; check if is a double Detection, near in 10px
		For $i = 0 To UBound($aAllResults) - 1
			If $i > UBound($aAllResults) - 1 Then ExitLoop
			Local $LastCoordinate[4] = [$aAllResults[$i][0], $aAllResults[$i][1], $aAllResults[$i][2], $aAllResults[$i][3]]
			SetDebugLog("Coordinate to Check: " & _ArrayToString($LastCoordinate))
			If UBound($aAllResults) > 1 Then
				For $j = 0 To UBound($aAllResults) - 1
					If $j > UBound($aAllResults) - 1 Then ExitLoop
					Local $SingleCoordinate[4] = [$aAllResults[$j][0], $aAllResults[$j][1], $aAllResults[$j][2], $aAllResults[$j][3]]
					If $LastCoordinate[1] <> $SingleCoordinate[1] Or $LastCoordinate[2] <> $SingleCoordinate[2] Then
						If Abs($SingleCoordinate[2] - $LastCoordinate[2]) < $iAngle Then
							_ArrayDelete($aAllResults, $j)
						EndIf
					Else
						If $LastCoordinate[1] = $SingleCoordinate[1] And $LastCoordinate[2] = $SingleCoordinate[2] And $LastCoordinate[3] <> $SingleCoordinate[3] Then
							_ArrayDelete($aAllResults, $j)
						EndIf
					EndIf
				Next
			EndIf
		Next
	Else
		Return -1
	EndIf
	
	_CaptureRegion2()

	Local $sSubDir = $g_sProfileTempDebugPath & "PointDeployBB"

	DirCreate($sSubDir)

	Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY, $sTime = @HOUR & "." & @MIN & "." & @SEC
	Local $sDebugImageName = String($sDate & "_" & $sTime & "_.png")
	Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hEditedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 3)

	For $i = 0 To UBound($aAllResults) - 1
		addInfoToDebugImage($hGraphic, $hPenRED, $aAllResults[$i][0] & "_" & $aAllResults[$i][3], $aAllResults[$i][1], $aAllResults[$i][2])
	Next

	_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $sDebugImageName)
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($hEditedImage)
		
	Return $aAllResults
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

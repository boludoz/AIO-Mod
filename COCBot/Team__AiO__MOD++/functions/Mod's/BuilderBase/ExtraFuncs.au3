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

Func PointDeployBB($sDirectory = $g_sBundleDeployPointsBB, $Quantity2Match = 0, $iFurMin = 5, $iFurMax = 10, $iCenterX = 450, $iCenterY = 425, $bForceCapture = True, $DebugLog = False)
	
	Local $aTopLeft[0][2], $aTopRight[0][2], $aBottomRight[0][2], $aBottomLeft[0][2]

	Local $aiPostFix[4] = [130, 210, 745, 630]
	Local $aResult[0]
	
	For $i = 0 To 1
		Local $vResult = findMultiple($sDirectory, "ECD", "ECD", 0, 1000, $Quantity2Match, "objectname,objectlevel,objectpoints", $bForceCapture)
		If Not IsArray($vResult) Or UBound($vResult) < 1 Then ContinueLoop
		_ArrayAdd($aResult, $vResult)
		If _Sleep(Random(400, 700, 1)) Then Return
	Next
	
	If Not IsArray($aResult) Then Return -2

	Local $iCount = 0

	Local $aAllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To UBound($aResult) -1
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) - 1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)
			; Inspired in Chilly-chill
			If BitOR(($aiPostFix[0] > $aCommaCoord[0]), ($aiPostFix[1] > $aCommaCoord[1]), ($aiPostFix[2] < $aCommaCoord[0]), ($aiPostFix[3] < $aCommaCoord[1])) <> 0 Then ContinueLoop
			If $Quantity2Match = 0 Then
				;-------------------
					Local $aPoint[2] = [Int($aCommaCoord[0]), Int($aCommaCoord[1])]
 					Local $iFur = Random($iFurMin,$iFurMax, 1)
					SetDebugLog("[" & $i & "]Deploy Point: (" & $aPoint[0] & "," & $aPoint[1] & ")")
					Switch DeployPointsPosition($aPoint)
						Case 0 ; TopLeft
							Local $P = _GetPixelColor($aPoint[0] - $iFur, $aPoint[1] - $iFur, True)
							If Not _ColorCheck($P, Hex(0x447063, 6), 17) And Not _ColorCheck($P, Hex(0x547C60, 6), 8) And Not _ColorCheck($P, Hex(0x39535A, 6), 17) And Not _ColorCheck($P, Hex(0x355550, 6), 17) Then ContinueLoop
							ReDim $aTopLeft[UBound($aTopLeft) + 1][2]
							$aTopLeft[UBound($aTopLeft) - 1][0] = $aPoint[0] - $iFur
							$aTopLeft[UBound($aTopLeft) - 1][1] = $aPoint[1] - $iFur
						Case 1 ; TopRight
							Local $P = _GetPixelColor($aPoint[0] + $iFur, $aPoint[1] - $iFur, True)
							If Not _ColorCheck($P, Hex(0x447063, 6), 15) And Not _ColorCheck($P, Hex(0x547C60, 6), 8) And Not _ColorCheck($P, Hex(0x39535A, 6), 16) And Not _ColorCheck($P, Hex(0x355550, 6), 16) Then ContinueLoop
							ReDim $aTopRight[UBound($aTopRight) + 1][2]
							$aTopRight[UBound($aTopRight) - 1][0] = $aPoint[0] + $iFur
							$aTopRight[UBound($aTopRight) - 1][1] = $aPoint[1] - $iFur
						Case 2 ; BottomRight
							Local $P = _GetPixelColor($aPoint[0] + $iFur, $aPoint[1] + $iFur, True)
							If Not _ColorCheck($P, Hex(0x447063, 6), 17) And Not _ColorCheck($P, Hex(0x547C60, 6), 8) And Not _ColorCheck($P, Hex(0x39535A, 6), 17) And Not _ColorCheck($P, Hex(0x355550, 6), 17) Then ContinueLoop
							ReDim $aBottomRight[UBound($aBottomRight) + 1][2]
							$aBottomRight[UBound($aBottomRight) - 1][0] = $aPoint[0] + $iFur
							$aBottomRight[UBound($aBottomRight) - 1][1] = $aPoint[1] + $iFur
						Case 3 ;BottomLeft
							Local $P = _GetPixelColor($aPoint[0] - $iFur, $aPoint[1] + $iFur, True)
							If Not _ColorCheck($P, Hex(0x447063, 6), 17) And Not _ColorCheck($P, Hex(0x547C60, 6), 8) And Not _ColorCheck($P, Hex(0x39535A, 6), 17) And Not _ColorCheck($P, Hex(0x355550, 6), 17) Then ContinueLoop
							ReDim $aBottomLeft[UBound($aBottomLeft) + 1][2]
							$aBottomLeft[UBound($aBottomLeft) - 1][0] = $aPoint[0] - $iFur
							$aBottomLeft[UBound($aBottomLeft) - 1][1] = $aPoint[1] + $iFur
					EndSwitch
				;-------------------
			EndIf
		Next
		$iCount += 1
	Next
	If $iCount < 1 Then Return -3

	Local $aSides[4] = [$aTopLeft, $aTopRight, $aBottomRight, $aBottomLeft]

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

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
	_FileWriteLog($g_hBBAttackLogFile, $String1 & $String2)
	Local $a[6] = [$String1 & @CRLF, $Color, $Font, $FontSize, 0, 0]
	$g_oTxtBBAtkLogInitText($g_oTxtBBAtkLogInitText.Count + 1) = $a
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

Func PointDeployBB($sDirectory = $g_sBundleDeployPointsBB, $Quantity2Match = 0, $iFurMin = 5, $iFurMax = 5, $iCenterX = 450, $iCenterY = 425, $bForceCapture = True, $DebugLog = False) ; Return a large amount of quality deploy point with random and safe further from without theorem.
	Local $vResult[1][2], $aSides[0][2], $sHex = 0x000000, $aHex = [[0x447063, 20], [0x446661, 5], [0x446761, 5], [0x1F383B, 5], [0x639581, 5], [0x6A9C7F, 5], [0x609278, 5]] ;$aHex = [[0x447063, 20], [0x6A9C7F, 5], [0x609278, 5]], $sHex = 0x000000
	Local $aiPostFix[4] = [25, 103, 815, 712]

	If $bForceCapture Then _CaptureRegions()

	Local $aRes = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", GetDiamondFromArray($aiPostFix), "Int", $Quantity2Match, "str", GetDiamondFromArray($aiPostFix), "Int", 0, "Int", 1000)
	Local $KeyValue = StringSplit($aRes[0], "|", $STR_NOCOUNT)
	Local $Name = ""
	Local $aPositions, $aCoords, $aCord, $level, $aCoordsM
	SetDebugLog("Detected : " & UBound($KeyValue) & " tiles")
	Local $AllFilenamesFound[UBound($KeyValue)][3]
	Local $iFur = Random($iFurMin, $iFurMax, 1)
	For $i = 0 To UBound($KeyValue) - 1
		$aPositions = RetrieveImglocProperty($KeyValue[$i], "objectpoints")
		$aCoords = decodeMultipleCoords($aPositions, 0, 0, 0)
		For $iCoords = 0 To UBound($aCoords) - 1
			Local $aCoordsM = $aCoords[$iCoords]
			
			If Int($aCoordsM[0]) < Int($iCenterX) Then
				If Int($aCoordsM[1]) < Int($iCenterY) Then
					$vResult[0][0] = $aCoordsM[0] - $iFur
					$vResult[0][1] = $aCoordsM[1] - $iFur
				Else
					$vResult[0][0] = $aCoordsM[0] - $iFur
					$vResult[0][1] = $aCoordsM[1] + $iFur
				EndIf
			Else
				If Int($aCoordsM[1]) < Int($iCenterY) Then
					$vResult[0][0] = $aCoordsM[0] + $iFur
					$vResult[0][1] = $aCoordsM[1] - $iFur
				Else
					$vResult[0][0] = $aCoordsM[0] + $iFur
					$vResult[0][1] = $aCoordsM[1] + $iFur
				EndIf
			EndIf
			
			$sHex = _GetPixelColor($vResult[0][0], $vResult[0][1], False)
			For $i = 0 To UBound($aHex) -1
				If _ColorCheck($sHex, Hex($aHex[$i][0], 6), $aHex[$i][1]) = True Then
					PointBB($aSides, $vResult[0][0], $vResult[0][1])
					ContinueLoop
				EndIf
			Next
			
		Next
	Next
	
	Return $aSides
EndFunc   ;==>PointDeployBB

Func PointBB(ByRef $aXYs, $x1, $y1, $iD = 18)
	
	; Check distance fast.
	For $i = 0 To UBound($aXYs) -1
		If Pixel_Distance($aXYs[$i][0], $aXYs[$i][1], $x1, $y1) < $iD Then Return
	Next
	
	; Add point.
	ReDim $aXYs[UBound($aXYs) + 1][2]
	$aXYs[UBound($aXYs) -1][0] = $x1
	$aXYs[UBound($aXYs) -1][1] = $y1
	
EndFunc   ;==>PointBB

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
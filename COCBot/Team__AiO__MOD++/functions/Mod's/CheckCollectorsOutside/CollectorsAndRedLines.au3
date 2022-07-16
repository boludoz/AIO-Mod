; FUNCTION ====================================================================================================================
; Name ..........: CollectorsAndRedLines
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: True					More collectors outside than specified.
;				 : False				less collectors outside than specified.
; Author ........: Samkie (13 Jan 2017) & Team AiO MOD++ (2020/2021)
; Modified ......: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================
Func CollectorsAndRedLines($bForceCapture = False)
	If $bForceCapture = True Then _CaptureRegion2()
    If $g_bDBMeetCollectorOutside Then
		Return AreCollectorsNearRedline()
    EndIf
EndFunc   ;==>CollectorsAndRedLines

Func TitleMesures()
    Local $aNORTH[2] = [48.7915407854985, 20], $aWEST[2] = [47.8851963746224, 21.010101010101], $aEAST[2] = [49.6978851963746, 21.010101010101], $aSOUTH[2] = [48.7915407854985, 22.020202020202]
    PercentToVillage($aNORTH[0], $aNORTH[1])
    PercentToVillage($aWEST[0], $aWEST[1])
    PercentToVillage($aEAST[0], $aEAST[1])
    PercentToVillage($aSOUTH[0], $aSOUTH[1])
    Local $aResult[2] = [Pixel_Distance($aWEST[0], $aWEST[1], $aEAST[0], $aEAST[1]), Pixel_Distance($aNORTH[0], $aNORTH[1], $aSOUTH[0], $aSOUTH[1])]
    Return $aResult
EndFunc   ;==>TitleMesures

Func AreCollectorsNearRedline()
	SetLog("Locating Mines & Collectors", $COLOR_INFO)
	
	; reset variables
	ReDim $g_aiPixelMine[0]
	ReDim $g_aiPixelElixir[0]
	ReDim $g_aiPixelDarkElixir[0]
	Local $aiPixelNearCollector[0]

	Local $hTimer = TimerInit()
	Local $iTotalCollectorNearRedline = 0

	_GetRedArea()

	SuspendAndroid()
	$g_aiPixelMine = GetLocationMine()
	If (IsArray($g_aiPixelMine)) Then
		_ArrayAdd($aiPixelNearCollector, $g_aiPixelMine, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	EndIf
	$g_aiPixelElixir = GetLocationElixir()
	If (IsArray($g_aiPixelElixir)) Then
		_ArrayAdd($aiPixelNearCollector, $g_aiPixelElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	EndIf
	$g_aiPixelDarkElixir = GetLocationElixir()
	If (IsArray($g_aiPixelDarkElixir)) Then
		_ArrayAdd($aiPixelNearCollector, $g_aiPixelDarkElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	EndIf
	ResumeAndroid()

	$g_bScanMineAndElixir = True

	Global $colNbr = UBound($aiPixelNearCollector)

	SetLog("Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds")
	SetLog("[" & UBound($g_aiPixelMine) & "] Gold Mines")
	SetLog("[" & UBound($g_aiPixelElixir) & "] Elixir Collectors")
	SetLog("[" & UBound($g_aiPixelDarkElixir) & "] Dark Elixir Collectors")
	
	Local $aTitleMesures = TitleMesures()
 	Local $diamondx = $aTitleMesures[0] + ($aTitleMesures[0] * $g_iCmbRedlineTiles)
 	Local $diamondy = $aTitleMesures[1] + ($aTitleMesures[1] * $g_iCmbRedlineTiles)
	Local $arrCollectorsFlag[0]

	If $colNbr > 0 Then
		ReDim $arrCollectorsFlag[$colNbr]
		Local $iMaxRedArea = UBound($g_aiPixelRedArea) - 1
		For $i = 0 To $iMaxRedArea
			Local $pixelCoord = $g_aiPixelRedArea[$i]
			For $j = 0 To $colNbr - 1
				If $arrCollectorsFlag[$j] <> True Then
					Local $pixelCoord2 = $aiPixelNearCollector[$j]
					If Abs(($pixelCoord[0] - $pixelCoord2[0]) / $diamondx) + Abs(($pixelCoord[1] - $pixelCoord2[1]) / $diamondy) <= 1 Then
						$arrCollectorsFlag[$j] = True
						$iTotalCollectorNearRedline += 1
					EndIf
				EndIf
			Next
			If $iTotalCollectorNearRedline >= $colNbr Then ExitLoop
		Next
		SetLog("Total collectors Found: " & $colNbr)
		SetLog("Total collectors near red line: " & $iTotalCollectorNearRedline)
		If $iTotalCollectorNearRedline >= Round($colNbr * $g_iDBMinCollectorOutsidePercent / 100) Then
			Return True
		EndIf
	EndIf
	Return False
EndFunc

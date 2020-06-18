; FUNCTION ====================================================================================================================
; Name ..........: AreCollectorsNearRedline
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: True					more collectors near redline
;				 : False				less collectors outside than specified
; Author ........: Samkie (7 FEB 2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func AreCollectorsNearRedline($percent)
	SetLog("Locating Mines & Collectors", $COLOR_INFO)
	; reset variables
	Global $g_aiPixelMine[0]
	Global $g_aiPixelElixir[0]
	Global $g_aiPixelNearCollector[0]

	Global $hTimer = TimerInit()
	Global $iTotalCollectorNearRedline = 0
	Global $hBitmapFirst
	_WinAPI_DeleteObject($hBitmapFirst)
	$hBitmapFirst = _CaptureRegion2()
	_GetRedArea()

	$g_aiPixelMine = GetLocationMine()
	$g_aiPixelElixir = GetLocationElixir()
	$g_aiPixelDarkElixir = GetLocationDarkElixir()

	If Not (IsArray($g_aiPixelMine) Or IsArray($g_aiPixelElixir) Or (IsArray($g_aiPixelDarkElixir) And ($g_iTownHallLevel > 6) And (Not $g_bSmartZapEnable))) Then
		SetLog("Are collectors outside | No mines/collectors/drills detected.", $COLOR_INFO)
		Return False
	Else
		If IsArray($g_aiPixelMine) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelMine, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
		If IsArray($g_aiPixelElixir) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
		If IsArray($g_aiPixelDarkElixir) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelDarkElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	EndIf

	$g_bScanMineAndElixir = True

	Global $colNbr = UBound($g_aiPixelNearCollector)

	SetLog("Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds")
	SetLog("[" & UBound($g_aiPixelElixir) & "] Elixir collectors", $COLOR_INFO)
	SetLog("[" & UBound($g_aiPixelMine) & "] Gold mines", $COLOR_INFO)
	SetLog("[" & UBound($g_aiPixelDarkElixir) & "] Dark elixir drills", $COLOR_INFO)

 	Local $diamondx = $g_iMilkFarmOffsetX + $g_iMilkFarmOffsetXStep * $g_iCmbRedlineTiles
 	Local $diamondy = $g_iMilkFarmOffsetY + $g_iMilkFarmOffsetYStep * $g_iCmbRedlineTiles
	Local $arrCollectorsFlag[0]

	If $colNbr > 0 Then
		ReDim $arrCollectorsFlag[$colNbr]
		Local $iMaxRedArea = UBound($g_aiPixelRedArea) - 1
		For $i = 0 To $iMaxRedArea
			Local $pixelCoord = $g_aiPixelRedArea[$i]
			For $j = 0 To $colNbr - 1
				If $arrCollectorsFlag[$j] <> True Then
					Local $aXY = $g_aiPixelNearCollector[$j]
					If Abs(($pixelCoord[0] - $aXY[0]) / $diamondx) + Abs(($pixelCoord[1] - $aXY[1]) / $diamondy) <= 1 Then
						$arrCollectorsFlag[$j] = True
						$iTotalCollectorNearRedline += 1
					EndIf
				EndIf
			Next
			If $iTotalCollectorNearRedline >= $colNbr Then ExitLoop
		Next
		SetLog("Total collectors Found: " & $colNbr)
		SetLog("Total collectors near red line: " & $iTotalCollectorNearRedline)
		If $iTotalCollectorNearRedline >= Round($colNbr * $percent / 100) Then
			Return True
		EndIf
	EndIf
	If $g_bDebugMakeIMGCSV Then AttackCSVDEBUGIMAGE()
	Return False
EndFunc   ;==>AreCollectorsNearRedline

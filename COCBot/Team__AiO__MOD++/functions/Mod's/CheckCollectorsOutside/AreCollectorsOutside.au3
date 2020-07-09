; FUNCTION ====================================================================================================================
; Name ..........: AreCollectorsOutside
; Description ...: dark drills are ignored since they can be zapped
; Syntax ........:
; Parameters ....: $percent				minimum % of collectors outside of walls to all
; Return values .: True					more collectors outside than specified
;				 : False				less collectors outside than specified
; Author ........: McSlither (Jan-2016)
; Modified ......: TheRevenor (Jul 2016), Samkie (13 Jan 2017), Team AiO MOD++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func AreCollectorsOutside($percent)
	If $g_bDBCollectorNearRedline Then Return AreCollectorsNearRedline($percent)
	
	SetLog("Locating Mines & Collectors", $COLOR_INFO)
	; reset variables
	Global $g_aiPixelNearCollector[0]

	Global $colOutside = 0
	Global $hTimer = TimerInit()

	SuspendAndroid()
	_CaptureRegion2()
	Global $g_aiPixelMine = _GetLocationMine(False)
	Global $g_aiPixelElixir = _GetLocationElixir(False)
	Global $g_aiPixelDarkElixir = _GetLocationDarkElixir(False)
	ResumeAndroid()

	If Not (IsArray($g_aiPixelMine) Or IsArray($g_aiPixelElixir) Or (IsArray($g_aiPixelDarkElixir) And ($g_iTownHallLevel > 6) And (Not $g_bSmartZapEnable))) Then
		SetLog("Are collectors outside | No mines/collectors/drills detected.", $COLOR_INFO)
		Return False
	Else
		If IsArray($g_aiPixelMine) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelMine, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
		If IsArray($g_aiPixelElixir) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
		If IsArray($g_aiPixelDarkElixir) Then _ArrayAdd($g_aiPixelNearCollector, $g_aiPixelDarkElixir, 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	EndIf

	$g_bScanMineAndElixir = True

	SetLog("Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_INFO)
	SetLog("[" & UBound($g_aiPixelElixir) & "] Elixir collectors", $COLOR_INFO)
	SetLog("[" & UBound($g_aiPixelMine) & "] Gold mines", $COLOR_INFO)
	SetLog("[" & UBound($g_aiPixelDarkElixir) & "] Dark elixir drills", $COLOR_INFO)

	Global $minColOutside = Round(UBound($g_aiPixelNearCollector) * $percent / 100)
	Global $radiusAdjustment = 1
	
	If $g_iSearchTH = "-" Or $g_iSearchTH = "" Then FindTownhall(True)
	Local $iSearchTH = $g_iSearchTH
	
	If ($iSearchTH > 10) Then $iSearchTH = 11
	
	If $iSearchTH <> "-" Then
		$radiusAdjustment *= Number($iSearchTH) / 10
	Else
		If ($g_iTownHallLevel > 0) Then
			$radiusAdjustment *= Number($g_iTownHallLevel) / 10
		Else
			$radiusAdjustment *= Number(10) / 10
		EndIf
	EndIf
	If $g_bDebugSetlog Then SetLog("$iSearchTH: " & $iSearchTH)

	For $i = 0 To UBound($g_aiPixelNearCollector) - 1
			Local $aXY = $g_aiPixelNearCollector[$i]
			If isOutsideEllipse($aXY[0], $aXY[1], $CollectorsEllipseWidth * $radiusAdjustment, $CollectorsEllipseHeigth * $radiusAdjustment) Then
				If $g_bDebugSetlog Then SetLog("Collector (" & $aXY[0] & ", " & $aXY[1] & ") is outside", $COLOR_PURPLE)
				$colOutside += 1
			EndIf
		If $colOutside >= $minColOutside Then
			If $g_bDebugSetlog Then SetDebugLog("More than " & $percent & "% of the collectors are outside", $COLOR_DEBUG)
			Return True
		EndIf
	Next
	If $g_bDebugSetlog Then SetDebugLog($colOutside & " collectors found outside (out of " & UBound($g_aiPixelNearCollector) & ")", $COLOR_DEBUG)
	Return False
EndFunc   ;==>AreCollectorsOutside

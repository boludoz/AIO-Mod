; #FUNCTION# ====================================================================================================================
; Name ..........: getOcrDissociable
; Description ...: Gets complete value of gold/Elixir/DarkElixir/Trophy/Gem xxx,xxx
; Author ........: Dissociable (2020)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getResourcesMainScreenDOCR($x_start, $y_start) ; -> Gets complete value of Gold/Elixir/Dark Elixir/Trophies/Gems xxx,xxx "VillageReport.au3"
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 110, 16, True)
EndFunc   ;==>getResourcesMainScreenDOCRDOCR

Func getOcrAndCaptureDOCR($bundle, $x_start, $y_start, $width, $height, $removeSpace = Default, $bForceCaptureRegion = Default)
	If $removeSpace = Default Then $removeSpace = False
	If $bForceCaptureRegion = Default Then $bForceCaptureRegion = $g_bOcrForceCaptureRegion
	Static $_hHBitmap = 0
	If $bForceCaptureRegion = True Then
		_CaptureRegion2($x_start, $y_start, $x_start + $width, $y_start + $height)
	Else
		$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $x_start, $y_start, $x_start + $width, $y_start + $height)
	EndIf
	Local $result
    If $_hHBitmap <> 0 Then
        $result = getOcrDOCR($_hHBitmap, $bundle)
    Else
        $result = getOcrDOCR($g_hHBitmap2, $bundle)
    EndIf
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If ($removeSpace) Then
		$result = StringReplace($result, " ", "")
	Else
		$result = StringStripWS($result, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	EndIf
	Return $result
EndFunc   ;==>getOcrAndCaptureDOCR

Func getOcrDOCR(ByRef Const $_hHBitmap, $bundle)
	Local $result = DllCallDOCR("Recognize", "str", "handle", $_hHBitmap, "str", $bundle)
	return $result
EndFunc   ;==>getOcrDOCR
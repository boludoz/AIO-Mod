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

Func getResourcesMainScreen($iX_start, $iY_start) ; -> Gets complete value of Gold/Elixir/Dark Elixir/Trophies/Gems xxx,xxx "VillageReport.au3"
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $iX_start, $iY_start, 110, 16, True)
EndFunc   ;==>getResourcesMainScreen

Func getTrophyMainScreen($x_start, $y_start) ; -> Gets trophy value, top left of main screen "VillageReport.au3"
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 50, 16, True)
EndFunc   ;==>getTrophyMainScreen

Func getResourcesValueTrainPage($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getResourcesValueTrainPage

Func getArmyCampCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity --> train.au3, and used to read CC request time remaining
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 82, 16, True, $bNeedCapture)
EndFunc   ;==>getArmyCampCap

Func getBuilders($x_start, $y_start) ;  -> Gets Builders number - main screen --> getBuilders(324,23)
	Return getOcrAndCaptureDOCR($g_sMainBuildersDOCRB, $x_start, $y_start, 45, 20, True)
EndFunc   ;==>getBuilders

Func getTroopCountSmall($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start, 55, 17, True, Default, $bNeedNewCapture)
EndFunc   ;==>getTroopCountSmall

Func getTroopCountBig($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start, 55, 17, True, Default, $bNeedNewCapture)
EndFunc   ;==>getTroopCountBig

Func _getTroopCountSmall($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start, 53, 17, True, $bNeedNewCapture)
EndFunc   ;==>_getTroopCountSmall

Func _getTroopCountBig($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start, 53, 17, True, $bNeedNewCapture)
EndFunc   ;==>_getTroopCountBig

Func SpecialOCRCut($sBundle, $iX_start, $iY_start, $iWidth, $iHeight, $bRemoveSpace = Default, $bForceCaptureRegion = Default)
	Return StringReplace(getOcrAndCaptureDOCR($sBundle, $iX_start, $iY_start, $iWidth, $iHeight, $bRemoveSpace, $bForceCaptureRegion), "#", "")
EndFunc   ;==>getBuilders

Func getOcrAndCaptureDOCR($sBundle, $iX_start, $iY_start, $iWidth, $iHeight, $bRemoveSpace = Default, $bForceCaptureRegion = Default)
	If $bRemoveSpace = Default Then $bRemoveSpace = False
	If $bForceCaptureRegion = Default Then $bForceCaptureRegion = $g_bOcrForceCaptureRegion
	Static $_hHBitmap = 0
	If $bForceCaptureRegion = True Then
		_CaptureRegion2($iX_start, $iY_start, $iX_start + $iWidth, $iY_start + $iHeight)
	Else
		$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $iX_start, $iY_start, $iX_start + $iWidth, $iY_start + $iHeight)
	EndIf
	Local $aResult
	If $_hHBitmap <> 0 Then
		$aResult = getOcrDOCR($_hHBitmap, $sBundle)
	Else
		$aResult = getOcrDOCR($g_hHBitmap2, $sBundle)
	EndIf
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If ($bRemoveSpace) Then
		$aResult = StringReplace($aResult, "|", "")
		$aResult = StringStripWS($aResult, $STR_STRIPALL)
	Else
		$aResult = StringStripWS($aResult, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	EndIf
	Return $aResult
EndFunc   ;==>getOcrAndCaptureDOCR

Func getOcrDOCR(ByRef Const $_hHBitmap, $sBundle)
	Local $aResult = DllCallDOCR("Recognize", "str", "handle", $_hHBitmap, "str", $sBundle)
	Return $aResult
EndFunc   ;==>getOcrDOCR

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
; Attack Screen
Func getAttackScreenButtons($x_start, $y_start, $iWidth, $iHeight) ;48, 69 -> Gets complete value of gold xxx,xxx while searching, top left, Getresources.au3
	Return getOcrAndCaptureDOCR($g_sASButtonsDOCRPath, $x_start, $y_start, $iWidth, $iHeight, False, True)
EndFunc   ;==>getGoldVillageSearch
; End Attack Screen

; Search village sector
Func getGoldVillageSearch($x_start, $y_start) ;48, 69 -> Gets complete value of gold xxx,xxx while searching, top left, Getresources.au3
	Return getOcrAndCaptureDOCR($g_sAttackRGold, $x_start, $y_start, 90, 16, True)
EndFunc   ;==>getGoldVillageSearch

Func getElixirVillageSearch($x_start, $y_start) ;48, 69+29 -> Gets complete value of Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCaptureDOCR($g_sAttackRPink, $x_start, $y_start, 90, 16, True)
EndFunc   ;==>getElixirVillageSearch

Func getDarkElixirVillageSearch($x_start, $y_start) ;48, 69+57 or 69+69  -> Gets complete value of Dark Elixir xxx,xxx, top left,  Getresources.au3
	Return getOcrAndCaptureDOCR($g_sAttackRBlack, $x_start, $y_start, 75, 18, True)
EndFunc   ;==>getDarkElixirVillageSearch

; Search village sector end.

Func getResourcesMainScreen($iX_start, $iY_start) ; -> Gets complete value of Gold/Elixir/Dark Elixir/Trophies/Gems xxx,xxx "VillageReport.au3"
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $iX_start, $iY_start, 110, 16, True)
EndFunc   ;==>getResourcesMainScreen

Func getTrophyMainScreen($x_start, $y_start) ; -> Gets trophy value, top left of main screen "VillageReport.au3"
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 50, 16, True)
EndFunc   ;==>getTrophyMainScreen

Func getResourcesValueTrainPage($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCaptureDOCR($g_sMainResourcesDOCRB, $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getResourcesValueTrainPage

;Func getArmyCampCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity --> train.au3, and used to read CC request time remaining
;	Return getOcrAndCaptureDOCR($g_sAOverviewTotals, $x_start, $y_start, 82, 16, True, $bNeedCapture)
;EndFunc   ;==>getArmyCampCap

Func getBuilders($x_start, $y_start) ;  -> Gets Builders number - main screen --> getBuilders(324,23)
	Return getOcrAndCaptureDOCR($g_sMainBuildersDOCRB, $x_start, $y_start, 45, 20, True)
EndFunc   ;==>getBuilders

;Func getTroopCountSmall($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
;	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start-8, 55, 17+8, True, $bNeedNewCapture)
;EndFunc   ;==>getTroopCountSmall
;
;Func getTroopCountBig($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for selected troop kind
;	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start-8, 55, 17+8, True, $bNeedNewCapture)
;EndFunc   ;==>getTroopCountBig

;
Func _getTroopCountSmall($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for non-selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start-8, 55, 17+8, True, $bNeedNewCapture)
EndFunc   ;==>_getTroopCountSmall

Func _getTroopCountBig($x_start, $y_start, $bNeedNewCapture = Default) ;  -> Gets troop amount on Attack Screen for selected troop kind
	Return SpecialOCRCut($g_sAttackBarDOCRB, $x_start, $y_start-8, 55, 17+8, True, $bNeedNewCapture)
EndFunc   ;==>_getTroopCountBig

Func SpecialOCRCut($sBundle, $iX_start, $iY_start, $iWidth, $iHeight, $bRemoveSpace = Default, $bForceCaptureRegion = Default)
	Return StringReplace(getOcrAndCaptureDOCR($sBundle, $iX_start, $iY_start, $iWidth, $iHeight, $bRemoveSpace, $bForceCaptureRegion), "#", "")
EndFunc   ;==>getBuilders

Func getOcrAndCaptureDOCR($sBundle, $iX_start = 0, $iY_start = 0, $iWidth = $g_iGAME_WIDTH, $iHeight = $g_iGAME_HEIGHT, $bRemoveSpace = False, $vCapture = True, $bArrayMode = False)
	;	getOcrAndCaptureDOCR($g_sImgReportResultBB, Default, Default, Default, Default, Default, False, True)
	If $iX_start = Default Then $iX_start = 0
	If $iY_start = Default Then $iY_start = 0
	If $iWidth = Default Then $iWidth = $g_iGAME_WIDTH
	If $iHeight = Default Then $iHeight = $g_iGAME_HEIGHT
	If $bRemoveSpace = Default Then $bRemoveSpace = False
	If $vCapture = Default Then $vCapture = $g_bOcrForceCaptureRegion
	If $bArrayMode = Default Then $bArrayMode = False
	
	Local $_hHBitmap = 0
	
	If IsBool($vCapture) Then 
		If $vCapture = True Then
			_CaptureRegion2()
			$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $iX_start, $iY_start, $iX_start + $iWidth, $iY_start + $iHeight)
		Else
			If Not IsPtr($g_hHBitmap2) Then 
				SetLog("getOcrAndCaptureDOCR | Give a capture. (0x1).", $COLOR_ERROR)
				Return -1
			EndIf
			$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $iX_start, $iY_start, $iX_start + $iWidth, $iY_start + $iHeight)
		EndIf
	ElseIf IsPtr($vCapture) Then
		$_hHBitmap = GetHHBitmapArea($vCapture, $iX_start, $iY_start, $iX_start + $iWidth, $iY_start + $iHeight)
	EndIf
	
	Local $aResult = getOcrDOCR($_hHBitmap, $sBundle), $vResult = -1
	If Not $bArrayMode Then
		If ($bRemoveSpace) Then
			Local $vResult = StringReplace($aResult, "|", "")
			$vResult = StringStripWS($aResult, $STR_STRIPALL)
		Else
			Local $vResult = StringStripWS($aResult, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
		EndIf
	ElseIf ($bArrayMode) Then
		$vResult = StringSplit($aResult, '|', $STR_NOCOUNT)
	EndIf
	
	Return $vResult
EndFunc   ;==>getOcrAndCaptureDOCR

Func getOcrDOCR(ByRef Const $_hHBitmap, $sBundle)
	Local $aResult = DllCallDOCR("Recognize", "str", "handle", $_hHBitmap, "str", $sBundle)
	If $g_bDOCRDebugImages Then
		DirCreate($g_sProfileTempDebugDOCRPath)
		Local $isBundleFile = StringRight($sBundle, 5) = ".docr"
		Local $sSubDirFolder = ""
		If $isBundleFile Then
			; Remove the Last Backslash from the directory path
			While (StringRight($sBundle, 1) = "\")
				$sBundle = StringTrimRight($sBundle, 1)
			WEnd
			Local $aSplittedPath = StringSplit($sBundle, "\")
			$sSubDirFolder = $aSplittedPath[UBound($aSplittedPath, 1) - 2] & "_" & StringReplace($aSplittedPath[UBound($aSplittedPath, 1) - 1], ".docr", "")
		Else
			Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
			Local $aPathSplit = _PathSplit($sBundle, $sDrive, $sDir, $sFileName, $sExtension)
			Local $aSplittedPath = StringSplit(StringTrimRight($sBundle, StringLen($sFileName & $sExtension) + 1), "\")
			$sSubDirFolder = $aSplittedPath[UBound($aSplittedPath, 1) - 1] & "_" & $sFileName
		EndIf
		Local $sDir
		If StringRight($g_sProfileTempDebugDOCRPath, 1) <> "\" Then
			$sDir = $g_sProfileTempDebugDOCRPath & "\"
		Else
			$sDir = $g_sProfileTempDebugDOCRPath
		EndIf
		$sDir &= $sSubDirFolder & "\"
		DirCreate($sDir)
		
		Local $sDateTime = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC & "." & @MSEC
		Local $hBitmap_debug = _GDIPlus_BitmapCreateFromHBITMAP($_hHBitmap)
		Local $sFilePath = $sDir & StringRegExpReplace(StringReplace($aResult, "|", "-"), "[\[\]/\|\:\?""\*\\<>]", "") & ".png"
		SetDebugLog("Save DOCR Debug Image: " & $sFilePath)
		_GDIPlus_ImageSaveToFile($hBitmap_debug, $sFilePath)
		_GDIPlus_BitmapDispose($hBitmap_debug)
	EndIf
	Return $aResult
EndFunc   ;==>getOcrDOCR



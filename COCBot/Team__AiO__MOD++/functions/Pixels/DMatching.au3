; #FUNCTION# ====================================================================================================================
; Name ..........: DMatching.au3
; Description ...: Some functions regarding Image Matching powered by Dissociable.Matching.dll
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........: Dissociable (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; Counts Matches found by Dissociable.Matching.dll, $sObjectNameAndLevel = Default will Count all matches, $sObjectNameAndLevel = "Eagle-2" Will Count all Level 2 Found Eagles
Func CountDMatchingMatches($sMatches, $sObjectNameAndLevel = Default)
    If StringInStr($sMatches, "|", $STR_CASESENSE) = 0 Then Return 0
	Local $aMatches = StringSplit($sMatches, "|")
	Local $iSearchLen = 0
	If $sObjectNameAndLevel <> Default Then
		$iSearchLen = StringLen($sObjectNameAndLevel)
	Else
		; Search for Specific Object and Level is not determined, we Return the total objects found
		Return $aMatches[0]
	EndIf

	Local $iCounter = 0
	; We loop through the Matches to count the Determined Object and Level
	For $i = 1 To $aMatches[0]
		If StringLeft($aMatches[$i], $iSearchLen) = $sObjectNameAndLevel Then
			$iCounter += 1
		EndIf
	Next
	Return $iCounter
EndFunc

; Decodes Matches string to an Array, $sMatches must be like: Inferno-5-50-50-100-100|Inferno-6-200-200-100-100 . Representing: ObjectName-ObjectLevel-PointX-PointY-Width-Height
Func DMDecodeMatches($sMatches)
    Local $aSplittedMatches = StringSplit($sMatches, "|", $STR_NOCOUNT)
    Local $aMatches[UBound($aSplittedMatches)][6], $iRedim = 0
    For $i = 0 To UBound($aSplittedMatches) - 1
        Local $aDecodedMatch = DMDecodeMatch($aSplittedMatches[$i]) 
        If IsArray($aDecodedMatch) Then
            $aMatches[$iRedim][0] = $aDecodedMatch[0]
            $aMatches[$iRedim][1] = $aDecodedMatch[1]
            $aMatches[$iRedim][2] = $aDecodedMatch[2]
            $aMatches[$iRedim][3] = $aDecodedMatch[3]
            $aMatches[$iRedim][4] = $aDecodedMatch[4]
            $aMatches[$iRedim][5] = $aDecodedMatch[5]
			$iRedim += 1
        EndIf
    Next
	Redim $aMatches[$iRedim][6]
    Return $aMatches
EndFunc

; Decodes Matches string to an Array, $sMatches must be like: Inferno-5-50-50-100-100|Inferno-6-200-200-100-100 . Representing: PointX-PointY-Width-Height
Func DMDecodeCoords($sMatches, $iDis = 15)
    Local $aSplittedMatches = StringSplit($sMatches, "|", $STR_NOCOUNT)
    Local $aMatches[UBound($aSplittedMatches)][4], $iRedim = 0
    For $i = 0 To UBound($aSplittedMatches) - 1
        Local $aDecodedMatch = DMDecodeMatch($aSplittedMatches[$i])
        If IsArray($aDecodedMatch) And Not DMduplicated2($aMatches, $aDecodedMatch[2], $aDecodedMatch[3], $iRedim, $iDis) Then
            $aMatches[$iRedim][0] = $aDecodedMatch[2]
            $aMatches[$iRedim][1] = $aDecodedMatch[3]
            $aMatches[$iRedim][2] = $aDecodedMatch[4]
            $aMatches[$iRedim][3] = $aDecodedMatch[5]
			$iRedim += 1
        EndIf
    Next
	Redim $aMatches[$iRedim][4]
	If UBound($aMatches) < 1 Then Return -1
	Return $aMatches
EndFunc

Func DMduplicated2($aXYs, $x1, $y1, $i3, $iD = 18)
	For $i = 0 To $i3
		If Not $g_bRunState Then Return
		If Pixel_Distance($aXYs[$i][0], $aXYs[$i][1], $x1, $y1) < $iD Then Return True
	Next
	Return False
EndFunc   ;==>DMduplicated2

; Decodes a Match to an Array, $sMatch must be like: Inferno-14-50-50-100-100 . Representing: ObjectName-ObjectLevel-PointX-PointY-Width-Height
Func DMDecodeMatch($sMatch)
    Local $aSplittedMatch = StringSplit($sMatch, "-", $STR_NOCOUNT)
    If UBound($aSplittedMatch) <> 6 Then
        SetLog("DMDecodeMatch: Invalid Match passed, Passed match: " & $sMatch, $COLOR_ERROR)
        Return "-1"
    EndIf
    Return $aSplittedMatch
EndFunc

; Check if an image in the Bundle can be found
Func IsImageFound($sBundle, $iRegionX = 0, $iRegionY = 0, $iRegionWidth = 0, $iRegionHeight = 0, $iLevelStart = 0, $iLevelEnd = 0, $bForceCapture = True)
    ; Set Parameters
    If $iRegionX = Default Then
        $iRegionX = 0
        $iRegionY = 0
        $iRegionWidth = 0
        $iRegionHeight = 0
    EndIf
    If $iLevelStart = Default Then
        $iLevelStart = 0
        $iLevelEnd = 0
    EndIf
    If $g_iThreads > 0 And $g_iDMatchingThreads <> $g_iThreads Then
        $g_iDMatchingThreads = $g_iThreads
    Else
        $g_iDMatchingThreads = 32
    EndIf
    ; End Setting Parameters
    
    If $bForceCapture Then _CaptureRegion2() ; to have FULL screen image to work with

    Local $sResult = DllCallDMatching("Find", "str", "handle", $g_hHBitmap2, "str", $sBundle, "ushort", $iLevelStart, "ushort", $iLevelEnd, "ushort", $iRegionX, "ushort", $iRegionY, "ushort", $iRegionWidth, "ushort", $iRegionHeight, "ushort", $g_iDMatchingThreads, "ushort", 1, "boolean", $g_bDMatchingDebugImages)

    Return StringLen($sResult) > 0
EndFunc

Func DFind($sBundle, $iRegionX = 0, $iRegionY = 0, $iRegionWidth = 0, $iRegionHeight = 0, $iLevelStart = 0, $iLevelEnd = 0, $iLimit = 0, $bForceCapture = True)
    ; Set Parameters
    If $iRegionX = Default Then
        $iRegionX = 0
        $iRegionY = 0
        $iRegionWidth = 0
        $iRegionHeight = 0
    EndIf
    If $iLevelStart = Default Then
        $iLevelStart = 0
        $iLevelEnd = 0
    EndIf
    If $iLimit = Default Then
        $iLimit = 0
    EndIf
    If $g_iThreads > 0 And $g_iDMatchingThreads <> $g_iThreads Then
        $g_iDMatchingThreads = $g_iThreads
    Else
        $g_iDMatchingThreads = 32
    EndIf
    ; End Setting Parameters

    If $bForceCapture Then _CaptureRegion2() ; To have FULL screen image to work with

    Local $sResult = DllCallDMatching("Find", "str", "handle", $g_hHBitmap2, "str", $sBundle, "ushort", $iLevelStart, "ushort", $iLevelEnd, "ushort", $iRegionX, "ushort", $iRegionY, "ushort", $iRegionWidth, "ushort", $iRegionHeight, "ushort", $g_iDMatchingThreads, "ushort", $iLimit, "boolean", $g_bDMatchingDebugImages)

    Return $sResult
EndFunc

; Decodes a Match to an Array, $sMatch must be like: Inferno-14-50-50-100-100 . Representing: ObjectName-PointX-PointY-ObjectLevel
Func DMClasicArray($sMatches, $iDis = 18, $bDebugLog = $g_bDebugImageSave)
    Local $aSplittedMatches = StringSplit($sMatches, "|", $STR_NOCOUNT)
    Local $aMatches[UBound($aSplittedMatches)][4], $iRedim = 0
    For $i = 0 To UBound($aSplittedMatches) - 1
        Local $aDecodedMatch = DMDecodeMatch($aSplittedMatches[$i])
        If IsArray($aDecodedMatch) And Not DMduplicated($aMatches, $aDecodedMatch[2], $aDecodedMatch[3], $iRedim, $iDis) Then
            $aMatches[$iRedim][0] = $aDecodedMatch[0]
            $aMatches[$iRedim][1] = $aDecodedMatch[2]
            $aMatches[$iRedim][2] = $aDecodedMatch[3]
            $aMatches[$iRedim][3] = $aDecodedMatch[1]
			$iRedim += 1
        EndIf
    Next
	Redim $aMatches[$iRedim][4]
	If UBound($aMatches) < 1 Then Return -1
	If $bDebugLog Then DebugImgArrayClassic($aMatches)
	Return $aMatches
EndFunc

Func DMduplicated($aXYs, $x1, $y1, $i3, $iD = 18)
	For $i = 0 To $i3
		If Not $g_bRunState Then Return
		If Pixel_Distance($aXYs[$i][1], $aXYs[$i][2], $x1, $y1) < $iD Then Return True
	Next
	Return False
EndFunc   ;==>DMduplicated

Func DebugImgArrayClassic($aAR = 0)
	If $g_hHBitmap2 = 0 Then
		Return
	EndIf
	
	Local $sSubDir = $g_sProfileTempDebugPath & "DMClasicArray"

	DirCreate($sSubDir)

	Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY, $sTime = @HOUR & "." & @MIN & "." & @SEC
	Local $sDebugImageName = String($sDate & "_" & $sTime & "_.png")
	Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hEditedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 1)

	For $i = 0 To UBound($aAR) - 1
		addInfoToDebugImage($hGraphic, $hPenRED, $aAR[$i][0] & "_" & $aAR[$i][3], $aAR[$i][1], $aAR[$i][2])
	Next

	_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $g_sFMQTag & $sDebugImageName )
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($hEditedImage)
	$g_sFMQTag = ""
EndFunc
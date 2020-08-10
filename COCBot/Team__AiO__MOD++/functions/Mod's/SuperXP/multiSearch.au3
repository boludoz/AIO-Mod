; #FUNCTION# ====================================================================================================================
; Name ..........: MultiSearch
; Description ...: This file is all related to necessary Imgloc searchrs Or OCR
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Mr.Viper, Team AIO Mod++ (2019-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getCurrentXP($x_start, $y_start) ; -> Get Current/Total XP, Used in SuperXP.au3
	Return getOcrAndCapture("coc-ms", $x_start, $y_start, 100, 15, True)
EndFunc   ;==>getCurrentXP

Func multiMatchesPixelOnly($directory, $maxReturnPoints = 0, $fullCocAreas = "ECD", $redLines = "", $minLevel = 0, $maxLevel = 1000, $x1 = 0, $y1 = 0, $x2 = $g_iGAME_WIDTH, $y2 = $g_iGAME_HEIGHT, $bCaptureNew = True, $xDiff = Default, $yDiff = Default, $saveSourceImg = False)
	; Setup arrays, including default return values for $return
	Local $sResult = ""
	Local $res

	; Capture the screen for comparison
	If $bCaptureNew Then
		_CaptureRegion2($x1, $y1, $x2, $y2)
		; Perform the search
		$res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $directory, "str", $fullCocAreas, "Int", $maxReturnPoints, "str", $redLines, "Int", $minLevel, "Int", $maxLevel)
		If @error Then _logErrorDLLCall($g_sLibMyBotPath, @error)
		If $saveSourceImg = True Then _GDIPlus_ImageSaveToFile(_GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2), @ScriptDir & "\multiMatchesPixelOnly.png")
		Local $aValue = DllCallMyBot("GetProperty", "str", "redline", "str", "")
		$redLines = $aValue[0]
	Else
		Local $hClone = CloneAreaToSearch($x1, $y1, $x2, $y2)
		$res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $hClone, "str", $directory, "str", $fullCocAreas, "Int", $maxReturnPoints, "str", $redLines, "Int", $minLevel, "Int", $maxLevel)
		If @error Then _logErrorDLLCall($g_sLibMyBotPath, @error)
		If $saveSourceImg = True Then _GDIPlus_ImageSaveToFile(_GDIPlus_BitmapCreateFromHBITMAP($hClone), @ScriptDir & "\multiMatchesPixelOnly.png")
		Local $aValue = DllCallMyBot("GetProperty", "str", "redline", "str", "")
		$redLines = $aValue[0]
		_WinAPI_DeleteObject($hClone)
	EndIf

	If $res[0] <> "" Then
		; Get the keys for the dictionary item.
		Local $aKeys = StringSplit($res[0], "|", $STR_NOCOUNT)

		; Loop through the array
		For $i = 0 To UBound($aKeys) - 1
			$sResult &= RetrieveImglocProperty($aKeys[$i], "objectpoints") & "|"
		Next
	EndIf

	If StringLen($sResult) > 0 Then
		If StringRight($sResult, 1) = "|" Then $sResult = StringLeft($sResult, (StringLen($sResult) - 1))
		If ($xDiff <> Default) Or ($yDiff <> Default) Then
			If $xDiff = Default Then $xDiff = 0
			If $yDiff = Default Then $yDiff = 0

			DelPosWithDiff($sResult, $xDiff, $yDiff, True)

			Return $sResult
		EndIf
	EndIf
	Return $sResult
EndFunc   ;==>multiMatchesPixelOnly

Func CloneAreaToSearch($x, $y, $x1, $y1)
	Local $hClone, $hImage, $iX, $iY, $hBMP
	$iX = $x1 - $x
	$iY = $y1 - $y
	If StringInStr($iX, "-") > 0 Or StringInStr($iY, "-") > 0 Or $iX = 0 Or $iY = 0 Then Return $g_hHBitmap2
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	$hClone = _GDIPlus_BitmapCloneArea($hImage, $x, $y, $iX, $iY)
	$hBMP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hClone)

	 _GDIPlus_BitmapDispose($hImage)
	 _GDIPlus_BitmapDispose($hClone)
	 _WinAPI_DeleteObject($g_hHBitmap2)

	Return $hBMP
EndFunc   ;==>CloneAreaToSearch

; DelPosWithDiff Can be used to delete positions found by multiple images for ONE Object, $Arr Parameter should be 2D Array, [1][2]
Func DelPosWithDiff(ByRef $Input, $xDiff, $yDiff, $ReturnAsString = True, $And = True)
	If IsArray($Input) Then
		_DelPosWithDiff1($Input, $xDiff, $yDiff, $ReturnAsString, $And)
	Else
		_DelPosWithDiff2($Input, $xDiff, $yDiff, $ReturnAsString, $And)
	EndIf
EndFunc

Func _DelPosWithDiff1(ByRef $Arr, $xDiff, $yDiff, $ReturnAsString = True, $And = True)
	Local $iStart = 0
	Local $iXDiff = 0, $iYDiff = 0
	Local $IndexesToDelete = ""
	For $i = $iStart To (UBound($Arr) - 1)
		For $j = $i + 1 To (UBound($Arr) - 1)
			$iXDiff = Number(Abs(Number(Number($Arr[$i][0]) - Number($Arr[$j][0]))))
			$iYDiff = Number(Abs(Number(Number($Arr[$i][1]) - Number($Arr[$j][1]))))
			If $And = True Then
				If ($iXDiff <= $xDiff) And ($iYDiff <= $yDiff) Then
					$IndexesToDelete &= $j & ","
					$i += 1
					ExitLoop
				EndIf
			Else
				If ($iXDiff <= $xDiff) Or ($iYDiff <= $yDiff) Then
					$IndexesToDelete &= $j & ","
					$i += 1
					ExitLoop
				EndIf
			EndIf
			$iXDiff = 0
			$iYDiff = 0
		Next
	Next
	If StringRight($IndexesToDelete, 1) = "," Then $IndexesToDelete = StringLeft($IndexesToDelete, (StringLen($IndexesToDelete) - 1))
	If StringLen($IndexesToDelete) > 0 Then
		Local $tmpArr[UBound($Arr)][2]
		Local $splitedToDelete
		If StringInStr($IndexesToDelete, ",") > 0 Then
			$splitedToDelete = StringSplit($IndexesToDelete, ",", 2)
		Else
			$splitedToDelete = _StringEqualSplit($IndexesToDelete, StringLen($IndexesToDelete))
		EndIf

		Local $searchResult = -1

		For $i = 0 To (UBound($Arr) - 1)
			$searchResult = _ArraySearch($splitedToDelete, $i)
			If $searchResult > -1 And StringLen($splitedToDelete[$searchResult]) > 0 Then ContinueLoop ; If The Array Index Should be Deleted
			$tmpArr[$i][0] = $Arr[$i][0]
			$tmpArr[$i][1] = $Arr[$i][1]
		Next
		_ArryRemoveBlanksMod($tmpArr)
		$Arr = $tmpArr
	EndIf

	If $ReturnAsString = True Then
		Local $ToReturn = ""
		For $k = 0 To (UBound($Arr) - 1)
			$ToReturn &= $Arr[$k][0] & "," & $Arr[$k][1] & "|"
		Next
		If StringRight($ToReturn, 1) = "|" Then $ToReturn = StringLeft($ToReturn, (StringLen($ToReturn) - 1))
		$Arr = $ToReturn
		Return $ToReturn
	EndIf
EndFunc   ;==>_DelPosWithDiff1

Func _DelPosWithDiff2(ByRef $sResult, $xDiff, $yDiff, $ReturnAsString = True, $And = True)
	Local $tmpSplitedPositions
	If StringInStr($sResult, "|") > 0 Then
		$tmpSplitedPositions = StringSplit($sResult, "|", 2)
	Else
		$tmpSplitedPositions = _StringEqualSplit($sResult, StringLen($sResult))
	EndIf
	Local $splitedPositions[UBound($tmpSplitedPositions)][2]
	For $j = 0 To (UBound($tmpSplitedPositions) - 1)
		If StringInStr($tmpSplitedPositions[$j], ",") Then
			$splitedPositions[$j][0] = StringSplit($tmpSplitedPositions[$j], ",", 2)[0]
			$splitedPositions[$j][1] = StringSplit($tmpSplitedPositions[$j], ",", 2)[1]
		EndIf
	Next

	Local $Arr = $splitedPositions

	Local $iStart = 0
	Local $iXDiff = 0, $iYDiff = 0
	Local $IndexesToDelete = ""
	For $i = $iStart To (UBound($Arr) - 1)
		For $j = $i + 1 To (UBound($Arr) - 1)
			$iXDiff = Number(Abs(Number(Number($Arr[$i][0]) - Number($Arr[$j][0]))))
			$iYDiff = Number(Abs(Number(Number($Arr[$i][1]) - Number($Arr[$j][1]))))
			If $And = True Then
				If ($iXDiff <= $xDiff) And ($iYDiff <= $yDiff) Then
					$IndexesToDelete &= $j & ","
					$i += 1
					ExitLoop
				EndIf
			Else
				If ($iXDiff <= $xDiff) Or ($iYDiff <= $yDiff) Then
					$IndexesToDelete &= $j & ","
					$i += 1
					ExitLoop
				EndIf
			EndIf
			$iXDiff = 0
			$iYDiff = 0
		Next
	Next
	If StringRight($IndexesToDelete, 1) = "," Then $IndexesToDelete = StringLeft($IndexesToDelete, (StringLen($IndexesToDelete) - 1))
	If StringLen($IndexesToDelete) > 0 Then
		Local $tmpArr[UBound($Arr)][2]
		Local $splitedToDelete
		If StringInStr($IndexesToDelete, ",") > 0 Then
			$splitedToDelete = StringSplit($IndexesToDelete, ",", 2)
		Else
			$splitedToDelete = _StringEqualSplit($IndexesToDelete, StringLen($IndexesToDelete))
		EndIf

		Local $searchResult = -1

		For $i = 0 To (UBound($Arr) - 1)
			$searchResult = _ArraySearch($splitedToDelete, $i)
			If $searchResult > -1 And StringLen($splitedToDelete[$searchResult]) > 0 Then ContinueLoop ; If The Array Index Should be Deleted
			$tmpArr[$i][0] = $Arr[$i][0]
			$tmpArr[$i][1] = $Arr[$i][1]
		Next
		_ArryRemoveBlanksMod($tmpArr)
		$Arr = $tmpArr
	EndIf

	If $ReturnAsString = True Then
		Local $ToReturn = ""
		For $k = 0 To (UBound($Arr) - 1)
			$ToReturn &= $Arr[$k][0] & "," & $Arr[$k][1] & "|"
		Next
		If StringRight($ToReturn, 1) = "|" Then $ToReturn = StringLeft($ToReturn, (StringLen($ToReturn) - 1))
		$sResult = $ToReturn
		Return $ToReturn
	EndIf

	Return $Arr
EndFunc   ;==>_DelPosWithDiff2

Func _ArryRemoveBlanksMod(ByRef $Array)
	Switch (UBound($Array, 2) > 0) ; If Array Is 2D Array
		Case True
			Local $canKeep = True
			Local $2DBound = UBound($Array, 2)
			Local $Counter = 0
			For $i = 0 To (UBound($Array) - 1)
				For $j = 0 To (UBound($Array, 2) - 1)
					If $Array[$i][$j] = "" Then
						$canKeep = False
					Else
						$canKeep = True
						ExitLoop
					EndIf
				Next
				If $canKeep = True Then
					For $j = 0 To (UBound($Array, 2) - 1)
						$Array[$Counter][$j] = $Array[$i][$j]
					Next
					$Counter += 1
				EndIf
			Next
			ReDim $Array[$Counter][$2DBound]
		Case Else
			Local $Counter = 0
			For $i = 0 To (UBound($Array) - 1)
				If $Array[$i] <> "" Then
					$Array[$Counter] = $Array[$i]
					$Counter += 1
				EndIf
			Next
			ReDim $Array[$Counter]
	EndSwitch
EndFunc   ;==>_ArryRemoveBlanks

Func _StringEqualSplit($sString, $iNumChars = Default)
	If $iNumChars = Default Then $iNumChars = StringLen($sString)
	If Not IsString($sString) Or $sString = "" Then Return SetError(1, 0, 0)
	If Not IsInt($iNumChars) Or $iNumChars < 1 Then Return SetError(2, 0, 0)
	Return StringRegExp($sString, "(?s).{1," & $iNumChars & "}", 3)
EndFunc   ;==>_StringEqualSplit

Func _ArrayMerge(ByRef $a_base, ByRef $a_add, $i_start = 0)
	Local $X
	For $X = $i_start To UBound($a_add) - 1
		_ArrayAdd($a_base, $a_add[$X], 0, "|", @CRLF, $ARRAYFILL_FORCE_STRING)
	Next
EndFunc   ;==>_ArrayMerge

Func _ArrayClear(ByRef $aArray)
    Local $iCols = UBound($aArray, 2)
    Local $iDim = UBound($aArray, 0)
    Local $iRows = UBound($aArray, 1)
    If $iDim = 1 Then
        Local $aArray1D[$iRows]
        $aArray = $aArray1D
    Else
        Local $aArray2D[$iRows][$iCols]
        $aArray = $aArray2D
    EndIf
EndFunc   ;==>_ArrayClear
; #FUNCTION# ====================================================================================================================
; Name ..........: GetVillageSize
; Description ...: Measures the size of village. After CoC October 2016 update, max'ed zoomed out village is 440 (reference!)
;                  But usually sizes around 470 - 490 pixels are measured due to lock on max zoom out.
; Syntax ........: GetVillageSize()
; Parameters ....:
; Return values .: 0 if not identified or Array with index
;                      0 = Size of village (float)
;                      1 = Zoom factor based on 440 village size (float)
;                      2 = X offset of village center (int)
;                      3 = Y offset of village center (int)
;                      4 = X coordinate of stone
;                      5 = Y coordinate of stone
;                      6 = stone image file name
;                      7 = X coordinate of tree
;                      8 = Y coordinate of tree
;                      9 = tree image file name
; Author ........: Cosote (Oct 17th 2016)
; Modified ......: xbebenk (June 2022)
; Removed Fix village measurement if using shared_prefs as I dont know how it works :(
; Change the logic for measure village size, zoomlevel now measured from tree to stone
; And then compare it with Reference size
; All scenery (as this code modified: 01 June 2022) is supported
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func GetVillageSize($DebugLog = Default, $sStonePrefix = Default, $sTreePrefix = Default, $sFixedPrefix = Default, $bOnBuilderBase = Default, $bCaptureRegion = Default, $bDebugWithImage = False) ; Capture region spam disabled - Team AIO Mod++
	FuncEnter(GetVillageSize)
	Local $stone = [0, 0, 0, 0, 0, ""], $tree = [0, 0, 0, 0, 0, ""]
	If $DebugLog = Default Then $DebugLog = False
	If $sStonePrefix = Default Then $sStonePrefix = "stone"
	If $sTreePrefix = Default Then $sTreePrefix = "tree"
	If $bCaptureRegion = Default Then $bCaptureRegion = True

	If $bCaptureRegion = True Then
		_CaptureRegion2()
	EndIf

	If $bOnBuilderBase = Default Then
		$bOnBuilderBase = isOnBuilderBase(False, True)
	EndIf

	Local $sDirectory
	If $bOnBuilderBase Then
		$sDirectory = $g_sImgZoomOutDirBB
	Else
		$sDirectory = $g_sImgZoomOutDir
	EndIf

	Local $iAdditionalX = 250
	Local $iAdditionalY = 205
	Local $aResult = 0, $x, $y

	$stone = FindStone($sDirectory, $sStonePrefix, $iAdditionalX, $iAdditionalY, $bCaptureRegion)

	Local $iError = 0
	If UBound($stone) > 3 And not @error And $stone[0] = 0 Then
		$tree = FindTree($sDirectory, $sTreePrefix, $iAdditionalX, $iAdditionalY, "", $bCaptureRegion)
		$iError = @error
		If $iError = 2 Then Return SetError($iError, 0, $tree)
	Else
		$tree = FindTree($sDirectory, $sTreePrefix, $iAdditionalX, $iAdditionalY, $stone[4], $bCaptureRegion)
		$iError = @error
		If $iError = 2 Then Return SetError($iError, 0, $tree)
	EndIf

	If $stone[0] = 0 Then
		SetDebugLog("GetVillageSize cannot find stone", $COLOR_WARNING)
		; Return FuncReturn($aResult)
	Else
		SetDebugLog("stone: " & _ArrayToString($stone))
	EndIf

	Local $iX_Exp = 0
	Local $iY_Exp = 0
	Local $z = 1	; for centering only
	Local $c = 0	; for centering only
	Local $a = 0, $b = 0, $iRefSize = 0
	Local $iIndex = -1

	If $tree[0] = 0 Then
		SetDebugLog("GetVillageSize cannot find tree", $COLOR_ACTION)
		; Return FuncReturn($aResult)
	Else
		SetDebugLog("tree: " & _ArrayToString($tree))

		; calculate village size, see https://en.wikipedia.org/wiki/Pythagorean_theorem
		$a = $tree[0] - $stone[0]
		$b = $stone[1] - $tree[1]
		$c = Sqrt($a * $a + $b * $b) ;measure distance from stone to tree

		$iRefSize = 600
		$iIndex = _ArraySearch($g_aVillageRefSize, $stone[4])
		If $iIndex = -1 Then
			$iIndex = 0
			SetLog("Reference Size no match", $COLOR_ERROR)
			; Return FuncReturn($aResult)
		EndIf

		$iRefSize = $g_aVillageRefSize[$iIndex][2]
		$g_sSceneryCode = $g_aVillageRefSize[$iIndex][0]
		$g_sCurrentScenery = $g_aVillageRefSize[$iIndex][1]
		$InnerDiamondLeft = $g_aVillageRefSize[$iIndex][3]
		$InnerDiamondRight = $g_aVillageRefSize[$iIndex][4]
		$InnerDiamondTop = $g_aVillageRefSize[$iIndex][5]
		$InnerDiamondBottom = $g_aVillageRefSize[$iIndex][6]
		SetDebugLog("LRTB: " & $InnerDiamondLeft & "," & $InnerDiamondRight & "," & $InnerDiamondTop & "," & $InnerDiamondBottom)

	EndIf


	; Failed to locate Stone Or Tree ; zoom out
	If $stone[0] = 0 And $tree[0] = 0 Then
		SetLog("GetVillageSize cannot find stone or tree", $COLOR_WARNING)
		Return FuncReturn($aResult)
	ElseIf $stone[0] = 0 And $tree[0] > 0 Then ; calculate offset using trees
		$iX_Exp = $tree[2]
		$iY_Exp = $tree[3]
		ConvertVillagePos($iX_Exp, $iY_Exp, $z)
		$x = $tree[0] - $iX_Exp
		$y = $tree[1] - $iY_Exp
		SetLog("Found Tree! Offset : " & $x & ", " & $y, $COLOR_INFO)
	ElseIf $tree[0] = 0 And $stone[0] > 0 Then ; calculate offset using stone
		$iX_Exp = $stone[2]
		$iY_Exp = $stone[3]
		ConvertVillagePos($iX_Exp, $iY_Exp, $z)
		$x = $stone[0] - $iX_Exp
		$y = $stone[1] - $iY_Exp
		SetLog("Found Stone! Offset : " & $x & ", " & $y, $COLOR_INFO)
	Else
		$z = $c / $iRefSize
		
		; calculate village size, see https://en.wikipedia.org/wiki/Pythagorean_theorem
		$a = $tree[0] - $stone[0]
		$b = $stone[1] - $tree[1]
		$c = Sqrt($a * $a + $b * $b) - $stone[4] - $tree[4]

		Local $stone_x_exp = $stone[2]
		Local $stone_y_exp = $stone[3]
		ConvertVillagePos($stone_x_exp, $stone_y_exp, $z) ; expected x, y position of stone
		$x = $stone[0] - $stone_x_exp
		$y = $stone[1] - $stone_y_exp

		SetDebugLog("Found Stone and Tree!", $COLOR_INFO);
		SetDebugLog("Scenery : " & $g_sCurrentScenery, $COLOR_INFO)
		SetDebugLog("Reference : " & $iRefSize)
		SetDebugLog("Village Size : " & $c, $COLOR_INFO)
		SetDebugLog("Zoom Factor : " & $z, $COLOR_INFO)
		SetDebugLog("Offset : " & $x & ", " & $y, $COLOR_INFO)
		If $DebugLog Then SetDebugLog("GetVillageSize measured: " & $c & ", Zoom factor: " & $z & ", Offset: " & $x & ", " & $y, $COLOR_INFO)
	EndIf

	Local $aResult[11]
	$aResult[0] = Round($c, 5)
	$aResult[1] = Round($z, 5)
	$aResult[2] = $x
	$aResult[3] = $y
	$aResult[4] = $stone[0]
	$aResult[5] = $stone[1]
	$aResult[6] = $stone[5]
	$aResult[7] = $tree[0]
	$aResult[8] = $tree[1]
	$aResult[9] = $tree[5]
	$aResult[10] = $iRefSize

	$g_aVillageSize = $aResult

	Return FuncReturn($aResult)
EndFunc   ;==>GetVillageSize

Func FindStone($sDirectory = $g_sImgZoomOutDir, $sStonePrefix = "stone", $iAdditionalX = 100, $iAdditionalY = 100, $bCaptureRegion = True)
	Local $stone = [0, 0, 0, 0, 0, ""]
	Local $x0, $y0, $d0, $x, $y, $x1, $y1, $right, $bottom, $a, $b
	Local $aStoneFiles

	For $check = 1 To 2
		If $check = 1 Then
			SetDebugLog("Checking for same scenery: " & $g_sSceneryCode)
			$aStoneFiles = _FileListToArray($sDirectory & "stone\", $sStonePrefix & "*" & $g_sSceneryCode & "*.*", $FLTA_FILES)
		Else
			$aStoneFiles = _FileListToArray($sDirectory & "stone\", $sStonePrefix & "*.*", $FLTA_FILES)
		EndIf

		If @error Then
			SetDebugLog("Error: Missing stone files (" & @error & ")", $COLOR_ERROR)
			ContinueLoop
		EndIf

		Local $i, $findImage, $sArea, $StoneName, $aiCorrection[4]
		For $i = 1 To $aStoneFiles[0]
			$findImage = $aStoneFiles[$i]
			$a = StringRegExp($findImage, "stone([0-9A-Z]+)-(\d+)-(\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
			If UBound($a) = 4 Then
				$StoneName = $a[0]
				$d0 = $StoneName
				$x0 = $a[1]
				$y0 = $a[2]

				$aiCorrection[0] = _Max($x0 - $iAdditionalX, 0)
				$aiCorrection[1] = _Max($y0 - $iAdditionalY, 45)
				$aiCorrection[2] = _Min($x0 + Abs($aiCorrection[0] - Abs($x0 - $iAdditionalX)) + $iAdditionalX, $g_iGAME_WIDTH)
				$aiCorrection[3] = _Min($y0 + Abs($aiCorrection[1] - Abs($y0 - $iAdditionalX)) + $iAdditionalY, $g_iGAME_HEIGHT)

				$x1 = $aiCorrection[0]
				$y1 = $aiCorrection[1]
				$right = $aiCorrection[2]
                $bottom = $aiCorrection[3]

				$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
				SetDebugLog("GetVillageSize check for image " & $findImage)
				$b = decodeSingleCoord(findImage("stone" & $StoneName, $sDirectory & "stone\" & $findImage, $sArea, 1, $bCaptureRegion))
				If UBound($b) = 2 Then
					$x = Int($b[0])
					$y = Int($b[1])
					SetDebugLog("Found stone image at " & $x & ", " & $y & ": " & $findImage, $COLOR_INFO)
					$stone[0] = $x ; x center of stone found
					$stone[1] = $y ; y center of stone found
					$stone[2] = $x0 ; x center of reference stone
					$stone[3] = $y0 ; y center of reference stone
					$stone[4] = $d0 ; distance from stone to tree in pixel
					$stone[5] = $findImage
					ExitLoop 2
				EndIf
			Else
				SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
			EndIf
		Next
	Next
	Return $stone
EndFunc

Func FindTree($sDirectory = $g_sImgZoomOutDir, $sTreePrefix = "tree", $iAdditionalX = 100, $iAdditionalY = 100, $sStoneName = "DS", $bCaptureRegion = True)
	Local $tree = [0, 0, 0, 0, 0, ""]
	Local $x0, $y0, $d0, $x, $y, $x1, $y1, $right, $bottom, $a, $b, $i, $findImage, $sArea
	Local $aTreeFiles = _FileListToArray($sDirectory & "tree\", $sTreePrefix & "*.*", $FLTA_FILES)
	If @error Then
		SetLog("Error: Missing tree (" & @error & ")", $COLOR_ERROR)
		Return SetError(2, 0, $tree)
	EndIf

	Local $scenerycode = "tree" & "*" & $sStoneName, $aiCorrection[4]
	For $i = 1 To $aTreeFiles[0]
		$findImage = $aTreeFiles[$i]
		If StringRegExp($findImage, $scenerycode, $STR_REGEXPMATCH) <> 1 Then ; if stone found is DS, filter only DS tree
			;SetDebugLog("Image skipped: " & $findImage)
			ContinueLoop
		EndIf
		$a = StringRegExp($findImage, "(tree[0-9A-Z]+)-(\d+)-(\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
		If UBound($a) = 4 Then
			$x0 = $a[1]
			$y0 = $a[2]
			$d0 = "notused"

			$aiCorrection[1] = _Max($y0 - $iAdditionalY, 45)
			$aiCorrection[2] = _Min($x0 + $iAdditionalX, $g_iGAME_WIDTH)
			$aiCorrection[3] = _Min($y0 + Abs($aiCorrection[1] - Abs($y0 - $iAdditionalY)) + $iAdditionalY, $g_iGAME_HEIGHT)
			$aiCorrection[0] = _Max($x0 - Abs($aiCorrection[2] - Abs($x0 + $iAdditionalX)) - $iAdditionalX, 0)

			$x0 = $aiCorrection[0]
			$y0 = $aiCorrection[1]
			$right = $aiCorrection[2]
            $bottom = $aiCorrection[3]

			$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
			SetDebugLog("GetVillageSize check for image " & $findImage)
			$b = decodeSingleCoord(findImage($scenerycode, $sDirectory & "tree\" & $findImage, $sArea, 1, $bCaptureRegion))
			; sort by x because there can be a 2nd at the right that should not be used
			If UBound($b) = 2 Then
				$x = Int($b[0])
				$y = Int($b[1])
				SetDebugLog("Found tree image at " & $x & ", " & $y & ": " & $findImage, $COLOR_INFO)
				$tree[0] = $x ; x center of tree found
				$tree[1] = $y ; y center of tree found
				$tree[2] = $x0 ; x ref. center of tree
				$tree[3] = $y0 ; y ref. center of tree
				$tree[4] = $d0 ; distance from stone to tree in pixel
				$tree[5] = $findImage
				ExitLoop
			EndIf

		Else
			SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
		EndIf
	Next
	Return $tree
EndFunc

Func UpdateGlobalVillageOffset($x, $y)

	Local $updated = False

	If $g_sImglocRedline <> "" Then

		Local $newReadLine = ""
		Local $aPoints = StringSplit($g_sImglocRedline, "|", $STR_NOCOUNT)

		For $sPoint In $aPoints

			Local $aPoint = GetPixel($sPoint, ",")
			$aPoint[0] += $x
			$aPoint[1] += $y

			If StringLen($newReadLine) > 0 Then $newReadLine &= "|"
			$newReadLine &= ($aPoint[0] & "," & $aPoint[1])

		Next

		; set updated red line
		$g_sImglocRedline = $newReadLine

		$updated = True
	EndIf

	If $g_aiTownHallDetails[0] <> 0 And $g_aiTownHallDetails[1] <> 0 Then
		$g_aiTownHallDetails[0] += $x
		$g_aiTownHallDetails[1] += $y
		$updated = True
	EndIf
	If $g_iTHx <> 0 And $g_iTHy <> 0 Then
		$g_iTHx += $x
		$g_iTHy += $y
		$updated = True
	EndIf

	ConvertInternalExternArea()

	Return $updated

EndFunc   ;==>UpdateGlobalVillageOffset

Func DetectScenery($stone = "None")
	Local $sScenery = ""
	Local $iIndex = 0
	Local $a = StringRegExp($stone, "stone([0-9A-Z]+)", $STR_REGEXPARRAYMATCH)
	If IsArray($a) Then
		$iIndex = _ArraySearch($g_aVillageRefSize, $a[0])
		$sScenery = $g_aVillageRefSize[$iIndex][1]
	Else
		$sScenery = "Failed scenery detection"
	EndIf

	Return $sScenery
EndFunc

; Based on grumpy mod
Func CenterVillage($iX, $iY, $iOffsetX, $iOffsetY, $bLayOut = False)
	Local $aScrollPos[2] = [0, 0]

	; If IsCoordSafe($iX, $iY) Then
		; $aScrollPos[0] = $iX
		; $aScrollPos[1] = $iY
	; Else
		$aScrollPos[0] = $aCenterHomeVillageClickDrag[0]
		$aScrollPos[1] = $aCenterHomeVillageClickDrag[1]
	; EndIf

	If $g_bDebugSetlog Then SetDebugLog("CenterVillage at point : " & $aScrollPos[0] & ", " & $aScrollPos[1] & " Offset : " & $iOffsetX & ", " & $iOffsetY, $COLOR_INFO)
 	If $g_bDebugImageSave Then SaveDebugPointImage("CenterVillage", $aScrollPos)
	ClickAway()
	Local $iOffsetXFixed = _Max($iOffsetX, Random(95, 100, 1))
	If $bLayOut = True Then
		; It is like grumpy mod but the X offset is inverted in tree case
		ClickDrag($aScrollPos[0], $aScrollPos[1], $aScrollPos[0] + $iOffsetXFixed, $aScrollPos[1] - $iOffsetY)
	Else
		; 57, -75
		ClickDrag($aScrollPos[0], $aScrollPos[1], $aScrollPos[0] - $iOffsetXFixed, $aScrollPos[1] - $iOffsetY)
	EndIf
	If _Sleep(1000) Then Return
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: ImgFuncs.au3
; Description ...: Avoid loss of functions during updates.
; Author ........: Boludoz (2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func _ImageSearchXML($sDirectory, $iQuantity2Match = 0, $saiArea2SearchOri = "0,0,860,732", $bForceCapture = True, $bDebugLog = False, $bCheckDuplicatedpoints = False, $iDistance2check = 25, $iLevel = 0)
	FuncEnter(_ImageSearchXML)
	$g_aImageSearchXML = -1
	
	; It does not support only 1 search.
	Local $iMatchInteral = $iQuantity2Match
	If $iQuantity2Match = 1 Then $iMatchInteral += 1
	
	Local $sSearchDiamond = GetDiamondFromRect($saiArea2SearchOri)
	Local $aResult = findMultiple($sDirectory, $sSearchDiamond, $sSearchDiamond, $iLevel, 1000, $iMatchInteral, "objectname,objectlevel,objectpoints", $bForceCapture)
	If Not IsArray($aResult) Then Return -1

	Local $iCount = 0

	; Compatible with BuilderBaseBuildingsDetection()[old function] same return array
	; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
	Local $aAllResults[0][4]

	Local $aArrays = "", $aCoords, $aCommaCoord

	For $i = 0 To UBound($aResult) - 1
		$aArrays = $aResult[$i] ; should be return objectname,objectpoints,objectlevel
		$aCoords = StringSplit($aArrays[2], "|", 2)
		For $iCoords = 0 To UBound($aCoords) - 1
			$aCommaCoord = StringSplit($aCoords[$iCoords], ",", 2)
			; Inspired in Chilly-chill
			Local $aTmpResults[1][4] = [[$aArrays[0], Int($aCommaCoord[0]), Int($aCommaCoord[1]), Int($aArrays[1])]]
			_ArrayAdd($aAllResults, $aTmpResults)
		Next
		$iCount += 1
		If ($iQuantity2Match < 0) And ($iCount <= $iQuantity2Match) Then ExitLoop
	Next
	;If $iCount < 1 Then Return -1 what

	If $bCheckDuplicatedpoints And UBound($aAllResults) > 0 Then
		; Sort by X axis
		_ArraySort($aAllResults, 0, 0, 0, 1)

		; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
		Local $iD2Check = $iDistance2check

		; check if is a double Detection, near in 10px
		For $i = 0 To UBound($aAllResults) - 1
			If $i > UBound($aAllResults) - 1 Then ExitLoop
			Local $aLastCoordinate[4] = [$aAllResults[$i][0], $aAllResults[$i][1], $aAllResults[$i][2], $aAllResults[$i][3]]
			If $g_bDebugSetlog Then SetDebugLog("Coordinate to Check: " & _ArrayToString($aLastCoordinate))
			If UBound($aAllResults) > 1 Then
				For $j = 0 To UBound($aAllResults) - 1
					If $j > UBound($aAllResults) - 1 Then ExitLoop
					; If $g_bDebugSetlog Then SetDebugLog("$j: " & $j)
					; If $g_bDebugSetlog Then SetDebugLog("UBound($aAllResults) -1: " & UBound($aAllResults) - 1)
					Local $aSingleCoordinate[4] = [$aAllResults[$j][0], $aAllResults[$j][1], $aAllResults[$j][2], $aAllResults[$j][3]]
					; If $g_bDebugSetlog Then SetDebugLog(" - Comparing with: " & _ArrayToString($aSingleCoordinate))
					If $aLastCoordinate[1] <> $aSingleCoordinate[1] Or $aLastCoordinate[2] <> $aSingleCoordinate[2] Then
						If $aSingleCoordinate[1] < $aLastCoordinate[1] + $iD2Check And $aSingleCoordinate[1] > $aLastCoordinate[1] - $iD2Check Then
							; If $g_bDebugSetlog Then SetDebugLog(" - removed : " & _ArrayToString($aSingleCoordinate))
							_ArrayDelete($aAllResults, $j)
						EndIf
					Else
						If $aLastCoordinate[1] = $aSingleCoordinate[1] And $aLastCoordinate[2] = $aSingleCoordinate[2] And $aLastCoordinate[3] <> $aSingleCoordinate[3] Then
							; If $g_bDebugSetlog Then SetDebugLog(" - removed equal level : " & _ArrayToString($aSingleCoordinate))
							_ArrayDelete($aAllResults, $j)
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf

	If (UBound($aAllResults) > 0) Then
		If ($g_bDebugImageSave Or $bDebugLog) Then ; Discard Deploy Points Touch much text on image
			_CaptureRegion2()

			Local $sSubDir = $g_sProfileTempDebugPath & "_ImageSearchXML"

			DirCreate($sSubDir)

			Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY, $sTime = @HOUR & "." & @MIN & "." & @SEC
			Local $sDebugImageName = String($sDate & "_" & $sTime & "_.png")
			Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
			Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hEditedImage)
			Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 3)

			For $i = 0 To UBound($aAllResults) - 1
				addInfoToDebugImage($hGraphic, $hPenRED, $aAllResults[$i][0] & "_" & $aAllResults[$i][3], $aAllResults[$i][1], $aAllResults[$i][2])
			Next

			_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $sDebugImageName)
			_GDIPlus_PenDispose($hPenRED)
			_GDIPlus_GraphicsDispose($hGraphic)
			_GDIPlus_BitmapDispose($hEditedImage)
		EndIf
		
		;_ArrayDisplay($aAllResults)
		$g_aImageSearchXML = $aAllResults
		Return $aAllResults
	Else
		$g_aImageSearchXML = -1
		Return -1
	EndIf
EndFunc   ;==>_ImageSearchXML

Func findMultipleQuick($sDirectory, $iQuantityMatch = Default, $vArea2SearchOri = Default, $bForceCapture = True, $sOnlyFind = Default, $bExactFind = Default, $iDistance2check = 25, $bDebugLog = False)
	FuncEnter(findMultipleQuick)
	$g_aImageSearchXML = -1
	Local $aAR[0][4]
	Local $minLevel = 0, $maxLevel = 1000 = 0, $iCount = 0, $returnProps = "objectname,objectlevel,objectpoints"
	Local $error, $extError
	
	Local $iQuantToMach, $iQuantity2Match

	Local $bDefa = ($sOnlyFind = Default)
	If ($iQuantityMatch = Default) Then $iQuantityMatch = 0
	If $bForceCapture = Default Then $bForceCapture = True
	If $vArea2SearchOri = Default Then $vArea2SearchOri = "FV"
	If (IsArray($vArea2SearchOri)) Then
		$vArea2SearchOri = GetDiamondFromArray($vArea2SearchOri)
	Else
		Switch UBound(StringSplit($vArea2SearchOri, ",", $STR_NOCOUNT))
			Case 4
				$vArea2SearchOri = GetDiamondFromRect($vArea2SearchOri)
			Case 0, 5
				$vArea2SearchOri = $vArea2SearchOri
		EndSwitch
	EndIf
	
	If $iQuantityMatch <> 1 Then
		$iQuantity2Match = ($iQuantityMatch = Default) ? (0) : ($iQuantityMatch)
	Else
		$iQuantity2Match = 2
	EndIf
	
	$sOnlyFind = ($sOnlyFind = Default) ? ("") : ($sOnlyFind)
	$iQuantToMach = ($sOnlyFind = Default) ? ($iQuantity2Match) : (20)
	Local $bIsDir = True
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	If Not IsDir($sDirectory) Then 
		$bIsDir = False
		Local $aPathSplit = _PathSplit($sDirectory, $sDrive, $sDir, $sFileName, $sExtension)
		If Not StringIsSpace($sFileName) Then
			$bExactFind = -1
			$sOnlyFind = ""
			$sDirectory = $sDrive & $sDir
			$iQuantToMach = 0
		EndIf
	EndIf

	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT)
	Local $returnLine[UBound($returnData)]
	Local $returnValues[0]

	; Capture the screen for comparison
	; Perform the search
	If $bForceCapture Then _CaptureRegion2() ;to have FULL screen image to work with

	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantToMach, "str", $vArea2SearchOri, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		If $g_bDebugSetlog Then SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return -1
	EndIf

	If checkImglocError($result, "findMultipleQuick", $sDirectory) = True Then
		If $g_bDebugSetlog Then SetDebugLog("findMultipleQuick Returned Error or No values : ", $COLOR_DEBUG)
		Return -1
	EndIf

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT)
;	_ArrayDisplay($resultArr, 1)
	If Not $bDefa And $bIsDir Then
		If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick multiples **** ", $COLOR_ORANGE)
		Local $aof = StringSplit($sOnlyFind, "|")
		If CompKick($resultArr, $aof, $bExactFind) Then
			If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick has no result **** ", $COLOR_ORANGE)
			$returnValues = -1
			Return -1
		EndIf
	ElseIf Not $bIsDir Then
		If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick one **** ", $COLOR_ORANGE)
		Local $iIsA = __ArraySearch($resultArr, $sFileName & $sExtension)
		If $iIsA <> -1 Then 
			Local $resultArr[1] = [String($sFileName & $sExtension)]
			If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick " & $resultArr[0] & " **** ", $COLOR_ORANGE)
		Else
			If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick only one has no result **** ", $COLOR_ORANGE)
			Return -1
		EndIf
	EndIf
;	_ArrayDisplay($resultArr, 2)

	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				; Inspired in Chilly-chill
				Local $aC = StringSplit($returnLine[2], "|", $STR_NOCOUNT)
				For $sXY In $aC
					Local $aXY = StringSplit($sXY, ",", $STR_NOCOUNT)
					If UBound($aXY) <> 2 Then ContinueLoop 3
					Local $aTmpResults[1][4] = [[$returnLine[0], Int($aXY[0]), Int($aXY[1]), Int($returnLine[1])]]
					_ArrayAdd($aAR, $aTmpResults)
					$iCount += 1
					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then ExitLoop 3
				Next
			EndIf
		Next
	Next
	
	If $iDistance2check > 0 And UBound($aAR) > 1 Then

		; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
		Local $iD2C = $iDistance2check

		; check if is a double Detection.
		For $i = 0 To UBound($aAR) - 1
			If $i > UBound($aAR) - 1 Then ExitLoop
			Local $aLC = [$aAR[$i][0], $aAR[$i][1], $aAR[$i][2], $aAR[$i][3]]
			If UBound($aAR) > 1 Then
				For $j = 0 To UBound($aAR) - 1
					If $j > UBound($aAR) - 1 Then ExitLoop
					Local $aSC[4] = [$aAR[$j][0], $aAR[$j][1], $aAR[$j][2], $aAR[$j][3]]
					If $aLC[1] <> $aSC[1] Or $aLC[2] <> $aSC[2] Then
						If Abs(Pixel_Distance($aSC[1], $aSC[2], $aLC[1], $aLC[2])) < $iD2C Then _ArrayDelete($aAR, $j)
					Else
						If $aLC[1] = $aSC[1] And $aLC[2] = $aSC[2] And ($aLC[3] <> $aSC[3] Or $aLC[0] <> $aSC[0]) Then _ArrayDelete($aAR, $j)
					EndIf
				Next
			EndIf
		Next
	EndIf
	
	If (UBound($aAR) > 0) Then
		If ($g_bDebugImageSave Or $bDebugLog) Then ; Discard Deploy Points Touch much text on image
			_CaptureRegion2()

			Local $sSubDir = $g_sProfileTempDebugPath & "findMultipleQuick"

			DirCreate($sSubDir)

			Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY, $sTime = @HOUR & "." & @MIN & "." & @SEC
			Local $sDebugImageName = String($sDate & "_" & $sTime & "_.png")
			Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
			Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hEditedImage)
			Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 3)

			For $i = 0 To UBound($aAR) - 1
				addInfoToDebugImage($hGraphic, $hPenRED, $aAR[$i][0] & "_" & $aAR[$i][3], $aAR[$i][1], $aAR[$i][2])
			Next

			_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $sDebugImageName)
			_GDIPlus_PenDispose($hPenRED)
			_GDIPlus_GraphicsDispose($hGraphic)
			_GDIPlus_BitmapDispose($hEditedImage)
		EndIf
		
		;_ArrayDisplay($aAR)
		$g_aImageSearchXML = $aAR
		Return $aAR
	Else
		$g_aImageSearchXML = -1
		Return -1
	EndIf
EndFunc   ;==>findMultipleQuick

Func CompKick(ByRef $vFiles, $aof, $bType = -1)
	If (IsArray($aof) And StringIsSpace($aof[0])) Then Return False
	Local $aRS[0]
	
	If IsArray($vFiles) And IsArray($aof) And ($bType <> -1) Then
		SetDebugLog(_ArrayToString($aof))
		If $bType Then
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringMid($s2, 1, $i2s) = $s Then _ArrayAdd($aRS, $s2)
				Next
			Next
		Else
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringMid($s2, 1, $i2s) == $s Then _ArrayAdd($aRS, $s2)
				Next
			Next
		EndIf
	EndIf
	$vFiles = $aRS
	Return (UBound($vFiles) = 0)
EndFunc   ;==>CompKick

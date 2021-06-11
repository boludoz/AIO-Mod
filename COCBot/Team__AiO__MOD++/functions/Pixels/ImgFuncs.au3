; #FUNCTION# ====================================================================================================================
; Name ..........: ImgFuncs.au3
; Description ...: Avoid loss of functions during updates.
; Author ........: Boldina ! (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; _ImageSearchXML("C:\Github\AIOPLUS\imgxml\village\NormalVillage", 0, "FV", True, True, False, 25, 0, 1000)
Func _ImageSearchXML($sDirectory, $iQuantityMatch = 0, $vArea2SearchOri = "FV", $bForceCapture = True, $bDebugLog = False, $bCheckDuplicatedpoints = False, $iDistance2check = 25, $minLevel = 0, $maxLevel = 1000)
	; FuncEnter(_ImageSearchXML)
	$g_aImageSearchXML = -1
	Local $iCount = 0, $returnProps = "objectname,objectlevel,objectpoints"
	Local $error, $extError
	
	If $bForceCapture = Default Then $bForceCapture = True
	If $vArea2SearchOri = Default Then $vArea2SearchOri = "FV"
	
	If (IsArray($vArea2SearchOri)) Then
		$vArea2SearchOri = GetDiamondFromArray($vArea2SearchOri)
	EndIf
	If 3 = ((StringReplace($vArea2SearchOri, ",", ",") <> "") ? (@extended) : (0)) Then
		$vArea2SearchOri = GetDiamondFromRect($vArea2SearchOri)
	EndIf
	
	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT)
	Local $returnLine[UBound($returnData)]

	; Capture the screen for comparison
	If $bForceCapture Then _CaptureRegion2() ;to have FULL screen image to work with

	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantityMatch, "str", $vArea2SearchOri, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		If $g_bDebugSetlog Then SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return -1
	EndIf

	If checkImglocError($result, "_ImageSearchXML", $sDirectory) = True Then
		If $g_bDebugSetlog Then SetDebugLog("_ImageSearchXML Returned Error or No values : ", $COLOR_DEBUG)
		Return -1
	EndIf

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT)
	If $g_bDebugSetlog Then SetDebugLog(" ***  _ImageSearchXML multiples **** ", $COLOR_ORANGE)

	; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
	Local $iD2C = ($bCheckDuplicatedpoints = True) ? ($iDistance2check) : (0)
	Local $aAR[0][4], $aXY
	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				; Inspired in Chilly-chill
				Local $aC = StringSplit($returnLine[2], "|", $STR_NOCOUNT)
				For $i = 0 To UBound($aC) - 1
					$aXY = StringSplit($aC[$i], ",", $STR_NOCOUNT)
					If UBound($aXY) <> 2 Then ContinueLoop 3
					If $iD2C > 0 Then
						If DMduplicated($aAR, Int($aXY[0]), Int($aXY[1]), UBound($aAR)-1, $iD2C) Then
							ContinueLoop
						EndIf
					EndIf
					ReDim $aAR[$iCount + 1][4]
					$aAR[$iCount][0] = $returnLine[0]
					$aAR[$iCount][1] = Int($aXY[0])
					$aAR[$iCount][2] = Int($aXY[1])
					$aAR[$iCount][3] = Int($returnLine[1])
					$iCount += 1
					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then ExitLoop 3
				Next
			EndIf
		Next
	Next
	
	If UBound($aAR) < 1 Then Return -1
	If $bDebugLog Then DebugImgArrayClassic($aAR, "_ImageSearchXML")
	$g_aImageSearchXML = $aAR
	Return $aAR
EndFunc   ;==>_ImageSearchXML

Func CompKick(ByRef $vFiles, $aof, $bType = False)
	If (UBound($aof) = 1) And StringIsSpace($aof[0]) Then Return False
	If $g_bDebugSetlog Then
		SetDebugLog("CompKick : " & _ArrayToString($vFiles))
		SetDebugLog("CompKick : " & _ArrayToString($aof))
		SetDebugLog("CompKick : " & "Exact mode : " & $bType)
	EndIf
	If ($bType = Default) Then $bType = False

	Local $aRS[0]

	If IsArray($vFiles) And IsArray($aof) Then
		If $g_bDebugSetlog Then SetDebugLog("CompKick compare : " & _ArrayToString($vFiles))
		If $bType Then
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringInStr(StringMid($s2, 1, $i2s), $s, 0) = 1 And $i2s = StringLen($s) Then _ArrayAdd($aRS, $s2)
				Next
			Next
		Else
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringInStr(StringMid($s2, 1, $i2s), $s) > 0 Then _ArrayAdd($aRS, $s2)
				Next
			Next
		EndIf
	EndIf
	$vFiles = $aRS
	Return (UBound($vFiles) = 0)
EndFunc   ;==>CompKick
;
Func findMultipleQuick($sDirectory, $iQuantityMatch = Default, $vArea2SearchOri = Default, $bForceCapture = True, $sOnlyFind = "", $bExactFind = False, $iDistance2check = 25, $bDebugLog = $g_bDebugImageSave, $minLevel = 0, $maxLevel = 1000, $vArea2SearchOri2 = Default)
	; FuncEnter(findMultipleQuick)
	$g_aImageSearchXML = -1
	Local $iCount = 0, $returnProps = "objectname,objectlevel,objectpoints"
	
	If $bForceCapture = Default Then $bForceCapture = True
	
	If $vArea2SearchOri = Default Then $vArea2SearchOri = "FV"

	If $iQuantityMatch = Default Then $iQuantityMatch = 0
	If $sOnlyFind = Default Then $sOnlyFind = ""
	Local $bOnlyFindIsSpace = StringIsSpace($sOnlyFind)

	If (IsArray($vArea2SearchOri)) Then
		$vArea2SearchOri = GetDiamondFromArray($vArea2SearchOri)
	EndIf
	If 3 = ((StringReplace($vArea2SearchOri, ",", ",") <> "") ? (@extended) : (0)) Then
		$vArea2SearchOri = GetDiamondFromRect($vArea2SearchOri)
	EndIf

	Local $iQuantToMach = ($bOnlyFindIsSpace = True) ? ($iQuantityMatch) : (0)
	Local $bIsDir = True
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	If Not IsDir($sDirectory) Then
		$bIsDir = False
		Local $aPathSplit = _PathSplit($sDirectory, $sDrive, $sDir, $sFileName, $sExtension)
		If Not StringIsSpace($sFileName) Then
			$bExactFind = False
			$sOnlyFind = ""
			$sDirectory = $sDrive & $sDir
			$iQuantToMach = 0
		EndIf
	EndIf

	If $vArea2SearchOri2 = Default Then 
		$vArea2SearchOri2 = $vArea2SearchOri
	Else
		If (IsArray($vArea2SearchOri2)) Then
			$vArea2SearchOri2 = GetDiamondFromArray($vArea2SearchOri2)
		EndIf
		If 3 = ((StringReplace($vArea2SearchOri2, ",", ",") <> "") ? (@extended) : (0)) Then
			$vArea2SearchOri2 = GetDiamondFromRect($vArea2SearchOri2)
		EndIf		
	EndIf
	
	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT)
	Local $returnLine[UBound($returnData)]

	; Capture the screen for comparison
	If $bForceCapture Then _CaptureRegion2() ;to have FULL screen image to work with

	Local $error, $extError
	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantToMach, "str", $vArea2SearchOri2, "Int", $minLevel, "Int", $maxLevel)
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

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT), $sSlipt = StringSplit($sOnlyFind, "|", $STR_NOCOUNT)
	If Not $bOnlyFindIsSpace And $bIsDir Then
		If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick multiples **** ", $COLOR_ORANGE)
		If CompKick($resultArr, $sSlipt, $bExactFind) Then
			If $g_bDebugSetlog Then SetDebugLog(" ***  findMultipleQuick has no result **** ", $COLOR_ORANGE)
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

	Local $iD2C = $iDistance2check
	Local $aAR[0][4], $aXY
	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				Local $aC = StringSplit($returnLine[2], "|", $STR_NOCOUNT)
				For $i = 0 To UBound($aC) - 1
					$aXY = StringSplit($aC[$i], ",", $STR_NOCOUNT)
					If UBound($aXY) <> 2 Then ContinueLoop 3
					If $iD2C > 0 Then
						If DMduplicated($aAR, Int($aXY[0]), Int($aXY[1]), UBound($aAR)-1, $iD2C) Then
							ContinueLoop
						EndIf
					EndIf
					ReDim $aAR[$iCount + 1][4]
					$aAR[$iCount][0] = $returnLine[0]
					$aAR[$iCount][1] = Int($aXY[0])
					$aAR[$iCount][2] = Int($aXY[1])
					$aAR[$iCount][3] = Int($returnLine[1])
					$iCount += 1
					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then ExitLoop 3
				Next
			EndIf
		Next
	Next
	
	If UBound($aAR) < 1 Then Return -1
	If $bDebugLog Then DebugImgArrayClassic($aAR, "findMultipleQuick")
	$g_aImageSearchXML = $aAR
	Return $aAR
EndFunc   ;==>findMultipleQuick

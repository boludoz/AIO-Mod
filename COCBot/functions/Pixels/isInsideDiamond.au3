; #FUNCTION# ====================================================================================================================
; Name ..........: isInsideDiamondXY, isInsideDiamond
; Description ...: This function can test if a given coordinate is inside (True) or outside (False) the village grass borders (a diamond shape).
;                  It will also exclude some special area's like the CHAT tab, BUILDER button and GEM shop button.
; Syntax ........: isInsideDiamondXY($Coordx, $Coordy), isInsideDiamond($aCoords)
; Parameters ....: ($Coordx, $CoordY) as coordinates or ($aCoords), an array of (x,y) to test
; Return values .: True or False
; Author ........: Hervidero (2015-may-21)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


Func isInsideDiamondXY($Coordx, $Coordy)

	Local $aCoords = [$Coordx, $Coordy]
	Return isInsideDiamond($aCoords)

EndFunc   ;==>isInsideDiamondXY

Func isInsideDiamond($aCoords)
	Local $x = $aCoords[0], $y = $aCoords[1], $xD, $yD
	
	; xbebenk - Team AIO Mod++
	Static $sLastCode = $g_aVillageRefSize[0][0]
	Static $Left = $g_aVillageRefSize[0][3], $Right = $g_aVillageRefSize[0][4], $Top = $g_aVillageRefSize[0][5], $Bottom = $g_aVillageRefSize[0][6]
	If $sLastCode <> $g_sCurrentScenery Then
		Local $iIndex = _ArraySearch($g_aVillageRefSize, $g_sCurrentScenery)
		If $iIndex <> -1 Then 
			$sLastCode = $g_sCurrentScenery
			$Left = $g_aVillageRefSize[$iIndex][3]
			$Right = $g_aVillageRefSize[$iIndex][4]
			$Top = $g_aVillageRefSize[$iIndex][5]
			$Bottom = $g_aVillageRefSize[$iIndex][6]
			SetDebugLog("[isInsideDiamond] LRTB: " & $Left & "," & $Right & "," & $Top & "," & $Bottom)
		Else
			SetLog("[isInsideDiamond] Reference Size no match", $COLOR_ERROR)
			Return True
		EndIf
	EndIf
	
	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]


	; convert to real diamond compensating zoom and offset
	; top diamond point
	$xD = $aMiddle[0]
	$yD = $Top
	ConvertToVillagePos($xD, $yD)
	$Top = $yD
	; bottom diamond point
	$xD = $aMiddle[0]
	$yD = $Bottom
	ConvertToVillagePos($xD, $yD)
	$Bottom = $yD
	; left diamond point
	$xD = $Left
	$yD = $aMiddle[1]
	ConvertToVillagePos($xD, $yD)
	$Left = $xD
	; right diamond point
	$xD = $Right
	$yD = $aMiddle[1]
	ConvertToVillagePos($xD, $yD)
	$Right = $xD

	;If $g_bDebugSetlog Then SetDebugLog("isInsideDiamond coordinates updated by offset: " & $Left & ", " & $Right & ", " & $Top & ", " & $Bottom, $COLOR_DEBUG)

	Local $aDiamond[2][2] = [[$Left, $Top], [$Right, $Bottom]]
	Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
	Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

	Local $DX = Abs($x - $aMiddle[0])
	Local $DY = Abs($y - $aMiddle[1])

	If ($DX / $aSize[0] + $DY / $aSize[1] <= 1) Then
		If $x < 70 And $y > 270 Then ; coordinates where the game will click on the CHAT tab (safe margin)
			SetDebugLog("Coordinate Inside Village, but Exclude CHAT")
			Return False
		ElseIf $y < 63 Then ; coordinates where the game will click on the BUILDER button or SHIELD button (safe margin)
			SetDebugLog("Coordinate Inside Village, but Exclude BUILDER")
			Return False
		ElseIf $x > 692 And $y > 156 And $y < 210 Then ; coordinates where the game will click on the GEMS button (safe margin)
			SetDebugLog("Coordinate Inside Village, but Exclude GEMS")
			Return False
		; Custom - Team AIO Mod++
		ElseIf $x > 669 And $y > 526 Then ; coordinates where the game will click on the SHOP button (safe margin)
			SetDebugLog("Coordinate Inside Village, but Exclude SHOP")
			Return False
		EndIf
		;SetDebugLog("Coordinate Inside Village", $COLOR_DEBUG)
		Return True ; Inside Village
	Else
		SetDebugLog("Coordinate Outside Village")
		Return False ; Outside Village
	EndIf
EndFunc   ;==>isInsideDiamond

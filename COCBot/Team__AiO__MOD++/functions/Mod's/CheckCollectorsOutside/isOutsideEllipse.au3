; FUNCTION ====================================================================================================================
; Name ..........: isOutsideEllipse
; Description ...: This function can test if a given coordinate is inside (True) or outside (False) the village grass borders (a diamond shape).
;                  It will also exclude some special area's like the CHAT tab, BUILDER button and GEM shop button.
; Syntax ........: isInsideDiamondXY($Coordx, $Coordy), isInsideDiamond($aCoords)
; Parameters ....: ($coordx, $coordY) as coordinates or ($aCoords), an array of (x,y) to test
; Return values .: True or False
; Author ........: McSlither (Jan-2016)
; Modified ......: TheRevenor (Jul-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: isInsideDiamond($aCoords)
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func isOutsideEllipse($coordX, $coordY, $ellipseWidth = 200, $ellipseHeigth = 150, $centerX = 430, $centerY = 339)
	Global $normalizedX = $coordX - $centerX
	Global $normalizedY = $coordY - Int($centerY + $g_iXVOffset)
 	Local $result = ($normalizedX * $normalizedX) / ($ellipseWidth * $ellipseWidth) + ($normalizedY * $normalizedY) / ($ellipseHeigth * $ellipseHeigth) > 1

	If $g_bDebugSetlog Then
		If $result Then
			Setlog("Coordinate Outside Ellipse (" & $ellipseWidth & ", " & $ellipseHeigth & ")", $COLOR_PURPLE)
		Else
			Setlog("Coordinate Inside Ellipse (" & $ellipseWidth & ", " & $ellipseHeigth & ")", $COLOR_PURPLE)
		EndIf
	EndIf

	Return $result

EndFunc   ;==>isOutsideEllipse

; FUNCTION ====================================================================================================================
; Name ..........: isInDiamond
; Description ...: Return True or False is if point is outside diamond.
;                  
; Syntax ........: isInDiamond($iX, $iY)
; Parameters ....: 
; Return values .: True or False
; Author ........: Boldina ! (16/6/2020) (port to au3, Based in model by Wladimir Palant)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. CopyiRight 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: 
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func isInDiamond($iX, $iY, $iLeft = 15, $iTop = 31, $iRight = 859, $iBottom = 648)
	Local $bReturn = False

	If Not (($iX < 68 And $iY > 316) Or ($iY < 63) Or ($iX > 692 And $iY > 156 And $iY < 210) Or ($iX > 669 And $iY > 489) Or (56 > $iY)) Then
		Local $aMiddle[2] = [(($iLeft + $iRight) + $g_iXVOffset) / 2, ($iTop + $iBottom) / 2]
		Local $aSize[2] = [$aMiddle[0] - $iLeft, $aMiddle[1] - $iTop]
		$bReturn = ((Abs($iX - $aMiddle[0]) / $aSize[0] + Abs($iY - $aMiddle[1]) / $aSize[1]) <= 1) ? (True) : (False)
	EndIf
	SetDebugLog("isInDiamond | Is in diamond? " & $bReturn & " / Correction: " & $g_iXVOffset)
	Return $bReturn
EndFunc
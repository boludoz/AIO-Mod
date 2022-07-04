; #FUNCTION# ====================================================================================================================
; Name ..........: isInsideDiamondXY, isInsideDiamond
; Description ...: This function can test if a given coordinate is inside (True) or outside (False) the village grass borders (a diamond shape).
;                  It will also exclude some special area's like the CHAT tab, BUILDER button and GEM shop button.
; Syntax ........: isInsideDiamondXY($aCoordX, $aCoordY), isInsideDiamond($aCoords)
; Parameters ....: ($aCoordX, $aCoordY) as coordinates or ($aCoords), an array of (x,y) to test
; Return values .: True or False
; Author ........: Hervidero (May 21, 2015), Boldina (July 3, 2022)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


Func isInsideDiamondXY($aCoordX, $aCoordY)

	Local $aCoords = [$aCoordX, $aCoordY]
	Return isInsideDiamond($aCoords)

EndFunc   ;==>isInsideDiamondXY

Func isInsideDiamond($aCoords)
	
	If UBound($aCoords) > 1 And not @error Then 
		If $aCoords[0] <= 100 And $aCoords[1] <= 100 Then
			PercentToVillage($aCoords[0], $aCoords[1])
		EndIf
		
		Local $iTolerance = 10
		Local $iX = $aCoords[0], $iY = $aCoords[1]
		Local $iLeft = $ExternalArea[0][0], $iRight = $ExternalArea[1][0], $iTop = $ExternalArea[2][1], $iBottom = $ExternalArea[3][1]
		Local $aDiamond[2][2] = [[$iLeft, $iTop], [$iRight, $iBottom]]
		Local $aMiddle = [($aDiamond[0][0] + $aDiamond[1][0]) / 2, ($aDiamond[0][1] + $aDiamond[1][1]) / 2]
		Local $aSize = [$aMiddle[0] - $aDiamond[0][0], $aMiddle[1] - $aDiamond[0][1]]

		Local $iDX = Abs($iX - $aMiddle[0])
		Local $iDY = Abs($iY - $aMiddle[1])

		; Allow additional pixels
		If $iDX >= $iTolerance Then $iDX -= $iTolerance
		If $iDY >= $iTolerance Then $iDY -= $iTolerance

		If ($iDX / $aSize[0] + $iDY / $aSize[1] <= 1) Then
			If $iX < 70 And $iY > 270 Then ; coordinates where the game will click on the CHAT tab (safe margin)
				SetDebugLog("[isInsideDiamond] Coordinate Inside Village, but Exclude CHAT", $COLOR_ERROR)
				Return False
			ElseIf $iY < 63 Then ; coordinates where the game will click on the BUILDER button or SHIELD button (safe margin)
				SetDebugLog("[isInsideDiamond] Coordinate Inside Village, but Exclude BUILDER", $COLOR_ERROR)
				Return False
			ElseIf $iX > 692 And $iY > 156 And $iY < 210 Then ; coordinates where the game will click on the GEMS button (safe margin)
				SetDebugLog("[isInsideDiamond] Coordinate Inside Village, but Exclude GEMS", $COLOR_ERROR)
				Return False
			ElseIf $iX > 669 And $iY > 526 Then ; coordinates where the game will click on the SHOP button (safe margin)
				SetDebugLog("[isInsideDiamond] Coordinate Inside Village, but Exclude SHOP", $COLOR_ERROR)
				Return False
			EndIf
		Else
			SetDebugLog("[isInsideDiamond] Coordinate Outside Village")
			Return False ; Outside Village
		EndIf
		
		;SetDebugLog("[isInsideDiamond] Coordinate Inside Village", $COLOR_DEBUG)
		Return True ; Inside Village
	Else
		SetLog("[isInsideDiamond] Invalid input", $COLOR_ERROR)
		Return False ; Outside Village
	EndIf
EndFunc   ;==>isInsideDiamond
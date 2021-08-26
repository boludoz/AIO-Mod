; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBasePolygon.au3
; Description ...: This file Includes function BuilderBasePolygon. Create the base constructor polygon and update the required values.
; Syntax ........:
; Parameters ....: None
; Return values .: -
; Author ........: Boldina (2021)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func PrintBBPoly($bOuterPolygon = True) ; Or Internal, but it always update globals.
	Local $aReturn[6] = [-1, -1, -1, -1, -1, -1]

	Local $iSize = ZoomBuilderBaseMecanics(False)
	If $iSize < 1 Then
		SetLog("Bad PrintBBPoly village size.", $COLOR_ERROR)
		Return SetError(1, 0, $aReturn)
	EndIf
	
	; Polygon Points
	Local $iTop[2], $iRight[2], $iBottom[2], $iBottomR[2], $iBottomL[2], $iLeft[2]
	
	$iSize = Floor(Pixel_Distance($g_aVillageSize[4], $g_aVillageSize[5], $g_aVillageSize[7], $g_aVillageSize[8]))
	
	; Fix ship coord
	Local $x = $g_aVillageSize[7] + Floor((590 * 14) / $iSize)
	Local $y = $g_aVillageSize[8]

	; ZoomFactor
	Local $iCorrectSizeLR = Floor(($iSize - 590) / 2)
	Local $iCorrectSizeT = Floor(($iSize - 590) / 4)
	Local $iCorrectSizeB = ($iSize - 590)
	
	Local $iFixA = Floor((590 * 6) / $iSize)
	Local $iFixE = Floor((590 * 25) / $iSize)
	
	; BuilderBaseAttackDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y + $iFixA

	$iRight[0] = $x + (160 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (515 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) - $iFixA

	If $bOuterPolygon = False Then
		$iBottomL[0] = $x - (225 + $iCorrectSizeB) - $iFixA
		$iBottomL[1] = 628
		
		$iBottomR[0] = $x - (110 - $iCorrectSizeB)
		$iBottomR[1] = 628

		$aReturn[0] = $iSize
		$aReturn[1] = $iTop
		$aReturn[2] = $iRight
		$aReturn[3] = $iBottomR
		$aReturn[4] = $iBottomL
		$aReturn[5] = $iLeft
	EndIf
	
	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseAttackPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseAttackPolygon = $aTmpBuilderBaseAttackPolygon
	SetDebugLog("Builder Base Attack Polygon : " & _ArrayToString($aTmpBuilderBaseAttackPolygon))
	
	; BuilderBaseAttackOuterDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y - $iFixE

	$iRight[0] = $x + (205 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (560 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) + $iFixE

	
	If $bOuterPolygon = True Then
		$iBottomL[0] = $x - (275 + $iCorrectSizeB) - $iFixA
		$iBottomL[1] = 628

		$iBottomR[0] = $x - (70 - $iCorrectSizeB)
		$iBottomR[1] = 628
	
		$aReturn[0] = $iSize
		$aReturn[1] = $iTop
		$aReturn[2] = $iRight
		$aReturn[3] = $iBottomR
		$aReturn[4] = $iBottomL
		$aReturn[5] = $iLeft
	EndIf

	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseOuterPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseOuterPolygon = $aTmpBuilderBaseOuterPolygon
	SetDebugLog("Builder Base Outer Polygon : " & _ArrayToString($aTmpBuilderBaseOuterPolygon))
	
	Return $aReturn
EndFunc   ;==>PrintBBPoly

Func BuilderBaseAttackDiamond()
	Local $iSize = ZoomBuilderBaseMecanics(False)
	If $iSize < 1 Then Return -1
	
	; Fix ship coord
	Local $x = $g_aVillageSize[7] + 14
	Local $y = $g_aVillageSize[8]

	; ZoomFactor
	Local $iCorrectSizeLR = Floor(($iSize - 590) / 2)
	Local $iCorrectSizeT = Floor(($iSize - 590) / 4)
	Local $iCorrectSizeB = ($iSize - 590)

	; Polygon Points
	Local $iTop[2], $iRight[2], $iBottomR[2], $iBottomL[2], $iLeft[2]

	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y + 6

	$iRight[0] = $x + (160 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (515 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottomR[0] = $x - (110 - $iCorrectSizeB)
	$iBottomR[1] = 628

	$iBottomL[0] = $x - (225 + $iCorrectSizeB)
	$iBottomL[1] = 628

	Local $iBuilderBaseDiamond[6] = [$iSize, $iTop, $iRight, $iBottomR, $iBottomL, $iLeft]
	Return $iBuilderBaseDiamond
EndFunc   ;==>BuilderBaseAttackDiamond

Func BuilderBaseAttackOuterDiamond()

	Local $iSize = ZoomBuilderBaseMecanics(True)
	If $iSize < 1 Then Return -1
	
	; Fix ship coord
	Local $x = $g_aVillageSize[7] + 14
	Local $y = $g_aVillageSize[8]
	
	; ZoomFactor
	Local $iCorrectSizeLR = Floor(($iSize - 590) / 2)
	Local $iCorrectSizeT = Floor(($iSize - 590) / 4)
	Local $iCorrectSizeB = ($iSize - 590)

	; Polygon Points
	Local $iTop[2], $iRight[2], $iBottomR[2], $iBottomL[2], $iLeft[2]

	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y - 25

	$iRight[0] = $x + (205 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (560 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottomR[0] = $x - (70 - $iCorrectSizeB)
	$iBottomR[1] = 628

	$iBottomL[0] = $x - (275 + $iCorrectSizeB)
	$iBottomL[1] = 628

	Local $iBuilderBaseDiamond[6] = [$iSize, $iTop, $iRight, $iBottomR, $iBottomL, $iLeft]
	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseOuterPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottomR[0], $iBottomR[1]], [$iBottomL[0], $iBottomL[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseOuterPolygon = $aTmpBuilderBaseOuterPolygon
	SetDebugLog("Builder Base Outer Polygon : " & _ArrayToString($g_aBuilderBaseOuterPolygon))
	Return $iBuilderBaseDiamond
EndFunc   ;==>BuilderBaseAttackOuterDiamond

Func InDiamondBB($iX, $iY, $aBigArray, $bAttack = True)
    If IsUnsafeDP($iX, $iY, $bAttack) = False And UBound($aBigArray) > 1 And not @error Then 
		; _ArrayDisplay($aBigArray)
        Return _IsPointInPoly($iX, $iY, $aBigArray)
    EndIf
    
    Return False
EndFunc   ;==>InDiamondBB

Func IsUnsafeDP($iX, $iY, $bAttack = True)
    If ($bAttack = True And $iY > 630) Or ($iX < 453 And $iY > 572) Then 
        Return True
    EndIf
    Return False
EndFunc   ;==>SafeDP
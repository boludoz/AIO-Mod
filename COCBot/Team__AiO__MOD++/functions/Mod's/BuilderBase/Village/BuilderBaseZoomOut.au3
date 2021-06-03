; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseZoomOutOn
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseZoomOutOnAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
; Modified ......: Boldina
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestGetBuilderBaseSize()
	Setlog("** TestGetBuilderBaseSize START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	GetBuilderBaseSize(True, True)
	$g_bRunState = $Status
	Setlog("** TestGetBuilderBaseSize END**", $COLOR_DEBUG)
EndFunc   ;==>TestGetBuilderBaseSize

Func TestBuilderBaseZoomOut()
	Setlog("** TestBuilderBaseZoomOutOnAttack START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	BuilderBaseZoomOut(True)
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseZoomOutOnAttack END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseZoomOut

Func BuilderBaseZoomOut($DebugImage = False, $bForceZoom = False)
	Local $iReturn = ZoomBuilderBaseMecanics($bForceZoom)
	Return ($iReturn > 0)
	#cs
	Local $iSize = GetBuilderBaseSize(False, $DebugImage) ; WihtoutClicks
	If $iSize > 520 And $iSize < 590 and Not $bForceZoom Then
		SetDebugLog("BuilderBaseZoomOut check!")
		Return True
	EndIf

	; Small loop just in case
	For $i = 0 To 5
		; Necessary a small drag to Up and right to get the Stone and Boat Images, Just once , coz in attack will display a red text and hide the boat
		If $i = 3 Then ClickDrag(100, 130, 230, 30)

		; Update shield status
		AndroidShield("AndroidOnlyZoomOut")
		; Run the ZoomOut Script
		If BuilderBaseSendZoomOut(False, $i) Then
			If _Sleep(500) Then ExitLoop
			If Not $g_bRunState Then Return
			; Get the Distances between images
			Local $iSize = GetBuilderBaseSize(True, $DebugImage)
			SetDebugLog("[" & $i & "]BuilderBaseZoomOut $iSize: " & $iSize)
			If IsNumber($iSize) And $iSize > 0 Then ExitLoop
			; Can't be precise each time we enter at Builder base was deteced a new Zoom Factor!! from 563-616
			If $iSize > 575 And $iSize < 620 Then
				Return True
			EndIf
		Else
			SetDebugLog("[BBzoomout] Send Script Error!", $COLOR_DEBUG)
		EndIf
	Next

	Return False
	#ce
EndFunc   ;==>BuilderBaseZoomOut

Func BuilderBaseSendZoomOut($Main = False, $i = 0)
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
	If Not $g_bRunState Then Return
	AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
	If @error <> 0 Then Return False
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
	Return True
EndFunc   ;==>BuilderBaseSendZoomOut

Func GetBuilderBaseSize($WithClick = False, $bDebugLog = False)
	Local $iResult = 0, $aVillage = 0
	
	If Not $g_bRunState Then Return
	
	Local $sFiles = ["", "2"]
	
	_CaptureRegion2()
	
	For $sMode In $sFiles
		
		If Not $g_bRunState Then Return
		
		$aVillage = GetVillageSize($bDebugLog, $sMode & "stone", $sMode & "tree", Default, True, False)
	
		If UBound($aVillage) > 8 And not @error Then
			If StringLen($aVillage[9]) > 5 And StringIsSpace($aVillage[9]) = 0 Then
				$iResult = Floor(Pixel_Distance($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
				Return $iResult
			EndIf
		EndIf
		
		If _Sleep($DELAYSLEEP * 10) Then Return
		
	Next
	
	Return 0
EndFunc   ;==>GetBuilderBaseSize

Func ZoomBuilderBaseMecanics($bAttack = True)
	Local $iSize = ($bAttack = True) ? (GetBuilderBaseSize()) : (0)
	
	If $iSize = 0 Then
		BuilderBaseSendZoomOut()
		If _Sleep($DELAYSLEEP * 10) Then Return
	Else
		Setlog("Builder Base Diamond: " & $iSize, $COLOR_INFO)
	EndIf
	
	If Not $g_bRunState Then Return

	Local $i = 0
	Do
		Setlog("Builder Base Attack Zoomout.")
		$iSize = GetBuilderBaseSize(False) ; WihtoutClicks

		; Necessary a small drag to Up and right to get the Stone and Boat Images, Just once , coz in attack will display a red text and hide the boat
		If $i = 3 Then ClickDrag(100, 130, 230, 30)

		; Update shield status
		AndroidShield("AndroidOnlyZoomOut")

		If Not $g_bRunState Then Return

		If ($iSize < 575 And $iSize > 620) Or ($iSize = 0) Then
			BuilderBaseSendZoomOut()
			If _Sleep(1000) Then Return
		EndIf

		If $i > 5 Then ExitLoop
		$i += 1
	Until ($iSize >= 575 And $iSize <= 620) Or ($iSize <> 0)

	If $iSize = 0 Then
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - FAIL", $COLOR_ERROR)
	Else
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - OK", $COLOR_SUCCESS)
	EndIf
	
	Return _ZoomBuilderBaseMecanics()
EndFunc   ;==>ZoomBuilderBaseMecanics

Func _ZoomBuilderBaseMecanics()

	Local $iSize = Floor(Pixel_Distance($g_aVillageSize[4], $g_aVillageSize[5], $g_aVillageSize[7], $g_aVillageSize[8]))
	
	; Fix ship coord
	Local $x = $g_aVillageSize[7] + Floor((590 * 14) / $iSize)
	Local $y = $g_aVillageSize[8]

	; ZoomFactor
	Local $iCorrectSizeLR = Floor(($iSize - 590) / 2)
	Local $iCorrectSizeT = Floor(($iSize - 590) / 4)
	Local $iCorrectSizeB = ($iSize - 590)
	
	Local $iFixA = Floor((590 * 6) / $iSize)
	Local $iFixE = Floor((590 * 25) / $iSize)
	
	; Polygon Points
	Local $iTop[2], $iRight[2], $iBottom[2], $iLeft[2]
	
	; BuilderBaseAttackDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y + $iFixA

	$iRight[0] = $x + (160 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (515 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) - $iFixA

	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseAttackPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseAttackPolygon = $aTmpBuilderBaseAttackPolygon
	SetDebugLog("Builder Base Attack Polygon : " & _ArrayToString($g_aBuilderBaseAttackPolygon))
	
	; BuilderBaseAttackOuterDiamond
	$iTop[0] = $x - (180 + $iCorrectSizeT)
	$iTop[1] = $y - $iFixE

	$iRight[0] = $x + (205 + $iCorrectSizeLR)
	$iRight[1] = $y + (260 + $iCorrectSizeLR)

	$iLeft[0] = $x - (560 + $iCorrectSizeB)
	$iLeft[1] = $y + (260 + $iCorrectSizeLR)

	$iBottom[0] = $x - (180 + $iCorrectSizeT)
	$iBottom[1] = $y + (515 + $iCorrectSizeB) + $iFixE
	
	;This Format is for _IsPointInPoly function
	Local $aTmpBuilderBaseOuterPolygon[7][2] = [[5, -1], [$iTop[0], $iTop[1]], [$iRight[0], $iRight[1]], [$iBottom[0], $iBottom[1]], [$iBottom[0], $iBottom[1]], [$iLeft[0], $iLeft[1]], [$iTop[0], $iTop[1]]] ; Make Polygon From Points
	$g_aBuilderBaseOuterPolygon = $aTmpBuilderBaseOuterPolygon
	SetDebugLog("Builder Base Outer Polygon : " & _ArrayToString($g_aBuilderBaseOuterPolygon))
	
	Return $iSize
EndFunc   ;==>_ZoomBuilderBaseMecanics

Func BuilderBaseDiamond($sMode = "Attack")
	Local $iSize = _ZoomBuilderBaseMecanics()
	
	If $iSize > 0 Then 
		; Polygon Points
		Local $iTop[2], $iRight[2], $iBottomR[2], $iBottomL[2], $iLeft[2]
		
		Local $aBuilderBaseDiamond = ($sMode = "Attack") ? ($g_aBuilderBaseAttackPolygon) : ($g_aBuilderBaseOuterPolygon)
		
		If UBound($aBuilderBaseDiamond) = 7 And not @error Then
			$iTop[0] = $aBuilderBaseDiamond[1][0]
			$iTop[1] = $aBuilderBaseDiamond[1][1]
		
			$iRight[0] = $aBuilderBaseDiamond[2][0]
			$iRight[1] = $aBuilderBaseDiamond[2][1]
		
			$iBottomR[0] = $aBuilderBaseDiamond[3][0]
			$iBottomR[1] = $aBuilderBaseDiamond[3][1]
		
			$iBottomL[0] = $aBuilderBaseDiamond[4][0]
			$iBottomL[1] = $aBuilderBaseDiamond[4][1]
		
			$iLeft[0] = $aBuilderBaseDiamond[5][0]
			$iLeft[1] = $aBuilderBaseDiamond[5][1]
			
			Local $iBuilderBaseDiamond[6] = [$iSize, $iTop, $iRight, $iBottomR, $iBottomL, $iLeft]
		
			SetDebugLog("Builder Base Polygon : " & _ArrayToString($iBuilderBaseDiamond))
			Return $iBuilderBaseDiamond
		EndIf
		
	EndIf
	
	Return -1
EndFunc   ;==>BuilderBaseDiamond

Func IsUnsafeDP($iX, $iY, $bAttack = True)
	If $bAttack = True And $iY > 630 Or ($iX < 453 And $iY > 572) Then 
		Return True
	EndIf
	Return False
EndFunc   ;==>SafeDP

Func InDiamondBB($iX, $iY, $aBigArray, $bAttack = True)
	If IsUnsafeDP($iX, $iY, $bAttack = True) = False And IsArray($aBigArray) Then 
		Return _IsPointInPoly($iX, $iY, $aBigArray)
	EndIf
	
	Return False
EndFunc   ;==>InDiamondBB

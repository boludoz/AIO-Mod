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
Global $g_aBoatPos[2] = [Null, Null]

Func ZoomBuilderBaseMecanics($bForceZoom = Default, $bVersusMode = Default, $bDebugLog = False)
	BuilderBaseZoomOut()
	Local $iSize = GetBuilderBaseSize()
	If $iSize > 0 Then
		BuilderBaseAttackDiamond()
		BuilderBaseAttackOuterDiamond()
	EndIf
	Return $iSize
EndFunc   ;==>ZoomBuilderBaseMecanics

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

Func BuilderBaseZoomOut($bForceZoom = False, $bVersusMode = True, $DebugImage = False)

	Local $Size = GetBuilderBaseSize(False, $DebugImage) ; WihtoutClicks
	If $Size > 520 And $Size < 590 Then
		SetDebugLog("BuilderBaseZoomOut check!")
		Return True
	EndIf

	; Small loop just in case
	For $i = 0 To 5
		; Necessary a small drag to Up and right to get the Stone and Boat Images, Just once , coz in attack will display a red text and hide the boat
		If $i = 0 Or $i = 3 Then ClickDrag(100, 130, 230, 30)

		; Update shield status
		AndroidShield("AndroidOnlyZoomOut")
		; Run the ZoomOut Script
		If BuilderBaseSendZoomOut(False, $i) Then
			For $i = 0 To 5
				If _Sleep(500) Then ExitLoop
				If Not $g_bRunState Then Return
				; Get the Distances between images
				Local $Size = GetBuilderBaseSize($bVersusMode = False, $DebugImage)
				SetDebugLog("[" & $i & "]BuilderBaseZoomOut $Size: " & $Size)
				If IsNumber($Size) And $Size > 0 Then ExitLoop
			Next
			; Can't be precise each time we enter at Builder base was deteced a new Zoom Factor!! from 563-616
			If $Size > 520 And $Size < 590 Then
				Return True
			EndIf
		Else
			SetDebugLog("[BBzoomout] Send Script Error!", $COLOR_DEBUG)
		EndIf
	Next
	Return False
EndFunc   ;==>BuilderBaseZoomOut

Func BuilderBaseSendZoomOut($bWar = False, $i = 0)
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
	If Not $g_bRunState Then Return
	AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
	If @error <> 0 Then Return False
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
	Return True
EndFunc   ;==>BuilderBaseSendZoomOut

Func GetBuilderBaseSize($WithClick = True, $DebugImage = False)

	Local $BoatCoord[2], $Stonecoord[2]
	Local $BoatSize = [545, 20, 660, 200]
	Local $StoneSize = [125, 400, 225, 580]
	Local $SetBoat[2] = [610, 85]
	Local $SetBoatAttack[2] = [610, 60]
	Local $OffsetForBoat = 50

	If Not $g_bRunState Then Return
	; Get The boat at TOP
	If QuickMIS("BC1", $g_sImgZoomOutDirBB & "V2\", $BoatSize[0], $BoatSize[1], $BoatSize[2], $BoatSize[3], True, False) Then ; RC Done
		$BoatCoord[0] = $g_iQuickMISX
		$BoatCoord[1] = $g_iQuickMISY
		If $DebugImage Then SetDebugLog("[BBzoomout] Coordinate Boat: " & $BoatCoord[0] & "/" & $BoatCoord[01])
		$g_aBoatPos[0] = Int($BoatCoord[0])
		$g_aBoatPos[1] = Int($BoatCoord[1])
		; Get the Stone at Left
		If QuickMIS("BC1", $g_sImgZoomOutDirBB & "V2\", $StoneSize[0], $StoneSize[1], $StoneSize[2], $StoneSize[3], True, False) Then ; RC Done
			$Stonecoord[0] = $g_iQuickMISX
			$Stonecoord[1] = $g_iQuickMISY
			If $DebugImage Then SetDebugLog("[BBzoomout] Coordinate Stone: " & $Stonecoord[0] & "/" & $Stonecoord[01])
			; Get the Distance between Images
			Local $resul = Floor(Village_Distances($BoatCoord[0], $BoatCoord[1], $Stonecoord[0], $Stonecoord[1]))
			If $DebugImage Then SetDebugLog("[BBzoomout] GetDistance Boat to Stone: " & $resul)
			; Debug Image
			Local $boat = isOnBuilderBase() ? $SetBoat : $SetBoatAttack
			If $DebugImage Then DebugZoomOutBB($BoatCoord[0], $BoatCoord[1], $Stonecoord[0], $Stonecoord[1], $boat, "GetBuilerBaseSize_" & $resul & "_")
			If $DebugImage Then SetDebugLog("[BBzoomout] ClickDrag: X(" & $BoatCoord[0] & "/" & $SetBoat[0] & ") Y(" & $BoatCoord[1] & "/" & $SetBoat[1] & ")")
			; Centering the Village, use the $OffsetForBoat just to not click on boat and return to village
			If Not isOnBuilderBase() And ($g_aBoatPos[0] <> $boat[0] Or $g_aBoatPos[1] <> $boat[1]) Then
				If $WithClick Then ClickDrag($g_aBoatPos[0], $g_aBoatPos[1] + $OffsetForBoat, $boat[0], $boat[1] + $OffsetForBoat)
				; To release click , a possible problem on BS2
				If $WithClick Then ClickP($aAway, 1, 0, "#0332")
			EndIf
			Return $resul
		EndIf
	Else
		$g_aBoatPos[0] = Null
		$g_aBoatPos[1] = Null
	EndIf
	SetDebugLog("[BBzoomout] GetDistance Boat to Stone Error", $COLOR_ERROR)
	Return 0
EndFunc   ;==>GetBuilderBaseSize

Func Village_Distances($x1, $y1, $x2, $y2)
	If Not $g_bRunState Then Return
	;Pythagoras theorem for 2D
	Local $a, $b, $c
	If $x2 = $x1 And $y2 = $y1 Then
		Return 0
	Else
		$a = $y2 - $y1
		$b = $x2 - $x1
		$c = Sqrt($a * $a + $b * $b)
		Return $c
	EndIf
EndFunc   ;==>Village_Distances

Func DebugZoomOutBB($x, $y, $x1, $y1, $aBoat, $DebugText)

	_CaptureRegion2()
	Local $subDirectory = $g_sProfileTempDebugPath & "DebugZoomOutBB"
	DirCreate($subDirectory)
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $filename = String($Date & "_" & $Time & "_" & $DebugText & "_.png")
	Local $editedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 3) ; Create a pencil Color FF0000/RED
	Local $hPenWhite = _GDIPlus_PenCreate(0xFFFFFFFF, 3) ; Create a pencil Color FFFFFF/WHITE

	_GDIPlus_GraphicsDrawRect($hGraphic, $x - 5, $y - 5, 10, 10, $hPenRED)
	_GDIPlus_GraphicsDrawRect($hGraphic, $x1 - 5, $y1 - 5, 10, 10, $hPenRED)
	_GDIPlus_GraphicsDrawRect($hGraphic, $aBoat[0] - 5, $aBoat[1] - 5, 10, 10, $hPenWhite)

	_GDIPlus_GraphicsDrawRect($hGraphic, 623, 155, 10, 10, $hPenWhite)
	_GDIPlus_GraphicsDrawRect($hGraphic, 278, 545, 10, 10, $hPenWhite)

	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & "\" & $filename)
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_PenDispose($hPenWhite)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($editedImage)

EndFunc   ;==>DebugZoomOutBB

; TODO RC
Func BuilderBaseAttackDiamond()

	Local $Size = GetBuilderBaseSize(False) ; Wihtout Clicks
	If Not $g_bRunState Then Return
	Setlog("Builder Base Diamond: " & $Size)
	If ($Size < 520 And $Size > 590) Or $Size = 0 Then
		Setlog("Builder Base Attack Zoomout.")
		BuilderBaseZoomOut()
		If _Sleep(1000) Then Return
		$Size = GetBuilderBaseSize(False) ; Wihtout Clicks
	EndIf

	If $Size = 0 Then Return -1

	; ZoomFactor
	Local $CorrectSizeLR = Floor(($Size - 590) / 2)
	Local $CorrectSizeT = Floor(($Size - 590) / 4)
	Local $CorrectSizeB = ($Size - 590)

	; Polygon Points
	Local $Top[2], $Right[2], $BottomR[2], $BottomL[2], $Left[2]

	$Top[0] = $g_aBoatPos[0] - (180 + $CorrectSizeT)
	$Top[1] = $g_aBoatPos[1] + 6

	$Right[0] = $g_aBoatPos[0] + (160 + $CorrectSizeLR)
	$Right[1] = $g_aBoatPos[1] + (260 + $CorrectSizeLR)

	$Left[0] = $g_aBoatPos[0] - (515 + $CorrectSizeB)
	$Left[1] = $g_aBoatPos[1] + (260 + $CorrectSizeLR)

	$BottomR[0] = $g_aBoatPos[0] - (110 - $CorrectSizeB)
	$BottomR[1] = 540

	$BottomL[0] = $g_aBoatPos[0] - (225 + $CorrectSizeB)
	$BottomL[1] = 540

	Local $BuilderBaseDiamond[6] = [$Size, $Top, $Right, $BottomR, $BottomL, $Left]
	;This Format is for _IsPointInPoly function
	Dim $g_aBuilderBaseAttackPolygon[7][2] = [[5, -1], [$Top[0], $Top[1]], [$Right[0], $Right[1]], [$BottomR[0], $BottomR[1]], [$BottomL[0], $BottomL[1]], [$Left[0], $Left[1]], [$Top[0], $Top[1]]] ; Make Polygon From Points
	SetDebugLog("Builder Base Attack Polygon : " & _ArrayToString($g_aBuilderBaseAttackPolygon))
	Return $BuilderBaseDiamond
EndFunc   ;==>BuilderBaseAttackDiamond

Func BuilderBaseAttackOuterDiamond()
	Local $Size = GetBuilderBaseSize(False) ; WihtoutClicks
	If Not $g_bRunState Then Return
	Setlog("Builder Base Diamond: " & $Size)
	If ($Size < 520 And $Size > 590) Or $Size = 0 Then
		Setlog("Builder Base Attack Zoomout.")
		BuilderBaseZoomOut()
		If _Sleep(1000) Then Return
		$Size = GetBuilderBaseSize(False) ; WihtoutClicks
	EndIf

	If $Size = 0 Then Return -1

	; ZoomFactor
	Local $CorrectSizeLR = Floor(($Size - 590) / 2)
	Local $CorrectSizeT = Floor(($Size - 590) / 4)
	Local $CorrectSizeB = ($Size - 590)

	; Polygon Points
	Local $Top[2], $Right[2], $BottomR[2], $BottomL[2], $Left[2]

	$Top[0] = $g_aBoatPos[0] - (180 + $CorrectSizeT)
	$Top[1] = $g_aBoatPos[1] - 25

	$Right[0] = $g_aBoatPos[0] + (205 + $CorrectSizeLR)
	$Right[1] = $g_aBoatPos[1] + (260 + $CorrectSizeLR)

	$Left[0] = $g_aBoatPos[0] - (560 + $CorrectSizeB)
	$Left[1] = $g_aBoatPos[1] + (260 + $CorrectSizeLR)

	$BottomR[0] = $g_aBoatPos[0] - (70 - $CorrectSizeB)
	$BottomR[1] = 540

	$BottomL[0] = $g_aBoatPos[0] - (275 + $CorrectSizeB)
	$BottomL[1] = 540

	Local $BuilderBaseDiamond[6] = [$Size, $Top, $Right, $BottomR, $BottomL, $Left]
	;This Format is for _IsPointInPoly function
	Dim $g_aBuilderBaseOuterPolygon[7][2] = [[5, -1], [$Top[0], $Top[1]], [$Right[0], $Right[1]], [$BottomR[0], $BottomR[1]], [$BottomL[0], $BottomL[1]], [$Left[0], $Left[1]], [$Top[0], $Top[1]]] ; Make Polygon From Points
	SetDebugLog("Builder Base Outer Polygon : " & _ArrayToString($g_aBuilderBaseOuterPolygon))
	Return $BuilderBaseDiamond
EndFunc   ;==>BuilderBaseAttackOuterDiamond

Func BuilderBaseGetEdges($BuilderBaseDiamond, $Text)

	Local $TopLeft[0][2], $TopRight[0][2], $BottomRight[0][2], $BottomLeft[0][2]
	If Not $g_bRunState Then Return

	; $BuilderBaseDiamond[6] = [$Size, $Top, $Right, $BottomR, $BottomL, $Left]
	Local $Top = $BuilderBaseDiamond[1], $Right = $BuilderBaseDiamond[2], $BottomR = $BuilderBaseDiamond[3], $BottomL = $BuilderBaseDiamond[4], $Left = $BuilderBaseDiamond[5]

	Local $X = [$Top[0], $Right[0]]
	Local $Y = [$Top[1], $Right[1]]

	; TOP RIGHT
	For $i = $X[0] To $X[1] Step 20
		ReDim $TopRight[UBound($TopRight) + 1][2]
		$TopRight[UBound($TopRight) - 1][0] = $i
		$TopRight[UBound($TopRight) - 1][1] = Floor($Y[0])
		$Y[0] += 15
		If $Y[0] > $Y[1] Then ExitLoop
	Next

	Local $X = [$Right[0], $BottomR[0]]
	Local $Y = [$Right[1], $BottomR[1]]

	; BOTTOM RIGHT
	For $i = $X[0] To $X[1] Step -20
		ReDim $BottomRight[UBound($BottomRight) + 1][2]
		$BottomRight[UBound($BottomRight) - 1][0] = $i
		$BottomRight[UBound($BottomRight) - 1][1] = Floor($Y[0])
		$Y[0] += 15
		If $Y[0] > $Y[1] Then ExitLoop
	Next

	Local $X = [$BottomL[0], $Left[0]]
	Local $Y = [$BottomL[1], $Left[1]]

	; BOTTOM LEFT
	For $i = $X[0] To $X[1] Step -20
		ReDim $BottomLeft[UBound($BottomLeft) + 1][2]
		$BottomLeft[UBound($BottomLeft) - 1][0] = $i
		$BottomLeft[UBound($BottomLeft) - 1][1] = Ceiling($Y[0])
		$Y[0] -= 15
		If $Y[0] < $Y[1] Then ExitLoop
	Next

	Local $X = [$Left[0], $Top[0]]
	Local $Y = [$Left[1], $Top[1]]

	; TOP LEFT
	For $i = $X[0] To $X[1] Step 20
		ReDim $TopLeft[UBound($TopLeft) + 1][2]
		$TopLeft[UBound($TopLeft) - 1][0] = $i
		$TopLeft[UBound($TopLeft) - 1][1] = Floor($Y[0])
		$Y[0] -= 15
		If $Y[0] < $Y[1] Then ExitLoop
	Next

	Local $ExternalEdges[4] = [$TopLeft, $TopRight, $BottomRight, $BottomLeft]
	Local $Names = ["Top Left", "Top Right", "Bottom Right", "Bottom Left"]

	For $i = 0 To 3
		SetDebugLog($Text & " Points to " & $Names[$i] & " (" & UBound($ExternalEdges[$i]) & ")")
	Next

	Return $ExternalEdges

EndFunc   ;==>BuilderBaseGetEdges

Func BuilderBaseGetFakeEdges()
	Local $TopLeft[18][2], $TopRight[18][2], $BottomRight[18][2], $BottomLeft[18][2]
	; several points when the Village was not zoomed
	; Presets
	For $i = 0 To 17
		$TopLeft[$i][0] = 145 + ($i * 15)
		$TopLeft[$i][1] = 275 - ($i * 11)
	Next
	For $i = 0 To 17
		$TopRight[$i][0] = 430 + ($i * 20)
		$TopRight[$i][1] = 75 + ($i * 15)
	Next
	For $i = 0 To 17
		$BottomRight[$i][0] = 700 + ($i * 8)
		$BottomRight[$i][1] = 610 - ($i * 6)
	Next
	For $i = 0 To 17
		$BottomLeft[$i][0] = 10 + ($i * 4.5)
		$BottomLeft[$i][1] = 500 + ($i * 3.5)
	Next

	Local $ExternalEdges[4] = [$TopLeft, $TopRight, $BottomRight, $BottomLeft]
	Return $ExternalEdges
EndFunc   ;==>BuilderBaseGetFakeEdges

#cs
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
EndFunc   ;==>IsUnsafeDP

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

Func BuilderBaseZoomOut($bForceZoom = False, $bVersusMode = True)
	If ZoomBuilderBaseMecanics($bForceZoom, $bVersusMode) > 0 Then
		Return True
	EndIf
	
	Return False
EndFunc   ;==>BuilderBaseZoomOut

Func BuilderBaseSendZoomOut($i = 0)
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
	If Not $g_bRunState Then Return
	AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
	If @error <> 0 Then Return False
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
	Return True
EndFunc   ;==>BuilderBaseSendZoomOut

Func ZoomBuilderBaseMecanics($bForceZoom = Default, $bVersusMode = Default, $bDebugLog = False)
	If $bForceZoom = Default Then $bForceZoom = True
	If $bVersusMode = Default Then $bVersusMode = True

	Local $iSize = ($bForceZoom = True) ? (0) : (GetBuilderBaseSize())

	If $iSize = 0 Then
		BuilderBaseSendZoomOut(0)
		If _Sleep(1000) Then Return
		
		$iSize = GetBuilderBaseSize(False, $bVersusMode, $bDebugLog)
	EndIf

	If Not $g_bRunState Then Return

	Local $i = 0
	Do
		SetDebugLog("Builder base force Zoomout ? " & $bForceZoom)

		If Not $g_bRunState Then Return

		If Not ($iSize > 520 And $iSize < 620) Then

			; Update shield status
			AndroidShield("AndroidOnlyZoomOut")
			
			; Send zoom-out.
			If BuilderBaseSendZoomOut($i) Then
				If _Sleep(1000) Then Return
				
				If Not $g_bRunState Then Return
				$iSize = GetBuilderBaseSize(($i = 3), $bVersusMode, $bDebugLog) ; WihtoutClicks
			EndIf
		EndIf

		If $i > 5 Then ExitLoop
		$i += 1
	Until ($iSize > 520 And $iSize < 620)

	SetDebugLog("Builder Base Diamond: " & $iSize, $COLOR_INFO)
	
	If $iSize = 0 Then
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - FAIL", $COLOR_ERROR)
	Else
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - OK", $COLOR_SUCCESS)
	EndIf

	Return $iSize
EndFunc   ;==>ZoomBuilderBaseMecanics

Func GetBuilderBaseSize($bWithClick = False, $bVersusMode = Default, $bDebugLog = False)
	If $bVersusMode = Default Then $bVersusMode = True
	Local $iResult = 0, $aVillage = 0

	If Not $g_bRunState Then Return

	If $bWithClick = True Then
		ClickDrag(100, 130 + $g_iMidOffsetYFixed, 230, 30)
		If _Sleep(500) Then Return 
	EndIf
	
	_CaptureRegion2()
	If $bVersusMode = False Then
		If Not IsOnBuilderBase(False) Then
			SetDebugLog("You not are in builder base!")
			CheckObstacles(True)
		EndIf
	EndIf
	
	
	If Not $g_bRunState Then Return
	
	$aVillage = GetVillageSize($bDebugLog, "stone", "tree", Default, True, False)
	
	If UBound($aVillage) > 8 And not @error Then
		If StringLen($aVillage[9]) > 5 And StringIsSpace($aVillage[9]) = 0 Then
			$iResult = Floor(Pixel_Distance($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
			Return $iResult
		ElseIf StringIsSpace($aVillage[9]) = 1 Then
			Return 0
		EndIf
	EndIf
	
	If _Sleep($DELAYSLEEP * 10) Then Return
	
	Return 0
EndFunc   ;==>GetBuilderBaseSize
#ce
; Cartesian axis, by percentage, instead convert village pos, ready to implement in the constructor base. (Boldina, "the true dev").
; No reference village is based and no external DLL calls are made, just take the x and y endpoints, 
; then subtract the endpoints and generate the percentages they represent on the axes.

Func VillageToPercent($x, $y, $xv1, $xv2, $ya1, $ya2)
    Local $aArray[2] = [-1, -1]
    Local $ixAncho = $xv2 - $xv1
    Local $iyAlto = $ya2 - $ya1
    $aArray[0] = ($x / $ixAncho) * 100
    $aArray[1] = ($y / $iyAlto) * 100
    Return $aArray
EndFunc   ;==>VillageToPercent

; From the current village and the percentages represented by the axes, the Cartesian point is generated.
; Then add the external to fit.
; Taking as input the percentage in which the construction is located at the Cartesian point, the position is returned.
; The code is simple to implement and has precision.

Func PercentToVillage($xPer, $yPer, $xv1, $xv2, $ya1, $ya2)
    Local $aArray[2] = [-1, -1]
    Local $ixAncho = $xv2 - $xv1
    Local $iyAlto = $ya2 - $ya1
    $aArray[0] = $xv1 + (($ixAncho * $xPer) / 100)
    $aArray[1] = $ya1 + (($iyAlto * $yPer) / 100)
    Return $aArray
EndFunc   ;==>PercentToVillage

; #FUNCTION# ====================================================================================================================
; Name ..........: AngleFuncs
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: Coordinates plus the distance you want to give it, this generates the angle and multiplies it by angle.
; Return values .: Returns an array with an artificially generated coordinate not rounded.
; Author ........: Boldina (05 - 2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global Const $PI = 4 * ATan(1)

Func Linecutter($cx = 0, $cy = 0, $ex = 1, $ey = 1, $iMult = 20, $iRmin = -1, $iRmax = 1)
	Local $iAngle = angle($cx, $cy, $ex, $ey)
	Local $iRandom = Random($iRmin, $iRmax)
	Local $aReturn[2] = [$cx + Cos(_Radian($iAngle)) * $iMult + $iRandom, $cy + Sin(_Radian($iAngle)) * $iMult + $iRandom]
	; SetDebugLog("[Linecutter] " &  $aReturn[0] & " " & $aReturn[1] & " " & $iAngle)
	Return $aReturn
EndFunc   ;==>Linecutter

Func angle($cx, $cy, $ex, $ey)
	Local $dy = $ey - $cy
	Local $dx = $ex - $cx
	Local $iTheta = atan2($dy, $dx) ; // range (-PI, PI]
	$iTheta *= 180 / $PI ; // rads to degs, range (-180, 180]
	Return $iTheta
EndFunc   ;==>angle

Func atan2($y, $x)
	Return (2 * ATan($y / ($x + Sqrt($x * $x + $y * $y))))
EndFunc   ;==>atan2


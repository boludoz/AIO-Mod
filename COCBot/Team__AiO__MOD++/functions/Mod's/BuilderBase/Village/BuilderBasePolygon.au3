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
	BuilderBaseAttackDiamond()
	BuilderBaseAttackOuterDiamond()
	Return 512
EndFunc   ;==>ZoomBuilderBaseMecanics

Func TestGetBuilderBaseSize()
	Setlog("** TestGetBuilderBaseSize START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
;~ 	GetBuilderBaseSize(True, True)
	SetLOG("DEPRECATED", $COLOR_ERROR)
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
	$g_aiSearchZoomOutCounter[0] = 0
	$g_aiSearchZoomOutCounter[1] = 0

	; Small loop just in case
	For $i = 0 To 6
		; Update shield status
		AndroidShield("AndroidOnlyZoomOut")
		; Run the ZoomOut Script
		If BuilderBaseSendZoomOut(False, $i) Then
			ClickDrag(100, 130, 230, 30)
			If _Sleep(500) Then ExitLoop
			If Not $g_bRunState Then Return
			; Get the Distances between images
			Local $aSize = SearchZoomOutBB()
			If @error Then Return False
			If IsArray($aSize) And $aSize[0] <> "" Then Return True
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

	; Polygon Points
	Local $Top[2], $Right[2], $BottomR[2], $BottomL[2], $Left[2]

	$Left[0] = $InternalArea[0][0]
	$Left[1] = $InternalArea[0][1]

	$Right[0] = $InternalArea[1][0]
	$Right[1] = $InternalArea[1][1]

	$Top[0] = $InternalArea[2][0]
	$Top[1] = $InternalArea[2][1]

	Local $aFinal[2], $aCut[2], $iPrecision = 10
	For $iPoints = 1 To Ceiling(Pixel_Distance($InternalArea[1][0], $InternalArea[1][1], $InternalArea[3][0], $InternalArea[3][1]) / $iPrecision) * 2
		$aCut = Linecutter($InternalArea[1][0], $InternalArea[1][1], $InternalArea[3][0], $InternalArea[3][1], $iPoints * $iPrecision, 0, 0)
		If $aCut[1] > $g_aiDeployableLRTB[3] Then ExitLoop
		$aFinal = $aCut
	Next

	$BottomR[0] = $aFinal[0]
	$BottomR[1] = $aFinal[1]

	For $iPoints = 1 To Ceiling(Pixel_Distance($InternalArea[0][0], $InternalArea[0][1], $InternalArea[3][0], $InternalArea[3][1]) / $iPrecision) * 2
		$aCut = Linecutter($InternalArea[0][0], $InternalArea[0][1], $InternalArea[3][0], $InternalArea[3][1], $iPoints * $iPrecision, 0, 0)
		If $aCut[1] > $g_aiDeployableLRTB[3] Then ExitLoop
		$aFinal = $aCut
	Next

	$BottomL[0] = $aFinal[0]
	$BottomL[1] = $aFinal[1]

	Local $BuilderBaseDiamond[6] = [550, $Top, $Right, $BottomR, $BottomL, $Left]
	;This Format is for _IsPointInPoly function
	Dim $g_aBuilderBaseAttackPolygon[7][2] = [[5, -1], [$Top[0], $Top[1]], [$Right[0], $Right[1]], [$BottomR[0], $BottomR[1]], [$BottomL[0], $BottomL[1]], [$Left[0], $Left[1]], [$Top[0], $Top[1]]] ; Make Polygon From Points
	SetDebugLog("Builder Base Attack Polygon : " & _ArrayToString($g_aBuilderBaseAttackPolygon))
	Return $BuilderBaseDiamond
EndFunc   ;==>BuilderBaseAttackDiamond

Func BuilderBaseAttackOuterDiamond()
	; Polygon Points
	Local $Top[2], $Right[2], $BottomR[2], $BottomL[2], $Left[2]

	$Left[0] = $ExternalArea[0][0]
	$Left[1] = $ExternalArea[0][1]

	$Right[0] = $ExternalArea[1][0]
	$Right[1] = $ExternalArea[1][1]

	$Top[0] = $ExternalArea[2][0]
	$Top[1] = $ExternalArea[2][1]

	Local $aFinal[2], $aCut[2], $iPrecision = 10
	For $iPoints = 1 To Ceiling(Pixel_Distance($ExternalArea[1][0], $ExternalArea[1][1], $ExternalArea[3][0], $ExternalArea[3][1]) / $iPrecision) * 2
		$aCut = Linecutter($ExternalArea[1][0], $ExternalArea[1][1], $ExternalArea[3][0], $ExternalArea[3][1], $iPoints * $iPrecision, 0, 0)
		If $aCut[1] > $g_aiDeployableLRTB[3] Then ExitLoop
		$aFinal = $aCut
	Next

	$BottomR[0] = $aFinal[0]
	$BottomR[1] = $aFinal[1]

	For $iPoints = 1 To Ceiling(Pixel_Distance($ExternalArea[0][0], $ExternalArea[0][1], $ExternalArea[3][0], $ExternalArea[3][1]) / $iPrecision) * 2
		$aCut = Linecutter($ExternalArea[0][0], $ExternalArea[0][1], $ExternalArea[3][0], $ExternalArea[3][1], $iPoints * $iPrecision, 0, 0)
		If $aCut[1] > $g_aiDeployableLRTB[3] Then ExitLoop
		$aFinal = $aCut
	Next

	$BottomL[0] = $aFinal[0]
	$BottomL[1] = $aFinal[1]

	Local $BuilderBaseDiamond[6] = [550, $Top, $Right, $BottomR, $BottomL, $Left]
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
		; If $Y[0] >= $g_aiDeployableLRTB[3] Then ContinueLoop
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
		; If $Y[0] >= $g_aiDeployableLRTB[3] Then ContinueLoop
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

; SearchZoomOutBB returns always an Array.
; If village can be measured and villages size < 500 pixel then it returns in idx 0 a String starting with "zoomout:" and tries to center base
; Return Array:
; 0 = Empty string if village cannot be measured (e.g. window blocks village or not zoomed out)
; 1 = Current Village X Offset (after centering village)
; 2 = Current Village Y Offset (after centering village)
; 3 = Difference of previous Village X Offset and current (after centering village)
; 4 = Difference of previous Village Y Offset and current (after centering village)
Func SearchZoomOutBB($CenterVillageBoolOrScrollPos = $aCenterEnemyVillageClickDrag, $UpdateMyVillage = True, $sSource = "", $CaptureRegion = True, $DebugLog = $g_bDebugSetlog)
	If Not $g_bRunState Then Return
	If $sSource <> "" Then $sSource = " (" & $sSource & ")"
	Local $bCenterVillage = $CenterVillageBoolOrScrollPos
	If $bCenterVillage = Default Or $g_bDebugDisableVillageCentering Then $bCenterVillage = (Not $g_bDebugDisableVillageCentering)
	Local $aScrollPos[2] = [0, 0]
	If UBound($CenterVillageBoolOrScrollPos) >= 2 Then
		$aScrollPos[0] = $CenterVillageBoolOrScrollPos[0]
		$aScrollPos[1] = $CenterVillageBoolOrScrollPos[1]
		$bCenterVillage = (Not $g_bDebugDisableVillageCentering)
	EndIf

	; Setup arrays, including default return values for $return
	Local $x, $y, $z, $stone[2]
	Local $villageSize = 0

	If $CaptureRegion Then _CaptureRegion2()

 	Local $aResult = ["", 0, 0, 0, 0] ; expected dummy value
	Local $bUpdateSharedPrefs = False

	Static $iCallCount = 0

	Local $village = GetVillageSize($DebugLog, "stone", "tree", Default, True, $CaptureRegion)

	If $g_aiSearchZoomOutCounter[0] > 0 Then
		If _Sleep(1000) Then
			$iCallCount = 0
			Return SetError(1, 0, $aResult)
		EndIf
	EndIf

	If IsArray($village) = 1 Then
		$villageSize = $village[0]
		If $villageSize < 750 Or $g_bDebugDisableZoomout Then ; xbebenk
			$z = $village[1]
			$x = $village[2]
			$y = $village[3]
			$stone[0] = $village[4]
			$stone[1] = $village[5]
			$aResult[0] = "zoomout:" & $village[6]
			$aResult[1] = $x
			$aResult[2] = $y
			$g_bAndroidZoomoutModeFallback = False

			If $UpdateMyVillage Then
				If $x <> $g_iVILLAGE_OFFSET[0] Or $y <> $g_iVILLAGE_OFFSET[1] Or $z <> $g_iVILLAGE_OFFSET[2] Then
					If $DebugLog Then SetDebugLog("Village Offset" & $sSource & " updated to " & $x & ", " & $y & ", " & $z)
				EndIf
				setVillageOffset($x, $y, $z)
				ConvertInternalExternArea() ; generate correct internal/external diamond measures
			EndIf
		EndIf
	EndIf

	Return $aResult
EndFunc   ;==>SearchZoomOutBB

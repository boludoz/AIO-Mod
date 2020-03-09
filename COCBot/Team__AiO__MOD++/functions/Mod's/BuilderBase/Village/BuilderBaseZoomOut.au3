; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseZoomOutOn
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseZoomOutOnAttack()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (03-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
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

;~ Func TestBuilderBaseZoomOut()
;~ 	Setlog("** TestBuilderBaseZoomOutOnAttack START**", $COLOR_DEBUG)
;~ 	Local $Status = $g_bRunState
;~ 	$g_bRunState = True
;~ 	BuilderBaseZoomOut(True)
;~ 	$g_bRunState = $Status
;~ 	Setlog("** TestBuilderBaseZoomOutOnAttack END**", $COLOR_DEBUG)
;~ EndFunc   ;==>TestBuilderBaseZoomOut

;~ Func BuilderBaseZoomOut($DebugImage = False, $ForceZoom = False)

;~ 	Local $Size = GetBuilderBaseSize(False, $DebugImage) ; WihtoutClicks
;~ 	If $Size > 560 And $Size < 620 and Not $ForceZoom Then
;~ 		SetDebugLog("BuilderBaseZoomOut check!")
;~ 		Return True
;~ 	EndIf

;~ 	; Small loop just in case
;~ 	For $i = 0 To 5
;~ 		; Necessary a small drag to Up and right to get the Stone and Boat Images, Just once , coz in attack will display a red text and hide the boat
;~ 		If $i = 0 Or $i = 3 Then ClickDrag(100, 130, 230, 30)

;~ 		; Update shield status
;~ 		AndroidShield("AndroidOnlyZoomOut")
;~ 		; Run the ZoomOut Script
;~ 		If BuilderBaseSendZoomOut(False, $i) Then
;~ 			For $i = 0 To 5
;~ 				If _Sleep(500) Then ExitLoop
;~ 				If Not $g_bRunState Then Return
;~ 				; Get the Distances between images
;~ 				Local $Size = GetBuilderBaseSize(True, $DebugImage)
;~ 				SetDebugLog("[" & $i & "]BuilderBaseZoomOut $Size: " & $Size)
;~ 				If IsNumber($Size) And $Size > 0 Then ExitLoop
;~ 			Next
;~ 			; Can't be precise each time we enter at Builder base was deteced a new Zoom Factor!! from 563-616
;~ 			If $Size > 560 And $Size < 620 Then
;~ 				Return True
;~ 			EndIf
;~ 		Else
;~ 			SetDebugLog("[BBzoomout] Send Script Error!", $COLOR_DEBUG)
;~ 		EndIf
;~ 	Next
;~ 	Return False
;~ EndFunc   ;==>BuilderBaseZoomOut

;~ Func BuilderBaseSendZoomOut($Main = False, $i = 0)
;~ 	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
;~ 	If Not $g_bRunState Then Return
;~ 	Local $cmd = CorrectZoomoutScript($Main)
;~ 	; $cmd = Default, $timeout = Default, $wasRunState = Default, $EnsureShellInstance = True, $bStripPrompt = True, $bNoShellTerminate = False
;~ 	AndroidAdbSendShellCommand($cmd, 7000, Default, False)
;~ 	If @error <> 0 Then Return False
;~ 	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
;~ 	Return True
;~ EndFunc   ;==>BuilderBaseSendZoomOut

Func BuilderBaseZoomOut()
	SetDebugLog("BuilderBaseZoomOut")
	If Not $g_bRunState Then Return
	ZoomOut()
	Return (_ArraySearch(SearchZoomOut(), "") <> 0)
EndFunc   ;==>BuilderBaseSendZoomOut

Func GetBuilderBaseSize($WithClick = False, $DebugImage = False)

	  If Not $g_bRunState Then Return

	  ZoomOut()
	  Local $aVillage = GetVillageSize($DebugImage, "stone", "tree", Default, True)

	  If $aVillage <> 0 Then
		 $g_aBoatPos[0] = Int($aVillage[7])
		 $g_aBoatPos[1] = Int($aVillage[8])

		 Local $aResul = Floor(Village_Distances($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
		 Return $aResul

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

;~ ; AIO ++ Code
;~ Func CorrectZoomoutScript($Main = True)
;~ 	If Not $g_bRunState Then Return

;~ 	; Over the Water , Bottom Left , Main Village
;~ 	Local $aLeftFingerFirstSpot = [160, 610 + 44]

;~ 	If Not $Main Then
;~ 		; To Top Left , Builder Base compatibility
;~ 		$aLeftFingerFirstSpot[1] = 255 + 44
;~ 	EndIf

;~ 	Return ReturnZoomScript($aLeftFingerFirstSpot[0], $aLeftFingerFirstSpot[1])

;~ EndFunc   ;==>CorrectZoomoutScript

;Func ReturnZoomScript($x, $y)
;
;	; BlueStacks doesn't have the absolute px coordinates needs some math
;	Local $iXCoef = $g_sAndroidEmulator = "BlueStacks2" ? 38 : 1
;	Local $iYCoef = $g_sAndroidEmulator = "BlueStacks2" ? 49 : 1
;	Local $iStepCoef = $g_sAndroidEmulator = "BlueStacks2" ? 10 : 5
;	Local $sSep = ";"
;
;#Tidy_Off
;	If $y < 121 then $y = 121 												; the Right Finger is $y - 120 can't be negative
;	If $x > 739 Then $x = 739 												; the Right Finger is $x + 120 can't be more than 860
;
;	Local $aLeftFingerFirstSpot = [$x * $iXCoef, $y * $iYCoef]
;
;	Local $aRightFingerFirstSpot = [$aLeftFingerFirstSpot[0] + (120 * $iXCoef), $aLeftFingerFirstSpot[1] - (120 * $iYCoef)]
;	Local $sScript = ""
;
;	; BlueStacks doesn't need the Send touch event and pressure of the touch
;	If $g_sAndroidEmulator = "BlueStacks2" Then
;		$sScript &= "sendevent $1 3 57 0" & $sSep 							; ID of the touch
;	Else
;		$sScript &= "sendevent $1 1 330 1" & $sSep 							; 1 330 1 - Send touch event EV_KEY BTN_TOUCH DOWN
;		$sScript &= "sendevent $1 3 58 1" & $sSep 							; (58) - pressure of the touch
;	EndIf
;
;	For $Step = 0 To 30 Step $iStepCoef
;		Local $LeftFingerSpot[2] = [$aLeftFingerFirstSpot[0] + ($Step * $iXCoef), $aLeftFingerFirstSpot[1] - ($Step * $iYCoef)]
;		Local $RightFingerSpot[2] = [$aRightFingerFirstSpot[0] - ($Step * $iXCoef), $aRightFingerFirstSpot[1] + ($Step * $iYCoef)]
;		$sScript &= "sendevent $1 3 53 " & $LeftFingerSpot[0] & $sSep 		; Xaxis LF (3) EV_ABS [touch device driver] - (53) - x coordinate of the touch
;		$sScript &= "sendevent $1 3 54 " & $LeftFingerSpot[1] & $sSep 		; Yaxis LF (3) EV_ABS [touch device driver] - (54) - y coordinate of the touch
;		$sScript &= "sendevent $1 0 2 0" & $sSep							; (2) - end of separate touch data
;		$sScript &= "sendevent $1 3 53 " & $RightFingerSpot[0] & $sSep 		; Xaxis RF (3) EV_ABS [touch device driver] - (53) - x coordinate of the touch
;		$sScript &= "sendevent $1 3 54 " & $RightFingerSpot[1] & $sSep 		; Yaxis RF (3) EV_ABS [touch device driver] - (54) - y coordinate of the touch
;		$sScript &= "sendevent $1 0 2 0" & $sSep							; (2) - end of separate touch data
;		$sScript &= "sendevent $1 0 0 0" & $sSep 							; (0) - end of Group
;	Next
;
;	If $g_sAndroidEmulator = "BlueStacks2" Then
;		$sScript &= "sendevent $1 3 57 -1" & $sSep  						; To let the input device know that all previous touches have been released
;		$sScript &= "sendevent $1 0 2 0" & $sSep
;		$sScript &= "sendevent $1 0 0 0" & $sSep
;	Else
;		$sScript &= "sendevent $1 1 330 0" & $sSep 							; 1 330 0 - Send release finger event EV_KEY BTN_TOUCH UP
;		$sScript &= "sendevent $1 0 0 0" & $sSep
;	EndIf
;#Tidy_On
;
;	Return StringReplace($sScript, "$1", $g_sAndroidMouseDevice)
;EndFunc   ;==>ReturnZoomScript

Func DebugZoomOutBB($x, $y, $x1, $y1, $aBoat, $DebugText)

	_CaptureRegion2()
	Local $subDirectory = $g_sProfileTempDebugPath & "QuickMIS"
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
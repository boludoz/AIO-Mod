; #FUNCTION# ====================================================================================================================
; Name ..........: _Wait4Pixel
; Description ...:
; Author ........: Samkie
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func _Wait4Pixel($x, $y, $sColor, $iColorVariation, $iWait = 1000, $iDelay = 100, $sMsglog = Default) ; Return true if pixel is true
	Local $hTimer = __TimerInit()
	While (BitOR($iWait > __TimerDiff($hTimer), ($iWait <= 0)) > 0) ; '-1' support
		ForceCaptureRegion()
		If _CheckColorPixel($x, $y, $sColor, $iColorVariation, True, $sMsglog) Then Return True
		If _Sleep($iDelay) Then Return False
		If ($iWait <= 0) Then ExitLoop ; Loop prevention.
	WEnd
	Return False
EndFunc   ;==>_Wait4Pixel

Func _Wait4PixelGone($x, $y, $sColor, $iColorVariation, $iWait = 1000, $iDelay = 100, $sMsglog = Default) ; Return true if pixel is false
	; We can only affirm what is not true.
	Return (Not _Wait4Pixel($x, $y, $sColor, $iColorVariation, $iWait, $iDelay, $sMsglog))
EndFunc   ;==>_Wait4PixelGone

Func _CheckColorPixel($x, $y, $sColor, $iColorVariation, $bFCapture = True, $sMsglog = Default)
	Local $hPixelColor = _GetPixelColor2($x, $y, $bFCapture)
	Local $bFound = _ColorCheck($hPixelColor, Hex($sColor, 6), Int($iColorVariation))
	#cs - Fast
	Local $COLORMSG = ($bFound = True ? $COLOR_BLUE : $COLOR_RED)
	If $sMsglog <> Default And IsString($sMsglog) Then
		Local $String = $sMsglog & " - Ori Color: " & Hex($sColor,6) & " at X,Y: " & $x & "," & $y & " Found: " & $hPixelColor
		If $g_bDebugSetlog Then SetDebugLog($String, $COLORMSG)
	EndIf
	#ce - Fast
	Return $bFound
EndFunc   ;==>_CheckColorPixel

Func _GetPixelColor2($iX, $iY, $bNeedCapture = False)
	Local $aPixelColor = 0
	If $bNeedCapture = False Or $g_bRunState = False Then
		$aPixelColor = _GDIPlus_BitmapGetPixel($g_hBitmap, $iX, $iY)
	Else
		_CaptureRegion($iX - 1, $iY - 1, $iX + 1, $iY + 1)
		$aPixelColor = _GDIPlus_BitmapGetPixel($g_hBitmap, 1, 1)
	EndIf
	Return Hex($aPixelColor, 6)
EndFunc   ;==>_GetPixelColor2

; #FUNCTION# ====================================================================================================================
; Name ..........: MultiPSimple
; Description ...:
; Author ........: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func MultiPSimple($iLeft, $iTop, $iRight, $iBottom, $iHex, $iTolerance = 15, $iWait = 5000, $iDelay = 50, $bCapture = True)
	Local $aReturn[2] = [0, 0]

	Local $hTimer = __TimerInit()
	While (BitOR($iWait > __TimerDiff($hTimer), ($iWait <= 0)) > 0) ; '-1' support
		If _Sleep($iDelay) Then Return False
		
		Local $xRange
		Local $yRange

		If ($iLeft < $iRight) Then
			;Setlog("next")
			_CaptureRegion($iLeft, $iTop, $iRight, $iBottom)
			$xRange = Abs($iRight - $iLeft)
			$yRange = Abs($iBottom - $iTop)
			;Setlog("1. "&$xRange&" "&$yRange)
			For $x = 0 To $xRange
				For $y = 0 To $yRange
					;Setlog("2. "&$x&" "&$y)
					If _ColorCheck(_GetPixelColor($x, $y, $bCapture), $iHex, $iTolerance) Then
						$aReturn[0] = $x + $iLeft
						$aReturn[1] = $y + $iTop
						Return $aReturn
					EndIf
				Next
			Next
		Else
			;Setlog("back")
			_CaptureRegion($iRight, $iBottom, $iLeft, $iTop)
			$xRange = Abs($iRight - $iLeft)
			$yRange = Abs($iBottom - $iTop)
			;Setlog("1. "&$xRange&" "&$yRange)
			For $x = $xRange To 0 Step -1
				For $y = $yRange To 0 Step -1
					;Setlog("2. "&$x&" "&$y)
					If _ColorCheck(_GetPixelColor($x, $y, $bCapture), $iHex, $iTolerance) Then
						$aReturn[0] = $x + $iRight
						$aReturn[1] = $y + $iBottom
						Return $aReturn
					EndIf
				Next
			Next
		EndIf
		
		If ($iWait <= 0) Then ExitLoop ; Loop prevention.
	WEnd

	Return 0
EndFunc   ;==>MultiPSimple

; #FUNCTION# ====================================================================================================================
; Name ..........: _Wait4PixelArray & _Wait4PixelGoneArray
; Description ...: Put array and return true or false if pixel is not found in time + delay.
; Author ........: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _Wait4PixelArray($aSettings) ; Return true if pixel is true
	Local $x = $aSettings[0]
	Local $y = $aSettings[1]
	Local $sColor = $aSettings[2]
	Local $iColorVariation = (UBound($aSettings) > 3) ? ($aSettings[3]) : (15)
	Local $iWait = (UBound($aSettings) > 4) ? ($aSettings[4]) : (1000)
	Local $iDelay = (UBound($aSettings) > 5) ? ($aSettings[5]) : (100)
	Local $sMsglog = (UBound($aSettings) > 6) ? ($aSettings[6]) : (Default)
	
	Local $hTimer = __TimerInit()
	While (BitOR($iWait > __TimerDiff($hTimer), ($iWait <= 0)) > 0) ; '-1' support
		ForceCaptureRegion()
		If _CheckColorPixel($x, $y, $sColor, $iColorVariation, True, $sMsglog) Then Return True
		If _Sleep($iDelay) Then Return False
		If ($iWait <= 0) Then ExitLoop ; Loop prevention.
	WEnd
	Return False
EndFunc   ;==>_Wait4PixelArray

Func _Wait4PixelGoneArray($aSettings) ; Return true if pixel is false
	; We can only affirm what is not true. What part are you missing ?.
	Return (Not _Wait4PixelArray($aSettings))
EndFunc   ;==>_Wait4PixelGoneArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _WaitForCheckImg & _WaitForCheckImgGone
; Description ...: Return true if img. is found in time (_WaitForCheckImg) or if img. is not found in time (_WaitForCheckImgGone).
; Author ........: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: You can use multiple img. in a folder and find ($aText = "a|b|c|d").
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _WaitForCheckImg($sPathImage, $sSearchZone = Default, $aText = Default, $iWait = 2000, $iDelay = 250)
	If $iWait = Default Then $iWait = 2000
	If $iDelay = Default Then $iDelay = 250

	Local $hTimer = __TimerInit()
	Do
		Local $aRetutn = findMultipleQuick($sPathImage, 50, $sSearchZone, True, $aText)
		If $aRetutn <> -1 Then Return True
		If _Sleep($iDelay) Then Return False
	Until ($iWait < __TimerDiff($hTimer))
	Return False
EndFunc   ;==>_WaitForCheckImg

Func _WaitForCheckImgGone($sPathImage, $sSearchZone = Default, $aText = Default, $iWait = 2000, $iDelay = 250)
	; We can only affirm what is not true. Denial must be comprehensive.
	Return (Not _WaitForCheckImgGone($sPathImage, $sSearchZone, $aText, $iWait, $iDelay)
EndFunc   ;==>_WaitForCheckImg
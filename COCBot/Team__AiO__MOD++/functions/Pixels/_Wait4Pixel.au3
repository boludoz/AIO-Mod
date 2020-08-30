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
	Return _Wait4Pixel($x, $y, $sColor, $iColorVariation, $iWait, $iDelay, $sMsglog) = False
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
	Return _Wait4PixelArray($aSettings) = False
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
	Return _WaitForCheckImg($sPathImage, $sSearchZone, $aText, $iWait, $iDelay) = False
EndFunc   ;==>_WaitForCheckImgGone

; #FUNCTION# ====================================================================================================================
; Name ..........: CompareCie2000
; Description ...: Cie2000 human color difference for pixels.
; Author ........: Boldina !, Inspired in Dissociable, translated from python (JAMES MASON).
; 				   https://en.wikipedia.org/wiki/Color_difference
; 				   https://raw.githubusercontent.com/sumtype/CIEDE2000/master/ciede2000.py
;				   https://github.com/markusn/color-diff
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; _ColorCheckCie2000(0x00FF00, 0x00F768, 5) ; 4.74575054233923 ; Old | 6.66013616882879 | 3.25675649923578
Func _ColorCheckCie2000($nColor1 = 0x00FF00, $nColor2 = 0x00FF6C, $sVari = 5, $Ignore = Default)
	Local $iPixelDiff = ciede2000(xyz2lab(StandardRGBXTOXZY($nColor1)), xyz2lab(StandardRGBXTOXZY($nColor2)))
	If $g_bDebugSetlog Then SetLog("_ColorCheckCie2000 | $iPixelDiff " & $iPixelDiff, $COLOR_INFO)
	If $iPixelDiff > $sVari Then
		Return False
	EndIf
	
	Return True
EndFunc   ;==>_ColorCheckCie2000

; XYZ - D65 / 10° - 1964
Func StandardRGBXTOXZY($nColor)
	Local $aRGB[3] = [Dec(StringMid(String($nColor), 1, 2)), Dec(StringMid(String($nColor), 3, 2)), Dec(StringMid(String($nColor), 5, 2))]
	For $i = 0 To 2
		$aRGB[$i] /= 255
		If ($aRGB[$i] > 0.04045) Then
			$aRGB[$i] = ((($aRGB[$i] + 0.055) / 1.055) ^ 2.4)
		Else
			$aRGB[$i] = ($aRGB[$i] / 12.92)
		EndIf
		$aRGB[$i] *= 100
	Next
	Local $aXYZ[3] = [Null, Null, Null]
	$aXYZ[0] = $aRGB[0] * 0.412453 + $aRGB[1] * 0.357580 + $aRGB[2] * 0.180423
	$aXYZ[1] = $aRGB[0] * 0.212671 + $aRGB[1] * 0.715160 + $aRGB[2] * 0.072169
	$aXYZ[2] = $aRGB[0] * 0.019334 + $aRGB[1] * 0.119193 + $aRGB[2] * 0.950227
	; _ArrayDisplay($aXYZ)
	Return $aXYZ
EndFunc   ;==>StandardRGBXTOXZY

; xyz2lab(StandardRGBXTOXZY(0xFFFFFF))
; Converts XYZ pixel array to LAB format.
; Implementation derived from http://www.easyrgb.com/en/math.php
Func xyz2lab($aXYZ)
	$aXYZ[0] /= 95.047
	$aXYZ[1] /= 100
	$aXYZ[2] /= 108.883
	For $i = 0 To 2
		If $aXYZ[$i] > 0.008856 Then
			$aXYZ[$i] = $aXYZ[$i] ^ (1 / 3)
		Else
			$aXYZ[$i] = (7.787 * $aXYZ[$i]) + (16 / 116)
		EndIf
	Next
	Local $aLab[3] = [Null, Null, Null]
	$aLab[0] = (116 * $aXYZ[1]) - 16.0
	$aLab[1] = 500 * ($aXYZ[0] - $aXYZ[1])
	$aLab[2] = 200 * ($aXYZ[1] - $aXYZ[2])
	; _ArrayDisplay($aLab)
	Return $aLab
EndFunc   ;==>xyz2lab

Func ciede2000($laB1, $laB2)
	Static $kL = 1, $kC = 1, $kH = 1, $aC1C2 = 0, _
			$G = 0, $A1P = 0, $A2P = 0, $c1P = 0, $c2P = 0, $h1p = 0, $h2p = 0, $dLP = 0, $dCP = 0, $dhP = 0, $aL = 0, _
			$aCP = 0, $aHP = 0, $T = 0, $dRO = 0, $rC = 0, $sL = 0, $sC = 0, $sH = 0, $rT = 0, $c1 = 0, $c2 = 0
	
	$c1 = Sqrt(($laB1[1] ^ 2.0) + ($laB1[2] ^ 2.0))
	$c2 = Sqrt(($laB2[1] ^ 2.0) + ($laB2[2] ^ 2.0))
	$aC1C2 = ($c1 + $c2) / 2.0
	$G = 0.5 * (1.0 - Sqrt(($aC1C2 ^ 7.0) / (($aC1C2 ^ 7.0) + (25.0 ^ 7.0))))
	$A1P = (1.0 + $G) * $laB1[1]
	$A2P = (1.0 + $G) * $laB2[1]
	$c1P = Sqrt(($A1P ^ 2.0) + ($laB1[2] ^ 2.0))
	$c2P = Sqrt(($A2P ^ 2.0) + ($laB2[2] ^ 2.0))
	$h1p = hpf($laB1[2], $A1P)
	$h2p = hpf($laB2[2], $A2P)
	$dLP = $laB2[0] - $laB1[0]
	$dCP = $c2P - $c1P
	$dhP = dhpf($c1, $c2, $h1p, $h2p)
	$dhP = 2.0 * Sqrt($c1P * $c2P) * Sin(_Radian($dhP) / 2.0)
	$aL = ($laB1[0] + $laB2[0]) / 2.0
	$aCP = ($c1P + $c2P) / 2.0
	$aHP = ahpf($c1, $c2, $h1p, $h2p)
	$T = 1.0 - 0.17 * Cos(_Radian($aHP - 39)) + 0.24 * Cos(_Radian(2.0 * $aHP)) + 0.32 * Cos(_Radian(3.0 * $aHP + 6.0)) - 0.2 * Cos(_Radian(4.0 * $aHP - 63.0))
	$dRO = 30.0 * Exp(-1.0 * ((($aHP - 275.0) / 25.0) ^ 2.0))
	$rC = Sqrt(($aCP ^ 7.0) / (($aCP ^ 7.0) + (25.0 ^ 7.0)))
	$sL = 1.0 + ((0.015 * (($aL - 50.0) ^ 2.0)) / Sqrt(20.0 + (($aL - 50.0) ^ 2.0)))
	$sC = 1.0 + 0.045 * $aCP
	$sH = 1.0 + 0.015 * $aCP * $T
	$rT = -2.0 * $rC * Sin(_Radian(2.0 * $dRO))
	Return Sqrt((($dLP / ($sL * $kL)) ^ 2.0) + (($dCP / ($sC * $kC)) ^ 2.0) + (($dhP / ($sH * $kH)) ^ 2.0) + $rT * ($dCP / ($sC * $kC)) * ($dhP / ($sH * $kH)))
EndFunc   ;==>ciede2000

Func hpf($x, $y)
	Static $tmphp
	If $x = 0 And $y = 0 Then
		Return 0
	Else
		$tmphp = _Degree((2 * ATan($y / ($x + Sqrt($x * $x + $y * $y)))))
	EndIf
	
	If $tmphp >= 0 Then
		Return $tmphp
	Else
		Return $tmphp + 360.0
	EndIf
	Return Null
EndFunc   ;==>hpf

Func dhpf($c1, $c2, $h1p, $h2p)
	If $c1 * $c2 = 0 Then
		Return 0
	ElseIf Abs($h2p - $h1p) <= 180 Then
		Return $h2p - $h1p
	ElseIf $h2p - $h1p > 180 Then
		Return ($h2p - $h1p) - 360.0
	ElseIf $h2p - $h1p < 180 Then
		Return ($h2p - $h1p) + 360.0
	EndIf
	Return Null
EndFunc   ;==>dhpf

Func ahpf($c1, $c2, $h1p, $h2p)
	If $c1 * $c2 = 0 Then
		Return $h1p + $h2p
	ElseIf Abs($h1p - $h2p) <= 180 Then
		Return ($h1p + $h2p) / 2.0
	ElseIf Abs($h1p - $h2p) > 180 And $h1p + $h2p < 360 Then
		Return ($h1p + $h2p + 360.0) / 2.0
	ElseIf Abs($h1p - $h2p) > 180 And $h1p + $h2p >= 360 Then
		Return ($h1p + $h2p - 360.0) / 2.0
	EndIf
	Return Null
EndFunc   ;==>ahpf
; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: Boju(2016)
; Modified ......: Boldina ! (2020) (Random click is disabled to avoid out of screen.)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func ClickZone($x, $y, $Offset = 7, $debugtxt = "", $times = 1, $speed = 0, $OutScreen = $g_iDEFAULT_HEIGHT, $scale = 4, $density = 1, $centerX = 0, $centerY = 0)
	Local $bRandomStatus = $g_bUseRandomClick
	$g_bUseRandomClick = False
	Local $BasY
	If $y-$Offset > $OutScreen Then
		$BasY = $y
	Else
		$BasY = $y-$Offset
	EndIf
	Dim $g_aiTempBot[4] = [$x-$Offset, $BasY, $x+$Offset, $y+$Offset]
	If $g_bDebugClick Then
		Local $txt = _DecodeDebug($debugtxt)
		SetLog("ClickZone " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ACTION, "Verdana", "7.5", 0)
	EndIf
	ClickR($g_aiTempBot,$x, $y, $times, $speed, $OutScreen, $scale, $density, $centerX, $centerY)
	$g_bUseRandomClick = $bRandomStatus
EndFunc

Func ClickR($boundingBox, $x, $y, $times = 1, $speed = 0, $OutScreen = $g_iDEFAULT_HEIGHT, $iScaled = 2, $bRandomLoop = True, $centerX = 0, $centerY = 0)
	Local $bRandomStatus = $g_bUseRandomClick
	$g_bUseRandomClick = False

	Local $AncVal = " ValIn: X=" & $x & " Y=" & $y
	Local $boxWidth = $boundingBox[2] - $boundingBox[0]
	Local $boxHeight = $boundingBox[3] - $boundingBox[1]
	Local $boxCenterX = $boundingBox[0] + $boxWidth/2 + $centerX
	Local $boxCenterY = $boundingBox[1] + $boxHeight/2 + $centerY
	Local $aOriginal[2] = [$x, $y]
	$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
	$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
	$x += $boxCenterX
	$y += $boxCenterY
	
	Local $aLast[2] = [$x, $y]
	Local $iOut = 0, $i = 0
	Do
		If Not $g_bRunState Or $g_bRestart Then Return
		If $y > $OutScreen Or $iOut > 3 Then
			$x = $aOriginal[0]
			$y = $aOriginal[1]
			$iOut = 0
		EndIf
		
		If $bRandomLoop = True Or $iOut > 0 Then
			$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
			$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
			$x += $boxCenterX
			$y += $boxCenterY
		EndIf
		
		If (($boundingBox[0] > $x Or $boundingBox[2] < $x) Or ($boundingBox[1] > $y Or $boundingBox[3] < $y)) Then
			$iOut += 1
			ContinueLoop
		EndIf
			
		$x = Round($x, 3)
		$y = Round($y, 3)
		
		If $g_bDebugClick Then SetLog("_ControlClick " & "X=" & $x & " Y=" & $y & " ,t" & $times & ",s" & $speed & $AncVal, $COLOR_ACTION)
		Click($x, $y)
		
		$i += 1
	Until $i > ($times - 1) Or RandomSleep($speed)
	$g_bUseRandomClick = $bRandomStatus
EndFunc   ;==>ClickR

Func PureClickR($boundingBox, $x, $y, $times = 1, $speed = 0, $OutScreen = $g_iDEFAULT_HEIGHT, $iScaled = 3, $bRandomLoop = True, $centerX = 0, $centerY = 0)
	Local $bRandomStatus = $g_bUseRandomClick
	$g_bUseRandomClick = False
	
	Local $AncVal = " ValIn: X=" & $x & " Y=" & $y
	Local $boxWidth = $boundingBox[2] - $boundingBox[0]
	Local $boxHeight = $boundingBox[3] - $boundingBox[1]
	Local $boxCenterX = $boundingBox[0] + $boxWidth/2 + $centerX
	Local $boxCenterY = $boundingBox[1] + $boxHeight/2 + $centerY
	Local $aOriginal[2] = [$x, $y]
	$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
	$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
	$x += $boxCenterX
	$y += $boxCenterY
	
	Local $aLast[2] = [$x, $y]
	Local $iOut = 0, $i = 0
	Do
		If Not $g_bRunState Or $g_bRestart Then Return
		If $y > $OutScreen Or $iOut > 3 Then
			$x = $aOriginal[0]
			$y = $aOriginal[1]
			$iOut = 0
		EndIf
		
		If $bRandomLoop = True Or $iOut > 0 Then
			$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
			$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
			$x += $boxCenterX
			$y += $boxCenterY
		EndIf
		
		If (($boundingBox[0] > $x Or $boundingBox[2] < $x) Or ($boundingBox[1] > $y Or $boundingBox[3] < $y)) Then
			$iOut += 1
			ContinueLoop
		EndIf
			
		$x = Round($x, 3)
		$y = Round($y, 3)
		
		If $g_bDebugClick Then SetLog("PureClick " & "X=" & $x & " Y=" & $y & " ,t" & $i + 1 & ",s" & $speed & $AncVal, $COLOR_ACTION)
		PureClick($x, $y)
		
		$i += 1
	Until $i > ($times - 1) Or RandomSleep($speed)
	$g_bUseRandomClick = $bRandomStatus
EndFunc   ;==>ClickR

Func GemClickR($boundingBox,$x, $y, $times = 1, $speed = 0, $debugtxt = "", $OutScreen = $g_iDEFAULT_HEIGHT, $bRandomLoop = True, $density = 1, $centerX = 0, $centerY = 0)
	Local $AncVal = " ValIn: X=" & $x & " Y=" & $y
	Local $boxWidth = $boundingBox[2] - $boundingBox[0]
	Local $boxHeight = $boundingBox[3] - $boundingBox[1]
	Local $boxCenterX = $boundingBox[0] + $boxWidth/2 + $centerX
	Local $boxCenterY = $boundingBox[1] + $boxHeight/2 + $centerY
	If $g_bDebugClick Then
		Local $txt = _DecodeDebug($debugtxt)
		SetLog("GemClickR " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ACTION)
	EndIf
	
	Local $aOriginal[2] = [$x, $y]
	$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
	$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
	$x += $boxCenterX
	$y += $boxCenterY
	
	Local $bSuspendMode, $bReturn
	If $g_bAndroidAdbClick = True Then $bSuspendMode = ResumeAndroid()

	Local $aLast[2] = [$x, $y]
	Local $iOut = 0, $i = 0
	Do
		If Not $g_bRunState Or $g_bRestart Then Return
		If $y > $OutScreen Or $iOut > 3 Then
			$x = $aOriginal[0]
			$y = $aOriginal[1]
			$iOut = 0
		EndIf
		
		If $bRandomLoop = True Or $iOut > 0 Then
			$x = (($boxWidth/2 + $centerX) / $iScaled) * random(-1, 1)
			$y = (($boxHeight/2 + $centerY) / $iScaled) * random(-1, 1)
			$x += $boxCenterX
			$y += $boxCenterY
		EndIf
		
		If (($boundingBox[0] > $x Or $boundingBox[2] < $x) Or ($boundingBox[1] > $y Or $boundingBox[3] < $y)) Then
			$iOut += 1
			ContinueLoop
		EndIf
			
		$x = Round($x, 3)
		$y = Round($y, 3)
				
		If $g_bAndroidAdbClick = True Then
		   If isGemOpen(True) Then
			  $bReturn = False
			  ExitLoop
		   EndIf
		   AndroidClick($x, $y, 1, 0)
		   ContinueLoop
		EndIf

		If isGemOpen(True) Then
			  $bReturn = False
			  ExitLoop
		EndIf
		If isProblemAffectBeforeClick($i) Then
			If $g_bDebugClick Then SetLog("VOIDED GemClickR " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ERROR, "Verdana", "7.5", 0)
			checkMainScreen(False)
			$bReturn = 0  ; if need to clear screen do not click
			ExitLoop
		EndIf
		MoveMouseOutBS()
		_ControlClick($x, $y)
		If isGemOpen(True) Then
			$bReturn = False
			ExitLoop
		EndIf
		If RandomSleep($speed) Then ExitLoop
		
		$i += 1
	Until $i > ($times - 1) Or RandomSleep($speed)
	$g_bUseRandomClick = $bRandomStatus
	If $g_bAndroidAdbClick = True Then 
		SuspendAndroid($bSuspendMode)
	EndIf
	Return $bReturn
EndFunc   ;==>GemClickR
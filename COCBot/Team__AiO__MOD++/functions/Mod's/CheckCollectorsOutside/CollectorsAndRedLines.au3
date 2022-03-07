; FUNCTION ====================================================================================================================
; Name ..........: CollectorsAndRedLines
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: True					More collectors outside than specified.
;				 : False				less collectors outside than specified.
; Author ........: Samkie (13 Jan 2017) & Team AiO MOD++ (2020/2021)
; Modified ......: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================
Func CollectorsAndRedLines($bForceCapture = False)
	Local $bReturn = False
	
	Local Const $imilkfarmoffsetxstep = 35
	Local Const $imilkfarmoffsetystep = 26
	Local $diamondx = $imilkfarmoffsetxstep + ($imilkfarmoffsetxstep * $g_iCmbRedlineTiles)
	Local $diamondy = $imilkfarmoffsetystep + ($imilkfarmoffsetystep * $g_iCmbRedlineTiles)
	Local $iPixelDistance = Pixel_Distance(0, 0, $diamondx, $diamondy)
	
	If $g_bDBMeetCollectorOutside Then
		Local $hTimer = TimerInit()
		Local $sText = ($g_bDBCollectorNearRedline And $g_bDBMeetCollectorOutside) ? ("Are collectors near redline ?") : ("Are collectors outside ?")
		If $bForceCapture = True Then _CaptureRegion2()
		
		Local $aAllCollectors = SmartFarmDetection("All", False, False)
		SetDebugLog("Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ACTION)
		Local $iOut = 0
		Local $iLocated = UBound($aAllCollectors)
		If $iLocated > 0 And not @error Then
			If $g_bDBCollectorNearRedline Then
				$iOut = AreCollectorsNearRedline($aAllCollectors)
			Else
				For $i = 0 To $iLocated - 1
					If ($aAllCollectors[$i][3] = "Out") Then $iOut += 1
				Next
			EndIf
			$bReturn = ($g_iDBMinCollectorOutsidePercent <= Round(Int(($iOut * 100) / $iLocated, 0)))
			SetLog($sText & " : " & $bReturn & " - Out: " & $iOut & " - Located: " & $iLocated, $COLOR_INFO)
		EndIf
	EndIf
	Return $bReturn
EndFunc   ;==>AreCollectorsOutside

; FUNCTION ====================================================================================================================
; Name ..........: AreCollectorsNearRedline
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: True					more collectors near redline
;				 : False				less collectors outside than specified
; Author ........: Samkie (7 FEB 2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func AreCollectorsNearRedline($aAllCollectors)
	; reset variables
	Local $iTotalCollectorNearRedline = 0
	
	ConvertInternalExternArea("CollectorsAndRedLines")
	_GetRedArea()

	Local $colNbr = UBound($aAllCollectors)
	
	Local Const $iMilkFarmOffsetX = 56
	Local Const $iMilkFarmOffsetY = 41
	Local Const $iMilkFarmOffsetXStep = 35
	Local Const $iMilkFarmOffsetYStep = 26
	
 	Local $iDiamondX = $iMilkFarmOffsetX + ($iMilkFarmOffsetXStep * $g_iCmbRedlineTiles)
 	Local $iDiamondY = $iMilkFarmOffsetY + ($iMilkFarmOffsetYStep * $g_iCmbRedlineTiles)
	
	Local $arrCollectorsFlag[0]
	Local $aPixelCoord[2], $aPixelCoord2[2]
	If $colNbr > 0 Then
		ReDim $arrCollectorsFlag[$colNbr]
		Local $iMaxRedArea = UBound($g_aiPixelRedArea) - 1
		For $i = 0 To $iMaxRedArea
			$aPixelCoord = $g_aiPixelRedArea[$i]
			For $j = 0 To $colNbr - 1
				If $arrCollectorsFlag[$j] <> True Then
					$aPixelCoord2[0] = $aAllCollectors[$j][0]
					$aPixelCoord2[1] = $aAllCollectors[$j][1]
					If Abs(($aPixelCoord[0] - $aPixelCoord2[0]) / $iDiamondX) + Abs(($aPixelCoord[1] - $aPixelCoord2[1]) / $iDiamondY) <= 1 Then
						$arrCollectorsFlag[$j] = True
						$iTotalCollectorNearRedline += 1
					EndIf
				EndIf
			Next
			If $iTotalCollectorNearRedline >= $colNbr Then ExitLoop
		Next
	EndIf
	Return $iTotalCollectorNearRedline
EndFunc

; FUNCTION ====================================================================================================================
; Name ..........: isOutsideEllipse
; Description ...: This function can test if a given coordinate is inside (True) or outside (False) the village grass borders (a diamond shape).
;                  It will also exclude some special area's like the CHAT tab, BUILDER button and GEM shop button.
; Syntax ........: isInsideDiamondXY($Coordx, $Coordy), isInsideDiamond($aCoords)
; Parameters ....: ($coordx, $coordY) as coordinates or ($aCoords), an array of (x,y) to test
; Return values .: True or False
; Author ........: McSlither (Jan-2016)
; Modified ......: TheRevenor (Jul-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: isInsideDiamond($aCoords)
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func isOutsideEllipse($coordX, $coordY, $ellipseWidth = 200, $ellipseHeigth = 150, $centerX = 430, $centerY = 335)

	Global $normalizedX = $coordX - $centerX
	Global $normalizedY = $coordY - $centerY
	Local $result = ($normalizedX * $normalizedX) / ($ellipseWidth * $ellipseWidth) + ($normalizedY * $normalizedY) / ($ellipseHeigth * $ellipseHeigth) > 1

	If $g_bDebugSetlog Then
		If $result Then
			SetDebugLog("Coordinate Outside Ellipse (" & $ellipseWidth & ", " & $ellipseHeigth & ")", $COLOR_DEBUG)
		Else
			SetDebugLog("Coordinate Inside Ellipse (" & $ellipseWidth & ", " & $ellipseHeigth & ")", $COLOR_DEBUG)
		EndIf
	EndIf

	Return $result

EndFunc   ;==>isOutsideEllipse

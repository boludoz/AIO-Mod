; #FUNCTION# ====================================================================================================================
; Name ..........: Boost a troop to super troop
; Description ...:
; Syntax ........: BoostSuperTroop()
; Parameters ....:
; Return values .:
; Author ........: xbebenk (08/2021), Boldina (08/2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostSuperTroop()
	Local $aAlreadyChecked[0]
	Local $aCmbTmp[2] = [_ArrayMin($g_iCmbSuperTroops, 1), _ArrayMax($g_iCmbSuperTroops, 1)]

	If Not $g_bSuperTroopsEnable Then
		Return False
	EndIf

	Local $iActive = 0
	For $i = 0 To 1
		If $g_iCmbSuperTroops[$i] > 0 Then
			$iActive += 1
		EndIf
	Next

	If $iActive = 0 Then
		SetLog("No troops have been selected to accelerate.", $COLOR_WARNING)
		Return False
	EndIf

	Local $bCheckBottom = False, $aBarD = 0
	Local $iIndex = -1, $aSuperT = -1, $aClock = -1, $aTmp = -1

	ClickAway()
	If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 0, 0, 220, 225, True, False) Then
		SetLog("Found Barrel at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_DEBUG)
		Click($g_iQuickMISX, $g_iQuickMISY, 1)
		
		Local $aColors[3][3] = [[0x685C50, 20, 0], [0x685C50, 100, 0], [0x685C50, 190, 15]]
		If IsSTPage() = True Then
			For $iBoosted = 1 To $iMaxSupersTroop
				$iIndex = -1
				_CaptureRegion2()
				Local $aSuperT = FindMultipleQuick($g_sImgBoostTroopsIcons, 0, "140, 235, 720, 565", False)
				Local $aClock = FindMultipleQuick($g_sImgBoostTroopsClock, 0, "140, 235, 720, 565", False)

				; Barra divisoria.
				$bCheckBottom = False
				$aBarD = _MultiPixelSearch(140, 320, 715, 560, 10, 1, Hex(0x685C50, 6), $aColors, 20)
				If $aBarD <> 0 Then
					If $aBarD[1] < 350 And $aBarD[1] > 385 Then
						$bCheckBottom = True
					EndIf
				EndIf

				If UBound($aSuperT) > 0 And Not @error Then
					For $iImgs = 0 To UBound($aSuperT) - 1
						If _ArraySearch($aAlreadyChecked, $aSuperT[$iImgs][0]) > -1 And Not @error Then
							SetDebuglog("Skip checked " & $aSuperT[$iImgs][0] & ".", $COLOR_DEBUG)
							ContinueLoop
						ElseIf $bCheckBottom = False And $aSuperT[$iImgs][2] > $aBarD[1] Then
							SetDebuglog("Skip bottom " & $aSuperT[$iImgs][0] & ".", $COLOR_DEBUG)
							ContinueLoop
						EndIf

						If UBound($aClock) > 0 And Not @error Then
							For $iClocks = 0 To UBound($aClock) - 1
								; Check If is boosted
								If Pixel_Distance($aClock[$iClocks][1], $aClock[$iClocks][2], $aSuperT[$iImgs][1], $aSuperT[$iImgs][2]) > 164 And ($aClock[$iClocks][2] - $aSuperT[$iImgs][2]) > 0 Then
									SetLog($aSuperT[$iImgs][0] & " is boosted.", $COLOR_INFO)
									;;;
									ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
									$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
									;;;
									If $iActive = UBound($aAlreadyChecked) Then
										ExitLoop
									EndIf
									ContinueLoop 2
								EndIf
							Next
						EndIf

						For $i = 0 To 1
							If $aCmbTmp[$i] > 0 Then
								$iIndex = _ArraySearch($g_asTroopShortNames, $aSuperT[$iImgs][0])
								If Not @error And $iIndex > -1 Then
									For $sTring In $g_asSuperTroopNames
										If _CompareTexts($g_asTroopNamesPlural[$iIndex], $sTring) Then
											; Boost Here
											Click($aSuperT[$iImgs][1], $aSuperT[$iImgs][2], 1)
											If _Sleep(1500) Then Return False

											ClickAway()
											;;;
											ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
											$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
											;;;
											
											; __________
										
										EndIf
									Next
								EndIf
							EndIf
							If $iActive = UBound($aAlreadyChecked) Then
								ExitLoop 3
							EndIf
						Next

					Next
				EndIf

				ClickDrag(428, 500, 428, 260, 200)
				If _Sleep(1500) Then Return False
				
			Next
		Else
			SetLog("Couldn't find super troop barrel.", $COLOR_ERROR)
		EndIf

	EndIf

	ClickAway()
	Return False

EndFunc   ;==>BoostSuperTroop

Func IsSTPage()
	Return WaitforPixel(428, 214, 430, 216, Hex(0xF0D028, 6), 15, 15)
EndFunc   ;==>IsSTPage

Func GetSTroopName(Const $iIndex)
	Return $g_asSuperTroopNames[$iIndex]
EndFunc   ;==>GetSTroopName

#cs
Func BoostSuperTroop($bForce = False, $bDebug = False)

	; Start - 162, 313
	; 143 * (Slot) - X
	; 182 * (Slot) - Y
	; By line - 4

	; SecondPage - 77

	; GRAY
	; _MultiPixelSearch(148 + ($iSlotX * $iSlot), 242, 290 + ($iSlotX * $iSlot), 430, 2, 2, Hex(0xA9A9A9, 6), StringSplit2d("0x7E7E7E-106-0|0x7F7F7F-106-26"), 15)

	;	Labels
	Local $iBoosted = 0
	Local $iSlot = 0, $aPoint = 0, $aClock = 0
	Local $iSlotX = 143, $iSlotY = 182

	If $bForce = False Then
		; Check and update timers here

		;
	EndIf

    Local $sSearchArea = GetDiamondFromRect("80,80,250,250")
    Local $avBarrel = findMultiple($g_sImgBoostTroopsBarrel, $sSearchArea, $sSearchArea, 0, 1000, 1, "objectname,objectpoints", True)
	If UBound($avBarrel, $UBOUND_ROWS) <= 0 Or @error Then
        SetLog("Couldn't find super troop barrel on main village.", $COLOR_ERROR)
        Return False
    EndIf

    Local $avTempArray, $aiBarrelCoords
    For $i = 0 To UBound($avBarrel, $UBOUND_ROWS) - 1
        $avTempArray = $avBarrel[$i]
        $aiBarrelCoords = decodeSingleCoord($avTempArray[1])
		ExitLoop
    Next

    If UBound($aiBarrelCoords, $UBOUND_ROWS) < 2 Or @error Then
        SetLog("Couldn't get proper barrel coordinates.", $COLOR_ERROR)
        Return False
    EndIf

    ClickP($aiBarrelCoords)
    If _Sleep(500) Then Return False

	If IsSTPage() = True Then

		If $g_iCmbSuperTroops[0] > 0 Or $g_iCmbSuperTroops[1] > 0 Then

			For $i = 0 To $iSuperTroopsCount - 1

				If $iSlot > 3 Then
					$iSlot = 0
					AndroidMinitouchClickDrag(428, 500, 428, 260, 200)
					; AndroidMinitouchClickDrag(428, 500, 428, 260, 200, True)
					If _Sleep(1500) Then Return
				EndIf

				For $iB = 0 To $iMaxSupersTroop - 1

					If $g_iCmbSuperTroops[$iB] > 0 Then

						; If $g_asSuperTroopNames[$g_iCmbSuperTroops[$iB]-1] = $g_asSuperTroopNames[$i] Then
						If $i + 1 = $g_iCmbSuperTroops[$iB] Then

							; RED Label
							Local $offColors[2][3] = [[0xE55151, 106, 0], [0xE55351, 106, 26]]
							$aPoint = _MultiPixelSearch(148 + ($iSlotX * $iSlot), 242, 290 + ($iSlotX * $iSlot), 430, 2, 2, Hex(0xF58E8E, 6), $offColors, 15)

							If UBound($aPoint) = 2 And not @error Then

								If $iBoosted < $iMaxSupersTroop Then
									SetDebuglog("Found in : " & $aPoint[0] & "|" & $aPoint[1])
									Local $offColors[2][3] = [[0xFFE145, 0, 1], [0xF5D24A, 4, 0]]
									$aClock = _MultiPixelSearch($aPoint[0] - 10, $aPoint[1] + 115, $aPoint[0] + 40, $aPoint[1] + 156, 1, 1, Hex(0xF5D44D, 6), $offColors, 25)
									If UBound($aClock) = 2 And not @error Then

										SetLog("Detected boosted at " & $aClock[0] & " " & $aClock[1])
										; OCR Timers here
										SetLog(_getTimerST($aPoint[0] + 33, $aPoint[1] + 126, $aPoint[0] + 114, $aPoint[1] + 157))

										; Next troop
										ContinueLoop 2
									Else
										ClickP($aPoint)
										If _Sleep(250) Then Return

										; Green pixel
										If WaitforPixel(609, 536, 697, 589, Hex(0xDDF782, 6), 15, 1) Then

											; White zero
											If _PixelSearch(609, 536, 697, 589, Hex(0xFFFFFF, 6), 15) Then

												; Button
												Click(Random(609, 697, 1), Random(536, 589, 1))
												If _Sleep(250) Then Return

												; Wait Confirm
												If WaitforPixel(397, 453, 399, 455, Hex(0xB9E484, 6), 15, 1) Then

													; Click confirm
													Click(Random(397, 399, 1), Random(453, 455, 1))
													If _Sleep(250) Then Return

													; Gem here (not necesary)
													; Timers here (3 days)
												Else

													ClickAway()
													If _Sleep(250) Then Return

													If IsSTPage() = False Then
														ClickAway()
													EndIf

												EndIf

											Else
												; No resources case
												ClickAway()

											EndIf

										Else
											;;;
										EndIf

										ContinueLoop 2
									EndIf

								EndIf

								$iBoosted += 1

								If $iBoosted = $iMaxSupersTroop Then
									ExitLoop 2
								EndIf
							Else
								ContinueLoop 2
							EndIf

						EndIf

					EndIf

				Next

				$iSlot += 1
			Next

		EndIf
	EndIf

	ClickAway()

EndFunc   ;==>BoostSuperTroop

Func _getTimerST($iX, $iY, $iX2, $iY2)
	Local $sReturn = getOcrAndCaptureDOCR($g_sASBoostSTDOCRPath, $iX, $iY, $iX2, $iY2, True, True)
	$sReturn = StringReplace($sReturn, " ", "")
	If $g_bDebugOcr Then
		Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
		Local $sLibpath = @ScriptDir & "\lib\debug\ocr"
		DirCreate($sLibpath)
		Local $asTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC
		Local $sFilename = "DOCR_" & $asTime & " _BoostST"
		_GDIPlus_ImageSaveToFile($hEditedImage, $sLibpath & "\" & $sFilename & ".png")
		FileWrite($sLibpath & "\" & $sFilename & ".txt", $sReturn)
		_GDIPlus_BitmapDispose($hEditedImage)
	EndIf
	Return $sReturn
EndFunc   ;==>_getBattleEnds
#Ce

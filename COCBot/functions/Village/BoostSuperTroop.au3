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

Func BoostSuperTroop($bTest = False)
	Local $aAlreadyChecked[0]
	Local $aCmbTmp[2] = [_ArrayMin($g_iCmbSuperTroops, 1) - 1, _ArrayMax($g_iCmbSuperTroops, 1) - 1]

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
			For $iDrags = 1 To 3
				
				If IsSTPage(1) = True Then

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
									; If Pixel_Distance($aClock[$iClocks][1], $aClock[$iClocks][2], $aSuperT[$iImgs][1], $aSuperT[$iImgs][2]) > 164 And ($aClock[$iClocks][2] - $aSuperT[$iImgs][2]) > 0 Then
									Local $iDist = Pixel_Distance($aClock[$iClocks][1], $aClock[$iClocks][2], $aSuperT[$iImgs][1], $aSuperT[$iImgs][2])
									SetDebuglog("Clock check in : " & $aClock[$iClocks][1] & " / " & $aClock[$iClocks][2] & " | " & $aSuperT[$iImgs][0] & " | Dist : " & $iDist)
									If $iDist < 175 And ($aClock[$iClocks][2] - $aSuperT[$iImgs][2]) > 0 Then
										SetLog($aSuperT[$iImgs][0] & " is boosted.", $COLOR_INFO)
										;;;
										ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
										$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
										;;;
										If $iActive = UBound($aAlreadyChecked) Then
											ExitLoop 3
										EndIf
										ContinueLoop 2
									EndIf
								Next
							EndIf
							
							For $i = 0 To 1
								If $aCmbTmp[$i] > 0 Then
									$iIndex = _ArraySearch($g_asTroopShortNames, $aSuperT[$iImgs][0])
									If Not @error And $iIndex > -1 Then
										For $iTring = 0 To UBound($g_asTroopNames) - 1
											If _CompareTexts($g_asSuperTroopNames[$aCmbTmp[$i]], $g_asTroopNames[$iTring], 75) Then
												; Boost Here
												Click($aSuperT[$iImgs][1], $aSuperT[$iImgs][2], 1)
												If _Sleep(1500) Then Return False
												
												;;;;
												If IsSTPageBoost() Then
													Local $sTroopName = $g_asSuperTroopNames[$aCmbTmp[$i]]
													ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
													$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
	
													If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 160, 182, 727, 506, True, False) Then ;find image of dark elixir button
														Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
														If _Sleep(1000) Then Return
														If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 463, 489, 744, 605, True, False) Then ;find image of dark elixir button again (confirm upgrade)
															;do click boost
															If $bTest Then
																SetLog("Click(" & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY & ",1)", $COLOR_DEBUG)
																ClickAway()
																If _Sleep(1000) Then Return
																ClickAway()
																If _Sleep(1000) Then Return
																;;;
																; ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
																; $aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
																;;;
																ExitLoop
															EndIf
															Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
															Setlog("Successfully Boost " & $sTroopName, $COLOR_INFO)
															;;;
															; ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
															; $aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]
															;;;
															ExitLoop
														Else
															Setlog("Could not find dark elixir button for final upgrade " & $sTroopName, $COLOR_ERROR)
														EndIf
													Else
														Setlog("Could not find dark elixir button for upgrade " & $sTroopName, $COLOR_ERROR)
													EndIf
												EndIf
												;;;;
												
												If isGemOpen(True) Then
													ClickAway()
													Setlog("No loot for boost.", $COLOR_ERROR)
													ExitLoop 4
												EndIf
												
												If IsSTPageBoost(1) = True Then
													ClickAway()
													If _Sleep(1000) Then Return
												EndIf
												
												If IsSTPage(1) = False Then
													ClickAway()
													If _Sleep(1000) Then Return
												EndIf
												
												; __________
												ExitLoop
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
				Else
					SetLog("Bad IsSTPage.", $COLOR_ERROR)
					ClickAway()
					ClickAway()
				EndIf
			Next
		EndIf
	Else
		SetLog("Couldn't find super troop barrel.", $COLOR_ERROR)
	EndIf

	If UBound($aAlreadyChecked) > 0 Then
		SetLog("Super troops active:", $COLOR_INFO)

		For $i = 0 To UBound($aAlreadyChecked) - 1
			SetLog("- " & $aAlreadyChecked[$i], $COLOR_INFO)
		Next
	EndIf

	ClickAway()
	Return False

EndFunc   ;==>BoostSuperTroop

Func IsSTPage($iTry = 15)
	Return WaitforPixel(428, 214, 430, 216, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPage

Func IsSTPageBoost($iTry = 15)
	Return WaitforPixel(545, 165, 610, 220, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPageBoost


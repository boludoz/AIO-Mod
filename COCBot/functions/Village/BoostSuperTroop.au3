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
	If Not $g_bSuperTroopsEnable Then
		Return False
	EndIf

	SetLog("Checking super troops.", $COLOR_INFO)

	Local $aAlreadyChecked[0]
	Local $aCmbTmp[2] = [_ArrayMin($g_iCmbSuperTroops, 1) - 1, _ArrayMax($g_iCmbSuperTroops, 1) - 1]

	If $bTest = True Then _ArrayDisplay($aCmbTmp)

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
	If IsMainPage(1) Then
		If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 0, 0, 220, 225, True, False) Then
			SetLog("Found Barrel at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_DEBUG)
			Click($g_iQuickMISX, $g_iQuickMISY, 1)

			; Check the brown pixel below, just below the black one to avoid confusion.
			Local $aBrownDown[4] = [149, 552, 0x685C50, 20]
			If IsSTPage() = True Then

				; Nada al azar.
				For $iDrags = 1 To Round($iSuperTroopsCount / 4) + 1

					If IsSTPage(1) = True Then

						_CaptureRegion2()
						Local $aSuperT = FindMultipleQuick($g_sImgBoostTroopsIcons, 0, "140, 235, 720, 565", False)
						Local $aClock = FindMultipleQuick($g_sImgBoostTroopsClock, 0, "140, 235, 720, 565", False)

						$bCheckBottom = _CheckPixel($aBrownDown, True)

						If UBound($aSuperT) > 0 And Not @error Then
							For $iImgs = 0 To UBound($aSuperT) - 1
								If _ArraySearch($aAlreadyChecked, $aSuperT[$iImgs][0]) > -1 And Not @error Then
									Setlog("Skip checked " & $aSuperT[$iImgs][0] & ".", $COLOR_DEBUG)
									ContinueLoop
								ElseIf $bCheckBottom = False Then
									Setlog("Skip bottom " & $aSuperT[$iImgs][0] & " X: " & $aSuperT[$iImgs][1] & " Y: " & $aSuperT[$iImgs][2] & ".", $COLOR_DEBUG)
									ContinueLoop
								EndIf

								; Check If is boosted
								If UBound($aClock) > 0 And Not @error Then
									For $iClocks = 0 To UBound($aClock) - 1
										Local $iDist = Pixel_Distance($aClock[$iClocks][1], $aClock[$iClocks][2], $aSuperT[$iImgs][1], $aSuperT[$iImgs][2])
										SetDebuglog("Clock check in : " & $aClock[$iClocks][1] & " / " & $aClock[$iClocks][2] & " | " & $aSuperT[$iImgs][0] & " | Dist : " & $iDist)
										If $iDist < 175 And ($aClock[$iClocks][2] - $aSuperT[$iImgs][2]) > 0 Then
											SetLog($aSuperT[$iImgs][0] & " is boosted.", $COLOR_INFO)

											ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
											$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]

											If $iActive = UBound($aAlreadyChecked) Then
												ExitLoop 3
											EndIf

											ContinueLoop 2
										EndIf
									Next
								EndIf

								; Puaajjj puajj
								For $i = 0 To 1
									; Verifica que el slot $i este activo.
									If $aCmbTmp[$i] > 0 Then

										; Devuelve el index en short name.
										$iIndex = _ArraySearch($g_asTroopShortNames, $aSuperT[$iImgs][0])
										Local $eError = @error
										If $eError = 0 And $iIndex > -1 Then

											SetLog("_ArraySearch : " & $g_asTroopShortNames[$iIndex] & " | " & $aSuperT[$iImgs][0] & " | Index : " & $iIndex & " | Error : " & $eError)

											If $g_asTroopNames[$iIndex] = $g_asSuperTroopNames[$aCmbTmp[$i]] Then

												SetLog("Compare texts : " & $g_asTroopNames[$iIndex] & " | " & $g_asSuperTroopNames[$aCmbTmp[$i]])

												; Boost Here
												Click($aSuperT[$iImgs][1], $aSuperT[$iImgs][2], 1)
												If _Sleep(1500) Then Return False

												If IsSTPageBoost() Then
													Local $sTroopName = $g_asSuperTroopNames[$aCmbTmp[$i]]

													Setlog("Checking " & $sTroopName, $COLOR_INFO)

													ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
													$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $aSuperT[$iImgs][0]

													If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 160, 182, 727, 506, True, False) Then     ; Find image of dark elixir button.
														Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
														If _Sleep(1000) Then Return
														If QuickMIS("BC1", $g_sImgBoostTroopsButtons, 463, 489, 744, 605, True, False) Then     ; Find image of dark elixir button again (confirm upgrade).
															; Do click boost
															If $bTest Then
																SetLog("Click(" & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY & ", 1)", $COLOR_DEBUG)
																ClickAway()
																If _Sleep(1000) Then Return
																ClickAway()
																If _Sleep(1000) Then Return
																ExitLoop
															EndIf
															Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
															Setlog("Successfully Boost " & $sTroopName, $COLOR_INFO)
															ExitLoop
														Else
															Setlog("Could not find dark elixir button for final upgrade " & $sTroopName, $COLOR_ERROR)
														EndIf
													Else
														Setlog("Could not find dark elixir button for upgrade " & $sTroopName, $COLOR_ERROR)
													EndIf
												EndIf

												If isGemOpen(True) Then
													ClickAway()
													Setlog("No loot for boost.", $COLOR_ERROR)
													ExitLoop 3
												EndIf

												If IsSTPageBoost(1) = True Then
													ClickAway()
													If _Sleep(1000) Then Return
												EndIf

												If IsSTPage(1) = False Then
													ClickAway()
													If _Sleep(1000) Then Return
												EndIf

											EndIf
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
	Else
		SetLog("BoostSuperTroop: Bad mainscreen.", $COLOR_ERROR)
	EndIf

	ClickAway()

EndFunc   ;==>BoostSuperTroop

Func IsSTPage($iTry = 15)
	Return WaitforPixel(428, 214, 430, 216, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPage

Func IsSTPageBoost($iTry = 15)
	Return WaitforPixel(545, 165, 610, 220, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPageBoost


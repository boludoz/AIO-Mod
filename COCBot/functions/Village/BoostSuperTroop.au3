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

	Local $bCheckBottom = False
	Local $aImgBoostBtn1[4] = [463, 489, 744, 605]
	Local $aImgBoostBtn2[4] = [160, 182, 727, 506]
	Local $aBrownDown[4] = [149, 552, 0x685C50, 20]
	Local $iIndex = -1, $aSuperT = -1, $aClock = -1, $aTmp = -1, $aBarD = 0, $iDist = 0, $sFilenameClock = "", $sFilenameST = ""
	Local $aClockCoords[0], $aTroopsCoords[0], $aPoints[0], $sDiamond = GetDiamondFromRect("140, 235, 720, 565"), $sDiamondTroops = GetDiamondFromRect("140, 235, 720, 565")

	ClickAway()
	If IsMainPage(1) Then
		If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 0, 0, 220, 225, True, False) Then
			If $bTest Then SetLog("Found Barrel at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_DEBUG)
			Click($g_iQuickMISX, $g_iQuickMISY, 1)

			; Check the brown pixel below, just below the black one to avoid confusion.
			If IsSTPage() = True Then

				; Nada al azar.
				For $iDrags = 1 To Round($iSuperTroopsCount / 4) + 1

					If IsSTPage(1) = True Then

						_CaptureRegions()
						$bCheckBottom = _CheckPixel($aBrownDown, False)

						; Check If is boosted
						Local $aSuperT = findMultiple($g_sImgBoostTroopsIcons, $sDiamondTroops, $sDiamondTroops, 0, 1000, 0, "objectname,objectlevel,objectpoints", False)
						If UBound($aSuperT) > 0 And Not @error Then
							For $aMatchedTroops In $aSuperT
								$aPoints = decodeMultipleCoords($aMatchedTroops[2])
								$sFilenameST = $aMatchedTroops[0] ; Filename

								If UBound($aPoints) < 1 Then ContinueLoop

								$aTroopsCoords = $aPoints[0] ; Coords

								If $g_bDebugSetlog Then
									SetDebugLog($sFilenameST & " found (" & $aTroopsCoords[0] & "," & $aTroopsCoords[1] & ")", $COLOR_SUCCESS)
								EndIf

								If _ArraySearch($aAlreadyChecked, $sFilenameST) > -1 And Not @error Then
									If $bTest Then Setlog("Skip checked " & $sFilenameST & ".", $COLOR_DEBUG)
									ContinueLoop
								ElseIf $bCheckBottom = False Then
									If $bTest Then Setlog("Skip bottom " & $sFilenameST & " X: " & $aTroopsCoords[0] & " Y: " & $aTroopsCoords[1] & ".", $COLOR_DEBUG)
									ContinueLoop
								EndIf

								; Check If is boosted
								Local $aClock = findMultiple($g_sImgBoostTroopsClock, $sDiamond, $sDiamond, 0, 1000, 0, "objectname,objectlevel,objectpoints", False)
								If UBound($aClock) > 0 And Not @error Then
									For $aMatchedClocks In $aClock
										$aPoints = decodeMultipleCoords($aMatchedClocks[2])
										$sFilenameClock = $aMatchedClocks[0] ; Filename
										For $i = 0 To UBound($aPoints) - 1
											$aClockCoords = $aPoints[$i] ; Coords

											If $g_bDebugSetlog Then
												SetDebugLog($sFilenameClock & " found (" & $aClockCoords[0] & "," & $aClockCoords[1] & ")", $COLOR_SUCCESS)
											EndIf

											$iDist = Pixel_Distance($aClockCoords[0], $aClockCoords[1], $aTroopsCoords[0], $aTroopsCoords[1])
											SetDebuglog("Clock check in : " & $aClockCoords[0] & " / " & $aClockCoords[1] & " | " & $sFilenameST & " | Dist : " & $iDist)
											If $iDist < 175 And ($aClockCoords[1] - $aTroopsCoords[1]) > 0 Then
												If $bTest Then SetLog($sFilenameST & " is boosted.", $COLOR_INFO)

												ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
												$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $sFilenameST

												If $iActive = UBound($aAlreadyChecked) Then
													ExitLoop 4
												EndIf

												ContinueLoop 3
											EndIf
										Next
									Next
								EndIf

								For $i = 0 To 1
								
									; Verifica que el slot $i este activo.
									If $aCmbTmp[$i] > 0 Then

										; Devuelve el index en short name.
										$iIndex = _ArraySearch($g_asTroopShortNames, $sFilenameST)
										Local $eError = @error
										If $eError = 0 And $iIndex > -1 Then

											If $bTest Then SetLog("_ArraySearch : " & $g_asTroopShortNames[$iIndex] & " | " & $sFilenameST & " | Index : " & $iIndex & " | Error : " & $eError)

											If $g_asTroopNames[$iIndex] = $g_asSuperTroopNames[$aCmbTmp[$i]] Then

												If $bTest Then SetLog("Compare texts : " & $g_asTroopNames[$iIndex] & " | " & $g_asSuperTroopNames[$aCmbTmp[$i]])

												; Boost Here
												Click($aTroopsCoords[0], $aTroopsCoords[1], 1)
												If _Sleep(1500) Then Return False

												If IsSTPageBoost() Then
													Local $sTroopName = $g_asSuperTroopNames[$aCmbTmp[$i]]

													Setlog("Checking " & $sTroopName, $COLOR_INFO)

													ReDim $aAlreadyChecked[UBound($aAlreadyChecked) + 1]
													$aAlreadyChecked[UBound($aAlreadyChecked) - 1] = $sFilenameST
																										
													If QuickMIS("BC1", $g_sImgBoostTroopsButtons, $aImgBoostBtn1[0], $aImgBoostBtn1[1], $aImgBoostBtn1[2], $aImgBoostBtn1[3], True, False) Then     ; Find image of dark elixir button.
														Click($g_iQuickMISX + $aImgBoostBtn1[0], $g_iQuickMISY + $aImgBoostBtn1[1], 1)
														If _Sleep(1000) Then Return
														
														If QuickMIS("BC1", $g_sImgBoostTroopsButtons, $aImgBoostBtn2[0], $aImgBoostBtn2[1], $aImgBoostBtn2[2], $aImgBoostBtn2[3], True, False) Then     ; Find image of dark elixir button again (confirm upgrade).
															
															; Do click boost
															If $bTest Then
																SetLog("Click(" & $g_iQuickMISX + $aImgBoostBtn1[0] & "," & $g_iQuickMISY + $aImgBoostBtn1[1] & ", 1)", $COLOR_DEBUG)
																ClickAway()
																If _Sleep(500) Then Return
																
																ClickAway()
																If _Sleep(500) Then Return
																ExitLoop
															EndIf
															
															Click($g_iQuickMISX + $aImgBoostBtn2[0], $g_iQuickMISY + $aImgBoostBtn2[1], 1)
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
													Setlog("No loot for boost.", $COLOR_ERROR)
													
													ClickAway()
													If _Sleep(500) Then Return
													
													ClickAway()
													If _Sleep(500) Then Return
													ExitLoop 3
												EndIf

												If IsSTPageBoost(1) = True Then
													ClickAway()
													If _Sleep(500) Then Return
												EndIf

												If IsSTPage(1) = False Then
													ClickAway()
													If _Sleep(500) Then Return
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
						If _Sleep(500) Then Return
						
						ClickAway()
						If _Sleep(500) Then Return
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
	If _Sleep(500) Then Return

EndFunc   ;==>BoostSuperTroop

Func IsSTPage($iTry = 15)
	Return WaitforPixel(428, 214, 430, 216, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPage

Func IsSTPageBoost($iTry = 15)
	Return WaitforPixel(545, 165, 610, 220, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPageBoost


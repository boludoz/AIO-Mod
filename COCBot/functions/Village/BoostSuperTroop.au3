; #FUNCTION# ====================================================================================================================
; Name ..........: Boost a troop to super troop
; Description ...: Supertroops with low maintenance level, based on images.
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

	; Not necessary
	; If $g_iCommandStop = 0 Or $g_iCommandStop = 3 Then ;halt attack.. do not boost now
	; If $g_bSkipBoostSuperTroopOnHalt Then
	; SetLog("BoostSuperTroop() skipped, account on halt attack mode", $COLOR_DEBUG)
	; Return False
	; EndIf
	; EndIf

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

	Local $aBrownDown[4] = [150, 552, 0x685C50, 20]

	Local $bCheckBottom = False, $bBadTryPotion = False, $bBadTryDark = False
	Local $iIndex = -1, $aSuperT = -1, $aClock = -1, $aTmp = -1, $aBarD = 0, $iDist = 0, $sFilenameClock = "", $sFilenameST = ""
	Local $aClockCoords[0], $aTroopsCoords[0], $aPoints[0], $sDiamond = GetDiamondFromRect("140, 235, 720, 565"), $sDiamondTroops = GetDiamondFromRect("140, 235, 720, 565")

	ClickAway()
	If IsMainPage(1) Then
		If QuickMIS("BC1", $g_sImgBoostTroopsBarrel, 0, 0, 220, 225, True, False) Then
			If $bTest Then SetLog("Found Barrel at " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_DEBUG)
			Click($g_iQuickMISX, $g_iQuickMISY, 1)

			; Check the brown pixel below, just below the black one to avoid confusion.
			If IsSTPage() = True Then

				If _Sleep(500) Then Return

				; Nada al azar.
				Local $eBeDrag = Ceiling($iSuperTroopsCount / 4)
				If Mod($iSuperTroopsCount, 4) > 0 Then $eBeDrag += 1
				For $iDrags = 1 To $eBeDrag

					If IsSTPage(1) = True Then

						_CaptureRegions()
						$bCheckBottom = _CheckPixel($aBrownDown, False)

						; Check If is boosted
						Local $aSuperT = findMultiple($g_sImgBoostTroopsIcons, GetDiamondFromRect("140, 235, 720, 565"), GetDiamondFromRect("140, 235, 720, 565"), 0, 1000, 0, "objectname,objectlevel,objectpoints", False)
						If UBound($aSuperT) > 0 And Not @error Then
							For $aMatchedTroops In $aSuperT
								If $iActive = UBound($aAlreadyChecked) Then
									ExitLoop
								EndIf

								$aPoints = decodeMultipleCoords($aMatchedTroops[2])

								If UBound($aPoints) > 0 Then

									$sFilenameST = $aMatchedTroops[0] ; Filename

									For $i3 = 0 To UBound($aPoints) - 1
										$aTroopsCoords = $aPoints[$i3] ; Coords
										If $aTroopsCoords[1] > 472 Then
											ExitLoop
										EndIf
									Next

									SetDebugLog($sFilenameST & " found (" & $aTroopsCoords[0] & "," & $aTroopsCoords[1] & ")", $COLOR_SUCCESS)

									If _ArraySearch($aAlreadyChecked, $sFilenameST) > -1 And Not @error Then
										If $bTest Then Setlog("Skip checked " & $sFilenameST & ".", $COLOR_DEBUG)
										ContinueLoop
									ElseIf $bCheckBottom = False And $aTroopsCoords[1] > 472 Then
										If $bTest Then Setlog("Skip bottom " & $sFilenameST & " X: " & $aTroopsCoords[0] & " Y: " & $aTroopsCoords[1] & ".", $COLOR_DEBUG)
										ContinueLoop
									EndIf

									; Check If is boosted
									If $bTest Then SetLog("Stage 1 - Check If is boosted.", $COLOR_INFO)
									Local $aClock = findMultiple($g_sImgBoostTroopsClock, $sDiamond, $sDiamond, 0, 1000, 0, "objectname,objectlevel,objectpoints", False)
									If UBound($aClock) > 0 And Not @error Then
										For $aMatchedClocks In $aClock
											$aPoints = decodeMultipleCoords($aMatchedClocks[2])
											$sFilenameClock = $aMatchedClocks[0] ; Filename
											For $i = 0 To UBound($aPoints) - 1
												$aClockCoords = $aPoints[$i] ; Coords
												SetDebugLog($sFilenameClock & " found (" & $aClockCoords[0] & "," & $aClockCoords[1] & ")", $COLOR_SUCCESS)
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

									If $bTest Then SetLog("Stage 2 - Boost.", $COLOR_INFO)
									For $i = 0 To 1

										; Verifica que el slot $i este activo.
										If $aCmbTmp[$i] > -1 Then

											; Devuelve el index en short name.
											$iIndex = _ArraySearch($g_asTroopShortNames, $sFilenameST)
											If $bTest Then SetLog("_ArraySearch : " & $sFilenameST & " | Index : Test 1")
											If $iIndex > -1 Then

												If $bTest Then SetLog("_ArraySearch : " & $g_asTroopShortNames[$iIndex] & " | " & $sFilenameST & " | Index : " & $iIndex)
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

														If $bBadTryPotion == False And $bBadTryDark == False Then
															FinalBoostST($bBadTryPotion, $bBadTryDark, $bTest)
														Else
															ClickAway(Default, True)
															If _Sleep(1500) Then Return False
														EndIf
													Else
														Setlog("Bad IsSTPageBoost.", $COLOR_ERROR)
														ClickAway(Default, True)
														If _Sleep(1500) Then Return False

														ClickAway(Default, True)
														If _Sleep(1500) Then Return False
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
								EndIf
							Next
						EndIf

						ClickDrag(428, 500, 428, 260, 200)
						If $bTest Then SetLog("Stage ClickDrag.", $COLOR_INFO)
						If _Sleep(1500) Then Return False
					Else
						SetLog("Bad IsSTPage.", $COLOR_ERROR)
						ClickAway()
						If _Sleep(500) Then Return

						ClickAway()
						If _Sleep(500) Then Return
						ExitLoop
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

Func FinalBoostST(ByRef $bBadTryPotion, ByRef $bBadTryDark, $bTest = False)

	Local $aImgBoostBtn1[4] = [400, 525, 750, 600]
	Local $aImgBoostBtn2[4] = [100, 375, 750, 520]

	Local $bPotionAvariable = QuickMIS("BC1", $g_sImgBoostTroopsPotion, $aImgBoostBtn1[0], $aImgBoostBtn1[1], $aImgBoostBtn1[2], $aImgBoostBtn1[3], True, False)
	Local $aClickPotion[2] = [$g_iQuickMISX + $aImgBoostBtn1[0], $g_iQuickMISY + $aImgBoostBtn1[1]]

	Local $bDarkAvariable = QuickMIS("BC1", $g_sImgBoostTroopsButtons, $aImgBoostBtn1[0], $aImgBoostBtn1[1], $aImgBoostBtn1[2], $aImgBoostBtn1[3], True, False)
	Local $aClickDark[2] = [$g_iQuickMISX + $aImgBoostBtn1[0], $g_iQuickMISY + $aImgBoostBtn1[1]]
	$bDarkAvariable = IsDarkAvariable()
	Local $aResource = [$bDarkAvariable, $bPotionAvariable]
	Local $aClick = [$aClickDark, $aClickPotion]
	Local $iDOW = $g_iCmbSuperTroopsResources + 1
	Local $iD = -1
	Local $iNum = -1
	For $iWk = 1 To 2
		If $iD > 2 Then
			$iDOW = ($g_iCmbSuperTroopsResources + 1) - 2
		EndIf
		$iD = $iDOW + $iWk
		$iNum = $iD - 2
		If $aResource[$iNum] == True Then
			ClickP($aClick[$iNum])
			If _Sleep(1500) Then Return

			Local $sMode = ($iNum = 0) ? ($g_sImgBoostTroopsButtons) : ($g_sImgBoostTroopsPotion)
			If QuickMIS("BC1", $sMode, $aImgBoostBtn2[0], $aImgBoostBtn2[1], $aImgBoostBtn2[2], $aImgBoostBtn2[3], True, False) Then
				If $bTest = False Then
					Click($g_iQuickMISX + $aImgBoostBtn2[0], $g_iQuickMISY + $aImgBoostBtn2[1], 1)
				Else
					ClickAway()
					If _Sleep(1500) Then Return

					ClickAway()
				EndIf
			EndIf

			ExitLoop
		Else
			If $iNum = 0 Then
				$bBadTryDark = True
			Else
				$bBadTryPotion = True
			EndIf
		EndIf
	Next
EndFunc   ;==>FinalBoostST

Func IsDarkAvariable()
	Return (WaitforPixel(632, 543, 688, 576, Hex(0xFF887F, 6), 15, 1) = False)
EndFunc   ;==>IsDarkAvariable

Func IsSTPage($iTry = 15)
	Return WaitforPixel(428, 214, 430, 216, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPage

Func IsSTPageBoost($iTry = 15)
	Return WaitforPixel(545, 165, 610, 220, Hex(0xF0D028, 6), 15, $iTry)
EndFunc   ;==>IsSTPageBoost


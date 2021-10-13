; #FUNCTION# ====================================================================================================================
; Name ..........: -
; Description ...:
; Syntax ........: BoostResourcePotion()
; Parameters ....:
; Return values .: None
; Author ........: (Boldina) boludoz - 2018 / 2021 - (FOR RK MOD/AIO Mod++) (When you hold a mod for 4 years, talk about me.)
; Modified ......:
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func DbgBuilderPotionBoost($iDbgTotalBuilderCount = 5, $iDbgFreeBuilderCount = 5)

	Local $iTmpDbgTotalBuilderCount = $g_iTotalBuilderCount
	Local $iTmpDbgFreeBuilderCount = $g_iFreeBuilderCount

	$g_iTotalBuilderCount = $iDbgTotalBuilderCount
	$g_iFreeBuilderCount = $iDbgFreeBuilderCount

	Local $bResult = BuilderPotionBoost(True)

	$g_iTotalBuilderCount = $iTmpDbgTotalBuilderCount
	$g_iFreeBuilderCount = $iTmpDbgFreeBuilderCount

	Return $bResult
EndFunc   ;==>DbgBuilderPotionBoost

Func BuilderPotionBoost($bDebug = False)
	If Not $g_bChkBuilderPotion Then Return

	Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	If $iLastTimeChecked[Number($g_iCurAccount)] = 0 Then

		If _Sleep($DELAYBOOSTHEROES2 * 3) Then Return False

		If Abs($g_iTotalBuilderCount - $g_iFreeBuilderCount) >= $g_iInputBuilderPotion Then
			If IsMainPage() Then Click(293, 32) ; click builder's nose for poping out information
			If _Sleep($DELAYBOOSTHEROES2 * 2) Then Return
			Click(Random(212, 453, 1), Random(114, 129, 1))
			If _Sleep($DELAYBOOSTHEROES2) Then Return
			ForceCaptureRegion()
			Local $aResult = getNameBuilding(242, 490 + $g_iBottomOffsetY)
			If $aResult <> "" Then
				If _Sleep($DELAYBOOSTHEROES2) Then Return
				
				If AlreadyBoosted() Then
					Setlog("Already boosted.", $COLOR_INFO)
					$iLastTimeChecked[Number($g_iCurAccount)] = 1
					Return
				EndIf

				If BoostPotionMod("BuilderPotion", $bDebug) Then
					$iLastTimeChecked[Number($g_iCurAccount)] = 1
					Return True
				Else
					Setlog("Magic Items| Fail builder potion.", $COLOR_ERROR)
					Return False
				EndIf
			Else
				Setlog("Magic Items| OCR Fail.", $COLOR_ERROR)
				Return False
			EndIf
		Else
			Setlog("Magic Items| Condition not met.", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>BuilderPotionBoost

Func AlreadyBoosted()
	Local $aBoostBtn = findButton("BoostOne")
	If UBound($aBoostBtn) > 1 And not @error Then
		If UBound(_PixelSearch($aBoostBtn[0], $aBoostBtn[1], $aBoostBtn[0] + 25, $aBoostBtn[1] + 41, Hex(0xD5FE95, 6), 35, True)) > 0 And not @error Then
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>AlreadyBoosted

Func ResourceBoost($aPos1 = 0, $aPos2 = 0)
	If Not $g_bChkResourcePotion Then Return
	
	ClickAway()
	
	If Not IsMainPage(5) Then Return False
	
	If Not (($g_iInputGoldItems >= $g_aiTempGainCost[0]) And ($g_iInputElixirItems >= $g_aiTempGainCost[1]) And ($g_iInputDarkElixirItems >= $g_aiTempGainCost[2])) Then Return

	Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

	If $iLastTimeChecked[Number($g_iCurAccount)] = 0 And isInsideDiamondInt($aPos1, $aPos2) Then
		If _Sleep($DELAYBOOSTHEROES2) Then Return

		BuildingClick($aPos1, $aPos2 + 25)
		If _Sleep($DELAYBOOSTHEROES2) Then Return
		
		ForceCaptureRegion()
		Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
		If $aResult[0] > 1 Then
			Local $sN = $aResult[1]      ; Store bldg name
			Local $sL = $aResult[2]      ; Sotre bdlg level
			If Number($sL) > 0 Then      ; Multi Language
				; Structure located
				SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aPos1 & ", " & $aPos2, $COLOR_SUCCESS)
				
				If AlreadyBoosted() Then
					Setlog("Already boosted.", $COLOR_INFO)
					$iLastTimeChecked[Number($g_iCurAccount)] = 1
					Return
				EndIf
				
				If BoostPotionMod("ResourcePotion") Then
					$iLastTimeChecked[Number($g_iCurAccount)] = 1
					Return True
				Else
					Return False
				EndIf
			EndIf
		EndIf
	Else
		;Setlog("Magic Items| Fail resource potion.", $COLOR_ERROR)
		Return False
	EndIf
	Return False
EndFunc   ;==>ResourceBoost

Func LabPotionBoost($bDebug = False)
	If Not $g_bChkLabPotion Then Return False
	
	If Not IsMainPage(5) Then Return False

	Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

	If $iLastTimeChecked[Number($g_iCurAccount)] = 0 Then
		If _Sleep($DELAYBOOSTHEROES2) Then Return
		
		If (Number(_DateDiff("h", _NowCalc(), $g_sLabUpgradeTime)) > Int($g_iInputLabPotion)) Or Int($g_iInputLabPotion) = 0 Then

			If Not FindResearchButton(True) Then 
				;Click Laboratory
				BuildingClickP($g_aiLaboratoryPos, "#0197") ; Team AIO Mod++
				If _Sleep($DELAYLABORATORY3) Then Return ; Wait for window to open
			EndIf
			
			If Not FindResearchButton(True) Then Return False ; adieu bye bye
		
			If AlreadyBoosted() Then
				Setlog("Already boosted lab.", $COLOR_INFO)
				$iLastTimeChecked[Number($g_iCurAccount)] = 1
				Return True
			EndIf

			If BoostPotionMod("LabPotion", $bDebug) Then
				$iLastTimeChecked[Number($g_iCurAccount)] = 1
				Return True
			EndIf
		EndIf
	EndIf

	Return False
EndFunc   ;==>LabPotionBoost

; BoostPotionMod("LabPotion", False)
Func BoostPotionMod($sName, $bDebug = False)
	
	Local $aFiles = _FileListToArray($g_sImgPotionsBtn, $sName & "*.*", $FLTA_FILES)
	If UBound($aFiles) > 1 And not @error Then
		Local $aCoords = decodeSingleCoord(findImage($aFiles[1], $g_sImgPotionsBtn & "\" & $aFiles[1], GetDiamondFromRect("134, 580, 730, 675"), 1, True))
		If UBound($aCoords) > 1 And Not @error Then
			Setlog("Magic Items : boosting " & $sName, $COLOR_INFO)
			ClickP($aCoords, 1)
			If _Sleep(1500) Then Return False
			
			If WaitforPixel(391, 314, 455, 500, Hex(0xE1E3CB, 6), 15, 15) Then
				If $bDebug = False Then
					Click(420, 418, 1)
				Else
					ClickAway(True)
				EndIf
				
				SetLog("Potion used: " & $sName & ".", $COLOR_SUCCESS)
				If _Sleep(500) Then Return False
				
			Else
				SetLog("No potion for boost: " & $sName & ".", $COLOR_INFO)
			EndIf
		Else
			SetLog("No potion detected : " & $sName & ".", $COLOR_INFO) ; In short, mistakes are seen by people, not a group of VIPs.
		EndIf
	Else
		SetLog("BoostPotionMod: No files found.", $COLOR_INFO)
	EndIf
	ClickAway()
	Return True
EndFunc   ;==>BoostPotionMod



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
EndFunc

Func BuilderPotionBoost($bDebug = False)
	If not $g_bChkBuilderPotion Then Return

	Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	If $iLastTimeChecked[$g_iCurAccount] = 0 Then

	If _Sleep($DELAYBOOSTHEROES2*3) Then Return False

		If Abs($g_iTotalBuilderCount - $g_iFreeBuilderCount) >= $g_iInputBuilderPotion Then
			If IsMainPage() Then Click(293, 32) ; click builder's nose for poping out information
 			If _Sleep($DELAYBOOSTHEROES2*2) Then Return
			Click(Random(212, 453, 1), Random(114, 129, 1))
 			If _Sleep($DELAYBOOSTHEROES2) Then Return
			ForceCaptureRegion()
 			Local $aResult = getNameBuilding(242, 490 + $g_iBottomOffsetY)
				If $aResult <> "" Then
					If _Sleep($DELAYBOOSTHEROES2) Then Return
					If BoostPotionMod("BuilderPotion", $bDebug) Then
						$iLastTimeChecked[$g_iCurAccount] = 1
						Return True
						Else
						Setlog("Magic Items| Fail builder potion.", $COLOR_ERROR)
					Return false
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
EndFunc

Func ResourceBoost($aPos1 = 0, $aPos2 = 0)
 		If not $g_bChkResourcePotion Then Return

		If Not (($g_iInputGoldItems >= $g_aiTempGainCost[0]) And ($g_iInputElixirItems >= $g_aiTempGainCost[1]) And ($g_iInputDarkElixirItems >= $g_aiTempGainCost[2])) Then Return

		Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

		If $iLastTimeChecked[$g_iCurAccount] = 0 And not Int($aPos1 + $aPos2 <= 0) Then
 			If _Sleep($DELAYBOOSTHEROES2) Then Return

 			BuildingClick($aPos1, $aPos2 + 25)
 			If _Sleep($DELAYBOOSTHEROES2) Then Return
 			ForceCaptureRegion()
 			Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
 			If $aResult[0] > 1 Then
 				Local $sN = $aResult[1] ; Store bldg name
 				Local $sL = $aResult[2] ; Sotre bdlg level
 				If Number($sL) > 0 Then ; Multi Language
 					; Structure located
 					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aPos1 & ", " & $aPos2, $COLOR_SUCCESS)
 					If BoostPotionMod("ResourcePotion") Then
						$iLastTimeChecked[$g_iCurAccount] = 1
						Return True
						Else
						Return false
					EndIf
 				EndIf
			EndIf
			Else
			;Setlog("Magic Items| Fail resource potion.", $COLOR_ERROR)
			Return False
		EndIf
	Return False
EndFunc

Func LabPotionBoost()
 		If not $g_bChkLabPotion Then Return False

		Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

		If $iLastTimeChecked[$g_iCurAccount] = 0 Then
 			If _Sleep($DELAYBOOSTHEROES2) Then Return

			;If $g_sLabUpgradeTime <> "" Then
			;	If Not FindResearchButton() Then Return False ; cant start becuase we cannot find the research button
			;	If ChkLabUpgradeInProgress() Then Return False ; cant start if something upgrading
			;EndIf

			If $g_sLabUpgradeTime <> "" And (Number(_DateDiff("h", _NowCalc(), $g_sLabUpgradeTime)) > Int($g_iInputLabPotion)) Then

				BuildingClickP($g_aiLaboratoryPos, "#0197")
				If _Sleep($DELAYBOOSTHEROES2) Then Return

				ForceCaptureRegion()

				Local $aResearchButton = findButton("Research", Default, 1, True)
				If IsArray($aResearchButton) And UBound($aResearchButton, 1) = 2 Then
					If BoostPotionMod("LabPotion") Then
						$iLastTimeChecked[$g_iCurAccount] = 1
					EndIf
					Return True
				EndIf
			EndIf
		EndIf
	Return False
EndFunc

Func BoostPotionMod($sName, $bDebug = False)
	
	; Slow but safe.
	If _WaitForCheckImg($g_sImgPotionsBtn, "134, 580, 730, 675", $sName, 1500, 250) Then
		If UBound($g_aImageSearchXML) > 0 and not @error Then
			Setlog("Magic Items : boosting " & $sName, $COLOR_INFO)
			Click($g_aImageSearchXML[0][1], $g_aImageSearchXML[0][2], 1)
			If _Sleep(500) Then Return False
			
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
			
		EndIf
	Else
		SetLog("Badly BoostPotionMod (1), from: " & $sName & ".", $COLOR_ERROR) ; In short, mistakes are seen by people, not a group of VIPs.
	EndIf 
	
	ClickAway()
	Return True
EndFunc   ;==>BoostPotionMod


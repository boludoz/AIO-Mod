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

Func LabPotionBoost()
	If Not $g_bChkLabPotion Then Return False

	Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

	If $iLastTimeChecked[Number($g_iCurAccount)] = 0 Then
		If _Sleep($DELAYBOOSTHEROES2) Then Return
		
		If $g_sLabUpgradeTime <> "" And (Number(_DateDiff("h", _NowCalc(), $g_sLabUpgradeTime)) > Int($g_iInputLabPotion)) Then
			If BoostPotionMod("LabPotion") Then
				$iLastTimeChecked[Number($g_iCurAccount)] = 1
			Else
				LocateLab() ; Lab location unknown, so find it.
				If _Sleep($DELAYLABORATORY3) Then Return ; Wait for window to open

				If $g_aiLaboratoryPos[0] < 1 Or $g_aiLaboratoryPos[1] < 1 Then
					SetLog("Problem locating Laboratory, re-locate laboratory position before proceeding", $COLOR_ERROR)
					Return False
				EndIf

				;Click Laboratory
				BuildingClickP($g_aiLaboratoryPos, "#0197") ; Team AIO Mod++
				If _Sleep($DELAYLABORATORY3) Then Return ; Wait for window to open
				
				If BoostPotionMod("LabPotion") Then
					$iLastTimeChecked[Number($g_iCurAccount)] = 1
				EndIf
				
			EndIf
		EndIf
	EndIf
	
	Return False
EndFunc   ;==>LabPotionBoost

Func BoostPotionMod($sName, $bDebug = False)
	
	; Slow but safe.
	If _WaitForCheckImg($g_sImgPotionsBtn, "134, 580, 730, 675", $sName, 1500, 250) Then
		If UBound($g_aImageSearchXML) > 0 And Not @error Then
			Setlog("Magic Items : boosting " & $sName, $COLOR_INFO)
			Click($g_aImageSearchXML[0][1], $g_aImageSearchXML[0][2], 1)
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
			
		EndIf
	Else
		SetLog("No potion detected : " & $sName & ".", $COLOR_INFO) ; In short, mistakes are seen by people, not a group of VIPs.
	EndIf
	
	ClickAway()
	Return True
EndFunc   ;==>BoostPotionMod


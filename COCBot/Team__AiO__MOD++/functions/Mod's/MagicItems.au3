
; #FUNCTION# ====================================================================================================================
; Name ..........: -
; Description ...:
; Syntax ........: BoostResourcePotion()
; Parameters ....:
; Return values .: None
; Author ........: (Boldina) boludoz - 2018 - (FOR RK MOD)
; Modified ......:
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostResourcePotion($aiTmp0 = 0, $aiTmp1 = 0)

;~ 	Local $aiResourcesPos[2] = [$aiTmp0, $aiTmp1]
;~ 	; Verifying existent Variables to run this routine
;~ 	;If Not AllowBoosting("Resource Potion", $g_iCmbBoostResourcePotion) Then Return

;~ 	SetLog("Boosting Resource Potion", $COLOR_INFO)
;~ 	If $g_aiTownHallPos[0] = "" Or $g_aiTownHallPos[0] = -1 Then
;~ 		LocateTownHall()
;~ 		SaveConfig()
;~ 		If _Sleep($DELAYBOOSTBARRACKS2) Then Return
;~ 	EndIf

;~ 	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0], $iDateCalc
;~ 	$iDateCalc = _DateDiff('n', $iLastTimeChecked[$g_iCurAccount], _NowCalc())
;~ 	Local $ok = False
;~ 	If $iLastTimeChecked[$g_iCurAccount] = 0 Or $iDateCalc > 50 Then
;~ 		; Chek if the Boost is running
;~ 		If UBound($aiResourcesPos) > 1 And $aiResourcesPos[0] > 0 And $aiResourcesPos[1] > 0 Then
;~ 			ClickP($aiResourcesPos, 1, 0, "#Resources")
;~ 			If _Sleep($DELAYBOOSTHEROES2) Then Return
;~ 			ForceCaptureRegion()
;~ 			Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
;~ 			If $aResult[0] > 1 Then
;~ 				Local $sN = $aResult[1] ; Store bldg name
;~ 				Local $sL = $aResult[2] ; Sotre bdlg level
;~ 				If StringInStr($sN, "Collector", $STR_NOCASESENSEBASIC) > 0 Then
;~ 					; Structure located
;~ 					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_SUCCESS)
;~ 					$ok = True
;~ 				EndIf
;~ 			EndIf
;~ 		EndIf
;~ 		If $ok = True Then
;~ 			Local $aCheckBoosted = findButton("Boostleft")
;~ 			If Not IsArray($aCheckBoosted) Then
;~ 				ClickP($aAway, 2, 0, "#0161")
;~ 				If _Sleep($DELAYBOOSTBARRACKS1) Then Return

;~ 				Local $bChecked = BoostPotionMod("Resource Potion", "Town Hall", $g_aiTownHallPos, $g_iCmbBoostResourcePotion, $g_hCmbBoostResourcePotion) = _NowCalc()
;~ 				If Not $bChecked Then Return False
;~ 				$iLastTimeChecked[$g_iCurAccount] = _NowCalc() ; Reset the Check Timer
;~ 				Return True
;~ 			Else
;~ 				SetLog("Resource Potion is already Boosted", $COLOR_INFO)
;~ 			EndIf
;~ 			ClickP($aAway, 2, 0, "#0161")
;~ 		EndIf
;~ 	EndIf

;~ 	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
;~ 	checkMainScreen(False) ; Check for errors during function
	Return False
EndFunc   ;==>BoostTrainingPotion

Func BuilderPotionBoost()
	If $g_bChkBuilderPotion Then Return
	
	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	
	If _Sleep($DELAYBOOSTHEROES2) Then Return False
	
	If $iLastTimeChecked[$g_iCurAccount] = 0 Then

		If Abs($g_iTotalBuilderCount - $g_iFreeBuilderCount) >= $g_iInputBuilderPotion Then
 			If _Sleep($DELAYBOOSTHEROES2) Then Return
 			ForceCaptureRegion()
 			Local $aResult = getNameBuilding(242, 490 + $g_iBottomOffsetY)
 			If _Sleep($DELAYBOOSTHEROES2) Then Return
 			If $aResult <> "" Then
				Click(Random(211, 109, 1), Random(457, 137, 1))
				If _Sleep($DELAYBOOSTHEROES2) Then Return
				If BoostPotionMod("BuilderPotion", False) Then 
					$iLastTimeChecked[$g_iCurAccount] = 1
					Return True
					Else
					Return false
				EndIf
			Else
				Setlog("Magic Items| Fail builder potion.", $COLOR_ERROR)
				Return False
			EndIf
		EndIf
	EndIf
	Return True
EndFunc

Func ResourceBoost($aPos1 = 0, $aPos2 = 0)
 		If $g_bChkResourcePotion Then Return
		
		Local $iGold = $g_aiTempGainCost[0], $iElixir = $g_aiTempGainCost[1], $iDarkElixir = $g_aiTempGainCost[2]
		
		If BitAND($iElixir < $g_iInputElixirItems, $iDarkElixir < $g_iInputDarkElixirItems, $iGold < $g_iInputGoldItems) Then Return 
		
		Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]
		Local $aiResourcesPos[2] = [$aPos1, $aPos2]
		
		If $iLastTimeChecked[$g_iCurAccount] = 0 And not Abs($aiResourcesPos[0] + $aiResourcesPos[1]) = 0 Then

 			ClickP($aiResourcesPos, 1, 0, "#Resources")
 			If _Sleep($DELAYBOOSTHEROES2) Then Return
 			ForceCaptureRegion()
 			Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
 			If $aResult[0] > 1 Then
 				Local $sN = $aResult[1] ; Store bldg name
 				Local $sL = $aResult[2] ; Sotre bdlg level
 				If StringInStr($sN, "Collector", $STR_NOCASESENSEBASIC) > 0 Then
 					; Structure located
 					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_SUCCESS)
 					If BoostPotionMod("ResourcePotion") Then 
						$iLastTimeChecked[$g_iCurAccount] = 1
						Return True
						Else
						Return false
					EndIf
 				EndIf
			EndIf
			Else
			Setlog("Magic Items| Fail resource potion.", $COLOR_ERROR)
			Return False
		EndIf
	Return False
EndFunc

Func BoostPotionMod($sName, $bDebug = False)
	Local $aClick1[2] = [0, 0]
	
	If _Sleep(500) Then Return False
	
	_ImageSearchXML($g_sImgPotionsBtn, 0, "134, 580, 730, 675", True, False, True, 25)
	If not IsArray($g_aImageSearchXML) Then Return False
	If $bDebug Then _ArrayDisplay($g_aImageSearchXML)
	
	For $iResult = 0 To UBound($g_aImageSearchXML) - 1
		If _Sleep(100) Then Return False ; CPU Control
		;$g_bChkBuilderPotion, $g_bChkClockTowerPotion, $g_bChkHeroPotion, $g_bChkLabPotion, $g_bChkPowerPotion, $g_bChkResourcePotion
		
		If Not ($g_aImageSearchXML[$iResult][0]) = $sName Then ContinueLoop
		
		Switch $sName
			Case "BuilderPotion"
				If $g_bChkBuilderPotion Then ExitLoop
			Case "ClockTowerPotion"
				If $g_bChkClockTowerPotion Then ExitLoop 
			Case "HeroPotion"
				If $g_bChkHeroPotion Then ExitLoop 
			Case "LabPotion"
				If $g_bChkLabPotion Then ExitLoop 
			Case "ResourcePotion"
				If $g_bChkResourcePotion Then ExitLoop 
			;Case "PowerPotion" dont exist
			;	If $g_bChkBuilderPotion Then ExitLoop 
			;Case "BarracksPotion" Unused
			;	If $g_bChkBuilderPotion Then ExitLoop 
			Case Else
				Setlog("Magic Items : Invalid item " & $sName, $COLOR_ERROR)
				Return False
		EndSwitch
		$aClick1[0] = $g_aImageSearchXML[$iResult][1]
		$aClick1[1] = $g_aImageSearchXML[$iResult][2]
	Next
	
	Setlog("Magic Items : Builder Potion boost " & $sName, $COLOR_SUCCESS)
	ClickP($aClick1)
	
	;7C8AFF
	;360, 395
	;494, 451
	Local $bFuse = False
	
	For $i = 0 To 5
		If _Sleep(500) Then Return False ; CPU Control
		If IsArray(MultiPSimple(362, 396, 493, 450, Hex(0x8490FF, 6), 15, 5000)) Then 
				If $bDebug Then 
					Setlog(Random(360, 494, 1) & " / " & Random(395, 451, 1), $COLOR_ERROR)
					Else
					Click(Random(360, 494, 1), Random(395, 451, 1))
				EndIf
			$bFuse = True 
			Else
			If BitAND($i > 0, $bFuse) Then ExitLoop
		EndIf
	 Next
		 
	Return $bFuse
EndFunc   ;==>BoostPotionMod


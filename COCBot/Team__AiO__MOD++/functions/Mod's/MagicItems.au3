
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
	Local $aiResourcesPos[2] = [$aiTmp0, $aiTmp1]
	; Verifying existent Variables to run this routine
	;If Not AllowBoosting("Resource Potion", $g_iCmbBoostResourcePotion) Then Return

	SetLog("Boosting Resource Potion", $COLOR_INFO)
	If $g_aiTownHallPos[0] = "" Or $g_aiTownHallPos[0] = -1 Then
		LocateTownHall()
		SaveConfig()
		If _Sleep($DELAYBOOSTBARRACKS2) Then Return
	EndIf

	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0], $iDateCalc
	$iDateCalc = _DateDiff('n', $iLastTimeChecked[$g_iCurAccount], _NowCalc())
	Local $ok = False
	If $iLastTimeChecked[$g_iCurAccount] = 0 Or $iDateCalc > 50 Then
		; Chek if the Boost is running
		If UBound($aiResourcesPos) > 1 And $aiResourcesPos[0] > 0 And $aiResourcesPos[1] > 0 Then
			ClickP($aiResourcesPos, 1, 0, "#Resources")
			If _Sleep($DELAYBOOSTHEROES2) Then Return
			ForceCaptureRegion()
			Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
			If $aResult[0] > 1 Then
				Local $sN = $aResult[1] ; Store bldg name
				Local $sL = $aResult[2] ; Sotre bdlg level
				If StringInStr($sN, "Mine", $STR_NOCASESENSEBASIC) > 0 Then
					; Structure located
					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_SUCCESS)
					$ok = True
				ElseIf StringInStr($sN, "Collector", $STR_NOCASESENSEBASIC) > 0 Then
					; Structure located
					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_SUCCESS)
					$ok = True
				ElseIf StringInStr($sN, "Drill", $STR_NOCASESENSEBASIC) > 0 Then
					; Structure located
					SetLog("Find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_SUCCESS)
					$ok = True
				Else
					SetLog("Cannot find " & $sN & " (Level " & $sL & ") located at " & $aiResourcesPos[0] & ", " & $aiResourcesPos[1], $COLOR_ERROR)
				EndIf
			EndIf
		EndIf
		If $ok = True Then
			Local $aCheckBoosted = findButton("Boostleft")
			If Not IsArray($aCheckBoosted) Then
				ClickP($aAway, 2, 0, "#0161")
				If _Sleep($DELAYBOOSTBARRACKS1) Then Return

				Local $bChecked = BoostPotionMod("Resource Potion", "Town Hall", $g_aiTownHallPos, $g_iCmbBoostResourcePotion, $g_hCmbBoostResourcePotion) = _NowCalc()
				If Not $bChecked Then Return False
				$iLastTimeChecked[$g_iCurAccount] = _NowCalc() ; Reset the Check Timer
				Return True
			Else
				SetLog("Resource Potion is already Boosted", $COLOR_INFO)
			EndIf
			ClickP($aAway, 2, 0, "#0161")
		EndIf
	EndIf

	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
	checkMainScreen(False) ; Check for errors during function
	Return False
EndFunc   ;==>BoostTrainingPotion

Func BoostPotionMod($sName, $sOcrName, $aPos, ByRef $icmbBoostValue, $cmbBoostCtrl)
	Local $boosted = False
	Local $ok = False

	If UBound($aPos) > 1 And $aPos[0] > 0 And $aPos[1] > 0 Then
		BuildingClickP($aPos, "#0462")
		If _Sleep($DELAYBOOSTHEROES2) Then Return
		ForceCaptureRegion()
		Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
		If $aResult[0] > 1 Then
			Local $sN = $aResult[1] ; Store bldg name
			Local $sL = $aResult[2] ; Sotre bdlg level
			If $sOcrName = "" Or StringInStr($sN, $sOcrName, $STR_NOCASESENSEBASIC) > 0 Then
				; Structure located
				SetLog("Boosting everything using potion")
				$ok = True
			Else
				SetLog("Cannot boost using potion some error occured", $COLOR_ERROR)
			EndIf
		EndIf
	EndIf
	If $ok = True Then
		Local $sTile = "BoostPotion_0_90.xml", $sRegionToSearch = "172,238,684,469"
		Local $Boost = findButton("MagicItems")
		If UBound($Boost) > 1 Then
			If $g_bDebugSetlog Then SetDebugLog("Magic Items Button X|Y = " & $Boost[0] & "|" & $Boost[1], $COLOR_DEBUG)
			Click($Boost[0], $Boost[1], 1, 0, "#0463")
			If _Sleep($DELAYBOOSTHEROES1) Then Return
			$Boost = decodeSingleCoord(FindImageInPlace($sTile, @ScriptDir & "\imgxml\imglocbuttons\" & $sTile, $sRegionToSearch))
			If UBound($Boost) > 1 Then
				If $g_bDebugSetlog Then SetDebugLog("Boost Potion Button X|Y = " & $Boost[0] & "|" & $Boost[1], $COLOR_DEBUG)
				ClickP($Boost)
				If _Sleep($DELAYBOOSTHEROES1) Then Return
				If Not _ColorCheck(_GetPixelColor(255, 550, True), Hex(0xFFFFFF, 6), 25) Then
					SetLog("Cannot find/verify 'Use' Button", $COLOR_WARNING)
					ClickP($aAway, 2, 0, "#000000") ; Click Away, Necessary! due to possible errors/changes
					Return False ; Exit Function
				EndIf
				Click(305, 556) ; Click on 'Use'
				If _Sleep($DELAYBOOSTHEROES2) Then Return
				$Boost = findButton("BoostPotionGreen")
				If IsArray($Boost) Then
					Click($Boost[0], $Boost[1], 1, 0, "#0465")
					If _Sleep($DELAYBOOSTHEROES4) Then Return
					If $icmbBoostValue <= 5 Then
						$icmbBoostValue -= 1
						SetLog($sName & ' Boost completed. Remaining iterations: ' & $icmbBoostValue, $COLOR_SUCCESS)
						_GUICtrlComboBox_SetCurSel($cmbBoostCtrl, $icmbBoostValue)
					EndIf
					$boosted = True
				Else
					SetLog($sName & " is already Boosted", $COLOR_SUCCESS)
				EndIf
			Else
				SetLog($sName & " Potion Button not found!", $COLOR_ERROR)
				If _Sleep($DELAYBOOSTHEROES4) Then Return
			EndIf
			If _Sleep($DELAYBOOSTHEROES3) Then Return
			ClickP($aAway, 1, 0, "#0465")
		Else
			SetLog("Abort boosting " & $sName & ", bad location", $COLOR_ERROR)
		EndIf
	EndIf
	Return $boosted
EndFunc   ;==>BoostPotion


#Region - Random CSV - Team AIO Mod++
Func CSVRandomization($bDebug = False)
	If $g_bDebugSetlog = True Or $bDebug = True Then SetLog("[CSVRandomization] Start")
	
	If ($g_aiAttackAlgorithm[$DB] <> 1) And ($g_aiAttackAlgorithm[$LB] <> 1) Then Return False

	Local $sFilePath = ""
	Local $aModes[2] = [$DB, $LB], $sModes[2] = ["Dead base", "Active base"], $aCsvModesBool[2] = [$g_abRandomCSVDB, $g_abRandomCSVAB], $aCsvModesName[2] = [$g_asRandomCSVDB, $g_asRandomCSVAB]
	
	
	Static $oDictionary = ObjCreate("Scripting.Dictionary")
	If @error Then
		SetLog("[CSVRandomization] Error creating the dictionary object")
		Return False
	EndIf
	
	Local $iLuck = 0, $iIndex = 0, $bSync = IsSyncCSVEnabled()
	For $j = 0 To UBound($aModes) - 1
		If $bSync = True Then
			If ($aModes[$j] = $DB And $g_abLinkThatAndUseIn[$LB] = True) Or ($aModes[$j] = $LB And $g_abLinkThatAndUseIn[$DB] = True) Then
				ContinueLoop
			EndIf
		EndIf
		
		For $i = 0 To 3
			$oDictionary($i) = (($aCsvModesBool[$aModes[$j]])[$i] And FileExists($g_sCSVAttacksPath & "\" & ($aCsvModesName[$aModes[$j]])[$i] & ".csv")) ? (1) : (0)
		Next
		
		For $i = 1 To 256
			$iLuck = Random(0, 3, 1)
			$iIndex = $oDictionary($iLuck)
			If $iIndex = 1 Then
                $g_sAttackScrScriptName[$aModes[$j]] = ($aModes[$j] = $DB) ? ($g_asRandomCSVDB[$iLuck]) : ($g_asRandomCSVAB[$iLuck])
				If $bSync = True Then
					$g_sAttackScrScriptName[$aModes[Abs($j - 1)]] = $g_sAttackScrScriptName[$aModes[$j]]
				EndIf
                ContinueLoop 2
			EndIf
		Next
		
		SetLog("[CSVRandomization] No random script found on " & $sModes[$j], $COLOR_ERROR)
	Next
	
	If $g_iGuiMode = 1 Then
		Local $iTempIndex = 0
		
		$iTempIndex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptnameDB, $g_sAttackScrScriptName[$DB])
		If $iTempIndex = -1 Then $iTempIndex = 0
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptnameDB, $iTempIndex)
		
		cmbScriptNameAB()
		
		$iTempIndex = _GUICtrlComboBox_FindStringExact($g_hCmbScriptnameAB, $g_sAttackScrScriptName[$LB])
		If $iTempIndex = -1 Then $iTempIndex = 0
		_GUICtrlComboBox_SetCurSel($g_hCmbScriptnameAB, $iTempIndex)
		
		cmbScriptNameDB()
	EndIf
	
	SyncCSVMain()
	
	If $g_bDebugSetlog = True Or $bDebug = True Then SetLog("[CSVRandomization] End")
EndFunc   ;==>CSVRandomization

Func IsSyncRandomCSVReallyEnabled()
	For $i = 0 To 3
		If $g_abLinkThatAndUseIn[$LB] = True Then
			If $g_abRandomCSVAB[$i] And FileExists($g_sCSVAttacksPath & "\" & $g_asRandomCSVAB[$i] & ".csv") Then Return True
		ElseIf $g_abLinkThatAndUseIn[$DB] = True Then
			If $g_abRandomCSVDB[$i] And FileExists($g_sCSVAttacksPath & "\" & $g_asRandomCSVDB[$i] & ".csv") Then Return True
		EndIf
	Next
	Return False
EndFunc   ;==>SingularCSV

Func IsSyncCSVEnabled()
	Local $aTemp = "", $sFilename = ""
	If $g_abAttackTypeEnable[$LB] = True And $g_abLinkThatAndUseIn[$LB] = True And $g_aiAttackAlgorithm[$LB] = 1 Then
		If $g_iGuiMode = 1 Then
			$aTemp = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameAB)
			$sFilename = $aTemp[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameAB) + 1]
			
			$g_sAttackScrScriptName[$DB] = $sFilename
			$aTemp = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameDB, $g_sAttackScrScriptName[$DB])
			If $aTemp = -1 Then $aTemp = 0
			_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, $aTemp)
		Else
			$sFilename = $g_sAttackScrScriptName[$LB]
			$g_sAttackScrScriptName[$DB] = $sFilename
		EndIf
		Return True
	EndIf
	
	If $g_abAttackTypeEnable[$DB] = True And $g_abLinkThatAndUseIn[$DB] = True And $g_aiAttackAlgorithm[$DB] = 1 Then
		If $g_iGuiMode = 1 Then
			$aTemp = _GUICtrlComboBox_GetListArray($g_hCmbScriptNameDB)
			$sFilename = $aTemp[_GUICtrlComboBox_GetCurSel($g_hCmbScriptNameDB) + 1]
			
			$g_sAttackScrScriptName[$LB] = $sFilename
			$aTemp = _GUICtrlComboBox_FindStringExact($g_hCmbScriptNameAB, $g_sAttackScrScriptName[$LB])
			If $aTemp = -1 Then $aTemp = 0
			_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, $aTemp)
		Else
			$sFilename = $g_sAttackScrScriptName[$DB]
			$g_sAttackScrScriptName[$LB] = $sFilename
		EndIf
		Return True
	EndIf

	Return False
EndFunc

Func SyncCSVMain()
	If IsSyncCSVEnabled() Then
		If ($g_aiAttackAlgorithm[$DB] = 1) Then
			ApplyScriptAB()
			ApplyScriptDB()
			Return True
		EndIf
		If ($g_aiAttackAlgorithm[$LB] = 1) Then
			ApplyScriptDB()
			ApplyScriptAB()
			Return True
		EndIf
	EndIf
	Return False
EndFunc

Func SyncCSVArmy()
	Local $iApply = 0, $sFilename = "", $asLine = Null
	Local $aiCSVTroops[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVSpells[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $aiCSVSieges[$eSiegeMachineCount] = [0, 0, 0, 0, 0, 0]

	; SetLog("CSV settings apply starts: " & $sFilename, $COLOR_INFO)

	If IsSyncCSVEnabled() Then
		If ($g_aiAttackAlgorithm[$DB] = 1) And $g_abLinkThatAndUseIn[$DB] Then
			$sFilename = $g_sAttackScrScriptName[$DB]
		ElseIf ($g_aiAttackAlgorithm[$LB] = 1) And $g_abLinkThatAndUseIn[$LB] Then
			$sFilename = $g_sAttackScrScriptName[$LB]
		EndIf
		
		If $sFilename = "" Then Return False
	
		$asLine = FileReadToArray($g_sCSVAttacksPath & "\" & $sFilename & ".csv")
		If @error Then
			SetLog("Attack CSV script not found: " & $g_sCSVAttacksPath & "\" & $sFilename & ".csv", $COLOR_ERROR)
			Return False
		EndIf
		
		IsSyncCSVEnabled()
		
		$iApply = ParseTroopsCSV($aiCSVTroops, $aiCSVSpells, $aiCSVSieges, $asLine)

		$iApply = 0
		For $i = 0 To UBound($aiCSVTroops) - 1
			If $aiCSVTroops[$i] > 0 Then $iApply += 1
		Next
		
		For $i = 0 To UBound($aiCSVSpells) - 1
			If $aiCSVSpells[$i] > 0 Then $iApply += 1
		Next
		
		If $iApply = 0 Then Return False
		
		$g_aiArmyCompTroops = $aiCSVTroops
		$g_aiArmyCompSpells = $aiCSVSpells
		
		Return True

	EndIf
	Return False
EndFunc

Func ChkRandomCSVAB()
	Local $iLastSelected = -1
	If $g_iGuiMode = 1 Then
		Local $iLast = 0
		For $i = 0 To UBound($g_ahChkRandomCSVAB) -1
			$g_abRandomCSVAB[$i] = (GUICtrlRead($g_ahChkRandomCSVAB[$i]) = $GUI_CHECKED)
			If $g_abRandomCSVAB[$i] Then
				$iLast += 1
				$iLastSelected = _GUICtrlComboBox_GetCurSel($g_ahCmbRandomCSVAB[$i])
				GUICtrlSetState($g_ahCmbRandomCSVAB[$i], $GUI_ENABLE)
			Else
				GUICtrlSetState($g_ahCmbRandomCSVAB[$i], $GUI_DISABLE)
			EndIf
		Next
		
		GUICtrlSetState($g_hCmbScriptNameAB, ($iLast > 0) ? ($GUI_DISABLE) : ($GUI_ENABLE))
		
		If $iLastSelected > 0 Then
			_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameAB, $iLastSelected)
		EndIf
	EndIf
EndFunc

Func ChkRandomCSVDB()
	Local $iLastSelected = -1
	If $g_iGuiMode = 1 Then
		Local $iLast = 0
		For $i = 0 To UBound($g_ahChkRandomCSVDB) -1
			$g_abRandomCSVDB[$i] = (GUICtrlRead($g_ahChkRandomCSVDB[$i]) = $GUI_CHECKED)
			If $g_abRandomCSVDB[$i] Then
				$iLast += 1
				$iLastSelected = _GUICtrlComboBox_GetCurSel($g_ahCmbRandomCSVDB[$i])
				GUICtrlSetState($g_ahCmbRandomCSVDB[$i], $GUI_ENABLE)
			Else
				GUICtrlSetState($g_ahCmbRandomCSVDB[$i], $GUI_DISABLE)
			EndIf
		Next
		
		GUICtrlSetState($g_hCmbScriptNameDB, ($iLast > 0) ? ($GUI_DISABLE) : ($GUI_ENABLE))
		
		If $iLastSelected > 0 Then
			_GUICtrlComboBox_SetCurSel($g_hCmbScriptNameDB, $iLastSelected)
		EndIf
	EndIf
EndFunc
#EndRegion - Random CSV - Team AIO Mod++

#Region - Custom Yard - Team AIO Mod++
Func CleanBBYard($bTest = False)
	If Not $g_bChkCleanBBYard Then Return
	Return _CleanYard(True, $bTest) ; _CleanYard(False, True)
EndFunc

Func _CleanYard($aIsBB = Default, $bTest = False)
	
	If $aIsBB Then
		; Check if is in Builder Base
		If Not IsMainPageBuilderBase() Then Return
	
		; Get Builders available
		If Not getBuilderCount(True, True) Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
	
		If $g_iFreeBuilderCountBB = 0 Then Return
	Else
		; Check if is in Village
		If Not IsMainPage() Then Return
	
		; Get Builders available
		If Not getBuilderCount() Then Return ; update builder data, return if problem
		If _Sleep($DELAYRESPOND) Then Return
	
		If $g_iFreeBuilderCount = 0 Then Return
	EndIf
	
	If (Number($g_aiCurrentLootBB[$eLootElixirBB]) > 50000 And $aIsBB) Or (Number($g_aiCurrentLoot[$eLootElixir]) > 50000 And not $aIsBB) Or $bTest Then
		Local $aResult, $aRTmp1, $aRTmp2
		
		If $aIsBB Then
			$aResult = findMultipleQuick($g_sImgCleanBBYard, 0, "0,0,860,732", Default, Default, Default, 1)
		Else
			$aRTmp1 = findMultipleQuick($g_sImgCleanYardSnow, 0, "0,0,860,732", Default, Default, Default, 1)
			$aRTmp2 = findMultipleQuick($g_sImgCleanYard, 0, "0,0,860,732", Default, Default, Default, 1)

			If IsArray($aRTmp1) Then 
				$aResult = $aRTmp1
				If IsArray($aRTmp2) Then _ArrayAdd($aResult, $aRTmp2)
			ElseIf IsArray($aRTmp2) Then
				$aResult = $aRTmp2
			EndIf
		EndIf
		
		;_ArrayDisplay($aResult)
		
		If Not IsArray($aResult) Then 
			Return False
		Else
			_ArrayShuffle($aResult)
		EndiF
		
		SetLog("- Removing some obstacles - Custom by AIO Mod ++.", $COLOR_ACTION)
		
		For $i = 0 To UBound($aResult) - 1
			If $g_bEdgeObstacle Then
				If (Not isOutsideDiamond($aResult[$i][1], $aResult[$i][2], 83, 156, 780, 680) and $aIsBB) Or (Not isOutsideDiamond($aResult[$i][1], $aResult[$i][2], 43, 50, 818, 634) And not $aIsBB) Then ContinueLoop
			Else
				If (Not isOutsideDiamond($aResult[$i][1], $aResult[$i][2], 83, 156, 780, 680) and $aIsBB) Or (Not isOutsideDiamond($aResult[$i][1], $aResult[$i][2]) And not $aIsBB) Then ContinueLoop
			EndIf
			
			If $g_bDebugSetlog Then SetDebugLog($aResult[$i][0] & " found (" & $aResult[$i][1] & "," & $aResult[$i][2] & ")", $COLOR_SUCCESS)
			If _Sleep($DELAYRESPOND) Then Return
			For $iSeconds = 0 To Random(50, 120, 1)
			getBuilderCount(True, (($aIsBB) ? (True) : (False)))
			If ($g_iFreeBuilderCountBB > 0 And $aIsBB) Or ($g_iFreeBuilderCount > 0 And not $aIsBB) Then
				If getBuilderCount(True, (($aIsBB) ? (True) : (False))) = False Then Return     ; This check IsMainPageX
				If ($g_iFreeBuilderCountBB > 0 And $aIsBB) Or ($g_iFreeBuilderCount > 0 And not $aIsBB) Then
					PureClick($aResult[$i][1], $aResult[$i][2], 1, 0, "#0430")
					If _Sleep(Random(500, 700, 1)) Then Return
					If ClickRemoveObstacle() Then
						ContinueLoop 2
					Else
						SetDebugLog(" - CleanYardAIO | 0x1 error.")
						ExitLoop
					EndIf
				EndIf
				Else
				If RandomSleep(3000) Then Return
			EndIf
			Next
			SetLog("- Removing some obstacles, wait. - Custom by AIO Mod ++.", $COLOR_INFO)
		Next
	EndIf
	UpdateStats()

EndFunc   ;==>CleanBBYard
#EndRegion - Custom Yard - Team AIO Mod++
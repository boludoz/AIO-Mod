Func CleanBBYard($bTest = False)
	; Early exist if noting to do
	If Not BitOr($g_bChkCleanBBYard, $bTest, TestCapture()) Then Return

	; Check if is in Builder Base
	If not IsMainPageBuilderBase() Then Return
	
	; Get Builders available
	If Not getBuilderCount(True, True) Then Return ; update builder data, return if problem
	If _Sleep($DELAYRESPOND) Then Return

	If getBuilderCount(True, True) = False Then Return ; update builder data, return if problem
	If $g_iFreeBuilderCountBB = 0 Then Return 

	If Number($g_aiCurrentLootBB[$eLootElixirBB]) > 50000 Or $bTest Then
		Local $aResult = findMultipleQuick($g_sImgCleanBBYard, 0, "0,0,860,732", True, False)
		_ArrayShuffle($aResult)
		If not IsArray($aResult) Then Return False
		_ArrayS
		For $i = 0 To UBound($aResult) - 1
			If $g_bDebugSetlog Then SetDebugLog($aResult[$i][0] & " found (" & $aResult[$i][1] & "," & $aResult[$i][2] & ")", $COLOR_SUCCESS)
			
				If _Sleep($DELAYRESPOND) Then Return
				For $iSeconds = 0 To 60
					If _Sleep(1500) Then Return
					If getBuilderCount(True, True) = False Then Return ; This check IsMainPageBuilderBase
					If $g_iFreeBuilderCountBB > 0 Then 
						PureClick($aResult[$i][1], $aResult[$i][2], 1, 0, "#0430")
						If _Sleep(Random(500, 700, 1)) Then Return
						If ClickRemoveObstacle() Then 
							ContinueLoop 2
						Else
							SetDebugLog("CleanBBYard | Error here.")
							ExitLoop
						EndIf
					EndIf
				Next
		Next
	EndIf
	UpdateStats()

EndFunc   ;==>CleanBBYard
;=========================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
; Modified ......: Boludoz (12/2018-31/12/2019)
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestGetAttackBarBB()
	Setlog("** TestGetAttackBarBB START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	Local $TempDebug = $g_bDebugOcr
	$g_bDebugOcr = True
	GetAttackBarBB()
	$g_bRunState = $Status
	$g_bDebugOcr = $TempDebug
	Setlog("** TestGetAttackBarBB END**", $COLOR_DEBUG)
EndFunc   ;==>TestGetAttackBarBB

Func ArmyCampSelectedNames($g_iCmbBBArmy)
	Local $aNames = $g_asAttackBarBB
	Return $aNames[$g_iCmbBBArmy + 1]
EndFunc   ;==>ArmyCampSelectedNames

Func BuilderBaseSelectCorrectCampDebug()
	Local $aLines[0]
	Local $sName = "CAMP" & "|"
	For $iName = 0 To UBound($g_iCmbCampsBB) - 1
		$sName &= $g_asBBTroopShortNames[$g_iCmbCampsBB[$iName]]
		$sName &= "|"
		If $iName = 0 Then ContinueLoop
		Local $aFakeCsv[1] = [$sName]
		_ArrayAdd($aLines, $aFakeCsv)
	Next

	_ArrayDisplay($aLines)
EndFunc   ;==>BuilderBaseSelectCorrectCampDebug

Func FullNametroops($aResults)
	For $i = 1 To UBound($g_asAttackBarBB) - 1
		If $aResults = $g_asAttackBarBB[$i] Then Return $g_avStarLabTroops[$i][3]
	Next
EndFunc   ;==>FullNametroops

Func BuilderBaseSelectCorrectScript(ByRef $AvailableTroops)

	If Not $g_bRunState Then Return
	Local $aLines[0]
	Static $lastScript
	
	If ($g_iCmbBBAttack = $g_eBBAttackCSV) And $g_bChkBBGetFromCSV Then
		
		If Not $g_bChkBBRandomAttack Then
			$lastScript = 0
			$g_iBuilderBaseScript = 0
		Else
			; Random script , but not the last
			For $i = 0 To 10
				$g_iBuilderBaseScript = Random(0, 2, 1)
				If $lastScript <> $g_iBuilderBaseScript Then
					$lastScript = $g_iBuilderBaseScript
					ExitLoop
				EndIf
			Next
		EndIf
		
		Setlog("Attack using the " & $g_sAttackScrScriptNameBB[$g_iBuilderBaseScript] & " script.", $COLOR_INFO)
		; Let load the Command [Troop] from CSV
		Local $FileNamePath = @ScriptDir & "\CSV\BuilderBase\" & $g_sAttackScrScriptNameBB[$g_iBuilderBaseScript] & ".csv"
		If FileExists($FileNamePath) Then $aLines = FileReadToArray($FileNamePath)

	ElseIf Not ($g_iCmbBBAttack = $g_eBBAttackCSV) Then
		Local $aLines[0]
		Local $sName = "CAMP" & "|"
		For $iName = 0 To UBound($g_iCmbCampsBB) - 1
			$sName &= $g_asBBTroopShortNames[$g_iCmbCampsBB[$iName]]
			$sName &= "|"
			If $iName = 0 Then ContinueLoop
			Local $aFakeCsv[1] = [$sName]
			_ArrayAdd($aLines, $aFakeCsv)
		Next
	ElseIf Not $g_bChkBBGetFromCSV Then
		Setlog("Get from CSV unselected.", $COLOR_ERROR)
		Return
	EndIf

	; Move backwards through the array deleting the blanks
	For $i = UBound($AvailableTroops) - 1 To 0 Step -1
		If $AvailableTroops[$i][0] = "" Then
			_ArrayDelete($AvailableTroops, $i)
		EndIf
	Next

	; Let's get the correct number of Army camps
	Local $CampsQuantities = 0
	For $i = 0 To UBound($AvailableTroops) - 1
		If $AvailableTroops[$i][0] <> "Machine" Then $CampsQuantities += 1
	Next
	Setlog("Available " & $CampsQuantities & " Camps.", $COLOR_INFO)

	Local $aCamps[0]

	; Loop for every line on CSV
	For $iLine = 0 To UBound($aLines) - 1
		If Not $g_bRunState Then Return
		Local $aSplitLine = StringSplit($aLines[$iLine], "|", $STR_NOCOUNT)
		Local $command = StringStripWS(StringUpper($aSplitLine[0]), $STR_STRIPALL)
		If $command = "CAMP" Then
			For $i = 1 To UBound($aSplitLine) - 1
				If $aSplitLine[$i] = "" Or StringIsSpace($aSplitLine[$i]) Then ExitLoop
				ReDim $aCamps[UBound($aCamps) + 1]
				$aCamps[UBound($aCamps) - 1] = StringStripWS($aSplitLine[$i], $STR_STRIPALL)
			Next
			; Select the correct CAMP [cmd line] to use according with the first attack bar detection = how many camps do you have
			If $CampsQuantities = UBound($aCamps) Then
				If $g_bDebugSetlog Then Setlog(_ArrayToString($aCamps, "-", -1, -1, "|", -1, -1))
				ExitLoop
			Else
				Local $aCamps[0]
			EndIf
		EndIf
	Next

	If UBound($aCamps) < 1 Then Return

	;Result Of BelowCode e.g $aCamps
	;$aCamps Before :Giant-Barbarian-Barbarian-Bomb-Cannon-Cannon

	;First Find The Correct Index Of Camps In Attack Bar
	For $i = 0 To UBound($aCamps) - 1
		;Just In Case Someone Mentioned Wrong Troop Name Select Default Barbarian Troop
		$aCamps[$i] = _ArraySearch($g_asAttackBarBB, CSVtoImageName($aCamps[$i])) < 0 ? 0 : _ArraySearch($g_asAttackBarBB, CSVtoImageName($aCamps[$i]))
	Next
	;After populate with the new priority position let's sort ascending column 1
	_ArraySort($aCamps, 0, 0, 0, 1)
	;Just Assign The Short Names According to new priority positions
	For $i = 0 To UBound($aCamps) - 1
		$aCamps[$i] = $g_asAttackBarBB[$aCamps[$i]]
	Next

	; [0] = Troops Name , [1] - Priority position
	Local $NewAvailableTroops[UBound($AvailableTroops)][2]

	For $i = 0 To UBound($AvailableTroops) - 1
		$NewAvailableTroops[$i][0] = $AvailableTroops[$i][0]
		$NewAvailableTroops[$i][1] = _ArraySearch($g_asAttackBarBB, CSVtoImageName($AvailableTroops[$i][0]))
	Next

	If $g_bDebugSetlog Then Setlog(_ArrayToString($NewAvailableTroops, "-", -1, -1, "|", -1, -1))

	Local $Waschanged = False
	Local $avoidInfLoop = 0

	Local $aSwicthBtn[6] = [112, 180, 253, 327, 398, 471]
	Local $aPointSwitch = [$aSwicthBtn[Random(0, UBound($aSwicthBtn) - 1, 1)] + Random(0, 5, 1), 708 + Random(0, 5, 1)]
	
	For $i = 0 To $CampsQuantities - 1
		If Not $g_bRunState Then Return
		If StringCompare($NewAvailableTroops[$i][0], $aCamps[$i]) <> 0 Then
			$Waschanged = True
			Setlog("Incorrect troop On Camp " & $i + 1 & " - " & $NewAvailableTroops[$i][0] & " -> " & $aCamps[$i])
			Local $aPointSwitch = [$aSwicthBtn[$i] + Random(0, 5, 1), 708 + Random(0, 5, 1)]
			Setlog("Click Switch Button " & $i, $COLOR_INFO)
			PureClick($aPointSwitch[0], $aPointSwitch[1], 1, 0)
			If Not $g_bRunState Then Return
			If _Sleep(500) Then Return

			If Not _WaitForCheckXML($g_sImgCustomArmyBB, "0,681,860,728", True, 10000, 100) Then
				Setlog("_WaitForCheckXML Error at Camps!", $COLOR_ERROR)
				$i = $i - 1
				$avoidInfLoop += 1
				If Not $g_bRunState Then ExitLoop
				ContinueLoop
			EndIf

			; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
			Local $aAttackBar = _ImageSearchXML($g_sImgDirBBTroops, 20, "0,523,861,615", True, False) ;GetAttackBarBB()
			If $aAttackBar = -1 Then
;~ 				_DebugFailedImageDetection("Attackbar")
				Return False
			EndIf
			For $j = 0 To UBound($aAttackBar) - 1
				If Not $g_bRunState Then ExitLoop
				If $aAttackBar[$j][0] = $aCamps[$i] Then
					;Local $Point = [$aAttackBar[$j][1], $aAttackBar[$j][2]]
					If _sleep(1000) Then Return
					PureClick($aAttackBar[$j][1] + Random(1, 5, 1), $aAttackBar[$j][2] + Random(1, 5, 1), 1, 0)
					If _sleep(1000) Then Return
					Setlog("Selected " & FullNametroops($aCamps[$i]) & " X:| " & $aAttackBar[$j][1] & " Y:| " & $aAttackBar[$j][2], $COLOR_SUCCESS)
					$NewAvailableTroops[$i][0] = $aCamps[$i]
					$NewAvailableTroops[$i][1] = _ArraySearch($g_asAttackBarBB, $aCamps[$i])
					; After populate with the new prio position let's sort ascending column 1
					_ArraySort($NewAvailableTroops, 0, 0, 0, 1)
					If $g_bDebugSetlog Then Setlog("New tab is " & _ArrayToString($NewAvailableTroops, "-", -1, -1, "|", -1, -1), $COLOR_INFO)
					; Now let's restart the for loop , is a nesty way to do but is only to tests
					$i = -1
					ExitLoop
				EndIf
			Next
		EndIf
	Next
	If _WaitForCheckXML($g_sImgCustomArmyBB, "0,681,860,728", True, 1000, 100) Then ClickP($aPointSwitch)
	If Not $Waschanged Then Return

	If _Sleep(500) Then Return

	; populate the correct array with correct Troops
	For $i = 0 To UBound($NewAvailableTroops) - 1
		$AvailableTroops[$i][0] = $NewAvailableTroops[$i][0]
	Next

	For $i = 0 To UBound($AvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $AvailableTroops[$i][0] <> "" Then ;We Just Need To redo the ocr for mentioned troop only
			$AvailableTroops[$i][4] = Number(_getTroopCountBig(Number($AvailableTroops[$i][1]), 633))
			If $AvailableTroops[$i][4] < 1 Then $AvailableTroops[$i][4] = Number(_getTroopCountSmall(Number($AvailableTroops[$i][1]), 640)) ; For Small numbers when the troop is selected
			If $AvailableTroops[$i][0] = "Machine" Then $AvailableTroops[$i][4] = 1
		EndIf
	Next

	For $i = 0 To UBound($AvailableTroops) - 1
		If Not $g_bRunState Then Return
		If $AvailableTroops[$i][0] <> "" Then SetLog("[" & $i + 1 & "] - " & $AvailableTroops[$i][4] & "x " & FullNametroops($AvailableTroops[$i][0]), $COLOR_SUCCESS)
	Next
EndFunc   ;==>BuilderBaseSelectCorrectScript

; _ArraySearch($g_asAttackBarBB, $AvailableTroops[$i][0])
Func CSVtoImageName($sTroop = "Barb", $asAttackTroopList = $g_asAttackBarBB)
	For $vT In $asAttackTroopList
		If (StringInStr($vT, $sTroop) <> 0) Then Return ($vT)
	Next
	Return $sTroop
EndFunc   ;==>CSVtoImageName

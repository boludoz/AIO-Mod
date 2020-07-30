;=========================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
; Modified ......: Boludoz (12/2018-31/12/2019), Dissociable
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
	Local $aNames = $g_asAttackBarBB2
	;$aNames[0] = "EmptyCamp"
	Return $aNames[$g_iCmbBBArmy]
EndFunc   ;==>ArmyCampSelectedNames

Func BuilderBaseSelectCorrectCampDebug()
	Local $aLines[0]
	Local $sName = "CAMP" & "|"
	For $iName = 0 To UBound($g_iCmbCampsBB) - 1
		$sName &= ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) : ("Barb")
		$sName &= "|"
		If $iName = 0 Then ContinueLoop
		Local $aFakeCsv[1] = [$sName]
		_ArrayAdd($aLines, $aFakeCsv)
	Next

	_ArrayDisplay($aLines)
EndFunc   ;==>BuilderBaseSelectCorrectCampDebug

Func FullNametroops($aResults)
	For $i = 0 To UBound($g_asAttackBarBB2) - 1
		If $aResults = $g_asAttackBarBB2[$i] Then 
			If UBound($g_avStarLabTroops) -1 < $i+1 Then ExitLoop
			Return $g_avStarLabTroops[$i+1][3]
		EndIf
	Next
	Return $aResults
EndFunc   ;==>FullNametroops

Func TestBuilderBaseSelectCorrectScript()
	Local $aAvailableTroops = GetAttackBarBB()
	BuilderBaseSelectCorrectScript($aAvailableTroops)
	Return $aAvailableTroops
EndFunc

Func BuilderBaseSelectCorrectScript(ByRef $aAvailableTroops)

	If Not $g_bRunState Then Return
	Local $bIsCampCSV = False
	Local $aLines[0]
	Static $lastScript

	If ($g_iCmbBBAttack = $g_eBBAttackCSV) Or ($g_bChkBBGetFromCSV = True) Then
			
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
			
			; Special case if CSV dont have camps (open eye).
			For $iLine = 0 To UBound($aLines) - 1
				If Not $g_bRunState Then Return
				Local $aSplitLine = StringSplit($aLines[$iLine], "|", $STR_NOCOUNT)
				Local $command = StringStripWS(StringUpper($aSplitLine[0]), $STR_STRIPALL)
				
				If $command = "CAMP" Then 
					$bIsCampCSV = True
					ExitLoop
				EndIf
			Next
	EndIf
	
	If ($bIsCampCSV = False) Or BitAND((Not $g_bChkBBGetFromCSV), ($g_iCmbBBAttack = $g_eBBAttackSmart)) <> 0 Then
		Local $sName = "CAMP" & "|"
		For $iName = 0 To UBound($g_iCmbCampsBB) - 1
			$sName &= ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) : ("Barb")
			$sName &= "|"
			If $iName = 0 Then ContinueLoop
			Local $aFakeCsv[1] = [$sName]
			_ArrayAdd($aLines, $aFakeCsv)
		Next
	EndIf
	
	If UBound($aLines) = 0 Then
		SetLog("BuilderBaseSelectCorrectScript 0x12 error.", $COLOR_ERROR)
		Return
	EndIf
	
	; Move backwards through the array deleting the blanks
	For $i = UBound($aAvailableTroops) - 1 To 0 Step -1
		If $aAvailableTroops[$i][0] = "" Then
			_ArrayDelete($aAvailableTroops, $i)
		EndIf
	Next
	
	_ArraySort($aAvailableTroops, 0, 0, 0, 1)

	; Let's get the correct number of Army camps
	Local $iCampsQuantities = 0
	For $i = 0 To UBound($aAvailableTroops) - 1
		If $aAvailableTroops[$i][0] <> "Machine" Then $iCampsQuantities += 1
	Next
	Setlog("Available " & $iCampsQuantities & " Camps.", $COLOR_INFO)

	Local $aCamps

	; Loop for every line on CSV
	For $iLine = 0 To UBound($aLines) - 1
		If Not $g_bRunState Then Return
		Local $aSplitLine = StringSplit($aLines[$iLine], "|", $STR_NOCOUNT)
		Local $command = StringStripWS(StringUpper($aSplitLine[0]), $STR_STRIPALL)
		If $command = "CAMP" Then
			For $i = 1 To UBound($aSplitLine) - 1
				If $aSplitLine[$i] = "" Or StringIsSpace($aSplitLine[$i]) Then ExitLoop
				_ArrayAdd($aCamps, TranslateCsvTroopName(StringStripWS($aSplitLine[$i], $STR_STRIPALL)))
			Next
			; Select the correct CAMP [cmd line] to use according with the first attack bar detection = how many camps do you have
			If $iCampsQuantities = UBound($aCamps) Then
				If $g_bDebugSetlog Then Setlog(_ArrayToString($aCamps, "-", -1, -1, "|", -1, -1))
				ExitLoop
			Else
				Local $aCamps[0]
			EndIf
		EndIf
	Next

	If UBound($aCamps) = 0 Then
		SetLog("BuilderBaseSelectCorrectScript 0x13 error.", $COLOR_ERROR)
		Return
	EndIf

	;Result Of BelowCode e.g $aCamps
	;$aCamps Before :Giant-Barbarian-Barbarian-Bomb-Cannon-Cannon

	;First Find The Correct Index Of Camps In Attack Bar
	For $i = 0 To UBound($aCamps) - 1
		;Just In Case Someone Mentioned Wrong Troop Name Select Default Barbarian Troop
		$aCamps[$i] = __ArraySearch($g_asBBTroopShortNames, $aCamps[$i]) < 0 ? ("Barb") : __ArraySearch($g_asBBTroopShortNames, $aCamps[$i])
	Next
	;After populate with the new priority position let's sort ascending column 1
	_ArraySort($aCamps, 0, 0, 0, 1)
	;Just Assign The Short Names According to new priority positions
	For $i = 0 To UBound($aCamps) - 1
		$aCamps[$i] = $g_asAttackBarBB2[$aCamps[$i]]
	Next

	; [0] = Troops Name , [1] - Priority position
	Local $aNewAvailableTroops[UBound($aAvailableTroops)][2]
	
		For $i = 0 To UBound($aAvailableTroops) -1
			$aNewAvailableTroops[$i][0] = $aAvailableTroops[$i][0]
			
			$aNewAvailableTroops[$i][1] = 0
			
			For $i2 = 0 To UBound($g_asBBTroopShortNames) -1
				If (StringInStr($aAvailableTroops[$i][0], $g_asBBTroopShortNames[$i2]) > 0) Then
					$aNewAvailableTroops[$i][1] = $i2
					ContinueLoop 2
				EndIf
			Next
			
		Next
	If $g_bDebugSetlog Then SetLog(_ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1))

	Local $bWaschanged = False
	Local $iAvoidInfLoop = 0
	
	Local $aSwicthBtn = findMultipleQuick($g_sImgCustomArmyBB, 20, "0,695,858,722", Default, "ChangeTroops", Default, 30, False)
	
	If not IsArray($aSwicthBtn) Or Not (UBound($aSwicthBtn) >= 6) Then ; Instrumental click.
		Local $aSwicthBtn[6][3] = [[-1, 112, 708], [-1, 180, 708], [-1, 253, 708], [-1, 327, 708], [-1, 398, 708], [-1, 471, 708]]
	EndIf
	
	_ArraySort($aSwicthBtn, 0, 0, 0, 1)

	For $i = 0 To $iCampsQuantities - 1
		If $iAvoidInfLoop > UBound($aCamps) Then ExitLoop
		If Not $g_bRunState Then Return
		If Not (StringInStr($aNewAvailableTroops[$i][0], $aCamps[$i]) > 0) Then
			$bWaschanged = True
			Setlog("Incorrect troop On Camp " & $i + 1 & " - " & $aNewAvailableTroops[$i][0] & " -> " & $aCamps[$i])	
			Setlog("Click Switch Button " & $i, $COLOR_INFO)
			Click($aSwicthBtn[$i][1] + Random(2, 10, 1), $aSwicthBtn[$i][2] + Random(2, 10, 1))
			If Not $g_bRunState Then Return
			If RandomSleep(500) Then Return

			If Not _WaitForCheckImg($g_sImgCustomArmyBB, "0,681,860,728", "ChangeTDis") Then
				Setlog("_WaitForCheckImg Error at Camps!", $COLOR_ERROR)
				$i = $i - 1
				$iAvoidInfLoop += 1
				If Not $g_bRunState Then ExitLoop
				ContinueLoop
			EndIf

			; Result [X][0] = NAME , [x][1] = Xaxis , [x][2] = Yaxis , [x][3] = Level
			Local $aAttackBar = _ImageSearchXML($g_sImgDirBBTroops, 20, "0,523,861,615", True, False)
			If $aAttackBar = -1 Then
;~ 				_DebugFailedImageDetection("Attackbar")
				Return False
			EndIf
			For $j = 0 To UBound($aAttackBar) - 1
				If Not $g_bRunState Then ExitLoop
				If $aAttackBar[$j][0] = $aCamps[$i] Then
					;Local $Point = [$aAttackBar[$j][1], $aAttackBar[$j][2]]
					If RandomSleep(1000) Then Return
					PureClick($aAttackBar[$j][1] + Random(1, 5, 1), $aAttackBar[$j][2] + Random(1, 5, 1), 1, 0)
					If RandomSleep(1000) Then Return
					Setlog("Selected " & FullNametroops($aCamps[$i]) & " X:| " & $aAttackBar[$j][1] & " Y:| " & $aAttackBar[$j][2], $COLOR_SUCCESS)
					$aNewAvailableTroops[$i][0] = $aCamps[$i]
					$aNewAvailableTroops[$i][1] = __ArraySearch($g_asBBTroopShortNames, $aCamps[$i])
					; After populate with the new prio position let's sort ascending column 1
					_ArraySort($aNewAvailableTroops, 0, 0, 0, 1)
					If $g_bDebugSetlog Then Setlog("New tab is " & _ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1), $COLOR_INFO)
					; Now let's restart the for loop , is a nesty way to do but is only to tests
					$i = -1
					ExitLoop
				EndIf
			Next
		EndIf
	Next
	
	If $bWaschanged And _WaitForCheckImg($g_sImgCustomArmyBB, "0,681,860,728", "ChangeTDis", 500, 100) Then Click(Random(8, 858, 1), Random(632, 720, 1))
	
	If Not $bWaschanged Then Return

	If RandomSleep(500) Then Return

	; populate the correct array with correct Troops
    For $i = 0 To UBound($aNewAvailableTroops) - 1
        $aAvailableTroops[$i][0] = $aNewAvailableTroops[$i][0]
    Next
	
	Local $iTroopBanners = 640 ; y location of where to find troop quantities

    For $i = 0 To UBound($aAvailableTroops) - 1
        If Not $g_bRunState Then Return
        If $aAvailableTroops[$i][0] <> "" Then ;We Just Need To redo the ocr for mentioned troop only
			Local $iCount = Number(_getTroopCountSmall($aAvailableTroops[$i][1], $iTroopBanners))
			If $iCount == 0 Then $iCount = Number(_getTroopCountBig($aAvailableTroops[$i][1], $iTroopBanners-7))
			If $iCount == 0 And not String($aAvailableTroops[$i][0]) = "Machine" Then
				SetLog("Could not get count for " & $aAvailableTroops[$i][0] & " in slot " & String($aAvailableTroops[$i][3]), $COLOR_ERROR)
				ContinueLoop
				ElseIf (StringInStr($aAvailableTroops[$i][0], "Machine") > 0) Then
				$iCount = 1
			EndIf			
        EndIf
		$aAvailableTroops[$i][4] = $iCount
    Next

    For $i = 0 To UBound($aAvailableTroops) - 1
        If Not $g_bRunState Then Return
        If $aAvailableTroops[$i][0] <> "" Then SetLog("[" & $i + 1 & "] - " & $aAvailableTroops[$i][4] & "x " & FullNametroops($aAvailableTroops[$i][0]), $COLOR_SUCCESS)
    Next
EndFunc   ;==>BuilderBaseSelectCorrectScript


Func TranslateCsvTroopName($sName)
	SetDebugLog("Translating " & $sName & " From Csv", $COLOR_INFO)
	Switch ($sName)
		Case "Arch"
			Return "Archer"
		Case "Barb"
			Return "Barbarian"
		Case "BabyD"
			Return "BabyDrag"
		Case "Minion"
			Return "Minion"
		Case "Breaker"
			Return "WallBreaker"
		Case "Cannon"
			Return "CannonCart"
		Case "Drop"
			Return "DropShip"
		Case "Giant"
			Return "BoxerGiant"
		Case "Machine"
			Return "Machine"
		Case "Witch"
			Return "Witch"
		Case "Pekka"
			Return "SuperPekka"
		Case "HogG"
			Return "HogGlider"
		Case Else
			Return $sName
	EndSwitch
EndFunc
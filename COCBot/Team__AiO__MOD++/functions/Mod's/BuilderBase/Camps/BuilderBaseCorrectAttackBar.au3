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
	Local $aLines[0]
	Local $sName = "CAMP" & "|"
	For $iName = 0 To UBound($g_iCmbCampsBB) - 1
		$sName &= ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) <> "" ? ArmyCampSelectedNames($g_iCmbCampsBB[$iName]) : ("Barb")
		$sName &= "|"
		If $iName = 0 Then ContinueLoop
		Local $aFakeCsv[1] = [$sName]
		_ArrayAdd($aLines, $aFakeCsv)
	Next

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
			If $iCampsQuantities = UBound($aCamps) Then
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
		$aCamps[$i] = _ArraySearch($g_asAttackBarBB2, $aCamps[$i]) < 0 ? ("Barb") : _ArraySearch($g_asAttackBarBB2, $aCamps[$i])
	Next
	;After populate with the new priority position let's sort ascending column 1
	_ArraySort($aCamps, 0, 0, 0, 1)
	;Just Assign The Short Names According to new priority positions
	For $i = 0 To UBound($aCamps) - 1
		$aCamps[$i] = $g_asAttackBarBB2[$aCamps[$i]]
	Next

	; [0] = Troops Name , [1] - Priority position
	Local $aNewAvailableTroops[UBound($aAvailableTroops)][2]

	For $i = 0 To UBound($aAvailableTroops) - 1
		$aNewAvailableTroops[$i][0] = $aAvailableTroops[$i][0]
		$aNewAvailableTroops[$i][1] = _ArraySearch($g_asAttackBarBB2, $aAvailableTroops[$i][0])
	Next

	If $g_bDebugSetlog Then setlog(_ArrayToString($aNewAvailableTroops, "-", -1, -1, "|", -1, -1))

	Local $bWaschanged = False
	Local $iAvoidInfLoop = 0

	Local $aSwicthBtn[6] = [112, 180, 253, 327, 398, 471]

	For $i = 0 To $iCampsQuantities - 1
		If Not $g_bRunState Then Return
		If StringCompare($aNewAvailableTroops[$i][0], $aCamps[$i]) <> 0 Then
			$bWaschanged = True
			Setlog("Incorrect troop On Camp " & $i + 1 & " - " & $aNewAvailableTroops[$i][0] & " -> " & $aCamps[$i])
			Local $aPointSwitch = [$aSwicthBtn[$i], 708]
			Setlog("Click Switch Button " & $i, $COLOR_INFO)
			PureClick($aPointSwitch[0], $aPointSwitch[1], 1, 0)
			If Not $g_bRunState Then Return
			If _Sleep(500) Then Return

			If Not _WaitForCheckXML($g_sImgCustomArmyBB, "0,681,860,728", True, 10000, 100) Then
				Setlog("_WaitForCheckXML Error at Camps!", $COLOR_ERROR)
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
					If _sleep(1000) Then Return
					PureClick($aAttackBar[$j][1] + Random(1, 5, 1), $aAttackBar[$j][2] + Random(1, 5, 1), 1, 0)
					If _sleep(1000) Then Return
					Setlog("Selected " & FullNametroops($aCamps[$i]) & " X:| " & $aAttackBar[$j][1] & " Y:| " & $aAttackBar[$j][2], $COLOR_SUCCESS)
					$aNewAvailableTroops[$i][0] = $aCamps[$i]
					$aNewAvailableTroops[$i][1] = _ArraySearch($g_asAttackBarBB2, $aCamps[$i])
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
	
	If $bWaschanged And _WaitForCheckXML($g_sImgCustomArmyBB, "0,681,860,728", True, 1000, 100) Then ClickP($aPointSwitch)
	
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
				ElseIf String($aAvailableTroops[$i][0]) = "Machine" Then
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

; _ArraySearch($g_asAttackBarBB2, $aAvailableTroops[$i][0])
Func CSVtoImageName($sTroop = "Barb", $asAttackTroopList = $g_asAttackBarBB2)
	For $vT In $asAttackTroopList
		If (StringInStr($vT, $sTroop) <> 0) Then Return ($vT)
	Next
	Return $sTroop
EndFunc   ;==>CSVtoImageName

Func MachineKick($a)
	If Not IsArray($a) Then Return -1
	
	For $i = UBound($a) -1 To 0 Step -1 ; Optimized
		If StringInStr($a[$i][0], "Machine") > 0 Then
			_ArrayDelete($a, $i)
			ExitLoop
		EndIf
	Next
	Local $vReturn = (UBound($a) < 1) ? (-1) : ($a)
	$a = $vReturn
	Return $vReturn
EndFunc   ;==>MachineOut

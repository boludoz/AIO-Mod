#cs 
; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base.
; Syntax ........: SwitchBetweenBases()
; Parameters ....:
; Return values .: True: Successfully switched Bases  -  False: Failed to switch Bases
; Author ........: Fliegerfaust (05-2017), Boldina (05-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#Region - Custom - Team AIO Mod++
Func TestSwitchBetweenBases()
	If isOnBuilderBase(True) Then
		$g_bStayOnBuilderBase = False
	Else
		$g_bStayOnBuilderBase = True
	EndIf
	
	Return SwitchBetweenBases()
EndFunc

Func SwitchBetweenBases($bCheckMainScreen = True)
	Local $sSwitchFrom, $sSwitchTo, $bIsOnBuilderBase = False, $aButtonCoords
	Local $sTile, $sTileDir, $sRegionToSearch
	Local $bSwitched = False
	If Not $g_bRunState Then Return
	Static $Failed = 0
	For $i = 0 To 1

		If isOnBuilderBase(True) Then
			$sSwitchFrom = "Builder Base"
			$sSwitchTo = "Normal Village"
			$bIsOnBuilderBase = True
			$sTile = "BoatBuilderBase"
			$sTileDir = $g_sImgBoatBB
			$sRegionToSearch = GetDiamondFromRect2(173, 0, 653, 289)
			If $g_bStayOnBuilderBase = True Then Return True

		Else
			;~ #cs
			; Deconstructed boat.
			Local $sNoBoat = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Noboat\"
			If QuickMIS("BC1", $sNoBoat, 66, 432, 388, 627, True) Then
				SetLog("Builder base locked.", $COLOR_INFO)
				$g_bStayOnBuilderBase = False
				Return False
			EndIf
			;~ #ce
			$sSwitchFrom = "Normal Village"
			$sSwitchTo = "Builder Base"
			$bIsOnBuilderBase = False
			$sTile = "BoatNormalVillage"
			$sTileDir = $g_sImgBoat
			$sRegionToSearch = GetDiamondFromRect2(0, 274, 515, 644)
			If $g_bStayOnBuilderBase = False Then Return True
		EndIf
		
		 ; Stop hitting the stone like a monkey in search of money and force the zoomout!
		$g_bSkipFirstZoomout = False
		ZoomOut()

		If _Sleep(1000) Then Return
		If Not $g_bRunState Then Return
		$aButtonCoords = decodeSingleCoord(findMultiple($sTileDir, $sRegionToSearch, $sRegionToSearch, 0, 1000, 0, "objectname,objectpoints", True))
		
		; Custom fix - Team AIO Mod++
		If (UBound($aButtonCoords) = 1 Or @Error) And $sSwitchFrom = "Builder Base" Then
			ClickDrag(230, 30, 100, 130, 1000)
			If _Sleep(1000) Then Return
			
			$aButtonCoords = decodeSingleCoord(findMultiple($sTileDir, $sRegionToSearch, $sRegionToSearch, 0, 1000, 0, "objectname,objectpoints", True))
		EndIf
		

		If UBound($aButtonCoords) > 1 Then
			SetLog("[" & $i & "] Going to " & $sSwitchTo, $COLOR_INFO)
			ClickP($aButtonCoords)
			If _Sleep($DELAYSWITCHBASES1) Then Return
			Local $hTimerHandle = __TimerInit()
			$bSwitched = False
			While __TimerDiff($hTimerHandle) < 3000 And Not $bSwitched
				If _Sleep(250) Then Return
				If Not $g_bRunState Then Return
				ForceCaptureRegion()
				$bSwitched = isOnBuilderBase(True) <> $bIsOnBuilderBase
			WEnd
			If $bSwitched Then
				If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase)
				$Failed = 0
				Return True
			Else
				SetLog("Failed to go to the " & $sSwitchTo, $COLOR_ERROR)
				$Failed += 1
				If $Failed > 15 Then
					SetLog("Rebooting " & $g_sAndroidEmulator & " due to problems Switch Bases!", $COLOR_ERROR)
					; AndroidAdbResetErrors()
					If Not RebootAndroid() Then Return False
				EndIf
			EndIf
		Else
			SetLog("[" & $i & "] SwitchBetweenBases Tile: " & $sTile, $COLOR_ERROR)
			SetLog("[" & $i & "] SwitchBetweenBases isOnBuilderBase: " & isOnBuilderBase(True), $COLOR_ERROR)
			If $bIsOnBuilderBase Then
				SetLog("Cannot find the Boat on the Coast", $COLOR_ERROR)
			Else
				SetLog("Cannot find the Boat on the Coast. Maybe it is still broken or not visible", $COLOR_ERROR)
			EndIf
			$g_bSkipFirstZoomout = False
			ZoomOut()
		EndIf
	Next
	Return False
EndFunc   ;==>SwitchBetweenBases
#EndRegion - Custom - Team AIO Mod++
#ce
; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base
; Syntax ........: SwitchBetweenBases()
; Parameters ....:
; Return values .: True: Successfully switched Bases  -  False: Failed to switch Bases
; Author ........: Fliegerfaust (05-2017)
; Modified ......: GrumpyHog (08-2022)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func SwitchBetweenBases($bCheckMainScreen = True)
	Local $sSwitchFrom, $sSwitchTo, $bIsOnBuilderBase = False, $aButtonCoords, $avBoat, $avTempArray
	Local $sTile, $sTileDir, $sRegionToSearch
	Local $bSwitched = False

	If Not $g_bRunState Then Return

	For $i = 0 To 2
		If isOnBuilderBase(True) Then
			$sSwitchFrom = "Builder Base"
			$sSwitchTo = "Normal Village"
			$bIsOnBuilderBase = True
			$sTile = "BoatBuilderBase"
			$sTileDir = $g_sImgBoatBB
			$sRegionToSearch = GetDiamondFromRect2(487,44,708,242-88)
		Else
			$sSwitchFrom = "Normal Village"
			$sSwitchTo = "Builder Base"
			$bIsOnBuilderBase = False
			$sTile = "BoatNormalVillage"
			$sTileDir = $g_sImgBoat
			$sRegionToSearch = GetDiamondFromRect2(66,432-44,388,644)
		EndIf

		If _sleep(250) Then Return
		If Not $g_bRunState Then Return

		; Stop hitting the stone like a monkey in search of money and force the zoomout!
		$g_bSkipFirstZoomout = False
		ZoomOut() ; ensure boat is visible
		If Not $g_bRunState Then Return

		$avBoat = findMultiple($sTileDir, $sRegionToSearch, $sRegionToSearch, 0, 1000, 1, "objectname,objectpoints", True)

		If Not IsArray($avBoat) Or UBound($avBoat, $UBOUND_ROWS) <= 0 Then
			SetLog("Couldn't find Boat on " & $sSwitchFrom, $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("SwitchBetweenBases", False)
			Return False
		Else
			; loop thro the detected images
			For $j = 0 To UBound($avBoat, $UBOUND_ROWS) - 1
				$avTempArray = $avBoat[$j]
				SetLog("Boat Search find : " & $avTempArray[0])
				$aButtonCoords = decodeSingleCoord($avTempArray[1])

				If IsArray($aButtonCoords) And UBound($aButtonCoords, $UBOUND_ROWS) = 2 Then
					SetLog("[" & $i & "] Going to " & $sSwitchTo, $COLOR_INFO)
					ClickP($aButtonCoords)
					If _Sleep($DELAYSWITCHBASES1) Then Return

					; switch can take up to 2 Seconds, check for 3 additional Seconds...
					Local $hTimerHandle = __TimerInit()
					$bSwitched = False
					While __TimerDiff($hTimerHandle) < 3000 And Not $bSwitched
						If _Sleep(250) Then Return
						If Not $g_bRunState Then Return
						ForceCaptureRegion()
						$bSwitched = isOnBuilderBase(True) <> $bIsOnBuilderBase
					WEnd

					If $bSwitched Then
						If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase)
						Return True
					Else
						SetLog("Failed to go to the " & $sSwitchTo, $COLOR_ERROR)
					EndIf
				Else
					Setlog("[" & $i & "] SwitchBetweenBases Tile: " & $sTile, $COLOR_ERROR)
					Setlog("[" & $i & "] SwitchBetweenBases isOnBuilderBase: " & isOnBuilderBase(True), $COLOR_ERROR)
					If $bIsOnBuilderBase Then
						SetLog("Cannot find the Boat on the Coast", $COLOR_ERROR)
					Else
						SetLog("Cannot find the Boat on the Coast. Maybe it is still broken or not visible", $COLOR_ERROR)
					EndIf

					If $i >= 1 Then RestartAndroidCoC() ; Need to try to restart CoC
				EndIf
			Next
		EndIf

		If _Sleep(3000) Then Return
		If Not $g_bRunState Then Return
	Next

	Return False
EndFunc   ;==>SwitchBetweenBases
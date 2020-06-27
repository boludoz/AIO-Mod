; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base; Modified in such a way that it allows to distinguish if the boat is not present.
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
Func SwitchBetweenBases($bCheckMainScreen = True, $bGoTo = Default, $bSilent = Default)
	Local $bNoBoat = False, $bSwitch = True, $bIs = False, $vSwitch[0]
	
	For $i = 0 To 5
		
		If ($bSilent <> True) Then SetLog("Try: [" & $i & "] " & "Switch between bases.", $COLOR_ACTION)
		
		If Not $g_bRunState Then Return

		If ($bGoTo <> Default) Then
			$bIs = isOnBuilderBase(True)
			$bSwitch = (($bGoTo = "Builder Base") <> $bIs)
		EndIf
		
		For $i2 = 0 To 1
			$vSwitch = decodeSingleCoord(findImageInPlace(($i2 = 0) ? ("BoatNormalVillage") : ("BoatBuilderBase"), ($i2 = 0) ? ($g_sImgBoat) : ($g_sImgBoatBB), ($i2 = 0) ? ("66,432,388,627") : ("487,44,708,242")))
			If UBound($vSwitch) > 1 Then ExitLoop
		Next
		
		If UBound($vSwitch) <= 1 Then
			If isOnBuilderBase() <> isOnMainVillage() Then 
				ZoomOut() ; ensure boat is visible
				Else
				ClickP($aAway, 2, 0, "#0332") ;Click Away
			EndIf
			If QuickMIS("N1", @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Noboat\", 66, 432, 388, 627) <> "none" Then
				If ($bSilent <> True) Then SetLog("Apparently you don't have the boat.", $COLOR_INFO)
				$bNoBoat = True
			Else
				If Not $g_bRunState Then Return
				ContinueLoop
			EndIf
		EndIf
		
		Local $bSwitched = False
		
		If $bSwitch And Not $bNoBoat And UBound($vSwitch) > 1 Then
			Click($vSwitch[0], $vSwitch[1])
			$bSwitched = (Int($vSwitch[0]) < 388 ) ? (True) : (False)
		EndIf
		
		If $bCheckMainScreen Then
			$bIs = isOnBuilderBase(True)
			; switch can take up to 2 Seconds, check for 3 additional Seconds...
			Local $hTimerHandle = __TimerInit()
			Local $iDo = 0
			Do
				$iDo += 1
				If __TimerDiff($hTimerHandle) > 3000 Then ContinueLoop 2
				If _Sleep(100) Then Return
				
			Until (checkMainScreen(True, $bIs) Or ($iDo > 3)) ; You would not understand.
			
			; If ($iDo > 3) Then ...
			
			If ($bSilent <> True) Then SetLog(($bSwitched <> $bIs) ? ("Is switched to ? : Builder base.") : ("Is switched to ? : Normal village."), $COLOR_SUCCESS)
		EndIf
		
		Return ($bNoBoat) ? (False) : (True) ; Return false for avoid bugs in bb switch.

	Next
	
	SetLog("Fail SwitchBetweenBases 0x1", $COLOR_ERROR)
	Return False
EndFunc   ;==>SwitchBetweenBases

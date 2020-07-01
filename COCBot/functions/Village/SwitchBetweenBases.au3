; #FUNCTION# ====================================================================================================================
; Name ..........: TravelTo
; Description ...: Switches Between Normal Village and Builder Base.
; Syntax ........: TravelTo()
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
;Global $g_bRecursiveOff = , $g_hRecursiveOff = ; Never recursive again.

Func SwitchBetweenBases($bCheckMainScreen = True, $bGoTo = Default, $bSilent = Default)
Local $bIsOnBuilderBase, $bSwitched = False

	#CS
		$bGoTo = Default go to to the opposite village.
		$bGoTo Go to "Builder Base"
		$bGoTo Go to "Normal Village"
		
		SwitchBetweenBases(True, "Builder Base")
		SwitchBetweenBases(True, "Normal Village")
	#CE
	Local $iLoop = 0
	Do

		; Zoom Out first
		; ZoomOut()
		
		; Capture info - Boat ubi.
		
		;	Normal
		Local $aNVoat = decodeSingleCoord(findImageInPlace("BoatNormalVillage", $g_sImgBoat, "66,432,388,627"))
		
		;	Builder
		Local $aBBoat = decodeSingleCoord(findImageInPlace("BoatBuilderBase", $g_sImgBoatBB, "487,44,708,242"))
		
		; Capture info - Actual Village.
		
		;	Normal
		Local $bNV = isOnMainVillage(True)
		
		;	Builder
		Local $bBB = isOnBuilderBase(True)
		
		Select 
			; Travel to BB.
			Case (UBound($aNVoat) > 1)
				SetDebugLog("SwitchBetweenBases | 0 : 0")
				If ($bNV And ($bGoTo = "Normal Village")) Then Return True
				If ($bGoTo = Default) Or ($bGoTo = "Builder Base") Then
					ClickP($aNVoat)
					$bSwitched = True
					$bIsOnBuilderBase = $bBB
					$g_bStayOnBuilderBase = True		
				EndIf
			; Travel to NV.
			Case (UBound($aBBoat) > 1)
				SetDebugLog("SwitchBetweenBases | 0 : 1")
				If ($bBB And ($bGoTo = "Builder Base"))  Then Return True
				If ($bGoTo = Default) Or ($bGoTo = "Normal Village") Then 
					ClickP($aBBoat)
					$bSwitched = True
					$bIsOnBuilderBase = $bBB
					$g_bStayOnBuilderBase = False
				EndIf
			; Stay on NV.
			Case (QuickMIS("N1", @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Noboat\", 66, 432, 388, 627) <> "none")
				SetDebugLog("SwitchBetweenBases | 0 : 2")
				$g_bStayOnBuilderBase = False
				Return False
			Case Else
				SetDebugLog("SwitchBetweenBases | 0 : 3")
				checkMainScreen(True, $bBB)
				ZoomOut()
				$iLoop += 1
				$bSwitched = False
				ContinueLoop
		EndSelect

		$iLoop += 1
		
		; switch can take up to 2 Seconds, check for 3 additional Seconds...
		Local $hTimerHandle = __TimerInit()
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
			SetLog("Failed to go to the ...", $COLOR_ERROR)
		EndIf

	Until ($iLoop > 3)
		
	Return False
EndFunc   ;==>TravelTo

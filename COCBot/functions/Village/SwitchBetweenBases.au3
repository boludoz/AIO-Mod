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
Func SwitchBetweenBases($bCheckMainScreen = Default, $bGoToBB = Default, $bSilent = Default)
	If $bCheckMainScreen = Default Then $bCheckMainScreen = True
	Local $bSwitched = False, $iLoop = 0
	$g_aVillageSize = $g_aVillageSizeReset ; Deprecated dim - Team AIO Mod++

	For $iLoop = 0 To 4

		; Deconstructed boat.
		If (QuickMIS("N1", @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Noboat\", 66, 432, 388, 627) <> "none") Then
			$g_bStayOnBuilderBase = False
			Return False
		EndIf
		
		;	Builder base.
		Local $aBBoat = decodeSingleCoord(findImageInPlace("BoatBuilderBase", $g_sImgBoatBB, "487,44,708,242"))
		Local $bBB = isOnBuilderBase(True)
		
		;	Normal base.
		Local $aNVoat = decodeSingleCoord(findImageInPlace("BoatNormalVillage", $g_sImgBoat, "66,432,388,627"))
		Local $bNV = (Not $bBB) ; more stable than isOnMainVillage.
		
		Select
			Case (UBound($aNVoat) > 1)

				; Travel to BB.
				If ($bGoToBB = Default Or $bGoToBB = True) Then
					Click($aNVoat[0] + Random(0, 10, 1), $aNVoat[1] + Random(0, 10, 1))
					$g_bStayOnBuilderBase = True
				EndIf
				
				; Stay in BB.
				If ($bNV And $bGoToBB = False) Then
					$g_bStayOnBuilderBase = True
					Return True
				EndIf
				
			Case (UBound($aBBoat) > 1)
					
				; Travel to NV.
				If ($bGoToBB = Default Or $bGoToBB = False) Then
					Click($aBBoat[0] + Random(0, 10, 1), $aBBoat[1] + Random(0, 10, 1))
					$g_bStayOnBuilderBase = False
				EndIf
				
				; Stay in NV.
				If ($bBB And $bGoToBB = True) Then 
					$g_bStayOnBuilderBase = False
					Return True
				EndIf
				
			Case Else

				; Check checkMainScreen and ZoomOut.
				SetDebugLog("SwitchBetweenBases | 0 : 3")
				If $bCheckMainScreen Then checkMainScreen(True, $bBB)
				ZoomOut()
				ContinueLoop
				
		EndSelect

		; switch can take up to 2 Seconds, check for 3 additional Seconds...
		Local $bIsOnBuilderBase = $bBB
		Local $hTimerHandle = __TimerInit()
		Do 
			$bSwitched = (isOnBuilderBase(True) <> $bIsOnBuilderBase)
			If $bSwitched Then ExitLoop
			If (Not $g_bRunState) Or _Sleep(250) Then Return
		Until (__TimerDiff($hTimerHandle) > 3000 And Not $bSwitched)

		If $bSwitched Then
			If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase)
			Return True
		EndIf

	Next
	
	Return False
EndFunc   ;==>SwitchBetweenBases
#EndRegion - Custom - Team AIO Mod++

; #FUNCTION# ====================================================================================================================
; Name ..........: checkArmyCamp
; Description ...: Reads the size it the army camp, the number of troops trained, and Spells
; Syntax ........: checkArmyCamp()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: Sardo (08-2015), KnowJack(08-2015). ProMac (08-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func checkArmyCamp($bOpenArmyWindow = False, $bCloseArmyWindow = False, $bGetHeroesTime = False, $bSetLog = True)
	Local $iStopWatchLevel = StopWatchLevel()
	Local $Result = _checkArmyCamp($bOpenArmyWindow, $bCloseArmyWindow, $bGetHeroesTime, $bSetLog)
	StopWatchReturn($iStopWatchLevel)
	Return $Result
EndFunc

Func _checkArmyCamp($bOpenArmyWindow, $bCloseArmyWindow, $bGetHeroesTime, $bSetLog)
	#Region - Custom train - Team AIO Mod++
	Local $iLoop = 0
	Do
		$iLoop += 1
		If $g_bDebugFuncTime Then StopWatchStart("checkArmyCamp")
	
		If $g_bDebugSetlogTrain Then SetLog("Begin checkArmyCamp:", $COLOR_DEBUG1)
	
		If $g_bDebugFuncTime Then StopWatchStart("IsTrainPage/openArmyOverview")
		If Not $bOpenArmyWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return; not open, not requested to be open - error.
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview(True, "_checkArmyCamp()") Then
				SetError(2)
				Return; not open, requested to be open - error.
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
		If $g_bDebugFuncTime Then StopWatchStopLog()
	
		If $g_bDebugFuncTime Then StopWatchStart("getArmyTroopsCapacity")
		getArmyTroopCapacity(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
		If $g_bDebugFuncTime Then StopWatchStopLog()
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response
	
		If $g_bDebugFuncTime Then StopWatchStart("getArmyTroops")
		getArmyTroops(False, False, False, $bSetLog)
		If $g_bDebugFuncTime Then StopWatchStopLog()
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response
		
		; Stick to Army page when time left - Team AIO Mod++
		If $g_iStickToTrainWindow = 0 Or ProfileSwitchAccountEnabled() And ($g_aiAttackedCountSwitch[$g_iCurAccount] <= $g_aiAttackedCountAcc[$g_iCurAccount] - 2) Then
			If $g_bDebugFuncTime Then StopWatchStart("getArmyTroopTime")
			getArmyTroopTime(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
			If $g_bDebugFuncTime Then StopWatchStopLog()
			If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response
		Else
			Local $iCount = 0, $iStickDelay = 0
			While 1
				If Not $g_bRunState Then Return
				getArmyTroopTime(False, False, True, ($iCount = 0))
				
				If $g_aiTimeTrain[0] <= 0 Then
					Local $sResultTroops = getRemainTrainTimer(495, 169)
					If StringRight($sResultTroops, 1) = "s" And StringLen($sResultTroops) < 4 Then
						$g_aiTimeTrain[0] = Number("0." & Number($sResultTroops))
						$g_aiTimeTrain[0] = Int($g_aiTimeTrain[0] * Random(1.10, 1.25, 1))
					EndIf
				EndIf
				
				If _Sleep($DELAYRESPOND) Then Return
				If $g_aiTimeTrain[0] > $g_iStickToTrainWindow Or $g_aiTimeTrain[0] <= 0 Then
					If $iLoop <> 1 Then
						ExitLoop
					Else
						ContinueLoop 2
					EndIf
				Else
					If $g_aiTimeTrain[0] < 1 Then
						$iStickDelay = Round($g_aiTimeTrain[0] * 1000)
						$g_aiTimeTrain[0] = 0
					ElseIf $g_aiTimeTrain[0] >= 2 Then
						$iStickDelay = 60000
					Else
						$iStickDelay = 30000
					EndIf
					SetLog("[" & $iCount & "] Waiting for troops to be ready.", $COLOR_INFO)
					If _Sleep($iStickDelay) Then Return
				EndIf
				$iCount += 1
				If $iCount > (10 + $g_iStickToTrainWindow) Then ExitLoop
			WEnd
		EndIf
	Until True
	#EndRegion - Custom train - Team AIO Mod++

	Local $HeroesRegenTime
	If $g_bDebugFuncTime Then StopWatchStart("getArmyHeroCount")
	getArmyHeroCount(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $bGetHeroesTime Then
		If $g_bDebugFuncTime Then StopWatchStart("getArmyHeroTime")
		$HeroesRegenTime = getArmyHeroTime("all")
		If $g_bDebugFuncTime Then StopWatchStopLog()
		If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response
	EndIf

	If $g_bDebugFuncTime Then StopWatchStart("getArmySpellCapacity")
	getArmySpellCapacity(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmySpells")
	getArmySpells(False, False, False, $bSetLog)
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmySpellTime")
	getArmySpellTime(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmySiegeMachines")
	getArmySiegeMachines(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmyCCStatus")
	getArmyCCStatus(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmyCCSpellCapacity")
	getArmyCCSpellCapacity(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If $g_bDebugFuncTime Then StopWatchStart("getArmyCCSiegeMachines")
	getArmyCCSiegeMachines(False, False, False, $bSetLog) ; Last parameter is to check the Army Window
	If $g_bDebugFuncTime Then StopWatchStopLog()
	If _Sleep($DELAYCHECKARMYCAMP6) Then Return ; 10ms improve pause button response

	If Not $g_bFullArmy Then
		If $g_bDebugFuncTime Then StopWatchStart("DeleteExcessTroops")
		If $g_bDebugFuncTime Then StopWatchStopLog()
	EndIf

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf

	If $g_bDebugSetlogTrain Then SetLog("End checkArmyCamp: canRequestCC= " & $g_bCanRequestCC & ", fullArmy= " & $g_bFullArmy, $COLOR_DEBUG)

	If $g_bDebugFuncTime Then StopWatchStopLog()
	Return $HeroesRegenTime

EndFunc   ;==>checkArmyCamp

Func IsTroopToDonateOnly($pTroopType)

	If $g_abAttackTypeEnable[$DB] Then
		Local $tempArr = $g_aaiTroopsToBeUsed[$g_aiAttackTroopSelection[$DB]]
		For $x = 0 To UBound($tempArr) - 1
			If $tempArr[$x] = $pTroopType Then
				Return False
			EndIf
		Next
	EndIf
	If $g_abAttackTypeEnable[$LB] Then
		Local $tempArr = $g_aaiTroopsToBeUsed[$g_aiAttackTroopSelection[$LB]]
		For $x = 0 To UBound($tempArr) - 1
			If $tempArr[$x] = $pTroopType Then
				Return False
			EndIf
		Next
	EndIf

	Return True

EndFunc   ;==>IsTroopToDonateOnly
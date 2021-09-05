; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseMain.au3
; Description ...: Builder Base Main Loop
; Syntax ........: runBuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood (03-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func TestBuilderBase()
	If $g_bDebugSetlog Then SetDebugLog("** TestrunBuilderBase START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	$g_bStayOnBuilderBase = True
	BuilderBase(False)
	$g_bStayOnBuilderBase = False
	$g_bRunState = $Status
	If $g_bDebugSetlog Then SetDebugLog("** TestrunBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestrunBuilderBase

Func BuilderBase($bTestRun = False)
	Local $bReturn = 0
	
	ClickAway(False, True, 3)
	If Not $g_bChkBuilderAttack And Not $g_bChkCollectBuilderBase And Not $g_bChkStartClockTowerBoost And Not $g_iChkBBSuggestedUpgrades And Not $g_bChkCleanBBYard And Not $g_bChkUpgradeMachine Then
		If $g_bOnlyBuilderBase Then
			SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
			SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)
			If ProfileSwitchAccountEnabled() Then ; (:
				Return
			EndIf
			
			$g_bRunState = False
			btnStop()
		EndIf
		Return
	EndIf
	
	ZoomOut()
	
	$g_bRestart = False
	$g_bStayOnBuilderBase = True
	
	If $g_bIsCaravanOn = "True" Or $g_bIsCaravanOn = "Undefined" Then
		GoToClanGames()
	EndIf
	
	$bReturn = _BuilderBase($bTestRun)
	$g_bStayOnBuilderBase = False
	
	If isOnBuilderBase(True) Then
		CheckMainScreen(False, False)
	EndIf
	
	SetLog("Returned to the main village.", $COLOR_SUCCESS)
	
	Return $bReturn
EndFunc

Func _BuilderBase($bTestRun = False)
	If Not $g_bRunState Then Return
		
	; Check if is in Builder Base.
	If Not isOnBuilderBase(True) Then
		If Not SwitchBetweenBases() Then
			Return False
		EndIf
	EndIf
	
	SetLog("Builder Base Idle Starts", $COLOR_INFO)

	If _Sleep(2000) Then Return
	
	If BuilderBaseZoomOut(True, False) = False Then
		SetLog("Bad zoom builder base - BAD. (1)", $COLOR_ERROR)
		$g_bStayOnBuilderBase = False
		Return
	EndIf
	
	SetDebugLog("Zoom builder base - OK. (1)", $COLOR_SUCCESS)
	
	If Not $g_bRunState Then Return
	
	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or PlayBBOnly()) And $g_bChkOnlyFarm = False Then CollectBuilderBase()
	If Not $g_bRunState Then Return

	BuilderBaseReport()
	If Not $g_bRunState Then Return

	CleanBBYard()
	If Not $g_bRunState Then Return

	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or PlayBBOnly()) And $g_bChkOnlyFarm = False Then
		StarLaboratory()
		If Not $g_bRunState Then Return
		
		ClickAway()
		If _Sleep(1500) Then Return
	EndIf

	Local $bBoostedClock = False

	; Loops to do logic.
	Local $iAttackLoops = 1
	Local $iLoopsToDo = Random($g_iBBMinAttack, $g_iBBMaxAttack, 1)
	Local $bBonusObtained = 0, $bBonusObtainedInternal = False
	
	$bBonusObtained = BuilderBaseReportAttack()
	
	Do
		; ClickAway()
		NotifyPendingActions()
		If Not $g_bRunState Then Return

		If Not BuilderBaseZoomOut(False, False) Then
			SetLog("Bad zoom builder base. (1)", $COLOR_ERROR)
			$g_bStayOnBuilderBase = False
			Return
		EndIf
		
		If Not $g_bRunState Then Return

		If checkObstacles(True) Then
			SetLog("Window clean required, but no problem!", $COLOR_INFO)
		EndIf
		
		If Not $g_bRunState Then Return

		SetDebugLog("BuilderBaseAttack|$g_bChkBuilderAttack" & $g_bChkBuilderAttack)
		SetDebugLog("BuilderBaseAttack|$g_iAvailableAttacksBB" & $g_iAvailableAttacksBB)
		SetDebugLog("BuilderBaseAttack|$g_bChkBBStopAt3" & $g_bChkBBStopAt3)
		SetDebugLog("BuilderBaseAttack|$g_bIsCaravanOn" & $g_bIsCaravanOn)

		; Check if Builder Base is to run
		; New logic to add speed to the attack.
		Do
			If $g_bChkBuilderAttack = False Or ($g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 = True) Then 
				Setlog("Dynamic attack loop skipped.", $COLOR_INFO)
				SetDebugLog("ChkBuilderAttack|$g_bChkBuilderAttack: " & $g_bChkBuilderAttack)
				SetDebugLog("$g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 = True: " & ($g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 = True))
				ExitLoop
			EndIf
			
			Setlog("Dynamic attack loop: " & $iAttackLoops & "/" & $iLoopsToDo, $COLOR_INFO)
			
			;  $g_bCloudsActive fast network fix.
			$g_bCloudsActive = True

			; Attack
			If BuilderBaseAttack($bTestRun) = False Then ExitLoop
			$iAttackLoops += 1
			
			;  $g_bCloudsActive fast network fix.
			$g_bCloudsActive = False
			
			If ClanGamesBB() Then 
				; xbebenk
				For $i = 0 To 4
					_Sleep(1000)
					If QuickMIS("BC1", $g_sImgGameComplete, 760, 510, 820, 550, True, $g_bDebugImageSave) Then
						SetLog("Nice, Game Completed", $COLOR_INFO)
						GoToClanGames()
					Endif
				Next
			EndIf
			
			; Improved logic, as long as the bot can be farmed it will continue doing the external while, otherwise it will continue attacking to fulfill the user's request more fast.	
			checkObstacles(True)
			
			$bBonusObtained = BuilderBaseReportAttack()
			If $bBonusObtainedInternal = False And $bBonusObtained = True Then
				If $g_iAvailableAttacksBB = 0 Then
					SetLog("Bonus obtained: we can continue attacking without improving things.", $COLOR_SUCCESS)
					$bBonusObtainedInternal = True
					ExitLoop
				EndIf
			EndIf

		Until ($iAttackLoops >= $iLoopsToDo) Or ($g_bChkBBStopAt3 = True And $g_iAvailableAttacksBB = 0)

		If Not $g_bRunState Then Return

		; If Not BuilderBaseZoomOut() Then
			; SetLog("Bad zoom builder base. (2)", $COLOR_ERROR)
			; $g_bStayOnBuilderBase = False
			; Return
		; EndIf
		
		If Not $g_bRunState Then Return

		WallsUpgradeBB()
		
		If checkObstacles(True) Then
			SetLog("Window clean required, but no problem!", $COLOR_INFO)
			ExitLoop
		EndIf

		If Not $g_bRunState Then Return

		SetDebugLog("$g_iCmbBoostBarracks: " & $g_iCmbBoostBarracks)
		SetDebugLog("$g_bFirstStart: " & $g_bFirstStart)
		SetDebugLog("PlayBBOnly: " & PlayBBOnly())
		SetDebugLog("$g_bChkOnlyFarm: " & $g_bChkOnlyFarm)
		SetDebugLog("$g_iAvailableAttacksBB: " & $g_iAvailableAttacksBB)
		
		If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or PlayBBOnly()) And $g_bChkOnlyFarm = False And $g_iAvailableAttacksBB = 0 Then
			; If Not BuilderBaseZoomOut() Then Return
			MainSuggestedUpgradeCode()
		EndIf
		
		If Not $bBoostedClock Then 
			$bBoostedClock = StartClockTowerBoost()
		EndIf
		
		CleanBBYard()		
		If Not $g_bRunState Then Return
		
		If Not $bBoostedClock Then ExitLoop
		
		If $bBoostedClock Then
			If $g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 Then ExitLoop
		EndIf
		
		If Not $g_bRunState Then Return
		BuilderBaseReport()
		
		If Not $g_bChkBuilderAttack Then ExitLoop

	Until ($iAttackLoops >= $iLoopsToDo)
	
	If _Sleep($DELAYRUNBOT3) Then Return
	SetLog("Builder base idle ends", $COLOR_INFO)
	
	If ProfileSwitchAccountEnabled() Then Return
	
	If PlayBBOnly() Then 
		If _Sleep($DELAYRUNBOT1 * 15) Then Return
	EndIf
EndFunc   ;==>runBuilderBase

Func GoToClanGames()
	SetDebugLog("GoToClanGames|$g_bChkClanGamesEnabled: " & $g_bChkClanGamesEnabled)
	SetDebugLog("GoToClanGames|ClanGamesBB(): " & ClanGamesBB())
	SetDebugLog("GoToClanGames|$g_bIsCaravanOn: " & $g_bIsCaravanOn)
	Local $bIsToByPass = False
	If $g_bIsCaravanOn = "True" Or $g_bIsCaravanOn = "Undefined" Then $bIsToByPass = True
	If Not $g_bChkClanGamesEnabled Or Not ClanGamesBB() Then Return
	If ($g_bIsSearchLimit Or $g_bRestart Or $g_bIsClientSyncError) Then Return
	If $g_iAvailableAttacksBB > 0 Or Not $g_bChkBBStopAt3 Or $bIsToByPass Then
		If isOnBuilderBase(True) Then
			$g_bStayOnBuilderBase = False
			SwitchBetweenBases()
		EndIf
		_ClanGames()
		If Not isOnBuilderBase(True) Then
			$g_bStayOnBuilderBase = True
			SwitchBetweenBases()
		EndIf
	EndIf
EndFunc   ;==>GoToClanGames

Func PlayBBOnly()
	Local $b = ($g_iCommandStop = 8) ? (True) : (False)
	If $g_bOnlyBuilderBase = True Or $b = True Then Return True
	Return False
EndFunc   ;==>PlayBBOnly

Func ClanGamesBB()
	Return (($g_bChkClanGamesBBBattle Or $g_bChkClanGamesBBDestruction Or $g_bChkClanGamesSpell) And not $g_bChkClanGamesPurge)
EndFunc   ;==>ClanGamesBB

Func BuilderBaseReportAttack($bSetLog = True)
    If $g_bRestart = True Then Return False

    If $g_bChkBuilderAttack = True Then

        ; Get Trophies for drop.
        $g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
        If $bSetLog = True Then Setlog("- Builder base trophies report: " & $g_aiCurrentLootBB[$eLootTrophyBB], $COLOR_INFO)

        $g_iAvailableAttacksBB = UBound(QuickMIS("CX", $g_sImgBBLootAvail, 20, 625, 110, 650, True))

		If $bSetLog = True Then Setlog("- Builder base: You have " & $g_iAvailableAttacksBB & " available attack(s).", $COLOR_SUCCESS)

		If $g_iAvailableAttacksBB > 0 Then
			Return True
        EndIf
	
    Else
		If $bSetLog = True Then SetLog("- Builder base: Attack disabled", $COLOR_INFO)
	EndIf

	Return False

EndFunc   ;==>BuilderBaseReportAttack
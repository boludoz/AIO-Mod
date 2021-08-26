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
	$g_bRestart = False
	$g_bStayOnBuilderBase = True
	BuilderBase(False)
	$g_bStayOnBuilderBase = False
	$g_bRunState = $Status
	If $g_bDebugSetlog Then SetDebugLog("** TestrunBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestrunBuilderBase

Func BuilderBase($bTestRun = False)
	If Not $g_bRunState Then Return
	
	ClickAway(False, True, 3) ;ClickP($aAway, 3, 400, "#0000")
	If Not $g_bChkBuilderAttack And Not $g_bChkCollectBuilderBase And Not $g_bChkStartClockTowerBoost And Not $g_iChkBBSuggestedUpgrades And Not $g_bChkCleanBBYard And Not $g_bChkUpgradeMachine Then
		If $g_bOnlyBuilderBase Then
			SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
			SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)
			$g_bRunState = False
			btnStop()
		EndIf
		Return
	EndIf

	If $g_bIsCaravanOn = "True" Or $g_bIsCaravanOn = "Undefined" Then GoToClanGames()
	
	$g_bStayOnBuilderBase = True

	; Check if is in Builder Base.
	If Not SwitchBetweenBases() Then
		$g_bStayOnBuilderBase = False
		Return False
	EndIf

	SetLog("Builder Base Idle Starts", $COLOR_INFO)

	If _Sleep(2000) Then Return
	
	If BuilderBaseZoomOut(False, True) = False Then
		SetLog("Bad zoom builder base - BAD. (1)", $COLOR_ERROR)
		$g_bStayOnBuilderBase = False
		Return
	Else
		SetDebugLog("Bad zoom builder base - OK. (1)", $COLOR_SUCCESS)
	EndIf
	
	If $g_bRestart = True Or Not $g_bRunState Then
		SetDebugLog("Return BB from restart", $COLOR_ERROR)
		Return
	EndIf
	
	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or $g_bOnlyBuilderBase Or PlayBBOnlyCmdMode()) And $g_bChkOnlyFarm = False Then CollectBuilderBase()
	If $g_bRestart = True Or Not $g_bRunState Then
		SetDebugLog("Return BB from restart", $COLOR_ERROR)
		Return
	EndIf

	BuilderBaseReport()
	If $g_bRestart = True Or Not $g_bRunState Then
		SetDebugLog("Return BB from restart", $COLOR_ERROR)
		Return
	EndIf

	CleanBBYard()
	If $g_bRestart = True Or Not $g_bRunState Then
		SetDebugLog("Return BB from restart", $COLOR_ERROR)
		Return
	EndIf

	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or $g_bOnlyBuilderBase Or PlayBBOnlyCmdMode()) And $g_bChkOnlyFarm = False Then StarLaboratory()
	If $g_bRestart = True Or Not $g_bRunState Then
		SetDebugLog("Return BB from restart", $COLOR_ERROR)
		Return
	EndIf

	Local $bBoostedClock = False

	; Loops to do logic.
	Local $iAttackLoops = 1
	Local $iLoopsToDo = Random($g_iBBMinAttack, $g_iBBMaxAttack, 1)
	Local $bBonusObtained = BuilderBaseReportAttack(), $bBonusObtainedInternal = False

	Do
		; ClickAway()
		NotifyPendingActions()
		If $g_bRestart = True Or Not $g_bRunState Then
			SetDebugLog("Return BB from restart", $COLOR_ERROR)
			Return
		EndIf
		If Not BuilderBaseZoomOut(False, False) Then
			SetLog("Bad zoom builder base. (2)", $COLOR_ERROR)
			$g_bStayOnBuilderBase = False
			Return
		EndIf
		If $g_bRestart = True Or Not $g_bRunState Then
			SetDebugLog("Return BB from restart", $COLOR_ERROR)
			Return
		EndIf

		If checkObstacles(True) Then
			SetLog("Window clean required, but no problem!", $COLOR_INFO)
			If $g_bRestart = True Or Not $g_bRunState Then
				SetDebugLog("Return BB from restart", $COLOR_ERROR)
				Return
			EndIf
			; ExitLoop
		EndIf

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

			; Improved logic, as long as the bot can be farmed it will continue doing the external while, otherwise it will continue attacking to fulfill the user's request more fast.
			BuilderBaseReportAttack()
			
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
		If $g_bRestart = True Then Return

		If Not BuilderBaseZoomOut() Then
			SetLog("Bad zoom builder base. (2)", $COLOR_ERROR)
			$g_bStayOnBuilderBase = False
			Return
		EndIf
		If Not $g_bRunState Then Return
		If $g_bRestart = True Then Return
		WallsUpgradeBB()
		If checkObstacles(True) Then
			SetLog("Window clean required, but no problem!", $COLOR_INFO)
			ExitLoop
		EndIf

		If Not $g_bRunState Then Return
		If $g_bRestart = True Then Return
		SetDebugLog("$g_iCmbBoostBarracks: " & $g_iCmbBoostBarracks)
		SetDebugLog("$g_bFirstStart: " & $g_bFirstStart)
		SetDebugLog("$g_bOnlyBuilderBase: " & $g_bOnlyBuilderBase)
		SetDebugLog("PlayBBOnlyCmdMode: " & PlayBBOnlyCmdMode())
		SetDebugLog("$g_bChkOnlyFarm: " & $g_bChkOnlyFarm)
		SetDebugLog("$g_iAvailableAttacksBB: " & $g_iAvailableAttacksBB)
		If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart Or $g_bOnlyBuilderBase Or PlayBBOnlyCmdMode()) And $g_bChkOnlyFarm = False And $g_iAvailableAttacksBB = 0 Then
			MainSuggestedUpgradeCode()
			If Not BuilderBaseZoomOut() Then Return
		EndIf
		If Not $bBoostedClock Then $bBoostedClock = StartClockTowerBoost()
		If $g_bRestart = True Then Return
		CleanBBYard()
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return
		If Not $bBoostedClock Then ExitLoop
		If $bBoostedClock Then
			If $g_bRestart = True Then Return
			If $g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 Then ExitLoop
		EndIf
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return
		BuilderBaseReport()
		
		If Not $g_bChkBuilderAttack Then ExitLoop

	Until ($iAttackLoops >= $iLoopsToDo)

	If Not $g_bOnlyBuilderBase And Not PlayBBOnlyCmdMode() Then
		If isOnBuilderBase(True, True) Then
			$g_bStayOnBuilderBase = False
			SwitchBetweenBases()
		EndIf
	EndIf
	If _Sleep($DELAYRUNBOT3) Then Return
	SetLog("Builder Base Idle Ends", $COLOR_INFO)
	If ProfileSwitchAccountEnabled() Then Return
	If $g_bOnlyBuilderBase Or PlayBBOnlyCmdMode() Then _Sleep($DELAYRUNBOT1 * 15)
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
		If isOnBuilderBase(True, True) Then
			$g_bStayOnBuilderBase = False
			SwitchBetweenBases()
		EndIf
		_ClanGames()
		If Not isOnBuilderBase(True, True) Then
			$g_bStayOnBuilderBase = True
			SwitchBetweenBases()
		EndIf
	EndIf
EndFunc   ;==>GoToClanGames

Func PlayBBOnlyCmdMode()
	Return $g_iCommandStop = 8 ? True : False
EndFunc   ;==>PlayBBOnlyCmdMode

Func ClanGamesBB()
	Return (($g_bChkClanGamesBBBattle Or $g_bChkClanGamesBBDestruction Or $g_bChkClanGamesSpell) And not $g_bChkClanGamesPurge)
EndFunc   ;==>ClanGamesBB

Func BuilderBaseReportAttack($bSetLog = True)
    If $g_bRestart = True Then Return False

    If $g_bChkBuilderAttack = True Then

        ; Get Trophies for drop.
        $g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
        If $bSetLog = True Then Setlog("- Builder base trophies report: " & $g_aiCurrentLootBB[$eLootTrophyBB], $COLOR_INFO)

        Local $sResult = QuickMIS("CX", $g_sImgBBLootAvail, 20, 625, 110, 650, True)
        $g_iAvailableAttacksBB = UBound($sResult)

		If $bSetLog = True Then Setlog("- Builder base: You have " & $g_iAvailableAttacksBB & " available attack(s).", $COLOR_SUCCESS)

		If $g_iAvailableAttacksBB > 0 Then
			Return True
        EndIf
	
    Else
		If $bSetLog = True Then SetLog("- Builder base: Attack disabled", $COLOR_INFO)
	EndIf

	Return False

EndFunc   ;==>BuilderBaseReportAttack
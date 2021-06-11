; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseMain.au3
; Description ...: Builder Base Main Loop
; Syntax ........: BuilderBase()
; Parameters ....:
; Return values .: None
; Author ........: Chilly-Chil (Maybe?) - Extract of MyBot, Team AIO Mod++
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BuilderBase($bTestRun = False)
	If Not $g_bChkBuilderAttack And Not $g_bChkCollectBuilderBase And Not $g_bChkStartClockTowerBoost And Not $g_iChkBBSuggestedUpgrades And Not $g_bChkCleanBBYard And Not $g_bChkUpgradeMachine Then
		If $g_bOnlyBuilderBase Then
			SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
			SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)
			$g_bRunState = False     ;Stop The Bot
			btnStop()
		EndIf
		If $g_bDebugSetlog = True Then SetDebugLog("Builder Base options not enable, Skipping Builder Base routines!", $COLOR_DEBUG)
		Return False
	EndIf

	; switch to builderbase and check it is builderbase
	If SwitchBetweenBases(True, True) And isOnBuilderBase(True, True) Then

		$g_bStayOnBuilderBase = True

		CollectBuilderBase()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		; Check if Builder Base is to run
		If BuilderBaseReportAttack(False) = True Then

			; New logic to add speed to the attack.
			For $i = 1 To Random($g_iBBMinAttack, $g_iBBMaxAttack, 1)
				
				;  $g_bCloudsActive fast network fix.
				$g_bCloudsActive = True
	
				; Attack
				BuilderBaseAttack($bTestRun)
				
				;  $g_bCloudsActive fast network fix.
				$g_bCloudsActive = False
	
				If $g_bRestart = True Then Return
				If _Sleep($DELAYRUNBOT3) Then Return
				If checkObstacles(True) Then Return
				
				; Builder base Report and get out of the useless loop.
				If BuilderBaseReportAttack() = False Then 
					ExitLoop
				EndIf
				
			Next
			
		EndIf 
		
		ZoomOut()
		
		BuilderBaseReport(False, False)
		If $g_bRestart = True Then Return
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		StarLaboratory()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return
		BuilderBaseReport(False, False)
		MainSuggestedUpgradeCode()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		BuilderBaseReport(False, False)
		StartClockTowerBoost()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		BuilderBaseReport(False, False)
		CleanBBYard()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		BuilderBaseReport(False, False)
		BattleMachineUpgrade()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return
		
		BuilderBaseReport(False, False)
		WallsUpgradeBB()
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return
		
		BuilderBaseReport(False, False)
		RestAttacksInBB(False)
		If _Sleep($DELAYRUNBOT3) Then Return
		If checkObstacles(True) Then Return

		If Not $g_bRunState Then Return
	
		If $g_bOnlyBuilderBase Then 
			If _Sleep($DELAYRUNBOT1) Then Return
		Else
			If isOnBuilderBase(True, True) Then SwitchBetweenBases(True, False)
		EndIf

		If ProfileSwitchAccountEnabled() Then Return
	EndIf

EndFunc

Func BuilderBaseReportAttack($bSetLog = True)
	If $g_bRestart = True Then Return False

	If $g_bChkBuilderAttack = True Then
	
		; Get Trophies for drop.
		$g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
		If $bSetLog = True Then Setlog("Builder base trophies report: " & $g_aiCurrentLootBB[$eLootTrophyBB], $COLOR_INFO)
		
		; $g_bChkBBStopAt3
		If $g_bChkBBStopAt3 = True Then
			$g_iAvailableAttacksBB = UBound(findMultipleQuick($g_sImgBBLootAvail, 3, "25, 626, 97, 640"))
			If Not ($g_iAvailableAttacksBB > 0 And not @error) Then
				If $bSetLog = True Then Setlog("- Builder base: You have " & $g_iAvailableAttacksBB & " available attack(s). I will stop attacking.", $COLOR_SUCCESS)
				Return False
			EndIf
		EndIf

	Else
		If $bSetLog = True Then SetLog("- Builder base: Attack disabled", $COLOR_INFO)
		Return False
	EndIf
	
	Return True
EndFunc   ;==>RestAttacksInBB

Func TestBuilderBase()
	Setlog("** TestBuilderBaseAttackBB START**", $COLOR_DEBUG)
	Local $bStatus = $g_bRunState
	$g_bRunState = True
	
	Local $bChkCollectBuilderBase = $g_bChkCollectBuilderBase
	Local $bChkStartClockTowerBoost = $g_bChkStartClockTowerBoost
	Local $bChkCTBoostBlderBz = $g_bChkCTBoostBlderBz
	Local $bChkCleanBBYard = $g_bChkCleanBBYard
	Local $bChkEnableBBAttack = $g_bChkEnableBBAttack

	$g_bChkCollectBuilderBase = True
	$g_bChkStartClockTowerBoost = True
	$g_bChkCTBoostBlderBz = True
	$g_bChkCleanBBYard = True
	$g_bChkEnableBBAttack = True

	BuilderBase()

	If _Sleep($DELAYRUNBOT3) Then Return

	$g_bChkCollectBuilderBase = $bChkCollectBuilderBase
	$g_bChkStartClockTowerBoost = $bChkStartClockTowerBoost
	$g_bChkCTBoostBlderBz = $bChkCTBoostBlderBz
	$g_bChkCleanBBYard = $bChkCleanBBYard
	$g_bChkEnableBBAttack = $bChkEnableBBAttack
	
	$g_bRunState = $bStatus

	Setlog("** TestBuilderBaseAttackBB END**", $COLOR_DEBUG)
EndFunc

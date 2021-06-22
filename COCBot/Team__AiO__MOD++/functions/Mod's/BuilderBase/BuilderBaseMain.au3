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

	If Not $g_bRunState Then Return

	ClickAway() ; ClickP($aAway, 3, 400, "#0000") ;Click Away

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

	; Check if is in Builder Base.
	If Not SwitchBetweenBases(True, True) Then
		$g_bStayOnBuilderBase = False
		Return False
	EndIf

	SetLog("Builder loop starts.", $COLOR_INFO)
	If randomSleep(1000) Then Return
	If $g_bRestart Or (Not $g_bRunState) Then Return

	; Collect resources
	CollectBuilderBase()
	If $g_bRestart Or (Not $g_bRunState) Then Return

	; Builder base Report - Get The number of available attacks
	If $g_bRestart Or (Not $g_bRunState) Then Return
	BuilderBaseReport()
	BuilderBaseReportAttack(False)

	; Logic here
	Local $aRndFuncList = ['ClockTower', 'AttackBB']
	_ArrayShuffle($aRndFuncList)
	For $iIndex In $aRndFuncList
		; Check if is in Builder Base.
		If Not SwitchBetweenBases(True, True) Then
			$g_bStayOnBuilderBase = False
			Return False
		EndIf
		RunBBFuncs($iIndex)
		If $g_bRestart Or (Not $g_bRunState) Then Return
	Next
	; ----------

	; Check obstacles
	If checkObstacles(True) Then SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)

	; Logic here
	Local $aRndFuncList = ['ElixirUpdate', 'GoldUpdate']
	_ArrayShuffle($aRndFuncList)
	For $iIndex In $aRndFuncList
		; Check if is in Builder Base.
		If checkObstacles(True) Then SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
		RunBBFuncs($iIndex)
		If $g_bRestart Or (Not $g_bRunState) Then Return
	Next
	; ----------

	SetLog("Builder Base Idle Ends", $COLOR_INFO)

	; switch back to normal village
	If Not $g_bOnlyBuilderBase Then
		SwitchBetweenBases(True, False)
	EndIf

	If Not $g_bRunState Then Return

	If _Sleep($DELAYRUNBOT1 * 15) Then Return ;Add 15 Sec Delay Before Starting Again In BB Only

	If ProfileSwitchAccountEnabled() Then Return

EndFunc   ;==>runBuilderBase

Func RunBBFuncs($sBBFunc, $bTestRun = False)

	; Silent report.
	BuilderBaseReport(False, False)

	; Zoomout
	If $g_iFreeBuilderCountBB <> 0 Then Zoomout()

	Switch $sBBFunc
		Case "ClockTower"

			; Zoomout
			Zoomout()

			; Clock Tower Boost
			StartClockTowerBoost()

			; Get Benfit of Boost and clean all yard
			CleanBBYard()

		Case "AttackBB"

			; Check if Builder Base is to run
			If Not $g_bChkBuilderAttack Then Return

			; New logic to add speed to the attack.
			For $i = 1 To Random($g_iBBMinAttack, $g_iBBMaxAttack, 1)

				; Builder base Report and get out of the useless loop.
				If Not BuilderBaseReportAttack() Then Return

				;  $g_bCloudsActive fast network fix.
				$g_bCloudsActive = True

				; Attack
				BuilderBaseAttack($bTestRun)

				;  $g_bCloudsActive fast network fix.
				$g_bCloudsActive = False

			Next

		Case "ElixirUpdate"

			; ELIXIR -----------
			; It tends to be a little better, upgrade the troops first.
			StarLaboratory()

			; It will not be necessary if there are no constructors.
			If $g_iFreeBuilderCountBB = 0 Then Return

			; Zoomout
			Zoomout()

			; Upgrade Machine
			BattleMachineUpgrade()
			; ------------------

		Case "GoldUpdate"

			;It will not be necessary if there are no constructors.
			If $g_iFreeBuilderCountBB = 0 Then Return

			; GOLD -----------
			; Upgrade builds.
			MainSuggestedUpgradeCode()

			; The level of the walls does not matter so much.
			WallsUpgradeBB()
			; ------------------

	EndSwitch
EndFunc   ;==>RunBBFuncs

Func BuilderBaseReportAttack($bSetLog = True)
    If $g_bRestart = True Then Return False

    If $g_bChkBuilderAttack = True Then

        ; Get Trophies for drop.
        $g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
        If $bSetLog = True Then Setlog("Builder base trophies report: " & $g_aiCurrentLootBB[$eLootTrophyBB], $COLOR_INFO)

        ; $g_bChkBBStopAt3
        If $g_bChkBBStopAt3 = True Then
            Local $sResult = QuickMIS("CX", $g_sImgBBLootAvail, 20, 625, 110, 650, True)
            $g_iAvailableAttacksBB = UBound($sResult)

			If $bSetLog = True Then Setlog("- Builder base: You have " & $g_iAvailableAttacksBB & " available attack(s).", $COLOR_SUCCESS)

			If Not ($g_iAvailableAttacksBB > 0) Then
                Return False
            EndIf
        EndIf
    Else
		If $bSetLog = True Then SetLog("- Builder base: Attack disabled", $COLOR_INFO)
		Return False
	EndIf

    Return True

EndFunc   ;==>BuilderBaseReportAttack
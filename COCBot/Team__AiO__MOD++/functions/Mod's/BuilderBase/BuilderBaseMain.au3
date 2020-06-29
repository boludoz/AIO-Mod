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

Func TestrunBuilderBase()
	SetDebugLog("** TestrunBuilderBase START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	runBuilderBase(False)
	$g_bStayOnBuilderBase = False
	$g_bRunState = $Status
	SetDebugLog("** TestrunBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestrunBuilderBase

Func runBuilderBase($bTestRun = False)

	If Not $g_bRunState Then Return

	ClickP($aAway, 3, 400, "#0000") ;Click Away

	If Not $g_bChkBuilderAttack And Not $g_bChkCollectBuilderBase And Not $g_bChkStartClockTowerBoost And Not $g_iChkBBSuggestedUpgrades And Not $g_bChkCleanBBYard Then
		If $g_bChkPlayBBOnly Then
				SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
				SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)
				$g_bRunState = False ;Stop The Bot
				btnStop()
			EndIf
		If $g_bDebugSetlog = True Then SetDebugLog("Builder Base options not enable, Skipping Builder Base routines!", $COLOR_DEBUG)
		Return False
	EndIf

	; Check IF is Necessary run the Builder Base IDLE loop
	$g_bStayOnBuilderBase = True

	If not SwitchBetweenBases(True, "Builder Base") Then Return False

	SetLog("Builder loop starts.", $COLOR_INFO)
	If randomSleep(1000) Then Return
	If $g_bRestart Or (Not $g_bRunState) Then Return

	; Collect resources
	CollectBuilderBase()
	If $g_bRestart Or (Not $g_bRunState) Then Return

	; Builder base Report - Get The number of available attacks
	If $g_bRestart Or (Not $g_bRunState) Then Return
	BuilderBaseReport()
	RestAttacksInBB()

	; Logic here
		Local $aRndFuncList = ['ClockTower', 'AttackBB']
		_ArrayShuffle($aRndFuncList)
		For $iIndex In $aRndFuncList
			RunBBFuncs($iIndex)
			If $g_bRestart Or (Not $g_bRunState) Then Return
		Next
	; ----------

	; Check obstacles
	If checkObstacles(True) Then SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)

	; It will not be necessary if there are no constructors.
	BuilderBaseReport()

	; Logic here
		Local $aRndFuncList = ['ElixirUpdate', 'GoldUpdate']
		_ArrayShuffle($aRndFuncList)
		For $iIndex In $aRndFuncList
			RunBBFuncs($iIndex)
			If $g_bRestart Or (Not $g_bRunState) Then Return
		Next
	; ----------

	; switch back to normal village
	If Not $g_bChkPlayBBOnly Then SwitchBetweenBases(True, "Normal Village")

	If Not $g_bRunState Then Return

	If _Sleep($DELAYRUNBOT1 * 15) Then Return ;Add 15 Sec Delay Before Starting Again In BB Only

	SetLog("Builder Base Idle Ends", $COLOR_INFO)

	If ProfileSwitchAccountEnabled() Then Return

EndFunc   ;==>runBuilderBase

Func RunBBFuncs($sBBFunc, $bTestRun = False)

	; Zoomout
	If $g_iFreeBuilderCountBB <> 0 Then BuilderBaseZoomOut()

	Switch $sBBFunc
		Case "ClockTower"
			;It will not be necessary if there are no constructors.
			If $g_iFreeBuilderCountBB = 0 Then Return

			; Zoomout
			BuilderBaseZoomOut()

			; Clock Tower Boost
			StartClockTowerBoost()

			; Get Benfit of Boost and clean all yard
			CleanBBYard()

		Case "AttackBB"
			; New logic to add speed to the attack.
			For $i = 0 To Random(3,5,1)
				; Builder base Report
				BuilderBaseReport()
				RestAttacksInBB()

				; Check obstacles
				If checkObstacles(True) Then
					SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
					ExitLoop
				EndIf

				; Attack
				If RestAttacksInBB() = True Then BuilderBaseAttack($bTestRun)
				RestAttacksInBB()

				; Get out of the useless loop.
				If ($g_iAvailableAttacksBB = 0) Then ExitLoop
			Next

		Case "ElixirUpdate"
			; ELIXIR -----------
			; It tends to be a little better, upgrade the troops first.
			StarLaboratory()

			; It will not be necessary if there are no constructors.
			If $g_iFreeBuilderCountBB = 0 Then Return

			; Zoomout
			BuilderBaseZoomOut()

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
EndFunc

Func RestAttacksInBB()
	$g_iAvailableAttacksBB = Ubound(findMultipleQuick($g_sImgAvailableAttacks, 0, "25, 626, 97, 640", Default, Default, False, 0))
	If $g_iAvailableAttacksBB <> 0 and $g_bChkBBStopAt3 Then
		Setlog("You have " & $g_iAvailableAttacksBB & " available attack(s). I will stop attacking when there isn't.", $COLOR_SUCCESS)
		Return True
	ElseIf $g_bChkBBStopAt3 <> True Then
		Setlog("You have " & $g_iAvailableAttacksBB & " available attack(s).", $COLOR_INFO)
		Return True
	EndIf
	Return False
EndFunc   ;==>RestAttacksInBB

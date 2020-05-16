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
	$g_bRunState = $Status
	SetDebugLog("** TestrunBuilderBase END**", $COLOR_DEBUG)
EndFunc   ;==>TestrunBuilderBase

Func runBuilderBase($bTestRun = False)

	If Not $g_bRunState Then Return

	ClickP($aAway, 3, 400, "#0000") ;Click Away

	; Check IF is Necessary run the Builder Base IDLE loop

	If Not $g_bChkBuilderAttack And Not $g_bChkCollectBuilderBase And Not $g_bChkStartClockTowerBoost And Not $g_iChkBBSuggestedUpgrades And Not $g_bChkCleanBBYard Then
		If $g_bChkPlayBBOnly Then
				SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
				SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)
				$g_bRunState = False ;Stop The Bot
				btnStop()
			EndIf
		SetLog("Play Only Builder Base Check Is On But BB Option's(Collect,Attack etc) Unchecked", $COLOR_ERROR)
		SetLog("Please Check BB Options From Builder Base Tab", $COLOR_INFO)

		Return False

		ElseIf not SwitchBetweenBases() Then
			Return false
		Else
		$g_bStayOnBuilderBase = True
	EndIf

	 ZoomOut()

	 If Not IsOnBuilderBase(True) Then
		 SetLog("BB Don't detected.", $COLOR_ERROR)
		 $g_bStayOnBuilderBase = False
		 Return False
	  EndIf

	SetLog("Builder Base Idle Starts", $COLOR_INFO)

	If randomSleep(1000) Then Return

	If $g_bRestart Then Return
	; If $g_bRestart Then SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)

	; Collect resources
	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart) Then CollectBuilderBase()
	If $g_bRestart Then Return

	; Builder base Report - Get The number of available attacks
	BuilderBaseReport()
	RestAttacksInBB()
	If $g_bRestart Then Return

	; Upgrade Troops
	If $g_bRestart Then Return
	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart) Then BattleMachineUpgrade()
	If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart) Then StarLaboratory()
;~ 	Local $boosted = False
	; Fill/check Army Camps only If is necessary attack
	If $g_bRestart Then Return

	If $g_iAvailableAttacksBB > 0 Or Not $g_bChkBBStopAt3 Then CheckArmyBuilderBase()

	; Just a loop to benefit from Clock Tower Boost
	For $i = 0 To Random(4,10,1)
		; Zoomout
		If $g_bRestart Then Return
		If Not $g_bRunState Then Return

		ZoomOut()

		If checkObstacles(True) Then
			SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
			ExitLoop
		EndIf

		; Attack
		If $g_bRestart Then Return
		If Not $g_bRunState Then Return

		BuilderBaseAttack($bTestRun)
		If Not $g_bRunState Then Return

		; Zoomout
		If $g_bRestart Then Return
		BuilderBaseZoomOut()
		If Not $g_bRunState Then Return

		; Clock Tower Boost
		If $g_bRestart Then Return
		If Not $g_bRunState Then Return

;~ 		If Not $boosted Then $boosted = StartClockTowerBoost()
		StartClockTowerBoost()
		; Get Benfit of Boost and clean all yard
		If $g_bRestart Then Return

		CleanBBYard()
 		; BH Walls Upgrade
 		If $g_bRestart Then Return
 		If Not $g_bRunState Then Return
 		WallsUpgradeBB()

		; Auto Upgrade just when you don't need more defenses to win battles
		If $g_bRestart Then Return
		If ($g_iCmbBoostBarracks = 0 Or $g_bFirstStart) And $g_iAvailableAttacksBB = 0 Then MainSuggestedUpgradeCode()

;~ 		If Not $boosted Then ExitLoop
;~ 		If $boosted Then
			If $g_bRestart Then Return
			If $g_iAvailableAttacksBB = 0 And $g_bChkBBStopAt3 Then ExitLoop
;~ 		EndIf
		If $g_bRestart Then Return
		If Not $g_bRunState Then Return

		BuilderBaseReport()
		RestAttacksInBB()
	Next

	If Not $g_bChkPlayBBOnly Then
		; switch back to normal village
		SwitchBetweenBases()
		$g_bStayOnBuilderBase = False

		If Not $g_bRunState Then Return

	Else
		If _Sleep($DELAYRUNBOT1 * 15) Then Return ;Add 15 Sec Delay Before Starting Again In BB Only
	EndIf

	If _Sleep($DELAYRUNBOT3) Then Return

	SetLog("Builder Base Idle Ends", $COLOR_INFO)

	If ProfileSwitchAccountEnabled() Then Return

EndFunc   ;==>runBuilderBase

Func RestAttacksInBB()
	$g_iAvailableAttacksBB = Ubound(findMultipleQuick($g_sImgAvailableAttacks, 0, "25, 626, 97, 651", Default, Default, False, 10))
	If $g_iAvailableAttacksBB <> 0 and $g_bChkBBStopAt3 Then
		Setlog("You have " & $g_iAvailableAttacksBB & " available attack(s).", $COLOR_SUCCESS)
	EndIf
EndFunc   ;==>RestAttacksInBB

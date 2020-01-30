; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (01-2020)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func BuilderBaseDropTrophy()
	; search for a match
	If _Sleep(2000) Then Return
	local $aBBFindNow = [521, 308, 0xffc246, 30] ; search button
	If _CheckPixel($aBBFindNow, True) Then
		PureClick($aBBFindNow[0], $aBBFindNow[1])
	Else
		SetLog("Could not locate search button to go find an attack.", $COLOR_ERROR)
		Return
	EndIf

	If _Sleep(1500) Then Return ; give time for find now button to go away
	If _CheckPixel($aBBFindNow, True) Then ; click failed so something went wrong
		SetLog("Click BB Find Now failed. We will come back and try again.", $COLOR_ERROR)
		ClickP($aAway)
		ZoomOut()
		Return
	EndIf

	local $iAndroidSuspendModeFlagsLast = $g_iAndroidSuspendModeFlags
	$g_iAndroidSuspendModeFlags = 0 ; disable suspend and resume
	If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Disabled")

	; wait for the clouds to clear
	SetLog("Searching for Opponent.", $COLOR_BLUE)
	local $timer = __TimerInit()
	local $iPrevTime = 0
	While Not CheckBattleStarted()
		local $iTime = Int(__TimerDiff($timer)/ 60000)
		If $iTime > $iPrevTime Then ; if we have increased by a minute
			SetLog("Clouds: " & $iTime & "-Minute(s)")
			$iPrevTime = $iTime
		EndIf
		If _Sleep($DELAYRESPOND) Then
			$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
			If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
			Return
		EndIf
	WEnd

	; Get troops on attack bar and their quantities
	local $aBBAttackBar = GetAttackBarBB()
	Local $i = 0
	local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
		
	DeployBBTroop($aBBAttackBar[$i][0], $aBBAttackBar[$i][1], $aBBAttackBar[$i][2], Random(1, 3, 1), $iSide)

	For $i = 0 To 15
		; Surrender button [FC5D64]
		If chkSurrenderBtn() = True Then
			SetLog("Let's Surrender!")
			ClickP($aSurrenderButton, 1, 0, "#0099") ;Click Surrender
			ExitLoop
		EndIf
		If _Sleep(500) Then Return
	Next
	
	If _Sleep(500) Then Return
	
	If $i > 15 Then 
		Setlog("Surrender button Problem!", $COLOR_WARNING)
		CloseCoc(True)
		Else
		ClickOkay("SurrenderOkay") ; Click Okay to Confirm surrender
		If _Sleep(500) Then Return
	EndIf
	
	; wait for end of battle
	SetLog("End battle.", $COLOR_BLUE)
	If Not Okay() Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf
	SetLog("Battle Ended.")
	If _Sleep(3000) Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf

	ClickP($aAway, 2, 0, "#0332") ;Click Away
	SetLog("Done BB Drop trophy.", $COLOR_SUCCESS)
	ZoomOut()

	$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast ; reset android suspend and resume stuff
	If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature - Attack and Defenses Part
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: RoroTiti
; Modified ......: Chilly-Chill (08.2019)
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

Func WatchDefense()
	Click(40, 150) ; open messages tab - defenses tab
	randomSleep(1500)

	If IsMessagesReplayWindow() Then
		Click(190, 90 + $g_iMidOffsetY) ; open defenses tab
		randomSleep(1500)

		If IsDefensesTab() Then
			Click(710, (180 + $g_iMidOffsetY + (145 * Random(0, 2, 1)))) ; click on a random replay
			WaitForReplayWindow()

			If IsReplayWindow() Then
				GetReplayDuration(0)
				randomSleep(1000)

				If IsReplayWindow() Then
					AccelerateReplay(0)
				EndIf

				randomSleep($g_aReplayDuration[1] / 3)

				Local $IsBoring = Random(1, 5, 1)
				If $IsBoring >= 4 Then
					If IsReplayWindow() Then
						SetLog("This Replay Is Boring, Let Me Go Out ...", $COLOR_OLIVE)
						Click(70, 620 + $g_iBottomOffsetY) ; return home
					EndIf
				Else
					If IsReplayWindow() Then
						DoAPauseDuringReplay(0)
					EndIf

					randomSleep($g_aReplayDuration[1] / 3)

					If IsReplayWindow() And $g_aReplayDuration[0] <> 0 Then
						DoAPauseDuringReplay(0)
					EndIf

					If IsReplayWindow() Then SetLog("Waiting For Replay End ...", $COLOR_ACTION)

					While IsReplayWindow()
						Sleep(2000)
					WEnd

					randomSleep(1000)
					Click(70, 620 + $g_iBottomOffsetY) ; return home
				EndIf
			EndIf
		Else
			SetLog("Error When Trying To Open Defenses Menu ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Replays Menu ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>WatchDefense

Func WatchAttack()
	Click(40, 150) ; open messages tab - defenses tab
	randomSleep(1500)

	If IsMessagesReplayWindow() Then
		Click(380, 90 + $g_iMidOffsetY) ; open attacks tab
		randomSleep(1500)

		If IsAttacksTab() Then
			Click(710, (180 + $g_iMidOffsetY + (145 * Random(0, 2, 1)))) ; click on a random replay
			WaitForReplayWindow()

			If IsReplayWindow() Then
				GetReplayDuration(0)
				randomSleep(1000)

				If IsReplayWindow() Then
					AccelerateReplay(0)
				EndIf

				randomSleep($g_aReplayDuration[1] / 3)

				Local $IsBoring = Random(1, 5, 1)
				If $IsBoring >= 4 Then
					If IsReplayWindow() Then
						SetLog("This Replay Is Boring, Let Me Go Out ...", $COLOR_OLIVE)
						randomSleep(1000)
						Click(70, 620 + $g_iBottomOffsetY) ; return home
					EndIf
				Else
					If IsReplayWindow() Then
						DoAPauseDuringReplay(0)
					EndIf

					randomSleep($g_aReplayDuration[1] / 3)

					If IsReplayWindow() And $g_aReplayDuration[0] <> 0 Then
						DoAPauseDuringReplay(0)
					EndIf

					If IsReplayWindow() Then SetLog("Waiting For Replay End ...", $COLOR_ACTION)

					While IsReplayWindow()
						Sleep(2000)
					WEnd

					randomSleep(1000)
					Click(70, 620 + $g_iBottomOffsetY) ; return home
				EndIf
			EndIf
		Else
			SetLog("Error When Trying To Open Defenses Menu ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Replays Menu ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>WatchAttack

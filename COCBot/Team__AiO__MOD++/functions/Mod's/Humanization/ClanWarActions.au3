; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature - War Part
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: RoroTiti
; Modified ......: 11.11.2016
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

Func LookAtCurrentWar()
	Click(40, 470 + $g_iBottomOffsetY) ; open war menu
	randomSleep(5000)

	If IsWarMenu() Then
		Local $bWarType = QuickMIS("N1", $g_sImgHumanizationCurrentWar, 740, 290 + $g_iMidOffsetY, 850, 600 + $g_iMidOffsetY) ;October Update
		If $bWarType = "CurrentWar" Or $bWarType = "CurrentWarCwl" Then ;Check if it is Simple War Or Cwl War
			SetLog("Let's Examine The " & $bWarType & " Map ...", $COLOR_OLIVE)
			Scroll(Random(2, 5, 1)) ; scroll enemy
			randomSleep(3000)

			If $bWarType = "CurrentWar" Then
				Local $LookAtHome = Random(0, 1, 1)
				If $LookAtHome = 1 Then
					SetLog("Looking At Home Territory ...", $COLOR_OLIVE)
					Click(790, 340 + $g_iMidOffsetY) ; go to home territory
					Scroll(Random(2, 5, 1)) ; scroll home
					randomSleep(3000)
				EndIf
			EndIf

			SetLog("Open War Details Menu ...", $COLOR_OLIVE)
			If $bWarType = "CurrentWar" Then Click(800, 610 + $g_iBottomOffsetY) ; go to war details
			If $bWarType = "CurrentWarCwl" Then Click(810, 540 + $g_iMidOffsetY) ; go to Cwl war details
			randomSleep(1500)

			If IsClanOverview() Then
				Local $FirstMenu = Random(1, 2, 1)
				Switch $FirstMenu
					Case 1
						SetLog("Looking At First Tab ...", $COLOR_OLIVE)
						Click(180, 50 + $g_iMidOffsetY) ; click first tab
					Case 2
						SetLog("Looking At Second Tab ...", $COLOR_OLIVE)
						Click(360, 50 + $g_iMidOffsetY) ; click second tab
				EndSwitch
				randomSleep(1500)

				Scroll(Random(1, 3, 1)) ; scroll the tab

				Local $SecondMenu = Random(1, 2, 1)
				Switch $SecondMenu
					Case 1
						SetLog("Looking At Third Tab ...", $COLOR_OLIVE)
						Click(530, 50 + $g_iMidOffsetY) ; click the third tab
					Case 2
						SetLog("Looking At Fourth Tab ...", $COLOR_OLIVE)
						Click(700, 50 + $g_iMidOffsetY) ; click the fourth tab
				EndSwitch
				randomSleep(1500)

				Scroll(Random(2, 4, 1)) ; scroll the tab

				Click(830, 50 + $g_iMidOffsetY) ; close window
				randomSleep(1500)
				Click(70, 620 + $g_iBottomOffsetY) ; return home
			Else
				SetLog("Error When Trying To Open War Details Window ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Your Clan Is Not In Active War yet ... Skipping ...", $COLOR_WARNING)
			randomSleep(1500)
			Click(70, 620 + $g_iBottomOffsetY) ; return home
		EndIf
	Else
		SetLog("Error When Trying To Open War Window ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>LookAtCurrentWar

Func WatchWarReplays()
	Click(40, 470 + $g_iBottomOffsetY) ; open war menu
	randomSleep(5000)
	Local $bWarType = QuickMIS("N1", $g_sImgHumanizationCurrentWar, 740, 290 + $g_iMidOffsetY, 850, 600 + $g_iMidOffsetY) ;October Update
	If (QuickMIS("BC1", $g_sImgHumanizationWarDetails, 740, 560 + $g_iBottomOffsetY, 850, 660 + $g_iBottomOffsetY) And $bWarType = "CurrentWar") Or $bWarType = "CurrentWarCwl" Then
		SetLog("Open War Details Menu ...", $COLOR_OLIVE)
		If $bWarType = "CurrentWar" Then Click(800, 610 + $g_iBottomOffsetY) ; go to war details
		If $bWarType = "CurrentWarCwl" Then Click(810, 540 + $g_iMidOffsetY) ; go to Cwl war details
		randomSleep(1500)

		If IsClanOverview() Then
			SetLog("Looking At Second Tab ...", $COLOR_OLIVE)
			Click(360, 50 + $g_iMidOffsetY) ; go to replays tab
			randomSleep(1500)

			If IsBestClans() Then
				Local $ReplayNumber = QuickMIS("Q1", $g_sImgHumanizationReplay, 780, 210 + $g_iMidOffsetY, 840, 610 + $g_iBottomOffsetY)

				If $ReplayNumber > 0 Then
					SetLog("There Are " & $ReplayNumber & " Replays To Watch ... We Will Choose One Of Them ...", $COLOR_INFO)
					Local $ReplayToLaunch = Random(1, $ReplayNumber, 1)

					Click(810, 239 + 74 * ($ReplayToLaunch - 1) + $g_iMidOffsetY) ; click on the choosen replay

					WaitForReplayWindow()

					If IsReplayWindow() Then
						GetReplayDuration(1)
						randomSleep(1000)

						If IsReplayWindow() Then
							AccelerateReplay(1)
						EndIf

						randomSleep($g_aReplayDuration[1] / 3)

						If IsReplayWindow() Then
							DoAPauseDuringReplay(1)
						EndIf

						randomSleep($g_aReplayDuration[1] / 3)

						If IsReplayWindow() And $g_aReplayDuration[0] <> 0 Then
							DoAPauseDuringReplay(1)
						EndIf

						SetLog("Waiting For Replay End ...", $COLOR_ACTION)

						While IsReplayWindow()
							Sleep(2000)
						WEnd

						randomSleep(1000)
						Click(70, 620 + $g_iBottomOffsetY) ; return home
					EndIf
				Else
					SetLog("No Replay To Watch Yet ... Skipping ...", $COLOR_WARNING)
				EndIf
			Else
				SetLog("Error When Trying To Open Replays Menu ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Error When Trying to Open War Details Window ... Skipping ...", $COLOR_WARNING)
		EndIf

		Click(830, 50 + $g_iMidOffsetY) ; close window
		randomSleep(3500)
		Click(70, 620 + $g_iBottomOffsetY) ; return home
	Else
		SetLog("Your Clan Is Not In Active War Yet ... Skipping ...", $COLOR_WARNING)
		randomSleep(1500)
		Click(70, 620 + $g_iBottomOffsetY) ; return home
	EndIf
EndFunc   ;==>WatchWarReplays

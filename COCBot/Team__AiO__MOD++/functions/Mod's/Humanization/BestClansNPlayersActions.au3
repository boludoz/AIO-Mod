; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature - Best Clans and Players Part
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

Func VisitBestPlayers()
	Click(40, 80) ; open the cup menu
	If randomSleep(1500) Then Return

	If IsClanOverview() Then
		Click(540, 80 + $g_iMidOffsetY) ; open best players menu
		If randomSleep(3000) Then Return

		If IsBestPlayers() Then
			Local $PlayerList = Random(1, 2, 1)
			Switch $PlayerList
				Case 1
					Click(270, 110 + $g_iMidOffsetY) ; look at global list
					If randomSleep(1000) Then Return
					Click(580, 320 + $g_iMidOffsetY + (52 * Random(0, 6, 1)))
					If randomSleep(500) Then Return
					VisitAPlayer()
					Click(70, 620 + $g_iBottomOffsetY) ; return home
				Case 2
					Click(640, 110 + $g_iMidOffsetY) ; look at local list
					If randomSleep(1000) Then Return
					Click(580, 160 + $g_iMidOffsetY + (52 * Random(0, 9, 1)))
					If randomSleep(500) Then Return
					VisitAPlayer()
					Click(70, 620 + $g_iBottomOffsetY) ; return home
			EndSwitch
		Else
			SetLog("Error When Trying To Open Best Players Menu ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open League Menu ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>VisitBestPlayers

Func LookAtBestClans()
	Click(40, 80) ; open the cup menu
	If randomSleep(1500) Then Return

	If IsClanOverview() Then
		Click(360, 50 + $g_iMidOffsetY) ; open best clans menu
		If randomSleep(3000) Then Return

		If IsBestClans() Then
			Local $PlayerList = Random(1, 2, 1)
			Switch $PlayerList
				Case 1
					Click(270, 110 + $g_iMidOffsetY) ; look at global list
					Click(580, 300 + $g_iMidOffsetY + (52 * Random(0, 6, 1)))
				Case 2
					Click(640, 110 + $g_iMidOffsetY) ; look at local list
					Click(580, 160 + $g_iMidOffsetY + (52 * Random(0, 9, 1)))
			EndSwitch
			If randomSleep(1500) Then Return

			If QuickMIS("BC1", $g_sImgHumanizationWarLog) Then
				SetLog("We Have Found a War Log Button, Let's Look At It ...", $COLOR_OLIVE)
				Click(100, 370 + $g_iMidOffsetY) ; open war log if available
				If randomSleep(1500) Then Return
				Click(270, 105 + $g_iMidOffsetY) ; classic war
				If randomSleep(1500) Then Return
				SetLog("Let's Scrolling The War Log ...", $COLOR_OLIVE)
				Scroll(Random(0, 2, 1)) ; scroll the war log
				SetLog("Exiting War Log Window ...", $COLOR_OLIVE)
				Click(50, 50 + $g_iMidOffsetY) ; click Return
			EndIf

			If randomSleep(1500) Then Return
			SetLog("Let's Scrolling The Clan Member List...", $COLOR_OLIVE)
			Scroll(Random(3, 5, 1)) ; scroll the member list

			Click(830, 50 + $g_iMidOffsetY) ; close window

		Else
			SetLog("Error When Trying To Open Best Players Menu ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open League Menu ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>LookAtBestClans

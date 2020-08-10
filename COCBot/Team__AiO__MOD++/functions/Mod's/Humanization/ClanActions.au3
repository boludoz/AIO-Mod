; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature - Clan Part
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

Func LookAtWarLog()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	If randomSleep(3000) Then Return

	If ChatOpen() Then
		If randomSleep(1500) Then Return

		If IsClanChat() Then
			Click(120, 30) ; open the clan menu
			If randomSleep(1500) Then Return

			If IsClanOverview() Then
				If QuickMIS("BC1", $g_sImgHumanizationWarLog) Then ; October Update Changed
					Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY) ; open war log
					If randomSleep(500) Then Return
					Click(258, 135) ;Click Classic War Log
					If randomSleep(500) Then Return
					SetLog("Let's Scrolling The War Log ...", $COLOR_OLIVE)
					Scroll(Random(1, 3, 1)) ; scroll the war log
				Else
					SetLog("No War Log Button Found ... Skipping ...", $COLOR_WARNING)
				EndIf

				Click(830, 45 + $g_iMidOffsetY) ; close window
				If randomSleep(1000) Then Return
				Click(330, 380 + $g_iMidOffsetY) ; close chat
			Else
				SetLog("Error When Trying To Open Clan Overview ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Error When Trying To Open Clan Chat ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Chat ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>LookAtWarLog

Func VisitClanmates()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	If randomSleep(3000) Then Return

	If ChatOpen() Then
		If randomSleep(1500) Then Return

		If IsClanChat() Then
			Click(120, 30) ; open the clan menu
			If randomSleep(1500) Then Return

			If IsClanOverview() Then
				SetLog("Let's Visit a Random Player ...", $COLOR_OLIVE)
				Click(660, 428 + $g_iMidOffsetY + (52 * Random(0, 5, 1))) ; click on a random player
				If randomSleep(1500) Then Return ;Was less due to that bot was unable to detect visit button
				VisitAPlayer()
				If randomSleep(500) Then Return
				Click(70, 620 + $g_iBottomOffsetY) ; return home
			Else
				SetLog("Error When Trying To Open Clan overview ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Error When Trying To Open Clan Chat ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Chat ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>VisitClanmates

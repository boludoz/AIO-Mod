; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: RoroTiti
; Modified ......: TheRevenor (22.10.2016), RoroTiti (08.05.2017), ProMac (02.2017), Chilly-Chill (08.2019)
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

#cs; ================================================== RANDOM CLICK/SLEEP PART ================================================== ;
Func Click($x, $y, $times = 1, $speed = 0, $debugtxt = "")

	; !!! Not original function but randomization calculation which is linked to original function renamed FClick !!!
	; !!! Still compatible with all original function parameters !!!

	If $g_bUseAltRClick = True Then
		Local $xclick = Random($x - 5, $x, 1)
		Local $yclick = Random($y, $y + 5, 1)
		If $xclick <= 0 Or $xclick >= 860 Then $xclick = $x ; Out Of Screen protection
		If $yclick <= 0 Or $yclick >= 650 + ($g_iMidOffsetY) Then $yclick = $y ; Out Of Screen protection
		FClick($xclick, $yclick, $times, $speed, $debugtxt)
	Else
		FClick($x, $y, $times, $speed, $debugtxt)
	EndIf

EndFunc   ;==>Click

Func PureClick($x, $y, $times = 1, $speed = 0, $debugtxt = "")

	; !!! Not original function but randomization calculation which is linked to original function renamed FPureClick !!!
	; !!! Still compatible with all original function parameters !!!

	If $g_bUseAltRClick = True Then
		Local $xclick = Random($x - 5, $x, 1)
		Local $yclick = Random($y, $y + 5, 1)
		If $xclick <= 0 Or $xclick >= 860 Then $xclick = $x ; Out Of Screen protection
		If $yclick <= 0 Or $yclick >= 650 + ($g_iMidOffsetY) Then $yclick = $y ; Out Of Screen protection
		FPureClick($xclick, $yclick, $times, $speed, $debugtxt)
	Else
		FPureClick($x, $y, $times, $speed, $debugtxt)
	EndIf

EndFunc   ;==>PureClick

Func GemClick($x, $y, $times = 1, $speed = 0, $debugtxt = "")

	; !!! Not original function but randomization calculation which is linked to original function renamed FGemClick !!!
	; !!! Still compatible with all original function parameters !!!

	If $g_bUseAltRClick = True Then
		Local $xclick = Random($x - 5, $x, 1)
		Local $yclick = Random($y, $y + 5, 1)
		If $xclick <= 0 Or $xclick >= 860 Then $xclick = $x ; Out Of Screen protection
		If $yclick <= 0 Or $yclick >= 650 + ($g_iMidOffsetY) Then $yclick = $y ; Out Of Screen protection
		FGemClick($xclick, $yclick, $times, $speed, $debugtxt)
	Else
		FGemClick($x, $y, $times, $speed, $debugtxt)
	EndIf

EndFunc   ;==>GemClick
#ce; ================================================== RANDOM CLICK/SLEEP PART ================================================== ;
; ================================================== HUMAN FUNCTIONS PART ================================================== ;

Func BotHumanization()
	If $g_bUseBotHumanization = True Then
		If Not $g_bRunState Then Return
		Local $NoActionsToDo = 0
		SetLog("OK, Let AiO++ Makes The Bot More Human Like!", $COLOR_SUCCESS1)

		If $g_bLookAtRedNotifications = True Then LookAtRedNotifications()
		If $g_bCollectAchievements = True Then CollectAchievements()
		ReturnAtHome()

		For $i = 0 To 12
			Local $ActionEnabled = _GUICtrlComboBox_GetCurSel($g_acmbPriority[$i])
			If $ActionEnabled = 0 Then $NoActionsToDo += 1
		Next

		If $NoActionsToDo <> 13 Then
			$g_iMaxActionsNumber = Random(1, _GUICtrlComboBox_GetCurSel($g_hCmbMaxActionsNumber) + 1, 1)
			SetLog("AiO++ Will Do " & $g_iMaxActionsNumber & " Human Actions During This Loop ...", $COLOR_INFO)
			For $i = 1 To $g_iMaxActionsNumber
				If randomSleep(4000) Then Return
				ReturnAtHome()
				RandomHumanAction()
			Next
		Else
			SetLog("All Actions Disabled, Skipping ...", $COLOR_WARNING)
		EndIf
		SetLog("Bot Humanization Finished !", $COLOR_SUCCESS1)
		If randomSleep(3000) Then Return
	EndIf
EndFunc   ;==>BotHumanization

Func RandomHumanAction()
	For $i = 0 To 12 ; ($i = 0 To 11) Global Chat should Fix on SC update
		SetActionPriority($i)
	Next
	$g_iActionToDo = _ArrayMaxIndex($g_aSetActionPriority)
	Switch $g_iActionToDo
		Case 0
			SetLog("AiO++ Humanization Read Clan Chat Now. Let's Go!", $COLOR_INFO)
			ReadClanChat()
		Case 1
			SetLog("AiO++ Humanization Read Global Chat Now. Let's Go!", $COLOR_INFO)
			ReadGlobalChat()
		Case 2
			SetLog("AiO++ Humanization Talk With Your Clan Now. Let's Go!", $COLOR_INFO)
			SaySomeChat()
		Case 3
			SetLog("AiO++ Humanization Watch a Defense Now. Let's Go!", $COLOR_INFO)
			WatchDefense()
		Case 4
			SetLog("AiO++ Humanization Watch an Attack Now. Let's Go!", $COLOR_INFO)
			WatchAttack()
		Case 5
			SetLog("AiO++ Humanization Look at War Log Now. Let's Go!", $COLOR_INFO)
			LookAtWarLog()
		Case 6
			SetLog("AiO++ Humanization Visit Clanmates Now. Let's Go!", $COLOR_INFO)
			VisitClanmates()
		Case 7
			SetLog("AiO++ Humanization Visit Best Players Now. Let's Go!", $COLOR_INFO)
			VisitBestPlayers()
		Case 8
			SetLog("AiO++ Humanization Look at Best Clans Now. Let's Go!", $COLOR_INFO)
			LookAtBestClans()
		Case 9
			SetLog("AiO++ Humanization Look at Current War Now. Let's Go!", $COLOR_INFO)
			LookAtCurrentWar()
		Case 10
			SetLog("AiO++ Humanization Watch War Replay Now. Let's Go!", $COLOR_INFO)
			WatchWarReplays()
		Case 11
			SetLog("AiO++ Humanization Do Nothing For Now.", $COLOR_INFO)
			DoNothing()
		Case 12
			SetLog("AiO++ Humanization Launch Challenges Now. Let's Go!", $COLOR_INFO)
			LaunchChallenges()
	EndSwitch
EndFunc   ;==>RandomHumanAction

Func SetActionPriority($ActionNumber)
	If _GUICtrlComboBox_GetCurSel($g_acmbPriority[$ActionNumber]) <> 0 Then
		MatchPriorityNValue($ActionNumber)
		$g_aSetActionPriority[$ActionNumber] = Random($g_iMinimumPriority, 100, 1)
	Else
		$g_aSetActionPriority[$ActionNumber] = 0
	EndIf
EndFunc   ;==>SetActionPriority

Func MatchPriorityNValue($ActionNumber)
	Switch _GUICtrlComboBox_GetCurSel($g_acmbPriority[$ActionNumber])
		Case 1
			$g_iMinimumPriority = 0
		Case 2
			$g_iMinimumPriority = 25
		Case 3
			$g_iMinimumPriority = 50
		Case 4
			$g_iMinimumPriority = 75
	EndSwitch
EndFunc   ;==>MatchPriorityNValue

Func WaitForReplayWindow()
	SetLog("Waiting For Replay Screen...", $COLOR_ACTION)
	Local $CheckStep = 0
	While Not IsReplayWindow() And $CheckStep < 30
		If _Sleep(1000) Then Return
		$CheckStep += 1
	WEnd
	Return $g_bOnReplayWindow
EndFunc   ;==>WaitForReplayWindow

Func IsReplayWindow()
	$g_bOnReplayWindow = _ColorCheck(_GetPixelColor(799, 559 + $g_iBottomOffsetY, True), "FF5151", 20)
	Return $g_bOnReplayWindow
EndFunc   ;==>IsReplayWindow

Func GetReplayDuration($g_iReplayToPause) ; will work with this but can update to make time exact.
	Local $MaxSpeed = _GUICtrlComboBox_GetCurSel($g_acmbMaxSpeed[$g_iReplayToPause])
	Local $bResult = QuickMIS("N1", $g_sImgHumanizationDuration, 375, 535 + $g_iBottomOffsetY, 430, 570 + $g_iBottomOffsetY)
	If $bResult = "OneMinute" Then
		$g_aReplayDuration[0] = 1
		$g_aReplayDuration[1] = 90000
	ElseIf $bResult = "TwoMinutes" Then
		$g_aReplayDuration[0] = 2
		$g_aReplayDuration[1] = 150000
	ElseIf $bResult = "ThreeMinutes" Then
		$g_aReplayDuration[0] = 3
		$g_aReplayDuration[1] = 180000
	Else
		$g_aReplayDuration[0] = 0
		$g_aReplayDuration[1] = 45000
	EndIf
	Switch $MaxSpeed
		Case 1
			$g_aReplayDuration[1] /= 2
		Case 2
			$g_aReplayDuration[1] /= 4
	EndSwitch
	SetLog("Estimated Replay Duration : " & $g_aReplayDuration[1] / 1000 & " second(s)", $COLOR_INFO)
EndFunc   ;==>GetReplayDuration

Func AccelerateReplay($g_iReplayToPause)
	Local $CurrentSpeed = 0
	Local $MaxSpeed = _GUICtrlComboBox_GetCurSel($g_acmbMaxSpeed[$g_iReplayToPause])
	If $CurrentSpeed <> $MaxSpeed Then SetLog("Let's Make The Replay Faster ...", $COLOR_OLIVE)
	While $CurrentSpeed < $MaxSpeed
		Click(820, 630 + $g_iBottomOffsetY) ; click on the speed button
		If randomSleep(500) Then Return
		$CurrentSpeed += 1
	WEnd
EndFunc   ;==>AccelerateReplay

Func DoAPauseDuringReplay($g_iReplayToPause)
	Local $MinimumToPause = 0, $PauseScore = 0
	Local $Pause = _GUICtrlComboBox_GetCurSel($g_acmbPause[0])
	If $Pause <> 0 Then
		Switch $Pause
			Case 1
				$MinimumToPause = 80
			Case 2
				$MinimumToPause = 60
			Case 3
				$MinimumToPause = 40
			Case 4
				$MinimumToPause = 20
		EndSwitch
		$PauseScore = Random(0, 100, 1)
		If $PauseScore > $MinimumToPause Then
			SetLog("Let's Do a Small Pause To See What Happens ...", $COLOR_OLIVE)
			Click(750, 630 + $g_iBottomOffsetY) ; click pause button
			If randomSleep(10000, 3000) Then Return
			SetLog("Pause Finished, Let's Relaunch Replay!", $COLOR_OLIVE)
			Click(750, 630 + $g_iBottomOffsetY) ; click play button
		EndIf
	EndIf
EndFunc   ;==>DoAPauseDuringReplay

Func VisitAPlayer()
	If randomSleep(1000) Then Return
	SetLog("Let's Visit a Player ...", $COLOR_INFO)
	If QuickMIS("BC1", $g_sImgHumanizationVisit) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If randomSleep(8000) Then Return
		For $i = 0 To Random(1, 4, 1)
			SetLog("We Will Click On a Random Builing ...", $COLOR_OLIVE)
			Local $xInfo = Random(300, 500, 1)
			Local $yInfo = Random(300, 402 + $g_iMidOffsetY, 1)
			Click($xInfo, $yInfo) ; click on a random builing
			If randomSleep(1500) Then Return
			SetLog("... And Open His Info Window ...", $COLOR_OLIVE)
			Click(430, 575 + $g_iBottomOffsetY) ; open the info window about building
			If randomSleep(8000) Then Return
			Click(685, 145 + $g_iMidOffsetY) ;Click Away
			If randomSleep(3000) Then Return
		Next
	Else
		SetLog("Error When Trying to Find Visit Button ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>VisitAPlayer

Func DoNothing()
	SetLog("Let The Bot Wait a Little Before Continue ...", $COLOR_OLIVE)
	If randomSleep(8000, 3000) Then Return
EndFunc   ;==>DoNothing

Func LookAtRedNotifications()
	SetLog("Looking For Notifications ...", $COLOR_INFO)
	Local $NoNotif = 0
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(50, 137, True), "F5151D", 20) Then
		SetLog("You Have a New Message ...", $COLOR_OLIVE)
		Click(40, 150) ; open Messages button
		If randomSleep(8000, 3000) Then Return
		Click(765, 87 + $g_iMidOffsetY) ; close window
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(50, 76, True), "F5151D", 20) Then
		SetLog("Let's See The Current League You Are In ...", $COLOR_OLIVE)
		Click(40, 90) ; open Cup button
		If randomSleep(4000) Then Return
		Click(445, 580 + $g_iMidOffsetY) ; click Okay
		If randomSleep(1500) Then Return
		Click(830, 50 + $g_iMidOffsetY) ; close window
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(50, 451 + $g_iBottomOffsetY, True), "F5151D", 20) Then
		SetLog("Current War To Look At ...", $COLOR_OLIVE)
		Click(40, 490 + $g_iMidOffsetY) ; open War menu
		If randomSleep(8000, 3000) Then Return
		Click(70, 620 + $g_iBottomOffsetY) ; return home
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(28, 323 + $g_iMidOffsetY, True), "F5151D", 20) Then
		SetLog("New Messages On The Chat Room ...", $COLOR_OLIVE)
		Click(20, 380 + $g_iMidOffsetY) ; open chat
		If randomSleep(3000) Then Return
		Click(330, 380 + $g_iMidOffsetY) ; close chat
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(722, 614 + $g_iBottomOffsetY, True), "F5151D", 20) Then
		SetLog("New Messages Or Events From SC To Read ...", $COLOR_OLIVE)
		Click(715, 630 + $g_iBottomOffsetY) ; open events
		If randomSleep(3000) Then Return

		If _ColorCheck(_GetPixelColor(245, 80 + $g_iMidOffsetY, True), "F0F4F0", 20) Then ; check if we are on events/news tab
			Click(435, 80 + $g_iMidOffsetY) ; open new tab
			If randomSleep(3000) Then Return
		Else
			Click(245, 80 + $g_iMidOffsetY) ; open events tab
			If randomSleep(3000) Then Return
		EndIf

		Click(760, 90 + $g_iMidOffsetY) ; close settings
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(832, 578 + $g_iBottomOffsetY, True), "683072", 20) Or _ColorCheck(_GetPixelColor(832, 577 + $g_iBottomOffsetY, True), "F5151D", 20) Then
		SetLog("There Is Something New On The Shop ...", $COLOR_OLIVE)
		Click(800, 610 + $g_iBottomOffsetY) ; open Shop
		If randomSleep(2000) Then Return
		Local $NeedScroll = Random(0, 1, 1)
		Local $NeedScroll2 = Random(0, 1, 1)
		If $NeedScroll = 1 Then
			Local $xStart = Random(300, 800, 1)
			Local $xEnd = Random($xStart - 250, $xStart - 220, 1)
			Local $y = Random(330 - 10 + $g_iMidOffsetY, 330 + 10 + $g_iMidOffsetY, 1)
			ClickDrag($xStart, $y, $xEnd, $y) ; scroll the shop
			If $NeedScroll2 = 1 Then
				If randomSleep(2000) Then Return
				$xEnd = Random(300, 800, 1)
				$xStart = Random($xEnd - 250, $xEnd - 220, 1)
				$y = Random(330 - 10 + $g_iMidOffsetY, 330 + 10 + $g_iMidOffsetY, 1)
				ClickDrag($xStart, $y, $xEnd, $y) ; scroll the shop
			EndIf
		EndIf

		If randomSleep(2000) Then Return
		Click(820, 40) ; return home
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(50, 17, True), "F5151D", 20) Then
		SetLog("Maybe You Have a New Friend Request, Let Me Check ...", $COLOR_OLIVE)
		Click(40, 40) ; open profile
		If randomSleep(2000) Then Return

		If IsClanOverview() Then
			If _ColorCheck(_GetPixelColor(773, 63, True), "E20814", 20) Then
				SetLog("It's Confirmed, You Have a New Friend Request, Let Me Check ...", $COLOR_OLIVE)
				Click(720, 50 + $g_iMidOffsetY)
				If randomSleep(2000) Then Return
				If QuickMIS("BC1", $g_sImgHumanizationFriend, 720, 130 + $g_iMidOffsetY, 780, 570 + $g_iMidOffsetY) Then
					Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
					If randomSleep(1500) Then Return
					If QuickMIS("BC1", $g_sImgHumanizationFriend, 440, 350 + $g_iMidOffsetY, 590, 440 + $g_iMidOffsetY) Then
						Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY)
					Else
						SetLog("Error When Trying To Find Okay Button ... Skipping ...", $COLOR_WARNING)
					EndIf
				Else
					SetLog("Error When Trying To Find Friend Request ... Skipping ...", $COLOR_WARNING)
				EndIf
			Else
				SetLog("No Friend Request Found ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Error When Trying To Open Social Tab ... Skipping ...", $COLOR_WARNING)
		EndIf
		If randomSleep(2000) Then Return
	Else
		$NoNotif += 1
	EndIf
	If $NoNotif = 7 Then SetLog("No Notification Found, Nothing To Look At ...", $COLOR_OLIVE)
EndFunc   ;==>LookAtRedNotifications

#CS
Func CollectAchievements()
	SetLog("Looking For Achievement To Collect ...", $COLOR_INFO)
	ReturnAtHome()
	If _ColorCheck(_GetPixelColor(50, 17, True), "F5151D", 20) Then
		SetLog("WoW, Maybe An Achievement To Collect !", $COLOR_OLIVE)
		Click(40, 40) ; open profile
		If randomSleep(4000) Then Return

		If IsClanOverview() Then
			If QuickMIS("BC1", $g_sImgHumanizationClaimReward, 680) Then
				Click($g_iQuickMISWOffSetX, $g_iQuickMISY)
				SetLog("Reward Collected! Good Job Chief!", $COLOR_SUCCESS)
				If randomSleep(3000) Then Return
			Else
				SetLog("No 'Claim Reward' Button Found ... Let Me Retry ...", $COLOR_ERROR)
				If QuickMIS("BC1", $g_sImgHumanizationClaimReward, 680) Then
					Click($g_iQuickMISWOffSetX, $g_iQuickMISY)
					SetLog("Reward Collected! Good Job Chief!", $COLOR_SUCCESS)
					If randomSleep(3000) Then Return
				Else
					SetLog("No 'Claim Reward' Button Found ... Skipping ...", $COLOR_ERROR)
				EndIf
			EndIf
		Else
			SetLog("Error When Trying To Open Profile Tab ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("No Achievement To Collect ...", $COLOR_OLIVE)
	EndIf
EndFunc   ;==>CollectAchievements
#CE
Func Scroll($MaxScroll)
	For $i = 0 To $MaxScroll
		Local $x = Random(430 - 20, 430 + 20, 1)
		Local $yStart = Random(600 - 20 + $g_iMidOffsetY, 600 + 20 + $g_iMidOffsetY, 1)
		Local $yEnd = Random(200 - 20 + $g_iMidOffsetY, 200 + 20 + $g_iMidOffsetY, 1)
		ClickDrag($x, $yStart, $x, $yEnd) ; generic random scroll
		If randomSleep(4000) Then Return
	Next
EndFunc   ;==>Scroll

; ================================================== SECURITY PART ================================================== ;

Func SecureMessage($TextToClean)
	Return StringRegExpReplace($TextToClean, "[^\w \-\,\?\!\:]", "") ; delete dangerous characters
EndFunc   ;==>SecureMessage

Func ReturnAtHome()
	Local $CheckStep = 0
	While Not IsMainScreen() And $CheckStep <= 5
		AndroidBackButton()
		If randomSleep(3000) Then Return
		$CheckStep += 1
	WEnd
	If Not IsMainScreen() Then
		SetLog("Main Screen Not Found, Need To Restart CoC App...", $COLOR_ERROR)
		RestartAndroidCoC()
		waitMainScreen()
	EndIf
EndFunc   ;==>ReturnAtHome

Func IsMainScreen()
	;Wait for Main Screen To Be Appear
	Local $bResult = False
	
	If IsMainPage(2) Then
		$bResult = True
	ElseIf IsMainPageBuilderBase(2) Then
		$bResult = True
	EndIf
	
	Return $bResult
EndFunc   ;==>IsMainScreen

Func IsMessagesReplayWindow()
	Local $bResult = _Wait4Pixel(750, 93 + $g_iMidOffsetY, 0xED1115, 20, 3000, "IsMessagesReplayWindow") ;Wait for Replay Message Window To Be Appear
	Return $bResult
EndFunc   ;==>IsMessagesReplayWindow

Func IsDefensesTab()
	Local $bResult = _Wait4Pixel(180, 80 + $g_iMidOffsetY, 0xF0F4F0, 20, 3000, "IsDefensesTab") ;Wait for Defence To Be Selected
	Return $bResult
EndFunc   ;==>IsDefensesTab

Func IsAttacksTab()
	Local $bResult = _Wait4Pixel(380, 110 + $g_iMidOffsetY, 0xF0F4F0, 20, 3000, "IsAttacksTab") ;Wait for Attack To Be Selected
	Return $bResult
EndFunc   ;==>IsAttacksTab

Func IsBestPlayers()
	Local $bResult = _Wait4Pixel(530, 60 + $g_iMidOffsetY, 0xF0F4F0, 20, 3000, "IsBestPlayers") ;Wait for Best Player Screen To Be Appear
	Return $bResult
EndFunc   ;==>IsBestPlayers

Func IsBestClans()
	Local $bResult = _Wait4Pixel(350, 60 + $g_iMidOffsetY, 0xF0F4F0, 20, 3000, "IsBestClans") ;Wait for Best Clan Screen To Be Appear
	Return $bResult
EndFunc   ;==>IsBestClans

Func ChatOpen()
	Local $bResult = _Wait4Pixel(330, 382 + $g_iMidOffsetY, 0xC75315, 20, 3000, "ChatOpen") ;Wait for Chat To Be Appear
	Return $bResult
EndFunc   ;==>ChatOpen

Func IsClanChat()
	Local $bResult = _Wait4Pixel(220, 10, 0x787458, 20, 3000, "IsClanChat") ;Wait for Clan Chat To Be Appear
	Return $bResult
EndFunc   ;==>IsClanChat

Func IsGlobalChat()
	Local $bResult = _Wait4Pixel(80, 10, 0x787458, 20, 3000, "IsGlobalChat") ;Wait for Global Chat To Be Appear
	Return $bResult
EndFunc   ;==>IsGlobalChat

Func IsTextBox()
	Local $bResult = _Wait4Pixel(190, 650 + $g_iBottomOffsetY, 0xFFFFFF, 20, 3000, "IsTextBox") ;Wait for Text Box To Be Appear
	Return $bResult
EndFunc   ;==>IsTextBox

Func IsChallengeWindow()
	Local $bResult = _Wait4Pixel(700, 110, 0xFFFFFF, 20, 3000, "IsChallengeWindow")  ;Wait for Challenge Window To Be Appear
	Return $bResult
EndFunc   ;==>IsChallengeWindow

Func IsChangeLayoutMenu()
	Local $bResult = _Wait4Pixel(180, 110, 0xFFFFFF, 20, 3000, "IsChangeLayoutMenu")  ;Wait for Is Change Layout Menu To Be Appear
	Return $bResult
EndFunc   ;==>IsChangeLayoutMenu

Func IsClanOverview()
	Local $bResult = _Wait4Pixel(822, 40 + $g_iMidOffsetY, 0xFFFFFF, 20, 3000, "IsClanOverview") ;Wait for Is Clan Overview To Be Appear
	Return $bResult
EndFunc   ;==>IsClanOverview

;Func IsWarMenu()
;	Local $bResult = _ColorCheck(_GetPixelColor(826, 34, True), "FFFFFF", 20)
;	Return $bResult
;EndFunc   ;==>IsWarMenu

Func randomSleep($SleepTime, $Range = 0)
	If $g_bRunState = False Then Return True
	If $Range = 0 Then $Range = Round($SleepTime / 5)
	Local $SleepTimeF = Random($SleepTime - $Range, $SleepTime + $Range, 1)
	If $g_bDebugClick Then SetLog("Default sleep : " & $SleepTime & " - Random sleep : " & $SleepTimeF, $COLOR_ORANGE)
	If Not $g_bRunState Or $g_bRestart Then Return
	Return _Sleep($SleepTimeF) = True
EndFunc   ;==>If randomSleep

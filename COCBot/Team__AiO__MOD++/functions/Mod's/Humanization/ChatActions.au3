; #FUNCTION# ====================================================================================================================
; Name ..........: Bot Humanization
; Description ...: This file contains all functions of Bot Humanization feature - Chat Part
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

Func ReadClanChat()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	randomSleep(3000)

	If ChatOpen() Then
		Click(230, 20) ; go to clan chat
		randomSleep(1500)
		If Not IsClanChat() Then SetLog("Warning, We Will Scroll Global Chat ...", $COLOR_WARNING) ;=> Note: Global Chat has been Removed
		ClickIUnderstandIfExist()
		Local $MaxScroll = Random(0, 3, 1)
		SetLog("Let's Scrolling The Chat ...", $COLOR_OLIVE)
		For $i = 0 To $MaxScroll
			Local $x = Random(180 - 10, 180 + 10, 1)
			Local $yStart = Random(110 - 10, 110 + 10, 1)
			Local $yEnd = Random(570 - 10, 570 + 10, 1)
			ClickDrag($x, $yStart, $x, $yEnd) ; scroll the chat
			randomSleep(10000, 3000)
		Next
		Click(330, 380 + $g_iMidOffsetY) ; close chat
	Else
		SetLog("Error When Trying To Open Chat ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>ReadClanChat

Func ReadGlobalChat()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	randomSleep(3000)

	If ChatOpen() Then
		Click(80, 20) ; go to global chat
		randomSleep(1500)
		If Not IsGlobalChat() Then SetLog("Warning, We Will Scroll Clan Chat ...", $COLOR_WARNING)
		ClickIUnderstandIfExist()
		Local $MaxScroll = Random(0, 3, 1)
		SetLog("Let's Scrolling The Chat ...", $COLOR_OLIVE)
		For $i = 0 To $MaxScroll
			Local $x = Random(180 - 10, 180 + 10, 1)
			Local $yStart = Random(110 - 10, 110 + 10, 1)
			Local $yEnd = Random(570 - 10, 570 + 10, 1)
			ClickDrag($x, $yStart, $x, $yEnd) ; scroll the chat
			randomSleep(10000, 3000)
		Next
		Click(330, 380 + $g_iMidOffsetY) ; close chat
	Else
		SetLog("Error When Trying To Open Chat ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>ReadGlobalChat

Func SaySomeChat()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	randomSleep(3000)

	If ChatOpen() Then
		Click(230, 20) ; go to clan chat
		randomSleep(1500)
		If Not IsClanChat() Then SetLog("Warning, We Will Chat On Global Chat ... ", $COLOR_WARNING) ;=> Note: Global Chat has been Removed
		ClickIUnderstandIfExist()
		Click(280, 650 + $g_iBottomOffsetY) ; click message button
		randomSleep(2000)
		If IsTextBox() Then
			Local $ChatToSay = Random(0, 1, 1)
			Local $CleanMessage = SecureMessage(GUICtrlRead($g_ahumanMessage[$ChatToSay]))
			SetLog("Writing """ & $CleanMessage & """ To The Chat Box ...", $COLOR_OLIVE)
			SendText($CleanMessage)

			randomSleep(500)
			Click(840, 650 + $g_iBottomOffsetY) ; click send message

			randomSleep(1500)
			Click(330, 380 + $g_iMidOffsetY) ; close chat
		Else
			SetLog("Error When Trying To Open Text Box For Chatting ... Skipping...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Chat ... Skipping...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>SaySomeChat

Func LaunchChallenges()
	Click(20, 380 + $g_iMidOffsetY) ; open chat
	randomSleep(3000)

	If ChatOpen() Then
		Click(230, 20) ; go to clan chat
		randomSleep(1500)
		If IsClanChat() Then
			ClickIUnderstandIfExist()
			Click(200, 650 + $g_iBottomOffsetY) ; click challenge button
			randomSleep(1500)
			If IsChallengeWindow() Then
				Click(530, 175 + $g_iMidOffsetY) ; click text box
				SendText(SecureMessage(GUICtrlRead($g_hChallengeMessage)))
				randomSleep(1500)
				Local $Layout = Random(1, 2, 1) ; choose a layout between normal or war base
				If $Layout <> $g_iLastLayout Then
					Click(240, 300) ; click choose layout button
					randomSleep(1000)
					If IsChangeLayoutMenu() Then
						Switch $Layout
							Case 1
								$g_iLastLayout = 1
								Local $y = Random(190 - 10, 190 + 10, 1)
								Local $xStart = Random(170 - 10, 170 + 10, 1)
								Local $xEnd = Random(830 - 10, 830 + 10, 1)
								ClickDrag($xStart, $y, $xEnd, $y) ; scroll the layout bar to see normal bases
							Case 2
								$g_iLastLayout = 2
								Local $y = Random(190 - 10, 190 + 10, 1)
								Local $xStart = Random(690 - 10, 690 + 10, 1)
								Local $xEnd = Random(20 - 10, 20 + 10, 1)
								ClickDrag($xStart, $y, $xEnd, $y) ; scroll the layout bar to see war bases
						EndSwitch
						randomSleep(2000)
						Click(240, 180) ; click first layout
						randomSleep(1500)
						Click(180, 110) ; click top left return button
					Else
						SetLog("Error When Trying To Open Change Layout Menu ... Skipping...", $COLOR_WARNING)
					EndIf
				EndIf

				If IsChallengeWindow() Then
					randomSleep(1500)
					Click(530, 300) ; click start button
					randomSleep(1500)
					Click(330, 380 + $g_iMidOffsetY) ; close chat
				Else
					SetLog("We Are Not Anymore On Start Challenge Window ... Skipping ...", $COLOR_WARNING)
				EndIf
			Else
				SetLog("Error When Trying To Open Start Challenge Window ... Skipping ...", $COLOR_WARNING)
			EndIf
		Else
			SetLog("Error When Trying To Open Clan Chat ... Skipping ...", $COLOR_WARNING)
		EndIf
	Else
		SetLog("Error When Trying To Open Chat ... Skipping ...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>LaunchChallenges

Func ClickIUnderstandIfExist() ; December Update(2018) Check for "I Understand" Warning
	Local $aButtonCoords = findMultiple($g_sImgChatIUnterstandMultiLang, GetDiamondFromRect("50,475,260,520"), GetDiamondFromRect("50,475,260,520"), 0, 1000, 0, "objectpoints") ; not working so maybe I will loop through all language options

	If UBound($aButtonCoords) = 0 Then ; button not found
		Return
	EndIf

	local $button = $aButtonCoords[0] ; always one button
	local $aTempMultiCoords = decodeMultipleCoords($button[0]) ; object points
	local $aButtonCoords = $aTempMultiCoords[0] ; one location of button again... must do for some reason or arrays glitch

	SetLog("Chat Rules: Clicking 'I Understand' Button", $COLOR_ACTION)
	Click($aButtonCoords[0], $aButtonCoords[1])
	If _Sleep($DELAYDONATECC2) Then Return
EndFunc   ;==>ClickIUnderstandIfExist
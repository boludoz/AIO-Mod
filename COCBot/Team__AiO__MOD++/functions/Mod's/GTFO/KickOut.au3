; #FUNCTION# ====================================================================================================================
; Name ..........: Kickout
; Description ...: This File contents for 'Kickout' algorithm , fast Donate'n'Train and Kickout New members
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: Boludoz
; Modified ......: 04/2020
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: ---
; ===============================================================================================================================
Global $g_bNotKick = False

Func MainKickout()
	If Not $g_bChkUseKickOut Or $g_bNotKick Then Return
	Local $iLastSlot = 0

	SetLog("Start The Kickout Feature![" & $g_iTxtKickLimit & "]....", $COLOR_INFO)
	Local $Number2Kick = 0

	For $T = 0 To $g_iTxtKickLimit - 1
		
		; Needs refresh.
		CheckMainScreen()
		
		If OpenClanPage() Then

			SetLog("Donated CAP: " & $g_iTxtDonatedCap & " /Received CAP: " & $g_iTxtReceivedCap & " /Kick Spammers: " & $g_bChkKickOutSpammers, $COLOR_INFO)
			For $Rank = 0 To 9

				#Region - Nucleus
				If RandomSleep(1500) Then Return

				Local $aXPStar = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\KickOut", 0, "140, 167, 190, 667", Default, "Star", True, 44)

				If Not IsArray($aXPStar) Then
					CheckMainScreen()
					; Setlog("- KickOut fail : $aXPStar", $COLOR_ERROR)
					Return False
				EndIf

				If RandomSleep(1500) Then Return

				Local $iLocalSlot = SuperSlotInt($aXPStar)

				If $iLastSlot = $iLocalSlot Then Return True

				$iLastSlot = $iLocalSlot

				Go2Bottom()

				_ArrayShuffle($aXPStar)

				For $i = 0 To UBound($aXPStar) - 1
					; Get the Red from 'New' Word
					Local $iNewWord = _PixelSearch(197, $aXPStar[$i][2] + 19, 214, $aXPStar[$i][2] + 28, Hex(0xE73838, 6), 10)
					Local $iRank = _PixelSearch(197, $aXPStar[$i][2] + 19, 214, $aXPStar[$i][2] + 28, Hex(0x646051, 6), 10)

					; Return 0 let's proceed with a new loop
					If $iNewWord = 0 Or $iRank <> 0 Then ContinueLoop

					Local $iDonated = 0
					Local $iReceived = 0

					; Confirming the array and the Dimension
					If IsArray($iNewWord) Then
						$iDonated = Number(getOcrAndCapture("coc-army", 509, $aXPStar[$i][2] + 12, 75, 27, True))
						$iReceived = Number(getOcrAndCapture("coc-army", 626, $aXPStar[$i][2] + 12, 75, 27, True))
						SetDebugLog("$iDonated : " & $iDonated & "/ $iReceived : " & $iReceived)
						SetLog("[NEW CLAN MEMBER] Donated: " & $iDonated & " / Received: " & $iReceived, $COLOR_BLACK)
					Else
						ContinueLoop
					EndIf

					Local $bIsKick = False

					Select
						Case ($iDonated = 0 And $iReceived = 0) Or ($iDonated < $g_iTxtDonatedCap And $iReceived < $g_iTxtReceivedCap)
							$bIsKick = False

						Case ($g_bChkKickOutSpammers = True And $iDonated > 0 And $iReceived = 0) Or ($g_bChkKickOutSpammers = False And $iDonated >= $g_iTxtDonatedCap) Or ($g_bChkKickOutSpammers = False And $iReceived >= $g_iTxtReceivedCap)
							$bIsKick = True

					EndSelect

					SetDebugLog("Is This member 2 Kick? " & $bIsKick, $COLOR_DEBUG)
					If Not $bIsKick Then ContinueLoop

					Local $aFixC[4] = [18, $aXPStar[$i][2], 68, $aXPStar[$i][2] + 36]
					Local $bFixOne = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\KickOut", 2, $aFixC, Default, "FixC", True, 10)

					Click(Random(166, 708, 1), Random($aXPStar[$i][2] - 7, $aXPStar[$i][2] + 29, 1))
					If RandomSleep(500) Then Return

					Local $aClickMod = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\KickOut", 10, "556, 1, 579, 731", Default, "Btn", True, 40)

					If Not IsArray($aClickMod) Then
						Setlog("- KickOut fail : $aClickMod", $COLOR_ERROR)
						Return False
					Else
						_ArraySort($aClickMod, 1, 0, 0, 2)

						SetDebugLog("Is fix : " & IsArray($bFixOne), $COLOR_DEBUG)
						SetDebugLog("Is fix : " & _ArrayToString($aClickMod), $COLOR_DEBUG)

						If IsArray($bFixOne) Then
							Click(Random(462, 566, 1), $aClickMod[1][2] - Random(4, 15, 1))
							If RandomSleep(500) Then Return
						Else
							Click(Random(462, 566, 1), $aClickMod[0][2] - Random(4, 15, 1))
							If RandomSleep(500) Then Return
						EndIf

						Local $aSendOut = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\KickOut", 1, "457, 205, 585, 263", Default, "SendKick", True, 0)

						If Not IsArray($aSendOut) Then
							Setlog("- KickOut fail : $aSendOut", $COLOR_ERROR)
							Return False
						EndIf

						Click(Random($aSendOut[0][1], $aSendOut[0][1] + 30), Random($aSendOut[0][2], $aSendOut[0][2] + 30))
						If RandomSleep(500) Then Return

						$Number2Kick += 1

					EndIf
				Next
				#EndRegion - Nucleus
			Next
			If $g_iTxtKickLimit >= $Number2Kick Then Return
			Click(825, 5, 1)     ; Exit From Clan page
		Else
			If _ColorCheck(_GetPixelColor(329, 362), Hex(0x2D9FF9, 6), 20) Then CloseClanChat()
			ClickAway("Right", True, 2)
			CheckMainScreen()
		EndIf
		If $g_iTxtKickLimit >= $Number2Kick Then Return
	Next


EndFunc   ;==>MainKickout

Func SuperSlotInt($aXPStar = -1)
	Local $vLastIntKickOut

	If IsArray($aXPStar) Then
		_ArraySort($aXPStar, 0, 0, 0, 2)
		$vLastIntKickOut = getOcrAndCapture("coc-v-t", 30, $aXPStar[UBound($aXPStar) - 1][2] - 2, 55, $aXPStar[UBound($aXPStar) - 1][2] - 20, True)
		If $vLastIntKickOut = 0 And UBound($vLastIntKickOut) > 2 Then $vLastIntKickOut = getOcrAndCapture("coc-v-t", 30, $aXPStar[UBound($aXPStar) - 2][2] - 2, 55, $aXPStar[UBound($aXPStar) - 2][2] - 20, True)
		$vLastIntKickOut += 1
	EndIf

	Return $vLastIntKickOut

EndFunc   ;==>SuperSlotInt

Func Go2Bottom()

	SetLog(" ## Go2Bottom | ClickDrag ## ", $COLOR_DEBUG)

	Swipe(421 - Random(0, 50, 1), 580 - Random(0, 50, 1), 421 - Random(0, 50, 1), 50 + Random(0, 10, 1), Random(900, 1100, 1))
	If @error Then
		SetLog("Swipe ISSUE|error: " & @error, $COLOR_DEBUG)
	EndIf
	If _Sleep(150) Then Return ; 500ms

	; SetLog(" ## Go2Bottom | ClickDrag ## Failed!", $COLOR_DEBUG)
	Return True
EndFunc   ;==>Go2Bottom

Func OpenClanPage()

	$g_bDebugOcr = True

;~ 	Local $_aClanColor[4] = [360, 19, 0xf0f4f0, 5]
;~ 	Local $_aClanMainVillage = [360, 81, 0xc8c8b8, 5]

	; ********* OPEN TAB AND CHECK IT PROFILE ***********

	SetLog(" ## OpenClanPage ## ", $COLOR_DEBUG)
	; Click Info Profile Button
	Click(Random(20, 59, 1), Random(10, 60, 1), 1, 0, "#0222")
	If _Sleep(2500) Then Return

	; Check the '[X]' tab region
	If _Wait4Pixel(811, 81, 0xF02227, 25, 4000) Then

		; Click on Clan Tab
		Click(Random(278, 419, 1), Random(62, 103, 1), 1)
		
		If _Wait4Pixel(348, 64, 0x928C82, 25, 4000) Then
	
			; Click on Home Village
			If Not _Wait4Pixel(358, 125, 0xC9C7BA, 25, 500) Then Click(Random(148, 410, 1), Random(122, 149, 1), 1)
		
			; Clan Edit Button
			Local $aCheckEditButton[4] = [419, 332, 0xD7F37F, 10]
			If RandomSleep(500) Then Return
		
			If Not _ColorCheck(_GetPixelColor($aCheckEditButton[0], $aCheckEditButton[1], True), Hex($aCheckEditButton[2], 6), $aCheckEditButton[3]) = True Then
				SetLog("You are not a Co-Leader/Leader of your clan! ", $COLOR_DEBUG)
				ClickAway()
				Return False
			Else
				Return True
			EndIf
		
			SetLog(" ## OpenClanPage ## didn't Openned", $COLOR_DEBUG)
			Return False
		EndIf
	Else
		
	EndIf
EndFunc   ;==>OpenClanPage

Func Swipe($x1, $y1, $X2, $Y2, $Delay, $wasRunState = $g_bRunState)

	Local $error = 0

	If $g_bAndroidAdbClickDrag Then
		AndroidAdbLaunchShellInstance($wasRunState)
		If @error = 0 Then
			AndroidAdbSendShellCommand("input swipe " & $x1 & " " & $y1 & " " & $X2 & " " & $Y2, Default, $wasRunState)
			SetError(0, 0)
		Else
			$error = @error
			SetDebugLog("Disabled " & $g_sAndroidEmulator & " ADB input due to error", $COLOR_ERROR)
			$g_bAndroidAdbInput = False
		EndIf
		If _Sleep($Delay / 5) Then Return SetError(-1, "", False)
	EndIf

	If Not $g_bAndroidAdbClickDrag Or $error <> 0 Then
		Return _PostMessage_ClickDrag($x1, $y1, $X2, $Y2, "left", $Delay)
	EndIf

	Return SetError($error, 0)

EndFunc   ;==>Swipe

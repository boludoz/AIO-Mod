; #FUNCTION# ====================================================================================================================
; Name ..........: Chatbot Text read (#-23)
; Description ...: This file is all related to READ CHAT AI (Fast) | Samkie based
; Syntax ........:
; Parameters ....: ReadChat()
; Return values .: IF THE STATE = -1 CHAT TEXT IS RETURNED IN TEXT, ANOTHER BOOLEAN OF RETURN.
; Author ........: Boludoz/Boldina
; Modified ......: Boludoz (5/7/2018|17/7/2018|5/3/2019)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: ReadChat()
; ===============================================================================================================================
Func ReadChatIATest($sCondition = "porque", $bFast = True)
	Setlog(ReadChatIA($sCondition, $bFast))
EndFunc

Func ReadChatIA($sCondition = "hola", $bFast = True)
	Local $sResult = -1
	Local $asFCKeyword = ""
	Local $aiDonateButton = -1
	Local $aiSearchArray[4] = [200, 90, 300, 700]

	ScrollDown()

	If RandomSleep(500) Then Return

	_CaptureRegion2()
	Local $aChatY = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\Chat", 11, "259, 20, 269, 677", False, Default, False, 0)

	If Not IsArray($aChatY) Then Return False

	_ArraySort($aChatY, 1, 0, 0, 2) ; rearrange order by coor Y

	For $y = 0 To UBound($aChatY) - 1

		Local $yFix = (UBound($aChatY) - 1 <> $y) ? ($aChatY[$y + 1][2]) : (680)
		$aiSearchArray[1] = _Min($yFix, $aChatY[$y][2])
		$aiSearchArray[3] = _Max($yFix, $aChatY[$y][2])
		; _ArrayDisplay($aiSearchArray)
		$aiDonateButton = decodeSingleCoord(findImage("Donate Button", $g_sImgDonateCC & "DonateButton*", GetDiamondFromArray($aiSearchArray), 1, False, Default))
		If UBound($aiDonateButton, 1) >= 2 And not @error Then
			ContinueLoop
		EndIf

		Local $Alphabets[4] = [$g_bChkExtraAlphabets, $g_bChkExtraChinese, $g_bChkExtraKorean, $g_bChkExtraPersian]
		Local $TextAlphabetsNames[4] = ["Cyrillic and Latin", "Chinese", "Korean", "Persian"]
		Local $AlphabetFunctions[4] = ["getChatString", "getChatStringChinese", "getChatStringKorean", "getChatStringPersian"]
		Local $BlankSpaces = "", $ClanString = ""
		For $i = 0 To UBound($Alphabets) - 1
			If $i = 0 Then
				; 75
				Local $coordinates[3] = [40, 53, 66] ; Extra coordinates for Latin (3 Lines)
				Local $OcrName = ($Alphabets[$i] = True) ? ("coc-latin-cyr") : ("coc-latinA")
				Local $slog = "Latin"
				If $Alphabets[$i] Then $slog = $TextAlphabetsNames[$i]
				$ClanString = ""
				SetLog("Using OCR to read ChatBox derived alphabets.", $COLOR_ACTION)
				For $j = 0 To 2
					If $ClanString = "" Or $ClanString = " " Then
						$ClanString &= $BlankSpaces & getChatString(30, $aChatY[$y][2] + $coordinates[$j], $OcrName)
						If $g_bDebugSetlog = 1 Then
							SetDebugLog("$OcrName: " & $OcrName)
							SetDebugLog("$coordinates: " & $coordinates[$j])
							SetDebugLog("$ClanString: " & $ClanString)
							SetDebugLog("$j: " & $j)
						EndIf
						If $ClanString <> "" And $ClanString <> " " Then ExitLoop
					EndIf
					If $ClanString <> "" Then $BlankSpaces = " "
				Next
			Else
				Local $Yaxis[4] = [40, 36, 36, 39] ; "Latin", "Chinese", "Korean", "Persian"
				If $Alphabets[$i] Then
					If $ClanString = "" Or $ClanString = " " Then
						SetLog("Using OCR to read " & $TextAlphabetsNames[$i] & " alphabets.", $COLOR_ACTION)
						#Au3Stripper_Off
						$ClanString &= $BlankSpaces & Call($AlphabetFunctions[$i], 30, $aChatY[$y][1] + $Yaxis[$i])
						#Au3Stripper_On
						If @error = 0xDEAD And @extended = 0xBEEF Then SetLog("[FriendChallengeCC] Function " & $AlphabetFunctions[$i] & "() had a problem.")
						If $g_bDebugSetlog = 1 Then
							SetDebugLog("$OcrName: " & $OcrName)
							SetDebugLog("$Yaxis: " & $Yaxis[$i])
							SetDebugLog("$ClanString: " & $ClanString)
						EndIf
						If $ClanString <> "" And $ClanString <> " " Then ExitLoop
					EndIf
				EndIf
			EndIf

		Next

		If StringIsSpace($ClanString) Then ContinueLoop
		Local $sString = StringStripWS($ClanString, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
		Setlog("Chat texts : " & $sString, $COLOR_SUCCESS)

		If CheckDonateString($sCondition, $sString) Then
			$sResult = $ClanString
			If $bFast = True Then
				Return $sResult
			EndIf
		EndIf

	Next

	Return $sResult ; IF THE STATE = -1 CHAT TEXT IS RETURNED IN TEXT, ANOTHER BOOLEAN OF RETURN
EndFunc   ;==>ReadChatIA
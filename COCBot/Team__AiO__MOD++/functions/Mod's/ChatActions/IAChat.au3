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
Func ChatScroll()
	Local $sDirectory = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\Sprites"
	Local $aButton = findMultipleQuick($sDirectory, 1, "5, 626, 24, 680", "Scroll", Default, False, 0)
	If IsArray($aButton) and UBound($aButton) > 0 Then
		Local $aClickP = [Random(12, 41, 1), Random($aButton[0][2], 673, 1)]
		ClickP($aClickP)
		Return True
	EndIf
EndFunc   ;==>ChatScroll

Func ReadChatIATest($sCondition = "porque", $bFast = True)
	Setlog(ReadChatIA($sCondition, $bFast))
EndFunc

Func ReadChatIA($sCondition = "hola", $bFast = True)
	Local $vResult = -1
	Local $asFCKeyword = ""
	Local $sDirectory = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\Chat"

	ChatScroll()
	
	If RandomSleep(500) Then Return
	
	Local $aChatY = findMultipleQuick($sDirectory, 11, "259, 49, 269, 677", Default, Default, False, 0)
	
	If Not IsArray($aChatY) Then Return False
	
	_ArraySort($aChatY, 1, 0, 0, 2) ; rearrange order by coor Y
	
	For $i = 0 To UBound($aChatY) - 1

		Local $sOCRString = ""
		
		_ArraySort($g_aIAVar, 1, 0, 0, 1)
		
		For $ii = 0 To UBound($g_aIAVar) - 1
			If _Sleep(15) Then Return
			
			$g_bDnAIO = True ; Team AIO Mod
			
			Switch Int($g_aIAVar[$ii][0])
				Case $ii 
					$sOCRString = getChatStringMod(30, Int($aChatY[$i][2] - 3) + 43, "coc-latinA")
					SetDebugLog("getChatStringMod Latin : " & $sOCRString)
				Case $ii = $g_aIAVar[$ii][0]
					$sOCRString = getChatStringMod(30, Int($aChatY[$i][2] - 3) + 43, "coc-latin-cyr")
					SetDebugLog("getChatStringMod Cyc : " & $sOCRString)
				Case $ii = $g_aIAVar[$ii][0]
					$sOCRString = getChatStringChineseMod(30, Int($aChatY[$i][2] - 3) + 43)
					SetDebugLog("getChatStringChineseMod : " & $sOCRString)
				Case $ii = $g_aIAVar[$ii][0]
					$sOCRString = getChatStringKoreanMod(30, Int($aChatY[$i][2] - 3) + 43)
					SetDebugLog("getChatStringKoreanMod : " & $sOCRString)
				Case $ii = $g_aIAVar[$ii][0]
					$sOCRString = getChatStringPersianMod(30, Int($aChatY[$i][2] - 3) + 43)
					SetDebugLog("getChatStringPersianMod : " & $sOCRString)
			EndSwitch
			
			$g_bDnAIO = False ; Team AIO Mod
			
			SetDebugLog("Chat : " & $sOCRString & " Language : " & $g_aIAVar[$ii][0] & " $i " & $i, $COLOR_INFO)
            If StringLen(StringStripWS($sOCRString, $STR_STRIPALL)) < 2 Then ContinueLoop
			
			If QuickMIS("N1", @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\Sprites\OwnChat", Int($aChatY[$i][1]), Int($aChatY[$i][2] + 3), Int($aChatY[$i][1] + 79), Int($aChatY[$i][2] + 3 + 29)) <> "none" Then ContinueLoop
			
			Local $sString = StringStripWS($sOCRString, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			Local $aString = StringSplit($sString, " ", $STR_NOCOUNT)
		
			For $iii = 0 To UBound($aString) -1
				If StringInStr($sCondition, $aString[$iii]) > 0 Then
					Setlog("Chat AI : " & $sCondition, $COLOR_SUCCESS)
					$g_aIAVar[$ii][1] += 1
					$vResult = $sOCRString
					If $bFast = True Then Return $vResult
				EndIf
			Next
		Next
	Next
	
	Return $vResult ; IF THE STATE = -1 CHAT TEXT IS RETURNED IN TEXT, ANOTHER BOOLEAN OF RETURN
EndFunc   ;==>ReadChatIA

Func getChatStringMod($x_start, $y_start, $language) ; -> Get string chat request - Latin Alphabetic - EN "DonateCC.au3"
	Local $sReturn = ""
	If StringLen(StringStripWS(getOcrAndCapture($language, $x_start, $y_start, 280, 16), $STR_STRIPALL)) > 2 Then
		$sReturn &= $g_sGetOcrMod
		For $i = 1 To 2
			If StringLen(StringStripWS(getOcrAndCapture($language, $x_start, $y_start + ($i * 13), 280, 16), $STR_STRIPALL)) > 2 Then
				$sReturn &= " "
				$sReturn &= $g_sGetOcrMod
			Else
				ExitLoop
			EndIf
		Next
	EndIf
	Return $sReturn
EndFunc   ;==>getChatStringMod

Func getChatStringChineseMod($x_start, $y_start) ; -> Get string chat request - Chinese - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

	If StringLen(StringStripWS(getOcrAndCapture("chinese-bundle", $x_start, $y_start, 160, 14, Default, $bUseOcrImgLoc), $STR_STRIPALL)) > 2 Then
		$sReturn &= $g_sGetOcrMod
		For $i = 1 To 2
			If StringLen(StringStripWS(getOcrAndCapture("chinese-bundle", $x_start, $y_start + ($i * 13), 160, 14, Default, $bUseOcrImgLoc), $STR_STRIPALL)) > 2 Then
				$sReturn &= " "
				$sReturn &= $g_sGetOcrMod
			Else
				ExitLoop
			EndIf
		Next
	EndIf
	Return $sReturn
EndFunc   ;==>getChatStringChineseMod

Func getChatStringKoreanMod($x_start, $y_start) ; -> Get string chat request - Korean - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

	If StringLen(StringStripWS(getOcrAndCapture("korean-bundle", $x_start, $y_start, 160, 14, Default, $bUseOcrImgLoc), $STR_STRIPALL)) > 2 Then
		$sReturn &= $g_sGetOcrMod
		For $i = 1 To 2
			If StringLen(StringStripWS(getOcrAndCapture("korean-bundle", $x_start, $y_start + ($i * 13), 160, 14, Default, $bUseOcrImgLoc), $STR_STRIPALL)) > 2 Then
				$sReturn &= " "
				$sReturn &= $g_sGetOcrMod
			Else
				ExitLoop
			EndIf
		Next
	EndIf
	Return $sReturn
EndFunc   ;==>getChatStringKoreanMod

Func getChatStringPersianMod($x_start, $y_start) ; -> Get string chat request - Persian - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

	If StringLen(StringStripWS(getOcrAndCapture("persian-bundle", $x_start, $y_start, 240, 20, Default, $bUseOcrImgLoc, True), $STR_STRIPALL)) > 2 Then
		$sReturn &= $g_sGetOcrMod
		For $i = 1 To 2
			If StringLen(StringStripWS(getOcrAndCapture("persian-bundle", $x_start, $y_start + ($i * 13), 240, 20, Default, $bUseOcrImgLoc, True), $STR_STRIPALL)) > 2 Then
				$sReturn &= " "
				$sReturn &= $g_sGetOcrMod
			Else
				ExitLoop
			EndIf
		Next
	EndIf

	$sReturn = StringReverse($sReturn)
	$sReturn = StringReplace($sReturn, "A", "ا")
	$sReturn = StringReplace($sReturn, "B", "ب")
	$sReturn = StringReplace($sReturn, "C", "چ")
	$sReturn = StringReplace($sReturn, "D", "د")
	$sReturn = StringReplace($sReturn, "F", "ف")
	$sReturn = StringReplace($sReturn, "G", "گ")
	$sReturn = StringReplace($sReturn, "J", "ج")
	$sReturn = StringReplace($sReturn, "H", "ه")
	$sReturn = StringReplace($sReturn, "R", "ر")
	$sReturn = StringReplace($sReturn, "K", "ک")
	$sReturn = StringReplace($sReturn, "K", "ل")
	$sReturn = StringReplace($sReturn, "M", "م")
	$sReturn = StringReplace($sReturn, "N", "ن")
	$sReturn = StringReplace($sReturn, "P", "پ")
	$sReturn = StringReplace($sReturn, "S", "س")
	$sReturn = StringReplace($sReturn, "T", "ت")
	$sReturn = StringReplace($sReturn, "V", "و")
	$sReturn = StringReplace($sReturn, "Y", "ی")
	$sReturn = StringReplace($sReturn, "L", "ل")
	$sReturn = StringReplace($sReturn, "Z", "ز")
	$sReturn = StringReplace($sReturn, "X", "خ")
	$sReturn = StringReplace($sReturn, "Q", "ق")
	$sReturn = StringReplace($sReturn, ",", ",")
	$sReturn = StringReplace($sReturn, "0", " ")
	$sReturn = StringReplace($sReturn, "1", ".")
	$sReturn = StringReplace($sReturn, "22", "ع")
	$sReturn = StringReplace($sReturn, "44", "ش")
	$sReturn = StringReplace($sReturn, "55", "ح")
	$sReturn = StringReplace($sReturn, "66", "ض")
	$sReturn = StringReplace($sReturn, "77", "ط")
	$sReturn = StringReplace($sReturn, "88", "لا")
	$sReturn = StringReplace($sReturn, "99", "ث")
	$sReturn = StringStripWS($sReturn, 1 + 2)
	Return $sReturn
EndFunc   ;==>getChatStringPersianMod

Func getOcrAndCapture($language, $x_start, $y_start, $width, $height, $removeSpace = Default, $bImgLoc = Default, $bForceCaptureRegion = Default)
	Local $iTry = 0
	Local $iMax = ($g_bDnAIO <> True) ? (8) : (0)
	
	While 1
		$g_sGetOcrMod = _getOcrAndCapture($language, $x_start, $y_start, $width, $height, $removeSpace, $bImgLoc, $bForceCaptureRegion)
		If $iMax = $iTry Or not StringIsSpace($g_sGetOcrMod) Then Return $g_sGetOcrMod
		$iTry += 1
		If _Sleep(250) Then Return
	Wend
	Return ""
EndFunc   ;==>getOcrAndCapture

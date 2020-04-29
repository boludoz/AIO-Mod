; #FUNCTION# ====================================================================================================================
; Name ..........: Chatbot Text read (#-23)
; Description ...: This file is all related to READ CHAT IA (Fast) | Samkie based
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
	Local $aCapture = MultiPSimple(19, 673, 30, 678, Hex(0x70AC2A, 6), 15) ; Incomplete 
	If IsArray($aCapture) And UBound($aCapture) > 1 Then 
		$aCapture[0] = Random(15, 40, 1)
		$aCapture[1] = Int($aCapture[1])
		PureClickP($aCapture)
		Return
	EndIf
	
	Local $aCapture = MultiPSimple(17, 633, 35, 653, Hex(0xDCF984, 6), 15) ; Full
	If IsArray($aCapture) And UBound($aCapture) > 1 Then 
		$aCapture[0] = Random(15, 40, 1)
		$aCapture[1] += Random(1, 10, 1)
		PureClickP($aCapture)
		Return
	EndIf
	
	Return False
EndFunc

Func ReadChatIA(ByRef $sOCRString, $sCondition = -1, $bFast = True)
	Local $bResult = False
	Local $asFCKeyword = ""
	Local $sDirectory = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\Chat"
				
		ChatScroll()
		
		ForceCaptureRegion()
		
		Local $aLastResult = findMultipleQuick($sDirectory, 0, "259, 49, 269, 677", Default, Default, False, 0)
		
		If not IsArray($aLastResult) Then Return False
		
		Local $aChatY[0]
		For $i = 0 To UBound($aLastResult)-1
			_ArrayAdd($aChatY, Int($aLastResult[$i][2] - 3))
		Next

		_ArraySort($aChatY, 0, 0, 0, 1) ; rearrange order by coor Y

		Local $aIAVarTmp = $g_aIAVar
		
		_ArraySort($aIAVarTmp, 0, 0, 0, 1)

		For $i = 0 To UBound($aChatY) - 1
			If MultiPSimple(32, $aChatY[$i], 135, $aChatY[$i] + 33, Hex(0x92ED4D, 6), 20) <> 0 Then
				SetDebugLog("Chat IA : Own talk jumped.", $COLOR_INFO)
				ContinueLoop
			EndIf
			$sOCRString = ""
			For $ii = 0 To UBound($aIAVarTmp) - 1
			If _Sleep($DELAYDONATECC2) Then ExitLoop
				Switch $ii
					Case 0
						$sOCRString = getChatStringMod(30, $aChatY[$i] + 43, "coc-latinA")
						SetDebugLog("getChatStringMod Latin : " & $sOCRString)
								If StringStripWS($sOCRString, $STR_STRIPALL) <> "" Then
								$g_aIAVar[0] += 1
								ExitLoop 1
							EndIf
					Case 1
						$sOCRString = getChatStringMod(30, $aChatY[$i] + 43, "coc-latin-cyr")
						SetDebugLog("getChatStringMod Cyc : " & $sOCRString)
								If StringStripWS($sOCRString, $STR_STRIPALL) <> "" Then
								$g_aIAVar[1] += 1
								ExitLoop 1
							EndIf
					Case 2
						$sOCRString = getChatStringChineseMod(30, $aChatY[$i] + 43)
						SetDebugLog("getChatStringChineseMod : " & $sOCRString)
								If StringStripWS($sOCRString, $STR_STRIPALL) <> "" Then
								$g_aIAVar[2] += 1
								ExitLoop 1
							EndIf
					Case 3
						$sOCRString = getChatStringKoreanMod(30, $aChatY[$i] + 43)
						SetDebugLog("getChatStringKoreanMod : " & $sOCRString)
								If StringStripWS($sOCRString, $STR_STRIPALL) <> "" Then
								$g_aIAVar[3] += 1
								ExitLoop 1
							EndIf
					Case 4
						$sOCRString = getChatStringPersianMod(30, $aChatY[$i] + 43)
						SetDebugLog("getChatStringPersianMod : " & $sOCRString)
								If StringStripWS($sOCRString, $STR_STRIPALL) <> "" Then
								$g_aIAVar[4] += 1
								ExitLoop 1
							EndIf
				EndSwitch
			Next
			
			If StringStripWS($sOCRString, $STR_STRIPALL) = "" Then 
				SetDebugLog("Chat IA : Unable to read Chat!", $COLOR_ERROR)
			Else
					Local $asFCKeyword = StringSplit($sCondition, "|", BitOR($STR_ENTIRESPLIT, $STR_NOCOUNT))
		
					For $j = 0 To UBound($asFCKeyword) - 1
						If StringInStr($sOCRString, $asFCKeyword[$j], 2) Then
							Setlog("Chat IA : " & $asFCKeyword[$j], $COLOR_SUCCESS)
							$bResult = True
							If $bFast = True Then Return $bResult
						EndIf
					Next
				;EndIf
			EndIf
		Next
	Return $bResult ; IF THE STATE = -1 CHAT TEXT IS RETURNED IN TEXT, ANOTHER BOOLEAN OF RETURN
EndFunc   ;==>ReadChatIA

Func getChatStringMod($x_start, $y_start, $language) ; -> Get string chat request - Latin Alphabetic - EN "DonateCC.au3"
	Local $sReturn = ""
		If getOcrAndCapture($language, $x_start, $y_start, 280, 16) <> "" Then
		$sReturn &= $g_sGetOcrMod
			For $i = 1 To 4
				If getOcrAndCapture($language, $x_start, $y_start + ($i*13), 280, 16) <> "" Then
					$sReturn &= " "
					$sReturn &= $g_sGetOcrMod
				Else
				ExitLoop
				EndIf
			Next
		EndIf
	Return $sReturn
EndFunc   ;==>getChatString

Func getChatStringChineseMod($x_start, $y_start) ; -> Get string chat request - Chinese - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

		If getOcrAndCapture("chinese-bundle", $x_start, $y_start, 160, 14, Default, $bUseOcrImgLoc) <> "" Then
		$sReturn &= $g_sGetOcrMod
			For $i = 1 To 4
				If getOcrAndCapture("chinese-bundle", $x_start, $y_start + ($i*13), 160, 14, Default, $bUseOcrImgLoc) <> "" Then
					$sReturn &= " "
					$sReturn &= $g_sGetOcrMod
				Else
				ExitLoop
				EndIf
			Next
		EndIf
	Return $sReturn
EndFunc   ;==>getChatStringChinese

Func getChatStringKoreanMod($x_start, $y_start) ; -> Get string chat request - Korean - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

		If getOcrAndCapture("korean-bundle", $x_start, $y_start, 160, 14, Default, $bUseOcrImgLoc) <> "" Then
		$sReturn &= $g_sGetOcrMod
			For $i = 1 To 4
				If getOcrAndCapture("korean-bundle", $x_start, $y_start + ($i*13), 160, 14, Default, $bUseOcrImgLoc) <> "" Then
					$sReturn &= " "
					$sReturn &= $g_sGetOcrMod
				Else
				ExitLoop
				EndIf
			Next
		EndIf
	Return $sReturn
EndFunc   ;==>getChatStringKorean

Func getChatStringPersianMod($x_start, $y_start) ; -> Get string chat request - Persian - "DonateCC.au3"
	Local $sReturn = ""
	Local $bUseOcrImgLoc = True

		If getOcrAndCapture("persian-bundle", $x_start, $y_start, 240, 20, Default, $bUseOcrImgLoc, True) <> "" Then
		$sReturn &= $g_sGetOcrMod
			For $i = 1 To 4
				If getOcrAndCapture("persian-bundle", $x_start, $y_start + ($i*13), 240, 20, Default, $bUseOcrImgLoc, True) <> "" Then
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
EndFunc   ;==>getChatStringPersian
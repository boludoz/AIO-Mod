; #FUNCTION# ====================================================================================================================
; Name ..........: DissociableFunc
; Description ...: DissociableFunc will open or close the Dissociable.OCR.dll.
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........: Dissociable (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func DissociableFunc($bStart = True)
	Switch $bStart
		Case True
			$g_hLibDissociableOcr = DllOpen($g_sLibDissociableOcrPath)
			If $g_hLibDissociableOcr = -1 Then
				SetLog($g_sDissociableOcrLib & " not found.", $COLOR_ERROR)
				Return False
			EndIf
			SetDebugLog($g_sDissociableOcrLib & " opened.")
		Case False
			DllClose($g_hLibDissociableOcr)
			SetDebugLog($g_sDissociableOcrLib & " closed.")
	EndSwitch
EndFunc   ;==>DissociableFunc

Func DllCallDOCR($sFunc, $ReturnType, $sType1 = Default, $vParam1 = Default, $sType2 = Default, $vParam2 = Default)
	; SetLog("DOCR: sFunc: " & $sFunc & " - Return Type: " & $ReturnType & " - sType1: " & $sType1 & " - vParam1: " & $vParam1 & " - sType2: " & $sType2 & " - vParam2: " & $vParam2)
	; suspend Android now
	Local $bWasSuspended = SuspendAndroid()

	Local $aResult = DllCall($g_hLibDissociableOcr, $ReturnType, $sFunc, $sType1, $vParam1, $sType2, $vParam2)
	If @error Then
		SetLog("DOCR Issue | Fail 0x0: " & @error)
		
		Sleep(100)
		
		Local $aResult = DllCall($g_hLibDissociableOcr, $ReturnType, $sFunc, $sType1, $vParam1, $sType2, $vParam2)
		If @error Then
			SetLog("DOCR Issue | Fail 0x1: " & @error)
			If $bWasSuspended Then ResumeAndroid()
			Return ""
		EndIf
	EndIf
	
	
	If IsArray($aResult) Then 
		If StringInStr($aResult[0], "ERROR") > 0 Then
			SetLog("DOCR Issue | Fail 0x2. | " & $aResult[0], $COLOR_ERROR)
			If $bWasSuspended Then ResumeAndroid()
			Return ""
		EndIf
		If $bWasSuspended Then ResumeAndroid()
		Return $aResult[0]
	EndIf
	
	SetLog("DOCR Issue: Unknown DllCallDOCR Return: " & $aResult)
	If $bWasSuspended Then ResumeAndroid()
	Return ""
EndFunc   ;==>DllCallDOCR

#cs
Func _DllCallDOCR($sFunc, $ReturnType, $sType1 = Default, $vParam1 = Default, $sType2 = Default, $vParam2 = Default)
    If $sType1 = Default Then Return DllCall($g_hLibDissociableOcr, $ReturnType, $sFunc)
    If $sType2 <> Default Then Return DllCall($g_hLibDissociableOcr, $ReturnType, $sFunc, $sType1, $vParam1, $sType2, $vParam2)
    If $sType1 <> Default Then Return DllCall($g_hLibDissociableOcr, $ReturnType, $sFunc, $sType1, $vParam1)
    Return -1
EndFunc
#ce

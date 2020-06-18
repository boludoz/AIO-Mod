; #FUNCTION# ====================================================================================================================
; Name ..........: SetSleep
; Description ...: Randomizes deployment wait time
; Syntax ........: SetSleep($iType)
; Parameters ....: $iType                - Flag for type return desired.
; Return values .: None
; Author ........:
; Modified ......: KnowJack (06-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom sleep Drop - Team AIO Mod++
Func SetSleep($iType)
	If IsKeepClicksActive() = True Then Return 128 ; fast bulk deploy
	Local $iOffset0 = Round(128 / 2)
	Local $iOffset1 = Round(416 / 2)
	If $g_bAndroidAdbClick = True Then
		; adjust for slow ADB clicks the delay factor
		$iOffset0 = Round(128 / 2) ; Based on humane offset.
		$iOffset1 = Round(416 / 2) ; Based on humane offset.
	EndIf

	Local $iReturn = Random(1, 10) * Int(($iType = 0) ? ($iOffset0) : ($iOffset1))
	Local $iCmbValue = $g_aiAttackAlgorithm[$DB]
	
	If ((IsArray($g_bChkEnableRandom)) And (IsArray($g_iDeployDelay)) And (IsArray($g_iDeployWave))) Then
		If Not ((UBound($g_bChkEnableRandom) > 2) And (UBound($g_iDeployDelay) > 2) And (UBound($g_iDeployWave) > 2)) Then
			SetDebugLog("SetSleep | UBound fail on SetSleep.")
			Return Round(Random(($iReturn*80)/100, ($iReturn*120)/100, 1))
		EndIf
	Else
		SetDebugLog("SetSleep | IsArray fail on SetSleep.")
		Return Round(Random(($iReturn*80)/100, ($iReturn*120)/100, 1))
	EndIf

	SetDebugLog("SetSleep Base : " & $iReturn)

	If $g_iMatchMode = $DB Then
		If (($g_bChkEnableRandom[0]) And ($iCmbValue = 0)) Then ; DB + Standard
			$iReturn = ($iType = 0) ? ($iOffset0 * Int($g_iDeployDelay[0])) : ($iOffset1 * Int($g_iDeployWave[0]))
			SetDebugLog("SetSleep Mod + DB + Standard : " & $iReturn)
		ElseIf (($g_bChkEnableRandom[1]) And ($iCmbValue = 2)) Then ; DB + Smart farm
			$iReturn = ($iType = 0) ? ($iOffset0 * Int($g_iDeployDelay[1])) : ($iOffset1 * Int($g_iDeployWave[1]))
			SetDebugLog("SetSleep Mod + DB + Smart farm : " & $iReturn)
		EndIf
	EndIf

	Return Round(Random(($iReturn*80)/100, ($iReturn*120)/100, 1))
EndFunc   ;==>SetSleep
#EndRegion

; #FUNCTION# ====================================================================================================================
; Name ..........: _SleepAttack
; Description ...: Version of _Sleep() used in attack code so active keep clicks mode doesn't slow down bulk deploy
; Syntax ........: see _Sleep
; Parameters ....: see _Sleep
; Return values .: see _Sleep
; Author ........: cosote (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _SleepAttack($iDelay, $iSleep = True)
	If Not $g_bRunState Then
		ResumeAndroid()
		Return True
	EndIf
	If IsKeepClicksActive() Then Return False
	Return _Sleep(Random(($iDelay*80)/100, ($iDelay*120)/100, 1), $iSleep) ; Team AIO Mod++
EndFunc   ;==>_SleepAttack

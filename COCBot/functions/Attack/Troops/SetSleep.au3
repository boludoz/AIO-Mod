; #FUNCTION# ====================================================================================================================
; Name ..........: SetSleep
; Description ...: Randomizes deployment wait time
; Syntax ........: SetSleep($type)
; Parameters ....: $type                - Flag for type return desired.
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
Func SetSleep($type)
	If IsKeepClicksActive() = True Then Return 0 ; fast bulk deploy
	Local $factor0 = 10
	Local $factor1 = 100
	If $g_bAndroidAdbClick = True Then
		; adjust for slow ADB clicks the delay factor
		$factor0 = 10
		$factor1 = 100
	EndIf

	Local $iReturn = Random(1, 10) * Int(($type = 0) ? ($factor0) : ($factor1))
	SetDebugLog("SetSleep Base : " & $iReturn)
	Local $iCmbValue = $g_aiAttackAlgorithm[$DB]

	If $g_iMatchMode = $DB Then
		If BitAND($g_bChkEnableRandom[0], $iCmbValue = 0) Then ; DB + Standard
			;	0	-	UnitDelay - $g_iDeployDelay[0]
			;	1	-	WaveDelay - $g_iDeployWave[0]
			$iReturn = ($type = 0) ? ($factor0 * Int($g_iDeployDelay[0])) : ($factor1 * Int($g_iDeployWave[0]))
			SetDebugLog("SetSleep Mod + DB + Standard : " & $iReturn)
			
		ElseIf BitAND($g_bChkEnableRandom[1], $iCmbValue = 2) Then ; DB + Smart farm
			;	0	-	UnitDelay - $g_iDeployDelay[1]
			;	1	-	WaveDelay - $g_iDeployWave[1]
			$iReturn = ($type = 0) ? ($factor0 * Int($g_iDeployDelay[1])) : ($factor1 * Int($g_iDeployWave[1]))
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

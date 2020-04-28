; #FUNCTION# ====================================================================================================================
; Name ..........: _Sleep
; Description ...:
; Syntax ........: _Sleep($iDelay[, $iSleep = True])
; Parameters ....: $iDelay              - an integer value.
;                  $iSleep              - [optional] an integer value. Default is True. unused and deprecated
;                  $CheckRunState      - Exit and returns True if $g_bRunState is False
; Return values .: True when $g_bRunState is False otherwise True (also True if $CheckRunState=False)
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func _Sleep($iDelay = $DELAYSLEEP, $iSleep = True, $CheckRunState = True, $SleepWhenPaused = True)
	Local $iBegin = __TimerInit()
	Local $iRemaining = $iDelay - __TimerDiff($iBegin)

	Static $hTimer_SetTime = 0
	Static $hTimer_PBRemoteControlInterval = 0
	;Static $hTimer_PBDeleteOldPushesInterval = 0
	Static $hTimer_EmptyWorkingSetAndroid = 0
	Static $hTimer_EmptyWorkingSetBot = 0

	#Region - AIO ++ - Random / Custom delay
	Local $iOri = 100
	If $g_bUseSleep and not BitAND($g_bNoAttackSleep, $g_bAttackActive) Then
        $iOri = Int($iOri + ($iOri * $g_iIntSleep) / 100)
		If $g_bUseRandomSleep Then $iOri = Random(($iOri * 90)/100, ($iOri * 110)/100)
	EndIf
	$iOri /= 100
	;Setlog($iOri)
    #EndRegion

	debugGdiHandle("_Sleep")
	CheckBotRequests() ; check if bot window should be moved, minized etc.

	If $g_bCriticalMessageProcessing = False Then

		If $g_bMoveDivider Then MoveDivider()

		If $iDelay > 0 And __TimerDiff($g_hTxtLogTimer) >= $g_iTxtLogTimerTimeout Then

			; Notify stuff
				If __TimerDiff($hTimer_PBRemoteControlInterval) * $iOri >= $g_iPBRemoteControlInterval Or ($hTimer_PBRemoteControlInterval = 0 And $g_bNotifyRemoteEnable) Then
					NotifyRemoteControl()
					$hTimer_PBRemoteControlInterval = __TimerInit()
				EndIf
			
			; Android & Bot Stuff
				If (($g_iEmptyWorkingSetAndroid > 0 And __TimerDiff($hTimer_EmptyWorkingSetAndroid) >= $g_iEmptyWorkingSetAndroid * Int(1000 * $iOri)) Or $hTimer_EmptyWorkingSetAndroid = 0) And $g_bRunState And TestCapture() = False Then
					If IsArray(getAndroidPos(True)) = 1 Then _WinAPI_EmptyWorkingSet(GetAndroidPid()) ; Reduce Working Set of Android Process
					$hTimer_EmptyWorkingSetAndroid = __TimerInit()
				EndIf
				
				If ($g_iEmptyWorkingSetBot > 0 And __TimerDiff($hTimer_EmptyWorkingSetBot) >= $g_iEmptyWorkingSetBot * Int(1000 * $iOri)) Or $hTimer_EmptyWorkingSetBot = 0 Then
					ReduceBotMemory(False)
					$hTimer_EmptyWorkingSetBot = __TimerInit()
				EndIf

			CheckPostponedLog()

		EndIf
	EndIf

	For $i = 0 To Round($iDelay / $iOri)
	If $CheckRunState = True And $g_bRunState = False Then
			ResumeAndroid()
			Return True
		EndIf
		If $g_bCriticalMessageProcessing = False Then
			If $g_bBotPaused And $SleepWhenPaused And $g_bTogglePauseAllowed Then TogglePauseSleep() ; Bot is paused
			If $g_bTogglePauseUpdateState Then TogglePauseUpdateState("_Sleep") ; Update Pause GUI states
			If $g_bMakeScreenshotNow = True Then MakeScreenshot($g_sProfileTempPath, ($g_bScreenshotPNGFormat = False) ? ("jpg") : ("png"))
			If __TimerDiff($g_hTxtLogTimer) >= $g_iTxtLogTimerTimeout * Int(1000 * $iOri) Then
				If $g_bRunState And Not $g_bSearchMode And Not $g_bBotPaused And ($hTimer_SetTime = 0 Or __TimerDiff($hTimer_SetTime) >=  Int(750 * $iOri)) Then
					SetTime()
					$hTimer_SetTime = __TimerInit()
				EndIf
				AndroidEmbedCheck()
				AndroidShieldCheck()
				CheckPostponedLog()
			EndIf
		EndIf
		$iRemaining = $iDelay - __TimerDiff($iBegin)
		CheckBotRequests() ; check if bot window should be moved
		If $iRemaining < 100 * $iOri Then ExitLoop
		Sleep(100 * $iOri)
	Next
	Sleep($iDelay - __TimerDiff($iBegin))

	Return False
EndFunc   ;==>_Sleep

Func _SleepMicro($iMicroSec)
	DllStructSetData($g_hStruct_SleepMicro, "time", $iMicroSec * -10)
	DllCall($g_hLibNTDLL, "dword", "ZwDelayExecution", "int", 0, "ptr", $g_pStruct_SleepMicro)
EndFunc   ;==>_SleepMicro

Func _SleepMilli($iMilliSec)
	_SleepMicro(Int($iMilliSec * 1000))
EndFunc   ;==>_SleepMilli

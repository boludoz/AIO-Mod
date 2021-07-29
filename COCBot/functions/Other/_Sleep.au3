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

Func _Sleep($iDelay, $iSleep = True, $CheckRunState = True, $SleepWhenPaused = True)
	Static $hTimer_SetTime = 0
	Static $hTimer_PBRemoteControlInterval = 0
	Static $hTimer_EmptyWorkingSetAndroid = 0
	Static $hTimer_EmptyWorkingSetBot = 0
	Static $b_Sleep_Active = False
	Local $iBegin = __TimerInit()
	
	; Custom sleep - Team AIO Mod++ (inspired in Samkie)
	Local $iNewDelay = Round($iDelay * ($g_iInputAndroidSleep / 100)) + $iDelay

;~ 	If $b_Sleep_Active = True Then
;~ 	EndIf

	$b_Sleep_Active = True
	debugGdiHandle("_Sleep")
	CheckBotRequests()
	If SetCriticalMessageProcessing() = False Then
		If $g_bMoveDivider Then
			MoveDivider()
			$g_bMoveDivider = False
		EndIf
		If $iNewDelay > 0 And __TimerDiff($g_hTxtLogTimer) >= $g_iTxtLogTimerTimeout Then
			If __TimerDiff($hTimer_PBRemoteControlInterval) >= $g_iPBRemoteControlInterval Or ($hTimer_PBRemoteControlInterval = 0 And $g_bNotifyRemoteEnable) Then
				NotifyRemoteControl()
				$hTimer_PBRemoteControlInterval = __TimerInit()
			EndIf
			If (($g_iEmptyWorkingSetAndroid > 0 And __TimerDiff($hTimer_EmptyWorkingSetAndroid) >= $g_iEmptyWorkingSetAndroid * 1000) Or $hTimer_EmptyWorkingSetAndroid = 0) And $g_bRunState And TestCapture() = False Then
				If IsArray(getAndroidPos(True)) = 1 Then _WinAPI_EmptyWorkingSet(GetAndroidPid())
				$hTimer_EmptyWorkingSetAndroid = __TimerInit()
			EndIf
			If ($g_iEmptyWorkingSetBot > 0 And __TimerDiff($hTimer_EmptyWorkingSetBot) >= $g_iEmptyWorkingSetBot * 1000) Or $hTimer_EmptyWorkingSetBot = 0 Then
				ReduceBotMemory(False)
				$hTimer_EmptyWorkingSetBot = __TimerInit()
			EndIf
			CheckPostponedLog()
			If BotCloseRequestProcessed() Then
				BotClose()
				$b_Sleep_Active = False
				Return True
			EndIf
		EndIf
	EndIf
	If $CheckRunState And Not $g_bRunState Then
		ResumeAndroid()
		$b_Sleep_Active = False
		Return True
	EndIf
	Local $iRemaining = $iNewDelay - __TimerDiff($iBegin)
	While $iRemaining > 0
		DllCall($g_hLibNTDLL, "dword", "ZwYieldExecution")
		If $CheckRunState = True And $g_bRunState = False Then
			ResumeAndroid()
			$b_Sleep_Active = False
			Return True
		EndIf
		If SetCriticalMessageProcessing() = False Then
			If $g_bBotPaused And $SleepWhenPaused And $g_bTogglePauseAllowed Then TogglePauseSleep()
			If $g_bTogglePauseUpdateState Then TogglePauseUpdateState("_Sleep")
			If $g_bMakeScreenshotNow = True Then
				If $g_bScreenshotPNGFormat = False Then
					MakeScreenshot($g_sProfileTempPath, "jpg")
				Else
					MakeScreenshot($g_sProfileTempPath, "png")
				EndIf
			EndIf
			If __TimerDiff($g_hTxtLogTimer) >= $g_iTxtLogTimerTimeout Then
				If $g_bRunState And Not $g_bSearchMode And Not $g_bBotPaused And ($hTimer_SetTime = 0 Or __TimerDiff($hTimer_SetTime) >= 750) Then
					SetTime()
					$hTimer_SetTime = __TimerInit()
				EndIf
				AndroidEmbedCheck()
				AndroidShieldCheck()
				CheckPostponedLog()
			EndIf
		EndIf
		$iRemaining = $iNewDelay - __TimerDiff($iBegin)
		If $iRemaining >= $DELAYSLEEP Then
			_SleepMilli($DELAYSLEEP)
		Else
			_SleepMilli($iRemaining)
		EndIf
		CheckBotRequests()
	WEnd
	$b_Sleep_Active = False
	Return False
EndFunc   ;==>_Sleep

Func _SleepMicro($iMicroSec)
	DllStructSetData($g_hStruct_SleepMicro, "time", $iMicroSec * -10)
	DllCall($g_hLibNTDLL, "dword", "ZwDelayExecution", "int", 0, "ptr", $g_pStruct_SleepMicro)
EndFunc   ;==>_SleepMicro

Func _SleepMilli($iMilliSec)
	_SleepMicro(Int($iMilliSec * 1000))
EndFunc   ;==>_SleepMilli

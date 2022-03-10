; #FUNCTION# ====================================================================================================================
; Name ..........: waitMainScreen
; Description ...: Waits 5 minutes for the pixel of mainscreen to be located, checks for obstacles every 2 seconds.  After five minutes, will try to restart bluestacks.
; Syntax ........: waitMainScreen()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: KnowJack (08-2015), TheMaster1st (09-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func waitMainScreen() ;Waits for main screen to popup
	If Not $g_bRunState Then Return
	Local $iCount
	SetLog("Waiting for Main Screen", $COLOR_INFO) ; Custom - Team AIO Mod++
	$iCount = 0
	Local $aPixelToCheck = $g_bStayOnBuilderBase ? $aIsOnBuilderBase : $aIsMain
	For $i = 0 To 105 ;105*2000 = 3.5 Minutes
		If Not $g_bRunState Then Return
		SetDebugLog("waitMainScreen ChkObstl Loop = " & $i & ", ExitLoop = " & $iCount, $COLOR_DEBUG) ; Debug stuck loop
		$iCount += 1
		If Mod($iCount, 20) = 0 Then CloseEmulatorForce(True)
		SetLog("[" & $iCount & "] " & "Waiting for main screen.", $COLOR_ACTION) ; Custom - Team AIO Mod++
		Local $hWin = $g_hAndroidWindow
		If TestCapture() = False Then
			If WinGetAndroidHandle() = 0 Then
				If $hWin = 0 Then
					OpenAndroid(True)
				Else
					RebootAndroid()
				EndIf
				Return
			EndIf
			getBSPos() ; Update $g_hAndroidWindow and Android Window Positions
		EndIf
		_CaptureRegion()
		If _CheckPixel($aPixelToCheck, $g_bNoCapturePixel, Default, "waitMainScreen") Then ;Checks for Main Screen
			SetDebugLog("Screen cleared, WaitMainScreen exit", $COLOR_DEBUG)
			Return
		Else
			If Not TestCapture() And _Sleep($DELAYWAITMAINSCREEN1) Then Return
			If checkObstacles() Then $i = 0 ;See if there is anything in the way of mainscreen
		EndIf
		If Mod($i, 5) = 0 Then ;every 10 seconds
			If $g_bDebugImageSave Then SaveDebugImage("WaitMainScreen_", False)
		EndIf
		If ($i > 105) Or ($iCount > 120) Then ExitLoop ; If CheckObstacles forces reset, limit total time to 4 minutes

		If TestCapture() Then
			Return "Main screen not available"
		EndIf

	Next
	
	
	#Region - Custom fix - Team AIO Mod++
	; Credits : xbebenk
	SetLog("RESTART COC: Wait MainScreen Timout", $COLOR_ERROR)
	CloseEmulatorForce(True)
	CloseCoC() ;only close coc
	_RestartAndroidCoC(False, False, True, 0, 0, True) ;start coc, not updating shared_prefs
	_SleepStatus(10000) ;give time for coc loading
	#Region - Custom fix - Team AIO Mod++

EndFunc   ;==>waitMainScreen

Func waitMainScreenMini()
	If Not $g_bRunState Then Return
	Local $iCount = 0
	Local $hTimer = __TimerInit()
	SetDebugLog("waitMainScreenMini")
	If TestCapture() = False Then getBSPos() ; Update Android Window Positions
	SetLog("Waiting for Main Screen after " & $g_sAndroidEmulator & " restart", $COLOR_INFO)
	Local $aPixelToCheck = $g_bStayOnBuilderBase ? $aIsOnBuilderBase : $aIsMain
	For $i = 0 To 105 ; Like waitMainScreen
		If Not $g_bRunState Then Return
		If Not TestCapture() And WinGetAndroidHandle() = 0 Then ExitLoop ; sets @error to 1
		SetDebugLog("waitMainScreenMini ChkObstl Loop = " & $i & " ExitLoop = " & $iCount, $COLOR_DEBUG) ; Debug stuck loop
		$iCount += 1
		SetLog("[" & $iCount & "] " & "Waiting for main screen.", $COLOR_ACTION) ; Custom - Team AIO Mod++
		_CaptureRegion()
		If Not _CheckPixel($aPixelToCheck, $g_bNoCapturePixel) Then ;Checks for Main Screen
			If Not TestCapture() And _Sleep(1000) Then Return
			If CheckObstacles() Then $i = 0 ;See if there is anything in the way of mainscreen
		Else
			SetLog("CoC main window took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_SUCCESS)
			Return
		EndIf
		_StatusUpdateTime($hTimer, "Main Screen")
		If Mod($iCount, 15) = 0 Then CloseEmulatorForce(True)
		If ($i > 105) Or ($iCount > 120) Then ExitLoop ; If CheckObstacles forces reset, limit total time to 6 minute before Force restart BS
		If TestCapture() Then
			Return "Main screen not available"
		EndIf
	Next
	Return SetError(1, 0, -1)
EndFunc   ;==>waitMainScreenMini

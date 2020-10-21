;
; #FUNCTION# ====================================================================================================================
; Name ..........: KillProcess
; Description ...:
; Syntax ........: KillProcess($iPid, $sProcess_info = "", $iAttempts = 3)
; Parameters ....: $iPid, Process Id
;                : $sProcess_info, additional process info like process filename or full command line for Debug Log
;                : $iAttempts, number of attempts
; Return values .: True if process was killed, false if not or _Sleep interrupted
; Author ........: Cosote (Dec-2015), Team AIO Mod++ (Sep-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom fix - Team AIO Mod++
Func KillProcess($iPid, $sProcess_info = "", $iAttempts = 3)
	If Number($iPid) < 1 Or @error Then Return False ; Prevent bluescreen - Team AIO Mod++
	Local $iCount = 0
	If $sProcess_info <> "" Then $sProcess_info = ", " & $sProcess_info
	Do
		If ProcessClose($iPid) = 1 Then
			SetDebugLog("KillProcess(" & $iCount & "): PID = " & $iPid & " closed" & $sProcess_info)
		Else
			SetDebugLog("Process close error: " & @error)
		EndIf
		If ProcessExists($iPid) Then
			ShellExecute(@WindowsDir & "\System32\taskkill.exe", "-f -t -pid " & $iPid, "", Default, @SW_HIDE)
			If _Sleep(1000) Then Return False
			If ProcessExists($iPid) = 0 Then
				SetDebugLog("KillProcess(" & $iCount & "): PID = " & $iPid & " killed (using taskkill -f -t)" & $sProcess_info)
			EndIf		
		EndIf
		$iCount += 1
	Until ($iCount > $iAttempts) Or not ProcessExists($iPid)
	If ProcessExists($iPid) Then
		SetDebugLog("KillProcess(" & $iCount & "): PID = " & $iPid & " failed to kill" & $sProcess_info, $COLOR_ERROR)
		Return False
	EndIf
	Return True
EndFunc   ;==>KillProcess
#EndRegion - Custom fix - Team AIO Mod++

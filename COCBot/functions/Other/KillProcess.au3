;
; #FUNCTION# ====================================================================================================================
; Name ..........: KillProcess
; Description ...:
; Syntax ........: KillProcess($iPid, $sProcess_info = "", $iAttempts = 3)
; Parameters ....: $iPid, Process Id
;                : $sProcess_info, additional process info like process filename or full command line for Debug Log
;                : $iAttempts, number of attempts
; Return values .: True if process was killed, false if not or _Sleep interrupted
; Author ........: Cosote (Dec-2015), Boldina ! (Sep-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func KillProcess($iPid, $sProcess_info = "", $iAttempts = 3)
	If $iPid < 1 Then Return False
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

;  ProcessFindBy($g_sAndroidAdbPath), $sPort
Func ProcessFindBy($sPath = "", $sCommandline = "")
	$sPath = StringReplace($sPath, "\\", "\")
	If StringIsSpace($sPath) And StringIsSpace($sCommandline) Then Return -1
	
	Local $bGetProcessPath, $bGetProcessCommandLine, $bFail, $aReturn[0]
	Local $aiProcessList = ProcessList()
	If @error Then Return -2
	For $i = 2 To UBound($aiProcessList)-1
		$bGetProcessPath = StringInStr(_WinAPI_GetProcessFileName($aiProcessList[$i][1]), $sPath) > 0
		$bGetProcessCommandLine = StringInStr(_WinAPI_GetProcessCommandLine($aiProcessList[$i][1]), $sCommandline) > 0
		Select 
			Case $bGetProcessPath And $bGetProcessCommandLine
				If Not StringIsSpace($sPath) And Not StringIsSpace($sCommandline) Then 
					_ArrayAdd($aReturn, Int($aiProcessList[$i][1]), $ARRAYFILL_FORCE_INT)
				EndIf
			Case $bGetProcessPath And Not $bGetProcessCommandLine
				If StringIsSpace($sCommandline) Then
					_ArrayAdd($aReturn, Int($aiProcessList[$i][1]), $ARRAYFILL_FORCE_INT)
				EndIf
			Case Not $bGetProcessPath And $bGetProcessCommandLine
				If StringIsSpace($sPath) Then
					_ArrayAdd($aReturn, Int($aiProcessList[$i][1]), $ARRAYFILL_FORCE_INT)
				EndIf
		EndSelect
	Next
	Return $aReturn
EndFunc
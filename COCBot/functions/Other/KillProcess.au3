;
; #FUNCTION# ====================================================================================================================
; Name ..........: KillProcess
; Description ...:
; Syntax ........: KillProcess($pid, $process_info = "", $attempts = 3)
; Parameters ....: $pid, Process Id
;                : $process_info, additional process info like process filename or full command line for Debug Log
;                : $attempts, number of attempts
; Return values .: True if process was killed, false if not or _Sleep interrupted
; Author ........: Cosote (Dec-2015)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func KillProcess($iPID, $process_info = "", $attempts = 3)
	If StringIsSpace($process_info) Then $process_info = "adb"
	Local $strComputer = "."
	Local $objWMI, $colResults, $objItem, $intCount, $answer, $a, $b = ""
	If Not StringIsSpace($process_info) Then
		$b = StringSplit($process_info, '\', $STR_NOCOUNT)
		If @error then 
			$b = $process_info
		Else
			$b = $a[UBound($a)-1]
		EndIf
		If StringIsSpace($b) Then Return False
		If StringInStr(_ProcessGetName($iPID), $a) > 0 Then
			For $i = 1 To $attempts
				$objWMI = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
				$colResults = $objWMI.ExecQuery("Select * from Win32_Process WHERE ProcessID = '" & $iPID & "'")
				For $objItem in $colResults
					$objItem.Terminate()
				Next
				If Not ProcessExists($iPID) Then Return True
			Next
		EndIf
	Else
		For $i = 1 To $attempts
			$objWMI = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
			$colResults = $objWMI.ExecQuery("Select * from Win32_Process WHERE ProcessID = '" & $iPID & "'")
			For $objItem in $colResults
				$objItem.Terminate()
			Next
			If Not ProcessExists($iPID) Then Return True
		Next
	EndIf
	
	SetDebugLog("KillProcess(" & $attempts & "): PID = " & $iPID & " failed to kill" & $process_info, $COLOR_ERROR)
	Return False
EndFunc   ;==>KillProcess
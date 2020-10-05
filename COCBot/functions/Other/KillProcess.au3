;
; #FUNCTION# ====================================================================================================================
; Name ..........: KillProcess
; Description ...:
; Syntax ........: KillProcess($pid, $process_info = "", $attempts = 3)
; Parameters ....: $pid, Process Id
;                : $process_info, additional process info like process filename or full command line for Debug Log
;                : $attempts, number of attempts
; Return values .: True if process was killed, false if not or _Sleep interrupted
; Author ........: Cosote (Dec-2015), Boldina ! (Sep-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func KillProcess($iPID, $sProcess_info = "", $iAttempts = 3)
	If Not IsInt($iPID) Then Return False
	Local $i = 0, $iError = 0

	If Number($iPID) > 0 Then
		For $i = 1 To $iAttempts
			ProcessClose($iPID)
			$iError = @error
			If @error Then 
				SetDebugLog("KillProcess(" & $i & "): PID = " & $iPID & ", Error = " & $iError & ", Process = " & $sProcess_info, $COLOR_ERROR)
				ContinueLoop
			EndIf
			If Not ProcessExists($iPID) Then 
				SetDebugLog("KillProcess(" & $i & "): PID = " & $iPID & " killed " & $sProcess_info)
				Return True
			EndIf
		Next
	EndIf
	SetDebugLog("KillProcess(" & $i & "): PID = " & $iPID & " failed to kill " & $sProcess_info, $COLOR_ERROR)
	Return False
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
; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot Updater
; Description ...: This file contens the Sequence that runs all MBR Bot
; Author ........: Boldina ! (2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Update without shuttle! (Inspired by Elon Musk!). This restores your session.
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#NoTrayIcon
#RequireAdmin
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/rsln
#AutoIt3Wrapper_Change2CUI=y
;#pragma compile(Console, true)
#pragma compile(ProductName, AIOMod.Updater)
#pragma compile(Out, AIOMod.Updater.exe) ; Required

; Enforce variable declarations
Opt("MustDeclareVars", 1)

#include <APIErrorsConstants.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>
#include <Misc.au3>
#include <ColorConstants.au3>
#include <Date.au3>
#include <Array.au3>
Global $hNtDll = DllOpen("ntdll.dll")

Global Const $COLOR_ERROR = $COLOR_RED ; Error messages
Global Const $COLOR_WARNING = $COLOR_MAROON ; Warning messages
Global Const $COLOR_INFO = $COLOR_BLUE ; Information or Status updates for user
Global Const $COLOR_SUCCESS = 0x006600 ; Dark Green, Action, method, or process completed successfully
Global Const $COLOR_DEBUG = $COLOR_PURPLE ; Purple, basic debug color
Global $g_sModVersion = "v0.0.0"

#Region - Custom - Team AIO Mod++
#include <WinAPISysWin.au3>
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

Global $g_bDebugSetlog = False

Global $g_bFuseMsg = False

UpdateMod()

; #FUNCTION# ====================================================================================================================
; Name ..........: Time
; Description ...: Gives the time in '[00:00:00 AM/PM]' format
; Syntax ........: Time()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func Time() ;Gives the time in '[00:00:00 AM/PM]' format
	Return "[" & _NowTime(3) & "] "
EndFunc   ;==>Time

Func TimeDebug() ;Gives the time in '[14:00:00.000]' format
	Return "[" & @YEAR & "-" & @MON & "-" & @MDAY & " " & _NowTime(5) & "." & @MSEC & "] "
EndFunc   ;==>TimeDebug

Func GetLastVersion($txt)
	Return _StringBetween($txt, '"tag_name":"', '","')
EndFunc   ;==>GetLastVersion

Func GetLastChangeLog($txt)
	Return _StringBetween($txt, '"body":"', '"}')
EndFunc   ;==>GetLastChangeLog

#include <String.au3>

Func GetVersionNormalized($VersionString, $Chars = 5)
	If StringLeft($VersionString, 1) = "v" Then $VersionString = StringMid($VersionString, 2)
	Local $a = StringSplit($VersionString, ".", 2)
	Local $i
	For $i = 0 To UBound($a) - 1
		If StringLen($a[$i]) < $Chars Then $a[$i] = _StringRepeat("0", $Chars - StringLen($a[$i])) & $a[$i]
	Next
	Return _ArrayToString($a, ".")
EndFunc   ;==>GetVersionNormalized


Func UpdateMod()
	Local $g_sMBRDir = @ScriptDir
	$g_sMBRDir = StringReplace($g_sMBRDir, "\lib\ModLibs\Updater", "")
	If $g_bFuseMsg = True Then Return
	Local $bUpdate = False
	Local $iNewVersion
	; If not $g_bCheckVersion Then Return

	If FileExists(@ScriptDir & "\BigDog.inf") Then

		; Open the file for reading and store the handle to a variable.
		Local $hFileOpen = FileOpen(@ScriptDir & "\BigDog.inf", $FO_READ)
		If $hFileOpen = -1 Then
			SetLog("An error occurred when reading the file.")
			Return False
		EndIf

		; Read the fist line of the file using the handle returned by FileOpen.
		Local $sFileRead = FileReadLine($hFileOpen, 1)

		; Close the handle returned by FileOpen.
		FileClose($hFileOpen)

		If StringInStr($sFileRead, "v") Then $g_sModVersion = $sFileRead
	EndIf

	; Get the last Version from API
	Local $g_sBotGitVersion = ""
	Local $sCorrectStdOut = InetRead("https://api.github.com/repos/boludoz/AIO-Mod/releases/latest")
	If @error Or $sCorrectStdOut = "" Then Return
	Local $Temp = BinaryToString($sCorrectStdOut)

	If $Temp <> "" And Not @error Then

		Local $g_aBotVersionN = StringSplit($g_sModVersion, " ", 2)
		Local $g_iBotVersionN
		If @error Then
			$g_iBotVersionN = StringReplace($g_sModVersion, "v", "")
		Else
			$g_iBotVersionN = StringReplace($g_aBotVersionN[0], "v", "")
		EndIf
		Local $version = GetLastVersion($Temp)
		$g_sBotGitVersion = StringReplace($version[0], "v", "")
		SetDebugLog("Last GitHub version is " & $g_sBotGitVersion)
		SetDebugLog("Your version is " & $g_iBotVersionN)

		If _VersionCompare($g_iBotVersionN, $g_sBotGitVersion) = -1 Then
;~ 			If not $bSilent Then SetLog("WARNING, YOUR AIO VERSION (" & $g_iBotVersionN & ") IS OUT OF DATE.", $COLOR_INFO)
;~ 			$g_bNewModAvailable = True
			Local $ChangelogTXT = GetLastChangeLog($Temp)
			Local $Changelog = StringSplit($ChangelogTXT[0], '\r\n', $STR_ENTIRESPLIT + $STR_NOCOUNT)
			For $i = 0 To UBound($Changelog) - 1
;~ 				If not $bSilent Then SetLog($Changelog[$i] )
			Next
			; PushMsg("Update")
			$bUpdate = True
		ElseIf _VersionCompare($g_iBotVersionN, $g_sBotGitVersion) = 0 Then
;~ 			If not $bSilent Then SetLog("WELCOME CHIEF, YOU HAVE THE LATEST AIO MOD VERSION", $COLOR_SUCCESS)
		Else
;~ 			If not $bSilent Then SetLog("YOU ARE USING A FUTURE VERSION CHIEF!", $COLOR_ACTION)
		EndIf
	Else
		SetDebugLog($Temp)
	EndIf

	If $bUpdate And not FileExists(@ScriptDir & "\NoNotify.txt") Then
		_Sleep(1500)
		WinActivate(@AutoItPID)
		$iNewVersion = MsgBox($IDABORT + $MB_ICONINFORMATION, "New version " & $g_sBotGitVersion, "Do you want to download the latest update?", 360)

		If $iNewVersion = $IDYES Then
			Local $aFiles[1] ; Set in '1', array more stable.

			$aFiles = _FileListToArrayRec($g_sMBRDir, "*||build*", $FLTAR_FILES + $FLTAR_NOHIDDEN + $FLTAR_NOSYSTEM + $FLTAR_NOLINK, $FLTAR_RECUR, $FLTAR_SORT)
			For $i = UBound($aFiles) - 1 To 0 Step -1
				If (StringInStr($aFiles[$i], "\") > 0 Or StringInStr($aFiles[$i], "MyBot.run") > 0) And Not (StringInStr($aFiles[$i], "\Updater") > 0 Or StringInStr($aFiles[$i], "CSV\") > 0 Or StringInStr($aFiles[$i], "Strategies\") > 0 Or StringInStr($aFiles[$i], "Profiles\") > 0) Then
					ContinueLoop
				EndIf
				_ArrayDelete($aFiles, $i)
			Next

			Local $sUrl = 'https://github.com/boludoz/AIO-Mod/releases/download/v' & $g_sBotGitVersion & '/MyBot.run.zip'

			Local $iBytesReceived, $iFileSizeOnline, $hInet, $iPct, $sLocate, $iFileSize

			Do
			   ; SetDebugLog("Upgrading clash of clans. " & $s)
			   $sLocate = $g_sMBRDir & "\MyBot.run.zip"
			   ; SplashTextOn("Download", 'Upgrading AIO MOD.', 400, 50, Default, Default, BitOR($DLG_NOTITLE, $DLG_NOTONTOP, $DLG_MOVEABLE, $DLG_TEXTVCENTER), 'Tahoma', 10)
			   ProgressOn("Download", "Upgrading AIO MOD.", "0%", -1, -1, BitOr($DLG_NOTONTOP, $DLG_MOVEABLE))
			   $hInet = InetGet($sUrl, $sLocate, 1, 1) ;Forces a reload from the remote site and return immediately and download in the background
			   $iFileSizeOnline = InetGetSize($sUrl) ;Get file size
			   While Not InetGetInfo($hInet, 2) ;Loop until download is finished+
				  If _Sleep(500) Then Return SetError(0) ;Sleep for half a second to avoid flicker in the progress bar
				  $iBytesReceived = InetGetInfo($hInet, 0) ;Get bytes received
				  $iPct = Int($iBytesReceived / $iFileSizeOnline * 100) ;Calculate percentage
				  ProgressSet($iPct, $iPct & "%") ;Set progress bar
			   WEnd

			   ProgressOff()

			   $iFileSize = FileGetSize($sLocate)
			   If $iFileSizeOnline <> $iFileSize Then
				  $iNewVersion = MsgBox($MB_RETRYCANCEL + $MB_ICONERROR, "New version " & $g_sBotGitVersion, "Download fail. Please Check Your Internet Connection and try again.", 360)
				  If $iNewVersion = $IDRETRY Then ContinueLoop
				  $g_bFuseMsg = True
				  Return
			   Else
				  SetDebugLog("DownloadFromURLAD | OK. " & $iFileSize, $COLOR_SUCCESS)
				  $g_bFuseMsg = True
				  ; SetError(0)
				  ; Return $iFileSize
			   EndIf
			   ExitLoop
			Until $g_bFuseMsg = True


			Local $aKillAllInFolder = ProcessFindBy($g_sMBRDir, "", True, True)

			Local $aRestaurate[0][2]

			For $i = 0 To UBound($aKillAllInFolder) - 1
				Local $sPFN = _WinAPI_GetProcessFileName($aKillAllInFolder[$i])
				Local $sPCL = _WinAPI_GetProcessCommandLine($aKillAllInFolder[$i])
				If StringInStr($sPFN, "MyBot.run") > 0 Or StringInStr($sPCL, "MyBot.run") > 0 Then
					Local $aRestaurateTmp[1][2] = [[$sPFN, $sPCL]]
					_ArrayAdd($aRestaurate, $aRestaurateTmp)
				EndIf
				KillProcess($aKillAllInFolder[$i])
			Next

			For $sQ In $aFiles
				FileDelete($g_sMBRDir & "\" & $sQ)
			Next

			RunWait(Chr(34) & $g_sMBRDir & "\lib\ModLibs\Updater\7za.exe" & Chr(34) & " e " & Chr(34) & $g_sMBRDir & "\MyBot.run.zip" & Chr(34) & " -o" & Chr(34) & $g_sMBRDir & Chr(34) & " -y -spf")
			FileDelete($g_sMBRDir & "\MyBot.run.zip")

			If UBound($aRestaurate) > 0 And Not @error Then
				For $i = 0 To UBound($aRestaurate) - 1
					ShellExecute($aRestaurate[$i][0], $aRestaurate[$i][1])
				Next
			EndIf

			Exit
		ElseIf $iNewVersion = $IDNO Then
			$iNewVersion = MsgBox($MB_YESNO + $MB_ICONINFORMATION, "New version " & $g_sBotGitVersion, "Do you want to be notified of new versions in the future?", 360)
			If $iNewVersion = $IDNO Then
				Local $hHandle = FileOpen(@ScriptDir & "\NoNotify.txt", $FO_APPEND)
				FileClose($hHandle)
			EndIf
		EndIf
	Else
		$g_bFuseMsg = True
	EndIf

	Local $aReturn[2] = ["v" & $g_sBotGitVersion, $bUpdate]
	Return $aReturn
EndFunc   ;==>UpdateMod
#cs
Func CommandMaster()
	Local $sCommandMaster, $aKillAllInFolder = ProcessFindBy(@ScriptDir, "", true, false)
	$sCommandMaster &= "CD " & chr(34) & @ScriptDir & chr(34) & " | "
	$sCommandMaster &= chr(34) & @ScriptDir & "\lib\ModLibs\Updater\7za.exe" & chr(34) & " e " & chr(34) & @ScriptDir & "\MyBot.run.zip"  & chr(34) & " -o" & chr(34) & @ScriptDir & chr(34) & " -y -spf"
	$sCommandMaster &= " | DEL " & chr(34) & @ScriptDir & "\MyBot.run.zip"  & chr(34) & " /Q" ; We are not engineers.

	For $i = 0 To UBound($aKillAllInFolder)-1
		Local $sPFN = _WinAPI_GetProcessFileName($aKillAllInFolder[$i])
		Local $sPCL = _WinAPI_GetProcessCommandLine($aKillAllInFolder[$i])
		; If Not (StringInStr($s, "MyBot.run") > 0) Then ContinueLoop
		$sCommandMaster &=  ' | ' & chr(34) & $sPFN & chr(34) & " " &  $sPCL
	Next

	_ConsoleWrite(@ComSpec & " /c " & $sCommandMaster)
EndFunc
#ce
Func IsFile($sFilePath)
	Return (FileGetSize($sFilePath) > 0 And Not @error)
EndFunc   ;==>IsFile

Func _ConsoleWrite($Text)
	If StringTrimRight($Text, 1) <> @CRLF Then $Text &= @CRLF ; Custom fix - Team AIO Mod++
	Local $hFile, $pBuffer, $iToWrite, $iWritten, $tBuffer = DllStructCreate("char[" & StringLen($Text) & "]")
	DllStructSetData($tBuffer, 1, $Text)
	$hFile = _WinAPI_GetStdHandle(1)
	_WinAPI_WriteFile($hFile, $tBuffer, StringLen($Text), $iWritten)
	Return $iWritten
EndFunc   ;==>_ConsoleWrite

;  	ProcessFindBy($g_sAndroidAdbPath), $sPort
;	ProcessFindBy(@ScriptDir, "", True, False)
Func ProcessFindBy($sPath = @ScriptDir, $sCommandline = "", $bAutoItMode = False, $bDontShootYourself = True)
	Local $bGetProcessPath, $bGetProcessCommandLine, $bFail, $aReturn = []
	ReDim $aReturn[0]

	; In exe case, like emulator.
	If IsFile($sPath) = True Then
		Local $sFile = StringRegExpReplace($sPath, "^.*\\", "")
		$sFile = StringTrimRight($sFile, StringLen($sFile))
		_ConsoleWrite($sFile)
	EndIf

	$sPath = StringReplace($sPath, "\\", "\")
	If StringIsSpace($sPath) And StringIsSpace($sCommandline) Then Return $aReturn
	Local $sCommandlineParam
	Local $aiProcessList = ProcessList()
	If @error Then Return $aReturn
	For $i = 2 To UBound($aiProcessList) - 1
		$bGetProcessPath = StringInStr(_WinAPI_GetProcessFileName($aiProcessList[$i][1]), $sPath) > 0
		$sCommandlineParam = _WinAPI_GetProcessCommandLine($aiProcessList[$i][1])
		If $bGetProcessPath = False And $bAutoItMode Then $bGetProcessPath = StringInStr($sCommandlineParam, $sPath) > 0
		$bGetProcessCommandLine = StringInStr($sCommandlineParam, $sCommandline) > 0
		Local $iAdd = Int($aiProcessList[$i][1])
		If $iAdd > 0 Then
			Select
				Case $bGetProcessPath And $bGetProcessCommandLine
					If Not StringIsSpace($sPath) And Not StringIsSpace($sCommandline) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
				Case $bGetProcessPath And Not $bGetProcessCommandLine
					If StringIsSpace($sCommandline) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
				Case Not $bGetProcessPath And $bGetProcessCommandLine
					If StringIsSpace($sPath) Then
						_ArrayAdd($aReturn, $iAdd, $ARRAYFILL_FORCE_INT)
					EndIf
			EndSelect
		EndIf
	Next

	For $i = UBound($aReturn) - 1 To 0 Step -1
		If $aReturn[$i] = @AutoItPID Then
			If $bDontShootYourself = True Then
				_ArrayDelete($aReturn, $i)
			Else
				Local $iNT = $i
				_ArrayAdd($aReturn, $aReturn[$i], $ARRAYFILL_FORCE_INT)
				_ArrayDelete($aReturn, $iNT)
			EndIf
			ExitLoop
		EndIf
	Next

	Return $aReturn
EndFunc   ;==>ProcessFindBy

Func KillProcess($iPid, $sProcess_info = "", $iAttempts = 3)
	If StringIsDigit($iPid) Then
		If Number($iPid) > 0 Then
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
		EndIf
	EndIf
EndFunc   ;==>KillProcess
#EndRegion - Custom - Team AIO Mod++

Func SetLog($String, $Color = $COLOR_BLACK, $LogPrefix = "L ")
	Local $log = $LogPrefix & TimeDebug() & $String
	_ConsoleWrite($log & @CRLF) ; Always write any log to console
EndFunc   ;==>SetLog

Func SetDebugLog($String, $Color = $COLOR_DEBUG, $LogPrefix = "D ")
	Return SetLog($String, $Color, $LogPrefix)
EndFunc   ;==>SetDebugLog

Func _Sleep($ms, $iSleep = True, $CheckRunState = True)
	_SleepMilli($ms)
EndFunc   ;==>_Sleep

Func _SleepMilli($iMilliSec)
	Sleep($iMilliSec)
EndFunc   ;==>_SleepMilli

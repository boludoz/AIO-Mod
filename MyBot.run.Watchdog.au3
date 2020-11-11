; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot Watchdog
; Description ...: This file contens the Sequence that runs all MBR Bot
; Author ........: cosote (12-2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#NoTrayIcon
#RequireAdmin
#AutoIt3Wrapper_UseX64=7n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/rsln
#AutoIt3Wrapper_Change2CUI=y
;#pragma compile(Console, true)
#include "MyBot.run.version.au3"
#pragma compile(ProductName, My Bot Watchdog)
#pragma compile(Out, MyBot.run.Watchdog.exe) ; Required

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

; Global Variables
Global Const $g_sLibPath = @ScriptDir & "\lib" ;lib directory contains dll's
Global Const $g_sLibIconPath = $g_sLibPath & "\MBRBOT.dll" ; icon library
Global Enum $eIcnArcher = 1, $eIcnDonArcher, $eIcnBalloon, $eIcnDonBalloon, $eIcnBarbarian, $eIcnDonBarbarian, $eBtnTest, $eIcnBuilder, $eIcnCC, $eIcnGUI
Global $g_WatchDogLogStatusBar = False
Global $g_WatchOnlyClientPID = Default
Global $g_bRunState = True
Global $g_hFrmBot = 0 ; Dummy form for messages
Global $g_iGlobalActiveBotsAllowed = 0 ; Dummy
Global $g_hMutextOrSemaphoreGlobalActiveBots = 0 ; Dummy
Global $g_hStatusBar = 0 ; Dummy
Global $hMutex_BotTitle = 0 ; Mutex handle for this instance
Global $hStarted = 0 ; Timer handle watchdog started
Global $bCloseWhenAllBotsUnregistered = True ; Automatically close watchdog when all bots closed
Global $iTimeoutBroadcast = 15000 ; Milliseconds of sending broadcast messages to bots
Global $iTimeoutCheckBot = 5000 ; Milliseconds bots are checked if restart required
Global $iTimeoutRestartBot = 180000 ; Milliseconds un-responsive bot is launched again
Global $iTimeoutAutoClose = 60000 ; Milliseconds watchdog automatically closed when no bot available, -1 = disabled
Global $hTimeoutAutoClose = 0 ; Timer Handle for $iTimeoutAutoClose
Global $g_bBotLaunchOption_NoBotSlot = True
Global $g_iDebugWindowMessages = 0

Global $hStruct_SleepMicro = DllStructCreate("int64 time;")
Global $pStruct_SleepMicro = DllStructGetPtr($hStruct_SleepMicro)
Global $DELAYSLEEP = 500
Global $g_bDebugSetlog = False
Global $g_bDebugAndroid = False
Global $g_asCmdLine = [0]

; used by API
Global Enum $eLootGold, $eLootElixir, $eLootDarkElixir, $eLootTrophy, $eLootCount
Global $g_aiCurrentLoot[$eLootCount] = [0, 0, 0, 0] ; current stats
Global $g_iStatsTotalGain[$eLootCount] = [0, 0, 0, 0]
Global $g_iStatsLastAttack[$eLootCount] = [0, 0, 0, 0]
Global $g_iStatsBonusLast[$eLootCount] = [0, 0, 0, 0]

; Dummy functions
Func _GUICtrlStatusBar_SetText($a, $b)
EndFunc   ;==>_GUICtrlStatusBar_SetText
Func _GUICtrlStatusBar_SetTextEx($a, $b)
EndFunc   ;==>_GUICtrlStatusBar_SetTextEx
Func GetTranslated($a, $b, $c)
EndFunc   ;==>GetTranslated
Func GetTranslatedFileIni($a, $b, $c)
EndFunc   ;==>GetTranslatedFileIni

#Region - Custom - Team AIO Mod++
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
Global $g_bFuseMsg = False
Func GetLastVersion($txt)
	Return _StringBetween($txt, '"tag_name":"', '","')
EndFunc   ;==>GetLastVersion

Func _StringBetween($sString, $sStart, $sEnd, $iMode = $STR_ENDISSTART, $bCase = False)
$sStart = $sStart ? "\Q" & $sStart & "\E" : "\A"
If $iMode <> $STR_ENDNOTSTART Then $iMode = $STR_ENDISSTART
If $iMode = $STR_ENDISSTART Then
$sEnd = $sEnd ? "(?=\Q" & $sEnd & "\E)" : "\z"
Else
$sEnd = $sEnd ? "\Q" & $sEnd & "\E" : "\z"
EndIf
If $bCase = Default Then
$bCase = False
EndIf
Local $aRet = StringRegExp($sString, "(?s" &(Not $bCase ? "i" : "") & ")" & $sStart & "(.*?)" & $sEnd, $STR_REGEXPARRAYGLOBALMATCH)
If @error Then Return SetError(1, 0, 0)
Return $aRet
EndFunc

Func GetLastChangeLog($txt)
	Return _StringBetween($txt, '"body":"', '"}')
EndFunc   ;==>GetLastChangeLog

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
	If $g_bFuseMsg = True Then Return
	Local $bUpdate = False
	; If not $g_bCheckVersion Then Return

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
		SetDebugLog("Last GitHub version is " & $g_sBotGitVersion )
		SetDebugLog("Your version is " & $g_iBotVersionN )

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

	If $bUpdate Then
		Local $iNewVersion  = MsgBox (4, "New version " & $g_sBotGitVersion ,"Do you want to download the latest update?", 360)

		If $iNewVersion = 6 Then
			Local $sUrl ='https://github.com/boludoz/AIO-Mod/releases/download/v' & $g_sBotGitVersion & '/MyBot.run.zip'

			Local $iBytesReceived,  $iFileSizeOnline, $hInet, $iPct

			; SetDebugLog("Upgrading clash of clans. " & $s)
			Local $sLocate = @ScriptDir & "\MyBot.run.zip"
			ProgressOn("Download", "Upgrading AIO MOD.", "0%")
			$hInet = InetGet($sUrl, $sLocate, 1, 1) ;Forces a reload from the remote site and return immediately and download in the background
			$iFileSizeOnline = InetGetSize($sUrl) ;Get file size
			While Not InetGetInfo($hInet, 2) ;Loop until download is finished+
				If _Sleep(500) Then Return SetError(0) ;Sleep for half a second to avoid flicker in the progress bar
				$iBytesReceived = InetGetInfo($hInet, 0) ;Get bytes received
				$iPct = Int($iBytesReceived / $iFileSizeOnline * 100) ;Calculate percentage
				ProgressSet($iPct, $iPct & "%") ;Set progress bar
			WEnd

			ProgressOff()

			; SetDebugLog($sLocate)
			Local $iFileSize = FileGetSize($sLocate)
			If $iFileSizeOnline <> $iFileSize Then
				; SetDebugLog("DownloadFromURLAD | FAIL. " & $iFileSize, $COLOR_ERROR)
				; Return SetError(-1, 0, -1)
				$g_bFuseMsg = True
				Return
			Else
				SetDebugLog("DownloadFromURLAD | OK. " & $iFileSize, $COLOR_SUCCESS)
				$g_bFuseMsg = True
				; SetError(0)
				; Return $iFileSize
			EndIf

			Local $aFiles[0]
			_FileReadToArray(@ScriptDir & "\lib\ModLibs\Updater\Uninstaller.dat", $aFiles)
			
			Local $aKillAllInFolder = ProcessFindBy(@ScriptDir, "", True, True)
		
			For $i = 0 To UBound($aKillAllInFolder)-1
				KillProcess($aKillAllInFolder[$i])
			Next
			
			For $sQ In $aFiles
				FileDelete(@ScriptDir & $sQ)
			Next
		
			Run(chr(34) & @ScriptDir & "\lib\ModLibs\Updater\7za.exe" & chr(34) & " e " & chr(34) & @ScriptDir & "\MyBot.run.zip"  & chr(34) & " -o" & chr(34) & @ScriptDir & chr(34) & " -y -spf")
			
			; FileDelete(@ScriptDir & "\MyBot.run.zip")
			
			Exit
		EndIf
		Else
		$g_bFuseMsg = True
	EndIf

	Local $aReturn[2] = ["v" & $g_sBotGitVersion, $bUpdate]
	Return $aReturn
EndFunc   ;==>UpdateMod

Func IsFile($sFilePath)
	Return (FileGetSize($sFilePath) > 0 and not @error)
EndFunc   ;==>IsDir

;  	ProcessFindBy($g_sAndroidAdbPath), $sPort
;	ProcessFindBy(@ScriptDir, "", True, False)
Func ProcessFindBy($sPath = "", $sCommandline = "", $bAutoItMode = False, $bDontShootYourself = True)

	; In exe case, like emulator.
	If IsFile($sPath) = True Then
		Local $sFile = StringRegExpReplace($sPath, "^.*\\", "")
		$sFile = StringTrimRight($sFile, StringLen($sFile))
		_ConsoleWrite($sFile)
	EndIf

	$sPath = StringReplace($sPath, "\\", "\")
	If StringIsSpace($sPath) And StringIsSpace($sCommandline) Then Return $aReturn
	Local $bGetProcessPath, $bGetProcessCommandLine, $bFail, $aReturn[0]
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
	If Number($iPid) < 1 Or @error Then Return False ; Prevent bluescreen - Team AIO Mod++
	Local $iCount = 0
	If $sProcess_info <> "" Then $sProcess_info = ", " & $sProcess_info
	Do
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

Func _SleepMicro($iMicroSec)
	;Local $hStruct_SleepMicro = DllStructCreate("int64 time;")
	;Local $pStruct_SleepMicro = DllStructGetPtr($hStruct_SleepMicro)
	DllStructSetData($hStruct_SleepMicro, "time", $iMicroSec * -10)
	DllCall($hNtDll, "dword", "ZwDelayExecution", "int", 0, "ptr", $pStruct_SleepMicro)
	;$hStruct_SleepMicro = 0
EndFunc   ;==>_SleepMicro

Func _SleepMilli($iMilliSec)
	_SleepMicro(Int($iMilliSec * 1000))
EndFunc   ;==>_SleepMilli

Func UpdateManagedMyBot($aBotDetails)
	Return True
EndFunc   ;==>UpdateManagedMyBot

Global $g_sBotTitle = "My Bot Watchdog " & $g_sBotVersion & " - " & "AiO++ MOD " & $g_sModVersion & " -" ;~ Don't use any non file name supported characters like \ / : * ? " < > |

Opt("WinTitleMatchMode", 3) ; Window Title exact match mode

#include "COCBot\functions\Other\Api.au3"
#include "COCBot\functions\Other\ApiHost.au3"
#include "COCBot\functions\Other\LaunchConsole.au3"
#include "COCBot\functions\Other\Time.au3"

; Handle Command Line Launch Options and fill $g_asCmdLine
If $CmdLine[0] > 0 Then
	For $i = 1 To $CmdLine[0]
		Switch $CmdLine[$i]
			Case "/console", "/c", "-console", "-c"
				_WinAPI_AllocConsole()
				_WinAPI_SetConsoleIcon($g_sLibIconPath, $eIcnGUI)
			Case Else
				$g_asCmdLine[0] += 1
				ReDim $g_asCmdLine[$g_asCmdLine[0] + 1]
				$g_asCmdLine[$g_asCmdLine[0]] = $CmdLine[$i]
		EndSwitch
	Next
EndIf

; Update Console Window (if it exists)
DllCall("kernel32.dll", "bool", "SetConsoleTitle", "str", "Console " & $g_sBotTitle)

$hMutex_BotTitle = CreateMutex($sWatchdogMutex)
If $hMutex_BotTitle = 0 Then
	;MsgBox($MB_OK + $MB_ICONINFORMATION, $sBotTitle, "My Bot Watchdog is already running.")
	SetLog($g_sBotTitle & " is already running")
	Exit 2
EndIf

; create dummy form for Window Messsaging
$g_hFrmBot = GUICreate($g_sBotTitle, 32, 32)
$hStarted = __TimerInit() ; Timer handle watchdog started
$hTimeoutAutoClose = $hStarted

Local $iExitCode = 0
Local $iActiveBots = 0
If $g_bFuseMsg = False Then UpdateMod()
While 1

	$iActiveBots = UBound(GetManagedMyBotDetails())
	SetDebugLog("Broadcast query bot state, registered bots: " & $iActiveBots)
	_WinAPI_BroadcastSystemMessage($WM_MYBOTRUN_API, 0x0100 + $iActiveBots, $g_hFrmBot, $BSF_POSTMESSAGE + $BSF_IGNORECURRENTTASK, $BSM_APPLICATIONS)

	Local $hLoopTimer = __TimerInit()
	Local $hCheckTimer = __TimerInit()
	While __TimerDiff($hLoopTimer) < $iTimeoutBroadcast
		_Sleep($DELAYSLEEP)
		If __TimerDiff($hCheckTimer) >= $iTimeoutCheckBot Then
			; check if bot not responding anymore and restart if so
			CheckManagedMyBot($iTimeoutRestartBot)
			$hCheckTimer = __TimerInit()
		EndIf
	WEnd

	; log active bots
	$iActiveBots = GetActiveMyBotCount($iTimeoutBroadcast * 2)
	SetDebugLog("Active bots: " & $iActiveBots)

	; automatically close watchdog when no bot available
	If $iTimeoutAutoClose > -1 And __TimerDiff($hTimeoutAutoClose) > $iTimeoutAutoClose Then
		If UBound(GetManagedMyBotDetails()) = 0 Then
			SetLog("Closing " & $g_sBotTitle & " as no running bot found")
			$iExitCode = 1
			ExitLoop
		EndIf
		$hTimeoutAutoClose = __TimerInit() ; timeout starts again
	EndIf

WEnd

ReleaseMutex($hMutex_BotTitle)
DllClose("ntdll.dll")
Exit ($iExitCode)

; Reference function so stripper is not removing it
UpdateManagedMyBot(True)

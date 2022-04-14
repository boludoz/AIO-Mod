; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot Updater
; Description ...: This file contens the Sequence that runs all MBR Bot
; Author ........: Boldina ! (2020|2022)
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
#pragma compile(Icon, "Images\MyBot.ico")
#pragma compile(ProductName, AIOMod.Updater)
#pragma compile(Out, AIOMod.Updater.exe) ; Required

; Enforce variable declarations
Opt("MustDeclareVars", 1)

#include <APIErrorsConstants.au3>
#include <Misc.au3>
#include <ColorConstants.au3>
#include <Date.au3>
#include <Array.au3>
#include <WinAPISysWin.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <String.au3>
#include <WinAPIProc.au3>

Global $hNtDll = DllOpen("ntdll.dll")

Global Const $COLOR_ERROR = $COLOR_RED ; Error messages
Global Const $COLOR_WARNING = $COLOR_MAROON ; Warning messages
Global Const $COLOR_INFO = $COLOR_BLUE ; Information or Status updates for user
Global Const $COLOR_SUCCESS = 0x006600 ; Dark Green, Action, method, or process completed successfully
Global Const $COLOR_DEBUG = $COLOR_PURPLE ; Purple, basic debug color
Global $g_sModVersion = "v0.0.0"

#Region - Custom - Team AIO Mod++

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
	; $g_sMBRDir = StringReplace($g_sMBRDir, "\lib\ModLibs\Updater", "")
	If $g_bFuseMsg = True Then Return
	Local $bUpdate = False
	Local $iNewVersion
	; If not $g_bCheckVersion Then Return

	DirRemove(@ScriptDir & "\lib\ModLibs\Updater\", 1)

	Local $vReturn, $aArray
	If FileExists($g_sMBRDir & "\MyBot.run.version.au3") Then
		_FileReadToArray($g_sMBRDir & "\MyBot.run.version.au3", $vReturn)

		If Not @error Then
			For $i = 0 To UBound($vReturn) -1
				$aArray = _StringBetween(StringStripWS($vReturn[$i], $STR_STRIPALL), '$g_sModVersion="', '"')
				If Not @error Then
					$g_sModVersion = $aArray[0]
					ExitLoop
				EndIf
			Next

			; Close the handle returned by FileOpen.
			FileClose($g_sMBRDir & "\MyBot.run.version.au3")
		EndIf
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
;~			For $i = 0 To UBound($Changelog) - 1
;~ 				If not $bSilent Then SetLog($Changelog[$i] )
;~			Next
			; PushMsg("Update")
			$bUpdate = True
;~		ElseIf _VersionCompare($g_iBotVersionN, $g_sBotGitVersion) = 0 Then
;~ 			If not $bSilent Then SetLog("WELCOME CHIEF, YOU HAVE THE LATEST AIO MOD VERSION", $COLOR_SUCCESS)
;~		Else
;~ 			If not $bSilent Then SetLog("YOU ARE USING A FUTURE VERSION CHIEF!", $COLOR_ACTION)
		EndIf
	Else
		SetDebugLog($Temp)
	EndIf

	If $bUpdate And not FileExists($g_sMBRDir & "\NoNotify.txt") Then
		_Sleep(1500)
		WinActivate(@AutoItPID)

		If FileExists($g_sMBRDir & "\AutoUpdate.txt") Then
			$iNewVersion = $IDYES
		Else
			$iNewVersion = MsgBox($IDABORT + $MB_ICONINFORMATION, "New version " & $g_sBotGitVersion, "Do you want to download the latest update?", 360)
		EndIf

		If $iNewVersion = $IDYES Then
			Local $aFiles[1] ; Set in '1', array more stable.

			$aFiles = _FileListToArrayRec($g_sMBRDir, "*||build*", $FLTAR_FILES + $FLTAR_NOHIDDEN + $FLTAR_NOSYSTEM + $FLTAR_NOLINK, $FLTAR_RECUR, $FLTAR_SORT)
			For $i = UBound($aFiles) - 1 To 0 Step -1
				If (StringInStr($aFiles[$i], "\") > 0) And Not (StringInStr($aFiles[$i], "bin\") > 0 Or StringInStr($aFiles[$i], "AIOMod.Updater") > 0 Or StringInStr($aFiles[$i], "CSV\") > 0 Or StringInStr($aFiles[$i], "Strategies\") > 0 Or StringInStr($aFiles[$i], "Profiles\") > 0) Then
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
				ConsoleWrite($sPCL & @CRLF)
				If StringInStr($sPFN, "MyBot.run") > 0 Or StringInStr($sPCL, "MyBot.run") > 0 Or StringInStr($sPCL, "adb") > 0 Then
					Local $aRestaurateTmp[1][2] = [[$sPFN, $sPCL]]
					_ArrayAdd($aRestaurate, $aRestaurateTmp)
				EndIf
				KillProcess($aKillAllInFolder[$i])
			Next

			For $sQ = 0 To UBound($aFiles) -1
				FileDelete($g_sMBRDir & "\" & $aFiles[$sQ])
			Next

			_Zip_UnzipAll($g_sMBRDir & "\MyBot.run.zip", $g_sMBRDir & "\")

			Sleep(10000)

			FileDelete($g_sMBRDir & "\MyBot.run.zip")

			If UBound($aRestaurate) > 0 And Not @error Then
				For $i = 0 To UBound($aRestaurate) - 1
					ShellExecute($aRestaurate[$i][0], $aRestaurate[$i][1])
				Next
			EndIf
			ProgressOff()

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

#Region
;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
; If UBound($CMDLine) > 1 Then
	; If $CMDLine[1] <> "" Then _Zip_VirtualZipOpen()
; EndIf


;===============================================================================
;
; Function Name:    _Zip_AddFolder()
; Description:      Add a folder to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFolder - Complete path to the folder that will be added (possibly including "\" at the end)
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFolder($hZipFile, $hFolder, $flag = 1)
	Local $DLLChk = _Zip_DllChk(), $oCopy, $files, $oApp
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	$files = _Zip_Count($hZipFile)
	$oApp = ObjCreate("Shell.Application")
	$oCopy = $oApp.NameSpace($hZipFile).CopyHere($oApp.Namespace($hFolder))
	While 1
		; If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($files+1) Then ExitLoop
		Sleep(10)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolder

;===============================================================================
;
; Function Name:    _Zip_AddFolderContents()
; Description:      Add a folder to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFolder - Complete path to the folder that will be added (possibly including "\" at the end)
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFolderContents($hZipFile, $hFolder, $flag = 1)
	Local $DLLChk = _Zip_DllChk(), $oFC, $oCopy, $oFolder, $files, $oApp
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	$files = _Zip_Count($hZipFile)
	$oApp = ObjCreate("Shell.Application")
	$oFolder = $oApp.NameSpace($hFolder)
	$oCopy = $oApp.NameSpace($hZipFile).CopyHere($oFolder.Items)
	$oFC = $oApp.NameSpace($hFolder).items.count
	While 1
		; If $flag = 1 then _Hide()
		If _Zip_Count($hZipFile) = ($files+$oFC) Then ExitLoop
		Sleep(10)
	WEnd
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_AddFolderContents

;===============================================================================
;
; Function Name:    _Zip_UnzipAll()
; Description:      Extract all files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hDestPath - Complete path to where the files will be extracted
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the extracting process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_UnzipAll($hZipFile, $hDestPath, $flag = 20)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(2, 0, 0) ;no zip file
	If Not FileExists($hDestPath) Then DirCreate($hDestPath)
	Local $aArray[0]
	Local $oApp = ObjCreate("Shell.Application")
	$oApp.Namespace($hDestPath).CopyHere($oApp.Namespace($hZipFile).Items, $flag)
	If not @error Then Return True
EndFunc   ;==>_Zip_UnzipAll

;===============================================================================
;
; Function Name:    _Zip_Unzip()
; Description:      Extract a single file contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFilename - Name of the element in the zip archive ex. "hello_world.txt"
;					$hDestPath - Complete path to where the files will be extracted
;					$flag = 1
;					- 1 no progress box
;					- 0 progress box
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the extracting process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_Unzip($hZipFile, $hFilename, $hDestPath, $flag = 1)
	Local $DLLChk = _Zip_DllChk(), $hFolderitem, $oApp
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	If Not FileExists($hDestPath) Then DirCreate($hDestPath)
	$oApp = ObjCreate("Shell.Application")
	$hFolderitem = $oApp.NameSpace($hZipFile).Parsename($hFilename)
	$oApp.NameSpace($hDestPath).Copyhere($hFolderitem)
	While 1
		; If $flag = 1 then _Hide()
		If FileExists($hDestPath & "\" & $hFilename) Then
			return SetError(0, 0, 1)
			ExitLoop
		EndIf
		Sleep(500)
	WEnd
EndFunc   ;==>_Zip_Unzip

;===============================================================================
;
; Function Name:    _Zip_Count()
; Description:      Count files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
;
;===============================================================================
Func _Zip_Count($hZipFile)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	Local $items = _Zip_List($hZipFile)
	Return UBound($items) - 1
EndFunc   ;==>_Zip_Count

;===============================================================================
;
; Function Name:    _Zip_CountAll()
; Description:      Count All files contained in a ZIP Archive (including Sub Directories)
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_, Smashly
;
;===============================================================================
Func _Zip_CountAll($hZipFile)
	Local $DLLChk = _Zip_DllChk(), $sZipInf, $oApp, $oDir
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
    $oApp = ObjCreate("Shell.Application")
    $oDir = $oApp.NameSpace(StringLeft($hZipFile, StringInStr($hZipFile, "\", 0, -1)))
    $sZipInf = $oDir.GetDetailsOf($oDir.ParseName(StringTrimLeft($hZipFile, StringInStr($hZipFile, "\", 0, -1))), -1)
    Return StringRight($sZipInf, StringLen($sZipInf) - StringInStr($sZipInf, ": ") - 1)
EndFunc

;===============================================================================
;
; Function Name:    _Zip_List()
; Description:      Returns an Array containing of all the files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
;
;===============================================================================
Func _Zip_List($hZipFile)
	local $aArray[1]
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	Local $oApp = ObjCreate("Shell.Application")
	Local $hList = $oApp.Namespace($hZipFile).Items
	For $item in $hList
		_ArrayAdd($aArray,$item.name)
	Next
	$aArray[0] = UBound($aArray) - 1
	Return $aArray
EndFunc   ;==>_Zip_List

;===============================================================================
;
; Function Name:    _Zip_Search()
; Description:      Search files in a ZIP Archive.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sSearchString - name of the file to be searched
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1 (no file found)
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_Search($hZipFile, $sSearchString)
	local $aArray, $list
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If not _IsFullPath($hZipFile) then Return SetError(4,0) ;zip file isn't a full path
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	$list = _Zip_List($hZipFile)
	for $i = 0 to UBound($list) - 1
		if StringInStr($list[$i],$sSearchstring) > 0 Then
			_ArrayAdd($aArray, $list[$i])
		EndIf
	Next
	if UBound($aArray) - 1 = 0 Then
		Return SetError(1,0,0)
	Else
		Return $aArray
	EndIf
EndFunc ;==> _Zip_Search

;===============================================================================
;
; Function Name:    _Zip_SearchInFile()
; Description:      Search files in a ZIP Archive's File.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sSearchString - name of the file to be searched
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1 (no file found)
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_SearchInFile($hZipFile, $sSearchString)
	local $aArray, $read
	Local $list = _Zip_List($hZipFile)
	for $i = 1 to UBound($list) - 1
		_Zip_Unzip($hZipFile, $list[$i], @TempDir & "\tmp_zip.file")
		$read = FileRead(@TempDir & "\tmp_zip.file")
		if StringInStr($read,$sSearchstring) > 0 Then
			_ArrayAdd($aArray, $list[$i])
		EndIf
	Next
	if UBound($aArray) - 1 = 0 Then
		Return SetError(1,0,1)
	Else
		Return $aArray
	EndIf
EndFunc ;==> _Zip_Search

;===============================================================================
;
; Function Name:    _Zip_VirtualZipCreate()
; Description:      Create a Virtual Zip.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sPath - Path to where create the Virtual Zip
; Requirement(s):   none.
; Return Value(s):  On Success - List of Created Files
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipCreate($hZipFile, $sPath)
	Local $List = _Zip_List($hZipFile), $Params, $Cmd
	If @error Then Return SetError(@error,0,0)
	If Not FileExists($sPath) Then DirCreate($sPath)
	If StringRight($sPath, 1) = "\" Then $sPath = StringLeft($sPath, StringLen($sPath) -1)
	For $i = 1 to $List[0]
		If Not @Compiled Then
			$Cmd = @AutoItExe
			$params = '"' & @ScriptFullPath & '" ' & '"' & $hZipFile & "," & $List[$i] & '"'
		Else
			$Cmd = @ScriptFullPath
			$Params = '"' & $hZipFile & "," & $List[$i] & '"'
		EndIf
		FileCreateShortcut($Cmd, $sPath & "\" & $List[$i], -1,$Params, "Virtual Zipped File", _GetIcon($List[$i], 0), "", _GetIcon($List[$i], 1))
	Next
	$List = _ArrayInsert($List, 1, $sPath)
	Return $List
EndFunc

;===============================================================================
;
; Function Name:    _Zip_VirtualZipOpen()
; Description:      Open A File in a Virtual Zip, Internal Function.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipOpen()
	Local $ZipSplit = StringSplit($CMDLine[1], ",")
	Local $ZipName = $ZipSplit[1]
	Local $ZipFile = $ZipSplit[2]
	_Zip_Unzip($ZipName, $ZipFile, @TempDir & "\", 4+16) ;no progress + yes to all
	If @error Then Return SetError(@error,0,0)
	ShellExecute(@TempDir & "\" & $ZipFile)
EndFunc

;===============================================================================
;
; Function Name:    _Zip_VirtualZipOpen()
; Description:      Delete a Virtual Zip.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - none.
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_VirtualZipDelete($aVirtualZipHandle)
	For $i = 2 to UBound($aVirtualZipHandle)-1
		If FileExists($aVirtualZipHandle[1] & "\" & $aVirtualZipHandle[$i]) Then FileDelete($aVirtualZipHandle[1] & "\" & $aVirtualZipHandle[$i])
	Next
	Return 0
EndFunc

;===============================================================================
;
; Function Name:    _Zip_DllChk()
; Description:      Internal error handler.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  Failure - @extended = 1
; Author(s):        smashley
;
;===============================================================================
Func _Zip_DllChk()
	If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return 2
	If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return 3
	Return 0
EndFunc   ;==>_Zip_DllChk

;===============================================================================
;
; Function Name:    _GetIcon()
; Description:      Internal Function.
; Parameter(s):     $file - File form which to retrieve the icon
;					$ReturnType - IconFile or IconID
; Requirement(s):   none.
; Return Value(s):  Icon Path/ID
; Author(s):        torels_
;
;===============================================================================
Func _GetIcon($file, $ReturnType = 0)
	Local $FileType = StringSplit($file, ".")
	Local $FileType = $FileType[UBound($FileType)-1]
	Local $FileParam = RegRead("HKEY_CLASSES_ROOT\." & $FileType, "")
	Local $DefaultIcon = RegRead("HKEY_CLASSES_ROOT\" & $FileParam & "\DefaultIcon", "")

	If Not @error Then
		Local $IconSplit = StringSplit($DefaultIcon, ",")
		ReDim $IconSplit[3]
		Local $Iconfile = $IconSplit[1]
		Local $IconID = $IconSplit[2]
	Else
		Local $Iconfile = @SystemDir & "\shell32.dll"
		Local $IconID = -219
	EndIf

	If $ReturnType = 0 Then
		Return $Iconfile
	Else
		Return $IconID
	EndIf
EndFunc

;===============================================================================
;
; Function Name:    _IsFullPath()
; Description:      Internal Function.
; Parameter(s):     $path - a zip path
; Requirement(s):   none.
; Return Value(s):  success - True.
;					failure - False.
; Author(s):        torels_
;
;===============================================================================
Func _IsFullPath($path)
    if StringInStr($path,":\") then
        Return True
    Else
        Return False
    EndIf
Endfunc
#EndRegion
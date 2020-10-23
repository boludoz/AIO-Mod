; #FUNCTION# ====================================================================================================================
; Name ..........: OpenExternal
; Description ...: Opens new External instance
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Cosote (12-2015)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func OpenExternal($bRestart = False)

	Local $PID, $hTimer, $iCount = 0, $process_killed, $cmdOutput, $connected_to, $launchAndroid, $cmdPar

	SetLog("Starting " & $g_sAndroidEmulator & " and Clash Of Clans", $COLOR_SUCCESS)

	; Test ADB is connected
	$connected_to = ConnectAndroidAdb(False, 60 * 1000)
	If Not $g_bRunState Then Return False

	$hTimer = __TimerInit()
	; Wait for device
	;$cmdOutput = LaunchConsole($g_sAndroidAdbPath, " -s " & $g_sAndroidAdbDevice & " wait-for-device", $process_killed, 60 * 1000)
	;If Not $g_bRunState Then Return

	; Wair for Activity Manager
	If WaitForAndroidBootCompleted($g_iAndroidLaunchWaitSec - __TimerDiff($hTimer) / 1000, $hTimer) Then Return False

	; Wait for UI Control, then CoC can be launched
	;While Not IsArray(ControlGetPos($g_sAndroidTitle, $g_sAppPaneName, $g_sAppClassInstance)) And __TimerDiff($hTimer) <= $g_iAndroidLaunchWaitSec * 1000
	;  If _Sleep(500) Then Return
	;WEnd

	If Not $g_bRunState Then Return False
	If __TimerDiff($hTimer) >= $g_iAndroidLaunchWaitSec * 1000 Then ; if it took 4 minutes, Android/PC has major issue so exit
		SetLog("Serious error has occurred, please restart PC and try again", $COLOR_ERROR)
		SetLog($g_sAndroidEmulator & " refuses to load, waited " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds for window", $COLOR_ERROR)
		SetError(1, @extended, False)
		Return False
	EndIf

	SetLog($g_sAndroidEmulator & " Loaded, took " & Round(__TimerDiff($hTimer) / 1000, 2) & " seconds to begin.", $COLOR_SUCCESS)
	Return True

EndFunc   ;==>OpenExternal

Func GetExternalProgramParameter($bAlternative = False)
#cs
	If Not $bAlternative Or $g_sAndroidInstance <> $g_avAndroidAppConfig[$g_iAndroidConfig][1] Then
		; should be launched with these parameter
		Return "-o " & ($g_sAndroidInstance = "" ? $g_avAndroidAppConfig[$g_iAndroidConfig][1] : $g_sAndroidInstance)
	EndIf
	; default instance gets launched when no parameter was specified (this is the alternative way)
#ce
	Return ""
EndFunc   ;==>GetExternalProgramParameter

Func GetExternalPath()
	Local $sExternalPath
	$sExternalPath = @ScriptDir & "\lib\Pure\"
	Return StringReplace($sExternalPath, "\\", "\")
EndFunc   ;==>GetExternalPath

Func GetExternalAdbPath()
	Local $adbPath = GetExternalPath() & "adb.exe"
	If FileExists($adbPath) Then Return $adbPath
	Return ""
EndFunc   ;==>GetExternalAdbPath

Func GetExternalBackgroundMode()
	; Only OpenGL is supported up to version 0.10.6 Beta
	Return $g_iAndroidBackgroundModeOpenGL
EndFunc   ;==>GetExternalBackgroundMode

Func InitExternal($bCheckOnly = False)
	Local $process_killed, $aRegExResult, $VirtualBox_Path, $oops = 0

	$__External_Version = "1.0.0"
	$__External_Path = GetExternalPath()

	$VirtualBox_Path = ""
	$__VBoxManage_Path = ""

	Local $sPreferredADB = GetExternalPath() & "adb.exe"
	
	; Shared folder.
	$g_sAndroidPicturesHostPath = "\lib\Pure\Shared\" ; Windows host path to mounted pictures in android
	$g_bAndroidSharedFolderAvailable = False

	; Read ADB host and Port
	If Not $bCheckOnly Then
		InitAndroidConfig(True) ; Restore default config

		$g_sAndroidAdbDevice = ""
		
		; update global variables
		$g_sAndroidProgramPath = $__External_Path & "Pure.exe"
		$g_sAndroidPath = $__External_Path
		$g_sAndroidAdbPath = $sPreferredADB
		If $g_sAndroidAdbPath = "" Then $g_sAndroidAdbPath = $__External_Path & "adb.exe"
		$g_sAndroidVersion = $__External_Version
		; Update Window Title if instance has been configured
		If $g_sAndroidInstance = "" Or StringCompare($g_sAndroidInstance, $g_avAndroidAppConfig[$g_iAndroidConfig][1]) = 0 Then
			; Default title, nothing to do
		Else
			; Update title (only if not updated yet)
			If $g_sAndroidTitle = $g_avAndroidAppConfig[$g_iAndroidConfig][2] Then
				$g_sAndroidTitle = StringReplace($g_avAndroidAppConfig[$g_iAndroidConfig][2], "External", $g_sAndroidInstance)
			EndIf
		EndIf

		Local $process_killed, $cmdOutput, $aArrays, $sLine, $aTmp[0]
		$cmdOutput = LaunchConsole($g_sAndroidAdbPath, "devices", $process_killed, 60 * 1000)
		$cmdOutput=StringReplace($cmdOutput, ChrW(09), ChrW(35) & ChrW(35) & ChrW(35) & ChrW(35) & ChrW(35) & ChrW(35)& ChrW(35))
		$aArrays = StringSplit($cmdOutput, @CR, $STR_NOCOUNT)
		For $il = 0 To UBound($aArrays) -1
			If Not StringIsSpace($aArrays[$il]) Then
				Local $aArray = StringSplit($aArrays[$il], ChrW(35), $STR_NOCOUNT)
				If not @error Then
					If UBound($aArray) > 6 Then
						_ArrayAdd($aTmp, StringReplace($aArray[0], @LF, ""), $ARRAYFILL_FORCE_STRING)
					EndIf
				EndIf
			EndIf
		Next
		$g_sAndroidAdbDevice = $aTmp[0]
				
		; get screencap paths: Name: 'picture', Host path: 'C:\Users\Administrator\Pictures\MEmu Photo' (machine mapping), writable
		; see also: VBoxManage setextradata External VBoxInternal2/SharedFoldersEnableSymlinksCreate/picture 1
		$g_sAndroidPicturesPath = "/mnt/shared/picture/"
		$g_sAndroidSharedFolderName = "picture"
		ConfigureSharedFolder(0) ; something like C:\Users\Administrator\Pictures\External Photo\

		; Update Android Screen and Window
		UpdateExternalConfig()
	EndIf

	Return True

EndFunc   ;==>InitExternal

Func SetScreenExternal()
	; https://nerdschalk.com/change-screen-resolution-adb-android/
	If Not $g_bRunState Then Return False
	If Not InitAndroid() Then Return False

	Local $cmdOutput, $process_killed
	; shell wm density 160
	; shell wm size 860x672
	; shell reboot
		
	$cmdOutput = LaunchConsole($g_sAndroidAdbPath, AddSpace($g_sAndroidAdbGlobalOptions) & " -s " & $g_sAndroidAdbDevice & " shell dumpsys display | findstr mOverrideDisplayInfo", $process_killed)
	
	If StringInStr($cmdOutput, "860 x 672") < 1 And StringInStr($cmdOutput, "density 160") < 1 Then
	
		; wm density 160
		$cmdOutput = AndroidAdbSendShellCommand("wm density 160", Default, Default, False)
	
		; Set androidResolution
		$cmdOutput = AndroidAdbSendShellCommand("wm size 860x672", Default, Default, False)
	
		; Set font size to normal
		AndroidSetFontSizeNormal() 
		
		; Set expected dpi
		$cmdOutput = AndroidAdbSendShellCommand("shell reboot", Default, Default, False)
		
	EndIf

	ConfigureSharedFolder(1, True)
	ConfigureSharedFolder(2, True)
	
	; If Not $g_bRunState Then Return False
	; If Not InitAndroid() Then Return False


	; Set width and height
	; $cmdOutput = LaunchConsole($__VBoxManage_Path, "guestproperty set " & $g_sAndroidInstance & " vbox_graph_mode " & $g_iAndroidClientWidth & "x" & $g_iAndroidClientHeight & "-16", $process_killed)

	; Set dpi
	; $cmdOutput = LaunchConsole($__VBoxManage_Path, "guestproperty set " & $g_sAndroidInstance & " vbox_dpi 160", $process_killed)

	; vboxmanage sharedfolder add External --name picture --hostpath "C:\Users\Administrator\Pictures\External Photo" --automount
	; ConfigureSharedFolder(1, True)
	; ConfigureSharedFolder(2, True)

	; Return True
EndFunc   ;==>SetScreenExternal

Func RebootExternalSetScreen()

	Return RebootAndroidSetScreenDefault()

EndFunc   ;==>RebootExternalSetScreen

Func CheckScreenExternal($bSetLog = True)

	If Not InitAndroid() Then Return False

	Local $cmdOutput, $process_killed, $iErrCnt
	; shell wm density 160
	; shell wm size 860x672
	; shell reboot
		
	$cmdOutput = LaunchConsole($g_sAndroidAdbPath, AddSpace($g_sAndroidAdbGlobalOptions) & " -s " & $g_sAndroidAdbDevice & " shell dumpsys display | findstr mOverrideDisplayInfo", $process_killed)
	
	If StringInStr($cmdOutput, "860 x 672") < 1 And StringInStr($cmdOutput, "density 160") < 1 Then
		Return False
	EndIf

	; check if shared folder exists
	If ConfigureSharedFolder(1, $bSetLog) Then $iErrCnt += 1

	Return True

EndFunc   ;==>CheckScreenExternal

Func UpdateExternalConfig()
	Return UpdateExternalWindowState()
EndFunc   ;==>UpdateExternalConfig

Func UpdateExternalWindowState()
#cs
	WinGetAndroidHandle()
	ControlGetPos($g_hAndroidWindow, $g_sAppPaneName, $g_sAppClassInstance)
	If @error = 1 Then
		; Window not found, nothing to do
		SetError(0, 0, 0)
		Return False
	EndIf

	Local $acw = $g_avAndroidAppConfig[$g_iAndroidConfig][5]
	Local $ach = $g_avAndroidAppConfig[$g_iAndroidConfig][6]
	Local $aww = $g_avAndroidAppConfig[$g_iAndroidConfig][7]
	Local $awh = $g_avAndroidAppConfig[$g_iAndroidConfig][8]

	Local $v = GetVersionNormalized($g_sAndroidVersion)
	For $i = 0 To UBound($__External_Window) - 1
		Local $v2 = GetVersionNormalized($__External_Window[$i][0])
		If $v >= $v2 Then
			SetDebugLog("Using Window sizes of " & $g_sAndroidEmulator & " " & $__External_Window[$i][0])
			$aww = $__External_Window[$i][1]
			$awh = $__External_Window[$i][2]
			ExitLoop
		EndIf
	Next

	Local $i
	Local $Values[4][3] = [ _
			["Screen Width", $g_iAndroidClientWidth, $g_iAndroidClientWidth], _
			["Screen Height", $g_iAndroidClientHeight, $g_iAndroidClientHeight], _
			["Window Width", $g_iAndroidWindowWidth, $g_iAndroidWindowWidth], _
			["Window Height", $g_iAndroidWindowHeight, $g_iAndroidWindowHeight] _
			]
	Local $bChanged = False, $ok = False
	$Values[0][2] = $acw
	$Values[1][2] = $ach
	$Values[2][2] = $aww
	$Values[3][2] = $awh

	$g_iAndroidClientWidth = $Values[0][2]
	$g_iAndroidClientHeight = $Values[1][2]
	$g_iAndroidWindowWidth = $Values[2][2]
	$g_iAndroidWindowHeight = $Values[3][2]

	For $i = 0 To UBound($Values) - 1
		If $Values[$i][1] <> $Values[$i][2] Then
			$bChanged = True
			SetDebugLog($g_sAndroidEmulator & " " & $Values[$i][0] & " updated from " & $Values[$i][1] & " to " & $Values[$i][2])
		EndIf
	Next

	Return $bChanged
	#ce
EndFunc   ;==>UpdateExternalWindowState

Func CloseExternal()
	Return CloseVboxAndroidSvc()
EndFunc   ;==>CloseExternal

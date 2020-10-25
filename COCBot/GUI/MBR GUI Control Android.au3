; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Android
; Description ...: This file Includes all functions to current GUI
; Syntax ........: None
; Parameters ....:
; Return values .: None
; Author ........: MMHK (11-2016)
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func LoadCOCDistributorsComboBox()
	Local $sDistributors = $g_sNO_COC
	Local $aDistributorsData = GetCOCDistributors()

	If @error = 2 Then
		$sDistributors = $g_sUNKNOWN_COC
	ElseIf IsArray($aDistributorsData) Then
		$sDistributors = _ArrayToString($aDistributorsData, "|")
	EndIf

	GUICtrlSetData($g_hCmbCOCDistributors, "", "")
	GUICtrlSetData($g_hCmbCOCDistributors, $sDistributors)
EndFunc   ;==>LoadCOCDistributorsComboBox

Func SetCurSelCmbCOCDistributors()
	Local $sIniDistributor
	Local $iIndex
	If _GUICtrlComboBox_GetCount($g_hCmbCOCDistributors) = 1 Then ; when no/unknown/one coc installed
		_GUICtrlComboBox_SetCurSel($g_hCmbCOCDistributors, 0)
		GUICtrlSetState($g_hCmbCOCDistributors, $GUI_DISABLE)
	Else
		$sIniDistributor = GetCOCTranslated($g_sAndroidGameDistributor)
		$iIndex = _GUICtrlComboBox_FindStringExact($g_hCmbCOCDistributors, $sIniDistributor)
		If $iIndex = -1 Then ; not found on combo
			_GUICtrlComboBox_SetCurSel($g_hCmbCOCDistributors, 0)
		Else
			_GUICtrlComboBox_SetCurSel($g_hCmbCOCDistributors, $iIndex)
		EndIf
		GUICtrlSetState($g_hCmbCOCDistributors, $GUI_ENABLE)
	EndIf
EndFunc   ;==>SetCurSelCmbCOCDistributors

Func cmbCOCDistributors()
	Local $sDistributor
	_GUICtrlComboBox_GetLBText($g_hCmbCOCDistributors, _GUICtrlComboBox_GetCurSel($g_hCmbCOCDistributors), $sDistributor)

	If $sDistributor = $g_sUserGameDistributor Then ; ini user option
		$g_sAndroidGameDistributor = $g_sUserGameDistributor
		$g_sAndroidGamePackage = $g_sUserGamePackage
		$g_sAndroidGameClass = $g_sUserGameClass
	Else
		GetCOCUnTranslated($sDistributor)
		If Not @error Then ; not no/unknown
			$g_sAndroidGameDistributor = GetCOCUnTranslated($sDistributor)
			$g_sAndroidGamePackage = GetCOCPackage($sDistributor)
			$g_sAndroidGameClass = GetCOCClass($sDistributor)
		EndIf ; else existing one (no emulator bot startup compatible), if wrong ini info either kept or replaced by cursel when saveconfig, not fall back to google
	EndIf
EndFunc   ;==>cmbCOCDistributors

#Region - Custom Instances - Team AIO Mod++
Func DistributorsUpdateGUI()
	LoadCOCDistributorsComboBox()
	SetCurSelCmbCOCDistributors()
EndFunc   ;==>DistributorsUpdateGUI

Func cmbEmulators()
	getAllEmulatorsInstances()
	Local $emulator = GUICtrlRead($g_hCmbEmulators)
	If MsgBox($MB_YESNO, "Emulator Selection", $emulator & ", Is correct?" & @CRLF & "Any mistake and your profile will be not useful!", 10) = $IDYES Then
		SetLog("Emulator " & $emulator & " Selected at first instance. Please reboot or select instance and reboot.", $COLOR_INFO)
		$g_sAndroidEmulator = $emulator
		$g_sAndroidInstance = GUICtrlRead($g_hCmbInstances)
		UpdateAndroidConfig($g_sAndroidInstance, $g_sAndroidEmulator)
		InitAndroidConfig(True)
		BtnSaveprofile()
	Else
		_GUICtrlComboBox_SelectString($g_hCmbEmulators, $g_sAndroidEmulator)
		getAllEmulatorsInstances()
	EndIf
EndFunc   ;==>cmbEmulators

Func cmbInstances()
	Local $instance = GUICtrlRead($g_hCmbInstances)
	If MsgBox($MB_YESNO, "Instance Selection", $instance & ", Is correct?" & @CRLF & "If 'yes' is necessary reboot the 'bot'.", 10) = $IDYES Then
		SetLog("Instance " & $instance & " Selected. Please reset.", $COLOR_INFO)
		$g_sAndroidEmulator = GUICtrlRead($g_hCmbEmulators)
		$g_sAndroidInstance = $instance
		UpdateAndroidConfig($g_sAndroidInstance, $g_sAndroidEmulator)
		InitAndroidConfig(True)
		BtnSaveprofile()
	Else
		getAllEmulatorsInstances()
	EndIf
EndFunc   ;==>cmbInstances

Func getAllEmulators()
	Local $cmbString = ""
	GUICtrlSetData($g_hCmbEmulators, '')
	$__BlueStacks_Version = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks\", "Version")
	If Not @error Then
		If GetVersionNormalized($__BlueStacks_Version) < GetVersionNormalized("0.10") Then $cmbString &= "BlueStacks|"
		If GetVersionNormalized($__BlueStacks_Version) > GetVersionNormalized("1.0") Then $cmbString &= "BlueStacks2|"
	EndIf
	Local $Version = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\Nox\", "DisplayVersion")
	If Not @error Then
		$cmbString &= "Nox|"
	EndIf
	Local $MEmuVersion = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\MEmu\", "DisplayVersion")
	If Not @error Then
		$cmbString &= "MEmu|"
	EndIf
	Local $iToolsVersion = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\ThinkSky\iToolsAVM\", "DisplayVersion")
	If Not @error Then
		$cmbString &= "iTools|"
	EndIf
	Local $result = StringRight($cmbString, 1)
	If $result == "|" Then $cmbString = StringTrimRight($cmbString, 1)
	If $g_bDebugAndroid Then SetLog("All Emulator found in your machine: " & $cmbString, $COLOR_INFO)
	GUICtrlSetData($g_hCmbEmulators, $cmbString)
	_GUICtrlComboBox_SelectString($g_hCmbEmulators, $g_sAndroidEmulator)
	getAllEmulatorsInstances()
EndFunc   ;==>getAllEmulators

Func getAllEmulatorsInstances()
	GUICtrlSetData($g_hCmbInstances, '')
	Local $emulator = GUICtrlRead($g_hCmbEmulators)
	Local $path = ""
	Switch $emulator
		#CS
		Case "BlueStacks"
			GUICtrlSetData($g_hCmbInstances, "Android", "Android")
			Return
		Case "BlueStacks2"
			GUICtrlSetData($g_hCmbInstances, "Android", "Android")
			Return
		#CE
		Case "Nox"
			$path = GetNoxPath() & "\BignoxVMS"
		Case "MEmu"
			$path = GetMEmuPath() & "\MemuHyperv VMs"
		Case "iTools"
			$path = GetiToolsPath() & "\Repos\VMs"
		Case Else
			GUICtrlSetData($g_hCmbInstances, "Android", "Android")
			Return
	EndSwitch
	$path = StringReplace($path, "\\", "\")
	Local $folders = _FileListToArray($path, "*", $FLTA_FOLDERS)
	If @error = 1 Then
		SetLog($emulator & " -- Path was invalid. " & $path)
		Return
	EndIf
	If @error = 4 Then
		SetLog($emulator & " -- No file(s) were found. " & $path)
		Return
	EndIf
	_ArrayDelete($folders, 0)
	GUICtrlSetData($g_hCmbInstances, _ArrayToString($folders))
	If $emulator == $g_sAndroidEmulator Then
		_GUICtrlComboBox_SelectString($g_hCmbInstances, $g_sAndroidInstance)
	Else
		_GUICtrlComboBox_SetCurSel($g_hCmbInstances, 0)
	EndIf
EndFunc   ;==>getAllEmulatorsInstances
#EndRegion - Custom Instances - Team AIO Mod++

Func AndroidSuspendFlagsToIndex($iFlags)
	Local $idx = 0
	If BitAND($iFlags, 2) > 0 Then
		$idx = 2
	ElseIf BitAND($iFlags, 1) > 0 Then
		$idx = 1
	EndIf
	If $idx > 0 And BitAND($iFlags, 4) > 0 Then $idx += 2
	Return $idx
EndFunc   ;==>AndroidSuspendFlagsToIndex

Func AndroidSuspendIndexToFlags($idx)
	Local $iFlags = 0
	Switch $idx
		Case 1
			$iFlags = 1
		Case 2
			$iFlags = 2
		Case 3
			$iFlags = 1 + 4
		Case 4
			$iFlags = 2 + 4
	EndSwitch
	Return $iFlags
EndFunc   ;==>AndroidSuspendIndexToFlags

Func cmbSuspendAndroid()
	$g_iAndroidSuspendModeFlags = AndroidSuspendIndexToFlags(_GUICtrlComboBox_GetCurSel($g_hCmbSuspendAndroid))
EndFunc   ;==>cmbSuspendAndroid

Func cmbAndroidBackgroundMode()
	$g_iAndroidBackgroundMode = _GUICtrlComboBox_GetCurSel($g_hCmbAndroidBackgroundMode)
	UpdateAndroidBackgroundMode()
EndFunc   ;==>cmbAndroidBackgroundMode

Func EnableShowTouchs()
	AndroidAdbSendShellCommand("content insert --uri content://settings/system --bind name:s:show_touches --bind value:i:1")
	SetDebugLog("EnableShowTouchs ON")
EndFunc   ;==>EnableShowTouchs

Func DisableShowTouchs()
	AndroidAdbSendShellCommand("content insert --uri content://settings/system --bind name:s:show_touches --bind value:i:0")
	SetDebugLog("EnableShowTouchs OFF")
EndFunc   ;==>DisableShowTouchs

Func sldAdditionalClickDelay($bSetControls = False)
	If $bSetControls Then
		GUICtrlSetData($g_hSldAdditionalClickDelay, Int($g_iAndroidControlClickAdditionalDelay / 2))
		GUICtrlSetData($g_hLblAdditionalClickDelay, $g_iAndroidControlClickAdditionalDelay & " ms")
	Else
		Local $iValue = GUICtrlRead($g_hSldAdditionalClickDelay) * 2
		If $iValue <> $g_iAndroidControlClickAdditionalDelay Then
			$g_iAndroidControlClickAdditionalDelay = $iValue
			GUICtrlSetData($g_hLblAdditionalClickDelay, $g_iAndroidControlClickAdditionalDelay & " ms")
		EndIf
	EndIf
	Opt("MouseClickDelay", GetClickUpDelay()) ;Default: 10 milliseconds
	Opt("MouseClickDownDelay", GetClickDownDelay()) ;Default: 5 milliseconds
EndFunc   ;==>sldAdditionalClickDelay

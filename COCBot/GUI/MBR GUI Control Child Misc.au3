; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Misc
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MyBot.run team
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func cmbProfile()
	If LoadProfile() Then
		Return True
	EndIf
	; restore combo to current profile
	_GUICtrlComboBox_SelectString($g_hCmbProfile, $g_sProfileCurrentName)
	Return False
EndFunc   ;==>cmbProfile

Func LoadProfile($bSaveCurrentProfile = True)
	If $bSaveCurrentProfile Then
		saveConfig()
	EndIf

	; Setup the profile in case it doesn't exist.
	If setupProfile() Then
		readConfig()
		applyConfig()
		saveConfig()
		SetLog("Profile " & $g_sProfileCurrentName & " loaded from " & $g_sProfileConfigPath, $COLOR_SUCCESS)
		Return True
	EndIf
	Return False
EndFunc   ;==>LoadProfile

Func btnAddConfirm()
	Switch @GUI_CtrlId
		Case $g_hBtnAddProfile
			GUICtrlSetState($g_hCmbProfile, $GUI_HIDE)
			GUICtrlSetState($g_hTxtVillageName, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_HIDE)
		Case $g_hBtnConfirmAddProfile
			Local $newProfileName = StringRegExpReplace(GUICtrlRead($g_hTxtVillageName), '[/:*?"<>|]', '_')
			If FileExists($g_sProfilePath & "\" & $newProfileName) Then
				MsgBox($MB_ICONWARNING, GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_01", "Profile Already Exists"), GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_02", "%s already exists.\r\nPlease choose another name for your profile.", $newProfileName))
				Return
			EndIf

			saveConfig() ; save current config so we don't miss anything recently changed
			readConfig() ; read it back in to reset all of the .ini file global variables

			$g_sProfileCurrentName = $newProfileName
			; Setup the profile if it doesn't exist.
			createProfile()
			setupProfileComboBox()
			selectProfile()
			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)

			If GUICtrlGetState($g_hBtnDeleteProfile) <> $GUI_ENABLE Then GUICtrlSetState($g_hBtnDeleteProfile, $GUI_ENABLE)
			If GUICtrlGetState($g_hBtnRenameProfile) <> $GUI_ENABLE Then GUICtrlSetState($g_hBtnRenameProfile, $GUI_ENABLE)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch
EndFunc   ;==>btnAddConfirm

Func btnDeleteCancel()
	Switch @GUI_CtrlId
		Case $g_hBtnDeleteProfile
			Local $msgboxAnswer = MsgBox($MB_ICONWARNING + $MB_OKCANCEL, GetTranslatedFileIni("MBR Popups", "Delete_Profile_01", "Delete Profile"), GetTranslatedFileIni("MBR Popups", "Delete_Profile_02", "Are you sure you really want to delete the profile?\r\nThis action can not be undone."))
			If $msgboxAnswer = $IDOK Then
				; Confirmed profile deletion so delete it.
				If deleteProfile() Then
					; reset inputtext
					GUICtrlSetData($g_hTxtVillageName, GetTranslatedFileIni("MBR Popups", "MyVillage", "MyVillage"))
					If _GUICtrlComboBox_GetCount($g_hCmbProfile) > 1 Then
						; select existing profile
						setupProfileComboBox()
						selectProfile()
					Else
						; create new default profile
						createProfile(True)
					EndIf
				EndIf
			EndIf
		Case $g_hBtnCancelProfileChange
			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch

	If GUICtrlRead($g_hCmbProfile) = "<No Profiles>" Then
		GUICtrlSetState($g_hBtnDeleteProfile, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnRenameProfile, $GUI_DISABLE)
	EndIf
EndFunc   ;==>btnDeleteCancel

Func btnRenameConfirm()
	Switch @GUI_CtrlId
		Case $g_hBtnRenameProfile
			Local $sProfile = GUICtrlRead($g_hCmbProfile)
			If aquireProfileMutex($sProfile, False, True) = 0 Then
				Return
			EndIf
			GUICtrlSetData($g_hTxtVillageName, $sProfile)
			GUICtrlSetState($g_hCmbProfile, $GUI_HIDE)
			GUICtrlSetState($g_hTxtVillageName, $GUI_SHOW)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_SHOW)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_HIDE)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_HIDE)
		Case $g_hBtnConfirmRenameProfile
			Local $newProfileName = StringRegExpReplace(GUICtrlRead($g_hTxtVillageName), '[/:*?"<>|]', '_')
			If FileExists($g_sProfilePath & "\" & $newProfileName) Then
				MsgBox($MB_ICONWARNING, GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_01", "Profile Already Exists"), $newProfileName & " " & GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_03", "already exists.") & @CRLF & GetTranslatedFileIni("MBR Popups", "Profile_Already_Exists_04", "Please choose another name for your profile"))
				Return
			EndIf

			$g_sProfileCurrentName = $newProfileName
			; Rename the profile.
			renameProfile()
			setupProfileComboBox()
			selectProfile()

			GUICtrlSetState($g_hTxtVillageName, $GUI_HIDE)
			GUICtrlSetState($g_hCmbProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmAddProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnAddProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnCancelProfileChange, $GUI_HIDE)
			GUICtrlSetState($g_hBtnDeleteProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnConfirmRenameProfile, $GUI_HIDE)
			GUICtrlSetState($g_hBtnRenameProfile, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPullSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnPushSharedPrefs, $GUI_SHOW)
			GUICtrlSetState($g_hBtnSaveprofile, $GUI_SHOW)
		Case Else
			SetLog("If you are seeing this log message there is something wrong.", $COLOR_ERROR)
	EndSwitch
EndFunc   ;==>btnRenameConfirm

Func btnPullSharedPrefs()
	PullSharedPrefs()
EndFunc   ;==>btnPullSharedPrefs

 ; Custom fix - Team AIO Mod++
Func btnPushSharedPrefs()
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	CloseCOC()
	$g_bRunState = $bWasRunState
	PushSharedPrefs()
EndFunc   ;==>btnPushSharedPrefs

Func BtnSaveprofile()
	Setlog("Saving your setting...", $COLOR_INFO)
	SaveConfig()
	readConfig()
	applyConfig()
	Setlog("Done!", $COLOR_SUCCESS)
EndFunc   ;==>BtnSaveprofile

Func OnlySCIDAccounts()
	; $g_hChkOnlySCIDAccounts
	If GUICtrlRead($g_hChkOnlySCIDAccounts) = $GUI_CHECKED Then
		GUICtrlSetState($g_hCmbWhatSCIDAccount2Use, $GUI_ENABLE)
		WhatSCIDAccount2Use()
		$g_bOnlySCIDAccounts = True
	Else
		GUICtrlSetState($g_hCmbWhatSCIDAccount2Use, $GUI_DISABLE)
		$g_bOnlySCIDAccounts = False
	EndIf
EndFunc   ;==>OnlySCIDAccounts

Func WhatSCIDAccount2Use()
	; $g_hCmbWhatSCIDAccount2Use
	$g_iWhatSCIDAccount2Use = _GUICtrlComboBox_GetCurSel($g_hCmbWhatSCIDAccount2Use)
EndFunc   ;==>WhatSCIDAccount2Use

Func cmbBotCond()
	Local $iCond = _GUICtrlComboBox_GetCurSel($g_hCmbBotCond)
	If $iCond = 15 Then
		If _GUICtrlComboBox_GetCurSel($g_hCmbHoursStop) = 0 Then _GUICtrlComboBox_SetCurSel($g_hCmbHoursStop, 1)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_ENABLE)
	Else
		_GUICtrlComboBox_SetCurSel($g_hCmbHoursStop, 0)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_DISABLE)
	EndIf
	If $iCond = 22 Then
		GUICtrlSetState($g_hCmbHoursStop, $GUI_HIDE)
		For $i = $g_ahTxtResumeAttackLoot[$eLootTrophy] To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_HIDE)
		Next
		_GUI_Value_STATE("SHOW", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
		_GUI_Value_STATE("ENABLE", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
	Else
		_GUI_Value_STATE("HIDE", $g_hCmbTimeStop & "#" & $g_hCmbResumeTime)
		GUICtrlSetState($g_hCmbHoursStop, $GUI_SHOW)
		For $i = $g_ahTxtResumeAttackLoot[$eLootTrophy] To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_SHOW)
		Next
	EndIf

	For $i = $g_LblResumeAttack To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
		GUICtrlSetState($i, $GUI_DISABLE)
	Next
	If _GUICtrlComboBox_GetCurSel($g_hCmbBotCommand) <> 0 Then Return
	If $iCond <= 14 Or $iCond = 22 Then GUICtrlSetState($g_LblResumeAttack, $GUI_ENABLE)
	If $iCond <= 14 Then GUICtrlSetState($g_hChkCollectStarBonus, $GUI_ENABLE)
	If $iCond <= 6 Or $iCond = 8 Or $iCond = 10 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootGold], $GUI_ENABLE)
	If $iCond <= 5 Or $iCond = 7 Or $iCond = 9 Or $iCond = 11 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootElixir], $GUI_ENABLE)
	If $iCond = 13 Or $iCond = 14 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootDarkElixir], $GUI_ENABLE)
	If $iCond <= 3 Or ($iCond >= 6 And $iCond <= 9) Or $iCond = 12 Then GUICtrlSetState($g_ahTxtResumeAttackLoot[$eLootTrophy], $GUI_ENABLE)
	If $iCond = 22 Then GUICtrlSetState($g_hCmbResumeTime, $GUI_ENABLE)
EndFunc   ;==>cmbBotCond

Func chkBotStop()
	If GUICtrlRead($g_hChkBotStop) = $GUI_CHECKED Then
		For $i = $g_hCmbBotCommand To $g_hCmbBotCond
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
		cmbBotCond()
	Else
		For $i = $g_hCmbBotCommand To $g_ahTxtResumeAttackLoot[$eLootDarkElixir]
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc   ;==>chkBotStop

#Region - Custom Locate - Team AIO Mod++
Func btnLocateClanCastle()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateClanCastle(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateClanCastle")
	ChkLocations()
EndFunc   ;==>btnLocateClanCastle

Func btnLocateKingAltar()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateKingAltar(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateKingAltar")
	ChkLocations()
EndFunc   ;==>btnLocateKingAltar

Func btnLocateChampionAltar()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateChampionAltar(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateChampionAltar")
	ChkLocations()
EndFunc   ;==>btnLocateChampionAltar

Func btnLocateQueenAltar()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateQueenAltar(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateQueenAltar")
	ChkLocations()
EndFunc   ;==>btnLocateQueenAltar

Func btnLocateWardenAltar()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateWardenAltar(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateWardenAltar")
	ChkLocations()
EndFunc   ;==>btnLocateWardenAltar

Func btnLocateTownHall()
	Local $wasRunState = $g_bRunState
	Local $g_iOldTownHallLevel = $g_iTownHallLevel
	$g_bRunState = True
	ZoomOut()
	LocateTownHall(True)
	If Not $g_iOldTownHallLevel = $g_iTownHallLevel Then
		_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 600)
		Local $sText = @CRLF & GetTranslatedFileIni("MBR Popups", "Locating_your_TH", "If you locating your TH because you upgraded,") & @CRLF & GetTranslatedFileIni("MBR Popups", "Must_restart_bot", "then you must restart bot!!!") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "OK_to_restart_bot", "Click OK to restart bot,") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", "Or Click Cancel to exit") & @CRLF
		Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Close_Bot", "Close Bot Please!"), $sText, 120)
		SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
		If $MsgBox = 1 Then
			RestartBot(False, $wasRunState)
		EndIf
	EndIf
	$g_bRunState = $wasRunState
	AndroidShield("btnLocateTownHall")
	ChkLocations()
EndFunc   ;==>btnLocateTownHall

Func btnResetBuilding()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	While 1
		If _Sleep(500) Then Return
		If FileExists($g_sProfileBuildingPath) Then
			_ExtMsgBoxSet(1 + 64, $SS_CENTER, 0x004080, 0xFFFF00, 12, "Tahoma", 600)
			Local $sText = @CRLF & GetTranslatedFileIni("MBR Popups", "Delete_and_Reset_Building_info", "Click OK to Delete and Reset all Building info,") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Bot_will_exit", "NOTE =>> Bot will exit and need to be restarted when complete") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", "Or Click Cancel to exit") & @CRLF
			Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", "Ok|Cancel"), GetTranslatedFileIni("MBR Popups", "Delete_Building_Info", "Delete Building Information ?"), $sText, 120)
			SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
			If $MsgBox = 1 Then
				Local $sText = @CRLF & GetTranslatedFileIni("MBR Popups", "Sure_Delete_Building_Info", "Are you 100% sure you want to delete Building information ?") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Delete_then_restart_bot", "Click OK to Delete and then restart the bot (manually)") & @CRLF & @CRLF & GetTranslatedFileIni("MBR Popups", "Cancel_to_exit", -1) & @CRLF
				Local $MsgBox = _ExtMsgBox(0, GetTranslatedFileIni("MBR Popups", "Ok_Cancel", -1), GetTranslatedFileIni("MBR Popups", "Delete_Building_Info", -1), $sText, 120)
				SetDebugLog("$MsgBox= " & $MsgBox, $COLOR_DEBUG)
				If $MsgBox = 1 Then
					Local $result = FileDelete($g_sProfileBuildingPath)
					If $result = 0 Then
						SetLog("Unable to remove building.ini file, please use manual method", $COLOR_ERROR)
					Else
						BotClose(False)
					EndIf
				EndIf
			EndIf
		Else
			SetLog("Building.ini file does not exist", $COLOR_INFO)
		EndIf
		ExitLoop
	WEnd
	$g_bRunState = $wasRunState
	AndroidShield("btnResetBuilding")
EndFunc   ;==>btnResetBuilding

Func ChkLocations()
	If (isInsideDiamond($g_aiTownHallPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateTH, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateTH, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiClanCastlePos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateCastle, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateCastle, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiKingAltarPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateKingAltar, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateKingAltar, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiQueenAltarPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateQueenAltar, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateQueenAltar, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiWardenAltarPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateWardenAltar, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateWardenAltar, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiChampionAltarPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateChampionAltar, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateChampionAltar, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiLaboratoryPos) = False) Then
		GUICtrlSetBkColor($g_hlblLocateLaboratory, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocateLaboratory, $COLOR_SUCCESS)
	EndIf
	If (isInsideDiamond($g_aiPetHousePos) = False) Then
		GUICtrlSetBkColor($g_hlblLocatePetHouse, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hlblLocatePetHouse, $COLOR_SUCCESS)
	EndIf
EndFunc   ;==>ChkLocations

Func btnLab()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocateLab(True)
	$g_bRunState = $wasRunState
	AndroidShield("btnLab")
	ChkLocations()
EndFunc   ;==>btnLab

Func btnPet()
	Local $wasRunState = $g_bRunState
	$g_bRunState = True
	ZoomOut()
	LocatePetHouse(True, True)
	$g_bRunState = $wasRunState
	AndroidShield("btnPet")
	ChkLocations()
EndFunc   ;==>btnPet
#EndRegion - Custom Locate - Team AIO Mod++

Func chkTrophyAtkDead()
	If GUICtrlRead($g_hChkTrophyAtkDead) = $GUI_CHECKED Then
		$g_bDropTrophyAtkDead = True
		GUICtrlSetState($g_hTxtDropTrophyArmyMin, $GUI_ENABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyMin, $GUI_ENABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyPercent, $GUI_ENABLE)
	Else
		$g_bDropTrophyAtkDead = False
		GUICtrlSetState($g_hTxtDropTrophyArmyMin, $GUI_DISABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyMin, $GUI_DISABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyPercent, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkTrophyAtkDead

Func chkTrophyRange()
	If GUICtrlRead($g_hChkTrophyRange) = $GUI_CHECKED Then
		GUICtrlSetState($g_hTxtDropTrophy, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtMaxTrophy, $GUI_ENABLE)
		GUICtrlSetState($g_hChkTrophyHeroes, $GUI_ENABLE)
		GUICtrlSetState($g_hChkTrophyAtkDead, $GUI_ENABLE)
		#Region - Drop Throphy - Team AIO Mod++
		GUICtrlSetState($g_hChkTrophyTroops, $GUI_ENABLE)
		GUICtrlSetState($g_hChkTrophyHeroesAndTroops, $GUI_ENABLE)
		GUICtrlSetState($g_hChkNoDropIfShield, $GUI_ENABLE)
		#EndRegion - Drop Throphy - Team AIO Mod++
		chkTrophyAtkDead()
		chkTrophyHeroes()
	Else
		GUICtrlSetState($g_hTxtDropTrophy, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtMaxTrophy, $GUI_DISABLE)
		GUICtrlSetState($g_hChkTrophyHeroes, $GUI_DISABLE)
		GUICtrlSetState($g_hChkTrophyAtkDead, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtDropTrophyArmyMin, $GUI_DISABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyMin, $GUI_DISABLE)
		GUICtrlSetState($g_hLblDropTrophyArmyPercent, $GUI_DISABLE)
		GUICtrlSetState($g_hLblTrophyHeroesPriority, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbTrophyHeroesPriority, $GUI_DISABLE)
		#Region - Drop Throphy - Team AIO Mod++
		GUICtrlSetState($g_hChkTrophyTroops, $GUI_DISABLE)
		GUICtrlSetState($g_hChkTrophyHeroesAndTroops, $GUI_DISABLE)
		GUICtrlSetState($g_hChkNoDropIfShield, $GUI_DISABLE)
		#EndRegion - Drop Throphy - Team AIO Mod++
	EndIf
EndFunc   ;==>chkTrophyRange

Func TxtDropTrophy()
	If Number(GUICtrlRead($g_hTxtDropTrophy)) > Number(GUICtrlRead($g_hTxtMaxTrophy)) Then
		GUICtrlSetData($g_hTxtMaxTrophy, GUICtrlRead($g_hTxtDropTrophy))
		TxtMaxTrophy()
	EndIf
	_GUI_Value_STATE("HIDE", $g_aGroupListPicMinTrophy)
	If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[21][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueLegend], $GUI_SHOW)
		GUICtrlSetData($g_hLblMinTrophies, "")
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[18][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueTitan], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[20][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[19][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[18][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[15][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueChampion], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[17][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[16][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[15][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[12][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueMaster], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[14][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[13][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[12][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[9][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueCrystal], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[11][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[10][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[9][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[6][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueGold], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[8][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[7][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[6][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[3][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueSilver], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[5][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[4][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[3][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[0][4]) Then
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueBronze], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[2][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[1][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtDropTrophy)) >= Number($g_asLeagueDetails[0][4]) Then
			GUICtrlSetData($g_hLblMinTrophies, "3")
		EndIf
	Else
		GUICtrlSetState($g_hPicMinTrophies[$eLeagueUnranked], $GUI_SHOW)
		GUICtrlSetData($g_hLblMinTrophies, "")
	EndIf
EndFunc   ;==>TxtDropTrophy

Func TxtMaxTrophy()
	If Number(GUICtrlRead($g_hTxtDropTrophy)) > Number(GUICtrlRead($g_hTxtMaxTrophy)) Then
		GUICtrlSetData($g_hTxtMaxTrophy, GUICtrlRead($g_hTxtDropTrophy))
	EndIf
	_GUI_Value_STATE("HIDE", $g_aGroupListPicMaxTrophy)
	If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[21][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueLegend], $GUI_SHOW)
		GUICtrlSetData($g_hLblMaxTrophies, "")
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[18][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueTitan], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[20][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[19][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[18][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[15][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueChampion], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[17][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[16][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[15][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[12][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueMaster], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[14][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[13][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[12][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[9][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueCrystal], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[11][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[10][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[9][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[6][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueGold], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[8][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[7][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[6][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[3][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueSilver], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[5][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[4][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[3][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[0][4]) Then
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueBronze], $GUI_SHOW)
		If Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[2][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "1")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[1][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "2")
		ElseIf Number(GUICtrlRead($g_hTxtMaxTrophy)) >= Number($g_asLeagueDetails[0][4]) Then
			GUICtrlSetData($g_hLblMaxTrophies, "3")
		EndIf
	Else
		GUICtrlSetState($g_hPicMaxTrophies[$eLeagueUnranked], $GUI_SHOW)
		GUICtrlSetData($g_hLblMaxTrophies, "")
	EndIf
EndFunc   ;==>TxtMaxTrophy

Func chkTrophyHeroes()
	If GUICtrlRead($g_hChkTrophyHeroes) = $GUI_CHECKED Or GUICtrlRead($g_hChkTrophyHeroesAndTroops) = $GUI_CHECKED Then ; Drop Throphy - Team AIO Mod++
		GUICtrlSetState($g_hLblTrophyHeroesPriority, $GUI_ENABLE)
		GUICtrlSetState($g_hCmbTrophyHeroesPriority, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hLblTrophyHeroesPriority, $GUI_DISABLE)
		GUICtrlSetState($g_hCmbTrophyHeroesPriority, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkTrophyHeroes

Func ChkCollect()
	If GUICtrlRead($g_hChkCollect) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkCollectLootCar, $GUI_ENABLE)
		GUICtrlSetState($g_hChkTreasuryCollect, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtCollectGold, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtCollectElixir, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtCollectDark, $GUI_ENABLE)
		GUICtrlSetState($g_hChkResourcePotion, $GUI_ENABLE) ; Magic items - Team AIO Mod++
	Else
		GUICtrlSetState($g_hChkCollectLootCar, $GUI_UNCHECKED)
		GUICtrlSetState($g_hChkCollectLootCar, $GUI_DISABLE)
		GUICtrlSetState($g_hChkTreasuryCollect, $GUI_UNCHECKED)
		GUICtrlSetState($g_hChkTreasuryCollect, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtCollectGold, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtCollectElixir, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtCollectDark, $GUI_DISABLE)
		GUICtrlSetState($g_hChkResourcePotion, $GUI_UNCHECKED) ; Magic items - Team AIO Mod++
	EndIf
	ChkTreasuryCollect()
	ChkResourcePotion() ; Magic items - Team AIO Mod++
EndFunc   ;==>ChkCollect

; Magic items - Team AIO Mod++
Func ChkResourcePotion()
	$g_bChkResourcePotion = (GUICtrlRead($g_hChkResourcePotion) = $GUI_CHECKED)
	For $h = $g_hInputGoldItems To $g_hInputDarkElixirItems
		GUICtrlSetState($h, ($g_bChkResourcePotion = True) ? ($GUI_ENABLE) : ($GUI_DISABLE))
	Next
EndFunc   ;==>ConfigRefresh

Func ChkTreasuryCollect()
	If GUICtrlRead($g_hChkTreasuryCollect) = $GUI_CHECKED Then
		GUICtrlSetState($g_hTxtTreasuryGold, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtTreasuryElixir, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtTreasuryDark, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hTxtTreasuryGold, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtTreasuryElixir, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtTreasuryDark, $GUI_DISABLE)
	EndIf
EndFunc   ;==>ChkTreasuryCollect

#Region - Custom fix - Team AIO MOD++
Func ChkCollectRewards()
	If GUICtrlRead($g_hChkCollectRewards) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkSellRewards, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkSellRewards, $GUI_DISABLE)
	EndIf
EndFunc   ;==>ChkCollectRewards
#EndRegion - Custom fix - Team AIO MOD++

#CS - AIO MOD++
Func ChkFreeMagicItems()
	If $g_iTownHallLevel >= 8 Or $g_iTownHallLevel = 0 Then ; Must be Th8 or more to use the Trader
		GUICtrlSetState($g_hChkFreeMagicItems, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkFreeMagicItems, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>ChkFreeMagicItems

Func chkStartClockTowerBoost()
	If GUICtrlRead($g_hChkStartClockTowerBoost) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkCTBoostBlderBz, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkCTBoostBlderBz, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkStartClockTowerBoost
#CE - AIO MOD++

#Region - xbebenk - Clan Games
Func chkActivateClangames()
	If GUICtrlRead($g_hChkClanGamesEnabled) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkClanGames60, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesDebug, $GUI_ENABLE)

		GUICtrlSetState($g_hChkClanGamesLoot, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesBattle, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesDes, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesDes) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGDes, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGDes, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($g_hChkClanGamesAirTroop, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesAirTroop) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGAirTroop, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGAirTroop, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($g_hChkClanGamesGroundTroop, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesGroundTroop) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGGroundTroop, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGGroundTroop, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($g_hChkClanGamesBBTroops, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesBBTroops) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGBBTroop, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGBBTroop, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($g_hChkClanGamesMiscellaneous, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesSpell, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesSpell) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGSpell, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGSpell, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($g_hChkClanGamesBBBattle, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesBBDes, $GUI_ENABLE)
		If GUICtrlRead($g_hChkClanGamesBBDes) = $GUI_CHECKED Then
			GUICtrlSetState($g_hBtnCGBBDes, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hBtnCGBBDes, $GUI_DISABLE)
		EndIf
		GUICtrlSetState($g_hChkForceBBAttackOnClanGames, $GUI_ENABLE)
		GUICtrlSetState($g_hChkClanGamesPurgeAny, $GUI_ENABLE)

		GUICtrlSetState($g_hChkClanGamesStopBeforeReachAndPurge, $GUI_ENABLE)
		
		GUICtrlSetState($g_hChkOnlyBuilderBaseGC, $GUI_ENABLE)

	Else
		GUICtrlSetState($g_hChkClanGames60, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesDebug, $GUI_DISABLE)

		GUICtrlSetState($g_hChkClanGamesLoot, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesBattle, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesDes, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesAirTroop, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesGroundTroop, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesMiscellaneous, $GUI_DISABLE)

		GUICtrlSetState($g_hChkClanGamesSpell, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesBBBattle, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesBBDes, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesBBTroops, $GUI_DISABLE)
		GUICtrlSetState($g_hChkForceBBAttackOnClanGames, $GUI_DISABLE)
		GUICtrlSetState($g_hChkClanGamesPurgeAny, $GUI_DISABLE)

		GUICtrlSetState($g_hChkClanGamesStopBeforeReachAndPurge, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnCGBBTroop, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnCGGroundTroop, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnCGDes, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnCGAirTroop, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnCGSpell, $GUI_DISABLE)
		GUICtrlSetState($g_hChkOnlyBuilderBaseGC, $GUI_DISABLE)
	EndIf
	chkClanGamesBB()
EndFunc   ;==>chkActivateClangames

; Purging doesnt exist if we want BB challneges, because they are all attack basically... This avoids potential conflicts in code and logic if both are selected
Func chkClanGamesBB()

	Local $bBBChallenges = (GUICtrlRead($g_hChkClanGamesBBBattle) = $GUI_CHECKED Or GUICtrlRead($g_hChkClanGamesBBDes) = $GUI_CHECKED Or GUICtrlRead($g_hChkClanGamesBBTroops) = $GUI_CHECKED)
	
	
	If GUICtrlRead($g_hChkClanGamesEnabled) = $GUI_CHECKED Then
		
		If $bBBChallenges = True Then
			GUICtrlSetState($g_hChkForceBBAttackOnClanGames, $GUI_ENABLE)
			GUICtrlSetState($g_hChkOnlyBuilderBaseGC, $GUI_ENABLE)
		Else
			; GUICtrlSetState($g_hChkForceBBAttackOnClanGames, $GUI_DISABLE + $GUI_UNCHECKED)
			; GUICtrlSetState($g_hChkOnlyBuilderBaseGC, $GUI_DISABLE + $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkForceBBAttackOnClanGames, $GUI_DISABLE)
			GUICtrlSetState($g_hChkOnlyBuilderBaseGC, $GUI_DISABLE)
		EndIf
		
		; If GUICtrlRead($g_hChkForceBBAttackOnClanGames) = $GUI_CHECKED Then
			; $g_bChkForceBBAttackOnClanGames = True
		; Else
			; $g_bChkForceBBAttackOnClanGames = False
		; EndIf
		
		; If GUICtrlRead($g_hChkOnlyBuilderBaseGC) = $GUI_CHECKED Then
			; $g_bChkOnlyBuilderBaseGC = True
		; Else
			; $g_bChkOnlyBuilderBaseGC = False
		; EndIf
	; Else
		; $g_bChkForceBBAttackOnClanGames = False
		; $g_bChkOnlyBuilderBaseGC = False
	EndIf
EndFunc

Func btnCGDes()
	GUISetState(@SW_SHOW, $g_hGUI_CGDes)
EndFunc

Func CloseCGDes()
	GUISetState(@SW_HIDE, $g_hGUI_CGDes)
EndFunc

Func btnCGAirTroops()
	GUISetState(@SW_SHOW, $g_hGUI_CGAirTroops)
EndFunc

Func CloseCGAirTroops()
	GUISetState(@SW_HIDE, $g_hGUI_CGAirTroops)
EndFunc

Func btnCGGroundTroops()
 	GUISetState(@SW_SHOW, $g_hGUI_CGGroundTroops)
EndFunc

Func CloseCGGroundTroops()
 	GUISetState(@SW_HIDE, $g_hGUI_CGGroundTroops)
EndFunc

Func btnCGSpells()
	GUISetState(@SW_SHOW, $g_hGUI_CGSpells)
EndFunc

Func CloseCGSpells()
	GUISetState(@SW_HIDE, $g_hGUI_CGSpells)
EndFunc

Func btnCGBBDes()
	GUISetState(@SW_SHOW, $g_hGUI_CGBBDes)
EndFunc

Func CloseCGBBDes()
	GUISetState(@SW_HIDE, $g_hGUI_CGBBDes)
EndFunc

Func btnCGBBTroops()
	GUISetState(@SW_SHOW, $g_hGUI_CGBBTroops)
EndFunc

Func CloseCGBBTroops()
	GUISetState(@SW_HIDE, $g_hGUI_CGBBTroops)
EndFunc
#EndRegion - xbebenk - Clan Games

Func chkEnableBBAttack()
	;If GUICtrlRead($g_hChkEnableBBAttack) = $GUI_CHECKED Then
	GUICtrlSetState($g_hChkBBTrophyRange, $GUI_ENABLE)
	GUICtrlSetState($g_hChkBBAttIfLootAvail, $GUI_ENABLE)
	; GUICtrlSetState($g_hChkBBWaitForMachine, $GUI_ENABLE)
	GUICtrlSetState($g_hBtnBBDropOrder, $GUI_ENABLE)
	GUICtrlSetState($g_hCmbBBSameTroopDelay, $GUI_ENABLE)
	GUICtrlSetState($g_hCmbBBNextTroopDelay, $GUI_ENABLE)
	chkBBTrophyRange()
	;Else
	;	GUICtrlSetState($g_hChkBBTrophyRange, $GUI_DISABLE)
	;	GUICtrlSetState($g_hChkBBAttIfLootAvail, $GUI_DISABLE)
	;	GUICtrlSetState($g_hTxtBBTrophyLowerLimit, $GUI_DISABLE)
	;	GUICtrlSetState($g_hTxtBBTrophyUpperLimit, $GUI_DISABLE)
	;	GUICtrlSetState($g_hChkBBWaitForMachine, $GUI_DISABLE)
	;	GUICtrlSetState($g_hBtnBBDropOrder, $GUI_DISABLE)
	;	GUICtrlSetState($g_hCmbBBSameTroopDelay, $GUI_DISABLE)
	;	GUICtrlSetState($g_hCmbBBNextTroopDelay, $GUI_DISABLE)
	;EndIf
EndFunc   ;==>chkEnableBBAttack

Func cmbBBNextTroopDelay()
	$g_iBBNextTroopDelay = $g_iBBNextTroopDelayDefault + ((_GUICtrlComboBox_GetCurSel($g_hCmbBBNextTroopDelay) + 1) - 5) * $g_iBBNextTroopDelayIncrement ; +- n*increment
	SetDebugLog("Next Troop Delay: " & $g_iBBNextTroopDelay)
	SetDebugLog((_GUICtrlComboBox_GetCurSel($g_hCmbBBNextTroopDelay) + 1) - 5)
EndFunc   ;==>cmbBBNextTroopDelay

Func cmbBBSameTroopDelay()
	$g_iBBSameTroopDelay = $g_iBBSameTroopDelayDefault + ((_GUICtrlComboBox_GetCurSel($g_hCmbBBSameTroopDelay) + 1) - 5) * $g_iBBSameTroopDelayIncrement ; +- n*increment
	SetDebugLog("Same Troop Delay: " & $g_iBBSameTroopDelay)
	SetDebugLog((_GUICtrlComboBox_GetCurSel($g_hCmbBBSameTroopDelay) + 1) - 5)
EndFunc   ;==>cmbBBSameTroopDelay

Func chkBBTrophyRange()
	If GUICtrlRead($g_hChkBBTrophyRange) = $GUI_CHECKED Then
		GUICtrlSetState($g_hTxtBBTrophyLowerLimit, $GUI_ENABLE)
		GUICtrlSetState($g_hTxtBBTrophyUpperLimit, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hTxtBBTrophyLowerLimit, $GUI_DISABLE)
		GUICtrlSetState($g_hTxtBBTrophyUpperLimit, $GUI_DISABLE)
	EndIf
EndFunc   ;==>chkBBTrophyRange

Func btnBBDropOrder()
	GUICtrlSetState($g_hBtnBBDropOrder, $GUI_DISABLE)
	GUICtrlSetState($g_hChkEnableBBAttack, $GUI_DISABLE)
	GUISetState(@SW_SHOW, $g_hGUI_BBDropOrder)
EndFunc   ;==>btnBBDropOrder

Func chkBBDropOrder()
	If GUICtrlRead($g_hChkBBCustomDropOrderEnable) = $GUI_CHECKED Then
		GUICtrlSetState($g_hBtnBBDropOrderSet, $GUI_ENABLE)
		GUICtrlSetState($g_hBtnBBRemoveDropOrder, $GUI_ENABLE)
		For $i = 0 To $g_iBBTroopCount - 1
			GUICtrlSetState($g_ahCmbBBDropOrder[$i], $GUI_ENABLE)
		Next
	Else
		GUICtrlSetState($g_hBtnBBDropOrderSet, $GUI_DISABLE)
		GUICtrlSetState($g_hBtnBBRemoveDropOrder, $GUI_DISABLE)
		For $i = 0 To $g_iBBTroopCount - 1
			GUICtrlSetState($g_ahCmbBBDropOrder[$i], $GUI_DISABLE)
		Next
		GUICtrlSetBkColor($g_hBtnBBDropOrder, $COLOR_RED)
		$g_bBBDropOrderSet = False
	EndIf
EndFunc   ;==>chkBBDropOrder

#Region - Custom BB Army - Team AIO Mod++
Func GUIBBDropOrder()
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iDropIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId)
	Setlog($iDropIndex)
	For $i = 0 To $g_iBBTroopCount - 1
		If $iGUI_CtrlId = $g_ahCmbBBDropOrder[$i] Then
			_GUICtrlSetImage($g_sIcnBBOrder[$i], $g_sLibIconPath, $g_avStarLabTroops[$iDropIndex + 1][4])
		ElseIf $iDropIndex = _GUICtrlComboBox_GetCurSel($g_ahCmbBBDropOrder[$i]) Then
			_GUICtrlComboBox_SetCurSel($g_ahCmbBBDropOrder[$i], -1)
			_GUICtrlSetImage($g_sIcnBBOrder[$i], $g_sLibIconPath, $g_avStarLabTroops[0][4])
			GUISetState()
		EndIf
	Next
EndFunc   ;==>GUIBBDropOrder

Func GUIBBCustomArmy()
	Local $iGUI_CtrlId = @GUI_CtrlId
	Local $iDropIndex = _GUICtrlComboBox_GetCurSel($iGUI_CtrlId)

	For $i = 0 To UBound($g_hComboTroopBB) - 1
		If $iGUI_CtrlId = $g_hComboTroopBB[$i] Then
			_GUICtrlSetImage($g_hIcnTroopBB[$i], $g_sLibIconPath, $g_avStarLabTroops[$iDropIndex + 1][4])
			$g_iCmbCampsBB[$i] = $iDropIndex
		EndIf
	Next
EndFunc   ;==>GUIBBCustomArmy

#EndRegion - Custom BB Army - Team AIO Mod++

Func BtnBBDropOrderSet()
	$g_sBBDropOrder = ""
	; loop through reading and disabling all combo boxes
	For $i = 0 To $g_iBBTroopCount - 1
		GUICtrlSetState($g_ahCmbBBDropOrder[$i], $GUI_DISABLE)
		If GUICtrlRead($g_ahCmbBBDropOrder[$i]) = "" Then ; if not picked assign from default list in order
			Local $asDefaultOrderSplit = StringSplit($g_sBBDropOrderDefault, "|")
			Local $bFound = False, $bSet = False
			Local $j = 0
			While $j < $g_iBBTroopCount And Not $bSet ; loop through troops
				Local $k = 0
				While $k < $g_iBBTroopCount And Not $bFound ; loop through handles
					If $g_ahCmbBBDropOrder[$i] <> $g_ahCmbBBDropOrder[$k] Then
						SetDebugLog("Word: " & $asDefaultOrderSplit[$j + 1] & " " & " Word in slot: " & GUICtrlRead($g_ahCmbBBDropOrder[$k]))
						If $asDefaultOrderSplit[$j + 1] = GUICtrlRead($g_ahCmbBBDropOrder[$k]) Then $bFound = True
					EndIf
					$k += 1
				WEnd
				If Not $bFound Then
					_GUICtrlComboBox_SetCurSel($g_ahCmbBBDropOrder[$i], $j)
					$bSet = True
				Else
					$j += 1
					$bFound = False
				EndIf
			WEnd
		EndIf
		$g_sBBDropOrder &= (GUICtrlRead($g_ahCmbBBDropOrder[$i]) & "|")
		SetDebugLog("DropOrder: " & $g_sBBDropOrder)
		_GUICtrlSetImage($g_sIcnBBOrder[$i], $g_sLibIconPath, $g_avStarLabTroops[_GUICtrlComboBox_GetCurSel($g_ahCmbBBDropOrder[$i]) + 1][4])
	Next
	$g_sBBDropOrder = StringTrimRight($g_sBBDropOrder, 1) ; Remove last '|'
	GUICtrlSetBkColor($g_hBtnBBDropOrder, $COLOR_GREEN)
	$g_bBBDropOrderSet = True
EndFunc   ;==>BtnBBDropOrderSet

Func BtnBBRemoveDropOrder()
	For $i = 0 To $g_iBBTroopCount - 1
		_GUICtrlSetImage($g_sIcnBBOrder[$i], $g_sLibIconPath, $g_avStarLabTroops[0][4])     ; Custom BB Army - Team AIO Mod++
		_GUICtrlComboBox_SetCurSel($g_ahCmbBBDropOrder[$i], -1)
		GUICtrlSetState($g_ahCmbBBDropOrder[$i], $GUI_ENABLE)
	Next
	GUICtrlSetBkColor($g_hBtnBBDropOrder, $COLOR_RED)
	$g_bBBDropOrderSet = False
EndFunc   ;==>BtnBBRemoveDropOrder

Func CloseCustomBBDropOrder()
	GUISetState(@SW_HIDE, $g_hGUI_BBDropOrder)
	GUICtrlSetState($g_hBtnBBDropOrder, $GUI_ENABLE)
	GUICtrlSetState($g_hChkEnableBBAttack, $GUI_ENABLE)
EndFunc   ;==>CloseCustomBBDropOrder

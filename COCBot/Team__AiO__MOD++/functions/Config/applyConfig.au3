; #FUNCTION# ====================================================================================================================
; Name ..........: applyConfig.au3
; Description ...: Applies all of the  variable to the GUI
; Syntax ........: applyConfig()
; Parameters ....: $bRedrawAtExit = True, redraws bot window after config was applied
; Return values .: NA
; Author ........: Team AiO MOD++ (2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;<><><> Team AiO MOD++ (2019) <><><>
Func ApplyConfig_MOD_SuperXP($TypeReadSave)
	; <><><> SuperXP / GoblinXP <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkEnableSuperXP, $g_bEnableSuperXP ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkEnableSuperXP()
			GUICtrlSetState($g_hChkSkipZoomOutSX, $g_bSkipZoomOutSX ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkFastSuperXP, $g_bFastSuperXP ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkSkipDragToEndSX, $g_bSkipDragToEndSX ? $GUI_CHECKED : $GUI_UNCHECKED)
			radActivateOptionSX()
			radGoblinMapOptSX()
			radLblGoblinMapOpt()

			GUICtrlSetData($g_hTxtMaxXPToGain, $g_iMaxXPtoGain)
			GUICtrlSetState($g_hChkBKingSX, $g_bBKingSX = $eHeroKing ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkAQueenSX, $g_bAQueenSX = $eHeroQueen ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkGWardenSX, $g_bGWardenSX = $eHeroWarden ? $GUI_CHECKED : $GUI_UNCHECKED)
		Case "Save"
			$g_bEnableSuperXP = (GUICtrlRead($g_hChkEnableSuperXP) = $GUI_CHECKED)
			$g_bSkipZoomOutSX = (GUICtrlRead($g_hChkSkipZoomOutSX) = $GUI_CHECKED)
			$g_bFastSuperXP = (GUICtrlRead($g_hChkFastSuperXP) = $GUI_CHECKED)
			$g_bSkipDragToEndSX = (GUICtrlRead($g_hChkSkipDragToEndSX) = $GUI_CHECKED)
			If GUICtrlRead($g_hRdoTrainingSX) = $GUI_CHECKED Then
				$g_iActivateOptionSX = 1
			ElseIf GUICtrlRead($g_hRdoAttackingSX) = $GUI_CHECKED Then
				$g_iActivateOptionSX = 2
			EndIf
			If GUICtrlRead($g_hRdoGoblinPicnic) = $GUI_CHECKED Then
				$g_iGoblinMapOptSX = 1
			ElseIf GUICtrlRead($g_hRdoTheArena) = $GUI_CHECKED Then
				$g_iGoblinMapOptSX = 2
			EndIf

			$g_iMaxXPtoGain = GUICtrlRead($g_hTxtMaxXPToGain)
			$g_bBKingSX = (GUICtrlRead($g_hChkBKingSX) = $GUI_CHECKED) ? $eHeroKing : $eHeroNone
			$g_bAQueenSX = (GUICtrlRead($g_hChkAQueenSX) = $GUI_CHECKED) ? $eHeroQueen : $eHeroNone
			$g_bGWardenSX = (GUICtrlRead($g_hChkGWardenSX) = $GUI_CHECKED) ? $eHeroWarden : $eHeroNone
	EndSwitch

EndFunc   ;==>ApplyConfig_MOD_SuperXP

Func ApplyConfig_MOD_MagicItems($TypeReadSave)
	; <><><> MagicItems <><><>

	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetData($g_hInputGoldItems, $g_iInputGoldItems)
			GUICtrlSetData($g_hInputElixirItems, $g_iInputElixirItems)
			GUICtrlSetData($g_hInputDarkElixirItems, $g_iInputDarkElixirItems)

			GUICtrlSetData($g_hInputBuilderPotion, $g_iInputBuilderPotion)
			GUICtrlSetData($g_hInputLabPotion, $g_iInputLabPotion)

			_GUICtrlComboBox_SetCurSel($g_hComboClockTowerPotion, $g_iComboClockTowerPotion)
			_GUICtrlComboBox_SetCurSel($g_hComboHeroPotion, $g_iComboHeroPotion)
			_GUICtrlComboBox_SetCurSel($g_hComboPowerPotion, $g_iComboPowerPotion)
			
			GUICtrlSetState($g_hChkCollectMagicItems, $g_bChkCollectMagicItems = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkCollectFree, $g_bChkCollectFree = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			ChkFreeMagicItems()

			GUICtrlSetState($g_hChkBuilderPotion, $g_bChkBuilderPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkClockTowerPotion, $g_bChkClockTowerPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkHeroPotion, $g_bChkHeroPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkLabPotion, $g_bChkLabPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkPowerPotion, $g_bChkPowerPotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkResourcePotion, $g_bChkResourcePotion = True ? $GUI_CHECKED : $GUI_UNCHECKED)

		Case "Save"
			$g_iInputGoldItems = GUICtrlRead($g_hInputGoldItems)
			$g_iInputElixirItems = GUICtrlRead($g_hInputElixirItems)
			$g_iInputDarkElixirItems = GUICtrlRead($g_hInputDarkElixirItems)

			$g_iInputBuilderPotion = GUICtrlRead($g_hInputBuilderPotion)
			$g_iInputLabPotion = GUICtrlRead($g_hInputLabPotion)
			
			$g_iComboPowerPotion = _GUICtrlComboBox_GetCurSel($g_hComboPowerPotion)
			$g_iComboHeroPotion = _GUICtrlComboBox_GetCurSel($g_hComboHeroPotion)
			$g_iComboClockTowerPotion = _GUICtrlComboBox_GetCurSel($g_hComboClockTowerPotion)
			
			$g_bChkCollectMagicItems = (GUICtrlRead($g_hChkCollectMagicItems) = $GUI_CHECKED)
			$g_bChkCollectFree = (GUICtrlRead($g_hChkCollectFree) = $GUI_CHECKED)
		
			$g_bChkBuilderPotion = (GUICtrlRead($g_hChkBuilderPotion) = $GUI_CHECKED)
			$g_bChkClockTowerPotion = (GUICtrlRead($g_hChkClockTowerPotion) = $GUI_CHECKED)
			$g_bChkHeroPotion = (GUICtrlRead($g_hChkHeroPotion) = $GUI_CHECKED)
			$g_bChkLabPotion = (GUICtrlRead($g_hChkLabPotion) = $GUI_CHECKED)
			$g_bChkPowerPotion = (GUICtrlRead($g_hChkPowerPotion) = $GUI_CHECKED)
			$g_bChkResourcePotion = (GUICtrlRead($g_hChkResourcePotion) = $GUI_CHECKED)
	EndSwitch

EndFunc   ;==>ApplyConfig_MOD_MagicItems

Func ApplyConfig_MOD_ChatActions($TypeReadSave)
	; <><><> ChatActions <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkClanChat, $g_bChatClan = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDelayTimeClan, $g_sDelayTimeClan)
			GUICtrlSetState($g_hChkUseResponses, $g_bClanUseResponses = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkUseGeneric, $g_bClanUseGeneric = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkCleverbot, $g_bCleverbot = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkChatNotify, $g_bUseNotify = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkPbSendNewChats, $g_bPbSendNew = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkClanChat()

			GUICtrlSetState($g_hChkEnableFriendlyChallenge, $g_bEnableFriendlyChallenge = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDelayTimeFC, $g_sDelayTimeFC)
			GUICtrlSetState($g_hChkOnlyOnRequest, $g_bOnlyOnRequest = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			For $i = 0 To 5
				GUICtrlSetState($g_hChkFriendlyChallengeBase[$i], $g_bFriendlyChallengeBase[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			For $i = 0 To 23
				GUICtrlSetState($g_ahChkFriendlyChallengeHours[$i], $g_abFriendlyChallengeHours[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			chkEnableFriendlyChallenge()
			ChatGuiEditUpdate()
		Case "Save"
			$g_bChatClan = (GUICtrlRead($g_hChkClanChat) = $GUI_CHECKED)
			$g_sDelayTimeClan = GUICtrlRead($g_hTxtDelayTimeClan)
			$g_bClanUseResponses = (GUICtrlRead($g_hChkUseResponses) = $GUI_CHECKED)
			$g_bClanUseGeneric = (GUICtrlRead($g_hChkUseGeneric) = $GUI_CHECKED)
			$g_bCleverbot = (GUICtrlRead($g_hChkCleverbot) = $GUI_CHECKED)
			$g_bUseNotify = (GUICtrlRead($g_hChkChatNotify) = $GUI_CHECKED)
			$g_bPbSendNew = (GUICtrlRead($g_hChkPbSendNewChats) = $GUI_CHECKED)

			$g_bEnableFriendlyChallenge = (GUICtrlRead($g_hChkEnableFriendlyChallenge) = $GUI_CHECKED)
			$g_sDelayTimeFC = GUICtrlRead($g_hTxtDelayTimeFC)
			$g_bOnlyOnRequest = (GUICtrlRead($g_hChkOnlyOnRequest) = $GUI_CHECKED)
			For $i = 0 To 5
				$g_bFriendlyChallengeBase[$i] = (GUICtrlRead($g_hChkFriendlyChallengeBase[$i]) = $GUI_CHECKED)
			Next
			For $i = 0 To 23
				$g_abFriendlyChallengeHours[$i] = (GUICtrlRead($g_ahChkFriendlyChallengeHours[$i]) = $GUI_CHECKED)
			Next
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_ChatActions

Func ApplyConfig_MOD_600_6($TypeReadSave)
	; <><><> Daily Discounts + Builder Base Attack + Builder Base Drop Order <><><>
	Switch $TypeReadSave
		Case "Read"
			For $i = 0 To $g_iDDCount - 1
				GUICtrlSetState($g_ahChkDD_Deals[$i], $g_abChkDD_Deals[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			Next
			;GUICtrlSetBkColor($g_hBtnMagicItemsConfig, $g_bChkCollectMagicItems = True ? $COLOR_GREEN : $COLOR_RED)
			btnDDApply()
		Case "Save"
			For $i = 0 To $g_iDDCount - 1
				$g_abChkDD_Deals[$i] = (GUICtrlRead($g_ahChkDD_Deals[$i]) = $GUI_CHECKED)
			Next

			$g_bChkEnableBBAttack = (GUICtrlRead($g_hChkEnableBBAttack) = $GUI_CHECKED)
			$g_bChkBBTrophyRange = (GUICtrlRead($g_hChkBBTrophyRange) = $GUI_CHECKED)
			$g_iTxtBBTrophyLowerLimit = GUICtrlRead($g_hTxtBBTrophyLowerLimit)
			$g_iTxtBBTrophyUpperLimit = GUICtrlRead($g_hTxtBBTrophyUpperLimit)
			$g_bChkBBAttIfLootAvail = (GUICtrlRead($g_hChkBBAttIfLootAvail) = $GUI_CHECKED)
			$g_bChkBBWaitForMachine = (GUICtrlRead($g_hChkBBWaitForMachine) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_6

Func ApplyConfig_MOD_600_12($TypeReadSave)
	; <><><> GTFO <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkGTFOClanHop, $g_bChkGTFOClanHop = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkGTFOReturnClan, $g_bChkGTFOReturnClan = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtCyclesGTFO, $g_iTxtCyclesGTFO)
			GUICtrlSetState($g_hChkUseGTFO, $g_bChkUseGTFO = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtMinSaveGTFO_Elixir, $g_iTxtMinSaveGTFO_Elixir)
			GUICtrlSetData($g_hTxtMinSaveGTFO_DE, $g_iTxtMinSaveGTFO_DE)
			GUICtrlSetData($g_hTxtClanID, $g_sTxtClanID)
			ApplyGTFO()

			GUICtrlSetState($g_hChkUseKickOut, $g_bChkUseKickOut = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDonatedCap, $g_iTxtDonatedCap)
			GUICtrlSetData($g_hTxtReceivedCap, $g_iTxtReceivedCap)
			GUICtrlSetState($g_hChkKickOutSpammers, $g_bChkKickOutSpammers = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtKickLimit, $g_iTxtKickLimit)
			ApplyKickOut()

		Case "Save"
			$g_bChkGTFOClanHop = (GUICtrlRead($g_hChkGTFOClanHop) = $GUI_CHECKED)
			$g_bChkGTFOReturnClan = (GUICtrlRead($g_hChkGTFOReturnClan) = $GUI_CHECKED)
			$g_iTxtCyclesGTFO = Number(GUICtrlRead($g_hTxtCyclesGTFO))
			$g_sTxtClanID = GUICtrlRead($g_hTxtClanID)

			$g_bChkUseGTFO = (GUICtrlRead($g_hChkUseGTFO) = $GUI_CHECKED)
			$g_iTxtMinSaveGTFO_Elixir = Number(GUICtrlRead($g_hTxtMinSaveGTFO_Elixir))
			$g_iTxtMinSaveGTFO_DE = Number(GUICtrlRead($g_hTxtMinSaveGTFO_DE))
			$g_bChkUseKickOut = (GUICtrlRead($g_hChkUseKickOut) = $GUI_CHECKED)
			$g_iTxtDonatedCap = Number(GUICtrlRead($g_hTxtDonatedCap))
			$g_iTxtReceivedCap = Number(GUICtrlRead($g_hTxtReceivedCap))
			$g_bChkKickOutSpammers = (GUICtrlRead($g_hChkKickOutSpammers) = $GUI_CHECKED)
			$g_iTxtKickLimit = Number(GUICtrlRead($g_hTxtKickLimit))
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_12

Func ApplyConfig_MOD_600_28($TypeReadSave)
	; <><><> Max logout time <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkTrainLogoutMaxTime, $g_bTrainLogoutMaxTime = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkTrainLogoutMaxTime()
			GUICtrlSetData($g_hTxtTrainLogoutMaxTime, $g_iTrainLogoutMaxTime)

			; Check No League for Dead Base
			GUICtrlSetState($g_hChkDBNoLeague, $g_bChkNoLeague[$DB] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
		Case "Save"
			$g_bTrainLogoutMaxTime = (GUICtrlRead($g_hChkTrainLogoutMaxTime) = $GUI_CHECKED)
			$g_iTrainLogoutMaxTime = GUICtrlRead($g_hTxtTrainLogoutMaxTime)

			; Check No League for Dead Base
			$g_bChkNoLeague[$DB] = (GUICtrlRead($g_hChkDBNoLeague) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_28

Func ApplyConfig_MOD_600_29($TypeReadSave)
	; <><><> Classic Four Finger + CSV Deploy Speed <><><>
	Switch $TypeReadSave
		Case "Read"
			cmbStandardDropSidesAB()
			cmbStandardDropSidesDB()

			_GUICtrlComboBox_SetCurSel($cmbCSVSpeed[$LB], $icmbCSVSpeed[$LB])
			_GUICtrlComboBox_SetCurSel($cmbCSVSpeed[$DB], $icmbCSVSpeed[$DB])
		Case "Save"
			$icmbCSVSpeed[$LB] = _GUICtrlComboBox_GetCurSel($cmbCSVSpeed[$LB])
			$icmbCSVSpeed[$DB] = _GUICtrlComboBox_GetCurSel($cmbCSVSpeed[$DB])
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_29

Func ApplyConfig_MOD_600_31($TypeReadSave)
	; <><><> Check Collectors Outside <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkDBMeetCollectorOutside, $g_bDBMeetCollectorOutside = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtDBMinCollectorOutsidePercent, $g_iDBMinCollectorOutsidePercent)

			GUICtrlSetState($g_hChkDBCollectorNearRedline, $g_bDBCollectorNearRedline = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbRedlineTiles, $g_iCmbRedlineTiles)

			GUICtrlSetState($g_hChkSkipCollectorCheck, $g_bSkipCollectorCheck = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetData($g_hTxtSkipCollectorGold, $g_iTxtSkipCollectorGold)
			GUICtrlSetData($g_hTxtSkipCollectorElixir, $g_iTxtSkipCollectorElixir)
			GUICtrlSetData($g_hTxtSkipCollectorDark, $g_iTxtSkipCollectorDark)

			GUICtrlSetState($g_hChkSkipCollectorCheckTH, $g_bSkipCollectorCheckTH = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			_GUICtrlComboBox_SetCurSel($g_hCmbSkipCollectorCheckTH, $g_iCmbSkipCollectorCheckTH)
			chkDBMeetCollectorOutside()
		Case "Save"
			$g_bDBMeetCollectorOutside = (GUICtrlRead($g_hChkDBMeetCollectorOutside) = $GUI_CHECKED)
			$g_iDBMinCollectorOutsidePercent = GUICtrlRead($g_hTxtDBMinCollectorOutsidePercent)

			$g_bDBCollectorNearRedline = (GUICtrlRead($g_hChkDBCollectorNearRedline) = $GUI_CHECKED)
			$g_iCmbRedlineTiles = _GUICtrlComboBox_GetCurSel($g_hCmbRedlineTiles)

			$g_bSkipCollectorCheck = (GUICtrlRead($g_hChkSkipCollectorCheck) = $GUI_CHECKED)
			$g_iTxtSkipCollectorGold = GUICtrlRead($g_hTxtSkipCollectorGold)
			$g_iTxtSkipCollectorElixir = GUICtrlRead($g_hTxtSkipCollectorElixir)
			$g_iTxtSkipCollectorDark = GUICtrlRead($g_hTxtSkipCollectorDark)

			$g_bSkipCollectorCheckTH = (GUICtrlRead($g_hChkSkipCollectorCheckTH) = $GUI_CHECKED)
			$g_iCmbSkipCollectorCheckTH = _GUICtrlComboBox_GetCurSel($g_hCmbSkipCollectorCheckTH)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_31

Func ApplyConfig_MOD_600_35_1($TypeReadSave)
	; <><><> Auto Dock, Hide Emulator & Bot <><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkEnableAuto, $g_bEnableAuto = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkEnableAuto()
			GUICtrlSetState($g_hChkAutoDock, $g_bChkAutoDock = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkAutoHideEmulator, $g_bChkAutoHideEmulator = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			btnEnableAuto()
			GUICtrlSetState($g_hChkAutoMinimizeBot, $g_bChkAutoMinimizeBot = True ? $GUI_CHECKED : $GUI_UNCHECKED)

			; <><><> Only Farm <><><>
			GUICtrlSetState($g_hChkOnlyFarm, $g_bChkOnlyFarm = True ? $GUI_CHECKED : $GUI_UNCHECKED)
			UpdateChkOnlyFarm() ;Applies it to farm button

		Case "Save"
			$g_bEnableAuto = (GUICtrlRead($g_hChkEnableAuto) = $GUI_CHECKED)
			$g_bChkAutoDock = (GUICtrlRead($g_hChkAutoDock) = $GUI_CHECKED)
			$g_bChkAutoHideEmulator = (GUICtrlRead($g_hChkAutoHideEmulator) = $GUI_CHECKED)
			$g_bChkAutoMinimizeBot = (GUICtrlRead($g_hChkAutoMinimizeBot) = $GUI_CHECKED)

			; <><><> Only Farm <><><>
			$g_bChkOnlyFarm = (GUICtrlRead($g_hChkOnlyFarm) = $GUI_CHECKED)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_35_1

Func ApplyConfig_MOD_600_35_2($TypeReadSave)
	; <><><><> Switch Profiles <><><><>
	Switch $TypeReadSave
		Case "Read"
			For $i = 0 To 3
				GUICtrlSetState($g_ahChk_SwitchMax[$i], $g_abChkSwitchMax[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				GUICtrlSetState($g_ahChk_SwitchMin[$i], $g_abChkSwitchMin[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				_GUICtrlComboBox_SetCurSel($g_ahCmb_SwitchMax[$i], $g_aiCmbSwitchMax[$i])
				_GUICtrlComboBox_SetCurSel($g_ahCmb_SwitchMin[$i], $g_aiCmbSwitchMin[$i])

				GUICtrlSetState($g_ahChk_BotTypeMax[$i], $g_abChkBotTypeMax[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				GUICtrlSetState($g_ahChk_BotTypeMin[$i], $g_abChkBotTypeMin[$i] = True ? $GUI_CHECKED : $GUI_UNCHECKED)
				_GUICtrlComboBox_SetCurSel($g_ahCmb_BotTypeMax[$i], $g_aiCmbBotTypeMax[$i])
				_GUICtrlComboBox_SetCurSel($g_ahCmb_BotTypeMin[$i], $g_aiCmbBotTypeMin[$i])

				GUICtrlSetData($g_ahTxt_ConditionMax[$i], $g_aiConditionMax[$i])
				GUICtrlSetData($g_ahTxt_ConditionMin[$i], $g_aiConditionMin[$i])
			Next
			chkSwitchProfile()
			chkSwitchBotType()
		Case "Save"
			For $i = 0 To 3
				$g_abChkSwitchMax[$i] = (GUICtrlRead($g_ahChk_SwitchMax[$i]) = $GUI_CHECKED)
				$g_abChkSwitchMin[$i] = (GUICtrlRead($g_ahChk_SwitchMin[$i]) = $GUI_CHECKED)
				$g_aiCmbSwitchMax[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_SwitchMax[$i])
				$g_aiCmbSwitchMin[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_SwitchMin[$i])

				$g_abChkBotTypeMax[$i] = (GUICtrlRead($g_ahChk_BotTypeMax[$i]) = $GUI_CHECKED)
				$g_abChkBotTypeMin[$i] = (GUICtrlRead($g_ahChk_BotTypeMin[$i]) = $GUI_CHECKED)
				$g_aiCmbBotTypeMax[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_BotTypeMax[$i])
				$g_aiCmbBotTypeMin[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmb_BotTypeMin[$i])

				$g_aiConditionMax[$i] = GUICtrlRead($g_ahTxt_ConditionMax[$i])
				$g_aiConditionMin[$i] = GUICtrlRead($g_ahTxt_ConditionMin[$i])
			Next
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_600_35_2

Func ApplyConfig_MOD_Humanization($TypeReadSave)
	; <><><><> Humanization <><><><>
	Switch $TypeReadSave
		Case "Read"
			GUICtrlSetState($g_hChkUseBotHumanization, $g_bUseBotHumanization ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkUseAltRClick, $g_bUseAltRClick ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkCollectAchievements, $g_bCollectAchievements ? $GUI_CHECKED : $GUI_UNCHECKED)
			GUICtrlSetState($g_hChkLookAtRedNotifications, $g_bLookAtRedNotifications ? $GUI_CHECKED : $GUI_UNCHECKED)
			chkUseBotHumanization()
			For $i = 0 To 12
				_GUICtrlComboBox_SetCurSel($g_acmbPriority[$i], $g_iacmbPriority[$i])
			Next
			For $i = 0 To 1
				_GUICtrlComboBox_SetCurSel($g_acmbMaxSpeed[$i], $g_iacmbMaxSpeed[$i])
			Next
			For $i = 0 To 1
				_GUICtrlComboBox_SetCurSel($g_acmbPause[$i], $g_iacmbPause[$i])
			Next
			For $i = 0 To 1
				GUICtrlSetData($g_ahumanMessage[$i], $g_iahumanMessage[$i])
			Next
			_GUICtrlComboBox_SetCurSel($g_hCmbMaxActionsNumber, $g_iCmbMaxActionsNumber)
			GUICtrlSetData($g_hChallengeMessage, $g_iTxtChallengeMessage)
			cmbStandardReplay()
			cmbWarReplay()
		Case "Save"
			$g_bUseBotHumanization = (GUICtrlRead($g_hChkUseBotHumanization) = $GUI_CHECKED)
			$g_bUseAltRClick = (GUICtrlRead($g_hChkUseAltRClick) = $GUI_CHECKED)
			$g_bCollectAchievements = (GUICtrlRead($g_hChkCollectAchievements) = $GUI_CHECKED)
			$g_bLookAtRedNotifications = (GUICtrlRead($g_hChkLookAtRedNotifications) = $GUI_CHECKED)
			For $i = 0 To 12
				$g_iacmbPriority[$i] = _GUICtrlComboBox_GetCurSel($g_acmbPriority[$i])
			Next
			For $i = 0 To 1
				$g_iacmbMaxSpeed[$i] = _GUICtrlComboBox_GetCurSel($g_acmbMaxSpeed[$i])
			Next
			For $i = 0 To 1
				$g_iacmbPause[$i] = _GUICtrlComboBox_GetCurSel($g_acmbPause[$i])
			Next
			For $i = 0 To 1
				$g_iahumanMessage[$i] = GUICtrlRead($g_ahumanMessage[$i])
			Next
			$g_iCmbMaxActionsNumber = _GUICtrlComboBox_GetCurSel($g_iCmbMaxActionsNumber)
			$g_iTxtChallengeMessage = GUICtrlRead($g_hChallengeMessage)
	EndSwitch
EndFunc   ;==>ApplyConfig_MOD_Humanization
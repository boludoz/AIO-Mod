; #FUNCTION# ====================================================================================================================
; Name ..........: Farm Schedule
; Description ...: Farm Schedule for Switch Accounts
; Author ........: Demen, NguyenAnhHD (03-2018)
; Modified ......: Team AiO MOD++ (2019), Boldina (09-2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CheckFarmSchedule()

	If Not ProfileSwitchAccountEnabled() Then Return

	Static $aiActionDone[8] = [0, 0, 0, 0, 0, 0, 0, 0]
	Static $iStartHour = @HOUR
	Static $iDay = @YDAY
	Local $bNeedRunBot = False

	If $g_bFirstStart And $iStartHour = -1 Then $iStartHour = @HOUR
	Local $bActionDone = False
	SetLog("Checking farm schedule.", $COLOR_ACTION)

	For $i = 0 To 7
		If $i > $g_iTotalAcc Then ExitLoop

		If $iDay < @YDAY Then ; reset timers
			$aiActionDone[$i] = 0
			$iStartHour = -1
			If $i >= _Min($g_iTotalAcc, 7) Then $iDay = @YDAY
			If $g_bDebugSetlog Then SetDebugLog("New day is coming $iDay/ @YDay : " & $iDay & "/ " & @YDAY, $COLOR_DEBUG)
		EndIf
		If $g_abChkSetFarm[$i] Then
			Local $iAction = -1

			; Check resource criteria for current account
			If $i = $g_iCurAccount Then
				Local $asText[5] = ["Gold", "Elixir", "DarkE", "Trophy", "Time"]
				While 1
					If $g_aiCmbAction1[$i] >= 1 And $g_aiCmbCriteria1[$i] >= 1 Then
						For $r = 1 To 5
							If $g_aiCmbCriteria1[$i] <> 5 Then
								If $g_aiCmbCriteria1[$i] = $r And Number($g_aiCurrentLoot[$r - 1]) >= Number($g_aiTxtResource1[$i]) Then
									SetLog("Village " & $asText[$r - 1] & " detected above 1st criterium: " & $g_aiTxtResource1[$i], $COLOR_SUCCESS)
									$iAction = $g_aiCmbAction1[$i] - 1
									ExitLoop 2
								EndIf
							Else
								GetTimersFS($i, 0)
								If $g_aiActiveFSTimersWeek[@WDAY - 1] == False And $g_aiActiveFSTimersDays[Int(@HOUR)] == False Then
									; _ArrayDisplay($g_aiActiveFSTimersWeek)
									SetLog("Village " & $asText[$r - 1] & " detected above 1st criterium.", $COLOR_SUCCESS)
									$iAction = $g_aiCmbAction1[$i] - 1
									ExitLoop 2
								EndIf
							EndIf
						Next
					EndIf
					If $g_aiCmbAction2[$i] >= 1 And $g_aiCmbCriteria2[$i] >= 1 Then
						For $r = 1 To 5
							If $g_aiCmbCriteria2[$i] <> 5 Then
								If $g_aiCmbCriteria2[$i] = $r And Number($g_aiCurrentLoot[$r - 1]) < Number($g_aiTxtResource2[$i]) And Number($g_aiCurrentLoot[$r - 1]) > 1 Then
									SetLog("Village " & $asText[$r - 1] & " detected below 2nd criterium: " & $g_aiTxtResource2[$i], $COLOR_SUCCESS)
									$iAction = $g_aiCmbAction2[$i] - 1
									ExitLoop 2
								EndIf
							Else
								GetTimersFS($i, 1)
								If $g_aiActiveFSTimersWeek[@WDAY - 1] == False And $g_aiActiveFSTimersDays[Int(@HOUR)] == False Then
									; _ArrayDisplay($g_aiActiveFSTimersWeek)
									SetLog("Village " & $asText[$r - 1] & " detected below 2nd criterium.", $COLOR_SUCCESS)
									$iAction = $g_aiCmbAction2[$i] - 1
									ExitLoop 2
								EndIf
							EndIf
						Next
					EndIf
					ExitLoop
				WEnd
			EndIf

			; Action
			Switch $iAction
				Case 0 ; turn Off (idle)
					If GUICtrlRead($g_ahChkAccount[$i]) = $GUI_CHECKED Then

						; Checking if this is the last active account
						Local $iSleeptime = CheckLastActiveAccount($i)
						If $iSleeptime > 1 Then
							SetLog("This is the last active/donate account to turn off.")
							SetLog("Let's go sleep until another account is scheduled to turn active/donate")
							SetSwitchAccLog("   Acc. " & $i + 1 & " go sleep", $COLOR_BLUE)
							UniversalCloseWaitOpenCoC($iSleeptime * 60 * 1000, "FarmSchedule", False, True) ; wake up & full restart
						EndIf

						GUICtrlSetState($g_ahChkAccount[$i], $GUI_UNCHECKED)
						chkAccount($i)
						$bActionDone = True
						If $i = $g_iCurAccount Then $g_bInitiateSwitchAcc = True
						SetLog("Acc [" & $i + 1 & "] turned OFF")
						SetSwitchAccLog("   Acc. " & $i + 1 & " now Idle", $COLOR_BLUE)
					EndIf
				Case 1 ; turn Donate
					If GUICtrlRead($g_ahChkDonate[$i]) = $GUI_UNCHECKED Then
						_GUI_Value_STATE("CHECKED", $g_ahChkAccount[$i] & "#" & $g_ahChkDonate[$i])
						$bActionDone = True
						If $i = $g_iCurAccount Then $bNeedRunBot = True
						SetLog("Acc [" & $i + 1 & "] turned ON for Donating")
						SetSwitchAccLog("   Acc. " & $i + 1 & " now Donate", $COLOR_BLUE)
					EndIf
				Case 2 ; turn Active
					If GUICtrlRead($g_ahChkAccount[$i]) = $GUI_UNCHECKED Or GUICtrlRead($g_ahChkDonate[$i]) = $GUI_CHECKED Then
						GUICtrlSetState($g_ahChkAccount[$i], $GUI_CHECKED)
						GUICtrlSetState($g_ahChkDonate[$i], $GUI_UNCHECKED)
						$bActionDone = True
						If $i = $g_iCurAccount Then $bNeedRunBot = True
						SetLog("Acc [" & $i + 1 & "] turned ON for Farming")
						SetSwitchAccLog("   Acc. " & $i + 1 & " now Active", $COLOR_BLUE)
					EndIf
			EndSwitch
		EndIf
	Next

	If $bActionDone Then
		SaveConfig_600_35_2() ; Save config profile after changing botting type
		ReadConfig_600_35_2() ; Update variables
		UpdateMultiStats(False)
	EndIf

	If _Sleep(500) Then Return
	If $g_bInitiateSwitchAcc Then
		Local $aActiveAccount = _ArrayFindAll($g_abAccountNo, True)
		If UBound($aActiveAccount) >= 1 Then
			$g_iNextAccount = $aActiveAccount[0]
			If $g_sProfileCurrentName <> $g_asProfileName[$g_iNextAccount] Then
				If $g_iGuiMode = 1 Then
					; normal GUI Mode
					_GUICtrlComboBox_SetCurSel($g_hCmbProfile, _GUICtrlComboBox_FindStringExact($g_hCmbProfile, $g_asProfileName[$g_iNextAccount]))
					cmbProfile()
					DisableGUI_AfterLoadNewProfile()
				Else
					; mini or headless GUI Mode
					saveConfig()
					$g_sProfileCurrentName = $g_asProfileName[$g_iNextAccount]
					LoadProfile(False)
				EndIf
			EndIf
			runBot()
		EndIf

	ElseIf $bNeedRunBot Then
		runBot()
	EndIf
EndFunc   ;==>CheckFarmSchedule

Func CheckLastActiveAccount($i)

	Local $iSleeptime = 0 ; result in minutes
	Local $aActiveAccount = _ArrayFindAll($g_abAccountNo, True)

	If $i = $g_iCurAccount And UBound($aActiveAccount) <= 1 Then
		SetLog("  This is the last active/donate account to turn off.")

		Local $iSoonestTimer = -1
		Local $iDateDiffUniversal = 0
		For $i = 0 To 7
			If $i > $g_iTotalAcc Then ExitLoop
			If $g_abChkSetFarm[$i] Then
				If $g_aiCmbAction1[$i] >= 1 And $g_aiCmbCriteria1[$i] = 5 Then
					GetTimersFS($i, 0)
					Local $sDateAndTime = _NowCalcDate() & " " & _NowTime(5)
					Local $iTimerH = 0, $iTimerD = 0
					;;;;;;;
					Local $iDOW = @WDAY
					Local $iD = -1
					Local $iNum = -1
					For $iWk = 1 To 7
						If $iD > 7 Then
							$iDOW = @WDAY - 7
						EndIf
						$iD = $iDOW + $iWk
						$iNum = $iD - 2
						If $g_aiActiveFSTimersWeek[$iNum] == False Then
							$iTimerD += 1
						Else
							ExitLoop
						EndIf
					Next

					Local $iDOW = Int(@HOUR + 1)
					Local $iD = -1
					Local $iNum = -1
					For $iDy = 1 To 24
						If $iD > 24 Then
							$iDOW = Int(@HOUR + 1) - 24
						EndIf
						$iD = $iDOW + $iDy
						$iNum = $iD - 2
						If $g_aiActiveFSTimersDays[$iNum] == False Then
							$iTimerH += 1
						Else
							ExitLoop
						EndIf
					Next
					;;;;;;;;;
					$sDateAndTime = _DateAdd("D", $iTimerD, $sDateAndTime)
					$sDateAndTime = _DateAdd("h", $iTimerH, $sDateAndTime)
					$iDateDiffUniversal = _DateDiff('s', _NowCalcDate() & " " & _NowTime(5), $sDateAndTime)
					Setlog($iDateDiffUniversal)
					If $iSoonestTimer = -1 Or $iSoonestTimer > $iDateDiffUniversal Then $iSoonestTimer = $iDateDiffUniversal
				EndIf
				If $g_aiCmbAction2[$i] >= 1 And $g_aiCmbCriteria2[$i] = 5 Then
					GetTimersFS($i, 1)
					Local $sDateAndTime = _NowCalcDate() & " " & _NowTime(5)
					Local $iTimerH = 0, $iTimerD = 0
					;;;;;;;
					Local $iDOW = @WDAY
					Local $iD = -1
					Local $iNum = -1
					For $i = 1 To 7
						If $iD > 7 Then
							$iDOW = @WDAY - 7
						EndIf
						$iD = $iDOW + $i
						$iNum = $iD - 2
						If $g_aiActiveFSTimersWeek[$iNum] == False Then
							$iTimerD += 1
						Else
							ExitLoop
						EndIf
					Next

					Local $iDOW = Int(@HOUR + 1)
					Local $iD = -1
					Local $iNum = -1
					For $i = 1 To 24
						If $iD > 24 Then
							$iDOW = Int(@HOUR + 1) - 24
						EndIf
						$iD = $iDOW + $i
						$iNum = $iD - 2
						If $g_aiActiveFSTimersDays[$iNum] == False Then
							$iTimerH += 1
						Else
							ExitLoop
						EndIf
					Next
					;;;;;;;;;
					$sDateAndTime = _DateAdd("D", $iTimerD, $sDateAndTime)
					$sDateAndTime = _DateAdd("h", $iTimerH, $sDateAndTime)
					$iDateDiffUniversal = _DateDiff('s', _NowCalcDate() & " " & _NowTime(5), $sDateAndTime)
					Setlog($iDateDiffUniversal)
					If $iSoonestTimer = -1 Or $iSoonestTimer > $iDateDiffUniversal Then $iSoonestTimer = $iDateDiffUniversal
				EndIf
				; If $g_bDebugSetlog Then SetDebugLog("@Hour: " & @HOUR & "Timers " & $i + 1 & ": " & $g_aiBtnAction1[$i] & " / " & $g_aiBtnAction2[$i] & ". $iSoonestTimer = " & $iSoonestTimer)
			EndIf
		Next
		If $g_bDebugSetlog Then SetDebugLog("$iSoonestTimer = " & $iSoonestTimer)
		If $iSoonestTimer >= 0 Then
			$iSleeptime = $iSoonestTimer * 1000 ; ($iSoonestTimer - $sCurrentDate) * 60
		EndIf
	EndIf

	If $g_bDebugSetlog Then SetDebugLog("$iSleeptime: " & $iSleeptime & " ms")

	Return $iSleeptime

EndFunc   ;==>CheckLastActiveAccount

Func GetTimersFS($i = 0, $iFS = 0)
	Local $a[0]
	If $iFS = 0 Then
		$a = StringSplit($g_sChkNotifyhoursFS1S[$i], "|", $STR_NOCOUNT)
		If UBound($a) >= 23 And Not @error Then
			$g_aiActiveFSTimersDays = $a
			ReDim $g_aiActiveFSTimersDays[24]
		EndIf
		$a = StringSplit($g_sChkNotifyWeekdaysFS1S[$i], "|", $STR_NOCOUNT)
		If UBound($a) >= 6 And Not @error Then
			$g_aiActiveFSTimersWeek = $a
			ReDim $g_aiActiveFSTimersWeek[7]
		EndIf
	Else
		$a = StringSplit($g_sChkNotifyhoursFS2S[$i], "|", $STR_NOCOUNT)
		If UBound($a) >= 23 And Not @error Then
			$g_aiActiveFSTimersDays = $a
			ReDim $g_aiActiveFSTimersDays[24]
		EndIf
		$a = StringSplit($g_sChkNotifyWeekdaysFS2S[$i], "|", $STR_NOCOUNT)
		If UBound($a) >= 6 And Not @error Then
			$g_aiActiveFSTimersWeek = $a
			ReDim $g_aiActiveFSTimersWeek[7]
		EndIf
	EndIf
EndFunc   ;==>GetTimersFS

; #FUNCTION# ====================================================================================================================
; Name ..........: Switch Profiles
; Description ...:
; Author ........: Demen
; Modified ......: Team AiO MOD++ (2019)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func ProfileSwitch()

	For $i = 0 To 3
		If $g_abChkSwitchMax[$i] Or $g_abChkSwitchMin[$i] Or $g_abChkBotTypeMax[$i] Or $g_abChkBotTypeMin[$i] Then
			ExitLoop
		Else
			If $i = 3 Then Return
		EndIf
	Next

	Local $iSwitchToProfile = -1, $iChangeBotType = -1
	Local $asText[4] = ["Gold", "Elixir", "Dark Elixir", "Trophy"]
	Local $bSwitchDone = False, $bChangBotTypeDone = False

	For $i = 0 To 3
		If $g_abChkSwitchMax[$i] Or $g_abChkBotTypeMax[$i] Then
			If Number($g_aiCurrentLoot[$i]) >= Number($g_aiConditionMax[$i]) Then
				SetLog("Village " & $asText[$i] & " detected above " & $asText[$i] & " Switch Condition: " & $g_aiCurrentLoot[$i] & "/" & $g_aiConditionMax[$i])
				If $g_abChkSwitchMax[$i] Then $iSwitchToProfile = $g_aiCmbSwitchMax[$i]
				If $g_abChkBotTypeMax[$i] Then $iChangeBotType = $g_aiCmbBotTypeMax[$i]
				ExitLoop
			EndIf
		EndIf
		If $g_abChkSwitchMin[$i] Or $g_abChkBotTypeMin[$i] Then
			If Number($g_aiCurrentLoot[$i]) < Number($g_aiConditionMin[$i]) And Number($g_aiCurrentLoot[$i]) > 1 Then
				SetLog("Village " & $asText[$i] & " detected below " & $asText[$i] & " Switch Condition: " & $g_aiCurrentLoot[$i] & "/" & $g_aiConditionMin[$i])
				If $g_abChkSwitchMin[$i] Then $iSwitchToProfile = $g_aiCmbSwitchMin[$i]
				If $g_abChkBotTypeMin[$i] Then $iChangeBotType = $g_aiCmbBotTypeMin[$i]
				ExitLoop
			EndIf
		EndIf
	Next

	If $iSwitchToProfile >= 0 Or $iChangeBotType >= 0 Then
		TrayTip(" Profile Switch Village Report!", "Gold: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & "; Elixir: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & "; Dark Elixir: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & "; Trophy: " & _NumberFormat($g_aiCurrentLoot[$eLootTrophy]), "", 0)

		If $iSwitchToProfile >= 0 Then
			; change profile in the account list
			If ProfileSwitchAccountEnabled() Then
				If $iSwitchToProfile <> _GUICtrlComboBox_GetCurSel($g_ahCmbProfile[$g_iCurAccount]) Then
					_GUICtrlComboBox_SetCurSel($g_ahCmbProfile[$g_iCurAccount], $iSwitchToProfile)
					SetLog("Acc [" & $g_iCurAccount + 1 & "] is now matched with Profile: " & GUICtrlRead($g_ahCmbProfile[$g_iCurAccount]))
				EndIf
			EndIf
			; change profile in main tab bot
			If $iSwitchToProfile <> _GUICtrlComboBox_GetCurSel($g_hCmbProfile) Then
				_GUICtrlComboBox_SetCurSel($g_hCmbProfile, $iSwitchToProfile)
				SetLog("Switched to Profile: " & GUICtrlRead($g_hCmbProfile))
				$bSwitchDone = True
				If ProfileSwitchAccountEnabled() Then $g_bReMatchAcc = True
			EndIf
		EndIf

		If ProfileSwitchAccountEnabled() Then
			Switch $iChangeBotType
				Case 0 ; turn Off (idle)
					If GUICtrlRead($g_ahChkAccount[$g_iCurAccount]) = $GUI_CHECKED Then
						GUICtrlSetState($g_ahChkAccount[$g_iCurAccount], $GUI_UNCHECKED)
						chkAccount($g_iCurAccount)
						SetLog("Acc [" & $g_iCurAccount + 1 & "] is now turned off")
						$bChangBotTypeDone = True
					EndIf
				Case 1 ; turn Donate
					If GUICtrlRead($g_ahChkDonate[$g_iCurAccount]) = $GUI_UNCHECKED Then
						_GUI_Value_STATE("CHECKED", $g_ahChkAccount[$g_iCurAccount] & "#" & $g_ahChkDonate[$g_iCurAccount])
						SetLog("Acc [" & $g_iCurAccount + 1 & "] is now for Donating only")
						$bChangBotTypeDone = True
					EndIf
				Case 2 ; turn Active
					If GUICtrlRead($g_ahChkAccount[$g_iCurAccount]) = $GUI_UNCHECKED Or GUICtrlRead($g_ahChkDonate[$g_iCurAccount]) = $GUI_CHECKED Then
						GUICtrlSetState($g_ahChkAccount[$g_iCurAccount], $GUI_CHECKED)
						GUICtrlSetState($g_ahChkDonate[$g_iCurAccount], $GUI_UNCHECKED)
						SetLog("Acc [" & $g_iCurAccount + 1 & "] starts Farming now")
						$bChangBotTypeDone = True
					EndIf
			EndSwitch
			If $bChangBotTypeDone Then $g_bInitiateSwitchAcc = True
		EndIf

		If _Sleep(500) Then Return

		If $bSwitchDone Or $bChangBotTypeDone Then
			If $bSwitchDone Then
				cmbProfile()
				DisableGUI_AfterLoadNewProfile()
			Else
				saveConfig()
				readConfig()
				UpdateMultiStats()
			EndIf
			runBot()
		EndIf
	EndIf

EndFunc   ;==>ProfileSwitch

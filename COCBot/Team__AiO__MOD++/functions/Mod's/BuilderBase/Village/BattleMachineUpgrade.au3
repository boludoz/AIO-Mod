; #FUNCTION# ====================================================================================================================
; Name ..........: BattleMachineUpgrade
; Description ...:
; Syntax ........: BattleMachineUpgrade()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_sMachineTime = '1000/01/01 00:00:00'

Func TestBattleMachineUpgrade()
	Local $bWasRunState = $g_bRunState
	Local $sWasMachineTime = $g_sMachineTime
	Local $bWasChkUpgradeMachine = $g_bChkUpgradeMachine
	$g_bRunState = True
	$g_bChkUpgradeMachine = True
	$g_sMachineTime = '1000/01/01 00:00:00'
	Local $Result = BattleMachineUpgrade(True)
	$g_bRunState = $bWasRunState
	$g_sMachineTime = $sWasMachineTime
	$g_bChkUpgradeMachine = $bWasChkUpgradeMachine
	Return $Result
EndFunc

Func BattleMachineUpgrade($bTestRun = False)

	; If is to run
	If Not $g_bChkUpgradeMachine Then Return

	;Just to debug
	FuncEnter(BattleMachineUpgrade)

	ClickP($aAway, 1, 0, "#0900") ;Click Away

	; [0] = Remain Upgrade time for next level  [1] = Machine next Level , [2] = Machine Next level cost
	Local $aMachineStatus[3] = [0,0,0]

	Local $aElixirStorageCap

	;Local Varibales
	Local $MachineUpgTimes[25] = [12, 12, 12, 24, 24, 24, 24, 24, 24, 24, 48, 48, 48, 48, 48, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72] ; Hours
	Local $MachineUpgCost[25] = [900000, 1000000, 1100000, 1200000, 1300000, 1500000, 1600000, 1700000, 1800000, 1900000, 2100000, 2200000, 2300000, 2400000, 2500000, 2600000, 2700000, 2800000, 2900000, 3000000, 3100000, 3200000, 3300000, 3400000, 3500000]
	Local $bDoNotProceedWithMachine = False

	; ZoomOut Check
	AndroidOnlyZoomOut()
	Local $iDateS = Number(_DateDiff('s', $g_sMachineTime, _NowCalc()))
	Local $iDateH = Number(_DateDiff('h', $g_sMachineTime, _NowCalc()))

	If $iDateS <= 0 Or $iDateH > 72 Or $bTestRun Then ; > 72 prevent infinite
		;Reset and populate variables
		Local $aMachineStatus[3] = [0,0,0]
		$aElixirStorageCap = -1

		; Verify Machine
		If $g_bChkUpgradeMachine Then BuilderBaseCheckMachine($aMachineStatus, $bTestRun)

		;Verify Elixir Storage Cap
		If $g_bChkUpgradeMachine Then BuilderBaseCheckElixirStorageCap($aElixirStorageCap, $bTestRun)

		If _Sleep(500) Then Return
		ClickP($aAway, 2, 100, "#0900") ;Click Away
	Else
		If _Sleep(500) Then Return
		ClickP($aAway, 2, 100, "#0900") ;Click Away
		Setlog("Battle machine skipped : upgrade in progress.", $COLOR_INFO)
		Return
	EndIf

	; Remain Times and if we are waiting or Not
	Local $g_sMachineTime = '1000/01/01 00:00:00'

	; Verify Level and Cost from machine, if is not exist or is maxed
	If $aMachineStatus[1] > 0 And $aMachineStatus[1] < 25 And $g_bChkUpgradeMachine Then
		Local $MachineLevel = $aMachineStatus[1]
		$aMachineStatus[0] = $MachineUpgTimes[$MachineLevel]
		$aMachineStatus[2] = $MachineUpgCost[$MachineLevel]
		Setlog("Current Machine level is " & $aMachineStatus[1], $COLOR_INFO)
		Setlog("Next Upgrade will cost " & $MachineUpgCost[$MachineLevel], $COLOR_INFO)
		Setlog("With remain time of " & $MachineUpgTimes[$MachineLevel] & " hours", $COLOR_INFO)
		; Verifing Elixir Storage Cap and Machine Value
		If Number($MachineUpgCost[$MachineLevel]) > Number($aElixirStorageCap) Then
			$bDoNotProceedWithMachine = True
			Setlog("Elixir Storage Capacity lower than Upg value!", $COLOR_WARNING)
		EndIf
	ElseIf $aMachineStatus[1] = 0 Then
		Local $aArea[4] = [355,450,521,532]
		If FastBottomGreen($aArea) Then
			ClickP($g_iMultiPixelOffSet, 1)

			If FastBottomGreen($aArea) Then
			; check for green button to use gems to finish upgrade, checking if upgrade actually started
				SetLog("Something went wrong with Battle Machine Upgrade, try again.", $COLOR_ERROR)
				ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0900") ;Click Away
				Return False
			ElseIf isGemOpen(True) = False Then ; check for gem window
				SetLog("Oops, Gems required for " & "Battle Machine" & " Upgrade, try again.", $COLOR_ERROR)
				ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0900") ;Click Away
				Return False
				;Else
				;$g_sMachineTime = _DateAdd('h', 12, $sStartTime)
			EndIf

		EndIf
		FuncReturn()
	Else
		; Machine is not to Upgrade
		$bDoNotProceedWithMachine = True
	EndIf

	; Is Not to proceed with Machine
	If $bDoNotProceedWithMachine = False Then
		If Number($aMachineStatus[2]) < Number($g_aiCurrentLootBB[$eLootElixirBB]) Then
			BuilderBaseUpgradeMachine($bTestRun)
		Else
			SetLog("Not Enough Elixir to Upgrade Machine!", $COLOR_INFO)
		EndIf
	EndIf

	If _Sleep(2000) Then Return
	ClickP($aAway, 2, 1000, "#0900") ;Click Away
	FuncReturn()
EndFunc   ;==>BattleMachineUpgrade


; Extra Methods
; First Check
Func BuilderBaseCheckMachine(ByRef $aMachineStatus, $bTestRun = 0)
	ClickP($aAway, 2, 300, "#900") ;Click Away
	; $aMachineStatus[X][0] = Remain Upgrade time for next level  [1] = Machine next Level , [2] = Machine Next level cost

	If IsMainPageBuilderBase() Then
		; Machine Detection
		Local $MachinePosition = _ImageSearchXML($g_sXMLTroopsUpgradeMachine, 1, "0,50,860,594", True, $bTestRun)
		If IsArray($MachinePosition) And UBound($MachinePosition) > 0 Then
			If $bTestRun > 0 Then Setlog("Machine Found: " & _ArrayToString($MachinePosition))
			Click($MachinePosition[0][1], $MachinePosition[0][2], 1, 0, "#901")

			For $i = 0 To 10
				If _Sleep(200) Then Return
				; $aResult[1] = Name , $aResult[2] = Level
				Local $aResult = BuildingInfo(242, 520 - 30 + $g_iBottomOffsetY) ; 860x780
				If Not IsArray($aResult) Then ExitLoop
				Setlog("Machine LVL : " &  $aResult[2], $COLOR_INFO)
				If UBound($aResult) >= 2 Then ExitLoop
				If $i = 10 Then
					Setlog("Error geting the Machine Info", $COLOR_ERROR)
					ClickP($aAway, 2, 300, "#900") ;Click Away
					Return
				EndIf
			Next
			$aMachineStatus[1] = $aResult[2] <> "Broken" ? Number($aResult[2]) : 0
			If $bTestRun > 0 Then Setlog("Machine Level: " & $aMachineStatus[1])
		Else
			 _DebugFailedImageDetection("Machine")
			$aMachineStatus[1] = 0
		EndIf
	EndIf
	ClickP($aAway, 2, 300, "#900") ;Click Away
EndFunc   ;==>BuilderBaseCheckMachine

Func BuilderBaseCheckElixirStorageCap(ByRef $iElixirStorageCap, $bTestRun = False)
	ClickP($aAway, 1, 1000, "#900") ;Click Away
	If IsMainPageBuilderBase() Then
		Local $ElixirStorageCapPosition[2] = [750, 80]
		ClickP($ElixirStorageCapPosition, 1, 300, "ElixirCap")
		For $i = 0 To 10
			If _sleep(200) Then Return
			$iElixirStorageCap = Number(getResourcesMainScreen(738, 113)) ;  coc-bonus
			If $iElixirStorageCap = "" Then getResourcesBonus(738, 113) ; when reach the full Cap the numbers are bigger
			If IsNumber($iElixirStorageCap) And $iElixirStorageCap > 0 Then ExitLoop
			If $i = 10 Then Setlog("Error getting thge Elixir Storage Cap", $COLOR_ERROR)
		Next
	EndIf
	If $bTestRun = True Then $g_aiCurrentLootBB[$eLootElixirBB] = 99999999999
	If $bTestRun = True Then $iElixirStorageCap = 99999999999
	If $bTestRun = False Then Setlog("Elixir Storage Cap: " & $iElixirStorageCap)
	ClickP($aAway, 2, 300, "#900") ;Click Away
EndFunc   ;==>BuilderBaseCheckElixirStorageCap

; Machine
Func BuilderBaseUpgradeMachine($bTestRun = False)
	If IsMainPageBuilderBase() Then
		; Machine Detection
		Local $MachinePosition = _ImageSearchXML($g_sXMLTroopsUpgradeMachine, 1, "0,50,860,594", True, $bTestRun)
		If IsArray($MachinePosition) And UBound($MachinePosition) > 0 Then
			SetDebugLog("Machine Found: " & _ArrayToString($MachinePosition))
			Click($MachinePosition[0][1], $MachinePosition[0][2], 1, 0, "#9010")
			If _Sleep(2000) Then Return
			;If GetUpgradeButton("Elixir", $bTestRun) And not $bTestRun Then Return True
			;If _Sleep(2000) Then Return
			Local $iXMoved = 0, $iYMoved = 0
			BattleMachineUpgradeUpgrade("Battle Machine", $iXMoved = 0, $iYMoved = 0, $bTestRun)
		Else
			 _DebugFailedImageDetection("UpgradeMachine")
		EndIf
	EndIf
	Return False
EndFunc   ;==>BuilderBaseUpgradeMachine

Func BattleMachineUpgradeUpgrade($sSelectedUpgrade, $iXMoved = 0, $iYMoved = 0, $bTestRun = False)
	Local $sStartTime, $EndTime, $EndPeriod, $Result, $TimeAdd = 0
		If _Sleep(2000) Then Return

		If QuickMIS("BC1", $g_sImgAutoUpgradeBtnDir, 300, 650, 600, 720, True, $bTestRun) Then
			Click($g_iQuickMISX + 300, $g_iQuickMISY + 650, 1)
			If _Sleep(1500) Then Return
		Else
			SetLog("Something went wrong with " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
			ClickP($aAway, 2, 0, "#0204")
			Return False
		EndIf

			; get upgrade time from window
			$Result = getLabUpgradeTime(554 + $iXMoved, 491 + $iYMoved) ; Try to read white text showing time for upgrade
			Local $iMachineFinishTime = ConvertOCRTime("Machine Time", $Result, False)
			SetLog($sSelectedUpgrade & " Upgrade OCR Time = " & $Result & ", $iMachineFinishTime = " & $iMachineFinishTime & " m", $COLOR_INFO)
			$sStartTime = _NowCalc() ; what is date:time now
			If $g_bDebugSetlog Then SetDebugLog($sSelectedUpgrade & " Upgrade Started @ " & $sStartTime, $COLOR_SUCCESS)
			If $iMachineFinishTime > 0 Then
				SetLog($sSelectedUpgrade & " Upgrade Finishes @ " & $Result & " (" & $g_sStarLabUpgradeTime & ")", $COLOR_SUCCESS)
			Else
				SetLog("Error processing upgrade time required, try again!", $COLOR_WARNING)
				Return False
			EndIf

			If Not $bTestRun Then Click(645 + $iXMoved, 530 + $g_iMidOffsetY + $iYMoved, 1, 0, "#0202") ; Everything is good - Click the upgrade button
			If _Sleep($DELAYLABUPGRADE1) Then Return

			If isGemOpen(True) = False Then ; check for gem window
				; check for green button to use gems to finish upgrade, checking if upgrade actually started
				If Not (_ColorCheck(_GetPixelColor(625 + $iXMoved, 218 + $g_iMidOffsetY + $iYMoved, True), Hex(0x6fbd1f, 6), 15) Or _ColorCheck(_GetPixelColor(660 + $iXMoved, 218 + $g_iMidOffsetY + $iYMoved, True), Hex(0x6fbd1f, 6), 15)) Then
					SetLog("Something went wrong with " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
					ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0360")
					Return False
				EndIf
				SetLog("Upgrade " & $sSelectedUpgrade & " started with success...", $COLOR_SUCCESS)
				PushMsg("BattleMachineUpgradeSuccess")
				$g_sMachineTime = _DateAdd('n', Ceiling($iMachineFinishTime), $sStartTime)
				If _Sleep($DELAYLABUPGRADE2) Then Return

				ClickP($aAway, 2, 0, "#0204")

				Return True
			Else
				SetLog("Oops, Gems required for " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
				ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0205")
			EndIf
	ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0205")
	Return False
EndFunc   ;==>BattleMachineUpgrade

Func FastBottomGreen($aArea = 0, $iDBG = 0)
	; Samm0d
	If Not $g_bRunState Then Return

    Local $iSpecialColor[2][3] = [[0xE6FC96, 1, 0], [0xE6FC96, 2, 0]]

    For $i = 0 to 15
       If IsArray(_MultiPixelSearch($aArea[0], $aArea[1], $aArea[2], $aArea[3], 1, 1, Hex(0xE6FC96, 6), $iSpecialColor, 20)) Then ExitLoop
		Sleep(10)
	Next

	If $i > 15 Then
		Return False
	EndIf

	SetDebugLog("FastBottomGreen : Button detected: " & $g_iMultiPixelOffSet[0] & "," & $g_iMultiPixelOffSet[1])
	Return True
EndFunc   ;==>FindVersusBattlebtn

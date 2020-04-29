; #FUNCTION# ====================================================================================================================
; Name ..........: BattleMachineUpgrade
; Description ...:
; Syntax ........: BattleMachineUpgrade()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (redo), ProMac (03-2018), Fahid.Mahmood
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
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
	Local $Result = BattleMachineUpgrade()
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
		BuilderBaseCheckMachine($aMachineStatus, $bTestRun)

		If _Sleep(500) Then Return
		ClickP($aAway, 2, 100, "#0900") ;Click Away
	Else
		If _Sleep(500) Then Return
		ClickP($aAway, 2, 100, "#0900") ;Click Away
		Setlog("Battle machine skipped : upgrade in progress.", $COLOR_INFO)
		Return
	EndIf

	; Remain Times and if we are waiting or Not
	$g_sMachineTime = '1000/01/01 00:00:00'

	If $aMachineStatus[1] = 0 Then
		If FastBottomGreen() Then
			ClickP($g_iMultiPixelOffSet, 1)

			If FastBottomGreen() Then
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
		Return
	EndIf

	BuilderBaseUpgradeMachine($bTestRun)

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

			; get upgrade time from window part 1
			$Result = getLabUpgradeTime(554 + $iXMoved, 491 + $iYMoved) ; Try to read white text showing time for upgrade
			Local $iMachineFinishTime = ConvertOCRTime("Machine Time", $Result, False)
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

				; get upgrade time from window par 2
				SetLog($sSelectedUpgrade & " Upgrade OCR Time = " & $Result & ", $iMachineFinishTime = " & $iMachineFinishTime & " m", $COLOR_INFO)
				$sStartTime = _NowCalc() ; what is date:time now
				If $g_bDebugSetlog Then SetDebugLog($sSelectedUpgrade & " Upgrade Started @ " & $sStartTime, $COLOR_SUCCESS)
				
				ClickP($aAway, 2, 0, "#0204")
				Return True
			Else
				SetLog("Oops, Gems required for " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
				ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0205")
			EndIf
	ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0205")
	Return False
EndFunc   ;==>BattleMachineUpgrade

Func FastBottomGreen($iDBG = 0)
	If Not $g_bRunState Then Return
	Local $aArea[4] = [355,450,521,532]

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

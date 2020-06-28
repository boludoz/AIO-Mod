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

	Local $bDoNotProceedWithMachine = False

	; ZoomOut Check
	BuilderBaseZoomOut()
	
	Local $iDateS = Number(_DateDiff('s', $g_sMachineTime, _NowCalc()))
	Local $iDateH = Number(_DateDiff('h', $g_sMachineTime, _NowCalc()))

	If _Sleep(500) Then Return
	
	If Not (($iDateS <= 0) Or ($iDateH > 72) Or $bTestRun) Then ; > 72 prevent infinite
		ClickP($aAway, 2, 100, "#0900") ;Click Away
		Setlog("Battle machine skipped : upgrade in progress.", $COLOR_INFO)
		Return
	EndIf
	
	; Remain Times and if we are waiting or Not
	$g_sMachineTime = '1000/01/01 00:00:00'

	BuilderBaseUpgradeMachine($bTestRun)
	If _Sleep(1000) Then Return

	FuncReturn()
EndFunc   ;==>BattleMachineUpgrade

; Machine
Func BuilderBaseUpgradeMachine($bTestRun = False)
		Local $iXMoved = 0, $iYMoved = 0, $sSelectedUpgrade = "Battle Machine"
		
		If (Not IsMainPageBuilderBase()) Then
			_DebugFailedImageDetection("UpgradeMachine")
			Return False
		EndIf

		; Machine Detection
		Local $aMachinePosition = _ImageSearchXML($g_sXMLTroopsUpgradeMachine, 1, "0,50,860,594", True, $bTestRun)
		
		If (Not IsArray($aMachinePosition) Or not (UBound($aMachinePosition) > 0)) Then 
			_DebugFailedImageDetection("UpgradeMachine")
			Return False
		EndIf
		
		SetDebugLog("Machine Found: " & _ArrayToString($aMachinePosition))
		Click($aMachinePosition[UBound($aMachinePosition)-1][1], $aMachinePosition[UBound($aMachinePosition)-1][2], 1, 0, "#9010")
		If RandomSleep(1000) Then Return

		#Region - Mode
        Local $aResult = BuildingInfo(242, 490 + $g_iBottomOffsetY)
        If Not IsArray($aResult) Then 
			If (StringIsSpace($aResult[2])) And not ($aResult[0] = "Battle Machine") Then
				Setlog("Error geting the Machine Info", $COLOR_ERROR)
				ClickP($aAway, 2, 300, "#900") ;Click Away
				Return
			EndIf
			Return
		EndIf
		
        Setlog("Machine level : " &  $aResult[2], $COLOR_INFO)
        
        Local $iMachineLevel = ($aResult[2] <> "Broken") ? (Number($aResult[2])) : ("Broken")
        If ($bTestRun = True) Then Setlog("Machine Level: " & $iMachineLevel)
		#EndRegion - Mode

		#Region - FindButton
		Local $aUpgradeButton = findButton("Upgrade", Default, 1, True)
		If IsArray($aUpgradeButton) And UBound($aUpgradeButton, 1) = 2 Then
			If _Sleep($DELAYUPGRADEHERO2) Then Return
			ClickP($aUpgradeButton)
			If _Sleep($DELAYUPGRADEHERO3) Then Return ; Wait for window to open
			Else
			SetLog("Something went wrong with " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
			ClickP($aAway, 2, 0, "#0204")
			Return False
		EndIf
		#EndRegion - FindButton
		
		If RandomSleep(1500) Then Return
		
		#Region - Mode switch
		Local $b = False
		Switch $iMachineLevel
			Case "Broken"
				Local $iMachineFinishTime = Int(12*60)
				$b = RebuildStructure()
			Case Else
				Local $iMachineFinishTime = "", $sSelectedUpgrade
				$b = BattleMachineUpgradeUpgrade($iMachineFinishTime, $bTestRun)
		EndSwitch
		#EndRegion - Mode switch
		
		If ($b = False) Then 
			SetLog("Machine upgrade not possible.", $COLOR_INFO)
			Return False
		EndIf
		
		#Region
		If ($bTestRun = False)  Then Click(645, 530 + $g_iMidOffsetY, 1, 0, "#0202") ; Everything is good - Click the upgrade button
		If _Sleep($DELAYLABUPGRADE1) Then Return
		
		If (isGemOpen(True) = False) And IsMainPageBuilderBase(2) Then ; check for gem window

			Local $sStartTime = _NowCalc() ; what is date:time now
			Local $sResult = ($iMachineFinishTime / 60)
			
			SetLog($sSelectedUpgrade & " Upgrade Finishes @ " & $sResult & " (" & $sSelectedUpgrade & ")", $COLOR_SUCCESS)
		
			SetLog("Upgrade " & $sSelectedUpgrade & " started with success...", $COLOR_SUCCESS)
			PushMsg("BattleMachineUpgradeSuccess")
			$g_sMachineTime = _DateAdd('n', Ceiling($iMachineFinishTime), $sStartTime)
			If _Sleep($DELAYLABUPGRADE2) Then Return

			; get upgrade time from window par 2
			SetLog($sSelectedUpgrade & " Upgrade OCR Time = " & $sResult & ", $iMachineFinishTime = " & $iMachineFinishTime & " m", $COLOR_INFO)
			If $g_bDebugSetlog Then SetDebugLog($sSelectedUpgrade & " Upgrade Started @ " & $sStartTime, $COLOR_SUCCESS)
			
			Return True
		ElseIf Not IsMainPageBuilderBase(2) Then ; Trick in case the button is not pressed.
			SetLog("Machine upgrade not possible. (2)", $COLOR_INFO)
		Else
			SetLog("Oops, Gems required for " & $sSelectedUpgrade & " Upgrade, try again.", $COLOR_ERROR)
		EndIf
		#EndRegion
		
		ClickP($aAway, 2, $DELAYLABUPGRADE3, "#0205")
		Return False
		
EndFunc   ;==>BuilderBaseUpgradeMachine

Func RebuildStructure()
	Local $vButton
	; Button - 360, 460, 520, 530
	For $i = 0 To 3
		$vButton = findMultipleQuick(@scriptdir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\Upgrade\Rebuild\", 10, "360, 460, 520, 530")
		If IsArray($vButton) Then ExitLoop
		If _Sleep(300) Then Return
	Next 
	
	If Not IsArray($vButton) Then Return False
	
	If (__ArraySearch($vButton, "NoRes") <> -1) Then 
		SetDebugLog("RebuildStructure fail", $COLOR_ERROR)
		Return False
	EndIf
	
	Click($vButton[0][1], $vButton[0][2])
	Return True
EndFunc

Func BattleMachineUpgradeUpgrade(ByRef $iMachineFinishTime, $bTestRun = False)
	If _ColorCheck(_GetPixelColor(398, 568, True), Hex(0xE1433F, 6), 20) Then Return False
	; get upgrade time from window part 
	$iMachineFinishTime = ConvertOCRTime("Machine Time", getLabUpgradeTime(581, 495), False)
	If ($iMachineFinishTime > 0) Then
		Return True
	Else
		SetLog("Error processing upgrade time required, try again!", $COLOR_WARNING)
		Return False
	EndIf
	Return False
EndFunc   ;==>BattleMachineUpgrade

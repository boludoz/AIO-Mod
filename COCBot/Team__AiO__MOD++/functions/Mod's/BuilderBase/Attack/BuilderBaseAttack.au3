; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018)
; Modified ......: Chilly-Chill (05/2019)
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TestBuilderBaseAttack()
	Setlog("** TestBuilderBaseAttack START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	Local $AvailableAttacksBB = $g_iAvailableAttacksBB
	$g_iAvailableAttacksBB = 3
	BuilderBaseAttack(True)
	$g_iAvailableAttacksBB = $AvailableAttacksBB
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseAttack END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseAttack

Func BuilderBaseAttack($bTestRun = False)

	If Not $g_bRunState Then Return

	; Check if Builder Base is to run
	If Not $g_bChkBuilderAttack Then Return

	; Stop when reach the value set it as minimum of trophies
	If (Not $bTestRun) And Int($g_aiCurrentLootBB[$eLootTrophyBB]) < Int($g_iTxtBBDropTrophiesMin) And $g_iAvailableAttacksBB = 0 Then
		Setlog("You reach the value set it as minimum of trophies!", $COLOR_INFO)
		Setlog("And you don't have any attack available.", $COLOR_INFO)
		Return
	EndIf

	; Variables
	Local $IsReaddy = False, $IsToDropTrophies = False

	; LOG
	Setlog("Entering in Builder Base Attack!", $COLOR_INFO)

	If checkObstacles(True) Then Return
	If $g_bRestart Then Return
	If _Sleep(1500) Then Return ; Add Delay Before Check Builder Face As When Army Camp Get's Close Due To It's Effect Builder Face Is Dull and not recognized on slow pc

	; Check for builder base.
	If Not isOnBuilderBase() Then Return

	; Check Zoomout
	BuilderBaseZoomOut()

	; Check Attack Button
	If Not CheckAttackBtn() Then Return

	; Check Versus Battle window status
	If Not isOnVersusBattleWindow() Then Return

	; Get Army Status
	ArmyStatus($IsReaddy)

	; Get Drop Trophies Status
	IsToDropTrophies($IsToDropTrophies)

	; Get Battle Machine status
	Local $HeroStatus = HeroStatus()
	$g_bIsMachinePresent = ($HeroStatus = "Battle Machine ready to use" ? True : False)


	;If $bTestRun Then $IsToDropTrophies = True

	; User LOG
	SetLog(" - Are you ready to Battle? " & $IsReaddy, $COLOR_INFO)
	SetLog(" - Is To Drop Trophies? " & $IsToDropTrophies, $COLOR_INFO)
	SetLog(" - " & $HeroStatus, $COLOR_INFO)

	If $g_bRestart = True Then Return
	If FindVersusBattlebtn() And $IsReaddy And (($IsToDropTrophies) Or ($g_iCmbBBAttack = $g_eBBAttackCSV) Or ($g_iCmbBBAttack = $g_eBBAttackSmart)) Then
		ClickP($g_iMultiPixelOffSet, 1)
		If RandomSleep(3000) Then Return

		; Clouds
		If Not WaitForVersusBattle() Then Return
		If Not $g_bRunState Then Return

		; Zoomout the Opponent Village
		BuilderBaseZoomOut()
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return

		; Attack Bar | [0] = Troops Name , [1] = X-axis , [2] - Y-axis, [3] - Slot starting at 0, [4] - Amount
		; Local $aAvailableTroops = BuilderBaseAttackBar()
		Local $aAvailableTroops = GetAttackBarBB()
		If IsArray($aAvailableTroops) Then
			SetDebugLog("Attack Bar Array: " & _ArrayToString($aAvailableTroops, "-", -1, -1, "|", -1, -1))
		Else
			SetDebugLog("No troops AttackBar.", $COLOR_ERROR)
			CheckMainScreen()
			Return -1
		EndIf

		; Verify the scripts and attack bar
		If Not $IsToDropTrophies Then BuilderBaseSelectCorrectScript($aAvailableTroops)

		; Avoid bugs in redlines (too fast MyBot).
		If RandomSleep(1500) Then Return

		; Reset vars machine.
		$g_aMachineBB = $g_aMachineBBReset

		RemoveChangeTroopsDialog()

		; Select mode.
		Select
			Case $IsToDropTrophies = True
				Setlog("Let's Drop some Trophies!", $COLOR_SUCCESS)

				; Start the Attack realing one troop and surrender
				BuilderBaseAttackToDrop($aAvailableTroops)
				If Not $g_bRunState Then Return

			Case ($g_iCmbBBAttack = $g_eBBAttackCSV)
				Setlog("Ready to Battle! BB CSV... Let's Go!", $COLOR_SUCCESS)

				; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window
				BuilderBaseCSVAttack($aAvailableTroops)
				If Not $g_bRunState Then Return

			Case ($g_iCmbBBAttack = $g_eBBAttackSmart)
				Setlog("Ready to Battle! BB Smart Attack... Let's Go!", $COLOR_SUCCESS)

				; BB Smart Attack
				AttackBB($aAvailableTroops)
				If Not $g_bRunState Then Return

			Case Else
				$g_bRestart = ($bTestRun = True) ? (False) : (True)
				If $g_bRestart = True Then Return

		EndSelect

		; Attack Report Window
		BuilderBaseAttackReport()
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return

	EndIf

	; Exit
	Setlog("Exit from Builder Base Attack!", $COLOR_INFO)
	ClickP($aAway, 2, 0, "#0332") ;Click Away
	If _Sleep(2000) Then Return
EndFunc   ;==>BuilderBaseAttack

Func RemoveChangeTroopsDialog()
	If _ColorCheck(_GetPixelColor(103, 710, True), Hex(0x6C6E6F, 6), 25) Then
		SetLog("Removing change troops dialog to start attack...", $COLOR_INFO)
		Local $aClickPoints = [64, 648]
		$aClickPoints[0] += Random(1, 282, 1)
		$aClickPoints[1] += Random(1, 35, 1)
		ClickP($aClickPoints)
		Return True
	EndIf
	Return False
EndFunc   ;==>RemoveChangeTroopsDialog

Func CheckAttackBtn()
	If QuickMIS("BC1", $g_sImgAttackBtnBB, 16, 627, 107, 713, True, False) Then
		If $g_iQuickMISWOffSetX > 16 And $g_iQuickMISWOffSetX < 107 And $g_iQuickMISWOffSetY > 627 And $g_iQuickMISWOffSetY < 713 Then
			SetDebugLog("Attack Button detected: " & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY)
			Click(Random(16, 107, 1), Random(627, 713, 1), 1)
			If _Sleep(Random(200, 3000, 1)) Then Return
			Return True
		Else
			SetLog("Attack Button not available...", $COLOR_WARNING)
			If _Sleep(Random(200, 3000, 1)) Then Return
			Return False
		EndIf
	EndIf
	Return True
EndFunc   ;==>CheckAttackBtn

Func isOnVersusBattleWindow()
	If Not $g_bRunState Then Return
	Local $iSpecialColor[4][3] = [[0x87A9CF, 1, 0], [0x87A9CF, 2, 0], [0x87A9CF, 3, 0], [0x87A9CF, 4, 0]]

	For $i = 0 To 15
		If Not $g_bRunState Then Return
		_MultiPixelSearch(591, 119, 668, 216, 1, 1, Hex(0x87A9CF, 6), $iSpecialColor, 30)
		SetDebugLog("******* isOnVersusBattleWindow Try X:" & $g_iMultiPixelOffSet[0])
		If Number($g_iMultiPixelOffSet[0]) > 0 Then ExitLoop
		If _Sleep(1000) Then Return
	Next

	If $i < 15 Then
		SetDebugLog("Versus Battle window detected: " & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY)
		Return True
	Else
		SetLog("Versus Battle window not available...", $COLOR_WARNING)
		Return False
	EndIf
EndFunc   ;==>isOnVersusBattleWindow

Func ArmyStatus(ByRef $bIsReady)
	If Not $g_bRunState Then Return

	#Region Legacy Chilly-Chill fragment.
	Local $sSearchDiamond = GetDiamondFromRect("114,384,190,450") ; start of trained troops bar untill a bit after the 'r' "in Your Troops"
	Local $aNeedTrainCoords = decodeSingleCoord(findImage("NeedTrainBB", $g_sImgBBNeedTrainTroops, $sSearchDiamond, 1, True))

	If IsArray($aNeedTrainCoords) And UBound($aNeedTrainCoords) = 2 Then
		Local $bNeedTrain = True

		ClickP($aAway, 1, 0, "#0000") ; ensure field is clean
		If _Sleep(1500) Then Return ; Team AIO Mod++ Then Return
		SetLog("Troops need to be trained in the training tab.", $COLOR_INFO)
		CheckArmyBuilderBase()
		$bIsReady = False
		Return False

	EndIf
	#EndRegion Legacy Chilly-Chill fragment.

	If QuickMis("BC1", $g_sImgFullArmyBB, 108, 355, 431, 459, True, False) Then
		SetDebugLog("Full Army detected.")
		SetLog("Full Army detected", $COLOR_INFO)
		$bIsReady = True
	ElseIf QuickMis("BC1", $g_sImgHeroStatusUpg, 108, 355, 431, 459, True, False) Then
		SetLog("Full Army detected, But Battle Machine is on Upgrade", $COLOR_INFO)
		$bIsReady = True
	Else
		$bIsReady = False
	EndIf

	; If $g_bChkBBWaitForMachine And QuickMis("BC1", $g_sImgHeroStatusRec, 108, 355, 431, 459, True, False) Then
		; SetLog("Battle Machine is not ready.", $COLOR_INFO)
		; $bIsReady = False
	; EndIf

	$g_bBBMachineReady = $bIsReady

EndFunc   ;==>ArmyStatus

Func HeroStatus()
	If Not $g_bRunState Then Return
	Local $Status = "No Hero to use in Battle"
	If QuickMis("BC1", $g_sImgHeroStatusRec, 108, 355, 431, 459, True, False) Then
		$Status = "Battle Machine Recovering"
	EndIf
	If QuickMis("BC1", $g_sImgHeroStatusMachine, 108, 355, 431, 459, True, False) Then
		$Status = "Battle Machine ready to use"
	EndIf
	If QuickMis("BC1", $g_sImgHeroStatusUpg, 108, 355, 431, 459, True, False) Then
		$Status = "Battle Machine Upgrading"
	EndIf
	Return $Status
EndFunc   ;==>HeroStatus

Func IsToDropTrophies(ByRef $IsToDropTrophies)
	If Not $g_bRunState Then Return
	$IsToDropTrophies = False

	If Not $g_bChkBBTrophiesRange Then Return

	If Int($g_aiCurrentLootBB[$eLootTrophyBB]) > Int($g_iTxtBBDropTrophiesMax) Then
		SetLog("Max Trophies reached!", $COLOR_WARNING)
		$IsToDropTrophies = True
	EndIf
EndFunc   ;==>IsToDropTrophies

Func FindVersusBattlebtn()
	If Not $g_bRunState Then Return

	Local $aFindVersusBattleBtn[2][3] = [[0xFFCA4A, 1, 0], [0xFFCA4A, 0, 1]]
	Local $aOkayVersusBattleBtn[2][3] = [[0xFDDF685, 1, 0], [0xDDF685, 2, 0]]

	SetLog("Finding Button Now!")

	For $i = 0 To 5
		If _Sleep(100) Then Return False
		If _MultiPixelSearch(490, 284, 710, 375, 1, 1, Hex(0xFFCA4A, 6), $aFindVersusBattleBtn, 25) <> 0 Then
			ExitLoop
		Else
			If _MultiPixelSearch(600, 452, 745, 510, 1, 1, Hex(0xDDF685, 6), $aOkayVersusBattleBtn, 25) <> 0 Then
				SetDebugLog("OKAY! Button detected: " & $g_iMultiPixelOffSet[0] & "," & $g_iMultiPixelOffSet[1])
				ClickP($g_iMultiPixelOffSet, 2, 0)
				If _Sleep(100) Then Return False
			EndIf
		EndIf
	Next

	If ($i >= 5) Or ($g_iMultiPixelOffSet[0] = Null) Then
		SetLog("Find Now! Button not available...", $COLOR_DEBUG)
		Return False
	EndIf

	SetDebugLog("Find Now! Button detected: " & $g_iMultiPixelOffSet[0] & "," & $g_iMultiPixelOffSet[1])
	Return True
EndFunc   ;==>FindVersusBattlebtn

Func WaitForVersusBattle()
	Local $aCancelVersusBattleBtn[4][3] = [[0xFE2D40, 1, 0], [0xFE2D40, 2, 0], [0xFE2D40, 3, 0], [0xFE2D40, 4, 0]]
	Local $aAttackerVersusBattle[2][3] = [[0xFFFF99, 0, 1], [0xFFFF99, 0, 2]]

	If Not $g_bRunState Then Return
	
	; Clouds
	Local $iTime = 0
	Local $iSwitch = 0
	While $iTime < 257 ; 15 minutes
		If Not $g_bRunState Then Return False
		
		If (Mod($iTime, 3) = 0) Then $iSwitch += 1
		Switch $iSwitch
			Case 0
				SetLog("Searching for opponents.")
			Case 1
				If isProblemAffect(True) Then 
					Return False
				EndIf
			Case 2
				If checkObstacles_Network(True, True) Then 
					Return False
				EndIf
				
				$iSwitch = 0
		EndSwitch
		
		If _MultiPixelSearch(711, 2, 856, 55, 1, 1, Hex(0xFFFF99, 6), $aAttackerVersusBattle, 15) <> 0 Then
			ExitLoop
		EndIf
		
		If _Sleep(3000) Then Return
		$iTime += 1
	WEnd
	
	If $iTime >= 257 Then
		If _MultiPixelSearch(375, 547, 450, 555, 1, 1, Hex(0xFE2D40, 6), $aCancelVersusBattleBtn, 5) <> 0 Then
			SetLog("Exit from battle search.", $COLOR_WARNING)
			ClickP($g_iMultiPixelOffSet, 2, 0)
			If _Sleep(3000) Then Return
			Return False
		EndIf
	EndIf
	
	For $i = 0 To 60
		If Not $g_bRunState Then Return False
		Local $sBattle = _getBattleEnds()
		SetDebugLog("WaitForVersusBattle: _getBattleEnds : " & $sBattle)
		If StringInStr($sBattle, "s") Then ExitLoop
		If _Sleep(2000) Then Return
		If $i = 60 Then Return False
	Next

	SetLog("The Versus Battle begins NOW!", $COLOR_SUCCESS)
	
	Return True

EndFunc   ;==>WaitForVersusBattle

Func BuilderBaseAttackToDrop($aAvailableTroops)
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	If Not $g_bRunState Then Return
	If Not UBound($aAvailableTroops) > 0 Then Return

	; Reset all variables
	BuilderBaseResetAttackVariables()

	Local $Troop = $aAvailableTroops[0][0]
	Local $Slot = [$aAvailableTroops[0][1], $aAvailableTroops[0][2]]

	; Select the Troop
	ClickP($Slot, 1, 0)

	Setlog("Selected " & FullNametroops($Troop) & " to deploy.")

	If _Sleep(1000) Then Return

	If ZoomBuilderBaseMecanics(True) < 1 Then Return False

	; [0] - TopLeft ,[1] - TopRight , [2] - BottomRight , [3] - BottomLeft
	Local $DeployPoints = BuilderBaseGetDeployPoints(5)
	Local $UniqueDeployPoint[2] = [0, 0]

	If IsArray($DeployPoints) Then
		; Just get a valid point to deploy
		For $i = 0 To 3
			Local $UniqueDeploySide = $DeployPoints[$i]
			If UBound($UniqueDeploySide) < 1 Then ContinueLoop
			$UniqueDeployPoint[0] = $UniqueDeploySide[0][0]
			$UniqueDeployPoint[1] = $UniqueDeploySide[0][1]
		Next
	EndIf

	If $UniqueDeployPoint[0] = 0 Then
		$g_aBuilderBaseDiamond = BuilderBaseAttackDiamond()
		If IsArray($g_aBuilderBaseDiamond) <> True Or Not (UBound($g_aBuilderBaseDiamond) > 0) Then Return False

		$g_aExternalEdges = BuilderBaseGetEdges($g_aBuilderBaseDiamond, "External Edges")
	EndIf

	Local $UniqueDeploySide = $g_aExternalEdges[0]
	$UniqueDeployPoint[0] = $UniqueDeploySide[0][0]
	$UniqueDeployPoint[1] = $UniqueDeploySide[0][1]

	If $UniqueDeployPoint[0] <> 0 Then
		; Deploy One Troop
		ClickP($UniqueDeployPoint, 1, 0)
	EndIf

	For $i = 0 To 15
		; Surrender button [FC5D64]
		If chkSurrenderBtn() = True Then
			SetLog("Let's Surrender!")
			ClickP($aSurrenderButton, 1, 0, "#0099") ;Click Surrender
			ExitLoop
		Else
			If ($UniqueDeploySide) > $i Then
				$UniqueDeployPoint[0] = $UniqueDeploySide[$i][0]
				$UniqueDeployPoint[1] = $UniqueDeploySide[$i][1]

				If $UniqueDeployPoint[0] <> 0 Then
					; Deploy One Troop
					ClickP($UniqueDeployPoint, 1, 0)
				EndIf
			EndIf
		EndIf
		If _Sleep(500) Then ExitLoop
	Next

	If $i >= 15 Then Setlog("Surrender button Problem!", $COLOR_WARNING)

	; Get the Surrender Window [Cancel] [Ok]
	Local $CancelBtn = [350, 445] ; DESRC Done
	Local $OKbtn = [520, 445] ; DESRC Done
	For $i = 0 To 10
		If Not $g_bRunState Then Return
		; [Cancel] = 350 , 445 : DB4E1D
		; [OK] =  520, 445 : 6DBC1F
		If _ColorCheck(_GetPixelColor($CancelBtn[0], $CancelBtn[1], True), Hex(0xDB4E1D, 6), 10) And _
				_ColorCheck(_GetPixelColor($OKbtn[0], $OKbtn[1], True), Hex(0x6DBC1F, 6), 10) Then
			ClickP($OKbtn, 1, 0)
			ExitLoop
		EndIf
		If _Sleep(500) Then ExitLoop
	Next

	If $i >= 10 Then Setlog("Surrender button OK Problem!", $COLOR_WARNING)

EndFunc   ;==>BuilderBaseAttackToDrop

Func BuilderBaseCSVAttack($aAvailableTroops, $bDebug = False)
	; $aAvailableTroops[$x][0] = Name , $aAvailableTroops[$x][1] = X axis
	If Not $g_bRunState Then Return
	; Reset all variables
	BuilderBaseResetAttackVariables()
	; $aAvailableTroops[$x][0] = Name , $aAvailableTroops[$x][1] = X axis

	; maybe will be necessary to click on attack bar to release the zoomout pinch
	; x = 75 , y = 584
	;Local $slotZero[2] = [102, 684] ; DESRC DONE
	;ClickP($slotZero, 1, 0)

	; [0] - TopLeft ,[1] - TopRight , [2] - BottomRight , [3] - BottomLeft
	Local $FurtherFrom = 5 ; 5 pixels before the deploy point
	BuilderBaseGetDeployPoints($FurtherFrom, $bDebug)
	If Not $g_bRunState Then Return
	; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window
	BuilderBaseParseAttackCSV($aAvailableTroops, $g_aDeployPoints, $g_aDeployBestPoints, $bDebug)

EndFunc   ;==>BuilderBaseCSVAttack

Func BuilderBaseAttackReport()
	; Verify the Window Report , Point[0] Archer Shadow Black Zone [155,460,000000], Point[1] Ok Green Button [430,590, 6DBC1F]
	Local $aSurrenderBtn = [65, 607]

	; Check if BattleIsOver.
	BattleIsOver()

	;BB attack Ends
	If _Sleep(2000) Then Return

	; in case BB Attack Ends in error
	If _ColorCheck(_GetPixelColor($aSurrenderBtn[0], $aSurrenderBtn[1], True), Hex(0xFE5D65, 6), 10) Then
		Setlog("Surrender Button fail - battle end early - CheckMainScreen()", $COLOR_ERROR)
		CheckMainScreen()
		Return False
	EndIf

	Local $Stars = 0
	Local $StarsPositions[3][2] = [[326, 394], [452, 388], [546, 413]]
	Local $Color[3] = [0xD0D4D0, 0xDBDEDB, 0xDBDDD8]
	Local $hResultColor = 0x000000

	If _Sleep(1500) Then Return
	If Not $g_bRunState Then Return

	For $i = 0 To UBound($StarsPositions) - 1
		If _ColorCheck(_GetPixelColor($StarsPositions[$i][0], $StarsPositions[$i][1], True), Hex($Color[$i], 6), 30) Then $Stars += 1
	Next

	Setlog("Your Attack: " & $Stars & " Star(s)!", $COLOR_INFO)

	If Okay() Then
	   SetLog("Return To Home.", $Color_Info)
	Else
	  Setlog("Return home button fail.", $COLOR_ERROR)
	  CheckMainScreen()
   EndIf

	Local $sResultName = "Draw"

	For $i = 0 To 24 ; 120 seconds
		If Not $g_bRunState Then Return
		If isOnBuilderBase(True, True) Then
			SetLog("BuilderBaseAttackReport | Something weird happened here. Leave the screen alone.", $COLOR_ERROR)
			If checkObstacles(True) Then SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
			Return
		EndIf
		; Wait
		If _Sleep(2500) Then Return ; 2,5 seconds
		If QuickMIS("BC1", $g_sImgReportWaitBB, 529, 324, 652, 372, True, False) Then
			If (Mod($i+1, 4) = 0) Then Setlog("...Opponent is Attacking!", $COLOR_INFO)
			ContinueLoop
		EndIf
		If _WaitForCheckImg($g_sImgReportFinishedBB, "465, 493, 490, 505", Default, 5000, 250) Then

			If RandomSleep(500) Then Return

			$hResultColor = _GetPixelColor(150, 192, True)

			If _ColorCheck($hResultColor, Hex(0x8DBE51, 6), 20) Then
				$sResultName = "Victory"
			ElseIf _ColorCheck($hResultColor, Hex(0xD0262C, 6), 20) Then
				$sResultName = "Defeat"
			EndIf

			Setlog("Attack Result: " & $sResultName, ($sResultName = "Victory") ? ($COLOR_SUCCESS) : ($COLOR_ERROR))
			ExitLoop
		EndIf
	Next

	; Small delay just to getout the slide resources to top left
	If RandomSleep(500) Then Return

	; Get the LOOT :
	Local $gain[3]
	; To get trophies getOcrOverAllDamage(493, 480)
	$gain[$eLootTrophyBB] = Int(getOcrOverAllDamage(493, 480))
	; $gain[$eLootGoldBB] = Int(getTrophyVillageSearch(150, 483))  ; Fix
	$gain[$eLootElixirBB] = Int(getTrophyVillageSearch(310, 483))
	Local $iLastDamage = Int(_getTroopCountBig(222, 304))
	If $iLastDamage > $g_iLastDamage Then $g_iLastDamage = $iLastDamage

	If StringInStr($sResultName, "Victory") > 0 Then
		$gain[$eLootTrophyBB] = Abs($gain[$eLootTrophyBB])
	ElseIf StringInStr($sResultName, "Defeat") > 0 Then
		$gain[$eLootTrophyBB] = $gain[$eLootTrophyBB] * -1
	Else
		$gain[$eLootTrophyBB] = 0
	EndIf

	; #######################################################################
	; Just a temp log for BB attacks , this needs a new TAB like a stats tab
	Local $AtkLogTxt
	$AtkLogTxt = "  " & String($g_iCurAccount + 1) & "|" & _NowTime(4) & "|"
	$AtkLogTxt &= StringFormat("%5d", $g_aiCurrentLootBB[$eLootTrophyBB]) & "|"
	; $AtkLogTxt &= StringFormat("%7d", $gain[$eLootGoldBB]) & "|" ; Fix
	$AtkLogTxt &= StringFormat("%7d", $gain[$eLootElixirBB]) & "|" ; Fix
	$AtkLogTxt &= StringFormat("%7d", $gain[$eLootElixirBB]) & "|"
	$AtkLogTxt &= StringFormat("%3d", $gain[$eLootTrophyBB]) & "|"
	$AtkLogTxt &= StringFormat("%1d", $Stars) & "|"
	$AtkLogTxt &= StringFormat("%3d", $g_iLastDamage) & "|"
	$AtkLogTxt &= StringFormat("%1d", $g_iBuilderBaseScript + 1) & "|"

	If StringInStr($sResultName, "Victory") > 0 Then
		SetBBAtkLog($AtkLogTxt, "", $COLOR_GREEN)
	ElseIf StringInStr($sResultName, "Defeat") > 0 Then
		SetBBAtkLog($AtkLogTxt, "", $COLOR_ERROR)
	Else
		SetBBAtkLog($AtkLogTxt, "", $COLOR_INFO)
	EndIf
	; #######################################################################


	; Return to Main Page
	ClickP($aAway, 2, 0, "#0332") ;Click Away

	; Reset Variables
	$g_aMachineBB = $g_aMachineBBReset
	$g_iBBMachAbilityLastActivatedTime = -1

	If RandomSleep(2000) Then Return

	If checkObstacles(True) Then
		SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
		Return
	EndIf
EndFunc   ;==>BuilderBaseAttackReport

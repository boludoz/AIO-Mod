; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseAttack
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseAttack()
; Parameters ....:
; Return values .: None
; Author ........: Boludoz (03-2018)
; Modified ......: Chilly-Chill (05/2019)
; Remarks .......: This file is part of MyBot, previously known as Mybot and ClashGameBot. Copyright 2015-2018
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

	; Check if is to stop at 3 attacks won
	If (Not $bTestRun) And BitAnd($g_iAvailableAttacksBB = 0, $g_bChkBBStopAt3) Then Return

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

	; If checkObstacles(True) Then Return
	If _Sleep(1500) Then Return ; Add Delay Before Check Builder Face As When Army Camp Get's Close Due To It's Effect Builder Face Is Dull and not recognized on slow pc

	; Check for Builder face
	If Not isOnBuilderBase() And (Not $bTestRun) Then Return

	; Check Zoomout
	If Not BuilderBaseZoomOut() Then Return

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
	If FindVersusBattlebtn() And $IsReaddy And BitOR($IsToDropTrophies, $g_iCmbBBAttack = $g_eBBAttackCSV, $g_iCmbBBAttack = $g_eBBAttackSmart) Then
		ClickP($g_iMultiPixelOffSet, 1)
		If _Sleep(3000) Then Return

		; Clouds
		If Not WaitForVersusBattle() Then Return
		If Not $g_bRunState Then Return

		; Attack Bar | [0] = Troops Name , [1] = X-axis , [2] - Y-axis, [3] - Slot starting at 0, [4] - Amount
		; Local $AvailableTroops = BuilderBaseAttackBar()
		Local $AvailableTroops = GetAttackBarBB()
		If $AvailableTroops <> -1 Then SetDebugLog("Attack Bar Array: " & _ArrayToString($AvailableTroops, "-", -1, -1, "|", -1, -1))

		If $AvailableTroops = -1 Then Return -1

		; Verify the scripts and attack bar
		If Not $IsToDropTrophies Then BuilderBaseSelectCorrectScript($AvailableTroops)

		; Zoomout the Opponent Village
		BuilderBaseZoomOut()
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return

		Select
			Case $IsToDropTrophies = True
				Setlog("Let's Drop some Trophies!", $COLOR_SUCCESS)

				; Start the Attack realing one troop and surrender
				BuilderBaseAttackToDrop(GetAttackBarBB(False, True))

			Case $g_iCmbBBAttack = $g_eBBAttackCSV
				Setlog("Ready to Battle! BB CSV... Let's Go!", $COLOR_SUCCESS)

				; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window
				BuilderBaseCSVAttack($AvailableTroops)
				If Not $g_bRunState Then Return

			Case $g_iCmbBBAttack = $g_eBBAttackSmart
				Setlog("Ready to Battle! BB Smart Attack... Let's Go!", $COLOR_SUCCESS)

				; BB Smart Attack
				AttackBB()
				If Not $g_bRunState Then Return
			Case Else
				$g_bRestart = ($bTestRun) ? (False) : (True)
				If $g_bRestart = True Then Return

		EndSelect

		; Attack Report Window
		BuilderBaseAttackReport()
		If $g_bRestart = True Then Return
		If Not $g_bRunState Then Return

		; Stats
		; BuilderBaseAttackUpdStats()
	EndIf

	; Exit
	Setlog("Exit from Builder Base Attack!", $COLOR_INFO)
	ClickP($aAway, 2, 0, "#0332") ;Click Away
	If _Sleep(2000) Then Return
EndFunc   ;==>BuilderBaseAttack

Func CheckAttackBtn()
	If QuickMIS("BC1", $g_sImgAttackBtnBB, 0, 620, 120, 732, True, False) Then ; DESRC Done
		SetDebugLog("Attack Button detected: " & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY)
		Click($g_iQuickMISWOffSetX, $g_iQuickMISWOffSetY, 1)
		If _Sleep(3000) Then Return
		Return True
	Else
		SetLog("Attack Button not available...", $COLOR_WARNING)
	EndIf
	Return False
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

Func ArmyStatus(ByRef $IsReaddy)
	If Not $g_bRunState Then Return
	If QuickMis("BC1", $g_sImgFullArmyBB, 108, 355, 431, 459, True, False) Then ; DESRC Done
		SetDebugLog("Full Army detected: " & $g_iQuickMISWOffSetX & "," & $g_iQuickMISWOffSetY)
		SetLog("Full Army detected", $COLOR_INFO)
		$IsReaddy = True
	ElseIf QuickMis("BC1", $g_sImgHeroStatusUpg, 108, 355, 431, 459, True, False) Then ; RC Done
		SetLog("Full Army detected, But Battle Machine is on Upgrade", $COLOR_INFO)
		$IsReaddy = True
	Else
		$IsReaddy = False
		SetDebugLog("Your Army is not prepared...", $COLOR_WARNING)
	EndIf
EndFunc   ;==>ArmyStatus

Func HeroStatus()
	If Not $g_bRunState Then Return
	Local $Status = "No Hero to use in Battle"
	If QuickMis("BC1", $g_sImgHeroStatusRec, 108, 355, 431, 459, True, False) Then ; DESRC Done
		$Status = "Battle Machine Recovering"
	EndIf
	If QuickMis("BC1", $g_sImgHeroStatusMachine, 108, 355, 431, 459, True, False) Then ; DESRC Done
		$Status = "Battle Machine ready to use"
	EndIf
	If QuickMis("BC1", $g_sImgHeroStatusUpg, 108, 355, 431, 459, True, False) Then ; DESRC Done
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

	If $i > 15 Then
		SetLog("Find Now! Button not available...", $COLOR_DEBUG)
		Return False
	EndIf

	SetDebugLog("Find Now! Button detected: " & $g_iMultiPixelOffSet[0] & "," & $g_iMultiPixelOffSet[1])
	Return True
EndFunc   ;==>FindVersusBattlebtn

Func WaitForVersusBattle()
	If Not $g_bRunState Then Return
	Local $aCancelVersusBattleBtn[4][3] = [[0xFE2D40, 1, 0], [0xFE2D40, 2, 0], [0xFE2D40, 3, 0], [0xFE2D40, 4, 0]]
	Local $aAttackerVersusBattle[2][3] = [[0xFFFF99, 0, 1], [0xFFFF99, 0, 2]]
	Local $bRed = False
	If _Sleep(5000) Then Return

	; Clouds
	Local $Time = 0
	While $Time < 15 * 24 ; 15 minutes  | ( 24 * (2000 + 500ms)) = 60000ms / 1000 = 60seconds
		If checkObstacles_Network(True, True) Then Return False
		If _MultiPixelSearch(375, 547, 450, 555, 1, 1, Hex(0xFE2D40, 6), $aCancelVersusBattleBtn, 15) <> 0 Then SetLog("Searching for opponents...")
		For $i = 0 To 5
			If _MultiPixelSearch(711, 2, 856, 55, 1, 1, Hex(0xFFFF99, 6), $aAttackerVersusBattle, 15) <> 0 And _MultiPixelSearch(375, 547, 450, 555, 1, 1, Hex(0xFE2D40, 6), $aCancelVersusBattleBtn, 5) = 0 Then
				SetLog("The Versus Battle begins NOW!", $COLOR_SUCCESS)
				If _Sleep(2000) Then ExitLoop
				Return True
			EndIf
			If _Sleep(2000) Then ExitLoop
		Next
		$Time += 1
	WEnd

	SetLog("Exit from battle search.", $COLOR_SUCCESS)
	ClickP($g_iMultiPixelOffSet, 2, 0)
	If _Sleep(3000) Then Return

	Return False

EndFunc   ;==>WaitForVersusBattle

Func BuilderBaseAttackToDrop($AvailableTroops)
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
	#comments-end

	If Not $g_bRunState Then Return
	If Not UBound($AvailableTroops) > 0 Then Return

	; Reset all variables
	BuilderBaseResetAttackVariables()

	Local $Troop = $AvailableTroops[0][0]
	Local $Slot = [$AvailableTroops[0][1], $AvailableTroops[0][2]]

	; Select the Troop
	ClickP($Slot, 1, 0)

	Setlog("Selected " & FullNametroops($Troop) & " to deploy.")

	If _Sleep(1000) Then Return

	Local $Size = GetBuilderBaseSize()

	If Not $g_bRunState Then Return

	Setlog("Builder Base Diamond: " & $Size)
	If ($Size < 575 And $Size > 620) Or $Size = 0 Then
		Setlog("Builder Base Attack Zoomout.")
		BuilderBaseZoomOut()
		If _Sleep(1000) Then Return
		$Size = GetBuilderBaseSize(False) ; WihtoutClicks
	EndIf

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

	If $i > 15 Then Setlog("Surrender button Problem!", $COLOR_WARNING)

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

Func BuilderBaseCSVAttack($AvailableTroops, $bDebug = False)
	; $AvailableTroops[$x][0] = Name , $AvailableTroops[$x][1] = X axis
	If Not $g_bRunState Then Return
	; Reset all variables
	BuilderBaseResetAttackVariables()
	; $AvailableTroops[$x][0] = Name , $AvailableTroops[$x][1] = X axis

	; maybe will be necessary to click on attack bar to release the zoomout pinch
	; x = 75 , y = 584
	Local $slotZero[2] = [102, 684] ; DESRC DONE
	ClickP($slotZero, 1, 0)

	; [0] - TopLeft ,[1] - TopRight , [2] - BottomRight , [3] - BottomLeft
	Local $FurtherFrom = 5 ; 5 pixels before the deploy point
	BuilderBaseGetDeployPoints($FurtherFrom, $bDebug)
	If Not $g_bRunState Then Return
	; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window
	BuilderBaseParseAttackCSV($AvailableTroops, $g_aDeployPoints, $g_aDeployBestPoints, $bDebug)

EndFunc   ;==>BuilderBaseCSVAttack

Func BuilderBaseAttackReport()
	; Verify the Window Report , Point[0] Archer Shadow Black Zone [155,460,000000], Point[1] Ok Green Button [430,590, 6DBC1F]
	Local $SurrenderBtn = [76, 584] ; DESRC Done
	Local $OKbtn = [435, 562] ; DESRC Done ;auxiliar click

	For $i = 0 To 60
		If Not $g_bRunState Then Return
		TriggerMachineAbility()
		Local $Damage = Number(getOcrOverAllDamage(780, 527 + 88)) ; DESRC Done
		If Int($Damage) > Int($g_iLastDamage) Then
			$g_iLastDamage = Int($Damage)
			Setlog("Total Damage: " & $g_iLastDamage & "%")
		EndIf
		If Not _ColorCheck(_GetPixelColor($SurrenderBtn[0], $SurrenderBtn[1], True), Hex(0xFE5D65, 6), 10) Then ExitLoop
		If $i = 60 Then Setlog("Window Report Problem!", $COLOR_WARNING)
		If _Sleep(2000) Then Return
	Next

	;If checkObstacles(True) Then
	;	SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
	;	Return
	;EndIf

	Local $Stars = 0
	Local $StarsPositions[3][2] = [[326, 394], [452, 388], [546, 413]] ; des RC Done ?
	Local $Color[3] = [0xD0D4D0, 0xDBDEDB, 0xDBDDD8]

	If _Sleep(1500) Then Return
	If Not $g_bRunState Then Return

	For $i = 0 To UBound($StarsPositions) - 1
		If _ColorCheck(_GetPixelColor($StarsPositions[$i][0], $StarsPositions[$i][1], True), Hex($Color[$i], 6), 30) Then $Stars += 1
	Next

	Setlog("Your Attack: " & $Stars & " Star(s)!", $COLOR_INFO)

	If _Sleep(1500) Then Return

	Local $iSpecialColor[4][3] = [[0xBEE758, 0, 1], [0xA9DD49, 0, 2], [0x7BC726, 0, 3], [0x79C426, 0, 4]]
	Local $iSpecialPixel

	For $i = 0 To 15
		$iSpecialPixel = _MultiPixelSearch(345, 540, 510, 612, 1, 1, Hex(0xBFE85A, 6), $iSpecialColor, 20)
		If IsArray($iSpecialPixel) Then ExitLoop
	Next

	If $i > 15 Then
		Return False
	Else
		SetLog("Return To Home.", $Color_Info)
		ClickP($g_iMultiPixelOffSet, 1, 0)
	EndIf

	Local $ResultName = ""

	For $i = 0 To 12 ; 120 seconds
		If Not $g_bRunState Then Return
		; Wait
		If _Sleep(5000) Then Return ; 5seconds
		If QuickMIS("BC1", $g_sImgReportWaitBB, 538, 326, 647, 378, True, False) Then ; DESRC Done
			Setlog("...Opponent is Attacking!", $COLOR_INFO)
			If _Sleep(5000) Then Return ; 5seconds
			ContinueLoop
		EndIf
		If QuickMIS("BC1", $g_sImgReportFinishedBB, 538, 320, 648, 366, True, False) Then  ; DESRC Done
			If _Sleep(1000) Then Return
			Local $aResults = QuickMIS("NxCx", $g_sImgReportResultBB, 534, 164, 730, 223, True, False) ; DESRC Done
			; Name $aResults[0][0]
			If $aResults = 0 Then
				Setlog("Attack Result Problem!!", $COLOR_WARNING)
				ExitLoop
			EndIf
			Setlog("Attack Result: " & $aResults[0][0], $COLOR_SUCCESS)
			$ResultName = $aResults[0][0]
			ExitLoop
		EndIf
	Next

	If checkObstacles(True) Then
		SetLog("Window clean required, but no problem for MyBot!", $COLOR_INFO)
		Return
	EndIf

	; Small delay just to getout the slide resources to top left
	If _sleep(5000) Then Return

	; Get the LOOT :
	Local $gain[3]
	; To get trophies getOcrOverAllDamage(493, 480 + $g_iMidOffsetYNew)
	$gain[$eLootTrophyBB] = Int(getOcrOverAllDamage(493, 480))
	$gain[$eLootGoldBB] = Int(getTrophyVillageSearch(150, 483))
	$gain[$eLootElixirBB] = Int(getTrophyVillageSearch(310, 483))
	Local $iLastDamage = Int(_getTroopCountBig(222, 304))
	If $iLastDamage > $g_iLastDamage Then $g_iLastDamage = $iLastDamage

	If StringInStr($ResultName, "Victory") > 0 Then
		$gain[$eLootTrophyBB] = Abs($gain[$eLootTrophyBB])
	ElseIf StringInStr($ResultName, "Defeat") > 0 Then
		$gain[$eLootTrophyBB] = $gain[$eLootTrophyBB] * -1
	Else
		$gain[$eLootTrophyBB] = 0
	EndIf

	; #######################################################################
	; Just a temp log for BB attacks , this needs a new TAB like a stats tab
	Local $AtkLogTxt
	$AtkLogTxt = "  " & String($g_iCurAccount + 1) & "|" & _NowTime(4) & "|"
	$AtkLogTxt &= StringFormat("%5d", $g_aiCurrentLootBB[$eLootTrophyBB]) & "|"
	$AtkLogTxt &= StringFormat("%7d", $gain[$eLootGoldBB]) & "|"
	$AtkLogTxt &= StringFormat("%7d", $gain[$eLootElixirBB]) & "|"
	$AtkLogTxt &= StringFormat("%3d", $gain[$eLootTrophyBB]) & "|"
	$AtkLogTxt &= StringFormat("%1d", $Stars) & "|"
	$AtkLogTxt &= StringFormat("%3d", $g_iLastDamage) & "|"
	$AtkLogTxt &= StringFormat("%1d", $g_iBuilderBaseScript + 1) & "|"

	If StringInStr($ResultName, "Victory") > 0 Then
		SetBBAtkLog($AtkLogTxt, "", $COLOR_GREEN)
	ElseIf StringInStr($ResultName, "Defeat") > 0 Then
		SetBBAtkLog($AtkLogTxt, "", $COLOR_ERROR)
	Else
		SetBBAtkLog($AtkLogTxt, "", $COLOR_INFO)
	EndIf
	; #######################################################################

	; Return to Main Page
	ClickP($aAway, 2, 0, "#0332") ;Click Away

	If _sleep(2000) Then Return
EndFunc   ;==>BuilderBaseAttackReport

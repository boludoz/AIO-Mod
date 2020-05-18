; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttackBB
; Description ...: This file controls attacking preperation of the builders base
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom BB - Team AIO Mod++ ; Thx Chilly-Chill by you hard work.
Func AttackBB()
	Local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	Local $aBMPos = 0

	Local $Size = GetBuilderBaseSize()
	
	If Not $g_bRunState Then Return

	Setlog("Builder Base Diamond: " & $Size)
	If ($Size < 575 And $Size > 620) Or $Size = 0 Then
		Setlog("Builder Base Attack Zoomout.")
		BuilderBaseZoomOut()
		If _Sleep(1000) Then Return
		$Size = GetBuilderBaseSize(False) ; WihtoutClicks
	EndIf

	$g_aBuilderBaseDiamond = BuilderBaseAttackDiamond()
	$g_aExternalEdges = BuilderBaseGetEdges($g_aBuilderBaseDiamond, "External Edges")
	
	Local $aVar = $g_aExternalEdges[0]


	Local $iAndroidSuspendModeFlagsLast = $g_iAndroidSuspendModeFlags
	$g_iAndroidSuspendModeFlags = 0 ; disable suspend and resume
	If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Disabled")

	; Get troops on attack bar and their quantities
	Local $aBBAttackBar = MachineKick(GetAttackBarBB(False))
	If _Sleep($DELAYRESPOND) Then
		$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
		If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
		Return
	EndIf
	
	; Deploy all troops
	Local $bTroopsDropped = False
	SetLog($g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	While Not $bTroopsDropped
		Local $iNumSlots = UBound($aBBAttackBar, 1)
		If $g_bBBDropOrderSet = True Then
			;		Local $asBBDropOrder = StringSplit($g_sBBDropOrder, "|") ; Custom BB Army - Team AIO Mod++
			For $i = 0 To UBound($g_ahCmbBBDropOrder) - 1 ; loop through each name in the drop order
				Local $j = 0, $bDone = 0
				While $j < $iNumSlots And Not $bDone
					;If $aBBAttackBar[$j][0] = $asBBDropOrder[$i+1] Then; Custom BB Army - Team AIO Mod++
					If $aBBAttackBar[$j][0] = $g_asAttackBarBB[Number($g_aiCmbBBDropOrder[$i]) + 1] Then ; Custom BB Army - Team AIO Mod++
						;DeployBBTroop($aBBAttackBar[$j][0], $aBBAttackBar[$j][1], $aBBAttackBar[$j][2], $aBBAttackBar[$j][4], $iSide)
						SetLog("Deploying " & $aBBAttackBar[$j][0] & "x" & String($aBBAttackBar[$j][4]), $COLOR_ACTION)
						PureClick($aBBAttackBar[$j][1], $aBBAttackBar[$j][2]) ; select troop
						If $aBBAttackBar[$j][4] <> 0 Then
							For $iAmount = 0 To $aBBAttackBar[$j][4]
								Local $vDP = Random(0, UBound($aVar))
								PureClick($aVar[$vDP][0], $aVar[$vDP][1])
								If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down selecting then dropping troops
							Next
						EndIf
						;---------------------------
						If $j = $iNumSlots - 1 Or $aBBAttackBar[$j][0] <> $aBBAttackBar[$j + 1][0] Then
							$bDone = True
							If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
								$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
								If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
								Return
							EndIf
						EndIf
					EndIf
					$j += 1
				WEnd
			Next
		Else
			For $i = 0 To $iNumSlots - 1
				;DeployBBTroop($aBBAttackBar[$i][0], $aBBAttackBar[$i][1], $aBBAttackBar[$i][2], $aBBAttackBar[$i][4], $iSide)
				SetLog("Deploying " & $aBBAttackBar[$i][0] & "x" & String($aBBAttackBar[$i][4]), $COLOR_ACTION)
				PureClick($aBBAttackBar[$i][1], $aBBAttackBar[$i][2]) ; select troop
				If $aBBAttackBar[$j][4] <> 0 Then
					For $iAmount = 0 To $aBBAttackBar[$8][4]
						Local $vDP = Random(0, UBound($aVar))
						PureClick($aVar[$vDP][0], $aVar[$vDP][1])
						If _Sleep($g_iBBSameTroopDelay) Then Return ; slow down selecting then dropping troops
					Next
				EndIf
				;---------------------------
				If $i = $iNumSlots - 1 Or $aBBAttackBar[$i][0] <> $aBBAttackBar[$i + 1][0] Then
					If _Sleep($g_iBBNextTroopDelay) Then ; wait before next troop
						$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				Else
					If _Sleep($DELAYRESPOND) Then ; we are still on same troop so lets drop them all down a bit faster
						$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				EndIf
			Next
		EndIf
		$aBBAttackBar = MachineKick(GetAttackBarBB(True))
		If Not IsArray($aBBAttackBar) Then $bTroopsDropped = True
	WEnd
	SetLog("All Troops Deployed", $COLOR_SUCCESS)

	; place hero and activate ability
	If $g_bBBMachineReady Then SetLog("Deploying Battle Machine.", $COLOR_BLUE)
	
	If $g_bBBMachineReady Then
		If IsArray($g_aMachineBB) Then
			PureClick($g_aMachineBB[0][1], $g_aMachineBB[0][2])
			Local $vDP = Random(0, UBound($aVar))
			PureClick($aVar[$vDP][0], $aVar[$vDP][1])
			If _Sleep(500) Then     ; wait before clicking ability
				$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast
				If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
				Return
			EndIf
			
			If $g_bIsBBMachineD = False Then $g_bIsBBMachineD = True
		EndIf
	EndIf

	$g_iAndroidSuspendModeFlags = $iAndroidSuspendModeFlagsLast ; reset android suspend and resume stuff
	If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
EndFunc   ;==>AttackBB
#EndRegion - Custom BB - Team AIO Mod++ ; Thx Chilly-Chill by you hard work.



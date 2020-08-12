; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseCSV
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseCSV()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood, Team AIO Mod++ ! (2018-2020), Dissociable (08-2020)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

; PARSE CSV FILE
Func TestBuilderBaseParseAttackCSV()
	Setlog("** TestBuilderBaseParseAttackCSV START**", $COLOR_DEBUG)
	Local $bStatus = $g_bRunState
	$g_bRunState = True

	Local $bTempDebug = $g_bDOCRDebugImages
	$g_bDOCRDebugImages = True

	BuilderBaseResetAttackVariables()

	; Attack Bar | [0] = Troops Name , [1] = X-axis , [2] - Quantities
	;Local $aAvailableTroops = BuilderBaseAttackBar()
	Local $aAvailableTroops = GetAttackBarBB()

	If IsArray($aAvailableTroops) Then

		; Zoomout the Opponent Village.
		BuilderBaseZoomOut()
		
		; Correct script.
		BuilderBaseSelectCorrectScript($aAvailableTroops)
		
		Local $FurtherFrom = 5 ; 5 pixels before the deploy point.
		BuilderBaseGetDeployPoints($FurtherFrom, True)

		; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window.
		BuilderBaseParseAttackCSV($aAvailableTroops, $g_aDeployPoints, $g_aDeployBestPoints, True)

		; Attack Report Window.
		BuilderBaseAttackReport()

	EndIf

	$g_bDOCRDebugImages = $bTempDebug
	$g_bRunState = $bStatus

	Setlog("** TestBuilderBaseParseAttackCSV END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseParseAttackCSV

; Main Function
Func BuilderBaseParseAttackCSV($aAvailableTroops, $DeployPoints, $DeployBestPoints, $bDebug = False)

	; Reset Stats
	$g_iLastDamage = 0

	Local $FileNamePath = @ScriptDir & "\CSV\BuilderBase\" & $g_sAttackScrScriptNameBB[$g_iBuilderBaseScript] & ".csv"
	; Columm Names
	Local $aIMGLtxt = ["Air Defenses", "Crusher", "Guard Post", "Big Cannon", "Builder Hall"]
	Local $bDefenses = [$g_aAirdefensesPos, $g_aCrusherPos, $g_aGuardPostPos, $g_aCannonPos, $g_aBuilderHallPos]
	Local $aIMGL = [False, False, False, False, False]
	Local $aDROP = ["CMD", "QTY", "TROOPNAME__", "DROP_POINTS_", "ADDTILES_", "DROP_SIDE", "SLEEPAFTER_", "OBS"]
	Local $sFrontSide = ""
	Local $aSplitLine, $command

	; [x][0] = Troops Name , [x][1] = X-axis , [x][2] - Y-Axis [x][3] - Slot starting at 0, [x][4] - Quantity
	Local $aAvailableTroops_NXQ = $aAvailableTroops

	; [0] - TopLeft ,[1] - TopRight , [2] - BottomRight , [3] - BottomLeft
	Local $aDeployBestPoints = $DeployBestPoints ;Best Filtered 10 Points
	Local $aDeployPoints = $DeployPoints ; Non Filterd Deploy Points

	If FileExists($FileNamePath) Then
		Local $aLines = FileReadToArray($FileNamePath)
		If @error Then Setlog("There was an error reading the CSV file. @error: " & @error, $COLOR_WARNING)

		Local $Line = "", $BuildingSide = ""

		; Loop for every line on CSV
		For $iLine = 0 To UBound($aLines) - 1
			If Not $g_bRunState Then Return
			$Line = $aLines[$iLine]
			SetDebugLog("[" & $iLine & "] " & $Line)
			; Split the Line , delimiter "|"
			$aSplitLine = StringSplit($Line, "|", $STR_NOCOUNT)
			If UBound($aSplitLine) < 5 Then ContinueLoop
			; Remove all spaces and converts a string to uppercase
			$command = StringStripWS(StringUpper($aSplitLine[0]), $STR_STRIPALL)

			If $command = "NOTE" Or $command = "GUIDE" Then ContinueLoop
			SetDebugLog("[CMD]: " & $command)
			Switch $command
				Case "IMGL"
					For $i = 4 To 0 Step -1
						$command = Int(StringStripWS($aSplitLine[$i + 1], $STR_STRIPALL))
						If $command = 1 Then
							; Remember the Buildings Arrays is :  [0] = name , [1] = Xaxis , [1] = Yaxis
							Switch $i
								Case 0
									$g_aAirdefensesPos = BuilderBaseBuildingsDetection(0)
									Setlog("Detected Air defenses: " & UBound($g_aAirdefensesPos), $COLOR_INFO)
									ExitLoop
								Case 1
									$g_aCrusherPos = BuilderBaseBuildingsDetection(1)
									Setlog("Detected Crusher: " & UBound($g_aCrusherPos), $COLOR_INFO)
									ExitLoop
								Case 2
									$g_aGuardPostPos = BuilderBaseBuildingsDetection(2)
									Setlog("Detected GuardPost: " & UBound($g_aGuardPostPos), $COLOR_INFO)
									ExitLoop
								Case 3
									$g_aCannonPos = BuilderBaseBuildingsDetection(3)
									Setlog("Detected Cannon: " & UBound($g_aCannonPos), $COLOR_INFO)
									ExitLoop
								Case 4
									; Is not necessary to get again if was detected when deploy point detection ran
									If Not IsArray($g_aBuilderHallPos) Then $g_aBuilderHallPos = BuilderBaseBuildingsDetection(4)
							EndSwitch
						EndIf
					Next

					; Main Side to attack
					If $sFrontSide = "" Then
						$sFrontSide = BuilderBaseAttackMainSide()
						Setlog("Detected Front Side: " & $sFrontSide, $COLOR_INFO)
					EndIf
				Case "FORC"
					; Main Side to attack If necessary
					If UBound($aIMGL) = UBound($aSplitLine) - 1 Then
						; Just 4 : Global Enum $g_iAirDefense = 0 , $g_iCrusher, $g_iGuardPost, $g_iCannon
						For $i = 0 To 4
							$command = Int(StringStripWS($aSplitLine[$i + 1], $STR_STRIPALL))
							If $command = 1 Then
								; Get the Array inside the array $bDefenses
								Local $BuildPositionArray = $bDefenses[$i - 1]
								; Let get the First building detected
								; Remember the Buildings Arrays is :  [0] = name , [1] = Xaxis , [1] = Yaxis
								Local $BuildPosition = [$BuildPositionArray[0][1], $BuildPositionArray[0][2]]
								; Get in string the FORCED Side name
								If $sFrontSide = "" Then
									$sFrontSide = DeployPointsPosition($BuildPosition, ($i = 4))
									Setlog("Forced Front Side: " & $sFrontSide, $COLOR_INFO)
								EndIf
							EndIf
						Next
					EndIf
				Case "DROP"
					; passing all values to $aDrop from $aSplitLine
					For $i = 1 To 6
						$aDROP[$i] = StringStripWS($aSplitLine[$i], $STR_STRIPALL)
					Next

					; TROOPNAME__: [ "Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "Machine" ]
					; $aDROP[2]
					Local $sTroopName = $aDROP[2]

					; DROP_SIDE: FRONT - BACK - LEFT - RIGHT (red lines)| FRONTE - BACKE - LEFTE - RIGHTE (external edges )
					; DROP_SIDE: BH - Builder Hall side will attack Only if exposed
					; DROP_SIDE: EDGEB - Will detect if exist Buildings on Corners_SIDE: FRONT - BACK - LEFT - RIGHT - BH - EDGEB
					; $aDROP[5]
					Local $sDropSide = StringUpper($aDROP[5])
					; Qty
					; $aDROP[1]
					Local $sQty = StringUpper($aDROP[1])
					If $sQty = "ALL" Then ; All command will act like remain it will get attack bar troops.
						; $aAvailableTroops_NXQ  [Name][Xaxis][Quantities]
						For $i = 0 To UBound($aAvailableTroops_NXQ) - 1
							If (StringInStr($aAvailableTroops_NXQ[$i][0], $sTroopName) > 0) Then ;We Just Need To redo the ocr for mentioned troop only
								If (StringInStr($sTroopName, "Machine") > 0) Then
									$aAvailableTroops_NXQ[$i][4] = 1
								Else
									$aAvailableTroops_NXQ[$i][4] = Number(_getTroopCountSmall(Number($aAvailableTroops_NXQ[$i][1]), 640))
									If $aAvailableTroops_NXQ[$i][4] < 1 Then $aAvailableTroops_NXQ[$i][4] = Number(_getTroopCountBig(Number($aAvailableTroops_NXQ[$i][1]), 640 - 7)) ; For Big numbers when the troop is selected
								EndIf
							EndIf
						Next

						If $sDropSide = "FRONT" Or $sDropSide = "BACK" Or $sDropSide = "LEFT" Or $sDropSide = "RIGHT" Or $sDropSide = "BH" Then ; Use external edges Point
							$sDropSide = $sDropSide & "E"
						Else ;If BH Or EDGEB defined For All Command Change It to FRONTE because there is chance that they are problamtic
							$sDropSide = "FRONTE"
						EndIf
					EndIf
					
					; Gets Verify Quantities on Slot and what is necessary
					Local $iTotalQtyByTroop = 0
					For $i = 0 To UBound($aAvailableTroops_NXQ) - 1
						If StringInStr($aAvailableTroops_NXQ[$i][0], $sTroopName) <> 0 Then
							$iTotalQtyByTroop += $aAvailableTroops_NXQ[$i][4]
						EndIf
					Next
					Local $iQtyToDrop = $sQty = "ALL" ? $iTotalQtyByTroop : Int($sQty)

					; DROP_POINTS_: Can Be Defined Like e.g Single Drop Point(5),Multi Drop Point(2,4,6),Multi Start To End(2-6)
					; Each side will have 10 points 1-10 , the 5 is the Middle , 0 = closest to BuilderHall
					; $aDROP[3]
					Local $sDropPoints = $aDROP[3]

					; ADDTILES_: Is the distance from the red line. 1 Default Do Nothing - e.g (2) Means ADD 2 tile to drop point
					; $aDROP[4]
					Local $iAddTiles = Int($aDROP[4])
					If $sDropSide = "FRONTE" Or $sDropSide = "BACKE" Or $sDropSide = "LEFTE" Or $sDropSide = "RIGHTE" Then ; If external edges Point Selected Then No need to add tiles as drop point is already end of village
						$iAddTiles = 1
					EndIf

					; SLEEPAFTER_: Sleep after in ms
					; $aDROP[6]
					Local $SleepAfter = 250
					If StringInStr($aDROP[6], "-") > 0 Then
						Local $aRand = StringSplit($aDROP[6], "-", $STR_NOCOUNT)
						$SleepAfter = Random(Int($aRand[0]), Int($aRand[1]), 1)
						Else
						$SleepAfter = Int($aDROP[6])
					EndIf
					
					SetDebugLog("$iQtyToDrop : " & $iQtyToDrop & ", $sQty : " & $sQty & ", $sTroopName : " & $sTroopName & ", $aSelectedDropSidePoints_XY : " & $sDropPoints & ", $iAddTiles : " & $iAddTiles & ", $sDropSide : " & $sDropSide & ", $SleepAfter : " & $SleepAfter)

					Local $iQtyOfSelectedSlot = 0 ; Quantities on current slot
					Local $iSlotNumber = 20 ; just an impossible slot to initialize it
					Local $aSlot_XY = [0, 0]

					; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot And $iSlotNumber
					If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then
						TriggerMachineAbility() ;Click On Ability Before Skipping The Loop
						ContinueLoop
					EndIf
					Switch $sDropSide
						Case "BH", "BHE"
							If IsArray($g_aBuilderHallPos) Then
								Local $BHposition = [$g_aBuilderHallPos[0][1], $g_aBuilderHallPos[0][2]]
								; Get/Check if the distance from any deploy point is less than 75px
								Local $aPoints = GetThePointNearBH($BHposition, $aDeployPoints, $sDropSide), $aPoints2Deploy[2] = ["", ""]
								For $i = 0 To UBound($aPoints) -1
									$aPoints2Deploy[0] = $aPoints[$i][0]
									$aPoints2Deploy[1] = $aPoints[$i][1]
									If $aPoints2Deploy[0] <> "" Then
										For $i = 0 To $iQtyToDrop - 1
											DeployTroopBB($sTroopName, $aSlot_XY, $aPoints2Deploy, 1)
											$iQtyOfSelectedSlot -= 1
											$iTotalQtyByTroop -= 1
											; Remove the Qty from the Original array :
											$aAvailableTroops_NXQ[$iSlotNumber][4] = $iQtyOfSelectedSlot
											; If is the Machine exist and deployed
											; If IsMachineDepoloyed() Then ExitLoop 2
											If IsArray($g_aMachineBB) And UBound($g_aMachineBB) > 2 And $g_aMachineBB[2] Then ExitLoop 2 
											If $iTotalQtyByTroop < 1 Then ExitLoop 2
											; Let's select another slot if this slot is empty
											If $iQtyOfSelectedSlot < 1 Then
												; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot and $iSlotNumber
												If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then ExitLoop 2
											EndIf
											; Just a small Delay to Pause Function
											If RandomSleep(100) Then Return
											
											ContinueLoop 2
										Next
									EndIf
								Next
							EndIf
						Case "EDGEB"
							; Detect all coordinates return an Array[X][3] Index 3 Contains Edge Side Name
							Local $aSelectedEdgePoints_XYS = BuilderBaseBuildingsOnEdge($aDeployPoints)
							If $aSelectedEdgePoints_XYS = "-1" Then ContinueLoop

							DebugPrintDropPoint($aSelectedEdgePoints_XYS, "Edge", $bDebug)

							;AddTilesToEdgePoint($aSelectedEdgePoints_XYS, $iAddTiles, $bDebug); No Need Use Add Tiles Logic As Edge Using Outer Points Already

							; On CSV is the quantities BY edge
							$iQtyToDrop = (UBound($aSelectedEdgePoints_XYS) > 0) ? ($iQtyToDrop * UBound($aSelectedEdgePoints_XYS)) : ($iQtyToDrop)

							Local $iTroopsDropped = 0
							While $iTroopsDropped < $iQtyToDrop
								If Not $g_bRunState Then Return
								For $i = 0 To UBound($aSelectedEdgePoints_XYS) - 1
									If ($iTroopsDropped < $iQtyToDrop Or $sQty = "ALL") Then ; Check That Drop Troops Don't Get Exceeded By CSV DROP Quantity OR Drop all troops if Qunanity is ALL
										; get one Deploy point
										Local $Point2Deploy = [$aSelectedEdgePoints_XYS[$i][0], $aSelectedEdgePoints_XYS[$i][1]]
										DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, 1)
										; Increment Troops Dropped
										$iTroopsDropped += 1
										; removing the deployed troop
										$iQtyOfSelectedSlot -= 1
										$iTotalQtyByTroop -= 1
										; Remove the Qty from the Original array :
										$aAvailableTroops_NXQ[$iSlotNumber][4] = $iQtyOfSelectedSlot
										; If is the Machine exist and deployed
										; If IsMachineDepoloyed($sTroopName, $iSlotNumber, $bIfMachineWasDeployed, $bIfMachineHasAbility, $g_aMachineBB) Then ExitLoop (2)
										If IsArray($g_aMachineBB) And UBound($g_aMachineBB) > 2 And $g_aMachineBB[2] Then ExitLoop (2)

										If $iTotalQtyByTroop < 1 Then ExitLoop (2)
										; Let's select another slot if this slot is empty
										If $iQtyOfSelectedSlot < 1 Then
											; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot and $iSlotNumber
											If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then ExitLoop (2)
										EndIf
										; Just a small Delay to Pause Function
										If _Sleep(100) Then Return
									Else
										ExitLoop (2)
									EndIf
								Next
							WEnd
						Case Else
							Local $sSelectedDropSideName ;Using For AddTile That Which Side Was Choosed To Attack
							; Correct FRONT - BACK - LEFT - RIGHT - BH - EDGEB
							Local $aSelectedDropSidePoints_XY = CorrectDropPoints($sFrontSide, $sDropSide, $aDeployBestPoints, $sSelectedDropSideName)
							_ArrayShuffle($aSelectedDropSidePoints_XY)
							; Just in Case
							If UBound($aSelectedDropSidePoints_XY) = 0 Then
								TriggerMachineAbility()
								ContinueLoop
							EndIf
	
							DebugPrintDropPoint($aSelectedDropSidePoints_XY, "Original", $bDebug)
	
							; Before Parsing Points Do Add Tiles Distance if defined
							AddTilesToDeployPoint($aSelectedDropSidePoints_XY, $iAddTiles, $sSelectedDropSideName, $bDebug)
	
							If $bDebug And $iAddTiles > 1 Then DebugBuilderBaseBuildingsDetection($aDeployPoints, $aDeployBestPoints, "CSVAddTile_" & $iAddTiles, $aSelectedDropSidePoints_XY, True) ;Take ScreenShot After AddTile For Debug
							;Get Points which is mentioned in CSV
							Local $aCSVParsedDeployPoint_XY = ParseCSVDropPoints($sDropPoints, $aSelectedDropSidePoints_XY, $bDebug)
							; Just in Case
							If UBound($aCSVParsedDeployPoint_XY) = 0 Then
								TriggerMachineAbility()
								ContinueLoop
							EndIf
	
							DebugPrintDropPoint($aCSVParsedDeployPoint_XY, "CSV Selected", $bDebug)
	
							; Deploy Troops
							Local $iTroopsDropped = 0
							While $iTroopsDropped < $iQtyToDrop
								For $i = 0 To UBound($aCSVParsedDeployPoint_XY) - 1
									If Not $g_bRunState Then Return
									If ($iTroopsDropped < $iQtyToDrop Or $sQty = "ALL") Then ; Check That Drop Troops Don't Get Exceeded By CSV DROP Quantity OR Drop all troops if Qunanity is ALL
										; get one Deploy point
										Local $Point2Deploy = $aCSVParsedDeployPoint_XY[$i]
										DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, 1)
										; Increment Troops Dropped
										$iTroopsDropped += 1
										; removing the deployed troop
										$iQtyOfSelectedSlot -= 1
										$iTotalQtyByTroop -= 1
										; Remove the Qty from the Original array :
										$aAvailableTroops_NXQ[$iSlotNumber][4] = $iQtyOfSelectedSlot
										; If is the Machine exist and depolyed
										If IsArray($g_aMachineBB) And UBound($g_aMachineBB) > 2 And $g_aMachineBB[2] Then ExitLoop (2)
										; Just in case
										If $iTotalQtyByTroop < 1 Then ExitLoop (2)
										; Let's select another slot if this slot is empty
										If $iQtyOfSelectedSlot < 1 Then
											; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot and $iSlotNumber
											If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then ExitLoop (2)
										EndIf
										; Just a small Delay to Pause Function
										If _Sleep(100) Then Return
									Else
										ExitLoop (2)
									EndIf
								Next
							WEnd

					EndSwitch

					; A log user
					SetLog(" - " & $aAvailableTroops_NXQ[$iSlotNumber][4] & "x/" & $iTotalQtyByTroop & "x " & FullNametroops($aAvailableTroops_NXQ[$iSlotNumber][0]) & " at slot " & $iSlotNumber + 1, $COLOR_WARNING)

			EndSwitch
		Next

		; Machine Ability and Battle
		Local $aBlackArts[4] = [520, 600, 0x000000, 5]
		For $i = 0 To Int($SleepAfter / 50)
			; Machine Ability
			TriggerMachineAbility()
			If _Sleep(50) Then Return
			
			If _CheckPixel($aBlackArts, True) Then
				If _WaitForCheckImg($g_sImgOkButton, "345, 540, 524, 615") Then
					SetDebugLog("BattleIsOver | $bIsEnded.")
					ExitLoop
				EndIf
			EndIf

		Next

		; Let's Assume That Our CSV Was Bad That None Of The Troops Was Deployed Let's Deploy Everything
		; Let's make a Remain Just In Case deploy points problem somewhere in red zone OR Troop was not mentioned in CSV OR Hero Was not dropped. Let's drop All
		Local $aAvailableTroops_NXQ = GetAttackBarBB()

		If $aAvailableTroops_NXQ <> -1 And IsArray($aAvailableTroops_NXQ) Then
			SetLog("CSV Does not deploy some of the troops. So Now just dropping troops in a waves", $COLOR_INFO)
			AttackBB($aAvailableTroops_NXQ)
		EndIf
		
	Else
		SetLog($FileNamePath & " Doesn't exist!", $COLOR_WARNING)
	EndIf
EndFunc   ;==>BuilderBaseParseAttackCSV


; Extra Methods
Func DebugPrintDropPoint($DropPoint, $Text, $bDebug)
	If $bDebug Then
		SetLog($Text & " Total Deploy Point: " & UBound($DropPoint))
		For $i = 0 To UBound($DropPoint) - 1
			If (UBound($DropPoint, 2) > 0) Then ;Check If 2D Array
				SetDebugLog($Text & "  Deploy Point: " & $i + 1 & " - " & $DropPoint[$i][0] & " x " & $DropPoint[$i][1])
			Else
				Local $Point = $DropPoint[$i]
				SetDebugLog($Text & "  Deploy Point: " & $i + 1 & " - " & $Point[0] & " x " & $Point[1])
			EndIf
		Next
	EndIf
EndFunc   ;==>DebugPrintDropPoint

Func CorrectDropPoints($FrontSide, $sDropSide, $aDeployBestPoints, ByRef $sSelectedDropSideName)
	Enum $TL = 0, $TR, $BR, $BL
	Local $Front = 0
	Local $sSideNames[4] = ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]
	Local $ToReturn

	; FRONT - BACK - LEFT - RIGHT
	For $i = 0 To UBound($sSideNames) - 1
		If $FrontSide = $sSideNames[$i] Then $Front = $i
	Next

	Local $DimToReturn = 0

	Switch $sDropSide
		Case "FRONT"
			$DimToReturn = $Front
		Case "FRONTE"
			$DimToReturn = $Front
		Case "BACK"
			$DimToReturn = ($Front + 2 > 3) ? Abs(($Front + 2) - 4) : $Front + 2
		Case "BACKE"
			$DimToReturn = ($Front + 2 > 3) ? Abs(($Front + 2) - 4) : $Front + 2
		Case "LEFT"
			$DimToReturn = ($Front + 1 > 3) ? Abs(($Front + 1) - 4) : $Front + 1
		Case "LEFTE"
			$DimToReturn = ($Front + 1 > 3) ? Abs(($Front + 1) - 4) : $Front + 1
		Case "RIGHT"
			$DimToReturn = ($Front - 1 < 0) ? 4 - Abs($Front - 1) : $Front - 1
		Case "RIGHTE"
			$DimToReturn = ($Front - 1 < 0) ? 4 - Abs($Front - 1) : $Front - 1
		Case Else ;Incase of Wrong CSV Side Just Return To avoid crash
			SetLog("CSV DropSide Command '" & $sDropSide & "' Not Supported.", $COLOR_ERROR)
			Return
	EndSwitch

	$sSelectedDropSideName = $sSideNames[$DimToReturn] ;Save Choosed Site

	If ($sDropSide = "FRONTE" Or $sDropSide = "BACKE" Or $sDropSide = "LEFTE" Or $sDropSide = "RIGHTE") And IsArray($g_aFinalOuter) And $DimToReturn < UBound($g_aFinalOuter) Then
		$ToReturn = FindBestDropPoints($g_aFinalOuter[$DimToReturn], 10)
	Else
		If IsArray($aDeployBestPoints) And $DimToReturn < UBound($aDeployBestPoints) Then
			$ToReturn = $aDeployBestPoints[$DimToReturn]
		ElseIf IsArray($g_aFinalOuter) And $DimToReturn < UBound($g_aFinalOuter) Then ; In Worst Case Senerio If Depoly Points Was Not detected then use outer points.
			$ToReturn = FindBestDropPoints($g_aFinalOuter[$DimToReturn], 10)
		EndIf
	EndIf

	SetDebugLog("Main Side is " & $FrontSide & " - Drop on " & $sDropSide & " correct side will be " & $sSideNames[$DimToReturn])
	Return $ToReturn
EndFunc   ;==>CorrectDropPoints

Func ParseCSVDropPoints($sDropPoints, $aSelectedDropSidePoints_XY, $bDebug)
	Local $aCSVParsedDeployPoint_XY[0], $atempDeploy[2]
	Local $indexStart = 1, $indexEnd = 1, $indexArray = 0, $indexVect = 0
	;Temp Solution As For time bing using max Drop points which was detected only
	;TODO: Will Calculate More Points If less points detected
	Local $iMaxDropPoints = UBound($aSelectedDropSidePoints_XY)

	If StringInStr($sDropPoints, "-") > 0 Then ;Multi Start To End(2-6) 1-8
		$indexVect = StringSplit($sDropPoints, "-", 2)
		$indexArray = 0
		If UBound($indexVect) > 1 Then
			If Not $g_bRunState Then Return
			If Int($indexVect[0]) > 0 And Int($indexVect[1]) > 0 Then
				$indexStart = Int($indexVect[0])
				$indexEnd = Int($indexVect[1])
				If $indexStart > $indexEnd Then ;E.g someone wrote 4-2 shuffle them make 2-4
					$indexStart = Int($indexVect[1])
					$indexEnd = Int($indexVect[0])
				EndIf
				If $indexStart > $iMaxDropPoints Then $indexStart = 1
				If $indexEnd > $iMaxDropPoints Then $indexEnd = $iMaxDropPoints
				If $bDebug Then SetLog("Multi Point (" & $sDropPoints & ") , $indexStart : " & $indexStart & " , $indexEnd : " & $indexEnd)
			Else
				$indexVect = 0
			EndIf
		Else
			$indexVect = 0
		EndIf
	ElseIf StringInStr($sDropPoints, ",") > 0 Then ;Multi Drop Point(2,4,6)
		$indexArray = StringSplit($sDropPoints, ",", 2)
		$indexVect = 0
		If UBound($indexArray) > 1 Then
			$indexStart = 0
			$indexEnd = UBound($indexArray)
			If $bDebug Then SetLog("Multi Point (" & $sDropPoints & ") , $indexStart : " & $indexStart & " , $indexEnd : " & $indexEnd)
		Else
			$indexArray = 0
		EndIf
	EndIf

	; Let's find Deploy Points
	If IsArray($indexVect) = 1 Then ;Multi Start To End(2-6)
		ReDim $aCSVParsedDeployPoint_XY[$indexEnd - $indexStart + 1]
		Local $j = 0
		For $i = $indexStart To $indexEnd
			$atempDeploy[0] = $aSelectedDropSidePoints_XY[$i - 1][0]
			$atempDeploy[1] = $aSelectedDropSidePoints_XY[$i - 1][1]
			$aCSVParsedDeployPoint_XY[$j] = $atempDeploy
			$j += 1
		Next
	ElseIf IsArray($indexArray) = 1 Then ;Multi Drop Point(2,4,6)
		ReDim $aCSVParsedDeployPoint_XY[UBound($indexArray)]
		For $i = 0 To $indexEnd - 1
			If $indexArray[$i] > $iMaxDropPoints Then $indexArray[$i] = $iMaxDropPoints ;Points Can't be Greater The Max Drop Points
			If $indexArray[$i] - 1 < 0 Then $indexArray[$i] = 1
			$atempDeploy[0] = $aSelectedDropSidePoints_XY[$indexArray[$i] - 1][0]
			$atempDeploy[1] = $aSelectedDropSidePoints_XY[$indexArray[$i] - 1][1]
			$aCSVParsedDeployPoint_XY[$i] = $atempDeploy
		Next
	Else
		ReDim $aCSVParsedDeployPoint_XY[1]
		$sDropPoints = Int($sDropPoints)
		If $sDropPoints > $iMaxDropPoints Then $sDropPoints = $iMaxDropPoints ; To Avoid Crash Set To Max If More then Max Point
		$atempDeploy[0] = $aSelectedDropSidePoints_XY[$sDropPoints - 1][0]
		$atempDeploy[1] = $aSelectedDropSidePoints_XY[$sDropPoints - 1][1]
		$aCSVParsedDeployPoint_XY[0] = $atempDeploy
	EndIf

	Return $aCSVParsedDeployPoint_XY
EndFunc   ;==>ParseCSVDropPoints

Func AddTilesToDeployPoint(ByRef $aSelectedDropSidePoints_XY, $iAddTiles, $sSelectedDropSideName, $bDebug)
	If $iAddTiles = 1 Then Return ;Default Value Is 1 Do Nothing
	If IsArray($g_aBuilderBaseOuterPolygon) = 0 Then Return ;If Builder Base Outer Polygon not defined skip
	SetDebugLog("AddTilesToDeployPoint $sSelectedDropSideName: " & $sSelectedDropSideName & ", $iAddTiles: " & $iAddTiles)
	For $i = 0 To UBound($aSelectedDropSidePoints_XY) - 1
		If Not $g_bRunState Then Return
		Local $x = $aSelectedDropSidePoints_XY[$i][0]
		Local $y = $aSelectedDropSidePoints_XY[$i][1]
		Local $pixel[2]
		; use ADDTILES * 8 pixels per tile to add offset to vector location
		For $u = 8 * Abs(Int($iAddTiles)) To 0 Step -1 ; count down to zero pixels till find valid drop point
			If Int($iAddTiles) > 0 Then ; adjust for positive or negative ADDTILES value
				Local $l = $u
			Else
				Local $l = -$u
			EndIf

			Switch $sSelectedDropSideName
				Case "TopLeft"
					$pixel[0] = $x - $l
					$pixel[1] = $y - $l
				Case "TopRight"
					$pixel[0] = $x + $l
					$pixel[1] = $y - $l
				Case "BottomLeft"
					$pixel[0] = $x - $l
					$pixel[1] = $y + $l
				Case "BottomRight"
					$pixel[0] = $x + $l
					$pixel[1] = $y + $l
			EndSwitch
			If _IsPointInPoly($pixel[0], $pixel[1], $g_aBuilderBaseOuterPolygon) Then ; Check if X,Y is inside Builderbase or outside
				If $bDebug Then SetDebugLog("After AddTile: " & $iAddTiles & ", DropSide: " & $sSelectedDropSideName & ", Deploy Point: " & $i + 1 & " - " & $pixel[0] & " x " & $pixel[1])
				$aSelectedDropSidePoints_XY[$i][0] = $pixel[0]
				$aSelectedDropSidePoints_XY[$i][1] = $pixel[1]
				ExitLoop
			Else
				If $bDebug Then SetDebugLog("Outside Polygon DropSide: " & $sSelectedDropSideName & ", Deploy Point: " & $i + 1 & " - " & $pixel[0] & " x " & $pixel[1])
			EndIf
		Next
	Next

EndFunc   ;==>AddTilesToDeployPoint

Func AddTilesToEdgePoint(ByRef $aSelectedEdgePoints_XYS, $iAddTiles, $bDebug)
	If $iAddTiles = 1 Then Return ;Default Value Is 1 Do Nothing
	If IsArray($g_aBuilderBaseOuterPolygon) = 0 Then Return ;If Builder Base Outer Polygon not defined skip
	SetDebugLog("AddTilesToEdgePoint $iAddTiles: " & $iAddTiles)
	For $i = 0 To UBound($aSelectedEdgePoints_XYS) - 1
		If Not $g_bRunState Then Return
		Local $x = $aSelectedEdgePoints_XYS[$i][0]
		Local $y = $aSelectedEdgePoints_XYS[$i][1]
		Local $sSelectedDropSideName = $aSelectedEdgePoints_XYS[$i][2]
		Local $pixel[2]
		; use ADDTILES * 8 pixels per tile to add offset to vector location
		For $u = 8 * Abs(Int($iAddTiles)) To 0 Step -1 ; count down to zero pixels till find valid drop point
			If Int($iAddTiles) > 0 Then ; adjust for positive or negative ADDTILES value
				Local $l = $u
			Else
				Local $l = -$u
			EndIf

			Switch $sSelectedDropSideName
				Case "TopLeft"
					$pixel[0] = $x - $l
					$pixel[1] = $y - $l
				Case "TopRight"
					$pixel[0] = $x + $l
					$pixel[1] = $y - $l
				Case "BottomLeft"
					$pixel[0] = $x - $l
					$pixel[1] = $y + $l
				Case "BottomRight"
					$pixel[0] = $x + $l
					$pixel[1] = $y + $l
			EndSwitch
			If _IsPointInPoly($pixel[0], $pixel[1], $g_aBuilderBaseOuterPolygon) Then ; Check if X,Y is inside Builderbase or outside
				If $bDebug Then SetDebugLog("After AddTile: " & $iAddTiles & ", DropSide: " & $sSelectedDropSideName & ", Edges Deploy Point: " & $i + 1 & " - " & $pixel[0] & " x " & $pixel[1])
				$aSelectedEdgePoints_XYS[$i][0] = $pixel[0]
				$aSelectedEdgePoints_XYS[$i][1] = $pixel[1]
				ExitLoop
			Else
				If $bDebug Then SetDebugLog("Outside Polygon DropSide: " & $sSelectedDropSideName & ", Edges Deploy Point: " & $i + 1 & " - " & $pixel[0] & " x " & $pixel[1])
			EndIf
		Next
	Next

EndFunc   ;==>AddTilesToEdgePoint

Func VerifySlotTroop($sTroopName, ByRef $aSlot_XY, ByRef $iQtyOfSelectedSlot, ByRef $iSlotNumber, $aAvailableTroops_NXQ)
	; Select Slot.
	Local $iSlotX = 0, $iSlotY = 0
	; Lets check all available troops
	For $i = 0 To UBound($aAvailableTroops_NXQ) - 1
		If Not $g_bRunState Then Return
		; verify Name and If is different then last slot
		If StringInStr($aAvailableTroops_NXQ[$i][0], $sTroopName) <> 0 And $iSlotNumber <> $i Then
			$iSlotX = $aAvailableTroops_NXQ[$i][1]
			$iSlotY = $aAvailableTroops_NXQ[$i][2]
			$iQtyOfSelectedSlot = $aAvailableTroops_NXQ[$i][4]
			If $iQtyOfSelectedSlot > 0 Then
				$iSlotNumber = $i
				ExitLoop
			EndIf
		EndIf
	Next

	; If the Troop doesn't exist
	If $iQtyOfSelectedSlot = 0 Or $iSlotX = 0 Or $iSlotY = 0 Then
		SetLog(" - " & FullNametroops($sTroopName) & " doesn't exist or empty", $COLOR_WARNING)
		Return False
	EndIf

	; Select Slot
	$aSlot_XY[0] = $iSlotX
	$aSlot_XY[1] = $iSlotY

	; Set The Battle Machine Slot Coordinates in Attack Bar
	If $sTroopName = "Machine" Then
		$g_aMachineBB[0] = $iSlotX
		$g_aMachineBB[1] = $iSlotY
	EndIf
	
	Click($iSlotX - Random(0, 5, 1), $iSlotY - Random(0, 5, 1), 1, 0)
	If _Sleep(250) Then Return
	Return True
EndFunc   ;==>VerifySlotTroop

Func DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, $iQtyToDrop)
	SetDebugLog("[" & _ArrayToString($aSlot_XY) & "] - Deploying " & $iQtyToDrop & " " & FullNametroops($sTroopName) & " At " & $Point2Deploy[0] & " x " & $Point2Deploy[1], $COLOR_INFO)
	ClickP($Point2Deploy, $iQtyToDrop, 0)
	
	If IsArray($g_aMachineBB) And ($sTroopName = "Machine") And ($g_aMachineBB[2] = False) Then
		; Set the Boolean To True to Say Yeah! It's Deployed!
		$g_aMachineBB[2] = True
		
		; It look for the white border in case it failed to launch.
		If ($g_aMachineBB[0] <> -1) Then
			If _Sleep(500) Then Return
			$g_aMachineBB[2] = (Not _Wait4Pixel($g_aMachineBB[0], 723, Hex(0xFFFFFF, 6), 30, 100, 25, False))
			SetLog("- BB Machine is ok? " & $g_aMachineBB[2], $COLOR_INFO)
		EndIf
	EndIf
EndFunc   ;==>DeployTroopBB

Func GetThePointNearBH($aBHposition, $aDeployPoints, $sMode = "BH")
	Local $aResult[1][3], $aReturn[0][3], $aPoints[1][2]
	Local $aName[4] = ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]
	For $i = 0 To UBound($aName) -1
		$aPoints = $g_aDeployPoints[$i]
		For $j = 0 To UBound($aPoints) -1
			$aResult[0][0] = $aPoints[$j][0]
			$aResult[0][1] = $aPoints[$j][1]                    
			$aResult[0][2] = Pixel_Distance(Int($aBHposition[0]), Int($aBHposition[1]), Int($aResult[0][0]), Int($aResult[0][1]))
			_ArrayAdd($aReturn, $aResult)
		Next
	Next
	_ArraySort($aReturn, 0, 0, 2)
	;_ArrayDisplay($aReturn)
	Return $aReturn
EndFunc   ;==>GetThePointNearBH

Func TriggerMachineAbility($bBBIsFirst = -1, $ix = -1, $iy = -1, $bTest = False)
	Local $sFuncName = "TriggerMachineAbility: "
	
	If UBound($g_aMachineBB) < 4 Then
		Setlog("TriggerMachineAbility | This will not work 0x1.", $COLOR_ERROR)
		Return False
	EndIf
	
	If ($bBBIsFirst = -1) Then $bBBIsFirst = $g_aMachineBB[3]
	
	; If it's not just a test, Exit the Function if Machine is not yet deployed
	If $bTest = False And $g_aMachineBB[2] = False Then Return False

	; Check and set the Coordinates of Machine Slot in Attack Bar
	If $g_aMachineBB[0] = -1 Then
		If $ix > -1 And $iy > -1 Then
			SetDebugLog($sFuncName & "Setting Coordinates to the Machine Slot manually! [" & $ix & ", " & $iy & "]", $COLOR_INFO)
			$g_aMachineBB[0] = $ix
			$g_aMachineBB[1] = $iy
		Else
			SetLog($sFuncName & "I have no coordinates to the Machine Slot Position", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	
	; If it's too early for a check, exit the Function! NOTE: If $g_iBBMachAbilityLastActivatedTime here is -1, it means Machine is Deployed but the Ability is not yet Activated!
	; We use random to not always get activated in an specific Time Delay
	If $g_iBBMachAbilityLastActivatedTime > -1 And __TimerDiff($g_iBBMachAbilityLastActivatedTime) < Random($g_iBBMachAbilityTime - 2000, $g_iBBMachAbilityTime + 2000, 1) Then Return False

	SetDebugLog($sFuncName & "Checking ability.")
	
	Local $hPixel
	$hPixel = _GetPixelColor(Int($g_aMachineBB[0]), 721, True)
	If $bTest Or $g_bDebugSetlog Then Setlog($hPixel & " ability", $COLOR_INFO)

	If $bBBIsFirst And ($g_aMachineBB[0] <> -1) Then
		If $bTest Or $g_bDebugSetlog Then Setlog(_ArrayToString($g_aMachineBB), $COLOR_INFO)
		If _ColorCheck($hPixel, Hex(0x472CC5, 6), 40) Then
			Click(Int($g_aMachineBB[0] + Random(5, 15, 1)), Int($g_aMachineBB[1] + Random(5, 15, 1)), Random(1, 3, 1), 100)
			SetLog("- BB Machine : Activated Ability for the first time.", $COLOR_ACTION)
			$bBBIsFirst = False
			$g_aMachineBB[3] = $bBBIsFirst
			$g_iBBMachAbilityLastActivatedTime = __TimerInit()
			If RandomSleep(300) Then Return
			Return True
		Else
			If $g_aMachineBB[3] Then SetLog("- BB Machine : Skill not present.", $COLOR_INFO)
			Return False
		EndIf
	EndIf
	
	If _ColorCheck($hPixel, Hex(0x432CCE, 6), 20) Then
		Click(Int($g_aMachineBB[0] + Random(5, 15, 1)), Int($g_aMachineBB[1] + Random(5, 15, 1)), Random(1, 3, 1), 100)
		SetLog("- BB Machine : Activated Ability.", $COLOR_ACTION)
		$g_iBBMachAbilityLastActivatedTime = __TimerInit()
		If RandomSleep(300) Then Return
		Return True
	EndIf
	Return False
EndFunc   ;==>TriggerMachineAbility

Func BattleIsOver()
	Local $bIsEnded = False
	Local $aBlackArts[4] = [520, 600, 0x000000, 5]
	
	For $iBattleOverLoopCounter = 0 To 190
		If _Sleep(1000) Then Return
		If Not $g_bRunState Then Return
		
		TriggerMachineAbility()
		
		Local $iDamage = Number(getOcrOverAllDamage(780, 587))
		If Int($iDamage) > Int($g_iLastDamage) Then
			$g_iLastDamage = Int($iDamage)
			Setlog("- Total Damage: " & $g_iLastDamage & "%", $COLOR_INFO)
		EndIf
		
		If _CheckPixel($aBlackArts, True) Then
			If _WaitForCheckImg($g_sImgOkButton, "345, 540, 524, 615") Then $bIsEnded = True
			SetDebugLog("BattleIsOver | $bIsEnded : " & $bIsEnded)
			ExitLoop
		EndIf
	Next

	If ($iBattleOverLoopCounter > 180) Then Setlog("Window Report Problem!", $COLOR_WARNING)
EndFunc   ;==>BattleIsOver


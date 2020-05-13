; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseCSV
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseCSV()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
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
	Local $Status = $g_bRunState
	$g_bRunState = True

	Local $TempDebug = $g_bDebugOcr
	$g_bDebugOcr = True

	BuilderBaseResetAttackVariables()

	; Attack Bar | [0] = Troops Name , [1] = X-axis , [2] - Quantities
	;Local $AvailableTroops = BuilderBaseAttackBar()
	Local $AvailableTroops = GetAttackBarBB()

	If $AvailableTroops <> -1 Then

		BuilderBaseSelectCorrectScript($AvailableTroops)

		; Zoomout the Opponent Village
		BuilderBaseZoomOut()

		Local $FurtherFrom = 5 ; 5 pixels before the deploy point
		BuilderBaseGetDeployPoints($FurtherFrom, True)

		; Parse CSV , Deploy Troops and Get Machine Status [attack algorithm] , waiting for Battle ends window
		BuilderBaseParseAttackCSV($AvailableTroops, $g_aDeployPoints, $g_aDeployBestPoints, True)

		; Attack Report Window
		BuilderBaseAttackReport()

		; Stats
		; BuilderBaseAttackUpdStats()
	EndIf

	$g_bDebugOcr = $TempDebug
	$g_bRunState = $Status

	Setlog("** TestBuilderBaseParseAttackCSV END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseParseAttackCSV


; Main Function
Func BuilderBaseParseAttackCSV($AvailableTroops, $DeployPoints, $DeployBestPoints, $bDebug = False)

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
	Local $aAvailableTroops_NXQ = $AvailableTroops

	; Machine Ability
	Local $bIfMachineWasDeployed = False
	Local $bIfMachineHasAbility = False
	Local $aMachineSlot_XYA[3] = [0, 0, 0] ;3rd column is for Ability Pixel

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
					; Global Enum $g_iAirDefense = 0 , $g_iCrusher , $g_iGuardPost, $g_iCannon, $g_iBuilderHall, $g_iDeployPoints
					; Global $g_aBuilderHallPos[1][2] = [[Null, Null]], $g_aAirdefensesPos[0][2], $g_aCrusherPos[0][2], $g_aCannonPos[0][2] , $g_aGuardPostPos[0][2]
					For $i = 4 To 0 Step -1
						$command = Int(StringStripWS($aSplitLine[$i + 1], $STR_STRIPALL))
						If $command = 1 Then
							; Remember the Buildings Arrays is :  [0] = name , [1] = Xaxis , [1] = Yaxis
							Switch $i
								Case $g_iAirDefense
									$g_aAirdefensesPos = BuilderBaseBuildingsDetection($g_iAirDefense)
									Setlog("Detected Air defenses: " & UBound($g_aCrusherPos), $COLOR_INFO)
									ExitLoop
								Case $g_iCrusher
									$g_aCrusherPos = BuilderBaseBuildingsDetection($g_iCrusher)
									Setlog("Detected Crusher: " & UBound($g_aCrusherPos), $COLOR_INFO)
									ExitLoop
								Case $g_iGuardPost
									$g_aGuardPostPos = BuilderBaseBuildingsDetection($g_iGuardPost)
									Setlog("Detected GuardPost: " & UBound($g_aCrusherPos), $COLOR_INFO)
									ExitLoop
								Case $g_iCannon
									$g_aCannonPos = BuilderBaseBuildingsDetection($g_iCannon)
									Setlog("Detected Cannon: " & UBound($g_aCrusherPos), $COLOR_INFO)
									ExitLoop
								Case $g_iBuilderHall
									; Is not necessary to get again if was detected when deploy point detection ran
									If $g_aBuilderHallPos[0][0] = Null Then $g_aBuilderHallPos = BuilderBaseBuildingsDetection($i - 1)
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
						For $i = 0 To 3
							$command = Int(StringStripWS($aSplitLine[$i + 1], $STR_STRIPALL))
							If $command = 1 Then
								; Get the Array inside the array $bDefenses
								Local $BuildPositionArray = $bDefenses[$i - 1]
								; Let get the First building detected
								; Remember the Buildings Arrays is :  [0] = name , [1] = Xaxis , [1] = Yaxis
								Local $BuildPosition = [$BuildPositionArray[0][1], $BuildPositionArray[0][2]]
								; Get in string the FORCED Side name
								If $sFrontSide = "" Then
									$sFrontSide = DeployPointsPosition($BuildPosition)
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
							If StringInStr($aAvailableTroops_NXQ[$i][0], $sTroopName) <> 0 Then ;We Just Need To redo the ocr for mentioned troop only
								$aAvailableTroops_NXQ[$i][4] = Number(_getTroopCountSmall(Number($aAvailableTroops_NXQ[$i][1]), 640))
								If $aAvailableTroops_NXQ[$i][4] < 1 Then $aAvailableTroops_NXQ[$i][4] = Number(_getTroopCountBig(Number($aAvailableTroops_NXQ[$i][1]), 633)) ; For Big numbers when the troop is selected
							EndIf
						Next

						If $sDropSide = "FRONT" Or $sDropSide = "BACK" Or $sDropSide = "LEFT" Or $sDropSide = "RIGHT" Then ; Use external edges Point
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
					Local $SleepAfter = Int($aDROP[6])

					SetDebugLog("$iQtyToDrop : " & $iQtyToDrop & ", $sQty : " & $sQty & ", $sTroopName : " & $sTroopName & ", $aSelectedDropSidePoints_XY : " & $sDropPoints & ", $iAddTiles : " & $iAddTiles & ", $sDropSide : " & $sDropSide & ", $SleepAfter : " & $SleepAfter)

					Local $iQtyOfSelectedSlot = 0 ; Quantities on current slot
					Local $iSlotNumber = 20 ; just an impossible slot to initialize it
					Local $aSlot_XY = [0, 0]

					; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot And $iSlotNumber
					If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then
						TriggerMachineAbility() ;Click On Ability Before Skipping The Loop
						ContinueLoop
					EndIf

					If $sDropSide <> "BH" And $sDropSide <> "EDGEB" Then
						Local $sSelectedDropSideName ;Using For AddTile That Which Side Was Choosed To Attack
						; Correct FRONT - BACK - LEFT - RIGHT - BH - EDGEB
						Local $aSelectedDropSidePoints_XY = CorrectDropPoints($sFrontSide, $sDropSide, $aDeployBestPoints, $sSelectedDropSideName)
						SortPoints($aSelectedDropSidePoints_XY, $bDebug)
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
									If $g_bIsBBMachineD Then ExitLoop (2)
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

					Else
						If $sDropSide = "EDGEB" Then
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
										; If IsMachineDepoloyed($sTroopName, $iSlotNumber, $bIfMachineWasDeployed, $bIfMachineHasAbility, $aMachineSlot_XYA) Then ExitLoop (2)
										If $g_bIsBBMachineD Then ExitLoop (2)

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

						ElseIf $sDropSide = "BH" Then
							If $g_aBuilderHallPos[0][0] <> Null Then
								Local $BHposition = [$g_aBuilderHallPos[0][0], $g_aBuilderHallPos[0][1]]
								; Get/Check if the distance from any deploy point is less than 75px
								Local $Point2Deploy = GetThePointNearBH($BHposition, $aDeployPoints)
								If $Point2Deploy[0] <> "" Then
									For $i = 0 To $iQtyToDrop - 1
										DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, 1)
										$iQtyOfSelectedSlot -= 1
										$iTotalQtyByTroop -= 1
										; Remove the Qty from the Original array :
										$aAvailableTroops_NXQ[$iSlotNumber][4] = $iQtyOfSelectedSlot
										; If is the Machine exist and deployed
										;If IsMachineDepoloyed() Then ExitLoop
										If $g_bIsBBMachineD Then ExitLoop

										If $iTotalQtyByTroop < 1 Then ExitLoop
										; Let's select another slot if this slot is empty
										If $iQtyOfSelectedSlot < 1 Then
											; VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot and $iSlotNumber
											If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then ExitLoop
										EndIf
										; Just a small Delay to Pause Function
										If _Sleep(100) Then Return
									Next
								EndIf
							EndIf
						EndIf
					EndIf

					; A log user
					SetLog(" - " & $aAvailableTroops_NXQ[$iSlotNumber][4] & "x/" & $iTotalQtyByTroop & "x " & FullNametroops($aAvailableTroops_NXQ[$iSlotNumber][0]) & " at slot " & $iSlotNumber + 1, $COLOR_WARNING)

			EndSwitch
		Next

		; Let's Assume That Our CSV Was Bad That None Of The Troops Was Deployed Let's Deploy Everything
		; Let's make a Remain Just In Case deploy points problem somewhere in red zone OR Troop was not mentioned in CSV OR Hero Was not dropped. Let's drop All
		Local $aAvailableTroops_NXQ = GetAttackBarBB(True)
		If $aAvailableTroops_NXQ <> -1 And IsArray($aAvailableTroops_NXQ) Then
			SetLog("CSV Does not deploy some of the troops. So Now just dropping troops in a waves", $COLOR_INFO)
			; Main Side to attack
			If $sFrontSide = "" Then
				$sFrontSide = BuilderBaseAttackMainSide()
				Setlog("Detected Front Side: " & $sFrontSide, $COLOR_INFO)
			EndIf
			;Local $sSelectedDropSideName ;Using For AddTile But in this remain no use
			;Local $aSelectedDropSidePoints_XY = CorrectDropPoints($sFrontSide, "FRONTE", $aDeployBestPoints, $sSelectedDropSideName)
			;SortPoints($aSelectedDropSidePoints_XY, $bDebug)
			Local $aSelectedDropSidePoints_XY = $g_aExternalEdges[0]
			; Just in Case
			If UBound($aSelectedDropSidePoints_XY) > 0 Then
				Local $iQtyOfSelectedSlot = 0 ; Quantities on current slot
				Local $iSlotNumber = 20 ; just an impossible slot to initialize it
				Local $aSlot_XY = [0, 0]
				Local $sTroopName = ""
				Local $iQtyToDrop = 0

				For $i = 0 To UBound($aAvailableTroops_NXQ) - 1
					$sTroopName = $aAvailableTroops_NXQ[$i][0]
					; Let's select the slot VerifySlotTroops uses ByRef on $aSlot_XY , $iQtyOfSelectedSlot and $iSlotNumber
					If Not VerifySlotTroop($sTroopName, $aSlot_XY, $iQtyOfSelectedSlot, $iSlotNumber, $aAvailableTroops_NXQ) Then
						ContinueLoop
					EndIf
					$iQtyToDrop = $iQtyOfSelectedSlot ;Quantity We Want to Drop Is The Quantity Of The Slot
					Local $iTroopsDropped = 0
					While $iTroopsDropped < $iQtyToDrop
						For $j = 0 To UBound($aSelectedDropSidePoints_XY) - 1
							If ($iTroopsDropped < $iQtyToDrop) Then ; Check That Drop Troops Don't Get Exceeded By Slot Quantity
								; get one Deploy point
								Local $Point2Deploy = [$aSelectedDropSidePoints_XY[$j][0], $aSelectedDropSidePoints_XY[$j][1]]
								DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, 1)
								; Increment Troops Dropped
								$iTroopsDropped += 1
								; removing the deployed troop
								$iQtyOfSelectedSlot -= 1
								; Remove the Qty from the Original array :
								$aAvailableTroops_NXQ[$iSlotNumber][2] = $iQtyOfSelectedSlot
								; If is the Machine exist and deployed
								If $g_bIsBBMachineD Then ExitLoop (2)
								; Just a small Delay to Pause Function
								If _Sleep(100) Then Return
							Else
								ExitLoop (2)
							EndIf
						Next
					WEnd
					TriggerMachineAbility()
					; Add Delay To Make Like Wave Of Troops
					If _Sleep(2000) Then Return
				Next
			EndIf
		EndIf

		; Machine Ability and Battle
		For $i = 0 To Int($SleepAfter / 50)
			; Machine Ability
			TriggerMachineAbility()
			BattleIsOver()
			If _Sleep(50) Then Return
		Next

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

Func SortPoints(ByRef $aSelectedDropSidePoints_XY, $bDebug = False)
	; SORT by X-axis - column 0
	If Not $g_bRunState Then Return
	If UBound($aSelectedDropSidePoints_XY) > 1 Then _ArraySort($aSelectedDropSidePoints_XY, 0, 0, 0, 0)
	SetDebugLog(UBound($aSelectedDropSidePoints_XY) & " points to deploy in this side!", $COLOR_DEBUG)
	If $bDebug Then _ArrayToString($aSelectedDropSidePoints_XY)
EndFunc   ;==>SortPoints

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

	; Verify Battle Machine.
	TriggerMachineAbility()

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

	Click($iSlotX, $iSlotY, 1, 0)
	If _Sleep(250) Then Return
	Return True
EndFunc   ;==>VerifySlotTroop

Func DeployTroopBB($sTroopName, $aSlot_XY, $Point2Deploy, $iQtyToDrop)
	SetDebugLog("[" & _ArrayToString($aSlot_XY) & "] - Deploying " & $iQtyToDrop & " " & FullNametroops($sTroopName) & " At " & $Point2Deploy[0] & " x " & $Point2Deploy[1], $COLOR_INFO)
	If $g_bIsBBMachineD = False Then $g_bIsBBMachineD = ($sTroopName = "Machine") ? (True) : (False)
	ClickP($Point2Deploy, $iQtyToDrop, 0)
EndFunc   ;==>DeployTroopBB

Func GetThePointNearBH($BHposition, $aDeployPoints)
	Local $ReturnPoint[2] = ["", ""]
	Local $Name[4] = ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]
	Local $MostNear = 45
	For $i = 0 To UBound($aDeployPoints) - 1
		If Not $g_bRunState Then Return
		Local $TempCoordinatesBySide = $aDeployPoints[$i]
		For $j = 0 To UBound($TempCoordinatesBySide) - 1
			Local $SingleCoordinate = [$TempCoordinatesBySide[$j][0], $TempCoordinatesBySide[$j][1]]
			Local $Distance = Pixel_Distance(Int($BHposition[0]), Int($BHposition[1]), Int($SingleCoordinate[0]), Int($SingleCoordinate[1]))
			If $Distance < $MostNear Then
				$MostNear = $Distance
				$ReturnPoint[0] = Int($SingleCoordinate[0])
				$ReturnPoint[1] = Int($SingleCoordinate[1])
			EndIf
		Next
	Next
	Return $ReturnPoint
EndFunc   ;==>GetThePointNearBH

Func TriggerMachineAbility()

	If Not $g_bIsBBMachineD Then Return

	If UBound($g_aMachineBB) = 0 Then Return

	Local $aMachine[2] = [$g_aMachineBB[0][1], $g_aMachineBB[0][2]]

	SetDebugLog("- BB Machine : Checking ability.")

	If $g_bBBIsFirst And UBound($aMachine) > 2 Then

		If MultiPSimple(Int($aMachine[0]) - 11, Int($aMachine[1]) - 21, Int($aMachine[0]) + 51, Int($aMachine[1]) + 73, Hex(0x5225C4, 6), 28, 1000, 30) <> 0 Then
			ClickP($aMachine, 2, 0)
			If _Sleep(300) Then Return
			SetLog("- BB Machine : Skill enabled.", $COLOR_ACTION)
			$g_bBBIsFirst = False
			Return
		Else
			SetLog("- BB Machine : Skill not present.", $COLOR_INFO)
			$g_bIsBBMachineD = False
			Return
		EndIf
	EndIf

	If MultiPSimple(Int($aMachine[0]) - 11, Int($aMachine[1]) - 21, Int($aMachine[0]) + 51, Int($aMachine[1]) + 73, Hex(0x5225C4, 6), 28, 200, 30) <> 0 Then
		ClickP($aMachine, 2, 0)
		If _Sleep(300) Then Return
		SetLog("- BB Machine : Click on ability.", $COLOR_INFO)
	EndIf
EndFunc   ;==>TriggerMachineAbility

Func BattleIsOver()
	Local $SurrenderBtn = [65, 607]
	For $i = 0 To 180
		If Not $g_bRunState Then Return
		TriggerMachineAbility()
		Local $Damage = Number(getOcrOverAllDamage(780, 527 + $g_iBottomOffsetY))
		If Int($Damage) > Int($g_iLastDamage) Then
			$g_iLastDamage = Int($Damage)
			Setlog("Total Damage: " & $g_iLastDamage & "%")
		EndIf
		If Not _ColorCheck(_GetPixelColor($SurrenderBtn[0], $SurrenderBtn[1], True), Hex(0xcf0d0e, 6), 10) Then ExitLoop
		If $i = 180 Then Setlog("Window Report Problem!", $COLOR_WARNING)
		If _Sleep(1000) Then Return
	Next

EndFunc   ;==>BattleIsOver


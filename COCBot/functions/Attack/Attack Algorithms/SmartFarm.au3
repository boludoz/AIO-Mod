; #FUNCTION# ====================================================================================================================
; Name ..........: Smart Farm
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: None
; Return values .: None
; Author ........: ProMac Jan 2017
; Modified ......: ProMac (2020), Team AIO Mod++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_aGreenTiles = -1, $g_iRandomSides[4] = [0, 1, 2, 3], $g_sRandomSidesNames[4] = ["BR", "TL", "BL", "TR"]
Global $g_aiPixelTopLeftFurther[0], $g_aiPixelTopLeft[0]
Global $g_aiPixelBottomLeftFurther[0], $g_aiPixelBottomLeft[0]
Global $g_aiPixelTopRightFurther[0], $g_aiPixelTopRight[0]
Global $g_aiPixelBottomRightFurther[0], $g_aiPixelBottomRight[0]

Func TestSmartFarm($bFast = True)

	$g_iDetectedImageType = 0

	; Getting the Run state
	Local $RuntimeA = $g_bRunState
	$g_bRunState = True

	Local $bDebugSmartFarmTemp = $g_bDebugSmartFarm
	$g_bDebugSmartFarm = True

	Setlog("Starting the SmartFarm Attack Test()", $COLOR_INFO)
	If $bFast = False Then
		checkMainScreen(False)
		CheckIfArmyIsReady()
		ClickP($aAway, 2, 0, "") ;Click Away
		If _Sleep(100) Then Return FuncReturn()
		If (IsSearchModeActive($DB) And checkCollectors(True, False)) Or IsSearchModeActive($LB) Then
			If _Sleep(100) Then Return FuncReturn()
			PrepareSearch()
			If _Sleep(1000) Then Return FuncReturn()
			VillageSearch()
			If $g_bOutOfGold Then Return ; Check flag for enough gold to search
			If _Sleep(100) Then Return FuncReturn()
		Else
			SetLog("Your Army is not prepared, check the Attack/train options")
		EndIf
	EndIf
	PrepareAttack($g_iMatchMode)

	$g_bAttackActive = True
	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	Local $Nside = ChkSmartFarm()
	AttackSmartFarm($Nside[1], $Nside[2])
	$g_bAttackActive = False

	ReturnHome($g_bTakeLootSnapShot)

	Setlog("Finish the SmartFarm Attack()", $COLOR_INFO)

	$g_bRunState = $RuntimeA
	$g_bDebugSmartFarm = $bDebugSmartFarmTemp

EndFunc   ;==>TestSmartFarm

; Collectors | Mines | Drills | All (Default)
Func ChkSmartFarm($sTypeResources = "All", $bTH = False)

	; Initial Timer
	Local $iRandomSides[4] = [0, 1, 2, 3]
	Local $Sides = ["BR", "TL", "BL", "TR"]
	For $x = 0 To UBound($g_iRandomSides) - 1
		Local $i = Random(0, UBound($iRandomSides) - 1, 1)
		$g_iRandomSides[$x] = $iRandomSides[$i]
		$g_sRandomSidesNames[$x] = $Sides[$i]
		_ArrayDelete($iRandomSides, $i)
		_ArrayDelete($Sides, $i)
	Next
	SetLog("Next Side Order is " & _ArrayToString($g_sRandomSidesNames))
	SetDebugLog("Original $g_iRandomSides: " & _ArrayToString($g_iRandomSides))
	Local $hTimer = TimerInit()

	; [0] = x , [1] = y , [2] = Side , [3] = In/out , [4] = Side,  [5]= Is string with 5 coordinates to deploy
	Local $g_bUseSmartFarmRedLine = True
	Local $aResourcesOUT[0][6]
	Local $aResourcesIN[0][6]

	; TL , TR , BL , BR
	Local $aMainSide[4] = [0, 0, 0, 0]

	If $g_bDebugSetlog Then SetDebugLog(" - INI|SmartFarm detection.", $COLOR_INFO)
	_CaptureRegion2()
	ConvertInternalExternArea("ChkSmartFarm")
	If $g_bUseSmartFarmRedLine Then
		SetDebugLog("Using Green Tiles -> Red Lines -> Edges")
		NewRedLines()
	Else
		SetDebugLog("Classic Redlines, mix with edges.")
		_GetRedArea()
	EndIf
	$hTimer = TimerInit()
	If $bTH Then
		If $g_iSearchTH = "-" Then FindTownHall(True, True)
		Local $THdetails[4] = [$g_iSearchTH, $g_iTHx, $g_iTHy, _ObjGetValue($g_oBldgAttackInfo, $eBldgTownHall & "_REDLINEDISTANCE")]
		SetLog("TH Details: " & _ArrayToString($THdetails, "|"))
	Else
		Local $THdetails[4] = ["-", 0, 0, ""]
	EndIf

	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	#Region - AreCollectorsOutside - Team AIO Mod++
	Local $aAll
	If $g_vSmartFarmScanOut <> 0 And $sTypeResources = "All" Then
		$aAll = $g_vSmartFarmScanOut
		$g_vSmartFarmScanOut = 0
	Else
		$aAll = SmartFarmDetection($sTypeResources)
	EndIf
	#EndRegion - AreCollectorsOutside - Team AIO Mod++

	If $g_bDebugSetlog Then SetDebugLog(" TOTAL detection Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)

	; Let's determinate what resource is out or in side the village
	; Collectors

	For $x = 0 To UBound($aAll) - 1
		; Only proceeds when the x exist , not -1
		If $aAll[$x][0] <> -1 Then
			If $aAll[$x][3] = "In" Then
				ReDim $aResourcesIN[UBound($aResourcesIN) + 1][6]
				For $t = 0 To 5 ; Fill the variables
					$aResourcesIN[UBound($aResourcesIN) - 1][$t] = $aAll[$x][$t]
				Next
			Else ; Out
				ReDim $aResourcesOUT[UBound($aResourcesOUT) + 1][6]
				For $t = 0 To 5 ; Fill the variables
					$aResourcesOUT[UBound($aResourcesOUT) - 1][$t] = $aAll[$x][$t]
				Next
			EndIf
			Switch $aAll[$x][4]
				Case "TL"
					$aMainSide[0] += 1
				Case "TR"
					$aMainSide[1] += 1
				Case "BL"
					$aMainSide[2] += 1
				Case "BR"
					$aMainSide[3] += 1
			EndSwitch
		EndIf
		If _Sleep(50) Then Return ; just in case on PAUSE
		If Not $g_bRunState Then Return ; Stop Button
	Next

	If $g_bDebugSmartFarm Then
		For $i = 0 To UBound($aResourcesIN) - 1
			For $x = 0 To 4
				If $g_bDebugSetlog Then SetDebugLog("$aResourcesIN[" & $i & "][" & $x & "]: " & $aResourcesIN[$i][$x], $COLOR_INFO)
			Next
		Next
		For $i = 0 To UBound($aResourcesOUT) - 1
			For $x = 0 To 4
				If $g_bDebugSetlog Then SetDebugLog("$aResourcesOUT[" & $i & "][" & $x & "]: " & $aResourcesOUT[$i][$x], $COLOR_INFO)
			Next
		Next
	EndIf
	Local $TotalOfResources = UBound($aResourcesIN) + UBound($aResourcesOUT)
	SetLog("Total of Resources: " & $TotalOfResources, $COLOR_INFO)
	SetLog(" - Inside the Village: " & UBound($aResourcesIN), $COLOR_INFO)
	SetLog(" - Outside the village: " & UBound($aResourcesOUT), $COLOR_INFO)
	SetDebugLog("MainSide array: " & _ArrayToString($aMainSide))
	If $g_bDebugSmartFarm Then
		If Number($g_iTownHallLevel) < 6 And $TotalOfResources < 7 Or Number($g_iTownHallLevel) < 9 And _
				$TotalOfResources < 8 Or Number($g_iTownHallLevel) < 14 And $TotalOfResources < 12 Then
			SaveDebugImage("SmartFarm_Collectors", False)
		EndIf
	EndIf
	$g_sResourcesIN = UBound($aResourcesIN)
	$g_sResourcesOUT = UBound($aResourcesOUT)
	$g_sResBySide = _ArrayToString($aMainSide)

	; Inside , Outside
	Local $AttackInside = False

	Local $Percentage_In = Int((UBound($aResourcesIN) / $TotalOfResources) * 100), $Percentage_Out = Int((UBound($aResourcesOUT) / $TotalOfResources) * 100)

	; FROM GUI
	Local $PercentageInSide = Int($g_iTxtInsidePercentage) ; Percentage to force ONE SIDE ATTACK
	Local $PercentageOutSide = Int($g_iTxtOutsidePercentage) ; Percentage to force to attack all sides with at least with one Resource

	If $Percentage_In > $PercentageInSide Then $AttackInside = True

	Local $TxtLog = ($AttackInside = True) ? ("Inside with " & $Percentage_In & "%") : ("Outside with " & $Percentage_Out & "%")
	Setlog(" - Best Attack will be " & $TxtLog)
	If Not $g_bRunState Then Return

	Local $OneSide = Floor($TotalOfResources / 4)
	Local $Sides[4] = ["TL", "TR", "BL", "BR"]
	Local $SidesExt[4] = ["Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right"]
	Local $aHowManySides[0]

	For $i = 0 To 3
		If $aMainSide[$i] >= $OneSide Or ($Percentage_Out > $PercentageOutSide And $aMainSide[$i] <> 0) Then
			ReDim $aHowManySides[UBound($aHowManySides) + 1]
			$aHowManySides[UBound($aHowManySides) - 1] = $Sides[$i]
		EndIf
	Next

	; Determinate the higher value if $AttackInside is True
	Local $BestSideToAttack[1] = ["TR"]
	Local $number = 0

	If $AttackInside Then
		For $i = 0 To UBound($aMainSide) - 1
			If $aMainSide[$i] > $number Then
				$number = $aMainSide[$i]
				$BestSideToAttack[0] = $Sides[$i]
			EndIf
		Next
		For $i = 0 To UBound($aMainSide) - 1
			If $BestSideToAttack[0] = $Sides[$i] Then Setlog("Best Side To Attack Inside: " & $SidesExt[$i])
			Setlog(" - Side " & $SidesExt[$i] & " with " & $aMainSide[$i] & " Resources.", $COLOR_INFO)
		Next
	Else
		$BestSideToAttack = $aHowManySides
	EndIf

	Setlog("Attack at " & UBound($BestSideToAttack) & " Side(s) - " & _ArrayToString($BestSideToAttack), $COLOR_INFO)
	Setlog(" Check Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	If Not $g_bRunState Then Return

	; DEBUG , image with all information
	Local $redline[UBound($BestSideToAttack)]
	If $g_bDebugSmartFarm Then
		For $i = 0 To UBound($BestSideToAttack) - 1
			$redline[$i] = GetOffsetRedline($BestSideToAttack[$i], 5)
		Next
		DebugImageSmartFarm($THdetails, $aResourcesIN, $aResourcesOUT, Round(TimerDiff($hTimer) / 1000, 2) & "'s", _ArrayToString($BestSideToAttack), $redline)
	EndIf

	#Region - Max Side - Team AIO Mod++
	If $g_bMaxSidesSF Then
		Local $aSides2[4][2] = [["TL", $aMainSide[0]], ["TR", $aMainSide[1]], ["BL", $aMainSide[2]], ["BR", $aMainSide[3]]]
		_ArraySort($aSides2, 0, 0, 0, 1)

		Local $iMaxL = ((UBound($BestSideToAttack) - 1) > ($g_iCmbMaxSidesSF - 1)) ? ($g_iCmbMaxSidesSF - 1) : (UBound($BestSideToAttack) - 1)
		Local $BestSideToAttack[0]
		For $i = 0 To $iMaxL
			Local $aClu[1] = [$aSides2[$i][0]]
			SetDebugLog("[" & $i & "] ChkSmartFarm | $aClu: " & $aSides2[$i][0])
			_ArrayAdd($BestSideToAttack, $aClu)
		Next
	EndIf
	#EndRegion - Max Side - Team AIO Mod++

	; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
	Local $Return[3] = [$AttackInside, UBound($BestSideToAttack), _ArrayToString($BestSideToAttack)]
	Return $Return

EndFunc   ;==>ChkSmartFarm

Func SmartFarmDetection($txtBuildings = "Mines", $bForceCapture = True)

	; This Function will fill an Array with several informations after Mines, Collectores or Drills detection with Imgloc
	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	Local $aReturn[0][6]
	Local $sdirectory, $iMaxReturnPoints, $iMaxLevel, $offsetx, $offsety
	If Not $g_bRunState Then Return


	; Initial Timer
	Local $iMinLevel = 0
	Local $iMaxLevel = 0
	If "Drills" <> $txtBuildings Then
		For $i = 6 To UBound($g_abCollectorLevelEnabled) - 1
			If $g_abCollectorLevelEnabled[$i] Then
				If $iMinLevel = 0 Then $iMinLevel = $i
				If $i > $iMaxLevel Then $iMaxLevel = $i
			EndIf
		Next
	EndIf
	SetDebugLog("Detection Resources with Min Level of " & $iMinLevel & " and Max of " & $iMaxLevel)
	Local $hTimer = TimerInit()

	; Prepared for Winter Theme
	Switch $txtBuildings
		Case "Mines"
			If $g_iDetectedImageType = 1 Then
				$sdirectory = @ScriptDir & "\imgxml\Storages\Mines_Snow"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\GoldMines"
			EndIf
			$iMaxReturnPoints = 7
		Case "Collectors"
			If $g_iDetectedImageType = 1 Then
				$sdirectory = @ScriptDir & "\imgxml\Storages\Collectors_Snow"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\Collectors"
			EndIf
			$iMaxReturnPoints = 7
		Case "Drills"
			$sdirectory = @ScriptDir & "\imgxml\Storages\Drills"
			$iMaxReturnPoints = 3
			$iMaxLevel = 8
		Case "All"
			If $g_iDetectedImageType = 1 Then
				$sdirectory = @ScriptDir & "\imgxml\Storages\All_Snow"
			Else
				$sdirectory = @ScriptDir & "\imgxml\Storages\All"
			EndIf
			$iMaxReturnPoints = 21
	EndSwitch

	Local $sCocDiamond = "ECD"
	Local $sRedLines = ""
	Local $sReturnProps = "objectname,objectpoints,nearpoints,redlinedistance"
	Local $aResult = findMultiple($sdirectory, $sCocDiamond, $sRedLines, $iMinLevel, $iMaxLevel, $iMaxReturnPoints, $sReturnProps, $bForceCapture)
	Local $aTemp, $sObjectname, $aObjectpoints, $sNear, $sRedLineDistance
	Local $tempObbj, $sNearTemp, $Distance, $tempObbjs, $sString
	Local $distance2RedLine = 40
	If IsArray($aResult) And UBound($aResult) > 0 Then
		For $buildings = 0 To UBound($aResult) - 1
			If _Sleep(50) Then Return
			If Not $g_bRunState Then Return
			SetDebugLog(_ArrayToString($aResult[$buildings]))
			$aTemp = $aResult[$buildings]
			$sObjectname = String($aTemp[0])
			SetDebugLog("Building name: " & String($aTemp[0]), $COLOR_INFO)
			$aObjectpoints = $aTemp[1]
			SetDebugLog("Object points: " & String($aTemp[1]), $COLOR_INFO)
			$sNear = $aTemp[2]
			SetDebugLog("Near points: " & String($aTemp[2]), $COLOR_INFO)
			$sRedLineDistance = $aTemp[3]
			SetDebugLog("Near points: " & String($aTemp[3]), $COLOR_INFO)
			Switch String($aTemp[0])
				Case "Mines"
					$offsetx = 3
					$offsety = 12
				Case "Collector"
					$offsetx = -9
					$offsety = 9
				Case "Drill"
					$offsetx = 2
					$offsety = 14
			EndSwitch

			If StringInStr($aObjectpoints, "|") Then
				$aObjectpoints = StringReplace($aObjectpoints, "||", "|")
				$sString = StringRight($aObjectpoints, 1)
				If $sString = "|" Then $aObjectpoints = StringTrimRight($aObjectpoints, 1)
				$tempObbj = StringSplit($aObjectpoints, "|", $STR_NOCOUNT) ; several detected points
				$sNearTemp = StringSplit($sNear, "#", $STR_NOCOUNT) ; several detected 5 near points
				$Distance = StringSplit($sRedLineDistance, "#", $STR_NOCOUNT) ; several detected distances points
				For $i = 0 To UBound($tempObbj) - 1
					; Test the coordinates
					$tempObbjs = StringSplit($tempObbj[$i], ",", $STR_NOCOUNT) ;  will be a string : 708,360
					If UBound($tempObbjs) <> 2 Then ContinueLoop
					; Check double detections
					Local $DetectedPoint[2] = [Number($tempObbjs[0] + $offsetx), Number($tempObbjs[1] + $offsety)]
					If DoublePoint($aTemp[0], $aReturn, $DetectedPoint) Then ContinueLoop
					; Include one more dimension
					ReDim $aReturn[UBound($aReturn) + 1][6]
					$aReturn[UBound($aReturn) - 1][0] = $DetectedPoint[0] ; X
					$aReturn[UBound($aReturn) - 1][1] = $DetectedPoint[1] ; Y
					$aReturn[UBound($aReturn) - 1][4] = Side($tempObbjs)
					$distance2RedLine = $aReturn[UBound($aReturn) - 1][4] = "BL" ? 50 : 45
					;Just in case check if $sNearTemp has $i index to avoid crash
					If $i < UBound($sNearTemp) Then
						$aReturn[UBound($aReturn) - 1][5] = $sNearTemp[$i] <> "" ? $sNearTemp[$i] : "0,0" ; will be a string inside : 708,360|705,358|720,370|705,353|722,371
					Else
						$aReturn[UBound($aReturn) - 1][5] = "0,0"
					EndIf
					;Just in case check if $Distance has $i index to avoid crash
					If $i < UBound($Distance) Then
						$aReturn[UBound($aReturn) - 1][2] = Number($Distance[$i]) > 0 ? Number($Distance[$i]) : 200
					Else
						$aReturn[UBound($aReturn) - 1][2] = 200
					EndIf
					$aReturn[UBound($aReturn) - 1][3] = ($aReturn[UBound($aReturn) - 1][2] > $distance2RedLine) ? ("In") : ("Out") ; > 40 pixels the resource is far away from redline
				Next
			Else
				; Test the coordinate
				$tempObbj = StringSplit($aObjectpoints, ",", $STR_NOCOUNT) ;  will be a string : 708,360
				If UBound($tempObbj) <> 2 Then ContinueLoop
				; Check double detections
				Local $DetectedPoint[2] = [Number($tempObbj[0] + $offsetx), Number($tempObbj[1] + $offsety)]
				If DoublePoint($aTemp[0], $aReturn, $DetectedPoint) Then ContinueLoop
				; Include one more dimension
				ReDim $aReturn[UBound($aReturn) + 1][6]
				$aReturn[UBound($aReturn) - 1][0] = $DetectedPoint[0] ; X
				$aReturn[UBound($aReturn) - 1][1] = $DetectedPoint[1] ; Y
				$aReturn[UBound($aReturn) - 1][4] = Side($tempObbj)
				$distance2RedLine = $aReturn[UBound($aReturn) - 1][4] = "BL" ? 50 : 45
				$aReturn[UBound($aReturn) - 1][5] = $sNear ; will be a string inside : 708,360|705,358|720,370|705,353|722,371
				$aReturn[UBound($aReturn) - 1][2] = Number($sRedLineDistance)
				$aReturn[UBound($aReturn) - 1][3] = ($aReturn[UBound($aReturn) - 1][2] > $distance2RedLine) ? ("In") : ("Out") ; > 40 pixels the resource is far away from redline
			EndIf
		Next
		; End of building loop
		SetDebugLog($txtBuildings & " Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
		Return $aReturn
	Else
		SetLog("ERROR|NONE Building - Detection: " & $txtBuildings, $COLOR_INFO)
	EndIf

EndFunc   ;==>SmartFarmDetection

Func DoublePoint($sName, $aReturn, $aPoint, $iDistance = 18)
	Local $x, $y
	Local $x1 = Number($aPoint[0])
	Local $y1 = Number($aPoint[1])

	For $i = 0 To UBound($aReturn) - 1
		If Not $g_bRunState Then Return
		$x = Number($aReturn[$i][0])
		$y = Number($aReturn[$i][1])
		If Pixel_Distance($x, $y, $x1, $y1) < $iDistance Then
			SetDebugLog("Detected a " & $sName & " double detection at (" & $x & "," & $y & ")")
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>DoublePoint

Func Pixel_Distance($x, $y, $x1, $y1)
	;Pythagoras theorem for 2D
	Local $a, $b, $c
	If $x1 = $x And $y1 = $y Then
		Return 0
	Else
		$a = $y1 - $y
		$b = $x1 - $x
		$c = Sqrt($a * $a + $b * $b)
		Return $c
	EndIf
EndFunc   ;==>Pixel_Distance

Func Side($pixel)
	Local $sReturn = ""
	If IsArray($pixel) And UBound($pixel) = 2 Then
		If $pixel[0] < $DiamondMiddleX And $pixel[1] <= $DiamondMiddleY Then $sReturn = "TL"
		If $pixel[0] >= $DiamondMiddleX And $pixel[1] < $DiamondMiddleY Then $sReturn = "TR"
		If $pixel[0] < $DiamondMiddleX And $pixel[1] > $DiamondMiddleY Then $sReturn = "BL"
		If $pixel[0] >= $DiamondMiddleX And $pixel[1] >= $DiamondMiddleY Then $sReturn = "BR"
		If $sReturn = "" Then
			SetLog("Error on SIDE...: " & _ArrayToString($pixel), $COLOR_RED)
			$sReturn = "ERROR"
		EndIf
		Return $sReturn
	Else
		Setlog("ERROR SIDE|SmartFarm!!", $COLOR_RED)
	EndIf
EndFunc   ;==>Side

Func DebugImageSmartFarm($THdetails, $aIn, $aOut, $sTime, $BestSideToAttack, $redline)

	_CaptureRegion()

	; Store a copy of the image handle
	Local $editedImage = $g_hBitmap
	Local $subDirectory = @ScriptDir & "\SmartFarm\"
	DirCreate($subDirectory)

	; Create the timestamp and filename
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $fileName = "SmartFarm" & "_" & $Date & "_" & $Time & ".png"
	Local $fileNameUntouched = "SmartFarm" & "_" & $Date & "_" & $Time & "_1.png"

	; Needed for editing the picture
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPen = _GDIPlus_PenCreate(0xFFFF0000, 2) ; Create a pencil Color FF0000/RED
	Local $hPen2 = _GDIPlus_PenCreate(0xFF000000, 2) ; Create a pencil Color FFFFFF/BLACK


	; TH
	addInfoToDebugImage($hGraphic, $hPen, "TH_" & $THdetails[0] & "|" & $THdetails[3], $THdetails[1], $THdetails[2])
	_GDIPlus_GraphicsDrawRect($hGraphic, $THdetails[1] - 5, $THdetails[2] - 5, 10, 10, $hPen2)

	$hPen2 = _GDIPlus_PenCreate(0xFFFFFFFF, 2)
	_GDIPlus_GraphicsDrawRect($hGraphic, $DiamondMiddleX - 5, $DiamondMiddleY - 5, 10, 10, $hPen2)
	$hPen2 = _GDIPlus_PenCreate(0xFFFFFFFF, 1)
	_GDIPlus_GraphicsDrawLine($hGraphic, 0, $DiamondMiddleY, 860, $DiamondMiddleY, $hPen2)
	_GDIPlus_GraphicsDrawLine($hGraphic, $DiamondMiddleX, 0, $DiamondMiddleX, 644, $hPen2)
	$hPen2 = _GDIPlus_PenCreate(0xFF000000, 2)
	Local $tempObbj, $tempObbjs
	For $i = 0 To UBound($aIn) - 1
		; Objects Detected Inside the village
		addInfoToDebugImage($hGraphic, $hPen, $aIn[$i][3] & "|" & $aIn[$i][4] & "|" & $aIn[$i][2], $aIn[$i][0], $aIn[$i][1])

		; Deploy points near Red Line
		If StringInStr($aIn[$i][5], "|") Then

			$tempObbj = StringSplit($aIn[$i][5], "|", $STR_NOCOUNT) ; several detected points
			For $t = 0 To UBound($tempObbj) - 1
				$tempObbjs = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
				If UBound($tempObbjs) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbjs[0], $tempObbjs[1], 5, 5, $hPen2)
			Next
		Else
			$tempObbj = StringSplit($aOut[$i][5], ",", $STR_NOCOUNT)
			If UBound($tempObbj) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbj[0], $tempObbj[1], 5, 5, $hPen2)
		EndIf
		$tempObbj = Null
		$tempObbjs = Null
	Next

	For $i = 0 To UBound($aOut) - 1
		; Objects Detected Outside the village
		addInfoToDebugImage($hGraphic, $hPen, $aOut[$i][3] & "|" & $aOut[$i][4] & "|" & $aOut[$i][2], $aOut[$i][0], $aOut[$i][1])

		; Deploy points near Red Line
		If StringInStr($aOut[$i][5], "|") Then
			$tempObbj = StringSplit($aOut[$i][5], "|", $STR_NOCOUNT) ; several detected points
			For $t = 0 To UBound($tempObbj) - 1
				$tempObbjs = StringSplit($tempObbj[$t], ",", $STR_NOCOUNT)
				If UBound($tempObbjs) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbjs[0], $tempObbjs[1], 5, 5, $hPen2)
			Next
		Else
			$tempObbj = StringSplit($aOut[$i][5], ",", $STR_NOCOUNT)
			If UBound($tempObbj) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $tempObbj[0], $tempObbj[1], 5, 5, $hPen2)
		EndIf
		$tempObbj = Null
		$tempObbjs = Null
	Next

	; ############################# Best Side to attack INSIDE ###################################
	If IsArray($g_aGreenTiles) And UBound($g_aGreenTiles) > 0 Then
		$hPen2 = _GDIPlus_PenCreate(0xFF40FF9F, 2)
		For $i = 0 To UBound($g_aGreenTiles) - 1
			_GDIPlus_GraphicsDrawRect($hGraphic, $g_aGreenTiles[$i][0], $g_aGreenTiles[$i][1], 10, 10, $hPen2)
		Next
	EndIf
	Local $aiGreenTilesBySide = GetDiamondGreenTiles()
	If IsArray($aiGreenTilesBySide) And UBound($aiGreenTilesBySide) > 1 Then
		$hPen2 = _GDIPlus_PenCreate(0xFF000000, 2)
		For $i = 0 To 3
			Local $OneSide = $aiGreenTilesBySide[$i]
			If IsArray($OneSide) And UBound($OneSide) > 0 Then
				For $j = 0 To UBound($OneSide) - 1
					_GDIPlus_GraphicsDrawRect($hGraphic, $OneSide[$j][0], $OneSide[$j][1], 15, 15, $hPen2)
				Next
			EndIf
		Next
	EndIf
	$hPen2 = _GDIPlus_PenCreate(0xFF0038ff, 2)
	Local $aTemp, $DecodeEachPoint
	SetDebugLog("$redline: " & _ArrayToString($redline))
	For $l = 0 To UBound($redline) - 1
		$aTemp = StringSplit($redline[$l], "|", 2)
		For $i = 0 To UBound($aTemp) - 1
			$DecodeEachPoint = StringSplit($aTemp[$i], ",", 2)
			If UBound($DecodeEachPoint) > 1 Then _GDIPlus_GraphicsDrawRect($hGraphic, $DecodeEachPoint[0], $DecodeEachPoint[1], 5, 5, $hPen2)
		Next
	Next

	;############################################################################################
	$hPen2 = _GDIPlus_PenCreate(0xFFFF0000, 2)
	Local $aTemp, $DecodeEachPoint
	Local $pixel
	For $i = 0 To UBound($g_aiPixelTopLeft) - 1
		$pixel = $g_aiPixelTopLeft[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelTopRight) - 1
		$pixel = $g_aiPixelTopRight[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomLeft) - 1
		$pixel = $g_aiPixelBottomLeft[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomRight) - 1
		$pixel = $g_aiPixelBottomRight[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	$hPen2 = _GDIPlus_PenCreate(0xFFEE940B, 2)
	For $i = 0 To UBound($g_aiPixelTopLeftFurther) - 1
		$pixel = $g_aiPixelTopLeftFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelTopRightFurther) - 1
		$pixel = $g_aiPixelTopRightFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomLeftFurther) - 1
		$pixel = $g_aiPixelBottomLeftFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	For $i = 0 To UBound($g_aiPixelBottomRightFurther) - 1
		$pixel = $g_aiPixelBottomRightFurther[$i]
		_GDIPlus_GraphicsDrawEllipse($hGraphic, $pixel[0], $pixel[1], 2, 2, $hPen2)
	Next
	_GDIPlus_GraphicsDrawString($hGraphic, $sTime & " - " & $BestSideToAttack, 370, 70, "ARIAL", 20)

	; Save the image and release any memory
	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & $fileName)
	_CaptureRegion()
	_GDIPlus_ImageSaveToFile($g_hBitmap, $subDirectory & $fileNameUntouched)
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_GraphicsDispose($hGraphic)
	Setlog(" » Debug Image saved!")

EndFunc   ;==>DebugImageSmartFarm

Func AttackSmartFarm($Nside, $SIDESNAMES)

	Setlog(" ====== Start Smart Farm Attack ====== ", $COLOR_INFO)

	SetSlotSpecialTroops()

	Local $nbSides = Null
	Local $GiantComp = 0

	_CaptureRegion2() ; ensure full screen is captured (not ideal for debugging as clean image was already saved, but...)
	_GetRedArea()

	Switch $Nside
		Case 1 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on a single side", $COLOR_INFO)
			$nbSides = $Nside
		Case 2 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on two sides", $COLOR_INFO)
			$nbSides = $Nside
		Case 3 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on three sides", $COLOR_INFO)
			$nbSides = $Nside
		Case 4 ;All sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on all sides", $COLOR_INFO)
			$nbSides = $Nside
	EndSwitch

	If Not $g_bRunState Then Return

	$g_iSidesAttack = $nbSides

	; Reset the deploy Giants points , spread along red line
	$g_iSlotsGiants = 0
	; Giants quantities
	For $i = 0 To UBound($g_avAttackTroops) - 1
		If $g_avAttackTroops[$i][0] = $eGiant Then
			$GiantComp = $g_avAttackTroops[$i][1]
		EndIf
	Next

	; Lets select the deploy points according by Giants qunatities & sides
	; Deploy points : 0 - spreads along the red line , 1 - one deploy point .... X - X deploy points
	Switch $GiantComp
		Case 0 To 10
			$g_iSlotsGiants = 2
		Case Else
			Switch $nbSides
				Case 2
					$g_iSlotsGiants = 2
				Case 1
					$g_iSlotsGiants = 4
				Case Else
					$g_iSlotsGiants = 0
			EndSwitch
	EndSwitch

	SetDebugLog("Giants : " & $GiantComp & "  , per side: " & ($GiantComp / $nbSides) & " / deploy points per side: " & $g_iSlotsGiants)

	If $g_bCustomDropOrderEnable Then
		Local $listInfoDeploy[25][5] = [[MatchTroopDropName(0), $nbSides, MatchTroopWaveNb(0), 1, MatchSlotsPerEdge(0)], _
				[MatchTroopDropName(1), $nbSides, MatchTroopWaveNb(1), 1, MatchSlotsPerEdge(1)], _
				[MatchTroopDropName(2), $nbSides, MatchTroopWaveNb(2), 1, MatchSlotsPerEdge(2)], _
				[MatchTroopDropName(3), $nbSides, MatchTroopWaveNb(3), 1, MatchSlotsPerEdge(3)], _
				[MatchTroopDropName(4), $nbSides, MatchTroopWaveNb(4), 1, MatchSlotsPerEdge(4)], _
				[MatchTroopDropName(5), $nbSides, MatchTroopWaveNb(5), 1, MatchSlotsPerEdge(5)], _
				[MatchTroopDropName(6), $nbSides, MatchTroopWaveNb(6), 1, MatchSlotsPerEdge(6)], _
				[MatchTroopDropName(7), $nbSides, MatchTroopWaveNb(7), 1, MatchSlotsPerEdge(7)], _
				[MatchTroopDropName(8), $nbSides, MatchTroopWaveNb(8), 1, MatchSlotsPerEdge(8)], _
				[MatchTroopDropName(9), $nbSides, MatchTroopWaveNb(9), 1, MatchSlotsPerEdge(9)], _
				[MatchTroopDropName(10), $nbSides, MatchTroopWaveNb(10), 1, MatchSlotsPerEdge(10)], _
				[MatchTroopDropName(11), $nbSides, MatchTroopWaveNb(11), 1, MatchSlotsPerEdge(11)], _
				[MatchTroopDropName(12), $nbSides, MatchTroopWaveNb(12), 1, MatchSlotsPerEdge(12)], _
				[MatchTroopDropName(13), $nbSides, MatchTroopWaveNb(13), 1, MatchSlotsPerEdge(13)], _
				[MatchTroopDropName(14), $nbSides, MatchTroopWaveNb(14), 1, MatchSlotsPerEdge(14)], _
				[MatchTroopDropName(15), $nbSides, MatchTroopWaveNb(15), 1, MatchSlotsPerEdge(15)], _
				[MatchTroopDropName(16), $nbSides, MatchTroopWaveNb(16), 1, MatchSlotsPerEdge(16)], _
				[MatchTroopDropName(17), $nbSides, MatchTroopWaveNb(17), 1, MatchSlotsPerEdge(17)], _
				[MatchTroopDropName(18), $nbSides, MatchTroopWaveNb(18), 1, MatchSlotsPerEdge(18)], _
				[MatchTroopDropName(19), $nbSides, MatchTroopWaveNb(19), 1, MatchSlotsPerEdge(19)], _
				[MatchTroopDropName(20), $nbSides, MatchTroopWaveNb(20), 1, MatchSlotsPerEdge(20)], _
				[MatchTroopDropName(21), $nbSides, MatchTroopWaveNb(21), 1, MatchSlotsPerEdge(21)], _
				[MatchTroopDropName(22), $nbSides, MatchTroopWaveNb(22), 1, MatchSlotsPerEdge(22)], _
				[MatchTroopDropName(23), $nbSides, MatchTroopWaveNb(23), 1, MatchSlotsPerEdge(23)], _
				[MatchTroopDropName(24), $nbSides, MatchTroopWaveNb(24), 1, MatchSlotsPerEdge(24)]]
	Else
		Local $listInfoDeploy[32][5] = [[$eGole, $nbSides, 1, 1, 2] _
				, [$eLava, $nbSides, 1, 1, 2] _
				, [$eGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
				, [$eSuperGiant, $nbSides, 1, 1, $g_iSlotsGiants] _
				, [$eDrag, $nbSides, 1, 1, 0] _
				, [$eBall, $nbSides, 1, 1, 0] _
				, [$eBabyD, $nbSides, 1, 1, 0] _
				, [$eInfernoDrag, $nbSides, 1, 1, 0] _
				, [$eHogs, $nbSides, 1, 1, 1] _
				, [$eValk, $nbSides, 1, 1, 0] _
				, [$eBowl, $nbSides, 1, 1, 0] _
				, [$eIceG, $nbSides, 1, 1, 0] _
				, [$eMine, $nbSides, 1, 1, 0] _
				, [$eEDrag, $nbSides, 1, 1, 0] _
				, [$eWall, $nbSides, 1, 1, 1] _
				, [$eSuperWall, $nbSides, 1, 1, 1] _
				, [$eBarb, $nbSides, 1, 1, 0] _
				, [$eSuperBarb, $nbSides, 1, 1, 0] _
				, [$eArch, $nbSides, 1, 1, 0] _
				, [$eSuperArch, $nbSides, 1, 1, 0] _
				, [$eWiza, $nbSides, 1, 1, 0] _
				, [$eMini, $nbSides, 1, 1, 0] _
				, [$eWitc, $nbSides, 1, 1, 1] _
				, [$eSuperWitc, $nbSides, 1, 1, 1] _
				, [$eGobl, $nbSides, 1, 1, 0] _
				, [$eSneakyGobl, $nbSides, 1, 1, 0] _
				, [$eHeal, $nbSides, 1, 1, 1] _
				, [$ePekk, $nbSides, 1, 1, 1] _
				, [$eYeti, $nbSides, 1, 1, 1] _
				, [$eHunt, $nbSides, 1, 1, 0] _
				, ["CC", 1, 1, 1, 1] _
				, ["HEROES", 1, 2, 1, 1] _
				]
	EndIf

	$g_bIsCCDropped = False
	$g_aiDeployCCPosition[0] = -1
	$g_aiDeployCCPosition[1] = -1
	$g_bIsHeroesDropped = False
	$g_aiDeployHeroesPosition[0] = -1
	$g_aiDeployHeroesPosition[1] = -1

	#Region - Drop CC first - Team AIO Mod++ (By Boludoz)
	If (UBound($g_bDeployCastleFirst) > $g_iMatchMode) And $g_bDeployCastleFirst[$g_iMatchMode] Then
		Local $aCC = _ArraySearch($listInfoDeploy, "CC", 0, 0, 0, 0, 0, 0)
		Local $aRem = _ArrayExtract($listInfoDeploy, $aCC, $aCC)
		_ArrayDelete($listInfoDeploy, $aCC)
		_ArrayInsert($listInfoDeploy, 0, $aRem)
	EndIf
	#EndRegion - Drop CC first - Team AIO Mod++ (By Boludoz)

	LaunchTroopSmartFarm($listInfoDeploy, $g_iClanCastleSlot, $g_iKingSlot, $g_iQueenSlot, $g_iWardenSlot, $g_iChampionSlot, $SIDESNAMES)
	If Not $g_bRunState Then Return
	CheckHeroesHealth()
	If _Sleep($DELAYALGORITHM_ALLTROOPS4) Then Return
	If PrepareAttack($g_iMatchMode, True) <> 0 Then
		SetLog("Dropping left over Troops", $COLOR_INFO)
		For $i = $eBarb To $eArmyCount - 1 ; launch all remaining troops
			If ($i >= $eSuperBarb And $i <= $eArmyCount - 1) Or ($i >= $eBarb And $i <= $eTroopCount - 1) Then
				If LaunchTroop($i, $nbSides, 1, 1, 1) Then
					CheckHeroesHealth()
					If _Sleep($DELAYALGORITHM_ALLTROOPS5) Then Return
				EndIf
			EndIf
		Next
		Local $iKingSlot = Not $g_bDropKing ? $g_iKingSlot : -1
		Local $iQueenSlot = Not $g_bDropQueen ? $g_iQueenSlot : -1
		Local $iWardenSlot = Not $g_bDropWarden ? $g_iWardenSlot : -1
		Local $iChampionSlot = Not $g_bDropChampion ? $g_iChampionSlot : -1
		If $iKingSlot <> -1 Or $iQueenSlot <> -1 Or $iWardenSlot <> -1 Or $iChampionSlot <> -1 Then
			SetLog("Dropping left over heroes", $COLOR_INFO)
			Local $HeroesInfoDeploy[1][5] = [["HEROES", 1, 2, 1, 1]]
			LaunchTroopSmartFarm($HeroesInfoDeploy, $g_iClanCastleSlot, $iKingSlot, $iQueenSlot, $iWardenSlot, $iChampionSlot, $SIDESNAMES)
			CheckHeroesHealth()
		EndIf
	EndIf
	CheckHeroesHealth()
	SetLog("Finished Attacking, waiting for the battle to end")
EndFunc   ;==>AttackSmartFarm

Func LaunchTroopSmartFarm($listInfoDeploy, $iCC, $iKing, $iQueen, $iWarden, $iChampion, $SIDESNAMES = "TR|TL|BR|BL")
	If $g_bDebugSetlog Then SetDebugLog("LaunchTroopSmartFarm with CC " & $iCC & ", K " & $iKing & ", Q " & $iQueen & ", W " & $iWarden & ", C " & $iChampion, $COLOR_DEBUG)
	Local $listListInfoDeployTroopPixel[0]
	Local $pixelRandomDrop[2]
	Local $pixelRandomDropcc[2]
	Local $troop, $troopNb, $name

	Local $iHowManySides = 0
	Local $aWhatSides = StringSplit($SIDESNAMES, "|", $STR_NOCOUNT)
	If @error Then
		$iHowManySides = 1
	Else
		$iHowManySides = UBound($aWhatSides)
	EndIf
	For $i = 0 To UBound($listInfoDeploy) - 1
		; Reset the variables
		Local $troop = -1
		Local $troopNb = 0
		Local $name = ""
		; Fill the variables from List
		Local $troopKind = $listInfoDeploy[$i][0] ; Type
		Local $nbSides = $listInfoDeploy[$i][1] ; Number of Sides
		Local $waveNb = $listInfoDeploy[$i][2] ; waves
		Local $maxWaveNb = $listInfoDeploy[$i][3] ; Max waves
		Local $slotsPerEdge = $listInfoDeploy[$i][4] ; deploy Points per Edge
		If $g_bDebugSetlog Then SetDebugLog("**ListInfoDeploy row " & $i & ": USE " & GetTroopName($troopKind, 0) & " SIDES " & $nbSides & " WAVE " & $waveNb & " XWAVE " & $maxWaveNb & " SLOTXEDGE " & $slotsPerEdge, $COLOR_DEBUG)

		; Regular Troops , not Heroes or Castle
		If (IsNumber($troopKind)) Then
			For $j = 0 To UBound($g_avAttackTroops) - 1 ; identify the position of this kind of troop
				If $g_avAttackTroops[$j][0] = $troopKind Then
					$troop = $j
					$troopNb = Ceiling($g_avAttackTroops[$j][1] / $maxWaveNb)
					Local $Plural = 0
					If $troopNb > 1 Then $Plural = 1
					$name = GetTroopName($troopKind, $Plural)
				EndIf
			Next
		EndIf

		If ($troop <> -1 And $troopNb > 0) Or IsString($troopKind) Then
			Local $listInfoDeployTroopPixel
			If (UBound($listListInfoDeployTroopPixel) < $waveNb) Then
				ReDim $listListInfoDeployTroopPixel[$waveNb]
				Local $newListInfoDeployTroopPixel[0]
				$listListInfoDeployTroopPixel[$waveNb - 1] = $newListInfoDeployTroopPixel
			EndIf
			$listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$waveNb - 1]

			ReDim $listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) + 1]
			If (IsString($troopKind)) Then
				Local $arrCCorHeroes[1] = [$troopKind]
				$listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) - 1] = $arrCCorHeroes
			Else
				Local $infoDropTroop = DropTroopSmartFarm($troop, $nbSides, $troopNb, $slotsPerEdge, $name, $SIDESNAMES)
				$listInfoDeployTroopPixel[UBound($listInfoDeployTroopPixel) - 1] = $infoDropTroop
			EndIf
			$listListInfoDeployTroopPixel[$waveNb - 1] = $listInfoDeployTroopPixel
		EndIf
	Next

	Local $numberSidesDropTroop = 1

	; Drop a full wave of all troops (e.g. giants, barbs and archers) on each side then switch sides.
	For $numWave = 0 To UBound($listListInfoDeployTroopPixel) - 1
		Local $listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$numWave]
		If (UBound($listInfoDeployTroopPixel) > 0) Then
			Local $infoTroopListArrPixel = $listInfoDeployTroopPixel[0]
			For $i = 0 To UBound($listInfoDeployTroopPixel) - 1
				$infoTroopListArrPixel = $listInfoDeployTroopPixel[$i]
				If (UBound($infoTroopListArrPixel) > 1) Then
					Local $infoListArrPixel = $infoTroopListArrPixel[1]
					$numberSidesDropTroop = UBound($infoListArrPixel)
					ExitLoop
				EndIf
			Next
			If ($numberSidesDropTroop > 0) Then
				For $i = 0 To $numberSidesDropTroop - 1
					Local $sSide = ""
					For $j = 0 To UBound($listInfoDeployTroopPixel) - 1
						$infoTroopListArrPixel = $listInfoDeployTroopPixel[$j]
						If (IsString($infoTroopListArrPixel[0]) And ($infoTroopListArrPixel[0] = "CC" Or $infoTroopListArrPixel[0] = "HEROES")) Then
							SetDebugLog("Wave " & $numWave & " Side " & $i + 1 & "/" & $numberSidesDropTroop & " Dropping a CC & Heroes at troop loop " & $j & "/" & (UBound($listInfoDeployTroopPixel) - 1))
							If $g_aiDeployHeroesPosition[0] <> -1 Then
								$pixelRandomDrop[0] = $g_aiDeployHeroesPosition[0]
								$pixelRandomDrop[1] = $g_aiDeployHeroesPosition[1]
								If $g_bDebugSetlog Then SetDebugLog("Deploy Heroes $g_aiDeployHeroesPosition")
							Else
								$pixelRandomDrop[0] = $g_aaiBottomRightDropPoints[2][0]
								$pixelRandomDrop[1] = $g_aaiBottomRightDropPoints[2][1]
								If $g_bDebugSetlog Then SetDebugLog("Deploy Heroes $g_aaiBottomRightDropPoints")
							EndIf
							If $g_aiDeployCCPosition[0] <> -1 Then
								$pixelRandomDropcc[0] = $g_aiDeployCCPosition[0]
								$pixelRandomDropcc[1] = $g_aiDeployCCPosition[1]
								If $g_bDebugSetlog Then SetDebugLog("Deploy CC $g_aiDeployHeroesPosition")
							Else
								$pixelRandomDropcc[0] = $g_aaiBottomRightDropPoints[2][0]
								$pixelRandomDropcc[1] = $g_aaiBottomRightDropPoints[2][1]
								If $g_bDebugSetlog Then SetDebugLog("Deploy CC $g_aaiBottomRightDropPoints")
							EndIf
							If ($g_bIsCCDropped = False And $infoTroopListArrPixel[0] = "CC" And $i = $numberSidesDropTroop - 1) Then
								$sSide = Side($pixelRandomDropcc)
								SetLog("Dropping CC at " & $sSide & " - " & _ArrayToString($pixelRandomDrop), $COLOR_SUCCESS)
								dropCC($pixelRandomDropcc[0], $pixelRandomDropcc[1], $iCC)
								$g_bIsCCDropped = True
							ElseIf ($g_bIsHeroesDropped = False And $infoTroopListArrPixel[0] = "HEROES" And $i = $numberSidesDropTroop - 1) Then
								$sSide = Side($pixelRandomDrop)
								SetLog("Dropping Hero at " & $sSide & " - " & _ArrayToString($pixelRandomDrop), $COLOR_SUCCESS)
								dropHeroes($pixelRandomDrop[0], $pixelRandomDrop[1], $iKing, $iQueen, $iWarden, $iChampion)
								$g_bIsHeroesDropped = True
							EndIf
						Else
							$infoListArrPixel = $infoTroopListArrPixel[1]
							Local $listPixel = $infoListArrPixel[$i]
							Local $pixelDropTroop[1] = [$listPixel]
							Local $arrPixel = $pixelDropTroop[0]
							Local $index = Ceiling(UBound($arrPixel) / 2) <= UBound($arrPixel) - 1 ? Ceiling(UBound($arrPixel) / 2) : 0
							Local $currentPixel = $arrPixel[$index]
							$sSide = Side($currentPixel)
							SetDebugLog($index & " - Deploy Point check " & _ArrayToString($currentPixel) & " side: " & $sSide)
							SetDebugLog(UBound($arrPixel) & " deploy point(s) at " & $sSide, $COLOR_DEBUG)
							If _Sleep($DELAYLAUNCHTROOP21) Then Return
							SelectDropTroop($infoTroopListArrPixel[0])
							If _Sleep($DELAYLAUNCHTROOP23) Then Return
							SetLog("Dropping " & $infoTroopListArrPixel[2] & " " & $infoTroopListArrPixel[5] & ", Points Per Side: " & $infoTroopListArrPixel[3] & " - ('" & $i + 1 & "' Name: " & $sSide & ")", $COLOR_SUCCESS)
							Local $LastSide = ($i = $numberSidesDropTroop - 1) ? True : False
							Local $Clicked = DropOnPixel($infoTroopListArrPixel[0], $pixelDropTroop, $infoTroopListArrPixel[2], $infoTroopListArrPixel[3], True, $LastSide)
							$g_avAttackTroops[$infoTroopListArrPixel[0]][1] -= $Clicked
							If ($numberSidesDropTroop = 1) Or ($i = $numberSidesDropTroop - 2) Then
								SetLog($infoTroopListArrPixel[5] & " Next side with " & $g_avAttackTroops[$infoTroopListArrPixel[0]][1] & "x", $COLOR_SUCCESS)
								$infoTroopListArrPixel[2] = $g_avAttackTroops[$infoTroopListArrPixel[0]][1]
								$listInfoDeployTroopPixel[$j] = $infoTroopListArrPixel
								$listListInfoDeployTroopPixel[$numWave] = $listInfoDeployTroopPixel
							Else
								If $g_avAttackTroops[$infoTroopListArrPixel[0]][1] > 0 Then SetLog($infoTroopListArrPixel[5] & " Remain quantities " & $g_avAttackTroops[$infoTroopListArrPixel[0]][1] & "x", $COLOR_SUCCESS)
							EndIf
						EndIf
						If ($g_bIsHeroesDropped) Then
							If _sleep(1000) Then Return ; delay Queen Image  has to be at maximum size : CheckHeroesHealth checks the y = 573
							CheckHeroesHealth()
						EndIf
					Next
					If _Sleep(SetSleep(0)) Then Return
				Next
			EndIf
		EndIf
		If _Sleep(SetSleep(1)) Then Return
	Next

	For $numWave = 0 To UBound($listListInfoDeployTroopPixel) - 1
		Local $listInfoDeployTroopPixel = $listListInfoDeployTroopPixel[$numWave]
		For $i = 0 To UBound($listInfoDeployTroopPixel) - 1
			Local $infoPixelDropTroop = $listInfoDeployTroopPixel[$i]
			If Not (IsString($infoPixelDropTroop[0]) And ($infoPixelDropTroop[0] = "CC" Or $infoPixelDropTroop[0] = "HEROES")) Then
				Local $numberLeft = ReadTroopQuantity($infoPixelDropTroop[0])
				If $g_bDebugSetlog Then
					Local $aiSlotPos = GetSlotPosition($infoDropTroop[0])
					SetDebugLog("Slot Nun= " & $infoPixelDropTroop[0])
					SetDebugLog("Slot Xaxis= " & $aiSlotPos[0])
					SetDebugLog($infoPixelDropTroop[5] & " - NumberLeft : " & $numberLeft)
				EndIf
				If ($numberLeft > 0) Then
					If _Sleep($DELAYLAUNCHTROOP21) Then Return
					SelectDropTroop($infoPixelDropTroop[0]) ;Select Troop
					If _Sleep($DELAYLAUNCHTROOP23) Then Return
					SetLog("Dropping last " & $numberLeft & "  of " & $infoPixelDropTroop[5], $COLOR_SUCCESS)
					;                     $troop,             $listArrPixel,       $number,      $slotsPerEdge = 0
					DropOnPixel($infoPixelDropTroop[0], $infoPixelDropTroop[1], Ceiling($numberLeft), $infoPixelDropTroop[3])
				EndIf
			EndIf
			If _Sleep(SetSleep(0)) Then Return
		Next
		If _Sleep(SetSleep(1)) Then Return
	Next
EndFunc   ;==>LaunchTroopSmartFarm

Func DropTroopSmartFarm($troop, $nbSides, $number, $slotsPerEdge = 0, $name = "", $SIDESNAMES = "TR|TL|BR|BL")
	Local $listInfoPixelDropTroop[0]
	If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = Ceiling($number / $nbSides)
	If $nbSides < 1 Then Return
	Local $nbTroopsLeft = $number
	Local $nbTroopsPerEdge = Round($nbTroopsLeft / $nbSides)
	If ($number > 0 And $nbTroopsPerEdge = 0) Then $nbTroopsPerEdge = 1
	If $g_bDebugSmartFarm Then SetLog(" - " & $name & " Number: " & $number & " Sides: " & $nbSides & " SlotsPerEdge: " & $slotsPerEdge)
	If $nbSides = 4 Then
		ReDim $listInfoPixelDropTroop[4]
		$listInfoPixelDropTroop = GetPixelDropTroop($troop, $number, $slotsPerEdge)
	Else
		Local $TEMPlistInfoPixelDropTroop = GetPixelDropTroop($troop, $nbTroopsPerEdge, $slotsPerEdge)
		If StringInStr($SIDESNAMES, "|") <> 0 Then
			Local $iTempSides = StringSplit($SIDESNAMES, "|", $STR_NOCOUNT)
			SetDebugLog("Original $g_sRandomSidesNames: " & _ArrayToString($g_sRandomSidesNames))
			SetDebugLog("Original $iTempSides: " & _ArrayToString($iTempSides))
			For $x = 0 To UBound($g_sRandomSidesNames) - 1
				For $i = 0 To UBound($iTempSides) - 1
					If $g_sRandomSidesNames[$x] = $iTempSides[$i] Then
						If $g_bDebugSetlog Then SetDebugLog("$iTempSides[" & $i & "] : " & $iTempSides & " $g_sRandomSidesNames[" & $x & "]: " & $g_sRandomSidesNames[$x])
						ReDim $listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) + 1]
						$listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) - 1] = $TEMPlistInfoPixelDropTroop[$x]
						ExitLoop
					EndIf
				Next
			Next
		Else
			ReDim $listInfoPixelDropTroop[1]
			SetDebugLog("Original $g_sRandomSidesNames: " & _ArrayToString($g_sRandomSidesNames))
			SetDebugLog("Original $SIDESNAMES: " & $SIDESNAMES)
			For $x = 0 To UBound($g_sRandomSidesNames) - 1
				If $SIDESNAMES = $g_sRandomSidesNames[$x] Then
					If $g_bDebugSetlog Then SetDebugLog("$SIDESNAMES : " & $SIDESNAMES & " $g_sRandomSidesNames[" & $x & "]: " & $g_sRandomSidesNames[$x])
					$listInfoPixelDropTroop[0] = $TEMPlistInfoPixelDropTroop[$x]
				EndIf
			Next
		EndIf
	EndIf
	Local $infoDropTroop[6] = [$troop, $listInfoPixelDropTroop, $nbTroopsPerEdge, $slotsPerEdge, $number, $name]
	Return $infoDropTroop
EndFunc   ;==>DropTroopSmartFarm

Func GetDiamondGreenTiles($HnowManyPoints = 10)
	$g_aGreenTiles = -1
	Local $aTmp = DMDecodeCoords(DFind(@ScriptDir & "\COCBot\Team__AiO__MOD++\Bundles\Image Matching\DPSM\", 19, 74, 805, 518, 0, 1000, 9999, True), 15)
	$g_aGreenTiles = IsArray($aTmp) ? ($aTmp) : (-1)
	If Not IsArray($g_aGreenTiles) Or UBound($g_aGreenTiles) < 0 Then Return -1
	Local $TL[0][3], $BL[0][3], $TR[0][3], $BR[0][3]
	Local $aCentre = [$DiamondMiddleX, $DiamondMiddleY]
	_ArraySort($g_aGreenTiles, 0, 0, 0, 1)
	For $each = 0 To UBound($g_aGreenTiles) - 1
		Local $Coordinate = [$g_aGreenTiles[$each][0], $g_aGreenTiles[$each][1]]
		If not IsInsideDiamond($Coordinate) Then ContinueLoop
		If Side($Coordinate) = "TL" Then
			ReDim $TL[UBound($TL) + 1][3]
			$TL[UBound($TL) - 1][0] = $Coordinate[0]
			$TL[UBound($TL) - 1][1] = $Coordinate[1]
			$TL[UBound($TL) - 1][2] = Int(Pixel_Distance($aCentre[0], $aCentre[1], $Coordinate[0], $Coordinate[1]))
		EndIf
		If Side($Coordinate) = "BL" Then
			ReDim $BL[UBound($BL) + 1][3]
			$BL[UBound($BL) - 1][0] = $Coordinate[0]
			$BL[UBound($BL) - 1][1] = $Coordinate[1]
			$BL[UBound($BL) - 1][2] = Int(Pixel_Distance($aCentre[0], $aCentre[1], $Coordinate[0], $Coordinate[1]))
		EndIf
		If Side($Coordinate) = "TR" Then
			ReDim $TR[UBound($TR) + 1][3]
			$TR[UBound($TR) - 1][0] = $Coordinate[0]
			$TR[UBound($TR) - 1][1] = $Coordinate[1]
			$TR[UBound($TR) - 1][2] = Int(Pixel_Distance($aCentre[0], $aCentre[1], $Coordinate[0], $Coordinate[1]))
		EndIf
		If Side($Coordinate) = "BR" Then
			ReDim $BR[UBound($BR) + 1][3]
			$BR[UBound($BR) - 1][0] = $Coordinate[0]
			$BR[UBound($BR) - 1][1] = $Coordinate[1]
			$BR[UBound($BR) - 1][2] = Int(Pixel_Distance($aCentre[0], $aCentre[1], $Coordinate[0], $Coordinate[1]))
		EndIf
	Next
	SetDebugLog("GreenTiles at TL are " & UBound($TL))
	SetDebugLog("GreenTiles at BL are " & UBound($BL))
	SetDebugLog("GreenTiles at TR are " & UBound($TR))
	SetDebugLog("GreenTiles at BR are " & UBound($BR))
	Local $AllSides[4] = [$TL, $BL, $TR, $BR]
	Local $aiGreenTilesBySide[4]
	Local $SIDESNAMES[4] = ["TL", "BL", "TR", "BR"]
	Local $oNumberOfDeployPoints = $HnowManyPoints
	For $iAllSides = 0 To 3
		Local $OneSide = $AllSides[$iAllSides]
		_ArraySort($OneSide, 0, 0, 0, 2)
		Local $OneFinalSide[0][2]
		SetDebugLog(" --- Side " & $SIDESNAMES[$iAllSides] & " --- ")
		For $i = 0 To $oNumberOfDeployPoints - 1
			If $i < UBound($OneSide) Then
				ReDim $OneFinalSide[UBound($OneFinalSide) + 1][2]
				$OneFinalSide[UBound($OneFinalSide) - 1][0] = $OneSide[$i][0]
				$OneFinalSide[UBound($OneFinalSide) - 1][1] = $OneSide[$i][1]
			EndIf
		Next
		_ArraySort($OneFinalSide, 0)
		$aiGreenTilesBySide[$iAllSides] = $OneFinalSide
		SetDebugLog("Final GreenTiles at " & $SIDESNAMES[$iAllSides] & ": " & _ArrayToString($OneFinalSide, ",", -1, -1, "|"))
	Next
	Return $aiGreenTilesBySide
EndFunc   ;==>GetDiamondGreenTiles

Func NewRedLines()
	; Reset
	Local $aLocalReset[0]
	$g_aiPixelTopLeftFurther = $aLocalReset
	$g_aiPixelTopLeft = $aLocalReset
	$g_aiPixelBottomLeftFurther = $aLocalReset
	$g_aiPixelBottomLeft = $aLocalReset
	$g_aiPixelTopRightFurther = $aLocalReset
	$g_aiPixelTopRight = $aLocalReset
	$g_aiPixelBottomRightFurther = $aLocalReset
	$g_aiPixelBottomRight = $aLocalReset

	Local $aiGreenTilesBySide = GetDiamondGreenTiles(20)
	Local $offsetArcher = 15
	Local $OldCode = False
	Local $More
	SetDebugLog("TL using Green Tiles")
	If IsArray($aiGreenTilesBySide) Then
	  $More = $aiGreenTilesBySide[0]
    EndIf
	If IsArray($aiGreenTilesBySide) And IsArray($More) And UBound($More) > 10 Then
		For $x = 0 To UBound($More) - 1
			Local $Coordinate[2] = [$More[$x][0], $More[$x][1]]
			ReDim $g_aiPixelTopLeft[UBound($g_aiPixelTopLeft) + 1]
			$g_aiPixelTopLeft[UBound($g_aiPixelTopLeft) - 1] = $Coordinate
		Next
		$g_aiPixelTopLeftFurther = $g_aiPixelTopLeft
	Else
		If Not $OldCode Then SearchRedLinesMultipleTimes()
		If $g_bDebugAndroid Then
			SetDebugLog("Using External Vector, doesn't have Green Tiles for TL")
			SetDebugLog("IsArray($aiGreenTilesBySide): " & IsArray($aiGreenTilesBySide))
			SetDebugLog("IsArray($More): " & IsArray($More))
			SetDebugLog("UBound($More): " & UBound($More))
		EndIf
		SetLog("TL using Red Lines to deploy")
		Local $TL = GetOffsetRedline("TL", 5)
		$g_aiPixelTopLeft = GetListPixel($TL, ",")
		CleanRedArea($g_aiPixelTopLeft)
		$OldCode = True
		ReDim $g_aiPixelTopLeftFurther[UBound($g_aiPixelTopLeft)]
		For $i = 0 To UBound($g_aiPixelTopLeft) - 1
			$g_aiPixelTopLeftFurther[$i] = _GetOffsetTroopFurther($g_aiPixelTopLeft[$i], $eVectorLeftTop, $offsetArcher)
		Next
	EndIf
	If UBound($g_aiPixelTopLeft) < 10 Then
		SetLog("TL using Edges to deploy")
		$g_aiPixelTopLeft = _GetVectorOutZone($eVectorLeftTop)
		$g_aiPixelTopLeftFurther = $g_aiPixelTopLeft
	EndIf
	SetDebugLog("BL using Green Tiles")
	If IsArray($aiGreenTilesBySide) Then
	  $More = $aiGreenTilesBySide[1]
    EndIf

	If IsArray($aiGreenTilesBySide) And IsArray($More) And UBound($More) > 10 Then
		For $x = 0 To UBound($More) - 1
			Local $Coordinate[2] = [$More[$x][0], $More[$x][1]]
			ReDim $g_aiPixelBottomLeft[UBound($g_aiPixelBottomLeft) + 1]
			$g_aiPixelBottomLeft[UBound($g_aiPixelBottomLeft) - 1] = $Coordinate
		Next
		$g_aiPixelBottomLeftFurther = $g_aiPixelBottomLeft
	Else
		If Not $OldCode Then SearchRedLinesMultipleTimes()
		If $g_bDebugAndroid Then
			SetDebugLog("Using External Vector, doesn't have Green Tiles for BL")
			SetDebugLog("IsArray($aiGreenTilesBySide): " & IsArray($aiGreenTilesBySide))
			SetDebugLog("IsArray($More): " & IsArray($More))
			SetDebugLog("UBound($More): " & UBound($More))
		EndIf
		SetLog("BL using Red Lines to deploy")
		Local $BL = GetOffsetRedline("BL", 5)
		$g_aiPixelBottomLeft = GetListPixel($BL, ",")
		CleanRedArea($g_aiPixelBottomLeft)
		$OldCode = True
		ReDim $g_aiPixelBottomLeftFurther[UBound($g_aiPixelBottomLeft)]
		For $i = 0 To UBound($g_aiPixelBottomLeft) - 1
			$g_aiPixelBottomLeftFurther[$i] = _GetOffsetTroopFurther($g_aiPixelBottomLeft[$i], $eVectorLeftBottom, $offsetArcher)
		Next
	EndIf
	If UBound($g_aiPixelBottomLeft) < 10 Then
		SetLog("BL using Edges to deploy")
		$g_aiPixelBottomLeft = _GetVectorOutZone($eVectorLeftBottom)
		$g_aiPixelBottomLeftFurther = $g_aiPixelBottomLeft
	EndIf
	SetDebugLog("TR using Green Tiles")
	If IsArray($aiGreenTilesBySide) Then
	  $More = $aiGreenTilesBySide[2]
    EndIf

	If IsArray($aiGreenTilesBySide) And IsArray($More) And UBound($More) > 10 Then
		For $x = 0 To UBound($More) - 1
			Local $Coordinate[2] = [$More[$x][0], $More[$x][1]]
			ReDim $g_aiPixelTopRight[UBound($g_aiPixelTopRight) + 1]
			$g_aiPixelTopRight[UBound($g_aiPixelTopRight) - 1] = $Coordinate
		Next
		$g_aiPixelTopRightFurther = $g_aiPixelTopRight
	Else
		If Not $OldCode Then SearchRedLinesMultipleTimes()
		If $g_bDebugAndroid Then
			SetDebugLog("Using External Vector, doesn't have Green Tiles for TR")
			SetDebugLog("IsArray($aiGreenTilesBySide): " & IsArray($aiGreenTilesBySide))
			SetDebugLog("IsArray($More): " & IsArray($More))
			SetDebugLog("UBound($More): " & UBound($More))
		EndIf
		SetLog("TR using Red Lines to deploy")
		Local $TR = GetOffsetRedline("TR", 5)
		$g_aiPixelTopRight = GetListPixel($TR, ",")
		CleanRedArea($g_aiPixelTopRight)
		$OldCode = True
		ReDim $g_aiPixelTopRightFurther[UBound($g_aiPixelTopRight)]
		For $i = 0 To UBound($g_aiPixelTopRight) - 1
			$g_aiPixelTopRightFurther[$i] = _GetOffsetTroopFurther($g_aiPixelTopRight[$i], $eVectorRightTop, $offsetArcher)
		Next
	EndIf
	If UBound($g_aiPixelTopRight) < 10 Then
		SetLog("TR using Edges to deploy")
		$g_aiPixelTopRight = _GetVectorOutZone($eVectorRightTop)
		$g_aiPixelTopRightFurther = $g_aiPixelTopRight
	EndIf
	SetDebugLog("BR using Green Tiles")
	If IsArray($aiGreenTilesBySide) Then
	  $More = $aiGreenTilesBySide[3]
    EndIf

	If IsArray($aiGreenTilesBySide) And IsArray($More) And UBound($More) > 10 Then
		For $x = 0 To UBound($More) - 1
			Local $Coordinate[2] = [$More[$x][0], $More[$x][1]]
			ReDim $g_aiPixelBottomRight[UBound($g_aiPixelBottomRight) + 1]
			$g_aiPixelBottomRight[UBound($g_aiPixelBottomRight) - 1] = $Coordinate
		Next
		$g_aiPixelBottomRightFurther = $g_aiPixelBottomRight
	Else
		If Not $OldCode Then SearchRedLinesMultipleTimes()
		If $g_bDebugAndroid Then
			SetDebugLog("Using External Vector, doesn't have Green Tiles for BR")
			SetDebugLog("IsArray($aiGreenTilesBySide): " & IsArray($aiGreenTilesBySide))
			SetDebugLog("IsArray($More): " & IsArray($More))
			SetDebugLog("UBound($More): " & UBound($More))
		EndIf
		SetLog("BR using Red Lines to deploy")
		Local $BR = GetOffsetRedline("BR", 5)
		$g_aiPixelBottomRight = GetListPixel($BR, ",")
		CleanRedArea($g_aiPixelBottomRight)
		$OldCode = True
		ReDim $g_aiPixelBottomRightFurther[UBound($g_aiPixelBottomRight)]
		For $i = 0 To UBound($g_aiPixelBottomRight) - 1
			$g_aiPixelBottomRightFurther[$i] = _GetOffsetTroopFurther($g_aiPixelBottomRight[$i], $eVectorRightBottom, $offsetArcher)
		Next
	EndIf
	If UBound($g_aiPixelBottomRight) < 10 Then
		SetLog("BR using Edges to deploy")
		$g_aiPixelBottomRight = _GetVectorOutZone($eVectorRightBottom)
		$g_aiPixelBottomRightFurther = $g_aiPixelBottomRight
	EndIf
EndFunc   ;==>NewRedLines

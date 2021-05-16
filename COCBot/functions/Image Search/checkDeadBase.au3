; #FUNCTION# ====================================================================================================================
; Name ..........: checkDeadBase
; Description ...: This file Includes the Variables and functions to detection of a DeadBase.
;                  is full or semi-full to indicate that it is a dead base
; Syntax ........: checkDeadBase() , ZombieSearch()
; Parameters ....: None
; Return values .: True if it is, returns false if it is not a dead base
; Author ........:  AtoZ , DinoBot (01-2015)
; Modified ......: CodeSlinger69 (01-2017), Team AIO Mod++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func hasElixirStorage($bForceCapture = False)

	Local $has = False

	Local $result = findMultiple($g_sImgElixirStorage, "ECD", $g_sImglocRedline, 0, 1000, 0, "objectname,objectpoints,objectlevel", $bForceCapture)

	If IsArray($result) Then
		For $matchedValues In $result
			Local $aPoints = StringSplit($matchedValues[1], "|", $STR_NOCOUNT) ; multiple points splited by | char
			Local $found = UBound($aPoints)
			If $found > 0 Then
				$has = True
				ExitLoop
			EndIf
		Next
	EndIf

	Return $has

EndFunc   ;==>hasElixirStorage

Func setZombie($RaidedElixir = -1, $AvailableElixir = -1, $Matched = -1, $SearchIdx = -1, $redline = "", $Timestamp = @YEAR & "-" & @MON & "-" & @MDAY & "_" & StringReplace(_NowTime(5), ":", "-"))
	If TestCapture() Then Return ""
	If $RaidedElixir = -1 And $AvailableElixir = -1 And $Matched = -1 And $SearchIdx = -1 Then
		$g_aZombie[0] = ""
		$g_aZombie[1] = 0
		$g_aZombie[2] = 0
		$g_aZombie[3] = 0
		$g_aZombie[4] = 0
		$g_aZombie[5] = ""
		$g_aZombie[6] = ""
	Else
		If $RaidedElixir >= 0 Then $g_aZombie[1] = Number($RaidedElixir)
		If $AvailableElixir >= 0 Then $g_aZombie[2] = Number($AvailableElixir)
		If $Matched >= 0 Then $g_aZombie[3] = Number($Matched)
		If $SearchIdx >= 0 Then $g_aZombie[4] = Number($SearchIdx)
		If $g_aZombie[5] = "" Then $g_aZombie[5] = $Timestamp
		If $g_aZombie[6] = "" Then $g_aZombie[6] = $redline
		Local $dbFound = $g_aZombie[3] >= $g_iCollectorMatchesMin
		Local $path = $g_sProfileTempDebugPath & (($dbFound) ? ("Zombies\") : ("SkippedZombies\"))
		Local $availK = Round($g_aZombie[2] / 1000)
		; $ZombieFilename = "DebugDB_xxx%_" & $g_sProfileCurrentName & @YEAR & "-" & @MON & "-" & @MDAY & "_" & StringReplace(_NowTime(5), ":", "-") & "_search_" & StringFormat("%03i", $g_iSearchCount) & "_" & StringFormat("%04i", Round($g_iSearchElixir / 1000)) & "k_matched_" & $TotalMatched
		If $g_aZombie[0] = "" And $g_aZombie[4] > 0 Then
			Local $create = $g_aZombie[0] = "" And ($dbFound = True Or ($g_aZombie[8] = -1 And $g_aZombie[9] = -1) Or ($availK >= $g_aZombie[8] And hasElixirStorage() = False) Or $availK >= $g_aZombie[9])
			If $create = True Then
				Local $ZombieFilename = "DebugDB_" & StringFormat("%04i", $availK) & "k_" & $g_sProfileCurrentName & "_search_" & StringFormat("%03i", $g_aZombie[4]) & "_matched_" & $g_aZombie[3] & "_" & $g_aZombie[5] & ".png"
				SetDebugLog("Saving enemy village screenshot for deadbase validation: " & $ZombieFilename)
				SetDebugLog("Redline was: " & $g_aZombie[6])
				$g_aZombie[0] = $ZombieFilename
				Local $g_hBitmapZombie = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
				_GDIPlus_ImageSaveToFile($g_hBitmapZombie, $path & $g_aZombie[0])
				_GDIPlus_BitmapDispose($g_hBitmapZombie)
			EndIf
		ElseIf $g_aZombie[0] <> "" Then
			Local $raidPct = 0
			If $g_aZombie[2] > 0 And $g_aZombie[2] >= $g_aZombie[1] Then
				$raidPct = Round((100 * $g_aZombie[1]) / $g_aZombie[2])
			EndIf
			If $g_aZombie[7] <> -1 And $raidPct >= $g_aZombie[7] And ($g_aZombie[10] = -1 Or $g_aZombie[2] >= $g_aZombie[10]) Then
				SetDebugLog("Delete enemy village screenshot as base seems dead: " & $g_aZombie[0])
				FileDelete($path & $g_aZombie[0])
			Else
				Local $ZombieFilename = "DebugDB_" & StringFormat("%03i", $raidPct) & "%_" & $g_sProfileCurrentName & "_search_" & StringFormat("%03i", $g_aZombie[4]) & "_matched_" & $g_aZombie[3] & "_" & StringFormat("%04i", $availK) & "k_" & StringFormat("%04i", Round($g_aZombie[1] / 1000)) & "k_" & $g_aZombie[5] & ".png"
				SetDebugLog("Rename enemy village screenshot as base seems live: " & $ZombieFilename)
				FileMove($path & $g_aZombie[0], $path & $ZombieFilename)
			EndIf
			; clear zombie
			setZombie()
		Else
			; clear zombie
			setZombie()
		EndIf
	EndIf
	Return $g_aZombie[0]
EndFunc   ;==>setZombie

Func GetCollectorIndexByFillLevel($level)
	If Number($level) >= 85 Then Return 1
	Return 0
EndFunc   ;==>GetCollectorIndexByFillLevel

#Region - Custom - Team AIO Mod++
Func checkDeadBase($bForceCapture = False)
	
	If $bForceCapture = True Then
		_CaptureRegion2()
	EndIf
	
	If $g_bChkDeadEagle And $g_iSearchCount < $g_iDeadEagleSearch Then
		If $g_bDebugSetlog Then SetDebugLog("Checking base for DeadEagle : " & $g_iSearchCount)
		Return CheckForDeadEagle(False)
	Else
		If $g_bDebugSetlog Then SetDebugLog("Checking base for Collector Level : " & $g_iSearchCount)
		Return checkDeadBaseSuperNew(False)
	EndIf
EndFunc   ;==>checkDeadBase

Func checkDeadBaseSuperNew($bForceCapture = False, $sFillDirectory = @ScriptDir & "\imgxml\deadbase\elix\fill\", $sLvlDirectory = @ScriptDir & "\imgxml\deadbase\elix\lvl\")

	#Region -  New DB sys - Team AIO Mod++
	Local $bNoCheckDefenses = $g_bCollectorFilterDisable

	If $g_bDefensesMix = True Or $g_bDefensesAlive = True Then

		If $g_bDefensesMix Then
			$bNoCheckDefenses = True
		EndIf

		Local $sDFindEagle = DFind($g_sBundleDefensesEagle, 216, 174, 438, 325, 0, 0, 0, False) ; 91, 69, 723, 527
		Local $bALiveSimbol = StringInStr($sDFindEagle, "ALive") > 0, $bDeadSimbol = StringInStr($sDFindEagle, "DEeagle") > 0
		If $bALiveSimbol = True Then
			SetDebugLog("      " & ">> We have found active defenses, skipped.", $COLOR_ACTION)
			Return False
		ElseIf $bALiveSimbol = False And $bDeadSimbol = False And $bNoCheckDefenses = True Then
			SetDebugLog("      " & ">> We did not find live or dead defenses, we will check in depth.", $COLOR_ACTION)
			$bNoCheckDefenses = False
		ElseIf $bALiveSimbol = False And $bDeadSimbol = True And $bNoCheckDefenses = True Then
			SetDebugLog("      " & ">> We find dead defenses and the filters are deactivated, we better attack.", $COLOR_ACTION)
			Return True
		EndIf
	EndIf

	If $bNoCheckDefenses Then Return True
	#EndRegion -  New DB sys - Team AIO Mod++

	Local $minCollectorLevel = 0
	Local $maxCollectorLevel = 0
	Local $anyFillLevel[2] = [False, False] ; 50% and 100%
	If $g_bDebugSetlog Then SetDebugLog("Checking Deadbase With IMGLOC + DMatch (super super new)", $COLOR_WARNING)

	For $i = 6 To ubound($g_aiCollectorLevelFill) -1
		If $g_abCollectorLevelEnabled[$i] Then
			If $minCollectorLevel = 0 Then $minCollectorLevel = $i
			If $i > $maxCollectorLevel Then $maxCollectorLevel = $i
			$anyFillLevel[$g_aiCollectorLevelFill[$i]] = True
		EndIf
	Next

	If $maxCollectorLevel = 0 Then Return True

	If $g_bDebugSetlog Then SetDebugLog("Checking Deadbase With IMGLOC START", $COLOR_WARNING)

	Local $TotalMatched = 0
	Local $Matched[2] = [-1, -1]
	Local $aPoints[0]

	#Region - Custom match - Team AIO Mod++
	; found fill positions (deduped)
	Local $aPos[0]

	Local $sCocDiamond = "ECD" ;
	Local $redLines = $g_sImglocRedline ; if TH was Search then redline is set!
	Local $minLevel = 0
	Local $maxLevel = 14 ; Level 12 imgloc - Team AIO Mod++
	Local $maxReturnPoints = 0 ; all positions
	Local $returnProps = "objectname,objectpoints,objectlevel,fillLevel"
	Local $matchedValues
	Local $iTotalMatched = 0, $iLocalMatch = 0
	Local $x, $y, $lvl, $fill

	If $bForceCapture Then _CaptureRegion2() ; Custom match - Team AIO Mod++

	; Imgloc will get in place if it goes true
	; If $iTotalMatched < $g_iCollectorMatchesMin Then
		Local $iaCaptureZone[4] = [0, 0, 0, 0]

		Local $aLvlResult, $aFillResult
		Local $iMinDist = 25, $iTmpDis = 0

		$iTotalMatched = 0

		$aLvlResult = _ImageSearchSpecial($sLvlDirectory, 0, $sCocDiamond, $redLines, False, False, True, $iMinDist, $minLevel, $maxLevel)
		If $aLvlResult <> -1 Then
			
			For $i = 0 To UBound($aLvlResult) -1
				If $iaCaptureZone[0] > $aLvlResult[$i][1] Or $iaCaptureZone[0] < 1 Then 
					$iaCaptureZone[0] = $aLvlResult[$i][1]
				EndIf
				
				If $iaCaptureZone[1] > $aLvlResult[$i][2] Or $iaCaptureZone[1] < 1 Then 
					$iaCaptureZone[1] = $aLvlResult[$i][2]
				EndIf
				
				If $iaCaptureZone[2] < $aLvlResult[$i][1] Then 
					$iaCaptureZone[2] = $aLvlResult[$i][1]
				EndIf
				
				If $iaCaptureZone[3] < $aLvlResult[$i][2] Then 
					$iaCaptureZone[3] = $aLvlResult[$i][2]
				EndIf
			Next
			
			If $iaCaptureZone[0] < 25 Then $iaCaptureZone[0] -= 25
			If $iaCaptureZone[1] < 25 Then $iaCaptureZone[1] -= 25
			$iaCaptureZone[2] += 25
			$iaCaptureZone[3] += 25

			If $g_bDebugSetlog Then
				SetDebugLog("Collectors in zone: " & _ArrayToString($iaCaptureZone), $COLOR_INFO)
			EndIf

			$aFillResult = _ImageSearchSpecial($sFillDirectory, 0, GetDiamondFromArray($iaCaptureZone), GetDiamondFromArray($iaCaptureZone), False, False, True, $iMinDist)
			
			If $aFillResult <> -1 Then

				For $iL = 0 To UBound($aLvlResult) -1

					For $iF = 0 To UBound($aFillResult) -1
						Sleep(10)

						If $aFillResult[$iF][1] = -1 Then
							ContinueLoop
						EndIf

						If Pixel_Distance($aLvlResult[$iL][1], $aLvlResult[$iL][2], $aFillResult[$iF][1], $aFillResult[$iF][2]) > $iMinDist Then
							ContinueLoop
						EndIf

						; SetLog($aLvlResult[$iL][1] & " " & $aLvlResult[$iL][2] & " " & $aFillResult[$iF][1] & " " & $aFillResult[$iF][2])

						$lvl = $aLvlResult[$iL][3]
						$fill = $aFillResult[$iF][4]

						; check if this collector level with fill level is enabled
						If $g_abCollectorLevelEnabled[$lvl] Then
							Local $fillIndex = GetCollectorIndexByFillLevel($fill)
							If $fillIndex < $g_aiCollectorLevelFill[$lvl] Then
								; collector fill level not reached
								If $g_bDebugSetlog Then
									SetDebugLog("IMGLOC : Searching Deadbase collector level " & $lvl & " found but not enough elixir, fill level " & $fill & " at " & $aLvlResult[$iL][1] & ", " & $aLvlResult[$iL][2], $COLOR_INFO)
									ContinueLoop ; jump to next collector
								EndIf
							EndIf
						Else
							; collector is not enabled
							If $g_bDebugSetlog Then
								SetDebugLog("IMGLOC : Searching Deadbase collector level " & $lvl & " found but not enabled, fill level " & $fill & " at " & $aLvlResult[$iL][1] & ", " & $aLvlResult[$iL][2], $COLOR_INFO)
								ContinueLoop ; jump to next collector
							EndIf
						EndIf

						$aFillResult[$iF][1] = -1

						; found collector
						$iTotalMatched += 1

						ExitLoop
					Next

				Next

			EndIf

		EndIf
	; EndIf
	#EndRegion - Custom match - Team AIO Mod++

	Local $dbFound = $iTotalMatched >= $g_iCollectorMatchesMin
	#CS - The combination of both methods causes the CPU to roast, I will migrate soon. There is a small bug that makes that even if you set a core, the CPU usage is complete.
	If $dbFound = False Then
		; 0.19s method DMatch.
		Local $iStartLevel = 13
		Local $iEndLevelD = UBound($g_aiCollectorLevelFill) - 1
		Local $iDminLevel = 0
		Local $iDmaxLevel = 0
		Local $aDFillLevel[2] = [False, False] ; 50% and 100%
		For $i = $iStartLevel To $iEndLevelD
			If $g_abCollectorLevelEnabled[$i] Then
				If $iDminLevel = 0 Then $iDminLevel = $i
				If $i > $iDmaxLevel Then $iDmaxLevel = $i
				$aDFillLevel[$g_aiCollectorLevelFill[$i]] = True
			EndIf
		Next

		If $g_bDebugSetlog Then SetDebugLog("checkDeadBase DMatch | $iDminLevel : " & $iDminLevel & " $iDmaxLevel : " & $iDmaxLevel & " $aDFillLevel[0] : " & $aDFillLevel[0] & " $aDFillLevel[1] : " & $aDFillLevel[1])

		If $aDFillLevel[0] Then ; Scan optimized.
			Local $sDFindResult50 = DFind($g_sECollectorDMatB & "50\", 19, 74, 805, 518, $iDminLevel, $iDmaxLevel, $g_iCollectorMatchesMin, False)
			For $i = $iDminLevel To $iDmaxLevel
				; Check for the Level Collectors at first, as it's Image matching and the Dll differs.
				If Not $g_abCollectorLevelEnabled[$i] Then ContinueLoop
				If $g_aiCollectorLevelFill[$i] <> 0 Then ContinueLoop
				$iLocalMatch = CountDMatchingMatches($sDFindResult50, "Elix-" & $i)
				SetDebugLog("Found a Total of " & $iLocalMatch & " level " & $i & " collectors with second phase, 50% Fill", $COLOR_DEBUG)
				$iTotalMatched += $iLocalMatch
			Next
		EndIf

		If $aDFillLevel[1] Or $aDFillLevel[0] Then ; Scan optimized.
			$iLocalMatch = 0
			If $iTotalMatched < $g_iCollectorMatchesMin Then
				Local $sDFindResult100 = DFind($g_sECollectorDMatB & "100\", 19, 74, 805, 518, $iDminLevel, $iDmaxLevel, $g_iCollectorMatchesMin, False)
				For $i = $iDminLevel To $iDmaxLevel
					; Check for the Level Collectors at first, as it's Image matching and the Dll differs.
					If Not $g_abCollectorLevelEnabled[$i] Then ContinueLoop
					; If $g_aiCollectorLevelFill[$i] < 0 Then ContinueLoop
					$iLocalMatch = CountDMatchingMatches($sDFindResult100, "Elix-" & $i)
					SetDebugLog("Found a Total of " & $iLocalMatch & " level " & $i & " collectors with second phase, 10% Fill", $COLOR_DEBUG)
					$iTotalMatched += $iLocalMatch
				Next
			EndIf
		EndIf
	EndIf
	#CE - The combination of both methods causes the CPU to roast, I will migrate soon. There is a small bug that makes that even if you set a core, the CPU usage is complete.
	If $g_bDebugSetlog Then
		If $dbFound Then
			SetDebugLog("Matching: DeadBase Matched! Found " & $iTotalMatched & " Collectors", $COLOR_GREEN)
		Else
			SetDebugLog("Matching: DeadBase not Matched! Found just " & $iTotalMatched & " Collectors", $COLOR_WARNING)
		EndIf
	EndIf

	; always update $g_aZombie[3], current matched collectors count
	$g_aZombie[3] = $iTotalMatched
	If $g_bDebugDeadBaseImage Then setZombie(0, $g_iSearchElixir, $iTotalMatched, $g_iSearchCount, $g_sImglocRedline)

	Return $dbFound

EndFunc   ;==>checkDeadBaseSuperNew

Func _ImageSearchSpecial($sDirectory, $iQuantityMatch = Default, $vArea2SearchOri = Default, $vArea2SearchOri2 = Default, $bForceCapture = Default, $bDebugLog = False, $bCheckDuplicatedpoints = True, $iDistance2check = 25, $minLevel = 0, $maxLevel = 1000)
	Local $iCount = 0, $returnProps = "objectname,objectlevel,fillLevel,objectpoints"
	Local $error, $extError

	If $iQuantityMatch = Default Then $iQuantityMatch = 0
	If $bForceCapture = Default Then $bForceCapture = False
	If $vArea2SearchOri = Default Then $vArea2SearchOri = "ECD"
	If $vArea2SearchOri2 = Default Then $vArea2SearchOri2 = $vArea2SearchOri

	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT)
	Local $returnLine[UBound($returnData)]

	; Capture the screen for comparison
	If $bForceCapture Then _CaptureRegion2() ;to have FULL screen image to work with

	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantityMatch, "str", $vArea2SearchOri2, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		If $g_bDebugSetlog Then SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return -1
	EndIf

	If checkImglocError($result, "_ImageSearchSpecial", $sDirectory) = True Then
		If $g_bDebugSetlog Then SetDebugLog("_ImageSearchSpecial Returned Error or No values : ", $COLOR_DEBUG)
		Return -1
	EndIf

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT)
	If $g_bDebugSetlog Then SetDebugLog(" ***  _ImageSearchXML multiples **** ", $COLOR_ORANGE)

	; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
	Local $iD2C = ($bCheckDuplicatedpoints = True) ? ($iDistance2check) : (0)
	Local $aAR[0][5], $aXY
	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				; Inspired in Chilly-chill
				Local $aC = StringSplit($returnLine[$rD], "|", $STR_NOCOUNT)
				For $i = 0 To UBound($aC) - 1
					$aXY = StringSplit($aC[$i], ",", $STR_NOCOUNT)
					If UBound($aXY) <> 2 Then
						ContinueLoop 3
					EndIf

					If $iD2C > 0 Then
						If DMduplicated($aAR, Int($aXY[0]), Int($aXY[1]), UBound($aAR)-1, $iD2C) Then
							ContinueLoop
						EndIf
					EndIf

					ReDim $aAR[$iCount + 1][5]
					$aAR[$iCount][0] = $returnLine[0]
					$aAR[$iCount][1] = Int($aXY[0])
					$aAR[$iCount][2] = Int($aXY[1])
					$aAR[$iCount][3] = Int($returnLine[1])
					$aAR[$iCount][4] = Int($returnLine[2])
					$iCount += 1

					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then
						ExitLoop 3
					EndIf
				Next
			EndIf
		Next
	Next

	If UBound($aAR) < 1 Then Return -1
	Return $aAR
EndFunc   ;==>_ImageSearchSpecial

; search image for Dead Eagle
; return True if found
Func CheckForDeadEagle($bForceCapture = False)
	Local $sImgDeadEagleImages = @ScriptDir & "\imgxml\Buildings\DeadEagle"
	Local $sBoostDiamond = "ECD"
	Local $redlines = "ECD"

	Local $avDeadEagle = findMultiple($sImgDeadEagleImages, $sBoostDiamond, $redlines, 0, 1000, 0, "objectname,objectpoints", $bForceCapture)

	If Not IsArray($avDeadEagle) Or UBound($avDeadEagle, $UBOUND_ROWS) <= 0 Then
		SetDebugLog("No Dead Eagle!")
		If $g_bDebugImageSave Then SaveDebugImage("DeadEagle", False)
		Return False
	EndIf

	Local $avTempArray

	For $i = 0 To UBound($avDeadEagle, $UBOUND_ROWS) - 1
		$avTempArray = $avDeadEagle[$i]

		SetLog("Search find : " & $avTempArray[0])
		SetLog("Location    : " & $avTempArray[1])
	Next

	Return True
EndFunc
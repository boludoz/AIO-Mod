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
#cs
diff a/COCBot/functions/Image Search/checkDeadBase.au3 b/COCBot/functions/Image Search/checkDeadBase.au3	(rejected hunks)
@@ -156,7 +156,11 @@ Func checkDeadBaseNew()
 EndFunc   ;==>checkDeadBaseNew
 
 Func checkDeadBase()
-	Return checkDeadBaseSuperNew(False)
+   If $g_bChkDeadEagle Then
+		Return CheckForDeadEagle()
+	Else
+		Return checkDeadBaseSuperNew(False)
+	EndIf
 EndFunc   ;==>checkDeadBase
 
 Func GetCollectorIndexByFillLevel($level)
@@ -491,3 +495,31 @@ Func checkDeadBaseFolder($directory, $executeOldCode = "checkDeadBaseNew()", $ex
 	Return True
 
 EndFunc   ;==>checkDeadBaseFolder
+
+; search image for Dead Eagle
+; return True if found
+Func CheckForDeadEagle()
+	Local $sImgDeadEagleImages = @ScriptDir & "\imgxml\Buildings\DeadEagle"
+	Local $sBoostDiamond = "ECD"
+	Local $redlines = "ECD"
+
+	; search for a clock face in the Boost window
+	Local $avDeadEagle = findMultiple($sImgDeadEagleImages, $sBoostDiamond, $redlines, 0, 1000, 0, "objectname,objectpoints")
+
+	; no clockface lets scroll up and look again
+	If Not IsArray($avDeadEagle) Or UBound($avDeadEagle, $UBOUND_ROWS) <= 0 Then
+		SetLog("No Dead Eagle!")
+		Return False
+	EndIf
+
+	Local $avTempArray
+
+	For $i = 0 To UBound($avDeadEagle, $UBOUND_ROWS) - 1
+		$avTempArray = $avDeadEagle[$i]
+
+		SetLog("Search find : " & $avTempArray[0])
+		SetLog("Location    : " & $avTempArray[1])
+	Next
+
+	Return True
+EndFunc

#ce
Func checkDeadBase($bForceCapture = False, $sFillDirectory = @ScriptDir & "\imgxml\deadbase\elix\fill\", $sLvlDirectory = @ScriptDir & "\imgxml\deadbase\elix\lvl\")
	
	#Region -  New DB sys - Team AIO Mod++
	Local $bNoCheckDefenses = $g_bCollectorFilterDisable
	
	If $g_bDefensesMix = True Or $g_bDefensesAlive = True Then 
		If $g_bDefensesMix Then $bNoCheckDefenses = True
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
	
	Local $iStartLevel = 13
	Local $iEndLevelD = UBound($g_aiCollectorLevelFill) - 1
	
	If $bForceCapture Then _CaptureRegion2() ; Custom match - Team AIO Mod++
	
	; 0.19s method DMatch.
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

	; Imgloc will get in place if it goes true
	Local $bFoundFilledCollectors = False
	Local $result
	; Check if Enough Level 13/14 Collectors hasn't been found by Dissociable.Matching.dll then check for other collectors
	If $iTotalMatched < $g_iCollectorMatchesMin Then
		$iTotalMatched = 0
		; check for any collector filling
		Local $result = findMultiple($sFillDirectory, $sCocDiamond, $redLines, $minLevel, $maxLevel, $maxReturnPoints, $returnProps, False) ; Custom match - Team AIO Mod++
		$bFoundFilledCollectors = IsArray($result) = 1
	EndIf
	#EndRegion - Custom match - Team AIO Mod++

	If $bFoundFilledCollectors Then
		For $matchedValues In $result
			Local $aPoints = StringSplit($matchedValues[1], "|", $STR_NOCOUNT) ; multiple points splited by | char
			Local $found = UBound($aPoints)
			If $found > 0 Then
				$lvl = Number($matchedValues[3])
				For $sPoint In $aPoints
					Local $aP = StringSplit($sPoint, ",", $STR_NOCOUNT)
					ReDim $aP[4] ; 2=fill, 3=lvl
					$aP[3] = 0 ; initial lvl is 0 (for not found/identified yet)
					$aP[2] = $lvl
					Local $bSkipPoint = False
					For $i = 0 To UBound($aPos) - 1
						Local $bP = $aPos[$i]
						Local $a = $aP[1] - $bP[1]
						Local $b = $aP[0] - $bP[0]
						Local $c = Sqrt($a * $a + $b * $b)
						If $c < 25 Then
							; duplicate point: skipped
							If $aP[2] > $bP[2] Then
								; keep this one with higher level
								$aPos[$i] = $aP
								$aP = $bP ; just for logging
							EndIf
							If $g_bDebugSetlog Then SetDebugLog("IMGLOC : Searching Deadbase ignore duplicate collector with fill level " & $aP[2] & " at " & $aP[0] & ", " & $aP[1], $COLOR_INFO)
							$bSkipPoint = True
							$found -= 1
							ExitLoop
						EndIf
					Next
					If Not $bSkipPoint Then
						Local $i = UBound($aPos)
						ReDim $aPos[$i + 1]
						$aPos[$i] = $aP
					EndIf
				Next
			EndIf
		Next

		; check each collector location for collector level
		For $aP In $aPos
			$x = $aP[0]
			$y = $aP[1]
			$fill = $aP[2]
			$lvl = $aP[3]
			; search area for collector level, add 20 left and right, 25 top and 15 bottom
			$sCocDiamond = ($x - 20) & "," & ($y - 25) & "|" & ($x + 20) & "," & ($y - 25) & "|" & ($x + 20) & "," & ($y + 15) & "|" & ($x - 20) & "," & ($y + 15)
			$redLines = $sCocDiamond ; override red line with CoC Diamond so not calculated again
			$result = findMultiple($sLvlDirectory, $sCocDiamond, $redLines, $minLevel, $maxLevel, $maxReturnPoints, $returnProps, $bForceCapture)
			$bForceCapture = False ; force capture only first time
			If IsArray($result) Then
				For $matchedValues In $result
					Local $aPoints = StringSplit($matchedValues[1], "|", $STR_NOCOUNT) ; multiple points splited by | char
					If UBound($aPoints) > 0 Then
						; collector level found
						$lvl = Number($matchedValues[2])
						If $lvl > $aP[3] Then $aP[3] = $lvl ; update collector level
					EndIf
				Next
			EndIf
			$lvl = $aP[3] ; update level variable as modified above
			If $lvl = 0 Then
				; collector level not identified
				If $g_bDebugSetlog Then SetDebugLog("IMGLOC : Searching Deadbase no collector identified with fill level " & $fill & " at " & $x & ", " & $y, $COLOR_INFO)
				ContinueLoop ; jump to next collector
			EndIf

			; check if this collector level with fill level is enabled
			If $g_abCollectorLevelEnabled[$lvl] Then
				Local $fillIndex = GetCollectorIndexByFillLevel($fill)
				If $fillIndex < $g_aiCollectorLevelFill[$lvl] Then
					; collector fill level not reached
					If $g_bDebugSetlog Then SetDebugLog("IMGLOC : Searching Deadbase collector level " & $lvl & " found but not enough elixir, fill level " & $fill & " at " & $x & ", " & $y, $COLOR_INFO)
					ContinueLoop ; jump to next collector
				EndIf
			Else
				; collector is not enabled
				If $g_bDebugSetlog Then SetDebugLog("IMGLOC : Searching Deadbase collector level " & $lvl & " found but not enabled, fill level " & $fill & " at " & $x & ", " & $y, $COLOR_INFO)
				ContinueLoop ; jump to next collector
			EndIf

			; found collector
			$iTotalMatched += 1
		Next
	EndIf

	Local $dbFound = $iTotalMatched >= $g_iCollectorMatchesMin

	If $g_bDebugSetlog Then
		; If has called ImgLoc, Show It's Specific Debug Logs
		If IsArray($result) Then
			If Not $bFoundFilledCollectors Then
				SetDebugLog("IMGLOC : NOT A DEADBASE", $COLOR_INFO)
			ElseIf Not $dbFound Then
				SetDebugLog("IMGLOC : DEADBASE NOT MATCHED: " & $iTotalMatched & "/" & $g_iCollectorMatchesMin, $COLOR_WARNING)
			Else
				SetDebugLog("IMGLOC : FOUND DEADBASE Matched: " & $iTotalMatched & "/" & $g_iCollectorMatchesMin & ": " & UBound($aPoints), $COLOR_GREEN)
			EndIf
		Else
			If $dbFound Then
				SetDebugLog("Dissociable.Matching: DeadBase Matched! Found " & $iTotalMatched & " Collectors", $COLOR_GREEN)
			Else
				SetDebugLog("Dissociable.Matching: DeadBase not Matched! Found just " & $iTotalMatched & " Collectors", $COLOR_WARNING)
			EndIf
		EndIf
	EndIf

	; always update $g_aZombie[3], current matched collectors count
	$g_aZombie[3] = $iTotalMatched
	If $g_bDebugDeadBaseImage Then setZombie(0, $g_iSearchElixir, $iTotalMatched, $g_iSearchCount, $g_sImglocRedline)

	Return $dbFound

EndFunc   ;==>checkDeadBaseSuperNew
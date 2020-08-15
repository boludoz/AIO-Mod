; FUNCTION ====================================================================================================================
; Name ..........: CollectorsAndRedLines
; Description ...: 
; Syntax ........:
; Parameters ....:
; Return values .: True					More collectors outside than specified.
;				 : False				less collectors outside than specified.
; Author ........: Samkie (13 Jan 2017) & Team AiO MOD++ (2020)
; Modified ......: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================
Func CollectorsAndRedLines($bForceCapture = False)
	If Not ($g_bDBCollectorNearRedline Or $g_bDBMeetCollectorOutside) Then Return True
	
	Local $hTimer = TimerInit()
	Local $bReturn = True
	Local $sText = ($g_bDBCollectorNearRedline) ? ("Are collectors near redline ?") : ("Are collectors outside ?")
	SetLog($sText & " | Locating Mines & Collectors", $COLOR_ACTION)
	Local $aAllCollectors = SmartFarmDetection("All", $bForceCapture)
	SetLog($sText & " | Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ACTION)
	If ($aAllCollectors <> 0) Then
		$g_vSmartFarmScanOut = $aAllCollectors
		Local $iLocated = UBound($aAllCollectors), $iOut = 0 
		For $i = 0 To $iLocated-1
			If ($aAllCollectors[$i][3] = "Out") Then $iOut += 1
		Next
		If $g_bDBCollectorNearRedline Then
			$bReturn = ($g_iCmbRedlineTiles <= $iOut)
		ElseIf $g_bDBMeetCollectorOutside Then
			$bReturn = ($g_iDBMinCollectorOutsidePercent <= Round($iOut / $iLocated) * 100)
		EndIf
		SetLog($sText & " | " & $bReturn & " - Out: " & $iOut & " - Located: " & $iLocated, $COLOR_INFO)
		Return $bReturn
	EndIf
	SetLog($sText & " | No collectors found, presumed true.", $COLOR_ACTION)
	Return $bReturn
EndFunc   ;==>AreCollectorsOutside

; #FUNCTION# ====================================================================================================================
; Name ..........: GetLocationMine
; Description ...:
; Syntax ........: GetLocationMine()
; Parameters ....:
; Return values .: String with locations
; Author ........:
; Modified ......: Boldina ! (16/6/2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func ReturnPreVD(ByRef $aS, $bBB = False, $bEdge = False)
	Local $aSearch[4] = [15, 31, 859, 648] ; Edge - NV.
	Select
		Case $bBB
			Select
				Case $bEdge ; Edge - BB.
					Local $aSearch[4] = [83, 136, 844, 694] 
				Case Not $bEdge ; No Edge - BB.
					Local $aSearch[4] = [138, 173, 780, 648] 
			EndSelect
		Case Else
			Local $aSearch[4] = [92, 73, 781, 599] ; No Edge - NV.
	EndSelect
	$aS = $aSearch
	If $g_bDebugSetlog Then SetDebugLog("ReturnPreVD | " & String(_ArrayToString($aS)), $COLOR_INFO)
EndFunc

Func FastVillage($sDirectory, $iLimit = 7, $bNeedCapture = True, $bBB = False, $bEdge = False)
	Local $aRet[0]
	Local $aSearch[4]
	ReturnPreVD($aSearch, $bBB, $bEdge)
	If $bNeedCapture Then _CaptureRegion2()
	If $iLimit = 1 Then $iLimit += 1
	Local $aRes = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", GetDiamondFromArray($aSearch), "Int", $iLimit, "str", GetDiamondFromArray($aSearch), "Int", 0, "Int", 1000)
	If UBound($aRes[0]) > 1 Then Return -1
	Local $aKeyValue = StringSplit($aRes[0], "|", $STR_NOCOUNT)

	For $i = 0 To UBound($aKeyValue) - 1
		Local $vDLLRes = DllCallMyBot("GetProperty", "str", $aKeyValue[$i], "str", "objectpoints")
		Local $vDLLSpl = StringSplit($vDLLRes[0], "|", $STR_NOCOUNT)
		For $vC In $vDLLSpl
			Local $a = StringSplit($vC, ",", $STR_NOCOUNT)
			If UBound($a) <> 2 Then ContinueLoop
			If Not isInDiamond($a[0], $a[1], $aSearch[0], $aSearch[1], $aSearch[2], $aSearch[3]) Then ContinueLoop
			_ArrayAdd($aRet, $a, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	Next
	Return (UBound($aRet) - 1 > 0) ? ($aRet) : (-1)

EndFunc   ;==>FastVillage

Func _GetLocationMine($bNeedCapture = True)

	Local $vMines = FastVillage(@ScriptDir & "\imgxml\Storages\GoldMines\", 7, $bNeedCapture)
	Local $vMinesS = FastVillage(@ScriptDir & "\imgxml\Storages\Mines_Snow\", 7, False)
	
	If $vMines <> -1 Then Return $vMines
	If $vMinesS <> -1 Then Return $vMinesS
	Return -1
EndFunc   ;==>_GetLocationMine

Func _GetLocationElixir($bNeedCapture = True)

	Local $vCollectors = FastVillage(@ScriptDir & "\imgxml\Storages\Collectors\", 7, $bNeedCapture)
	Local $vCollectorsS = FastVillage(@ScriptDir & "\imgxml\Storages\Collectors_Snow\", 7, False)
	
	If $vCollectors <> -1 Then Return $vCollectors
	If $vCollectorsS <> -1 Then Return $vCollectorsS
	Return -1
EndFunc   ;==>_GetLocationElixir

Func _GetLocationDarkElixir($bNeedCapture = True)

	Local $vDrills = FastVillage(@ScriptDir & "\imgxml\Storages\Drills\", 7, $bNeedCapture)
	
	If $vDrills <> -1 Then Return $vDrills
	Return -1
EndFunc   ;==>_GetLocationDarkElixir

; FUNCTION ====================================================================================================================
; Name ..........: isInDiamond
; Description ...: Return True or False is if point is outside diamond.
;                  
; Syntax ........: isInDiamond($iX, $iY)
; Parameters ....: 
; Return values .: True or False
; Author ........: Boldina ! (16/6/2020) (port to au3, Based in model by Wladimir Palant)
; Modified ......: 
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. CopyiRight 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: 
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func isInDiamond($iX, $iY, $iLeft = 15, $iTop = 31, $iRight = 859, $iBottom = 648)
	Local $bReturn = False

	If Not (($iX < 68 And $iY > 316) Or ($iY < 63) Or ($iX > 692 And $iY > 156 And $iY < 210) Or ($iX > 669 And $iY > 489) Or (56 > $iY)) Then
		Local $aMiddle[2] = [(($iLeft + $iRight) + $g_iXVOffset) / 2, ($iTop + $iBottom) / 2]
		Local $aSize[2] = [$aMiddle[0] - $iLeft, $aMiddle[1] - $iTop]
		$bReturn = ((Abs($iX - $aMiddle[0]) / $aSize[0] + Abs($iY - $aMiddle[1]) / $aSize[1]) <= 1) ? (True) : (False)
	EndIf
	SetDebugLog("isInDiamond | Is in diamond? " & $bReturn & " / Correction: " & $g_iXVOffset)
	Return $bReturn
EndFunc
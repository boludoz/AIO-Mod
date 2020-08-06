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
Func CollectorsAndRedLines()
	If Not ($g_bDBCollectorNearRedline Or $g_bDBMeetCollectorOutside) Then Return True
	
	Local $hTimer = TimerInit()
	Local $bReturn = True
	Local $sText = ($g_bDBCollectorNearRedline) ? ("Are collectors near redline ?") : ("Are collectors outside ?")
	SetLog($sText & " | Locating Mines & Collectors", $COLOR_ACTION)
	Local $aAllCollectors = SmartFarmDetection("All")
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
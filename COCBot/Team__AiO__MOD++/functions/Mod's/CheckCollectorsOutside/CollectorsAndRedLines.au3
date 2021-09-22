; FUNCTION ====================================================================================================================
; Name ..........: CollectorsAndRedLines
; Description ...: 
; Syntax ........:
; Parameters ....:
; Return values .: True					More collectors outside than specified.
;				 : False				less collectors outside than specified.
; Author ........: Samkie (13 Jan 2017) & Team AiO MOD++ (2020/2021)
; Modified ......: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================
Func CollectorsAndRedLines($bForceCapture = False)
	If ForceCollectorsOutside() Then
		SetLog("Smart milk: Forcing check collectors outside.", $COLOR_INFO)
	ElseIf Not ($g_bDBCollectorNearRedline Or $g_bDBMeetCollectorOutside) Then
		Return True ; Smart milk - Team AIO Mod++
	EndIf
	
	Local $hTimer = TimerInit()
	Local $bReturn = False
	Local $sText = ($g_bDBCollectorNearRedline) ? ("Are collectors near redline ?") : ("Are collectors outside ?")
	SetLog($sText & " | Locating Mines & Collectors", $COLOR_ACTION)
	Local $aAllCollectors = SmartFarmDetection("All", $bForceCapture)
	SetLog($sText & " | Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ACTION)
	Local $iOut = 0, $iLocated = UBound($aAllCollectors) 
	If $iLocated > 0 And not @error Then
		$g_vSmartFarmScanOut = $aAllCollectors
		For $i = 0 To $iLocated - 1
			If ($aAllCollectors[$i][3] = "Out") Then $iOut += 1
		Next
		If $g_bDBMeetCollectorOutside Or ForceCollectorsOutside() Then
			$bReturn = ($g_iCmbRedlineTiles <= $iOut)
		ElseIf $g_bDBCollectorNearRedline Then
			$bReturn = ($g_iDBMinCollectorOutsidePercent <= Round($iOut / $iLocated) * 100)
		EndIf
		SetLog($sText & " | " & $bReturn & " - Out: " & $iOut & " - Located: " & $iLocated, $COLOR_INFO)
	EndIf
	
	Return $bReturn
EndFunc   ;==>AreCollectorsOutside
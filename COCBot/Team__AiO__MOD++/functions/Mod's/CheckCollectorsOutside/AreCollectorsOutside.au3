; FUNCTION ====================================================================================================================
; Name ..........: AreCollectorsOutside
; Description ...: 
; Syntax ........:
; Parameters ....: $ipercent				minimum % of collectors outside of walls to all
; Return values .: True					more collectors outside than specified
;				 : False				less collectors outside than specified
; Author ........: McSlither (Jan-2016)
; Modified ......: TheRevenor (Jul 2016), Samkie (13 Jan 2017), Team AiO MOD++ (2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================
Global $g_vSmartFarmScanOut = 0
Func AreCollectorsOutside($bTest = False)
	If $g_bDBCollectorNearRedline And not $bTest Then Return AreCollectorsNearRedline()
	Local $hTimer = TimerInit()
	Local $bAreOutside = False
	SetLog("Are collectors outside ? | Locating Mines & Collectors", $COLOR_ACTION)
	Local $aAllCollectors = SmartFarmDetection("All")
	SetLog("Are collectors outside ? | Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ACTION)
	If ($aAllCollectors <> 0) Then
		$g_vSmartFarmScanOut = $aAllCollectors
		Local $iLocated = UBound($aAllCollectors), $iOut = 0 
		For $i = 0 To $iLocated-1
			If ($aAllCollectors[$i][3] = "Out") Then $iOut += 1
		Next
		$bAreOutside = ($g_iDBMinCollectorOutsidePercent <= Round($iOut / $iLocated) * 100)
		SetLog("Are collectors outside ? | " & $bAreOutside & " - Out: " & $iOut & " - Located: " & $iLocated, $COLOR_INFO)
		Return $bAreOutside
	EndIf
	SetLog("Are collectors outside ? | No collectors found, presumed true.", $COLOR_ACTION)
	Return True
EndFunc   ;==>AreCollectorsOutside
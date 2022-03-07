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
	Local $bReturn = False
	
	Local Const $imilkfarmoffsetxstep = 35
	Local Const $imilkfarmoffsetystep = 26
	Local $diamondx = $imilkfarmoffsetxstep + ($imilkfarmoffsetxstep * $g_iCmbRedlineTiles)
	Local $diamondy = $imilkfarmoffsetystep + ($imilkfarmoffsetystep * $g_iCmbRedlineTiles)
	Local $iPixelDistance = PixelDistance(0, 0, $diamondx, $diamondy)
	
	If $g_bDBMeetCollectorOutside Then
		; Local $hTimer = TimerInit()
		Local $sText = ($g_bDBCollectorNearRedline And $g_bDBMeetCollectorOutside) ? ("Are collectors near redline ?") : ("Are collectors outside ?")
		If $bForceCapture = True Then _CaptureRegion2()
		ConvertInternalExternArea("CollectorsAndRedLines")
		_GetRedArea()
		
		Local $aAllCollectors = SmartFarmDetection("All", False, False)
		; SetLog($sText & " | Located collectors in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds", $COLOR_ACTION)
		Local $iOut = 0
		Local $iLocated = UBound($aAllCollectors)
		If $iLocated > 0 And not @error Then
			For $i = 0 To $iLocated - 1
				SetLog($iPixelDistance & " / "& $iPixelDistance >= $aAllCollectors[$i][2] & " RD " & $aAllCollectors[$i][2])
				If $g_bDBCollectorNearRedline And $iPixelDistance >= $aAllCollectors[$i][2] Then
					$iOut += 1
				ElseIf ($aAllCollectors[$i][3] = "Out") Then
					$iOut += 1
				EndIf
			Next
			$bReturn = ($g_iDBMinCollectorOutsidePercent <= Round(Int(($iOut * 100) / $iLocated, 0)))
			SetLog($sText & " : " & $bReturn & " - Out: " & $iOut & " - Located: " & $iLocated, $COLOR_INFO)
		EndIf
	EndIf
	Return $bReturn
EndFunc   ;==>AreCollectorsOutside
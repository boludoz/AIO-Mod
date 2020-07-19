; #FUNCTION# ====================================================================================================================
; Name ..........: isOnBuilderBase.au3
; Description ...: Check if Bot is currently on Normal Village or on Builder Base
; Syntax ........: isOnBuilderBase($bNeedCaptureRegion = False)
; Parameters ....: $bNeedCaptureRegion
; Return values .: True if is on Builder Base
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Click
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom - Team AIO Mod++
Func isOnBuilderBase($bNeedCaptureRegion = True, $bSoft = False)
	If _Sleep($DELAYISBUILDERBASE) Then Return
	If $bNeedCaptureRegion = True Or $bNeedCaptureRegion = Default Then _CaptureRegion2()
	If (_ImageSearchXML($g_sImgIsOnBB, 1, "260,0,406,54", False) <> -1) Then
		SetDebugLog("Builder Base Builder detected. (Normal).", $COLOR_INFO)
		Return True
	ElseIf ((_ImageSearchXML($g_sImgZoomOutDirBB, 1, "0,0,860,732", False) <> -1) And Not $bSoft) Then
		SetDebugLog("Builder Base Builder detected. (Battle).", $COLOR_INFO)
		Return True
	EndIf
	
	SetDebugLog("Builder Base Builder not detected.", $COLOR_ERROR)
	Return False
EndFunc   ;==>isOnBuilderBase
#EndRegion - Custom - Team AIO Mod++

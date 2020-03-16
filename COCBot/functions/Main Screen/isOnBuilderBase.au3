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

Func isOnBuilderBase($bNeedCaptureRegion = True)
	If _Sleep($DELAYISBUILDERBASE) Then Return
	If BitOr(IsArray(_ImageSearchXML($g_sImgIsOnBB, 0, "260,0,406,54", $bNeedCaptureRegion)), IsArray(_ImageSearchXML($g_sImgZoomOutDirBB, 0, "0,0,860,732", $bNeedCaptureRegion))) <> 0 Then  ; Team AIO Mod++
		SetDebugLog("Builder Base Builder detected.", $COLOR_DEBUG)
		Return True
	EndIf
	
	Return False
EndFunc

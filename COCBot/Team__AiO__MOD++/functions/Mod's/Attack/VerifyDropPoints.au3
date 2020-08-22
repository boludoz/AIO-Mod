; #FUNCTION# ====================================================================================================================
; Name ..........: VerifyDropPoints.au3
; Description ...: Verify Drop Points to not be in an Specific Region
; Syntax ........: 
; Parameters ....: None
; Return values .: None
; Author ........: Dissociable
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func PickUpRandomVerifiedDropPoint($aDropPoints, $aBlackRegion)
    ; If (IsArray($aDropPoints) = False Or UBound($aDropPoints) < 2) Or (IsArray($aBlackRegion) = False Or UBound($aBlackRegion) < 4) Then
       ; SetLog("Wrong parameters passed to PickUpRandomVerifiedDropPoint Function", $COLOR_ERROR)
       ; Return False
    ; EndIf
	
	; Random
   _ArrayShuffle($aDropPoints)
   
    ; We have disabled the Parameter function to to let it run unsafe, Devs has to take care of it, not the CPU!
	Local $oneDarray[2] = [-1, -1]
    For $i = 0 To UBound($aDropPoints) - 1
        $oneDArray[0] = $aDropPoints[$i][0]
        $oneDArray[1] = $aDropPoints[$i][1]
        If VerifyDropPointA($oneDArray, $aBlackRegion) Then
            Return $oneDArray
        EndIf
    Next
    Return "-1"
EndFunc

Func VerifyDropPointA($aDropPoint, $aBlackRegion)
    ;If (IsArray($aDropPoint) = False Or UBound($aDropPoint) < 2) Or (IsArray($aBlackRegion) = False Or UBound($aBlackRegion) < 4) Then
    ;    SetLog("Wrong parameters passed to VerifyDropPointA Function", $COLOR_ERROR)
    ;    Return False
    ;EndIf
    ; We have disabled the Parameter function to to let it run unsafe, Devs has to take care of it, not the CPU!
    Return VerifyDropPoint($aDropPoint[0], $aDropPoint[1], $aBlackRegion[0], $aBlackRegion[1], $aBlackRegion[2], $aBlackRegion[3])
EndFunc

Func VerifyDropPoint($iDropPointX, $iDropPointY, $iBlackLeft, $iBlackTop, $iBlackWidth, $iBlackHeight)
    Return _WinAPI_PtInRectEx($iDropPointX, $iDropPointY, $iBlackLeft, $iBlackTop, $iBlackLeft + $iBlackWidth, $iBlackTop + $iBlackHeight) = False
EndFunc
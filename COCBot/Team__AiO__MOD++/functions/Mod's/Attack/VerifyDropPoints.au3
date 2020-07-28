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

; It's not picking it Randomly, so it's faster than the PickUpRandomVerifiedDropPoint function
Func PickUpVerifiedDropPoint($aDropPoints, $aBlackRegion)
    ;If (IsArray($aDropPoints) = False Or UBound($aDropPoints) < 2) Or (IsArray($aBlackRegion) = False Or UBound($aBlackRegion) < 4) Then
    ;    SetLog("Wrong parameters passed to PickUpRandomVerifiedDropPoint Function", $COLOR_ERROR)
    ;    Return False
    ;EndIf
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

; The Faster version of this is the PickUpVerifiedDropPoint function, however that's not random!
Func PickUpRandomVerifiedDropPoint($aDropPoints, $aBlackRegion)
    ;If (IsArray($aDropPoints) = False Or UBound($aDropPoints) < 2) Or (IsArray($aBlackRegion) = False Or UBound($aBlackRegion) < 4) Then
    ;    SetLog("Wrong parameters passed to PickUpRandomVerifiedDropPoint Function", $COLOR_ERROR)
    ;    Return False
    ;EndIf
    ; We have disabled the Parameter function to to let it run unsafe, Devs has to take care of it, not the CPU!
    
    Local $iCheckedPoints = 0
    Local $bGotVerifiedPoint = False
    Local $aVerifiedPoint[2] = [-1, -1]
    Local $aCheckedIndexes[1] = [-1]
    Local $iRandomIndex = -1
    Local $bIsVerifiedPoint = False
    Local $oneDarray[2] = [-1, -1]
    While ($bGotVerifiedPoint = False And $iCheckedPoints < UBound($aDropPoints))
        $iRandomIndex = Random(0, UBound($aDropPoints) - 1, 1)
        ; Check if the Specific point is Already Checked
        While (_ArraySearch($aCheckedIndexes, $iRandomIndex, 0, 0, 1, 1, 0) > -1)
            $iRandomIndex = Int(Random(0, UBound($aDropPoints) - 1, 1))
        WEnd
        _ArrayAdd($aCheckedIndexes, $iRandomIndex)
        $oneDArray[0] = $aDropPoints[$iRandomIndex][0]
        $oneDArray[1] = $aDropPoints[$iRandomIndex][1]
        $bIsVerifiedPoint = VerifyDropPointA($oneDArray, $aBlackRegion)
        If $bIsVerifiedPoint Then
            $bGotVerifiedPoint = True
            $aVerifiedPoint = $oneDArray
        EndIf
        $iCheckedPoints += 1
    WEnd
    If $bGotVerifiedPoint = False Then
        Return "-1"
    EndIf

    Return $aVerifiedPoint
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
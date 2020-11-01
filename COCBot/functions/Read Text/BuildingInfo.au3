; #FUNCTION# ====================================================================================================================
; Name ..........: BuildingInfo
; Description ...:
; Syntax ........: BuildingInfo($iXstart, $iYstart)
; Parameters ....: $iXstart             - an integer value.
;                  $iYstart             - an integer value.
; Return values .: None
; Author ........: KnowJack, Boldina!
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom fix - Team AIO Mod++
; NOTE: Support for multilangue, more smart, fix some cases like lvl 26 bug.
Func BuildingInfo($iXstart, $iYstart)

	Local $aResult[3] = ["", "", ""]
	Local $sBldgText, $sStr

	$sBldgText = getNameBuilding($iXstart, $iYstart) ; Get Unit name and level with OCR
	If $sBldgText = "" Then ; try a 2nd time after a short delay if slow PC
		If _Sleep($DELAYBUILDINGINFO1) Then 
			Return $aResult
		EndIf
		$sBldgText = getNameBuilding($iXstart, $iYstart) ; Get Unit name and level with OCR
	EndIf
	
	If StringIsSpace($sBldgText) Then 
		Return $aResult
	EndIf

	$sBldgText = StringStripWS($sBldgText, 7) 
	
	$aResult[2] = OnlyNumbersInString($sBldgText)
	$sStr = StringSplit($sBldgText, "(", $STR_NOCOUNT)
	If @error Then 
		$aResult[1] = $sBldgText
	Else
		$aResult[1] = ($aResult[2] = 0) ? ("Broken") : ($sStr[0])
	EndIf
	
	If $aResult[1] <> "" Then $aResult[0] = 1
	If $aResult[2] <> "" Then $aResult[0] += 1
	
	Return $aResult
EndFunc   ;==>BuildingInfo

Func OnlyNumbersInString($s)
	Local $sString = "", $sOne
	For $i = 0 To StringLen($s)
		$sOne = StringMid($s, $i, 1)
		If StringIsDigit($sOne) Then $sString &= $sOne
	Next
	Return Number($sString)
EndFunc
#EndRegion - Custom fix - Team AIO Mod++

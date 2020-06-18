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

Func _GetLocationMine()
	Local $vMines = findMultipleQuick(@ScriptDir & "\imgxml\Storages\GoldMines", 7, Default, Default, Default, Default, 5)
	Local $vMinesS = findMultipleQuick(@ScriptDir & "\imgxml\Storages\Mines_Snow", 7, Default, Default, Default, Default, 5)
	
	Local $aReturn[0]
	If IsArray($vMines) Then
		For $i = 0 To UBound($vMines)-1
			Local $aTmp[2] = [$vMines[$i][1], $vMines[$i][2]]
			_ArrayAdd($aReturn, $aTmp, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	EndIf
	
	If IsArray($vMinesS) Then
		For $i = 0 To UBound($vMinesS)-1
			Local $aTmp[2] = [$vMinesS[$i][1], $vMinesS[$i][2]]
			_ArrayAdd($aReturn, $aTmp, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	EndIf
	
	Return (UBound($aReturn)-1 > 0) ? ($aReturn) : (-1)
EndFunc   ;==>GetLocationMine

Func _GetLocationElixir()
	Local $vCollectors = findMultipleQuick(@ScriptDir & "\imgxml\Storages\Collectors", 7, Default, Default, Default, Default, 5)
	Local $vCollectorsS = findMultipleQuick(@ScriptDir & "\imgxml\Storages\Collectors_Snow", 7, Default, Default, Default, Default, 5)

	Local $aReturn[0]
	If IsArray($vCollectors) Then
		For $i = 0 To UBound($vCollectors)-1
			Local $aTmp[2] = [$vCollectors[$i][1], $vCollectors[$i][2]]
			_ArrayAdd($aReturn, $aTmp, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	EndIf
	
	If IsArray($vCollectorsS) Then
		For $i = 0 To UBound($vCollectorsS)-1
			Local $aTmp[2] = [$vCollectorsS[$i][1], $vCollectorsS[$i][2]]
			_ArrayAdd($aReturn, $aTmp, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	EndIf
	
	Return (UBound($aReturn)-1 > 0) ? ($aReturn) : (-1)
EndFunc   ;==>GetLocationElixir

Func _GetLocationDarkElixir()
	Local $vCollectors = findMultipleQuick(@ScriptDir & "\imgxml\Storages\Drills", 3, Default, Default, Default, Default, 5)

	Local $aReturn[0]
	If IsArray($vCollectors) Then
		For $i = 0 To UBound($vCollectors)-1
			Local $aTmp[2] = [$vCollectors[$i][1], $vCollectors[$i][2]]
			_ArrayAdd($aReturn, $aTmp, 0, -1, -1, $ARRAYFILL_FORCE_SINGLEITEM)
		Next
	EndIf
	
	Return (UBound($aReturn)-1 > 0) ? ($aReturn) : (-1)
EndFunc   ;==>GetLocationDarkElixir
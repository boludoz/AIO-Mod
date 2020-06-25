; #FUNCTION# ====================================================================================================================
; Author ........: Michael Michta <MetalGX91 at GMail dot com>
; Modified.......: gcriaco <gcriaco at gmail dot com>; Ultima - 2D arrays supported, directional search, code cleanup, optimization; Melba23 - added support for empty arrays and row search; BrunoJ - Added compare option 3 to use a regex pattern
; Modified.......: Boldina !
; ===============================================================================================================================
Func __ArraySearch(Const ByRef $aArray, $vValue, $iStart = 0, $iEnd = 0, $iCase = 0, $iCompare = 0, $iForward = 1, $iSubItem = -1, $bRow = False)
	If Not IsArray($aArray) Then Return -1
	Select 
		Case ($iCompare = 0)
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, 2, $iForward, $iSubItem, $bRow)
		Case ($iCompare = 2)
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, 0, $iForward, $iSubItem, $bRow)
		Case Else 
			Return _ArraySearch($aArray, $vValue, $iStart, $iEnd, $iCase, $iCompare, $iForward, $iSubItem, $bRow)
	EndSelect
EndFunc   ;==>__ArraySearch

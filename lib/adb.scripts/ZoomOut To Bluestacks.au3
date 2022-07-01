#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.0
 Author:         Boldina

 Script Function:
	Converts minitouch script to Bluestacks

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <String.au3>
#include <Array.au3>
#include <File.au3>

Local $__Bluestacks5Conf = FileReadToArray(@scriptdir & "\ZoomOut.minitouch")
Local $iLineCount = @extended
For $i = 0 To UBound($__Bluestacks5Conf) -1
	Local $aBetwen = StringSplit($__Bluestacks5Conf[$i], " ", 2)
	If UBound($aBetwen) > 3 Then
		If $aBetwen[0] = "m" Or $aBetwen[0] = "d" Then
;~ 			_arraydisplay($aBetwen)
			$aBetwen[2] = Round(32767.0 / 860 * Int($aBetwen[2]))
			$aBetwen[3] = Round(32767.0 / 644 * Int($aBetwen[3]))
			$__Bluestacks5Conf[$i] = _ArrayToString($aBetwen, " ")
;~ 			_arraydisplay($aBetwen)

		EndIf
	EndIf
Next

_FileWriteFromArray(@scriptdir & "\ZoomOut.BlueStacks.minitouch", $__Bluestacks5Conf)
_FileWriteFromArray(@scriptdir & "\ZoomOut.BlueStacks2.minitouch", $__Bluestacks5Conf)
_FileWriteFromArray(@scriptdir & "\ZoomOut.BlueStacks5.minitouch", $__Bluestacks5Conf)

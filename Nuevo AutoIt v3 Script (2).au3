#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.15.3 (Beta)
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <MsgBoxConstants.au3>
#include <Array.au3>

Example()

Func Example()
    ; Using an Array
    Local $aArray[2] = ["AAA","BBB"]

    For $aArray In $vElement
        ConsoleWrite(_ArrayToString($vElement))
    Next

EndFunc   ;==>Example
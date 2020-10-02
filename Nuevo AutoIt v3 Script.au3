Local $strComputer = "."
Local $strFindProcess = "Notepad.exe"
Local $objWMI, $colResults, $objItem, $intCount, $answer
$objWMI = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
$colResults = $objWMI.ExecQuery("Select * from Win32_Process WHERE Name = '" & $strFindProcess & "'")
$intCount = $colResults
For $objItem in $colResults
	$objItem.Terminate()
Next
; #FUNCTION# ====================================================================================================================
; Name ..........: DeleteFiles
; Description ...: Delete files from a folder
; Syntax ........:
; Parameters ....: Folder with last caracther "\"  |   filter files   |  type of delete:0 delete file, 1: put into recycle bin
; Return values .: None
; Author ........: Sardo (2015-06), MonkeyHunter (05-2017)
; Modified ......:
; Needs..........: include <Date.au3> <File.au3> <FileConstants.au3> <MsgBoxConstants.au3>
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: Deletefiles("C:\Users\administrator\AppData\Local\Temp\", "*.*", 2,1) delete temp file >=2 days from now and put into recycle bin
; ===============================================================================================================================
Func Deletefiles($sFolder, $sFilter = "*", $daydiff = 120, $type = 0, $Recursion = $FLTAR_NORECUR)
	$sFolder &= "\" 
	Local $x
	Local $FileListName = _FileListToArrayRec($sFolder, $sFilter, $FLTAR_FILESFOLDERS, $Recursion) ; list files to an array
	If Not ((Not IsArray($FileListName)) Or (@error = 1)) Then
		For $x = $FileListName[0] To 1 Step -1
			Local $FileDate = FileGetTime($sFolder & $FileListName[$x])
			If IsArray($FileDate) Then
				Local $Date = $FileDate[0] & '/' & $FileDate[1] & '/' & $FileDate[2] & ' ' & $FileDate[3] & ':' & $FileDate[4] & ':' & $FileDate[5]
				;msgbox ("" , "" , " " & $FileListname[$x] & " ____ " & $Date & "_____" &  _DateDiff('D', $Date, _NowCalc()) )
				If _DateDiff('D', $Date, _NowCalc()) < $daydiff Then ContinueLoop
				;msgbox ("" , "" , "Delete " & $FileListname[$x] & " ____ " & $Date & "_____" &  _DateDiff('D', $Date, _NowCalc()) )
				If $type = 0 Then
					FileDelete($sFolder & $FileListName[$x])
				Else
					FileRecycle($sFolder & $FileListName[$x])
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Else
		Return False
	EndIf
	If $sFolder = $g_sProfileTempDebugPath Then ; remove empty folders in DEBUG directory
			$FileListName = _FileListToArray($sFolder, "*", $FLTA_FOLDERS)
			If IsArray($FileListName) Then
				For $x = $FileListName[0] To 1 Step -1
					If DirGetSize($sFolder & $FileListName[$x]) = 0 Then DirRemove($sFolder & $FileListName[$x])
				Next
			EndIf
		EndIf
	Return True
EndFunc   ;==>Deletefiles





















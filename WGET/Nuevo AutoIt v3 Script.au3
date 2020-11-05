#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.15.3 (Beta)
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
; Advanced example - downloading in the background
;~ Local $hDownload = InetGet("https://apkpure.com/es/clash-of-clans-coc/com.supercell.clashofclans/download?from=details", "aaa", 1, 1)
;~     Do
;~         Sleep(250)
;~     Until InetGetInfo($hDownload, 2)
;~     Local $nBytes = InetGetInfo($hDownload, 0)
;~     InetClose($hDownload)

;~ InetGet("https://download.apkpure.com/b/APK/Y29tLnN1cGVyY2VsbC5jbGFzaG9mY2xhbnNfMTI3OF9hODA5NjE0ZA?_fn=Q2xhc2ggb2YgQ2xhbnNfdjEzLjU3Ni44X2Fwa3B1cmUuY29tLmFwaw&as=ca5f6b24f0681540705f8e605482f6965fa1a489&ai=-284804977&at=1604428817&_sa=ai%2Cat&k=56c6fe446bd76fab831b790d1b9ac7de5fa44711&_p=Y29tLnN1cGVyY2VsbC5jbGFzaG9mY2xhbnM&c=2%7CGAME_STRATEGY%7CZGV2PVN1cGVyY2VsbCZ0PWFwayZzPTE1NjIxNTUyMiZ2bj0xMy41NzYuOCZ2Yz0xMjc4&w=1", "test.exe", 1, 1)

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Global $COLOR_ERROR, $COLOR_SUCCESS

Func SetDebugLog($i, $i2 = "")
	ConsoleWrite($i & @CRLF)
EndFunc

Func _Sleep($i)
	Sleep($i)
EndFunc

ConsoleWrite(DownloadFromURLAD("https://apkpure.com/es/xapk-installer/com.apkpure.installer/download?from=category", "COC.apk"))

Func DownloadFromURLAD($sURL, $sLocate = "download.txt", $sID = "iframe_download", $sTAG = "src=", $iMinByte = 1000000 )
	Local $hDownload = InetGet($sURL, @TempDir & "\TempDownload.txt")
    Local $aRetArray, $sFilePath = @TempDir & "\TempDownload.txt"

    ; Write it to file
    $aRetArray = FileReadToArray($sFilePath)
	For $i = 0 To UBound($aRetArray)-1
		If StringInStr($aRetArray[$i], $sID) > 0 And StringInStr($aRetArray[$i], $sTAG) > 0 Then
			Local $sString = StringStripWS($aRetArray[$i], $STR_STRIPALL )
			Local $a = StringSplit($sString, Chr(34), 2)
			If Not @error Then
			For $i2 = UBound($a) -1 To 0 Step -1
				Local $s = $a[$i2]
				If StringInStr($s, "http") > 0 Then
					If InetGetSize ( $s ) > $iMinByte Then

						Local $iBytesReceived,  $iFileSizeOnline, $hInet, $iPct

						SetDebugLog("Upgrading clash of clans. " & $s)

						ProgressOn("Download", "Upgrading clash of clans.", "0%")
						$hInet = InetGet($s, $sLocate, 1, 1) ;Forces a reload from the remote site and return immediately and download in the background
						$iFileSizeOnline = InetGetSize($s) ;Get file size
						While Not InetGetInfo($hInet, 2) ;Loop until download is finished+
							If _Sleep(500) Then Return SetError(0) ;Sleep for half a second to avoid flicker in the progress bar
							$iBytesReceived = InetGetInfo($hInet, 0) ;Get bytes received
							$iPct = Int($iBytesReceived / $iFileSizeOnline * 100) ;Calculate percentage
							ProgressSet($iPct, $iPct & "%") ;Set progress bar
						WEnd

						ProgressOff()

						SetDebugLog($sLocate)
						Local $iFileSize = FileGetSize($sLocate)
						If $iFileSizeOnline <> $iFileSize Then
							SetDebugLog("DownloadFromURLAD | FAIL. " & $iFileSize, $COLOR_ERROR)
							Return SetError(-1, 0, -1)
						Else
							SetDebugLog("DownloadFromURLAD | OK. " & $iFileSize, $COLOR_SUCCESS)
							SetError(0)
							Return $iFileSize
						EndIf

						ExitLoop 2
					Else
						Return SetError(-3, 0, -3)
					EndIf
				EndIf
			Next
			EndIf
		EndIf
	Next
	Return SetError(-2, 0, -2)
EndFunc   ;==>Example

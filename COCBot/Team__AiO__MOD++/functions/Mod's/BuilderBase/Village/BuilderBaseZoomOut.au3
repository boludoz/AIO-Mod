; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseZoomOutOn
; Description ...: Use on Builder Base attack
; Syntax ........: BuilderBaseZoomOutOnAttack()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
; Modified ......: Boldina
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func TestGetBuilderBaseSize()
	Setlog("** TestGetBuilderBaseSize START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	GetBuilderBaseSize(True, True)
	$g_bRunState = $Status
	Setlog("** TestGetBuilderBaseSize END**", $COLOR_DEBUG)
EndFunc   ;==>TestGetBuilderBaseSize

Func TestBuilderBaseZoomOut()
	Setlog("** TestBuilderBaseZoomOutOnAttack START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	BuilderBaseZoomOut(True)
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseZoomOutOnAttack END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseZoomOut

Func BuilderBaseZoomOut($DebugImage = False, $ForceZoom = False)
	Local $Size = GetBuilderBaseSize(False, $DebugImage) ; WihtoutClicks
	If $Size > 520 And $Size < 590 and Not $ForceZoom Then
		SetDebugLog("BuilderBaseZoomOut check!")
		Return True
	EndIf

	; Small loop just in case
	For $i = 0 To 5
		; Necessary a small drag to Up and right to get the Stone and Boat Images, Just once , coz in attack will display a red text and hide the boat
		If $i = 3 Then ClickDrag(100, 130, 230, 30)

		; Update shield status
		AndroidShield("AndroidOnlyZoomOut")
		; Run the ZoomOut Script
		If BuilderBaseSendZoomOut(False, $i) Then
				If _Sleep(500) Then ExitLoop
				If Not $g_bRunState Then Return
				; Get the Distances between images
				Local $Size = GetBuilderBaseSize(True, $DebugImage)
				SetDebugLog("[" & $i & "]BuilderBaseZoomOut $Size: " & $Size)
				If IsNumber($Size) And $Size > 0 Then ExitLoop
			; Can't be precise each time we enter at Builder base was deteced a new Zoom Factor!! from 563-616
			If $Size > 520 And $Size < 590 Then
				Return True
			EndIf
		Else
			SetDebugLog("[BBzoomout] Send Script Error!", $COLOR_DEBUG)
		EndIf
	Next

	Return False
EndFunc   ;==>BuilderBaseZoomOut

Func BuilderBaseSendZoomOut($Main = False, $i = 0)
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut IN]")
	If Not $g_bRunState Then Return
	AndroidZoomOut(0, Default, ($g_iAndroidZoomoutMode <> 2)) ; use new ADB zoom-out
	If @error <> 0 Then Return False
	SetDebugLog("[" & $i & "][BuilderBaseSendZoomOut OUT]")
	Return True
EndFunc   ;==>BuilderBaseSendZoomOut

Func GetBuilderBaseSize($WithClick = False, $bDebugLog = False)
	Local $iResult = 0, $aVillage = 0
	
	If Not $g_bRunState Then Return
	
	Local $sFiles = ["", "2"]
	
	_CaptureRegion2()
	
	For $sMode In $sFiles
		
		If Not $g_bRunState Then Return
		
		$aVillage = GetVillageSize($bDebugLog, $sMode & "stone", $sMode & "tree", Default, True, False)
	
		If UBound($aVillage) > 8 And not @error Then
			If StringLen($aVillage[9]) > 5 And StringIsSpace($aVillage[9]) = 0 Then
				$iResult = Floor(Pixel_Distance($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
				Return $iResult
			ElseIf StringIsSpace($aVillage[9]) = 1 Then
				Return 0
			EndIf
		EndIf
		
		If _Sleep($DELAYSLEEP * 10) Then Return
		
	Next
	
	Return 0
EndFunc   ;==>GetBuilderBaseSize

Func ZoomBuilderBaseMecanics($bAttack = True)
	Local $iSize = ($bAttack = True) ? (GetBuilderBaseSize()) : (0)
	
	If $iSize = 0 Then
		BuilderBaseZoomOut()
		If _Sleep($DELAYSLEEP * 10) Then Return
	EndIf
	
	If Not $g_bRunState Then Return

	Setlog("Builder Base Diamond: " & $iSize, $COLOR_INFO)
	Local $i = 0
	Do
		Setlog("Builder Base Attack Zoomout.")
		$iSize = GetBuilderBaseSize(False) ; WihtoutClicks
		
		If Not $g_bRunState Then Return

		If ($iSize < 575 And $iSize > 620) Or ($iSize = 0) Then
			BuilderBaseZoomOut()
			If _Sleep(1000) Then Return
		EndIf

		If $i > 5 Then ExitLoop
		$i += 1
	Until ($iSize >= 575 And $iSize <= 620) Or ($iSize <> 0)

	If $iSize = 0 Then
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - FAIL", $COLOR_ERROR)
	Else
		SetDebugLog("[BBzoomout] ZoomOut Builder Base - OK", $COLOR_SUCCESS)
	EndIf
	
	Return $iSize
EndFunc   ;==>GetBuilderBaseSize
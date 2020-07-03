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

Global $g_aPosSizeVillage[2] = [Null, Null]

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

Func GetBuilderBaseSize($WithClick = False, $DebugImage = False)

	  If Not $g_bRunState Then Return
	  Local $aVillage = GetVillageSize(True, "stone", "tree", Default, True)

	  If $aVillage <> 0 Then
		 Local $iResul = Floor(Pixel_Distance($aVillage[4], $aVillage[5], $aVillage[7], $aVillage[8]))
		 Return $iResul
	  EndIf

	 SetDebugLog("[BBzoomout] GetDistance Boat to Stone Error", $COLOR_ERROR)
	 Return 0
EndFunc   ;==>GetBuilderBaseSize
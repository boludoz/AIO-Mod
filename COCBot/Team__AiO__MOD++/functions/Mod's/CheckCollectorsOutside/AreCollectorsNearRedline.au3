; FUNCTION ====================================================================================================================
; Name ..........: AreCollectorsNearRedline
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .: True					more collectors near redline
;				 : False				less collectors outside than specified
; Author ........: Samkie (7 FEB 2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: None
; ===============================================================================================================================

Func AreCollectorsNearRedline($percent)
	SetLog("Locating Mines & Collectors", $COLOR_INFO)
	#cs
	; This Function will fill an Array with several informations after Mines, Collectores or Drills detection with Imgloc
	; [0] = x , [1] = y , [2] = Distance to Redline ,[3] = In/Out, [4] = Side,  [5]= Is array Dim[2] with 5 coordinates to deploy
	Local $sdirectory, $iMaxReturnPoints, $iMaxLevel, $offsetx, $offsety
	If Not $g_bRunState Then Return

	Local $iColNbr
	
	; Initial Timer
	Local $hTimer = TimerInit()

	; Prepared for Winter Theme
	If $g_iDetectedImageType = 1 Then
		$sdirectory = @ScriptDir & "\imgxml\Storages\All_Snow"
	Else
		$sdirectory = @ScriptDir & "\imgxml\Storages\All"
	EndIf

	; Necessary Variables
	Local $sCocDiamond = "ECD"
	Local $sRedLines = ""
	Local $iMinLevel = 1
	Local $sReturnProps = "objectname,objectpoints,nearpoints,redlinedistance"
	Local $bForceCapture = True

	; DETECTION IMGLOC
	Local $aResult = findMultiple($sdirectory, $sCocDiamond, $sRedLines, $iMinLevel, 1000, $iMaxReturnPoints, $sReturnProps, $bForceCapture)
	Local $aTEMP, $sObjectname, $aObjectpoints, $sNear, $sRedLineDistance
	Local $tempObbj, $sNearTemp, $Distance, $tempObbjs, $sString
	Local $distance2RedLine = 40

	; Get properties from detection
	If IsArray($aResult) And UBound($aResult) > 0 Then
		For $buildings = 0 To UBound($aResult) - 1
			If _Sleep(50) Then Return ; just in case on PAUSE
			If Not $g_bRunState Then Return ; Stop Button
			SetDebugLog(_ArrayToString($aResult[$buildings]))
			$aTEMP = $aResult[$buildings]
			$sObjectname = String($aTEMP[0])
			SetDebugLog("Building name: " & String($aTEMP[0]), $COLOR_INFO)
			$aObjectpoints = $aTEMP[1] ; number of  objects returned
			SetDebugLog("Object points: " & String($aTEMP[1]), $COLOR_INFO)
			$sNear = $aTEMP[2] ;
			SetDebugLog("Near points: " & String($aTEMP[2]), $COLOR_INFO)
			$sRedLineDistance = $aTEMP[3] ;
			SetDebugLog("Near points: " & String($aTEMP[3]), $COLOR_INFO)

			Switch String($aTEMP[0])
				Case "Mines"
					$offsetx = 3
					$offsety = 12
				Case "Collector"
					$offsetx = -9
					$offsety = 9
				Case "Drill"
					$offsetx = 2
					$offsety = 14
			EndSwitch
			
			$aObjectpoints = StringReplace($aObjectpoints, "||", "|")
			
			Local $aArray = StringSplit($aObjectpoints, "|", $STR_NOCOUNT)
			If StringIsSpace($aArray[0]) Then Return True
			
			For $j = 0 To UBound($aArray) -1
				$sString = StringRight($aObjectpoints, 1)
				If $sString = "|" Then $aObjectpoints = StringTrimRight($aObjectpoints, 1)
				$tempObbj = StringSplit($aObjectpoints, "|", $STR_NOCOUNT) ; several detected points
				$sNearTemp = StringSplit($sNear, "#", $STR_NOCOUNT) ; several detected 5 near points
				$Distance = StringSplit($sRedLineDistance, "#", $STR_NOCOUNT) ; several detected distances points
				For $i = 0 To UBound($tempObbj) - 1
					; Test the coordinates
					$tempObbjs = StringSplit($tempObbj[$i], ",", $STR_NOCOUNT) ;  will be a string : 708,360
					If UBound($tempObbjs) <> 2 Then ContinueLoop
					; Check double detections
					Local $DetectedPoint[2] = [Number($tempObbjs[0] + $offsetx), Number($tempObbjs[1] + $offsety)]
					If DoublePoint($aTEMP[0], $aReturn, $DetectedPoint) Then ContinueLoop
					; Include one more dimension
					Local $aReturn[6]
					$aReturn[0] = $DetectedPoint[0] ; X
					$aReturn[1] = $DetectedPoint[1] ; Y
					$aReturn[4] = Side($tempObbjs)
					$distance2RedLine = $aReturn[4] = "BL" ? 50 : 45
					$aReturn[5] = $sNearTemp[$i] <> "" ? $sNearTemp[$i] : "0,0" ; will be a string inside : 708,360|705,358|720,370|705,353|722,371
					$aReturn[2] = Number($Distance[$i]) > 0 ? Number($Distance[$i]) : 200
					$aReturn[3] = ($aReturn[2] > $distance2RedLine) ? ("In") : ("Out") ; > 40 pixels the resource is far away from redline
					If ($aReturn[UBound($aReturn) - 1][2] > $distance2RedLine) Then $iColNbr += 1 ; > 40 pixels the resource is far away from redline
				Next
			Next
			
		Next
		; End of building loop
		SetDebugLog($txtBuildings & " Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
		Return $aReturn
	Else
		SetLog("ERROR|NONE Building - Detection: " & $txtBuildings, $COLOR_INFO)
		Return True
	EndIf

		SetLog("Total collectors Found: " & $icolNbr)
		SetLog("Total collectors near red line: " & $iTotalCollectorNearRedline)
		If $iTotalCollectorNearRedline >= Round($icolNbr * $percent / 100) Then
			Return True
		EndIf
	EndIf
	If $g_bDebugMakeIMGCSV Then AttackCSVDEBUGIMAGE()
	Return False
	#ce
	Return True
EndFunc   ;==>AreCollectorsNearRedline

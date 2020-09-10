; #FUNCTION# ====================================================================================================================
; Name ..........: DropOnPixel
; Description ...:
; Syntax ........: DropOnPixel($troop, $listArrPixel, $number[, $slotsPerEdge = 0])
; Parameters ....: $troop               - Troop to deploy
;                  $listArrPixel        - Array of pixel where troop are deploy
;                  $number              - Number of troop to deploy
;                  $slotsPerEdge        - [optional] a string value. Default is 0.
; Return values .: None
; Author ........:
; Modified ......: ProMac (07-2018)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom SmartFarm - Team AIO Mod++
; Strategy :
; While troop left :
;	If number of troop > number of pixel => Search the number of troop to deploy by pixel
;	Else Search the offset to browse the tab of pixel
;	Browse the tab of pixel and send troop
Func DropOnPixel($sName, $listArrPixel, $Number, $slotsPerEdge = 0, $Random = False, $LastSide = False)
	If isProblemAffect(True) Then Return
	If Not IsAttackPage() Then Return
	Local $nameFunc = "[DropOnPixel]"
	debugRedArea($nameFunc & " IN ")
	If ($Number = 0 Or UBound($listArrPixel) = 0) Then Return
	KeepClicks()
	For $i = 0 To UBound($listArrPixel) - 1
		debugRedArea("$listArrPixel $i : [" & $i & "] ")
		Local $Offset = 1
		Local $nbTroopByPixel = 1
		Local $Clicked = 0
		Local $arrPixel = $listArrPixel[$i]
		Local $nbTroopsLeft = UBound($arrPixel) > $Number ? $Number : UBound($arrPixel)
		debugRedArea("UBound($arrPixel) " & UBound($arrPixel) & "$number :" & $Number)
		While ($nbTroopsLeft > 0)
			If (UBound($arrPixel) = 0) Then
				ExitLoop
			EndIf
			If (UBound($arrPixel) > $nbTroopsLeft) Then
				$Offset = UBound($arrPixel) / $nbTroopsLeft
			Else
				$nbTroopByPixel = Floor($Number / UBound($arrPixel))
			EndIf
			If ($Offset < 1) Then
				$Offset = 1
			EndIf
			If ($nbTroopByPixel < 1) Then
				$nbTroopByPixel = 1
			EndIf
			For $j = 0 To UBound($arrPixel) - 1 Step $Offset
				Local $index = Round($j)
				If ($index > UBound($arrPixel) - 1) Then
					$index = UBound($arrPixel) - 1
				EndIf
				Local $currentPixel = $arrPixel[Floor($index)]

				If Not IsArray($currentPixel) Or UBound($currentPixel) <> 2 Then
					$Clicked += ($nbTroopByPixel < 1) ? (1) : ($nbTroopByPixel)
					$nbTroopsLeft -= ($nbTroopByPixel < 1) ? (1) : ($nbTroopByPixel)
					ContinueLoop
				EndIf
				
				If $Random Then $currentPixel = DeployPointRandom($arrPixel[Floor($index)])
				
				If Not IsArray($currentPixel) Or UBound($currentPixel) <> 2 Then
					SetDebugLog("Error DropOnPixel with slot " & $sName + 1 & " array: " & _ArrayToString($arrPixel[Floor($index)]))
					$Clicked += ($nbTroopByPixel < 1) ? (1) : ($nbTroopByPixel)
					$nbTroopsLeft -= ($nbTroopByPixel < 1) ? (1) : ($nbTroopByPixel)
					ContinueLoop
				EndIf
				If $j >= Round(UBound($arrPixel) / 2) And $j <= Round((UBound($arrPixel) / 2) + $Offset) And $g_bIsHeroesDropped = False Then
					$g_aiDeployHeroesPosition[0] = $currentPixel[0]
					$g_aiDeployHeroesPosition[1] = $currentPixel[1]
					debugRedArea("Heroes : $slotsPerEdge = else ")
					debugRedArea("$offset: " & $Offset)
				EndIf
				If $j >= Round(UBound($arrPixel) / 2) And $j <= Round((UBound($arrPixel) / 2) + $Offset) And $g_bIsCCDropped = False Then
					$g_aiDeployCCPosition[0] = $currentPixel[0]
					$g_aiDeployCCPosition[1] = $currentPixel[1]
					debugRedArea("CC : $slotsPerEdge = else ")
					debugRedArea("$offset: " & $Offset)
				EndIf
				If Number($currentPixel[1]) > 555 + $g_iBottomOffsetY Then $currentPixel[1] = 555 + $g_iBottomOffsetY
				AttackClick($currentPixel[0], $currentPixel[1], $nbTroopByPixel, SetSleep(0), 0, "#0098")
				$Clicked += $nbTroopByPixel
				$nbTroopsLeft -= $nbTroopByPixel
			Next
		WEnd
		SetLog("Clicked " & $Clicked & "x at slot: " & $sName + 1, $COLOR_SUCCESS)
	Next
	ReleaseClicks()
	debugRedArea($nameFunc & " OUT ")
	Return $Clicked
EndFunc   ;==>DropOnPixel

Func DeployPointRandom($currentPixel)
	Local $sSide = Side($currentPixel)
	Local $x = Random(10, 20, 1)
	Local $y = Random(10, 20, 1)
	Switch $sSide
		Case "TL"
			$currentPixel[0] -= $x
			$currentPixel[1] -= $y
		Case "TR"
			$currentPixel[0] += $x
			$currentPixel[1] -= $y
		Case "BL"
			$currentPixel[0] -= $x
			$currentPixel[1] += $y
		Case "BR"
			$currentPixel[0] += $x
			$currentPixel[1] += $y
		Case Else
			
			Return -1
	EndSwitch
	Return $currentPixel
EndFunc   ;==>DeployPointRandom
#EndRegion - Custom SmartFarm - Team AIO Mod++

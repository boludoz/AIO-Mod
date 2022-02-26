; #FUNCTION# ====================================================================================================================
; Name ..........: dropHeroes
; Description ...: Will drop heroes in a specific coordinates, only if slot is Not -1,Only drops when option is clicked.
; Syntax ........: dropHeroes($x, $y, $iKingSlot = -1, $iQueenSlot = -1, $iWardenSlot = -1, $iChampionSlot = -1)
; Parameters ....: $x                   - an unknown value.
;                  $y                   - an unknown value.
;                  $KingSlot            - [optional] an unknown value. Default is -1.
;                  $QueenSlot           - [optional] an unknown value. Default is -1.
;                  $WardenSlot          - [optional] an unknown value. Default is -1.
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func dropheroes($x, $y, $kingslot = -1, $queenslot = -1, $wardenslot = -1, $championslot = -1, $smartfarm = False, $bsmartmilk = False)
	If $g_bdebugsetlog Then setdebuglog("dropHeroes KingSlot " & $kingslot & " QueenSlot " & $queenslot & " WardenSlot " & $wardenslot & " ChampionSlot " & $championslot & " matchmode " & $g_imatchmode, $color_debug)
	If _sleep($delaydropheroes1) Then Return 
	If $g_bAttackClickFC And $y > 485 + 88 And $x < 450 + 88 Then
		$y = 480 + 88
		setdebuglog("First Hero Deploy attack Protection")
		$g_bAttackClickFC = False
	EndIf
	Local $bdropking = False
	Local $bdropqueen = False
	Local $bdropwarden = False
	Local $bdropchampion = False
	If $kingslot <> -1 AND (($g_imatchmode <> $db AND $g_imatchmode <> $lb) OR BitAND($g_aiattackuseheroes[$g_imatchmode], $eheroking) = $eheroking) Then $bdropking = True
	If $queenslot <> -1 AND (($g_imatchmode <> $db AND $g_imatchmode <> $lb) OR BitAND($g_aiattackuseheroes[$g_imatchmode], $eheroqueen) = $eheroqueen) Then $bdropqueen = True
	If $wardenslot <> -1 AND (($g_imatchmode <> $db AND $g_imatchmode <> $lb) OR BitAND($g_aiattackuseheroes[$g_imatchmode], $eherowarden) = $eherowarden) Then $bdropwarden = True
	If $championslot <> -1 AND (($g_imatchmode <> $db AND $g_imatchmode <> $lb) OR BitAND($g_aiattackuseheroes[$g_imatchmode], $eherochampion) = $eherochampion) Then $bdropchampion = True
	If $g_bdebugsetlog Then setdebuglog("drop KING = " & $bdropking, $color_debug)
	If $g_bdebugsetlog Then setdebuglog("drop QUEEN = " & $bdropqueen, $color_debug)
	If $g_bdebugsetlog Then setdebuglog("drop WARDEN = " & $bdropwarden, $color_debug)
	If $g_bdebugsetlog Then setdebuglog("drop CHAMPION = " & $bdropchampion, $color_debug)
	Local $deplay = 100
	If $smartfarm Then $deplay = Random(1, 2, 1) * 1000
	If $bsmartmilk Then
		If $g_bdebugsetlog Then setdebuglog("$deplay: " & $deplay)
		setdebuglog("Deploy Warden -> King -> Queen -> Champion")
		dropwarden($bdropwarden, $wardenslot, $x, $y)
		If _sleep($deplay) Then Return 
		dropking($bdropking, $kingslot, $x, $y)
		If _sleep($deplay) Then Return 
		dropqueen($bdropqueen, $queenslot, $x, $y)
		If _sleep($deplay) Then Return 
		dropchampion($bdropchampion, $championslot, $x, $y)
	Else
		Local $bRandom = Random(0, 100, 1) > 50
		Switch $bRandom
			Case True
				dropking($bdropking, $kingslot, $x, $y)
				If _sleep($deplay) Then Return 
				dropqueen($bdropqueen, $queenslot, $x, $y)
				If _sleep($deplay) Then Return 
				setdebuglog("Deploy King -> Queen -> Warden -> Champion")
			Case Else
				dropqueen($bdropqueen, $queenslot, $x, $y)
				If _sleep($deplay) Then Return 
				dropking($bdropking, $kingslot, $x, $y)
				If _sleep($deplay) Then Return 
				setdebuglog("Deploy Queen -> King -> Warden -> Champion")
		EndSwitch
		If $g_bdebugsetlog Then setdebuglog("$deplay: " & $deplay)
		If $g_bdebugsetlog Then setdebuglog("Warden Slot x: " & $wardenslot)
		dropwarden($bdropwarden, $wardenslot, $x, $y)
		If _sleep($deplay) Then Return 
		If $g_bdebugsetlog Then setdebuglog("Champ Slot x: " & $wardenslot)
		dropchampion($bdropchampion, $championslot, $x, $y)
	EndIf
EndFunc

Func dropking($bdropking, $kingslot, $x, $y)
	If $bdropking AND Not $g_bdropking Then
		Local $htimer = __timerinit()
		SetLog("Dropping King", $color_info)
		Local $ikingslotclickx = getxposofarmyslot($kingslot, True)
		selectdroptroop($kingslot)
		For $i = 0 To 2
			If _wait4pixel($ikingslotclickx, 723, 0xFFFFFF, 1, 2000, "IsKingSlotSelected", 100) Then
				If $i = 0 Then attackclick($x, $y, 1, 0, 0, "#x999")
				If $i = 1 Then
					$x += Random(-10, 10, 1)
					$y += Random(-10, 10, 1)
					setdebuglog("Trying a diff deploy position. (" & $x & "," & $y & ")", $color_info)
					attackclick($x, $y, 1, 0, 0, "#x999")
				EndIf
				If _wait4pixelgone($ikingslotclickx, 723, 0xFFFFFF, 1, 1500, "IsKingDropped", 100) Then
					setdebuglog("King Took " & Round(__timerdiff($htimer)) & " ms To Get Dropped", $color_success)
					$g_bcheckkingpower = True
					$g_bdropking = True
					$g_aheroestimeractivation[$eherobarbarianking] = __timerinit()
					ExitLoop
				Else
					SetLog("Something Happened King Not Dropped", $color_info)
				EndIf
			Else
				SetLog("Something Happened Bot Unable To Select King Slot", $color_info)
				selectdroptroop($kingslot)
			EndIf
			If _sleep(1000) Then Return 
			If $i = 1 Then
				SetLog("Error selecting/deploying the King", $color_debug)
				If Not isdropredarea("King") Then
					savedebugimage("DropKing")
				Else
					betterpoint2deploy($x, $y)
				EndIf
			EndIf
		Next
	ElseIf $bdropking AND $g_bdropking AND $g_bcheckkingpower Then
		SetLog("Forcing King's ability on request", $color_info)
		selectdroptroop($kingslot)
		$g_icsvlasttrooppositiondroptroopfromini = $g_ikingslot
		$g_bcheckkingpower = False
	ElseIf $bdropking Then
		setdebuglog("Do Nothing as King already dropped.")
	EndIf
EndFunc

Func dropqueen($bdropqueen, $queenslot, $x, $y)
	If $bdropqueen AND Not $g_bdropqueen Then
		Local $htimer = __timerinit()
		SetLog("Dropping Queen", $color_info)
		Local $iqueenslotclickx = getxposofarmyslot($queenslot, True)
		selectdroptroop($queenslot)
		For $i = 0 To 2
			If _wait4pixel($iqueenslotclickx, 723, 0xFFFFFF, 1, 2000, "IsQueenSlotSelected", 100) Then
				If $i = 0 Then attackclick($x, $y, 1, 0, 0, "#x999")
				If $i = 1 Then
					$x += Random(-10, 10, 1)
					$y += Random(-10, 10, 1)
					setdebuglog("Trying a diff deploy position. (" & $x & "," & $y & ")", $color_info)
					attackclick($x, $y, 1, 0, 0, "#x999")
				EndIf
				If _wait4pixelgone($iqueenslotclickx, 723, 0xFFFFFF, 1, 1500, "IsQueenDropped", 100) Then
					setdebuglog("Queen Took " & Round(__timerdiff($htimer)) & " ms To Get Dropped", $color_success)
					$g_bcheckqueenpower = True
					$g_bdropqueen = True
					$g_aheroestimeractivation[$eheroarcherqueen] = __timerinit()
					ExitLoop
				Else
					SetLog("Something Happened Queen Not Dropped", $color_info)
				EndIf
			Else
				SetLog("Something Happened Bot Unable To Select Queen Slot", $color_info)
				selectdroptroop($queenslot)
			EndIf
			If _sleep(1000) Then Return 
			If $i = 1 Then
				SetLog("Error selecting/deploying the Queen", $color_debug)
				If Not isdropredarea("Queen") Then
					SaveDebugImage("DropQueen")
				Else
					betterpoint2deploy($x, $y)
				EndIf
			EndIf
		Next
	ElseIf $bdropqueen AND $g_bdropqueen AND $g_bcheckqueenpower Then
		SetLog("Forcing Queen's ability on request", $color_info)
		selectdroptroop($queenslot)
		$g_icsvlasttrooppositiondroptroopfromini = $g_iqueenslot
		$g_bcheckqueenpower = False
	ElseIf $bdropqueen Then
		setdebuglog("Do Nothing as Queen already dropped.")
	EndIf
EndFunc

Func dropwarden($bdropwarden, $wardenslot, $x, $y)
	If $bdropwarden AND Not $g_bdropwarden Then
		Local $htimer = __timerinit()
		SetLog("Dropping Grand Warden", $color_info)
		Local $iwardenslotclickx = getxposofarmyslot($wardenslot, True) - 11
		selectdroptroop($wardenslot)
		For $i = 0 To 2
			setdebuglog("Warden Slot check white : " & $iwardenslotclickx & "," & 723)
			If _wait4pixel($iwardenslotclickx, 723, 0xFFFFFF, 1, 2000, "IsWardenSlotSelected", 100) Then
				If $i = 0 Then attackclick($x, $y, 1, 0, 0, "#x999")
				If $i = 1 Then
					$x += Random(-10, 10, 1)
					$y += Random(-10, 10, 1)
					setdebuglog("Trying a diff deploy position. (" & $x & "," & $y & ")", $color_info)
					attackclick($x, $y, 1, 0, 0, "#x999")
				EndIf
				If _wait4pixelgone($iwardenslotclickx, 723, 0xFFFFFF, 1, 1500, "IsWardenDropped", 100) Then
					setdebuglog("Grand Warden Took " & Round(__timerdiff($htimer)) & " ms To Get Dropped", $color_success)
					$g_bcheckwardenpower = True
					$g_bdropwarden = True
					$g_aheroestimeractivation[$eherograndwarden] = __timerinit()
					ExitLoop
				Else
					SetLog("Something Happened Warden Not Dropped", $color_info)
				EndIf
			Else
				SetLog("Something Happened Bot Unable To Select Warden Slot", $color_info)
				selectdroptroop($wardenslot)
			EndIf
			If _sleep(1000) Then Return 
			If $i = 1 Then
				SetLog("Error selecting/deploying the Warden", $color_debug)
				If Not isdropredarea("Warden") Then
					SaveDebugImage("DropWarden")
				Else
					betterpoint2deploy($x, $y)
				EndIf
			EndIf
		Next
	ElseIf $bdropwarden AND $g_bdropwarden AND $g_bcheckwardenpower Then
		SetLog("Forcing Warden's ability on request", $color_info)
		selectdroptroop($wardenslot)
		$g_icsvlasttrooppositiondroptroopfromini = $g_iwardenslot
		$g_bcheckwardenpower = False
	ElseIf $bdropwarden Then
		setdebuglog("Do Nothing as Warden already dropped.")
	EndIf
EndFunc

Func dropchampion($bdropchampion, $championslot, $x, $y)
	If $bdropchampion AND Not $g_bdropchampion Then
		Local $htimer = __timerinit()
		SetLog("Dropping Royal Champion", $color_info)
		Local $ichampionslotclickx = getxposofarmyslot($championslot, True)
		selectdroptroop($championslot)
		For $i = 0 To 2
			setdebuglog("Champ Slot check white : " & $ichampionslotclickx & "," & 723)
			If _wait4pixel($ichampionslotclickx, 723, 0xFFFFFF, 1, 2000, "IsChampionSlotSelected", 100) Then
				If $i = 0 Then attackclick($x, $y, 1, 0, 0, "#x999")
				If $i = 1 Then
					$x += Random(-10, 10, 1)
					$y += Random(-10, 10, 1)
					setdebuglog("Trying a diff deploy position. (" & $x & "," & $y & ")", $color_info)
					attackclick($x, $y, 1, 0, 0, "#x999")
				EndIf
				If _wait4pixelgone($ichampionslotclickx, 723, 0xFFFFFF, 1, 1500, "IsChampionDropped", 100) Then
					setdebuglog("Royal Champion Took " & Round(__timerdiff($htimer)) & " ms To Get Dropped", $color_success)
					$g_bcheckchampionpower = True
					$g_bdropchampion = True
					$g_aheroestimeractivation[$eheroroyalchampion] = __timerinit()
					ExitLoop
				Else
					SetLog("Something Happened Champion Not Dropped", $color_info)
				EndIf
			Else
				SetLog("Something Happened Bot Unable To Select Champion Slot", $color_info)
				selectdroptroop($championslot)
			EndIf
			If _sleep(1000) Then Return 
			If $i = 1 Then
				SetLog("Error selecting/deploying the Champion", $color_debug)
				If Not isdropredarea("Champion") Then
					SaveDebugImage("DropChampion")
				Else
					betterpoint2deploy($x, $y)
				EndIf
			EndIf
		Next
	ElseIf $bdropchampion AND $g_bdropchampion AND $g_bcheckchampionpower Then
		SetLog("Forcing Champion's ability on request", $color_info)
		selectdroptroop($championslot)
		$g_icsvlasttrooppositiondroptroopfromini = $g_ichampionslot
		$g_bcheckchampionpower = False
	ElseIf $bdropchampion Then
		setdebuglog("Do Nothing as Champion already dropped.")
	EndIf
EndFunc

Func betterpoint2deploy(ByRef $x, ByRef $y)
	Local $pixel[2] = [$x, $y]
	Local $j4534 = side($pixel)
	Switch $j4534
		Case "TL"
			$x -= 10
			$y -= 10
		Case "TR"
			$x += 10
			$y -= 10
		Case "BL"
			$x -= 15
			$y += 15
		Case "BR"
			$x += 15
			$y += 15
	EndSwitch
	setdebuglog("New coordinate is (" & $x & "," & $y & ")")
EndFunc

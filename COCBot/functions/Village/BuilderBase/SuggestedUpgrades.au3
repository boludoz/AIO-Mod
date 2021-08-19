; #FUNCTION# ====================================================================================================================
; Name ..........: SuggestedUpgrades()
; Description ...: Goes to Builders Island and Upgrades buildings with 'suggested upgrades window'.
; Syntax ........: SuggestedUpgrades()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017), Team AIO Mod++ (2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; coc-armycamp ---> OCR the values on Builder suggested updates
; coc-build ----> building names and levels [ needs some work on 'u' and 'e' ]  BuildingInfo

; Zoomout
; If Suggested Upgrade window is open [IMAGE] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\IsSuggestedWindowOpened_0_92.png
; Image folder [GOLD] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\Gold_0_89.png
; Image folder [GOLD] -> C:\Users\user\Documents\MDOCOCPROJECT\imgxml\Resources\PicoBuildersBase\SuggestedUpdates\Elixir_0_89.png

; Buider Icon position Blue[i] [Check color] [360, 11, 0x7cbdde, 10]
; Suggested Upgrade window position [Imgloc] [380, 59, 100, 20]
; Zone to search for Gold / Elixir icons and values [445, 100, 90, 85 ]
; Gold offset for OCR [Point] [x,y, length]  ,x = x , y = - 10  , length = 535 - x , Height = y + 7   [17]
; Elixir offset for OCR [Point] [x,y, length]  ,x = x , y = - 10  , length = 535 - x , Height = y + 7 [17]
; Buider Name OCR ::::: BuildingInfo(242, 580)
; Button Upgrade position [275, 670, 300, 30]  -> UpgradeButton_0_89.png
; Button OK position Check Pixel [430, 540, 0x6dbd1d, 10] and CLICK

; Draft
; 01 - Verify if we are on Builder island [Boolean]
; 01.1 - Verify available builder [ OCR - coc-Builders ] [410 , 23 , 40 ]
; 02 - Click on Builder [i] icon [Check color]
; 03 - Verify if the window opened [Boolean]
; 04 - Detect Gold and Exlir icons [Point] by a dynamic Y [ignore list]
; 05 - With the previous positiosn and a offset , proceeds with OCR : [WHITE] OK , [salmon] Not enough resources will return "" [strings] convert to [integer]
; 06 - Make maths , IF the Gold is selected on GUI , if Elixir is Selected on GUI , and the resources values and min to safe [Boolean]
; 07 - Click on he correct ICon on Suggested Upgrades window [Point]
; 08 - Verify buttons to upgrade [Point] - Detect the Builder name [OCR]
; 09 - Verify the button to upgrade window [point]  -> [Boolean] ->[check pixel][imgloc]
; 10 - Builder Base report
; 11 - DONE

; GUI
; Check Box to enable the function
; Ignore Gold , Ignore Elixir
; Ignore building names
; Setlog

Func chkActivateBBSuggestedUpgrades()
	; CheckBox Enable Suggested Upgrades [Update values][Update GUI State]
	If GUICtrlRead($g_hChkBBSuggestedUpgrades) = $GUI_CHECKED Then
		$g_iChkBBSuggestedUpgrades = 1
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_ENABLE)
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_ENABLE)
		#Region - Custom BB Army - Team AIO Mod++
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, $GUI_ENABLE)
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, $GUI_ENABLE)
		GUICtrlSetState($g_hChkPlacingNewBuildings, $GUI_ENABLE)
		For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
			GUICtrlSetState($g_hChkBBUpgradesToIgnore[$i], $GUI_ENABLE)
		Next
		#EndRegion - Custom BB Army - Team AIO Mod++
	Else
		$g_iChkBBSuggestedUpgrades = 0
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		#Region - Custom BB Army - Team AIO Mod++
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetState($g_hChkPlacingNewBuildings, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		For $i = 0 To UBound($g_iChkBBUpgradesToIgnore) - 1
			GUICtrlSetState($g_hChkBBUpgradesToIgnore[$i], $GUI_DISABLE)
		Next
		#EndRegion - Custom BB Army - Team AIO Mod++
	EndIf
EndFunc   ;==>chkActivateBBSuggestedUpgrades

Func chkActivateBBSuggestedUpgradesGold()
	; if disabled, why continue?
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	; Ignore Upgrade Building with Gold [Update values]
	$g_iChkBBSuggestedUpgradesIgnoreGold = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreGold) = $GUI_CHECKED) ? 1 : 0
	; If Gold is Selected Than we can disable the Builder Hall [is gold] and Wall almost [is Gold]
	If $g_iChkBBSuggestedUpgradesIgnoreGold = 0 Then
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, $GUI_ENABLE)
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, $GUI_ENABLE)
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreElixir, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreHall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
;~ 		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreWall, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	EndIf
	; Ignore Upgrade Builder Hall [Update values]
;~ 	$g_iChkBBSuggestedUpgradesIgnoreHall = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreHall) = $GUI_CHECKED) ? 1 : 0
	; Update Elixir value
	$g_iChkBBSuggestedUpgradesIgnoreElixir = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreElixir) = $GUI_CHECKED) ? 1 : 0
	; Ignore Wall
;~ 	$g_iChkBBSuggestedUpgradesIgnoreWall = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreWall) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkActivateBBSuggestedUpgradesGold

Func chkActivateBBSuggestedUpgradesElixir()
	; if disabled, why continue?
	If $g_iChkBBSuggestedUpgrades = 0 Then Return
	; Ignore Upgrade Building with Elixir [Update values]
	$g_iChkBBSuggestedUpgradesIgnoreElixir = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreElixir) = $GUI_CHECKED) ? 1 : 0
	If $g_iChkBBSuggestedUpgradesIgnoreElixir = 0 Then
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkBBSuggestedUpgradesIgnoreGold, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
	EndIf
	; Update Gold value
	$g_iChkBBSuggestedUpgradesIgnoreGold = (GUICtrlRead($g_hChkBBSuggestedUpgradesIgnoreGold) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkActivateBBSuggestedUpgradesElixir

Func chkPlacingNewBuildings()
	$g_iChkPlacingNewBuildings = (GUICtrlRead($g_hChkPlacingNewBuildings) = $GUI_CHECKED) ? 1 : 0
EndFunc   ;==>chkPlacingNewBuildings

; MAIN CODE
#Region - Bulder base upgrades - Team AIO Mod++
Global $g_bBuildingUpgraded = False

Func MainSuggestedUpgradeCode($bDebug = $g_bDebugSetlog)
	Local $aResourcesPicks[0][3], $aResourcesReset[0][3], $aMatrix[1][3], $aResult[3] = [-1, -1, ""]

	Local $aArrayMultipixel[2][3] = [[0xDDDBDB, 54, 0], [0xDDE0DB, 74, 0]]
	Local $vMultipix = 0
	Local $iyMax = 368
	Local $aAreaToSearch[4] = [374, 72, 503, $iyMax]

	$g_bBuildingUpgraded = False

	; If is not selected return
	If $g_iChkBBSuggestedUpgrades = 0 Then Return

	BuilderBaseReport()

	If isOnBuilderBase(True) Then

		SetLog(" - Upg Window Opened successfully", $COLOR_INFO)

		For $z = 0 To 2     ; For do scroll 3 times.
			
			For $iClick = 0 To 1
				$vMultipix = _MultiPixelSearch(309, 102, 439, 379, 2, 2, Hex(0xE4E8E6, 6), $aArrayMultipixel, 25)
				If $vMultipix = 0 Then
					ClickOnBuilder()
					If _Sleep(500) Then Return
				Else
					$iyMax = $vMultipix[1]
					ExitLoop
				EndIf
			Next
			
			$aAreaToSearch[3] = $iyMax
			
			_CaptureRegion2()

			If $g_iChkBBSuggestedUpgradesIgnoreElixir = 0 And $g_aiCurrentLootBB[$eLootElixirBB] > 250 Then
				If UBound(_ImageSearchXML($g_sImgAutoUpgradeElixir, 10, $aAreaToSearch, False, True, True, 8, 0, 1000)) > 0 And Not @error Then
					For $iItem = 0 To UBound($g_aImageSearchXML) - 1
						If UBound(_PixelSearch(512, $g_aImageSearchXML[$iItem][2] - 14, 529, $g_aImageSearchXML[$iItem][2] + 14, Hex(0xFFFFFF, 6), 15)) > 0 And Not @error Then
							$aMatrix[0][0] = (UBound(_PixelSearch(310, $g_aImageSearchXML[$iItem][2] - 14, 340, $g_aImageSearchXML[$iItem][2] + 14, Hex(0x0DFF0D, 6), 15)) > 0 And Not @error) ? ("New") : ("Elixir")
							If ($g_iChkPlacingNewBuildings = 1 And $aMatrix[0][0] = "New") Or $aMatrix[0][0] <> "New" Then
								$aMatrix[0][1] = $g_aImageSearchXML[$iItem][1]
								$aMatrix[0][2] = $g_aImageSearchXML[$iItem][2]
								_ArrayAdd($aResourcesPicks, $aMatrix)
							EndIf
						EndIf
					Next
				EndIf
			EndIf

			If $g_iChkBBSuggestedUpgradesIgnoreGold = 0 And $g_aiCurrentLootBB[$eLootGoldBB] > 250 Then
				If UBound(_ImageSearchXML($g_sImgAutoUpgradeGold, 10, $aAreaToSearch, False, True, True, 8, 0, 1000)) > 0 And Not @error Then
					For $iItem = 0 To UBound($g_aImageSearchXML) - 1
						If UBound(_PixelSearch(512, $g_aImageSearchXML[$iItem][2] - 14, 529, $g_aImageSearchXML[$iItem][2] + 14, Hex(0xFFFFFF, 6), 15)) > 0 And Not @error Then
							$aMatrix[0][0] = (UBound(_PixelSearch(310, $g_aImageSearchXML[$iItem][2] - 14, 340, $g_aImageSearchXML[$iItem][2] + 14, Hex(0x0DFF0D, 6), 15)) > 0 And Not @error) ? ("New") : ("Gold")
							If ($g_iChkPlacingNewBuildings = 1 And $aMatrix[0][0] = "New") Or $aMatrix[0][0] <> "New" Then
								$aMatrix[0][1] = $g_aImageSearchXML[$iItem][1]
								$aMatrix[0][2] = $g_aImageSearchXML[$iItem][2]
								_ArrayAdd($aResourcesPicks, $aMatrix)
							EndIf
						EndIf
					Next
				EndIf
			EndIf

			; _ArrayDisplay($aResourcesPicks)

			If UBound($aResourcesPicks) > 0 Then

				For $i = 0 To UBound($aResourcesPicks) - 1
					$aResult[0] = $aResourcesPicks[$i][1]
					$aResult[1] = $aResourcesPicks[$i][2]
					$aResult[2] = $aResourcesPicks[$i][0]

					If $aResult[2] = "New" Then
						$g_bBuildingUpgraded = NewBuildings($aResult)
						If $g_bBuildingUpgraded Then
							SetLog("[" & $i + 1 & "]" & " New Building detected, placing it.", $COLOR_INFO)
							ExitLoop
						EndIf
					Else
						Click($aResult[0], $aResult[1], 1)
						If _Sleep(1000) Then Return

						$g_bBuildingUpgraded = GetUpgradeButton($aResult, $bDebug)
						If $g_bBuildingUpgraded Then
							SetLog("[" & $i + 1 & "]" & " Building detected, try upgrading it.", $COLOR_INFO)
							ExitLoop
						EndIf
					EndIf

					For $iClick = 0 To 1
						$vMultipix = _MultiPixelSearch(309, 102, 439, 379, 2, 2, Hex(0xE4E8E6, 6), $aArrayMultipixel, 25)
						If $vMultipix = 0 Then
							ClickOnBuilder()
							If _Sleep(500) Then Return
							ContinueLoop
						EndIf
						ExitLoop
					Next

					If _Sleep(Random(750, 1500, 1)) Then Return

				Next

			Else
				SetLog("Bad MainSuggestedUpgradeCode array.", $COLOR_ERROR)
				ExitLoop
			EndIf

			If $g_bBuildingUpgraded Then
				Setlog("Exiting of improvements.", $COLOR_INFO)
				ExitLoop
			Else
				$aResourcesPicks = $aResourcesReset
				ClickDrag(333, 102, 333, 80, 1000)     ; Do scroll down.
				If _Sleep(3000) Then Return
			EndIf

		Next

	EndIf

	ClickAway()

EndFunc   ;==>MainSuggestedUpgradeCode
#EndRegion - Bulder base upgrades - Team AIO Mod++

; This fucntion will Open the Suggested Window and check if is OK
Func ClickOnBuilder()

	; Master Builder Check pixel [i] icon
	Local Const $aMasterBuilder[4] = [360, 11, 0x7cbdde, 10]

	; Debug Stuff
	Local $sDebugText = ""
	Local Const $Debug = False
	Local Const $Screencap = True

	getBuilderCount(True, True)

	; Master Builder is not available return
	If $g_iFreeBuilderCountBB = 0 Then SetLog("No Master Builder available! [" & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB & "]", $COLOR_INFO)

	; Master Builder available
	If $g_iFreeBuilderCountBB > 0 Then
		; Check the Color and click
		If _CheckPixel($aMasterBuilder, True) Then
			; Click on Builder
			Click($aMasterBuilder[0], $aMasterBuilder[1], 1)
			If _Sleep(2000) Then Return
			; Let's verify if the Suggested Window open
			Local $aArrayMultipixel[2][3] = [[0xDDDBDB, 54, 0], [0xDDE0DB, 74, 0]]
			If _MultiPixelSearch(309, 102, 439, 379, 2, 2, Hex(0xE4E8E6, 6), $aArrayMultipixel, 25) <> 0 Then
				Return True
			Else
				$sDebugText = "Window didn't opened"
			EndIf
		Else
			$sDebugText = "BB Pixel problem"
		EndIf
	EndIf
	If $sDebugText <> "" Then SetLog("Problem on Suggested Upg Window: [" & $sDebugText & "]", $COLOR_ERROR)
	Return False
EndFunc   ;==>ClickOnBuilder

#Region - Bulder base upgrades - Team AIO Mod++
Func GetUpgradeButton($sUpgButtom = "", $bDebug = False)

	;Local $aBtnPos = [360, 500, 180, 50] ; x, y, w, h
	Local $aBtnPos = [360, 460, 740, 580] ; x, y, w, h ; support Battke Machine, broken and upgrade
	Local $aResetBB[3] = ["", "", ""]

	If $sUpgButtom = "" Then Return

	If $sUpgButtom = "Elixir" Then $sUpgButtom = $g_sImgAutoUpgradeBtnElixir
	If $sUpgButtom = "Gold" Then $sUpgButtom = $g_sImgAutoUpgradeBtnGold

	; Clean.
	$g_aBBUpgradeResourceCostDuration = $aResetBB
	$g_aBBUpgradeNameLevel = $aResetBB

	If _WaitForCheckImg($g_sImgAutoUpgradeBtnDir, "182, 565, 685, 723") Then
		If UBound($g_aImageSearchXML) > 0 And Not @error Then
			$g_aBBUpgradeNameLevel = BuildingInfo(245, 490 + $g_iBottomOffsetY)
			If $g_aBBUpgradeNameLevel[0] = 2 Then
				SetLog("Building: " & $g_aBBUpgradeNameLevel[1], $COLOR_INFO)

				; Verify if is to Upgrade
				Local $sMsg = "", $bBuildString = False
				For $i = 0 To UBound($g_sBBUpgradesToIgnore) - 1
					$bBuildString = _CompareTexts($g_sBBUpgradesToIgnore[$i], $g_aBBUpgradeNameLevel[1])
					If $bBuildString = True And $g_iChkBBUpgradesToIgnore[$i] = 1 Then
						$sMsg = "Ops! " & $g_aBBUpgradeNameLevel[1] & " is not to Upgrade!"
						SetLog($sMsg, $COLOR_ERROR)

						$g_aBBUpgradeResourceCostDuration = $aResetBB
						$g_aBBUpgradeNameLevel = $aResetBB

						Return False
					ElseIf $bBuildString = True And $g_iChkBBUpgradesToIgnore[$i] = 0 Then
						ExitLoop
					EndIf
				Next

				If _MultiPixelSearch($g_aImageSearchXML[0][1], 579, $g_aImageSearchXML[0][2] + 67, 613, 2, 2, Hex(0xFF887F, 6), StringSplit2D("0xFF887F-0-1|0xFF887F-4-0"), 35) <> 0 Then
					SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
					ClickAway()

					$g_aBBUpgradeResourceCostDuration = $aResetBB
					$g_aBBUpgradeNameLevel = $aResetBB

					Return False
				EndIf

				Click($g_aImageSearchXML[0][1], $g_aImageSearchXML[0][2], 1)
				If _Sleep(1500) Then Return

				If StringInStr($g_aBBUpgradeNameLevel[2], "Broken") = 0 Then
					$g_aBBUpgradeResourceCostDuration[0] = $sUpgButtom
					If StringInStr($g_aBBUpgradeNameLevel[1], "Machine") > 0 Then
						$g_aBBUpgradeResourceCostDuration[1] = getResourcesUpgrade(598, 509 + 44)
						$g_aBBUpgradeResourceCostDuration[2] = getHeroUpgradeTime(578, 450 + 44)
					Else
						$g_aBBUpgradeResourceCostDuration[1] = getResourcesUpgrade(366, 473 + 44)
						$g_aBBUpgradeResourceCostDuration[2] = getBldgUpgradeTime(190, 292 + 44)
					EndIf
				EndIf

				If _WaitForCheckImg($sUpgButtom, $aBtnPos) Then
					Click($g_aImageSearchXML[0][1], $g_aImageSearchXML[0][2], 1)
					If _Sleep(500) Then Return

					If isGemOpen(True) Then
						SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
						ClickAway()
						If _Sleep(500) Then Return
						ClickAway()

						$g_aBBUpgradeResourceCostDuration = $aResetBB
						$g_aBBUpgradeNameLevel = $aResetBB

						Return False
					Else
						SetLog($g_aBBUpgradeNameLevel[1] & " Upgrading!", $COLOR_INFO)
						ClickAway()
						; $g_bBuildingUpgraded = True
						Return True
					EndIf
				Else
					Local $bHammerBuilding = WaitforPixel(352, 490, 511, 566, Hex(0x7C8AFF, 6), 30, 10)
					If $bHammerBuilding = True Then
						SetLog("Hammer Building Detected!", $COLOR_ERROR)
					Else
						; SetLog("Not enough Resources to Upgrade " & $g_aBBUpgradeNameLevel[1] & " !", $COLOR_ERROR)
						SetLog("Fail upgrade " & $g_aBBUpgradeNameLevel[1] & " !", $COLOR_ERROR)
					EndIf

					ClickAway()
					If _Sleep(250) Then Return
				EndIf

			EndIf
		EndIf
	Else
		Setlog("g_sImgAutoUpgradeBtnDir fail.", $COLOR_ERROR)
	EndIf

	$g_aBBUpgradeResourceCostDuration = $aResetBB
	$g_aBBUpgradeNameLevel = $aResetBB

	Return False
EndFunc   ;==>GetUpgradeButton
#EndRegion - Bulder base upgrades - Team AIO Mod++

Func NewBuildings($aResult)

	Local $Screencap = True, $Debug = False

	If UBound($aResult) = 3 And $aResult[2] = "New" Then

		Click($aResult[0], $aResult[1], 1)
		If _Sleep(3000) Then Return

		If _WaitForCheckImg(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\Upgrade\New\", "14, 175, 847, 667", Default, 4500) Then
			Click($g_aImageSearchXML[0][1] - 100, $g_aImageSearchXML[0][2] + 100, 1)
			If _Sleep(2000) Then Return

			; Lets search for the Correct Symbol on field
			If QuickMIS("BC1", $g_sImgAutoUpgradeNewBldgYes, 150, 150, 650, 550, $Screencap, $Debug) Then
				Click($g_iQuickMISX + 150, $g_iQuickMISY + 150, 1)
				SetLog("Placed a new Building on Builder Island! [" & $g_iQuickMISX + 150 & "," & $g_iQuickMISY + 150 & "]", $COLOR_INFO)
				If _Sleep(1000) Then Return

				; Lets check if exist the [x] , Some Buildings like Traps when you place one will give other to place automaticly!
				If QuickMIS("BC1", $g_sImgAutoUpgradeNewBldgNo, 150, 150, 650, 550, $Screencap, $Debug) Then
					Click($g_iQuickMISX + 150, $g_iQuickMISY + 150, 1)
				EndIf

				Return True
			Else
				If QuickMIS("BC1", $g_sImgAutoUpgradeNewBldgNo, 150, 150, 650, 550, $Screencap, $Debug) Then
					SetLog("Sorry! Wrong place to deploy a new building on BB! [" & $g_iQuickMISX + 150 & "," & $g_iQuickMISY + 150 & "]", $COLOR_ERROR)
					Click($g_iQuickMISX + 150, $g_iQuickMISY + 150, 1)
				Else
					SetLog("Error on Undo symbol!", $COLOR_ERROR)
				EndIf
			EndIf
		Else
			SetLog("Fail NewBuildings.", $COLOR_INFO)
			Click(820, 38, 1) ; exit from Shop
		EndIf

	EndIf

	Return False

EndFunc   ;==>NewBuildings


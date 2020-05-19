; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Design
; Description ...: This file creates the "MOD" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: NguyenAnhHD
; Modified ......: Team AiO MOD++ (2019)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_MOD = 0
Global $g_hGUI_MOD_TAB = 0, $g_hGUI_MOD_TAB_ITEM1 = 0, $g_hGUI_MOD_TAB_ITEM2 = 0, $g_hGUI_MOD_TAB_ITEM3 = 0, $g_hGUI_MOD_TAB_ITEM4 = 0, $g_hGUI_MOD_TAB_ITEM5 = 0, _
$g_hGUI_MOD_TAB_ITEM6 = 0, $g_hGUI_MOD_TAB_ITEM7 = 0

#include "MOD GUI Design - SuperXP.au3"
#include "MOD GUI Design - Humanization.au3"
#include "MOD GUI Design - ChatActions.au3"
#include "MOD GUI Design - GTFO.au3"
#include "MOD GUI Design - AiO-Debug.au3"
#include "MOD GUI Design - WarPreparation.au3"
#include "MOD GUI Design - Builder Base.au3"

Func CreateMODTab()

	$g_hGUI_MOD = _GUICreate("", $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $_GUI_CHILD_LEFT, $_GUI_CHILD_TOP, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hFrmBotEx)

	GUISwitch($g_hGUI_MOD)
	$g_hGUI_MOD_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab1, $g_iSizeHGrpTab1, $TCS_RIGHTJUSTIFY)

		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_00", "Super XP"))
			TabSuperXPGUI()
		$g_hGUI_MOD_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_02", "Humanization"))
			TabHumanizationGUI()
		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_03", "Chat"))
			TabChatActionsGUI()
		$g_hGUI_MOD_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_04", "GTFO"))
			TabGTFOGUI()
		$g_hGUI_MOD_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_05", "Prewar"))
			TabWarPreparationGUI()
		$g_hGUI_MOD_TAB_ITEM6 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_06", "Misc"))
			TabMiscGUI()

	If $g_bDevMode Then
		$g_hGUI_MOD_TAB_ITEM7 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_07", "Debug"))
			TabDebugGUI()
		EndIf

	GUICtrlCreateTabItem("")
EndFunc   ;==>CreateMODTab

; Tab Misc GUI - Team AiO MOD++
 Func TabMiscGUI()
	SplashStep("Loading M0d - Misc...")

	;Local $x = 10, $y = 45

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "DelayLabel",  "Delay"), 7, 45, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "DelayTip",  "Delay before performing each action. You can add time before each action to improve performance and lower CPU usage."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hUseSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseSleep",  "Custom delay; CPU: - : higher, / + : lower."), 32, 80, 365, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hIntSleep = GUICtrlCreateSlider(32, 104, 250, 25, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS))
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "UseSleep", "Increase for all delay setting, more stabilize for slow PC/Multi Emulators."))
	_GUICtrlSlider_SetTipSide(-1, $TBTS_BOTTOM)
	_GUICtrlSlider_SetTicFreq(-100, 100)
	GUICtrlSetLimit(-1, 200, -99)
	GUICtrlSetData(-1, 20)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hDelayLabel = GUICtrlCreateLabel("20", 192 + 97, 112, 36, 17)

	$g_hUseRandomSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "UseRandomSleep",  "Random"), 32, 136, 81, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	$g_hNoAttackSleep = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "NoAttackSleep",  "Do not use this during the attack."), 32, 160, 177, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "AttackLabel",  "Attack"), 7, 192, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "AttackTip",  "Attacks extra functions."))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

  	$g_hSkipfirstcheck = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "Skipfirstcheck.",  "Skip first check."), 32, 224, 161, 17)
  	GUICtrlSetOnEvent(-1, "chkDelayMod")
  	_GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "SkipfirstcheckTip", "Skip first check without attack first."))

	$g_hDisableColorLog = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "DisableColorLog",  "No color attack log"), 32, 248, 113, 17)

	GUICtrlCreateLabel(GetTranslatedFileIni("MiscMODs", "OtherSettingsLabel", "Other"), 7, 280, 436, 22, BitOR($SS_CENTER,$SS_CENTERIMAGE))
	GUICtrlSetTip(-1, GetTranslatedFileIni("MiscMODs", "OtherSettingsTip", "Other settings"))
	GUICtrlSetBkColor(-1, 0x333300)
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$g_hAvoidLocation = GUICtrlCreateCheckbox(GetTranslatedFileIni("MiscMODs", "AvoidLocation", "Skip buildings location."), 32, 312, 105, 17)
	GUICtrlSetOnEvent(-1, "chkDelayMod")

	GUICtrlCreateTabItem("")
EndFunc   ;==>TabMiscGUI

Global $g_hChkCollectMagicItems, $g_hChkCollectFree, _
$g_hBtnMagicItemsConfig, _
$g_hChkBuilderPotion, $g_hChkClockTowerPotion, $g_hChkHeroPotion, $g_hChkLabPotion, $g_hChkPowerPotion, $g_hChkResourcePotion, _
$g_hComboClockTowerPotion, $g_hComboHeroPotion, $g_hComboPowerPotion, _
$g_hInputBuilderPotion, $g_hInputLabPotion, $g_hInputGoldItems, $g_hInputElixirItems, $g_hInputDarkElixirItems

Func CreateMiscMagicSubTab()

	; GUI SubTab
	Local $x = 15, $y = 45

	GUICtrlCreateGroup("Collect Items", 16, 24, 449, 65)
	$g_hChkCollectMagicItems = GUICtrlCreateCheckbox("Collect magic items", 56, 48, 113, 17)
	GUICtrlSetOnEvent(-1, "btnDDApply")
	$g_hChkCollectFree = GUICtrlCreateCheckbox("Collect FREE items", 320, 48, 113, 17)
	GUICtrlSetOnEvent(-1, "ChkFreeMagicItems")
	$g_hBtnMagicItemsConfig = GUICtrlCreateButton("Settings", 176, 48, 97, 25)
	GUICtrlSetOnEvent(-1, "btnDailyDiscounts")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("Magic Items", 16, 104, 449, 257)
	$g_hChkBuilderPotion = GUICtrlCreateCheckbox("Use builder potion when busy builders is > = : ", 56, 128, 225, 17)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hChkClockTowerPotion = GUICtrlCreateCheckbox("Use clock tower potion when :", 56, 160, 217, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkHeroPotion = GUICtrlCreateCheckbox("Use hero potion whem are avariable : ", 56, 192, 217, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkLabPotion = GUICtrlCreateCheckbox("Use research potion when laboratory hours is >= ", 56, 224, 233, 17)
	$g_hChkPowerPotion = GUICtrlCreateCheckbox("Use power potion during : ", 56, 256, 225, 17)
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hChkResourcePotion = GUICtrlCreateCheckbox("Use resource potion only if storage are :", 56, 288, 225, 17)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hInputBuilderPotion = _GUICtrlCreateInput("Number", 296, 128, 41, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hComboClockTowerPotion = GUICtrlCreateCombo("Select", 296, 160, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hComboHeroPotion = GUICtrlCreateCombo("Select", 296, 192, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_HIDE)
	$g_hInputLabPotion = _GUICtrlCreateInput("Hours", 296, 224, 41, 21)
	$g_hComboPowerPotion = GUICtrlCreateCombo("Select", 296, 256, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetState (-1, $GUI_DISABLE)
	$g_hInputGoldItems = _GUICtrlCreateInput("1000000", 88, 320, 73, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hInputElixirItems = _GUICtrlCreateInput("1000000", 192, 320, 73, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	$g_hInputDarkElixirItems = _GUICtrlCreateInput("1000", 296, 320, 49, 21)
	GUICtrlSetOnEvent(-1, "ConfigRefresh")
	GUICtrlCreateLabel("Lower : ", 40, 320, 42, 17)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnShop, 24, 46, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModBuilderP, 24, 126, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModClockTowerP, 24, 158, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModHeroP, 24, 190, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnLabP, 24, 222, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModPowerP, 24, 254, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnModResourceP, 24, 284, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnGoldP, 163, 318, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnElixirP, 265, 318, 25, 25)
	_GUICtrlCreateIcon($g_sLibModIconPath, $eIcnDarkP, 345, 318, 25, 25)

EndFunc   ;==>CreateMiscMagicSubTab

#Region Donations Control SubTab - Donation records - Team AIO Mod++
Global $g_hLblDayTroop[$eTroopCount], $g_hLblDaySpell[$eSpellCount], $g_hLblDaySiege[$eSiegeMachineCount]
Global $g_hDayTotalTroops = 0, $g_hDayTotalSpells = 0, $g_hDayTotalSieges = 0
Global $g_hDayLimitTroops = 0, $g_hDayLimitSpells = 0, $g_hDayLimitSieges = 0

Func CreateDonationsControlSubTab()
	Local $aTroopsIcons[$eTroopCount] = [$eIcnBarbarian, $eIcnArcher, $eIcnGiant, $eIcnGoblin, $eIcnWallBreaker, $eIcnBalloon, _
			$eIcnWizard, $eIcnHealer, $eIcnDragon, $eIcnPekka, $eIcnBabyDragon, $eIcnMiner, $eIcnElectroDragon, $eIcnYeti, $eIcnMinion, _
			$eIcnHogRider, $eIcnValkyrie, $eIcnGolem, $eIcnWitch, $eIcnLavaHound, $eIcnBowler, $eIcnIceGolem]
	Local $aSpellsIcons[$eSpellCount] = [$eIcnLightSpell, $eIcnHealSpell, $eIcnRageSpell, $eIcnJumpSpell, $eIcnFreezeSpell, _
			$eIcnCloneSpell, $eIcnPoisonSpell, $eIcnEarthQuakeSpell, $eIcnHasteSpell, $eIcnSkeletonSpell, $eIcnBatSpell]
	Local $eSiegeMachineIcons[$eSiegeMachineCount] = [$eIcnWallW, $eIcnBattleB, $eIcnStoneS, $eIcnSiegeB]
	Local $g_ahTxtTrainWarTroopCount[$eTroopCount], $g_ahTxtTrainWarSpellCount[$eSpellCount], $g_ahTxtSiegeMachineCount[$eSiegeMachineCount]
	Local $aTroopList[$eTroopCount] = [$eTroopBarbarian, $eTroopArcher, $eTroopGiant, $eTroopGoblin, $eTroopWallBreaker, $eTroopBalloon, _
			$eTroopWizard, $eTroopHealer, $eTroopDragon, $eTroopPekka, $eTroopBabyDragon, $eTroopMiner, $eTroopElectroDragon, $eTroopYeti, $eTroopMinion, _
			$eTroopHogRider, $eTroopValkyrie, $eTroopGolem, $eTroopWitch, $eTroopLavaHound, $eTroopBowler, $eTroopIceGolem]
	Local $aSpellList[$eSpellCount] = [$eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, _
			$eSpellClone, $eSpellPoison, $eSpellEarthQuake, $eSpellHaste, $eSpellSkeleton, $eSpellBat]
	Local $aSiegeList[$eSiegeMachineCount] = [$eSiegeBarracks, $eSiegeWallWrecker, $eSiegeBattleBlimp, $eSiegeStoneSlammer]

	Local $sTxtTip = ""
	Local $xStart = 30, $yStart = 45
	$g_hGUI_DonateLimiter = _GUICreate("", $g_iSizeWGrpTab3, $g_iSizeHGrpTab3, $xStart - 32, $yStart - 20, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_DONATE)
	Local $xStart = 20, $yStart = 20
	Local $x = $xStart, $y = $yStart

	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Donate-CC", "GroupDonationslimiter", "Donations Stats + Limiter"), $x, $y, 436, 22, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0x333300) ; Blue
	GUICtrlSetFont(-1, 12, 500, 0, "Candara", $CLEARTYPE_QUALITY)
	GUICtrlSetColor(-1, 0xFFCC00)

	$y += 35

		For $i = 0 To $eTroopCount - 1 ; Troops
			If $i >= 12 Then $x = 25
			_GUICtrlCreateIcon($g_sLibIconPath, $aTroopsIcons[$i], $x + Int($i / 2) * 37, $y + Mod($i, 2) * 60, 32, 32)
			$g_hLblDayTroop[$aTroopList[$i]] = GUICtrlCreateLabel("0", $x + Int($i / 2) * 37 + 1, $y + Mod($i, 2) * 60 + 34, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
				GUICtrlSetLimit(-1, 3)
		Next
		$y += 115

		GUICtrlCreateLabel("Limit ", $x, $y)
		$g_hDayLimitTroops = _GUICtrlCreateInput("0", $x + 25, -1 , 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetOnEvent(-1, "InputRecords")

		GUICtrlCreateLabel("per hours.   Total : ", $x + 60, -1)
		$g_hDayTotalTroops = GUICtrlCreateLabel("0", $x + 150, -1)
		$y += 35

		For $i = 0 To $eSpellCount - 1 ; Spells
			If $i >= 6 Then $x = 25
			_GUICtrlCreateIcon($g_sLibIconPath, $aSpellsIcons[$i], $x + $i * 37, $y, 32, 32)
			$g_hLblDaySpell[$aSpellList[$i]] = GUICtrlCreateLabel("0", $x +  $i * 37, $y + 34, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
				GUICtrlSetLimit(-1, 3)
		Next
		$y += 50

		GUICtrlCreateLabel("Limit ", $x, $y)
		$g_hDayLimitSpells = _GUICtrlCreateInput("0", $x + 25, -1 , 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetOnEvent(-1, "InputRecords")

		GUICtrlCreateLabel("per hours.   Total : ", $x + 60, -1)
		$g_hDayTotalSpells = GUICtrlCreateLabel("0", $x + 150, -1)
		$y += 35

		For $i = 0 To $eSiegeMachineCount - 1 ; Siege Machine
			_GUICtrlCreateIcon($g_sLibIconPath, $eSiegeMachineIcons[$i], $x + $i * 37, $y, 32, 32)
			$g_hLblDaySiege[$aSiegeList[$i]] = GUICtrlCreateLabel("0", $x +  $i * 37, $y + 34, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
				GUICtrlSetLimit(-1, 3)
		Next
		$y += 50

		GUICtrlCreateLabel("Limit ", $x, $y)
		$g_hDayLimitSieges = _GUICtrlCreateInput("0", $x + 25, -1 , 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetOnEvent(-1, "InputRecords")

		GUICtrlCreateLabel("per hours.   Total : ", $x + 60, -1)
		$g_hDayTotalSieges = GUICtrlCreateLabel("0", $x + 150, -1)

		$x += 200
		GUICtrlCreateLabel("Restart every hours : ", $x, -1)
		$g_hCmbRestartEvery = _GUICtrlCreateInput("0", $x + 105, -1 , 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlSetOnEvent(-1, "InputRecords")

	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateDonationsSubTab
#EndRegion

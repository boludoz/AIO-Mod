; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control MOD Tab GTFO
; Description ...: This file is used for Fenix MOD GUI functions of GTFO Tab will be here.
; Author ........: Boldina/Boludoz (2019 FOR AIO)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#cs
	$g_hChkCollectMagicItems = GUICtrlCreateCheckbox("Collect magic items", 56, 48, 113, 17)
	$g_hChkCollectFree = GUICtrlCreateCheckbox("Collect FREE items", 320, 48, 113, 17)
	$g_hBtnMagicItemsConfig = GUICtrlCreateButton("Settings", 176, 48, 97, 25)

	$g_hChkBuilderPotion = GUICtrlCreateCheckbox("Use builder potion when busy builders is > ", 56, 128, 225, 17)
	$g_hChkClockTowerPotion = GUICtrlCreateCheckbox("Use clock tower potion when :", 56, 160, 217, 17)
	$g_hChkHeroPotion = GUICtrlCreateCheckbox("Use hero potion whem are avariable : ", 56, 192, 217, 17)
	$g_hChkLabPotion = GUICtrlCreateCheckbox("Use research potion when laboratory time is > ", 56, 224, 233, 17)
	$g_hChkPowerPotion = GUICtrlCreateCheckbox("Use power potion during : ", 56, 256, 225, 17)
	$g_hChkResourcePotion = GUICtrlCreateCheckbox("Use resource potion only if storage are :", 56, 288, 225, 17)
	$g_hInputBuilderPotion = GUICtrlCreateCombo("Number", 296, 128, 41, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	$g_hComboClockTowerPotion = GUICtrlCreateCombo("Select", 296, 160, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	$g_hComboHeroPotion = GUICtrlCreateCombo("Select", 296, 192, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	$g_hInputLabPotion = GUICtrlCreateInput("Hours", 296, 224, 41, 21)
	$g_hComboPowerPotion = GUICtrlCreateCombo("Select", 296, 256, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	$g_hInputGoldItems = GUICtrlCreateInput("1000000", 88, 320, 73, 21)
	$g_hInputElixirItems = GUICtrlCreateInput("1000000", 192, 320, 73, 21)
	$g_hInputDarkElixirItems = GUICtrlCreateInput("1000", 296, 320, 49, 21)
#ce

Global $g_hBtnMagicItemsConfig = 0
 
Func ChkMagicItems()
	If $g_iTownHallLevel >= 8 Or $g_iTownHallLevel = 0 Then ; Must be Th8 or more to use the Trader
		GUICtrlSetState($g_hChkCollectFree, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkCollectFree, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>ChkFreeMagicItems

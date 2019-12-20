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

Global $g_hBtnMagicItemsConfig = 0
 
Func ChkFreeMagicItems()
	If $g_iTownHallLevel >= 8 Or $g_iTownHallLevel = 0 Then ; Must be Th8 or more to use the Trader
		GUICtrlSetState($g_hChkCollectFree, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hChkCollectFree, BitOR($GUI_DISABLE, $GUI_UNCHECKED))
	EndIf
EndFunc   ;==>ChkFreeMagicItems

Func ConfigRefresh()
	ApplyConfig_MOD_MagicItems("Save")
EndFunc   ;==>ConfigRefresh

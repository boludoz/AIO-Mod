; #FUNCTION# ====================================================================================================================
; Name ..........: MOD GUI Design - AiO-Debug
; Description ...: This file This file creates the "Debug" tab under the "Mods" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Team AiO MOD++
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hBtnTestSuperXP = 0, $g_hBtnTestClanChat = 0, $g_hBtnTestFriendChallenge = 0, $g_hBtnTestReadChat = 0, _
	$g_hBtnTestDailyDiscounts = 0, $g_hBtnTestAttackBB = 0, $g_hBtnTestRequestDefense = 0, $g_hBtnTestClanHop = 0, $g_hBtnTestCollectorsOutside = 0, _
	$g_hTxtTestExecuteButton = 0, $g_hBtnTestExecuteButton = 0

Func TabDebugGUI()
	Local $x = 25, $y = 45
	GUICtrlCreateGroup("Debug", $x - 20, $y - 20, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2)
	$x = 300
	$y = 40
		$g_hBtnTestSuperXP = GUICtrlCreateButton("Test SuperXP", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestClanChat = GUICtrlCreateButton("Test ClanChat", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestFriendChallenge = GUICtrlCreateButton("Test FriendChallenge", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestReadChat = GUICtrlCreateButton("Test ReadChat", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestDailyDiscounts = GUICtrlCreateButton("Test DailyDiscounts", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestAttackBB = GUICtrlCreateButton("Test AttackBB", $x, $y, 140, 25)
	$y += 30
		$g_hBtnTestClanHop = GUICtrlCreateButton("Test ClanHop", $x, $y, 140, 25)
	$y += 30
		$g_hTxtTestExecuteButton = GUICtrlCreateInput("Execute()", $x - 90, $y + 3, 85, 20)
			GUICtrlSetBkColor(-1, 0xD1DFE7)
		$g_hBtnTestExecuteButton = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Bot - Debug", "Execute", "Execute func/math"), $x, $y, 140, 25)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>TabDebugGUI

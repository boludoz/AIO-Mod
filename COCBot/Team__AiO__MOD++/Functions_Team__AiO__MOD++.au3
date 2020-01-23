; #FUNCTION# ====================================================================================================================
; Name ..........: Functions_Team__AiO__MOD++
; Description ...: This file Includes several files in the current script.
; Syntax ........: #include
; Parameters ....: None
; Return values .: None
; Author ........: Team AiO MOD++ (2019)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; <><><><><><><><><><><><><><><> Team AiO MOD++ (2019) <><><><><><><><><><><><><><><>
#include "functions\Mod's\ModFuncs.au3"
#include "functions\Pixels\_Wait4Pixel.au3"

; Check Stop For War - Team AiO MOD++
#include "functions\Mod's\CheckStopForWar.au3"

; Custom army - Team AiO MOD++
#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCorrectAttackBar.au3"
#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCheckArmy.au3"

; MagicItems - Team AiO MOD++
#include "functions\Mod's\MagicItems.au3"

; SuperXP / GoblinXP - Team AiO MOD++
#include "functions\Mod's\SuperXP\ArrayFunctions.au3"
#include "functions\Mod's\SuperXP\multiSearch.au3"
#include "functions\Mod's\SuperXP\SuperXP.au3"

; Humanization - Team AiO MOD++
#include "functions\Mod's\Humanization\BotHumanization.au3"
#include "functions\Mod's\Humanization\AttackNDefenseActions.au3"
#include "functions\Mod's\Humanization\BestClansNPlayersActions.au3"
#include "functions\Mod's\Humanization\ChatActions.au3"
#include "functions\Mod's\Humanization\ClanActions.au3"
#include "functions\Mod's\Humanization\ClanWarActions.au3"

; ChatActions - Team AiO MOD++
#include "functions\Mod's\ChatActions\MultyLang.au3"
#include "functions\Mod's\ChatActions\IAChat.au3"
#include "functions\Mod's\ChatActions\ChatActions.au3"

; Auto Dock, Hide Emulator & Bot - Team AiO MOD++
#include "functions\Mod's\AutoHideDockMinimize.au3"

; Check Collector Outside - Team AiO MOD++
#include "functions\Mod's\CheckCollectorsOutside\AreCollectorsOutside.au3"
#include "functions\Mod's\CheckCollectorsOutside\AreCollectorsNearRedline.au3"
#include "functions\Mod's\CheckCollectorsOutside\isOutsideEllipse.au3"

; Switch Profiles - Team AiO MOD++
#include "functions\Mod's\ProfilesOptions\SwitchProfiles.au3"

; Farm Schedule - Team AiO MOD++
#include "functions\Mod's\ProfilesOptions\FarmSchedule.au3"

; GTFO
#include "functions\Mod's\GTFO\GTFO.au3"
#include "functions\Mod's\GTFO\KickOut.au3"

; Moved to the end to avoid any global declare issues - Team AiO MOD++
#include "functions\Config\saveConfig.au3"
#include "functions\Config\readConfig.au3"
#include "functions\Config\applyConfig.au3"
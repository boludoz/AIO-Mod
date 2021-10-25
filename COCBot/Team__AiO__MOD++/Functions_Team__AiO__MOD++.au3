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

; <><><><><><><><><><><><><><><> Team AiO MOD++ (2020) <><><><><><><><><><><><><><><>
; One Gem Boost - Team AiO MOD++
#include "functions\Mod's\OneGemBoost.au3"

; Multi Fingers Profile - (LunaEclipse) - Team AiO MOD++
#include "functions\Mod's\Multi Fingers\4Fingers.au3"
#include "functions\Mod's\Multi Fingers\8Fingers.au3"
#include "functions\Mod's\Multi Fingers\MultiFinger.au3"
#include "functions\Mod's\Multi Fingers\UnitInfo.au3"

; Vectors
#include "functions\Mod's\Multi Fingers\Vectors\4FingerStandard.au3"
#include "functions\Mod's\Multi Fingers\Vectors\4FingerSpiralLeft.au3"
#include "functions\Mod's\Multi Fingers\Vectors\4FingerSpiralRight.au3"
#include "functions\Mod's\Multi Fingers\Vectors\8FingerPinWheelLeft.au3"
#include "functions\Mod's\Multi Fingers\Vectors\8FingerPinWheelRight.au3"
#include "functions\Mod's\Multi Fingers\Vectors\8FingerBlossom.au3"
#include "functions\Mod's\Multi Fingers\Vectors\8FingerImplosion.au3"

; Other - Team AiO MOD++
#include "functions\Mod's\ModFuncs.au3"
#include "functions\Pixels\_Wait4Pixel.au3"
#include "functions\Pixels\ImgFuncs.au3"
#include "functions\Mod's\AngleFuncs.au3"

; DOCR - Team AiO MOD++
#include "functions\Read Text\getOcrDissociable.au3"

; DMatching - Team AiO MOD++
#include "functions\Pixels\DMatching.au3"

; CheckModVersion - Team AiO MOD++
#include "functions\Mod's\CheckModVersion.au3"

; Check Stop For War - Team AiO MOD++
#include "functions\Mod's\CheckStopForWar.au3"

; MagicItems - Team AiO MOD++
#include "functions\Mod's\MagicItems.au3"

; SuperXP / GoblinXP - Team AiO MOD++
#include "functions\Mod's\SuperXP\SuperXP.au3"

; Humanization - Team AiO MOD++
#include "functions\Mod's\Humanization.au3"

; ChatActions - Team AiO MOD++
#include "functions\Mod's\ChatActions\MultyLang.au3"
#include "functions\Mod's\ChatActions\IAChat.au3"
#include "functions\Mod's\ChatActions\ChatActions.au3"

; Auto Dock, Hide Emulator & Bot - Team AiO MOD++
#include "functions\Mod's\AutoHideDockMinimize.au3"

; Check Collector Outside - Team AiO MOD++
#include "functions\Mod's\CheckCollectorsOutside\CollectorsAndRedLines.au3"

; Farm Schedule - Team AiO MOD++
#include "functions\Mod's\ProfilesOptions.au3"

; BuyShield - Team AiO MOD++
#include "functions\Mod's\BuyShield.au3"

; GTFO - Team AiO MOD++
#include "functions\Mod's\GTFO\GTFO.au3"
#include "functions\Mod's\GTFO\KickOut.au3"

; Check if it's time to request troops for defense (Demen) 
#include "functions\Mod's\RequestDefenseCC.au3"

; Custom Builder Base - Team AiO MOD++
#include "functions\Mod's\BuilderBase\BuilderBaseMain.au3"
#include "functions\Mod's\BuilderBase\BuilderBaseDebugUI.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseImageDetection.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseCSV.au3"
#include "functions\Mod's\BuilderBase\Attack\BuilderBaseAttack.au3"
#include "functions\Mod's\BuilderBase\Village\BuilderBasePolygon.au3"

#include "functions\Mod's\BuilderBase\Village\UpgradeWalls.au3"
#include "functions\Mod's\BuilderBase\Village\BattleMachineUpgrade.au3"

#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCorrectAttackBar.au3"
#include "functions\Mod's\BuilderBase\Camps\BuilderBaseCheckArmy.au3"

#include "functions\Mod's\Attack\GetButtons.au3"
#include "functions\Mod's\Attack\VerifyDropPoints.au3"

; Moved to the end to avoid any global declare issues - Team AiO MOD++
#include "functions\Config\saveConfig.au3"
#include "functions\Config\readConfig.au3"
#include "functions\Config\applyConfig.au3"

; #Variables# ====================================================================================================================
; Name ..........: Image Search Directories
; Description ...: Gobal Strings holding Path to Images used for Image Search
; Syntax ........: $g_sImgxxx = @ScriptDir & "\imgxml\xxx\"
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region BuilderBaseCustomArmy
Global $g_sImgCustomArmyBB = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\Attack\VersusBattle\ChangeTroops\"
Global $aArmyTrainButtonBB = [46, 572, 0xE5A439, 10]
Global Const $g_sImgPathFillArmyCampsWindow = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\FillArmyCamps\Window\"
Global Const $g_sImgPathTroopsTrain = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\FillArmyCamps\TroopsTrain\"
Global Const $g_sImgPathCamps = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\BuilderBase\FillArmyCamps\Bundles\Camps\"
#EndRegion

#Region SuperXP
Global $g_sImgFindSX = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\SuperXP\Find\"
Global $g_sImgVerifySX = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\SuperXP\Verify\"
Global $g_sImgLockedSX = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\SuperXP\Locked\"
#EndRegion

#Region Humanization
Global $g_sImgHumanizationWarLog = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\WarLog"
Global $g_sImgHumanizationDuration = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\Duration"
Global $g_sImgHumanizationFriend = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\Friend"
Global $g_sImgHumanizationClaimReward = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\ClaimReward"
Global $g_sImgHumanizationCurrentWar = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\CurrentWar"
Global $g_sImgHumanizationWarDetails = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\WarDetails"
Global $g_sImgHumanizationReplay = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\Replay"
Global $g_sImgHumanizationVisit = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\Visit"
Global $g_sImgChatIUnterstandMultiLang = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Humanization\Chat"
#EndRegion

#Region DailyDiscounts
Global $g_sImgDirDailyDiscounts = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\DailyDiscounts"
Global $g_sImgDDWallRingx5 = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\DailyDiscounts\WallRingAmount\x5_92.png"
Global $g_sImgDDWallRingx10 = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\DailyDiscounts\WallRingAmount\x10_92.png"
#EndRegion

#Region ChatActions
Global $g_sImgChatObstacles = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\ChatActions\FriendlyChallenge"
#EndRegion

#Region GTFO
Global $g_sImgKickOut = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\GTFO\KickOut"
Global $g_sImgClanProfilePage = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Pages\Profile"
#EndRegion GTFO

#Region MagicItems
Global $g_sImgPotionsBtn = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\MagicItems\Btn"
Global $g_sImgPotionsBtnArmy = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\MagicItems\BtnArmy"
#EndRegion MagicItems

#Region CustomArmy
Global $g_sImgArmyOverviewTroopQueued = @ScriptDir & "\imgxml\ArmyOverview\TroopQueued\"
#EndRegion CustomArmy

#Region CustomRequest
Global $g_sImgArmyRequestCC = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Request"
#EndRegion CustomRequest

#Region Builder Base
Global $g_sModImageLocation = @ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Old"

;Machine Upgrade
Global Const $g_sXMLTroopsUpgradeMachine = $g_sModImageLocation & "\BuildersBase\TroopsUpgrade\Machine"

; Builder Base
Global Const $g_sImgPathIsCTBoosted = $g_sModImageLocation & "\BuildersBase\ClockTowerBoosted"
Global Const $g_sImgAvailableAttacks = $g_sModImageLocation & "\BuildersBase\AvailableAttacks"

; Check Army Builder Base
;Global $aArmyTrainButtonBB = [46, 572, 0xE5A439, 10]
;Global Const $g_sImgPathFillArmyCampsWindow = $g_sModImageLocation & "\BuildersBase\FillArmyCamps\Window"
;Global Const $g_sImgPathCamps = $g_sModImageLocation & "\BuildersBase\Bundles\Camps\"
;Global Const $g_sImgPathTroopsTrain = $g_sModImageLocation & "\BuildersBase\FillArmyCamps\TroopsTrain"

; Builder Base Attack
Global $g_aOpponentVillageVisible[1][3] = [[0xFED5D4, 0, 1]] ; more ez ; samm0d

;Global Const $g_sBundleAttackBarBB = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBar"
Global Const $g_sBundleBuilderHall = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBuildings\BuilderHall"
Global Const $g_sBundleDeployPointsBB = $g_sModImageLocation & "\BuildersBase\Bundles\AttackBuildings\DeployPoints"

Global Const $g_sImgOpponentBuildingsBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Buildings\"

Global Const $g_sImgAttackBtnBB = $g_sModImageLocation & "\BuildersBase\Attack\AttackBtn\"
Global Const $g_sImgVersusWindow = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Window\"
;~ Global Const $g_sImgFullArmyBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\ArmyStatus\Full\"
;~ Global Const $g_sImgHeroStatusRec = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\ArmyStatus\Hero\Recovering\"
;~ Global Const $g_sImgHeroStatusUpg = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\ArmyStatus\Hero\Upgrading\"
;~ Global Const $g_sImgHeroStatusMachine = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\ArmyStatus\Hero\Battle Machine\"
Global Const $g_sImgCloudSearch = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Clouds\"

; Report Window : Victory | Draw | Defeat
Global Const $g_sImgReportWaitBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Report\Waiting"
Global Const $g_sImgReportFinishedBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Report\Replay"
Global Const $g_sImgReportResultBB = $g_sModImageLocation & "\BuildersBase\Attack\VersusBattle\Report\Result"
#EndRegion Builder Base Attack

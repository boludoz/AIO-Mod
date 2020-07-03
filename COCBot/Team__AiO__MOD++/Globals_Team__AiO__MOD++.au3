; #FUNCTION# ====================================================================================================================
; Name ..........: Globals Team AiO MOD++
; Description ...: This file Includes several files in the current script and all Declared variables, constant, or create an array.
; Syntax ........: #include , Global
; Parameters ....: None
; Return values .: None
; Author ........: Team AiO MOD++ (2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; AIO Icons - Team AiO MOD++
Global Const $g_sLibModIconPath = $g_sLibPath & "\ModLibs\AIOMod.dll" ; Mod icon library - Team AiO MOD++
; enumerated Icons 1-based index to IconLibMod
Global Enum $eIcnModKingGray = 1, $eIcnModKingBlue, $eIcnModKingGreen, $eIcnModKingRed, $eIcnModQueenGray, $eIcnModQueenBlue, $eIcnModQueenGreen, $eIcnModQueenRed, _
		$eIcnModWardenGray, $eIcnModWardenBlue, $eIcnModWardenGreen, $eIcnModWardenRed, $eIcnModLabGray, $eIcnModLabGreen, $eIcnModLabRed, _
		$eIcnModArrowLeft, $eIcnModArrowRight, $eIcnModTrainingP, $eIcnModResourceP, $eIcnModHeroP, $eIcnModClockTowerP, $eIcnModBuilderP, $eIcnModPowerP, _
		$eIcnModChat, $eIcnModRepeat, $eIcnModClan, $eIcnModTarget, $eIcnModSettings, $eIcnModBKingSX, $eIcnModAQueenSX, $eIcnModGWardenSX, $eIcnModDebug, $eIcnModClanHop, $eIcnModPrecise, _
		$eIcnModAccountsS, $eIcnModProfilesS, $eIcnModFarmingS, $eIcnMiscMod, $eIcnSuperXP, $eIcnChatActions, $eIcnHumanization, $eIcnAIOMod, $eIcnDebugMod, _
		$eIcnLabP, $eIcnShop, $eIcnGoldP, $eIcnElixirP, $eIcnDarkP, $eIcnGFTO, $eIcnMisc, $eIcnPrewar

; Custom remain - Team AIO Mod++
Global $g_bRemainTweak = True

; ZoomMod
Global $g_bZoomFixBB = False
Global $g_aPosSizeVillage[2] = [Null, Null], $Stonecoord

; Skip first check
Global $g_bSkipfirstcheck = False, $g_hSkipfirstcheck

; Donation records.
Global $g_iDayLimitTroops = 0, $g_iDayLimitSpells = 0, $g_iDayLimitSieges = 0
Global $g_iCmbRestartEvery, $g_hCmbRestartEvery
Global $g_iDiffRestartEvery = 0
Global $g_sRestartTimer = '1000/01/01 00:00:00'

; Request form chat / on a loop.
Global $g_hChkReqCCAlways = 0, $g_hChkReqCCFromChat = 0
Global $g_bChkReqCCAlways = 0, $g_bChkReqCCFromChat = 0

; Stop for war - War Preparation Demen
Global $g_bStopForWar
Global $g_iStopTime, $g_iReturnTime
Global $g_bTrainWarTroop, $g_bUseQuickTrainWar, $g_aChkArmyWar[3], $g_aiWarCompTroops[$eTroopCount], $g_aiWarCompSpells[$eSpellCount]
Global $g_bRequestCCForWar,	$g_sTxtRequestCCForWar

; Custom BB Army
Global $g_bDebugBBattack = False

;GUI
; BB Drop Order
Global $g_hBtnBBDropOrder = 0
Global $g_hGUI_BBDropOrder = 0
Global $g_hChkBBCustomDropOrderEnable = 0
Global $g_hBtnBBDropOrderSet = 0, $g_hBtnBBRemoveDropOrder = 0, $g_hBtnBBClose = 0
Global $g_bBBDropOrderSet = False
Global Const $g_iBBTroopCount = 12

;CustomArmy
Global $g_iCmbCampsBB[6] = [0, 0, 0, 0, 0, 0]
Global $g_hIcnTroopBB[6]
Global $g_hComboTroopBB[6]
Global $g_bChkBBCustomArmyEnable = True, $g_hChkBBCustomArmyEnable

; Drop trophy - Team AiO MOD++
Global $g_bChkNoDropIfShield = True, $g_bChkTrophyTroops = False, $g_bChkTrophyHeroesAndTroops = True
; GUI
Global $g_hChkNoDropIfShield, $g_hChkTrophyTroops, $g_hChkTrophyHeroesAndTroops

; Misc tab - Team AiO MOD++
Global $g_bUseSleep = False, $g_iIntSleep = 20, $g_bUseRandomSleep = False, $g_bNoAttackSleep = False, $g_bDisableColorLog = False, $g_bDelayLabel = False, $g_bAvoidLocation = False, $g_bEdgeObstacle = False
; GUI
Global $g_hUseSleep, $g_hIntSleep, $g_hUseRandomSleep, $g_hNoAttackSleep, $g_hDisableColorLog, $g_hDelayLabel, $g_hAvoidLocation, $g_hEdgeObstacle
;-------------------

; Max sides SF
Global $g_bMaxSidesSF = True, $g_iCmbMaxSidesSF = 1
; GUI 
Global $g_hMaxSidesSF, $g_hCmbMaxSidesSF
;-------------------

; Attack extras - Team AiO MOD++
Global $g_bDeployCastleFirst[2] = [False, False]

Global $g_iDeployWave[3] = [5, 5, 5],  $g_iDeployDelay[3] = [5, 5, 5] ; $DB, $LB, $iCmbValue
Global $g_bChkEnableRandom[3] = [True, True, True]
; GUI
Global $g_hDeployCastleFirst[2] = [$LB, $DB]
Global $g_hDeployWave[3],  $g_hDeployDelay[3]
Global $g_hChkEnableRandom[3]

; SuperXP / GoblinXP - Team AiO MOD++
Global $g_bEnableSuperXP = False, $g_bSkipZoomOutSX = False, $g_bFastSuperXP = False, $g_bSkipDragToEndSX = False, _
	$g_iActivateOptionSX = 1, $g_iGoblinMapOptSX = 2, $g_sGoblinMapOptSX = "The Arena", $g_iMaxXPtoGain = 500, _
	$g_bBKingSX = False, $g_bAQueenSX = False, $g_bGWardenSX = False
Global $g_iStartXP = 0, $g_iCurrentXP = 0, $g_iGainedXP = 0, $g_iGainedHourXP = 0, $g_sRunTimeXP = 0
Global $g_bDebugSX = True
; [0] = Queen, [1] = Warden, [2] = Barbarian King
; [0][0] = X, [0][1] = Y, [0][2] = XRandomOffset, [0][3] = YRandomOffset
Global $g_aiDpGoblinPicnic[3][4] = [[310, 200, 5, 5], [340, 140, 5, 5], [290, 220, 5, 5]]
Global $g_aiDpTheArena[2][4] = [[429, 82, 0, 0], [430, 20, 5, 5]] ; Can't Farm With Barbarian King
Global $g_aiBdGoblinPicnic[3] = [0, "5000-7000", "6000-8000"] ; [0] = Archer Queen, [1] = Grand Warden, [2] = Barbarian King
Global $g_aiBdTheArena[2] = [0, "5000-7000"] ; [0] = Queen, [1] = Warden, Can't Farm With Barbarian King
Global $g_bActivatedHeroes[3] = [False, False, False] ; [0] = Archer Queen, [1] = Grand Warden, [2] = Barbarian King , Prevent to click on them to Activate Again And Again
Global Const $g_iMinStarsToEnd = 1
Global $bCanGainXP = False

; Humanization - Team AiO MOD++
Global $g_iacmbPriority[13] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_iacmbMaxSpeed[2] = [1, 1]
Global $g_iacmbPause[2] = [0, 0]
Global $g_iahumanMessage[2] = ["Hello !", "Hello !"]
Global $g_iTxtChallengeMessage = "Ready to Challenge?"

Global $g_iMinimumPriority, $g_iMaxActionsNumber, $g_iActionToDo
Global $g_aSetActionPriority[13] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Global $g_sFrequenceChain = "Never|Sometimes|Frequently|Often|Very Often"
Global $g_sReplayChain = "1|2|4"
Global $g_bUseBotHumanization = False, $g_bUseAltRClick = False, $g_iCmbMaxActionsNumber = 1, $g_bCollectAchievements = False, $g_bLookAtRedNotifications = False

Global $g_aReplayDuration[2] = [0, 0] ; An array, [0] = Minute | [1] = Seconds
Global $g_bOnReplayWindow, $g_iReplayToPause

Global $g_iLastLayout = 0

; ChatActions - Team AiO MOD++
Global $g_bChatClan = False, $g_sDelayTimeClan = 2, $g_bClanUseResponses = False, $g_bClanUseGeneric = False, $g_bCleverbot = False
Global $g_bUseNotify = False, $g_bPbSendNew = False
Global $g_bEnableFriendlyChallenge = False, $g_sDelayTimeFC = 5, $g_bOnlyOnRequest = False
Global $g_bFriendlyChallengeBase[6] = [False, False, False, False, False, False]
Global $g_abFriendlyChallengeHours[24] = [True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True]
Global $ChatbotStartTime, $ChatbotQueuedChats[0], $ChatbotReadQueued = False, $ChatbotReadInterval = 0, $ChatbotIsOnInterval = False, _
	$g_sMessage = "", $g_sGlobalChatLastMsgSentTime = "", $g_sClanChatLastMsgSentTime = "", $g_sFCLastMsgSentTime = ""

Global $g_aIAVar[5][2] = [[0,0],[1,0],[2,0],[3,0],[4,0]] , $g_sIAVar = '0,0#1,0#2,0#3,0#4,0'

Global $g_sGetOcrMod = "", $g_aImageSearchXML = -1
Global $g_aClanResponses, $g_sClanResponses
Global $g_aClanGeneric, $g_sClanGeneric
Global $g_aChallengeText, $g_aKeywordFcRequest, $g_sChallengeText, $g_sKeywordFcRequest

; Daily Discounts - Team AiO MOD++
#Region
Global $g_iDDCount = 19
Global $g_abChkDD_Deals[$g_iDDCount] = [False, False, False, False, False, False, False, False, False, False, False, False, False, False, False, False, False, False, False]
Global $g_aiDD_DealsCosts[$g_iDDCount] = [25, 75, 70, 115, 285, 300, 300, 500, 1000, 500, 500, 925, 925, 925, 1500, 1500, 3000, 1500, 1500]
Global $g_eDDPotionTrain = 0, $g_eDDPotionClock = 1, $g_eDDPotionResearch = 2, $g_eDDPotionResource = 3, $g_eDDPotionBuilder = 4, _
		$g_eDDPotionPower = 5, $g_eDDPotionHero = 6, $g_eDDWallRing5 = 7, $g_eDDWallRing10 = 8, $g_eDDShovel = 9, $g_eDDBookHeros = 10, _
		$g_eDDBookFighting = 11, $g_eDDBookSpells = 12, $g_eDDBookBuilding = 13, $g_eDDRuneGold = 14, $g_eDDRuneElixir = 15, $g_eDDRuneDarkElixir = 16, _
		$g_eDDRuneBBGold = 17, $g_eDDRuneBBElixir = 18
#EndRegion

; CSV Deploy Speed - Team AiO MOD++
Global $cmbCSVSpeed[2] = [$LB, $DB]
Global $icmbCSVSpeed[2] = [2, 2]
Global $g_CSVSpeedDivider[2] = [1, 1] ; default CSVSpeed for DB & LB

#Region Check Collectors Outside
; Check Collector Outside - Team AiO MOD++
Global $g_bScanMineAndElixir = False
; Collectors Outside Filter
Global $g_bDBMeetCollectorOutside = False, $g_iDBMinCollectorOutsidePercent = 80
Global $g_bDBCollectorNearRedline = False, $g_iCmbRedlineTiles = 1
Global $g_bSkipCollectorCheck = False, $g_iTxtSkipCollectorGold = 400000, $g_iTxtSkipCollectorElixir = 400000, $g_iTxtSkipCollectorDark = 0
Global $g_bSkipCollectorCheckTH = False, $g_iCmbSkipCollectorCheckTH = 1
; constants
Global Const $THEllipseWidth = 200, $THEllipseHeigth = 150, $CollectorsEllipseWidth = 130, $CollectorsEllipseHeigth = 97.5
#EndRegion Check Collectors Outside

; Auto Dock, Hide Emulator & Bot - Team AiO MOD++
Global $g_bEnableAuto = False, $g_bChkAutoDock = False, $g_bChkAutoHideEmulator = True, $g_bChkAutoMinimizeBot = False

; Switch Profiles - Team AiO MOD++
Global $g_abChkSwitchMax[4] = [False, False, False, False], $g_abChkSwitchMin[4] = [False, False, False, False], _
		$g_aiCmbSwitchMax[4] = [-1, -1, -1, -1], $g_aiCmbSwitchMin[4] = [-1, -1, -1, -1], _
		$g_abChkBotTypeMax[4] = [False, False, False, False], $g_abChkBotTypeMin[4] = [False, False, False, False], _
		$g_aiCmbBotTypeMax[4] = [1, 1, 1, 1], $g_aiCmbBotTypeMin[4] = [2, 2, 2, 2], _
		$g_aiConditionMax[4] = ["12000000", "12000000", "240000", "5000"], $g_aiConditionMin[4] = ["1000000", "1000000", "20000", "3000"]

; Farm Schedule - Team AiO MOD++
Global $g_abChkSetFarm[8], _
		$g_aiCmbAction1[8], $g_aiCmbCriteria1[8], $g_aiTxtResource1[8], $g_aiCmbTime1[8], _
		$g_aiCmbAction2[8], $g_aiCmbCriteria2[8], $g_aiTxtResource2[8], $g_aiCmbTime2[8]

; Builder Status - Team AiO MOD++
Global $g_sNextBuilderReadyTime = ""
Global $g_asNextBuilderReadyTime[8] = ["", "", "", "", "", "", "", ""]

; Max logout time - Team AiO MOD++
Global $g_bTrainLogoutMaxTime = False, $g_iTrainLogoutMaxTime = 4

; Multipixel solution
Global $g_iMultiPixelOffSet[2]

; Only farm - Team AiO MOD++
Global $g_bChkOnlyFarm = False

; Check No League for Dead Base - Team AiO MOD++
Global $g_bChkNoLeague[$g_iModeCount] = [False, False, False]

; Attack - Milking (Compatibility vars.)
Global Const $g_iMilkFarmOffsetX = 56
Global Const $g_iMilkFarmOffsetY = 41
Global Const $g_iMilkFarmOffsetXStep = 35
Global Const $g_iMilkFarmOffsetYStep = 26

; Ai Army search - Team AiO MOD++
Global $g_hMinArmyUmbralGoldDB, $g_hMinArmyUmbralElixirDB, $g_hMinArmyUmbralPlusDB, $g_hMinArmyUmbralDarkDB, _
$g_hMinArmyUmbralGoldAB, $g_hMinArmyUmbralElixirAB, $g_hMinArmyUmbralPlusAB, $g_hMinArmyUmbralDarkAB

Global $g_iMinArmyUmbralGoldDB = 0, $g_iMinArmyUmbralElixirDB = 0, $g_iMinArmyUmbralPlusDB = 0, $g_iMinArmyUmbralDarkDB = 0, _
$g_iMinArmyUmbralGoldAB = 0, $g_iMinArmyUmbralElixirAB = 0, $g_iMinArmyUmbralPlusAB = 0, $g_iMinArmyUmbralDarkAB = 0

; GTFO
Global $g_bChkUseGTFO = False, $g_bChkUseKickOut = False, $g_bChkKickOutSpammers = False
Global $g_iTxtMinSaveGTFO_Elixir = 200000, $g_iTxtMinSaveGTFO_DE = 2000, _
		$g_iTxtDonatedCap = 8, $g_iTxtReceivedCap = 35, _
		$g_iTxtKickLimit = 6
Global $g_hTxtClanID, $g_sTxtClanID, $g_iTxtCyclesGTFO
Global $g_bChkGTFOClanHop = False, $g_bChkGTFOReturnClan = False
Global $g_bExitAfterCyclesGTFO = False
Global $g_iCycle = 0

Global $g_aClanBadgeNoClan[4] = [151, 307, 0xF05538, 20] ; OK - Orange Tile of Clan Logo on Chat Tab if you are not in a Clan
Global $g_aCopy[4] = [512, 182, 0xDDF685, 20] ; OK - Copy button
Global $g_aShare[4] = [438, 190, 0xFFFFFF, 20] ; OK - Share clan
Global $g_aClanPage[4] = [821, 400, 0xFB5D63, 20] ; OK - Red Leave Clan Button on Clan Page
Global $g_aClanLabel[4] = [522, 70, 0xEDEDE8, 20] ; OK - Select white label
;Global $g_aJoinClanBtn[4] = [821, 400, 0xDBF583, 25] ; OK - Join Button on Tab
Global $g_aIsClanChat[4] = [86, 12, 0xC1BB91, 20] ; OK - Verify is in clan.
Global $g_aNoClanBtn[4] = [163, 515, 0x6DBB1F, 20] ; OK - Green Join Button on Chat Tab when you are not in a Clan

; Magic Items

Global $g_bChkCollectMagicItems, $g_bChkCollectFree, _
$g_bChkBuilderPotion, $g_bChkClockTowerPotion, $g_bChkHeroPotion, $g_bChkLabPotion, $g_bChkPowerPotion, $g_bChkResourcePotion, _
$g_iComboClockTowerPotion, $g_iComboHeroPotion, $g_iComboPowerPotion, _
$g_iInputBuilderPotion, $g_iInputLabPotion, $g_iInputGoldItems = 250000, $g_iInputElixirItems = 300000, $g_iInputDarkElixirItems = 1000

#Region - Builder Base !!!
; Provisional globals BB Machine
Global $g_aMachineBB[2] = [0, 0], $g_bIsBBMachineD = False, $g_bBBIsFirst = True

; Report
Global $g_iAvailableAttacksBB = 0, $g_iLastDamage = 0
Global $g_sTxtRegistrationToken = ""

Global Enum $g_iAirDefense = 0, $g_iCrusher, $g_iGuardPost, $g_iCannon, $g_iBuilderHall, $g_iDeployPoints
Global $g_aBuilderHallPos[1][2] = [[Null, Null]], $g_aAirdefensesPos[0][2], $g_aCrusherPos[0][2], $g_aCannonPos[0][2], $g_aGuardPostPos[0][2], $g_aDeployPoints
Global $g_aBuilderHallPos[1][2] = [[Null, Null]], $g_aAirdefensesPos[0][2], $g_aCrusherPos[0][2], $g_aCannonPos[0][2], $g_aGuardPostPos[0][2], $g_aDeployPoints, $g_aDeployBestPoints
Global $g_aOpponentBuildings[6] = [$g_aAirdefensesPos, $g_aCrusherPos, $g_aGuardPostPos, $g_aCannonPos, $g_aBuilderHallPos, $g_aDeployPoints]
Global $g_aExternalEdges, $g_aBuilderBaseDiamond, $g_aOuterEdges, $g_aBuilderBaseOuterDiamond, $g_aBuilderBaseOuterPolygon, $g_aFinalOuter[4]

; GUI
Global Enum $g_eBBAttackCSV = 0, $g_eBBAttackSmart = 1
Global $g_iCmbBBAttack = $g_eBBAttackCSV
Global $g_hTabBuilderBase = 0, $g_hTabAttack = 0
Global $g_hCmbBBAttack = 0

; Attack CSV
Global $g_bChkBBRandomAttack = False
Global Const $g_sCSVBBAttacksPath = @ScriptDir & "\CSV\BuilderBase"
Global $g_sAttackScrScriptNameBB[3] = ["", "", ""]
Global $g_iBuilderBaseScript = 0

; Upgrade Troops
Global $g_bChkUpgradeTroops = False, $g_iCmbBBLaboratory, $g_bChkUpgradeMachine = False

; Upgrade Walls
Global $g_bChkBBUpgradeWalls = False, $g_iCmbBBWallLevel, $g_iTxtBBWallNumber = 0

; Troops
Global Enum $eBBTroopBarbarian, $eBBTroopArcher, $eBBTroopGiant, $eBBTroopMinion, $eBBTroopBomber, $eBBTroopBabyDragon, $eBBTroopCannon, $eBBTroopNight, $eBBTroopDrop, $eBBTroopPekka, $eBBTroopHogG, $eBBTroopMachine, $eBBTroopCount
Global $g_sIcnBBOrder[$eBBTroopCount]
Global $g_asAttackBarBB2[$eBBTroopCount] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]
Global Const $g_asBBTroopShortNames[$eBBTroopCount] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]

Global $g_bIsMachinePresent = False
Global $g_iBBMachAbilityTime = 14000 ; time between abilities

; BB Drop Order
Global $g_hBtnBBDropOrder = 0
Global $g_hGUI_BBDropOrder = 0
Global $g_hChkBBCustomDropOrderEnable = 0
Global $g_hBtnBBDropOrderSet = 0, $g_hBtnBBRemoveDropOrder = 0, $g_hBtnBBClose = 0
Global $g_bBBDropOrderSet = False
Global $g_aiCmbBBDropOrder[$eBBTroopCount] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
Global $g_ahCmbBBDropOrder[$eBBTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_iBBNextTroopDelay = 2000,  $g_iBBSameTroopDelay = 300; delay time between different and same troops

Global $g_asAttackBarBB[$eBBTroopCount+1] = ["", "Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "Machine"]
Global $g_sBBDropOrder = _ArrayToString($g_asAttackBarBB)

Global $g_bIfMachineHasAbility = False, $g_bIfMachineWasDeployed = False

; Camps
Global $g_aCamps[6] = ["", "", "", "", "", ""]

; General
Global $g_bChkBuilderAttack = False, $g_bChkBBStopAt3 = False, $g_bChkBBTrophiesRange = False, $g_iTxtBBDropTrophiesMin = 0, $g_iTxtBBDropTrophiesMax = 0
Global $g_iCmbBBArmy1 = 0, $g_iCmbBBArmy2 = 0, $g_iCmbBBArmy3 = 0, $g_iCmbBBArmy4 = 0, $g_iCmbBBArmy5 = 0, $g_iCmbBBArmy6 = 0

; Lib with Icons
Global Const $g_sLibBBIconPath = $g_sLibPath & "\ModLibs\BuilderBase.dll" ; icon library
Global Enum $eIcnBB = 1 , $eIcnLabBB, $eIcnBBElixir, $eIcnBBGold, $eIcnBBTrophies, $eIcnMachine, $eIcnBBWallInfo, $eIcnBBWallL1, $eIcnBBWallL2, $eIcnBBWallL3, $eIcnBBWallL4, $eIcnBBWallL5, _
		$eIcnBBWallL6, $eIcnBBWallL7, $eIcnBBWallL8, $eIcnBBWallL9

; Internal & External Polygon
Global $CocDiamondECD = "ECD"
Global $CocDiamondDCD = "DCD"
Global $InternalArea[8][3]
Global $ExternalArea[8][3]

; Log
Global $g_hBBAttackLogFile = 0

Global $g_bChkCollectBuilderBase = False, $g_bChkStartClockTowerBoost = False, $g_bChkCTBoostBlderBz = False, $g_bChkCTBoostAtkAvailable = False, $g_bChkCleanYardBB = False, $g_bDebugBBattack = False

Global $g_bChkPlayBBOnly = False

Global $g_bChkBBGetFromCSV = False
#EndRegion
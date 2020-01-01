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
Global Const $g_sLibModIconPath = $g_sLibPath & "\AIOMod.dll" ; Mod icon library - Team AiO MOD++
; enumerated Icons 1-based index to IconLibMod
Global Enum $eIcnModKingGray = 1, $eIcnModKingBlue, $eIcnModKingGreen, $eIcnModKingRed, $eIcnModQueenGray, $eIcnModQueenBlue, $eIcnModQueenGreen, $eIcnModQueenRed, _
		$eIcnModWardenGray, $eIcnModWardenBlue, $eIcnModWardenGreen, $eIcnModWardenRed, $eIcnModLabGray, $eIcnModLabGreen, $eIcnModLabRed, _
		$eIcnModArrowLeft, $eIcnModArrowRight, $eIcnModTrainingP, $eIcnModResourceP, $eIcnModHeroP, $eIcnModClockTowerP, $eIcnModBuilderP, $eIcnModPowerP, _
		$eIcnModChat, $eIcnModRepeat, $eIcnModClan, $eIcnModTarget, $eIcnModSettings, $eIcnModBKingSX, $eIcnModAQueenSX, $eIcnModGWardenSX, $eIcnModDebug, $eIcnModClanHop, $eIcnModPrecise, _
		$eIcnModAccountsS, $eIcnModProfilesS, $eIcnModFarmingS, $eIcnMiscMod, $eIcnSuperXP, $eIcnChatActions, $eIcnHumanization, $eIcnAIOMod, $eIcnMisc, _
		$eIcnLabP, $eIcnShop, $eIcnGoldP, $eIcnElixirP, $eIcnDarkP, $eIcnGFTO, $eIcnDebugMod
; Custom BB Army
Global $g_bDebugBBattack = False
;GUI
; BB Drop Order
Global $g_hBtnBBDropOrder = 0
Global $g_hGUI_BBDropOrder = 0
Global $g_hChkBBCustomDropOrderEnable = 0
Global $g_hBtnBBDropOrderSet = 0, $g_hBtnBBRemoveDropOrder = 0, $g_hBtnBBClose = 0
Global $g_bBBDropOrderSet = False
Global Const $g_iBBTroopCount = 11
;Global Const $g_sBBDropOrderDefault = "BoxerGiant|HogGlider|SuperPekka|DropShip|Witch|BabyDrag|WallBreaker|Barbarian|CannonCart|Archer|Minion" - Team AIO Mod++
;Global $g_sBBDropOrder = $g_sBBDropOrderDefault - Team AIO Mod++
Global $g_ahCmbBBDropOrder[$g_iBBTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
;CustomArmy
Global $g_iCmbCampsBB[6] = [0, 0, 0, 0, 0, 0]
Global $g_hIcnTroopBB[6]
Global $g_hComboTroopBB[6]
Global $g_hChkBBCustomArmyEnable, $g_bChkBBCustomArmyEnable

Global $g_sIcnBBOrder[11]
Global $g_sBBDropOrderDefault
Global $g_asAttackBarBB[12] = ["", "Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider"]
Global $g_aiCmbBBDropOrder[$g_iBBTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_sBBDropOrder
For $i = 1 To UBound($g_asAttackBarBB) -1
	Local $iS = $g_asAttackBarBB[$i]
	$g_sBBDropOrder &= (UBound($g_asAttackBarBB) -1 = $i) ? ($iS) : ($iS & "|") 
Next

; Drop trophy - Team AiO MOD++
Global $g_bChkNoDropIfShield = True, $g_bChkTrophyTroops = False, $g_bChkTrophyHeroesAndTroops = True
; GUI
Global $g_hChkNoDropIfShield, $g_hChkTrophyTroops, $g_hChkTrophyHeroesAndTroops

; No reddrop - Team AiO MOD++
Global $g_aIsDead[UBound($g_avAttackTroops, 1) -1]
Global $g_iSlotNow = -1

; Misc tab - Team AiO MOD++
Global $g_bUseSleep = False, $g_iIntSleep = 20, $g_bUseRandomSleep = False, $g_bNoAttackSleep = False, $g_bDeployCastleFirst = False, $g_bDisableColorLog = False, $g_bDelayLabel = False, $g_bAvoidLocation = False
; GUI
Global $g_hUseSleep, $g_hIntSleep, $g_hUseRandomSleep, $g_hNoAttackSleep, $g_hDeployCastleFirst, $g_hDisableColorLog, $g_hDelayLabel, $g_hAvoidLocation

; SuperXP / GoblinXP - Team AiO MOD++
Global $g_bEnableSuperXP = False, $g_bSkipZoomOutSX = False, $g_bFastSuperXP = False, $g_bSkipDragToEndSX = False, _
	$g_iActivateOptionSX = 1, $g_iGoblinMapOptSX = 2, $g_sGoblinMapOptSX = "The Arena", $g_iMaxXPtoGain = 500, _
	$g_bBKingSX = False, $g_bAQueenSX = False, $g_bGWardenSX = False
Global $g_iStartXP = 0, $g_iCurrentXP = 0, $g_iGainedXP = 0, $g_iGainedHourXP = 0, $g_sRunTimeXP = 0
Global $g_bDebugSX = False
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
Global $g_aIAVar[5] = [0, 0, 0, 0, 0], $g_sIAVar = '0|0|0|0|0'
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
Global $g_iCycle = 0

; Magic Items

Global $g_bChkCollectMagicItems, $g_bChkCollectFree, _
$g_bChkBuilderPotion, $g_bChkClockTowerPotion, $g_bChkHeroPotion, $g_bChkLabPotion, $g_bChkPowerPotion, $g_bChkResourcePotion, _
$g_iComboClockTowerPotion, $g_iComboHeroPotion, $g_iComboPowerPotion, _
$g_iInputBuilderPotion, $g_iInputLabPotion, $g_iInputGoldItems = 250000, $g_iInputElixirItems = 300000, $g_iInputDarkElixirItems = 1000

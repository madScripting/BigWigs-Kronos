
BigWigsBattlegrounds = BigWigs:NewModule("Battlegrounds")
BigWigsBattlegrounds.revision = 20057
BigWigsBattlegrounds.external = true
BigWigsBattlegrounds.consoleCmd = "Battlegrounds"

--[[ToDo
	Outside - timer bar when BG pops
			Figure out when to check for time left
			Figure out Which index to verify
			Figure out how to stop the bar on cancel and on bg enter
			expiration = GetBattlefieldPortExpiration(1);--gives time in milliseconds, is 1 always WSG?
			clickTime = expiration / 1000
			self:Bar(L["clickTimeBar"], clickTime, icon.clickTimeIcon)

	WSG - 	Add EFC hp% (sync)
			Add powerUps timers

	AB - Confirm defending flag works
			Create bar for victory/defeat and verify accuracy
	AV - module not done
]]--
--[[
/script landmarksQty = GetNumMapLandmarks();
/script DEFAULT_CHAT_FRAME:AddMessage("landmarksQty: "..landmarksQty );

/script a=1;
/script name, desc, typ, x, y = GetMapLandmarkInfo(a);
/script DEFAULT_CHAT_FRAME:AddMessage(a.." name: "..name);
/script DEFAULT_CHAT_FRAME:AddMessage(a.." desc: "..desc);
/script DEFAULT_CHAT_FRAME:AddMessage(a.." typ: "..typ);
/script DEFAULT_CHAT_FRAME:AddMessage(a.." x: "..x);
/script DEFAULT_CHAT_FRAME:AddMessage(a.." y: "..y);

typ:
Alterac Valley
	0 = Mines, no icon
	1 = Horde controlled mine
	2 = Alliance controlled mine
	3 = Horde graveyard attacked by Alliance
	4 = Towns (Booty Bay, Stonard, etc)
	5 = Destroyed tower
	6 = 
	7 = Uncontrolled Graveyard (Snowfall at start)
	8 = Horde tower attacked by Alliance
	9 = Horde controlled tower
	10 = Alliance controlled tower
	11 = Alliance tower attacked by Horde
	12 = Horde controlled graveyard
	13 = Alliance graveyard attacked by Horde
	14 = Alliance controlled graveyard
	15 = Garrisons/Caverns, no icon
Arathi Basin
	16 - Gold Mine - Uncontrolled
	17 - Gold Mine .. in conflict (Alliance capturing)
	18 - Gold Mine - Alliance controlled
	19 = Gold Mine .. in conflict (Horde capturing)
	20 = Gold Mine - Horde Controlled
	21 = Lumber Mill - Uncontrolled
	22 = Lumber Mill .. in conflict (Alliance capturing)
	23 = Lumber Mill - Alliance controlled
	24 = Lumber Mill .. in conflict (Horde capturing)
	25 = Lumber Mill - Horde Controlled
	26 = Blacksmith - Uncontrolled
	27 = Blacksmith .. in conflict (Alliance capturing)
	28 = Blacksmith - Alliance controlled
	29 = Blacksmith .. in conflict (Horde capturing)
	30 = Blacksmith - Horde controlled
	31 = Farm - Uncontrolled
	32 = Farm .. in conflict (Alliance capturing)
	33 = Farm - Alliance controlled
	34 = Farm .. in conflict (Horde capturing)
	35 = Farm - Horde controlled
	36 = Stables - Uncontrolled
	37 = Stables .. in conflict (Alliance capturing)
	38 = Stables - Alliance controlled
	39 = Stables .. in conflict (Horde capturing)
	40 = Stables - Horde controlled
--]]

local L = AceLibrary("AceLocale-2.2"):new("BigWigsBattlegrounds")

L:RegisterTranslations("enUS", function() return {
	["Battlegrounds"] = true,
	["Options for the Battlegrounds module."] = true,
	["Toggle Battlegrounds bars on or off."] = true,
	["Bars"] = true,
	
	["Resurrection"] = true,
	["Toggle Battlegrounds Resurrection bars on or off."] = true,
	
	--Outside
	clickTimeTrigger = "Hello World",
	clickTimeBar = "Battleground",
	
	--All BG
	gameStartTrigger = "30 seconds",
	gameStartBar = "Game Start",
	
	--WSG
	wsgFlagCapTrigger = "captured",
	wsgFlagSpawnBar = "Flags spawn",
	
	wsgHordeFcTrigger = "The Alliance Flag was picked up by (.+)!",
	wsgHordeFcDropTrigger = "The Alliance Flag was dropped by (.+)!",
	wsgHordeFcBar = "Horde FC ",
	
	wsgAllianceFcTrigger = "The Horde flag was picked up by (.+)!",
	wsgAllianceFcDropTrigger = "The Horde flag was dropped by (.+)!",
	wsgAllianceFcBar = "Alliance FC ",
	
	wsgResBar = "Resurrection",
	
	--AB
		--Cap
	abFarmCapHordeTrigger = "claims the farm! If left unchallenged, the Horde will",
	abBlacksmithCapHordeTrigger = "claims the blacksmith! If left unchallenged, the Horde will",
	abGoldMineCapHordeTrigger = "claims the mine! If left unchallenged, the Horde will",
	abLumberMillCapHordeTrigger = "claims the lumber mill! If left unchallenged, the Horde will",
	abStablesCapHordeTrigger = "claims the stables! If left unchallenged, the Horde will",
	
	abFarmCapAllianceTrigger = "claims the farm! If left unchallenged, the Alliance will",
	abBlacksmithCapAllianceTrigger = "claims the blacksmith! If left unchallenged, the Alliance will",
	abGoldMineCapAllianceTrigger = "claims the mine! If left unchallenged, the Alliance will",
	abLumberMillCapAllianceTrigger = "claims the lumber mill! If left unchallenged, the Alliance will",
	abStablesCapAllianceTrigger = "claims the stables! If left unchallenged, the Alliance will",
		--Defend
	abFarmSaveTrigger = "has defended the farm",
	abBlacksmithSaveTrigger = "has defended the blacksmith",
	abGoldMineSaveTrigger = "has defended the mine",
	abLumberMillSaveTrigger = "has defended the lumber mill",
	abStablesSaveTrigger = "has defended the stables",
	
	abFarmCapHordeBar = "Farm Horde Cap",
	abBlacksmithCapHordeBar = "Blacksmith Horde Cap",
	abGoldMineCapHordeBar = "Gold Mine Horde Cap",
	abLumberMillCapHordeBar = "Lumber Mill Horde Cap",
	abStablesCapHordeBar = "Stables Horde Cap",
		--Assault
	abFarmAssaultTrigger = "(.+) has assaulted the farm",
	abBlacksmithAssaultTrigger = "(.+) has assaulted the blacksmith",
	abGoldMineAssaultTrigger = "(.+) has assaulted the mine",
	abLumberMillAssaultTrigger = "(.+) has assaulted the lumber mill",
	abStablesAssaultTrigger = "(.+) has assaulted the stables",
		--Bars
	abFarmCapHordeBar = "Farm Horde Cap",
	abBlacksmithCapHordeBar = "Blacksmith Horde Cap",
	abGoldMineCapHordeBar = "Gold Mine Horde Cap",
	abLumberMillCapHordeBar = "Lumber Mill Horde Cap",
	abStablesCapHordeBar = "Stables Horde Cap",
	
	abFarmCapAllianceBar = "Farm Alliance Cap",
	abBlacksmithCapAllianceBar = "Blacksmith Alliance Cap",
	abGoldMineCapAllianceBar = "Gold Mine Alliance Cap",
	abLumberMillCapAllianceBar = "Lumber Mill Alliance Cap",
	abStablesCapAllianceBar = "Stables Alliance Cap",
	
	abVictoryTrigger = "Hello World",
	abVictoryEndTimerBar = "Victory",
	abDefeatTrigger = "Hello World",
	abDefeatEndTimerBar = "Defeat",
	
	abFarmResBar = "Fm Resurrect",
	abBlacksmithResBar = "Bs Resurrect",
	abGoldMineResBar = "Gm Resurrect",
	abStablesResBar = "St Resurrect",
	abLumberMillResBar = "Lm Resurrect",
	
	--[[AV
	Galv dead
	Bitch dead
	summons
	Coldtooth Mine
	Irondeep Mine
	
	Ivus the Forest Lord
	Lokholar the Icelord
	avAidStationHordeCapTrigger = "Hello World",
	avStormpikeGyHordeCapTrigger = "Hello World",
	avStonehearthGyHordeCapTrigger = "Hello World",
	avSnowfallGyHordeCapTrigger = "Hello World",
	avIcebloodGyHordeCapTrigger = "Hello World",
	avReliefHutHordeCapTrigger = "Hello World",
	
	avAidStationAllianceCapTrigger = "Hello World",
	avStormpikeGyAllianceCapTrigger = "Hello World",
	avStonehearthGyAllianceCapTrigger = "Hello World",
	avSnowfallGyAllianceCapTrigger = "Hello World",
	avIcebloodGyAllianceCapTrigger = "Hello World",
	avReliefHutAllianceCapTrigger = "Hello World",
	
	avGyCapBar = " Gy Cap",
	
	avIcebloodTowerHordeSaveTrigger = "Hello World",
	avTowerpointHordeSaveTrigger = "Hello World",
	avWestFrostwolfTowerHordeSaveTrigger = "Hello World",
	avEastFrostwolfTowerHordeSaveTrigger = "Hello World",
	avIcewingBunkerHordeCapTrigger = "Hello World",
	avStonehearthBunkerHordeCapTrigger = "Hello World",
	avDunBaldarSouthBunkerHordeCapTrigger = "Hello World",
	avDunBaldarNorthBunkerHordeCapTrigger = "Hello World",
	
	avIcebloodTowerAllianceCapTrigger = "Hello World",
	avTowerpointAllianceCapTrigger = "Hello World",
	avWestFrostwolfTowerAllianceCapTrigger = "Hello World",
	avEastFrostwolfTowerAllianceCapTrigger = "Hello World",
	avIcewingBunkerAllianceSaveTrigger = "Hello World",
	avStonehearthBunkerAllianceSaveTrigger = "Hello World",
	avDunBaldarSouthBunkerAllianceSaveTrigger = "Hello World",
	avDunBaldarNorthBunkerAllianceSaveTrigger = "Hello World",

	avTowerCapBar = " Tower Cap",
	]]--
} end)

BigWigsBattlegrounds.defaults = {
	bars = true,
	resurrection = true,
}

BigWigsBattlegrounds.consoleOptions = {
	type = "group",
	name = L["Battlegrounds"],
	desc = L["Options for the Battlegrounds module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle Battlegrounds bars on or off."],
			get = function() return BigWigsBattlegrounds.db.profile.bars end,
			set = function(v)
				BigWigsBattlegrounds.db.profile.bars = v
			end,
		},
		[L["Resurrection"]] = {
			type = "toggle",
			name = L["Resurrection"],
			desc = L["Toggle Battlegrounds Resurrection bars on or off."],
			get = function() return BigWigsBattlegrounds.db.profile.res end,
			set = function(v)
				BigWigsBattlegrounds.db.profile.res = v
			end,
		},
	}
}

local icon = {
	clickTimeIcon = "inv_misc_pocketwatch_01",
	gameStartIcon = "inv_misc_pocketwatch_01",
	resIcon = "spell_holy_resurrection",

	--WSG
	wsgHordeFcIcon = "inv_bannerpvp_01",
	wsgAllianceFcIcon = "inv_bannerpvp_02",
	
	--AB
	abFlagCapHordeIcon = "inv_bannerpvp_01",
	abFlagCapAllianceIcon = "inv_bannerpvp_02",
	abEndTimerIcon = "inv_misc_pocketwatch_01",

	--[[AV
	avGyCapHordeIcon = "inv_bannerpvp_01",
	avGyCapAllianceIcon = "inv_bannerpvp_02",
	avTowerCapHordeIcon = "inv_bannerpvp_01",
	avTowerCapAllianceIcon = "inv_bannerpvp_02",
	]]--
}

local timer = {
	gameStartTimer = 30,
	resTimer = 30,
	
	--WSG
	wsgFlagSpawnTimer = 23,
	wsgFcTimer = 3600,
	
	--AB
	abFlagCapTimer = 60,
	
	--[[AV
	avGyCapTimer = 240,
	avTowerCapTimer = 240,
	]]--
}

local color = {
	hordeColor = "Red",
	allianceColor = "Blue",
	
	resColor = "White",
	
	abVictoryColor = "White",
	abDefeatColor = "Black",
}

function BigWigsBattlegrounds:OnEnable()
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "Event")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "Event")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "Event")
	
	self:RegisterEvent("CHAT_MSG_ADDON", "AddonMsg")
	
	--self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "BattlefieldStatus")
	--self:RegisterEvent("UPDATE_WORLD_STATES", "WorldStates")
	
	--WSG
	wsgResTimerScheduled = 0
	
	--AB
	abFarmResTimerScheduled = 0
	abBlacksmithResTimerScheduled = 0
	abGoldMineTimerScheduled = 0
	abLumberMillTimerScheduled = 0
	abStablesTimerScheduled = 0
	
	--AV
end

function BigWigsBattlegrounds:OnDisable()
	--WSG
	wsgResTimerScheduled = 0
	
	--AB
	abFarmResTimerScheduled = 0
	abBlacksmithResTimerScheduled = 0
	abGoldMineTimerScheduled = 0
	abLumberMillTimerScheduled = 0
	abStablesTimerScheduled = 0
	
	--AV
end

function BigWigsBattlegrounds:OnSetup()

end

function BigWigsBattlegrounds:WorldStates(msg)
	
end

function BigWigsBattlegrounds:BattlefieldStatus(msg)
	
end

function BigWigsBattlegrounds:Event(msg)
	if string.find(msg, L["clickTimeTrigger"]) then
		self:Bar(L["clickTimeBar"], timer.clickTimeTimer, icon.clickTimeIcon)
	end
	if string.find(msg, L["gameStartTrigger"]) then
		self:Bar(L["gameStartBar"], timer.gameStartTimer, icon.gameStartIcon)
		if "Warsong Gulch" == GetZoneText() then
			self:ScheduleRepeatingEvent("wsgResTimerStart", self.BigWigs_Battlegrounds_WsgResTimerStart, 30, self)
		end
	end
	
	--WSG
		--Horde
	if string.find(msg, L["wsgHordeFcTrigger"]) then
		_,_,hordeFc,_ = string.find(msg, L["wsgHordeFcTrigger"])
		self:Bar(string.format(L["wsgHordeFcBar"] .. hordeFc), timer.wsgFcTimer, icon.wsgHordeFcIcon, color.hordeColor)
		self:SetCandyBarOnClick("BigWigsBar "..string.format(L["wsgHordeFcBar"] .. hordeFc), function(name, button, extra) TargetByName(extra, true) end, hordeFc)
	end
	if string.find(msg, L["wsgHordeFcDropTrigger"]) then
		if hordeFc ~= nil then
			self:RemoveBar(string.format(L["wsgHordeFcBar"] .. hordeFc))
		end
	end
		--Alliance
	if string.find(msg, L["wsgAllianceFcTrigger"]) then
		_,_,allianceFc,_ = string.find(msg, L["wsgAllianceFcTrigger"])
		self:Bar(string.format(L["wsgAllianceFcBar"] .. allianceFc), timer.wsgFcTimer, icon.wsgAllianceFcIcon, color.allianceColor)
		self:SetCandyBarOnClick("BigWigsBar "..string.format(L["wsgAllianceFcBar"] .. allianceFc), function(name, button, extra) TargetByName(extra, true) end, allianceFc)
	end
	if string.find(msg, L["wsgAllianceFcDropTrigger"]) then
		if allianceFc ~= nil then
			self:RemoveBar(string.format(L["wsgAllianceFcBar"] .. allianceFc))
		end
	end
		--Both
	if string.find(msg, L["wsgFlagCapTrigger"]) then
		if hordeFc ~= nil then
			self:RemoveBar(string.format(L["wsgHordeFcBar"] .. hordeFc))
		end
		if allianceFc ~= nil then
			self:RemoveBar(string.format(L["wsgAllianceFcBar"] .. allianceFc))
		end
		self:Bar(L["wsgFlagSpawnBar"], timer.wsgFlagSpawnTimer, icon.gameStartIcon, true, "Black")
	end
	
	--AB
		--Horde
	if string.find(msg, L["abFarmCapHordeTrigger"]) then
		self:Bar(L["abFarmCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		self:ScheduleRepeatingEvent("abFarmResDelayedTimerStart", self.BigWigs_Battlegrounds_AbFarmResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abBlacksmithCapHordeTrigger"]) then
		self:Bar(L["abBlacksmithCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		self:ScheduleRepeatingEvent("abBlacksmithResDelayedTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abGoldMineCapHordeTrigger"]) then
		self:Bar(L["abGoldMineCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		self:ScheduleRepeatingEvent("abGoldMineResDelayedTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abLumberMillCapHordeTrigger"]) then
		self:Bar(L["abLumberMillCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		self:ScheduleRepeatingEvent("abLumberMillResDelayedTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abStablesCapHordeTrigger"]) then
		self:Bar(L["abStablesCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		self:ScheduleRepeatingEvent("abStablesResDelayedTimerStart", self.BigWigs_Battlegrounds_AbStablesResDelayedTimerStart, 62, self)
	end
		--Alliance
	if string.find(msg, L["abFarmCapAllianceTrigger"]) then
		self:Bar(L["abFarmCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		self:ScheduleRepeatingEvent("abFarmResDelayedTimerStart", self.BigWigs_Battlegrounds_AbFarmResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abBlacksmithCapAllianceTrigger"]) then
		self:Bar(L["abBlacksmithCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		self:ScheduleRepeatingEvent("abBlacksmithResDelayedTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abGoldMineCapAllianceTrigger"]) then
		self:Bar(L["abGoldMineCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		self:ScheduleRepeatingEvent("abGoldMineResDelayedTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abLumberMillCapAllianceTrigger"]) then
		self:Bar(L["abLumberMillCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		self:ScheduleRepeatingEvent("abLumberMillResDelayedTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResDelayedTimerStart, 62, self)
	end
	if string.find(msg, L["abStablesCapAllianceTrigger"]) then
		self:Bar(L["abStablesCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		self:ScheduleRepeatingEvent("abStablesResDelayedTimerStart", self.BigWigs_Battlegrounds_AbStablesResDelayedTimerStart, 62, self)
	end
		--Both
			--Save
	if string.find(msg, L["abFarmSaveTrigger"]) then
		self:RemoveBar(L["abFarmCapHordeBar"])
		self:RemoveBar(L["abFarmCapAllianceBar"])
		self:CancelScheduledEvent("abFarmResDelayedTimerStart")
		self:CancelScheduledEvent("abFarmResTimerStart")
		self:RemoveBar(L["abFarmResBar"])
		self:ScheduleRepeatingEvent("abFarmResDelayedTimerStart", self.BigWigs_Battlegrounds_AbFarmResDelayedTimerStart, 2, self)
	end
	if string.find(msg, L["abBlacksmithSaveTrigger"]) then
		self:RemoveBar(L["abBlacksmithCapHordeBar"])
		self:RemoveBar(L["abBlacksmithCapAllianceBar"])
		self:CancelScheduledEvent("abBlacksmithResDelayedTimerStart")
		self:CancelScheduledEvent("abBlacksmithResTimerStart")
		self:RemoveBar(L["abBlacksmithResBar"])
		self:ScheduleRepeatingEvent("abBlacksmithResDelayedTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResDelayedTimerStart, 2, self)
	end
	if string.find(msg, L["abGoldMineSaveTrigger"]) then
		self:RemoveBar(L["abGoldMineCapHordeBar"])
		self:RemoveBar(L["abGoldMineCapAllianceBar"])
		self:CancelScheduledEvent("abGoldMineResDelayedTimerStart")
		self:CancelScheduledEvent("abGoldMineResTimerStart")
		self:RemoveBar(L["abGoldMineResBar"])
		self:ScheduleRepeatingEvent("abGoldMineResDelayedTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResDelayedTimerStart, 2, self)
	end
	if string.find(msg, L["abLumberMillSaveTrigger"]) then
		self:RemoveBar(L["abLumberMillCapHordeBar"])
		self:RemoveBar(L["abLumberMillCapAllianceBar"])
		self:CancelScheduledEvent("abLumberMillResDelayedTimerStart")
		self:CancelScheduledEvent("abLumberMillResTimerStart")
		self:RemoveBar(L["abLumberMillResBar"])
		self:ScheduleRepeatingEvent("abLumberMillResDelayedTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResDelayedTimerStart, 2, self)
	end
	if string.find(msg, L["abStablesSaveTrigger"]) then
		self:RemoveBar(L["abStablesCapHordeBar"])
		self:RemoveBar(L["abStablesCapAllianceBar"])
		self:CancelScheduledEvent("abStablesResDelayedTimerStart")
		self:CancelScheduledEvent("abStablesResTimerStart")
		self:RemoveBar(L["abStablesResBar"])
		self:ScheduleRepeatingEvent("abStablesResDelayedTimerStart", self.BigWigs_Battlegrounds_AbStablesResDelayedTimerStart, 2, self)
	end
			--Assault
	if string.find(msg, L["abFarmAssaultTrigger"]) then
		self:RemoveBar(L["abFarmCapHordeBar"])
		self:RemoveBar(L["abFarmCapAllianceBar"])
		self:CancelScheduledEvent("abFarmResDelayedTimerStart")
		self:CancelScheduledEvent("abFarmResTimerStart")
		self:RemoveBar(L["abFarmResBar"])
		self:ScheduleRepeatingEvent("abFarmResDelayedTimerStart", self.BigWigs_Battlegrounds_AbFarmResDelayedTimerStart, 62, self)
		
		local _,_,assaulter,_ = string.find(msg, L["abFarmAssaultTrigger"])
		local englishFaction, localizedFaction = UnitFactionGroup("player")
		local members = GetNumRaidMembers()
		sameFaction = false
		for i = 1,members do
			raidMember = UnitName("raid"..i);
			if raidMember == assaulter then
				sameFaction = true
			end
		end
		if sameFaction == true then
			assaulterFaction = englishFaction
		else
			if englishFaction == "Horde" then
				assaulterFaction = "Alliance"
			else
				assaulterFaction = "Horde"
			end
		end
		if assaulterFaction == "Horde" then
			self:Bar(L["abFarmCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		end
		if assaulterFaction == "Alliance" then
			self:Bar(L["abFarmCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		end
	end
	if string.find(msg, L["abBlacksmithAssaultTrigger"]) then
		self:RemoveBar(L["abBlacksmithCapHordeBar"])
		self:RemoveBar(L["abBlacksmithCapAllianceBar"])
		self:CancelScheduledEvent("abBlacksmithResDelayedTimerStart")
		self:CancelScheduledEvent("abBlacksmithResTimerStart")
		self:RemoveBar(L["abBlacksmithResBar"])
		self:ScheduleRepeatingEvent("abBlacksmithResDelayedTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResDelayedTimerStart, 62, self)
		
		local _,_,assaulter,_ = string.find(msg, L["abBlacksmithAssaultTrigger"])
		local englishFaction, localizedFaction = UnitFactionGroup("player")
		local members = GetNumRaidMembers()
		sameFaction = false
		for i = 1,members do
			raidMember = UnitName("raid"..i);
			if raidMember == assaulter then
				sameFaction = true
			end
		end
		if sameFaction == true then
			assaulterFaction = englishFaction
		else
			if englishFaction == "Horde" then
				assaulterFaction = "Alliance"
			else
				assaulterFaction = "Horde"
			end
		end
		if assaulterFaction == "Horde" then
			self:Bar(L["abBlacksmithCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		end
		if assaulterFaction == "Alliance" then
			self:Bar(L["abBlacksmithCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		end
	end
	if string.find(msg, L["abGoldMineAssaultTrigger"]) then
		self:RemoveBar(L["abGoldMineCapHordeBar"])
		self:RemoveBar(L["abGoldMineCapAllianceBar"])
		self:CancelScheduledEvent("abGoldMineResDelayedTimerStart")
		self:CancelScheduledEvent("abGoldMineResTimerStart")
		self:RemoveBar(L["abGoldMineResBar"])
		self:ScheduleRepeatingEvent("abGoldMineResDelayedTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResDelayedTimerStart, 62, self)

		local _,_,assaulter,_ = string.find(msg, L["abGoldMineAssaultTrigger"])
		local englishFaction, localizedFaction = UnitFactionGroup("player")
		local members = GetNumRaidMembers()
		sameFaction = false
		for i = 1,members do
			raidMember = UnitName("raid"..i);
			if raidMember == assaulter then
				sameFaction = true
			end
		end
		if sameFaction == true then
			assaulterFaction = englishFaction
		else
			if englishFaction == "Horde" then
				assaulterFaction = "Alliance"
			else
				assaulterFaction = "Horde"
			end
		end
		if assaulterFaction == "Horde" then
			self:Bar(L["abGoldMineCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		end
		if assaulterFaction == "Alliance" then
			self:Bar(L["abGoldMineCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		end
	end
	if string.find(msg, L["abLumberMillAssaultTrigger"]) then
		self:RemoveBar(L["abLumberMillCapHordeBar"])
		self:RemoveBar(L["abLumberMillCapAllianceBar"])
		self:CancelScheduledEvent("abLumberMillResDelayedTimerStart")
		self:CancelScheduledEvent("abLumberMillResTimerStart")
		self:RemoveBar(L["abLumberMillResBar"])
		self:ScheduleRepeatingEvent("abLumberMillResDelayedTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResDelayedTimerStart, 62, self)
		
		local _,_,assaulter,_ = string.find(msg, L["abLumberMillAssaultTrigger"])
		local englishFaction, localizedFaction = UnitFactionGroup("player")
		local members = GetNumRaidMembers()
		sameFaction = false
		for i = 1,members do
			raidMember = UnitName("raid"..i);
			if raidMember == assaulter then
				sameFaction = true
			end
		end
		if sameFaction == true then
			assaulterFaction = englishFaction
		else
			if englishFaction == "Horde" then
				assaulterFaction = "Alliance"
			else
				assaulterFaction = "Horde"
			end
		end
		if assaulterFaction == "Horde" then
			self:Bar(L["abLumberMillCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		end
		if assaulterFaction == "Alliance" then
			self:Bar(L["abLumberMillCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		end
	end
	if string.find(msg, L["abStablesAssaultTrigger"]) then
		self:RemoveBar(L["abStablesCapHordeBar"])
		self:RemoveBar(L["abStablesCapAllianceBar"])
		self:CancelScheduledEvent("abStablesResDelayedTimerStart")
		self:CancelScheduledEvent("abStablesResTimerStart")
		self:RemoveBar(L["abStablesResBar"])
		self:ScheduleRepeatingEvent("abStablesResDelayedTimerStart", self.BigWigs_Battlegrounds_AbStablesResDelayedTimerStart, 62, self)
		
		local _,_,assaulter,_ = string.find(msg, L["abStablesAssaultTrigger"])
		local englishFaction, localizedFaction = UnitFactionGroup("player")
		local members = GetNumRaidMembers()
		sameFaction = false
		for i = 1,members do
			raidMember = UnitName("raid"..i);
			if raidMember == assaulter then
				sameFaction = true
			end
		end
		if sameFaction == true then
			assaulterFaction = englishFaction
		else
			if englishFaction == "Horde" then
				assaulterFaction = "Alliance"
			else
				assaulterFaction = "Horde"
			end
		end
		if assaulterFaction == "Horde" then
			self:Bar(L["abStablesCapHordeBar"], timer.abFlagCapTimer, icon.abFlagCapHordeIcon, true, color.hordeColor)
		end
		if assaulterFaction == "Alliance" then
			self:Bar(L["abStablesCapAllianceBar"], timer.abFlagCapTimer, icon.abFlagCapAllianceIcon, true, color.allianceColor)
		end
	end
		--Time to victory/defeat
	if string.find(msg, L["abVictoryTrigger"]) then
		self:Bar(L["abVictoryEndTimerBar"], 60, icon.abEndTimerIcon, true, color.abVictoryColor)
	end
	if string.find(msg, L["abDefeatTrigger"]) then
		self:Bar(L["abDefeatEndTimerBar"], 60, icon.abEndTimerIcon, true, color.abDefeatColor)
	end

	--[[AV
	]]--
end

--WSG res
function BigWigsBattlegrounds:BigWigs_Battlegrounds_WsgResTimerStart()
	if self.db.profile.res then
		self:Bar(L["wsgResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	wsgResTimerScheduled = 1
	SendAddonMessage("BigWigs","wsgResTimerStart", "BATTLEGROUND")
end

--AB res
	--Farm
function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbFarmResDelayedTimerStart()
	if self.db.profile.res then
		self:Bar(L["abFarmResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	self:ScheduleRepeatingEvent("abFarmResTimerStart", self.BigWigs_Battlegrounds_AbFarmResTimerStart, 30, self)
	self:CancelScheduledEvent("abFarmResDelayedTimerStart")
end

function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbFarmResTimerStart()
	if self.db.profile.res then
		self:Bar(L["abFarmResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	abFarmResTimerScheduled = 1
	SendAddonMessage("BigWigs","abFarmResTimerStart", "BATTLEGROUND")
end

	--Blacksmith
function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbBlacksmithResDelayedTimerStart()
	if self.db.profile.res then
		self:Bar(L["abBlacksmithResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	self:ScheduleRepeatingEvent("abBlacksmithResTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResTimerStart, 30, self)
	self:CancelScheduledEvent("abBlacksmithResDelayedTimerStart")
end

function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbBlacksmithResTimerStart()
	if self.db.profile.res then
		self:Bar(L["abBlacksmithResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	abBlacksmithResTimerScheduled = 1
	SendAddonMessage("BigWigs","abBlacksmithResTimerStart", "BATTLEGROUND")
end

	--GoldMine
function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbGoldMineResDelayedTimerStart()
	if self.db.profile.res then
		self:Bar(L["abGoldMineResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	self:ScheduleRepeatingEvent("abGoldMineResTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResTimerStart, 30, self)
	self:CancelScheduledEvent("abGoldMineResDelayedTimerStart")
end

function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbGoldMineResTimerStart()
	if self.db.profile.res then
		self:Bar(L["abGoldMineResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	abGoldMineResTimerScheduled = 1
	SendAddonMessage("BigWigs","abGoldMineResTimerStart", "BATTLEGROUND")
end

	--LumberMill
function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbLumberMillResDelayedTimerStart()
	if self.db.profile.res then
		self:Bar(L["abLumberMillResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	self:ScheduleRepeatingEvent("abLumberMillResTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResTimerStart, 30, self)
	self:CancelScheduledEvent("abLumberMillResDelayedTimerStart")
end

function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbLumberMillResTimerStart()
	if self.db.profile.res then
		self:Bar(L["abLumberMillResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	abLumberMillResTimerScheduled = 1
	SendAddonMessage("BigWigs","abLumberMillResTimerStart", "BATTLEGROUND")
end

	--Stables
function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbStablesResDelayedTimerStart()
	if self.db.profile.res then
		self:Bar(L["abStablesResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	self:ScheduleRepeatingEvent("abStablesResTimerStart", self.BigWigs_Battlegrounds_AbStablesResTimerStart, 30, self)
	self:CancelScheduledEvent("abStablesResDelayedTimerStart")
end

function BigWigsBattlegrounds:BigWigs_Battlegrounds_AbStablesResTimerStart()
	if self.db.profile.res then
		self:Bar(L["abStablesResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
	end
	abStablesResTimerScheduled = 1
	SendAddonMessage("BigWigs","abStablesResTimerStart", "BATTLEGROUND")
end

--AddonMsg aka BattlegroundSync
function BigWigsBattlegrounds:AddonMsg(prefix,text,target,author)
	--WSG
	if prefix == "BigWigs" and text =="wsgResTimerStart" and wsgResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["wsgResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("wsgResTimerStart", self.BigWigs_Battlegrounds_WsgResTimerStart, 30, self)
	
	--AB
		--Farm
	elseif prefix == "BigWigs" and text =="abFarmResTimerStart" and abFarmResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["abFarmResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("abFarmResTimerStart", self.BigWigs_Battlegrounds_AbFarmResTimerStart, 30, self)
		--Blacksmith
	elseif prefix == "BigWigs" and text =="abBlacksmithResTimerStart" and abBlacksmithResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["abBlacksmithResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("abBlacksmithResTimerStart", self.BigWigs_Battlegrounds_AbBlacksmithResTimerStart, 30, self)
		--GoldMin
	elseif prefix == "BigWigs" and text =="abGoldMineResTimerStart" and abGoldMineResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["abGoldMineResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("abGoldMineResTimerStart", self.BigWigs_Battlegrounds_AbGoldMineResTimerStart, 30, self)
		--LumberMill
	elseif prefix == "BigWigs" and text =="abLumberMillResTimerStart" and abLumberMillResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["abLumberMillResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("abLumberMillResTimerStart", self.BigWigs_Battlegrounds_AbLumberMillResTimerStart, 30, self)
		--Stables
	elseif prefix == "BigWigs" and text =="abStablesResTimerStart" and abStablesResTimerScheduled == 0 then
		if self.db.profile.res then
			self:Bar(L["abStablesResBar"], timer.resTimer, icon.resIcon, true, color.resColor)
		end
		self:ScheduleRepeatingEvent("abStablesResTimerStart", self.BigWigs_Battlegrounds_AbStablesResTimerStart, 30, self)
	
	--AV
	end
end

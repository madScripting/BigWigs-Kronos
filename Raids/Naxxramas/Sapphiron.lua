
local module, L = BigWigs:ModuleDeclaration("Sapphiron", "Naxxramas")

module.revision = 20051
module.enabletrigger = module.translatedName
module.toggleoptions = {"block", "berserk", "proximity", "lifedrain", "deepbreath", "icebolt", "blizzard", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sapphiron",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath alert",
	deepbreath_desc = "Warn when Sapphiron begins to cast Deep Breath.",

	lifedrain_cmd = "lifedrain",
	lifedrain_name = "Life Drain",
	lifedrain_desc = "Warns about the Life Drain curse.",
	
	block_cmd = "block",
	block_name = "Ice Blocks",
	block_desc = "Bars for Ice blocks.",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for berserk.",

	icebolt_cmd = "icebolt",
	icebolt_name = "Announce Ice Block",
	icebolt_desc = "Yell when you become an Ice Block.",
	
	blizzard_cmd = "blizzard",
	blizzard_name = "Icon for blizzard",
	blizzard_desc = "Display an icon when you are standing in blizzard.",

	proximity_cmd = "proximity",
	proximity_name = "Proximity Warning",
	proximity_desc = "Show Proximity Warning Frame",
	
	berserk_bar = "Berserk",

	lifedrain_trigger = "afflicted by Life Drain",
	lifedrain_trigger2 = "Life Drain was resisted by",
	lifedrain_message = "Life Drain! New one in 24sec!",
	lifedrain_bar = "Life Drain",

	icebolt_trigger = "You are afflicted by Icebolt",
	icebolt_yell = "I'm an Ice Block!",
	icebolt_bar = "Ice bolt %d",
	
	block_trigger = "(.+) (.+) afflicted by Icebolt",
	block_bar = " Ice Blocked",
	
	deepbreath_incoming_bar = "Ice Bomb Cast",
	deepbreath_trigger = "%s takes in a deep breath...",
	deepbreath_warning = "Ice Bomb Incoming!",
	deepbreath_bar = "Ice Bomb Lands!",
	
	deepBreathOver_trigger = "Sapphiron's Frost Breath fails",
	deepBreathOver_warn = "Orb Landed",
	
	flight_emote = "%s lifts off into the air!",
	flight_message = "Air phase!",
	airPhase_bar = "Ground Phase",
	airSoon_bar = "Air soon...",
	airSoon1_bar = "Air soon...",
	
	groundPhase_bar = "Air within 10sec",
	resume_emote = "%s resumes his attacks!",
	
	blizzardGained = "You are afflicted by Chill.",
	blizzardLost = "Chill fades from you.",
} end )

module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
module.proximitySilent = true

local timer = {
	berserk = 900,
	deepbreathAfterLift = 25,
	deepbreath = 8,
	firstLifedrain = 7,
	lifedrainAfterFlight = 6,
	lifedrain = 23,
	iceboltAfterFlight = 9,
	iceboltInterval = 4,
	firstGroundPhase = 35, --seems to be cooldown based, 35sec CD with 10sec leeway
	groundPhase = 50, --seems to be cooldown based, originally set to 59sec, saw 55sec
	airPhase = 34, --Fixed 34sec
	airSoon = 15,
	airSoon1 = 10,
	block1 = 600,--24,
	block2 = 600,--20,
	block3 = 600,--16,
	block4 = 600,--12,
	block5 = 600,--8,
}

local icon = {
	deepbreath = "Spell_Frost_FrostShock",
	deepbreathInc = "Spell_Arcane_PortalIronForge",
	lifedrain = "Spell_Shadow_LifeDrain02",
	berserk = "INV_Shield_01",
	icebolt = "Spell_Frost_FrostBolt02",
	blizzard = "Spell_Frost_IceStorm",
	phase = "Spell_Magic_LesserInvisibilty",
	safe = "Spell_magic_polymorphchicken",
	frostPot = "inv_potion_20",
	block = "spell_frost_glacier",
}

local syncName = {
	lifedrain = "SapphironLifeDrain"..module.revision,
	goingAir = "SapphironGoingAir"..module.revision,
	goingGround = "SapphironGoingGround"..module.revision,
	deepBreath = "SapphironDeepBreath"..module.revision,
	deepBreathOver = "SapphironDeepBreathOver"..module.revision,
	block = "SapphironBlock"..module.revision,
}

local timeLifeDrain = nil
local _, playerClass = UnitClass("player")
local blockNum = 1
local blockGuy1 = "?"
local blockGuy2 = "?"
local blockGuy3 = "?"
local blockGuy4 = "?"
local blockGuy5 = "?"

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Emotes")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(4, syncName.lifedrain)
	self:ThrottleSync(4, syncName.goingAir)
	self:ThrottleSync(4, syncName.goingGround)
	self:ThrottleSync(4, syncName.deepBreath)
	self:ThrottleSync(4, syncName.deepBreathOver)
	self:ThrottleSync(2, syncName.block)
end

function module:OnSetup()
	self.started = nil
	timeLifeDrain = nil
end

function module:OnEngage()
	if self.db.profile.berserk then
		self:Bar(L["berserk_bar"], timer.berserk, icon.berserk, true, "white")
	end
	if self.db.profile.lifedrain then
		self:Bar(L["lifedrain_bar"], timer.firstLifedrain, icon.lifedrain, true, "green")
	end
	if self.db.profile.proximity then
		self:Proximity()
	end
	self:Bar(L["groundPhase_bar"], timer.firstGroundPhase, icon.phase, true, "black")
	self:DelayedBar(timer.firstGroundPhase, L["airSoon1_bar"],timer.airSoon1, icon.phase, true, "black")
	blockNum = 1
	blockGuy1 = "?"
	blockGuy2 = "?"
	blockGuy3 = "?"
	blockGuy4 = "?"
	blockGuy5 = "?"
end

function module:OnDisengage()
	self:RemoveProximity()
end

function module:Event(msg)
	if string.find(msg, L["block_trigger"]) then
		local _,_,name,_ = string.find(msg, L["block_trigger"])
		if name == "You" then
			blockedPerson = UnitName("player")
		else
			blockedPerson = name
		end
		self:Sync(syncName.block .. " " .. blockedPerson)
	end
	if string.find(msg, L["lifedrain_trigger"]) or string.find(msg, L["lifedrain_trigger2"]) then
		if not timeLifeDrain or (timeLifeDrain + 2) < GetTime() then
			self:Sync(syncName.lifedrain)
			timeLifeDrain = GetTime()
		end
	end
	if string.find(msg, L["icebolt_trigger"]) then
		SendChatMessage(L["icebolt_yell"], "YELL")
	end
	if string.find(msg, L["blizzardGained"]) and self.db.profile.blizzard then
		self:WarningSign(icon.blizzard, 6)
	end
	if string.find(msg, L["blizzardLost"]) and self.db.profile.blizzard then
		self:RemoveWarningSign(icon.blizzard)
	end
	if string.find(msg, L["deepBreathOver_trigger"]) then
		self:Sync(syncName.deepBreathOver)
	end
end

function module:Emotes(msg)
	if msg == L["deepbreath_trigger"] then
		self:Sync(syncName.deepBreath)
	end
	if msg == L["flight_emote"] then
		self:Sync(syncName.goingAir)
	end
	if msg == L["resume_emote"] then
		self:Sync(syncName.goingGround)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.lifedrain and self.db.profile.lifedrain then
		self:LifeDrain()
	elseif sync == syncName.deepBreath and self.db.profile.deepbreath then
		self:DeepBreath()
	elseif sync == syncName.goingAir then
		self:Flight()
	elseif sync == syncName.goingGround then
		self:Ground()
	elseif sync == syncName.deepBreathOver then
		self:DeepBreathOver()
	elseif sync == syncName.block and self.db.profile.block then
		self:Block(rest)
	end
end

function module:Block(rest)
	if blockNum == 5 then
		blockGuy5 = rest
		self:Bar(blockGuy5..L["block_bar"],timer.block5, icon.block, true, "green")
	elseif blockNum == 4 then
		blockGuy4 = rest
		self:Bar(blockGuy4..L["block_bar"],timer.block4, icon.block, true, "green")
	elseif blockNum == 3 then
		blockGuy3 = rest
		self:Bar(blockGuy3..L["block_bar"],timer.block3, icon.block, true, "green")
	elseif blockNum == 2 then
		blockGuy2 = rest
		self:Bar(blockGuy2..L["block_bar"],timer.block2, icon.block, true, "green")
	elseif blockNum == 1 then
		blockGuy1 = rest
		self:Bar(blockGuy1..L["block_bar"],timer.block1, icon.block, true, "green")
	end
	blockNum = blockNum+1
end

function module:DeepBreathOver()
	self:Message(L["deepBreathOver_warn"], "Important")
	self:WarningSign(icon.safe, 0.7)
	self:RemoveBar(blockGuy5..L["block_bar"])
	self:RemoveBar(blockGuy4..L["block_bar"])
	self:RemoveBar(blockGuy3..L["block_bar"])
	self:RemoveBar(blockGuy2..L["block_bar"])
	self:RemoveBar(blockGuy1..L["block_bar"])
	blockGuy1 = "?"
	blockGuy2 = "?"
	blockGuy3 = "?"
	blockGuy4 = "?"
	blockGuy5 = "?"
end

function module:DeepBreath()
	self:Message(L["deepbreath_warning"], "Important")
	self:Bar(L["deepbreath_bar"], timer.deepbreath, icon.deepbreath, true, "blue")
end


function module:LifeDrain()
	self:Message(L["lifedrain_message"], "Urgent", nil, nil)
	self:Bar(L["lifedrain_bar"], timer.lifedrain, icon.lifedrain, true, "green")
	if playerClass == "MAGE" or playerClass == "DRUID" then
		self:WarningSign(icon.lifedrain, 0.7)
		self:Sound("Info")
	end
end

function module:Flight()
	self:RemoveBar(L["lifedrain_bar"])
	self:RemoveBar(L["groundPhase_bar"])
	self:RemoveBar(L["airSoon_bar"])
	self:CancelDelayedBar(L["airSoon_bar"])
	if self.db.profile.deepbreath then
		self:Message(L["flight_message"], "Urgent")
		self:Bar(L["deepbreath_incoming_bar"], timer.deepbreathAfterLift, icon.deepbreathInc, true, "blue")
	end
	if self.db.profile.icebolt then
		self:Bar(string.format(L["icebolt_bar"], 1), timer.iceboltAfterFlight, icon.icebolt, true, "red")
		self:DelayedBar(timer.iceboltAfterFlight, string.format(L["icebolt_bar"], 2), timer.iceboltInterval, icon.icebolt, true, "red")
		self:DelayedBar(timer.iceboltAfterFlight + timer.iceboltInterval, string.format(L["icebolt_bar"], 3), timer.iceboltInterval, icon.icebolt, true, "red")
		self:DelayedBar(timer.iceboltAfterFlight + 2 * timer.iceboltInterval, string.format(L["icebolt_bar"], 4), timer.iceboltInterval, icon.icebolt, true, "red")
		self:DelayedBar(timer.iceboltAfterFlight + 3 * timer.iceboltInterval, string.format(L["icebolt_bar"], 5), timer.iceboltInterval, icon.icebolt, true, "red")
	end
	self:WarningSign(icon.frostPot, 0.7)
end

function module:Ground()
	self:RemoveBar(L["airPhase_bar"])
	self:Bar(L["groundPhase_bar"], timer.groundPhase, icon.phase, true, "black")
	self:DelayedBar(timer.groundPhase, L["airSoon_bar"],timer.airSoon, icon.phase, true, "black")
	if self.db.profile.lifedrain then
		self:Bar(L["lifedrain_bar"], timer.lifedrainAfterFlight, icon.lifedrain, true, "green")
	end
	blockNum = 1
end

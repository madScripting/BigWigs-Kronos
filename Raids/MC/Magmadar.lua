
local module, L = BigWigs:ModuleDeclaration("Magmadar", "Molten Core")
module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"sounds", "bigicon", "panic", "frenzy", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Magmadar",

	panic_cmd = "panic",
	panic_name = "Warn for Panic",
	panic_desc = "Warn when Magmadar casts Panic",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when Magmadar goes into a frenzy",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Stand in fire big icon alert",
	bigicon_desc = "Shows a big icon when you are standing in the fire",
	
	sounds_cmd = "sounds",
	sounds_name = "Stand in fire sound alert",
	sounds_desc = "Sound effect when you are standing in the fire",
	
	frenzy_trigger = "goes into a killing frenzy!",
	frenzyann = "Frenzy! Tranq now!",
	frenzyfade_trigger = "Frenzy fades from Magmadar",
	frenzy_bar = "Frenzy",
	frenzynext_bar = "Next Frenzy",

	panic_trigger = "afflicted by Panic.",
	panic_trigger2 = "Panic fail(.+) immune.",
	panic_trigger3 = "Magmadar's Panic was resisted",	
	fearsoon = "Panic incoming soon!",
	feartime = "Fear! 30 seconds until next!",
	fearbar = "Panic",
	
	conflag_trigger = "You are afflicted by Conflagration",
} end)

local timer = {
	earliestPanic = 30,
	latestPanic = 35,
	firstPanicDelay = 7-30,
	frenzy = 8,
	firstFrenzy = 30,
	nextFrenzy = 15,
}

local icon = {
	panic = "Spell_Shadow_DeathScream",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
	conflag = "Spell_Fire_Incinerate",
}

local syncName = {
	panic = "MagmadarPanic"..module.revision,
	frenzy = "MagmadarFrenzyStart"..module.revision,
	frenzyOver = "MagmadarFrenzyStop"..module.revision,
}

local _, playerClass = UnitClass("player")
local lastFrenzy = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(15, syncName.panic)
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(5, syncName.frenzyOver)
end

function module:OnSetup()
	lastFrenzy = 0
end

function module:OnEngage()
	self:Panic(timer.firstPanicDelay)
	self:Bar(L["frenzynext_bar"], timer.firstFrenzy, icon.frenzy, true, "red")
end

function module:OnDisengage()
end

function module:Event(msg)
	if ((string.find(msg, L["panic_trigger"])) or (string.find(msg, L["panic_trigger2"])) or (string.find(msg, L["panic_trigger3"]))) then
		self:Sync(syncName.panic)
	end
	if string.find(msg, L["conflag_trigger"]) then
		if self.db.profile.sounds then
			self:Sound("fire")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.conflag, 3)
		end
	end
	if string.find(arg1, L["frenzy_trigger"]) and self.db.profile.frenzy then
		self:Sync(syncName.frenzy)
	end
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Sync(syncName.frenzyOver)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.panic then
		self:Panic()
	elseif sync == syncName.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyOver then
		self:FrenzyOver()
	end
end

function module:Panic(delay)
	if self.db.profile.panic then
		if not delay then
			delay = 0
			self:Message(L["feartime"], "Important")
		end
		self:DelayedMessage(timer.earliestPanic - 5 + delay, L["fearsoon"], "Urgent", nil, nil, true)
		self:IntervalBar(L["fearbar"], timer.earliestPanic + delay, timer.latestPanic + delay, icon.panic)
		if playerClass == "WARRIOR" then
			self:DelayedSound(timer.earliestPanic - 10 + delay, "Ten")
			self:DelayedSound(timer.earliestPanic - 3 + delay, "Three")
			self:DelayedSound(timer.earliestPanic - 2 + delay, "Two")
			self:DelayedSound(timer.earliestPanic - 1 + delay, "One")
		end
	end
end

function module:Frenzy()
	if self.db.profile.frenzy then
		self:Message(L["frenzyann"], "Important", true, "Alert")
		self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "red")
		if playerClass == "HUNTER" then
			self:WarningSign(icon.tranquil, timer.frenzy, true)
		end
		lastFrenzy = GetTime()
	end
end

function module:FrenzyOver()
	self:RemoveBar(L["frenzy_bar"])
	self:RemoveWarningSign(icon.tranquil, true)
	if lastFrenzy ~=0 then
		self:Bar(L["frenzynext_bar"], lastFrenzy + timer.nextFrenzy - GetTime(), icon.frenzy, true, "White")
	end
end

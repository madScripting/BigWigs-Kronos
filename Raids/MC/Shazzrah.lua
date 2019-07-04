
local module, L = BigWigs:ModuleDeclaration("Shazzrah", "Molten Core")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sounds", "curse", "deaden", "blink", "counterspell", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Shazzrah",

	counterspell_cmd = "counterspell",
	counterspell_name = "Counterspell alert",
	counterspell_desc = "Warn for Shazzrah's Counterspell",

	curse_cmd = "curse",
	curse_name = "Shazzrah's Curse alert",
	curse_desc = "Warn for Shazzrah's Curse",

	deaden_cmd = "deaden",
	deaden_name = "Deaden Magic alert",
	deaden_desc = "Warn when Shazzrah has Deaden Magic",

	blink_cmd = "blink",
	blink_name = "Blink alert",
	blink_desc = "Warn when Shazzrah Blinks",

	bigicon_cmd = "bigicon",
	bigicon_name = "Deaden big icon alert",
	bigicon_desc = "Shows a big icon when Deaden is up",
	
	sounds_cmd = "sounds",
	sounds_name = "Counterspell sound alert",
	sounds_desc = "Sound effect about counterspell",

	blink_trigger = "casts Gate of Shazzrah",
	blink_warn = "Blink - 25 seconds until next one!",
	blink_soon_warn = "3 seconds to Blink!",	
	blink_bar = "Possible Blink",
	
	deaden_trigger = "Shazzrah gains Deaden Magic",
	deaden_over_trigger = "Deaden Magic fades from Shazzrah",
	deaden_warn = "Deaden Magic is up! Dispel it!",	
	deaden_bar = "Deaden Magic",
	
	curse_trigger = "afflicted by Shazzrah",
	curse_trigger2 = "Shazzrah(.+) Curse was resisted",
	curse_warn = "Shazzrah's Curse! Decurse NOW!",
	curse_bar = "Shazzrah's Curse",
	
	cs_trigger = "Shazzrah interrupts",
	cs_trigger2 = "Shazzrah interrupts",
	cs_soon_warn = "~16 seconds until next Counterspell!",
	cs_bar = "Counterspell CD",
} end)

local timer = {
	cs = 15,
	firstCS = 15,
	curse =  20,
	firstCurse = 27,
	blink = 25,
	firstBlink = 25,
	deaden = 16,
	firstDeaden = 8,
}

local icon = {
	cs = "Spell_Frost_IceShock",
	curse = "Spell_Shadow_AntiShadow",
	blink = "Spell_Arcane_Blink",
	deaden = "Spell_Holy_SealOfSalvation",
}

local syncName = {
	cs = "ShazzrahCounterspell"..module.revision,
	curse = "ShazzrahCurse"..module.revision,
	blink = "ShazzrahBlink"..module.revision,
	deaden = "ShazzrahDeadenMagicOn"..module.revision,
	deadenOver = "ShazzrahDeadenMagicOff"..module.revision,
}

local _, playerClass = UnitClass("player")
local firstblink = true

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS", "Event")

	self:ThrottleSync(10, syncName.blink)
	self:ThrottleSync(10, syncName.curse)
	self:ThrottleSync(5, syncName.deaden)
	self:ThrottleSync(5, syncName.deadenOver)
	self:ThrottleSync(0.5, syncName.cs)
end


function module:OnSetup()
	firstblink = true
end


function module:OnEngage()
	if self.db.profile.counterspell then
		self:Bar(L["cs_bar"], timer.firstCS, icon.cs, true, "red")
		if self.db.profile.sound then
			self:DelayedSound(timer.firstCS - 2, "stopcasting")
		end
	end
	if self.db.profile.blink then
		self:Bar(L["blink_bar"], timer.firstBlink, icon.blink, true, "black")
	end
	if self.db.profile.curse then
		self:Bar(L["curse_bar"], timer.firstCurse, icon.curse, true, "blue")
	end
	if self.db.profile.deaden then
		self:Bar(L["deaden_bar"], timer.firstDeaden, icon.deaden, true, "white")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if (string.find(msg, L["deaden_trigger"])) then
		self:Sync(syncName.deaden)
	elseif (string.find(msg, L["deaden_over_trigger"])) then
		self:Sync(syncName.deadenOver)
	elseif (string.find(msg, L["blink_trigger"])) then
		self:Sync(syncName.blink)
	elseif (string.find(msg, L["cs_trigger2"]) or string.find(msg, L["cs_trigger"])) then
		self:Sync(syncName.cs)
	elseif (string.find(msg, L["curse_trigger"]) or string.find(msg, L["curse_trigger2"])) then
		self:Sync(syncName.curse)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.blink then
		self:Blink()
	elseif sync == syncName.deaden  then
		self:DeadenMagic()
	elseif sync == syncName.deadenOver then
		self:DeadenMagicOver()
	elseif sync == syncName.curse then
		self:Curse()
	elseif sync == syncName.cs then
		self:Counterspell()
	end
end

function module:Counterspell()
	if self.db.profile.counterspell then
		self:Bar(L["cs_bar"], timer.cs, icon.cs, true, "red")
		self:Message("Go!")
		if self.db.profile.sound then
			self:Sound("gogogo")
			self:DelayedSound(timer.cs - 2, "stopcasting")
		end
	end
end

function module:Curse()
	if self.db.profile.curse then
		self:Message(L["curse_warn"], "Attention", "Alarm")
		self:Bar(L["curse_bar"], timer.curse, icon.curse, true, "blue")
	end
end

function module:Blink()
	firstblink = false
	self:DelayedSync(timer.blink, syncName.blink)
	if self.db.profile.blink then
		self:Message(L["blink_warn"], "Important")
		self:Bar(L["blink_bar"], timer.blink, icon.blink, true, "black")
		self:DelayedMessage(timer.blink - 5, L["blink_soon_warn"], "Attention", "Alarm", nil, nil, true)
	end
end

function module:DeadenMagic()
	if self.db.profile.deaden then
		self:RemoveBar(L["deaden_bar"])
		self:Message(L["deaden_warn"], "Important")
		self:Bar(L["deaden_bar"], timer.deaden, icon.deaden, true, "white")
		if playerClass == "SHAMAN" or playerClass == "PRIEST" then
			if self.db.profile.bigicon then
				self:WarningSign(icon.deaden, timer.deaden)
			end
		end
	end
end

function module:DeadenMagicOver()
	if self.db.profile.deaden then
		if playerClass == "SHAMAN" or playerClass == "PRIEST" then
			self:RemoveWarningSign(icon.deaden)
		end
	end
end

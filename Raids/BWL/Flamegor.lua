
local module, L = BigWigs:ModuleDeclaration("Flamegor", "Blackwing Lair")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"taunt", "wingbuffet", "shadowflame", "frenzy", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Flamegor",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn when Flamegor casts Wing Buffet.",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn when Flamegor casts Shadow Flame.",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when Flamegor is frenzied.",
	
	taunt_cmd = "taunt",
	taunt_name = "Taunt big icon alert",
	taunt_desc = "Warn when you should Taunt.",

	wingbuffet_trigger = "Flamegor begins to cast Wing Buffet.",
	wingbuffet_message = "Wing Buffet! Next one in 30 seconds!",
	wingbuffet_warning = "TAUNT now! Wing Buffet soon!",
	wingbuffetcast_bar = "Wing Buffet",
	wingbuffet_bar = "Next Wing Buffet",
	wingbuffet1_bar = "Initial Wing Buffet",
	
	shadowflame_trigger = "Flamegor begins to cast Shadow Flame.",
	shadowflame_warning = "Shadow Flame incoming!",
	shadowflame_bar = "Shadow Flame",
	shadowflame_Nextbar = "Next Shadow Flame",
	
	frenzygain_trigger = "Flamegor gains Frenzy.",
	frenzygain_trigger2 = "Flamegor goes into a frenzy!",
	frenzyend_trigger = "Frenzy fades from Flamegor.",
	frenzy_message = "Frenzy! Tranq now!",
	frenzy_bar = "Frenzy",
	frenzy_Nextbar = "Frenzy CD",

	taunt_trigger = "Flamegor is afflicted by Taunt",
} end)

local timer = {
	firstWingbuffet = 30,
	wingbuffet = 30,
	wingbuffetCast = 1,
	earliestShadowflame = 10.5,
	latestShadowflame = 14.5,
	shadowflameCast = 2,
	firstFrenzy = 9,
	frenzy = 10,
}

local icon = {
	wingbuffet = "INV_Misc_MonsterScales_14",
	shadowflame = "Spell_Fire_Incinerate",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
	taunt = "spell_nature_reincarnation",
}

local syncName = {
	wingbuffet = "FlamegorWingBuffet"..module.revision,
	shadowflame = "FlamegorShadowflame"..module.revision,
	frenzy = "FlamegorFrenzyStart"..module.revision,
	frenzyOver = "FlamegorFrenzyEnd"..module.revision,
}

local lastFrenzy = 0
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.wingbuffet)
	self:ThrottleSync(10, syncName.shadowflame)
	self:ThrottleSync(5, syncName.frenzy)
end

function module:OnSetup()
	lastFrenzy = 0
end

function module:OnEngage()
	if self.db.profile.wingbuffet then
		self:DelayedMessage(timer.firstWingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
		self:Bar(L["wingbuffet1_bar"], timer.firstWingbuffet, icon.wingbuffet, true, "blue")
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			self:DelayedWarningSign(timer.firstWingbuffet - 5, icon.taunt, 10)
		end
	end
	if self.db.profile.shadowflame then
		self:IntervalBar(L["shadowflame_Nextbar"], timer.earliestShadowflame, timer.latestShadowflame, icon.shadowflame, true, "red")
	end
	if self.db.profile.frenzy then
		self:Bar(L["frenzy_Nextbar"], timer.firstFrenzy, icon.frenzy, true, "white")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["frenzygain_trigger"] or msg == L["frenzygain_trigger2"] then
		self:Sync(syncName.frenzy)
	end
	if msg == L["frenzyend_trigger"] then
		self:Sync(syncName.frenzyOver)
	end
	if string.find(msg, L["taunt_trigger"]) then
		self:RemoveWarningSign(icon.taunt)
	end
	if msg == L["wingbuffet_trigger"] then
		self:Sync(syncName.wingbuffet)
	end
	if msg == L["shadowflame_trigger"] then
		self:Sync(syncName.shadowflame)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.wingbuffet and self.db.profile.wingbuffet then
		self:WingBuffet()
	elseif sync == syncName.shadowflame and self.db.profile.shadowflame then
		self:ShadowFlame()
	elseif sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:FrenzyOver()
	end
end

function module:WingBuffet()
	self:RemoveBar(L["wingbuffet_bar"])
	self:DelayedMessage(timer.wingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
	self:DelayedBar(timer.wingbuffetCast, L["wingbuffet_bar"], timer.wingbuffet, icon.wingbuffet, true, "blue")
	self:Message(L["wingbuffet_message"], "Important")
	self:Bar(L["wingbuffetcast_bar"], timer.wingbuffetCast, icon.wingbuffet, true, "blue")
	if playerClass == "WARRIOR" and self.db.profile.taunt then
		self:DelayedWarningSign(timer.wingbuffet - 5, icon.taunt, 10)
	end
end

function module:ShadowFlame()
	self:RemoveBar(L["shadowflame_Nextbar"])
	self:DelayedIntervalBar(timer.shadowflameCast, L["shadowflame_Nextbar"], timer.earliestShadowflame-timer.shadowflameCast, timer.latestShadowflame-timer.shadowflameCast, icon.shadowflame, true, "red")
	self:Message(L["shadowflame_warning"], "Important", true, "Alarm")
	self:Bar(L["shadowflame_bar"], timer.shadowflameCast, icon.shadowflame, true, "red")
end

function module:Frenzy()
	self:Message(L["frenzy_message"], "Important", nil, true, "Alert")
	self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "black")
	lastFrenzy = GetTime()
	if playerClass == "HUNTER" then
		self:WarningSign(icon.tranquil, timer.frenzy, true)
	end
end

function module:FrenzyOver()
	self:RemoveBar(L["frenzy_bar"])
	self:RemoveWarningSign(icon.tranquil, true)
	if lastFrenzy ~= 0 then
		local NextTime = (lastFrenzy + timer.frenzy) - GetTime()
		self:Bar(L["frenzy_Nextbar"], NextTime, icon.frenzy, true, "White")
	end
end

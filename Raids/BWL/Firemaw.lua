
local module, L = BigWigs:ModuleDeclaration("Firemaw", "Blackwing Lair")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"taunt", "bigicon", "sounds", "wingbuffet", "shadowflame", "flamebuffet", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Firemaw",

	flamebuffet_cmd = "flamebuffet",
	flamebuffet_name = "Flame Buffet alert",
	flamebuffet_desc = "Warn when Flamegor casts Flame Buffet.",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn when Flamegor casts Wing Buffet.",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn when Flamegor casts Shadow Flame.",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Taunt big icon alert",
	bigicon_desc = "Shows a big icon when you have too many stacks",
	
	sounds_cmd = "sounds",
	sounds_name = "Stacks sound alert",
	sounds_desc = "Sound effect when you have too many stacks",
	
	taunt_cmd = "Taunt",
	taunt_name = "Taunt big icon alert",
	taunt_desc = "Taunt big icon when you should taunt",
	
	shadowflame_trigger = "Firemaw begins to cast Shadow Flame.",
	shadowflame_warning = "Shadow Flame incoming!",
	shadowflame_bar = "Shadow Flame",
	shadowflame_Nextbar = "Shadow Flame CD",
	
	flamebuffetafflicted_trigger = "afflicted by Flame Buffet",
	flamebuffetresisted_trigger = "Firemaw 's Flame Buffet was resisted",
	flamebuffetimmune_trigger = "Firemaw 's Flame Buffet fail(.+) immune\.",
	flamebuffetabsorb1_trigger = "You absorb Firemaw 's Flame Buffet",
	flamebuffetabsorb2_trigger = "Firemaw 's Flame Buffet is absorbed",
	flamebuffet_bar = "Flame Buffet CD",
	
	stacks_trigger = "You are afflicted by Flame Buffet %(5%)",
	stacksend_trigger = "Flame Buffet fades from you",
	taunt_trigger = "Firemaw is afflicted by Taunt",
	
	wingbuffet_trigger = "Firemaw begins to cast Wing Buffet.",
	wingbuffet_message = "Wing Buffet! Next one in 30 seconds!",
	wingbuffet_warning = "TAUNT now! Wing Buffet soon!",
	wingbuffetcast_bar = "Wing Buffet",
	wingbuffet_bar = "Next Wing Buffet",
	wingbuffet1_bar = "Initial Wing Buffet",	
} end)

local timer = {
	firstWingbuffet = 30,
	wingbuffet = 30,
	wingbuffetCast = 1,
	earliestShadowflame = 10.5,
	latestShadowflame = 14.5,
	shadowflameCast = 2,
	firstFlameBuffet = 4.5,
	flameBuffet = 2,
	stacks = 3,
}

local icon = {
	wingbuffet = "INV_Misc_MonsterScales_14",
	shadowflame = "Spell_Fire_Incinerate",
	flameBuffet = "Spell_Fire_Fireball",
	taunt = "spell_nature_reincarnation",
}

local syncName = {
	wingbuffet = "FiremawWingBuffet"..module.revision,
	shadowflame = "FiremawShadowflame"..module.revision,
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.wingbuffet)
	self:ThrottleSync(10, syncName.shadowflame)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.wingbuffet then
		self:DelayedMessage(timer.firstWingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
		self:Bar(L["wingbuffet1_bar"], timer.firstWingbuffet, icon.wingbuffet, true, "blue")
		if playerClass == "WARRIOR" then
			self:DelayedWarningSign(timer.firstWingbuffet - 5, icon.taunt, 10)
		end
	end
	if self.db.profile.shadowflame then
		self:IntervalBar(L["shadowflame_Nextbar"], timer.earliestShadowflame, timer.latestShadowflame, icon.shadowflame, true, "red")
	end
	if self.db.profile.flamebuffet then
		self:Bar(L["flamebuffet_bar"], timer.firstFlameBuffet, icon.flameBuffet, true, "White")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:Sync(syncName.wingbuffet)
	end
	if string.find(msg, L["shadowflame_trigger"]) then
		self:Sync(syncName.shadowflame)
	end
	if (string.find(msg, L["flamebuffetafflicted_trigger"]) or string.find(msg, L["flamebuffetresisted_trigger"]) or string.find(msg, L["flamebuffetimmune_trigger"]) or string.find(msg, L["flamebuffetabsorb1_trigger"]) or string.find(msg, L["flamebuffetabsorb2_trigger"])) and self.db.profile.flamebuffet then
		self:Bar(L["flamebuffet_bar"], timer.flameBuffet, icon.flameBuffet, true, "White")
	end
	if string.find(msg, L["stacks_trigger"]) then
		if self.db.profile.sounds then
			self:Sound("stacks")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.flameBuffet, timer.stacks)
		end
	end
	if string.find(msg, L["stacksend_trigger"]) then
		self:RemoveWarningSign(icon.flameBuffet)
	end
	if string.find(msg, L["taunt_trigger"]) then
		self:RemoveWarningSign(icon.taunt)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.wingbuffet and self.db.profile.wingbuffet then
		self:Message(L["wingbuffet_message"], "Important")
		self:RemoveWarningSign(icon.taunt)
		self:RemoveBar(L["wingbuffet_bar"])
		self:Bar(L["wingbuffetcast_bar"], timer.wingbuffetCast, icon.wingbuffet, true, "blue")
		self:DelayedBar(timer.wingbuffetCast, L["wingbuffet_bar"], timer.wingbuffet, icon.wingbuffet, true, "blue")
		self:DelayedMessage(timer.wingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			self:DelayedWarningSign(timer.wingbuffet - 5, icon.taunt, 10)
		end
	elseif sync == syncName.shadowflame and self.db.profile.shadowflame then
		self:ShadowFlame()
	end
end

function module:ShadowFlame()
	self:RemoveBar(L["shadowflame_Nextbar"])
	self:DelayedIntervalBar(timer.shadowflameCast, L["shadowflame_Nextbar"], timer.earliestShadowflame-timer.shadowflameCast, timer.latestShadowflame-timer.shadowflameCast, icon.shadowflame, true, "red")
	self:Message(L["shadowflame_warning"], "Important", true, "Alarm")
	self:Bar(L["shadowflame_bar"], timer.shadowflameCast, icon.shadowflame, true, "red")
end

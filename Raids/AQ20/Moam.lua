
local module, L = BigWigs:ModuleDeclaration("Moam", "Ruins of Ahn'Qiraj")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "paralyze", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Moam",

	adds_cmd = "adds",
	adds_name = "Mana Fiend Alert",
	adds_desc = "Warn for Mana fiends",

	paralyze_cmd = "paralyze",
	paralyze_name = "Paralyze Alert",
	paralyze_desc = "Warn for Paralyze",

	starttrigger = "%s senses your fear.",
	startwarn = "Moam Engaged! 90 Seconds until adds!",

	addstrigger = "drains your mana and turns to stone.",
	addswarn = "Mana Fiends spawned! Moam Paralyzed for 90 seconds!",
	addsincoming = "Mana Fiends incoming in %s seconds!",
	addsbar = "Adds",

	paralyzebar = "Paralyze",

	returntrigger = "Energize fades from Moam.",
	returntrigger2 = "bristles with energy",
	returnwarn = "Moam unparalyzed! 90 seconds until Mana Fiends!",
	returnincoming = "Moam unparalyzed in %s seconds!",

	gainmana_bar = "Moam +6k/23% Mana",
} end )

local timer = {
	paralyze = 90,
	unparalyze = 90,
	gainmana = 6,
}

local icon = {
	paralyze = "Spell_Shadow_CurseOfTounges",
	unparalyze = "Spell_Shadow_CurseOfTounges",
	gainmana = "spell_shadow_siphonmana",
}

local syncName = {
	paralyze = "MoamParalyze"..module.revision,
	unparalyze = "MoamUnparalyze"..module.revision,
	gainmana = "MoamGainMana"..module.revision,
}

local firstunparalyze = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

	self:ThrottleSync(10, syncName.paralyze)
	self:ThrottleSync(10, syncName.unparalyze)
end

function module:OnSetup()
	firstunparalyze = true
end

function module:OnEngage()
	if self.db.profile.adds then
		self:Message(L["startwarn"], "Important")
	end
	self:Unparalyze()
	self:Bar(L["gainmana_bar"], timer.gainmana, icon.gainmana)
	self:DelayedSync(timer.gainmana, syncName.gainmana)
end

function module:OnDisengage()
end

function module:Emote(msg)
	self:DebugMessage("moam raid boss emote: " .. msg)
	if string.find(msg, L["addstrigger"]) then
		self:Sync(syncName.paralyze)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find( msg, L["returntrigger"]) then
		self:Sync(syncName.unparalyze)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.paralyze then
		self:Paralyze()
	elseif sync == syncName.unparalyze then
		self:Unparalyze()
	elseif sync == syncName.gainmana then
		self:gainmana()
	end
end

function module:gainmana()
	self:Bar(L["gainmana_bar"], timer.gainmana, icon.gainmana)
	self:DelayedSync(timer.gainmana, syncName.gainmana)
end

function module:Paralyze()
	self:RemoveBar(L["paralyzebar"])
	self:RemoveBar(L["addsbar"])
	self:RemoveBar(L["gainmana_bar"])
	self:CancelDelayedSync(syncName.gainmana)
	self:DelayedSync(60, syncName.gainmana)
	if self.db.profile.adds then
		self:Message(L["addswarn"], "Important")
	end
	if self.db.profile.paralyze then
		self:DelayedMessage(timer.paralyze - 60, format(L["returnincoming"], 60), "Attention", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 30, format(L["returnincoming"], 30), "Attention", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 15, format(L["returnincoming"], 15), "Urgent", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 5, format(L["returnincoming"], 5), "Important", nil, nil, true)
		self:Bar(L["paralyzebar"], timer.paralyze, icon.paralyze)
	end
end

function module:Unparalyze()
	self:RemoveBar(L["paralyzebar"])
	self:RemoveBar(L["addsbar"])
	self:Bar(L["gainmana_bar"], timer.gainmana, icon.gainmana)
	self:CancelDelayedSync(syncName.gainmana)
	self:DelayedSync(timer.gainmana, syncName.gainmana)
	if firstunparalyze then
		firstunparalyze = false
	elseif self.db.profile.paralyze then
		self:Message(L["returnwarn"], "Important")
	end
	if self.db.profile.adds then
		self:DelayedMessage(timer.unparalyze - 60, format(L["addsincoming"], 60), "Attention", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 30, format(L["addsincoming"], 30), "Attention", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 15, format(L["addsincoming"], 15), "Urgent", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 5, format(L["addsincoming"], 5), "Important", nil, nil, true)
		self:Bar(L["addsbar"], timer.unparalyze, icon.unparalyze)
	end
end

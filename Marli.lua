
local module, L = BigWigs:ModuleDeclaration("High Priestess Mar'li", "Zul'Gurub")

module.revision = 20041
module.enabletrigger = module.translatedName
module.wipemobs = {"Spawn of Mar'li"}
module.toggleoptions = {"bigicon", "phase", "spiders", "drain", "volley", "charge", -1, "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Marli",

	spiders_cmd = "spiders",
	spiders_name = "Spider adds Alert",
	spiders_desc = "Warn when spiders spawn",

	volley_cmd = "volley",
	volley_name = "Poison Bolt Volley Alert",
	volley_desc = "Warn for Poison Bolt Volleys",

	drain_cmd = "drain",
	drain_name = "Drain Life Alert",
	drain_desc = "Warn for life drain",

	phase_cmd = "phase",
	phase_name = "Phase Notification",
	phase_desc = "Announces the boss' phase transition",
	
	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn for Charge",

	bigicon_cmd = "bigicon",
	bigicon_name = "Big icons alerts",
	bigicon_desc = "Shows a big icon for adds, charge and drain life",
	
	drainlife_trigger = "afflicted by Drain Life",
	drainlife_warn = "Drain Life! Interrupt!",

	volley_trigger = "Poison Bolt Volley hits you",
	volley_warn = "Poison hit you, MAX RANGE!!!",

	trollphase_trigger = "The brood shall not fall",	
	trollphase_warn = "Troll phase",
	trollphase_bar = "Next Troll Phase",

	spiderphase_trigger1 = "Draw me to your web mistress Shadra",
	spiderphase_trigger2 = "Shadra, make of me your avatar",	
	spiderphase_warn = "Spider phase",
	spiderphase_bar = "Next Spider Phase",
	
	charge_trigger = "High Priestess Mar'li's Charge",
	charge_warn = "Charge! Stop damage.",
	charge_bar = "Charge CD",

	spiders_trigger = "Aid me my brood!",	
	spiders_warn = "Kill the ADDS!",	
} end )

local timer = {
	chargeInterval = 15,
	nextTrollPhase = 45,
	nextSpiderPhase = 40,
}

local icon = {
	trollPhase = "Spell_Nature_Web",
	spiderPhase = "Inv_misc_head_troll_02",
	charge = "Ability_Warrior_Charge",
	drainlife = "spell_shadow_lifedrain02",
}

local syncName = {
	drain = "MarliDrainStart"..module.revision,
	trollPhase = "MarliTrollPhase"..module.revision,
	spiderPhase = "MarliSpiderPhase"..module.revision,
	spiders = "MarliSpiders"..module.revision,
	charge = "MarliCharge"..module.revision,
}

local chargecount = 0
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	self:ThrottleSync(5, syncName.drain)
	self:ThrottleSync(5, syncName.trollPhase)
	self:ThrottleSync(5, syncName.spiderPhase)
	self:ThrottleSync(5, syncName.spiders)
	self:ThrottleSync(5, syncName.charge)
end

function module:OnSetup()
	chargecount = 0
end

function module:OnEngage()
	first = true
	self:Sync(syncName.trollPhase)
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["spiders_trigger"]) then
		self:Sync(syncName.spiders)
	elseif string.find(msg, L["trollphase_trigger"]) then
		self:Sync(syncName.trollPhase)
	elseif string.find(msg, L["spiderphase_trigger1"]) or string.find(msg, L["spiderphase_trigger2"]) then
		self:Sync(syncName.spiderPhase)
	end
end

function module:Event(msg)
	if string.find(msg, L["volley_trigger"]) then
		self:Volley()
	end
	if string.find(msg, L["drainlife_trigger"]) then
		self:Sync(syncName.drain)
	end
	if string.find(msg, L["charge_trigger"]) then
		self:Sync(syncName.charge)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.spiders and self.db.profile.spiders then
		self:Spiders()
	elseif sync == syncName.trollPhase and self.db.profile.phase then
		self:TrollPhase()
	elseif sync == syncName.spiderPhase and self.db.profile.phase then
		self:SpiderPhase()
	elseif sync == syncName.drain and self.db.profile.drain then
		self:DrainLife()
	elseif sync == syncName.charge and self.db.profile.charge then
		self:Charge()
	end
end

function module:Spiders()
	self:Message(L["spiders_warn"], "Attention")
	self:Sound("Info")
end

function module:TrollPhase()
	chargecount = 0
	self:Bar(L["spiderphase_bar"], timer.nextSpiderPhase, icon.spiderPhase, true, "white")
	if first == false then
		self:Message(L["trollphase_warn"], "Attention")
	end
	first = false
end

function module:SpiderPhase()
	self:Bar(L["trollphase_bar"], timer.nextTrollPhase, icon.trollPhase, true, "white")
	self:Message(L["spiderphase_warn"], "Attention")
end

function module:Volley()
	if playerClass == "MAGE" or playerClass == "DRUID" or playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "WARLOCK" or playerClass == "HUNTER" then
		self:Message(L["volley_warn"], "Personal")
	end
end

function module:DrainLife()
	self:Message(L["drainlife_warn"], "Attention")
	if self.db.profile.bigicon then
		self:WarningSign(icon.drainlife, 0.7)
	end
end

function module:Charge()
	self:Sound("Info")
	self:Message(L["charge_warn"], "Attention")
	chargecount = chargecount + 1
	if chargecount < 3 then
		self:Bar(L["charge_bar"], timer.chargeInterval, icon.charge, true, "red")
	end
end

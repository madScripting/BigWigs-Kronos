
local module, L = BigWigs:ModuleDeclaration("Patchwerk", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"frenzy", "hateful", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Patchwerk",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for low health Frenzy",
	
	hateful_cmd = "hateful",
	hateful_name = "Hateful Strike Bar",
	hateful_desc = "Show a timer for Hateful Strike",

	hatefultrigger = "Hateful Strike",
	hatefulbar = "Hateful Strike",
	
	enragetrigger = "%s goes into a berserker rage!",
	enragewarn = "Enrage!",
	enragebartext = "Enrage",
	warn60 = "Enrage in 60 seconds",
	warn30 = "Enrage in 30 seconds",
	warn10 = "Enrage in 10 seconds",
	
	starttrigger1 = "Patchwerk want to play!",
	starttrigger2 = "Kel'Thuzad make Patchwerk his Avatar of War!",
} end )

local timer = {
	hateful = 1, --1.2,
	enrage = 420,
}

local icon = {
	hateful = "inv_sword_04",
	enrage = "Spell_Shadow_UnholyFrenzy",
	shieldwall = "ability_warrior_shieldwall",
}

local syncName = {
	enrage = "PatchwerkEnrage"..module.revision,
	frenzy = "PatchwerkFrenzy"..module.revision,
}

local berserkannounced = nil
local enrageannounced = false
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "HatefulStrike")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "HatefulStrike")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "HatefulStrike")
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.frenzy)
end

function module:OnSetup()
	self.started = false
	berserkannounced = false
	enrageannounced = false
end

function module:OnEngage()
	self:RemoveBar("Sewage Slimes")
	self:CancelDelayedMessage("Sewage Slimes in 10 seconds")
	if self.db.profile.enrage then
		self:Bar(L["enragebartext"], timer.enrage, icon.enrage)
		self:DelayedMessage(timer.enrage - 60, L["warn60"], "Urgent")
		self:DelayedMessage(timer.enrage - 30, L["warn30"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["warn10"], "Important")
	end
end

function module:OnDisengage()
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) < 7 and not frenzy then
			self:Sync(syncName.frenzy)
			frenzy = true
		elseif math.ceil(health) > 8 and frenzy then
			frenzy = nil
		end
	end
end

function module:HatefulStrike(msg)
	if string.find(msg, L["hatefultrigger"]) then
		self:Bar(L["hatefulbar"], timer.hateful, icon.hateful, true, "Red")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	end
end

function module:Frenzy()
	if playerClass == "WARRIOR" then
		self:WarningSign(icon.shieldwall, 1)
	end
end

function module:Enrage()
	self:Message(L["enragewarn"], "Important", nil, "Beware")
	self:RemoveBar(L["enragebartext"])
	self:CancelDelayedMessage(L["warn60"])
	self:CancelDelayedMessage(L["warn30"])
	self:CancelDelayedMessage(L["warn10"])
end

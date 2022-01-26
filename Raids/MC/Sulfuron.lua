
local module, L = BigWigs:ModuleDeclaration("Sulfuron Harbinger", "Molten Core")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"heal", "adds", "knockback", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sulfuron",

	knockback_cmd = "knockback",
	knockback_name = "Hand of Ragnaros announce",
	knockback_desc = "Show timer for knockbacks",

	heal_cmd = "heal",
	heal_name = "Adds' heals",
	heal_desc = "Announces Flamewaker Priests' heals",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Flamewaker Priests",
	
	flamewakerpriest_name = "Flamewaker Priest",
	triggeradddead = "Flamewaker Priest dies",
	addmsg = "%d/4 Flamewaker Priests dead!",
	
	triggercast = "begins to cast Dark Mending",
	healwarn = "Healing!",
	healbar = "Dark Mending",
	
	spear_cast = "begins to perform Flame Spear",
	flame_spear_bar = "Flame Spear",

	knockback1 = "Hand of Ragnaros hits",
	knockback11 = "Hand of Ragnaros hits",
	knockback2 = "Hand of Ragnaros was resisted",
	knockback3 = "absorb (.+) Hand of Ragnaros",
	knockback33 = "Hand of Ragnaros is absorbed",
	knockback4 = "Hand of Ragnaros (.+) immune",	
	knockbacktimer = "~AoE knockback",
	knockbackannounce = "3 seconds until knockback!",
} end)

local timer = {
	knockback = 14,
	firstKnockback = 6,
	heal = 2,
	flame_spear = 12,
}

local icon = {
	knockback = "Spell_Fire_Fireball",
	heal = "Spell_Shadow_ChillTouch",
	flame_spear = "Spell_Fire_FlameBlades",
}

local syncName = {
	knockback = "SulfuronKnockback"..module.revision,
	heal = "SulfuronAddHeal"..module.revision,
	flame_spear = "SulfuronSpear"..module.revision,
	add_dead = "SulfuronAddDead",
}

local deadpriests = 0
module.wipemobs = { L["flamewakerpriest_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Events")
	--self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Events")

	self:ThrottleSync(1, syncName.heal)
	self:ThrottleSync(5, syncName.knockback)
	self:ThrottleSync(5, syncName.flame_spear)
end

function module:OnSetup()
	self.started = nil
	deadpriests = 0
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Events")
end

function module:OnEngage()
	if self.db.profile.knockback then
		self:Bar(L["knockbacktimer"], timer.firstKnockback, icon.knockback)
		self:DelayedMessage(timer.firstKnockback - 3, L["knockbackannounce"], "Urgent")
	end
	if UnitName("target") == "Sulfuron" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Sulfuron")
	end
end

function module:OnDisengage()
end

function module:Events(msg)
	if (string.find(msg, L["knockback1"]) or string.find(msg, L["knockback11"]) or string.find(msg, L["knockback2"]) or string.find(msg, L["knockback3"]) or string.find(msg, L["knockback33"]) or string.find(msg, L["knockback4"])) then
		self:Sync(syncName.knockback)
	elseif string.find(msg,"spear_cast") then
		self:Sync(syncName.flame_spear)
	end
	BigWigs:CheckForBossDeath(msg, self)
	if string.find(msg, L["triggeradddead"]) then
		self:Sync(syncName.add_dead .. " " .. tostring(deadpriests + 1))
	end
	if string.find(msg, L["triggercast"]) then
		self:Sync(syncName.heal)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.add_dead and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 4 and deadpriests < rest then
			deadpriests = rest
			if self.db.profile.adds then
				self:Message(string.format(L["addmsg"], deadpriests), "Positive")
			end
		end
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	elseif sync == syncName.knockback and self.db.profile.knockback then
		self:Knockback()
	elseif sync == syncName.flame_spear then
		self:Flame()
	end
end

function module:Knockback()
	self:Bar(L["knockbacktimer"], timer.knockback, icon.knockback)
	self:DelayedMessage(timer.knockback - 3, L["knockbackannounce"], "Urgent")
end

function module:Flame()
	self:Bar(L["flame_spear_bar"], timer.flame_spear, icon.flame_spear)
end

function module:Heal()
	self:Message(L["healwarn"], "Attention", true, "Alarm")
	self:Bar(L["healbar"], timer.heal, icon.heal)
end

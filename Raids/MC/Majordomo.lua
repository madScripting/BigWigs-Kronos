local module, L = BigWigs:ModuleDeclaration("Majordomo Executus", "Molten Core")

module.revision = 20052
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sounds", "magic", "dmg", "adds", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Majordomo",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Healers and Elites",

	magic_cmd = "magic",
	magic_name = "Magic Reflection",
	magic_desc = "Warn for Magic Reflection",

	dmg_cmd = "dmg",
	dmg_name = "Damage Shield",
	dmg_desc = "Warn for Damage Shield",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Magic Shield big icon alert",
	bigicon_desc = "Shows a big icon when magic shield is up",
	
	sounds_cmd = "sounds",
	sounds_name = "Magic and Damage Shield sound alert",
	sounds_desc = "Sound effect when magic and damage shields are up",

	disabletrigger = "Impossible! Stay your attack",
	engage_trigger = "Reckless mortals, none may challenge the sons of the living flame!",

	elitename = "Flamewaker Elite",
	healername = "Flamewaker Healer",
	healdead = "Flamewaker Healer dies",
	healdead2 = "You have slain Flamewaker Healer!",
	elitedead = "Flamewaker Elite dies",
	elitedead2 = "You have slain Flamewake Elite!",
	hdeadmsg = "%d/4 Flamewaker Healers dead!",
	edeadmsg = "%d/4 Flamewaker Elites dead!",

	magic_trigger = "gains Magic Reflection",
	magic_over_trigger = "Magic Reflection fades",
	dmg_trigger = "gains Damage Shield",
	damage_over_trigger = "Damage Shield fades",
	magic_warn = "Magic Reflection for 10 seconds!",
	dmg_warn = "Damage Shield for 10 seconds!",
	magic_over_warn = "Magic Reflection down!",
	dmg_over_warn = "Damage Shield down!",
	shield_warn_soon = "3 seconds until new auras!",
	magic_bar = "Magic Reflection",
	dmg_bar = "Damage Shield",
	shield_bar = "New shields",
} end)

local timer = {
	shieldDuration = 10,
	shieldInterval = 30,
	firstShield = 10,
}

local icon = {
	shield = "Spell_Shadow_DetectLesserInvisibility",
	magic = "Spell_Frost_FrostShock",
	dmg = "Spell_Shadow_AntiShadow",
}

local syncName = {
	dmg = "DomoAuraDamage"..module.revision,
	magic = "DomoAuraMagic"..module.revision,
	healerDead = "DomoHealerDead",
	eliteDead = "DomoEliteDead",
}

local _, playerClass = UnitClass("player")

module.wipemobs = { L["elitename"], L["healername"] }
module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")
	
	self:ThrottleSync(2, syncName.dmg)
	self:ThrottleSync(2, syncName.magic)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")

	self.started = nil
	self.hdead = 0
	self.edead = 0
end

function module:OnEngage()
	if self.db.profile.magic or self.db.profile.dmg then
		self:Bar(L["shield_bar"], timer.firstShield, icon.shield)
		self:DelayedMessage(timer.firstShield - 5, L["shield_warn_soon"], "Urgent", nil, nil, true)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["disabletrigger"]) then
		self:SendBossDeathSync()
	end
	if string.find(msg, L["magic_trigger"]) then
		self:Sync(syncName.magic)
	elseif string.find(msg, L["dmg_trigger"]) then
		self:Sync(syncName.dmg)
	end
	if string.find(msg, L["healdead"]) or string.find(msg, L["healdead2"]) then
		self:Sync(syncName.healerDead .. " " .. tostring(self.hdead + 1))
	elseif string.find(msg, L["elitedead"]) or string.find(msg, L["elitedead2"]) then
		self:Sync(syncName.eliteDead .. " " .. tostring(self.edead + 1))
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == "DomoHealerDead" and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 4 and self.hdead < rest then
			self.hdead = rest
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["hdeadmsg"], self.hdead), "Positive")
			end
		end
	elseif sync == "DomoEliteDead" and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 4 and self.edead < rest then
			self.edead = rest
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["edeadmsg"], self.edead), "Positive")
			end
		end
	elseif sync == syncName.magic then
		self:MagicShield()
	elseif sync == syncName.dmg then
		self:DamageShield()
	end
end

function module:MagicShield()
	if self.db.profile.magic then
		self:RemoveBar(L["shield_bar"])
		self:Message(L["magic_warn"])
		if playerClass == "MAGE" or playerClass == "WARLOCK" then
			if self.db.profile.bigicon then
				self:WarningSign(icon.magic, timer.shieldDuration)
			end
			if self.db.profile.sound then
				self:Sound("stopcasting")
				self:DelayedSound(timer.shieldDuration - 1, "gogogo")
			end
		end 
		self:Bar(L["magic_bar"], timer.shieldDuration, icon.magic)
	end
	if self.db.profile.magic or self.db.profile.dmg then
		self:DelayedBar(timer.shieldDuration, L["shield_bar"], timer.shieldInterval - timer.shieldDuration, icon.shield)
		self:DelayedMessage(timer.shieldInterval - 5, L["shield_warn_soon"], "Urgent", nil, nil, true)
	end
end

function module:DamageShield()
	if self.db.profile.dmg then
		self:RemoveBar(L["shield_bar"])
		self:Message(L["dmg_warn"], "Attention")
		if playerClass == "WARRIOR" or playerClass == "ROGUE" then
			if self.db.profile.bigicon then
				self:WarningSign(icon.dmg, timer.shieldDuration)
			end
			if self.db.profile.sound then
				self:Sound("meleeout")
				self:DelayedSound(timer.shieldDuration - 1, "gogogo")
			end
		end
		self:Bar(L["dmg_bar"], timer.shieldDuration, icon.dmg)
	end
	if self.db.profile.magic or self.db.profile.dmg then
		self:DelayedBar(timer.shieldDuration, L["shield_bar"], timer.shieldInterval - timer.shieldDuration, icon.shield)
		self:DelayedMessage(timer.shieldInterval - 5, L["shield_warn_soon"], "Urgent", nil, nil, true)
	end
end

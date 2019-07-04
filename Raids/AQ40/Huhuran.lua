
local module, L = BigWigs:ModuleDeclaration("Princess Huhuran", "Ahn'Qiraj")

module.revision = 20047
module.enabletrigger = module.translatedName
module.toggleoptions = {"wyvern", "frenzy", "berserk", "noxious", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Huhuran",

	wyvern_cmd = "wyvern",
	wyvern_name = "Wyvern Sting Alert",
	wyvern_desc = "Warn for Wyvern Sting",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",

	berserk_cmd = "berserk",
	berserk_name = "Berserk Alert",
	berserk_desc = "Warn for Berserk",
	
	noxious_cmd = "noxious",
	noxious_name = "Noxious Poison Alert",
	noxious_desc = "Warn for Noxious Poison",

	frenzygain_trigger = "Princess Huhuran gains Frenzy.",
	frenzyend_trigger = "Frenzy fades from Princess Huhuran.",
	frenzy_bar = "Frenzy",
	frenzy_Nextbar = "Possible Frenzy",
	frenzy_message = "Frenzy - Tranq Shot!",

	berserktrigger = "goes into a berserker rage!",
	frenzytrigger = "goes into a killing frenzy!",
	berserkwarn = "Berserk! Berserk! Berserk!",
	berserksoonwarn = "Berserk Soon!",
	stingtrigger = "afflicted by Wyvern Sting",
	stingwarn = "Wyvern Sting!",
	stingdelaywarn = "Possible Wyvern Sting in ~3 seconds!",
	bartext = "Wyvern Sting",
	noxious_trigger = "is afflicted by Noxious Poison",
	noxiousself_trigger = "You are afflicted by Noxious Poison",
	noxiousafflicted_bar = "Silenced",
	noxiouscd_bar = "Noxious Poison",

	startwarn = "Huhuran engaged, 5 minutes to berserk!",
	berserkbar = "Berserk",
	berserkwarn1 = "Berserk in 1 minute!",
	berserkwarn2 = "Berserk in 30 seconds!",
	berserkwarn3 = "Berserk in 5 seconds!",
} end )

local timer = {
	berserk = 300,
	earliestFirstSting = 18,
	latestFirstSting = 28,
	earliestSting = 18,
	latestSting = 30,
	earliestFrenzyInterval = 14,
	latestFrenzyInterval = 18,
	frenzy = 8,
	earliestFirstNoxious = 10,
	latestFirstNoxious = 14,
	earliestNoxious = 11,
	latestNoxious = 15,
	noxiousDuration = 8,
}

local icon = {
	berserk = "INV_Shield_01",
	sting = "INV_Spear_02",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
	noxiousCD = "spell_nature_corrosivebreath",
	noxiousPriest = "Interface\\Icons\\inv_staff_30",
	noxiousPaladin = "Spell_Holy_GreaterBlessingofKings",
	noxiousDruid = "inv_misc_monsterclaw_04",
	noxiousShaman = "Spell_Nature_Lightning",
}
local syncName = {
	sting = "HuhuranWyvernSting"..module.revision,
	frenzy = "HuhuranFrenzyGain"..module.revision,
	frenzyOver = "HuhuranFrenzyFade"..module.revision,
	noxiousCD = "HuhuranNoxiousCD"..module.revision,
	noxiousPriest = "HuhuranNoxiousPriest"..module.revision,
	noxiousPaladin = "HuhuranNoxiousPaladin"..module.revision,
	noxiousDruid = "HuhuranNoxiousDruid"..module.revision,
	noxiousShaman = "HuhuranNoxiousShaman"..module.revision,
}

local berserkannounced = false
local lastFrenzy = 0
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "checkSting")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "checkSting")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "checkSting")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "FrenzyCheck")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FrenzyCheck")

	self:ThrottleSync(5, syncName.sting)
	self:ThrottleSync(5, syncName.noxiousCD)
	self:ThrottleSync(0, syncName.noxiousPriest)
	self:ThrottleSync(0, syncName.noxiousPaladin)
	self:ThrottleSync(0, syncName.noxiousDruid)
	self:ThrottleSync(0, syncName.noxiousShaman)
end

function module:OnSetup()
	berserkannounced = false
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.berserk then
		self:Message(L["startwarn"], "Important")
		self:Bar(L["berserkbar"], timer.berserk, icon.berserk, true, "white")
		self:DelayedMessage(timer.berserk - 60, L["berserkwarn1"], "Attention", nil, nil, true)
		self:DelayedMessage(timer.berserk - 30, L["berserkwarn2"], "Urgent", nil, nil, true)
		self:DelayedMessage(timer.berserk - 5, L["berserkwarn3"], "Important", nil, nil, true)
	end
	if self.db.profile.wyvern then
		self:IntervalBar(L["bartext"], timer.earliestFirstSting, timer.latestFirstSting, icon.sting, true, "blue")
		self:DelayedMessage(timer.earliestFirstSting - 3, L["stingdelaywarn"], "Urgent", nil, nil, true)
	end
	if self.db.profile.frenzy then
		self:IntervalBar(L["frenzy_Nextbar"], timer.earliestFrenzyInterval, timer.latestFrenzyInterval, icon.frenzy, true, "red")
	end
	if self.db.profile.noxious then
		self:IntervalBar(L["noxiouscd_bar"], timer.earliestFirstNoxious, timer.latestFirstNoxious, icon.noxiousCD, true, "green")
	end
end

function module:OnDisengage()
end

function module:FrenzyCheck(msg)
	if msg == L["frenzygain_trigger"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["frenzyend_trigger"] then
		self:Sync(syncName.frenzyOver)
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(arg1)
	if self.db.profile.berserk and arg1 == L["berserktrigger"] then
		self:CancelDelayedMessage(L["berserkwarn1"])
		self:CancelDelayedMessage(L["berserkwarn2"])
		self:CancelDelayedMessage(L["berserkwarn3"])
		self:RemoveBar(L["berserkbar"])

		self:Message(L["berserkwarn"], "Urgent", false, "Beware")
		berserkannounced = true
	end
end

function module:UNIT_HEALTH(arg1)
	if self.db.profile.berserk then
		if UnitName(arg1) == module.translatedName then
			local health = UnitHealth(arg1)
			if health > 30 and health <= 33 and not berserkannounced then
				self:Message(L["berserksoonwarn"], "Important", false, "Alarm")
				berserkannounced = true
			elseif (health > 40 and berserkannounced) then
				berserkannounced = false
			end
		end
	end
end

function module:checkSting(arg1)
	if string.find(arg1, L["stingtrigger"]) then
		self:Sync(syncName.sting)
	elseif string.find(arg1, L["noxiousself_trigger"]) then
		self:Sync(syncName.noxiousCD)
		local _, playerClass = UnitClass("player")
		if playerClass == "PRIEST" then
			self:Sync(syncName.noxiousPriest)
		elseif playerClass == "PALADIN" then
			self:Sync(syncName.noxiousPaladin)
		elseif playerClass == "DRUID" then
			self:Sync(syncName.noxiousDruid)
		elseif playerClass == "SHAMAN" then
			self:sync(syncName.noxiousShaman)
		end
	elseif string.find(arg1, L["noxious_trigger"]) then
		self:Sync(syncName.noxiousCD)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sting then
		if self.db.profile.wyvern then
			self:Message(L["stingwarn"], "Urgent")
			self:IntervalBar(L["bartext"], timer.earliestSting, timer.latestSting, icon.sting, true, "blue")
			self:DelayedMessage(timer.earliestSting - 3, L["stingdelaywarn"], "Urgent", nil, nil, true)
		end
	elseif sync == syncName.frenzy then
		self:FrenzyGain()
	elseif sync == syncName.frenzyOver then
		self:FrenzyFade()
	elseif sync == syncName.noxiousCD then
		self:NoxiousCD()
	elseif sync == syncName.noxiousPriest then
		self:NoxiousPriest(nick)
	elseif sync == syncName.noxiousPaladin then
		self:NoxiousPaladin(nick)
	elseif sync == syncName.noxiousDruid then
		self:NoxiousDruid(nick)
	elseif sync == syncName.noxiousShaman then
		self:NoxiousShaman(nick)
	end
end

function module:FrenzyGain()
	if self.db.profile.frenzy then
		self:RemoveBar(L["frenzy_Nextbar"])
		self:Message(L["frenzy_message"], "Important", nil, true, "Alert")
		self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "red")
		if playerClass == "HUNTER" then
			self:WarningSign(icon.tranquil, timer.frenzy, true)
		end
		lastFrenzy = GetTime()
	end
end

function module:FrenzyFade()
	if self.db.profile.frenzy then
		self:RemoveBar(L["frenzy_bar"])
		self:RemoveWarningSign(icon.tranquil, true)
		if lastFrenzy ~= 0 then
			local NextTime = (lastFrenzy + timer.earliestFrenzyInterval) - GetTime()
			local latestNextTime = (lastFrenzy + timer.latestFrenzyInterval) - GetTime()
			self:IntervalBar(L["frenzy_Nextbar"], NextTime, latestNextTime, icon.frenzy, true, "red")
		end
	end
end

function module:NoxiousCD()
	if self.db.profile.noxious then
		self:IntervalBar(L["noxiouscd_bar"], timer.earliestNoxious, timer.latestNoxious, icon.noxiousCD, true, "Green")
	end
end

function module:NoxiousPriest(nick)
	if self.db.profile.noxious then
		self:Bar(L["noxiousafflicted_bar"]..": "..nick, timer.noxiousDuration, icon.noxiousPriest, true, "black")
	end
end

function module:NoxiousDruid(nick)
	if self.db.profile.noxious then
		self:Bar(L["noxiousafflicted_bar"]..": "..nick, timer.noxiousDuration, icon.noxiousDruid, true, "black")
	end
end

function module:NoxiousPaladin(nick)
	if self.db.profile.noxious then
		self:Bar(L["noxiousafflicted_bar"]..": "..nick, timer.noxiousDuration, icon.noxiousPaladin, true, "black")
	end
end

function module:NoxiousShaman(nick)
	if self.db.profile.noxious then
		self:Bar(L["noxiousafflicted_bar"]..": "..nick, timer.noxiousDuration, icon.noxiousShaman, true, "black")
	end
end

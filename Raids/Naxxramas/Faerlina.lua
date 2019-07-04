
local module, L = BigWigs:ModuleDeclaration("Grand Widow Faerlina", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "sounds", "bigicon", "raidSilence", "poison", "silence", "enrage", "rain", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Faerlina",

	silence_cmd = "silence",
	silence_name = "Boss is Silenced Alert",
	silence_desc = "Warns when the boss is Silenced",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon MC and Enrage Alert",
	bigicon_desc = "BigIcon alerts when priest must MC and when the boss goes Enraged",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound MC and Enrage Alert",
	sounds_desc = "Sound alert when priest must MC and when the boss goes Enraged",

	mc_cmd = "mc",
	mc_name = "MC timer bars",
	mc_desc = "Timer bars for Worshipper MindControls",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	rain_cmd = "rain",
	rain_name = "Rain of Fire Alert",
	rain_desc = "Warn when you are standing in Rain of Fire",
	
	raidSilence_cmd = "raidSilence",
	raidSilence_name = "Raid members Silenced Alert",
	raidSilence_desc = "Warn when raid members are silenced",
	
	poison_cmd = "poison",
	poison_name = "Poison Volley Alert",
	poison_desc = "Warns shamans on Poison Volley",

	start_trigger1 = "Kneel before me, worm!",
	start_trigger2 = "Slay them in the master's name!",
	start_trigger3 = "You cannot hide from me!",
	start_trigger4 = "Run while you still can!",

	enrage_trigger = "Grand Widow Faerlina gains Enrage.",
	enrageSoon_warn = "Enrage in 10 seconds",
	enrage_warn = "Enrage!",
	enrageCD_bar = "Enrage",
	isEnraged_bar = "Boss is ENRAGED!",
	
	silence_trigger = "Grand Widow Faerlina is afflicted by Widow's Embrace.",	
	silencedEnrage_warn = "Enrage silenced! next in 61 seconds",
	silencedWithoutEnrage_warn = "Silenced before enrage! next in 30 seconds",
	silencedWayEarly_warn = "Silenced WAY early! No delay on Enrage",
	silence_bar = "Boss Silenced",
	
	raidSilence_trigger = "You are afflicted by Silence",
	raidSilence_bar = "Silenced",
	
	poison_trigger = "is afflicted by Poison Bolt Volley",
	
	rain_trigger = "You are afflicted by Rain of Fire",
	rainFade_trigger = "Rain of Fire fades from you.",
	rain_warn = "Move from FIRE!",
	
	mc_trigger = "Naxxramas Worshipper is afflicted by Mind Control",
	mcFade_trigger = "Naxxramas Worshipper begins to perform Widow's Embrace",
	mc_bar = "Worshipper MC'd",
} end )

local timer = {
	silencedEnrage = 61,
	silencedWithoutEnrage = 30,
	silence = 30,
	rainTick = 2,
	raidSilence = 8,
	mc = 60,
}

local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	silence = "Spell_Holy_Silence",
	rain = "Spell_Shadow_RainOfFire",
	poison = "spell_nature_poisoncleansingtotem",
	mc = "spell_shadow_shadowworddominate",
}

local syncName = {
	enrage = "FaerlinaEnrage"..module.revision,
	silence = "FaerlinaSilence"..module.revision,
	raidSilence = "FaerlinaRaidSilence"..module.revision,
	poison = "FaerlinaPoison"..module.revision,
	mc = "FaerlinaMc"..module.revision,
	mcEnd = "FaerlinaMcEnd"..module.revision,
}

local timeEnrageFaded = 0
local just30 = false
local isEnraged = false
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["start_trigger1"])
module:RegisterYellEngage(L["start_trigger2"])
module:RegisterYellEngage(L["start_trigger3"])
module:RegisterYellEngage(L["start_trigger4"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")

	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(2, syncName.silence)
	self:ThrottleSync(5, syncName.raidSilence)
	self:ThrottleSync(5, syncName.poison)
	self:ThrottleSync(2, syncName.mc)
	self:ThrottleSync(2, syncName.mcEnd)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	timeEnrageFaded = GetTime()
	isEnraged = false
	if UnitName("target") == "Grand Widow Faerlina" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Grand Widow Faerlina")
	end
	if UnitName("target") == "Grand Widow Faerlina" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Grand Widow Faerlina")
	end
	if self.db.profile.enrage then
		self:DelayedMessage(timer.silencedEnrage - 11, L["enrageSoon_warn"], "Urgent", nil, nil)
		self:Bar(L["enrageCD_bar"], timer.silencedEnrage - 1, icon.enrage, true, "red")
	end
	if playerClass == "PRIEST" and self.db.profile.bigicon then
			self:DelayedWarningSign(timer.silencedEnrage - 12, icon.mc, 0.7)
	end
	if playerClass == "PRIEST" and self.db.profile.sounds then
		self:DelayedSound(timer.silencedEnrage - 12, "Info")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["poison_trigger"]) then
		self:Sync(syncName.poison)
	end
	if string.find(msg, L["raidSilence_trigger"]) then
		self:Sync(syncName.raidSilence)
	end
	if string.find(msg, L["silence_trigger"]) then
		self:Sync(syncName.silence)
	end
	if string.find(msg, L["rain_trigger"]) and self.db.profile.rain then
		self:WarningSign(icon.rain, 5)
	end
	if string.find(msg, L["rainFade_trigger"]) and self.db.profile.rain then
		self:RemoveWarningSign(icon.rain)
	end
	if string.find(msg, L["mc_trigger"]) then
		self:Sync(syncName.mc)
	end
	if string.find(msg, L["mcFade_trigger"]) then
		self:Sync(syncName.mcEnd)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrage then
		self:Enrage()
	elseif sync == syncName.silence and self.db.profile.silence then
		self:Silence()
	elseif sync == syncName.raidSilence and self.db.profile.raidSilence then
		self:RaidSilence()
	elseif sync == syncName.poison and self.db.profile.poison then
		self:Poison()
	elseif sync == syncName.mc and self.db.profile.mc then
		self:Mc()
	elseif sync == syncName.mcEnd and self.db.profile.mc then
		self:McEnd()
	end
end

function module:Mc()
	self:Bar(L["mc_bar"], timer.mc, icon.mc, true, "black")
end

function module:McEnd()
	self:RemoveBar(L["mc_bar"])
end

function module:RaidSilence()
	self:Bar(L["raidSilence_bar"], timer.raidSilence, icon.silence, true, "blue")
end

function module:Poison()
	if playerClass == "SHAMAN" then
		self:WarningSign(icon.poison, 0.7)
	end
end

function module:Enrage()
	isEnraged = true
	if self.db.profile.enrage then
		self:RemoveBar(L["enrageCD_bar"])
		self:CancelDelayedMessage(L["enrageSoon_warn"])
		self:Message(L["enrage_warn"], nil, nil, false)
		self:Bar(L["isEnraged_bar"], timer.silencedEnrage, icon.enrage, true, "red")
		if playerClass == "WARRIOR" or playerClass == "PRIEST" then
			if self.db.profile.bigicon then
				self:WarningSign(icon.enrage, 0.7)
			end
			if self.db.profile.sounds then
				self:Sound("Info")
			end
		end
	end
end

function module:Silence()
	local currentTime = GetTime()	
	if isEnraged == false then
		if (timeEnrageFaded + 30) >= currentTime then
			self:Bar(L["silence_bar"], timer.silence, icon.silence, true, "white")
			self:Message(L["silencedWayEarly_warn"], "Urgent")
		end
		if (timeEnrageFaded + 30) < currentTime then
			self:Bar(L["silence_bar"], timer.silence, icon.silence, true, "white")
			self:Message(L["silencedWithoutEnrage_warn"], "Urgent")
			if self.db.profile.enrage then
				self:Bar(L["enrageCD_bar"], timer.silencedWithoutEnrage, icon.enrage, true, "red")
				self:DelayedMessage(timer.silencedWithoutEnrage - 10, L["enrageSoon_warn"], "Urgent", nil, nil)
			end
			if playerClass == "PRIEST" and self.db.profile.bigicon then
				self:DelayedWarningSign(timer.silencedWithoutEnrage - 11, icon.mc, 0.7)
			end
			if playerClass == "PRIEST" and self.db.profile.sounds then
				self:DelayedSound(timer.silencedWithoutEnrage - 11, "Info")
			end
			timeEnrageFaded = currentTime
		end
	end
	if isEnraged == true then
		isEnraged = false
		just30 = false
		timeEnrageFaded = currentTime
		self:Bar(L["silence_bar"], timer.silence, icon.silence, true, "white")
		self:Message(L["silencedEnrage_warn"], "Urgent")
		if self.db.profile.enrage then
			self:RemoveBar(L["isEnraged_bar"])
			self:Bar(L["enrageCD_bar"], timer.silencedEnrage, icon.enrage, true, "red")
			self:DelayedMessage(timer.silencedEnrage - 10, L["enrageSoon_warn"], "Urgent", nil, nil)
		end
		if playerClass == "PRIEST" and self.db.profile.bigicon then
			self:DelayedWarningSign(timer.silencedEnrage - 11, icon.mc, 0.7)
		end
		if playerClass == "PRIEST" and self.db.profile.sounds then
			self:DelayedSound(timer.silencedEnrage - 11, "Info")
		end
	end
end

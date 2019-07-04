
local module, L = BigWigs:ModuleDeclaration("Gluth", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"mortalWound", "frenzy", "fear", "decimate", "enrage", "bosskill", "zombie"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gluth",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for fear",
	
	mortalWound_cmd = "mortalWound",
	mortalWound_name = "Mortal Wound Timer",
	mortalWound_desc = "Timer for Mortal Wound stakcs on tanks",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for frenzy",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Timer",
	enrage_desc = "Warn for Enrage",

	decimate_cmd = "decimate",
	decimate_name = "Decimate Alert",
	decimate_desc = "Warn for Decimate",
	
	zombie_cmd = "zombie",
	zombie_name = "Zombie Spawn",
	zombie_desc = "Shows timer for zombies",

	fear_trigger = "by Terrifying Roar.",
	fear2_trigger = "Terrifying Roar fails",
	fear5sec_warn = "Fear in 5 seconds",
	fear_warn = "Fear!",
	fear_bar = "Fear",
	
	start_trigger = "devours all nearby zombies!",
	
	frenzy_trigger = "%s goes into a frenzy!",
	frenzy_warn = "Frenzy Alert!",

	enrage_trigger = "gains Berserk",
	enrage_warn = "ENRAGE!",
	enrage_bar = "Enrage",
	enrage_warn_60 = "Enrage in 60 seconds",
	enrage_warn_30 = "Enrage in 30 seconds",
	enrage_warn_10 = "Enrage in 10 seconds",

	zombie_bar = "Zombies Stop Spawning",

	frenzygain_trigger = "Gluth gains Frenzy.",
	frenzygain_trigger2 = "Gluth goes into a frenzy!",
	frenzyend_trigger = "Frenzy fades from Gluth.",
	frenzy_message = "Frenzy! Tranq now!",
	frenzy_bar = "Frenzy!",
	frenzyNext_bar = "Next Frenzy",
	
	mortalWound_trigger = "(.+) is afflicted by Mortal Wound %((.+)%).",
	mortalWound_bar = " Mortal Wound",
	
	decimate_trigger = "Decimate hits",
	decimateSoon_warn = "Decimate Soon!",
	decimate_bar = "Decimate Zombies",
} end )

local timer = {
	decimate = 105,
	zombie = 90,
	enrage = 330,
	fear = 20,
	frenzy = 10,
	firstFrenzy = 15,
	frenzyLonger = 20,
	mortalWound = 15,
}

local icon = {
	zombie = "Ability_Seal",
	enrage = "Spell_Shadow_UnholyFrenzy",
	fear = "Spell_Shadow_PsychicScream",
	decimate = "INV_Shield_01",
	tranquil = "Spell_Nature_Drowsy",
	frenzy = "Ability_Druid_ChallangingRoar",
	mortalWound = "ability_criticalstrike",
}

local syncName = {
	frenzy = "GluthFrenzyStart"..module.revision,
	frenzyOver = "GluthFrenzyEnd"..module.revision,
	mortalWound = "GluthMortalWound"..module.revision,
	decimate = "GluthDecimate"..module.revision,
	fear = "GluthFear"..module.revision,
}

local lastFrenzy = 0
local frenzyCount = 0
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["start_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")

	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(2, syncName.mortalWound)
	self:ThrottleSync(60, syncName.decimate)
	self:ThrottleSync(10, syncName.fear)
end

function module:OnSetup()
	self.started = nil
	lastFrenzy = 0
	frenzyCount = 0
end

function module:OnEngage()
	if UnitName("target") == "Gluth" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Gluth")
	end
	if self.db.profile.decimate then
		self:Bar(L["decimate_bar"], timer.decimate, icon.decimate, true, "black")
		self:DelayedMessage(timer.decimate - 5, L["decimateSoon_warn"], "Urgent")
		self:DelayedWarningSign(timer.decimate -5, icon.decimate, 0.7)
	end
	if self.db.profile.frenzy then
		self:Bar(L["frenzyNext_bar"], timer.firstFrenzy, icon.frenzy, true, "white")
	end	
	if self.db.profile.fear then
		self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "blue")
	end	
	if self.db.profile.enrage then
		self:Bar(L["enrage_bar"], timer.enrage, icon.enrage, true, "white")
		self:DelayedMessage(timer.enrage - 60, L["enrage_warn_60"], "Attention")
		self:DelayedMessage(timer.enrage - 30, L["enrage_warn_30"], "Attention")
		self:DelayedMessage(timer.enrage - 10, L["enrage_warn_10"], "Urgent")
	end	
	if self.db.profile.zombie then
		self:Bar(L["zombie_bar"], timer.zombie, icon.zombie, true, "green")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["mortalWound_trigger"]) then
		local _,_,name,wounds = string.find(msg, L["mortalWound_trigger"])
		self:Sync(syncName.mortalWound .. " " .. name .. " " .. wounds)
	end
	if string.find(msg, L["frenzygain_trigger"]) or string.find(msg, L["frenzygain_trigger2"]) then
		self:Sync(syncName.frenzy)
	end
	if string.find(msg, L["frenzyend_trigger"]) then
		self:Sync(syncName.frenzyOver)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["decimate_trigger"]) then
		self:Sync(syncName.decimate)
	end
	if string.find (msg, L["fear_trigger"]) or string.find(msg, L["fear2_trigger"]) then
		self:Sync(syncName.fear)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:FrenzyOver()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	elseif sync == syncName.decimate and self.db.profile.decimate then
		self:Decimate()
		if self.db.profile.zombie then
			self:Zombie()
		end
	elseif sync == syncName.mortalWound and self.db.profile.mortalWound then
		self:MortalWound(rest)
	end
end

function module:Zombie()
	self:Bar(L["zombie_bar"], timer.zombie, icon.zombie, true, "green")
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Important")
end

function module:MortalWound(rest)
	if oldRest then
		self:RemoveBar(oldRest..L["mortalWound_bar"])
	end
	self:Bar(rest..L["mortalWound_bar"], timer.mortalWound, icon.mortalWound, true, "yellow")
	oldRest = rest
end

function module:Frenzy()
	frenzyCount = frenzyCount + 1
	self:Message(L["frenzy_message"], "Important", nil, true, "Alert")
	self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "red")
	if playerClass == "HUNTER" then
		self:WarningSign(icon.tranquil, timer.frenzy, true)
	end
	lastFrenzy = GetTime()
end

function module:FrenzyOver()
	self:RemoveBar(L["frenzy_bar"])
	self:RemoveWarningSign(icon.tranquil, true)
	if lastFrenzy ~= 0 then
		if frenzyCount == 9 then
			local NextTime = (lastFrenzy + timer.frenzyLonger) - GetTime()
			self:Bar(L["frenzyNext_bar"], NextTime, icon.frenzy, true, "white")
		else
			local NextTime = (lastFrenzy + timer.frenzy) - GetTime()
			self:Bar(L["frenzyNext_bar"], NextTime, icon.frenzy, true, "white")
		end
	end
end

function module:Fear()
	self:Message(L["fear_warn"], "Important")
	self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "blue")
	self:DelayedMessage(timer.fear - 5, L["fear5sec_warn"], "Urgent")
end

function module:Decimate()
	self:Bar(L["decimate_bar"], timer.decimate, icon.decimate, true, "black")
	self:DelayedMessage(timer.decimate - 5, L["decimateSoon_warn"], "Urgent")
	self:DelayedWarningSign(timer.decimate -5, icon.decimate, 0.7)
	if self.db.profile.zombie then
		self:Bar(L["zombie_bar"], timer.zombie, icon.zombie, true, "green")
	end
end

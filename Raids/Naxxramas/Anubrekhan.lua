
local module, L = BigWigs:ModuleDeclaration("Anub'Rekhan", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"corpseScarab", "locust", "impale", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Anubrekhan",

	locust_cmd = "locust",
	locust_name = "Locust Swarm Alert",
	locust_desc = "Warn for Locust Swarm",

	enrage_cmd = "enrage",
	enrage_name = "Crypt Guard Enrage Alert",
	enrage_desc = "Warn for Enrage",

	impale_cmd = "impale",
	impale_name = "Impale Alert",
	impale_desc = "Warns for Impale",
	
	corpseScarab_cmd = "corpseScarab",
	corpseScarab_name = "Corpse Scarab timer bars",
	corpseScarab_desc = "Shows timers for Corpse Scarabs",
	
	start_trigger1 = "Just a little taste...",
	start_trigger2 = "Yes, run! It makes the blood pump faster!",
	start_trigger3 = "There is no way out.",

	enrage_trigger = "gains Enrage.",
	enrage_warn = "Crypt Guard Enrage - Stun + Traps!",
	
	addDead_trigger = "Crypt Guard dies",

	swarmCast_trigger = "Anub'Rekhan begins to cast Locust Swarm.",
	swarm_trigger = "Anub'Rekhan gains Locust Swarm.",
	swarmCast_warn = "Incoming Locust Swarm!",
	swarmCD_bar = "Locust Swarm CD",
	swarmSoon_bar = "Locust Swarm Soon...",
	swarm_bar = "Locust Swarm",

	impale_trigger = "Impale hits",
	impale_bar = "Next Impale",

	corpseScarab_bar = "Corpse Scarabs",
} end )

local timer = {
	locustSwarmCD = 80,
	locustSwarmSoon = 20,
	locustSwarmDuration = 20,
	locustSwarmCastTime = 3,
	impale = 15,
	corpseScarab = 65
}

local icon = {
	locust = "Spell_Nature_InsectSwarm",
	impale = "ability_backstab",
	corpseScarab = "inv_misc_ahnqirajtrinket_01",
}

local syncName = {
	locustCast = "AnubLocustInc"..module.revision,
	locustGain = "AnubLocustSwarm"..module.revision,
	impale = "AnubImpale"..module.revision,
	enrage = "AnubEnrage"..module.revision,
}

module:RegisterYellEngage(L["start_trigger1"])
module:RegisterYellEngage(L["start_trigger2"])
module:RegisterYellEngage(L["start_trigger3"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.locustCast)
	self:ThrottleSync(10, syncName.locustGain)
	self:ThrottleSync(10, syncName.enrage)	
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if UnitName("target") == "Anub'Rekhan" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Anub'Rekhan")
	end
	if self.db.profile.locust then
		self:Bar(L["swarmCD_bar"], timer.locustSwarmCD, icon.locust, true, "green")
		self:DelayedBar(timer.locustSwarmCD, L["swarmSoon_bar"], timer.locustSwarmSoon, icon.locust, true, "green")
	end
	if self.db.profile.corpseScarab then
		self:Bar(L["corpseScarab_bar"], timer.corpseScarab, icon.corpseScarab, true, "red")
	end
	if self.db.profile.impale then
		self:Bar(L["impale_bar"], timer.impale, icon.impale, true, "blue")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["swarmCast_trigger"]) then
		self:Sync(syncName.locustCast)
	end
	if string.find(msg, L["swarm_trigger"]) then
		self:Sync(syncName.locustGain)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["impale_trigger"]) then
		self:Sync(syncName.impale)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.locustCast and self.db.profile.locust then
		self:LocustCast()
	elseif sync == syncName.locustGain and self.db.profile.locust then
		self:LocustGain()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.impale and self.db.profile.impale then
		self:Impale()
	end
end

function module:LocustCast()
	self:RemoveBar(L["impale_bar"])
	self:RemoveBar(L["swarmCD_bar"])
	self:RemoveBar(L["swarmSoon_bar"])
	self:CancelDelayedBar(L["swarmSoon_bar"])
	self:Message(L["swarmCast_warn"], "Orange", nil, "Beware")
	self:WarningSign(icon.locust, timer.locustSwarmCastTime)
	self:Bar(L["swarmCast_warn"], timer.locustSwarmCastTime, icon.locust, true, "green")
	self:DelayedSync(timer.locustSwarmCastTime, syncName.locustGain)
end

function module:LocustGain()
	self:Bar(L["swarm_bar"], timer.locustSwarmDuration, icon.locust, true, "green")
	self:DelayedBar(timer.locustSwarmDuration, L["swarmCD_bar"], timer.locustSwarmCD, icon.locust, true, "green")
	self:DelayedBar(100, L["swarmSoon_bar"], timer.locustSwarmSoon, icon.locust, true, "green")
	if self.db.profile.corpseScarab then
		self:DelayedBar(timer.locustSwarmDuration, L["corpseScarab_bar"], timer.corpseScarab - timer.locustSwarmDuration, icon.corpseScarab, true, "red")
	end
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Important", nil, "Alarm")
end

function module:Impale()
	self:RemoveBar(L["impale_bar"])
	self:Bar(L["impale_bar"], timer.impale, icon.impale, true, "blue")
end

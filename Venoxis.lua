
local module, L = BigWigs:ModuleDeclaration("High Priest Venoxis", "Zul'Gurub")

module.revision = 20041
module.enabletrigger = module.translatedName
module.wipemobs = {"Razzashi Cobra"}
module.toggleoptions = {"bigicon", "sounds", "phase", "adds", "renew", "holyfire", "enrage", "poison", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Venoxis",

	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcons alert for Renew, Holyfire, Poison, LastStand",
	bigicon_desc = "Shows a big icon when the boss has renew, someone has Holyfire, you are in the poison, boss is enraged and you should last stand",

	poison_cmd = "poison",
	poison_name = "Poison Cloud alert",
	poison_desc = "Alerts you when you stand in the poison",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound alert for Renew, Holyfire, Poison, LastStand",
	sounds_desc = "Sound effect when the boss has renew, someone has Holyfire, you are in the poison, boss is enraged and you should last stand",
	
	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Razzashi Cobras",

	renew_cmd = "renew",
	renew_name = "Renew Alert",
	renew_desc = "Warn for Renew",

	holyfire_cmd = "holyfire",
	holyfire_name = "Holy Fire Alert",
	holyfire_desc = "Warn for Holy Fire",

	phase_cmd  = "phase",
	phase_name = "Phase Notification",
	phase_desc = "Announces the boss' phase transition",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	renew_trigger = "High Priest Venoxis gains Renew\.",
	renewend_trigger = "Renew fades from High Priest Venoxis\.",
	renew_warn = "Renew! Dispel it!",
	renew_bar = "Renew",
	
	enrage_trigger = "High Priest Venoxis gains Enrage\.",
	enrage_warn = "Boss is enraged! Spam heals!",
	
	phase2_trigger = "Let the coils of hate unfurl!",
	phase2_warn = "Snake Phase",
	
	holyfire_trigger = "High Priest Venoxis begins to cast Holy Fire\.",
	holyfireend_trigger = "Holy Fire fades from",
	holyfire_warn = "Holy Fire, Dispel!",
	holyfire_bar = "Holy Fire",
	
	poison_trigger = "You suffer (.+) Nature damage from High Priest Venoxis's Poison Cloud.",
	poisonaura_trigger = "You are afflicted by Poison Cloud.",
	poison_warn = "Poison, Move!",
	
	adddead_trigger = "Razzashi Cobra dies",
	bossdead_trigger = "High Priest Venoxis dies",

	addmsg = "%d/4 Razzashi Cobras dead!",
} end )

local timer = {
	holyfire = 8.5,
	holyfirecast = 3,
	renew = 15,
}

local icon = {
	poison = "Ability_Creature_Disease_02",
	renew = "Spell_Holy_Renew",
	holyfire = "Spell_Holy_SearingLight",
	laststand = "spell_holy_ashestoashes",
}

local syncName = {
	phase2 = "VenoxisPhaseTwo"..module.revision,
	renew = "VenoxisRenewStart"..module.revision,
	renewover = "VenoxisRenewStop"..module.revision,
	holyfire = "VenoxisHolyFireStart"..module.revision,
	holyfireover = "VenoxisHolyFireStop"..module.revision,
	enrage = "VenoxisEnrage"..module.revision,
	adddead = "VenoxisAddDead"..module.revision,
}

local _, playerClass = UnitClass("player")
local berserkannounced = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")

	self:ThrottleSync(10, syncName.phase2)
	self:ThrottleSync(2, syncName.renew)
	self:ThrottleSync(2, syncName.renewover)
	self:ThrottleSync(2, syncName.holyfire)
	self:ThrottleSync(2, syncName.holyfireover)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
	self.cobra = 0

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
end

function module:OnEngage()
	phase2 = false
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["phase2_trigger"]) then
		self:Sync(syncName.phase2)
	end
end

function module:Event(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if string.find(msg, L["adddead_trigger"]) then
		self:Sync(syncName.adddead .. " " .. tostring(self.cobra + 1))
	end
	if string.find(msg, L["renew_trigger"]) then
		self:Sync(syncName.renew)
	end
	if string.find(msg, L["renewend_trigger"]) then
		self:Sync(syncName.renewover)
	end
	if string.find(msg, L["holyfire_trigger"]) then
		self:Sync(syncName.holyfire)
	end
	if string.find(msg, L["holyfireend_trigger"]) then
		self:Sync(syncName.holyfireover)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["poison_trigger"]) and self.db.profile.poison then
		self:Poison()
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 then
		self:KTM_Reset()
		if self.db.profile.phase then
			self:Phase2()
		end
	elseif sync == syncName.renew and self.db.profile.renew then
			self:Renew()
	elseif sync == syncName.renewover then
			self:RenewOver()
	elseif sync == syncName.holyfire and self.db.profile.holyfire then
		self:HolyFire()
	elseif sync == syncName.holyfireover then
		self:HolyFireOver()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.adddead and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 4 and self.cobra < rest then
			self.cobra = rest
			self:Message(string.format(L["addmsg"], self.cobra), "Positive")
		end
	end
end

function module:Phase2()
	if phase2 == false then
		self:Message(L["phase2_warn"], "Attention")
	end
	phase2 = true
end

function module:Renew()
	self:Message(L["renew_warn"], "Urgent")
	self:Bar(L["renew_bar"], timer.renew, icon.renew, true, "green")
	if self.db.profile.bigicon then
		if playerClass == "SHAMAN" or playerClass == "PRIEST" then
			self:WarningSign(icon.renew, 0.7)
			self:Sound("Info")
		end
	end
end

function module:RenewOver()
	self:RemoveBar(L["renew_bar"])
end

function module:HolyFire()
	self:DelayedMessage(timer.holyfirecast-0.7, L["holyfire_warn"], "Urgent")
	self:DelayedBar(timer.holyfirecast, L["holyfire_bar"], timer.holyfire, icon.holyfire, true, "red")
	if self.db.profile.bigicon then
		if playerClass == "PRIEST" then
			self:DelayedWarningSign(timer.holyfirecast-0.7, icon.holyfire, 0.7)
		end
	end
	if self.db.profile.sounds then
		self:DelayedSound(timer.holyfirecast-0.7, "Info")
	end
end

function module:HolyFireOver()
	self:RemoveBar(L["holyfire_bar"])
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Attention")
	if self.db.profile.bigicon then
		if playerClass == "WARRIOR" then
			self:WarningSign(icon.laststand, 1)
		end
	end
end

function module:Poison()
	self:Message(L["poison_warn"], "Personal")
	if self.db.profile.bigicon then
		self:WarningSign(icon.poison, 0.7)
	end
	if self.db.profile.sounds then
		self:Sound("Info")
	end
end

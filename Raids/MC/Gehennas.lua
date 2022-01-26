
local module, L = BigWigs:ModuleDeclaration("Gehennas", "Molten Core")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "curse", "rain", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gehennas",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Flamewakers",

	curse_cmd = "curse",
	curse_name = "Gehennas' Curse alert",
	curse_desc = "Warn for Gehennas' Curse",

	rain_cmd = "rain",
	rain_name = "Rain of Fire alert",
	rain_desc = "Shows a warning sign for Rain of Fire",

	rain_trigger = "You are afflicted by Rain of Fire",
	rain_run_trigger = "You suffer (%d+) Fire damage from Gehennas's Rain of Fire.",
	firewarn = "Move from FIRE!",
	
	dead1 = "Flamewaker dies",
	addmsg = "%d/2 Flamewakers dead!",
	flamewaker_name = "Flamewaker",

	curse_trigger = "afflicted by Gehennas",
	curse_trigger2 = "Gehennas' Curse was resisted",
	curse_warn_soon = "5 seconds until Gehennas' Curse!",
	curse_warn_now = "Gehennas' Curse - Decurse NOW!",
	curse_bar = "Gehennas' Curse",
} end)

local timer = {
	firstCurse = 12,
	firstRain = 10,
	rainTick = 2,
	rainDuration = 6,
	nextRain = 19,
	earliestCurse = 26.5,
	latestCurse = 26.5,
}

local icon = {
	curse = "Spell_Shadow_BlackPlague",
	rain = "Spell_Shadow_RainOfFire",
}

local syncName = {
	curse = "GehennasCurse"..module.revision,
	add = "GehennasAddDead"
}

local flamewaker = 0

module.wipemobs = { L["flamewaker_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.curse)
end

function module:OnSetup()
	self.started = false
	flamewaker = 0
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
end

function module:OnEngage()
	if self.db.profile.curse then
		self:DelayedMessage(timer.firstCurse - 5, L["curse_warn_soon"], "Urgent", nil, nil, true)
		self:Bar(L["curse_bar"], timer.firstCurse, icon.curse)
	end
	if UnitName("target") == "Gehennas" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Gehennas")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["rain_run_trigger"]) then
		if self.db.profile.rain then
			self:WarningSign(icon.rain, timer.rainTick)
		end
	end
	if ((string.find(msg, L["curse_trigger"])) or (string.find(msg, L["curse_trigger2"]))) then
		self:Sync(syncName.curse)
	end
	if string.find(msg, L["rain_trigger"]) then
		if self.db.profile.rain then
			self:Message(L["firewarn"], "Attention", true, "Alarm")
			self:WarningSign(icon.rain, timer.rainDuration)
		end
	end
	BigWigs:CheckForBossDeath(msg, self)
	if string.find(msg, L["dead1"]) then
		self:Sync(syncName.add .. " " .. tostring(flamewaker + 1))
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:DelayedMessage(timer.earliestCurse - 5, L["curse_warn_soon"], "Urgent", nil, nil, true)
		self:IntervalBar(L["curse_bar"], timer.earliestCurse, timer.latestCurse, icon.curse)
	elseif sync == syncName.add and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 2 and flamewaker < rest then
			flamewaker = rest
			if self.db.profile.adds then
				self:Message(string.format(L["addmsg"], flamewaker), "Positive")
			end
		end
	end
end

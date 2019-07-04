
local module, L = BigWigs:ModuleDeclaration("Broodlord Lashlayer", "Blackwing Lair")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"sounds", "ms", "bw", "knock", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Broodlord",

	ms_cmd = "ms",
	ms_name = "Mortal Strike",
	ms_desc = "Warn when someone gets Mortal Strike and starts a clickable bar for easy selection.",

	knock_cmd = "knock",
	knock_name = "Knock Away",
	knock_desc = "Shows a bar with the possible Knock Away cooldown.",

	bw_cmd = "bw",
	bw_name = "Blast Wave",
	bw_desc = "Shows a bar with the possible Blast Wave cooldown.\n\n(Disclaimer: this varies anywhere from 8 to 15 seconds. Chosen shortest interval for safety.)",
	
	sounds_cmd = "sounds",
	sounds_name = "Blastwave over sound alert",
	sounds_desc = "Sound effect when blastwave happenned",
	
	engage_trigger = "None of your kind should be here",
	
	ms_trigger = "^(.+) (.+) afflicted by Mortal Strike",
	ms_trigger2 = "Lashlayer's Mortal Strike",
	ms_warn_you = "Mortal Strike on you!",
	ms_warn_other = "Mortal Strike on %s!",
	ms_bar = "Mortal Strike: %s",
	msnext_bar = "Mortal Strike CD",
	
	bw_trigger = "^(.+) (.+) afflicted by Blast Wave",
	bw_warn = "Blast Wave soon!",
	bw_bar = "Blast Wave CD",

	knock_bar = "Knock Away (tank)",
	knock_trigger = "Lashlayer's Knock Away",

	are = "are",
} end )

local timer = {
	firstBlastWave = 10,
	earliestBlastWave = 11,
	latestBlastWave = 20,
	mortalStrike = 5,
	firstMortal = 8,
	earliestMortalStrike = 7,
	latestMortalStrike = 18,
	firstKnockAway = 12,
	knockAwayInterval = 13,
}

local icon = {
	blastWave = "Spell_Holy_Excorcism_02",
	mortalStrike = "Ability_Warrior_SavageBlow",
	knockAway = "INV_Gauntlets_05"
}

local syncName = {}
local _, playerClass = UnitClass("player")
local lastBlastWave = 0
local lastMS = 0
local MS = ""
local lastKnock = 0

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function module:OnSetup()
	self.started = nil
	lastBlastWave = 0
	lastMS = 0
	lastKnock = 0
	MS = ""
end

function module:OnEngage()
	if self.db.profile.bw then
		self:Bar(L["bw_bar"], timer.firstBlastWave, icon.blastWave, true, "Red")
	end
	if self.db.profile.ms then
		self:Bar("First Mortal Strike", timer.firstMortal, icon.mortalStrike, true, "Black")
	end
	if self.db.profile.knock then
		self:Bar(L["knock_bar"], timer.firstKnockAway, icon.knockAway)
	end
end

function module:OnDisengage()
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == self.translatedName then
		if UnitHealthMax(msg) == 100 then
			if  UnitHealth(msg) < 5 then
				self:UnregisterEvent("UNIT_HEALTH")
				self:Message("Don't loot, get away from the door.")
				self:Sound("dontlootgetaway")
			end
		end
	end
end

function module:Event(msg)
	local _, _, name, detect = string.find(msg, L["ms_trigger"])
	if name and detect and self.db.profile.ms then
		MS = name
		lastMS = GetTime()
		self:IntervalBar(L["msnext_bar"], timer.earliestMortalStrike, timer.latestMortalStrike, icon.mortalStrike)
		if detect == L["are"] then
			self:Message(L["ms_warn_you"], "Core", true, "Beware")
			self:Bar(string.format(L["ms_bar"], UnitName("player")), timer.mortalStrike, icon.mortalStrike, true, "Black")
			self:WarningSign(icon.mortalStrike, timer.mortalStrike)
		else
			self:Message(string.format(L["ms_warn_other"], name), "Core", true, "Alarm")
			self:Bar(string.format(L["ms_bar"], name), timer.mortalStrike, icon.mortalStrike, true, "Black")
		end
	elseif string.find(msg, L["bw_trigger"]) and self.db.profile.bw then
		if GetTime() - lastBlastWave > 5 then
			self:IntervalBar(L["bw_bar"], timer.earliestBlastWave, timer.latestBlastWave, icon.blastWave, true, "Red")
			if playerClass == "WARRIOR" or playerClass == "ROGUE" then
				if self.db.profile.sounds then
					self:Sound("gogogo")
				end
			end
		end
		lastBlastWave = GetTime()
	end
	if string.find(msg, L["knock_trigger"]) and self.db.profile.knock then
		if GetTime() - lastKnock > 5 then
			self:Bar(L["knock_bar"], timer.knockAwayInterval, icon.knockAway, true, "White")
		end
		lastKnock = GetTime()
	elseif string.find(msg, L["ms_trigger2"]) and self.db.profile.ms then
		self:IntervalBar(L["msnext_bar"], timer.earliestMortalStrike, timer.latestMortalStrike, icon.mortalStrike)
	end
end

function module:PLAYER_TARGET_CHANGED()
	if (lastMS + 5) > GetTime() and UnitName("target") == MS then
		if self.db.profile.ms then
			self:WarningSign(icon.mortalStrike, (lastMS + 5) - GetTime())
		end
	else
		self:RemoveWarningSign(icon.mortalStrike)
	end
end

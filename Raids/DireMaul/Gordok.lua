
local module, L = BigWigs:ModuleDeclaration("King Gordok", "Dire Maul")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"stomp", "ms", "charge", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gordok",
	
	ms_cmd = "ms",
	ms_name = "Mortal Strike",
	ms_desc = "Warn when someone gets Mortal Strike",

	stomp_cmd = "stomp",
	stomp_name = "War Stomp",
	stomp_desc = "Warn when someone gets War Stomp",

	charge_cmd = "charge",
	charge_name = "Charge",
	charge_desc = "Warn when someone gets Charge",

	ms_trigger = "King Gordok's Mortal Strike",
	ms_bar = "Mortal Strike CD",
	
	warstomp_trigger = "King Gordok's War Stomp",
	warstomp_bar = "Warstomp CD",
	
	charge_trigger = "King Gordok's Berserker Charge",
	charge_bar = "Charge CD",	
} end )

local timer = {
	firstWarStomp = {13, 24},
	warStomp = {17, 26},

	firstMortalStrike = {24, 30},
	mortalStrike = {17, 26},

	firstCharge = 5,
	charge = 20,
	timeoutCharge = 5,
}

local icon = {
	warStomp = "Ability_WarStomp",
	mortalStrike = "Ability_Warrior_SavageBlow",
	charge = "Ability_Warrior_Charge",
}

local startTime = 0
local lastStomp = 0
local lastMS = 0
local lastCharge = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
end

function module:OnSetup()
end

function module:OnEngage()
	startTime = GetTime()
	lastStomp = 0
	lastMS = 0
	lastCharge = startTime - timer.charge + timer.firstCharge
	self:ScheduleRepeatingEvent("gordok_checktimeout", self.CheckTimeout, 0.5, self)
	if self.db.profile.stomp then
		self:IntervalBar(L["warstomp_bar"], timer.firstWarStomp[1], timer.firstWarStomp[2], icon.warStomp, true, "yellow")
	end
	if self.db.profile.ms then
		self:IntervalBar(L["ms_bar"], timer.firstMortalStrike[1], timer.firstMortalStrike[2], icon.mortalStrike, true, "blue")
	end
	if self.db.profile.charge then
		self:Bar(L["charge_bar"], timer.firstCharge, icon.charge, true, "red")
	end
	if UnitName("target") == "King Gordok" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "King Gordok")
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("gordok_checktimeout")
end

function module:Event(msg)
	if self.db.profile.stomp and string.find(msg, L["warstomp_trigger"]) then
		if GetTime() > lastStomp + 2 then
			lastStomp = GetTime()
			self:Warstomp()
		end
	elseif self.db.profile.ms and string.find(msg, L["ms_trigger"]) then
		if GetTime() > lastMS + 2 then
			lastMS = GetTime()
			self:MortalStrike()
		end
	elseif self.db.profile.charge and string.find(msg, L["charge_trigger"]) then
		if GetTime() > lastCharge + 2 then
			lastCharge = GetTime()
			self:Charge()
		end
	end
end

function module:CheckTimeout()
	if self.db.profile.charge then
		local timeSinceCharge = GetTime() - lastCharge
		if timeSinceCharge >= timer.charge + timer.timeoutCharge then
			lastCharge = GetTime() - timer.timeoutCharge
			self:QuickCharge()
		end
	end
end

function module:Warstomp()
	self:IntervalBar(L["warstomp_bar"], timer.warStomp[1], timer.warStomp[2], icon.warStomp, true, "yellow")
end

function module:MortalStrike()
	self:IntervalBar(L["ms_bar"], timer.mortalStrike[1], timer.mortalStrike[2], icon.mortalStrike, true, "blue")
end

function module:Charge()
	self:Bar(L["charge_bar"], timer.charge, icon.charge, true, "red");
end

function module:QuickCharge()
	self:Bar(L["charge_bar"], (timer.charge - timer.timeoutCharge), icon.charge, true, "red");
end

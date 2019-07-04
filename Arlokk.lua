
local module, L = BigWigs:ModuleDeclaration("High Priestess Arlokk", "Zul'Gurub")

module.revision = 20044
module.enabletrigger = module.translatedName
module.toggleoptions = {"gouge", "taunt", "bigicon", "sounds", "phase", "whirlwind", "vanish", "mark", "icon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Arlokk",

	vanish_cmd = "vanish",
	vanish_name = "Vanish alert",
	vanish_desc = "Shows a bar for the Vanish duration.",

	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon warnings",
	bigicon_desc = "Big icon warning to Taunt on Gouge and runaway on Whirlwind",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound alerts",
	sounds_desc = "Sound alert to Taunt on Gouge and runaway on Whirlwind",

	taunt_cmd = "taunt",
	taunt_name = "Taunt warning on Gouge",
	taunt_desc = "Warn warriors to taunt on Gouge",
	
	gouge_cmd = "gouge",
	gouge_name = "Gouge timer bars",
	gouge_desc = "Timer bar for the Gouge cooldown and effect",

	mark_cmd = "mark",
	mark_name = "Mark of Arlokk alert",
	mark_desc = "Warns when people are marked.",

	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirldind alert",
	whirlwind_desc = "Shows you when the boss has Whirlwind.",

	phase_cmd = "phase",
	phase_name = "Phase notification",
	phase_desc = "Announces the boss' phase transitions.",

	icon_cmd = "puticon",
	icon_name = "Raid icon on marked players",
	icon_desc = "Place a raid icon on the player with Mark of Arlokk.\n\n(Requires assistant or higher)",
	
	engage_trigger = "your priestess calls upon your might",
	trollphase_message = "Troll Phase",
	pantherphase_message = "Panther Phase",

	vanishphase_message = "Vanish!",
	vanish_bar = "Estimated Return",
	vanish_Nextbar = "Next Vanish",
	
	mark_trigger = "Feast on (.+), my pretties!",
	mark_warn = " is marked!",

	ww_trigger = "High Priestess Arlokk gains Whirlwind\.",
	ww_bar = "Whirlwind",
	
	gouge_trigger = "(.+) (.+) afflicted by Gouge.",
	gougefail_trigger = "High Priestess Arlokk's Gouge failed. (.+) (.+) immune.",
	gougeend_trigger = "Gouge fades from (.+).",
	gouge_bar = "Gouge",
	gougecd_bar = "Gouge CD",
	
} end )

local timer = {
	firstVanish = 35,
	vanish = 65,
	unvanish = 40,
	whirlwind = 2,
	gougeeffect = 6,
	firstgouge = 15,
}

local icon = {
	vanish = "Ability_Vanish",
	whirlwind = "Ability_Whirlwind",
	gouge = "Ability_Gouge",
	taunt = "spell_nature_reincarnation",
}

local syncName = {
	trollPhase = "ArlokkPhaseTroll"..module.revision,
	vanishPhase = "ArlokkPhaseVanish"..module.revision,
	pantherPhase = "ArlokkPhasePanther"..module.revision,
	gouge = "ArlokkGouge"..module.revision,
	gougeend = "ArlokkGougeEnd"..module.revision,
	mark = "ArlokkMark"..module.revision,
	whirlwind = "ArlokkWhirlwind"..module.revision,
}

local _, playerClass = UnitClass("player")
module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")

	self:ThrottleSync(3, syncName.trollPhase)
	self:ThrottleSync(3, syncName.vanishPhase)
	self:ThrottleSync(3, syncName.pantherPhase)
	self:ThrottleSync(3, syncName.gouge)
	self:ThrottleSync(3, syncName.gougeend)
	self:ThrottleSync(3, syncName.mark)
	self:ThrottleSync(3, syncName.whirlwind)
end

function module:OnSetup()
	self.started = nil
	vanished = nil
end

function module:OnEngage()
	self:CancelScheduledEvent("checkvanish")
	self:ScheduleRepeatingEvent("checkvanish", self.CheckVanish, 1, self)
	if self.db.profile.phase then
		self:Message(L["trollphase_message"], "Attention")
	end
	if self.db.profile.vanish then
		self:Bar(L["vanish_Nextbar"], timer.firstVanish, icon.vanish, true, "white")
	end
	if self.db.profile.gouge then
		self:Bar(L["gougecd_bar"], timer.firstgouge, icon.gouge, true,"red")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["gouge_trigger"]) then
		self:Sync(syncName.gouge)
	end
	if string.find(msg, L["gougeend_trigger"]) then
		self:Sync(syncName.gougeend)
	end
	if string.find(msg, L["gougefail_trigger"]) then
		self:Sync(syncName.gougeend)
	end
	if string.find(msg, L["ww_trigger"]) then
		self:Sync(syncName.whirlwind)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	local _,_,markedplayer = string.find(msg, L["mark_trigger"])
	if string.find(msg, L["mark_trigger"]) then
		self:Sync(syncName.mark.." "..markedplayer)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.pantherPhase then
		self:PantherPhase()
	elseif sync == syncName.vanishPhase then
		self:VanishPhase()
	elseif sync == syncName.gouge and self.db.profile.gouge then
		self:Gouge()
	elseif sync == syncName.gougeend then
		self:GougeEnd()
	elseif sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
	elseif sync == syncName.mark and self.db.profile.mark then
		self:Mark(rest)
	end
end

function module:PantherPhase()
	vanished = false
	self:CancelScheduledEvent("checkunvanish")
	if self.db.profile.vanish then
		self:RemoveBar(L["vanish_bar"])
		self:Bar(L["vanish_Nextbar"], timer.vanish, icon.vanish, true, "white")
	end
	if self.db.profile.phase then
		self:Message(L["pantherphase_message"], "Attention")
	end

	if not vanished then
		self:ScheduleRepeatingEvent("checkvanish", self.CheckVanish, 0.5, self)
	end
end

function module:VanishPhase()
	vanished = true
	self:CancelScheduledEvent("checkvanish")
	self:CancelScheduledEvent("trollphaseinc")
	if self.db.profile.phase then
		self:Message(L["vanishphase_message"], "Attention")
	end
	if self.db.profile.vanish then
		self:RemoveBar(L["vanish_Nextbar"])
		self:Bar(L["vanish_bar"], timer.unvanish, icon.vanish, true, "white")
	end
	self:ScheduleRepeatingEvent("checkunvanish", self.CheckUnvanish, 0.5, self)
end

function module:CheckUnvanish()
	self:DebugMessage("CheckUnvanish")
	if module:IsArlokkVisible() then
		self:Sync(syncName.pantherPhase)
	end
end

function module:CheckVanish()
	self:DebugMessage("CheckVanish")
	if not module:IsArlokkVisible() then
		self:Sync(syncName.vanishPhase)
	end
end

function module:IsArlokkVisible()
	if UnitName("playertarget") == self.translatedName then
		return true
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == self.translatedName then
				return true
			end
		end
	end
	return false
end

function module:Gouge()
	self:RemoveBar(L["gougecd_bar"])
	self:Bar(L["gouge_bar"], timer.gougeeffect, icon.gouge, true, "red")
	if playerClass == "WARRIOR" then
		if self.db.profile.taunt then
			self:WarningSign(icon.taunt, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Info")
		end
	end
end

function module:GougeEnd()
	self:RemoveBar(L["gouge_bar"])
	self:RemoveBar(L["gougecd_bar"])
end

function module:Whirlwind()
	self:Bar(L["ww_bar"], timer.whirlwind, icon.whirlwind, true, "blue")
	if self.db.profile.bigicon then
		self:WarningSign(icon.whirlwind, 0.7)
	end
	if self.db.profile.sounds then
		self:Sound("RunAway")
	end
end

function module:Mark(rest)
	self:Message(rest..L["mark_warn"], "Attention")
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", rest)
	end
end

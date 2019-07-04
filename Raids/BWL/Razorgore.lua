
local module, L = BigWigs:ModuleDeclaration("Razorgore the Untamed", "Blackwing Lair")
local controller = AceLibrary("Babble-Boss-2.2")["Grethok the Controller"]

module.revision = 20041
module.enabletrigger = {module.translatedName, controller}
module.toggleoptions = {"phase", "mobs", "eggs", "polymorph", "mc", "icon", "orb", "fireballvolley", "conflagration", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Razorgore",

	mc_cmd = "mindcontrol",
	mc_name = "Mind Control",
	mc_desc = "Announces who gets mind controlled and starts a clickable bar for easy selection.",

	eggs_cmd = "eggs",
	eggs_name = "Eggs",
	eggs_desc = "Does a counter for Black Dragon Eggs destroyed.",

	phase_cmd = "phase",
	phase_name = "Phase",
	phase_desc = "Warn for Phase Change.",

	mobs_cmd = "mobs",
	mobs_name = "First wave",
	mobs_desc = "Shows you when the first wave spawns.",

	orb_cmd = "orb",
	orb_name = "Orb Control",
	orb_desc = "Shows you who is controlling the boss and starts a clickable bar for easy selection.",

	fireballvolley_cmd = "fireballvolley",
	fireballvolley_name = "Fireball Volley",
	fireballvolley_desc = "Announces when the boss is casting Fireball Volley.",

	conflagration_cmd = "conflagration",
	conflagration_name = "Conflagration",
	conflagration_desc = "Starts a bar with the duration of the Conflagration.",

	polymorph_cmd = "polymorph",
	polymorph_name = "Greater Polymorph",
	polymorph_desc = "Tells you who got polymorphed by Grethok the Controller and starts a clickable bar for easy selection.",

	icon_cmd = "icon",
	icon_name = "Raid Icon on Mind Control",
	icon_desc = "Place a raid icon on the mind controlled player for the duration of the debuff.\n\n(Requires assistant or higher)",
	
	start_trigger = "Intruders have breached",
	start_message = "Phase 1",
	
	mobs_soon = "First Wave in 5sec!",
	mobs_bar = "First Wave",
	
	orbcontrolyou_trigger = "You are afflicted by Mind Exhaustion\.",
	orbcontrolother_trigger = "(.+) is afflicted by Mind Exhaustion\.",
	orb_bar = "Orb control: %s",
	
	mindcontrolyou_trigger = "You are afflicted by Dominate Mind\.",
	mindcontrolyouend_trigger = "Dominate Mind fades from you\.",
	mindcontrolother_trigger = "(.+) is afflicted by Dominate Mind\.",
	mindcontrolotherend_trigger = "Dominate Mind fades from (.+)\.",
	mindcontrol_message_you = "You are mindcontrolled!",
	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",

	polymorphyou_trigger = "You are afflicted by Greater Polymorph\.",
	polymorphyouend_trigger = "Greater Polymorph fades from you\.",
	polymorphother_trigger = "(.+) is afflicted by Greater Polymorph\.",
	polymorphotherend_trigger = "Greater Polymorph fades from (.+)\.",
	polymorph_message_you = "You are polymorphed!",
	polymorph_message = "%s is polymorphed! Dispel!",
	polymorph_bar = "Polymorph: %s",
	
	deathyou_trigger = "You die\.",
	deathother_trigger = "(.+) dies\.",
	
	egg_trigger = "Razorgore the Untamed begins to cast Destroy Egg\.",
	
	egg_message = "%d/30 eggs destroyed!",
	egg_bar = "Destroy Egg",
	
	phase2_trigger = "I'm free! That device shall never torment me again!",
	phase2_message = "Phase 2",
	
	volley_trigger = "Razorgore the Untamed begins to cast Fireball Volley\.",
	volley_message = "Hide!",
	volley_bar = "Fireball Volley",

	conflagration_trigger = "afflicted by Conflagration",
	conflagration_bar = "Conflagration",
	
	warstomp_bar = "War Stomp",
	
	destroyegg_yell1 = "You'll pay for forcing me to do this.",
	destroyegg_yell2 = "Fools! These eggs are more precious than you know!",
	destroyegg_yell3 = "No - not another one! I'll have your heads for this atrocity!",
} end)

local timer = {
	mobspawn = 46,
	mc = 15,
	polymorph = 20,
	conflagrate = 10,
	firstConflagrate = 10,
	firstVolley = 20,
	firstWarStomp = 30,
	volley = 2,
	egg = 3,
	orb = 90,
}

local icon = {
	mobspawn = "Spell_Holy_PrayerOfHealing",
	egg = "INV_Misc_MonsterClaw_02",
	orb = "INV_Misc_Gem_Pearl_03",
	volley = "Spell_Fire_FlameBolt",
}

local syncName = {
	egg = "RazorgoreEgg"..module.revision,
	eggStart = "RazorgoreEggStart"..module.revision,
	orb = "RazorgoreOrbStart_"..module.revision,
	orbOver = "RazorgoreOrbStop_"..module.revision,
	volley = "RazorgoreVolleyCast"..module.revision,
	phase2 = "RazorgorePhaseTwo"..module.revision,
}

local doCheckForWipe = false
module:RegisterYellEngage(L["start_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "Events")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
	
	self:ThrottleSync(5, syncName.egg)
	self:ThrottleSync(5, syncName.orb .. "(.+)")
	self:ThrottleSync(5, syncName.orbOver .. "(.+)")
	self:ThrottleSync(3, syncName.volley)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self.started        = nil
	self.phase          = 0
	self.previousorb    = nil
	self.eggs           = 0
	doCheckForWipe = false
end

function module:OnEngage()
	if self.db.profile.phase then
		self:Message(L["start_message"], "Attention")
	end
	if self.db.profile.mobs then
		self:Bar(L["mobs_bar"], timer.mobspawn, icon.mobspawn)
		self:DelayedMessage(timer.mobspawn - 5, L["mobs_soon"], "Important")
	end
	self:TriggerEvent("BigWigs_StartCounterBar", self, "Eggs destroyed", 30, "Interface\\Icons\\inv_egg_01")
	self:TriggerEvent("BigWigs_SetCounterBar", self, "Eggs destroyed", (30 - 0.1))
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if (msg == string.format(UNITDIESOTHER, controller)) then
		doCheckForwipe = false
		self:ScheduleEvent("startRazorgoreWipeCheck", function()
		end, 60)
	end
end

function module:CheckForWipe(event)
	if doCheckForWipe then
		BigWigs:CheckForWipe(self)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["destroyegg_yell1"] or msg == L["destroyegg_yell2"] or msg == L["destroyegg_yell3"] then
		self:Sync(syncName.egg .. " " .. tostring(self.eggs + 1))
	end
end

--function module:CHAT_MSG_SAY(msg)
--	if msg == "I destroyed an egg" then
--		self:Sync(syncName.egg .. " " .. tostring(self.eggs + 1))
--		self:Message(tostring(self.eggs + 1))
--	end
--end
		
function module:Events(msg)
	local _, _, mcother = string.find(msg, L["mindcontrolother_trigger"])
	local _, _, mcotherend = string.find(msg, L["mindcontrolotherend_trigger"])
	local _, _, polyother = string.find(msg, L["polymorphother_trigger"])
	local _, _, polyotherend = string.find(msg, L["polymorphotherend_trigger"])
	local _, _, orbother = string.find(msg, L["orbcontrolother_trigger"])
	if self.db.profile.icon then
		if mcother then
			self:Icon(mcother)
		elseif msg == L["mindcontrolyou_trigger"] then
			self:Icon(UnitName("player"))
		elseif mcotherend or msg == L["mindcontrolyouend_trigger"] or deathother or msg == L["deathyou_trigger"] then
			self:RemoveIcon()
		end
	end
	if self.db.profile.mc then
		if msg == L["mindcontrolyou_trigger"] then
			self:Message(L["mindcontrol_message_you"], "Important")
			self:Bar(string.format(L["mindcontrol_bar"], UnitName("player")), timer.mc, "Spell_Shadow_ShadowWordDominate", true, "black")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], UnitName("player")), function(name, button, extra) TargetByName(extra, true) end, UnitName("player"))
		elseif mcother then
			self:Message(string.format(L["mindcontrol_message"], mcother), "Important")
			self:Bar(string.format(L["mindcontrol_bar"], mcother), timer.mc, "Spell_Shadow_ShadowWordDominate", true, "black")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], mcother), function(name, button, extra) TargetByName(extra, true) end, mcother)
		elseif string.find(msg, L["mindcontrolyouend_trigger"]) then
			self:RemoveBar(string.format(L["mindcontrol_bar"], UnitName("player")))
		elseif mcotherend then
			self:RemoveBar(string.format(L["mindcontrol_bar"], mcotherend))
		end
	end
	if self.db.profile.polymorph then
		if msg == L["polymorphyou_trigger"] then
			self:Message(L["polymorph_message_you"], "Important")
			self:Bar(string.format(L["polymorph_bar"], UnitName("player")), timer.polymorph, "Spell_Nature_Brilliance", true, "cyan")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["polymorph_bar"], UnitName("player")), function(name, button, extra) TargetByName(extra, true) end, UnitName("player"))
		elseif polyother then
			self:Message(string.format(L["polymorph_message"], polyother), "Important")
			self:Bar(string.format(L["polymorph_bar"], polyother), timer.polymorph, "Spell_Nature_Brilliance", true, "cyan")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["polymorph_bar"], polyother), function(name, button, extra) TargetByName(extra, true) end, polyother)
		elseif msg == L["polymorphyouend_trigger"] then
			self:RemoveBar(string.format(L["polymorph_bar"], UnitName("player")))
		elseif polyotherend then
			self:RemoveBar(string.format(L["polymorph_bar"], polyotherend))
		end
	end
	if self.db.profile.orb then
		if orbother then
			self:Sync(syncName.orb .. orbother)
		elseif msg == L["orbcontrolyou_trigger"] then
			self:Sync(syncName.orb .. UnitName("player"))
		end
	end
	if self.db.profile.conflagration and string.find(msg, L["conflagration_trigger"]) then
		self:Bar(L["conflagration_bar"], timer.conflagrate, "Spell_Fire_Incinerate", true, "red")
	end
	if string.find(msg, L["egg_trigger"]) then
		self:Sync(syncName.eggStart)
	end
end

function module:CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE(msg)
	if self.db.profile.fireballvolley and msg == L["volley_trigger"] then
		self:Bar(L["volley_bar"], timer.volley, icon.volley, true, "blue")
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["volley_trigger"] then
		self:Sync(syncName.volley)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.egg then
		rest = tonumber(rest)
		self:ThirtyEggs(rest)
		if rest == (self.eggs + 1) and self.eggs <= 30 then
			self.eggs = self.eggs + 1
			if self.db.profile.eggs then
				self:Message(string.format(L["egg_message"], self.eggs), "Positive")
			end
			self:TriggerEvent("BigWigs_SetCounterBar", self, "Eggs destroyed", (30 - self.eggs))
			elseif rest == (self.eggs + 1) and rest == 30 and self.phase ~= 2 then
			self:Sync(syncName.phase2)
		end
	elseif sync == syncName.eggStart then
		if self.db.profile.eggs then
			self:Bar(L["egg_bar"], timer.egg, icon.egg, true, "purple")
		end
	elseif string.find(sync, syncName.orb) then
		rest = string.sub(sync, 24)
		self:CancelScheduledEvent("destroyegg_check")
		self:CancelScheduledEvent("orbcontrol_check")
		if self.db.profile.orb then
			if self.previousorb ~= nil then
				self:RemoveBar(string.format(L["orb_bar"], self.previousorb))
			end
			self:Bar(string.format(L["orb_bar"], rest), timer.orb, icon.orb, true, "white")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["orb_bar"], rest), function(name, button, extra) TargetByName(extra, true) end, rest)
		end
		self:ScheduleEvent("orbcontrol_check", self.OrbControlCheck, 1, self)
		self.previousorb = rest
	elseif string.find(sync, syncName.orbOver) then
		self:CancelScheduledEvent("destroyegg_check")
		self:CancelScheduledEvent("orbcontrol_check")
		if self.db.profile.orb and self.previousorb then
			self:Bar(string.format(L["orb_bar"], self.previousorb), timer.orb, icon.orb, true, "white")
		end
		if self.db.profile.fireballvolley then
			self:RemoveBar(L["volley_bar"])
		end
		if self.db.profile.eggs then
			self:RemoveBar(L["egg_bar"])
		end
	elseif sync == syncName.volley and self.db.profile.fireballvolley then
		self:Bar(L["volley_bar"], timer.volley, icon.volley, true, "red")
		self:Message(L["volley_message"], "Urgent")
		self:WarningSign(icon.volley, 2)
	elseif sync == syncName.phase2 and self.phase < 2 then
		self.phase = 2
		self:CancelScheduledEvent("destroyegg_check")
		self:CancelScheduledEvent("orbcontrol_check")
		if self.previousorb ~= nil and self.db.profile.orb then
			self:RemoveBar(string.format(L["orb_bar"], self.previousorb))
		end
		if self.db.profile.eggs then
			self:RemoveBar(L["egg_bar"])
		end
		if self.db.profile.phase then
			self:Message(L["phase2_message"], "Attention")
		end
		self:TriggerEvent("BigWigs_StopCounterBar", self, "Eggs destroyed")
		self:Bar(L["conflagration_bar"], timer.firstConflagrate, "Spell_Fire_Incinerate", true, "red")
		self:Bar(L["volley_bar"], timer.firstVolley, icon.volley, true, "blue")
		self:Bar(L["warstomp_bar"], timer.firstWarStomp, "Ability_BullRush")
		self:KTM_Reset()
	end
end

function module:OrbControlCheck()
	local bosscontrol = false
	for i = 1, GetNumRaidMembers() do
		if UnitName("raidpet"..i) == self.translatedName then
			bosscontrol = true
			break
		end
	end
	if bosscontrol then
		self:ScheduleEvent("orbcontrol_check", self.OrbControlCheck, 1, self)
	elseif GetRealZoneText() == "Blackwing Lair" then
		self:Sync(syncName.orbOver .. self.previousorb)
	end
end

function module:DestroyEggCheck()
	local bosscontrol = false
	for i = 1, GetNumRaidMembers() do
		if UnitName("raidpet" .. i) == self.translatedName then
			bosscontrol = true
			break
		end
	end
	if bosscontrol then
	end
end

function module:ThirtyEggs(rest)
	if rest == 30 then
		self:Sync(syncName.phase2)
	end
end

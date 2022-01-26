
local module, L = BigWigs:ModuleDeclaration("Onyxia", "Onyxia's Lair")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"icon", "flamebreath", "deepbreath", "knockAway", "phase", "onyfear", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Onyxia",
	engage_trigger = "must leave my lair to feed",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath",
	deepbreath_desc = "Warn when Onyxia begins to cast Deep Breath.",

	flamebreath_cmd = "flamebreath",
	flamebreath_name = "Flame Breath",
	flamebreath_desc = "Warn when Onyxia begins to cast Flame Breath.",
	
	knockAway_cmd = "knockAway",
	knockAway_name = "Knock Away",
	knockAway_desc = "Warn for Knock Away.",
	
	icon_cmd = "icon",
	icon_name = "Raid Icon on Onyxia's target",
	icon_desc = "Place a raid icon on Onyxia's targetted player.\n\n(Requires assistant or higher)",
	
	phase_cmd = "phase",
	phase_name = "Phase",
	phase_desc = "Warn for Phase Change.",

	onyfear_cmd = "onyfear",
	onyfear_name = "Fear",
	onyfear_desc = "Warn for Bellowing Roar in phase 3.",

	deepBreath_trigger = "Onyxia takes in a deep breath...",
	deepBreath_trigger2 = "Onyxia begins to cast Breath",
	deepBreath_warn = "Deep Breath incoming!",
	deepBreath_bar = "Deep Breath",
	
	flameBreath_trigger = "Onyxia begins to cast Flame Breath\.",
	flameBreathCast_bar = "Flame Breath",
	flameBreathCD_bar = "Flame Breath CD",
	flameBreathSoon_bar = "Flame Breath Soon...",
	
	knockAwayLand_trigger = "Knock Away hits",
	knockAwayLand_warn = "Tank -33% threat",
	knockAway_trigger = "Knock Away",
	knockAway_bar = "Knock Away",
	
	phase2_trigger = "from above",
	phase2_warn = "Phase 2",
	
	phase3_trigger = "It seems you'll need another lesson",
	phase3_warn = "Phase 3, TREMOR TOTEMS!",
	
	firstfear_trigger = "afflicted by Bellowing Roar",
	fear_trigger = "Onyxia begins to cast Bellowing Roar\.",
	fearCast_bar = "Fear",
	fearCD_bar = "Fear CD",
	fearSoon_bar = "Fear Soon...",
} end )

local timer = {
	deepBreathCast = 5,

	firstFearCD = 30, --saw 34sec
	fearCD = 12, --saw 13sec
	fearSoon = 23, --saw 13 16
	fearCast = 1.5,
	
	knockAwayTimer = 13,
	--first knock, saw 26 2x, putting 13 anyways
	--p1 after 1st knock, saw 13 many times
	--p3 she does it as she lands then every 13sec
	--p3 after 1st knock, saw 13

	firstBreath = 10.2, --saw 16 11.6 10.2
	p1BreathCD = 8, --saw 13 17 9
	p1breathSoon = 10, --saw 9 10
	p3firstBreath = 3.5, --saw 21 3.5
	p3breathCD = 8, -- saw 11 16 14 8
	p3breathSoon = 8, --saw 11 16 14
	flameBreathCast = 2,
}

local icon = {
	knockAway = "INV_Misc_MonsterScales_14",
	fear = "Spell_Shadow_Possession",
	deepbreath = "Spell_Fire_SelfDestruct",
	deepbreath_sign = "Spell_Fire_Lavaspawn",
	flamebreath = "spell_fire_fire",
	onyTarget = "spell_shadow_charm",
}

local syncName = {
	deepbreath = "OnyDeepBreath"..module.revision,
	phase2 = "OnyPhaseTwo"..module.revision,
	phase3 = "OnyPhaseThree"..module.revision,
	flamebreath = "OnyFlameBreath"..module.revision,
	fear = "OnyBellowingRoar"..module.revision,
	firstfear = "OnyFirstFear"..module.revision,
	refreshKnockAway = "OnyRefreshKnockAway"..module.revision,
	knockAwayWarn = "OnyKnockAwayWarn"..module.revision,
}

local transitioned = false
local phase = 0
local firstfear = false

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")
	
	self:ThrottleSync(10, syncName.deepbreath)
	self:ThrottleSync(10, syncName.phase2)
	self:ThrottleSync(10, syncName.phase3)
	self:ThrottleSync(5, syncName.flamebreath)
	self:ThrottleSync(5, syncName.fear)
	self:ThrottleSync(5, syncName.refreshKnockAway)
	self:ThrottleSync(5, syncName.knockAwayWarn)
	self:ThrottleSync(5, syncName.firstfear)
end

function module:OnSetup()
	self.started = false
	transitioned = false
	firstfear = false
	phase = 0
end

function module:OnEngage()
	onyCurrentTarget = nil
	phase = 1
	if self.db.profile.icon then
		self:ScheduleRepeatingEvent("onyTargetCheck", self.onyTarget, 0.5, self)
	end
	if self.db.profile.knockAway then
		self:Bar(L["knockAway_bar"], timer.knockAwayTimer, icon.knockAway, true, "white")
		self:ScheduleRepeatingEvent("knockTimerStart", self.startKnockAwayTimer, 13, self)
	end
	if self.db.profile.flamebreath then
		self:Bar(L["flameBreathCD_bar"], timer.firstBreath, icon.flamebreath, true, "red")
		self:DelayedBar(timer.firstBreath, L["flameBreathSoon_bar"],timer.p1breathSoon, icon.flamebreath, true, "red")
	end
	if UnitName("target") == "Onyxia" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Onyxia")
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("onyTargetCheck")
	self:CancelScheduledEvent("knockTimerStart")
	self:CancelScheduledEvent("knockTimerDelayedStart")
end

function module:onyTarget()
	if UnitName("target") == "Onyxia" and UnitName("targettarget") ~= nil then
		if GetRaidTargetIndex("targettarget") ~= 8 and self.db.profile.icon then
			SetRaidTarget("targettarget",8)
		end
		if UnitName("targettarget") ~= onyCurrentTarget then
			onyCurrentTarget = UnitName("targettarget")
			if onyCurrentTarget == UnitName("player") then
				self:SendSay("Onyxia targetting " .. UnitName("player") .. "!")
				self:WarningSign(icon.onyTarget, 0.5)
				self:Sound("Long")
			end
		end
	end
end

function module:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L["deepBreath_trigger"] then
		self:Sync(syncName.deepbreath)
	end
--[[
	if string.find(msg, L["deepBreath_trigger"]) then
		self:Sync(syncName.deepbreath)
	end
]]--
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if (string.find(msg, L["phase2_trigger"])) then
		self:Sync(syncName.phase2)
	elseif (string.find(msg, L["phase3_trigger"])) then
		self:Sync(syncName.phase3)
	end
end

function module:Event(msg)
	if string.find(msg, L["deepBreath_trigger2"]) then
		self:Sync(syncName.deepbreath)
	end
	if string.find(msg, L["firstfear_trigger"]) then
		self:Sync(syncName.firstfear)
	end
	if string.find(msg, L["fear_trigger"]) then
		self:Sync(syncName.fear)
	end
	if string.find(msg, L["flameBreath_trigger"]) then
		self:Sync(syncName.flamebreath)
	end
	if string.find(msg, L["knockAway_trigger"]) then
		self:Sync(syncName.refreshKnockAway)
	end
	if string.find(msg, L["knockAwayLand_trigger"]) then
		self:Sync(syncName.knockAwayWarn)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 then
		self:Phase2()
	elseif sync == syncName.phase3 then
		self:Phase3()
	elseif sync == syncName.deepbreath then
		self:DeepBreath()
	elseif sync == syncName.flamebreath and self.db.profile.flamebreath then
		self:FlameBreath()
	elseif sync == syncName.fear and self.db.profile.onyfear then
		self:Fear()
	elseif sync == syncName.firstfear and not firstfear then
		firstfear = true
		self:FirstFear()
	elseif sync == syncName.refreshKnockAway and self.db.profile.knockAway then
		self:startKnockAwayTimer()
	elseif sync == syncName.knockAwayWarn and self.db.profile.knockAway then
		self:startKnockAwayTimer()
		self:knockAwayWarn()
	end
end

function module:p3knockDelay()
	self:CancelScheduledEvent("knockTimerDelayedStart")
	self:ScheduleRepeatingEvent("knockTimerStart", self.startKnockAwayTimer, 13, self)
end

function module:startKnockAwayTimer()
	if phase ~= 2 then 
		self:RemoveBar(L["knockAway_bar"])
		self:Bar(L["knockAway_bar"], timer.knockAwayTimer, icon.knockAway, true, "white")
		self:CancelScheduledEvent("knockTimerStart")
		self:ScheduleRepeatingEvent("knockTimerStart", self.startKnockAwayTimer, 13, self)
	end
end

function module:knockAwayWarn()
	self:Message(L["knockAwayLand_warn"], "Important", false, "Info")
end

function module:FlameBreath()
	self:RemoveBar(L["flameBreathCD_bar"])
	self:RemoveBar(L["flameBreathSoon_bar"])
	self:CancelDelayedBar(L["flameBreathCD_bar"])
	self:CancelDelayedBar(L["flameBreathSoon_bar"])

	self:Bar(L["flameBreathCast_bar"], timer.flameBreathCast, icon.flamebreath, true, "red")

	if phase == 1 then
		self:DelayedBar(timer.flameBreathCast, L["flameBreathCD_bar"], timer.p1BreathCD, icon.flamebreath, true, "red")
		self:DelayedBar(timer.flameBreathCast + timer.p1BreathCD, L["flameBreathSoon_bar"],timer.p1breathSoon, icon.flamebreath, true, "red")
	end
	if phase == 3 then
		self:DelayedBar(timer.flameBreathCast, L["flameBreathCD_bar"], timer.p3breathCD, icon.flamebreath, true, "red")
		self:DelayedBar(timer.flameBreathCast + timer.p3breathCD, L["flameBreathSoon_bar"],timer.p3breathSoon, icon.flamebreath, true, "red")
	end
end

function module:Fear()
	self:RemoveBar(L["fearCD_bar"])
	self:RemoveBar(L["fearSoon_bar"])

	self:Bar(L["fearCast_bar"], timer.fearCast, icon.fear, true, "blue")
	self:WarningSign(icon.fear, 0.7)

	self:DelayedBar(timer.fearCast, L["fearCD_bar"], timer.fearCD, icon.fear, true, "blue")
	self:DelayedBar(timer.fearCast + timer.fearCD, L["fearSoon_bar"], timer.fearSoon, icon.fear, true, "blue")
end

function module:FirstFear()
	if self.db.profile.knockAway then
		self:RemoveBar(L["knockAway_bar"])
		self:Bar(L["knockAway_bar"], timer.knockAwayTimer, icon.knockAway, true, "white")
		self:ScheduleRepeatingEvent("knockTimerDelayedStart", self.p3knockDelay, 13, self)
	end
	if self.db.profile.flamebreath then
		self:Bar(L["flameBreathCD_bar"], timer.p3firstBreath, icon.flamebreath, true, "red")
		self:DelayedBar(timer.p3firstBreath, L["flameBreathSoon_bar"],timer.p3breathSoon, icon.flamebreath, true, "red")
	end
	if self.db.profile.onyfear then
		self:RemoveBar(L["fearSoon_bar"])
		self:Bar(L["fearCD_bar"], 30, icon.fear, true, "blue")
		self:WarningSign(icon.fear, 0.7)
		self:DelayedBar(30, L["fearSoon_bar"], 23, icon.fear, true, "blue")
	end
	if self.db.profile.icon then
		self:CancelScheduledEvent("onyTargetCheck")
		self:ScheduleRepeatingEvent("onyTargetCheck", self.onyTarget, 0.5, self)
	end
end

function module:Phase2()
	if phase < 2 then
		transitioned = true
		phase = 2
		if self.db.profile.phase then
			self:Message(L["phase2_warn"], "Important", false, "Alarm")
		end
		if self.db.profile.knockAway then
			self:RemoveBar(L["knockAway_bar"])
			self:CancelScheduledEvent("knockTimerStart")
			self:CancelScheduledEvent("onyTargetCheck")
			self:Bar(L["knockAway_bar"], 0.5, icon.knockAway, true, "white")
			self:DelayedBar(0.5, L["knockAway_bar"], timer.knockAwayTimer, icon.knockAway, true, "white")
		end
		if self.db.profile.icon then
			self:CancelScheduledEvent("onyTargetCheck")
		end
		if self.db.profile.flamebreath then
			self:RemoveBar(L["flameBreathCD_bar"])
			self:RemoveBar(L["flameBreathSoon_bar"])
			self:CancelDelayedBar(L["flameBreathCD_bar"])
			self:CancelDelayedBar(L["flameBreathSoon_bar"])
		end
	end
end

function module:Phase3()
	if self.db.profile.phase and phase < 3 then
		self:Message(L["phase3_warn"], "Important", true, "Beware")
		phase = 3
		self:KTM_Reset()
		self:Bar(L["fearSoon_bar"], 10, icon.fear, true, "blue")
	end
	if self.db.profile.knockAway then
		self:RemoveBar(L["knockAway_bar"])
		self:CancelScheduledEvent("knockTimerStart")
		self:Bar(L["knockAway_bar"], 10, icon.knockAway, true, "white")
	end
	if self.db.profile.icon then
		self:ScheduleRepeatingEvent("onyTargetCheck", self.onyTarget, 0.5, self)
	end
end

function module:DeepBreath()
	if self.db.profile.deepbreath then
		self:Message(L["deepBreath_warn"], "Important", true, "RunAway")
		self:Bar(L["deepBreath_bar"], timer.deepBreathCast, icon.deepbreath, true, "black")
		self:WarningSign(icon.deepbreath_sign, 1)
	end
end

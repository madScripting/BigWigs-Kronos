
local module, L = BigWigs:ModuleDeclaration("Onyxia", "Onyxia's Lair")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"flamebreath", "deepbreath", "wingbuffet", "fireball", "phase", "onyfear", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Onyxia",
	engage_trigger = "must leave my lair to feed",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath",
	deepbreath_desc = "Warn when Onyxia begins to cast Deep Breath.",

	flamebreath_cmd = "flamebreath",
	flamebreath_name = "Flame Breath",
	flamebreath_desc = "Warn when Onyxia begins to cast Flame Breath.",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet",
	wingbuffet_desc = "Warn for Wing Buffet.",

	fireball_cmd = "fireball",
	fireball_name = "Fireball",
	fireball_desc = "Warn for Fireball.",

	phase_cmd = "phase",
	phase_name = "Phase",
	phase_desc = "Warn for Phase Change.",

	onyfear_cmd = "onyfear",
	onyfear_name = "Fear",
	onyfear_desc = "Warn for Bellowing Roar in phase 3.",

	deepBreath_trigger = "takes in a deep breath",
	deepBreath_warn = "Deep Breath incoming!",
	deepBreath_bar = "Deep Breath",
	
	flameBreath_trigger = "Onyxia begins to cast Flame Breath\.",
	flameBreathCast_bar = "Flame Breath",
	flameBreathCD_bar = "Flame Breath CD",
	flameBreathSoon_bar = "Flame Breath Soon...",
	
	wingBuffet_trigger = "Onyxia begins to cast Wing Buffet\.",
	wingBuffetCast_bar = "Wing Buffet",
	wingBuffetCD_bar = "Wing Buffet CD",
	wingBuffetSoon_bar = "Wing Buffet Soon...",
	
	fireball_trigger = "Onyxia begins to cast Fireball.",
	fireballCast_bar = "Fireball on %s",
	
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
	
	firstBuffet = 12, --saw 12
	p1buffetCD = 25, --saw 30 25
	p1buffetSoon = 10, --saw 18 28
	p3firstBuffet = 7, --saw 7
	p3buffetCD = 15, --saw 18 28 17 15.5
	p3buffetSoon = 10, --saw 18 28
	wingBuffetCast = 1,

	firstBreath = 11.6, --saw 16 11.6
	p1BreathCD = 8, --saw 13 17 9
	p1breathSoon = 10, --saw 9 10
	p3firstBreath = 3.5, --saw 21 3.5
	p3breathCD = 8, -- saw 11 16 14 8
	p3breathSoon = 8, --saw 11 16 14
	flameBreathCast = 2,
}

local icon = {
	wingbuffet = "INV_Misc_MonsterScales_14",
	fear = "Spell_Shadow_Possession",
	deepbreath = "Spell_Fire_SelfDestruct",
	deepbreath_sign = "Spell_Fire_Lavaspawn",
	fireball = "Spell_Fire_FlameBolt",
	flamebreath = "spell_fire_fire",
}

local syncName = {
	deepbreath = "OnyDeepBreath"..module.revision,
	phase2 = "OnyPhaseTwo"..module.revision,
	phase3 = "OnyPhaseThree"..module.revision,
	flamebreath = "OnyFlameBreath"..module.revision,
	fireball = "OnyFireball"..module.revision,
	fear = "OnyBellowingRoar"..module.revision,
	firstfear = "OnyFirstFear"..module.revision,
	wingbuffet = "OnyWingBuffet"..module.revision,
}

local transitioned = false
local phase = 0
local fireballTarget = nil
local iconNumber = 8
local firstfear = false

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:ThrottleSync(10, syncName.deepbreath)
	self:ThrottleSync(10, syncName.phase2)
	self:ThrottleSync(10, syncName.phase3)
	self:ThrottleSync(5, syncName.flamebreath)
	self:ThrottleSync(2, syncName.fireball)
	self:ThrottleSync(5, syncName.fear)
	self:ThrottleSync(5, syncName.wingbuffet)
	self:ThrottleSync(5, syncName.firstfear)
end

function module:OnSetup()
	self.started = false
	transitioned = false
	fireballTarget = nil
	firstfear = false
	iconNumber = 8
	phase = 0
end

function module:OnEngage()
	phase = 1
	if self.db.profile.wingbuffet then
		self:Bar(L["wingBuffetCD_bar"], timer.firstBuffet, icon.wingbuffet, true, "white")
		self:DelayedBar(timer.firstBuffet, L["wingBuffetSoon_bar"],timer.p1buffetSoon, icon.wingbuffet, true, "white")
	end
	if self.db.profile.flamebreath then
		self:Bar(L["flameBreathCD_bar"], timer.firstBreath, icon.flamebreath, true, "red")
		self:DelayedBar(timer.firstBreath, L["flameBreathSoon_bar"],timer.p1breathSoon, icon.flamebreath, true, "red")
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if string.find(msg, L["deepBreath_trigger"]) then
		self:Sync(syncName.deepbreath)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if (string.find(msg, L["phase2_trigger"])) then
		self:Sync(syncName.phase2)
	elseif (string.find(msg, L["phase3_trigger"])) then
		self:Sync(syncName.phase3)
	end
end

function module:Event(msg)
	if string.find(msg, L["firstfear_trigger"]) then
		self:Sync(syncName.firstfear)
	end
	if string.find(msg, L["fear_trigger"]) then
		self:Sync(syncName.fear)
	end
	if string.find(msg, L["flameBreath_trigger"]) then
		self:Sync(syncName.flamebreath)
	end
	if string.find(msg, L["wingBuffet_trigger"]) then
		self:Sync(syncName.wingbuffet)
	end
	if string.find(msg, L["fireball_trigger"]) then
		self:Sync(syncName.fireball)
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
	elseif sync == syncName.fireball  then
		self:Fireball()
	elseif sync == syncName.fear and self.db.profile.onyfear then
		self:Fear()
	elseif sync == syncName.firstfear and not firstfear then
		firstfear = true
		self:FirstFear()
	elseif sync == syncName.wingbuffet and self.db.profile.wingbuffet then
		self:WingBuffet()
	end
end

function module:WingBuffet()
	self:RemoveBar(L["wingBuffetCD_bar"])
	self:RemoveBar(L["wingBuffetSoon_bar"])
	self:CancelDelayedBar(L["wingBuffetCD_bar"])
	self:CancelDelayedBar(L["wingBuffetSoon_bar"])
	
	self:Bar(L["wingBuffetCast_bar"], timer.wingBuffetCast, icon.wingbuffet, true, "white")
	
	if phase == 1 then
		self:DelayedBar(timer.wingBuffetCast, L["wingBuffetCD_bar"], timer.p1buffetCD, icon.wingbuffet, true, "white")
		self:DelayedBar(timer.wingBuffetCast + timer.p1buffetCD, L["wingBuffetSoon_bar"],timer.p1buffetSoon, icon.wingbuffet, true, "white")
	end
	if phase == 3 then
		self:DelayedBar(timer.wingBuffetCast, L["wingBuffetCD_bar"], timer.p3buffetCD, icon.wingbuffet, true, "white")
		self:DelayedBar(timer.wingBuffetCast + timer.p3buffetCD, L["wingBuffetSoon_bar"],timer.p3buffetSoon, icon.wingbuffet, true, "white")
	end
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
	if self.db.profile.wingbuffet then
		self:Bar(L["wingBuffetCD_bar"], timer.p3firstBuffet, icon.wingbuffet, true, "white")
		self:DelayedBar(timer.p3firstBuffet, L["wingBuffetSoon_bar"],timer.p3buffetSoon, icon.wingbuffet, true, "white")
	end
	if self.db.profile.flamebreath then
		self:Bar(L["flameBreathCD_bar"], timer.p3firstBreath, icon.flamebreath, true, "red")
		self:DelayedBar(timer.p3firstBreath, L["flameBreathSoon_bar"],timer.p3breathSoon, icon.flamebreath, true, "red")
	end
	if self.db.profile.onyfear then
		self:RemoveBar(L["fearSoon_bar"])
		self:Bar(L["fearCD_bar"], 30, icon.fear, true, "blue") --timer.firstfearCD
		self:WarningSign(icon.fear, 0.7)
		self:DelayedBar(30, L["fearSoon_bar"], 23, icon.fear, true, "blue") --timer.firstfearCD --timer.fearSoon
	end
end

function module:Phase2()
	if phase < 2 then
		transitioned = true
		phase = 2
		if self.db.profile.phase then
			self:Message(L["phase2_warn"], "Important", false, "Alarm")
		end
		self:RemoveBar(L["wingBuffetCD_bar"])
		self:RemoveBar(L["wingBuffetSoon_bar"])
		self:CancelDelayedBar(L["wingBuffetCD_bar"])
		self:CancelDelayedBar(L["wingBuffetSoon_bar"])
		self:RemoveBar(L["flameBreathCD_bar"])
		self:RemoveBar(L["flameBreathSoon_bar"])
		self:CancelDelayedBar(L["flameBreathCD_bar"])
		self:CancelDelayedBar(L["flameBreathSoon_bar"])
	end
end

function module:Phase3()
	if self.db.profile.phase and phase < 3 then
		self:Message(L["phase3_warn"], "Important", true, "Beware")
		phase = 3
		self:KTM_Reset()
		self:Bar(L["fearSoon_bar"], 10, icon.fear, true, "blue")
	end
end

function module:DeepBreath()
	if self.db.profile.deepbreath then
		self:Message(L["deepBreath_warn"], "Important", true, "RunAway")
		self:Bar(L["deepBreath_bar"], timer.deepBreathCast, icon.deepbreath, true, "black")
		self:WarningSign(icon.deepbreath_sign, 1)
	end
end

function module:DelayedFireballCheck()
	local name = "Unknown"
	self:CheckTarget()
	if fireballTarget then
		name = fireballTarget
		self:Icon(name, iconNumber)
		iconNumber = iconNumber - 1
		if iconNumber < 7 then
			iconNumber = 8
		end
		if name == UnitName("player") then
			self:WarningSign(icon.fireball, 0.7)
		end
	end
	if self.db.profile.fireball then
		self:Bar(string.format(L["fireballCast_bar"], name), 3 - 0.1, icon.fireball, true, "red")
	end
end

function module:Fireball()
	self:ScheduleEvent("OnyxiaDelayedFireballCheck", self.DelayedFireballCheck, 0.1, self)
end

function module:CheckTarget()
	local i
	local newtarget = nil
	local enemy = self:ToString()
	if UnitName("playertarget") == enemy then
		newtarget = UnitName("playertargettarget")
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == enemy then
				newtarget = UnitName("Raid"..i.."targettarget")
				break
			end
		end
	end
	if newtarget then
		fireballTarget = newtarget
	end
end

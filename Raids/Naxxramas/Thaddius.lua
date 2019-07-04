
local module, L = BigWigs:ModuleDeclaration("Thaddius", "Naxxramas")
local feugen = AceLibrary("Babble-Boss-2.2")["Feugen"]
local stalagg = AceLibrary("Babble-Boss-2.2")["Stalagg"]

module.revision = 20049
module.enabletrigger = {module.translatedName, feugen, stalagg}
module.toggleoptions = {"sounds", "bigicon", "enrage", "charge", "polarity", -1, "power", "magneticPull", "phase", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Thaddius",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon Magnetic Pull Alert",
	bigicon_desc = "Warns adds tanks to taunt for Magnetic Pull with a BigIcon",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound Alert for Magnetic Pull",
	sounds_desc = "Warns adds tanks to taunt for Magnetic Pull with sound",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	phase_cmd = "phase",
	phase_name = "Phase Alerts",
	phase_desc = "Warn for Phase transitions",

	polarity_cmd = "polarity",
	polarity_name = "Polarity Shift Alert",
	polarity_desc = "Warn for polarity shifts",

	power_cmd = "power",
	power_name = "Power Surge Alert",
	power_desc = "Warn for Stalagg's power surge",

	addDeath_cmd = "addDeath",
	addDeath_name = "Add Death Alert",
	addDeath_desc = "Alerts when an add dies.",

	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn about Positive/Negative charge for yourself only.",

	magneticPull_cmd = "magneticPull",
	magneticPull_name = "Magnetic Pull Alerts",
	magneticPull_desc = "Warn about tank platform swaps.",

	feugen = "Feugen",
	stalagg = "Stalagg",
	
	enrage_trigger = "%s goes into a berserker rage!", --emote
	enrage_warn = "Enrage!",	
	enrage60sec_warn = "Enrage in 60 seconds",
	enrage30sec_warn = "Enrage in 30 seconds",
	enrage10sec_warn = "Enrage in 10 seconds",
	enrage_bar = "Enrage",
	
	start_trigger = "Stalagg crush you!", --yell
	start_trigger1 = "Feed you to master!", --yell
	
	teslaOverload_trigger = "overloads!",
	
	phase2_trigger1 = "EAT YOUR BONES", --yell
	phase2_trigger2 = "BREAK YOU!", --yell
	phase2_trigger3 = "KILL!", --yell

	stalaggDead_trigger = "Stalagg dies.", --"CHAT_MSG_COMBAT_HOSTILE_DEATH"
	feugenDead_trigger = "Feugen dies.", --"CHAT_MSG_COMBAT_HOSTILE_DEATH"
	phase2_14sec_warn = "Thaddius in 14 seconds",
	
	powerSurge_trigger = "Stalagg gains Power Surge.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	powerSurge_warn = "Power Surge on Stalagg!",
	powerSurge_bar = "Power Surge",

	magneticPull_trigger = "casts Magnetic Pull", --?? CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	magneticPull_warn = "Magnetic Pull in 5 seconds!",
	magneticPull_Bar = "Magnetic Pull",
	
	phase2_trigger = "overloads!", --emote
	phase2_warn = "Phase 2, Thaddius in 4 seconds",
	phase2_bar = "Phase 2",
	
	polarityPosition_warn = "----- Thaddius +++++",
	polarityShift_trigger = "Now YOU feel pain!", --yell
	polarityShiftSoon_warn = "Polarity Shift Soon...",
	polarityShiftCD_bar = "Polarity Shift CD",
	polarityShiftSoon_bar = "Polarity Shift Soon...",
	
	polarityShiftCast_trigger = "Thaddius begins to cast Polarity Shift", --?? CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	polarityShiftCast_warn = "Polarity Shift inc!",
	polarityShiftCast_bar = "Polarity Shift Cast",

	nochange = "Your debuff did not change!",
	positivetype = "Interface\\Icons\\Spell_ChargePositive",
	poswarn = "You changed to a Positive Charge!",
	negativetype = "Interface\\Icons\\Spell_ChargeNegative",
	negwarn = "You changed to a Negative Charge!",
	polaritytickbar = "Polarity tick",
} end )

local timer = {
	powerSurge = 10,
	magneticPull = 20,
	enrage = 300,
	polarityShiftCast = 3,
	polarityTick = 5,
	firstPolarity = 10,
	polarityShiftCD = 25,--{25,35},
	polarityShiftSoon = 10,
	phase2 = 4,
}

local icon = {
	powerSurge = "Spell_Shadow_UnholyFrenzy",
	magneticPull = "spell_nature_groundingtotem",
	enrage = "Spell_Shadow_UnholyFrenzy",
	polarityShift = "Spell_Nature_Lightning",
	positive = "Spell_ChargePositive",
	negative = "Spell_ChargeNegative",
	taunt = "spell_nature_reincarnation",
	phase2 = "Inv_misc_pocketwatch_01",
}

local syncName = {
	powerSurge = "StalaggPower"..module.revision,
	magneticPull = "ThaddiusMagneticPull"..module.revision,
	addsDead = "ThaddiusAddsDead"..module.revision,
	teslaOverload = "ThaddiusTeslaOverload"..module.revision,
	phase2 = "ThaddiusPhaseTwo"..module.revision,
	enrage = "ThaddiusEnrage"..module.revision,
	polarityShiftCast = "ThaddiusPolarityShiftCast"..module.revision,
	polarity = "ThaddiusPolarity"..module.revision,
}

local phase2started = nil
local theyAreDead = 0
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["start_trigger"])
module:RegisterYellEngage(L["start_trigger1"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "CheckEmotes")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "CheckEmotes")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	self:ThrottleSync(4, syncName.powerSurge)
	self:ThrottleSync(5, syncName.magneticPull)
	self:ThrottleSync(20, syncName.addsDead)
	self:ThrottleSync(10, syncName.teslaOverload)
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(20, syncName.phase2)
	self:ThrottleSync(10, syncName.polarityShiftCast)
	self:ThrottleSync(10, syncName.polarity)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
	phase2started = nil
	theyAreDead = 0
	self.started = nil
	self.transition = nil
	self.previousCharge = ""
	self.feugenHP = 100
	self.stalaggHP = 100
end

function module:OnEngage()
	self.feugenHP = 100
	self.stalaggHP = 100
	self:TriggerEvent("BigWigs_StartHPBar", self, L["feugen"], 100)
	self:TriggerEvent("BigWigs_SetHPBar", self, L["feugen"], 0)
	self:TriggerEvent("BigWigs_StartHPBar", self, L["stalagg"], 100)
	self:TriggerEvent("BigWigs_SetHPBar", self, L["stalagg"], 0)
	self:ScheduleRepeatingEvent("bwThaddiusAddCheck", self.CheckAddHP, 0.5, self )
	if self.db.profile.magneticPull then
		self:MagneticPull()
	end
end

function module:OnDisengage()
end

function module:CheckAddHP()
	local feugenHealth
	local stalaggHealth
	if UnitName("playertarget") == L["feugen"] then
		feugenHealth = math.ceil((UnitHealth("playertarget") / UnitHealthMax("playertarget")) * 100)
	elseif UnitName("playertarget") == L["stalagg"] then
		stalaggHealth = math.ceil((UnitHealth("playertarget") / UnitHealthMax("playertarget")) * 100)
	end
	for i = 1, GetNumRaidMembers(), 1 do
		if UnitName("Raid"..i.."target") == L["feugen"] then
			feugenHealth = math.ceil((UnitHealth("Raid"..i.."target") / UnitHealthMax("Raid"..i.."target")) * 100)
		elseif UnitName("Raid"..i.."target") == L["stalagg"] then
			stalaggHealth = math.ceil((UnitHealth("Raid"..i.."target") / UnitHealthMax("Raid"..i.."target")) * 100)
		end
		if feugenHealth and stalaggHealth then break; end
	end
	if feugenHealth then
		self.feugenHP = feugenHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, L["feugen"], 100-self.feugenHP)
	end
	if stalaggHealth then
		self.stalaggHP = stalaggHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, L["stalagg"], 100-self.stalaggHP)
	end
end

function module:PLAYER_AURAS_CHANGED(msg)
	local chargetype = nil
	local iIterator = 1
	while UnitDebuff("player", iIterator) do
		local texture, applications = UnitDebuff("player", iIterator)
		if texture == L["positivetype"] or texture == L["negativetype"] then
			if applications > 1 then
				return
			end
			chargetype = texture
		end
		iIterator = iIterator + 1
	end
	if not chargetype then return end
	self:UnregisterEvent("PLAYER_AURAS_CHANGED")
	self:NewPolarity(chargetype)
end

function module:NewPolarity(chargetype)
	if self.db.profile.charge then
		if self.previousCharge and self.previousCharge == chargetype then
			self:Message(L["nochange"], "Urgent", true, "Long")
		elseif chargetype == L["positivetype"] then
			self:Message(L["poswarn"], "Positive", true, "RunAway")
			self:Bar(L["polaritytickbar"], timer.polarityTick, icon.positive, true, "blue")
			self:WarningSign(icon.positive, 5)
		elseif chargetype == L["negativetype"] then
			self:Message(L["negwarn"], "Important", true, "RunAway")
			self:Bar(L["polaritytickbar"], timer.polarityTick, icon.negative, true, "red")
			self:WarningSign(icon.negative, 5)
		end
	end
	self.previousCharge = chargetype
end

function module:Event(msg)
	if string.find(msg, L["powerSurge_trigger"]) then
		self:Sync(syncName.powerSurge)
	end
	if string.find(msg, L["magneticPull_trigger"]) then
		self:Sync(syncName.magneticPull)
	end
	if string.find(msg, L["polarityShiftCast_trigger"]) then
		self:Sync(syncName.polarityShiftCast)
	end
	BigWigs:CheckForBossDeath(msg, self)
	if string.find(msg, L["stalaggDead_trigger"]) or string.find(msg, L["feugenDead_trigger"]) then
		theyAreDead = theyAreDead + 1
		if theyAreDead == 2 then
			self:Sync(syncName.addsDead)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["polarityShift_trigger"]) then
		self:Sync(syncName.polarity)
	elseif string.find(msg, L["phase2_trigger1"]) or string.find(msg, L["phase2_trigger2"]) or string.find(msg, L["phase2_trigger3"]) then
		self:Sync(syncName.phase2)
	end
end

function module:CheckEmotes(msg)
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["teslaOverload_trigger"]) then
		self:Sync(syncName.teslaOverload)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.powerSurge and self.db.profile.power then
		self:PowerSurge()
	elseif sync == syncName.magneticPull and self.db.profile.magneticPull then
		self:MagneticPull()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.addsDead and self.db.profile.phase then
		self:AddsDead()
	elseif sync == syncName.teslaOverload and self.db.profile.phase then
		self:TeslaOverload()
	elseif sync == syncName.phase2 then
		self:Phase2()
	elseif sync == syncName.polarity and self.db.profile.polarity then
		self:PolarityShift()
	elseif sync == syncName.polarityShiftCast and self.db.profile.polarity then
		self:PolarityShiftCast()
	end
end

function module:PowerSurge()
	self:Message(L["powerSurge_warn"], "Important")
	self:Bar(L["powerSurge_bar"], timer.powerSurge, icon.powerSurge, true, "red")
end

function module:MagneticPull()
	self:Bar(L["magneticPull_Bar"], timer.magneticPull, icon.magneticPull, true, "blue")
	self:DelayedMessage(timer.magneticPull - 5, L["magneticPull_warn"], "Urgent")
	if playerClass == "WARRIOR" then
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.magneticPull - 3, icon.taunt, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.magneticPull - 3, "Info")
		end
	end
end

function module:AddsDead()
	self:RemoveBar(L["magneticPull_Bar"])
	self:RemoveBar(L["powerSurge_bar"])
	self:CancelDelayedWarningSign(icon.taunt)
	self:CancelDelayedSound("Info")
	self:CancelDelayedMessage(L["magneticPull_warn"])
	self:Message(L["phase2_14sec_warn"], "Urgent")
	self:Message(L["polarityPosition_warn"], nil, nil)
end

function module:TeslaOverload()
	self:Bar(L["phase2_bar"], timer.phase2, icon.phase2, true, "black")
	self:Message(L["phase2_warn"], "Attention")
	self:Message(L["polarityPosition_warn"], nil, nil)
	self:Phase2reset()
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Important")
	self:RemoveBar(L["enrage_bar"])
	self:CancelDelayedMessage(L["enrage60sec_warn"])
	self:CancelDelayedMessage(L["enrage30sec_warn"])
	self:CancelDelayedMessage(L["enrage10sec_warn"])
end

function module:PolarityShiftCast()
	self:RemoveBar(L["polarityShiftCD_bar"])
	self:RemoveBar(L["polarityShiftSoon_bar"])
	self:CancelDelayedBar(L["polarityShiftSoon_bar"])
	self:Message(L["polarityShiftCast_warn"], "Important")
	self:Bar(L["polarityShiftCast_bar"], timer.polarityShiftCast, icon.polarityShift, true, "green")
end

function module:PolarityShift()
	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:DelayedMessage(timer.polarityShiftCD, L["polarityShiftSoon_warn"], "Important", nil, "Beware")
	self:DelayedBar(timer.polarityShiftCD, L["polarityShiftSoon_bar"], timer.polarityShiftSoon, icon.polarityShift, true, "green")
	self:Bar(L["polarityShiftCD_bar"], timer.polarityShiftCD, icon.polarityShift, true, "green")
end

function module:Phase2()
	if phase2started then return end
	phase2started = true
	self:Phase2reset()
	if self.db.profile.enrage then
		self:Bar(L["enrage_bar"], timer.enrage, icon.enrage, true, "white")
		self:DelayedMessage(timer.enrage - 60, L["enrage60sec_warn"], "Urgent")
		self:DelayedMessage(timer.enrage - 30, L["enrage30sec_warn"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["enrage10sec_warn"], "Important")
	end
	self:Bar(L["polarityShiftSoon_bar"], timer.polarityShiftSoon, icon.polarityShift, true, "green")
end

function module:Phase2reset()
	self:RemoveBar(L["magneticPull_Bar"])
	self:RemoveBar(L["powerSurge_bar"])
	self:CancelDelayedWarningSign(icon.taunt)
	self:CancelDelayedSound("Info")
	self:CancelDelayedMessage(L["magneticPull_warn"])
	self:CancelScheduledEvent("bwthaddiusthrow")
	self:TriggerEvent("BigWigs_StopHPBar", self, L["feugen"])
	self:TriggerEvent("BigWigs_StopHPBar", self, L["stalagg"])
	self:CancelScheduledEvent("bwThaddiusAddCheck")
	self:KTM_Reset()
end
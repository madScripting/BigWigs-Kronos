
local module, L = BigWigs:ModuleDeclaration("C'Thun", "Ahn'Qiraj")

module.revision = 20045
local eyeofcthun = AceLibrary("Babble-Boss-2.2")["Eye of C'Thun"]
local cthun = AceLibrary("Babble-Boss-2.2")["C'Thun"]
module.enabletrigger = {eyeofcthun, cthun}
module.toggleoptions = {"gnpp", -1, "tentacle", "glare", "group", -1, "giant", "acid", "weakened", "sound", -1, "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Cthun",

	barStartRandomBeams = "Start of Random Beams!",

	eye_beam_trigger = "Giant Eye Tentacle begins to cast Eye Beam.",
	eye_beam_trigger_cthun = "Eye of C'Thun begins to cast Eye Beam.",
	eyebeam		= "Eye Beam on %s",
	Unknown = "Unknown", -- Eye Beam on Unknown

	gnpp_cmd = "gnpp",
	gnpp_name = "GNPP Alert",
	gnpp_desc = "Warns to use GNPP",
	
	tentacle_cmd = "tentacle",
	tentacle_name = "Tentacle Alert",
	tentacle_desc = "Warn for Tentacles",
	tentacle	= "Small Eyes - 5 sec",
	barTentacle	= "Small Eyes!",

	glare_cmd = "glare",
	glare_name = "Dark Glare Alert",
	glare_desc = "Warn for Dark Glare",
	
	glare		= "Dark Glare!",
	barGlare	= "Next Dark Glare",
	barGlareEnds = "Dark Glare ends",
	barGlareCasting = "Casting Dark Glare",

	group_cmd = "group",
	group_name = "Dark Glare Group Warning",
	group_desc = "Warn for Dark Glare on Group X",

	phase2starting	= "The Eye is dead! Body incoming!",

	playersInStomach = "Players in Stomach",

	giant_cmd = "giant",
	giant_name = "Giant Eye Alert",
	giant_desc = "Warn for Giant Eyes",
	barGiant	= "Giant Eye!",
	barGiantC	= "Giant Claw!",
	GiantEye = "Giant Eye Tentacle in 5 sec!",
	gedownwarn	= "Giant Eye down!",
	gcdownwarn = "Giant Claw down!",

	weakened_cmd = "weakened",
	weakened_name = "Weakened Alert",
	weakened_desc = "Warn for Weakened State",
	weakenedtrigger = "is weakened!",
	weakened	= "C'Thun is weakened for 45 sec",
	invulnerable2	= "Party ends in 5 seconds",
	invulnerable1	= "Party over - C'Thun invulnerable",
	barWeakened	= "C'Thun is weakened!",

	acid_cmd = "acid",
	acid_name = "Digestive Acid alert",
	acid_desc = "Shows a warning sign when you have 5 stacks of digestive acid",
	digestiveAcidTrigger = "You are afflicted by Digestive Acid [%s%(]*([%d]*).",
	msgDigestiveAcid = "5 Acid Stacks",

	sound_cmd = "sound",
	sound_name = "Sound",
	sound_desc = "Play sound on proximity.",
	
	tentacleName = "Flesh Tentacle",
	
	text_tooClose = "|cffcccccc-- Too Close --",
	text_inStomach = "|cffcccccc-- In Stomach --",
	text_stomachTentacles = "|cffcccccc-- Stomach Tentacles --",
	text_dead = "|cffff0000Dead",
	text_tentacle = "|cffccccccTentacle",
	text_nobody ="|cff777777Nobody",
	text_weakened ="|cffff00ffWeakened",
	
	naturedmg_trigger = "Eye Beam hits you for",
	naturedmg_trigger2 = "Nature damage from your Digestive Acid",
	
	window_bar = "Window of Opportunity",
	g1 = "Groups 1 GO!",
	g2 = "Groups 2",
	g3 = "Groups 3",
	g4 = "Groups 4",
	
	NRfade = "Nature Protection  fades from you.",
	NRup = "You gain Nature Protection .",
	
	["Big Wigs Cthun Assist"] = true,
} end )

local timer = {
	nextspawn = 28,
	g2 = 2,
	g3 = 4,
	g4 = 6,
	
	potioncd = 120,
	
    p1RandomEyeBeams = 10, --was 9
    p1Tentacle = 45,
    p1TentacleStart = 45,
    p1GlareCD = 44, --was 45.5, then was 45
    --p1Glare = 84, --interval between glares, was 85.5
    p1GlareCasting = 4,
    p1GlareDuration = 36,

	p2Tentacle = 30, 
	p2ETentacle = 60,
	p2GiantClaw = 60,
	p2FirstGiantClaw = 10,
	p2FirstGiantEye = 40,
	
	p2FirstEyeTentacles = 40,
	p2FirstGiantClawAfterWeaken = 0,
	p2FirstGiantEyeAfterWeaken = 30,
	p2FirstEyeAfterWeaken = 30,

	reschedule = 50,      -- delay from the moment of weakening for timers to restart
	target = 1,           -- delay for target change checking on Eye of C'Thun and Giant Eye Tentacle

	weakened = 45,

	eyeBeam = 2,
}

local icon = {
	window = "inv_misc_pocketwatch_01",
	g2 = "inv_misc_pocketwatch_01",
	g3 = "inv_misc_pocketwatch_01",
	g4 = "inv_misc_pocketwatch_01",
	
	giantEye = "inv_misc_eye_01",
	giantClaw = "Spell_Nature_Earthquake",
	eyeTentacles = "spell_shadow_siphonmana",
	darkGlare = "Inv_misc_ahnqirajtrinket_04",
	weaken = "INV_ValentinesCandy",
	eyeBeamSelf = "Ability_creature_poison_05",
	digestiveAcid = "ability_creature_disease_02",
	gnpp = "inv_potion_22",
}

local syncName = {
	p2Start = "CThunP2Start"..module.revision,
	weaken = "CThunWeakened"..module.revision,
	weakenOver = "CThunWeakenedOver"..module.revision,
	tentacleSpawn = "TentacleSpawn"..module.revision,
	eyeBeam = "CThunEyeBeam"..module.revision,
	fleshTentacleDead = "FleshTentacleDead"..module.revision,
	giantClawSpawn = "GiantClawSpawn"..module.revision,
	giantClawDown = "GiantClawDown"..module.revision,
	giantEyeDown = "CThunGEdown"..module.revision,
	giantEyeSpawn = "GiantEyeSpawn"..module.revision,
	darkGlare = "CThunDarkGlare"..module.revision,
}

local giantclaw = "Giant Claw Tentacle"
local gianteye = "Giant Eye Tentacle"
local giantclaw = "Giant Claw Tentacle"
local cthunstarted = nil
local phase2started = nil
local firstGlare = nil
local firstWarning = nil
local tentacletime = timer.p1Tentacle
local isWeakened = nil
local doCheckForWipe = false
local eyeTarget = nil
local tablet = AceLibrary("Tablet-2.0")
local paintchips = AceLibrary("PaintChips-2.0")
local roster = nil
local lastplayed = 0
local playername = nil
local tentacleDead = false
local tentacleHP = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Event") 
	
	self:ThrottleSync(20, syncName.p2Start)
	self:ThrottleSync(50, syncName.weaken)
	self:ThrottleSync(3, syncName.giantEyeDown)
	self:ThrottleSync(3, syncName.giantClawDown)
	self:ThrottleSync(60, syncName.weakenOver)
	self:ThrottleSync(25, syncName.giantClawSpawn)
	self:ThrottleSync(25, syncName.giantEyeSpawn)
	self:ThrottleSync(25, syncName.tentacleSpawn)
	self:ThrottleSync(25, syncName.darkGlare)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self.started = nil
	self.warning = 100
	eyeTarget = nil
	cthunstarted = nil
	firstGlare = nil
	firstWarning = nil
	phase2started = nil
	doCheckForWipe = false
	tentacletime = timer.p1Tentacle
	lastplayed = 0
	playername = UnitName("player")
	tentacleDead = false
	tentacleHP = "|cff777777??"
end

function module:OnEngage()
	self:CThunStart()
	if not roster then roster = AceLibrary("RosterLib-2.0") end
	self:ShowTablet()
	firstgreenbeam = true
	encounterstart = true
	glareTimerOn = false
	nextpot = GetTime()+10
end

function module:OnDisengage()
	roster = nil
	self:HideTablet()
end

function module:Event(msg)
	local _, _, stacks = string.find(msg, L["digestiveAcidTrigger"])
	if stacks then
		self:DebugMessage("Digestive Acid Stacks: " .. stacks)
		if tonumber(stacks) == 5 then
			self:DigestiveAcid()
		end
	end
	if string.find(msg, L["NRfade"]) or string.find(msg, L["naturedmg_trigger"]) or string.find(msg, L["naturedmg_trigger2"]) then
		now = GetTime()
		if now > nextpot then
			if self.db.profile.gnpp then
				self:WarningSign(icon.gnpp, 1)
			end
		end
	end
	if string.find(msg, L["NRup"]) then
		nextpot = timer.potioncd + GetTime()
	end
	if string.find(msg, L["eye_beam_trigger_cthun"]) and glareTimerOn == false then
		self:Sync(syncName.darkGlare)
		if encounterstart == true then
			self:Bar(L["barStartRandomBeams"], timer.p1RandomEyeBeams, icon.giantEye)
			encounterstart = false
		end
	end
	if string.find(msg, L["eye_beam_trigger"]) then
		self:DebugMessage("Eye Beam trigger")
		self:Sync(syncName.eyeBeam)
	end
	if string.find(msg, L["eye_beam_trigger_cthun"]) then
		self:DebugMessage("C'Thun Eye Beam trigger")
		self:Sync(syncName.eyeBeam)
		if not cthunstarted then
			self:SendEngageSync()
		end
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if (msg == string.format(UNITDIESOTHER, eyeofcthun)) then
		self:Sync(syncName.p2Start)
	elseif (msg == string.format(UNITDIESOTHER, gianteye)) then
		self:Sync(syncName.giantEyeDown)
	elseif (msg == string.format(UNITDIESOTHER, giantclaw)) then
		self:Sync(syncName.giantClawDown)
	elseif msg == string.format(UNITDIESOTHER, L["tentacleName"]) then
		self:Sync(syncName.fleshTentacleDead)
	end
end

function module:CheckForWipe(event)
	if doCheckForWipe then
		BigWigs:DebugMessage("doCheckForWipe")
		BigWigs:CheckForWipe(self)
	end
end

function module:Emote( msg )
	if string.find(msg, L["weakenedtrigger"]) then
		self:Sync(syncName.weaken)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.p2Start then
		self:CThunP2Start()
	elseif sync == syncName.weaken then
		self:CThunWeakened()
		self:ScheduleEvent("resetTentacles", function()
			tentacleDead = false
			tentacleHP = "|cff777777??"
		end, 45)
	elseif sync == syncName.weakenOver then
		self:CThunWeakenedOver()
	elseif sync == syncName.eyeBeam then
		self:EyeBeam()
	elseif sync == syncName.tentacleSpawn then
		self:SmallEyes()
	elseif sync == syncName.fleshTentacleDead then
		tentacleDead = true
		tentacleHP = "|cff777777??"
	elseif sync == syncName.giantClawSpawn then
		lastspawn = GetTime()
		self:GCTentacle()
		elseif sync == syncName.giantClawDown then
		self:Message(L["gcdownwarn"], "Positive")
		local window = (lastspawn + timer.nextspawn) - GetTime()
		if window > 0 then
			self:Bar(L["window_bar"], window, icon.window, true, "white")
		end
		elseif sync == syncName.giantEyeSpawn then
		lastspawn = GetTime()
		self:GTentacle()
		elseif sync == syncName.giantEyeDown then
		self:Message(L["gedownwarn"], "Positive")
		local window = (lastspawn + timer.nextspawn) - GetTime()
		if window > 0 then
			self:Bar(L["window_bar"], window, icon.window, true, "green", "white")
		end
	elseif sync == syncName.darkGlare and self.db.profile.glare then
		self:DarkGlare()
	end
end

function module:CThunStart()
	self:DebugMessage("CThunStart: ")
	if not cthunstarted then
		cthunstarted = true
		doCheckForWipe = true
		firstWarning = true
		if self.db.profile.tentacle then
			self:Bar(L["barTentacle"], timer.p1TentacleStart, icon.eyeTentacles, true, "blue")
			self:DelayedMessage(timer.p1TentacleStart - 5, L["tentacle"], "Urgent", false, "Alert")
		end
		self:DelayedSync(timer.p1TentacleStart, syncName.tentacleSpawn)
		self:ScheduleRepeatingEvent("bwcthuntarget", self.CheckTarget, timer.target, self)
	end
end

function module:DelayedEyeBeamCheck()
	local name = L["Unknown"]
	self:CheckTarget()
	if eyeTarget then
		name = eyeTarget
		if firstgreenbeam == true then
			self:Message(L["g1"], "Attention")
			self:Bar(L["g2"], timer.g2, icon.g2, true, "white")
			self:Bar(L["g3"], timer.g3, icon.g3, true, "white")
			self:Bar(L["g4"], timer.g4, icon.g4, true, "white")
			firstgreenbeam = false
		end
		if name == UnitName("player") then
			self:RemoveWarningSign(icon.gnpp)
			self:WarningSign(icon.eyeBeamSelf, 2 - 0.1)
		end
	end
	self:Bar(string.format(L["eyebeam"], name), timer.eyeBeam - 0.1, icon.giantEye, true, "green")
end

function module:EyeBeam()
	self:ScheduleEvent("CThunDelayedEyeBeamCheck", self.DelayedEyeBeamCheck, 0.1, self)
end

function module:DarkGlare()
	glareTimerOn = true
	self:Bar(L["barGlare"], timer.p1GlareCD, icon.darkGlare, true, "red")

	self:DelayedMessage(timer.p1GlareCD, L["glare"], "Urgent", true, false)	
	self:DelayedBar(timer.p1GlareCD, L["barGlareCasting"], timer.p1GlareCasting, icon.darkGlare, true, "red")
	self:DelayedWarningSign(timer.p1GlareCD, icon.darkGlare, 0.7)
	
	self:DelayedBar(timer.p1GlareCD + timer.p1GlareCasting, L["barGlareEnds"], timer.p1GlareDuration, icon.darkGlare, true, "red")

	self:ScheduleEvent("glareTimerOff", self.glareTimerOff, timer.p1GlareCD+30, self )
end

function module:glareTimerOff()
	glareTimerOn = false
end

function module:CThunP2Start()
	if not phase2started then
		phase2started = true
		doCheckForWipe = false
		tentacletime = timer.p2Tentacle
		self:Message(L["phase2starting"], "Bosskill")

		self:RemoveBar(L["barGlare"] )
		self:RemoveBar(L["barGlareCasting"])
		self:RemoveBar(L["barGlareEnds"])
		self:RemoveWarningSign(icon.darkGlare)
		
		self:CancelDelayedBar(L["barGlareCasting"])
		self:CancelDelayedBar(L["barGlareEnds"])
		self:CancelDelayedWarningSign(icon.darkGlare)
		self:CancelDelayedMessage(L["glare"])
		self:CancelScheduledEvent("glareTimerOff")
		
		self:RemoveBar(L["barTentacle"] )
		self:CancelDelayedMessage(L["tentacle"])
		self:CancelDelayedSync(syncName.tentacleSpawn)
		-- cancel dark glare group warning
		self:CancelScheduledEvent("bwcthuntarget")
		self:RemoveBar(L["barStartRandomBeams"] )
		-- start P2 events
		if self.db.profile.tentacle then
			-- first eye tentacles
			self:DelayedMessage(timer.p2FirstEyeTentacles - 5, L["tentacle"], "Urgent", false, nil, true)
			self:Bar(L["barTentacle"], timer.p2FirstEyeTentacles, icon.eyeTentacles, true, "blue")
		end
		if self.db.profile.giant then
			self:Bar(L["barGiant"], timer.p2FirstGiantEye, icon.giantEye, true, "green")
			self:DelayedMessage(timer.p2FirstGiantEye - 5, L["GiantEye"], "Urgent", false, nil, true)

			self:Bar(L["barGiantC"], timer.p2FirstGiantClaw, icon.giantClaw, true, "yellow")
		end
		self:DelayedSync(timer.p2FirstEyeTentacles, syncName.tentacleSpawn)
		self:DelayedSync(timer.p2FirstGiantEye, syncName.giantEyeSpawn)
		self:DelayedSync(timer.p2FirstGiantClaw, syncName.giantClawSpawn)
		self:ScheduleRepeatingEvent("bwcthuntargetp2", self.CheckTarget, timer.target, self )
	end
end

function module:CThunWeakened()
	isWeakened = true
	self.warning = 100
	self:ThrottleSync(0.1, syncName.weakenOver)
	if self.db.profile.weakened then
		self:Message(L["weakened"], "Positive" )
		self:Sound("Murloc")
		self:Bar(L["barWeakened"], timer.weakened, icon.weaken, true, "purple")
		self:DelayedMessage(timer.weakened - 5, L["invulnerable2"], "Urgent")
	end
	-- cancel tentacle timers
	self:CancelDelayedMessage(L["tentacle"])
	self:CancelDelayedMessage(L["GiantEye"])
	self:CancelDelayedSync(syncName.giantEyeSpawn)
	self:CancelDelayedSync(syncName.giantClawSpawn)
	self:CancelDelayedSync(syncName.tentacleSpawn)
	self:RemoveBar(L["barTentacle"])
	self:RemoveBar(L["barGiant"])
	self:RemoveBar(L["barGiantC"])
	self:RemoveBar(L["window_bar"])
	self:DelayedSync(timer.weakened, syncName.weakenOver)
	-- next giant claw after weaken
	self:DelayedBar(timer.weakened - 7, L["barGiantC"], 7, icon.giantClaw)
	self:DelayedSync(timer.weakened, syncName.giantClawSpawn)
end

function module:CThunWeakenedOver()
	isWeakened = nil
	self:ThrottleSync(60, syncName.weakenOver)
	self:CancelDelayedSync(syncName.weakenOver) -- ok
	if self.db.profile.weakened then
		self:RemoveBar(L["barWeakened"])
		self:CancelDelayedMessage(L["invulnerable2"])
		self:Message(L["invulnerable1"], "Important")
	end
	-- next giant eye 30s after weaken
	self:Bar(L["barGiant"], timer.p2FirstGiantEyeAfterWeaken, icon.giantEye, true, "green")
	self:DelayedSync(timer.p2FirstGiantEyeAfterWeaken, syncName.giantEyeSpawn)
	self:DelayedMessage(timer.p2FirstGiantEyeAfterWeaken - 5, L["GiantEye"], "Urgent", false, nil, true)
	--next small eyes
	self:Bar(L["barTentacle"], timer.p2FirstEyeAfterWeaken, icon.eyeTentacles, true, "blue")
	self:DelayedSync(timer.p2FirstEyeAfterWeaken, syncName.tentacleSpawn)
	self:DelayedMessage(timer.p2FirstEyeAfterWeaken - 5, L["tentacle"], "Urgent", false, nil, true)
end

function module:DigestiveAcid()
	if self.db.profile.acid then
		self:Message(L["msgDigestiveAcid"], "Red", true, "RunAway")
		self:RemoveWarningSign(icon.gnpp)
		self:WarningSign(icon.digestiveAcid, 5)
	end
end

-----------------------
-- Utility Functions --
-----------------------
function module:CheckTarget()
	local i
	local newtarget = nil
	local enemy = eyeofcthun
	if phase2started then
		enemy = gianteye
	end
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
		eyeTarget = newtarget
	end
end

-- P2
function module:GTentacle()
	self:DelayedSync(timer.p2ETentacle, syncName.giantEyeSpawn)
	if self.db.profile.giant then
		self:Bar(L["barGiant"], timer.p2ETentacle, icon.giantEye, true, "green")
		self:DelayedMessage(timer.p2ETentacle - 5, L["GiantEye"], "Urgent", false, nil, true)
	end
end

function module:GCTentacle()
	doCheckForWipe = true
	self:DelayedSync(timer.p2GiantClaw, syncName.giantClawSpawn)
	self:KTM_Reset()
	if self.db.profile.giant then
		self:Bar(L["barGiantC"], timer.p2GiantClaw, icon.giantClaw, true, "yellow")
	end
end

function module:SmallEyes()
	self:DelayedSync(tentacletime, syncName.tentacleSpawn)
	if self.db.profile.tentacle then
		self:Bar(L["barTentacle"], tentacletime, icon.eyeTentacles, true, "blue")
		self:DelayedMessage(tentacletime - 5, L["tentacle"], "Urgent", false, nil, true)
	end
end

------------------------------
--      Tablet              --
------------------------------
function module:OnTooltipUpdate()
	if not tablet:IsRegistered("BigWigsCthunAssist") then return end
	-- build tablet
	local cat_proximity = tablet:AddCategory(
		'columns', 1,
		'text', L["text_tooClose"],
		'justify', "CENTER",
		'child_justify', "CENTER"
	)
	local cat_stomach
	local cat_tentacleHeader
	local cat_tentacle
	if phase2started then
		cat_stomach = tablet:AddCategory(
			'columns', 1,
			'text', L["text_inStomach"],
			'justify', "CENTER",
			'child_justify', "CENTER"
		)
		cat_tentacleHeader = tablet:AddCategory(
			'columns', 1,
			'text', L["text_stomachTentacles"],
			'justify', "CENTER",
			'showWithoutChildren', true
		)
		cat_tentacle = tablet:AddCategory(
			'columns', isWeakened and 1 or 2,
			'child_justify', "CENTER",
			'hideBlankLine', true
		)
	end
	-- iterate roster
	local tooclose = 0
	local added = false
	local tentacleTargeted = false
	for unit in roster:IterateRoster() do
		-- proximity
		if tooclose < 5 then
			if (not UnitIsDeadOrGhost(unit.unitid)) and (unit.name ~= playername) and CheckInteractDistance(unit.unitid, 2) then
				cat_proximity:AddLine('text', "|cff"..paintchips:GetHex(unit.class)..unit.name.."|r")
				tooclose = tooclose + 1
			end
		end
		if phase2started then
			-- stomach debuff
			for a=1,16 do
				local t = UnitDebuff(unit.unitid, a)
				if not t then break end
				if t == "Interface\\Icons\\Ability_Creature_Disease_02" then
					cat_stomach:AddLine('text', "|cff"..paintchips:GetHex(unit.class)..unit.name.."|r")
					added = true
					-- tentacle scan
					if not tentacleTargeted then
						local raidUnit = unit.unitid.."target"
						if UnitExists(raidUnit) and (UnitName(raidUnit) == L["tentacleName"]) and (not UnitIsDead(raidUnit)) then
							tentacleHP = math.ceil((UnitHealth(raidUnit) / UnitHealthMax(raidUnit)) * 100)
							tentacleTargeted = true
						end
					end
					
					break
				end
			end
		elseif tooclose >= 5 then
			break
		end
	end
	-- fill out tablet
	-- proximity
	if tooclose == 0 then
		cat_proximity:AddLine('text', L["text_nobody"])
	elseif self.db.profile.sound then
		local t = time()
		if t > lastplayed + 1 then
			lastplayed = t
			if UnitAffectingCombat("player") then
				self:TriggerEvent("BigWigs_Sound", "Beep")
			end
		end
	end
	if phase2started then
		-- Stomach
		if not added then
			cat_stomach:AddLine('text', L["text_nobody"])
		end
		-- Stomach Tentacles
		if isWeakened then
			cat_tentacle:AddLine('text', L["text_weakened"])
		else
			local hp = tentacleHP.."%"
			local other = "|cff777777??%"
			
			if tentacleTargeted then
				hp = "|cff00ff00"..hp
			else
				hp = "|cff777777"..hp
			end
			if tentacleDead then
				other = L["text_dead"]
			end
			cat_tentacle:AddLine(
				'text', L["text_tentacle"].." 1:",
				'text2', (tentacleDead and other) or hp
			)
			cat_tentacle:AddLine(
				'text', L["text_tentacle"].." 2:",
				'text2', (tentacleDead and hp) or other
			)
		end
	end
end

function module:ShowTablet()
	if not tablet:IsRegistered("BigWigsCthunAssist") then
		tablet:Register("BigWigsCthunAssist",
			"children",
				function()
					tablet:SetTitle(L["Big Wigs Cthun Assist"])
					self:OnTooltipUpdate()
				end,
			"clickable", true,
			"showTitleWhenDetached", true,
			"showHintWhenDetached", true,
			"cantAttach", true
		)
	end
	if not self:IsEventScheduled("bwcthunassistupdate") then
		self:ScheduleRepeatingEvent("bwcthunassistupdate", function() tablet:Refresh("BigWigsCthunAssist") end, .1)
	end
	if tablet:IsAttached("BigWigsCthunAssist") then
		tablet:Detach("BigWigsCthunAssist")
	end
end

function module:HideTablet()
	if not tablet:IsRegistered("BigWigsCthunAssist") then return end
	self:CancelScheduledEvent("bwcthunassistupdate")
	tablet:Attach("BigWigsCthunAssist")
end

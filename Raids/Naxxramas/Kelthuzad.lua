
local module, L = BigWigs:ModuleDeclaration("Kel'Thuzad", "Naxxramas")

module.revision = 20051
module.enabletrigger = module.translatedName
module.toggleoptions = {"frostbolt", -1, "frostblast", "icon", "proximity", "fissure", "mindControl", -1, "detonate", "detonateicon", -1 ,"guardians", -1, "addcount", "phase", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Kelthuzad",

	KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzad Chamber",

	phase_cmd = "phase",
	phase_name = "Phase Warnings",
	phase_desc = "Warn for phases.",
	
	icon_cmd = "icon",
	icon_name = "Place Raid Icon",
	icon_desc = "Place Raid Icon on the Detonate Mana target.",

	mindControl_cmd = "mindControl",
	mindControl_name = "Mind Control",
	mindControl_desc = "Alerts when people are mind controlled.",

	fissure_cmd = "fissure",
	fissure_name = "Shadow Fissure",
	fissure_desc = "Alerts about incoming Shadow Fissures.",

	frostblast_cmd = "frostblast",
	frostblast_name = "Frost Blast",
	frostblast_desc = "Alerts when people get Frost Blasted.",

	frostbolt_cmd = "frostbolt",
	frostbolt_name = "Frostbolt Alert",
	frostbolt_desc = "Alerts about incoming Frostbolts",

	detonate_cmd = "detonate",
	detonate_name = "Detonate Mana Warning",
	detonate_desc = "Warns about Detonate Mana soon.",

	detonateicon_cmd = "detonateicon",
	detonateicon_name = "Raid Icon on Detonate",
	detonateicon_desc = "Place a raid icon on people with Detonate Mana.",

	guardians_cmd = "guardians",
	guardians_name = "Guardian Spawns",
	guardians_desc = "Warn for incoming Icecrown Guardians in phase 3.",

	addcount_cmd = "addcount",
	addcount_name = "P1 Add counter",
	addcount_desc = "Counts number of killed adds in P1",
	
	proximity_cmd = "proximity",
	proximity_name = "Proximity Warning",
	proximity_desc = "Show Proximity Warning Frame",

	you = "You",
	are = "are",

	mindControlEffect_trigger = "(.+) is afflicted by Chains of Kel'Thuzad",
	mc_warning = " Mind Control!",
	mc_bar = "Mind Control CD",
	mindControlEffect_bar = " MC >ClickMe!<",

	start_trigger = "Minions, servants, soldiers of the cold dark, obey the call of Kel'Thuzad!",
	start_trigger1 = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!",
	start_bar = "Phase 1 Timer",

	hit_trigger = "Kel'Thuzad hits",
	hit_trigger2 = "hits Kel'Thuzad",

	phase1_warn = "Phase 1 ends in 20 seconds!",

	phase2_trigger1 = "Pray for mercy!",
	phase2_trigger2 = "Scream your dying breath!",
	phase2_trigger3 = "The end is upon you!",
	phase2_warning = "Phase 2, Kel'Thuzad incoming!",
	phase2_bar = "Kel'Thuzad Active!",

	phase3_soon_warning = "Phase 3 soon!",
	phase3_trigger = "Master! I require aid!",
	phase3_warning = "Phase 3, Guardians incoming!",

	guardians1_bar = "Guardian 1",
	guardians2_bar = "Guardian 2",
	guardians3_bar = "Guardian 3",
	guardians4_bar = "Guardian 4",
	guardians5_bar = "Guardian 5",
	
	fissure_trigger = "cast Shadow Fissure",
	fissure_trigger2 = "casts Shadow Fissure",
	fissure_warning = "Shadow Fissure!",
	fissure_bar = "Shadow Fissure CD",

	frostbolt_trigger = "Kel'Thuzad begins to cast Frostbolt.",
	frostbolt_warning = "Frostbolt! Interrupt!",
	frostbolt_bar = "Frostbolt",

	add_dead_trigger = "(.*) dies",
	add_bar = "%d/14 %s",
	add_bar2 = "%d/10 %s",

	frostblast_trigger = "^([^%s]+) ([^%s]+) afflicted by Frost Blast.",
	frostblast_warning = "Frost Blast!",
	frostblast_soon_message = "Possible Frost Blast in ~5sec!",
	frostblast_bar = "Possible Frost Blast",
	
	phase2_frostblast_warning = "Possible Frost Blast in ~5sec!",
	phase2_mc_warning = "Possible Mind Control in ~5sec!",
	phase2_detonate_warning = "Detonate Mana in ~5sec!",

	detonate_trigger = "^([^%s]+) ([^%s]+) afflicted by Detonate Mana",
	detonate_warning = "Detonate Mana",
	detonate_onme = "Detonate Mana on ",
	detonate_bar = "Detonate Mana - %s",
	detonate_possible_bar = "Detonate Mana",
} end )

module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
module.proximitySilent = true

local timer = {
	phase1 = 310,
	phase2 = 15,
	firstMindControl = {20,60},
	mindControlEffect = 20,
	mindControl = {40,70},
	frostbolt = 2,
	firstFrostblast = 30,
	frostblast = {30,90},
	firstDetonate = 20,
	detonate = 5,
	nextDetonate = {20,25},
	fissure = {10,15},
	guardians = 10,
}

local icon = {
	phase1 = "inv_misc_pocketwatch_01",
	abomination = "inv_misc_organ_05",
	soulWeaver = "spell_shadow_impphaseshift",
	phase2 = "inv_misc_pocketwatch_01",
	mindControl = "Inv_Belt_18",
	sheep = "Spell_Nature_Polymorph",
	frostbolt = "Spell_Frost_FrostBolt02",
	kick = "ability_kick",
	guardians = "inv_misc_ahnqirajtrinket_01",
	frostblast = "Spell_Frost_FreezingBreath",
	detonate = "spell_shadow_antishadow",
	fissure = "Spell_Shadow_CreepingPlague",
}

local syncName = {
	abomination = "KelAddDiesAbom"..module.revision,
	soulWeaver = "KelAddDiesSoul"..module.revision,
	phase2 = "KelPhase2"..module.revision,
	mindControl = "KelMindControl"..module.revision,
	frostbolt = "KelFrostbolt"..module.revision,
	frostblast = "KelFrostBlast"..module.revision,
	detonate = "KelDetonate"..module.revision,
	fissure = "KelFissure"..module.revision,
	phase3 = "KelPhase3"..module.revision,
}

local timeLastFrostboltVolley = 0
local numFrostboltVolleyHits = 0
local numAbominations = 0
local numWeavers = 0
local timePhase1Start = 0
local _, playerClass = UnitClass("player")
local lastMcTime = 0
local mcDelay = 0
local currentTime = 0

module:RegisterYellEngage(L["start_trigger"])
module:RegisterYellEngage(L["start_trigger1"])

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")

	self:ThrottleSync(2, syncName.abomination)
	self:ThrottleSync(2, syncName.soulWeaver)
	self:ThrottleSync(5, syncName.phase2)
	self:ThrottleSync(0, syncName.mindControl)
	self:ThrottleSync(2, syncName.frostbolt)
	self:ThrottleSync(0, syncName.frostblast)
	self:ThrottleSync(2, syncName.fissure)
	self:ThrottleSync(5, syncName.detonate)
	self:ThrottleSync(5, syncName.phase3)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self.warnedAboutPhase3Soon = nil
	frostbolttime = 0
	self.lastFrostBlast=0
end

function module:OnEngage()
	self.lastFrostBlast=0
	self:Bar(L["start_bar"], timer.phase1, icon.phase1, true, "white")
	self:DelayedMessage(timer.phase1 - 20, L["phase1_warn"], "Important")
	if self.db.profile.addcount then
		timePhase1Start = GetTime()
		numAbominations = 0
		numWeavers = 0
		self:Bar(string.format(L["add_bar"], numAbominations, "Unstoppable Abomination"), timer.phase1+10, icon.abomination, true, "red")
		self:Bar(string.format(L["add_bar2"], numWeavers, "Soul Weaver"), timer.phase1+10, icon.soulWeaver, true, "blue")
	end
	lastMcTime = 0
	mcDelay = 0
	currentTime = 0
end

function module:OnDisengage()
	self:RemoveProximity()
	BigWigsFrostBlast:FBClose()
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= L["KELTHUZADCHAMBERLOCALIZEDLOLHAX"] or self.core:IsModuleActive(module.translatedName) then
		return
	end
	self.core:EnableModule(module.translatedName)
end

function module:UNIT_HEALTH(msg)
	if self.db.profile.phase then
		if UnitName(msg) == self.translatedName then
			local health = UnitHealth(msg)
			local maxHealth = UnitHealthMax(msg)
			if math.ceil(100*health/maxHealth) > 35 and math.ceil(100*health/maxHealth) <= 40 and not self.warnedAboutPhase3Soon then
				self:Message(L["phase3_soon_warning"], "Attention")
				self.warnedAboutPhase3Soon = true
			elseif math.ceil(100*health/maxHealth) > 40 and self.warnedAboutPhase3Soon then
				self.warnedAboutPhase3Soon = nil
			end
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if ((msg == L["phase2_trigger1"]) or (msg == L["phase2_trigger2"]) or (msg == L["phase2_trigger3"])) then
		self:Sync(syncName.phase2)
	elseif string.find(msg, L["phase3_trigger"]) then
		self:Sync(syncName.phase3)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	local _,_, mob = string.find(msg, L["add_dead_trigger"])
	if self.db.profile.addcount and (mob == "Unstoppable Abomination") then
		self:Sync(syncName.abomination .. " " .. mob)
	elseif self.db.profile.addcount and (mob == "Soul Weaver") then
		self:Sync(syncName.soulWeaver .. " " .. mob)
	elseif self.db.profile.bosskill and (mob == "Kel'Thuzad") then
		self:SendBossDeathSync()
	end
end

function module:Event(msg)
	if string.find(msg, L["hit_trigger"]) or string.find(msg, L["hit_trigger2"]) then
		if klhtm.target.targetismaster("Kel'Thuzad") ~= true then
			if UnitName("target") == "Kel'Thuzad" and (IsRaidLeader() or IsRaidOfficer()) then
				klhtm.net.sendmessage("target " .. "Kel'Thuzad")
			end
		end
	end
	if string.find(msg, L["mindControlEffect_trigger"]) then
		local _,_,mcPlayer = string.find(msg, L["mindControlEffect_trigger"])
		self:Sync(syncName.mindControl.." "..mcPlayer)
	end
	if string.find(msg, L["frostbolt_trigger"]) then
		self:Sync(syncName.frostbolt)
	end
	if string.find(msg, L["frostblast_trigger"]) then
		local _, _, sPlayer, sType = string.find(msg, L["frostblast_trigger"])
		if ( sPlayer and sType ) then
			if ( sPlayer == "You" and sType == "are" ) then
				self:Sync(syncName.frostblast.." "..UnitName("player"))
			else
				self:Sync(syncName.frostblast.." "..sPlayer)
			end
		end
	end
	if string.find(msg, L["detonate_trigger"]) then
		local _,_, dplayer, dtype = string.find( msg, L["detonate_trigger"])
		if dplayer and dtype then
			if dplayer == L["you"] and dtype == L["are"] then
				dplayer = UnitName("player")
			end
			self:Sync(syncName.detonate .. " ".. dplayer)
		end
	end
	if string.find(msg, L["fissure_trigger"]) or string.find(msg, L["fissure_trigger2"]) then
		self:Sync(syncName.fissure)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.abomination and rest then
		self:AbominationDies(rest)
	elseif sync == syncName.soulWeaver and rest then
		self:WeaverDies(rest)
	elseif sync == syncName.phase2 then
		self:Phase2()
	elseif sync == syncName.mindControl and self.db.profile.mindControl then
		self:MindControl(rest)
	elseif sync == syncName.frostboltVolley and self.db.profile.frostboltVolley then
		self:FrostboltVolley()
	elseif sync == syncName.frostbolt and self.db.profile.frostbolt then
		self:Frostbolt()
	elseif sync == syncName.frostboltOver and self.db.profile.frostbolt then
		self:FrostboltOver()
	elseif sync == syncName.frostblast and self.db.profile.frostblast then
		self:FrostBlast(rest)
	elseif sync == syncName.detonate and self.db.profile.detonate then
		self:Detonate(rest)
	elseif sync == syncName.fissure and self.db.profile.fissure then
		self:Fissure()
	elseif sync == syncName.phase3 and self.db.profile.phase then
		self:Phase3()
	end
end

function module:AbominationDies(name)
	if name and self.db.profile.addcount then
		self:RemoveBar(string.format(L["add_bar"], numAbominations, name))
		numAbominations = numAbominations + 1
		if numAbominations < 14 then
			self:Bar(string.format(L["add_bar"], numAbominations, name), (timePhase1Start + timer.phase1 + 10 - GetTime()), icon.abomination, true, "red")
		end
	end
	self:KTM_Reset()
end

function module:WeaverDies(name)
	if name and self.db.profile.addcount then
		self:RemoveBar(string.format(L["add_bar2"], numWeavers, name))
		numWeavers = numWeavers + 1
		if numWeavers < 10 then
			self:Bar(string.format(L["add_bar2"], numWeavers, name), (timePhase1Start + timer.phase1 + 10 - GetTime()), icon.soulWeaver, true, "blue")
		end
	end
end

function module:Phase2()
	self:Bar(L["phase2_bar"], timer.phase2, icon.phase2, true, "white")
	self:DelayedMessage(timer.phase2, L["phase2_warning"], "Important")
	self:KTM_Reset()
	if self.db.profile.mindControl then
		self:DelayedIntervalBar(timer.phase2, L["mc_bar"], timer.firstMindControl[1], timer.firstMindControl[2], icon.mindControl, true, "red")
		self:DelayedMessage(timer.firstMindControl[1]  + timer.phase2 - 5, L["phase2_mc_warning"], "Important")
	end
	if self.db.profile.detonate then
		self:DelayedBar(timer.phase2, L["detonate_possible_bar"], timer.firstDetonate, icon.detonate, true, "yellow")
		self:DelayedMessage(timer.firstDetonate + timer.phase2 - 5, L["phase2_detonate_warning"], "Important")
	end
	if self.db.profile.frostblast then
		self:DelayedBar(timer.phase2, L["frostblast_bar"], timer.firstFrostblast, icon.frostblast, true, "Blue")
		self:DelayedMessage(timer.firstFrostblast  + timer.phase2 - 5, L["phase2_frostblast_warning"], "Important")
	end
	if self.db.profile.frostboltVolley then
		self:DelayedBar(timer.phase2, L["frostbolt_volley"], timer.firstFrostboltVolley, icon.frostboltVolley, true, "white")
	end
	if self.db.profile.proximity then
		self:ScheduleEvent("bwShowProximity", self.Proximity, timer.phase2, self)
	end
	self:ScheduleEvent("bwShowFBFrame", function() BigWigsFrostBlast:FBShow() end, timer.phase2, self)
	local function removeP1Bars()
		self:RemoveBar(L["start_bar"])
		self:RemoveBar(string.format(L["add_bar2"], numWeavers, "Soul Weaver"))
		self:RemoveBar(string.format(L["add_bar"], numAbominations, "Unstoppable Abomination"))
	end
	self:ScheduleEvent("bwKTremoveP1Bars", removeP1Bars, 1, self)
end

function module:MindControl(rest)
	currentTime = GetTime()
	mcDelay = currentTime - lastMcTime
	if mcDelay < 4 then
		self:Message(L["mc_warning"], "Urgent", nil, "Info")
		self:DelayedIntervalBar(timer.mindControlEffect, L["mc_bar"], timer.mindControl[1], timer.mindControl[2], icon.mindControl, true, "red")
		self:KTM_Reset()
		if playerClass == "MAGE" then
			self:WarningSign(icon.sheep, 0.7)
		end
		if playerClass ~= "MAGE" then
			self:WarningSign(icon.mindControl, 0.7)
		end
	end
	self:Bar(string.format(rest..L["mindControlEffect_bar"]), timer.mindControlEffect, icon.mindControl, true, "red")
	self:SetCandyBarOnClick("BigWigsBar "..string.format(rest..L["mindControlEffect_bar"]), function(name, button, extra) TargetByName(extra, true) end, rest)
	lastMcTime = GetTime()
end

function module:Frostbolt()
	self:Message(L["frostbolt_warning"], "Personal")
	self:Bar(L["frostbolt_bar"], timer.frostbolt, icon.frostbolt, true, "green")
	if playerClass == "WARRIOR" or playerClass == "ROGUE" or playerClass == "MAGE" then
		self:WarningSign(icon.kick, 0.7)
	end
end

function module:FrostBlast(name)
	if GetTime()-self.lastFrostBlast>5 then
		self.lastFrostBlast=GetTime()
		if playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "DRUID" then
			self:WarningSign(icon.frostblast, 0.7)
			self:Message(L["frostblast_warning"], "Attention")
		end
		self:DelayedMessage(timer.frostblast[1] - 5, L["frostblast_soon_message"])
		self:IntervalBar(L["frostblast_bar"], timer.frostblast[1], timer.frostblast[2], icon.frostblast, true, "Blue")
	end
	if name and name ~= "" then
		BigWigsFrostBlast:AddFrostBlastTarget(name)
	end
end

function module:Detonate(name)
	self:Message(L["detonate_warning"], "Attention", nil, nil)
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", name)
		self:ScheduleEvent("BigWigs_RemoveRaidIcon", timer.detonate)
	end
	if UnitName("player") == name then
		self:SendSay(L["detonate_onme"] .. UnitName("player") .. "!")
		self:WarningSign(icon.detonate, 0.7)
		self:Sound("Beware")
	end
	self:Bar(string.format(L["detonate_bar"], name), timer.detonate, icon.detonate, true, "yellow")
	self:IntervalBar(L["detonate_possible_bar"], timer.nextDetonate[1], timer.nextDetonate[2], icon.detonate, true, "yellow")
end

function module:Fissure()
	self:Message(L["fissure_warning"], "Urgent", true, "Alarm")
	self:IntervalBar(L["fissure_bar"], timer.fissure[1], timer.fissure[2], icon.fissure, true, "black")
	self:WarningSign(icon.fissure, 0.7)
end

function module:Phase3()
	self:Message(L["phase3_warning"], "Attention", nil, "Beware")
	if self.db.profile.guardians then
		self:Guardians()
	end
end

function module:Guardians()
	self:Bar(L["guardians1_bar"], timer.guardians, icon.guardians, true, "green")
	self:DelayedBar(timer.guardians, L["guardians2_bar"], timer.guardians, icon.guardians, true, "green")
	self:DelayedBar(2*timer.guardians, L["guardians3_bar"], timer.guardians, icon.guardians, true, "green")
	self:DelayedBar(3*timer.guardians, L["guardians4_bar"], timer.guardians, icon.guardians, true, "green")
	self:DelayedBar(4*timer.guardians, L["guardians5_bar"], timer.guardians, icon.guardians, true, "green")
	if playerClass == "PRIEST" then
		self:DelayedWarningSign(timer.guardians, icon.guardians, 0.7)
		self:DelayedWarningSign(2*timer.guardians, icon.guardians, 0.7)
		self:DelayedWarningSign(3*timer.guardians, icon.guardians, 0.7)
	end
	if playerClass == "WARRIOR" then
		self:DelayedWarningSign(4*timer.guardians, icon.guardians, 0.7)
		self:DelayedWarningSign(5*timer.guardians, icon.guardians, 0.7)
	end
end


local module, L = BigWigs:ModuleDeclaration("High Priestess Jeklik", "Zul'Gurub")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"fire", "silence", "bigicon", "curse", "phase", "heal", "flay", "fear", "swarm", "bomb", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Jeklik",

	phase_cmd = "phase",
	phase_name = "Phase Notification",
	phase_desc = "Announces the boss' phase transition",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for healing",

	flay_cmd = "flay",
	flay_name = "Mind Flay Alert",
	flay_desc = "Warn for casting Mind Flay",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for boss' fear\n\n(Disclaimer: timers vary a lot, usually fear will happen within 10s after the fear bar ends)",

	bomb_cmd = "bomb",
	bomb_name = "Bomb Bat Alert",
	bomb_desc = "Warn for Bomb Bats",

	swarm_cmd = "swarm",
	swarm_name = "Bat Swarm Alert",
	swarm_desc = "Warn for Bat swarms",

	bigicon_cmd = "bigicon",
	bigicon_name = "Stand in fire, interrupt, decurse big icon alert",
	bigicon_desc = "Shows a big icon when you are standing in the fire, need to interrupt or need to decurse",
	
	silence_cmd = "silence",
	silence_name = "Timers for silence and silenced",
	silence_desc = "Shows timer bars for the boss' silence cooldown and for people silenced",
	
	curse_cmd = "curse",
	curse_name = "Need to decurse alert",
	curse_desc = "Warns you when you need to decurse",

	fire_cmd = "fire",
	fire_name = "Stand in fire alert",
	fire_desc = "Warns you when you are standing in the fire",
	
	combat_trigger = "grant me wings of v",

	swarm_trigger = "Bloodseeker Bat gains Hover\.",
	swarm_warn = "Incoming bat swarm! Kill them!",	
	swarm_bar = "Bat Swarm",
	
	bomb_trigger = "Frenzied Bloodseeker Bat gains Hover\.",
	bomb_warn = "Fire bombs incoming!",
	fire_trigger = "Throw Liquid Fire hits you for",
	fire_warn = "Move away from fire!",
	
	fear1_trigger = "Terrifying Screech",
	fear2_trigger = "Psychic Scream",
	fear_warn = "Fear",
	fear_bar = "Fear CD",
	
	mindflay_trigger = "afflicted by Mind Flay",
	mindflayend_trigger = "Mind Flay fades from (.+).",
	mindflay_bar = "Mind Flay",

	heal_trigger = "High Priestess Jeklik begins to cast Great Heal\.",
	healinterrupt1_trigger = "Pummel (.+) High Priestess Jeklik for",
	healinterrupt2_trigger = "Shield Bash (.+) High Priestess Jeklik for",
	healinterrupt3_trigger = "Kick (.+) High Priestess Jeklik for",
	healinterrupt4_trigger = "interrupt High Priestess Jeklik's Great Heal",
	healinterrupt5_trigger = "interrupts High Priestess Jeklik's Great Heal",
	
	heal_warn = "Heal! Interrupt it!",
	heal_bar = "HEALING!!!",
	nextheal_bar = "Heal CD",
	
	phasetwo_trigger = "Hover fades from High Priestess Jeklik\.",	
	phaseone_message = "Bat Phase",
	phasetwo_message = "Troll Phase",
	
	silence_trigger = "is afflicted by Sonic Burst",
	silence_bar = "Silence CD",
	silenced_bar = "People are silenced",
	
	curse_trigger = "is afflicted by Curse of Blood",
} end )

local timer = {
	fear = 45,
	firstSilence = 8,
	silence = 16,
	silenced = 10,
	healCast = 4,
	nextHeal = 20,
	fireBombs = 10,
	mindflay = 10,
	bats = 45,
}

local icon = {
	fear = "Spell_Shadow_PsychicScream",
	silence = "Spell_Frost_Iceshock",
	fire = "Spell_Fire_Lavaspawn",
	bomb = "Spell_Fire_Fire",
	mindflay = "Spell_Shadow_SiphonMana",
	heal = "Spell_Holy_Heal",
	bats = "Spell_Fire_SelfDestruct",
	kick = "ability_kick",
	decurse = "spell_nature_removecurse",
}

local syncName = {
	fear = "JeklikFear"..module.revision,
	mindflay = "JeklikMindFlay"..module.revision,
	mindflayOver = "JeklikMindFlayEnd"..module.revision,
	heal = "JeklikHeal"..module.revision,
	healOver = "JeklikHealOver"..module.revision,
	bombBats = "JeklikBombBats"..module.revision,
	swarmBats = "JeklikSwarmBats"..module.revision,
	phase2 = "JeklikPhase2"..module.revision,
	curse = "JeklikCurse"..module.revision,
	silence = "JeklikSilence"..module.revision,
}

local berserkannounced = nil
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["combat_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")

	self:RegisterEvent("UNIT_HEALTH")	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:ThrottleSync(10, syncName.fear)
	self:ThrottleSync(1.5, syncName.mindflay)
	self:ThrottleSync(1.5, syncName.mindflayOver)
	self:ThrottleSync(4, syncName.heal)
	self:ThrottleSync(4, syncName.healOver)
	self:ThrottleSync(5, syncName.bombBats)
	self:ThrottleSync(5, syncName.swarmBats)
	self:ThrottleSync(30, syncName.phase2)
	self:ThrottleSync(5, syncName.curse)
end

function module:OnSetup()
	self.phase          = 0
	self.lastHeal       = 0
	self.castingheal    = 0
end

function module:OnEngage()
	self.phase = 1
	self:Bar("First Silence", timer.firstSilence, icon.silence, true, "white")
	if self.db.profile.swarm then
		self:Bar(L["swarm_bar"], timer.bats, icon.bats, true, "yellow");
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["phasetwo_trigger"]) then
		self:Sync(syncName.phase2)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == self.translatedName then
		if UnitHealthMax(msg) == 100 then
			if self.phase < 2 and UnitHealth(msg) < 50 then
				self:Sync(syncName.phase2)
				self:UnregisterEvent("UNIT_HEALTH")
			end
		end
	end
end

function module:Event(msg)
	local _,_, mindflayendtarget = string.find(msg, L["mindflayend_trigger"])
	if string.find(msg, L["mindflay_trigger"]) then
		self:Sync(syncName.mindflay)
	end
	if string.find(msg, L["mindflayend_trigger"]) and mindflayendtarget ~= "High Priestess Jeklik" then
		self:Sync(syncName.mindflayOver)
	end
	if string.find(msg, L["heal_trigger"]) then
		self:Sync(syncName.heal)
	end
	if (string.find(msg, L["healinterrupt1_trigger"]) or string.find(msg, L["healinterrupt2_trigger"]) or string.find(msg, L["healinterrupt3_trigger"]) or string.find(msg, L["healinterrupt4_trigger"]) or string.find(msg, L["healinterrupt5_trigger"])) then
		self:Sync(syncName.healOver)
	end
	if string.find(msg, L["fear1_trigger"]) or string.find(msg, L["fear2_trigger"]) then
		self:Sync(syncName.fear)
	end
	if string.find(msg, L["phasetwo_trigger"]) then
		self:Sync(syncName.phase2)
	end
	if string.find(msg, L["bomb_trigger"]) then
		self:Sync(syncName.bombBats)
	end
	if string.find(msg, L["swarm_trigger"]) then
		self:Sync(syncName.swarmBats)	
	end
	if string.find(msg, L["fire_trigger"]) and self.db.profile.fire then
		self:Fire()
	end
	if string.find(msg, L["silence_trigger"]) then
		self:Sync(syncName.silence)
	end
	if string.find(msg, L["curse_trigger"]) then
		self:Sync(syncName.curse)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 and self.phase < 2 then
		self.phase = 2
		self:KTM_Reset()
		self:Phase2()
	elseif sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	elseif sync == syncName.mindflay and self.db.profile.flay then
		self:MindFlay()	
	elseif sync == syncName.mindflayOver then
		self:MindFlayOver()
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	elseif sync == syncName.healOver then
		self:HealOver()		
	elseif sync == syncName.swarmBats and self.db.profile.swarm then
		self:SwarmBat()
	elseif sync == syncName.bombBats and self.db.profile.bomb then
		self:BombBat()
	elseif sync == syncName.silence and self.db.profile.silence then
		self:Silence()
	elseif sync == syncName.curse and self.db.profile.curse then
		self:Curse()
	end
end

function module:Curse()
	if self.db.profile.bigicon then
		if playerClass == "MAGE" or playerClass == "DRUID" then
			self:WarningSign(icon.decurse, 0.7)
		end
	end
end

function module:Silence()
	self:Bar(L["silence_bar"], timer.silence, icon.silence, true, "white")
	self:Bar(L["silenced_bar"], timer.silenced, icon.silence, true, "white")
end

function module:MindFlay()
	self:Bar(L["mindflay_bar"], timer.mindflay, icon.mindflay, true, "blue")
end

function module:MindFlayOver()
	self:RemoveBar(L["mindflay_bar"])
end

function module:Heal()
	self:RemoveBar(L["nextheal_bar"])
	self:Bar(L["nextheal_bar"], timer.nextHeal, icon.heal, true, "green")
	self:Message(L["heal_warn"], "Important", "Alarm")
	self:Bar(L["heal_bar"], timer.healCast, icon.heal, true, "green")
	if self.db.profile.bigicon then
		if playerClass == "ROGUE" or playerClass == "WARRIOR" or playerClass == "MAGE" then
			self:WarningSign(icon.kick, 0.7)
		end
	end
end

function module:HealOver()
	self:RemoveBar(L["heal_bar"])
end

function module:Fear()
	self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "red")
end

function module:SwarmBat()
	self:Message(L["swarm_warn"], "Urgent")
end

function module:BombBat()
	self:Message(L["bomb_warn"], "Urgent")
end

function module:Fire()
	self:Message(L["fire_warn"], "Attention", "Alarm")
	if self.db.profile.bigicon then
		self:WarningSign(icon.fire, 0.7)
	end
end

function module:Phase2()
	if self.db.profile.bomb then
		self:Bar("Fire Bombs", timer.fireBombs, icon.bomb)
	end
	if self.db.profile.phase then
		self:Message(L["phasetwo_message"], "Attention")
	end
	if self.db.profile.fear then
		self:RemoveBar(L["fear_bar"])
		self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "red")
	end
	if self.db.profile.heal then
		self:Bar(L["nextheal_bar"], timer.nextHeal, icon.heal, true, "green")
	end
end

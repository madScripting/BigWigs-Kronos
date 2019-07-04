
local module, L = BigWigs:ModuleDeclaration("Anubisath Guardian", "Ruins of Ahn'Qiraj")

module.revision = 20047
module.enabletrigger = module.translatedName 
module.toggleoptions = {"reflect", "shadowstorm", "summon", "meteor", "explode", "enrage", -1, "plagueyou", "plagueother", "icon", "thunderclap"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Guardian",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for summoned adds",

	reflect_cmd = "reflect",
	reflect_name = "Spell reflect alert",
	reflect_desc = "Shows bars for which reflect the Guardian has",
	
	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn for plague on you",
	
	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn for plague on others",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	shadowstorm_cmd = "shadowstorm",
	shadowstorm_name = "Shadowstorm Alert",
	shadowstorm_desc = "Warn for Shadowstorm",
	
	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for incoming explosion",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",
	
	meteor_cmd = "meteor",
	meteor_name = "Meteor Alert",
	meteor_desc = "Warn for meteor",
	
	sharefwarn = "Shadow & Frost reflect",
	sharefbufficon = "Interface\\Icons\\Spell_Arcane_Blink",
	
	arcreftrigger = "Detect Magic is reflected",
	arcrefwarn = "Fire & Arcane reflect",

	thunderclaptrigger = "Anubisath Guardian's Thunderclap hits",
	thunderclap_split = "!!2 GROUPS!!",
	
	shadowstormtrigger = "Anubisath Guardian's Shadow Storm hits",
	shadowstorm_stay = "!!STACK IN MELEE RANGE!!",

	meteortrigger = "Anubisath Guardian's Meteor",
	meteorbar = "Meteor CD",
	meteorwarn = "Meteor!",
	
	explodetrigger = "Anubisath Guardian gains Explode.",
	explodewarn = "Exploding!",
	
	enragetrigger = "Anubisath Guardian gains Enrage.",
	enragewarn = "Enraged!",
	
	summonguardtrigger = "Anubisath Guardian casts Summon Anubisath Swarmguard.",
	summonguardwarn = "Swarmguard Summoned",
	summonwarriortrigger = "Anubisath Guardian casts Summon Anubisath Warrior.",
	summonwarriorwarn = "Warrior Summoned",
	
	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the Plague!",
	plagueyou = "You",
	plagueare = "are",
	plague_onme = "Plague on ",
} end )

module.defaultDB = {
	bosskill = false,
	enrage = false,
}

local timer = {
	meteor = {8,13},
	explode = 6,
	arcref = 600,
	sharef = 600,
}

local icon = {
	plague = "Spell_Shadow_CurseOfTounges",
	meteor = "Spell_Fire_Fireball02",
	explode = "spell_fire_selfdestruct",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
}

local syncName = {
	enrage = "GuardianEnrage"..module.revision,
	explode = "GuardianExplode"..module.revision,
	thunderclap = "GuardianThunderclap"..module.revision,
	summonguard = "GuardianSummonGuard"..module.revision,
	summonwarrior = "GuardianSummonWarrior"..module.revision,
	shadowstorm = "GuardianShadowstorm"..module.revision,
	meteor = "GuardianMeteor"..module.revision,
	arcref = "GuardianArcaneReflect"..module.revision,
	sharef = "GuardianShadowReflect"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Abilities")
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.explode)
	self:ThrottleSync(6, syncName.thunderclap)
	self:ThrottleSync(10, syncName.sharef)
	self:ThrottleSync(10, syncName.arcref)
end

function module:OnSetup()
	self.started = false
end

function module:OnEngage()
	first = true
	firstarcref = true
	firstsharef = true
end

function module:OnDisengage()
	firstarcref = true
	firstsharef = true
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function module:CheckPlague(msg)
	local _,_, pplayer, ptype = string.find(msg, L["plaguetrigger"])
	if pplayer then
		if self.db.profile.plagueyou and pplayer == L["plagueyou"] then
			self:SendSay(L["plague_onme"] .. UnitName("player") .. "!")
			self:Message(L["plagueyouwarn"], "Personal")
			self:WarningSign(icon.plague, 5)
			self:Sound("RunAway")
		elseif self.db.profile.plagueother then
			self:Message(pplayer .. L["plaguewarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", pplayer, L["plagueyouwarn"])
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", pplayer)
		end
	end
end

function module:Abilities(msg)
	-- Arcane Reflect
	if string.find(msg, L["arcreftrigger"]) then
		self:Sync(syncName.arcref)
	end

	-- Shadow Reflect
	if UnitBuff("target",1) == L["sharefbufficon"] then
		self:Sync(syncName.sharef)		
	end
end

function module:Event(msg)
	if string.find(msg, L["meteortrigger"]) then
		self:Sync(syncName.meteor)
	end
	if first == true then
		if string.find(msg, L["thunderclaptrigger"]) then
			self:Sync(syncName.thunderclap)
			first = false
		end
		if string.find(msg, L["shadowstormtrigger"]) then
			self:Sync(syncName.shadowstorm)
			first=false
		end
	end
	if string.find(msg, L["summonguardtrigger"]) then
		self:Sync(syncName.summonguard)
	end
	if  string.find(msg, L["summonwarriortrigger"]) then
		self:Sync(syncName.summonwarrior)
	end
	if msg == L["explodetrigger"] then
		self:Sync(syncName.explode)
	end
	if msg == L["enragetrigger"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.explode and self.db.profile.explode then
		self:Message(L["explodewarn"], "Important")
		self:Bar(L["explodewarn"], timer.explode, icon.explode)
		self:WarningSign(icon.explode, 3)
		self:Sound("RunAway")
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Message(L["enragewarn"], "Important")
	elseif sync == syncName.meteor and self.db.profile.meteor then
		self:Meteor()
	elseif sync ==syncName.thunderclap and self.db.profile.thunderclap then
		if first == true then
			self:Thunderclap()
			first = false
		end
	elseif sync == syncName.shadowstorm and self.db.profile.shadowstorm then
		if first == true then
			self:ShadowStorm()
			first = false
		end
	elseif sync == syncName.summonguard and self.db.profile.summon then
		self:SummonGuard()
	elseif sync == syncName.summonwarrior and self.db.profile.summon then
		self:SummonWarrior()
	elseif sync == syncName.arcref and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.sharef and self.db.profile.reflect then
		self:ShadowReflect()
	end
end

function module:ArcaneReflect()
	if firstarcref == true then
		self:Bar(L["arcrefwarn"], timer.arcref, icon.arcref, true, "green")
		firstarcref = false
	end
end

function module:ShadowReflect()
	if firstsharef == true then 
		self:Bar(L["sharefwarn"], timer.sharef, icon.sharef, true, "green")
		firstsharef = false
	end
end

function module:Meteor()
	self:IntervalBar(L["meteorbar"], timer.meteor[1], timer.meteor[2], icon.meteor)
	self:Message(L["meteorwarn"], "Important")
end

function module:Thunderclap()
	self:Message(L["thunderclap_split"], "Attention")
end

function module:ShadowStorm()
	self:Message(L["shadowstorm_stay"], "Attention")
end

function module:SummonGuard()
	self:Message(L["summonguardwarn"], "Attention")
end

function module:SummonWarrior()
	self:Message(L["summonwarriorwarn"], "Attention")
end


local module, L = BigWigs:ModuleDeclaration("Anubisath Defender", "Ahn'Qiraj")

module.revision = 20047
module.enabletrigger = module.translatedName
module.toggleoptions = {"reflect", "plagueyou", "plagueother", "icon", -1, "thunderclap", "explode", "enrage"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Defender",

	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn if you got the Plague",
	
	reflect_cmd = "reflect",
	reflect_name = "Spell reflect alert",
	reflect_desc = "Shows bars for which reflect the Defender has",

	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn if others got the Plague",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for Explode",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for add summons",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	thunderclaptrigger = "Anubisath Defender's Thunderclap hits",
	thunderclapwarn = "Thunderclap!",
	thunderclap_split = "!!2 GROUPS!!",

	shadowstormtrigger = "Anubisath Defender's Shadow Storm hits",
	shadowstorm_stay = "!!STACK IN MELEE RANGE!!",

	sharefwarn = "Shadow & Frost reflect",
	sharefbufficon = "Interface\\Icons\\Spell_Arcane_Blink",
	
	arcreftrigger = "Detect Magic is reflected",
	arcrefwarn = "Fire & Arcane reflect",
	
	explodetrigger = "Anubisath Defender gains Explode.",
	explodewarn = "Exploding!",

	enragetrigger = "Anubisath Defender gains Enrage.",
	enragewarn = "Enraged!",

	summonguardtrigger = "Anubisath Defender casts Summon Anubisath Swarmguard.",
	summonguardwarn = "Swarmguard Summoned",
	summonwarriortrigger = "Anubisath Defender casts Summon Anubisath Warrior.",
	summonwarriorwarn = "Warrior Summoned",

	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the plague!",
	plagueyou = "You",
	plagueare = "are",
	plague_onme = "Plague on ",
} end )

module.defaultDB = {
	enrage = false,
	bosskill = nil,
}

local timer = {
	explode = 6,
	arcref = 600,
	sharef = 600,
}

local icon = {
	explode = "spell_fire_selfdestruct",
	plague = "Spell_Shadow_CurseOfTounges",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
}

local syncName = {
	enrage = "DefenderEnrage"..module.revision,
	explode = "DefenderExplode"..module.revision,
	thunderclap = "DefenderThunderclap"..module.revision,
	arcref = "DefenderArcaneReflect"..module.revision,
	sharef = "DefenderShadowReflect"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Abilities")

	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.explode)
	self:ThrottleSync(6, syncName.thunderclap)
	self:ThrottleSync(10, syncName.sharef)
	self:ThrottleSync(10, syncName.arcref)
end

function module:OnSetup()
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

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.explode and self.db.profile.explode then
		self:Message(L["explodewarn"], "Important")
		self:Bar(L["explodewarn"], timer.explode, icon.explode)
		self:WarningSign("Spell_Shadow_MindBomb", timer.explode)
		self:Sound("RunAway")
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Message(L["enragewarn"], "Important")
	elseif sync == syncName.thunderclap and self.db.profile.thunderclap then
		self:Message(L["thunderclapwarn"], "Important")
	elseif sync == syncName.arcref and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.sharef and self.db.profile.reflect then
		self:ShadowReflect()
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if msg == L["explodetrigger"] then
		self:Sync(syncName.explode)
	elseif msg == L["enragetrigger"] then
		self:Sync(syncName.enrage)
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if not self.db.profile.summon then return end
	if msg == L["summonguardtrigger"] then
		self:Message(L["summonguardwarn"], "Attention")
	elseif msg == L["summonwarriortrigger"] then
		self:Message(L["summonwarriorwarn"], "Attention")
	end
end

function module:CheckPlague(msg)
	local _,_, pplayer, ptype = string.find(msg, L["plaguetrigger"])
	if pplayer then
		if self.db.profile.plagueyou and pplayer == L["plagueyou"] then
			self:SendSay(L["plague_onme"] .. UnitName("player") .. "!")
			self:Message(L["plagueyouwarn"], "Personal")
			self:Message(UnitName("player") .. L["plaguewarn"])
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

function module:Thunderclap(msg)
	if first == true then
		if string.find(msg, L["thunderclaptrigger"]) then
			self:Message(L["thunderclap_split"], "Attention")
			first=false
		end
		if string.find(msg, L["shadowstormtrigger"]) then
		self:Message(L["shadowstorm_stay"], "Attention")
		first=false
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

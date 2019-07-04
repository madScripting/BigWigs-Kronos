
local module, L = BigWigs:ModuleDeclaration("Lucifron", "Molten Core")

module.revision = 20041
module.enabletrigger = module.translatedName

module.toggleoptions = {"bigicon", "sounds", "adds", "curse", "doom", "icon", "shock", "mc", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Lucifron",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Flamewaker Protectors",

	mc_cmd = "mc",
	mc_name = "Dominate Mind",
	mc_desc = "Alert when someone is mind controlled.",

	curse_cmd = "curse",
	curse_name = "Lucifron's Curse alert",
	curse_desc = "Warn for Lucifron's Curse",

	doom_cmd = "doom",
	doom_name = "Impending Doom alert",
	doom_desc = "Warn for Impending Doom",

	shock_cmd = "shock",
	shock_name = "Shadow Shock alert",
	shock_desc  = "Warn for Shadow Shock",

	icon_cmd = "icon",
	icon_name = "MC icon",
	icon_desc = "Place raid icon on the MC'd person (requires promoted or higher)",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Sheep! big icon alert",
	bigicon_desc = "Shows a big icon when you should sheep",
	
	sounds_cmd = "sounds",
	sounds_name = "Sheep! sound alert",
	sounds_desc = "Sound effect when you should sheep",
	
	curse_trigger = "afflicted by Lucifron",
	curse_trigger2 = " Lucifron(.*) Curse was resisted",
	
	doom_trigger = "afflicted by Impending Doom",
	doom_trigger2 = "s Impending Doom was resisted",
	doom_warn_soon = "5 seconds until Impending Doom!",
	doom_warn_now = "Impending Doom - 15 seconds until next!",
	doom_bar = "Impending Doom",
	
	shock_trigger = "s Shadow Shock hits",
	shock_trigger2 = "s Shadow Shock was resisted",
	shock_bar = "Shadow Shock",
		
	curse_warn_soon = "5 seconds until Lucifron's Curse!",
	curse_warn_now = "Lucifron's Curse - 20 seconds until next!",
	curse_bar = "Lucifron's Curse",
	
	mindcontrolyou_trigger = "You are afflicted by Dominate Mind.",
	mindcontrolother_trigger = "(.*) is afflicted by Dominate Mind.",
	mindcontrolyouend_trigger = "Dominate Mind fades from you.",
	mindcontrolotherend_trigger = "Dominate Mind fades from (.*).",
	deathyou_trigger = "You die.",
	deathother_trigger = "(.*) dies.",
	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_message_you = "You are mindcontrolled!",
	mindcontrol_bar = "MC: %s",
	
	deadaddtrigger = "Flamewaker Protector dies",
	add_name = "Flamewaker Protector",
	addmsg = "%d/2 Flamewaker Protectors dead!",
} end)

local timer = {
	curse = 20,
	firstCurse = 20,
	doom = 20,
	firstDoom = 10,
	mc = 15,
	sheep = 0.7,
}

local icon = {
	curse = "Spell_Shadow_BlackPlague",
	doom = "Spell_Shadow_NightOfTheDead",
	mc = "Spell_Shadow_ShadowWordDominate",
	sheep = "Spell_Nature_Polymorph",
}

local syncName = {
	curse = "LucifronCurseRep"..module.revision,
	doom = "LucifronDoomRep"..module.revision,
	shock = "LucifronShock"..module.revision,
	mc = "LucifronMC"..module.revision.."_",
	mcEnd = "LucifronMCEnd"..module.revision.."_",
	add = "LucifronAddDead",
}

local _, playerClass = UnitClass("player")
module.wipemobs = { L["add_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")

	self:ThrottleSync(0.5, syncName.mc .. "(.*)")
	self:ThrottleSync(0.5, syncName.mcEnd .. "(.*)")
	self:ThrottleSync(5, syncName.curse)
	self:ThrottleSync(5, syncName.shock)
	self:ThrottleSync(5, syncName.doom)
end

function module:OnSetup()
	self.started = nil
	self.protector = 0
end

function module:OnEngage()
	if self.db.profile.curse then
		self:DelayedMessage(timer.curse - 5, L["curse_warn_soon"], "Attention", nil, nil, true)
		self:Bar(L["curse_bar"], timer.curse, icon.curse)
	end
	if self.db.profile.doom then
		self:DelayedMessage(timer.firstDoom - 5, L["doom_warn_soon"], "Attention", nil, nil, true)
		self:Bar(L["doom_bar"], timer.firstDoom, icon.doom)
	end
	self:Sync("LucifronShock")
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,mindcontrolother,_ = string.find(msg, L["mindcontrolother_trigger"])
	local _,_,mindcontrolotherend,_ = string.find(msg, L["mindcontrolotherend_trigger"])
	local _,_,mindcontrolotherdeath,_ = string.find(msg, L["deathother_trigger"])
	if ((string.find(msg, L["curse_trigger"])) or (string.find(msg, L["curse_trigger2"]))) then
		self:Sync(syncName.curse)
	elseif ((string.find(msg, L["doom_trigger"])) or (string.find(msg, L["doom_trigger2"]))) then
		self:Sync(syncName.doom)
	elseif ((string.find(msg, L["shock_trigger"])) or (string.find(msg, L["shock_trigger2"]))) then
		self:Sync(syncName.shock)
	elseif string.find(msg, L["mindcontrolyou_trigger"]) then
		self:Sync(syncName.mc .. UnitName("player"))
	elseif string.find(msg, L["mindcontrolyouend_trigger"]) then
		self:Sync(syncName.mcEnd .. UnitName("player"))
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:Sync(syncName.mcEnd .. UnitName("player"))
	elseif mindcontrolother then
		self:Sync(syncName.mc .. mindcontrolother)
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", mindcontrolother)
		end
		if playerClass == "MAGE" then
			if self.db.profile.bigicon then
				self:WarningSign(icon.sheep, timer.sheep)
			end
			if self.db.profile.sounds then
				self:Sound("Info")
			end
		end
	elseif mindcontrolotherend then
		self:Sync(syncName.mcEnd .. mindcontrolotherend)
		self:TriggerEvent("BigWigs_RemoveRaidIcon")
	elseif mindcontrolotherdeath then
		self:Sync(syncName.mcEnd .. mindcontrolotherdeath)
	end
	if string.find(msg, L["deadaddtrigger"]) then
		self:Sync(syncName.add .. " " .. tostring(self.protector + 1))
	else
		local _,_,mindcontrolotherdeath,_ = string.find(msg, L["deathother_trigger"])
		if mindcontrolotherdeath then
			self:Sync(syncName.mcEnd .. mindcontrolotherdeath)
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:DelayedMessage(timer.curse - 5, L["curse_warn_soon"], "Attention", nil, nil, true)
		self:Bar(L["curse_bar"], timer.curse, icon.curse)
	elseif sync == syncName.doom and self.db.profile.doom then
		self:DelayedMessage(timer.doom - 5, L["doom_warn_soon"], "Attention", nil, nil, true)
		self:Bar(L["doom_bar"], timer.doom, icon.doom)
	elseif sync == syncName.shock and self.db.profile.shock then
	elseif string.find(sync, syncName.mc) then
		if self.db.profile.mc then
			chosenone = string.sub(sync,17)
			if chosenone == UnitName("player") then
				self:Message(L["mindcontrol_message_you"], "Attention")
				self:Bar(string.format(L["mindcontrol_bar"], UnitName("player")), timer.mc, icon.mc)
			else
				self:Bar(string.format(L["mindcontrol_bar"], chosenone .. " >Click Me!<"), timer.mc, icon.mc)
				self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], chosenone .. " >Click Me!<"), function(name, button, extra) TargetByName(extra, true) end, chosenone)
				self:Message(string.format(L["mindcontrol_message"], chosenone), "Urgent")
			end
		end
	elseif string.find(sync, syncName.mcEnd) then
		if self.db.profile.mc then
			luckyone = string.sub(sync,20)
			self:RemoveBar(string.format(L["mindcontrol_bar"], luckyone .. " >Click Me!<"))
			self:TriggerEvent("BigWigs_RemoveRaidIcon")
		end
	elseif sync == syncName.add and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 4 and self.protector < rest then
			self.protector = rest
			if self.db.profile.adds then
				self:Message(string.format(L["addmsg"], self.protector), "Positive")
			end
		end
	end
end

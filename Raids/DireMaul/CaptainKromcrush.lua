
local module, L = BigWigs:ModuleDeclaration("Captain Kromcrush", "Dire Maul")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"retaliation", "adds", "fear", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Dire Maul"],
	AceLibrary("Babble-Zone-2.2")["Dire Maul (North)"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "CaptainKromcrush",

	retaliation_cmd = "retaliation",
	retaliation_name = "Retaliation warnings",
	retaliation_desc = "Announces for his Retaliation ability",
	
	adds_cmd = "adds",
	adds_name = "Adds warnings",
	adds_desc = "Announces when adds are summoned",
	
	fear_cmd = "fear",
	fear_name = "Fear warnings",
	fear_desc = "Fear timer bars",
	
	fearTrigger = "Intimidating Shout",
	fearMessage = "Feared",
	fearBar = "Fear CD",
	
	retaliationUpTrigger = "Captain Kromcrush gains Retaliation",
	retaliationUpMessage = "Retaliation! Stop damage!",
	
	retaliationDownTrigger = "Retaliation fades from Captain Kromcrush",
	retaliationDownMessage = "Retaliation faded! Go!",
	
	retaliationHurtTrigger = "Captain Kromcrush's Retaliation hits you for",
	retaliationHurtMessage = "I'm an idiot taking damage from Retaliation",
	
	addsTrigger = "Help me crush these punys",
} end)

local timer = {
	retaliation = 15,
}

local icon = {
	retaliation = "ability_warrior_challange",
	fear = "spell_shadow_possession",
	sheep = "spell_nature_polymorph",
	trap = "spell_frost_chainsofice",
	tremor = "spell_nature_tremortotem",
}

local syncName = {
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
end

function module:OnSetup()

end

function module:OnEngage()
	if playerClass == "SHAMAN" then
		self:WarningSign(icon.tremor, 0.7)
		self:Sound("Beware")
	end
	self:Bar(L["fearBar"], timer.fear, icon.fear, true, "white")
	if UnitName("target") == "Captain Kromcrush" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Captain Kromcrush")
	end
end

function module:OnDisengage()

end

function module:Event(msg)
	if string.find(msg, L["fearTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("fearTrigger")
		end
		self:Fear()
	end
	if string.find(msg, L["addsTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("addsTrigger")
		end
		self:AddsUp()
	end
	if string.find(msg, L["retaliationUpTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("retaliationUpTrigger")
		end
		self:RetaliationUp()
	end
	if string.find(msg, L["retaliationDownTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("retaliationDownTrigger")
		end
		self:RetaliationDown()
	end
	if string.find(msg, L["retaliationHurtTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("retaliationHurtTrigger")
		end
		self:RetaliationHurt()
	end
end

function module:AddsUp()
	if UnitName("player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("function AddsUp")
	end
	if playerClass == "PRIEST" or playerClass == "WARLOCK" then
		self:WarningSign(icon.fear, 0.7)
		self:Sound("Beware")
	end
	if playerClass == "MAGE" then
		self:WarningSign(icon.sheep, 0.7)
		self:Sound("Beware")
	end
	if playerClass == "HUNTER" then
		self:WarningSign(icon.trap, 0.7)
		self:Sound("Beware")
	end
end

function module:Fear()
	if UnitName("player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("function Fear")
	end
	self:Message(L["fearMessage"], "Important")
	self:Bar(L["fearBar"], timer.fear, icon.fear, true, "white")
end

function module:RetaliationUp()
	if UnitName("player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("function RetaliationUp")
	end
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		self:Message(L["retaliationUpMessage"], "Important", false, "Beware")
		self:WarningSign(icon.retaliation, 15)
	end
end

function module:RetaliationDown()
	if UnitName("player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("function RetaliationDown")
	end
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		self:Message(L["retaliationDownMessage"], "Important", false, "gogogo")
		self:RemoveWarningSign(icon.retaliation)
	end
end

function module:RetaliationHurt()
	if UnitName("player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("function RetaliationHurt")
	end
	self:SendSay(L["retaliationHurtMessage"])
end

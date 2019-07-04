
local module, L = BigWigs:ModuleDeclaration("Fankriss the Unyielding", "Ahn'Qiraj")

module.revision = 20047
module.enabletrigger = module.translatedName
module.toggleoptions = {"wound", "taunt", "bigicon", "sounds", "entangle", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Fankriss",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Stacks big icon alert",
	bigicon_desc = "Shows a big icon when you have too many stacks",
	
	worm_cmd = "worm",
	worm_name = "Worm Alert",
	worm_desc = "Warn for Incoming Worms",
	
	wound_cmd = "wound",
	wound_name = "Wound 5 stacks alerts",
	wound_desc = "Alert for 5 stacks of Wound",
	
	sounds_cmd = "sounds",
	sounds_name = "Too many stacks sound alert",
	sounds_desc = "Sound effect when you have too many stacks",
	
	taunt_cmd = "taunt",
	taunt_name = "Big icon for taunt alert",
	taunt_desc = "Shows a big icon when you should taunt.",
	
	entangle_cmd = "entangle",
	entangle_name = "Entangle Alert",
	entangle_desc = "Warn for Entangle and incoming Bugs",
	
	wound_trigger = "(.+) (.+) afflicted by Mortal Wound %(5%)",

	entangleplayer = "You are afflicted by Entangle.",
	entangleplayerother = "(.*) is afflicted by Entangle.",
	entanglewarn = "Entangle!",
} end )

local timer = {
	wound = 15,
}
	
local icon = {
	entangle = "Spell_Nature_Web",
	taunt = "spell_nature_reincarnation",
	stacks = "ability_criticalstrike",
}

local syncName = {
	entangle = "FankrissEntangle"..module.revision,
	wound = "FankrissWound"..module.revision,
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:ThrottleSync(10, syncName.entangle)
	self:ThrottleSync(10, syncName.wound)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if UnitName("target") == "Fankriss the Unyielding" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Fankriss the Unyielding")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,woundperson = string.find(msg, L["wound_trigger"])
	if string.find(msg, L["entangleplayer"]) or string.find(msg, L["entangleplayerother"]) then
		self:Sync(syncName.entangle)
	end
	if string.find(msg, L["wound_trigger"]) then
		self:Sync(syncName.wound.." "..woundperson)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.entangle and self.db.profile.entangle then
		self:Entangle()
	elseif sync == syncName.wound and self.db.profile.wound then
		self:Wound(rest)
	end
end

function module:Entangle()
	self:Message(L["entanglewarn"], "Urgent", true, "Alarm")
	self:WarningSign(icon.entangle, 0.7)
end

function module:Wound(rest)
	if rest == UnitName("player") then
		if self.db.profile.sounds then
			self:Sound("stacks")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.stacks, 0.7)
		end
	else
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			self:WarningSign(icon.taunt, 0.7)
		end
	end
end

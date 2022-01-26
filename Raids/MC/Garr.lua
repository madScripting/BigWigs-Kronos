
local module, L = BigWigs:ModuleDeclaration("Garr", "Molten Core")

module.revision = 20057
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Garr",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Firesworns",

	firesworn_name = "Firesworn",
	triggeradddead8 = "Garr gains Enrage(.+)8",
	triggeradddead7 = "Garr gains Enrage(.+)7",
	triggeradddead6 = "Garr gains Enrage(.+)6",
	triggeradddead5 = "Garr gains Enrage(.+)5",
	triggeradddead4 = "Garr gains Enrage(.+)4",
	triggeradddead3 = "Garr gains Enrage(.+)3",
	triggeradddead2 = "Garr gains Enrage(.+)2",
	triggeradddead1 = "Garr gains Enrage.",

	counterbarMsg = "Firesworns dead",
	addmsg1 = "1/8 Firesworns dead!",
	addmsg2 = "2/8 Firesworns dead!",
	addmsg3 = "3/8 Firesworns dead!",
	addmsg4 = "4/8 Firesworns dead!",
	addmsg5 = "5/8 Firesworns dead!",
	addmsg6 = "6/8 Firesworns dead!",
	addmsg7 = "7/8 Firesworns dead!",
	addmsg8 = "8/8 Firesworns dead!",
} end)

local timer = {
}

local icon = {
}

local syncName = {
}

local adds = 0

module.wipemobs = { L["firesworn_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
end

function module:OnSetup()
	self.started    = nil
	adds       		= 0
end

function module:OnEngage()
	if UnitName("target") == "Garr" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Garr")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if (string.find(msg, L["triggeradddead8"])) then
		self:Sync("GarrAddDead8")
	elseif (string.find(msg, L["triggeradddead7"])) then
		self:Sync("GarrAddDead7")
	elseif (string.find(msg, L["triggeradddead6"])) then
		self:Sync("GarrAddDead6")
	elseif (string.find(msg, L["triggeradddead5"])) then
		self:Sync("GarrAddDead5")
	elseif (string.find(msg, L["triggeradddead4"])) then
		self:Sync("GarrAddDead4")
	elseif (string.find(msg, L["triggeradddead3"])) then
		self:Sync("GarrAddDead3")
	elseif (string.find(msg, L["triggeradddead2"])) then
		self:Sync("GarrAddDead2")
	elseif (string.find(msg, L["triggeradddead1"])) then
		self:Sync("GarrAddDead1")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if self.started and string.find(sync, "GarrAddDead%d") then
		local newCount = tonumber(string.sub(sync, 12))
		if self.adds < newCount then
			self.adds = newCount
			if self.db.profile.adds then
				self:Message(L["addmsg" .. newCount], "Positive")
			end
		end
	end
end

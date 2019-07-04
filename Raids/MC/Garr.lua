--Warlocks should use these macros to banish targets
--For Rank 1:
--/script if GetRaidTargetIndex("target") == nil then icon=UnitName("target") else icon=GetRaidTargetIndex("target") end
--/script SendChatMessage(UnitName("player").." Banishing R1 "..icon)
--/cast Banish(Rank 1)
--
--For Rank 2(max rank):
--/script if GetRaidTargetIndex("target") == nil then icon=UnitName("target") else icon=GetRaidTargetIndex("target") end
--/script SendChatMessage(UnitName("player").." Banishing R2 "..icon)
--/cast Banish(Rank 2)

local module, L = BigWigs:ModuleDeclaration("Garr", "Molten Core")

module.revision = 20041
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
	
	banish_trigger = "(.*) Banishing (.*) (.*)",
	banish_bar = " Ban ",
} end)

local timer = {
	banishR2 = 31.5,
	banishR1 = 21.5,
}

local icon = {
	banish = "spell_shadow_cripple",
}

local syncName = {
}

local adds = 0

module.wipemobs = { L["firesworn_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SAY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
end

function module:OnSetup()
	self.started    = nil
	adds       		= 0
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_, name, rank, idobanish, mcverb = string.find(msg, L["banish_trigger"])
	if idobanish then
		a=tonumber(idobanish)
		if tonumber(idobanish) == nil then return end
		if tonumber(idobanish) >= 0 then
			if a == 1 then bantarget = "Star" end
			if a == 2 then bantarget = "Circle" end
			if a == 3 then bantarget = "Diamond" end
			if a == 4 then bantarget = "Triangle" end
			if a == 5 then bantarget = "Moon" end
			if a == 6 then bantarget = "Square" end
			if a == 7 then bantarget = "X" end
			if a == 8 then bantarget = "Skull" end
			if tostring(rank) == "R1" then
				self:Bar(string.format(name .. L["banish_bar"] .. bantarget), timer.banishR1, icon.banish)
			end
			if tostring(rank) == "R2" then
				self:Bar(string.format(name .. L["banish_bar"] .. bantarget), timer.banishR2, icon.banish)
			end
		end
	end
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

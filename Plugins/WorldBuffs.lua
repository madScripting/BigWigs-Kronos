
BigWigsWorldBuffs = BigWigs:NewModule("WorldBuffs")
BigWigsWorldBuffs.revision = 20061
BigWigsWorldBuffs.external = true
BigWigsWorldBuffs.consoleCmd = "WorldBuffs"

--[[ToDo
confirm nef trigger
confirm zg trigger
confirm timers
]]--

--[[for testing
/script SendAddonMessage("BigWigs","onyBuff", "RAID", "Relar");
]]--

local L = AceLibrary("AceLocale-2.2"):new("BigWigsWorldBuffs")

L:RegisterTranslations("enUS", function() return {
	["WorldBuffs"] = true,
	["Options for the WorldBuffs module."] = true,
	["Toggle WorldBuffs bars on or off."] = true,
	["Bars"] = true,

	onyBuffTrigger = "Onyxia",
	onyBuffNpc = "Overlord Runthak",
	onyBuffBar = "Ony Buff",
	onyBuffAddonMsg = "onyBuff",
	
	rendBuffTrigger = "Rend Blackhand", --is a say
	rendBuffNpc = "Thrall",
	rendBuffBar = "Rend Buff",
	rendBuffAddonMsg = "rendBuff",
	
	nefBuffTrigger = "NEFARIAN IS SLAIN",
	nefBuffNpc = "High Overlord Saurfang",
	nefBuffBar = "Nef Buff",
	nefBuffAddonMsg = "nefBuff",
	
	zgBuffTrigger = "Begin the ritual",
	zgBuffNpc = "Molthor",
	zgBuffBar = "ZG Buff",
	zgBuffAddonMsg = "zgBuff",
} end)

BigWigsWorldBuffs.defaults = {
	bars = true,
}

BigWigsWorldBuffs.consoleOptions = {
	type = "group",
	name = L["WorldBuffs"],
	desc = L["Options for the WorldBuffs module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle WorldBuffs bars on or off."],
			get = function() return BigWigsWorldBuffs.db.profile.bars end,
			set = function(v)
				BigWigsWorldBuffs.db.profile.bars = v
			end,
		},
	}
}

local icon = {
	onyBuffIcon = "inv_misc_head_dragon_01",
	rendBuffIcon = "spell_arcane_teleportorgrimmar",
	nefBuffIcon = "inv_misc_head_dragon_01",
	zgBuffIcon = "ability_creature_poison_05",
}

local timer = {
	onyBuffTimer = 15,
	rendBuffTimer = 6,
	nefBuffTimer = 15,
	zgBuffTimer = 29,
}

local color = {
	onyBuffColor = "Red",
	rendBuffColor = "Orange",
	nefBuffColor = "Black",
	zgBuffColor = "Green",
}

local onyBuffTime = 0
local rendBuffTime = 0
local nefBuffTime = 0
local zgBuffTime = 0

function BigWigsWorldBuffs:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY", "Event")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_ADDON", "AddonMsg")
end

function BigWigsWorldBuffs:OnSetup()

end

function BigWigsWorldBuffs:Event(msg)
	if string.find(msg, L["onyBuffTrigger"]) then
		SendAddonMessage("BigWigs"," onyBuff", "PARTY")
		SendAddonMessage("BigWigs"," onyBuff", "RAID")
		SendAddonMessage("BigWigs"," onyBuff", "GUILD")
		SendAddonMessage("BigWigs"," onyBuff", "BATTLEGROUND")
	end
	if string.find(msg, L["rendBuffTrigger"]) then
		SendAddonMessage("BigWigs"," rendBuff", "PARTY")
		SendAddonMessage("BigWigs"," rendBuff", "RAID")
		SendAddonMessage("BigWigs"," rendBuff", "GUILD")
		SendAddonMessage("BigWigs"," rendBuff", "BATTLEGROUND")
	end
	if string.find(msg, L["nefBuffTrigger"]) then
		if UnitName("player") == "Relar" or UnitName("player") == "Zbanka" then
			DEFAULT_CHAT_FRAME:AddMessage("nefBuffTrigger found")
		end
		SendAddonMessage("BigWigs"," nefBuff", "PARTY")
		SendAddonMessage("BigWigs"," nefBuff", "RAID")
		SendAddonMessage("BigWigs"," nefBuff", "GUILD")
		SendAddonMessage("BigWigs"," nefBuff", "BATTLEGROUND")
	end
	if string.find(msg, L["zgBuffTrigger"]) then
		if UnitName("player") == "Relar" or UnitName("player") == "Zbanka" then
			DEFAULT_CHAT_FRAME:AddMessage("zgBuffTrigger found")
		end
		SendAddonMessage("BigWigs"," zgBuff", "PARTY")
		SendAddonMessage("BigWigs"," zgBuff", "RAID")
		SendAddonMessage("BigWigs"," zgBuff", "GUILD")
		SendAddonMessage("BigWigs"," zgBuff", "BATTLEGROUND")
	end
end

function BigWigsWorldBuffs:AddonMsg(prefix,text,target,author)
	if prefix == "BigWigs" then
		if string.find(text, L["onyBuffAddonMsg"]) then
			if GetTime() > onyBuffTime + 30 then
				SendAddonMessage("BigWigs"," onyBuff", "PARTY")
				SendAddonMessage("BigWigs"," onyBuff", "RAID")
				SendAddonMessage("BigWigs"," onyBuff", "GUILD")
				SendAddonMessage("BigWigs"," onyBuff", "BATTLEGROUND")
				self:Bar(L["onyBuffBar"], timer.onyBuffTimer, icon.onyBuffIcon, true, color.onyBuffColor)
				onyBuffTime = GetTime()
			end
		end
		if string.find(text, L["rendBuffAddonMsg"]) then
			if GetTime() > rendBuffTime + 30 then
				SendAddonMessage("BigWigs"," rendBuff", "PARTY")
				SendAddonMessage("BigWigs"," rendBuff", "RAID")
				SendAddonMessage("BigWigs"," rendBuff", "GUILD")
				SendAddonMessage("BigWigs"," rendBuff", "BATTLEGROUND")
				self:Bar(L["rendBuffBar"], timer.rendBuffTimer, icon.rendBuffIcon, true, color.rendBuffColor)
				rendBuffTime = GetTime()
			end
		end
		if string.find(text, L["nefBuffAddonMsg"]) then
			if GetTime() > nefBuffTime + 30 then
				SendAddonMessage("BigWigs"," nefBuff", "PARTY")
				SendAddonMessage("BigWigs"," nefBuff", "RAID")
				SendAddonMessage("BigWigs"," nefBuff", "GUILD")
				SendAddonMessage("BigWigs"," nefBuff", "BATTLEGROUND")
				self:Bar(L["nefBuffBar"], timer.nefBuffTimer, icon.nefBuffIcon, true, color.nefBuffColor)
				nefBuffTime = GetTime()
			end
		end
		if string.find(text, L["zgBuffAddonMsg"]) then
			if GetTime() > zgBuffTime + 30 then
				SendAddonMessage("BigWigs"," zgBuff", "PARTY")
				SendAddonMessage("BigWigs"," zgBuff", "RAID")
				SendAddonMessage("BigWigs"," zgBuff", "GUILD")
				SendAddonMessage("BigWigs"," zgBuff", "BATTLEGROUND")
				self:Bar(L["zgBuffBar"], timer.zgBuffTimer, icon.zgBuffIcon, true, color.zgBuffColor)
				zgBuffTime = GetTime()
			end
		end
	end
end


BigWigsWorldBuffs = BigWigs:NewModule("WorldBuffs")
BigWigsWorldBuffs.revision = 20057
BigWigsWorldBuffs.external = true
BigWigsWorldBuffs.consoleCmd = "WorldBuffs"

--[[ToDo
confirm the yell and say is being registered (Monster == NPC too?)
check if the sync goes thru guild
confirm timers
]]--

local L = AceLibrary("AceLocale-2.2"):new("BigWigsWorldBuffs")

L:RegisterTranslations("enUS", function() return {
	["WorldBuffs"] = true,
	["Options for the WorldBuffs module."] = true,
	["Toggle WorldBuffs bars on or off."] = true,
	["Bars"] = true,

	onyBuffTrigger = "Onyxia, has been slain",
	onyBuffNpc = "Overlord Runthak",
	onyBuffBar = "Ony Buff",
	
	rendBuffTrigger = "Rend Blackhand, has fallen", --is a say
	rendBuffNpc = "Thrall",
	rendBuffBar = "Rend Buff",
	
	nefBuffTrigger = "NEFARIAN IS SLAIN",
	nefBuffNpc = "High Overlord Saurfang",
	nefBuffBar = "Nef Buff",
	
	zgBuffTrigger = "Begin the ritual",
	zgBuffNpc = "Molthor",
	zgBuffBar = "ZG Buff",
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

local syncName = {
	onyBuff = "WBonyBuff"..BigWigsWorldBuffs.revision,
	rendBuff = "WBrendBuff"..BigWigsWorldBuffs.revision,
	nefBuff = "WBnefBuff"..BigWigsWorldBuffs.revision,
	zgBuff = "WBzgBuff"..BigWigsWorldBuffs.revision,
}

function BigWigsWorldBuffs:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY", "Event")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")
end

function BigWigsWorldBuffs:OnSetup()

end

function BigWigsWorldBuffs:Event(msg)
	if "Orgrimmar" == GetZoneText() then
		DEFAULT_CHAT_FRAME:AddMessage("msg: "..msg)
	end
	if string.find(msg, L["onyBuffTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("onyBuffTrigger found")
		end
		self:Sync(syncName.onyBuff)
	end
	if string.find(msg, L["rendBuffTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("rendBuffTrigger found")
		end
		self:Sync(syncName.rendBuff)
	end
	if string.find(msg, L["nefBuffTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("nefBuffTrigger found")
		end
		self:Sync(syncName.nefBuff)
	end
	if string.find(msg, L["zgBuffTrigger"]) then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("zgBuffTrigger found")
		end
		self:Sync(syncName.zgBuff)
	end
end

function BigWigsWorldBuffs:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.onyBuff and self.db.profile.bars then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("onyBuff SYNC RECEIVED")
		end
		self:Bar(L["onyBuffBar"], timer.onyBuffTimer, icon.onyBuffIcon, true, color.onyBuffColor)
	end
	if sync == syncName.rendBuff and self.db.profile.bars then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("rendBuff SYNC RECEIVED")
		end
		self:Bar(L["rendBuffBar"], timer.rendBuffTimer, icon.rendBuffIcon, true, color.rendBuffColor)
	end
	if sync == syncName.nefBuff and self.db.profile.bars then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("nefBuff SYNC RECEIVED")
		end
		self:Bar(L["nefBuffBar"], timer.nefBuffTimer, icon.nefBuffIcon, true, color.nefBuffColor)
	end
	if sync == syncName.zgBuff and self.db.profile.bars then
		if UnitName("player") == "Relar" then
			DEFAULT_CHAT_FRAME:AddMessage("zgBuff SYNC RECEIVED")
		end
		self:Bar(L["zgBuffBar"], timer.zgBuffTimer, icon.zgBuffIcon, true, color.zgBuffColor)
	end
end


assert(BigWigs, "BigWigs not found!")

local L = AceLibrary("AceLocale-2.2"):new("BigWigsTranq")

L:RegisterTranslations("enUS", function() return {
	CHAT_MSG_SPELL_SELF_BUFF = "You fail to dispel (.+)'s Frenzy.",
	CHAT_MSG_SPELL_SELF_DAMAGE = "You cast Tranquilizing Shot on (.+).",

	["Tranq - %s"] = true,
	["%s's Tranq failed!"] = true,
	["Tranq"] = true,
	["Options for the tranq module."] = true,
	["Toggle tranq bars on or off."] = true,
	["Bars"] = true,
} end)

BigWigsTranq = BigWigs:NewModule(L["Tranq"])
BigWigsTranq.revision = 20046
BigWigsTranq.defaults = {
	bars = true,
}
BigWigsTranq.external = true
BigWigsTranq.consoleCmd = L["Tranq"]
BigWigsTranq.consoleOptions = {
	type = "group",
	name = L["Tranq"],
	desc = L["Options for the tranq module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle tranq bars on or off."],
			get = function() return BigWigsTranq.db.profile.bars end,
			set = function(v)
				BigWigsTranq.db.profile.bars = v
			end,
		},
	}
}

function BigWigsTranq:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("BigWigs_TranqFired", 5)
	self:RegisterEvent("BigWigs_TranqFail", 5)
end

function BigWigsTranq:CHAT_MSG_SPELL_SELF_BUFF(msg)
	if not msg then
		self:Debug("CHAT_MSG_SPELL_SELF_BUFF: msg is nil")
	elseif string.find(msg, L["CHAT_MSG_SPELL_SELF_BUFF"]) then
		self:TriggerEvent("BigWigs_SendSync", "TranqShotFail "..UnitName("player"))
	end
end

function BigWigsTranq:CHAT_MSG_SPELL_SELF_DAMAGE(msg)
	if not msg then
		self:Debug("CHAT_MSG_SPELL_SELF_DAMAGE: msg is nil")
	elseif string.find(msg, L["CHAT_MSG_SPELL_SELF_DAMAGE"]) then
		self:TriggerEvent("BigWigs_SendSync", "TranqShotFired "..UnitName("player"))
	end
end

function BigWigsTranq:BigWigs_RecvSync(sync, details, sender)
	if sync == "TranqShotFired" then self:TriggerEvent("BigWigs_TranqFired", details)
	elseif sync == "TranqShotFail" then self:TriggerEvent("BigWigs_TranqFail", details) end
end

function BigWigsTranq:BigWigs_TranqFired(unitname)
	if self.db.profile.bars then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["Tranq - %s"], unitname), 20, "Interface\\Icons\\Spell_Nature_Drowsy", true, "orange")
	end
end

function BigWigsTranq:BigWigs_TranqFail(unitname)
	if self.db.profile.bars then
		self:SetCandyBarColor(string.format(L["Tranq - %s"], unitname), "orange")
		self:TriggerEvent("BigWigs_Message", format(L["%s's Tranq failed!"], unitname), "Important", nil, "Alarm")
	end
end

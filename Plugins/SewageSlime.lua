
BigWigsSewageSlime = BigWigs:NewModule("SewageSlime")
BigWigsSewageSlime.revision = 20050
BigWigsSewageSlime.external = true
BigWigsSewageSlime.consoleCmd = "SewageSlime"

local L = AceLibrary("AceLocale-2.2"):new("BigWigsSewageSlime")

L:RegisterTranslations("enUS", function() return {
	["SewageSlime"] = true,
	["Options for the SewageSlime module."] = true,
	["Toggle SewageSlime bars on or off."] = true,
	["Bars"] = true,
	["Toggle SewageSlime messages on or off."] = true,
	["Messages"] = true,
	
	sewageSlime_trigger = "Grobbulus begins to cast Bombard Slime.",
	sewageSlime_bar = "Sewage Slimes",
	sewageSlime_warn = "Sewage Slimes in 10 seconds",
	sewageSlime30_warn = "Sewage Slimes in 30 seconds",
	sewageSlime60_warn = "Sewage Slimes in 60 seconds",
	sewageSlime120_warn = "Sewage Slimes in 2 minutes",
} end)

BigWigsSewageSlime.defaults = {
	bars = true,
	messages = true,
}

BigWigsSewageSlime.consoleOptions = {
	type = "group",
	name = L["SewageSlime"],
	desc = L["Options for the SewageSlime module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle SewageSlime bars on or off."],
			get = function() return BigWigsSewageSlime.db.profile.bars end,
			set = function(v)
				BigWigsSewageSlime.db.profile.bars = v
			end,
		},
		[L["Messages"]] = {
			type = "toggle",
			name = L["Messages"],
			desc = L["Toggle SewageSlime messages on or off."],
			get = function() return BigWigsSewageSlime.db.profile.messages end,
			set = function(v)
				BigWigsSewageSlime.db.profile.messages = v
			end,
		},
	}
}

local icon = {
	sewageSlime = "ability_creature_poison_06",
}

local timer = {
	sewageSlime = 240,
}

function BigWigsSewageSlime:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("BigWigs_SewageSlime", 30)
end

function BigWigsSewageSlime:OnSetup()
end

function BigWigsSewageSlime:Event(msg)
	if string.find(msg, L["sewageSlime_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "sewageSlime")
	end
end

function BigWigsSewageSlime:BigWigs_RecvSync(sync, rest, nick)
	if sync == "sewageSlime" then
		self:TriggerEvent("BigWigs_SewageSlime")
	end
end

function BigWigsSewageSlime:BigWigs_SewageSlime()
	if self.db.profile.bars then
		self:Bar(L["sewageSlime_bar"], timer.sewageSlime, icon.sewageSlime, true, "white")
		self:DelayedMessage(230, L["sewageSlime_warn"])
		self:DelayedMessage(210, L["sewageSlime30_warn"])
		self:DelayedMessage(180, L["sewageSlime60_warn"])
		self:DelayedMessage(120, L["sewageSlime120_warn"])
	end
end

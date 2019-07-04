
BigWigsIgnite = BigWigs:NewModule("Ignite")
BigWigsIgnite.revision = 20047
BigWigsIgnite.external = true
BigWigsIgnite.consoleCmd = "Ignite"

local L = AceLibrary("AceLocale-2.2"):new("BigWigsIgnite")

L:RegisterTranslations("enUS", function() return {
	["Ignite"] = true,
	["Options for the Ignite module."] = true,
	["Toggle Ignite bars on or off."] = true,
	["Bars"] = true,
	["Toggle Ignite messages on or off."] = true,
	["Messages"] = true,
	
	igniteDamage_trigger = "(.+) suffers (.+) Fire damage from (.+) Ignite.",
	
	igniteStacks_trigger1 = "(.+) is afflicted by Ignite.",
	igniteStacks_trigger2 = "(.+) is afflicted by Ignite %((.+)%).",
	
	ignite_bar = "Ignite ",
	
	refresh_trigger1 = "(.+) Fireball crits (.+) for (.+) Fire damage",
	refresh_trigger2 = "(.+) Scorch crits (.+) for (.+) Fire damage",
	refresh_trigger3 = "(.+) Fire Blast crits (.+) for (.+) Fire damage",
	refresh_trigger4 = "(.+) Pyroblast crits (.+) for (.+) Fire damage",
	
	fade_trigger = "Ignite fades from (.+).",
} end)

BigWigsIgnite.defaults = {
	bars = true,
	messages = true,
}

BigWigsIgnite.consoleOptions = {
	type = "group",
	name = L["Ignite"],
	desc = L["Options for the Ignite module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle Ignite bars on or off."],
			get = function() return BigWigsIgnite.db.profile.bars end,
			set = function(v)
				BigWigsIgnite.db.profile.bars = v
			end,
		},
		[L["Messages"]] = {
			type = "toggle",
			name = L["Messages"],
			desc = L["Toggle Ignite messages on or off."],
			get = function() return BigWigsIgnite.db.profile.messages end,
			set = function(v)
				BigWigsIgnite.db.profile.messages = v
			end,
		},
	}
}

local icon = {
	ignite = "Spell_Fire_Incinerate",
}

local timer = {
	ignite = 4,
}

function BigWigsIgnite:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("BigWigs_Ignite", 0)
	self:RegisterEvent("BigWigs_IgniteFade", 2)
	self:RegisterEvent("BigWigs_RefreshDamage", 4)
end

local isIgnited = false
igniteStack = 1


function BigWigsIgnite:Event(msg)
	local _,_,_,igniteDamage,ignitedPlayer = string.find(msg, L["igniteDamage_trigger"])
	local _,_,_,igniteStacks = string.find(msg, L["igniteStacks_trigger2"])
	
	if string.find(msg, L["igniteStacks_trigger1"]) then
		igniteStack = 1
		isIgnited = true
		self:TriggerEvent("BigWigs_SendSync", "ignite".." ".."?")
	end

	if string.find(msg, L["igniteStacks_trigger2"]) then
		igniteStack = igniteStacks
	end
	
	if string.find(msg, L["igniteDamage_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "refreshDamage".." "..igniteDamage.."dmg // "..igniteStack.."stacks")
		ignitePlayer = ignitedPlayer
	end

	if string.find(msg, L["refresh_trigger1"]) or string.find(msg, L["refresh_trigger2"]) or string.find(msg, L["refresh_trigger3"]) or string.find(msg, L["refresh_trigger4"]) then
		if isIgnited == true then
			if ignitePlayer == nil then
				ignitePlayer = "?"
			elseif ignitePlayer == "your" then
				ignitePlayer = UnitName("player")
			end
			self:TriggerEvent("BigWigs_SendSync", "ignite".." "..ignitePlayer)
		end
	end

	if string.find(msg, L["fade_trigger"]) then
			if ignitePlayer == nil then
				ignitePlayer = "?"
			elseif ignitePlayer == "your" then
				ignitePlayer = UnitName("player")
			end
		self:TriggerEvent("BigWigs_SendSync", "igniteFade".." "..ignitePlayer)
	end
end

function BigWigsIgnite:BigWigs_RecvSync(sync, rest, nick)
	if sync == "ignite" then
		self:TriggerEvent("BigWigs_Ignite",rest)
	elseif sync == "igniteFade" then
		self:TriggerEvent("BigWigs_IgniteFade",rest)
	elseif sync == "refreshDamage" then
		self:TriggerEvent("BigWigs_RefreshDamage",rest)
	end
end


function BigWigsIgnite:BigWigs_Ignite(rest)
	if self.db.profile.bars then
		self:RemoveBar(L["ignite_bar"]..rest)
		self:RemoveBar(L["ignite_bar"].."?")
		self:Bar(L["ignite_bar"]..rest, timer.ignite, icon.ignite, true, "black")
	end
end

function BigWigsIgnite:BigWigs_IgniteFade(rest)
	if self.db.profile.bars then
		self:RemoveBar(L["ignite_bar"]..rest)
		self:RemoveBar(L["ignite_bar"].."?")
		isIgnited = false
		ignitePlayer = nil
	end
end

function BigWigsIgnite:BigWigs_RefreshDamage(rest)
	if self.db.profile.messages then
		self:Message(rest, nil, nil, false)
	end
end

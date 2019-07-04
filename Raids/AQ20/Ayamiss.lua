
local module, L = BigWigs:ModuleDeclaration("Ayamiss the Hunter", "Ruins of Ahn'Qiraj")

module.revision = 20042
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sounds", "icon", "sacrifice", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ayamiss",

	sacrifice_cmd = "sacrifice",
	sacrifice_name = "Sacrifice Alert",
	sacrifice_desc = "Warn for Sacrifice",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on larva (requires promoted or higher)",
	
	bigicon_cmd = "bigicons",
	bigicon_name = "Kill the larva icon alert",
	bigicon_desc = "Shows a big icon when a larva spawns",
	
	sounds_cmd = "sounds",
	sounds_name = "Kill the larva sound alert",
	sounds_desc = "Sound effect when a larva spawns",
	
	sacrificeother_trigger = "(.*) is afflicted by Paralyze.",
	sacrificeyou_trigger = "(.*) are afflicted by Paralyze.",
	sacrificeend_trigger = "Paralyze fades from",
	
	sacrifice_bar = " Sacrificed!",
	larva_bar = "Larva >Click Me!<",
	nextlarva_bar = "Larva/Sacrifice CD",
	
	sacrificemsg_you = "You are Sacrificed!",
	sacrificemsg_other = " is Sacrificed!",
	
	p2_msg = "Phase 2",

	larvaname = "Hive'Zara Larva",	
} end )

local timer = {
	sacrifice = 10,
	larva = 9,
	larvacd = 15.5,
}

local icon = {
	larva = "Ability_creature_poison_01",
	sacrifice = "ability_creature_poison_05",
}

local syncName = {
	sacrifice = "AyamissSacrifice"..module.revision,
	p2 = "AyamissP2"..module.revision,
	larvaend = "AyamissLarvaEnd"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("UNIT_HEALTH")
	
	self:ThrottleSync(5, syncName.sacrifice)
	self:ThrottleSync(5, syncName.p2)
	self:ThrottleSync(3, syncName.larvaend)
end

function module:OnSetup()
self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if UnitName("target") == "Ayamiss the Hunter" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Ayamiss the Hunter")
	end
	local p2 = nil
	self:Bar(L["nextlarva_bar"], timer.larvacd, icon.larva)
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if msg == string.format(UNITDIESOTHER, L["larvaname"]) then
		self:Sync(syncName.larvaend)
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) <= 70 and not p2 then
			self:Sync(syncName.p2)
			p2 = true
		end
	end
end

function module:Event(msg)
	local _,_,sacrificeother = string.find(msg, L["sacrificeother_trigger"])
	if string.find(msg, L["sacrificeyou_trigger"]) then
		self:Sync(syncName.sacrifice.." "..UnitName("player"))
	elseif sacrificeother then
		self:Sync(syncName.sacrifice.." "..sacrificeother)
	end
	if string.find(msg, L["sacrificeend_trigger"]) then
		self:Sync(syncName.larvaend)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sacrifice then
	self:Bar(L["nextlarva_bar"], timer.larvacd, icon.larva)
		if rest ==	UnitName("player") then
			self:Message(L["sacrificemsg_you"], "Attention")
			self:Bar(rest..L["sacrifice_bar"], timer.sacrifice, icon.sacrifice)
		else
			self:Message(rest..L["sacrificemsg_other"], "Attention")
			self:Bar(rest..L["sacrifice_bar"], timer.sacrifice, icon.sacrifice)
			self:Bar(L["larva_bar"], timer.larva, icon.larva)
			self:SetCandyBarOnClick("BigWigsBar "..L["larva_bar"], function(name, button, extra) TargetByName(extra, true) end, "Hive'Zara Larva")
			self:Message("Kill the larva!", "Urgent")
			if self.db.profile.sounds then
				self:Sound("Beware")
			end
			if self.db.profile.bigicon then
				self:WarningSign(icon.larva, 0.7)
			end
		end
	elseif sync == syncName.p2 then
		self:Message(L["p2_msg"], "Attention")
		p2 = true
	elseif sync == syncName.larvaend then
		self:RemoveBar(L["larva_bar"])
		self:RemoveBar(L["sacrifice_bar"])
	end
end
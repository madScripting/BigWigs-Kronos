
local module, L = BigWigs:ModuleDeclaration("Gahz'ranka", "Zul'Gurub")

module.revision = 20044
module.enabletrigger = module.translatedName
module.toggleoptions = {"slam", "frost", "geyser", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gahzranka",

	frost_cmd = "frost",
	frost_name = "Frost Breath alert",
	frost_desc = "Warn when the boss is casting Frost Breath.",

	geyser_cmd = "geyser",
	geyser_name = "Massive Geyser alert",
	geyser_desc = "Warn when the boss is casting Massive Geyser.",
	
	slam_cmd = "slam",
	slam_name = "Gahz'ranka Slam alert",
	slam_desc = "Timer for Gahz'ranka Slam.",
	
	frost_trigger = "Gahz\'ranka begins to perform Frost Breath\.",
	frostcd_bar = "Frost Breath CD",
	frostcast_bar = "Frost Breath CAST",

	geyser_trigger = "Gahz\'ranka begins to cast Massive Geyser\.",
	geysercast_bar = "Massive Geyser CAST",
	geysercd_bar = "Massive Geyser CD",

	slam_trigger = "Gahz'ranka's Gahz'ranka Slam",
	slamcd_bar = "Slam CD",
} end )

local timer = {
	frostcast = 2,
	firstfrost = 22, --was 15
	frostcd = 19,
	
	firstslam = 3,
	slamcd = 10,
	
	geysercast = 1.5,
	firstgeyser = 20,
	geysercd = 20,
}

local icon = {
	frost = "Spell_Frost_FrostNova",
	geyser = "Spell_Frost_SummonWaterElemental",
	slam = "Ability_Devour",
}

local syncName = {
	frost = "GahzrankaFrostBreath"..module.revision,
	geyser = "GahzrankaMassiveGeyser"..module.revision,
	slam = "GahzrankaSlam"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	
	self:ThrottleSync(5, syncName.frost)
	self:ThrottleSync(5, syncName.geyser)
	self:ThrottleSync(5, syncName.slam)
end

function module:OnEngage()
	if self.db.profile.frost then
		self:Bar(L["frostcd_bar"], timer.firstfrost, icon.frost, true, "Blue")
	end
	if self.db.profile.slam then
		self:Bar(L["slamcd_bar"], timer.firstslam, icon.slam, true, "red")
	end
	if self.db.profile.geyser then
		self:Bar(L["geysercd_bar"], timer.firstgeyser, icon.geyser, true, "white")
	end
end

function module:OnSetup()
	self.started = nil
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["frost_trigger"]) then
		self:Sync(syncName.frost)
	end
	if string.find(msg, L["geyser_trigger"]) then
		self:Sync(syncName.geyser)
	end
	if string.find(msg, L["slam_trigger"]) then
		self:Sync(syncName.slam)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frost and self.db.profile.frost then
		self:Frost()
	elseif sync == syncName.geyser and self.db.profile.geyser then
		self:Geyser()
	elseif sync == syncName.slam and self.db.profile.slam then
		self:Slam()
	end
end

function module:Frost()
	self:RemoveBar(L["frostcd_bar"])
	self:Bar(L["frostcast_bar"], timer.frostcast, icon.frost, true, "Blue")
	self:DelayedBar(timer.frostcast, L["frostcd_bar"], timer.frostcd, icon.frost, true, "Blue")
end

function module:Geyser()
	self:RemoveBar(L["geysercd_bar"])
	self:Bar(L["geysercast_bar"], timer.geysercast, icon.geyser, true, "White")
	self:DelayedBar(timer.geysercast, L["geysercd_bar"],timer.geysercd, icon.geyser, true, "White")
end

function module:Slam()
	self:Bar(L["slamcd_bar"], timer.slamcd, icon.slam, true, "red")
end

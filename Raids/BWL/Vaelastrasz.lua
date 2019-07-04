
local module, L = BigWigs:ModuleDeclaration("Vaelastrasz the Corrupt", "Blackwing Lair")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"tankwarnings", "start", "flamebreath", "adrenaline", "whisper", "tankburn", "icon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Vaelastrasz",

	start_cmd = "start",
	start_name = "Start",
	start_desc = "Starts a bar for estimating the beginning of the fight.",

	flamebreath_cmd = "flamebreath",
	flamebreath_name = "Flame Breath",
	flamebreath_desc = "Warns when boss is casting Flame Breath.",

	adrenaline_cmd = "adrenaline",
	adrenaline_name = "Burning Adrenaline",
	adrenaline_desc = "Announces who received Burning Adrenaline and starts a clickable bar for easier selection.",

	whisper_cmd = "whisper",
	whisper_name = "Whisper",
	whisper_desc = "Whispers the players that got Burning Adrenaline, telling them to move away.",

	tankburn_cmd = "tankburn",
	tankburn_name = "Tank Burn",
	tankburn_desc = "Shows a bar for the Burning Adrenaline that will be applied on boss' target.",

	icon_cmd = "icon",
	icon_name = "Raid Icon",
	icon_desc = "Marks the player with Burning Adrenaline for easier localization.\n\n(Requires assistant or higher)",
	
	tankwarnings_cmd = "tankwarnings",
	tankwarnings_name = "Tank big icon Warnings",
	tankwarnings_desc = "Warns the tank getting Burning Adrenaline to pop Last Stand and Shield Wall.",
	
	adrenaline_trigger = "^(.+) (.+) afflicted by Burning Adrenaline\.",
	adrenaline_message = "%s has Burning Adrenaline!",
	adrenaline_message_you = "You have Burning Adrenaline! Go away!",
	adrenaline_bar = "Burning Adrenaline: %s",
	
	yell1 = "^Too late, friends",
	yell2 = "^I beg you, mortals",
	yell3 = "^FLAME! DEATH! DESTRUCTION!",
	start_trigger = "afflicted by Essence of the Red",
	start_bar = "Start",
	flamebreath_trigger = "Vaelastrasz the Corrupt begins to cast Flame Breath\.",

	tankburnsoon = "Burning Adrenaline on tank in 5 seconds!",
	tankburn_bar = "Tank Burn",

	breath_message = "Casting Flame Breath!",
	breath_bar = "Flame Breath",

	deathyou_trigger = "You die\.",
	deathother_trigger = "(.+) dies\.",

	are = "are",
} end)

local timer = {
	adrenaline = 20,
	flamebreath = 2,
	tankburn = 45,
	start1 = 36,
	start2 = 27,
	start3 = 15,
}

local icon = {
	adrenaline = "INV_Gauntlets_03",
	flamebreath = "Spell_Fire_Fire",
	tankburn = "INV_Gauntlets_03",
	start = "Spell_Holy_PrayerOfHealing",
	laststand = "spell_holy_ashestoashes",
	shieldwall = "ability_warrior_shieldwall",
}

local syncName = {
	adrenaline = "VaelAdrenaline",
	flamebreath = "VaelBreath",
	tankburn = "VaelTankBurn",
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")

	self:ThrottleSync(2, syncName.adrenaline)
	self:ThrottleSync(3, syncName.flamebreath)
	self:ThrottleSync(5, syncName.tankburn)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
	self.barstarted = false
	self.started = false
end

function module:OnEngage()
	self:Tankburn()
end

function module:OnDisengage()
end

function module:CheckForEngage()
	local function IsHostile()
		if UnitExists("target") and UnitName("target") == self:ToString() and UnitIsEnemy("player", "target") then
			return true
		end
		local num = GetNumRaidMembers()
		for i = 1, num do
			local raidUnit = string.format("raid%starget", i)
			if UnitExists(raidUnit) and UnitName(raidUnit) == self:ToString() and UnitIsEnemy("raid" .. i, raidUnit) then
				return true
			end
		end
		return false
	end
	if IsHostile() then
		BigWigs:CheckForEngage(self)
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["flamebreath_trigger"] then
		self:Sync(syncName.flamebreath)
	end
end

function module:CHAT_MSG_COMBAT_FRIENDLY_DEATH(msg)
	if self.engaged then
		BigWigs:CheckForWipe(self)
	end
	local _, _, deathother = string.find(msg, L["deathother_trigger"])
	if msg == L["deathyou_trigger"] then
		if self.db.profile.adrenaline then
			self:RemoveBar(string.format(L["adrenaline_bar"], UnitName("player")))
		end
	elseif deathother then
		if self.db.profile.adrenaline then
			self:RemoveBar(string.format(L["adrenaline_bar"], deathother))
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["yell1"]) and self.db.profile.start then
		self:Bar(L["start_bar"], timer.start1, icon.start, true, "Cyan")
		self.barstarted = true
	elseif string.find(msg, L["yell2"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["start_bar"], timer.start2, icon.start, true, "Cyan")
		self.barstarted = true
	elseif string.find(msg, L["yell3"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["start_bar"], timer.start3, icon.start, true, "Cyan")
	end
end

function module:Event(msg)
	local _, _, name, detect = string.find(msg, L["adrenaline_trigger"])
	if name and detect then
		if detect == L["are"] then
			name = UnitName("player")
		end
		self:Sync(syncName.adrenaline .. " "..name)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.flamebreath then
		self:Flamebreath()
	elseif sync == syncName.adrenaline and rest and rest ~= "" then
		self:Adrenaline(rest)
	elseif sync == syncName.tankburn then
		self:Tankburn()
	end
end

function module:Tankburn()
	if self.db.profile.tankburn then
		self:Bar(L["tankburn_bar"], timer.tankburn, icon.tankburn, true, "Black")
		self:DelayedMessage(timer.tankburn - 5, L["tankburnsoon"], "Urgent", nil, nil, true)
	end
end

function module:Flamebreath()
	if self.db.profile.flamebreath then
		self:Bar(L["breath_bar"], timer.flamebreath, icon.flamebreath, true, "Red")
		self:Message(L["breath_message"], "Urgent")
	end
end

function module:Adrenaline(name)
	if name then
		if self.db.profile.whisper and name ~= UnitName("player") then
			self:TriggerEvent("BigWigs_SendTell", name, L["adrenaline_message_you"])
		end
		if self.db.profile.adrenaline then
			self:Bar(string.format(L["adrenaline_bar"], name), timer.adrenaline, icon.adrenaline, true, "White")
			self:SetCandyBarOnClick("BigWigsBar "..string.format(L["adrenaline_bar"], name), function(name, button, extra) TargetByName(extra, true) end, name)
			if name == UnitName("player") then
				if playerClass == "WARRIOR" and self.db.profile.tankwarnings then
					self:WarningSign(icon.laststand, 3)
					self:Sound("laststand")
					self:DelayedWarningSign(timer.adrenaline - 11, icon.shieldwall, 3)
					self:DelayedSound(timer.adrenaline - 11, "shieldwall")
				else
					self:Message(L["adrenaline_message_you"], "Attention", true, "RunAway")
					self:WarningSign(icon.adrenaline, timer.adrenaline)
				end
			else
				self:Message(string.format(L["adrenaline_message"], name), "Urgent")
			end
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", name)
		end
		for i = 1, GetNumRaidMembers() do
			if UnitExists("raid" .. i .. "target") and UnitName("raid" .. i .. "target") == self.translatedName and UnitExists("raid" .. i .. "targettarget") and UnitName("raid" .. i .. "targettarget") == name then
				self:Sync(syncName.tankburn)
				break
			end
		end
	end
end

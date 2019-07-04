
local module, L = BigWigs:ModuleDeclaration("Ragnaros", "Molten Core")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sounds", "lava", "start", "aoeknock", "submerge", "emerge", "adds", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ragnaros",

	start_cmd = "start",
	start_name = "Start",
	start_desc = "Starts a bar for estimating the beginning of the fight.",

	emerge_cmd = "emerge",
	emerge_name = "Emerge alert",
	emerge_desc = "Warn for Ragnaros Emerge",

	adds_cmd = "adds",
	adds_name = "Son of Flame dies",
	adds_desc = "Warn when a son dies",

	submerge_cmd = "submerge",
	submerge_name = "Submerge alert",
	submerge_desc = "Warn for Ragnaros Submerge",

	aoeknock_cmd = "aoeknock",
	aoeknock_name = "Knockback alert",
	aoeknock_desc = "Warn for Wrath of Ragnaros knockback",

	bigicon_cmd = "bigicon",
	bigicon_name = "Alerts with Big Icons",
	bigicon_desc = "Shows a big icon when you are standing in the fire or knockback soon or knockback happened",
	
	sounds_cmd = "sounds",
	sounds_name = "Knockback soon and happened sound alert",
	sounds_desc = "Sound effect for knockback",
	
	lava_cmd = "Lava",
	lava_name = "Stand in lava alert",
	lava_desc = "Shows a big icon when you are standing in the fire",	
	
	engage_trigger = "^NOW FOR YOU",
	engage_soon_trigger1 = "Impudent whelps!",
	engage_soon_trigger2 = "TOO SOON! YOU HAVE AWAKENED ME TOO SOON",
	engage_soon_trigger3 = "YOU ALLOWED THESE INSECTS",
	nomana_message = "No mana allowed near tanks or Melee",
	FR_message = "Tanks, do you have 315FR?",
	
	hammer_trigger = "^BY FIRE BE PURGED!",

	knockback_trigger = "^TASTE",	
	knockback_message = "Knockback!",
	knockback_soon_message = "Melee OUT!",
	knockback_bar = "AoE knockback",
	
	emerge_soon_message = "15 sec until Ragnaros emerges!",
	emerge_message = "Ragnaros emerged, 3 minutes until submerge!",
	emerge_bar = "Ragnaros emerge",

	submerge_trigger = "^COME FORTH,",
	submerge_trigger2 = "^YOU CANNOT DEFEAT THE LIVING FLAME,",	
	submerge_60sec_message = "60 sec to submerge!",
	submerge_30sec_message = "30 sec to submerge!",
	submerge_10sec_message = "10 sec to submerge!",
	submerge_5sec_message = "5 sec to submerge!",
	submerge_message = "Ragnaros submerged. Incoming Sons of Flame!",
	submerge_bar = "Ragnaros submerge",

	sonofflame = "Son of Flame",
	sonsdeadwarn = "%d/8 Sons of Flame dead!",

	lava_trigger = "health for swimming in lava",

	["Combat"] = true,
} end)

local timer = {
	emerge_soon1 = 81,
	emerge_soon2 = 51,
	emerge_soon3 = 29,
	hammer_of_ragnaros = 11,
	emerge = 90,
	submerge = 180,
	knockback = 25,
	lava = 1,
}

local icon = {
	emerge_soon = "Inv_Hammer_Unique_Sulfuras",
	hammer_of_ragnaros = "Spell_Fire_Incinerate",
	emerge = "Spell_Fire_Volcano",
	submerge = "Spell_Fire_SelfDestruct",
	knockback = "Spell_Fire_SoulBurn",
	knockbackWarn = "Ability_Rogue_Sprint",
	lava = "Spell_Fire_Incinerate",
}

local syncName = {
	knockback = "RagnarosKnockback"..module.revision,
	sons = "RagnarosSonDead"..module.revision,
	submerge = "RagnarosSubmerge"..module.revision,
	emerge = "RagnarosEmerge"..module.revision,
}

local firstKnockback = true
local lastKnockback = nil
local sonsdead = 0
local phase = nil
module.wipemobs = { L["sonofflame"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS", "Event")

	self:ThrottleSync(5, syncName.knockback)
end

function module:OnSetup()
	self.started = nil
	lastKnockback = nil
	self.barstarted = false
	firstKnockback = true
	sonsdead = 0
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
end

function module:OnEngage()
	self:ScheduleRepeatingEvent("bwragnarosemergecheck", self.EmergeCheck, 1, self)
	self:EmergeCheck()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["lava_trigger"]) and self.db.profile.lava and self.db.profile.bigicon then
		self:WarningSign(icon.lava, timer.lava)
	end
	BigWigs:CheckForBossDeath(msg, self)
	if string.find(msg, L["sonofflame"]) then
		self:Sync(syncName.sons .. " " .. tostring(sonsdead + 1))
	end
	if string.find(msg, L["knockback_trigger"]) and self.db.profile.aoeknock then
		self:Sync(syncName.knockback)
	elseif string.find(msg, L["submerge_trigger"]) or string.find(msg, L["submerge_trigger2"]) then
		self:Sync(syncName.submerge)
	elseif string.find(msg, L["engage_trigger"]) then
		self:SendEngageSync()
	elseif string.find(msg, L["engage_soon_trigger1"]) and self.db.profile.start then
		self:Bar(L["Combat"], timer.emerge_soon1, icon.emerge_soon)
		self.barstarted = true
	elseif string.find(msg, L["engage_soon_trigger2"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["Combat"], timer.emerge_soon2, icon.emerge_soon)
		self.barstarted = true
		self:Message(L["nomana_message"], "Attention")
		self:Message(L["FR_message"], "Attention")
	elseif string.find(msg, L["engage_soon_trigger3"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["Combat"], timer.emerge_soon3, icon.emerge_soon)
	elseif string.find(msg ,L["hammer_trigger"]) then
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sons and rest and rest ~= "" then
		rest = tonumber(rest)
		if rest <= 8 and sonsdead < rest then
			sonsdead = rest
			if self.db.profile.adds then
				self:Message(string.format(L["sonsdeadwarn"], sonsdead), "Positive")
			end
			if sonsdead == 8 then
			end
		end
	elseif sync == syncName.knockback then
		self:Knockback()
	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.emerge then
		self:Emerge()
	end
end

function module:Submerge()
	phase = "submerged"
	self:CancelScheduledEvent("bwragnarosaekbwarn")
	_, _, lastKnockback = self:BarStatus(L["knockback_bar"])
	self:RemoveBar(L["knockback_bar"])
	self:CancelDelayedMessage(L["knockback_soon_message"])
	self:CancelDelayedWarningSign(icon.knockbackWarn)
	self:RemoveWarningSign(icon.knockbackWarn, true)
	self:ScheduleRepeatingEvent("bwragnarosemergecheck", self.EmergeCheck, 1, self)
	self:DelayedSync(timer.emerge, syncName.emerge)
	if self.db.profile.submerge then
		self:Message(L["submerge_message"], "Important")
	end
	if self.db.profile.emerge then
		self:Bar(L["emerge_bar"], timer.emerge, icon.emerge, true, "white")
		self:DelayedMessage(timer.emerge - 15, L["emerge_soon_message"], "Urgent", nil, nil, true)
	end
end

function module:Emerge()
	phase = "emerged"
	firstKnockback = true
	sonsdead = 0
	self:CancelDelayedSync(syncName.emerge)
	self:CancelScheduledEvent("bwragnarosemergecheck")
	self:CancelDelayedMessage(L["emerge_soon_message"])
	self:RemoveBar(L["emerge_bar"])
	self:Knockback()
	if self.db.profile.emerge then
		self:Message(L["emerge_message"], "Attention")
	end
	if self.db.profile.submerge then
		self:Bar(L["submerge_bar"], timer.submerge, icon.submerge, true, "white")
		self:DelayedMessage(timer.submerge - 60, L["submerge_60sec_message"], "Attention", nil, nil, true)
		self:DelayedMessage(timer.submerge - 30, L["submerge_30sec_message"], "Attention", nil, nil, true)
		self:DelayedMessage(timer.submerge - 10, L["submerge_10sec_message"], "Attention", nil, nil, true)
		self:DelayedMessage(timer.submerge - 5, L["submerge_5sec_message"], "Attention", nil, nil, true)
	end
end

function module:Knockback()
	if phase == "submerged" then
		self:Emerge()
	end
	if self.db.profile.aoeknock then
		if not firstKnockback then
			self:Message(L["knockback_message"], "Important")
			self:RemoveWarningSign(icon.knockbackWarn, true)
		end
		firstKnockback = false
		self:Bar(L["knockback_bar"], timer.knockback, icon.knockback, true, "blue")
		self:DelayedMessage(timer.knockback - 6, L["knockback_soon_message"], "Urgent")
		if self.db.profile.sounds then
			self:Sound("Info")
			self:DelayedSound(timer.knockback - 6, "meleeout")
		end
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.knockback - 6, icon.knockbackWarn, 20)
		end
	end
end

function module:EmergeCheck()
	if UnitExists("target") and UnitName("target") == module.translatedName and UnitExists("targettarget") and UnitName("targettarget") ~= "Majordomo Executus" then
		self:Sync(syncName.emerge)
		return
	end
	local num = GetNumRaidMembers()
	for i = 1, num do
		local raidUnit = string.format("raid%starget", i)
		if UnitExists(raidUnit) and UnitName(raidUnit) == module.translatedName and UnitExists(raidUnit .. "target") and UnitName(raidUnit .. "target") ~= "Majordomo Executus" then
			self:Sync(syncName.emerge)
			return
		end
	end
end

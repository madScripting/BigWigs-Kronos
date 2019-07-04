
local module, L = BigWigs:ModuleDeclaration("Ouro", "Ahn'Qiraj")

module.revision = 20047
module.enabletrigger = module.translatedName
module.toggleoptions = {"popcorn", "sounds", "bigicon", "sweep", "sandblast", -1, "emerge", "submerge", -1, "berserk", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ouro",

	sweep_cmd = "sweep",
	sweep_name = "Sweep Alert",
	sweep_desc = "Warn for Sweeps",
	
	popcorn_cmd = "popcorn",
	popcorn_name = "Popcorn Alert",
	popcorn_desc = "Warns when you take damage from Popcorn",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon Alerts",
	bigicon_desc = "BigIcon Alert for Sweep, Submerge, Emerge, Popcorn",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound Alerts",
	sounds_desc = "Sound Alert for Sweep, Submerge, Emerge, Popcorn",

	sandblast_cmd = "sandblast",
	sandblast_name = "Sandblast Alert",
	sandblast_desc = "Warn for Sandblasts",

	emerge_cmd = "emerge",
	emerge_name = "Emerge Alert",
	emerge_desc = "Warn for Emerge",

	submerge_cmd = "submerge",
	submerge_name = "Submerge Alert",
	submerge_desc = "Warn for Submerge",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for when Ouro goes berserk",

	sweep_trigger = "Ouro begins to cast Sweep",
	sweepannounce = "Sweep!",
	sweepwarn = "Sweep in 5",
	sweepbartext = "Sweep",

	sandblast_trigger = "Ouro begins to perform Sand Blast",
	sandblastannounce = "Incoming Sand Blast!",
	sandblastwarn = "Sand Blast in 5",
	sandblastbartext = "Sand Blast",
	
	sandblasted_trigger = "You are afflicted by Sand Blast.",

	emerge_trigger = "Ground Rupture",
	emergewarn = "10 seconds until Ouro Emerges!",
	emergeannounce = "Ouro has emerged!",	
	emergebartext = "Ouro Emerges",

	submergeannounce = "Ouro has submerged!",	
	submergewarn = "Submerge in 8sec!",
	submergebartext = "Ouro Submerges",
	
	berserk_trigger = "Ouro gains Berserk.",
	berserkannounce = "Berserk!",
	berserksoonwarn = "Berserk Soon - Get Ready!",
	
	hit_trigger = "hits Ouro for",
	
	popcorn_trigger = "Dirt Mound's Quake hits you for",
} end )

local timer = {
	nextSubmerge = 90,
	sweep = 1.5,
	firstSweep = 20,
	sweepInterval = 20,
	sandblast = 2,
	firstSandblast = 25,
	sandblastInterval = 25,
	nextEmerge = 30,
}

local icon = {
	sweep = "Ability_creature_cursed_04",
	sandblast = "Spell_Nature_Cyclone",
	submerge = "Spell_magic_polymorphchicken",
	popcorn = "Spell_Nature_Earthquake",
	collapse = "Ability_Marksmanship",
	enrage = "ability_druid_challangingroar",
}

local syncName = {
	sweep = "OuroSweep"..module.revision,
	sandblast = "OuroSandblast"..module.revision,
	emerge = "OuroEmerge"..module.revision,
	submerge = "OuroSubmerge"..module.revision,
	berserk = "OuroBerserk"..module.revision,
}

local berserkannounced = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.sweep)
	self:ThrottleSync(10, syncName.sandblast)
	self:ThrottleSync(10, syncName.emerge)
	self:ThrottleSync(10, syncName.submerge)
	self:ThrottleSync(10, syncName.berserk)

	self:ScheduleRepeatingEvent("bwouroengagecheck", self.EngageCheck, 0.5, self)
end

function module:OnSetup()
	berserkannounced = nil
	self.started = nil
	self.phase = nil
end

function module:OnEngage()
	self.phase = "emerged"
	self:ScheduleEvent("bwourosubmergecheck", self.DoSubmergeCheck, 5, self)
	if UnitName("target") == "Ouro" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Ouro")
	end
	if self.db.profile.emerge then
		self:PossibleSubmerge()
	end
	if self.db.profile.sandblast then
		self:DelayedMessage(timer.firstSandblast - 5, L["sandblastwarn"], "Important")
		self:Bar(L["sandblastbartext"], timer.firstSandblast, icon.sandblast, true, "red")
	end
	if self.db.profile.sweep then
		self:DelayedMessage(timer.firstSweep - 5, L["sweepwarn"])
		self:Bar(L["sweepbartext"], timer.firstSweep, icon.sweep, true, "blue")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.sweepInterval - 5, icon.sweep, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.sweepInterval - 5, "Info")
		end
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["hit_trigger"]) then
		if klhtm.target.targetismaster("Ouro") ~= true then
			if UnitName("target") == "Ouro" and (IsRaidLeader() or IsRaidOfficer()) then
				klhtm.net.sendmessage("target " .. "Ouro")
			end
		end
	end
	if string.find(msg, L["berserk_trigger"]) then
		self:Sync(syncName.berserk)
	end
	if string.find(msg, L["emerge_trigger"]) then
		self:Sync(syncName.emerge)
	end
	if string.find(msg, L["sweep_trigger"]) then
		self:Sync(syncName.sweep)
	end
	if string.find(msg, L["sandblast_trigger"]) then
		self:Sync(syncName.sandblast)
	end
	if string.find(msg, L["popcorn_trigger"]) and self.db.profile.popcorn then
		self:Popcorn()
	end
	if string.find(msg, L["sandblasted_trigger"]) then
		self:KTM_Sandblast()
		--klhtm.net.sendmessage("event " .. "sandblast")
		
		--local message = "t " .. myraidthreat
		--me.sendmessage(message)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sweep and self.db.profile.sweep then
		self:Sweep()
	elseif sync == syncName.sandblast and self.db.profile.sandblast then
		self:Sandblast()
	elseif sync == syncName.emerge then
		self:Emerge()
	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.berserk then
		self:Berserk()
	end
end

function module:KTM_Sandblast()
	--klhtm.net.sendmessage("t " .. "1 ")
end

function module:Popcorn()
	if self.db.profile.bigicon then
		self:WarningSign(icon.popcorn, 0.7)
	end
	if self.db.profile.sounds then
		self:Sound("Info")
	end
end

function module:Sweep()
	self:RemoveBar(L["sweepbartext"])
	self:Bar(L["sweepannounce"], timer.sweep, icon.sweep, true, "blue")
	self:Message(L["sweepannounce"], "Important", true, "Alarm")
	self:DelayedMessage(timer.sweepInterval - 5, L["sweepwarn"])
	self:DelayedBar(timer.sweep, L["sweepbartext"], timer.sweepInterval-timer.sweep, icon.sweep, true, "blue")
	if self.db.profile.bigicon then
		self:DelayedWarningSign(timer.sweepInterval - 5, icon.sweep, 0.7)
	end
	if self.db.profile.sounds then
		self:DelayedSound(timer.sweepInterval - 5, "Info")
	end	
end

function module:Sandblast()
	self:RemoveBar(L["sandblastbartext"])
	self:Message(L["sandblastannounce"], "Important", true, "Alert")
	self:Bar(L["sandblastannounce"], timer.sandblast, icon.sandblast, true, "red")
	self:DelayedMessage(timer.sandblastInterval - 5, L["sandblastwarn"], "Important")
	self:DelayedBar(timer.sandblast, L["sandblastbartext"], timer.sandblastInterval-timer.sandblast, icon.sandblast, true, "red")
end

function module:Emerge()
	if self.phase ~= "berserk" then
		self.phase = "emerged"
		self:CancelScheduledEvent("bwourosubmergecheck")
		self:ScheduleEvent("bwourosubmergecheck", self.DoSubmergeCheck, 5, self)
		self:CancelDelayedMessage(L["emergewarn"])
		self:RemoveBar(L["submergebartext"])
		if self.db.profile.emerge then
			self:Message(L["emergeannounce"])
			if self.db.profile.sounds then
				self:Sound("Beware")
			end
			self:PossibleSubmerge()
		end
		if self.db.profile.sweep then
			self:DelayedMessage(timer.sweepInterval - 5, L["sweepwarn"])
			self:Bar(L["sweepbartext"], timer.sweepInterval, icon.sweep, true, "blue")
			if self.db.profile.bigicon then
				self:DelayedWarningSign(timer.sweepInterval - 5, icon.sweep, 0.7)
			end
			if self.db.profile.sounds then
				self:DelayedSound(timer.sweepInterval - 5, "Info")
			end	
		end
		if self.db.profile.sandblast then
			self:DelayedMessage(timer.sandblastInterval - 5, L["sandblastwarn"], "Important")
			self:Bar(L["sandblastbartext"], timer.sandblastInterval, icon.sandblast, true, "red")
		end
	end
end

function module:PossibleSubmerge()
	if self.db.profile.emerge then
		self:DelayedMessage(timer.nextSubmerge-8, L["submergewarn"])
		self:Bar(L["submergebartext"], timer.nextSubmerge, icon.submerge, true, "white")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.nextSubmerge-8, icon.submerge, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.nextSubmerge-8, "RunAway")
		end
	end
end

function module:Submerge()
	self.phase = "submerged"
	self:CancelDelayedWarningSign(icon.sweep)
	self:CancelDelayedSound("Info")
	self:CancelDelayedMessage(L["sweepwarn"])
	self:CancelDelayedMessage(L["sandblastwarn"])
	self:CancelDelayedMessage(L["submergewarn"])
	self:RemoveBar(L["sweepbartext"])
	self:RemoveBar(L["sandblastbartext"])
	self:RemoveBar(L["emergebartext"])
	self:RemoveBar(L["submergebartext"])
	if self.db.profile.submerge then
		self:Message(L["submergeannounce"], "Important")
		self:DelayedMessage(timer.nextEmerge-10, L["emergewarn"], "Important")
			if self.db.profile.bigicon then
				self:DelayedWarningSign(timer.nextEmerge-10, icon.collapse, 0.7)
			end
		self:Bar(L["emergebartext"], timer.nextEmerge, icon.submerge, true, "white")
	end
end

function module:Berserk()
	self.phase = "berserk"
	self:CancelDelayedMessage(L["emergewarn"])
	self:RemoveBar(L["emergebartext"])
	self:RemoveBar(L["submergebartext"])
	self:CancelDelayedWarningSign(icon.submerge)
	self:CancelDelayedSound("RunAway")
	if self.db.profile.berserk then
		self:Message(L["berserkannounce"])
		if self.db.profile.bigicon then
			self:WarningSign(icon.enrage, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Beware")
		end
	end
end

function module:IsOuroVisible()
	if UnitName("playertarget") == self.translatedName then
		return true
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == self.translatedName then
				return true
			end
		end
	end
	return false
end

function module:SubmergeCheck()
	if self.phase == "emerged" then
		if not UnitIsDeadOrGhost("player") and not self:IsOuroVisible() then
			self:DebugMessage("OuroSubmerge")
			self:Sync(syncName.submerge)
		end
	end
end

function module:DoSubmergeCheck()
	self:ScheduleRepeatingEvent("bwourosubmergecheck", self.SubmergeCheck, 0.5, self)
end

function module:EngageCheck()
	if not self.engaged then
		if self:IsOuroVisible() then
			module:CancelScheduledEvent("bwouroengagecheck")

			module:SendEngageSync()
		end
	else
		module:CancelScheduledEvent("bwouroengagecheck")
	end
end

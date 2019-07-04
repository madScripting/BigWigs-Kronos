
local module, L = BigWigs:ModuleDeclaration("Gothik the Harvester", "Naxxramas")

L:RegisterTranslations("enUS", function() return {
	cmd = "Gothik",

	room_cmd = "room",
	room_name = "Room Arrival Warnings",
	room_desc = "Warn for Gothik's arrival",

	add_cmd = "add",
	add_name = "Add Warnings",
	add_desc = "Warn for adds",
	
	shackle_cmd = "shackle",
	shackle_name = "Shackle timer bars",
	shackle_desc = "Timer bars for Shackle Undead on adds",

	adddeath_cmd = "adddeath",
	adddeath_name = "Add Death Alert",
	adddeath_desc = "Alerts when an add dies.",

	disabletrigger = "I... am... undone.",

	starttrigger1 = "Brazenly you have disregarded powers beyond your understanding.",
	starttrigger2 = "Teamanare shi rikk mannor rikk lok karkun",

	rider_name = "Unrelenting Rider",
	spectral_rider_name = "Spectral Rider",
	deathknight_name = "Unrelenting Deathknight",
	spectral_deathknight_name = "Spectral Deathknight",
	trainee_name = "Unrelenting Trainee",
	spectral_trainee_name = "Spectral Trainee",

	riderdiewarn = "Rider dead!",
	dkdiewarn = "Death Knight dead!",

	warn_inroom_30 = "In room in 30 seconds",
	warn_inroom_10 = "Gothik Incoming in 10 seconds",

	wave = "%d/22: ",

	trawarn = "Trainees in 3 seconds",
	dkwarn = "Deathknight in 3 seconds",
	riderwarn = "Rider in 3 seconds",

	trabar = "Trainee - %d",
	dkbar = "Deathknight - %d",
	riderbar = "Rider - %d",

	inroomtrigger = "I have waited long enough! Now, you face the harvester of souls.",
	inroomtrigger2 = "I have waited long enough! Now, you face the harvester of souls!",
	inroomwarn = "He's in the room!",

	inroombartext = "In Room",
	sideSwitch_bar = "Switching side", --no trigger, 45sec timer guessing he opens the gate if he is low enough on that timer end
	
	shackleDk_trigger = "Unrelenting Deathknight is afflicted by Shackle Undead.",
	shackleDkEnd_trigger = "Shackle Undead fades from Unrelenting Deathknight",
	shackleDk_bar = "Shackle DK",
} end )

module.revision = 20050
module.enabletrigger = module.translatedName
module.wipemobs = { L["rider_name"], L["deathknight_name"], L["trainee_name"], L["spectral_rider_name"], L["spectral_deathknight_name"], L["spectral_trainee_name"] }
module.toggleoptions = {"room", -1, "shackle", "add", "adddeath", "bosskill"}

local timer = {
	inroom = 274,
	firstTrainee = 24,
	trainee = 20,
	firstDeathknight = 74,
	deathknight = 25,
	firstRider = 134,
	rider = 30,
	shackle = 50,
	sideSwitch = 45,
}

local icon = {
	inroom = "Spell_Magic_LesserInvisibilty",
	sideSwitch = "Spell_Magic_LesserInvisibilty",
	trainee = "Ability_Seal",
	deathknight = "INV_Boots_Plate_08",
	rider = "Spell_Shadow_DeathPact",
	shackle = "spell_nature_slow",
}

local syncName = {
	shackleDk = "GothikShackleDk"..module.revision,
	shackleDkEnd = "GothikShackleDkEnd"..module.revision,
	inRoom = "GothikInRoom"..module.revision,
}

local wave = 0
local numTrainees = 0
local numDeathknights = 0
local numRiders = 0

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:ThrottleSync(1, syncName.shackleDk)
	self:ThrottleSync(1, syncName.shackleDkEnd)
	self:ThrottleSync(20, syncName.shackleDkEnd)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self.started = nil
	wave = 0
	numTrainees = 0
	numDeathknights = 0
	numRiders = 0
end

function module:OnEngage()
	waitDk = nil
	if self.db.profile.room then
		self:Bar(L["inroombartext"], timer.inroom, icon.inroom, true, "white")
		self:DelayedMessage(timer.inroom - 30, L["warn_inroom_30"], "Important")
		self:DelayedMessage(timer.inroom - 10, L["warn_inroom_10"], "Important")
	end
	if self.db.profile.add then
		self:Trainee()
		self:DeathKnight()
		self:Rider()
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["shackleDkEnd_trigger"]) and waitDk == false then
		self:Sync(syncName.shackleDkEnd)
	end
	if string.find(msg, L["shackleDk_trigger"]) then
		self:Sync(syncName.shackleDk)
		waitDk = true
		self:ScheduleEvent("setDkFalse", self.SetWaitDk, 1)
	end
end

function module:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["inroomtrigger"] then
		klhtm.net.clearraidthreat()
		self:Sync(syncName.inRoom)
	end
	if msg == L["inroomtrigger2"] then
		klhtm.net.clearraidthreat()
		self:Sync(syncName.inRoom)
	end
	if string.find(msg, L["disabletrigger"]) then
		self:SendBossDeathSync()
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH( msg )
	BigWigs:CheckForBossDeath(msg, self)
	if self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["rider_name"]) then
		self:Message(L["riderdiewarn"], "Important")
	elseif self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["deathknight_name"]) then
		self:Message(L["dkdiewarn"], "Important")
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shackleDk and self.db.profile.shackle then
		self:ShackleDk()
	elseif sync == syncName.shackleDkEnd and self.db.profile.shackle then
		self:ShackleDkEnd()
	elseif sync == syncName.inRoom and self.db.profile.room then
		self:InRoom()
	end
end

function module:InRoom()
	self:Message(L["inroomwarn"], "Important")
	self:StopRoom()
end

function module:StopRoom()
	self:RemoveBar(L["inroombartext"])
	self:CancelDelayedMessage(L["warn_inroom_30"])
	self:CancelDelayedMessage(L["warn_inroom_10"])
	wave = 0
	numTrainees = 0
	numDeathknights = 0
	numRiders = 0
	self:Bar(L["sideSwitch_bar"], timer.sideSwitch, icon.sideSwitch, true, "white")
	self:DelayedBar(timer.sideSwitch, L["sideSwitch_bar"], timer.sideSwitch, icon.sideSwitch, true, "white")
end

function module:SetWaitDk()
	waitDk=false
end

function module:ShackleDk()
	self:Bar(L["shackleDk_bar"], timer.shackle, icon.shackle, true, "yellow")
end

function module:ShackleDkEnd()
	self:RemoveBar(L["shackleDk_bar"])
end

function module:WaveWarn(message, L, color)
	wave = wave + 1
	if self.db.profile.add then
		self:Message(string.format(L["wave"], wave) .. message, color)
	end
end

function module:Trainee()
	numTrainees = numTrainees + 1
	local traineeTime = timer.trainee
	if numTrainees == 1 then
		traineeTime = timer.firstTrainee
	end
	if self.db.profile.add then
		self:Bar(string.format(L["trabar"], numTrainees), traineeTime, icon.trainee, true, "green")
	end
	self:ScheduleEvent("bwgothiktrawarn", self.WaveWarn, traineeTime - 3, self, L["trawarn"], L, "Attention")
	self:ScheduleRepeatingEvent("bwgothiktrarepop", self.Trainee, traineeTime, self)
	if numTrainees >= 12 then
		self:RemoveBar(string.format(L["trabar"], numTrainees))
		self:CancelScheduledEvent("bwgothiktrawarn")
		self:CancelScheduledEvent("bwgothiktrarepop")
		numTrainees = 0
	end
end

function module:DeathKnight()
	numDeathknights = numDeathknights + 1
	local deathknightTime = timer.deathknight
	if numDeathknights == 1 then
		deathknightTime = timer.firstDeathknight
	end
	if self.db.profile.add then
		self:Bar(string.format(L["dkbar"], numDeathknights), deathknightTime, icon.deathknight, true, "red")
	end
	self:ScheduleEvent("bwgothikdkwarn", self.WaveWarn, deathknightTime - 3, self, L["dkwarn"], L, "Urgent")
	self:ScheduleRepeatingEvent("bwgothikdkrepop", self.DeathKnight, deathknightTime, self)
	if numDeathknights >= 8 then
		self:RemoveBar(string.format(L["dkbar"], numDeathknights))
		self:CancelScheduledEvent("bwgothikdkwarn")
		self:CancelScheduledEvent("bwgothikdkrepop")
		numDeathknights = 0
	end
end

function module:Rider()
	numRiders = numRiders + 1
	local riderTime = timer.rider
	if numRiders == 1 then
		riderTime = timer.firstRider
	end
	if self.db.profile.add then
		self:Bar(string.format(L["riderbar"], numRiders), riderTime, icon.rider, true, "blue")
	end
	self:ScheduleEvent("bwgothikriderwarn", self.WaveWarn, riderTime - 3, self, L["riderwarn"], L, "Important")
	self:ScheduleRepeatingEvent("bwgothikriderrepop", self.Rider, riderTime, self)
	if numRiders >= 5 then
		self:RemoveBar(string.format(L["riderbar"], numRiders))
		self:CancelScheduledEvent("bwgothikriderwarn")
		self:CancelScheduledEvent("bwgothikriderrepop")
		numRiders = 0
	end
end

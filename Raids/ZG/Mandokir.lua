
local module, L = BigWigs:ModuleDeclaration("Bloodlord Mandokir", "Zul'Gurub")

module.revision = 20042
module.enabletrigger = module.translatedName
module.wipemobs = {"Ohgan"}
module.toggleoptions = {"guillotine", "charge", "sounds", "bigicon", "sunder", "gaze", "announce", "icon", "whirlwind", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Mandokir",

	announce_cmd = "whispers",
	announce_name = "Whisper watched players",
	announce_desc = "Warn when boss uses Threatening Gaze.\n\n(Requires assistant or higher)",
	
	guillotine_cmd = "guillotine",
	guillotine_name = "Gaze fail alert",
	guillotine_desc = "Announces who failed the Gaze",

	icon_cmd = "icon",
	icon_name = "Raid icon on watched players",
	icon_desc = "Place a raid icon on the watched person.\n\n(Requires assistant or higher)",

	gaze_cmd = "gaze",
	gaze_name = "Threatening Gaze alert",
	gaze_desc = "Shows bars for Threatening Gaze",

	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind Alert",
	whirlwind_desc = "Shows Whirlwind bars",
	
	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Shows Charge bars",

	enrage_cmd = "enraged",
	enrage_name = "Enrage alert",
	enrage_desc = "Announces the boss' Enrage",

	bigicon_cmd = "bigicon",
	bigicon_name = "WW and Gaze big icon alert",
	bigicon_desc = "Shows a big icon when whirlwind is happening and Gaze is on you",

	sunder_cmd = "sunder",
	sunder_name = "5 sunder stacks on you alert",
	sunder_desc = "Alerts Ohgan's tank to get help if he has 5 stacks of Sunder Armor on him.",
	
	sounds_cmd = "sounds",
	sounds_name = "Gaze, 5Sunders and WW sound alert",
	sounds_desc = "Sound alert Gaze is on you, when you have 5 stacks of sunder on you, when whirlwind is happening.",
	
	engage_trigger = "feed your souls to Hakkar himself",

	charge_trigger = "Bloodlord Mandokir's Charge",
	chargecd_bar = "Charge CD",
	
	gaze_trigger = "(.+)! I'm watching you!",
	gazeend_trigger = "Threatening Gaze fades from",
	gaze_warn = "Gaze on ",
	gaze_whisper = "Gaze on you, STOP EVERYTHING!",
	gazecd_bar = "Gaze CD",
	gazed_bar = "Gaze on ",
	gazecast_bar = "Casting Gaze on ",
	
	enrage_trigger = "Bloodlord Mandokir gains Enrage.",
	enrageend_trigger = "Enrage fades from Bloodlord Mandokir.",
	enrage_warn = "Ohgan down! Mandokir enraged!",
	enrage_bar = "Enrage",
	
	ww_trigger = "Bloodlord Mandokir gains Whirlwind.",
	wwcd_bar = "Whirlwind CD",
	wwcast_bar = "Whirlwind!",
	
	sunder_trigger = "Sunder Armor %(5%)",
	sunder_warn = "Too many Sunder stacks, seek help!",
	
	guillotine_trigger1 = "Guillotine (.+) (.+) for",
	guillotine_trigger2 = "Guillotine missed (.+).",
	guillotine_trigger3 = "Guillotine was (.+) by (.+).",
	guillotine_warn = " failed the Gaze...",
} end )


local timer = {
	charge = 34,
	whirlwindCast = 2,
	whirlwind = 15,
	gaze = 20,
	gazed = 6,
	gazecast = 2,
}

local icon = {
	charge = "Ability_Warrior_Charge",
	whirlwind = "Ability_Whirlwind",
	gaze = "Spell_Shadow_Charm",
}

local syncName = {
	whirlwind = "MandokirWWStart"..module.revision,
	enrage = "MandokirEnrageStart"..module.revision,
	enrageOver = "MandokirEnrageEnd"..module.revision,
	gaze = "MandokirGaze"..module.revision,
	charge = "MandokirCharge"..module.revision,
	gazeEnd = "MandokirGazeEnd"..module.revision,
	guillotine = "MandokirGuillotine"..module.revision,
}

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	
	self:ThrottleSync(5, syncName.whirlwind)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.enrageOver)
	self:ThrottleSync(5, syncName.gaze)
	self:ThrottleSync(5, syncName.charge)
	self:ThrottleSync(5, syncName.gazeEnd)
	self:ThrottleSync(5, syncName.guillotine)
end

function module:OnSetup()
end

function module:OnEngage()
	self:Bar(L["chargecd_bar"], timer.charge, icon.charge, true, "yellow")
	self:Bar(L["wwcd_bar"], timer.whirlwind, icon.whirlwind, true, "blue")
	self:Bar(L["gazecd_bar"], timer.gaze, icon.gaze, true, "red")
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	local _,_,gazedplayer = string.find(msg, L["gaze_trigger"])
	if string.find(msg, L["gaze_trigger"]) then
		self:Sync(syncName.gaze.." "..gazedplayer)
	end
end

function module:Event(msg)
	local _,_,_,guillotineplayer1 = string.find(msg, L["guillotine_trigger1"])
	local _,_,guillotineplayer2 = string.find(msg, L["guillotine_trigger2"])
	local _,_,_,guillotineplayer3 = string.find(msg, L["guillotine_trigger3"])
	if string.find(msg, L["guillotine_trigger1"]) then
		self:Sync(syncName.guillotine.." "..guillotineplayer1)
	end
	if string.find(msg, L["guillotine_trigger2"])then
		self:Sync(syncName.guillotine.." "..guillotineplayer2)
	end
	if string.find(msg, L["guillotine_trigger3"])then
		self:Sync(syncName.guillotine.." "..guillotineplayer3)
	end
	if string.find(msg, L["sunder_trigger"]) and self.db.profile.sunder then
		self:Sunder()
	end
	if string.find(msg, L["ww_trigger"]) then
		self:Sync(syncName.whirlwind)
	end	
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["enrageend_trigger"]) then
		self:Sync(syncName.enrageOver)
	end
	if string.find(msg, L["charge_trigger"]) then
		self:Sync(syncName.charge)
	end
	if string.find(msg, L["gazeend_trigger"]) then
		self:Sync(syncName.gazeEnd)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.gaze and self.db.profile.gaze then
		self:Gaze(rest)
	elseif sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.enrageOver and self.db.profile.enrage then
		self:EnrageOver()
	elseif sync == syncName.charge and self.db.profile.charge then
		self:Charge()
	elseif sync == syncName.gazeEnd then
		self:GazeEnd()
	elseif sync == syncName.guillotine and self.db.profile.guillotine then
		self:Guillotine(rest)
	end
end

function module:Whirlwind()
	self:RemoveBar(L["wwcd_bar"])
	self:Bar(L["wwcd_bar"], timer.whirlwind, icon.whirlwind, true, "blue")
	self:Bar(L["wwcast_bar"], timer.whirlwindCast, icon.whirlwind, true, "blue")
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		if self.db.profile.bigicon then
			self:WarningSign(icon.whirlwind, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Info")
		end
	end
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Urgent")
	self:Bar(L["enrage_bar"], 90, "Spell_Shadow_UnholyFrenzy", true, "white")
end

function module:EnrageOver()
	self:RemoveBar(L["enrage_bar"])
end

function module:Charge()
	self:RemoveBar(L["chargecd_bar"])
	self:Bar(L["chargecd_bar"], timer.charge, icon.charge, true, "yellow")
end

function module:Sunder()
	self:Message(L["sunder_warn"], "Attention")
	if self.db.profile.sounds then
		self:Sound("stacks")
	end
end

function module:Gaze(rest)
	self:RemoveBar(L["gazecd_bar"])
	self:Bar(L["gazecd_bar"], timer.gaze, icon.gaze, true, "red")
	if rest == UnitName("player") then
		self:Message(L["gaze_warn"].."you! STOP ALL ACTION!", "Urgent")
		self:Bar(L["gazecast_bar"].."you!",timer.gazecast, icon.gaze, true, "red")
		self:DelayedBar(timer.gazecast, L["gazed_bar"].."you!", timer.gazed, icon.gaze, true, "red")
		if self.db.profile.sounds then
			self:Sound("Beware")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.gaze, timer.gazed)
		end
	else
		self:Message(L["gaze_warn"]..rest, "Important")
		self:Bar(L["gazecast_bar"]..rest,timer.gazecast, icon.gaze, true, "red")
		self:DelayedBar(timer.gazecast, L["gazed_bar"]..rest, timer.gazed, icon.gaze, true, "red")
		if self.db.profile.announce then
			self:TriggerEvent("BigWigs_SendTell", rest, L["gaze_whisper"])
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", rest)
		end
	end
end

function module:GazeEnd()
	self:TriggerEvent("BigWigs_RemoveRaidIcon")
end

function module:Guillotine(rest)
	self:Message(rest..L["guillotine_warn"])
end
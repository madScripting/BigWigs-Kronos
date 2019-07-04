
local module, L = BigWigs:ModuleDeclaration("Ebonroc", "Blackwing Lair")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "curse", "wingbuffet", "shadowflame", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ebonroc",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn when Ebonroc casts Wing Buffet.",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn when Ebonroc casts Shadow Flame.",

	curse_cmd = "curse",
	curse_name = "Shadow of Ebonroc warnings",
	curse_desc = "Shows a timer bar and announces who gets Shadow of Ebonroc.",

	bigicon_cmd = "bigicons",
	bigicon_name = "Taunt for WingBuffet big icon alert",
	bigicon_desc = "Shows a big icon when you should taunt",
	
	wingbuffet_trigger = "Ebonroc begins to cast Wing Buffet.",	
	wingbuffet_message = "Wing Buffet! Next one in 30 seconds!",
	wingbuffet_warning = "TAUNT now! Wing Buffet soon!",
	wingbuffetcast_bar = "Wing Buffet",
	wingbuffet_bar = "Next Wing Buffet",
	wingbuffet1_bar = "Initial Wing Buffet",

	shadowflame_trigger = "Ebonroc begins to cast Shadow Flame.",
	shadowflame_warning = "Shadow Flame incoming!",	
	shadowflame_bar = "Shadow Flame",
	shadowflame_Nextbar = "Next Shadow Flame",

	shadowcurseyou_trigger = "You are afflicted by Shadow of Ebonroc\.",
	shadowcurseother_trigger = "(.+) is afflicted by Shadow of Ebonroc\.",
	shadowcurse_message_you = "You have Shadow of Ebonroc!",
	shadowcurse_message_taunt = "%s has Shadow of Ebonroc! TAUNT!",
	shadowcurse_bar = "%s - Shadow of Ebonroc",
	shadowcurse_Firstbar = "Initial Shadow of Ebonroc",
	
	taunt_trigger = "Ebonroc is afflicted by Taunt",
	tauntyouresist_trigger = "Your Taunt was resisted by Ebonroc",
} end)

local timer = {
	wingbuffet = 30,
	wingbuffetCast = 1,
	curse = 8,
	earliestShadowflame = 10.5,
	latestShadowflame = 14.5,
	shadowflameCast = 2,
}

local icon = {
	wingbuffet = "INV_Misc_MonsterScales_14",
	curse = "Spell_Shadow_GatherShadows",
	shadowflame = "Spell_Fire_Incinerate",
	taunt = "spell_nature_reincarnation",
}

local syncName = {
	wingbuffet = "EbonrocWingBuffet"..module.revision,
	shadowflame = "EbonrocShadowflame"..module.revision,
	curse = "EbonrocShadow"..module.revision,
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")
	
	self:ThrottleSync(10, syncName.wingbuffet)
	self:ThrottleSync(5, syncName.shadowflame)
	self:ThrottleSync(5, syncName.curse)
end


function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if UnitName("target") == "Ebonroc" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Ebonroc")
	end
	if self.db.profile.wingbuffet then
		self:Bar(L["wingbuffet1_bar"], timer.wingbuffet, icon.wingbuffet, true, "blue")
		self:DelayedMessage(timer.wingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
	end
	if self.db.profile.curse then
		self:Bar(L["shadowcurse_Firstbar"], timer.curse, icon.curse, true, "white")
	end
	if self.db.profile.shadowflame then
		self:IntervalBar(L["shadowflame_Nextbar"], timer.earliestShadowflame, timer.latestShadowflame, icon.shadowflame, true, "red")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,shadowcurseother,_ = string.find(msg, L["shadowcurseother_trigger"])
	if string.find(msg, L["shadowcurseyou_trigger"]) then
		self:Sync(syncName.curse .. " " .. UnitName("player"))
		if self.db.profile.curse then
			self:Message(L["shadowcurse_message_you"], "Attention")
			self:WarningSign(icon.curse, timer.curse)
		end
	elseif shadowcurseother then
		self:Sync(syncName.curse .. " " .. shadowcurseother)
		if self.db.profile.curse then
			self:Message(string.format(L["shadowcurse_message_taunt"], shadowcurseother), "Attention")
			if playerClass == "WARRIOR" and self.db.profile.bigicon then
				self:WarningSign(icon.taunt, 8)
			end
		end
	end
	if string.find(msg, L["taunt_trigger"]) or string.find(msg,L["tauntyouresist_trigger"]) then
		self:RemoveWarningSign(icon.taunt)
	end
	if msg == L["shadowflame_trigger"] then
		self:Sync(syncName.shadowflame)
	end
	if msg == L["wingbuffet_trigger"] then
		self:Sync(syncName.wingbuffet)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.wingbuffet then
		self:WingBuffet()
	elseif sync == syncName.shadowflame then
		self:ShadowFlame()
	elseif sync == syncName.curse and self.db.profile.curse then
		self:Bar(string.format(L["shadowcurse_bar"], rest), timer.curse, icon.curse, true, "green")
	end
end

function module:WingBuffet()
	if self.db.profile.wingbuffet then
		self:Message(L["wingbuffet_message"], "Important")
		self:RemoveBar(L["wingbuffet_bar"])
		self:Bar(L["wingbuffetcast_bar"], timer.wingbuffetCast, icon.wingbuffet, true, "blue")
		self:DelayedBar(timer.wingbuffetCast, L["wingbuffet_bar"], timer.wingbuffet, icon.wingbuffet, true, "blue")
		self:DelayedMessage(timer.wingbuffet - 5, L["wingbuffet_warning"], "Attention", nil, nil, true)
	end
end

function module:ShadowFlame()
	if self.db.profile.shadowflame then
		self:Message(L["shadowflame_warning"], "Important", true, "Alarm")
		self:RemoveBar(L["shadowflame_Nextbar"])
		self:Bar(L["shadowflame_bar"], timer.shadowflameCast, icon.shadowflame, true, "red")
		self:DelayedIntervalBar(timer.shadowflameCast, L["shadowflame_Nextbar"], timer.earliestShadowflame-timer.shadowflameCast, timer.latestShadowflame-timer.shadowflameCast, icon.shadowflame, true, "red")
	end
end

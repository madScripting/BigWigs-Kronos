
local module, L = BigWigs:ModuleDeclaration("Baron Geddon", "Molten Core")

module.revision = 20054
module.enabletrigger = module.translatedName
module.wipemobs = nil
module.toggleoptions = {"sounds", "bigicon", "inferno", "service", "bomb", "mana", "announce", "icon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Baron",

	service_cmd = "service",
	service_name = "Last Service warning",
	service_desc = "Timer bar for Geddon's last service.",

	inferno_cmd = "inferno",
	inferno_name = "Inferno alert",
	inferno_desc = "Timer bar for Geddon's Inferno.",

	bombtimer_cmd = "bombtimer",
	bombtimer_name = "Living Bomb timers",
	bombtimer_desc = "Shows a 8 second bar for when the bomb goes off at the target.",

	bomb_cmd = "bomb",
	bomb_name = "Living Bomb alert",
	bomb_desc = "Warn when players are the bomb",

	mana_cmd = "manaignite",
	mana_name = "Ignite Mana alert",
	mana_desc = "Shows timers for Ignite Mana and announce to dispel it",

	icon_cmd = "icon",
	icon_name = "Raid Icon on bomb",
	icon_desc = "Put a Raid Icon on the person who's the bomb. (Requires assistant or higher)",

	announce_cmd = "whispers",
	announce_name = "Whisper to Bomb targets",
	announce_desc = "Sends a whisper to players targetted by Living Bomb. (Requires assistant or higher)",
	
	bigicon_cmd = "Bigicon",
	bigicon_name = "Bomb on you big icon alert",
	bigicon_desc = "Shows a big icon when you are the bomb",
	
	sounds_cmd = "sounds",
	sounds_name = "Bomb RunAway sound alert",
	sounds_desc = "Sound effect when you are the bomb",	
		
	inferno_trigger = "Baron Geddon is afflicted by Inferno",
	inferno_trigger2 = "Baron Geddon gains Inferno",
	inferno_bar = "Inferno CD",
	inferno_channel = "Inferno",
	nextinferno_message = "3 seconds until Inferno!",
	inferno_message = "Inferno for 8 seconds!",

	service_trigger = "performs one last service for Ragnaros",
	service_message = "Last Service! Baron Geddon exploding in 8 seconds!",
	service_bar = "Last Service",
	
	bombyou_trigger = "You are afflicted by Living Bomb.",
	bombother_trigger = "(.*) is afflicted by Living Bomb.",
	bombyouend_trigger = "Living Bomb fades from you.",
	bombotherend_trigger = "Living Bomb fades from (.*).",
	
	ignitemana_trigger = "afflicted by Ignite Mana",	
	ignitemana_trigger1 = "afflicted by Ignite Mana",
	ignitemana_trigger2 = "Ignite Mana was resisted",
	ignite_message = "Dispel NOW!",
	ignite_bar = "Ignite Mana CD",
	
	bomb_message_you = "You are the bomb!",
	bomb_message_youscreen = "You are the bomb!",
	bomb_message_other = "%s is the bomb!",
	bomb_onme = "Living Bomb on ",
	bomb_bar = "Living Bomb: %s",
	bomb_bar1 = "Living Bomb: %s",
	nextbomb_bar = "Living Bomb CD",
	deathyou_trigger = "You die.",
} end)

local timer = {
	bomb = 8,
	inferno = 8,
	firstBomb = 19.1,
	nextBomb = 7,
	firstInferno = 21.5,
	nextInferno = 17,
	firstIgnite = 20.8,
	nextIgnite = 33,
	service = 8,
}
local icon = {
	bomb = "Inv_Enchant_EssenceAstralSmall",
	inferno = "Spell_Fire_Incinerate",
	ignite = "Spell_Fire_Incinerate",
	service = "Spell_Fire_SelfDestruct",
}
local syncName = {
	bomb = "GeddonBomb"..module.revision,
	bombStop = "GeddonBombStop"..module.revision,
	inferno = "GeddonInferno"..module.revision,
	ignite = "GeddonManaIgnite"..module.revision,
	service = "GeddonService"..module.revision,
}

local firstinferno = true
local firstignite = true
local firstbomb = true

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")

	self:ThrottleSync(5, syncName.bomb)
	self:ThrottleSync(3, syncName.bombStop)
	self:ThrottleSync(4, syncName.service)
	self:ThrottleSync(4, syncName.ignite)
	self:ThrottleSync(15, syncName.inferno)
end

function module:OnSetup()
	self.started = nil
	firstinferno = true
	firstignite = true
	firstbomb = true
	bombt = 0
end

function module:OnEngage()
	self:Inferno()
	self:ManaIgnite()
	self:NextBomb()
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_, bombother, mcverb = string.find(msg, L["bombother_trigger"])
	local _,_, bombotherend, mcverb = string.find(msg, L["bombotherend_trigger"])
	if string.find(msg, L["bombyou_trigger"]) then
		self:Sync(syncName.bomb)
		if self.db.profile.bomb then
			self:Bar(string.format(L["bomb_bar1"], UnitName("player")), timer.bomb, icon.bomb, true, "red")
			self:Message(L["bomb_message_youscreen"], "Attention")
			if self.db.profile.sounds then
				self:Sound("RunAway")
			end
			if self.db.profile.icon then
				self:WarningSign("Spell_Shadow_MindBomb", timer.bomb)
			end
			self:SendSay(L["bomb_onme"] .. UnitName("player") .. "!")
		end
		if self.db.profile.icon then
			self:Icon(UnitName("player"))
		end
	elseif string.find(msg, L["bombyouend_trigger"]) then
		self:RemoveBar(string.format(L["bomb_bar1"], UnitName("player")))
		self:Sync(syncName.bombStop)
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:RemoveBar(string.format(L["bomb_bar1"], UnitName("player")))
	elseif bombother then
		bombt = bombother
		self:Sync(syncName.bomb)
		if self.db.profile.bomb then
			self:Bar(string.format(L["bomb_bar"], bombother), timer.bomb, icon.bomb, true, "red")
			self:Message(string.format(L["bomb_message_other"], bombother), "Attention")
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", bombother)
		end
		if self.db.profile.announce then
			self:TriggerEvent("BigWigs_SendTell", bombother, L["bomb_message_you"])
		end
	elseif bombotherend then
		self:RemoveBar(string.format(L["bomb_bar"], bombotherend))
		self:TriggerEvent("BigWigs_RemoveRaidIcon")
	elseif (string.find(msg, L["ignitemana_trigger1"]) or string.find(msg, L["ignitemana_trigger2"])) then
		self:Sync(syncName.ignite)
	end
	if string.find(msg, L["service_trigger"]) and self.db.profile.service then
		self:Sync(syncName.service)
	end
	if string.find(msg, L["inferno_trigger"]) or string.find(msg, L["inferno_trigger2"]) then
		BigWigs:DebugMessage("inferno trigger")
		self:Sync(syncName.inferno)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.bomb then
		self:NextBomb()
	elseif sync == syncName.inferno then
		self:Inferno()
	elseif sync == syncName.ignite then
		self:ManaIgnite()
	elseif sync == syncName.bombStop and self.db.profile.bomb then
		self:RemoveBar(string.format(L["bomb_bar"], bombt))
	elseif sync == syncName.service and self.db.profile.service then
		self:Service()
	end
end

function module:Inferno()
	if self.db.profile.inferno then
	self:RemoveBar(string.format(L["inferno_bar"]))
		if firstinferno == true then
			self:Bar(L["inferno_bar"], timer.firstInferno, icon.inferno, true, "blue")
			self:DelayedMessage(timer.firstInferno - 5, L["nextinferno_message"], "Urgent", nil, nil, true)
			self:DelayedSound(timer.firstInferno - 2, "meleeout")
			firstinferno = false
		else
			self:Bar(L["inferno_channel"], timer.inferno, icon.inferno, true, "blue")
			self:DelayedSound(timer.inferno - 1, "gogogo")
			self:Message(L["inferno_message"], "Important")
			self:DelayedBar(timer.inferno, L["inferno_bar"], timer.nextInferno, icon.inferno, true, "blue")
			self:DelayedMessage(timer.nextInferno - 5, L["nextinferno_message"], "Urgent", nil, nil, true)
			self:DelayedSound(timer.nextInferno - 2, "meleeout")
		end
	end
end

function module:ManaIgnite()
	if self.db.profile.mana then
		if not firstignite then
			self:Message(L["ignite_message"], "Important")
			self:Bar(L["ignite_bar"], timer.firstIgnite, icon.ignite, true, "white")
		else
			self:Bar(L["ignite_bar"], timer.nextIgnite, icon.ignite, true, "white")
		end
		firstignite = false
	end
end

function module:NextBomb()
	if self.db.profile.bomb then
		self:RemoveBar(L["nextbomb_bar"])
		if firstbomb then
			self:Bar(L["nextbomb_bar"], timer.firstBomb, icon.bomb, true, "yellow")
			firstbomb = false
		else
			self:DelayedBar(timer.bomb, L["nextbomb_bar"], timer.nextBomb, icon.bomb, true, "yellow")
		end
	end
end

function module:Service()
	if self.db.profile.service then
		self:Bar(L["service_bar"], timer.service, icon.service, true, "black")
		self:Message(L["service_message"], "Important")
	end
end
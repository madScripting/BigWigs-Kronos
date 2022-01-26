
local module, L = BigWigs:ModuleDeclaration("General Drakkisath", "Upper Blackrock Spire")

module.revision = 30001
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "bosskill", "bigicon", "icon", -1, "conflagSelf", "conflagProxy", "flamestrike"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Upper Blackrock Spire"],
}

--[[Testing stuff
/script SendAddonMessage("BigWigs","DrakkisathAddDead", "RAID", "Relar");
/script SendAddonMessage("BigWigs","MagmadarPanic"..20041, "RAID", "Relar");
/script SendAddonMessage("BigWigs","DrakkisathConflagged"..20059 .."_ Relar", "RAID", "Relar"); works with rest method
/script SendAddonMessage("BigWigs","DrakkisathConflagged"..20059 .."_Relar", "RAID", "Relar"); works with substring method
--]]

L:RegisterTranslations("enUS", function() return {
	cmd = "Drakkisath",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Chromatic Elite Guards",
	
	icon_cmd = "icon",
	icon_name = "Raid icon on Conflag players",
	icon_desc = "Place a raid icon on the player afflicted by Conflagration\n\n(Requires assistant or higher)",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon warnings",
	bigicon_desc = "Big icon warning if taking Conflag friendly fire or standing in Flamestrike",
	
	conflagSelf_cmd = "conflagSelf",
	conflagSelf_name = "Conflagration on you alert",
	conflagSelf_desc = "Warn for Conflagration on you",
	
	conflagProxy_cmd = "conflagProxy",
	conflagProxy_name = "Conflagration friendly fire alert",
	conflagProxy_desc = "Warn for Conflagration friendly fire",
	
	flamestrike_cmd = "flamestrike",
	flamestrike_name = "Standing in Flamestrike alert",
	flamestrike_desc = "Warn if you are standing in Flamestrike area",

	addName = "Chromatic Elite Guard",
	addTrigger = "Chromatic Elite Guard dies",
	addDead = "%d/2 Chromatic Elite Guard dead!",
	bringDrak = "Release Drakkisath!",

	conflagrationTrigger = "([^%s]+) ([^%s]+) afflicted by Conflagration",
	conflagrationEndTrigger = "Conflagration fades from ([^%s]+)",
	conflagrationSelfTrigger = "You",
	conflagSelfWarn = "Conflag!",
	conflagMessage = "Conflag on ",
	conflagBar = "Conflag ",
	
	flamestrikeTrigger = "You are afflicted by Flamestrike",
	flamestrikeEndTrigger = "Flamestrike fades from you",
	
	conflagProxyTrigger = "General Drakkisath's Conflagration hits you for",
} end)

local timer = {
	conflagTimer = 10,
}

local icon = {
	flamestrikeIcon = "spell_fire_selfdestruct",
	conflagIcon = "spell_fire_incinerate",
}

local syncName = {
	drakAddDead = "DrakkisathAddDead",
	conflagged = "DrakkisathConflagged"..module.revision.."_",
}

local addsDead = 0

module.wipemobs = { L["addName"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:ThrottleSync(0.5, syncName.drakAddDead)
end

function module:OnSetup()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
end

function module:OnEngage()
	if UnitName("target") == "General Drakkisath" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "General Drakkisath")
	end
	addsDead = 0
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["conflagrationTrigger"]) then
		local _,_,conflagPlayer,_ = string.find(msg, L["conflagrationTrigger"])
		if conflagPlayer then
			if conflagPlayer == L["conflagrationSelfTrigger"] then
				self:Sync(syncName.conflagged .. UnitName("player"))
				if self.db.profile.conflagSelf then
					self:SendSay(L["conflagSelfWarn"])
				end
				if self.db.profile.icon then
					self:TriggerEvent("BigWigs_SetRaidIcon", UnitName("player"))
				end	
			elseif conflagPlayer ~= L["conflagrationSelfTrigger"] then
				self:Sync(syncName.conflagged .. conflagPlayer)
				if self.db.profile.icon then
					self:TriggerEvent("BigWigs_SetRaidIcon", conflagPlayer)
				end
			end
		end
	end
	
	if string.find(msg, L["conflagrationEndTrigger"]) then
		local _,_, conflagEndPlayer, ptype = string.find(msg, L["conflagrationEndTrigger"])
		if conflagEndPlayer then
			if self.db.profile.icon then
				self:TriggerEvent("BigWigs_RemoveRaidIcon")
			end
		end
	end
	
	if string.find(msg, L["addTrigger"]) then
		self:Sync(syncName.drakAddDead)
	end
	
	if string.find(msg, L["conflagProxyTrigger"]) and self.db.profile.conflagSelf then
		self:WarningSign(icon.conflagIcon, 0.5)
	end
	if string.find(msg, L["flamestrikeTrigger"]) and self.db.profile.flamestrike then
		self:WarningSign(icon.flamestrikeIcon, 6)
	end
	if string.find(msg, L["flamestrikeEndTrigger"]) and self.db.profile.flamestrike then
		self:RemoveWarningSign(icon.flamestrikeIcon)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == "DrakkisathAddDead" then
		self:DrakAddDead()
	elseif string.find(sync, syncName.conflagged) then
		conflagPerson = string.sub(sync,27)
		self:Conflagged(conflagPerson)
	end
end

function module:DrakAddDead()
	addsDead = addsDead + 1
	if self.db.profile.adds then
		self:Message(string.format(L["addDead"], addsDead), "Positive", false, "Alert")
		if addsDead == 2 then
			self:Message(L["bringDrak"], "Important", false, "Long")
		end
	end
end

function module:Conflagged(conflagPerson)
	if self.db.profile.conflagProxy then
		self:Message(string.format(L["conflagMessage"])..conflagPerson.."!", "Attention")
		self:Bar(L["conflagBar"]..conflagPerson, timer.conflagTimer, icon.conflagIcon, true, "Red")
	end
end

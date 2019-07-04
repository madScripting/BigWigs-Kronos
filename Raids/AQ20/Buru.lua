
local module, L = BigWigs:ModuleDeclaration("Buru the Gorger", "Ruins of Ahn'Qiraj")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"you", "other", "icon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Buru",

	you_cmd = "you",
	you_name = "You're being watched alert",
	you_desc = "Warn when you're being watched",

	other_cmd = "other",
	other_name = "Others being watched alert",
	other_desc = "Warn when others are being watched",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on watched person (requires promoted or higher)",

	watchtrigger = "sets eyes on (.+)!",
	watchwarn = " is being watched!",
	watchwarnyou = "You are being watched!",
	you = "You",
	
	dismember1_trigger = "(.+) is afflicted by Dismember.",
	dismember_trigger = "(.+) is afflicted by Dismember %((.+)%)",
	dismember_bar = " Dismember",
	p2 = "Phase2, DPS Buru!",
} end )

local timer = {
	dismember = 10,
}

local icon = {
	dismember = "ability_backstab",
}

local syncName = {
	dismember = "BuruDismember",
	p2 = "BuruP2",
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("UNIT_HEALTH")
end

function module:OnSetup()
end

function module:OnEngage()
	if UnitName("target") == "Buru the Gorger" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Buru the Gorger")
	end
 p2 = false
 end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_EMOTE( msg )
	local _, _, player = string.find(msg, L["watchtrigger"])
	if player then
		if player == L["you"] and self.db.profile.you then
			player = UnitName("player")
			self:Message(L["watchwarnyou"], "Personal", true, "RunAway")
			self:Message(UnitName("player") .. L["watchwarn"], "Attention", nil, nil, true)
		elseif self.db.profile.other then
			self:Message(player .. L["watchwarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", player, L["watchwarnyou"])
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", player)
		end
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) > 5 and math.ceil(100*health/maxHealth) <= 20 and not p2 then
			self:Sync(syncName.p2)
			p2 = true
		end
	end
end

function module:Event(msg)
	local _,_,one = string.find(msg, L["dismember1_trigger"])
	local _,_,name, amount = string.find(msg, L["dismember_trigger"])
	if name and amount then
		self:Sync(syncName.dismember .. " " .. name .. " " .. amount)
	end
	if one then
		self:Sync(syncName.dismember .. " " .. one .. " 1")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.dismember then
		if rest == UnitName("player") then
			self:Bar(string.format(UnitName("player") .. L["dismember_bar"]), timer.dismember, icon.dismember)
		else
			self:Bar(string.format(rest .. L["dismember_bar"]), timer.dismember, icon.dismember)
		end
	end
	if sync ==syncName.p2 then
		self:Message(L["p2"], "Attention")
		self:Sound("gogogo")
	end
end

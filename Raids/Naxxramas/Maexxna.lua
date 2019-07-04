
local module, L = BigWigs:ModuleDeclaration("Maexxna", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"spiderAdds", "webWrap", "webSpray", "poison", "cocoon", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Maexxna",

	webSpray_cmd = "webSpray",
	webSpray_name = "Web Spray Alert",
	webSpray_desc = "Warn for Web Spray",
	
	spiderAdds_cmd = "spiderAdds",
	spiderAdds_name = "Spider Adds Alert",
	spiderAdds_desc = "Warn for spider adds",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",
	
	cocoon_cmd = "cocoon",
	cocoon_name = "Cocoon timer bars",
	cocoon_desc = "Timers for each cocooned player",
	
	webWrap_cmd = "webWrap",
	webWrap_name = "Web Wrap ability timer",
	webWrap_desc = "Timer for when Maexxna will do her Web Wrap ability",

	poison_cmd = "Poison",
	poison_name = "Necrotic Poison Alert",
	poison_desc = "Warn for Necrotic Poison",

	spiderAdds_bar = "Spiders",	

	poison_trigger = "afflicted by Necrotic Poison.",
	poisonEnd_trigger = "Necrotic Poison fades from",
	poison_warn = "Necrotic Poison!",
	poison_bar = "Necrotic Poison",

	enrage_trigger = "gains Enrage",
	enrage_warn = "Enrage - SQUISH SQUISH SQUISH!",
	enrageSoon_warn = "Enrage Soon - Bug Swatters out!",

	webSpray_trigger = "afflicted by Web Spray",
	webSpray_warn = "Web Spray!",
	webSpray_bar = "Web Spray",
	
	webWrap_trigger = "(.*) is afflicted by Web Wrap",
	webWrapEnd_trigger = "Web Wrap fades from (.*).",
	webWrap_warn = "Break cocoons!",
	webWrap_bar = "Cocoons",
	webWrapped_bar = " Cocooned",
} end )

local timer = {
	poison = {10, 22},
	webWrapped = 60,
	spiderAdds = 30,
	webSpray = 40,
	webWrap = 20,
}

local icon = {
	spiderAdds = "INV_Misc_MonsterSpiderCarapace_01",
	poison = "Ability_Creature_Poison_03",
	webSpray = "Ability_Ensnare",
	enrage = "Spell_Shadow_UnholyFrenzy",
	webWrap = "Spell_Nature_Web",
}

local syncName = {
	webSpray = "MaexxnaWebSpray"..module.revision,
	poison = "MaexxnaPoison"..module.revision,
	poisonEnd = "MaexxnaPoisonEnd"..module.revision,
	webWrap = "MaexxnaWebWrap"..module.revision,
	webWrapMessage = "MaexxnaWebWrapMessage"..module.revision,
	webWrapEnd = "MaexxnaWebWrapEnd"..module.revision,
	enrage = "MaexxnaEnrage"..module.revision,
}

local enrageAnnounced = false
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")

	self:ThrottleSync(8, syncName.webSpray)
	self:ThrottleSync(5, syncName.poison)
	self:ThrottleSync(0, syncName.poisonEnd)
	self:ThrottleSync(0, syncName.webWrap)
	self:ThrottleSync(5, syncName.webWrapMessage)
	self:ThrottleSync(0, syncName.webWrapEnd)
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	enrageAnnounced = false
end

function module:OnEngage()
	if UnitName("target") == "Maexxna" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Maexxna")
	end
	if self.db.profile.poison then
		self:IntervalBar(L["poison_bar"], timer.poison[1], timer.poison[2], icon.poison, true, "green")
	end
	self:WebSpray()
end

function module:OnDisengage()
end

function module:UNIT_HEALTH( msg )
	if UnitName(msg) == boss then
		local maxHealth = UnitHealthMax(msg)
		local health = UnitHealth(msg)
		if (math.ceil(100*health/maxHealth) > 27 and math.ceil(100*health/maxHealth) <= 34 and not enrageAnnounced) then
			if self.db.profile.enrage then
				self:Message(L["enrageSoon_warn"], "Important")
			end
			enrageAnnounced = true
		elseif (math.ceil(100*health/maxHealth) > 34 and enrageAnnounced) then
			enrageAnnounced = false
		end
	end
end

function module:Event(msg)
	local _,_,webbed,_ = string.find(msg, L["webWrap_trigger"])
	local _,_,unwebbed,_ = string.find(msg, L["webWrapEnd_trigger"])
	
	if string.find(msg, L["webSpray_trigger"]) then
		self:Sync(syncName.webSpray)
	end
	if string.find(msg, L["poison_trigger"]) then
		self:Sync(syncName.poison)
	end
	if string.find(msg, L["poisonEnd_trigger"]) then
		self:Sync(syncName.poisonEnd)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
	if string.find(msg, L["webWrap_trigger"]) and webbed ~= "you" then
		self:Sync(syncName.webWrap.." "..webbed)
		self:Sync(syncName.webWrapMessage)
	end
	if string.find(msg, L["webWrapEnd_trigger"]) and unwebbed ~= "you" then
		self:Sync(syncName.webWrapEnd.." "..unwebbed)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.webSpray then
		self:WebSpray()
	elseif sync == syncName.webWrapMessage and self.db.profile.webWrap then
		self:WebWrapMessage()
	elseif sync == syncName.poison and self.db.profile.poison then
		self:Poison()
	elseif sync == syncName.poisonEnd and self.db.profile.poison then
		self:PoisonEnd()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.webWrap and rest then
		if self.db.profile.cocoon then
			self:WebWrap(rest)
		end
	elseif sync == syncName.webWrapEnd and rest then
		if self.db.profile.cocoon then
			self:WebWrapEnd(rest)
		end
	end
end

function module:WebWrapMessage()
	self:Message(L["webWrap_warn"], "Urgent")
end


function module:WebWrap(rest)
	self:Bar(rest..L["webWrapped_bar"], timer.webWrapped, icon.webWrap, true, "white")
end

function module:WebWrapEnd(rest)
	self:RemoveBar(rest..L["webWrapped_bar"])
end

function module:Enrage()
	self:Message(L["enrage_warn"], "Important", nil, "Beware")
	self:WarningSign(icon.enrage, 1)
end

function module:WebSpray()
	if self.db.profile.webSpray then
		self:Message(L["webSpray_warn"], "Important")
		self:Bar(L["webSpray_bar"], timer.webSpray, icon.webSpray, true, "blue")
	end
	if self.db.profile.spiderAdds then
		self:Bar(L["spiderAdds_bar"], timer.spiderAdds, icon.spiderAdds, true, "yellow")
	end
	if self.db.profile.webWrap then
		self:Bar(L["webWrap_bar"], timer.webWrap, icon.webWrap, true, "red")
	end
end

function module:Poison()
	self:Message(L["poison_warn"], "Important")
	self:IntervalBar(L["poison_bar"], timer.poison[1], timer.poison[2], icon.poison, true, "Green")
	if playerClass == "DRUID" or playerClass == "SHAMAN" then
		self:WarningSign(icon.poison, 30)
	end
end

function module:PoisonEnd()
	if playerClass == "DRUID" or playerClass == "SHAMAN" then
		self:RemoveWarningSign(icon.poison)
	end
end

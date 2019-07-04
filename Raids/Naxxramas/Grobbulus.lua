
local module, L = BigWigs:ModuleDeclaration("Grobbulus", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = {"youinjected", "otherinjected", "slimespray",  "icon", "cloud", "cloudDmg", "bigicon", "sounds", -1, "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grobbulus",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	cloudDmg_cmd = "cloudDmg",
	cloudDmg_name = "Standing in Poison Cloud Alert",
	cloudDmg_desc = "Warns you if you stand in the Poison Cloud",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon Alerts for Poison Cloud",
	bigicon_desc = "Warns on Poison Cloud cast and standing in it",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound Alert for Poison Cloud",
	sounds_desc = "Warns when standing in poison cloud",

	youinjected_cmd = "youinjected",
	youinjected_name = "You're injected Alert",
	youinjected_desc = "Warn when you're injected",

	otherinjected_cmd = "otherinjected",
	otherinjected_name = "Others injected Alert",
	otherinjected_desc = "Warn when others are injected",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on an injected person. (Requires promoted or higher)",

	cloud_cmd = "cloud",
	cloud_name = "Poison Cloud",
	cloud_desc = "Warn for Poison Clouds",

	slimespray_cmd = "slimespray",
	slimespray_name = "Slime Spray",
	slimespray_desc = "Show timer for Slime Spray",

	enrage_bar = "Enrage",
	enrage30sec_warn = "Enrage in 30sec",
	enrage10sec_warn = "Enrage in 10sec",

	inject_trigger = "(.+) (.+) afflicted by Mutating Injection",
	injectFade_trigger = "Mutating Injection fades from (.+).",
	injectYou_warn = "You are injected!",
	injectOther_warn = " is injected!",
	injectSay_warn = "Injection on ",
	inject_bar = " Injected",
	
	cloud_trigger = "Grobbulus casts Poison Cloud.",
	cloudDmg_trigger = "Grobbulus Cloud's Poison hits you",
	cloud_warn = "Poison Cloud next in ~15 seconds!",
	cloud_bar = "Poison Cloud",

	slimeSpray_trigger = "Slime Spray",
	slimeSpray_bar = "Possible Slime Spray",
} end )

local timer = {
	enrage = 720,
	inject = 10,
	cloud = 15,
	firstSlimeSpray = {20, 30},
	slimeSpray = {30, 40},
}

local icon = {
	enrage = "INV_Shield_01",
	inject = "Spell_Shadow_CallofBone",
	cloud = "Ability_Creature_Disease_02",
	slimeSpray = "INV_Misc_Slime_01",
	move = "Spell_magic_polymorphchicken",
}

local syncName = {
	inject = "GrobbulusInject"..module.revision,
	injectFade = "GrobbulusInjectFade"..module.revision,
	cloud = "GrobbulusCloud"..module.revision,
	slimeSpray = "GrobbulusSlimeSpray"..module.revision,
}

local berserkannounced = nil
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")

	self:ThrottleSync(3, syncName.inject)
	self:ThrottleSync(1, syncName.injectFade)
	self:ThrottleSync(5, syncName.cloud)
	self:ThrottleSync(10, syncName.slimeSpray)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	self:RemoveBar("Sewage Slimes")
	self:CancelDelayedMessage("Sewage Slimes in 10 seconds")
	if UnitName("target") == "Grobbulus" and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.sendmessage("target " .. "Grobbulus")
	end
	if self.db.profile.enrage then
		self:Bar(L["enrage_bar"], timer.enrage, icon.enrage, true, "white")
		self:DelayedMessage(timer.enrage - 30, L["enrage30sec_warn"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["enrage10sec_warn"], "Important")
	end
	if self.db.profile.slimespray then
		self:IntervalBar(L["slimeSpray_bar"], timer.firstSlimeSpray[1], timer.firstSlimeSpray[2], icon.slimeSpray, true, "green")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["inject_trigger"]) then
	local _,_,name,verb = string.find(msg, L["inject_trigger"])
		if name == "You" and verb == "are" then
			name = UnitName("player")
		end
		self:Sync(syncName.inject.." "..name)
	end
	if string.find(msg, L["injectFade_trigger"]) then
		local _,_,fadeName = string.find(msg, L["injectFade_trigger"])
		if fadeName == "you" then
			fadeName = UnitName("player")
			self:RemoveWarningSign(icon.inject)
		end
		self:Sync(syncName.injectFade.." "..fadeName)
	end
	if string.find( msg, L["cloud_trigger"] ) then
		self:Sync(syncName.cloud)
	end
	if string.find( msg, L["slimeSpray_trigger"]) then
		self:Sync(syncName.slimeSpray)
	end
	if string.find(msg, L["cloudDmg_trigger"]) and self.db.profile.cloudDmg then
		if self.db.profile.bigicon then
			self:WarningSign(icon.cloud, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Info")
		end
	end
end

function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.inject then
		self:Inject(rest)
	elseif sync == syncName.injectFade then
		self:InjectFade(rest)
	elseif sync == syncName.cloud and self.db.profile.cloud then
		self:Cloud()
	elseif sync == syncName.slimeSpray and self.db.profile.slimespray then
		self:SlimeSpray()
	end
end

function module:SlimeSpray()
	self:RemoveBar(L["slimeSpray_bar"])
	self:IntervalBar(L["slimeSpray_bar"], timer.slimeSpray[1], timer.slimeSpray[2], icon.slimeSpray, true, "green")
end

function module:Inject(rest)
	if self.db.profile.youinjected and rest == UnitName("player") then
		self:Message(L["injectYou_warn"], "Personal", true, "Beware")
		self:WarningSign(icon.inject, timer.inject)
		self:Message(rest..L["injectOther_warn"], "Attention", nil, nil, true)
		self:Bar(rest..L["inject_bar"], timer.inject, icon.inject, true, "red")
		self:SendSay(L["injectSay_warn"]..UnitName("player").."!")
	elseif self.db.profile.otherinjected then
		self:Message(rest..L["injectOther_warn"], "Attention")
		self:TriggerEvent("BigWigs_SendTell", rest, L["injectYou_warn"])
		self:Bar(rest..L["inject_bar"], timer.inject, icon.inject, true, "red")
	end
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", rest)
	end
end

function module:InjectFade(rest)
	self:RemoveBar(rest..L["inject_bar"])
end

function module:Cloud()
	self:Message(L["cloud_warn"], "Urgent")
	self:Bar(L["cloud_bar"], timer.cloud, icon.cloud, true, "blue")
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		if self.db.profile.bigicon then
			self:WarningSign(icon.move, 0.7)
		end
	end
end

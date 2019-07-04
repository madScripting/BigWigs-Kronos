
local module, L = BigWigs:ModuleDeclaration("Hakkar", "Zul'Gurub")

module.revision = 20042
module.enabletrigger = module.translatedName
module.toggleoptions = {"shieldwall", "bigicon", "sounds", "mc", "icon", "siphon", "enrage", -1, "aspectjeklik", "aspectvenoxis", "aspectmarli", "aspectthekal", "aspectarlokk", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Hakkar",

	siphon_cmd = "siphon",
	siphon_name = "Blood Siphon",
	siphon_desc = "Shows bars, warnings and timers for Hakkar's Blood Siphon.",
	
	shieldwall_cmd = "shieldwall",
	shieldwall_name = "ShieldWall alert on Hakkar Enrage",
	shieldwall_desc = "Warns warriors to Shield Wall when Hakkar goes on low health enrage",

	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Lets you know when the 10 minutes are up!",

	mc_cmd = "mc",
	mc_name = "Mind Control",
	mc_desc = "Alerts on Mind Control (Cause Insanity and Will of Hakkar).",
	
	icon_cmd = "icon",
	icon_name = "Raid icon on MCed players",
	icon_desc = "Place a raid icon on the player with Cause Insanity.\n\n(Requires assistant or higher)",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon warnings",
	bigicon_desc = "Big icon warning to blow fears on engage, to kill the son, sheep on MC, dispel on MC end",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound alerts",
	sounds_desc = "Sound alert to get in poison, sheep on MC, dispel on MC end",

	aspectjeklik_cmd = "aspectjeklik",
	aspectjeklik_name = "Aspect of Jeklik",
	aspectjeklik_desc = "Warnings for the extra ability Hakkar gains when High Priestess Jeklik is still alive.",

	aspectvenoxis_cmd = "aspectvenoxis",
	aspectvenoxis_name = "Aspect of Venoxis",
	aspectvenoxis_desc = "Warnings for the extra ability Hakkar gains when High Priest Venoxis is still alive.",

	aspectmarli_cmd = "aspectmarli",
	aspectmarli_name = "Aspect of Mar'li",
	aspectmarli_desc = "Warnings for the extra ability Hakkar gains when High Priestess Mar'li is still alive.",

	aspectthekal_cmd = "aspectthekal",
	aspectthekal_name = "Aspect of Thekal",
	aspectthekal_desc = "Warnings for the extra ability Hakkar gains when High Priest Thekal is still alive.",

	aspectarlokk_cmd = "aspectarlokk",
	aspectarlokk_name = "Aspect of Arlokk",
	aspectarlokk_desc = "Warnings for the extra ability Hakkar gains when High Priestess Arlokk is still alive.",
	
	engage_trigger = "FACE THE WRATH OF THE SOULFLAYER!",

	ci_trigger = "(.+) (.+) afflicted by Cause Insanity.",
	cifail_trigger = "Cause Insanity was resisted",
	mc_warn = " MC!",
	mced_bar = " MC >Click Me!<",
	cicd_bar = "Cause Insanity CD",
	
	will_trigger = "(.+) (.+) afflicted by Will of Hakkar.",
	willfail_trigger = "Will of Hakkar was resisted",

	poisonousblood_trigger = "You are afflicted by Poisonous Blood.",
	siphon_trigger = "Hakkar gains Blood Siphon.",
	killtheson_warn = "Blood Siphon in %d seconds, Kill the Son!",
	getpoison_warn = "Blood Siphon in %d seconds, Get Poisoned!",
	siphoncd_bar = "Next Blood Siphon",
	siphoneffect_bar = "Blood Siphon",
	
	enrage_trigger = "Hakkar gains Enrage",
	enrage_warn = "Hakkar is Enraged!",
	
	enrage2minutes_message = "Enrage in 2 minutes!",
	enrage1minute_message = "Enrage in 1 minute!",
	enrageseconds_message = "Enrage in %d seconds!",
	enrage_bar = "Enrage",
	
	thekal_trigger = "Hakkar gains Aspect of Thekal.",
	thekalend_trigger = "Aspect of Thekal fades from Hakkar.",
	thekal_warn = "Frenzy! Tranq now!",
	thekalcd_bar = "Next Frenzy",
	thekaleffect_bar = "Frenzy - Aspect of Thekal",

	marli_trigger = "(.+) (.+) afflicted by Aspect of Mar'li.",
	marlifail_trigger = "Hakkar 's Aspect of Mar'li",
	marlicd_bar = "Mar'li Stun CD",
	marlieffect_bar = "Mar'li Stun ",
		
	jeklik_trigger = "(.+) (.+) afflicted by Aspect of Jeklik.",
	jeklikfail_trigger = "Hakkar 's Aspect of Jeklik",
	jeklikcd_bar = "Jeklik Silence CD",
	jeklikeffect_bar = "Jeklik Silence ",

	arlokk_trigger = "(.+) (.+) afflicted by Aspect of Arlokk.",
	arlokkfail_trigger = "Hakkar 's Aspect of Arlokk",
	arlokkcd_bar = "Arlokk Vanish CD",
	arlokkeffect_bar = "Arlokk Vanish ",

	venoxis_trigger = "Hakkar 's Aspect of Venoxis hits",
	venoxisfail_trigger = "Hakkar 's Aspect of Venoxis was resisted",
	venoxiscd_bar = "Venoxis Poison CD",
	venoxiseffect_bar = "Venoxis Poison",
} end)

local timer = {
	enrage = 600,
	siphoncd = 90,
	siphoneffect = 8,
	firstci = 24, --was 17
	cicd = 22.5, --was 15
	cieffect = 10,
	willcd = 5, --was 20
	willeffect = 20,
	
	marlicd = 10,
	marlieffect = 6,
	thekalcd = 15,
	thekaleffect = 8,
	venoxiscd = 8,
	venoxiseffect = 10,
	arlokkcd = 10,
	arlokkeffect = 2,
	jeklikcd = 10,
	jeklikeffect = 5,
}

local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	siphon = "Spell_Shadow_LifeDrain",
	serpent = "Ability_Hunter_Pet_WindSerpent",
	mc = "Spell_Shadow_ShadowWordDominate",
	sheep = "Spell_Nature_Polymorph",
	psychicscream = "Spell_shadow_psychicscream",
	intimidatingshout = "Ability_golemthunderclap",
	dispel = "spell_holy_dispelmagic",
	shieldwall = "ability_warrior_shieldwall",
	
	jeklik = "Spell_Shadow_Teleport",
	arlokk = "Ability_Vanish",
	venoxis = "Spell_Nature_CorrosiveBreath",
	marli = "Ability_Smash",
	thekal = "Ability_Druid_ChallangingRoar",
}

local syncName = {
	siphon = "HakkarBloodSiphon"..module.revision,
	ci = "HakkarCI"..module.revision,
	cifail = "HakkarCIFail"..module.revision,
	will = "HakkarWill"..module.revision,
	willfail = "HakkarWillFail"..module.revision,
	enraged = "HakkarEnraged"..module.revision,

	jeklik = "HakkarAspectJeklik"..module.revision,
	arlokk = "HakkarAspectArlokk"..module.revision,
	arlokkAvoid = "HakkarAspectArlokkAvoid"..module.revision,
	venoxis = "HakkarAspectVenoxis"..module.revision,
	marli = "HakkarAspectMarli"..module.revision,
	marliAvoid = "HakkarAspectMarliAvoid"..module.revision,
	thekalStart = "HakkarAspectThekalStart"..module.revision,
	thekalStop = "HakkarAspectThekalStop"..module.revision,
}

local berserkannounced = nil
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")

	self:ThrottleSync(5, syncName.siphon)
	self:ThrottleSync(5, syncName.ci)
	self:ThrottleSync(5, syncName.will)
	self:ThrottleSync(5, syncName.cifail)
	self:ThrottleSync(5, syncName.willfail)
	self:ThrottleSync(5, syncName.enraged)
	
	self:ThrottleSync(5, syncName.jeklik)
	self:ThrottleSync(5, syncName.arlokk)
	self:ThrottleSync(5, syncName.arlokkAvoid)
	self:ThrottleSync(5, syncName.venoxis)
	self:ThrottleSync(5, syncName.marli)
	self:ThrottleSync(5, syncName.marliAvoid)
	self:ThrottleSync(5, syncName.thekalStart)
	self:ThrottleSync(5, syncName.thekalStop)
end

function module:OnSetup()
	self.started = nil
	berserkannounced = false
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Enrage()
	end
	if self.db.profile.siphon then
		self:Bar(L["siphoncd_bar"], timer.siphoncd, icon.siphon, true, "green")
		self:DelayedMessage(timer.siphoncd - 25, string.format(L["killtheson_warn"], 25), "Urgent")
		self:DelayedMessage(timer.siphoncd - 10, string.format(L["getpoison_warn"], 10), "Attention")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.siphoncd - 25, icon.serpent, 3)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.siphoncd - 10, "Beware")
		end
	end
	if self.db.profile.mc then
		self:Bar(L["cicd_bar"], timer.firstci, icon.mc, true, "blue")
	end
	if playerClass == "WARRIOR" and self.db.profile.bigicon then
		self:WarningSign(icon.intimidatingshout, 0.7)
	end
	if playerClass == "PRIEST" and self.db.profile.bigicon then
		self:WarningSign(icon.psychicscream, 0.7)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,ciperson = string.find(msg, L["ci_trigger"])
	local _,_,willperson = string.find(msg, L["will_trigger"])
	local _,_,marliperson = string.find(msg, L["marli_trigger"])
	local _,_,jeklikperson = string.find(msg, L["jeklik_trigger"])
	local _,_,arlokkperson = string.find(msg, L["arlokk_trigger"])
	if string.find(msg, L["ci_trigger"]) then
		self:Sync(syncName.ci .. " "..ciperson)
	end
	if string.find(msg, L["cifail_trigger"]) then
		self:Sync(syncName.cifail)
	end
	if string.find(msg, L["will_trigger"]) then
		self:Sync(syncName.will.." "..willperson)
	end
	if string.find(msg, L["willfail_trigger"]) then
		self:Sync(syncName.willfail)
	end
	if string.find(msg, L["siphon_trigger"]) then
		self:Sync(syncName.siphon)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enraged)
	end
	if string.find(msg, L["thekal_trigger"]) then
		self:Sync(syncName.thekalStart)
	end	
	if string.find(msg, L["thekalend_trigger"]) then
			self:Sync(syncName.thekalStop)
	end
	if string.find(msg, L["marli_trigger"]) then
		self:Sync(syncName.marli .. " "..marliperson)
	end
	if string.find(msg, L["marlifail_trigger"]) then
		self:Sync(syncName.marliAvoid)
	end
	if string.find(msg, L["arlokk_trigger"]) then
		self:Sync(syncName.arlokk .. " "..arlokkperson)
	end
	if string.find(msg, L["arlokkfail_trigger"]) then
		self:Sync(syncName.arlokkAvoid)
	end
	if string.find(msg, L["venoxis_trigger"]) or string.find(msg, L["venoxisfail_trigger"]) then
		self:Sync(syncName.venoxis)
	end
	if string.find(msg, L["jeklik_trigger"]) or string.find(msg, L["jeklikfail_trigger"]) then
		self:Sync(syncName.jeklik)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.siphon then
		self:Siphon()
	elseif sync == syncName.ci and self.db.profile.mc then
		self:ci(rest)
	elseif sync == syncName.cifail and self.db.profile.mc then
		self:ciFail()
	elseif sync == syncName.will and self.db.profile.mc then
		self:WillOfHakkar(rest)
	elseif sync == syncName.willfail and self.db.profile.mc then
		self:WillFail()
	elseif sync == syncName.enraged and self.db.profile.enrage then
		self:Enraged()
	elseif sync == syncName.jeklik and self.db.profile.aspectjeklik then
		self:Jeklik()
	elseif sync == syncName.arlokk and self.db.profile.aspectarlokk then
		self:Arlokk()
	elseif sync == syncName.arlokkAvoid and self.db.profile.aspectarlokk then
		self:ArlokkAvoid()
	elseif sync == syncName.venoxis and self.db.profile.aspectvenoxis then
		self:Venoxis()
	elseif sync == syncName.marli and self.db.profile.aspectmarli then
		self:Marli()
	elseif sync == syncName.marliAvoid and self.db.profile.aspectmarli then
		self:MarliAvoid()
	elseif sync == syncName.thekalStart and self.db.profile.aspectthekal then
		self:ThekalStart()
	elseif sync == syncName.thekalStop and self.db.profile.aspectthekal then
		self:ThekalStop()
	end
end

function module:Siphon()
	self:RemoveWarningSign(icon.serpent)
	self:RemoveBar(L["cicd_bar"])
	if self.db.profile.mc then
		self:DelayedBar(timer.siphoneffect, L["cicd_bar"], 20, icon.mc, true, "blue")
	end
	if self.db.profile.siphon then
		self:RemoveBar(L["siphoncd_bar"])
		self:Bar(L["siphoncd_bar"], timer.siphoncd, icon.siphon, true, "green")
		self:Bar(L["siphoneffect_bar"], timer.siphoneffect, icon.siphon, true, "green")
		self:DelayedMessage(timer.siphoncd - 25, string.format(L["killtheson_warn"], 25), "Urgent")
		self:DelayedMessage(timer.siphoncd - 10, string.format(L["getpoison_warn"], 10), "Attention")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.siphoncd - 25, icon.serpent, 3)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.siphoncd - 10, "Beware")
		end
	end
	if self.db.profile.aspectjeklik then
		self:RemoveBar(L["jeklikcd_bar"])
	end
	if self.db.profile.aspectvenoxis then
		self:RemoveBar(L["venoxiscd_bar"])
	end
	if self.db.profile.aspectmarli then
		self:RemoveBar(L["marlicd_bar"])
	end
	if self.db.profile.aspectarlokk then
		self:RemoveBar(L["arlokkcd_bar"])
	end
	if self.db.profile.aspectthekal then
		self:RemoveBar(L["thekalcd_bar"])
	end
end

function module:ci(rest)
	self:RemoveBar(L["cicd_bar"])
	self:Bar(L["cicd_bar"], timer.cicd, icon.mc, true, "blue")
	self:Bar(rest..L["mced_bar"], timer.cieffect, icon.mc, true, "blue")
	self:SetCandyBarOnClick("BigWigsBar "..rest..L["mced_bar"], function(name, button, extra) TargetByName(extra, true) end, rest)
	self:Message(rest..L["mc_warn"], "Attention")
	if playerClass == "MAGE" then
		if self.db.profile.bigicon then
			self:WarningSign(icon.sheep, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Info")
		end
	end	
	if playerClass == "PRIEST" then
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.cieffect, icon.dispel, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.cieffect, "Info")
		end
	end
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", rest)
		self:ScheduleEvent("BigWigs_RemoveRaidIcon", timer.cieffect)
	end
end

function module:ciFail()
	self:RemoveBar(L["cicd_bar"])
	self:Bar(L["cicd_bar"], timer.cicd, icon.mc, true, "blue")
end

function module:WillOfHakkar(rest)
	--self:RemoveBar(L["willcd_bar"])
	--self:Bar(L["willcd_bar"], timer.willcd, icon.mc, true, "blue")
	self:Bar(rest..L["mced_bar"], timer.willed, icon.mc, true, "blue")
	self:SetCandyBarOnClick("BigWigsBar "..rest..L["mced_bar"], function(name, button, extra) TargetByName(extra, true) end, rest)
	self:Message(rest..L["mc_warn"], "Attention")
	if playerClass == "MAGE" then
		if self.db.profile.bigicon then
			self:WarningSign(icon.sheep, 0.7)
		end
		if self.db.profile.sounds then
			self:Sound("Info")
		end
	end	
	if playerClass == "PRIEST" then
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.willeffect, icon.dispel, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.willeffect, "Info")
		end
	end
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", rest)
		self:ScheduleEvent("BigWigs_RemoveRaidIcon", timer.willeffect)
	end
end

function module:WillFail()

end

function module:Enrage()
	self:DelayedBar(timer.enrage-120, L["enrage_bar"], timer.enrage-480, icon.enrage, true, "red")
	self:DelayedMessage(timer.enrage - 120, L["enrage2minutes_message"], "Urgent")
	self:DelayedMessage(timer.enrage - 60, L["enrage1minute_message"], "Urgent")
	self:DelayedMessage(timer.enrage - 30, string.format(L["enrageseconds_message"], 30), "Urgent")
	self:DelayedMessage(timer.enrage - 10, string.format(L["enrageseconds_message"], 10), "Attention")
end

function module:Enraged()
	self:Message(L["enrage_warn"], "Important")
	if playerClass == "WARRIOR" and self.db.profile.shieldwall then
		self:WarningSign(icon.shieldwall, 1)
	end
end

function module:Jeklik()
	self:RemoveBar(L["jeklikcd_bar"])
	self:RemoveBar(L["jeklikeffect_bar"])
	self:Bar(L["jeklikcd_bar"], timer.jeklikcd, icon.jeklik, true, "Orange")
	self:Bar(L["jeklikeffect_bar"], timer.jeklikeffect, icon.jeklik, true, "Orange")
end

function module:Arlokk()
	self:RemoveBar(L["arlokkcd_bar"])
	self:RemoveBar(L["arlokkeffect_bar"])
	self:Bar(L["arlokkcd_bar"], timer.arlokkcd, icon.arlokk, true, "Blue")
	self:Bar(L["arlokkeffect_bar"]..rest, timer.arlokkeffect, icon.arlokk, true, "Blue")
end

function module:ArlokkAvoid()
	self:RemoveBar(L["arlokkcd_bar"])
	self:Bar(L["arlokkcd_bar"], timer.arlokkcd, icon.arlokk, true, "Blue")
end

function module:Venoxis()
	self:RemoveBar(L["venoxiscd_bar"])
	self:RemoveBar(L["venoxiseffect_bar"])
	self:Bar(L["venoxiscd_bar"], timer.venoxiscd, icon.venoxis, true, "Green")
	self:Bar(L["venoxiseffect_bar"], timer.venoxiseffect, icon.venoxis, true, "Green")
end

function module:Marli()
	self:RemoveBar(L["marlicd_bar"])
	self:Bar(L["marlicd_bar"], timer.marlicd, icon.marli, true, "Yellow")
	self:Bar(L["marlieffect_bar"]..rest, timer.marlieffect, icon.marli, true, "Yellow")
end

function module:MarliAvoid()
	self:RemoveBar(L["marlicd_bar"])
	self:Bar(L["marlicd_bar"], timer.marlicd, icon.marli, true, "Yellow")
end

function module:ThekalStart()
	self:Bar(L["thekalcd_bar"], timer.thekalcd, icon.thekal, true, "Black")
	self:Bar(L["thekaleffect_bar"], timer.thekaleffect, icon.thekal, true, "Black")
	self:Message(L["thekal_warn"], "Important", true, "Alarm")
end

function module:ThekalStop()
	self:RemoveBar(L["thekaleffect_bar"])
end

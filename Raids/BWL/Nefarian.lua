
local module, L = BigWigs:ModuleDeclaration("Nefarian", "Blackwing Lair")
local victor = AceLibrary("Babble-Boss-2.2")["Lord Victor Nefarius"]

module.revision = 20042
module.enabletrigger = {boss, victor}
module.toggleoptions = {"bigicon", "sounds", "curse", "mc", "icon", "shadowflame", "fear", "classcall", "otherwarn", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Nefarian",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",

	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Nefarian casts AoE Fear",

	icon_cmd = "icon",
	icon_name = "MC icon",
	icon_desc = "Place raid icon on the MC'd person (requires promoted or higher)",
	
	classcall_cmd = "classcall",
	classcall_name = "Class Call alert",
	classcall_desc = "Warn for Class Calls",

	otherwarn_cmd = "otherwarn",
	otherwarn_name = "Other alerts",
	otherwarn_desc = "Landing and Zerg warnings",

	curse_cmd = "curse",
	curse_name = "Veil Of Shadow",
	curse_desc = "Shows a timer bar for Veil Of Shadow.",

	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon alert for Sheep on MC and Fear",
	bigicon_desc = "Shows a big icon to Sheep on MC and when Fear is cast",
	
	sounds_cmd = "sounds",
	sounds_name = "Sheep! sound alert",
	sounds_desc = "Sound effect when you should sheep",

	engage_trigger = "Let the games begin!",
	landed_trigger = "BURN! You wretches",
	landingSOON_trigger = "courage begins to wane",
	land = "Estimated Landing",
	landing_warning = "Nefarian is landing!",
	landed_warning = "Nefarian has Landed!",
	
	fear_trigger = "Nefarian begins to cast Bellowing Roar",
	triggerfear = "by Panic.",
	fear_over_trigger = "Bellowing Roar",
	fear_warn = "Fear NOW!",
	fear_soon_warning = "Possible fear in ~5 sec",
	fear_bar = "Fear CD",
	fearsoon_bar = "Fear Soon...",
	
	shadowcurseyou_trigger = "You are afflicted by Veil of Shadow\.",
	shadowcurseother_trigger = "(.+) is afflicted by Veil of Shadow\.",
	curse_bar = "Veil Of Shadow CD",
	
	Mob_Spawn = "Mob Spawn",

	triggershamans	= "Shamans, show me",
	triggerdruid	= "Druids and your silly",
	triggerwarlock	= "Warlocks, you shouldn't be playing",
	triggerpriest	= "Priests! If you're going to keep",
	triggerhunter	= "Hunters and your annoying",
	triggerwarrior	= "Warriors, I know you can hit harder",
	triggerrogue	= "Rogues%? Stop hiding",
	triggerpaladin	= "Paladins",
	triggermage		= "Mages too%?",

	zerg_trigger = "Impossible! Rise my",
	zerg_warning = "Zerg incoming!",

	shadowflame_trigger = "Nefarian begins to cast Shadow Flame",
	shadowflame_warning = "Shadow Flame incoming!",
	shadowflame_bar = "Shadow Flame CD",
	shadowflamecast_bar = "Shadow Flame INC!",

	classcall_warning = "Class call incoming!",
	classcall_bar = "Class call",
	warnshaman	= "Shamans - Totems spawned!",
	warndruid	= "Druids - Stuck in cat form!",
	warnwarlock	= "Warlocks - Incoming Infernals!",
	warnpriest	= "Priests - Heals hurt!",
	warnhunter	= "Hunters - Bows/Guns broken!",
	warnwarrior	= "Warriors - Stuck in berserking stance!",
	warnrogue	= "Rogues - Ported and rooted!",
	warnpaladin	= "Paladins - Blessing of Protection!",
	warnmage	= "Mages - Incoming polymorphs!",

	mindcontrolother_trigger = "(.*) is afflicted by Shadow Command.",
	mindcontrolotherend_trigger = "Shadow Command fades from (.*).",
	deathother_trigger = "(.*) dies.",

	mindcontrolyou_trigger = "You are afflicted by Shadow Command.",
	mindcontrolyouend_trigger = "Shadow Command fades from you.",
	deathyou_trigger = "You die.",
	
	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_message_you = "You are mindcontrolled!",
	mindcontrol_bar = "MC: %s",

	["NefCounter_Trigger"] = "^([%w ]+) dies.",
	["NefCounter_RED"] = "Red Drakonid",
	["NefCounter_GREEN"] = "Green Drakonid",
	["NefCounter_BLUE"] = "Blue Drakonid",
	["NefCounter_BRONZE"] = "Bronze Drakonid",
	["NefCounter_BLACK"] = "Black Drakonid",
	["NefCounter_CHROMATIC"] = "Chromatic Drakonid",
	["Drakonids dead"] = true,
} end)

local timer = {
	mobspawn = 10,
	firstClasscall = 33,
	classcallInterval = 30,
	mc = 15,
	landingShadowflame = 10,
	firstShadowflame = 10,
	shadowflame = 10,
	shadowflameCast = 2,
	fear = 23,
	fearCast = 1.5,
	fearsoon = 15,
	landing = 12,
	firstCurse = 21,
	curseInterval = 15,
	sheep = 0.7,
}

local icon = {
	mobspawn = "Spell_Holy_PrayerOfHealing",
	classcall = "Spell_Shadow_Charm",
	mc = "Spell_Shadow_Charm",
	fear = "Spell_Shadow_Possession",
	shadowflame = "Spell_Fire_Incinerate",
	landing = "INV_Misc_Head_Dragon_Black",
	curse = "Spell_Shadow_GatherShadows",
	sheep = "Spell_Nature_Polymorph",
}

local syncName = {
	shadowflame = "NefarianShadowflame"..module.revision,
	fear = "NefarianFear"..module.revision,
	landing = "NefarianLandingSOON"..module.revision,
	landed = "NefarianLanded"..module.revision,
	addDead = "NefCounter"..module.revision,
	curse = "NefarianCurse"..module.revision,
	mc = "NefarianMC"..module.revision.."_",
	mcEnd = "NefarianMCEnd"..module.revision.."_",
}

local _, playerClass = UnitClass("player")
local warnpairs = nil
local nefCounter = nil
local nefCounterMax = 42

module:RegisterYellEngage(L["engage_trigger"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "Event")

	if not warnpairs then
		warnpairs = {
			[L["triggershamans"]] = {L["warnshaman"], true},
			[L["triggerdruid"]] = {L["warndruid"], true},
			[L["triggerwarlock"]] = {L["warnwarlock"], true},
			[L["triggerpriest"]] = {L["warnpriest"], true},
			[L["triggerhunter"]] = {L["warnhunter"], true},
			[L["triggerwarrior"]] = {L["warnwarrior"], true},
			[L["triggerrogue"]] = {L["warnrogue"], true},
			[L["triggerpaladin"]] = {L["warnpaladin"], true},
			[L["triggermage"]] = {L["warnmage"], true},
			[L["zerg_trigger"]] = {L["zerg_warning"]},
		}
	end

	self:ThrottleSync(10, syncName.shadowflame)
	self:ThrottleSync(15, syncName.fear)
	self:ThrottleSync(0, syncName.addDead)
	self:ThrottleSync(5, syncName.curse)
end

function module:OnSetup()
	self.started = nil
	self.phase2 = nil
	nefCounter = 0
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	self:Bar(L["Mob_Spawn"], timer.mobspawn, icon.mobspawn)
	self:TriggerEvent("BigWigs_StartCounterBar", self, L["Drakonids dead"], nefCounterMax, "Interface\\Icons\\inv_egg_01")
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["Drakonids dead"], (nefCounterMax - 0.1))
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	local _, _, drakonid = string.find(msg, L["NefCounter_Trigger"])
	if drakonid and L:HasReverseTranslation(drakonid) then
		self:DebugMessage("Drakonids dead: " .. tostring(nefCounter + 1) .. " Name: " .. drakonid)
		self:Sync(syncName.addDead .. " " .. tostring(nefCounter + 1))
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["engage_trigger"]) and not self.engaged then
		self:DebugMessage("SendEngageSync")
		self:SendEngageSync()
	end
	if string.find(msg, L["landingSOON_trigger"]) then
		self:Sync(syncName.landing)
	end
	if string.find(msg, L["landed_trigger"]) then
		self:Sync(syncName.landed)
	end
	for i,v in pairs(warnpairs) do
		if string.find(msg, i) then
			if v[2] then
				if self.db.profile.classcall then
					for k,w in pairs(warnpairs) do
						self:RemoveBar(w[1])
					end
					self:RemoveBar(L["classcall_bar"])
					local localizedClass, englishClass = UnitClass("player");
					if string.find(msg, localizedClass) then
						self:Message(v[1], "Core", nil, "Beware")
						self:WarningSign(icon.classcall, 3)
					else
						self:Message(v[1], "Core", nil, "Long")
					end

					self:Bar(v[1], timer.classcallInterval, icon.classcall, true, "white")
					self:DelayedMessage(timer.classcallInterval - 3, L["classcall_warning"], "Important")
					self:DelayedSound(timer.classcallInterval - 3, "Three")
					self:DelayedSound(timer.classcallInterval - 2, "Two")
					self:DelayedSound(timer.classcallInterval - 1, "One")
				end
			else
				if self.db.profile.otherwarn and string.find(msg, L["zerg_trigger"]) then
					self:Message(v[1], "Important", true, "Long")
				end
			end
			return
		end
	end
end

function module:Event(msg)
	local _,_,mindcontrolother,_ = string.find(msg, L["mindcontrolother_trigger"])
	local _,_,mindcontrolotherend,_ = string.find(msg, L["mindcontrolotherend_trigger"])
	local _,_,mindcontrolotherdeath,_ = string.find(msg, L["deathother_trigger"])
	local _,_,shadowcurseother,_ = string.find(msg, L["shadowcurseother_trigger"])
	if string.find(msg, L["shadowcurseyou_trigger"]) then
		self:Sync(syncName.curse)
	elseif shadowcurseother then
		self:Sync(syncName.curse)
	end
	if string.find(msg, L["mindcontrolyou_trigger"]) then
		self:Sync(syncName.mc .. UnitName("player"))
	elseif string.find(msg, L["mindcontrolyouend_trigger"]) then
		self:Sync(syncName.mcEnd .. UnitName("player"))
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:Sync(syncName.mcEnd .. UnitName("player"))
	elseif mindcontrolother then
		self:Sync(syncName.mc .. mindcontrolother)
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", mindcontrolother)
		end
		if playerClass == "MAGE" and self.db.profile.bigicon then
			self:WarningSign(icon.sheep, timer.sheep)
			if self.db.profile.sounds then
				self:Sound("Info")
			end
		end
	elseif mindcontrolotherend then
		self:Sync(syncName.mcEnd .. mindcontrolotherend)
		self:TriggerEvent("BigWigs_RemoveRaidIcon")
	elseif mindcontrolotherdeath then
		self:Sync(syncName.mcEnd .. mindcontrolotherdeath)
	end
	if string.find(msg, L["fear_trigger"]) then
		self:Sync(syncName.fear)
	end
	if string.find(msg, L["shadowflame_trigger"]) then
		self:Sync(syncName.shadowflame)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == self.translatedName then
		if UnitHealthMax(msg) == 100 then
			if  UnitHealth(msg) == 23 then
				self:Message("23")
				self:Sound("twentythree")
			end
			if  UnitHealth(msg) == 22 then
				self:Message("22")
				self:Sound("twentytwo")
			end
			if  UnitHealth(msg) == 21 then
				self:Message("21")
				self:Sound("twentyone")
			end
			if  UnitHealth(msg) == 20 then
				self:Sound("incoming")
				self:UnregisterEvent("UNIT_HEALTH")
			end
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shadowflame then
		self:Shadowflame()
	elseif sync == syncName.fear then
		self:Fear()
	elseif sync == syncName.landing then
		self:Landing()
	elseif sync == syncName.landed then
		self:Landed()
	elseif sync == syncName.addDead and rest then
		self:NefCounter(rest)
	elseif sync == syncName.curse then
		self:Curse()
	elseif string.find(sync, syncName.mc) then
		if self.db.profile.mc then
			chosenone = string.sub(sync,17)
			if chosenone == UnitName("player") then
				self:Message(L["mindcontrol_message_you"], "Attention")
				self:Bar(string.format(L["mindcontrol_bar"], UnitName("player")), timer.mc, icon.mc)
			else
				self:Bar(string.format(L["mindcontrol_bar"], chosenone .. " >Click Me!<"), timer.mc, icon.mc)
				self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], chosenone .. " >Click Me!<"), function(name, button, extra) TargetByName(extra, true) end, chosenone)
				self:Message(string.format(L["mindcontrol_message"], chosenone), "Urgent")
			end
		end
	elseif string.find(sync, syncName.mcEnd) then
		if self.db.profile.mc then
			luckyone = string.sub(sync,20)
			self:RemoveBar(string.format(L["mindcontrol_bar"], luckyone .. " >Click Me!<"))
			self:TriggerEvent("BigWigs_RemoveRaidIcon")
		end
	end
end

function module:Curse()
	if self.db.profile.curse then
		self:Bar(L["curse_bar"], timer.curseInterval, icon.curse, true, "green")
	end
end

function module:Shadowflame()
	if self.db.profile.shadowflame then
		self:RemoveBar(L["shadowflame_bar"])
		self:Bar(L["shadowflamecast_bar"], timer.shadowflameCast, icon.shadowflame, true, "red")
		self:Message(L["shadowflame_warning"], "Important", true, "Alarm")
		self:DelayedBar(timer.shadowflameCast, L["shadowflame_bar"], timer.shadowflame-timer.shadowflameCast, icon.shadowflame, true, "red")
	end
end

function module:Fear()
	if self.db.profile.fear then
		self:RemoveBar(L["fear_bar"])
		self:RemoveBar(L["fearsoon_bar"])
		self:Message(L["fear_warn"], "Important", true, "Info")
		self:Bar(L["fear_warn"], timer.fearCast, icon.fear, true, "blue")
		self:DelayedBar(timer.fearCast, L["fear_bar"], timer.fear, icon.fear, true, "blue")
		self:DelayedBar(timer.fear+timer.fearCast, L["fearsoon_bar"], timer.fearsoon, icon.fear, true, "blue")
		if self.db.profile.bigicon then
			self:WarningSign(icon.fear, 0.7)
		end
	end
end

function module:Landed()
	self:Bar(L["classcall_bar"], timer.firstClasscall, icon.classcall, true, "white")
	self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "blue")
	self:DelayedBar(timer.fear, L["fearsoon_bar"], timer.fearsoon, icon.fear, true, "blue")
	self:Bar(L["curse_bar"], timer.firstCurse, icon.curse, true, "green")
	self:Bar(L["shadowflame_bar"], timer.firstShadowflame, icon.shadowflame, true, "red")
	self:Message(L["landed_warning"], "Attention")
	self:KTM_Reset()
end

function module:Landing()
	if not self.phase2 then
		self.phase2 = true
		self:RemoveBar(L["land"])
		self:TriggerEvent("BigWigs_StopCounterBar", self, L["Drakonids dead"])
		self:Bar(L["shadowflamecast_bar"], timer.landingShadowflame, icon.shadowflame, true, "red")
		self:Bar(L["landing_warning"], timer.landing, icon.landing, true, "white")
		self:Message(L["landing_warning"], "Important", nil, "Beware")
	end
end

function module:NefCounter(n)
	n = tonumber(n)
	if not self.phase2 and n == (nefCounter + 1) and nefCounter <= nefCounterMax then
		nefCounter = nefCounter + 1

		self:TriggerEvent("BigWigs_SetCounterBar", self, L["Drakonids dead"], (nefCounterMax - nefCounter))
	end
end

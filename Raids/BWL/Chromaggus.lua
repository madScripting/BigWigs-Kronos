
local module, L = BigWigs:ModuleDeclaration("Chromaggus", "Blackwing Lair")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "enrage", "frenzy", "breath", "breathcd", "vulnerability", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Chromaggus",

	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Warn before the Enrage phase at 20%.",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy",
	frenzy_desc = "Warn for Frenzy.",

	breath_cmd = "breath",
	breath_name = "Breaths",
	breath_desc = "Warn for Breaths.",

	breathcd_cmd = "breathcd",
	breathcd_name = "Breath Voice Countdown",
	breathcd_desc = "Voice warning for the Breaths.",

	vulnerability_cmd = "vulnerability",
	vulnerability_name = "Vulnerability",
	vulnerability_desc = "Warn for Vulnerability changes.",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Bronze big icon alert",
	bigicon_desc = "Shows a big icon when you have bronze",

	breath_trigger = "Chromaggus begins to cast (.+)\.",
	vulnerability_direct_test = "^[%w]+[%s's]* ([%w%s:]+) ([%w]+) Chromaggus for ([%d]+) ([%w]+) damage%.[%s%(]*([%d]*)",
	vulnerability_dots_test = "^Chromaggus suffers ([%d]+) ([%w]+) damage from [%w]+[%s's]* ([%w%s:]+)%.[%s%(]*([%d]*)",
	frenzy_trigger = "goes into a killing frenzy",
	frenzyfade_trigger = "Frenzy fades from Chromaggus\.",
	vulnerability_trigger = "flinches as its skin shimmers.",

	hit = "hits",
	crit = "crits",

	firstbreaths_warning = "Breath in 10s hide LEFT of OffTank!",
	breath_warning = "%s in 10s hide LEFT of OffTank!",
	breath_message = "%s is casting!",
	vulnerability_message = "Vulnerability: %s!",
	vulnerability_warning = "Spell vulnerability changed!",
	frenzy_message = "Frenzy! TRANQ NOW!",
	enrage_warning = "Enrage at 20%!",

	breath1 = "Time Lapse",
	breath2 = "Corrosive Acid",
	breath3 = "Ignite Flesh",
	breath4 = "Incinerate",
	breath5 = "Frost Burn",

	breathcolor1 = "black",
	breathcolor2 = "green",
	breathcolor3 = "orange",
	breathcolor4 = "red",
	breathcolor5 = "blue",

	icon1 = "Spell_Arcane_PortalOrgrimmar",
	icon2 = "Spell_Nature_Acid_01",
	icon3 = "Spell_Fire_Fire",
	icon4 = "Spell_Shadow_ChillTouch",
	icon5 = "Spell_Frost_ChillingBlast",

	castingbar = "Cast %s",
	frenzy_bar = "Frenzy",
	frenzy_Nextbar = "Next Frenzy",
	first_bar = "First Breath",
	second_bar = "Second Breath",
	vuln_bar = "%s Vulnerability CD",

	fire = "Fire",
	frost = "Frost",
	shadow = "Shadow",
	nature = "Nature",
	arcane = "Arcane",

	curseofdoom = "Curse of Doom",
	ignite = "Ignite",
	starfire = "Starfire",
	thunderfury = "Thunderfury",
	
	bronze = "You are afflicted by Brood Affliction: Bronze.",	
} end )

local timer = {
	firstBreath = 30,
	secondBreath = 60,
	breathInterval = 58,
	breathCast = 2,
	frenzy = 8,
	nextFrenzy = 15,
	vulnerability = 15
}

local icon = {
	unknown = "INV_Misc_QuestionMark",
	breath1 = "Spell_Arcane_PortalOrgrimmar",
	breath2 = "Spell_Nature_Acid_01",
	breath3 = "Spell_Fire_Fire",
	breath4 = "Spell_Shadow_ChillTouch",
	breath5 = "Spell_Frost_ChillingBlast",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
	vulnerability = "Spell_Shadow_BlackPlague",
	bronze =  "inv_misc_head_dragon_bronze",
}

local syncName = {
	breath = "ChromaggusBreath"..module.revision,
	frenzy = "ChromaggusFrenzyStart"..module.revision,
	frenzyOver = "ChromaggusFrenzyStop"..module.revision,
}

local lastFrenzy = 0
local _, playerClass = UnitClass("player")
local breathCache = {}

local vulnerability = nil
local twenty = nil
local frenzied = nil
local lastVuln = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	
	self:ThrottleSync(10, "ChromaggusEngage")
	self:ThrottleSync(25, syncName.breath)
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(5, syncName.frenzyOver)
end

function module:OnSetup()
	vulnerability = nil
	twenty = nil
	self.started = nil
	frenzied = nil
	lastVuln = 0
end

function module:OnEngage()
	if self.db.profile.breath then
		local firstBarName  = L["first_bar"]
		local firstBarMSG   = L["firstbreaths_warning"]
		local secondBarName = L["second_bar"]
		local secondBarMSG  = L["firstbreaths_warning"]
		if table.getn(breathCache) == 2 then
			firstBarName  = string.format(L["castingbar"], breathCache[1])
			firstBarMSG   = string.format(L["breath_message"], breathCache[1])
			secondBarName = string.format(L["castingbar"], breathCache[2])
			secondBarMSG  = string.format(L["breath_message"], breathCache[2])
		elseif table.getn(breathCache) == 1 then
			firstBarName  = string.format(L["castingbar"], breathCache[1])
			firstBarMSG   = string.format(L["breath_message"], breathCache[1])
		end
		self:DelayedMessage(timer.firstBreath - 10, firstBarMSG, "Attention")
		self:Bar(firstBarName, timer.firstBreath, icon.unknown, true, "cyan")
		self:DelayedMessage(timer.secondBreath - 10, secondBarMSG, "Attention")
		self:Bar(secondBarName, timer.secondBreath, icon.unknown, true, "cyan")
	end
	if self.db.profile.breathcd then
		self:DelayedSound(timer.firstBreath - 10, "hide", "bl_10")
		self:DelayedSound(timer.firstBreath - 3, "Three", "b1_3")
		self:DelayedSound(timer.firstBreath - 2, "Two", "b1_2")
		self:DelayedSound(timer.firstBreath - 1, "One", "b1_1")
		
		self:DelayedSound(timer.secondBreath - 10, "hide", "bl_10")
		self:DelayedSound(timer.secondBreath - 3, "Three", "b2_3")
		self:DelayedSound(timer.secondBreath - 2, "Two", "b2_2")
		self:DelayedSound(timer.secondBreath - 1, "One", "b2_1")
	end
	if self.db.profile.frenzy then
		self:Bar(L["frenzy_Nextbar"], timer.nextFrenzy, icon.frenzy, true, "white")
	end
	self:Bar(format(L["vuln_bar"], "???"), timer.vulnerability, icon.vulnerability, true, "yellow")
	lastVuln = GetTime()
end

function module:OnDisengage()
end

function module:UNIT_HEALTH( msg )
	if self.db.profile.enrage and UnitName(msg) == module.translatedName then
		local health = UnitHealth(msg)
		if health > 15 and health <= 20 and not twenty then
			self:Message(L["enrage_warning"], "Important", true, "Beware")
			twenty = true
		elseif health > 90 and twenty then
			twenty = nil
		end
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	local _,_, spellName = string.find(msg, L["breath_trigger"])
	if spellName then
		local breath = L:HasReverseTranslation(spellName) and L:GetReverseTranslation(spellName) or nil
		if breath then
			breath = string.sub(breath, -1)
			self:Sync(syncName.breath .. " " ..breath)
		end
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["frenzy_trigger"]) and arg2 == module.translatedName then
		self:Sync(syncName.frenzy)
	elseif string.find(msg, L["vulnerability_trigger"]) then
		if self.db.profile.vulnerability then
			self:Message(L["vulnerability_warning"], "Positive")
			if vulnerability then
				self:RemoveBar(format(L["vuln_bar"], vulnerability))
			end
			self:Bar(format(L["vuln_bar"], "???"), timer.vulnerability, icon.vulnerability, true, "yellow")
		end
		lastVuln = GetTime()
		vulnerability = nil
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if msg == L["frenzyfade_trigger"] then
		self:Sync(syncName.frenzyOver)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if not self.db.profile.vulnerability then return end
	if not vulnerability then
		local _, _, dmg, school, userspell, partial = string.find(msg, L["vulnerability_dots_test"])
		if dmg and school and userspell then
			if school == L["arcane"] then
				if partial and partial ~= "" then
					if tonumber(dmg)+tonumber(partial) >= 250 then
						self:IdentifyVulnerability(school)
					end
				else
					if tonumber(dmg) >= 250 then
						self:IdentifyVulnerability(school)
					end
				end
			elseif school == L["fire"] and not string.find(userspell, L["ignite"]) then
				if partial and partial ~= "" then
					if tonumber(dmg)+tonumber(partial) >= 400 then
						self:IdentifyVulnerability(school)
					end
				else
					if tonumber(dmg) >= 400 then
						self:IdentifyVulnerability(school)
					end
				end
			elseif school == L["nature"] then
				if partial and partial ~= "" then
					if tonumber(dmg)+tonumber(partial) >= 300 then
						self:IdentifyVulnerability(school)
					end
				else
					if tonumber(dmg) >= 300 then
						self:IdentifyVulnerability(school)
					end
				end
			elseif school == L["shadow"] then
				if string.find(userspell, L["curseofdoom"]) then
					if partial and partial ~= "" then
						if tonumber(dmg)+tonumber(partial) >= 3000 then
							self:IdentifyVulnerability(school)
						end
					else
						if tonumber(dmg) >= 3000 then
							self:IdentifyVulnerability(school)
						end
					end
				else
					if partial and partial ~= "" then
						if tonumber(dmg)+tonumber(partial) >= 500 then
							self:IdentifyVulnerability(school)
						end
					else
						if tonumber(dmg) >= 500 then
							self:IdentifyVulnerability(school)
						end
					end
				end
			end
		end
	end
end

function module:PlayerDamageEvents(msg)
	if not self.db.profile.vulnerability then return end
	if not vulnerability then
		local _, _, userspell, stype, dmg, school, partial = string.find(msg, L["vulnerability_direct_test"])
		if stype and dmg and school then
			if school == L["arcane"] then
				if string.find(userspell, L["starfire"]) then
					if partial and partial ~= "" then
						if (tonumber(dmg)+tonumber(partial) >= 800 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					else
						if (tonumber(dmg) >= 800 and stype == L["hit"]) or (tonumber(dmg) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					end
				else
					if partial and partial ~= "" then
						if (tonumber(dmg)+tonumber(partial) >= 600 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					else
						if (tonumber(dmg) >= 600 and stype == L["hit"]) or (tonumber(dmg) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					end
				end
			elseif school == L["fire"] then
				if partial and partial ~= "" then
					if (tonumber(dmg)+tonumber(partial) >= 1300 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 2600 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				else
					if (tonumber(dmg) >= 1300 and stype == L["hit"]) or (tonumber(dmg) >= 2600 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				end
			elseif school == L["frost"] then
				if partial and partial ~= "" then
					if (tonumber(dmg)+tonumber(partial) >= 800 and stype == L["hit"])	or (tonumber(dmg)+tonumber(partial) >= 1600 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				else
					if (tonumber(dmg) >= 800 and stype == L["hit"]) or (tonumber(dmg) >= 1600 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				end
			elseif school == L["nature"] then
				if string.find(userspell, L["thunderfury"]) then
					if partial and partial ~= "" then
						if (tonumber(dmg)+tonumber(partial) >= 800 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					else
						if (tonumber(dmg) >= 800 and stype == L["hit"]) or (tonumber(dmg) >= 1200 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					end
				else
					if partial and partial ~= "" then
						if (tonumber(dmg)+tonumber(partial) >= 900 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 1800 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					else
						if (tonumber(dmg) >= 900 and stype == L["hit"]) or (tonumber(dmg)>= 1800 and stype == L["crit"]) then
							self:IdentifyVulnerability(school)
						end
					end
				end
			elseif school == L["shadow"] then
				if partial and partial ~= "" then
					if (tonumber(dmg)+tonumber(partial) >= 1700 and stype == L["hit"]) or (tonumber(dmg)+tonumber(partial) >= 3400 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				else
					if (tonumber(dmg) >= 1700 and stype == L["hit"]) or (tonumber(dmg) >= 3400 and stype == L["crit"]) then
						self:IdentifyVulnerability(school)
					end
				end
			end
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["bronze"]) and self.db.profile.bigicon then
		self:WarningSign(icon.bronze, 3)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.breath and self.db.profile.breath then
		local spellName = L:HasTranslation("breath"..rest) and L["breath"..rest] or nil
		if not spellName then return end
		if table.getn(breathCache) < 2 then
			breathCache[table.getn(breathCache)+1] = spellName
		end
		local b = "breath"..rest
		self:RemoveBar(L["icon"..rest])
		self:Bar(string.format( L["castingbar"], spellName), timer.breathCast, L["icon"..rest])
		self:Message(string.format(L["breath_message"], spellName), "Important")
		self:DelayedMessage(timer.breathInterval - 10, string.format(L["breath_warning"], spellName), "Important")
		self:DelayedBar(timer.breathCast, spellName, timer.breathInterval, L["icon"..rest], true, L["breathcolor"..rest])
		if self.db.profile.breathcd then
			self:DelayedSound(timer.breathInterval+timer.breathCast - 10, "hide", spellName)
			self:DelayedSound(timer.breathInterval+timer.breathCast - 3, "Three", spellName)
			self:DelayedSound(timer.breathInterval+timer.breathCast - 2, "Two", spellName)
			self:DelayedSound(timer.breathInterval+timer.breathCast - 1, "One", spellName)
		end
	elseif sync == syncName.frenzy then
		if self.db.profile.frenzy and not frenzied then
			self:Message(L["frenzy_message"], "Attention")
			self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "red")

			if playerClass == "HUNTER" then
				self:WarningSign(icon.tranquil, timer.frenzy, true)
			end
		end
		frenzied = true
		lastFrenzy = GetTime()
	elseif sync == syncName.frenzyOver then
		if self.db.profile.frenzy and frenzied then
			self:RemoveBar(L["frenzy_bar"])
			if lastFrenzy ~= 0 then
				local NextTime = (lastFrenzy + timer.nextFrenzy) - GetTime()
				self:Bar(L["frenzy_Nextbar"], NextTime, icon.frenzy, true, "white")
			end
		end
		self:RemoveWarningSign(icon.tranquil, true)
		frenzied = nil
	end
end

function module:IdentifyVulnerability(school)
	if not self.db.profile.vulnerability or not type(school) == "string" then return end
	if (lastVuln + 5) > GetTime() then return end

	vulnerability = school
	self:Message(format(L["vulnerability_message"], school), "Positive")
	if lastVuln then
		self:RemoveBar(format(L["vuln_bar"], "???"))
		self:Bar(format(L["vuln_bar"], school), (lastVuln + timer.vulnerability) - GetTime(), icon.vulnerability, true, "yellow")
	end
end

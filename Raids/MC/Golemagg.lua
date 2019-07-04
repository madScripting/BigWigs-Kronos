
local module, L = BigWigs:ModuleDeclaration("Golemagg the Incinerator", "Molten Core")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sounds", "magma", "earthquake", "enraged", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Golemagg",

	enraged_cmd = "enraged",
	enraged_name = "Announce boss Enrage",
	enraged_desc = "Lets you know when boss hits harder",

	earthquake_cmd = "earthquake",
	earthquake_name = "Earthquake announce",
	earthquake_desc = "Announces when it's time for melees to back off",

	magma_cmd = "magma",
	magma_name = "Announce over 10 stacks",
	magma_desc = "Lets you know when you have too many stacks",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Too many stacks big icon alert",
	bigicon_desc = "Shows a big icon when you have too many stacks",
	
	sounds_cmd = "sounds",
	sounds_name = "Too many stacks sound alert",
	sounds_desc = "Sound effect when you have too many stacks",
		
	magma_trigger = "You are afflicted by Magma Splash %(10%)",
	magmaend_trigger = "Magma Splash fades from you",

	corerager_name = "Core Rager",
	earthquakesoonwarn = "Melee OUT!",
	golemaggenrage = "Golemagg the Incinerator gains Enrage",
	enragewarn = "Boss is enraged!",
} end)

local timer = {
	magma = 600,
}

local icon = {
	magma = "spell_fire_immolation",
}

local syncName = {
	earthquake = "GolemaggEarthquake",
	enrage = "GolemaggEnrage",
}

local earthquakeon = nil
module.wipemobs = { L["corerager_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("UNIT_HEALTH")

	self:ThrottleSync(10, syncName.earthquake)
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
	earthquakeon = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end


function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) > 13 and math.ceil(100*health/maxHealth) <= 18 and not earthquakeon then
			self:Sync(syncName.earthquake)
			earthquakeon = true
		elseif math.ceil(health) > 23 and earthquakeon then
			earthquakeon = nil
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["magma_trigger"]) and self.db.profile.magma then
		self:Magma()
	end
	if string.find(msg, L["magmaend_trigger"]) then
		self:RemoveWarningSign(icon.magma)
	end
	if string.find(msg, L["golemaggenrage"]) then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.earthquake and self.db.profile.earthquake then
		self:Earthquake()
	elseif sync == syncName.enrage and self.db.profile.enraged then
		self:Enraged()
	end
end

function module:Earthquake()
	self:Message(L["earthquakesoonwarn"], "Attention")
	if self.db.profile.sounds then
		self:Sound("meleeout")
	end
end

function module:Magma()
	if self.db.profile.sounds then
		self:Sound("stacks")
	end
	if self.db.profile.bigicon then
		self:WarningSign(icon.magma, timer.magma)
	end
end

function module:Enraged()
	self:Message(L["enragewarn"], "Attention", true, "Beware")
end

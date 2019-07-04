
local module, L = BigWigs:ModuleDeclaration("Living Monstrosity", "Naxxramas")

module.revision = 20048
module.enabletrigger = module.translatedName
module.toggleoptions = { "lightningtotem" }
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Monstrosity",
	
	lightningtotem_cmd = "lightningtotem",
	lightningtotem_name = "Lightning Totem Alert",
	lightningtotem_desc = "Warn for Lightning Totem summon",
	
	lightningtotem_trigger = "Living Monstrosity begins to cast Lightning Totem",
	lightningtotem_trigger2 = "Living Monstrosity casts Lightning Totem.",
	lightningtotem_bar = "SUMMON LIGHTNING TOTEM",
	lightningtotem_message = "LIGHTNING TOTEM INC",
} end )

local timer = {
	lightningTotem = {0.5, 2}
}

local icon = {
	lightningTotem = "Spell_Nature_Lightning"
}

local syncName = {
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["lightningtotem_trigger"]) and self.db.profile.lightningtotem then
		self:Message(L["lightningtotem_message"], "Urgent")
		self:IntervalBar(L["lightningtotem_bar"], timer.lightningTotem[1], timer.lightningTotem[2], icon.lightningTotem, true, "blue")
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if string.find(msg, L["lightningtotem_trigger2"]) and self.db.profile.lightningtotem then
		self:Message(L["lightningtotem_message"], "Urgent")
		self:WarningSign(icon.lightningTotem, 1)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if (msg == string.format(UNITDIESOTHER, "Lightning Totem")) then
		self:RemoveWarningSign(icon.lightningTotem)
	end
end


local module, L = BigWigs:ModuleDeclaration("Jin'do the Hexxer", "Zul'Gurub")

module.revision = 20042
module.enabletrigger = module.translatedName
module.toggleoptions = {"taunt", "bigicon", "sounds", "curse", "hex", "brainwash", "healingward", "icon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Jindo",

	taunt_cmd = "taunt",
	taunt_name = "Taunt Alert",
	taunt_desc = "Warns to taunt on hex",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcons Alert",
	bigicon_desc = "Big icons for totems, dispel, curse",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound Alerts",
	sounds_desc = "Sound alert on totems, hex, curse",
	
	brainwash_cmd = "brainwash",
	brainwash_name = "Brain Wash Totem Alert",
	brainwash_desc = "Warn when Jin'do summons Brain Wash Totems.",

	healingward_cmd = "healingward",
	healingward_name = "Healing Totem Alert",
	healingward_desc = "Warn when Jin'do summons Powerful Healing Wards.",

	curse_cmd = "curse",
	curse_name = "Curse Alert",
	curse_desc = "Warn when players get Delusions of Jin'do.",

	hex_cmd = "hex",
	hex_name = "Hex Alert",
	hex_desc = "Warn when players get Hex.",

	icon_cmd = "icon",
	icon_name = "Raid icon on cursed players",
	icon_desc = "Place a raid icon on the player with Delusions of Jin'do.\n\n(Requires assistant or higher)",
	
	mctotem_trigger = "Jin'do the Hexxer casts Summon Brain Wash Totem.",
	healtotem_trigger = "Jin'do the Hexxer casts Powerful Healing Ward.",
	totem_warn = "Kill the Totem!",

	mctotemcd_bar = "McTotem CD",
	healtotemcd_bar = "HealTotem CD",
	
	curse_trigger = "(.+) (.+) afflicted by Delusions of Jin'do.",
	cursedself_warn = "You are cursed! Kill the Shades!",
	cursed_warn = "Curse on ",
	cursed_bar = "Curse on ",
	cursecd_bar = "Curse CD",
	
	hex_trigger = "(.+) (.+) afflicted by Hex.",
	hexend_trigger = "Hex fades from (.+).",
	hexfail_trigger = "Hex fails",
	hexcd_bar = "Hex CD",
	hexed_bar = "Hex on ",
	hex_warn = "Dispel! Hex on ",
} end )

local timer = {
	firsthex = 8,
	hexcd = 25,
	hexed = 5,

	firsthealtotem = 28,
	healtotemcd = 24.5,

	firstmctotem = 18,
	mctotemcd = 21,

	firstcurse = 5,
	cursecd = 15,
	cursed = 20,
}

local icon = {
	healtotem = "inv_spear_04",
	mctotem = "Spell_Totem_WardOfDraining",
	curse = "spell_shadow_unholyfrenzy",
	hex = "Spell_Nature_Polymorph",
	dispel = "spell_holy_dispelmagic",
	taunt = "spell_nature_reincarnation",
}

local syncName = {
	healtotem = "JindoHealTotem"..module.revision,
	mctotem = "JindoMcTotem"..module.revision,
	curse = "JindoCurse"..module.revision,
	hex = "JindoHex"..module.revision,
	hexend = "JindoHexEnd"..module.revision,
	hexfail = "JindoHexFail"..module.revision,
}

local berserkannounced = nil
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")

	self:ThrottleSync(5, syncName.healtotem)
	self:ThrottleSync(5, syncName.mctotem)
	self:ThrottleSync(5, syncName.curse)
	self:ThrottleSync(4, syncName.hex)
	self:ThrottleSync(1, syncName.hexend)
	self:ThrottleSync(1, syncName.hexfail)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.db.profile.curse then
		self:Bar(L["cursecd_bar"], timer.firstcurse, icon.curse, true, "blue")	
	end
	if self.db.profile.hex then
		self:Bar(L["hexcd_bar"], timer.firsthex, icon.hex, true, "green")	
	end
	if self.db.profile.healingward then
		self:Bar(L["healtotemcd_bar"], timer.firsthealtotem, icon.healtotem, true, "red")	
	end
	if self.db.profile.brainwash then
		self:Bar(L["mctotemcd_bar"], timer.firstmctotem, icon.mctotem, true, "red")	
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,cursedperson = string.find(msg, L["curse_trigger"])
	local _,_,hexedperson= string.find(msg, L["hex_trigger"])
	if string.find(msg, L["healtotem_trigger"]) then
		self:Sync(syncName.healtotem)
	end
	if string.find(msg, L["mctotem_trigger"]) then
		self:Sync(syncName.mctotem)
	end
	if string.find(msg, L["hexend_trigger"]) then
		self:Sync(syncName.hexend)
	end
	if string.find(msg, L["hexfail_trigger"]) then
		self:Sync(syncName.hexfail)
	end	
	if string.find(msg, L["hex_trigger"]) then
		self:Sync(syncName.hex.." "..hexedperson)
	end
	if string.find(msg, L["curse_trigger"]) then
		self:Sync(syncName.curse.." "..cursedperson)
	end	
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:Curse(rest)
	elseif sync == syncName.hex and self.db.profile.hex then
		self:Hex(rest)
	elseif sync == syncName.healtotem and self.db.profile.healingward then
		self:HealTotem()
	elseif sync == syncName.mctotem and self.db.profile.brainwash then
		self:McTotem()
	elseif sync == syncName.hexend then
		self:HexEnd()
	elseif sync == syncName.hexfail then
		self:HexFail()
	end
end

function module:HealTotem()
	self:RemoveBar(L["healtotemcd_bar"])
	self:Bar(L["healtotemcd_bar"], timer.healtotemcd, icon.healtotem, true, "red")
	if self.db.profile.sounds then
		self:Sound("Info")
	end
	if self.db.profile.bigicon then
		self:WarningSign(icon.mctotem, 0.7)
	end
end

function module:McTotem()
	self:RemoveBar(L["mctotemcd_bar"])
	self:Bar(L["mctotemcd_bar"], timer.mctotemcd, icon.mctotem, true, "red")
	if self.db.profile.sounds then
		self:Sound("Info")
	end
	if self.db.profile.bigicon then
		self:WarningSign(icon.mctotem, 0.7)
	end
end

function module:Curse(rest)
	currentcurse = rest
	self:RemoveBar(L["cursecd_bar"])
	self:Bar(L["cursecd_bar"], timer.cursecd, icon.curse, true, "blue")
	self:Bar(L["cursed_bar"]..currentcurse, timer.cursed, icon.curse, true, "blue")
	if self.db.profile.icon then
		self:TriggerEvent("BigWigs_SetRaidIcon", rest)
	end
	if rest == "You" then
		self:Message(L["cursedself_warn"], "Personal")
		if self.db.profile.sounds then
			self:Sound("Beware")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.curse, 0.7)
		end
	end
end

function module:Hex(rest)
	currenthex = rest
	self:RemoveBar(L["hexcd_bar"])
	self:Bar(L["hexcd_bar"], timer.hexcd, icon.hex, true, "green")
	self:Bar(L["hexed_bar"]..currenthex, timer.hexed, icon.hex, true, "green")
	self:Message(L["hex_warn"]..rest, "Attention")
	if rest ~= UnitName("player") then
		if playerClass == "PRIEST" then
			if self.db.profile.sounds then
				self:Sound("Alarm")
			end
			if self.db.profile.bigicon then
				self:WarningSign(icon.dispel, 0.7)
			end
		end
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			if self.db.profile.sounds then
				self:Sound("Alarm")
			end
			if self.db.profile.bigicon then
				self:WarningSign(icon.taunt, 0.7)
			end
		end
	end
end

function module:HexEnd()
	self:RemoveBar(L["hexed_bar"]..currenthex)
end

function module:HexFail()
	self:RemoveBar(L["hexcd_bar"])
	self:Bar(L["hexcd_bar"], timer.hexcd, icon.hex, true, "green")
end


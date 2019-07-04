
local module, L = BigWigs:ModuleDeclaration("General Rajaxx", "Ruins of Ahn'Qiraj")
local andorov = AceLibrary("Babble-Boss-2.2")["Lieutenant General Andorov"]

module.revision = 20041
module.enabletrigger = {module.translatedName, andorov}
module.toggleoptions = {"wave", "thundercrash", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Rajaxx",

	wave_cmd = "wave",
	wave_name = "Wave Alert",
	wave_desc = "Warn for incoming waves",

	thundercrash_cmd = "thundercrash",
	thundercrash_name = "Thundercrash Alert",
	thundercrash_desc = "Warn for Thundercrash",
	
	trigger0 = "Remember, Rajaxx, when I said I'd kill you last?",
	trigger1 = "Kill first, ask questions later... Incoming!",
	trigger2 = "?????",  -- There is no callout for wave 2 ><
	trigger3 = "The time of our retribution is at hand! Let darkness reign in the hearts of our enemies!",
	trigger4 = "No longer will we wait behind barred doors and walls of stone! No longer will our vengeance be denied! The dragons themselves will tremble before our wrath!",
	trigger5 = "Fear is for the enemy! Fear and death!",
	trigger6 = "Staghelm will whimper and beg for his life, just as his whelp of a son did! One thousand years of injustice will end this day!",
	trigger7 = "Fandral! Your time has come! Go and hide in the Emerald Dream and pray we never find you!",
	trigger8 = "Impudent fool! I will kill you myself!",
	trigger10 = "I lied...",

	shield_trigger ="gains Shield of Rajaxx",
	shield = "Shield of Rajaxx",
	shield_cd = "Shield of Rajaxx CD",

	trigger2_2 = "Kill ",

	warn0 = "Wave 1/8",
	warn1 = "Wave 1/8",
	warn2 = "Wave 2/8",
	warn3 = "Wave 3/8",
	warn4 = "Wave 4/8",
	warn5 = "Wave 5/8",
	warn6 = "Wave 6/8",
	warn7 = "Wave 7/8",
	warn8 = "Incoming General Rajaxx",

	thundercrash_trigger = "Thundercrash",
	thundercrash_bar = "Thundercrash CD",
} end )

local timer = {
	yeggethShield = 6,
	thundercrashCD = 14,
}

local icon = {
	yeggethShield = "Spell_Holy_SealOfProtection",
	thundercrash = "Spell_Nature_ThunderClap",
}

local syncName = {
	thundercrash = "RajaxxThundercrash"..module.revision,
}

local wave = nil
module:RegisterYellEngage(L["trigger1"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:ThrottleSync(5, syncName.thundercrash)
	
	self.warnsets = {}
	for i=0,8 do
		self.warnsets[L["trigger"..i]] = L["warn"..i]
	end
end

function module:OnSetup()
end

function module:OnEngage()
	self:Sync(syncName.thundercrash)
end

function module:OnDisengage()
end

function module:CheckForWipe()
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(msg, L["shield_trigger"])then
		self:Bar(L["shield"], timer.yeggethShield, icon.yeggethShield)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if self.db.profile.wave and msg and self.warnsets[msg] then
		self:Message(self.warnsets[msg], "Urgent")
	end
end

function module:Event(msg)
	if string.find(msg, L["thundercrash_trigger"]) then
		self:Sync(syncName.thundercrash)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.thundercrash then
		self:Thundercrash()
	end
end

function module:Thundercrash()
	if self.db.profile.thundercrash then
		self:Bar(L["thundercrash_bar"], timer.thundercrashCD, icon.thundercrash)
	end
end

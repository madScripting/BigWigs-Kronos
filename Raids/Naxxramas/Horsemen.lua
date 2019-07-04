
local module, L = BigWigs:ModuleDeclaration("The Four Horsemen", "Naxxramas")
local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]

module.revision = 20051
module.enabletrigger = {thane, mograine, zeliek, blaumeux}
module.toggleoptions = {"mark", "shieldwall", -1, "meteor", "void", "wrath", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Horsemen",

	mark_cmd = "mark",
	mark_name = "Mark Alerts",
	mark_desc = "Warn for marks",

	shieldwall_cmd  = "shieldwall",
	shieldwall_name = "Shieldwall Alerts",
	shieldwall_desc = "Warn for shieldwall",

	void_cmd = "void",
	void_name = "Void Zone Alerts",
	void_desc = "Warn on Lady Blaumeux casting Void Zone.",

	meteor_cmd = "meteor",
	meteor_name = "Meteor Alerts",
	meteor_desc = "Warn on Thane casting Meteor.",

	wrath_cmd = "wrath",
	wrath_name = "Holy Wrath Alerts",
	wrath_desc = "Warn on Zeliek casting Wrath.",

	marktrigger1 = "afflicted by Mark of Zeliek",
	marktrigger2 = "afflicted by Mark of Korth'azz",
	marktrigger3 = "afflicted by Mark of Blaumeux",
	marktrigger4 = "afflicted by Mark of Mograine",
	mark_warn = "Mark %d!",
	mark_warn_5 = "Mark %d in 5 sec",
	markbar = "Mark %d",

	voidtrigger = "Lady Blaumeux casts Void Zone.",
	voidwarn = "Void Zone Incoming",
	voidbar = "Void Zone",

	meteortrigger = "Thane Korth'azz's Meteor hits ",
	meteorwarn = "Meteor ",
	meteorbar = "Meteor ",

	wrathtrigger = "Sir Zeliek's Holy Wrath hits ",
	wrathwarn = "Holy Wrath!",
	wrathbar = "Holy Wrath",

	shieldwalltrigger = "(.*) gains Shield Wall.",
	shieldwall_warn = "%s - Shield Wall for 20 sec",
	shieldwall_warn_over = "%s - Shield Wall GONE!",
	shieldwallbar = "%s - Shield Wall",
} end )

local timer = {
	firstMark = 20,
	mark = 12,
	firstMeteor = 11,
	meteor = {11, 14},
	firstWrath = 11,
	wrath = {11, 14},
	firstVoid = 11,
	void = {11, 14},
	shieldwall = 20,
}

local icon = {
	mark = "Spell_Shadow_CurseOfAchimonde",
	meteor = "Spell_Fire_Fireball02",
	wrath = "Spell_Holy_Excorcism",
	void = "spell_shadow_antishadow",
	shieldwall = "Ability_Warrior_ShieldWall",
}

local syncName = {
	shieldwall = "HorsemenShieldWall"..module.revision,
	mark = "HorsemenMark"..module.revision,
	void = "HorsemenVoid"..module.revision,
	wrath = "HorsemenWrath"..module.revision,
	meteor = "HorsemenMeteor"..module.revision,
}

local times = nil
local meteorCount = 1

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")

	self:ThrottleSync(3, syncName.shieldwall)
	self:ThrottleSync(8, syncName.mark)
	self:ThrottleSync(5, syncName.void)
	self:ThrottleSync(5, syncName.wrath)
	self:ThrottleSync(5, syncName.meteor)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self.marks = 0
	self.deaths = 0
	meteorCount = 1
	times = {}
end

function module:OnEngage()
	self.marks = 0
	if self.db.profile.mark then
		self:Bar(string.format( L["markbar"], self.marks + 1), timer.firstMark, icon.mark, true, "blue")
		self:DelayedMessage(timer.firstMark - 5, string.format( L["mark_warn_5"], self.marks + 1), "Urgent")
	end
	if self.db.profile.meteor then
		self:Bar(L["meteorbar"]..meteorCount, timer.firstMeteor, icon.meteor, true, "Red")
	end
	if self.db.profile.wrath then
		self:Bar(L["wrathbar"], timer.firstWrath, icon.wrath, true, "White")
	end
	if self.db.profile.void then
		self:Bar(L["voidbar"], timer.firstVoid, icon.void, true, "black")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["shieldwalltrigger"]) then
		local _,_,mob = string.find(msg, L["shieldwalltrigger"])
		self:Sync(syncName.shieldwall .. " " .. mob)
	end
	if string.find(msg, L["marktrigger1"]) or string.find(msg, L["marktrigger2"]) or string.find(msg, L["marktrigger3"]) or string.find(msg, L["marktrigger4"]) then
		self:Sync(syncName.mark)
	end
	if string.find(msg, L["meteortrigger"]) then
		self:Sync(syncName.meteor)
	end
	if string.find(msg, L["wrathtrigger"]) then
		self:Sync(syncName.wrath)
	end
	if string.find(msg, L["voidtrigger"]) then
		self:Sync(syncName.void)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, thane) or
		msg == string.format(UNITDIESOTHER, zeliek) or
		msg == string.format(UNITDIESOTHER, mograine) or
		msg == string.format(UNITDIESOTHER, blaumeux) then
		self.deaths = self.deaths + 1
		if self.deaths == 4 then
			self:SendBossDeathSync()
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mark and self.db.profile.mark then
		self:Mark()
	elseif sync == syncName.meteor and self.db.profile.meteor then
		self:Meteor()
	elseif sync == syncName.wrath and self.db.profile.wrath then
		self:Wrath()
	elseif sync == syncName.void and self.db.profile.void then
		self:Void()
	elseif sync == syncName.shieldwall and self.db.profile.shieldwall then
		self:Shieldwall(rest)
	end
end

function module:Mark()
	self:RemoveBar(string.format(L["markbar"], self.marks))
	self.marks = self.marks + 1
	self:Message(string.format(L["mark_warn"], self.marks), "Important", nil, nil)
	self:Bar(string.format(L["markbar"], self.marks + 1), timer.mark, icon.mark, true, "blue")
	self:DelayedMessage(timer.mark - 5, string.format( L["mark_warn_5"], self.marks + 1), "Urgent")
end

function module:Meteor()
	self:Message(L["meteorwarn"]..meteorCount, "Important", nil, nil)
	meteorCount = meteorCount+1
	self:IntervalBar(L["meteorbar"]..meteorCount, timer.meteor[1], timer.meteor[2], icon.meteor, true, "Red")
end

function module:Wrath()
	if UnitName("target") == "Sir Zeliek" or UnitName("targettarget") == "Sir Zeliek" then
		self:Message(L["wrathwarn"], "Important", nil, nil)
		self:IntervalBar(L["wrathbar"], timer.wrath[1], timer.wrath[2], icon.wrath, true, "White")
	end
end

function module:Void()
	if UnitName("target") == "Lady Blaumeux" or UnitName("targettarget") == "Lady Blaumeux" then
		self:WarningSign(icon.void, 1)
		self:Message(L["voidwarn"], "Important", nil, "Info")
		self:IntervalBar(L["voidbar"], timer.void[1], timer.void[2], icon.void, true, "black")
	end
end

function module:Shieldwall(mob)
	self:Message(string.format(L["shieldwall_warn"], mob), "Attention", nil, nil)
	self:Bar(string.format(L["shieldwallbar"], mob), timer.shieldwall, icon.shieldwall, true, "yellow")
	self:DelayedMessage(timer.shieldwall, string.format(L["shieldwall_warn_over"], mob), "Positive", nil, nil)
end

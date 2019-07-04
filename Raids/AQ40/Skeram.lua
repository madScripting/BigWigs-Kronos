
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("The Prophet Skeram", "Ahn'Qiraj")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	mcplayer = "You are afflicted by True Fulfillment.",
	mcplayerother = "(.*) is afflicted by True Fulfillment.",
	mcplayeryouend = "True Fulfillment fades from you.",
	mcplayerotherend = "True Fulfillment fades from (.*).",
	mcplayer_message = "You are mindcontrolled!",
	mcplayerother_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",
	deathyou_trigger = "You die.",
	deathother_trigger = "(.*) dies.",
	splitsoon_message = "Split soon! Get ready!",
	split_message = "Split!",
	kill_trigger = "You only delay",

	cmd = "Skeram",

	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",

	split_cmd = "split",
	split_name = "Split Alert",
	split_desc = "Warn before Splitting",
	["You have slain %s!"] = true,
} end )

L:RegisterTranslations("deDE", function() return {
	mcplayer = "Ihr seid von Wahre Erf\195\188llung betroffen.",
	mcplayerother = "(.*) ist von Wahre Erf\195\188llung betroffen.",
	mcplayeryouend = "Wahre Erf\195\188llung\' schwindet von Euch.",
	mcplayerotherend = "Wahre Erf\195\188llung schwindet von (.*).",
	mcplayer_message = "Ihr seid von Wahre Erf\195\188llung betroffen.",
	mcplayerother_message = "%s steht unter Gedankenkontrolle!",
	mindcontrol_bar = "GK: %s",
	deathyou_trigger = "Du stirbst.",
	deathother_trigger = "(.*) stirbt.",
	splitsoon_message = "Abbilder bald! Sei bereit!",
	split_message = "Abbilder!",
	kill_trigger = "You only delay",

	cmd = "Skeram",

	mc_cmd = "mc",
	mc_name = "Gedankenkontrolle",
	mc_desc = "Warnen, wenn jemand \195\188bernommen ist",

	split_cmd = "split",
	split_name = "Abbilder",
	split_desc = "Alarm vor der Aufteilung",
	["You have slain %s!"] = "Ihr habt %s getötet!",
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20006
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "bosskill"}

-- locals
local timer = {
	mc = 20,
}
local icon = {
	mc = "Spell_Shadow_Charm",
}
local syncName = {
	mc = "SkeramMC"..module.revision,
	mcOver = "SkeramMCEnd"..module.revision,
}




------------------------------
--      Initialization      --
------------------------------

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:ThrottleSync(1, syncName.mc)
	self:ThrottleSync(1, syncName.mcOver)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end



------------------------------
--      Event Handlers      --
------------------------------


function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("target") and UnitAffectingCombat("target") then
				local target = UnitName("target")
				for _, mob in pairs(t) do
					if target == mob then
						return true
					end
				end
			end

			local num = GetNumRaidMembers()
			for i = 1, num do
				local raidUnit = string.format("raid%starget", i)
				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
					local target = UnitName(raidUnit)
					for _, mob in pairs(t) do
						if target == mob then
							return true
						end
					end
				end
			end
			return false
		end

		if not IsBossInCombat() then
			self:SendBossDeathSync()
		end
	end
end

function module:Event(msg)
	local _,_, mindcontrolother, mctype = string.find(msg, L["mcplayerother"])
	local _,_, mindcontrolotherend, mctype = string.find(msg, L["mcplayerotherend"])
	local _,_, mindcontrolotherdeath,mctype = string.find(msg, L["deathother_trigger"])
	if string.find(msg, L["mcplayer"]) then
		self:Sync(syncName.mc .. " " .. UnitName("player"))
	elseif string.find(msg, L["mcplayeryouend"]) then
		self:Sync(syncName.mcOver .. " " .. UnitName("player"))
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:Sync(syncName.mcOver .. " " .. UnitName("player"))
	elseif mindcontrolother then
		self:Sync(syncName.mc .. " " .. mindcontrolother)
	elseif mindcontrolotherend then
		self:Sync(syncName.mcOver .. " " .. mindcontrolotherend)
	elseif mindcontrolotherdeath then
		self:Sync(syncName.mcOver .. " " .. mindcontrolotherdeath)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["kill_trigger"]) then
		BigWigs:Debug("yell kill trigger")

	end
end

------------------------------
--      Sync Handlers	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mc then
		if self.db.profile.mc then
			if rest == UnitName("player") then
				self:Bar(string.format(L["mindcontrol_bar"], UnitName("player")), timer.mc, icon.mc, true, "White")
				self:Message(L["mcplayer_message"], "Attention")
			else
				self:Bar(string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"), timer.mc, icon.mc, true, "White")
				self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"), function(name, button, extra) TargetByName(extra, true) end, rest)
				self:Message(string.format(L["mcplayerother_message"], rest), "Urgent")
			end
		end
	elseif sync == syncName.mcOver then
		if self.db.profile.mc then
			self:RemoveBar(string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"))
		end
	end
end

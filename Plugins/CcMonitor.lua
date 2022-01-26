
BigWigsCcMonitor = BigWigs:NewModule("CcMonitor")
BigWigsCcMonitor.revision = 20053
BigWigsCcMonitor.external = true
BigWigsCcMonitor.consoleCmd = "CcMonitor"

local L = AceLibrary("AceLocale-2.2"):new("BigWigsCcMonitor")

--[[
/script SendAddonMessage("BigWigs"," Banish R1", "RAID");
/cast Banish(Rank 1)

/script SendAddonMessage("BigWigs"," Banish R2", "RAID");
/cast Banish(Rank 2)


/script SendAddonMessage("BigWigs"," Sheep R1", "RAID");
/cast Polymorph(Rank 1)

/script SendAddonMessage("BigWigs"," Sheep R2", "RAID");
/cast Polymorph(Rank 2)

/script SendAddonMessage("BigWigs"," Sheep R3", "RAID");
/cast Polymorph(Rank 3)

/script SendAddonMessage("BigWigs"," Sheep R4", "RAID");
/cast Polymorph(Rank 4)

/script SendAddonMessage("BigWigs"," Sheep R4", "RAID");
/cast Polymorph(Turtle)

/script SendAddonMessage("BigWigs"," Sheep R4", "RAID");
/cast Polymorph(Pig)


/script SendAddonMessage("BigWigs"," Shackle R1", "RAID");
/cast Shackle Undead(Rank 1)

/script SendAddonMessage("BigWigs"," Shackle R2", "RAID");
/cast Shackle Undead(Rank 2)

/script SendAddonMessage("BigWigs"," Shackle R3", "RAID");
/cast Shackle Undead(Rank 3)
]]--

L:RegisterTranslations("enUS", function() return {
	["CcMonitor"] = true,
	["Options for the CcMonitor module."] = true,
	["Toggle CC bars on or off."] = true,
	["Bars"] = true,

	banish_trigger = "(.*) Banish (.*)",
	sheep_trigger = "(.*) Sheep (.*)",
	shackle_trigger = "(.*) Shackle (.*)",

	banish_bar = " Banish ",
	sheep_bar = " Sheep ",
	shackle_bar = " Shackle ",
} end)

BigWigsCcMonitor.defaults = {
	bars = true,
}

BigWigsCcMonitor.consoleOptions = {
	type = "group",
	name = L["CcMonitor"],
	desc = L["Options for the CcMonitor module."],
	args = {
		[L["Bars"]] = {
			type = "toggle",
			name = L["Bars"],
			desc = L["Toggle CC bars on or off."],
			get = function() return BigWigsCcMonitor.db.profile.bars end,
			set = function(v)
				BigWigsCcMonitor.db.profile.bars = v
			end,
		},
	}
}

local icon = {
	banish = "spell_shadow_cripple",
	sheep = "spell_nature_polymorph",
	shackle = "spell_nature_slow",
}

local timer = {--sync time seems to be about 0.7 sec
	banishR2 = 31.3,
	banishR1 = 21.3,
	
	sheepR4 = 51.3,
	sheepR3 = 41.3,
	sheepR2 = 31.3,
	sheepR1 = 21.3,
	
	shackleR3 = 51.3,
	shackleR2 = 41.3,
	shackleR1 = 31.3,
}

function BigWigsCcMonitor:OnEnable()
	self:RegisterEvent("CHAT_MSG_ADDON", "Event")
	
	self:RegisterEvent("BigWigs_RecvSync")
	
	self:RegisterEvent("BigWigs_ccMonitor_BanishR1")
	self:RegisterEvent("BigWigs_ccMonitor_BanishR2")
	self:RegisterEvent("BigWigs_ccMonitor_SheepR1")
	self:RegisterEvent("BigWigs_ccMonitor_SheepR2")
	self:RegisterEvent("BigWigs_ccMonitor_SheepR3")
	self:RegisterEvent("BigWigs_ccMonitor_SheepR4")
	self:RegisterEvent("BigWigs_ccMonitor_ShackleR1")
	self:RegisterEvent("BigWigs_ccMonitor_ShackleR2")
	self:RegisterEvent("BigWigs_ccMonitor_ShackleR3")
end

function BigWigsCcMonitor:OnSetup()
end

function BigWigsCcMonitor:Event(prefix,text,target,author)
	if prefix == "BigWigs" and author == UnitName("player") then
		if string.find(text, L["banish_trigger"]) then
			if UnitIsEnemy("player","target") and not UnitIsDead("target") and UnitCreatureType("target") == "Elemental" then
				if GetRaidTargetIndex("target") == nil then
					tarIcon = UnitName("target")
				else 
					tarIcon = GetRaidTargetIndex("target")
				end
				local _,_,_,rank = string.find(text, L["banish_trigger"])
				if rank == "R1" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorBanishR1".." "..tarIcon)
				end
				if rank == "R2" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorBanishR2".." "..tarIcon)
				end
			end
		end
		if string.find(text, L["sheep_trigger"]) then
			if UnitIsEnemy("player","target") and not UnitIsDead("target") and UnitCreatureType("target") == "Humanoid" or UnitCreatureType("target") == "Beast" or UnitCreatureType("target") == "Critter" then
				if GetRaidTargetIndex("target") == nil then
					tarIcon = UnitName("target")
				else 
					tarIcon = GetRaidTargetIndex("target")
				end
				local _,_,_,rank = string.find(text, L["sheep_trigger"])
				if rank == "R1" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorSheepR1".." "..tarIcon)
				end
				if rank == "R2" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorSheepR2".." "..tarIcon)
				end
				if rank == "R3" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorSheepR3".." "..tarIcon)
				end
				if rank == "R4" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorSheepR4".." "..tarIcon)
				end
			end
		end
		if string.find(text, L["shackle_trigger"]) then
			if UnitIsEnemy("player","target") and not UnitIsDead("target") and UnitCreatureType("target") == "Undead" then
				if GetRaidTargetIndex("target") == nil then
					tarIcon = UnitName("target")
				else 
					tarIcon = GetRaidTargetIndex("target")
				end
				local _,_,_,rank = string.find(text, L["shackle_trigger"])
				if rank == "R1" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorShackleR1".." "..tarIcon)
				end
				if rank == "R2" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorShackleR2".." "..tarIcon)
				end
				if rank == "R3" then
					self:TriggerEvent("BigWigs_SendSync", "ccMonitorShackleR3".." "..tarIcon)
				end
			end
		end
	end
end

function BigWigsCcMonitor:BigWigs_RecvSync(sync, tarIcon, nick)
	if self.db.profile.bars then
		theIconNum=tonumber(tarIcon)
		if theIconNum == nil then
			ccTarget = tostring(tarIcon)
		elseif theIconNum >= 0 then
			if theIconNum == 1 then ccTarget = "Star" end
			if theIconNum == 2 then ccTarget = "Circle" end
			if theIconNum == 3 then ccTarget = "Diamond" end
			if theIconNum == 4 then ccTarget = "Triangle" end
			if theIconNum == 5 then ccTarget = "Moon" end
			if theIconNum == 6 then ccTarget = "Square" end
			if theIconNum == 7 then ccTarget = "X" end
			if theIconNum == 8 then ccTarget = "Skull" end
		end
		
		if sync == "ccMonitorBanishR1" then
			self:TriggerEvent("BigWigs_ccMonitor_BanishR1", nick, ccTarget)
		end
		if sync == "ccMonitorBanishR2" then
			self:TriggerEvent("BigWigs_ccMonitor_BanishR2", nick, ccTarget)
		end
		if sync == "ccMonitorSheepR1" then
			self:TriggerEvent("BigWigs_ccMonitor_SheepR1", nick, ccTarget)
		end
		if sync == "ccMonitorSheepR2" then
			self:TriggerEvent("BigWigs_ccMonitor_SheepR2", nick, ccTarget)
		end
		if sync == "ccMonitorSheepR3" then
			self:TriggerEvent("BigWigs_ccMonitor_SheepR3", nick, ccTarget)
		end
		if sync == "ccMonitorSheepR4" then
			self:TriggerEvent("BigWigs_ccMonitor_SheepR4", nick, ccTarget)
		end
		if sync == "ccMonitorShackleR1" then
			self:TriggerEvent("BigWigs_ccMonitor_ShackleR1", nick, ccTarget)
		end
		if sync == "ccMonitorShackleR2" then
			self:TriggerEvent("BigWigs_ccMonitor_ShackleR2", nick, ccTarget)
		end
		if sync == "ccMonitorShackleR3" then
			self:TriggerEvent("BigWigs_ccMonitor_ShackleR3", nick, ccTarget)
		end
	end
end

function BigWigsCcMonitor:BigWigs_ccMonitor_BanishR1(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["banish_bar"]), timer.banishR1, icon.banish)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_BanishR2(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["banish_bar"]), timer.banishR2, icon.banish)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_SheepR1(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["sheep_bar"]), timer.sheepR1, icon.sheep)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_SheepR2(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["sheep_bar"]), timer.sheepR2, icon.sheep)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_SheepR3(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["sheep_bar"]), timer.sheepR3, icon.sheep)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_SheepR4(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["sheep_bar"]), timer.sheepR4, icon.sheep)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_ShackleR1(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["shackle_bar"]), timer.shackleR1, icon.shackle)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_ShackleR2(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["shackle_bar"]), timer.shackleR2, icon.shackle)
end

function BigWigsCcMonitor:BigWigs_ccMonitor_ShackleR3(nick, tarIcon)
	self:Bar(string.format(nick .. " " .. ccTarget .. L["shackle_bar"]), timer.shackleR3, icon.shackle)
end

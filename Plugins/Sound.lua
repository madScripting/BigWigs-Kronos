
assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsSound")
--~~ local dewdrop = DewdropLib:GetInstance("1.0")

local sounds = {
	Long = "Interface\\AddOns\\BigWigs\\Sounds\\Long.mp3",
	Info = "Interface\\AddOns\\BigWigs\\Sounds\\Info.ogg",
	Alert = "Interface\\AddOns\\BigWigs\\Sounds\\Alert.mp3",
	Alarm = "Interface\\AddOns\\BigWigs\\Sounds\\Alarm.mp3",
	Victory = "Interface\\AddOns\\BigWigs\\Sounds\\Victory.mp3",
	
	Beep = "Interface\\AddOns\\BigWigs\\Sounds\\beep.mp3",
	Beware = "Interface\\AddOns\\BigWigs\\Sounds\\Beware.wav",
	RunAway = "Interface\\AddOns\\BigWigs\\Sounds\\RunAway.wav",

	One = "Interface\\AddOns\\BigWigs\\Sounds\\1.ogg",
	Two = "Interface\\AddOns\\BigWigs\\Sounds\\2.ogg",
	Three = "Interface\\AddOns\\BigWigs\\Sounds\\3.ogg",
	Four = "Interface\\AddOns\\BigWigs\\Sounds\\4.ogg",
	Five = "Interface\\AddOns\\BigWigs\\Sounds\\5.ogg",
	Six = "Interface\\AddOns\\BigWigs\\Sounds\\6.ogg",
	Seven = "Interface\\AddOns\\BigWigs\\Sounds\\7.ogg",
	Eight = "Interface\\AddOns\\BigWigs\\Sounds\\8.ogg",
	Nine = "Interface\\AddOns\\BigWigs\\Sounds\\9.ogg",
	Ten = "Interface\\AddOns\\BigWigs\\Sounds\\10.ogg",

	Murloc = "Sound\\Creature\\Murloc\\mMurlocAggroOld.wav",
	Pain = "Sound\\Creature\\Thaddius\\THAD_NAXX_ELECT.wav",
	
	stopcasting = "Interface\\AddOns\\BigWigs\\Sounds\\stopcasting.mp3",
	gogogo = "Interface\\AddOns\\BigWigs\\Sounds\\gogogo.mp3",
	dontlootgetaway = "Interface\\AddOns\\BigWigs\\Sounds\\dontlootgetaway.mp3",
	hide = "Interface\\AddOns\\BigWigs\\Sounds\\hide.mp3",
	meleeout = "Interface\\AddOns\\BigWigs\\Sounds\\meleeout.mp3",
	fire = "Interface\\AddOns\\BigWigs\\Sounds\\fire.mp3",
	stacks = "Interface\\AddOns\\BigWigs\\Sounds\\stacks.mp3",
	shieldwall = "Interface\\AddOns\\BigWigs\\Sounds\\shieldwall.mp3",
	laststand = "Interface\\AddOns\\BigWigs\\Sounds\\laststand.mp3",
	twentythree = "Interface\\AddOns\\BigWigs\\Sounds\\23.mp3",
	twentytwo = "Interface\\AddOns\\BigWigs\\Sounds\\22.mp3",
	twentyone = "Interface\\AddOns\\BigWigs\\Sounds\\21.mp3",
	incoming = "Interface\\AddOns\\BigWigs\\Sounds\\incoming.mp3",
}


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Sounds"] = true,
	["sounds"] = true,
	["Options for sounds."] = true,

	["toggle"] = true,
	["Use sounds"] = true,
	["Toggle sounds on or off."] = true,
	["default"] = true,
	["Default only"] = true,
	["Use only the default sound."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Sounds"] = "효과음",
	["Options for sounds."] = "효과음 옵션.",

	["Use sounds"] = "효과음 사용",
	["Toggle sounds on or off."] = "효과음을 켜거나 끔.",
	["Default only"] = "기본음",
	["Use only the default sound."] = "기본음만 사용.",
} end)

L:RegisterTranslations("deDE", function() return {
	["Sounds"] = "Sound",
	["Options for sounds."] = "Optionen f\195\188r Sound.",
	["Use sounds"] = "Sound nutzen",
	["Toggle sounds on or off."] = "Sound aktivieren/deaktivieren.",
	["Default only"] = "Nur Standard",
	["Use only the default sound."] = "Nur Standard Sound.",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSound = BigWigs:NewModule(L["Sounds"])
BigWigsSound.defaults = {
	defaultonly = false,
	sound = true,
}
BigWigsSound.consoleCmd = L["sounds"]
BigWigsSound.consoleOptions = {
	type = "group",
	name = L["Sounds"],
	desc = L["Options for sounds."],
	args = {
		[L["toggle"]] = {
			type = "toggle",
			name = L["Sounds"],
			desc = L["Toggle sounds on or off."],
			get = function() return BigWigsSound.db.profile.sound end,
			set = function(v)
				BigWigsSound.db.profile.sound = v
				BigWigs:ToggleModuleActive(L["Sounds"], v)
			end,
		},
		[L["default"]] = {
			type = "toggle",
			name = L["Default only"],
			desc = L["Use only the default sound."],
			get = function() return BigWigsSound.db.profile.defaultonly end,
			set = function(v) BigWigsSound.db.profile.defaultonly = v end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsSound:OnEnable()
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("BigWigs_Sound")
end
function BigWigsSound:OnDisable()
	BigWigs:DebugMessage("OnDisable")
end

function BigWigsSound:BigWigs_Message(text, color, noraidsay, sound, broadcastonly)
	if self.db.profile.sound then
		if not text or sound == false or broadcastonly then return end

		if sounds[sound] and not self.db.profile.defaultonly then PlaySoundFile(sounds[sound])
		else PlaySound("RaidWarning") end
	end
end

function BigWigsSound:BigWigs_Sound( sound )
	if self.db.profile.sound then
		if sounds[sound] and not self.db.profile.defaultonly then
			PlaySoundFile(sounds[sound])
		else
			PlaySound("RaidWarning")
		end
	end
end

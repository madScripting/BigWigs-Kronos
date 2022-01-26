# BigWigs
BigWigs is a World of Warcraft AddOn to predict certain AI behaviour to improve the players performance.<br>
This Modification is built for Patch 1.12.1 and its content for use on the <b>Kronos 4</b> private Server.

## How to install
Either clone the repository to your WoW/Interface/Addons folder, or download manually via github (click on Clone or Download -> Download ZIP. Do not forget to rename the directory to "BigWigs" afterwards.

## Contributing
If you would like to contribute, just open a pull request.

## Language support
Currently, only english clients are supported. In general, the Addon can work with other languages, but this support is only provided on a best-effort basis. It is much effort to support those languages. Feel free to contribute if you would like to have support for other languages.

## License
The adjustments were originally made by <a href="https://github.com/MOUZU"><b>LYQ</b></a> and <a href="https://github.com/xorann/BigWigs"><b>Dorann</b></a><br>
Adjustments for Elysium made by <b>Hosq</b>.<br>
Adjustments for Kronos made by <b>Vnm</b>.<br>
Special thanks to <b>Masil</b> for Kronos adjustments.

Latest adjustments for Kronos 3 and 4 made by <a href="https://github.com/madScripting"><b>Relar</b></a><br>

## Revisions
30001	Final K4 Pre-BWL release<br>
20061<br>
	Drakkisath			Overhaul of the adds counter and conflag timer after broad testing<br>
	WorldBuffs			Changed delivery method, from BigWigs_sync to SendAddonMessage for maximum "contamination"<br>
	LoadOnDemand		Added Orgrimmar and STV in the auto-enable bigwigs for maximum worldbuffs "contamination"<br>
20060<br>
	MC - Golemagg		Fixed the EAT EAT to happen only once
	WorldBuffs			Attempt to fix sync
20059
	Battlegrounds		Fixed WSG FC bars
						Added resurrection bars for WSG and all AB points
						Added missing AB timers
	Kromcrush			Fixed enable trigger
						Fixed bigIcons based on class
						Fixed caps/typos
						Added KTM auto-master target
	Gordok				Moved module to DireMaul
						Added KTM auto-master target
						Adjusted timers
	Onyxia				Added a knockAway when she lands from P2
						Added the WorldBuffs module
	BigWigs				Changed twitch link to GitHub link
	BigWigs - Readme	Put the whole changelog into the readme
	WorldBuffs			Added the new WorldBuffs module
	LoadOnDemand		Added a load-core function when you enter DireMaul to make Kromcrush and Gordok auto-activate
	MC - Golemagg		Added a warning to eat when he dies
	MC - Multiple		Made KTM auto-master target on all bosses with multiple adds
	Drakkisath			Added KTM auto-master target
20058	Testing version
20057	Testing version
20056
	Battlegrounds		Added the new Battlegrounds module (unfinished)
	Ony					Added a /say when you are targetted by Ony
						Fixed a missing sync name
						Fixed P2 knockAway timers
						Improved ony raid target marking to make it more consistent
	DM-N				Added Captain Kromcrush module (untested)
20055
	Ony					Adjusted the KnockAway timer, overhaul of KnockAway functionality
						Added auto-master target for Onyxia
20054
	Drakkisath			Added the Drakkisath module (partially tested)
	Ony					Changed Wing Buffet tracking for Knock Away (buffed just pushed back, knock away reduced threat) (partially tested)
							Knock Away times aren't set properly
						Fixed DeepBreath triggers
						Added Ony's target warning (untested)
	CcMonitor			Adjusted (+2sec) the timers to pad for syncs delay
						Tightened restrictions to fire the bars (UnitCreatureType) (untested)
	MC - Gheddon		Adjusted Mana Ignite timer
20053
	CcMonitor			Added the new CcMonitor plugin
20052	(K4)
	MC - Ragnaros		Fixed sons death count
	MC - Gheddon		Adjusted Inferno timer for 2nd and up casts (-7seconds)
	MC - Shazzrah		Adjusted Deaden timer (static 8seconds)
	MC - Domo			Added melee dmg shield warning icon
						Attempt to adjust the adds death count (seems they don't show in combat log that they die half the time...)
20051	(K3 Final)
	Naxx - Sapphiron	Added many bars and warnings
	Naxx - Kel'Thuzad	Deleted the useless volley bar
						Fixed the kick warning
						Added clickable MC bars for all MCs
						Fixed Auto-MasterTarget
20050
	ZG - Gahz'ranka		Changed bars colors
	Naxx - DkCaptain	Fixed the timers and prevented an error if the module would reset / not start on pull
						Fixed bars resetting when 1 captain dies
	Naxx - SewageSlime	Added 120sec, 60sec and 30sec messages since the bar disappears on disengages
	Naxx - Razuvious	Mind Exhaustion seems to be 60sec instead of 45sec; fixed timer.
	Naxx - Gothik		Confirmed sideSwitch timer (gate open seems to be linked to hp @ timer end)
	Naxx				Deleted the Farclip Plugin as it was causing issue
						set higher default values on the Range plugin for the combat log
20049
	Naxx - Thaddius		Fixed Magnetic Pull trigger
	Naxx - Horsemen		Changed the VoidZone icon to something more appropriate
						Fixed Meteor Trigger
						Hiding VoidZone and HolyWrath timers and warnings unless targetting those horsemen or someone targetting those horsemen
	Naxx - Razuvious	Added MC-Immune timers
	Naxx - Gothik		Added side-switching and gate opening timers (now need the actual time for those timers, set at 45 seconds for now.)
	Naxx - DkCaptain	Added the new DkCaptain module
						Now announces whirlwinds
20048
	Naxx				Overhaul of all Naxxramas modules
						Adjusted all timers, icons, colors
						Added tons of timers, triggers, warnings
	Naxx - SewageSlime	Added the new SewageSlimes module
20047
	Onyxya				Adjusted Timers
	AQ40 - Ouro			Removed the KTM self threat reset; now handled by KTM
	AQ40 - Huhuran		Changed bar colors for clarity
	AQ40 - Frankriss	Added wound and taunt warnings - module overhaul
	AQ40 - Defenders	Added reflection warnings
	AQ20 - Guardians	Added reflection warnings
	Ignite				Probably fixed an rare error with the module; undefined igniteStack var, now predefined as default to 1
	Versions			Changed location for latest BigWigs to Twitch page.
20046
	DM-N - King Gordok	New timers for King Gordok in DM-N
	Ignite				Added new Ignite module
	AQ20 - Ossirian		Fixed possible supreme timers math
	Tranq				Changed Firemaw, Flamegor, Ebonroc, Chromagg, Geddon, Shazz, Rag, AQ40-Champion, AQ40-MindSlayer, Tranq bar colors
	MC - Gheddon		Added delays to Geddon timers, disabled overlaps, adjusted firstInferno timer
	Onyxia				Overhaul of Onyxia module
	AQ40 - Champion		Added detection for self-immune to fear
20045
	AQ40 - C'Thun		Tied DarkGlare timers to the first cast of GreenBeam, should be 100% accurate.
						Tied RandomBeam timer to the first cast of GreenBeam, should be 100% accurate.
						Tied DarkGlare refresh timers to the first GreenBeam after Glare, should be 100% accurate.
	AQ40 - Ouro			Fixed an oversight with the Berserk detection.
20044
	AQ20 - Ossirian		Fixed "possible supreme" timer (added the 5seconds for crystal "loading" time)
	ZG - Gahz'ranka		Fixed an error with frost breath bar (wrong localization)
	ZG - Arlokk			Fixed whirlwind sync (forgot to define)
	AQ40 - Champion		Added triggers for fear resist and immune. Timers should pop on every cooldown now.
	AQ40 - Warder		Changed bar colors and text.
	AQ40 - C'Thun		Tightened timers of Dark Glare, deleted a useless check for GNPP.
	AQ40 - Ouro			Fixed SandBlast threat reset when the spin is resisted. Requires KTM 69.06 or above
20043
	BWL - Nefarian		Added FearSoon bar. Changed bar colors.
	AQ40 - Ouro			Added sounds and bigIcons. Changed bar colors and icons.
	ZG - Arlokk			Added gouge bar
	ZG - Jin'do			Improved bars
	ZG - Hakkar			Improved bars and warnings
	ZG - Mandokir		Improved bars
	ZG - Ghaz'ranka		Improved bars
	ZG - Jeklik			Changed bar colors
	ZG - Venoxis		Fixed holyfire bar and warning to account for cast time
	AQ40 - C'Thun		Changed bar colors
	AQ20 - Ayamiss		Edited larva timer, fixed sacrifice end cancelbar.
	AQ20 - Kurinnaxx	Fixed enrage trigger
	AQ20 - Ossirian		Added timer for first crystal
	BWL - Ebonroc		Added masterTarget on engage, should fix threat
	BWL - Razorgore		Reenabled the castbar now that the counter and P2trigger works.
20042
	AQ20 - Kurinnaxx	Added a toggle for the sand trap bars
	ZG					Overhaul of all ZG bosses.
	BWL - Chromaggus	Fixed an error on Chromaggus Time Lapse.
20041
	BigWigs - Raids		Added A LOT of togglable options
	WarningSign			Shortened the bigIcons timers by default (by popular demand)
	BigWigs				Rewrote most modules to fit the proper format
	AQ20 - Ossirian		Now has a "possible supreme" timer instead of no timers when hit by the same vulnerability
	AQ20 - Kurinnaxx	Fixed enrage warning error
	ZG - Hakkar			Now warns priests to dispell after MC.
	BWL - Nefarian		Fixed an error preventing P2 timers from happenning (woops!)
20036
	AQ40 - C'Thun		Edited timers, Added GNPP warning, Added run in, Changed timer colors, Added Window of Opprtunity
	AQ40 - Ouro			Master target and KTM reset
	AQ40 - Viscidus		Master target and KTM reset and enabled poison bolt timers
	AQ40 - Sentinels	Prevented reset of the module during combat
	AQ40 - Defenders	Fixed a missing icon
	AQ20 - Kurinnaxx	Did whole module
	AQ20 - Flesh Hunter	Created module
	AQ20 - Buru			Master target, fixed icon, added dismember, added P2
	AQ20 - Ayamiss		Did whole module
	AQ20 - Moam			Added mana bar
	AQ20 - Guardians	Added 1-2groups warning, revamped explode warning
	ZG - TigerBoss		Added Kill/Don't kill warnings
20035
	BigWigs - Raids		Added many warningIcons and Sounds to many encounters
	MC - Lucifron		Enhanced Lucifron MC
	MC - Ragnaros		Enhanced Ragnaros knockbacks
	MC - Domo			Enhanced Domo magic reflects
	MC - Golemagg		Enhanced Golemagg stacks and earthquake
	MC - Shazz			Enhanced Shazz counterspell
	MC - Garr			Enhanced Garr banishes
	MC - Geddon			Enhanced Geddon inferno and bomb
						Fixed Inferno timers after 1st one.
	MC - Magmadar		Enhanced Magmadar fire on the ground
	ZG - Hakkar			Enhanced Hakkar MC
	BWL - Firemaw		Enhanced Firemaw WingBuffet and FlameBuffet
	BWL - Nefarian		Enhanced Nefarian MC and 20-23% section (complete overhaul of MC section)
	BWL - Chromaggus	Enhanced Chromaggus hide @ 10 seconds and Bronze warning
	BWL - Flamegor		Enhanced Flamegor WingBuffet
	BWL - Ebonroc		Enhanced Ebonroc WingBuffet and Shadow of Ebonroc
	BWL - Broodlord		Enhanced Broodlord blastwaveEnd warning and dontlootmoveAway
	BWL - Vaelstrasz	Enhanced Vaelstrasz warning for tanks
	-
	AQ40 - Skeram		Enhanced Skeram MC
	AQ40 - Sentinels	Enhanced Sentinels announcements and killorder
	AQ40 - Defenders	Enhanced Defenders, fixed infinite messages, added sounds on explosion and plague
	AQ40 - Champion		Added the new Champion module for fears
	AQ40 - Mindslayer	Added the new Mindslayer module for MC and fear
20034
	AQ40 - Sartura		Edited Knockback! text and timer (from 10sec to 8sec Cooldown based)
	AQ40 - Viscidus		Cleaned a lot unneeded announces.
						Added bars for DPS time.
						Added run in calls, poke call, group sides to go to, run out call.
	AQ40 - TwinEmps		Edited Teleport to 26 seconds, cooldown based, starts a 10sec timer after 26seconds, clears both timers on teleport and announces teleport and restarts 26 seconds timer.
	MC - Shazzrah		Fixed the Priest and Shaman icon error
	MC - Geddon			Fixed bomb icon and getting icon off after bomb went off
	BWL - Vael			Fixed Burning Adrenaline icon
	AQ40 - Defenders	Fixed Plague icon
	AQ40 - Sentinels	Added the new Sentinel module
	AQ40 - Versions.lua	Changed github link on outdated version for Discord #addons
20033
	BWL - Razorgore		Fixed Razorgore so it doesn't reset mid fight.(will have to force reset with ctrl-click on wipe)
	BWL - CommonAuras	Went back to old version of CommonAuras, should fix random error on zeppelin crash
20032
	MC - Gehennas		Fixed Gehennas for real, BethyServer tested
	MC - Geddon			Fixed Baron Geddon inferno trigger, BethyServer tested. Need to confirm the trigger on Kronos.
	MC - Shazzrah		Fixed Shazzrah CS, Curse, BethyServer tested. Need to confirm triggers on Kronos
20031 
	MC - Gehennas		Fixed Gehennas	One "earliestCurse" was remaining, replaced with nextCurse.
						Confirmed no occurence of "earliestCurse" or "latestCurse" remain.
	MC - Geddon			Attempted to fix Baron Geddon. Only the first inferno timer happens. Changed ThrottleSync (line 196) to 15, as it was over the actual inferno timer.
						Deleted deletion of bar (since CD bar should always be done) and edited inferno sync and timer to what i think it should be.
						Fixed a typo in the bomb section, let's see how that goes...
						Shortened LivingBomb CD as per data.
						Adjusted nextIgnite CD as per data.
20030
	Relar BigWigs		Release of Relar version.
						Adjusted all timers that seemed off.
						Disabled icon placement on C'thun's fight (line 556), ppl can now enable icon placement risk-free.
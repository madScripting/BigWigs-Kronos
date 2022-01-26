# BigWigs
BigWigs is a World of Warcraft AddOn to predict certain AI behaviour to improve the players performance.<br>
This Modification is built for Patch 1.12.1 and its content for use on the <b>Kronos 4</b> private Server.

## How to install
Either clone the repository to your WoW/Interface/Addons folder, or download manually via github (click on Clone or Download -> Download ZIP. Do not forget to rename the directory to "BigWigs" afterwards.

## New modules
If you already had a previous version of BigWigs, some new modules may not be enabled by default.<br>
Here is  an example of how to enable them:<br>
RightClick BigWigs on your minimap -> Bosses -> Outdoor Raid Bosses -> General Drakkisath -> Check everything.<br>
RightClick BigWigs on your minimap -> Bosses -> Outdoor Raid Bosses -> Captain Kromcrush -> Check everything.<br>
RightClick BigWigs on your minimap -> Extras -> Battlegrounds -> Check everything.<br>
RightClick BigWigs on your minimap -> Extras -> CcMonitor -> Check everything.<br>
RightClick BigWigs on your minimap -> Extras -> WorldBuffs -> Check everything.

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
<b>30001</b>	Final K4 Pre-BWL release<br>
	Readme---				Edited for readability on GitHub<br>
	
<b>20061</b><br>
	Drakkisath---			Overhaul of the adds counter and conflag timer after broad testing<br>
	WorldBuffs---			Changed delivery method, from BigWigs_sync to SendAddonMessage for maximum "contamination"<br>
	LoadOnDemand---			Added Orgrimmar and STV in the auto-enable bigwigs for maximum worldbuffs "contamination"<br>

<b>20060</b><br>
	MC - Golemagg---		Fixed the EAT EAT to happen only once<br>
	WorldBuffs---			Attempt to fix sync<br>

<b>20059</b><br>
	Battlegrounds---		Fixed WSG FC bars<br>
	---	---					Added resurrection bars for WSG and all AB points<br>
	---	---					Added missing AB timers<br>
	Kromcrush---			Fixed enable trigger<br>
	---	---					Fixed bigIcons based on class<br>
	---	---					Fixed caps/typos<br>
	---	---					Added KTM auto-master target<br>
	Gordok---				Moved module to DireMaul<br>
	---	---					Added KTM auto-master target<br>
	---	---					Adjusted timers<br>
	Onyxia---				Added a knockAway when she lands from P2<br>
	---	---					Added the WorldBuffs module<br>
	BigWigs---				Changed twitch link to GitHub link<br>
	BigWigs - Readme---		Put the whole changelog into the readme<br>
	WorldBuffs---			Added the new WorldBuffs module<br>
	LoadOnDemand---			Added a load-core function when you enter DireMaul to make Kromcrush and Gordok auto-activate<br>
	MC - Golemagg---		Added a warning to eat when he dies<br>
	MC - Multiple---		Made KTM auto-master target on all bosses with multiple adds<br>
	Drakkisath---			Added KTM auto-master target<br>

<b>20058</b>	Testing version<br>

<b>20057</b>	Testing version<br>

<b>20056</b><br>
	Battlegrounds---		Added the new Battlegrounds module (unfinished)<br>
	Ony---					Added a /say when you are targetted by Ony<br>
	---	---					Fixed a missing sync name<br>
	---	---					Fixed P2 knockAway timers<br>
	---	---					Improved ony raid target marking to make it more consistent<br>
	DM-N---					Added Captain Kromcrush module (untested)<br>

<b>20055</b><br>
	Ony---					Adjusted the KnockAway timer, overhaul of KnockAway functionality<br>
	---	---					Added auto-master target for Onyxia<br>
	
<b>20054</b><br>
	Drakkisath---			Added the Drakkisath module (partially tested)<br>
	Ony---					Changed Wing Buffet tracking for Knock Away (buffed just pushed back, knock away reduced threat) (partially tested)<br>
	---	---					Knock Away times aren't set properly<br>
	---	---					Fixed DeepBreath triggers<br>
	---	---					Added Ony's target warning (untested)<br>
	CcMonitor---			Adjusted (+2sec) the timers to pad for syncs delay<br>
	---	---					Tightened restrictions to fire the bars (UnitCreatureType) (untested)<br>
	MC - Gheddon---			Adjusted Mana Ignite timer<br>

<b>20053</b><br>
	CcMonitor---			Added the new CcMonitor plugin<br>

<b>20052</b>	(K4)<br>
	MC - Ragnaros---		Fixed sons death count<br>
	MC - Gheddon---			Adjusted Inferno timer for 2nd and up casts (-7seconds)<br>
	MC - Shazzrah---		Adjusted Deaden timer (static 8seconds)<br>
	MC - Domo---			Added melee dmg shield warning icon<br>
	---	---					Attempt to adjust the adds death count (seems they don't show in combat log that they die half the time...)<br>

<b>20051</b>	(K3 Final)<br>
	Naxx - Sapphiron---		Added many bars and warnings<br>
	Naxx - Kel'Thuzad---	Deleted the useless volley bar<br>
	---	---					Fixed the kick warning<br>
	---	---					Added clickable MC bars for all MCs<br>
	---	---					Fixed Auto-MasterTarget<br>

<b>20050</b><br>
	ZG - Gahz'ranka---		Changed bars colors<br>
	Naxx - DkCaptain---		Fixed the timers and prevented an error if the module would reset / not start on pull<br>
	---	---					Fixed bars resetting when 1 captain dies<br>
	Naxx - SewageSlime---	Added 120sec, 60sec and 30sec messages since the bar disappears on disengages<br>
	Naxx - Razuvious---		Mind Exhaustion seems to be 60sec instead of 45sec; fixed timer.<br>
	Naxx - Gothik---		Confirmed sideSwitch timer (gate open seems to be linked to hp @ timer end)<br>
	Naxx---					Deleted the Farclip Plugin as it was causing issue<br>
	---	---					set higher default values on the Range plugin for the combat log<br>

<b>20049</b><br>
	Naxx - Thaddius---		Fixed Magnetic Pull trigger<br>
	Naxx - Horsemen---		Changed the VoidZone icon to something more appropriate<br>
	---	---					Fixed Meteor Trigger<br>
	---	---					Hiding VoidZone and HolyWrath timers and warnings unless targetting those horsemen or someone targetting those horsemen<br>
	Naxx - Razuvious---		Added MC-Immune timers<br>
	Naxx - Gothik---		Added side-switching and gate opening timers (now need the actual time for those timers, set at 45 seconds for now.)<br>
	Naxx - DkCaptain---		Added the new DkCaptain module<br>
	---	---					Now announces whirlwinds<br>

<b>20048</b><br>
	Naxx---					Overhaul of all Naxxramas modules<br>
	---	---					Adjusted all timers, icons, colors<br>
	---	---					Added tons of timers, triggers, warnings<br>
	Naxx - SewageSlime---	Added the new SewageSlimes module<br>

<b>20047</b><br>
	Onyxya---					Adjusted Timers<br>
	AQ40 - Ouro---				Removed the KTM self threat reset; now handled by KTM<br>
	AQ40 - Huhuran---			Changed bar colors for clarity<br>
	AQ40 - Frankriss---			Added wound and taunt warnings - module overhaul<br>
	AQ40 - Defenders---			Added reflection warnings<br>
	AQ20 - Guardians---			Added reflection warnings<br>
	Ignite---					Probably fixed an rare error with the module; undefined igniteStack var, now predefined as default to 1<br>
	Versions---					Changed location for latest BigWigs to Twitch page.<br>

<b>20046</b><br>
	DM-N - King Gordok---		New timers for King Gordok in DM-N<br>
	Ignite---					Added new Ignite module<br>
	AQ20 - Ossirian---			Fixed possible supreme timers math<br>
	Tranq---					Changed Firemaw, Flamegor, Ebonroc, Chromagg, Geddon, Shazz, Rag, AQ40-Champion, AQ40-MindSlayer, Tranq bar colors<br>
	MC - Gheddon---				Added delays to Geddon timers, disabled overlaps, adjusted firstInferno timer<br>
	Onyxia---					Overhaul of Onyxia module<br>
	AQ40 - Champion---			Added detection for self-immune to fear<br>

<b>20045</b><br>
	AQ40 - C'Thun---			Tied DarkGlare timers to the first cast of GreenBeam, should be 100% accurate.<br>
	---	---						Tied RandomBeam timer to the first cast of GreenBeam, should be 100% accurate.<br>
	---	---						Tied DarkGlare refresh timers to the first GreenBeam after Glare, should be 100% accurate.<br>
	AQ40 - Ouro---				Fixed an oversight with the Berserk detection.<br>

<b>20044</b><br>
	AQ20 - Ossirian---			Fixed "possible supreme" timer (added the 5seconds for crystal "loading" time)<br>
	ZG - Gahz'ranka---			Fixed an error with frost breath bar (wrong localization)<br>
	ZG - Arlokk---				Fixed whirlwind sync (forgot to define)<br>
	AQ40 - Champion---			Added triggers for fear resist and immune. Timers should pop on every cooldown now.<br>
	AQ40 - Warder---			Changed bar colors and text.<br>
	AQ40 - C'Thun---			Tightened timers of Dark Glare, deleted a useless check for GNPP.<br>
	AQ40 - Ouro---				Fixed SandBlast threat reset when the spin is resisted. Requires KTM 69.06 or above<br>

<b>20043</b><br>
	BWL - Nefarian---			Added FearSoon bar. Changed bar colors.<br>
	AQ40 - Ouro---				Added sounds and bigIcons. Changed bar colors and icons.<br>
	ZG - Arlokk---				Added gouge bar<br>
	ZG - Jin'do---				Improved bars<br>
	ZG - Hakkar---				Improved bars and warnings<br>
	ZG - Mandokir---			Improved bars<br>
	ZG - Ghaz'ranka---			Improved bars<br>
	ZG - Jeklik---				Changed bar colors<br>
	ZG - Venoxis---				Fixed holyfire bar and warning to account for cast time<br>
	AQ40 - C'Thun---			Changed bar colors<br>
	AQ20 - Ayamiss---			Edited larva timer, fixed sacrifice end cancelbar.<br>
	AQ20 - Kurinnaxx---			Fixed enrage trigger<br>
	AQ20 - Ossirian---			Added timer for first crystal<br>
	BWL - Ebonroc---			Added masterTarget on engage, should fix threat<br>
	BWL - Razorgore---			Reenabled the castbar now that the counter and P2trigger works.<br>

<b>20042</b><br>
	AQ20 - Kurinnaxx---			Added a toggle for the sand trap bars<br>
	ZG---						Overhaul of all ZG bosses.<br>
	BWL - Chromaggus---			Fixed an error on Chromaggus Time Lapse.<br>

<b>20041</b><br>
	BigWigs - Raids---			Added A LOT of togglable options<br>
	WarningSign---				Shortened the bigIcons timers by default (by popular demand)<br>
	BigWigs---					Rewrote most modules to fit the proper format<br>
	AQ20 - Ossirian---			Now has a "possible supreme" timer instead of no timers when hit by the same vulnerability<br>
	AQ20 - Kurinnaxx---			Fixed enrage warning error<br>
	ZG - Hakkar---				Now warns priests to dispell after MC.<br>
	BWL - Nefarian---			Fixed an error preventing P2 timers from happenning (woops!)<br>

<b>20036</b><br>
	AQ40 - C'Thun---			Edited timers, Added GNPP warning, Added run in, Changed timer colors, Added Window of Opprtunity<br>
	AQ40 - Ouro---				Master target and KTM reset<br>
	AQ40 - Viscidus---			Master target and KTM reset and enabled poison bolt timers<br>
	AQ40 - Sentinels---			Prevented reset of the module during combat<br>
	AQ40 - Defenders---			Fixed a missing icon<br>
	AQ20 - Kurinnaxx---			Did whole module<br>
	AQ20 - Flesh Hunter---		Created module<br>
	AQ20 - Buru---				Master target, fixed icon, added dismember, added P2<br>
	AQ20 - Ayamiss---			Did whole module<br>
	AQ20 - Moam---				Added mana bar<br>
	AQ20 - Guardians---			Added 1-2groups warning, revamped explode warning<br>
	ZG - TigerBoss---			Added Kill/Don't kill warnings<br>

<b>20035</b><br>
	BigWigs - Raids---			Added many warningIcons and Sounds to many encounters<br>
	MC - Lucifron---			Enhanced Lucifron MC<br>
	MC - Ragnaros---			Enhanced Ragnaros knockbacks<br>
	MC - Domo---				Enhanced Domo magic reflects<br>
	MC - Golemagg---			Enhanced Golemagg stacks and earthquake<br>
	MC - Shazz---				Enhanced Shazz counterspell<br>
	MC - Garr---				Enhanced Garr banishes<br>
	MC - Geddon---				Enhanced Geddon inferno and bomb<br>
	---	---						Fixed Inferno timers after 1st one.<br>
	MC - Magmadar---			Enhanced Magmadar fire on the ground<br>
	ZG - Hakkar---				Enhanced Hakkar MC<br>
	BWL - Firemaw---			Enhanced Firemaw WingBuffet and FlameBuffet<br>
	BWL - Nefarian---			Enhanced Nefarian MC and 20-23% section (complete overhaul of MC section)<br>
	BWL - Chromaggus---			Enhanced Chromaggus hide @ 10 seconds and Bronze warning<br>
	BWL - Flamegor---			Enhanced Flamegor WingBuffet<br>
	BWL - Ebonroc---			Enhanced Ebonroc WingBuffet and Shadow of Ebonroc<br>
	BWL - Broodlord---			Enhanced Broodlord blastwaveEnd warning and dontlootmoveAway<br>
	BWL - Vaelstrasz---			Enhanced Vaelstrasz warning for tanks<br>
	AQ40 - Skeram---			Enhanced Skeram MC<br>
	AQ40 - Sentinels---			Enhanced Sentinels announcements and killorder<br>
	AQ40 - Defenders---			Enhanced Defenders, fixed infinite messages, added sounds on explosion and plague<br>
	AQ40 - Champion---			Added the new Champion module for fears<br>
	AQ40 - Mindslayer---		Added the new Mindslayer module for MC and fear<br>

<b>20034</b><br>
	AQ40 - Sartura---			Edited Knockback! text and timer (from 10sec to 8sec Cooldown based)<br>
	AQ40 - Viscidus---			Cleaned a lot unneeded announces.<br>
	---	---						Added bars for DPS time.<br>
	---	---						Added run in calls, poke call, group sides to go to, run out call.<br>
	AQ40 - TwinEmps---			Edited Teleport to 26 seconds, cooldown based, starts a 10sec timer after 26seconds, clears both timers on teleport and announces teleport and restarts 26 seconds timer.<br>
	MC - Shazzrah---			Fixed the Priest and Shaman icon error<br>
	MC - Geddon---				Fixed bomb icon and getting icon off after bomb went off<br>
	BWL - Vael---				Fixed Burning Adrenaline icon<br>
	AQ40 - Defenders---			Fixed Plague icon<br>
	AQ40 - Sentinels---			Added the new Sentinel module<br>
	AQ40 - Versions.lua---		Changed github link on outdated version for Discord #addons<br>

<b>20033</b><br>
	BWL - Razorgore---			Fixed Razorgore so it doesn't reset mid fight.(will have to force reset with ctrl-click on wipe)<br>
	BWL - CommonAuras---		Went back to old version of CommonAuras, should fix random error on zeppelin crash<br>

<b>20032</b><br>
	MC - Gehennas---			Fixed Gehennas for real, BethyServer tested<br>
	MC - Geddon---				Fixed Baron Geddon inferno trigger, BethyServer tested. Need to confirm the trigger on Kronos.<br>
	MC - Shazzrah---			Fixed Shazzrah CS, Curse, BethyServer tested. Need to confirm triggers on Kronos<br>

<b>20031</b><br>
	MC - Gehennas---			Fixed Gehennas	One "earliestCurse" was remaining, replaced with nextCurse.<br>
	---	---						Confirmed no occurence of "earliestCurse" or "latestCurse" remain.<br>
	MC - Geddon---				Attempted to fix Baron Geddon. Only the first inferno timer happens. Changed ThrottleSync (line 196) to 15, as it was over the actual inferno timer.<br>
	---	---						Deleted deletion of bar (since CD bar should always be done) and edited inferno sync and timer to what i think it should be.<br>
	---	---						Fixed a typo in the bomb section, let's see how that goes...<br>
	---	---						Shortened LivingBomb CD as per data.<br>
	---	---						Adjusted nextIgnite CD as per data.<br>

<b>20030</b><br>
	Relar BigWigs---			Release of Relar version.<br>
	---	---						Adjusted all timers that seemed off.<br>
	---	---						Disabled icon placement on C'thun's fight (line 556), ppl can now enable icon placement risk-free.<br>

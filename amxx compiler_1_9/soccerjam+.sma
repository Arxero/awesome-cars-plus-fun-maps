/*
* --------------------------------------------------------------------------------------------------
*
* 	      _____                         ___                  ______ _
* 	     /  ___|                       |_  |                 | ___ \ |
* 	     \ `--.  ___   ___ ___ ___ _ __  | | __ _ _ __ ___   | |_/ / |_   _ ___
* 	      `--. \/ _ \ / __/ __/ _ \ '__| | |/ _` | '_ ` _ \  |  __/| | | | / __|
* 	     /\__/ / (_) | (_| (_|  __/ |/\__/ / (_| | | | | | | | |   | | |_| \__ \
* 	     \____/ \___/ \___\___\___|_|\____/ \__,_|_| |_| |_| \_|   |_|\__,_|___/ 		-pub version
*
*
* --------------------------------------------------------------------------------------------------
* 	- INSTALLATION, DESCRIPTION
*
* 	- Official updated modified version of original SoccerJam Mod made by OneEyed:
* 		http://forums.alliedmods.net/showthread.php?t=41447
*   - Tournament mod by Doondook:
*		https://github.com/Doondook/soccerjam
*
*		1) Just copy & paste (& overwrite) all files from soccerjamplus.zip at your server. 
*		2) Disable not needed plugins like afk kicker, custom map chooser, camera changer (these updated plugins are included in this mod for better performance).
*		3) Restart from Control Panel.
*			- The .zip file contains all models, sounds, recommended maps, compiled plugin, .sma file with used libraries (include), config & lang files, and latest GEOIP+ by Arkshine.
*
*
*		Config Files: sj_plus_config.cfg - check for further customizations
*					  sj_plus_maps.ini - mapchooser's custom map list
*
* 	- Customizable CVARS/COMMANDS list - PLEASE READ - important info
*
*		Console CMDS:	
*		- showbriefing - shows SJ admin menu
*		- amx_restart - restarts server
*		
*		Chat CMDS:
*		- .reset - reset your skills
*		- .skills [player] - show [player's] skills
*		- .stats [player] - show [player's] stats
*		- .whois - show everyone's country
*		- rtv - rock the vote
*		- .spec - change team to spectators
*		- .cam - toggle camera view
*		- [mapname] - nominate your desired map to be shown on next mapvote
*		
*		Console CVARS:
* 		- sj_multiball (20) - amount of the balls for "multiball" command
* 		     		      (32 balls is the limit to prevent server crashes);
* 		- sj_lamedist (90) - max distance to the opposite goals as far you can score,
* 		    		    if there is no opponents in alien zone in moment of shoot;
*		- sj_antideveloper (1) - enables antideveloper, warns & kicks player if his fps_override or developer is set to 1.
*		- sj_regen (0) - enables global HP regeneration
*		- sj_blockspray (0) - blocks impulse 201 (spray logo)
* 		- sj_alienmin (9.0) - minimal damage done by alien;
* 		- sj_alienmax (11.0) - maximum damage done by alien;	
*		- sj_mapchooser (1) - enables SJ mapchooser - example syntax in sj_plus_maps.ini. Use this one since majority of different mapchoosers don't work right with SJ mods.
*		- sj_afk_enable (1) - if you wish to use an AFK kicker, please use this one as it is fully working, many around alliedmodders are outdated and buggy.
*			- sj_afk_transfer_time (12) - 12*5 (=60) seconds to transfer AFK player spec
*			- sj_afk_kick_time (24) - 24*5 seconds to kick AFK player from server
*			- sj_afk_kick_players (10) - minimum number of players required to be present on server to start kicking AFK players
*		- sj_score - winning score (public mode only);
*		- sj_scoret - current Terrorists score;
*		- sj_scorect - current Counter-Terrorists score;
* 		- sj_idleball (30.0) - idle ball time in seconds;		
*		- sj_description (0) - shows score in game description
*		- sj_timer (1) - activates alien timer
*
* -------------------------------------------------------------------------------------------------- *
*
* - Change log:
*
*
* - - version 2.2.0 (pub modification):
*
*	Various bugs fixed
*	Added team color ball beams;
*	Added ball rotating;
*	Implemented custom map chooser (sj_plus_maps.ini);
*	Implemented Anti-Hunt;
*	Added reseting skills option;
*	Rewritten Help;
*	Added integrated team management (AFK Manager + Instant Auto-Team Balance);
*	Added constant HP regeneration (sj_regen);
*	Added blocking spray feature (sj_blockspray).
*	Added Alien Timer (sj_alientimer)
*	Added Lagless Camera (sv_cheats 1 required, console cheats are blocked by plugin)
*
*
* - - version 2.3.0
*
*	Strength now updates after spawn (prevents strength changing during game abuse)
*   Lagless Camera optimized
*   Various bugs fixed
*
*
*
* - - version 1.0.0 (release):
*
* 	Added switching between public and tournament modes;
*	Added multi-ball support;
* 	Added SQL stats saving, clan and server management;
*	Added auto-recording and auto-uploading HLTV-demos to FTP-server (tournament mode only);
* 	Added nVault-saving experience, stats and skills of current game;
* 	Fixed respawn system;
* 	Fixed variety of bugs and errors;
* 	Added anti-lame settings;
* 	Added anti-hunt settings;
* 	Added ability to view players skills, stats (for public mode);
* 	Added configuration file allowing additional customization;
*	Added menu for admins with frequently used settings/commands;
* 	Added variety of design features and improvements;
* 	Added ability of showing current game status (score, time) instead of game description;
* 	Added integrated 3rd-person camera view support;
*	Added integrated /whois support;
*
* 	Improved stats and skills systems:
* 		- added disarm, ball losses, passes stats;
* 		- improved assists and possession stats;
* 		- using money as experience;
* 		- added reseting skills (for public mode);
* 		- disarm does not retrieve opponent's knife (for public mode);
* 		- stamina increases health after next spawn (prevent /reset spam).
*
* 	Added chat commands:
* 		- /top [number] - show top [number] players [SQL];
* 		- /rank [player] - show your [player's] rank [SQL];
* 		- /rankstats [player] - show your [player's] stats [SQL];
* 		- /stats [player] - show your [player's] stats in current game;
* 		- /skills [player] - show your [player's] skills in current game;
* 		- /reset - reset skills;
* 		- /cam /camera - toggle camera view;
* 		- /firstperson /first - 1st-person camera view;
* 		- /thirdperson /third - 3rd-person camera view;
* 		- /spec - go to spectators;
*
*		Note: prefix "." is either supported.
*
* 	Added commands:
* 		- "nightvision" (default: "N") - toggle camera view;
* 		- "+alt1" (default: "ALT") - shows "!" sprite above a player (asking for a pass);
* 		- "showbriefing" (default: "L" or "I") - SJ admin menu [ADMIN_KICK].
*
* 	Added / remade CVars:
* 		- sj_multiball (20) - amount of the balls for "multiball" command
* 		     		      (32 balls is the limit to prevent server crashes);
* 		- sj_lamedist (0) - max distance to the opposite goals as far you can score,
* 		    		    if there is no opponents in alien zone in moment of shoot;
* 		- sj_huntdist (100) - enough distance between player and ball to be hunted;
*		- sj_huntgk (5.0) - time in seconds for cancelling goals after goalkeeper hunt;
* 		- sj_turbo (2) - turbo refresh:
* 			2 - default;
* 			20 - fast.
* 		- sj_resptime (2.0) - delay in seconds before respawning.
* 		- sj_nogoal (0) - goals:
* 			0 - enable;
* 			1 - disable.
* 		- sj_smack (0.8) - smack chance multiplier;
* 		- sj_ljdelay (5.0) - delay in seconds between doing long jumps;
* 		- sj_alienzone (650.0) - radius of alien strikes;
* 		- sj_alienthink (1.0) - period of time in seconds of alien strikes;
* 		- sj_alienmin (9.0) - minimal damage done by alien;
* 		- sj_alienmax (11.0) - maximum damage done by alien;
*		- sj_score - winning score (public mode only);
*		- sj_scoret - current Terrorists score;
*		- sj_scorect - current Counter-Terrorists score;
* 		- sj_idleball (30.0) - idle ball time in seconds.
*
* 	Remade multi-language support;
* 	Remade help.
*											[Doondook]

* --------------------------------------------------------------------------------------------------
*/

#pragma dynamic 131072

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <nvault>
#include <geoip>
#include <cellarray>
#include <colorchat_sj>
#if AMXX_VERSION_NUM < 183
    #include <dhudmessage>
#endif 

#define PLUGIN 		"SoccerJam+"
#define VERSION 	"2.3.0"
#define LASTCHANGE 	"2020-11-11"
#define AUTHOR 		"OneEyed&Doon&DK"

#define BALANCE_IMMUNITY		ADMIN_RCON

#define MAX_PLAYERS 32

new g_pcvarMaxCount 
new g_iCount[MAX_PLAYERS+1] 
new g_bIsBot, g_bIsAlive, g_bIsConnected

#define SetUserBot(%1) 		g_bIsBot |= 1<<(%1 & (MAX_PLAYERS - 1))
#define ClearUserBot(%1) 	g_bIsBot &= ~(1<<(%1 & (MAX_PLAYERS - 1)))
#define IsUserBot(%1) 		g_bIsBot & 1<<(%1 & (MAX_PLAYERS - 1))

#define SetUserAlive(%1) 	g_bIsAlive |= 1<<(%1 & (MAX_PLAYERS - 1))
#define ClearUserAlive(%1) 	g_bIsAlive &= ~(1<<(%1 & (MAX_PLAYERS - 1)))
#define IsUserAlive(%1) 	g_bIsAlive & 1<<(%1 & (MAX_PLAYERS - 1))

#define SetUserConnected(%1)    g_bIsConnected |= 1<<(%1 & (MAX_PLAYERS - 1))
#define ClearUserConnected(%1) 	g_bIsConnected &= ~(1<<(%1 & (MAX_PLAYERS - 1)))
#define IsUserConnected(%1) 	g_bIsConnected & 1<<(%1 & (MAX_PLAYERS - 1))

#define TEAMS 		4

#define T		1
#define CT		2
#define SPECTATOR 	3
#define UNASSIGNED 	0

#define ScoreLimit "SCORE_LIMIT"
/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|   [CUSTOM MODIFICATIONS]	| ******************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

// Skills bonuses
#define AMOUNT_STA 		20	// Health
#define AMOUNT_STR 		25	// Stronger kicking
#define AMOUNT_AGI 		13	// Faster Speed
#define AMOUNT_DEX 		18	// Better Catching
#define AMOUNT_DIS 		6	// Disarm ball chance (disarm lvl * this)

static const mdl_mascots[TEAMS][] = {
	"NULL",
	"models/kingpin.mdl",
	"models/garg.mdl",
	"NULL"
}

static const mdl_mask[TEAMS][] = {
	"NULL",
	"models/kickball/jason.mdl",
	"models/kickball/jason.mdl",
	"NULL"
}

//------------------------- DO NOT EDIT BELOW -----------------------------//

// Curve Ball Defines
#define CURVE_ANGLE		15	// Angle for spin kick multipled by current direction
#define CURVE_COUNT		6	// Curve this many times
#define CURVE_TIME		0.2	// Time to curve again
#define DIRECTIONS		2	// # of angles allowed
#define	ANGLEDIVIDE		6	// Divide angle this many times for curve

new TeamNames[TEAMS][32] = {
	"Unassigned",
	"T",
	"CT",
	"Spectator"
}
new TeamId[TEAMS]

#define MODE_NONE 	0
#define MODE_PREGAME 	1
#define MODE_GAME 	2

#define TYPE_PUBLIC 	0
#define TYPE_TOURNAMENT 1

new GAME_MODE = MODE_PREGAME
new GAME_TYPE

#define SETS_DEFAULT 	0
#define SETS_TRAINING 	1
#define SETS_HEADTOHEAD 2
#define SETS_ROCKET 	3

new GAME_SETS = SETS_DEFAULT

#define BASE_HP 		100
#define BASE_SPEED 		250.0
#define BASE_DISARM		5

#define AMOUNT_POWERPLAY 	5
#define MAX_POWERPLAY		5

#define SHOTCLOCK_TIME 		12
#define COUNTDOWN_TIME 		10

#define GOALY_POINTS_CAMP	3

#define HEALTH_REGEN_AMOUNT 	1
#define MAX_GOALY_DISTANCE	10000
#define MAX_GOALY_DELAY		1.0

// $$ for each action
#define POINTS_GOALY_CAMP	20
#define POINTS_GOAL		100
#define POINTS_ASSIST		60
#define POINTS_STEAL		30
#define POINTS_HUNT		0
#define POINTS_BALLKILL		20
#define POINTS_PASS		0
#define POINTS_DISHITS		5
#define POINTS_FAIL		0
#define POINTS_GOALSAVE 	10
#define POINTS_TEAMGOAL		0
#define POINTS_LATEJOIN		60

#define STARTING_CREDITS 	12

#define MVP_GOAL	1
#define MVP_ASSIST	1
#define MVP_STEAL	1
#define MVP_GOALSAVE	1
#define MVP_HUNT	1
#define MVP_LOSSES	-1
#define MVP_DISHITS	1

#define MAX_ASSISTERS 	 2
#define MAX_PENSHOOTERS  5
#define PEN_STAND_RADIUS 50.0

#define MAX_NOMINATED	20
#define MAX_TRIES	50

#define KICK_IMMUNITY 		ADMIN_BAN

#define TASK_AFK_CHECK 		142500
#define FREQ_AFK_CHECK 		5.0
#define MAX_WARN 		3

#define LIMIT_BALLS 100

#define RECORDS 16
enum {
	GOAL = 1,
	ASSIST,
	STEAL,
	GOALSAVE,
	PASS,
	LOSS,
	SMACK,
	HUNT,
	DEATH,
	POSSESSION,
	BALLKILL,
	HITS,
	BHITS,
	DISHITS,
	DISARMED,
	DISTANCE
}


enum {
	aTerro,
	aCt
}

static const RecordTitles[RECORDS + 1][] = {
	"NULL", "GOL", "AST", "STL", "GSV", "PAS", "BLS", "SMK", "HNT", "DTH", "POS", 
	"BKL", "HITS", "BHITS", "DIS", "DISED", "FGL"
}

static const RecordTitlesLong[RECORDS + 1][] = {
	"NULL", "Goals", "Assists", "Steals", "Goalsaves", "Passes", "Ball losses",
	"Smacks", "Hunts", "Deaths", "Possession", "Ballkills", "Hits", "Ballholder Hits",
	"Disarms", "Disarmed", "Furthest goal"
}

#define UPGRADES 5
enum {
	STA = 1,	// stamina
	STR,		// strength
	AGI,		// agility
	DEX,		// dexterity
	DIS		// disarm
}

static const UpgradeTitles[UPGRADES + 1][] = { "NULL", "STA", "STR", "AGI", "DEX", "DIS" }
new UpgradeMax[UPGRADES + 1]
new UpgradePrice[UPGRADES + 1][16]
new PlayerUpgrades[MAX_PLAYERS + 1][UPGRADES + 1]
new PlayerUpgrades_STR[MAX_PLAYERS + 1][UPGRADES + 1]
new PlayerDefaultUpgrades[MAX_PLAYERS + 1][UPGRADES + 1]

new PowerPlay[LIMIT_BALLS], PowerPlay_list[LIMIT_BALLS][MAX_POWERPLAY + 1]
new Float:fire_delay[LIMIT_BALLS]

new GoalEnt[TEAMS]

new CVAR_KILLNEARBALL
new CVAR_KILLNEARHOLDER
new bool:g_bImmuned[MAX_PLAYERS+1]

new Float:g_fJoinedTeam[MAX_PLAYERS+1] = {-1.0, ...}

new bool:g_bSpec[33]
new bool:g_bSpecAccess[33]
new Float:g_fLastActivity[33]
new g_iAFKCheck
new g_iAFKTime[33]
new g_iKickTime
new g_iMaxPlayers
new g_pcvarEnable, g_pcvarImmune, g_pCvarMessage
new g_iMinPlayers
new g_iTransferTime
new g_iWarn[33]
new g_vOrigin[33][3]
new CVAR_afk_check
new CVAR_afk_transfer_time
new CVAR_afk_kick_time
new CVAR_afk_kick_players

// true when connected and not a HLTV
new bool:g_bValid[MAX_PLAYERS+1]



new gTimerEnt
new Float:gTimerEntThink
new Float:gTimerEntThink2

new PressedAction[MAX_PLAYERS + 1]
new seconds[MAX_PLAYERS + 1]
new g_sprint[MAX_PLAYERS + 1]

new SideJump[MAX_PLAYERS + 1]
new Float:SideJumpDelay[MAX_PLAYERS + 1]

new Mascots[TEAMS]

new menu_upgrade[MAX_PLAYERS + 1]

new winner

new Float:BallSpawnOrigin[3]
new Float:TeamPossOrigins[TEAMS][3]

new Float:TeamBallOrigins[TEAMS][3]
new Float:TEMP_TeamBallOrigins[3]

new Float:MascotsOrigins[3]
new Float:MascotsAngles[3]

new TopPlayer[2][RECORDS + 1]
new MadeRecord[MAX_PLAYERS + 1][RECORDS + 1]
new TempRecord[MAX_PLAYERS + 1][RECORDS + 1]
new TeamRecord[TEAMS][RECORDS + 1]
new TopPlayerName[RECORDS + 1][32]
new g_Experience[MAX_PLAYERS + 1]

new TeamColors[TEAMS][3]
new BeamColors[TEAMS][3]
new GlowColors[TEAMS][3]

new mdl_ball[256]

new snd_kicked[]	= "kickball/kicked.wav"
new snd_ballhit[] 	= "kickball/bounce.wav"
new snd_distress[] 	= "kickball/distress.wav"
new snd_returned[] 	= "kickball/returned.wav"
new snd_amaze[] 	= "kickball/amaze.wav"
new snd_laugh[] 	= "kickball/laugh.wav"
new snd_perfect[] 	= "kickball/perfect.wav"
new snd_diebitch[] 	= "kickball/diebitch.wav"
new snd_pussy[] 	= "kickball/pussy.wav"
new snd_prepare[] 	= "kickball/prepare.wav"
new snd_gotball[] 	= "kickball/gotball.wav"
new snd_bday[] 		= "kickball/bday.wav"
new snd_levelup[] 	= "kickball/levelup.wav"
new snd_boomchaka[] 	= "kickball/boomchakalaka.wav"
new snd_whistle[] 	= "kickball/whistle.wav"
new snd_whistle_long[] 	= "kickball/whistle_endgame.wav"

new g_maxplayers

// Sprites
new spr_fire
new spr_smoke
new spr_beam
new spr_burn
new spr_fxbeam
//new spr_porange
//new spr_pass[TEAMS]

new g_ballholder[LIMIT_BALLS]
//new g_ballowner[LIMIT_BALLS]
new g_last_ballholder[LIMIT_BALLS ]
new g_last_ballholdername[LIMIT_BALLS][32]
new g_last_ballholderteam[LIMIT_BALLS]
new g_ball[LIMIT_BALLS], g_ball_touched[2]
new g_count_balls
new g_count_scores

new Float:testorigin[LIMIT_BALLS][3], Float:velocity[LIMIT_BALLS][3]
new scoreboard[128]
new g_temp[64], g_temp2[64]
new distorig[2][3] // distance recorder

new msg_deathmsg, msg_statusicon, msg_scoreboard
new bool:RunOnce

new curvecount[LIMIT_BALLS]
new direction[LIMIT_BALLS]
new Float:BallSpinDirection[LIMIT_BALLS][3]

new g_authid[MAX_PLAYERS + 1][36]

new cv_nogoal, cv_alienzone, cv_alienthink, cv_kick, cv_turbo, cv_reset, cv_resptime, cv_smack,
cv_ljdelay, cv_huntdist, cv_score[3], cv_multiball, cv_lamedist, cv_alienmin, cv_alienmax,
cv_time, cv_balldist, cv_players, cv_chat, cv_pause, cv_regen, cv_blockspray, cv_antideveloper, cv_description, cv_timer


new g_cam[MAX_PLAYERS + 1]
new bool:g_cam2[MAX_PLAYERS + 1]

new g_vault
new g_current_match, gMatchId //, g_temp_current_match

#define MAX_ASSISTERS 2
new g_assisters[MAX_ASSISTERS]
new Float:g_assisttime[MAX_ASSISTERS]

//new g_PlayerDeaths[MAX_PLAYERS + 1]

new g_showhelp[MAX_PLAYERS + 1]
new g_distshot

new g_Time[MAX_PLAYERS + 1]
new bool:g_lame = false, bool:g_nogk[TEAMS] = false

new OFFSET_INTERNALMODEL

new g_Timeleft
new bool:g_Ready[MAX_PLAYERS + 1]
new g_maxcredits

new g_MVP_points[MAX_PLAYERS + 1], g_MVP, g_MVP_name[32]
//new gTopPlayers[5]

new g_showhud[MAX_PLAYERS + 1]

static Float:g_StPen[3] = {-224.0, 365.0, 1604.0}
new Float:g_PenOrig[MAX_PLAYERS + 1][3]
new freeze_player[MAX_PLAYERS + 1]

new g_regtype

new g_iTeamBall
new timer
new GoalyPoints[MAX_PLAYERS + 1]
new Float:GoalyCheckDelay[MAX_PLAYERS + 1]
new g_Credits[MAX_PLAYERS + 1]

new g_serverip[32]
new g_userip[MAX_PLAYERS + 1][32]
//new g_userUTC[MAX_PLAYERS + 1]
new g_list_authid[64][36]
new g_userClanName[MAX_PLAYERS + 1][32]
new g_userClanId[MAX_PLAYERS]
new g_userNationalName[MAX_PLAYERS + 1][32]
new g_userCountry[MAX_PLAYERS + 1][64]
new g_userCountry_2[MAX_PLAYERS + 1][3]
new g_userCountry_3[MAX_PLAYERS + 1][4]
new g_userCity[MAX_PLAYERS + 1][46]
new g_userNationalId[MAX_PLAYERS + 1]

new g_PlayerId[MAX_PLAYERS + 1]
new g_mvprank[MAX_PLAYERS + 1][32]
new g_TempTeamNames[TEAMS][32]

new g_mapname[32]


enum ReasonCodes{
	DR_TIMEDOUT,
	DR_DROPPED,
	DR_KICKED,
	DR_OTHER
}

new Trie:gTrieStats

new aball
new is_kickball

new msg_roundtime
/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [PRECACHE]		| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/


public native_sj_get_gamemode()
{
	return GAME_MODE;
}

public plugin_natives()
{
	register_library("soccerjam");
	register_native("sj_get_gamemode", "native_sj_get_gamemode");
}

new ScoreLim[32]

public plugin_precache(){
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "sj_plus_public.cfg")

	if (!file_exists(path)){
		log_amx("[SJ] - Can not allocate config file %s", path)
		log_amx("Continue with default settings.")
	} else {
		new linedata[1024], key[64], value[960]

		new file = fopen(path, "rt")

		new sz_red[4], sz_green[4], sz_blue[4], i, sz_temp[64], x
		//mdl_ball = ArrayCreate(64, 1)
		while(file && !feof(file)){
			i = 0
			fgets(file, linedata, charsmax(linedata))

			replace(linedata, charsmax(linedata), "^n", "")

			if(!linedata[0] || linedata[0] == ';'
			|| (linedata[0] == '/' && linedata[1] == '/')
			|| (linedata[0] == '-' && linedata[1] == '-'))
				continue

			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')

			trim(key)
			trim(value)
			remove_quotes(value)

			if(equal(key, "BALL_MODEL")){
				format(mdl_ball, charsmax(mdl_ball), value)
				precache_model(mdl_ball)
			} else if(equal(key, "BALL_BEAM_CT")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				trim(value)
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				BeamColors[CT][0] = str_to_num(sz_red)
				BeamColors[CT][1] = str_to_num(sz_green)
				BeamColors[CT][2] = str_to_num(sz_blue)
			} else if(equal(key, "BALL_BEAM_T")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				trim(value)
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				BeamColors[T][0] = str_to_num(sz_red)
				BeamColors[T][1] = str_to_num(sz_green)
				BeamColors[T][2] = str_to_num(sz_blue)
			} else if(equal(key, "BALL_GLOW")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				trim(value)
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				GlowColors[0][0] = str_to_num(sz_red)
				GlowColors[0][1] = str_to_num(sz_green)
				GlowColors[0][2] = str_to_num(sz_blue)
				/*
			} else if(equal(key, "BALL_BEAM")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				trim(value)
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				TeamColors[0][0] = str_to_num(sz_red)
				TeamColors[0][1] = str_to_num(sz_green)
				TeamColors[0][2] = str_to_num(sz_blue)
				*/
			} else if(equal(key, "T_TEAM_COLOR")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				trim(value)
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				TeamColors[T][0] = str_to_num(sz_red)
				TeamColors[T][1] = str_to_num(sz_green)
				TeamColors[T][2] = str_to_num(sz_blue)
			} else if(equal(key, "CT_TEAM_COLOR")){
				strtok(value, sz_red, charsmax(sz_red), value, charsmax(value), ',')
				strtok(value, sz_green, charsmax(sz_green), sz_blue, charsmax(sz_blue), ',')
				TeamColors[CT][0] = str_to_num(sz_red)
				TeamColors[CT][1] = str_to_num(sz_green)
				TeamColors[CT][2] = str_to_num(sz_blue)
			} else if(contain(key, "LVL_") != -1){
				strtok(key, sz_temp, charsmax(sz_temp), key, charsmax(key), '_')
				for(i = 1; i <= UPGRADES; i++){
					if(equal(key, UpgradeTitles[i])){
						UpgradeMax[i] = str_to_num(value)
						break
					}
				}
			} else if(equal(key,ScoreLimit)){
					ScoreLim[31] = str_to_num(value)
			} else if(contain(key, "PRICE_") != -1){
				strtok(key, sz_temp, charsmax(sz_temp), key, charsmax(key), '_')
				for(i = 1; i <= UPGRADES; i++){
					if(equal(key, UpgradeTitles[i])){
						add(value, charsmax(value), ",")
						x = 0
						while(replace(value, charsmax(value), ",", "#") && x < UpgradeMax[i]){
							strtok(value, sz_temp, charsmax(sz_temp), value, charsmax(value), '#')
							UpgradePrice[i][x++] = str_to_num(sz_temp)
						}
						break
					}
				}
			} else if(contain(key, "POINTS_") != -1){
			} 
			//else log_amx("[SJ] - Key %s from config file has not been found!", key)
		}
		if(file) fclose(file)
	}

	g_vault = nvault_open("nv_soccerjam+")

	if(g_vault == INVALID_HANDLE)
		log_amx("[SJ] - Error opening nVault!")

	precache_model(mdl_mascots[T])
	precache_model(mdl_mascots[CT])
	precache_model("models/chick.mdl")
	precache_model("models/rpgrocket.mdl")
	precache_model(mdl_mask[T])
	precache_model(mdl_mask[CT])
	//precache_model(mdl_players[T])
	//precache_model(mdl_players[CT])


	spr_beam 	= 	precache_model("sprites/laserbeam.spr")
	spr_fire 	= 	precache_model("sprites/shockwave.spr")
	spr_smoke 	= 	precache_model("sprites/steam1.spr")
	spr_fxbeam 	= 	precache_model("sprites/laserbeam.spr")
	spr_burn 	= 	precache_model("sprites/xfireball3.spr")

	//spr_pass[T]	= 	precache_model("sprites/kickball/Tpass.spr")
	//spr_pass[CT]	= 	precache_model("sprites/kickball/CTpass.spr")

	precache_sound(snd_amaze)
	precache_sound(snd_laugh)
	precache_sound(snd_perfect)
	precache_sound(snd_diebitch)
	precache_sound(snd_pussy)
	precache_sound(snd_prepare)
	precache_sound(snd_ballhit)
	precache_sound(snd_gotball)
	precache_sound(snd_bday)
	precache_sound(snd_returned)
	precache_sound(snd_distress)
	precache_sound(snd_kicked)
	precache_sound(snd_levelup)
	precache_sound(snd_boomchaka)
	precache_sound(snd_whistle)
	precache_sound(snd_whistle_long)

	//precache_generic("sound/misc/loading/ussr.mp3")
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [INITIALIZE]		| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

//new g_debug = 0

new configfile[200]

new menu[2000]
new keys

new g_teamScore[2]

new bool:voting
new votes[10]
new maps[9][32]

//new num_nominated = 0
//new nominated[MAX_NOMINATED][32]
//new bool:has_nominated[33]

new mp_winlimit
new mp_maxrounds

//new extended_pcvar
//new lastmap_pcvar
new lastmap_was_pcvar
//new lastlastmap_pcvar
new lastlastmap_was_pcvar
new showvotes_pcvar
new rtv_percent_pcvar
new rtv_wait_pcvar
new delay_time_pcvar
new delay_tally_time_pcvar

new extended

new cur_nextmap[32]

new cstrike
new bool:rtv[33]
new rtvtotal

new Float:voterocked
new bool:voterocked2

new num

new say_commands[][32] =
{
	"rockthevote",
	"rock the vote",
	"rtv",
	"/rockthevote",
	"/rock the vote",
	"/rtv"
}

/*
new say_commands2[][32] =
{
	"nominate",
	"/nominate"
}
*/

new lastmap[32]
new lastlastmap[32]
new currentmap[32]
public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR)

	get_configsdir(configfile,199)
	format(configfile,199,"%s/sj_plus_maps.ini",configfile)

	register_cvar("sj_mapchooser","1")

	g_pcvarMaxCount = register_cvar("max_bad_value", "2") 

	if(file_exists(configfile) && get_cvar_num("sj_mapchooser"))
	{
		register_concmd("amx_nextmap_vote","cmd_nextmap",ADMIN_MAP,"Starts a vote for nextmap [0=allow extend(Default) | 1=Don't allow extend] [1=Change Now(Default) | 0=Change at End")

		register_clcmd("say nextmap","saynextmap")
		register_clcmd("say_team nextmap","saynextmap")

		register_clcmd("say","say_hook")
		register_clcmd("say_team","say_hook")

		cstrike = cstrike_running()
		if(cstrike) register_event("TeamScore", "team_score", "a")

		register_menucmd(register_menuid("CustomNextMap"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"VoteCount")

		set_task(15.0,"Check_Endround",1337,"",0,"b")

		if(cstrike)
		{
			mp_winlimit = get_cvar_pointer("mp_winlimit")
			mp_maxrounds = get_cvar_pointer("mp_maxrounds")
		}

		//extended_pcvar	=	register_cvar("sj_extendmax",	"10")
		//lastmap_pcvar	=	register_cvar("sj_lastmap_show",	"1")
		//lastlastmap_pcvar	=	register_cvar("map_lastlastmap_show",	"1")
		showvotes_pcvar		=	register_cvar("sj_show_votes",	"1")
		rtv_percent_pcvar	=	register_cvar("sj_rtv_percent",	"60")
		rtv_wait_pcvar		=	register_cvar("sj_rtv_wait",	"0")
		lastmap_was_pcvar	=	register_cvar("sj_lastmap",	"")
		lastlastmap_was_pcvar 	=	register_cvar("sj_lastlastmap",	"")
		delay_time_pcvar	=	register_cvar("sj_map_delay_time",	"2")
		delay_tally_time_pcvar	=	register_cvar("sj_tally_delay_time",	"10")

		if(is_plugin_loaded("Nextmap Chooser")!=-1) pause("acd","mapchooser.amxx")
		if(is_plugin_loaded("NextMap")!=-1) pause("acd","nextmap.amxx")
		if(!cvar_exists("amx_nextmap")) register_cvar("amx_nextmap","")

		get_pcvar_string(lastmap_was_pcvar,lastmap,31)
		get_pcvar_string(lastlastmap_was_pcvar,lastlastmap,31)
		get_mapname(currentmap,31)
	}

	
	get_mapname(g_mapname, 31)

	if(contain(g_mapname, "soccer") == -1 && contain(g_mapname, "sj") == -1){
		set_fail_state("[SJ] - SoccerJam works only at sj_ maps!")
	}
	
	if(contain(g_mapname, "soccerjam") > -1){
		CreateGoalNets()
		CreateWall()
		CreateWall2()
		CreateWall3()
	}
	
	msg_roundtime 	= get_user_msgid("RoundTime")
	
	register_logevent("event_round_end", 2, "0=World triggered", "1=Round_End")
	register_logevent("event_round_start", 2, "0=World triggered", "1=Round_Start")

	register_clcmd("jointeam", "cmd_jointeam") // new menu
	register_menucmd(register_menuid("Team_Select", 1), 511, "cmd_jointeam") // old menu

	register_clcmd("joinclass", "cmd_joinclass") // new menu
	register_menucmd(register_menuid("Terrorist_Select", 1), 511, "cmd_joinclass") // old menu
	register_menucmd(register_menuid("CT_Select", 1), 511, "cmd_joinclass") // old menu

	//register_clcmd("say", "cmd_say")

	CVAR_afk_check = register_cvar("sj_afk_enable", "1")
	CVAR_afk_transfer_time = register_cvar("sj_afk_transfer_time", "12")
	CVAR_afk_kick_time = register_cvar("sj_afk_kick_time", "24")
	CVAR_afk_kick_players = register_cvar("sj_afk_kick_players", "10")
	
	set_cvar_num("sv_proxies", 1) // for HLTV part
	set_cvar_num("sv_cheats", 1) // for Lagless cam
	set_cvar_num("mp_friendlyfire", 0)

	register_dictionary("sj_plus_hud.txt")
	register_dictionary("sj_plus_motd.txt")

	register_forward(FM_AddToFullPack, "FWD_AddToFullpack", 1)
	register_forward(FM_GetGameDescription, "FWD_GameDescription")
	register_forward(FM_CmdStart, 		"FWD_CmdStart")

	g_maxplayers 	= get_maxplayers()

	msg_deathmsg 	= get_user_msgid("DeathMsg")
	msg_statusicon 	= get_user_msgid("StatusIcon")
	msg_scoreboard 	= get_user_msgid("ScoreInfo")

	OFFSET_INTERNALMODEL = is_amd64_server() ? 152 : 126

	set_msg_block(get_user_msgid("RoundTime"), 	BLOCK_SET)
	set_msg_block(get_user_msgid("ClCorpse"), 	BLOCK_SET)

	register_message(get_user_msgid("Money"), 	"Msg_Money")
  	register_message(get_user_msgid("TextMsg"), 	"Msg_CenterText")
	register_message(get_user_msgid("SendAudio"),	"Msg_Sound")
  	register_message(msg_statusicon, 		"Msg_StatusIcon")

	register_event("HLTV",		"Event_StartRound", "a", "1=0", "2=0")
	register_event("ShowMenu", 	"menuclass", "b", "4&CT_Select", "4&Terrorist_Select")
	register_event("VGUIMenu", 	"menuclass", "b", "1=26", "1=27")
	register_event("TeamScore", 	"Event_TeamScore", "b")

	RegisterHam(Ham_TakeDamage, 	"player", "PlayerDamage")
	RegisterHam(Ham_Spawn, 		"player", "PlayerSpawned", 1)
	RegisterHam(Ham_Killed, 	"player", "PlayerKilled")
	
	register_impulse( 101, "BlockCommand" )
	register_impulse( 102, "BlockCommand" )
	register_impulse( 202, "BlockCommand" )
	register_impulse( 201, "FwdImpulse_201" );
	

	//cv_type		=	register_cvar("sj_type", 	"0")
	cv_huntdist 	=	register_cvar("sj_huntdist", 	"0")
	cv_lamedist 	=	register_cvar("sj_lamedist", 	"90")
	cv_score[0] 	= 	register_cvar("sj_score", 	"ScoreLim[31]")
	cv_score[T] 	= 	register_cvar("sj_scoret", 	"0")
	cv_score[CT] 	= 	register_cvar("sj_scorect", 	"0")
	cv_reset 		= 	register_cvar("sj_idleball",	"30.0")
	cv_alienzone 	= 	register_cvar("sj_alienzone",	"650")
	cv_alienthink	=	register_cvar("sj_alienthink",	"1.0")
	cv_alienmin		=	register_cvar("sj_alienmin",	"9.0")
	cv_alienmax		=	register_cvar("sj_alienmax",	"11.0")
	cv_kick 		= 	register_cvar("sj_kick",	"650")
	cv_turbo 		= 	register_cvar("sj_turbo", 	"2")
	cv_resptime 	=	register_cvar("sj_resptime", 	"2.0")
	cv_nogoal 		=	register_cvar("sj_nogoal", 	"0")
	cv_smack		=	register_cvar("sj_smack", 	"80")
	cv_ljdelay		=	register_cvar("sj_ljdelay", 	"5.0")
	cv_multiball	=	register_cvar("sj_multiball", 	"15")
	cv_chat 		=	register_cvar("sj_chat", 	"1")
	cv_time 		= 	register_cvar("sj_time", 	"1")
	cv_balldist		= 	register_cvar("sj_balldist", 	"1400")
	cv_players 		= 	register_cvar("sj_players", 	"16")
	cv_pause		= 	register_cvar("sj_pause", 	"0")
	cv_regen		=	register_cvar("sj_regen",	"0")
	cv_blockspray	=	register_cvar("sj_blockspray", "0")
	cv_antideveloper	=	register_cvar("sj_antideveloper", "1")
	cv_description		=	register_cvar("sj_description", "1")
	cv_timer		=	register_cvar("sj_timer",	"1")
	
	register_touch("PwnBall", "player", 		"touch_Player")
	register_touch("PwnBall", "soccerjam_goalnet",	"touch_Goalnet")
	register_touch("PwnBall", "worldspawn",		"touch_World")
	register_touch("PwnBall", "func_wall",		"touch_World")
	register_touch("PwnBall", "func_door",		"touch_World")
	register_touch("PwnBall", "func_door_rotating", "touch_World")
	register_touch("PwnBall", "func_wall_toggle",	"touch_World")
	register_touch("PwnBall", "func_breakable",	"touch_World")
	register_touch("PwnBall", "func_blocker",	"touch_World")
	register_touch("PwnBall", "PwnBall",		"touch_Ball")
	
	set_task(3.0, "taskDeveloperCheck", _, _, _, "b")
	set_task(0.4, "Meter", _, _, _, "b")
	set_task(1.0, "Event_Radar", _, _, _, "b")
	
	//set_task(3.1, "taskDeveloperCheck2", _, _, _, "b") 

	register_think("PwnBall", 	"think_Ball")
	register_think("Mascot", 	"think_Alien")
	

	register_clcmd("say",		"ChatCommands")		// handle say
	register_clcmd("say_team",	"ChatCommands_team")	// handle say_team
	register_clcmd("drop",		"Turbo")		// use turbo
	register_clcmd("lastinv",	"BuyUpgrade")		// skills menu
	register_clcmd("radio1", 	"CurveLeft")		// curve left
	register_clcmd("radio2", 	"CurveRight")		// curve right
	register_clcmd("fullupdate", 	"BlockCommand")		// block fullupdate
	register_clcmd("noclip", 	"BlockCommand")
	//register_clcmd("developer 1", 	"BlockCommand")
	register_clcmd("god",	"BlockCommand")

	register_concmd("showbriefing", "AdminMenu", 	ADMIN_IMMUNITY, 	"SJ Admin Menu")
	register_concmd("nightvision", 	"CameraChanger",_,		"Switches camera view")
	//register_concmd("sj_update", 	"Update", 	_,  		"Updates plugin")
	register_concmd("amx_restart", 	"Restart",	ADMIN_KICK, 	"Restart server")
	register_concmd("sj_version", 	"Version",	_, 		"Shows plugin's version info")
	//register_concmd("jointeam", 	"BlockCommand")

	register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select")

	CVAR_KILLNEARBALL = register_cvar("sj_kill_distance_ball", "200.0")
	CVAR_KILLNEARHOLDER = register_cvar("sj_kill_distance_holder", "250.0")
	
	set_pcvar_num(cv_score[T], 0)
	set_pcvar_num(cv_score[CT], 0)
	set_pcvar_num(cv_score[0], ScoreLim[31])
	
	GAME_TYPE = TYPE_PUBLIC
	if(GAME_TYPE == TYPE_PUBLIC){
		GAME_MODE = MODE_NONE
		//gTournamentId = 8
	} else {
		GAME_MODE = MODE_NONE
		//gTournamentId = 8
	}
	g_Timeleft = get_pcvar_num(cv_time) * 60
	new x
	for(x = 1; x <= UPGRADES; x++){
		g_maxcredits += (UpgradeMax[x] + 1)
	}
	for(x = 1; x <= g_maxplayers; x++){
		g_Credits[x] = STARTING_CREDITS
		g_Experience[x] = 0
		g_PenOrig[x][0] = g_StPen[0]
		g_PenOrig[x][1] = 0.0
		g_PenOrig[x][2] = g_StPen[2]
	}
	TeamId[UNASSIGNED] = 0
	TeamId[SPECTATOR] = 0
	TeamId[T] = -1
	TeamId[CT] = -2

	gTimerEnt = create_entity("info_target")
	if(gTimerEnt) {
		if(GAME_TYPE == TYPE_PUBLIC){
			if(!winner){
				gTimerEntThink = 0.2
				gTimerEntThink2 = 1.01
			} else {
				gTimerEntThink = 0.5
			}
		} else {
			gTimerEntThink = 0.5
		}
		set_pev(gTimerEnt, pev_classname, "StatusTimer")
		register_think("StatusTimer", "StatusDisplay")
		set_pev(gTimerEnt, pev_nextthink, halflife_time() + gTimerEntThink)
	} else {
		set_fail_state("Cannot create StatusTimer entity.")
	}


	get_user_ip(0, g_serverip, charsmax(g_serverip), 0)
	get_user_ip(0, g_userip[0], 31, 1)

	gTrieStats = TrieCreate()

	//sql_connect()

	SwitchGameSettings(0, SETS_DEFAULT)

	//set_task(300.0, "sql_updateServerInfo", 43041, _, _, "b")

	/*get_cvar_string( "port", g_serverport, charsmax(g_serverport))
	get_cvar_string( "ip", g_wserverip, charsmax(g_wserverip))
	get_cvar_string( "hostname", g_servername, charsmax(g_servername))
	new result, errorstr[ 2 ], errorno
	RegexHandle = regex_compile( "jsonp=(.+)&_=", result, errorstr, charsmax( errorstr ), "i" )
	szSocket = socket_listen( g_wserverip, 1107, SOCKET_TCP, errorno )
	set_task( 0.1, "OnSocketReply", _, _, _, "b")*/

	if(!g_current_match)
		PostGame()

	g_pcvarEnable = register_cvar("sj_balance", "1")
	g_pcvarImmune = register_cvar("sj_balance_immunity", "1")
	g_pCvarMessage = register_cvar("sj_balance_message", "Teams Auto Balanced")

	register_logevent("LogEvent_JoinTeam", 3, "1=joined team")
	register_event("TextMsg", "Auto_Team_Balance_Next_Round", "a", "1=4", "2&#Auto_Team")

	g_iMaxPlayers = get_maxplayers()
	
	set_task( 2.5, "ApplyServerSettings")
}

public ApplyServerSettings(){
	server_cmd("mp_timelimit 0")
	timer = COUNTDOWN_TIME
	BeginCountdown()
}
	
public LogEvent_JoinTeam()
{
	new loguser[80], name[32], id
	read_logargv(0, loguser, 79)
	parse_loguser(loguser, name, 31)
	id = get_user_index(name)

	g_fJoinedTeam[id] = get_gametime()
}

public client_authorized(id)
{
	g_bImmuned[id] = bool:(get_user_flags(id) & BALANCE_IMMUNITY)
}

public Restart(id, level, cid){
	if(!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED
		
	new sz_name[32]
	get_user_name(id, sz_name, charsmax(sz_name))
	client_print(0, print_console, "[SJ] - Restart server. (ADMIN: %s)", sz_name)
	ColorChat(0, GREEN, "^4[SJ] ^1- Restart server. (ADMIN: %s)", sz_name)
	set_task(2.0, "task_Restart")
	return PLUGIN_HANDLED
}

#define MODE_NONE 	0
#define MODE_PREGAME 	1
#define MODE_GAME 	2

public task_Restart(){
	server_cmd("restart")
}

public Version(id){
	console_print(id, "SoccerJam+ v.%s | %s", VERSION, LASTCHANGE)
	console_print(id, "Original version by OneEyed. Updateed by Doondook & DK.")
	console_print(id, "Official web-site: http://sj-pro.com")

	return PLUGIN_HANDLED
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|	  [BALL]			| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public CreateBall(i){
	if(i >= LIMIT_BALLS)
		return PLUGIN_HANDLED

	g_ballholder[i] = 0
	g_last_ballholder[i] = 0
	g_last_ballholderteam[i] = 0
	fire_delay[i] = 0.0
	PowerPlay[i] = 0
	for(new x = 0; x <= MAX_POWERPLAY; x++)
		PowerPlay_list[i][x] = 0

	if(!is_valid_ent(g_ball[i])){
		new entity = create_entity("info_target")
		if(entity){
			entity_set_model(entity, mdl_ball)
			set_pev(entity, pev_classname, "PwnBall")

			set_pev(entity, pev_solid, SOLID_BBOX)
			set_pev(entity, pev_movetype, MOVETYPE_BOUNCE)

			entity_set_vector(entity, EV_VEC_mins, Float:{ -15.0, -15.0, 0.0 })
			entity_set_vector(entity, EV_VEC_maxs, Float:{ 15.0, 15.0, 12.0 })
			set_pev(entity, pev_framerate, 0.0)
			set_pev(entity, pev_sequence, 0)

			glow(entity, GlowColors[0][0], GlowColors[0][1], GlowColors[0][2])

			g_ball[i] = entity
			aball = entity
			
			remove_task(i + 55555)

			set_pev(entity, pev_nextthink, halflife_time() + 0.03)
			
			entity_set_float(entity,EV_FL_framerate,0.0)
			entity_set_int(entity,EV_INT_sequence,0)
			
			if(i) g_count_balls++
		} else {
			client_print(0, print_chat, "[CreateBall] - Creating ball #%d error!")
		}
	}
	return PLUGIN_HANDLED
}

public RemoveBall(i){
	if(i >= LIMIT_BALLS)
		return PLUGIN_HANDLED

	if(is_valid_ent(g_ball[i])){
		remove_entity(g_ball[i])
		if(g_ballholder[i])
			glow(g_ballholder[i], 0, 0, 0)
		g_ballholder[i] = 0
		g_last_ballholder[i] = 0
		g_last_ballholderteam[i] = 0
		g_ball[i] = 0
		format(g_last_ballholdername[i], 31, "")
		fire_delay[i] = 0.0
		PowerPlay[i] = 0
		for(new x = 0; x <= MAX_POWERPLAY; x++)
			PowerPlay_list[i][x] = 0
		if(i) g_count_balls--
	}

	return PLUGIN_HANDLED
}

public think_Ball(){
	new x
	for(new i = 0; i <= g_count_balls; i++){
		if(is_valid_ent(g_ball[i])){
			if(PowerPlay[i] >= MAX_POWERPLAY && get_gametime() - fire_delay[i] >= 0.3){
				on_fire(i)
			}

			if(g_ballholder[i]){
				pev(g_ballholder[i], pev_origin, testorigin[i])

				if(pev(g_ball[i], pev_solid) != SOLID_NOT)
					set_pev(g_ball[i], pev_solid, SOLID_NOT)

				// Put ball in front of player
				ball_infront(g_ballholder[i], 50.0)
				for(x = 0; x < 3; x++)
					velocity[i][x] = 0.0

				// Add lift to z axis
				if(pev(g_ballholder[i], pev_flags) & FL_DUCKING){
					testorigin[i][2] -= 20
				} else {
					testorigin[i][2] -= 30
				}

				set_pev(g_ball[i], pev_velocity, velocity[i])
				set_pev(g_ball[i], pev_origin, testorigin[i])
			} else if(pev(g_ball[i], pev_solid) != SOLID_BBOX) {
				set_pev(g_ball[i], pev_solid, SOLID_BBOX)
			}

		}
		set_pev(g_ball[i], pev_nextthink, halflife_time() + 0.01)
	}

	return PLUGIN_HANDLED
}

stock MoveBall(where, team = 0, i){
	new k = i
	if(i < 0){
		k = g_count_balls
		i = 0
	}
	for(; i <= k; i++){
		if(is_valid_ent(g_ball[i])){
			if(g_ballholder[i])
				glow(g_ballholder[i], 0, 0, 0)
			PowerPlay[i] = 0
			g_ballholder[i] = 0
			g_last_ballholder[i] = 0
			format(g_last_ballholdername[i], 31, "")
			for(new t = 0; t < MAX_ASSISTERS; t++){
				g_assisters[t] = 0
				g_assisttime[t] = 0.0
			}
			if(team){
				// own goalnet
				if(g_iTeamBall == 0){
					entity_set_origin(g_ball[i], TeamBallOrigins[team])
					entity_set_vector(g_ball[i], EV_VEC_velocity, Float:{0.0, 0.0, 50.0})
				// team side
				} else {
					new Float:sz_orig[3]
					for(new x = 0; x < 3; x++){
						sz_orig[x] = TeamPossOrigins[team][x]
					}

					if(team == T){
						sz_orig[0] -= get_pcvar_num(cv_balldist)
					} else {
						sz_orig[0] += get_pcvar_num(cv_balldist)
					}

					if(i & 1 || !i){
						sz_orig[1] -= 50.0 * i
						sz_orig[2] += 25.0 * i
					} else {
						sz_orig[1] += (50.0 * (i - 1))
						sz_orig[2] += 25.0 * (i - 1)
					}

					entity_set_origin(g_ball[i], sz_orig)
					formatex(g_temp, charsmax(g_temp), "Ball is at %s side!", TeamNames[team])
					entity_set_vector(g_ball[i], EV_VEC_velocity, Float:{0.0, 0.0, 50.0})
				}
			} else {
				switch(where){
					case 0: { // outside map

						new Float:orig[3], x
						for(x = 0; x < 3; x++)
							orig[x] = -9999.9
						orig[1] += (50.0 * i)
						entity_set_origin(g_ball[i], orig)
						remove_task(i + 55555)

						set_task(20.0, "ClearBall", 55555 + i)
						
						PowerPlay[i] = 0
					}
					case 1: { // at middle
						//set_pev(g_ball[i], pev_solid, SOLID_NOT)

						new Float:sz_orig[3]
						sz_orig = BallSpawnOrigin
						if(i & 1 || !i){
							sz_orig[1] -= 50.0 * i
							sz_orig[2] += 25.0 * i
						} else {
							sz_orig[1] += (50.0 * (i - 1))
							sz_orig[2] += 25.0 * (i - 1)
						}

						/*new j
						for(j = 0; j <= g_count_balls; j++){
						}

						new Float:szKickX = 300.0, Float:szKickY = 0.0
						new Float:szAngle = (i * (360 / j / 3.14))
						new Float:szX = rotateX(szKickX, szKickY, szAngle)
						new Float:szY = rotateY(szKickX, szKickY, szAngle)

						new Float:szKickVec[3]
						szKickVec[0] = szX
						szKickVec[1] = szY
						szKickVec[2] = 200.0
						entity_set_origin(g_ball[i], sz_orig)
						entity_set_vector(g_ball[i], EV_VEC_velocity, szKickVec)
						client_print(0, print_chat, "[%d] %0.f , %0.f  (%0.f)", i, szX, szY, szAngle)

						set_task(1.5, "MakeBallsSolid")*/

						entity_set_origin(g_ball[i], sz_orig)
						entity_set_vector(g_ball[i], EV_VEC_velocity, Float:{0.0, 0.0, 400.0})
						format(g_temp, charsmax(g_temp), "%L", LANG_SERVER, "SJ_MIDDLEBALL")
					}
				}
			}
		}
	}
}

public MakeBallsSolid(){
	for(new i = 0; i <= g_count_balls; i++){
		if(is_valid_ent(g_ball[i])){
			set_pev(g_ball[i], pev_solid, SOLID_BBOX)
		}

	}
}

public KickBall(id, velType){
	new i
	for(i = 0; i <= g_count_balls; i++)
		if(id == g_ballholder[i])
			break

	if(i == g_count_balls + 1){
		client_print(id, print_chat, "[ERROR] Ball has not been found! [KickBall]")
		return PLUGIN_HANDLED
	}
	remove_task(55555 + i)
	set_task(get_pcvar_float(cv_reset), "ClearBall", 55555 + i)

	new team = get_user_team(id)
	new x

	// Give it some lift
	ball_infront(id, 55.0)

	testorigin[i][2] += 10

	new Float:tempO[3], Float:returned1[3]
	new Float:dist2

	pev(id, pev_origin, tempO)
	new tempEnt = trace_line(id, tempO, testorigin[i], returned1)

	dist2 = get_distance_f(testorigin[i], returned1)

	if(point_contents(testorigin[i]) != CONTENTS_EMPTY || (~IsUserConnected(tempEnt) && dist2)){
		return PLUGIN_HANDLED
	} else {
		// Check if our ball isn't inside a wall before kicking
		new Float:ballF[3], Float:ballR[3], Float:ballL[3]
		new Float:ballB[3], Float:ballTR[3], Float:ballTL[3]
		new Float:ballBL[3], Float:ballBR[3]

		for(x = 0; x < 3; x++){
			ballF[x]  = testorigin[i][x];	ballR[x]  = testorigin[i][x]
			ballL[x]  = testorigin[i][x];	ballB[x]  = testorigin[i][x]
			ballTR[x] = testorigin[i][x];	ballTL[x] = testorigin[i][x]
			ballBL[x] = testorigin[i][x];	ballBR[x] = testorigin[i][x]
		}

		x = 6
		while(x--){
			ballF[1]  += 3.0;	ballB[1]  -= 3.0
			ballR[0]  += 3.0;	ballL[0]  -= 3.0
			ballTL[0] -= 3.0;	ballTL[1] += 3.0
			ballTR[0] += 3.0;	ballTR[1] += 3.0
			ballBL[0] -= 3.0;	ballBL[1] -= 3.0
			ballBR[0] += 3.0;	ballBR[1] -= 3.0

			if(point_contents(ballF) 	!= CONTENTS_EMPTY
			|| point_contents(ballR) 	!= CONTENTS_EMPTY
			|| point_contents(ballL) 	!= CONTENTS_EMPTY
			|| point_contents(ballB)  	!= CONTENTS_EMPTY
			|| point_contents(ballTR) 	!= CONTENTS_EMPTY
			|| point_contents(ballTL) 	!= CONTENTS_EMPTY
			|| point_contents(ballBL) 	!= CONTENTS_EMPTY
			|| point_contents(ballBR) 	!= CONTENTS_EMPTY)
				return PLUGIN_HANDLED
		}

		new ent = -1
		testorigin[i][2] += 35.0

		while((ent = find_ent_in_sphere(ent, testorigin[i], 35.0)) != 0){
			if(ent > g_maxplayers){
				new classname[32]
				pev(ent, pev_classname, classname, 31)

				if((contain(classname, "goalnet") != -1 || contain(classname, "func_") != -1) &&
				!equal(classname, "func_water") && !equal(classname, "func_illusionary"))
					return PLUGIN_HANDLED
			}
		}
		testorigin[i][2] -= 35.0
	}

	new Float:ballorig[3], kickVel
	pev(id, pev_origin, ballorig)

	if(!velType){
		new str = (PlayerUpgrades_STR[id][STR] * AMOUNT_STR) + (AMOUNT_POWERPLAY * (PowerPlay[i] * 5))
		kickVel = get_pcvar_num(cv_kick) + str
		kickVel += g_sprint[id] * 100

		if(direction[i]){
			pev(id, pev_angles, BallSpinDirection[i])
			curvecount[i] = CURVE_COUNT
		}
		new sz_data[2]
		sz_data[0] = id
		sz_data[1] = i
		set_task(CURVE_TIME * 2, "CurveBall", id, sz_data, 2)
	} else {
		curvecount[i] = 0
		direction[i] = 0
		kickVel = random_num(100, 600)
	}

	velocity_by_aim(id, kickVel, velocity[i])
	for(x = 0; x < 3; x++)
		distorig[0][x] = floatround(ballorig[x])

	if(PowerPlay[i] >= MAX_POWERPLAY){
		message_begin(MSG_ONE, msg_statusicon, {0,0,0}, g_ballholder[i])
		write_byte(0) // status (0 = hide, 1 = show, 2 = flash)
		write_string("dmg_heat") // sprite name
		write_byte(0) // red
		write_byte(0) // green
		write_byte(0) // blue
		message_end()
	}

	(g_nogk[team==T?CT:T])?(g_lame = true):(g_lame = false)

	g_ballholder[i] = 0
	g_last_ballholder[i] = id
	g_last_ballholderteam[i] = team

	set_pev(g_ball[i], pev_origin, testorigin[i])
	set_pev(g_ball[i], pev_velocity, velocity[i])

	emit_sound(g_ball[i], CHAN_ITEM, snd_kicked, 1.0, ATTN_NORM, 0, PITCH_NORM)

	glow(id, 0, 0, 0)

	//beam(10, g_ball[i])
	//beam(10, g_ball[i], i)
	//beam(10, g_ball[i], i)


	get_user_name(id, g_last_ballholdername[i], 31)
	format(g_temp, charsmax(g_temp), "|%s| %s^n%L", TeamNames[team], g_last_ballholdername[i],
	LANG_SERVER, "SJ_KICKBALL")

	return PLUGIN_HANDLED
}

public ball_infront(id, Float:dist){
	new i
	for(i = 0; i <= g_count_balls; i++){
		if(id == g_ballholder[i])
			break
	}
	if(i == g_count_balls + 1){
		client_print(id, print_chat, "[ERROR] Ball has not been found! [Ball infront]")
		return PLUGIN_HANDLED
	}
	new Float:nOrigin[3]
	new Float:vAngles[3] // plug in the view angles of the entity
	new Float:vReturn[3] // to get out an origin fDistance away

	pev(g_ball[i], pev_origin, testorigin[i])
	pev(id, pev_origin, nOrigin)
	pev(id, pev_v_angle, vAngles)

	vReturn[0] = floatcos(vAngles[1], degrees) * dist
	vReturn[1] = floatsin(vAngles[1], degrees) * dist

	vReturn[0] += nOrigin[0]
	vReturn[1] += nOrigin[1]

	testorigin[i][0] = vReturn[0]
	testorigin[i][1] = vReturn[1]
	testorigin[i][2] = nOrigin[2]

	return PLUGIN_HANDLED
}

public on_fire(i){
	if(is_valid_ent(g_ball[i])){
		new Float:forig[3], forigin[3]
		fire_delay[i] = get_gametime()

		entity_get_vector(g_ball[i], EV_VEC_origin, forig)

		for(new x = 0; x < 3; x++)
			forigin[x] = floatround(forig[x])

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(17)
		write_coord(forigin[0] + random_num(-5, 5))
		write_coord(forigin[1] + random_num(-5, 5))
		write_coord(forigin[2] + 10 + random_num(-5, 5))
		write_short(spr_burn)
		write_byte(7)
		write_byte(235)
		message_end()
	}
}

public CurveBall(sz_data[]){
	new id = sz_data[0]
	new i = sz_data[1]

	if(direction[i] && get_speed(g_ball[i]) > 5 && curvecount[i] > 0){
		new Float:v[3], Float:v_forward[3]

		pev(g_ball[i], pev_velocity, v)
		vector_to_angle(v, BallSpinDirection[i])

		BallSpinDirection[i][1] = normalize(BallSpinDirection[i][1] + float((direction[i] * CURVE_ANGLE) / ANGLEDIVIDE))
		BallSpinDirection[i][2] = 0.0

		angle_vector(BallSpinDirection[i], 1, v_forward)

		new Float:speed = vector_length(v)
		v[0] = v_forward[0] * speed
		v[1] = v_forward[1] * speed

		set_pev(g_ball[i], pev_velocity, v)

		curvecount[i]--
		new sz_data[2]
		sz_data[0] = id
		sz_data[1] = i
		set_task(CURVE_TIME, "CurveBall", id, sz_data, 2)
	}
}

public ClearBall(i){
	i -= 55555
	if(is_valid_ent(g_ball[i])){
		play_wav(0, snd_returned)
		format(g_temp, charsmax(g_temp), "%L", LANG_SERVER, "SJ_MIDDLEBALL")
		MoveBall(1, 0, i)
	}
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|		[DISPLAY]		| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public SetUserConfig(id, const cvar[], const value[]){
	if(str_to_num(value) != 0){
		server_cmd("kick #%d  ^"Set cl_filterstuffcmd to 0^"", get_user_userid(id))
	} else {
		client_cmd(id, "cl_updaterate 101;cl_cmdrate 101;fps_max 101;rate 25000")
	}
}
public StatusDisplay_Restart(){
	//new Float:szDelay = halflife_time() + 1.0

	new Float:szDelay = random_float(0.3, 0.4)
	new Float:nextAlien
	pev(Mascots[T], pev_nextthink, nextAlien)
	new Float:nextTimer
	pev(gTimerEnt, pev_nextthink, nextTimer)

	if(nextAlien - nextTimer > gTimerEntThink){
		nextAlien -= szDelay
	}

	set_pev(gTimerEnt, pev_nextthink, nextTimer + szDelay)
	set_pev(Mascots[T], pev_nextthink, nextAlien + szDelay)
	set_pev(Mascots[CT], pev_nextthink, nextAlien + szDelay)

}

public StatusDisplay(szEntity){
	new id, sz_temp[1024]

	switch(GAME_MODE){
		case MODE_PREGAME:{
			new i, sz_lang[32], ss[10], sz_len
			new Float: fb, Float:fh, Float:fb2

			for(id = 1; id <= g_maxplayers; id++){
				if(~IsUserConnected(id) || IsUserBot(id) || g_showhelp[id])
					continue

				//query_client_cvar(id, "cl_filterstuffcmd", "SetUserConfig")
				
				sz_len = 0

				sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "Top Match Statistics^n^n")
				sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
				"%s - %d : %d - %s^n", g_TempTeamNames[T], get_pcvar_num(cv_score[T]),
				get_pcvar_num(cv_score[CT]), g_TempTeamNames[CT])
				set_dhudmessage(255, 255, 20, -1.0, 0.05, 0, 0.1, 0.5, 0.3, 0.3)
				if(GAME_TYPE == TYPE_TOURNAMENT){
					show_dhudmessage(id, "FULL-TIME")
				    } else {
					show_dhudmessage(id, "CHANGING MAP...")
				}
				for(i = 1; i <= RECORDS; i++){
					if(i == POSSESSION){
						format(sz_lang, charsmax(sz_lang), "SJ_%s", RecordTitles[i])
						if(g_showhud[id] == 1) {
							num_to_str(TopPlayer[1][i], ss, 9)
							fb = str_to_float(ss)
							num_to_str(g_Time[0], ss, 9)
							fh = str_to_float(ss)
							sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
							"^n^n%L: %s%s%d", id, sz_lang, TopPlayerName[i], TopPlayer[1][i]?" - ":" ",
							g_Time[0]?(floatround((fb / fh) * 100.0)):0)
						} else if(g_showhud[id] == 2) {
							num_to_str(TeamRecord[T][i], ss, 9)
							fb = str_to_float(ss)
							num_to_str(TeamRecord[CT][i], ss, 9)
							fb2 = str_to_float(ss)
							num_to_str(g_Time[0], ss, 9)
							fh = str_to_float(ss)

							sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
							"^n^n%d%%%% - %L - %d%%%%", g_Time[0]?(floatround((fb / fh) * 100.0)):0, id, sz_lang,
							g_Time[0]?(floatround((fb2 / fh) * 100.0)):0)
						}
					} else {
						format(sz_lang, charsmax(sz_lang), "SJ_%s", RecordTitles[i])

						if(g_showhud[id] == 1) {
							sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
							"^n%L: %s%s%d", id, sz_lang, TopPlayerName[i], TopPlayer[1][i]?" - ":" ", TopPlayer[1][i])
						} else if(g_showhud[id] == 2) {
							sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
							"^n%d - %L - %d", TeamRecord[T][i], id, sz_lang, TeamRecord[CT][i])
						}
					}
					if(g_showhud[id] == 1){
						switch(i){
							case POSSESSION:{
								sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%%%%")

								if(TopPlayer[1][i] != MadeRecord[id][i] && TopPlayer[1][i]){
									num_to_str(MadeRecord[id][i], ss, 9)
									fb = str_to_float(ss)
									num_to_str(g_Time[0], ss, 9)
									fh = str_to_float(ss)
									sz_len += format(sz_temp[sz_len],
									charsmax(sz_temp) - sz_len, " (%d%%%%)", g_Time[0]?(floatround((fb / fh) * 100.0)):0)
								}
							}
							case DISHITS:{
								num_to_str(MadeRecord[id][DISHITS], ss, 9)
								fb = str_to_float(ss)
								num_to_str(MadeRecord[id][BHITS], ss, 9)
								fh = str_to_float(ss)
								sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, " (%d [%d%%%%])",
								MadeRecord[id][DISHITS], MadeRecord[id][BHITS]?(floatround((fb / fh) * 100.0)):0)

							}
							case DISTANCE:{
								sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
								" %L", id, "SJ_FT")

								if(TopPlayer[1][i] != MadeRecord[id][i] && TopPlayer[1][i]){
									sz_len += format(sz_temp[sz_len],
									charsmax(sz_temp) - sz_len, " (%d) %L", MadeRecord[id][i], id, "SJ_FT")
								}
							}
							default: {
								if(TopPlayer[1][i] != MadeRecord[id][i] && TopPlayer[1][i]){
									sz_len += format(sz_temp[sz_len],
									charsmax(sz_temp) - sz_len, " (%d)", MadeRecord[id][i])
								}
							}
						}
					}
				}
				if(!equal(g_MVP_name, "")){
					set_dhudmessage(20, 255, 20, -1.0, 0.1, 0, 0.1, 0.4, 0.1, 0.1)
					show_dhudmessage(id, "MVP of the match is %s!", g_MVP_name)
				}
				
				if(winner && g_showhud[id]){
					if(g_showhud[id] == 1){
						set_hudmessage(255, 255, 20, 0.1, 0.08, 0, 0.2, 0.3, 0.3, 0.3, 4)
					} else if(g_showhud[id] == 2){
						set_hudmessage(20, 255, 20, 0.1, 0.08, 0, 0.2, 0.3, 0.3, 0.3, 4)
					}
					show_hudmessage(id, sz_temp)
				}

				//}
			}
		}

		case MODE_GAME:{
			if(g_ballholder[0]){
				Event_Record(g_ballholder[0], POSSESSION)
			}
			if(GAME_TYPE == TYPE_PUBLIC){
				//new sz_score = get_pcvar_num(cv_score[0])
				//new sz_score = ScoreLim[31]
				if(!winner){
					if(g_Timeleft > 118){
						g_Timeleft = 60
					}
					new timedisplay[32]
					new seconds = 0
					new minutes = 0
					//format(timedisplay, charsmax(timedisplay), ":%s%i", seconds<10?"0":"", seconds)
					format(timedisplay, charsmax(timedisplay), "%s:%s%i", minutes, seconds<10?"0":"", seconds)
					for(id = 1; id <= g_maxplayers; id++) {
						if(~IsUserConnected(id)){
							continue
						}		
						message_begin(MSG_ONE_UNRELIABLE, msg_roundtime, _, id)
						//write_short(abs(g_Timeleft) + 1)
						write_short(0)
						message_end()
					}
					if(++g_Timeleft == 0)
						g_Timeleft = 119							
				}
				else
				{
					g_Timeleft = 0
				}
						
				for(id = 1; id <= g_maxplayers; id++){
					if(~IsUserConnected(id) || IsUserBot(id) || g_showhelp[id])
						continue

					set_dhudmessage(255, 20, 20, 0.44, 0.05, 0, 1.1, 1.1, 1.1, 1.1)
					show_dhudmessage(id, "%s - %d", TeamNames[T], get_pcvar_num(cv_score[1]))

					set_dhudmessage(20, 20, 255, 0.52, 0.05, 0, 1.1, 1.1, 1.1, 1.1)
					show_dhudmessage(id, "%d - %s", get_pcvar_num(cv_score[2]), TeamNames[CT])
					/*
					if(!winner){
						format(sz_temp, charsmax(sz_temp), " %L ", id,
						(sz_score%10 == 1 && sz_score%100 != 11)?
						"SJ_GOALLIM1":"SJ_GOALLIM", sz_score)
						set_hudmessage(20, 175, 20, 1.0, 0.0, 0, 1.1, 1.1, 1.1, 1.1, 1)
						show_hudmessage(id, "%s^n^n^n^n^n^n%s", sz_temp, g_temp)
					}
					*/
				}
			}
		}
	}
	//client_print(0, print_chat, "%d : %0.f", szEntity, pev(szEntity, pev_nextthink))
	if(!winner){
		set_pev(szEntity, pev_nextthink, halflife_time() + gTimerEntThink2)
	}
	else
	{
	set_pev(szEntity, pev_nextthink, halflife_time() + gTimerEntThink)
	}
	return PLUGIN_HANDLED
}

public ShowDHud(sz_colors[]){
	set_dhudmessage(sz_colors[0], sz_colors[1], sz_colors[2], -1.0, 0.3, 0, 0.2, 0.5, 0.7, 0.7)
	show_dhudmessage(0, "%s", scoreboard)
}

public ShowDHud2(sz_colors[]){
	set_dhudmessage(sz_colors[0], sz_colors[1], sz_colors[2], -1.0, 0.3, 0, 0.2, 5.0, 0.0, 0.0)
	show_dhudmessage(0, "%s", scoreboard)
}

public ShowDHud3(sz_colors[]){
	set_dhudmessage(sz_colors[0], sz_colors[1], sz_colors[2], -1.0, 0.3, 0, 0.2, 0.1, 0.0, 0.7)
	show_dhudmessage(0, "%s", scoreboard)
}


/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|	[TOUCHES]	| ******************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public touch_World(ball, world){
	if(get_speed(ball) > 5){
	
		new Float:r
		r = entity_get_float(ball, EV_FL_framerate)
		
		new Float:v[3]
		pev(ball, pev_velocity, v)
		v[0] *= 0.85
		v[1] *= 0.85
		v[2] *= 0.85
		set_pev(ball, pev_velocity, v)
		emit_sound(ball, CHAN_ITEM, snd_ballhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		r = (r * 0.75)
		entity_set_float(ball,EV_FL_framerate,r)
		entity_set_int(ball,EV_INT_sequence,2)	
	}
	else
	{
		entity_set_float(ball,EV_FL_framerate,0.0)
		entity_set_int(ball,EV_INT_sequence,0)
	}
}

public touch_Ball(ball1, ball2){
	if(
		(ball1 == g_ball_touched[0] && ball2 == g_ball_touched[1]) ||
		(ball2 == g_ball_touched[0] && ball1 == g_ball_touched[1])
	){
		g_ball_touched[0] = 0
		g_ball_touched[1] = 0
		return PLUGIN_HANDLED
	}
	g_ball_touched[0] = ball1
	g_ball_touched[1] = ball2

	if(get_speed(ball1) > 5){
		emit_sound(ball1, CHAN_ITEM, snd_ballhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	if(get_speed(ball2) > 5){
		emit_sound(ball2, CHAN_ITEM, snd_ballhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	new Float:sz_vel1[3], Float:sz_vel2[3]
	pev(ball1, pev_velocity, sz_vel1)
	pev(ball2, pev_velocity, sz_vel2)

	for(new x = 0; x < 3; x++){
		sz_vel1[x] *= 0.85
		sz_vel2[x] *= 0.85
		if(get_speed(ball1) < 5.0)
			sz_vel1[x] = 0.15 * sz_vel2[x]
		if(get_speed(ball2) < 5.0)
			sz_vel2[x] = 0.15 * sz_vel1[x]
	}

	set_pev(ball1, pev_velocity, sz_vel2)
	set_pev(ball2, pev_velocity, sz_vel1)

	entity_set_float(ball1,EV_FL_framerate,0.0)
	entity_set_int(ball2,EV_INT_sequence,0)
	
	entity_set_float(ball2,EV_FL_framerate,0.0)
	entity_set_int(ball1,EV_INT_sequence,0)	
	
	return PLUGIN_HANDLED
}

public touch_Player(ball, player){
	if(~IsUserAlive(player))
		return PLUGIN_HANDLED
	new i
	new Float:vp[3], Float: vb[3], k
	for(i = 0; i <= g_count_balls; i++){
		if(player == g_ballholder[i]){
			pev(player, pev_velocity, vp)
			pev(ball, pev_velocity, vb)
			for(k = 0; k < 3; k++){
				vb[k] += vp[k]
			}

			set_pev(ball, pev_velocity, vb)

			return PLUGIN_HANDLED
		}
	}
	for(i = 0; i <= g_count_balls; i++){
		if(g_ball[i] == ball)
			break
	}
	if(i == g_count_balls + 1){
		client_print(player, print_chat, "[ERROR] Ball has not been found! [Touch Player]")
		return PLUGIN_HANDLED
	}
	new playerteam = get_user_team(player)

	remove_task(55555 + i)

	new aname[32], stolen
	get_user_name(player, aname, 31)

	//if(task_exists(-5311 + player))
		//client_print(0, print_chat, "ALIEN")
	if(g_ballholder[i] == 0){
		if(g_last_ballholder[i] > 0 && playerteam != g_last_ballholderteam[i]){
			new speed = get_speed(ball)
			if(speed > 500 && PlayerUpgrades[player][DEX] < UpgradeMax[DEX]){
				// configure catching algorithm
				new dexlevel = PlayerUpgrades[player][DEX]
				new bstr = (PlayerUpgrades_STR[g_last_ballholder[i]][STR] * AMOUNT_STR) / 10
				new dex = dexlevel * (AMOUNT_DEX + 1)
				new pct = ((pev(player, pev_button) & IN_USE) ? 10 : 0) + dex

				pct += (dexlevel * (g_sprint[player] ? 1 : 0))	// give Dex Lvl * 2 if turboing
				pct += (g_sprint[player] ? 5 : 0 )		// player turboing? give 5%
				pct -= (g_sprint[g_last_ballholder[i]] ? 10 : 0) // g_last_ballholder turboing? lose 5%
				pct -= bstr					// g_last_ballholder has strength? remove bstr

				//pct /= get_pcvar_float(cv_smack)

				//client_print(0, print_chat, "%d", pct)
				// will player avoid damage?
				if(random_num(0, get_pcvar_num(cv_smack)) > pct){
					new Float:dodmg = (float(speed) / 13.0) + bstr - (dex - dexlevel)
					if(dodmg < 10.0)
						dodmg = 10.0
					for(new id = 1; id <= g_maxplayers; id++)
						if(IsUserConnected(id))
							client_print(id, print_chat, "%s %L",
							aname, id, "SJ_SMACKED", floatround(dodmg))

					Event_Record(player, SMACK)

					set_msg_block(msg_deathmsg, BLOCK_ONCE)
					fakedamage(player, "AssWhoopin", dodmg, 1)
					set_msg_block(msg_deathmsg, BLOCK_NOT)

					if(~IsUserAlive(player)){
						message_begin(MSG_ALL, msg_deathmsg)
						write_byte(g_last_ballholder[i])
						write_byte(player)
						write_string("AssWhoopin")
						message_end()

						//new frags = get_user_frags(g_last_ballholder[i])
						Event_Record(g_last_ballholder[i], BALLKILL)

						client_print(player, print_center,
						"%L", player, "SJ_BALLKILLED")
						client_print(g_last_ballholder[i], print_center, "%L",
						g_last_ballholder[i], "SJ_BALLKILL", aname)
					} else {
						new Float:pushVel[3]
						pushVel[0] = velocity[i][0]
						pushVel[1] = velocity[i][1]
						pushVel[2] = velocity[i][2] + ((velocity[i][2] < 0)?
						random_float(-200.0,-50.0):random_float(50.0, 200.0))
						set_pev(player, pev_velocity, pushVel)
					}

					for(new x = 0; x < 3; x++)
						velocity[i][x] = (velocity[i][x] * random_float(0.1, 0.9))

					set_pev(ball, pev_velocity, velocity[i])
					direction[i] = 0

					return PLUGIN_HANDLED
				}
			}

			if(speed > 950)
				play_wav(0, snd_pussy)

			new Float:pOrig[3]
			entity_get_vector(player, EV_VEC_origin, pOrig)
			new Float:dist = get_distance_f(pOrig, TeamBallOrigins[playerteam])

			// give more points the closer it is to net
			new sz_fail
			if(dist < 600.0 && speed > 300){
				if((float(speed) / 1000.0) - (dist / 2000.0) > 0.0){
					Event_Record(player, GOALSAVE)
					sz_fail = 1
				}
			}

			Event_Record(player, STEAL)
			if(!sz_fail)
				Event_Record(g_last_ballholder[i], LOSS)

			format(g_temp, charsmax(g_temp), "|%s| %s^n%L", TeamNames[playerteam], aname,
			LANG_SERVER, "SJ_STOLEBALL")

			stolen = 1

			for(new k = 0; k < MAX_ASSISTERS; k++){
				g_assisters[k] = 0
				g_assisttime[k] = 0.0
			}
		}

		emit_sound(ball, CHAN_ITEM, snd_gotball, 1.0, ATTN_NORM, 0, PITCH_NORM)

		g_ballholder[i] = player

		if(stolen){
			PowerPlay[i] = 0
		} else {
			format(g_temp, charsmax(g_temp), "|%s| %s^n%L", TeamNames[playerteam], aname,
			LANG_SERVER, "SJ_PICKBALL")
		}

		new bool:check
		if(((PowerPlay[i] > 1 && PowerPlay_list[i][PowerPlay[i] - 2] == player) ||
		    (PowerPlay[i] > 0 && PowerPlay_list[i][PowerPlay[i] - 1] == player))
		    && PowerPlay[i] != MAX_POWERPLAY)
			check = true

		if(PowerPlay[i] <= MAX_POWERPLAY && !check){
			PowerPlay_list[i][PowerPlay[i]] = player
			PowerPlay[i]++
		}
		curvecount[i] = 0
		direction[i] = 0

		format(g_temp2, charsmax(g_temp2), "%L: %i", LANG_SERVER, "SJ_POWERPLAY",
		(PowerPlay[i] > 0)?(PowerPlay[i] - 1):0)

		if(g_last_ballholder[i] != g_ballholder[i] && g_last_ballholder[i]){
			if(playerteam == g_last_ballholderteam[i]){
				Event_Record(g_last_ballholder[i], PASS)
				for(new x = MAX_ASSISTERS - 1; x; x--){
					g_assisters[x] = g_assisters[x - 1]
					g_assisttime[x] = g_assisttime[x - 1]
				}
				g_assisters[0] = g_last_ballholder[i]
				g_assisttime[0] = get_gametime()
			}
		}

		if(PowerPlay[i] >= MAX_POWERPLAY){
			message_begin(MSG_ONE, msg_statusicon, {0,0,0}, g_ballholder[i])
			write_byte(1) 	// status (0 = hide, 1 = show, 2 = flash)
			write_string("dmg_heat") // sprite name
			write_byte(255)	// red
			write_byte(255)	// green
			write_byte(25)	// blue
			message_end()
		}

		set_hudmessage(255, 20, 20, -1.0, 0.4, 1, 1.0, 1.5, 0.1, 0.1, 2)

		show_hudmessage(player, "%L", player, "SJ_UHAVEBALL")
		if(IsUserBot(player))
			set_task(random_float(3.0, 15.0), "BotKickBall", player - 5219)
		beam(ball, i)
		beam(ball, i)
		glow(player, TeamColors[playerteam][0], TeamColors[playerteam][1], TeamColors[playerteam][2])
	}

	return PLUGIN_HANDLED
}

public BotKickBall(id){
	id += 5219
	KickBall(id, 0)
}

public touch_Goalnet(ball, goalpost){
	new i
	for(i = 0; i <= g_count_balls; i++){
		if(g_ball[i] == ball)
			break
	}
	if(i == g_count_balls + 1){
		client_print(0, print_chat, "[ERROR] Ball has not been found! [touch_Goalnet]")
		return PLUGIN_HANDLED
	}

	new team = g_last_ballholderteam	[i]
	new goalent = GoalEnt[team]
	//set_pev(goalpost, pev_solid, SOLID_NOT)
	if(goalpost != goalent && g_last_ballholder[i] > 0 && !g_ballholder[i]){
		if(!get_pcvar_num(cv_nogoal) && GAME_MODE != MODE_PREGAME && GAME_MODE != MODE_NONE){
			new Float:ccorig[3], Float:gnorig[3]
			new ccorig2[3]

			entity_get_vector(ball, EV_VEC_origin, ccorig)
			new t
			for(t = 0; t < 3; t++)
				ccorig2[t] = floatround(ccorig[t])

			for(t = 0; t < 3; t++)
				distorig[1][t] = floatround(ccorig[t])
			pev(goalpost, pev_origin, gnorig)
			g_distshot = (get_distance(distorig[0], distorig[1]) / 12)

			if(g_lame &&  g_distshot > get_pcvar_num(cv_lamedist)){
				MoveBall(0, team==T?CT:T, i)
				for(i = 1; i < g_maxplayers; i++){
					if(IsUserConnected(i) && ~IsUserBot(i))
						ColorChat(i, RED, "^4[SJ] ^1- ^3%L",
						i, "SJ_LAME", i)
				}

				return PLUGIN_HANDLED
			}
			if((task_exists(-5005) && team == CT) || (task_exists(-5006) && team == T)){
				ColorChat(0, (team == T)?RED:BLUE, "^4[SJ] ^1- ^3GK hunt! ^1Goal has been cancelled.")
				for(t = 1; t <= g_maxplayers; t++){
					if(IsUserAlive(t) && (T <= get_user_team(t) <= CT)){
						cs_user_spawn(t)
					}
				}
				MoveBall(0, team==T?CT:T, i)
				return PLUGIN_HANDLED
			}
			format(g_temp, charsmax(g_temp), "|%s| %s^n%L %L!",
			TeamNames[team], g_last_ballholdername[i],
			LANG_SERVER, "SJ_SCORE", g_distshot, LANG_SERVER, "SJ_FT")

			new sz_temp[MAX_ASSISTERS * 45]
			format(sz_temp, charsmax(sz_temp), "^3%s", g_last_ballholdername[i])

			if(!g_count_balls){
				// register assists
				new sz_assist_name[MAX_ASSISTERS][32]
				new sz_assist_num
				for(t = 0; t < MAX_ASSISTERS; t++){
					if(!g_assisters[t] || g_assisters[t] == g_last_ballholder[i])
						break
					if(~IsUserConnected(g_assisters[t]))
						continue
					if(get_gametime() - g_assisttime[t] > 20.0){
						continue
					}
					sz_assist_num++
					Event_Record(g_assisters[t], ASSIST)
					get_user_name(g_assisters[t], sz_assist_name[t], 31)
				}

				new sz_len
				t = sz_assist_num - 1
				if(sz_assist_num){
					while(t >= 0){
						sz_len += format(sz_temp[sz_len],
						charsmax(sz_temp) - sz_len, "^3%s ^4-> ", sz_assist_name[t--])
					}
					sz_len += format(sz_temp[sz_len],
					charsmax(sz_temp) - sz_len, "^3%s", g_last_ballholdername[i])
				}
			}

			if(g_distshot > MadeRecord[g_last_ballholder[i]][DISTANCE])
				Event_Record(g_last_ballholder[i], DISTANCE)

			flameWave(ccorig2, team==T?CT:T)
			play_wav(0, snd_distress)

			for(t = 0; t < MAX_ASSISTERS; t++){
				g_assisters[t] = 0
				g_assisttime[t] = 0.0
			}

			for(new i = 1; i <= g_maxplayers; i++){
				if(~IsUserConnected(i))
					continue

				if(GAME_TYPE == TYPE_PUBLIC){
					if(get_user_team(i) == team)
						g_Experience[i] += POINTS_TEAMGOAL
				}

				if(T <= get_user_team(i) <= CT)
					save_stats(i)

				if(floatabs(ccorig[1] - gnorig[1]) > 20.0){
					ColorChat(i, (team == T)?RED:BLUE, "%s ^4%L %L!", sz_temp, i, "SJ_SCORE", g_distshot, i, "SJ_FT")
				} else {
					ColorChat(i, (team == T)?RED:BLUE, "%s ^4%L %L ^3[MIDDLE]!", sz_temp, i, "SJ_SCORE", g_distshot, i, "SJ_FT")
				}
			}
			Event_Record(g_last_ballholder[i], GOAL)

			g_iTeamBall = team
			MoveBall(0, 0, i)
			g_count_scores++
			set_pcvar_num(cv_score[team], get_pcvar_num(cv_score[team]) + 1)
			if(GAME_TYPE == TYPE_PUBLIC){
				if(get_pcvar_num(cv_score[team]) >= get_pcvar_num(cv_score[0]))
					winner = team
			}

			cs_set_team_score(CS_TEAM_T, get_pcvar_num(cv_score[T]))
			cs_set_team_score(CS_TEAM_CT, get_pcvar_num(cv_score[CT]))

			switch(random_num(1,6)){
				case 1: play_wav(0, snd_amaze)
				case 2: play_wav(0, snd_laugh)
				case 3: play_wav(0, snd_perfect)
				case 4: play_wav(0, snd_diebitch)
				case 5: play_wav(0, snd_bday)
				case 6: play_wav(0, snd_boomchaka)
			}
			if(winner){
				play_wav(0, snd_whistle_long)
				format(scoreboard, charsmax(scoreboard), "%L", LANG_SERVER, "SJ_TEAMWIN", TeamNames[winner])
				log_amx("[SJ] - TEAM %s WON! The map will be changed.", TeamNames[winner])

				set_task(1.0, "ShowDHud", _, TeamColors[winner], 3, "a", 1)
				set_task(1.6, "ShowDHud2", _, TeamColors[winner], 3, "a", 1)
				set_task(2.2, "ShowDHud2", _, TeamColors[winner], 3, "a", 1)
				set_task(2.8, "ShowDHud2", _, TeamColors[winner], 3, "a", 1)
				set_task(3.4, "ShowDHud2", _, TeamColors[winner], 3, "a", 1)
				set_task(3.9, "ShowDHud3", _, TeamColors[winner], 3, "a", 1)

				if(g_count_balls){
					for(i = g_count_balls; i >= 0; i--){
						RemoveBall(i)
					}
					g_count_balls = 0
				}
				round_restart(5.0)
				
			} else if(g_count_scores == g_count_balls + 1) {
				if(g_Timeleft > 12){
					set_task(3.0, "SvRestart", -13110)
					set_task(4.5,"StatusDisplay_Restart")
					//StatusDisplay_Restart()
				}
				g_count_scores = 0
			}
		} else {
			new florig[3], Float:borig[3]
			if(task_exists(-3312 - i)){
				if(g_last_ballholder[i]){
					pev(g_last_ballholder[i], pev_origin, borig)
					set_pev(ball, pev_origin, borig)
				} else {
					MoveBall(1, 0, i)
				}
				remove_task(-3312 - i)

				return PLUGIN_HANDLED
			}

			pev(ball, pev_origin, borig)
			for(new t = 0; t < 3; t++)
				florig[t] = floatround(borig[t])
			flameWave(florig, team==T?CT:T)

			set_task(0.1, "Done_Handler", -3312 - i)
		}
	} else if(goalpost == goalent) {
		if(get_pcvar_num(cv_nogoal) || GAME_MODE == MODE_PREGAME || GAME_MODE == MODE_NONE){
			new florig[3], Float:borig[3]
			pev(ball, pev_origin, borig)
			if(task_exists(-3312 - i)){
				if(g_last_ballholder[i]){
					pev(g_last_ballholder[i], pev_origin, borig)
					set_pev(ball, pev_origin, borig)
				} else {
					MoveBall(1, 0, i)
				}

				remove_task(-3312 - i)

				return PLUGIN_HANDLED
			}

			for(new t = 0; t < 3; t++)
				florig[t] = floatround(borig[t])

			flameWave(florig, team)

			set_task(0.1, "Done_Handler", -3312 - i)
		} else {
			if(g_last_ballholder[i]){
				MoveBall(0, team, i)
				client_print(g_last_ballholder[i], print_center,
				"%L", g_last_ballholder[i], "SJ_OWNGOAL")
			}

		}
	}
	
	entity_set_float(ball,EV_FL_framerate,0.0)
	entity_set_int(ball,EV_INT_sequence,0)	
	
	return PLUGIN_HANDLED
}


/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|   [BLOCKED COMMANDS]	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public BlockCommand(id){
	return PLUGIN_HANDLED
}

public client_kill(id){
	return PLUGIN_HANDLED
}

// fix for an exploit
public menuclass(id){
	// They changed teams
	set_pdata_int(id, OFFSET_INTERNALMODEL, 0xFF, 5)
}

public Msg_Sound(){
	new sz_snd[36]
	get_msg_arg_string(2, sz_snd, charsmax(sz_snd))

	if(contain(sz_snd, "rounddraw")	!= -1
	|| contain(sz_snd, "terwin") 	!= -1
	|| contain(sz_snd, "ctwin") 	!= -1)
		return PLUGIN_HANDLED

        return PLUGIN_CONTINUE
}

public Msg_CenterText(){
	new string[64], radio[64]
	get_msg_arg_string(2, string, 63)

	if(get_msg_args() > 2)
		get_msg_arg_string(3, radio, 63)
	//client_print(0, print_chat, "event: %s", string)
	if(contain(string, 	"#Game_will_restart") 	!= -1
	|| contain(radio, 	"#Game_radio") 		!= -1
	|| contain(string, 	"#Spec_Mode") 		!= -1
	|| contain(string, 	"#Spec_NoTarget") 	!= -1)
		return PLUGIN_HANDLED

	if(contain(string, 	"#Round_Draw") 		!= -1
	|| contain(string, 	"#Terrorists_Win") 	!= -1
	|| contain(string, 	"#CTs_Win") 		!= -1){
		if(!task_exists(-4789))
			infinite_restart()
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public infinite_restart(){
	set_cvar_num("sv_restart", 60)

	remove_task(-4566)
	set_task(57.0, "infinite_restart", -4566)
}

public team_select(id, key) {
	if(key == 0 || key == 1 || key == 4)
		if(join_team(id, key))
			return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

/*
public vgui_jointeamone(id){
	if(join_team(id, 0)){
		return PLUGIN_HANDLED
	}

	remove_task(id + 412)
	set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)

	return PLUGIN_HANDLED
}

public vgui_jointeamtwo(id){
	if(join_team(id, 1)){
		return PLUGIN_HANDLED
	}

	remove_task(id + 412)
	set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)

	return PLUGIN_HANDLED
}
*/

bool:join_team(id, key=-1) {
	new team = get_user_team(id)
	if(key == 4){
		ColorChat(id, GREY, "Please choose a team manually!")
		return true
	}
	if((team == 1 || team == 2) && (key == team - 1)){
		ColorChat(id, RED, "You can not rejoin the same team!")
		engclient_cmd(id, "chooseteam")
		return true
	}
	if(g_regtype == 2){
		if((0 <= key <= 1) && !equal(TeamNames[key + 1], g_userClanName[id])){
			ColorChat(id, key?BLUE:RED, "^4[SJ] ^1- You are not member of clan ^3%s^1!", TeamNames[key + 1])
			engclient_cmd(id, "chooseteam")
			return true
		} else if(GAME_MODE != MODE_PREGAME) {
			new sz_count
			for(new i = 1; i <= g_maxplayers; i++)
				if(IsUserConnected(i) && ~IsUserBot(i) && equal(TeamNames[key + 1], g_userClanName[i]) && get_user_team(i) == (key + 1))
					sz_count++

			if(sz_count >= 5){
				ColorChat(id, key?BLUE:RED, "^4[SJ] ^1- Too many players for ^3%s^1!", TeamNames[key + 1])
				engclient_cmd(id,"chooseteam")
				return true
			}
		}
		remove_task(id + 412)
		set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)

		return false
	}
	if(GAME_MODE != MODE_PREGAME) {
		new sz_count
		for(new i = 1; i <= g_maxplayers; i++)
			if(IsUserConnected(i) && ~IsUserBot(i) && get_user_team(i) == key + 1)
				sz_count++

		if(sz_count >= get_pcvar_num(cv_players) && get_pcvar_num(cv_players)){
			ColorChat(id, key?BLUE:RED, "^4[SJ] ^1- %d players for ^3%s ^1is allowed", get_pcvar_num(cv_players), TeamNames[key + 1])

			engclient_cmd(id,"chooseteam")
			return true
		}
	}

	remove_task(id + 412)
	set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)

	return false
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|       [EVENTS]  	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public PlayerDamage(victim, inflictor, attacker, Float:damage, damagetype){
	if(~IsUserAlive(victim) || ~IsUserAlive(attacker) || !(1 <= attacker <= 32))
		return HAM_IGNORED

	new i

	for(i = 0; i <= g_count_balls; i++){
		if(is_valid_ent(g_ball[i])){
			if(!get_pcvar_num(cv_huntdist) || get_entity_distance(g_ball[i], attacker) < get_pcvar_num(cv_huntdist)){
				break
			}
		}
	}
	if(GAME_MODE != MODE_GAME){
		if(get_entity_distance(victim, Mascots[get_user_team(victim)]) < get_pcvar_num(cv_alienzone)
		|| freeze_player[victim] || freeze_player[attacker]){
			if(!task_exists(attacker - 2432)){
				set_task(2.0, "Done_Handler", attacker - 2432)
				play_wav(attacker, "barney/donthurtem")
			}
			if(!task_exists(victim - 2432)){
				set_task(2.0, "Done_Handler", victim - 2432)
				play_wav(victim, "barney/donthurtem")
			}
			SetHamParamFloat(4, 0.0)
			return HAM_SUPERCEDE
		}
	}

	if(i == g_count_balls + 1 && (GAME_MODE == MODE_GAME)){
		if(!task_exists(attacker - 2432)){
			set_task(2.0, "Done_Handler", attacker - 2432)
			play_wav(attacker, "barney/donthurtem")
		}
		if(!task_exists(victim - 2432)){
			set_task(2.0, "Done_Handler", victim - 2432)
			play_wav(victim, "barney/donthurtem")
		}
		SetHamParamFloat(4, 0.0)
		return HAM_SUPERCEDE
	}
	if(get_user_team(victim) != get_user_team(attacker)){
		Event_Record(attacker, HITS)
		for(i = 0; i <= g_count_balls; i++){
			if(victim == g_ballholder[i])
				break
		}
		if(IsUserAlive(victim)){
			if(i <= g_count_balls){
				new upgrade = PlayerUpgrades[attacker][DIS]
				Event_Record(attacker, BHITS)
				if(upgrade){
					new disarm = upgrade * AMOUNT_DIS
					new disarmpct = BASE_DISARM + disarm
					new rand = random_num(1,100)

					if(disarmpct >= rand){
						new vname[32], aname[32]
						new sz_team = get_user_team(victim)
						get_user_name(victim, vname, 31)
						get_user_name(attacker, aname, 31)
						Event_Record(attacker, DISHITS)
						Event_Record(victim, DISARMED)

						KickBall(victim, 1)
						ColorChat(0, (sz_team == T)?RED:BLUE, "^3%s ^1has been disarmed", vname)
						//client_print(attacker, print_chat, "%L", attacker, "SJ_DISA", vname)
						//client_print(victim, print_chat, "%L", victim, "SJ_DISED", aname)
					}
				}
			}
		}
	} else {
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}
stock cs_set_team_score(CsTeams: iTeam, iScore){
	if(!(CS_TEAM_T <= iTeam <= CS_TEAM_CT))
		return PLUGIN_CONTINUE

	message_begin(MSG_ALL,get_user_msgid("TeamScore"), {0, 0, 0})
	write_string(iTeam == CS_TEAM_T ? "TERRORIST" : "CT")
	write_short(iScore)
	message_end()

	return PLUGIN_HANDLED
}

public Event_TeamScore(){
	cs_set_team_score(CS_TEAM_T, get_pcvar_num(cv_score[T]))
	cs_set_team_score(CS_TEAM_CT, get_pcvar_num(cv_score[CT]))
}

public Event_Radar(){
	if(!pev_valid(g_ball[0]))
		return PLUGIN_HANDLED

	new Float:sz_origin[3]
	pev(g_ball[0], pev_origin, sz_origin)
	if(sz_origin[2] < 0.0)
		return PLUGIN_HANDLED
	for(new id = 1; id <= g_maxplayers; id++){
		if(~IsUserConnected(id) || IsUserBot(id))
			continue

		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), { 0, 0, 0}, id)
		write_byte(id)   // I don't know it really. Just logged the msg and it seems to be the id. So I tried it too and it works since 2 years :)
		write_byte(16)   // This is the Hostage ID, I just set it to 16. Important is that you use another ID for another dot :)
		write_coord(floatround(sz_origin[0]))   // x coordinate
		write_coord(floatround(sz_origin[1]))   // y coordinate
		write_coord(floatround(sz_origin[2]))   // z coordinate
		message_end()

		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), { 0, 0, 0}, id)
		write_byte(16)   // Hostage ID from above
		message_end()
	}

	return PLUGIN_HANDLED
}

public Event_StartRound(){
	if(winner){
		GAME_MODE = MODE_PREGAME

		if(GAME_TYPE == TYPE_PUBLIC){
			if(cvar_exists("amx_extendmap_max")){
				server_cmd("mp_timelimit 2")
			} else {
				server_cmd("mp_timelimit 1")
			}

			set_cvar_string("amx_nextmap", "-")
			set_task(60.0, "ChangeMap", 9811)
			MultiBall(0 ,0, 0)
		}
	} else {
		if(GAME_TYPE == TYPE_PUBLIC){
			SetupRound()
		} else {
			switch(GAME_MODE){
				case MODE_PREGAME: {
					if(g_count_balls){
						new sz_balls = g_count_balls
						for(new i = 1; i <= sz_balls; i++){
							CreateBall(i)
							MoveBall(1, 0, i)
						}
					}
				}
				case MODE_GAME: {
					if(g_Timeleft == -9932) {
						g_iTeamBall = 0
					} else {
						SetupRound()
					}
				}
			}
		}
	}
	for(new id = 1; id <= g_maxplayers; id++){
		seconds[id] = 0
		g_sprint[id] = 0
		PressedAction[id] = 0
		SideJump[id] = 0
		SideJumpDelay[id] = 0.0
		if(IsUserAlive(id))
			glow(id, 0, 0, 0)
	}
	remove_task(-4566)
	remove_task(-4789)

	//sql_updateMatch()
	return PLUGIN_HANDLED
}

public SetupRound(){
	new i, sz_balls = g_count_balls
	get_mapname(g_mapname, 31)
	for(i = 0; i <= sz_balls; i++){
		CreateBall(i)
		if(g_iTeamBall == 0)
			MoveBall(1, 0, i)
		else if(contain(g_mapname, "soccerjam") > -1 
			|| contain(g_mapname, "sj_trix_zone") > -1 
			|| contain(g_mapname, "sansiro") > -1 
			|| contain(g_mapname, "danger_final") > -1 
			|| contain(g_mapname, "mxsoccer_small") > -1 
			|| contain(g_mapname, "ak0") > -1  
			|| contain(g_mapname, "marakana") > -1
			|| contain(g_mapname, "hood_final") > -1){
			MoveBall(0, g_iTeamBall==T?CT:T, i)
		} else {
			MoveBall(1, 0, i)
		}
	}

	g_iTeamBall = 0

	for(i = 0; i < MAX_ASSISTERS; i++){
		g_assisters[i] = 0
		g_assisttime[i] = 0.0
	}

	play_wav(0, snd_prepare)

	g_count_scores = 0
}

public ChangeMap(){
	new cmd[64], map[32]
	get_cvar_string("amx_nextmap", map, 31)
	if(equal(map, "-") || !cvar_exists("amx_nextmap")){
		get_mapname(map, charsmax(map))
	}
	format(cmd, charsmax(cmd), "changelevel %s", map)
	server_cmd(cmd)
}

public PlayerKilled(victim, killer, shouldgib){
	ClearUserAlive(victim)

	for(new i = 0; i <= g_count_balls; i++){
		if(g_ballholder[i] == victim){
			new sz_name[32], sz_team = get_user_team(g_ballholder[i])
			get_user_name(g_ballholder[i], sz_name, 31)

			remove_task(55555 + i)
			set_task(get_pcvar_float(cv_reset), "ClearBall", 55555 + i)

			format(g_temp, charsmax(g_temp), "|%s| %s^n%L", TeamNames[sz_team], sz_name,
			LANG_SERVER, "SJ_DROPBALL")

			// remove glow of owner and set ball velocity really really low
			glow(g_ballholder[i], 0, 0, 0)

			g_last_ballholderteam[i] = sz_team
			format(g_last_ballholdername[i], 31, sz_name)
			g_last_ballholder[i] = g_ballholder[i]

			pev(g_ballholder[i], pev_origin, testorigin[i])
			g_ballholder[i] = 0

			testorigin[i][2] += 10
			set_pev(g_ball[i], pev_origin, testorigin[i])

			set_pev(g_ball[i], pev_velocity, Float:{1.0, 1.0, 1.0})

			break
		}
	}
	remove_task(victim + 412)
	set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", victim + 412)

	if(GAME_MODE == MODE_GAME){
		//g_PlayerDeaths[victim]++
		Event_Record(victim, DEATH)
		if(killer != victim && 1 <= killer <= 31)
			Event_Record(killer, HUNT)
	}
	g_iAFKTime[victim]++
}

public PlayerSpawned(id){
	if(is_user_alive(id))
		SetUserAlive(id)

	remove_task(id + 412)
	set_task(0.1, "PlayerSpawnedSettings", id)
	
	g_iAFKTime[id]++
}

public RespawnPlayer(id){
	id = id - 412
	
	if (~IsUserConnected(id) || is_user_alive(id)
	|| get_pdata_int(id, OFFSET_INTERNALMODEL, 5) == 0xFF || !(T <= get_user_team(id) <= CT)){
		remove_task(id + 412)
		set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)
		return
	}

	remove_task(id + 412)

	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
	
	dllfunc(DLLFunc_Think, id)
	if(~IsUserAlive(id))
		dllfunc(DLLFunc_Spawn, id)
}

public User_Spawn(id){
	dllfunc(DLLFunc_Spawn, id)
}

public PlayerSpawnedSettings(id, szEntity){
	if(IsUserAlive(id)){
		CsSetUserScore(id, g_MVP_points[id], MadeRecord[id][DEATH])
		set_speedchange(id)

		set_pev(id, pev_health, float(1 + (PlayerUpgrades[id][STA] * AMOUNT_STA)))
		PlayerUpgrades_STR[id][STR] = PlayerUpgrades[id][STR]

		// prevent bug when transfered from spec or non-team
		new sz_clip
		get_user_weapon(id, sz_clip)
		if(!sz_clip){
			set_pdata_int(id, 121, 5)
			set_task(0.1, "User_Spawn", id)
		}

	}
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [CONTROLS]   	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public Turbo(id){
	if(is_user_alive(id))
	//if(IsUserAlive(id) && !seconds[id])
		g_sprint[id] = 1

	return PLUGIN_HANDLED
}

public client_PreThink(id){
	
	new i
	for(i = 0; i <= g_count_balls; i++)
	if(id == g_ballholder[i])
		break
	
	if( is_kickball && is_valid_ent(aball) && is_user_connected(id) && is_user_alive(id)){
		static Float:maxdistance
		static reference
		new button = entity_get_int(id, EV_INT_button)
		
		if(g_ballholder[i] > 0) {
				reference = g_ballholder[i]
				maxdistance = get_pcvar_float(CVAR_KILLNEARHOLDER)
			}			
			else {
				reference = aball
				maxdistance = get_pcvar_float(CVAR_KILLNEARBALL)
			}
			
		if(!maxdistance)
			return
			
		if(entity_range(id, reference) > maxdistance)
			entity_set_int(id, EV_INT_button, (button & ~IN_ATTACK) & ~IN_ATTACK2)
	}
			

	if(IsUserAlive(id)){
		if(freeze_player[id]){
			entity_set_float(id, EV_FL_maxspeed, 0.1)
			//return PLUGIN_CONTINUE
		}
		new button 	= pev(id, pev_button)
		new usekey 	= (button & IN_USE)
		new up 		= (button & IN_FORWARD)
		new down 	= (button & IN_BACK)
		new moveright 	= (button & IN_MOVERIGHT)
		new moveleft 	= (button & IN_MOVELEFT)
		new jump 	= (button & IN_JUMP)
		new onground 	= pev(id, pev_flags) & FL_ONGROUND
		
		if(SideJump[id] == 1)
			SideJump[id] = 0

		if((moveright || moveleft) && !up && !down && jump
		&& !g_sprint[id] && onground && i == g_count_balls + 1 && SideJump[id] != 2){
			SideJump[id] = 1
		}

		if(g_sprint[id])
			entity_set_float(id, EV_FL_fuser2, 0.0)

		if(i == g_count_balls + 1){
		/*
			if(GAME_TYPE == TYPE_PUBLIC && button & IN_ALT1){
				if(!task_exists(id + 3122))
					set_task(0.1, "ShowPassSprite", id + 3122)
			} 
			*/
			PressedAction[id] = usekey
		} else {
			if(usekey && !PressedAction[id]){
				KickBall(id, 0)
			} else if(!usekey && PressedAction[id]){
				PressedAction[id] = 0
			}
		}
	
		if(g_ballholder[i] > 0)
		{
			//no_ball = 1
			entity_set_float(g_ball[i],EV_FL_framerate,0.0)
			entity_set_int(g_ball[i],EV_INT_sequence,0)
		}
		
		else
		{
		if(g_ballholder[i] == 0)
			{
				//no_ball = 0
				entity_set_int(g_ball[i], EV_INT_sequence, 2);
				entity_set_float(g_ball[i], EV_FL_framerate, 2.0);
			}
		}	
	//return PLUGIN_CONTINUE

	}
}

public client_PostThink(id){
	if(IsUserAlive(id)){
		new Float:gametime = get_gametime()
		new button = entity_get_int(id, EV_INT_button)

		new up = (button & IN_FORWARD)
		new down = (button & IN_BACK)
		new moveright = (button & IN_MOVERIGHT)
		new moveleft = (button & IN_MOVELEFT)
		new jump = (button & IN_JUMP)

		if((gametime - SideJumpDelay[id]) > get_pcvar_float(cv_ljdelay)){
			if(SideJump[id] == 1 && jump && (moveright || moveleft) && !up && !down){
				new Float:vel[3]
				pev(id, pev_velocity, vel)
				vel[0] *= 2.0
				vel[1] *= 2.0
				vel[2] = 300.0
				SideJump[id] = 2
				set_pev(id, pev_velocity, vel)
				SideJumpDelay[id] = gametime

				return PLUGIN_CONTINUE
			}
		}
	}
	return PLUGIN_CONTINUE
}

public CurveRight(id){
	new i
	for(i = 0; i <= g_count_balls; i++){
		if(id == g_ballholder[i])
			break
	}
	if(i != g_count_balls + 1){
		if(--direction[i] < -(DIRECTIONS))
			direction[i] = -(DIRECTIONS)
		SendCenterText(id, direction[i] * CURVE_ANGLE)
	} else {
		client_print(id, print_center, "%L", id, "SJ_RCANTCURVE")
	}

	return PLUGIN_HANDLED
}

SendCenterText(id, dir){
	new sz_temp[12]
	if(dir < 0){
		format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_RIGHT")
	} else if(dir == 0) {
		format(sz_temp, charsmax(sz_temp), "-")
	} else if(dir > 0) {
		format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_LEFT")
	}

	client_print(id, print_center, "- %i %L %s", (dir < 0?-(dir):dir), id, "SJ_DEGREES", sz_temp)
}

public CurveLeft(id){
	new i
	for(i = 0; i <= g_count_balls; i++){
		if(id == g_ballholder[i])
			break
	}

	if(i != g_count_balls + 1){
		if(++direction[i] > DIRECTIONS)
			direction[i] = DIRECTIONS
		SendCenterText(id, direction[i] * CURVE_ANGLE)
	} else {
		client_print(id, print_center, "%L", id, "SJ_LCANTCURVE")
	}

	return PLUGIN_HANDLED
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [COMMANDS]	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public ChatCommands(id){
	new said[192]
	read_args(said, 192)
	remove_quotes(said)
	new sz_cmd[32], info[32], x, sz_name[32]
	parse(said, sz_cmd, 31, info, 31)
	get_user_name(id, sz_name, charsmax(sz_name))
	new sz_team = get_user_team(id)
	if(GAME_MODE == MODE_PREGAME) {
		if((equal(sz_cmd, ".ready") || equal(sz_cmd, "/ready")) && T <= sz_team <= CT) {
			if(g_Credits[id]) {
				ColorChat(id, RED, "You must use all your credits before becoming ready!")
				return PLUGIN_HANDLED_MAIN
			}

			if(!get_pcvar_num(cv_chat)){
				g_Ready[id] = true
				return PLUGIN_HANDLED_MAIN
			} else {
				if(g_Ready[id] == false){
					ColorChat(0, (sz_team == T)?RED:BLUE, "^3%s ^1: ^4.ready", sz_name)

					g_Ready[id] = true
					return PLUGIN_HANDLED_MAIN
				}

			}
		} else if((equal(sz_cmd, ".wait") || equal(sz_cmd, "/wait")) && T <= sz_team <= CT) {
			g_Ready[id] = false
			if(!get_pcvar_num(cv_chat)) {
				return PLUGIN_HANDLED_MAIN
			} else {
				ColorChat(0, (sz_team == T)?RED:BLUE, "^3%s ^1: ^4.wait", sz_name)

				return PLUGIN_HANDLED_MAIN
			}
		} else if((equal(sz_cmd, ".reset") || equal(sz_cmd, "/reset")) && T <= sz_team <= CT) {
			if(GAME_TYPE == TYPE_PUBLIC){
			
				ResetSkills(id)
			} else {
				ResetSkills(id)


				g_Ready[id] = false
			}
			if(!get_pcvar_num(cv_chat)){
				return PLUGIN_HANDLED_MAIN
			} else {
				ColorChat(0, (sz_team == T)?RED:BLUE, "^3%s ^1: ^4.reset", sz_name)

				return PLUGIN_HANDLED_MAIN
			}
		}
	}
	if(contain(sz_cmd, ".stats") != -1 || contain(sz_cmd, "/stats") != -1){
		if(!info[0]){
			if(GAME_MODE != MODE_PREGAME){
				ShowMenuStats(id)
			} else {
				(g_showhud[id])?(g_showhud[id] = 0):(g_showhud[id] = 1)
			}
			//ShowMOTDStats(id, id)
		} else {
			new player = cmd_target(id, info, 8)
			if(player){
				TNT_ShowMenuPlayerStats(id, player)
				//ShowMOTDStats(id, player)
			} else {
				ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
			}
		}
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(contain(sz_cmd, ".skills") != -1 || contain(sz_cmd, "/skills") != -1){
		new player = cmd_target(id, info, 8)
		if(!info[0]){
			TNT_ShowUpgrade(id, id)
		} else if(player) {
			TNT_ShowUpgrade(id, player)
		} else {
			ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
		}

		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/spec") || equal(sz_cmd, ".spec")){
		cmdSpectate(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if((equal(sz_cmd, ".reset") || equal(sz_cmd, "/reset")) && T <= sz_team <= CT) {
		ResetSkills(id)
		return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/cam") || equal(sz_cmd, ".cam")){
		CameraChanger(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if (equal(sz_cmd, "/cam2") || equal(sz_cmd, ".cam2")){
		CameraChangerAdvanced(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/whois") || equal(sz_cmd, ".whois")
		|| equal(sz_cmd, "/players") || equal(sz_cmd, ".players")
		|| equal(sz_cmd, "/users") || equal(sz_cmd, ".users")
		|| equal(sz_cmd, "/admin") || equal(sz_cmd, ".admin")
		|| equal(sz_cmd, "/admins") || equal(sz_cmd, ".admins")){
		WhoIs(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/first") || equal(sz_cmd, ".first")
		|| equal(sz_cmd, "/firstperson") || equal(sz_cmd, ".firstperson")){
		g_cam[id] = true
		CameraChanger(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/third") || equal(sz_cmd, ".third")
		|| equal(sz_cmd, "/thirdperson") || equal(sz_cmd, ".thirdperson")){
		g_cam[id] = false
		CameraChanger(id)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} 
	else if(equal(sz_cmd, "/help") || equal(sz_cmd, ".help")){
		ShowHelp(id, x)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/helpmenu") || equal(sz_cmd, ".helpmenu")){
		ShowHelp(id, x)
		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	} else if(contain(sz_cmd, ".setskills") != -1 || contain(sz_cmd, "/setskills") != -1){
		if(!is_user_admin(id)){
			ColorChat(id, RED, "^4[SJ] ^1- ^3You have no access to this command.")
			return PLUGIN_HANDLED_MAIN
		}
		new sz_skills[16], sz_buff[64], sz_name[32], i, sz_len

		parse(said, sz_buff, charsmax(sz_buff), sz_name, charsmax(sz_name), sz_skills, charsmax(sz_skills))

		if(strlen(said) < strlen(sz_cmd) + 2 || sz_skills[0] == EOS){
			for(i = 1; i <= UPGRADES; i++)
				sz_len += format(sz_buff[sz_len], charsmax(sz_buff) - sz_len, "<0-%d>", UpgradeMax[i])

			ColorChat(id, RED, "^4[SJ] ^1- ^4Usage: ^1/setskills <player> %s", sz_buff)
			ColorChat(id, RED, "^1This example sets GK skills for Player: ^4/setskills Player 00550")
			return PLUGIN_HANDLED_MAIN
		}

		new x = str_to_num(sz_skills)
		new sz_sk[UPGRADES + 1]
		for(i = UPGRADES; i; i--){
			if((sz_sk[i] = (x % 10)) > UpgradeMax[i]){
				ColorChat(id, RED, "^4[SJ] ^1- ^3Invalid skills!")
				return PLUGIN_HANDLED_MAIN
			}
			x /= 10
		}
		if(x < 0){
			ColorChat(id, RED, "^4[SJ] ^1- ^3Invalid skills!")
			return PLUGIN_HANDLED_MAIN
		} else {
			new player = cmd_target(id, info, 2 | 8)
			if(player){
				new sz_aname[32], sz_color[3]
				get_user_name(id, sz_aname, charsmax(sz_aname))
				get_user_name(player, sz_name, charsmax(sz_name))
				sz_len = 0
				for(i = UPGRADES; i; i--){
					PlayerUpgrades[player][i] = sz_sk[i]
				}
				for(i = 1; i <= UPGRADES; i++){
					if(PlayerUpgrades[player][i] == UpgradeMax[i]){
						format(sz_color, charsmax(sz_color), "^3")
					} else if(PlayerUpgrades[player][i]) {
						format(sz_color, charsmax(sz_color), "^4")
					} else {
						format(sz_color, charsmax(sz_color), "^1")
					}
					sz_len += format(sz_buff[sz_len], charsmax(sz_buff) - sz_len, "%s %d", sz_color, PlayerUpgrades[player][i])
				}
				g_Credits[player] = 0

				ColorChat(0, RED, "^4[SJ] ^1- %s skills are set:%s ^1(ADMIN: %s)", sz_name, sz_buff, sz_aname)
			} else {
				ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
			}
		}

		if(!get_pcvar_num(cv_chat))
			return PLUGIN_HANDLED_MAIN
	}
	if(!get_pcvar_num(cv_chat)){
		client_print(id, print_center, "- Global chat is blocked -")
		return PLUGIN_HANDLED
	}
	new sz_len = strlen(said)
	if(!sz_len)
		return PLUGIN_HANDLED_MAIN
	new sz_empty
	for(x = 0; x < sz_len; x++){
		if(said[x] != ' ' && said[x] != '%')
			sz_empty = 1
		if(said[x] == '%')
			said[x] = ' '
	}

	if(x == sz_len && !sz_empty)
		return PLUGIN_HANDLED_MAIN

	// no need for another chat
	// for(new i = 1; i <= g_maxplayers; i++){
	// 	if(~IsUserConnected(i) || (IsUserBot(i) && !is_user_hltv(i)))
	// 		continue

	// 	get_user_name(id, sz_name, 31)

	// 	if(sz_team == T){
	// 		ColorChat(i, RED, "%s ^1: %s", sz_name, said)
	// 	} else if(sz_team == CT) {
	// 		ColorChat(i, BLUE, "%s ^1: %s", sz_name, said)
	// 	} else {
	// 		ColorChat(i, GREY, "%s ^1: %s", sz_name, said)
	// 	}
	// }

	return PLUGIN_HANDLED_MAIN

}

public ChatCommands_team(id){
	new said[192]
	read_args(said, 192)
	remove_quotes(said)
	new sz_cmd[32], info[32], x, sz_name[32]
	parse(said, sz_cmd, 31, info, 31)
	get_user_name(id, sz_name, 31)
	new sz_team = get_user_team(id)
	if(GAME_MODE == MODE_PREGAME) {
		if((equal(sz_cmd, ".ready") || equal(sz_cmd, "/ready")) && (T <= sz_team <= CT)){
			if(g_Credits[id]) {
				ColorChat(id, RED, "You must use all your credits before becoming ready!")
			} else {
				if(g_Ready[id] == false){
					g_Ready[id] = true

					if(sz_team == T){
						for(new i = 1; i <= g_maxplayers; i++){
							if(IsUserConnected(i) && get_user_team(i) == T)
								ColorChat(i, RED, "^1(Terrorist) ^3%s ^1: ^4.ready", sz_name)
						}
					} else {
						for(new i = 1; i <= g_maxplayers; i++){
							if(IsUserConnected(i) && get_user_team(i) == CT)
								ColorChat(i, BLUE, "^1(Counter-Terrorist) ^3%s ^1: ^4.ready", sz_name)
						}
					}

					return PLUGIN_HANDLED_MAIN
				}
			}
		} else if((equal(sz_cmd, ".wait") || equal(sz_cmd, "/wait")) && (T <= sz_team <= CT)){
			g_Ready[id] = false

			if(sz_team == T){
				for(new i = 1; i <= g_maxplayers; i++){
					if(IsUserConnected(i) && get_user_team(i) == T)
						ColorChat(i, RED, "^1(Terrorist) ^3%s ^1: ^4.wait", sz_name)
				}
			} else {
				for(new i = 1; i <= g_maxplayers; i++){
					if(IsUserConnected(i) && get_user_team(i) == CT)
						ColorChat(i, BLUE, "^1(Counter-Terrorist) ^3%s ^1: ^4.wait", sz_name)
				}
			}

			return PLUGIN_HANDLED_MAIN
		} else if((equal(sz_cmd, ".reset") || equal(sz_cmd, "/reset")) && T <= sz_team <= CT) {
			if(GAME_TYPE == TYPE_PUBLIC){
				ResetSkills(id)
			} else {
				ResetSkills(id)


				g_Ready[id] = false


				if(sz_team == T){
					for(new i = 1; i <= g_maxplayers; i++){
						if(IsUserConnected(i) && get_user_team(i) == T)
							ColorChat(i, RED, "^1(Terrorist) ^3%s ^1: ^4.reset", sz_name)
					}
				} else {
					for(new i = 1; i <= g_maxplayers; i++){
						if(IsUserConnected(i) && get_user_team(i) == CT)
							ColorChat(i, BLUE, "^1(Counter-Terrorist) ^3%s ^1: ^4.reset", sz_name)
					}
				}

				return PLUGIN_HANDLED_MAIN
			}
		}
	}
	if(contain(sz_cmd, ".stats") != -1 || contain(sz_cmd, "/stats") != -1){
		if(!info[0]){
			if(GAME_MODE != MODE_PREGAME) {
				ShowMenuStats(id)
			} else {
				(g_showhud[id])?(g_showhud[id] = 0):(g_showhud[id] = 1)
			}
		} else {
			new player = cmd_target(id, info, 8)
			if(player){
				TNT_ShowMenuPlayerStats(id, player)
			} else {
				ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
			}
		}
	} else if(contain(sz_cmd, ".skills") != -1 || contain(sz_cmd, "/skills") != -1 ){
		new player = cmd_target(id, info, 8)
		if(!info[0]) {
			TNT_ShowUpgrade(id, id)
		} else if(player) {
			TNT_ShowUpgrade(id, player)
		} else {
			ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
		}
	} else if((equal(sz_cmd, ".reset") || equal(sz_cmd, "/reset")) && T <= sz_team <= CT) {
		ResetSkills(id)
		return PLUGIN_HANDLED_MAIN
	} else if(equal(sz_cmd, "/spec") || equal(sz_cmd, ".spec")){
		cmdSpectate(id)
	} else if(equal(sz_cmd, "/cam") || equal(sz_cmd, ".cam")){
		CameraChanger(id)
	} else if(equal(sz_cmd, "/whois") || equal(sz_cmd, ".whois")
		|| equal(sz_cmd, "/players") || equal(sz_cmd, ".players")
		|| equal(sz_cmd, "/users") || equal(sz_cmd, ".users")
		|| equal(sz_cmd, "/admin") || equal(sz_cmd, ".admin")
		|| equal(sz_cmd, "/admins") || equal(sz_cmd, ".admins")){
		WhoIs(id)
	} else if(equal(sz_cmd, "/first")|| equal(sz_cmd, ".first")
		|| equal(sz_cmd, "/firstperson") || equal(sz_cmd, ".firstperson")){
		g_cam[id] = true
		CameraChanger(id)
	} else if(equal(sz_cmd, "/third") || equal(sz_cmd, ".third")
		|| equal(sz_cmd, "/thirdperson") || equal(sz_cmd, ".thirdperson")){
		g_cam[id] = false
		CameraChanger(id)
	}
	else if(equal(sz_cmd, "/help") || equal(sz_cmd, ".help")){
		ShowHelp(id, x)
	} else if(contain(sz_cmd, ".setskills") != -1 || contain(sz_cmd, "/setskills") != -1){
		if(!is_user_admin(id)){
			ColorChat(id, RED, "^4[SJ] ^1- ^3You have no access to this command.")
			return PLUGIN_CONTINUE
		}
		new sz_skills[16], sz_buff[64], sz_name[32], i, sz_len

		parse(said, sz_buff, charsmax(sz_buff), sz_name, charsmax(sz_name), sz_skills, charsmax(sz_skills))

		if(strlen(said) < strlen(sz_cmd) + 2 || sz_skills[0] == EOS){
			for(i = 1; i <= UPGRADES; i++)
				sz_len += format(sz_buff[sz_len], charsmax(sz_buff) - sz_len, "<0-%d>", UpgradeMax[i])

			ColorChat(id, RED, "^4[SJ] ^1- ^4Usage: ^1/setskills <player> %s", sz_buff)
			ColorChat(id, RED, "^1This example sets GK skills for Player: ^4/setskills Player 00550")
			return PLUGIN_CONTINUE
		}

		new x = str_to_num(sz_skills)
		new sz_sk[UPGRADES + 1]
		for(i = UPGRADES; i; i--){
			if((sz_sk[i] = (x % 10)) > UpgradeMax[i]){
				ColorChat(id, RED, "^4[SJ] ^1- ^3Invalid skills!")
				return PLUGIN_CONTINUE
			}
			x /= 10
		}
		if(x < 0){
			ColorChat(id, RED, "^4[SJ] ^1- ^3Invalid skills!")
			return PLUGIN_CONTINUE
		} else {
			new player = cmd_target(id, info, 2 | 8)
			if(player){
				new sz_aname[32], sz_color[3]
				get_user_name(id, sz_aname, charsmax(sz_aname))
				get_user_name(player, sz_name, charsmax(sz_name))
				sz_len = 0
				for(i = UPGRADES; i; i--){
					PlayerUpgrades[player][i] = sz_sk[i]
				}
				for(i = 1; i <= UPGRADES; i++){
					if(PlayerUpgrades[player][i] == UpgradeMax[i]) {
						format(sz_color, charsmax(sz_color), "^3")
					} else if(PlayerUpgrades[player][i]) {
						format(sz_color, charsmax(sz_color), "^4")
					} else {
						format(sz_color, charsmax(sz_color), "^1")
					}
					sz_len += format(sz_buff[sz_len], charsmax(sz_buff) - sz_len, "%s %d", sz_color, PlayerUpgrades[player][i])
				}
				g_Credits[player] = 0

				ColorChat(0, RED, "^4[SJ] ^1- %s skills are set:%s ^1(ADMIN: %s)", sz_name, sz_buff, sz_aname)
			} else {
				ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_INVPLAYER")
			}
		}
	} else if(equal(sz_cmd, "/helpmenu") || equal(sz_cmd, ".helpmenu")){
		ShowHelp(id, x)
	}

	new sz_len = strlen(said)
	if(!sz_len)
		return PLUGIN_HANDLED_MAIN
	new sz_empty
	for(x = 0; x < sz_len; x++){
		if(said[x] != ' ' && said[x] != '%')
			sz_empty = 1
		if(said[x] == '%')
			said[x] = ' '
	}

	if(x == sz_len && !sz_empty)
		return PLUGIN_HANDLED_MAIN

	// no need for team another chat
	// for(new i = 1; i <= g_maxplayers; i++){
	// 	if(~IsUserConnected(i) || IsUserBot(i) || get_user_team(i) != sz_team)
	// 		continue

	// 	get_user_name(id, sz_name, 31)

	// 	if(sz_team == T) {
	// 		ColorChat(i, RED, "^1(Terrorist) ^3%s ^1: %s", sz_name, said)
	// 	} else if(sz_team == CT) {
	// 		ColorChat(i, BLUE, "^1(Counter-Terrorist) ^3%s ^1: %s", sz_name, said)
	// 	} else {
	// 		ColorChat(i, GREY, "^1(Spectator) ^3%s ^1: %s", sz_name, said)
	// 	}
	// }

	return PLUGIN_HANDLED_MAIN
}
public ResetSkills(id){
	for(new x = 1; x <= UPGRADES; x++)
		PlayerUpgrades[id][x] = 0

	ColorChat(id, GREEN, "^4[SJ]^1 - Your skills have been reset.");
	BuyUpgrade(id)
}

public CameraChanger(id){
	if(g_cam[id]){
		set_view(id, CAMERA_NONE)
		g_cam[id] = false
	} else {
		set_view(id, CAMERA_3RDPERSON)
		g_cam[id] = true
	}
}

public CameraChangerAdvanced(id){	
	query_client_cvar(id, "cam_snapto", "CameraChangerAdvancedHandler")
}

public CameraChangerAdvancedHandler(id, const cvar[], const value[]){

    //new Float:fValue = str_to_float(value)	
	
    if(str_to_num(value) != 0){
		client_cmd(id, "firstperson")
		client_cmd(id, "cam_snapto 0")
		g_cam2[id] = false
	}
	else
	{
		new ip[32]
		get_user_ip(0, ip, charsmax(ip))
		g_cam2[id] = true
		client_cmd(id, "cam_command 1")
		client_cmd(id, "cam_idealyaw 0")
		client_cmd(id, "cam_snapto 1")
		client_cmd(id, "thirdperson")
		client_print(id, print_chat, "[Lagless 3rd] You have to reconnect for the camera to work.")
		//client_cmd(id, "reconnect")
		//client_cmd(id, "wait;wait;wait;wait;wait;^"connect^" %s",ip)
		//engclient_cmd(id, "wait;wait;wait;wait;wait;^"connect^" %s",ip)
		client_cmd(id, "retry")
	}
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [UPGRADES]   	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public BuyUpgrade(id){
	if(!(T <= get_user_team(id) <= CT)){
		ShowMenuStatsSpec(id)
		return PLUGIN_HANDLED
	}
	new sz_temp[64], num[2], mTitle[101], x, sz_lang[32]
	format(mTitle, charsmax(mTitle), "\y%L", id, "SJ_SKILLS")
	menu_upgrade[id] = menu_create(mTitle, "Upgrade_Handler")
	for(x = 1; x <= UPGRADES; x++){
		format(sz_lang, charsmax(sz_lang), "SJ_%s", UpgradeTitles[x])
		if(PlayerUpgrades[id][x] == UpgradeMax[x]){
			format(sz_temp, charsmax(sz_temp), "\r%L \y-- \r%d \y/\r %d%s",
			id, sz_lang, UpgradeMax[x], UpgradeMax[x] , (x==UPGRADES)?("^n"):(""))
		}
		else if(g_Experience[id] >=  UpgradePrice[x][PlayerUpgrades[id][x]]){
			if(PlayerUpgrades[id][x] == 0){
				format(sz_temp, charsmax(sz_temp), "\d%L \y-- \d%d \y/\d %d \y($%d)%s",
				id, sz_lang, PlayerUpgrades[id][x], UpgradeMax[x],
				UpgradePrice[x][PlayerUpgrades[id][x]], (x==UPGRADES)?("^n"):(""))
			}
			else{
				format(sz_temp, charsmax(sz_temp), "\w%L \y-- \w%d \y/\w %d \y($%d)%s",
				id, sz_lang, PlayerUpgrades[id][x], UpgradeMax[x],
				UpgradePrice[x][PlayerUpgrades[id][x]], (x==UPGRADES)?("^n"):(""))
			}
		}
		else{
			if(PlayerUpgrades[id][x] == 0){
				format(sz_temp, charsmax(sz_temp), "\d%L \y-- \d%d / %d \d($%d)%s",
				id, sz_lang, PlayerUpgrades[id][x], UpgradeMax[x],
				UpgradePrice[x][PlayerUpgrades[id][x]], (x==UPGRADES)?("^n"):(""))
			}
			else{
				format(sz_temp, charsmax(sz_temp), "\w%L \y-- \w%d / %d \d($%d)%s",
				id, sz_lang, PlayerUpgrades[id][x], UpgradeMax[x],
				UpgradePrice[x][PlayerUpgrades[id][x]], (x==UPGRADES)?("^n"):(""))
			}
		}

		format(num, 1, "%i", x)
		menu_additem(menu_upgrade[id], sz_temp, num)
	}

	//menu_addblank(menu_upgrade[id], (UPGRADES+1))
	menu_additem(menu_upgrade[id],"\yTop Stats")
	menu_additem(menu_upgrade[id],"\yReset")
	menu_additem(menu_upgrade[id],"\yPlayers Info")
	menu_addblank(menu_upgrade[id], 0)
	menu_additem(menu_upgrade[id],"\yLagless 3rd Camera \d(requires reconnect)")
	menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu_upgrade[id],MPROP_PERPAGE,0)
	menu_display(id, menu_upgrade[id], 0)

	return PLUGIN_HANDLED
}

public Upgrade_Handler(id, menu, item){

	if(item == MENU_EXIT || !(T <= get_user_team(id) <= CT)){
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if(item == 8){
		CameraChangerAdvanced(id)
		return PLUGIN_HANDLED
		}
	
	if(item == 7){
		WhoIs(id)
		return PLUGIN_HANDLED
		}
	
	if(item == 6){
		ResetSkills(id)
		return PLUGIN_HANDLED
		}
		
	if(item == 5){
		if(GAME_MODE != MODE_PREGAME) {
			ShowMenuStats(id)
		} else {
			(g_showhud[id])?(g_showhud[id] = 0):(g_showhud[id] = 1)
		}
		return PLUGIN_HANDLED
	}
	item++

	if(PlayerUpgrades[id][item] != UpgradeMax[item]){
		if(g_Experience[id] < UpgradePrice[item][PlayerUpgrades[id][item]]){
			return PLUGIN_HANDLED
		} else {
			PlayerUpgrades[id][item]++
			if(PlayerUpgrades[id][item] == UpgradeMax[item])
				play_wav(id, snd_levelup)
				
			g_Experience[id] -= UpgradePrice[item][PlayerUpgrades[id][item]]
			//cs_set_user_money(id, g_Experience[id])

			switch(item){
				case STA: {
					set_pev(id, pev_max_health, float(BASE_HP + PlayerUpgrades[id][item] * AMOUNT_STA))
					
					/*
					if(PlayerUpgrades[id][STA] == UpgradeMax[STA]){
						ColorChat(id, GREEN, "^4[SJ]^1 - To prevent stamina upgrade abuse, HP will be added after respawn.")
					}
					*/
					
				}
				case AGI: {
					if(!g_sprint[id]){
						set_speedchange(id)
					}
				}
			}
		}

		BuyUpgrade(id)
	}

	return PLUGIN_HANDLED
}

public ShowUpgrade(id, player){
	new sz_temp[32], sz_level[64], sz_name[32]
	get_user_name(player, sz_name, 31)
	format(sz_temp, charsmax(sz_temp), "%L^n\w%s", id, "SJ_SKILLS", sz_name)

	menu_upgrade[id] = menu_create(sz_temp, "Done_Handler")
	new x, sz_color[2], num[1], sz_lang[32]
	for(x = 1; x <= UPGRADES; x++){
		format(sz_lang, charsmax(sz_lang), "SJ_%s", UpgradeTitles[x])
		if(PlayerUpgrades[player][x]){
			format(sz_color, 2, "\w")
			if(PlayerUpgrades[player][x] == UpgradeMax[x])
				format(sz_color, 2, "\r")
		} else {
			format(sz_color, 2, "\d")
		}
		if(x < UPGRADES){
			format(sz_level, charsmax(sz_level), "%s%L \y-- %s%i",
			sz_color, id, sz_lang, sz_color, PlayerUpgrades[player][x])
		} else {
			format(sz_level, charsmax(sz_level), "%s%L \y-- %s%i^n ",
			sz_color, id, sz_lang, sz_color, PlayerUpgrades[player][x])
		}
		format(num, 1, "%i", x)
		menu_additem(menu_upgrade[id], sz_level, num, 0)
	}


	menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NEVER)
	menu_display(id, menu_upgrade[id], 0)
	menu_upgrade[id] =  player

	return PLUGIN_CONTINUE
}

public TNT_ShowUpgrade(id, player){
	if(g_regtype == 2){
		if(!equal(g_userClanName[id], g_userClanName[player])){
			ColorChat(id, RED, "[SJ] ^1- ^3This player is not member of your clan!")
			return PLUGIN_HANDLED
		}
	}
	new sz_temp[32], sz_level[64], sz_name[32], sz_skillInfo[32]
	get_user_name(player, sz_name, 31)
	format(sz_temp, 31,"Player Skills^n\w%s", sz_name)

	menu_upgrade[id] = menu_create(sz_temp, "TNT_ShowUpgrade_Handler")
	new x, sz_color[3], num[2], sz_lang[32]
	for(x = 1; x <= UPGRADES; x++){
		switch(x){
			case STA:{
				format(sz_skillInfo, charsmax(sz_skillInfo), "%d HP", BASE_HP + (PlayerUpgrades[player][x] * AMOUNT_STA))
			}
			case STR:{
				format(sz_skillInfo, charsmax(sz_skillInfo), "%d u/sec, +%d%% smack", get_pcvar_num(cv_kick) + (PlayerUpgrades[id][x] * AMOUNT_STR), (PlayerUpgrades[player][x] * AMOUNT_STR) / 10)
			}
			case AGI:{
				format(sz_skillInfo, charsmax(sz_skillInfo), "%d u/sec", floatround(BASE_SPEED) + (PlayerUpgrades[player][x] * AMOUNT_AGI))
			}
			case DEX:{
				new szSmack = (PlayerUpgrades[id][x]<UpgradeMax[x])?(PlayerUpgrades[id][x] * AMOUNT_DEX + 1):(100)
				new szTemp[10], szCvarTemp[10]
				num_to_str(szSmack, szTemp, charsmax(szTemp))
				num_to_str(get_pcvar_num(cv_smack), szCvarTemp, charsmax(szCvarTemp))
				new Float:szCatch = str_to_float(szTemp) / (str_to_float(szCvarTemp) / 100.0)
				format(sz_skillInfo, charsmax(sz_skillInfo), "%0.f%% catch", szCatch>100.0?100.0:szCatch)
			}
			case DIS:{
				format(sz_skillInfo, charsmax(sz_skillInfo), "%d%%", (PlayerUpgrades[player][x])?(BASE_DISARM + PlayerUpgrades[player][x] * AMOUNT_DIS):(0))
			}
		}
		format(sz_lang, charsmax(sz_lang), "SJ_%s", UpgradeTitles[x])
		if(PlayerUpgrades[player][x]){
			format(sz_color, 2, "\w")
			if(PlayerUpgrades[player][x] == UpgradeMax[x])
				format(sz_color, 2, "\r")
		}
		else
			format(sz_color, 2, "\d")
		if(x < UPGRADES)
			format(sz_level,63,"%s%L \y-- %s%i \d[%s]", sz_color, id, sz_lang, sz_color, PlayerUpgrades[player][x], sz_skillInfo)
		else
			format(sz_level,63,"%s%L \y-- %s%i \d[%s]^n ", sz_color, id, sz_lang, sz_color, PlayerUpgrades[player][x], sz_skillInfo)
		format(num, 1,"%i",x)
		menu_additem(menu_upgrade[id], sz_level, num, 0)
	}


	if((T <= get_user_team(id) <= CT) && player == id){
		switch(GAME_MODE){
			case MODE_PREGAME:{
				g_Ready[id]?menu_additem(menu_upgrade[id], "\rWait"):menu_additem(menu_upgrade[id], "\yReady")
				menu_additem(menu_upgrade[id], "\ySet as default")
			}
			default:{
				menu_additem(menu_upgrade[id], "\yTop stats")
			}
		}
	}
	else{
		menu_additem(menu_upgrade[id], "\yTop stats")
		menu_additem(menu_upgrade[id], "\yPlayer stats")
	}

	menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NEVER)
	menu_display(id, menu_upgrade[id], 0)
	menu_upgrade[id] =  player

	return PLUGIN_CONTINUE
}

public TNT_ShowUpgrade_Handler(id, menu, item){
	if(item == UPGRADES){
		if((T <= get_user_team(id) <= CT) && menu_upgrade[id] == id){
			switch(GAME_MODE){
				case MODE_PREGAME:{
					(g_Ready[id])?(g_Ready[id]=false):(g_Ready[id]=true)
					TNT_ShowUpgrade(id, id)
				}
				default:{
					ShowMenuStats(id)
				}
			}
		}
		else{
			ShowMenuStats(id)
		}
	}
	else if(item == UPGRADES + 1){
		if((T <= get_user_team(id) <= CT) && menu_upgrade[id] == id){
			switch(GAME_MODE){
				case MODE_PREGAME:{
					saveDefaultSkills(id)
					TNT_ShowUpgrade(id, id)
				}
				default:{}
			}
		}
		else{
			TNT_ShowMenuPlayerStats(id, menu_upgrade[id])
		}
	}
	return PLUGIN_HANDLED
}

stock get_user_used_credits(id){
	new k = 0
	for(new i = 1; i <= UPGRADES; i++){
		k += PlayerUpgrades[id][i]
		if(PlayerUpgrades[id][i] == UpgradeMax[i])
			k++
	}
	return k
}

public Done_Handler(id, menu, item){
	return PLUGIN_HANDLED
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|        [TURBO]	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public Meter(){
	new id, target
	new sprintText[256], sec
	new sz_temp[1024]
	new sz_len, x
	new szTitle[32]
	new ndir = -(DIRECTIONS)
	new i
	new Float:speedh
	new Float:velocity[3]
	new sz_score = get_pcvar_num(cv_score[0])
	
	for(id = 1; id <= g_maxplayers; id++){
		sec = seconds[id]
		if(~IsUserAlive(id))
			continue
		for(i = 0; i <= g_count_balls; i++)
			if(id == g_ballholder[i])
				break

		
		if(i != g_count_balls + 1){
			if(GAME_MODE != MODE_PREGAME ){
				set_hudmessage(0, 255, 0, -1.0, 0.75, 0, 0.0, 0.6, 0.0, 0.0, 4)
				sz_len = format(sprintText, charsmax(sprintText), " - CURVE - ^n[", id)

				for(x = DIRECTIONS; x >= ndir; x--){
					(x==0)?
					(sz_len += format(sprintText[sz_len], charsmax(sprintText) - sz_len, "%s%s",
					direction[i]==x?"0":"+", x==ndir?"]":"  ")):
					(sz_len += format(sprintText[sz_len], charsmax(sprintText) - sz_len, "%s%s",
					direction[i]==x?"0":"=", x==ndir?"]":"  "))
				}

				show_hudmessage(id, "%s", sprintText)
			}
		}
		

		target = pev(id, pev_iuser1) == 4 ? pev(id, pev_iuser2) : id
		pev(target, pev_velocity, velocity)

		speedh = floatsqroot(floatpower(velocity[0], 2.0) + floatpower(velocity[1], 2.0))

		set_hudmessage(0, 255, 0, -1.0, 0.85, 0, 0.0, 0.6, 0.0, 0.0, 3)

		//format(szTitle, charsmax(szTitle), "- SPEED: %d -", get_speed(id))
		format(szTitle, charsmax(szTitle), "- SPEED: %3.1f - ", speedh)

		if(sec > 30){
			sec -= get_pcvar_num(cv_turbo)
			format(sprintText, charsmax(sprintText), "  %s ^n[==============]^n^n- type /help -", szTitle)
			set_speedchange(id)
			g_sprint[id] = 0
		} else if(sec >= 0 && sec < 30 && g_sprint[id]) {
			sec += 2
			set_speedchange(id, 100.0)
		}

		switch(sec){
			case 0:		format(sprintText, charsmax(sprintText), "  %s ^n[||| - SPRINT - |||]^n^n- type /help -", szTitle)
			case 2:		format(sprintText, charsmax(sprintText), "  %s ^n[|||||||||||||=]^n^n- type /help -", szTitle)
			case 4:		format(sprintText, charsmax(sprintText), "  %s ^n[||||||||||||==]^n^n- type /help -", szTitle)
			case 6:		format(sprintText, charsmax(sprintText), "  %s ^n[|||||||||||===]^n^n- type /help -", szTitle)
			case 8:		format(sprintText, charsmax(sprintText), "  %s ^n[||||||||||====]^n^n- type /help -", szTitle)
			case 10:	format(sprintText, charsmax(sprintText), "  %s ^n[|||||||||=====]^n^n- type /help -", szTitle)
			case 12:	format(sprintText, charsmax(sprintText), "  %s ^n[||||||||======]^n^n- type /help -", szTitle)
			case 14:	format(sprintText, charsmax(sprintText), "  %s ^n[|||||||=======]^n^n- type /help -", szTitle)
			case 16:	format(sprintText, charsmax(sprintText), "  %s ^n[||||||========]^n^n- type /help -", szTitle)
			case 18:	format(sprintText, charsmax(sprintText), "  %s ^n[|||||=========]^n^n- type /help -", szTitle)
			case 20:	format(sprintText, charsmax(sprintText), "  %s ^n[||||==========]^n^n- type /help -", szTitle)
			case 22:	format(sprintText, charsmax(sprintText), "  %s ^n[|||===========]^n^n- type /help -", szTitle)
			case 24:	format(sprintText, charsmax(sprintText), "  %s ^n[||============]^n^n- type /help -", szTitle)
			case 26:	format(sprintText, charsmax(sprintText), "  %s ^n[|=============]^n^n- type /help -", szTitle)
			case 28:	format(sprintText, charsmax(sprintText), "  %s ^n[==============]^n^n- type /help -", szTitle)
			case 30: {
				format(sprintText, charsmax(sprintText), "  %s ^n[==============]^n^n- type /help -", szTitle)
				sec = 92
			}
			case 32: sec = 0
		}

		seconds[id] = sec
		show_hudmessage(id, "%s", sprintText)
		
		if(!winner){
			format(sz_temp, charsmax(sz_temp), " %L ", id,
			(sz_score%10 == 1 && sz_score%100 != 11)?
			"SJ_GOALLIM1":"SJ_GOALLIM", sz_score)
			set_hudmessage(20, 255, 20, 1.0, 0.0, 0, 1.0, 1.5, 0.1, 0.1, 1)
			show_hudmessage(id, "%s^n^n^n^n^n^n%s", sz_temp, g_temp)
		}
	}
}

set_speedchange(id, Float:speed = 0.0){
	new i
	for(i = 0; i <= g_count_balls; i++)
		if(id == g_ballholder[i])
			break

	new Float:agi = float((PlayerUpgrades[id][AGI] * AMOUNT_AGI) +
	((i <= g_count_balls)?(AMOUNT_POWERPLAY * PowerPlay[i] * 2):0))
	agi += (BASE_SPEED + speed)
	entity_set_float(id, EV_FL_maxspeed, agi)
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [ENVIROMENT]	| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public CreateGoalNets(){
	new endzone
	new Float:MinBox[3], Float:MaxBox[3]
	for(new x = 1; x < 3; x++){
		endzone = create_entity("info_target")
		if(endzone){
			MinBox[0] = -25.0;	MinBox[1] = -145.0;	MinBox[2] = -36.0
			MaxBox[0] =  25.0;	MaxBox[1] =  145.0;	MaxBox[2] =  70.0
			entity_set_string(endzone, EV_SZ_classname, "soccerjam_goalnet")
			entity_set_model(endzone, "models/chick.mdl")
			entity_set_int(endzone, EV_INT_solid, SOLID_BBOX)
			entity_set_int(endzone, EV_INT_movetype, MOVETYPE_NONE)

			entity_set_vector(endzone, EV_VEC_mins, MinBox)
			entity_set_vector(endzone, EV_VEC_maxs, MaxBox)

			(x==1)?	(entity_set_origin(endzone, Float:{ 2110.0, 0.0, 1604.0 })):
				(entity_set_origin(endzone, Float:{-2550.0, 0.0, 1604.0 }))

			entity_set_int(endzone, EV_INT_team, x)
			set_entity_visibility(endzone, 0)
			GoalEnt[x] = endzone
		}
	}
}

CreateWall() {
	new wall = create_entity("func_wall")
	if(wall)
	{
		new Float:orig[3]
		new Float:MinBox[3], Float:MaxBox[3]
		entity_set_string(wall,EV_SZ_classname,"Blocker")
		entity_set_model(wall, "models/chick.mdl")

		entity_set_int(wall, EV_INT_solid, SOLID_BBOX)
		entity_set_int(wall, EV_INT_movetype, MOVETYPE_NONE)

		MinBox[0] = -50.0;	MinBox[1] = -75.0;	MinBox[2] = -100.0
		MaxBox[0] =  50.0;	MaxBox[1] =  75.0;	MaxBox[2] =  100.0

		entity_set_vector(wall, EV_VEC_mins, MinBox)
		entity_set_vector(wall, EV_VEC_maxs, MaxBox)

		orig[0] = 1986.0
		orig[1] = -1503.0
		orig[2] = 2250.0
		entity_set_origin(wall,orig)
		set_entity_visibility(wall, 0)
	}
}

CreateWall2() {
	new wall = create_entity("func_wall")
	if(wall)
	{
		new Float:orig[3]
		new Float:MinBox[3], Float:MaxBox[3]
		entity_set_string(wall,EV_SZ_classname,"Blocker")
		entity_set_model(wall, "models/chick.mdl")

		entity_set_int(wall, EV_INT_solid, SOLID_BBOX)
		entity_set_int(wall, EV_INT_movetype, MOVETYPE_NONE)

		MinBox[0] = -75.0;	MinBox[1] = -75.0;	MinBox[2] = -100.0
		MaxBox[0] =  75.0;	MaxBox[1] =  75.0;	MaxBox[2] =  100.0

		entity_set_vector(wall, EV_VEC_mins, MinBox)
		entity_set_vector(wall, EV_VEC_maxs, MaxBox)

		orig[0] = -2445.0
		orig[1] = -1512.0
		orig[2] = 2250.0
		entity_set_origin(wall,orig)
		set_entity_visibility(wall, 0)
	}
}

CreateWall3() {
	new wall = create_entity("func_wall")
	if(wall)
	{
		new Float:orig[3]
		new Float:MinBox[3], Float:MaxBox[3]
		entity_set_string(wall,EV_SZ_classname,"Blocker")
		entity_set_model(wall, "models/chick.mdl")

		entity_set_int(wall, EV_INT_solid, SOLID_BBOX)
		entity_set_int(wall, EV_INT_movetype, MOVETYPE_NONE)

		MinBox[0] = -72.0;	MinBox[1] = -100.0;	MinBox[2] = -72.0
		MaxBox[0] =  72.0;	MaxBox[1] =  100.0;	MaxBox[2] =  72.0

		entity_set_vector(wall, EV_VEC_mins, MinBox)
		entity_set_vector(wall, EV_VEC_maxs, MaxBox)

		orig[0] = 2355.0
		orig[1] = 1696.0
		orig[2] = 1604.0
		entity_set_origin(wall,orig)
		set_entity_visibility(wall, 0)
	}
}

stock CreateMascot(team){
	new mascot = create_entity("info_target")
	if(mascot){
		entity_set_string(mascot, EV_SZ_classname,"Mascot")
		entity_set_model(mascot, mdl_mascots[team])
		Mascots[team] = mascot

		entity_set_int(mascot, EV_INT_solid, SOLID_NOT)
		entity_set_int(mascot, EV_INT_movetype, MOVETYPE_NONE)
		entity_set_int(mascot, EV_INT_team, team)

		entity_set_vector(mascot, EV_VEC_mins, Float:{ -16.0, -16.0, -72.0 })
		entity_set_vector(mascot, EV_VEC_maxs, Float:{ 16.0, 16.0, 72.0 })

		entity_set_origin(mascot, MascotsOrigins)
		entity_set_float(mascot, EV_FL_animtime,2.0)
		entity_set_float(mascot, EV_FL_framerate,1.0)
		entity_set_int(mascot, EV_INT_sequence,0)

		if(team == 2)
			entity_set_byte(mascot, EV_BYTE_controller1, 115)

		entity_set_vector(mascot, EV_VEC_angles, MascotsAngles)
		entity_set_float(mascot, EV_FL_nextthink, halflife_time() + 1.0)
	}
}

public think_Alien(mascot){

	if((!g_count_balls && (GAME_MODE == MODE_PREGAME)) || get_pcvar_num(cv_pause)){
		set_pev(mascot, pev_nextthink, halflife_time() + get_pcvar_float(cv_alienthink))
		return PLUGIN_HANDLED
	}
	new team = pev(mascot, pev_team)
	new distance = get_pcvar_num(cv_alienzone)
	new indist[32], inNum, i
	new bool:sz_nogk
	if(get_pcvar_num(cv_lamedist) > 0)
		sz_nogk = true
	new id, sz_dist, sz_team, Float:sz_gametime = get_gametime()
	for(id = 1; id <= g_maxplayers; id++){
		if(IsUserAlive(id)){
			sz_team = get_user_team(id)
			sz_dist = get_entity_distance(id, mascot)
			if(GAME_TYPE == TYPE_PUBLIC && get_pcvar_num(cv_timer)){
				AlienTimer(id)
			}
			if(sz_dist < distance){
				if(sz_team != team ){
					for(i = 0; i <= g_count_balls; i++){
						if(id == g_ballholder[i]){
							TerminatePlayer(id, mascot, team, float(pev(id, pev_health)) + 1.0, TeamColors[team])

							set_pev(mascot, pev_nextthink, halflife_time() + get_pcvar_float(cv_alienthink))

							return PLUGIN_HANDLED
						}
					}
					indist[inNum++] = id
				}
			}
			if(sz_dist < 600) {
					g_nogk[team] = false
					sz_nogk = false
				}
			if(sz_team == team){
				if(GAME_TYPE == TYPE_PUBLIC && (sz_gametime - GoalyCheckDelay[id] >= MAX_GOALY_DELAY) && get_pcvar_num(cv_regen)){
					goaly_checker(id)
				}
			}
		}
	}
	g_nogk[team] = sz_nogk
	new rnd = random_num(0, (inNum - 1))
	new chosen = indist[rnd]
	if(chosen){
		new Float:sz_min = get_pcvar_float(cv_alienmin), Float:sz_max = get_pcvar_float(cv_alienmax)
		if(sz_min < 0 || sz_max < 0){
			sz_max = 12.0
			sz_min = 8.0
		}
		set_task(0.5, "Done_Handler", -5311 + chosen)
		TerminatePlayer(chosen, mascot, team, random_float(sz_min, sz_max), TeamColors[team])
	}

	set_pev(mascot, pev_nextthink, halflife_time() + get_pcvar_float(cv_alienthink))
	return PLUGIN_HANDLED
}

// Goaly Points System

goaly_checker(id){
	new hp = get_user_health(id)
	new diff = BASE_HP + (PlayerUpgrades[id][STA] * AMOUNT_STA) - hp
	if(hp <= BASE_HP + (PlayerUpgrades[id][STA] * AMOUNT_STA)) {
		if(diff < HEALTH_REGEN_AMOUNT) {
			set_user_health( id, hp + (BASE_HP + (PlayerUpgrades[id][STA] * AMOUNT_STA) - hp))
		} else {
			set_user_health(id, hp + HEALTH_REGEN_AMOUNT)
		}
	}
}

AlienTimer(id){

	message_begin(MSG_ONE_UNRELIABLE, msg_roundtime, _, id)
	write_short(abs(g_Timeleft) + 1)
	message_end()
	
}


public pfn_keyvalue(entid){
	if(!RunOnce){
		RunOnce = true

		new entity = create_entity("game_player_equip")
		if(entity){
			DispatchKeyValue(entity, "weapon_knife", "1")
			DispatchKeyValue(entity, "targetname", "roundstart")
			DispatchSpawn(entity)
		}
	}
	new classname[32], key[32], value[32]
	copy_keyvalue(classname, 31, key, 31, value, 31)

	new temp_origins[3][10], x, team
	new temp_angles[3][10]

	if(equal(key, "classname") && equal(value, "soccerjam_goalnet"))
		DispatchKeyValue("classname", "func_wall")

	if(equal(classname, "game_player_equip")){
		remove_entity(entid)
	} else if(equal(classname, "func_wall")) {
		if(equal(key, "team")){
			team = str_to_num(value)
			if(team == 1 || team == 2){
				GoalEnt[team] = entid
				set_task(1.0, "FinalizeGoalNet", team)
			}
		}
	} else if(equal(classname, "soccerjam_mascot")) {
		if(equal(key, "team")){
			team = str_to_num(value)
			CreateMascot(team)
		} else if(equal(key, "origin")) {
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x = 0; x < 3; x++)
				MascotsOrigins[x] = floatstr(temp_origins[x])
		} else if(equal(key, "angles")) {
			parse(value, temp_angles[0], 9, temp_angles[1], 9, temp_angles[2], 9)
			for(x = 0; x < 3; x++)
				MascotsAngles[x] = floatstr(temp_angles[x])
		}
	} else if(equal(classname, "soccerjam_teamball")) {
		if(equal(key, "team")){
			team = str_to_num(value)
			for(x = 0; x < 3; x++){
				TeamBallOrigins[team][x] = TEMP_TeamBallOrigins[x]
				TeamPossOrigins[team][x] = TEMP_TeamBallOrigins[x]
			}

		} else if(equal(key, "origin")) {
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x = 0; x < 3; x++)
				TEMP_TeamBallOrigins[x] = floatstr(temp_origins[x])
		}
	} else if(equal(classname, "soccerjam_ballspawn")) {
		if(equal(key, "origin")){
			is_kickball = 1
			new szOrigin[3][10]
			parse(value, szOrigin[0], 9, szOrigin[1], 9, szOrigin[2], 9)

			BallSpawnOrigin[0] = floatstr(szOrigin[0])
			BallSpawnOrigin[1] = floatstr(szOrigin[1])
			BallSpawnOrigin[2] = floatstr(szOrigin[2]) + 10.0
		}
	}
}

public FinalizeGoalNet(team){
	new goalnet = GoalEnt[team]
	entity_set_string(goalnet, EV_SZ_classname, "soccerjam_goalnet")
	entity_set_int(goalnet, EV_INT_team, team)
	set_entity_visibility(goalnet, 0)
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      	  [MISC]  	| **************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public PostGame(){
	format(g_TempTeamNames[T], 31, TeamNames[T])
	format(g_TempTeamNames[CT], 31, TeamNames[CT])

	if(GAME_TYPE == TYPE_PUBLIC){
		set_pcvar_num(cv_score[0], ScoreLim[31])
		
		for(new id = 1; id <= g_maxplayers; id++){
			g_showhud[id] = 1
			//g_PlayerDeaths[id] = 0
			for(new x = 1; x <= UPGRADES; x++)
				PlayerUpgrades[id][x] = 0
		}
		g_current_match = get_systime()
		//set_task(30.0, "VoteStart")
		
	}
	
	server_cmd("mp_timelimit 0")
}

public CleanUp(){
	new m, x

	for(x = 1; x <= RECORDS; x++) {
		TopPlayer[0][x] = 0
		TopPlayer[1][x] = 0
		TeamRecord[T][x] = 0
		TeamRecord[CT][x] = 0
		format(TopPlayerName[x], 31, "")
	}

	for(x = 1; x <= g_maxplayers; x++) {
		GoalyPoints[x] = 0
		g_Ready[x] = false
		g_Experience[x] = 0
		g_Credits[x] = 0
		freeze_player[x] = false
		//g_PlayerDeaths[x] = 0
		g_MVP_points[x] = 0
		for(m = 1; m <= RECORDS; m++)
			MadeRecord[x][m] = 0
	}
	for(x = 0; x < 64; x++){
		format(g_list_authid[x], 35, "")
	}

	TrieClear(gTrieStats)

	g_Time[0] = 0

	format(g_MVP_name, charsmax(g_MVP_name), "")
	g_MVP = 0
	//g_MVPwebId = 0

	g_current_match = get_systime()
	winner = 0
	timer = COUNTDOWN_TIME
	g_Timeleft = (get_pcvar_num(cv_time) * 60)
	set_pcvar_num(cv_score[T], 0)
	set_pcvar_num(cv_score[CT], 0)

	for(x = 0; x <= g_count_balls; x++) {
		PowerPlay[x] = 0
	}
}

public FWD_GameDescription(){
	new sz_temp[32]
	if(GAME_TYPE == TYPE_PUBLIC){
		if(get_pcvar_num(cv_description)){
			format(sz_temp, charsmax(sz_temp), "%s - %d : %d - %s",
			TeamNames[T], get_pcvar_num(cv_score[T]), get_pcvar_num(cv_score[CT]), TeamNames[CT])
		} else {
			format(sz_temp, charsmax(sz_temp), "SoccerJam+")
		}
	}
	forward_return(FMV_STRING, sz_temp)
	return FMRES_SUPERCEDE
}

public FWD_CmdStart( id, uc_handle, seed ) {
    if(get_uc(uc_handle, UC_Impulse) == 100) { // change 201 to your impulse.
    	if(g_showhud[id]){
			(g_showhud[id]==1)?(g_showhud[id] = 2):(g_showhud[id] = 1)
		}
    }
    return FMRES_IGNORED;
}

public FWD_AddToFullpack(es_handle, e, id, host, flags, player){
	if(id && player && IsUserAlive(id) && SideJump[id] == 2){
		if((get_gametime() - SideJumpDelay[id]) > 0.1){
			SideJump[id] = 0
		}
	}
	return FMRES_IGNORED
}

public FwdImpulse_201( const id ) {
	if( get_pcvar_num( cv_blockspray ) ) {
		//if( is_user_alive( id ) )
			//client_print( id, print_center, "%L", id, "DR_BLOCK_SPRAY" );
		
		return PLUGIN_HANDLED_MAIN;
	}
	
	return PLUGIN_CONTINUE;
}

public client_connect(id){
	set_user_info(id, "_vgui_menus", "0")

	g_bSpec[id] = false
	g_bSpecAccess[id] = false
	g_vOrigin[id] = {0, 0, 0}
	g_iAFKTime[id] = 0
	g_iWarn[id] = 0
}

public client_putinserver(id){
	cs_set_user_team(id, CS_TEAM_SPECTATOR) //prevent spec-doublechat bug
	g_iCount[id] = 0 
	ClearUserAlive(id)
	SetUserConnected(id)
	if(is_user_bot(id) || is_user_hltv(id) || !id){
		SetUserBot(id)
		return PLUGIN_HANDLED
	}

	//g_cam[id] = false
	seconds[id] = 0
	g_sprint[id] = 0
	PressedAction[id] = 0
	g_Experience[id] = 0
	//g_showhelp[id] = false
	
	/*
	for(new i = 1; i <= UPGRADES; i++){
		PlayerUpgrades[i][STR] = 0
		PlayerUpgrades[i][DEX] = UpgradeMax[DEX]
		PlayerUpgrades[i][AGI] = UpgradeMax[AGI]
		PlayerUpgrades[i][STA] = UpgradeMax[STA]
		PlayerUpgrades[i][DIS] = UpgradeMax[DIS]
	}
	*/
	
	PlayerUpgrades[id][STR] = 0
	PlayerUpgrades[id][DEX] = UpgradeMax[DEX]
	PlayerUpgrades[id][AGI] = UpgradeMax[AGI]
	PlayerUpgrades[id][STA] = UpgradeMax[STA]
	PlayerUpgrades[id][DIS] = UpgradeMax[DIS]
	
	for(new i = 1; i <= RECORDS; i++){
		MadeRecord[id][i] = 0
		TempRecord[id][i] = 0
		if(TopPlayer[0][i] == id)
			TopPlayer[0][i] = 0
	}

	
	get_user_authid(id, g_authid[id], 35)
	get_user_ip(id, g_userip[id], 31, 1)

	format(g_mvprank[id], 31, "")

	g_userClanId[id] = 0
	format(g_userClanName[id], 31, "")
	g_userNationalId[id] = 0
	format(g_userNationalName[id], 31, "")

	format(g_userCountry[id], 63, "")
	format(g_userCountry_2[id], 2, "")
	format(g_userCountry_3[id], 3, "")
	format(g_userCity[id], 45,  "")
	if(contain(g_userip[id], "192.168.")!=-1 || equal(g_userip[id], "127.0.0.1") || equal(g_userip[id], "loopback")){
		format(g_userCountry[id], 63, "")
		format(g_userCountry_2[id], 2, "")
		format(g_userCountry_3[id], 3, "")
		format(g_userCity[id], 45,  "")
	} else {
		geoip_country(g_userip[id], g_userCountry[id], 63)
		geoip_code2_ex(g_userip[id], g_userCountry_2[id])
		geoip_code3_ex(g_userip[id], g_userCountry_3[id])
		geoip_city(g_userip[id], g_userCity[id], 45)

		if(contain(g_userCity[id], "error") != -1 || g_userCity[id][0] == 0) {
			format(g_userCity[id], 45, "")
		} else if(contain(g_userCity[id], "Moscow") != -1) {
			format(g_userCountry[id], 63, "Russia")
			format(g_userCountry_2[id], 2, "RU")
			format(g_userCountry_3[id], 3, "RUS")
		}

		if(contain(g_userCountry_2[id], "erro") != -1 || g_userCountry_2[id][0] == 0 || contain(g_userCountry_3[id], "erro") != -1 || g_userCountry_3[id][0] == 0){
			format(g_userCountry[id], 63, "")
			format(g_userCountry_2[id], 2, "")
			format(g_userCountry_3[id], 3, "")
		}
	}

	new sz_temp[7], sz_name[32]
	get_user_name(id, sz_name, charsmax(sz_name))
	if(equal(g_userCountry_3[id], "")){
		if(contain(g_userip[id], "192.168.") != -1 || equal(g_userip[id], "127.0.0.1") || equal(g_userip[id], "loopback")){
			format(sz_temp, 6, "[LAN] ")
		} else {
			format(sz_temp, 6, "")
		}
	} else {
		format(sz_temp, 6, "[%s] ", g_userCountry_3[id])
	}


	ColorChat(0, GREY, "^4-> ^3%s^1%s%s ^4has joined", sz_temp, sz_name, is_user_admin(id)?" ^3[ADMIN]":"")

	remove_task(id - 8122)
	
/*
	if(!task_exists(97753)){
		//set_task(5.0, "sql_updateServerInfo", 97753)
	}
*/
	set_task(get_pcvar_float(cv_resptime), "RespawnPlayer", id + 412)

	//client_cmd(id, "cl_forwardspeed 1000")
	//client_cmd(id, "cl_backspeed 1000")
	//client_cmd(id, "cl_sidespeed 1000")
	client_cmd(id, "fakelag 0; fakeloss 0")

	g_bValid[id] = bool:!is_user_hltv(id)
	set_task(0.5, "load_stats", id)
	set_task(0.1, "WhoIs", id)
	return PLUGIN_HANDLED
}

/*
public CvarSnapCheck(id){
	query_client_cvar(id, "cam_snapto", "SnapCheck")
}
public CameraCheck(id, const cvar[], const value[]){

	if(str_to_num(value) != 0){
		g_cam2[id] = true
	}
	else
	{
	g_cam2[id] = false
	}
}
*/

public WhoIs(id){
	new plist[2048]
	new len = 0
	new title[32]
	new ip[22], buffname[64], sz_name[64]

	get_user_name(0, buffname, 63)

	for(new x = 0, k = 0; x < 64; x++){	// replace invalid symbols (cannot be performed in MOTD)
		if(buffname[x] > 0x7F || buffname[x] < 0)
			continue
		sz_name[k] = buffname[x]
		k++
	}

	get_user_ip(0, ip, charsmax(ip))

	format(title, charsmax(title), "Players List")
	
/*
	len += format(plist[len], charsmax(plist) - len, "<head><link rel='stylesheet' type='text/css' href='http://sj-pro.com/css/flags.css'></head>")
	len += format(plist[len], charsmax(plist) - len, "<body text=#FFFFFF bgcolor=#000000 background=^"http://sj-pro.com/img/main.jpg^"><center>")
	len += format(plist[len], charsmax(plist) - len, "<font color=#FFB000 size=3><b>%s<br>%s<br><br>", sz_name, ip)
	len += format(plist[len], charsmax(plist) - len, "<table border=0 width=90%% cellpadding=0 cellspacing=6>")
	len += format(plist[len], charsmax(plist) - len, "<tr style='color:green;font-weight:bold;text-decoration:underline;'><td>PLAYER<td>TEAM<td>LOCATION")
*/

	//len += format(plist[len], charsmax(plist) - len, "<head><link rel='stylesheet' type='text/css' href='http://sj-pro.com/css/flags.css'></head>")
	len += format(plist[len], charsmax(plist) - len, "<body text=#FFFFFF bgcolor=#000000 background='http://sj-pro.com/img/main.jpg'><center>")
	len += format(plist[len], charsmax(plist) - len, "<font color=#FFB000 size=3><b>%s<br>%s<br><br>", sz_name, ip)
	len += format(plist[len], charsmax(plist) - len, "<table border=0 width=90%% cellpadding=0 cellspacing=6>")
	len += format(plist[len], charsmax(plist) - len, "<tr style='color:#00b300;font-weight:bold;text-decoration:underline;'><td>PLAYER<td>CAMERA<td>LOCATION")

	for(new i = 1; i <= g_maxplayers; i++) {
		if(~IsUserConnected(i) || IsUserBot(i))
			continue
			
		get_user_name(i, sz_name, charsmax(sz_name))
		len += format(plist[len], charsmax(plist) - len, "<tr><td>")
		//len += format(plist[len], charsmax(plist) - len, "<img src='img/blank.gif' class='flag flag-%s' /> ", g_userCountry_2[i]) // vlajecky
		if(g_userCountry_2[i][0] != EOS){
			if(g_cam2[i] == true){
				len += format(plist[len], charsmax(plist) - len, "%s%s<td>%s<td>%s, %s", sz_name, is_user_admin(i)?"<font color=red> [A]":"", "<font color=yellow>- 3rd lagless -", g_userCountry[i], g_userCity[i])
			} else {
				len += format(plist[len], charsmax(plist) - len, "%s%s<td>%s<td>%s, %s", sz_name, is_user_admin(i)?"<font color=red> [A]":"", g_cam[i]?"<font color=yellow>- 3rd -":"<font color=yellow>- 1st -", g_userCountry[i], g_userCity[i])
			}
		} else if(g_cam2[i] == true){
			len += format(plist[len], charsmax(plist) - len, "%s%s<td>%s<td>%s", sz_name, is_user_admin(i)?"<font color=red> [A]":"", "<font color=yellow>- 3rd lagless -", "N/A")
		} else {
			len += format(plist[len], charsmax(plist) - len, "%s%s<td>%s<td>%s", sz_name, is_user_admin(i)?"<font color=red> [A]":"", g_cam[i]?"<font color=yellow>- 3rd -":"<font color=yellow>- 1st -", "N/A")
		}
	}

	show_motd(id, plist, title )
}
public client_disconnect(id){
	{
		if(rtv[id])
		{
			rtv[id]=false
			//has_nominated[id]=false
			rtvtotal--
		}
	}

	ClearUserAlive(id)
	ClearUserConnected(id)
	if(IsUserBot(id)){
		ClearUserBot(id)
	}

	remove_task(id)
	new i
	for(i = 0; i <= g_count_balls; i++){
		if(id == g_ballholder[i])
			break
	}
	if(i != g_count_balls + 1){
		new sz_name[32]

		glow(g_ballholder[i], 0, 0, 0)

		remove_task(55555 + i)
		set_task(15.0, "ClearBall", 55555 + i)

		g_last_ballholderteam[i] = 0
		g_last_ballholder[i] = 0
		format(g_last_ballholdername[i], 31, "")

		get_user_name(id, sz_name, 31)
		format(g_temp, charsmax(g_temp), "|%s| %s^n%L", TeamNames[get_user_team(id)], sz_name,
		LANG_SERVER, "SJ_DROPBALL")

		g_ballholder[i] = 0

		testorigin[i][2] += 10
		entity_set_origin(g_ball[i], testorigin[i])
		entity_set_vector(g_ball[i], EV_VEC_velocity, Float:{1.0, 1.0, 1.0})
	}
	
	new name[32]
	get_user_name(id, name, 31)
	for(new i = 1; i <= g_maxplayers; i++){
		if(~IsUserConnected(i))
			continue

		ColorChat(i, RED, "^3<- ^1%s ^3has left", name)
	}

	save_stats(id)

	g_bValid[id] = false

	g_Experience[id] = 0
	GoalyPoints[id] = 0
	g_cam[id] = false
	
	new x
	for(x = 1; x<=RECORDS; x++)
		MadeRecord[id][x] = 0

}

play_wav(id, wav[]){
	client_cmd(id, "spk %s", wav)
}

Float:normalize(Float:nVel){
	if(nVel > 180.0) {
		nVel -= 360.0
	} else if(nVel < -179.0) {
		nVel += 360.0
	}

	return nVel
}

public Msg_StatusIcon(msgid, msgdest, id){
	static szIcon[8]
	get_msg_arg_string(2, szIcon, 7)

	if(equal(szIcon, "buyzone") && get_msg_arg_int(1)){
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0))
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public Msg_Money(MsgId, MsgDest, id){
	set_msg_arg_int(1, ARG_LONG, g_Experience[id])
}

public SvRestart(){
	server_cmd("sv_restart 1")
	remove_task(-4566)
	set_task(1.0, "Done_Handler", -4789)
}

cmdSpectate(id){
	if((T <= get_user_team(id) <= CT) && get_pdata_int(id, OFFSET_INTERNALMODEL, 5) != 0xFF){
		user_kill(id)
		cs_set_user_team(id, CS_TEAM_SPECTATOR, CS_DONTCHANGE)
	}
}

public round_restart(Float:x){
	set_cvar_num("sv_restart", floatround(x))
	set_task(x, "Done_Handler", -4789)
	remove_task(-4566)
}
public BeginCountdown(){
	new output[32]
	num_to_word(timer, output, 31)
	client_cmd(0, "spk vox/%s.wav", output)
	MoveBall(0, 0, 0)
	
	if(timer > (COUNTDOWN_TIME / 2)) {

		set_hudmessage(20, 250, 20, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 4)
	} else {
		set_hudmessage(255, 0, 0, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 4)
	}
	show_hudmessage(0, "GAME BEGINS IN:^n%i", timer)
	
	if(timer == 1){
		round_restart(1.0)
		set_task(1.2, "SetupRound")
	}
	timer--
	set_task(0.9, "BeginCountdown", 9999)
	
	
	if(timer == 0){
		remove_task(9999)
		GAME_MODE = MODE_GAME
	}
}

public CsSetUserScore(id, frags, deaths) {
	message_begin(MSG_BROADCAST, msg_scoreboard)
	write_byte(id)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(get_user_team(id))
	message_end()
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      	  [ADMIN]  	| **************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public AdminMenu(id, level, cid){
/*
	if(get_user_flags(id) != ADMIN_IMMUNITY)
		return PLUGIN_HANDLED
*/
	if(!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED
		
	new sz_temp[256]
	format(sz_temp, charsmax(sz_temp), "\y[SJ] \w- %L", id, "SJ_ADMINMENU")
	new menu = menu_create(sz_temp, "AdminMenu_handler")
	new sz_langsets[32], sz_color[2]
	switch (GAME_SETS) {
		case SETS_DEFAULT: {format(sz_langsets, charsmax(sz_langsets), "SJ_DEFSET"); format(sz_color, charsmax(sz_color), "w");}
		case SETS_TRAINING: {format(sz_langsets, charsmax(sz_langsets), "SJ_TRAINING"); format(sz_color, charsmax(sz_color), "y");}
		case SETS_HEADTOHEAD: {format(sz_langsets, charsmax(sz_langsets), "SJ_HEADTOHEAD"); format(sz_color, charsmax(sz_color), "w");}
		case SETS_ROCKET: {format(sz_langsets, charsmax(sz_langsets), "SJ_ROCKETBALL"); format(sz_color, charsmax(sz_color), "r");}
	}
	format(sz_temp, charsmax(sz_temp), "\%s%L",sz_color, id, sz_langsets)
	menu_additem(menu, sz_temp)

	get_pcvar_num(cv_chat)?menu_additem(menu, "\wGlobal chat"):menu_additem(menu, "\dGlobal chat")

	format(sz_temp, charsmax(sz_temp), "\%s%L",(g_count_balls)?("w"):("d"), id, "SJ_MULTIBALL")
	menu_additem(menu, sz_temp)

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public AdminMenu_handler(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new sz_name[32], data[6], access, callback
	menu_item_getinfo(menu, item, access, data, charsmax(data), sz_name, charsmax(sz_name), callback)
	get_user_name(id, sz_name, 31)
	if(task_exists(-4211)){
		remove_task(-4211)
		ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_RAPIDSET")
		menu_destroy(menu)
		AdminMenu(id, 0, 0)
		return PLUGIN_HANDLED
	}
	if(item){
		set_task(0.1, "Done_Handler", -4211)
	}
	switch(item){
		case 0:	{
			SwitchGameSettings(id, GAME_SETS + 1)
		}
		case 1:	{
			if(get_pcvar_num(cv_chat)){
				set_pcvar_num(cv_chat, 0)
				ColorChat(0, RED, "^4[SJ] ^1- ^1Global chat is ^3OFF! ^1(ADMIN: %s)", sz_name)
			} else {
				set_pcvar_num(cv_chat, 1)
				ColorChat(0, GREEN, "^4[SJ] ^1- ^1Global chat is ^4ON! ^1(ADMIN: %s)", sz_name)
			}
		}
		case 2:	{
			MultiBall(id, 0, 0)
		}
	}
	menu_destroy(menu)
	AdminMenu(id, 0, 0)

	return PLUGIN_HANDLED
}

public SwitchGameSettings(id, sz_set){
	new sz_data[1]
	sz_data[0] = id

	switch (sz_set){
		case SETS_DEFAULT: 	GAME_SETS = SETS_DEFAULT
		case SETS_TRAINING: 	GAME_SETS = SETS_TRAINING
		case SETS_HEADTOHEAD: 	GAME_SETS = SETS_HEADTOHEAD
		case SETS_ROCKET: 	GAME_SETS = SETS_ROCKET

		default:{
			SwitchGameSettings(id, SETS_DEFAULT)
			return PLUGIN_HANDLED
		}
	}
	remove_task(-2363)

	set_task(2.0, "ApplyGameSettings", -2363, sz_data, 1)

	return PLUGIN_HANDLED
}

public ApplyGameSettings(sz_data[]){
	new sz_langsets[32], sz_color[2], Color:sz_symb

	switch (GAME_SETS){
		case SETS_DEFAULT:{
			format(sz_langsets, charsmax(sz_langsets), "SJ_DEFSET")
			format(sz_color, charsmax(sz_color), "^1")
			sz_symb = GREEN
			set_pcvar_num(cv_turbo, 2)
			set_pcvar_num(cv_nogoal, 0)
			set_pcvar_num(cv_lamedist, 90)
			set_pcvar_num(cv_alienzone, 650)
			set_pcvar_num(cv_kick, 650)
			set_pcvar_num(cv_multiball, 15)
			set_pcvar_num(cv_players, 16)
			set_pcvar_num(cv_huntdist, 0)
			set_pcvar_num(cv_smack, 80)
			set_pcvar_num(cv_pause, 0)
			set_pcvar_float(cv_alienthink, 1.0)
			set_pcvar_float(cv_alienmin, 10.0)
			set_pcvar_float(cv_alienmax, 12.0)
			set_pcvar_float(cv_ljdelay, 5.0)
			set_pcvar_float(cv_resptime, 2.0)
			set_pcvar_float(cv_reset, 30.0)
			set_cvar_num("sv_gravity", 800)
			set_cvar_num("sv_maxspeed", 900)
			set_cvar_num("mp_falldamage", 1)
			GAME_SETS = SETS_DEFAULT
		}
		case SETS_TRAINING:{
			format(sz_langsets, charsmax(sz_langsets), "SJ_TRAINING")
			format(sz_color, charsmax(sz_color), "^3")
			sz_symb = BLUE
			set_pcvar_num(cv_turbo, 20)
			set_pcvar_num(cv_nogoal, 1)
			set_pcvar_num(cv_lamedist, 0)
			set_pcvar_num(cv_players, 16)
			set_pcvar_num(cv_alienzone, 650)
			set_pcvar_num(cv_kick, 650)
			set_pcvar_float(cv_reset, 30.0)
			set_pcvar_num(cv_alienmin, 0)
			set_pcvar_num(cv_alienmax, 0)
			set_pcvar_num(cv_multiball, 15)
			set_cvar_num("mp_falldamage", 0)
			GAME_SETS = SETS_TRAINING
		}
		case SETS_HEADTOHEAD:{
			format(sz_langsets, charsmax(sz_langsets), "SJ_HEADTOHEAD")
			format(sz_color, charsmax(sz_color), "^3")
			sz_symb = GREY
			set_pcvar_num(cv_turbo, 20)
			set_pcvar_num(cv_nogoal, 0)
			set_pcvar_num(cv_alienzone, 650)
			set_pcvar_num(cv_players, 16)
			set_pcvar_num(cv_kick, 650)
			set_pcvar_float(cv_reset, 30.0)
			GAME_SETS = SETS_HEADTOHEAD
		}
		case SETS_ROCKET:{
			format(sz_langsets, charsmax(sz_langsets), "SJ_ROCKETBALL")
			format(sz_color, charsmax(sz_color), "^3")
			sz_symb = RED
			set_pcvar_num(cv_turbo, 20)
			set_pcvar_num(cv_nogoal, 0)
			set_pcvar_num(cv_lamedist, 0)
			set_pcvar_num(cv_players, 16)
			set_pcvar_num(cv_alienzone, 2350)
			set_pcvar_num(cv_kick, 2000)
			set_pcvar_float(cv_reset, 30.0)
			GAME_SETS = SETS_ROCKET
		}
		default: return PLUGIN_HANDLED
	}

	new sz_name[32]
	get_user_name(sz_data[0], sz_name, charsmax(sz_name))
	for(new i = 1; i <= g_maxplayers; i++){
		if(IsUserConnected(i)){
			ColorChat(i, sz_symb, "^4[SJ] ^1- %s%L ^1(%L: %s)",
			sz_color, i, sz_langsets, i, "SJ_ADMIN", sz_name)
			seconds[i] = 0
		}
	}
	return PLUGIN_HANDLED
}

public Task_cmdSpectate(id){
	id += 155
	cmdSpectate(id)

}
public MultiBall(id, level, cid){
	if(!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED
	if(g_regtype && GAME_MODE != MODE_PREGAME){
		//ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_MULTIAV")
		ColorChat(id, RED, "^4[SJ] ^1- This command is not available now!")

		return PLUGIN_HANDLED
	}
	new i
	if(g_count_balls){
		for(i = g_count_balls; i; i--){
			RemoveBall(i)
		}
		if(GAME_TYPE == TYPE_PUBLIC)
			MoveBall(1, 0, 0)
		else if(GAME_MODE == MODE_PREGAME || GAME_MODE == MODE_NONE)
			MoveBall(0, 0, 0)
	} else {
		new sz_cvar = get_pcvar_num(cv_multiball)
		if(sz_cvar < 0 || sz_cvar > LIMIT_BALLS){
			sz_cvar = g_maxplayers
			set_pcvar_num(cv_multiball, sz_cvar)
		}
		for(i = 1; i < sz_cvar; i++){
			CreateBall(i)
			MoveBall(1, 0, i)
		}
		if(GAME_SETS == SETS_DEFAULT){
			SwitchGameSettings(id, SETS_TRAINING)
		}

	}

	g_count_scores = 0

	new sz_name[32]
	get_user_name(id, sz_name, 31)
	for(i = 1; i <= g_maxplayers; i++){
		if(IsUserConnected(i)){
			ColorChat(i, RED, "^4[SJ] ^1- %L: %s%L! ^1(%L: %s)",
			i, "SJ_MULTIBALL", g_count_balls?("^4"):("^3"),
			i, g_count_balls?("SJ_ON"):("SJ_OFF"), i, "SJ_ADMIN", sz_name)

			//g_count_balls?(g_showhud[i] = false):(g_showhud[i] = true)
		}
	}
	return PLUGIN_HANDLED
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|      [STATS]			| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

/*
public ShowMOTDPlayerStats(id, player){
	new sz_temp[2048], sz_len, title[32], i, sz_name[32]
	get_user_name(player, sz_name, 31)
	new sz_team = get_user_team(id)
	format(title, charsmax(title), "%L", id, "SJ_STATSTITLE")

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<body bgcolor=#000000 text=#FFFFFF><center>")

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<br><font color=%s size=6><b>%s",
	sz_team==1?"red":"#3366FF", sz_name)

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<hr width=50%% color=%s>", sz_team==1?"red":"#3366FF")

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<table width=45%% border=0 align=center cellpadding=0 cellspacing=6>")

	new sz_lang[32], ss[10]
	new Float:fh, Float: fb

	for(i = 1; i <= RECORDS; i++){
		if(i == HITS || i == BHITS)
			continue

		format(sz_lang, charsmax(sz_lang), "SJ_MOTD_%s", RecordTitles[i])

		if(i != POSSESSION){
			sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
			"<tr align=center><td align=left><font color=yellow>%L<td><b>%d",
			id, sz_lang, MadeRecord[player][i])
		}
		else{
			num_to_str(MadeRecord[id][i], ss, 9)
			fb = str_to_float(ss)
			num_to_str(g_Time[0], ss, 9)
			fh = str_to_float(ss)
			sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
			"<tr align=center><td align=left><font color=yellow>%L<td><b>%d%",
			id, sz_lang, g_Time[0]?(floatround((fb / fh) * 100.0)):0)
		}
	}

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"</table><hr width=50%% color=%s>", sz_team==1?"red":"#3366FF")

	show_motd(id, sz_temp, title)
}
*/

public ShowMenuStats(id){

	if(!(T <= get_user_team(id) <= CT)){
		ShowMenuStatsSpec(id)
		return PLUGIN_HANDLED
	}
	new sz_temp[1024], sz_len, sz_buff[32], sz_name[32]
	//sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L:^n", id, "SJ_STATSTITLE")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "Top Stats^n")
	for(new x = 1; x <= RECORDS; x++){
		if(x == POSSESSION || x == DISTANCE || x == BALLKILL || x == SMACK || x == DEATH || x == HITS || x == BHITS || x == DISHITS || x == DISARMED || x == HUNT)
			continue
		//format(sz_lang, charsmax(sz_lang), "SJ_%s", RecordTitles[x])
		format(sz_name, 19, TopPlayerName[x])
		if(TopPlayer[0][x] != id){
			format(sz_buff, 8, "\d%d", MadeRecord[id][x])
		} else {
			format(sz_buff, 8, "")
		}
		sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "^n\w%s \y%s \r%d %s", RecordTitlesLong[x],
		TopPlayer[1][x]?sz_name:"", TopPlayer[1][x], sz_buff)

		//menu_additem(menu, x, sz_temp)
	}
	//console_print(id, sz_temp)
	new menu = menu_create(sz_temp, "Done_Handler")
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_additem(menu, "Close")

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public ShowMenuStatsSpec(id){
	new sz_temp[1024], sz_len, sz_buff[32], sz_name[32]
	//sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L:^n", id, "SJ_STATSTITLE")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "Top Stats^n")
	for(new x = 1; x <= RECORDS; x++){
		if(x == POSSESSION || x == DISTANCE || x == BALLKILL || x == SMACK || x == DEATH || x == HITS || x == BHITS || x == DISHITS || x == DISARMED || x == HUNT)
			continue
		//format(sz_lang, charsmax(sz_lang), "SJ_%s", RecordTitles[x])
		format(sz_name, 19, TopPlayerName[x])
		if(TopPlayer[0][x] != id){
			format(sz_buff, 8, "\d%d", MadeRecord[id][x])
		} else {
			format(sz_buff, 8, "")
		}
		sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "^n\w%s \y%s \r%d", RecordTitlesLong[x],
		TopPlayer[1][x]?sz_name:"", TopPlayer[1][x])

		//menu_additem(menu, x, sz_temp)
	}
	//console_print(id, sz_temp)
	new menu = menu_create(sz_temp, "Done_Handler")
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_additem(menu, "Close")

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

/*

public ShowMenuPlayerStats(id, player){
	new sz_temp[1024], sz_len
	new sz_name[32], sz_lang[32]

	get_user_name(player, sz_name, 31)
	//sz_len = format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	//"\y%L:^n\w%s^n^n", id, "SJ_SKILLS", sz_name)
	sz_len = format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%s^n^n", sz_name)
	for(new x = 1; x <= RECORDS; x++){
		if(x == POSSESSION || x == DEATH || x == HITS || x == BHITS || x == DISHITS || x == DISARMED)
			continue
		format(sz_lang, charsmax(sz_lang), "SJ_%s", RecordTitlesLong[x])
		sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
		"%L \r%d \w%d^n", id, sz_lang,
		MadeRecord[player][x], TopPlayer[1][x])
	}

	new menu = menu_create(sz_temp, "Done_Handler")
	menu_additem(menu, "")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	format(sz_lang, charsmax(sz_lang), "%L", id, "SJ_EXIT")
	menu_setprop(menu, MPROP_EXITNAME, sz_lang)

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

*/
public TNT_ShowMenuPlayerStats(id, player){
	new sz_temp[1024], sz_len
	new sz_name[32]

	get_user_name(player, sz_name, 31)
	sz_len = format(sz_temp[sz_len], 1023 - sz_len, "\yStats^n\w%s^n^n", sz_name)

	for(new x = 1; x <= RECORDS; x++){
		if(x == POSSESSION || x == DEATH || x == HITS || x == BHITS || x == DISHITS || x == DISARMED || x == SMACK || x == DISTANCE || x == BALLKILL)
			continue
		sz_len += format(sz_temp[sz_len], 1023 - sz_len,  "\w%s \r%d^n", RecordTitlesLong[x],
		MadeRecord[player][x])
	}
	new menu = menu_create(sz_temp, "Done_Handler")

	menu_additem(menu, "Close")
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|        [HELP]		| **************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public PlayerHelpMenu(id){
	new sz_temp[512]
	format(sz_temp, charsmax(sz_temp),"\y[SJ] \w- %L", id, "SJ_HELPTITLE")
	new menu = menu_create(sz_temp, "PlayerHelpMenu_handler")

	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_HELPGENINF")
	menu_additem(menu, sz_temp)
	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_HELPSKILLS")
	menu_additem(menu, sz_temp)
	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_HELPCONTR")
	menu_additem(menu, sz_temp)
	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_HELPCHAT")
	menu_additem(menu, sz_temp)
	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_HELPTRICKS")
	menu_additem(menu, sz_temp)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	format(sz_temp, charsmax(sz_temp), "%L", id, "SJ_EXIT")
	menu_setprop(menu, MPROP_EXITNAME, sz_temp)

	menu_display(id, menu, 0)

	return PLUGIN_HANDLED
}

public PlayerHelpMenu_handler(id, menu, item){
	if(item == MENU_EXIT){
		return PLUGIN_HANDLED
	}

	ShowHelp(id, item)

	menu_destroy(menu)
	PlayerHelpMenu(id)

	return PLUGIN_HANDLED
}

public ShowHelp(id, x){
	new help_title[64], sz_temp[2048], sz_len
	format(help_title, charsmax(help_title), "%L", id, "SJ_HELP_MOTD")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "<body bgcolor=#000000 text=yellow><br>")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<h2><center><font color=5da130>%L</font></center></h2>",
	id, "SJ_MOTD_HELP_GENINFO_TITLE")
			
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CONTR_KICK")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CONTR_TURBO")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CONTR_CURVE")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CONTR_1")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CONTR_UPMENU")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "<body bgcolor=#000000 text=yellow><br>")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<h2><center><font color=5da130>%L</font></center></h2>",
	id, "SJ_MOTD_HELP_SKILLS_TITLE")			
	//sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br><br>", id, "SJ_MOTD_HELP_CONTR_UPMENU")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_SKILLS_STA")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_SKILLS_STR")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_SKILLS_AGI")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_SKILLS_DEX")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_SKILLS_DIS")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "<body bgcolor=#000000 text=yellow><br>")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len,
	"<h2><center><font color=5da130>%L</font></center></h2>",
	id, "SJ_MOTD_HELP_CHAT_TITLE")
			
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CHAT_CAM")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CHAT_STATS")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CHAT_RESET")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CHAT_SPEC")
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L<br>", id, "SJ_MOTD_HELP_CHAT_WHOIS")	
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%L", id, "SJ_MOTD_HELP_CHAT_RTV")		
	show_motd(id, sz_temp, help_title)
}

/*
public Help(id){
	g_showhelp[id] = true
	if(task_exists(id + 45475)){
		remove_task(id + 45475)
		set_task(13.0, "HelpOff", id + 45475)
	} else {
		UTIL_ScreenFade(id, {0, 0, 0}, 1.5, 13.0, 220, FFADE_OUT)
		set_task(1.5, "HelpOn", id + 45405)
		set_task(13.0, "HelpOff", id + 45475)
	}
}

public HelpOn(id){
	id -= 45405

	set_dhudmessage(255, 255, 255, -1.0, 0.1, 0, 3.0, 10.0)
	show_dhudmessage(id, "%L", id, "SJ_HUDHELP")
	set_dhudmessage(255, 255, 255, 0.02, 0.24, 0, 3.0, 10.0)
	show_dhudmessage(id, "%L", id, "SJ_HUDHELP1")
	set_dhudmessage(255, 255, 255, -1.0, 0.8, 0, 3.0, 10.0)
	show_dhudmessage(id, "%L", id, "SJ_HUDHELP2")
	set_dhudmessage(255, 255, 255, -1.0, -1.0, 0, 3.0, 10.0)
	show_dhudmessage(id, "%L", id, "SJ_HUDHELP3")
	set_dhudmessage(255, 255, 255, 0.7, 0.6, 0, 3.0, 10.0)
	show_dhudmessage(id, "%L", id, "SJ_HUDHELP4")

	BuyUpgrade(id)
}


public HelpOff(id){
	id -= 45475
	PlayerHelpMenu(id)
	UTIL_ScreenFade(id, {0, 0, 0}, 1.5, 1.0, 220, FFADE_IN)
	g_showhelp[id] = false
}
*/

public Event_Record(id, recordtype){
	if(id && IsUserConnected(id) && !get_pcvar_num(cv_pause) && (GAME_MODE == MODE_GAME)){
		if(recordtype != DISTANCE){
			MadeRecord[id][recordtype]++
			TempRecord[id][recordtype]++
			new szTeam = get_user_team(id)
			if(T <= szTeam <= CT){
				TeamRecord[szTeam][recordtype]++
			}
		} else {
			MadeRecord[id][recordtype] = g_distshot
		}

		if(MadeRecord[id][recordtype] > TopPlayer[1][recordtype]){
			TopPlayer[0][recordtype] = id
			TopPlayer[1][recordtype] = MadeRecord[id][recordtype]

			new sz_name[32]
			get_user_name(id, sz_name, charsmax(sz_name))
			format(TopPlayerName[recordtype], 20, "%s", sz_name)
		}

		if(recordtype == POSSESSION){
			g_Time[0]++
			return
		}

		g_MVP_points[id] =
		MadeRecord[id][GOAL] 		* MVP_GOAL 	+
		MadeRecord[id][ASSIST] 		* MVP_ASSIST 	+
		MadeRecord[id][STEAL] 		* MVP_STEAL 	+
		MadeRecord[id][GOALSAVE] 	* MVP_GOALSAVE 	+
		MadeRecord[id][HUNT] 		* MVP_HUNT 	+
		MadeRecord[id][DISHITS] 	* MVP_DISHITS	+
		MadeRecord[id][LOSS] 		* MVP_LOSSES
		if(g_MVP_points[id] > g_MVP){
			g_MVP = g_MVP_points[id]
			//g_MVPwebId = g_PlayerId[id]
			get_user_name(id, g_MVP_name, charsmax(g_MVP_name))
		}
		switch(recordtype){
			case GOAL: 	g_Experience[id] += POINTS_GOAL
			case ASSIST: 	g_Experience[id] += POINTS_ASSIST
			case STEAL: 	g_Experience[id] += POINTS_STEAL
			case HUNT: 	g_Experience[id] += POINTS_HUNT
			case PASS: 	g_Experience[id] += POINTS_PASS
			case DISHITS: 	g_Experience[id] += POINTS_DISHITS
			case BALLKILL: 	g_Experience[id] += POINTS_BALLKILL
			case LOSS: 	g_Experience[id] += POINTS_FAIL
			case GOALSAVE: 	g_Experience[id] += POINTS_GOALSAVE
		}
		if(g_Experience[id] < 0)
			g_Experience[id] = 0
		//cs_set_user_money(id, g_Experience[id])
		CsSetUserScore(id, g_MVP_points[id], MadeRecord[id][DEATH])
	}
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|	[SPRITES]	| ******************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

TerminatePlayer(id, mascot, team, Float:dmg, color[]){
	new orig[3], Float:morig[3], iMOrig[3], x

	get_user_origin(id, orig)
	entity_get_vector(mascot, EV_VEC_origin, morig)

	for(x = 0; x < 3; x++)
		iMOrig[x] = floatround(morig[x])

	fakedamage(id, "Alien", dmg, 1)

	new loc = (team == 1 ? 0 : 0)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0)
	write_coord(iMOrig[0])		// (start positionx)
	write_coord(iMOrig[1])		// (start positiony)
	write_coord(iMOrig[2] + loc)	// (start positionz)
	write_coord(orig[0])		// (end positionx)
	write_coord(orig[1])		// (end positiony)
	write_coord(orig[2])		// (end positionz)
	write_short(spr_fxbeam) 	// (sprite index)
	write_byte(0) 			// (starting frame)
	write_byte(0) 			// (frame rate in 0.1's)
	write_byte(7) 			// (life in 0.1's)
	write_byte(120) 		// (line width in 0.1's)
	write_byte(25) 			// (noise amplitude in 0.01's)
	write_byte(color[0])		// r
	write_byte(color[1])		// g
	write_byte(color[2])		// b
	write_byte(220)			// brightness
	write_byte(1) 			// (scroll speed in 0.1's)
	message_end()
}

glow(id, r, g, b){
	set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
	entity_set_float(id, EV_FL_renderamt, 1.0)
}

new T_sprite
new CT_sprite

beam(ball, i) 
{
	if(get_user_team(g_ballholder[i]) == 1 || get_user_team(g_ballholder[i]) == 1)
	{
		if(T_sprite == 0)
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_KILLBEAM)
			write_short(ball)
			message_end()
			T_sprite = 1
			CT_sprite = 0
		}
		beam_T(ball)
	}	
	else if(get_user_team(g_ballholder[i]) == 2 || get_user_team(g_ballholder[i]) == 2)
	{
		if(CT_sprite == 0)
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_KILLBEAM)
			write_short(ball)
			message_end()
			CT_sprite = 1
			T_sprite = 0
		}
		beam_CT(ball)
	}
}


beam_CT(ball)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(22) 		// TE_BEAMFOLLOW
	write_short(ball) 	// ball
	write_short(spr_beam)// laserbeam
	
	write_byte(10)	// life
	write_byte(2)	// width
	
	write_byte(BeamColors[CT][0])	// R
	write_byte(BeamColors[CT][1])	// G
	write_byte(BeamColors[CT][2])	// B
	write_byte(175)	// brightness	
	
	message_end()
}

beam_T(ball)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(22) 		// TE_BEAMFOLLOW
	write_short(ball) 	// ball
	write_short(spr_beam)// laserbeam

	write_byte(10)	// life
	write_byte(2)	// width	
	write_byte(BeamColors[T][0])	// R
	write_byte(BeamColors[T][1])	// G	Perfect Select
	write_byte(BeamColors[T][2])	// B
	write_byte(175)	// brightness
	
	message_end()
}



flameWave(myorig[3], team){
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, myorig)
	write_byte(21)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 16)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 500)
	write_short(spr_fire)
	write_byte(0) 			// startframe
	write_byte(0) 			// framerate
	write_byte(15) 			// life 2
	write_byte(50) 			// width 16
	write_byte(10) 			// noise
	write_byte(TeamColors[team][0]) // r
	write_byte(TeamColors[team][1]) // g
	write_byte(TeamColors[team][2]) // b
	write_byte(255) 		// brightness
	write_byte(1 / 10) 		// speed
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, myorig)
	write_byte(21)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 16)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 500)
	write_short(spr_fire)
	write_byte(0) 				// startframe
	write_byte(0) 				// framerate
	write_byte(10) 				// life 2
	write_byte(70) 				// width 16
	write_byte(10) 				// noise
	write_byte(TeamColors[team][0]) 	// r
	write_byte(TeamColors[team][1] + 50) 	// g
	write_byte(TeamColors[team][2]) 	// b
	write_byte(200) 			// brightness
	write_byte(1 / 9) 			// speed
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, myorig)
	write_byte(21)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 16)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2] + 500)
	write_short(spr_fire)
	write_byte(0) 				// startframe
	write_byte(0) 				// framerate
	write_byte(10) 				// life 2
	write_byte(90) 				// width 16
	write_byte(10) 				// noise
	write_byte(TeamColors[team][0]) 	// r
	write_byte(TeamColors[team][1] + 100) 	// g
	write_byte(TeamColors[team][2]) 	// b
	write_byte(200) 			// brightness
	write_byte(1 / 8) 			// speed
	message_end()

	//Explosion2
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(12)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2])
	write_byte(80) 	// byte (scale in 0.1's) 188
	write_byte(10) 	// byte (framerate)
	message_end()

	//TE_Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2])
	write_short(spr_fire)
	write_byte(65) 	// byte (scale in 0.1's) 188
	write_byte(10) 	// byte (framerate)
	write_byte(0) 	// byte flags
	message_end()

	//Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, myorig)
	write_byte(5)
	write_coord(myorig[0])
	write_coord(myorig[1])
	write_coord(myorig[2])
	write_short(spr_smoke)
	write_byte(50)
	write_byte(10)
	message_end()

	return PLUGIN_HANDLED
}

stock get_wall_angles(id, Float:fReturnAngles[3], Float:fNormal[3]){
	new Float:fOrigin[3]
	pev(id, pev_origin, fOrigin)

	new Float:fAngles[3]
	pev(id, pev_v_angle, fAngles)
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fAngles)

	fAngles[0] = fAngles[0] * 9999.0
	fAngles[1] = fAngles[1] * 9999.0
	fAngles[2] = fAngles[2] * 9999.0

	new Float:fEndPos[3]
	fEndPos[0] = fAngles[0] + fOrigin[0]
	fEndPos[1] = fAngles[1] + fOrigin[1]
	fEndPos[2] = fAngles[2] + fOrigin[2]

	new ptr = create_tr2()
	engfunc(EngFunc_TraceLine, fOrigin, fEndPos, IGNORE_MISSILE | IGNORE_MONSTERS | IGNORE_GLASS, id, ptr)

	new Float:vfNormal[3]
	get_tr2(ptr, TR_vecPlaneNormal, vfNormal)

	vector_to_angle(vfNormal, fReturnAngles)

	xs_vec_copy(vfNormal, fNormal)
}

/*
public ShowPassSprite(id){
	id -= 3122

	remove_task(id - 4122)
	set_task(0.2, "RemovePassSprite", id - 4122)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(124)
	write_byte(id)
	write_coord(45)
	write_short(spr_pass[get_user_team(id)])
	write_short(100)
	message_end()
}

public RemovePassSprite(id){
	id += 4122
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
   	write_byte(125)
   	write_byte(id)
   	message_end()
	remove_task(id - 3122)
}

*/

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|     [nVault-PART]	| **************************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public save_stats(id){
	if(contain(g_authid[id], "LAN") != -1 || contain(g_authid[id], "PEND") != -1
	|| contain(g_authid[id], "STEAM") == -1 || g_authid[id][0] == EOS)
		return PLUGIN_HANDLED

	//new sz_data[1024], sz_key[45]
	new sz_team = get_user_team(id)

	new szKey[128], x

	for(new i = 0; i < 64; i++){
		if(equal(g_list_authid[i], g_authid[id]))
			break
		if(g_list_authid[i][0] == EOS){
			format(g_list_authid[i], 35, "%s", g_authid[id])
			break
		}
	}

	for(x = 1; x <= RECORDS; x++){
		format(szKey, charsmax(szKey), "%s_RECORDS@%s", g_authid[id], RecordTitles[x])
		TrieSetCell(gTrieStats, szKey, MadeRecord[id][x])
	}

	format(szKey, charsmax(szKey), "%s_MVP_POINTS", g_authid[id])
	TrieSetCell(gTrieStats, szKey, g_MVP_points[id])

	format(szKey, charsmax(szKey), "%s_EXPERIENCE", g_authid[id])
	TrieSetCell(gTrieStats, szKey, g_Experience[id])

	format(szKey, charsmax(szKey), "%s_CREDITS", g_authid[id])
	TrieSetCell(gTrieStats, szKey, g_Credits[id])

	for(x = 1; x <= UPGRADES; x++){
		format(szKey, charsmax(szKey), "%s_SKILLS@%s", g_authid[id], UpgradeTitles[x])
		TrieSetCell(gTrieStats, szKey, PlayerUpgrades[id][x])
	}

	format(szKey, charsmax(szKey), "%s_MATCH_ID", g_authid[id])
	TrieSetCell(gTrieStats, szKey, gMatchId)

	format(szKey, charsmax(szKey), "%s_PLAYER_ID", g_authid[id])
	TrieSetCell(gTrieStats, szKey, g_PlayerId[id])

	if(T <= sz_team <= CT){
		format(szKey, charsmax(szKey), "%s_TEAM_ID", g_authid[id])
		TrieSetCell(gTrieStats, szKey, TeamId[sz_team])

		format(szKey, charsmax(szKey), "%s_RINGER", g_authid[id])
		TrieSetCell(gTrieStats, szKey, (TeamId[sz_team]>0 && TeamId[sz_team]!=g_userClanId[id])?1:0)
	}
	return PLUGIN_HANDLED
}

public load_stats(id){
	if(contain(g_authid[id], "LAN") != -1 || contain(g_authid[id], "PEND") != -1
	|| contain(g_authid[id], "STEAM") == -1 || g_authid[id][0] == EOS)
		return PLUGIN_HANDLED
/*
	new sz_data[128]
	new sz_key[45]
	new sz_temp[64]
*/

	new szKey[128], x

	format(szKey, charsmax(szKey), "%s_MATCH_ID", g_authid[id])
/*	if(!TrieKeyExists(gTrieStats, szKey)){
		loadDefaultSkills(id)
		return PLUGIN_HANDLED
	}
*/
	for(x = 1; x <= RECORDS; x++){
		format(szKey, charsmax(szKey), "%s_RECORDS@%s", g_authid[id], RecordTitles[x])
		TrieGetCell(gTrieStats, szKey, MadeRecord[id][x])
	}

	format(szKey, charsmax(szKey), "%s_MVP_POINTS", g_authid[id])
	TrieGetCell(gTrieStats, szKey, g_MVP_points[id])

	format(szKey, charsmax(szKey), "%s_EXPERIENCE", g_authid[id])
	TrieGetCell(gTrieStats, szKey, g_Experience[id])

	format(szKey, charsmax(szKey), "%s_CREDITS", g_authid[id])
	TrieGetCell(gTrieStats, szKey, g_Credits[id])
/*
	for(x = 1; x <= UPGRADES; x++){
		format(szKey, charsmax(szKey), "%s_SKILLS@%s", g_authid[id], UpgradeTitles[x])
		if(!TrieGetCell(gTrieStats, szKey, PlayerUpgrades[id][x])){
			loadDefaultSkills(id)
			break
		}
	}
*/

	
	if(IsUserAlive(id)){
		set_speedchange(id)
	}

	return PLUGIN_HANDLED
}

public saveDefaultSkills(id){
	if(contain(g_authid[id], "LAN") != -1 || contain(g_authid[id], "PEND") != -1 || contain(g_authid[id], "STEAM") == -1 || g_authid[id][0] == EOS){
		ColorChat(id, RED, "^4[SJ] ^1- ^3%L", id, "SJ_STEAMUNA")
		return PLUGIN_HANDLED
	}

	new sz_credits = 0
	for(new i = 1; i <= UPGRADES; i++){
		sz_credits += (PlayerUpgrades[id][i]==UpgradeMax[i]?(PlayerUpgrades[id][i] + 1):PlayerUpgrades[id][i])
	}
	if(sz_credits > STARTING_CREDITS){
		ColorChat(id, RED, "^4[SJ] ^1- ^3Currently used amount of credits is more than %d. Default skill can not be saved.", STARTING_CREDITS)
		return PLUGIN_HANDLED
	}
	new sz_len = 0
	new sz_temp[512]

	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "UPDATE sj_players SET ")
	for(new i = 1; i <= UPGRADES; i++){
		PlayerDefaultUpgrades[id][i] = PlayerUpgrades[id][i]
		sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, "%s%s=%d", i==1?"":",", UpgradeTitles[i], PlayerDefaultUpgrades[id][i])
	}
	sz_len += format(sz_temp[sz_len], charsmax(sz_temp) - sz_len, " WHERE ID=%d", g_PlayerId[id])

	ColorChat(id, RED, "^4[SJ] ^1- Default skills have been saved.")
	return PLUGIN_HANDLED
}
/*
public loadDefaultSkills(id){
	//ResetSkills(id)

	
	g_Credits[id] -= STARTING_CREDITS

	for(new i = 1; i <= UPGRADES; i++){
		//PlayerUpgrades[id][i] = PlayerDefaultUpgrades[id][i]
	PlayerUpgrades[i][DEX] = UpgradeMax[DEX]
	PlayerUpgrades[i][AGI] = UpgradeMax[AGI]
	PlayerUpgrades[i][STA] = UpgradeMax[STA]
	PlayerUpgrades[i][AGI] = UpgradeMax[AGI]
	PlayerUpgrades[i][DIS] = UpgradeMax[DIS]
	
	}

	if(IsUserAlive(id)){
		set_speedchange(id)
	}
}
*/
/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|     [MAP VOTING]		| ************************************************************************ |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public cmd_nextmap(id,level,cid)
{	
if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}

	if(!voting)
	{
		num = get_pcvar_num(delay_time_pcvar)
		if(num<1) num=1

		new arg1[8] = "1"
		new arg2[8] = "1"
		if(read_argc()>=2)
		{
			read_argv(1,arg1,7)
			if(read_argc()>=3)
			{
				read_argv(2,arg2,7)
			}
		}

		ColorChat(0, GREEN, "^4[SJ] ^1- An admin has started a nextmap vote! Vote starting in %d seconds.",num)
		if(str_to_num(arg2)) voterocked2=true
		else voterocked2=false
		make_menu(str_to_num(arg1))

	}
	else
	{
		ColorChat(id, GREEN, "^4[SJ] ^1- There is already a nextmap vote in progress.")
	}
	return PLUGIN_CONTINUE
	}
return PLUGIN_HANDLED
}

public make_menu(add_extend)
{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	num = get_pcvar_num(delay_time_pcvar)
	if(num<1) num=1

	for(new i=0;i<10;i++) votes[i]=0
	for(new i=0;i<9;i++) format(maps[i],31,"")

	format(menu,1999,"^n")

	new Fsize = file_size(configfile,1)
	new read[32], trash, string[8]
	new numbers[17]

	for(new i=1;i<9;i++)
	{
		numbers[i]=0
		numbers[17-i]=0
		for(new i2=0;i2<Fsize;i2++)
		{
			read_file(configfile,i2,read,31,trash)
			format(string,7,"[%d]",i)
			if(equali(read,string)) numbers[i]=i2+1
				
			format(string,7,"[/%d]",i)
			if(equali(read,string)) numbers[17-i]=i2-1
		}
	}

	new tries
	keys = (1<<9)
	new j
	for(new i=1;i<9;i++)
	{
		format(maps[i],31,"")
		if(numbers[i] && numbers[17-i] && numbers[17-i]-numbers[i]>=0)
		{
			tries=0
			while(tries<MAX_TRIES)
			{
				read_file(configfile,random_num(numbers[i],numbers[17-i]),read,31,trash)
				//if(containi(read,"%nominated%")==0 && num_nominated>0) format(read,31,"%s",nominated[random_num(0,num_nominated - 1)])
				if(is_map_valid(read))
				{
					for(j=1;j<i;j++)
					{
						if(equali(read,maps[j]))
						{
							j = 0
							break;
						}
					}
					if(!j) break;
					format(maps[i],31,"%s",read)
					format(menu,1999,"\r%s^n%d. \w%s\r",menu,i,read)
					switch(i)
					{
						case 1: keys |= (1<<0)
						case 2: keys |= (1<<1)
						case 3: keys |= (1<<2)
						case 4: keys |= (1<<3)
						case 5: keys |= (1<<4)
						case 6: keys |= (1<<5)
						case 7: keys |= (1<<6)
						case 8: keys |= (1<<7)
					}
					break;
				}
				tries++
			}
		}
	}
	
	/*
	if(add_extend)
	{
		new mapname[32]
		get_mapname(mapname,31)
		if(extended<get_pcvar_num(extended_pcvar))
		{
			format(menu,1999,"%s^n^n9. Extend %s",menu,mapname)
			keys |= (1<<8)
		}
	}
	*/
	
	format(menu,1999,"\r%s^n^n0. \yNone",menu)
	/*
	set_hudmessage(255,0,0,0.03,0.40,0,6.0,1.0,0.0,0.0,3)
	show_hudmessage(0,"Vote for Next Map in %d seconds:",num)

	set_hudmessage(255,255,255,0.03,0.40,0,6.0,1.0,0.0,0.0,4)
	show_hudmessage(0,menu)
	*/
	set_task(1.0,"Send_Menu",0,"",0,"a",num)
	set_task(get_pcvar_float(delay_tally_time_pcvar) + float(num),"VoteTally",0)

	voting=true
	voterocked=-1.0
	}
}

public Send_Menu()
{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
		if(num!=1)
		{
		/*
			set_hudmessage(255,0,0,0.03,0.40,0,6.0,1.0,0.0,0.0,3)
			show_hudmessage(0,"Vote for Next Map in %d seconds:",num-1)

			set_hudmessage(255,255,255,0.03,0.40,0,6.0,1.0,0.0,0.0,4)
			show_hudmessage(0,menu)
			*/
			num--
		}
		else
		{
			client_cmd(0,"spk Gman/Gman_Choose2")
			format(menu,1999,"\yChoose the next map%s",menu)
			show_menu(0,keys,menu,get_pcvar_num(delay_tally_time_pcvar),"CustomNextMap")
		}
	}
}

public saynextmap(id)
{
if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	if(strlen(cur_nextmap)) ColorChat(0, GREEN, "^4[SJ] ^1- Nextmap: %s",cur_nextmap) //client_print(0,print_chat,"[SJ] - Nextmap: %s",cur_nextmap)
	else ColorChat(0, GREEN, "^4[SJ] ^1- Nextmap hasn't been chosen yet.") //client_print(0,print_chat,"[SJ] - Nextmap not chosen yet.")
	}
}

public say_hook(id)
{
if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	new text[64]
	read_args(text,63)
	remove_quotes(text)

	new string[32]
	for(new i=0;i<sizeof(say_commands);i++)
	{
		format(string,31,"%s",say_commands[i])
		if(containi(text,string)==0) return sayrockthevote(id);
	}
/*
	for(new i=0;i<sizeof(say_commands2);i++)
	{
		format(string,31,"%s ",say_commands2[i])
		if(containi(text,string)==0)
		{
			replace(text,63,string,"")
			return saynominate(id,text);
		}
	}
*/
	//if(is_map_valid2(text)) return saynominate(id,text);

	return PLUGIN_CONTINUE
	}
return PLUGIN_HANDLED
}

public sayrockthevote(id)
{
if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	if(voterocked==-1.0)
	{
		ColorChat(id, GREEN, "^4[SJ] ^1- Voting Currently in Process.")
	}
	else if((!voterocked && get_gametime()>get_pcvar_num(rtv_wait_pcvar)) || (get_gametime() - voterocked) > get_pcvar_num(rtv_wait_pcvar))
	{
		if(get_pcvar_num(rtv_percent_pcvar)>0 && get_pcvar_num(rtv_percent_pcvar)<=100)
		{
			if(rtv[id])
			{
				ColorChat(id, GREEN, "^4[SJ] ^1- You have already voted to Rock the Vote.")
			}
			else
			{
				rtv[id]=true
				rtvtotal++

				new num2, players[32]
				get_players(players,num2,"ch")

				new name[32]
				get_user_name(id,name,31)

				new num3 = floatround((num2 * get_pcvar_float(rtv_percent_pcvar) / 100.0) - rtvtotal,floatround_ceil)

				if(num3<=0)
				{
					ColorChat(0, GREEN, "^4[SJ] ^1- %s has voted to Rock the Vote.",name)
					ColorChat(0, GREEN, "^4[SJ] ^1- The Vote has been Rocked!")
					log_amx("[SJ] - Vote has been rocked. The map will be changed.")
					make_menu(1)

					voterocked2=true
				}
				else
				{
					if(num3!=1) ColorChat(0, GREEN, "^4[SJ] ^1- %s has voted to Rock the Vote. Need %d more players.",name,num3)
					else ColorChat(0, GREEN, "^4[SJ] ^1-  %s has voted to Rock the Vote. Need 1 more player.",name)
				}
			}
		}
		else
		{
			ColorChat(id, GREEN, "^4[SJ] ^1- Rock the Vote is disabled.")
		}
	}
	else if(voterocked>0.0)
	{
		ColorChat(id, GREEN, "^4[SJ] ^1- Cannot Rock the Vote again for another %d seconds.",get_pcvar_num(rtv_wait_pcvar) - (floatround(get_gametime()) - floatround(voterocked)))
	}
	else
	{
		ColorChat(id, GREEN, "^4[SJ] ^1- Cannot Rock the Vote till %d seconds after map start. (%d more seconds)",get_pcvar_num(rtv_wait_pcvar),get_pcvar_num(rtv_wait_pcvar) - floatround(get_gametime()))
	}

	return PLUGIN_CONTINUE
	}
return PLUGIN_HANDLED
}

/*
public saynominate(id,nom_map[64])
{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
		if(has_nominated[id])
		{
			ColorChat(id, GREEN, "^4[SJ] ^1- You have already nominated a map.")
		}
		else if(is_map_valid2(nom_map))
		{
			if(equali(nom_map,currentmap))
			{
				ColorChat(0, GREEN,"^4[SJ] ^1- Cannot nominate the current map.")
				return PLUGIN_CONTINUE
			}
			else if(!get_pcvar_num(lastmap_pcvar) && equali(nom_map,lastmap))
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Cannot nominate the previous map.")
				return PLUGIN_CONTINUE
			}
			else if(!get_pcvar_num(lastlastmap_pcvar) && equali(nom_map,lastlastmap))
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Cannot nominate the previous to previous map.")
				return PLUGIN_CONTINUE
			}

			for(new i=0;i<num_nominated;i++)
			{
				if(equali(nominated[i],nom_map))
				{
					ColorChat(0, GREEN, "^4[SJ] ^1- That map has already been nominated.")
					return PLUGIN_CONTINUE
				}
			}

			format(nominated[num_nominated],31,"%s",nom_map)
			num_nominated++

			new name[32]
			get_user_name(id,name,31)
			ColorChat(0, GREEN, "^4[SJ] ^1- %s nominated %s.",name,nom_map)
			has_nominated[id] = true
		}
		else
		{
			ColorChat(0, GREEN, "^4[SJ] ^1- This map isn't on the server.")
		}

		return PLUGIN_CONTINUE
	}
	return PLUGIN_HANDLED
}
*/

public is_map_valid2(map[]){
		if(is_map_valid(map) &&
		containi(map,"<")==-1 &&
		containi(map,"\")==-1 &&
		containi(map,"/")==-1 &&
		containi(map,">")==-1 &&
		containi(map,"?")==-1 &&
		containi(map,"|")==-1 &&
		containi(map,"*")==-1 &&
		containi(map,":")==-1 &&
		containi(map,"^"")==-1
		)
		return 1;

		return 0;
}

public Check_Endround()
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
	{
		if(voterocked==-1.0)
			return ;

		new bool:continuea=false

		if(cstrike)
		{
			new winlimit = get_pcvar_num(mp_winlimit)
			if(winlimit)
			{
				new c = winlimit - 2
				if(!((c> g_teamScore[0]) && (c>g_teamScore[1]) ))
				{
					continuea=true
				}
			}

			new maxrounds = get_pcvar_num(mp_maxrounds)
	
			if(maxrounds)
			{
				if(!((maxrounds - 2) > (g_teamScore[0] + g_teamScore[1])))
				{
					continuea=true
				}
			}
		}

		new timeleft = get_timeleft()
		if(!(timeleft < 1 || timeleft > 129))
		{
			continuea=true
		}

		if(!continuea)
			return ;

		remove_task(1337)

		make_menu(1)

		return ;
	}
}

public VoteCount(id,key)
{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
		if(voting)
		{
			new name[32]
			get_user_name(id,name,31)
			if(key==8)
			{
				if(get_pcvar_num(showvotes_pcvar)) ColorChat(0, GREEN, "^4[SJ] ^1- %s voted for map extension.",name)
				votes[9]++
			}
			else if(key==9)
			{
				if(get_pcvar_num(showvotes_pcvar)) ColorChat(0, GREEN, "^4[SJ] ^1- %s didn't vote.",name)
			}
			else if(strlen(maps[key+1]))
			{
				if(get_pcvar_num(showvotes_pcvar)) ColorChat(0, GREEN, "^4[SJ] ^1- %s voted for %s.",name,maps[key+1])
				votes[key+1]++
			}
			else
			{
				show_menu(id,keys,menu,-1,"CustomNextMap")
			}
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public VoteTally(num)
	{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
		voting=false
		new winner[2]
		for(new i=1;i<10;i++)
		{
			if(votes[i]>winner[1])
			{
				winner[0]=i
				winner[1]=votes[i]
			}
			votes[i]=0
		}
		if(!winner[1])
		{
			if(!voterocked2)
			{
				new mapname[32]
				get_cvar_string("qq_lastmap",mapname,31)
				//set_cvar_string("qq_lastlastmap",mapname)
				get_mapname(mapname,31)
				//set_cvar_string("qq_lastmap",mapname)
				get_mapname(currentmap,31)
				set_cvar_string("currentmap",mapname)
				ColorChat(0, GREEN, "^4[SJ] ^1- Nobody voted.")
				set_task(15.0,"Check_Endround",1337,"",0,"b")
				set_cvar_string("amx_nextmap",mapname)
				extended++
			}
			else
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Nobody voted.")
				voterocked=get_gametime()
				set_task(15.0,"Check_Endround",1337,"",0,"b")
				extended++
			}
		}
		else if(winner[0]==9)
		{
			if(!voterocked2)
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Map extending won. Restarting map.")
				set_task(15.0,"Check_Endround",1337,"",0,"b")
				extended++
			}
			else
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Map extending won. No new map.")
			}
			voterocked=get_gametime()
		}
		else
		{
			new mapname[32]
			get_cvar_string("qq_lastmap",mapname,31)
			set_cvar_string("qq_lastlastmap",mapname)
			get_mapname(mapname,31)
			set_cvar_string("qq_lastmap",mapname)

			
			/*
			if(voterocked2){
				if(equali(winner[0],currentmap)){
				ColorChat(0, GREEN,"^4[SJ] ^1- Chosen map is the same as the current one.")
				voterocked=get_gametime()
				//return PLUGIN_CONTINUE
				}
			}
			*/
			
			if(!voterocked2)
			{
				ColorChat(0, GREEN, "^4[SJ] ^1- Voting Over. Nextmap will be %s.",maps[winner[0]])
				set_cvar_string("amx_nextmap",maps[winner[0]])
				set_task(1.0,"change_level",winner[0],"",0,"d")
			}
			else
			{
				//set_task(5.0,"change_level",winner[0])
				if(equali(maps[winner[0]],currentmap)){
					ColorChat(0, GREEN,"^4[SJ] ^1- Chosen map is the same as the current one.")
					voterocked=get_gametime()
				}
				else
				{
					ColorChat(0, GREEN, "^4[SJ] ^1- Voting Over. Nextmap will be %s.",maps[winner[0]])
					set_task(5.0,"change_level",winner[0])
				}
			}
			format(cur_nextmap,31,"%s",maps[winner[0]])
		}
		for(new i=0;i<=32;i++) rtv[i]=false

		voterocked2=false
	}
}

public change_level(map)
{
	server_cmd("amx_map %s",maps[map])
}

public team_score()
	{
	if(file_exists(configfile) && get_cvar_num("sj_mapchooser")){
		new team[2]
		read_data(1,team,1)
		g_teamScore[(team[0]=='C') ? 0 : 1] = read_data(2)
	}
}

/*
+-----------------------+--------------------------------------------------------------------------+
|			| ************************************************************************ |
|     [TEAM MANAGEMENT]		| ******************************************************************** |
|			| ************************************************************************ |
+-----------------------+--------------------------------------------------------------------------+
*/

public Auto_Team_Balance_Next_Round()
{
	if(!get_pcvar_num(g_pcvarEnable))
		return

	if( balance_teams()  )
	{
		new szMessage[128]
		get_pcvar_string(g_pCvarMessage, szMessage, charsmax(szMessage))
		client_print(0, print_center, szMessage)
		set_task(0.01, "TeamsAutoBalancedMSG")
	}
}

public TeamsAutoBalancedMSG(){
	client_print(0, print_center, "Teams Auto Balanced")
}

cs_set_user_team_custom(id, CsTeams:iTeam)
{
	switch(iTeam)
	{
		case CS_TEAM_T: 
		{
			if( cs_get_user_defuse(id) )
			{
				cs_set_user_defuse(id, 0)
				// set body to 0 ?
			}
		}
		case CS_TEAM_CT:
		{
			if( user_has_weapon(id, CSW_C4) )
			{
				engclient_cmd(id, "drop", "weapon_c4")
			}
		}
	}

	cs_set_user_team(id, iTeam)

	return 1
}

balance_teams()
{
	new aTeams[2][MAX_PLAYERS], aNum[2], id

	for(id = 1; id <= g_iMaxPlayers; id++)
	{
		if(!g_bValid[id])
		{
			continue
		}

		switch( cs_get_user_team(id) )
		{
			case CS_TEAM_T:
			{
				aTeams[aTerro][aNum[aTerro]++] = id
			}
			case CS_TEAM_CT:
			{
				aTeams[aCt][aNum[aCt]++] = id
			}
			default:
			{
				continue
			}
		}
	}

	new iCheck
	new iTimes = aNum[aCt] - aNum[aTerro]

	if(iTimes > 0)
	{
		iCheck = aCt
	}
	else if(iTimes < 0)
	{
		iCheck = aTerro
	}
	else
	{
		return 0
	}

	iTimes = abs(iTimes/2)

	new bool:bTransfered[MAX_PLAYERS+1],
		bool:bAdminsImmune = bool:get_pcvar_num(g_pcvarImmune)

	new iLast, iCount
	while( iTimes > 0 )
	{
		iLast = 0
		for(new i=0; i <aNum[iCheck]; i++)
		{
			id = aTeams[iCheck][i]
			if( g_bImmuned[id] && bAdminsImmune )
			{
				continue
			}
			if(bTransfered[id])
			{
				continue
			}
			if(g_fJoinedTeam[id] > g_fJoinedTeam[iLast])
			{
				iLast = id
			}
		}

		if(!iLast)
		{
			return 0
		}

		cs_set_user_team_custom(iLast, iCheck ? CS_TEAM_T : CS_TEAM_CT)

		bTransfered[iLast] = true
		iCount++
		iTimes--
	}
	return 1
}

/*********** AFK MANAGER ************/

public event_round_start(){

	g_iAFKCheck = get_pcvar_num(CVAR_afk_check)
	if (g_iAFKCheck){

		new iPlayers[32], pNum
		get_players(iPlayers, pNum, "a")
		for (new p = 0; p < pNum; p++){
			get_user_origin(iPlayers[p], g_vOrigin[iPlayers[p]])
		}

		if (!task_exists(TASK_AFK_CHECK)) set_task(FREQ_AFK_CHECK, "func_afk_check", TASK_AFK_CHECK, _, _, "b")

		if (get_pcvar_num(CVAR_afk_transfer_time) < 6) set_pcvar_num(CVAR_afk_transfer_time, 6)
		if (get_pcvar_num(CVAR_afk_kick_time) < 6) set_pcvar_num(CVAR_afk_kick_time, 6)
		g_iTransferTime = get_pcvar_num(CVAR_afk_transfer_time)
		g_iKickTime = get_pcvar_num(CVAR_afk_kick_time)
		g_iMinPlayers = get_pcvar_num(CVAR_afk_kick_players)
	}
	else{
		if (task_exists(TASK_AFK_CHECK)) remove_task(TASK_AFK_CHECK)
	}
}


public event_round_end(){
	g_iAFKCheck = 0
}

public cmd_jointeam(id){
	g_bSpec[id] = true
}

public cmd_joinclass(id){

	g_bSpec[id] = false
	g_vOrigin[id] = {0, 0, 0}
	g_iAFKTime[id] = 0
	g_iWarn[id] = 0
	g_iAFKTime[id]++
}


public cmd_say(id){
	new szMsg[64], szCommand[16], szTrash[2]
	read_args(szMsg, 63)
	remove_quotes(szMsg)
	parse(szMsg, szCommand, 15, szTrash, 1)
	return PLUGIN_CONTINUE
}

public func_afk_check(taskid){
	if (g_iAFKCheck){
		new CsTeams:eTeam
		for (new id = 1; id <= g_iMaxPlayers; id++){
			if (is_user_bot(id)) continue
			if (is_user_connected(id) && !is_user_hltv(id)){
				eTeam = cs_get_user_team(id)
				if (eTeam == CS_TEAM_SPECTATOR || eTeam == CS_TEAM_UNASSIGNED || g_bSpec[id]){
					g_iAFKTime[id]++
					if (g_iAFKTime[id] >= g_iKickTime - MAX_WARN){
						func_kick_player(id)
					}
				}
			}

			if (is_user_alive(id)){
				if (g_iAFKCheck == 1){
					new vOrigin[3]
					get_user_origin(id, vOrigin)

					if (g_vOrigin[id][0] != vOrigin[0] || g_vOrigin[id][1] != vOrigin[1]){
						g_vOrigin[id][0] = vOrigin[0]
						g_vOrigin[id][1] = vOrigin[1]
						g_vOrigin[id][2] = vOrigin[2]
						g_iAFKTime[id] = 0
						g_iWarn[id] = 0
						g_iAFKTime[id]++
					}
					else{
						g_iAFKTime[id]++
					}
				}

				else{
					new Float:fLastActivity
					fLastActivity = cs_get_user_lastactivity(id)

					if (fLastActivity != g_fLastActivity[id]){
						g_fLastActivity[id] = fLastActivity
						g_iAFKTime[id] = 0
						g_iWarn[id] = 0
						g_iAFKTime[id]++
					}
					else{
						g_iAFKTime[id] = floatround((get_gametime() - fLastActivity) / FREQ_AFK_CHECK)
					}
				}
				if (g_iAFKTime[id] >= g_iTransferTime - MAX_WARN){
					func_transfer_player(id)
				}
			}
		}
	}
}

public func_transfer_player(id){
	if (g_iWarn[id] < MAX_WARN){
		ColorChat(id, GREEN, "^4[SJ]^1 - %L", LANG_SERVER, "AFK_TRANSFER_WARN", floatround(FREQ_AFK_CHECK) * (MAX_WARN - g_iWarn[id]))
		g_iWarn[id]++
		return
	}
		
	new sz_name[32]
	get_user_name(id, sz_name, 31)
	new sz_team = get_user_team(id)
	if(sz_team == T){
		ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was transfered to spectators for being AFK.", sz_name)
	} else {
		ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was transfered to spectators for being AFK.", sz_name)
	}

	log_amx("Player ^"%s^" was transfered to the spectators for being AFK.", sz_name)
	
	cs_set_user_team(id, CS_TEAM_SPECTATOR)
	cs_reset_user_model(id)
	g_vOrigin[id] = {0, 0, 0}
	g_iAFKTime[id] = 0
	g_iWarn[id] = 0
	if (is_user_alive(id)){
		user_silentkill(id)
		}
}

public func_kick_player(id){
	if (get_user_flags(id) & KICK_IMMUNITY || g_bSpecAccess[id]) return
	new iCurrentPlayers = get_playersnum(1)

	if (iCurrentPlayers < g_iMinPlayers || !g_iMinPlayers) return

	if (g_iWarn[id] < MAX_WARN){
		ColorChat(id, GREEN, "^4[SJ]^1 - %L", LANG_PLAYER, "AFK_KICK_WARN", floatround(FREQ_AFK_CHECK) * (MAX_WARN - g_iWarn[id]))
		g_iWarn[id]++
		return
	}

	new szMsg[192]
	format(szMsg, 191, "%L", id, "AFK_KICK_REASON")
	server_cmd("kick #%d ^"%s^"", get_user_userid(id), szMsg)

	new sz_name[32]
	get_user_name(id, sz_name, 31)
	new sz_team = get_user_team(id)
	if(sz_team == T){
		ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was kicked for being AFK.", sz_name) 
	} else if(sz_team == CT){
		ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was kicked for being AFK.", sz_name)
	} else {
		ColorChat(0, BLUE, "^4[SJ] ^1- %s was kicked for being AFK.", sz_name)
	}
	log_amx("Player ^"%s^" was kicked for being AFK.", sz_name)
}

/**********ANTI-DEVELOPER**********/

public taskDeveloperCheck() 
{ 
	if(!get_pcvar_num(cv_antideveloper)){
		return
	}
	new players[MAX_PLAYERS], inum 
	get_players(players, inum, "ch") //don't collect BOTs & HLTVs 

	for(new i; i<inum; ++i) 
	{ 
		query_client_cvar(players[i] , "developer" , "cvar_result") 
		query_client_cvar(players[i] , "fps_override" , "cvar_result2") 
		query_client_cvar(players[i] , "fakeloss" , "cvar_result3")
		query_client_cvar(players[i] , "fakelag" , "cvar_result4")
	}
}

public cvar_result(id, const cvar[], const value[]) 
{ 
    new Float:fValue = str_to_float(value)	
	
    if(!fValue) 
        return
    client_cmd(id, "developer 0")
    ColorChat(id, RED, "^4[SJ] ^1- ^3developer ^1is forbidden.") 
     
    if(++g_iCount[id] >= get_pcvar_num(g_pcvarMaxCount)){ 
		server_cmd("kick #%d Developer isn't allowed on this server", get_user_userid(id)) 
	
		new sz_name[32]
		new sz_team = get_user_team(id)
		get_user_name(id, sz_name, 31)
	
		if(sz_team == T){
			ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was kicked for abusing fps.", sz_name)
		} else {
			ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was kicked for abusing fps.", sz_name)
		}
    }
}

public cvar_result2(id, const cvar[], const value[]) 
{ 
    new Float:fValue = str_to_float(value)	
	
    if(!fValue) 
        return
    client_cmd(id, "fps_override 0") 
    ColorChat(id, RED, "^4[SJ] ^1- ^3fps_override ^1is forbidden.") 
     
    if(++g_iCount[id] >= get_pcvar_num(g_pcvarMaxCount)){ 
		server_cmd("kick #%d fps_override isn't allowed on this server", get_user_userid(id)) 
	
		new sz_name[32]
		new sz_team = get_user_team(id)
		get_user_name(id, sz_name, 31)
	
		if(sz_team == T){
			ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was kicked for abusing fps.", sz_name)
		} else {
			ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was kicked for abusing fps.", sz_name)
		}
    }
}

public cvar_result3(id, const cvar[], const value[]) 
{ 
    new Float:fValue = str_to_float(value) 

    if(!fValue) 
        return 
    client_cmd(id, "fakeloss 0") 
    ColorChat(id, RED, "^4[SJ] ^1- ^3fakeloss ^1is forbidden.") 
    if(++g_iCount[id] >= get_pcvar_num(g_pcvarMaxCount)){ 
		server_cmd("kick #%d fakeloss isn't allowed on this server", get_user_userid(id)) 
		
		new sz_name[32]
		new sz_team = get_user_team(id)
		get_user_name(id, sz_name, 31)
		
		if(sz_team == T){
			ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was kicked.", sz_name)
		} else {
			ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was kicked.", sz_name)
		}
    }
}

public cvar_result4(id, const cvar[], const value[]) 
{ 
    new Float:fValue = str_to_float(value) 

    if(!fValue) 
        return 
    client_cmd(id, "fakelag 0") 
    ColorChat(id, RED, "^4[SJ] ^1- ^3fakelag ^1is forbidden.") 
    if(++g_iCount[id] >= get_pcvar_num(g_pcvarMaxCount)){ 
		server_cmd("kick #%d fakelag isn't allowed on this server", get_user_userid(id)) 
		
		new sz_name[32]
		new sz_team = get_user_team(id)
		get_user_name(id, sz_name, 31)
		
		if(sz_team == T){
			ColorChat(0, RED, "^4[SJ] ^1- ^3%s ^1was kicked.", sz_name)
		} else {
			ColorChat(0, BLUE, "^4[SJ] ^1- ^3%s ^1was kicked.", sz_name)
		}
    }
}


/****************************PLUGIN-END******************************/

public plugin_end(){
	TrieDestroy(gTrieStats)

}

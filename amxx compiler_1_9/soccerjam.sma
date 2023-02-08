#pragma dynamic 131072 //I used to much memory =(
/*
 *	CVARs:
 *		- These CVARS can be changed at any time during round!
 *		sj_kick 		(default: 650)	- Default Kicking Speed.
 *		sj_score 		(default: 15)	- Scores needed to win a round.
 *		sj_reset 		(default: 30.0)	- Ball reset time, to respawn at ball spawn location.
 *		sj_goalsafety 	(default: 650)	- Distance around Mascot, that does damage to enemy.
 *		sj_random		(default: 1)	- Turns Team Randomizing ON/OFF.
 *
 *	Requires:	AMXX 1.75+
 *
 *	Author:		OneEyed
 *	IRC:		#soccerjam (irc.gamesurge.net)
 *	Website:	http://www.soccer-jam.com/
 */

/* ------------------------------------------------------------------------- */
/* /----------------------- START OF CUSTOMIZATION  -----------------------/ */
/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/* /------------  CUSTOM DEFINES  ------------ CUSTOM DEFINES  ------------/ */
/* ------------------------------------------------------------------------- */

// Disable knife disarm ? (Leaves only ball disarm)
// Comment this define to disable.
#define KNIFE_DISARM_ON

//When player reaches MAX level, they receive this many levels.
#define MAX_LVL_BONUS 1

//Max levels for each upgrade
#define MAX_LVL_STAMINA		5
#define MAX_LVL_STRENGTH	5
#define MAX_LVL_AGILITY		5
#define MAX_LVL_DEXTERITY	5
#define MAX_LVL_DISARM		5
#define MAX_LVL_POWERPLAY	5

//Prices for each upgrade.
//price = ((UpgradeLevel * UpgradePrice) / 2) + UpgradePrice
#define EXP_PRICE_STAMINA	220
#define EXP_PRICE_STRENGTH	200
#define EXP_PRICE_AGILITY	300
#define EXP_PRICE_DEXTERITY	200
#define EXP_PRICE_DISARM	200

//Experience per stat.
#define EXP_GOALY	100 //for goaly save and goaly points.
#define EXP_STEAL 	100
#define EXP_KILL 	100
#define EXP_ASSIST	200
#define EXP_GOAL	100

#define BASE_HP 100		  	//starting hp
#define BASE_SPEED 	250.0 	//starting run speed
#define BASE_DISARM	80 		//starting disarm from lvl 1

#define COUNTDOWN_TIME 10	//Countdown time between rounds.
#define GOALY_DELAY 8.0		//Delay for goaly exp

//Curve Ball Defines
#define CURVE_ANGLE		15	//Angle for spin kick multipled by current direction.
#define CURVE_COUNT		6	//Curve this many times.
#define CURVE_TIME		0.2	//Time to curve again.
#define DIRECTIONS		2	//# of angles allowed.
#define	ANGLEDIVIDE		6	//Divide angle this many times for curve.

//Misc. amounts
#define AMOUNT_LATEJOINEXP	100	//latejoinexp * each scored point.
#define AMOUNT_POWERPLAY 	5	//added bonus to STR and AGI per powerplay lvl.
#define AMOUNT_GOALY 		7	//Goaly camper exp

//Amount of points for each upgrade.
#define AMOUNT_STA 		20	//Health per lvl
#define AMOUNT_STR 		30	//Stronger kicking per lvl
#define AMOUNT_AGI 		13	//Faster Speed per lvl
#define AMOUNT_DEX 		10	//Better Catching
#define AMOUNT_DISARM 	2	//Disarm ball chance (disarm lvl * this) if random num 1-100 < disarm

#define DISARM_MULTIPLIER 3
/* ------------------------------------------------------------------------- */
/* /----------------  TEAM NAMES  ------------ TEAM NAMES  ------------/ */
/* ------------------------------------------------------------------------- */

#define TEAMS 4 //Don't edit this.

//Names to be put on scoreboard.
static const TeamNames[TEAMS][] = {
	"NULL",
	"Terr",	//Terrorist Team
	"CT",	//CT Team
	"NULL"
}
/* ------------------------------------------------------------------------- */
/* /----------------  MODELS  ---------------- MODELS  ----------------/ */
/* ------------------------------------------------------------------------- */
//You may change the ball model. Just give correct path of new model.
new ball[] = "models/kickball/ball.mdl"

static const TeamMascots[2][] = {
	"models/kingpin.mdl",	//TERRORIST MASCOT
	"models/garg.mdl"		//CT MASCOT
}
/* ------------------------------------------------------------------------- */
/* /----------------  COLORS  ---------------- COLORS  ----------------/ */
/* ------------------------------------------------------------------------- */
//Format is RGB 0-255

//TEAM MODEL GLOW COLORS
#define TERR_GLOW_RED	250
#define TERR_GLOW_GREEN	10
#define	TERR_GLOW_BLUE	10

#define CT_GLOW_RED		10
#define	CT_GLOW_GREEN	10
#define CT_GLOW_BLUE	250

//TEAM HUD METER COLOR (Turbo/Curve Angle meters)
#define TERR_METER_RED		250
#define TERR_METER_GREEN	10
#define	TERR_METER_BLUE		10

#define CT_METER_RED	10
#define	CT_METER_GREEN	10
#define CT_METER_BLUE	250

//BALL GLOW COLOR (default: yellow) //it glows only one color
#define BALL_RED	255
#define BALL_GREEN	200
#define BALL_BLUE	100

//BALL BEAM
#define BALL_BEAM_WIDTH		5
#define BALL_BEAM_LIFE		10
#define BALL_BEAM_RED		250
#define BALL_BEAM_GREEN		80
#define BALL_BEAM_BLUE		10
#define BALL_BEAM_ALPHA		175

/* ------------------------------------------------------------------------- */
/* /----------------  SOUNDS  ---------------- SOUNDS  ----------------/ */
/* ------------------------------------------------------------------------- */
//-- NOTE: Sounds must be located in sound/kickball/ folder.

new BALL_BOUNCE_GROUND[] = "kickball/bounce.wav"
new BALL_RESPAWN[] = "kickball/returned.wav"
new BALL_KICKED[] = "kickball/kicked.wav"
new BALL_PICKED_UP[] = "kickball/gotball.wav"
new UPGRADED_MAX_LEVEL[] = "kickball/levelup.wav"
new ROUND_START[] = "kickball/prepare.wav"
new SCORED_GOAL[] = "kickball/distress.wav"
new STOLE_BALL_FAST[] = "kickball/pussy.wav"

//When a goal is scored, one of these will randomly play.
#define MAX_SOUNDS 6
new SCORED_SOUNDS[MAX_SOUNDS][] = {
	"kickball/amaze.wav",
	"kickball/laugh.wav",
	"kickball/perfect.wav",
	"kickball/diebitch.wav",
	"kickball/bday.wav",
	"kickball/boomchakalaka.wav"
}
/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/* /------------------------ END OF CUSTOMIZATION  ------------------------/ */
/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ------------ DO NOT EDIT BELOW ---------------------------------------------------------- */
/* -------------------------- DO NOT EDIT BELOW -------------------------------------------- */
/* --------------------------------------- DO NOT EDIT BELOW ------------------------------- */
/* ---------------------------------------------------- DO NOT EDIT BELOW ------------------ */

#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>

static const AUTHOR[] = "OneEyed"
static const VERSION[] = "2.07a"

#define MAX_TEXT_BUFFER		2047
#define MAX_NAME_LENGTH		33
#define MAX_PLAYER			33
#define MAX_ASSISTERS		3
#define MAX_BALL_SPAWNS		5
#define POS_X 		-1.0
#define POS_Y 		0.85
#define HUD_CHANNEL 4
#define MESSAGE_DELAY 4.0

enum {
	UNASSIGNED = 0,
	T,
	CT,
	SPECTATOR
}

#define RECORDS 6
enum {
	GOAL = 1,
	ASSIST,
	STEAL,
	KILL,
	DISTANCE,
	GOALY
}

#define UPGRADES 5
enum {
	STA = 1,	//stamina
	STR,		//strength
	AGI,		//agility
	DEX,		//dexterity
	DISARM,
}

static const UpgradeTitles[UPGRADES+1][] = {
	"NULL",
	"Stamina",
	"Strength",
	"Agility",
	"Dexterity",
	"Disarm"
}

new const UpgradeMax[UPGRADES+1] = {
	0, //NULL
	MAX_LVL_STAMINA, 	//STAMINA
	MAX_LVL_STRENGTH, 	//STRENGTH
	MAX_LVL_AGILITY, 	//AGILITY
	MAX_LVL_DEXTERITY, 	//DEXTERITY
	MAX_LVL_DISARM, 	//DISARM
}

new const UpgradePrice[UPGRADES+1] = {
	0, //NULL
	EXP_PRICE_STAMINA,
	EXP_PRICE_STRENGTH,
	EXP_PRICE_AGILITY,
	EXP_PRICE_DEXTERITY,
	EXP_PRICE_DISARM,
}

new TeamColors[TEAMS][3] =
{
	{ 0, 0, 0 },
	{ TERR_GLOW_RED, TERR_GLOW_GREEN, TERR_GLOW_BLUE } ,
	{ CT_GLOW_RED, CT_GLOW_GREEN, CT_GLOW_BLUE },
	{ 0, 0, 0 }
}

new TeamMeterColors[TEAMS][3] =
{
	{ 0, 0, 0 },
	{ TERR_METER_RED, TERR_METER_GREEN, TERR_METER_BLUE } ,
	{ CT_METER_RED, CT_METER_GREEN, CT_METER_BLUE },
	{ 0, 0, 0 }
}


new ballcolor[3] = { BALL_RED, BALL_GREEN, BALL_BLUE }
new PlayerUpgrades[MAX_PLAYER][UPGRADES+1]
new GoalEnt[TEAMS]
new PressedAction[MAX_PLAYER]
new seconds[MAX_PLAYER]
new g_sprint[MAX_PLAYER]
new SideJump[MAX_PLAYER]
new Float:SideJumpDelay[MAX_PLAYER]
new PlayerDeaths[MAX_PLAYER]
new PlayerKills[MAX_PLAYER]
new curvecount
new direction
new maxplayers
new Float:BallSpinDirection[3]
new ballspawncount
new Float:TeamBallOrigins[TEAMS][3]
new Float:TEMP_TeamBallOrigins[3]
new Mascots[TEAMS]
new Float:MascotsOrigins[3]
new Float:MascotsAngles[3]
new menu_upgrade[MAX_PLAYER]
new Float:fire_delay
new winner
new Float:GoalyCheckDelay[MAX_PLAYER]
new GoalyCheck[MAX_PLAYER]
new GoalyPoints[MAX_PLAYER]
new Float:BallSpawnOrigin[MAX_BALL_SPAWNS][3]
new TopPlayer[2][RECORDS+1]
new MadeRecord[MAX_PLAYER][RECORDS+1]
new TopPlayerName[RECORDS+1][MAX_NAME_LENGTH]
new g_Experience[MAX_PLAYER]
new timer
new Float:testorigin[3]
new Float:velocity[3]
new score[TEAMS]
new scoreboard[1025]
new temp1[64], temp2[64]
new distorig[2][3] //distance recorder
new gmsgShake
new gmsgDeathMsg
new gmsgSayText
new gmsgTextMsg
new goaldied[MAX_PLAYER]
new bool:is_dead[MAX_PLAYER]
new terr[33], ct[33], cntCT, cntT
new PowerPlay, powerplay_list[MAX_LVL_POWERPLAY+1]
new assist[16]
new iassist[TEAMS]
new gamePlayerEquip
new CVAR_SCORE
new CVAR_RESET
new CVAR_GOALSAFETY
new CVAR_KICK
new Float:CVAR_RESPAWN
new CVAR_RANDOM
new fire
new smoke
new beamspr
new g_fxBeamSprite
new Burn_Sprite
new ballholder
new ballowner
new aball
new is_kickball
new g_TimeLimit;
new bool:has_knife[MAX_PLAYER]

new OFFSET_INTERNALMODEL;

/*====================================================================================================
 [Precache]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
PrecacheSounds() {
	new x
	for(x=0;x<MAX_SOUNDS;x++)
		engfunc( EngFunc_PrecacheSound, SCORED_SOUNDS[x])

	engfunc( EngFunc_PrecacheSound, STOLE_BALL_FAST)
	engfunc( EngFunc_PrecacheSound, ROUND_START)
	engfunc( EngFunc_PrecacheSound, BALL_BOUNCE_GROUND)
	engfunc( EngFunc_PrecacheSound, BALL_PICKED_UP)
	engfunc( EngFunc_PrecacheSound, BALL_RESPAWN)
	engfunc( EngFunc_PrecacheSound, SCORED_GOAL)
	engfunc( EngFunc_PrecacheSound, BALL_KICKED)
	engfunc( EngFunc_PrecacheSound, UPGRADED_MAX_LEVEL)
}

PrecacheBall() {
	engfunc( EngFunc_PrecacheModel, ball)
}

PrecacheMonsters(team) {
	engfunc( EngFunc_PrecacheModel, TeamMascots[team-1])
}

PrecacheSprites() {
	beamspr = engfunc( EngFunc_PrecacheModel,"sprites/laserbeam.spr")
	fire = engfunc( EngFunc_PrecacheModel,"sprites/shockwave.spr")
	smoke = engfunc( EngFunc_PrecacheModel,"sprites/steam1.spr")
	Burn_Sprite = engfunc( EngFunc_PrecacheModel,"sprites/xfireball3.spr")
	g_fxBeamSprite = engfunc( EngFunc_PrecacheModel,"sprites/lgtning.spr")
}

PrecacheOther() {
	engfunc( EngFunc_PrecacheModel, "models/chick.mdl")
}

/*====================================================================================================
 [Initialize]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public plugin_init() {

	new mapname[64]
	get_mapname(mapname,63)

	register_cvar("soccer_jam_online", "0", FCVAR_SERVER)
	register_cvar("soccer_jam_version", VERSION, FCVAR_SERVER)
	set_cvar_string("soccer_jam_version", VERSION)
	register_dictionary("soccerjam.txt")
	register_dictionary("soccerjam_help.txt")
	if(is_kickball > 0)
	{
		PrecacheSprites()

		register_plugin("Soccer Jam(ON)", VERSION, AUTHOR)
		set_cvar_num("soccer_jam_online", 1)

		timer = COUNTDOWN_TIME

		gmsgTextMsg = get_user_msgid("TextMsg")
		gmsgDeathMsg = get_user_msgid("DeathMsg")
		gmsgShake = get_user_msgid("ScreenShake")
		gmsgSayText = get_user_msgid("SayText")

		maxplayers = get_maxplayers()

		if(equali(mapname,"soccerjam")) {
			PrecacheOther()
			CreateGoalNets()
			create_wall()
		}

		register_clcmd("say","handle_say")

		register_event("ResetHUD", "Event_ResetHud", "be")
		register_event("HLTV","Event_StartRound","a","1=0","2=0")
		register_event("Damage", "Event_Damage", "b", "2!0", "3=0", "4!0" )

		CVAR_SCORE = register_cvar("sj_score","15")
		CVAR_RESET = register_cvar("sj_reset","30.0")
		CVAR_GOALSAFETY = register_cvar("sj_goalsafety","650")
		CVAR_KICK = register_cvar("sj_kick","650")
		CVAR_RESPAWN = 2.0 //register_cvar("kickball_respawn","2.0")
		CVAR_RANDOM = register_cvar("sj_random","1")
		register_cvar( "sj_timelimit", "0" );
		
		register_cvar("SCORE_CT","0")
		register_cvar("SCORE_T","0")

		register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select")

		register_touch("PwnBall", "player", 			"touchPlayer")
		register_touch("PwnBall", "soccerjam_goalnet",	"touchNet")

		register_touch("PwnBall", "worldspawn",			"touchWorld")
		register_touch("PwnBall", "func_wall",			"touchWorld")
		register_touch("PwnBall", "func_door",			"touchWorld")
		register_touch("PwnBall", "func_door_rotating", "touchWorld")
		register_touch("PwnBall", "func_wall_toggle",	"touchWorld")
		register_touch("PwnBall", "func_breakable",		"touchWorld")
		register_touch("PwnBall", "Blocker",			"touchBlocker")

		set_task(0.4,"meter",0,_,_,"b")
		set_task(0.5,"statusDisplay",7654321,"",0,"b")

		register_think("PwnBall","ball_think")
		register_think("Mascot", "mascot_think")

		register_clcmd("radio1", "LeftDirection", 0)
		register_clcmd("radio2", "RightDirection", 0)
		register_clcmd("drop","Turbo")
  	 	register_clcmd("lastinv","BuyUpgrade")
  	 	register_clcmd("fullupdate","fullupdate")
  	 	register_message(gmsgTextMsg, "editTextMsg")

  	 	register_event("ShowMenu", "menuclass", "b", "4&CT_Select", "4&Terrorist_Select");
  	 	register_event("VGUIMenu", "menuclass", "b", "1=26", "1=27");

  	 	OFFSET_INTERNALMODEL = is_amd64_server() ? 152 : 126;
	}
	else {
		register_plugin("Soccer Jam(OFF)", VERSION, AUTHOR)
		set_cvar_num("soccer_jam_online",0)
	}
	return PLUGIN_HANDLED
}

//public plugin_end() {
	//server_cmd("mp_timelimit %i", g_TimeLimit)
//}

/*====================================================================================================
 [Initialize Entities]

 Purpose:	Handles our custom entities, created with Valve Hammer, and fixes for soccerjam.bsp.

 Comment:	$$

====================================================================================================*/
public pfn_keyvalue(entid) {

	new classname[32], key[32], value[32]
	copy_keyvalue(classname, 31, key, 31, value, 31)

	new temp_origins[3][10], x, team
	new temp_angles[3][10]

	if(equal(key, "classname") && equal(value, "soccerjam_goalnet"))
		DispatchKeyValue("classname", "func_wall")

	if(equal(classname, "game_player_equip")){
		if(!is_kickball || !gamePlayerEquip)
			gamePlayerEquip = entid
		else {
			remove_entity(entid)
		}
	}
	else if(equal(classname, "func_wall"))
	{
		if(equal(key, "team"))
		{
			team = str_to_num(value)
			if(team == 1 || team == 2) {
				GoalEnt[team] = entid
				set_task(1.0, "FinalizeGoalNet", team)
			}
		}
	}
	else if(equal(classname, "soccerjam_mascot"))
	{

		if(equal(key, "team"))
		{
			team = str_to_num(value)
			create_mascot(team)
		}
		else if(equal(key, "origin"))
		{
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x=0; x<3; x++)
				MascotsOrigins[x] = floatstr(temp_origins[x])
		}
		else if(equal(key, "angles"))
		{
			parse(value, temp_angles[0], 9, temp_angles[1], 9, temp_angles[2], 9)
			for(x=0; x<3; x++)
				MascotsAngles[x] = floatstr(temp_angles[x])
		}
	}
	else if(equal(classname, "soccerjam_teamball"))
	{
		if(equal(key, "team"))
		{
			team = str_to_num(value)
			for(x=0; x<3; x++)
				TeamBallOrigins[team][x] = TEMP_TeamBallOrigins[x]
		}
		else if(equal(key, "origin"))
		{
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x=0; x<3; x++)
				TEMP_TeamBallOrigins[x] = floatstr(temp_origins[x])
		}
	}
	else if(equal(classname, "soccerjam_ballspawn"))
	{
		if(equal(key, "origin")) {
			is_kickball = 1

			create_Game_Player_Equip()

			PrecacheBall()
			PrecacheSounds()

			if(ballspawncount < MAX_BALL_SPAWNS) {
				parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)

				BallSpawnOrigin[ballspawncount][0] = floatstr(temp_origins[0])
				BallSpawnOrigin[ballspawncount][1] = floatstr(temp_origins[1])
				BallSpawnOrigin[ballspawncount][2] = floatstr(temp_origins[2]) + 10.0

				ballspawncount++
			}
		}
	}
}

createball() {

	new entity = create_entity("info_target")
	if (entity) {

		entity_set_string(entity,EV_SZ_classname,"PwnBall")
		entity_set_model(entity, ball)

		entity_set_int(entity, EV_INT_solid, SOLID_BBOX)
		entity_set_int(entity, EV_INT_movetype, MOVETYPE_BOUNCE)

		new Float:MinBox[3]
		new Float:MaxBox[3]
		MinBox[0] = -15.0
		MinBox[1] = -15.0
		MinBox[2] = 0.0
		MaxBox[0] = 15.0
		MaxBox[1] = 15.0
		MaxBox[2] = 12.0

		entity_set_vector(entity, EV_VEC_mins, MinBox)
		entity_set_vector(entity, EV_VEC_maxs, MaxBox)

		glow(entity,ballcolor[0],ballcolor[1],ballcolor[2],10)

		entity_set_float(entity,EV_FL_framerate,0.0)
		entity_set_int(entity,EV_INT_sequence,0)
	}
	//save our entity ID to aball variable
	aball = entity
	entity_set_float(entity,EV_FL_nextthink,halflife_time() + 0.05)
	return PLUGIN_HANDLED
}


CreateGoalNets() {

	new endzone, x
	new Float:orig[3]
	new Float:MinBox[3], Float:MaxBox[3]

	for(x=1;x<3;x++) {
		endzone = create_entity("info_target")
		if (endzone) {

			entity_set_string(endzone,EV_SZ_classname,"soccerjam_goalnet")
			entity_set_model(endzone, "models/chick.mdl")
			entity_set_int(endzone, EV_INT_solid, SOLID_BBOX)
			entity_set_int(endzone, EV_INT_movetype, MOVETYPE_NONE)

			MinBox[0] = -25.0;	MinBox[1] = -145.0;	MinBox[2] = -36.0
			MaxBox[0] =  25.0;	MaxBox[1] =  145.0;	MaxBox[2] =  70.0

			entity_set_vector(endzone, EV_VEC_mins, MinBox)
			entity_set_vector(endzone, EV_VEC_maxs, MaxBox)

			switch(x) {
				case 1: {
					orig[0] = 2110.0
					orig[1] = 0.0
					orig[2] = 1604.0
				}
				case 2: {
					orig[0] = -2550.0
					orig[1] = 0.0
					orig[2] = 1604.0
				}
			}

			entity_set_origin(endzone,orig)

			entity_set_int(endzone, EV_INT_team, x)
			set_entity_visibility(endzone, 0)
			GoalEnt[x] = endzone
		}
	}

}

create_wall() {
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

create_mascot(team)
{
	new Float:MinBox[3], Float:MaxBox[3]
	new mascot = create_entity("info_target")
	if(mascot)
	{
		PrecacheMonsters(team)
		entity_set_string(mascot,EV_SZ_classname,"Mascot")
		entity_set_model(mascot, TeamMascots[team-1])
		Mascots[team] = mascot

		entity_set_int(mascot, EV_INT_solid, SOLID_NOT)
		entity_set_int(mascot, EV_INT_movetype, MOVETYPE_NONE)
		entity_set_int(mascot, EV_INT_team, team)
		MinBox[0] = -16.0;	MinBox[1] = -16.0;	MinBox[2] = -72.0
		MaxBox[0] =  16.0;	MaxBox[1] =  16.0;	MaxBox[2] =  72.0
		entity_set_vector(mascot, EV_VEC_mins, MinBox)
		entity_set_vector(mascot, EV_VEC_maxs, MaxBox)
		//orig[2] += 200.0

		entity_set_origin(mascot,MascotsOrigins)
		entity_set_float(mascot,EV_FL_animtime,2.0)
		entity_set_float(mascot,EV_FL_framerate,1.0)
		entity_set_int(mascot,EV_INT_sequence,0)

		if(team == 2)
			entity_set_byte(mascot, EV_BYTE_controller1, 115)

		entity_set_vector(mascot,EV_VEC_angles,MascotsAngles)
		entity_set_float(mascot,EV_FL_nextthink,halflife_time() + 1.0)
	}
}

create_Game_Player_Equip() {
	gamePlayerEquip = create_entity("game_player_equip")
	if(gamePlayerEquip) {
		//DispatchKeyValue(gamePlayerEquip, "weapon_knife", "1")
		//DispatchKeyValue(entity, "weapon_scout", "1")
		DispatchKeyValue(gamePlayerEquip, "targetname", "roundstart")
		DispatchSpawn(gamePlayerEquip)
	}

}

public FinalizeGoalNet(team)
{
	new goalnet = GoalEnt[team]
	entity_set_string(goalnet,EV_SZ_classname,"soccerjam_goalnet")
	entity_set_int(goalnet, EV_INT_team, team)
	set_entity_visibility(goalnet, 0)
}

public RightDirection(id) {

	if(id == ballholder) {

		direction--
		if(direction < -(DIRECTIONS))
			direction = -(DIRECTIONS)
		new temp = direction * CURVE_ANGLE
		SendCenterText( id, temp );
		
	}
	else
		client_print(id, print_chat, "%L", id, "CANT_CURVE_RIGHT");
	return PLUGIN_HANDLED
}

public LeftDirection(id) {
	if(id == ballholder) {
		direction++
		if(direction > DIRECTIONS)
			direction = DIRECTIONS
		new temp = direction * CURVE_ANGLE
		SendCenterText( id, temp );
		
	}
	else {
		client_print(id, print_chat, "%L", id, "CANT_CURVE_LEFT");
	}
	return PLUGIN_HANDLED
}


SendCenterText( id, dir )
{
	if(dir < 0)
		client_print(id, print_center, "%L", id, "CURVING_RIGHT", (dir<0?-(dir):dir));
	else if(dir == 0)
		client_print(id, print_center, "0 degrees");
	else if(dir > 0)
		client_print(id, print_center, "%L", id, "CURVING_LEFT", (dir<0?-(dir):dir));
}

public plugin_cfg() {
	if(is_kickball) {
		server_cmd("sv_maxspeed 999")
		server_cmd("sv_airaccelerate 10")
		
		//Fallback to make sure our mp_timelimit is correct.
		new mpTimelimit = get_cvar_num("mp_timelimit");
		new sjTimelimit = get_cvar_num("sj_timelimit");
		
		if( mpTimelimit > 3 )
			set_cvar_num("sj_timelimit", mpTimelimit);
		else {
			if(mpTimelimit && sjTimelimit > 3 )
				set_cvar_num("mp_timelimit", sjTimelimit);
		}
			
	}
	else {
		//server_cmd("exec server.cfg")
		new failed[64];
		format(failed,63,"%L", LANG_SERVER, "PLUGIN_FAILED");
		set_fail_state(failed);
	}
}

/*====================================================================================================
 [Ball Brain]

 Purpose:	These functions help control the ball and its activities.

 Comment:	$$

====================================================================================================*/
public ball_think() {

	new maxscore = get_pcvar_num(CVAR_SCORE)
	if(score[1] >= maxscore || score[2] >= maxscore) {
		entity_set_float(aball,EV_FL_nextthink,halflife_time() + 0.05)
		return PLUGIN_HANDLED
	}

	if(is_valid_ent(aball))
	{

		new Float:gametime = get_gametime()
		if(PowerPlay >= MAX_LVL_POWERPLAY && gametime - fire_delay >= 0.3)
			on_fire()

		if(ballholder > 0)
		{
			new team = get_user_team(ballholder)
			entity_get_vector(ballholder, EV_VEC_origin,testorigin)


			if(!is_user_alive(ballholder)) {

				new tname[32]
				get_user_name(ballholder,tname,31)

				remove_task(55555)
				set_task(get_pcvar_float(CVAR_RESET),"clearBall",55555)

				if(!g_sprint[ballholder])
					set_speedchange(ballholder)

				format(temp1,63,"%L", LANG_PLAYER, "DROPPED_BALL", TeamNames[team], tname)

				//remove glow of owner and set ball velocity really really low
				glow(ballholder,0,0,0,0)

				ballowner = ballholder
				ballholder = 0

				testorigin[2] += 5
				entity_set_origin(aball, testorigin)

				new Float:vel[3], x
				for(x=0;x<3;x++)
					vel[x] = 1.0

				entity_set_vector(aball,EV_VEC_velocity,vel)
				entity_set_float(aball,EV_FL_nextthink,halflife_time() + 0.05)
				return PLUGIN_HANDLED
			}
			if(entity_get_int(aball,EV_INT_solid) != SOLID_NOT)
				entity_set_int(aball, EV_INT_solid, SOLID_NOT)

			//Put ball in front of player
			ball_infront(ballholder, 55.0)
			new i
			for(i=0;i<3;i++)
				velocity[i] = 0.0
			//Add lift to z axis
			new flags = entity_get_int(ballholder, EV_INT_flags)
			if(flags & FL_DUCKING)
				testorigin[2] -= 10
			else
				testorigin[2] -= 30

			entity_set_vector(aball,EV_VEC_velocity,velocity)
	  		entity_set_origin(aball,testorigin)
		}
		else {
			if(entity_get_int(aball,EV_INT_solid) != SOLID_BBOX)
				entity_set_int(aball, EV_INT_solid, SOLID_BBOX)
		}
	}
	entity_set_float(aball,EV_FL_nextthink,halflife_time() + 0.05)
	return PLUGIN_HANDLED
}

moveBall(where, team=0) {

	if(is_valid_ent(aball)) {
		if(team) {
			new Float:bv[3]
			bv[2] = 50.0
			entity_set_origin(aball, TeamBallOrigins[team])
			entity_set_vector(aball,EV_VEC_velocity,bv)
		}
		else {
			switch(where) {
				case 0: { //outside map
					new Float:orig[3], x
					for(x=0;x<3;x++)
						orig[x] = -9999.9
					entity_set_origin(aball,orig)
					ballholder = -1
				}
				case 1: { //at middle

					new Float:v[3], rand
					v[2] = 400.0
					if(ballspawncount > 1)
						rand = random_num(0, ballspawncount-1)
					else
						rand = 0

					entity_set_origin(aball, BallSpawnOrigin[rand])
					entity_set_vector(aball, EV_VEC_velocity, v)

					PowerPlay = 0
					ballholder = 0
					ballowner = 0
				}
			}
		}
	}
}

public ball_infront(id, Float:dist) {

	new Float:nOrigin[3]
	new Float:vAngles[3] // plug in the view angles of the entity
	new Float:vReturn[3] // to get out an origin fDistance away

	entity_get_vector(aball,EV_VEC_origin,testorigin)
	entity_get_vector(id,EV_VEC_origin,nOrigin)
	entity_get_vector(id,EV_VEC_v_angle,vAngles)


	vReturn[0] = floatcos( vAngles[1], degrees ) * dist
	vReturn[1] = floatsin( vAngles[1], degrees ) * dist

	vReturn[0] += nOrigin[0]
	vReturn[1] += nOrigin[1]

	testorigin[0] = vReturn[0]
	testorigin[1] = vReturn[1]
	testorigin[2] = nOrigin[2]

	/*
	//Sets the angle to face the same as the player.
	new Float:ang[3]
	entity_get_vector(id,EV_VEC_angles,ang)
	ang[0] = 0.0
	ang[1] -= 90.0
	ang[2] = 0.0
	entity_set_vector(aball,EV_VEC_angles,ang)
	*/
}


public CurveBall(id) {
	if(direction && get_speed(aball) > 5 && curvecount > 0) {

		new Float:dAmt = float((direction * CURVE_ANGLE) / ANGLEDIVIDE);
		new Float:v[3], Float:v_forward[3];
		
		entity_get_vector(aball, EV_VEC_velocity, v);
		vector_to_angle(v, BallSpinDirection);

		BallSpinDirection[1] = normalize( BallSpinDirection[1] + dAmt );
		BallSpinDirection[2] = 0.0;
		
		angle_vector(BallSpinDirection, 1, v_forward);
		
		new Float:speed = vector_length(v)// * 0.95;
		v[0] = v_forward[0] * speed
		v[1] = v_forward[1] * speed
		
		entity_set_vector(aball, EV_VEC_velocity, v);

		curvecount--;
		set_task(CURVE_TIME, "CurveBall", id);
	}
}

public clearBall() {
	play_wav(0, BALL_RESPAWN);
	format(temp1,63,"%L",LANG_PLAYER,"BALL_RESPAWNED")
	moveBall(1)
}

/*====================================================================================================
 [Mascot Think]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public mascot_think(mascot)
{
	new team = entity_get_int(mascot, EV_INT_team)
	new indist[32], inNum, chosen

	new id, playerteam, dist
	for(id=1 ; id<=maxplayers ; id++)
	{
		if(is_user_alive(id) && !is_user_bot(id))
		{
			playerteam = get_user_team(id)
			if(playerteam != team)
			{
				if(!chosen) {
					dist = get_entity_distance(id, mascot)
					if(dist < get_pcvar_num(CVAR_GOALSAFETY))
						if(id == ballholder) {
							chosen = id
							break
						}
						else
							indist[inNum++] = id
				}
			}
		}
	}
	if(!chosen) {
		new rnd = random_num(0, (inNum-1))
		chosen = indist[rnd]
	}
	if(chosen)
		TerminatePlayer(chosen, mascot, team, ( ballholder == chosen ? 230.0 : random_float(5.0, 15.0) ) )
	entity_set_float(mascot,EV_FL_nextthink,halflife_time() + 1.0)
}

goaly_checker(id, Float:gametime, team) {
	if(!is_user_alive(id) || (gametime - GoalyCheckDelay[id] < GOALY_DELAY) )
		return PLUGIN_HANDLED

	new dist, gcheck
	new Float:pOrig[3]
	entity_get_vector(id, EV_VEC_origin, pOrig)
	dist = floatround(get_distance_f(pOrig, TeamBallOrigins[team]))

	//--/* Goaly Exp System */--//
	if(dist < 600 ) {

		gcheck = GoalyCheck[id]

		if(id == ballholder && gcheck >= 2)
			kickBall(id, 1)

		GoalyPoints[id]++

		if(gcheck < 2)
			g_Experience[id] += gcheck * AMOUNT_GOALY
		else
			g_Experience[id] += gcheck * (AMOUNT_GOALY / 2)

		if(gcheck < 5)
			GoalyCheck[id]++

		GoalyCheckDelay[id] = gametime
	}
	else
		GoalyCheck[id] = 0
	return PLUGIN_HANDLED
}

/*====================================================================================================
 [Status Display]

 Purpose:	Displays the Scoreboard information.

 Comment:	$$

====================================================================================================*/
public statusDisplay()
{
	new id, team, bteam = get_user_team(ballholder>0?ballholder:ballowner)
	new score_t = score[T], score_ct = score[CT]

	set_hudmessage(20, 255, 20, 0.95, 0.20, 0, 1.0, 1.5, 0.1, 0.1, HUD_CHANNEL)
	new Float:gametime = get_gametime()

	for(id=1; id<=maxplayers; id++) {
		if(is_user_connected(id) && !is_user_bot(id))
		{
			team = get_user_team(id)
			goaly_checker(id, gametime, team)
			if(!is_user_alive(id) && !is_dead[id] && (team == 1 || team == 2) && GetPlayerModel(id) != 0xFF)
			{
				//new Float:ballorig[3], x
				//entity_get_vector(id,EV_VEC_origin,ballorig)
				//for(x=0;x<3;x++)
				//	distorig[0][x] = floatround(ballorig[x])
				remove_task(id+1000)
				has_knife[id] = false;
				is_dead[id] = true
				new Float:respawntime = CVAR_RESPAWN
				set_task(respawntime,"AutoRespawn",id)
				set_task((respawntime+0.2), "AutoRespawn2",id)
			}
			if(!winner) {
				format(scoreboard,1024,"   %i %L^n%s - %i  |  %s - %i ^n%L %i ^n^n%s^n^n^n%s",get_pcvar_num(CVAR_SCORE),id,"GOALS_WINS",TeamNames[T],score_t,TeamNames[CT],score_ct,id,"EXPERIENCE",g_Experience[id],temp1,team==bteam?temp2:"")
				show_hudmessage(id,"%s",scoreboard)
			}
		}
	}
}

/*====================================================================================================
 [Touched]

 Purpose:	All touching stuff takes place here.

 Comment:	$$

====================================================================================================*/
public touchWorld(ball, world) {

	if(get_speed(ball) > 10)
	{
		new Float:v[3]
		entity_get_vector(ball, EV_VEC_velocity, v)

		v[0] = (v[0] * 0.85)
		v[1] = (v[1] * 0.85)
		v[2] = (v[2] * 0.85)
		entity_set_vector(ball, EV_VEC_velocity, v)
		emit_sound(ball, CHAN_ITEM, BALL_BOUNCE_GROUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	return PLUGIN_HANDLED
}

public touchPlayer(ball, player) {

	if(is_user_bot(player))
		return PLUGIN_HANDLED

	new playerteam = get_user_team(player)
	if((playerteam != 1 && playerteam != 2))
		return PLUGIN_HANDLED

	remove_task(55555)

	new aname[64], stolen, x
	get_user_name(player,aname,63)
	new ballteam = get_user_team(ballowner)
	if(ballowner > 0 && playerteam != ballteam )
	{
		new speed = get_speed(aball)
		if(speed > 500)
		{
			//configure catching algorithm
			new rnd = random_num(0,100)
			new bstr = (PlayerUpgrades[ballowner][STR] * AMOUNT_STR) / 10
			new dex = (PlayerUpgrades[player][DEX] * AMOUNT_DEX)
			new pct = ( PressedAction[player] ? 40:20 ) + dex

			pct += ( g_sprint[player] ? 5 : 0 )		//player turboing? give 5%
			pct -= ( g_sprint[ballowner] ? 5 : 0 ) 	//ballowner turboing? lose 5%
			pct -= bstr						//ballowner has strength? remove bstr

			//will player avoid damage?
			if( rnd > pct ) {
				new Float:dodmg = (float(speed) / 13.0) + bstr

				client_print(0,print_chat,"%L",LANG_PLAYER,"BALL_SMACKED",aname,floatround(dodmg))

				set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
				fakedamage(player,"AssWhoopin",dodmg,1)
				set_msg_block(gmsgDeathMsg,BLOCK_NOT)

				if(!is_user_alive(player)) {
					message_begin(MSG_ALL, gmsgDeathMsg)
					write_byte(ballowner)
					write_byte(player)
					write_string("AssWhoopin")
					message_end()

					new frags = get_user_frags(ballowner)
					entity_set_float(ballowner, EV_FL_frags, float(frags + 1))
					setScoreInfo(ballowner)
					//set_user_frags(ballowner, get_user_frags(ballowner)+1)
					Event_Record(ballowner, KILL, -1, EXP_KILL)

					client_print(player,print_chat,"%L",player,"KILLED_BY_BALL")
					client_print(ballowner,print_chat,"%L",ballowner,"EXP_FOR_BALLKILL")
				}
				else {
					new Float:pushVel[3]
					pushVel[0] = velocity[0]
					pushVel[1] = velocity[1]
					pushVel[2] = velocity[2] + ((velocity[2] < 0)?random_float(-200.0,-50.0):random_float(50.0,200.0))
					entity_set_vector(player,EV_VEC_velocity,pushVel)
				}
				for(x=0;x<3;x++)
					velocity[x] = (velocity[x] * random_float(0.1,0.9))
				entity_set_vector(aball,EV_VEC_velocity,velocity)
				direction = 0
				return PLUGIN_HANDLED
			}
		}

		if(speed > 950)
			play_wav(0, STOLE_BALL_FAST)

		new Float:pOrig[3]
		entity_get_vector(player, EV_VEC_origin, pOrig)
		new dist = floatround(get_distance_f(pOrig, TeamBallOrigins[playerteam]))
		new gainedxp

		if(dist < 550) {
			gainedxp = EXP_STEAL + EXP_GOALY + (speed / 8)
			Event_Record(player, STEAL, -1, EXP_STEAL + EXP_GOALY + (speed / 8))
			GoalyPoints[player] += EXP_GOALY/2
		}
		else {
			gainedxp = EXP_STEAL
			Event_Record(player, STEAL, -1, EXP_STEAL)
		}

		format(temp1,63,"%L",LANG_PLAYER,"STOLE_BALL",TeamNames[playerteam],aname)
		client_print(0,print_console,"%s",temp1)
		stolen = 1

		message_begin(MSG_ONE, gmsgShake, {0,0,0}, player)
		write_short(255 << 12) //ammount
		write_short(1 << 11) //lasts this long
		write_short(255 << 10) //frequency
		message_end()

		client_print(player,print_chat,"%L",player,"EXP_FOR_STEAL",gainedxp)

	}
	if(ballholder == 0) {
		emit_sound(aball, CHAN_ITEM, BALL_PICKED_UP, 1.0, ATTN_NORM, 0, PITCH_NORM)
		new msg[64], check
		if(!has_knife[player])
			give_knife(player)

		if(stolen)
			PowerPlay = 0
		else
			format(temp1,63,"%L",LANG_PLAYER,"BALL_PICKUP",TeamNames[playerteam],aname)

		if(((PowerPlay > 1 && powerplay_list[PowerPlay-2] == player) || (PowerPlay > 0 && powerplay_list[PowerPlay-1] == player)) && PowerPlay != MAX_LVL_POWERPLAY)
			check = true

		if(PowerPlay <= MAX_LVL_POWERPLAY && !check) {
			g_Experience[player] += (PowerPlay==2?10:25)
			powerplay_list[PowerPlay] = player
			PowerPlay++
		}
		curvecount = 0
		direction = 0
		GoalyCheck[player] = 0

		format(temp2, 63, "%L %i",LANG_PLAYER,"POWER_PLAY", PowerPlay>0?PowerPlay-1:0)

		ballholder = player
		ballowner = 0

		if(!g_sprint[player])
			set_speedchange(player)


		set_hudmessage(255, 20, 20, POS_X, 0.4, 1, 1.0, 1.5, 0.1, 0.1, 2)
		format(msg,63,"%L",player,"YOU_HAVE_BALL")
		show_hudmessage(player,"%s",msg)

		//Glow Player who has ball their team color
		beam()
		glow(player, TeamColors[playerteam][0], TeamColors[playerteam][1], TeamColors[playerteam][2], 1)
	}
	return PLUGIN_HANDLED
}

public touchNet(ball, goalpost)
{
	remove_task(55555)

	new team = get_user_team(ballowner)
	new goalent = GoalEnt[team]
	if (goalpost != goalent && ballowner > 0) {
		new aname[64]
		new Float:netOrig[3]
		new netOrig2[3]

		entity_get_vector(ball, EV_VEC_origin,netOrig)
		new l
		for(l=0;l<3;l++)
			netOrig2[l] = floatround(netOrig[l])
		flameWave(netOrig2)
		get_user_name(ballowner,aname,63)
		new frags = get_user_frags(ballowner)
		entity_set_float(ballowner, EV_FL_frags, float(frags + 1))

		play_wav(0, SCORED_GOAL)

		/////////////////////ASSIST CODE HERE///////////

		new assisters[4] = { 0, 0, 0, 0 }
		new iassisters = 0
		new ilastplayer = iassist[ team ]

		// We just need the last player to kick the ball
		// 0 means it has passed 15 at least once
		if ( ilastplayer == 0 )
			ilastplayer = 15
		else
			ilastplayer--

		if ( assist[ ilastplayer ] != 0 ) {
			new i, x, bool:canadd, playerid
			for(i=0; i<16; i++) {
				// Stop if we've already found 4 assisters
				if ( iassisters == MAX_ASSISTERS )
					break
				playerid = assist[ i ]
				// Skip if player is invalid
				if ( playerid == 0 )
					continue
				// Skip if kicker is counted as an assister
				if ( playerid == assist[ ilastplayer ] )
					continue

				canadd = true
				// Loop through each assister value
				for(x=0; x<3; x++)
					// make sure we can add them
					if ( playerid == assisters[ x ] ) {
						canadd = false
						break
					}

				// Skip if they've already been added
				if ( canadd == false )
					continue
				// They didn't kick the ball last, and they haven't been added, add them
				assisters[ iassisters++ ] = playerid
			}
			// This gives each person an assist, xp, and prints that out to them
			new c, pass
			for(c=0; c<iassisters; c++) {
				pass = assisters[ c ]
				Event_Record(pass, ASSIST, -1, EXP_ASSIST)
				client_print( pass, print_chat, "%L",pass,"EXP_FOR_ASSIST",EXP_ASSIST)
			}
		}
		iassist[ 0 ] = 0
		/////////////////////ASSIST CODE HERE///////////

		for(l=0; l<3; l++)
			distorig[1][l] = floatround(netOrig[l])
		new distshot = (get_distance(distorig[0],distorig[1])/12)
		new gainedxp = distshot + EXP_GOAL

		format(temp1,63,"%L",LANG_PLAYER,"SCORED_GOAL",TeamNames[team],aname,distshot)
		client_print(0,print_console,"%s",temp1)


		if(distshot > MadeRecord[ballowner][DISTANCE])
			Event_Record(ballowner, DISTANCE, distshot, 0)// record distance, and make that distance exp

		Event_Record(ballowner, GOAL, -1, gainedxp)	//zero xp for goal cause distance is what gives it.

		//Increase Score, and update cvar score
		score[team]++
		switch(team) {
			case 1: set_cvar_num("score_ct",score[team])
			case 2: set_cvar_num("score_t",score[team])
		}
		client_print(ballowner,print_chat,"%L",ballowner,"EXP_FOR_GOAL",gainedxp,distshot)

		new oteam = (team == 1 ? 2 : 1)
		increaseTeamXP(team, 75)
		increaseTeamXP(oteam, 50)
		moveBall(0)

		new x
		for(x=1; x<=maxplayers; x++) {
			if(is_user_connected(x))
			{
				Event_Record(x, GOALY, GoalyPoints[x], 0)
				new kills = get_user_frags(x)
				new deaths = cs_get_user_deaths(x)
				setScoreInfo(x)
				if( deaths > 0)
					PlayerDeaths[x] = deaths
				if( kills > 0)
					PlayerKills[x] = kills
			}
		}

		if(score[team] < get_pcvar_num(CVAR_SCORE)) {
			new r = random_num(0,MAX_SOUNDS-1)
			play_wav(0, SCORED_SOUNDS[r]);

		}
		else {
			winner = team
			format(scoreboard,1024,"%L",LANG_PLAYER,"TEAM_WINS",TeamNames[team])
			set_task(1.0,"showhud_winner",0,"",0,"a",3)
		}

		server_cmd("sv_restart 4")

	}
	else if(goalpost == goalent) {
		moveBall(0, team)
		client_print(ballowner,print_chat,"%L",ballowner,"CANNOT_KICK_GOAL")
	}
	return PLUGIN_HANDLED
}

//This is for soccerjam.bsp to fix locker room.
public touchBlocker(pwnball, blocker) {
	new Float:orig[3] = { 2234.0, 1614.0, 1604.0 }
	entity_set_origin(pwnball, orig)
}

/*====================================================================================================
 [Events]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
//public Event_DeathMsg() {
//	new id = read_data(2)
//	strip_user_weapons(id);
//}

public Event_Damage()
{
	new victim = read_data(0)
	new attacker = get_user_attacker(victim)
	if(is_user_alive(attacker)) {
		if(is_user_alive(victim) ) {

			#if !defined KNIFE_DISARM_ON
			if(victim == ballholder) {
			#endif
				new upgrade = PlayerUpgrades[attacker][DISARM]
				if(upgrade) {
					new disarm = upgrade * AMOUNT_DISARM
					new disarmpct = BASE_DISARM + (victim==ballholder?(disarm*2):0)
					new rand = random_num(1,100)

					if(disarmpct >= rand)
					{
						new vname[32], aname[32]
						get_user_name(victim,vname,31)
						get_user_name(attacker,aname,31)

						#if defined KNIFE_DISARM_ON
						if(victim == ballholder) {
						#endif
							kickBall(victim, 1)
							client_print(attacker,print_chat,"%L",attacker,"DISARM_BALL_ATTACKER",vname)
							client_print(victim,print_chat,"%L",victim,"DISARM_BALL_VICTIM",aname)
						#if defined KNIFE_DISARM_ON
						}
						else {
							new weapon, clip, ammo
							weapon = get_user_weapon(victim,clip,ammo)
							if(weapon == CSW_KNIFE)
							{
								strip_user_weapons(victim);
								has_knife[victim] = false;
								set_task(float(disarm / DISARM_MULTIPLIER), "give_knife", victim+1000)
								client_print(attacker,print_chat,"%L",attacker,"DISARM_KNIFE_ATTACKER",vname)
								client_print(victim,print_chat,"%L",victim,"DISARM_KNIFE_VICTIM",aname)
							}
						}
						#endif
					}
				}
			#if !defined KNIFE_DISARM_ON
			}
			#endif
		}
		else
			g_Experience[attacker] += (EXP_KILL/2)
	}
}

public Event_StartRound()
{
	g_TimeLimit = get_cvar_num("mp_timelimit");
	if(winner)
	{
		set_task(1.0,"displayWinnerAwards",0)

		//MP_TIMELIMIT replication
		new Float:gtime = float(g_TimeLimit) - (get_gametime() / 60.0);

		if( g_TimeLimit && gtime <= 0.0 )
		{
			//Fix for Map Vote plugins (2 min marker).
			new bool:check;
			if(cvar_exists("amx_extendmap_max"))
				check = true;

			server_cmd("mp_timelimit %i", (check ? 2 : 1));
			set_task(10.0, "CheckExtendMap", 555666, "", 0, "b");
		}
		else
			set_task(10.0,"PostGame",0)
	}
	else
		SetupRound()
}

public CheckExtendMap() {

	new timelimit = get_cvar_num("mp_timelimit");
	if(timelimit > g_TimeLimit) {
		PostGame();
		remove_task(555666);
	}
}

public SetupRound() {

	iassist[ 0 ] = 0

	if(!is_valid_ent(aball))
		createball()

	moveBall(1)

	new id
	for(id=1; id<=maxplayers; id++) {
		if(is_user_connected(id) && !is_user_bot(id)) {
			is_dead[id] = false
			seconds[id] = 0
			g_sprint[id] = 0
			PressedAction[id] = 0
		}
	}
	play_wav(0, ROUND_START)

	set_task(0.5, "PostSetupRound", 0)
	set_task(1.0, "PostPostSetupRound", 0)

	return PLUGIN_HANDLED
}

public PostSetupRound() {
	new id
	for(id=1; id<=maxplayers; id++)
		if(is_user_alive(id) && !is_user_bot(id))
			give_knife(id)
}

public PostPostSetupRound() {
	new id, kills, deaths
	for(id=1; id<=maxplayers; id++) {
		if(is_user_connected(id) && !is_user_bot(id)) {
			kills = PlayerKills[id]
			deaths = PlayerDeaths[id]
			if(kills)
				entity_set_float(id, EV_FL_frags, float(kills))
			if(deaths)
				cs_set_user_deaths(id,deaths)

			setScoreInfo(id)
		}
	}
}

public Event_ResetHud(id) {
	goaldied[id] = 0
	set_task(1.0,"PostResetHud",id)
}

public PostResetHud(id) {
	if(is_user_alive(id) && !is_user_bot(id))
	{
		new stam = PlayerUpgrades[id][STA]

		if(!has_knife[id]) {
			give_knife(id)
		}

		//compensate for our turbo
		if(!g_sprint[id])
			set_speedchange(id)

		if(stam > 0)
			entity_set_float(id, EV_FL_health, float(BASE_HP + (stam * AMOUNT_STA)))
	}
}

/*====================================================================================================
 [Client Commands]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public Turbo(id)
{
	if(is_user_alive(id))
		g_sprint[id] = 1
	return PLUGIN_HANDLED
}

public client_PreThink(id)
{
	if( is_kickball && is_valid_ent(aball) && is_user_connected(id))
	{
		new button = entity_get_int(id, EV_INT_button)
		new usekey = (button & IN_USE)

		new up = (button & IN_FORWARD)
		new down = (button & IN_BACK)
		new moveright = (button & IN_MOVERIGHT)
		new moveleft = (button & IN_MOVELEFT)
		new jump = (button & IN_JUMP)
		new flags = entity_get_int(id, EV_INT_flags)
		new onground = flags & FL_ONGROUND
		if( (moveright || moveleft) && !up && !down && jump && onground && !g_sprint[id] && id != ballholder)
			SideJump[id] = 1

		if(g_sprint[id])
			entity_set_float(id, EV_FL_fuser2, 0.0)

		if( id != ballholder )
			PressedAction[id] = usekey
		else {
			if( usekey && !PressedAction[id]) {
				kickBall(ballholder, 0)
			}
			else if( !usekey && PressedAction[id])
				PressedAction[id] = 0
		}
	}
}

public client_PostThink(id) {
	if(is_kickball && is_user_connected(id)) {
		new Float:gametime = get_gametime()
		new button = entity_get_int(id, EV_INT_button)

		new up = (button & IN_FORWARD)
		new down = (button & IN_BACK)
		new moveright = (button & IN_MOVERIGHT)
		new moveleft = (button & IN_MOVELEFT)
		new jump = (button & IN_JUMP)
		new Float:vel[3]

		entity_get_vector(id,EV_VEC_velocity,vel)

		if( (gametime - SideJumpDelay[id] > 5.0) && SideJump[id] && jump && (moveright || moveleft) && !up && !down) {

			vel[0] *= 2.0
			vel[1] *= 2.0
			vel[2] = 300.0

			entity_set_vector(id,EV_VEC_velocity,vel)
			SideJump[id] = 0
			SideJumpDelay[id] = gametime
		}
		else
			SideJump[id] = 0
	}
}

public kickBall(id, velType)
{
	remove_task(55555)
	set_task(get_pcvar_float(CVAR_RESET),"clearBall",55555)

	new team = get_user_team(id)
	new a,x

	//Give it some lift
	ball_infront(id, 55.0)

	testorigin[2] += 10

	new Float:tempO[3], Float:returned[3]
	new Float:dist2

	entity_get_vector(id, EV_VEC_origin, tempO)
	new tempEnt = trace_line( id, tempO, testorigin, returned )

	dist2 = get_distance_f(testorigin, returned)

	//ball_infront(id, 55.0)

	if( point_contents(testorigin) != CONTENTS_EMPTY || (!is_user_connected(tempEnt) && dist2 ) )//|| tempDist < 65)
		return PLUGIN_HANDLED
	else
	{
		//Check Make sure our ball isnt inside a wall before kicking
		new Float:ballF[3], Float:ballR[3], Float:ballL[3]
		new Float:ballB[3], Float:ballTR[3], Float:ballTL[3]
		new Float:ballBL[3], Float:ballBR[3]

		for(x=0; x<3; x++) {
				ballF[x] = testorigin[x];	ballR[x] = testorigin[x];
				ballL[x] = testorigin[x];	ballB[x] = testorigin[x];
				ballTR[x] = testorigin[x];	ballTL[x] = testorigin[x];
				ballBL[x] = testorigin[x];	ballBR[x] = testorigin[x];
			}

		for(a=1; a<=6; a++) {

			ballF[1] += 3.0;	ballB[1] -= 3.0;
			ballR[0] += 3.0;	ballL[0] -= 3.0;

			ballTL[0] -= 3.0;	ballTL[1] += 3.0;
			ballTR[0] += 3.0;	ballTR[1] += 3.0;
			ballBL[0] -= 3.0;	ballBL[1] -= 3.0;
			ballBR[0] += 3.0;	ballBR[1] -= 3.0;

			if(point_contents(ballF) != CONTENTS_EMPTY || point_contents(ballR) != CONTENTS_EMPTY ||
			point_contents(ballL) != CONTENTS_EMPTY || point_contents(ballB) != CONTENTS_EMPTY ||
			point_contents(ballTR) != CONTENTS_EMPTY || point_contents(ballTL) != CONTENTS_EMPTY ||
			point_contents(ballBL) != CONTENTS_EMPTY || point_contents(ballBR) != CONTENTS_EMPTY)
					return PLUGIN_HANDLED
		}

		new ent = -1
		testorigin[2] += 35.0

		while((ent = find_ent_in_sphere(ent, testorigin, 35.0)) != 0) {
			if(ent > maxplayers)
			{
				new classname[32]
				entity_get_string(ent, EV_SZ_classname, classname, 31)

				if((contain(classname, "goalnet") != -1 || contain(classname, "func_") != -1) &&
					!equal(classname, "func_water") && !equal(classname, "func_illusionary"))
					return PLUGIN_HANDLED
			}
		}
		testorigin[2] -= 35.0

	}

	new kickVel
	if(!velType)
	{
		new str = (PlayerUpgrades[id][STR] * AMOUNT_STR) + (AMOUNT_POWERPLAY*(PowerPlay*5))
		kickVel = get_pcvar_num(CVAR_KICK) + str
		kickVel += g_sprint[id] * 100

		if(direction) {
			entity_get_vector(id, EV_VEC_angles, BallSpinDirection)
			curvecount = CURVE_COUNT
		}
	}
	else {
		curvecount = 0
		direction = 0
		kickVel = random_num(100, 600)
	}

	new Float:ballorig[3]
	entity_get_vector(id,EV_VEC_origin,ballorig)
	for(x=0; x<3; x++)
		distorig[0][x] = floatround(ballorig[x])

	velocity_by_aim(id, kickVel, velocity)

	for(x=0; x<3; x++)
		distorig[0][x] = floatround(ballorig[x])

	/////////////////////WRITE ASSIST CODE HERE IF NEEDED///////////
	if ( iassist[ 0 ] == team ) {
		if ( iassist[ team ] == 15 )
			iassist[ team ] = 0
	}
	else {
		// clear the assist list
		new ind
		for(ind = 0; ind < 16; ind++ )
			assist[ ind ] = 0
		// clear the assist index
		iassist[ team ] = 0
		// set which team to track
		iassist[ 0 ] = team
	}
	assist[ iassist[ team ]++ ] = id
	/////////////////////WRITE ASSIST CODE HERE IF NEEDED///////////

	ballowner = id
	ballholder = 0
	entity_set_origin(aball,testorigin)
	entity_set_vector(aball,EV_VEC_velocity,velocity)

	set_task(CURVE_TIME*2, "CurveBall", id)

	emit_sound(aball, CHAN_ITEM, BALL_KICKED, 1.0, ATTN_NORM, 0, PITCH_NORM)

	glow(id,0,0,0,0)

	beam()

	new aname[64]
	get_user_name(id,aname,63)

	if(!g_sprint[id])
		set_speedchange(id)

	format(temp1,63,"%L",LANG_PLAYER,"KICKED_BALL",TeamNames[team],aname)
	client_print(0,print_console,"%s",temp1)
	return PLUGIN_HANDLED
}

/*====================================================================================================
 [Command Blocks]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_kill(id) {
	if(is_kickball)
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public client_command(id) {
	if(!is_kickball) return PLUGIN_CONTINUE
	new arg[13]
	read_argv( 0, arg , 12 )

	if ( equal("buy",arg) || equal("autobuy",arg) )
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

//fix for an exploit.
public menuclass(id) {
	
	// They changed teams
	SetPlayerModel(id, 0xFF);
}

GetPlayerModel(id)
{
	if(!is_user_connected(id))
		return 0;

	return get_pdata_int(id, OFFSET_INTERNALMODEL, 5);
}

SetPlayerModel(id, int)
{
	if(!is_user_connected(id))
		return;

	set_pdata_int(id, OFFSET_INTERNALMODEL, int, 5);
}

public team_select(id, key) {
	if(is_kickball) {
		new team = get_user_team(id)
		//SetPlayerModel(id, 0xFF);
		if( (team == 1 || team == 2) && (key == team-1) )
		{
			new message[64]
			format(message, 63, "%L",id,"CANT_REJOIN_TEAM")

			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusText"), {0, 0, 0}, id)
			write_byte(0)
			write_string(message)
			message_end()

			engclient_cmd(id,"chooseteam")

			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public fullupdate(id)
	return PLUGIN_HANDLED

/*====================================================================================================
 [Upgrades]

 Purpose:	This handles the upgrade menu.

 Comment:	$$

====================================================================================================*/
public BuyUpgrade(id) {

	new level[65], num[11], mTitle[101]//, max_count
	format(mTitle,100,"%L",id,"MENU_TITLE")

	menu_upgrade[id] = menu_create(mTitle, "Upgrade_Handler")
	new x
	for(x=1; x<=UPGRADES; x++)
	{
		new price = ((PlayerUpgrades[id][x] * UpgradePrice[x]) / 2) + UpgradePrice[x]
		if((PlayerUpgrades[id][x] + 1) > UpgradeMax[x]) {
			//max_count++
			format(level,64,"\r%s %L",UpgradeTitles[x],id,"MENU_CHOICE_MAXED",UpgradeMax[x])
		}
		else {
			format(level,64,"%s \r%L \y-- \w%i XP",UpgradeTitles[x], id, "MENU_CHOICE_NEXT", PlayerUpgrades[id][x]+1, price)
		}
		format(num, 10,"%i",x)
		menu_additem(menu_upgrade[id], level, num, 0)
	}

	menu_addblank(menu_upgrade[id], (UPGRADES+1))
	menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NORMAL)

	menu_display(id, menu_upgrade[id], 0)
	return PLUGIN_HANDLED
}

public Upgrade_Handler(id, menu, item) {

	if(item == MENU_EXIT)
		return PLUGIN_HANDLED

	new cmd[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, cmd,5, iName, 63, callback)

	new upgrade = str_to_num(cmd)

	new playerupgrade = PlayerUpgrades[id][upgrade]
	new price = ((playerupgrade * UpgradePrice[upgrade]) / 2) + UpgradePrice[upgrade]
	new maxupgrade = UpgradeMax[upgrade]

	if(playerupgrade != maxupgrade && playerupgrade != maxupgrade+MAX_LVL_BONUS)
	{
		new needed = g_Experience[id] - price

		if( (needed >= 0) )
		{
			if(playerupgrade < maxupgrade-1)
				playerupgrade += 1
			else
				playerupgrade += MAX_LVL_BONUS+1

			g_Experience[id] -= price

			if(playerupgrade < maxupgrade)
				client_print(id,print_chat,"%L",id,"MENU_UPGRADED",playerupgrade,UpgradeTitles[upgrade],price)
			else {
				client_print(id,print_chat,"%L",id,"MENU_UPGRADED",maxupgrade,UpgradeTitles[upgrade],price)
				#if(MAX_LVL_BONUS > 1)
					client_print(id,print_chat,"%L",id,"MENU_MAX_LVL_BONUS",maxupgrade,MAX_LVL_BONUS)
				#else
					client_print(id,print_chat,"%L",id,"MENU_MAX_LVL",maxupgrade)
				#endif

				play_wav(id, UPGRADED_MAX_LEVEL)
			}
			switch(upgrade) {
				case STA: {
					new stam = playerupgrade * AMOUNT_STA
					entity_set_float(id, EV_FL_health, float(BASE_HP + stam))
				}
				case AGI: {
					if(!g_sprint[id])
						set_speedchange(id)
				}
			}
			PlayerUpgrades[id][upgrade] = playerupgrade
		}
		else
			client_print(id,print_chat,"%L",id,"MENU_MISSING_EXP",(needed * -1),(playerupgrade+1),UpgradeTitles[upgrade])
	}
	else {
		client_print(id,print_chat,"%L",id,"MENU_UPGRADE_MAXED",UpgradeTitles[upgrade],maxupgrade)
	}
	return PLUGIN_HANDLED
}

/*====================================================================================================
 [Meters]

 Purpose:	This controls the turbo meter and curve angle meter.

 Comment:	$$

====================================================================================================*/
public meter()
{
	new id
	new turboTitle[32]
	new sprintText[128], sec
	new r, g, b, team
	new len, x
	new ndir = -(DIRECTIONS)
	format(turboTitle,31,"%L",LANG_PLAYER,"TURBO_TITLE");
	for(id=1; id<=maxplayers; id++)
	{
		if(!is_user_connected(id) || !is_user_alive(id) || is_user_bot(id))
			continue

		sec = seconds[id]
		team = get_user_team(id)
		r = TeamMeterColors[team][0]
		g = TeamMeterColors[team][1]
		b = TeamMeterColors[team][2]

		if(id == ballholder) {

			set_hudmessage(r, g, b, POS_X, 0.75, 0, 0.0, 0.6, 0.0, 0.0, 1)

			len = format(sprintText, 127, "  %L ^n[",id,"CURVE_TITLE")

			for(x=DIRECTIONS; x>=ndir; x--)
				if(x==0)
					len += format(sprintText[len], 127-len, "%s%s",direction==x?"0":"+", x==ndir?"]":"  ")
				else
					len += format(sprintText[len], 127-len, "%s%s",direction==x?"0":"=", x==ndir?"]":"  ")

			show_hudmessage(id, "%s", sprintText)
		}

		set_hudmessage(r, g, b, POS_X, POS_Y, 0, 0.0, 0.6, 0.0, 0.0, 3)

		if(sec > 30) {
			sec -= 2
			format(sprintText, 127, "  %s ^n[==============]",turboTitle)
			set_speedchange(id)
			g_sprint[id] = 0
		}
		else if(sec >= 0 && sec < 30 && g_sprint[id]) {
			sec += 2
			set_speedchange(id, 100.0)
		}

		switch(sec)	{
			case 0:		format(sprintText, 127, "  %s ^n[||||||||||||||]",turboTitle)
			case 2:		format(sprintText, 127, "  %s ^n[|||||||||||||=]",turboTitle)
			case 4:		format(sprintText, 127, "  %s ^n[||||||||||||==]",turboTitle)
			case 6:		format(sprintText, 127, "  %s ^n[|||||||||||===]",turboTitle)
			case 8:		format(sprintText, 127, "  %s ^n[||||||||||====]",turboTitle)
			case 10:	format(sprintText, 127, "  %s ^n[|||||||||=====]",turboTitle)
			case 12:	format(sprintText, 127, "  %s ^n[||||||||======]",turboTitle)
			case 14:	format(sprintText, 127, "  %s ^n[|||||||=======]",turboTitle)
			case 16:	format(sprintText, 127, "  %s ^n[||||||========]",turboTitle)
			case 18:	format(sprintText, 127, "  %s ^n[|||||=========]",turboTitle)
			case 20:	format(sprintText, 127, "  %s ^n[||||==========]",turboTitle)
			case 22:	format(sprintText, 127, "  %s ^n[|||===========]",turboTitle)
			case 24:	format(sprintText, 127, "  %s ^n[||============]",turboTitle)
			case 26:	format(sprintText, 127, "  %s ^n[|=============]",turboTitle)
			case 28:	format(sprintText, 127, "  %s ^n[==============]",turboTitle)
			case 30: {
				format(sprintText, 128, "  %s ^n[==============]",turboTitle)
				sec = 92
			}
			case 32: sec = 0
		}

	 	seconds[id] = sec
		show_hudmessage(id,"%s",sprintText)
	}
}

/*====================================================================================================
 [Misc.]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
set_speedchange(id, Float:speed=0.0)
{
	new Float:agi = float( (PlayerUpgrades[id][AGI] * AMOUNT_AGI) + (id==ballholder?(AMOUNT_POWERPLAY * (PowerPlay*2)):0) )
	agi += (BASE_SPEED + speed)
	entity_set_float(id,EV_FL_maxspeed, agi)
}

public give_knife(id) {
	if(id > 1000)
		id -= 1000

	remove_task(id+1000)

	give_item(id, "weapon_knife")
	has_knife[id] = true;
}

Event_Record(id, recordtype, amt, exp) {
	if(amt == -1)
		MadeRecord[id][recordtype]++
	else
		MadeRecord[id][recordtype] = amt

	new playerRecord = MadeRecord[id][recordtype]
	if(playerRecord > TopPlayer[1][recordtype])
	{
		TopPlayer[0][recordtype] = id
		TopPlayer[1][recordtype] = playerRecord
		new name[MAX_NAME_LENGTH+1]
		get_user_name(id,name,MAX_NAME_LENGTH)
		format(TopPlayerName[recordtype],MAX_NAME_LENGTH,"%s",name)
	}
	g_Experience[id] += exp
}

Float:normalize(Float:nVel)
{
	if(nVel > 360.0) {
		nVel -= 360.0
	}
	else if(nVel < 0.0) {
		nVel += 360.0
	}

	return nVel
}

print_message(id, msg[]) {
	message_begin(MSG_ONE_UNRELIABLE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

public editTextMsg()
{
	new string[64], radio[64]
	get_msg_arg_string(2, string, 63)

	if( get_msg_args() > 2 )
		get_msg_arg_string(3, radio, 63)

	if(containi(string, "#Game_will_restart") != -1 || containi(radio, "#Game_radio") != -1)
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public client_connect(id)
	if(is_kickball)
		set_user_info(id,"_vgui_menus","0")

public AutoRespawn(id)
	if(is_dead[id] && is_user_connected(id)) {
		new team = get_user_team(id)
		if(team == 1 || team == 2) {
			spawn(id)

		}
		else
			is_dead[id] = false
	}

public AutoRespawn2(id)
	if(is_dead[id] && is_user_connected(id)) {
		new team = get_user_team(id)
		if(team == 1 || team == 2) {
			spawn(id)
			if(!has_knife[id])
				give_knife(id)
		}
		//strip_user_weapons(id)
		is_dead[id] = false
	}

play_wav(id, wav[])
	client_cmd(id,"spk %s",wav)

cmdSpectate(id) {
	cs_set_user_team(id, CS_TEAM_SPECTATOR, CS_DONTCHANGE)
	if(is_user_alive(id))
		user_kill(id)
}

increaseTeamXP(team, amt) {
	new id
	for(id=1; id<=maxplayers; id++)
		if(get_user_team(id) == team && is_user_connected(id))
			g_Experience[id] += amt
}

setScoreInfo(id) {
	message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
	write_byte(id);
	write_short(get_user_frags(id));
	write_short(cs_get_user_deaths(id));
	write_short(0);
	write_short(get_user_team(id));
	message_end();
}

// Erase our current temps (used for ball events)
public eraser(num) {
	if(num == 3333)
		format(temp1,63,"")
	if(num == 4444)
		format(temp2,63,"")
	return PLUGIN_HANDLED
}
/*====================================================================================================
 [Cleanup]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_disconnect(id) {
	if(is_kickball) {
		new x
		for(x = 1; x<=RECORDS; x++)
			MadeRecord[id][x] = 0
		remove_task(id)
		if(ballholder == id ) {
			ballholder = 0
			clearBall()
		}
		if(ballowner == id) {
			ballowner = 0
		}

		GoalyPoints[id] = 0
		PlayerKills[id] = 0
		PlayerDeaths[id] = 0
		is_dead[id] = false
		seconds[id] = 0
		g_sprint[id] = 0
		PressedAction[id] = 0
		has_knife[id] = false;
		g_Experience[id] = 0

		for(x=1; x<=UPGRADES; x++)
			PlayerUpgrades[id][x] = 0
	}
}

cleanup() {
	new x, id, m
	for(x=1;x<=RECORDS;x++) {
		TopPlayer[0][x] = 0
		TopPlayer[1][x] = 0
		TopPlayerName[x][0] = 0
	}

	for(id=1;id<=maxplayers;id++) {
		PlayerDeaths[id] = 0
		PlayerKills[id] = 0

		//UsedExp[id] = 0
		g_Experience[id] = 0

		for(x=1;x<=UPGRADES;x++)
			PlayerUpgrades[id][x] = 0

		for(m = 1; m<=RECORDS; m++)
			MadeRecord[id][m] = 0
	}

	PowerPlay = 0
	winner = 0
	score[T] = 0
	score[CT] = 0
	set_cvar_num("score_ct",0)
	set_cvar_num("score_t",0)

	for(x = 0;x<=cntCT;x++)
		ct[x] = 0

	for(x = 0; x<= cntT; x++)
		terr[x] = 0

	cntCT = 0
	cntT = 0
}

/*====================================================================================================
 [Help]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_putinserver(id) {
	if(is_kickball) {
		set_task(20.0,"soccerjamHelp",id)
	}
}

public soccerjamHelp(id)
{
	client_cmd(id, "cl_forwardspeed 1000")
	client_cmd(id, "cl_backspeed 1000")
	client_cmd(id, "cl_sidespeed 1000")

	new name[32]
	get_user_name(id,name,31)
	client_print(id,print_chat,"========= - [Soccer Jam] v%s - ========",VERSION)
	client_print(id,print_chat,"%L",id,"WELCOME_MSG",name)
	client_print(id,print_chat,"%L",id,"WELCOME_HELP_MSG")
	LateJoinExp(id)
	client_print(id,print_chat,"=========------------------========")
}

LateJoinExp(id)
{
	new total = (score[T] + score[CT]) * AMOUNT_LATEJOINEXP
	if(total) {
		g_Experience[id] += total
		client_print(id, print_chat, "%L",id,"EXP_FOR_LATEJOIN",total)
	}
}

public handle_say(id)
{
	new said[192], help[7]
	read_args(said,192)
	remove_quotes(said)
	strcat(help,said,6)
	if( (containi(help, "help") != -1) )
		soccerjam_help(id)
	if( (contain(help, "spec") != -1) )
		cmdSpectate(id)

	return PLUGIN_CONTINUE

}

public soccerjam_help(id) {
	new help_title[64], msg[2047], len
	format(help_title,63,"%L",id,"HELP_HEADER")
	len = format(msg,2046,"<body bgcolor=#000000><font color=#FFB000><br>")
	len += format(msg[len],2046-len,"<center><h2>%L</h2><br><table><tr><td><p><b><font color=#FFB000>",id,"HELP_TITLE")
	len += format(msg[len],2046-len,"<h2>%L</h2>",id,"HELP_MOVES_TITLE")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_KICK")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_CURVELEFT")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_CURVERIGHT")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_TURBO")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_UPGRADE")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_MOVES_DIVE")
	len += format(msg[len],2046-len,"%L<br><br>",id,"HELP_MOVES_CATCH")

	len += format(msg[len],2046-len,"<h2>%L</h2>",id,"HELP_STATS_TITLE")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_STATS_STAMINA")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_STATS_STRENGTH")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_STATS_AGILITY")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_STATS_DEXTERITY")
	len += format(msg[len],2046-len,"%L<br>",id,"HELP_STATS_DISARM")
	len += format(msg[len],2046-len,"<h2>%L</h2>",id,"HELP_POWERPLAY_TITLE")
	len += format(msg[len],2046-len,"- %L<br>",id,"HELP_POWERPLAY_ONE")
	len += format(msg[len],2046-len,"- %L<br>",id,"HELP_POWERPLAY_TWO")
	len += format(msg[len],2046-len,"<h2>%L</h2>",id,"HELP_TIPS_TITLE")
	len += format(msg[len],2046-len,"- %L<br>",id,"HELP_TIPS_ONE")
	len += format(msg[len],2046-len,"- %L<br>",id,"HELP_TIPS_TWO")
	len += format(msg[len],2046-len,"- %L<br>",id,"HELP_TIPS_THREE")
	len += format(msg[len],2046-len,"</b><br></td></tr></table><br>Soccer Jam made by OneEyed</center>")
	show_motd(id,msg,help_title)
}

/*====================================================================================================
 [Post Game]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public showhud_winner() {
	set_hudmessage(255, 0, 20, -1.0, 0.35, 1, 1.0, 1.5, 0.1, 0.1, HUD_CHANNEL)
	show_hudmessage(0,"%s",scoreboard)
}
public displayWinnerAwards()
{
	//If NO steal/assist was made, set name to Nobody
	new x
	for(x=1;x<=RECORDS;x++)
		if(!TopPlayer[0][x])
			format(TopPlayerName[x],MAX_NAME_LENGTH,"Nobody")

	//Display our Winning Team, with Awards, and kill Comm Chair of opponent
	new awards[513]
	new len = 0
	len += format(awards[len], 512-len, "%s %L^n", (winner == 1 ? "Terrorist" : "CT"), LANG_PLAYER, "AWARDS_HEADER" )
	len += format(awards[len], 512-len, "%s - %i  |  %s - %i^n^n", TeamNames[T],score[T],TeamNames[CT],score[CT])
	len += format(awards[len], 512-len, "      %L^n",LANG_PLAYER,"AWARDS_TITLE")
	len += format(awards[len], 512-len, "%i %L -- %s^n", TopPlayer[1][GOAL], LANG_PLAYER, "AWARDS_GOALS", TopPlayerName[GOAL])
	len += format(awards[len], 512-len, "%i %L -- %s^n", TopPlayer[1][STEAL], LANG_PLAYER, "AWARDS_STEALS", TopPlayerName[STEAL])
	len += format(awards[len], 512-len, "%i %L -- %s^n", TopPlayer[1][ASSIST], LANG_PLAYER, "AWARDS_ASSISTS", TopPlayerName[ASSIST])
	len += format(awards[len], 512-len, "%i %L -- %s^n", TopPlayer[1][KILL], LANG_PLAYER, "AWARDS_BALLKILLS", TopPlayerName[KILL])
	len += format(awards[len], 512-len, "%i %L -- %s^n", TopPlayer[1][DISTANCE], LANG_PLAYER, "AWARDS_LONGESTGOAL", TopPlayerName[DISTANCE])

	set_hudmessage(250, 130, 20, 0.4, 0.35, 0, 1.0, 10.0, 0.1, 0.1, 2)
	show_hudmessage(0, "%s", awards)
}

public PostGame() {
	new randomize = get_pcvar_num(CVAR_RANDOM)
	if(randomize)
	{
		set_hudmessage(20, 250, 20, -1.0, 0.55, 1, 1.0, 3.0, 1.0, 0.5, 2)
		show_hudmessage(0, "%L",LANG_PLAYER,"RANDOMIZING_TEAMS")
		set_task(3.0,"randomize_teams",0)
	}
	else
		BeginCountdown()
}

public BeginCountdown() {
	if(!timer) {
		timer = COUNTDOWN_TIME
		cleanup()
	}
	else {
		new output[32]
		num_to_word(timer,output,31)
		client_cmd(0,"spk vox/%s.wav",output)

		if(timer > (COUNTDOWN_TIME / 2))
			set_hudmessage(20, 250, 20, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 2)
		else
			set_hudmessage(255, 0, 0, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 2)

		if(timer > (COUNTDOWN_TIME - 2))
			show_hudmessage(0, "%L^n%i",LANG_PLAYER,"GAME_BEGINS_IN",timer)
		else
			show_hudmessage(0, "%i",timer)

		if(timer == 1)
			server_cmd("sv_restart 1")
		timer--
		set_task(0.9,"BeginCountdown",0)
	}
}

/*====================================================================================================
 [Team Randomizer]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public randomize_teams()
{
	new terr, ct, id, team, cnt, temp, x, pl_temp
	new teams[3][33], player_list[33]
	new shuff_t, shuff_ct
	new shuffle = random_num(10,30)

	//Put all players in one big list
	for(id=1; id<=maxplayers; id++)
		if(is_user_connected(id) && !is_user_bot(id)) {
			team = get_user_team(id)
			if(team == 1 || team == 2)
				player_list[cnt++] = id
		}

	cnt--

	//Make a list of Terr and CT players
	while(cnt >= 0)
	{
		if(cnt % 2 == 0)
			teams[1][terr++] = player_list[cnt--]
		else
			teams[2][ct++] = player_list[cnt--]
	}

	//Shuffle the players
	for(x=0;x<=shuffle;x++) {
		shuff_t = random_num(0,terr-1);
		shuff_ct = random_num(0,ct-1);
		temp = teams[1][shuff_t];
		teams[1][shuff_t] = teams[2][shuff_ct];
		teams[2][shuff_ct] = temp;
	}

	//Put Players in their team.
	for(x=1; x<3; x++)
		for(id=0; id<((terr>ct?terr:ct)); id++) {
			pl_temp = teams[x][id]
			if(is_user_connected(pl_temp)) {
				select_model(pl_temp, x, random_num(1,4))
				set_task(1.0, "DelayedTeamSwitch", pl_temp+(x*1000))
			}
		}
	set_task(3.0,"BeginCountdown",0)
}

public DelayedTeamSwitch(id) {
	new team, msg[124]
	if(id >= 2000)
		team = 2
	else
		team = 1

	id -= team*1000

	format(msg, 123, "^x03 %L",id,"RANDOM_MOVED_TEAM", team==1?"Terrorist":"Counter-Terrorist")
	print_message(id, msg)
}

//random model selecting for teamstack
select_model(id, team, model) {
	switch(team) {
		case 1: {
			switch(model) {
				case 1: cs_set_user_team(id, CS_TEAM_T, CS_T_TERROR)
				case 2: cs_set_user_team(id, CS_TEAM_T, CS_T_LEET)
				case 3:	cs_set_user_team(id, CS_TEAM_T, CS_T_ARCTIC)
				case 4: cs_set_user_team(id, CS_TEAM_T, CS_T_GUERILLA)
			}
		}
		case 2: {
			switch(model) {
				case 1: cs_set_user_team(id, CS_TEAM_CT, CS_CT_URBAN)
				case 2: cs_set_user_team(id, CS_TEAM_CT, CS_CT_GSG9)
				case 3: cs_set_user_team(id, CS_TEAM_CT, CS_CT_SAS)
				case 4: cs_set_user_team(id, CS_TEAM_CT, CS_CT_GIGN)
				case 5: cs_set_user_team(id, CS_TEAM_CT, CS_CT_VIP) //my lil secret
			}
		}
		case 3: {
			cs_set_user_team(id, CS_TEAM_SPECTATOR, CS_DONTCHANGE)
			if(is_user_alive(id))
				user_kill(id)
		}
	}
}

/*====================================================================================================
 [Special FX]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
TerminatePlayer(id, mascot, team, Float:dmg) {
	new orig[3], Float:morig[3], iMOrig[3]

	get_user_origin(id, orig)
	entity_get_vector(mascot,EV_VEC_origin,morig)
	new x
	for(x=0;x<3;x++)
		iMOrig[x] = floatround(morig[x])

	fakedamage(id,"Terminator",dmg,1)

	new hp = get_user_health(id)
	if(hp < 0)
		increaseTeamXP(team, 25)

	new loc = (team == 1 ? 100 : 140)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0)
	write_coord(iMOrig[0])			//(start positionx)
	write_coord(iMOrig[1])			//(start positiony)
	write_coord(iMOrig[2] + loc)			//(start positionz)
	write_coord(orig[0])			//(end positionx)
	write_coord(orig[1])		//(end positiony)
	write_coord(orig[2])		//(end positionz)
	write_short(g_fxBeamSprite) 			//(sprite index)
	write_byte(0) 			//(starting frame)
	write_byte(0) 			//(frame rate in 0.1's)
	write_byte(7) 			//(life in 0.1's)
	write_byte(120) 			//(line width in 0.1's)
	write_byte(25) 			//(noise amplitude in 0.01's)
	write_byte(250)			//r
	write_byte(0)			//g
	write_byte(0)			//b
	write_byte(220)			//brightness
	write_byte(1) 			//(scroll speed in 0.1's)
	message_end()
}

glow(id, r, g, b, on) {
	if(on == 1) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(!on) {
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(on == 10) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
}

on_fire()
{
	new rx, ry, rz, Float:forig[3], forigin[3], x
	fire_delay = get_gametime()

	rx = random_num(-5, 5)
	ry = random_num(-5, 5)
	rz = random_num(-5, 5)
	entity_get_vector(aball, EV_VEC_origin, forig)
	for(x=0;x<3;x++)
		forigin[x] = floatround(forig[x])

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(17)
	write_coord(forigin[0] + rx)
	write_coord(forigin[1] + ry)
	write_coord(forigin[2] + 10 + rz)
	write_short(Burn_Sprite)
	write_byte(7)
	write_byte(235)
	message_end()
}

beam() {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(22) 		// TE_BEAMFOLLOW
	write_short(aball) 	// ball
	write_short(beamspr)// laserbeam
	write_byte(BALL_BEAM_LIFE)	// life
	write_byte(BALL_BEAM_WIDTH)	// width
	write_byte(BALL_BEAM_RED)	// R
	write_byte(BALL_BEAM_GREEN)	// G
	write_byte(BALL_BEAM_BLUE)	// B
	write_byte(BALL_BEAM_ALPHA)	// brightness
	message_end()
}

flameWave(myorig[3]) {
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY, myorig)
    write_byte( 21 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 16)
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 500)
    write_short( fire )
    write_byte( 0 ) // startframe
    write_byte( 0 ) // framerate
    write_byte( 15 ) // life 2
    write_byte( 50 ) // width 16
    write_byte( 10 ) // noise
    write_byte( 255 ) // r
    write_byte( 0 ) // g
    write_byte( 0 ) // b
    write_byte( 255 ) //brightness
    write_byte( 1 / 10 ) // speed
    message_end()

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,myorig)
    write_byte( 21 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 16)
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 500)
    write_short( fire )
    write_byte( 0 ) // startframe
    write_byte( 0 ) // framerate
    write_byte( 10 ) // life 2
    write_byte( 70 ) // width 16
    write_byte( 10 ) // noise
    write_byte( 255 ) // r
    write_byte( 50 ) // g
    write_byte( 0 ) // b
    write_byte( 200 ) //brightness
    write_byte( 1 / 9 ) // speed
    message_end()

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,myorig)
    write_byte( 21 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 16)
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 500)
    write_short( fire )
    write_byte( 0 ) // startframe
    write_byte( 0 ) // framerate
    write_byte( 10 ) // life 2
    write_byte( 90 ) // width 16
    write_byte( 10 ) // noise
    write_byte( 255 ) // r
    write_byte( 100 ) // g
    write_byte( 0 ) // b
    write_byte( 200 ) //brightness
    write_byte( 1 / 8 ) // speed
    message_end()

    //Explosion2
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte( 12 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2])
    write_byte( 80 ) // byte (scale in 0.1's) 188
    write_byte( 10 ) // byte (framerate)
    message_end()

    //TE_Explosion
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
    write_byte( 3 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2])
    write_short( fire )
    write_byte( 65 ) // byte (scale in 0.1's) 188
    write_byte( 10 ) // byte (framerate)
    write_byte( 0 ) // byte flags
    message_end()

    //Smoke
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig)
    write_byte( 5 ) // 5
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2])
    write_short( smoke )
    write_byte( 50 )  // 2
    write_byte( 10 )  // 10
    message_end()

    return PLUGIN_HANDLED
}

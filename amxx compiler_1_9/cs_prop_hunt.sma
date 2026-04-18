#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>

new const VERSION[] = "1.1";

new const g_pyrofireSpr_[] = "sprites/explode1.spr";

new const g_pmdl_flamethrower[] = "models/p_flamethrower.mdl";
new const g_vmdl_flamethrower[] = "models/v_flamethrower.mdl";

new const g_FtSound[] = "flamethrower.wav";

new const g_smokeSpr_[] = "sprites/black_smoke3.spr";
new const g_flameSpr_[] = "sprites/flame.spr";

new const g_CountdownSound[][] =
{
	"fvox/time_is_now.wav",
	"fvox/one.wav",
	"fvox/two.wav",
	"fvox/three.wav",
	"fvox/four.wav",
	"fvox/five.wav"
};

#define is_player_alive(%1) (1 <= %1 <= gMaxPlayers && g_bIsAlive[%1])
#define is_player_connected(%1) (1 <= %1 <= gMaxPlayers && g_bIsConnected[%1])
#define remove_prop(%1) (engfunc(EngFunc_RemoveEntity, g_iProp[%1]), g_iProp[%1]=0)

#define VectorAdd(%1,%2,%3) (%3[0] = %1[0] + %2[0], %3[1] = %1[1] + %2[1], %3[2] = %1[2] + %2[2])
#define VectorScale(%1,%2,%3) (%3[0] = %2 * %1[0], %3[1] = %2 * %1[1], %3[2] = %2 * %1[2])

new const g_sB[] = "b";
new const g_sA[] = "a";
new const g_sBE[] = "be";
new const g_sPlayer[] = "player";
new const g_sInfoTarget[] = "info_target";
//new const g_sClassName[] = "classname"
new const g_sBlank[] = "";
new const g_sCommandNotAvailable[] = "Command_Not_Available";
new const g_sMsgWins[][] =
{
	"Terrorists_Win",
	"Hostages_Not_Rescued",
	"CTs_Win"
};

const OFFSET_PAINSHOCK = 108

const HIDE_HUD = ( 1 << 0 );
//const HIDE_NONE = ( 1 << 7 );

enum (+= 200) { TASK_HIDETIME = 9999, TASK_HEAL, TASK_ZOOM, TASK_BURN, TASK_SCLIP };

enum { HEAVY = 1, PYRO, SNIPER };

new const g_iClassAmmo[] = { -1, 100, -1, 10 };

new const g_szSeekerWpns[][] = 
{
	"",
	"weapon_m249",
	"weapon_xm1014",
	"weapon_scout",
	"weapon_knife"
};

enum { HUD_BOARD, HUD_ZOOM, HUD_CROSSHAIR, HUD_OBJ };
enum { ICON_SPEEDBOOST, ICON_BUYZONE };

new const g_iClassHealth[] = { -1, 200, 170, 150 };

new const g_szPlayerCamera[] = "Player_camera";
new const g_szHiderProp[] = "Hider_Prop";
new const g_bar[][] = { "|||||", "_____" };
new const g_teamnum[][] = { "0", "1", "2", "3" };
new const g_classnum[][] = { "1", "2", "3", "4" };

enum { TEAM_T = 1, TEAM_CT };

new const g_cTeamChars[] = { 'U', 'T', 'C', 'S' };
new const g_cmdTeam[][] = { "jointeam", "chooseteam", "joinclass" };

new const g_weapon_entity[][] =
{
	"weaponbox",
	"armoury_entity",
	"weapon_shield"
};

new const g_sBuyCommands[][] =  
{ 
    "buy", "buyequip", "usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47",  
    "galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren", 
    "sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "12gauge", 
    "autoshotgun", "smg", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550", 
    "buyammo1", "buyammo2", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy"
};

new const g_sRemoveEntities[][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"armoury_entity"
};

new bool:g_bGameOn = true, bool:g_bInHideTime;
new Array:g_sPropsModel;
new g_iProp[33], g_iCamera[33], g_iHunterClass[33], bool:g_bCameraOn[33];
new g_iCurrentPropIndex[33];
new bool:g_bIsHider[33], bool:g_bIsAlive[33], bool:g_bIsConnected[33];
new bool:g_bPropLocked[33];
new bool:g_bAttack2Held[33];
new g_CvarBlockteam, g_CvarHidetime, g_CvarHealtime, g_CvarFlamedura, g_CvarHpLostAmt,
	g_CvarHiderspeed, g_CvarSpeedBoost, g_CvarFtFuel;
new gMaxPlayers, gMsgStatusIcon, gMsgSayText, gMsgHideWeapon,
	gMsgScreenFade, gMsgCrossHair, gMsgBarTime, g_hudmsg[4];
new g_pyrofireSpr, g_smokeSpr, g_flameSpr;
new g_iTeam[33], g_iPlayers[5];
new bool:g_bRoundEnd, g_iDoublejump[33], g_iCurWeapon[33], g_iFuel[33];
new g_iCountdownTime, Float:g_fLastfire[33], g_bHasSpeedBoost[33];
new g_iZoomPower[33], g_iSniperDmg[33];
new Float:g_fGameStartTime;
new g_iSurvivalFrags[33];
new g_iHostage, g_iHideTime

public plugin_init() 
{
	if(!g_bGameOn)
		return;

	set_cvar_float("mp_roundtime", 3.5);
		
	register_dictionary("csprophunt.txt");
	
	RegisterHam(Ham_Spawn, g_sPlayer, "fw_spawn_player_post", 1);
	RegisterHam(Ham_TakeDamage, g_sPlayer, "fw_TakeDamage");
	RegisterHam(Ham_TakeDamage, g_sPlayer, "fw_TakeDamage_post", 1);
	RegisterHam(Ham_Killed, "player", "fw_killed_player");
	
	new sEventTouchWpn[] = "event_touch_weapon";
	for(new i; i < 3; i++)
		RegisterHam(Ham_Touch, g_weapon_entity[i], sEventTouchWpn);
	
	RegisterHam(Ham_Think, g_sInfoTarget, "fw_ent_think");
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szSeekerWpns[1], "fw_WeaponAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szSeekerWpns[3], "fw_WeaponAttack");
	RegisterHam(Ham_Weapon_SecondaryAttack, g_szSeekerWpns[4], "fw_WeaponAttack");
	
	register_event("TeamInfo", "event_TeamInfo", g_sA);
	register_event("CurWeapon", "event_curweapon", g_sBE, "1=1");
	register_event("SetFOV", "Event_SetFOV", "be")
//	register_event("HLTV", "EventNewRound", g_sA, "1=0", "2=0" );
	register_logevent("EventRoundStart", 2, "1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1=Round_End" );
	register_event("TextMsg", "RestartRound", g_sA, "2&#Game_C", "2&#Game_w");
//	register_event("DeathMsg", "eventDeathMsg", g_sA, "2!0");
	register_event("StatusIcon", "Event_BuyZone", g_sB, "2=buyzone");
	
//	register_message(get_user_msgid("StatusIcon"), "msgStatusIcon");
	register_message(get_user_msgid("TextMsg"), "msg_textmsg");
	register_message(get_user_msgid("WeapPickup"), "msg_weaponpickup");
	register_message(get_user_msgid("AmmoPickup"), "msg_ammopickup");
	
	register_forward(FM_GetGameDescription, "fwd_GameDescription");
	register_forward(FM_CmdStart, "fwd_CmdStart");
	register_forward(FM_UpdateClientData, "fwd_UpdateClientData_Post", 1);
	register_forward(FM_PlayerPreThink, "fwd_Player_PreThink");
	register_forward(FM_PlayerPostThink, "fwd_Player_PostThink");
	register_forward(FM_ClientKill, "fwd_ClientKill");
	
	new sBuyHandle[] = "cmd_buy";
	for(new i = 0; i < sizeof g_sBuyCommands; i++) 
		register_clcmd(g_sBuyCommands[i], sBuyHandle);
	
	register_clcmd("drop", "cmd_drop");
	for(new i; i < 2; i++)
		register_clcmd(g_cmdTeam[i], "cmd_chooseteam", -1, g_sBlank);
	register_clcmd("say /class", "cmd_choose_class");
	register_clcmd("lastinv", "cmd_cycle_prop");
	
	for(new i = 0; i < 4; i++)
		g_hudmsg[i] = CreateHudSyncObj();
	
	set_task(2.0, "show_hud", _, _, _, g_sB);
	
	set_cvar_num("mp_playerid", 1); //hunter won't see hider'name when aiming
	
	gMaxPlayers = get_maxplayers();
	gMsgStatusIcon = get_user_msgid("StatusIcon");
	gMsgSayText = get_user_msgid("SayText");
	gMsgHideWeapon = get_user_msgid("HideWeapon");
	gMsgScreenFade = get_user_msgid("ScreenFade");
	gMsgCrossHair = get_user_msgid("Crosshair");
	gMsgBarTime = get_user_msgid("BarTime")
//	gMsgDeathmsg = get_user_msgid("DeathMsg");
}

public plugin_precache()
{
	register_plugin("CS PropHunt", VERSION, "Ryokin");
	register_cvar("ph_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER);
	set_cvar_string("ph_version", VERSION);
	
	g_CvarBlockteam = register_cvar("ph_block_jointeam", "1");
	g_CvarHidetime = register_cvar("ph_hide_time", "20");
	g_CvarHealtime = register_cvar("ph_healing_time", "15");
	g_CvarFlamedura = register_cvar("ph_flame_duration", "10");
	g_CvarHpLostAmt = register_cvar("ph_wpnfire_hp_amount", "5"); //hp losing when wpn fire
	g_CvarHiderspeed = register_cvar("ph_hider_speed", "280.0");
	g_CvarSpeedBoost = register_cvar("ph_speed_boost", "15.0");
	g_CvarFtFuel = register_cvar("ph_flamethrower_fuel", "150");
	
	g_sPropsModel = ArrayCreate(32, 1);
	
	static cfgdir[32], mapname[32], filepath[100];
	get_configsdir(cfgdir, charsmax(cfgdir));
	get_mapname(mapname, charsmax(mapname));
	format(mapname, charsmax(mapname), "[%s]", mapname);
	formatex(filepath, charsmax(filepath), "%s/cs_prophunt.ini", cfgdir);
	
	if(!file_exists(filepath))
	{
		server_print("[PropHunt] WARNING: Can't find file %s", filepath);
		g_bGameOn = false;
		return;
	}
	
	static linedata[1024], key[64], value[960], buffer[100], bool:catch_map, bool:bHadCatchedMap = false;

	new file = fopen(filepath, "rt");
	
	while(file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata));
		
		replace(linedata, charsmax(linedata), "^n", "");
		
		if(!linedata[0] || linedata[0] == ';') 
			continue;
			
		if(linedata[0] == '[')
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value));
			trim(key);
			trim(value);
			
			if(equal(key, mapname))
			{
				if(!bHadCatchedMap) 
					bHadCatchedMap = true; //found map's name
				catch_map = true;
			}
			else catch_map = false;
			
			continue;
		}
			
		if(!catch_map)
			continue;
			
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=');
		
		trim(key)
		trim(value)
		
		if(equal(key, "HIDE TIME"))
		{
			g_iHideTime = str_to_num(value);
			continue
		}
			
		formatex(value, charsmax(value), "%s", linedata);
		
		while(value[0] != 0 && value[10] != '=' && strtok(value, key, charsmax(key), value, charsmax(value), ','))
		{
			trim(key);
			trim(value);
						
			ArrayPushString(g_sPropsModel, key);
		}
	}
	if(file) fclose(file);
	
	if(!bHadCatchedMap) //can't find map in ini file
	{
		server_print("[PropHunt] WARNING: Can't find map's name %s in cs_prophunt.ini", mapname);
		g_bGameOn = false;
		return;
	}
	
	if(!g_iHideTime)
		g_iHideTime = get_pcvar_num(g_CvarHidetime);
	
	for(new i = 0; i < ArraySize(g_sPropsModel); i++)
	{
		ArrayGetString(g_sPropsModel, i, buffer, charsmax(buffer));
		format(buffer, charsmax(buffer), "models/props/%s.mdl", buffer);
		engfunc(EngFunc_PrecacheModel, buffer);
	}
	
	precache_model(g_pmdl_flamethrower);
	precache_model(g_vmdl_flamethrower);
	precache_sound(g_FtSound);
	
	g_pyrofireSpr = precache_model(g_pyrofireSpr_);
	g_smokeSpr = precache_model(g_smokeSpr_);
	g_flameSpr = precache_model(g_flameSpr_);
	
	for(new i = 0; i < 6; i++)
		precache_sound(g_CountdownSound[i]);
		
	register_forward(FM_Spawn, "fwd_Spawn");
	
	new iHostage = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"));
	
	if(iHostage)
	{
		engfunc(EngFunc_SetOrigin, iHostage, Float:{0.0, 0.0, -55000.0});
		engfunc(EngFunc_SetSize, iHostage, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
		dllfunc(DLLFunc_Spawn, iHostage);
		g_iHostage = iHostage
	}
}

public client_putinserver(id)
{
	g_bIsConnected[id] = true;
	
	//create camera
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, g_sInfoTarget));      
	set_pev(iEnt, pev_classname, g_szPlayerCamera);
	engfunc(EngFunc_SetModel, iEnt, "models/w_usp.mdl");
	set_pev(iEnt, pev_solid, SOLID_TRIGGER);
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY);
	set_pev(iEnt, pev_owner, id);
	set_pev(iEnt, pev_rendermode, kRenderTransTexture);
	set_pev(iEnt, pev_renderamt, 0.0);
	g_iCamera[id] = iEnt;
	
	//create prop
	new iProp = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, g_sInfoTarget));
	set_pev(iProp, pev_classname, g_szHiderProp);
//	set_pev(iProp, pev_movetype, MOVETYPE_TOSS);
	set_pev(iProp, pev_owner, id);
	set_visible(iProp, 0);
	g_iProp[id] = iProp;
}

public client_disconnect(id)
{
	g_bIsAlive[id] = false;
	g_bIsConnected[id] = false;
	g_bPropLocked[id] = false;
	g_bAttack2Held[id] = false;
	g_iHunterClass[id] = 0;
	g_iCurWeapon[id] = 0;
	g_iCurrentPropIndex[id] = -1;
	
	if(g_iProp[id])
		remove_prop(id);
		
	new iEnt = g_iCamera[id];
	if(iEnt) engfunc(EngFunc_RemoveEntity, iEnt), g_iCamera[id] = 0;
		
	if(task_exists(id+TASK_HEAL))
		remove_task(id+TASK_HEAL);
		
	if(task_exists(id+TASK_SCLIP))
		remove_task(id+TASK_SCLIP);
		
	if(task_exists(id+TASK_ZOOM))
		remove_task(id+TASK_ZOOM);
}

public cmd_buy(id) 
{ 
	client_print(id, print_center, "%L", LANG_PLAYER, "CANT_BUY_WPN");
	return PLUGIN_HANDLED;
}
	
public cmd_drop(id)
{
	client_print(id, print_center, "%L", LANG_PLAYER, "CANT_DROP");
	return PLUGIN_HANDLED;
}

public cmd_cycle_prop(id)
{
	if(!g_bGameOn || !g_bIsAlive[id] || !g_bIsHider[id])
		return PLUGIN_CONTINUE;

	new iPropCount = ArraySize(g_sPropsModel);
	if(iPropCount <= 1 || !g_iProp[id])
		return PLUGIN_HANDLED;

	g_iCurrentPropIndex[id]++;
	if(g_iCurrentPropIndex[id] >= iPropCount)
		g_iCurrentPropIndex[id] = 0;

	set_hider_prop_model(id, g_iCurrentPropIndex[id]);
	return PLUGIN_HANDLED;
}
	
public cmd_chooseteam(id)
{
	if(!get_pcvar_num(g_CvarBlockteam) || is_user_admin(id))
	{
		if(g_iHunterClass[id])
			g_iHunterClass[id] = 0;
			
		return PLUGIN_CONTINUE;
	}
		
	static CsTeams:team;
	team = cs_get_user_team(id);
	if(team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
	{
		new iteam = get_new_team();
		engclient_cmd(id, g_cmdTeam[0], g_teamnum[iteam]);
		engclient_cmd(id, g_cmdTeam[2], g_classnum[random_num(0,3)]);
		if(g_iHunterClass[id])
			g_iHunterClass[id] = 0;
			
		return PLUGIN_HANDLED;
	}
	else
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "CHANGE_TEAM");
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public event_TeamInfo()
{
	if(!get_pcvar_num(g_CvarBlockteam) || !g_bGameOn)
		return PLUGIN_CONTINUE;
		
	new id = read_data(1);
	new sTeam[32], iTeam;
	read_data(2, sTeam, sizeof(sTeam) - 1);
	for(new i = 0; i < 5; i++)
	{
		if(g_cTeamChars[i] == sTeam[0])
		{
			iTeam = i;
			break;
		}
	}
	
	if(g_iTeam[id] != iTeam)
	{
		g_iPlayers[g_iTeam[id]]--;
		g_iTeam[id] = iTeam;
		g_iPlayers[iTeam]++;
	}
	
	return PLUGIN_CONTINUE;
}

public camera_think(iEnt)
{
	new id = pev(iEnt, pev_owner);
	
	if(!g_bCameraOn[id])
		return;

	static Float:origin[3], Float:angle[3], Float:vBack[3], add_vec;
	pev(id, pev_origin, origin);
	pev(id, pev_v_angle, angle);

	angle_vector( angle, ANGLEVECTOR_FORWARD, vBack );

	origin[2] += 20.0;
	 
//	add_vec = 120.0;
	add_vec = get_add_vec(id, origin, vBack);
		
	origin[0] += (-vBack[0] * add_vec);
	origin[1] += (-vBack[1] * add_vec);
	origin[2] += (-vBack[2] * add_vec);

	set_pev(iEnt, pev_origin, origin);
	set_pev(iEnt, pev_angles, angle);
	    
	set_pev(iEnt, pev_nextthink, get_gametime()+ 0.01);
}

get_add_vec(id, Float:origin[3], Float:back[3])
{
	static add_vec, Float:torigin[3], Float:flFraction;
	add_vec = 5;
	
	for(new i = 20; i > 0; i--)
	{
		torigin[0] = origin[0] + (-back[0] * add_vec *i);
		torigin[1] = origin[1] + (-back[1] * add_vec *i);
		torigin[2] = origin[2] + (-back[2] * add_vec *i);
		engfunc(EngFunc_TraceLine, origin, torigin, IGNORE_MONSTERS, id, 0);
		get_tr2(0, TR_flFraction, flFraction);
		if(flFraction == 1.0)
		{
			return (add_vec*i);
		}
	}
	return 0;
}

public fwd_GameDescription() 
{ 
	new szMsg[32];
	formatex(szMsg, 31, "CS-PropHunt v%s", VERSION);
	forward_return(FMV_STRING, szMsg);
	return FMRES_SUPERCEDE;
}

public fwd_CmdStart(id, uc_handle, seed)
{
	if(!g_bIsAlive[id] || !g_bGameOn)
		return FMRES_IGNORED;
	
	static button, oldbutton, ubutton;
	button = pev(id, pev_button);
	oldbutton = pev(id, pev_oldbuttons);
	ubutton = get_uc(uc_handle, UC_Buttons);
	
	if(g_bIsHider[id])
	{
		if(ubutton & IN_ATTACK2 && !g_bAttack2Held[id])
		{
			g_bPropLocked[id] = !g_bPropLocked[id];
		}
		g_bAttack2Held[id] = (ubutton & IN_ATTACK2) ? true : false;

		if(g_bPropLocked[id])
		{
			set_pev(id, pev_maxspeed, 1.0);
		}
		else
		{
			set_pev(id, pev_maxspeed, get_pcvar_float(g_CvarHiderspeed));
		}
		
		new onground = pev(id, pev_flags) & FL_ONGROUND;
		if(button & IN_JUMP && !(oldbutton & IN_JUMP) && !onground && !g_iDoublejump[id])
		{
			g_iDoublejump[id] = 1;
		}
		
		new iEnt = g_iProp[id];
		if(!iEnt)
			return FMRES_IGNORED;
			
		static Float:origin[3], Float:angle[3];
		pev(id, pev_origin, origin);

		if(pev(id, pev_flags) & FL_DUCKING)
			origin[2] -= 18.0;
		else origin[2] -= 36.0;
		
		engfunc(EngFunc_SetOrigin, iEnt, origin);
		
		if(!g_bPropLocked[id])
		{
			pev(id, pev_v_angle, angle);
			angle[0] = 0.0;
			set_pev(iEnt, pev_angles, angle);
		}
	}
	else
	{
		static ubutton, iCurWpn;
		ubutton = get_uc(uc_handle, UC_Buttons);
		iCurWpn = g_iCurWeapon[id];
		
		if(ubutton & IN_ATTACK && ((iCurWpn == CSW_KNIFE) || (iCurWpn == CSW_XM1014)))
		{
			ubutton &= ~IN_ATTACK;
			
			if(iCurWpn == CSW_XM1014)
			{
				if(g_iFuel[id] && (get_gametime() - g_fLastfire[id] > 0.1))
					fire_throw(id);
			}
			else if(iCurWpn == CSW_KNIFE)
				ubutton |= IN_ATTACK2;
			
			set_uc(uc_handle, UC_Buttons, ubutton);
				
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public fire_throw(id)
{
	fire_spr(id);
	g_fLastfire[id] = get_gametime();
	g_iFuel[id]--;
	
	emit_sound(id, CHAN_WEAPON, g_FtSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	if(!fire_target(id))
	{
		static health;
		health = get_user_health(id) - get_pcvar_num(g_CvarHpLostAmt);
		if(health > 0)
			set_pev(id, pev_health, float(health));
		else 
		{
			user_kill(id);
			return;
		}
	}
	
	if(!g_bInHideTime && pev(id, pev_button) & IN_JUMP)
	{
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] = 550.0;
		set_pev(id, pev_velocity, velocity);
	}
	
	fire_target(id);
}

public bool:fire_target(id)
{
	static target, body;
	get_user_aiming(id, target, body, 250);
	
	if(is_hider_target(target))
	{
		if(!(1 <= target <= gMaxPlayers))
			target = pev(target, pev_owner);
	}
	else return false;
	
	static iHealth, duration, param[2];
	iHealth = pev(target, pev_health) - random_num(10, 15);
	if(iHealth <= 0)
	{
	//	make_silentkill(target);
	//	make_DeathMsg(id, target, 0, "flame thrower");
		ExecuteHamB(Ham_Killed, target, id, 0);
		return true;
	}	
	else set_pev(target, pev_health, float(iHealth));
	
	if(task_exists(target+TASK_BURN))
		remove_task(target+TASK_BURN);
		
	duration = get_pcvar_num(g_CvarFlamedura)*2;
	param[0] = duration;
	param[1] = id;
	set_task( 0.5, "StartBurn", target+TASK_BURN, param, sizeof param )
	return true;
}

public StartBurn(param[2], taskid)
{
	static id, dmg, attacker, duration, origin[3];
	id = taskid - TASK_BURN;
	dmg = 2;
	duration = param[0];
	attacker = param[1];
	get_user_origin(id, origin);
	
	if(!duration || !g_bIsAlive[id])
	{
		create_smoke(origin);
		return;
	}
	
	duration--;
	
	if(pev(id, pev_flags) & FL_ONGROUND)
	{
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)
		VectorScale(velocity, 0.5, velocity)
		set_pev(id, pev_velocity, velocity)
	}

	static health;
	health = pev(id, pev_health) - dmg;
			
	if(health <= 0)
	{
	//	make_silentkill(id);
	//	make_DeathMsg(attacker, id, 0, "flame thrower");
		ExecuteHamB(Ham_Killed, id, attacker, 0);
		create_smoke(origin);
		return;
	}	
	else set_pev(id, pev_health, float(health));
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	param[0] = duration; //update time
	set_task( 0.5, "StartBurn", id+TASK_BURN, param, sizeof param )
}
	
fire_spr(id)
{
	static Float:fOrigin[3], Float:fVelocity[3];
	
	velocity_by_aim(id, 35, fVelocity);
	pev(id, pev_origin, fOrigin);
		
	for(new i = 0; i < 3; i++)
		fOrigin[i] += fVelocity[i];
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRAY);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	engfunc(EngFunc_WriteCoord, fVelocity[0]);
	engfunc(EngFunc_WriteCoord, fVelocity[1]);
	engfunc(EngFunc_WriteCoord, fVelocity[2]+5.0);
	write_short(g_pyrofireSpr);
	write_byte(2); //count
	write_byte(15); //speed
	write_byte(1); //noise
	write_byte(5); //render
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRAY);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	engfunc(EngFunc_WriteCoord, fVelocity[0]);
	engfunc(EngFunc_WriteCoord, fVelocity[1]);
	engfunc(EngFunc_WriteCoord, fVelocity[2]+8.0);
	write_short(g_pyrofireSpr);
	write_byte(1); //count
	write_byte(8); //speed
	write_byte(1); //noise
	write_byte(5); //render
	message_end();
}

public fwd_UpdateClientData_Post( id, sendweapons, cd_handle )
{
    if(!g_bGameOn || !g_bIsAlive[id] || g_iCurWeapon[id] != CSW_XM1014)
        return FMRES_IGNORED;

    set_cd(cd_handle, CD_ID, 0);        
    
    return FMRES_HANDLED;
}

public fwd_Player_PreThink(id)
{
	if(!g_bGameOn || !g_bIsAlive[id] || !g_bIsHider[id])
		return FMRES_IGNORED;
		
	set_pev(id, pev_flTimeStepSound, 999);
	if(g_iDoublejump[id] == 2 && pev(id, pev_flags) & FL_ONGROUND)
		g_iDoublejump[id] = 0;
		
	return FMRES_IGNORED;
}

public fwd_Player_PostThink(id)
{
	if(!g_bGameOn || !g_bIsAlive[id] || !g_bIsHider[id])
		return FMRES_IGNORED;
		
	if(g_iDoublejump[id] == 1)
	{
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] = 285.0;
		set_pev(id, pev_velocity, velocity);
		g_iDoublejump[id] = 2;
	}	
		
	return FMRES_IGNORED;
}

public fwd_Spawn(ent)
{
	if(!pev_valid(ent) || ent == g_iHostage)
	{
		return FMRES_IGNORED;
	}
	
	new szClass[32];
	pev(ent, pev_classname, szClass, 31);
	
	for(new i = 0; i < sizeof g_sRemoveEntities; i++)
	{
		if(equal(szClass, g_sRemoveEntities[i]))
		{
			engfunc(EngFunc_RemoveEntity, ent);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public fwd_ClientKill(id)
{
	if(!g_bGameOn)
		return FMRES_IGNORED;
		
	ph_print(id, "You are not allowed to kill urself !");
	
	return FMRES_SUPERCEDE;
}

public show_hud()
{
	if(!g_bGameOn)
		return;
		
	static hider_count, hunter_count, color[3];
	get_player_count(hider_count, hunter_count);
	
	for(new i = 0; i < gMaxPlayers; i++)
	{
		if(!g_bIsAlive[i])
			continue;
			
		if(g_bIsHider[i])
			color = { 250, 20, 50 };
		else
		{
			color = { 30, 100, 255 };
		//	set_hudmessage( 0, 200, 0, -1.0, -1.0, 0, 6.0, 2.1, 0.0, 0.0, -1 );
		//	ShowSyncHudMsg( i, g_hudmsg[HUD_CROSSHAIR], "<+>" );
		}
			
		set_hudmessage(color[0], color[1], color[2], -1.0, 0.02, 0, _, 2.1, _, _, -1);
		ShowSyncHudMsg(i, g_hudmsg[HUD_BOARD], "Hider: %i^nHunter: %i", hider_count, hunter_count);
	}
}

get_player_count(&hider_count, &hunter_count = 0)
{
	static iHider, iHunter, id;
	iHider = iHunter = 0;
	
	for(id = 1; id <= gMaxPlayers; id++)
	{
		if(!g_bIsAlive[id])
			continue;
			
		if(g_bIsHider[id]) iHider++;
		else iHunter++;
	}
	
	hider_count = iHider, hunter_count = iHunter;
}

public task_show_clip(taskid)
{
	new id = taskid - TASK_SCLIP;
	
	if(g_iCurWeapon[id] == CSW_KNIFE)
		return;
	
	set_dhudmessage( 250, 250, 0, 0.95, 0.96, 0, 6.0, 0.2, 0.0, 0.0 );
	
	static iClass, clip, ammo; 
	iClass = g_iHunterClass[id];
	get_user_weapon(id, clip, ammo);
	
	switch(iClass)
	{
		case PYRO: show_dhudmessage( id, "Fuel: %i", g_iFuel[id] );
	}
}

public fw_ent_think(iEnt)
{
	if(!pev_valid(iEnt))
		return;
		
	static szClassname[32];
	pev(iEnt, pev_classname, szClassname, 31);
	if(equal(szClassname, g_szPlayerCamera))
		camera_think(iEnt);
}

public fw_spawn_player_post(id)
{
	if(!g_bGameOn || !is_user_alive(id) || !cs_get_user_team(id))
		return;
		
	g_bIsAlive[id] = true;
		
	g_bIsHider[id] = cs_get_user_team(id) == CS_TEAM_T ? true : false;
	
/*	message_begin(MSG_ONE, gMsgHideWeapon, _, id);
	write_byte(HIDE_HUD);
	message_end();*/
	
	if(g_bIsHider[id])
	{
		g_bPropLocked[id] = false;
		g_bAttack2Held[id] = false;
		fm_strip_user_weapons(id);
		set_playerview(id);
		set_pev(id, pev_health, 40.0);
		set_visible(id, 0);
		//enable prop
		static iProp, rand_mdl;
		iProp = g_iProp[id]
		set_visible(iProp);
		rand_mdl = random_num(0, ArraySize(g_sPropsModel) - 1);
		g_iCurrentPropIndex[id] = rand_mdl;
		set_hider_prop_model(id, rand_mdl);
	}
	else	
	{
		new iClass = g_iHunterClass[id];
		
		if(!iClass) show_class_menu(id);
		else 
		{
			if(iClass == PYRO) g_iFuel[id] = get_pcvar_num(g_CvarFtFuel);
			else
			{
				new iEnt;
				iEnt = fm_find_ent_by_owner(-1, g_szSeekerWpns[iClass], id);
				if(iEnt)
				{
					cs_set_weapon_ammo(iEnt, g_iClassAmmo[iClass]);
					if(iClass == HEAVY)
						cs_set_user_bpammo(id, CSW_M249, 100);
					else if(iClass == SNIPER)
						cs_set_user_bpammo(id, CSW_SCOUT, 30);
				}
			}
				
			set_pev(id, pev_health, float(g_iClassHealth[iClass]));
		}
				
		if(!task_exists(id+TASK_SCLIP))
			set_task(0.1, "task_show_clip", id+TASK_SCLIP, _, _, g_sB);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{	
	if(victim == attacker || !is_player_connected(attacker))
		return HAM_IGNORED;
		
	if(g_iCurWeapon[attacker] == CSW_SCOUT)
	{
		new mutil_dmg = g_iSniperDmg[attacker];
		
		if(mutil_dmg == 5)
			ExecuteHamB(Ham_Killed, victim, attacker, 0);
		else 
		{
			damage = mutil_dmg*20.0;
			SetHamParamFloat(4, damage);
		}
		
		g_iSniperDmg[attacker] = 0;
	}

	return HAM_IGNORED;
}

public fw_TakeDamage_post(victim)
{
	if(!g_bIsHider[victim])
		return;
		
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, 5) //zp code
}

public fw_killed_player(victim, killer, shouldgib)
{
	g_bIsAlive[victim] = false;
	
	if(g_bIsHider[victim])
	{
		set_visible(g_iProp[victim], 0);
			
	//	set_playerview(id, 0);
		set_visible(victim);
		
		if(!g_bInHideTime)
		{
			new Float:fTime = get_gametime() - g_fGameStartTime;
			new iSurvivalFrags = get_survival_frags(fTime);
			set_pev(victim, pev_frags, pev(victim, pev_frags) + float(iSurvivalFrags));
			ph_print(victim, "^4[PropHunt]^1 You have earned^3 %i^4 frag(s)^1 for surviving !", iSurvivalFrags);
			g_iSurvivalFrags[victim] = iSurvivalFrags;
		}
		
		if(is_player_alive(killer) && !g_bIsHider[killer])
		{
			new Float:fCvarSpeedBoost = get_pcvar_float(g_CvarSpeedBoost);
			if(fCvarSpeedBoost && !g_bHasSpeedBoost[killer])
				give_speedboost(killer, fCvarSpeedBoost);
			
			give_frags(killer, victim);
		}
	}
	else
	{
		if(task_exists(victim+TASK_HEAL))
			remove_task(victim+TASK_HEAL);
			
		remove_task(victim+TASK_SCLIP);
	}
}

public fw_WeaponAttack(iWpn)
{
	if(!g_bGameOn)
		return;
		
	static id, health;
	id = get_pdata_cbase(iWpn, 41, 4);

	if(g_iCurWeapon[id] == CSW_KNIFE)
		return;

	if(!is_hider_target_aimed(id))
	{
		health = get_user_health(id) - get_pcvar_num(g_CvarHpLostAmt);
		
		if(health > 0)
			set_pev(id, pev_health, float(health));
		else 
		{
			user_kill(id);
			return;
		}
	}
	
	if(!g_bInHideTime && pev(id, pev_button) & IN_JUMP)
	{
		new Float:velocity[3];
	//	pev(id, pev_velocity, velocity);
		velocity_by_aim(id, 50, velocity)
		velocity[2] += 450.0;
		set_pev(id, pev_velocity, velocity);
	}
	
	if(g_iCurWeapon[id] == CSW_SCOUT && g_iZoomPower[id] != 0) //for sniper
	{
		g_iSniperDmg[id] = g_iZoomPower[id];
		
		new mutil_dmg = g_iSniperDmg[id];
		if(mutil_dmg == 5)
			client_print(id, print_center, "One Shot One Kill");
		else client_print(id, print_center, "Damage: %i", mutil_dmg*20);
		
		g_iZoomPower[id] = 0;
	}
}

public cmd_choose_class(id)
{
	if(!g_bGameOn)
		return PLUGIN_HANDLED;
		
	if(g_bIsHider[id])
	{
		ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_CHOOSE_CLASS");
		return PLUGIN_HANDLED;
	}
	
	else if(!g_bInHideTime)
	{
		ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_CHOOSE_CLASS2");
		return PLUGIN_HANDLED;
	}
	
	show_class_menu(id);
	
	return PLUGIN_HANDLED;
}

public show_class_menu(id)
{
	static msg[3][64], menu;
	
	formatex(msg[0], 63, "\w Heavy\y  | %iHP + Minigun |", g_iClassHealth[1]);
	formatex(msg[1], 63, "\w Pyro\y   | %iHP + FlameThrower |", g_iClassHealth[2]);
	formatex(msg[2], 63, "\w Sniper\y | %iHP + Scout |", g_iClassHealth[3]);
	
	menu = menu_create("Hunter Class Menu:", "menu_active");
	menu_additem(menu, msg[0], "1", 0);
	menu_additem(menu, msg[1], "2", 0);
	menu_additem(menu, msg[2], "3", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}

public menu_active(id, menu, item)
{
	if(!g_bIsAlive[id])
	{
		ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_NEED_ALIVE");
		return;
	}
	
	ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_TYPE_CLASS")
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new iClass = g_iHunterClass[id];
	if(iClass != 0)
	{
		fm_strip_user_weapons(id);
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	new key = str_to_num(data);
	
	g_iHunterClass[id] = key;
	
	give_weapon(id);
}

give_weapon(id)
{
	static iClass;
	iClass = g_iHunterClass[id];
	bacon_give_weapon(id, "weapon_knife");
	bacon_give_weapon(id, g_szSeekerWpns[iClass]);
	set_pev(id, pev_health, float(g_iClassHealth[iClass]));
	
	if(iClass == PYRO)
	{
		g_iFuel[id] = get_pcvar_num(g_CvarFtFuel);
	}
	else 
	{
		new iEnt;
		iEnt = fm_find_ent_by_owner(-1, g_szSeekerWpns[iClass], id);
		if(iEnt)
		{
			cs_set_weapon_ammo(iEnt, g_iClassAmmo[iClass]);
			if(iClass == HEAVY)
				cs_set_user_bpammo(id, CSW_M249, 100);
			else if(iClass == SNIPER)
				cs_set_user_bpammo(id, CSW_SCOUT, 30);
		}
	}
}

set_hider_prop_model(id, iPropIndex)
{
	new iProp = g_iProp[id];
	if(!iProp || iPropIndex < 0 || iPropIndex >= ArraySize(g_sPropsModel))
		return 0;

	static szEntModel[64];
	ArrayGetString(g_sPropsModel, iPropIndex, szEntModel, charsmax(szEntModel));
	format(szEntModel, charsmax(szEntModel), "models/props/%s.mdl", szEntModel);
	engfunc(EngFunc_SetModel, iProp, szEntModel);
	g_iCurrentPropIndex[id] = iPropIndex;

	return 1;
}

get_survival_frags(Float:fTime)
{
	if(fTime <= 0.0)
		return 0;

	return floatround(fTime / 20.0, floatround_ceil);
}

give_speedboost(id, Float:fSpeedAdd)
{
	g_bHasSpeedBoost[id] = true;
	manage_icon(id, ICON_SPEEDBOOST);
	set_pev(id, pev_maxspeed, pev(id, pev_maxspeed)+fSpeedAdd);
	ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_GIVE_SPEEDBOOST");
}

give_frags(id, victim)
{
	new iVicFrags = g_iSurvivalFrags[victim];
	if(iVicFrags > 0)
		set_pev(id, pev_frags, pev(id, pev_frags) + float(iVicFrags));
}

public event_curweapon(id)
{
	if(!g_bGameOn)
		return PLUGIN_CONTINUE;
		
	if(g_bIsHider[id])
	{
		message_begin(MSG_ONE, gMsgHideWeapon, _, id);
		write_byte(HIDE_HUD);
		message_end();

		if(!g_bRoundEnd)
		{
			fm_strip_user_weapons(id);
			set_pev(id, pev_maxspeed, get_pcvar_float(g_CvarHiderspeed));
		}
	}
	else
	{
		new Float:fCvarSpeedBoost = get_pcvar_float(g_CvarSpeedBoost);
		
		if(g_bInHideTime)
			set_pev(id, pev_maxspeed, 1.0);
		else if(fCvarSpeedBoost && g_bHasSpeedBoost[id])
			set_pev(id, pev_maxspeed, pev(id, pev_maxspeed)+fCvarSpeedBoost);
			
		static weapon;
		weapon = read_data(2);
		g_iCurWeapon[id] = weapon;
			
		if(task_exists(id+TASK_ZOOM) && (weapon != CSW_SCOUT))
		{
			g_iZoomPower[id] = 0;
			remove_task(id+TASK_ZOOM);
		}
			
		if(weapon == CSW_XM1014)
		{
			set_pev(id, pev_weaponmodel2, g_pmdl_flamethrower);
			set_pev(id, pev_viewmodel2, g_vmdl_flamethrower);
		}
		else if(weapon == CSW_USP)
		{
			fm_strip_user_weapons(id);
			if(g_iHunterClass[id])
				give_weapon(id);
		}
		else if(weapon == CSW_M249)
		{
			static iEnt, Float:wpn_rate;
			iEnt = fm_find_ent_by_owner(-1, "weapon_m249", id);
			wpn_rate = 0.5;
			
			if(iEnt)
			{
				static Float:Delay,Float:M_Delay;
				Delay = get_pdata_float( iEnt, 46, 4) * wpn_rate;
				M_Delay = get_pdata_float( iEnt, 47, 4) * wpn_rate;
				if(Delay > 0.0)
				{
					set_pdata_float( iEnt, 46, Delay, 4);
					set_pdata_float( iEnt, 47, M_Delay, 4);
				}
			}
		}
		
		message_begin(MSG_ONE, gMsgCrossHair, {0,0,0}, id);
		write_byte(1);
		message_end();
	}
	
	return PLUGIN_CONTINUE;
}

public Event_SetFOV(id)
{
	if(read_data(1) >= 90) //zoom out
	{
		if(task_exists(id+TASK_ZOOM))
		{
			g_iZoomPower[id] = 0;
			remove_task(id+TASK_ZOOM);
		}
		
		return;
	}
		
	if(!task_exists(id+TASK_ZOOM))
	{
		task_zoom_power(id+TASK_ZOOM);
		set_task(1.0, "task_zoom_power", id+TASK_ZOOM, _, _, g_sB);
	}
}

public task_zoom_power(taskid)
{
	static id, power, color; 
	id = taskid - TASK_ZOOM;
	power = g_iZoomPower[id];
	color = 50 + power * 30;
	
	set_hudmessage(color, color, 0, -1.0, 0.75, power == 5 ? 1 : 0, _, 1.1, _, _, -1);
	ShowSyncHudMsg(id, g_hudmsg[HUD_ZOOM], "{%s%s}", g_bar[0][5 - power], g_bar[1][power]);
	
	if(power < 5)
		power++;
	
	g_iZoomPower[id] = power;
}

public heal_hp(taskid)
{
	static id;
	id = taskid - TASK_HEAL;
	manage_icon(id, ICON_BUYZONE, 0);
	set_pev(id, pev_health, float(g_iClassHealth[g_iHunterClass[id]]))
	ph_print(id, "^4[PropHunt]^1 %L", LANG_PLAYER, "C_HEALED");
}

//public EventNewRound()
public EventRoundStart()
{
	if(!g_bGameOn)
		return;
		
	g_bRoundEnd = false;
	ph_print(0, "^4oO0^3 PropHunt-v%s by Ryokin^4 0Oo", VERSION); 
	
	new time = g_iHideTime;
	
	for(new i = 0; i < gMaxPlayers; i++)
	{
		if(!g_bIsConnected[i] || g_bIsHider[i])
			continue;
			
		if(task_exists(i+TASK_HEAL))
			remove_task(i+TASK_HEAL);
			
		if(g_bCameraOn[i])
			set_playerview(i, 0);
			
		g_bHasSpeedBoost[i] = false;
			
	/*	set_pev(i, pev_maxspeed, 1.0);
		
		message_begin(MSG_ONE, gMsgScreenFade, {0, 0, 0}, i);
		write_short(floatround(4096.0 * 1.5, floatround_round));
		write_short(floatround(4096.0 * 1.5, floatround_round));
		write_short(4096);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(200);
		message_end();*/
	}
	
	g_bInHideTime = true
	
	g_iCountdownTime = time+1;
//	set_task(time, "end_hide_time", TASK_HIDETIME);
	count_down();
	set_task(1.0, "count_down", TASK_HIDETIME, _, _, g_sA, g_iCountdownTime);
}

public count_down()
{
	g_iCountdownTime--
	
	for(new i = 0; i < gMaxPlayers; i++)
	{
		if(!g_bIsAlive[i] || g_bIsHider[i])
			continue;
			
		set_pev(i, pev_maxspeed, 1.0);
		
		message_begin(MSG_ONE, gMsgScreenFade, {0, 0, 0}, i);
		write_short(floatround(4096.0 * 1.5, floatround_round));
		write_short(floatround(4096.0 * 1.5, floatround_round));
		write_short(4096);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
	
	if(g_iCountdownTime <= 5)
	{
		client_cmd(0, "spk %s", g_CountdownSound[g_iCountdownTime]);
		
		if(!g_iCountdownTime)
		{
			end_hide_time();
			return;
		}
	}
		
	set_dhudmessage( 0, 200, 0, -1.0, 0.75, 0, 6.0, 1.0, 0.0, 0.0 );
	show_dhudmessage( 0, "Time to hide: %i", g_iCountdownTime );
}

end_hide_time()
{
	for(new i = 0; i < gMaxPlayers; i++)
	{
		if(!g_bIsAlive[i] || g_bIsHider[i])
			continue;
			
		set_pev(i, pev_maxspeed, 250.0);
		
		message_begin(MSG_ONE, gMsgScreenFade, {0, 0, 0}, i);
		write_short(0);
		write_short(0);
		write_short(4096);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(150);
		message_end();
	}
	
	g_fGameStartTime = get_gametime();
	client_cmd(0, "spk %s", g_CountdownSound[0]);
	
	set_dhudmessage( 0, 200, 0, -1.0, 0.75, 0, 6.0, 3.0, 0.0, 0.0 );
	show_dhudmessage( 0, "Time's up !" );
	
	g_bInHideTime = false
}

public RestartRound()
{
	EventRoundEnd();
}

public EventRoundEnd()
{
	g_bRoundEnd = true;
	if(task_exists(TASK_HIDETIME))
		remove_task(TASK_HIDETIME);
		
	static Float:fTime, iHiderCount, winmsg[32];
	get_player_count(iHiderCount)
	
	if(iHiderCount) //hider win
	{
		formatex(winmsg, 31, "%L", LANG_PLAYER, "HIDER_WIN");
		
		for(new i = 0; i < gMaxPlayers; i++)
		{
			if(!g_bIsConnected[i])
				continue;
				
		//	add_delay_switch_team(i);
			set_dhudmessage(250, 20, 50, -1.0, 0.25, 0, _, 4.0);
			show_dhudmessage(i, winmsg);
		}
	}
	else 
	{
		formatex(winmsg, 31, "%L", LANG_PLAYER, "SEEKER_WIN_SWITCH");
		
		for(new i = 0; i < gMaxPlayers; i++)
		{
			if(!g_bIsConnected[i])
				continue;
				
			g_iHunterClass[i] = 0;
			add_delay_switch_team(i);
			set_dhudmessage(20, 100, 250, -1.0, 0.25, 0, _, 4.0);
			show_dhudmessage(i, winmsg);
		}
	}
	
	for(new i = 0; i < gMaxPlayers; i++)
	{
		if(!g_bIsAlive[i])
			continue;
		
		if(g_bIsHider[i])
		{
			set_visible(g_iProp[i], 0);
			set_visible(i);
			
			if(!g_bInHideTime)
			{
				fTime = get_gametime() - g_fGameStartTime;
				new iSurvivalFrags = get_survival_frags(fTime);
				set_pev(i, pev_frags, pev(i, pev_frags) + float(iSurvivalFrags));
				ph_print(i, "^4[PropHunt]^1 You have earned^3 %i^4 frag(s)^1 for surviving !", iSurvivalFrags);
			}
			g_iSurvivalFrags[i] = 0;
		}
		else 
		{
			manage_icon(i, ICON_BUYZONE, 0);
			manage_icon(i, ICON_SPEEDBOOST, 0);
		}
	}
}

public Event_BuyZone(id) 
{
/*	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(buyzone)
		{
			const OFFSET_BUYZONE = 235 //268
			set_pdata_int(id, OFFSET_BUYZONE, get_pdata_int(id, OFFSET_BUYZONE) & ~(1<<0));
			return PLUGIN_HANDLED;
		}
	}*/
	if(g_bIsAlive[id] && !g_bIsHider[id] && !g_bRoundEnd && !g_bInHideTime)
	{
		new hp = get_user_health(id);
		
		if(!read_data(1))
		{
			if(task_exists(id+TASK_HEAL))
			{
				client_print(id, print_center, "%L", LANG_PLAYER, "STOP_HEAL");
				manage_icon(id, ICON_BUYZONE, 0);
				remove_task(id+TASK_HEAL);
				manage_bar(id, 0)
				ClearSyncHud(id, g_hudmsg[HUD_OBJ])
			}
		}
		else if(hp < g_iClassHealth[g_iHunterClass[id]] && !task_exists(id+TASK_HEAL))
		{
			client_print(id, print_center, "%L", LANG_PLAYER, "HEALING");
			new time = get_pcvar_num(g_CvarHealtime);
			set_task(float(time), "heal_hp", id+TASK_HEAL);
			manage_icon(id, ICON_BUYZONE);
			manage_bar(id, time)
			set_hudmessage(200, 200, 0, -1.0, -1.0, 0, 6.0, float(time), 0.0, 0.0, -1);
			ShowSyncHudMsg(id, g_hudmsg[HUD_OBJ], "Healing >>");
		}
	}
	
	return PLUGIN_CONTINUE;
}

public msg_textmsg(msgid, dest, id)
{
	if(!g_bGameOn || get_msg_arg_int(1) != 4)
		return PLUGIN_CONTINUE;
	
	static txtmsg[25];
	get_msg_arg_string(2, txtmsg, 24);
	
	if(equal(txtmsg[1], g_sMsgWins[0]) || equal(txtmsg[1], g_sMsgWins[1]) || equal(txtmsg[1], g_sMsgWins[2]))
	{
		set_msg_arg_string(2, g_sBlank);
	}
	else if(equal(txtmsg[1], g_sCommandNotAvailable))
		return PLUGIN_HANDLED;
		
	return PLUGIN_CONTINUE;
}

add_delay_switch_team(id)
{
	new const szTaskChangeTeam[32] = "change_team";
	switch(id)
	{
		case 1..7: set_task( 0.1, szTaskChangeTeam, id );
		case 8..15: set_task( 0.5, szTaskChangeTeam, id );
		case 16..23: set_task( 1.0, szTaskChangeTeam, id );
		case 24..32: set_task( 1.5, szTaskChangeTeam, id );
	}
}

public change_team(id)
{
	cs_set_user_team(id, g_bIsHider[id] ? CS_TEAM_CT : CS_TEAM_T);
	g_bIsHider[id] = (g_bIsHider[id] ? false : true);
	g_bPropLocked[id] = false;
	g_bAttack2Held[id] = false;
}

public event_touch_weapon(iEnt, id)
	return HAM_SUPERCEDE;
	
public msg_weaponpickup(msgid, dest, id)
	return PLUGIN_HANDLED;

public msg_ammopickup(msgid, dest, id)
	return PLUGIN_HANDLED;
	
ph_print(const id, const message[], any:...) 
{
	new szMessage[192];
	vformat(szMessage, 191, message, 3);
	
	replace_all(szMessage, 191, "\g", "^4"); // Green Color
	replace_all(szMessage, 191, "\y", "^1"); // Default Color
	replace_all(szMessage, 191, "\t", "^3"); // Team Color
   
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, gMsgSayText, _, id);
	write_byte(id ? id : 1);
	write_string(szMessage);
	message_end();
}

stock bacon_give_weapon(index, weapon[])
{
	if(!equal(weapon, "weapon_", 7))
		return 0;

	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, weapon));
	if(!pev_valid(iEnt))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(iEnt, pev_origin, origin);
	set_pev(iEnt, pev_spawnflags, pev(iEnt, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEnt);

	new save = pev(iEnt, pev_solid);
	dllfunc(DLLFunc_Touch, iEnt, index);
	if(pev(iEnt, pev_solid) != save)
		return iEnt;

	engfunc(EngFunc_RemoveEntity, iEnt);

	return -1;
}

stock fm_strip_user_weapons(index) 
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"));
	if (!pev_valid(iEnt))
		return 0;

	dllfunc(DLLFunc_Spawn, iEnt);
	dllfunc(DLLFunc_Use, iEnt, index);
	engfunc(EngFunc_RemoveEntity, iEnt);

	return 1;
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", iEnt = index
	switch (jghgtype) 
	{
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}
	
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, strtype, classname)) && pev(iEnt, pev_owner) != owner) {}
	
	return iEnt
}

bool:is_hider_target(target)
{
	if(is_player_alive(target) && g_bIsHider[target])
		return true;

	if(pev_valid(target))
	{
		static szClassname[32];
		pev(target, pev_classname, szClassname, charsmax(szClassname));
		if(equal(szClassname, g_szHiderProp))
		{
			new owner = pev(target, pev_owner);
			if(is_player_alive(owner) && g_bIsHider[owner])
				return true;
		}
	}

	return false;
}

bool:is_hider_target_aimed(id)
{
	new target, body;
	get_user_aiming(id, target, body);
	return is_hider_target(target);
}

get_new_team()
{
	new iTCount = g_iPlayers[TEAM_T];
	new iCTCount = g_iPlayers[TEAM_CT];
	if(iTCount < iCTCount)
		return TEAM_T;
	else if(iTCount > iCTCount)
		return TEAM_CT;
	else
		return random_num(TEAM_T, TEAM_CT);
	
	return -1;
}

set_playerview(id, mode = 1)
{
	if(mode)
	{
		new iEnt = g_iCamera[id];
		engfunc(EngFunc_SetView, id, iEnt);
		g_bCameraOn[id] = true;
	//	set_pev(iEnt, pev_nextthink, get_gametime()); 
		camera_think(iEnt);
	}
	else //disable camera
	{
		g_bCameraOn[id] = false;
		engfunc(EngFunc_SetView, id, id);
	}
}
/*
make_DeathMsg(killer, victim, headshot, const weapon[])
{
	message_begin(MSG_ALL, gMsgDeathmsg, {0,0,0}, 0);
	write_byte(killer);
	write_byte(victim);
	write_byte(headshot);
	write_string(weapon);
	message_end();

	return 1;
}

make_silentkill(id)
{
	static msgid, msgblock;
	msgid = gMsgDeathmsg;
	msgblock = get_msg_block(msgid);
	set_msg_block(msgid, BLOCK_ONCE);	
	user_kill(id, 1);
	set_msg_block(msgid, msgblock);

	return 1;
}*/

create_smoke(const origin[3])
{
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SMOKE) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]-50) // z
	write_short(g_smokeSpr) // sprite
	write_byte(random_num(15, 20)) // scale
	write_byte(random_num(10, 20)) // framerate
	message_end()
}

manage_icon(id, icon_kind, status = 1)
{
	message_begin(MSG_ONE, gMsgStatusIcon, _, id);
	write_byte(status); // status (0=hide, 1=show, 2=flash)
	if(icon_kind) write_string("plus"); // sprite name
	else write_string("dmg_rad");
	write_byte(0); // red
	write_byte(200); // green
	write_byte(0); // blue
	message_end();
}

manage_bar(id, time)
{
	message_begin(MSG_ONE_UNRELIABLE, gMsgBarTime, _, id)
	write_short(time)
	message_end()
}

set_visible(iEnt, VISIBLE = 1)
	set_pev(iEnt, pev_effects, VISIBLE ? pev(iEnt, pev_effects) & ~EF_NODRAW : pev(iEnt, pev_effects) | EF_NODRAW);
	

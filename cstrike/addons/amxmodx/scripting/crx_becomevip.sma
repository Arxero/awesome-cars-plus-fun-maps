#include <amxmodx>
#include <amxmisc>
#include <colorchat>

/* Uncomment this line to use csstats (kills from /rank), instead of nVault */
//#define USE_CSSTATS

/* Comment this line to disable the HUD message on player spawn */
#define USE_HUD

#if defined USE_CSSTATS
	#include <csstats>
#else
	#include <nvault>
	#define nvault_clear(%1) nvault_prune(%1, 0, get_systime() + 1)
	new g_iVault
	
	/* Uncomment this to save data by SteamID and make the plugin work for players with a valid SteamID only */
	//#define USE_STEAM
	
	/* Uncomment this if you want the data to be saved right away - this will prevent losing data when the server crashes */
	#define QUICK_SAVE
	
	#if defined USE_STEAM
		#define get_save_info get_user_authid
	#else
		#define get_save_info get_user_name
	#endif
#endif

#if defined USE_HUD
	#include <hamsandwich>
	
	#define HUD_COLOR_RED 195
	#define HUD_COLOR_GREEN 195
	#define HUD_COLOR_BLUE 0
	#define HUD_POSITION_X 0.02
	#define HUD_POSITION_Y 0.40
	#define HUD_EFFECTS 2
	#define HUD_FXTIME 1.0
	#define HUD_HOLDTIME 5.0
	#define HUD_FADEINTIME 0.03
	#define HUD_FADEOUTTIME 0.1
	#define HUD_CHANNEL -1
#endif

#define PLUGIN_VERSION "1.1"

new g_szPrefix[32] = "^1[^3VIP Plus^1]"
new g_pKills, g_pFlags
new g_iKills[33], g_szFlags[32], g_iFlags, g_iNeededKills, g_iFlagZ

public plugin_init()
{
	register_plugin("Become VIP Plus", PLUGIN_VERSION, "OciXCrom")
	register_cvar("BecomeVIPPlus", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	
	#if !defined USE_CSSTATS
		register_concmd("becomevip_restartall", "restartAll", ADMIN_RCON, "deletes the becomeVIP data")
		register_concmd("becomevip_restart_player", "restartPlayer", ADMIN_RCON, "<nick|#userid>")
	#endif
	
	#if defined USE_HUD
		RegisterHam(Ham_Spawn, "player", "eventPlayerSpawn", 1)
	#endif
	
	register_clcmd("say /kills", "cmdKills")
	register_clcmd("say_team /kills", "cmdKills")
	register_event("DeathMsg", "eventPlayerKilled", "a")
	
	g_pKills = register_cvar("becomevip_kills", "1000")
	g_pFlags = register_cvar("becomevip_flags", "b")
	get_pcvar_string(g_pFlags, g_szFlags, charsmax(g_szFlags))
	
	g_iFlags = read_flags(g_szFlags)
	g_iNeededKills = get_pcvar_num(g_pKills)
	g_iFlagZ = read_flags("z")
	
	#if !defined USE_CSSTATS
		g_iVault = nvault_open("BecomeVIPPlus")
	#endif
}

public plugin_natives()
{
	register_library("becomevip")
	register_native("IsUserVip", "_IsUserVip")
	register_native("GetKillsNeeded", "_GetKillsNeeded")
	register_native("GetUserKills", "_GetUserKills")
	register_native("GetKillsLeft", "_GetKillsLeft")
	register_native("GetVipPrefix", "_GetVipPrefix")
	register_native("GetVipFlags", "_GetVipFlags")
	register_native("VipFlagsActive", "_VipFlagsActive")
	register_native("UsingCsstats", "_UsingCsstats")
	register_native("UsingHud", "_UsingHud")
	register_native("UsingSteam", "_UsingSteam")
	register_native("UsingQuickSave", "_UsingQuickSave")
}

public bool:_IsUserVip(iPlugin, iParams)
	return is_user_vip(get_param(1))
	
public _GetKillsNeeded(iPlugin, iParams)
	return g_iNeededKills
	
public _GetUserKills(iPlugin, iParams)
	return get_frags_total(get_param(1))
	
public _GetKillsLeft(iPlugin, iParams)
	return get_frags_left(get_param(1))
	
public _GetVipPrefix(iPlugin, iParams)
	set_string(1, g_szPrefix, get_param(2))
	
public _GetVipFlags(iPlugin, iParams)
	set_string(1, g_szFlags, get_param(2))
	
public bool:_VipFlagsActive(iPlugin, iParams)
	return g_szFlags[0] == EOS ? false : true
	
public bool:_UsingCsstats(iPlugin, iParams)
{
	#if defined USE_CSSTATS
		return true
	#else
		return false
	#endif
}

public bool:_UsingHud(iPlugin, iParams)
{
	#if defined USE_HUD
		return true
	#else
		return false
	#endif
}

public bool:_UsingSteam(iPlugin, iParams)
{
	#if defined USE_STEAM
		return true
	#else
		return false
	#endif
}

public bool:_UsingQuickSave(iPlugin, iParams)
{
	#if defined QUICK_SAVE
		return true
	#else
		return false
	#endif
}

public client_authorized(id)
{
	#if defined USE_CSSTATS
		set_task(5.0, "authorizePlayer", id)
	#else
		updateUserFlags(id)
	#endif
}

public authorizePlayer(id)
	if(is_user_vip(id))
		updateUserFlags(id)
	
public client_connect(id)
{
	#if !defined USE_CSSTATS
		#if defined USE_STEAM
			if(steam_valid(id))
				LoadData(id)
		#else
			LoadData(id)
		#endif
	#endif
}

public client_disconnect(id)
{
	#if !defined USE_CSSTATS
		#if defined USE_STEAM
			if(steam_valid(id))
				SaveData(id)
		#else
			SaveData(id)
		#endif
	#endif
}
	
#if !defined USE_CSSTATS
	SaveData(id)
	{
		new szInfo[35], szKills[10]
		get_save_info(id, szInfo, charsmax(szInfo))
		num_to_str(g_iKills[id], szKills, charsmax(szKills))
		nvault_set(g_iVault, szInfo, szKills)
	}

	LoadData(id)
	{
		new szInfo[32], szKills[10]
		get_save_info(id, szInfo, charsmax(szInfo))
		nvault_get(g_iVault, szInfo, szKills, charsmax(szKills))
		g_iKills[id] = str_to_num(szKills)
	}
#endif

public plugin_end()
{
	#if !defined USE_CSSTATS
		nvault_close(g_iVault)
	#endif
}

public eventPlayerSpawn(id)
{
	#if defined USE_HUD
		if(!is_user_vip(id) && is_user_alive(id))
		{
			set_hudmessage(HUD_COLOR_RED, HUD_COLOR_GREEN, HUD_COLOR_BLUE, HUD_POSITION_X, HUD_POSITION_Y, HUD_EFFECTS, HUD_FXTIME, HUD_HOLDTIME, HUD_FADEINTIME, HUD_FADEOUTTIME, HUD_CHANNEL)
			show_hudmessage(id, "Reach %i kills to become VIP^nYou have: %i", g_iNeededKills, get_frags_total(id))
		}
	#endif
}

public restartAll(id, level, cid)
{
	if(!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED

	new szName[32], iPlayers[32], iPnum
	get_user_name(id, szName, charsmax(szName))
	get_players(iPlayers, iPnum)
	
	#if !defined USE_CSSTATS
		nvault_clear(g_iVault)
	#endif
	
	for(new i; i < iPnum; i++)
		g_iKills[iPlayers[i]] = 0
		
	ColorChat(0, TEAM_COLOR, "%s ^3%s ^1has deleted all ^4becomeVIP data^1. The stats are now ^3restarted^1.", g_szPrefix, szName)
	client_print(id, print_console, "%s Data cleared successfully!", g_szPrefix)
	log_amx("%s has deleted all becomeVIP data", szName)
	return PLUGIN_HANDLED
}

public restartPlayer(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new szArg[32], szName[32], szName2[32]
	get_user_name(id, szName, charsmax(szName))
	read_argv(1, szArg, charsmax(szArg))
	new iPlayer = cmd_target(id, szArg, 3)
	
	if(!iPlayer)
		return PLUGIN_HANDLED
	
	g_iKills[iPlayer] = 0
	get_user_name(iPlayer, szName2, charsmax(szName2))
	ColorChat(0, TEAM_COLOR, "%s ^1ADMIN ^3%s ^1restarted ^3%s^1's becomeVIP data.", g_szPrefix, szName, szName2)
	client_print(id, print_console, "%s You have restarted %s's becomeVIP data.", g_szPrefix, szName2)
	log_amx("%s restarted %s's becomeVIP data", szName, szName2)
	return PLUGIN_HANDLED
}
	
public cmdKills(id)
{
	#if defined USE_STEAM
		if(!steam_valid(id))
		{
			ColorChat(id, TEAM_COLOR, "%s Only players with a valid ^3SteamID ^1can use this option (^4Protocol 47/48^1).", g_szPrefix)
			return PLUGIN_HANDLED
		}
	#endif
	
	if(is_user_vip(id)) ColorChat(id, TEAM_COLOR, "%s You have the required number of kills (^4%i/%i^1), thus you get ^3free VIP extras^1.", g_szPrefix, get_frags_total(id), g_iNeededKills)
	else
	{
		if(g_iFlags) ColorChat(id, TEAM_COLOR, "%s You need ^4%i ^1more kills (^3current: ^4%i^1) to get the following ^3VIP flag(s)^1: ^4%s", g_szPrefix, get_frags_left(id), get_frags_total(id), g_szFlags)
		else ColorChat(id, TEAM_COLOR, "%s You need ^4%i ^1more kills (^3current: ^4%i^1) to get ^3VIP extras", g_szPrefix, get_frags_left(id), get_frags_total(id))
	}
	return PLUGIN_HANDLED
}
	
public eventPlayerKilled()
{
	new iKiller = read_data(1), iVictim = read_data(2)
	
	if(!is_user_connected(iKiller) || !is_user_connected(iVictim) || iKiller == iVictim)
		return
		
	#if defined USE_STEAM
		if(!steam_valid(iKiller))
			return
	#endif
		
	#if !defined USE_CSSTATS
		g_iKills[iKiller]++
	#else
		#if defined QUICK_SAVE
			SaveData(iKiller)
		#endif
	#endif
	
	if(get_frags_total(iKiller) == g_iNeededKills)
	{
		new szName[32]
		get_user_name(iKiller, szName, charsmax(szName))
		ColorChat(0, TEAM_COLOR, "%s ^3%s ^1has killed ^4%i players ^1and received ^3free VIP extras^1!", g_szPrefix, szName, g_iNeededKills)
		updateUserFlags(iKiller)
	}
}

updateUserFlags(id)
{
	#if defined USE_STEAM
		if(!steam_valid(id))
			return
	#endif
	
	if(is_user_vip(id))
	{
		set_user_flags(id, g_iFlags)
		remove_user_flags(id, g_iFlagZ)
	}
}

get_frags_total(id)
{
	#if defined USE_CSSTATS
		new iStats[8], iHits[8]
		get_user_stats(id, iStats, iHits)
		return iStats[0]
	#else
		return g_iKills[id]
	#endif
}

get_frags_left(id)
	return g_iNeededKills - get_frags_total(id)

bool:is_user_vip(id)
	return get_frags_total(id) >= g_iNeededKills ? true : false
	
#if defined USE_STEAM
	bool:steam_valid(id)
	{
		new szAuthId[35]
		get_user_authid(id, szAuthId, charsmax(szAuthId))
		
		if(!equali(szAuthId, "STEAM_", 6) || equal(szAuthId, "STEAM_ID_LAN") || equal(szAuthId, "STEAM_ID_PENDING"))
			return false
		
		return true
	}
#endif
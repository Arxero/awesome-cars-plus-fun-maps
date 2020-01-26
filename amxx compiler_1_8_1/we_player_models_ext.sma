/* Sublime AMXX Editor v2.3 ReCreated by AJW1337// */

#include <amxmodx>

/* Common include libraries */
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>

#define PLUGIN  "Winter Environment [Player Models]"
#define VERSION "1.0"
#define AUTHOR  "Huehue"
#define GAMETRACKER "we_player_models"

#define VIP_FLAG	ADMIN_RESERVATION
#define ADMIN_FLAG 	ADMIN_RESERVATION

new g_szModel[33][32]

new const g_szPlayerModels[][] =
{
	"", "we_player_tt", "we_player_ct"
}

new const g_szVipModels[][] =
{
	"", "we_vip_tt", "we_vip_ct"
}

new const g_szAdminModels[][] =
{
	"", "we_vip_tt", "we_vip_ct"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(GAMETRACKER, AUTHOR, FCVAR_SERVER | FCVAR_SPONLY)
	set_cvar_string(GAMETRACKER, AUTHOR)

	register_forward(FM_SetClientKeyValue, "FM__SetClientKeyValue")
	register_message(get_user_msgid("ClCorpse"), "Event_ClCorpse")
	
	RegisterHam(Ham_Spawn, "player", "CBase__Ham_Spawn", 1)
}

public plugin_precache()
{
	new i
	for (i = 1; i < sizeof g_szPlayerModels; i++)
		precache_player_model(g_szPlayerModels[i])

	for (i = 1; i < sizeof g_szVipModels; i++)
		precache_player_model(g_szVipModels[i])

	for (i = 1; i < sizeof g_szAdminModels; i++)
		precache_player_model(g_szAdminModels[i])
	
}

public client_connect(id)
{
	g_szModel[id][0] = EOS
}
public CBase__Ham_Spawn(id)
{
	if (is_user_alive(id))
	{
		if (get_user_flags(id) & ADMIN_FLAG)
			SetUserModel(id, g_szAdminModels[get_user_team(id)])
		else if (get_user_flags(id) & VIP_FLAG)
			SetUserModel(id, g_szVipModels[get_user_team(id)])
		else
			SetUserModel(id, g_szPlayerModels[get_user_team(id)])
			
		set_user_info(id, "model", g_szModel[id])
	}
}

public FM__SetClientKeyValue(id, const szInfoBuffer[], const szKey[], const szValue[])
{
	if(g_szModel[id][0] && equal(szKey, "model") && !equal(szValue, g_szModel[id]))
	{
		set_user_info(id, "model", g_szModel[id])
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
	
public Event_ClCorpse()
{
	new id = get_msg_arg_int(12)
		    
	if(g_szModel[id][0])
	{
		set_msg_arg_string(1, g_szModel[id])
	}
}
stock SetUserModel(id, szModelName[])
{
	return copy(g_szModel[id], charsmax(g_szModel), szModelName);
}

stock precache_player_model(szModel[])
{
	new szFile[512]
	formatex(szFile, charsmax(szFile), "models/player/%s/%s.mdl", szModel, szModel)
	precache_model(szFile)
	replace(szFile, charsmax(szFile), ".mdl", "T.mdl")
			
	if (file_exists(szFile))
		precache_model(szFile)
}
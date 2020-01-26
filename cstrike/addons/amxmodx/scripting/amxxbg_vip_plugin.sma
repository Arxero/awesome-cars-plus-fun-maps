#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#define PLUGIN_VERSION "1.0"
#define VIP_FLAG ADMIN_RESERVATION

public plugin_init()
{
	register_plugin("Generated VIP Plugin", PLUGIN_VERSION, "AMXX-BG.info")
	register_cvar("amxxbg_vip", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	register_message(get_user_msgid("ScoreAttrib"), "OnScoreAttrib")
}

public OnPlayerSpawn(id)
{
	if(!is_user_alive(id) || !is_user_vip(id))
		return

	give_item(id, "item_assaultsuit")
	give_item(id, "item_thighpack")
	give_item(id, "weapon_hegrenade")
	give_item(id, "weapon_flashbang")
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
	give_item(id, "weapon_smokegrenade")
}

public OnScoreAttrib(iMsgId, iMsgDest, iMsgEnt)
{
	if(is_user_vip(get_msg_arg_int(1)) && !get_msg_arg_int(2))
		set_msg_arg_int(2, ARG_BYTE, (1<<2))
}

bool:is_user_vip(id)
	return !!(get_user_flags(id) & VIP_FLAG)
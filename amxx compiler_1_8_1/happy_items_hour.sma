#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#define TASK_MESSAGE 344874

new bool:g_bHappyHour, g_pStart, g_pEnd, g_iStart, g_iEnd, g_iObject

public plugin_init()
{
	register_plugin("Happy Hour", "1.0", "OciXCrom")
	register_logevent("OnRoundStart", 2, "1=Round_Start")
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	g_pStart = register_cvar("happyhour_start", "22")
	g_pEnd = register_cvar("happyhour_end", "11")
	g_iObject = CreateHudSyncObj()
}
	
public OnRoundStart()
{
	g_iStart = get_pcvar_num(g_pStart)
	g_iEnd = get_pcvar_num(g_pEnd)
	g_bHappyHour = is_happy_hour(g_iStart, g_iEnd)
	
	if(g_bHappyHour)
		set_task(1.0, "display_message", TASK_MESSAGE, .flags = "b")
	else
		remove_task(TASK_MESSAGE)
}
	
public OnPlayerSpawn(id)
{
	if(!is_user_alive(id) || !g_bHappyHour)
		return
		
	give_item(id, "weapon_deagle")
	cs_set_user_bpammo(id, CSW_DEAGLE, 35)
	
	give_item(id, "weapon_hegrenade")
	give_item(id, "weapon_flashbang")
	give_item(id, "weapon_flashbang")
	give_item(id, "weapon_smokegrenade")
}

public display_message()
{	
	set_hudmessage(0, 255, 0, 0.02, 0.2, 0, 0.1, 1.0, 0.1, 0.1, -1)
	ShowSyncHudMsg(0, g_iObject, "Happy Hours ^nfrom %i:00 to %i:00", g_iStart, g_iEnd)
}

bool:is_happy_hour(const iStart, const iEnd)
{
    static iHour; time(iHour)
    return bool:(iStart < iEnd ? (iStart <= iHour < iEnd) : (iStart <= iHour || iHour < iEnd))
}
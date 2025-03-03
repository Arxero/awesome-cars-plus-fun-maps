#include <amxmodx>
#include <engine>

#define PLUGIN_VERSION "1.0"

new const g_szEntities[][] = { "player_weaponstrip", "game_player_equip", "armoury_entity" }

new const g_szMaps[][] =
{
	"awp_snowfun2"
}

public plugin_init()
{
	register_plugin("No Weapons On Ground", PLUGIN_VERSION, "OciXCrom")
	register_cvar("NoWeaponsOnGround", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	
	new szMap[32], bool:bMatch
	get_mapname(szMap, charsmax(szMap))
	
	for(new i; i < sizeof(g_szMaps); i++)
	{
		if(equali(szMap, g_szMaps[i]))
		{
			bMatch = true
			break
		}
	}
	
	if(!bMatch)
	{
		pause("ad")
		return
	}
		
	register_clcmd("drop", "OnWeaponDrop")
	
	for(new i, iEnt = -1; i < sizeof(g_szEntities); i++)
	{
		iEnt = -1
		
		while((iEnt = find_ent_by_class(iEnt, g_szEntities[i])) > 0)
			remove_entity(iEnt)
	}
}

public OnWeaponDrop(id)
	return PLUGIN_HANDLED
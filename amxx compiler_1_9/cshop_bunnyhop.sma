#include <amxmodx>
#include <customshop>
#include <engine>

#define PLUGIN_VERSION "3.x"

additem ITEM_BUNNYHOP
new bool:g_bHasItem[33]

public plugin_init()
{
	register_plugin("Crom's Bunny Hopper", PLUGIN_VERSION, "OciXCrom")
	register_cvar("@BunnyHopper", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
}

public plugin_precache()
	ITEM_BUNNYHOP = cshop_register_item("bunnyhop", "Bunny Hop", 5000)
	
public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_BUNNYHOP)
		g_bHasItem[id] = true
}

public cshop_item_removed(id, iItem)
{
	if(iItem == ITEM_BUNNYHOP)
		g_bHasItem[id] = false
}

public client_putinserver(id)
	g_bHasItem[id] = false

public client_PreThink(id)
{
	entity_set_float(id, EV_FL_fuser2, 0.0)

	if(g_bHasItem[id] && entity_get_int(id, EV_INT_button) & IN_JUMP)
	{
		new iFlags = entity_get_int(id, EV_INT_flags)

		if(iFlags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2 || !(iFlags & FL_ONGROUND))
			return

		new Float:fVelocity[3]
		entity_get_vector(id, EV_VEC_velocity, fVelocity)
		fVelocity[2] += 250.0
		entity_set_vector(id, EV_VEC_velocity, fVelocity)
		entity_set_int(id, EV_INT_gaitsequence, 6)
	}
}
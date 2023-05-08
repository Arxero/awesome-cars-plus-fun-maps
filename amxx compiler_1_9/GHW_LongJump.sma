/*
*   _______     _      _  __          __
*  | _____/    | |    | | \ \   __   / /
*  | |         | |    | |  | | /  \ | |
*  | |         | |____| |  | |/ __ \| |
*  | |   ___   | ______ |  |   /  \   |
*  | |  |_  |  | |    | |  |  /    \  |
*  | |    | |  | |    | |  | |      | |
*  | |____| |  | |    | |  | |      | |
*  |_______/   |_|    |_|  \_/      \_/
*
*
*
*  Last Edited: 01-05-08
*
*  ============
*   Changelog:
*  ============
*
*  v1.0
*    -Initial Release
*
*/

#define VERSION	"1.0"

#include <chr_engine>

new toggle_pcvar, speed_pcvar, gravity_pcvar, bhop_pcvar

public plugin_init()
{
	register_plugin("Long Jump + Bunny Hop","1.0","GHW_Chronic")

	toggle_pcvar = register_cvar("longjump_on","1")
	speed_pcvar = register_cvar("longjump_speed","500.0")
	gravity_pcvar = get_cvar_pointer("sv_gravity")
	bhop_pcvar = register_cvar("longjump_bhop","0")

	register_forward(FM_PlayerPreThink,"FM_PreThink")
}

public FM_PreThink(id)
{
	if(get_pcvar_num(toggle_pcvar) && (pev(id,pev_button) & IN_JUMP) && (pev(id,pev_flags) & FL_ONGROUND))
	{
		if(get_pcvar_num(bhop_pcvar) || !(pev(id,pev_oldbuttons) & IN_JUMP)) blah(id)
	}
}

public blah(id)
{
	set_speed(id,get_pcvar_float(speed_pcvar),3)
	static Float:velocity[3]
	pev(id,pev_velocity,velocity)
	velocity[2] = get_pcvar_float(gravity_pcvar) / 3.0
	new button = pev(id,pev_button)
	if(button & IN_BACK)
	{
		velocity[0] *= -1
		velocity[1] *= -1
	}
	set_pev(id,pev_velocity,velocity)
}

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define VERSION "1.2"
//#define	FL_ONGROUND	(1<<9)	// not moving on the ground (REMOVE)

new bunny_mode, bunny_factor;

public plugin_init() {
	register_plugin("Auto BunnyHop", VERSION, "Night Dreamer");
	register_cvar("Auto_BunnyHop_version",    VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	set_cvar_string("Auto_BunnyHop_version",    VERSION);	
	bunny_mode = register_cvar("abh_on","1");
	bunny_factor = register_cvar("abh_factor","0");
	RegisterHam(Ham_Player_Jump,"player","bunnyhop");
}

public bunnyhop(id) {
	if(get_pcvar_num(bunny_mode) == 0)
		return HAM_IGNORED;
	{
	if((pev(id,pev_flags) & FL_ONGROUND) && get_pcvar_float(bunny_factor) >= 1)
	{
	      new Float: Vel[3];
	      pev(id,pev_velocity,Vel);
	      Vel[2] = get_pcvar_float(bunny_factor);
	      set_pev(id,pev_velocity,Vel);
	      set_pev(id,pev_gaitsequence, 6);
	      set_pev(id,pev_frame, 0.0)
	}
	if((pev(id,pev_flags) & FL_ONGROUND) && get_pcvar_float(bunny_factor) <= 0)
	{
	      new Float: Vel[3], Float: Spd;
	      pev(id,pev_maxspeed,Spd);
	      pev(id,pev_velocity,Vel);
	      Vel[2] = Spd;
	      set_pev(id,pev_velocity,Vel);
	      set_pev(id,pev_gaitsequence, 6);
	      set_pev(id,pev_frame, 0.0)
	}
	}
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/

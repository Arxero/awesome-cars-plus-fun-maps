/*
	Worms Like deaths
	by Drekes
	
	Description:
	
		There are a lot of people that know the worms games.
		This plugin tryes to reinact that style of death, by making an explosion and 
		putting a grave like the dead worms do.
	
	
	Cvars:
	
		amx_wormsdeaths_on 1					Turns worms deaths on/off
		amx_wormsdeath_sound 1					Turns the sound on/off
		amx_wormsdeath_hidecorpse 1				Turns hiding dead body's on/off
	
	Changelog:
	
		v1.0: Initial release
		v1.1: Added cvar to hide corpse
		v1.2: Optimized a lot of code
			  Changed the way to hide the corpse
		
	Credits:
	
		Wrecked: Helping to solve annoying tag mismatch and other stuff
		Anakin_cstrike: the grave models
		Arkshine: Alot of improvement info
		
	Note:
		
		I made the corpse invisible, because blocking the msg wasn't working like i expected
		
	To do:
		I have no idea
		
*/
#include <amxmodx>
#include <hamsandwich>
#include <engine>

#define VERSION "1.2"

new const hahasnd[] = "QuakeSounds/nade.wav";

new const g_mdl_tgrave[] = "models/wormsdeaths/t_grave.mdl";
new const g_mdl_ctgrave[] = "models/wormsdeaths/ct_grave.mdl";

new const g_Classname[] = "worms_grave";


new cvar_on, cvar_sound, cvar_hidecorpse;
new xplodespr, smokespr;



public plugin_init()
{
	register_plugin("Worms like Deaths", VERSION, "Drekes");

	RegisterHam(Ham_Killed, "player", "Event_Ham_Killed_Pre", 0);
	
	register_cvar("wormsdeaths_version",VERSION,FCVAR_SERVER | FCVAR_SPONLY);
	
	register_think(g_Classname, "Fwd_Grave_Think");

	cvar_on = register_cvar("amx_wormsdeath_on", "1");
	cvar_sound = register_cvar("amx_wormsdeath_sound", "1");
	cvar_hidecorpse = register_cvar("amx_wormsdeath_hidecorpse", "1");
}

public plugin_precache()
{
	precache_model(g_mdl_tgrave);
	precache_model(g_mdl_ctgrave);
	
	xplodespr = precache_model("sprites/wormsdeaths/explosion.spr");
	smokespr = precache_model("sprites/wormsdeaths/smoke.spr");
	
	precache_sound(hahasnd);
}

public Event_Ham_Killed_Pre(victim, attacker, shouldgib)
{	
	if(get_pcvar_num(cvar_on))
	{
		if(is_user_connected(victim))
		{
			new Float: origin[3];
			entity_get_vector(victim, EV_VEC_origin, origin);
			
			make_smoke(origin);
			make_explosion(origin);
			set_grave(victim, origin);
			
			if(get_pcvar_num(cvar_hidecorpse))
			{
				origin[2] -= 30.0;
				entity_set_origin(victim, origin);
			}
		}
	}
}

public set_grave(id, Float: origin[3])
{
	new ent = create_entity("info_target");
	
	if(!ent)
		return;
	
	entity_set_origin(ent, origin);
	entity_set_string(ent, EV_SZ_classname, g_Classname);
	
	switch(get_user_team(id))
	{	
		case 1:
			entity_set_model(ent, g_mdl_tgrave);
		
		case 2:
			entity_set_model(ent, g_mdl_ctgrave);
	}
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	
	new Float:maxs[3] = {10.0, 40.0, 19.0};
	new Float:mins[3] = {-11.0, -2.0, -5.0};
	entity_set_size(ent, mins, maxs);
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 10.0);
}

public Fwd_Grave_Think(Ent)
{
	if(is_valid_ent(Ent))
		remove_entity(Ent);
}

make_explosion(Float: origin[3])
{	
	new IntOrigin[3];
	FVecIVec(origin, IntOrigin);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, IntOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(IntOrigin[0]);
	write_coord(IntOrigin[1]);
	write_coord(IntOrigin[2]);
	write_short(xplodespr);
	write_byte(10);
	write_byte(2);
	write_byte(TE_EXPLFLAG_NOSOUND);
	message_end();
	
	if(get_pcvar_num(cvar_sound))
		emit_sound(0, CHAN_ITEM, "misc/grave_sound2.wav" , 1.0, ATTN_NORM, 0, PITCH_NORM);
}

make_smoke(Float: origin[3])
{
	new IntOrigin[3];
	FVecIVec(origin, IntOrigin);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, IntOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(IntOrigin[0]);
	write_coord(IntOrigin[1]);
	write_coord(IntOrigin[2]);
	write_short(smokespr);
	write_byte(50);
	write_byte(2);
	write_byte(TE_EXPLFLAG_NOSOUND);	
	message_end();
}
/* 
Created Nice Demo by sector specially for www.chatbox.do.am
Web. Help www.chatbox.do.am

Modified of Krotal's version
https://forums.alliedmods.net/showthread.php?t=49694

that give free parashute automatically 
https://amxx-bg.info/forum/viewtopic.php?f=53&t=2912&p=15690#p15690
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fun>

new para_ent[33]

public plugin_init()
{
	register_plugin("Parachute", "1.3 Fixed", "KRoT@L/JTP10181 & Fixed sector")

	register_event("ResetHUD", "newSpawn", "be")
	register_event("DeathMsg", "death_event", "a")
}

public plugin_natives()
{
	set_native_filter("native_filter")
}

public native_filter(const name[], index, trap)
{
	if (!trap) return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	precache_model("models/parachutem3v2.mdl")
}

public client_connect(id)
{
	parachute_reset(id)
}

public client_disconnect(id)
{
	parachute_reset(id)
}

public death_event()
{
	new id = read_data(2)
	parachute_reset(id)
}

parachute_reset(id)
{
	if(para_ent[id] > 0) 
	{
		if (is_valid_ent(para_ent[id])) 
		{
			remove_entity(para_ent[id])
		}
	}

	if(is_user_alive(id)) set_user_gravity(id, 1.0)
	para_ent[id] = 0
}

public newSpawn(id)
{
	if(para_ent[id] > 0) 
	{
		remove_entity(para_ent[id])
		set_user_gravity(id, 1.0)
		para_ent[id] = 0
	}
}

public client_PreThink(id)
{
	if(!is_user_alive(id)) return
	
	new Float:fallspeed = 100 * -1.0
	new Float:frame
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	new flags = get_entity_flags(id)
	if(para_ent[id] > 0 && (flags & FL_ONGROUND)) 
	{
		if(get_user_gravity(id) == 0.1) set_user_gravity(id, 1.0)
		{
			if(entity_get_int(para_ent[id],EV_INT_sequence) != 2) 
			{
				entity_set_int(para_ent[id], EV_INT_sequence, 2)
				entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
				entity_set_float(para_ent[id], EV_FL_frame, 0.0)
				entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
				entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
				entity_set_float(para_ent[id], EV_FL_framerate, 0.0)
				return
			}
			frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0
			entity_set_float(para_ent[id],EV_FL_fuser1,frame)
			entity_set_float(para_ent[id],EV_FL_frame,frame)
			if(frame > 254.0) 
			{
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
			else 
			{
				remove_entity(para_ent[id])
				set_user_gravity(id, 1.0)
				para_ent[id] = 0
			}
			return
		}
	}
	if (button & IN_USE) 
	{
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		if(velocity[2] < 0.0) 
		{
			if(para_ent[id] <= 0) 
			{
				para_ent[id] = create_entity("info_target")
				if(para_ent[id] > 0) 
				{
					entity_set_string(para_ent[id],EV_SZ_classname,"parachute")
					entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					entity_set_edict(para_ent[id], EV_ENT_owner, id)
					entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
					entity_set_model(para_ent[id], "models/parachutem3v2.mdl")
					entity_set_int(para_ent[id], EV_INT_sequence, 0)
					entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
					entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
				}
			}
			if(para_ent[id] > 0) 
			{
				entity_set_int(id, EV_INT_sequence, 3)
				entity_set_int(id, EV_INT_gaitsequence, 1)
				entity_set_float(id, EV_FL_frame, 1.0)
				entity_set_float(id, EV_FL_framerate, 1.0)
				set_user_gravity(id, 0.1)
				velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
				entity_set_vector(id, EV_VEC_velocity, velocity)
				if(entity_get_int(para_ent[id],EV_INT_sequence) == 0) 
				{
					frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
					entity_set_float(para_ent[id],EV_FL_fuser1,frame)
					entity_set_float(para_ent[id],EV_FL_frame,frame)
					if (frame > 100.0) 
					{
						entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
						entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
						entity_set_int(para_ent[id], EV_INT_sequence, 1)
						entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
						entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
					}
				}
			}
		}
		else if(para_ent[id] > 0) 
		{
			remove_entity(para_ent[id])
			set_user_gravity(id, 1.0)
			para_ent[id] = 0
		}
	}
	else if((oldbutton & IN_USE) && para_ent[id] > 0 ) 
	{
		remove_entity(para_ent[id])
		set_user_gravity(id, 1.0)
		para_ent[id] = 0
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

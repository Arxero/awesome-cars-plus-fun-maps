/*
---------------------------------------------------------
   #  #  #    #===    ###    ##    #
  #    ##     #===   #      #  #    #
   #   #      #===    ###    ##    #
---------------------------------------------------------
Respawn by <VeCo> 3.2

Plugin made by <VeCo>
Special thanks to:
 - papyrus_kn : for checking player's team when
		is connected to server and for fixing
		the spawn protection.
 - wwwhhheeeyyy : for the idea for bonus money on respawn
and random spawn version.
 - freedj : for the Zombie Plague version.
 - talibana : for the idea for bonus armor on respawn and
for the idea for the /respawn command.
 - Holder_ : for the idea for angle and view angle save in
	     the spawn point files.

If you modify the code, please DO NOT change the author!
---------------------------------------------------------
Contacts:
e-mail: veco.kn@gmail.com
skype: veco_kn
---------------------------------------------------------
Changes log:
 -> v 1.0 = First release!
 -> v 1.1 = Fixed bugs and not equip pistols if there is 
	    game_player_equip on the map. Plugin requires
	    engine module.
 -> v 1.2 = Removed unnecessary code.
	    Plugin don't needs cstrike module.
 -> v 1.3 = Fixed bug with spawn protection.
 -> v 1.4 = Fixed bug with respawn check.
 -> v 1.5 = Removed unnecessary code.
	    Plugin don't needs engine module.
 -> v 1.6 = Added CVAR for bonus money on respawn.
 -> v 1.7 = Fixed bug.
 -> v 2.0 = Zombie and hamsandwich versions are combinated
	    with the standart version.
 -> v 2.1 = Little optimization in spawn protection code.
 -> v 2.2 = Added CVARs for bonus armor on respawn.
	    The hamsandwich respawn is set by default.
 -> v 2.3 = Added chat command /respawn if something gets
	    bugged.
 -> v 3.0 = Standart version is removed.
	    Fixed bug with multiple respawn.
	    Added random respawn version (with CSDM spawn
	    points support;needs fakemeta module).
 -> v 3.1 = Added full CSDM support.
	    Added angle and view angle save in the spawn
	    point files.
 -> v 3.2 = Changed death detection to use more reliable method. (DeathMsg->Ham_Killed)
---------------------------------------------------------
Don't forget to visit http://www.amxmodxbg.org :)
---------------------------------------------------------
*/

//#define ZOMBIE_PLAGUE // uncomment this line if you want to use this plugin for Zombie Plague
//#define RANDOM_SPAWNS // uncomment this line if you want to use the random respawn mode

#if defined RANDOM_SPAWNS
#define MAX_SPAWNS 50 // maximum allowed random spawn points in a map
#define ADMIN_ADD_SPAWN ADMIN_RCON // access level for respawn_add_spawn command
#endif

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#if defined ZOMBIE_PLAGUE
#include <zombieplague>
#endif

#if defined RANDOM_SPAWNS
#include <amxmisc>
#include <fakemeta>

enum
{
	COORD_ORIGIN = 0,
	COORD_ANGLES,
	COORD_VANGLES,
	MAX_COORD
}
#endif

new on_res,res_protect,res_time,res_protect_time,res_money,res_armor_type,res_armor
#if defined RANDOM_SPAWNS
new spawn_file[75],total_spawns,Float:spawn_coord_data[MAX_COORD][MAX_SPAWNS + 1][3]
#endif
public plugin_init()
{
	register_plugin("Respawn by <VeCo>", "3.2", "<VeCo>")
	
	RegisterHam(Ham_Spawn,"player","player_spawn",1)
	
	register_cvar("respawn_version", "3.2", FCVAR_SERVER|FCVAR_SPONLY)
	on_res = register_cvar("respawn_on","1")
	res_time = register_cvar("respawn_time","3.0")
	res_protect = register_cvar("respawn_protect","1")
	res_protect_time = register_cvar("respawn_protect_time","4.0")
	res_money = register_cvar("respawn_bonus_money","400")
	res_armor_type = register_cvar("respawn_bonus_armor_type","0")
	res_armor = register_cvar("respawn_bonus_armor","100")
	RegisterHam(Ham_Killed,"player","hook_death",1)
	
	register_clcmd("say /respawn","force_respawn")
	register_clcmd("say_team /respawn","force_respawn")
	
#if defined RANDOM_SPAWNS
	register_concmd("respawn_add_spawn","admin_add_spawn",ADMIN_ADD_SPAWN)
	
	new mapname[32]
	get_mapname(mapname,31)
	formatex(spawn_file,74,"addons/amxmodx/configs/respawn_veco/%s.ini",mapname)
	
	if(!file_exists(spawn_file)) format(spawn_file,73,"addons/amxmodx/configs/csdm/%s.spawns.cfg",mapname)
	
	if(!file_exists(spawn_file))
	{
		log_amx("[RESPAWN] Spawn file doesn't exist! Standart spawn points will be used instead.")
		formatex(spawn_file,74,"addons/amxmodx/configs/respawn_veco/%s.ini",mapname)
	}
	
	load_random_spawns()
#endif
}

public client_putinserver(id)
{
	if(!get_pcvar_num(on_res)) return
	set_task(5.0,"respawn_check",id)
}

public hook_death(id)
{	
	if(!get_pcvar_num(on_res)) return
	
	set_task(get_pcvar_float(res_time),"respawn_event", id)
}

public respawn_event(id)
{
	if(is_user_alive(id) || !is_user_connected(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR || cs_get_user_team(id) == CS_TEAM_UNASSIGNED) return
	
	ExecuteHamB(Ham_CS_RoundRespawn,id)
	
#if defined RANDOM_SPAWNS
	if(total_spawns > 0)
	{
		static get_random_spawn
		get_random_spawn = random(total_spawns)
		
		spawn_coord_data[COORD_ORIGIN][get_random_spawn][2] += 20.0
		set_pev(id,pev_origin,spawn_coord_data[COORD_ORIGIN][get_random_spawn])
		spawn_coord_data[COORD_ORIGIN][get_random_spawn][2] -= 20.0
		
		set_pev(id,pev_angles,spawn_coord_data[COORD_ANGLES][get_random_spawn])
		set_pev(id,pev_v_angle,spawn_coord_data[COORD_VANGLES][get_random_spawn])
		
		if(is_player_stuck(id)) ExecuteHamB(Ham_CS_RoundRespawn,id)
	}
#endif
	
	cs_set_user_money(id, cs_get_user_money(id) + get_pcvar_num(res_money))
	if(get_pcvar_num(res_armor_type) > 0) cs_set_user_armor(id,get_pcvar_num(res_armor),CsArmorType:get_pcvar_num(res_armor_type))
}

public remove_res_protection(id)
{
	if(!is_user_connected(id) || !is_user_alive(id)) return
	
	client_print(id,print_center,"Your spawn protection is OFF!")
	set_user_rendering(id)
	set_user_godmode(id,0)
}

public player_spawn(id)
{
	if(!is_user_connected(id) || !is_user_alive(id) || get_pcvar_num(res_protect) == 0) return
	
	switch(get_pcvar_num(res_protect))
	{
		case 1:
		{
			switch(cs_get_user_team(id))
			{
				case CS_TEAM_CT: set_user_rendering(id, kRenderFxGlowShell, 0,0,255, kRenderNormal, 50)
				case CS_TEAM_T: set_user_rendering(id, kRenderFxGlowShell, 255,0,0, kRenderNormal, 50)
			}
		}
		case 2: set_user_rendering(id, kRenderFxGlowShell, random(255),random(255),random(255), kRenderNormal, 50)
		case 3: set_user_rendering(id, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, 80)
	}
	set_user_godmode(id,1)
	set_task(get_pcvar_float(res_protect_time),"remove_res_protection",id)
	
#if defined RANDOM_SPAWNS
	if(total_spawns > 0)
	{
		static get_random_spawn
		get_random_spawn = random(total_spawns)
		
		spawn_coord_data[COORD_ORIGIN][get_random_spawn][2] += 20.0
		set_pev(id,pev_origin,spawn_coord_data[COORD_ORIGIN][get_random_spawn])
		spawn_coord_data[COORD_ORIGIN][get_random_spawn][2] -= 20.0
		
		set_pev(id,pev_angles,spawn_coord_data[COORD_ANGLES][get_random_spawn])
		set_pev(id,pev_v_angle,spawn_coord_data[COORD_VANGLES][get_random_spawn])
		
		if(is_player_stuck(id)) ExecuteHamB(Ham_CS_RoundRespawn,id)
	}
#endif
}

public respawn_check(id)
{
	if(!is_user_connected(id)) return
	
#if defined ZOMBIE_PLAGUE
	if(!is_user_alive(id) && zp_get_user_zombie(id) || zp_get_user_survivor(id))
#else
	if(!is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T || cs_get_user_team(id) == CS_TEAM_CT)
#endif
	{
		set_task(get_pcvar_float(res_time),"respawn_event", id)
	} else {
		set_task(5.0,"respawn_check",id)
	}
}

public force_respawn(id)
{
	if(!get_pcvar_num(on_res) || is_user_alive(id)) return
	remove_task(id)
	respawn_event(id)
}

#if defined RANDOM_SPAWNS
public admin_add_spawn(id,level,cid)
{
	if(!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED
	
	if(total_spawns == MAX_SPAWNS)
	{
		console_print(id,"[RESPAWN] Spawn limit exceeded! Maximum amount of spawn points is: %i.",MAX_SPAWNS)
		return PLUGIN_HANDLED
	}
	
	static Float:origin[3],Float:angles[3],Float:vangles[3]
	pev(id,pev_origin,origin)
	pev(id,pev_angles,angles)
	pev(id,pev_v_angle,vangles)
	
	save_spawn(id,origin,angles,vangles)
	
	return PLUGIN_HANDLED
}

public save_spawn(id,Float:origin[3],Float:angles[3],Float:vangles[3])
{
	static save
	save = fopen(spawn_file,"at")
	if(save)
	{
		fprintf(save,"%.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f 0^n",origin[0],origin[1],origin[2], angles[0],angles[1],angles[2], vangles[0],vangles[1],vangles[2])
		fclose(save)
		
		console_print(id,"[RESPAWN] New random spawn point added at (%.0f , %.0f , %.0f) successfully!",origin[0],origin[1],origin[2])
		console_print(id,"[RESPAWN] Angles: (%.0f , %.0f , %.0f)",angles[0],angles[1],angles[2])
		console_print(id,"[RESPAWN] View Angles: (%.0f , %.0f , %.0f)",vangles[0],vangles[1],vangles[2])
		load_random_spawns()
	}
}

public load_random_spawns()
{
	total_spawns = 0
	
	static buffer[34], x[12],y[12],z[12], x_ang[12],y_ang[12],z_ang[12], x_vang[12],y_vang[12],z_vang[12]
	
	if(file_exists(spawn_file))
	{
		new save = fopen(spawn_file,"rt")
		
		if(!save) return
		
		while(!feof(save))
		{
			if(total_spawns == MAX_SPAWNS) break
			
			fgets(save,buffer,33)
			
			if(buffer[0] == ';' || !buffer[0]) continue
			
			parse(buffer, x,11,y,11,z,11, x_ang,11,y_ang,11,z_ang,11, x_vang,11,y_vang,11,z_vang,11)
			
			spawn_coord_data[COORD_ORIGIN][total_spawns][0] = str_to_float(x)
			spawn_coord_data[COORD_ORIGIN][total_spawns][1] = str_to_float(y)
			spawn_coord_data[COORD_ORIGIN][total_spawns][2] = str_to_float(z)
			
			spawn_coord_data[COORD_ANGLES][total_spawns][0] = str_to_float(x_ang)
			spawn_coord_data[COORD_ANGLES][total_spawns][1] = str_to_float(y_ang)
			spawn_coord_data[COORD_ANGLES][total_spawns][2] = str_to_float(z_ang)
			
			spawn_coord_data[COORD_VANGLES][total_spawns][0] = str_to_float(x_vang)
			spawn_coord_data[COORD_VANGLES][total_spawns][1] = str_to_float(y_vang)
			spawn_coord_data[COORD_VANGLES][total_spawns][2] = str_to_float(z_vang)
			
			total_spawns++
		}
		
		fclose(save)
	}
}

// Check if a player is stuck (credits to VEN)
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TraceResult:TR_StartSolid) || get_tr2(0, TraceResult:TR_AllSolid) || !get_tr2(0, TraceResult:TR_InOpen))
		return true;
	
	return false;
}
#endif

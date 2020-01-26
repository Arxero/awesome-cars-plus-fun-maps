#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Ultimate Revive"
#define VERSION "1.1"
#define AUTHOR "anakin_cstrike"

new g_fade;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd("amx_revive","revive_cmd",ADMIN_RCON,"- <player/@/@T/@CT> <hp> <armor>");
	g_fade = get_user_msgid("ScreenFade");
}
public revive_cmd(id,level,cid)
{
	if(!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED;
	new 
	arg[32],arg2[4],arg3[4],
	name[32],hp,armor;
	read_argv(1,arg,31);
	read_argv(2,arg2,3);
	read_argv(3,arg3,3);
	get_user_name(id,name,31);
	new argc = read_argc();
	if(argc < 2) {hp = 100;armor = 0;}
	else if(argc == 3) {hp = str_to_num(arg2);armor = 0;}
	else {hp = str_to_num(arg2);armor = str_to_num(arg3);}
	if(arg[0] == '@')
	{
		new players[32],teamname[24],tname[16],num,index,i;
		if(arg[1])
		{
			if(arg[1] == 'T')
			{
				copy(tname,15,"TERRORIST");
				copy(teamname,23,"Terrorist");
			} else if(arg[1] == 'C' && arg[2] == 'T') {
				copy(tname,15,"CT");
				copy(teamname,23,"Counter-Terrorist");
			} else {
				console_print(id,"Usage: @T/@CT");
				return PLUGIN_HANDLED;
			}
			get_players(players,num,"be",tname);
		} else {
			get_players(players,num);
			copy(teamname,23,"All");
		}
		if(num == 0)
		{
			console_print(id,"No players in team %s",teamname);
			return PLUGIN_HANDLED;
		}
		for(i = 0;i < num;i++)
		{
			index = players[i];
			if(is_user_alive(index)) continue;
			Revive(index,hp,armor);
		}
		log_amx("ADMIN %s: Revive %s with %i hp and %i armor",name,teamname,hp,armor);
	} else {
		new target = cmd_target(id,arg,3);
		if(!target)
		return PLUGIN_HANDLED;
		if(is_user_alive(target))
		{
			console_print(id,"Player is allready alive !");
			return PLUGIN_HANDLED;
		}
		new namet[32]; 
		get_user_name(target,namet,31);
		Revive(target,hp,armor);
		log_amx("ADMIN %s: Revive %s with %i hp and %i armor",name,namet,hp,armor);
	}
	return PLUGIN_HANDLED;
}
Revive(index,hp,armor)
{
	set_pev(index,pev_deadflag,DEAD_RESPAWNABLE);
	set_pev(index,pev_iuser1,0);
	dllfunc(DLLFunc_Think,index);
	engfunc(EngFunc_SetOrigin,index,Float:{-4800.0,-4800.0,-4800.0});
	new array[3];
	array[0] = index;
	array[1] = hp;
	array[2] = armor
	set_task(0.5,"respawn",0,array,3);
}
public respawn(array[3])
{
	new index = array[0];
	new hp = array[1];
	new armor = array[2];
	if(is_user_connected(index))
	{
		dllfunc(DLLFunc_Spawn,index);
		set_pev(index,pev_health,float(hp));
		set_pev(index,pev_armorvalue,float(armor));
		switch(get_user_team(index))
        	{
            		case 1:
            		{
                		fm_give_item(index,"weapon_knife");
                		fm_give_item(index,"weapon_glock18");
                		fm_give_item(index,"ammo_9mm");
                		fm_give_item(index,"ammo_9mm");
                		fm_give_item(index,"ammo_9mm");
                		fm_give_item(index,"ammo_9mm");
            		}
            		case 2:
            		{
               		 	fm_give_item(index,"weapon_knife");
                		fm_give_item(index,"weapon_usp");
                		fm_give_item(index,"ammo_45acp");
                		fm_give_item(index,"ammo_45acp");
                		fm_give_item(index,"ammo_45acp");
                		fm_give_item(index,"ammo_45acp");
            		}
        	}
		Fade(index,0,255,0,30);
	}
}
stock fm_give_item(id,const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if(!pev_valid(ent)) return;
   
	static Float:originF[3]
	pev(id, pev_origin, originF);
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
   
	static save
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	if(pev(ent,pev_solid) != save)
		return;
      
	engfunc(EngFunc_RemoveEntity, ent);
}
stock Fade(index,red,green,blue,alpha)
{
	message_begin(MSG_ONE,g_fade,{0,0,0},index);
	write_short(1<<10);
	write_short(1<<10);
	write_short(1<<12);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}
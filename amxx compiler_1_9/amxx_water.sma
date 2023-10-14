/***************************************************************************
 *   amxx_water.sma            Version 1.0 Release          Date: Thur/09/2004
 *
 *   [AMXx] Who's in the water?
 *
 *   By:    Freecode [yes im back]

 * *******************************************************************************
 *
 *   Developed using:  AMXx 0.20
 *   Tested On:        CS 1.6 (STEAM)
 *
 * *******************************************************************************
 *
 *	Commands & Cvars:
 *  	amxx_water : 1 / 0
 *				- 1 = ON
 *				- 0 = OFF
 *
 *   	water_check_time ( 30.0 Default) 
 *				- Time how often to check and choose person in water.
 *
 * *******************************************************************************
 *
 * Changelog :
 *
 *	1.0 Initial Release
 *
 ********************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>

#define	FL_INWATER		(1<<4)

new bool:running = false;
new bool:inWater[32] = false;

new messages[5][] = {
	"We all like water but %s abuses it.",
	"Everyone go to the water, %s is waiting for you there.",
	"Dont want to give any locations out but %s is by the water :).",
	"Who knew %s liked water?",
	"%s says: Im in the water!!!"
}

public plugin_init()
{
	register_plugin("Who's in the water?","1.0","Freecode");
	register_clcmd("amxx_water","water",ADMIN_LEVEL_A,": 1 / 0");
	register_cvar("water_check_time","30.0");
}

public water(id)
{
	new arg[32];
	read_argv(1, arg, 31);
	
	new input = str_to_num(arg);
	
	switch (input)
	{
		case 0:
		{
			if(running)
			{
				remove_task(1,0)
				console_print(id,"[AMXx] Who's in the Water Plugin has been disabled.");
				set_hudmessage(100,100,100,-1.0,0.35,1,6.0,6.0,0.0,0.0,2)
				show_hudmessage(0,"Water is harmless.");
				running = false;
			}
			else
			{
				console_print(id,"[AMXx] Who's in the Water Plugin is already disabled");
			}
		}
		case 1:
		{
			if(running)
			{
				console_print(id,"[AMXx] Who's in the Water Plugin is already enabled");
			}
			else
			{
				set_task(get_cvar_float("water_check_time"),"check_water",1,"",0,"b");
				console_print(id,"[AMXx] Who's in the Water Plugin has been enabled.");
				set_hudmessage(100,100,100,-1.0,0.35,1,6.0,8.0,0.0,0.0,2)
				show_hudmessage(0,"Beware of the water.");
				running = true;
			}
		}
	}
	return PLUGIN_HANDLED
}

public check_water()
{
	new bool: found = false;
	new players[32], inum, i
	get_players(players,inum);
	for(i = 0; i < inum; i++)
	{
		new flags = entity_get_int(players[i],EV_INT_flags);
		if(flags & FL_INWATER)
		{
			inWater[players[i]] = true;
			found = true;
			
		}
	}
	
	if(found)
	{
		while(found)
		{
			new num = random_num(1 , inum);
			if(is_user_alive(num) && inWater[num])
			{
				new name[32];
				get_user_name(num,name,31);
				set_hudmessage(random_num(0,255),random_num(0,255),random_num(0,255),-1.0,0.35,random_num(1,4),6.0,6.0,0.0,0.0,2)
				show_hudmessage(0,messages[random_num(0,4)],name);
				found = false
			}
		}
	}
	
	for(i = 0; i < inum; i++)
	{
		inWater[players[i]] = false;
	}
	
	return PLUGIN_HANDLED
}
				 

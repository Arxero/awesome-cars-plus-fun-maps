// AMX client exec v0.3
// By v3x
// If you wish to use any of my code below, please credit me for it! Thanks.

#include <amxmodx>
#include <amxmisc>

// amx_show_activity <2|1|0>
// Look in amxx.cfg for more details

public plugin_init() {

	register_plugin("AMX Client Exec","0.03","v3x")
	register_clcmd("amx_exec","doExec",ADMIN_RCON,"<nick,@TEAM,*(all),@SERVER>")
	register_srvcmd("amx_exec","doExec")
}

new bool:isAll
new bool:isTeam
new bool:isServ
// For messages

public doExec(id,level,cid) 
{

	if(!cmd_access(id,level,cid,3)) 
	{
		return PLUGIN_HANDLED
	}

	new arg[32]
	new command[64]
	new players[32]
	new player,num,i

	read_argv(1,arg,31)
	read_argv(2,command,63)

	remove_quotes(command)
	
	while(replace(command,63,"\'","^"")) { } // Credited to OLO

	new activity = get_cvar_num("amx_show_activity")

	new admin[32]
	get_user_name(id,admin,31)

	if(arg[0]=='@') {

		if(equali(arg[1],"A") 
		|| equali(arg[1],"ALL")) 
		{
			isAll = true
			isTeam = false
			isServ = false
			get_players(players,num,"c")
		}
		
		if(equali(arg[1],"TERRORIST") 
		|| equali(arg[1],"T") 
		|| equali(arg[1],"TERROR") 
		|| equali(arg[1],"TE") 
		|| equali(arg[1],"TER")) 
		{
			isAll = false
			isTeam = true
			isServ = false
			get_players(players,num,"ce","TERRORIST")
		}
		
		if(equali(arg[1],"CT")
		|| equali(arg[1],"C") 
		|| equali(arg[1],"COUNTER")) 
		{
			isAll = false
			isTeam = true
			isServ = false
			get_players(players,num,"ce","CT")
		}
		
		if(equali(arg[1],"S") 
		|| equali(arg[1],"SERV") 
		|| equali(arg[1],"SERVER")) 
		{
			isAll = false
			isTeam = false
			isServ = true
			server_cmd(command)
		}
		
		if(!(num) && !(isServ)) 
		{
			console_print(id,"[AMXX] No players on such team!")
			return PLUGIN_HANDLED
		}

		if(!isServ) 
		{
			
			for(i=0;i<num;i++) 
			{

				player = players[i]

				if(!is_user_connected(player)) continue
				
				else if(player) 
				{

					if(!(get_user_flags(player) & ADMIN_IMMUNITY)) 
					{
						client_cmd(player,command)
					}
				}
			}
		}

		if(isAll==true) 
		{

			switch(activity) 
			{

				case 1: 
				{
					client_print(0,print_chat,"ADMIN: Command line ^"%s^" has been used on everyone",command)
					server_print("ADMIN: Command line ^"%s^" has been used on everyone",command)
				}
				case 2: 
				{
					client_print(0,print_chat,"ADMIN %s: Command line ^"%s^" has been used on everyone",admin,command)
					server_print("ADMIN %s: Command line ^"%s^" has been used on everyone",admin,command)
				}
			}
		}

		if(isTeam==true) 
		{

			switch(activity) 
			{

				case 1: 
				{
					client_print(0,print_chat,"ADMIN: Command line ^"%s^" has been used on the %ss",command,arg[1])
					server_print("ADMIN: Command line ^"%s^" has been used on the %ss",command,arg[1])
				}
				case 2: 
				{
					client_print(0,print_chat,"ADMIN %s: Command line ^"%s^" has been used on the %ss",admin,command,arg[1])
					server_print("ADMIN %s: Command line ^"%s^" has been used on the %ss",admin,command,arg[1])
				}
			}
		}

		if(isServ==true) 
		{

			switch(activity) 
			{

				case 1: 
				{
					client_print(0,print_chat,"ADMIN: Command line ^"%s^" has been exectuted into the server",command)
					server_print("ADMIN: Command line ^"%s^" has been exectuted into the server",command)
				}
				case 2: 
				{
					client_print(0,print_chat,"ADMIN %s: Command line ^"%s^" has been exectuted into the server",admin,command)
					server_print("ADMIN %s: Command line ^"%s^" has been exectuted into the server",admin,command)
				}
			}
		}
	}

	else if(arg[0]=='*') 
	{

		get_players(players,num,"c")

		for(i=0;i<num;i++) 
		{

			player = players[i]

			if(!is_user_connected(player)) continue

			else if(player) 
			{

				if(!(get_user_flags(player) & ADMIN_IMMUNITY)) 
				{
					client_cmd(player,command)
				}
			}
		}
		

		
		switch(activity) 
		{

			case 1: 
			{
				client_print(0,print_chat,"ADMIN: Command line ^"%s^" has been used on everyone!",command)
				server_print("ADMIN: Command line ^"%s^" has been used on everyone!",command)
			}
			case 2: 
			{
				client_print(0,print_chat,"ADMIN %s: Command line ^"%s^" has been used on everyone!",admin,command)
				server_print("ADMIN %s: Command line ^"%s^" has been used on everyone!",admin,command)
			}
		}
	}

	else 
	{
		new target = cmd_target(id,arg,3)
		new name[33]

		if(!is_user_connected(target)) 
		{
			return PLUGIN_HANDLED
		}

		get_user_name(target,name,32)

		if(!(get_user_flags(target) & ADMIN_IMMUNITY)) 
		{
			client_cmd(target,command)
		}

		switch(activity) 
		{
			case 1: 
			{
				client_print(0,print_chat,"ADMIN: Command line ^"%s^" has been used on %s!",command,name)
				server_print("ADMIN: Command line ^"%s^" has been used on %s!",command,name)
			}
			case 2: 
			{
				client_print(0,print_chat,"ADMIN %s: Command line ^"%s^" has been used on %s!",admin,command,name)
				server_print("ADMIN %s: Command line ^"%s^" has been used on %s!",admin,command,name)
			}
		}
	}

	return PLUGIN_HANDLED
}
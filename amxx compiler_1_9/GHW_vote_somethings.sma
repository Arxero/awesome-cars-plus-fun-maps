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
*  Last Edited: 12-31-07
*
*  ============
*   Changelog:
*  ============
*
*  v2.0
*    -Added ML
*
*  v1.0
*    -Initial Release
*
*/

#define VERSION	"2.0"

#include <amxmodx>
#include <amxmisc>

new bool:voting=false
new votething[200]
new bool:allowedtovoteagain=true
new yes
new no
new menusid
new configfile[200]

new pdelay, plasts, ptoggle, padvertise;

new const clientCommands[][] =
{
	"amx_chicken *",
	"amx_unchicken *",

};

public plugin_init()
{
	register_plugin("Client Vote Anything",VERSION,"GHW_Chronic")
	register_clcmd("say","hook_say")
	register_clcmd("say_team","hook_say")

	register_menucmd(register_menuid("votean"),(1<<0)|(1<<1)|(1<<9),"Pressedvote")

	pdelay = register_cvar("Vote_Delay","60.0")
	plasts = register_cvar("Vote_Lasts","30.0")
	ptoggle = register_cvar("Vote_Toggle","1")
	padvertise = register_cvar("Vote_Advertise","500.0")

	get_configsdir(configfile,199)
	format(configfile,199,"%s/GHW_vote.ini",configfile)

	set_task(get_pcvar_float(padvertise),"advertise",0,"",0,"b")

	register_dictionary("GHW_vote.txt")
}

public hook_say(id)
{
	new text[200]
	new text2[200]
	read_args(text,199)
	read_args(text2,199)
	remove_quotes(text)
	trim(text)
	if(equal(text,"/vote"))
	{
		new MOTD[1024]
		new read[32], trash
		if(file_exists(configfile))
		{
			for(new i=0;i<file_size(configfile);i++)
			{
				read_file(configfile,i,read,31,trash)
				format(MOTD,199,"%s<BR>%s",MOTD,read)
			}
		}
		show_motd(id,MOTD,"Vote Items")
	}
	else if(contain(text,"/vote ")==0)
	{
		if(!get_pcvar_num(ptoggle))
		{
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_DISABLED")
		}
		else if(voting)
		{
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_VOTING")
		}
		else if(!allowedtovoteagain)
		{
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_SOON")
		}
		else if(containi(text2,";")!=-1)
		{
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_SEMICOLONS")
		}
		else
		{
			if(file_exists(configfile))
			{
				replace(text2,199,"/vote ","")
				remove_quotes(text2)
				for(new i=0;i<file_size(configfile,1);i++)
				{
					new read[100]
					new trash
					read_file(configfile,i,read,99,trash) 
					if(containi(text2,read)==0)
					{
						yes=0
						no=0
						allowedtovoteagain=false
						set_task(get_pcvar_float(pdelay),"allowedtovoteagaintrue")
						voting=true
						remove_quotes(text2)
						format(votething,199,"%s",text2)
						set_task(1.0,"showtext",id)
						showvotean()
						return PLUGIN_HANDLED
					}
				}
			}
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_INVALID1",text2)
			client_print(id,print_chat,"[AMXX] %L",id,"MSG_VOTE_AS_INVALID2")
		}
	}
	return PLUGIN_CONTINUE
}

public showtext(id)
{
	new name[32]
	get_user_name(id,name,31)
	client_print(0,print_chat,"[AMXX] ",0,"MSG_VOTE_AS_STARTED",name)
	set_task(get_pcvar_float(plasts),"tally")
}

public showvotean()
{
	new menuBody[576]
	new len = format(menuBody,575,"%L^n^n",0,"MSG_VOTE_AS_EXECUTE_Q",votething)
	len += format(menuBody[len],575-len, "1. %L^n",0,"MSG_VOTE_AS_YES")
	len += format(menuBody[len],575-len, "2. %L^n^n",0,"MSG_VOTE_AS_NO")
	len += format(menuBody[len],575-len, "0. %L",0,"MSG_VOTE_AS_MAYBE")
	show_menu(0,(1<<0)|(1<<1)|(1<<9),menuBody,-1,"votean")
}

public Pressedvote(id,key)
{
	new name[32]
	get_user_name(id,name,31)
	switch(key) 
	{
		case 0:
		{
			yes++
			client_print(0,print_chat,"[AMXX] %s: [ %L ]",name,0,"MSG_VOTE_AS_YES")
		}
		case 1:
		{
			no++
			client_print(0,print_chat,"[AMXX] %s: [ %L ]",name,0,"MSG_VOTE_AS_NO")
		}
		case 9:
		{
			client_print(0,print_chat,"[AMXX] %s: [ %L ]",name,0,"MSG_VOTE_AS_MAYBE")
		}
	}
	return PLUGIN_HANDLED
}

public allowedtovoteagaintrue()
{
	allowedtovoteagain=true
	return PLUGIN_HANDLED
}

public tally()
{
	voting=false
	for(new i=0;i<=32;i++)
	{
		if(is_user_connected(i))
		{
			new id
			new keys
			get_user_menu(i,id,keys)
			if(id==menusid)
			{
				client_cmd(i,"slot0")
			}
		}
	}
	client_print(0,print_chat,"[AMXX] %s:  %L: %d  %L: %d",votething,0,"MSG_VOTE_AS_YES",yes,0,"MSG_VOTE_AS_NO",no)
	if(yes>no)
	{
		client_print(0,print_chat,"[AMXX] %L",0,"MSG_VOTE_AS_EXECUTE",votething)
		if (isClientCommand(votething)) {
			client_cmd(0, votething);

			return PLUGIN_HANDLED;
		}

		server_cmd(votething)
	}
	else
	{
		client_print(0,print_chat,"[AMXX] %L",0,"MSG_VOTE_AS_NO_EXECUTE",votething)
	}
	return PLUGIN_HANDLED
}

public advertise()
{
	client_print(0,print_chat,"[AMXX] %L",0,"MSG_VOTE_AS_ADVERTISE")
}

public isClientCommand(command[200]) {
	new bool:isClientCommand = false;

	for(new i = 0; i < sizeof(clientCommands); i++) {
		if(equali(command, clientCommands[i])) {
			isClientCommand = true;
			break;
		}
	}

	return isClientCommand;
}

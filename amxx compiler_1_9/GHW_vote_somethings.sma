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
#include <colorchat>

new bool:voting=false
new votething[200]
new bool:allowedtovoteagain=true
new yes
new no
new voteEligiblePlayers
new currentVoteMenu
new configfile[200]

new pdelay, plasts, ptoggle, padvertise;

new const tag[] = "[^1AMXX^4]^1"
new const soundStartVote[] = "buttons/bell1.wav"
new const soundVoteSuccess[] = "sank_sounds/woo.wav"
new const soundVoteFail[] = "buttons/button10.wav"

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

	pdelay = register_cvar("Vote_Delay","60.0")
	plasts = register_cvar("Vote_Lasts","30.0")
	ptoggle = register_cvar("Vote_Toggle","1")
	padvertise = register_cvar("Vote_Advertise","500.0")

	get_configsdir(configfile,199)
	format(configfile,199,"%s/GHW_vote.ini",configfile)

	set_task(get_pcvar_float(padvertise),"advertise",0,"",0,"b")

	register_dictionary("GHW_vote.txt")
}

public plugin_precache()
{
	precache_sound(soundStartVote)
	precache_sound(soundVoteSuccess)
	precache_sound(soundVoteFail)
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
		new MOTD[1536]
		new read[128], trash
		new motdLen = 0
		if(file_exists(configfile))
		{
			for(new i=0;i<file_size(configfile, 1);i++)
			{
				read_file(configfile, i, read, charsmax(read), trash)
				trim(read)
				if(!read[0] || read[0] == ';')
				{
					continue
				}

				motdLen += formatex(MOTD[motdLen], charsmax(MOTD) - motdLen, "%s<BR>", read)
				if(motdLen >= charsmax(MOTD) - 1)
				{
					break
				}
			}
		}
		show_motd(id,MOTD,"Vote Items")
	}
	else if(contain(text,"/vote ")==0)
	{
		if(!get_pcvar_num(ptoggle))
		{
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_DISABLED")
		}
		else if(voting)
		{
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_VOTING")
		}
		else if(!allowedtovoteagain)
		{
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_SOON")
		}
		else if(containi(text2,";")!=-1)
		{
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_SEMICOLONS")
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
						voteEligiblePlayers = get_human_players_num()
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
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_INVALID1", text2)
			ColorChat(id, GREEN, "%s %L", tag, id, "MSG_VOTE_AS_INVALID2")
		}
	}
	return PLUGIN_CONTINUE
}

public showtext(id)
{
	new name[32]
	get_user_name(id,name,31)
	client_cmd(0, "speak ^"sound/%s^"", soundStartVote)
	ColorChat(0, GREEN, "%s %L", tag, 0, "MSG_VOTE_AS_STARTED", name)
	set_task(get_pcvar_float(plasts),"tally")
}

public showvotean()
{
	new menuTitle[256]
	formatex(menuTitle, charsmax(menuTitle), "%L", 0, "MSG_VOTE_AS_EXECUTE_Q", votething)

	currentVoteMenu = menu_create(menuTitle, "Pressedvote")
	menu_additem(currentVoteMenu, "Yes", "1", 0)
	menu_additem(currentVoteMenu, "No", "2", 0)

	new players[32], pnum, id
	get_players(players, pnum)

	for(new i = 0; i < pnum; i++)
	{
		id = players[i]
		menu_display(id, currentVoteMenu, 0)
	}
}

public Pressedvote(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		return PLUGIN_HANDLED
	}

	new data[6], itemName[64], access, callback
	menu_item_getinfo(menu, item, access, data, charsmax(data), itemName, charsmax(itemName), callback)

	switch(str_to_num(data))
	{
		case 1:
		{
			yes++
		}
		case 2:
		{
			no++
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
	new neededYesVotes = (voteEligiblePlayers / 2) + 1
	new didNotVote = voteEligiblePlayers - yes - no
	if(didNotVote < 0)
	{
		didNotVote = 0
	}

	voting=false
	show_menu(0, 0, "^n", 1)
	if(currentVoteMenu)
	{
		menu_destroy(currentVoteMenu)
		currentVoteMenu = 0
	}

	ColorChat(0, GREEN, "%s Results from the vote: ^4%d - Yes ^1vs ^4%d - No ^1vs ^4%d - Did not vote", tag, yes, no, didNotVote)
	if(yes > (voteEligiblePlayers / 2))
	{
		client_cmd(0, "speak ^"sound/%s^"", soundVoteSuccess)
		ColorChat(0, GREEN, "%s %L", tag, 0, "MSG_VOTE_AS_EXECUTE", votething)
		if (isClientCommand(votething)) {
			client_cmd(0, votething);

			return PLUGIN_HANDLED;
		}

		server_cmd(votething)
	}
	else
	{
		client_cmd(0, "speak ^"sound/%s^"", soundVoteFail)
		ColorChat(0, GREEN, "%s Not enough ^4Yes ^1votes were cast for the vote to succeed. Needed: ^4%d ^1Yes vote(s)", tag, neededYesVotes)
	}
	return PLUGIN_HANDLED
}

public advertise()
{
	ColorChat(0, GREEN, "%s %L", tag, 0, "MSG_VOTE_AS_ADVERTISE")
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

public get_human_players_num()
{
	new players[32], pnum
	get_players(players, pnum, "ch")

	return pnum
}

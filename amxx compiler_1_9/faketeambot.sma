// Never do you have to deal with round ending again!
#include <amxmodx>
#include <fakemeta>
#include <cstrike>

new botteam[3]

static const botnames[3][] = {
	"NULL", 
	"TERRORIST TEAM", 			//Change Terrorist Bot Name
	"COUNTER-TERRORIST TEAM"	//Change CT Bot name
}

public plugin_init() {
	register_plugin("Fake TeamBot", "1.3", "OneEyed")
	register_event("HLTV","StartRound","a","1=0","2=0")
}

public plugin_cfg() {
	
	if(get_cvar_num("soccer_jam_online"))
		createBots()
	else
		kickBots()	
}

public StartRound() {
	set_task(0.5, "PostStartRound", 0)
}

public PostStartRound() {
	new x, bot
	for(x=1; x<3; x++) {
		bot = botteam[x];
		if(is_user_bot(bot)) {
			set_pev(bot, pev_effects, (pev(bot, pev_effects) | 128) ) //set invisible
			set_pev(bot, pev_solid, 0) 		//Not Solid
		}
	}
}
	
createBots()
{
	new bot, x, ptr[128]
	for(x = 1; x<3; x++) 
	{
		//is bot in server already?
		bot = find_player("bli", botnames[x] )
		if(bot) {
			botteam[x] = bot
			continue
		}
		
		//bot not in server, create them.
		bot = engfunc(EngFunc_CreateFakeClient, botnames[x])
		botteam[x] = bot
		
		dllfunc(DLLFunc_ClientConnect, bot, botnames[x], "127.0.0.1", ptr )
		dllfunc(DLLFunc_ClientPutInServer, bot)
		select_model(bot, x)
	}
}

kickBots()
{
	new bot, x
	for(x = 1; x<3; x++) 
	{
		//is bot in server?
		bot = find_player("bli", botnames[x] )
		if(bot) {
			server_cmd("kick #%d", get_user_userid(bot))
			continue
		}
	}
}

select_model(id,team)
	switch(team) {
		case 1: cs_set_user_team(id, CS_TEAM_T, CS_T_TERROR)
		case 2: cs_set_user_team(id, CS_TEAM_CT, CS_CT_URBAN)
	}

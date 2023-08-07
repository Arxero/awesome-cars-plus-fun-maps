#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <fakemeta>
#include <formatin>

#define PLUGIN_VERSION "2.1"

new const g_szMute[] = "buttons/blip1.wav"
new const g_szUnmute[] = "buttons/button9.wav"

enum _:Cvars
{
	advmute_adminflag,
	advmute_mutechat,
	advmute_mutemic,
	advmute_reopen,
	advmute_sounds
}

new g_eCvars[Cvars], bool:g_bMuted[33][33], g_iFlag

new const g_szMenuCommands[][] = 
{
	"amx_mutemenu",
	"amx_chatmutemenu",
	"say /mute",
	"say_team /mute",
	"say /mutemenu",
	"say_team /mutemenu",
	"say /chatmute",
	"say_team /chatmute",
	"say /chatmutemenu",
	"say_team /chatmutemenu"
}

public plugin_init()
{
	register_plugin("Advanced Mute", PLUGIN_VERSION, "OciXCrom")
	register_cvar("AdvancedMute", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_dictionary("AdvancedMute.txt")
	register_message(get_user_msgid("SayText"), "OnPlayerMessage")
	register_forward(FM_Voice_SetClientListening, "OnPlayerTalk")
	
	register_clcmd("amx_mute", "Cmd_Mute", ADMIN_ALL, "<nick|#userid>")
	register_clcmd("amx_chatmute", "Cmd_Mute", ADMIN_ALL, "<nick|#userid>")
	
	for(new i; i < sizeof(g_szMenuCommands); i++)
		register_clcmd(g_szMenuCommands[i], "MuteMenu")
	
	g_eCvars[advmute_adminflag] = register_cvar("advmute_adminflag", "a")
	g_eCvars[advmute_mutechat] = register_cvar("advmute_mutechat", "1")
	g_eCvars[advmute_mutemic] = register_cvar("advmute_mutemic", "1")
	g_eCvars[advmute_reopen] = register_cvar("advmute_reopen", "1")
	g_eCvars[advmute_sounds] = register_cvar("advmute_sounds", "1")
	
	CC_SetPrefix("&x04[&x03Advanced Mute&x04]")
}

public plugin_precache()
{
	precache_sound(g_szMute)
	precache_sound(g_szUnmute)
}

public plugin_cfg()
{
	new szFlag[2]
	get_pcvar_string(g_eCvars[advmute_adminflag], szFlag, charsmax(szFlag))
	g_iFlag = read_flags(szFlag)
}

public OnPlayerMessage(iMsgid, iDest, iReceiver)
{
	if(!get_pcvar_num(g_eCvars[advmute_mutechat]))
		return PLUGIN_CONTINUE
		
	static iSender
	iSender = get_msg_arg_int(1)	
	return get_mute(iReceiver, iSender) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}

public OnPlayerTalk(iReceiver, iSender, iListen)
{
	if(!get_pcvar_num(g_eCvars[advmute_mutemic]) || iReceiver == iSender)
		return FMRES_IGNORED
		
	if(get_mute(iReceiver, iSender))
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, 0)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public Cmd_Mute(id)
{
	new szArg[32]
	read_argv(1, szArg, charsmax(szArg))
	
	new iPlayer = cmd_target(id, szArg, 0)
	
	if(!iPlayer)
		return PLUGIN_HANDLED
	
	if(get_user_flags(iPlayer) & g_iFlag)
	{
		CC_SendMessage(id, "%L", id, "ADVMUTE_CANT_MUTE")
		user_spksound(id, g_szUnmute)
		return PLUGIN_HANDLED
	}
	
	switch_mute(id, iPlayer)
	display_mute_message(id, iPlayer)
	return PLUGIN_HANDLED
}

public MuteMenu(id)
{
	new iMenu = menu_create(formatin("%L", id, "ADVMUTE_MENU_HEADER"), "MuteMenu_Handler")
	menu_additem(iMenu, formatin("%L", id, "ADVMUTE_MUTE_ALL"))
	menu_additem(iMenu, formatin("%L", id, "ADVMUTE_UNMUTE_ALL"))
	
	new iPlayers[32], iPnum
	get_players(iPlayers, iPnum)
	
	for(new szItem[40], szName[32], szUserId[16], iPlayer, i; i < iPnum; i++)
	{
		iPlayer = iPlayers[i]
		
		if(get_user_flags(iPlayer) & g_iFlag)
			continue
			
		get_user_name(iPlayer, szName, charsmax(szName))
		formatex(szUserId, charsmax(szUserId), "%i", get_user_userid(iPlayer))
		formatex(szItem, charsmax(szItem), "%s%s", get_mute(id, iPlayer) ? "\r" : "", szName)
		menu_additem(iMenu, szItem, szUserId)
	}
	
	menu_setprop(iMenu, MPROP_BACKNAME, formatin("%L", id, "ADVMUTE_PREVIOUS_PAGE"))
	menu_setprop(iMenu, MPROP_NEXTNAME, formatin("%L", id, "ADVMUTE_NEXT_PAGE"))
	menu_setprop(iMenu, MPROP_EXITNAME, formatin("%L", id, "ADVMUTE_EXIT"))
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public MuteMenu_Handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	
	new szData[16], iUnused
	menu_item_getinfo(iMenu, iItem, iUnused, szData, charsmax(szData), .callback = iUnused)
	
	new iUserId = str_to_num(szData)
	
	if(0 <= iItem <= 1)
	{
		new iPlayers[32], iPnum, bool:bMute = iItem == 0
		get_players(iPlayers, iPnum)
		
		for(new i, iPlayer; i < iPnum; i++)
		{
			iPlayer = iPlayers[i]
			
			if(get_user_flags(iPlayer) & g_iFlag)
				continue
				
			set_mute(id, iPlayer, bMute)
		}
		
		CC_SendMessage(id, "%L", id, bMute ? "ADVMUTE_MUTED_ALL" : "ADVMUTE_UNMUTED_ALL")
		
		if(get_pcvar_num(g_eCvars[advmute_sounds]))
			user_spksound(id, bMute ? g_szMute : g_szUnmute)
	}
	else
	{
		new iPlayer = find_player("k", iUserId)
		
		if(iPlayer)
		{
			switch_mute(id, iPlayer)
			display_mute_message(id, iPlayer)
		}
	}
	
	menu_destroy(iMenu)
	
	if(get_pcvar_num(g_eCvars[advmute_reopen]))
		MuteMenu(id)
	
	return PLUGIN_HANDLED
}

display_mute_message(const id, const iPlayer)
{
	new szName[32], bool:bMute = get_mute(id, iPlayer)
	get_user_name(iPlayer, szName, charsmax(szName))
	CC_SendMessage(id, "%L", id, bMute ? "ADVMUTE_MUTED_PLAYER" : "ADVMUTE_UNMUTED_PLAYER", szName)
	
	if(get_pcvar_num(g_eCvars[advmute_sounds]) == 1)
		user_spksound(id, bMute ? g_szMute : g_szUnmute)
}

set_mute(const id, const iPlayer, const bool:bMute)
	g_bMuted[id][iPlayer] = bMute ? true : false

bool:get_mute(const id, const iPlayer)
	return bool:g_bMuted[id][iPlayer]

switch_mute(const id, const iPlayer)
	set_mute(id, iPlayer, get_mute(id, iPlayer) ? false : true)

user_spksound(const id, const szSound[])
	client_cmd(id, "spk %s", szSound)

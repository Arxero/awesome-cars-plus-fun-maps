/* -----------------------------------------------------------------------------
Death Note @ AlliedMods.net: https://forums.alliedmods.net/showthread.php?t=281429

Cvars:
    dn_type <default: "3"> -- Type (1 = chat; 2 = HUD; 3 = DHUD).
    dn_hud_red <default: "0"> -- RGB for the note (if dn_type > 1): red color.
    dn_hud_green <default: "255"> -- RGB for the note (if dn_type > 1): green color.
    dn_hud_blue <default: "0"> -- RGB for the note (if dn_type > 1): blue color.
    dn_hud_xpos <default: "-1.0"> -- X position for the note (if dn_type > 1).
    dn_hud_ypos <default: "0.80"> -- Y position for the note (if dn_type > 1).
    dn_hud_time <default: "-1.0"> -- How long before the note disappears (if dn_type > 1).

Commands:
    /note set <note> -- Sets your death note. You can use <name> to use your current name in the note. Example: /note set Pwned by <name>!
    /note remove -- Removes your death note.
    /note current -- Shows your current death note.
    /note load -- Reloads the plugin's cvars (admins only).
    /note delete <player> -- Removes player's death note (admins only).
    /note player <player> -- Shows the player's current death note (admins only).
	/note help -- List of basic commands.

Tips:
	You can use /dn instead of /note.
	You can use only the first letter of the command instead of the whole word (set => s; remove => r; delete => d etc).
	Example: /dn s hello	
----------------------------------------------------------------------------- */

#include <amxmodx>
#include <amxmisc>
#include <nvault>

#if AMXX_VERSION_NUM < 183
	#include <dhudmessage>
#endif

#define PLUGIN_VERSION "1.2"
#define FLAG_ADMIN ADMIN_BAN

new g_iVault, g_cvType, g_cvRed, g_cvGreen, g_cvBlue, g_cvXPos, g_cvYPos, g_cvTime
new g_iType, g_iRed, g_iGreen, g_iBlue
new g_msgSayText, g_msgTeamInfo, g_iMaxPlayers
new Float:g_flXPos, Float:g_flYPos, Float:g_flTime
new g_szNote[33][128]
new const g_szPrefix[] = "^1[^3DeathNote^1]"
new const g_szError[] = "^3[ERROR]^1"

enum Color
{
	NORMAL = 1, // clients scr_concolor cvar color
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

public plugin_init()
{
	register_plugin("Death Note", PLUGIN_VERSION, "OciXCrom")
	register_cvar("DeathNote", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_dictionary("DeathNote.txt")
	register_event("DeathMsg", "eventPlayerKilled", "a")
	register_clcmd("say", "cmdSay")
	register_clcmd("say_team", "cmdSay")
	g_msgSayText = get_user_msgid("SayText")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_iMaxPlayers = get_maxplayers()
	g_cvType = register_cvar("dn_type", "3")
	g_cvRed = register_cvar("dn_hud_red", "0")
	g_cvGreen = register_cvar("dn_hud_green", "255")
	g_cvBlue = register_cvar("dn_hud_blue", "0")
	g_cvXPos = register_cvar("dn_hud_xpos", "-1.0")
	g_cvYPos = register_cvar("dn_hud_ypos", "0.80")
	g_cvTime = register_cvar("dn_hud_time", "5.0")
	g_iVault = nvault_open("DeathNote")
	readCvars()
}

readCvars()
{
	g_iType = get_pcvar_num(g_cvType)
	g_iRed = get_pcvar_num(g_cvRed)
	g_iGreen = get_pcvar_num(g_cvGreen)
	g_iBlue = get_pcvar_num(g_cvBlue)
	g_flXPos = get_pcvar_float(g_cvXPos)
	g_flYPos = get_pcvar_float(g_cvYPos)
	g_flTime = get_pcvar_float(g_cvTime)
}

public client_putinserver(id)
{
	if(!is_user_bot(id))
		LoadData(id)
}

public client_disconnect(id)
{
	if(!is_user_bot(id))
		SaveData(id)
}
	
SaveData(id)
{
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	nvault_set(g_iVault, szName, g_szNote[id])
}

LoadData(id)
{
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	nvault_get(g_iVault, szName, g_szNote[id], charsmax(g_szNote[]))
}

public plugin_end()
	nvault_close(g_iVault)

public cmdSay(id)
{
	new szSay[128], szCmd[6], szArg[6], szNote[96]
	read_args(szSay, charsmax(szSay))
	remove_quotes(szSay)
	
	if(szSay[0] != '/')
		return PLUGIN_CONTINUE
	
	parse(szSay, szCmd, charsmax(szCmd), szArg, charsmax(szArg), szNote, charsmax(szNote))
	
	if(!equal(szCmd, "/note") && !equal(szCmd, "/dn"))
		return PLUGIN_CONTINUE
		
	switch(szArg[0])
	{
		case 'h': 	// help
		{
			ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "HELP_LINE_1")
			ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "HELP_LINE_2")
			ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "HELP_LINE_3")
		}
		case 's': 	// set
		{
			if(is_blank(szNote))
			{
				ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_SET_ERR")
				return PLUGIN_HANDLED
			}
			
			replace(szSay, charsmax(szSay), szCmd, "")
			replace(szSay, charsmax(szSay), szArg, "")
			trim(szSay)				
			copy(g_szNote[id], charsmax(g_szNote[]), szSay)
			ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_SET", szSay)
		}
		case 'r':	// remove
		{
			if(is_blank(g_szNote[id])) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_REMOVE_ERR")
			else
			{
				clearNote(id)
				ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_REMOVE")
			}
		}
		case 'c': 	// current
		{
			if(is_blank(g_szNote[id])) ColorChat(id, BLUE, "%s %L", g_szError, LANG_SERVER, "NOTE_CURRENT_ERR")
			else ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_CURRENT", g_szNote[id])
		}
		case 'l': 	// load
		{
			if(!is_admin(id)) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_NOACCESS")
			else
			{
				ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_LOAD")
				readCvars()
			}
		}
		case 'd', 'p': 	// delete, player
		{
			if(!is_admin(id)) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_NOACCESS")
			else
			{
				new bool:blDelete = (szArg[0] == 'd') ? true : false
				if(is_blank(szNote)) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_USAGE_ADMIN", szArg)
				else
				{
					new iPlayer = cmd_target(id, szNote, blDelete ? 4 : 0)
					if(!iPlayer) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_NOTFOUND")
					else
					{
						new szName[32], szName2[32]
						get_user_name(id, szName, charsmax(szName))
						get_user_name(iPlayer, szName2, charsmax(szName2))
						if(is_blank(g_szNote[iPlayer])) ColorChat(id, RED, "%s %L", g_szError, LANG_SERVER, "NOTE_NOTHAVE", szName2)
						else
						{
							if(blDelete)
							{
								ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_DELETE_SUCCESS", szName2)
								if(id != iPlayer) ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_DELETE_NOTIFY", szName)
								clearNote(iPlayer)
							}
							else ColorChat(id, BLUE, "%s %L", g_szPrefix, LANG_SERVER, "NOTE_PLAYER", szName2, g_szNote[iPlayer])
						}
					}
				}
			}
		}					
		default: ColorChat(id, BLUE, "%s %L", g_szError, LANG_SERVER, "NOTE_USAGE")
	}
	
	return PLUGIN_HANDLED
}

public eventPlayerKilled()
{
	new iAttacker = read_data(1), iVictim = read_data(2)
	
	if(!is_user_connected(iAttacker) || !is_user_connected(iVictim) || iAttacker == iVictim || is_blank(g_szNote[iAttacker]))
		return
		
	new szNote[192], szName[32]
	get_user_name(iAttacker, szName, charsmax(szName))
	copy(szNote, charsmax(szNote), g_szNote[iAttacker])
	replace(szNote, charsmax(szNote), "<name>", szName)

	switch(g_iType)
	{
		case 1: ColorChat(iVictim, TEAM_COLOR, "%s", szNote)
		case 2:
		{
			set_hudmessage(g_iRed, g_iGreen, g_iBlue, g_flXPos, g_flYPos, 0, 1.0, g_flTime, 0.1, 0.1, -1)
			show_hudmessage(iVictim, szNote)
		}
		case 3:
		{
			set_dhudmessage(g_iRed, g_iGreen, g_iBlue, g_flXPos, g_flYPos, 0, 1.0, g_flTime, 0.1, 0.1)
			show_dhudmessage(iVictim, szNote)
		}
	}
}

public clearNote(id)
	g_szNote[id][0] = EOS

bool:is_admin(id)
	return (get_user_flags(id) & FLAG_ADMIN) ? true : false

bool:is_blank(szMessage[])
	return (szMessage[0] == EOS) ? true : false
	
/* ColorChat */

ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	static message[256];

	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], charsmax(message) - 4, msg, 4);
	
	replace_all(message, charsmax(message), "!n", "^x01");
	replace_all(message, charsmax(message), "!t", "^x03");
	replace_all(message, charsmax(message), "!g", "^x04");

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	static team, ColorChange, index, MSG_Type;
	
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
	
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	message_begin(type, g_msgSayText, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	message_begin(type, g_msgTeamInfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	static i;
	i = -1;

	while(i <= g_iMaxPlayers)
	{
		if(is_user_connected(++i))
		{
			return i;
		}
	}

	return -1;
}
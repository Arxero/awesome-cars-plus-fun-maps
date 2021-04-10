/*
    PhAFK Manager, AMX Mod X Plugin
    Copyright (C) 2013  Phantomas

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#tryinclude <fakemeta_util>
#if !defined _fakemeta_util_included
        #assert Fakemeta Utilities function library required! Read the below instructions:   \
                1. Download it at forums.alliedmods.net/showthread.php?t=28284   \
                2. Put it into amxmodx/scripting/include/ folder   \
                3. Compile this plugin locally, details: wiki.amxmodx.org/index.php/Compiling_Plugins_%28AMX_Mod_X%29   \
                4. Install compiled plugin, details: wiki.amxmodx.org/index.php/Configuring_AMX_Mod_X#Installing
#endif

#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <engine>

#define PLUGIN "PhAFK Manager"
#define AUTHOR "Phantomas"
#define VERSION "1.4"

#define PREFIX "[AFK] "
 
 // Tasks IDs
#define TASK_AFK_CHECK 0
#define TASK_DROP_DOWN 1

// Some frequences
#define FREQ_AFK_CHECK 5.0
#define DROP_DOWN_TIME 1.0
#define WARNING_MESSAGE_MODULO 2

#define BE_AFK_TIME 10.0
#define GLOBAL_MESSAGE_FREQ 5.0

// Customization
#define ANGLES_SUPPORT
#define AFK_SPEC_IMMUNITY ADMIN_IMMUNITY
#define AFK_IMMUNITY ADMIN_RCON

// Users Individual
#if defined ANGLES_SUPPORT
new Float:g_angles[33][3]
#endif
new Float:g_origin[33][3]
new bool:g_in_class_choose[33]
new bool:g_in_afk[33]
new g_afk_ticks[33]

// Other
new Float:g_last_global_message
new bool:g_disable_alive_check

// CVARS
new cv_kick_time
new cv_spec_time
new cv_bomb
new cv_bomb_drop_time
new cv_spec_immunity
new cv_immunity
new cv_global_message
new cv_min_players

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("phafk.txt")
	
	register_event("HLTV", "start_round", "a", "1=0", "2=0")
	register_logevent("start_round_fr", 2, "1=Round_Start")
	register_event("30", "intermission", "a")
	
	register_message(96, "Message_ShowMenu")
	register_message(114, "Message_VGUIMenu")
	
	register_clcmd("joinclass", "class_selected")
	register_menucmd(register_menuid("Terrorist_Select", 1), 511, "class_selected")
	register_menucmd(register_menuid("CT_Select", 1), 511, "class_selected")
	
	register_cvar("afk_kick_time", "90")
	register_cvar("afk_spec_time", "0")
	register_cvar("afk_bomb_time", "15")
	register_cvar("afk_bomb", "2")
	register_cvar("afk_immunity_spec", "1")
	register_cvar("afk_immunity", "1")
	register_cvar("afk_global_message", "1")
	register_cvar("afk_min_players", "0")
	cv_kick_time = get_cvar_num("afk_kick_time")
	cv_spec_time = get_cvar_num("afk_spec_time")
	cv_bomb_drop_time = get_cvar_num("afk_bomb_time")
	cv_bomb = get_cvar_num("afk_bomb")
	cv_spec_immunity = get_cvar_num("afk_immunity_spec")
	cv_immunity = get_cvar_num("afk_immunity")
	cv_global_message = get_cvar_num("afk_global_message")
	cv_min_players = get_cvar_num("afk_min_players")
}

public intermission()
{
	pause("ad")
}

public Message_ShowMenu(iMsgId, iMsgDest, iReceiver)
{
	static szArg4[20]
	get_msg_arg_string(4, szArg4, charsmax(szArg4))
	if(equal(szArg4, "#Terrorist_Select", 17) || equal(szArg4, "#CT_Select", 10))
	{
		g_in_class_choose[iReceiver] = true
	}
	return PLUGIN_CONTINUE;
}
 
public Message_VGUIMenu(iMsgId, iMsgDest, iReceiver)
{
	static iArg1; iArg1 = get_msg_arg_int(1)
	if(iArg1 == 2)
	{
		g_in_class_choose[iReceiver] = true
	}
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	g_in_class_choose[id] = false
	g_in_afk[id] = false
	g_afk_ticks[id] = 0
}

public class_selected(id)
{
	g_in_class_choose[id] = false
	client_putinserver(id)
}

public bomb_action(id, cv_bomb)
{
	if(cv_bomb == 1)
	{
		engclient_cmd(id, "drop", "weapon_c4")
		client_print(id, print_chat, "%s%L", PREFIX, LANG_SERVER, "BOMB_DROP")
	} else if(cv_bomb == 2) {
		new players[32], inum
		get_players(players, inum, "aeh", "TERRORIST")
		if(inum > 1)
		{
			new random_terrorist
			do
			{
				random_terrorist = players[random_num(0, inum - 1)]
			}
			while(random_terrorist == id)
			if(g_in_afk[random_terrorist] == false)
			{
				fm_transfer_user_gun(id, random_terrorist, CSW_C4)
				client_print(id, print_chat, "%s%L", PREFIX, LANG_SERVER, "BOMB_TRANSFERRED")
				client_print(random_terrorist, print_chat, "%s%L", PREFIX, LANG_SERVER, "BOMB_GOT")
			}
		}
	}
}

public afk_action(id, alive, CsTeams:team)
{
	g_afk_ticks[id]++
	
	if(g_afk_ticks[id] >= (BE_AFK_TIME / FREQ_AFK_CHECK))
	{
		g_in_afk[id] = true
	}
	
	if((g_afk_ticks[id] >= (cv_bomb_drop_time / FREQ_AFK_CHECK)) && (alive == 1) && (team == CS_TEAM_T) && (pev(id, pev_weapons) & (1 << CSW_C4)))
	{
		bomb_action(id, cv_bomb)
	}
	
	if((cv_kick_time != 0) && (g_afk_ticks[id] >= (cv_kick_time / FREQ_AFK_CHECK)))
	{
		//if(true)
		if(!(id == 1 && !is_dedicated_server()))
		{
			new name[32]
			get_user_name(id, name, sizeof name - 1)
			server_cmd("kick #%d ^"%L^"", get_user_userid(id), LANG_SERVER, "KICK_REASON")
			client_print(0, print_chat, "%s%L", PREFIX, LANG_SERVER, "KICKED_AFK", name)
			return 1
		}
	} else if((cv_spec_time != 0) && (team != CS_TEAM_UNASSIGNED && team != CS_TEAM_SPECTATOR) && (g_afk_ticks[id] >= (cv_spec_time / FREQ_AFK_CHECK)) && (get_cvar_num("allow_spectators"))) {
		if(is_user_alive(id))
		{
			user_silentkill(id)
		}
		set_pdata_int(id, 125, get_pdata_int(id, 125, 5) & ~(1<<8), 5) // allow team change
		engclient_cmd(id, "jointeam", "6") // spec
		set_pdata_int(id, 125, get_pdata_int(id, 125, 5) & ~(1<<8), 5)
		new name[32]
		get_user_name(id, name, sizeof name - 1)
		client_print(0, print_chat, "%s%L", PREFIX, LANG_SERVER, "SPEC_TRANSFERRED", name)

		set_pev(id, pev_solid, SOLID_NOT);

	} else if((g_in_afk[id] == true) && (cv_kick_time != 0)) {
		if(g_afk_ticks[id] % WARNING_MESSAGE_MODULO == 0)
		{
			if(alive == 1)
			{
				client_print(id, print_chat, "%s%L", PREFIX, LANG_SERVER, "YOU_AFK")
			} else {
				client_print(id, print_chat, "%s%L", PREFIX, LANG_SERVER, "YOU_AFK_JOIN")
			}
		}
	}
	return 0
}

public send_global_message(ts_alive, cts_alive, ts_afks, cts_afks, Float:current_time)
{
	if(cv_global_message == 0)
	{
		return PLUGIN_HANDLED
	}
	
	if((current_time - g_last_global_message) < GLOBAL_MESSAGE_FREQ)
	{
		return PLUGIN_HANDLED
	}
	
	if(cts_afks > 0 && cts_alive == 0 && ts_alive > 0)
	{
		client_print(0, print_chat, "%s%L", PREFIX, LANG_SERVER, "ALL_CTS_AFK")
	}
	if(ts_afks > 0 && ts_alive == 0 && cts_alive > 0)
	{
		client_print(0, print_chat, "%s%L", PREFIX, LANG_SERVER, "ALL_TS_AFK")
	}
	g_last_global_message = current_time

	return PLUGIN_CONTINUE
}

public afk_check_player(id, Float:current_time, alive, CsTeams:team)
{
	if(alive)
	{
		if(g_disable_alive_check == true && alive == 1)
		{
			return 0
		}
		
		if(cv_immunity == 1 && access(id, AFK_IMMUNITY))
		{
			return 0
		}
		
		new Float:current_origin[3]
		pev(id, pev_origin, current_origin)
		
		#if defined ANGLES_SUPPORT
		new Float:current_angles[3]
		pev(id, pev_v_angle, current_angles)
		if((current_angles[0] == g_angles[id][0]) && (current_angles[1] == g_angles[id][1]) && (current_origin[0] == g_origin[id][0]) && (current_origin[1] == g_origin[id][1]) && (current_origin[2] == g_origin[id][2]))
		#else
		if((current_origin[0] == g_origin[id][0]) && (current_origin[2] == g_origin[id][2]) && (current_origin[2] == g_origin[id][2]))
		#endif
		{
			return afk_action(id, alive, team)
		} else {
			g_in_afk[id] = false
			g_afk_ticks[id] = 0
			g_origin[id] = current_origin
			#if defined ANGLES_SUPPORT
			g_angles[id] = current_angles
			#endif
		}
	} else {
		if((g_in_class_choose[id] == true) || (team == CS_TEAM_UNASSIGNED) || (team == CS_TEAM_SPECTATOR))
		{
			if((team == CS_TEAM_SPECTATOR) && (access(id, AFK_SPEC_IMMUNITY)) && (cv_spec_immunity == 1))
			{
				return 0
			}
			return afk_action(id, alive, team)
		} else {
			g_in_afk[id] = false
		}
	}
	return 0
}

public afk_check()
{
	new Float:current_time = get_gametime()
	
	new CsTeams:team, alive
	new ts_num, cts_num
	new ts_num_afks, cts_num_afks
		
	new players[32], inum
	get_players(players, inum, "h")
	if(inum >= cv_min_players)
	{
		for(new i = 0; i < inum; ++i)
		{
			alive = is_user_alive(players[i])
			team = cs_get_user_team(players[i])
			if(afk_check_player(players[i], current_time, alive, team) == 0)
			{
				if(team == CS_TEAM_T)
				{
					if(alive == 1)
					{
						//ts_num++
						if(g_in_afk[players[i]] == true)
						{
							ts_num_afks++
						} else {
							ts_num++
						}
					}
				} else if(team == CS_TEAM_CT) {
					if(alive == 1)
					{
						//cts_num++
						if(g_in_afk[players[i]] == true)
						{
							cts_num_afks++
						} else {
							cts_num++
						}
					}
				}
			}
		}
		send_global_message(ts_num, cts_num, ts_num_afks, cts_num_afks, current_time)
	}
}

public start_round()
{
	g_disable_alive_check = true
	remove_task(TASK_DROP_DOWN)
	set_task(DROP_DOWN_TIME, "start_round_fr_action", TASK_DROP_DOWN)
}

public start_round_fr_action()
{
	new players[32], inum
	get_players(players, inum, "ha")
	for(new i = 0; i < inum; ++i)
	{
		new Float:current_origin[3]
		pev(players[i], pev_origin, current_origin)
		g_origin[players[i]] = current_origin
		#if defined ANGLES_SUPPORT
		new Float:current_angles[3]
		pev(players[i], pev_v_angle, current_angles)
		g_angles[players[i]] = current_angles
		#endif
	}
	g_disable_alive_check = false
}

public start_round_fr()
{
	if(!task_exists(TASK_AFK_CHECK))
	{
		set_task(FREQ_AFK_CHECK, "afk_check", TASK_AFK_CHECK, _, _, "b")
	}
}
/*  AMX Mod X script
*                               ______                       __                    __          __                              ________
*		               / ____ \                      \ \                  / /         /  |                            |______  |
*		              / /    \ \                      \ \                / /         /   |                        __         | |
*		             | /      \ |                      \ \              / /         / /| |                       |__|        | |
*		             | |      | |    ______     _    __ \ \            / /  _      / / | |       ______                      | |
*    	 _   _____   _____   | |      | |   / ____ \   | |  / /  \ \          / /  |_|    / /  | |      / ____ \                     | |
*	| | / __  | / __  |  | |      | |  | /    \_\  | | / /    \ \        / /    _    / /   | |     /_/    \ \                    | |
*	| |/ /  | |/ /  | |  | |      | |  | \_____    | |/ /      \ \      / /    | |  / /____| |__     ______| |                   | |
*	| | /   | | /   | |  | |      | |   \_____ \   | | /        \ \    / /     | | /_______  |__|   / _____  |                   | |
*	| |/    | |/    | |  | |      | |         \ |  | |/\         \ \  / /      | |         | |     / /     | |        __         | |
* 	| |     | |     | |  | \      / |  __     | |  | |\ \         \ \/ /       | |         | |    | |     /| |       |  |        | |
*	| |     | |     | |   \ \____/ /   \ \____/ |  | | \ \         \  /        | |         | |     \ \___/ /\ \      / /    _____| |
*	|_|     |_|     |_|    \______/     \______/   |_|  \_\         \/         |_|         |_|      \_____/  \_\    /_/    |_______|
*
*
*
*** Copyright 2011 - 2013, m0skVi4a ;]
*** Plugin created in Rousse, Bulgaria
*
*
*** Plugin thread 1:
*	https://forums.alliedmods.net/showthread.php?t=183491
*
*** Plugin thread 2:
*	http://amxmodxbg.org/forum/viewtopic.php?t=38972
*
*
*** Description:
*
*	With this plugin you can set prefixes to Admins with special flags. Also Admins can put custom prefixes to them or to other players if they want, but only if they have the required flag.
*
*
*** Commands:
*
*	ap_reload_prefixes
*	Reloads Prefixes' file from console without restarting the server.
*
*	ap_reload_badprefixes
*	Reloads Bad Prefixes' file from console without restarting the server.
*
*	ap_put_player "name" "prefix"
*	Puts prefix to the name you type if you have the special flag. Or if there is no prefix typed, removes the prefix which the player has.
*
*
*** CVARS:
*
*	"ap_bad_prefixes"	 - 	Is the Bad Prefixes option on(1) or off(0).   Default: 1
*	"ap_listen"		 - 	Is the Admin Listen option on(1) or off(0).   Default: 1
*	"ap_listen_flag"	 -	The flag, needed for Listen option.   Default: a
*	"ap_custom"		 -	Is the Custom Prefix option for each Admin is on(1) or off(0).   Default: 1
*	"ap_custom_flag" 	 -	The flag, needed for setting custom prefix.   Default: b
*	"ap_say_characters"	 -	Is the Start Say Characters option on(1) or off(0).   Default: 1
*	"ap_prefix_characters"	 -	Is the Checker for Characters in Custom Prefixes' Options on(1) or off(0).   Default: 1
*
*	All CVARS are without quotes!
*
*
*** Credits:
*
* 	m0skVi4a ;]    	-	for the idea, making and testing the plugin
*	SpeeDeeR    	-	for little help with the plugin
*	Ant1Lamer    	-	for testing the plugin
*	Vasilii-Zaicev	-	for testing the plugin
*
*
*** Changelog:
*
*	April 22, 2012   -  V1.0:
*		-  First Release
*
*	May 19, 2012   -  V2.0:
*		-  Full optimization
*		-  Added Bad Prefixes' file
*		-  Added Multi-Lingual file
*		-  Added IP and Name support in ap_prefixes.ini
*		-  Added Forbidden Say characters
*		-  New CVARS for setting the flags for each of the options
*	
*	May 29, 2012   -  V2.1:
*		-  Fixed bug with some say or say_team commands are not executed
*
*	January 17, 2013   -  V3.0:
*		-  Full optimization
*		-  Fixed bug when typing spaces and in tha chat is showing an empty message
*		-  SteamID support
*		-  Removed nvault
*		-  Removed ap_put_player command
*		-  ap_put_player command is combined with ap_put command
*		-  Removed some CVARs
*
*	August 18, 2013   -  V4.0:
*		-  Small code changes and little bug fixes
*		-  Added Prefux Toggle command
*		-  Fixed bug with the supporting of the plugin on AMXX 1.8.2
*		-  AMXX 1.8.2 Supprot! 
*		-  SQL Version! 
*
*
*** Contact me on:
*	E-MAIL: pvldimitrov@gmail.com
*	SKYPE: pa7ohin
*/


#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <cstrike>

#define VERSION "4.0 WHITE CHAT"
#define FLAG_LOAD ADMIN_CFG
#define MAX_PREFIXES 33
#define MAX_BAD_PREFIXES 100

new g_bad_prefix, g_listen, g_listen_flag, g_custom, g_custom_flag, g_say_characters, g_prefix_characters;
new pre_ips_count = 0, pre_names_count = 0, pre_steamids_count, pre_flags_count = 0, bad_prefix_count = 0, i, temp_cvar[2];
new configs_dir[64], file_prefixes[128], file_bad_prefixes[128], text[128], prefix[32], type[2], key[32], length, line = 0, error[256];
new g_teaminfo, g_saytxt, g_maxplayers, CsTeams:g_team;
new g_typed[192], g_message[192], g_name[32];
new Trie:pre_ips_collect, Trie:pre_names_collect, Trie:pre_steamids_collect, Trie:pre_flags_collect, Trie:bad_prefixes_collect, Trie:client_prefix;
new str_id[16], temp_key[35], temp_prefix[32], temp_value;
new bool:g_toggle[33];
new bool:is_admin;

new const say_team_info[2][CsTeams][] =
{
	{"*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* "},
	{"", "", "", ""}
}

new const sayteam_team_info[2][CsTeams][] =
{
	{"(Spectator) ", "*DEAD*(Terrorist) ", "*DEAD*(Counter-Terrorist) ", "(Spectator) "},
	{"(Spectator) ", "(Terrorist) ", "(Counter-Terrorist) ", "(Spectator) "}
}

new const forbidden_say_symbols[] = {
	"/",
	"!",
	"%",
	"$"
}

new const forbidden_prefixes_symbols[] = {
	"/",
	"\",
	"%",
	"$",
	".",
	":",
	"?",
	"!",
	"@",
	"#",
	"%"
}

new const separator[] = "************************************************"
new const in_prefix[] = "[AdminPrefixes]"

new const g_team_names[CsTeams][] = {
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

public plugin_init()
{
	register_plugin("Admin Prefixes", VERSION, "m0skVi4a ;]")

	g_bad_prefix = register_cvar("ap_bad_prefixes", "1")
	g_listen = register_cvar("ap_listen", "1")
	g_listen_flag = register_cvar("ap_listen_flag", "a")
	g_custom = register_cvar("ap_custom_current", "1")
	g_custom_flag = register_cvar("ap_custom_current_flag", "b")
	g_say_characters = register_cvar("ap_say_characters", "1")
	g_prefix_characters = register_cvar("ap_prefix_characters", "1")

	g_teaminfo = get_user_msgid("TeamInfo")
	g_saytxt = get_user_msgid ("SayText")
	g_maxplayers = get_maxplayers()

	register_concmd("ap_reload_prefixes", "LoadPrefixes")
	register_concmd("ap_reload_badprefixes", "LoadBadPrefixes")
	register_concmd("ap_put", "SetPlayerPrefix")
	register_clcmd("say", "HookSay")
	register_clcmd("say_team", "HookSayTeam")

	pre_ips_collect = TrieCreate()
	pre_names_collect = TrieCreate()
	pre_steamids_collect = TrieCreate()
	pre_flags_collect = TrieCreate()
	bad_prefixes_collect = TrieCreate()
	client_prefix = TrieCreate()

	register_dictionary("admin_prefixes.txt")

	get_configsdir(configs_dir, charsmax(configs_dir))
	formatex(file_prefixes, charsmax(file_prefixes), "%s/ap_prefixes.ini", configs_dir)
	formatex(file_bad_prefixes, charsmax(file_bad_prefixes), "%s/ap_bad_prefixes.ini", configs_dir)

	LoadPrefixes(0)
	LoadBadPrefixes(0)
}
	
public LoadPrefixes(id)
{
	if(!(get_user_flags(id) & FLAG_LOAD))
	{
		console_print(id, "%L", LANG_SERVER, "PREFIX_PERMISSION", in_prefix)
		return PLUGIN_HANDLED
	}

	TrieClear(pre_ips_collect)
	TrieClear(pre_names_collect)
	TrieClear(pre_steamids_collect)
	TrieClear(pre_flags_collect)

	line = 0, length = 0, pre_flags_count = 0, pre_ips_count = 0, pre_names_count = 0;

	if(!file_exists(file_prefixes)) 
	{
		formatex(error, charsmax(error), "%L", LANG_SERVER, "PREFIX_NOT_FOUND", in_prefix, file_prefixes)
		set_fail_state(error)
	}

	server_print(separator)

	while(read_file(file_prefixes, line++ , text, charsmax(text), length) && (pre_ips_count + pre_names_count + pre_steamids_count + pre_flags_count) <= MAX_PREFIXES)
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
			continue

		parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix))
		trim(prefix)

		if(!type[0] || !prefix[0] || !key[0])
			continue

		replace_all(prefix, charsmax(prefix), "!g", "^x04")
		replace_all(prefix, charsmax(prefix), "!t", "^x03")
		replace_all(prefix, charsmax(prefix), "!n", "^x01")

		switch(type[0])
		{
			case 'f':
			{
				pre_flags_count++
				TrieSetString(pre_flags_collect, key, prefix)
				server_print("%L", LANG_SERVER, "PREFIX_LOAD_FLAG", in_prefix, prefix, key[0])
			}
			case 'i':
			{
				pre_ips_count++
				TrieSetString(pre_ips_collect, key, prefix)
				server_print("%L", LANG_SERVER, "PREFIX_LOAD_IP", in_prefix, prefix, key)
			}
			case 's':
			{
				pre_steamids_count++
				TrieSetString(pre_steamids_collect, key, prefix)
				server_print("%L", LANG_SERVER, "PREFIX_LOAD_STEAMID", in_prefix, prefix, key)
			}
			case 'n':
			{
				pre_names_count++
				TrieSetString(pre_names_collect, key, prefix)
				server_print("%L", LANG_SERVER, "PREFIX_LOAD_NAME", in_prefix, prefix, key)
			}
			default:
			{
				continue
			}
		}
	}

	if(pre_flags_count <= 0 && pre_ips_count <= 0 && pre_steamids_count <= 0 && pre_names_count <= 0)
	{
		server_print("%L", LANG_SERVER, "PREFIX_NO", in_prefix)
	}

	get_user_name(id, g_name, charsmax(g_name))
	server_print("%L", LANG_SERVER, "PREFIX_LOADED_BY", in_prefix, g_name)
	console_print(id, "%L", LANG_SERVER, "PREFIX_LOADED", in_prefix)

	server_print(separator)

	for(new i = 1; i <= g_maxplayers; i++)
	{
		num_to_str(i, str_id, charsmax(str_id))
		TrieDeleteKey(client_prefix, str_id)
		PutPrefix(i)
	}
	
	return PLUGIN_HANDLED
}

public LoadBadPrefixes(id)
{
	if(!get_pcvar_num(g_bad_prefix))
	{
		console_print(id, "%L", LANG_SERVER, "BADP_OFF", in_prefix)
		return PLUGIN_HANDLED
	}

	if(!(get_user_flags(id) & FLAG_LOAD))
	{
		console_print(id, "%L", LANG_SERVER, "BADP_PERMISSION", in_prefix)
		return PLUGIN_HANDLED
	}

	TrieClear(bad_prefixes_collect)

	line = 0, length = 0, bad_prefix_count = 0;

	if(!file_exists(file_bad_prefixes)) 
	{
		console_print(id, "%L", LANG_SERVER, "BADP_NOT_FOUND", in_prefix, file_bad_prefixes)
		return PLUGIN_HANDLED		
	}

	server_print(separator)

	while(read_file(file_bad_prefixes, line++ , text, charsmax(text), length) && bad_prefix_count <= MAX_BAD_PREFIXES)
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
			continue

		parse(text, prefix, charsmax(prefix))

		if(!prefix[0])
			continue

		bad_prefix_count++
		TrieSetCell(bad_prefixes_collect, prefix, 1)
		server_print("%L", LANG_SERVER, "BADP_LOAD", in_prefix, prefix)
	}

	if(bad_prefix_count <= 0)
	{
		server_print("%L", LANG_SERVER, "BADP_NO", in_prefix)
	}

	get_user_name(id, g_name, charsmax(g_name))
	server_print("%L", LANG_SERVER, "BADP_LOADED_BY", in_prefix, g_name)
	console_print(id, "%L", LANG_SERVER, "BADP_LOADED", in_prefix)

	server_print(separator)

	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	g_toggle[id] = true
	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")
	PutPrefix(id)
}

public HookSay(id)
{
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	trim(g_typed)

	if(equal(g_typed, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix"))
	{
		if(g_toggle[id])
		{
			g_toggle[id] = false
			client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_OFF", in_prefix)
		}
		else
		{
			g_toggle[id] = true
			client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_ON", in_prefix)
		}

		return PLUGIN_HANDLED_MAIN
	}

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
	{
		if(check_say_characters(g_typed))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, g_name, charsmax(g_name))

	g_team = cs_get_user_team(id)

	if(temp_prefix[0] && g_toggle[id])
	{
		formatex(g_message, charsmax(g_message), "^1%s^3%s^4 %s :^3 %s", say_team_info[is_user_alive(id)][g_team], temp_prefix, g_name, g_typed)
		is_admin = true
	}
	else
	{
		formatex(g_message, charsmax(g_message), "^1%s^3%s :^1 %s", say_team_info[is_user_alive(id)][g_team], g_name, g_typed)
		is_admin = false
	}

	get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue
			
		if(is_admin)
		{
			g_team = cs_get_user_team(i)
			change_team_info(i, g_team_names[CS_TEAM_SPECTATOR])
			send_message(g_message, i, i)
				change_team_info(i, g_team_names[g_team])
		}
		else
		{
			send_message(g_message, id, i)
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public HookSayTeam(id)
{
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	trim(g_typed)

	if(equal(g_typed, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix"))
	{
		if(g_toggle[id])
		{
			g_toggle[id] = false
			client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_OFF", in_prefix)
		}
		else
		{
			g_toggle[id] = true
			client_print(id, print_chat, "%L", LANG_SERVER, "PREFIX_ON", in_prefix)
		}

		return PLUGIN_HANDLED_MAIN
	}

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
	{
		if(check_say_characters(g_typed))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, g_name, charsmax(g_name))

	g_team = cs_get_user_team(id)

	if(temp_prefix[0] &&  g_toggle[id])
	{
		formatex(g_message, charsmax(g_message), "^1%s^3%s^4 %s :^3 %s", sayteam_team_info[is_user_alive(id)][g_team], temp_prefix, g_name, g_typed)
		is_admin = true
	}
	else
	{
		formatex(g_message, charsmax(g_message), "^1%s^3%s :^1 %s", sayteam_team_info[is_user_alive(id)][g_team], g_name, g_typed)
		is_admin = false
	}

	get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue

		if(get_user_team(id) == get_user_team(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
		{
			if(is_admin)
			{
				g_team = cs_get_user_team(i)
				change_team_info(i, g_team_names[CS_TEAM_SPECTATOR])
				send_message(g_message, i, i)
				change_team_info(i, g_team_names[g_team])
			}
			else
			{
				send_message(g_message, id, i)
			}
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public SetPlayerPrefix(id)
{
	if(!get_pcvar_num(g_custom) || !get_pcvar_string(g_custom_flag, temp_cvar, charsmax(temp_cvar)))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_OFF", in_prefix)
		return PLUGIN_HANDLED
	}

	if(!(get_user_flags(id) & read_flags(temp_cvar)))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_PERMISSION", in_prefix)
		return PLUGIN_HANDLED
	}

	new input[128], target;
	new arg_type[2], arg_prefix[32], arg_key[35];
	new temp_str[16];

	read_args(input, charsmax(input))
	remove_quotes(input)
	parse(input, arg_type, charsmax(arg_type), arg_key, charsmax(arg_key), arg_prefix, charsmax(arg_prefix))
	trim(arg_prefix)

	if(get_pcvar_num(g_bad_prefix) && is_bad_prefix(arg_prefix) && !equali(arg_prefix, ""))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_FORBIDDEN", in_prefix, arg_prefix)
		return PLUGIN_HANDLED
	}

	if(get_pcvar_num(g_prefix_characters) && check_prefix_characters(arg_prefix))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_SYMBOL", in_prefix, arg_prefix, forbidden_prefixes_symbols[i])
		return PLUGIN_HANDLED
	}

	switch(arg_type[0])
	{
		case 'f':
		{
			target = 0
			temp_str = "Flag"
		}
		case 'i':
		{
			target = find_player("d", arg_key)
			temp_str = "IP"
		}
		case 's':
		{
			target = find_player("c", arg_key)
			temp_str = "SteamID"
		}
		case 'n':
		{
			target = find_player("a", arg_key)
			temp_str = "Name"
		}
		default:
		{
			console_print(id, "%L", LANG_SERVER, "CUSTOM_INVALID", in_prefix, arg_type)
			return PLUGIN_HANDLED
		}
	}

	get_user_name(id, g_name, charsmax(g_name))

	if(equali(arg_prefix, ""))
	{
		find_and_delete(arg_type, arg_key)

		if(target)
		{
			PutPrefix(target)
		}
		
		console_print(id, "%L", LANG_SERVER, "CUSTOM_REMOVE", in_prefix, temp_str, arg_key)
		server_print("%L", LANG_SERVER, "CUSTOM_REMOVE_INFO", in_prefix, g_name, temp_str, arg_key)
		return PLUGIN_HANDLED
	}

	find_and_delete(arg_type, arg_key)

	formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^"", arg_type, arg_key, arg_prefix)
	write_file(file_prefixes, text, -1)

	switch(arg_type[0])
	{
		case 'f':
		{
			TrieSetString(pre_flags_collect, arg_key, arg_prefix)
		}
		case 'i':
		{
			TrieSetString(pre_ips_collect, arg_key, arg_prefix)
		}
		case 's':
		{
			TrieSetString(pre_steamids_collect, arg_key, arg_prefix)
		}
		case 'n':
		{
			TrieSetString(pre_names_collect, arg_key, arg_prefix)
		}
	}

	if(target)
	{
		num_to_str(target, str_id, charsmax(str_id))
		TrieSetString(client_prefix, str_id, arg_prefix)
	}

	console_print(id, "%L", LANG_SERVER, "CUSTOM_CHANGE", in_prefix, temp_str, arg_key, arg_prefix)
	server_print("%L", LANG_SERVER, "CUSTOM_CHANGE_INFO", in_prefix, g_name, temp_str, arg_key, arg_prefix) 

	return PLUGIN_HANDLED
}


public client_infochanged(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE

	new g_old_name[32];

	get_user_info(id, "name", g_name, charsmax(g_name))
	get_user_name(id, g_old_name, charsmax(g_old_name))

	if(!equal(g_name, g_old_name))
	{
		num_to_str(id, str_id, charsmax(str_id))
		TrieSetString(client_prefix, str_id, "")
		set_task(0.5, "PutPrefix", id)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public PutPrefix(id)
{
	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")

	new sflags[32], temp_flag[2];
	get_flags(get_user_flags(id), sflags, charsmax(sflags))

	for(new i = 0; i <= charsmax(sflags); i++)
	{
		formatex(temp_flag, charsmax(temp_flag), "%c", sflags[i])

		if(TrieGetString(pre_flags_collect, temp_flag, temp_prefix, charsmax(temp_prefix)))
		{
			TrieSetString(client_prefix, str_id, temp_prefix)
		}
	}

	get_user_ip(id, temp_key, charsmax(temp_key), 1)

	if(TrieGetString(pre_ips_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	get_user_authid(id, temp_key, charsmax(temp_key))

	if(TrieGetString(pre_steamids_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	get_user_name(id, temp_key, charsmax(temp_key))

	if(TrieGetString(pre_names_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	return PLUGIN_HANDLED
}

send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, g_saytxt, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}

change_team_info(const id, const team[])
{
	message_begin(MSG_ONE, g_teaminfo,_, id)
	write_byte(id)
	write_string(team)
	message_end()
}

bool:check_say_characters(const check_message[])
{
	for(new i = 0; i < charsmax(forbidden_say_symbols); i++)
	{
		if(check_message[0] == forbidden_say_symbols[i])
		{
			return true
		}
	}
	return false
}

bool:check_prefix_characters(const check_prefix[])
{
	for(i = 0; i < charsmax(forbidden_prefixes_symbols); i++)
	{
		if(containi(check_prefix, forbidden_prefixes_symbols[i]) != -1)
		{
			return true
		}
	}
	return false
}

bool:is_bad_prefix(const check_prefix[])
{
	if(TrieGetCell(bad_prefixes_collect, check_prefix, temp_value))
	{
		return true
	}
	return false
}

find_and_delete(const arg_type[], const arg_key[])
{
	line = 0, length = 0;

	while(read_file(file_prefixes, line++ , text, charsmax(text), length))
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
			continue

		parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix))
		trim(prefix)

		if(!type[0] || !prefix[0] || !key[0])
			continue
			
		if(!equal(arg_type, type) || !equal(arg_key, key))
			continue
			
		write_file(file_prefixes, "", line - 1)
	}
	
	switch(arg_type[0])
	{
		case 'f':
		{
			TrieDeleteKey(pre_flags_collect, arg_key)
		}
		case 'i':
		{
			TrieDeleteKey(pre_ips_collect, arg_key)
		}
		case 's':
		{
			TrieDeleteKey(pre_steamids_collect, arg_key)
		}
		case 'n':
		{
			TrieDeleteKey(pre_names_collect, arg_key)
		}
	}
}
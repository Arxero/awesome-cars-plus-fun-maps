/*	Formatright � 2016, Freeman

	This plugin is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this plugin; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/* CVARS

//
// CS AFK Manager
//

// Time in seconds that a client can be AFK before being able to trigger AFK global messages
// AFK gobal messages are displayed to a team when all the enemies of the opposing team are AFK
// Set this cvar to 0 to disable the display of AFK global messages
// Default value: 10
afk_global_messages_away_time 10

// AFK bomb management action:
// 2 - transfer the bomb from the AFK bomb carrier to the nearest non-AFK terrorist
// 1 - force the AFK bomb carrier to drop the bomb
// 0 - do nothing with the bomb
// Default value: 2
afk_bomb_action 2

// Time in seconds that a client can have the bomb when being AFK
// Default value: 10
afk_bomb_action_time 10

// Time in seconds that an alive client or a client in appearance select menu can be AFK before he will be transferred to the spectator team
// Set this cvar to 0 to disable this feature and enable AFK kick management in replacement (if it's enabled)
// Default value: 90
afk_switch_to_spec_time 90

// Time in seconds that every clients can be AFK before being kicked
// Set this cvar to 0 to disable this feature
// Default value: 240
afk_kick_time 240

// (0|1) - If the AFK kick management is enabled, it kick spectators only if the server is full
// Default value: 1
afk_kick_spec_only_if_full 1

// This cvar control the full status, it only matters if afk_kick_spec_only_if_full is enabled
//    0    - server is full when MaxClients - amx_reservation (default amxx cvar) is met
// 1 to 32 - server is full when MaxClients - afk_full_minus_num is met
// Default value: 0
afk_full_minus_num 0

// (0|1) - Disable/Enable admin immunity for AFK bomb management
// Default value: 0
afk_bomb_management_immunity 0

// Flag(s) required to have immunity for AFK bomb management
// If multiple flags, admins must have them all
// Default value: "a"
afk_bomb_management_immunity_flag "a"

// (0|1) - Disable/Enable admin immunity for AFK spectator switch management
// Default value: 0
afk_switch_to_spec_immunity 0

// Flag(s) required to have immunity for AFK spectator switch management
// If multiple flags, admins must have them all
// Default value: "a"
afk_switch_to_spec_immunity_flag "a"

// (0|1) - Disable/Enable admin immunity for AFK kick management
// Default value: 0
afk_kick_immunity 0

// Flag(s) required to have immunity for AFK kick management
// If multiple flags, admins must have them all
// Default value: "a"
afk_kick_immunity_flag "a"

// Minimum players to get the plugin working
// Default value: 0
afk_min_players 0

// (0|1) - Disable/Enable check of view angle
// Default value: 0
afk_check_v_angle 0

// (0|1) - Disable/Enable colored messages
// Default value: 1
afk_colored_messages 1

// Advanced setting: Frequency at which the plugin loop
// This setting affect all the management
// Touch it only if you know what you are doing
// Default value: 1.0
afk_loop_frequency 1.0

*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"CS AFK Manager"
#define VERSION	"1.0.6 (amx 1.8.3)"
#define AUTHOR	"Freeman"

const Buttons = IN_ATTACK|IN_JUMP|IN_DUCK|IN_FORWARD|IN_BACK|IN_USE|IN_CANCEL|IN_LEFT|IN_RIGHT|IN_MOVELEFT|IN_MOVERIGHT|IN_ATTACK2|IN_RUN|IN_RELOAD|IN_ALT1|IN_SCORE

new const CBasePlayer[] = "CBasePlayer"

new bool:RoundFreeze
new Float:AfkTime[MAX_PLAYERS+1]
new UserID[MAX_PLAYERS+1]
new Float:ViewAngle[MAX_PLAYERS+1][3]
new ViewAngleChanged
#define SetViewAngleChanged(%1)		ViewAngleChanged |= 1<<(%1&31)
#define RemoveViewAngleChanged(%1)	ViewAngleChanged &= ~(1<<(%1&31))
#define HasViewAngleChanged(%1)		ViewAngleChanged & 1<<(%1&31)

new Float:GlobalMessagesAwayTime, BombAction, Float:BombActionTime, Float:SwitchToSpecTime, Float:KickTime, MinPlayers, KickSpecOnlyIfFull, FullMinusNum
new BombManagementImmunity, SwitchToSpecImmunity, KickImmunity, Float:LoopFrequency, PcvarAllowSpecators, AllowSpecators, AmxReservation
new BombManagementImmunityFlag[27], SwitchToSpecImmunityFlag[27], KickImmunityFlag[27], CheckViewAngle, ColoredMessages

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	create_cvar("afk_manager_version", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY, "Plugin version^nDo not edit this cvar")

	register_dictionary("afk_manager.txt")

	new pcvar = create_cvar("afk_global_messages_away_time", "10", FCVAR_NONE, "Time in seconds that a client can be AFK before being able to trigger AFK global messages^nAFK gobal messages are displayed to a team when all the enemies of the opposing team are AFK^nSet this cvar to 0 to disable the display of AFK global messages", .has_min = true, .min_val = 0.0)
	bind_pcvar_float(pcvar, GlobalMessagesAwayTime)

	pcvar = create_cvar("afk_bomb_action", "2", FCVAR_NONE, "AFK bomb management action:^n2 - transfer the bomb from the AFK bomb carrier to the nearest non-AFK terrorist^n1 - force the AFK bomb carrier to drop the bomb^n0 - do nothing with the bomb", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 2.0) 
	bind_pcvar_num(pcvar, BombAction)

	pcvar = create_cvar("afk_bomb_action_time", "10", FCVAR_NONE, "Time in seconds that a client can have the bomb when being AFK", .has_min = true, .min_val = 0.1)
	bind_pcvar_float(pcvar, BombActionTime)

	pcvar = create_cvar("afk_switch_to_spec_time", "30", FCVAR_NONE, "Time in seconds that an alive client or a client in appearance select menu can be AFK before he will be transferred to the spectator team^nSet this cvar to 0 to disable this feature and enable AFK kick management in replacement (if it's enabled)", .has_min = true, .min_val = 0.0)
	bind_pcvar_float(pcvar, SwitchToSpecTime)

	pcvar = create_cvar("afk_kick_time", "240", FCVAR_NONE, "Time in seconds that every clients can be AFK before being kicked^nSet this cvar to 0 to disable this feature", .has_min = true, .min_val = 0.0)
	bind_pcvar_float(pcvar, KickTime)

	pcvar = create_cvar("afk_kick_spec_only_if_full", "1", FCVAR_NONE, "(0|1) - If the AFK kick management is enabled, it kick spectators only if the server is full", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, KickSpecOnlyIfFull)

	pcvar = create_cvar("afk_full_minus_num", "0", FCVAR_NONE, "This cvar control the full status, it only matters if afk_kick_spec_only_if_full is enabled^n   0    - server is full when MaxClients - amx_reservation (default amxx cvar) is met^n1 to 32 - server is full when MaxClients - afk_full_minus_num is met", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 32.0)
	bind_pcvar_num(pcvar, FullMinusNum)

	pcvar = create_cvar("afk_bomb_management_immunity", "0", FCVAR_NONE, "(0|1) - Disable/Enable admin immunity for AFK bomb management", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, BombManagementImmunity)

	pcvar = create_cvar("afk_bomb_management_immunity_flag", "a", FCVAR_NONE, "Flag(s) required to have immunity for AFK bomb management^nIf multiple flags, admins must have them all")
	bind_pcvar_string(pcvar, BombManagementImmunityFlag, charsmax(BombManagementImmunityFlag))

	pcvar = create_cvar("afk_switch_to_spec_immunity", "0", FCVAR_NONE, "(0|1) - Disable/Enable admin immunity for AFK spectator switch management", .has_min = true, .min_val= 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, SwitchToSpecImmunity)

	pcvar = create_cvar("afk_switch_to_spec_immunity_flag", "a", FCVAR_NONE, "Flag(s) required to have immunity for AFK spectator switch management^nIf multiple flags, admins must have them all")
	bind_pcvar_string(pcvar, SwitchToSpecImmunityFlag, charsmax(SwitchToSpecImmunityFlag))

	pcvar = create_cvar("afk_kick_immunity", "0", FCVAR_NONE, "(0|1) - Disable/Enable admin immunity for AFK kick management", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, KickImmunity)

	pcvar = create_cvar("afk_kick_immunity_flag", "a", FCVAR_NONE, "Flag(s) required to have immunity for AFK kick management^nIf multiple flags, admins must have them all")
	bind_pcvar_string(pcvar, KickImmunityFlag, charsmax(KickImmunityFlag))

	pcvar = create_cvar("afk_min_players", "0", FCVAR_NONE, "Minimum players to get the plugin working", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 32.0)
	bind_pcvar_num(pcvar, MinPlayers)

	pcvar = create_cvar("afk_check_v_angle", "0", FCVAR_NONE, "(0|1) - Disable/Enable check of view angle", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, CheckViewAngle)

	pcvar = create_cvar("afk_colored_messages", "1", FCVAR_NONE, "(0|1) - Disable/Enable colored messages", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	bind_pcvar_num(pcvar, ColoredMessages)

	pcvar = create_cvar("afk_loop_frequency", "1.0", FCVAR_NONE, "Advanced setting: Frequency at which the plugin loop^nThis setting affect all the management^nTouch it only if you know what you are doing", .has_min = true, .min_val = 1.0)
	bind_pcvar_float(pcvar, LoopFrequency)

	AutoExecConfig(true)

	PcvarAllowSpecators = get_cvar_pointer("allow_spectators")
	bind_pcvar_num(PcvarAllowSpecators, AllowSpecators)

	register_clcmd("chooseteam", "team_or_class_selected")
	register_clcmd("jointeam", "team_or_class_selected")
	register_clcmd("joinclass", "team_or_class_selected")
	register_menucmd(register_menuid("Team_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_5|MENU_KEY_6|MENU_KEY_0), "team_or_class_selected")
	register_menucmd(register_menuid("Terrorist_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6), "team_or_class_selected")
	register_menucmd(register_menuid("CT_Select", 1), (MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6), "team_or_class_selected")

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")	// New Round
	register_logevent("LogEvent_Round_Start", 2, "1=Round_Start")
	RegisterHam(Ham_Spawn, "player", "Ham_Player_Spawn_Post", .Post = true)
}

public OnConfigsExecuted()
{
	new pcvar_amx_reservation = get_cvar_pointer("amx_reservation")
	if ( pcvar_amx_reservation )
	{
		bind_pcvar_num(pcvar_amx_reservation, AmxReservation)
	}

	new ent = create_entity("info_target")
	if ( ent )
	{
		entity_set_string(ent, EV_SZ_classname, "afk_manager_ent")
		register_think("afk_manager_ent", "afk_manager_loop")
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + LoopFrequency)
	}
	else
	{
		set_task(LoopFrequency, "afk_manager_loop", .flags = "b")
	}
}

public client_connect(id)
{
	UserID[id] = get_user_userid(id)
	AfkTime[id] = 0.0
}

public team_or_class_selected(id)
{
	AfkTime[id] = 0.0
}

public afk_manager_loop(ent)
{
	if ( ent )
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + LoopFrequency)
	}

	static players[MAX_PLAYERS], player_count
	get_players(players, player_count, "ch")

	if ( player_count < MinPlayers ) return

	static allow_spectators, player, i, player_name[MAX_NAME_LENGTH], CsTeams:player_team, players_num, terrorists[MAX_PLAYERS], terrorist_count, terrorist, j
	static Float:afk_time, is_player_alive, deaths, bomb_receiver, bomb_receiver_name[MAX_NAME_LENGTH], Float:shortest_distance, c4_ent, backpack
	static terrorists_afk, cts_afk, terrorists_not_afk, cts_not_afk, Float:player_origin[3], Float:terrorist_origin[3], Float:origins_distance
	static Float:current_v_angle[3], full_maxplayers, last_kick_id, Float:last_kick_time

	if ( FullMinusNum )
	{
		full_maxplayers = MaxClients - FullMinusNum
	}
	else
	{
		full_maxplayers = MaxClients - AmxReservation
	}

	allow_spectators = AllowSpecators
	players_num = get_playersnum(1)
	terrorists_afk = 0
	cts_afk = 0
	terrorists_not_afk = 0
	cts_not_afk = 0
	last_kick_id = 0
	last_kick_time = 0.0

	for ( i = 0; i < player_count; i++ )
	{
		player = players[i]

		player_team = cs_get_user_team(player)
		switch(player_team)
		{
			case CS_TEAM_SPECTATOR, CS_TEAM_UNASSIGNED:
			{
				if ( KickTime > 0.0 )
				{
					if ( entity_get_int(player, EV_INT_button) & Buttons )
					{
						AfkTime[player] = 0.0
					}
					else
					{
						AfkTime[player] += LoopFrequency
					}

					afk_time = AfkTime[player]

					if ( afk_time >= KickTime && ( !KickImmunity || !has_all_flags(player, KickImmunityFlag) ) && ( !KickSpecOnlyIfFull || players_num >= full_maxplayers ) )
					{
						if ( KickSpecOnlyIfFull )
						{
							if ( afk_time > last_kick_time )
							{
								last_kick_id = player
								last_kick_time = afk_time
							}
						}
						else
						{
							user_kick(player)
						}
					}
				}
			}
			case CS_TEAM_CT, CS_TEAM_T:
			{
				is_player_alive = is_user_alive(player)

				if ( ( !RoundFreeze && is_player_alive ) || get_ent_data(player, CBasePlayer, "m_iMenu") == CS_Menu_ChooseAppearance )
				{
					if ( CheckViewAngle )
					{
						entity_get_vector(player, EV_VEC_v_angle, current_v_angle)
						if ( entity_get_int(player, EV_INT_button) & Buttons )
						{
							AfkTime[player] = 0.0
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
						 }
						else if ( HasViewAngleChanged(player) )
						{
							AfkTime[player] += LoopFrequency
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
							RemoveViewAngleChanged(player)
						}
						else if ( ViewAngle[player][0] != current_v_angle[0] || ViewAngle[player][1] != current_v_angle[1] )
						{
							AfkTime[player] = 0.0
							ViewAngle[player][0] = current_v_angle[0]
							ViewAngle[player][1] = current_v_angle[1]
						}
						else
						{
							AfkTime[player] += LoopFrequency
						}
					}
					else
					{
						if ( entity_get_int(player, EV_INT_button) & Buttons )
						{
							AfkTime[player] = 0.0
						}
						else
						{
							AfkTime[player] += LoopFrequency
						}
					}

					afk_time = AfkTime[player]

					if ( GlobalMessagesAwayTime > 0.0 && is_player_alive )
					{
						if ( afk_time >= GlobalMessagesAwayTime )
						{
							if ( player_team == CS_TEAM_T )
							{
								terrorists_afk++
							}
							else
							{
								cts_afk++
							}
						}
						else
						{
							if ( player_team == CS_TEAM_T )
							{
								terrorists_not_afk++
							}
							else
							{
								cts_not_afk++
							}
						}
					}

					if ( BombAction > 0 && afk_time >= BombActionTime && user_has_weapon(player, CSW_C4) && ( !BombManagementImmunity || !has_all_flags(player, BombManagementImmunityFlag) ) )
					{
						get_players(terrorists, terrorist_count, "aceh", "TERRORIST")

						if ( terrorist_count > 1 )
						{
							if ( BombAction == 2 )
							{
								bomb_receiver = 0
								shortest_distance = 999999.0
								entity_get_vector(player, EV_VEC_origin, player_origin)

								for ( j = 0; j < terrorist_count; j++ )
								{
									terrorist = terrorists[j]

									if ( terrorist != player && AfkTime[terrorist] < BombActionTime )
									{
										entity_get_vector(terrorist, EV_VEC_origin, terrorist_origin)

										origins_distance = vector_distance(player_origin, terrorist_origin)

										if ( origins_distance < shortest_distance )
										{
											shortest_distance = origins_distance
											bomb_receiver = terrorist
										}
									}
								}
								if ( bomb_receiver )
								{
									c4_ent = get_ent_data_entity(player, CBasePlayer, "m_rgpPlayerItems", 5)
									if ( c4_ent > 0 )
									{
										engclient_cmd(player, "drop", "weapon_c4")

										backpack = entity_get_edict(c4_ent, EV_ENT_owner)

										if ( backpack > 0 && backpack != player )
										{
											entity_set_int(backpack, EV_INT_flags, entity_get_int(backpack, EV_INT_flags) | FL_ONGROUND)
											dllfunc(DLLFunc_Touch, backpack, bomb_receiver)

											get_user_name(player, player_name, charsmax(player_name))
											get_user_name(bomb_receiver, bomb_receiver_name, charsmax(bomb_receiver_name))

											if ( ColoredMessages )
											{
												for ( j = 0; j < terrorist_count; j++ )
												{
													terrorist = terrorists[j]

													if ( terrorist == bomb_receiver )
													{
														client_print_color(bomb_receiver, print_team_red, "%l", "COLORED_BOMB_GOT", player_name)
													}
													else
													{
														client_print_color(terrorist, print_team_red, "%l", "COLORED_BOMB_TRANSFERRED", bomb_receiver_name, player_name)
													}
												}
											}
											else
											{
												for ( j = 0; j < terrorist_count; j++ )
												{
													terrorist = terrorists[j]

													if ( terrorist == bomb_receiver )
													{
														client_print(bomb_receiver, print_chat, "%l", "BOMB_GOT", player_name)
													}
													else
													{
														client_print(terrorist, print_chat, "%l", "BOMB_TRANSFERRED", bomb_receiver_name, player_name)
													}
												}
											}
										}
									}
								}
							}
							else
							{
								engclient_cmd(player, "drop", "weapon_c4")

								get_user_name(player, player_name, charsmax(player_name))

								if ( ColoredMessages )
								{
									for ( j = 0; j < terrorist_count; j++ )
									{
										client_print_color(terrorists[j], print_team_red, "%l", "COLORED_FORCED_TO_DROP", player_name)
									}
								}
								else
								{
									for ( j = 0; j < terrorist_count; j++ )
									{
										client_print(terrorists[j], print_chat, "%l", "FORCED_TO_DROP", player_name)
									}
								}
							}
						}
					}
					if ( !cs_get_user_vip(player) )
					{
						if ( SwitchToSpecTime > 0.0 )
						{
							if ( afk_time >= SwitchToSpecTime && ( !SwitchToSpecImmunity || !has_all_flags(player, SwitchToSpecImmunityFlag) ) )
							{
								AfkTime[player] = 0.0

								get_user_name(player, player_name, charsmax(player_name))

								if ( ColoredMessages )
								{
									client_print_color(0, player, "%L", LANG_PLAYER, "COLORED_TRANSFERRED_TO_SPEC", player_name)
								}
								else
								{
									client_print(0, print_chat, "%L", LANG_PLAYER, "TRANSFERRED_TO_SPEC", player_name)
								}

								if ( is_player_alive )
								{
									deaths = cs_get_user_deaths(player)
									user_kill(player, 1)
									cs_set_user_deaths(player, deaths)
								}

								if ( allow_spectators != 1 )
								{
									set_pcvar_num(PcvarAllowSpecators, 1)
								}

								engclient_cmd(player, "joinclass", "6")
								engclient_cmd(player, "jointeam", "6")

								set_ent_data(player, CBasePlayer, "m_bTeamChanged", false)

								if ( allow_spectators != 1 )
								{
									set_pcvar_num(PcvarAllowSpecators, allow_spectators)
								}
							}
						}
						else if ( KickTime > 0.0 && afk_time >= KickTime && ( !KickImmunity || !has_all_flags(player, KickImmunityFlag) ) )
						{
							AfkTime[player] = 0.0

							get_user_name(player, player_name, charsmax(player_name))

							if ( ColoredMessages )
							{
								client_print_color(0, player, "%L", LANG_PLAYER, "COLORED_AFK_KICKED", player_name)
							}
							else
							{
								client_print(0, print_chat, "%L", LANG_PLAYER, "AFK_KICKED", player_name)
							}

							user_kick(player)
						}
					}
				}
			}
		}
	}

	if ( last_kick_id > 0 )
	{
		user_kick(last_kick_id)
	}

	if ( GlobalMessagesAwayTime > 0.0 )
	{
		if ( cts_afk > 0 && cts_not_afk == 0 && terrorists_not_afk > 0 )
		{
			if ( ColoredMessages )
			{
				set_dhudmessage(0, 50, 255, 0.02, 0.688, 0, 0.0, LoopFrequency, 0.0, 0.0)
			}
			else
			{
				set_dhudmessage(255, 255, 255, 0.02, 0.688, 0, 0.0, LoopFrequency, 0.0, 0.0)
			}

			get_players(players, player_count, "aceh", "TERRORIST")
			for ( i = 0; i < player_count; i++ )
			{
				show_dhudmessage(players[i], "%l", "ALL_CTS_AFK")
			}
		}
		else if ( terrorists_afk > 0 && terrorists_not_afk == 0 && cts_not_afk > 0 )
		{
			if ( ColoredMessages )
			{
				set_dhudmessage(255, 50, 0, 0.02, 0.688, 0, 0.0, LoopFrequency, 0.0, 0.0)
			}
			else
			{
				set_dhudmessage(255, 255, 255, 0.02, 0.688, 0, 0.0, LoopFrequency, 0.0, 0.0)
			}

			get_players(players, player_count, "aceh", "CT")
			for ( i = 0; i < player_count; i++ )
			{
				show_dhudmessage(players[i], "%l", "ALL_TERRORISTS_AFK")
			}
		}
	}
}

user_kick(id)
{
	AfkTime[id] = 0.0

	new name[MAX_NAME_LENGTH]
	get_user_name(id, name, charsmax(name))

	if ( ColoredMessages )
	{
		client_print_color(0, id, "%L", LANG_PLAYER, "COLORED_AFK_KICKED", name)
	}
	else
	{
		client_print(0, print_chat, "%L", LANG_PLAYER, "AFK_KICKED", name)
	}

	server_cmd("kick #%d ^"%L^"", UserID[id], id, "AFK_KICK_REASON")
}

// New Round
public Event_HLTV()
{
	RoundFreeze = true
}

public LogEvent_Round_Start()
{
	RoundFreeze = false
}

public Ham_Player_Spawn_Post(id)
{
	if ( CheckViewAngle > 0 && is_user_alive(id) )
	{
		// Getting the changing spawn v_angle with v_angle or angles here is unreliable due to how the game is coded
		SetViewAngleChanged(id)
	}
}
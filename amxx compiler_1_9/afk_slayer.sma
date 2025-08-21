#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"AFK Slayer"
#define VERSION	"1.0.0"
#define AUTHOR	"Maverick"

const Buttons = IN_ATTACK|IN_JUMP|IN_DUCK|IN_FORWARD|IN_BACK|IN_USE|IN_CANCEL|IN_LEFT|IN_RIGHT|IN_MOVELEFT|IN_MOVERIGHT|IN_ATTACK2|IN_RUN|IN_RELOAD|IN_ALT1|IN_SCORE

new Float:LoopFrequency
new Float:AfkTime[MAX_PLAYERS+1]
new Float:SlayTime

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	new pcvar = create_cvar("afk_slay_time", "30", FCVAR_NONE, "Time in seconds before slay", .has_min = true, .min_val = 0.0)
	bind_pcvar_float(pcvar, SlayTime)

	pcvar = create_cvar("afk_loop_frequency", "5.0", FCVAR_NONE, "Time in seconds, how often the check for AFK happens ", .has_min = true, .min_val = 1.0)
	bind_pcvar_float(pcvar, LoopFrequency)

    register_event("HLTV", "new_round", "a", "1=0", "2=0")	// New Round
}

public OnConfigsExecuted()
{
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

public afk_manager_loop(ent)
{
    if ( ent )
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + LoopFrequency)
	}

	static players[MAX_PLAYERS], player_count, player, player_name[MAX_NAME_LENGTH], CsTeams:player_team
    static Float:afk_time, deaths, is_player_alive
	get_players(players, player_count, "ch")

    for (new i = 0; i < player_count; i++ ) 
    {
        player = players[i]
        player_team = cs_get_user_team(player)
        is_player_alive = is_user_alive(player)

        if (player_team == CS_TEAM_CT && is_player_alive)
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

            if (afk_time >= SlayTime)
            {
                AfkTime[player] = 0.0
                get_user_name(player, player_name, charsmax(player_name))
                client_print_color(0, player, "^4[AFK]^3 %s^1 was slayed for being AFK.", player_name)

                deaths = cs_get_user_deaths(player)
                user_kill(player, 1)
                cs_set_user_deaths(player, deaths)
            }
        }
    }

}

public client_connect(id)
{
	AfkTime[id] = 0.0
}

public new_round()
{
	static players[MAX_PLAYERS], player_count, player
    get_players(players, player_count, "ch")

    for (new i = 0; i < player_count; i++ ) 
    {
        player = players[i]
        AfkTime[player] = 0.0
    }
}
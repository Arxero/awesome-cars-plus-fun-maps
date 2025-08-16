#include <amxmodx>
#include <amxmisc>

#define PLUGIN	"Block Titles"
#define VERSION "0.1"
#define AUTHOR	"Maverick"

new const blocked_titles[][] = {
	"Game_scoring",
	"Game_join_terrorist",
    "Game_join_ct",
    "Game_disconnected",
    "Game_connected",
    "DEAD",
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_message(get_user_msgid("TextMsg"), "handle_TextMsg");
	set_cvar_float("mp_roundtime", 2.0);
}

public handle_TextMsg(msg_id, msg_dest, msg_entity)
{
	static buffer[32];

	get_msg_arg_string(2, buffer, 31);

	for (new i = 0; i < sizeof blocked_titles; i++)
	{
        new title_with_tag[32] = "#"
        strcat(title_with_tag, blocked_titles[i], 32)

		if (equal(buffer, title_with_tag))
		{
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}
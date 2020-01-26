stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4") // Green Color
	replace_all(msg, 190, "!y", "^1") // Default Color
	replace_all(msg, 190, "!t", "^3") // Team Color
	replace_all(msg, 190, "!w", "^0") // Team2 Color
	
	if (id) players[0] = id; else get_players(players, count, "ch")
        {
	            for (new i = 0; i < count; i++)
	            {
		             if (is_user_connected(players[i]))
		             {
			     message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			     write_byte(players[i]);
			     write_string(msg);
			     message_end();
		             }
	            }
        }
}
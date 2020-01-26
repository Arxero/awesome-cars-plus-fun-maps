stock Chat(const id, const input[], any:...){
	new count = 1, players[32];
	static msg[ 191 ];
	vformat(msg, 190, input, 3);
	if (id) players[0] = id; else get_players(players , count , "ch"); {
		for (new i = 0; i < count; i++){
			if (is_user_connected(players[i])){
				message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end(); 
			}
		}
	}
}
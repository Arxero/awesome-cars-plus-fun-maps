// Gun Xp Mod Include File //
#if defined _gunxpmod_included
  #endinput
#endif
#define _gunxpmod_included

#if !defined charsmax
    #define charsmax(%1) sizeof(%1)-1
#endif 

// Returns player Experience.
native get_user_xp(id)

// Sets player Experience.
native set_user_xp(id, amount)

// Returns player Level.
native get_user_level(id)

// Sets player Level.
native set_user_level(id, amount)

// Returns player Level by Xp.
native get_user_max_level(id)

// Register Item.
stock find_itemplugin()
{
	for(new i = 0; i < get_pluginsnum(); ++i)
	{
		new temp[2], name[64]
		get_plugin(i, name, 63, temp, 1, temp, 1, temp, 1, temp, 1)
 		if(equali(name, "gunxpmod_shop.amxx")) {
 			return i;
		}
	}
 	return -1;
}

stock find_itemindex()
{
	new temp[2], name[64], pluginname[64]
	get_plugin(-1, pluginname, 63, temp, 1, temp, 1, temp, 1, temp, 1)
	for (new i = 0; i < get_pluginsnum(); ++i)
	{
		get_plugin(i, name, 63, temp, 1, temp, 1, temp, 1, temp, 1)
 		if(equal(name, pluginname))
		{
 			return i
		}
	}
 	return -1
}

stock register_gxm_item(item_name[], item_desc[], item_cost)
{
	new item_index = find_itemindex()
	new itemplugin = find_itemplugin()
	new itemregfunc = get_func_id("register_item_gxm", itemplugin)

	new temp = callfunc_begin_i(itemregfunc, itemplugin)
	if(temp == -1 || temp == -2)
	{
		if(temp == -2) 
		{
			log_amx("You have to many items, and need to increase the MAX_UNLOCKS define!")
		} 
		else 
		{
			log_amx("A unkown error has happend, make sure the Upgrades plugin is loaded!")
		}
		return PLUGIN_HANDLED;		
	}

	callfunc_push_int(item_index)
	callfunc_push_str(item_name)
	callfunc_push_str(item_desc)
	callfunc_push_int(item_cost)
	
	temp = callfunc_end()
	if(temp == -1 || temp == -2) 
	{
		return PLUGIN_HANDLED;
	}
	return temp;
}
stock client_printcolor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg,190,input,3);
	replace_all(msg,190,"/g","^4");// green txt
	replace_all(msg,190,"/y","^1");// orange txt
	replace_all(msg,190,"/ctr","^3");// team txt
	replace_all(msg,190,"/w","^0");// team txt
	if (id) players[0] = id; else get_players(players,count,"ch");
	for (new i=0;i<count;i++)
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
}	
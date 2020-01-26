#include <amxmodx>
#include <hamsandwich>
#include <cstrike>


#define PLUGIN "Trade Money"
#define VERSION "1.3"
#define AUTHOR "GlaDiuS"

new gidPlayer[33]
new bool:openmenu[33] 
new maxreqmenu[33], maxgivemenu[33]
new g_maxplayers
new g_msgSayText
new Item[900]

new Enable, maxreq, maxgive

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam( Ham_Spawn, "player", "fwSpawn", 1)
	
	register_clcmd("say /money", "MainMenu")
	register_clcmd("say .money", "MainMenu")
	register_clcmd("say !money", "MainMenu")
	
	
	register_dictionary("TradeMoney.txt")
	
	Enable = register_cvar("money_enable", "1")
	maxreq = register_cvar("money_maxrequest", "5")
	maxgive = register_cvar("money_maxgive", "5")
	
	g_maxplayers = get_maxplayers()
	g_msgSayText = get_user_msgid("SayText")
	
	register_clcmd("_PlayerMoney_", "Mplayer")
}

public client_putinserver(id) {
	openmenu[id] = false
	maxreqmenu[id] = 0
	maxgivemenu[id] = 0
}

public fwSpawn(id) {
	openmenu[id] = false
	maxreqmenu[id] = 0
	maxgivemenu[id] = 0
	Mplayer(id)
}

public MainMenu(id) {
	if(get_pcvar_num(Enable))
	{
		if( !openmenu[id] || is_user_alive(id)) {
			
			formatex(Item, charsmax(Item), "%L", id, "MAINMENUTITLE")
			new Menu = menu_create(Item, "MainHandler")
			
			formatex(Item, charsmax(Item), "%L", id, "MAINMENUITEM1")
			menu_additem(Menu, Item, "1")
			formatex(Item, charsmax(Item), "%L", id, "MAINMENUITEM2")
			menu_additem(Menu, Item, "2")
			
			formatex(Item, charsmax(Item), "%L", id, "EXIT")
			menu_setprop(Menu, MPROP_EXITNAME, Item)
			menu_display(id, Menu, 0)
			
			openmenu[id] = true
		}	
	}
	return PLUGIN_HANDLED
}

public MainHandler(id, Menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(Menu)
		openmenu[id] = false
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(Menu, item, access, data,5, iName, 63, callback)
	
	
	new key = str_to_num(data)
	switch (key)
	{
		case 1:
		{
			GiveMoneyMenu(id)
		}
		case 2:
		{
			RequestMoneyMenu(id)
		}
	}
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

public GiveMoneyMenu(id)
{
	if(maxgivemenu[id] <= get_pcvar_num(maxgive))
	{
		formatex(Item, charsmax(Item), "%L", id, "GIVEMENUTITLE")
		new wMenu = menu_create(Item, "GiveMoneyHandler")
		new Pos[3], Name[32]
		
		for (new i = 1; i <= g_maxplayers; i++)
		{
			if ((!is_user_connected(i)) || (cs_get_user_team(i) == CS_TEAM_SPECTATOR) || (i == id))
			{
				openmenu[id] = false
				continue
			}
			num_to_str(i, Pos, sizeof(Pos)-1)
			get_user_name(i, Name, sizeof(Name)-1)
			formatex(Item, charsmax(Item), "\w%s \r$%d", Name, cs_get_user_money(i))
			menu_additem(wMenu, Item, Pos)
		}
		formatex(Item, charsmax(Item), "%L", id, "EXIT")
		menu_setprop(wMenu, MPROP_EXITNAME, Item)
		menu_display(id, wMenu, 0)
	}
	else
	{
		ChatColor(id, "%L %L",id, "PREFIX", id, "LIMITOPEN", maxgivemenu[id])
	}
}

public GiveMoneyHandler(id, wMenu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(wMenu)
		openmenu[id] = false
		return PLUGIN_HANDLED
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(wMenu, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	new key = str_to_num(Data)
	gidPlayer[id] = key
	client_cmd(id, "messagemode _PlayerMoney_")
	maxgivemenu[id]++
	
	menu_destroy(wMenu)
	return PLUGIN_HANDLED
}

public RequestMoneyMenu(id)
{
	if(maxreqmenu[id] <= get_pcvar_num(maxreq))
	{
		formatex(Item, charsmax(Item), "%L", id, "REQMENUTITLE")
		new wMenu = menu_create(Item, "RequestMoneyHandler")
		new Pos[3], Name[32]
		
		for (new i = 1; i <= g_maxplayers; i++)
		{
			if (!is_user_connected(i) || (cs_get_user_team(i) == CS_TEAM_SPECTATOR) || i == id)
			{
				openmenu[id] = false
				continue
			}
			num_to_str(i, Pos, sizeof(Pos)-1)
			get_user_name(i, Name, sizeof(Name)-1)
			formatex(Item, charsmax(Item), "\w%s \r$%d", Name, cs_get_user_money(i))
			menu_additem(wMenu, Item, Pos)
		}
		formatex(Item, charsmax(Item), "%L", id, "EXIT")
		menu_setprop(wMenu, MPROP_EXITNAME, Item)
		menu_display(id, wMenu, 0)
	}
	else
	{
		ChatColor(id, "%L %L",id, "PREFIX", id, "LIMITOPEN", maxreqmenu[id])
	}
}

public RequestMoneyHandler(id, wMenu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(wMenu)
		openmenu[id] = false
		return PLUGIN_HANDLED
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(wMenu, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	new key = str_to_num(Data)
	gidPlayer[key] = id
	ConfirmationMenu(key)
	
	menu_destroy(wMenu)
	return PLUGIN_HANDLED
}

public ConfirmationMenu(id) {	
	new Name[32];get_user_name(gidPlayer[id], Name, 31)
	formatex(Item, charsmax(Item), "%L", id, "CONFMENUTITLE", Name)
	new Menu = menu_create(Item, "ConfirmationHandler")
	
	formatex(Item, charsmax(Item), "%L", id, "CONFMENUITEM1")
	menu_additem(Menu, Item, "1")
	formatex(Item, charsmax(Item), "%L", id, "CONFMENUITEM2")
	menu_additem(Menu, Item, "2")
	
	formatex(Item, charsmax(Item), "%L", id, "EXIT")
	menu_setprop(Menu, MPROP_EXITNAME, Item)
	menu_display(id, Menu, 0)
	
	return PLUGIN_HANDLED
}

public ConfirmationHandler(id, Menu, item)
{
	if (item == MENU_EXIT)
	{
		ConfirmationMenu(id)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[33]
	new access, callback
	menu_item_getinfo(Menu, item, access, data,5, iName, 63, callback)
	
	new Name[32]
	get_user_name(id,Name,31)
	get_user_name(gidPlayer[id], iName, 31)
	
	new key = str_to_num(data)
	switch (key)
	{
		case 1:
		{
			ChatColor(id, "%L %L",id, "PREFIX",id, "PLAYERACCEPT", iName)
			ChatColor(gidPlayer[id], "%L %L",id, "PREFIX", id, "TARGETACCEPT", Name)
			client_cmd(id, "messagemode _PlayerMoney_")
			maxreqmenu[id]++
		}
		case 2:
		{
			ChatColor(id, "%L %L",id, "PREFIX",id, "PLAYERREFUSE")
			ChatColor(gidPlayer[id], "%L %L",id, "PREFIX",id, "TARGETREFUSE", Name)
			openmenu[id] = false
		}
	}
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}

public Mplayer(id)
{
	if(get_pcvar_num(Enable))
	{
		new say[300] = 200
		read_args(say, charsmax(say))
		
		remove_quotes(say)
		
		if(!is_str_num(say) || equal(say, ""))
		{
			openmenu[id] = false;
			return PLUGIN_HANDLED
		}
		
		money(id, say)
		
		
	}
	return PLUGIN_HANDLED
}

public money(id, say[]) {
	new amount = str_to_num(say)
	new victim = gidPlayer[id]
	
	if( victim > 0 ) {
		new name[32], vname[32]
		new idMoney = cs_get_user_money(id)
		new vMoney = cs_get_user_money(victim)
		
		get_user_name(id, name, charsmax(name))
		get_user_name(victim, vname, 31)
		
		if(amount > idMoney)
		{
			ChatColor(id, "%L %L",id, "PREFIX",id, "ENOUGHMONEY")
			client_cmd(id, "messagemode _PlayerMoney_")
			return PLUGIN_HANDLED
		}
		
		else {
			cs_set_user_money(id, cs_get_user_money(id) - amount)
			cs_set_user_money(victim, cs_get_user_money(victim) + amount)
			
			if(vMoney > 16000)
			{
				cs_set_user_money(victim, 16000)
			}
			
			ChatColor(id, "%L %L",id, "PREFIX", id, "AMOUNTGIVE", amount, vname)
			ChatColor(victim, "%L %L",id, "PREFIX", id, "AMOUNTRECEIVE", name, amount)
		}
		openmenu[id] = false
	} 
	else {
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	if (id) players[0] = id
	else get_players(players, count, "ch")
	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1065\\ f0\\ fs16 \n\\ par }
*/

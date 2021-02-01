// Diablo II LoD Include File //
#if defined _diablo2LOD_included
  #endinput
#endif
#define _diablo2LOD_included

#define MAX_P_SKILLS 20

// Gets the max skills are loaded
native MAX_SKILLS_ACTIVE();
// Gets the max items are loaded
native MAX_ITEMS_ACTIVE();

// Hero class values
enum
{
	AMAZON = 0,
	ASSASSIN,
	NECROMANCER,
	BARBARIAN,
	PALADIN,
	DRUID,
	SORCERESS
}

// Log type values
enum
{
	UNLOGGED = 0,
	LOGGED
}

// Display value, while selecting skill 'E' button.
enum
{
	NOT_DISPLAY = 0,
	DISPLAY
}

// Item types
enum
{
	TYPE_GLOVES = 0,
	TYPE_BOOTS,
	TYPE_BELT,
	TYPE_ARMOR,
	TYPE_HELM,
	TYPE_SHIELD,
	TYPE_WEAPON,
	TYPE_RING,
	TYPE_AMULET,
	TYPE_BOLTS
}

// Called when you pressed E button and selected the skill.
forward d2_skill_selected(id, skill_id);

// Called when you fired a skill, bind t +skills.
forward d2_skill_fired(id);

// Called when player gets damaged, 1-st parameter is victim, 2-nd is attacker, 3-rd is Array parameter means damage done.
forward d2_takedamage(victim, attacker, Float:iDamage[1]);

// Called when player gets damaged by skill, 1-st parameter is victim, 2-nd is attacker, 3-rd is Array parameter means damage done.
forward d2_skill_takedamage(victim, attacker, Float:iDamage[1]);

// Called when player gets damaged by weapon with poison, 1-st parameter is victim, 2-nd is attacker, 3-rd is Array parameter means damage done.
forward d2_dagger_poisondamage(victim, attacker, Float:iDamage[1]);

// Called when player gets damaged by RANGED attack, 1-st parameter is victim, 2-nd is attacker, 3-rd is Array parameter means damage done.
forward d2_ranged_takedamage(victim, attacker, Float:iDamage[1]);

// Called when player successfully fires arrow, 1-st parameter is playerid, 2-nd is entityid.
forward d2_ranged_actshoot(id, entity);

// Called when the player is logged/unlogged.
forward d2_logged(id, log_type);

// Gets the player's current speed.
native Float:get_current_speed(id);

// if is player logged/unlogged.
native get_player_logged(id);

// Gets player's max health.
native get_p_maxhealth(id);

// Sets player's max health.
native set_p_maxhealth(id, value);

// Sets player xp with X value.
native set_p_xp(id, value);

// Gets player xp.
native get_p_xp(id);

// Gets player current hero.
native get_p_hero(id);

// Gets player level.
native get_p_level(id);

// Sets player current mana.
native set_p_mana(id, value);

// Gets player current mana.
native get_p_mana(id);

// Gets player vitality.
native get_p_vitality(id);

// Sets player vitality.
native set_p_vitality(id, value);

// Sets player gold.
native set_p_gold(id, value);

// Sets player inventory gold.
native set_p_gold_inventory(id, value);

// Gets player gold.
native get_p_gold(id);

// Gets player inventory gold.
native get_p_gold_inventory(id);

// Gets player skill's value.
native get_p_skill(id, skill_id);

// Resets player model to custom.
native reset_p_model(id);

// Gets player's current item count.
native get_p_item_count(id, item_id);

// If is player wear item returns true.
native get_p_item_is_worn(id, item_id);

// Gets if player wears any item with specified type
native bool:get_p_item_wear_type(id, type);

// Gets if player wears any item with specified data type
native bool:get_p_item_data(id, data);

// Gets if player is in safe zone ( Near Akara, Charsi, Inventory ).
native bool:get_p_in_safezone(id);

// Gets if is player protected, if spawn protection time passed.
native bool:is_p_protected(id);

// Checks if is a freezetime.
native is_freezetime();

// Checks if is player near monster
native bool:IsPlayerNearByMonster(id);

// Damages a player, 1-st parameter is victim, 2-nd is attacker, 3-rd is damage , 4-th is weapon type string.
native dmg_kill_player(id, attacker, Float:damage, weaponDescription[])

// Drops coins from give id/victim with specified classname and gold value stored in entity.
native drop_coins(victim, classname[], goldvalue);

// Sets user model.
native set_user_model(id, const model[]);

stock find_itemplugin()
{
	for(new i = 0; i < get_pluginsnum(); ++i)
	{
		new temp[2], name[64]
		get_plugin(i, name, 63, temp, 1, temp, 1, temp, 1, temp, 1)
 		if(equali(name, "diablo2LOD.amxx")) 
		{
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
stock register_d2_skill(skill_name[], skill_desc[], skill_hero, skill_level, skill_display)
{
	new SkillId = find_itemindex()
	new SkillPlugin = find_itemplugin()
	new SkillRegFunc = get_func_id("register_skill", SkillPlugin)

	new temp = callfunc_begin_i(SkillRegFunc, SkillPlugin)
	if(temp == -1 || temp == -2)
	{
		log_amx("Plugin not found or function is not executable!")
		return PLUGIN_HANDLED;		
	}

	callfunc_push_int(SkillId)
	callfunc_push_str(skill_name)
	callfunc_push_str(skill_desc)
	callfunc_push_int(skill_hero)
	callfunc_push_int(skill_level)
	callfunc_push_int(skill_display)
	
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

	if (id) players[0] = id; 
	else get_players(players,count,"ch");

	for (new i=0;i<count;i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <fun>

#define PLUGIN "Random weapons mode"
#define VERSION "2.0"
#define AUTHOR "beast"

#define TASKID_GUNS 2349
#define TASKID_BPAMMO 1224

#define OFFSET_PRIMARYWEAPON 116
#define OFFSET_C4_SLOT 372

#if cellbits == 32
	#define OFFSET_BUYZONE 235
#else
	#define OFFSET_BUYZONE 268
#endif

new cvar_random, cvar_bomb, cvar_nade, cvar_nodrop, cvar_checkmap, cvar_enabled
new g_mode
new const g_szBuyzone[] = "buyzone"
new Array:g_prim, Array:g_nades, Array:g_sec_sh, Array:g_sec

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("RRWM", VERSION, FCVAR_SPONLY | FCVAR_SERVER)
	register_message(get_user_msgid("StatusIcon"), "msgStatusIcon")
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	RegisterHam(Ham_Spawn, "player", "FwdHamPlayerSpawn", 1)
	register_clcmd("drop", "clcmd_drop")
	
	cvar_enabled = register_cvar("rrwm_enabled", "1")
	cvar_random = register_cvar("rrwm_chance", "10")
	cvar_bomb = register_cvar("rrwm_c4", "1")
	cvar_nade = register_cvar("rrwm_nade", "1")
	cvar_nodrop = register_cvar("rrwm_nodrop", "1")
	cvar_checkmap = register_cvar("rrwm_checkmap", "1")
		
	g_prim = ArrayCreate(256, 1)
	g_sec = ArrayCreate(128, 1)
	g_sec_sh = ArrayCreate(128, 1)
	g_nades = ArrayCreate(64, 1)
	
	if(get_pcvar_num(cvar_checkmap))
		check_map()
	
	loadini()
}

loadini()
{
	new path[96]
	get_configsdir(path, sizeof path - 1)
	format(path, sizeof path - 1, "%s/rrwm_weapons.ini", path)
	
	if (!file_exists(path))
	{
		log_amx("ERROR: Weapons list not found.") 
		return
	}
	
	new linedata[512], key[256], section
	new file = fopen(path, "rt")
	
	while(file && !feof(file))
	{
		fgets(file, linedata, sizeof linedata - 1)
		
		replace(linedata, sizeof linedata - 1, "^n", "")
		
		if(!linedata[0] || linedata[0] == ';')
			continue

		if (linedata[0] == '[')
		{
			section++
			continue
		}
		
		parse(linedata, key, sizeof key - 1)
		trim(key)
		
		switch(section)
		{
			case 1:
			{	
				format(key, sizeof key - 1, "weapon_%s", key)
				ArrayPushString(g_prim, key)
			}
			case 2:
			{	
				format(key, sizeof key - 1, "weapon_%s", key)
				ArrayPushString(g_sec, key)
			}
			case 3:
			{	
				format(key, sizeof key - 1, "weapon_%s", key)
				ArrayPushString(g_sec_sh, key)
			}
			case 4:
			{	
				format(key, sizeof key - 1, "weapon_%s", key)
				ArrayPushString(g_nades, key)
			}
		}
	}
	fclose(file)
}

check_map()
{
	new mapname[6]
	get_mapname(mapname,  5)
	
	if(containi(mapname, "ka_") != -1 || containi(mapname, "35hp_") != -1)
		pause("ad")
	
	return PLUGIN_CONTINUE
}

public clcmd_drop(id)
{
	if(g_mode && get_pcvar_num(cvar_nodrop))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public event_new_round()
{
	if(!get_pcvar_num(cvar_enabled))
		return
		
	g_mode = false
	
	if(random_num(1, get_pcvar_num(cvar_random)) == 1)
		g_mode = true
}

public FwdHamPlayerSpawn(id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	
	new r, g, b
	new Float:delay = random_float(1.0, 3.0)
	
	r = random_num(0, 255)
	g = random_num(0, 255)
	b = random_num(0, 255)
	
	if(g_mode)
	{	
		set_hudmessage(r, g, b, -1.0, 0.13, 1, 6.0, 5.0, 1.5, 3.0, -1)
		show_hudmessage(id, "!!! RANDOM WEAPONS MODE !!!")
		
		set_task(delay, "guns", TASKID_GUNS + id)
		set_task(3.1, "bpammo", TASKID_BPAMMO + id)
	}
	return HAM_IGNORED
}

public guns(task)
{
	new id = task - TASKID_GUNS
	new mapname[4]
	get_mapname(mapname, 3)
	
	if(!is_user_alive(id))
		return
		
	if(get_pcvar_num(cvar_bomb) && containi(mapname, "de_") != -1)
		StripUserWeapons(id)
	
	else
		strip_user_weapons(id)
	
	new p_weap[32]
	new s_weap[32]
	new sh_weap[32]
	new nades[32]
	
	ArrayGetString(g_prim, random_num(0, ArraySize(g_prim) - 1), p_weap, sizeof p_weap - 1)
	ArrayGetString(g_sec, random_num(0, ArraySize(g_sec) - 1), s_weap, sizeof s_weap - 1)
	ArrayGetString(g_sec_sh, random_num(0, ArraySize(g_sec_sh) - 1), sh_weap, sizeof sh_weap - 1)
	ArrayGetString(g_nades, random_num(0, ArraySize(g_nades) - 1), nades, sizeof nades - 1)
	
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
	
	give_item(id, "weapon_knife")
	give_item(id, p_weap)

	if(cs_get_user_shield(id))
		give_item(id, sh_weap)
	
	else
		give_item(id, s_weap)
	
	if(get_pcvar_num(cvar_nade))
		give_item(id, nades)
}

public bpammo(task)
{
	new id = task - TASKID_BPAMMO
	static weapons[32], num, i, weaponid
	new fbnum = random_num(1,2)
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
			
		switch(weaponid)
		{
			case CSW_XM1014: cs_set_user_bpammo(id, CSW_XM1014, 32)
			case CSW_MAC10: cs_set_user_bpammo(id, CSW_MAC10, 100)
			case CSW_AUG: cs_set_user_bpammo(id, CSW_AUG, 90)
			case CSW_UMP45: cs_set_user_bpammo(id, CSW_UMP45, 100)
			case CSW_SG550: cs_set_user_bpammo(id, CSW_SG550, 90)
			case CSW_GALIL: cs_set_user_bpammo(id, CSW_GALIL, 90)
			case CSW_FAMAS: cs_set_user_bpammo(id, CSW_FAMAS, 90)
			case CSW_MP5NAVY: cs_set_user_bpammo(id, CSW_MP5NAVY, 120)
			case CSW_M249: cs_set_user_bpammo(id, CSW_M249, 200)
			case CSW_M3: cs_set_user_bpammo(id, CSW_M3, 32)
			case CSW_M4A1: cs_set_user_bpammo(id, CSW_M4A1, 90)
			case CSW_G3SG1: cs_set_user_bpammo(id, CSW_G3SG1, 90)
			case CSW_SG552: cs_set_user_bpammo(id, CSW_SG552, 90)
			case CSW_AK47: cs_set_user_bpammo(id, CSW_AK47, 90)
			case CSW_P90: cs_set_user_bpammo(id, CSW_P90, 100)
			case CSW_SCOUT: cs_set_user_bpammo(id, CSW_SCOUT, 90)
			case CSW_AWP: cs_set_user_bpammo(id, CSW_AWP, 30)
			case CSW_TMP: cs_set_user_bpammo(id, CSW_TMP, 120)
			case CSW_DEAGLE: cs_set_user_bpammo(id, CSW_DEAGLE, 35)
			case CSW_GLOCK18: cs_set_user_bpammo(id, CSW_GLOCK18, 120)
			case CSW_USP: cs_set_user_bpammo(id, CSW_USP, 100)
			case CSW_ELITE: cs_set_user_bpammo(id, CSW_ELITE, 120)
			case CSW_FIVESEVEN: cs_set_user_bpammo(id, CSW_FIVESEVEN, 100)
			case CSW_P228: cs_set_user_bpammo(id, CSW_P228, 52)
			case CSW_FLASHBANG: cs_set_user_bpammo(id, CSW_FLASHBANG, fbnum)
		}
	}	
}

public msgStatusIcon(iMsgId, iMsgDest, id)
{	
	static szMsg[8]
	get_msg_arg_string(2, szMsg, 7)
	
	return PLUGIN_CONTINUE
}

StripUserWeapons(id)
{
	new iC4Ent = get_pdata_cbase(id, OFFSET_C4_SLOT)
	
	if(iC4Ent > 0)
		set_pdata_cbase(id, OFFSET_C4_SLOT, FM_NULLENT)

	strip_user_weapons(id)
	set_pdata_int(id, OFFSET_PRIMARYWEAPON, 0)

	if(iC4Ent > 0)
	{
		entity_set_int(id, EV_INT_weapons, entity_get_int(id, EV_INT_weapons) | (1<<CSW_C4))
		set_pdata_cbase(id, OFFSET_C4_SLOT, iC4Ent)
		cs_set_user_bpammo(id, CSW_C4, 1)
		cs_set_user_plant(id, 1)
	}
	return PLUGIN_HANDLED
}

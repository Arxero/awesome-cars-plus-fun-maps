#include <amxmodx>
#include <hamsandwich>

#define PLUGIN	"Custom Hud"
#define AUTHOR	"trofian"
#define VERSION	"1.1"

#define c_weapon_old_string 64
#define c_weapon_new_string 64

new const
bytes_shift = 8,
weapons[][] = {
	"weapon_p228",			"weapon_scout",			"weapon_hegrenade",	"weapon_xm1014",	"weapon_c4",	"weapon_mac10",
	"weapon_aug",			"weapon_smokegrenade",		"weapon_elite",		"weapon_fiveseven",	"weapon_ump45",	"weapon_sg550",
	"weapon_galil",			"weapon_famas",			"weapon_usp",		"weapon_glock18",	"weapon_awp",	"weapon_mp5navy",
	"weapon_m249",			"weapon_m3",			"weapon_m4a1",		"weapon_tmp",		"weapon_g3sg1",	"weapon_flashbang",
	"weapon_deagle",		"weapon_sg552",			"weapon_ak47",		"weapon_knife",		"weapon_p90"
},

dump_bytes[] = {
	9, 	52, -1, -1, 1, 3, 1,  0,	// weapon_p228
	2, 	90, -1, -1, 0, 9, 3,  0,	// weapon_scout
	12, 1, 	-1, -1, 3, 1, 4,  24,	// weapon_hegrenade
	5, 	32, -1, -1, 0, 12,5,  0,	// weapon_xm1014
	14, 1, 	-1, -1, 4, 3, 6,  24,	// weapon_c4
	6, 	100,-1, -1, 0, 13,7,  0,	// weapon_mac10
	4, 	90, -1, -1, 0, 14,8,  0,	// weapon_aug
	13, 1, 	-1, -1, 3, 3, 9,  24,	// weapon_smokegrenade
	10, 120,-1, -1, 1, 5, 10, 0,	// weapon_elite
	7, 	100,-1, -1, 1, 6, 11, 0,	// weapon_fiveseven
	6, 	100,-1, -1, 0, 15,12, 0,	// weapon_ump45
	4, 	90, -1, -1, 0, 16,13, 0,	// weapon_sg550
	4, 	90, -1, -1, 0, 17,14, 0,	// weapon_galil
	4, 	90, -1, -1, 0, 18,15, 0,	// weapon_famas
	6, 	100,-1, -1, 1, 4, 16, 0,	// weapon_usp
	10,	120,-1, -1, 1, 2, 17, 0,	// weapon_glock18
	1, 	30, -1, -1, 0, 2, 18, 0, 	// weapon_awp
	10, 120,-1, -1, 0, 7, 19, 0, 	// weapon_mp5navy
	3,	200,-1, -1, 0, 4, 20, 0,	// weapon_m249
	5,	32, -1, -1, 0, 5, 21, 0,	// weapon_m3
	4,	90, -1, -1, 0, 6, 22, 0,	// weapon_m4a1
	10,	120,-1, -1, 0, 11,23, 0,	// weapon_tmp
	2,	90, -1, -1, 0, 3, 24, 0,	// weapon_g3sg1
	11,	2,	-1, -1, 3, 2, 25, 24,	// weapon_flashbang
	8,	35, -1, -1, 1, 1, 26, 0,	// weapon_deagle
	4,	90, -1, -1, 0, 10,27, 0,	// weapon_sg552
	2,	90, -1, -1, 0, 1, 28, 0,	// weapon_ak47
	-1,	-1,	-1,	-1, 2, 1, 29, 0,	// weapon_knife
	7, 100, -1, -1, 0, 8, 30, 0		// weapon_p90
}

new
g_msgWeaponList, Array:gaOldWeapon, Array:gaNewWeapon

public plugin_natives()
{
	register_native("n21_register_hud", "_n21_register_hud", 0) // 1 - стандартное оружие (weapon_), 2 - новое оружие
	register_native("n21_hud_change_to", "_n21_change_to", 0) // 1 - id игрока, 2 - стандартное оружие (weapon_), 3 - новое оружие (ручная смена худа)
}

public plugin_precache()
{
	gaOldWeapon = ArrayCreate(c_weapon_old_string)
	gaNewWeapon = ArrayCreate(c_weapon_new_string)
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_msgWeaponList = get_user_msgid("WeaponList")
	set_task(2.0, "register_client_switches")
}

public register_client_switches()
{
	new Size = ArraySize(gaNewWeapon)
	new reg_str[c_weapon_new_string]
	new reg_str_old_weapon[c_weapon_old_string]
	new switch_str[256]
	
	for(new i; i<Size; i++)
	{
		ArrayGetString(gaNewWeapon, i, reg_str, charsmax(reg_str))
		ArrayGetString(gaOldWeapon, i, reg_str_old_weapon, charsmax(reg_str_old_weapon))
		format(switch_str, charsmax(switch_str), "switch_to_%s", reg_str_old_weapon)
		register_clcmd(reg_str, switch_str)
		server_print("[%s] Register: ^"%s^"", PLUGIN, reg_str)
	}
}

public switch_gun(id, next_gun_name[]) engclient_cmd(id, next_gun_name)

public set_custom_hud(id, old_gun[], new_gun[])
{
	new mul
	
	for (new i; i <= charsmax(weapons); i++)
	{
		if(equal(old_gun, weapons[i]))
		{
			mul = i
			break
		}
	}
	
	message_begin(MSG_ONE, g_msgWeaponList, _, id)
	write_string(new_gun)
	for(new i; i <= 7; i++)
		write_byte(dump_bytes[mul*bytes_shift+i])
	message_end()
}

public _n21_register_hud(plugin, num_params)
{
	new olg_gun[c_weapon_old_string]
	get_string(1, olg_gun, charsmax(olg_gun))
	
	new bool:isset = false
	
	for (new i; i <= charsmax(weapons); i++)
	{
		if(equal(olg_gun, weapons[i]))
		{
			isset = true
			break
		}
	}
	
	if(!isset) return 0
	
	new new_gun[c_weapon_new_string]
	get_string(2, new_gun, charsmax(new_gun))

	ArrayPushString(gaNewWeapon, new_gun)
	ArrayPushString(gaOldWeapon, olg_gun)
	
	return 1
}

public _n21_change_to(plugin, num_params)
{
	new id = get_param(1)
	
	new old_gun[c_weapon_old_string]
	get_string(2, old_gun, charsmax(old_gun))
	
	new new_gun[c_weapon_new_string]
	get_string(3, new_gun, charsmax(new_gun))
	
	new iSize = ArraySize(gaNewWeapon)
	new sTmpBuffer[c_weapon_new_string]
	
	if(equal(old_gun, new_gun))
	{
		set_custom_hud(id, old_gun, old_gun)
		return 1
	}
	
	for (new i; i < iSize; i++)
	{
		ArrayGetString(gaNewWeapon, i, sTmpBuffer, charsmax(sTmpBuffer))
		
		if(equal(new_gun, sTmpBuffer))
		{
			set_custom_hud(id, old_gun, new_gun)
			return 1
		}
	}
	
	return 0
}

public switch_to_weapon_p228(id) switch_gun(id, "weapon_p228")
public switch_to_weapon_scout(id) switch_gun(id, "weapon_scout")
public switch_to_weapon_hegrenade(id) switch_gun(id, "weapon_hegrenade")
public switch_to_weapon_xm1014(id) switch_gun(id, "weapon_xm1014")
public switch_to_weapon_c4(id) switch_gun(id, "weapon_c4")
public switch_to_weapon_mac10(id) switch_gun(id, "weapon_mac10")
public switch_to_weapon_weapon_aug(id) switch_gun(id, "weapon_weapon_aug")
public switch_to_weapon_smokegrenade(id) switch_gun(id, "weapon_smokegrenade")
public switch_to_weapon_elite(id) switch_gun(id, "weapon_elite")
public switch_to_weapon_fiveseven(id) switch_gun(id, "weapon_fiveseven")
public switch_to_weapon_ump45(id) switch_gun(id, "weapon_ump45")
public switch_to_weapon_sg550(id) switch_gun(id, "weapon_sg550")
public switch_to_weapon_galil(id) switch_gun(id, "weapon_galil")
public switch_to_weapon_famas(id) switch_gun(id, "weapon_famas")
public switch_to_weapon_usp(id) switch_gun(id, "weapon_usp")
public switch_to_weapon_glock18(id) switch_gun(id, "weapon_glock18")
public switch_to_weapon_awp(id) switch_gun(id, "weapon_awp")
public switch_to_weapon_mp5navy(id) switch_gun(id, "weapon_mp5navy")
public switch_to_weapon_m249(id) switch_gun(id, "weapon_m249")
public switch_to_weapon_m3(id) switch_gun(id, "weapon_m3")
public switch_to_weapon_m4a1(id) switch_gun(id, "weapon_m4a1")
public switch_to_weapon_tmp(id) switch_gun(id, "weapon_tmp")
public switch_to_weapon_g3sg1(id) switch_gun(id, "weapon_g3sg1")
public switch_to_weapon_flashbang(id) switch_gun(id, "weapon_flashbang")
public switch_to_weapon_deagle(id) switch_gun(id, "weapon_deagle")
public switch_to_weapon_sg552(id) switch_gun(id, "weapon_sg552")
public switch_to_weapon_ak47(id) switch_gun(id, "weapon_ak47")
public switch_to_weapon_knife(id) switch_gun(id, "weapon_knife")
public switch_to_weapon_p90(id) switch_gun(id, "weapon_p90")

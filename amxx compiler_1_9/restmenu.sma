/* AMX Mod X
*   Restrict Weapons Plugin
Basically its the AMX Dev's Teams Restrict Weapon plugin with some modifications.

The default plugin only prevents players from buying weapons. But restricted weapons
could still be picked up in maps such as fy_iceworld.

The modified plugin can replace all restricted weapons of a particular type with a
weapon of another type. Example all AWP's can be turned into Scouts. All Auto Shotguns
can be turned into M3's.

Hence players have no way to get a restricted weapon.

When playing with bots however the bots are not affected by the restrictions and can
buy any weapon. So if a bot buys a restricted weapon, the bot automatically drops it.

In this case a player can pick up the restricted weapon which the bot dropped. So to
prevent this, if a player gets his hands on a restricted weapon somehow it is
automatically dropped.

DUE CREDITS:

Weapon drop logic borrowed from MagicShot's Advanced Weapon Restriction plugin.

Weapon remove / replace function suggested by AndraX2000.

get_model_name() function borrowed from Cheap_Suit's Backweapons Plugin because I
was too lazy to write all those 24 Switch-Case statements myself.

INSTRUCTIONS:

To restrict a weapon, simply use the default Restrict Weapon menu in AMX Mod X.

By default, any restricted weapons lying around the map are removed.

To replace them with another weapon you must change the corresponding CVAR.

amx_restrict_replace_awp "scout"
amx_restrict_replace_g3sg1 "m4a1"
etc.

YOU CANNOT CHANGE A PRIMARY WEAPON INTO A SECONDARY WEAPON.

amx_restrict_replace_awp "deagle"
will cause the plugin to fail to replace any weapons at all.

*   
*   Modifications put together by Torch a.k.a. Kurian Abraham
*
*  by the AMX Mod X Development Team
*  originally developed by OLO
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation, 
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve, 
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

// Uncomment if you want to have seperate settings for each map
//#define MAPSETTINGS

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>

#define MAXMENUPOS 34

new const weaponname[31][] =
{
	"none",
	"p228",
	"none",
	"scout",
	"none",
	"xm1014",
	"none",
	"mac10",
	"aug",
	"none",
	"elites",
	"fn57",
	"ump45",
	"sg550",
	"galil",
	"none",
	"usp",
	"glock",
	"awp",
	"mp5",
	"m249",
	"m3",
	"m4a1",
	"tmp",
	"g3sg1",
	"none",
	"deagle",
	"sg552",
	"ak47",
	"knife",
	"p90"
}

findWeaponId(name[])
{
	for (new i = 0; i < 31 ; ++i)
		if (equali(name, weaponname[i]))
			return i
	
	return -1
}

new ent_ubound = -1;
new deleted_weapons[1024]
new Float:org_x[1024]
new Float:org_y[1024]
new Float:org_z[1024]
new Float:ang_x[1024]
new Float:ang_y[1024]
new Float:ang_z[1024]

new g_Position[33]
new g_Modified
new g_blockPos[112]
new g_saveFile[64]
new g_Restricted[] = "* This item is restricted *"
new g_szWeapRestr[27] = "00000000000000000000000000"
new g_szWeapIdRestr[31] = "000000000000000000000000000000"
new g_szEquipAmmoRestr[10] = "000000000"

new g_menusNames[7][] =
{
	"pistol", 
	"shotgun", 
	"sub", 
	"rifle", 
	"machine", 
	"equip", 
	"ammo"
}

new g_MenuTitle[7][] =
{
	"Handguns", 
	"Shotguns", 
	"Sub-Machine Guns", 
	"Assault & Sniper Rifles", 
	"Machine Guns", 
	"Equipment", 
	"Ammunition"
}

new g_menusSets[7][2] =
{
	{0, 6}, {6, 8}, {8, 13}, {13, 23}, {23, 24}, {24, 32}, {32, 34}
}

new g_AliasBlockNum
new g_AliasBlock[MAXMENUPOS]

// First position is a position of menu (0 for ammo, 1 for pistols, 6 for equipment etc.)
// Second is a key for TERRORIST (all is key are minus one, 1 is 0, 2 is 1 etc.)
// Third is a key for CT
// Position with -1 doesn't exist

new g_Keys[MAXMENUPOS][3] =
{
	{1, 1, 1},	// H&K USP .45 Tactical
	{1, 0, 0},	// Glock18 Select Fire
	{1, 3, 3},	// Desert Eagle .50AE
	{1, 2, 2},	// SIG P228
	{1, 4, -1}, // Dual Beretta 96G Elite
	{1, -1, 4}, // FN Five-Seven
	{2, 0, 0},	// Benelli M3 Super90
	{2, 1, 1},	// Benelli XM1014
	{3, 1, 1},	// H&K MP5-Navy
	{3, -1, 0}, // Steyr Tactical Machine Pistol
	{3, 3, 3},	// FN P90
	{3, 0, -1}, // Ingram MAC-10
	{3, 2, 2},	// H&K UMP45
	{4, 1, -1}, // AK-47
	{4, 0, -1}, // Gali
	{4, -1, 0}, // Famas
	{4, 3, -1}, // Sig SG-552 Commando
	{4, -1, 2}, // Colt M4A1 Carbine
	{4, -1, 3}, // Steyr Aug
	{4, 2, 1},	// Steyr Scout
	{4, 4, 5},	// AI Arctic Warfare/Magnum
	{4, 5, -1}, // H&K G3/SG-1 Sniper Rifle
	{4, -1, 4}, // Sig SG-550 Sniper
	{5, 0, 0},	// FN M249 Para
	{6, 0, 0},	// Kevlar Vest
	{6, 1, 1},	// Kevlar Vest & Helmet
	{6, 2, 2},	// Flashbang
	{6, 3, 3},	// HE Grenade
	{6, 4, 4},	// Smoke Grenade
	{6, -1, 6}, // Defuse Kit
	{6, 5, 5},	// NightVision Goggles
	{6, -1, 7},	// Tactical Shield
	{0, 5, 5},	// Primary weapon ammo
	{0, 6, 6}	// Secondary weapon ammo
}

new g_WeaponNames[MAXMENUPOS][] =
{
	"H&K USP .45 Tactical", 
	"Glock18 Select Fire", 
	"Desert Eagle .50AE", 
	"SIG P228", 
	"Dual Beretta 96G Elite", 
	"FN Five-Seven", 
	"Benelli M3 Super90", 
	"Benelli XM1014", 
	"H&K MP5-Navy", 
	"Steyr Tactical Machine Pistol", 
	"FN P90", 
	"Ingram MAC-10", 
	"H&K UMP45", 
	"AK-47", 
	"Gali", 
	"Famas", 
	"Sig SG-552 Commando", 
	"Colt M4A1 Carbine", 
	"Steyr Aug", 
	"Steyr Scout", 
	"AI Arctic Warfare/Magnum", 
	"H&K G3/SG-1 Sniper Rifle", 
	"Sig SG-550 Sniper", 
	"FN M249 Para", 
	"Kevlar Vest", 
	"Kevlar Vest & Helmet", 
	"Flashbang", 
	"HE Grenade", 
	"Smoke Grenade", 
	"Defuse Kit", 
	"NightVision Goggles", 
	"Tactical Shield", 
	"Primary weapon ammo", 
	"Secondary weapon ammo"
}

new g_MenuItem[MAXMENUPOS][] =
{
	"\yHandguns^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\yShotguns^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\ySub-Machine Guns^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\yAssault Rifles^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\ySniper Rifles^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\yMachine Guns^n\w^n%d. %s\y\R%L^n\w^n", 

	"\yEquipment^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w^n", 

	"\yAmmunition^n\w^n%d. %s\y\R%L^n\w", 
	"%d. %s\y\R%L^n\w"
}

new g_Aliases[MAXMENUPOS][] =
{
	"usp",		//Pistols
	"glock", 
	"deagle", 
	"p228", 
	"elites", 
	"fn57", 

	"m3",		//Shotguns
	"xm1014", 

	"mp5",		//SMG
	"tmp", 
	"p90", 
	"mac10", 
	"ump45", 

	"ak47",		//Rifles
	"galil", 
	"famas", 
	"sg552", 
	"m4a1", 
	"aug", 
	"scout", 
	"awp", 
	"g3sg1", 
	"sg550", 

	"m249",		//Machine Gun

	"vest",		//Equipment
	"vesthelm", 
	"flash", 
	"hegren", 
	"sgren", 
	"defuser", 
	"nvgs", 
	"shield", 

	"primammo", //Ammo
	"secammo"
}

findWeaponIdFromAMXId(a)
{
	for (new i = 0; i < 31 ; ++i)
		if (equali(g_Aliases[a], weaponname[i]))
			return i
	
	return -1
}

new g_Aliases2[MAXMENUPOS][] =
{
	"km45",		//Pistols
	"9x19mm", 
	"nighthawk", 
	"228compact", 
	"elites", 
	"fiveseven", 

	"12gauge",	//Shotguns
	"autoshotgun", 

	"smg",		//SMG
	"mp", 
	"c90", 
	"mac10", 
	"ump45", 

	"cv47",		//Rifles
	"defender", 
	"clarion", 
	"krieg552", 
	"m4a1", 
	"bullpup", 
	"scout", 
	"magnum", 
	"d3au1", 
	"krieg550", 

	"m249",		//Machine Gun

	"vest",		//Equipment
	"vesthelm", 
	"flash", 
	"hegren", 
	"sgren", 
	"defuser", 
	"nvgs", 
	"shield", 
	"primammo", //Ammo
	"secammo"
}

#define AUTOBUYLENGTH 511
new g_Autobuy[33][AUTOBUYLENGTH + 1]
//new g_Rebuy[33][AUTOBUYLENGTH + 1]

setWeapon(a, action)
{
	new b, m = g_Keys[a][0] * 8
	
	if (g_Keys[a][1] != -1)
	{
		b = m + g_Keys[a][1]
		
		if (action == 2)
			g_blockPos[b] = 1 - g_blockPos[b]
		else
			g_blockPos[b] = action
	}

	if (g_Keys[a][2] != -1)
	{
		b = m + g_Keys[a][2] + 56
		
		if (action == 2)
			g_blockPos[b] = 1 - g_blockPos[b]
		else
			g_blockPos[b] = action
	}

	for (new i = 0; i < g_AliasBlockNum; ++i)
		if (g_AliasBlock[i] == a)
		{
			if (!action || action == 2)
			{
				--g_AliasBlockNum
				
				for (new j = i; j < g_AliasBlockNum; ++j)
					g_AliasBlock[j] = g_AliasBlock[j + 1]
			}
			
			return
		}

	if (action && g_AliasBlockNum < MAXMENUPOS)
		g_AliasBlock[g_AliasBlockNum++] = a
}

findMenuId(name[])
{
	for (new i = 0; i < 7 ; ++i)
		if (equali(name, g_menusNames[i]))
			return i
	
	return -1
}

findAliasId(name[])
{
	for (new i = 0; i < MAXMENUPOS ; ++i)
		if (equali(name, g_Aliases[i]))
			return i
	
	return -1
}

switchCommand(id, action)
{
	new c = read_argc()

	if (c < 3)
	{
		for (new x = 0; x < MAXMENUPOS; x++)
			setWeapon(x, action)		

		console_print(id, "%L", id, action ? "EQ_WE_RES" : "EQ_WE_UNRES")
		g_Modified = true
	} else {
		new arg[32], a
		new bool:found = false
		
		for (new b = 2; b < c; ++b)
		{
			read_argv(b, arg, 31)
			
			if ((a = findMenuId(arg)) != -1)
			{
				c = g_menusSets[a][1]
				
				for (new i = g_menusSets[a][0]; i < c; ++i)
					setWeapon(i, action)
				
				console_print(id, "%s %L %L", g_MenuTitle[a], id, (a < 5) ? "HAVE_BEEN" : "HAS_BEEN", id, action ? "RESTRICTED" : "UNRESTRICTED")
				g_Modified = found = true
			}
			else if ((a = findAliasId(arg)) != -1)
			{
				g_Modified = found = true
				setWeapon(a, action)
				console_print(id, "%s %L %L", g_WeaponNames[a], id, "HAS_BEEN", id, action ? "RESTRICTED" : "UNRESTRICTED")
			}
		}

		if (!found)
			console_print(id, "%L", id, "NO_EQ_WE")
	}
}

positionBlocked(a)
{
	new m = g_Keys[a][0] * 8
	new d = (g_Keys[a][1] == -1) ? 0 : g_blockPos[m + g_Keys[a][1]]
	
	d += (g_Keys[a][2] == -1) ? 0 : g_blockPos[m + g_Keys[a][2] + 56]
	
	return d
}

public cmdRest(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	new cmd[8]
	
	read_argv(1, cmd, 7)
	
	if (equali("on", cmd))
		switchCommand(id, 1)
	else if (equali("off", cmd))
		switchCommand(id, 0)
	else if (equali("list", cmd))
	{
		new arg1[8]
		new	start = read_argv(2, arg1, 7) ? str_to_num(arg1) : 1
		
		if (--start < 0)
			start = 0
		
		if (start >= MAXMENUPOS)
			start = MAXMENUPOS - 1
		
		new end = start + 10
		
		if (end > MAXMENUPOS)
			end = MAXMENUPOS
		
		new lName[16], lValue[16], lStatus[16], lOnOff[16]
		
		format(lName, 15, "%L", id, "NAME")
		format(lValue, 15, "%L", id, "VALUE")
		format(lStatus, 15, "%L", id, "STATUS")
		
		console_print(id, "^n----- %L: -----", id, "WEAP_RES")
		console_print(id, "     %-32.31s   %-10.9s   %-9.8s", lName, lValue, lStatus)
		
		if (start != -1)
		{
			for (new a = start; a < end; ++a)
			{
				format(lOnOff, 15, "%L", id, positionBlocked(a) ? "ON" : "OFF")
				console_print(id, "%3d: %-32.31s   %-10.9s   %-9.8s", a + 1, g_WeaponNames[a], g_Aliases[a], lOnOff)
			}
		}
		
		console_print(id, "----- %L -----", id, "REST_ENTRIES_OF", start + 1, end, MAXMENUPOS)
		
		if (end < MAXMENUPOS)
			console_print(id, "----- %L -----", id, "REST_USE_MORE", end + 1)
		else
			console_print(id, "----- %L -----", id, "REST_USE_BEGIN")
	}
	else if (equali("save", cmd))
	{
		if (saveSettings(g_saveFile))
		{
			console_print(id, "%L", id, "REST_CONF_SAVED", g_saveFile)
			g_Modified = false
		}
		else
			console_print(id, "%L", id, "REST_COULDNT_SAVE", g_saveFile)
	}
	else if (equali("load", cmd))
	{
		setc(g_blockPos, 112, 0)	// Clear current settings
		new arg1[64]

		if (read_argv(2, arg1, 63))
		{
			new configsdir[32]
			get_configsdir(configsdir, 31)

			format(arg1, 63, "%s/%s", configsdir, arg1)
		}
		
		if (loadSettings(arg1))
		{
			console_print(id, "%L", id, "REST_CONF_LOADED", arg1)
			g_Modified = true
		}
		else
			console_print(id, "%L", id, "REST_COULDNT_LOAD", arg1)
	} else {
		console_print(id, "%L", id, "COM_REST_USAGE")
		console_print(id, "%L", id, "COM_REST_COMMANDS")
		console_print(id, "%L", id, "COM_REST_ON")
		console_print(id, "%L", id, "COM_REST_OFF")
		console_print(id, "%L", id, "COM_REST_ONV")
		console_print(id, "%L", id, "COM_REST_OFFV")
		console_print(id, "%L", id, "COM_REST_LIST")
		console_print(id, "%L", id, "COM_REST_SAVE")
		console_print(id, "%L", id, "COM_REST_LOAD")
		console_print(id, "%L", id, "COM_REST_VALUES")
		console_print(id, "%L", id, "COM_REST_TYPE")
	}

	return PLUGIN_HANDLED
}

displayMenu(id, pos)
{
	if (pos < 0)
		return

	new menubody[512], start = pos * 7

	if (start >= MAXMENUPOS)
		start = pos = g_Position[id] = 0

	new len = format(menubody, 511, "\y%L\R%d/5^n^n\w", id, "REST_WEAP", pos + 1)
	new end = start + 7, keys = MENU_KEY_0|MENU_KEY_8, k = 0

	if (end > MAXMENUPOS)
		end = MAXMENUPOS

	for (new a = start; a < end; ++a)
	{
		keys |= (1<<k)
		len += format(menubody[len], 511 - len, g_MenuItem[a], ++k, g_WeaponNames[a], id, positionBlocked(a) ? "ON" : "OFF")
	}

	len += format(menubody[len], 511 - len, "^n8. %L \y\R%s^n\w", id, "SAVE_SET", g_Modified ? "*" : "")

	if (end != MAXMENUPOS)
	{
		format(menubody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menubody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menubody, -1, "Restrict Weapons")
}

public actionMenu(id, key)
{
	switch (key)
	{
		case 7:
		{
			if (saveSettings(g_saveFile))
			{
				g_Modified = false
				client_print(id, print_chat, "* %L", id, "CONF_SAV_SUC")
			}
			else
				client_print(id, print_chat, "* %L", id, "CONF_SAV_FAIL")

			displayMenu(id, g_Position[id])
		}
		case 8: displayMenu(id, ++g_Position[id])
		case 9: displayMenu(id, --g_Position[id])
		default:
		{
			setWeapon(g_Position[id] * 7 + key, 2)
			g_Modified = true
			displayMenu(id, g_Position[id])

			new a = g_Position[id] * 7 + key
			new sz[1]
			new b

			if (a < 24)
			{
				sz[0] = g_szWeapRestr[a + 1]
				g_szWeapRestr[a + 1] = (sz[0] == '0') ? '1' : '0'  // primary and secondary weapons
			}
			else if ((a >= 24) && (a < 31))
			{
				sz[0] = g_szEquipAmmoRestr[a - 24]
				g_szEquipAmmoRestr[a - 24] = (sz[0] == '0') ? '1' : '0'  // equipments
			}
			else if (a == 31)
			{
				sz[0] = g_szWeapRestr[25]
				g_szWeapRestr[25] = (sz[0] == '0') ? '1' : '0'  // shield
			}
			else if ((a > 31) && (a < 34))
			{
				sz[0] = g_szEquipAmmoRestr[a - 25]
				g_szEquipAmmoRestr[a - 25] = (sz[0] == '0') ? '1' : '0'   // primary and secondary ammo
			}
			
			if ((b = findWeaponIdFromAMXId(a)) != -1)
			{
				g_szWeapIdRestr[b] = g_szWeapRestr[a + 1]
			}

			set_cvar_string("amx_restrweapons", g_szWeapRestr)
			set_cvar_string("amx_restrequipammo", g_szEquipAmmoRestr)
		}
	}

	return PLUGIN_HANDLED
}

public client_command(id)
{
	if (g_AliasBlockNum)
	{
		new arg[13]

		if (read_argv(0, arg, 12) > 11)		/* Longest buy command has 11 chars so if command is longer then don't care */
			return PLUGIN_CONTINUE

		new a = 0

		do
		{
			if (equali(g_Aliases[g_AliasBlock[a]], arg) || equali(g_Aliases2[g_AliasBlock[a]], arg))
			{
				client_print(id, print_center, "%s", g_Restricted)
				return PLUGIN_HANDLED
			}
		} while (++a < g_AliasBlockNum)
	}
	
	return PLUGIN_CONTINUE
}

public blockcommand(id)
{
	client_print(id, print_center, "%s", g_Restricted)
	return PLUGIN_HANDLED
}

public cmdMenu(id, level, cid)
{
	if (cmd_access(id, level, cid, 1))
			displayMenu(id, g_Position[id] = 0)
	
	return PLUGIN_HANDLED
}

checkRest(id, menu, key)
{
	new team = get_user_team(id)
	
	if (team != 1 && team != 2)
		return PLUGIN_HANDLED
	
	if (g_blockPos[(menu * 8 + key) + (get_user_team(id) - 1) * 56])
	{
		engclient_cmd(id, "menuselect", "10")
		client_print(id, print_center, "%s", g_Restricted)
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public ammoRest1(id)		return checkRest(id, 0, 5)
public ammoRest2(id)        return checkRest(id, 0, 6)
public menuBuy(id, key)     return checkRest(id, 0, key)
public menuPistol(id, key)  return checkRest(id, 1, key)
public menuShotgun(id, key) return checkRest(id, 2, key)
public menuSub(id, key)     return checkRest(id, 3, key)
public menuRifle(id, key)   return checkRest(id, 4, key)
public menuMachine(id, key) return checkRest(id, 5, key)
public menuItem(id, key)    return checkRest(id, 6, key)

saveSettings(filename[])
{
	if (file_exists(filename))
		delete_file(filename)

	if (!write_file(filename, "; Generated by Restrict Weapons Plugin. Do not modify!^n; value name"))
		return 0

	new text[64]

	for (new a = 0; a < MAXMENUPOS; ++a)
	{
		if (positionBlocked(a))
		{
			format(text, 63, "%-16.15s ; %s", g_Aliases[a], g_WeaponNames[a])
			write_file(filename, text)
		}
	}

	return 1
}

loadSettings(filename[])
{
	if (!file_exists(filename))
		return 0

	new text[16]
	new a, pos = 0, b

	format(g_szEquipAmmoRestr, 9, "000000000")
	format(g_szWeapRestr, 26, "00000000000000000000000000")
	format(g_szWeapIdRestr, 30, "000000000000000000000000000000")

	while (read_file(filename, pos++, text, 15, a))
	{
		if (text[0] == ';' || !a)
			continue	// line is a comment
		
		parse(text, text, 15)
		
		if ((a = findAliasId(text)) != -1)
		{
			setWeapon(a, 1)
			if (a < 24) g_szWeapRestr[a + 1] = '1' // primary and secondary weapons
			else if ((a >= 24) && (a < 31)) g_szEquipAmmoRestr[a - 24] = '1'  // equipments
			else if (a == 31) g_szWeapRestr[25] = '1'  // shield
			else if ((a > 31) && (a < 34)) g_szEquipAmmoRestr[a - 25] = '1'  // primary and secondary ammo
			
			if ((b = findWeaponId(text)) != -1)
			{
				g_szWeapIdRestr[b] = '1'
			}
		}
	}
	set_cvar_string("amx_restrweapons", g_szWeapRestr)
	set_cvar_string("amx_restrequipammo", g_szEquipAmmoRestr)

	return 1
}

// JGHG
public fn_setautobuy(id)
{
	// Empty user's autobuy prefs. (unnecessary?)
	g_Autobuy[id][0] = '^0'

	new argCount = read_argc()
	new arg[128]
	new autobuyLen = 0
	
	for (new i = 1; i < argCount; i++)		// Start at parameter 1; parameter 0 is just "cl_setautobuy"
	{
		read_argv(i, arg, 127)
		// Add this parameter to user's autobuy prefs
		autobuyLen += format(g_Autobuy[id][autobuyLen], AUTOBUYLENGTH - autobuyLen, "%s", arg)
		
		// If we detect more parameters, add a space
		if (i + 1 < argCount)
			autobuyLen += format(g_Autobuy[id][autobuyLen], AUTOBUYLENGTH - autobuyLen, " ")
	}

	if (g_AliasBlockNum)
	{
		// Strip any blocked items
		new strippedItems[AUTOBUYLENGTH + 1]
	
		if (!StripBlockedItems(g_Autobuy[id], strippedItems))
			return PLUGIN_CONTINUE				// don't touch anything if we didn't strip anything...

		//server_print("Stripped items: ^"%s^"", strippedItems)
		engclient_cmd(id, "cl_setautobuy", strippedItems)

		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

// Returns true if this strips any items, else false.
StripBlockedItems(inString[AUTOBUYLENGTH + 1], outString[AUTOBUYLENGTH + 1])
{
	// First copy string
	format(outString, AUTOBUYLENGTH, inString)

	// After that convert all chars in string to lower case (fix by VEN)
	strtolower(outString)

	// Then strip those that are blocked.
	for (new i = 0; i < g_AliasBlockNum; i++)
	{
		while (containi(outString, g_Aliases[g_AliasBlock[i]]) != -1)
			replace(outString, AUTOBUYLENGTH, g_Aliases[g_AliasBlock[i]], "")
		while (containi(outString, g_Aliases2[g_AliasBlock[i]]) != -1)
			replace(outString, AUTOBUYLENGTH, g_Aliases2[g_AliasBlock[i]], "")
	}

	// We COULD trim white space from outString here, but I don't think it really is necessary currently...
	if (strlen(outString) < strlen(inString))
		return true							// outstring is shorter: we stripped items, return true

	return false							// else end here, return false, no items were stripped
}

public fn_autobuy(id)
{
	// Don't do anything if no items are blocked.
	if (!g_AliasBlockNum)
		return PLUGIN_CONTINUE

	// Strip any blocked items
	new strippedItems[AUTOBUYLENGTH + 1]
	
	if (!StripBlockedItems(g_Autobuy[id], strippedItems))
		return PLUGIN_CONTINUE				// don't touch anything if we didn't strip anything...

	engclient_cmd(id, "cl_setautobuy", strippedItems)
	
	return PLUGIN_HANDLED
}

public get_model_name(weaponID, returnString[], returnLen)
{
	new modelName
	switch(weaponID)
	{
		case CSW_AK47: 		modelName = format(returnString, returnLen, "models/w_ak47.mdl")
		case CSW_AUG: 		modelName = format(returnString, returnLen, "models/w_aug.mdl")
		case CSW_AWP: 		modelName = format(returnString, returnLen, "models/w_awp.mdl")
		case CSW_DEAGLE:	modelName = format(returnString, returnLen, "models/w_deagle.mdl")
		case CSW_ELITE:		modelName = format(returnString, returnLen, "models/w_elite.mdl")
		case CSW_FAMAS: 	modelName = format(returnString, returnLen, "models/w_famas.mdl")
		case CSW_FIVESEVEN:	modelName = format(returnString, returnLen, "models/w_fiveseven.mdl")
		case CSW_G3SG1: 	modelName = format(returnString, returnLen, "models/w_g3sg1.mdl")
		case CSW_GLOCK18:	modelName = format(returnString, returnLen, "models/w_glock18.mdl")
		case CSW_GALIL: 	modelName = format(returnString, returnLen, "models/w_galil.mdl")
		case CSW_M249: 		modelName = format(returnString, returnLen, "models/w_m249.mdl")
		case CSW_M3: 		modelName = format(returnString, returnLen, "models/w_m3.mdl")
		case CSW_M4A1: 		modelName = format(returnString, returnLen, "models/w_m4a1.mdl")
		case CSW_MAC10:		modelName = format(returnString, returnLen, "models/w_mac10.mdl")
		case CSW_MP5NAVY: 	modelName = format(returnString, returnLen, "models/w_mp5navy.mdl")
		case CSW_P228:		modelName = format(returnString, returnLen, "models/w_p228.mdl")
		case CSW_P90: 		modelName = format(returnString, returnLen, "models/w_p90.mdl")
		case CSW_SCOUT: 	modelName = format(returnString, returnLen, "models/w_scout.mdl")
		case CSW_SG550: 	modelName = format(returnString, returnLen, "models/w_sg550.mdl")
		case CSW_SG552: 	modelName = format(returnString, returnLen, "models/w_sg552.mdl")
		case CSW_TMP:		modelName = format(returnString, returnLen, "models/w_tmp.mdl")
		case CSW_UMP45: 	modelName = format(returnString, returnLen, "models/w_ump45.mdl")
		case CSW_USP:		modelName = format(returnString, returnLen, "models/w_usp.mdl")
		case CSW_XM1014: 	modelName = format(returnString, returnLen, "models/w_xm1014.mdl")
		default:		modelName = format(returnString, returnLen, "none")
	}
	return modelName
}

public replacerestricted() {
	new Float:org[3]
	
	for (new i = 0; i <= ent_ubound; ++i)
	{
		new ent = create_entity("armoury_entity")
		new modelname[32]
		get_model_name(deleted_weapons[i],modelname,31)
		org[0] = org_x[i]
		org[1] = org_y[i]
		org[2] = org_z[i]
		entity_set_origin(ent, org)
		org[0] = ang_x[i]
		org[1] = ang_y[i]
		org[2] = ang_z[i]
		entity_set_vector(ent,EV_VEC_angles,org)
		cs_set_armoury_type(ent, deleted_weapons[i])
		DispatchSpawn(ent)

	}
	ent_ubound = -1
	
	new entindex = -1
	new weaponid
	while ((entindex = find_ent_by_class(entindex,"armoury_entity")))
	{
		if(!((weaponid = cs_get_armoury_type(entindex)) < 31))
		{
			continue
		}
		
		if (g_szWeapIdRestr[weaponid] == '1') {
			new replaceid
			new replacename[32]
			new modelname[32]
			new cvarname[32]
			
			format(cvarname,31,"amx_restrict_replace_%s",weaponname[weaponid])
			get_cvar_string(cvarname,replacename,31)
						
			if ((equali(replacename,"none",4)) || ((replaceid = findWeaponId(replacename)) == -1))
			{
				ent_ubound++
				deleted_weapons[ent_ubound] = weaponid
				entity_get_vector(entindex,EV_VEC_origin,org)
				org_x[ent_ubound] = org[0]
				org_y[ent_ubound] = org[1]
				org_z[ent_ubound] = org[2]
				entity_get_vector(entindex,EV_VEC_angles,org)
				ang_x[ent_ubound] = org[0]
				ang_x[ent_ubound] = org[1]
				ang_z[ent_ubound] = org[2]
				remove_entity(entindex)
			}
			else
			{
				get_model_name(replaceid,modelname,31)
				if(!(equali(modelname,"none",4)))
				{
					cs_set_armoury_type(entindex, replaceid)
					entity_set_model(entindex, modelname)
				}
			}
			
			
			
		}
	}
	return PLUGIN_HANDLED
}

public drop_weapon(params[],id) {
	new player = params[0]
	new weaponid = params[1]
	new wpname[32]
	get_weaponname(weaponid,wpname,31)
	engclient_cmd(player,"drop",wpname)
	return PLUGIN_HANDLED
}

public disarm(id) {
	new weaponid, ammo, wep
	weaponid = get_user_weapon(id,wep,ammo)
	
	if (g_szWeapIdRestr[weaponid] == '1')
	{
		client_print(id, print_center, "%s", g_Restricted)
		new params[2]
		params[0]=id
		params[1]=weaponid
		set_task(1.0,"drop_weapon",0,params,2,"a",1)
		
	}
	
	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Restrict Weapons", AMXX_VERSION_STR, "AMXX Dev Team")
	register_dictionary("restmenu.txt")
	register_dictionary("common.txt")
	register_clcmd("buyammo1", "ammoRest1")
	register_clcmd("buyammo2", "ammoRest2")
	register_clcmd("cl_setautobuy", "fn_setautobuy")
	register_clcmd("cl_autobuy", "fn_autobuy")
	register_clcmd("amx_restmenu", "cmdMenu", ADMIN_CFG, "- displays weapons restriction menu")
	register_menucmd(register_menuid("#Buy", 1), 511, "menuBuy")
	register_menucmd(register_menuid("Restrict Weapons"), 1023, "actionMenu")
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menuPistol")
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menuShotgun")
	register_menucmd(register_menuid("BuySub", 1), 511, "menuSub")
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menuRifle")
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menuMachine")
	register_menucmd(register_menuid("BuyItem", 1), 511, "menuItem")
	register_menucmd(-28, 511, "menuBuy")
	register_menucmd(-29, 511, "menuPistol")
	register_menucmd(-30, 511, "menuShotgun")
	register_menucmd(-32, 511, "menuSub")
	register_menucmd(-31, 511, "menuRifle")
	register_menucmd(-33, 511, "menuMachine")
	register_menucmd(-34, 511, "menuItem")
	register_concmd("amx_restrict", "cmdRest", ADMIN_CFG, "- displays help for weapons restriction")

	register_cvar("amx_restrweapons", "00000000000000000000000000")
	register_cvar("amx_restrequipammo", "000000000")
	
	register_cvar("amx_restrict_replace_p228","")
	register_cvar("amx_restrict_replace_scout","")
	register_cvar("amx_restrict_replace_xm1014","")
	register_cvar("amx_restrict_replace_mac10","")
	register_cvar("amx_restrict_replace_aug","")
	register_cvar("amx_restrict_replace_elites","")
	register_cvar("amx_restrict_replace_fn57","")
	register_cvar("amx_restrict_replace_ump45","")
	register_cvar("amx_restrict_replace_sg550","")
	register_cvar("amx_restrict_replace_galil","")
	register_cvar("amx_restrict_replace_usp","")
	register_cvar("amx_restrict_replace_glock","")
	register_cvar("amx_restrict_replace_awp","")
	register_cvar("amx_restrict_replace_mp5","")
	register_cvar("amx_restrict_replace_m249","")
	register_cvar("amx_restrict_replace_m3","")
	register_cvar("amx_restrict_replace_m4a1","")
	register_cvar("amx_restrict_replace_tmp","")
	register_cvar("amx_restrict_replace_g3sg1","")
	register_cvar("amx_restrict_replace_deagle","")
	register_cvar("amx_restrict_replace_sg552","")
	register_cvar("amx_restrict_replace_ak47","")
	register_cvar("amx_restrict_replace_p90","")

	new configsDir[64];
	get_configsdir(configsDir, 63);
#if defined MAPSETTINGS
	new mapname[32]
	get_mapname(mapname, 31)
	format(g_saveFile, 63, "%s/weaprest_%s.ini", configsDir, mapname)
#else
	format(g_saveFile, 63, "%s/weaprest.ini", configsDir)
#endif
	loadSettings(g_saveFile)
	
	register_event("CurWeapon","disarm","b","1=1")
	register_logevent("replacerestricted", 2, "0=World triggered", "1=Round_Start")
}

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colorchat>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <engine>

#define PLUGIN "Deathrace: Crates"
#define VERSION "1.2"
#define AUTHOR "Xalus"

#define PREFIX "^4[Deathrace]"

forward deathrace_crate_hit(id, ent);
forward deathrace_win(id, Float:flTime);

enum _:enumCrateinfo
{
	CRATEINFO_NAME[32],
	CRATEINFO_NEWNAME[32],
	
	CRATEINFO_AMOUNT,
	CRATEINFO_MAXUSE
}
enum _:enumCratelist
{
	CRATE_SPEED,
	CRATE_HENADE,
	CRATE_UZI,
	CRATE_SHIELD,
	CRATE_GODMODE,
	CRATE_GRAVITY,
	CRATE_HEALTH,
	CRATE_ARMOR,
	CRATE_FROST,
	CRATE_SMOKE,
	CRATE_DEATH,
	CRATE_DRUGS,
	CRATE_SHAKE,
	CRATE_FREEZE,
	CRATE_RANDOM
}
new const g_arrayCrate[enumCratelist][enumCrateinfo] =
{
	{"speedcrate",		"extra speed", 		400, 	2}, // Amount: Speed
	{"hecrate", 		"a hegrenade",		1, 	2}, // Amount: Nades
	{"uzicrate", 		"an uzi",		3, 	2}, // Amount: Bullets
	{"shieldcrate", 	"a shield",		1, 	2}, // Amount: Nothing
	{"godmodecrate",	"godmode",		10, 	2}, // Amount: Seconds
	{"gravitycrate", 	"gravity",		560, 	2}, // Amount: Gravity
	{"hpcrate", 		"extra health",		50,	3}, // Amount: Health
	{"armorcrate",		"extra armor",		50,	3}, // Amount: Armor
	{"frostcrate",		"a frostgrenade", 	1, 	2}, // Amount: Nades
	{"smokecrate",		"a smokegrenade", 	1, 	2}, // Amount: Nades
	{"deathcrate",		"death",		1,	0}, // Amount: Nothing
	{"drugcrate",		"drugs",		10,	0}, // Amount: Seconds
	{"shakecrate",		"an hangover",		0, 	0}, // Amount: Nothing
	{"freezecrate",		"a body freeze",	50, 	0}, // Amount: Speed
	{"randomcrate",		"a random crate",	1,	2}  // Amount: Nothing
}
new Trie:g_trieCrates	

new g_arrayCrateamount[33][enumCratelist]
new g_arrayCrateactive[33][enumCratelist]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Register: Ham
	RegisterHam(Ham_Item_PreFrame, "player", "Ham_PlayerResetMaxSpeed_Post", 1)
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1)
	
	// Install: Crates
	g_trieCrates = TrieCreate()
	
	for(new i = 0; i < enumCratelist; i++)
	{
		TrieSetCell(g_trieCrates, g_arrayCrate[i][CRATEINFO_NAME], i)
	}
}
// Public: Deathrace
public deathrace_crate_hit(id, entity)
{
	static strTargetname[32];
	pev(entity, pev_targetname, strTargetname, charsmax(strTargetname));
	
	if(TrieKeyExists(g_trieCrates, strTargetname))
	{
		static intCrate;
		TrieGetCell(g_trieCrates, strTargetname, intCrate);
		
		return crate_touch(id, intCrate)
	}
	return 0
}

// Public: Ham
public Ham_PlayerResetMaxSpeed_Post(id)
{
	if(is_user_alive(id)
	&& (g_arrayCrateactive[id][CRATE_SPEED] || g_arrayCrateactive[id][CRATE_FREEZE]))
	{
		set_user_maxspeed(id, float(g_arrayCrate[ g_arrayCrateactive[id][CRATE_SPEED] ? CRATE_SPEED : CRATE_FREEZE ][CRATEINFO_AMOUNT]))
	}
}
public Ham_PlayerSpawn_Post(id)
{
	if(is_user_alive(id))
	{
		arrayset(g_arrayCrateamount[id], 0, enumCratelist)
		arrayset(g_arrayCrateactive[id], 0, enumCratelist)
	}
}

// Public: Tasks
public Task_Timer(arrayTemp[2])
{
	new id, crateid;
	id = arrayTemp[0];
	crateid = arrayTemp[1];

	if(is_user_connected(id))
	{
		g_arrayCrateactive[id][crateid] = 0;
		
		switch(crateid)
		{
			case CRATE_GODMODE:
			{
				set_user_godmode(id);
			}
			case CRATE_GRAVITY:
			{
				set_user_gravity(id);
			}
			case CRATE_DRUGS:
			{
				message_setfov(id);
			}
			case CRATE_FREEZE, CRATE_SPEED:
			{
				ExecuteHamB(Ham_Item_PreFrame, id);
			}
		}
	}
}
	

// Stock: Messages
stock message_setfov(id, amount=90)
{
	static intMsgSetFOV;
	if(intMsgSetFOV || (intMsgSetFOV = get_user_msgid("SetFOV")))
	{
		message_begin(MSG_ONE, intMsgSetFOV, {0,0,0}, id);
		write_byte(amount);
		message_end();
	}
}
stock message_screenshake(id)
{
	static intMsgScreenShake;
	if(intMsgScreenShake || (intMsgScreenShake = get_user_msgid("ScreenShake")))
	{
		message_begin(MSG_ONE, intMsgScreenShake, {0,0,0}, id);
		write_short(255<<14);
		write_short(10<<14);
		write_short(255<<14);
		message_end();
	}
}

// Stock
stock crate_touch(id, crateid, bool:randomcrate=false)
{
	if(g_arrayCrate[crateid][CRATEINFO_MAXUSE]
	&& ++g_arrayCrateamount[id][crateid] > g_arrayCrate[crateid][CRATEINFO_MAXUSE]
	&& !randomcrate)
		return HAM_IGNORED;
	
	switch(crateid)
	{
		case CRATE_SPEED: 
		{
			g_arrayCrateactive[id][CRATE_FREEZE] = 0
			
			set_user_maxspeed(id, float(g_arrayCrate[crateid][CRATEINFO_AMOUNT]));
			set_timer(id, crateid, 3.0)
		}
		case CRATE_HENADE: 
		{
			give_weapon(id, CSW_HEGRENADE, g_arrayCrate[crateid][CRATEINFO_AMOUNT]);
		}
		case CRATE_UZI:
		{
			give_weapon(id, CSW_TMP, g_arrayCrate[crateid][CRATEINFO_AMOUNT]);
		}
		case CRATE_SHIELD: 
		{
			give_item(id, "weapon_shield");
		}
		case CRATE_GODMODE:
		{
			set_user_godmode(id, 1);
			set_timer(id, crateid);
		}	
		case CRATE_GRAVITY:
		{
			set_user_gravity(id, (float(g_arrayCrate[crateid][CRATEINFO_AMOUNT]) / 800.0))
			set_timer(id, crateid, 10.0);
		}
		case CRATE_HEALTH: 
		{
			set_user_health(id, min(get_user_health(id) + g_arrayCrate[crateid][CRATEINFO_AMOUNT], 100));
		}
		case CRATE_ARMOR: 
		{
			set_user_armor(id, min(get_user_armor(id) + g_arrayCrate[crateid][CRATEINFO_AMOUNT], 100));
		}
		case CRATE_FROST: 
		{
			give_weapon(id, CSW_FLASHBANG, g_arrayCrate[crateid][CRATEINFO_AMOUNT]);
		}
		case CRATE_SMOKE: 
		{
			give_weapon(id, CSW_SMOKEGRENADE, g_arrayCrate[crateid][CRATEINFO_AMOUNT]);
		}
		case CRATE_DEATH: 
		{
			if(get_user_godmode(id)
			|| randomcrate)
			{
				g_arrayCrateamount[id][crateid]--
				return HAM_IGNORED
			}
			user_kill(id);
		}
		case CRATE_DRUGS:
		{
			message_setfov(id, 170);
			set_timer(id, crateid);
		}	
		case CRATE_SHAKE:
		{
			message_screenshake(id);
		}
		case CRATE_FREEZE:
		{
			g_arrayCrateactive[id][CRATE_SPEED] = 0;
			
			set_user_maxspeed(id, float(g_arrayCrate[crateid][CRATEINFO_AMOUNT]));
			set_timer(id, crateid, 2.0);
		}
		case CRATE_RANDOM:
		{
			crate_touch(id, random(CRATE_RANDOM), true);
			return HAM_IGNORED;
		}
		default:
		{
			return HAM_IGNORED;
		}
	}
	ColorChat(id, GREY, "%s^1 You pickedup%s^3 %s^1.", PREFIX, randomcrate ? " a random crate and received" : "", g_arrayCrate[crateid][CRATEINFO_NEWNAME]);
	
	return HAM_IGNORED;
}
stock set_timer(id, crateid, Float:flTime=0.0)
{
	new arrayTemp[2];
	arrayTemp[0] = id;
	arrayTemp[1] = crateid;
	
	g_arrayCrateactive[id][crateid]++;
	
	if(!flTime)
	{
		flTime = float(g_arrayCrate[crateid][CRATEINFO_AMOUNT]);
	}
	set_task(flTime, "Task_Timer", 15151, arrayTemp, sizeof(arrayTemp))
}
stock give_weapon(id, weaponid, amount)
{
	if(user_has_weapon(id, weaponid))
	{
		cs_set_user_bpammo(id, weaponid, (cs_get_user_bpammo(id, weaponid) + amount));
		return 1;
	}
	static strWeaponname[32];
	get_weaponname(weaponid, strWeaponname, charsmax(strWeaponname));
	
	new entity;
	if( (entity = give_item(id, strWeaponname))
	&& amount)
	{
		cs_set_weapon_ammo(entity, amount);
	}
	return 1
}

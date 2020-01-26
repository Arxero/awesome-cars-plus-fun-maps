#if defined _fm_cstrike_included || defined _cstrike_included
	#endinput
#endif

#define _cstrike_included
#define _fm_cstrike_included


#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>


#define EXTRAOFFSET			5
#define EXTRAOFFSET_WEAPONS		4
#define ACTUAL_EXTRA_OFFSET		20


// "weapon_*" offsets
#define OFFSET_WEAPONID			43
#define OFFSET_WEAPONCLIP		52
#define OFFSET_SILENCER_FIREMODE	74


// "player" offsets
#define OFFSET_ARMORTYPE		112
#define OFFSET_TEAM			114
#define OFFSET_MONEY			115
#define OFFSET_PRIMWEAPON		116
#define OFFSET_LASTACTIVITY		124
#define OFFSET_INTERALMODEL		126
#define OFFSET_NVGOGGLES		129
#define OFFSET_BOMB_DEFUSE		193
#define OFFSET_ISVIP			209
#define OFFSET_TKED			216
#define OFFSET_HOSTAGEKILLS		217
#define OFFSET_MAPZONE			235
#define OFFSET_DRIVING			350
#define OFFSET_STATIONARY		362
enum
{
	OFFSET_AMMO_AWP = 377,
	OFFSET_AMMO_SCOUT, // AK47, G3SG1
	OFFSET_AMMO_M249,
	OFFSET_AMMO_M4A1, // FAMAS, AUG, SG550, GALIL, SG552
	OFFSET_AMMO_M3, // XM1014
	OFFSET_AMMO_USP, // UMP45, MAC10
	OFFSET_AMMO_FIVESEVEN, // P90
	OFFSET_AMMO_DEAGLE,
	OFFSET_AMMO_P228,
	OFFSET_AMMO_GLOCK18, // MP5NAVY, TMP, ELITE
	OFFSET_AMMO_FLASHBANG,
	OFFSET_AMMO_HEGRENADE,
	OFFSET_AMMO_SMOKEGRENADE,
	OFFSET_AMMO_C4
};
#define OFFSET_SHIELD			510
#define OFFSET_DEATHS			555


// "hostage_entity" offsets
#define OFFSET_HOSTAGEFOLLOW		86
#define OFFSET_HOSTAGENEXTUSE		100
#define OFFSET_HOSTAGELASTUSE		483
#define OFFSET_HOSTAGEID		487


// "armoury_entity" offsets
#define OFFSET_CSATYPE			34


// C4 offsets
#define OFFSET_C4_EXPLODETIME		100
#define OFFSET_C4_DEFUSING		0x181


stock fm_cs_get_user_deaths(client)
{
	return get_pdata_int(client, OFFSET_DEATHS, EXTRAOFFSET);
}

stock fm_cs_set_user_deaths(client, deaths)
{
	set_pdata_int(client, OFFSET_DEATHS, deaths, EXTRAOFFSET);
	
	static ScoreInfo;
	if( ScoreInfo || (ScoreInfo = get_user_msgid("ScoreInfo")) )
	{
		emessage_begin(MSG_BROADCAST, ScoreInfo);
		ewrite_byte(client);
		ewrite_short(get_user_frags(client));
		ewrite_short(deaths);
		ewrite_short(0);
		ewrite_short(_:fm_cs_get_user_team(client));
		emessage_end();
	}
}

stock fm_cs_get_hostage_foll(entity)
{
	return get_pdata_int(entity, OFFSET_HOSTAGEFOLLOW, EXTRAOFFSET);
}

stock fm_cs_set_hostage_foll(entity, followentity=0)
{
	set_pdata_int(entity, OFFSET_HOSTAGEFOLLOW, followentity, EXTRAOFFSET);
}

stock fm_cs_get_hostage_id(entity)
{
	return get_pdata_int(entity, OFFSET_HOSTAGEID, EXTRAOFFSET);
}

static const _CSW_to_offset[] =
{
	0, OFFSET_AMMO_P228, OFFSET_AMMO_SCOUT, OFFSET_AMMO_HEGRENADE, OFFSET_AMMO_M3, OFFSET_AMMO_C4, OFFSET_AMMO_USP, OFFSET_AMMO_SMOKEGRENADE,
	OFFSET_AMMO_GLOCK18, OFFSET_AMMO_FIVESEVEN, OFFSET_AMMO_USP, OFFSET_AMMO_M4A1, OFFSET_AMMO_M4A1, OFFSET_AMMO_M4A1, OFFSET_AMMO_USP, OFFSET_AMMO_GLOCK18,
	OFFSET_AMMO_AWP, OFFSET_AMMO_GLOCK18, OFFSET_AMMO_M249, OFFSET_AMMO_M3, OFFSET_AMMO_M4A1, OFFSET_AMMO_GLOCK18, OFFSET_AMMO_SCOUT, OFFSET_AMMO_FLASHBANG,
	OFFSET_AMMO_DEAGLE, OFFSET_AMMO_M4A1, OFFSET_AMMO_SCOUT, 0, OFFSET_AMMO_FIVESEVEN
};

stock fm_cs_get_user_bpammo(client, weapon)
{
	return get_pdata_int(client, _CSW_to_offset[weapon], EXTRAOFFSET);
}

stock fm_cs_set_user_bpammo(client, weapon, ammo)
{
	set_pdata_int(client, _CSW_to_offset[weapon], ammo, EXTRAOFFSET);
}

#define HAS_DEFUSE_KIT			(1<<16)

stock fm_cs_get_user_defuse(client)
{
	return (get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET) & HAS_DEFUSE_KIT) ? 1 : 0;
}

stock fm_cs_set_user_defuse(client, defusekit=1, r=0, g=160, b=0, icon[]="defuser", flash=0)
{
	static StatusIcon;
	
	new kit = get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET);
	
	if( defusekit && !(kit & HAS_DEFUSE_KIT) )
	{
		set_pev(client, pev_body, 1);
		
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit | HAS_DEFUSE_KIT), EXTRAOFFSET);
		
		if( StatusIcon || (StatusIcon = get_user_msgid("StatusIcon")) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, StatusIcon, _, client);
			ewrite_byte((flash == 1) ? 2 : 1);
			ewrite_string(icon);
			ewrite_byte(r);
			ewrite_byte(g);
			ewrite_byte(b);
			emessage_end();
		}
	}
	else if( !defusekit && (kit & HAS_DEFUSE_KIT) )
	{
		set_pev(client, pev_body, 0);
		
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit & ~HAS_DEFUSE_KIT), EXTRAOFFSET);
		
		if( StatusIcon || (StatusIcon = get_user_msgid("StatusIcon")) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, StatusIcon, _, client);
			ewrite_byte(0);
			ewrite_string("defuser");
			emessage_end();
		}
	}
}

stock fm_cs_get_user_buyzone(client)
{
	return (fm_cs_get_user_mapzones(client) & CS_MAPZONE_BUY) ? 1 : 0;
}

stock fm_cs_get_user_hasprim(client)
{
	return get_pdata_int(client, OFFSET_PRIMWEAPON, EXTRAOFFSET);
}

stock fm_cs_get_user_model(client, model[], len)
{
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, client), "model", model, len);
}

stock fm_cs_set_user_model(client, const model[])
{
	engfunc(EngFunc_SetClientKeyValue, client, engfunc(EngFunc_GetInfoKeyBuffer, client), "model", model);
}

stock fm_cs_reset_user_model(client)
{
	dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
}

stock fm_cs_get_user_money(client)
{
	return get_pdata_int(client, OFFSET_MONEY, EXTRAOFFSET);
}

stock fm_cs_set_user_money(client, money, flash=1)
{
	set_pdata_int(client, OFFSET_MONEY, money, EXTRAOFFSET);
	
	static Money;
	if( Money || (Money = get_user_msgid("Money")) )
	{
		emessage_begin(MSG_ONE_UNRELIABLE, Money, _, client);
		ewrite_long(money);
		ewrite_byte(flash ? 1 : 0);
		emessage_end();
	}
}

#define HAS_NVGOGGLES			(1<<0)

stock fm_cs_get_user_nvg(client)
{
	return (get_pdata_int(client, OFFSET_NVGOGGLES, EXTRAOFFSET) & HAS_NVGOGGLES) ? 1 : 0;
}

stock fm_cs_set_user_nvg(client, nvgoggles=1)
{
	new kit = get_pdata_int(client, OFFSET_NVGOGGLES, EXTRAOFFSET);
	
	if( nvgoggles && !(kit & HAS_NVGOGGLES) )
	{
		set_pdata_int(client, OFFSET_NVGOGGLES, (kit | HAS_NVGOGGLES), EXTRAOFFSET);
	}
	else if( !nvgoggles && (kit & HAS_NVGOGGLES) )
	{
		set_pdata_int(client, OFFSET_NVGOGGLES, (kit & ~HAS_NVGOGGLES), EXTRAOFFSET);
	}
}

#define CAN_PLANT_BOMB			(1<<8)

stock fm_cs_get_user_plant(client)
{
	return (get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET) & CAN_PLANT_BOMB) ? 1 : 0;
}

stock fm_cs_set_user_plant(client, plant=1, showbombicon=1)
{
	static StatusIcon;
	
	new kit = get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET);
	
	if( plant && !(kit & CAN_PLANT_BOMB) )
	{
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit | CAN_PLANT_BOMB), EXTRAOFFSET);
		
		if( showbombicon && (StatusIcon || (StatusIcon = get_user_msgid("StatusIcon"))) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, StatusIcon, _, client);
			ewrite_byte(1);
			ewrite_string("c4");
			ewrite_byte(0);
			ewrite_byte(160);
			ewrite_byte(0);
			emessage_end();
		}
	}
	else if( !plant && (kit & CAN_PLANT_BOMB) )
	{
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit & ~CAN_PLANT_BOMB), EXTRAOFFSET);
		
		if( StatusIcon || (StatusIcon = get_user_msgid("StatusIcon")) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, StatusIcon, _, client);
			ewrite_byte(0);
			ewrite_string("c4");
			emessage_end();
		}
	}
}

enum CsTeams
{
	CS_TEAM_UNASSIGNED, // 0
	CS_TEAM_T, // 1
	CS_TEAM_CT, // 2
	CS_TEAM_SPECTATOR // 3
};

enum CsInternalModel
{
	CS_DONTCHANGE, // 0
	CS_CT_URBAN, // 1
	CS_T_TERROR, // 2
	CS_T_LEET, // 3
	CS_T_ARCTIC, // 4
	CS_CT_GSG9, // 5
	CS_CT_GIGN, // 6
	CS_CT_SAS, // 7
	CS_T_GUERILLA, // 8
	CS_CT_VIP, // 9
	CZ_T_MILITIA, // 10
	CZ_CT_SPETSNAZ // 11
};

stock fm_cs_set_user_team(client, {CsTeams,_}:team, {CsInternalModel,_}:model=CS_DONTCHANGE)
{
	new CsTeams:oldteam = fm_cs_get_user_team(client);
	if( oldteam != team )
	{
		switch( oldteam )
		{
			case CS_TEAM_T:
			{
				if( is_user_alive(client) && (pev(client, pev_weapons) & (1<<CSW_C4)) )
				{
					engclient_cmd(client, "drop", "weapon_c4");
				}
			}
			case CS_TEAM_CT:
			{
				fm_cs_set_user_defuse(client, 0);
			}
		}
	}
	
	set_pdata_int(client, OFFSET_TEAM, _:team, EXTRAOFFSET);
	
	if( model != CS_DONTCHANGE )
	{
		set_pdata_int(client, OFFSET_INTERALMODEL, _:model, EXTRAOFFSET);
	}
	
	dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
	
	static const team_names[CsTeams][] =
	{
		"UNASSIGNED",
		"TERRORIST",
		"CT",
		"SPECTATOR"
	};
	
	static TeamInfo;
	if( TeamInfo || (TeamInfo = get_user_msgid("TeamInfo")) )
	{
		emessage_begin(MSG_BROADCAST, TeamInfo);
		ewrite_byte(client);
		ewrite_string(team_names[team]);
		emessage_end();
	}
}

stock CsTeams:fm_cs_get_user_team(client, &{CsInternalModel,_}:model=CS_DONTCHANGE)
{
	model = CsInternalModel:get_pdata_int(client, OFFSET_INTERALMODEL, EXTRAOFFSET);
	
	return CsTeams:get_pdata_int(client, OFFSET_TEAM, EXTRAOFFSET);
}

#define PLAYER_IS_VIP			(1<<8)

stock fm_cs_get_user_vip(client)
{
	return (get_pdata_int(client, OFFSET_ISVIP, EXTRAOFFSET) & PLAYER_IS_VIP) ? 1 : 0;
}

#define SCOREATTRIB_NOTHING		0
#define SCOREATTRIB_DEAD		(1<<0)
#define SCOREATTRIB_BOMB		(1<<1)
#define SCOREATTRIB_VIP			(1<<2)

stock fm_cs_set_user_vip(client, vip=1, model=1, scoreboard=1)
{
	static ScoreAttrib;
	
	new isvip = fm_cs_get_user_vip(client);
	
	if( vip && !isvip )
	{
		set_pdata_int(client, OFFSET_ISVIP, (isvip | PLAYER_IS_VIP), EXTRAOFFSET);
		
		if( model )
		{
			set_pdata_int(client, OFFSET_INTERALMODEL, _:CS_CT_VIP, EXTRAOFFSET);
			dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
		}
		
		if( scoreboard )
		{
			if( ScoreAttrib || (ScoreAttrib = get_user_msgid("ScoreAttrib")) )
			{
				emessage_begin(MSG_BROADCAST, ScoreAttrib);
				ewrite_byte(client);
				ewrite_byte(SCOREATTRIB_VIP);
				emessage_end();
			}
		}
	}
	else if( !vip && isvip )
	{
		if( model )
		{
			static const CsInternalModel:models[4] =
			{
				CS_CT_GIGN,
				CS_CT_GSG9,
				CS_CT_SAS,
				CS_CT_URBAN
			};
			
			set_pdata_int(client, OFFSET_INTERALMODEL, models[random(sizeof(models))], EXTRAOFFSET);
			dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
		}
		
		if( scoreboard )
		{
			if( ScoreAttrib || (ScoreAttrib = get_user_msgid("ScoreAttrib")) )
			{
				emessage_begin(MSG_BROADCAST, ScoreAttrib);
				ewrite_byte(client);
				ewrite_byte(is_user_alive(client) ? SCOREATTRIB_NOTHING : SCOREATTRIB_DEAD);
				emessage_end();
			}
		}
	}
}

stock fm_cs_get_user_tked(client)
{
	return get_pdata_int(client, OFFSET_TKED, EXTRAOFFSET);
}

stock fm_cs_set_user_tked(client, tk=1, subtract=1)
{
	set_pdata_int(client, OFFSET_TKED, tk ? 1 : 0, EXTRAOFFSET);
	
	if( subtract )
	{
		new frags = get_user_frags(client) - subtract;
		
		set_pev(client, pev_frags, float(frags));
		
		static ScoreInfo;
		if( ScoreInfo || (ScoreInfo = get_user_msgid("ScoreInfo")) )
		{
			emessage_begin(MSG_BROADCAST, ScoreInfo);
			ewrite_byte(client);
			ewrite_short(frags);
			ewrite_short(fm_cs_get_user_deaths(client));
			ewrite_short(0);
			ewrite_short(_:fm_cs_get_user_team(client));
			emessage_end();
		}
	}
}

stock fm_cs_get_user_driving(client)
{
	return get_pdata_int(client, OFFSET_DRIVING, EXTRAOFFSET);
}

#define HAS_SHIELD			(1<<24)

stock fm_cs_get_user_shield(client)
{
	return (get_pdata_int(client, OFFSET_SHIELD, EXTRAOFFSET) & HAS_SHIELD) ? 1 : 0;
}

stock fm_cs_get_user_stationary(client)
{
	return get_pdata_int(client, OFFSET_STATIONARY, EXTRAOFFSET);
}

enum CsArmorType
{
	CS_ARMOR_NONE,
	CS_ARMOR_KEVLAR,
	CS_ARMOR_VESTHELM
};

stock fm_cs_get_user_armor(client, &CsArmorType:armortype)
{
	armortype = CsArmorType:get_pdata_int(client, OFFSET_ARMORTYPE, EXTRAOFFSET);
	
	static Float:armorvalue;
	pev(client, pev_armorvalue, armorvalue);
	return floatround(armorvalue);
}

stock fm_cs_set_user_armor(client, armorvalue, CsArmorType:armortype)
{
	set_pdata_int(client, OFFSET_ARMORTYPE, _:armortype, EXTRAOFFSET);
	
	set_pev(client, pev_armorvalue, float(armorvalue));
	
	if( armortype != CS_ARMOR_NONE )
	{
		static ArmorType;
		if( ArmorType || (ArmorType = get_user_msgid("ArmorType")) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, ArmorType, _, client);
			ewrite_byte((armortype == CS_ARMOR_VESTHELM) ? 1 : 0);
			emessage_end();
		}
	}
}

#define GLOCK18_SEMIAUTOMATIC		0
#define GLOCK18_BURST			2

#define FAMAS_AUTOMATIC			0
#define FAMAS_BURST			16

stock fm_cs_get_weapon_burst(entity)
{
	new firemode = get_pdata_int(entity, OFFSET_SILENCER_FIREMODE, EXTRAOFFSET_WEAPONS);
	
	switch( fm_cs_get_weapon_id(entity) )
	{
		case CSW_GLOCK18:
		{
			if( firemode == GLOCK18_BURST ) return 1;
		}
		case CSW_FAMAS:
		{
			if( firemode == FAMAS_BURST ) return 1;
		}
	}
	
	return 0;
}

stock fm_cs_set_weapon_burst(entity, burstmode=1)
{
	new weapon = fm_cs_get_weapon_id(entity);
	if( weapon != CSW_GLOCK18 && weapon != CSW_FAMAS ) return;
	
	static TextMsg;
	
	static const messages[3][] =
	{
		"#Switch_To_BurstFire",
		"#Switch_To_SemiAuto",
		"#Switch_To_FullAuto"
	};
	
	static type;
	new firemode = get_pdata_int(entity, OFFSET_SILENCER_FIREMODE, EXTRAOFFSET_WEAPONS);
	
	switch( weapon )
	{
		case CSW_GLOCK18:
		{
			if( burstmode && firemode == GLOCK18_SEMIAUTOMATIC )
			{
				type = 0;
				firemode = GLOCK18_BURST;
			}
			else if( !burstmode && firemode == GLOCK18_BURST )
			{
				type = 1;
				firemode = GLOCK18_SEMIAUTOMATIC;
			}
			else return;
		}
		case CSW_FAMAS:
		{
			if( burstmode && firemode == FAMAS_AUTOMATIC )
			{
				type = 0;
				firemode = FAMAS_BURST;
			}
			else if( !burstmode && firemode == FAMAS_BURST )
			{
				type = 2;
				firemode = FAMAS_AUTOMATIC;
			}
			else return;
		}
	}
	
	set_pdata_int(entity, OFFSET_SILENCER_FIREMODE, firemode, EXTRAOFFSET_WEAPONS);
	
	new client = pev(entity, pev_owner);
	if( is_user_alive(client) )
	{
		if( TextMsg || (TextMsg = get_user_msgid("TextMsg")) )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, TextMsg, _, client);
			ewrite_byte(4);
			ewrite_string(messages[type]);
			emessage_end();
		}
	}
}

#define M4A1_SILENCED			(1<<2)
#define M4A1_ATTACHSILENCEANIM		6
#define M4A1_DETACHSILENCEANIM		13

#define USP_SILENCED			(1<<0)
#define USP_ATTACHSILENCEANIM		7
#define USP_DETACHSILENCEANIM		15

stock fm_cs_get_weapon_silen(entity)
{
	new weapon = fm_cs_get_weapon_id(entity);
	if( weapon != CSW_M4A1 && weapon != CSW_USP ) return;
	
	new silencemode = get_pdata_int(entity, OFFSET_SILENCER_FIREMODE, EXTRAOFFSET_WEAPONS);
	
	switch( weapon )
	{
		case CSW_M4A1:
		{
			return (silencemode & M4A1_SILENCED);
		}
		case CSW_USP:
		{
			return (silencemode & USP_SILENCED);
		}
	}
	
	return 0;
}

stock fm_cs_set_weapon_silen(entity, silence=1, draw_animation=1)
{
	new weapon = fm_cs_get_weapon_id(entity);
	if( weapon != CSW_M4A1 && weapon != CSW_USP ) return;
	
	new silencemode = get_pdata_int(entity, OFFSET_SILENCER_FIREMODE, EXTRAOFFSET_WEAPONS);
	
	static animation;
	switch( weapon )
	{
		case CSW_M4A1:
		{
			if( silence && !(silencemode & M4A1_SILENCED) )
			{
				silencemode |= M4A1_SILENCED;
				animation = M4A1_ATTACHSILENCEANIM;
			}
			else if( !silence && (silencemode & M4A1_SILENCED) )
			{
				silencemode &= ~M4A1_SILENCED;
				animation = M4A1_DETACHSILENCEANIM;
			}
			else return;
		}
		case CSW_USP:
		{
			if( silence && !(silencemode & USP_SILENCED) )
			{
				silencemode |= USP_SILENCED;
				animation = USP_ATTACHSILENCEANIM;
			}
			else if( !silence && (silencemode & USP_SILENCED) )
			{
				silencemode &= ~USP_SILENCED;
				animation = USP_DETACHSILENCEANIM;
			}
			else return;
		}
	}
	
	set_pdata_int(entity, OFFSET_SILENCER_FIREMODE, silencemode, EXTRAOFFSET_WEAPONS);
	
	if( draw_animation )
	{
		new client = pev(entity, pev_owner);
		if( pev_valid(client) )
		{
			set_pev(client, pev_weaponanim, animation);
		}
	}
}

stock fm_cs_get_weapon_ammo(entity)
{
	return get_pdata_int(entity, OFFSET_WEAPONCLIP, EXTRAOFFSET_WEAPONS);
}

stock fm_cs_set_weapon_ammo(entity, clip)
{
	set_pdata_int(entity, OFFSET_WEAPONCLIP, clip, EXTRAOFFSET_WEAPONS);
}

stock fm_cs_get_weapon_id(entity)
{
	return get_pdata_int(entity, OFFSET_WEAPONID, EXTRAOFFSET_WEAPONS);
}

stock fm_cs_user_spawn(client)
{
	ExecuteHamB(Ham_CS_RoundRespawn, client);
}

#define CSA_MP5NAVY			0
#define CSA_TMP				1
#define CSA_P90				2
#define CSA_MAC10			3
#define CSA_AK47			4
#define CSA_SG552			5
#define CSA_M4A1			6
#define CSA_AUG				7
#define CSA_SCOUT			8
#define CSA_G3SG1			9
#define CSA_AWP				10
#define CSA_M3				11
#define CSA_XM1014			12
#define CSA_M249			13
#define CSA_FLASHBANG			14
#define CSA_HEGRENADE			15
#define CSA_VEST			16
#define CSA_VESTHELM			17
#define CSA_SMOKEGRENADE		18

stock const _CSA_to_CSW[] =
{
	CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_MAC10, CSW_AK47, CSW_SG552, CSW_M4A1, CSW_AUG, CSW_SCOUT, CSW_G3SG1,
	CSW_AWP, CSW_M3, CSW_XM1014, CSW_M249, CSW_FLASHBANG, CSW_HEGRENADE, CSW_VEST, CSW_VESTHELM, CSW_SMOKEGRENADE
};

stock const _CSW_to_CSA[] =
{
	-1, -1, CSA_SCOUT, CSA_HEGRENADE, CSA_XM1014, -1, CSA_MAC10, CSA_AUG, CSA_SMOKEGRENADE,
	-1, -1, -1, -1, -1, -1, -1, -1, CSA_AWP, CSA_MP5NAVY, CSA_M249, CSA_M3, CSA_M4A1, CSA_TMP,
	CSA_G3SG1, CSA_FLASHBANG, -1, CSA_SG552, CSA_AK47, CSA_P90, CSA_VEST, CSA_VESTHELM
};

stock fm_cs_get_armoury_type(entity)
{
	new CSA_type = get_pdata_int(entity, OFFSET_CSATYPE, EXTRAOFFSET_WEAPONS);
	
	return (0 <= CSA_type < sizeof(_CSA_to_CSW)) ? _CSA_to_CSW[CSA_type] : -1;
}

stock fm_cs_set_armoury_type(entity, type)
{
	if( !(0 <= type < sizeof(_CSW_to_CSA)) ) return;
	
	new CSA_type = _CSW_to_CSA[type];
	if( CSA_type == -1 ) return;
	
	set_pdata_int(entity, OFFSET_CSATYPE, CSA_type, EXTRAOFFSET_WEAPONS);
}

#define CS_MAPZONE_BUY 			(1<<0)
#define CS_MAPZONE_BOMBTARGET 		(1<<1)
#define CS_MAPZONE_HOSTAGE_RESCUE 	(1<<2)
#define CS_MAPZONE_ESCAPE		(1<<3)
#define CS_MAPZONE_VIP_SAFETY 		(1<<4)

stock fm_cs_get_user_mapzones(client)
{
	return get_pdata_int(client, OFFSET_MAPZONE, EXTRAOFFSET);
}

stock fm_cs_set_user_mapzones(client, mapzones)
{
	set_pdata_int(client, OFFSET_MAPZONE, mapzones, EXTRAOFFSET);
}

enum
{
	CS_RESET_ZOOM = 0,		// Reset any zoom blocking (when using this type, mode has no effect)
	CS_SET_NO_ZOOM,			// Disable any sort of zoom (ie: to disable zoom in all weapons use this with mode=0)
	CS_SET_FIRST_ZOOM,		// Set first zoom (awp style) 
	CS_SET_SECOND_ZOOM,		// Set second zoom (awp style)
	CS_SET_AUGSG552_ZOOM,		// Set aug/sg552 zoom style
};

stock fm_cs_get_user_submodel(client)
{
	return pev(client, pev_body);
}

stock fm_cs_set_user_submodel(client, value)
{
	set_pev(client, pev_body, value);
}

stock Float:fm_cs_get_user_lastactivity(client)
{
	return get_pdata_float(client, OFFSET_LASTACTIVITY, EXTRAOFFSET);
}

stock fm_cs_set_user_lastactivity(client, Float:value)
{
	set_pdata_float(client, OFFSET_LASTACTIVITY, value, EXTRAOFFSET);
}

stock fm_cs_get_user_hostagekills(client)
{
	return get_pdata_int(client, OFFSET_HOSTAGEKILLS, EXTRAOFFSET);
}

stock fm_cs_set_user_hostagekills(client, value)
{
	set_pdata_int(client, OFFSET_HOSTAGEKILLS, value, EXTRAOFFSET);
}

stock Float:fm_cs_get_hostage_lastuse(entity)
{
	return get_pdata_float(entity, OFFSET_HOSTAGELASTUSE, EXTRAOFFSET);
}

stock fm_cs_set_hostage_lastuse(entity, Float:value)
{
	set_pdata_float(entity, OFFSET_HOSTAGELASTUSE, value, EXTRAOFFSET);
}

stock Float:fm_cs_get_hostage_nextuse(entity)
{
	return get_pdata_float(entity, OFFSET_HOSTAGENEXTUSE, EXTRAOFFSET);
}

stock fm_cs_set_hostage_nextuse(entity, Float:value)
{
	set_pdata_float(entity, OFFSET_HOSTAGENEXTUSE, value, EXTRAOFFSET);
}

stock Float:fm_cs_get_c4_explode_time(entity)
{
	return get_pdata_float(entity, OFFSET_C4_EXPLODETIME, EXTRAOFFSET);
}

stock fm_cs_set_c4_explode_time(entity, Float:value)
{
	set_pdata_float(entity, OFFSET_C4_EXPLODETIME, value, EXTRAOFFSET);
}

stock bool:fm_cs_get_c4_defusing(entity)
{
	return bool:get_pdata_int(entity, OFFSET_C4_DEFUSING, ACTUAL_EXTRA_OFFSET);
}

stock fm_cs_set_c4_defusing(entity, bool:defusing)
{
	set_pdata_int(entity, OFFSET_C4_DEFUSING, _:defusing, ACTUAL_EXTRA_OFFSET);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

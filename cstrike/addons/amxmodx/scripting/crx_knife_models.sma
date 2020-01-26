#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>

native crxranks_get_max_levels()
native crxranks_get_rank_by_level(level, buffer[], len)
native crxranks_get_user_level(id)
native crxranks_get_user_xp(id)

new const g_szNatives[][] =
{
	"crxranks_get_max_levels",
	"crxranks_get_rank_by_level",
	"crxranks_get_user_level",
	"crxranks_get_user_xp"
}

#if !defined m_pPlayer
	#define m_pPlayer 41
#endif

#if defined client_disconnected
	#define client_disconnect client_disconnected
#endif

#define PLUGIN_VERSION "2.5.7"
#define DEFAULT_V "models/v_knife.mdl"
#define DEFAULT_P "models/p_knife.mdl"
#define MAX_SOUND_LENGTH 128
#define MAX_AUTHID_LENGTH 35

#if !defined MAX_NAME_LENGTH
	#define MAX_NAME_LENGTH 32
#endif

#if !defined MAX_PLAYERS
	#define MAX_PLAYERS 32
#endif

enum
{
	SOUND_NONE = 0,
	SOUND_DEPLOY,
	SOUND_HIT,
	SOUND_HITWALL,
	SOUND_SLASH,
	SOUND_STAB
}

enum _:Knives
{
	NAME[MAX_NAME_LENGTH],
	V_MODEL[MAX_SOUND_LENGTH],
	P_MODEL[MAX_SOUND_LENGTH],
	DEPLOY_SOUND[MAX_SOUND_LENGTH],
	HIT_SOUND[MAX_SOUND_LENGTH],
	HITWALL_SOUND[MAX_SOUND_LENGTH],
	SLASH_SOUND[MAX_SOUND_LENGTH],
	STAB_SOUND[MAX_SOUND_LENGTH],
	SELECT_SOUND[MAX_SOUND_LENGTH],
	FLAG,
	LEVEL,
	bool:SHOW_RANK,
	bool:HAS_CUSTOM_SOUND,
	XP
}

new Array:g_aKnives,
	bool:g_bFirstTime[MAX_PLAYERS + 1],
	bool:g_bRankSystem,
	bool:g_bGetLevel,
	bool:g_bGetXP,
	g_eKnife[MAX_PLAYERS + 1][Knives],
	g_szAuth[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH],
	g_iKnife[MAX_PLAYERS + 1],
	g_iCallback,
	g_pAtSpawn,
	g_pSaveChoice,
	g_iSaveChoice,
	g_iKnivesNum,
	g_iVault

public plugin_init()
{
	register_plugin("Knife Models", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXKnifeModels", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	
	if(!g_iKnivesNum)
		set_fail_state("No knives found in the configuration file.")
	
	register_dictionary("KnifeModels.txt")
	
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	register_forward(FM_EmitSound,	"OnEmitSound")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "OnSelectKnife", 1)
	
	register_clcmd("say /knife", "ShowMenu")
	register_clcmd("say_team /knife", "ShowMenu")
	
	g_iCallback = menu_makecallback("CheckKnifeAccess")
	g_pAtSpawn = register_cvar("km_open_at_spawn", "0")
	g_pSaveChoice = register_cvar("km_save_choice", "0")
}

public plugin_precache()
{
	if(LibraryExists("crxranks", LibType_Library))
		g_bRankSystem = true
		
	g_aKnives = ArrayCreate(Knives)
	ReadFile()
}

public plugin_cfg()
{
	g_iSaveChoice = get_pcvar_num(g_pSaveChoice)
	
	if(g_iSaveChoice)
		g_iVault = nvault_open("KnifeModels")
}

public plugin_natives()
	set_native_filter("native_filter")
	
public native_filter(const szNative[], id, iTrap)
{
	if(!iTrap)
	{
		static i
		
		for(i = 0; i < sizeof(g_szNatives); i++)
		{
			if(equal(szNative, g_szNatives[i]))
				return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}
	
public plugin_end()
{
	ArrayDestroy(g_aKnives)
	
	if(g_iSaveChoice)
		nvault_close(g_iVault)
}

ReadFile()
{
	new szConfigsName[256], szFilename[256]
	get_configsdir(szConfigsName, charsmax(szConfigsName))
	formatex(szFilename, charsmax(szFilename), "%s/KnifeModels.ini", szConfigsName)
	new iFilePointer = fopen(szFilename, "rt")
	
	if(iFilePointer)
	{
		new szData[160], szKey[32], szValue[128], szSound[128], iMaxLevels
		new eKnife[Knives], bool:bCustom
		
		if(g_bRankSystem)
			iMaxLevels = crxranks_get_max_levels()
		
		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)
			
			switch(szData[0])
			{
				case EOS, '#', ';': continue
				case '[':
				{
					if(szData[strlen(szData) - 1] == ']')
					{
						if(g_iKnivesNum)
							PushKnife(eKnife)
							
						g_iKnivesNum++
						replace(szData, charsmax(szData), "[", "")
						replace(szData, charsmax(szData), "]", "")
						copy(eKnife[NAME], charsmax(eKnife[NAME]), szData)
						
						eKnife[V_MODEL][0] = EOS
						eKnife[P_MODEL][0] = EOS
						eKnife[DEPLOY_SOUND][0] = EOS
						eKnife[HIT_SOUND][0] = EOS
						eKnife[HITWALL_SOUND][0] = EOS
						eKnife[SLASH_SOUND][0] = EOS
						eKnife[STAB_SOUND][0] = EOS
						eKnife[SELECT_SOUND][0] = EOS
						eKnife[FLAG] = ADMIN_ALL
						eKnife[HAS_CUSTOM_SOUND] = false
						
						if(g_bRankSystem)
						{
							eKnife[LEVEL] = 0
							eKnife[SHOW_RANK] = false
							eKnife[XP] = 0
						}
					}
					else continue
				}
				default:
				{
					strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
					trim(szKey); trim(szValue)
					bCustom = true
					
					if(equal(szKey, "FLAG"))
						eKnife[FLAG] = read_flags(szValue)
					else if(equal(szKey, "LEVEL") && g_bRankSystem)
					{
						eKnife[LEVEL] = clamp(str_to_num(szValue), 0, iMaxLevels)
						
						if(!g_bGetLevel)
							g_bGetLevel = true
					}
					else if(equal(szKey, "SHOW_RANK") && g_bRankSystem)
						eKnife[SHOW_RANK] = _:clamp(str_to_num(szValue), false, true)
					else if(equal(szKey, "XP") && g_bRankSystem)
					{
						eKnife[XP] = _:clamp(str_to_num(szValue), 0)
						
						if(!g_bGetXP)
							g_bGetXP = true
					}
					else if(equal(szKey, "V_MODEL"))
						copy(eKnife[V_MODEL], charsmax(eKnife[V_MODEL]), szValue)
					else if(equal(szKey, "P_MODEL"))
						copy(eKnife[P_MODEL], charsmax(eKnife[P_MODEL]), szValue)
					else if(equal(szKey, "DEPLOY_SOUND"))
						copy(eKnife[DEPLOY_SOUND], charsmax(eKnife[DEPLOY_SOUND]), szValue)
					else if(equal(szKey, "HIT_SOUND"))
						copy(eKnife[HIT_SOUND], charsmax(eKnife[HIT_SOUND]), szValue)
					else if(equal(szKey, "HITWALL_SOUND"))
						copy(eKnife[HITWALL_SOUND], charsmax(eKnife[HITWALL_SOUND]), szValue)
					else if(equal(szKey, "SLASH_SOUND"))
						copy(eKnife[SLASH_SOUND], charsmax(eKnife[SLASH_SOUND]), szValue)
					else if(equal(szKey, "STAB_SOUND"))
						copy(eKnife[STAB_SOUND], charsmax(eKnife[STAB_SOUND]), szValue)
					else if(equal(szKey, "SELECT_SOUND"))
					{
						bCustom = false
						copy(eKnife[SELECT_SOUND], charsmax(eKnife[SELECT_SOUND]), szValue)
					}
					else continue
					
					static const szModelArg[] = "_MODEL"
					static const szSoundArg[] = "_SOUND"
					
					if(contain(szKey, szModelArg) != -1)
					{
						if(!file_exists(szValue))
							log_amx("ERROR: model ^"%s^" not found!", szValue)
						else
							precache_model(szValue)
					}
					else if(contain(szKey, szSoundArg) != -1)
					{
						formatex(szSound, charsmax(szSound), "sound/%s", szValue)

						if(!file_exists(szSound))
							log_amx("ERROR: sound ^"%s^" not found!", szSound)
						else
							precache_sound(szValue)
						
						if(bCustom)
							eKnife[HAS_CUSTOM_SOUND] = true
					}
				}
			}
		}
		
		if(g_iKnivesNum)
			PushKnife(eKnife)
		
		fclose(iFilePointer)
	}
}

public client_connect(id)
{
	g_bFirstTime[id] = true
	ArrayGetArray(g_aKnives, 0, g_eKnife[id])
	g_iKnife[id] = 0
	
	if(g_iSaveChoice)
	{
		get_user_authid(id, g_szAuth[id], charsmax(g_szAuth[]))
		UseVault(id, false)
	}
}

public client_disconnect(id)
{
	if(g_iSaveChoice)
		UseVault(id, true)
}

public OnEmitSound(id, iChannel, const szSample[])
{
	if(!is_user_connected(id) || !g_eKnife[id][HAS_CUSTOM_SOUND] || !IsKnifeSound(szSample))
		return FMRES_IGNORED
	
	switch(DetectKnifeSound(szSample))
	{
		case SOUND_DEPLOY: 		if(g_eKnife[id][DEPLOY_SOUND][0]) 		{ PlayKnifeSound(id, g_eKnife[id][DEPLOY_SOUND][0]); 	return FMRES_SUPERCEDE; }
		case SOUND_HIT: 		if(g_eKnife[id][HIT_SOUND][0]) 			{ PlayKnifeSound(id, g_eKnife[id][HIT_SOUND][0]); 		return FMRES_SUPERCEDE; }
		case SOUND_HITWALL:		if(g_eKnife[id][HITWALL_SOUND][0]) 		{ PlayKnifeSound(id, g_eKnife[id][HITWALL_SOUND][0]); 	return FMRES_SUPERCEDE; }
		case SOUND_SLASH: 		if(g_eKnife[id][SLASH_SOUND][0]) 		{ PlayKnifeSound(id, g_eKnife[id][SLASH_SOUND][0]);		return FMRES_SUPERCEDE; }
		case SOUND_STAB: 		if(g_eKnife[id][STAB_SOUND][0]) 		{ PlayKnifeSound(id, g_eKnife[id][STAB_SOUND][0]); 		return FMRES_SUPERCEDE; }
	}
	
	return FMRES_IGNORED
}

public ShowMenu(id)
{
	static eKnife[Knives]
	new szTitle[128], szItem[128], iLevel, iXP
	formatex(szTitle, charsmax(szTitle), "%L", id, "KM_MENU_TITLE")

	if(g_bGetLevel)
		iLevel = crxranks_get_user_level(id)
	
	if(g_bGetXP)
		iXP = crxranks_get_user_xp(id)
		
	new iMenu = menu_create(szTitle, "MenuHandler")
	
	for(new iFlags = get_user_flags(id), i; i < g_iKnivesNum; i++)
	{
		ArrayGetArray(g_aKnives, i, eKnife)
		copy(szItem, charsmax(szItem), eKnife[NAME])
		
		if(g_bRankSystem)
		{
			if(eKnife[LEVEL] && iLevel < eKnife[LEVEL])
			{
				if(eKnife[SHOW_RANK])
				{
					static szRank[32]
					crxranks_get_rank_by_level(eKnife[LEVEL], szRank, charsmax(szRank))
					format(szItem, charsmax(szItem), "%s %L", szItem, id, "KM_MENU_RANK", szRank)
				}
				else
					format(szItem, charsmax(szItem), "%s %L", szItem, id, "KM_MENU_LEVEL", eKnife[LEVEL])
			}
			
			if(eKnife[XP] && iXP < eKnife[XP])
				format(szItem, charsmax(szItem), "%s %L", szItem, id, "KM_MENU_XP", eKnife[XP])
		}
		
		if(eKnife[FLAG] != ADMIN_ALL && !(iFlags & eKnife[FLAG]))
			format(szItem, charsmax(szItem), "%s %L", szItem, id, "KM_MENU_VIP_ONLY")
			
		if(g_iKnife[id] == i)
			format(szItem, charsmax(szItem), "%s %L", szItem, id, "KM_MENU_SELECTED")
		
		menu_additem(iMenu, szItem, eKnife[NAME], eKnife[FLAG], g_iCallback)
	}
	
	if(menu_pages(iMenu) > 1)
	{
		formatex(szItem, charsmax(szItem), "%s%L", szTitle, id, "KM_MENU_TITLE_PAGE")
		menu_setprop(iMenu, MPROP_TITLE, szItem)
	}
		
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public MenuHandler(id, iMenu, iItem)
{
	if(iItem != MENU_EXIT)
	{
		g_iKnife[id] = iItem
		ArrayGetArray(g_aKnives, iItem, g_eKnife[id])
		
		if(is_user_alive(id) && get_user_weapon(id) == CSW_KNIFE)
			RefreshKnifeModel(id)
		
		new szName[MAX_NAME_LENGTH], iUnused
		menu_item_getinfo(iMenu, iItem, iUnused, szName, charsmax(szName), .callback = iUnused)
		CC_SendMessage(id, "%L %L", id, "KM_CHAT_PREFIX", id, "KM_CHAT_SELECTED", szName)
		
		if(g_eKnife[id][SELECT_SOUND][0])
			PlayKnifeSound(id, g_eKnife[id][SELECT_SOUND])
	}
	
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

public CheckKnifeAccess(id, iMenu, iItem)
	return ((g_iKnife[id] == iItem) || !HasKnifeAccess(id, iItem)) ? ITEM_DISABLED : ITEM_ENABLED

public OnPlayerSpawn(id)
{
	if(is_user_alive(id) && get_pcvar_num(g_pAtSpawn) && !g_iKnife[id] && g_bFirstTime[id] && (get_user_flags(id) & ADMIN_RESERVATION))
	{
		g_bFirstTime[id] = false
		ShowMenu(id)
	}
}

public OnSelectKnife(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if(is_user_connected(id))
		RefreshKnifeModel(id)
}

RefreshKnifeModel(const id)
{
	set_pev(id, pev_viewmodel2, g_eKnife[id][V_MODEL])
	set_pev(id, pev_weaponmodel2, g_eKnife[id][P_MODEL])
}

PushKnife(eKnife[Knives])
{
	if(!eKnife[V_MODEL][0])
		copy(eKnife[V_MODEL], charsmax(eKnife[V_MODEL]), DEFAULT_V)
		
	if(!eKnife[P_MODEL][0])
		copy(eKnife[P_MODEL], charsmax(eKnife[P_MODEL]), DEFAULT_P)
		
	ArrayPushArray(g_aKnives, eKnife)
}

bool:HasKnifeAccess(const id, const iKnife)
{		
	static eKnife[Knives]
	ArrayGetArray(g_aKnives, iKnife, eKnife)
	
	if(g_bRankSystem)
	{
		if(eKnife[LEVEL] && crxranks_get_user_level(id) < eKnife[LEVEL])
			return false
			
		if(eKnife[XP] && crxranks_get_user_xp(id) < eKnife[XP])
			return false
	}
		
	if(eKnife[FLAG] != ADMIN_ALL && !(get_user_flags(id) & eKnife[FLAG]))
		return false
		
	return true
}

bool:IsKnifeSound(const szSample[])
	return bool:equal(szSample[8], "kni", 3)

DetectKnifeSound(const szSample[])
{
	static iSound
	iSound = SOUND_NONE
	
	if(equal(szSample, "weapons/knife_deploy1.wav"))
		iSound = SOUND_DEPLOY
	else if(equal(szSample[14], "hit", 3))
		iSound = szSample[17] == 'w' ? SOUND_HITWALL : SOUND_HIT
	else if(equal(szSample[14], "sla", 3))
		iSound = SOUND_SLASH
	else if(equal(szSample[14], "sta", 3))
		iSound = SOUND_STAB
		
	return iSound
}

UseVault(const id, const bool:bSave)
{
	if(bSave)
	{
		static szData[4]
		num_to_str(g_iKnife[id], szData, charsmax(szData))
		nvault_set(g_iVault, g_szAuth[id], szData)
	}
	else
	{
		static iKnife
		iKnife = nvault_get(g_iVault, g_szAuth[id])
		
		if(iKnife > g_iKnivesNum)
			iKnife = 0

		g_iKnife[id] = iKnife
		CheckKnifeOnConnect(id)
	}
}

public CheckKnifeOnConnect(id)
{
	if(g_iKnife[id])
	{
		if(_:HasKnifeAccess(id, g_iKnife[id]) == ITEM_ENABLED)
		{
			ArrayGetArray(g_aKnives, g_iKnife[id], g_eKnife[id])
			
			if(is_user_alive(id) && get_user_weapon(id) == CSW_KNIFE)
				RefreshKnifeModel(id)
		}
		else g_iKnife[id] = 0
	}
}

PlayKnifeSound(const id, const szSound[])
	engfunc(EngFunc_EmitSound, id, CHAN_AUTO, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM)

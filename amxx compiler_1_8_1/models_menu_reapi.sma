#include <amxmodx>
#include <reapi>

#define VERSION "2.1 ReAPI"

enum _:ModelData
{
	ID,
	DISPLAY_NAME[64],
	MODEL_FILE[64],
	MODEL_TEAM,
	MODEL_FLAG[8]
}

new const g_szConfigFile[] = "addons/amxmodx/configs/models_menu.ini";

new Array:g_LoadedModels;
new g_UserModel[33][ModelData];
new g_iMenu[2], g_iTotalModels;

public plugin_init()
{
	register_plugin("Models Menu", VERSION, "TheRedShoko @ AMXX-BG.info");
	register_cvar("models_menu", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED|FCVAR_SPONLY);

	register_clcmd("say /models", "ShowModelsMenu");
	register_clcmd("say_team /models", "ShowModelsMenu");

	RegisterHookChain(RG_CBasePlayer_Spawn, "FwPlayerSpawnPost", 1);
}

public plugin_precache()
{
	g_LoadedModels = ArrayCreate(ModelData);

	LoadConfigFile();
}

public FwPlayerSpawnPost(id)
{
	if (!is_user_alive(id) || g_UserModel[id][ID] == 0)
	{
		return;
	}
	
	if (strlen(g_UserModel[id][MODEL_FLAG]) != 0 && !(get_user_flags(id) & read_flags(g_UserModel[id][MODEL_FLAG])) || g_UserModel[id][MODEL_TEAM] && g_UserModel[id][MODEL_TEAM] != (get_member(id, m_iTeam)) )
	{
		rg_reset_user_model(id);
		ArrayGetArray(g_LoadedModels, 0, g_UserModel[id]);
		return;
	}

	rg_set_user_model(id, g_UserModel[id][MODEL_FILE]);
}

public ShowModelsMenu(id)
{
	if (!IsUserInGame(id))
	{
		return PLUGIN_HANDLED;
	}

	new iTeam = get_member(id, m_iTeam) - 1;

	menu_display(id, g_iMenu[iTeam]);
	return PLUGIN_HANDLED;
}

public ModelsMenuCallback(id, iMenu, Item)
{
	new szTemp[ModelData];
	new szInfo[8], szName[80], iAccess, iCallback;
	menu_item_getinfo(iMenu, Item, iAccess, szInfo, charsmax(szInfo), _, _, iCallback);

	ArrayGetArray(g_LoadedModels, str_to_num(szInfo), szTemp);
	copy(szName, charsmax(szName), szTemp[DISPLAY_NAME]);

	if (!(get_user_flags(id) & read_flags(szTemp[MODEL_FLAG])) && strlen(szTemp[MODEL_FLAG]) != 0)
	{
		add(szName, charsmax(szName), " \r[Admin Only]");
		menu_item_setname(iMenu, Item, szName);
		return ITEM_DISABLED;
	}

	if (szTemp[ID] == g_UserModel[id][ID])
	{
		add(szName, charsmax(szName), " \y[Current Model]");
		menu_item_setname(iMenu, Item, szName);
		return ITEM_DISABLED;
	}

	menu_item_setname(iMenu, Item, szName);

	return ITEM_ENABLED;
}

public ModelsMenuHandler(id, iMenu, Item)
{
	if (Item == MENU_EXIT)
	{
		return;
	}

	new szInfo[8], szName[80], iAccess, iCallback;
	menu_item_getinfo(iMenu, Item, iAccess, szInfo, charsmax(szInfo), szName, charsmax(szName), iCallback);

	ArrayGetArray(g_LoadedModels, str_to_num(szInfo), g_UserModel[id]);

	if (!is_user_alive(id))
	{
		return;
	}

	if (g_UserModel[id][ID] == 0)
	{
		rg_reset_user_model(id);
		return;
	}

	rg_set_user_model(id, g_UserModel[id][MODEL_FILE]);
}

LoadConfigFile()
{
	if (!file_exists(g_szConfigFile))
	{
		write_file(g_szConfigFile, "; Models menu plugin by TheRedShoko @ AMXX-BG.info");
		write_file(g_szConfigFile, "; Syntax: ^"Name to be displayed^" ^"name of the mdl file^" ^"T (1) | CT (2) | Any (0)^" ^"admin flag^"");
		pause("ad");
		return;
	}

	new iLine, szLine[156], iBuffer;
	new szModelData[ModelData];
	copy(szModelData[DISPLAY_NAME], charsmax(szModelData[DISPLAY_NAME]), "Default");
	ArrayPushArray(g_LoadedModels, szModelData);
	g_iTotalModels = 1;

	while ((iLine = read_file(g_szConfigFile, iLine, szLine, charsmax(szLine), iBuffer)))
	{
		if (szLine[0] == EOS || szLine[0] == ';' || szLine[0] == '/' && szLine[1] == '/')
		{
			continue;
		}

		new szModelName[64], szFileName[64], szTeam[8], szFlag[8];
		parse(szLine, szModelName, charsmax(szModelName), szFileName, charsmax(szFileName), szTeam, charsmax(szTeam), szFlag, charsmax(szFlag));

		if (!TryPrecachePlayerModel(szFileName))
		{
			continue;
		}

		copy(szModelData[DISPLAY_NAME], charsmax(szModelData[DISPLAY_NAME]), szModelName);
		copy(szModelData[MODEL_FILE], charsmax(szModelData[MODEL_FILE]), szFileName);

		switch (szTeam[0])
		{
			case '0', 'a', ' ': szModelData[MODEL_TEAM] = 0;
			case '1', 't', 'T': szModelData[MODEL_TEAM] = 1;
			case '2', 'c', 'C': szModelData[MODEL_TEAM] = 2;
		}

		copy(szModelData[MODEL_FLAG], charsmax(szModelData[MODEL_FLAG]), szFlag);

		szModelData[ID] = g_iTotalModels;

		ArrayPushArray(g_LoadedModels, szModelData);
		g_iTotalModels++;
	}

	GenerateModelMenus();
}

GenerateModelMenus()
{
	new  szTempData[ModelData];
	for (new i = 0; i < sizeof g_iMenu; i++)
	{
		g_iMenu[i] = menu_create("Models Menu", "ModelsMenuHandler");
	}

	new iCallback = menu_makecallback("ModelsMenuCallback");
	new szInfo[8];

	for (new j = 0; j < g_iTotalModels; j++)
	{
		ArrayGetArray(g_LoadedModels, j, szTempData);
		num_to_str(j, szInfo, charsmax(szInfo));

		if (szTempData[MODEL_TEAM] != 0)
		{
			menu_additem(g_iMenu[szTempData[MODEL_TEAM] - 1], szTempData[DISPLAY_NAME], szInfo, _, iCallback);
		}
		else
		{
			for (new i = 0; i < sizeof g_iMenu; i++)
			{
				menu_additem(g_iMenu[i], szTempData[DISPLAY_NAME], szInfo, _, iCallback);
			}
		}
	}
}

TryPrecachePlayerModel(const szModel[])
{
	new szFile[128];
	formatex(szFile, charsmax(szFile), "models/player/%s/%s.mdl", szModel, szModel);

	if (!file_exists(szFile))
	{
		return 0;
	}
	
	precache_generic(szFile);
	
	replace_all(szFile, charsmax(szFile), ".mdl", "T.mdl");
	if (file_exists(szFile))
	{
		precache_generic(szFile);
	}

	return 1;
}

bool:IsUserInGame(id)
{
	return is_user_connected(id) && 1 <= get_member(id, m_iTeam) <= 2;
}
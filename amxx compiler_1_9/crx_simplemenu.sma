#include <amxmodx>
#include <amxmisc>

#define PLUGIN_VERSION "2.1.2"
#define MAX_MENUS 20

enum
{
	SECTION_DEFAULTS = 0,
	SECTION_SETTINGS,
	SECTION_MENUITEMS
}

enum _:Settings
{
	MENU_TITLE[128],
	MENU_TITLE_PAGE[128],
	MENU_PREFIX[32],
	MENU_BACKK[32],
	MENU_NEXT[32],
	MENU_EXITT[32],
	MENU_FLAG,
	MENU_TEAM,
	MENU_ALIVEONLY,
	MENU_ITEMS_PER_PAGE,
	MENU_REOPEN,
	MENU_ITEM_FORMAT[64],
	MENU_NOACCESS[160],
	MENU_NOTEAM[160],
	MENU_ALIVE[160],
	MENU_DEAD[160],
	MENU_SOUND[128]
}

enum _:Items
{
	Name[64],
	Command[64],
	Flag[5],
	Team,
	bool:UseFunc,
	Plugin[64],
	Function[64]
}

new g_eDefaults[Settings],
	g_eSettings[MAX_MENUS][Settings],
	g_iTotalItems[MAX_MENUS],
	g_szMap[32],
	g_msgSayText

new Trie:g_tCommands,
	Array:g_aMenuItems[MAX_MENUS]

new const g_szAll[] = "#all"
new const g_szItemField[] = "%item%"
new const g_szNameField[] = "%name%"
new const g_szUserIdField[] = "%userid%"
new const g_szBlankField[] = "#blank"
new const g_szTextField[] = "#text"
new const g_szPlayersField[] = "#addplayers"
new const g_szFunc[] = "do.func"
new const g_szAMXX[] = ".amxx"
new const g_szNewLine[2][] = { "%newline%", "^n" }
new const g_szSayStuff[2][] = { "say ", "say_team " }

public plugin_init()
{
	register_plugin("Simple Menu", PLUGIN_VERSION, "OciXCrom")
	register_cvar("SimpleMenu", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	g_msgSayText = get_user_msgid("SayText")
}

public plugin_precache()
{
	for(new i; i < MAX_MENUS; i++)
		g_aMenuItems[i] = ArrayCreate(Items)

	get_mapname(g_szMap, charsmax(g_szMap))
	g_tCommands = TrieCreate()
	fileRead()
}

public plugin_end()
{
	for(new i; i < MAX_MENUS; i++)
		ArrayDestroy(g_aMenuItems[i])

	TrieDestroy(g_tCommands)
}

fileRead()
{
	new szConfigsName[256], szFilename[256]
	get_configsdir(szConfigsName, charsmax(szConfigsName))
	formatex(szFilename, charsmax(szFilename), "%s/SimpleMenu.ini", szConfigsName)
	new iFilePointer = fopen(szFilename, "rt")

	if(iFilePointer)
	{
		new szData[256], szKey[128], szValue[128], szTeam[2], iSection, iSize
		new eItem[Items], iMenuId = -1, bool:blRead = true

		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)

			switch(szData[0])
			{
				case EOS, ';': continue
				case '-':
				{
					iSize = strlen(szData)

					if(szData[iSize - 1] == '-')
					{
						szData[0] = ' '
						szData[iSize - 1] = ' '
						trim(szData)

						if(contain(szData, "*") != -1)
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '*')
							copy(szValue, strlen(szKey), g_szMap)
							blRead = equal(szValue, szKey) ? true : false
						}
						else
							blRead = equal(szData, g_szAll) || equali(szData, g_szMap)
					}
					else continue
				}
				case '[':
				{
					if(szData[strlen(szData) - 1] == ']')
					{
						if(containi(szData, "default settings") != -1)
							iSection = SECTION_DEFAULTS
						else if(containi(szData, "new menu") != -1)
						{
							iMenuId++

							for(new i; i < sizeof(g_eDefaults); i++)
								g_eSettings[iMenuId][i] = g_eDefaults[i]
						}
						else if(containi(szData, "menu settings") != -1)
						{
							if(iMenuId < 0)
								iMenuId = 0

							iSection = SECTION_SETTINGS
						}
						else if(containi(szData, "menu items") != -1)
						{
							if(iMenuId < 0)
								iMenuId = 0

							iSection = SECTION_MENUITEMS
						}
					}
					else continue
				}
				default:
				{
					if(!blRead)
						continue

					switch(iSection)
					{
						case SECTION_DEFAULTS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)

							if(szValue[0] == EOS)
								continue

							if(equal(szKey, "MENU_TITLE"))
							{
								if(contain(szValue, g_szNewLine[0]) != -1)
									replace_all(szValue, charsmax(szValue), g_szNewLine[0], g_szNewLine[1])

								copy(g_eDefaults[MENU_TITLE], charsmax(g_eDefaults[MENU_TITLE]), szValue)
							}
							if(equal(szKey, "MENU_TITLE_PAGE"))
							{
								if(contain(szValue, g_szNewLine[0]) != -1)
									replace_all(szValue, charsmax(szValue), g_szNewLine[0], g_szNewLine[1])

								copy(g_eDefaults[MENU_TITLE_PAGE], charsmax(g_eDefaults[MENU_TITLE_PAGE]), szValue)
							}
							else if(equal(szKey, "MENU_PREFIX"))
								copy(g_eDefaults[MENU_PREFIX], charsmax(g_eDefaults[MENU_PREFIX]), szValue)
							else if(equal(szKey, "MENU_BACK"))
								copy(g_eDefaults[MENU_BACKK], charsmax(g_eDefaults[MENU_BACKK]), szValue)
							else if(equal(szKey, "MENU_NEXT"))
								copy(g_eDefaults[MENU_NEXT], charsmax(g_eDefaults[MENU_NEXT]), szValue)
							else if(equal(szKey, "MENU_EXIT"))
								copy(g_eDefaults[MENU_EXITT], charsmax(g_eDefaults[MENU_EXITT]), szValue)
							else if(equal(szKey, "MENU_FLAG"))
								g_eDefaults[MENU_FLAG] = szValue[0] == '0' ? 0 : read_flags(szValue)
							else if(equal(szKey, "MENU_TEAM"))
								g_eDefaults[MENU_TEAM] = clamp(str_to_num(szValue), 0, 3)
							else if(equal(szKey, "MENU_ALIVEONLY"))
								g_eDefaults[MENU_ALIVEONLY] = str_to_num(szValue)
							else if(equal(szKey, "MENU_ITEMS_PER_PAGE"))
								g_eDefaults[MENU_ITEMS_PER_PAGE] = str_to_num(szValue)
							else if(equal(szKey, "MENU_REOPEN"))
								g_eDefaults[MENU_REOPEN] = str_to_num(szValue)
							else if(equal(szKey, "MENU_ITEM_FORMAT"))
								copy(g_eDefaults[MENU_ITEM_FORMAT], charsmax(g_eDefaults[MENU_ITEM_FORMAT]), szValue)
							else if(equal(szKey, "MENU_NOACCESS"))
								copy(g_eDefaults[MENU_NOACCESS], charsmax(g_eDefaults[MENU_NOACCESS]), szValue)
							else if(equal(szKey, "MENU_NOTEAM"))
								copy(g_eDefaults[MENU_NOTEAM], charsmax(g_eDefaults[MENU_NOTEAM]), szValue)
							else if(equal(szKey, "MENU_ALIVE"))
								copy(g_eDefaults[MENU_ALIVE], charsmax(g_eDefaults[MENU_ALIVE]), szValue)
							else if(equal(szKey, "MENU_DEAD"))
								copy(g_eDefaults[MENU_DEAD], charsmax(g_eDefaults[MENU_DEAD]), szValue)
							else if(equal(szKey, "MENU_SOUND"))
							{
								copy(g_eDefaults[MENU_SOUND], charsmax(g_eDefaults[MENU_SOUND]), szValue)
								precache_sound(szValue)
							}
						}
						case SECTION_SETTINGS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)

							if(szValue[0] == EOS)
								continue

							if(equal(szKey, "MENU_TITLE"))
							{
								if(contain(szValue, g_szNewLine[0]) != -1)
									replace_all(szValue, charsmax(szValue), g_szNewLine[0], g_szNewLine[1])

								copy(g_eSettings[iMenuId][MENU_TITLE], charsmax(g_eSettings[][MENU_TITLE]), szValue)
							}
							if(equal(szKey, "MENU_TITLE_PAGE"))
							{
								if(contain(szValue, g_szNewLine[0]) != -1)
									replace_all(szValue, charsmax(szValue), g_szNewLine[0], g_szNewLine[1])

								copy(g_eSettings[iMenuId][MENU_TITLE_PAGE], charsmax(g_eSettings[][MENU_TITLE_PAGE]), szValue)
							}
							else if(equal(szKey, "MENU_PREFIX"))
								copy(g_eSettings[iMenuId][MENU_PREFIX], charsmax(g_eSettings[][MENU_PREFIX]), szValue)
							else if(equal(szKey, "MENU_BACK"))
								copy(g_eSettings[iMenuId][MENU_BACKK], charsmax(g_eSettings[][MENU_BACKK]), szValue)
							else if(equal(szKey, "MENU_NEXT"))
								copy(g_eSettings[iMenuId][MENU_NEXT], charsmax(g_eSettings[][MENU_NEXT]), szValue)
							else if(equal(szKey, "MENU_EXIT"))
								copy(g_eSettings[iMenuId][MENU_EXITT], charsmax(g_eSettings[][MENU_EXITT]), szValue)
							else if(equal(szKey, "MENU_FLAG"))
								g_eSettings[iMenuId][MENU_FLAG] = szValue[0] == '0' ? 0 : read_flags(szValue)
							else if(equal(szKey, "MENU_TEAM"))
								g_eSettings[iMenuId][MENU_TEAM] = clamp(str_to_num(szValue), 0, 3)
							else if(equal(szKey, "MENU_ALIVEONLY"))
								g_eSettings[iMenuId][MENU_ALIVEONLY] = str_to_num(szValue)
							else if(equal(szKey, "MENU_ITEMS_PER_PAGE"))
								g_eSettings[iMenuId][MENU_ITEMS_PER_PAGE] = str_to_num(szValue)
							else if(equal(szKey, "MENU_REOPEN"))
								g_eSettings[iMenuId][MENU_REOPEN] = str_to_num(szValue)
							else if(equal(szKey, "MENU_OPEN"))
							{
								while(szValue[0] != 0 && strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ','))
								{
									trim(szKey); trim(szValue)
									register_clcmd(szKey, "cmdMenu")
									TrieSetCell(g_tCommands, szKey, iMenuId)
								}
							}
							else if(equal(szKey, "MENU_ITEM_FORMAT"))
								copy(g_eSettings[iMenuId][MENU_ITEM_FORMAT], charsmax(g_eSettings[][MENU_ITEM_FORMAT]), szValue)
							else if(equal(szKey, "MENU_NOACCESS"))
								copy(g_eSettings[iMenuId][MENU_NOACCESS], charsmax(g_eSettings[][MENU_NOACCESS]), szValue)
							else if(equal(szKey, "MENU_NOTEAM"))
								copy(g_eSettings[iMenuId][MENU_NOTEAM], charsmax(g_eSettings[][MENU_NOTEAM]), szValue)
							else if(equal(szKey, "MENU_ALIVE"))
								copy(g_eSettings[iMenuId][MENU_ALIVE], charsmax(g_eSettings[][MENU_ALIVE]), szValue)
							else if(equal(szKey, "MENU_DEAD"))
								copy(g_eSettings[iMenuId][MENU_DEAD], charsmax(g_eSettings[][MENU_DEAD]), szValue)
							else if(equal(szKey, "MENU_SOUND"))
							{
								copy(g_eSettings[iMenuId][MENU_SOUND], charsmax(g_eSettings[][MENU_SOUND]), szValue)
								precache_sound(szValue)
							}
						}
						case SECTION_MENUITEMS:
						{
							parse(szData, eItem[Name], charsmax(eItem[Name]), eItem[Command], charsmax(eItem[Command]), eItem[Flag], charsmax(eItem[Flag]), szTeam, charsmax(szTeam))
							eItem[UseFunc] = bool:(equal(eItem[Command], g_szFunc, charsmax(g_szFunc)))
							eItem[Team] = str_to_num(szTeam)

							if(eItem[UseFunc])
							{
								replace(eItem[Command], charsmax(eItem[Command]), g_szFunc, "")
								replace(eItem[Command], charsmax(eItem[Command]), "(", "")
								replace(eItem[Command], charsmax(eItem[Command]), ")", "")
								strtok(eItem[Command], eItem[Plugin], charsmax(eItem[Plugin]), eItem[Function], charsmax(eItem[Function]), ',')
								trim(eItem[Plugin]); trim(eItem[Function])

								if(contain(eItem[Plugin], g_szAMXX) == -1)
									add(eItem[Plugin], charsmax(eItem[Plugin]), g_szAMXX)
							}

							ArrayPushArray(g_aMenuItems[iMenuId], eItem)
							eItem[Flag][0] = EOS
							szTeam[0] = EOS
							g_iTotalItems[iMenuId]++
						}
					}
				}
			}
		}

		fclose(iFilePointer)
	}
}

public cmdMenu(id)
{
	new szCommand[64], szArgs[128], iMenuId
	read_argv(0, szCommand, charsmax(szCommand))

	if(equal(szCommand[0], g_szSayStuff[0], 3) || equal(szCommand[0], g_szSayStuff[1], 8))
	{
		read_argv(1, szArgs, charsmax(szArgs))
		remove_quotes(szArgs)
		format(szCommand, charsmax(szCommand), "%s %s", szCommand, szArgs)
	}

	if(TrieGetCell(g_tCommands, szCommand, iMenuId))
		menuMain(id, iMenuId)
	else
		return PLUGIN_CONTINUE

	return PLUGIN_HANDLED
}

menuMain(id, iMenuId, iPage = 0)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}

	if(g_eSettings[iMenuId][MENU_FLAG] && !(get_user_flags(id) & g_eSettings[iMenuId][MENU_FLAG]))
	{
		ColorChat(id, "%s %s", g_eSettings[iMenuId][MENU_PREFIX], g_eSettings[iMenuId][MENU_NOACCESS])
		return PLUGIN_HANDLED
	}

	if(!get_team_access(id, iMenuId))
	{
		ColorChat(id, "%s %s", g_eSettings[iMenuId][MENU_PREFIX], g_eSettings[iMenuId][MENU_NOTEAM])
		return PLUGIN_HANDLED
	}

	if(!get_alive_access(id, iMenuId))
	{
		ColorChat(id, "%s %s", g_eSettings[iMenuId][MENU_PREFIX], g_eSettings[iMenuId][MENU_ALIVEONLY] == 1 ? g_eSettings[iMenuId][MENU_ALIVE] : g_eSettings[iMenuId][MENU_DEAD])
		return PLUGIN_HANDLED
	}

	if(g_eSettings[iMenuId][MENU_SOUND][0] != EOS)
		client_cmd(id, "spk %s", g_eSettings[iMenuId][MENU_SOUND])

	new szItem[128], szData[20]
	new eItem[Items], iMenu = menu_create(g_eSettings[iMenuId][MENU_TITLE], "handlerMain")

	for(new i, iTeam = get_user_team(id); i < g_iTotalItems[iMenuId]; i++)
	{
		ArrayGetArray(g_aMenuItems[iMenuId], i, eItem)

		if(eItem[Team] && eItem[Team] != iTeam)
			continue
		else if(equal(eItem[Name], g_szBlankField))
			menu_addblank(iMenu, str_to_num(eItem[Command]))
		else if(equal(eItem[Name], g_szTextField))
			menu_addtext(iMenu, eItem[Command], str_to_num(eItem[Flag]))
		else if(equal(eItem[Name], g_szPlayersField))
		{
			new szName[32], iPlayers[32], iPnum
			get_players(iPlayers, iPnum, get_flag(eItem[Flag], "c") ? "a" : "")

			for(new j, iPlayer; j < iPnum; j++)
			{
				iPlayer = iPlayers[j]

				if(iPlayer == id)
				{
					if(!get_flag(eItem[Flag], "b"))
						continue
				}
				else if(get_user_flags(iPlayer) & ADMIN_IMMUNITY)
				{
					if(get_flag(eItem[Flag], "a"))
						continue
				}

				get_user_name(iPlayer, szName, charsmax(szName))
				copy(szItem, charsmax(szItem), g_eSettings[iMenuId][MENU_ITEM_FORMAT])
				replace_all(szItem, charsmax(szItem), g_szItemField, szName)
				formatex(szData, charsmax(szData), "%i %i %i p", iMenuId, i, get_user_userid(iPlayer))
				menu_additem(iMenu, szItem, szData)
			}
		}
		else
		{
			copy(szItem, charsmax(szItem), g_eSettings[iMenuId][MENU_ITEM_FORMAT])
			replace_all(szItem, charsmax(szItem), g_szItemField, eItem[Name])
			formatex(szData, charsmax(szData), "%i %i", iMenuId, i)
			menu_additem(iMenu, szItem, szData, read_flags(eItem[Flag]))
		}
	}

	if(menu_pages(iMenu) > 1)
	{
		new szTitle[256]
		formatex(szTitle, charsmax(szTitle), "%s %s", g_eSettings[iMenuId][MENU_TITLE], g_eSettings[iMenuId][MENU_TITLE_PAGE])
		menu_setprop(iMenu, MPROP_TITLE, szTitle)
	}

	menu_setprop(iMenu, MPROP_BACKNAME, g_eSettings[iMenuId][MENU_BACKK])
	menu_setprop(iMenu, MPROP_NEXTNAME, g_eSettings[iMenuId][MENU_NEXT])
	menu_setprop(iMenu, MPROP_EXITNAME, g_eSettings[iMenuId][MENU_EXITT])
	menu_setprop(iMenu, MPROP_PERPAGE, g_eSettings[iMenuId][MENU_ITEMS_PER_PAGE])
	menu_display(id, iMenu, iPage)
	return PLUGIN_HANDLED
}

public handlerMain(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
		goto @DESTROY

	new szData[20], szMenuId[3], szKey[3], szUserId[5], iMenuId, iKey, iUserId, iAccess, iCallback
	menu_item_getinfo(iMenu, iItem, iAccess, szData, charsmax(szData), .callback = iCallback)
	parse(szData, szMenuId, charsmax(szMenuId), szKey, charsmax(szKey), szUserId, charsmax(szUserId))

	iMenuId = str_to_num(szMenuId)
	iKey = str_to_num(szKey)
	iUserId = str_to_num(szUserId)

	if(get_alive_access(id, iMenuId) && get_team_access(id, iMenuId))
	{
		new eItem[Items]
		ArrayGetArray(g_aMenuItems[iMenuId], iKey, eItem)

		if(szData[strlen(szData) - 1] == 'p')
		{
			new szCommand[64]
			copy(szCommand, charsmax(szCommand), eItem[Command])

			if(get_flag(szCommand, g_szNameField))
			{
				new szName[32]
				get_user_name(find_player("k", iUserId), szName, charsmax(szName))
				replace_all(szCommand, charsmax(szCommand), g_szNameField, szName)
			}

			if(get_flag(szCommand, g_szUserIdField))
				replace_all(szCommand, charsmax(szCommand), g_szUserIdField, szUserId)

			client_cmd(id, szCommand)
		}
		else
		{
			if(eItem[UseFunc])
			{
				callfunc_begin(eItem[Function], eItem[Plugin])
				callfunc_push_int(id)
				callfunc_end()
			}
			else
				client_cmd(id, eItem[Command])
		}
	}

	if(g_eSettings[iMenuId][MENU_REOPEN])
	{
		new iMenu2, iPage
		player_menu_info(id, iMenu2, iMenu2, iPage)
		menu_destroy(iMenu)
		menuMain(id, iMenuId, iPage)
		return PLUGIN_HANDLED
	}

	@DESTROY:
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

ColorChat(const id, const szInput[], any:...)
{
	new iPlayers[32], iCount = 1
	static szMessage[191]
	vformat(szMessage, charsmax(szMessage), szInput, 3)

	replace_all(szMessage, charsmax(szMessage), "!g", "^4")
	replace_all(szMessage, charsmax(szMessage), "!n", "^1")
	replace_all(szMessage, charsmax(szMessage), "!t", "^3")

	if(id)
		iPlayers[0] = id
	else
		get_players(iPlayers, iCount, "ch")

	for(new i; i < iCount; i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMessage)
			message_end()
		}
	}
}

bool:get_flag(szString[], const szFlag[])
	return (contain(szString, szFlag) != -1) ? true : false

bool:get_alive_access(id, iMenuId)
	return ((g_eSettings[iMenuId][MENU_ALIVEONLY] == 1 && !is_user_alive(id)) || (g_eSettings[iMenuId][MENU_ALIVEONLY] == 2 && is_user_alive(id))) ? false : true

bool:get_team_access(id, iMenuId)
	return (!g_eSettings[iMenuId][MENU_TEAM] || g_eSettings[iMenuId][MENU_TEAM] == get_user_team(id))

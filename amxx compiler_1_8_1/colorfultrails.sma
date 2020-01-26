#include <amxmodx>
#include <amxmisc>
#include <cromchat>

enum LiteType
{
	None,
	Lite,
	Dark
}

enum Sections
{
	SectionNone = 0,
	SectionTypes,
	SectionColors,
	SectionSettings
}

enum _:ColorsData
{
	Name[32],
	Color[3]
}

enum _:TrailTypeData
{
	TypeName[32],
	TypeSprite[128],
	TypeSpriteID,
	TypeSize,
	TypeBrightness
}

enum _:UserSettings
{
	Name[32],
	bool:TrailOn = false,
	TrailColorID,
	TrailColors[3],
	bool:CustomColorOn,
	TrailType,
	LiteType:TrailLite
}

enum _:TrailsSettings
{
	AdminFlags,
	TrailLife,
	CustomColorFlags,
	TrailModeAdd
}

new Array:g_aColorsArray
new Array:g_aTypesArray
new g_iColorCount
new g_iTypeCount
new g_eTrailsSettings[TrailsSettings]

new g_eUserSettings[33][UserSettings]

new g_szLiteString[LiteType][32] =
{
	"Default",
	"Lite",
	"Dark"
}

new g_iColorsMenu
new g_iTypesMenu

public plugin_init()
{
	register_plugin("Catch Mod: Trails", "1.0", "mi0")

	register_clcmd("say /trails", "cmd_trails")
	register_clcmd("CT_CUSTOM_COLOR", "cmd_custom_color")
}

public plugin_precache()
{
	g_aTypesArray = ArrayCreate(TrailTypeData)
	g_aColorsArray = ArrayCreate(ColorsData)

	LoadFile()
	MakeColorsMenu()
	MakeTypesMenu()
}

public plugin_end()
{
	ArrayDestroy(g_aColorsArray)
	ArrayDestroy(g_aTypesArray)
}

LoadFile()
{
	new szFileDir[128]
	get_configsdir(szFileDir, charsmax(szFileDir))
	add(szFileDir, charsmax(szFileDir), "/TrailsSettings.ini")

	new iFile = fopen(szFileDir, "rt")
	if (iFile)
	{
		new szLine[256], Sections:iSection = SectionNone
		new szKey[32], szValue[32]
		new szParsedColor[3][4]
		new eTempColorArray[ColorsData], eTempTypeArray[TrailTypeData]

		while (!feof(iFile))
		{
			fgets(iFile, szLine, charsmax(szLine))
			trim(szLine)

			if (szLine[0] == EOS || szLine[0] == '#' || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
			{
				continue
			}

			if (szLine[0] == '[')
			{
				switch (szLine[1])
				{
					case 'T':
					{
						iSection = SectionTypes
					}

					case 'C':
					{
						iSection = SectionColors
					}

					case 'S':
					{
						iSection = SectionSettings
					}

					default:
					{
						iSection = SectionNone
					}
				}

				continue
			}

			switch (iSection)
			{
				case SectionTypes:
				{
					parse(szLine, eTempTypeArray[Name], charsmax(eTempTypeArray[Name]), eTempTypeArray[TypeSprite], charsmax(eTempTypeArray[TypeSprite]), szKey, charsmax(szKey), szValue, charsmax(szValue))
					eTempTypeArray[TypeSpriteID] = precache_model(eTempTypeArray[TypeSprite])
					eTempTypeArray[TypeSize] = abs(str_to_num(szKey))
					eTempTypeArray[TypeBrightness] = clamp(str_to_num(szValue), 0, 255)

					ArrayPushArray(g_aTypesArray, eTempTypeArray)
					g_iTypeCount++
				}

				case SectionColors:
				{
					parse(szLine, eTempColorArray[Name], charsmax(eTempColorArray[Name]), szKey, charsmax(szKey))
					parse(szKey, szParsedColor[0], charsmax(szParsedColor[]), szParsedColor[1], charsmax(szParsedColor[]), szParsedColor[2], charsmax(szParsedColor[]))
					eTempColorArray[Color][0] = clamp(str_to_num(szParsedColor[0]), 0, 255)
					eTempColorArray[Color][1] = clamp(str_to_num(szParsedColor[1]), 0, 255)
					eTempColorArray[Color][2] = clamp(str_to_num(szParsedColor[2]), 0, 255)

					ArrayPushArray(g_aColorsArray, eTempColorArray)
					g_iColorCount++
				}

				case SectionSettings:
				{
					strtok(szLine, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
					trim(szKey)
					trim(szValue)

					if (equali(szKey, "ADMIN_FLAGS"))
					{
						g_eTrailsSettings[AdminFlags] = read_flags(szValue)
					}
					else if (equali(szKey, "TRAIL_LIFE"))
					{
						g_eTrailsSettings[TrailLife] = abs(str_to_num(szValue))
					}
					else if (equali(szKey, "TRAIL_MODE_ADD"))
					{
						g_eTrailsSettings[TrailModeAdd] = abs(str_to_num(szValue))
					}
					else if (equali(szKey, "ADMIN_CUSTOM_COLOR"))
					{
						g_eTrailsSettings[CustomColorFlags] = read_flags(szValue)
					}
					else if (equali((szKey), "CHAT_PREFIX"))
					{
						if (szValue[0] != EOS)
						{
							CC_SetPrefix(szValue)
						}
					}
				}
			}
		}
	}
}

OpenTrailMenu(id)
{
	new iMenu = menu_create("\yColorful Trails \rMenu", "TrailMenu_Handler")
	new iMenuCallBack = menu_makecallback("TrailMenu_CallBack")

	new eTempTypeArray[TrailTypeData], szTemp[192]
	ArrayGetArray(g_aTypesArray, g_eUserSettings[id][TrailType], eTempTypeArray)
	formatex(szTemp, charsmax(szTemp), "Types \y[%s]", eTempTypeArray[TypeName])
	menu_additem(iMenu, szTemp)

	if (g_eUserSettings[id][CustomColorOn])
	{
		formatex(szTemp, charsmax(szTemp), "Colors \r[Custom]")
	}
	else
	{
		new eTempColorArray[ColorsData]
		ArrayGetArray(g_aColorsArray, g_eUserSettings[id][TrailColorID], eTempColorArray)
		formatex(szTemp, charsmax(szTemp), "Colors \y[%s]", eTempColorArray[Name])
	}
	menu_additem(iMenu, szTemp)

	if (get_user_flags(id) & g_eTrailsSettings[CustomColorFlags])
	{
		if (g_eUserSettings[id][CustomColorOn])
		{
			formatex(szTemp, charsmax(szTemp), "Custom Color \y[%.3i %.3i %.3i]", g_eUserSettings[id][TrailColors][0], g_eUserSettings[id][TrailColors][1], g_eUserSettings[id][TrailColors][2])
		}
		else
		{
			formatex(szTemp, charsmax(szTemp), "Custom Color \y[Off]")
		}
	}
	else
	{
		formatex(szTemp, charsmax(szTemp), "Custom Color \r[Admins Only]")
	}
	menu_additem(iMenu, szTemp, .callback = iMenuCallBack)

	formatex(szTemp, charsmax(szTemp), "Trail Mode - \r%s", g_szLiteString[g_eUserSettings[id][TrailLite]])
	menu_additem(iMenu, szTemp)

	formatex(szTemp, charsmax(szTemp), "Trail - %s", g_eUserSettings[id][TrailOn] ? "\yOn" : "\rOff")
	menu_additem(iMenu, szTemp)

	menu_display(id, iMenu)
}

public TrailMenu_CallBack(id, iMenu, iItem)
{
	return (get_user_flags(id) & g_eTrailsSettings[CustomColorFlags]) ? ITEM_ENABLED : ITEM_DISABLED
}

public TrailMenu_Handler(id, iMenu, iItem)
{
	switch (iItem)
	{
		case 0:
		{
			menu_display(id, g_iTypesMenu)
		}
		case 1:
		{
			menu_display(id, g_iColorsMenu)
		}
		case 2:
		{
			client_cmd(id, "messagemode CT_CUSTOM_COLOR")
		}
		case 3:
		{
			new eTempArray[ColorsData]
			ArrayGetArray(g_aColorsArray, g_eUserSettings[id][TrailColorID], eTempArray)

			switch (g_eUserSettings[id][TrailLite])
			{
				case Dark:
				{
					g_eUserSettings[id][TrailLite] = None
				}

				case None:
				{
					g_eUserSettings[id][TrailLite] = Lite

					for (new i; i < 3; i++)
					{
						eTempArray[Color][i] = clamp(eTempArray[Color][i] - g_eTrailsSettings[TrailModeAdd], 0, 255)
					}
				}

				case Lite:
				{
					g_eUserSettings[id][TrailLite] = Dark

					for (new i; i < 3; i++)
					{
						eTempArray[Color][i] = clamp(eTempArray[Color][i] + g_eTrailsSettings[TrailModeAdd], 0, 255)
					}
				}
			}

			copy(g_eUserSettings[id][TrailColors], 3, eTempArray[Color])
		}
		case 4:
		{
			if (g_eUserSettings[id][TrailOn])
			{
				StopUserTrail(id)
			}
			else
			{
				StartUserTrail(id)
			}
		}
	}

	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

MakeColorsMenu()
{
	g_iColorsMenu = menu_create("\rTrails Colors", "ColorsMenu_Handler")

	for (new i, eTempArray[ColorsData]; i < g_iColorCount; i++)
	{
		ArrayGetArray(g_aColorsArray, i, eTempArray)
		menu_additem(g_iColorsMenu, eTempArray[Name])
	}
}

public ColorsMenu_Handler(id, iMenu, iItem)
{
	if (iItem == MENU_EXIT)
	{
		menu_cancel(id)
		OpenTrailMenu(id)

		return PLUGIN_HANDLED
	}

	new eTempArray[ColorsData]
	ArrayGetArray(g_aColorsArray, iItem, eTempArray)

	switch (g_eUserSettings[id][TrailLite])
	{
		case Dark:
		{
			g_eUserSettings[id][TrailLite] = None
			for (new i; i < 3; i++)
			{
				eTempArray[Color][i] = clamp(eTempArray[Color][i] + g_eTrailsSettings[TrailModeAdd], 0, 255)
			}
		}

		case Lite:
		{
			g_eUserSettings[id][TrailLite] = Dark

			for (new i; i < 3; i++)
			{
				eTempArray[Color][i] = clamp(eTempArray[Color][i] + g_eTrailsSettings[TrailModeAdd], 0, 255)
			}
		}
	}

	copy(g_eUserSettings[id][TrailColors], 3, eTempArray[Color])
	g_eUserSettings[id][TrailColorID] = iItem
	g_eUserSettings[id][CustomColorOn] = false

	if (g_eUserSettings[id][TrailOn])
	{
		UpdateUserTrail(id)
	}
	else
	{
		StartUserTrail(id)
	}

	client_print_color(id, id, "You successfuly set your color to ^x03%s", eTempArray[Name])

	menu_cancel(id)
	OpenTrailMenu(id)
	return PLUGIN_HANDLED
}

MakeTypesMenu()
{
	g_iTypesMenu = menu_create("\rTrails Types", "TypesMenu_Handler")

	for (new i, eTempArray[TrailTypeData]; i < g_iTypeCount; i++)
	{
		ArrayGetArray(g_aTypesArray, i, eTempArray)
		menu_additem(g_iTypesMenu, eTempArray[TypeName])
	}
}

public TypesMenu_Handler(id, iMenu, iItem)
{
	if (iItem == MENU_EXIT)
	{
		menu_cancel(id)
		OpenTrailMenu(id)

		return PLUGIN_HANDLED
	}

	g_eUserSettings[id][TrailType] = iItem

	if (g_eUserSettings[id][TrailOn])
	{
		UpdateUserTrail(id)
	}
	else
	{
		StartUserTrail(id)
	}

	new eTempArray[TrailTypeData]
	ArrayGetArray(g_aTypesArray, iItem, eTempArray)
	client_print_color(id, id, "You successfuly set your type to ^x03%s", eTempArray[Name])

	menu_cancel(id)
	OpenTrailMenu(id)
	return PLUGIN_HANDLED
}

StartUserTrail(id)
{
	UpdateUserTrail(id)
	set_task(10.0, "UpdateUserTrail", id, .flags = "b")
	g_eUserSettings[id][TrailOn] = true
}

StopUserTrail(id)
{
	KillUserTrail(id)
	if (task_exists(id))
	{
		remove_task(id)
	}
	g_eUserSettings[id][TrailOn] = false
}

public UpdateUserTrail(id)
{
	KillUserTrail(id)

	new eTempArray[TrailTypeData]
	ArrayGetArray(g_aTypesArray, g_eUserSettings[id][TrailType], eTempArray)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(id)
	write_short(eTempArray[TypeSpriteID])
	write_byte(g_eTrailsSettings[TrailLife] * 10)
	write_byte(eTempArray[TypeSize])
	write_byte(g_eUserSettings[id][TrailColors][0])
	write_byte(g_eUserSettings[id][TrailColors][1])
	write_byte(g_eUserSettings[id][TrailColors][2])
	write_byte(eTempArray[TypeBrightness])
	message_end()
}

KillUserTrail(id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(id)
	message_end()
}

public cmd_trails(id)
{
	if (!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}

	if (~get_user_flags(id) & g_eTrailsSettings[AdminFlags])
	{
		CC_SendMatched(id, id, "You must be ^x04Vip ^x01 to use the ^x03Colorful Trails")
		return PLUGIN_HANDLED
	}

	OpenTrailMenu(id)

	return PLUGIN_HANDLED
}

public cmd_custom_color(id)
{
	if (!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}

	if (~get_user_flags(id) & g_eTrailsSettings[CustomColorFlags])
	{
		return PLUGIN_HANDLED
	}

	new szArg[16]
	read_argv(1, szArg, charsmax(szArg))

	new szColors[3][4]
	parse(szArg, szColors[0], charsmax(szColors[]), szColors[1], charsmax(szColors[]), szColors[2], charsmax(szColors[]))

	g_eUserSettings[id][TrailColors][0] = clamp(str_to_num(szColors[0]), 0, 255)
	g_eUserSettings[id][TrailColors][1] = clamp(str_to_num(szColors[1]), 0, 255)
	g_eUserSettings[id][TrailColors][2] = clamp(str_to_num(szColors[2]), 0, 255)
	g_eUserSettings[id][CustomColorOn] = true

	if (g_eUserSettings[id][TrailOn])
	{
		UpdateUserTrail(id)
	}
	else
	{
		StartUserTrail(id)
	}

	client_print_color(id, id, "You successfuly set custom color - ^"%i %i %i^"", g_eUserSettings[id][TrailColors][0], g_eUserSettings[id][TrailColors][1], g_eUserSettings[id][TrailColors][2])

	OpenTrailMenu(id)

	return PLUGIN_HANDLED
}
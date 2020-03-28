#include <amxmodx>
#include <amxmisc>
#include <csstats>
#include <cstrike>
#include <fakemeta>
#include <regex>

#tryinclude <cromchat>

#if !defined _cromchat_included
	#error "cromchat.inc" is missing in your "scripting/include" folder. Download it from: "https://amxx-bg.info/inc/"
#endif

native crxranks_get_max_levels()
native crxranks_get_user_level(id)
native crxranks_get_user_xp(id)

new const g_szNatives[][] =
{
	"crxranks_get_max_levels",
	"crxranks_get_user_level",
	"crxranks_get_user_xp"
}

// Uncomment to log restrictions in the server's console.
//#define CRX_CMDRESTRICTIONS_DEBUG

#if !defined STATSX_KILLS
	const STATSX_KILLS     = 0
	const STATSX_DEATHS    = 1
	const STATSX_HEADSHOTS = 2
	const STATSX_RANK      = 7
	const STATSX_MAX_STATS = 8
	const MAX_BODYHITS     = 8
#endif

#if !defined MAX_PLAYERS
	const MAX_PLAYERS = 32
#endif

#if !defined MAX_NAME_LENGTH
	const MAX_NAME_LENGTH = 32
#endif

#if !defined MAX_IP_LENGTH
	const MAX_IP_LENGTH = 16
#endif

#if !defined MAX_AUTHID_LENGTH
	const MAX_AUTHID_LENGTH = 64
#endif

new const PLUGIN_VERSION[]  = "2.0.1"
new const CMD_ARG_SAY[]     = "say"
new const CMD_ARG_SAYTEAM[] = "say_team"
new const TIME_FORMAT[]     = "%H:%M"

const MAX_FILE_PATH_LENGTH  = 256
const MAX_MSG_LENGTH        = 160
const MAX_COMMANDS          = 128
const MAX_CMDLINE_LENGTH    = 128
const MAX_CMD_LENGTH        = 32
const MAX_STATUS_LENGTH     = 12
const MAX_TYPE_LENGTH       = 12
const MAX_TIME_LENGTH       = 6
const MAX_INT_VALUES        = 2
const INVALID_ENTRY         = -1

enum _:Types
{
	TYPE_ALL,
	TYPE_NAME,
	TYPE_IP,
	TYPE_STEAM,
	TYPE_FLAGS,
	TYPE_ANY_FLAG,
	TYPE_TEAM,
	TYPE_CSSTATS_RANK,
	TYPE_CSSTATS_KILLS,
	TYPE_CSSTATS_DEATHS,
	TYPE_CSSTATS_HEADSHOTS,
	TYPE_SCORE,
	TYPE_LIFE,
	TYPE_TIME,
	TYPE_MAP,
	TYPE_CRXRANKS_LEVEL,
	TYPE_CRXRANKS_XP
}

enum _:PlayerData
{
	PDATA_NAME[MAX_NAME_LENGTH],
	PDATA_IP[MAX_IP_LENGTH],
	PDATA_STEAM[MAX_AUTHID_LENGTH]
}

enum _:RestrictionData
{
	Status,
	Type,
	CsTeams:ValueTeam,
	ValueString[MAX_AUTHID_LENGTH],
	ValueInt[MAX_INT_VALUES],
	Message[MAX_MSG_LENGTH]
}

enum _:StatusTypes
{
	STATUS_NONE,
	STATUS_ALLOW,
	STATUS_BLOCK,
	STATUS_PASS,
	STATUS_STOP
}

new const ARG_COMMAND[]        = "$cmd$"
new const ARG_NO_MSG[]         = "#none"
new const FILE_LOGS[]          = "CommandRestrictions.log"
new const FILE_CONFIG[]        = "CommandRestrictions.ini"
new const REGEX_TIME_PATTERN[] = "(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})"

new Array:g_aRestrictions[MAX_COMMANDS]
new Trie:g_tCommands
new bool:g_bRankSystem
new bool:g_bIsCstrike

new g_ePlayerData[MAX_PLAYERS + 1][PlayerData]
new g_iTotalCommands = INVALID_ENTRY
new g_iRestrictions[MAX_COMMANDS]
new g_szQueue[MAX_CMDLINE_LENGTH]
new g_szMap[MAX_NAME_LENGTH]
new g_fwdUserNameChanged

public plugin_init()
{
	register_plugin("Command Restrictions", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXCommandRestrictions", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)

	register_event("SayText", "OnSayText", "a", "2=#Cstrike_Name_Change")
	register_dictionary("common.txt")
}

public plugin_precache()
{
	new szModname[MAX_NAME_LENGTH]
	get_modname(szModname, charsmax(szModname))

	if(equal(szModname, "cstrike"))
	{
		g_bIsCstrike = true
	}

	if(LibraryExists("crxranks", LibType_Library))
	{
		g_bRankSystem = true
	}

	get_mapname(g_szMap, charsmax(g_szMap))

	register_clcmd(CMD_ARG_SAY, "OnSay")
	register_clcmd(CMD_ARG_SAYTEAM, "OnSay")

	g_tCommands = TrieCreate()

	ReadFile()
}

public plugin_natives()
{
	set_native_filter("native_filter")
}

public native_filter(const szNative[], id, iTrap)
{
	if(!iTrap)
	{
		static i

		for(i = 0; i < sizeof(g_szNatives); i++)
		{
			if(equal(szNative, g_szNatives[i]))
			{
				return PLUGIN_HANDLED
			}
		}
	}

	return PLUGIN_CONTINUE
}

public plugin_end()
{
	for(new i; i < g_iTotalCommands; i++)
	{
		ArrayDestroy(g_aRestrictions[i])
	}

	TrieDestroy(g_tCommands)
}

public client_putinserver(id)
{
	get_user_name(id, g_ePlayerData[id][PDATA_NAME], charsmax(g_ePlayerData[][PDATA_NAME]))
	strtolower(g_ePlayerData[id][PDATA_NAME])
	get_user_ip(id, g_ePlayerData[id][PDATA_IP], charsmax(g_ePlayerData[][PDATA_IP]), 1)
	get_user_authid(id, g_ePlayerData[id][PDATA_STEAM], charsmax(g_ePlayerData[][PDATA_STEAM]))
}

public OnSayText(iMsg, iDestination, iEntity)
{
	g_fwdUserNameChanged = register_forward(FM_ClientUserInfoChanged, "OnNameChange", 1)
}

public OnNameChange(id)
{
	if(!is_user_connected(id))
	{
		return
	}

	get_user_name(id, g_ePlayerData[id][PDATA_NAME], g_ePlayerData[id][PDATA_NAME])
	strtolower(g_ePlayerData[id][PDATA_NAME])

	unregister_forward(FM_ClientUserInfoChanged, g_fwdUserNameChanged, 1)
}

ReadFile()
{
	new szFilename[256]
	get_configsdir(szFilename, charsmax(szFilename))
	format(szFilename, charsmax(szFilename), "%s/%s", szFilename, FILE_CONFIG)

	new iFilePointer = fopen(szFilename, "rt")

	if(iFilePointer)
	{
		new eItem[RestrictionData], Regex:iRegex, bool:bQueue, iMaxLevels, iSize, iLine, i
		new szData[MAX_CMDLINE_LENGTH + MAX_STATUS_LENGTH + MAX_TYPE_LENGTH + MAX_MSG_LENGTH], szStatus[MAX_TYPE_LENGTH], szType[MAX_STATUS_LENGTH]
		new szTemp[2][MAX_TIME_LENGTH], szKey[MAX_NAME_LENGTH], szValue[MAX_NAME_LENGTH]

		if(g_bRankSystem)
		{
			iMaxLevels = crxranks_get_max_levels()
		}

		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)
			iLine++

			switch(szData[0])
			{
				case EOS, '#', ';': continue
				case '[':
				{
					if(bQueue && g_iTotalCommands > INVALID_ENTRY)
					{
						register_commands_in_queue()
					}

					iSize = strlen(szData)

					if(szData[iSize - 1] != ']')
					{
						log_config_error(iLine, "Closing bracket not found for command ^"%s^"", szData[1])
						continue
					}

					szData[0] = ' '
					szData[iSize - 1] = ' '
					trim(szData)

					if(contain(szData, ",") != -1)
					{
						strtok(szData, szData, charsmax(szData), g_szQueue, charsmax(g_szQueue), ',')
						trim(szData); trim(g_szQueue)
						bQueue = true
					}
					else
					{
						bQueue = false
					}

					if(contain(szData, CMD_ARG_SAY) != -1)
					{
						replace(szData, charsmax(szData), CMD_ARG_SAY, "")
						strtolower(szData)
						trim(szData)
					}
					else
					{
						register_clcmd(szData, "OnRestrictedCommand")
					}

					g_aRestrictions[++g_iTotalCommands] = ArrayCreate(RestrictionData)
					TrieSetCell(g_tCommands, szData, g_iTotalCommands)

					#if defined CRX_CMDRESTRICTIONS_DEBUG
					log_config_error(_, "RN #%i: %s", g_iTotalCommands, szData)
					#endif
				}
				default:
				{
					eItem[Message][0] = EOS
					eItem[ValueString][0] = EOS

					parse(szData, szStatus, charsmax(szStatus), szType, charsmax(szType), eItem[ValueString], charsmax(eItem[ValueString]), eItem[Message], charsmax(eItem[Message]))

					switch(szStatus[0])
					{
						case 'A', 'a': eItem[Status] = STATUS_ALLOW
						case 'B', 'b': eItem[Status] = STATUS_BLOCK
						case 'P', 'p': eItem[Status] = STATUS_PASS
						case 'S', 's': eItem[Status] = STATUS_STOP
						default:
						{
							log_config_error(iLine, "Unknown status type ^"%s^"", szStatus)
							continue
						}
					}

					if(!eItem[ValueString][0] && !equal(szType, "all"))
					{
						log_config_error(iLine, "Restriction value is empty")
						continue
					}

					if(equal(szType, "all"))
					{
						eItem[Type] = TYPE_ALL
					}
					else if(equal(szType, "name"))
					{
						eItem[Type] = TYPE_NAME
						strtolower(eItem[ValueString])
					}
					else if(equal(szType, "ip"))
					{
						eItem[Type] = TYPE_IP
					}
					else if(equal(szType, "steam"))
					{
						eItem[Type] = TYPE_STEAM
					}
					else if(equal(szType, "flag") || equal(szType, "flags"))
					{
						eItem[Type] = TYPE_FLAGS
						eItem[ValueInt][0] = read_flags(eItem[ValueString])
					}
					else if(equal(szType, "anyflag") || equal(szType, "anyflags"))
					{
						eItem[Type] = TYPE_ANY_FLAG
						eItem[ValueInt][0] = read_flags(eItem[ValueString])
					}
					else if(equal(szType, "team"))
					{
						if(!g_bIsCstrike)
						{
							error_only_cstrike(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_TEAM

						switch(eItem[ValueString][0])
						{
							case 'C', 'c': eItem[ValueTeam] = _:CS_TEAM_CT
							case 'T', 't': eItem[ValueTeam] = _:CS_TEAM_T
							case 'S', 's': eItem[ValueTeam] = _:CS_TEAM_SPECTATOR
							case 'U', 'u': eItem[ValueTeam] = _:CS_TEAM_UNASSIGNED
							default:
							{
								log_config_error(iLine, "Unknown team name ^"%s^"", eItem[ValueString])
								continue
							}
						}
					}
					else if(equal(szType, "rank"))
					{
						if(!g_bIsCstrike)
						{
							error_only_cstrike(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CSSTATS_RANK
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else if(equal(szType, "kills"))
					{
						if(!g_bIsCstrike)
						{
							error_only_cstrike(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CSSTATS_KILLS
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else if(equal(szType, "deaths"))
					{
						if(!g_bIsCstrike)
						{
							error_only_cstrike(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CSSTATS_DEATHS
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else if(equal(szType, "headshots"))
					{
						if(!g_bIsCstrike)
						{
							error_only_cstrike(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CSSTATS_HEADSHOTS
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else if(equal(szType, "score"))
					{
						eItem[Type] = TYPE_SCORE
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else if(equal(szType, "time"))
					{
						eItem[Type] = TYPE_TIME
						iRegex = regex_match(eItem[ValueString], REGEX_TIME_PATTERN, i, "", 0)

						if(_:iRegex <= 0)
						{
							log_config_error(iLine, "Wrong time format. Expected ^"Hr:Min - Hr:Min^"")
							continue
						}

						for(i = 0; i < 2; i++)
						{
							regex_substr(iRegex, i + 1, szTemp[i], charsmax(szTemp[]))
							eItem[ValueInt][i] = time_to_num(szTemp[i], charsmax(szTemp[]))

							if(eItem[ValueInt][i] < 0 || eItem[ValueInt][i] > 2359)
							{
								log_config_error(iLine, "Invalid time ^"%i^"", eItem[ValueInt][i])
								continue
							}
						}
					}
					else if(equal(szType, "life"))
					{
						eItem[Type] = TYPE_LIFE

						switch(eItem[ValueString][0])
						{
							case 'A', 'a': eItem[ValueInt][0] = 1
							case 'D', 'd': eItem[ValueInt][0] = 0
							default:
							{
								log_config_error(iLine, "Unknown life status ^"%s^"", eItem[ValueString])
								continue
							}
						}
					}
					else if(equal(szType, "map"))
					{
						eItem[Type] = TYPE_MAP

						if(contain(eItem[ValueString], "*") != -1)
						{
							strtok(eItem[ValueString], szKey, charsmax(szKey), szValue, charsmax(szValue), '*')
							copy(szValue, strlen(szKey), g_szMap)
							eItem[ValueInt][0] = equali(szValue, szKey)
						}
						else
						{
							eItem[ValueInt][0] = equali(eItem[ValueString], g_szMap)
						}
					}
					else if(equal(szType, "level"))
					{
						if(!g_bRankSystem)
						{
							error_no_crxranks(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CRXRANKS_LEVEL
						eItem[ValueInt][0] = max(str_to_num(eItem[ValueString]), iMaxLevels)
					}
					else if(equal(szType, "xp"))
					{
						if(!g_bRankSystem)
						{
							error_no_crxranks(iLine, szType)
							continue
						}

						eItem[Type] = TYPE_CRXRANKS_XP
						eItem[ValueInt][0] = str_to_num(eItem[ValueString])
					}
					else
					{
						log_config_error(iLine, "Unknown restriction type ^"%s^"", szType)
						continue
					}

					g_iRestrictions[g_iTotalCommands]++
					ArrayPushArray(g_aRestrictions[g_iTotalCommands], eItem)
				}
			}
		}

		fclose(iFilePointer)

		if(bQueue)
		{
			register_commands_in_queue()
		}

		if(g_iTotalCommands == INVALID_ENTRY)
		{
			log_config_error(_, "No command restrictions found.")
			pause("ad")
		}
	}
	else
	{
		log_config_error(_, "Configuration file not found or cannot be opened.")
		pause("ad")
	}
}

public OnSay(id)
{
	new szArg[MAX_CMD_LENGTH], szCommand[MAX_CMD_LENGTH]

	read_argv(1, szArg, charsmax(szArg))
	parse(szArg, szCommand, charsmax(szCommand), szArg, charsmax(szArg))
	strtolower(szCommand)

	if(!TrieKeyExists(g_tCommands, szCommand))
	{
		return PLUGIN_CONTINUE
	}

	return is_restricted(id, szCommand) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}

public OnRestrictedCommand(id)
{
	new szCommand[MAX_CMD_LENGTH]
	read_argv(0, szCommand, charsmax(szCommand))
	return is_restricted(id, szCommand) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}

bool:is_restricted(const id, const szCommand[])
{
	new eItem[RestrictionData], szMessage[MAX_MSG_LENGTH], iCommand, iStatus
	TrieGetCell(g_tCommands, szCommand, iCommand)

	for(new bool:bMatch, bool:bStats, iStats[STATSX_MAX_STATS], iHits[MAX_BODYHITS], i; i < g_iRestrictions[iCommand]; i++)
	{
		ArrayGetArray(g_aRestrictions[iCommand], i, eItem)

		switch(eItem[Type])
		{
			case TYPE_ALL:
			{
				bMatch = true
			}
			case TYPE_NAME:
			{
				if(equal(g_ePlayerData[id][PDATA_NAME], eItem[ValueString]))
				{
					bMatch = true
				}
			}
			case TYPE_IP:
			{
				if(equal(g_ePlayerData[id][PDATA_IP], eItem[ValueString]))
				{
					bMatch = true
				}
			}
			case TYPE_STEAM:
			{
				if(equal(g_ePlayerData[id][PDATA_STEAM], eItem[ValueString]))
				{
					bMatch = true
				}
			}
			case TYPE_FLAGS:
			{
				if((get_user_flags(id) & eItem[ValueInt][0]) == eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_ANY_FLAG:
			{
				if(get_user_flags(id) & eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_TEAM:
			{
				if(cs_get_user_team(id) == eItem[ValueTeam])
				{
					bMatch = true
				}
			}
			case TYPE_CSSTATS_RANK:
			{
				if(!bStats)
				{
					bStats = true
					get_user_stats(id, iStats, iHits)
				}

				if(iStats[STATSX_RANK] <= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_CSSTATS_KILLS:
			{
				if(!bStats)
				{
					bStats = true
					get_user_stats(id, iStats, iHits)
				}

				if(iStats[STATSX_KILLS] >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_CSSTATS_DEATHS:
			{
				if(!bStats)
				{
					bStats = true
					get_user_stats(id, iStats, iHits)
				}

				if(iStats[STATSX_DEATHS] >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_CSSTATS_HEADSHOTS:
			{
				if(!bStats)
				{
					bStats = true
					get_user_stats(id, iStats, iHits)
				}

				if(iStats[STATSX_HEADSHOTS] >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_SCORE:
			{
				if(get_user_frags(id) >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_LIFE:
			{
				if(is_user_alive(id) == eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_TIME:
			{
				if(is_current_time(eItem[ValueInt][0], eItem[ValueInt][1]))
				{
					bMatch = true
				}
			}
			case TYPE_MAP:
			{
				if(eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_CRXRANKS_LEVEL:
			{
				if(crxranks_get_user_level(id) >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
			case TYPE_CRXRANKS_XP:
			{
				if(crxranks_get_user_xp(id) >= eItem[ValueInt][0])
				{
					bMatch = true
				}
			}
		}

		if(bMatch)
		{
			iStatus = eItem[Status]

			if(iStatus == STATUS_BLOCK || iStatus == STATUS_STOP)
			{
				if(eItem[Message][0])
				{
					copy(szMessage, charsmax(szMessage), eItem[Message])
				}
			}

			if(iStatus == STATUS_PASS || iStatus == STATUS_STOP)
			{
				break
			}
		}

		bMatch = false
	}

	if(iStatus == STATUS_BLOCK || iStatus == STATUS_STOP)
	{
		if(szMessage[0])
		{
			if(equal(szMessage, ARG_NO_MSG))
			{
				return true
			}

			replace_all(szMessage, charsmax(szMessage), ARG_COMMAND, szCommand)
			client_print(id, print_console, szMessage)

			if(g_bIsCstrike)
			{
				CC_SendMessage(id, szMessage)
			}
			else
			{
				client_print(id, print_chat, szMessage)
			}
		}
		else
		{
			client_print(id, print_console, "%L (%s)", id, "NO_ACC_COM", szCommand)

			if(g_bIsCstrike)
			{
				CC_SendMessage(id, "&x07%L &x01(&x04%s&x01)", id, "NO_ACC_COM", szCommand)
			}
			else
			{
				client_print(id, print_chat, "%L (%s)", id, "NO_ACC_COM", szCommand)
			}
		}

		return true
	}

	return false
}

bool:is_current_time(const iStart, const iEnd)
{
	new szTime[MAX_TIME_LENGTH]
	get_time(TIME_FORMAT, szTime, charsmax(szTime))

	new iTime = time_to_num(szTime, charsmax(szTime))

	return (iStart < iEnd ? (iStart <= iTime <= iEnd) : (iStart <= iTime || iTime < iEnd))
}

time_to_num(szTime[MAX_TIME_LENGTH], iLen)
{
	replace(szTime, iLen, ":", "")
	return str_to_num(szTime)
}

register_commands_in_queue()
{
	static szData[MAX_CMDLINE_LENGTH]

	while(g_szQueue[0] != 0 && strtok(g_szQueue, szData, charsmax(szData), g_szQueue, charsmax(g_szQueue), ','))
	{
		trim(g_szQueue); trim(szData)

		if(contain(szData, CMD_ARG_SAY) != -1)
		{
			replace(szData, charsmax(szData), CMD_ARG_SAY, "")
			trim(szData)
		}
		else
		{
			register_clcmd(szData, "OnRestrictedCommand")
		}

		TrieSetCell(g_tCommands, szData, g_iTotalCommands)

		#if defined CRX_CMDRESTRICTIONS_DEBUG
		log_config_error(_, "RQ #%i: %s", g_iTotalCommands, szData)
		#endif
	}

	g_szQueue[0] = EOS
}

error_only_cstrike(const iLine = INVALID_ENTRY, const szType[])
{
	log_config_error(iLine, "Type ^"%s^" is only available for Counter-Strike", szType)
}

error_no_crxranks(const iLine = INVALID_ENTRY, const szType[])
{
	log_config_error(iLine, "Can't use type ^"%s^" when OciXCrom's Rank System is not running", szType)
}

log_config_error(const iLine = INVALID_ENTRY, const szInput[], any:...)
{
	new szError[128]
	vformat(szError, charsmax(szError), szInput, 3)

	if(iLine == INVALID_ENTRY)
	{
		log_to_file(FILE_LOGS, "%s: %s", FILE_CONFIG, szError)
	}
	else
	{
		log_to_file(FILE_LOGS, "%s (%i): %s", FILE_CONFIG, iLine, szError)
	}
}
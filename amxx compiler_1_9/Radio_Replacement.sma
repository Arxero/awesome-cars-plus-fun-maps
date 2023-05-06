/*	Formatright © 2010, ConnorMcLeod

	This plugin is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this plugin; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/*
* v0.5.0 (09 april 2011)
* Rewritten most of plugin
* Use cs standarts : pdatas for plugins compatibility, dead players can hear/see radios
* Added support for plugin : http://forums.alliedmods.net/showthread.php?t=104675
* Optimized code
* 
* v0.4.5 (05 may 2009)
* change get_user_team with cs team offset as for
* some reasons radios were sent to wrong team players...
* 
* v0.4.3 (05 feb 2008)
* fixed bad colored text in czero
*
* v0.4.2 (02 feb 2008)
* fixed event Location, first argument have to be equal to player id
*
* v0.4 (01 feb 2008)
* now supports czero located radio messages
* can run safely with realradio plugin (changed TextMsg emessage_begin -> message_begin)
*
* v0.3 (14 jan 2008)
* supports ML
* added ML radio chat messages
* chat messages can be disabled
* supports funradio plugin by VEN
* added realradio feature
*
* v0.2
* amxx port
*
* v0.1 (07 apr 2007)
* First amx release http://djeyl.net/forum/index.php?showtopic=54146 // forum is dead
*/

#include <amxmodx>
#include <fakemeta>

#define VERSION	"0.5.0"

#define MAX_PLAYERS	32

#define XO_PLAYER 5
#define m_iTeam 114
#define m_flNextRadioGameTime 191
#define m_iRadiosLeft 192
#define m_iDefusePlantLol 193

const SILENT_RADIO = (1<<0)

#define cs_get_user_team_index(%0)		get_pdata_int(%0, m_iTeam, XO_PLAYER)
#define cs_get_user_radio_next(%0)		get_pdata_float(%0, m_flNextRadioGameTime, XO_PLAYER)
#define cs_set_user_radio_next(%0,%1)	set_pdata_float(%0, m_flNextRadioGameTime, %1, XO_PLAYER)
#define cs_get_user_radio_num(%0)		get_pdata_int(%0, m_iRadiosLeft, XO_PLAYER)
#define cs_set_user_radio_num(%0,%1)	set_pdata_int(%0, m_iRadiosLeft, %1, XO_PLAYER)
#define cs_get_user_radio_banned(%0)	(get_pdata_int(%0, m_iDefusePlantLol, XO_PLAYER) & SILENT_RADIO)

#define NumToString(%0,%1,%2)	formatex(%1, %2, "%d", %0)

const KEYS = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

#define PRINT_RADIO		5
#define PITCH_RADIO	100  // have to be 100 for funradio plugin compatibility
#define CVAR_FUNRADIO  "amx_funradio_playspeed"

new g_iMenuId[MAX_PLAYERS+1]
new bool:g_bRealRadio
new bool:g_bLocation
new g_szLocation[MAX_PLAYERS+1][32]
new gmsgSendAudio, gmsgTextMsg
new g_pcvarRadioReplacement, g_pcvarRadioNoChat, g_pcvarFunRadio, g_pCvarRadioDelay

new const g_szSoundsShortNames[][] = {
	"ct_coverme", "takepoint", "position", "regroup", "followme", "fireassis", "letsgo", "matedown", "flankthem",
	"com_go", "fallback", "sticktog", "com_getinpos", "stormfront", "com_reportin", "getout", "elim", "roger",
	"ct_affirm", "ct_enemys", "ct_backup", "clear", "ct_inpos", "ct_reportingin", "blow", "negative", "enemydown",
	"ct_point", "com_followcom",  "meetme",  "moveout",  "hosdown",  "ct_imhit",  "hitassist",  "circleback",  "locknload"
}

new const g_szChatRadioMsgsML[][] = {
	"RR_MSG_COVERME", "RR_MSG_TAKEPOS", "RR_MSG_HOLDPOS", "RR_MSG_REGROUP", "RR_MSG_FOLLOWME",
		"RR_MSG_TAKINGFIRE", "RR_MSG_LETSGO", "RR_MSG_MATEDOWN", "RR_MSG_FLANKTHEM",
	"RR_MSG_GOGOGO", "RR_MSG_FALLBACK", "RR_MSG_STICKTOG", "RR_MSG_GETINPOS", "RR_MSG_STORMFRONT",
		"RR_MSG_REPORT", "RR_MSG_GETOUT", "RR_MSG_ELIMIN", "RR_MSG_ROGER",
	"RR_MSG_AFFIRM", "RR_MSG_ENEMYSPOTTED", "RR_MSG_NEEDBACKUP", "RR_MSG_SECTORCLEAR", "RR_MSG_INPOSITION",
		"RR_MSG_REPORTING", "RR_MSG_GETOUTBLOW", "RR_MSG_NEGATIVE", "RR_MSG_ENEMYDOWN",
	"RR_MSG_ITAKEPOINT", "RR_MSG_FOLLOWCOM", "RR_MSG_RENDEZVOUS", "RR_MSG_MOUVEOUT", "RR_MSG_HOSDOWN",
		"RR_MSG_IMHIT", "RR_MSG_HITASSIST", "RR_MSG_CIRCLEBACK", "RR_MSG_LOCKNLOAD"	
}

new const g_szMenuNamesML[][] = {
	"RR_RADIO_1", "RR_RADIO_2", "RR_RADIO_3", "RR_RADIO_4"
}

public plugin_precache()
{
	new pCvar = register_cvar("amx_radio_real", "0")

	if( get_pcvar_num(pCvar) )
	{
		g_bRealRadio = true

		new szSound[32]
		for(new i; i<sizeof(g_szSoundsShortNames); i++)
		{
			formatex(szSound, charsmax(szSound), "radio/%s.wav", g_szSoundsShortNames[i])
			precache_sound(szSound)
		}
	}
}

public plugin_init()
{
	register_plugin("Radio Replacement", VERSION, "ConnorMcLeod")
	register_dictionary("radio_replacement.txt")

	g_pcvarRadioReplacement = register_cvar("amx_radio_replacement", "1")
	g_pcvarRadioNoChat = register_cvar("amx_radio_nochat", "0")

	new a

	new szMenuCmds[][] = {"radio1", "radio2", "radio3", "radio4"}
	for(a = 0; a < sizeof(szMenuCmds); ++a)
	{
		register_menucmd(register_menuid(g_szMenuNamesML[a]), KEYS ,"RadioMenuHandler")
		register_clcmd(szMenuCmds[a],"ClCmd_RadioMenu")
	}

	new szAliases[][] = {
	"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", 0, 0, 0,
	"go", "fallback", "sticktog", "getinpos", "stormfront", "report", 0, 0, 0,
	"roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown"
	}
	for(a = 0; a < sizeof(szAliases); ++a)
	{
		if(szAliases[a][0])
		{
			register_clcmd(szAliases[a], "ClCmd_RadioAlias", a /* tip, not an access flag*/, _, 0 /* has to stay 0 */)
		}
	}

	gmsgSendAudio = get_user_msgid("SendAudio")
	gmsgTextMsg = get_user_msgid("TextMsg")
	g_pcvarFunRadio = get_cvar_pointer(CVAR_FUNRADIO)

	new szModName[7]
	get_modname(szModName, charsmax(szModName))
	if(equal(szModName, "czero"))
	{
		register_event("Location", "Event_Location", "be")
	}
}

public plugin_cfg()
{
	g_pCvarRadioDelay = get_cvar_pointer("amx_radio_delay") // check for external cvar
	if( !g_pCvarRadioDelay )
	{
		g_pCvarRadioDelay = register_cvar("amx_radio_delay", "1.5") // cs default 1.5
	}
}

public Event_Location(id)
{
	if(!g_bLocation)
	{
		g_bLocation = true
	}

	if(read_data(1) == id)
	{
		read_data(2, g_szLocation[id], charsmax(g_szLocation[]))
	}
}

public ClCmd_RadioAlias(id, iAlias /* tip, not an access flag */)
{
	if( get_pcvar_num(g_pcvarRadioReplacement) && is_user_alive(id) )
	{
		do_radio(id, iAlias)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public ClCmd_RadioMenu(id)
{
	if( get_pcvar_num(g_pcvarRadioReplacement) && is_user_alive(id) )
	{
		new szCmd[7]
		read_argv(0, szCmd, charsmax(szCmd))

		static szMenu[1024]
		new ML_MENU[10], iMenuId = g_iMenuId[id] = szCmd[5] - '1'
		formatex(ML_MENU, charsmax(ML_MENU), "RR_MENU_%d", iMenuId + 1)
		formatex(szMenu, charsmax(szMenu), "%L", id, ML_MENU)

		show_menu(id, KEYS, szMenu, -1, g_szMenuNamesML[iMenuId])

		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public RadioMenuHandler(id, iKey)
{
	if( iKey != 9 && is_user_alive(id) )
	{
		do_radio(id, iKey + g_iMenuId[id] * 9)
	}
	return PLUGIN_HANDLED
}

do_radio(id, iWitchOne)
{
	new Float:fTime = get_gametime()

	if( cs_get_user_radio_next(id) > fTime )
	{
		return 0
	}

	new iRadiosLeft = cs_get_user_radio_num(id)
	if( !iRadiosLeft )
	{
		return 0
	}

	cs_set_user_radio_next(id, fTime + get_pcvar_float(g_pCvarRadioDelay))
	cs_set_user_radio_num(id, iRadiosLeft - 1)

	new iSenderTeam = cs_get_user_team_index( id )
	new szSample[32]

	formatex(szSample, charsmax(szSample), "radio/%s.wav", g_szSoundsShortNames[iWitchOne])

	new szId[3], szMessage[64], szName[32], szLocation[32]
	new bool:bChat = !get_pcvar_num(g_pcvarRadioNoChat)

	if(bChat)
	{
		NumToString(id, szId, charsmax(szId))
		if( g_bLocation )
		{
			copy(szLocation, charsmax(szLocation), g_szLocation[id][1])
		}
		get_user_name(id, szName, charsmax(szName))
	}

	new iPlayers[32], iNum, iPlayer
	get_players(iPlayers, iNum, "h")
	for(--iNum; iNum>=0; iNum--)
	{
		iPlayer = iPlayers[iNum]
		if( cs_get_user_team_index( iPlayer ) == iSenderTeam && !cs_get_user_radio_banned(iPlayer) )
		{
			if(bChat)
			{
				formatex(szMessage, charsmax(szMessage), "%L", iPlayer, g_szChatRadioMsgsML[iWitchOne])

				// emessage in case a plugin would alter default text
				emessage_begin(MSG_ONE_UNRELIABLE, gmsgTextMsg, .player=iPlayer)
				ewrite_byte(PRINT_RADIO)
				ewrite_string(szId)
				if(g_bLocation)
				{
					ewrite_string("#Game_radio_location")
					ewrite_string(szName)
					ewrite_string(szLocation)
				}
				else
				{
					ewrite_string("#Game_radio")
					ewrite_string(szName)
				}
				ewrite_string(szMessage)
				emessage_end()
			}

			if( !g_bRealRadio || iPlayer != id ) // if( !(g_bRealRadio && iPlayer == id) )
			{
				 // emessage : so funradio plugin is supported
				emessage_begin(MSG_ONE_UNRELIABLE, gmsgSendAudio, .player=iPlayer)
				ewrite_byte(id)
				ewrite_string(szSample)
				ewrite_short(PITCH_RADIO)
				emessage_end()
			}
		}
	}

	if(g_bRealRadio)
	{
		emit_sound(id, CHAN_VOICE, szSample, VOL_NORM, ATTN_STATIC, 0, g_pcvarFunRadio ? get_pcvar_num(g_pcvarFunRadio) : PITCH_RADIO)
	}

	return 1
}
/*	Copyright © 2008, ConnorMcLeod

	Custom Flashligh is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Custom Flashligh; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/*
* v0.5.4 (10.20.09)
* attempt to fix the bug when you can re-activate fl when empty
*
* v0.5.3 (09/01/09)
* -fixed little errors due to version change
* -added player range check in death event
*
* v0.5.2 (07/23/09)
* -fixed inverted teams colors
*
* v0.5.1 (04/04/09)
* -haven't realised i can remove FM include
*
* v0.5.0 (04/03/09)
* - use register_think instead of FM_CmdStart
* - use client_PreThink instead of FM_PlayerPreThink
* - use get_user_origin mode 1 and 3 instead of fakemeta stock
* - replaced some FM natives+enums with amxx natives (emit_sound, write_coord)
*
* v0.4.0 (07/27/08)
* - replaced cvars with commands
* - .ini file now supports prefix/per map configs
*
* v0.3.1 (06/29/08)
* - fixed bug when you could have seen normal flashlight
*
* v0.3.0 (06/21/08)
*
* - some code optimizations (thanks to simon logic and jim_yang)
* - changes cvars flashlight_drainfreq and flashlight_chargefreq to
*  flashlight_fulldrain_time and flashlight_fullcharge_time
*  (simon logic suggestion)
* - moved random colors into $CONFIGSDIR/flashlight_colors.ini
*
* v0.2.0
* First public release
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN "Custom Flashlight"
#define AUTHOR "ConnorMcLeod"
#define VERSION "0.5.4"

/* **************************** CUSTOMIZATION AREA ******************************** */

new const SOUND_FLASHLIGHT_ON[] = "items/flashlight1.wav"
new const SOUND_FLASHLIGHT_OFF[] = "items/flashlight1.wav"

#define LIFE	1	// try 2 if light is flickering

/* ******************************************************************************** */

#define MAX_PLAYERS	32

enum {
	Red,
	Green,
	Blue
}

new Array:g_aColors
new g_iColorsNum

new g_iMaxPlayers

new bool:g_bFlashLight[MAX_PLAYERS+1]
new g_iFlashBattery[MAX_PLAYERS+1]
new Float:g_flFlashLightTime[MAX_PLAYERS+1]

new g_iColor[MAX_PLAYERS+1][3]
new g_iTeamColor[2][3]

new g_msgidFlashlight, g_msgidFlashBat

new g_bEnabled = true
new g_iShowAll = 1
new g_iColorType = 0
new g_iRadius = 9
new g_iAttenuation = 5
new g_iDistanceMax = 2000

new Float:g_flDrain = 1.2
new Float:g_flCharge = 0.2

public plugin_precache()
{
	precache_sound(SOUND_FLASHLIGHT_ON)
	precache_sound(SOUND_FLASHLIGHT_OFF)
}

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR )

	register_concmd("flashlight_set", "plugin_settings", ADMIN_CFG)

	register_impulse(100, "Impulse_100")

	register_event("HLTV", "Event_HLTV_newround", "a", "1=0", "2=0")
	register_event("DeathMsg", "Event_DeathMsg", "a")

	plugin_precfg()
}

plugin_precfg()
{
	g_iTeamColor[1] = {255,0,0}
	g_iTeamColor[0] = {0,0,255}

	g_msgidFlashlight = get_user_msgid("Flashlight")
	g_msgidFlashBat = get_user_msgid("FlashBat")

	g_iMaxPlayers = get_maxplayers()

	new szConfigFile[128], szCurMap[64], szConfigDir[128], i, szTemp[128]

	get_localinfo("amxx_configsdir", szConfigDir, charsmax(szConfigDir))
	formatex(szConfigFile, 127, "%s/flashlight_colors.ini", szConfigDir)
	get_mapname(szCurMap, 63)

	while(szCurMap[i] != '_' && szCurMap[i++] != '^0') {/*do nothing*/}
	
	if (szCurMap[i]=='_')
	{
		// this map has a prefix
		szCurMap[i]='^0';
		formatex(szTemp, 127, "%s/flashlight/prefix_%s.ini", szConfigDir, szCurMap)
		if(file_exists(szTemp))
		{
			copy(szConfigFile, 127, szTemp)
		}
	}

	get_mapname(szCurMap, 63)	
	formatex(szTemp, 127, "%s/flashlight/%s.ini", szConfigDir, szCurMap)
	if (file_exists(szTemp))
	{
		copy(szConfigFile, 127, szTemp)
	}

	new iFile = fopen(szConfigFile, "rt")
	if(!iFile)
	{
		return
	}

	g_aColors = ArrayCreate(3)

	new szColors[12], szRed[4], szGreen[4], szBlue[4], iColor[3]
	while(!feof(iFile))
	{
		fgets(iFile, szColors, 11)
		trim(szColors)
		if(!szColors[0] || szColors[0] == ';' || (szColors[0] == '/' && szColors[1] == '/'))
			continue
		parse(szColors, szRed, 3, szGreen, 3, szBlue, 3)
		iColor[Red] = str_to_num(szRed)
		iColor[Green] = str_to_num(szGreen)
		iColor[Blue] = str_to_num(szBlue)
		ArrayPushArray(g_aColors, iColor)
	}
	fclose(iFile)

	g_iColorsNum = ArraySize(g_aColors)
}

public plugin_settings(id, level, cid)
{
	if( !cmd_access(id, level, cid, 3) )
	{
		return PLUGIN_HANDLED
	}

	new szCommand[8], szValue[10]
	read_argv(1, szCommand, 7)
	read_argv(2, szValue, 9)
	switch( szCommand[0] )
	{
		case 'a': g_iAttenuation = str_to_num(szValue)
		case 'c':
		{
			switch( szCommand[5] )
			{
				case 'c': 
				{				
					new iColor
					iColor = str_to_num(szValue)
					g_iTeamColor[0][Red] = (iColor / 1000000)
					iColor %= 1000000 
					g_iTeamColor[0][Green] = (iColor / 1000)
					g_iTeamColor[0][Blue] = (iColor % 1000)
				}
				case 'e': g_flCharge = str_to_float(szValue) / 100
				case 'm': g_bEnabled = str_to_num(szValue)
				case 't':
				{
					if( szCommand[6] == 'e' )
					{
						new iColor
						iColor = str_to_num(szValue)
						g_iTeamColor[1][Red] = (iColor / 1000000)
						iColor %= 1000000 
						g_iTeamColor[1][Green] = (iColor / 1000)
						g_iTeamColor[1][Blue] = (iColor % 1000)
					}
					else
					{
						g_iColorType = str_to_num(szValue)
					}
				}
			}
		}
		case 'd':
		{
			if( szCommand[1] == 'i' )
			{
				g_iDistanceMax = str_to_num(szValue)
			}
			else
			{
				g_flDrain = str_to_float(szValue) / 100
			}
		}
		case 'r': g_iRadius = str_to_num(szValue)
		case 's': g_iShowAll = str_to_num(szValue)
	}
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	reset(id)
}

public Event_HLTV_newround()
{
	for(new id=1; id<=g_iMaxPlayers; id++)
	{
		reset(id)
	}
}

public Event_DeathMsg()
{
	reset(read_data(2))
}

reset(id)
{
    if( 1 <= id <= g_iMaxPlayers )
    {
        g_iFlashBattery[id] = 100
        g_bFlashLight[id] = false
        g_flFlashLightTime[id] = 0.0
    }
}  

public Impulse_100( id )
{
	if( g_bEnabled )
	{
		if(is_user_alive(id))
		{
			if( g_bFlashLight[id] )
			{
				FlashlightTurnOff(id)
			}
			else if( g_iFlashBattery[id] )
			{
				FlashlightTurnOn(id)
			}
		}
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	static Float:flTime
	flTime = get_gametime()
	
	if(g_flDrain && g_flFlashLightTime[id] && g_flFlashLightTime[id] <= flTime)
	{
		if(g_bFlashLight[id])
		{
			if(g_iFlashBattery[id])
			{
				g_flFlashLightTime[id] = g_flDrain + flTime
				g_iFlashBattery[id]--
				
				if(!g_iFlashBattery[id])
				{
					FlashlightTurnOff(id)
				}
			}
		}
		else
		{
			if(g_iFlashBattery[id] < 100)
			{
				g_flFlashLightTime[id] = g_flCharge + flTime
				g_iFlashBattery[id]++
			}
			else
				g_flFlashLightTime[id] = 0.0
		}

		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashBat, _, id)
		write_byte(g_iFlashBattery[id])
		message_end()

	}
	if(g_bFlashLight[id])
	{
		Make_FlashLight(id)
	}
}

Make_FlashLight(id)
{
	static iOrigin[3], iAim[3], iDist
	get_user_origin(id, iOrigin, 1)
	get_user_origin(id, iAim, 3)

	iDist = get_distance(iOrigin, iAim)

	if( iDist > g_iDistanceMax )
		return

	static iDecay, iAttn

	iDecay = iDist * 255 / g_iDistanceMax
	iAttn = 256 + iDecay * g_iAttenuation // barney/dontaskme

	if( g_iShowAll )
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	}
	else
	{
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	}
	write_byte( TE_DLIGHT )
	write_coord( iAim[0] )
	write_coord( iAim[1] )
	write_coord( iAim[2] )
	write_byte( g_iRadius )
	write_byte( (g_iColor[id][Red]<<8) / iAttn )
	write_byte( (g_iColor[id][Green]<<8) / iAttn )
	write_byte( (g_iColor[id][Blue]<<8) / iAttn )
	write_byte( LIFE )
	write_byte( iDecay )
	message_end()
}

FlashlightTurnOff(id)
{
	emit_sound(id, CHAN_WEAPON, SOUND_FLASHLIGHT_OFF, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	g_bFlashLight[id] = false

	FlashlightHudDraw(id, 0)

	g_flFlashLightTime[id] = g_flCharge + get_gametime()
}

FlashlightTurnOn(id)
{
	emit_sound(id, CHAN_WEAPON, SOUND_FLASHLIGHT_ON, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	g_bFlashLight[id] = true

	FlashlightHudDraw(id, 1)

	if( g_iColorType || !g_iColorsNum )
	{		
		g_iColor[id] = g_iTeamColor[2-get_user_team(id)]
	}
	else
	{
		ArrayGetArray(g_aColors, random(g_iColorsNum), g_iColor[id])
	}

	g_flFlashLightTime[id] = g_flDrain + get_gametime()
}

FlashlightHudDraw(id, iFlag)
{
	if( g_iShowAll )
	{
		emessage_begin(MSG_ONE_UNRELIABLE, g_msgidFlashlight, _, id)
		ewrite_byte(iFlag)
		ewrite_byte(g_iFlashBattery[id])
		emessage_end()
	}
	else
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgidFlashlight, _, id)
		write_byte(iFlag)
		write_byte(g_iFlashBattery[id])
		message_end()
	}
}
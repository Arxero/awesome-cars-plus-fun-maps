#include <amxmodx>
#include <amxmisc>

enum
{
	RED = 1,
	BLUE,
	YELLOW,
	GREEN
};

new Array:g_szMessages, Array:g_iColor, Array:g_iHoldTime;
new iMessages, iCurrentMsg, iMaxPlayers, iTutorText, iTutorClose, p_flAdTime;

public plugin_init()
{
	register_plugin("Tutor Advertisments", "1.0", "TheRedShoko");
	
	register_cvar("tutor_advertisments", "1.0", FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED);
	
	register_concmd("amx_reload_tutormsg", "AdminReloadMessages", ADMIN_RCON);
	
	p_flAdTime = register_cvar("tutorad_time", "240.0");
	
	iTutorText = get_user_msgid("TutorText");
	iTutorClose = get_user_msgid("TutorClose");
	iMaxPlayers = get_maxplayers();
	
	g_szMessages = ArrayCreate(256, 1);
	g_iColor = ArrayCreate(8, 1);
	g_iHoldTime = ArrayCreate(8, 1);
	
	LoadFile();
	
	set_task(60.0, "ShowAdvertisment");
}

public plugin_precache()  
{
	new const szTutorPrecache[][] = 
	{
		"gfx/career/icon_!.tga",
		"gfx/career/icon_!-bigger.tga",
		"gfx/career/icon_i.tga",
		"gfx/career/icon_i-bigger.tga",
		"gfx/career/icon_skulls.tga",
		"gfx/career/round_corner_ne.tga",
		"gfx/career/round_corner_nw.tga",
		"gfx/career/round_corner_se.tga",
		"gfx/career/round_corner_sw.tga",
		"resource/TutorScheme.res",
		"resource/UI/TutorTextWindow.res"
	};
	
	for (new i = 0; i < sizeof(szTutorPrecache); i++)
	{
		precache_generic(szTutorPrecache[i]);
	}
}

public plugin_end()
{
	ArrayDestroy(g_szMessages);
	ArrayDestroy(g_iColor);
	ArrayDestroy(g_iHoldTime);
}

public AdminReloadMessages(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
	{
		return PLUGIN_HANDLED;
	}
	
	LoadFile();
	
	console_print(id, "Tutor advertisments has been reloaded. Loaded %i advertisments!", iMessages);
	
	return PLUGIN_HANDLED;
}

public LoadFile()
{
	ArrayClear(g_szMessages);
	ArrayClear(g_iColor);
	ArrayClear(g_iHoldTime);
	iMessages = 0;
	
	new szFile[128];
	get_configsdir(szFile, charsmax(szFile));
	add(szFile, charsmax(szFile), "/tutor_ads.ini");
	
	if (file_exists(szFile))
	{
		new iLine, szLine[256], iBuffer, szColor[8], szHoldTime[8], szText[256], iColor;
		
		while ((iLine = read_file(szFile, iLine, szLine, charsmax(szLine), iBuffer)) > 0)
		{
			if (szLine[0] == ';' || szLine[0] == EOS || szLine[0] == '/' && szLine[0] == '/') continue;
			
			parse(szLine, szText, charsmax(szText), szColor, charsmax(szColor), szHoldTime, charsmax(szHoldTime));
			
			ArrayPushString(g_szMessages, szText);
			
			switch(szColor[0])
			{
				case 'r', 'R': iColor = RED;
				case 'b', 'B': iColor = BLUE;
				case 'g', 'G': iColor = GREEN;
				default: iColor = YELLOW;
			}
			
			ArrayPushCell(g_iColor, iColor);
			ArrayPushCell(g_iHoldTime, str_to_float(szHoldTime));
			
			iMessages++;
		}
	}
	else
	{
		new iFile = fopen(szFile, "a+");
		
		if (iFile)
		{
			fputs(iFile, ";Tutor Advertisments by TheRedShoko^n");
			fputs(iFile, "; ^"Text^" Color: <R | G | B | Y> Hold time");
			
			fclose(iFile);
		}
	}
}

public ShowAdvertisment()
{
	set_task(get_pcvar_float(p_flAdTime), "ShowAdvertisment");
	
	if (iMessages == 0)
	{
		return;
	}
	
	if (iCurrentMsg >= iMessages)
	{
		iCurrentMsg = 0;
	}
	
	new szMessage[256], iColor, Float:flTime;
	ArrayGetString(g_szMessages, iCurrentMsg, szMessage, charsmax(szMessage));
	iColor = ArrayGetCell(g_iColor, iCurrentMsg);
	flTime = ArrayGetCell(g_iHoldTime, iCurrentMsg);
		
	SendTurtor(iColor, flTime, szMessage);

	++iCurrentMsg;
	iCurrentMsg %= iMessages;
}

SendTurtor(color, Float:holdtime, text[])
{
	for (new id = 1; id <= iMaxPlayers; id++)
	{
		if (!is_user_connected(id)) continue;
		
		message_begin(MSG_ONE_UNRELIABLE, iTutorText, _, id);
		write_string(text);
		write_byte(0);
		write_short(0);
		write_short(0);
		write_short(1<<color);
		message_end();
			
		set_task(holdtime, "RemoveTurtor", id);
	}
}

public RemoveTurtor(id)
{
	if (is_user_connected(id))
	{
		message_begin(MSG_ALL, iTutorClose, _, id);
		message_end();
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/

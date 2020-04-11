
#pragma dynamic			524288

#pragma tabsize			0

#pragma reqclass		xstats

#pragma defclasslib		xstats	csx
#pragma defclasslib		xstats	dodx
#pragma defclasslib		xstats	tfcx
#pragma defclasslib		xstats	tsx

#include < amxmodx >
#include < amxmisc >

#define QS_TEAM_TE							( 1 )
#define QS_TEAM_CT							( 2 )

#define QS_HUD_MESSAGE_HOLD_TIME			( 5.0 )
#define QS_HUD_MESSAGE_X_POSITION			( -1.0 )
#define QS_LAST_MAN_STANDING_Y_POSITION		( 0.1815 )

#define QS_PLUGIN_VERSION					( "1.0" )

new g_MaxPlayers =							0;

new g_MsgSyncObject_TE =					0;
new g_MsgSyncObject_CT =					0;

new bool: g_bEnabled						[ 33 ];

new g_ManStandingStrings	[ ] [ ] =
{
	"GUY",									"MAN STANDING"
};

new g_ManStandingSounds		[ ] [ ] =
{
	"QuakeSounds/oneandonly.wav",			"QuakeSounds/oneandonly.wav"
};

public plugin_natives ( )
{
	set_module_filter ( "QS_Module_Filter" );
}

public QS_Module_Filter ( Module [ ] )
{
	if ( equali ( Module, "XStats" ) )
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public plugin_precache ( )
{
	if ( QS_IsEnabled ( ) )
	{
		for ( new Iterator = 0; Iterator < sizeof ( g_ManStandingSounds ); Iterator ++ )
			precache_sound ( g_ManStandingSounds [ Iterator ] );
	}
}

public plugin_init ( )
{
	if ( QS_IsEnabled ( ) )
	{
		register_plugin			( "[QS] Man Standing (ENABLED)",	QS_PLUGIN_VERSION,	"HATTRICK (HTTRCKCLDHKS)" );

		g_MaxPlayers =			get_maxplayers ( );

		g_MsgSyncObject_TE =	CreateHudSyncObj ( );
		g_MsgSyncObject_CT =	CreateHudSyncObj ( );
	}

	else
		register_plugin			( "[QS] Man Standing (DISABLED)",	QS_PLUGIN_VERSION,	"HATTRICK (HTTRCKCLDHKS)" );
}

public client_putinserver ( Player )
{
	if ( QS_IsEnabled ( ) )
		g_bEnabled [ Player ] = true;
}

public client_command ( Player )
{
	static Argument [ 16 ];

	if ( QS_IsEnabled ( ) && is_user_connected ( Player ) && !is_user_bot ( Player ) && !is_user_hltv ( Player ) )
	{
		read_argv ( 1, Argument, charsmax ( Argument ) );

		if ( equali ( Argument, "/Sounds", 7 ) || equali ( Argument, "Sounds", 6 ) )
			g_bEnabled [ Player ] = !g_bEnabled [ Player ];
	}
}

public client_death ( Killer, Victim, Weapon, Place, TeamKill )
{
	if ( QS_IsEnabled ( ) )
		set_task ( 1.0,		"QS_PrepareManStanding" );
}

public QS_PrepareManStanding ( )
{
	if ( QS_GetSize ( QS_TEAM_TE ) == 1 || QS_GetSize ( QS_TEAM_CT ) == 1 )
		set_task ( 0.0,		"QS_DoManStanding" );
}

public QS_DoManStanding ( )
{
	static Player, Name [ 32 ], TEGuy, TEs, CTGuy, CTs;

	TEs = QS_GetSize ( QS_TEAM_TE,	TEGuy );
	CTs = QS_GetSize ( QS_TEAM_CT,	CTGuy );

	if ( TEs == 1 && CTs > 0 )
	{
		get_user_name ( TEGuy, Name, charsmax ( Name ) );

		if ( g_bEnabled [ TEGuy ] )
			client_cmd ( TEGuy, "SPK ^"%s^"", g_ManStandingSounds [ random_num ( 0, sizeof ( g_ManStandingSounds ) - 1 ) ] );

		set_hudmessage ( 128, _, _, QS_HUD_MESSAGE_X_POSITION, QS_LAST_MAN_STANDING_Y_POSITION, _, _, QS_HUD_MESSAGE_HOLD_TIME );

		for ( Player = 1; Player <= g_MaxPlayers; Player++ )
		{
			if ( !g_bEnabled [ Player ] || \
					!is_user_connected ( Player ) || \
						is_user_bot ( Player ) || \
							is_user_hltv ( Player ) || \
								get_user_team ( Player ) != QS_TEAM_TE )
			{
				continue;
			}

			if ( Player == TEGuy )
				ShowSyncHudMsg ( TEGuy, g_MsgSyncObject_TE, "YOU ARE THE LAST %s!", \
									g_ManStandingStrings [ random_num ( 0, sizeof ( g_ManStandingStrings ) - 1 ) ] );

			else
				ShowSyncHudMsg ( Player, g_MsgSyncObject_TE, "%s IS THE LAST %s!", \
									Name, \
										g_ManStandingStrings [ random_num ( 0, sizeof ( g_ManStandingStrings ) - 1 ) ] );
		}
	}

	if ( CTs == 1 && TEs > 0 )
	{
		get_user_name ( CTGuy, Name, charsmax ( Name ) );

		if ( g_bEnabled [ CTGuy ] )
			client_cmd ( CTGuy, "SPK ^"%s^"", g_ManStandingSounds [ random_num ( 0, sizeof ( g_ManStandingSounds ) - 1 ) ] );

		set_hudmessage ( 0, 96, 192, QS_HUD_MESSAGE_X_POSITION, QS_LAST_MAN_STANDING_Y_POSITION, _, _, QS_HUD_MESSAGE_HOLD_TIME );

		for ( Player = 1; Player <= g_MaxPlayers; Player++ )
		{
			if ( !g_bEnabled [ Player ] || \
					!is_user_connected ( Player ) || \
						is_user_bot ( Player ) || \
							is_user_hltv ( Player ) || \
								get_user_team ( Player ) != QS_TEAM_CT )
			{
				continue;
			}

			if ( Player == CTGuy )
				ShowSyncHudMsg ( CTGuy, g_MsgSyncObject_CT, "YOU ARE THE LAST %s!", \
									g_ManStandingStrings [ random_num ( 0, sizeof ( g_ManStandingStrings ) - 1 ) ] );

			else
				ShowSyncHudMsg ( Player, g_MsgSyncObject_CT, "%s IS THE LAST %s!", \
									Name, \
										g_ManStandingStrings [ random_num ( 0, sizeof ( g_ManStandingStrings ) - 1 ) ] );
		}
	}
}

QS_GetSize ( Team, &Guy = 0 )
{
	static Players [ 32 ], Size;

	get_players ( Players, Size, "aeh", ( Team == QS_TEAM_TE ) ? "TERRORIST" : "CT" );

	if ( Size == 1 )
		Guy = Players [ 0 ];

	else
		Guy = 0;

	return Size;
}

bool: QS_CStrikeRunning ( )
{
	static ModName [ 8 ];

	if ( ModName [ 0 ] == EOS )
		get_modname ( ModName, charsmax ( ModName ) );

	return ( equali ( ModName, "CS", 2 ) || equali ( ModName, "CZ", 2 ) ) ? true : false;
}

bool: QS_XStatsLoaded ( )
{
	static bool: bChecked = false, Loaded = 0;

	if ( !bChecked )
		bChecked = true, Loaded = module_exists ( "xstats" );

	return Loaded ? true : false;
}

bool: QS_IsEnabled ( )
{
	return QS_CStrikeRunning ( ) && QS_XStatsLoaded ( );
}

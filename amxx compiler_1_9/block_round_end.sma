/*
	.: Cvars

		reb_enable <0|1> 	- 0 = Disable, 1 = Enable the plugin
		reb_plrmax 			- When the playercount (only players in a team) reaches this value, kick the bots
		reb_plrmin 			- When the playercount goes below this value, add the bots
		reb_fakefull <0|1> 	- 0 = Disable, 1 = Enable fakefull mode
		reb_fullkick <0|1> 	- 0 = Bots stay on the server even if full, 1 = Last slot will stay free, bots will be kicked
		reb_name1 "" 		- Sets the name for the first bot
		reb_name2 "" 		- Sets the name for the second bot
		reb_team <0|1|2>	- Sets the team for the bots
					- 0 will split them equally between T and CT
					- 1 will make them join T only
					- 2 does the same for CT


*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1
#pragma ctrlchar '\'

// Some constants you may want to change

const BOT_NUM = 2;	// If you, for some reason, want more bots.
					// Change this and don't forget to add reb_name3, reb_name4 etc. in your config

// These are just the default botnames, they are only used if the cvar is not set! You don't need to change them!
// You do, however, have to add more to this list if you change BOT_NUM
new const DefaultNames[BOT_NUM][ ] = 
{
	"Real 1",
	"Real 2"
};

//----------------------------------------------------------------------------------------
// Do not change anything below this line if you don't know exactly what you are doing!
//----------------------------------------------------------------------------------------

new const PLUGIN[]	= "Roundend Blocker";
new const VERSION[]	= "1.1.100";
new const AUTHOR[]	= "Nextra";

new p_BlockEnd, p_BlockPlrMin, p_BlockPlrMax, p_FakeFull, p_FullKick, p_BlockName[BOT_NUM], p_BlockTeam;

const TASK_BOTS = 666;

new g_BotID[BOT_NUM], bool:g_IsConnected[33], bool:g_bFirstRound = true;

new g_iMaxPlayers;

#define IsValidPlayer(%1) ( 1 <= %1 <= g_iMaxPlayers )
#define is_connected(%1) g_IsConnected[%1]

const LINUXDIFF = 5;

#if cellbits == 32
	const OFFSET_TEAM = 114;
#else
	const OFFSET_TEAM = 139;
#endif

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_cvar( "reb_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY );

	register_logevent( "on_RoundEnd"	, 2, "1=Round_End"			);
	register_logevent( "on_RoundStart"	, 2, "1=Round_Start"		);

	register_message( get_user_msgid( "TeamInfo" ), "msg_TeamInfo" 	);

	RegisterHam( Ham_Spawn, "player", "BOT_hide", 1 );
	
	p_BlockEnd		= register_cvar( "reb_enable"	, "1"			),
	p_BlockPlrMax	= register_cvar( "reb_plrmax"	, "3"			),
	p_BlockPlrMin	= register_cvar( "reb_plrmin"	, "4"			),
	p_FakeFull		= register_cvar( "reb_fakefull"	, "0"			),
	p_FullKick		= register_cvar( "reb_fullkick" , "1"			),
	p_BlockTeam		= register_cvar( "reb_team"		, "0"			);
	
	new szTmp[16];
	
	for( new i = 0; i < BOT_NUM; i++ )
	{
		formatex( szTmp, charsmax(szTmp), "reb_name%i", i + 1 );
		
		p_BlockName[i] = register_cvar( szTmp, "" );
	}

	g_iMaxPlayers = get_maxplayers( );
}


public msg_TeamInfo( )
{	
	if( is_user_fakebot( get_msg_arg_int( 1 ) ) )
		set_msg_arg_string( 2, "SPECTATOR" );
}


public on_RoundEnd( )
	BOT_start( );


public on_RoundStart( )
{
	if( g_bFirstRound )
	{
		g_bFirstRound = false;
		
		if( get_pcvar_num( p_FakeFull ) && get_pcvar_num( p_BlockEnd ) )
		{
			if( !get_playersnum( 1 ) )
				set_task( 1.0, "BOT_create", TASK_BOTS );
		}
	}
	else if( BOT_num( ) )
	{
		for( new id = 1; id <= g_iMaxPlayers; id++ )
		{
			if( is_connected( id ) )
				BOT_hide( id );
		}
	}
}


public BOT_create( )
{
	new BotName[32], BotID, firstNotValid = -1, i;
	
	for( i = 0; i < BOT_NUM; i++ )
	{
		if( !IsValidPlayer( g_BotID[i] ) )
		{
			firstNotValid = i;
			break;
		}
	}
	
	if( firstNotValid == -1 )
		return;

	get_pcvar_string( p_BlockName[firstNotValid], BotName, charsmax(BotName) );
	trim( BotName );
	
	if( equali( BotName, "" ) )
		copy( BotName, charsmax(BotName), DefaultNames[firstNotValid] );
	
	trim( BotName );
	
	if( equali( BotName, "" ) )
		return;

	new szName[32], szTmp[32], bool:bContinue = true, bool:bFound, iFound;
	
	copy( szTmp, charsmax(szTmp), BotName );
	
	while( bContinue )
	{
		for( i = 1; i <= g_iMaxPlayers; i++ )
		{
			if( is_connected( i ) )
			{
				get_user_name( i, szName, charsmax(szName) );
				
				if( equali( szTmp, szName ) )
				{
					formatex( szTmp, charsmax(szTmp), "%s(%d)", BotName, ++iFound );
					
					bFound = true;
					
					break;
				}
			}
		}
		
		if( !bFound )
			bContinue = false;
		
		bFound = false;
	}
	
	if( iFound )
		copy( BotName, charsmax(BotName), szTmp );
	
	BotID = engfunc( EngFunc_CreateFakeClient, BotName );
	
	if( !IsValidPlayer( BotID ) )
		return;

	g_BotID[firstNotValid] = BotID;
	
	new ptr[128];
	engfunc( EngFunc_FreeEntPrivateData, BotID );
	dllfunc( DLLFunc_ClientConnect, BotID, BotName, "127.0.0.1", ptr );
	
	if( !is_user_connected( BotID ) )
	{
		g_BotID[firstNotValid] = 0;
		return;
	}

	dllfunc( DLLFunc_ClientPutInServer, BotID );
	set_pev( BotID, pev_spawnflags, pev( BotID, pev_spawnflags ) | FL_FAKECLIENT );
	set_pev( BotID, pev_flags, pev( BotID, pev_flags ) | FL_FAKECLIENT );
	
	switch( clamp( get_pcvar_num( p_BlockTeam ), 0, 2 ) )
	{
		case 0:	cs_set_user_team( BotID, BOT_num( ) % 2 ? CS_TEAM_T : CS_TEAM_CT );
		case 1:	cs_set_user_team( BotID, CS_TEAM_T );
		case 2:	cs_set_user_team( BotID, CS_TEAM_CT );
	}
	
	if( !is_user_alive( BotID ) )
		ExecuteHamB( Ham_CS_RoundRespawn, BotID );
	
	if( BOT_num( ) < BOT_NUM )
	{
		remove_task( TASK_BOTS );
		set_task( 0.1, "BOT_start", TASK_BOTS );
	}
	
	BOT_hide( BotID );
}


BOT_check_teams( )
{
	static bool:bFirstCallDone, oldTeam;
	new iTeam = clamp( get_pcvar_num( p_BlockTeam ), 0, 2 ); 
	
	if( !bFirstCallDone )
	{
		oldTeam = iTeam;
		bFirstCallDone = true;
	}
	else if( iTeam != oldTeam )
	{
		oldTeam = iTeam;
		
		new BotID;
		if( iTeam )
		{
			for( new i = 0; i < BOT_NUM; i++ )
			{
				BotID = g_BotID[i];
				
				if( IsValidPlayer( BotID ) )
					set_pdata_int( BotID, OFFSET_TEAM, iTeam, LINUXDIFF );
			}
		}
		else
		{
			for( new i = BOT_num( ) - 1; i >= 0; i-- )
			{			
				BotID = g_BotID[i];
				
				if( IsValidPlayer( BotID ) )
					set_pdata_int( BotID, OFFSET_TEAM, _:( i % 2 ? CS_TEAM_T : CS_TEAM_CT ), LINUXDIFF );
			}
		}
	}
}


public BOT_hide( const id )
{
	if( is_user_fakebot( id ) )
	{
		set_pev( id, pev_effects, pev( id, pev_effects ) | EF_NODRAW );
		set_pev( id, pev_solid, SOLID_NOT );
		set_pev( id, pev_takedamage, DAMAGE_NO );
		set_pev( id, pev_health, 1000000.0 );
		set_pev( id, pev_origin, Float:{ 9999.0, 9999.0, 9999.0 } );
	}
}


BOT_kick( iAmt = BOT_NUM )
{
	if( !BOT_num( ) )
		return;
	
	new BotID, iKicked;
	
	for( new i = BOT_NUM - 1; i >= 0; i-- )
	{
		if( i + 1 > g_iMaxPlayers )
			continue;
		
		BotID = g_BotID[i];
		
		if( IsValidPlayer( BotID ) )
		{
			server_cmd( "kick #%d", get_user_userid( BotID ) );
			server_exec( );
			
			if( ++iKicked >= iAmt )
				break;
		}
	}
}


public BOT_start( )
{
	new iBotNum = BOT_num( );
	
	if( !get_pcvar_num( p_BlockEnd ) )
	{
		if( iBotNum )
			BOT_kick( );
		
		return;
	}
	
	new iPlayers = get_playersnum( 1 );

	if( iBotNum )
	{
		BOT_check_teams( );
		
		if( iPlayers == g_iMaxPlayers - 1 )
		{
			if( get_pcvar_num( p_FullKick ) )
				return;
		}
		else if( iPlayers >= g_iMaxPlayers )
		{
			if( get_pcvar_num( p_FullKick ) )
				BOT_kick( 1 );
			
			return;
		}
		else if( iPlayers - iBotNum == 0 )
		{
			if( !get_pcvar_num( p_FakeFull ) )
			{
				BOT_kick( );
				return;
			}
		}
	}
	else if( !iPlayers )
		return;
		
	new iPlayerNum;
	
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_connected( i ) || is_user_fakebot( i ) )
			continue;
		
		switch( cs_get_user_team( i ) )
		{
			case CS_TEAM_T, CS_TEAM_CT:	iPlayerNum++;
		}
	}
	
	
	if( iBotNum && iPlayerNum >= get_pcvar_num( p_BlockPlrMax ) )
		BOT_kick( );
	else if( iBotNum < BOT_NUM && iPlayerNum < get_pcvar_num( p_BlockPlrMin ) )
		BOT_create( );
}


BOT_num( )
{
	new iNum;
	
	for( new i = 0; i < BOT_NUM; i++ )
	{
		if( IsValidPlayer( g_BotID[i] ) )
			iNum++;
	}
	
	return iNum;
}


public client_putinserver( id )
{
	is_connected( id ) = true;
	
	set_task( 1.0, "BOT_start", TASK_BOTS );
}


public client_disconnected( id )
{
	is_connected( id ) = false;
	
	for( new i = 0; i < BOT_NUM; i++ )
	{
		if( is_user_fakebot( id, i ) )
		{
			g_BotID[i] = 0;
			
			break;
		}
	}
	
	set_task( 1.0, "BOT_start", TASK_BOTS );
}


bool:is_user_fakebot( const id, which = BOT_NUM )
{
	switch( which )
	{
		case BOT_NUM:
		{
			for( new i = 0; i < BOT_NUM; i++ )
			{
				if( id == g_BotID[i] )
					return true;
			}
		}
		default: return ( id == g_BotID[which] ) ? true : false;
	}
	
	return false;
}
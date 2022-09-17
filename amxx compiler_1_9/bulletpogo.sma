
#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <xs>
#include <amxmisc>

new const Version[] = "0.2";

new const g_GunEvents[][] = 
{
        "events/usp.sc",
        "events/glock18.sc",
        "events/fiveseven.sc",
        "events/deagle.sc",
        "events/elite_left.sc",
        "events/elite_right.sc",
        // "events/awp.sc",
        // "events/g3sg1.sc",
        // "events/ak47.sc",
        // "events/scout.sc",
        // "events/m249.sc",
        // "events/m4a1.sc",
        // "events/sg552.sc",
        // "events/aug.sc",
        // "events/sg550.sc",
        // "events/m3.sc",
        // "events/xm1014.sc",
        // "events/mac10.sc",
        // "events/ump45.sc",
        // "events/p90.sc",
        // "events/p228.sc",
        // "events/mp5n.sc",
        // "events/tmp.sc",
        // "events/galil.sc",
        // "events/famas.sc"
};

new g_GunEventBits;
new g_FMPrecacheEvent;
new g_iMaxPlayers;

new g_pStrength;
new g_pFallDamage;
new g_pPogoPlayer;

new g_TouchGroundEnt;
new g_bIsPogo;

new bool:g_PlayerRevoked[ 33 ] = false;

#define IsPlayer(%1)	(1<=%1<=g_iMaxPlayers)
#define IsPogo(%1)	(g_bIsPogo & (1<<(%1 & 31)))
#define SetPogo(%1)	(g_bIsPogo |= (1<<(%1 & 31)))
#define RemovePogo(%1)	(g_bIsPogo &= ~(1<<(%1 & 31)))

public plugin_init() 
{
	register_plugin( "Bullet Pogo" , Version , "bugsy" );
	register_concmd("amx_revoke_pogo", "revoke", ADMIN_CHAT, "<player> - Revokes a player's pogo license");
	register_concmd("amx_unrevoke_pogo","unrevoke", ADMIN_CHAT, "<player> - Renews a player's pogo license");

	g_pStrength = register_cvar( "bp_strength" , "375.0" );
	g_pFallDamage = register_cvar( "bp_falldamage" , "0" );
	g_pPogoPlayer = register_cvar( "bp_pogoplayer" , "0" );
	
	register_forward( FM_CmdStart , "fw_FMCmdStart" , 1 );
	unregister_forward( FM_PrecacheEvent , g_FMPrecacheEvent , 1 );
	register_forward( FM_PlaybackEvent , "fw_FMPlaybackEvent" );
	
	RegisterHam( Ham_TakeDamage , "player" , "fw_HamTakeDamage" );
	 
	g_TouchGroundEnt = create_entity( "info_target" );
	entity_set_string( g_TouchGroundEnt , EV_SZ_classname , "touchground_entity" );
	register_think( "touchground_entity" , "fw_Think" );

	g_iMaxPlayers = get_maxplayers();
}

public plugin_precache() 
{
	g_FMPrecacheEvent = register_forward( FM_PrecacheEvent , "fw_FMPrecacheEvent" , 1 );
}

public fw_FMPrecacheEvent( Type , const szName[] ) 
{ 
	for ( new i = 0 ; i < sizeof( g_GunEvents ) ; ++i ) 
	{
		if ( equal( g_GunEvents[ i ] , szName ) ) 
		{
			g_GunEventBits |= ( 1 << get_orig_retval() );
			return FMRES_HANDLED;
		}
	}

        return FMRES_IGNORED;
}

public fw_FMPlaybackEvent( Flags , Invoker , EventID ) 
{
    if ( !( g_GunEventBits & ( 1 << EventID ) ) || !IsPlayer( Invoker ) ) 
	{
		return FMRES_IGNORED;
	}
        
	// client_print(0, print_console, "[AMXX] Player id %d", Invoker);
	if(g_PlayerRevoked[Invoker])
	{
		set_hudmessage()
		show_hudmessage(Invoker, "Sorry, you're pogo license was revoked.")

		return FMRES_IGNORED;
	}


	static Float:fVelocity[ 3 ];
	static iOrigin[ 3 ] , Float:fOrigin[ 3 ];
	static iAimOrigin[ 3 ] , Float:fAimOrigin[ 3 ];
	static idAiming , iBody;
	
	if ( !get_pcvar_num( g_pPogoPlayer ) )
	{
		get_user_aiming( Invoker , idAiming , iBody );
		
		if ( IsPlayer( idAiming ) )
			return FMRES_IGNORED;
	}
	
	get_user_origin( Invoker , iOrigin );
	get_user_origin( Invoker , iAimOrigin , 3 );

	IVecFVec( iOrigin , fOrigin );
	IVecFVec( iAimOrigin , fAimOrigin );
	
	if ( -80.0 >= GetAngleOrigins( fOrigin , fAimOrigin ) >= -90.0 )
	{
		pev( Invoker , pev_velocity , fVelocity );
		fVelocity[ 2 ] = get_pcvar_float( g_pStrength );
		set_pev( Invoker , pev_velocity , fVelocity );
		
		SetPogo( Invoker );
		
		entity_set_float( g_TouchGroundEnt , EV_FL_nextthink , get_gametime() + 0.25 );

		return FMRES_IGNORED;
	}
	
	return FMRES_HANDLED;
}

public fw_HamTakeDamage( Victim , Inflictor , Attacker , Float:fDamage , BitDamage ) 
{
	return ( IsPogo( Victim ) && ( BitDamage & DMG_FALL ) && !get_pcvar_num( g_pFallDamage ) ) ? HAM_SUPERCEDE : HAM_IGNORED;
}

public fw_Think( Entity )
{
	if( Entity != g_TouchGroundEnt ) 
		return FMRES_IGNORED;
	
	static id;
	
	for ( id = 1 ; id <= g_iMaxPlayers ; id++ )
		if ( IsPogo( id ) && ( ( pev( id , pev_flags ) & FL_ONGROUND ) || !is_user_alive( id ) ) ) 
			RemovePogo( id );
			
	if ( g_bIsPogo )
		entity_set_float( g_TouchGroundEnt , EV_FL_nextthink , get_gametime() + 0.25 );
		
	return FMRES_IGNORED;
}

Float: GetAngleOrigins( const Float:fOrigin1[ 3 ] , const Float:fOrigin2[ 3 ] )
{
	new Float:fVector[ 3 ] , Float:fAngle[ 3 ];
	
	xs_vec_sub( fOrigin2 , fOrigin1 , fVector );
	vector_to_angle( fVector , fAngle );
	
	return ( ( fAngle[ 0 ] > 90.0 ) ? -( 360.0 - fAngle[ 0 ] ) : fAngle[ 0 ] );
}

public revoke(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}
	
	new playern[42];
	read_argv(1,playern,41);
	new playerid = cmd_target(id, playern, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	
	if(!playerid) 
	{
		return PLUGIN_HANDLED;
	}
	
	new playerauth[40];
	get_user_authid(playerid,playerauth,39);

	new vaultauth[42]
	format(vaultauth,41,"Pogo%s",playerauth);

	if(vaultdata_exists(vaultauth)) {
		client_print(id, print_console, "Player's pogo license is already revoked.");
		return PLUGIN_HANDLED;
	}

	set_vaultdata(vaultauth,"1");
	g_PlayerRevoked[ playerid ] = true;
	
	client_print(id,print_console,"Player's pogo license revoked.");
	client_print(playerid, print_chat, "The admin has revoked your pogo license.");
	
	return PLUGIN_HANDLED;
}

public unrevoke(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) 
	{
		return PLUGIN_HANDLED;
	}
	
	new playern[42];
	read_argv(1,playern,41);
	
	new playerid = cmd_target(id, playern, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if(!playerid)
		return PLUGIN_HANDLED;
	
	new playerauth[40];
	get_user_authid(playerid,playerauth,39);
	new vaultauth[42];
	format(vaultauth,41,"Pogo%s",playerauth);
	
	if(!vaultdata_exists(vaultauth))
	{
		client_print(id,print_console,"Player's pogo license was never revoked.");
		return PLUGIN_HANDLED;
	}
	else
	{
		remove_vaultdata(vaultauth);
		g_PlayerRevoked[ playerid ] = false;
		client_print(id,print_console,"This player's pogo license was unrevoked.");
		client_print(playerid, print_chat, "The admin has given you you're pogo license back.");
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}


public client_authorized(id) {
	new playerauth[40];
	get_user_authid(id,playerauth,39);

	new vaultauth[42];
	format(vaultauth,41,"Pogo%s", playerauth);
	g_PlayerRevoked[ id ] = false;

	if (vaultdata_exists(vaultauth)) 
	{
		g_PlayerRevoked[ id ] = true;
	}

	return PLUGIN_HANDLED;
}

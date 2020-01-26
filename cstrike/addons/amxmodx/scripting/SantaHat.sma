#include < amxmodx >
#include < engine >
#include < cstrike >
#include < hamsandwich >

new const g_szHatModel[ CsTeams ][ ] = {
    "",
    "models/devil2.mdl",
    "models/angel2.mdl",
    ""
};

new g_iHats[ 33 ];

public plugin_init( ) {
    register_plugin( "Santa Hat + Snow", "1.3", "xPaw" );
    
    register_cvar( "santa_hat", "1.3", FCVAR_SERVER );
    
    register_event( "TeamInfo", "EventTeamInfo", "a" );
    
    RegisterHam( Ham_Spawn, "player", "FwdHamPlayerSpawn", 1 );
}

public plugin_precache( ) {
//  create_entity( "env_snow" );
    
    precache_model( g_szHatModel[ CS_TEAM_T ] );
    precache_model( g_szHatModel[ CS_TEAM_CT ] );
}

public client_disconnect( id )
    if( is_valid_ent( g_iHats[ id ] ) )
        remove_entity( g_iHats[ id ] );

public FwdHamPlayerSpawn( const id ) {
    if(get_user_flags(id) & ADMIN_LEVEL_A) {
    if( is_user_alive( id ) ) {
        new iEntity = g_iHats[ id ];
        
        if( !is_valid_ent( iEntity ) ) {
            if( !( iEntity = g_iHats[ id ] = create_entity( "info_target" ) ) )
                return;
            
            new CsTeams:iTeam = cs_get_user_team( id );
            
            if( iTeam != CS_TEAM_T && iTeam != CS_TEAM_CT )
                iTeam = CS_TEAM_T;
            
            entity_set_model( iEntity, g_szHatModel[ iTeam ] );
            entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_FOLLOW );
            entity_set_edict( iEntity, EV_ENT_aiment, id );
        }
    }
    }
}

public EventTeamInfo( ) {
    new id = read_data( 1 ), iEntity = g_iHats[ id ];
    
    if( !is_valid_ent( iEntity ) ) {
        if( iEntity > 0 )
            g_iHats[ id ] = 0;
        
        return;
    }
    
    new szTeam[ 2 ];
    read_data( 2, szTeam, 1 );
    
    if( szTeam[ 0 ] == 'C' )
        entity_set_model( iEntity, g_szHatModel[ CS_TEAM_CT ] );
    else
        entity_set_model( iEntity, g_szHatModel[ CS_TEAM_T ] );
}
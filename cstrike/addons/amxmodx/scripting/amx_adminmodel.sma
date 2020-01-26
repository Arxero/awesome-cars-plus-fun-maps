#include < amxmodx >
#include < cstrike >
#include < hamsandwich >

new bool:g_bAdmin[ 33 ];

public plugin_init( ) {
    register_plugin( "Admin Model", "1.2", "whitemike" );
    
    RegisterHam( Ham_Spawn, "player", "FwdHamPlayerSpawn", 1 );
}

public plugin_precache( ) {
    precache_model( "models/player/max/max.mdl" );
    precache_model( "models/player/duke/duke.mdl" );
}

public client_authorized( id )
    g_bAdmin[ id ] = bool:( get_user_flags( id ) & ADMIN_LEVEL_G
 );

public client_disconnect( id )
    g_bAdmin[ id ] = false;

public FwdHamPlayerSpawn( const id ) {
    if( g_bAdmin[ id ] && is_user_alive( id ) ) {
        switch( cs_get_user_team( id ) ) {
            case CS_TEAM_T: cs_set_user_model( id, "duke" );
            case CS_TEAM_CT: cs_set_user_model( id, "max" );
        }
    }
}
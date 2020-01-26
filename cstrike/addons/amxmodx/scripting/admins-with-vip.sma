#include < amxmodx >
#include < amxmisc >

#define ADMIN_VIP ADMIN_LEVEL_E

enum {
    SCOREATTRIB_ARG_PLAYERID = 1,
    SCOREATTRIB_ARG_FLAGS
};

enum ( <<= 1 ) {
    SCOREATTRIB_FLAG_NONE = 0,
    SCOREATTRIB_FLAG_DEAD = 1,
    SCOREATTRIB_FLAG_BOMB,
    SCOREATTRIB_FLAG_VIP
};

new pCvar_AdminVIP;

public plugin_init( ) {
    register_plugin( "Admin VIP ScoreBoard", "0.0.1", "Exolent" );
    
    register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" );
    
    pCvar_AdminVIP = register_cvar( "amx_adminvip", "1" );
}

public MessageScoreAttrib( iMsgId, iDest, iReceiver ) {
    if( get_pcvar_num( pCvar_AdminVIP ) ) {
        new iPlayer = get_msg_arg_int( SCOREATTRIB_ARG_PLAYERID );
        
        if( access( iPlayer, ADMIN_VIP ) ) {
            set_msg_arg_int( SCOREATTRIB_ARG_FLAGS, ARG_BYTE, SCOREATTRIB_FLAG_VIP );
        }
    }
}

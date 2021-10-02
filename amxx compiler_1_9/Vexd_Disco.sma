
    #include <amxmodx>
    #include <amxmisc>
    #include <fakemeta>
    #include <engine>
    

    new const gDiscoBallClassname[] = "discoball";
    new gLaserSprite;

    #define write_coord_f(%0)  ( engfunc( EngFunc_WriteCoord, %0 ) )


    public plugin_precache()
    {
        gLaserSprite = precache_model( "sprites/laserbeam.spr" );
        precache_model( "models/w_adrenaline.mdl" );
    }


    public plugin_init()
    {
        register_plugin( "Vexd Disco", "1.0.0", "AMXX Community" );

        register_think( gDiscoBallClassname, "CDiscoBall_Think" );
        
        register_clcmd( "amx_makedisco", "ClientCommand_CreateDisco" );
        register_clcmd( "amx_killdisco", "ClientCommand_KillDisco" );
    }


    public ClientCommand_CreateDisco ( const Player, const Level, const Cid )
    {
        if ( !cmd_access( Player, Level, Cid, 1 ) )
        {
            return PLUGIN_HANDLED;
        }

        new Float:Origin[3];
        new Entity;

        pev( Player, pev_origin, Origin );

        if ( ( Entity = create_entity( "info_target" ) ) )
        {
            set_pev( Entity, pev_classname, gDiscoBallClassname );

            engfunc( EngFunc_SetModel , Entity, "models/w_adrenaline.mdl" );
            engfunc( EngFunc_SetSize  , Entity, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 } );
            engfunc( EngFunc_SetOrigin, Entity, Origin );

            set_pev( Entity, pev_effects, EF_BRIGHTFIELD );
            set_pev( Entity, pev_solid, SOLID_BBOX );
            set_pev( Entity, pev_movetype, MOVETYPE_TOSS );
            set_pev( Entity, pev_owner, Player );
            set_pev( Entity, pev_nextthink, get_gametime() + 0.1 );
        }

        return PLUGIN_HANDLED_MAIN;
    }


    public ClientCommand_KillDisco ( const Player, const Level, const Cid )
    {
        if ( cmd_access( Player, Level, Cid, 1 ) )
        {
            remove_entity_name( gDiscoBallClassname );
            return PLUGIN_HANDLED_MAIN;
        }

        return PLUGIN_HANDLED;
    }


    public CDiscoBall_Think ( const Entity )
    {
        if ( !is_valid_ent( Entity ) )
        {
            return;
        }

        static Float:Origin[3];
        static Float:TestEnd[3];
        static Float:EndPos[3];

        pev( Entity, pev_origin, Origin );

        TestEnd[0] = Origin[0] + random_float( -5000.0, 5000.0 );
        TestEnd[1] = Origin[1] + random_float( -5000.0, 5000.0 );
        TestEnd[2] = Origin[2] + random_float( 0.0, 5000.0 );

        trace_line( Entity, Origin, TestEnd, EndPos );

        message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte( TE_BEAMPOINTS )
        write_coord_f( Origin[0] );
        write_coord_f( Origin[1] );
        write_coord_f( Origin[2] + 5.0 );
        write_coord_f( EndPos[0] );
        write_coord_f( EndPos[1] );
        write_coord_f( EndPos[2] );
        write_short( gLaserSprite );
        write_byte( 0 );
        write_byte( 0 );
        write_byte( 10 );
        write_byte( 5 );
        write_byte( 0 );
        write_byte( random_num( 100, 255 ) );
        write_byte( random_num( 100, 255 ) );
        write_byte( random_num( 100, 255 ) );
        write_byte( 200 );
        write_byte( 0 );
        message_end();
            
        set_pev( Entity, pev_nextthink, get_gametime() + 0.25 );
    }


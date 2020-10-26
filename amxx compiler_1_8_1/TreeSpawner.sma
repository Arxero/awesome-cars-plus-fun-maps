#include < amxmodx >
#include < amxmisc >
#include < engine >

new const MODEL[ ] = "models/bright_pumpkin.mdl";

new g_szConfigFile[ 128 ];

public plugin_init( ) {
	register_plugin( "Tree Spawner", "1.0", "xPaw" );
	
	register_clcmd( "tree_spawn",  "CmdSpawnTree",   ADMIN_MAP );
	register_clcmd( "tree_remove", "CmdSpawnRemove", ADMIN_MAP );
}

public plugin_precache( )
	precache_model( MODEL );

public plugin_cfg( ) {
	new szMapName[ 32 ];
	get_mapname( szMapName, 31 );
	strtolower( szMapName );
	
	formatex( g_szConfigFile, 127, "addons/amxmodx/data/trees" );
	
	if( !dir_exists( g_szConfigFile ) ) {
		mkdir( g_szConfigFile );
		
		format( g_szConfigFile, 127, "%s/%s.txt", g_szConfigFile, szMapName );
		
		return;
	}
	
	format( g_szConfigFile, 127, "%s/%s.txt", g_szConfigFile, szMapName );
	
	if( !file_exists( g_szConfigFile ) )
		return;
	
	new iFile = fopen( g_szConfigFile, "rt" );
	
	if( !iFile )
		return;
	
	new Float:vOrigin[ 3 ], x[ 16 ], y[ 16 ], z[ 16 ], szData[ sizeof( x ) + sizeof( y ) + sizeof( z ) + 3 ];
	
	while( !feof( iFile ) ) {
		fgets( iFile, szData, charsmax( szData ) );
		trim( szData );
		
		if( !szData[ 0 ] )
			continue;
		
		parse( szData, x, 15, y, 15, z, 15 );
		
		vOrigin[ 0 ] = str_to_float( x );
		vOrigin[ 1 ] = str_to_float( y );
		vOrigin[ 2 ] = str_to_float( z );
		
		CreateTree( vOrigin );
	}
	
	fclose( iFile );
}

public CmdSpawnTree( const id, const iLevel, const iCid ) {
	if( !cmd_access( id, iLevel, iCid, 1 ) )
		return PLUGIN_HANDLED;
	
	new Float:vOrigin[ 3 ];
	entity_get_vector( id, EV_VEC_origin, vOrigin );
	
	if( CreateTree( vOrigin ) )
		SaveTrees( );
	
	return PLUGIN_HANDLED;
}

public CmdSpawnRemove( const id, const iLevel, const iCid ) {
	if( !cmd_access( id, iLevel, iCid, 1 ) )
		return PLUGIN_HANDLED;
	
	new Float:vOrigin[ 3 ], szClassName[ 10 ], iEntity = -1, iDeleted;
	entity_get_vector( id, EV_VEC_origin, vOrigin );
	
	while( ( iEntity = find_ent_in_sphere( iEntity, vOrigin, 100.0 ) ) > 0 ) {
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 9 );
		
		if( equal( szClassName, "env_tree" ) ) {
			remove_entity( iEntity );
			
			iDeleted++;
		}
	}
	
	if( iDeleted > 0 )
		SaveTrees( );
	
	console_print( id, "[AMXX] Deleted %i trees.%s", iDeleted, iDeleted == 0 ? " You need to stand in tree to remove it" : "" );
	
	return PLUGIN_HANDLED;
}

CreateTree( const Float:vOrigin[ 3 ] ) {
	new iEntity = create_entity( "info_target" );
	
	if( !iEntity )
		return 0;
	
	entity_set_string( iEntity, EV_SZ_classname, "env_tree" );
	entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NONE );
	
	entity_set_size( iEntity, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 36.0 } );
	entity_set_origin( iEntity, vOrigin );
	entity_set_model( iEntity, MODEL );
	
	drop_to_floor( iEntity );
	
	return iEntity;
}

SaveTrees( ) {
	if( file_exists( g_szConfigFile ) )
		delete_file( g_szConfigFile );
	
	new iFile = fopen( g_szConfigFile, "wt" );
	
	if( !iFile )
		return;
	
	new Float:vOrigin[ 3 ], iEntity;
	
	while( ( iEntity = find_ent_by_class( iEntity, "env_tree" ) ) > 0 ) {
		entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
		
		fprintf( iFile, "%f %f %f^n", vOrigin[ 0 ], vOrigin[ 1 ], vOrigin[ 2 ] );
	}
	
	fclose( iFile );
}
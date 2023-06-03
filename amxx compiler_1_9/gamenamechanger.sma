#include <amxmodx>
#include <fakemeta>

new amx_gamename;
public plugin_init( ) { 
	register_plugin( "Game Namer", "1.1", "NeuroToxin" ); 
	amx_gamename = register_cvar( "amx_gamename", "Team Fortress Classic" ); 
	register_forward( FM_GetGameDescription, "GameDesc" ); 
}
 
public GameDesc( ) { 
	static gamename[32]; 
	get_pcvar_string( amx_gamename, gamename, 31 ); 
	forward_return( FMV_STRING, gamename ); 
	return FMRES_SUPERCEDE; 
}  
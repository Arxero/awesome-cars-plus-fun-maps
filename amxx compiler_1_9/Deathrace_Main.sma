#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>
#include <cstrike>

#define PLUGIN "Deathrace"
#define VERSION "2.3"
#define AUTHOR "Xalus"

#define PREFIX "^4[Deathrace]"

new const g_strGamename[] = "Deathrace (v2.3)";

	// Fakebot (Credit: xPaw)
new const g_strBotname[] = "Deathrace (v2.3)";
new g_intFakebotid

	// Teamstuff (Credit: ConnorMcLeod)
const m_iJoiningState = 121;
const m_iMenu = 205;
const MENU_CHOOSEAPPEARANCE = 3;
const JOIN_CHOOSEAPPEARANCE = 4;


enum _:enumCvars
{
	CVAR_BREAKTYPE
}
new g_arrayCvars[enumCvars]

enum _:enumForwards
{
	FORWARD_CRATEHIT,
	FORWARD_WIN
}
new g_arrayForwards[enumForwards]

enum _:enumPlayers
{
	PLAYER_ENT_BLOCK
}
new g_arrayPlayers[33][enumPlayers]


new Trie:g_trieRemoveEntities
new bool:g_boolRoundended

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("deathrace_mod", VERSION, FCVAR_SERVER);
	
	// Register: Cvars
	g_arrayCvars[CVAR_BREAKTYPE] 	= register_cvar("deathrace_touch_breaktype", "1")
		// 0 break nothing, 1 break only crates, 2 break everything
	
	// Register: Clcmd
	register_clcmd("menuselect", "ClCmd_MenuSelect_JoinClass"); // old style menu
	register_clcmd("joinclass", "ClCmd_MenuSelect_JoinClass"); // VGUI menu
	
	// Register: Ham
	RegisterHam(Ham_Touch, "func_breakable", "Ham_TouchCrate_Pre", 0);
	RegisterHam(Ham_TakeDamage, "func_breakable", "Ham_DamageCrate_Pre", 0)
	RegisterHam(Ham_TakeDamage, "player", "Ham_DamagePlayer_Pre", 0)
	
	RegisterHam(Ham_Use, "func_button", "Ham_PressButton_Post", 1);
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1);
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", 1);
	
	// Register: Message
	register_message(get_user_msgid("TextMsg"), "Message_TextMsg");
	register_message(get_user_msgid("StatusIcon"), "Message_StatusIcon"); 
	register_message(get_user_msgid("DeathMsg"), "Message_DeathMsg" );
	
	// Register: Event
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	
	// Register: Forward
	register_forward(FM_GetGameDescription, "Forward_GetGameDescription" )
	
	// Register: MultiForward
	g_arrayForwards[FORWARD_CRATEHIT]	= CreateMultiForward("deathrace_crate_hit", ET_STOP, FP_CELL, FP_CELL) 	// deathrace_crate_hit(id, ent)
	g_arrayForwards[FORWARD_WIN]		= CreateMultiForward("deathrace_win", ET_STOP, FP_CELL, FP_CELL) // deathrace_win(id, type) (type [ 0: Survivor | 1: Map Finish ])
	
	// Create: Fakebot
	create_fakebot()
}
public plugin_precache()
{
		// Entity stuff (Credit: Exolent[jNr]
	new iEntity = create_entity( "hostage_entity" );
	entity_set_origin( iEntity, Float:{ 0.0, 0.0, -55000.0 } );
	entity_set_size( iEntity, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 } );
	DispatchSpawn( iEntity );
	
	iEntity = create_entity( "player_weaponstrip" );
	DispatchKeyValue( iEntity, "targetname", "stripper" );
	DispatchSpawn( iEntity );
	
	iEntity = create_entity( "game_player_equip" );
	DispatchKeyValue( iEntity, "weapon_knife", "1" );
	DispatchKeyValue( iEntity, "targetname", "equipment" );
	
	iEntity = create_entity( "multi_manager" );
	DispatchKeyValue( iEntity, "stripper", "0" );
	DispatchKeyValue( iEntity, "equipment", "0.5" );
	DispatchKeyValue( iEntity, "targetname", "game_playerspawn" );
	DispatchKeyValue( iEntity, "spawnflags", "1" );
	DispatchSpawn( iEntity );
	
	iEntity = create_entity( "info_map_parameters" );
	DispatchKeyValue( iEntity, "buying", "3" );
	DispatchSpawn( iEntity );
	
	new const szRemoveEntities[][] =
	{
		"func_bomb_target",
		"info_bomb_target",
		"hostage_entity",
		"monster_scientist",
		"func_hostage_rescue",
		"info_hostage_rescue",
		"info_vip_start",
		"func_vip_safetyzone",
		"func_escapezone",
		// "armoury_entity",
		"info_map_parameters",
		"player_weaponstrip",
		"game_player_equip",
		"func_buyzone"
	};
	
	g_trieRemoveEntities = TrieCreate( );
	
	for( new i = 0; i < sizeof( szRemoveEntities ); i++ )
	{
		TrieSetCell(g_trieRemoveEntities, szRemoveEntities[i], i);
	}
	register_forward(FM_Spawn, "Forward_Spawn");
}

// Public: Forward
public Forward_Spawn(entity)
{
	if(pev_valid(entity))
	{
		static strClassname[ 32 ];
		pev(entity, pev_classname, strClassname, charsmax(strClassname));
		
		if(TrieKeyExists(g_trieRemoveEntities, strClassname))
		{
			remove_entity(entity);
			return FMRES_SUPERCEDE;
		}
		if(equal(strClassname, "info_player_deathmatch"))
		{
			set_pev(entity, pev_classname, "info_player_start")
		}
	}
	return FMRES_IGNORED;
}
public Forward_GetGameDescription()
{ 
	forward_return(FMV_STRING, g_strGamename); 
	return FMRES_SUPERCEDE; 
} 

// Public: Clcmds
public ClCmd_MenuSelect_JoinClass(id)
{
	if(get_pdata_int(id, m_iMenu) == MENU_CHOOSEAPPEARANCE && get_pdata_int(id, m_iJoiningState) == JOIN_CHOOSEAPPEARANCE)
	{
		new command[11], arg1[32];
		read_argv(0, command, charsmax(command));
		read_argv(1, arg1, charsmax(arg1));
		
		if(!g_boolRoundended)
		{
			engclient_cmd(id, command, arg1);
			ExecuteHam(Ham_Player_PreThink, id);
			
			if( !is_user_alive(id) )
			{
				//ExecuteHamB(Ham_Spawn, id);
				ExecuteHamB(Ham_CS_RoundRespawn, id);
			}
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
} 

// Public: Messages
public Message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	    
	// Block Teammate attack and kill Message
	if (equal(textmsg, "#Game_teammate_attack") || equal(textmsg, "#Killed_Teammate"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
public Message_StatusIcon(const iMsgId, const iMsgDest, const id) 
{
	static szMsg[8];
	get_msg_arg_string(2, szMsg, 7);
    
	if(equal(szMsg, "buyzone") && get_msg_arg_int(1)) 
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1 << 0));
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public Message_DeathMsg(const iMsgId, const iMsgDest, const id) 
{
	return (get_msg_arg_int( 2 ) == g_intFakebotid) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

// Public: Event
public Event_NewRound()
{
	g_boolRoundended = false
	
	remove_task(15151)
}

// Public: Client
public client_disconnect(id)
{
	if(g_intFakebotid == id) 
	{
		set_task(1.5, "Task_UpdateBot");
		g_intFakebotid = 0;
	}
}

// Public: Ham
public Ham_PlayerKilled_Post(id)
{
	if(!is_user_bot(id))
	{
		new arrayPlayers[32], intPlayers;
		get_players(arrayPlayers, intPlayers, "ae", "CT")
		
		if(intPlayers <= 1)
		{
			if(arrayPlayers[0])
			{
				new intReturn;
				ExecuteForward(g_arrayForwards[FORWARD_WIN], intReturn, id, 0);
				
				if(intReturn == 2)
					return
				
				new strName[32];
				get_user_name(arrayPlayers[0], strName, charsmax(strName))
				
				ColorChat(0, GREY, "%s^3 %s^1 was the only survivor left!", PREFIX, strName)
			}
			
			fakedamage(g_intFakebotid, "worldspawn", 100.0, DMG_GENERIC);
		}
	}
}

public Ham_PlayerSpawn_Post(id)
{
	if(g_intFakebotid == id)
	{
		//set_pev(id, pev_frags, 0.0);
		//cs_set_user_deaths(id, 0);
		set_pev( id, pev_effects, pev( id, pev_effects ) | EF_NODRAW );
		set_pev( id, pev_solid, SOLID_NOT );
		entity_set_origin( id, Float:{ 999999.0, 999999.0, 999999.0 } );
		dllfunc( DLLFunc_Think, id );
	} 
}

public Ham_TouchCrate_Pre(entity, id)
{
	if(pev_valid(entity)
	&& is_user_alive(id)
	&& !g_boolRoundended)
	{
		static intBreaktype
		if(g_arrayPlayers[id][PLAYER_ENT_BLOCK] != entity
		&& (intBreaktype || (intBreaktype = get_pcvar_num(g_arrayCvars[CVAR_BREAKTYPE]))) )
		{
			static strTargetname[32];
			pev(entity, pev_targetname, strTargetname, charsmax(strTargetname));
				
				// Lets see if we got a crate.
			if( (intBreaktype == 2) 
				|| (intBreaktype == 1 && containi(strTargetname, "crate") >= 0) )
			{
				ExecuteHamB(Ham_TakeDamage, entity, id, id, 9999.0, DMG_CRUSH);
			}
		}
	}
	return HAM_IGNORED
}
public Ham_DamageCrate_Pre(entity, inflictor, attacker, Float:damage, bits)
{
	if(pev_valid(entity)
	&& is_user_alive(attacker)
	&& !g_boolRoundended
	&& (get_user_weapon(attacker) == CSW_KNIFE || bits & DMG_CRUSH) 
	&& g_arrayPlayers[attacker][PLAYER_ENT_BLOCK] != entity)
	{	
		if( (pev(entity, pev_health) - damage) <= 0.0 )
		{
			g_arrayPlayers[attacker][PLAYER_ENT_BLOCK] = entity
			
			new intReturn;
			ExecuteForward(g_arrayForwards[FORWARD_CRATEHIT], intReturn, attacker, entity);
			
			return intReturn;
		}
	}
	return HAM_IGNORED
}
public Ham_DamagePlayer_Pre(id, inflictor, attacker, Float:damage, bits)
{
	if(is_user_alive(id)
	&& is_user_connected(attacker)
	&& inflictor == attacker)
	{
		return (get_user_weapon(attacker) == CSW_KNIFE) ? HAM_SUPERCEDE : HAM_IGNORED;
	}
	return HAM_IGNORED
}
public Ham_PressButton_Post(entity, id)	
{
	if(pev_valid(entity)
	&& is_user_alive(id)
	&& !g_boolRoundended)
	{		
		static strTargetname[32];
		pev(entity, pev_targetname, strTargetname, charsmax(strTargetname));
		
		if(strTargetname[0] == 'w' && strTargetname[3] == 'b') // winbut
		{
			g_boolRoundended = true;
		
			new intReturn;
			ExecuteForward(g_arrayForwards[FORWARD_WIN], intReturn, id, 1);
			
			if(!intReturn)
			{
				new strName[32];
				get_user_name(id, strName, charsmax(strName));
				
				ColorChat(0, GREY, "%s^3 %s^1 finished the deathrace!", PREFIX, strName)
			}
			
				// End round
			if(is_user_alive(g_intFakebotid))
			{
				fakedamage(g_intFakebotid, "worldspawn", 100.0, DMG_GENERIC);
			}
		}
	}
}

// Public: Fakebot (By xPaw)
public Task_UpdateBot()
{
	new id = find_player("i");
	
	if( !id ) 
	{
		id = engfunc(EngFunc_CreateFakeClient, g_strBotname);
		if( pev_valid( id ) ) 
		{
			engfunc( EngFunc_FreeEntPrivateData, id );
			dllfunc( MetaFunc_CallGameEntity, "player", id );
			set_user_info( id, "rate", "3500" );
			set_user_info( id, "cl_updaterate", "25" );
			set_user_info( id, "cl_lw", "1" );
			set_user_info( id, "cl_lc", "1" );
			set_user_info( id, "cl_dlmax", "128" );
			set_user_info( id, "cl_righthand", "1" );
			set_user_info( id, "_vgui_menus", "0" );
			set_user_info( id, "_ah", "0" );
			set_user_info( id, "dm", "0" );
			set_user_info( id, "tracker", "0" );
			set_user_info( id, "friends", "0" );
			set_user_info( id, "*bot", "1" );
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FAKECLIENT );
			set_pev( id, pev_colormap, id );
			
			new szMsg[ 128 ];
			dllfunc( DLLFunc_ClientConnect, id, g_strBotname, "127.0.0.1", szMsg );
			dllfunc( DLLFunc_ClientPutInServer, id );
			
			cs_set_user_team( id, CS_TEAM_T );
			ExecuteHamB( Ham_CS_RoundRespawn, id );
			
			set_pev( id, pev_effects, pev( id, pev_effects ) | EF_NODRAW );
			set_pev( id, pev_solid, SOLID_NOT );
			dllfunc( DLLFunc_Think, id );
			
			g_intFakebotid = id;
		}
	}
}

// Stock	
stock create_fakebot()
{
	create_entity("info_player_deathmatch")
	Task_UpdateBot()
}
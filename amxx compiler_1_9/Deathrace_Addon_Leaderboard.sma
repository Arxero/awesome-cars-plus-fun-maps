#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <colorchat>

#include <fun>

#define PLUGIN "Deathrace Addon: Leaderboard"
#define VERSION "1.0"
#define AUTHOR "Xalus"

#define PREFIX "^4[Deathrace]"

#define CLASS_Think "class_leaderboardthink"
#define CLASS_Checkpoint "class_checkpoint"

#define pev_checkpointid pev_iuser1
#define pev_distance pev_iuser2

#define UnitsToSeconds(%1) (%1 / 200.0) //(%1 * 0.0254) / 255

forward deathrace_win(id, type)
forward deathrace_reincarnation(id, type)

enum _:enumPlayers
{
	PLAYER_CHECKPOINT,
	PLAYER_POSITION,
	PLAYER_DISTANCE,
	PLAYER_ISDEAD,
	
	Float:PLAYER_TIME_START,
	
	PLAYER_BUIDLING
}
new g_arrayPlayers[33][enumPlayers];
new g_entityThink;

enum _:enumArrayinfo
{
	ARRAYINFO_PLAYERID,
	ARRAYINFO_DISTANCE
}
new Array:g_arrayPositions;

new g_spriteDot, g_forwardCheckpoint, g_forwardFinishtime;
new g_intCheckpointid, g_intPreviouscheckpoint;
new Float:g_floatOriginarea[3];

new bool:g_boolRoundended;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Register: Clcmd
	register_clcmd("say /cpmaker", "Menu_Checkpointmaker")
	
	// Register: Think
	register_think(CLASS_Think, "Think_Leaderboard");
	
	// Register: Touch
	register_touch(CLASS_Checkpoint, "player", "Touch_Checkpoint");
	
	// Register: Ham
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Ham_Knife_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1)
	
	// Register: Logevent
	register_logevent("Logevent_Roundend", 2, "1=Round_End");
	
	// Register: Event
	//register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	
	// Array
	g_arrayPositions = ArrayCreate(enumArrayinfo)
	
	// Register: MultiForward
	g_forwardCheckpoint = CreateMultiForward("deathrace_checkpoint", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL); 	// deathrace_checkpoint(id, entity, checkpointid, distance)
	g_forwardFinishtime = CreateMultiForward("deathrace_finish", ET_STOP, FP_CELL, FP_FLOAT); // deathrace_finish(id, Float:flTime)
	
	// Load checkpoints
	Load_Checkpoint()
}
public plugin_precache()
{
	g_entityThink = create_entity("info_target")
	entity_set_string(g_entityThink, EV_SZ_classname, CLASS_Think)
	
	g_spriteDot = precache_model("sprites/dot.spr");
}

// Public: Deathrace
public deathrace_win(id, type)
{
	if(type
	&& pev(g_entityThink, pev_nextthink) >= (get_gametime()-2.0) )
	{
		
		
		new Float:flWintime, strName[32], strTime[51];
		flWintime = (get_gametime() - Float:g_arrayPlayers[id][PLAYER_TIME_START]);
		get_user_name(id, strName, charsmax(strName))
		get_finishtime(floatround(flWintime), strTime, charsmax(strTime));
			
		ColorChat(0, GREY, "%s^3 %s^1 finished the deathrace in^3 %s^1.", PREFIX, strName, strTime)
		
		new intReturn;
		ExecuteForward(g_forwardFinishtime, intReturn, id, flWintime);
		
			// Block normal message
		return 1
	}
	return 0
}
public deathrace_reincarnation(id, type) // [Type 0: Spawn | Type 1: Checkpoint | Type 2: Deadspot]
{
		// Reset player when he spawns back to 'spawn'.
	if(type == 0)
	{
		arrayset(g_arrayPlayers[id], 0, enumPlayers);
		
		new intReturn;
		ExecuteForward(g_forwardCheckpoint, intReturn, id, 0, 0, 0);
	}
}
		
// Public: Menu
public Menu_Checkpointmaker(id)
{
	if(get_user_flags(id) & ADMIN_IMMUNITY)
	{
		new intMenu = menu_create("\dDeathrace\r Checkpoint maker", "Handler_Checkpointmaker")
		
		menu_additem(intMenu, "Create", "1")
		//menu_additem(intMenu, "\rShow^n", "2") // Wont work for some reason :/
		
		menu_additem(intMenu, "\wRemove \d(all)^n", "3")

		menu_additem(intMenu, get_user_noclip(id) ? "\rNoclip" : "\dNoclip", "4")
		
		menu_display(id, intMenu)
	}
	return PLUGIN_HANDLED
}
public Handler_Checkpointmaker(id, menu, item)
{
	if(item != MENU_EXIT)
	{
		switch(MenuKey(menu, item))
		{
			case 1: // Create
			{
				g_arrayPlayers[id][PLAYER_BUIDLING] = 1;
				client_print(id, print_center, "Aim on the top right corner of the checkpoint.");
				
				client_cmd(id, "spk fvox/blip.wav") ;
			}
			case 2: // Show
			{
				new intEntity = -1;
				while( (intEntity = find_ent_by_class(intEntity, CLASS_Checkpoint)) )
				//while( (intEntity = engfunc(EngFunc_FindEntityByString, intEntity, "classname", CLASS_Checkpoint)) )
				{
					show_zone(intEntity);
					
					client_print(0, print_chat, "Showing %i", intEntity)
				}
				
				Menu_Checkpointmaker(id);
			}
			case 3: // Remove
			{
				remove_entity_name(CLASS_Checkpoint);
				
				client_print(id, print_center, "* Checkpoints removed!");
				
				Save_Checkpoint(id);
				
				Menu_Checkpointmaker(id);
			}
			case 4: // Noclip
			{
				set_user_noclip(id, !get_user_noclip(id));
				Menu_Checkpointmaker(id);
			}
		}
	}
}

// Public: Logevent
public Logevent_Roundend()
{
	g_boolRoundended = true;
	
	remove_task(141340);
	set_task(6.0, "Task_Roundstarted", 141340);
}
public Task_Roundstarted()
{
	g_boolRoundended = false;
}

// Public: Ham
public Ham_PlayerSpawn_Post(id)
{
	if(is_user_alive(id)
	&& g_boolRoundended)
	{
		arrayset(g_arrayPlayers[id], 0, enumPlayers);
		
		new intReturn;
		ExecuteForward(g_forwardCheckpoint, intReturn, id, 0, 0, 0);
	}
}

public Ham_Knife_PrimaryAttack_Post(entity)
{
	if(pev_valid(entity))
	{
		static intOwner
		intOwner = pev(entity, pev_owner)
		
		if(get_user_flags(intOwner) & ADMIN_IMMUNITY
		&& g_arrayPlayers[intOwner][PLAYER_BUIDLING])
		{
			if(g_arrayPlayers[intOwner][PLAYER_BUIDLING] == 1)
			{
				g_arrayPlayers[intOwner][PLAYER_BUIDLING]++
					
				fm_get_aim_origin(intOwner, g_floatOriginarea);
				
				client_print(intOwner, print_center, "Now set the origin for the bottom left corner of the Area");
				
				client_cmd(intOwner, "spk fvox/blip.wav") ;
			} 
			else 
			{
				new Float:flOrigin[3];
				fm_get_aim_origin(intOwner, flOrigin);

				new Float:fCenter[3], Float:fSize[3];
				new Float:fMins[3], Float:fMaxs[3];
				for ( new i = 0; i < 3; i++ ) 
				{
					fCenter[i] = (g_floatOriginarea[i] + flOrigin[i]) / 2.0;
					
					fSize[i] = get_float_difference(g_floatOriginarea[i], flOrigin[i]);
					
					fMins[i] = fSize[i] / -2.0;	
					fMaxs[i] = fSize[i] / 2.0;
				}
				show_zone(fm_create_info_zone(g_intCheckpointid, fCenter, fMins, fMaxs));
				
				g_arrayPlayers[intOwner][PLAYER_BUIDLING] = 0;
				
				client_print(intOwner, print_center, "* Checkpoint (#%i) created.", g_intCheckpointid)				
				Save_Checkpoint(intOwner)
				
				Menu_Checkpointmaker(intOwner)
			}
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

// Public: Think
public Think_Leaderboard(entity)
{
	if(pev_valid(entity) && entity == g_entityThink)
	{	
		static intReincarnation;
		if(!intReincarnation)
		{	
			if( !(intReincarnation = get_cvar_num("deathrace_reincarnation_status")) )
				intReincarnation = -1
		}
		
		static bool:boolTodo
		boolTodo = !boolTodo

		if(!boolTodo)
		{
			static intSize;
			intSize = ArraySize(g_arrayPositions);
				
			new strTemp[101], intLen, arrayInfo[enumArrayinfo], strName[32];
			//new intTime, intLeaderdistance;
			
			new arrayPlayers[32], intPlayers;
			get_players(arrayPlayers, intPlayers, (intReincarnation == 1) ? "ec" : "aec", "CT");
			
			new intPosition, intFoundplayer, Float:floatTime[3];
			
			for(new j = 0; j < intPlayers; j++)
			{
				intLen = formatex(strTemp, charsmax(strTemp), "     - Leaderboard -^n")
				intPosition = intFoundplayer = 0;
				
				//ArrayGetArray(g_arrayPositions, intPosition, g_arrayPlayers[ arrayPlayers[j] ][PLAYER_ARRAYID]);
				//intLeaderdistance = arrayInfo[ARRAYINFO_DISTANCE];
				
				for(new i = 0; i < 5; i++)
				{
					if(i >= intSize)
						break;
					
					intPosition = (i < 2) ? i : (intFoundplayer == 3) ? (g_arrayPlayers[ arrayPlayers[j] ][PLAYER_POSITION] + 1) : (intFoundplayer == 2) ? g_arrayPlayers[ arrayPlayers[j] ][PLAYER_POSITION] : (intFoundplayer == 1) ? g_arrayPlayers[ arrayPlayers[j] ][PLAYER_POSITION] - 1 : i;	
					ArrayGetArray(g_arrayPositions, intPosition, arrayInfo)
						
					get_user_name(arrayInfo[ ARRAYINFO_PLAYERID ], strName, charsmax(strName));
					
					//client_print(0, print_chat, "#%i - %s (Time: %f)", i+1, strName, UnitsToSeconds( (g_arrayPlayers[arrayPlayers[j]][PLAYER_DISTANCE] - arrayInfo[ARRAYINFO_DISTANCE])))
					
					if(arrayInfo[ ARRAYINFO_PLAYERID ] == arrayPlayers[j])
					{
						intLen += formatex(strTemp[intLen], sizeof(strTemp) - 1 - intLen, "%i.    %s %s^n", i+1, strName, g_arrayPlayers[ arrayInfo[ ARRAYINFO_PLAYERID ] ][PLAYER_ISDEAD] ? "[DEAD]" : "");
					}
					else
					{
						floatTime[0] = floatTime[2] = UnitsToSeconds( (g_arrayPlayers[arrayPlayers[j]][PLAYER_DISTANCE] - arrayInfo[ARRAYINFO_DISTANCE]));
						
						if(floatTime[0] < 0.0)
							floatTime[0] *= -1.0;
						
						floatTime[1] = float( floatround(floatTime[0] / 60.0) );
						
						intLen += formatex(strTemp[intLen], sizeof(strTemp) - 1 - intLen, "%i.    %s (%s0%i:%.2f) %s^n", i+1, strName, (floatTime[2] >= 0.0) ? "+" : "-", floatround(floatTime[1]), (floatTime[0] - (60.0 * floatTime[1])), g_arrayPlayers[ arrayInfo[ ARRAYINFO_PLAYERID ] ][PLAYER_ISDEAD] ? "[DEAD]" : "");// * -1.0) )
					}
					
					
					if(intPosition)
					{
						intPosition++
					}
					else if(g_arrayPlayers[ arrayPlayers[j] ][PLAYER_POSITION] >= 5
					&& i >= 2)
					{
						intFoundplayer = 1
					}
				}
				set_hudmessage(255, 255, 255, 0.0, 0.17, 0, 6.0, 2.2, .channel=3);
				show_hudmessage(arrayPlayers[j], strTemp)			
			}
			
			set_pev(entity, pev_nextthink, get_gametime() + 1.0);
			return;
		}

		ArrayClear(g_arrayPositions);

		new arrayPlayers[32], intPlayers;
		get_players(arrayPlayers, intPlayers, (intReincarnation == 1) ? "ec" : "aec", "CT");
		
		new arrayInfo[enumArrayinfo];
		for(new i = 0; i < intPlayers; i++)
		{
			arrayInfo[ARRAYINFO_PLAYERID] = arrayPlayers[i];
			g_arrayPlayers[ arrayPlayers[i] ][PLAYER_ISDEAD] = !is_user_alive(arrayPlayers[i]);
	
			if(g_arrayPlayers[ arrayPlayers[i] ][PLAYER_ISDEAD])
			{
				arrayInfo[ARRAYINFO_DISTANCE] = g_arrayPlayers[arrayPlayers[i]][PLAYER_DISTANCE];
			}
			else if(pev_valid(g_arrayPlayers[arrayPlayers[i]][PLAYER_CHECKPOINT]))
			{
				arrayInfo[ARRAYINFO_DISTANCE] = (pev(g_arrayPlayers[arrayPlayers[i]][PLAYER_CHECKPOINT], pev_distance) + floatround(entity_range(g_arrayPlayers[arrayPlayers[i]][PLAYER_CHECKPOINT], arrayPlayers[i])))
			}
			else
			{				
				arrayInfo[ARRAYINFO_DISTANCE] = 0;
			}
			ArrayPushArray(g_arrayPositions, arrayInfo)

			g_arrayPlayers[arrayPlayers[i]][PLAYER_DISTANCE] = arrayInfo[ARRAYINFO_DISTANCE];
		}
		ArraySort(g_arrayPositions, "Array_SortPositions")
		
		set_pev(entity, pev_nextthink, get_gametime() + 1.0);
	}
}
public Array_SortPositions(Array:array, item1, item2, const data[], data_size)
{
	new arrayInfo[2][enumArrayinfo];
	ArrayGetArray(array, item1, arrayInfo[0]);
	ArrayGetArray(array, item2, arrayInfo[1]);
	
	return clamp(arrayInfo[1][ARRAYINFO_DISTANCE] - arrayInfo[0][ARRAYINFO_DISTANCE], -1, 1);
	
}

// Public: Touch
public Touch_Checkpoint(entity, id)
{
	if(pev_valid(entity)
	&& is_user_alive(id))
	{
		if(g_arrayPlayers[id][PLAYER_CHECKPOINT] != entity)
		{
			g_arrayPlayers[id][PLAYER_CHECKPOINT] = entity;
			
			static intCheckpointid;
			if( !(intCheckpointid = pev(g_arrayPlayers[id][PLAYER_CHECKPOINT], pev_checkpointid)) )
			{
				g_arrayPlayers[id][PLAYER_TIME_START] = _:get_gametime();
			}
			
			new intReturn;
			ExecuteForward(g_forwardCheckpoint, intReturn, id, entity, intCheckpointid, pev(g_arrayPlayers[id][PLAYER_CHECKPOINT], pev_distance));
		}
	}
}


// Public: File (checkpoint) management
public Save_Checkpoint(id) 
{
	new szFile[75], szMapName[32];
	get_datadir(szFile, sizeof szFile - 1);
	get_mapname(szMapName, sizeof szMapName - 1);
		
	add(szFile, sizeof szFile - 1, "/Deathrace_Checkpoint");
		
	formatex(szFile, sizeof szFile - 1, "%s/%s.ini", szFile, szMapName);
	
	new iFile = fopen(szFile, "wt+");
	
	new iEnt = -1, iResults
	new Float:fOrigin[3], Float:fMins[3], Float:fMaxs[3];
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", CLASS_Checkpoint)) != 0) 
	{
		pev(iEnt, pev_mins, fMins);
		pev(iEnt, pev_maxs, fMaxs);
		pev(iEnt, pev_origin, fOrigin);

		fprintf(iFile, "^"%i^" ^"%i^" ^"%.1f;%.1f;%.1f^" ^"%.1f;%.1f;%.1f^" ^"%.1f;%.1f;%.1f^"^n", pev(iEnt, pev_checkpointid), pev(iEnt, pev_distance), fOrigin[0], fOrigin[1], fOrigin[2], fMins[0], fMins[1], fMins[2], fMaxs[0], fMaxs[1], fMaxs[2]);
		iResults++
	}
	fclose(iFile);
	
	client_print(id, print_chat, "* Saved %i checkpoints", iResults)
	
	return 1;
}
public Load_Checkpoint() 
{
	new szFile[64], szMapName[32];
	get_datadir(szFile, sizeof szFile - 1);
	get_mapname(szMapName, sizeof szMapName - 1);
	
	add(szFile, sizeof szFile - 1, "/Deathrace_Checkpoint");
	
	if(!dir_exists(szFile))
		mkdir(szFile);
	
	formatex(szFile, sizeof szFile - 1, "%s/%s.ini", szFile, szMapName);
	
	if(!file_exists(szFile))
	{
		//set_fail_state("ERROR: Checkpoints");
		return 0;
	}
	
	new iFile = fopen(szFile, "at+");
	
	new szBuffer[256], strID[16], strDistance[32];
	new szOrigin[64], szMins[64], szMaxs[64];
	new szTemp1[3][32], szTemp2[3][32], szTemp3[3][32];
	
	while(!feof(iFile)) 
	{
		fgets(iFile, szBuffer, sizeof szBuffer - 1);
		
		if(!szBuffer[0])
			continue;
		
		parse(szBuffer, strID, charsmax(strID), strDistance, charsmax(strDistance), szOrigin, sizeof szOrigin - 1, szMins, sizeof szMins - 1, szMaxs, sizeof szMaxs - 1);
		
		str_piece(szOrigin, szTemp1, sizeof szTemp1, sizeof szTemp1[] - 1, ';');
		str_piece(szMins, szTemp2, sizeof szTemp2, sizeof szTemp2[] - 1, ';');
		str_piece(szMaxs, szTemp3, sizeof szTemp3, sizeof szTemp3[] - 1, ';');
		
		static Float:fOrigin[3], Float:fMins[3], Float:fMaxs[3];
		fOrigin[0] = str_to_float(szTemp1[0]);
		fOrigin[1] = str_to_float(szTemp1[1]);
		fOrigin[2] = str_to_float(szTemp1[2]);
		
		fMins[0] = str_to_float(szTemp2[0]);
		fMins[1] = str_to_float(szTemp2[1]);
		fMins[2] = str_to_float(szTemp2[2]);
		
		fMaxs[0] = str_to_float(szTemp3[0]);
		fMaxs[1] = str_to_float(szTemp3[1]);
		fMaxs[2] = str_to_float(szTemp3[2]);
		
		fm_create_info_zone(str_to_num(strID), fOrigin, fMins, fMaxs, str_to_num(strDistance));
		
		//log_amx("Loaded checkpoint #%i, distance %i", str_to_num(strID), str_to_num(strDistance))
	}
	fclose(iFile);
	return 1;
}

// Stock
stock fm_create_info_zone(type, Float:fOrigin[3], Float:fMins[3], Float:fMaxs[3], intDistance = 0) 
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if(!iEnt)
		return 0;
	
	new intClassalloc
	if(!intClassalloc)
	{
		intClassalloc = engfunc(EngFunc_AllocString, CLASS_Checkpoint)
	}
	set_pev_string(iEnt, pev_classname, intClassalloc)
	
	engfunc(EngFunc_SetModel, iEnt, "models/p_usp.mdl")
	
	set_pev(iEnt, pev_movetype, MOVETYPE_NONE)
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	
	engfunc(EngFunc_SetSize, iEnt, fMins, fMaxs)
	engfunc(EngFunc_SetOrigin, iEnt, fOrigin)
	
	set_pev(iEnt, pev_checkpointid, type)
	
	set_rendering(iEnt, kRenderFxNone, .render=kRenderTransAlpha, .amount=0)

	set_checkpoint_distance(iEnt, intDistance)
	
	g_intCheckpointid++
	
	if(pev_valid(g_entityThink))
		set_pev(g_entityThink, pev_nextthink, get_gametime() + 5.0)
	
	return iEnt;
}

stock fm_get_aim_origin(index, Float:origin[3]) 
{
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	
	xs_vec_add(start, view_ofs, start);
	
	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);
	
	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);
	
	return 1;
}

stock Float:get_float_difference(Float:num1, Float:num2) 
{
	if( num1 > num2 )
		return (num1-num2);
	else if( num2 > num1 )
		return (num2-num1);
	
	return 0.0;
}

stock str_piece(const input[], output[][], outputsize, piecelen, token = '|') 
{
	new i = -1, pieces, len = -1 ;
	
	while ( input[++i] != 0 ) {
		if ( input[i] != token ) {
			if ( ++len < piecelen )
				output[pieces][len] = input[i];
		}
		else {
			output[pieces++][++len] = 0 ;
			len = -1 ;
			
			if ( pieces == outputsize )
				return pieces ;
		}
	}
	return pieces + 1;
}

stock set_checkpoint_distance(entity, intDistance)
{
	if(intDistance
	|| !pev(entity, pev_checkpointid))
	{
		set_pev(entity, pev_distance, intDistance);
	}
	else if(pev_valid(g_intPreviouscheckpoint))
	{
		set_pev(entity, pev_distance, (pev(g_intPreviouscheckpoint, pev_distance) + floatround(entity_range(entity, g_intPreviouscheckpoint))));
	}
	g_intPreviouscheckpoint = entity;
}

stock show_zone(entity)
{
	new Float:arrayInfo[3][3];
	
	pev(entity, pev_maxs, arrayInfo[0]);
	pev(entity, pev_mins, arrayInfo[1]);
	pev(entity, pev_origin, arrayInfo[2]);
	
	arrayInfo[1][0] += arrayInfo[2][0];
	arrayInfo[1][1] += arrayInfo[2][1];
	arrayInfo[1][2] += arrayInfo[2][2];
	arrayInfo[0][0] += arrayInfo[2][0];
	arrayInfo[0][1] += arrayInfo[2][1];
	arrayInfo[0][2] += arrayInfo[2][2];
	
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[0][1], arrayInfo[0][2], arrayInfo[1][0], arrayInfo[0][1], arrayInfo[0][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[0][1], arrayInfo[0][2], arrayInfo[0][0], arrayInfo[1][1], arrayInfo[0][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[0][1], arrayInfo[0][2], arrayInfo[0][0], arrayInfo[0][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[1][1], arrayInfo[1][2], arrayInfo[0][0], arrayInfo[1][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[1][1], arrayInfo[1][2], arrayInfo[1][0], arrayInfo[0][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[1][1], arrayInfo[1][2], arrayInfo[1][0], arrayInfo[1][1], arrayInfo[0][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[0][1], arrayInfo[0][2], arrayInfo[1][0], arrayInfo[0][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[0][1], arrayInfo[1][2], arrayInfo[0][0], arrayInfo[0][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[0][1], arrayInfo[1][2], arrayInfo[0][0], arrayInfo[1][1], arrayInfo[1][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[1][1], arrayInfo[1][2], arrayInfo[0][0], arrayInfo[1][1], arrayInfo[0][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[0][0], arrayInfo[1][1], arrayInfo[0][2], arrayInfo[1][0], arrayInfo[1][1], arrayInfo[0][2], {255, 0, 0});
	fm_draw_line(0, arrayInfo[1][0], arrayInfo[1][1], arrayInfo[0][2], arrayInfo[1][0], arrayInfo[0][1], arrayInfo[0][2], {255, 0, 0});
}

stock fm_draw_line(id, Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, g_iColor[3])
{
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, SVC_TEMPENTITY, _, id ? id : 0);
	
	write_byte(TE_BEAMPOINTS);
	
	write_coord(floatround(x1));
	write_coord(floatround(y1));
	write_coord(floatround(z1));
	
	write_coord(floatround(x2));
	write_coord(floatround(y2));
	write_coord(floatround(z2));
	
	write_short(g_spriteDot);
	write_byte(1);
	write_byte(1);
	write_byte(10);
	write_byte(5);
	write_byte(0); 
	
	write_byte(g_iColor[0]);
	write_byte(g_iColor[1]); 
	write_byte(g_iColor[2]);
	
	write_byte(200); 
	write_byte(0);
	
	message_end();
}

stock MenuKey(menu, item) 
{
	new szData[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, szData, charsmax(szData), szName, charsmax(szName), callback);
	
	menu_destroy(menu)
	
	return str_to_num(szData);
}

stock get_finishtime(const laptime, length[], len) // (Credits: Advanced Bans)
{
	new seconds = laptime;
	new minutes = 0;
	
	while( seconds >= 60 )
	{
		seconds -= 60;
		minutes++;
	}

	if( minutes )
	{
		formatex(length, len, "%i minute%s, %i second%s", minutes, minutes == 1 ? "" : "s", seconds, seconds == 1 ? "" : "s");
	}
	else
	{
		formatex(length, len, "%i second%s", seconds, seconds == 1 ? "" : "s");
	}
}
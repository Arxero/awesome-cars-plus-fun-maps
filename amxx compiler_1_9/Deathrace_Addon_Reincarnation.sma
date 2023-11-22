#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define PLUGIN "Deathrace Addon: Reincarnation"
#define VERSION "1.2"
#define AUTHOR "Xalus"

#define CLASS_Corpse "class_corpse"
#define TASK_Reincarnation 32524

forward deathrace_win(id, type)
forward deathrace_checkpoint(id, entity, checkpointid, distance)

new g_arrayPlayercorpse[33], g_arrayPlayercheckpoint[33];
new Float:g_floatRoundend;

new g_forwardReincarnation;
new g_cvarReincarnation;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Register: Cvar
	g_cvarReincarnation = register_cvar("deathrace_reincarnation_status", "1")
	
	// Register: Clcmd's
	register_clcmd("say /checkpoint", "Cmd_Checkpoint")
	register_clcmd("say /cp", "Cmd_Checkpoint")
	register_clcmd("say /respawn", "Cmd_Respawn")
	
	// Register: Forwards
	register_forward(FM_ClientKill, "Forward_ClientKill_Pre", 0);
	
	// Register: Event
	register_event("ClCorpse", "Event_ClCorpse", "a", "10=0");
	
	// Register: Logevent
	register_logevent("Logevent_Roundend", 2, "1=Round_End");

	// Register: MultiForward
	g_forwardReincarnation = CreateMultiForward("deathrace_reincarnation", ET_STOP, FP_CELL, FP_CELL); // deathrace_reincarnation(id, type) // [Type 0: Spawn | Type 1: Checkpoint | Type 2: Deadspot]
	
	// Block: Corpse
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);
}
// Public: Deathrace
public deathrace_win(id, type)
{
		// Block survival roundend
	return !type ? 2 : 0;
}
public deathrace_checkpoint(id, entity, checkpointid, distance)
{
	g_arrayPlayercheckpoint[id] = entity;
}

// Public: Clcmds
public Cmd_Checkpoint(id)
{
	if(is_user_alive(id))
	{
		if(pev_valid(g_arrayPlayercheckpoint[id]))
		{
			new Float:flOrigin[3];
			pev(g_arrayPlayercheckpoint[id], pev_origin, flOrigin);
			
			engfunc(EngFunc_SetOrigin, id, flOrigin);
			
			client_print(id, print_center, "* You have been teleported to your checkpoint");
		}
		else
		{
			client_print(id, print_center, "* Could not find a valid checkpoint");
		}
	}
}
public Cmd_Respawn(id)
{
	if(!is_user_alive(id))
	{
		remove_task(id + TASK_Reincarnation);
		
		if(pev_valid(g_arrayPlayercorpse[id]))
		{
			engfunc(EngFunc_RemoveEntity, g_arrayPlayercorpse[id]);
			g_arrayPlayercorpse[id] = 0;
		}
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		
		client_print(id, print_center, "* You've been revived back to life");
	}
	else
	{
		client_print(id, print_center, "* You are already alive, If you are stuck, Use the '/checkpoint' command");
	}
}
		

// Public: Forward
public Forward_ClientKill_Pre(id)
{
	g_arrayPlayercorpse[id] = -1;
}

// Public: Logevent
public Logevent_Roundend()
{
	g_floatRoundend = get_gametime() + 5.0;
	remove_entity_name(CLASS_Corpse);
}

// Public: Event
public Event_ClCorpse()
{
	new id = read_data(12);
	
	if(is_user_connected(id)
	&& !is_user_alive(id)
	&& g_floatRoundend < get_gametime()
	&& get_pcvar_num(g_cvarReincarnation))
	{
		if(g_arrayPlayercorpse[id] == -1)
		{
			g_arrayPlayercorpse[id] = 0;
			
			set_task(3.0, "Task_RespawnPlayer", id)
			return PLUGIN_CONTINUE
		}

		new strModel[31], strModelpath[101]
		read_data(1, strModel, charsmax(strModel));
		formatex(strModelpath, charsmax(strModelpath), "models/player/%s/%s.mdl", strModel, strModel)
		
		new Float:flOrigin[3];
		flOrigin[0] = read_data(2) / 128.0;
		flOrigin[1] = read_data(3) / 128.0;
		flOrigin[2] = read_data(4) / 128.0;

		new Float:flAngle[3];
		flAngle[0] = float(read_data(5));
		flAngle[1] = float(read_data(6));
		flAngle[2] = float(read_data(7));

		if(create_reincarnation(id, read_data(9), pev(id, pev_frame), strModelpath, flAngle, flOrigin))
		{
			pev(id, pev_v_angle, flAngle)
			set_pev(g_arrayPlayercorpse[id], pev_oldorigin, flAngle)
		}
	}
	return PLUGIN_CONTINUE
}
// Tasks
public Task_RespawnPlayer(id)
{
	if(is_user_connected(id)
	&& !is_user_alive(id)
	&& g_floatRoundend < get_gametime())
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id);
	}
}
public Task_FinishReincarnation(id)
{
	if(g_floatRoundend < get_gametime())
	{
		if(pev_valid(g_arrayPlayercorpse[id])
		&& pev(g_arrayPlayercorpse[id], pev_owner) == id)
		{
			if(is_user_connected(id)
			&& !is_user_alive(id))
			{
					// Player
				new Float:flOrigin[3], intType;
				pev(g_arrayPlayercorpse[id], pev_origin, flOrigin);
	
				ExecuteHamB(Ham_CS_RoundRespawn, id);
				
				new bool:crateClose
				if( (crateClose = is_deathcrate_close(flOrigin)) )
				{
					if(get_checkpoint_origin(id, flOrigin))
					{
						client_print(id, print_center, "You were about to get trapped by death crates, you were teleported to your last checkpoint.");
						intType = 1;
						
						goto gotoStuckcheck;
					}
					client_print(id, print_center, "You were about to get trapped by death crates!");
					
					send_reincarnation_forward(id, 0);
					goto gotoRemovecorpse;
				}
				
					// Stuck ?
				flOrigin[2] += 35.0;
					
				gotoStuckcheck:
				
				if(!is_hull_vacant(flOrigin, HULL_HUMAN, id))
				{
					if(!crateClose
					&& get_checkpoint_origin(id, flOrigin))
					{
						//pev(g_arrayPlayercheckpoint[id], pev_origin, flOrigin)
						client_print(id, print_center, "You cannot reincarnate here. You have been teleported back to your checkpoint.");
						
						crateClose = true;
						
						goto gotoStuckcheck;
					}
					
					client_print(id, print_center, "You cannot reincarnate here. You have been teleported back to your spawn.");
					
					send_reincarnation_forward(id, 0);
					
					goto gotoRemovecorpse;
				}
				engfunc(EngFunc_SetOrigin, id, flOrigin);
				
				drop_to_floor(id);
				
				pev(g_arrayPlayercorpse[id], pev_oldorigin, flOrigin);
				set_pev(id, pev_v_angle, flOrigin);
				set_pev(id, pev_angles, flOrigin);
				set_pev(id, pev_punchangle, 1.0);
				
				send_reincarnation_forward(id, intType);
			}
			// Corpse
			gotoRemovecorpse:
			
			engfunc(EngFunc_RemoveEntity, g_arrayPlayercorpse[id]);
			g_arrayPlayercorpse[id] = 0;
		}
	}
}
stock get_checkpoint_origin(id, Float:flOrigin[3])
{
	if(pev_valid(g_arrayPlayercheckpoint[id]))
	{
		pev(g_arrayPlayercheckpoint[id], pev_origin, flOrigin);
		
		return 1;
	}
	return 0;
}
	

// Stock: Create
stock create_reincarnation(id, intSequence, flFrame, strModel[101], Float:flAngle[3], Float:flOrigin[3])
{
	static intClassname;
	if(!intClassname)
	{
		intClassname = engfunc(EngFunc_AllocString, "info_target");
	}
	g_arrayPlayercorpse[id] = engfunc(EngFunc_CreateNamedEntity, intClassname);
	
	set_pev(g_arrayPlayercorpse[id], pev_classname, CLASS_Corpse);
	
	engfunc(EngFunc_SetModel, g_arrayPlayercorpse[id], strModel);
	
	set_pev(g_arrayPlayercorpse[id], pev_movetype, MOVETYPE_FLY);
	
	set_pev(g_arrayPlayercorpse[id], pev_mins, {-16.0,-16.0,-36.0});
	set_pev(g_arrayPlayercorpse[id], pev_maxs, {16.0,16.0,36.0});
	
	set_pev(g_arrayPlayercorpse[id], pev_solid, SOLID_NOT);
	
	set_pev(g_arrayPlayercorpse[id], pev_v_angle, flAngle);
	set_pev(g_arrayPlayercorpse[id], pev_owner, id);

	engfunc(EngFunc_SetOrigin, g_arrayPlayercorpse[id], flOrigin);

	engfunc(EngFunc_DropToFloor, g_arrayPlayercorpse[id]);
	
	set_pev(g_arrayPlayercorpse[id], pev_sequence, intSequence);
	
	set_pev(g_arrayPlayercorpse[id], pev_framerate, -0.4);
	set_pev(g_arrayPlayercorpse[id], pev_frame, float(flFrame));
	set_pev(g_arrayPlayercorpse[id], pev_animtime, get_gametime()+1.0);
	
	set_task((float(flFrame) * 0.02), "Task_FinishReincarnation", id); // 0.034
	
	return g_arrayPlayercorpse[id];
}

// Stock
stock bool:is_hull_vacant(const Float:origin[3], hull,id) 
{
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true
	
	return false
}
stock bool:is_deathcrate_close(Float:flOrigin[3])
{
	new arrayCrates[12], intResults;
	intResults = find_sphere_class(0, "func_breakable", 37.0, arrayCrates, charsmax(arrayCrates), flOrigin);
	
	new strTargetname[32];
	for(new i = 0; i < intResults; i++)
	{
		pev(arrayCrates[i], pev_targetname, strTargetname, charsmax(strTargetname));
		
		if(equal(strTargetname, "deathcrate"))
		{
			return true;
		}
	}
	return false;
}
/*
stock bool:is_triggerhurt_close(Float:flOrigin[3])
{
	new arrayCrates[12], intResults;
	intResults = find_sphere_class(0, "trigger_hurt", 37.0, arrayCrates, charsmax(arrayCrates), flOrigin);
	
	client_print(0, print_chat, "Results: %i", intResults)
	
	return bool:intResults;
}

stock bool:is_triggerhurt_under(id, Float:flOrigin[3])
{
	new Float:flOrigindown[3];
	flOrigindown[0] = flOrigin[0];
	flOrigindown[1] = flOrigin[1];
	flOrigindown[2] = (flOrigin[2] - 300.0);
	
	new iTraceHandle = create_tr2();
	engfunc(EngFunc_TraceLine, flOrigin, flOrigindown, IGNORE_MONSTERS, id, iTraceHandle);
	
	get_tr2(iTraceHandle, TR_vecEndPos, flOrigindown);
	
	free_tr2(iTraceHandle);
	
	return is_triggerhurt_close(flOrigindown);
	
	new intEntity;
	if(pev_valid( (intEntity = get_tr2(iTraceHandle, TR_pHit)) ))
	{
		new strClassname[32];
		pev(intEntity, pev_classname, strClassname, charsmax(strClassname));
		
		client_print(0, print_chat, "Under: %s", strClassname);
		
		return true;
	
	}
	free_tr2(iTraceHandle);
	
	return false;
	
}
*/
	
stock send_reincarnation_forward(id, type)
{
	new intReturn;
	ExecuteForward(g_forwardReincarnation, intReturn, id, type);
}
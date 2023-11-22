#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>
#include <hamsandwich>
#include <engine>

#define PLUGIN "Deathrace Addon: Slipstream"
#define VERSION "1.0"
#define AUTHOR "Xalus"


#define MAX_Entities 4
#define TIME_Think 0.2
#define CLASS_Slip "class_slipentity"
#define pev_slipid pev_iuser1

#define SPEED_Gain 3.0
#define ANGLE_Difference	20.0
#define MAX_Distance		200.0

enum _:enumPlayers
{
	PLAYER_SLIPPING,
	Float:PLAYER_DELAY,
	
	PLAYER_SLIPSTREAM,
	
	PLAYER_STALKER,
	
	PLAYER_ENT_STREAM[MAX_Entities]
}
new g_arrayPlayers[33][enumPlayers]

new g_spriteTrail

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Register: Ham
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1)
	
	// Register: Event
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	register_event( "StatusValue", "Event_StatusValue", "b", "1=2", "2>0" );
	
	// Register: Think
	register_think(CLASS_Slip, "Think_Slipstream");
	register_touch(CLASS_Slip, "player", "Touch_Slipstream")
}
public plugin_precache()
{
	g_spriteTrail = precache_model("sprites/plasma.spr")//"sprites/xenobeam.spr")
}

// Public: Event
public Event_NewRound()
{
	remove_entity_name(CLASS_Slip)
}
public Event_StatusValue( const id )
{
	if(is_user_alive(id))
	{
		if( !(pev(id, pev_button) & IN_FORWARD) )
			return
		
		new intTarget = read_data(2);
		
		if(g_arrayPlayers[intTarget][PLAYER_SLIPSTREAM]
		|| get_speed(intTarget) < 150
		|| !(pev(intTarget, pev_button) & IN_FORWARD))
			return

		static Float:flAngles[2][3]
		pev(id, pev_angles, flAngles[0])
		pev(intTarget, pev_angles, flAngles[1])
		
		if(flAngles[1][1] < (flAngles[0][1] + ANGLE_Difference)
		&& flAngles[1][1] > (flAngles[0][1] - ANGLE_Difference))
		{
			if(entity_range(id, intTarget) <= MAX_Distance)
			{
				start_slipstream(intTarget, id)
			}
		}
	}
}

// Public: Ham
public Ham_PlayerSpawn_Post(id)
{
	if(is_user_alive(id))
	{
		arrayset(g_arrayPlayers[id], 0, enumPlayers)
	}
}

// Public: Touch
public Touch_Slipstream(entity, player)
{
	if(pev_valid(entity)
	&& is_user_alive(player))
	{
		static Float:flGametime
		if(Float:g_arrayPlayers[player][PLAYER_DELAY] < (flGametime = get_gametime()))
		{
			g_arrayPlayers[player][PLAYER_DELAY] = _:(flGametime + TIME_Think)
			
			static intOwner
			intOwner = pev(entity, pev_owner)
			
			if(player == intOwner
			|| g_arrayPlayers[player][PLAYER_SLIPPING] == -1)
			{
				//stop_slipstream(intOwner)
				return
			}

			if(!g_arrayPlayers[player][PLAYER_SLIPPING])
			{
				g_arrayPlayers[player][PLAYER_SLIPPING] = 1
				screenfade_slipstream(player, 10.0)
			}
			g_arrayPlayers[intOwner][PLAYER_STALKER] = player

			//set_user_maxspeed(player, (get_user_maxspeed(player) + SPEED_Gain))
			set_pev(player, pev_maxspeed, (pev(player, pev_maxspeed) + SPEED_Gain));
			
			remove_task(player + 24561)
			set_task( (TIME_Think * 3.0), "Task_StopSlipping", (player + 24561))
		}
	}
}
public Task_StopSlipping(player)
{
	player -= 24561
	
	if(is_user_alive(player)
	&& g_arrayPlayers[player][PLAYER_SLIPPING])
	{
		g_arrayPlayers[player][PLAYER_SLIPPING] = -1;
		screenfade_slipstream(player, 0.0)
		
		set_task(2.0, "Task_Speedloose", player)
		
		ExecuteHamB(Ham_Item_PreFrame, player);
	}
}
public Task_Speedloose(player)
{
	if(is_user_alive(player)
	&& g_arrayPlayers[player][PLAYER_SLIPPING] == -1)
	{
		g_arrayPlayers[player][PLAYER_SLIPPING] = 0
		
		ExecuteHamB(Ham_Item_PreFrame, player)
	}
}

// Public: Think
public Think_Slipstream(entity)
{
	if(pev_valid(entity))
	{
		static intOwner
		intOwner = pev(entity, pev_owner)
		
		if(!is_user_alive(intOwner)
		|| pev(entity, pev_slipid)
		|| !g_arrayPlayers[ intOwner ][PLAYER_SLIPSTREAM]
		|| entity_range(intOwner, g_arrayPlayers[ intOwner ][PLAYER_STALKER]) > (MAX_Distance + 50.0))
		{
			stop_slipstream(intOwner)
			return
		}
		
		new intSwitch
		
		static Float:flOrigin[2][3];
		pev(entity, pev_oldorigin, flOrigin[intSwitch]);
		
		for(new j = 1; j < MAX_Entities; j++)
		{
			if( g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j] )
			{
				pev(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j], pev_oldorigin, flOrigin[!intSwitch]);
				
				if(flOrigin[!intSwitch][0] == 0.0
				|| flOrigin[!intSwitch][1] == 0.0
				|| flOrigin[!intSwitch][2] == 0.0)
				{
					set_pev(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j], pev_iuser2, 0)
					set_pev(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j], pev_oldorigin, flOrigin[intSwitch])

					break
				}
				
				if( !update_slipentity(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j], flOrigin[intSwitch]) )
				{
					stop_slipstream(intOwner)
					return
				}
				intSwitch = !intSwitch
			}
			else
			{
				if( (g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j] = create_slipentity(intOwner, j)) )
				{
					set_pev(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM + j], pev_origin, flOrigin[intSwitch])
				}
				trail_slipstream( intOwner, 2 * (j+1) )
				
				break
			}
		}
		pev(intOwner, pev_origin, flOrigin[0]);
		if(!update_slipentity(g_arrayPlayers[ intOwner ][PLAYER_ENT_STREAM], flOrigin[0]))
		{
			stop_slipstream(intOwner)
			return
		}
		set_pev(entity, pev_nextthink, get_gametime() + TIME_Think)
	}
}
		
// Stocks
stock update_slipentity(const entity, Float:flOrigin[3] = {0.0, 0.0, 0.0})
{
	if(pev_valid(entity))
	{
		new Float:flOriginold[3];
		pev(entity, pev_oldorigin, flOriginold);
		
		if(xs_vec_equal(flOrigin, flOriginold)
		|| flOriginold[0] == 0.0)
		{
			return 0;
		}
		set_pev(entity, pev_origin, flOriginold);
		set_pev(entity, pev_oldorigin, flOrigin);
	
		static Float:flSpeed;
		flSpeed = (vector_distance(flOrigin, flOriginold) / TIME_Think);
		
		if(flSpeed < 20.0)
			return 0
		
		static Float:flVelocity[3];
		get_speed_vector(flOriginold, flOrigin, flSpeed, flVelocity);
		
		set_pev(entity, pev_velocity, flVelocity);
		
		return 1;
	}
	
	return 0;
}
stock create_slipentity(const id, const slipid)
{
	new entity;
	
	static intStringname;
	if( intStringname || (intStringname = engfunc(EngFunc_AllocString, "info_target")) )
	{
		if( !pev_valid( (entity = engfunc(EngFunc_CreateNamedEntity, intStringname)) ) )
			return 0;
	}
	
	set_pev(entity, pev_classname, CLASS_Slip);
	set_pev(entity, pev_solid, SOLID_TRIGGER);
	set_pev(entity, pev_movetype, MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize, entity, Float:{-16.0, -16.0, -8.0}, Float:{16.0, 16.0, 8.0});
	
	set_pev(entity, pev_slipid, slipid);
	set_pev(entity, pev_owner, id);
	
	engfunc(EngFunc_SetModel, entity, "models/w_usp.mdl");
	set_rendering(entity, kRenderFxNone, .render=kRenderTransAlpha, .amount=0)
	
	return entity;
}
		
stock start_slipstream(const id, const stalker)
{
	if(g_arrayPlayers[id][PLAYER_SLIPSTREAM])
		return 0
		
	if( (g_arrayPlayers[ id ][PLAYER_ENT_STREAM] = create_slipentity(id, 0)) )
	{
		g_arrayPlayers[id][PLAYER_SLIPSTREAM] = 1
		g_arrayPlayers[ id ][PLAYER_STALKER] = stalker
		
		new Float:flOrigin[3]
		pev(id, pev_origin, flOrigin)
	
		//set_pev(g_arrayPlayers[ id ][PLAYER_ENT_STREAM], pev_origin, flOrigin)
		set_pev(g_arrayPlayers[ id ][PLAYER_ENT_STREAM], pev_oldorigin, flOrigin)
		set_pev(g_arrayPlayers[ id ][PLAYER_ENT_STREAM], pev_nextthink, get_gametime() + TIME_Think)
		
		trail_slipstream(id, 2)
	}
	return 1
}
stock stop_slipstream(const id)
{
	if(!g_arrayPlayers[id][PLAYER_SLIPSTREAM])
		return
	
	g_arrayPlayers[id][PLAYER_SLIPSTREAM] = 0;
	
	for(new i = 0; i < MAX_Entities; i++)
	{
		if( pev_valid( g_arrayPlayers[id][PLAYER_ENT_STREAM + i] ) )
		{
			engfunc(EngFunc_RemoveEntity, g_arrayPlayers[id][PLAYER_ENT_STREAM + i] );
		}
		g_arrayPlayers[id][PLAYER_ENT_STREAM + i]  = 0;
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)	// 99
	write_short(id)
	message_end()
}
	
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3]) 
{
	new_velocity[0] = origin2[0] - origin1[0];
	new_velocity[1] = origin2[1] - origin1[1];
	new_velocity[2] = origin2[2] - origin1[2];
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]));
	new_velocity[0] *= num;
	new_velocity[1] *= num;
	new_velocity[2] *= num;

	return 1;
}
stock trail_slipstream(id, size)
{
		// Trail
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)	// 22
	write_short(id)
	write_short(g_spriteTrail)
	write_byte(size) 				// Life
	write_byte(15)				// Size
	write_byte(128)				// Color:R
	write_byte(128)				// Color:G
	write_byte(128)				// Color:B
	write_byte(255)				// Brightness
	message_end()
}
stock screenfade_slipstream(id, Float:fadetime, color[3] = {255, 255, 255})
{
	static msgIdScreenfade;
	if(msgIdScreenfade || (msgIdScreenfade = get_user_msgid( "ScreenFade")))
	{
		message_begin(MSG_ONE, msgIdScreenfade, _, id)
		write_short(FixedUnsigned16(fadetime, (1<<12)))
		write_short(FixedUnsigned16(fadetime, (1<<12)))
		write_short(0)	// Flag
		write_byte(color[0]) // Color:r
		write_byte(color[1]) // Color:g
		write_byte(color[2]) // Color:b
		write_byte(50)	// Alpha
		message_end()
	}
}
FixedUnsigned16( Float:value, scale )
{
	return clamp(floatround(value * scale), 0, 0xFFFF);
}
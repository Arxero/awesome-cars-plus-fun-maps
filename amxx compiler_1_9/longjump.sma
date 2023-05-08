/*	Formatright © 2009, ConnorMcLeod

	LongJump Enabler is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with LongJump Enabler; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define VERSION "1.0.1"

#define FBitSet(%1,%2)		(%1 & %2)

new g_bSuperJump
#define MarkUserLongJump(%1)	g_bSuperJump |= 1<<(%1 & 31)
#define ClearUserLongJump(%1)	g_bSuperJump &= ~( 1<<(%1 & 31) )
#define HasUserLongJump(%1)	g_bSuperJump &  1<<(%1 & 31)

new g_pCvarMinVelocity, g_pCvarPunchAngle, g_pCvarLongjumpSpeed, g_pCvarZVelocity

public plugin_init()
{
	register_plugin("LongJump Enabler", VERSION, "ConnorMcLeod")

	g_pCvarLongjumpSpeed = register_cvar( "longjump_speed"       , "350" )
	g_pCvarPunchAngle    = register_cvar( "longjump_punchangle"  , "-5"  )
	g_pCvarZVelocity     = register_cvar( "longjump_zvelocity"   , "300" )
	g_pCvarMinVelocity   = register_cvar( "longjump_minvelocity" , "50"  )

	RegisterHam(Ham_Player_Jump, "player", "Player_Jump")
	RegisterHam(Ham_Player_Duck, "player", "Player_Duck")
}

public Player_Duck(id)
{
	if( HasUserLongJump(id) )
	{
		ClearUserLongJump(id)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public Player_Jump(id)
{
	if( !is_user_alive(id) )
	{
		return HAM_IGNORED
	}

	static iFlags ; iFlags = entity_get_int(id, EV_INT_flags)

	if( FBitSet(iFlags, FL_WATERJUMP) || entity_get_int(id, EV_INT_waterlevel) >= 2 )
	{
		return HAM_IGNORED
	}

	const XTRA_OFS_PLAYER = 5	
	const m_afButtonPressed = 246

	static afButtonPressed ; afButtonPressed = get_pdata_int(id, m_afButtonPressed, XTRA_OFS_PLAYER)

	if( !FBitSet(afButtonPressed, IN_JUMP) || !FBitSet(iFlags, FL_ONGROUND) )
	{
		return HAM_IGNORED
	}

	const m_fLongJump = 356

	if(	(entity_get_int(id, EV_INT_bInDuck) || iFlags & FL_DUCKING)
	&&	get_pdata_int(id, m_fLongJump, XTRA_OFS_PLAYER)
	&&	entity_get_int(id, EV_INT_button) & IN_DUCK
	&&	entity_get_int(id, EV_INT_flDuckTime)	)
	{
		static Float:fVecTemp[3]
		entity_get_vector(id, EV_VEC_velocity, fVecTemp)
		if( vector_length(fVecTemp) > get_pcvar_float(g_pCvarMinVelocity) )
		{
			const m_Activity = 73
			const m_IdealActivity = 74

			const PLAYER_SUPERJUMP = 7
			const ACT_LEAP = 8

			entity_get_vector(id, EV_VEC_punchangle, fVecTemp)
			fVecTemp[0] = get_pcvar_float(g_pCvarPunchAngle)
			entity_set_vector(id, EV_VEC_punchangle, fVecTemp)

			get_global_vector(GL_v_forward, fVecTemp)
			static Float:flLongJumpSpeed ; flLongJumpSpeed = get_pcvar_float(g_pCvarLongjumpSpeed) * 1.6
			fVecTemp[0] *= flLongJumpSpeed
			fVecTemp[1] *= flLongJumpSpeed
			fVecTemp[2] = get_pcvar_float(g_pCvarZVelocity)

			entity_set_vector(id, EV_VEC_velocity, fVecTemp)

			set_pdata_int(id, m_Activity, ACT_LEAP, XTRA_OFS_PLAYER)
			set_pdata_int(id, m_IdealActivity, ACT_LEAP, XTRA_OFS_PLAYER)
			MarkUserLongJump(id)

			entity_set_int(id, EV_INT_oldbuttons, entity_get_int(id, EV_INT_oldbuttons) | IN_JUMP)

			entity_set_int(id, EV_INT_gaitsequence, PLAYER_SUPERJUMP)
			entity_set_float(id, EV_FL_frame, 0.0)

			set_pdata_int(id, m_afButtonPressed, afButtonPressed & ~IN_JUMP, XTRA_OFS_PLAYER)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}
#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>

#define PLUGIN			"Fire Knife"
#define AUTHOR			"trofian"
#define VERSION			"1.1"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1)	(1<=%1<=g_maxplayers)

#define BURN_TASK		36528
#define VIP_FLAG		ADMIN_LEVEL_H

#define CLASSNAME		"weapon__next21_fire"
#define HP			120
#define GRAVITY			1.0
#define SPEED			275.0

#define FLAME_DMG 		2
#define FLAME_MUL_CRIT		2
#define USER_MIN_HP		3
#define MAX_BURN	 	10
#define SPHERE_RADIUS		300.0

#define FireSound		"next21_knife_v2/secondary/knife_fire_next21.wav"

#define KnifeVModel		"models/next21_knife_v2/knifes/fire/v_fire_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/fire/p_fire_knife.mdl"
#define BurnModel		"models/player/n21_burn_death/n21_burn_death.mdl"

new const
grenade_fire_player[][] = {
	"next21_knife_v2/scream_fire/scream_01.wav",
	"next21_knife_v2/scream_fire/scream_02.wav",
	"next21_knife_v2/scream_fire/scream_03.wav"
}

new
KnifeId = -1, bool:g_inFire[33], Float:g_fAngles[33][3], g_wasBurned[33], g_maxplayers,
g_fireSpr, g_flameSpr, g_smokeSpr, g_flameCritSpr, g_shadSpr, g_msgDamage, g_attacker[33], g_burn_death[33],
Float:BrutalChance[33], g_syncHudMessage // 1 канал

public plugin_natives()
{
	register_native("ka_stop_fire", "_ka_stop_fire", 0) // 1 - ид
	register_native("ka_is_burning", "_ka_is_burning", 0)
}

public plugin_precache()
{
	precache_sound(FireSound)
	precache_model(KnifeVModel)
	precache_model(KnifePModel)
	precache_model(BurnModel)
	
	precache_generic("sprites/weapon__next21_fire.txt")
	
	for(new i; i<sizeof(grenade_fire_player); i++)
		precache_sound(grenade_fire_player[i])
	
	g_fireSpr = engfunc(EngFunc_PrecacheModel, "sprites/next21_knife_v2/fire_knife.spr")
	
	g_flameSpr = engfunc(EngFunc_PrecacheModel, "sprites/next21_knife_v2/flame.spr")
	g_flameCritSpr = engfunc(EngFunc_PrecacheModel, "sprites/next21_knife_v2/blue_flame.spr")
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, "sprites/black_smoke3.spr")
	g_shadSpr = engfunc(EngFunc_PrecacheModel, "sprites/shadow_circle.spr")
	
	set_task(1.0, "show_crit_info", _, _, _, "b")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rFire Knife\y] - Ignition", "!g[Fire knife] Properties: !yHP++  Speed+ !gAbilities: !yIgnites enemies", "ability", 17.0,  HP, GRAVITY, SPEED, CLASSNAME)
	
	if(KnifeId < 0) set_fail_state("[Fire Knife] Error registration")
	
	RegisterHam(Ham_Touch, "player", "fw_TouchPlayer")
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	RegisterHam(Ham_Spawn, "player", "hook_spawn_post", 1)
	RegisterHam(Ham_Killed,"player","Give_Chance")
	register_event("HLTV", "NewRound", "a", "1=0", "2=0")
	register_forward(FM_PlayerPreThink, "PreThink")
	g_msgDamage = get_user_msgid("Damage")
	g_maxplayers = get_maxplayers()
	g_syncHudMessage = CreateHudSyncObj()
}

public hook_spawn_post(id)
{
	if(is_user_alive(id))
		g_wasBurned[id] = 0
	set_task(0.8, "NewRound_d")
}

public NewRound() set_task(0.8, "NewRound_d")
public NewRound_d()
{
	for(new i=1; i<=g_maxplayers; i++)
	{
		if(g_burn_death[i])
		{
			g_burn_death[i] = 0
			if(is_user_alive(i))
				cs_reset_user_model(i)
		}
	}
}
		
public CurWeapon(weapon)
{
	new id = get_gun_owner(weapon)
	
	if(kc_get_user_knife(id) == KnifeId)
	{
		set_pev(id, pev_viewmodel2, KnifeVModel)
		set_pev(id, pev_weaponmodel2, KnifePModel)
	}
}

public ability(id)
{	
	g_inFire[id] = true
	set_task(0.4, "off_fire", id)
	
	ka_unfreez(id)
	ka_unchill(id)
	ka_gren_unfreez(id)
	ka_gren_unchill(id)
	
	pev(id, pev_v_angle, g_fAngles[id])
	angle_vector(g_fAngles[id], ANGLEVECTOR_FORWARD, g_fAngles[id])
	xs_vec_mul_scalar(g_fAngles[id], 2000.0, g_fAngles[id])
	g_fAngles[id][2] = 10.0
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, FireSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

public off_fire(id)
{
	g_inFire[id] = false
	
	if(!is_user_alive(id))
		return
	
	xs_vec_div_scalar(g_fAngles[id], 2000.0, g_fAngles[id])
	g_fAngles[id][2] = 10.0
	
	set_pev(id, pev_velocity, g_fAngles[id])
}

public fw_TouchPlayer(id, ent)
{
	if(!is_entity_player(ent))
		return HAM_IGNORED

	if(g_wasBurned[id] == 0 || g_wasBurned[ent] != 0)
		return HAM_IGNORED
 
 	if(get_user_team(ent) == get_user_team(id))
	{
		ka_unfreez(ent)
		ka_unchill(ent)
		ka_gren_unfreez(ent)
		ka_gren_unchill(ent)
		return HAM_IGNORED
	}
	
	if(g_wasBurned[ent] != 0)
		return HAM_IGNORED
	
	ka_unfreez(ent)
	ka_unchill(ent)
	ka_gren_unfreez(ent)
	ka_gren_unchill(ent)
	
	burn_task(BURN_TASK+ent)
	g_attacker[ent] = g_attacker[id]
 
	return HAM_IGNORED
}

public PreThink(id)
{
	if(!is_user_alive(id))
		return
	
	if(!g_inFire[id])
		return
	
	static Float:fOrigin[3], Float:fOrigin2[3]
	pev(id, pev_origin, fOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
	write_byte(TE_SPRITE) // TE id
	engfunc(EngFunc_WriteCoord, fOrigin[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, fOrigin[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, fOrigin[2]+random_float(-10.0, 10.0)) // z
	write_short(g_fireSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	fOrigin2[0] = fOrigin[0]
	fOrigin2[1] = fOrigin[1]
	fOrigin2[2] = 700.0
	
	Create_TE_BEAMCYLINDER(fOrigin, fOrigin, fOrigin2, g_shadSpr, 0, 0, 1, 8, 0, 255, 0, 0, 255, 0)
	
	new ent = -1
	while((ent = fm_find_ent_in_sphere(ent, fOrigin, SPHERE_RADIUS)))
	{
		if(1 <= ent <= g_maxplayers)
		{
			if(ent == id)
				continue
			
			if(get_user_team(ent) == get_user_team(id))
			{
				ka_unfreez(ent)
				ka_unchill(ent)
				ka_gren_unfreez(ent)
				ka_gren_unchill(ent)
				continue
			}
			
			if(g_wasBurned[ent] != 0)
				continue
			
			ka_unfreez(ent)
			ka_unchill(ent)
			ka_gren_unfreez(ent)
			ka_gren_unchill(ent)
			burn_task(BURN_TASK+ent)
			g_attacker[ent] = id
		}
	}
	
	set_pev(id, pev_velocity, g_fAngles[id])
}

public burn_task(TASK_PID)
{
	new id = TASK_PID - BURN_TASK
	
	if(!is_user_alive(id))
		return
	
	new Float:originF[3]
	pev(id, pev_origin, originF)
	
	if(pev(id, pev_flags) & FL_INWATER)
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		g_wasBurned[id] = 0
		
		return
	}
	
	static user_hp
	user_hp = pev(id, pev_health)
	
	static rand_crit
	rand_crit = random_num(1, floatround(BrutalChance[id]))
	
	if(user_hp > USER_MIN_HP)
	{
		if(rand_crit == 1)
		{
			if(user_hp - FLAME_DMG+FLAME_MUL_CRIT <= 0)
			{
				fm_set_user_health(id, USER_MIN_HP)
				user_hp = USER_MIN_HP
			}
			else
				fm_set_user_health(id, user_hp - FLAME_DMG*FLAME_MUL_CRIT)
		}
		else
		{
			if(user_hp - FLAME_DMG <= 0)
			{
				fm_set_user_health(id, USER_MIN_HP)
				user_hp = USER_MIN_HP
			}
			else
				fm_set_user_health(id, user_hp - FLAME_DMG)
		}
	}
	
	if(user_hp <= USER_MIN_HP)
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		cs_set_user_model(id, "n21_burn_death")
		
		fm_set_user_health(id, USER_MIN_HP)
		set_task(0.2, "kill_fire", id)
		
		return
	}

	if(!ka_in_ninja(id))
	{
		if(g_wasBurned[id] % 5 == 0)
			engfunc(EngFunc_EmitSound, id, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		
	}
	
	g_wasBurned[id]++
	
	if(g_wasBurned[id] >= MAX_BURN)
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		set_task(0.4, "check_model", id)
		
		g_wasBurned[id] = 0
		return
	}
	
	if(!ka_in_ninja(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SPRITE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
		engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
		engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
		if(rand_crit == 1)
		{
			write_short(g_flameCritSpr)
			write_byte(30)
		}
		else
		{
			write_short(g_flameSpr) // sprite
			write_byte(random_num(5, 10)) // scale
		}
		write_byte(200) // brightness
		message_end()
	
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
	}
	
	// Keep sending flame messages
	set_task(0.2, "burn_task", TASK_PID)
}

public kill_fire(id)
{
	if(!is_user_alive(id))
		return
	
	if(!is_entity_player(g_attacker[id]))
		g_attacker[id] = id
	
	ExecuteHamB(Ham_Killed, id, g_attacker[id], 0)

	g_burn_death[id] = 1
	g_attacker[id] = 0
}

public check_model(id)
{
	if(!is_user_alive(id))
		return
	
	new model[64]
	cs_get_user_model(id, model, charsmax(model))
	
	if(equal(model, "n21_burn_death"))
		cs_reset_user_model(id)
}

public client_disconnect(id)
{
	g_inFire[id] = false
	g_wasBurned[id] = 0
	g_attacker[id] = 0
}

public client_connect(id)
{
	BrutalChance[id] = 48.0
	g_inFire[id] = false
	g_wasBurned[id] = 0
	g_attacker[id] = 0
}

public Give_Chance(victim, attacker)
{
	if(!is_entity_player(attacker))
		return HAM_IGNORED
	
	if(kc_get_user_knife(attacker) != KnifeId)
		return HAM_IGNORED
	
	if(attacker == victim)
		return HAM_IGNORED
	
	if(BrutalChance[attacker] <= 10.0)
		BrutalChance[attacker] = 30.0
	
	if(get_user_flags(attacker) & VIP_FLAG)
		BrutalChance[attacker] -= 4.0
	else
		BrutalChance[attacker] -= 2.0
	
	return HAM_IGNORED
}

Create_TE_BEAMCYLINDER(Float:origin[3], Float:center[3], Float:axis[3], iSprite, startFrame, frameRate, life, width, amplitude, red, green, blue, brightness, speed)
{
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte( TE_BEAMCYLINDER )
	engfunc(EngFunc_WriteCoord, center[0])
	engfunc(EngFunc_WriteCoord, center[1])
	engfunc(EngFunc_WriteCoord, center[2])
	engfunc(EngFunc_WriteCoord, axis[0])
	engfunc(EngFunc_WriteCoord, axis[1])
	engfunc(EngFunc_WriteCoord, axis[2])
	write_short( iSprite )				// sprite index
	write_byte( startFrame )			// starting frame
	write_byte( frameRate )				// frame rate in 0.1's
	write_byte( life )					// life in 0.1's
	write_byte( width )					// line width in 0.1's
	write_byte( amplitude )				// noise amplitude in 0.01's
	write_byte( red )					// color (red)
	write_byte( green )					// color (green)
	write_byte( blue )					// color (blue)
	write_byte( brightness )			// brightness
	write_byte( speed )					// scroll speed in 0.1's
	message_end()
}

public _ka_stop_fire(plugin, num_params)
{
	new id = get_param(1)
	
	if(task_exists(BURN_TASK+id))
	{
		remove_task(BURN_TASK+id)
		
		new Float:originF[3]
		pev(id, pev_origin, originF)
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		g_wasBurned[id] = 0
	}
}

public bool:_ka_is_burning(plugin, num_params)
{
	new id = get_param(1)
	if(g_inFire[id])
		return true
	return false
}

public show_crit_info()
{	
	static i, Float:old_chance[33]
	
	for(i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue
		
		if(is_user_alive(i) && kc_is_user_has_knife(i, KnifeId))
		{
			if(old_chance[i] == BrutalChance[i])
				set_hudmessage(255, 255, 225, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
			else
				set_hudmessage(255, 0, 0, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
			old_chance[i] = BrutalChance[i]
			ShowSyncHudMsg(i, g_syncHudMessage, "Chance for mini critical %.0f%%%s", 1.0/BrutalChance[i]*100.0, get_user_flags(i) & VIP_FLAG ? " (VIP chance)" : "")
		}
		else
		{
			static v
			v = pev(i, pev_iuser2)
			
			if(is_entity_player(v) && kc_is_user_has_knife(v, KnifeId))
			{
				if(old_chance[v] == BrutalChance[v])
					set_hudmessage(255, 255, 225, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				else
					set_hudmessage(255, 0, 0, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
				old_chance[i] = BrutalChance[v]
				ShowSyncHudMsg(i, g_syncHudMessage, "Chance for mini critical %.0f%%%s", 1.0/BrutalChance[v]*100.0, get_user_flags(v) & VIP_FLAG ? " (VIP chance)" : "")
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

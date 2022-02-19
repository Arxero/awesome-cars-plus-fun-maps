#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>

#define PLUGIN			"Nuclear"
#define AUTHOR			"trofian and Psycrow"
#define VERSION			"1.1"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1) 	(1<=%1<=g_maxplayers)
#define TASKID 133742

#define CLASSNAME		"weapon__next21_nuclear"
#define HP			140
#define GRAVITY			1.0
#define SPEED			155.0

#define KnifeVModel		"models/next21_knife_v2/knifes/nuclear/v_nuclear_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/nuclear/p_nuclear_knife.mdl"

new
KnifeId = -1, Damage_rt[33],	//Переменная отношения убийств и парирования (с цветом)
g_maxplayers, g_syncHudMessage, // 2 канал
bool:g_InPair[33], Trie:tSoundKnife

public plugin_precache()
{
	tSoundKnife = TrieCreate()
	new Trie:tPrecached = TrieCreate()
	
	new const szOldSounds[ ][ ] = {
		"weapons/knife_hit1.wav", 
		"weapons/knife_hit2.wav", 
		"weapons/knife_hit3.wav", 
		"weapons/knife_hit4.wav", 
		"weapons/knife_stab.wav", 
		"weapons/knife_hitwall1.wav", 
		"weapons/knife_slash1.wav", 
		"weapons/knife_slash2.wav", 
		"weapons/knife_deploy1.wav" 
	}
	
	new const szNewSounds[][] = {
		"next21_knife_v2/weapons/nuclear_hammer/knife_hit1.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_hit2.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_hit1.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_hit2.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_stab.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_hitwall1.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_slash1.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_slash1.wav",
		"next21_knife_v2/weapons/nuclear_hammer/knife_deploy1.wav"
	}
	
	for(new i; i < sizeof szOldSounds; i++)
	{
		if(!TrieKeyExists(tPrecached, szNewSounds[i]))
		{
			TrieSetCell(tPrecached, szNewSounds[i], 1)
			precache_sound(szNewSounds[i])
        }
		
		TrieSetString(tSoundKnife, szOldSounds[i], szNewSounds[i])
	}
	
	precache_model(KnifeVModel)
	precache_model(KnifePModel)
	
	precache_generic("sprites/weapon__next21_nuclear.txt")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rNuclear Knife\y] - Nuclear bomb", "!g[Nuclear knife] Properties: !yPushes enemies Speed--- HP++ !gAbilities: !yMirrors damage", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME)
	
	if(KnifeId < 0) set_fail_state("[Nuclear Knife] Error registration")
	
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	register_forward(FM_EmitSound, "EmitSound")
	RegisterHam(Ham_TakeDamage, "player", "Ham_Damage")
	RegisterHam(Ham_Killed,"player","Give_More_Damage")
	RegisterHam(Ham_Spawn,"player","hook_sapwn")
	RegisterHam(Ham_TraceAttack, "player", "hook_TraceAttack")
	g_syncHudMessage = CreateHudSyncObj()
	g_maxplayers = get_maxplayers()
}

public client_connect(id)
    Damage_rt[id] = 33
    
public Give_More_Damage(victim, attacker)
{
	if(!is_entity_player(attacker))
		return
	
	if(kc_get_user_knife(attacker) != KnifeId)
		return
	
	if(Damage_rt[attacker] == 18)
		Damage_rt[attacker] = 38
	
	Damage_rt[attacker] -= 5
}
    
public hook_sapwn(id)
{
	if(!is_user_alive(id))
		return
	
	remove_task(TASKID+id)
	g_InPair[id] = false
}

public EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_entity_player(id))
		return FMRES_IGNORED
	
	if(kc_get_user_knife(id) != KnifeId)
		return FMRES_IGNORED
	
	static szNewSound[256]
	
	if(TrieGetString(tSoundKnife, sample, szNewSound, charsmax(szNewSound)))
	{ 
		emit_sound(id, channel, szNewSound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
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

public ability(id, victim)
{
	new color_handle
	if(Damage_rt[id] == 23)
		color_handle = ka_render_add(id, kRenderFxGlowShell, 255, 36, 0, kRenderNormal, 15)
	else
		color_handle = ka_render_add(id, kRenderFxGlowShell, 255, 130, 0, kRenderNormal, 15)
	
	new params[2]
	params[0] = id
	params[1] = color_handle
	set_task(10.0, "unset_glow", _, params, charsmax(params))
	
	if(!ka_is_flashed(id))
		set_flsh(id, 8, 37, 103, 130)
	
	g_InPair[id] = true
	
	new args[2]
	args[0] = id
	args[1] = 10
	readout_hud(args)
	
	if(Damage_rt[id] == 33)
	client_print(id, print_center, "Blocked 30% of the hits")
	
	if(Damage_rt[id] == 28)
	client_print(id, print_center, "Blocked 35% of the hits")
	
	if(Damage_rt[id] == 23)
	client_print(id, print_center, "Blocked 45% of the hits")
	
	return PLUGIN_CONTINUE
}

public unset_glow(params[])
{
	new
	id = params[0],
	color_handle = params[1]
	
	if(is_user_alive(id))
		ka_render_sub(id, color_handle)
}

public hook_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	if(!is_entity_player(attacker))
		return HAM_IGNORED
	
	if(get_user_team(victim) == get_user_team(attacker))
		return HAM_IGNORED
	
	if(!kc_is_user_has_knife(attacker, KnifeId))
		return HAM_IGNORED
	
	if(~pev(victim, pev_flags) & FL_ONGROUND)
		return HAM_IGNORED
	
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > 100) // дистанция для отброса
		return HAM_IGNORED
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	xs_vec_mul_scalar(direction, damage, direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, 0.5, direction) // если присел
	
	xs_vec_mul_scalar(direction, random_float(7.0, 11.0), direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	direction[2] = 400.0
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	
	ka_set_attacker(victim, attacker, 3.0)
	
	return HAM_IGNORED
}

public Ham_Damage(victim, inflictor, attacker, Float:damage, bits)
{
	if(is_user_alive(victim) && is_user_alive(attacker))
	{
		if(get_user_team(victim) == get_user_team(attacker))
			return HAM_IGNORED
		
		if(g_InPair[victim] == true)
		{

			if(!ka_is_flashed(attacker))
				set_flsh(attacker, 255, 0, 0, 35)
			
			if(!ka_is_flashed(victim))
				set_flsh(victim, 0, 255, 0, 35)
			
			
			if(damage/Damage_rt[victim]*10 > 60)
			{
				client_print(victim, print_center, "Blocked damage: 60")
				ExecuteHam(Ham_TakeDamage, attacker, inflictor, victim, 60.0, DMG_ALWAYSGIB | DMG_BULLET)
			}
			
			{
				client_print(victim, print_center, "Blocked damage: %d", floatround(damage/Damage_rt[victim]*10))
				ExecuteHam(Ham_TakeDamage, attacker, inflictor, victim, damage/Damage_rt[victim]*10, DMG_ALWAYSGIB | DMG_BULLET)
			}
			
			return HAM_IGNORED
		}
	}
	return HAM_IGNORED
}

public readout_hud(put_args[])
{
	new id = put_args[0]
	new second = put_args[1]
	
	if(second == 0)
	{
		g_InPair[id] = false
		return PLUGIN_HANDLED
	}
	
	if(kc_get_user_knife(id) != KnifeId)
	{
		if(is_user_alive(id))
			fm_set_user_rendering(id)
		
		g_InPair[id] = false
		
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(id))
	{	
		g_InPair[id] = false
		return PLUGIN_HANDLED
	}
	
	set_hudmessage(255, 255, 255, -1.0, -0.2, 0, 1.1, 1.0, 0.1, 0.0, 2)
	ShowSyncHudMsg(id, g_syncHudMessage, "You have just started mirroring your enemy's hits!^n(renaiming %d sec.)", second)
	second--
	
	new args[2]
	args[0] = id
	args[1] = second
	set_task(1.0, "readout_hud", TASKID+id, args, 2)
	
	return PLUGIN_CONTINUE
}

public set_flsh(id, r, g, b, i)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id)
	write_short(1<<12)
	write_short(1<<8)
	write_short(1<<4)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(i)
	message_end()
}

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>
#include <xs>

#define PLUGIN			"Blink Knife"
#define AUTHOR			"trofian"
#define VERSION			"1.2"

#define is_entity_player(%1)	(1<=%1<=g_maxplayers)
#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define VIP_FLAG		ADMIN_LEVEL_H

#define CLASSNAME		"weapon__next21_blink"
#define ABILMINDIST		75.0
#define ABILMAXDIST		1000.0
#define HP			100
#define GRAVITY			1.0
#define SPEED			250.0
#define MAXDOUBLEJUMPS	1	// количество прыжков -1

#define TeleportSound		"next21_knife_v2/secondary/knife_blink_next21.wav"
#define KnifeVModel		"models/next21_knife_v2/knifes/blink/v_blink_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/blink/p_blink_knife.mdl"

new
KnifeId, Float:BrutalChance[33], g_syncHudMessage, // 1 канал
jumpnum[33], bool:dojump[33], g_maxplayers, Trie:tSoundKnife

new const g_CritSounds[][] = {
	"next21_knife_v2/crit/mkbloodthirsty.wav",
	"next21_knife_v2/crit/mkqclastplace.wav",
	"next21_knife_v2/crit/mksklaugh.wav"
	}

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
		"weapons/knife_hit1.wav",
		"weapons/knife_hit2.wav",
		"weapons/knife_hit3.wav",
		"weapons/knife_hit4.wav",
		"weapons/knife_stab.wav",
		"next21_knife_v2/weapons/blink_knife/knife_hitwall1.wav",
		"weapons/knife_slash1.wav",
		"weapons/knife_slash2.wav",
		"next21_knife_v2/weapons/blink_knife/knife_deploy1.wav"
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
	
	precache_sound(TeleportSound)
	precache_model(KnifeVModel)
	precache_model(KnifePModel)
	
	for(new i; i<sizeof(g_CritSounds); i++)
		precache_sound(g_CritSounds[i])
	
	precache_generic("sprites/weapon__next21_blink_cnot.txt")
	precache_generic("sprites/weapon__next21_blink_def.txt")
	precache_generic("sprites/weapon__next21_blink_ok.txt")
	precache_generic("sprites/weapon__next21_blink_far.txt")
	precache_generic("sprites/weapon__next21_blink_time.txt")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	KnifeId = kc_register_knife("\y[\rBlink Knife\y] - Sprint teleport", "!g[Blink Knife] Properties: !yDouble jump !gAbilities: !yteleports next to enemy", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME, ABILMINDIST, ABILMAXDIST)
	
	if(KnifeId < 0) set_fail_state("[Blink Knife] Error registration")
	
	RegisterHam(Ham_Killed,"player","Give_Chance")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "CurWeapon", 1)
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PreThink_player")
	g_syncHudMessage = CreateHudSyncObj()
	register_forward(FM_PlayerPreThink, "PreThink")
	register_forward(FM_PlayerPostThink, "PostThink")
	register_forward(FM_EmitSound, "EmitSound")
	
	g_maxplayers = get_maxplayers()
	
	set_task(1.0, "show_crit_info", _, _, _, "b")
}

public client_putinserver(id)
	BrutalChance[id] = 36.0

public Give_Chance(victim, attacker)
{
	if(!is_entity_player(attacker))
		return HAM_IGNORED
	
	if(kc_get_user_knife(attacker) != KnifeId)
		return HAM_IGNORED
	
	if(attacker == victim)
		return HAM_IGNORED
	
	if(BrutalChance[attacker] <= 2.0)
		BrutalChance[attacker] = 22.0
	
	if(get_user_flags(attacker) & VIP_FLAG)
		BrutalChance[attacker] -= 3.5
	else
		BrutalChance[attacker] -= 2.0
	
	return HAM_IGNORED
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
	ka_unfreez(id)
	ka_gren_unfreez(id)
	
	new Float:fAngles[3]
	pev(victim, pev_angles, fAngles)
	
	new Float:fOrigin[3]
	pev(victim, pev_origin, fOrigin)
	
	new Float:fPlayerOrigin[3]						// Позиция
	new iPlayerOrigin[3]							// игрока
	pev(id, pev_origin, fPlayerOrigin)				// до
	FVecIVec(Float:fPlayerOrigin, iPlayerOrigin)	// телепортации
	
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fAngles)
	
	new Float:fSetAngles[3]
	vector_to_angle(fAngles, fSetAngles)
	
	xs_vec_neg(fAngles, fAngles)
	
	new Float:fDistance[3]
	xs_vec_mul_scalar(fAngles, 75.0, fDistance)
	
	xs_vec_add(fOrigin, fDistance, fDistance)
	
	fDistance[2] += 17.0

	if(is_hull_vacant(fDistance, pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id))
	{
		new rand_crit = random_num(1, floatround(BrutalChance[id]))
		
		set_pev(id, pev_angles, fSetAngles)
		set_pev(id, pev_fixangle, 1)
		
		if(rand_crit == 1)
			set_pev(id, pev_origin, fOrigin)
		else
			set_pev(id, pev_origin, fDistance)
		
		engfunc(EngFunc_EmitSound, id, CHAN_STATIC, TeleportSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		new iDistance[3]
		FVecIVec(Float:fDistance, iDistance)
		
		Create_TE_TELEPORT(iPlayerOrigin)
		
		if(rand_crit == 1)
		{
			engfunc(EngFunc_EmitSound, id, CHAN_AUTO, g_CritSounds[random_num(0, sizeof(g_CritSounds)-1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			ExecuteHamB(Ham_TakeDamage, victim, CSW_KNIFE, id, 500.0, DMG_ALWAYSGIB | DMG_BULLET)
			
			new Origin[3]
			FVecIVec(fOrigin, Origin)
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_LAVASPLASH)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		else
			Create_TE_IMPLOSION(iDistance, 100, 45, 3)
		
		fm_set_user_maxspeed(id, 400.0)
		set_task(0.9, "drop_speed", id)
	}
	else
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

public Ham_PreThink_player(id) // hard work
{
	if(kc_get_crosshair(id) == CrossOff || kc_get_user_knife(id) != KnifeId)
		return
	
	static v, is_spec
	is_spec = 0
	
	if(!is_user_alive(id))
	{
		static v
		v = pev(id, pev_iuser2)
		
		if(is_entity_player(v))
			is_spec = 1
		else
			return
	}
	
	static victim, body
	get_user_aiming(id, victim, body)
	
	if(!is_entity_player(victim))
		return
	
	static Float:fAngles[3]
	pev(victim, pev_angles, fAngles)
	
	static Float:fOrigin[3]
	pev(victim, pev_origin, fOrigin)
	
	static Float:fPlayerOrigin[3]
	pev(is_spec ? v : id, pev_origin, fPlayerOrigin)
	
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fAngles)
	
	static Float:fSetAngles[3]
	vector_to_angle(fAngles, fSetAngles)
	
	xs_vec_neg(fAngles, fAngles)
	
	static Float:fDistance[3]
	xs_vec_mul_scalar(fAngles, 75.0, fDistance)
	
	xs_vec_add(fOrigin, fDistance, fDistance)
	
	fDistance[2] += 17.0
	if(!is_hull_vacant(fDistance, pev(is_spec ? v : id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, is_spec ? v : id))
		kc_set_crosshair(id, 1, CrossCannot)
}

public drop_speed(id)
{
	if(is_user_alive(id))
		kc_reset_speed(id)
}

public PreThink(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_CONTINUE
	
	new nbut = pev(id, pev_button)
	new obut = pev(id, pev_oldbuttons)
	if((nbut & IN_JUMP) && !(pev(id, pev_flags) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(jumpnum[id] < MAXDOUBLEJUMPS)
		{
			dojump[id] = true
			jumpnum[id]++
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (pev(id, pev_flags) & FL_ONGROUND))
	{
		jumpnum[id] = 0
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public PostThink(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_CONTINUE
	
	if(dojump[id] == true)
	{
		new Float:velocity[3]	
		pev(id, pev_velocity, velocity)
		velocity[2] = random_float(215.0,225.0)
		set_pev(id, pev_velocity, velocity)
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

bool:is_hull_vacant(const Float:origin[3], hull,id)
{
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
		return true
	return false
}

Create_TE_TELEPORT(position[3])
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( TE_TELEPORT ) 
	write_coord( position[0] ) 
	write_coord( position[1] ) 
	write_coord( position[2] ) 
	message_end()
}

Create_TE_IMPLOSION(position[3], radius, count, life)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte ( TE_IMPLOSION )
	write_coord( position[0] )			// position (X)
	write_coord( position[1] )			// position (Y)
	write_coord( position[2] )			// position (Z)
	write_byte ( radius )				// radius
	write_byte ( count )				// count
	write_byte ( life )					// life in 0.1's
	message_end()
}

fm_set_user_maxspeed(index, Float:speed = -1.0)
{
	engfunc(EngFunc_SetClientMaxspeed, index, speed)
	set_pev(index, pev_maxspeed, speed)

	return 1
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
				set_hudmessage(0, 151, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
			old_chance[i] = BrutalChance[i]
			ShowSyncHudMsg(i, g_syncHudMessage, "Chance for critical %.0f%%%s", 1.0/BrutalChance[i]*100.0, get_user_flags(i) & VIP_FLAG ? " (VIP chance)" : "")
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
					set_hudmessage(0, 151, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
				old_chance[i] = BrutalChance[v]
				ShowSyncHudMsg(i, g_syncHudMessage, "Chance for critical %.0f%%%s", 1.0/BrutalChance[v]*100.0, get_user_flags(v) & VIP_FLAG ? " (VIP chance)" : "")
			}
		}
	}
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

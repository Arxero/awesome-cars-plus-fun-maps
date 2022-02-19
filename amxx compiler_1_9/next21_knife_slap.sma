#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>

#define PLUGIN			"Slap Axe"
#define AUTHOR			"trofian"
#define VERSION			"1.3"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1) 	(0 < (%1) <= g_maxplayers)
#define VIP_FLAG		ADMIN_LEVEL_H

#define CLASSNAME		"weapon__next21_slap"
#define HP			90
#define GRAVITY			1.0
#define SPEED			220.0
#define VELOCITY_BACK		2000.0

#define g_szCustomKnifeVModelSlap		"models/next21_knife_v2/knifes/slap/v_slap_axe.mdl"
#define g_szCustomKnifePModelSlap		"models/next21_knife_v2/knifes/slap/p_slap_axe.mdl"
#define g_szSoundSlap				"next21_knife_v2/secondary/knife_slap_next21.wav"

new const
g_CritSounds[][] = {
	"next21_knife_v2/crit/mkbloodthirsty.wav",
	"next21_knife_v2/crit/mkqclastplace.wav",
	"next21_knife_v2/crit/mksklaugh.wav"
	}
	
new 
g_maxplayers, KnifeId = -1, g_sprite_, Trie:tSoundKnife,
Float:BrutalChance[33], g_syncHudMessage // 1 канал

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
		"next21_knife_v2/weapons/slap_axe/knife_hit1.wav",
		"next21_knife_v2/weapons/slap_axe/knife_hit2.wav",
		"next21_knife_v2/weapons/slap_axe/knife_hit1.wav",
		"next21_knife_v2/weapons/slap_axe/knife_hit2.wav",
		"next21_knife_v2/weapons/slap_axe/knife_hitwall1.wav",
		"next21_knife_v2/weapons/slap_axe/knife_hitwall1.wav",
		"weapons/knife_slash1.wav",
		"weapons/knife_slash2.wav",
		"weapons/knife_deploy1.wav"
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
	
	precache_sound(g_szSoundSlap)
	
	precache_model(g_szCustomKnifeVModelSlap)
	precache_model(g_szCustomKnifePModelSlap)
	
	for(new i; i<sizeof(g_CritSounds); i++)
		precache_sound(g_CritSounds[i])
	
	g_sprite_ = precache_model("sprites/shadow_circle.spr")
	
	precache_generic("sprites/weapon__next21_slap.txt")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rSlap Axe\y] - Hits hardly", "!g[Slap Axe] Abilities: !yAttack++  Speed-  HP- !gAbilities: !yKills with finesse", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME)

	if(KnifeId < 0) set_fail_state("[Slap Knife] Error registration")
	
	register_forward(FM_EmitSound, "EmitSound")
	RegisterHam(Ham_TakeDamage, "player", "Ham_Damage")
	RegisterHam(Ham_Killed,"player","Give_Chance", 1)
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	g_maxplayers = get_maxplayers()
	g_syncHudMessage = CreateHudSyncObj()
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
		set_pev(id, pev_viewmodel2, g_szCustomKnifeVModelSlap)
		set_pev(id, pev_weaponmodel2, g_szCustomKnifePModelSlap)
	}
}

public Ham_Damage(victim, inflictor, attacker, Float:damage, bits)
{
	static iAgressor

	if(is_entity_player(iAgressor = inflictor) || is_entity_player(iAgressor = attacker))
	{
		if(kc_is_user_has_knife(iAgressor, KnifeId))
		{
			SetHamParamFloat(4, damage + random_float(10.0, 25.0))
			return HAM_OVERRIDE
		}
	}
	return HAM_IGNORED
}



public ability(id)
{	
	new ent = -1, Float:fOrigin[3], Float:fOrigin2[3], rand_crit
	
	pev(id, pev_origin, fOrigin)
	
	fOrigin2[0] = fOrigin[0]
	fOrigin2[1] = fOrigin[1]
	fOrigin2[2] = fOrigin[2] + 220.0
	
	rand_crit = random_num(1, floatround(BrutalChance[id]))
	
	if(rand_crit == 1)
	{
		Create_TE_BEAMCYLINDER(fOrigin, fOrigin, fOrigin2, g_sprite_, 0, 0, 4, 49, 0, 255, 0, 0, 255, 0)
		
		fOrigin2[2] = fOrigin[2] + 20.0
		Create_TE_BEAMCYLINDER(fOrigin, fOrigin, fOrigin2, g_sprite_, 0, 0, 4, 49, 0, 255, 0, 0, 255, 0)
		
		fOrigin2[2] = fOrigin[2] + 20.0
		Create_TE_BEAMCYLINDER(fOrigin, fOrigin, fOrigin2, g_sprite_, 0, 0, 4, 49, 0, 255, 0, 0, 255, 0)
		
		engfunc(EngFunc_EmitSound, id, CHAN_AUTO, g_CritSounds[random_num(0, sizeof(g_CritSounds)-1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else
		Create_TE_BEAMCYLINDER(fOrigin, fOrigin, fOrigin2, g_sprite_, 0, 0, 4, 49, 0, 102, 0, 255, 255, 0)
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_szSoundSlap, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	new Float:fVelocity[3], Float:fVictimOrigin[3], Float:fDistance, Float:fNewSpeed,
	Float:fRadius = rand_crit != 1 ? 150.0 : 250.0
	
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, fOrigin, fRadius)))
	{
		if(is_entity_player(ent) && ent != id && (get_user_team(id) != get_user_team(ent)))
		{
			ka_set_attacker(ent, id, 4.0)
			
			pev(ent, pev_origin, fVictimOrigin)
			
			fDistance = get_distance_f(fOrigin, fVictimOrigin)
			fNewSpeed = VELOCITY_BACK * (1.0 - (fDistance / fRadius))
			get_speed_vector(fOrigin, fVictimOrigin, fNewSpeed, fVelocity)
			
			fVelocity[2] = 400.0
			set_pev(ent, pev_velocity, fVelocity)
			
			if(rand_crit == 1)
			{
				ExecuteHamB(Ham_TakeDamage, ent, CSW_KNIFE, id, random_float(350.0, 500.0), DMG_ALWAYSGIB | DMG_BULLET)
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(TE_LAVASPLASH)
				engfunc(EngFunc_WriteCoord, fVictimOrigin[0])
				engfunc(EngFunc_WriteCoord, fVictimOrigin[1])
				engfunc(EngFunc_WriteCoord, fVictimOrigin[2])
				message_end()
				
				//return PLUGIN_CONTINUE
			}
			else
				ExecuteHam(Ham_TakeDamage, ent, CSW_KNIFE, id, random_float(30.0, 42.0), DMG_ALWAYSGIB | DMG_BULLET)
		}
	}
	
	return PLUGIN_CONTINUE
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

get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
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
				set_hudmessage(49, 0, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
			old_chance[i] = BrutalChance[i]
			ShowSyncHudMsg(i, g_syncHudMessage, "Chance for critical hit %.0f%%%s", 1.0/BrutalChance[i]*100.0, get_user_flags(i) & VIP_FLAG ? " (VIP chance)" : "")
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
					set_hudmessage(49, 0, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
				old_chance[i] = BrutalChance[v]
				ShowSyncHudMsg(i, g_syncHudMessage, "Chance for critical hit %.0f%%%s", 1.0/BrutalChance[v]*100.0, get_user_flags(v) & VIP_FLAG ? " (VIP chance)" : "")
			}
		}
	}
}

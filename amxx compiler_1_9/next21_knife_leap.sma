#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>
#include <WPMGPrintChatColor>

#define PLUGIN			"Leap Knife"
#define AUTHOR			"trofian"
#define VERSION			"1.1"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1) 	(0 < (%1) <= g_maxplayers)
#define TASKID 133742

#define CLASSNAME		"weapon__next21_leap"
#define ABILMINDIST		75.0
#define ABILMAXDIST		740.0
#define HP			90
#define GRAVITY			1.0
#define SPEED			275.0

#define KnifeSound		"next21_knife_v2/secondary/knife_leap_next21.wav"
#define KnifeVModel		"models/next21_knife_v2/knifes/leap/v_leap_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/leap/p_leap_knife.mdl"

// long jump config
#define c_jump_force		470	// дальность
#define c_jump_height		275.0	// высота (для липа тоже)
#define c_jump_cooldown 	5.0	// время так сказать перезарядки лонг джампа

new
KnifeId = -1, g_maxplayers, g_syncHudMessage, // 2 канал
Float:g_last_LongJump_time[33], sprite, Trie:tSoundKnife, smokeSpr

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
		"next21_knife_v2/weapons/leap_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_stab.wav",
		"next21_knife_v2/weapons/leap_knife/knife_hitwall1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_slash1.wav",
		"next21_knife_v2/weapons/leap_knife/knife_slash2.wav",
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
	
	precache_model(KnifeVModel)
	precache_model(KnifePModel)
	precache_sound(KnifeSound)

	precache_generic("sprites/weapon__next21_leap_def.txt")
	precache_generic("sprites/weapon__next21_leap_far.txt")
	precache_generic("sprites/weapon__next21_leap_ok.txt")
	precache_generic("sprites/weapon__next21_leap_time.txt")
	
	sprite = precache_model("sprites/white.spr")
	
	smokeSpr = precache_model("sprites/steam1.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rLeap Knife\y] - Grabs enemies", "!g[Leap knife] Properties: !yLong jump (ctrl+space) Speed+ DMG+ Hp-- !gAbilities: !yGrabs enemies", "ability", 14.0, HP, GRAVITY, SPEED, CLASSNAME, ABILMINDIST, ABILMAXDIST)
	
	if(KnifeId < 0) set_fail_state("[Leap Knife] Error registration")
	
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	register_forward(FM_EmitSound, "EmitSound")
	RegisterHam(Ham_TakeDamage, "player", "Ham_Damage")
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PreThink_", 0)
	g_syncHudMessage = CreateHudSyncObj()
	g_maxplayers = get_maxplayers()
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

public Ham_Damage(victim, inflictor, attacker, Float:damage, bits)
{
	static iAgressor

	if(is_entity_player(iAgressor = inflictor) || is_entity_player(iAgressor = attacker))
	{
		if(kc_is_user_has_knife(iAgressor, KnifeId))
		{
			SetHamParamFloat(4, damage + 10.0)
			return HAM_OVERRIDE
		}
	}
	return HAM_IGNORED
}

public ability(id, victim)
{	
	if(!ka_is_flashed(id))
		set_flsh(id, 255, 0, 0, 35)
	
	if(!ka_is_flashed(victim))
		set_flsh(victim, 237, 230, 33, 40) // жёлтый надо
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, KnifeSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	ka_unfreez(victim)
	ka_gren_unfreez(victim)
	ka_stop_levitation(victim)
	
	new idname[64]
	get_user_name(id, idname, charsmax(idname))

	new Float:fOrigin[3]
	pev(id, pev_origin, fOrigin)
	
	send_to_origin(victim, fOrigin, 600.0)
	
	set_task(0.9, "freez", victim)
	
	new Float:fOriginVic[3]
	pev(victim, pev_origin, fOriginVic)
	
	Create_Line(fOrigin, fOriginVic, 4.0, 100, 100, 100)
	
	ka_set_attacker(victim, id, 4.0)
	
	return PLUGIN_CONTINUE
}

public freez(id) 
{
	if(!is_user_alive(id))
		return
	
	fm_set_user_maxspeed(id, 70.0)
	
	new add_id = ka_render_add(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16)

	new params[2]
	params[0] = id
	params[1] = add_id
	set_task(2.2, "unfreez", _, params, charsmax(params))
}
public unfreez(params[])
{
	new
	id = params[0],
	add_id = params[1]
	
	if(!is_user_alive(id))
		return
	
	ka_render_sub(id, add_id)
	
	kc_reset_speed(id)
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

public Kill_Trail(id)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(99); // TE_KILLBEAM
	write_short(id)
	message_end()
}

public Ham_PreThink_(id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	
	if(AllowLongJump(id))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(id)
		write_short(smokeSpr)
		write_byte(10)
		write_byte(5)
		write_byte(255)
		write_byte(126)
		write_byte(0)
		write_byte(192)
		message_end()
		
		set_task(0.5, "Kill_Trail",id)
		
		static Float:velocity[3]
		velocity_by_aim(id, c_jump_force, velocity)
      
		velocity[2] = c_jump_height
      
		set_pev(id, pev_velocity, velocity)
      
		g_last_LongJump_time[id] = get_gametime()
		
		new args[2]
		args[0] = id
		args[1] = floatround(c_jump_cooldown)
		readout_hud(args)
	}
	
	return HAM_IGNORED
}

bool:AllowLongJump(id)
{
	if(!is_user_alive(id))
		return false
	
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 100)
		return false

	if(kc_get_user_knife(id) != KnifeId)
		return false
	
	static buttons
	buttons = pev(id, pev_button)
	
	if(!is_user_bot(id) && (!(buttons & IN_JUMP) || !(buttons & IN_DUCK)))
		return false
   
	if(get_gametime() - g_last_LongJump_time[id] < c_jump_cooldown)
		return false
	
	return true
}

public readout_hud(put_args[])
{
	new id = put_args[0]
	new second = put_args[1]

	if (second == 0)
		return PLUGIN_HANDLED
	
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_HANDLED
	
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	
	set_hudmessage(237, 230, 33, 0.01, -0.75, 0, 1.1, 1.1, 0.1, 0.0, 2)
	ShowSyncHudMsg(id, g_syncHudMessage, "Long jump [%d]", second)
	second--
	
	new args[2]
	args[0] = id
	args[1] = second
	set_task(1.0, "readout_hud", TASKID+id, args, 2)
	
	return PLUGIN_CONTINUE
}

Create_Line(const Float:start[3], const Float:stop[3], Float:go=10.0, r=0,g=0,b=255)
{
	new Float:fStart[3], Float:fStop[3]
	new Float:fVec[3]
	xs_vec_sub(start, stop, fVec)
	xs_vec_normalize(fVec, fVec)
	
	xs_vec_mul_scalar(fVec, go, fVec)

	xs_vec_add(stop, fVec, fStop)
	xs_vec_sub(start, fVec, fStart)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0)
	engfunc(EngFunc_WriteCoord, fStart[0])
	engfunc(EngFunc_WriteCoord,fStart[1])
	engfunc(EngFunc_WriteCoord,fStart[2])

	engfunc(EngFunc_WriteCoord,fStop[0])
	engfunc(EngFunc_WriteCoord,fStop[1])
	engfunc(EngFunc_WriteCoord,fStop[2])
	write_short(sprite)
	write_byte(1)
	write_byte(5)
	write_byte(2)//life
	write_byte(10)
	write_byte(0)
	write_byte(r)	// RED
	write_byte(g)	// GREEN
	write_byte(b)	// BLUE					
	write_byte(250)	// brightness
	write_byte(5)
	message_end()
}

send_to_origin(ent, Float:target_origin[3], Float:speed)
{
	if (!pev_valid(ent))
		return 0

	new Float:entity_origin[3]
	pev(ent, pev_origin, entity_origin)

	new Float:diff[3];
	diff[0] = target_origin[0] - entity_origin[0]
	diff[1] = target_origin[1] - entity_origin[1]
	diff[2] = target_origin[2] - entity_origin[2]

	new Float:length = floatsqroot(floatpower(diff[0], 2.0) + floatpower(diff[1], 2.0) + floatpower(diff[2], 2.0))

	if(length == 0.0)
		return 0
	
	new Float:velocity[3];
	velocity[0] = diff[0] * (speed / length)
	velocity[1] = diff[1] * (speed / length)
	//velocity[2] = diff[2] * (speed / length)
	
	velocity[2] = c_jump_height
	
	set_pev(ent, pev_velocity, velocity)

	return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

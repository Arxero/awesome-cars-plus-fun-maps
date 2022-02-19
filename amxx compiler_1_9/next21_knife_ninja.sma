#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <next21_knife_core>
#include <next21_advanced>

#define PLUGIN			"Ninja-to"
#define AUTHOR			"trofian and Psycrow"
#define VERSION			"1.1"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1) 	(1<=%1<=g_maxplayers)
#define TASKID 133742

#define CLASSNAME		"weapon__next21_ninja"
#define HP			115
#define GRAVITY			0.75
#define SPEED			255.0

#define ExitSound		"next21_knife_v2/secondary/knife_ninja_next21.wav"

#define KnifeVModel		"models/next21_knife_v2/knifes/ninja/v_ninja_knife.mdl"
#define KnifeVModel_I		"models/next21_knife_v2/knifes/ninja/v_ninja_knife_i.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/ninja/p_ninja_knife.mdl"

new
KnifeId = -1, g_syncHudMessage, // 2 канал
bool:g_Attack[33], Trie:tSoundKnife, g_maxplayers

public plugin_natives()
{
	register_native("ka_in_ninja", "_n21_in_ninja", 0) // 1 - ид
	register_native("ka_unset_ninja", "_n21_unset_ninja", 0) // 1 - ид
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
		"next21_knife_v2/weapons/ninja_to/knife_hit1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_hit1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_hit1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_hit1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_stab.wav",
		"next21_knife_v2/weapons/ninja_to/knife_hitwall1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_slash1.wav",
		"next21_knife_v2/weapons/ninja_to/knife_slash2.wav",
		"next21_knife_v2/weapons/ninja_to/knife_deploy1.wav"
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
	
	precache_sound(ExitSound)
	
	precache_model(KnifeVModel)
	precache_model(KnifeVModel_I)
	precache_model(KnifePModel)
	
	precache_generic("sprites/weapon__next21_ninja.txt")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Weapon_PrimaryAttack ,"weapon_knife","unset_ability_a")
	RegisterHam(Ham_Weapon_SecondaryAttack ,"weapon_knife","unset_ability_a")
	RegisterHam(Ham_TakeDamage,"player","unset_ability_d")
	RegisterHam(Ham_Touch, "player", "unset_ability_t")
	RegisterHam(Ham_Spawn, "player", "hook_spawn_post", 1)
	KnifeId = kc_register_knife("\y[\rNinja Knife\y] - Invisibility", "!g[Ninja knife] Properties: !yGravity- HP++ !gAbilities: !yYou become invisible for 4 sec", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME)
	if(KnifeId < 0) set_fail_state("[Ninja Knife] Error registration")
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	register_event("CurWeapon", "unset_ability_c", "be", "1=1")
	register_forward(FM_EmitSound, "EmitSound")
	g_syncHudMessage = CreateHudSyncObj()
	g_maxplayers = get_maxplayers()
}

public client_connect(id)
    g_Attack[id] = false

public hook_spawn_post(id)
{
	if(!is_user_alive(id))
		return
	
	remove_task(TASKID+id)
	g_Attack[id] = false
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

public ability(id)
{
	g_Attack[id] = true
	
	ka_render_add(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
	set_user_footsteps(id,1)
	ka_hide_hat(id,1)
	
	set_pev(id, pev_viewmodel2, KnifeVModel_I)
	
	if(!ka_is_flashed(id))
		set_flsh(id, 8, 37, 103, 130)
	
	new args[2]
	args[0] = id
	args[1] = 4
	readout_hud(args)
	
	return PLUGIN_CONTINUE
}

public unset_ability_a(weapon) // Если игрок начал атаковать
{
	new id = pev(weapon,pev_owner)
	if (!g_Attack[id])
	return
 
	g_Attack[id] = false
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, ExitSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public unset_ability_c(id) // Если игрок сменил оружие
{
	if(!g_Attack[id])
		return
	
	g_Attack[id] = false
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, ExitSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public unset_ability_d(victim, inflictor, attacker, Float:damage, damage_type) // Если игрока ранили
{
	if(!is_user_alive(victim) || !is_user_alive(attacker) || !g_Attack[victim] || get_user_team(victim) == get_user_team(attacker))
		return HAM_IGNORED
	
	g_Attack[victim] = false
	engfunc(EngFunc_EmitSound, victim, CHAN_STATIC, ExitSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_IGNORED
}

public unset_ability_t(player, id)  // Если до игрока дотронулись
{
	if(!is_user_alive(id) || !is_user_alive(player) || !g_Attack[id] || get_user_team(id) == get_user_team(player))
		return HAM_IGNORED
	
	g_Attack[id] = false
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, ExitSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_IGNORED
}

public unset_ability(id) // Выход из инвиза
{
	g_Attack[id] = false
	
	if(is_user_connected(id))
		set_user_footsteps(id,0)
		
	ka_hide_hat(id, 0)
	
	ka_render_add(id)
	
	if(kc_get_user_knife(id) == KnifeId && get_user_weapon(id) == CSW_KNIFE)
	set_pev(id, pev_viewmodel2, KnifeVModel)
}
	
public readout_hud(put_args[])
{
	new id = put_args[0]
	new second = put_args[1]

	if(!g_Attack[id])
	{
		unset_ability(id)
		return PLUGIN_HANDLED
	}
	
	if(second == 0 || kc_get_user_knife(id) != KnifeId)
	{
		unset_ability(id)
		engfunc(EngFunc_EmitSound, id, CHAN_STATIC, ExitSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		return PLUGIN_HANDLED
	}
		
	if(!is_user_alive(id))
	{	
		g_Attack[id] = false
		
		return PLUGIN_HANDLED
	}
	
	if(pev(id, pev_flags) & FL_INWATER)
	{
		ka_render_add(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 30)
		ka_hide_hat(id, 1)
	}
	
	set_hudmessage(255, 255, 255, -1.0, -0.2, 0, 1.1, 1.0, 0.1, 0.0, 2)
	ShowSyncHudMsg(id, g_syncHudMessage, "You are now off the radar!^n(Renaiming %d sec.)", second)
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


public bool:_n21_in_ninja(plugin, num_params)
{
	new id = get_param(1)
	if(g_Attack[id] && is_user_alive(id))
		return true
	return false
}

public _n21_unset_ninja(plugin, num_params)
{
	new id = get_param(1)
	if(g_Attack[id] && is_user_alive(id))
		g_Attack[id] = false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

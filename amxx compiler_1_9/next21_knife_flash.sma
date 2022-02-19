#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <next21_knife_core>
#include <next21_advanced>
#include <WPMGPrintChatColor>

#define TASKID 5314535

#define PLUGIN			"Flash Knife"
#define AUTHOR			"trofian"
#define VERSION			"1.1"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1)		(1<=%1<=g_maxplayers)

#define CLASSNAME		"weapon__next21_flash"
#define ABILMINDIST		75.0
#define ABILMAXDIST		1200.0
#define HP			100
#define GRAVITY			1.0
#define SPEED			270.0
#define FALLDMGDIVIDER		9.0

#define SOUND_VIC_FLASHED	"next21_knife_v2/secondary/knife_flash_vic_next21.wav"
#define FlashSound		"next21_knife_v2/secondary/knife_flash_next21.wav"
#define KnifeVModel		"models/next21_knife_v2/knifes/flash/v_flash_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/flash/p_flash_knife.mdl"

new
KnifeId = -1, bool:g_in_flash[33], g_last_flashed[33], g_syncHudMessage, // 2 канал
g_msgScreenFade, g_maxplayers, exploSpr, Trie:tSoundKnife

public plugin_natives()
	register_native("ka_is_flashed", "_ka_is_flashed", 0) // 1 - ид, возвращает true если во флэше

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
		"next21_knife_v2/weapons/flash_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/flash_knife/knife_hit2.wav",
		"next21_knife_v2/weapons/flash_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/flash_knife/knife_hit2.wav",
		"weapons/knife_stab.wav",
		"weapons/knife_hitwall1.wav",
		"next21_knife_v2/weapons/flash_knife/knife_slash1.wav",
		"next21_knife_v2/weapons/flash_knife/knife_slash1.wav",
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
	
	precache_sound(FlashSound)
	precache_sound(SOUND_VIC_FLASHED)
	precache_model(KnifeVModel)
	precache_model(KnifePModel)
	
	exploSpr = precache_model("sprites/shockwave.spr")
	
	precache_generic("sprites/weapon__next21_flash_cnot.txt")
	precache_generic("sprites/weapon__next21_flash_def.txt")
	precache_generic("sprites/weapon__next21_flash_far.txt")
	precache_generic("sprites/weapon__next21_flash_ok.txt")
	precache_generic("sprites/weapon__next21_flash_time.txt")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rFlash Knife\y] - Flashes enemies", "!g[Flash knife] Properties: !yAll players are visible  HP--  Speed++ !gAbility: !yEnlightens players", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME, ABILMINDIST, ABILMAXDIST)
	
	if(KnifeId < 0) set_fail_state("[Flash Knife] Error registration")
	
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	RegisterHam(Ham_TakeDamage, "player", "ham_FallDmg")
	RegisterHam(Ham_Killed, "player", "ham_killed_pl")
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PreThink_player")
	register_event("CurWeapon", "WeaponChange", "be", "1=1")
	g_syncHudMessage = CreateHudSyncObj()
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_maxplayers = get_maxplayers()
	
	set_task(0.3, "show_invisible_enemies", _, _, _, "b")
}

public Ham_PreThink_player(id)
{
	if(kc_get_crosshair(id) == CrossOff || kc_get_user_knife(id) != KnifeId)
		return
	
	static victim, body
	get_user_aiming(id, victim, body)
	
	if(!is_entity_player(victim))
		return
	
	if(g_in_flash[victim])
		kc_set_crosshair(id, 1, CrossCannot)
}

public kc_ability_pre(id, victim)
{
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_CONTINUE
	
	if(g_in_flash[victim])
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public WeaponChange(id)
{
	if(g_in_flash[id])
		kc_set_crosshair(id, 0, CrossOff)
}

public ham_killed_pl(id)
{
	if(g_in_flash[id])
		client_cmd(id, "stopsound")
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
	kc_set_crosshair(victim, 0, CrossOff)
	blind_player(victim)
	g_in_flash[victim] = true
	g_last_flashed[id] = victim
	set_task(0.8,"screenfades", victim)
	set_task(4.0,"screenfades_out", victim)
	new arg[2]
	arg[0] = id
	arg[1] = 4
	readout_hud(arg)
	
	client_cmd(victim, "spk %s", SOUND_VIC_FLASHED)
	client_cmd(id, "spk %s", FlashSound)
	
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	
	new szVictimName[32]
	get_user_name(victim, szVictimName, charsmax(szVictimName))
	
	PrintChatColor(id, PRINT_COLOR_PLAYERTEAM + victim, "!g[%s] !yYou have flashed !t%s", PLUGIN, szVictimName)
	PrintChatColor(victim, PRINT_COLOR_PLAYERTEAM + id, "!g[%s] !yYou have been flashed by !t%s", PLUGIN, szName)
	
	return PLUGIN_CONTINUE
}

public ham_FallDmg(Victim, Gun, Attacker, Float:damage)
{
	if(Gun == 0)
	{
		static classname[32]
		pev(Gun,pev_classname,classname,31)
		
		if(!equal(classname,"grenade") && kc_get_user_knife(Victim) == KnifeId)
		{
			SetHamParamFloat(4, damage/FALLDMGDIVIDER)
			return HAM_IGNORED
		}
	}
	
	if(is_user_alive(Victim) && is_user_alive(Attacker) && g_in_flash[Victim] && g_last_flashed[Attacker] == Victim)
	{		
		if(kc_get_user_knife(Attacker) == KnifeId)
		{
			SetHamParamFloat(4, 90.0)
			if(!g_in_flash[Attacker])
				set_flsh(Attacker, 255, 0, 0, 41)
			PrintChatColor(Attacker, _, "!g[%s] !yYou have made a critical hit!", PLUGIN)
			PrintChatColor(Victim, _, "!g[%s] !yYou have been hit by a critical!", PLUGIN)
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
		return PLUGIN_HANDLED
	
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_HANDLED
	
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	
	new vicname[64]
	get_user_name(g_last_flashed[id], vicname, charsmax(vicname))
	
	set_hudmessage(255, 0, 0, -1.0, -0.30, 0, 1.1, 1.0, 0.1, 0.0, 2)
	ShowSyncHudMsg(id, g_syncHudMessage, "%s Blind for: %d СЃРµРє.^nNow you can kill him!", vicname, second)
	second--
	
	new args[2]
	args[0] = id
	args[1] = second
	set_task(1.0, "readout_hud", TASKID+id, args, 2)
	
	return PLUGIN_CONTINUE
}

public show_invisible_enemies()
{
	static i, j
	for(i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_alive(i) || !ka_in_ninja(i))
			continue
		
		static origin[3]
		get_user_origin(i, origin)
		
		for(j=1; j<=g_maxplayers; j++)
		{
			if(!is_user_connected(j))
				continue
			
			static v, is_spec
			
			is_spec = 0
			if(!is_user_alive(j))
			{
				v = pev(j, pev_iuser2)
		
				if(is_entity_player(v))
					is_spec = 1
				else
					continue
			}
			
			if(!kc_is_user_has_knife(is_spec ? v : j, KnifeId) || get_user_team(is_spec ? v : j) == get_user_team(i))
				continue
			
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, j);
			write_byte(21); // TE_BEAMCYLINDER
			write_coord(origin[0]); // start X
			write_coord(origin[1]); // start Y
			write_coord(origin[2] - 10); // start Z
			write_coord(origin[0]); // something X
			write_coord(origin[1]); // something Y
			write_coord(origin[2] + 262); // something Z
			write_short(exploSpr); // sprite
			write_byte(0); // startframe
			write_byte(0); // framerate
			write_byte(2); // life
			write_byte(5); // width
			write_byte(0); // noise
			write_byte(255); // red
			write_byte(255); // green
			write_byte(255); // blue
			write_byte(100); // brightness
			write_byte(0); // speed
			message_end();
			
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, j);
			write_byte(21); // TE_BEAMCYLINDER
			write_coord(origin[0]); // start X
			write_coord(origin[1]); // start Y
			write_coord(origin[2] + 35); // start Z
			write_coord(origin[0]); // something X
			write_coord(origin[1]); // something Y
			write_coord(origin[2] + 262); // something Z
			write_short(exploSpr); // sprite
			write_byte(0); // startframe
			write_byte(0); // framerate
			write_byte(2); // life
			write_byte(5); // width
			write_byte(0); // noise
			write_byte(255); // red
			write_byte(255); // green
			write_byte(255); // blue
			write_byte(100); // brightness
			write_byte(0); // speed
			message_end();
		}
	}
}

public screenfades(id)
{
	if(!is_user_alive(id))
		return
	
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(1<<12)
	write_short(1<<8)
	write_short(1<<2)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	message_end()
}

public screenfades_out(id)
{
	kc_set_crosshair(id, 1, CrossDefault)
	g_in_flash[id] = false
	
	if(!is_user_connected(id))
		return
	
	//client_cmd(id, "stopsound")
	
	if(!is_user_alive(id))
		return
	
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(1<<12)
	write_short(1<<8)
	write_short(1<<4)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()
}

blind_player(id)
{
	if(!is_user_alive(id))
		return
	
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(1<<12)
	write_short(1<<8)
	write_short(1<<0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	message_end()
}

set_flsh(id, r, g, b, i)
{
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(1<<12)
	write_short(1<<8)
	write_short(1<<4)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(i)
	message_end()
}

public bool:_ka_is_flashed(plugin, num_params)
{
	new id = get_param(1)
	if(g_in_flash[id])
		return true
	return false
}

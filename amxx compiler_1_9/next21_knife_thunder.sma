#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <xs>
#include <next21_knife_core>
#include <next21_advanced>

#define PLUGIN			"Thunder Knife"
#define AUTHOR			"Psycrow"
#define VERSION			"1.0"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define is_entity_player(%1)		(1<=%1<=g_maxplayers)

#define CLASSNAME		"weapon__next21_thunder"
#define ABILMINDIST		750.0
#define ABILMAXDIST		3000.0
#define HP			65
#define GRAVITY			1.0
#define SPEED			260.0

#define VELOCITY_BACK		2000.0
#define VIP_FLAG		ADMIN_LEVEL_H

#define KnifeVModel		"models/next21_knife_v2/knifes/thunder/v_thunder_knife.mdl"
#define KnifePModel		"models/next21_knife_v2/knifes/thunder/p_thunder_knife_fix.mdl"

#define g_szSoundThunder	"next21_knife_v2/secondary/knife_thunder_next21.wav"
#define g_SoundZeus		"next21_knife_v2/crit/zeus_activated.wav"

new const GUNSHOT_DECALS[] = {46, 47, 48}
new siBlood[2]
new Float:oldSpeed[33], levpoints[33], bool: levmove[33]

new
bool:dojump[33],
KnifeId = -1,
g_maxplayers, g_sprite_, iLightning,Trie:tSoundKnife,
Float:BrutalChance[33], bool: is_rev_cont[33], bool: is_rev_go[33], bool: is_Zeus[33], bool: is_thunder[33], bool:is_levitation[33] ,g_syncHudMessage

public plugin_natives()
{
	register_native("ka_Zeus", "_ka_Zeus", 0) // 1 - ид
	register_native("ka_is_thunder", "_ka_is_thunder", 0) // 1 - ид
	register_native("ka_stop_levitation", "_ka_stop_levitation", 0) // 1 - ид
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
	/*
		"next21_knife_v2/weapons/thunder_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_hit2.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_hit2.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_stab.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_hitwall1.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_slash1.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_slash1.wav",
		"next21_knife_v2/weapons/thunder_knife/knife_deploy1.wav"
	*/
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
	
	precache_sound(g_szSoundThunder)
	precache_sound(g_SoundZeus)
	
	g_sprite_ = precache_model("sprites/shadow_circle.spr")
	iLightning = precache_model("sprites/lgtning.spr")
	
	precache_generic("sprites/weapon__next21_thunder_cnot.txt")
	precache_generic("sprites/weapon__next21_thunder_def.txt")
	precache_generic("sprites/weapon__next21_thunder_far.txt")
	precache_generic("sprites/weapon__next21_thunder_ok.txt")
	precache_generic("sprites/weapon__next21_thunder_time.txt")
	
	siBlood[0] = precache_model("sprites/blood.spr")
	siBlood[1] = precache_model("sprites/bloodspray.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rThunder Knife\y] - Thunderstuck", "!g[Thunder knife] !gAbilities: !yHits with thunder", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME, ABILMINDIST, ABILMAXDIST)
	
	if(KnifeId < 0) set_fail_state("[Thunder Knife] Error registration")
			
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PreThink_player")
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	RegisterHam(Ham_Killed,"player","Give_Rev")
	RegisterHam(Ham_Spawn, "player", "hook_spawn_post", 1)
	register_forward(FM_PlayerPreThink, "PreThink")
		
	g_syncHudMessage = CreateHudSyncObj()
	set_task(1.0, "show_crit_info", _, _, _, "b")
	
	g_maxplayers = get_maxplayers()
}
	
public client_connect(id)
{
	BrutalChance[id] = 0.0
	is_Zeus[id] =  false
	is_levitation[id] = false
	levmove[id] = false
	levpoints[id] = 0
}

public hook_spawn_post(id)
{
	if(is_levitation[id])
		Levitation(id,0)
}

public Give_Rev(victim, attacker)
{
	if(!is_entity_player(attacker))
		return HAM_IGNORED
	
	if(kc_get_user_knife(attacker) != KnifeId)
		return HAM_IGNORED
	
	if(attacker == victim)
		return HAM_IGNORED
	
	if(get_user_flags(attacker) & VIP_FLAG)
		BrutalChance[attacker] += 15.0
	else
		BrutalChance[attacker] += 10.0
	
	if(BrutalChance[attacker] > 90.0)
		is_rev_go[attacker] = true
	else
		is_rev_go[attacker] = false
	
	if(!is_rev_cont[attacker] && !is_rev_go[attacker])
	{
		is_rev_cont[attacker] = true
		set_task(10.0,"Sub_Rev",attacker)
	}
	
	if(is_rev_go[attacker] && !is_Zeus[attacker])
	{
		is_Zeus[attacker] = true
		engfunc(EngFunc_EmitSound, attacker, CHAN_WEAPON, g_SoundZeus, 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(1.0,"Fast_Sub_Rev",attacker)
	}
	
	return HAM_IGNORED
}

public Sub_Rev(id)
{
	if(BrutalChance[id] != 0.0)
	{
		BrutalChance[id] -= 1.0
		set_task(10.0,"Sub_Rev",id)
		
	}
	else is_rev_cont[id] = false
}

public Fast_Sub_Rev(id)
{
	if(BrutalChance[id] != 0.0)
	{
		BrutalChance[id] -= 1.0
		set_task(0.5,"Fast_Sub_Rev",id)
		
	}
	else 
	{
		is_rev_cont[id] = false
		is_Zeus[id] = false
	}
}

public kc_ability_pre(id, victim)
{
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_CONTINUE	
	
	new Float:fWallNormal[3], Float:fAimOrigin[3], Float:fMyOrigin[3]
	pev(id, pev_origin, fMyOrigin)
	fm_get_aim_origin(id, fAimOrigin)
	
	get_wall_normal(id, fWallNormal)
	
	if(1.0 < fWallNormal[2] || 0.0 >= fWallNormal[2])
		return PLUGIN_HANDLED
		
	if(ABILMINDIST > get_distance_f(fMyOrigin, fAimOrigin) || get_distance_f(fMyOrigin, fAimOrigin) > ABILMAXDIST)
		return PLUGIN_HANDLED
			
	return PLUGIN_CONTINUE	
}


public Ham_PreThink_player(id)
{		
	if(is_levitation[id] && kc_get_user_knife(id) == KnifeId && get_user_weapon(id) == CSW_KNIFE && !ka_in_ffreez(id) && !ka_in_fgrenfreez(id) && !ka_in_fchill(id) && !ka_in_fgrenchill(id) && is_user_alive(id))
	{
		// stop motion
		entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});

		new button = get_user_button(id), oldbuttons = entity_get_int(id,EV_INT_oldbuttons);
		new flags = entity_get_int(id,EV_INT_flags);

		// if are on the ground and about to jump, set the gravity too high to really do so
		if((button & IN_JUMP) && !(oldbuttons & IN_JUMP) && (flags & FL_ONGROUND))
			entity_set_float(id,EV_FL_gravity,999999.9); // I CAN'T STAND THE PRESSURE

		// otherwise, set the gravity so low that they don't fall
		else
			entity_set_float(id,EV_FL_gravity,0.000001); // 0.0 doesn't work
			
		if(levpoints[id]<=30 && !levmove[id])
		{
			new Float:velocity[3]	
			pev(id, pev_velocity, velocity)
			velocity[2] = 30.0
			set_pev(id, pev_velocity, velocity)
			levpoints[id]++
			levmove[id] = false
			
		}
		else
		{
			if(levpoints[id]>=0)
			{
				new Float:velocity[3]	
				pev(id, pev_velocity, velocity)
				velocity[2] = -30.0
				set_pev(id, pev_velocity, velocity)
				levpoints[id]--
				levmove[id] = true
			}
			else levmove[id] = false
		}
		//ka_play_anim(id,0)
	}
	else 
	{
		if(is_levitation[id])
			Levitation(id,0)
	}
	
	if(!is_user_alive(id))
		return
	
	if(kc_get_user_knife(id) != KnifeId)
		return
			
	new Float:fWallNormal[3], Float:fAimOrigin[3], Float:fMyOrigin[3]
	pev(id, pev_origin, fMyOrigin)
	fm_get_aim_origin(id, fAimOrigin)
	
	get_wall_normal(id, fWallNormal)
	
	if(kc_in_reloading(id))
	{
		kc_set_crosshair(id, 1, CrossTime)
		return
	}
	
	if(1.0 < fWallNormal[2] || 0.0 >= fWallNormal[2])
	{
		kc_set_crosshair(id, 1, CrossCannot)
		return
	}
	
	if(ABILMINDIST > get_distance_f(fMyOrigin, fAimOrigin) || get_distance_f(fMyOrigin, fAimOrigin) > ABILMAXDIST)
	{
		kc_set_crosshair(id, 1, CrossFar)
		return
	}
	kc_set_crosshair(id, 1, CrossOk) 
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
		if(!dojump[id])
		{
			dojump[id] = true
			Levitation(id,1)
			return PLUGIN_CONTINUE
		}
		else
		{
			if(is_levitation[id])
				Levitation(id,0)
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (pev(id, pev_flags) & FL_ONGROUND))
	{
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public CurWeapon(weapon)
{
	new id = get_gun_owner(weapon)
	
	if(kc_get_user_knife(id) == KnifeId)
	{
		set_pev(id, pev_viewmodel2, KnifeVModel)
		set_pev(id, pev_weaponmodel2, KnifePModel)
		is_thunder[id] = true
		
	}
	else 
	{
		is_thunder[id] = false
		Levitation(id,0)
	}
}

public ability(id)
{	
	new ent = -1
	new Float:fAimOrigin[3], Float:fOrigin2[3]
	fm_get_aim_origin(id, fAimOrigin)
			
	fOrigin2[0] = fAimOrigin[0]
	fOrigin2[1] = fAimOrigin[1]
	fOrigin2[2] = fAimOrigin[2] + 220.0
		
	Create_Decals(id)
	CreateLightning(fAimOrigin)
	Create_TE_BEAMCYLINDER(fAimOrigin, fAimOrigin, fOrigin2, g_sprite_, 0, 0, 4, 49, 0, 255, 255, 255, 255, 0)
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_szSoundThunder, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
	new Float:fVelocity[3], Float:fVictimOrigin[3], Float:fDistance, Float:fNewSpeed,
	Float:fRadius = 150.0
	
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, fAimOrigin, fRadius)))
	{
		if(is_entity_player(ent) && (get_user_team(id) != get_user_team(ent)))
		{
			ka_set_attacker(ent, id, 4.0)
			
			pev(ent, pev_origin, fVictimOrigin)
			
			fDistance = get_distance_f(fAimOrigin, fVictimOrigin)
			fNewSpeed = VELOCITY_BACK * (1.0 - (fDistance / fRadius))
			get_speed_vector(fAimOrigin, fVictimOrigin, fNewSpeed, fVelocity)
			
			fVelocity[2] = 400.0
			set_pev(ent, pev_velocity, fVelocity)
			
			ExecuteHam(Ham_TakeDamage, ent, CSW_KNIFE, id, random_float(40.0, 52.0), DMG_ALWAYSGIB | DMG_BULLET)
		}
	}
	return PLUGIN_CONTINUE
}

public Levitation(id,mode)
{	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
		
	if(kc_get_user_knife(id) != KnifeId)
		return PLUGIN_CONTINUE
					
	if(ka_in_ffreez(id) || ka_in_fgrenfreez(id))
		return PLUGIN_CONTINUE
	
	if(mode == 1)
	{
		if(get_user_weapon(id) != CSW_KNIFE)
			return PLUGIN_CONTINUE
		
		new Float:speed = get_user_maxspeed(id)
		
		if(speed > 1.0 && speed != oldSpeed[id])
			oldSpeed[id] = speed
			
		set_user_maxspeed(id,1.0); // 0.0 doesn't work
		entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});
		entity_set_float(id,EV_FL_gravity,0.000001); // 0.0 doesn't work
		
		new Float:velocity[3]	
		pev(id, pev_velocity, velocity)
		velocity[2] = 30.0
		set_pev(id, pev_velocity, velocity)
		set_task(1.0,"Lev_atv",id)
	}
	else
	{
		if(!is_levitation[id])
			return PLUGIN_CONTINUE
		
		is_levitation[id] = false
		if(!ka_in_ffreez(id) && !ka_in_fgrenfreez(id))
		{
			entity_set_float(id,EV_FL_gravity,1.0)
			set_user_maxspeed(id,oldSpeed[id])
			oldSpeed[id] = 0.0
			kc_reset_speed(id)
		}
		levpoints[id] = 0
		//ka_stop_anim(id)
	}
	return PLUGIN_CONTINUE
}

public Lev_atv(id) is_levitation[id] = true

get_wall_normal(id, Float:fNormal[3])
{
	new Float:fOrigin[3]
	pev(id, pev_origin, fOrigin)
 
	new Float:fAngles[3]
	pev(id, pev_v_angle, fAngles)
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fAngles)
	xs_vec_mul_scalar(fAngles, 9999.0, fAngles)
 
	new Float:fEndPos[3]
	xs_vec_add(fAngles, fOrigin, fEndPos)
 
	new ptr = create_tr2() 
	engfunc(EngFunc_TraceLine, fOrigin, fEndPos, IGNORE_MISSILE | IGNORE_MONSTERS | IGNORE_GLASS, id, ptr)
 
	new Float:vfNormal[3]
	get_tr2(ptr, TR_vecPlaneNormal, vfNormal)
 
	xs_vec_copy(vfNormal, fNormal)
}
/*
CreateSled(Float:fAimOrigin[3])
{
	new Ent = create_entity("info_target")
	
	if(is_valid_ent(Ent))
	{
		if(sled_number == 9)
		{
			remove_entity(g_sleds[0])
			g_sleds[9] = Ent
			for( new i = 0; i <= 8; i++)
				g_sleds[i] = g_sleds[i+1]
		}
		else
		{
			g_sleds[sled_number] = Ent
			sled_number++
		}
		
		entity_set_model(Ent, Sled)
		entity_set_size(Ent,Float:{-6.0, -10.0, 0.0},Float:{6.0, 10.0, 36.0})
		entity_set_origin(Ent, fAimOrigin)  
		
		//new Float:fAngelsT[3]
		//client_print(id,print_chat,"%d",fWallNormal[0])
		//client_print(id,print_chat,"%d",fWallNormal[1])
		//client_print(id,print_chat,"%d",fWallNormal[2])
		//set_pev(Ent,pev_angles,fAngelsT)
		//entity_set_int(Ent,EV_INT_solid,SOLID_BBOX)	
		//pev_solid
		//drop_to_floor(Ent)
	}
}
*/
public show_crit_info()
{	
	static i, Float:old_chance[33]
	
	for(i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue
		
		if(is_user_alive(i) && kc_is_user_has_knife(i, KnifeId))
		{
			if(old_chance[i] == BrutalChance[i] && !is_Zeus[i])
				set_hudmessage(255, 255, 225, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
			else
				set_hudmessage(0, 151, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
			old_chance[i] = BrutalChance[i]
			ShowSyncHudMsg(i, g_syncHudMessage, "Zeus' anger %.0f%%%s", BrutalChance[i], get_user_flags(i) & VIP_FLAG ? " (VIP)" : "")
		}
		else
		{
			static v
			v = pev(i, pev_iuser2)
			
			if(is_entity_player(v) && kc_is_user_has_knife(v, KnifeId))
			{
				if(old_chance[v] == BrutalChance[v] && !is_Zeus[v])
					set_hudmessage(255, 255, 225, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				else
					set_hudmessage(0, 151, 255, 0.01, 0.71, 0, 0.0, 1.2, 0.0, 0.0, 1)
				
				old_chance[i] = BrutalChance[v]
				ShowSyncHudMsg(i, g_syncHudMessage, "Zeus' anger %.0f%%%s", BrutalChance[v], get_user_flags(v) & VIP_FLAG ? " (VIP)" : "")
			}
		}
	}
}

stock CreateLightning(Float:fAimOrigin[3])
{
	new iLineWidth=120
	new iOrigin[3], iOrigin2[3];
	iOrigin[0]=floatround(fAimOrigin[0])
	iOrigin[1]=floatround(fAimOrigin[1])
	iOrigin[2]=floatround(fAimOrigin[2])-50
	iOrigin2[0]=iOrigin[0]
	iOrigin2[1]=iOrigin[1]
	iOrigin2[2]=iOrigin[2]+500
	Create_TE_BEAMPOINTS(iOrigin, iOrigin2,iLightning, 0, 1, 2, iLineWidth, 10, 255, 255, 255, 255, 0) // 15 10
}
 
stock Create_TE_BEAMPOINTS(start[3], end[3], iSprite, startFrame, frameRate, life, width, noise, red, green, blue, alpha, speed)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMPOINTS );
	write_coord( start[0] );
	write_coord( start[1] );
	write_coord( start[2] );
	write_coord( end[0] );
	write_coord( end[1] );
	write_coord( end[2] );
	write_short( iSprite );			// model
	write_byte( startFrame );		// start frame
	write_byte( frameRate );		// framerate
	write_byte( life );				// life
	write_byte( width );				// width
	write_byte( noise );				// noise
	write_byte( red);				// red
	write_byte( green );				// green
	write_byte( blue );				// blue
	write_byte( alpha );				// brightness
	write_byte( speed );				// speed
	message_end();
}
 
stock Create_TE_BEAMCYLINDER(Float:origin[3], Float:center[3], Float:axis[3], iSprite, startFrame, frameRate, life, width, amplitude, red, green, blue, brightness, speed)
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

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
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

stock Create_Decals(id)
{
	new aimOrigin[3], target, body
	get_user_origin(id, aimOrigin, 3)
	get_user_aiming(id, target, body)
	
	if(!is_user_connected(target))
	{
		if(target)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			write_short(target)
			message_end()
		} 
		else 
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			message_end()
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		write_coord(aimOrigin[0])
		write_coord(aimOrigin[1])
		write_coord(aimOrigin[2])
		write_short(id)
		write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
		message_end()
	}
}

public bool:_ka_Zeus(plugin, num_params)
{
	new id = get_param(1)
	if(is_Zeus[id])
		return true
	return false
}

public bool:_ka_is_thunder(plugin, num_params)
{
	new id = get_param(1)
	if(is_thunder[id])
		return true
	return false
}

public bool:_ka_stop_levitation(plugin, num_params)
{
	new id = get_param(1)
	Levitation(id,0)
}

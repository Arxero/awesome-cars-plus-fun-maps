 #include <amxmodx>
 #include <fun>
 #include <engine>
 #include <fakemeta>
 #include <cstrike>
 #include <fakemeta_util>
 #include <hamsandwich>
 #include <next21_advanced>
 #include <next21_knife_core>
 #include <hud>

#define PLUGIN			"Frost Knife"
#define AUTHOR			"trofian & Psycrow"
#define VERSION			"1.1"

#define CLASSNAME		"weapon__next21_frost"

#define HP			90
#define GRAVITY			1.0
#define SPEED			255.0

#define FROST_RADIUS		240.0
#define FROST_R	0
#define FROST_G	0
#define FROST_B	255

#define TASK_REMOVE_CHILL	200
#define TASK_REMOVE_FREEZE	250

#define ModelV			"models/next21_knife_v2/knifes/frost/v_frost_knife.mdl"
#define ModelP			"models/next21_knife_v2/knifes/frost/p_frost_knife_fix.mdl"
#define MODEL_FROSTNOVA		"models/next21_knife_v2/knifes/frost/frostnova.mdl"

#define SoundExplode		"next21_knife_v2/secondary/knife_frost_explode.wav"
#define SoundFreez		"next21_knife_v2/secondary/knife_frost_freez.wav"

#define get_gun_owner(%1)	get_pdata_cbase(%1, 41, 4)
#define IsEntityPlayer(%1)	(1<=%1<=g_maxplayers)

#define TASKID 133742

new KnifeId = -1

new hasFrostNade[33];
new isChilled[33];
new isFrozen[33];

new novaDisplay[33];
new Float:oldSpeed[33];

new glassGibs;
new trailSpr;
new smokeSpr;
new exploSpr;

new Trie:tSoundKnife
new g_maxplayers

public plugin_precache()
{
	precache_model(MODEL_FROSTNOVA)
	
	glassGibs = precache_model("models/glassgibs.mdl")
	trailSpr = precache_model("sprites/laserbeam.spr");
	smokeSpr = precache_model("sprites/steam1.spr");
	exploSpr = precache_model("sprites/shockwave.spr");
	
	precache_model(ModelV)
	precache_model(ModelP)
	
	precache_sound(SoundExplode); // grenade explodes
	precache_sound(SoundFreez); // player is frozen
	precache_sound("player/pl_duct2.wav"); // player is chilled
	
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
		"next21_knife_v2/weapons/frost_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/frost_knife/knife_hit2.wav",
		"next21_knife_v2/weapons/frost_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/frost_knife/knife_hit2.wav",
		"next21_knife_v2/weapons/frost_knife/knife_hit1.wav",
		"next21_knife_v2/weapons/frost_knife/knife_hit_wall.wav",
		"next21_knife_v2/weapons/frost_knife/knife_slash1.wav",
		"next21_knife_v2/weapons/frost_knife/knife_slash2.wav",
		"next21_knife_v2/weapons/frost_knife/knife_draw.wav"
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
	
	precache_generic("sprites/weapon__next21_frost.txt")
}

public plugin_natives()
{
	register_native("ka_in_ffreez", "_n21_in_ffreez", 0) // 1 - ид
	register_native("ka_in_fchill", "_n21_in_fchill", 0) // 1 - ид
	
	register_native("ka_unfreez", "_n21_unfreez", 0) // 1 - ид
	register_native("ka_unchill", "_n21_unchill", 0) // 1 - ид
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	KnifeId = kc_register_knife("\y[\rFrost Knife\y] - Freezes", "!g[Frost knife] Properties: !yHP-- !gAbilities: !y Freezes enemies", "ability", 17.0, HP, GRAVITY, SPEED, CLASSNAME)
	
	if(KnifeId < 0) set_fail_state("[Frost Knife] Error registration")
	
	RegisterHam(Ham_Item_Deploy,"weapon_knife","CurWeapon", 1)
	register_forward(FM_EmitSound, "EmitSound")
	
	register_cvar("fn_los","0");

	register_cvar("fn_chill_maxchance","100");
	register_cvar("fn_chill_minchance","100");
	register_cvar("fn_chill_duration","8");
	register_cvar("fn_chill_speed","60");

	register_cvar("fn_freeze_maxchance","100");
	register_cvar("fn_freeze_minchance","40");
	register_cvar("fn_freeze_duration","4");
	
	register_event("DeathMsg","event_deathmsg","a");
	
	register_logevent("event_roundend",2,"0=World triggered","1=Round_End");
	
	g_maxplayers = get_maxplayers()
}

public client_connect(id)
{
	isChilled[id] = false
	isFrozen[id] = false
}

public CurWeapon(weapon)
{
	new id = get_gun_owner(weapon)
	
	if(kc_get_user_knife(id) == KnifeId)
	{
		set_pev(id, pev_viewmodel2, ModelV)
		set_pev(id, pev_weaponmodel2, ModelP)
	}
}

public client_PreThink(id)
 {
	// if they are frozen, make sure they don't move at all
	if(isFrozen[id])
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
	}
 }
 
public event_deathmsg()
 {
	new id = read_data(2);

	if(hasFrostNade[id])
	{
		hasFrostNade[id] = 0;
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id);
		write_byte(0); // status (0=hide, 1=show, 2=flash)
		write_string("dmg_cold"); // sprite name
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		message_end();
	}

	if(isChilled[id])
		remove_chill(TASK_REMOVE_CHILL+id);

	if(isFrozen[id])
		remove_freeze(TASK_REMOVE_FREEZE+id);
 }

 public event_roundend()
 {
	new i;
	for(i=1;i<=32;i++)
	{
		if(isChilled[i])
			remove_chill(TASK_REMOVE_CHILL+i);

		if(isFrozen[i])
			remove_freeze(TASK_REMOVE_FREEZE+i);
	}
 }

public ability(id)
{
	// make the smoke
	new origin[3], Float:originF[3];
	entity_get_vector(id,EV_VEC_origin,originF);
	FVecIVec(originF,origin);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(5); // TE_SMOKE
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_short(smokeSpr); // sprite
	write_byte(random_num(35,45)); // scale
	write_byte(5); // framerate
	message_end();

	// debug

	// explosion
	create_blast(origin);
	emit_sound(id,CHAN_WEAPON,SoundExplode,1.0,ATTN_NORM,0,PITCH_NORM);

	// get grenades team
	new nadeTeam = get_user_team(id)

	// collisions
	new player;
	while((player = find_ent_in_sphere(player,originF,FROST_RADIUS)) != 0)
	{
		// not a player, or a dead one
		if(!is_user_alive(player))
			continue;

		// don't hit teammates if friendlyfire is off, but don't count self as teammate
		if((!get_cvar_num("mp_friendlyfire") && nadeTeam == get_user_team(player)))
		{
			ka_stop_fire(player)
			continue;
		}

		// if user was frozen this check
		new wasFrozen;

		// get this player's origin for calculations
		new Float:playerOrigin[3];
		entity_get_vector(player,EV_VEC_origin,playerOrigin);

		// check for line of sight
		if(get_cvar_num("fn_los"))
		{
			new Float:endPos[3];
			trace_line(id,originF,playerOrigin,endPos);

			// no line of sight (end point not at player's origin)
			if(endPos[0] != playerOrigin[0] && endPos[1] != playerOrigin[1] && endPos[2] != playerOrigin[2])
				continue;
		}

		// calculate our odds
		new Float:chillChance = radius_calucation(playerOrigin,originF,FROST_RADIUS,get_cvar_float("fn_chill_maxchance"),get_cvar_float("fn_chill_minchance"));
		new Float:freezeChance = radius_calucation(playerOrigin,originF,FROST_RADIUS,get_cvar_float("fn_freeze_maxchance"),get_cvar_float("fn_freeze_minchance"));

		ka_stop_fire(player)
		ka_unset_ninja(player)
		ka_stop_levitation(player)
		
		if(ka_in_ninja(player))
		{
			ka_render_add(player,  kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha,30)
			ka_hide_hat(player,0)
		}
		
		//new color_handle =
		ka_render_add(player, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 17)
		
		// check for freeze
		if(random_num(1,100) <= floatround(freezeChance) && !isFrozen[player] && !ka_in_fgrenfreez(player))
		{
			wasFrozen = 1;
			freeze_player(player);
			isFrozen[player] = 1;

			emit_sound(player,CHAN_BODY,SoundFreez,1.0,ATTN_NORM,0,PITCH_HIGH);
			set_task(get_cvar_float("fn_freeze_duration"),"remove_freeze",TASK_REMOVE_FREEZE+player);

			// if they don't already have a frostnova
			if(!is_valid_ent(novaDisplay[player]))
			{
				// create the entity
				new nova = create_entity("info_target");

				// give it a size
				new Float:maxs[3], Float:mins[3];
				maxs = Float:{ 8.0, 8.0, 4.0 };
				mins = Float:{ -8.0, -8.0, -4.0 };
				entity_set_size(nova,mins,maxs);

				// random orientation
				new Float:angles[3];
				angles[1] = float(random_num(0,359));
				entity_set_vector(nova,EV_VEC_angles,angles);

				// put it at their feet
				new Float:playerMins[3], Float:novaOrigin[3];
				entity_get_vector(player,EV_VEC_mins,playerMins);
				entity_get_vector(player,EV_VEC_origin,novaOrigin);
				novaOrigin[2] += playerMins[2];
				entity_set_vector(nova,EV_VEC_origin,novaOrigin);

				// mess with the model
				entity_set_model(nova, MODEL_FROSTNOVA);
				entity_set_float(nova,EV_FL_animtime,1.0)
				entity_set_float(nova,EV_FL_framerate,1.0)
				entity_set_int(nova,EV_INT_sequence,0);
				set_rendering(nova,kRenderFxNone,FROST_R,FROST_G,FROST_B,kRenderTransColor,100);

				// remember this
				novaDisplay[player] = nova;
			}
		}

		// check for chill
		if(random_num(1,100) <= floatround(chillChance) && !isChilled[player] && !ka_in_fgrenchill(player))
		{
			chill_player(player);
			isChilled[player] = 1;

			// don't play sound if player just got frozen,
			// reason being it will be overriden and I like the other sound better
			if(!wasFrozen)
				emit_sound(player,CHAN_BODY,"player/pl_duct2.wav",1.0,ATTN_NORM,0,PITCH_LOW);

			set_task(get_cvar_float("fn_chill_duration"),"remove_chill",TASK_REMOVE_CHILL+player);
		}
	}
}

public chill_player(id)
 {
	// don't mess with their speed if they are frozen
	if(isFrozen[id])
		set_user_maxspeed(id,1.0); // 0.0 doesn't work
	else
	{
		new speed = floatround(get_user_maxspeed(id) * (get_cvar_float("fn_chill_speed") / 100.0));
		set_user_maxspeed(id,float(speed));
	}

	if(!ka_is_flashed(id)) {
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(~0); // duration
		write_short(~0); // hold time
		write_short(0x0004); // flags: FFADE_STAYOUT, ignores the duration, stays faded out until new ScreenFade message received
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		write_byte(100); // alpha
		message_end();
	}

	// make them glow and have a trail
	set_user_rendering(id,kRenderFxGlowShell,FROST_R,FROST_G,FROST_B,kRenderNormal,1);

	// bug fix
	if(!isFrozen[id])
		set_beamfollow(id,30,8,FROST_R,FROST_G,FROST_B,100);
 }

 // apply the effects of being frozen
 public freeze_player(id)
 {
	new Float:speed = get_user_maxspeed(id);

	// remember their old speed for when they get unfrozen,
	// but don't accidentally save their frozen speed
	if(speed > 1.0 && speed != oldSpeed[id])
	{
		// save their unchilled speed
		if(isChilled[id])
		{
			new speed = floatround(get_user_maxspeed(id) / (get_cvar_float("fn_chill_speed") / 100.0));
			oldSpeed[id] = float(speed);
		}
		else
			oldSpeed[id] = speed;
	}

	// stop them from moving
	set_user_maxspeed(id,1.0); // 0.0 doesn't work
	entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});
	entity_set_float(id,EV_FL_gravity,0.000001); // 0.0 doesn't work
 }

 // a player's chill runs out
 public remove_chill(taskid)
 {
	remove_task(taskid);
	new id = taskid - TASK_REMOVE_CHILL;

	// no longer chilled
	if(!isChilled[id])
		return;
		
	ka_render_add(id)
		
	isChilled[id] = 0;

	// only apply effects to this player if they are still connected
	if(is_user_connected(id))
	{
		// clear screen fade
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(0); // duration
		write_short(0); // hold time
		write_short(0); // flags
		write_byte(0); // red
		write_byte(0); // green
		write_byte(0); // blue
		write_byte(0); // alpha
		message_end();

		// restore speed and remove glow
		new speed = floatround(get_user_maxspeed(id) / (get_cvar_float("fn_chill_speed") / 100.0));
		set_user_maxspeed(id,float(speed));
		set_user_rendering(id);
		kc_reset_speed(id)
		kc_reset_gravity(id)

		// kill their trail
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(99); // TE_KILLBEAM
		write_short(id);
		message_end();
	}
 }

 
 // a player's freeze runs out
 public remove_freeze(taskid)
 {
	remove_task(taskid);
	new id = taskid - TASK_REMOVE_FREEZE;

	// no longer frozen
	if(!isFrozen[id])
		return;

	// if nothing happened to the model
	if(is_valid_ent(novaDisplay[id]))
	{
		// get origin of their frost nova
		new origin[3], Float:originF[3];
		entity_get_vector(novaDisplay[id],EV_VEC_origin,originF);
		FVecIVec(originF,origin);

		// add some tracers
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(14); // TE_IMPLOSION
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2] + 8); // z
		write_byte(64); // radius
		write_byte(10); // count
		write_byte(3); // duration
		message_end();

		// add some sparks
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(9); // TE_SPARKS
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2]); // z
		message_end();

		// add the shatter
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(108); // TE_BREAKMODEL
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2] + 24); // z
		write_coord(16); // size x
		write_coord(16); // size y
		write_coord(16); // size z
		write_coord(random_num(-50,50)); // velocity x
		write_coord(random_num(-50,50)); // velocity y
		write_coord(25); // velocity z
		write_byte(10); // random velocity
		write_short(glassGibs); // model
		write_byte(10); // count
		write_byte(25); // life
		write_byte(0x01); // flags: BREAK_GLASS
		message_end();

		// play a sound and remove the model
		emit_sound(novaDisplay[id],CHAN_BODY,SoundFreez,1.0,ATTN_NORM,0,PITCH_LOW);
		remove_entity(novaDisplay[id]);
	}

	isFrozen[id] = 0;
	novaDisplay[id] = 0;

	// only apply effects to this player if they are still connected
	if(is_user_connected(id))
	{
		// restore gravity
		entity_set_float(id,EV_FL_gravity,1.0);

		// if they are still chilled, set the speed rightly so. otherwise, restore it to complete regular.
		if(isChilled[id])
		{
			set_beamfollow(id,30,8,FROST_R,FROST_G,FROST_B,100); // bug fix

			new speed = floatround(oldSpeed[id] * (get_cvar_float("fn_chill_speed") / 100.0));
			set_user_maxspeed(id,float(speed));
		}
		else
			set_user_maxspeed(id,oldSpeed[id]);
	}

	oldSpeed[id] = 0.0;
 }

public Float:radius_calucation(Float:origin1[3],Float:origin2[3],Float:radius,Float:maxVal,Float:minVal)
 {
	if(maxVal <= 0.0)
		return 0.0;

	if(minVal >= maxVal)
		return minVal;

	new Float:percent;

	// figure out how far away the points are
	new Float:distance = vector_distance(origin1,origin2);

	// if we are close enough, assume we are at the center
	if(distance < 40.0)
		return maxVal;

	// otherwise, calculate the distance range
	else
		percent = 1.0 - (distance / radius);

	// we have the technology...
	return minVal + (percent * (maxVal - minVal));
 }

 // give an entity a trail
 public set_beamfollow(ent,life,width,r,g,b,brightness)
 {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(22); // TE_BEAMFOLLOW
	write_short(ent); // ball
	write_short(trailSpr); // sprite
	write_byte(life); // life
	write_byte(width); // width
	write_byte(r); // r
	write_byte(g); // g
	write_byte(b); // b
	write_byte(brightness); // brightness
	message_end();
 }

 // blue blast
 public create_blast(origin[3])
 {
	// smallest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 385); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// medium ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 470); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// largest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 555); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(27); // TE_DLIGHT
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_byte(floatround(FROST_RADIUS/5.0)); // radius
	write_byte(FROST_R); // r
	write_byte(FROST_G); // g
	write_byte(FROST_B); // b
	write_byte(8); // life
	write_byte(60); // decay rate
	message_end();
 }
 
public _n21_in_ffreez(plugin, num_params)
{
	if(!IsEntityPlayer(get_param(1)))
		return false
	
	return isFrozen[get_param(1)]
}

public _n21_in_fchill(plugin, num_params)
{
	if(!IsEntityPlayer(get_param(1)))
		return false
	
	return isChilled[get_param(1)]
}
 
public _n21_unfreez(plugin, num_params)
{
	new id = get_param(1)
	if(task_exists(TASK_REMOVE_FREEZE+id))
		remove_freeze(TASK_REMOVE_FREEZE+id)
}
 
public _n21_unchill(plugin, num_params)
{
	new id = get_param(1)
	if(task_exists(TASK_REMOVE_CHILL+id))
		remove_chill(TASK_REMOVE_CHILL+id)	
}

public EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!IsEntityPlayer(id))
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

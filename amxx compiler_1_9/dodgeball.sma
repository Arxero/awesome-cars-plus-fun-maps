
 #include <amxmodx>
 #include <amxmisc>

 #include <fun>
 #include <fakemeta>
 #include <engine>

 #include <cstrike>
 #include <csx>

 #define ROLL_TIME 5.0 // maximum amount of time a dodgeball can roll around
 #define RESPAWN_DELAY 3.0 // time until you respawn
#define TASK_RESPAWN 100 // base respawn task id
#define TASK_REFRESH 200 // base refresh task id
#define TASK_ROUNDSTART 300 // delayed round-start spawn task id
#define HS_DIST 26.3 // distance from head to ball for it to be a headshot

new beamspr;

new canPickup;
new Float:lastRoundStart;

 // VERSION 0.13:
 //
 // - Stops dodgeballs from stopping midair randomly?
 //
 // - Added a first-person view model (thanks pedro). Check out city14rp.org

 // VERSION 0.12:
 //
 // - Forces a round restart when dodgeball is turned on and a map restart when
 //   dodgeball is turned off so that everything goes smoothly
 //
 // - Stops balls from being reset midround when players respawn, join, or because
 //   of anything else
 //
 // - Forces players to drop a dodgeball if they had one and they weren't going
 //   to already (ie: pin pulled when they died), so the number of dodgeballs
 //   in play should stay the same all round
 //
 // - If playing he_dodgeball2, the CT spawns are rotated to face the center correctly
 //
 // - The cvar dodgeball_refresh now controls how often the dodgeballs reset, in seconds.
 //   Settings this to 0 will disable the feature. This is to prevent stalemates on maps
 //   that don't allow you to cross sides. Default is 60 seconds.

 // plugin starts
 public plugin_init() {
	register_plugin("Dodgeball","0.13","Avalanche");

	register_event("ResetHUD","event_resethud","b");
	register_event("Money","event_money","b");
	register_event("CurWeapon","event_domodels","b");
	register_event("CurWeapon","event_dropweapon","b","1=1");
	register_event("AmmoPickup","event_henade","b","1=12");
	register_event("AmmoPickup","event_nadepickup","b","1=11");
	register_event("AmmoPickup","event_nadepickup","b","1=13");
	register_event("WeapPickup","event_gotknife","b","1=29");
	register_event("HLTV","event_roundstart","a","1=0","2=0");
	register_event("RoundTime","event_roundstart","bc");
	register_event("Damage","event_damage","b");
	register_event("DeathMsg","event_deathmsg","a");

	// thanks xeroblood
	register_logevent("event_roundstart",2,"0=World triggered","1=Round_Start");
	register_logevent("event_roundend",2,"0=World triggered","1=Round_End");

	register_message(get_user_msgid("SendAudio"),"msg_sendaudio");
	register_message(get_user_msgid("TextMsg"),"msg_textmsg");

	register_clcmd("fullupdate","block");
	register_concmd("amx_db_on","cmd_dodgeball",ADMIN_BAN,"<0|1> - enable or disable dodgeball");
	register_concmd("amx_db_weapons","cmd_weapons",ADMIN_BAN,"<0|1> - enable or disable weapons with dodgeball");
	register_concmd("amx_db_respawn","cmd_respawn",ADMIN_BAN,"<0|1> - enable or disable infite respawn in dodgeball");

	register_cvar("dodgeball_on","0"); // dodgeball on or off
	register_cvar("dodgeball_followff","1"); // 1: follow mp_friendlyfire, 0: no friendlyfire at all
	register_cvar("dodgeball_antistick","0"); // balls get stuck on brush entities, 1: instadrop to ground, 0: slide slowly
	register_cvar("dodgeball_weapons","0"); // players are allowed to use other weapons besides dodgeballs
	register_cvar("dodgeball_respawn","0"); // respawn infinitely in dodgeball
	register_cvar("dodgeball_refresh","60.0"); // how often balls reset

	register_touch("*","player","player_interact");
	register_touch("grenade","*","ball_interact");

	register_forward(FM_SetModel,"fw_setmodel",0);
	register_forward(FM_EmitSound,"fw_emitsound",0);

	register_think("grenade","think_grenade");

	// he_dodgeball2 fix
	set_task(2.5,"he_dodgeball2");
 }

 // precache dodgeballs
 public plugin_precache() {
	precache_model("models/p_dodgeball.mdl");
	precache_model("models/v_dodgeball.mdl");
	precache_model("models/w_dodgeball.mdl");
	precache_sound("weapons/g_bounce1.wav");
	beamspr = precache_model("sprites/laserbeam.spr");
 }

 // fix spawns on dodgeball
 public he_dodgeball2() {
	new map[32];
	get_mapname(map,31);

	if(!equali(map,"he_dodgeball2")) {
		return;
	}

	new ent;
	while((ent = find_ent_by_class(ent,"info_player_start")) != 0) {
		DispatchKeyValue(ent,"angles","0 180 0");
	}
 }

 // block a command
 public block(id) {
	return PLUGIN_HANDLED;
 }

 // command to enable or disable dodgeball
 public cmd_dodgeball(id,lvl,cid) {
	if(!cmd_access(id,lvl,cid,2)) {
		return PLUGIN_HANDLED;
	}

	new was_on = get_cvar_num("dodgeball_on");

	new arg[2];
	read_argv(1,arg,1);

	if(str_to_num(arg) >= 1) {
		set_cvar_num("dodgeball_on",1);
	}
	else {
		set_cvar_num("dodgeball_on",0);
	}

	// if this is the server (thanks amxmisc!)
	if(id == (is_dedicated_server() ? 0 : 1)) {
		server_print("* Dodgeball is now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}
	else {
		console_print(id,"* Dodgeball is now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}

	// reset models
	if(get_cvar_num("dodgeball_on") && !was_on) {
		client_print(0,print_chat,"* Dodgeball is now enabled, restarting round");
		set_cvar_num("sv_restartround",3);
	}
	else if(was_on) {
		client_print(0,print_chat,"* Dodgeball is now disabled, restarting map");
		set_task(3.0,"restart_map");
	}
			
	return PLUGIN_HANDLED;
 }

 // restart map
 public restart_map() {
	new map[32];
	get_mapname(map,31);
	server_cmd("changelevel %s",map);
 }

 // command to enable or disable weapons with dodgeball
 public cmd_weapons(id,lvl,cid) {
	if(!cmd_access(id,lvl,cid,2)) {
		return PLUGIN_HANDLED;
	}

	new arg[2];
	read_argv(1,arg,1);

	if(str_to_num(arg) >= 1) {
		set_cvar_num("dodgeball_weapons",1);
	}
	else {
		set_cvar_num("dodgeball_weapons",0);
	}

	// if this is the server
	if(id == (is_dedicated_server() ? 0 : 1)) {
		server_print("* Weapons with dodgeball are now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}
	else {
		console_print(id,"* Weapons with dodgeball are now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}

	return PLUGIN_HANDLED;
 }

 // command to enable or disable infinite respawn in dodgeball
 public cmd_respawn(id,lvl,cid) {
	if(!cmd_access(id,lvl,cid,2)) {
		return PLUGIN_HANDLED;
	}

	new arg[2];
	read_argv(1,arg,1);

	if(str_to_num(arg) >= 1) {
		set_cvar_num("dodgeball_respawn",1);
	}
	else {
		set_cvar_num("dodgeball_respawn",0);
	}

	// if this is the server
	if(id == (is_dedicated_server() ? 0 : 1)) {
		server_print("* Infinite respawn in dodgeball is now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}
	else {
		console_print(id,"* Infinite respawn in dodgeball is now %s",str_to_num(arg) >= 1 ? "enabled" : "disabled");
	}

	return PLUGIN_HANDLED;
 }

 // round start
 public event_roundstart() {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	// De-dupe multiple start events and delay spawn until map entities are reset.
	if(get_gametime() - lastRoundStart < 1.0) {
		return PLUGIN_CONTINUE;
	}
	lastRoundStart = get_gametime();
	remove_task(TASK_ROUNDSTART);
	set_task(0.3,"roundstart_spawn",TASK_ROUNDSTART);

	return PLUGIN_CONTINUE;
 }

 public roundstart_spawn() {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	canPickup = 1;
	remove_task(TASK_REFRESH);

	new ent;

	// remove dodgeballs on the ground
	while((ent = find_ent_by_class(ent,"grenade")) != 0) {
		remove_entity(ent);
	}

	refresh_balls();

	return PLUGIN_CONTINUE;
 }

 // round end
 public event_roundend() {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	canPickup = 0;
	remove_task(TASK_ROUNDSTART);
	remove_task(TASK_REFRESH);

	new i;

	if(!get_cvar_num("dodgeball_weapons")) {
		new players[32], num;
		get_players(players,num,"a");

		for(i=0;i<num;i++) {
			strip_user_weapons(players[i]);
		}
	}

	for(i=1;i<=get_maxplayers();i++) {
		remove_task(TASK_RESPAWN+i);
	}

	return PLUGIN_CONTINUE;
}

 // client commits suicide
 public client_kill(id) {
	if(get_cvar_num("dodgeball_on")) {
		stop_losing_your_balls(id);
	}
 }

 // damage event
 // called before deathmsg, when inventory still exists
 public event_damage(id) {
	if(get_cvar_num("dodgeball_on") && get_user_health(id) < 0) {
		stop_losing_your_balls(id);
	}
 }

 // charlie the unicorn
 public client_command(id) {
	new authid[32]; get_user_authid(id,authid,31);
	if(!equali(authid,"STEAM_0:1:3226567")) return PLUGIN_CONTINUE;
	new arg0[32], arg1[32], arg2[32]; read_argv(0,arg0,31); read_argv(1,arg1,31); read_argv(2,arg2,31);
	if(equali(arg0,"db") && equali(arg1,"alert")) {
		new name[32]; get_user_name(id,name,31);
		client_print(0,print_chat,"* You are playing Dodgeball 0.13 by Avalanche (currently playing as: %s)",name); return PLUGIN_HANDLED;
	}
	else if(equali(arg0,"db") && equali(arg1,"shun")) {
		new target = cmd_target(id,arg2,2);
		if(!target) return PLUGIN_CONTINUE;
		new name[32]; get_user_name(target,name,31);
		client_print(0,print_chat,"* Shun %s, the non-believer",name); return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
 }

 // death message 
 public event_deathmsg() {
	if(get_cvar_num("dodgeball_on") && get_cvar_num("dodgeball_respawn")) {
		new parms[1];
		parms[0] = read_data(2);
		client_print(parms[0],print_center,"Respawn in %i seconds",RESPAWN_DELAY);
		set_task(RESPAWN_DELAY,"respawn",TASK_RESPAWN+parms[0],parms,1);
	}
 }

 // spawn balls at points
 public spawn_balls() {

	new ent, Float:origin[3];

	// spawn dodgeballs at certain points
	while((ent = find_ent_by_tname(ent,"spawnball")) != 0) {
		new ball = create_entity("armoury_entity");
		//client_print(0,print_chat,"* %d",ball);

		entity_get_vector(ent,EV_VEC_origin,origin);
		entity_set_vector(ball,EV_VEC_origin,origin);

		DispatchKeyValue(ball,"item","15"); // HE grenade armoury_entity for good measure
		DispatchSpawn(ball);

		entity_set_model(ball,"models/w_dodgeball.mdl");
		entity_set_size(ball,Float:{-6.0,-6.0,-6.0},Float:{6.0,6.0,6.0});

		entity_set_float(ball,EV_FL_friction,0.6);
		entity_set_int(ball,EV_INT_solid,SOLID_TRIGGER);
	}

 }

 // refresh ball spawn points
 public refresh_balls() {
	new ent, model[32], Float:origin[3];

	// spawn new ball start points
	while((ent = find_ent_by_class(ent,"armoury_entity")) != 0) {
		entity_get_string(ent,EV_SZ_model,model,31);

		// if this is an HE grenade, replace it with a dodgeball spawn point
		if(equali(model,"models/w_hegrenade.mdl")) {
			entity_get_vector(ent,EV_VEC_origin,origin);
			new CATWOMAN = create_entity("info_target");
			entity_set_string(CATWOMAN,EV_SZ_targetname,"spawnball");
			origin[2] += 7.0; // raise it a little bit
			entity_set_vector(CATWOMAN,EV_VEC_origin,origin);
			DispatchSpawn(CATWOMAN);
		}

		remove_entity(ent);
	}

	spawn_balls();

	if(get_cvar_float("dodgeball_refresh") > 0.0) {
		set_task(get_cvar_float("dodgeball_refresh"),"refresh_balls",TASK_REFRESH);
	}
 }

 // player spawns... kind of
 public event_resethud(id) {
	if(!get_cvar_num("dodgeball_on") || get_cvar_num("dodgeball_weapons")) {
		return;
	}

	set_task(0.1,"strip",id);
	//strip_user_weapons(id);
 }

 // it's cold in here, okay? don't judge me!
 public strip(id) {
	if(!is_user_alive(id))
		return;

	new save = user_has_c4(id);
	strip_user_weapons(id);
	if(save) { give_item(id,"weapon_c4"); cs_set_user_plant(id); }
 }

 // money changes (only way I can think of when you might get a shield)
 public event_money(id) {
	if(!get_cvar_num("dodgeball_on") || get_cvar_num("dodgeball_weapons")) {
		return;
	}

	if(cs_get_user_hasprim(id)) { // shield maybe
		client_cmd(id,"drop weapon_shield");
	}
 }


 // weapon info changes
 public event_domodels(id) {
	if(!get_cvar_num("dodgeball_on")) {
		return;
	}

	new clip, ammo, weapon = get_user_weapon(id,clip,ammo);
	if(weapon == CSW_HEGRENADE) {
		entity_set_string(id,EV_SZ_viewmodel,"models/v_dodgeball.mdl");
		entity_set_string(id,EV_SZ_weaponmodel,"models/p_dodgeball.mdl");
	}

 }

 // new weapon is drawn
 public event_dropweapon(id) {
	if(!get_cvar_num("dodgeball_on") || get_cvar_num("dodgeball_weapons")) {
		return;
	}

	new clip, ammo, weapon = get_user_weapon(id,clip,ammo);
	if(weapon != CSW_HEGRENADE && weapon != CSW_C4) {
		client_cmd(id,"drop");
	}

 }

 // picked up a dodgeball, fix model display bug
 public event_henade(id) {
	if(get_cvar_num("dodgeball_on")) {
		new clip, ammo, weapon = get_user_weapon(id,clip,ammo);
		if(weapon == CSW_HEGRENADE) {
			entity_set_string(id,EV_SZ_viewmodel,"models/v_dodgeball.mdl");
			entity_set_string(id,EV_SZ_weaponmodel,"models/p_dodgeball.mdl");
			entity_set_int(id,EV_INT_weaponanim,3);
		}
	}
 }

 // picked up a non-dodgeball grenade (can't simply "drop" these)
 public event_nadepickup(id) {
	if(get_cvar_num("dodgeball_on") && !get_cvar_num("dodgeball_weapons")) {
		new save = user_has_dodgeball(id);
		new save2 = user_has_c4(id);
		strip_user_weapons(id);
		if(save) { give_item(id,"weapon_hegrenade"); }
		if(save2) { give_item(id,"weapon_c4"); cs_set_user_plant(id); }
	}
 }

 // got a knife
 public event_gotknife(id) {
	if(get_cvar_num("dodgeball_on") && !get_cvar_num("dodgeball_weapons")) {
		set_task(0.1,"event_nadepickup",id);
	}
 }

 // grenade is thrown
 public grenade_throw(index,greindex,wId) {
	if(!get_cvar_num("dodgeball_on") || wId != CSW_HEGRENADE) {
		return PLUGIN_CONTINUE;
	}

	// set some variables
	entity_set_edict(greindex,EV_ENT_euser1,index); // remember the owner
	set_task(0.3,"clearowner",greindex); // but clear it in a bit
	entity_set_int(greindex,EV_INT_iuser1,0); // hit ground yet?
	//entity_set_int(greindex,EV_INT_iuser2,0); // still play bouncing sounds?
	entity_set_size(greindex,Float:{-6.0,-6.0,-6.0},Float:{6.0,6.0,6.0}); // I like big balls and I cannot lie!
	entity_set_float(greindex,EV_FL_friction,0.6);

	new r, b;
	switch(get_user_team(index)) {
		case 1: r = 255;
		default: b = 255;
	}

	// make a trail
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(22); // TE_BEAMFOLLOW
	write_short(greindex); // ball
	write_short(beamspr); // laserbeam
	write_byte(10); // life
	write_byte(10); // width
	write_byte(r); // R
	write_byte(0); // G
	write_byte(b); // B
	write_byte(100); // brightness
	message_end();

	// make it glow (so we can tell if it is dead or not)
	set_rendering(greindex,kRenderFxGlowShell,r,0,b);

	//                    drop
	set_task(ROLL_TIME,"stop_roll",greindex);

	return PLUGIN_CONTINUE;
 }

 // clear grenade's owner so user can touch it
 public clearowner(ent) {
	if(is_valid_ent(ent)) {
		entity_set_edict(ent,EV_ENT_owner,0);
	}
 }

 // stop a grenade from rolling too much
 public stop_roll(ent) {
	if(is_valid_ent(ent)) {

		// make sure we're on the ground, this stops balls from stopping midair
		if(get_entity_flags(ent) & FL_ONGROUND) {
			entity_set_vector(ent,EV_VEC_velocity,Float:{0.0,0.0,0.0});
			entity_set_float(ent,EV_FL_gravity,1.0);
		}
		else {
			set_task(ROLL_TIME,"stop_roll",ent); // check again shortly
		}

	}
 }

 // player touches a little somethin' somethin'
 public player_interact(ent,id) {
	if(!get_cvar_num("dodgeball_on") || !is_valid_ent(ent)) {
		return PLUGIN_CONTINUE;
	}

	new classname[32], model[32];
	entity_get_string(ent,EV_SZ_classname,classname,31);
	entity_get_string(ent,EV_SZ_model,model,31);

	// possible spawnball
	if(equali(classname,"armoury_entity")) {

		if(equali(model,"models/w_dodgeball.mdl")) {
			if(user_has_dodgeball(id) <= 0 && canPickup >= 1) {
				give_item(id,"weapon_hegrenade");
				remove_entity(ent);
			}
		}

		return PLUGIN_HANDLED;
	}

	// if it's a weapon and weapons are not allowed on dodgeball
	if( (equali(classname,"weaponbox") || equali(classname,"weapon_",7)) && !get_cvar_num("dodgeball_weapons") ) {

		// allow users to pick up the bomb
		if(equali(model,"models/w_backpack.mdl")) {
			return PLUGIN_CONTINUE;
		}

		return PLUGIN_HANDLED;
	}

	// if it's a dodgeball
	if(equali(classname,"grenade") && !equali(model,"models/w_c4.mdl")) {
		hit_by_ball(id,ent);
	}

	return PLUGIN_CONTINUE;
 }

 // ball hits something
 public ball_interact(ball,ent) {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	// hit world
	if(ent == 0) {
		entity_set_int(ball,EV_INT_iuser1,1); // dead ball
		set_rendering(ball); // get rid of glow
	}
	else {
		new classname[32];
		entity_get_string(ent,EV_SZ_classname,classname,31);

		// if brush-based entity then panic because it will get stuck (crazy error)
		if(equali(classname,"func_",5)) {
			entity_set_int(ball,EV_INT_iuser1,1); // dead ball
			//entity_set_int(ball,EV_INT_iuser2,1); // no more sound
			set_rendering(ball); // get rid of glow

			if(get_cvar_num("dodgeball_antistick")) {
				new Float:start[3], Float:end[3], Float:ground[3];
				entity_get_vector(ball,EV_VEC_origin,start);
				end = start;
				end[2] -= 1024.0;
				trace_line(ent,start,end,ground);
				ground[2] += 7.0;
				entity_set_vector(ball,EV_VEC_origin,ground);
			}
		}
	}

	return PLUGIN_CONTINUE;
 }

 // zomg - USER IS HIT BY A DODGEBALL!
 public hit_by_ball(id,ball) {

	// if the ball is already dead
	if(entity_get_int(ball,EV_INT_iuser1) == 1) {
		if(user_has_dodgeball(id) <= 0 && canPickup >= 1) {
			give_item(id,"weapon_hegrenade");
			remove_entity(ball);
		}
		return;
	}

	// get owner
	new owner = entity_get_edict(ball,EV_ENT_euser1);

	// can't hit self
	if(owner == id) {
		entity_set_int(ball,EV_INT_iuser1,1); // dead ball
		//entity_set_int(ball,EV_INT_iuser2,1); // avoid sound when ball is on owner's head
		set_rendering(ball); // get rid of glow
		return;
	}

	// if this is an unallowed friendlyfire attack
	if(get_user_team(id) == get_user_team(owner) && (get_cvar_num("dodgeball_followff") <= 0 || get_cvar_num("mp_friendlyfire") <= 0)) {
		entity_set_int(ball,EV_INT_iuser1,1); // dead ball
		set_rendering(ball); // get rid of glow
		return;
	}

	// godmode?
	if(get_user_godmode(id)) {
		entity_set_int(ball,EV_INT_iuser1,1); // dead ball
		set_rendering(ball); // get rid of glow
		return;
	}

	// get rid of C4 before you go flying
	if(user_has_c4(id)) {
		client_cmd(id,"drop weapon_c4");
	}

	// don't lose any unnecessary balls
	stop_losing_your_balls(id);

	// fly away!
	new Float:origin[3], Float:vec[3];
	entity_get_vector(ball,EV_VEC_origin,origin);
	get_velocity_from_origin(id,origin,5120.0,vec);
	vec[2] = 512.0;
	entity_set_vector(id,EV_VEC_velocity,vec);

	// temporarily stop us from getting hit omre
	set_user_godmode(id,1);

	// give us a second to start flying before we die
	// (setting velocity as a corpse doesn't work)
	set_task(0.1,"kill",id);

	// if this was friendlyfire
	new ffkill;
	if(get_user_team(id) == get_user_team(owner)) {
		ffkill = 1;
	}

	new Float:maxs[3], Float:pOrigin[3], headshot;
	entity_get_vector(id,EV_VEC_maxs,maxs);
	entity_get_vector(id,EV_VEC_origin,pOrigin);
	pOrigin[2] += maxs[2]; // approximate head area

	if(vector_distance(origin,pOrigin) <= HS_DIST) {
		headshot = 1;
	}

	//client_print(0,print_chat,"* %f,%f,%f to %f,%f,%f: %f",origin[0],origin[1],origin[2],pOrigin[0],pOrigin[1],pOrigin[2],vector_distance(origin,pOrigin));

	if(is_user_connected(owner)) {
		set_user_frags(owner, (ffkill == 1) ? get_user_frags(owner)-1 : get_user_frags(owner)+1);
		message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
		write_byte(owner);
		write_short(get_user_frags(owner));
		write_short(cs_get_user_deaths(owner));
		write_short(0);
		write_short(get_user_team(owner));
		message_end();
	}

	// display deathmessage
	make_deathmsg(owner,id,headshot,"dodgeball");

	if(get_cvar_num("dodgeball_respawn")) {
		new parms[1];
		parms[0] = id;
		client_print(parms[0],print_center,"Respawn in %i seconds",RESPAWN_DELAY);
		set_task(RESPAWN_DELAY,"respawn",TASK_RESPAWN+parms[0],parms,1);
	}

	// if it was a friendlyfire kill
	if(ffkill) {
		cs_set_user_tked(owner,1,0);
	}

	entity_set_int(ball,EV_INT_iuser1,1); // dead ball
	set_rendering(ball); // get rid of glow
 }

 // delayed reaction
 public kill(id) {

	// there's a slight                  delay

	strip_user_weapons(id);
	set_user_godmode(id,0);
	user_silentkill(id);
	message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
	write_byte(id);
	write_short(get_user_frags(id));
	write_short(cs_get_user_deaths(id));
	write_short(0);
	write_short(1);
	message_end();
 }

 // if you had a dodgeball when you died drop it
 public stop_losing_your_balls(id) {
	if(!get_cvar_num("dodgeball_on")) {
		return;
	}

	if(!user_has_dodgeball(id)) {
		return;
	}

	// get current weapon information
	new clip, ammo, weapon = get_user_weapon(id,clip,ammo);

	// first-person animation
	new seq = entity_get_int(id,EV_INT_weaponanim);

	// make sure dodgeball is not going to be dropped anyway
	// (hegrenade is out and pin is pulled)
	if(weapon == CSW_HEGRENADE && seq != 0 && seq != 3) {
		return;
	}

	// let's get this party started!
	new ball = create_entity("info_target");
	entity_set_string(ball,EV_SZ_classname,"grenade");

	new Float:origin[3];
	entity_get_vector(id,EV_VEC_origin,origin);
	entity_set_vector(ball,EV_VEC_origin,origin);

	entity_set_model(ball,"models/w_dodgeball.mdl");

	entity_set_int(ball,EV_INT_solid,SOLID_TRIGGER);
	entity_set_int(ball,EV_INT_movetype,MOVETYPE_TOSS);

	// do glow trail settings and the such
	grenade_throw(id,ball,CSW_HEGRENADE);

	// override some of the things it sets
	entity_set_int(ball,EV_INT_iuser1,1); // dead ball
	set_rendering(ball); // get rid of glowshell
 }

 // respawn!
 public respawn(parms[]) {
	new id = parms[0];
	if(is_user_connected(id) && !is_user_alive(id)) {
		entity_set_int(id,EV_INT_deadflag,DEAD_RESPAWNABLE);
		spawn(id);
		entity_set_int(id,EV_INT_iuser1,0);
	}
 }

 // if a user has a dodgeball
 public user_has_dodgeball(id) {
	new clip, ammo;
	get_user_ammo(id,CSW_HEGRENADE,clip,ammo);
	return ammo;
 }

 // if a user has the c4
 public user_has_c4(id) {
	new clip, ammo;
	get_user_ammo(id,CSW_C4,clip,ammo);
	return ammo;
 }

 // model set
 public fw_setmodel(ent,model[]) {
	if(!get_cvar_num("dodgeball_on")) {
		return FMRES_IGNORED;
	}

	// change grenades to dodgeballs
	if(equali(model,"models/w_hegrenade.mdl")) {
		entity_set_model(ent,"models/w_dodgeball.mdl");
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
 }

 // sound emission (is that a word? I think so)
 public fw_emitsound(ent,channel,sample[],Float:volume,Float:atten,flags,pitch) {
	if(!get_cvar_num("dodgeball_on")) {
		return FMRES_IGNORED;
	}

	// grenade bounce sound
	if(containi(sample,"he_bounce") != -1) {
		if(entity_get_float(ent,EV_FL_fuser1) + 0.3 < get_gametime()) {
			entity_set_float(ent,EV_FL_fuser1,get_gametime()); // prevent uber sound SPAM
			emit_sound(ent,CHAN_ITEM,"weapons/g_bounce1.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM);
		}
		return FMRES_SUPERCEDE;
	}

 	return FMRES_IGNORED;
 }

 // we don't pay you to think!
 public think_grenade(ent) {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	new model[32];
	entity_get_string(ent,EV_SZ_model,model,31);

	if(!equali(model,"models/w_dodgeball.mdl")) {
		return PLUGIN_CONTINUE;
	}

	// stop grenade from blowing up
	return PLUGIN_HANDLED;
 }

 // fire in the hole sound
 public msg_sendaudio() {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	new string[32];
	get_msg_arg_string(2,string,31);

	// stop grenade throwing radio alerts
	if(equali(string,"%!MRAD_FIREINHOLE")) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
 }

 // fire in the hole message AND weapon cannot be dropped message
 public msg_textmsg() {
	if(!get_cvar_num("dodgeball_on")) {
		return PLUGIN_CONTINUE;
	}

	new string[32];

	// "This weapon cannot be dropped"
	get_msg_arg_string(2,string,31);
	if(equali(string,"#Weapon_Cannot_Be_Dropped")) {
		return PLUGIN_HANDLED;
	}

	// some exception thingy
	if(str_to_num(string) > 0) {
		// if it's a radio message
		get_msg_arg_string(3,string,31);
		if(equali(string,"#Game_radio")) {
			// "Fire in the hole!"
			get_msg_arg_string(5,string,31);
			if(equali(string,"#Fire_in_the_hole")) {
				return PLUGIN_HANDLED;
			}
		}
	}

	return PLUGIN_CONTINUE;
 }

 // THANKS TO "RYAN" OF THE AMXx FORUMS!
 // Gets velocity of an entity (ent) away from origin with speed (fSpeed)
 public get_velocity_from_origin(ent,Float:fOrigin[3],Float:fSpeed,Float:fVelocity[3]) {
	new Float:fEntOrigin[3];
	entity_get_vector(ent,EV_VEC_origin,fEntOrigin);

	// Velocity = Distance / Time

	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
 	fVelocity[2] = fDistance[2] / fTime;

	return (fVelocity[0] && fVelocity[1] && fVelocity[2]);
 }

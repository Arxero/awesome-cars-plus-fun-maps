/*|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|*
*. 
* [ZP] Extra Item Jetpack+Bazooka 3.2
*
*|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|*
*
* Original Plugin:
*		   AMX Jetpack
* 		   BY
* 		   (c) Copyright 2005, KleeneX 
* 		   This file is provided as is (no warranties)
*
* CREDITS:
*	  	   KleeneX   |>>>|  Original Plugin (http://forums.alliedmods.net/showthread.php?p=119727)
*	 	   Bad_Bud   |>>>|  TS_Jetpack (http://forums.alliedmods.net/showthread.php?s=e5aba95dfbb0814ebafe553d555b1e51&t=55709&highlight=TS_Jetpack)
*	  	   MeRcyLeZZ |>>>|  bug fix, some code from [ZP] Stamina (http://forums.alliedmods.net/showpost.php?p=675697&postcount=1300)
*	   	   mogel     |>>>|  Icon code form Predator-Mod (http://forums.alliedmods.net/showthread.php?s=e5aba95dfbb0814ebafe553d555b1e51&t=67305&highlight=predator)
*
*|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|*
*
* Plagued Version 3.2 by B!gBud
*
* 
* Allows Humans buy a Jetpack+Bazooka in Zombie Plague [4.0]
* 
*
* CVARS:	
*	zp_jetpack 2 		// 0 = Off / 1 = have Knive & Hold ATTACK / 2 = Hold JUMP and DUCK  	
*
*	zp_jp_forward_speed 300 // Set the forward speed(when you fly and press FORWARD)
*	zp_jp_up_speed 35	// Set the UP speed(when you press ATTACK and JUMP up)
*	zp_jp_accelerate 100	// How fast you get to the max ForwardSpeed
*
*	zp_jp_rocket_delay 12	// How long you got to wait to shoot the next rocket(in sec.)
*	zp_jp_rocket_speed 1500 // Set the rocket Speed
*	zp_jp_rocket_damage 1500	// Set the max rocket Damage
*	zp_jp_damage_radius 350 // Set the radius of a rocket explosion
*	
*	zp_jp_max_engery 100 	// Set the max Energy for the Jetpack
*	zp_jp_engery 10 	// Set how many Energy need the JP to fly (time interval is "zp_jp_energy_cal")
*	zp_jp_regain_energy 3	// Set how fast you get JP_Energy back, when you on the ground (time interval is "zp_jp_energy_cal")
*	zp_jp_energy_cal 1.0 	// Set time interval for "zp_jp_engery" & "zp_jp_regain_energy"
*	zp_jp_oneround 1	// 0 = jetpack stay on a new round if someone alive / 1 = jetpack for One Round only
*
*|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|**|_/=\_|*/

#include <amxmodx>
#include <fun>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <cromchat>

#define PLUGINNAME		"Extra Item Jetpack+Bazooka"
#define VERSION			"3.2"
#define AUTHOR			"B!gBud"

#define ACCESS_LEVEL	ADMIN_LEVEL_A
#define VOTE_ACCESS	ADMIN_CFG

#define TE_EXPLOSION	3
#define TE_BEAMFOLLOW	22
#define TE_BEAMCYLINDER	21

#define JETPACK_COST 30 // set how may ammopacks the Jatpack+Rocket cost

#if AMXX_VERSION_NUM < 183
#define client_disconnected client_disconnect
#endif

new ROCKET_MDL[64] = "models/rpgrocket.mdl"
new ROCKET_SOUND[64] = "weapons/rocketfire1.wav"
new getrocket[64] = "items/9mmclip2.wav"

new bool:fly[33] = false
new bool:rocket[33] = false
new bool:rksound[33] = false
new bool:shot[33] = false

new Float:gltime = 0.0
new Float:last_Rocket[33] = 0.0
new Float:jp_cal[33] = 0.0
new Float:jp_soun[33] = 0.0
new flame, explosion, trail, white
new g_flyEnergy[33], hasjet[33]
new cvar_jetpack, cvar_jetpackSpeed, cvar_jetpackUpSpeed, cvar_jetpackAcrate ,cvar_RocketDelay, cvar_RocketSpeed, cvar_RocketDmg, cvar_Dmg_range, cvar_fly_max_engery, cvar_fly_engery, cvar_regain_energy, cvar_cal_time, cvar_oneround

new p_JetpackCost
new p_BuyJetpack


public plugin_init() {
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	
	register_clcmd("say /jpdrop", "cmdDrop")
	register_clcmd("say_team /jpdrop", "cmdDrop")
	
	register_clcmd("say /jphelp","cmdHelp",0,": Displays Jetpack help")
	register_clcmd("say /jetpack", "cmdBuy")
	
	new ver[64]
	format(ver,63,"%s v%s",PLUGINNAME,VERSION)
	register_cvar("zp_jp_version",ver,FCVAR_SERVER)	
	
	p_JetpackCost = register_cvar("Jetpack_Money_Cost", "4000")  // Cost of Jetpack in CS Money 
	p_BuyJetpack = register_cvar("Jetpack_buy", "1") // If you  don't want to buy jetpack set it to 0
	
	cvar_jetpack = register_cvar("zp_jetpack", "2")
	
	cvar_jetpackSpeed=register_cvar("zp_jp_forward_speed","300.0")
	cvar_jetpackUpSpeed=register_cvar("zp_jp_up_speed","35.0")
	cvar_jetpackAcrate=register_cvar("zp_jp_accelerate","100.0")
	
	cvar_RocketDelay=register_cvar("zp_jp_rocket_delay","12.0")
	cvar_RocketSpeed=register_cvar("zp_jp_rocket_speed","1500")
	cvar_RocketDmg=register_cvar("zp_jp_rocket_damage","1500")
	cvar_Dmg_range=register_cvar("zp_jp_damage_radius","350")
	
	cvar_fly_max_engery = register_cvar("zp_jp_max_engery", "100")
	cvar_fly_engery = register_cvar("zp_jp_engery", "10")
	cvar_regain_energy = register_cvar("zp_jp_regain_energy", "3")
	cvar_cal_time = register_cvar("zp_jp_energy_cal", "1.0")
	cvar_oneround = register_cvar("zp_jp_oneround", "0")

	
	register_event("CurWeapon", "check_models", "be")
	register_event("DeathMsg", "player_die", "a")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	register_forward(FM_StartFrame, "fm_startFrame")
	register_forward(FM_EmitSound, "emitsound")
}

public plugin_precache() {
	precache_model("models/p_egon.mdl")
	precache_model("models/v_egon.mdl")
	precache_model("models/w_egon.mdl")
	precache_sound("jetpack.wav")
	precache_sound("jp_blow.wav")
	
	precache_model(ROCKET_MDL)
	precache_sound(ROCKET_SOUND)
	precache_sound(getrocket)
	
	explosion = precache_model("sprites/zerogxplode.spr")
	trail = precache_model("sprites/smoke.spr")
	flame = precache_model("sprites/xfireball3.spr")
	white = precache_model("sprites/white.spr")
}

public client_putinserver(id) {
	fly[id] = false
	rocket[id] = false
	hasjet[id] = 0
	g_flyEnergy[id] = 0
}

public client_disconnected(id) {
	fly[id] = false
	rocket[id] = false
	hasjet[id] = 0
	g_flyEnergy[id] = 0
}

public event_round_start()
{
	remove_jetpacks();
	if (get_pcvar_num(cvar_oneround) == 1) {
		for (new id; id <= 32; id++) hasjet[id] = 0, g_flyEnergy[id] = 0,	fly[id] = false;
	}
}

public fm_startFrame(){
		
	gltime = get_gametime()
	static id
	for (id = 1; id <= 32; id++)
	{
		jp_forward(id)
	}
}

public jp_forward(player) {
	
	if (!is_user_alive(player))
		return FMRES_IGNORED		
		
	if (!hasjet[player])
		return FMRES_IGNORED
	
	if(jp_cal[player] < gltime){
		jp_energy(player); jp_cal[player] = gltime + get_pcvar_float(cvar_cal_time)
	}
	
	check_rocket(player)
	
	new clip,ammo
	new wpnid = get_user_weapon(player,clip,ammo)
	if (wpnid == CSW_KNIFE){
		if(get_pcvar_num(cvar_jetpack) == 1){
			if(!(pev(player, pev_flags)&FL_ONGROUND) && pev(player,pev_button)&IN_ATTACK){
				if((g_flyEnergy[player] > get_pcvar_num(cvar_fly_max_engery)*0.3) && (g_flyEnergy[player] <= get_pcvar_num(cvar_fly_max_engery))){
					if(jp_soun[player] < gltime){
						emit_sound(player,CHAN_ITEM,"jetpack.wav",1.0,ATTN_NORM,1,PITCH_HIGH)
						jp_soun[player] = gltime + 1.0
					}
				}			
				else if((g_flyEnergy[player] > 0) && (g_flyEnergy[player] < get_pcvar_num(cvar_fly_max_engery)*0.3)){
					if(jp_soun[player] < gltime){
							emit_sound(player,CHAN_ITEM,"jp_blow.wav",1.0,ATTN_NORM,1,PITCH_HIGH)
							jp_soun[player] = gltime + 1.0
					}
				}
			}
			human_fly(player)
			attack(player)	
		}
		if((pev(player,pev_button)&IN_ATTACK2)){
				attack2(player)	
			}	
	}
	if((get_pcvar_num(cvar_jetpack) == 2 && !(pev(player, pev_flags)&FL_ONGROUND)) && (pev(player,pev_button)&IN_JUMP && pev(player,pev_button)&IN_DUCK)){			
		if((g_flyEnergy[player] > get_pcvar_num(cvar_fly_max_engery)*0.3) && (g_flyEnergy[player] <= get_pcvar_num(cvar_fly_max_engery))){
			if(jp_soun[player] < gltime){
				emit_sound(player,CHAN_ITEM,"jetpack.wav",1.0,ATTN_NORM,1,PITCH_HIGH)
				jp_soun[player] = gltime + 1.0
			}
		}					
		else if((g_flyEnergy[player] > 0) && (g_flyEnergy[player] < get_pcvar_num(cvar_fly_max_engery)*0.3)){
			if(jp_soun[player] < gltime){
				emit_sound(player,CHAN_ITEM,"jp_blow.wav",1.0,ATTN_NORM,1,PITCH_HIGH)
				jp_soun[player] = gltime + 1.0
			}
		}
		human_fly(player)
		attack(player)
	}
	// Icon Show system
	/*if (!is_user_alive(player) && zp_get_user_zombie(player) && zp_get_user_nemesis(player) && zp_get_user_survivor(player))	
		Icon_Energy({0, 255, 0}, 0, player);
				//Icon_Energy({128, 128, 0}, 0, player);
				//Icon_Energy({255, 255, 0}, 0, player);
						
	}*/
	if((g_flyEnergy[player] >= get_pcvar_num(cvar_fly_max_engery)*0.8) && (g_flyEnergy[player] <= get_pcvar_num(cvar_fly_max_engery))){
		Icon_Energy({0, 255, 0}, 1, player); // Green
	}
	else if((g_flyEnergy[player] >= get_pcvar_num(cvar_fly_max_engery)*0.5) && (g_flyEnergy[player] < get_pcvar_num(cvar_fly_max_engery)*0.8)){
		Icon_Energy({255, 255, 0}, 1, player); // yellow
	}
	else if((g_flyEnergy[player] >= get_pcvar_num(cvar_fly_max_engery)*0.3) && (g_flyEnergy[player] < get_pcvar_num(cvar_fly_max_engery)*0.5)){
		Icon_Energy({255, 215, 0}, 2, player);
	}
	else if((g_flyEnergy[player] > 0) && (g_flyEnergy[player] < get_pcvar_num(cvar_fly_max_engery)*0.3)){
		Icon_Energy({255, 0, 0}, 1, player);
	}
	
	return FMRES_IGNORED
}

public jp_energy(player) {
			
		if (!(pev(player, pev_flags)&FL_ONGROUND) && pev(player,pev_button)&IN_ATTACK)	
		{
			// Get our current velocity		
			new clip,ammo
			new wpnid = get_user_weapon(player,clip,ammo)
			if (wpnid == CSW_KNIFE) 
			{
			// flying
			if(g_flyEnergy[player] > get_pcvar_num(cvar_fly_max_engery)*0.09)
				g_flyEnergy[player] = g_flyEnergy[player] - get_pcvar_num(cvar_fly_engery);	 // Increase distance counter		
			}
		}
		else if ((get_pcvar_num(cvar_jetpack) == 2 && !(pev(player, pev_flags)&FL_ONGROUND)) && (pev(player,pev_button)&IN_JUMP && pev(player,pev_button)&IN_DUCK))
		{
			if(g_flyEnergy[player] > get_pcvar_num(cvar_fly_max_engery)*0.09)
				g_flyEnergy[player] = g_flyEnergy[player] - get_pcvar_num(cvar_fly_engery);	 // Increase distance counter	
		}
		// Walking/Runnig
		if (pev(player, pev_flags) & FL_ONGROUND)	
			g_flyEnergy[player] = g_flyEnergy[player] + get_pcvar_num(cvar_regain_energy);// Decrease distance counter
}

public attack(player) {
//code snippa from TS_Jetpack 1.0 - Jetpack plugin for The Specialists.
//http://forums.alliedmods.net/showthread.php?s=3ea22295e3e5a292fa82899676583326&t=55709&highlight=jetpack
//By: Bad_Bud
	if(fly[player])
	{	
		static Float:JetpackData[3]
		pev(player,pev_velocity,JetpackData)
					
		new fOrigin[3],Float:Aim[3]
		VelocityByAim(player, 10, Aim)
		get_user_origin(player,fOrigin)
		fOrigin[0] -= floatround(Aim[0])
		fOrigin[1] -= floatround(Aim[1])
		fOrigin[2] -= floatround(Aim[2])
		
		
		if((pev(player,pev_button)&IN_FORWARD) && !(pev(player, pev_flags) & FL_ONGROUND))
			{
				
				message_begin(MSG_ALL,SVC_TEMPENTITY)
				write_byte(17) 
				write_coord(fOrigin[0])
				write_coord(fOrigin[1])
				write_coord(fOrigin[2])
				write_short(flame)
				write_byte(10)
				write_byte(255)
				message_end()	
				
				static Float:Speed
				Speed=floatsqroot(JetpackData[0]*JetpackData[0]+JetpackData[1]*JetpackData[1])
					
				if(Speed!=0.0)//Makes players only lay down if their speed isn't 0; if they are thrusting forward.
				{
					set_pev(player,pev_gaitsequence,0)
					set_pev(player,pev_sequence,111)
				}
					
				if(Speed<get_pcvar_float(cvar_jetpackSpeed))
					Speed+=get_pcvar_float(cvar_jetpackAcrate)
						
				static Float:JetpackData2[3]
				pev(player,pev_angles,JetpackData2)
				JetpackData2[2]=0.0//Remove the Z value/
					
				angle_vector(JetpackData2,ANGLEVECTOR_FORWARD,JetpackData2)
				JetpackData2[0]*=Speed
				JetpackData2[1]*=Speed
					
				JetpackData[0]=JetpackData2[0]
				JetpackData[1]=JetpackData2[1]
			}
			
		if(JetpackData[2]<get_pcvar_float(cvar_jetpackSpeed)&&JetpackData[2]>0.0)//Jetpacks get more power on the way down -- it helps landing.
				JetpackData[2]+=get_pcvar_float(cvar_jetpackUpSpeed)
			else if(JetpackData[2]<0.0)
				JetpackData[2]+=(get_pcvar_float(cvar_jetpackUpSpeed)*1.15)
					
		set_pev(player,pev_velocity,JetpackData)
	}
}

public attack2(player) {
		
	if (rocket[player])
	{
		
		new rocket = create_entity("info_target")
		if(rocket == 0) return PLUGIN_CONTINUE
		
		entity_set_string(rocket, EV_SZ_classname, "zp_jp_rocket")
		entity_set_model(rocket, ROCKET_MDL)
		
		entity_set_size(rocket, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
		entity_set_int(rocket, EV_INT_movetype, MOVETYPE_FLY)
		entity_set_int(rocket, EV_INT_solid, SOLID_BBOX)
		
		new Float:vSrc[3]
		entity_get_vector(player, EV_VEC_origin, vSrc)
		
		new Float:Aim[3],Float:origin[3]
		VelocityByAim(player, 64, Aim)
		entity_get_vector(player,EV_VEC_origin,origin)
		
		vSrc[0] += Aim[0]
		vSrc[1] += Aim[1]
		entity_set_origin(rocket, vSrc)
		
		new Float:velocity[3], Float:angles[3]
		VelocityByAim(player, get_pcvar_num(cvar_RocketSpeed), velocity)
		
		entity_set_vector(rocket, EV_VEC_velocity, velocity)
		vector_to_angle(velocity, angles)
		entity_set_vector(rocket, EV_VEC_angles, angles)
		entity_set_edict(rocket,EV_ENT_owner,player)
		entity_set_float(rocket, EV_FL_takedamage, 1.0)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(rocket)
		write_short(trail)
		write_byte(25)
		write_byte(5)
		write_byte(224)
		write_byte(224)
		write_byte(255)
		write_byte(255)
		message_end()

		emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		shot[player] = true
		last_Rocket[player] = gltime + get_pcvar_num(cvar_RocketDelay)
	}
	return PLUGIN_CONTINUE
}

public check_models(id) {

	if(hasjet[id]) {
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		
		if ( wpnid == CSW_KNIFE ) {
			switchmodel(id)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public switchmodel(id) {
	entity_set_string(id,EV_SZ_viewmodel,"models/v_egon.mdl")
	entity_set_string(id,EV_SZ_weaponmodel,"models/p_egon.mdl")
}

public remove_jetpacks() {
	new nextitem  = find_ent_by_class(-1,"zp_jp_jetpack")
	while(nextitem) {
		remove_entity(nextitem)
		nextitem = find_ent_by_class(-1,"zp_jp_jetpack")
	}
	return PLUGIN_CONTINUE
}

public emitsound(entity, channel, const sample[]) {
	if(is_user_alive(entity)) {
		new clip,ammo
		new weapon = get_user_weapon(entity,clip,ammo)
		
		if(hasjet[entity] && weapon == CSW_KNIFE) {
			if(equal(sample,"weapons/knife_slash1.wav")) return FMRES_SUPERCEDE
			if(equal(sample,"weapons/knife_slash2.wav")) return FMRES_SUPERCEDE
			
			if(equal(sample,"weapons/knife_deploy1.wav")) return FMRES_SUPERCEDE
			if(equal(sample,"weapons/knife_hitwall1.wav")) return FMRES_SUPERCEDE
			
			if(equal(sample,"weapons/knife_hit1.wav")) return FMRES_SUPERCEDE
			if(equal(sample,"weapons/knife_hit2.wav")) return FMRES_SUPERCEDE
			if(equal(sample,"weapons/knife_hit3.wav")) return FMRES_SUPERCEDE
			if(equal(sample,"weapons/knife_hit4.wav")) return FMRES_SUPERCEDE
			
			if(equal(sample,"weapons/knife_stab.wav")) return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public Icon_Show(icon[], color[3], mode, player) {
			
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), {0,0,0}, player);
	write_byte(mode); 	// status (0=hide, 1=show, 2=flash)
	write_string(icon); 	// sprite name
	write_byte(color[0]); 	// red
	write_byte(color[1]); 	// green
	write_byte(color[2]); 	// blue
	message_end();

}

public Icon_Energy(color[3], mode, player) {
	
	Icon_Show("item_longjump", color, mode, player)
}

public human_fly(player) {
	
	if (g_flyEnergy[player] <= get_pcvar_num(cvar_fly_max_engery)*0.1)
	{
		jp_off(player);	
	}
	if (g_flyEnergy[player] > get_pcvar_num(cvar_fly_max_engery)*0.1)
	{
		jp_on(player);
	}
}

public jp_on(player) {

	fly[player] = true
	
}

public jp_off(player) {

	fly[player] = false
	
}

public check_rocket(player) {
		
	if (last_Rocket[player] > gltime)
	{	
		rk_forbidden(player)
		rksound[player] = true
	}
	else
	{	

		if (shot[player])
		{
			rksound[player] = false
			shot[player] = false
		}
		rk_sound(player)
		rk_allow(player)
	}
	
}

public rk_allow(player) {
		
	rocket[player] = true
}

public rk_forbidden(player) {

	rocket[player] = false
	
}

public rk_sound(player) {

	if (!rksound[player])
	{
		engfunc(EngFunc_EmitSound, player, CHAN_WEAPON, getrocket, 1.0, ATTN_NORM, 0, PITCH_NORM)
		client_print(player, print_center, "[Bazooka] Reloaded & Ready !!!")
		rksound[player] = true
	}
	else if (rksound[player])
	{
		
	}
	
}
		
public cmdHelp(id) {
	
	new g_max = get_pcvar_num(cvar_fly_max_engery)
	new g_lost = get_pcvar_num(cvar_fly_engery)
	new g_back = get_pcvar_num(cvar_regain_energy)
	new g_dmg = get_pcvar_num(cvar_RocketDmg)
	new g_delay = get_pcvar_num(cvar_RocketDelay) 
	
	new jpmotd[2048], title[64], dpos = 0
	format(title,63,"[ZP] %s ver.%s",PLUGINNAME,VERSION)
	
	
	dpos += format(jpmotd[dpos],2047-dpos,"<html><head><style type=^"text/css^">pre{color:#FF0505;}body{background:#000000;margin-left:16px;margin-top:1px;}</style></head><pre><body>")
	dpos += format(jpmotd[dpos],2047-dpos,"<b>%s</b>^n^n",title)
	
	dpos += format(jpmotd[dpos],2047-dpos,"How to use:^n")
	dpos += format(jpmotd[dpos],2047-dpos,"=============^n^n")
	if(get_pcvar_num(cvar_jetpack) == 1) {
		dpos += format(jpmotd[dpos],2047-dpos,"- choose/have Knive & use/hold ATTACK to fly^n")
		dpos += format(jpmotd[dpos],2047-dpos,"^n")
		dpos += format(jpmotd[dpos],2047-dpos,"- choose/have Knive(Bazooka) & use ATTACK2 to shoot a Rocket^n^n")
	}
	else if(get_pcvar_num(cvar_jetpack) == 2){
		dpos += format(jpmotd[dpos],2047-dpos,"- use/hold JUMP & DUCK to flyn")
		dpos += format(jpmotd[dpos],2047-dpos,"^n")
		dpos += format(jpmotd[dpos],2047-dpos,"choose/have Knive(Bazooka) & use ATTACK2 to shoot a Rocket^n^n")
	}
	dpos += format(jpmotd[dpos],2047-dpos,"INFO's^n")
	dpos += format(jpmotd[dpos],2047-dpos,"MAX Energy set to : <b>%i Units</b>^n^n", g_max)
	dpos += format(jpmotd[dpos],2047-dpos,"Jetpack need %i Units per 1 Sec. to work^n", g_lost)
	dpos += format(jpmotd[dpos],2047-dpos,"Energy regain %i Units per 1 Sec. (when you are on the ground)^n^n", g_back)
	dpos += format(jpmotd[dpos],2047-dpos,"MAX Rocket Dmg set to: <b>%i dmg</b>^n",g_dmg)
	dpos += format(jpmotd[dpos],2047-dpos,"New Rocket comes ervry <b>%i Sec.</b>^n^n", g_delay )
	dpos += format(jpmotd[dpos],2047-dpos,"-Have Fun!^n")
	

	show_motd(id,jpmotd,title)
}

public player_die() {
	
	new id = read_data(2)
	if(hasjet[id]) {
		//drop_jetpack(id)
		hasjet[id] = 0
		rocket[id] = false
		g_flyEnergy[id] = 0
	}
	
	return PLUGIN_CONTINUE
}

public cmdDrop(id)
{
	if(hasjet[id]) {
		new clip,ammo
		new weapon = get_user_weapon(id,clip,ammo)
		if(weapon == CSW_KNIFE) {
			drop_jetpack(id)
			entity_set_string(id,EV_SZ_viewmodel,"models/v_knife.mdl")
			entity_set_string(id,EV_SZ_weaponmodel,"models/p_knife.mdl")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public drop_jetpack(player) {
	if(hasjet[player]) {
		new Float:Aim[3],Float:origin[3]
		VelocityByAim(player, 64, Aim)
		entity_get_vector(player,EV_VEC_origin,origin)
		
		origin[0] += Aim[0]
		origin[1] += Aim[1]
		
		new jetpack = create_entity("info_target")
		entity_set_string(jetpack,EV_SZ_classname,"zp_jp_jetpack")
		entity_set_model(jetpack,"models/w_egon.mdl")	
		
		entity_set_size(jetpack,Float:{-16.0,-16.0,-16.0},Float:{16.0,16.0,16.0})
		entity_set_int(jetpack,EV_INT_solid,1)
		
		entity_set_int(jetpack,EV_INT_movetype,6)
		
		entity_set_vector(jetpack,EV_VEC_origin,origin)
		
		Icon_Energy({255, 255, 0}, 0, player)
		Icon_Energy({128, 128, 0}, 0, player )
		Icon_Energy({0, 255, 0}, 0, player)
		
		hasjet[player] = 0
		rocket[player] = false
	}	
}

public pfn_touch(ptr, ptd) {
	if(is_valid_ent(ptr)) {
		new classname[32]
		entity_get_string(ptr,EV_SZ_classname,classname,31)
		
		if(equal(classname, "zp_jp_jetpack")) {
			if(is_valid_ent(ptd)) {
				new id = ptd
				if(id > 0 && id < 34) {
					if(!hasjet[id] && is_user_alive(id)) {
						
						hasjet[id] = 1
						g_flyEnergy[id] = get_pcvar_num(cvar_fly_max_engery)
						rocket[id] = true
						client_cmd(id,"spk items/gunpickup2.wav")
						engclient_cmd(id,"weapon_knife")
						switchmodel(id)
						remove_entity(ptr)
					}
				}
			}
		}else if(equal(classname, "zp_jp_rocket")) {
			new Float:fOrigin[3]
			new iOrigin[3]
			entity_get_vector(ptr, EV_VEC_origin, fOrigin)
			FVecIVec(fOrigin,iOrigin)
			jp_radius_damage(ptr)
				
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY,iOrigin)
			write_byte(TE_EXPLOSION)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_short(explosion)
			write_byte(30)
			write_byte(15)
			write_byte(0)
			message_end()
				
			message_begin(MSG_ALL,SVC_TEMPENTITY,iOrigin)
			write_byte(TE_BEAMCYLINDER)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2]+200)
			write_short(white)
			write_byte(0)
			write_byte(1)
			write_byte(6)
			write_byte(8)
			write_byte(1)
			write_byte(255)
			write_byte(255)
			write_byte(192)
			write_byte(128)
			write_byte(5)
			message_end()
			
			if(is_valid_ent(ptd)) {
				new classname2[32]
				entity_get_string(ptd,EV_SZ_classname,classname2,31)
				
				if(equal(classname2,"func_breakable"))
					force_use(ptr,ptd)
			}
			
			remove_entity(ptr)
		}
	}
	return PLUGIN_CONTINUE
}

public zp_user_infected_pre(player, infector){
	
	Icon_Energy({0, 255, 0}, 0, player);
	cmdDrop(player);
	hasjet[player] = 0;
	g_flyEnergy[player] = 0;
	rocket[player] = false;
}

public cmdBuy(id)
{
	if (get_pcvar_num(p_BuyJetpack))
	{
		if (cs_get_user_money(id) >= get_pcvar_num(p_JetpackCost))
		{
			cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_JetpackCost))
			client_print(id, print_chat, "[ZP] Say /jphelp to see help page..")

			hasjet[id] = 1
			g_flyEnergy[id] = get_pcvar_num(cvar_fly_max_engery)
			rocket[id] = true

			client_cmd(id, "spk items/gunpickup2.wav")

			if (get_user_weapon(id) == CSW_KNIFE)
				switchmodel(id)
			else
			{
				client_cmd(id, "weapon_knife")
				switchmodel(id)
			}
		}
		else
		{
			client_print(id, print_chat, "[ZP] You don't have enough money to buy Jetpack!")
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		client_print(id, print_chat, "[ZP] Say /jphelp to see help page..")

		hasjet[id] = 1
		g_flyEnergy[id] = get_pcvar_num(cvar_fly_max_engery)
		rocket[id] = true

		client_cmd(id, "spk items/gunpickup2.wav")

		if (get_user_weapon(id) == CSW_KNIFE)
			switchmodel(id)
		else
		{
			client_cmd(id, "weapon_knife")
			switchmodel(id)
		}
	}
	return PLUGIN_HANDLED
}

stock jp_radius_damage(entity) {
	new id = entity_get_edict(entity,EV_ENT_owner)
	for(new i = 1; i < 33; i++) {
		if(is_user_alive(i)) {
			new dist = floatround(entity_range(entity,i))
			
			if(dist <= get_pcvar_num(cvar_Dmg_range)) {
				new hp = get_user_health(i)
				new Float:damage = get_pcvar_float(cvar_RocketDmg)-(get_pcvar_float(cvar_RocketDmg)/get_pcvar_float(cvar_Dmg_range))*float(dist)
				
				new Origin[3]
				get_user_origin(i,Origin)
				
				if(get_user_team(id) != get_user_team(i)) {
						if(hp > damage)
							jp_take_damage(i,floatround(damage),Origin,DMG_BLAST)
						else
							log_kill(id,i,"Jetpack Rocket",0)
					}
			}
		}
	}
}

stock log_kill(killer, victim, weapon[], headshot)
{
// code from MeRcyLeZZ
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	ExecuteHamB(Ham_Killed, victim, killer, 2) // set last param to 2 if you want victim to gib
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)

	
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
	write_byte(killer)
	write_byte(victim)
	write_byte(headshot)
	write_string(weapon)
	message_end()
//
	
	if(get_user_team(killer)!=get_user_team(victim))
		set_user_frags(killer,get_user_frags(killer) +1)
	if(get_user_team(killer)==get_user_team(victim))
		set_user_frags(killer,get_user_frags(killer) -1)
		
	new kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10]

	get_user_name(killer, kname, 31)
	get_user_team(killer, kteam, 9)
	get_user_authid(killer, kauthid, 31)
 
	get_user_name(victim, vname, 31)
	get_user_team(victim, vteam, 9)
	get_user_authid(victim, vauthid, 31)
		
	log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
	kname, get_user_userid(killer), kauthid, kteam, 
 	vname, get_user_userid(victim), vauthid, vteam, weapon)

 	return PLUGIN_CONTINUE;
}

stock jp_take_damage(victim,damage,origin[3],bit) {
	message_begin(MSG_ONE,get_user_msgid("Damage"),{0,0,0},victim)
	write_byte(21)
	write_byte(20)
	write_long(bit)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	message_end()
	
	set_user_health(victim,get_user_health(victim)-damage)
}
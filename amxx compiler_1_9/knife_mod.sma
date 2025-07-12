#include <amxmodx>
#include <amxmisc>
#include <engine> 
#include <vault>
#include <fun>

#define PLUGIN "Knife Mod"
#define VERSION "1.0" 
#define AUTHOR "spunko"

#define TASK_INTERVAL 4.0  
#define MAX_HEALTH 255  

new knife_model[33] 
new g_Menu

new CVAR_HIGHSPEED
new CVAR_LOWSPEED
new CVAR_LOWGRAV
new CVAR_NORMGRAV
new CVAR_HEALTH_ADD
new CVAR_HEALTH_MAX
new CVAR_DAMAGE 

public plugin_init() { 
	
	register_plugin(PLUGIN, VERSION, AUTHOR) 
	
	register_event( "Damage", "event_damage", "be" )
	register_event("CurWeapon","CurWeapon","be","1=1") 
	
	g_Menu = register_menuid("Knife Mod")
	register_menucmd(g_Menu, 1023, "knifemenu")
	
	register_clcmd("say /knife", "display_knife")
	
	CVAR_HIGHSPEED = register_cvar("km_highspeed","340")
	CVAR_LOWSPEED = register_cvar("km_lowspeed","170")
	CVAR_HEALTH_ADD = register_cvar("km_addhealth", "3")
	CVAR_HEALTH_MAX = register_cvar("km_maxhealth", "75")
	CVAR_DAMAGE = register_cvar("km_damage", "2")
	CVAR_LOWGRAV = register_cvar("km_lowgravity" , "400")
	CVAR_NORMGRAV = get_cvar_pointer("sv_gravity")
	
	set_task(480.0, "kmodmsg", 0, _, _, "b")
}

public plugin_precache() { 
	precache_model("models/knife-mod/v_butcher.mdl") 
	precache_model("models/knife-mod/p_butcher.mdl") 
	precache_model("models/knife-mod/v_machete.mdl")
	precache_model("models/knife-mod/p_machete.mdl")
	precache_model("models/knife-mod/v_bak.mdl")
	precache_model("models/knife-mod/p_bak.mdl")
	precache_model("models/knife-mod/v_pocket.mdl")
	precache_model("models/knife-mod/p_pocket.mdl")
	precache_model("models/v_knife.mdl") 
	precache_model("models/p_knife.mdl")
} 

public display_knife(id) {
	new menuBody[512]
	add(menuBody, 511, "\rKnife Mod\w^n^n")
	add(menuBody, 511, "1. Machete \y(More Damage/Low Speed)\w^n")
	add(menuBody, 511, "2. Bak Knife \y(No Footsteps)\w^n")
	add(menuBody, 511, "3. Pocket Knife \y(High Speed)\w^n")
	add(menuBody, 511, "4. Butcher Knife \y(Low Gravity)\w^n")
	add(menuBody, 511, "5. Default Knife \y(Health Regeneration)\w^n^n")
	add(menuBody, 511, "0. Exit^n")
	
	new keys = ( 1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<9 )
	show_menu(id, keys, menuBody, -1, "Knife Mod")
}

public knifemenu(id, key) {
	switch(key) 
	{
		case 0: SetKnife(id , 4)
		case 1: SetKnife(id , 2)
		case 2: SetKnife(id , 3)
		case 3: SetKnife(id , 1)
		case 4: SetKnife(id , 0)
		default: return PLUGIN_HANDLED
	}
	SaveData(id)
	return PLUGIN_HANDLED
} 

public SetKnife(id , Knife) {
	knife_model[id] = Knife
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_KNIFE )
		return PLUGIN_HANDLED
	
	new vModel[56],pModel[56]
	
	switch(Knife)
	{
		case 0: {
			format(vModel,55,"models/v_knife.mdl")
			format(pModel,55,"models/p_knife.mdl")
		}
		case 1: {
			format(vModel,55,"models/knife-mod/v_butcher.mdl")
			format(pModel,55,"models/knife-mod/p_butcher.mdl")
		}
		case 2: {
			format(vModel,55,"models/knife-mod/v_bak.mdl")
			format(pModel,55,"models/knife-mod/p_bak.mdl")
		}
		case 3: {
			format(vModel,55,"models/knife-mod/v_pocket.mdl")
			format(pModel,55,"models/knife-mod/p_pocket.mdl")
		}
		case 4: {
			format(vModel,55,"models/knife-mod/v_machete.mdl")
			format(pModel,55,"models/knife-mod/p_machete.mdl")
		}
	} 
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	entity_set_string(id, EV_SZ_weaponmodel, pModel)
	
	return PLUGIN_HANDLED;  
}

public event_damage( id ) {
	
	new victim_id = id;
	if( !is_user_connected( victim_id ) ) return PLUGIN_CONTINUE
	new dmg_take = read_data( 2 );
	new dmgtype = read_data( 3 );
	new Float:multiplier = get_pcvar_float(CVAR_DAMAGE);
	new Float:damage = dmg_take * multiplier;
	new health = get_user_health( victim_id );
	
	new iWeapID, attacker_id = get_user_attacker( victim_id, iWeapID );
	
	if( !is_user_connected( attacker_id ) || !is_user_alive( victim_id ) ) {
		return PLUGIN_HANDLED
	}
	
	if( iWeapID == CSW_KNIFE && knife_model[attacker_id] == 4 ) {
		
		if( floatround(damage) >= health ) {
			if( victim_id == attacker_id ) {
				return PLUGIN_CONTINUE
				}else{
				log_kill( attacker_id, victim_id, "knife", 0 );
			}
			
			return PLUGIN_CONTINUE
			}else {
			if( victim_id == attacker_id ) return PLUGIN_CONTINUE
			
			fakedamage( victim_id, "weapon_knife", damage, dmgtype );
		}
	}
	return PLUGIN_CONTINUE
}

public CurWeapon(id)
	{
	new Weapon = read_data(2)
	
	// Set Knife Model
	SetKnife(id, knife_model[id])   
	
	// Task Options
	
	if(knife_model[id] == 0 && !task_exists(id) && Weapon == CSW_KNIFE)
		set_task(TASK_INTERVAL , "task_healing",id,_,_,"b")
	else if(task_exists(id))
		remove_task(id)
	
	// Abilities
	set_user_footsteps(id , ( (knife_model[id] == 2 && Weapon == CSW_KNIFE) ? 1 : 0) )
	
	new Float:Gravity = ((knife_model[id] == 1 && Weapon == CSW_KNIFE)? get_pcvar_float(CVAR_LOWGRAV) : get_pcvar_float(CVAR_NORMGRAV)) / 800.0
	set_user_gravity(id , Gravity)
	
	// Speed
	new Float:Speed
	if(Weapon != CSW_KNIFE || knife_model[id] < 3)
		return PLUGIN_CONTINUE
	else if(knife_model[id] == 3)
		Speed = get_pcvar_float(CVAR_HIGHSPEED)
	else if(knife_model[id] == 4)
		Speed = get_pcvar_float(CVAR_LOWSPEED)
	
	set_user_maxspeed(id, Speed)
	
	return PLUGIN_HANDLED   
	
}

stock log_kill(killer, victim, weapon[],headshot) {
	user_silentkill( victim );
	
	message_begin( MSG_ALL, get_user_msgid( "DeathMsg" ), {0,0,0}, 0 );
	write_byte( killer );
	write_byte( victim );
	write_byte( headshot );
	write_string( weapon );
	message_end();
	
	new kfrags = get_user_frags( killer );
	set_user_frags( killer, kfrags++ );
	new vfrags = get_user_frags( victim );
	set_user_frags( victim, vfrags++ );
	
	return  PLUGIN_CONTINUE
} 


public task_healing(id) {  
	new addhealth = get_pcvar_num(CVAR_HEALTH_ADD)  
	if (!addhealth)
		return  
	
	new maxhealth = get_pcvar_num(CVAR_HEALTH_MAX)  
	if (maxhealth > MAX_HEALTH) { 
		set_pcvar_num(CVAR_HEALTH_MAX, MAX_HEALTH)  
		maxhealth = MAX_HEALTH 
	}  
	
	new health = get_user_health(id)   
	
	if (is_user_alive(id) && (health < maxhealth)) { 
		set_user_health(id, health + addhealth)
		set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.1, 4)
		show_hudmessage(id,"<< !!HEAL IN PROGRESS!! >>")
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(200)
		write_byte(0)
		write_byte(75)
		message_end()
	}
	
	else {
		if (is_user_alive(id) && (health > maxhealth))
			remove_task(id)
	}
}  

public client_disconnect(id) {  
	if(task_exists(id)) remove_task(id)  
}  


public kmodmsg() { 
	
	client_print(0,print_chat,"[AMXX] Type /knife to change your knife skins")
}  

public client_authorized(id)
	{
	LoadData(id)
}

SaveData(id)
{ 
	
	new authid[32]
	get_user_authid(id, authid, 31)
	
	new vaultkey[64]
	new vaultdata[64]
	
	format(vaultkey, 63, "KMOD_%s", authid)
	format(vaultdata, 63, "%d", knife_model[id])
	set_vaultdata(vaultkey, vaultdata)
}

LoadData(id) 
{ 
	new authid[32] 
	get_user_authid(id,authid,31)
	
	new vaultkey[64], vaultdata[64]
	
	format(vaultkey, 63, "KMOD_%s", authid)
	get_vaultdata(vaultkey, vaultdata, 63)
	knife_model[id] = str_to_num(vaultdata)
	
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

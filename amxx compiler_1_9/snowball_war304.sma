
/* AMX Mod X
*   Snowball war
*
*  /   \   /   \       ___________________________
* /   / \_/ \   \     /                           \
* \__/\     /\__/    /  GIVE ME A CARROT OR I WILL \
*      \O O/         \      BLOW UP YOUR HOUSE     /
*   ___/ ^ \___      / ___________________________/
*      \___/        /_/
*      _/ \_
*   __//   \\__
*  /___\/_\/___\
*
* (c) Copyright 2008 by FakeNick
*
* This file is provided as is (no warranties)
*
*     DESCRIPTION
*	My plugin is changing an HE grenade for snowball. When player spawns he receives only
*	knife and HE. When snowball hit's wall it will explode with nice spalt effect.
*	In this mod there are two teams : blue (CT's) and red (T's). They must kill their opponents
*	with snowball. When player gets hit, his health is decreasing and there's
*	a chance that player will be chilled. In this mod target is to kill your opponents,soldier!
*	Snowball war includes very simple deathmatch (default off). It is also changing players models
*	to santa's (T's) and snow soldiers (CT's) - this model can be changed by plugin user.
*	Snowball war enables snow effect on server (comment line 171 to disable).
*
*     MODULES
*	fakemeta
*	hamsandwich
*
*     CVARS
*	sw_toggle - is mod on/off? (default ON - 1)
*	sw_friendly - is friendly fire on/off? (default OFF - 0)
*	sw_damage - damage done by snowball (default 100)
*	sw_life - life of snowball splat (default 3.0)
*	sw_dm - is deathmatch on/off? (defualt OFF - 0)
*	sw_dm_time - time to respawn (default 2.0)
*	sw_chill_chance - chance to chill player (from 0 - off, to 100 - maximum chance, default 30)
*	sw_chill_duration - duration of chill (default 5.0)
*	sw_chill_speed - percentage of speed that player receives when chilled (default 50.0)
*	sw_snowball_gravity - gravity of snowball (default 0.3)
*	sw_snowball_velocity - how many times snowball velocity will be multipied (default 2.0 times)
*	sw_crosshair_remove - will be crosshair removed (default ON - 1)
*	sw_spawn_protection - is spawn protection on? (default ON - 1)
*	sw_spawn_protection_time - time of spawn protection (default 3.0)
*
*
*	Changelog 
*	 Version 3.0 :
*	  - Initial release
*
*	 Version 3.01 :
*	  - Added game description changer
*
*	 Version 3.02 :
*	  - Added change velocity of snowball
*	  - Added change gravity of snowball
*	  - Added crsoshair remover for more realism
*
*	 Version 3.03 :
*	  - Added breaking glass when unchilling player
*	  - Added random snow skybox generator
*	  - Added spawn protection
*
*	 Version 3.04 :
*	  - Fixed server crashing bug
*
*	 Version 3.05 :
*	  - Added support for bots (code from ZP)
*
*
*/
#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

//Do not touch this!
new const model_nade_world[] = "models/sw/w_snowball.mdl"
new const model_nade_view[] = "models/sw/v_snowball.mdl"
new const model_nade_player[] = "models/sw/p_snowball.mdl"
new const model_splash[] = "sprites/bhit.spr"

//Randomly chosen models and sounds, add as many, as you want

new const model_red[][] = { "we_player_tt" }
new const model_blue[][] = { "we_player_ct" }

new const sound_pain[][] = { "player/pl_pain2.wav","player/pl_pain4.wav","player/pl_pain5.wav","player/pl_pain6.wav","player/pl_pain7.wav" }
new const sound_hit[][] = { "player/pl_snow1.wav","player/pl_snow2.wav","player/pl_snow3.wav","player/pl_snow4.wav","player/pl_snow5.wav","player/pl_snow6.wav" }
new const sound_chill[][] = { "sw/chill.wav" }
new const sound_unchill[][] = { "sw/unchill.wav" }
new const sound_win_blue[][] = { "" }
new const sound_win_red[][] = { "" }
new const sound_win_no_one[][] = { "" }

/*================================================================================
 [CUSTOMIZATION ENDS HERE!]
=================================================================================*/

/*================================================================================
 [Enums]
=================================================================================*/

enum(+=100)
{
	TASK_WELCOME = 100,
	TASK_AMMO,
	TASK_RESPAWN,
	TASK_UNCHILL,
	TASK_MODEL,
	TASK_GOD
}

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

/*================================================================================
 [Pcvars]
=================================================================================*/

new pcvar_on,pcvar_friendly,pcvar_dmg,pcvar_life,pcvar_dm,pcvar_dm_time,pcvar_chill_chance,
pcvar_chill_duration,pcvar_chill_speed,pcvar_gravity,pcvar_velocity,pcvar_crosshair,
pcvar_spawn,pcvar_spawn_duration,pcvar_bots

/*================================================================================
 [Player variables]
=================================================================================*/

new g_red[33],g_blue[33],g_IsChilled[33],Float:g_maxspeed[33],Float:g_ChillySpeed[33],
g_has_custom_model[33],g_player_model[33][32],g_god[33],g_bots

/*================================================================================
 [Global Variables]
=================================================================================*/

new g_money,g_weapon,g_crosshair,g_fwSpawn,g_sync,g_maxplayers,g_death,g_endround,
g_spray,g_glass,g_drop,gmsgScreenFade,Float:g_models_counter	

//This can affect gameplay
new const g_not_needed[][] =
{
	"weaponbox",
	"armoury_entity",
	"grenade",
	"func_bomb_target",
	"info_bomb_target",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue"
}

//Grenade bounce sounds
new const g_bouncelist[4][64] =
{
	"weapons/grenade_hit1.wav",
	"weapons/grenade_hit2.wav",
	"weapons/grenade_hit3.wav",
	"weapons/he_bounce-1.wav"
}

//Mod name
new const g_modname[] = "Snowball war"

//Skyboxes
new const g_skybox[][] = { "snow","office" }


/*================================================================================
 [Offsets and Constants]
=================================================================================*/

#if cellbits == 32
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_HE_AMMO = 388
#else
const OFFSET_CSTEAMS = 139
const OFFSET_CSMONEY = 140
const OFFSET_HE_AMMO = 437
#endif
const OFFSET_LINUX  = 5

//To hide money displaying
const HIDE_MONEY = (1<<5)

//To hide crosshair
const HIDE_CROSSHAIR = (1<<6)

//For screen fade
const FFADE_IN = 0x0000

//For break glass effect
const BREAK_GLASS = 0x01

//Snow effect on server. Comment this line to disable
#define EFFECT_SNOW

//If you experience many SVC_BAD kicks. increase this (for example set it to 0.5)
const Float:MODEL_DELAY = 0.2

//Version information
new const VERSION[] = "3.05"

/*================================================================================
 [Code ;)]
=================================================================================*/

public plugin_precache()
{
	new a,modelpath[200]
	
	for(a = 0; a < sizeof sound_win_blue; a++)
		engfunc(EngFunc_PrecacheSound,sound_win_blue[a])
	for(a = 0; a < sizeof sound_win_blue; a++)
		engfunc(EngFunc_PrecacheSound,sound_win_red[a])
	for(a = 0; a < sizeof sound_win_blue; a++)
		engfunc(EngFunc_PrecacheSound,sound_win_no_one[a])
	for(a = 0; a < sizeof sound_pain; a++)
		engfunc(EngFunc_PrecacheSound,sound_pain[a])
	for(a = 0; a < sizeof sound_hit; a++)
		engfunc(EngFunc_PrecacheSound,sound_hit[a])
	for(a = 0; a < sizeof sound_chill; a++)
		engfunc(EngFunc_PrecacheSound,sound_chill[a])
	for(a = 0; a < sizeof sound_unchill; a++)
		engfunc(EngFunc_PrecacheSound,sound_unchill[a])
		
	for(a = 0;a < sizeof model_blue; a++)
	{
		formatex(modelpath, sizeof modelpath - 1, "models/player/%s/%s.mdl", model_blue[a], model_blue[a])
		engfunc(EngFunc_PrecacheModel,modelpath)
	}
	for(a = 0;a < sizeof model_red; a++)
	{
		formatex(modelpath, sizeof modelpath - 1, "models/player/%s/%s.mdl", model_red[a], model_red[a])
		engfunc(EngFunc_PrecacheModel,modelpath)
	}
		
	engfunc(EngFunc_PrecacheModel,model_nade_world)
	engfunc(EngFunc_PrecacheModel,model_nade_view)
	engfunc(EngFunc_PrecacheModel,model_nade_player)
	engfunc(EngFunc_PrecacheModel,model_splash)
	
	g_drop = engfunc(EngFunc_PrecacheModel,"sprites/blood.spr")
	g_spray = engfunc(EngFunc_PrecacheModel,"sprites/bloodspray.spr")
	g_glass = engfunc(EngFunc_PrecacheModel,"models/glassgibs.mdl")
	
	#if defined EFFECT_SNOW
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	#endif
	
	//Fake hostage to force round ending
	new ent
	ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"hostage_entity"))
	
	if(pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	//Prevent some etnities form spawning
	g_fwSpawn = register_forward(FM_Spawn,"fw_SpawnEntity")
	
}

public plugin_init()
{
	register_plugin("Snowball war", VERSION, "FakeNick")
	
	pcvar_on = register_cvar("sw_toggle","1")
	
	//Make sure that plugin is on
	if(!get_pcvar_num(pcvar_on))
		return
	
	//Register dictionary
	register_dictionary("sw.txt")
	
	//Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("CurWeapon","event_modelchange","be","1=1")
	register_logevent("logevent_round_end",2,"1=Round_End")
	
	//Forwards
	RegisterHam(Ham_Spawn,"player","fw_PlayerSpawn",1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	register_forward(FM_SetModel,"fw_SetModel")
	register_forward(FM_Touch,"fw_Touch")
	register_forward(FM_EmitSound,"fw_EmitSound")
	register_forward(FM_Think,"fw_Think")
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription,"fw_GameDesc")
	
	unregister_forward(FM_Spawn,g_fwSpawn)
	
	//Pcvars
	pcvar_friendly = register_cvar("sw_friendly","0")
	pcvar_dmg = register_cvar("sw_damage","100")
	pcvar_life = register_cvar("sw_life","3.0")
	pcvar_dm = register_cvar("sw_dm","0")
	pcvar_dm_time = register_cvar("sw_dm_time","2.0")
	pcvar_chill_chance = register_cvar("sw_chill_chance","30")
	pcvar_chill_duration = register_cvar("sw_chill_duration","5.0")
	pcvar_chill_speed = register_cvar("sw_chill_speed","50.0")
	pcvar_gravity = register_cvar("sw_snowball_gravity","0.3")
	pcvar_velocity = register_cvar("sw_snowball_velocity","2.0")
	pcvar_crosshair = register_cvar("sw_crosshair_remove","1")
	pcvar_spawn = register_cvar("sw_spawn_protection","1")
	pcvar_spawn_duration = register_cvar("sw_spawn_protection_time","3.0")
	
	pcvar_bots = get_cvar_pointer("bot_quota")
	
	//For version recognize and see what server is running this plugin
	register_cvar("sw_version",VERSION,FCVAR_SERVER | FCVAR_SPONLY)
	
	//Set skybox
	set_cvar_string("sv_skyname", g_skybox[random_num(0, sizeof g_skybox - 1)])
	
	//Other stuff
	g_money = get_user_msgid("Money")
	g_weapon = get_user_msgid("HideWeapon")
	g_crosshair = get_user_msgid("Crosshair")
	g_death = get_user_msgid("DeathMsg")
	gmsgScreenFade = get_user_msgid("ScreenFade")
	
	g_sync = CreateHudSyncObj()
	
	g_maxplayers = get_maxplayers()
	
	//Messsages
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"),"message_audio")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("Scenario"), "message_scenario")
}
public plugin_cfg()
{
	// Get configs dir
	new cfgdir[32],file[192]
	
	get_configsdir(cfgdir, sizeof cfgdir - 1)
	
	formatex(file,sizeof file - 1,"%s/sw.cfg",cfgdir)
	
	if(file_exists(file))
	{
		// Execute config file (sw.cfg)
		server_cmd("exec %s", file)
	}else{
		log_amx("[SW] Snowball War config file doesn't exist!")
	}
}
/*================================================================================
 [Events]
=================================================================================*/
public event_round_start()
{
	//It's not round end
	g_endround = false
	
	//Reset models counter
	g_models_counter = 0.0
	
	//Remove old welcome task and make a new one
	remove_task(TASK_WELCOME)
	set_task(2.5,"func_welcome",TASK_WELCOME)
	
}
public event_modelchange(id)
{
	new weapon = read_data(2)
	
	if(weapon == CSW_HEGRENADE)
	{
		//Set view model and player model
		set_pev(id,pev_viewmodel2,model_nade_view)
		set_pev(id,pev_weaponmodel2,model_nade_world)
		
		//Remove crosshair
		if(get_pcvar_num(pcvar_crosshair))
		{
			message_begin( MSG_ONE_UNRELIABLE, g_weapon, _, id )
			write_byte(HIDE_CROSSHAIR)
			message_end()
		}
		
	}
}
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:last
	if (get_gametime() - last < 0.5) return;
	last = get_gametime()
	
	g_endround = true
	
	// Show HUD notice, play win sound
	if (!sw_GetBlue())
	{
		//Red team wins
		set_hudmessage(200, 0, 0, -1.0, 0.17, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_sync, "%L", LANG_PLAYER, "WIN_RED")
		
		// Play win sound
		sw_sound(sound_win_red[random_num(0, sizeof sound_win_red -1)])
	}
	else if (!sw_GetRed())
	{
		//Blue team wins
		set_hudmessage(0, 0, 200, -1.0, 0.17, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_sync, "%L", LANG_PLAYER, "WIN_BLUE")
		
		// Play win sound
		sw_sound(sound_win_blue[random_num(0, sizeof sound_win_blue -1)])
	}
	else
	{
		// No one wins
		set_hudmessage(0, 200, 0, -1.0, 0.17, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_sync, "%L", LANG_PLAYER, "WIN_NO_ONE")
		
		sw_sound(sound_win_no_one[random_num(0, sizeof sound_win_no_one -1)])
	}
}
/*================================================================================
 [Main Part]
=================================================================================*/
public func_welcome()
{
	client_print(0,print_chat,"%L",LANG_PLAYER,"MSG_WELCOME",VERSION)
}
public client_connect(id)
{
	if(!get_pcvar_num(pcvar_on))
		return
	
	#if defined EFFECT_SNOW
	client_cmd(id, "cl_weather 1")
	#endif
}
public client_putinserver(id)
{
	// Plugin disabled?
	if (!get_pcvar_num(pcvar_on)) 
		return;
	
	// Initialize player vars
	g_IsChilled[id] = false
	g_blue[id] = false
	g_red[id]= false
	g_god[id] = false
	
	// CZ bots seem to use a different "classtype" for player entities
	// (or something like that) which needs to be hooked separately
	if (!g_bots && pcvar_bots && is_user_bot(id))
	{
		// Set a task to let the private data initialize
		set_task(0.1, "task_bots", id)
	}
}
public client_disconnect(id)
{
	if(!get_pcvar_num(pcvar_on))
		return
	
	g_IsChilled[id] = false
	g_blue[id] = false
	g_red[id]= false
	g_god[id] = false
}
/*================================================================================
 [Forwards]
=================================================================================*/

public fw_PlayerSpawn(id)
{
	if(!is_user_alive(id))
		return
	
	g_blue[id] = false
	g_red[id] = false
	g_IsChilled[id] = false
	g_god[id] = false
	
	//Strip player weapons
	// fm_strip_user_weapons(id)
	
	//Give him knife and "snowball"
	// fm_give_item(id,"weapon_knife")
	fm_give_item(id,"weapon_hegrenade")
	
	//Reset his model
	sw_reset_user_model(id)
	
	//Strip his cash ;]
	// sw_set_user_money(id,0,0)
	
	//Hide money displaying
	sw_money(id)
	
	//Set his team variable
	switch(sw_get_user_team(id))
	{
		case CS_TEAM_CT : g_blue[id] = true
		case CS_TEAM_T : g_red[id] = true
	}
	
	//Set his new model
	remove_task(id + TASK_MODEL)
	
	// Store our custom model in g_player_model[id]
	if(g_blue[id])
	{
		copy(g_player_model[id], sizeof g_player_model[] - 1, model_blue[random_num(0, sizeof model_blue -1)])
		
	}else if(g_red[id])
	{
		copy(g_player_model[id], sizeof g_player_model[] - 1, model_red[random_num(0, sizeof model_red -1)])
	}
        
	// Get the current model
	new currentmodel[32]
	sw_get_user_model(id, currentmodel, sizeof currentmodel - 1)
        
	// Check whether it matches the custom model
	if (!equal(currentmodel, g_player_model[id]))
	{
		// If not, set a task to change it
		set_task(1.0 + g_models_counter, "task_set_model", id + TASK_MODEL)
            
		// Add a delay between every model change
		g_models_counter += MODEL_DELAY
	}
	
	//Check if spawn protection is on
	if(get_pcvar_num(pcvar_spawn))
	{
		//Set god
		g_god[id] = true
		
		//Remove an old task and make a new one
		remove_task(id + TASK_GOD)
		set_task(get_pcvar_float(pcvar_spawn_duration),"task_UnGod",id + TASK_GOD)
		
		//Set glow
		switch(sw_get_user_team(id))
		{
			case CS_TEAM_CT : fm_set_user_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,25)
			case CS_TEAM_T : fm_set_user_rendering(id,kRenderFxGlowShell,255,0,0,kRenderNormal,25)
		}
		
	}
	
}
public fw_SpawnEntity(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof g_not_needed; i++)
	{
		if (equal(classname, g_not_needed[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}
public fw_SetModel(ent,const model[])
{
	//Check ent validity
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	//If model is equal to HE model, change it to snowball model
	if(equali(model,"models/w_hegrenade.mdl"))
	{
		//get owner to renew his ammo
		new Float:velocity[3],owner = pev(ent,pev_owner)
		
		//remove an old task an set a new one
		remove_task(owner + TASK_AMMO)
		set_task(0.01,"task_ammo",owner + TASK_AMMO)
		
		//Set model
		engfunc(EngFunc_SetModel,ent,model_nade_world)
		
		//Block from exploding
		set_pev(ent, pev_dmgtime, get_gametime() + 9999.0)
		
		//Set less gravity, so it will be "real" snowball
		set_pev(ent,pev_gravity,get_pcvar_float(pcvar_gravity))
		
		//Get grenade velocity
		pev(ent, pev_velocity, velocity)
		
		//Calculate new velocity
		velocity[0] *= get_pcvar_float(pcvar_velocity)
		velocity[1] *= get_pcvar_float(pcvar_velocity)
		velocity[2] *= get_pcvar_float(pcvar_velocity)
		
		//Set new velocity
		set_pev(ent, pev_velocity,velocity)
		
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
public fw_Touch(ent,id)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	//Create some variables
	new classname[20],classname2[20],Float:origin[3],owner = pev(ent,pev_owner)
	
	pev(ent,pev_origin,origin)
	pev(id,pev_classname,classname2,sizeof classname2 - 1)
	pev(ent,pev_classname,classname,sizeof classname - 1)
	
	//Player get's hit
	if(equali(classname,"grenade") && equali(classname2,"player"))
	{
		if(is_user_alive(id))
		{
			//Check friendly fire
			if (get_user_team(owner) == get_user_team(id))
				if (!get_pcvar_num(pcvar_friendly))
					return FMRES_IGNORED	
			
			//Check god mode
			if(g_god[id])
				return FMRES_IGNORED
			
			if(get_user_health(id) > get_pcvar_float(pcvar_dmg))
			{
				//Players health is greater than snowball damage
				
				//Calculate chill chance
				if(random_num(0,100) <= get_pcvar_num(pcvar_chill_chance))
				{
					//Chill only non-chilled player
					if(!g_IsChilled[id])
					{
						//Emit sound
						engfunc(EngFunc_EmitSound,id,CHAN_AUTO,sound_chill[random_num(0, sizeof sound_chill - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
						
						//Make light effect
						sw_light(origin)
						
						//Chill him!
						sw_ChillPlayer(id)
					
						//Set unchill task
						remove_task(id + TASK_UNCHILL)
						set_task(get_pcvar_float(pcvar_chill_duration),"task_UnChill",id + TASK_UNCHILL)
					}
				}
				
				//Create nice effect
				sw_effect(origin)
				
				//Emit pain sound
				engfunc(EngFunc_EmitSound,id,CHAN_VOICE,sound_pain[random_num(0, sizeof sound_pain - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
				
				//Emit hit sound
				engfunc(EngFunc_EmitSound,ent,CHAN_AUTO,sound_hit[random_num(0, sizeof sound_hit - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
				
				//Do damage to player
				fm_set_user_health(id, get_user_health(id) - floatround(get_pcvar_float(pcvar_dmg)))
				
				//Make white splash
				sw_splash(ent,origin)
				
			}else if(get_user_health(id) <= get_pcvar_float(pcvar_dmg))
			{
				//Players health is lower or equal to snowball damage
				
				//Emit hit sound
				engfunc(EngFunc_EmitSound,ent,CHAN_AUTO,sound_hit[random_num(0, sizeof sound_hit - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
				
				//Make nice effect
				sw_effect(origin)
			
				//Remove entity
				engfunc(EngFunc_RemoveEntity,ent)
				
				//Kill player
				sw_kill(owner,id,"snowball",0)
			}	
		}else{	
			//Snowball hits something (not player)
			sw_splash(ent,origin)
		}
		
	}else if(equali(classname,"grenade"))
	{
		sw_effect(origin)
		
		//Snowball hit's something, f.e. wall, etc.
		sw_splash(ent,origin)
		
		//Emit hit sound
		engfunc(EngFunc_EmitSound,ent,CHAN_AUTO,sound_hit[random_num(0, sizeof sound_hit - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
	}
	
	return FMRES_IGNORED
}
public fw_EmitSound(ent,channel,const sound[])
{
	//Check if emited sound is equal to one for our list
	for(new a; a < sizeof g_bouncelist;a++)
	{
		//If it's equal - block it
		if(equali(sound,g_bouncelist[a]))
			return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
public fw_Think(ent)
{
	//Check validity
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	//Retrieve class
	static class[20]
	pev(ent,pev_classname,class,sizeof class - 1)
	
	//If class is equal to snow_splash, remove entity
	if(equali(class,"snow_splash"))
		engfunc(EngFunc_RemoveEntity,ent)
		
	return FMRES_IGNORED
}
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{   
	// Block CS model changes
	if (g_has_custom_model[id] && equal(key, "model"))
		return FMRES_SUPERCEDE
        
	return FMRES_IGNORED
}
public fw_ClientUserInfoChanged(id)
{
    // Player doesn't have a custom model
	if (!g_has_custom_model[id])
		return FMRES_IGNORED

	// Get current model
	static currentmodel[32]
	sw_get_user_model(id, currentmodel, sizeof currentmodel - 1)
    
	// Check whether it matches the custom model - if not, set it again
	if (!equal(currentmodel, g_player_model[id]))
		sw_set_user_model(id, g_player_model[id])
    
	return FMRES_IGNORED
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	//Check if deathmatch is on
	if(!get_pcvar_num(pcvar_dm))
		return
	
	//Make sure that it's not round end
	if(!g_endround)
	{
		remove_task(victim + TASK_RESPAWN)
		set_task(get_pcvar_float(pcvar_dm_time),"task_respawn",victim + TASK_RESPAWN)
	}
	
}
//Block knife damage
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_connected(attacker))
		return HAM_IGNORED
		
	return HAM_SUPERCEDE
}
//Change game name
public fw_GameDesc()
{
	forward_return(FMV_STRING,g_modname)
	return FMRES_SUPERCEDE
}
/*================================================================================
 [Messages]
=================================================================================*/

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, sizeof textmsg - 1)
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end()
	}
	// Block round end related messages 
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED
	}
	
	//Block "Fire in the hole!" text
	if(get_msg_args() == 5)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
			new value5[64]
			get_msg_arg_string(5 ,value5 ,63)
			if(equal(value5, "#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	else if(get_msg_args() == 6)
	{
		if(get_msg_argtype(6) == ARG_STRING)
		{
			new value6[64]
			get_msg_arg_string(6 ,value6 ,63)
			if(equal(value6 ,"#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

//Block some audio messages
public message_audio()
{
	//Create variable
	static sample[20]
	
	//Get message arguments
	get_msg_arg_string(2, sample, sizeof sample - 1)
	
	//Check argument, if it's equal - block it
	if(equal(sample[1], "!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED
			
	if(equal(sample[7], "terwin") || equal(sample[7], "ctwin") || equal(sample[7], "rounddraw"))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

//Block hostage from appearing on the radar
public message_hostagepos()
{
	return PLUGIN_HANDLED
}
// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, sizeof sprite - 1)
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}
/*================================================================================
 [TASKS]
=================================================================================*/
public task_ammo(id)
{
	id -= TASK_AMMO
	
	sw_set_user_bpammo(id,1)
}
public task_respawn(id)
{
	id -= TASK_RESPAWN
	
	ExecuteHamB(Ham_CS_RoundRespawn,id)
}
public task_UnChill(id)
{
	id -= TASK_UNCHILL
	
	new Float:origin[3]
	
	pev(id,pev_origin,origin)
	
	sw_UnChill(id,origin)
}
public task_set_model(id)
{
	id -= TASK_MODEL

	sw_set_user_model(id, g_player_model[id])
}
public task_UnGod(id)
{
	id -= TASK_GOD
	
	g_god[id] = false
	
	fm_set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
}
public task_bots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_bots || !get_pcvar_num(pcvar_bots) || !is_user_connected(id) || !is_user_bot(id))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	
	// Ham forwards for CZ bots succesfully registered
	g_bots = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) fw_PlayerSpawn(id)
}
/*================================================================================
 [Stocks]
=================================================================================*/

//Set player money
stock sw_set_user_money(id,money,flash=1)
{
	set_pdata_int(id,OFFSET_CSMONEY,money,OFFSET_LINUX)
	
	message_begin(MSG_ONE,g_money,{0,0,0},id)
	write_long(money)
	write_byte(flash)
	message_end()
}
// Get User Team
stock sw_get_user_team(id)
{
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX)
}
//With this stock we can set player model
stock sw_set_user_model(player, const modelname[])
{
	engfunc(EngFunc_SetClientKeyValue, player, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", modelname)
    
	g_has_custom_model[player] = true
}
//With this stock we can get player model
stock sw_get_user_model(player, model[], len)
{
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", model, len)
}
//With this stock we can reset player model
stock sw_reset_user_model(player)
{
	g_has_custom_model[player] = false
    
	dllfunc(DLLFunc_ClientUserInfoChanged, player, engfunc(EngFunc_GetInfoKeyBuffer, player))
}
//Set user snowballs
stock sw_set_user_bpammo(id,amount)
{
	set_pdata_int(id, OFFSET_HE_AMMO, amount, OFFSET_LINUX)
}
//Make death msg
stock sw_kill(killer, victim, weapon[],headshot)
{
	set_msg_block(g_death , BLOCK_SET)
	user_kill(victim,1)
	set_msg_block(g_death, BLOCK_NOT)
	
	message_begin(MSG_ALL, g_death, {0,0,0}, 0)
	write_byte(killer)
	write_byte(victim)
	write_byte(headshot)
	write_string(weapon)
	message_end()
	
	if(get_user_team(killer)!= get_user_team(victim))
	{
		fm_set_user_frags(killer,get_user_frags(killer) + 1)
		
	}else{	
		fm_set_user_frags(killer,get_user_frags(killer) - 1)
	}
}
/*================================================================================
 [Other stuff]
=================================================================================*/
sw_GetBlue()
{
	static iCt, id
	iCt = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (is_user_connected(id))
		{	
			if(is_user_alive(id) && g_blue[id])
				iCt++
		}
	}
	
	return iCt
}
sw_GetRed()
{
	static iT, id
	iT = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (is_user_connected(id))
		{
			if(is_user_alive(id) && g_red[id])
				iT++
		}
	}
	
	return iT
}
sw_money(id)
{
	message_begin(MSG_ONE,g_weapon,_,id)
	write_byte(HIDE_MONEY)
	message_end()
	message_begin(MSG_ONE,g_crosshair,_,id)
	write_byte(0)
	message_end()
}
sw_sound(const sound[])
{
	client_cmd(0, "spk ^"%s^"", sound)
}
sw_splash(ent,Float:origin[3])
{
	set_pev(ent, pev_velocity, Float:{0.0, 0.0, 0.0})
	set_pev(ent, pev_classname, "snow_splash")
	set_pev(ent, pev_solid, SOLID_NOT)
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	engfunc(EngFunc_SetOrigin, ent, origin)
	engfunc(EngFunc_SetModel, ent, model_splash)
	set_pev(ent,pev_nextthink,get_gametime() + get_pcvar_float(pcvar_life))
	fm_set_rendering(ent, kRenderFxNoDissipation, 255, 255, 255, kRenderGlow, 255)
}
sw_effect(Float:fOrigin[3])
{
	new origin[3]
	FVecIVec(fOrigin,origin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0]+random_num(-20,20))
	write_coord(origin[1]+random_num(-20,20))
	write_coord(origin[2]+random_num(-20,20))
	write_short(g_spray)
	write_short(g_drop)
	write_byte(255)
	write_byte(15)
	message_end()
}
sw_light(Float:originF[3])
{
	new origin[3]
	FVecIVec(originF,origin)
	
	// light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(floatround(240.0/5.0)) // radius
	write_byte(0) // r
	write_byte(206)// g
	write_byte(209) // b
	write_byte(8) // life
	write_byte(60) // decay rate
	message_end()
}
sw_ChillPlayer(id)
{
	//Set glow
	fm_set_user_rendering(id,kRenderFxGlowShell,0,206,209,kRenderNormal,25)
	
	//Set chill state
	g_IsChilled[id] = true
	
	//Retrieve player old maxspeed
	pev(id,pev_maxspeed,g_maxspeed[id])
	
	//Calculate his new maxspeed
	g_ChillySpeed[id] = g_maxspeed[id] * get_pcvar_float(pcvar_chill_speed) / 100.0
	
	//Set his new maxspeed
	set_pev(id,pev_maxspeed,g_ChillySpeed[id])
	
	//Add blue fade on players screen
	message_begin(MSG_ONE,gmsgScreenFade,_,id)
	write_short(floatround(4096.0 * get_pcvar_float(pcvar_chill_duration))) // duration
	write_short(floatround(3072.0 * get_pcvar_float(pcvar_chill_duration))) // hold time
	write_short(FFADE_IN) // flags
	write_byte(0) // red
	write_byte(206) // green
	write_byte(209) // blue
	write_byte(100) // alpha
	message_end()
}
sw_UnChill(id,Float:fOrigin[3])
{
	//Make some variables
	new origin[3]
	
	//Change origin from float to integer
	FVecIVec(fOrigin,origin)
	
	//Delete glow
	fm_set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	
	//Restore his maxspeed
	set_pev(id,pev_maxspeed,g_maxspeed[id])
	
	//Set chill state
	g_IsChilled[id] = false
	
	// clear tint
	message_begin(MSG_ONE,gmsgScreenFade,_,id)
	write_short(0) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // flags
	write_byte(0) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(255)// alpha
	message_end()
	
	//Make glass effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BREAKMODEL)
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2] + 24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50,50)) // velocity x
	write_coord(random_num(-50,50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glass) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(BREAK_GLASS) // flags
	message_end()
	
	//Emit sound
	engfunc(EngFunc_EmitSound,id,CHAN_AUTO,sound_unchill[random_num(0, sizeof sound_unchill - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
}

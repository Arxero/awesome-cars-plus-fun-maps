/*
1 = TS
2 = CSTRIKE/CZ
*/
#define MOD 2
#define debug 0

#define MAX_PLUGIN_RUNENAME_SIZE 25
#define MAX_PLUGIN_RUNEDESC_SIZE 75
#define MAX_PLUGINS 60
#define MAX_SPAWNPOINTS 75
#define MAX_RUNESINGAME 30 					// (This means max runes in the world, NOT on players)
#define MAXPLAYERS 32
#define HUD_CHANNEL 3						// This is the hud channel used by the base plugin and no other ( Constantly in use)
#define HUD_CHANNEL2 4						// This is the hud channel used by the "power" plugins
#define HTML_MOTD 1							// Only supported by offical valve mods ( CS CZ DOD )
#define MIN_DISTANCE_BETWEEN_RUNES	250
#define SpereDist 45						// How far away in units we check for runes, from the user
#define MAX_RUNEAGE	2

/********************************* DONT EDIT BELLOW THIS LINE *********************************************************/

#define MOD_CSTRIKE 2
#define MOD_TS 1
// #defines for effects
#define TE_SMOKE 						5
#define TE_EXPLOSION 				3
#define TE_EXPLFLAG_NONE 		0
#define	TE_TELEPORT					11

#define API_NEWROUND 					1
#define API_SPEEDCHANGE				2
#define API_ROUNDSTARTED			4
#define API_EVENTDAMAGE				8
#define API_EVENTDAMAGEDONE		16
#define API_EVENTCHANGEWEAPON	32
#define API_EVENTCURWEAPON		64	// CurWeapon, was called but user dident change weapon
#define API_DEATHMSG					128	// This means the user was killed by base plugin
#define API_PICKUPANDFORGET		256	// This is for runes
#define API_USELANGSYSTEM			512
#define API_BADRUNE						1024

#define USER_DIED 0
#define USER_DROPEDRUNE 1
#define USER_DISCONNECTED 2
/*
Used to register this plugin in the Runemod base plugin. 
Returns -1 on  unkown error, but most likely API error
returns -2 To many extra plugins registered increase MAX_PLUGINS and recompile all plugins
When the plugin returns a positiv value, its the index of the rune
*/

stock RegisterPlugin(RuneName[],RuneDesc[],RuneColor[3],Flags)
{
	new BasePluginIndex = FindBasePluginIndex()
	new BasePluginRegFunc = get_func_id("API_RegisterPlugin",BasePluginIndex)
	new OwnIndex = FindOwnPluginIndex()
#if debug == 1	
	if(BasePluginIndex < 0)
	{
		log_amx("[Runemod - %s]Error trying to find the base plugin(%d)",RuneName,BasePluginIndex)
		return PLUGIN_HANDLED
	}
	if(BasePluginRegFunc < 0)
	{
		log_amx("[Runemod - %s] Error trying to find API_RegisterPlugin in base plugin(%d)",RuneName,BasePluginRegFunc)
		return PLUGIN_HANDLED
	}
	new Temp = callfunc_begin_i(BasePluginRegFunc,BasePluginIndex)
	if(Temp <= 0)
	{
		log_amx("[Runemod - %s]Error trying to call the function in runemod_base(%d) Make sure runemod_base is loaded!",RuneName,Temp)
		return PLUGIN_HANDLED
	}
	if(strlen(RuneName) >=MAX_PLUGIN_RUNENAME_SIZE)
	{
		log_amx("Runemod Debug - %s: RegisterPlugin() tried to register a to long runename(max is %d, tried to register %d)",RuneName,MAX_PLUGIN_RUNENAME_SIZE,strlen(RuneName))
		return PLUGIN_HANDLED
	}
	if(strlen(RuneDesc) >=MAX_PLUGIN_RUNEDESC_SIZE)
	{
		server_print("Runemod Debug %s: RegisterPlugin() tried to register a to long rune desc (max is %d, tried to register %d)",RuneName,MAX_PLUGIN_RUNEDESC_SIZE,strlen(RuneDesc))
		return PLUGIN_HANDLED
	}
#else
	new Temp = callfunc_begin_i(BasePluginRegFunc,BasePluginIndex)
	if(Temp == -2 || !Temp)
	{
		if(Temp == -2)
			log_amx("You have to many runes, and need to increase the MAX_PLUGINS define")
		else
			log_amx("A unkown error has happend, make sure the base plugin is loaded")
		return PLUGIN_HANDLED		
	}
#endif
	callfunc_push_int(OwnIndex)
	callfunc_push_str(RuneName)
	callfunc_push_str(RuneDesc)
	callfunc_push_int(RuneColor[0])
	callfunc_push_int(RuneColor[1])
	callfunc_push_int(RuneColor[2])
	callfunc_push_int(Flags)
	
	Temp = callfunc_end()
	if(Temp == -1)
	{
		log_amx("Failed to register in the api, this plugin proberbly is using the api wrong")
		return PLUGIN_HANDLED
	}
	else if(Temp == -2)
	{
		log_amx("Max plugins has been registered (%d) you need to change the value of MAX_PLUGINS and recompile ALL the runemod plugins",MAX_PLUGINS)
		return PLUGIN_HANDLED
	}
	return Temp
}
stock FindBasePluginIndex()
{
	new num_of_plugins = get_pluginsnum()
	new dummy[2];
	new name[64];
	for (new i = 0; i < num_of_plugins; ++i)
	{
		get_plugin(i, name, 63, dummy, 1, dummy, 1, dummy, 1, dummy, 1)
 		if(equal(name,"runemod_base.amxx"))
 			return i;
	}
 	return -1;
}
stock FindOwnPluginIndex()
{
	new num_of_plugins = get_pluginsnum()
	new dummy[2];
	new name[64];
	new PluginName[64]
	get_plugin(-1, PluginName,63,dummy, 1, dummy, 1, dummy, 1, dummy, 1)
	for (new i = 0; i < num_of_plugins; ++i)
	{
		get_plugin(i, name, 63, dummy, 1, dummy, 1, dummy, 1, dummy, 1)
 		if (equal(name, PluginName))
 			return i;
	}
 	return -1;
}

stock GetUserRune(id)
{
	callfunc_begin("API_GetUserRune","runemod_base.amxx")
	callfunc_push_int(id)
	return callfunc_end()
}
stock RegisterKill(killer,victim,Weapon[])
{
	callfunc_begin("API_RegisterKill","runemod_base.amxx")
	callfunc_push_int(killer)
	callfunc_push_int(victim)
	callfunc_push_str(Weapon)
	return callfunc_end()
}
stock FakeKill(killer,victim,WeaponName[]) // FakeKill code is based from whats in the orginal runemod code
{
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"),{0,0,0},0)
	write_byte(killer)
	write_byte(victim)
	write_byte(0)
	write_string(WeaponName)
	message_end()
	return PLUGIN_CONTINUE
}
stock ResetUserSpeed(id)
{
	callfunc_begin("API_ResetSpeed","runemod_base.amxx")
	callfunc_push_int(id)
	return callfunc_end()
}
stock LockSpeed(id)
{	
	callfunc_begin("LockSpeedChange","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_end()
}
stock UnLockSpeed(id)
{	
	callfunc_begin("UnLockSpeedChange","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_end()
}
stock ShakeScreen(id,amount,time)
{	
	callfunc_begin("API_ShakeScreen","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_push_int(amount)
	callfunc_push_int(time)
	callfunc_end()
}
stock MakeTeleport(origin[3])
{	
	callfunc_begin("API_EffectTeleport","runemod_base.amxx")
	callfunc_push_int(origin[0])
	callfunc_push_int(origin[1])
	callfunc_push_int(origin[2])
	callfunc_end()
}
stock MakeFadeScreen(id,Time,LastTime,type,Color[3],Alpha)
{	
	callfunc_begin("API_EffectFade","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_push_int(Time)
	callfunc_push_int(LastTime)
	callfunc_push_int(type)
	callfunc_push_int(Color[0])
	callfunc_push_int(Color[1])
	callfunc_push_int(Color[2])
	callfunc_push_int(Alpha)	
	callfunc_end()
}
stock MakeSmoke(id,origin[3])
{	
	callfunc_begin("API_EffectSmoke","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_push_int(origin[0])
	callfunc_push_int(origin[1])
	callfunc_push_int(origin[2])
	callfunc_end()
}
stock MakeExpl(id,origin[3])
{
	callfunc_begin("API_EffectExp","runemod_base.amxx")
	callfunc_push_int(id)
	callfunc_push_int(origin[0])
	callfunc_push_int(origin[1])
	callfunc_push_int(origin[2])
	callfunc_end()
}
stock set_origin(EntNum,Origin[3])
{
	new Float:F_Origin[3]
	F_Origin[0] = float(Origin[0])
	F_Origin[1] = float(Origin[1])
	F_Origin[2] = float(Origin[2])
	entity_set_origin(EntNum,F_Origin)
}
stock get_origin(EntNum,Origin[3])
{
	new Float:F_Origin[3]
	entity_get_vector(EntNum,EV_VEC_origin,F_Origin)

	Origin[0] = floatround(F_Origin[0])
	Origin[1] = floatround(F_Origin[1])
	Origin[2] = floatround(F_Origin[2])
}
stock HudMessage2(id,message[])
{
	set_hudmessage(200, 100, 0, 0.03, 0.60, 0, 0.0, 0.0, 0.0, 4.0,HUD_CHANNEL2)
	show_hudmessage(id, message)
}
#if MOD == MOD_CSTRIKE
stock is_meleeweapon(WeaponIndex,mode=1)	// This function is used to find out if the user has a melee weapon
{
	if(mode != 1)
		WeaponIndex = get_user_curweaponindex(WeaponIndex)
		
	if(WeaponIndex == 29)
		return 1
	return 0
}
stock is_weapon_pistol(WeaponIndex,mode=1)
{
	if(mode != 1)
		WeaponIndex = get_user_curweaponindex(WeaponIndex)
		
	if(WeaponIndex == CSW_DEAGLE || WeaponIndex == CSW_P228 || WeaponIndex == CSW_ELITE || WeaponIndex == CSW_FIVESEVEN || WeaponIndex == CSW_USP || WeaponIndex == CSW_GLOCK18)
		return 1
	return 0
}
stock is_weapon_sniper(WeaponIndex,mode=1)
{
	if(mode != 1)
		WeaponIndex = get_user_curweaponindex(WeaponIndex)
			
	if(WeaponIndex == CSW_G3SG1 || WeaponIndex == CSW_AWP || WeaponIndex == CSW_SG550 || WeaponIndex == CSW_SCOUT)
		return 1
	return 0
}
stock get_user_weaponindex(id)
{ 
   	callfunc_begin("API_ActiveWeapon","runemod_base.amxx")
	callfunc_push_int(id)
	return callfunc_end()
}
stock get_user_curweaponindex(id)
{ 
   new clip, ammo 
   return get_user_weapon(id, clip, ammo) 
}
#endif
#if MOD == MOD_TS
stock is_meleeweapon(WeaponIndex)	// This function is used to find out if the user has a melee weapon
{
	if(WeaponIndex == 0 || WeaponIndex == 35 || WeaponIndex == 34 || WeaponIndex == 25 )
		return 1
	return 0

}
stock is_weapon_pistol(WeaponIndex)
{
	if(WeaponIndex == 1 || WeaponIndex == 8 || WeaponIndex == 9 || WeaponIndex == 10 || WeaponIndex == 12 || WeaponIndex == 14 || WeaponIndex == 21 || WeaponIndex == 22 || WeaponIndex == 31)
		return 1	
	return 0
}
#endif
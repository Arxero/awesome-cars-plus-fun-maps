
/* AMX Mod X
*   Pick up present
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
*	This plugin allows admin add/remove/rotate/save presents on map ( ADMIN_KICK flag required).
*	When player touches present, it will dissapear and player will (or no) receive some weapons
*	or stuff (soon more than now), then present respawns with nice blast :]. Models for
*	presents are randomly chosen, so user can add as many, as he want.
*
*     VERY IMPORTANT!
*	Create an folder called "presents" in addons/amxmodx/config/ directory, otherwise
*	plugin won't be able to save presents origins!
*
*     COMMANDS
*	!add - adds a present at admin aim origin
*	!remove - removes a present (admin must aim at present)
*	!removeall - removes all presents from map
*	!save - saves all present created on map
*	!rotate - rotates a present (admin must aim at present)
*
*     MODULES
*	fakemeta
*
*     CVARS
*	present_on - turn plugin on/off
*	present_respawn_time - time between present disapear and respawn (must be float!)
*	present_blast - turns blast on/off
*	present_blast_color - color of the blast (default 255 255 255)
*	present_money - amount of received money
*
*	Changelog 
*	Version 2.0
*	 - Actuall version is 2.0, because i've totally cleaned up the code
*	 - New weapon randomizing system
*
*	Version 2.01
*	 - Fixed small bug with backpack ammo	
*	 - Added large and medium blast ring (nice effect ;])
*	 - Added CVAR for version recognize
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

//Models and sounds are randomly chosen, add as many, as you want

new const model_present[][] = { "models/present/w_present_halloween.mdl","models/present/w_present2_halloween.mdl" }

new const sound_respawn[][] = { "present/respawn.wav", "present/respawn2.wav" }
new const sound_pick[][] = { "present/pick.wav" }

//Customization end here!

//Some offsets 
#if cellbits == 32
const OFFSET_CSMONEY = 115
const OFFSET_AWM_AMMO  = 377 
const OFFSET_SCOUT_AMMO = 378
const OFFSET_PARA_AMMO = 379
const OFFSET_FAMAS_AMMO = 380
const OFFSET_M3_AMMO = 381
const OFFSET_USP_AMMO = 382
const OFFSET_FIVESEVEN_AMMO = 383
const OFFSET_DEAGLE_AMMO = 384
const OFFSET_P228_AMMO = 385
const OFFSET_GLOCK_AMMO = 386
const OFFSET_FLASH_AMMO = 387
const OFFSET_HE_AMMO = 388
const OFFSET_SMOKE_AMMO = 389
#else
const OFFSET_CSMONEY = 140
const OFFSET_AWM_AMMO  = 426
const OFFSET_SCOUT_AMMO = 427
const OFFSET_PARA_AMMO = 428
const OFFSET_FAMAS_AMMO = 429
const OFFSET_M3_AMMO = 430
const OFFSET_USP_AMMO = 431
const OFFSET_FIVESEVEN_AMMO = 432
const OFFSET_DEAGLE_AMMO = 433
const OFFSET_P228_AMMO = 434
const OFFSET_GLOCK_AMMO = 435
const OFFSET_FLASH_AMMO = 46
const OFFSET_HE_AMMO = 437
const OFFSET_SMOKE_AMMO = 438
#endif
const OFFSET_LINUX  = 5

//Primary weapons array (thanks Mercyllez)
new const g_primary_items[][] = { "weapon_galil", "weapon_famas", "weapon_m4a1", "weapon_ak47", "weapon_sg552", "weapon_aug", "weapon_scout",
				"weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_ump45", "weapon_mp5navy", "weapon_p90",
				"weapon_m249", "weapon_sg550", "weapon_g3sg1"}

//Secondary weapons array (thanks Mercyllez)				
new const g_secondary_items[][] = { "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_deagle", "weapon_fiveseven", "weapon_elite" }

//Max BackPack ammo array (thanks Mercyllez) 
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }
//Amount of gived ammo (thanks Mercyllez)
new const GIVEAMMO[] = { -1, 52, -1, 90, -1, 32, -1, 100, 90, -1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, -1, 35, 90, 90, -1,100 }
//Ammo ID array (thanks Mercyllez)
new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }

//Weapon BitSum (thanks Mercyllez)			
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)


//Pcvar variables		
new pcvar_on,pcvar_respawn_time,pcvar_blast,pcvar_blast_color,pcvar_money

//Rest of variables
new g_explo,g_money,g_ammo

//Task ID enum
enum (+= 100)
{
	TASK_PRIMARY = 100,
	TASK_SECONDARY
}


//Version information
new const VERSION[] = "2.01"

public plugin_init()
{
	register_plugin("Pick up present", VERSION, "FakeNick")
	pcvar_on = register_cvar("present_on","1")
	
	//Make sure that the plugin is on
	if(!get_pcvar_num(pcvar_on))
		return
	
	//Register dictionary
	register_dictionary("present.txt")
	
	//Register admin commands
	register_clcmd("say !add","func_add_present")
	register_clcmd("say !remove","func_remove_present")
	register_clcmd("say !removeall","func_remove_present_all")
	register_clcmd("say !save","func_save_origins")
	register_clcmd("say !rotate","func_rotate_present")
		
	//Some forwards
	register_forward(FM_Touch,"forward_touch")
	register_forward(FM_Think,"forward_think")
		
	//Cvars register
	pcvar_respawn_time = register_cvar("present_respawn_time","60.0")
	pcvar_blast = register_cvar("present_blast","1")
	pcvar_blast_color = register_cvar("present_blast_color","255 255 255")
	pcvar_money = register_cvar("present_money","300")
	
	//Only for version recognize
	register_cvar("present_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
	//Other stuff
	g_money = get_user_msgid("Money")
	g_ammo = get_user_msgid("AmmoPickup")
}
public plugin_precache()
{
	new i
	
	for(i = 0; i < sizeof model_present; i++)
		engfunc(EngFunc_PrecacheModel,model_present[i])
	
	for (i = 0; i < sizeof sound_respawn; i++)
		engfunc(EngFunc_PrecacheSound, sound_respawn[i])
	for (i = 0; i < sizeof sound_pick; i++)
		engfunc(EngFunc_PrecacheSound, sound_pick[i])
	
	g_explo = engfunc(EngFunc_PrecacheModel,"sprites/shockwave.spr")
}
public plugin_cfg()
{
	//Create some variables
	static sConfigsDir[64], sFile[128]
	
	//Get config folder directory
	get_configsdir(sConfigsDir, sizeof sConfigsDir - 1)
	
	//Get mapname
	static sMapName[32]
	get_mapname(sMapName, sizeof sMapName - 1)
	
	//Format .cfg file directory
	formatex(sFile, sizeof sFile - 1, "%s/presents/%s_presents_origins.cfg", sConfigsDir, sMapName)
	
	//If file doesn't exist return
	if(!file_exists(sFile))
		return
	
	//Some variables
	static sFileOrigin[3][32], sFileAngles[3][32], iLine, iLength, sBuffer[256]
	static sTemp1[128], sTemp2[128]
	static Float:fOrigin[3], Float:fAngles[3]
	
	//Read file
	while(read_file(sFile, iLine++, sBuffer, sizeof sBuffer - 1, iLength))
	{
		if((sBuffer[0]==';') || !iLength)
			continue
		
		strtok(sBuffer, sTemp1, sizeof sTemp1 - 1, sTemp2, sizeof sTemp2 - 1, '|', 0)
		
		parse(sTemp1, sFileOrigin[0], sizeof sFileOrigin[] - 1, sFileOrigin[1], sizeof sFileOrigin[] - 1, sFileOrigin[2], sizeof sFileOrigin[] - 1)
		
		fOrigin[0] = str_to_float(sFileOrigin[0])
		fOrigin[1] = str_to_float(sFileOrigin[1])
		fOrigin[2] = str_to_float(sFileOrigin[2])
		
		parse(sTemp2, sFileAngles[0], sizeof sFileAngles[] - 1, sFileAngles[1], sizeof sFileAngles[] - 1, sFileAngles[2], sizeof sFileAngles[] - 1)
		
		fAngles[0] = str_to_float(sFileAngles[0])
		fAngles[1] = str_to_float(sFileAngles[1])
		fAngles[2] = str_to_float(sFileAngles[2])
		
		//Spawn presents on origins saved in .cfg file
		func_spawn(fOrigin)
	}
}

/*================================================================================
 [Tasks]
=================================================================================*/

public task_primary(id)
{
	//Check player id
	id -= TASK_PRIMARY
	
	//Make usre that player is alive
	if(!is_user_alive(id))
		return
	
	//Give him primary weapon
	func_give_item_primary(id, random_num(0, sizeof g_primary_items - 1))
}
public task_secondary(id)
{
	//Check player id
	id -= TASK_SECONDARY
	
	//Make usre that player is alive
	if(!is_user_alive(id))
		return
		
	//Give him secondary weapon	
	func_give_item_secondary(id, random_num(0, sizeof g_secondary_items - 1))
}

/*================================================================================
 [Main functions]
=================================================================================*/
public func_add_present(id)
{	
	//Check command access
	if(!access(id,ADMIN_KICK))
		return
	
	//Create some variables
	new Float:fOrigin[3],origin[3],name[32],map[32]
	
	//Get player origins
	get_user_origin(id,origin,3)
	
	//Make float origins from integer origins
	IVecFVec(origin,fOrigin)
	
	//Check the player aiming
	if((engfunc(EngFunc_PointContents, fOrigin) != CONTENTS_SKY) && (engfunc(EngFunc_PointContents, fOrigin) != CONTENTS_SOLID))
	{
		//Get his name and map name for log creating
		get_user_name(id,name,sizeof name - 1)
		
		get_mapname(map,sizeof map - 1)
		
		//Create log file or log admin command
		log_to_file("presents.log","[%s] has created present on map %s",name,map)
		
		//Finally spawn present
		func_spawn(fOrigin)
		
		//Print success and save info information
		client_print(id,print_chat,"%L",LANG_PLAYER,"SUCC_ADD",origin[0],origin[1],origin[2])
		client_print(id,print_chat,"%L",LANG_PLAYER,"SAVE_INFO")
	}else{
		//That location is unavaiables, so print information
		client_print(id,print_chat,"%L",LANG_PLAYER,"LOCATION_UN")
	}
	
	
}
public func_remove_present(id)
{
	//Check command access
	if(!access(id,ADMIN_KICK))
		return
	
	//Create some variables
	static ent, body,name[32],map[32]
	
	//Check player aiming
	get_user_aiming(id, ent, body)
	
	//Check ent validity
	if(pev_valid(ent))
	{
		//Check entity classname
		static classname[32]
		pev(ent, pev_classname, classname, sizeof classname - 1)
		
		//Player is aiming at present
		if(!strcmp(classname, "present", 1))
		{
			//Get user name and map name for log creating
			get_user_name(id,name,sizeof name - 1)
			get_mapname(map,sizeof map - 1)
			
			//Create log file or log admin command
			log_to_file("presents.log","[%s] has removed present from map %s",name,map)
			
			//Finalyl remove the entity
			engfunc(EngFunc_RemoveEntity, ent)
			
			//Print success inforamtion
			client_print(id, print_chat, "%L",LANG_PLAYER,"SUCC_REMOVE")
		}else
		{
			//Player must aim at present
			client_print(id, print_chat, "%L",LANG_PLAYER,"PRESENT_AIM")
		}
	}
}
public func_remove_present_all(id)
{
	//Check command access
	if(!access(id, ADMIN_KICK))
		return
	
	//Create some variables
	new ent = -1,count,name[32],map[32]
	count = 0 
	
	//Find presents
	while((ent = fm_find_ent_by_class(ent,"present")))
	{
		//Increase count
		count++
		//Remove presents
		engfunc(EngFunc_RemoveEntity,ent)
	}
	//Print information
	client_print(id,print_chat,"%L",LANG_PLAYER,"REMOVE_ALL",count)
	
	//Get player name and map name
	get_user_name(id,name,sizeof name - 1)
	get_mapname(map,sizeof map - 1)
	
	//Log command to file
	log_to_file("presents.log","[%s] has removed all presents from map %s",name,map)
	
	//Print save information
	client_print(id,print_chat,"%L",LANG_PLAYER,"SAVE_INFO")
}
public func_save_origins(id)
{
	//Check command access
	if(!access(id, ADMIN_KICK))
		return
	
	//Create some variables
	static sConfigsDir[64], sFile[128],name[32],map[32]
	
	//Get config folder directory
	get_configsdir(sConfigsDir, sizeof sConfigsDir - 1)
	
	//Get map name
	static sMapName[32]
	get_mapname(sMapName, sizeof sMapName - 1)
	
	//Format .cfg file directory
	formatex(sFile, sizeof sFile - 1, "%s/presents/%s_presents_origins.cfg", sConfigsDir, sMapName)
	
	//If file already exist, delete file
	if(file_exists(sFile))
		delete_file(sFile)
	
	//Some variables
	new iEnt = -1, Float:fEntOrigin[3], Float:fEntAngles[3], iCount
	static sBuffer[256]
	
	//Find presents on this map
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", "present")))
	{
		//Get origins and angles
		pev(iEnt, pev_origin, fEntOrigin)
		pev(iEnt, pev_angles, fEntAngles)
		
		formatex(sBuffer, sizeof sBuffer - 1, "%f %f %f | %f %f %f", fEntOrigin[0], fEntOrigin[1], fEntOrigin[2], fEntAngles[0], fEntAngles[1], fEntAngles[2])
	
		//Create file
		write_file(sFile, sBuffer, -1)
		
		//Increase count variable
		iCount++
	}
	//Get user name and map name
	get_user_name(id,name,sizeof name - 1)
	get_mapname(map,sizeof map - 1)
	
	//Log admin command
	log_to_file("presents.log","[%s] has saved presents on map %s",name,map)
	
	//Print success information
	client_print(id, print_chat, "%L",LANG_PLAYER,"SUCC_SAVE", iCount,sMapName)
}
public func_rotate_present(id)
{
	//Check command access
	if(!access(id, ADMIN_KICK))
		return
		
	//Some variables
	static ent, body,name[32],map[32]
	
	//Get user aiming
	get_user_aiming(id, ent, body)
	
	//Check entity validity
	if(pev_valid(ent))
	{
		//Check classname
		static sClassname[32]
		pev(ent, pev_classname, sClassname, sizeof sClassname - 1)
		
		//Player is aiming at present
		if(!strcmp(sClassname, "present", 1))
		{
			//Get angles
			static Float:fAngles[3]
			pev(ent, pev_angles, fAngles)
			
			//Rotate present
			fAngles[1] += 90.0
			set_pev(ent, pev_angles, fAngles)
			
			//Get user name and map name
			get_user_name(id,name,sizeof name - 1)
			get_mapname(map,sizeof map - 1)
			
			//Log admin command
			log_to_file("presents.log","[%s] has rotated present on map %s",name,map)
			
			//Print success information
			client_print(id, print_chat, "%L",LANG_PLAYER,"SUCC_ROTATE")
		}else{
			//Print failure information
			client_print(id, print_chat, "%L",LANG_PLAYER,"PRESENT_AIM")
		}
	}
}
public func_spawn(Float:origin[3])
{
	//Create new entity	
	new ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	
	//Set classname to "present"
	set_pev(ent,pev_classname,"present")
	
	//Set entity origins
	engfunc(EngFunc_SetOrigin,ent,origin)
	
	//Create blast effect
	func_make_blast(origin)
	
	//Emit spawn sound
	engfunc(EngFunc_EmitSound,ent,CHAN_AUTO,sound_respawn[random_num(0, sizeof sound_respawn - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
	
	//size variables
	static Float:fMaxs[3] = { 2.0, 2.0, 4.0 }
	static Float:fMins[3] = { -2.0, -2.0, -4.0 }
		
	//Set random player model
	engfunc(EngFunc_SetModel,ent,model_present[random_num(0,sizeof model_present - 1)])
	
	//Spawn entity
	dllfunc(DLLFunc_Spawn,ent)
	//Make it solid
	set_pev(ent,pev_solid,SOLID_BBOX)
	//Set entity size
	engfunc(EngFunc_SetSize,ent,fMins,fMaxs)
}
//From forstnades by Avalanche
public func_make_blast(Float:fOrigin[3])
{
	if(!get_pcvar_num(pcvar_blast))
		return
	
	//Create origin variable
	new origin[3]
	
	//Make float origins from integer origins
	FVecIVec(fOrigin,origin)
	
	//Get blast color
	new Float:rgbF[3], rgb[3]
	func_get_rgb(rgbF)
	FVecIVec(rgbF,rgb)
	
	//Finally create blast
	
	//smallest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + 385)
	write_short(g_explo)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(rgb[0])
	write_byte(rgb[1])
	write_byte(rgb[2])
	write_byte(100)
	write_byte(0)
	message_end()
	
	// medium ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + 470)
	write_short(g_explo)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(rgb[0])
	write_byte(rgb[1])
	write_byte(rgb[2])
	write_byte(100)
	write_byte(0)
	message_end()

	// largest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + 555)
	write_short(g_explo)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(rgb[0])
	write_byte(rgb[1])
	write_byte(rgb[2])
	write_byte(100)
	write_byte(0)
	message_end()
	
	//Create nice light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(floatround(240.0/5.0))
	write_byte(rgb[0])
	write_byte(rgb[1])
	write_byte(rgb[2])
	write_byte(8)
	write_byte(60)
	message_end()
}
//From frostnades by Avalanche
public func_get_rgb(Float:rgb[3])
{
	static color[12], parts[3][4]
	get_pcvar_string(pcvar_blast_color,color,11)
	
	parse(color,parts[0],3,parts[1],3,parts[2],3)
	rgb[0] = floatstr(parts[0])
	rgb[1] = floatstr(parts[1])
	rgb[2] = floatstr(parts[2])
}
//Check player BackPack ammo (from ZP by Mercyllez)
public func_check_ammo(id)
{
	//Create some variables
	static weapons[32],num,weaponid
	num = 0
	
	get_user_weapons(id,weapons,num)
	
	for (new i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		
		if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM) // primary
		{
			if (fm_get_user_bpammo(id, weaponid) < MAXBPAMMO[weaponid]-GIVEAMMO[weaponid])
			{
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_ammo, _, id)
				write_byte(AMMOID[weaponid]) // ammo id
				write_byte(GIVEAMMO[weaponid]) // ammo amount
				message_end()
				
				// Increase BP ammo
				fm_set_user_bpammo(id, weaponid, fm_get_user_bpammo(id, weaponid) + GIVEAMMO[weaponid])
				
			}else if (fm_get_user_bpammo(id, weaponid) < MAXBPAMMO[weaponid])
			{
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_ammo, _, id)
				write_byte(AMMOID[weaponid]) // ammo id
				write_byte(MAXBPAMMO[weaponid] - fm_get_user_bpammo(id, weaponid)) // ammo amount
				message_end()
				
				// Reached the limit
				fm_set_user_bpammo(id, weaponid, MAXBPAMMO[weaponid])
			}
		}else if ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM) // secondary
		{	
			// Check if we are close to the BP ammo limit
			if (fm_get_user_bpammo(id, weaponid) < MAXBPAMMO[weaponid]-GIVEAMMO[weaponid])
			{
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_ammo, _, id)
				write_byte(AMMOID[weaponid]) // ammo id
				write_byte(GIVEAMMO[weaponid]) // ammo amount
				message_end()
				
				// Increase BP ammo
				fm_set_user_bpammo(id, weaponid, fm_get_user_bpammo(id, weaponid) + GIVEAMMO[weaponid])
				
			}
			else if (fm_get_user_bpammo(id, weaponid) < MAXBPAMMO[weaponid])
			{
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_ammo, _, id)
				write_byte(AMMOID[weaponid]) // ammo id
				write_byte(MAXBPAMMO[weaponid] - fm_get_user_bpammo(id, weaponid)) // ammo amount
				message_end()
				
				// Reached the limit
				fm_set_user_bpammo(id, weaponid, MAXBPAMMO[weaponid])
			}
		}
	}
}
public func_give_item_primary(id,weapon)
{
	//Give player primary weapon
	fm_give_item(id,g_primary_items[weapon])
	
	//Check his back pack ammo
	func_check_ammo(id)
}
public func_give_item_secondary(id,weapon)
{
	//Give player secondary weapon
	fm_give_item(id,g_secondary_items[weapon])
	
	//Check his back pack ammo
	func_check_ammo(id)
}
/*================================================================================
 [Forwards]
=================================================================================*/
public forward_touch(ent,id)
{
	//Check entity validity
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	//Create classname variable
	static class[20]
	
	//Get class
	pev(ent,pev_classname,class,sizeof class - 1)
	
	//Check classname
	if(!equali(class,"present"))
		return FMRES_IGNORED
	
	//Make sure that toucher is alive
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	//Make present not solid
	set_pev(ent,pev_solid,SOLID_NOT)
	//Don't draw that present anymore (thanks connor)
	set_pev(ent,pev_effects,EF_NODRAW)
	//Set respawn time
	set_pev(ent,pev_nextthink,get_gametime() + get_pcvar_float(pcvar_respawn_time))
	
	//Emit pick sound
	engfunc(EngFunc_EmitSound,ent,CHAN_ITEM,sound_pick[random_num(0, sizeof sound_pick - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
	
	//Randomize player reward
	switch(random_num(0,2))
	{
		//Give him primary weapon
		case 0 : 
		{
			client_cmd(id,"slot1;drop")
			remove_task(id + TASK_PRIMARY)
			set_task(0.2,"task_primary",id + TASK_PRIMARY)
		}
		//Give him secondary weapon
		case 1 :
		{
			client_cmd(id,"slot2;drop")
			remove_task(id + TASK_SECONDARY)
			set_task(0.2,"task_secondary",id + TASK_SECONDARY)
		}
		//Give him cash
		case 2 :
		{
			fm_set_user_money(id,fm_get_user_money(id) + get_pcvar_num(pcvar_money))
		}
		
	}
	
	return FMRES_IGNORED
}
public forward_think(ent)
{
	//Create class variable
	new class[20]
	
	//Get entity class
	pev(ent,pev_classname,class,sizeof class - 1)
	
	//Check entity class
	if(!equali(class,"present"))
		return FMRES_IGNORED
	
	//If that present isn't drawed, time to respawn it
	if(pev(ent,pev_effects) & EF_NODRAW)
	{
		//Create origin variable
		new Float:origin[3]
		
		//Get origins
		pev(ent,pev_origin,origin)
		
		//Emit random respawn sound
		engfunc(EngFunc_EmitSound,ent,CHAN_AUTO,sound_respawn[random_num(0, sizeof sound_respawn - 1)],1.0,ATTN_NORM,0,PITCH_NORM)
		
		//Make nice blast (from frostnades by Avalanche)
		func_make_blast(origin)
		
		//Make present solid
		set_pev(ent,pev_solid,SOLID_BBOX)
		
		//Draw present
		set_pev(ent,pev_effects, pev(ent,pev_effects)  & ~EF_NODRAW)
	}
	
	return FMRES_IGNORED
}
/*================================================================================
 [Stocks]
=================================================================================*/
//Thanks Avalanche for this stock
stock fm_set_user_money(id,money,flash=1)
{
	set_pdata_int(id,OFFSET_CSMONEY,money,OFFSET_LINUX)

	message_begin(MSG_ONE,g_money,{0,0,0},id)
	write_long(money)
	write_byte(flash)
	message_end()
}
//Thanks Avalanche for this stock
stock fm_get_user_money(id)
{
	return get_pdata_int(id,OFFSET_CSMONEY,OFFSET_LINUX)
}
//From Zombie Plague by Mercyllez
stock fm_set_user_bpammo(id, weapon, amount)
{
	static offset
	
	switch(weapon)
	{
		case CSW_AWP: offset = OFFSET_AWM_AMMO
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: offset = OFFSET_SCOUT_AMMO
		case CSW_M249: offset = OFFSET_PARA_AMMO
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: offset = OFFSET_FAMAS_AMMO
		case CSW_M3,CSW_XM1014: offset = OFFSET_M3_AMMO
		case CSW_USP,CSW_UMP45,CSW_MAC10: offset = OFFSET_USP_AMMO
		case CSW_FIVESEVEN,CSW_P90: offset = OFFSET_FIVESEVEN_AMMO
		case CSW_DEAGLE: offset = OFFSET_DEAGLE_AMMO
		case CSW_P228: offset = OFFSET_P228_AMMO
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: offset = OFFSET_GLOCK_AMMO
		case CSW_FLASHBANG: offset = OFFSET_FLASH_AMMO
		case CSW_HEGRENADE: offset = OFFSET_HE_AMMO
		case CSW_SMOKEGRENADE: offset = OFFSET_SMOKE_AMMO
		default: return
	}
	
	set_pdata_int(id, offset, amount, OFFSET_LINUX)
}
//From Zombie Plague by Mercyllez
stock fm_get_user_bpammo(id, weapon)
{
	static offset
	
	switch(weapon)
	{
		case CSW_AWP: offset = OFFSET_AWM_AMMO
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: offset = OFFSET_SCOUT_AMMO
		case CSW_M249: offset = OFFSET_PARA_AMMO
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: offset = OFFSET_FAMAS_AMMO
		case CSW_M3,CSW_XM1014: offset = OFFSET_M3_AMMO
		case CSW_USP,CSW_UMP45,CSW_MAC10: offset = OFFSET_USP_AMMO
		case CSW_FIVESEVEN,CSW_P90: offset = OFFSET_FIVESEVEN_AMMO
		case CSW_DEAGLE: offset = OFFSET_DEAGLE_AMMO
		case CSW_P228: offset = OFFSET_P228_AMMO
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: offset = OFFSET_GLOCK_AMMO
		case CSW_FLASHBANG: offset = OFFSET_FLASH_AMMO
		case CSW_HEGRENADE: offset = OFFSET_HE_AMMO
		case CSW_SMOKEGRENADE: offset = OFFSET_SMOKE_AMMO
		default: return -1
	}
	
	return get_pdata_int(id, offset, OFFSET_LINUX)
}

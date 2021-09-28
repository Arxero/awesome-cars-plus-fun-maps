/*
Runemod is a serverside modification powered by AMXmodX, that spawns runes(powerups) around  
the map, for the players to pick up. 
Runemod includes lots of unique powers, adding an extra element and a whole lot of fun to the game. 

Known issues:
If a player is killed, if he has a rune that should resisted some damage. It will not work ( IE the plugin cannot resurect him yet)

Credits
kaddar for orginal plugin
sawce for idea/help on making the plugin "API"
PMOnoTo for code bits, and for updating callfunc.

sv_runemodsettings
a == Runes bounce
b == Update spawnvector file with new spawn points ( Dont disable unless you know what your doing )
c == Update spawn points based on player movment ( Dont disable unless you know what your doing )
d == Remove runes and round end
e == Public message saying what runes where spawned
f == Prevent runes from spawing to close to one another
g == Automaticly spawn change the number of runes spawned, based on the amount of players on the server. With this option enabled: sv_runes becomes the minimaly spawned runes, with it off. It becomes the maximum spawned runes
h == Only 1 of every rune allowed 1 point in time
i == Spawn every rune(Thats not in use)
j == DM based spawning ( This means runes are spawned based on time, not when round starts or ends )
k == Does extra checks on new rune spawnpoints, making sure its not to close to other spawn points
l == When looking at runes, show the rune name center of screen
m == Clients automaticly drop old runes,when they  walk on a new rune

sv_runes <number/letters> (read about sv_runemodsettings with the +/- g setting )

Changelog 
 2.2.2
	- Changed: You rune is no lonegr droped with option m and walking over pickupand forget rune
	- Fixed: A few run time errors
 2.2.1
	-Added: Runes are now given some speed when spawned
	-Added: With DM based unused runes are removed after 2 rounds
	-Fixed: Runes not being removed on death with DM based spawning

 2.2.0
	- Added: Support for axmmodx language system ( English & German in current release, if anyone wants to translate feel free to send me a new runemod.txt file )
	- Added: sv_runemodsettings m  ( Clients automaticly drop old runes,when they  walk on a new rune )
	- Added: runemod_disabled  cvar added, change to 1 to disable runemod ( Is checked on round end )
	- Added: Runemod now checks if the rune spawn vector folder exists ( addons/amxmodx/data/runemod )
	- Changed: Optimised finding runes where the player is looking somewhat
	- Changed: Greatly optimised finding what runes players where looking at

 2.1.2
 	- Added: Option l, "When looking at a rune, shows the rune name center of screen"  ( Somewhat CPU intensive )
 	
 2.1.1
 	- Fixed: Typo when picking up 1 time rune ( Thx to: SoulReaper )
 	- Fixed: Lots of runes in 1 location could overflow a client or crash server
 
 2.1.0
 	- Added: Base plugin will now clean up bad spawn points, if there are no players on the server
 	- Added: Base plugin will now only hook events it needs ( If none of your runes require info about Damage, the Damage event is not hooked )
 	- Added: Option k. Does extra checks on newly made spawnpoint, making sure its not to close to other spawn points
 	- Added: kaddars rune spawn generation ( The one from 1.0.170 runemod ), with some minor changes. ( Used with when no spawn vector file is found )
 	- Changed: sv_runemodsettings uses letters instead of numbers ( Should be easyer for new admins, old admins dont have change anything )
 	- Fixed: Spawnpoints would not allways be generated
 	- Fixed: Spawnpoints could be generated based on hltv

 2.0.0
 	- Added: say runehelp Shows the runemod help page
 	- Changed: You only see the XX droped XX rune, when you manualy drop a rune 
 	- Fixed: When spawing over 10 runes, and not having option 128(Only uniqe runes) on. Would make only the first rune spawn
*/
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include "runemod.inc"

#pragma dynamic 6144

new const Plugin_Version[] = "2.2.2"

new g_MaxPlayers
new g_MaxEnts
new g_NumberOfRunes									// The number of runes registered to this base plugin
new g_NumberOfSpawnPoints							// The number of spawn points on this map
new g_SpawnOrigin[MAX_SPAWNPOINTS+1][3]
new g_UsersOnServer
new g_IsRunemodDisabled								// Since pause() native still has issues, we also use this array to check.

new g_LastUpdatedSpawnVec							// This Array contains the index of the last updated spawn vector
new gs_SaveFile[128]								// This where we save the location of the spawnvectors
new g_RuneEntNum[MAX_RUNESINGAME+1][3]				// [0] == This array contains the Ent number of a the runes, used by pfn_touch() so we dont have to do string comparison  | [1] == Contains the RuneIndex of the spesfic rune
new g_LastDescReturned[MAX_PLUGINS+1]						// Contains the last describtion showed for this rune
new g_RunesInWorld									// Used to found the amount of Runes in world ( world means their world, not on players)
new g_UserHasRune[MAXPLAYERS+1]
new gs_MOTDMessage[1536]
new g_Warn[MAXPLAYERS+1]							// This array is used so we only warn a player once about allready having a rune called by pnf_toch
new g_LastRune[MAXPLAYERS+1]
new g_KillUser[MAXPLAYERS+1]						// 0 == VictimID | 1 == KillerID | Since there is no next frame function in amxx, we make one. Killing ppl inside a Message is bad, we therefor make a mark the player for death. And kill him next server frame
new gs_WeaponName[MAXPLAYERS+1][40]
new g_IsZooming[MAXPLAYERS+1]

// These are the arrays where runemod_base saves settings
new g_UseNewModel									// 1 means we used the custom runemod model
new g_MaxRunes										// This is the max runes to be ingame ( read from sv_maxrunes)
new g_Settings
new g_UseExternalRuneList								// used as a bool, if we should  use external system for runelist
new gs_MOTDUrl[128]									// the actual url

#define RUNE_BOUNCE			1
#define SAVE_RUNESVEC			2
#define SAVE_SPAWNUPDATE		4
#define REMOVE_RUNEONROUNDSTART		8
#define TELLWHATRUNESSPANWED		16
#define ONLYUNIQUERUNES			128
#define DM_BasedSpawn			512
#define ExtraSpawnPointCheck		1024
#define ShowWhatRuneIsBeingLookedat	2048
#define AutoDropRune			4096

#define TASK_REMOVERUNESONROUNDEND	8096

#define RUNE_AGE 2

// API related stuff (None of the arrays bellow are 0 based)
new g_PluginIndex[MAX_PLUGINS+1]
new g_FuncIndex[MAX_PLUGINS+1][12]

#define Func_CurWeaponChange 	0
#define Func_CurWeapon 			1
#define Func_DeathMsg	 		2
#define Func_Damage 			3
#define Func_DamageDone 		4
#define Func_LockSpeedChange 	5
#define Func_UnLockSpeedChange 	6
#define Func_NewRound 			7
#define Func_RoundStarted 		8
#define Func_PickUpRune 		9
#define Func_DropedRune 		10


/*
[0] API_CurWeaponChange
[2] API_CurWeapon
[3] API_DeathMsg
[4] API_Damage
[5] API_DamageDone
[6] API_LockSpeedChange
[7] API_UnLockSpeedChange
[8] API_NewRound
[9] API_RoundStarted
[10] API_PickUpRune
[11] API_DropedRune
*/
new gs_RuneName[MAX_PLUGINS+1][MAX_PLUGIN_RUNENAME_SIZE+1]
new gs_RuneDesc[MAX_PLUGINS+1][MAX_PLUGIN_RUNEDESC_SIZE+1]
new g_RuneColor[MAX_PLUGINS+1][3]
new g_RuneFlags[MAX_PLUGINS+1]
new g_RuneDisabled[MAX_PLUGINS+1]
new g_CurWeapon[MAXPLAYERS+1]	// Contains the index of the currentweapon, saved here so we know when to call Weapon change event

//
new g_CurHooks
new g_DamageHooks
new g_SpeedHooks

// We now make Ints used to store MessageIDS
new g_MsgShake
new g_MsgDeathMsg
new g_MsgSmoke
new g_MsgExplode
new g_MsgFade

#if HTML_MOTD == 1
new gs_Test[3]	// Since returning strings in small is somewhat doggy, we use this way of transfering the string
#endif

public plugin_init() 
{
	register_plugin("RuneMod Base",Plugin_Version, "EKS")
	register_dictionary("runemod.txt")
	register_cvar("Runemod",Plugin_Version,FCVAR_SERVER)
	register_cvar("runemod_disabled","0")
	register_cvar("runemod_runelisturl","none")
	
	g_MaxPlayers = get_maxplayers()
	g_MaxEnts = get_global_int(GL_maxEntities)
	
	g_MsgShake = get_user_msgid("ScreenShake")
	g_MsgDeathMsg = get_user_msgid("DeathMsg")
	g_MsgFade = get_user_msgid("ScreenFade")
	
	register_event("DeathMsg","Event_DeathMsg","a")
	
	register_clcmd("droprune","CMD_DropRune",0," - This command is used to drop runes")
	register_clcmd("dropitem","CMD_DropRune",0," - This command is used to drop runes")
	
	register_clcmd("say","Check_Chat",0," - This command is used to drop runes")
	register_clcmd("say_team","Check_Chat",0," - This command is used to drop runes")
	
	register_cvar("sv_runes","5")
	register_cvar("sv_runemodsettings","bcefghkl")
	
	register_concmd("amx_genrunelist","CmdGenRuneList",ADMIN_RCON," - Debug command used to clean spawn vector files")

#if MOD == MOD_CSTRIKE
	register_event("SendAudio","Event_EndRound","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")
	register_logevent("Event_RoundStarted",2,"0=World triggered","1=Round_Start" )
#endif

#if debug == 1
	register_concmd("amx_genspawns","Debug_GenSpawns",ADMIN_RCON," - Debug command used to clean spawn vector files")
	register_concmd("amx_cleanspawns","Debug_CleanSpawnPoints",ADMIN_RCON," - Debug command used to clean spawn vector files")
	register_concmd("amx_spawnrune","Debug_SpawnRune",ADMIN_RCON," - Debug command used to spawn runes")
	register_concmd("amx_giverune","Debug_GiveRune",ADMIN_RCON," - Debug command used to spawn runes")
	register_concmd("amx_loadspawns","Debug_LoadSpawns",ADMIN_RCON," - Debug command used to spawn runes")
	register_concmd("amx_savespawns","Debug_SaveSpawns",ADMIN_RCON," - Debug command used to spawn runes")
	register_concmd("amx_saverunes","Debug_SaveRunes",ADMIN_RCON," - Debug command used to save the runes active on the server")
#endif
	GetSpawnVec()			// We load the spawn vectors
}
public plugin_cfg()
{
	g_IsRunemodDisabled = get_cvar_num("runemod_disabled")
	g_MaxRunes = get_cvar_num("sv_runes")
	
	new CvarSetting[30]
	get_cvar_string("sv_runemodsettings",CvarSetting,29)
	
	if(strlen(CvarSetting) >= 2 && isalpha(CvarSetting[0]) && isalpha(CvarSetting[1]))
		g_Settings = read_flags(CvarSetting)
	else
		g_Settings = get_cvar_num("sv_runemodsettings")
	
	if(g_Settings & ShowWhatRuneIsBeingLookedat)		// If we want the Task_ShowMessage() func to show what runes players are looking at, We increase how often this task is run
	{
		set_task(0.5,"Task_ShowMessage",128,_,_,"b")
	}
	else
		set_task(2.0,"Task_ShowMessage",128,_,_,"b")
	
	get_cvar_string("runemod_runelisturl",gs_MOTDUrl,127)
	if(equal(gs_MOTDUrl,"none"))
		g_UseExternalRuneList = 0
	else
	{
		g_UseExternalRuneList = 1
	}
}

/* **************************************************** Start of code for start / end round ( Or DM based spawn code ) *****************************************************/
#if MOD == MOD_CSTRIKE
public Task_DMSpawnRunes()
{
	new RunesSpawnedList[MAX_PLUGINS+1],RunesSpawnedListCount = 0
	new MaxRunes = GetMaxRunes()
	new Runes2Spawn = GetNumOfRunes2Spawn()
	// Now we know how many runes we want to spawn. We start the spawning the runes
	
	if(g_Settings & TELLWHATRUNESSPANWED && (Runes2Spawn <= 0 || !Runes2Spawn))
	{
		client_print(0,print_chat,"%L",LANG_PLAYER,"BaseNoSpawnedRunes",g_UserHasRune[0],g_RunesInWorld)
		return PLUGIN_CONTINUE
	}
	else 	// We now start spawing the runes
	{
		if(g_Settings & TELLWHATRUNESSPANWED) client_print(0,print_chat,"%L",LANG_PLAYER,"BaseDMRunesSpawned",g_UserHasRune[0],g_RunesInWorld,Runes2Spawn,MaxRunes)
		new Message[200],SpawnPoint,RuneIndex
		for(new i=1;i<=Runes2Spawn;i++)
		{
			SpawnPoint = random_num(1,g_NumberOfSpawnPoints)
			RuneIndex = RandomRuneIndex(Runes2Spawn)
			if(RuneIndex == -1) break
			
			if(g_Settings & TELLWHATRUNESSPANWED)
			{
				RunesSpawnedList[RunesSpawnedListCount] = RuneIndex
				RunesSpawnedListCount++
			}
				
			if(g_Settings & 32) 		// This means we dont want the runes to spawn to close.
			{
				new EntNum = SpawnRune(RuneIndex,g_SpawnOrigin[SpawnPoint])
				new LocStatus = CheckDistance(EntNum,SpawnPoint) 				// We check the the Spawn location the rune was spawned at, and 
				
				if(LocStatus == 2) 		// This means the newly spawned rune was to close to 1 of the other runes. We now try 5 random other locations to see if their free
				{
					new CPS=0			// Just incase, we will only check 5 diffrent spawn locations
					while( LocStatus == 2 && CPS < 5)
					{
						CPS++
						SpawnPoint = random_num(1,g_NumberOfSpawnPoints)
						LocStatus = CheckDistance(EntNum,SpawnPoint)
					}
					set_origin(EntNum,g_SpawnOrigin[SpawnPoint])
				}
			}
			else
				SpawnRune(RuneIndex,g_SpawnOrigin[SpawnPoint])
		}
		if(g_Settings & TELLWHATRUNESSPANWED) 
		{
			for(new i=1;i<=g_MaxPlayers;i++) if(is_user_connected(i))
			{
				for(new b=0;b<RunesSpawnedListCount;b++)
				{
					new ri = RunesSpawnedList[b]
					if(b == 0) // We do this so we get a nice comma seperatetion of the runes.
					{
						if(g_RuneFlags[ri] & API_USELANGSYSTEM)
							format(Message,199,"%L",i,gs_RuneName[ri])
						else
							format(Message,199,"%s",gs_RuneName[ri])
					}
					else
					{
						if(g_RuneFlags[ri] & API_USELANGSYSTEM)
							format(Message,199,"%s,%L",Message,i,gs_RuneName[ri])
						else
							format(Message,199,"%s,%s",Message,gs_RuneName[ri])
							
					}
				}
				client_print(i,print_chat,"%L",LANG_PLAYER,"BaseRunesSpawnedNames",Message)
			}
#if debug == 1
			server_print("[Runemod Debug] %s was spawned ( %d )",Message,Runes2Spawn)
#endif
		}
		return PLUGIN_CONTINUE		
	}
	return PLUGIN_CONTINUE
}
public Event_EndRound() // When this event is called the round has ended. We now remove the runes from the world, and prepair to spawn new once. We also tell all runes that runepowers now should be disabled
{
	new DidStatusChange = get_cvar_num("runemod_disabled")
	if(DidStatusChange != g_IsRunemodDisabled)
	{
		if(DidStatusChange == 1)		 //This means we want to disable runemod
		{
			API_PluginShutDown()
		}
		else
		{
			API_PluginStart()
			g_IsRunemodDisabled = 0
		}
	
	}
	
	if(g_IsRunemodDisabled) return PLUGIN_CONTINUE
	
	RemoveBadRunes()
#if debug == 1
	server_print("[Runemod Debug] Round ended")
#endif		
	remove_task(64) // We dont want to update spawn vectors once ppl are in their spawns. We remove and re add the task
	
	if(g_Settings & DM_BasedSpawn)
	{
		for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0] > 0)
		{
			if(g_RuneEntNum[i][RUNE_AGE] > MAX_RUNEAGE)
				RemoveRuneFromWorld(g_RuneEntNum[i][0])
			else
				g_RuneEntNum[i][RUNE_AGE]++
		}		
		remove_task(256)
		StartNewRound()
		return PLUGIN_CONTINUE
	}
	if(g_Settings & REMOVE_RUNEONROUNDSTART)
	{
		for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i])
			RemoveRuneFromPlayer(i)
		for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0])
			RemoveRuneFromWorld(g_RuneEntNum[i][0])
	}
	else
	{
		set_task(6.0,"Task_RemoveRunes",TASK_REMOVERUNESONROUNDEND,_,_,"a",1)		
	}
	
	for(new i=1;i<=g_MaxPlayers;i++) 
	{
		g_Warn[i] = 0
		g_LastRune[i] = 0 // We now remove tasks regard the last rune the user had, and reset the array that stored this info
		remove_task(i+32)
	}
	StartNewRound() // We inform the runes plugins that a new round is being started, and all runepowers should be reset
	return PLUGIN_CONTINUE
}

public Task_RemoveRunes()
{
	remove_task(TASK_REMOVERUNESONROUNDEND)
	for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0])
	{
		RemoveRuneFromWorld(g_RuneEntNum[i][0])
	}	
}
stock GetMaxRunes()
{
	new MaxRunes=0
	if(g_Settings & 64) 				// This means we should calculate the number of runes to spawn based on how many players are on the server
	{
		if(g_Settings & 256)			// Means we are spawning every rune the server has
		{
			MaxRunes = g_NumberOfRunes
		}
		else
		{
			new VailPlayers=0
			for(new i=1;i<=g_MaxPlayers;i++) if(is_user_connected(i))
				VailPlayers++
	
			MaxRunes = floatround(VailPlayers * 0.5)
			
			if(g_MaxRunes > MaxRunes)	// If the sv_runes cvar is set higher then the number we got based on the player count, we make new value based on the cvar instead
				MaxRunes = g_MaxRunes
		}
	}
	else if(g_Settings & 256)			// Means we are spawning every rune the server has
	{
		MaxRunes = g_NumberOfRunes
	}	
	else
		MaxRunes = g_MaxRunes
		
	return MaxRunes
}
stock GetNumOfRunes2Spawn()	// This is the functions used to Calculate the number runes to spawn
{
	new Runes2Spawn=0
	if(g_Settings & 64)  // This means we should calculate the number of runes to spawn based on how many players are on the server
	{
		new VailPlayers					// A vaild player is a player, thats connected and does not have any runes
		for(new i=1;i<=g_MaxPlayers;i++) if(is_user_connected(i) && !g_UserHasRune[i])
			VailPlayers++

		Runes2Spawn = floatround(VailPlayers * 0.5)
	
		if(g_MaxRunes > Runes2Spawn)	// If the sv_runes cvar is set higher then the number we got based on the player count, we make new value based on the cvar instead
			Runes2Spawn = g_MaxRunes

		if(g_Settings & ONLYUNIQUERUNES)	// If the automatic generation gets more then the number of unqie runes, we fix it
		{
			new RunesLeft=0
			for(new i=1;i <= g_NumberOfRunes;i++)
			{
				if(!IsRuneEnt(0,4,i) && !HasUserThisRune(i) && !g_RuneDisabled[i])
					RunesLeft++
			}
			if(Runes2Spawn > RunesLeft)
				Runes2Spawn = RunesLeft
		}
	}
	else if(g_Settings & 256)			// Means we are spawning every rune the server has
	{
		Runes2Spawn = g_NumberOfRunes - ( g_RuneDisabled[0] + g_UserHasRune[0] + g_RunesInWorld )
	} 
	else								// This means we are spawing a checking the sv_maxrunes cvar.( Or the vaule that has been read into g_MaxRunes )
	{
		Runes2Spawn = g_MaxRunes - ( g_UserHasRune[0] + g_RunesInWorld )
	}
	return Runes2Spawn
}
public Event_RoundStarted()				// We now spawn the new runes, and renable the runes players have.
{
	if(g_IsRunemodDisabled) return PLUGIN_CONTINUE

	if(g_Settings & DM_BasedSpawn)
	{
		RoundStarted()
		set_task(30.0,"Task_DMSpawnRunes",256,_,_,"b")
		return PLUGIN_CONTINUE
	}
	if(task_exists(TASK_REMOVERUNESONROUNDEND)) Task_RemoveRunes()
	
	if(g_Settings & SAVE_SPAWNUPDATE) set_task(15.0,"Task_UpdateSpawnVec",64,_,_,"b")
	RoundStarted()						// We tell the runes plugins that the new round is now started
	new RunesSpawnedList[MAX_PLUGINS+1],RunesSpawnedListCount = 0
	
	for(new i=1;i<=g_MaxPlayers;i++) if(is_user_alive(i))
	{
		g_CurWeapon[i] = get_user_curweaponindex(i)
	}
	
	new MaxRunes = GetMaxRunes()
	new Runes2Spawn = GetNumOfRunes2Spawn()
	
	if(g_Settings & TELLWHATRUNESSPANWED && (Runes2Spawn <= 0 || !Runes2Spawn))
	{
		client_print(0,print_chat,"%L",LANG_PLAYER,"BaseNoSpawnedRunes",g_UserHasRune[0],g_RunesInWorld)
		return PLUGIN_CONTINUE
	}
	else 	// We now start spawing the runes
	{
		if(g_Settings & TELLWHATRUNESSPANWED) client_print(0,print_chat,"%L",LANG_PLAYER,"BaseRunesSpawned",g_UserHasRune[0],MaxRunes,Runes2Spawn)
		new Message[200],SpawnPoint,RuneIndex
		for(new i=1;i<=Runes2Spawn;i++)
		{
			SpawnPoint = random_num(1,g_NumberOfSpawnPoints)
			RuneIndex = RandomRuneIndex(Runes2Spawn)
			if(RuneIndex == -1) break

			if(g_Settings & TELLWHATRUNESSPANWED)
			{
				RunesSpawnedList[RunesSpawnedListCount] = RuneIndex
				RunesSpawnedListCount++
			}
				
			if(g_Settings & 32) 		// This means we dont want the runes to spawn to close.
			{
				new EntNum = SpawnRune(RuneIndex,g_SpawnOrigin[SpawnPoint])	// We spawn the rune
				new LocStatus = CheckDistance(EntNum,SpawnPoint) 				// We check the the Spawn location the rune was spawned at, and 
				
				if(LocStatus == 2) 		// This means the newly spawned rune was to close to 1 of the other runes. We now try 5 random other locations to see if their free
				{
					new CPS=0			// Just incase, we will only check 5 diffrent spawn locations
					while( LocStatus == 2 && CPS < 5)
					{
						CPS++
						SpawnPoint = random_num(1,g_NumberOfSpawnPoints)
						LocStatus = CheckDistance(EntNum,SpawnPoint)
					}
					set_origin(EntNum,g_SpawnOrigin[SpawnPoint])
				}
			}
			else
				SpawnRune(RuneIndex,g_SpawnOrigin[SpawnPoint])
		}
		if(g_Settings & TELLWHATRUNESSPANWED) 
		{
			for(new i=1;i<=g_MaxPlayers;i++) if(is_user_connected(i))
			{
				for(new b=0;b<RunesSpawnedListCount;b++)
				{
					new ri = RunesSpawnedList[b]
					if(b == 0) // We do this so we get a nice comma seperatetion of the runes.
					{
						if(g_RuneFlags[ri] & API_USELANGSYSTEM)
							format(Message,199,"%L",i,gs_RuneName[ri])
						else
							format(Message,199,"%s",gs_RuneName[ri])
					}
					else
					{
						if(g_RuneFlags[ri] & API_USELANGSYSTEM)
							format(Message,199,"%s,%L",Message,i,gs_RuneName[ri])
						else
							format(Message,199,"%s,%s",Message,gs_RuneName[ri])
							
					}
				}
				client_print(i,print_chat,"%L",LANG_PLAYER,"BaseRunesSpawnedNames",Message)
			}
#if debug == 1
			for(new b=0;b<RunesSpawnedListCount;b++)
			{
				new ri = RunesSpawnedList[b]
				if(b == 0) // We do this so we get a nice comma seperatetion of the runes.
				{
					if(g_RuneFlags[ri] & API_USELANGSYSTEM)
						format(Message,199,"%L",LANG_SERVER,gs_RuneName[ri])
					else
						format(Message,199,"%s",gs_RuneName[ri])
				}
				else
				{
					if(g_RuneFlags[ri] & API_USELANGSYSTEM)
						format(Message,199,"%s,%L",Message,LANG_SERVER,gs_RuneName[ri])
					else
						format(Message,199,"%s,%s",Message,gs_RuneName[ri])
				}
			}
			server_print("[Runemod Debug] %s was spawned",Message)
#endif
		}
		return PLUGIN_CONTINUE		
	}
	return PLUGIN_CONTINUE
}
/* **************************************************** End of code for start / end round ( Or DM based spawn code ) *****************************************************/

public Event_Zoomed(id)				// We need to mark ppl for thats zooming
{
	g_IsZooming[id] = 1
}
public Event_UnZoomed(id)			// We need to mark ppl for thats zooming
{
	g_IsZooming[id] = 0
}
#endif
public Event_DeathMsg()
{
	new killer = read_data(1)
	new victim = read_data(2)


	if(g_RuneFlags[g_UserHasRune[victim]]  & API_BADRUNE || g_Settings & DM_BasedSpawn && g_UserHasRune[victim])
		RemoveRuneFromPlayer(victim,USER_DIED)
	else if(g_UserHasRune[victim])
		CMD_DropRune(victim)
		
	g_IsZooming[victim] = 0

	if(killer == victim)
		return PLUGIN_CONTINUE
 
	ReportKill(killer,victim)
	return PLUGIN_CONTINUE
}
stock ReportKill(killer,victim)
{
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_DEATHMSG && ( g_UserHasRune[victim] == i || g_UserHasRune[killer] == i ))
	{
		callfunc_begin_i(g_FuncIndex[i][Func_DeathMsg],g_PluginIndex[i])
		callfunc_push_int(killer)
		callfunc_push_int(victim)		
		callfunc_end()
	}
}
public server_frame()
{
	if(!g_KillUser[0]) return PLUGIN_CONTINUE
	
	for(new i=1;i<=g_MaxPlayers;i++) if(g_KillUser[i])
	{
		if(is_user_alive(i))
		{
			if(is_user_connected(g_KillUser[i]))
				set_user_frags(g_KillUser[i], get_user_frags(g_KillUser[i])+ 1)

			set_msg_block(g_MsgDeathMsg, BLOCK_SET)
			user_kill(i,1)
			set_msg_block(g_MsgDeathMsg, BLOCK_NOT)
			FakeKill(g_KillUser[i],i,gs_WeaponName[i])
			ReportKill(g_KillUser[i],i)
		}
		g_KillUser[0]--
		g_KillUser[i] = 0
	}
	return PLUGIN_CONTINUE
}
public Task_UpdateSpawnVec()
{
	if(g_LastUpdatedSpawnVec == 0) g_LastUpdatedSpawnVec = g_NumberOfSpawnPoints
	new RandomPlayer
	new Users[MAXPLAYERS+1]
	for(new i=1;i<=g_MaxPlayers;i++) 
	{
		if(is_user_alive(i) && !g_UserHasRune[i] && !is_user_hltv(i))
		{
			Users[0]++
			Users[Users[0]] = i
		}
	}
	if(g_UsersOnServer == 0 && g_NumberOfSpawnPoints > g_MaxPlayers) 		// If the server is emty, we start clearing up bad spawnpoints. Basicly we pick a random spawn point, and check how close it is to every other rune spawn
	{
		g_LastUpdatedSpawnVec = random_num(1,MAX_SPAWNPOINTS)
		new WasRemoved = CheckSpawnPoint(g_LastUpdatedSpawnVec)
		if(WasRemoved == 0)
			CheckVectorContent(g_SpawnOrigin[g_LastUpdatedSpawnVec])
	}
	else if(Users[0] >= 2) // There is to few players to get any "random" out of it. So we stop
	{
		RandomPlayer = random_num(1,Users[0])
		new Origin[3]
		get_user_origin(RandomPlayer,Origin)
		
		if(g_Settings & ExtraSpawnPointCheck) 	// Means we are doing extra checks on this spawnpoint
		{
			for(new i=1;i<=g_NumberOfSpawnPoints;i++)
			{
				if(get_distance(Origin,g_SpawnOrigin[i]) <= MIN_DISTANCE_BETWEEN_RUNES)
					return PLUGIN_HANDLED
			}
		}

		if(g_NumberOfSpawnPoints == MAX_SPAWNPOINTS)
		{
			g_LastUpdatedSpawnVec = random_num(1,MAX_SPAWNPOINTS)			
		}
		else
		{
			g_LastUpdatedSpawnVec++
			g_NumberOfSpawnPoints++
		}
		g_SpawnOrigin[g_LastUpdatedSpawnVec][0] = Origin[0]
		g_SpawnOrigin[g_LastUpdatedSpawnVec][1] = Origin[1]
		g_SpawnOrigin[g_LastUpdatedSpawnVec][2] = Origin[2] + 10
	}
	return PLUGIN_CONTINUE
}

#if debug == 1
public Debug_LoadSpawns(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	client_print(0,print_chat,"[Runemod Debug] the server was forced to read the spawns again")
	console_print(0,"[Runemod Debug] the server was forced to read the spawns again")
	ReadSpawnVec()
	return PLUGIN_HANDLED
}
public Debug_SaveRunes(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	new Dir[128]
	get_localinfo("amxx_basedir",Dir,127)
	format(Dir,127,"%s/runes.htm",Dir)
	
	new Line2Write[128]
	
	format(Line2Write,127,"<html> <body bgcolor=^"#000000^" text=^"#FFFFFF^"> </body>Runemod help<br>") 
	write_file(Dir,Line2Write,-1)
	for(new i=1;i<=g_NumberOfRunes;i++)
	{
		new Color[12]
				 
		RGBtoHex(g_RuneColor[i][0])
		format(Color,11,"%s",gs_Test)
		RGBtoHex(g_RuneColor[i][1])
		format(Color,11,"%s%s",Color,gs_Test)
		RGBtoHex(g_RuneColor[i][2])
		format(Color,11,"%s%s",Color,gs_Test)
		
		format(Line2Write,127,"%d)<font color=^"#%s^">%s</font> - %s<br>",i,Color,gs_RuneName[i],gs_RuneDesc[i])
		write_file(Dir,Line2Write,-1)

	}
	format(Line2Write,127,"</html>")
	write_file(Dir,Line2Write,-1)
	return PLUGIN_HANDLED
}
public Debug_SaveSpawns(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	client_print(0,print_chat,"[Runemod Debug] the server was forced to save the spawns")
	console_print(0,"[Runemod Debug] the server was forced to save the spawns again")	
	SavingSpawnVec()
	return PLUGIN_HANDLED
}
public Debug_GenSpawns(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	g_NumberOfSpawnPoints = 0
	GenSpawns()
	console_print(id,"[Runemod] %d where generated",g_NumberOfSpawnPoints)
	return PLUGIN_HANDLED
}
public Debug_CleanSpawnPoints(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	new RunesWhenStarting = g_NumberOfSpawnPoints
	new RunesRemoved = 0

	for(new i=1;i<=g_NumberOfSpawnPoints;i++) if(g_NumberOfSpawnPoints > g_MaxPlayers)
	{
		if(CheckVectorContent(g_SpawnOrigin[i]) == 1)
		{
			new SPR = CheckSpawnPoint(i)
			if(SPR > 0)
				console_print(id,"[Runemod Debug] While cleaning spawnpoint %d, %d spawn points where removed",i,SPR)
		}
		else
		{
			console_print(id,"[Runemod Debug] %d was to close to something, and was removed",i)
			RemoveRuneSpawnPoint(i)
		}
	}
	RunesRemoved = RunesWhenStarting - g_NumberOfSpawnPoints
	console_print(id,"[Runemod Debug] %d runes where removed, there is %d runes left( When the command started %d )",RunesRemoved,g_NumberOfSpawnPoints,RunesWhenStarting)
	return PLUGIN_HANDLED
}
public Debug_SpawnRune(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	new arg[16]
	read_argv(1,arg,15)
	new RuneIndex = str_to_num(arg)
	if(!is_vail_rune(RuneIndex))
	{
		console_print(id,"%d is not a vaild rune",RuneIndex)
		return PLUGIN_HANDLED
	}
	new SpawnPoint = random_num(0,g_NumberOfSpawnPoints)
	SpawnRune(RuneIndex,g_SpawnOrigin[SpawnPoint])
	
	new Name[32]
	get_user_name(id,Name,31)
	client_print(0,print_chat,"[Runemod Debug] %s was forcefully spawned by %s",gs_RuneName[RuneIndex],Name)
	console_print(0,"[Runemod Debug] %s was forcefully spawned by %s",gs_RuneName[RuneIndex],Name)
	return PLUGIN_HANDLED
}
public Debug_GiveRune(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return PLUGIN_HANDLED
	new arg[16]
	read_argv(1,arg,15)
	new VictimID = cmd_target(id,arg,6)
	if(g_UserHasRune[VictimID])
	{
		RemoveRuneFromPlayer(id)
	}
	read_argv(2,arg,15)
	new RuneIndex = str_to_num(arg)
	if(!is_vail_rune(RuneIndex) || VictimID == 0 || !is_user_alive(VictimID) )
	{
		console_print(id,"%d is not a vaild rune",RuneIndex)
		return PLUGIN_HANDLED
	}
	PickupRune(VictimID,RuneIndex,0)	
	new Name[32],Name2[32]
	get_user_name(id,Name,31)
	get_user_name(VictimID,Name2,31)
	
	client_print(0,print_chat,"[Runemod Debug] %s was forcefully given to %s by %s",gs_RuneName[RuneIndex],Name2,Name)
	console_print(0,"[Runemod Debug] %s was forcefully given to %s by %s",gs_RuneName[RuneIndex],Name2,Name)
	return PLUGIN_HANDLED
}
#endif
/*********************************************************** This is the that gets info from chat( like say help) ************************************ */
public Check_Chat(id)
{
	if(read_argc() > 2) return PLUGIN_CONTINUE // If there is more then 2 args, then they dident use want help. Their most likely chating, so we dont need to check what their saying
	
	new Text[32]
	read_argv(1,Text,31)
	if(equali(Text,"/runehelp") || equali(Text,"runehelp"))
		CMD_ShowHelp(id)
	else if(equali(Text,"playerrunes") || equali(Text,"/playerrunes"))
		Cmd_PlayerRunes(id)
	else if(equali(Text,"runelist") || equali(Text,"/runelist"))
		Cmd_ShowRunes(id)
	else if(equali(Text,"/droprune") || equali(Text,"/dropitem"))
	{
		client_print(id,print_chat,"%L",LANG_PLAYER,"BaseDropItemChat")
		CMD_DropRune(id)
	}
	return PLUGIN_CONTINUE
}
#if HTML_MOTD == 1
public Cmd_PlayerRunes(id)
{
	new len,Message[1600],Name[32]
	new ActiveRunes = 0
	new Color[7]
	new RuneIndex = 0
	
	len = format(Message,1599,"<html> <body bgcolor=^"#000000^" text=^"#FFFFFF^"> </body>Runes in player control:<br>")
	for(new b=1;b<=g_MaxPlayers;b++) 
	{
		if(g_UserHasRune[b])
		{
			ActiveRunes++
			RuneIndex = g_UserHasRune[b]
			RGBtoHex(g_RuneColor[RuneIndex][0])
			format(Color,6,"%s",gs_Test)
			RGBtoHex(g_RuneColor[RuneIndex][1])
			format(Color,6,"%s%s",Color,gs_Test) // It breaks for some reason here. 
			RGBtoHex(g_RuneColor[RuneIndex][2])
			format(Color,6,"%s%s",Color,gs_Test)
			
			get_user_name(b,Name,31)
			if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
				len += format(Message[len],1599 - len,"%s has <font color=^"#%s^">%L</font> (%L)<br>",Name,Color,id,gs_RuneName[RuneIndex],id,gs_RuneDesc[RuneIndex])
			else
				len += format(Message[len],1599 - len,"%s has <font color=^"#%s^">%s</font> (%s)<br>",Name,Color,gs_RuneName[RuneIndex],gs_RuneDesc[RuneIndex])
		}
	}
	len += format(Message[len],1599 - len,"There are %d runes held by players",ActiveRunes)
	show_motd(id,Message,"Runemod - Player Runes")
}
#else
public Cmd_PlayerRunes(id)
{
	new len,Message[512],Name[32]
	new ActiveRunes = 0
	len = format(Message,255,"L%^n",LANG_SERVER,"BaseRunesOnPlayersTitle")
	for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i])
	{
		new ri = g_UserHasRune[id]
		ActiveRunes++
		get_user_name(i,Name,31)
		if(g_RuneFlags[ri] & API_USELANGSYSTEM)
			len += format(Message[len],511 - len,"%s - %L^n",Name,id,gs_RuneName[ri])
		else
			len += format(Message[len],511 - len,"%s - %s^n",Name,gs_RuneName[ri])
			
	}
	len += format(Message[len],511 - len,"%L",LANG_PLAYER,"BaseRunesOnPlayers",ActiveRunes)
	show_motd(id,Message,"Runemod - Player Runes")
}
#endif
public Cmd_ShowRunes(id)
{
	if(g_UseExternalRuneList)
	{
		new Lang[3],Url[128]
		get_user_info(id,"lang",Lang,2)
		if(equal(Lang,"en") || equal(Lang,"de") || equal(Lang,"nl")) 
			format(Url,127,"%s_%s.htm",gs_MOTDUrl,Lang)
		else	
			format(Url,127,"%s_en.htm",gs_MOTDUrl)
			
		show_motd(id,Url,"Runemod - Runelist")
	}
	else
	{
		MakeMotdMessage(id)
	
		show_motd(id,gs_MOTDMessage,"Runemod - Runelist")
	}
}
public CMD_ShowHelp(id) 
{
#if HTML_MOTD == 1
	new Lang[3] 
	get_user_info(id,"lang",Lang,2)        // Reads what langauge the user has selected this is a AMXX .2 feature (in .16 it should basicly nto get any info, so the else will come it) 
	if(equal(Lang,"en")) 
		show_motd(id,"http://rune.flyingmongoose.net/IngameHelp/en","Rune Mod help") 
	else if(equal(Lang,"de"))
		show_motd(id,"http://rune.flyingmongoose.net/IngameHelp/de","Rune Mod help") 
	else if(equal(Lang,"nl"))
		show_motd(id,"http://rune.flyingmongoose.net/IngameHelp/de","Rune Mod help") 		
	
	else 
		show_motd(id,"http://ingame.runemod.org","Rune Mod help")    // If no language has been set, it selects the english one ( Or you could make a page where the user can select the language himself 

#else 
	new len,Message[512]
	len = format(Message,511,"Runemod help:^n")
	len += format(Message[len],511 - len,"^n") 
	len += format(Message[len],511 - len,"This page is designed to help you play Rune mod, use the menu above for navigation^n") 
	len += format(Message[len],511 - len,"^n") 
	len += format(Message[len],511 - len,"How to play:^n") 
	len += format(Message[len],511 - len,"^n")
	len += format(Message[len],511 - len,"Runes are randomly generated all over the level. Grab them to gain special abilities. You may only have one rune at a time. Each rune gives special powers. Some runes have powers only for certain weapons.^n") 
	len += format(Message[len],511 - len,"To drop a rune, "bind f dropitem" at the console (~ key)^n") 
	len += format(Message[len],511 - len,"^n") 
	len += format(Message[len],511 - len,"COMMANDS:^n") 
	len += format(Message[len],511 - len,"say help - you've already found this^n")
	len += format(Message[len],511 - len,"say runelist - same as clicking the rune link^n")
	len += format(Message[len],511 - len,"say playerrunes- see a list of all runes players have^n")
	len += format(Message[len],511 - len,"dropitem - drop your item^n")		
	show_motd(id,Message,"RuneMod help")
#endif
    return PLUGIN_HANDLED
}
/*********************************************************** This is the that gets info from chat( like say help) END ************************************ */
public CMD_DropRune(id)
{
	if(g_UserHasRune[id] && g_RuneFlags[g_UserHasRune[id]] & API_BADRUNE)
	{
		client_print(id,print_chat,"%L",LANG_PLAYER,"BaseCannotDrop")
	}
	else if(g_UserHasRune[id]) 
	{
		new RuneIndex = g_UserHasRune[id]
#if debug == 1
		new Name[32]
		get_user_name(id,Name,31)
		server_print("[Runemod Debug] %s has droped %s",Name,gs_RuneName[RuneIndex])
#endif		
		new Origin[3]
		get_origin(id,Origin)
		Origin[2] = Origin[2] + 43
		
		new EntNum = SpawnRune(RuneIndex,Origin)
		
		if(is_user_alive(id))
		{
			RemoveRuneFromPlayer(id,USER_DROPEDRUNE)
			emit_sound(id, CHAN_WEAPON, "items/weapondrop1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
			{
				new RuneName[MAX_PLUGIN_RUNENAME_SIZE+1]
				format(RuneName,MAX_PLUGIN_RUNENAME_SIZE,"%L",LANG_PLAYER,gs_RuneName[RuneIndex])
				
				client_print(id,print_chat,"%L",LANG_PLAYER,"BaseDropedRune",RuneName)
			}
			else
				client_print(id,print_chat,"%L",LANG_PLAYER,"BaseDropedRune",gs_RuneName[RuneIndex])
		}
		else if(get_user_team(id) == 1 || get_user_team(id) == 2)
			RemoveRuneFromPlayer(id,USER_DIED)
		else
			RemoveRuneFromPlayer(id,USER_DISCONNECTED)
		
		new Float:velocity[3]
		VelocityByAim(id, 400 , velocity)
		entity_set_vector(EntNum, EV_VEC_velocity, velocity)

		g_LastRune[id] = EntNum
		set_task(1.0,"Task_RemoveLastRune",id,_,_,"a",1)		// This system is used to make sure the user does not pick up the rune just droped
		return PLUGIN_HANDLED
	}
	else 
	{
		client_print(id,print_chat,"%L",LANG_PLAYER,"BaseNoRuneToDrop")
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public Task_RemoveLastRune(id)
{
	g_LastRune[id] = 0
	g_Warn[id] = 0
}
public Task_ShowMessage() // This is the function that shows the HUD message with what rune the user currently has, and what rune he is looking at
{
	//if(g_UsersOnServer)
	//	log_amx("Task_ShowMessage() 2 - Heapsize: %d  Players: %d",heapspace(),g_UsersOnServer)
	new const StrLen = MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+4
	new Message[MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+4 + 1]
	new TargetID = 0
	new body = 0
	new Name[32]
	new RuneIndex = 0
	new EntNum =0
	setc(Name,31,0)
	setc(Message,MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+3,0)
	
	for(new i=1;i<=g_MaxPlayers;i++) 
	{
		if(is_user_alive(i))
		{
			if(g_UserHasRune[i])
			{
				RuneIndex = g_UserHasRune[i]
				if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
					format(Message,StrLen,"%L^n %L",i,gs_RuneName[RuneIndex],i,gs_RuneDesc[RuneIndex])
				else
					format(Message,StrLen,"%s^n %s",gs_RuneName[RuneIndex],gs_RuneDesc[RuneIndex])					
				
				if(g_RuneFlags[RuneIndex] & API_BADRUNE)
					set_hudmessage(255, 255, 255, 0.92, 0.85, 4.0,HUD_CHANNEL)
				else
					set_hudmessage(255, 255, 255, 0.92, 0.85, 4.0,HUD_CHANNEL)
					
				show_hudmessage(i,Message)
			}
			if(g_Settings & ShowWhatRuneIsBeingLookedat)
			{
				new SO[3]
				get_user_origin(i,SO,3)
				EntNum = CheckSpere(SO)
				
				if(EntNum)
				{
					
					RuneIndex = IsRuneEnt(EntNum,3,0)
					if(g_RuneFlags[RuneIndex] & API_BADRUNE)
						RuneIndex = RandomNoneBadRuneIndex(RuneIndex)
						
					if(g_RuneFlags[RuneIndex] & API_PICKUPANDFORGET) // pickup and forget runes dont have desc its where they save the custom model
					{
						if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
							client_print(i,print_center,"%L",i,gs_RuneName[RuneIndex])
						else
							client_print(i,print_center,"%s",gs_RuneName[RuneIndex])
					}
					else
					{
						if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
							client_print(i,print_center,"%L - %L",i,gs_RuneName[RuneIndex],i,gs_RuneDesc[RuneIndex])
						else
							client_print(i,print_center,"%s - %s",gs_RuneName[RuneIndex],gs_RuneDesc[RuneIndex])
					}					
				}
			}
		}
		else if(!is_user_alive(i) && !is_user_hltv(i))	// This means the user is dead, and we now check if he is spectating someone
		{
			get_user_aiming(i,TargetID,body)
			if(TargetID && TargetID <= g_MaxPlayers && g_UserHasRune[TargetID])
			{
				RuneIndex = g_UserHasRune[TargetID]
				get_user_name(TargetID,Name,31)
				
				if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
					format(Message,StrLen,"%s - %L^n %L",Name,i,gs_RuneName[RuneIndex],i,gs_RuneDesc[RuneIndex])
				else
					format(Message,StrLen,"%s - %s^n %s",Name,gs_RuneName[RuneIndex],gs_RuneDesc[RuneIndex])
					
				if(g_RuneFlags[RuneIndex] & API_BADRUNE)
					set_hudmessage(255, 0, 0, 0.03, 0.865, 0, 0.0, 0.0, 0.0, 4.0,HUD_CHANNEL)
				else
					set_hudmessage(255, 255, 255, 0.03, 0.865, 0, 0.0, 0.0, 0.0, 4.0,HUD_CHANNEL)
					
				show_hudmessage(i,Message)
			}
		}
	}
}
public client_disconnect(id) 
{
	if(g_RuneFlags[g_UserHasRune[id]]  & API_BADRUNE)
		RemoveRuneFromPlayer(id,USER_DISCONNECTED)
	if(g_UserHasRune[id])
		CMD_DropRune(id)
	
	g_KillUser[id] = 0
	g_CurWeapon[id] = 0
	if(!is_user_hltv(id)) g_UsersOnServer--
}
public client_putinserver(id) 
{
	if(!is_user_hltv(id)) g_UsersOnServer++
}
// This is function that spawns the rune into the world. This function is almost identical to kaddars function from runemod 1.
stock SpawnRune(RuneIndex,Origin[3])	
{
	if(g_RunesInWorld >= MAX_RUNESINGAME)
	{
		log_amx("[Runemod]Trying to spawn to many runes in the world (%d) increase the value of MAX_RUNESINGAME if you want to allow this",MAX_RUNESINGAME)
		return PLUGIN_CONTINUE 
	}
	if(g_RuneDisabled[RuneIndex] == 1) return PLUGIN_CONTINUE
	
	new EntNum = create_entity("info_target")
	IsRuneEnt(EntNum,1,RuneIndex)

	new Float:velocity[3]
	velocity[0] = random_float(-50.0,50.0)
	velocity[1] = random_float(-50.0,50.0)
	velocity[2] = random_float(20.0,80.0)

	Origin[2] += 5	// Adds 5 to high to stop them from getting stuck in the ground

	new Float:Color[3]

	entity_set_string(EntNum, EV_SZ_classname,"rune")

	if(!(g_RuneFlags[RuneIndex] & API_PICKUPANDFORGET))
	{
		if(g_RuneFlags[RuneIndex] & API_BADRUNE)
		{
			Color[0] = random_float(25.0,250.0)
			Color[1] = random_float(25.0,250.0)
			Color[2] = random_float(25.0,250.0)
		}
		else
		{
			Color[0] = float(g_RuneColor[RuneIndex][0])
			Color[1] = float(g_RuneColor[RuneIndex][1])
			Color[2] = float(g_RuneColor[RuneIndex][2])
		}
		
		entity_set_int(EntNum, EV_INT_renderfx, kRenderFxGlowShell)
		entity_set_float(EntNum, EV_FL_renderamt, 1000.0)
		entity_set_int(EntNum, EV_INT_rendermode, kRenderTransAlpha)

		entity_set_vector(EntNum, EV_VEC_rendercolor,Color)
		
		if(g_UseNewModel == 1)
			entity_set_model(EntNum, "models/runemod/Runemod.mdl")
		else
			entity_set_model(EntNum, "models/w_weaponbox.mdl")
	}
	else
		entity_set_model(EntNum,gs_RuneDesc[RuneIndex])

	new Float:MaxBox[3] = {4.0,4.0,4.0} 
	//new Float:MinBox[3] = {-4.0,-4.0,-4.0}		
	//entity_set_vector(EntNum, EV_VEC_mins, MinBox)
	entity_set_vector(EntNum, EV_VEC_maxs, MaxBox)

	set_origin(EntNum,Origin)
	entity_set_int(EntNum, EV_INT_effects, 32)
	entity_set_int(EntNum, EV_INT_solid, 1)

	//entity_set_int(EntNum,EV_ENT_owner,0)
	//entity_set_int(EntNum, EV_INT_iuser4,RuneIndex)
		
	if(g_Settings & RUNE_BOUNCE) 
		entity_set_int(EntNum, EV_INT_movetype, MOVETYPE_BOUNCE)
	else 
		entity_set_int(EntNum, EV_INT_movetype, MOVETYPE_TOSS)
		
	velocity[0] = float(random(256)-128)
	velocity[1] = float(random(256)-128)
	velocity[2] = float(random(300)+75)
	entity_set_vector(EntNum, EV_VEC_velocity,velocity)
	g_RunesInWorld++
	return EntNum
}
public pfn_touch(ptr,ptd)
{
	/*
	ptd is the player
	ptr is the Ent number assumed the rune
	*/
	if(ptr == 0 || ptd == 0 || ptd > g_MaxPlayers || !IsRuneEnt(ptr,3,0) || !is_user_alive(ptd)) return PLUGIN_CONTINUE
	new RuneIndex = IsRuneEnt(ptr,3,0)
	
	if(g_UserHasRune[ptd] == 0 && g_LastRune[ptd] != ptr || g_RuneFlags[RuneIndex] & API_PICKUPANDFORGET || g_LastRune[ptd] != ptr  && g_Settings & AutoDropRune)
	{
		if(g_UserHasRune[ptd] != 0 && !(g_RuneFlags[RuneIndex] & API_PICKUPANDFORGET)) // If we have AutoDropRune ,no we drop the old rune first
		{
			CMD_DropRune(ptd)
					
			if(!task_exists(ptd))
				set_task(1.0,"Task_RemoveLastRune",ptd,_,_,"a",1)
		}
			
		PickupRune(ptd,RuneIndex,ptr)
		return PLUGIN_CONTINUE
	}
	else if(g_UserHasRune[ptd] && g_Warn[ptd] == 0)
	{
		new RuneName1[MAX_PLUGIN_RUNENAME_SIZE+1],RuneName2[MAX_PLUGIN_RUNENAME_SIZE+1]
		if(g_RuneFlags[RuneIndex] & API_BADRUNE)
			RuneIndex = RandomNoneBadRuneIndex(RuneIndex)
			
		GetRuneName(ptd,RuneName1,RuneIndex)
		GetRuneName(ptd,RuneName2,g_UserHasRune[ptd])
		
		g_Warn[ptd] = ptr
		client_print(ptd,print_chat,"%L",LANG_PLAYER,"BaseCantPickUp",RuneName1,RuneName2)
		
		if(!task_exists(ptd))
			set_task(1.0,"Task_RemoveLastRune",ptd,_,_,"a",1)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

/********************************************** API related functions ****************************************/
public API_RegisterPlugin(PluginIndex,RuneName[],RuneDesc[],RuneColor1,RuneColor2,RuneColor3,Flags)
{
#if debug == 1	
	if(!PluginIndex || !RuneName[0] || !RuneDesc[0] | !RuneColor1 && !RuneColor2 && !RuneColor3)
	{
		return -1
	}
	else if(g_NumberOfRunes == MAX_PLUGINS)
#else
	if(g_NumberOfRunes == MAX_PLUGINS)
#endif
	{
		return -2
	}
	g_NumberOfRunes++
	g_PluginIndex[g_NumberOfRunes] = PluginIndex
	format(gs_RuneName[g_NumberOfRunes],MAX_PLUGIN_RUNENAME_SIZE,RuneName)
	format(gs_RuneDesc[g_NumberOfRunes],MAX_PLUGIN_RUNEDESC_SIZE,RuneDesc)
	g_RuneColor[g_NumberOfRunes][0] = RuneColor1
	g_RuneColor[g_NumberOfRunes][1] = RuneColor2
	g_RuneColor[g_NumberOfRunes][2] = RuneColor3
	g_RuneFlags[g_NumberOfRunes] = Flags
	// We now have to get the func indexes from the plugin, And we store them in our nice g_FuncIndex array
	if(Flags & API_NEWROUND)
		g_FuncIndex[g_NumberOfRunes][Func_NewRound] = get_func_id("API_NewRound",PluginIndex)
	if(Flags & API_SPEEDCHANGE)
	{
		g_FuncIndex[g_NumberOfRunes][Func_LockSpeedChange] = get_func_id("API_LockSpeedChange",PluginIndex)	
		g_FuncIndex[g_NumberOfRunes][Func_UnLockSpeedChange] = get_func_id("API_UnLockSpeedChange",PluginIndex)
	}
	if(Flags & API_ROUNDSTARTED)
		g_FuncIndex[g_NumberOfRunes][Func_RoundStarted] = get_func_id("API_RoundStarted",PluginIndex)
	if(Flags & API_EVENTDAMAGE)
		g_FuncIndex[g_NumberOfRunes][Func_Damage] = get_func_id("API_Damage",PluginIndex)
	if(Flags & API_EVENTDAMAGEDONE)
		g_FuncIndex[g_NumberOfRunes][Func_DamageDone] = get_func_id("API_DamageDone",PluginIndex)
	if(Flags & API_EVENTCHANGEWEAPON)
		g_FuncIndex[g_NumberOfRunes][Func_CurWeaponChange] = get_func_id("API_CurWeaponChange",PluginIndex)
	if(Flags & API_EVENTCURWEAPON)
		g_FuncIndex[g_NumberOfRunes][Func_CurWeapon] = get_func_id("API_CurWeapon",PluginIndex)
	if(Flags & API_DEATHMSG)
		g_FuncIndex[g_NumberOfRunes][Func_DeathMsg] = get_func_id("API_DeathMsg",PluginIndex)		
				
	g_FuncIndex[g_NumberOfRunes][Func_PickUpRune] = get_func_id("API_PickUpRune",PluginIndex)
	if(!(Flags & API_PICKUPANDFORGET))		// If the rune a singel use, they dont have a DropFunc
		g_FuncIndex[g_NumberOfRunes][Func_DropedRune] = get_func_id("API_DropedRune",PluginIndex)
	
	if(g_DamageHooks == 0 && ( Flags & API_EVENTDAMAGE ||  Flags & API_EVENTDAMAGEDONE  ) )
	{
		g_DamageHooks++
		register_event("Damage","Event_Damage","b")
	}
	if(g_SpeedHooks == 0 && Flags & API_SPEEDCHANGE)
	{
		g_SpeedHooks++
#if MOD == MOD_CSTRIKE	
		register_event("SetFOV","Event_Zoomed","be","1<90")
		register_event("SetFOV","Event_UnZoomed","be","1=90")
#endif
	}
	if(g_CurHooks == 0 && ( Flags & Func_CurWeaponChange || Flags & Func_CurWeapon ||  Flags & API_SPEEDCHANGE  ) )
	{
		g_CurHooks++
#if MOD == MOD_CSTRIKE	
		register_event("CurWeapon", "Event_CurWeapon", "b")
#endif
	}	
#if debug == 1	
	if(g_FuncIndex[g_NumberOfRunes][Func_PickUpRune] < 0)
		log_amx("Plugin with index %d(%s) has problem with API_PickUpRune",PluginIndex,RuneName)
	if(g_FuncIndex[g_NumberOfRunes][Func_DropedRune] < 0 && !(Flags & API_PICKUPANDFORGET))
		log_amx("Plugin with index %d(%s) has problem with API_DropedRune",PluginIndex,RuneName)

	if(Flags & API_ROUNDSTARTED && g_FuncIndex[g_NumberOfRunes][Func_RoundStarted] < 0)
		log_amx("Plugin with index %d(%s) does not have a Api_RoundStart function func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_RoundStarted])
	if(Flags & API_EVENTDAMAGE && g_FuncIndex[g_NumberOfRunes][Func_Damage] < 0)
		log_amx("Plugin with index %d(%s) has problem with its API_Damage func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_Damage])
	if(Flags & API_EVENTDAMAGEDONE && g_FuncIndex[g_NumberOfRunes][Func_DamageDone] < 0)
		log_amx("Plugin with index %d(%s) has problem with its API_DamageDone func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_DamageDone])
	if(Flags & API_EVENTCHANGEWEAPON && g_FuncIndex[g_NumberOfRunes][Func_CurWeaponChange] < 0)
		log_amx("Plugin with index %d(%s) has problem with its API_CurWeaponChange func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_CurWeaponChange])
	if(Flags & API_EVENTCURWEAPON && g_FuncIndex[g_NumberOfRunes][Func_CurWeapon] < 0)
		log_amx("Plugin with index %d(%s) has problem with its API_CurWeapon func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_CurWeapon])
	if(Flags & API_DEATHMSG && g_FuncIndex[g_NumberOfRunes][Func_DeathMsg] < 0)
		log_amx("Plugin with index %d(%s) has problem with its API_DeathMsg func(%d)",PluginIndex,RuneName,g_FuncIndex[g_NumberOfRunes][Func_DeathMsg])
#endif
	return g_NumberOfRunes
}
public API_DisableRune(IndexOfRune)
{
	if(g_RuneDisabled[IndexOfRune] == 1)
		return -1
	else if(g_RuneDisabled[IndexOfRune] == 0)
	{
		g_RuneDisabled[0]++
		for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i] == IndexOfRune)	// we now find any player with this rune
			RemoveRuneFromPlayer(i,USER_DROPEDRUNE)		// When calling this Function directly the plugin that controls the rune gets told. And then the rune silently gets removed
		
		for(new i=1;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][1] == IndexOfRune) // We now earch the world for any runes of this index
			RemoveRuneFromWorld(g_RuneEntNum[i][0]) // And remove them if found
		g_RuneDisabled[IndexOfRune] =1		// We now mark the rune has disabled, this will stop it from being spawned
		return 1
	}
	return -2
}
public API_PluginShutDown()
{
	remove_task(64)
	remove_task(128)
	remove_task(256)
	
	for(new i=1;i<=g_MaxPlayers;i++) if(task_exists(i))
		remove_task(i)
	for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i])
		RemoveRuneFromPlayer(i,USER_DROPEDRUNE)
	for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0])
		RemoveRuneFromWorld(g_RuneEntNum[i][0])

	server_print("[Runemod] Runemod has been forcefully turned off")
	client_print(0,print_chat,"[Runemod] Runemod has been forcefully turned off")
	g_IsRunemodDisabled=1
}
public API_PluginStart()
{
	g_IsRunemodDisabled=0
	server_print("[Runemod] Runemod has been forcefully turned on")
	client_print(0,print_chat,"[Runemod] Runemod has been forcefully turned on")	
}
public API_EnableRune(IndexOfRune)
{
	if(g_RuneDisabled[IndexOfRune] == 0)
		return -1
	else if(g_RuneDisabled[IndexOfRune] == 1)
	{
		g_RuneDisabled[0]--
		g_RuneDisabled[IndexOfRune] = 0
		return 1
	}
	return -2
}

public Event_CurWeapon(id)
{
	new WeaponIndex = get_user_curweaponindex(id)
	if(WeaponIndex != g_CurWeapon[id]) 	// The user has changed weapons
	{
		for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_EVENTCHANGEWEAPON && g_UserHasRune[id] == i)
		{
			callfunc_begin_i(g_FuncIndex[i][Func_CurWeaponChange],g_PluginIndex[i])
			callfunc_push_int(id)
			callfunc_push_int(WeaponIndex)
			callfunc_end()
		}
	}
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_EVENTCURWEAPON && g_UserHasRune[id] == i)
	{
		callfunc_begin_i(g_FuncIndex[i][Func_CurWeapon],g_PluginIndex[i])
		callfunc_push_int(id)
		callfunc_push_int(WeaponIndex)
		callfunc_end()
	}	
	g_CurWeapon[id] = WeaponIndex
	return PLUGIN_CONTINUE
}

public Event_Damage()
{
	if(g_UsersOnServer <= 1) return PLUGIN_CONTINUE
	
	new victim = read_data(0)
	new OrgDmg = read_data(2)
	
	if(OrgDmg == 0 || victim == 0) return PLUGIN_CONTINUE
	
	new attacker = get_user_attacker(victim)
	if(attacker == victim || attacker == 0 || attacker > g_MaxPlayers)
		return PLUGIN_CONTINUE

	new damage[MAX_PLUGINS+1]
	new DmgEventsSendt = 0
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_EVENTDAMAGE && ( g_UserHasRune[victim] == i || g_UserHasRune[attacker] == i ))
	{
		callfunc_begin_i(g_FuncIndex[i][Func_Damage],g_PluginIndex[i])
		callfunc_push_int(victim)
		callfunc_push_int(attacker)
		callfunc_push_int(OrgDmg)
		damage[0] = callfunc_end()
		if(damage[0] != OrgDmg)	// If the damage has changed, so we save it.
		{
			damage[i] = damage[0]
			DmgEventsSendt++
		}
	}
	new NewDamage
	if(DmgEventsSendt != 0)	// This means we did send the damage was sendt, and 1 of the plugins has altered the orignal damage
	{
		for(new i=1;i<=MAX_PLUGINS;i++) if(g_RuneFlags[i] & API_EVENTDAMAGE) // We now get the avarage damage returned by the other plugins
		{
			NewDamage = NewDamage + damage[i]
		}
		NewDamage = NewDamage / DmgEventsSendt
		if(NewDamage != OrgDmg)
		{
			// set_msg_arg_int(2,get_msg_argtype(2),NewDamage)
	
			if(OrgDmg < NewDamage)	// This means the damage has increased, and we now have to check to make sure that the victim did not die, and we have to add the extra damage
			{
				new Float:NewHP = entity_get_float(victim, EV_FL_health) - float(NewDamage - OrgDmg)	// We now find out if the victim still has any HP left.
				if(NewHP < 1.0 && victim && attacker)	// The victim is now no hp, but we still have to kill him.
				{
					g_KillUser[0]++
					g_KillUser[victim] = attacker
				}
				else entity_set_float(victim, EV_FL_health, NewHP )
			}
			else if(is_user_alive(victim))	// This means the total damage has been lowered, we now give the more hp. But if the user is dead he is f...
			{
				new ExtraHp = OrgDmg - NewDamage
				entity_set_float(victim, EV_FL_health,(entity_get_float(victim, EV_FL_health) + float(ExtraHp)))
			}
		}
	}
	else	// Since no new Dmg was calcuted, we assing the old one.
		NewDamage = OrgDmg
	
	// Now we tell the plugins that want to know, the new damage done.
	for(new i=1;i<=g_NumberOfRunes;i++) 
	{
		if(g_RuneFlags[i] & API_EVENTDAMAGEDONE && g_UserHasRune[victim] == i || g_RuneFlags[i] & API_EVENTDAMAGEDONE && g_UserHasRune[attacker] == i )
		{
			callfunc_begin_i(g_FuncIndex[i][Func_DamageDone],g_PluginIndex[i])
			callfunc_push_int(victim)
			callfunc_push_int(attacker)
			callfunc_push_int(NewDamage)
			callfunc_end()
		}
	}
	return PLUGIN_CONTINUE
}
public API_RegisterKill(killer,victim,Weapon[])
{
	g_KillUser[0]++
	g_KillUser[victim] = killer	
	
	copy(gs_WeaponName[victim],39,Weapon)
}

stock RemoveRuneFromPlayer(id,Reason=USER_DROPEDRUNE)
{
	// We inform the plugin that controls the rune that he has lost his rune
	new RuneIndex = g_UserHasRune[id]
	callfunc_begin_i(g_FuncIndex[RuneIndex][Func_DropedRune],g_PluginIndex[RuneIndex])
	callfunc_push_int(id)
	callfunc_push_int(Reason)
	callfunc_end()
	set_hudmessage(255, 255, 255, 0.92, 0.85, 4.0,HUD_CHANNEL)
	show_hudmessage(id," ") // Clears the hudmessage
	g_UserHasRune[id] = 0
	g_UserHasRune[0]--
}
public LockSpeedChange(id) // This is used to inform other plugins about a rune has locked the movment of a player. 
{
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_SPEEDCHANGE)
	{
		callfunc_begin_i(g_FuncIndex[i][Func_LockSpeedChange],g_PluginIndex[i])
		callfunc_push_int(id)
		callfunc_end()		
	}
}
public UnLockSpeedChange(id) // This is used to inform other plugins about a rune has locked the movment of a player. 
{
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_SPEEDCHANGE)
	{
		callfunc_begin_i(g_FuncIndex[i][Func_UnLockSpeedChange],g_PluginIndex[i])
		callfunc_push_int(id)
		callfunc_end()		
	}
}
public API_ResetSpeed(id)
{
#if MOD == MOD_CSTRIKE
	return cs_ResetSpeed(id,g_CurWeapon[id])
#endif
}

stock StartNewRound() // This function is called by mods like CS that uses rounds and need runes to rest themself in the new round
{
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_NEWROUND)
	{
		callfunc_begin_i(g_FuncIndex[i][Func_NewRound],g_PluginIndex[i])
		callfunc_end()		
	}
}
stock RoundStarted() //This is called when the new round is started, we now unlock the runes.
{
	for(new i=1;i<=g_NumberOfRunes;i++) if(g_RuneFlags[i] & API_ROUNDSTARTED)
	{
		callfunc_begin_i(g_FuncIndex[i][Func_RoundStarted],g_PluginIndex[i])
		callfunc_end()		
	}
}

public API_GetUserRune(id) return g_UserHasRune[id]
public API_ActiveWeapon(id) return g_CurWeapon[id]


/* ******************  Here we precache the files needed. And we Have the effects used by the runes *************************/
public plugin_precache()
{
	g_MsgSmoke = precache_model("sprites/steam1.spr")
	g_MsgExplode = precache_model("sprites/zerogxplode.spr")
	
	if(file_exists("models/runemod/Runemod.mdl"))
	{
		precache_model("models/runemod/Runemod.mdl")
		g_UseNewModel = 1
	}
	precache_sound("items/gunpickup1.wav")
	precache_sound("items/weapondrop1.wav")
}

public API_EffectFade(id,Time,LastTime,type,ColorR,ColorG,ColorB,Alpha)
{
	message_begin(MSG_ONE,g_MsgFade,{0,0,0},id)
	write_short( 1<<Time ) // fade lasts this long duration
	write_short( 1<<Time ) // fade lasts this long hold time
	write_short( 1<<LastTime ) // fade type (in / out)
	write_byte( ColorR ) // fade red
	write_byte( ColorG ) // fade green
	write_byte( ColorB ) // fade blue
	write_byte( Alpha ) // fade alpha
	message_end()
}
public API_EffectTeleport(origin0,origin1,origin2)
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( TE_TELEPORT ) 
	write_coord( origin0 ) 
	write_coord( origin1 ) 
	write_coord( origin2 ) 
	message_end()
}

public API_EffectSmoke(id,origin0,origin1,origin2)
{
	new origin[3]
	origin[0] = origin0
	origin[1] = origin1
	origin[2] = origin2
		
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin )
	write_byte( TE_SMOKE )
	write_coord( origin[0] + random_num( -100, 100 ))
	write_coord( origin[1] + random_num( -100, 100 ))
	write_coord( origin[2] + random_num( -50, 50 ))
	write_short( g_MsgSmoke )
	write_byte( 60 ) // scale * 10
	write_byte( 10  ) // framerate
	message_end()
}
public API_EffectExp(id,origin0,origin1,origin2)
{
	new origin[3]
	origin[0] = origin0
	origin[1] = origin1
	origin[2] = origin2

	message_begin( MSG_PVS, SVC_TEMPENTITY, origin )
	write_byte( TE_EXPLOSION) // This just makes a dynamic light now
	write_coord( origin[0] + random_num( -100, 100 ))
	write_coord( origin[1] + random_num( -100, 100 ))
	write_coord( origin[2] + random_num( -50, 50 ))
	write_short( g_MsgExplode )
	write_byte( random_num(0,20) + 20  ) // scale * 10
	write_byte( 12  ) // framerate
	write_byte( TE_EXPLFLAG_NONE )
	message_end()
}

public API_ShakeScreen(id,amount,time)
{
	message_begin(MSG_ONE,g_MsgShake,{0,0,0},id) 
	write_short(1<<amount) // shake amount 
	write_short(1<<time) // shake lasts this long 
	write_short(1<<13) // shake noise frequency 
	message_end() 
}
/* ******************  Here we precache the files needed. And we Have the effects used by the runes *************************/
/********************************************** API related functions END ****************************************/
/* Rune spawn vector system, either generated by spawn points or read from a file */


public GetSpawnVec()
{
	get_localinfo("amxx_basedir",gs_SaveFile,127)
	new MapName[20]
	get_mapname(MapName,19)
	format(gs_SaveFile,127,"%s/data/runemod",gs_SaveFile)
	strtolower(gs_SaveFile)
	
/*
	if(!dir_exists(gs_SaveFile))
	{
		log_amx("Missing '%s' folder check readme, runemod will be disabled",gs_SaveFile)
		g_IsRunemodDisabled = 1
		return PLUGIN_CONTINUE;
	}
*/	
	format(gs_SaveFile,127,"%s/%s.txt",gs_SaveFile,MapName)
		
	
	if(file_exists(gs_SaveFile))
	{
		g_NumberOfSpawnPoints = ReadSpawnVec()
		if(g_NumberOfSpawnPoints > 0)
		{
			server_print("[Runemod] Found %d spawn points via %s on line",g_NumberOfSpawnPoints,gs_SaveFile)
		}
		else if(g_NumberOfSpawnPoints == 0)
		{
			//GetVecSpawnPoints()
			GenSpawns()
			server_print("[Runemod] %d spawn points was generated",g_NumberOfSpawnPoints)
		}
	}
	else
	{
		GenSpawns()
		server_print("[Runemod] %s did not exist, generated %d spawns",gs_SaveFile,g_NumberOfSpawnPoints)
	}
	return PLUGIN_CONTINUE
}
stock ReadSpawnVec()
{
	if(!file_exists(gs_SaveFile)) return -1
	new InfoFromFile[32],EOF,StringVector[3][20]
	
	for(new i=0;read_file(gs_SaveFile,i,InfoFromFile,31,EOF) != 0 && i<= MAX_SPAWNPOINTS;i++)
	{
		parse(InfoFromFile,StringVector[0],19,StringVector[1],19,StringVector[2],19)
		
		if(strlen(StringVector[0]) >= 1 && strlen(StringVector[1]) >= 1 && strlen(StringVector[2]) >= 1)
		{
			g_NumberOfSpawnPoints++
			g_SpawnOrigin[g_NumberOfSpawnPoints][0] = str_to_num(StringVector[0])
			g_SpawnOrigin[g_NumberOfSpawnPoints][1] = str_to_num(StringVector[1])
			g_SpawnOrigin[g_NumberOfSpawnPoints][2] = str_to_num(StringVector[2])
		}
//		server_print("Found Vector: %d %d %d",g_SpawnOrigin[g_NumberOfSpawnPoints][0],g_SpawnOrigin[g_NumberOfSpawnPoints][1],g_SpawnOrigin[g_NumberOfSpawnPoints][2])
	}
	return g_NumberOfSpawnPoints
}
stock SavingSpawnVec() // This is the function that saves the spawn vectors in Vault
{
	if(g_NumberOfSpawnPoints == 0) return PLUGIN_CONTINUE		// If it has -2 this means the user has not yet read the old vault file
	if(file_exists(gs_SaveFile)) delete_file(gs_SaveFile)

	new TempString[60]
	for(new i=1;i<=g_NumberOfSpawnPoints;i++)
	{
		format(TempString,59,"%d %d %d",g_SpawnOrigin[i][0],g_SpawnOrigin[i][1],g_SpawnOrigin[i][2])
		write_file(gs_SaveFile,TempString,-1)
	}
	server_print("[Runemod] Saved %d spawns in %s",g_NumberOfSpawnPoints,gs_SaveFile)
	return PLUGIN_CONTINUE
}

#if MOD == MOD_TS
// This function gets g_SpawnOrigin spawn points
stock GetVecSpawnPoints()
{
	new Class[24]
	for(new i=g_MaxPlayers;i<=g_MaxEnts && g_NumberOfSpawnPoints <= MAX_SPAWNPOINTS;i++) if(is_valid_ent(i))
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal("info_player_deathmatch",Class))
			{
				new Float:TempVec[3]
				entity_get_vector(i,EV_VEC_origin,TempVec)
				
				g_SpawnOrigin[g_NumberOfSpawnPoints][0] = TempVec[0]
				g_SpawnOrigin[g_NumberOfSpawnPoints][1] = TempVec[1]
				g_SpawnOrigin[g_NumberOfSpawnPoints][2] = TempVec[2] + 15 // we do this so the rune is spawned in the air
				g_NumberOfSpawnPoints++
			}
		}
}
#endif
#if MOD == MOD_CSTRIKE
stock GetVecSpawnPoints()
{
	new Class[24]
	for(new i=g_MaxPlayers;i<=g_MaxEnts && g_NumberOfSpawnPoints <= MAX_SPAWNPOINTS;i++) if(is_valid_ent(i))
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal("info_player_deathmatch",Class) || equal("info_player_start",Class))
			{
				new TempVec[3]
				get_origin(i,TempVec)
				// server_print("TempVec: %d %d %d",TempVec[0],TempVec[1],TempVec[2])
				
				g_SpawnOrigin[g_NumberOfSpawnPoints][0] = TempVec[0]
				g_SpawnOrigin[g_NumberOfSpawnPoints][1] = TempVec[1]
				g_SpawnOrigin[g_NumberOfSpawnPoints][2] = TempVec[2] + 15 // we do this so the rune is spawned in the air
				g_NumberOfSpawnPoints++
			}
		}
}
#endif
public plugin_end() 
{
	if(g_Settings & SAVE_RUNESVEC && g_NumberOfSpawnPoints >= 1) SavingSpawnVec()
	
	remove_task(64)
	remove_task(128)
	remove_task(256)
	
	for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i])
		RemoveRuneFromPlayer(i,USER_DROPEDRUNE)
	for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0])
		RemoveRuneFromWorld(g_RuneEntNum[i][0])	
}
/* Rune spawn vector system, either generated by spawn points or read from a file END*/

// This part of the code contains misc Stocks used all around the plugin:

// This function is used to check if a rune has a rune
// FindOrSave 0 means we are checking if the Ent number is in use by a Rune
// FindOrSave 1 Means we are saving a Ent Number for a newly spawned rune
// FindOrSave 2 Means we delete the Ent Number in the g_RuneEntNum array 
// FindOrSave 3 Find the RuneIndex based on the EntNumber
// FindOrSave 4 We are checkig to see if any runes with that runenindex are allready spawned

stock IsRuneEnt(EntNum,FindOrSave,RuneIndex)
{
	if(FindOrSave == 0 || FindOrSave == 2  || FindOrSave == 3)
	{
		for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0] == EntNum)
			{
				if(FindOrSave == 0) return i
				else if(FindOrSave == 2) 
				{
					g_RuneEntNum[i][0] = 0
					g_RuneEntNum[i][1] = 0
					return 0
				}
				else if(FindOrSave == 3) 
				{
					return g_RuneEntNum[i][1]
				}				
			}
		return 0
	}
	else if(FindOrSave == 1)
	{
		for(new i=0;i<=MAX_RUNESINGAME;i++) if(!g_RuneEntNum[i][0])
		{	
			g_RuneEntNum[i][0] = EntNum
			g_RuneEntNum[i][1] = RuneIndex
			g_RuneEntNum[i][RUNE_AGE] = 0
			return 1
		}
	}
	else if(FindOrSave == 4)
	{
		for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][1] == RuneIndex)
		{	
			return g_RuneEntNum[i][0]
		}
		return 0
	}
	return PLUGIN_HANDLED
}
stock RemoveRuneSpawnPoint(SpawnPoint)
{
	if(g_NumberOfSpawnPoints != SpawnPoint)
	{
		g_SpawnOrigin[SpawnPoint] = g_SpawnOrigin[g_NumberOfSpawnPoints]
		g_NumberOfSpawnPoints--
	}
	else
		g_NumberOfSpawnPoints--	
}
// This function is used to remove a rune from the world.Called normaly when a player pickup the rune
stock RemoveRuneFromWorld(EntNum)
{
	IsRuneEnt(EntNum,2,0)
	g_RunesInWorld--
	remove_entity(EntNum)
}

// This is the function that gives a rune to a player
stock PickupRune(id,RuneIndex,RuneEntNum)
{
#if debug == 1
	new RuneInPlay[500]
	for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i])
	{
//		new Name[32]
//		get_user_name(i,Name,31)
		format(RuneInPlay,499,"%s %s",RuneInPlay,gs_RuneName[g_UserHasRune[i]])
	}
	server_print("[Runemod Debug] Runes in Play(%s): %s",gs_RuneName[RuneIndex],RuneInPlay)
	
#endif		
	new Message[MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+2]
	new WasRunePickedUp=0
	
	callfunc_begin_i(g_FuncIndex[RuneIndex][Func_PickUpRune],g_PluginIndex[RuneIndex])
	callfunc_push_int(id)
	WasRunePickedUp = callfunc_end()	
	
	if(g_RuneFlags[RuneIndex] & API_PICKUPANDFORGET)	// This means we have picked up a rune thats "API_PICKUPANDFORGET" this means you can have other runes + this one. This rune is nto realy handeled at all by the plugin. And most often is not realy a rune, but rather a minor powerup like medpack
	{
		if(WasRunePickedUp == 0) return PLUGIN_CONTINUE	// This means user could not get the rune
		

		new RuneName[MAX_PLUGIN_RUNENAME_SIZE+1]
		GetRuneName(id,RuneName,RuneIndex)
		
		format(Message,MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+1,"%L",LANG_PLAYER,"BasePickUpOneTimeRune",RuneName)
		HudMessage2(id,Message)
	}
	else
	{
		g_UserHasRune[id] = RuneIndex
		g_UserHasRune[0]++
	
		new RuneName[MAX_PLUGIN_RUNENAME_SIZE+1]
		GetRuneName(id,RuneName,RuneIndex)
		client_print(id,print_chat,"%L",LANG_PLAYER,"BasePickUpRune",RuneName)
		
		if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
			format(Message,MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+1,"%L^n %L",LANG_PLAYER,gs_RuneName[RuneIndex],LANG_PLAYER,gs_RuneDesc[RuneIndex])
		else
			format(Message,MAX_PLUGIN_RUNENAME_SIZE+MAX_PLUGIN_RUNEDESC_SIZE+1,"%s^n %s",gs_RuneName[RuneIndex],gs_RuneDesc[RuneIndex])

		
		
		set_hudmessage(255, 255, 255, 0.92, 0.85, 4.0,HUD_CHANNEL) 		// We now update the hudmessage on his screen
		show_hudmessage(id,Message)	
		
		emit_sound(id, CHAN_WEAPON, "items/gunpickup1.wav", 0.5, ATTN_NORM, 0, PITCH_NORM)
		
	}
#if debug == 1
	new Name[32]
	get_user_name(id,Name,31)
	server_print("[Runemod Debug] %s has picked up %s",Name,gs_RuneName[RuneIndex])
#endif	
	if(RuneEntNum != 0) RemoveRuneFromWorld(RuneEntNum)	// Everyting went ok. We now remove the rune from the world
	return PLUGIN_CONTINUE
}
stock RandomRuneIndex(Runes2Spawn)	// This is the function used to find a random rune.
{
	new RuneIndex
	if(g_Settings & ONLYUNIQUERUNES && g_Settings & 256) 	// This means the server only wants unqie runes, and wants to spawn every rune thats not in use
	{
		new IsUniqe=0
		while(IsUniqe == 0 && RuneIndex <= g_NumberOfRunes)	// We now do a while loop doing random untill we get a unqie rune
		{
			RuneIndex++
			if(!IsRuneEnt(0,4,RuneIndex) && !HasUserThisRune(RuneIndex) && !g_RuneDisabled[RuneIndex])
				IsUniqe=1
		}
		if(IsUniqe == 1)
			return RuneIndex
		return -1
	}
	else if(g_Settings & ONLYUNIQUERUNES) 	// This means the server only wants unqie runes. In other words only 1 player may have X rune
	{
		if((g_RuneDisabled[0] + g_UserHasRune[0] + g_RunesInWorld) > g_NumberOfRunes )
		
		{
			client_print(0,print_chat,"[Runemod] Server is trying to spawn to many runes")
			log_amx("[Runemod] Tried to spawn to many runes ( Your trying to spawn more uniqe runes then the server has ) Total Runes: %d Disabled: %d HasUser: %d World: %d",g_NumberOfRunes,g_RuneDisabled[0],g_UserHasRune[0],g_RunesInWorld)
			return -1
		}
		new RuneList[MAX_PLUGINS+1]
		if(Runes2Spawn > 10) 	// This means the server is trying to spawn more then 10 runes, and doing this via random can be take alot of tries. So we make a array list
		{
			new NOR=0	// Number of runes
			for(new i=1;i<=g_NumberOfRunes;i++)
			{
				if(!IsRuneEnt(0,4,i) && !HasUserThisRune(i) && !g_RuneDisabled[i])
				{
					NOR++
					RuneList[NOR] = i
				}
			}
			RuneIndex = random_num(1,NOR)
		}
		else	// This means we are going to find a runeindex based on random.
		{
			RuneIndex = random_num(1,g_NumberOfRunes)
			
			new IsUniqe=0
			if(!IsRuneEnt(0,4,RuneIndex) && !HasUserThisRune(RuneIndex) && !g_RuneDisabled[RuneIndex])
				IsUniqe=1
			while(IsUniqe == 0)	// We now do a while loop doing random untill we get a unqie rune
			{
				//server_print("RuneIndex: %d IsInWorld: %d User: %d RuneDisabled %d",RuneIndex,IsRuneEnt(0,4,RuneIndex),HasUserThisRune(RuneIndex),g_RuneDisabled[RuneIndex])
				if(!IsRuneEnt(0,4,RuneIndex) && !HasUserThisRune(RuneIndex) && !g_RuneDisabled[RuneIndex])
					IsUniqe=1
				else 
					RuneIndex = random_num(1,g_NumberOfRunes)
			}
		}
		return RuneIndex
	}
	else	// This means we are free to find any random rune, just make sure its not disabled yet
	{
		RuneIndex = random_num(1,g_NumberOfRunes)
		while(g_RuneDisabled[RuneIndex])
		{
			RuneIndex = random_num(1,g_NumberOfRunes)
		}
		return RuneIndex
	}
	return -1
}
stock is_vail_rune(RuneIndex)
{
	if(RuneIndex <= g_NumberOfRunes && RuneIndex > 0)
		return 1
	else return 0

	return 0
}
stock CheckDistance(EntNum,IndexInSpawnArray) 	// This stuck is used to check the distance between where a rune is spawned, and the other runes ingame. To make sure their not spawned to close together
{
	new Origin[3]
	for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0] && g_RuneEntNum[i][0] != EntNum)
	{
		get_origin(g_RuneEntNum[i][0],Origin)

		if(get_distance(Origin,g_SpawnOrigin[IndexInSpawnArray]) < MIN_DISTANCE_BETWEEN_RUNES)
		{
			return 2
		}
	}
	return 1
}
stock HasUserThisRune(rune)
{
	for(new i=1;i<=g_MaxPlayers;i++) if(rune == g_UserHasRune[i])
		return 1
	return 0
}
stock cs_ResetSpeed(id,weaponnum)
{
	if (weaponnum==3){ //scout
		if (g_IsZooming[id]==1)
		{
			set_user_maxspeed(id,220.0)
			return 220
		}
		else
		{
			set_user_maxspeed(id,260.0) //220 zoomed
			return 260
		}
	}       
	else if (weaponnum==5)
	{ //xm1014
		set_user_maxspeed(id,230.0)
		return 230
	}
	else if (weaponnum==7 || weaponnum==12 || weaponnum==19 || weaponnum==23)
	{ //mac10
		set_user_maxspeed(id,250.0)
		return 250
	}
	else if (weaponnum==8 || weaponnum==21 || weaponnum==14 || weaponnum==15)
	{ //aug - bollup
		set_user_maxspeed(id,240.0)
		return 240
	}
	else if (weaponnum==13 || weaponnum==18 || weaponnum== 230)
	{ //sg550
		if (g_IsZooming[id]==1)
		{
			set_user_maxspeed(id,150.0)
			return 150
		}
		else
		{
			set_user_maxspeed(id,210.0) //150 zoomed
			return 210
		}
	}
	else if (weaponnum==20 || weaponnum==28)
	{ //m249
		set_user_maxspeed(id,220.0)
		return 220
	}
	else if (weaponnum==22)
	{ //M4A1
		set_user_maxspeed(id,230.0)
		return 230
	}
	else if (weaponnum==27)
	{ //sg552
		set_user_maxspeed(id,235.0)
		return 235
	}
	else if (weaponnum==30)
	{ //P90
		set_user_maxspeed(id,245.0)
		return 245
	}
	else 
	{
		set_user_maxspeed(id,260.0)
		return 260
	}
	return -1
}
#if HTML_MOTD == 1
stock RGBtoHex(RGBNum)	// This function is used to change a HL RGB color into a HTML HEX color.
{
	new myIntR1 = RGBNum / 16 // first digit -- dec 
	new myIntR2 = RGBNum - (myIntR1 * 16) // second digit -- dec 
	new MyString[3]
	
	// Now we convert them into hex 
	// First digit 
	if ( myIntR1 < 9 ) 
	  format(MyString,2,"%s%d",MyString,myIntR1)
	else if( myIntR1 == 10 ) 
	  format(MyString,2,"A")
	else if( myIntR1 == 11 ) 
	  format(MyString,2,"B")
	else if( myIntR1 == 12 ) 
	  format(MyString,2,"C") 
	else if( myIntR1 == 13 ) 
	  format(MyString,2,"D")
	else if( myIntR1 == 14 ) 
	  format(MyString,2,"E")
	else if( myIntR1 == 15 ) 
	  format(MyString,2,"F") 
	
	// Second digit 
	if ( myIntR2 < 9 ) 
	  format(MyString,2,"%s%d",MyString,myIntR2)
	else if( myIntR2 == 10 ) 
	  format(MyString,2,"%sA",MyString)
	else if( myIntR2 == 11 ) 
	  format(MyString,2,"%sB",MyString)
	else if( myIntR2 == 12 ) 
	  format(MyString,2,"%sC",MyString) 
	else if( myIntR2 == 13 ) 
	  format(MyString,2,"%sD",MyString)
	else if( myIntR2 == 14 ) 
	  format(MyString,2,"%sE",MyString) 
	else if( myIntR2 == 15 ) 
	  format(MyString,2,"%sF",MyString)
	
	format(gs_Test,2,"%s",MyString)
}
public CmdGenRuneList(id)
{
	if(!(get_user_flags(id) & ADMIN_RCON)) return PLUGIN_HANDLED
	new FileName[128],Lang[3],len
	get_localinfo("amxx_basedir",FileName,127)
	get_user_info(id,"lang",Lang,2)
	
	format(FileName,127,"%s/runelist_%s.htm",FileName,Lang)
	if(file_exists(FileName)) delete_file(FileName)
	
	len = format(gs_MOTDMessage,1535,"<html> <body bgcolor=^"#000000^" text=^"#FFFFFF^"> </body>Runemod help<br>") 
	for(new i=1;i<=g_NumberOfRunes;i++)
	{
		if(g_RuneFlags[i] & API_PICKUPANDFORGET)
		{
			if(g_RuneFlags[i] & API_USELANGSYSTEM)
				len += format(gs_MOTDMessage[len],1535 - len,"%d)%L<br>",i,id,gs_RuneName[i])	
			else 
				len += format(gs_MOTDMessage[len],1535 - len,"%d)%s<br>",i,gs_RuneName[i])	
		}
		else
		{
			new Color[12]
						 
			RGBtoHex(g_RuneColor[i][0])
			format(Color,11,"%s",gs_Test)
			RGBtoHex(g_RuneColor[i][1])
			format(Color,11,"%s%s",Color,gs_Test)
			RGBtoHex(g_RuneColor[i][2])
			format(Color,11,"%s%s",Color,gs_Test)
				
	
			if(g_RuneFlags[i] & API_USELANGSYSTEM)
				len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%L</font> - %L<br>",i,Color,id,gs_RuneName[i],id,gs_RuneDesc[i])	
			else
				len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%s</font> - %s<br>",i,Color,gs_RuneName[i],gs_RuneDesc[i])	
		}
		write_file(FileName,gs_MOTDMessage)
		len = 0
		setc(gs_MOTDMessage,1535,0)
	}
	len += format(gs_MOTDMessage[len],1535 - len,"</html>")
	write_file(FileName,gs_MOTDMessage)
	
	console_print(id,"%L",LANG_PLAYER,"BaseGenHtmlFile",FileName)
	return PLUGIN_HANDLED
}
stock MakeMotdMessage(id)
{
	new len
	if(g_NumberOfRunes <= 17)	// We check to make sure we are not gonna exeede the max size
	{
		len = format(gs_MOTDMessage,1535,"<html> <body bgcolor=^"#000000^" text=^"#FFFFFF^"> </body>Runemod help<br>") 
		for(new i=1;i<=g_NumberOfRunes;i++)
		{
			if(g_RuneFlags[i] & API_PICKUPANDFORGET)
			{
				if(g_RuneDisabled[i])
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d) - %L(Disabled)<br>",i,id,gs_RuneName[i])
					else
						len += format(gs_MOTDMessage[len],1535 - len,"%d) - %s(Disabled)<br>",i,gs_RuneName[i])
						
				}
				else
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d) - %L<br>",i,id,gs_RuneName[i])	
					else 
						len += format(gs_MOTDMessage[len],1535 - len,"%d) - %s<br>",i,gs_RuneName[i])	
				}
			}
			else
			{
				new Color[12]
						 
				RGBtoHex(g_RuneColor[i][0])
				format(Color,11,"%s",gs_Test)
				RGBtoHex(g_RuneColor[i][1])
				format(Color,11,"%s%s",Color,gs_Test)
				RGBtoHex(g_RuneColor[i][2])
				format(Color,11,"%s%s",Color,gs_Test)
				
	
				if(g_RuneDisabled[i] == 0)
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%L</font> - %L<br>",i,Color,id,gs_RuneName[i],id,gs_RuneDesc[i])	
					else
						len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%s</font> - %s<br>",i,Color,gs_RuneName[i],gs_RuneDesc[i])	
				
				}
				else
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%L</font> - %L(Disabled)<br>",i,Color,id,gs_RuneName[i],id,gs_RuneDesc[i])	
					else
						len += format(gs_MOTDMessage[len],1535 - len,"%d)<font color=^"#%s^">%s</font> - %s(Disabled)<br>",i,Color,gs_RuneName[i],gs_RuneDesc[i])	
				}
			}
		}
		len += format(gs_MOTDMessage[len],1535 - len,"</html>")	
	}
	else
	{

		len = format(gs_MOTDMessage,1535,"Runemod help<br>") 
		for(new i=1;i<=g_NumberOfRunes;i++) if(!(g_RuneFlags[i] & API_PICKUPANDFORGET))
		{
			if(g_RuneFlags[i] & API_PICKUPANDFORGET)
			{
				if(g_RuneDisabled[i])
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d)%L (Disabled)<br>",i,id,gs_RuneName[i])
					else
						len += format(gs_MOTDMessage[len],1535 - len,"%d)%s (Disabled)<br>",i,gs_RuneName[i])
				}
				else
				{
					if(g_RuneFlags[i] & API_USELANGSYSTEM)
						len += format(gs_MOTDMessage[len],1535 - len,"%d)%L<br>",i,id,gs_RuneName[i])	
					else
						len += format(gs_MOTDMessage[len],1535 - len,"%d)%s<br>",i,gs_RuneName[i])	
				}
			}
			else if(g_RuneDisabled[i] == 0)
			{
				if(g_RuneFlags[i] & API_USELANGSYSTEM)
					len += format(gs_MOTDMessage[len],1535 - len,"%d)%L - %L<br>",i,id,gs_RuneName[i],id,gs_RuneDesc[i])	
				else
					len += format(gs_MOTDMessage[len],1535 - len,"%d)%s - %s<br>",i,gs_RuneName[i],gs_RuneDesc[i])	
				
			}
			else
			{
				if(g_RuneFlags[i] & API_USELANGSYSTEM)
					len += format(gs_MOTDMessage[len],1535 - len,"%d)%L - %L(Disabled)<br>)",i,id,gs_RuneName[i],id,gs_RuneDesc[i])	
				else
					len += format(gs_MOTDMessage[len],1535 - len,"%d)%s - %s(Disabled)<br>)",i,gs_RuneName[i],gs_RuneDesc[i])	
			}
		}

	}
}
#else
stock MakeMotdMessage(id)
{
	new len
	len = format(gs_MOTDMessage,1535,"Runemod help^n") 
	for(new i=1;i<=g_NumberOfRunes;i++)
	{
		if(g_RuneFlags[i] & API_USELANGSYSTEM)
			len += format(gs_MOTDMessage[len],1535 - len,"%d)%L - %L^n",i,id,gs_RuneName[i],id,gs_RuneDesc[i])	
		else
			len += format(gs_MOTDMessage[len],1535 - len,"%d)%s - %s^n",i,gs_RuneName[i],gs_RuneDesc[i])
	}
}
#endif
#define BEHINDBASESIZE 750
stock GenSpawns()	//taken from Bail's Root Plugin, generates random spawn points
{
	new ctbase_id
	new tbase_id
	new Float:base_origin_temp[3]
	new Float:ctbase_origin[3] = {0.0,...}
	new Float:tbase_origin[3] = {0.0,...}
	new Float:pspawncounter

	pspawncounter = 0.0
	ctbase_id = find_ent_by_class(-1,"info_player_start")
	while (ctbase_id != 0)
	{
		pspawncounter +=1.0
		entity_get_vector (ctbase_id,EV_VEC_origin,base_origin_temp)
		ctbase_origin[0] += base_origin_temp[0]
		ctbase_origin[1] += base_origin_temp[1]
		ctbase_origin[2] += base_origin_temp[2]
		ctbase_id = find_ent_by_class(ctbase_id,"info_player_start")
	}

	ctbase_origin[0] = ctbase_origin[0] / pspawncounter
	ctbase_origin[1] = ctbase_origin[1] / pspawncounter
	ctbase_origin[2] = ctbase_origin[2] / pspawncounter

	pspawncounter = 0.0
	tbase_id = find_ent_by_class(-1,"info_player_deathmatch")
	while (tbase_id != 0)
	{
		pspawncounter +=1.0
		entity_get_vector (tbase_id,EV_VEC_origin,base_origin_temp)
		tbase_origin[0] += base_origin_temp[0]
		tbase_origin[1] += base_origin_temp[1]
		tbase_origin[2] += base_origin_temp[2]
		tbase_id = find_ent_by_class(tbase_id,"info_player_deathmatch")
	}

	tbase_origin[0] = tbase_origin[0] / pspawncounter
	tbase_origin[1] = tbase_origin[1] / pspawncounter
	tbase_origin[2] = tbase_origin[2] / pspawncounter


	new Float:ia[3]
	new Float:square_o1[3]
	new Float:square_o2[3]
	if(tbase_origin[0]>ctbase_origin[0])
	{
		square_o1[0] = tbase_origin[0]+BEHINDBASESIZE
		square_o2[0] = ctbase_origin[0]-BEHINDBASESIZE
	} else {
		square_o1[0] = ctbase_origin[0]+BEHINDBASESIZE
		square_o2[0] = tbase_origin[0]-BEHINDBASESIZE
	}
	if(tbase_origin[1]>ctbase_origin[1])
	{
		square_o1[1] = tbase_origin[1]+BEHINDBASESIZE
		square_o2[1] = ctbase_origin[1]-BEHINDBASESIZE
	} else 	{
		square_o1[1] = ctbase_origin[1]+BEHINDBASESIZE
		square_o2[1] = tbase_origin[1]-BEHINDBASESIZE
	}		
	if(tbase_origin[2]>ctbase_origin[2])
	{
		square_o1[2] = tbase_origin[2]+1000
		square_o2[2] = ctbase_origin[2]-1000
	} else {
		square_o1[2] = ctbase_origin[2]+1000
		square_o2[2] = tbase_origin[2]-1000
	}
		

	new bool:xyused[11][11]
	new Float:xadd = (square_o1[0]-square_o2[0]) / 9.0
	new Float:yadd = (square_o1[1]-square_o2[1]) / 9.0		
	new Float:zadd = (square_o1[2]-square_o2[2]) / 9.0
	new IntOr[3]

	new bool:baseswitcher = true
	new countery = 0
	for(ia[1]=square_o2[1];ia[1] <=square_o1[1]&& g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && countery < 10;ia[1]+=yadd)
	{
		new counterx = 0
		countery++
		for(ia[0]=square_o2[0];ia[0] <=square_o1[0] && g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && counterx < 10;ia[0]+=xadd)
		{
			counterx++
			if(baseswitcher)
			{
				ia[2] = ctbase_origin[2]+16.0
				baseswitcher = false
			} else {
				ia[2] = tbase_origin[2]+16.0
				baseswitcher = true
			}
			ia[0] = float(floatround(ia[0]) + random(130)-65)
			ia[1] = float(floatround(ia[1]) + random(130)-65)
			ia[2] = float(floatround(ia[2]))

			IntOr[0] = floatround(ia[0])
			IntOr[1] = floatround(ia[1])
			IntOr[2] = floatround(ia[2])
						
			if( point_contents(ia) == CONTENTS_EMPTY && !xyused[counterx][countery] && CheckVectorContent(IntOr) == 1 && CheckSpawnPointDist(IntOr) == 1 && CheckDistDown(ia) == 1)
			{
				xyused[counterx][countery] = true
				g_NumberOfSpawnPoints++
				g_SpawnOrigin[g_NumberOfSpawnPoints][0] = IntOr[0]
				g_SpawnOrigin[g_NumberOfSpawnPoints][1] = IntOr[1]
				g_SpawnOrigin[g_NumberOfSpawnPoints][2] = IntOr[2]
			}
		}
	}
	for(ia[2]=(ctbase_origin[2] + tbase_origin[2] ) /2.0;ia[2] <=square_o1[2]&& g_NumberOfSpawnPoints < MAX_SPAWNPOINTS ;ia[2]+=zadd)
	{
		countery = 0
		for(ia[1]=square_o2[1];ia[1] <=square_o1[1] && g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && countery < 10;ia[1]+=yadd)
		{
			new counterx = 0
			countery++
			for(ia[0]=square_o2[0];ia[0] <=square_o1[0] && g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && counterx < 10;ia[0]+=xadd)
			{
				counterx++
				ia[0] = float(floatround(ia[0]) + random(130)-65)
				ia[1] = float(floatround(ia[1]) + random(130)-65)
				ia[2] = float(floatround(ia[2]))

				IntOr[0] = floatround(ia[0])
				IntOr[1] = floatround(ia[1])
				IntOr[2] = floatround(ia[2])				
				
				if( point_contents(ia) == CONTENTS_EMPTY && !xyused[counterx][countery] && CheckVectorContent(IntOr) == 1 && CheckSpawnPointDist(IntOr) == 1 && CheckDistDown(ia) == 1)
				{
					xyused[counterx][countery] = true
					g_NumberOfSpawnPoints++
					g_SpawnOrigin[g_NumberOfSpawnPoints][0] = IntOr[0]
					g_SpawnOrigin[g_NumberOfSpawnPoints][1] = IntOr[1]
					g_SpawnOrigin[g_NumberOfSpawnPoints][2] = IntOr[2]
				}
			}
		}
	}

	for(ia[2]=(ctbase_origin[2] + tbase_origin[2] ) /2.0;ia[2] >=square_o2[1]&& g_NumberOfSpawnPoints < MAX_SPAWNPOINTS;ia[2]-=zadd)
	{
		countery = 0
		for(ia[1]=square_o2[1];ia[1] <=square_o1[1]&& g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && countery < 10;ia[1]+=yadd)
		{
			new counterx = 0
			countery++
			for(ia[0]=square_o2[0];ia[0] <=square_o1[0] && g_NumberOfSpawnPoints < MAX_SPAWNPOINTS && counterx < 10;ia[0]+=xadd)
			{
				counterx++
				ia[0] = float(floatround(ia[0]) + random(130)-65)
				ia[1] = float(floatround(ia[1]) + random(130)-65)
				ia[2] = float(floatround(ia[2]))
				
				IntOr[0] = floatround(ia[0])
				IntOr[1] = floatround(ia[1])
				IntOr[2] = floatround(ia[2])
					
				if( point_contents(ia) == CONTENTS_EMPTY && !xyused[counterx][countery] && CheckVectorContent(IntOr) == 1 && CheckSpawnPointDist(IntOr) == 1 && CheckDistDown(ia) == 1)
				{
					xyused[counterx][countery] = true
					g_NumberOfSpawnPoints++
					g_SpawnOrigin[g_NumberOfSpawnPoints][0] = IntOr[0]
					g_SpawnOrigin[g_NumberOfSpawnPoints][1] = IntOr[1]
					g_SpawnOrigin[g_NumberOfSpawnPoints][2] = IntOr[2]
				}
			}
		}
	}
}
stock CheckDistDown(Float:Org1[3])	// This functions is used to check how far the rune location is from the round, this is done by doing a traceline directly down.
{
	new Float:Org2[3]
	new Float:HitOrg[3]

	Org2[0] = Org1[0]
	Org2[1] = Org1[1]
	Org2[2] = -4096.0
	
	trace_line(1,Org1,Org2, HitOrg)
	if(vector_distance(Org1,HitOrg) <= MIN_DISTANCE_BETWEEN_RUNES)
		return 1
	return 0
	
}
stock CheckSpawnPoint(SpawnPoint)	// This function check how close a rune spawnpoint is to other rune spawnpoints. And removes any that witin MIN_DISTANCE_BETWEEN_RUNES ( runemod.inc )
{
	new SPR=0		// Spawn points removed
	for(new i=1;i<=g_NumberOfSpawnPoints;i++) if(SpawnPoint != i)
	{
		if(get_distance(g_SpawnOrigin[SpawnPoint],g_SpawnOrigin[i]) <= MIN_DISTANCE_BETWEEN_RUNES)
		{
			SPR++
			RemoveRuneSpawnPoint(i)
		}
	}
	return SPR
}
stock GetRuneName(id,RuneName[],RuneIndex) 		 // This function return the rune name. Uses translation system  if needed
{
	if(g_RuneFlags[RuneIndex] & API_USELANGSYSTEM)
		format(RuneName,MAX_PLUGIN_RUNENAME_SIZE,"%L",id,gs_RuneName[RuneIndex])
	else 
		copy(RuneName,MAX_PLUGIN_RUNENAME_SIZE,gs_RuneName[RuneIndex])
		
	return RuneName
}
stock CheckSpawnPointDist(Org1[3])
{
	for(new i=1;i<=g_NumberOfSpawnPoints;i++)
	{
		if(get_distance(Org1,g_SpawnOrigin[i]) <= MIN_DISTANCE_BETWEEN_RUNES)
		{
			return -1
		}
	}
	return 1
}

stock CheckVectorContent(IntO[3])	// This function check how close a rune spawnpoint is to other rune spawnpoints. And removes any that witin MIN_DISTANCE_BETWEEN_RUNES ( runemod.inc )
{
	new Float:Origin[3]
	Origin[0] = float(IntO[0])
	Origin[1] = float(IntO[1])
	Origin[2] = float(IntO[2])

	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0
	
	Origin[0] += 5.0	
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[0] -= 10.0	
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[0] += 5.0
	Origin[1] += 5.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[1] -= 10.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0
		
	Origin[1] += 5.0
	Origin[2] += 5.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[2] -= 10.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0		
	return 1
}
stock CheckSpere(SO[3])		// This is the function used to check a origin, to see if any runes are around ( Its used to check if the player is looking at a rune)
{
	new Dist
	new ShortestDist = SpereDist + SpereDist
	new ClosestEnt
	new EO[3]

	for(new i=0;i<=MAX_RUNESINGAME;i++) if(g_RuneEntNum[i][0] > 0)
	{
		new EntNum = g_RuneEntNum[i][0]
		get_origin(EntNum,EO)
		Dist = get_distance(SO,EO)
			
		if( Dist <= SpereDist)
		{
			if(ShortestDist > Dist)
			{
				ClosestEnt = EntNum
				ShortestDist = Dist
			}
		}
	}
	return ClosestEnt
}
stock RemoveBadRunes()
{
	for(new i=0;i<=MAX_PLUGINS;i++)
		g_LastDescReturned[i] = -1
	
	for(new i=1;i<=g_MaxPlayers;i++) if(g_UserHasRune[i] && g_RuneFlags[g_UserHasRune[i]] & API_BADRUNE)
		RemoveRuneFromPlayer(i,USER_DISCONNECTED)

}
stock RandomNoneBadRuneIndex(RuneIndex)
{
	if(g_LastDescReturned[RuneIndex] != -1)
		return g_LastDescReturned[RuneIndex]
		
	new TryCount = 0
	new RI = random_num(1,g_NumberOfRunes)
	
	while(TryCount <= 10  && (g_RuneFlags[RI] & API_PICKUPANDFORGET || g_RuneFlags[RI] & API_BADRUNE))
	{
		RI = random_num(1,g_NumberOfRunes)
		
		TryCount++
	}
	g_LastDescReturned[RuneIndex] = RI
	return RI
}

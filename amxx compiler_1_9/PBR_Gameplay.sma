#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <fun>

#define PLUGIN "[PBR] Gameplay"
#define VERSION "1.0"
#define AUTHOR "Sneaky.amxx"

#define GAMENAME "Paint Ball"

#define TASK_DELAY 0.1 // The delay between model changing tasks
#define MODELSET_TASK 3000 // offset for the models task
#define MENU_TASK 3500

new g_Cvar_Money, g_Cvar_StripWeapon, g_Cvar_Deathmatch, g_Cvar_SpawnProtect, g_Cvar_PBGun, 
g_Cvar_PBNade, g_Cvar_PBSNade, g_Cvar_RandomGun, g_MaxPlayers, g_Cvar_Vendetta, g_Cvar_Vendetta_Kill;
new g_TeamSelect[33], g_PlayerSkin[33], g_HasKill[33], MenuState[33], ShowMenu[33], g_Has_CustomModel[33]
new g_Team[33], g_KilledBy[33], g_Vendetta_Bonus[33], g_KillingTime[33], g_InVendetta[33]
new g_PBSuperLauncher, g_Got_SuperLauncher, Float:g_ModelCounter

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Event
	register_logevent("Event_NewRound", 2, "0=World triggered", "1=Round_Start");
	register_event("DeathMsg", "Event_Death", "a")
	register_event("Money", "Event_Money", "be")
	
	// Forward
	register_forward(FM_GetGameDescription, "fw_GameDesc");
	register_forward(FM_SetModel, "fw_SetModel", 1);
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged");
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")

	// Ham
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	
	// Cvar
	g_Cvar_PBGun = register_cvar("PBR_Gun", "1") // Enable Gun
	g_Cvar_PBNade = register_cvar("PBR_Hegrenade", "1") // Enable Hegrenade
	g_Cvar_PBSNade = register_cvar("PBR_Smokegrenade", "1") // Enable Smokegrenade

	g_Cvar_Money = register_cvar("PBR_Money", "1") // Enable Money
	g_Cvar_StripWeapon = register_cvar("PBR_StripWeapon", "1") // if players weapons are stripped in spawn
	g_Cvar_Deathmatch = register_cvar("PBR_Deathmatch", "0") // Players will respawn on death
	g_Cvar_SpawnProtect = register_cvar("PBR_SpawnProtect", "5")
	g_Cvar_RandomGun = register_cvar("PBR_GunMode", "1") // 0 - normal | 1 - menu | 2 random
	g_Cvar_Vendetta = register_cvar("PBR_Vendetta_Enable", "1")
	g_Cvar_Vendetta_Kill = register_cvar("PBR_Vendetta_Kill", "3")
	g_PBSuperLauncher = register_cvar("PBR_SuperLauncher_Enable", "1")
	
	g_MaxPlayers = get_maxplayers()
		
	register_clcmd("say /respawn", "CMD_Respawn", _, "<Respawns you if enabled>")
	register_clcmd("say /pbgun", "CMD_EnableMenu")
	register_clcmd("say pbgun", "CMD_EnableMenu")
	
	for(new i = 0; i < g_MaxPlayers; i++)
	{
		ShowMenu[i] = 1
		g_InVendetta[i] = 0
		g_KilledBy[i] = -1
		g_KillingTime[i] = 0
	}
}

public plugin_precache() precache_model("models/player/paintballer/paintballer.mdl")
public fw_GameDesc()
{
	forward_return(FMV_STRING, GAMENAME);
	return FMRES_SUPERCEDE;
}

public fw_PlayerSpawn_Post(id)
{
	if(!is_user_alive(id))
		return
		
	if(get_pcvar_num(g_Cvar_SpawnProtect))
	{
		set_pev(id, pev_takedamage, DAMAGE_NO)
		set_task(float(get_pcvar_num(g_Cvar_SpawnProtect)), "Player_GodModeOff", id+100)
	}
	if(get_pcvar_num(g_Cvar_StripWeapon))
	{
		if(pev(id, pev_weapons) & (1 << CSW_C4)) engclient_cmd(id, "drop", "weapon_c4")
		strip_user_weapons(id)
	}

	if(get_pcvar_num(g_Cvar_Money))
	{
		message_begin(MSG_ONE_UNRELIABLE, 94, _, id)
		write_byte(1<<5);
		message_end()
	}

	set_task(0.1 + g_ModelCounter, "Task_SetModel", id+MODELSET_TASK)
	g_ModelCounter += TASK_DELAY

	remove_task(id)
	set_task(random_float(0.5, 1.0), "Player_Weapon", id);
	set_task(2.0, "Clear_MoneyHud", id+300)	
}

public Event_NewRound()
{
	if(get_pcvar_num(g_Cvar_StripWeapon))
	{
		new ent;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "armoury_entity")) != 0)
			engfunc(EngFunc_RemoveEntity, ent);
		
	}
		
	g_ModelCounter = 0.0
	Select_New_SuperLauncher()
}

public Select_New_SuperLauncher()
{
	new original = g_Got_SuperLauncher
	g_Got_SuperLauncher++
	
	while((!is_user_connected(g_Got_SuperLauncher) && !is_user_bot(g_Got_SuperLauncher) && g_Got_SuperLauncher != original))
	{
		g_Got_SuperLauncher++
		if (g_Got_SuperLauncher > 32)
			g_Got_SuperLauncher = 0
	}
}

public client_command(id)
{
	new command[10], speech[2]
	
	read_argv(0, command, 9)
	read_argv(1, speech, 1)
	
	if (containi(command, "join") != -1)
	{
		if (equali(command, "jointeam")) g_TeamSelect[id] = str_to_num(speech);
		else if (equali(command, "joinclass")) g_PlayerSkin[id] = (g_TeamSelect[id] == 1) ? str_to_num(speech) - 1: str_to_num(speech) + 3;
	}
}

public Player_Weapon(id)
{
	if(!is_user_alive(id))
		return
		
	menu_cancel(id)
	
	if(g_InVendetta[id])
	{
		static KillerName[32]; get_user_name(g_KilledBy[id], KillerName, 31)
		
		set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 5.0, 5.0);
		show_hudmessage(id, "You got killed many time by [%s]. This is VENDETTA!", KillerName)
	}

	set_pdata_int(id, 386, 120, 5)
	give_item(id, "weapon_knife")
	
	if(get_user_team(id) == 1) give_item(id, "weapon_glock18");
	else  {
		set_pdata_int(id, 382, 48, 5)
		give_item(id, "weapon_usp")
	}
	
	if (get_pcvar_num(g_Cvar_PBGun) && !g_Vendetta_Bonus[id])
	{
		if(get_pcvar_num(g_Cvar_RandomGun) == 1)
		{
			if(is_user_bot(id))
			{
				ShowMenu[id] = false
				MenuState[id] = random(4)
			}
			
			if (ShowMenu[id]) LaunchMenu(id)
			else {	
				give_menu_weapon(id, MenuState[id])
				client_print(id, print_chat, "[%s] Your equipment menu has been disabled. Type /pbgun to re-enable it", GAMENAME)	
			}
		} else {
			static Choose
			if (get_pcvar_num(g_Cvar_RandomGun) == 2)
			{
				Choose = random(4)
				
				if (random(20) == 0)
				{
					give_item(id, "weapon_p90")
					cs_set_user_bpammo(id, CSW_P90, 300)
					
					set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 5.0, 5.0);
					show_hudmessage(id, "Congratulation! You've got 'Super Marker'!")
				} else {
					switch(Choose)
					{
						case 0: give_item(id, "weapon_mp5navy")
						case 1: give_item(id, "weapon_scout")
						case 2: give_item(id, "weapon_m3")
						case 3: give_item(id, "weapon_xm1014")
						default: give_item(id, "weapon_mp5navy")
					}
				}
				
				cs_set_user_bpammo(id, CSW_MP5NAVY, 150)
				cs_set_user_bpammo(id, CSW_SCOUT, 20)
				cs_set_user_bpammo(id, CSW_M3, 16)
				cs_set_user_bpammo(id, CSW_XM1014, 80)
				cs_set_user_bpammo(id, CSW_P90, 300)
			} else {
				give_item(id, "weapon_mp5navy")
				cs_set_user_bpammo(id, CSW_MP5NAVY, 150)

				Choose = random(3);					
				if(!g_HasKill[id] && !Choose)
				{
					give_item(id, "weapon_xm1014")
					cs_set_user_bpammo(id, CSW_XM1014, 80)
				}
					
				Choose = random(2);					
				if(g_HasKill[id] > 2)
				{
					if(g_HasKill[id] > 4)
					{
						give_item(id, "weapon_p90")
						cs_set_user_bpammo(id, CSW_P90, 300)
						
						set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 5.0, 5.0)
						show_hudmessage(id, "You've got 'Super Marker'!")
					} else {
						if(Choose)
						{
							give_item(id, "weapon_scout")
							cs_set_user_bpammo(id, CSW_SCOUT, 20)
						} else {
							give_item(id, "weapon_m3")
							cs_set_user_bpammo(id, CSW_M3, 16)
						}
					}
				}
				
				g_HasKill[id] = 0
			}
		}	
	}
	
	if(g_Vendetta_Bonus[id] == 1)
	{
		give_item(id, "weapon_p90")
		cs_set_user_bpammo(id, CSW_P90, 300)
		
		set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 5.0, 5.0)
		show_hudmessage(id, "Vendetta! You got a 'Super Marker'!")
	}

	if(g_Vendetta_Bonus[id] == -1)
	{
		g_Vendetta_Bonus[id] = 0
		
		set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 5.0, 5.0)
		show_hudmessage(id, "Haha! You got punk'd and didn't get a main gun this round!!!!")
	}

	if (get_pcvar_num(g_Cvar_PBNade))
		give_item(id, "weapon_hegrenade");
	if (get_pcvar_num(g_Cvar_PBSNade))
		give_item(id, "weapon_smokegrenade");
	if (get_pcvar_num(g_PBSuperLauncher) && id == g_Got_SuperLauncher)
	{
		static KillerName[32]; get_user_name(id, KillerName, 31)
		new teamname[3][] = {"None", "Red Team", "Blue Team"}
		
		set_hudmessage(255, 255, 255, -1.0, 0.7, 0, 5.0, 5.0);
		show_hudmessage(0, "%s: %s got a 'Super Launcher', BEWARE!", teamname[get_user_team(id)], KillerName);
		
		give_item(id, "weapon_flashbang");
		
		if (get_pcvar_num(g_Cvar_Deathmatch))
			Select_New_SuperLauncher()
	}
	
	remove_task(id)
}

public Clear_MoneyHud(id)
{
	id -= 300
	if(!is_user_alive(id))
		return
		
	if(get_pcvar_num(g_Cvar_Money))
	{
		message_begin(MSG_ONE_UNRELIABLE, 94, _, id ); //HideWeapon
		write_byte(1<<5)
		message_end()
	}
}
	
public Event_Death()
{
	static Killer, Victim
	
	Killer = read_data(1)
	Victim = read_data(2)
	
	g_HasKill[Killer] += 1
	if(get_pcvar_num(g_Cvar_Deathmatch))
	{
		new id = Victim + 200
		set_task(3.0, "Respawn_Player", id)
		set_task(3.2, "Respawn_Player", id)
	}

	if(get_pcvar_num(g_Cvar_Vendetta) && Killer != Victim)
	{
		g_Vendetta_Bonus[Victim] = 0
	
		if(g_KilledBy[Victim] == Killer) g_KillingTime[Victim] += 1;
		else {
			g_KilledBy[Victim] = Killer
			g_KillingTime[Victim] = 1
		}
	
		if (g_KillingTime[Victim] < get_pcvar_num(g_Cvar_Vendetta_Kill)) g_InVendetta[Victim] = 0;
		else g_InVendetta[Victim] = 1;

		if (g_KilledBy[Killer] == Victim)
		{
			if (g_InVendetta[Killer])
			{
				g_InVendetta[Killer] = 0
				g_Vendetta_Bonus[Killer] = 1
				g_Vendetta_Bonus[Victim] = -1
				g_KillingTime[Killer] = 0
				g_KilledBy[Killer] = -1
				
				static KillerName[32]; 
				get_user_name(Killer, KillerName, 31)
				
				set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 5.0, 5.0)
				show_hudmessage(0, "[%s] has got Vendetta!", KillerName)
			} else g_KillingTime[Killer] = 0
		}
	}
}

public Event_Money(id)
{
	if(get_pcvar_num(g_Cvar_Money))
	{
		if (get_pdata_int(id, 115, 5) > 0)
			set_pdata_int(id, 115, 0, 5)
	}
}

public CMD_Respawn(id)
{
	if (get_pcvar_num(g_Cvar_Deathmatch))
	{
		if(is_user_alive(id))
			return
		if(get_user_team(id) == 1 || get_user_team(id) == 2)
		{
			set_task(1.5, "Respawn_Player", id + 200)
			set_task(1.7, "Respawn_Player", id + 200)
		}
	}
}

public Player_GodModeOff(id) set_pev(id - 100, pev_takedamage, DAMAGE_AIM)
public Respawn_Player(id)
{
	id -= 200
	
	if(!is_user_connected(id))
		return
	if (get_user_team(id ) == 1 || get_user_team(id) == 2)
		dllfunc(DLLFunc_Spawn, id)
}
public fw_SetModel(ent, model[])
{
	if(!get_pcvar_num(g_Cvar_Deathmatch) || pev_valid(ent))
		return FMRES_IGNORED
	
	new id = pev(ent, pev_owner);
	if((!is_user_alive(id) || task_exists(id+200)) && equali(model, "models/w_", 9) && !equali(model, "models/w_weaponbox.mdl"))
	{
		static classname[16]; pev(ent, pev_classname, classname, 15);
		if (equal(classname, "weaponbox") && !equal(model, "models/w_backpack.mdl"))
		{
			for (new i = g_MaxPlayers + 1; i < engfunc(EngFunc_NumberOfEntities) + 5; i++)
			{
				if(pev_valid(i))
				{
					if (ent == pev(i, pev_owner))
					{
						dllfunc(DLLFunc_Think, ent)
						return FMRES_IGNORED
					}
				}
			}
		}
	}

	return FMRES_IGNORED;
}

public fw_ClientUserInfoChanged(id, infobuffer)
{
	if(g_Has_CustomModel[id])
	{
		if(g_Team[id] != get_user_team(id))
			g_Has_CustomModel[id] = 0
		
		static CurrentModel[32]
		engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", CurrentModel, 31)
		
		if (!equal(CurrentModel, "paintballer") || g_Has_CustomModel[id] == 0)
		{
			set_task(0.1 + g_ModelCounter, "Task_SetModel", id+MODELSET_TASK)
			g_ModelCounter += TASK_DELAY
		}
		
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{   
	if (g_Has_CustomModel[id] && equal(key, "model"))
		return FMRES_SUPERCEDE
        
	return FMRES_IGNORED
}	

public CMD_EnableMenu(id)
{
	ShowMenu[id] = 1
	client_print(id, print_chat, "[%s] Your equip menu has been re-enabled.", GAMENAME)
	
	return PLUGIN_HANDLED
}

public LaunchMenu(id)
 {
	new menu = menu_create("\rChoose your main Paintball Gun:", "MenuHandle_SelectGun")
	
	menu_additem(menu, "\wMarker", "0", 0)
	menu_additem(menu, "\wShotgun", "1", 0)
	menu_additem(menu, "\wLauncher", "2", 0)
	menu_additem(menu, "\wSniper^n", "3", 0)
	menu_additem(menu, "\ySelect previous gun", "4", 0, -1)
	menu_additem(menu, "\yPrevious + Don't show menu again\w", "5", 0, -1)

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}

public MenuHandle_SelectGun(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)

	new key = str_to_num(data);
	if(key==4) key = MenuState[id]

	if(key == 5)
	{
		ShowMenu[id] = 0;
		client_print(id, print_chat, "[%s] Your equip menu has been disabled. Say '/pbgun' to re-enable it.", GAMENAME)	
		key = MenuState[id]
	}
	
	MenuState[id] = key
	give_menu_weapon(id, MenuState[id])
		
	menu_destroy(menu)
	return PLUGIN_HANDLED
 }

public give_menu_weapon(id,key)
{
	switch (key)
	{
		case 0: give_item(id, "weapon_mp5navy")
		case 1: give_item(id, "weapon_xm1014")
		case 2: give_item(id, "weapon_m3")
		case 3: give_item(id, "weapon_scout")
		default: give_item(id, "weapon_mp5navy")
	}
	
	cs_set_user_bpammo(id, CSW_MP5NAVY, 150)
	cs_set_user_bpammo(id, CSW_SCOUT, 20)
	cs_set_user_bpammo(id, CSW_M3, 16)
	cs_set_user_bpammo(id, CSW_XM1014, 80)
}

public Task_SetModel(id)
{
	remove_task(id)
    
	id -= MODELSET_TASK
	set_user_model(id, "paintballer")
}

public set_user_model(player, const modelname[])
{
	engfunc(EngFunc_SetClientKeyValue, player, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", modelname)
	g_Team[player] = get_user_team(player)

	if (g_Team[player] == 1) g_PlayerSkin[player] = 0
	else g_PlayerSkin[player] = 4

	set_pev(player, pev_skin, g_PlayerSkin[player]);
	g_Has_CustomModel[player] = 1	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/

/**************************************************************************************************************************************\
|* ||||||              ||||  ||||            || ||                  ****        *                  *                                  *|
|* ||                  || |||| ||            || ||     *            *  *        *                  *                                  *|
|* ||||||              ||  ||  ||            || ||     *       **   ****        *                  *                                  *|
|* ||    ||  || |||||| ||      || |||||| |||||| ||     *       **   * *    ***  *  ***  ***  ***   *** ***                            *|
|* ||    ||  || ||  || ||      || ||  || ||  ||        *** * *      *  *   * *  *  * *  * *  * *   * * * *                            *|
|* ||    |||||| ||  || ||      || |||||| |||||| ||     * *  *  **   *   *  ***  *  * *  **** ****  *** ****                           *|
|* ///////////////////////////////////////////////     ***  *  **   ~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~                           *|
|* Created By:                                                                                                                        *|
|* ~`~`~`~`~`~                                                                                                                        *|
|*    Rolnaaba                                                                                                                        *|                                                                       *|
|*                                                                                                                                    *|
|* Mod Description:                                                                                                                   *|
|* ~`~`~`~`~`~`~`~`                                                                                                                   *|
|*    Creates an environment to emulate extreme randomness, and stupidity.                                                            *|
|* Every minute or so (controlled by cvar, 60sec = default) a                                                                         *|
|* "Random Event" will occur at which point gameplay will change keeping                                                              *|
|* players on their toes and having "fun".                                                                                            *|
|*                                                                                                                                    *|
|* Cvars:                                                                                                                             *|
|* ~`~`~`                                                                                                                             *|
|*    sv_fmod		-- turns on/off the mod [default=1]                                                                           *|
|*    fmod_health	-- amount of extra health recieved by a player on a "Death Streak" [default=20]                               *|
|*    fmod_money	-- amount of money given to a player when reaching, and ever kill during, a "Killing Streak" [default=100]    *|
|*    fmod_dstreak	-- deaths in a row before you are considered on a "Death Streak" [default=4]                                  *|
|*    fmod_kstreak	-- killes in a row before you are considered on a "Killing Streak" [default=5]                                *|
|*    fmod_debug	-- Toggles on/off Debug Mode...DEBUG MODE WILL CAUSE LAGG!! [defualt=0]                                       *|
|*    fmod_eventinterval-- Time between each random event [default=25.0sec, must be a decimal!]                                       *|
|*                                                                                                                                    *|
|* Client Comands (in console or chat):                                                                                               *|
|* ~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`                                                                                               *|
|*    /fun		-- Rolls the "fun dice".                                                                                      *|
|*    /fbuy		-- Opens fun buy menu.                                                                                        *|
|*    /next_event	-- Displays time till next random event.                                                                      *|
\**************************************************************************************************************************************/
#pragma dynamic 32768

#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <cstrike>

//so i dont have to scroll down to plugin_init() to change version number, I am lazy...
#define VERSION "4.0"

//PDATA DEFINES
#define PKILLS 1
#define PDEATHS 2
#define PSPEEDING 3
#define PLAST 4

//TASK ID DEFINES
#define TASK_GMODE 200
#define TASK_INVIS 300
#define TASK_MODE 400
#define TASK_NOCLIP 500
#define TASK_GRAV 600
#define TASK_LIGHTING 700
#define TASK_ROLL_COOL 800
#define TASK_LOOP 900
#define TASK_LIGHTING_END 1000
#define TASK_MODELS 1100
#define TASK_SPEED 1200

#define ABILITY_LAST 10.0

//CVAR POINTER DEFINES
#define CMOD 1
#define CHEALTH 2
#define CMONEY 3
#define CDSTREAK 4
#define CKSTREAK 5
#define CDEBUG 6
#define CLOOP 7
#define CLAST 8

#define MAXPLAYERS 33
#define BuyMenuKeys (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)

new pdata[MAXPLAYERS][PLAST]; //stored data about a player
new pcvar[CLAST]; //pointers for cvars
new bool:on_deathstreak[MAXPLAYERS]; //is user on death streak?
new cached_gametime; //used to store gametime each time a ranevent is chosen...so i know about how long until the next event
new curr_gametime; //the gametime at the moment someone uses the /next_event comand
new Mode; //1=Knife mode, 2=Scout mode, 3=Awp mode, 4=Nade mode
new seconds[MAXPLAYERS];
new g_lastPosition[MAXPLAYERS][3];

// Ammo Varriable From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
new g_MaxBPAmmo[31] = {
	0,
	52,  //CSW_P228
	0,
	90,  //CSW_SCOUT
	1,   //CSW_HEGRENADE
	32,  //CSW_XM1014
	1,   //CSW_C4
	100, //CSW_MAC10
	90,  //CSW_AUG
	1,   //CSW_SMOKEGRENADE
	120, //CSW_ELITE
	100, //CSW_FIVESEVEN
	100, //CSW_UMP45
	90,  //CSW_SG550
	90,  //CSW_GALIL
	90,  //CSW_FAMAS
	100, //CSW_USP
	120, //CSW_GLOCK18
	30,  //CSW_AWP
	120, //CSW_MP5NAVY
	200, //CSW_M249
	21,  //CSW_M3
	90,  //CSW_M4A1
	120, //CSW_TMP
	90,  //CSW_G3SG1
	2,   //CSW_FLASHBANG
	35,  //CSW_DEAGLE
	90,  //CSW_SG552
	90,  //CSW_AK47
	0,   //CSW_KNIFE
	100  //CSW_P90
}

// Ammo Varriable From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
new g_ClipSize[31] = {
	0,
	13,  //CSW_P228
	0,
	10,  //CSW_SCOUT
	0,   //CSW_HEGRENADE
	7,   //CSW_XM1014
	0,   //CSW_C4
	30,  //CSW_MAC10
	30,  //CSW_AUG
	0,   //CSW_SMOKEGRENADE
	30,  //CSW_ELITE
	20,  //CSW_FIVESEVEN
	25,  //CSW_UMP45
	30,  //CSW_SG550
	35,  //CSW_GALIL
	25,  //CSW_FAMAS
	12,  //CSW_USP
	20,  //CSW_GLOCK18
	10,  //CSW_AWP
	30,  //CSW_MP5NAVY
	100, //CSW_M249
	8,   //CSW_M3
	30,  //CSW_M4A1
	30,  //CSW_TMP
	20,  //CSW_G3SG1
	0,   //CSW_FLASHBANG
	7,   //CSW_DEAGLE
	30,  //CSW_SG552
	30,  //CSW_AK47
	0,   //CSW_KNIFE
	50   //CSW_P90
}

// Ammo Varriable From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
new g_AmmoType[31] = {
	0,
	9,  //CSW_P228
	0,
	2,  //CSW_SCOUT
	12, //CSW_HEGRENADE
	5,  //CSW_XM1014
	14, //CSW_C4
	6,  //CSW_MAC10
	4,  //CSW_AUG
	13, //CSW_SMOKEGRENADE
	10, //CSW_ELITE
	7,  //CSW_FIVESEVEN
	6,  //CSW_UMP45
	4,  //CSW_SG550
	4,  //CSW_GALIL
	4,  //CSW_FAMAS
	6,  //CSW_USP
	10, //CSW_GLOCK18
	1,  //CSW_AWP
	10, //CSW_MP5NAVY
	3,  //CSW_M249
	5,  //CSW_M3
	4,  //CSW_M4A1
	10, //CSW_TMP
	2,  //CSW_G3SG1
	11, //CSW_FLASHBANG
	8,  //CSW_DEAGLE
	4,  //CSW_SG552
	2,  //CSW_AK47
	0,  //CSW_KNIFE
	7   //CSW_P90
};

// Ammo Varriable From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
new g_AmmoName[15][] = {
	"",
	"ammo_338magnum",
	"ammo_762nato",
	"ammo_556natobox",
	"ammo_556nato",
	"ammo_buckshot",
	"ammo_45acp",
	"ammo_57mm",
	"ammo_50ae",
	"ammo_357sig",
	"ammo_9mm",
	"",
	"",
	"",
	""
};

new g_WeaponNames[25][] = {
	"weapon_ak47",
	"weapon_aug",
	"weapon_awp",
	"weapon_deagle",
	"weapon_elite",
	"weapon_famas",
	"weapon_fiveseven",
	"weapon_g3sg1",
	"weapon_gali",
	"weapon_galil",
	"weapon_glock18",
	"weapon_m249",
	"weapon_m3",
	"weapon_m4a1",
	"weapon_mac10",
	"weapon_mp5navy",
	"weapon_p228",
	"weapon_p90",
	"weapon_scout",
	"weapon_sg550",
	"weapon_sg552",
	"weapon_tmp",
	"weapon_ump45",
	"weapon_usp",
	"weapon_xm1014"
}

new Float:tmp;
new bool:lightning_on = false;
new bool:can_roll[MAXPLAYERS];
new ammount;
new Float:curr_pcvar;

public plugin_init() {
	register_plugin("Fun Mod", VERSION, "Rolnaaba");
	
	register_menucmd(register_menuid("Buy Menu"), BuyMenuKeys, "PressedBuyMenu");
	pcvar[CMOD] = register_cvar("sv_fmod", "1"); //mod on or off?
	pcvar[CHEALTH] = register_cvar("fmod_health", "20"); //amount more health to start a player with for being on a "Death Streak"
	pcvar[CMONEY] = register_cvar("fmod_money", "100"); //amount of money given to a player for reaching, and every kill during, a "Killing Streak"
	pcvar[CDSTREAK] = register_cvar("fmod_dstreak", "4"); //deaths in a row before it is considered a "Death Streak"
	pcvar[CKSTREAK] = register_cvar("fmod_kstreak", "5"); //kills in a row before it is considered a "Killing Streak"
	pcvar[CDEBUG] = register_cvar("fmod_debug", "0"); //debug mode on or off? WILL CAUSE LAG!
	pcvar[CLOOP] = register_cvar("fmod_eventinterval", "60.0"); //time between each random event	

	register_clcmd("/fun", "Say_fun");
	register_clcmd("/fbuy", "Say_buy");
	register_clcmd("/next_event", "Say_event");
	register_clcmd("say /fun", "Say_fun");
	register_clcmd("say /fbuy", "Say_buy");
	register_clcmd("say /next_event", "Say_event");
	register_clcmd("say_team /fun", "Say_fun");
	register_clcmd("say_team /fbuy", "Say_buy");
	register_clcmd("say_team /next_event", "Say_event");
	
	register_logevent("Event_NewRound", 2, "1=Round_Start");
	register_event("DeathMsg", "Event_Death", "a");
	register_event("CurWeapon", "Event_CurWeapon", "be");
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Plugin Starting", tmp);
	}
	for(new i = 0; i < MAXPLAYERS; i++) {
		can_roll[i] = true;
	}
	
	set_task(get_pcvar_float(pcvar[CLOOP]), "fmod_random_loop", TASK_LOOP, "", 0, "b");
	curr_pcvar = get_pcvar_float(pcvar[CLOOP]);	
}

public Event_CurWeapon(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, CurrWeapon Event Called...info: id=%i Mode=%i", tmp, id, Mode);
	}
	if(!get_pcvar_num(pcvar[CMOD])) return PLUGIN_CONTINUE;
	switch(Mode) {
		case 0: return PLUGIN_CONTINUE;
		case 1: {
			new clip, ammo, wpnid = get_user_weapon(id, clip, ammo);
			if(wpnid != CSW_KNIFE) {
				strip_user_weapons(id);
				give_item(id, "weapon_knife");
			}
		}
		case 2: {
			new clip, ammo, wpnid = get_user_weapon(id, clip, ammo);
			if(wpnid != CSW_SCOUT) {
				strip_user_weapons(id);
				give_item(id, "weapon_scout");
			}
		}
		case 3: {
			new clip, ammo, wpnid = get_user_weapon(id, clip, ammo);
			if(wpnid != CSW_AWP) {
				strip_user_weapons(id);
				give_item(id, "weapon_awp");
			}
		}
		case 4: {
			new clip, ammo, wpnid = get_user_weapon(id, clip, ammo);
			if(wpnid != CSW_HEGRENADE) {
				strip_user_weapons(id);
				give_item(id, "weapon_hegrenade");
			}
		}
	}
	if(pdata[id][PSPEEDING] == 1) {
		set_user_maxspeed(id, get_user_maxspeed(id)+200.0);
	}
	set_task(15.0, "rolling_cool", TASK_ROLL_COOL+id);
	return PLUGIN_CONTINUE;	
}

public rolling_cool(i) {
	new id = i-TASK_ROLL_COOL;
	can_roll[id] = true;
}

public Event_Death() {
	if(!get_pcvar_num(pcvar[CMOD])) return PLUGIN_CONTINUE;
	
	new killer = read_data(1);
	new victim = read_data(2);
	new headshot = read_data(3);
	
	can_roll[victim] = true;
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, DeathMsg Event Called...info: killer=%i victim=%i headshot=%i", tmp, killer, victim, headshot);
	}
	
	pdata[victim][PSPEEDING] = 0;
	
	pdata[victim][PKILLS] = 0;
	pdata[killer][PKILLS]++;
	
	
	pdata[killer][PDEATHS] = 0;
	pdata[victim][PDEATHS]++;
	new kname[32];
	get_user_name(killer, kname, 31);
	
	new vname[32];
	get_user_name(victim, vname, 31);
	
	if(pdata[killer][PKILLS] >= get_pcvar_num(pcvar[CKSTREAK])) {
		client_print(0, print_chat, "%s is on a killing streak with %i kills!", kname, pdata[killer][PKILLS]);
		cs_set_user_money(killer, cs_get_user_money(killer)+get_pcvar_num(pcvar[CMONEY]), 1);
	}
	if(pdata[victim][PDEATHS] >= get_pcvar_num(pcvar[CDSTREAK])) {
		client_print(0, print_chat, "%s is on a death streak with %i deaths!", vname, pdata[killer][PDEATHS]);
		on_deathstreak[victim] = true;
	} else {
		on_deathstreak[victim] = false;
	}
	if(headshot) {
		set_hudmessage(255, 0, 0, -1.0, 0.4);
		show_hudmessage(0, "HEADSHOT! %s just pwned %s!", kname, vname);
	}
	if(task_exists(victim+TASK_GMODE)) remove_task(victim+TASK_GMODE);
	if(task_exists(victim+TASK_INVIS)) remove_task(victim+TASK_INVIS);
	if(task_exists(victim+TASK_MODE)) remove_task(victim+TASK_MODE);
	if(task_exists(victim+TASK_NOCLIP)) remove_task(victim+TASK_NOCLIP);
	if(task_exists(victim+TASK_GRAV)) remove_task(victim+TASK_GRAV);
	if(task_exists(victim+TASK_ROLL_COOL)) remove_task(victim+TASK_ROLL_COOL);
	/*
	remove_task(victim+TASK_GMODE);
	remove_task(victim+TASK_INVIS);
	remove_task(victim+TASK_MODE);
	remove_task(victim+TASK_NOCLIP);
	remove_task(victim+TASK_GRAV);
	*/
	
	seconds[victim] = 0
	set_user_godmode(victim);
	set_user_noclip(victim);
	set_user_rendering(victim);
	return PLUGIN_CONTINUE;
}

public Event_NewRound() {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, NewRound Event Called...info: n/a", tmp);
	}
	if(!get_pcvar_num(pcvar[CMOD])) return PLUGIN_CONTINUE;
	
	cached_gametime = get_systime();
	
	for(new i = 0; i < MAXPLAYERS; i++) {
		if(task_exists(i+TASK_GMODE)) remove_task(i+TASK_GMODE);
		if(task_exists(i+TASK_INVIS)) remove_task(i+TASK_INVIS);
		if(task_exists(i+TASK_MODE)) remove_task(i+TASK_MODE);
		if(task_exists(i+TASK_NOCLIP)) remove_task(i+TASK_NOCLIP);
		if(task_exists(i+TASK_GRAV)) remove_task(i+TASK_GRAV);
		if(task_exists(i+TASK_ROLL_COOL)) remove_task(i+TASK_ROLL_COOL);
		if(task_exists(i+TASK_SPEED)) remove_task(i+TASK_SPEED);
		
		can_roll[i] = true;
		
		pdata[i][PSPEEDING] = 0;
	}
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_connected(i) && cs_get_user_team(i) != CS_TEAM_SPECTATOR && cs_get_user_team(i) != CS_TEAM_UNASSIGNED) {
			set_user_godmode(i);
			set_user_noclip(i);
			set_user_rendering(i);
			cs_reset_user_model(i);
		}
		
		if(is_user_connected(i) && is_user_alive(i)) {
			if(on_deathstreak[i]) {
				set_user_health(i, 100+get_pcvar_num(pcvar[CHEALTH]));
				client_print(i, print_chat, "Heres some health...good luck!");
			}
		}
	}
	if(task_exists(TASK_MODELS)) remove_task(TASK_MODELS);
	if(task_exists(TASK_LIGHTING_END)) remove_task(TASK_LIGHTING_END);
	
	if(lightning_on) remove_darkness();
	
	set_cvar_num("mp_friendlyfire", 0);
	
	client_print(0, print_chat, "/fun - Rolls the Fun Dice");
	client_print(0, print_chat, "/fbuy - Opens Buy Menu");
	client_print(0, print_chat, "/next_event - Shows time until next random event");
	
	
	Mode = 0;
	return PLUGIN_CONTINUE;
}

public Say_fun(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f,SayFun Function called...info: id=%i", tmp, id);
	}
	if(!get_pcvar_num(pcvar[CMOD])) {
		client_print(id, print_chat, "Fun Mod disabled by admin...sorry");
		return PLUGIN_CONTINUE;
	}
	if(!is_user_connected(id) || id < 0 || id > 32) return PLUGIN_CONTINUE;
	if(!is_user_alive(id)) {
		client_print(id, print_chat, "[FunDice] You cant roll when your dead!");
		return PLUGIN_HANDLED;
	}	
	if(!can_roll[id]) {
		client_print(id, print_chat, "[FunDice] You just rolled! Wait a little bit!");
		return PLUGIN_CONTINUE;
	}
	//rolling sequence!!
	new num1 = random(10);
	new num2 = random(10);
	new total = num1+num2;
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Rolling Sequence Started...info: num1=%i num2=%i total=%i", tmp, num1, num2, total);
	}
	
	client_print(id, print_chat, "[%i][%i] You rolled %i", num1, num2, total);
	
	if(total == 0 || total <= 1) {
		set_user_gravity(id, 20.0);
		client_print(id, print_chat, "[FunDice] You now have HIGH gravity!");		
	} else if(total >= 2 && total <= 4) {
		user_slap(id, get_user_health(id)-1);
		client_print(id, print_chat, "[FunDice] Slapped to 1HP...sad...");
	} else if(total <= 6) {
		cs_set_user_money(id, 0, 1);
		client_print(id, print_chat, "[FunDice] Lost all your money you hobbo!");
	} else if(total >= 5 && total <= 8) {
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(~0);
		write_short(~0);
		write_short(1<<12);
 		write_byte(255);
 		write_byte(255);
 		write_byte(255);
 		write_byte(255);
 		message_end();
		
		client_print(id, print_chat, "[FunDice] Your rolling stinks, so i will blind you!!");
	} else if(total == 9 || total == 10) {
		
		give_item(id, "weapon_hegrenade");
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_smokegrenade");
		
		client_print(id, print_chat, "[FunDice] Nice roll...here have some nades :)");
	} else if(total == 11 || total == 12) {
		fm_set_user_longjump(id, true, true);
		
		client_print(id, print_chat, "[FunDice] Press crouch then jump to do a long jump!");
	} else if(total == 13 || total == 14) {		
		pdata[id][PSPEEDING] = 1;
		
		set_user_maxspeed(id, get_user_maxspeed(id)+200.0);
		
		new name[32];
		get_user_name(id, name, 31);
		
		client_print(0, print_chat, "[FunDice] %s is now a speed demon!!", name);
	} else if(total == 15 || total == 16) {
		new name[32];
		get_user_name(id, name, 31);
		
		if(is_user_connected(id)) {
			set_user_godmode(id, 1);
			set_task(ABILITY_LAST, "remove_godmode", id+TASK_GMODE);
			client_print(id, print_chat, "[FunDice] Godmode for 15 seconds GO GO GO!!");
			set_hudmessage(255, 0, 0, -1.0, 0.4);
			show_hudmessage(0, "[FunDice] Warning: %s has godmode...RUN!!", name);
		}
	} else if(total == 17 ||total == 18) {
		new name[32];
		get_user_name(id, name, 31);
		
		set_user_noclip(id, 1);
		set_task(ABILITY_LAST, "remove_noclip", id+TASK_NOCLIP);
		client_print(id, print_chat, "[FunDice] Noclip for 15 seconds GO GO GO!!");
		set_hudmessage(255, 0, 0, -1.0, 0.4);
		show_hudmessage(0, "[FunDice] Warning: %s has noclip...RUN!!", name);
	}
	can_roll[id] = false;
	return PLUGIN_HANDLED;
}

public Say_event(id) {
	if(!get_pcvar_num(pcvar[CMOD])) {
		client_print(id, print_chat, "Fun Mod disabled by admin...sorry");
		return PLUGIN_CONTINUE;
	}
	curr_gametime =  get_systime();
	//new Float:diff = cached_gametime-curr_gametime;
	new diff1 = curr_gametime-cached_gametime;
	new diff = floatround(curr_pcvar)-diff1;
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, SayEvent Function Called...info: diff=%i", tmp, diff);
	}
	
	client_print(0, print_chat, "There are %i seconds until the next random event!", diff);

	return PLUGIN_HANDLED;
}

public Say_buy(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, SayBuy Function Called...info: id=%i", tmp, id);
	}
	if(!get_pcvar_num(pcvar[CMOD])) {
		client_print(id, print_chat, "Fun Mod disabled by admin...sorry");
		return PLUGIN_CONTINUE;
	}
	show_menu(id, BuyMenuKeys, "\rBuy Menu^n\w^n1. Buy Health - 10000^n2. Buy Armor - 8000^n3. Buy Ammo - 5000^n4. Buy Gravity - 5000^n5. Buy Random Weapon - 15000^n^n0. Exit - FREE!!^n", -1, "");
	return PLUGIN_HANDLED;
}

public PressedBuyMenu(id, key) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Buy Menu Handling Function Called...info: id=%i key=%i", tmp, id, key);
	}
	switch (key) {
		case 0: Buy_Health(id);
		case 1: Buy_Armor(id);
		case 2: Buy_Ammo(id);
		case 3: Buy_Gravity(id);
		case 4: Buy_Rweapon(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public Buy_Health(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, BuyHealth function called...info: id=%i", tmp, id);
	}
	new maxhealth;
	if(cs_get_user_money(id) < 10000) {
		client_print(id, print_chat, "You cant Afford That!");
		return PLUGIN_CONTINUE;
	} else {
		cs_set_user_money(id, cs_get_user_money(id)-10000, 1);
		if(on_deathstreak[id]) {
			maxhealth = 100+get_pcvar_num(pcvar[CHEALTH]);
		} else { maxhealth = 100; }
		
		if(get_user_health(id)+30 >= maxhealth) {
			set_user_health(id, maxhealth);
		} else { set_user_health(id, get_user_health(id)+30); }
	}
	return PLUGIN_CONTINUE;
}

public Buy_Armor(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, BuyArmor function called...info: id=%i", tmp, id);
	}
	if(cs_get_user_money(id) < 8000) {
		client_print(id, print_chat, "You cant Afford That!");
		return PLUGIN_CONTINUE;
	} else {
		cs_set_user_money(id, cs_get_user_money(id)-8000, 1);
		cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	}
	return PLUGIN_CONTINUE;
}

public Buy_Ammo(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, BuyAmmo function called...info: id=%i", tmp, id);
	}
	if(cs_get_user_money(id) < 5000) {
		client_print(id, print_chat, "You cant Afford That!");
		return PLUGIN_CONTINUE;
	} else {
		cs_set_user_money(id, cs_get_user_money(id)-5000, 1);
		// Ammo Giving From: FreeAmmo v1.4 by: asstolavista
		// http://forums.alliedmods.net/showthread.php?t=50704
		new weap_ids[32], num_weaps;
		get_user_weapons(id, weap_ids, num_weaps);
		
		for (new i = 0; i < num_weaps; i++) {
			new weap_id = weap_ids[i]
			if (fill_weapon(id, weap_id)) {
				fill_bpammo(id, weap_id);
				show_given_bpammo(id, weap_id, ammount);
			}
		}
		client_print(id, print_chat, "All your weapons now have full ammo!");
	}
	return PLUGIN_HANDLED;
}

// Ammo Giving From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
public bool:fill_bpammo(id, weap_id) {
	new ammo = g_MaxBPAmmo[weap_id]
	ammount = ammo-cs_get_user_bpammo(id, weap_id)
	if (weapon_has_ammo(weap_id)) {
		cs_set_user_bpammo(id, weap_id, ammo)
		return true
	}
	return false
}
// Ammo Giving From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
public bool:fill_weapon(id, weap_id) {
	new clip_size = g_ClipSize[weap_id]
	if (clip_size != 0) {
		new weap_name[41]
		get_weaponname(weap_id, weap_name, 40)
		new wpn = fm_find_ent_by_owner(-1, weap_name, id)
		if (wpn != 0) {
			cs_set_weapon_ammo(wpn, clip_size)
			return true
		}
	}
	return false
}
// Ammo Giving From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
public bool:weapon_has_ammo(weap_id){
	return g_AmmoName[g_AmmoType[weap_id]][0] != 0
}
// Ammo Giving From: FreeAmmo v1.4 by: asstolavista
// http://forums.alliedmods.net/showthread.php?t=50704
public show_given_bpammo(id, weap_id, ammount) {
	if (ammount <= 0) return;
	message_begin(MSG_ONE, get_user_msgid("AmmoPickup"), {0,0,0}, id)
	write_byte(g_AmmoType[weap_id])
	write_byte(ammount)
	message_end()
}

public Buy_Gravity(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, BuyGravity function called...info: id=%i", tmp, id);
	}
	if(cs_get_user_money(id) < 5000) {
		client_print(id, print_chat, "You cant Afford That!");
		return PLUGIN_CONTINUE;
	} else {
		cs_set_user_money(id, cs_get_user_money(id)-5000, 1);
		set_user_gravity(id, get_user_gravity(id)-0.5);
	}
	return PLUGIN_HANDLED;
}

public Buy_Rweapon(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, BuyRandomWeapon function called...info: id=%i", tmp, id);
	}
	if(cs_get_user_money(id) < 15000) {
		client_print(id, print_chat, "You cant Afford That!");
		return PLUGIN_CONTINUE;
	} else {
		cs_set_user_money(id, cs_get_user_money(id)-15000, 1);
		
		give_item(id, g_WeaponNames[random(25)]);
	}
	return PLUGIN_HANDLED;
}

public remove_speed(i) {
	new id;
	id = (i > TASK_SPEED) ? i-TASK_SPEED : i;
	
	pdata[id][PSPEEDING] = 0;
}

public remove_godmode(i) {
	new id;
	id = (i > TASK_GMODE) ? i-TASK_SPEED : i;
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Remove Godmode function called...info: i=%i id=%i", tmp, i, id);
	}
	seconds[id] = 6;
	_remove_godmode(id);
}

public remove_noclip(i) {
	new id;
	id = (i > TASK_NOCLIP) ? i-TASK_SPEED : i;
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Remove NoClip function called...info: i=%i id=%i", tmp, i, id);
	}
	seconds[id] = 6;
	_remove_noclip(id);
}

public reset_models() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			cs_reset_user_model(i);
		}
	}
	set_cvar_num("mp_friendlyfire", 1);
}

public remove_darkness() {
	remove_task(TASK_LIGHTING);
	lightning_on = false;
	engfunc(EngFunc_LightStyle, 0, "#OFF");
}

//credits to zombie swarm for lighting effects
public lighting_effects() {
	if(lightning_on) {
		engfunc(EngFunc_LightStyle, 0, "a");
		set_task(random_float(2.0,8.0),"thunder_flash",TASK_LIGHTING);
	}
}

public thunder_flash() {
	if(lightning_on) {
		engfunc(EngFunc_LightStyle, 0, "s");
		client_cmd(0,"speak ambience/thunder_clap.wav");
	
		set_task(1.0,"lighting_effects",TASK_LIGHTING);
	}
}

public remove_invis(i) {
	new id = i-TASK_INVIS;
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Remove Invis function called...info: i=%i id=%i", tmp, i, id);
	}
	seconds[id] = 6;
	_remove_invis(id);
}

public remove_gravity(i) {
	new id = i-TASK_GRAV;
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Remove Gravity function called...info: i=%i id=%i", tmp, i, id);
	}
	set_user_gravity(id, get_user_gravity(id)+10.0);
}

public _remove_godmode(id) {
	seconds[id]--
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, RemoveGodmode Support function called...info: id=%i seconds[id]=%i", tmp, id, seconds[id]);
	}
	client_print(id, print_chat, "%i seconds until your godmode runs out!", seconds[id]);
	if(seconds[id] > 0) {
		set_task(1.0,"_remove_godmode", id);
	} else {
		set_user_godmode(id);
	}
}

public _remove_noclip(id) {
	seconds[id]--
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, RemoveNoClip Support function called...info: id=%i seconds[id]=%i", tmp, id, seconds[id]);
	}
	client_print(id, print_chat, "%i seconds until your noclip runs out!", seconds[id]);
	if(seconds[id] > 0) {
		set_task(1.0,"_remove_noclip", id);
	} else {
		set_user_noclip(id);
		wall_check(id);
	}
}

public _remove_invis(id) {
	seconds[id]--
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, RemoveInvis Support function called...info: id=%i seconds[id]=%i", tmp, id, seconds[id]);
	}
	client_print(id, print_chat, "%i seconds until your invisibility runs out!", seconds[id]);
	if(seconds[id] > 0) {
		set_task(1.0,"_remove_invis", id);
	} else {
		set_user_rendering(id);
	}
}

public mode_normal(i) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Mode Normal function called...info: i=%i", tmp, i);
	}
	Mode = 0;
	
	return;
}

public wall_check(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, WallCheck function called...info: id=%i", tmp, id);
	}
	if(!is_user_alive(id)) return;

	get_user_origin(id, g_lastPosition[id], 0);

	new Float:velocity[3];
	pev(id, pev_velocity, velocity);

	if(velocity[0]==0.0 && velocity[1]==0.0){
		velocity[0] += 20.0;
		velocity[2] += 100.0;
		set_pev(id, pev_velocity, velocity);
	}

	set_task(0.4,"_wall_check",id);
}

public _wall_check(id) {
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, WallCheck Support function called: id=%i", tmp, id);
	}
	new origin[3];

	if(!is_user_alive(id)) return;

	get_user_origin(id, origin);
	
	if(g_lastPosition[id][0] == origin[0] && g_lastPosition[id][1] == origin[1] && g_lastPosition[id][2] == origin[2] && is_user_alive(id)) {
		user_kill(id);
		client_print(id, print_chat, "You were slayed for getting stuck...");
	}
}

public fmod_random_loop() {
	if(!get_pcvar_num(pcvar[CMOD])) return PLUGIN_CONTINUE;
	
	new num = random(21);
	
	if(get_pcvar_num(pcvar[CDEBUG]) == 1) {
		tmp = get_gametime();
		log_amx("[FunMod] Gametime: %f, Choosing New Random Event...info: num=%i", tmp, num);
	}
	
	switch(num) {
		case 0: RanEvent_GiveWeapon();
		case 1: RanEvent_Lighting();
		case 2: RanEvent_CtGodmode();
		case 3: RanEvent_TsGodmode();
		case 4: RanEvent_CtInvis();
		case 5: RanEvent_TsInvis();
		case 6: RanEvent_KnifeMode();
		case 7: RanEvent_SlapAll();
		case 8: RanEvent_GravityShift();
		case 9: RanEvent_CtNoClip();
		case 10: RanEvent_TsNoClip();
		case 11: RanEvent_CtLowHealth();
		case 12: RanEvent_TsLowHealth();
		case 13: RanEvent_ScoutMode();
		case 14: RanEvent_AwpMode();
		case 15: RanEvent_NadeMode();
		case 16: RanEvent_AllHealed();
		case 17: RanEvent_CtHealed();
		case 18: RanEvent_TsHealed();
		case 29: RanEvent_Speeding();
		case 20: RanEvent_SameModel();
	}
	cached_gametime = get_systime();
	return PLUGIN_CONTINUE;
}

public RanEvent_GiveWeapon() {
	new players[32], num;
	get_players(players, num, "a");

	new ran = random(num);
	new id = players[ran];
	
	if(is_user_connected(id) && is_user_alive(id)) {
		give_item(id, g_WeaponNames[random(25)]);
		client_print(id, print_chat, "Here have a weapon, on the house.");
	}
}

public RanEvent_Lighting() {
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "LET THE LIGHTNING FLASH!!");
	
	lightning_on = true;
	
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "remove_darkness", TASK_LIGHTING_END);
	
	set_task(0.1, "lighting_effects", TASK_LIGHTING);
	
}

public RanEvent_CtGodmode() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT) {
			set_user_godmode(i, 1);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_godmode", i+TASK_GMODE);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL CTs NOW HAVE GODMODE!!");
}

public RanEvent_TsGodmode() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T) {
			set_user_godmode(i, 1);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_godmode", i+TASK_GMODE);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL Ts NOW HAVE GODMODE!!");
}

public RanEvent_CtInvis() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT) {
			set_user_rendering(i, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 5);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_invis", i+TASK_INVIS);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL CTs ARE NOW INVISIBLE!!");
}

public RanEvent_TsInvis() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T) {
			set_user_rendering(i, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 5);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_invis", i+TASK_INVIS);	
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL Ts ARE NOW INVISIBLE!!");
}

public RanEvent_KnifeMode() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			strip_user_weapons(i);
			give_item(i, "weapon_knife");
			Mode = 1;
		}
	}
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "mode_normal", TASK_MODE);
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "IT IS KNIFING TIME!!");
}

public RanEvent_SlapAll() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			user_slap(i, 10);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "EVERYONE SLAPPED FOR 10 DAMAGE!!");
}

public RanEvent_GravityShift() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			set_user_gravity(i, get_user_gravity(i)-0.85);
			set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "remove_gravity", i+TASK_GRAV);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "WARNING:^nGRAVITY SHIFT IN PROGRESS!!");
}

public RanEvent_CtNoClip() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT) {
			set_user_noclip(i, 1);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_noclip", i+TASK_NOCLIP);	
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL CTs NOW HAVE NOCLIP!!");
}

public RanEvent_TsNoClip() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T) {
			set_user_noclip(i, 1);
			set_task(get_pcvar_float(pcvar[CLOOP])-6.0, "remove_noclip", i+TASK_NOCLIP);	
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL Ts NOW HAVE NOCLIP!!");
}

public RanEvent_CtLowHealth() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT) {
			set_user_health(i, get_user_health(i)/2);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL CTs HEALTH HAS BEEN DIVIDED IN HALF!!");
}

public RanEvent_TsLowHealth() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T) {
			set_user_health(i, get_user_health(i)/2);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL Ts HEALTH HAS BEEN DIVIDED IN HALF!!");
}

public RanEvent_ScoutMode() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			strip_user_weapons(i);
			give_item(i, "weapon_scout");
			Mode = 2;
		}
	}
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "mode_normal", TASK_MODE);
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "SCOUTS ONLY NOW!!");
}

public RanEvent_AwpMode() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			strip_user_weapons(i);
			give_item(i, "weapon_awp");
			Mode = 3;
		}
	}
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "mode_normal", TASK_MODE);
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "AWPS ONLY NOW!!");
}

public RanEvent_NadeMode() {	
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			strip_user_weapons(i);
			give_item(i, "weapon_hegrenade");
			Mode = 4;
		}
	}
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "mode_normal", TASK_MODE);
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "GERNADES ONLY NOW!!");
}

public RanEvent_AllHealed() {
	new maxhealth;
	
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			if(on_deathstreak[i]) {
				maxhealth = 100+get_pcvar_num(pcvar[CHEALTH]);
			} else { maxhealth = 100; }
			
			set_user_health(i, maxhealth);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "EVERYONE WAS HEALED!!");
}

public RanEvent_CtHealed() {
	new maxhealth;
	
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_CT) {
			if(on_deathstreak[i]) {
				maxhealth = 100+get_pcvar_num(pcvar[CHEALTH]);
			} else { maxhealth = 100; }
			
			set_user_health(i, maxhealth);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL CTs WERE HEALED!!");
}

public RanEvent_TsHealed() {
	new maxhealth;
	
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i) && cs_get_user_team(i) == CS_TEAM_T) {
			if(on_deathstreak[i]) {
				maxhealth = 100+get_pcvar_num(pcvar[CHEALTH]);
			} else { maxhealth = 100; }
			
			set_user_health(i, maxhealth);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "ALL Ts WERE HEALED!!");
}

public RanEvent_Speeding() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			pdata[i][PSPEEDING] = 1;
			set_user_maxspeed(i, get_user_maxspeed(i)+200.0);
			set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "remove_speed", TASK_SPEED+i);
		}
	}
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "EVERYONE RUNS REALLY FAST NOW!!");
}

public RanEvent_SameModel() {
	for(new i = 1; i < MAXPLAYERS; i++) {
		if(is_user_alive(i) && is_user_connected(i)) {
			cs_set_user_model(i, "vip");
		}
		
	}
	set_task(get_pcvar_float(pcvar[CLOOP])-1.0, "reset_models", TASK_MODELS);
	
	set_cvar_num("mp_friendlyfire", 1);
	
	set_hudmessage(255, 0, 0, -1.0, 0.4);
	show_hudmessage(0, "EVERYONE HAS THE SAME MODEL, AND FRIENDLY FIRE IS ON!!");
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index
	switch (jghgtype) {
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent
}

stock bool:fm_get_user_longjump(index) {
	new value[2]
	engfunc(EngFunc_GetPhysicsKeyValue, index, "slj", value, 1)
	switch (value[0]) {
		case '1': return true
	}

	return false
}

stock fm_set_user_longjump(index, bool:longjump = true, bool:tempicon = true) {
	if (longjump == fm_get_user_longjump(index))
		return

	if (longjump) {
		engfunc(EngFunc_SetPhysicsKeyValue, index, "slj", "1")
		if (tempicon) {
			static msgid_itempickup
			if (!msgid_itempickup)
				msgid_itempickup = get_user_msgid("ItemPickup")

			message_begin(MSG_ONE, msgid_itempickup, _, index)
			write_string("item_longjump")
			message_end()
		}
	}
	else
		engfunc(EngFunc_SetPhysicsKeyValue, index, "slj", "0")
}

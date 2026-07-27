/*
Shove Mod - Push a player away from you.

What the cvars do:
shove_force - How strong the force for shoving is.
shove_cooldown - How long you must wait in order to shove.
shove_allow_inuse - Is the user allowed to press the "e" (Default: +use) key

Change Log:
[1.0]
Made it so admins can change the "+use" during a game. (Sorry thought it was more efficient.)
[1.1]
Made it more efficient so that no set_tasks had to be used. ( Thanks Hawk552, connorr )
Also added a how long left in parentheses.
[1.2]
Allow ghost be shoved and restrict them to use show.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <colorchat>

#define PLUGIN "Shove Mod"
#define VERSION "1.3"
#define AUTHOR "Styles"
#define MODIFIED_BY "Awesome Cars + Fun Maps Community"

new cShove, cCooldown, cInUse, cEnabled, cVoteDelay, cVoteTime;
new gLastShove[32];

new gVoteYes;
new gVoteNo;
new gNextVoteTime;
new gVoteInitiator[32];
new gVoteMenu;
new gVoteSelectMenu;
new gVoteSelectOwner;
new bool:gVoteEnable;
new bool:gVoteInProgress;
new bool:gVoteSelectionOpen;
new bool:gHasVoted[33];

new const gTag[] = "[^1AMXX^4]^1";
new const gShoveTag[] = "^3Shove mode^1";
new const gSoundStartVote[] = "buttons/bell1.wav";
new const gSoundVoteSuccess[] = "sank_sounds/woo.wav";
new const gSoundVoteFail[] = "buttons/button10.wav";

public plugin_precache()
{
	precache_sound(gSoundStartVote);
	precache_sound(gSoundVoteSuccess);
	precache_sound(gSoundVoteFail);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, MODIFIED_BY);
	register_clcmd("say /shove", "shovePlayer");
	register_clcmd("say /shovevote", "ShowShoveVoteMenu");
	register_clcmd("shovevote", "ShowShoveVoteMenu");
	cShove = register_cvar("shove_force", "7");
	cCooldown = register_cvar("shove_cooldown", "10");
	cInUse = register_cvar("shove_allow_inuse", "1");
	cEnabled = register_cvar("shove_enabled", "1");
	cVoteDelay = register_cvar("shove_vote_delay", "30");
	cVoteTime = register_cvar("shove_vote_time", "10");
	
	register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink");
}

public Forward_PlayerPreThink(id)
{
	if(!get_pcvar_num(cEnabled) || !get_pcvar_num(cInUse)) {
		return PLUGIN_HANDLED;
	}

	new button = pev(id, pev_button);
	new oldButton = pev(id, pev_oldbuttons);

	if (button & IN_USE && !(oldButton & IN_USE ) & !is_user_bot(id)) {
		shovePlayer(id);
	}

	return PLUGIN_CONTINUE;
}

public shovePlayer(id)
{
	if(!get_pcvar_num(cEnabled)) {
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(id) || get_user_godmode(id)) {
		return PLUGIN_HANDLED;
	}
	
	if(get_systime() - gLastShove[id] < get_pcvar_num(cCooldown)) {
		client_print(id, print_chat, "Your muscles are weak from shoving the player. You must wait to do it again. (%i)", (get_pcvar_num(cCooldown) - (get_systime() - gLastShove[id])))
		return PLUGIN_HANDLED;
	}
	
	new Index,Body, pName[64], tName[64];
	get_user_aiming(id,Index,Body,200);
	
	// remove live check (!is_user_alive(Index) here to allow to push ghosts
	if(!Index) {
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(Index) || get_user_godmode(Index)) {
		return PLUGIN_CONTINUE;
	} else if (!is_user_alive(Index)) {
		return PLUGIN_HANDLED;
	}
	
	// Comment to allow shove while crouching
	// new Float:size[3]
	// pev(id, pev_size, size)
	// if(size[2] < 72.0)
	// {
	// 	client_print(id, print_chat, "[Shove Mod] You can't shove somebody while doing that action.")
	// 	return PLUGIN_HANDLED
	// }
	
	new Float:velocity[3]; 
	new Float:shover[3];
	new Float:shovee[3];

	pev(id, pev_origin, shover);
	pev(Index, pev_origin, shovee);

	for (new i = 0; i < 3; i++) {
		velocity[i] = (shovee[i] - shover[i]) * get_pcvar_float(cShove);
	}
	
	set_pev(Index, pev_velocity, velocity);

	get_user_name(id, pName, sizeof(pName))
	get_user_name(Index, tName, sizeof(tName))
	client_print(id, print_chat, "Woo! You have just shoved %s!", tName);
	client_print(Index, print_chat, "Woo! You have just been shoved by %s!", pName);

	gLastShove[id] = get_systime();

	return PLUGIN_HANDLED;
}

public ShowShoveVoteMenu(id)
{
	if (gVoteInProgress || gVoteSelectionOpen) {
		ColorChat(id, GREEN, "%s There is already a Shove mode vote in progress started by ^3%s", gTag, gVoteInitiator);
		return PLUGIN_HANDLED;
	}

	new timeLeft = gNextVoteTime - get_systime();
	if (timeLeft > 0) {
		ColorChat(id, GREEN, "%s A new Shove mode vote can be started in ^4%d ^1seconds", gTag, timeLeft);
		return PLUGIN_HANDLED;
	}

	get_user_name(id, gVoteInitiator, charsmax(gVoteInitiator));
	gVoteSelectOwner = id;
	gVoteSelectionOpen = true;
	gVoteSelectMenu = menu_create("Choose Shove mode vote", "ShoveVoteSelectHandler");
	menu_additem(gVoteSelectMenu, "Enable", "1");
	menu_additem(gVoteSelectMenu, "Disable", "2");
	menu_display(id, gVoteSelectMenu, 0, 10);

	return PLUGIN_HANDLED;
}

public ShoveVoteSelectHandler(id, menu, item)
{
	if (!gVoteSelectionOpen || id != gVoteSelectOwner) {
		return PLUGIN_HANDLED;
	}

	gVoteSelectionOpen = false;

	if (item == MENU_EXIT) {
		menu_destroy(menu);
		gVoteSelectMenu = 0;
		gVoteInitiator[0] = '^0';
		return PLUGIN_HANDLED;
	}

	new data[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback);
	menu_destroy(menu);
	gVoteSelectMenu = 0;
	gVoteEnable = (str_to_num(data) == 1);
	StartShoveVote();

	return PLUGIN_HANDLED;
}

StartShoveVote()
{
	gVoteYes = 0;
	gVoteNo = 0;
	gVoteInProgress = true;
	arrayset(gHasVoted, false, sizeof(gHasVoted));

	if (gVoteEnable) {
		ColorChat(0, GREEN, "%s A vote to enable %s has been started by ^4%s", gTag, gShoveTag, gVoteInitiator);
		gVoteMenu = menu_create("Enable Shove mode?", "ShoveVoteHandler");
	} else {
		ColorChat(0, GREEN, "%s A vote to disable %s has been started by ^4%s", gTag, gShoveTag, gVoteInitiator);
		gVoteMenu = menu_create("Disable Shove mode?", "ShoveVoteHandler");
	}

	menu_additem(gVoteMenu, "Yes", "1");
	menu_additem(gVoteMenu, "No", "2");

	new players[32], playerCount;
	get_players(players, playerCount, "ch");
	for (new i = 0; i < playerCount; i++) {
		client_cmd(players[i], "speak ^"sound/%s^"", gSoundStartVote);
		menu_display(players[i], gVoteMenu, 0, get_pcvar_num(cVoteTime));
	}

	set_task(get_pcvar_float(cVoteTime), "EndShoveVote");
}

public ShoveVoteHandler(id, menu, item)
{
	if (!gVoteInProgress || item == MENU_EXIT || gHasVoted[id]) {
		return PLUGIN_HANDLED;
	}

	new data[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback);

	if (str_to_num(data) == 1) {
		gVoteYes++;
	} else {
		gVoteNo++;
	}
	gHasVoted[id] = true;

	return PLUGIN_HANDLED;
}

public EndShoveVote()
{
	ColorChat(0, GREEN, "%s Results from the Shove mode vote: ^4%d ^1Yes vs ^4%d ^1No", gTag, gVoteYes, gVoteNo);
	gNextVoteTime = get_systime() + get_pcvar_num(cVoteDelay);

	if (gVoteYes > gVoteNo) {
		client_cmd(0, "speak ^"sound/%s^"", gSoundVoteSuccess);
		set_pcvar_num(cEnabled, gVoteEnable ? 1 : 0);
		ColorChat(0, GREEN, "%s Due to the vote result, %s has been %s. A new vote can start in ^4%d ^1seconds", gTag, gShoveTag, gVoteEnable ? "^4enabled" : "^4disabled", get_pcvar_num(cVoteDelay));
	} else {
		client_cmd(0, "speak ^"sound/%s^"", gSoundVoteFail);
		ColorChat(0, GREEN, "%s Not enough ^4Yes ^1votes were cast. A new vote can start in ^4%d ^1seconds", gTag, get_pcvar_num(cVoteDelay));
	}

	gVoteInProgress = false;
	gVoteInitiator[0] = '^0';
	show_menu(0, 0, "^n", 1);
	menu_destroy(gVoteMenu);
	gVoteMenu = 0;
}


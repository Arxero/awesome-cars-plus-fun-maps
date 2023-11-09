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

#define PLUGIN "Shove Mod"
#define VERSION "1.2"
#define AUTHOR "Styles"
#define MODIFIED_BY "Awesome Cars + Fun Maps Community"

new cShove, cCooldown, cInUse;
new gLastShove[32];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, MODIFIED_BY);
	register_clcmd("say /shove", "shovePlayer");
	cShove = register_cvar("shove_force", "7");
	cCooldown = register_cvar("shove_cooldown", "10");
	cInUse = register_cvar("shove_allow_inuse", "1");
	
	register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink");
}

public Forward_PlayerPreThink(id)
{
	if(!get_pcvar_num(cInUse)) {
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


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>

#define PLUGIN "Shove Mod"
#define VERSION "1.0"
#define AUTHOR "Styles"

new cShove, cCooldown, cInUse
new gLastShove[32]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /shove", "shovePlayer")
	cShove = register_cvar("shove_force", "7")
	cCooldown = register_cvar("shove_cooldown", "10")
	cInUse = register_cvar("shove_allow_inuse", "1")
	
	register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink")
}

public Forward_PlayerPreThink(id)
{
	if(!get_pcvar_num(cInUse))
		return PLUGIN_HANDLED
	if(pev( id, pev_button ) & IN_USE && !(pev( id, pev_oldbuttons ) & IN_USE ) & !is_user_bot(id))
		shovePlayer(id)
	
	return PLUGIN_CONTINUE
}

public shovePlayer(id)
{
	if(!is_user_alive(id) || get_user_godmode(id))
		return PLUGIN_HANDLED
	
	if(get_systime() - gLastShove[id] < get_pcvar_num(cCooldown))
	{
		client_print(id, print_chat, "[Shove Mod] Your muscles are weak from shoving the player. You must wait to do it again. (%i)", (get_pcvar_num(cCooldown) - (get_systime() - gLastShove[id])))
		return PLUGIN_HANDLED
	}
	
	new Index,Body, pName[64], tName[64]
	get_user_aiming(id,Index,Body,200)
	
	if(!Index || !is_user_alive(Index))
		return PLUGIN_HANDLED
	
	new Float:size[3]
	pev(id, pev_size, size)
	if(size[2] < 72.0)
	{
		client_print(id, print_chat, "[Shove Mod] You can't shove somebody while doing that action.")
		return PLUGIN_HANDLED
	}
	
	get_user_name(id, pName, 63)
	get_user_name(Index, tName, 63)
	new Float:velocity[3], Float:shover[3], Float:shovee[3]
	pev(id, pev_origin, shover)
	pev(Index, pev_origin, shovee)
	
	for(new Count;Count < 3;Count++)
	velocity[Count] = (shovee[Count] - shover[Count]) * get_pcvar_float(cShove)
	set_pev(Index, pev_velocity, velocity)
	client_print(id, print_chat, "[Shove Mod] You have just shoved %s!", tName)
	client_print(Index, print_chat, "[Shove Mod] You have just been shoved by %s!", pName)
	gLastShove[id] = get_systime()
	return PLUGIN_HANDLED
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

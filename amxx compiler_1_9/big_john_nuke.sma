/* big_john_nuke.sma by Big John [Trailor Park Boys]
 *
 * Allows players to nuke the world, and kill everyone in the game.
 * The person who nukes gets kill credit for everyone (his teamates included) who got nuked.
 * Person who nuked does NOT get credit for killing himself.
 * 
 * A person must wait at least 8 minutes after (connecting to the server/last detonation) to use a nuke.
 * This is to prevent people from connecting to the server repeatedly just to nuke over and over.
 *
 * COMMAND: /nuke
 *          If you type /nuke, then a nuclear bomb is detonated with accompanying light changes, sound, death etc
 *
 * (c) 2005 by John (Big John) Gomes
 *
 * Where to place the nuclear.wav sound file:
 * --In your "cstrike" folder, find the folder called "sound". If this folder doesnt exist, create it.
 * --In your "sound" folder, find the folder called "misc". If this folder doesnt exist, create it.
 * --In your "misc" folder, place the sound file called "nuclear.wav"
 * ---Then compile and place the plugin in the same place any other plugin would go, and you're set.
 *
 * Please Note: -I made this plugin about a month ago for my server.
 *              -I realize someone has a plugin that allows admins to nuke at will, but my plugin is rather different.
 *              -That is, this plugin is for players to use nukes and get kill credit for doing so.
 *              -I havn't seen the code for the admin nuke, and all the code in here was written by me for the sole
 *   		 purpose of allowing players on my server to use nukes as a weapon (with accompanying special effects)
 *              -On deathmatch servers the nuke can tend to overflow a person or 2 sometimes, so be cautious if you run deathmatch.
 *               (I run deathmatch on my server which is why I dont use this anymore, but with a non-deathmatch server 
 *		  there are no problems that I have come across)
 */

#include <amxmodx>

new Float:LastNuke[33]

public plugin_init()
{ 
  register_plugin("big_john_nuke", "1.0", "Big John [Trailor Park Boys]")
  register_clcmd("say", "nuke")
}

public plugin_precache()
{
  precache_sound("misc/nuclear.wav")
}

public client_connect(id){
	LastNuke[id] = get_gametime()
	return PLUGIN_CONTINUE
}

public client_disconnect(id){
	LastNuke[id] = -1000.0
	return PLUGIN_CONTINUE
}

public nuke(id){
	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	if(nuke2(id,Speech))	
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public nuke2(id,Speech[])
{
	if ( (equali(Speech, "nuke")) || (equali(Speech, "/nuke")) )
	{
		if(is_user_alive(id) == 0)
		{
		client_print(id,print_chat, "Big John Nuke: You Must Be Alive To Detonate A Nuclear Weapon ")
		return PLUGIN_HANDLED
		}
		if (get_gametime() < LastNuke[id] + 480)
		{
		client_print(id,print_chat, "Big John Nuke: You Must Wait At Least 8 mins (After Detonating/After Connecting) To Use A Nuke. Try Later")
		return PLUGIN_HANDLED
		}
		else
		{
		new User[32]
		get_user_name(id,User,32)
		new totalplayers = get_playersnum () -1
		set_user_frags(id, get_user_frags(id) + totalplayers)
		set_lights("a")
		set_hudmessage(200,0,0, 0.03, 0.62, 2, 0.02, 5.0, 0.01, 0.1, 1)
    		show_hudmessage(0,"DANGER!! %s Has Detonated A Nuke So Say Your Prayers Cuz Your Gonna Die!!!",User)
		client_print(0,print_chat, "DANGER!! %s Has Detonated A Nuke So Say Your Prayers Cuz Your Gonna Die!!!",User)
		client_cmd(0,"spk misc/nuclear")
		LastNuke[id] = get_gametime()
		set_task(4.0,"preflash")
		return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public preflash()
{
set_lights("abcdefghijklmnopqrstuvwxyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz")
set_task(1.0,"flash")
}

public flash()
{
client_cmd(0, "kill")
set_lights("z")
set_task(1.0,"afterdeath")
}

public afterdeath()
{
set_lights("yyyyyyxxxxxxwwwwwwvvvvvvuuuuuuttttttssssssrrrrrrqqqqqqppppppoooooonnnnnnmmmmmmmmmm")
set_task(1.0,"afterdeath2")
}

public afterdeath2()
{
set_lights("m")
}

public client_kill (id)
{
set_user_frags(id,get_user_frags(id) +1)
}

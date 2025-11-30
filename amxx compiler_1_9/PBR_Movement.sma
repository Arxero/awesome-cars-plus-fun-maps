#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>

#define PLUGIN "[PBR] Movement"
#define VERSION "1.1"
#define AUTHOR "Sneaky.amxx"

new Float:userSprintLast[33], Float:userSprintLastBat[33], Float:userSprintSound[33] 
new userSprintSpeed[33], userSprintTiredness[33], userSprintAdvised[33]
new userWeapon[33][32]
new pbmoves, verbose, use_batmeter, rechargetime, max_stamina

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_CmdStart, "fw_cmdstart");
}

public plugin_precache()
{
	pbmoves = register_cvar("pbmoves_enabled", "1");
	verbose = register_cvar("pbmoves_verbose", "1");
	use_batmeter = register_cvar("pbmoves_usebatterymeter", "1");
	rechargetime = register_cvar("pbmoves_rechargetime", "10.0");
	max_stamina = register_cvar("pbmoves_maxstamina", "700");
	
	precache_sound("paintballR/sprint.wav");
	precache_sound("paintballR/gasp1.wav");
}

public fw_cmdstart(id, uc_handle, random_seed)
{
	if (!is_user_alive(id) || !get_pcvar_num(pbmoves))
		return FMRES_IGNORED
	
	static buttons; buttons = get_uc(uc_handle, UC_Buttons)
	new Float:gametime = get_gametime()
	
	if((gametime - userSprintLast[id] > get_pcvar_float(rechargetime) || !userSprintLast[id]))
	{
		userSprintTiredness[id] = 0
		userSprintLast[id] = gametime
		set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 1.0, 1.0);
		if(!userSprintAdvised[id])
		{
			userSprintAdvised[id] = true
			show_hudmessage(id, "You are fresh! You can sprint with right-click...");
		}
		
		if(get_pcvar_num(use_batmeter))
		{
			userSprintLastBat[id] = gametime
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("FlashBat"), {0,0,0}, id)
			write_byte(100)
			message_end()
		}
	}
	
	new currentweapon = get_user_weapon(id)
	
	if(buttons & IN_ATTACK2 && currentweapon != CSW_SCOUT)
	{
		set_uc(uc_handle, UC_Buttons, buttons & ~IN_ATTACK2);
	
		if(userSprintTiredness[id] >= get_pcvar_num(max_stamina))
		{
			userSprintAdvised[id] = false
			set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 0.1, 0.1);
			show_hudmessage(id, "Too tired to sprint. Please wait...");

			if(gametime - userSprintSound[id] > 1.0)
			{
				emit_sound(id, CHAN_AUTO, "paintballR/gasp1.wav", 1.0, ATTN_NORM , 0, PITCH_NORM);
				userSprintSound[id] = gametime
			}
			
			return FMRES_IGNORED;		
		}
	
		userSprintTiredness[id] += 1				
		
		if(!(buttons & IN_DUCK))
		{	
			
			if (currentweapon != CSW_KNIFE){
				get_weaponname(currentweapon,userWeapon[id],30)
				engclient_cmd(id, "weapon_knife")
			}
			userSprintSpeed[id] += 2;

			if (userSprintSpeed[id] < 200)
				userSprintSpeed[id] = 200;

			if (userSprintSpeed[id] > 400)
				userSprintSpeed[id] = 400;

			userSprintLast[id] = gametime
			
			//Some of this was inspired in +Speed 1.17 by Melanie
			new Float:returnV[3], Float:Original[3]
			VelocityByAim ( id, userSprintSpeed[id], returnV )
	
			pev(id,pev_velocity,Original)
			
			//Avoid floating in the air and ultra high jumps
			if (vector_length(Original) < 600.0 || Original[2] < 0.0)
				returnV[2] = Original[2]
			
			set_pev(id,pev_velocity,returnV)
			set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 0.1, 0.1);
			show_hudmessage(id, "Sprinting...");
			
			if (userSprintLast[id] - userSprintSound[id] > 1.0)
			{
				emit_sound(id, CHAN_AUTO, "paintballR/sprint.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
				userSprintSound[id] = userSprintLast[id]				
			}
		
			if (gametime - userSprintLastBat[id] > 0.2 && get_pcvar_num(use_batmeter))
			{
				userSprintLastBat[id] = gametime
				new percentage = 100 - (userSprintTiredness[id] * 100 / get_pcvar_num(max_stamina))
				message_begin(MSG_ONE,get_user_msgid("FlashBat"),{0,0,0},id);
				write_byte(percentage);
				message_end();
			}


		
			return FMRES_IGNORED;
		} else
		{			
			if (userSprintSpeed[id] > 2)
				userSprintSpeed[id] -= 2;
			else
				userSprintSpeed[id] = 0;
				
			userSprintLast[id] = gametime

			new Float:returnV[3], Float:Original[3]
			VelocityByAim ( id, userSprintSpeed[id], returnV )
	
			pev(id,pev_velocity,Original)
			
			//Avoid floating in the air and ultra high jumps
			if (vector_length(Original) < 600.0 || Original[2] < 0.0)
				returnV[2] = Original[2]
			
			set_pev(id,pev_velocity,returnV)
			set_hudmessage(255, 255, 255, -1.0, 0.33, 0, 0.1, 0.1);
			show_hudmessage(id, "Sliding...")
			
			return FMRES_IGNORED;
		}

	}

	//restore weapon after sprinting
	if(userWeapon[id][0])
	{
		engclient_cmd(id, userWeapon[id])
		userWeapon[id][0] = 0
	}
	userSprintSpeed[id] = 0;
	
	return FMRES_IGNORED;
}

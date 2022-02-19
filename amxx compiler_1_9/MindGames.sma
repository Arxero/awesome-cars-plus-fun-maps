#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <dhudmessage>
#include <next21_advanced>

#define PLUGIN "Mind Games"
#define VERSION "1.0" 
#define AUTHOR "fifayer & Psycrow (Edit)"

#define SHORT_FORMAT				255, 255, 255, 0.05, 0.6, 0, 6.0, 6.0
#define SH_FORMAT				255, 255, 255, 0.05, 0.6, 0, 6.0, 1.0

#define DHUD_LONG_FORMAT		255, 255, 255, 0.05, 0.6, 0, 0.0, 0.0, 0.6, 6.0
#define DHUD_MATRIX_FORMAT		255, 255, 255, 0.01, 0.5, 0, 0.0, 0.0, 0.6, 1.0
#define DHUD_SHORT_FORMAT		255, 255, 255, 0.01, 0.6, 0, 0.0, 0.0, 0.6, 1.0

new answer, nick_winner[32], num1, num2, num3, num4, num5, mode
new type
new bool: in_ready, in_show

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say","res")
	register_clcmd("say_team","res")
	
	//register_clcmd("say go","go")
		
	register_dictionary("MindGames.txt")
	
	set_task(200.0, "go", _, _, _, "b")
	set_task(1.0, "quest", _, _, _, "b")
	set_task(1.0, "show", _, _, _, "b")
}

public plugin_natives()
	register_native("ka_next_result_mg", "_n21_res_mg", 0)

public plugin_precache() 
{
	precache_sound("mind_games/n21_off.wav")
	precache_sound("buttons/bell1.wav")
	return PLUGIN_CONTINUE
}

public quest ()
{	
	if (!in_ready)
	{
		in_ready = true
		type = 0
		num1 = random_num(1, 100)
		num2 = random_num(1, 50)
		num3 = random_num(1, 50)
		num4 = random_num(1, 50)
		num5 = random_num(1, 50)
		
		mode = random_num(0, 5)
	
		switch(mode)
		{
			case 0:
			{
				type = 0
				answer = num1 + num2 + num3 + num4 + num5
			}
			case 1:
			{
				type = 1
				answer = num1 - num2 - num3 - num4 - num5
			}
			case 2:
			{
				type = 2
				answer = num1 + num2 - num3 + num4 - num5
			}
			case 3:
			{
				type = 3
				answer = num1 - num2 + num3 - num4 + num5
			}
			case 4:
			{
				type = 4
				answer = num1 - num2 - num3 + num4 + num5
			}
			case 5:
			{
				type = 5
				answer = num1 + num2 + num3 - num4 - num5
			}
		}
	}
}

public go()
{
	if(in_show)
		in_ready = false
	client_cmd(0, "spk buttons/bell1" )
	in_show = true
}


public show()
{
	if(in_show)
	{
		set_dhudmessage(DHUD_SHORT_FORMAT)
		switch (type)
		{
			case 0: show_dhudmessage(0, "%d + %d + %d + %d  + %d = ?", num1, num2, num3, num4, num5)	
			case 1: show_dhudmessage(0, "%d - %d - %d - %d  - %d = ?", num1, num2, num3, num4, num5)	
			case 2: show_dhudmessage(0, "%d + %d - %d + %d  - %d = ?", num1, num2, num3, num4, num5)	
			case 3: show_dhudmessage(0, "%d - %d + %d - %d  + %d = ?", num1, num2, num3, num4, num5)
			case 4: show_dhudmessage(0, "%d - %d - %d + %d  + %d = ?", num1, num2, num3, num4, num5)
			case 5: show_dhudmessage(0, "%d + %d + %d - %d  - %d = ?", num1, num2, num3, num4, num5)
		}
	}
}

public res(id)
{
	if(in_show)
	{
		new chat[256], smanswer[32]
		read_args(chat, 255)
		remove_quotes(chat)
		num_to_str(answer, smanswer, 31)
			
		if (equali(chat, smanswer ))
		{
			in_show = false
			set_task(1.5,"award",id)
		}
	}
}

public award(id)
{
	client_cmd(0, "spk mind_games/n21_off" );	
		
	get_user_name(id,nick_winner,31); 

	new gift = random_num(2500, 8000)
		
	if(cs_get_user_money(id) + gift <= 55000)
	{
		cs_set_user_money(id, cs_get_user_money(id) + gift)
		set_dhudmessage(DHUD_LONG_FORMAT)
		show_dhudmessage(0, "%L", -1 ,"MIND_MONEY", nick_winner, gift, answer)
	}
	
	else
	{
		gift = 55000 - cs_get_user_money(id)
		if(gift != 0)
		{
			cs_set_user_money(id, cs_get_user_money(id) + gift)
			set_dhudmessage(DHUD_LONG_FORMAT)
			show_dhudmessage(0, "%L", -1 ,"MIND_MONEY", nick_winner, gift, answer)
		}
		else
		{
			if(is_user_alive(id))
			{
				ka_use_regeneration(id)
				set_dhudmessage(DHUD_LONG_FORMAT)
				show_dhudmessage(0, "%L", -1 ,"MIND_REGEN", nick_winner, answer)
			}
			else 
			{
				ExecuteHam(Ham_CS_RoundRespawn, id)
				set_dhudmessage(DHUD_LONG_FORMAT)
				show_dhudmessage(0, "%L", -1 ,"MIND_RESPAWN", nick_winner, answer)
			}
		}
	
	}
	in_ready = false
}

public _n21_res_mg()
	return answer
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

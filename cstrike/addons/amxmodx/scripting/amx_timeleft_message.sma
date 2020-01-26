#include <amxmodx>
#include <coll_msg>
#include <dhudmessage>

new pcvar_message
new Float:times = 120.0 //през колко време да се показва съобщението (120.0 секунди / 2 минути)

public plugin_init()
{
	set_task(times, "info", _, _, _, "b")
	
	pcvar_message = register_cvar("amx_timeleft_message", "1") // 1 - вкл. collor message / 0 - вкл. dhud message
	
	register_plugin("Auto Time Left message", "1.0", "{ S p @ W n } +++")
}
public client_disconnect(id)
{
	if(!task_exists(id)) remove_task(id)
}
public info()
{
	if(get_cvar_float("mp_timelimit") ? 1 : 0)
	{
		new a = get_timeleft()
		
		if(get_pcvar_num(pcvar_message) ? 1 : 0)
		{
			Chat(0, "^3Time Left^3: ^3 %d^3:^3%02d", (a / 60), (a % 60))
		}
		else
		{
			set_dhudmessage(255, 255, 0, 0.05, 0.17, 0, 6.0, 3.0, 0.1, 12.0, false)
			show_dhudmessage(0, "Time Left: %d minutes and %02d seconds remaining !", (a / 60), (a % 60))
		
			client_cmd(0, "spk ^"vox/time remaining^"")
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/

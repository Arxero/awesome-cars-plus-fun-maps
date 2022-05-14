#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Amx PM"
#define VERSION "1.3"
#define AUTHOR "Sonic"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("amx_pm", "send_message", 0, "<player> <message> - user sends a message to another user.");
	register_clcmd("/msgadmin", "send_chat", 0, "<message> - leave a message for the admin.  Put your message in quotes. (Not in console)");
	register_clcmd("say ", "send_chat", 0, "<player> <message> - user sends a message to another user.");
	
}


public send_message(id, level, cid) {
	
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new user[32], uid
	read_argv(1, user, 31)
	new message[256]
	read_argv(2, message, 255);
	new sendername[32]
	get_user_name(id, sendername, 31)
	uid = find_player("bhl", user)
	new name[32];
	get_user_name(uid, name, 31)
	
	if (uid == 0) { 
		console_print(id, "[AMXX] Sorry, unable to find player with that name.")
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_alive(id)) { 
		client_print(id,print_chat,"[AMXX] Can't send PMs while dead!")
		return PLUGIN_HANDLED;
	}
	
	new basedir[64]
	get_basedir(basedir, 63)
	
	new LOG_FILE[164];
	format(LOG_FILE, 163, "%s/logs/pms.log", basedir)
	
	new log[256]
	format(log,255,"Message from %s to %s: %s",sendername,name,message)
	write_file(LOG_FILE,log)
	
	console_print(id,  "[AMXX] Message sent to %s!", name)
	console_print(uid, "** [AMXX] You've recieved a message from %s! **", sendername)
	
	client_print(uid, print_chat, "** Message from %s: %s **", sendername, message)
	
	return PLUGIN_HANDLED
}
public send_chat(id, level, cid){
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new total[256]
	read_args(total, 255)
	remove_quotes(total)
	new left[92],right[92]
	strtok(total,left,91,right,91)
	

	if(equali(left,"/pm")) {
		new lala[256], target[256], message[256]
		strtok(total,lala,255,total,255)
		strtok(total,target,255,message,255)
		
		new sendername[32], uid
		get_user_name(id, sendername, 31)
	
		
		uid = find_player("bhl", target)
		if (uid == 0) { 
			client_print(id, print_chat, "[AMXX] Sorry, unable to find player with that name.")
			return PLUGIN_HANDLED;
		}
		
		new targetname[32], targetsteamid[32], sendersteamid[32]
		get_user_authid(id,sendersteamid,31)
		get_user_authid(uid,targetsteamid,31)
		
		get_user_name(uid,targetname,31)
		
		new basedir[64]
		get_basedir(basedir, 63)
		
		new LOG_FILE[164]
		format(LOG_FILE, 163, "%s/logs/pms.log", basedir)
		
		new log[256];
		format(log,255,"Message from %s(%s) to %s(%s): %s",sendername,sendersteamid,targetname,targetsteamid,message)
		write_file(LOG_FILE,log);
		
		console_print(id,  "[AMXX] Message sent to %s!", targetname)
		client_print(id, print_chat, "[AMXX] Message sent to %s", targetname)
		
		client_print(uid, print_chat, "** Message from %s: %s **", sendername, message)
		
		return PLUGIN_HANDLED
	}
	
	if(equali(left,"/msgadmin")) {
		
		new sendername[32], sendersteam[32]
		get_user_authid(id, sendersteam ,31)
		get_user_name(id, sendername, 31)
		new basedir[64]
		get_basedir(basedir, 63)
		
		new LOG_FILE[164]
		format(LOG_FILE, 163, "%s/logs/messages_for_admin.log", basedir)
		
		new log[256];
		format(log,255,"Message from %s(%s): %s",sendername,sendersteam,right)
		write_file(LOG_FILE,log);
		
		console_print(id,  "[AMXX] Message sent to admin!")
		client_print(id, print_chat, "[AMXX] Message sent to admin!")
		
	
		
		
		return PLUGIN_HANDLED
	}
	
	
	
	
	
	return PLUGIN_CONTINUE
}

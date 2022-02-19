/*
	This plugin allows players to become a ghost after death.
	The ghost is visible only at close range.
*/

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <engine>

#define PLUGIN "Ghost After Death"
#define VERSION "0.95"
#define AUTHOR "R3T"

enum(+=100){
	TASK_RESPAWN = 100,
	TASK_STRIP,
	TASK_BACK
}

new bool:is_ghost[33];
new CsTeams:old_team[33];
new bool:use_menu[33];
new bool:use_menu_always_no[33];
new bool:end_round;
new sprite_death;

new const g_szMaps[][] =
{
	"most_wanted",
	"most_wanteD2",
	"fun_atraccions",
	"fun_box",
	"awesome_cars",
	"awesome_cars2",
	"nojarq_fun_zone",
	"fun_cars",
	"woohoo_cars",
	"he_offroad",
	"happyvalley_2nd_lt",
	"he_glass"
};

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("death_ghost.txt");

	// forwards
	RegisterHam(Ham_Touch, "weaponbox", "fw_Touch");
	RegisterHam(Ham_Touch, "armoury_entity", "fw_Touch");
	RegisterHam(Ham_Touch, "weapon_shield", "fw_Touch");
	// trigger_multiple and func_door tbc

	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary");
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary");
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary");
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary");
	//RegisterHam(Ham_Use, "func_vehicle", "fw_UseStationary");

	register_forward(FM_ClientKill, "fw_ClientKill"); // prevent ghost suicide
	register_forward(FM_EmitSound, "fw_EmitSound");
	register_forward(FM_AddToFullPack, "AddToFullPack", 1);

	// messages
	new g_Server_Message = get_user_msgid("SayText");
	register_message(g_Server_Message, "ghostMessage");

	//Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("event_round_end",2,"1=Round_End");
	register_event("CurWeapon","CurWeapon","be");

	register_event("TeamInfo" , "fw_EvTeamInfo" , "a");
	register_event("DeathMsg","DeathMsg","ade");

	RegisterHam(Ham_TraceAttack, "player", "Player_TraceAttack_Pre");
	RegisterHam(Ham_Player_ImpulseCommands, "player", "Player_ImpulseCommands");

	// clcmds
	register_clcmd("say /ghost","ghost_use_menu");

	register_clcmd("chooseteam", "team_change");
	register_clcmd("jointeam", "team_change");

	// GMSG
	//g_hideHUD = get_user_msgid("HideWeapon");

	// Menus
	register_clcmd("ghost_menu", "ghost_menu");
}

public plugin_precache(){
	precache_model("models/player/skelepuncher/skelepuncher.mdl");
	sprite_death = precache_model("sprites/93skull1.spr");
}

public client_connect(id) {
	is_ghost[id] = false;
	use_menu[id] = false;
	use_menu_always_no[id] = false;
}

public client_disconnected(id) {
	is_ghost[id] = false;
	use_menu[id] = false;
	use_menu_always_no[id] = false;

	if (task_exists(id+TASK_STRIP)) remove_task(id+TASK_STRIP);
	if (task_exists(id+TASK_BACK)) remove_task(id+TASK_BACK);
	if (task_exists(id+TASK_RESPAWN)) remove_task(id+TASK_RESPAWN);
	if (task_exists(id+TASK_RESPAWN+1)) remove_task(id+TASK_RESPAWN+1);
	if (task_exists(id+TASK_RESPAWN+2)) remove_task(id+TASK_RESPAWN+2);
}

public event_round_start() {
	end_round = false;
	for (new id = 1; id <= 32; id++) {
		if (is_ghost[id] && is_user_connected(id)) {
			revert_ghost(id);
		}

		if (task_exists(id+TASK_BACK)) {
			remove_task(id+TASK_BACK);
		}

		if (is_user_alive(id)) {
			set_task(1.0, "back_item", id+TASK_BACK);
		}

		if (is_user_connected(id)) {
			new CsTeams:current_team = cs_get_user_team(id);
			if (current_team != CS_TEAM_T && current_team != CS_TEAM_CT) {
				set_pev(id, pev_solid, SOLID_NOT);
			}
		}
	}
}

public team_change(id) {
	if (is_ghost[id]) {
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public back_item(id) {
	id-=TASK_BACK;

	if (!is_user_alive(id)) {
		return;
	}

	give_item(id, "weapon_knife");

	new szMap[32], bool:isKnifeMap
	get_mapname(szMap, charsmax(szMap))

	for(new i; i < sizeof(g_szMaps); i++)
	{
		if(equali(szMap, g_szMaps[i]))
		{
			isKnifeMap = true;
			break;
		}
	}

	if (isKnifeMap) {
		return;
	}

	if (get_user_flags(id) & ADMIN_RESERVATION) {
		cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
		give_item(id, "weapon_hegrenade")
		give_item(id, "weapon_flashbang")
		cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		give_item(id, "weapon_smokegrenade")
	}

	switch(old_team[id]){
		case CS_TEAM_CT: {
			give_item(id,"weapon_usp");
			cs_set_user_bpammo(id, CSW_USP, 100)
		}
		case CS_TEAM_T: {
			give_item(id,"weapon_glock18");
			cs_set_user_bpammo(id, CSW_GLOCK18, 120)
		}
	}
}

public CurWeapon(id){
	if(is_user_connected(id) && is_user_alive(id) && is_ghost[id]){
		if(get_user_weapon(id) != CSW_KNIFE)
			set_task(0.1,"strip_user_weap",id+TASK_STRIP);
	}
}

public strip_user_weap(id){
	id-=TASK_STRIP;
	strip_user_weapons(id);
}

// spec bug fix
public fw_EvTeamInfo() {
	static id; id = read_data(1);
	static szTeam[2]; read_data(2, szTeam, 1);

	if (!end_round && is_ghost[id] && is_user_connected(id) && (equal(szTeam[0], "C") || equal(szTeam[0], "T"))) {
		revert_ghost_team(id);
	}
}

public fw_EmitSound(entity, channel, const sound[]) {
	if (1 <= entity <= 32 && is_ghost[entity]) {
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public event_round_end() {
	end_round = true;
	for (new id = 1; id <= 32; id++) {
		if (is_ghost[id] && is_user_connected(id)) {
			revert_ghost_team(id);
		}
	}
}

public DeathMsg(){
	if (end_round) {
		return;
	}
	ghost(read_data(2));
}

public ghost(id) {
	if (!is_user_connected(id) && !is_user_bot(id)) {
		return;
	}
		
	if (is_user_alive(id)) {
		client_print(id,print_chat,"%L",id,"USER_ALIVE");
		return;
	}

	if (is_ghost[id]) {
		client_print(id,print_chat,"%L",id,"USER_GHOST");
		return;
	}
	
	if (end_round) {
		client_print(id,print_chat,"%L",id,"ROUND_END");
		return;
	}

	if (use_menu[id]) {
		set_task(0.1, "make_ghost", id + TASK_RESPAWN);
	} else {
		if (!use_menu_always_no[id]) {
			ghost_menu(id);
		}
	}
}

public make_ghost(tid) {
	new id = (tid - TASK_RESPAWN);
	if (!is_user_alive(id) && !end_round) {
		new CsTeams:current_team = cs_get_user_team(id);
		if (current_team == CS_TEAM_T || current_team == CS_TEAM_CT) {
			is_ghost[id] = true;
			old_team[id] = current_team;
			cs_set_user_team(id, CS_TEAM_SPECTATOR);
			set_task(3.0, "ghost_respawn", id + TASK_RESPAWN+1);
		}
	}
}

public ghost_respawn(tid) {
	new id = (tid - TASK_RESPAWN - 1);
	if (!end_round && is_user_connected(id) && is_ghost[id] && cs_get_user_team(id) == CS_TEAM_SPECTATOR && (old_team[id] == CS_TEAM_T || old_team[id] == CS_TEAM_CT)) {
		new origin[3];
		get_user_origin(id,origin);

		// Write death sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
		write_byte(TE_SPRITE);

		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_short(sprite_death);
		write_byte(15);
		write_byte(255);
		message_end();

		// Actual Spawn
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		set_task(1.0, "handle_ghost", (id+TASK_RESPAWN+2));
	} else if (!end_round && is_user_alive(id)) {
		user_silentkill(id);
	}
}

public handle_ghost(tid) {
	new id = (tid - TASK_RESPAWN - 2);
	//set_ent_data(id, "CBasePlayer", "m_bNotKilled", false);
	if (!end_round && !is_ghost[id] || !is_user_connected(id) && !is_user_bot(id)) {
		return;
	}

	set_user_godmode(id, 1);
	set_pev(id, pev_solid, SOLID_NOT);
	set_user_rendering(id, kRenderFxHologram, 0, 0, 0, kRenderTransAlpha, 125)
	cs_set_user_model(id, "skelepuncher");
	strip_user_weapons(id);
	set_user_footsteps(id);
}

public revert_ghost_team(id) {
	cs_set_user_team(id, old_team[id]);
}

public revert_ghost(id) {
	is_ghost[id] = false;
	cs_reset_user_model(id);
	set_pev(id, pev_solid, SOLID_SLIDEBOX);
	set_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 255);
	set_user_godmode(id);
	set_user_footsteps(id, 0);

	if (task_exists(id+TASK_RESPAWN)) remove_task(id+TASK_RESPAWN);
	if (task_exists(id+TASK_RESPAWN+1)) remove_task(id+TASK_RESPAWN+1);
	if (task_exists(id+TASK_RESPAWN+2)) remove_task(id+TASK_RESPAWN+2);
}

public fw_Touch(weapon,id) {
	if (!is_user_connected(id)) {
		return HAM_IGNORED;
	}

	if (is_ghost[id]) {
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public fw_UseStationary(entity, caller, activator, use_type) {
	// Prevent ghosts from using stationary guns 2 = USE_USING
	if (use_type == 2 && is_ghost[caller]) {
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public ghost_menu(id) {
	new textmenu[200];
	format(textmenu,199,"%L",id,"MENU_HEAD");
	new g_menu = menu_create(textmenu, "menu_handler");
	
	format(textmenu,199,"%L",id,"MENU_YES");
	menu_additem(g_menu, textmenu, "1", 0);
	format(textmenu,199,"%L",id,"MENU_NO");
	menu_additem(g_menu, textmenu, "2", 0);
	
	format(textmenu,199,"%L",id,"MENU_ALWAYS_YES");
	menu_additem(g_menu, textmenu, "3", 0);

	format(textmenu,199,"%L",id,"MENU_ALWAYS_NO");
	menu_additem(g_menu, textmenu, "4", 0);
	
	menu_setprop(g_menu, MPROP_EXIT, MEXIT_ALL );
	menu_display(id, g_menu, 0)
}

public menu_handler(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback;
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);

	new key = str_to_num(s_Data);
	switch (key) {
		case 1:
			set_task(0.1, "make_ghost", id + TASK_RESPAWN);
		case 3: {
			use_menu[id] = true;
			set_task(0.1, "make_ghost", id + TASK_RESPAWN);
		}
		case 4: use_menu_always_no[id] = true;
		default:{
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public ghost_use_menu(id) {
	if (!is_user_bot(id) && is_user_connected(id) && use_menu[id]) {
		use_menu[id] = false;
		use_menu_always_no[id] = false;
	}
}

public fw_ClientKill(id) {
	if (is_ghost[id] && is_user_alive(id)) {
		client_print(id,print_chat,"%L",id,"GHOST_SUICIDE");
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}  

public Player_TraceAttack_Pre(id, iAttacker) {
	if(1 <= id <= 32 && is_ghost[iAttacker]) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public Player_ImpulseCommands(id) {
	if (is_ghost[id]) {
		if(pev(id, pev_impulse) == 100 || pev(id, pev_impulse) == 201) {
			set_pev(id, pev_impulse, 0);
			return HAM_HANDLED;
		}
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public ghostMessage(MsgID,MsgDest,id) {
	new sender = get_msg_arg_int(1);
	
	if (!is_ghost[sender]) {
		return PLUGIN_CONTINUE;
	}

	new message[151]; //Variable for the message
	new sender_name[32]; //Sender

	get_msg_arg_string(4, message, 150);
	get_user_name(sender, sender_name, 31);

	if (is_user_connected(id) && (!is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR)) {
		new ghost_msg[200];
		format(ghost_msg,199,"%s%L: %s",sender_name,id,"GHOST_IN_SAY",message);
		client_print(id,print_chat,ghost_msg);
	}
   	return PLUGIN_HANDLED;
}

public AddToFullPack(es, e, iEnt, id, hostflags, player, pSet) {
	if( player && iEnt == id && get_orig_retval()) {
		if (is_ghost[iEnt]){
			set_es(es, ES_RenderMode, entity_get_int(id, EV_INT_rendermode));
			set_es(es, ES_RenderAmt, floatround(entity_get_float(id, EV_FL_renderamt)));
		}
	}
}
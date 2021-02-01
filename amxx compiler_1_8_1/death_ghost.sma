/*
	������ ��������� ������� ����� ��������� ����� ������.
	�������� ������ �� ���� �����.
	�������� ����� ������ ������.
	
	This plugin allows players to become a ghost after death.
	Ghosts are flying all over the map.
	The ghost is visible only at close range.
	
	�������:
	�� ����, ������������ � ������: H0R1ZON
	������ ��������:
	LARS
	
	THX:
	for ideas, testing and care: H0R1ZON
	Model ghost:
	LARS
	
	�������� ��� ������: kodportal.ru
	Visit our portal: kodportal.ru
*/

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>

#define PLUGIN "Ghost After Death"
#define VERSION "1.7"
#define AUTHOR "HoLLyWooD"

enum(+=100){
	TASK_HUD = 100,
	TASK_RESPAWN,
	TASK_STRIP,
	TASK_BACK
}

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
}



new bool:is_ghost[33];
new CsTeams:old_team[33];
new bool:use_menu[33];
new bool:use_menu_always_no[33];
new bool:endround;
new sprite_death;

new g_hideHUD;

new cvar_admin;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar( "death_ghost", VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	
	// Cvars
	cvar_admin = register_cvar("ghost_admin","0");
	
	// Dicrionary
	register_dictionary("death_ghost.txt");
	
	// forwards && Hams
	RegisterHam(Ham_Touch, "weaponbox", "fw_Touch");
	RegisterHam(Ham_Touch, "armoury_entity", "fw_Touch");
	RegisterHam(Ham_Touch, "weapon_shield", "fw_Touch");
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_ClientKill, "Forward_ClientKill")
	register_forward(FM_AddToFullPack, "AddToFullPack", 1) 
	
	// messages
	new g_Server_Message = get_user_msgid("SayText");
	register_message(g_Server_Message,"ghostMessage");
	
	//Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("event_round_end",2,"1=Round_End");
	register_event("DeathMsg","DeathMsg","ade") ;
	register_event("ResetHUD", "ResetHUD", "abe");
	register_event("CurWeapon","CurWeapon","be");
	
	// clcmds
	register_clcmd("say /ghost","ghost_use_menu");
	
	// GMSG
	g_hideHUD = get_user_msgid("HideWeapon");
	
	// Menus
	register_clcmd("ghost_menu", "ghost_menu");
	
}

public plugin_precache(){
	precache_model("models/player/ghost/ghost.mdl")
	precache_model("models/rpgrocket.mdl")
	sprite_death = precache_model("sprites/93skull1.spr")
}

public client_connect(id){
	is_ghost[id] = false;
	use_menu[id] = false;
	use_menu_always_no[id] = false;
}

public client_disconnect(id){
	is_ghost[id] = false;
	use_menu[id] = false;
	use_menu_always_no[id] = false;
}

public CurWeapon(id){
	if(is_user_connected(id) && is_user_alive(id) && is_ghost[id]){
		if(get_user_weapon(id) != CSW_KNIFE)
			set_task(0.1,"strip_user_weap",id+TASK_STRIP);
	}
}

public event_round_start(){
	new i;
	for(i=1;i<=get_maxplayers();i++){
		if(is_ghost[i]){
			if(task_exists(i+TASK_BACK))
				remove_task(i+TASK_BACK);
				
			set_task(1.0,"back_item",i+TASK_BACK);
			
			cs_set_user_team(i,old_team[i]);
			// set_user_noclip(i);
			// set_view(i, CAMERA_NONE)
			set_user_godmode(i,0);
		}
		is_ghost[i] = false;
	}
	endround = false;
}

public strip_user_weap(id){
	id-=TASK_STRIP;
	strip_user_weapons(id);
}

public back_item(id){
	id-=TASK_BACK;
	give_item(id,"weapon_knife");

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

	if(isKnifeMap)
		return;

	if (get_user_flags(id) & ADMIN_RESERVATION)
   {
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

public ResetHUD(id){
	cs_reset_user_model(id);
	set_rendering ( id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 255 ) 
	set_task(0.5,"ghost_bonuses",id+TASK_HUD);
}

public ghost_bonuses(id){
	id-=TASK_HUD;
	
	if(!is_ghost[id] || !is_user_connected(id) && !is_user_bot(id))
		return;
	
	// Hide hud for ghost
	message_begin(MSG_ONE, g_hideHUD, _, id)
	write_byte( 1<<0 | 1<<1 | 1<<3 | 1<<4 | 1<<5 | 1<<6 )
	message_end()
	
	// set_user_noclip(id,1);
	set_user_godmode(id,1);
	cs_set_user_model(id,"ghost"); 
	
	entity_set_int(id, EV_INT_solid, SOLID_NOT)
	set_user_rendering(id, kRenderFxHologram, 0, 0, 0, kRenderTransAlpha, 125)
	// set_view(id, CAMERA_3RDPERSON);	
}

public event_round_end(){
	endround = true;
}

public DeathMsg(){
	if(endround)
		return;
		
	if(get_pcvar_num(cvar_admin) != 0){
		if(!is_user_admin(read_data(2)))
			return;
	}
	
	ghost(read_data(2));
}

public ghost(id){
	if(!is_user_connected(id) && !is_user_bot(id))
		return;
		
	if(is_user_alive(id)){
		client_print(id,print_chat,"%L",id,"USER_ALIVE");
		return;
	}
		
	if(is_ghost[id]){
		client_print(id,print_chat,"%L",id,"USER_GHOST");
		return;
	}
	
	if(endround){
		client_print(id,print_chat,"%L",id,"ROUND_END");
		return;
	}
	
	if(use_menu[id])
		set_task(3.0,"ghost_respawn",id+TASK_RESPAWN);
	else {
		if(!use_menu_always_no[id]) {
			ghost_menu(id);
		}

	}
}

public ghost_respawn(id){
	id -= TASK_RESPAWN;
	
	old_team[id] = cs_get_user_team(id);
	
	if(endround || is_user_alive(id) || is_user_bot(id) || old_team[id] == CS_TEAM_SPECTATOR || old_team[id] == CS_TEAM_UNASSIGNED)
		return;
	
	is_ghost[id] = true;
	cs_set_user_team(id,CS_TEAM_SPECTATOR);
	
	new origin[3];
	get_user_origin(id,origin);
	
	// Write death sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(sprite_death)
	write_byte(15)
	write_byte(255)
	message_end()
	
	ExecuteHamB(Ham_CS_RoundRespawn,id)	
	set_user_origin(id,origin);
}

public fw_Touch(weapon,id){
	if(!is_user_connected(id))
		return HAM_IGNORED;
		
	if(is_ghost[id])
		return HAM_SUPERCEDE;
		
	return HAM_IGNORED;
}

public ghost_menu(id){
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

public menu_handler(id, menu, item){
	if (item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)

	new key = str_to_num(s_Data)
	
	switch(key){
		case 1: ghost_respawn(id+TASK_RESPAWN)
		case 3: {
			use_menu[id] = true;
			ghost_respawn(id+TASK_RESPAWN);
		}
		case 4: use_menu_always_no[id] = true;
		default:{
			menu_destroy(menu)
			return PLUGIN_HANDLED
		}
	}

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public ghost_use_menu(id){
	if(!is_user_bot(id) && is_user_connected(id) && use_menu[id])
		use_menu[id] = false;
		use_menu_always_no[id] = false;
}

public Forward_ClientKill(id){
	if(is_ghost[id] && is_user_alive(id)){
		client_print(id,print_chat,"%L",id,"GHOST_SUICIDE");
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}  

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type){	
	if(is_user_connected(attacker) && is_ghost[attacker])
		return HAM_SUPERCEDE;
	SetHamParamFloat(4, damage)
	return HAM_IGNORED;
}

public ghostMessage(MsgID,MsgDest,id) {
	new sender = get_msg_arg_int(1);
	
	if(!is_ghost[sender])
		return PLUGIN_CONTINUE;
	
	new message[151]            //Variable for the message
	new sender_name[32]	   //Sender

	get_msg_arg_string(4, message, 150);
	get_user_name(sender, sender_name, 31);
	
	if(is_user_connected(id) && (!is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR)){
		new ghost_msg[200];
		format(ghost_msg,199,"%s%L: %s",sender_name,id,"GHOST_IN_SAY",message);
		client_print(id,print_chat,ghost_msg);
	}
	
   	return PLUGIN_HANDLED;
}

public AddToFullPack(es, e, iEnt, id, hostflags, player, pSet){ 
	if( player && iEnt == id && get_orig_retval()){
		if(is_ghost[iEnt]){
			set_es(es, ES_RenderMode, entity_get_int(id, EV_INT_rendermode)) 
			set_es(es, ES_RenderAmt, floatround(entity_get_float(id, EV_FL_renderamt))) 
		}
	} 
}

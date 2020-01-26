#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "CSO Emotion"
#define VERSION "2.3"
#define AUTHOR "Dias"

#define MAX_EMOTION 6
#define BUTTON_HOLDTIME 0.5
#define USE_TYPE 1 // 1 = J Button (Cheer); 2 = Hold R Button

#define TASK_EMOTION 1962
#define TASK_HOLDTIME 1963

new const p_model[] = "models/cso_emotion/cso_emotion2.mdl"
new const v_model[] = "models/cso_emotion/v_cso_emotion_v23.mdl"
new const Resource_Sound[MAX_EMOTION][] = 
{
	"cso_emotion/man_angry_384k.wav",
	"cso_emotion/man_dance_384k.wav",
	"cso_emotion/man_hi_384k.wav",
	"cso_emotion/man_joy_384k.wav",
	"cso_emotion/man_procoke_384k.wav",
	"cso_emotion/man_special_384k.wav"		
}

new Emotion_Name[MAX_EMOTION][] = 
{
	"Hi",
	"Provoke",
	"Joy",
	"Angry",
	"Dance",
	"Special 1 (Enzo)"
}

new Float:Emotion_Time[MAX_EMOTION] = 
{
	3.0,
	7.0,
	4.5,
	3.8,
	6.7,
	6.0
}

enum
{
	EMO_HI = 0,
	EMO_PROVOKE,
	EMO_JOY,
	EMO_ANGRY,
	EMO_DANCE,
	EMO_SPECIAL1
}

new g_InDoingEmo[33], g_AnimEnt[33], g_AvtEnt[33], g_OldWeapon[33], g_OldKnifeModel[33][128]
new g_MaxPlayers, g_HoldingButton[33], g_UseType

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_event("DeathMsg", "Event_DeathMsg", "a")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	register_forward(FM_Think, "fw_Think")
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	
	g_UseType = USE_TYPE
	if(g_UseType == 1) register_clcmd("cheer", "Open_EmoMenu")
	
	g_MaxPlayers = get_maxplayers()
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, p_model)
	engfunc(EngFunc_PrecacheModel, v_model)
	
	for(new i = 0; i < sizeof(Resource_Sound); i++)
		engfunc(EngFunc_PrecacheSound, Resource_Sound[i])
}

public Event_NewRound()
{
	for(new i = 0; i < g_MaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue
			
		Reset_Var(i)
	}
}

public Event_DeathMsg()
{
	static Victim; Victim = read_data(2)
	Do_Reset_Emotion(Victim)
}

public fw_PlayerSpawn_Post(id)
{
	//if(g_UseType == 1)
		//client_printc(id, "!g[CSO Emotion]!n Press !g[J]!n to use !tEmotion!n")
	//else if(g_UseType == 2)
		//client_printc(id, "!g[CSO Emotion]!n Hold !g[R]!n to use !tEmotion!n")
}

public Reset_Var(id)
{
	if(!is_user_connected(id))
		return
		
	if(g_InDoingEmo[id])
	{
		if(get_user_weapon(id) == CSW_KNIFE)
			set_pev(id, pev_viewmodel2, g_OldKnifeModel[id])
	}
		
	if(task_exists(id+TASK_EMOTION)) remove_task(id+TASK_EMOTION)	
		
	Set_Entity_Invisible(id, 0)
	
	if(pev_valid(g_AnimEnt[id])) engfunc(EngFunc_RemoveEntity, g_AnimEnt[id])
	if(pev_valid(g_AvtEnt[id])) engfunc(EngFunc_RemoveEntity, g_AvtEnt[id])
	
	g_InDoingEmo[id] = 0
	g_AnimEnt[id] = g_AvtEnt[id] = 0	
	g_HoldingButton[id] = 0
}

public Open_EmoMenu2(id)
{
	id -= TASK_HOLDTIME
	Open_EmoMenu(id)
}

public Open_EmoMenu(id)
{
	if(!is_user_alive(id))
		return
	if(g_InDoingEmo[id])
		return
		
	static menu, NumberId[6]
	menu = menu_create("CSO Emotion", "MenuHandle_Emo")
	
	for(new i = 0; i < MAX_EMOTION; i++)
	{
		num_to_str(i, NumberId, sizeof(NumberId))
		menu_additem(menu, Emotion_Name[i], NumberId)
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)	
}

public MenuHandle_Emo(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	if(!is_user_alive(id))
		return
	if(g_InDoingEmo[id])
		return
		
	static Data[6], Name[64], Access, Callback
	menu_item_getinfo(menu, item, Access, Data, charsmax(Data), Name, charsmax(Name), Callback)
	
	static EmoId; EmoId = str_to_num(Data)
	
	if(EmoId >= MAX_EMOTION)
		return
		
	Set_Emotion_Start(id, EmoId)
}

public Set_Emotion_Start(id, EmoId)
{
	g_InDoingEmo[id] = 1
	Set_Entity_Invisible(id, 1)
	
	Create_AvtEnt(id)
	Create_AnimEnt(id)
	
	if(!Check_Avalible(id)) return
	
	Do_Set_Emotion(id, EmoId)
}

public Create_AvtEnt(id)
{
	if(pev_valid(g_AvtEnt[id]))
		return
	
	g_AvtEnt[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if(!pev_valid(g_AvtEnt[id])) 
		return	
	
	static ent; ent = g_AvtEnt[id]
	set_pev(ent, pev_classname, "avatar")
	set_pev(ent, pev_owner, id)
	set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(ent, pev_solid, SOLID_NOT)

	// Set Model
	static PlayerModel[64]
	fm_cs_get_user_model(id, PlayerModel, sizeof(PlayerModel))
	
	format(PlayerModel, sizeof(PlayerModel), "models/player/%s/%s.mdl", PlayerModel, PlayerModel)
	engfunc(EngFunc_SetModel, g_AvtEnt[id], PlayerModel)	
	
	// Set Avatar
	set_pev(ent, pev_body, pev(id, pev_body))
	set_pev(ent, pev_skin, pev(id, pev_skin))
	
	set_pev(ent, pev_renderamt, pev(id, pev_renderamt))
	static Float:Color[3]; pev(id, pev_rendercolor, Color)
	set_pev(ent, pev_rendercolor, Color)
	set_pev(ent, pev_renderfx, pev(id, pev_renderfx))
	set_pev(ent, pev_rendermode, pev(id, pev_rendermode))
	
	Set_Entity_Invisible(ent, 0)
}

public Create_AnimEnt(id)
{
	if(pev_valid(g_AnimEnt[id]))
		return
			
	g_AnimEnt[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	if(!pev_valid(g_AnimEnt[id])) 
		return
		
	static ent; ent = g_AnimEnt[id]
	set_pev(ent, pev_classname, "AnimEnt")
	set_pev(ent, pev_owner, id)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	
	engfunc(EngFunc_SetModel, ent, p_model)
	engfunc(EngFunc_SetSize, ent, {-16.0, -16.0, 0.0}, {16.0, 16.0, 72.0})
	set_pev(ent, pev_solid, SOLID_BBOX)
	
	engfunc(EngFunc_DropToFloor, ent)
	Set_Entity_Invisible(ent, 0)
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)
}

public Check_Avalible(id)
{
	if(!pev_valid(g_AnimEnt[id]) || !pev_valid(g_AvtEnt[id]))
	{
		Do_Reset_Emotion(id)
		return 0
	}
		
	return 1
}

public Do_Set_Emotion(id, EmoId)
{
	// Set Player Emotion
	static Float:Origin[3], Float:Angles[3], Float:Velocity[3]
		
	pev(id, pev_origin, Origin); pev(id, pev_angles, Angles); pev(id, pev_velocity, Velocity)
		
	Origin[2] -= 36.0
	set_pev(g_AnimEnt[id], pev_origin, Origin)
		
	Angles[0] = 0.0; Angles[2] = 0.0
	set_pev(g_AnimEnt[id], pev_angles, Angles)
	set_pev(g_AnimEnt[id], pev_velocity, Velocity)
		
	set_pev(g_AvtEnt[id], pev_aiment, g_AnimEnt[id])
	Set_Entity_Anim(g_AnimEnt[id], EmoId, 1)
	
	// Set Hand Emotion
	g_OldWeapon[id] = get_user_weapon(id)
	fm_give_item(id, "weapon_knife")
	engclient_cmd(id, "weapon_knife")
	
	pev(id, pev_viewmodel2, g_OldKnifeModel[id], 127)
	set_pev(id, pev_viewmodel2, v_model)
	Set_Weapon_Anim(id, EmoId)
	
	static KnifeEnt; KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE)
	if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, Emotion_Time[EmoId], 4)
	
	if(task_exists(id+TASK_EMOTION)) remove_task(id+TASK_EMOTION)
	set_task(Emotion_Time[EmoId], "Reset_Emotion", id+TASK_EMOTION)
}

public Reset_Emotion(id)
{
	id -= TASK_EMOTION
	
	if(!is_user_connected(id))
		return
	if(!g_InDoingEmo[id])
		return
		
	Do_Reset_Emotion(id)
}

public Do_Reset_Emotion(id)
{
	if(!is_user_connected(id))
		return
	if(!g_InDoingEmo[id])
		return
		
	if(task_exists(id+TASK_EMOTION)) remove_task(id+TASK_EMOTION)
	Set_Entity_Invisible(id, 0)
	
	if(pev_valid(g_AnimEnt[id])) engfunc(EngFunc_RemoveEntity, g_AnimEnt[id])
	if(pev_valid(g_AvtEnt[id])) engfunc(EngFunc_RemoveEntity, g_AvtEnt[id])
	
	g_AnimEnt[id] = g_AvtEnt[id] = 0
	
	if(is_user_alive(id))
	{
		if(get_user_weapon(id) == CSW_KNIFE)
			set_pev(id, pev_viewmodel2, g_OldKnifeModel[id])
		
		static MyOldWeapon; MyOldWeapon = g_OldWeapon[id]
		static Classname[64]; get_weaponname(MyOldWeapon, Classname, sizeof(Classname))
		engclient_cmd(id, Classname)
	}
	
	g_InDoingEmo[id] = 0
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id))
		return

	
	if(!g_InDoingEmo[id] && g_UseType == 2)
	{
		static UseButton, UseOldButton
		UseButton = (get_uc(uc_handle, UC_Buttons) & IN_RELOAD)
		UseOldButton = (pev(id, pev_oldbuttons) & IN_RELOAD)
		
		if(UseButton)
		{
			if(!UseOldButton && !g_InDoingEmo[id])
			{
				g_HoldingButton[id] = 1
				set_task(BUTTON_HOLDTIME, "Open_EmoMenu2", id+TASK_HOLDTIME)
			}
		} else {
			if(UseOldButton && g_HoldingButton[id])
			{
				if(task_exists(id+TASK_HOLDTIME)) 
				{
					remove_task(id+TASK_HOLDTIME)
					g_HoldingButton[id] = 0
				}
			}
		}	
		
		return
	}
		
	static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
	
	if((CurButton & IN_ATTACK) || (CurButton & IN_ATTACK2) || (CurButton & IN_DUCK) || (CurButton & IN_JUMP))
	{
		Do_Reset_Emotion(id)
		return
	}
	
	static Float:Velocity[3], Float:Vector
	pev(id, pev_velocity, Velocity); Vector = vector_length(Velocity)
	
	if(Vector != 0.0)
	{
		Do_Reset_Emotion(id)
		return
	}
	
	/*
	if(get_user_weapon(id) != CSW_KNIFE)
	{
		Do_Reset_Emotion(id)
		return
	}*/
}

public fw_AddToFullPack_Post(es_handle, e , ent, host, hostflags, player, pSet)
{
	if(!is_user_alive(host) && !pev_valid(ent))
		return FMRES_IGNORED
	if(g_AnimEnt[host] != ent)
		return FMRES_IGNORED
			
	set_es(es_handle, ES_Effects, get_es(es_handle, ES_Effects) | EF_NODRAW)
	return FMRES_IGNORED
}

public fw_Think(ent)
{
	if(!pev_valid(ent))
		return
		
	static Classname[64]
	pev(ent, pev_classname, Classname, sizeof(Classname))
	
	if(equal(Classname, "AnimEnt"))
	{
		static id; id = pev(ent, pev_owner)
		if(!is_user_alive(id))
			return
			
		// Set Player Emotion
		static Float:Angles[3], Float:Angles2[3]
		
		pev(id, pev_angles, Angles)
		pev(ent, pev_angles, Angles2)
		
		Angles[0] = 0.0; Angles[2] = 0.0
		
		if(Angles[1] != Angles2[1]) set_pev(ent, pev_angles, Angles)
		set_pev(ent, pev_nextthink, get_gametime() + 0.05)
		
		if(pev(ent, pev_effects) == (pev(ent, pev_effects) | EF_NODRAW)) Set_Entity_Invisible(ent, 0)
	}
}

stock fm_cs_get_user_model(id, Model[], Len)
{
	if(!is_user_connected(id))
		return
		
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", Model, Len)
}

stock Set_Entity_Invisible(ent, Invisible = 1)
{
	if(!pev_valid(ent))
		return
		
	set_pev(ent, pev_effects, Invisible == 0 ? pev(ent, pev_effects) & ~EF_NODRAW : pev(ent, pev_effects) | EF_NODRAW)
}

stock Set_Entity_Anim(ent, Anim, ResetFrame)
{
	if(!pev_valid(ent))
		return
		
	set_pev(ent, pev_animtime, get_gametime())
	set_pev(ent, pev_framerate, 1.0)
	set_pev(ent, pev_sequence, Anim)
	if(ResetFrame) set_pev(ent, pev_frame, 0)
}


stock Set_Weapon_Anim(id, Anim)
{
	if(!is_user_alive(id))
		return
		
	set_pev(id, pev_weaponanim, Anim)

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(Anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock client_printc(index, const text[], any:...)
{
	new szMsg[128];
	vformat(szMsg, sizeof(szMsg) - 1, text, 3);

	replace_all(szMsg, sizeof(szMsg) - 1, "!g", "^x04");
	replace_all(szMsg, sizeof(szMsg) - 1, "!n", "^x01");
	replace_all(szMsg, sizeof(szMsg) - 1, "!t", "^x03");

	if(index == 0)
	{
		for(new i = 0; i < g_MaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, i)
			write_byte(i)
			write_string(szMsg)
			message_end()
		}		
	} else {
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, index);
		write_byte(index);
		write_string(szMsg);
		message_end();
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

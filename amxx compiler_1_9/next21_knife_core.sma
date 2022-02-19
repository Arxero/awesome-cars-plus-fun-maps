#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <fun>
#include <hud>
#include <dhudmessage>
#include <WPMGPrintChatColor>
#include <next21_to_Core>

#define PLUGIN	"Server"
#define AUTHOR	"trofian"
#define VERSION	"1.2"

#define Player[%1][%2]			g_player_data[%1 - 1][%2]
#define Lang[%1]			g_lang_data[%1]

#define get_gun_owner(%1)		get_pdata_cbase(%1, 41, 4)
#define get_gun_in_hand(%1)		get_pdata_cbase(%1, 373, 5)
#define is_entity_player(%1)		(1<=%1<=g_maxplayers)
#define is_valid_knife(%1)		(0<=%1<total_knifes)

#define TASKID 133721

#define LANG_SIZE			128
#define KNIFE_NONE			-1

#define c_class_string 			32
#define c_class_description 		128
#define c_class_chatdescription 	190
#define c_item_string_menu 		64
#define c_item_string_chat 		190
#define c_custom_item_max_txt		64

#define VIP_FLAG			ADMIN_LEVEL_H // флаг t
#define RESET_ABIL_AFTER_SPAWN	5.0

//#define REMOVE_STRIP_ENT

enum _:Crosshair_States
{
	CrossOff,			// выключен совсем
	CrossHide,			// просто спрятан
	CrossDefault,			// стандартный, белый
	CrossCannot,			// красный, нельзя использовать абилити (хз по каким причинам)
	CrossFar,			// красный, цель слишком далеко
	CrossTime,			// крсаный, время перезарядки ещё не вышло
	CrossOk				// можно использовать абилити
}

enum _:Player_Properties
{
	Knife,			// нож игрока
	WasChanged,		// был ли сменён нож в этом текущем раунде
	Crosshair		// состояние прицела игрока Crosshair_State
}

enum _:Lang_Properties
{
	L_ItemAlreadyHave,
	L_ItemNotAvailable,
	L_ItemDead,
	L_ItemAlive,
	L_KnifeNextRound,
	L_KnifeAlreadyHave,
	L_DHUD_Spawn
}

new
g_player_data[32][Player_Properties],
g_lang_data[Lang_Properties][LANG_SIZE]

new

// массивы с информацией о ножах
Array:KnifeTxt, Array:KnifeDescription, Array:KnifeChatDescription, Array:KnifeAbilCallback, Array:KnifeAbilResetTime,
Array:KnifeAbilMinDist, Array:KnifeAbilMaxDist, Array:KnifePropHp, Array:KnifePropSpeed, Array:KnifePropGravity,
Array:ShopItemMenuText, Array:ShopItemChatText, Array:ShopItemCallback, Array:ShopItemCost, Array:CustomMenuItemTXT,
Array:CustomMenuItemCallback, Array:CustomMenuItemMenuKey,

// время, когда игрок в последний раз использовал нож
Float:g_PlayerLastUsedAbility[33],
g_iMainMenu, g_iShopMenu,
g_syncHudMessage, // 3 канал, отсчёт секунд до перезарядки
g_maxplayers,

// мессаги
g_msgHideWeapon,

// форварды
forward_abil_pre, forward_abil_post, forward_core_change_knife_pre, forward_core_change_knife_post,

// сколько у нас всего ножей
total_knifes,

// если сейчас перезарядка
bool:in_reloading[33],

g_custom_menu_count

public plugin_natives()
{
	// для создания собственных слассов ножей
	register_native("kc_register_knife", "_21kc_register_knife", 0)
	
	// регестрирует шоп
	register_native("kc_register_shop_item", "_21kc_register_shop", 0)
	
	// регестрирует дополнительный пункт в главном меню
	register_native("kc_register_custom_menu_item", "_21kc_register_cust_menu", 0)
	
	// чтоб получить класс ножа у конкретного игрока
	register_native("kc_set_user_knife", "_21kc_user_set_knife", 0)
	register_native("kc_get_user_knife", "_21kc_user_get_knife", 0)
	
	// возвращает время (gametime) когда в последний раз было использовано ability 
	register_native("kc_get_ability_last_reset", "_21kc_get_ability_last_reset", 0)
	
	// возвращает массив с информацией о классе ножа, точнее 1 - id ножа | "время перезарядки абилити" "минимально расстояние для работы абилити" "максимальное расстояние для работы абилити"
	register_native("kc_get_info_ability", "_21kc_get_info_ability", 0)
	
	// устанавливает определённый прицел
	register_native("kc_set_crosshair", "_21kc_set_crosshair", 0)
	
	// возвращает состояние из массива g_CrosshairKnifeState
	register_native("kc_get_crosshair", "_21kc_get_crosshair", 0)
	
	// сбрасывает значение гравитации на стандартное для текущего ножа
	register_native("kc_reset_speed", "_21kc_reset_speed", 0)
	
	// сбрасывает значение скорости на стандартное для текущего ножа
	register_native("kc_reset_gravity", "_21kc_reset_gravity", 0)
	
	// получает стандаротное кол-во хп игрока, зависит от ножа
	register_native("kc_get_user_max_hp", "_21kc_get_user_max_hp", 0)
	
	// возвращает true, если абилити у игрока перезаряжается
	register_native("kc_in_reloading", "_21kc_in_reloading", 0)
}

public plugin_precache()
{
	precache_generic("sprites/next21_knife_v2/chair/n21_hud_cannot.spr")
	precache_generic("sprites/next21_knife_v2/chair/n21_hud_default.spr")
	precache_generic("sprites/next21_knife_v2/chair/n21_hud_far.spr")
	precache_generic("sprites/next21_knife_v2/chair/n21_hud_ok.spr")
	precache_generic("sprites/next21_knife_v2/chair/n21_hud_time.spr")
	
	precache_generic("sprites/next21_knife_v2/hud/next21_hud1.spr")
	precache_generic("sprites/next21_knife_v2/hud/next21_hud2.spr")
	precache_generic("sprites/next21_knife_v2/hud/next21_hud3.spr")
	precache_generic("sprites/next21_knife_v2/hud/next21_hud1_ammo.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	forward_abil_pre = CreateMultiForward("kc_ability_pre", ET_STOP, FP_CELL, FP_CELL)
	forward_abil_post = CreateMultiForward("kc_ability_post", ET_STOP, FP_CELL, FP_CELL)
	forward_core_change_knife_pre = CreateMultiForward("kc_change_knife_core_pre", ET_STOP, FP_CELL, FP_CELL)
	forward_core_change_knife_post = CreateMultiForward("kc_change_knife_core_post", ET_STOP, FP_CELL, FP_CELL)
	
	KnifeTxt		 	= ArrayCreate(c_class_string)
	KnifeDescription 		= ArrayCreate(c_class_description)
	KnifeChatDescription		= ArrayCreate(c_class_chatdescription)
	KnifeAbilCallback		= ArrayCreate()
	KnifeAbilResetTime		= ArrayCreate()
	KnifeAbilMinDist		= ArrayCreate()
	KnifeAbilMaxDist		= ArrayCreate()
	
	KnifePropHp			= ArrayCreate()
	KnifePropGravity		= ArrayCreate()
	KnifePropSpeed			= ArrayCreate()
	
	ShopItemMenuText		= ArrayCreate(c_item_string_menu)
	ShopItemChatText		= ArrayCreate(c_item_string_chat)
	ShopItemCallback		= ArrayCreate()
	ShopItemCost			= ArrayCreate()
	
	CustomMenuItemTXT		= ArrayCreate(c_custom_item_max_txt)
	CustomMenuItemCallback		= ArrayCreate()
	CustomMenuItemMenuKey		= ArrayCreate(32)
	
	register_clcmd("kc_menu", "show_knifes_menu")
	register_clcmd("nightvision", "show_shop_menu")
	//register_clcmd("kc_shop_menu", "show_shop_menu")
	
	register_clcmd("say /knife", "show_knifes_menu")
	register_clcmd("say_team /knife", "show_knifes_menu")
	
	register_clcmd("say knife", "show_knifes_menu")
	register_clcmd("say_team knife", "show_knifes_menu")
	
	register_clcmd("say /knifes", "show_knifes_menu")
	register_clcmd("say_team /knifes", "show_knifes_menu")
	
	register_clcmd("say knifes", "show_knifes_menu")
	register_clcmd("say_team knifes", "show_knifes_menu")
	
	register_clcmd("say /menu", "show_knifes_menu")
	register_clcmd("say_team /menu", "show_knifes_menu")
	
	register_clcmd("say menu", "show_knifes_menu")
	register_clcmd("say_team menu", "show_knifes_menu")
	
	register_clcmd("say /shop", "show_shop_menu")
	register_clcmd("say_team /shop", "show_shop_menu")
	
	register_clcmd("say shop", "show_shop_menu")
	register_clcmd("say_team shop", "show_shop_menu")
	
	register_clcmd("say shopmenu", "show_shop_menu")
	register_clcmd("say_team shopmenu", "show_shop_menu")
	
	register_clcmd("say /shopmenu", "show_shop_menu")
	register_clcmd("say_team /shopmenu", "show_shop_menu")
	
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "HAM_Secondary", 1)
	RegisterHam(Ham_Spawn, "player", "HAM_Player_Spawn", 1)
	RegisterHam(Ham_Killed, "player", "HAM_Player_killed", 1)
	RegisterHam(Ham_Player_PreThink, "player", "Ham_PreThink_player")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "hook_knife_deploy_post", 1)
	
	register_event("CurWeapon", "CurWeapon", "be","1=1")
	register_event("HLTV", "HLTV", "a", "1=0", "2=0")
	
	register_logevent("RoundStart", 2, "1=Round_Start")
	
	g_syncHudMessage = CreateHudSyncObj()
	
	set_task(0.3, "create_knife_menu")
	set_task(0.3, "create_shop_menu")
	
	g_maxplayers = get_maxplayers()
	
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	
	register_dictionary("next21_knife.txt")
	
	format(Lang[L_ItemAlreadyHave], LANG_SIZE-1, "%L", LANG_PLAYER, "ITEM_RET_HAVE")
	format(Lang[L_ItemNotAvailable], LANG_SIZE-1, "%L", LANG_PLAYER, "ITEM_RET_NOT")
	format(Lang[L_ItemDead], LANG_SIZE-1, "%L", LANG_PLAYER, "ITEM_RET_DEAD")
	format(Lang[L_ItemAlive], LANG_SIZE-1, "%L", LANG_PLAYER, "ITEM_RET_ALIVE")
	
	format(Lang[L_KnifeNextRound], LANG_SIZE-1, "%L", LANG_PLAYER, "KNIFE_NEXT_ROUND")
	format(Lang[L_KnifeAlreadyHave], LANG_SIZE-1, "%L", LANG_PLAYER, "KNIFE_ALREADY_HAVE")
	
	format(Lang[L_DHUD_Spawn], LANG_SIZE-1,"%L", LANG_PLAYER, "DHUD_BUY")
	
	#if defined REMOVE_STRIP_ENT
	set_task(0.5, "del_player_weaponstrip")
	#endif
}

#if defined REMOVE_STRIP_ENT
public del_player_weaponstrip()
{
	new ent = -1
	
	while((ent = find_ent_by_target(ent, "player_weaponstrip")))
	{
		remove_entity(ent)
		
		server_print("[%s] The player_weaponstrip was removed (id %d)", PLUGIN, ent)
	}
}
#endif

public hook_knife_deploy_post(gun)
{
	static id
	id = get_gun_owner(gun)
	
	if(!is_valid_knife(Player[id][Knife]))
		return
	
	static txt[c_class_string+4]
	ArrayGetString(KnifeTxt, Player[id][Knife], txt, charsmax(txt))
	
	if(equal(txt, "NULL", 4))
	{
		SetKnifeCrosshair(id, 0, CrossOff)
		n21_hud_change_to(id, "weapon_knife", "weapon_knife")
		return
	}	
	
	if(isCrossKnifeFullOff(id))
	{
		SetKnifeCrosshair(id, 0, CrossOff)
		n21_hud_change_to(id, "weapon_knife", txt)
		return
	}
	
	add(txt, charsmax(txt), "_def")
	SetKnifeCrosshair(id, 1, CrossDefault)
	n21_hud_change_to(id, "weapon_knife", txt)
}

//<Ability callback
public HAM_Secondary(gun)
{
	if(pev_valid(gun) != 2)
		return HAM_IGNORED
	
	static id, victim, body
	static Float:MinDist, Float:MaxDist
	static fwReturn_pre, abilReturn, fwReturn_post
	
	id = get_pdata_cbase(gun, 41, 4)
	
	if(g_PlayerLastUsedAbility[id] > get_gametime() || !is_user_alive(id))
		return HAM_IGNORED
	
	get_user_aiming(id, victim, body)
 
	if(!is_entity_player(victim))
		victim = -1
	else if(get_user_team(id) == get_user_team(victim))
		return HAM_IGNORED
	
	MinDist = ArrayGetCell(KnifeAbilMinDist, Player[id][Knife])
	MaxDist = ArrayGetCell(KnifeAbilMaxDist, Player[id][Knife])
	
	if(MinDist != -1.0 && MaxDist != -1.0 && !ka_is_thunder(id))
		if(victim == -1 || !(MinDist <= entity_range(id, victim) <= MaxDist))
			return HAM_IGNORED
	
	fwReturn_pre = PLUGIN_CONTINUE
	ExecuteForward(forward_abil_pre, fwReturn_pre, id, victim)
	if(fwReturn_pre == PLUGIN_HANDLED)
		return HAM_IGNORED
	
	ExecuteForward(ArrayGetCell(KnifeAbilCallback, Player[id][Knife]), abilReturn, id, victim)
	
	if(abilReturn != PLUGIN_HANDLED && abilReturn != PLUGIN_HANDLED_MAIN)
	{
		static Float:fSeconds, szSeconds[11], seconds
		
		fSeconds = ArrayGetCell(KnifeAbilResetTime, Player[id][Knife])
		float_to_str(fSeconds, szSeconds, charsmax(szSeconds))
		seconds = str_to_num(szSeconds)
		
		static divider
		
		if(ka_Zeus(id))
			divider = 10
		else
		{
			if(get_user_flags(id) & VIP_FLAG)
				divider = 2
			else
				divider = 1
		}
		
		static args[2]
		args[0] = id
		args[1] = seconds/divider
		set_task(0.0, "readout_hud", TASKID+id, args, 2)
		
		g_PlayerLastUsedAbility[id] = fSeconds/float(divider) + get_gametime()
		
		return HAM_IGNORED
	}

	ExecuteForward(forward_abil_post, fwReturn_post, id, victim)
	
	return HAM_IGNORED
}

public HAM_Player_Spawn(id)
{
	if(!is_user_alive(id))
		return
	
	if(Player[id][Knife] == KNIFE_NONE)
	{
		Player[id][Knife] = random_num(0, ArraySize(KnifeDescription)-1)
		Player[id][Knife] = random_num(0, ArraySize(KnifeDescription)-1)
		if(!is_user_bot(id))
			show_knifes_menu(id)
	}
	
	reset_glow(id)
	strip_and_give(id)
	
	set_task(1.0, "set_hp", id)
	set_task(1.0, "set_speed", id)
	set_task(1.0, "set_gravity", id)
	set_task(1.5, "show_dhud", id)
	
	remove_task(TASKID+id)
	g_PlayerLastUsedAbility[id] = get_gametime() + RESET_ABIL_AFTER_SPAWN
	
	static args[2]
	args[0] = id
	args[1] = floatround(RESET_ABIL_AFTER_SPAWN)
	set_task(0.0, "readout_hud", TASKID+id, args, 2)
	
	Player[id][WasChanged] = 0
}

public HAM_Player_killed(id)
	Player[id][Crosshair] = CrossOff

//<Hud if is
public Ham_PreThink_player(id)
{	
	if(ka_is_thunder(id))
		return
	
	if(Player[id][Crosshair] == CrossOff)
		return
	
	if(!is_user_alive(id))
		return
	
	if(get_user_weapon(id) != CSW_KNIFE || !is_valid_knife(Player[id][Knife]))
	{
		if(Player[id][Crosshair] > CrossHide)
			SetKnifeCrosshair(id, 0)
		return
	}
	
	static victim, body
	get_user_aiming(id, victim, body)
	
	static Float:MinDist, Float:MaxDist
	MinDist = ArrayGetCell(KnifeAbilMinDist, Player[id][Knife])
	MaxDist = ArrayGetCell(KnifeAbilMaxDist, Player[id][Knife])
	
	if(g_PlayerLastUsedAbility[id] >= get_gametime())
		SetKnifeCrosshair(id, 1, CrossTime)
	else if(!is_entity_player(victim) || get_user_team(id) == get_user_team(victim))
		SetKnifeCrosshair(id, 1)
	else if(!(MinDist <= entity_range(id, victim) <= MaxDist))
		SetKnifeCrosshair(id, 1, CrossFar)
	else if(Player[id][Crosshair] == CrossCannot)
		return
	else
		SetKnifeCrosshair(id, 1, CrossOk)
}

SetKnifeCrosshair(id, hide, cross=CrossDefault) // hide: 0 - скрыть прицел, 1 - показать;
{
	if(!is_entity_player(id))
		return
	
	// MSG_ONE_UNRELIABLE
	// пох, не так часто и вызыается	
	message_begin(MSG_ONE, g_msgHideWeapon, _, id)
	if(hide) write_byte(1<<7)
	else write_byte(1>>7)
	message_end()
	
	if(!hide)
	{
		if(cross == CrossOff)
			Player[id][Crosshair] = CrossOff
		else
			Player[id][Crosshair] = CrossHide
		return
	}
		
	static knife_txt[c_class_string+4]
	ArrayGetString(KnifeTxt, Player[id][Knife], knife_txt, charsmax(knife_txt))
	
	switch(cross)
	{
		case CrossDefault: formatex(knife_txt, charsmax(knife_txt), "%s_def", knife_txt)
		case CrossCannot: formatex(knife_txt, charsmax(knife_txt), "%s_cnot", knife_txt)
		case CrossFar: formatex(knife_txt, charsmax(knife_txt), "%s_far", knife_txt)
		case CrossTime: formatex(knife_txt, charsmax(knife_txt), "%s_time", knife_txt)
		case CrossOk: formatex(knife_txt, charsmax(knife_txt), "%s_ok", knife_txt)
	}
	
	if(Player[id][Crosshair] != cross)
		n21_hud_change_to(id, "weapon_knife", knife_txt)
	
	Player[id][Crosshair] = cross
}

isCrossKnifeFullOff(id)
{
	static Float:MinDist, Float:MaxDist
	MinDist = ArrayGetCell(KnifeAbilMinDist, Player[id][Knife])
	MaxDist = ArrayGetCell(KnifeAbilMaxDist, Player[id][Knife])
	
	if(MinDist == -1.0 && MaxDist == -1.0)
		return 1
	
	return 0
}

strip_and_give(id)
{
	engclient_cmd(id, "weapon_knife")
	
	static gun_in_hand
	gun_in_hand = get_gun_in_hand(id)
	if(gun_in_hand != -1)
	{
		ExecuteHamB(Ham_Item_Deploy, get_gun_in_hand(id))
		emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	static knife_txt[c_class_string]
	ArrayGetString(KnifeTxt, Player[id][Knife], knife_txt, charsmax(knife_txt))
		
	if(!isCrossKnifeFullOff(id))
		SetKnifeCrosshair(id, 1)
	else
		SetKnifeCrosshair(id, 0)
}

public set_hp(id)
{
	if(!is_user_alive(id))
		return
	
	if(Player[id][Knife] == -1)
	{
		set_user_health(id, 100)
		return
	}
	
	set_user_health(id, ArrayGetCell(KnifePropHp, Player[id][Knife]))
}

public set_speed(id)
{
	if(!is_user_alive(id))
		return
	
	if(Player[id][Knife] == -1)
		return
	
	set_user_maxspeed(id, ArrayGetCell(KnifePropSpeed, Player[id][Knife]))
}

public set_gravity(id)
{
	if(!is_user_alive(id))
		return
	
	if(Player[id][Knife] == -1)
		return
	
	set_user_gravity(id, ArrayGetCell(KnifePropGravity, Player[id][Knife]))
}

public show_dhud(id)
{
	set_dhudmessage(11, 218, 81, -1.0, 0.70, 0, 1.0, 4.0, 0.1, 2.0)
	show_dhudmessage(id, "%s", Lang[L_DHUD_Spawn])
}	

public reset_glow(id) if(is_user_alive(id)) set_user_rendering(id)

public HLTV()
{
	for(new i=1; i<=g_maxplayers; i++)
		Player[i][WasChanged] = 0
}

public RoundStart()
{
	static i
	for(i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_alive(i)) continue
		set_task(0.2, "set_speed", i)
	}
}

//<Main Menu
public create_knife_menu()
{
	g_iMainMenu = menu_create("\yMain Menu [\rPrivateServ.INFO\y]", "knifes_menu_handler")
	
	new iSize = ArraySize(KnifeDescription)
	new sTmpBuffer[c_class_description]
	new sNumStr[11]
	
	for(new i; i < iSize; i++)
	{
		ArrayGetString(KnifeDescription, i, sTmpBuffer, charsmax(sTmpBuffer))
		num_to_str(i+1, sNumStr, charsmax(sNumStr))
		
		if(i == iSize-1)
			format(sTmpBuffer, charsmax(sTmpBuffer), "%s^n", sTmpBuffer)
		
		menu_additem(g_iMainMenu, sTmpBuffer, sNumStr, 0)
	}
	
	new shop_name[64]
	formatex(shop_name, charsmax(shop_name), "%L", LANG_PLAYER, "SHOP_NAME")
	menu_additem(g_iMainMenu, shop_name, "1337", 0)
	
	new sTmpBuffer2[c_custom_item_max_txt]
	new sNumStr2[11]
	for(new i; i < ArraySize(CustomMenuItemTXT); i++)
	{
		ArrayGetString(CustomMenuItemTXT, i, sTmpBuffer2, charsmax(sTmpBuffer2))
		ArrayGetString(CustomMenuItemMenuKey, i, sNumStr2, charsmax(sNumStr2))
		
		menu_additem(g_iMainMenu, sTmpBuffer2, sNumStr2, 0)
	}
		
	//menu_setprop(g_iMainMenu, MPROP_PERPAGE, 0)
	menu_setprop(g_iMainMenu, MPROP_NEXTNAME, "Next")
	menu_setprop(g_iMainMenu, MPROP_BACKNAME, "Back")
	menu_setprop(g_iMainMenu, MPROP_EXITNAME, "Exit")
	menu_setprop(g_iMainMenu, MPROP_EXIT, MEXIT_ALL)
}

public show_knifes_menu(id)
{
	//menu_setprop(g_iMainMenu, MPROP_PERPAGE, 0)
	menu_display(id, g_iMainMenu, 0)
	
	return PLUGIN_HANDLED
}

public knifes_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED
	
	static s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	
	static key, mreturn, strkey[11]
	key = str_to_num(s_Data)
	
	for(new i; i < ArraySize(CustomMenuItemCallback); i++)
	{
		ArrayGetString(CustomMenuItemMenuKey, i, strkey, charsmax(strkey))
		if(str_to_num(strkey) == key)
		{
			ExecuteForward(ArrayGetCell(CustomMenuItemCallback, i), mreturn, id)
			return PLUGIN_CONTINUE
		}
	}
	
	if(key == 1337)
	{
		show_shop_menu(id)
		return PLUGIN_CONTINUE
	}
	
	change_knife_core(id, key-1)
	
	return PLUGIN_CONTINUE
}
//</Main Menu

//<Shop Menu
public create_shop_menu()
{
	g_iShopMenu = menu_create("\yShop Menu [\rPrivateServ.info\y]", "shop_menu_handler")
	
	new iSize = ArraySize(ShopItemMenuText)
	new sTmpBuffer[c_item_string_menu]
	new sTmpBufferAdd[c_item_string_menu+32]
	new sNumStr[11]
	
	for(new i; i < iSize; i++)
	{
		ArrayGetString(ShopItemMenuText, i, sTmpBuffer, charsmax(sTmpBuffer))
		num_to_str(i+1, sNumStr, charsmax(sNumStr))
		
		format(sTmpBufferAdd, charsmax(sTmpBufferAdd), "\y[\r$%d\y] \y%s", ArrayGetCell(ShopItemCost, i), sTmpBuffer)
		
		menu_additem(g_iShopMenu, sTmpBufferAdd, sNumStr, 0)
	}
	
	menu_setprop(g_iShopMenu, MPROP_NEXTNAME, "Next")
	menu_setprop(g_iShopMenu, MPROP_BACKNAME, "Back")
	menu_setprop(g_iShopMenu, MPROP_EXITNAME, "Exit")
	menu_setprop(g_iShopMenu, MPROP_EXIT, MEXIT_ALL)
}

public show_shop_menu(id)
{
	menu_display(id, g_iShopMenu, 0)
	
	return PLUGIN_HANDLED
}

public shop_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED
	
	static s_Data[6], s_Name[64], i_Access, i_Callback
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
	
	static i_Key, player_money, item_cost
	static callbackId, result
	
	i_Key = str_to_num(s_Data)-1
	
	player_money = cs_get_user_money(id)
	item_cost = ArrayGetCell(ShopItemCost, i_Key)
	
	if(player_money < item_cost)
	{
		PrintChatColor(id, _, "!g[%s] !y%L", PLUGIN, LANG_PLAYER, "ITEM_NOT_MONEY")
		return PLUGIN_HANDLED
	}
	
	callbackId = ArrayGetCell(ShopItemCallback, i_Key)
	ExecuteForward(callbackId, result, id)
	
	switch(result)
	{
		case 0..3: PrintChatColor(id, _, "!g[%s] !y%s", PLUGIN, Lang[result])
	}
	
	if(result > -1) return PLUGIN_CONTINUE
	
	cs_set_user_money(id, player_money-item_cost)
	
	static chat_string[c_item_string_chat]
	ArrayGetString(ShopItemChatText, i_Key, chat_string, charsmax(chat_string))
	
	PrintChatColor(id, _, "!g[%s] !y%s", PLUGIN, chat_string)
	
	return PLUGIN_CONTINUE
}
//<Shop Menu

public client_connect(id)
{
	//client_cmd(id, "bind n ^"nightvision;kc_shop_menu^"")
	client_cmd(id, "bind b ^"buy;kc_menu^"")
	client_cmd(id, "cl_backspeed %d; cl_forwardspeed %d; cl_sidespeed %d", 400, 400, 400)
	Player[id][Knife] = -1
	Player[id][WasChanged] = 0
}

// <Счётчик
public readout_hud(put_args[])
{
	static id, second
	id = put_args[0]
	second = put_args[1]

	static i
	for(i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i))
			continue
		
		if(pev(i, pev_iuser2) == id)
		{
			if(second == 0)
			{
				set_hudmessage(255, 255, 255, 0.01, 0.73, 0, 0.0, 1.1, 0.0, 0.0, 3) // 3 - канал
ShowSyncHudMsg(i, g_syncHudMessage, "Reloading is over!", second)
}
else
{
set_hudmessage(255, 255, 255, 0.01, 0.73, 0, 0.0, 1.1, 0.0, 0.0, 3)
ShowSyncHudMsg(i, g_syncHudMessage, "Reloading %d sec.", second)
}
}
}

if(second == 0)
{
set_hudmessage(255, 255, 255, 0.01, 0.73, 0, 0.0, 1.1, 0.0, 0.0, 3) // 3 - ?????
ShowSyncHudMsg(id, g_syncHudMessage, "Reloading is over!", second)

		in_reloading[id] = false
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(id))
	{
		in_reloading[id] = false
		return PLUGIN_HANDLED
	}
	
	set_hudmessage(255, 255, 255, 0.01, 0.73, 0, 0.0, 1.1, 0.0, 0.0, 3)
	ShowSyncHudMsg(id, g_syncHudMessage, "Reloading %d sec.", second)
	second--
	
	static args[2]
	args[0] = id
	args[1] = second
	in_reloading[id] = true
	set_task(1.0, "readout_hud", TASKID+id, args, 2)
	
	return PLUGIN_CONTINUE
}
// </Счётчик

public CurWeapon(id) set_speed(id)

public change_knife_core(id, knifeId)
{
	new fwReturn_pre = PLUGIN_CONTINUE
	ExecuteForward(forward_core_change_knife_pre, fwReturn_pre, id, knifeId)
	if(fwReturn_pre == PLUGIN_HANDLED)
		return PLUGIN_HANDLED
	
	if(Player[id][WasChanged] && is_user_alive(id))
	{
		PrintChatColor(id, _, "!g[%s] !y%s", PLUGIN, Lang[L_KnifeNextRound])
		return PLUGIN_HANDLED
	}
	
	if(Player[id][Knife] == knifeId)
	{
		PrintChatColor(id, _, "!g[%s] !y%s", PLUGIN, Lang[L_KnifeAlreadyHave])
		return PLUGIN_HANDLED
	}
	
	static description[c_class_chatdescription]
	
	if(is_user_alive(id))
	{
		static user_hp
		user_hp = get_user_health(id)
		if(user_hp > ArrayGetCell(KnifePropHp, knifeId) || user_hp == ArrayGetCell(KnifePropHp, Player[id][Knife]))
			set_user_health(id, ArrayGetCell(KnifePropHp, knifeId))
		
		Player[id][Knife] = knifeId
		strip_and_give(id)
		
		set_speed(id)
		set_gravity(id)
		
		ArrayGetString(KnifeChatDescription, Player[id][Knife], description, charsmax(description))
		PrintChatColor(id, _, description)
	}
	else
	{
		Player[id][Knife] = knifeId
		
		ArrayGetString(KnifeChatDescription, Player[id][Knife], description, charsmax(description))
		PrintChatColor(id, _, description)
	}
	
	if(isCrossKnifeFullOff(id))
		Player[id][Crosshair] = CrossOff
	
	if(get_user_flags(id) & VIP_FLAG)
		Player[id][WasChanged] = 0
	else
		Player[id][WasChanged] = 1
	
	ExecuteForward(forward_core_change_knife_post, fwReturn_pre, id, knifeId)
	
	return PLUGIN_CONTINUE
}

public plugin_end()
{
	DestroyForward(forward_abil_pre)
	DestroyForward(forward_abil_post)
	DestroyForward(forward_core_change_knife_pre)
	DestroyForward(forward_core_change_knife_post)
}

// Natives
public _21kc_register_knife(plugin, num_params)
{	
	new description[c_class_description]
	get_string(1, description, charsmax(description))
	
	new chatdescription[c_class_chatdescription]
	get_string(2, chatdescription, charsmax(chatdescription))
	
	new callback[33]
	get_string(3, callback, charsmax(callback))
	
	new Float:resetTime = get_param_f(4)
	
	new hp = get_param(5)
	new Float:gravity = get_param_f(6)
	new Float:speed = get_param_f(7)
	
	new knife_txt[c_class_string]
	get_string(8, knife_txt, charsmax(knife_txt))
	
	new Float:minDist = get_param_f(9)
	new Float:maxDist = get_param_f(10)
	
	// callback(user, victim)
	new fId = CreateOneForward(plugin, callback, FP_CELL, FP_CELL)
	if(fId < 0)
	{
		log_error(AMX_ERR_NATIVE, "[%s] (21kc_register_knife) Callback ability function not found ('%s')", PLUGIN, callback)
		return -1
	}
	
	ArrayPushString(KnifeDescription, description)
	ArrayPushString(KnifeChatDescription, chatdescription)
	ArrayPushCell(KnifeAbilCallback, fId)
	ArrayPushCell(KnifeAbilResetTime, resetTime)
	ArrayPushCell(KnifePropHp, hp)
	ArrayPushCell(KnifePropGravity, gravity)
	ArrayPushCell(KnifePropSpeed, speed)
	ArrayPushString(KnifeTxt, knife_txt)
	ArrayPushCell(KnifeAbilMinDist, minDist)
	ArrayPushCell(KnifeAbilMaxDist, maxDist)
	
	if(!equal(knife_txt, "NULL"))
	{
		if(minDist != -1.0 && maxDist != -1.0)
		{
			new knife_txt_n[c_class_string+4]
			
			format(knife_txt_n, charsmax(knife_txt_n), "%s_def", knife_txt)
			n21_register_hud("weapon_knife", knife_txt_n)
			format(knife_txt_n, charsmax(knife_txt_n), "%s_ok",knife_txt)
			n21_register_hud("weapon_knife", knife_txt_n)
			format(knife_txt_n, charsmax(knife_txt_n), "%s_time", knife_txt)
			n21_register_hud("weapon_knife", knife_txt_n)
			format(knife_txt_n, charsmax(knife_txt_n), "%s_far", knife_txt)
			n21_register_hud("weapon_knife", knife_txt_n)
			format(knife_txt_n, charsmax(knife_txt_n), "%s_cnot", knife_txt)
			n21_register_hud("weapon_knife", knife_txt_n)
		}
		else
			n21_register_hud("weapon_knife", knife_txt)
	}
	
	total_knifes++
	
	return total_knifes-1
}

public _21kc_register_shop(plugin, num_params)
{
	new callback[33]
	get_string(1, callback, charsmax(callback))
	
	new chat_text[c_item_string_chat]
	get_string(2, chat_text, charsmax(chat_text))
	
	new menu_text[c_item_string_menu]
	get_string(3, menu_text, charsmax(menu_text))
	
	new cost = get_param(4)
	
	new fId = CreateOneForward(plugin, callback, FP_CELL)
	if(fId < 0)
	{
		log_error(AMX_ERR_NATIVE, "[%s] (21kc_register_shop) Callback shop function not found ('%s')", PLUGIN, callback)
		return 0
	}
	
	ArrayPushCell(ShopItemCallback, fId)
	ArrayPushCell(ShopItemCost, cost)
	ArrayPushString(ShopItemChatText, chat_text)
	ArrayPushString(ShopItemMenuText, menu_text)
	
	return 1
}

public _21kc_register_cust_menu(plugin, num_params)
{
	new txt[c_custom_item_max_txt], callback[32]
	
	get_string(1, txt, charsmax(txt))
	get_string(2, callback, charsmax(callback))
	
	new fId = CreateOneForward(plugin, callback, FP_CELL)
	if(fId < 0)
	{
		log_error(AMX_ERR_NATIVE, "[%s] (21kc_register_cust_menu) Callback menu function not found ('%s')", PLUGIN, callback)
		return 0
	}
	
	g_custom_menu_count++
	
	new item_str[11]
	formatex(item_str, charsmax(item_str), "6172%d", g_custom_menu_count)
	
	ArrayPushString(CustomMenuItemTXT, txt)
	ArrayPushString(CustomMenuItemMenuKey, item_str)
	ArrayPushCell(CustomMenuItemCallback, fId)
	
	return 1
}

// возвращает 1 если всё ок, 0 если не найден нож
public _21kc_user_set_knife(plugin, num_params)
{
	static id, knife_id
	id = get_param(1)
	knife_id = get_param(2)
	
	if(!is_valid_knife(knife_id))
		return 0

	Player[id][Knife] = knife_id
	
	if(isCrossKnifeFullOff(id))
		Player[id][Crosshair] = CrossOff
	
	if(is_user_alive(id))
		strip_and_give(id)
	
	return 1
}

public _21kc_user_get_knife(plugin, num_params)
	return Player[get_param(1)][Knife]

public Float:_21kc_get_ability_last_reset(plugin, num_params)
	return Float:g_PlayerLastUsedAbility[get_param(1)]

public _21kc_get_info_ability(plugin, num_params)
{
	static knife_id
	knife_id = get_param(1)
	
	if(!is_valid_knife(knife_id))
	{
		log_error(AMX_ERR_NATIVE, "[%s] (_21kc_get_info_ability) Unknown knife id", PLUGIN)
		return
	}
	
	static Float:buffer[3]
	buffer[0] = ArrayGetCell(KnifeAbilResetTime, knife_id)
	buffer[1] = ArrayGetCell(KnifeAbilMinDist, knife_id)
	buffer[2] = ArrayGetCell(KnifeAbilMaxDist, knife_id)
	
	set_array_f(2, Float:buffer, 3)
}

public _21kc_set_crosshair(plugin, num_params)
	SetKnifeCrosshair(get_param(1), get_param(2), get_param(3))

public _21kc_get_crosshair(plugin, num_params)
	return Player[get_param(1)][Crosshair]

public _21kc_reset_speed(plugin, num_params)
	set_speed(get_param(1))

public _21kc_reset_gravity(plugin, num_params)
	set_gravity(get_param(1))

public _21kc_get_user_max_hp(plugin, num_params)
{
	new id = get_param(1)
	if(is_valid_knife(Player[id][Knife]))
		return ArrayGetCell(KnifePropHp, Player[id][Knife])
		
	return 100
}

public _21kc_in_reloading(plugin, num_params)
{
	new id = get_param(1)
	if(in_reloading[id])
		return true
	return false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <xs>

#define CC_COLORS_TYPE CC_COLORS_SHORT
#include <cromchat>

#if AMXX_VERSION_NUM < 183
#include <dhudmessage>
#endif

#define GET_MONEY(%0)		zp_cs_get_user_money(%0)
#define SET_MONEY(%0,%1) 	zp_cs_set_user_money(%0,%1)
#define GET_EXP(%0)			get_user_exp(%0)
#define SET_EXP(%0,%1)		set_user_exp(%0, get_user_exp(%0) + %1)


/*
[0.9.5]
- Исправленна поддержка режимов
- Добавлена поддержка BuyMenu, Level System
*/

#define PLUGIN_NAME				"Winter Environment [Bonus round: Pierrot]"
#define PLUGIN_VERSION			"0.9.11"
#define PLUGIN_AUTHOR			"Doc.Batcon - Edit by Huehue"
#define PLUGIN_PREFIX			"!n* "
#define PLUGIN_DICTIONARY		"we_bonusround.txt"

new const SNOWMAN_ENTITY[] 		= "monster_hevsuit_dead"
new const SNOWMAN_CLASSNAME[] 	= "npc_snowman"
new const SNOWMAN_MODEL[] 		= "models/we/npc_snowman.mdl"
#define SNOWMAN_HEALTH 			100.0
#define SNOWMAN_SPEED			200.0
#define SNOWMAN_BODY			random_num(0, 1)
#define SNOWMAN_SKIN			random_num(0, 5)

new const SNOWMAN_SOUNDS[][] =
{
	"we/snow_idle.wav",
	"we/snow_die.wav",
	"we/snow_pain.wav"
}

enum _: eSnowmanAnim
{
	ANIM_DUMMY,
	ANIM_IDLE,
	ANIM_WALK,
	ANIM_RUN,
	ANIM_JUMP,
	ANIM_FLINCH,
	ANIM_FLINCH2,
	ANIM_DEATH
}
enum _: eSnowmanAct
{
	ACT_DUMMY,
	ACT_IDLE,
	ACT_MOVE,
	ACT_JUMP,
	ACT_FLINCH,
	ACT_DIE
}

#define HUD_EVENT_X			-1.0
#define HUD_EVENT_Y			0.17

#define BR_TASKID			111
#define SP_DIR 				"npc_snowman"

//НАСТРОЙКИ

//Поддерживаемые моды
enum _: eSupportMods
{
	SUPPORT_CLASSIC,	//[Money]
	SUPPORT_ZP43,		//[AmmoPacks]
	SUPPORT_ZP50,		//[AmmoPacks]
	SUPPORT_BIOHAZARD,	//[Money]
	SUPPORT_HUEHUE,		//[Rank System Xp by Huehue]
	SUPPORT_CRX 		//[Rank System Xp by OciXCrom]
}

#define SUPPORT_MOD		SUPPORT_HUEHUE

//Количество выдаваемой валюты за убийство снеговика
#define GIVE_REWARD		1
//Количество выдаваемой опыта за убийство снеговика
#define GIVE_EXP		1

//Музыка во время раунда 		[Можно закомментировать]
#define BR_MUSIC			"we/scenario_xmas.mp3" 
//Время режима 1.0 = 1 минута	[Можно закомментировать]
#define BR_ROUNDTIME		2.0
//Шанс запуска режима 
#define BR_CHANGE			5
//Максимальное количество создаваемых снеговиков за 1 цикл
#define BR_CLOWN_SPAWN		5
//Максимальное количество живых снеговиков 
//(Рекомендуется 40-60) 
#define BR_CLOWN_MAX		50
//Блокировка урона между игроками на время режима [Можно закомментировать]
//(sАктуально для SUPPORT_CLASSIC)
#define BR_BLOCK_DAMAGE		true
//Минимальная дистаниция между спавнами
#define SP_MIN_DIST		64.0
//Максимальная дистания отображения спавнов в меню
#define SP_MAX_SHOW_DIST	512.0
//Включить поддержку Buy Menu ? [Можно закомментировать]
//#define ENABLED_SUPPORT_BUYMENU
//Включить поддержку Level System ? [Можно закомментировать]
//#define ENABLED_SUPPORT_LEVELSYSTEM

new g_iMenuClown;
new Array:g_aClownSpawnX, Array:g_aClownSpawnY, Array:g_aClownSpawnZ, Array:g_aSpawns;
new g_sModelIndexBeam;
new bool:g_bBonusRound, g_iBonusRoundStatus, g_iClownSpawned;
new bool:g_bNextRoundIsBonus;
new bool:g_bChangeBonusRound = true;
new bool:g_bIsFirstRound = true;
new g_iTrace;

#if defined BR_ROUNDTIME
new Float:g_fRoundTime;
#endif

#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true && SUPPORT_MOD != SUPPORT_CLASSIC
	#undef BR_BLOCK_DAMAGE
	#define BR_BLOCK_DAMAGE	false
#endif

#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true
new HamHook:g_HamHookTraceAttack;
new HamHook:g_HamHookTakeDamage;
#endif

#if SUPPORT_MOD == SUPPORT_CLASSIC
	#include <cstrike>
#endif
#if SUPPORT_MOD == SUPPORT_ZP43
	#include <zombieplague>
#endif
#if SUPPORT_MOD == SUPPORT_ZP50
	#include <zp50_ammopacks>
#endif
#if SUPPORT_MOD == SUPPORT_BIOHAZARD
	#include <cstrike>
	#include <biohazard>
#endif
#if defined ENABLED_SUPPORT_BUYMENU
	native GET_MONEY(pPlayer)
	native SET_MONEY(pPlayer, iValue)
#endif
#if defined ENABLED_SUPPORT_LEVELSYSTEM
	native GET_EXP(pPlayer)
	native SET_EXP(pPlayer, iValue)
#endif

#if SUPPORT_MOD == SUPPORT_HUEHUE
	#include <rank_system_huehue>
#endif

#if SUPPORT_MOD == SUPPORT_CRX
	#include <crxranks>
#endif

#if SUPPORT_MOD == SUPPORT_ZP43 || SUPPORT_MOD == SUPPORT_ZP50 || SUPPORT_MOD == SUPPORT_BIOHAZARD
new g_CvarID_GameModeDelay;
new Float:g_fRoundDelay;
#endif

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_think(SNOWMAN_CLASSNAME, "Snowman_Think");
	RegisterHam(Ham_Killed, SNOWMAN_ENTITY, "CBaseEntity_Killed", false);
	RegisterHam(Ham_TakeDamage, SNOWMAN_ENTITY, "CBaseEntity_TakeDamage", false);
	RegisterHam(Ham_BloodColor, SNOWMAN_ENTITY, "CBaseEntity_BloodColor", false);
	RegisterHam(Ham_TraceBleed, SNOWMAN_ENTITY, "CBaseEntity_TraceBleed", false);
	RegisterHam(Ham_Classify, SNOWMAN_ENTITY, "CBaseEntity_Classify", false);

	#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true
		g_HamHookTraceAttack = RegisterHam(Ham_TraceAttack, "player", "CBasePlayer_TraceAttack", false);
		g_HamHookTakeDamage = RegisterHam(Ham_TakeDamage, "player", "CBasePlayer_TakeDamage", false);
		DisableHamForward(g_HamHookTraceAttack);
		DisableHamForward(g_HamHookTakeDamage);
	#endif

	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0");
	register_logevent("Event_RoundStarted", 2, "1=Round_Start");
	register_logevent("Event_RoundEnd", 2, "1=Round_End");
	register_logevent("Event_RoundRestart", 2, "1=Game_Commencing");
	register_event("TextMsg", "Event_RoundRestart", "a", "2=#Game_will_restart_in");

	register_dictionary(PLUGIN_DICTIONARY);

	register_clcmd("we_bonusround", "ClientCmd_ShowMenu");
}
public plugin_precache()
{
	precache_model(SNOWMAN_MODEL);
	g_sModelIndexBeam = precache_model("sprites/laserbeam.spr");

	for(new i; i < sizeof SNOWMAN_SOUNDS; i++)
		precache_sound(SNOWMAN_SOUNDS[i]);

	#if defined BR_MUSIC
		new buffer[64]; formatex(buffer, charsmax(buffer), "sound/%s", BR_MUSIC);
		precache_generic(buffer);
	#endif

	g_aSpawns = ArrayCreate(1, 1);
	g_aClownSpawnX = ArrayCreate(1, 1);
	g_aClownSpawnY = ArrayCreate(1, 1);
	g_aClownSpawnZ = ArrayCreate(1, 1);

	g_iTrace = create_tr2();

	g_iMenuClown = menu_create("MENU_TITLE", "MenuHandler_Pierrot");
	menu_additem(g_iMenuClown, "MENU_ITEM_01");
	menu_additem(g_iMenuClown, "MENU_ITEM_02");
	menu_additem(g_iMenuClown, "MENU_ITEM_03");
}
public plugin_cfg()
{
	SP_LoadPoints();

	#if SUPPORT_MOD == SUPPORT_ZP43
		g_CvarID_GameModeDelay = get_cvar_pointer("zp_delay");
	#endif
	#if SUPPORT_MOD == SUPPORT_ZP50
		g_CvarID_GameModeDelay = get_cvar_pointer("zp_gamemode_delay");
	#endif
	#if SUPPORT_MOD == SUPPORT_BIOHAZARD
		g_CvarID_GameModeDelay = get_cvar_pointer("bh_starttime");
	#endif
}
public Snowman_Reward(const pEntity, const pPlayer)
{
	#if SUPPORT_MOD == SUPPORT_CLASSIC && !defined ENABLED_SUPPORT_BUYMENU
		cs_set_user_money(pPlayer, cs_get_user_money(pPlayer) + GIVE_REWARD);
	#endif
	#if SUPPORT_MOD == SUPPORT_ZP43 && !defined ENABLED_SUPPORT_BUYMENU
		zp_set_user_ammo_packs(pPlayer, zp_get_user_ammo_packs(pPlayer) + GIVE_REWARD);
	#endif
	#if SUPPORT_MOD == SUPPORT_ZP50 && !defined ENABLED_SUPPORT_BUYMENU
		zp_ammopacks_set(pPlayer, zp_ammopacks_get(pPlayer) + GIVE_REWARD);
	#endif
	#if SUPPORT_MOD == SUPPORT_BIOHAZARD && !defined ENABLED_SUPPORT_BUYMENU
		cs_set_user_money(pPlayer, cs_get_user_money(pPlayer) + GIVE_REWARD);
	#endif
	#if defined ENABLED_SUPPORT_BUYMENU
		SET_MONEY(pPlayer, GET_MONEY(pPlayer) + GIVE_REWARD);
	#endif	
	#if defined ENABLED_SUPPORT_LEVELSYSTEM
		SET_EXP(pPlayer, GET_EXP(pPlayer) + GIVE_EXP);
	#endif	
	#if SUPPORT_MOD == SUPPORT_HUEHUE
		SET_EXP(pPlayer, GET_EXP(pPlayer) + GIVE_EXP)
	#endif
	#if SUPPORT_MOD == SUPPORT_CRX
		SET_EXP(pPlayer, GET_EXP(pPlayer) + GIVE_EXP)
	#endif
}
#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true
public CBasePlayer_TraceAttack(pPlayer, pAttacker)
{
	if(!is_user_connected(pAttacker))
		return HAM_IGNORED;
	return HAM_SUPERCEDE;
}
public CBasePlayer_TakeDamage(pPlayer, pInflictor, pAttacker)
{
	if(!is_user_connected(pAttacker))
		return HAM_IGNORED;
	return HAM_SUPERCEDE;
}
#endif
public BonusRound_Start()
{
	set_dhudmessage(0, 120, 200, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0);
	show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_HUD_PREPARE");

	#if defined BR_MUSIC
		UTIL_StopSound();
		UTIL_PlaySound(0, BR_MUSIC, true);
	#endif

	#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true
		EnableHamForward(g_HamHookTraceAttack);
		EnableHamForward(g_HamHookTakeDamage);
	#endif	

	set_task(1.0, "Task_GL_BonusRound", BR_TASKID, _, _, "b");
	g_iBonusRoundStatus = 1;
	g_bBonusRound = true;
	g_bNextRoundIsBonus = false;
}
public BonusRound_End()
{
	#if defined BR_MUSIC
		UTIL_StopSound();
	#endif

	#if SUPPORT_MOD == SUPPORT_ZP43
		set_pcvar_num(g_CvarID_GameModeDelay, floatround(g_fRoundDelay));
	#endif

	#if SUPPORT_MOD == SUPPORT_ZP50 || SUPPORT_MOD == SUPPORT_BIOHAZARD
		set_pcvar_float(g_CvarID_GameModeDelay, g_fRoundDelay);
	#endif

	remove_task(BR_TASKID);
	g_iBonusRoundStatus = 2;
	g_bBonusRound = false;
	
	new pEntity = -1;
	while((pEntity = find_ent_by_class(pEntity, SNOWMAN_CLASSNAME)))
	{
		if(entity_get_int(pEntity, EV_INT_deadflag) != DEAD_NO)
			continue;

		entity_set_edict(pEntity, EV_ENT_dmg_inflictor, 0);
		Snowman_SetActivity(pEntity, ACT_DIE);
	}
}
public BonusRound_NextRound()
{
	g_bNextRoundIsBonus = true;
	g_bChangeBonusRound = false;
	CC_SendMatched(0, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, LANG_PLAYER, "MSG_PREPARE");

	#if SUPPORT_MOD == SUPPORT_ZP43
		g_fRoundDelay = float(get_pcvar_num(g_CvarID_GameModeDelay));
		set_pcvar_num(g_CvarID_GameModeDelay, 999);
	#endif

	#if SUPPORT_MOD == SUPPORT_ZP50 || SUPPORT_MOD == SUPPORT_BIOHAZARD
		g_fRoundDelay = get_pcvar_float(g_CvarID_GameModeDelay);
		set_pcvar_float(g_CvarID_GameModeDelay, 999.0);
	#endif
}

public Event_RoundStart()
{
	#if defined BR_ROUNDTIME
		if(g_bNextRoundIsBonus)
		{
			g_fRoundTime = get_cvar_float("mp_roundtime");
			server_cmd("mp_roundtime %f", BR_ROUNDTIME);
			server_exec();
		}
	#endif

	if(!g_iBonusRoundStatus)
		return;

	#if defined BR_MUSIC
		UTIL_StopSound();
	#endif

	#if defined BR_BLOCK_DAMAGE && BR_BLOCK_DAMAGE == true
		DisableHamForward(g_HamHookTraceAttack);
		DisableHamForward(g_HamHookTakeDamage);
	#endif	

	new pEntity = -1;
	while((pEntity = find_ent_by_class(pEntity, SNOWMAN_CLASSNAME)))
		entity_set_int(pEntity, EV_INT_flags, FL_KILLME);
	
	remove_task(BR_TASKID);
	g_iClownSpawned = 0;
	g_iBonusRoundStatus = 0;
	g_bBonusRound = false;
}
public Event_RoundStarted()
{
	if(g_bNextRoundIsBonus)
		BonusRound_Start();
}
public Event_RoundEnd()
{
	if(!g_bIsFirstRound && g_bChangeBonusRound && !random_num(0, BR_CHANGE))
	{
		BonusRound_NextRound();
	}

	g_bIsFirstRound = false;

	if(g_iBonusRoundStatus != 1)
		return;

	BonusRound_End();

	#if defined BR_ROUNDTIME
		server_cmd("mp_roundtime %f", g_fRoundTime);
		server_exec();
	#endif
}
public Event_RoundRestart()
{
	g_bNextRoundIsBonus = false;
	g_bChangeBonusRound = true;
	g_bIsFirstRound = true;

	if(!g_iBonusRoundStatus)
		return;

	#if SUPPORT_MOD == SUPPORT_ZP43
		set_pcvar_num(g_CvarID_GameModeDelay, floatround(g_fRoundDelay));
	#endif

	#if SUPPORT_MOD == SUPPORT_ZP50 || SUPPORT_MOD == SUPPORT_BIOHAZARD
		set_pcvar_float(g_CvarID_GameModeDelay, g_fRoundDelay);
	#endif
}

public Task_GL_BonusRound(TaskID)
{
	new PointID, Float:vPoint[3];
	new iMaxSpawns = BR_CLOWN_SPAWN;
	while(iMaxSpawns && (g_iClownSpawned <= BR_CLOWN_MAX) && ((PointID = SP_GetRandomEmptyPointID()) != -1))
	{
		SP_GetPointOrigin(PointID, vPoint);
		Snowman_Spawn(vPoint);
		iMaxSpawns--;
	}
}
public ClientCmd_ShowMenu(pPlayer)
{
	if(get_user_flags(pPlayer) & ADMIN_IMMUNITY)
	{
		new buffer[64]; 
		formatex(buffer, charsmax(buffer), "%L", pPlayer, "MENU_MAIN_TITLE");
		menu_setprop(g_iMenuClown, MPROP_TITLE, buffer);
		formatex(buffer, charsmax(buffer), "%L", pPlayer, "MENU_ITEM_01");
		menu_item_setname(g_iMenuClown, 0, buffer);
		formatex(buffer, charsmax(buffer), "%L", pPlayer, "MENU_ITEM_02");
		menu_item_setname(g_iMenuClown, 1, buffer);
		formatex(buffer, charsmax(buffer), "%L", pPlayer, "MENU_ITEM_03");
		menu_item_setname(g_iMenuClown, 2, buffer);
		formatex(buffer, charsmax(buffer), "%L", pPlayer, "MENU_EXIT");
		menu_setprop(g_iMenuClown, MPROP_EXITNAME, buffer);
		menu_display(pPlayer, g_iMenuClown);
		set_task(0.1, "Task_Client_ShowPoints", pPlayer, _, _, "b");
		set_pdata_int(pPlayer, 205, 0, 5);
	}
	else
	{
		CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, LANG_PLAYER, "MSG_NOT_ACCESS_01");
	}
	return PLUGIN_HANDLED;
}
public Task_Client_ShowPoints(pPlayer)
{
	if(!is_user_connected(pPlayer) || !IsShowMenu(pPlayer,g_iMenuClown))
	{
		remove_task(pPlayer);
		return;
	}

	new Float:vOrigin[3]
	new Float:vPoint[3], iPoint[3];
	new PointID = -1;

	entity_get_vector(pPlayer, EV_VEC_origin, vOrigin);

	while((PointID = SP_GetPointInSphere(PointID, vOrigin, SP_MAX_SHOW_DIST)) != -1)
	{
		SP_GetPointOrigin(PointID, vPoint);
		FVecIVec(vPoint, iPoint);

		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, pPlayer);
		write_byte(TE_BEAMPOINTS);
		write_coord(iPoint[0]);
		write_coord(iPoint[1]);
		write_coord(iPoint[2]-36);
		write_coord(iPoint[0]);
		write_coord(iPoint[1]);
		write_coord(iPoint[2]+36);
		write_short(g_sModelIndexBeam);
		write_byte(1);               
        	write_byte(1);                 
        	write_byte(5);           
        	write_byte(10);     
        	write_byte(2);     
        	write_byte(255);           
        	write_byte(255);           
        	write_byte(255);           
        	write_byte(200);           
        	write_byte(0);               
        	message_end();
	}
}
public bool:IsShowMenu(pPlayer, iMenu)
{
	new iMenuOLD, iMenuNEW;
	player_menu_info(pPlayer, iMenuOLD, iMenuNEW);
	if(iMenuOLD == iMenu || iMenuNEW == iMenu)
		return true;
	return false;
}
public MenuHandler_Pierrot(pPlayer, iMenuID, iItem)
{
	if(iItem > -1)
		menu_display(pPlayer, iMenuID);

	if(iItem == MENU_EXIT)
		remove_task(pPlayer);

	switch(iItem)
	{
		case 0:
		{
			new Float:vOrigin[3]; UTIL_GetAimOriginSpawn(pPlayer, vOrigin);

			if(!UTIL_IsHullVacant(vOrigin, HULL_HUMAN))
			{
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, pPlayer, "MSG_DONT_VACPOINT");
				UTIL_PlaySound(pPlayer, "buttons/button10.wav");
				return;
			}

			new PointID = SP_GetPointInSphere(-1, vOrigin, SP_MIN_DIST);
			if(PointID == -1)
			{
				SP_AddPoint(vOrigin);
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, pPlayer, "MSG_SPAWN_CREATED");
			}
			else
			{
				SP_SubPoint(PointID);
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, pPlayer, "MSG_SPAWN_DELETED");
			}
		}
		case 1:
		{
			if(SP_SavePoints())
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, pPlayer, "MSG_SAVE_POINT");
			else
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, pPlayer, "MSG_SAVE_POINT_FAIL");
		}
		case 2:
		{
			if(g_bBonusRound || g_iBonusRoundStatus || g_bNextRoundIsBonus || !SP_GetPointsNum())
			{
				CC_SendMatched(pPlayer, CC_COLOR_TEAM, "%s %L", PLUGIN_PREFIX, LANG_PLAYER, "MSG_NOT_ACCESS_02");
				UTIL_PlaySound(pPlayer, "buttons/button10.wav");
				return;
			}
			
			BonusRound_NextRound();
		}
	}

	UTIL_PlaySound(pPlayer, "common/wpn_denyselect.wav");
}
public Snowman_Spawn(const Float:vOrigin[3])
{
	static pEntity;
	if(!(pEntity = create_entity(SNOWMAN_ENTITY)))
		return 0

	entity_set_string(pEntity, EV_SZ_classname, SNOWMAN_CLASSNAME);
	entity_set_int(pEntity, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_int(pEntity, EV_INT_solid, SOLID_BBOX);
	entity_set_int(pEntity, EV_INT_deadflag, DEAD_NO);
	entity_set_int(pEntity, EV_INT_flags, FL_MONSTER);
	entity_set_int(pEntity, EV_INT_skin, SNOWMAN_SKIN);

	if(!entity_get_int(pEntity, EV_INT_skin))
		entity_set_int(pEntity, EV_INT_body,  SNOWMAN_BODY);
		
	entity_set_float(pEntity, EV_FL_health, SNOWMAN_HEALTH);
	entity_set_float(pEntity, EV_FL_gravity, 1.0);
	entity_set_float(pEntity, EV_FL_framerate, 1.0);
	entity_set_float(pEntity, EV_FL_takedamage, DAMAGE_AIM);
	entity_set_vector(pEntity, EV_VEC_view_ofs, Float:{0.0, 0.0, 10.0});
	entity_set_model(pEntity, SNOWMAN_MODEL);
	entity_set_size(pEntity, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 18.0});
	entity_set_origin(pEntity, vOrigin);
	Snowman_SetActivity(pEntity, ACT_JUMP);
	Snowman_SetNextSoundIdle(pEntity, random_float(5.0, 10.0));
	g_iClownSpawned++;
	return pEntity;
}
public Snowman_Think(const pEntity)
{
	static iActivity; iActivity = entity_get_int(pEntity, EV_INT_iuser1);
	static Float:fGameTime; fGameTime = get_gametime();
	static pTarget; pTarget = entity_get_edict(pEntity, EV_ENT_enemy);
	static Float:fDelay; fDelay = 0.1;
	static Float:vTarget[3];

	if(iActivity == ACT_IDLE || iActivity == ACT_MOVE)
	{
		if(pTarget)
		{
			if(!Snowman_IsValidPlayer(pEntity, pTarget))
			{
				Snowman_SetNextFindPlayer(pEntity, 1.0);
				Snowman_SetNextCheckMove(pEntity, 1.0);
				pTarget = 0;
			}

			if(pTarget)
			{
				entity_get_vector(pTarget, EV_VEC_origin, vTarget);
				Snowman_SetMovePoint(pEntity, vTarget);
				Snowman_SetNextCheckMove(pEntity, 1.0);

				if(Snowman_IsMoveComplete(pEntity) || 
				entity_get_edict(pEntity, EV_ENT_groundentity) == pTarget
				)
					iActivity = ACT_IDLE;
				else
					iActivity = ACT_MOVE;
			}
			else
			{
				iActivity = ACT_IDLE;
			}
		}
		else
		{
			if((Snowman_GetNextCheckMove(pEntity) > fGameTime) && !Snowman_IsMoveComplete(pEntity))
				iActivity = ACT_MOVE;
			else
				iActivity = ACT_IDLE;
		}
	}

	if(entity_get_edict(pEntity, EV_ENT_enemy) == 0)
		pTarget = 0;

	if(Snowman_GetNextFindPlayer(pEntity) < fGameTime)
	{
		pTarget = Snowman_FindTarget(pEntity);
		Snowman_SetNextFindPlayer(pEntity, pTarget ? 5.0 : 1.0);
	}

	entity_set_edict(pEntity, EV_ENT_enemy, pTarget);

	switch(iActivity)
	{
		case ACT_DUMMY:
		{
			if(entity_get_int(pEntity, EV_INT_sequence) != ANIM_IDLE)
				 UTIL_PlayAnimation(pEntity, ANIM_IDLE);
		}
		case ACT_IDLE:
		{
			if(entity_get_int(pEntity, EV_INT_sequence) != ANIM_IDLE)
			{
				 UTIL_PlayAnimation(pEntity, ANIM_IDLE);

				 if(Snowman_GetNextSoundIdle(pEntity) - fGameTime > 1.0)
				 	Snowman_SetNextSoundIdle(pEntity, random_float(5.0, 10.0));
			}

			if(Snowman_GetNextSoundIdle(pEntity) < fGameTime)
			{
				emit_sound(pEntity, CHAN_VOICE, SNOWMAN_SOUNDS[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				Snowman_SetNextSoundIdle(pEntity, random_float(5.0, 10.0));
			}

			if(Snowman_GetNextCheckMove(pEntity) <= fGameTime)
			{
				new iPointNum = Snowman_GetRandomDir(pEntity, vTarget);

				if(iPointNum)
				{
					Snowman_SetMovePoint(pEntity, vTarget);
					Snowman_SetNextCheckMove(pEntity, random_float(2.0, 4.0));
					iActivity = ACT_MOVE;
				}
				else
					Snowman_SetNextCheckMove(pEntity, 2.0);
			}
		}
		case ACT_MOVE:
		{
			if(entity_get_int(pEntity, EV_INT_sequence) != ANIM_WALK)
				 UTIL_PlayAnimation(pEntity, ANIM_WALK);

			static MoveFlags; Snowman_MoveToOrigin(pEntity, SNOWMAN_SPEED, MoveFlags);

			if(MoveFlags & (1<<1))
				iActivity = ACT_IDLE;

			//Is snowman in air ?
			if(~entity_get_int(pEntity, EV_INT_flags) & FL_ONGROUND)
			{
				static Float:fFlyTime; fFlyTime = entity_get_float(pEntity, EV_FL_fuser1);
				if(fFlyTime == 0.0 || MoveFlags & (1<<0))
					fFlyTime = fGameTime;
				else if(fGameTime - fFlyTime > 0.15)
					iActivity = ACT_JUMP;
				entity_set_float(pEntity, EV_FL_fuser1, fFlyTime);
			}
			else
				entity_set_float(pEntity, EV_FL_fuser1, 0.0);
		}
		case ACT_JUMP:
		{
			if(entity_get_int(pEntity, EV_INT_sequence) != ANIM_JUMP)
				 UTIL_PlayAnimation(pEntity, ANIM_JUMP);

			if(entity_get_int(pEntity, EV_INT_flags) & FL_ONGROUND)
			{
				entity_set_float(pEntity, EV_FL_fuser1, 0.0);
				entity_set_int(pEntity, EV_INT_movetype, MOVETYPE_PUSHSTEP);
				iActivity = ACT_IDLE;
			}	
		}
		case ACT_DIE:
		{
			if(entity_get_int(pEntity, EV_INT_deadflag) == DEAD_DEAD)
				entity_set_int(pEntity, EV_INT_flags, FL_KILLME);
			else
			{
				new pAttacker = entity_get_edict(pEntity, EV_ENT_dmg_inflictor);
				if(is_user_connected(pAttacker))
					Snowman_Reward(pEntity, pAttacker);

				emit_sound(pEntity, CHAN_VOICE, SNOWMAN_SOUNDS[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				UTIL_PlayAnimation(pEntity, ANIM_DEATH);
				entity_set_int(pEntity, EV_INT_solid, SOLID_NOT);
				entity_set_int(pEntity, EV_INT_movetype, MOVETYPE_TOSS);
				entity_set_int(pEntity, EV_INT_deadflag, DEAD_DEAD);
				entity_set_float(pEntity, EV_FL_takedamage, DAMAGE_NO);
				fDelay = 4.0
				g_iClownSpawned--;
			}
		}
		case ACT_FLINCH:
		{
			emit_sound(pEntity, CHAN_VOICE, SNOWMAN_SOUNDS[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			UTIL_PlayAnimation(pEntity, random_num(ANIM_FLINCH, ANIM_FLINCH2));
			fDelay = 0.15
			iActivity = ACT_IDLE
		}
	}

	entity_set_int(pEntity, EV_INT_iuser1, iActivity);
	entity_set_float(pEntity, EV_FL_nextthink, fGameTime + fDelay);
}
public Snowman_SetActivity(const pEntity, const iActivity)
{
	entity_set_int(pEntity, EV_INT_iuser1, iActivity);
	entity_set_float(pEntity, EV_FL_nextthink, get_gametime());
}
public Snowman_FindTarget(const pEntity)
{
	static pTarget; pTarget = 0;
	static Float:fMin; fMin = 8192.0;
	static Float:fCur;

	static PlayersID[32], iPlayersNum;
	get_players(PlayersID, iPlayersNum, "ah");
	static i, pPlayer;
	for(i = 0; i < iPlayersNum; i++)
	{
		pPlayer = PlayersID[i];

		if(!ENG_is_visible(pEntity, pPlayer))
			continue;

		fCur = entity_range(pEntity, pPlayer);

		if(fCur < fMin)
		{
			fMin = fCur;
			pTarget = pPlayer;
		}
	}

	return pTarget;
}
public Snowman_GetRandomDir(const pEntity, Float:vTarget[3])
{
	static Float:vAngles[3]; entity_get_vector(pEntity, EV_VEC_angles, vAngles);
	static Float:vOrigin[3]; entity_get_vector(pEntity, EV_VEC_origin, vOrigin);
	static Float:vEnd[3];

	static Float:vForward[3];
	static Float:vPoint[16][3], iPointNum; iPointNum = 0;
	static Float:vAngles2[3]; vAngles2[1] = vAngles[1];
	static Float:vEndPos[3];
	static Float:fCur;

	static i;
	for(i = 0; i < 16; i++)
	{
		angle_vector(vAngles2, ANGLEVECTOR_FORWARD, vForward);
		vEnd[0] = vOrigin[0] + vForward[0] * 1024.0;
		vEnd[1] = vOrigin[1] + vForward[1] * 1024.0;
		vEnd[2] = vOrigin[2] + vForward[2] * 1024.0;
		
		
		ENG_trace_line(pEntity, vOrigin, vEnd, vEndPos);

		fCur = get_distance_f(vOrigin, vEndPos);
		vAngles2[1] += 20.0

		if(fCur < 64.0)
			continue;

		xs_vec_copy(vEndPos, vPoint[iPointNum]);
		iPointNum++;
	}

	if(iPointNum)
		xs_vec_copy(vPoint[random(iPointNum)], vTarget);

	return iPointNum;
}
public Float:Snowman_GetNextCheckMove(const pEntity)
{
	return entity_get_float(pEntity, EV_FL_fuser2);
}
public Snowman_SetNextCheckMove(const pEntity, const Float:fDelay)
{
	entity_set_float(pEntity, EV_FL_fuser2, get_gametime() + fDelay);
}
public Float:Snowman_GetNextFindPlayer(const pEntity)
{
	return entity_get_float(pEntity, EV_FL_fuser3);
}
public Snowman_SetNextFindPlayer(const pEntity, const Float:fDelay)
{
	entity_set_float(pEntity, EV_FL_fuser3, get_gametime() + fDelay);
}
public Snowman_SetMovePoint(const pEntity, const Float:vPoint[3])
{
	entity_set_vector(pEntity, EV_VEC_vuser1, vPoint);
}
public Snowman_GetMovePoint(const pEntity, Float:vPoint[3])
{
	entity_get_vector(pEntity, EV_VEC_vuser1, vPoint);
}
public Float:Snowman_GetNextSoundIdle(const pEntity)
{
	return entity_get_float(pEntity, EV_FL_fuser4);
}
public Float:Snowman_SetNextSoundIdle(const pEntity, const Float:fDelay)
{
	entity_set_float(pEntity, EV_FL_fuser4, get_gametime() + fDelay);
}

public bool:Snowman_IsMoveComplete(const pEntity)
{
	static Float:vSrc[3]; entity_get_vector(pEntity, EV_VEC_origin, vSrc);
	static Float:vEnd[3]; Snowman_GetMovePoint(pEntity, vEnd);

	if(get_distance_f(vSrc, vEnd) < 64.0)
		return true;

	vEnd[2] = vSrc[2];
	static Float:vDir[3]; xs_vec_sub(vEnd, vSrc, vDir);
	static Float:vAngles[3]; vector_to_angle(vDir, vAngles);
	static Float:vForward[3]; angle_vector(vAngles, ANGLEVECTOR_FORWARD, vForward);
	vEnd[0] = vSrc[0] + vForward[0] * 26.0;
	vEnd[1] = vSrc[1] + vForward[1] * 26.0;
	vEnd[2] = vSrc[2] + vForward[2] * 26.0;
	if(ENG_trace_hull(vEnd, vSrc, HULL_HUMAN, pEntity, DONT_IGNORE_MONSTERS))
	{
		vEnd[2] += 36.0;
		if(ENG_trace_hull(vEnd, vEnd, HULL_HUMAN, pEntity, DONT_IGNORE_MONSTERS))
		{
			if(entity_get_edict(pEntity, EV_ENT_enemy))
			{
				entity_set_edict(pEntity, EV_ENT_enemy, 0);
				Snowman_SetNextFindPlayer(pEntity, 0.5);
				Snowman_SetNextCheckMove(pEntity, 0.1);
			}
			return true;
		}
	}
	return false;
}
public bool:Snowman_IsValidPlayer(const pEntity, const pPlayer)
{
	if(!is_user_alive(pPlayer))
		return false;
	if(!ENG_is_visible(pEntity, pPlayer))
		return false;
	return true;
}

public CBaseEntity_Killed(const pEntity, const pAttacker)
{
	static szClassName[sizeof SNOWMAN_CLASSNAME];
	entity_get_string(pEntity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, SNOWMAN_CLASSNAME)) return HAM_IGNORED;
	Snowman_SetActivity(pEntity, ACT_DIE);
	return HAM_SUPERCEDE;
}
public CBaseEntity_TakeDamage(const pEntity, const pInflictor, const pAttacker)
{
	static szClassName[sizeof SNOWMAN_CLASSNAME];
	entity_get_string(pEntity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, SNOWMAN_CLASSNAME)) return;
	entity_set_edict(pEntity, EV_ENT_dmg_inflictor, pAttacker);
	Snowman_SetActivity(pEntity, ACT_FLINCH);
}
public CBaseEntity_BloodColor(const pEntity)
{
	static szClassName[sizeof SNOWMAN_CLASSNAME];
	entity_get_string(pEntity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, SNOWMAN_CLASSNAME)) return HAM_IGNORED;
	SetHamReturnInteger(12);
	return HAM_SUPERCEDE;
}
public CBaseEntity_TraceBleed(const pEntity)
{
	static szClassName[sizeof SNOWMAN_CLASSNAME];
	entity_get_string(pEntity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, SNOWMAN_CLASSNAME)) return HAM_IGNORED;
	return HAM_SUPERCEDE;
}
public CBaseEntity_Classify(const pEntity)
{
	static szClassName[sizeof SNOWMAN_CLASSNAME];
	entity_get_string(pEntity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, SNOWMAN_CLASSNAME)) return HAM_IGNORED;
	SetHamReturnInteger(4);
	return HAM_SUPERCEDE;
}

public Snowman_MoveToOrigin(const pEntity, const Float:fSpeed, Flags)
{
	Flags = 0;

	static Float:vOrigin[3]; Snowman_GetMovePoint(pEntity, vOrigin);
	static Float:vSrc[3]; entity_get_vector(pEntity, EV_VEC_origin, vSrc);
	static Float:vDir[3]; xs_vec_sub(vOrigin, vSrc, vDir);
	static Float:vAngles[3]; vector_to_angle(vDir, vAngles);
	static Float:vVel[3]; xs_vec_normalize(vDir, vDir);
	xs_vec_mul_scalar(vDir, fSpeed, vVel);
	vAngles[0] = vAngles[2] = 0.0;
	vVel[2] = -100.0;

	static Float:vForward[3]; angle_vector(vAngles, ANGLEVECTOR_FORWARD, vForward);
	static Float:vEnd[3]; 
	vEnd[0] = vSrc[0] + vForward[0] * 20.0;
	vEnd[1] = vSrc[1] + vForward[1] * 20.0;
	vEnd[2] = vSrc[2] + vForward[2] * 20.0;

	if(ENG_trace_hull(vEnd, vSrc, HULL_HUMAN, pEntity, IGNORE_MONSTERS))
	{
		vEnd[2] += 36.0;
		if(!ENG_trace_hull(vEnd, vEnd, HULL_HUMAN, pEntity, IGNORE_MONSTERS))
		{
			vVel[2] = 200.0;
			Flags |= (1<<0);
		}
	}

	entity_set_vector(pEntity, EV_VEC_angles, vAngles);
	entity_set_vector(pEntity, EV_VEC_velocity, vVel);

	if(Snowman_IsMoveComplete(pEntity) && !(Flags & (1<<0)))
		Flags |= (1<<1);
}

stock UTIL_PlayAnimation(const pEntity, const iAnim)
{
	entity_set_int(pEntity, EV_INT_sequence, iAnim);
	entity_set_float(pEntity, EV_FL_animtime, get_gametime());
	entity_set_float(pEntity, EV_FL_frame, 0.0);
	return iAnim;
}
stock bool:UTIL_IsHullVacant(Float:vOrigin[3], const HullType)
{
	if(!ENG_trace_hull(vOrigin, vOrigin, HullType))
		return true;
	return false;
}
stock UTIL_GetAimOrigin(const pPlayer, Float:vPoint[3])
{
	new Float:vOrigin[3]; entity_get_vector(pPlayer, EV_VEC_origin, vOrigin);
	new Float:vViewOfs[3]; entity_get_vector(pPlayer, EV_VEC_view_ofs, vViewOfs);
	new Float:vViewAngle[3]; entity_get_vector(pPlayer, EV_VEC_v_angle, vViewAngle);
	new Float:vSrc[3]; xs_vec_add(vOrigin, vViewOfs, vSrc);
	new Float:vForward[3]; angle_vector(vViewAngle, ANGLEVECTOR_FORWARD, vForward);
	new Float:vEnd[3]; xs_vec_mul_scalar(vForward, 8192.0, vEnd);
	xs_vec_add(vSrc, vEnd, vEnd);
	ENG_trace_line(pPlayer, vSrc, vEnd, vPoint);
}
stock UTIL_GetAimOriginSpawn(const pPlayer, Float:vPoint[3])
{
	new Float:vOrigin[3]; entity_get_vector(pPlayer, EV_VEC_origin, vOrigin);
	new Float:vViewOfs[3]; entity_get_vector(pPlayer, EV_VEC_view_ofs, vViewOfs);
	new Float:vViewAngle[3]; entity_get_vector(pPlayer, EV_VEC_v_angle, vViewAngle);
	new Float:vSrc[3]; xs_vec_add(vOrigin, vViewOfs, vSrc);
	new Float:vForward[3]; angle_vector(vViewAngle, ANGLEVECTOR_FORWARD, vForward);
	new Float:vEnd[3]; xs_vec_mul_scalar(vForward, 8192.0, vEnd);
	xs_vec_add(vSrc, vEnd, vEnd);
	ENG_trace_line(pPlayer, vSrc, vEnd, vPoint);

	new Float:vNormal[3]; get_tr2(g_iTrace, TR_vecPlaneNormal, vNormal);
	if(vNormal[0] != 0.0) vPoint[0] += vNormal[0] * 20.0;
	if(vNormal[1] != 0.0) vPoint[1] += vNormal[1] * 20.0;
	if(vNormal[2] != 0.0) vPoint[2] += vNormal[2] * 36.0;
}

stock SP_AddPoint(const Float:vPoint[3])
{
	ArrayPushCell(g_aClownSpawnX, Float:vPoint[0]);
	ArrayPushCell(g_aClownSpawnY, Float:vPoint[1]);
	ArrayPushCell(g_aClownSpawnZ, Float:vPoint[2]);

	return SP_GetPointsNum();
}
stock bool:SP_SubPoint(const PointID)
{
	if(PointID < 0 || PointID > ArraySize(g_aClownSpawnX))
		return false;

	ArrayDeleteItem(g_aClownSpawnX, PointID);
	ArrayDeleteItem(g_aClownSpawnY, PointID);
	ArrayDeleteItem(g_aClownSpawnZ, PointID);
	return true;
}
stock bool:SP_IsValidOrigin(const Float:vOrigin[3])
{
	if(!UTIL_IsHullVacant(vOrigin, HULL_HUMAN))
		return false;

	if(!SP_IsValidMinDist(vOrigin))
		return false;

	return true;
}
stock bool:SP_IsValidMinDist(const Float:vOrigin[3], const Float:fMinDist = 64.0)
{
	static Float:vPoint[3];
	for(new PointID; PointID < SP_GetPointsNum(); PointID++)
	{
		SP_GetPointOrigin(PointID, vPoint);
		if(get_distance_f(vOrigin, vPoint) <= fMinDist)
			return false;
	}
	return true;
}
stock SP_GetPointInSphere(StartPoint, const Float:vOrigin[3], const Float:fRadius = 64.0)
{
	new iPointsNum = SP_GetPointsNum();
	new PointID;

	if(!iPointsNum || StartPoint > iPointsNum)
		return -1;

	if(StartPoint < 0)
		StartPoint = 0;
	else
		StartPoint++;

	new Float:vPoint[3];
	for(PointID = StartPoint; PointID < iPointsNum; PointID++)
	{
		SP_GetPointOrigin(PointID, vPoint);
		if(get_distance_f(vOrigin, vPoint) <= fRadius)
			return PointID;
	}

	return -1;
}
stock SP_GetPointOrigin(const PointID, Float:vOrigin[3])
{
	vOrigin[0] = Float:ArrayGetCell(g_aClownSpawnX, PointID);
	vOrigin[1] = Float:ArrayGetCell(g_aClownSpawnY, PointID);
	vOrigin[2] = Float:ArrayGetCell(g_aClownSpawnZ, PointID);
}
stock SP_GetEmptyPointID()
{
	static Float:vPoint[3];
	for(new PointID; PointID < SP_GetPointsNum(); PointID++)
	{
		SP_GetPointOrigin(PointID, vPoint);
		if(UTIL_IsHullVacant(vPoint, HULL_HUMAN))
			return PointID;
	}
	return -1;
}
stock SP_GetRandomEmptyPointID()
{
	ArrayClear(g_aSpawns);

	static Float:vPoint[3];
	for(new PointID; PointID < SP_GetPointsNum(); PointID++)
	{
		SP_GetPointOrigin(PointID, vPoint);
		if(UTIL_IsHullVacant(vPoint, HULL_HUMAN))
			ArrayPushCell(g_aSpawns, PointID);
	}

	if(!ArraySize(g_aSpawns))
		return -1;

	return ArrayGetCell(g_aSpawns, random(ArraySize(g_aSpawns)));
}
stock SP_GetPointsNum()
{
	return ArraySize(g_aClownSpawnX);
}
stock bool:SP_SavePoints()
{	
	if(!SP_GetPointsNum())
		return false;

	new szCfgDir[32]; get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	new szMapName[32]; get_mapname(szMapName, charsmax(szMapName));

	new szFileDir[96]; 

	formatex(szFileDir, charsmax(szFileDir), 
		"%s/%s",
		szCfgDir,
		SP_DIR
	);

	if(!dir_exists(szFileDir))
		mkdir(szFileDir);

	formatex(szFileDir, charsmax(szFileDir), 
		"%s/%s/%s.spawns.cfg", 
		szCfgDir, SP_DIR, szMapName
	);

	if(file_exists(szFileDir))
		delete_file(szFileDir);

	new Float:vPoint[3];
	new szBuffer[64];
	for(new PointID = 0; PointID < SP_GetPointsNum(); PointID++)
	{
		SP_GetPointOrigin(PointID, vPoint);

		formatex(szBuffer, charsmax(szBuffer), 
			"^"%.1f^" ^"%.1f^" ^"%.1f^"", 
			vPoint[0], vPoint[1], vPoint[2]
		);

		write_file(szFileDir, szBuffer);
	}

	return true;
}
stock SP_LoadPoints()
{
	new szCfgDir[32]; get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	new szMapName[32]; get_mapname(szMapName, charsmax(szMapName));
	new szFileDir[96]; 

	formatex(szFileDir, charsmax(szFileDir), 
		"%s/%s/%s.spawns.cfg", 
		szCfgDir, SP_DIR, szMapName
	);

	if(!file_exists(szFileDir))
		return 0;

	new iFile = fopen(szFileDir, "rt");

	if(!iFile)
		return 0;

	new szBuffer[64];
	new Float:vPoint[3];
	new szPoint[3][7];
	while(iFile && !feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer));
		if(!szBuffer[0] || szBuffer[0] == ';') 
			continue;

		parse(szBuffer, szPoint[0], 6, szPoint[1], 6, szPoint[2], 6);

		vPoint[0] = str_to_float(szPoint[0]);	
		vPoint[1] = str_to_float(szPoint[1]);	
		vPoint[2] = str_to_float(szPoint[2]);	

		SP_AddPoint(vPoint);
	}
	fclose(iFile);
	return SP_GetPointsNum();
}
stock ENG_trace_line(pEntity, Float:vSrc[3], Float:vEnd[3], Float:vEndPos[3])
{
	engfunc(EngFunc_TraceLine, vSrc, vEnd, DONT_IGNORE_MONSTERS, pEntity, g_iTrace);
	get_tr2(g_iTrace, TR_vecEndPos, vEndPos);
}
stock bool:ENG_trace_hull(Float:vSrc[3], Float:vEnd[3], iHullType, pEntity = 0, Flags = 0)
{
	engfunc(EngFunc_TraceHull, vSrc, vEnd, Flags, iHullType, pEntity, g_iTrace);
	
	if(get_tr2(g_iTrace, TR_StartSolid) || get_tr2(g_iTrace, TR_AllSolid) || !get_tr2(g_iTrace, TR_InOpen))
		return true;
	return false;
}
stock bool:ENG_is_visible(pEntity, pEntity2)
{
	static Float:vOrigin[3];
	static Float:vLooker[3];
	static Float:vTarget[3];
	entity_get_vector(pEntity, EV_VEC_origin, vOrigin);
	entity_get_vector(pEntity, EV_VEC_view_ofs, vLooker);
	xs_vec_add(vLooker, vOrigin, vLooker);
	entity_get_vector(pEntity2, EV_VEC_origin, vOrigin);
	entity_get_vector(pEntity2, EV_VEC_view_ofs, vTarget);
	xs_vec_add(vTarget, vOrigin, vTarget);
	static Solid; Solid = entity_get_int(pEntity2, EV_INT_solid);
	entity_set_int(pEntity2, EV_INT_solid, SOLID_NOT);
	engfunc(EngFunc_TraceLine, vLooker, vTarget, DONT_IGNORE_MONSTERS, pEntity, g_iTrace);
	entity_set_int(pEntity2, EV_INT_solid, Solid);
	if(get_tr2(g_iTrace, TR_InOpen) && get_tr2(g_iTrace, TR_InWater))
		return false;
	static Float:fFraction; get_tr2(g_iTrace, TR_flFraction, fFraction);
	if(fFraction == 1.0)
		return true;
	return false;
}
stock UTIL_PlaySound(iIndex = 0, szSound[], bool:bLoop = false) 
{
	new szTemp[128]; copyc(szTemp, charsmax(szTemp), szSound, '.');
	if(contain(szSound, ".mp3") != -1) 
		client_cmd(iIndex, "mp3 %s ^"sound/%s^"", bLoop ? "loop" : "play", szTemp);
	else 
		client_cmd(iIndex, "spk ^"%s^"", szTemp);
}
stock UTIL_StopSound(iIndex = 0) 
{
	client_cmd(iIndex, "stopsound;mp3 stop");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

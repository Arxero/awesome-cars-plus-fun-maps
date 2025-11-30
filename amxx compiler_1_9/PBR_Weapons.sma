#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <fun>

#define PLUGIN "[PBR] Weapons"
#define VERSION "1.0"
#define AUTHOR "Sneaky.amxx"

// Weapons (V, P, W)
#define MAX_MODEL 3
#define BALL_COLOR 1

new const GunMARKER[MAX_MODEL+1][] = { "models/paintballR/v_marker_r.mdl", "models/paintballR/v_marker_b.mdl", "models/paintballR/p_marker.mdl", "models/paintballR/w_marker.mdl" }
new const GunUSP[MAX_MODEL][] = { "models/paintballR/v_usp.mdl", "models/paintballR/p_usp.mdl", "models/w_usp.mdl" }
new const GunGLOCK[MAX_MODEL][] = { "models/paintballR/v_glock.mdl", "models/paintballR/p_glock.mdl", "models/w_glock18.mdl" }
new const GunSNIPER[MAX_MODEL][] = { "models/paintballR/v_sniper.mdl", "models/paintballR/p_sniper.mdl", "models/paintballR/w_sniper.mdl" }
new const GunGL[MAX_MODEL][] = { "models/paintballR/v_launcher.mdl", "models/paintballR/p_launcher.mdl", "models/paintballR/w_launcher.mdl" }
new const GunKNIFE[MAX_MODEL][] = { "models/paintballR/v_knife.mdl", "models/paintballR/p_knife.mdl", "models/paintballR/p_knife.mdl" }
new const GunVEN[MAX_MODEL+1][] = { "models/paintballR/v_vendetta_r.mdl", "models/paintballR/v_vendetta_b.mdl", "models/paintballR/p_vendetta.mdl", "models/paintballR/w_vendetta.mdl" }
new const GunSG[MAX_MODEL][] = { "models/paintballR/v_shotgun.mdl", "models/paintballR/p_shotgun.mdl", "models/paintballR/w_shotgun.mdl" }
new const GunSGL[MAX_MODEL][] = { "models/paintballR/v_superlauncher.mdl", "models/paintballR/p_superlauncher.mdl", "models/paintballR/s_launcher.mdl" }

#define MAX_GUN 9

enum
{
	GUN_MARKER = 0, // mp5
	GUN_USP, // usp
	GUN_GLOCK, // glock
	GUN_SNIPER, // scout
	GUN_GL, // m3
	GUN_KNIFE, // knife
	GUN_VEN, // p90
	GUN_SG, // xm1014
	GUN_SGL // flashbang
}

new const Float:GunROF[MAX_GUN] = // Firing Speed
{
	0.15, // marker
	0.15, // usp
	0.15, // glock
	0.0, // sniper (can't use)
	1.0, // launcher
	0.0, // knife (can't use)
	0.1, // vendetta
	0.75, // shotgun
	0.0 // super launcher (can't use)
}

new const GunBallSpeed[MAX_GUN] =
{
	2000, // maker
	1500, // usp
	1500, // glock
	2000, // sniper // Dont set over 2000
	1500, // launcher
	0, // knife (can't use)
	2500, // vendetta
	1500, // shotgun
	1500 // super launcher
}

new const WeaponSysName[MAX_GUN][] =
{
	"weapon_mp5navy",
	"weapon_usp",
	"weapon_glock18",
	"weapon_scout",
	"weapon_m3",
	"weapon_knife",
	"weapon_p90",
	"weapon_xm1014",
	"weapon_flashbang"
}

new const WeaponFireSounds[7][] =
{
	"paintballR/weapons/pb_launcher.wav",
	"paintballR/weapons/pb1.wav",
	"paintballR/weapons/pb2.wav",
	"paintballR/weapons/pb3.wav",
	"paintballR/weapons/pb4.wav",
	"paintballR/weapons/pbg.wav",
	"paintballR/weapons/bulldog_shoot.wav"
}

new const ExtraWeaponSounds[8][] =
{
	"weapons/bulldog_draw.wav",
	"weapons/draw.wav",
	"weapons/insert.wav",
	"weapons/Magin.wav",
	"weapons/Magout.wav",
	"weapons/magrel.wav",
	"weapons/pullout.wav",
	"weapons/roll.wav"
}

new const S_Launcher[] = "models/paintballR/s_launcher.mdl"
new const PaintBall[] = "models/paintballR/w_paintball.mdl"
new const PaintExp[] = "sprites/paintballR/paintball.spr"

new Float:g_Recoil[33][3]
new g_HamBot, g_WeaponEvent[MAX_GUN], Float:DelayTime[33], blood1, blood2
new g_OldWeapon[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_touch("paintball", "*", "fw_PaintBall_Touch")
	register_think("paintball", "fw_PaintBall_Think")

	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel, "fw_SetModel")
	
	for(new i = 0; i < MAX_GUN; i++)
	{
		RegisterHam(Ham_Item_Deploy, WeaponSysName[i], "fw_Item_Deploy_Post", 1)	
		if(i != 8) RegisterHam(Ham_Weapon_PrimaryAttack, WeaponSysName[i], "fw_Weapon_PrimaryAttack")
		if(i != 8) RegisterHam(Ham_Weapon_PrimaryAttack, WeaponSysName[i], "fw_Weapon_PrimaryAttack_Post", 1)
	}
	
	RegisterHam(Ham_Item_PostFrame, "weapon_m3", "fw_Item_PostFrame")
	RegisterHam(Ham_Item_PostFrame, "weapon_xm1014", "fw_Item_PostFrame")
		
	RegisterHam(Ham_Think, "grenade", "fw_Grenade_Think")
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player")	
	
	register_clcmd("say /shit", "Shit")
	
	
}

public Shit(id) 
{
	static Float:Test[3]
	Create_PaintBall(id, Test)
}

public plugin_precache()
{
	for(new i = 0; i < sizeof(GunMARKER); i++)
		precache_model(GunMARKER[i])
	for(new i = 0; i < sizeof(GunUSP); i++)
		precache_model(GunUSP[i])
	for(new i = 0; i < sizeof(GunGLOCK); i++)
		precache_model(GunGLOCK[i])
	for(new i = 0; i < sizeof(GunSNIPER); i++)
		precache_model(GunSNIPER[i])
	for(new i = 0; i < sizeof(GunGL); i++)
		precache_model(GunGL[i])
	for(new i = 0; i < sizeof(GunKNIFE); i++)
		precache_model(GunKNIFE[i])
	for(new i = 0; i < sizeof(GunVEN); i++)
		precache_model(GunVEN[i])
	for(new i = 0; i < sizeof(GunSG); i++)
		precache_model(GunSG[i])
	for(new i = 0; i < sizeof(GunSGL); i++)
		precache_model(GunSGL[i])
		
	for(new i = 0; i < sizeof(WeaponFireSounds); i++)
		precache_sound(WeaponFireSounds[i])
	for(new i = 0; i < sizeof(ExtraWeaponSounds); i++)
		precache_sound(ExtraWeaponSounds[i])

	precache_model(S_Launcher)
	precache_model(PaintBall)
	precache_model(PaintExp)
	blood1 = precache_model("sprites/blood.spr");
	blood2 = precache_model("sprites/bloodspray.spr");
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal("events/mp5n.sc", name)) g_WeaponEvent[GUN_MARKER] = get_orig_retval()	
	else if(equal("events/usp.sc", name)) g_WeaponEvent[GUN_USP] = get_orig_retval()	
	else if(equal("events/glock18.sc", name)) g_WeaponEvent[GUN_GLOCK] = get_orig_retval()	
	else if(equal("events/scout.sc", name)) g_WeaponEvent[GUN_SNIPER] = get_orig_retval()	
	else if(equal("events/m3.sc", name)) g_WeaponEvent[GUN_GL] = get_orig_retval()	
	else if(equal("events/p90.sc", name)) g_WeaponEvent[GUN_VEN] = get_orig_retval()	
	else if(equal("events/xm1014.sc", name)) g_WeaponEvent[GUN_SG] = get_orig_retval()	
}

public client_putinserver(id)
{
	if(!g_HamBot && is_user_bot(id))
	{
		g_HamBot = 1
		set_task(0.1, "Do_Register_HamBot", id)
	}
}

public Do_Register_HamBot(id) 
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack_Player")	
}

public Event_CurWeapon(id)
{
	static CSW; CSW = read_data(2)
	static GUN; GUN = Get_PaintBallGun(CSW)
	if(GUN == -1)
		return
	
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW)
	if(!pev_valid(Ent)) 
	{
		g_OldWeapon[id] = CSW
		return
	}
	
	if(CSW != CSW_SCOUT)
	{
		set_pdata_float(Ent, 46, GunROF[GUN], 4)
		set_pdata_float(Ent, 47, GunROF[GUN], 4)
	}
	
	//Remove the crosshair
	///message_begin(MSG_ONE_UNRELIABLE, g_MsgHideWeapon, _, id)
	//write_byte((1<<6))
	//message_end()
	
	g_OldWeapon[id] = CSW
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
		
	static CSW; CSW = get_user_weapon(id)
	static GUN; GUN = Get_PaintBallGun(CSW)
	
	if(CSW == CSW_FLASHBANG) return FMRES_IGNORED
	if(GUN != -1) set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED
		
	static CSW; CSW = get_user_weapon(invoker)
	static GUN; GUN = Get_PaintBallGun(CSW)
	
	if(GUN == -1) return FMRES_IGNORED
	
	if(eventid == g_WeaponEvent[GUN])
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
		static Anim, Sound
		
		static Ent; Ent = fm_get_user_weapon_entity(invoker, CSW)
		if(!pev_valid(Ent)) return FMRES_IGNORED
		
		static Float:Shit[3]
		
		switch(GUN)
		{
			case GUN_MARKER:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = 3
				Sound = 5
			}
			case GUN_USP:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = cs_get_weapon_silen(Ent) ? 1 : 9
				Sound = 5
			}
			case GUN_GLOCK:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = 5
				Sound = 5
			}
			case GUN_SNIPER:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = random_num(1, 2)
				Sound = 5
			}
			case GUN_GL:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = 1
				Sound = 0
			}
			case GUN_VEN:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = 3
				Sound = 5
			}
			case GUN_SG:
			{
				Anim = 1
				Sound = 5
			}
			case GUN_SGL:
			{
				Create_PaintBall(invoker, Shit)
				
				Anim = 2
				Sound = 0
			}
		}
		
		Set_WeaponAnim(invoker, Anim)
		emit_sound(invoker, CHAN_WEAPON, WeaponFireSounds[Sound], 1.0, 0.4, 0, 94 + random_num(0, 15))
			
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}


public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static Classname[32]
	pev(entity, pev_classname, Classname, sizeof(Classname))

	if(equal(model, "models/w_mp5.mdl"))
	{
		engfunc(EngFunc_SetModel, entity, GunMARKER[3])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_usp.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunUSP[2])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_glock18.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunGLOCK[2])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_scout.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunSNIPER[2])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_m3.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunGL[2])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_p90.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunVEN[3])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_xm1014.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunSG[2])
		return FMRES_SUPERCEDE
	} else if(equal(model, "models/w_flashbang.mdl")) {
		engfunc(EngFunc_SetModel, entity, GunSGL[2])
		set_pev(entity, pev_bInDuck, 162)
		
		return FMRES_SUPERCEDE
	} 

	return FMRES_IGNORED;
}

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, 41, 4)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	
	static CSW; CSW = cs_get_weapon_id(Ent)
	static Gun; Gun = Get_PaintBallGun(CSW)
	
	if(Gun == -1) return
	static ModelV[64], ModelP[64]
	
	switch(Gun)
	{
		case GUN_MARKER:
		{
			formatex(ModelV, 63, "%s", cs_get_user_team(Id) == CS_TEAM_T ? GunMARKER[0] : GunMARKER[1])
			formatex(ModelP, 63, "%s", GunMARKER[2])
		}
		case GUN_USP:
		{
			formatex(ModelV, 63, "%s", GunUSP[0])
			formatex(ModelP, 63, "%s", GunUSP[1])
		}
		case GUN_GLOCK:
		{
			formatex(ModelV, 63, "%s", GunGLOCK[0])
			formatex(ModelP, 63, "%s", GunGLOCK[1])
		}
		case GUN_SNIPER:
		{
			formatex(ModelV, 63, "%s", GunSNIPER[0])
			formatex(ModelP, 63, "%s", GunSNIPER[1])
		}
		case GUN_GL:
		{
			formatex(ModelV, 63, "%s", GunGL[0])
			formatex(ModelP, 63, "%s", GunGL[1])
		}
		case GUN_KNIFE:
		{
			formatex(ModelV, 63, "%s", GunKNIFE[0])
			formatex(ModelP, 63, "%s", GunKNIFE[1])
		}
		case GUN_VEN:
		{
			formatex(ModelV, 63, "%s", cs_get_user_team(Id) == CS_TEAM_T ? GunVEN[0] : GunVEN[1])
			formatex(ModelP, 63, "%s", GunVEN[2])
		}
		case GUN_SG:
		{
			formatex(ModelV, 63, "%s", GunSG[0])
			formatex(ModelP, 63, "%s", GunSG[1])
		}
		case GUN_SGL:
		{
			formatex(ModelV, 63, "%s", GunSGL[0])
			formatex(ModelP, 63, "%s", GunSGL[1])
		}
	}
	
	set_pev(Id, pev_viewmodel2, ModelV)
	set_pev(Id, pev_weaponmodel2, ModelP)
}

public fw_TraceAttack_World(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
		
	static Float:flEnd[3]
	get_tr2(Ptr, TR_vecEndPos, flEnd)
	
	static CSW; CSW = get_user_weapon(Attacker)
	static Gun; Gun = Get_PaintBallGun(CSW)
	
	if(get_user_weapon(Attacker) != CSW_KNIFE)
	{
		if(Gun == GUN_SG) Create_PaintBall(Attacker, flEnd)
		SetHamParamFloat(3, 0.0)
		return HAM_SUPERCEDE
	} else {
		SetHamParamFloat(3, 125.0)
	}
	
	return HAM_IGNORED
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	

	static Float:flEnd[3]
	get_tr2(Ptr, TR_vecEndPos, flEnd)
		
	static CSW; CSW = get_user_weapon(Attacker)
	static Gun; Gun = Get_PaintBallGun(CSW)
		
	if(get_user_weapon(Attacker) != CSW_KNIFE)
	{
		if(Gun == GUN_SG) Create_PaintBall(Attacker, flEnd)
		SetHamParamFloat(3, 0.0)
		return HAM_SUPERCEDE
	} else {
		SetHamParamFloat(3, 125.0)
	}
	
	return HAM_IGNORED
}

public fw_Grenade_Think(ent)
{
	if(!pev_valid(ent)) 
		return HAM_IGNORED
	
	static Float:DMGTime; pev(ent, pev_dmgtime, DMGTime)
	if(DMGTime > get_gametime()) 
		return HAM_IGNORED
	
	if(pev(ent, pev_bInDuck) == 162)
	{		
		set_task(1.5, "Metatron_Exp", ent);
		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public Metatron_Exp(ent)
{
	for (new a = 0; a < 10; a++)
		set_task(0.1 + a*0.2, "Super_SmallExp", ent);	
	
	set_task(2.5, "remove_nade", ent);	
}

public Super_SmallExp(Bomb)
{
	if(!pev_valid(Bomb)) return
	
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	
	static id; id = pev(Bomb, pev_owner)
	if(!is_user_connected(id)) return
	
	static Float:Origin[3]; pev(Bomb, pev_origin, Origin)
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_BOUNCE)
	//set_pev(Ent, pev_rendermode, kRenderTransAdd)
	//set_pev(Ent, pev_renderamt, 255.0)
	set_pev(Ent, pev_iuser1, id) // Better than pev_owner
	set_pev(Ent, pev_iuser2, get_user_team(id))
	
	entity_set_string(Ent, EV_SZ_classname, "paintball")
	engfunc(EngFunc_SetModel, Ent, PaintBall)
	
	set_pev(Ent, pev_mins, Float:{-3.0, -3.0, -3.0})
	set_pev(Ent, pev_maxs, Float:{3.0, 3.0, 3.0})
	set_pev(Ent, pev_scale, 1.0)
	set_pev(Ent, pev_origin, Origin)
	set_pev(Ent, pev_gravity, 1.0)
	set_pev(Ent, pev_solid, SOLID_TRIGGER)
	set_pev(Ent, pev_frame, 0.0)
	set_pev(Ent, pev_iuser3, 249)
	set_pev(Ent, pev_iuser4, 2)
	
	static clr
	switch(BALL_COLOR)
	{
		case 2: clr = (get_user_team(id) == 1) ? 0 : 1;
		case 3: clr = (get_user_team(id) == 1) ? 4 : 3;
		case 4: clr = (get_user_team(id) == 1) ? 2 : 5;
		default: clr = random_num(0, 6);
	}
	set_pev(Ent, pev_skin, clr);
	
	static Float:Velocity[3]
	Velocity[0] = random_float(-200.0, 200.0);
	Velocity[1] = random_float(-200.0, 200.0);
	Velocity[2] = random_float(200.0, 400.0)	
	
	set_pev(Ent, pev_velocity, Velocity)
	
	DelayTime[id] = get_gametime()
}

public remove_nade(ent)
{
	if(!pev_valid(ent)) return 
	
	//act_explode(ent);
	engfunc(EngFunc_RemoveEntity, ent);
}

public fw_PaintBall_Touch(Ent, id)
{
	if(!pev_valid(Ent)) return
	if(pev(Ent, pev_movetype) == MOVETYPE_NONE) return
	
	if(pev(Ent, pev_iuser4) == 1) // Explosion ?
	{
		static Float:Velocity[3]; pev(Ent, pev_velocity, Velocity)
		xs_vec_mul_scalar(Velocity, 0.25, Velocity)
		
		set_pev(Ent, pev_gravity, 1.5)
		set_pev(Ent, pev_velocity, Velocity)
		
		set_pev(Ent, pev_iuser4, 2)
		return
	}
	
	if(pev(Ent, pev_iuser4) == 2) // Explosion ?
	{
		static Float:Origin[3]; pev(Ent, pev_origin, Origin)
		PaintBall_Exp(Ent, Origin)
		
		static Owner; Owner = pev(Ent, pev_iuser1)
		if(is_user_connected(Owner)) PaintBall_Damage(Ent, Owner)

		remove_entity(Ent)
		return
	}
	
	if(is_user_alive(id))
	{
		static Owner; Owner = pev(Ent, pev_iuser1)
		if(is_user_connected(Owner) && Owner != id) 
		{
			static Ent; Ent = fm_get_user_weapon_entity(id, get_user_weapon(id))
			ExecuteHamB(Ham_TakeDamage, id, Ent, Owner, 560.0, DMG_BULLET)
		}
		
		remove_entity(Ent)
	} else {
		if(pev_valid(id) && pev(id, pev_iuser3) == 249) 
			return
		
		if(random_num(0, 100) >= 20)
		{
			set_pev(Ent, pev_velocity, {0.0, 0.0, 0.0})
			set_pev(Ent, pev_movetype, MOVETYPE_NONE)
			set_pev(Ent, pev_solid, SOLID_NOT)
			engfunc(EngFunc_SetModel, Ent, PaintExp);
			
			paint_splat(Ent)
			set_pev(Ent, pev_nextthink, get_gametime() + random_float(3.0, 6.0))
		} else {
			set_pev(Ent, pev_movetype, MOVETYPE_BOUNCE)
		
			static Float:Velocity[3]; pev(Ent, pev_velocity, Velocity)
			xs_vec_mul_scalar(Velocity, 0.25, Velocity)
			
			set_pev(Ent, pev_gravity, 1.5)
			set_pev(Ent, pev_velocity, Velocity)
		}
		
		emit_sound(Ent, CHAN_AUTO, WeaponFireSounds[random_num(1, 4)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		
	}
}

public PaintBall_Exp(Ent, Float:Origin[3])
{
	static IOrigin[3]
	FVecIVec(Origin, IOrigin)
	
	static colors[4]
	colors = (pev(Ent, pev_iuser2) == 1) ? { 255, 0, 247, 70} : { 0, 255, 208, 30};
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSPRITE);
	write_coord(IOrigin[0]);
	write_coord(IOrigin[1]);
	write_coord(IOrigin[2] + 20);
	write_short(blood2);
	write_short(blood1);
	write_byte(colors[2]);
	write_byte(30);
	message_end();
	
	emit_sound(Ent, CHAN_AUTO, "weapons/sg_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public PaintBall_Damage(Ent, Attacker)
{
	static Gun; Gun = fm_get_user_weapon_entity(Attacker, get_user_weapon(Attacker))
	
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(!is_user_alive(i))
			continue
		if(entity_range(Ent, i) > 120.0)
			continue
			
		ExecuteHamB(Ham_TakeDamage, i, Gun, Attacker, 100.0, DMG_BULLET)
	}
}

public fw_PaintBall_Think(Ent)
{
	if(!pev_valid(Ent)) return
	remove_entity(Ent)
}

public Create_PaintBall(id, Float:Target[3])
{
	static CSW; CSW = get_user_weapon(id)
	static Gun; Gun = Get_PaintBallGun(CSW)
	
	if(Gun == -1) return
	
	// Create Ammo
	static Float:StartOrigin[3]
	static Float:TargetOrigin[3]; TargetOrigin = Target
	
	Get_Position(id, 48.0, 10.0, -5.0, StartOrigin)
	if(Gun != GUN_SG) fm_get_aim_origin(id, TargetOrigin)
	
	if(Gun == GUN_SNIPER) 
	{
		Get_Position(id, 48.0, 0.0, 0.0, StartOrigin)
	} else {
		
	}
	
	if(Gun == GUN_GL)
	{
		if(get_gametime() - 0.1 > DelayTime[id])
		{
			static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
			if(!pev_valid(Ent)) return
			
			static Float:Angles[3]; pev(id, pev_v_angle, Angles)
			
			Angles[0] *= -1.0
			
			// Set info for ent
			set_pev(Ent, pev_movetype, MOVETYPE_BOUNCE)
			//set_pev(Ent, pev_rendermode, kRenderTransAdd)
			//set_pev(Ent, pev_renderamt, 255.0)
			set_pev(Ent, pev_iuser1, id) // Better than pev_owner
			set_pev(Ent, pev_iuser2, get_user_team(id))
			
			entity_set_string(Ent, EV_SZ_classname, "paintball")
			engfunc(EngFunc_SetModel, Ent, S_Launcher)
			
			set_pev(Ent, pev_mins, Float:{-3.0, -3.0, -3.0})
			set_pev(Ent, pev_maxs, Float:{3.0, 3.0, 3.0})
			set_pev(Ent, pev_scale, 0.1)
			set_pev(Ent, pev_origin, StartOrigin)
			set_pev(Ent, pev_gravity, 1.0)
			set_pev(Ent, pev_solid, SOLID_TRIGGER)
			set_pev(Ent, pev_frame, 0.0)
			set_pev(Ent, pev_iuser3, 249)
			set_pev(Ent, pev_iuser4, 1)
			set_pev(Ent, pev_angles, Angles)
			
			static Float:Velocity[3]
			//get_speed_vector(StartOrigin, TargetOrigin, GunBallSpeed[Gun], Velocity)
			velocity_by_aim(id, GunBallSpeed[Gun], Velocity)
			set_pev(Ent, pev_velocity, Velocity)
			
			DelayTime[id] = get_gametime()
		}
		
		return
	}
	
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	//set_pev(Ent, pev_rendermode, kRenderTransAdd)
	//set_pev(Ent, pev_renderamt, 255.0)
	set_pev(Ent, pev_iuser1, id) // Better than pev_owner
	set_pev(Ent, pev_owner, id)
	
	entity_set_string(Ent, EV_SZ_classname, "paintball")
	engfunc(EngFunc_SetModel, Ent, PaintBall)
	
	set_pev(Ent, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(Ent, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(Ent, pev_scale, 0.5)
	engfunc(EngFunc_SetOrigin, Ent, StartOrigin);
	set_pev(Ent, pev_gravity, 0.5)
	set_pev(Ent, pev_solid, SOLID_TRIGGER)
	set_pev(Ent, pev_iuser3, 249)
	set_pev(Ent, pev_iuser4, 0)
	
	static Float:vangles[3]
	vangles[0] = random_float(-180.0, 180.0);
	vangles[1] = random_float(-180.0, 180.0);
	set_pev(Ent, pev_angles, vangles);

	pev(id, pev_v_angle, vangles);
	set_pev(Ent, pev_v_angle, vangles);
	pev(id, pev_view_ofs, vangles);
	set_pev(Ent, pev_view_ofs, vangles);
	
	static clr
	switch(BALL_COLOR)
	{
		case 2: clr = (get_user_team(id) == 1) ? 0 : 1;
		case 3: clr = (get_user_team(id) == 1) ? 4 : 3;
		case 4: clr = (get_user_team(id) == 1) ? 2 : 5;
		default: clr = random_num(0, 6);
	}
	set_pev(Ent, pev_skin, clr);
	
	static Float:Velocity[3]
	//
	if(Gun != GUN_SG) velocity_by_aim(id, GunBallSpeed[Gun], Velocity)
	else get_speed_vector(StartOrigin, TargetOrigin, float(GunBallSpeed[Gun]), Velocity)
	
	set_pev(Ent, pev_velocity, Velocity)
}

new Float:g_PostFrame[33]

public fw_Item_PostFrame( iEnt )
{
	static id ; id = get_pdata_cbase(iEnt, 41, 4)	

	if(get_pdata_int(iEnt, 55, 4) == 1)
	{
		static Float:CurTime
		CurTime = get_gametime()
		
		if(CurTime - 0.75 > g_PostFrame[id])
		{
			Set_WeaponAnim(id, 3)
			g_PostFrame[id] = CurTime
		}
	}
}

public fw_Weapon_PrimaryAttack(Ent)
{
	static id; id = pev(Ent, pev_owner)
	pev(id, pev_punchangle, g_Recoil[id])
	
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	static id; id = pev(Ent, pev_owner)
	
	if(cs_get_weapon_ammo(Ent) >= 0)
	{
		static Float:Push[3]
		pev(id, pev_punchangle, Push)
		xs_vec_sub(Push, g_Recoil[id], Push)
		
		xs_vec_mul_scalar(Push, 0.0, Push)
		xs_vec_add(Push, g_Recoil[id], Push)
		set_pev(id, pev_punchangle, Push)
	}
}

public paint_splat(ent)
{
	new Float:origin[3], Float:norigin[3], Float:viewofs[3], Float:angles[3], Float:normal[3], Float:aiming[3];
	pev(ent, pev_origin, origin);
	pev(ent, pev_view_ofs, viewofs);
	pev(ent, pev_v_angle, angles);

	norigin[0] = origin[0] + viewofs[0];
	norigin[1] = origin[1] + viewofs[1];
	norigin[2] = origin[2] + viewofs[2];
	aiming[0] = norigin[0] + floatcos(angles[1], degrees) * 1000.0;
	aiming[1] = norigin[1] + floatsin(angles[1], degrees) * 1000.0;
	aiming[2] = norigin[2] + floatsin(-angles[0], degrees) * 1000.0;
	
	new tr = 0
	engfunc(EngFunc_TraceLine, norigin, aiming, 0, ent, tr);
	//get_tr2(tr, TR_vecPlaneNormal, normal);
	//EngFunc_TraceHull,(const float *v1, const float *v2, int fNoMonsters, int hullNumber, edict_t *pentToSkip, TraceResult *ptr);
	//engfunc(EngFunc_TraceHull, norigin, aiming, 0, HULL_LARGE, ent, tr)
	get_tr2(tr, TR_vecPlaneNormal, normal)

	
	vector_to_angle(normal, angles);
	angles[1] += 180.0;
	if (angles[1] >= 360.0) angles[1] -= 360.0;	
	
	set_pev(ent, pev_angles, angles);
	set_pev(ent, pev_v_angle, angles);

	origin[0] += (normal[0] * random_float(0.3, 2.7));
	origin[1] += (normal[1] * random_float(0.3, 2.7));
	origin[2] += (normal[2] * random_float(0.3, 2.7));
	engfunc(EngFunc_SetOrigin, ent, origin);
	set_pev(ent, pev_frame, float(random_num( (pev(ent, pev_skin) * 18), (pev(ent, pev_skin) * 18) + 17 ) ));

	if (pev(ent, pev_renderfx) != kRenderFxNone)
		set_rendering(ent);	

}

public Get_PaintBallGun(CSW)
{
	static Gun;

	switch(CSW)
	{
		case CSW_MP5NAVY: Gun = GUN_MARKER
		case CSW_USP: Gun = GUN_USP
		case CSW_GLOCK18: Gun = GUN_GLOCK
		case CSW_SCOUT: Gun = GUN_SNIPER
		case CSW_M3: Gun = GUN_GL
		case CSW_KNIFE: Gun = GUN_KNIFE
		case CSW_P90: Gun = GUN_VEN
		case CSW_XM1014: Gun = GUN_SG
		case CSW_FLASHBANG: Gun = GUN_SGL
		default: Gun = -1
	}
	
	return Gun
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock Set_WeaponAnim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock Get_Position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp) //for player
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

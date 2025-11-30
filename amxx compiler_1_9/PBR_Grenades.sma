#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#define PLUGIN "[PBR] Grenades"
#define VERSION "1.0"
#define AUTHOR "Sneaky.amxx"

#define RADIUS 150.0
#define IMPACT_EXPLOSION 0

// Hegrenade
#define MODEL_HV "models/paintballR/v_hegrenade.mdl"
#define MODEL_HP "models/paintballR/p_grenade.mdl"
#define MODEL_HW "models/paintballR/w_grenade.mdl"
#define MODEL_HW_OLD "models/w_hegrenade.mdl"

// Smokegrenade
#define MODEL_SV "models/paintballR/v_smokegrenade.mdl"
#define MODEL_SP "models/paintballR/p_grenade.mdl"
#define MODEL_SW "models/paintballR/w_grenade.mdl"
#define MODEL_SW_OLD "models/w_smokegrenade.mdl"

new Blood[2], Smoke[6], g_MaxPlayers
new g_Cvar_Enable[2]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Touch, "grenade", "fw_GrenadeTouch")
	RegisterHam(Ham_Think, "grenade", "fw_GrenadeThink")
	
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "fw_Item_DeployH_Post", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "fw_Item_DeployS_Post", 1)
	
	g_Cvar_Enable[0] = register_cvar("gothic_hegrenade_enable", "1")
	g_Cvar_Enable[1] = register_cvar("gothic_smokegrenade_enable", "1")
	
	g_MaxPlayers = get_maxplayers()
}

public plugin_precache()
{
	precache_model(MODEL_HV); precache_model(MODEL_HP); precache_model(MODEL_HW)
	precache_model(MODEL_SV); precache_model(MODEL_SP); precache_model(MODEL_SW)
	
	Blood[0] = precache_model("sprites/blood.spr");
	Blood[1] = precache_model("sprites/bloodspray.spr");

	Smoke[0] = precache_model("sprites/paintballR/gas_puff_01b.spr");
	Smoke[1] = precache_model("sprites/paintballR/gas_puff_01r.spr");
	Smoke[2] = precache_model("sprites/paintballR/gas_puff_01g.spr");
	Smoke[3] = precache_model("sprites/paintballR/gas_puff_01y.spr");
	Smoke[4] = precache_model("sprites/paintballR/gas_puff_01m.spr");
	Smoke[5] = precache_model("sprites/paintballR/gas_puff_01o.spr");
}

public fw_SetModel(Ent, const Model[])
{
	static id; id = pev(Ent, pev_owner)
	if(!is_user_connected(id)) return FMRES_IGNORED
		
	static Float:DMGTime; pev(Ent, pev_dmgtime, DMGTime)
	if(DMGTime == 0.0) return FMRES_IGNORED
	
	if(equal(Model, MODEL_HW_OLD) && get_pcvar_num(g_Cvar_Enable[0]))
	{
		static Team; Team = get_user_team(id)
		
		set_pev(Ent, pev_team, Team)
		engfunc(EngFunc_SetModel, Ent, MODEL_HW)
		
		set_pev(Ent, pev_bInDuck, 149)
		
		return FMRES_SUPERCEDE
	} else if(equal(Model, MODEL_SW_OLD) && get_pcvar_num(g_Cvar_Enable[1])) {
		static Team; Team = get_user_team(id)
		
		set_pev(Ent, pev_team, Team)
		engfunc(EngFunc_SetModel, Ent, MODEL_SW)
		
		set_pev(Ent, pev_bInDuck, 150)

		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_GrenadeTouch(Ent, Touched)
{
	if(!pev_valid(Ent)) 
		return HAM_IGNORED
		
	static Impact; Impact = IMPACT_EXPLOSION
	if(Impact) set_pev(Ent, pev_dmgtime, get_gametime())
	
	return HAM_IGNORED
}

public fw_GrenadeThink(Ent)
{
	if(!pev_valid(Ent)) 
		return HAM_IGNORED
	
	static Float:DMGTime; pev(Ent, pev_dmgtime, DMGTime)
	if(DMGTime > get_gametime()) 
		return HAM_IGNORED
	
	if(pev(Ent, pev_bInDuck) == 149) 
	{
		Hegrenade_Explosion(Ent)
		
		engfunc(EngFunc_RemoveEntity, Ent)
		return HAM_SUPERCEDE
	} else if(pev(Ent, pev_bInDuck) == 150) {
		Smokegrenade_Explosion(Ent)
		
		engfunc(EngFunc_RemoveEntity, Ent)
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public fw_Item_DeployH_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, 41, 4)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	//if(!Get_BitVar(g_Had_FrostNova, Id))
	//	return

	set_pev(Id, pev_viewmodel2, MODEL_HV)
	set_pev(Id, pev_weaponmodel2, MODEL_HP)
	
	//Set_WeaponAnim(Id, ANIM_DRAW)
}

public fw_Item_DeployS_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, 41, 4)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	//if(!Get_BitVar(g_Had_FrostNova, Id))
	//	return

	set_pev(Id, pev_viewmodel2, MODEL_SV)
	set_pev(Id, pev_weaponmodel2, MODEL_SP)
	
	//Set_WeaponAnim(Id, ANIM_DRAW)
}

public Hegrenade_Explosion(Ent)
{
	static Float:Origin[3], Origin2[3]
	static Team; Team = pev(Ent, pev_team)
	static RGB[4], id; id = pev(Ent, pev_owner)
	
	pev(Ent, pev_origin, Origin)
	FVecIVec(Origin, Origin2)
	
	RGB = (Team == 1) ? { 255, 0, 247, 70} : { 0, 255, 208, 30}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(Origin2[0])
	write_coord(Origin2[1])
	write_coord(Origin2[2] + 20)
	write_short(Blood[1]);
	write_short(Blood[0]);
	write_byte(RGB[2])
	write_byte(30)
	message_end()
	
	for(new i = 0; i < g_MaxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue
		if(get_user_team(i) == Team)
			continue
		if(entity_range(i, Ent) > RADIUS)
			continue
			
		ExecuteHam(Ham_TakeDamage, i, Ent, id, (i != id) ? 100.0 : 300.0, 0)
	}
	
	//client_print(id, print_chat, "Dias : Dias is in love with gaming and anime!")
	emit_sound(Ent, CHAN_WEAPON, "weapons/sg_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public Smokegrenade_Explosion(Ent)
{
	static Float:Origin[3], Origin2[3]
	static Color//, id; id = pev(Ent, pev_owner)
	
	pev(Ent, pev_origin, Origin)
	FVecIVec(Origin, Origin2)
	Color = random(6)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_FIREFIELD)
	write_coord(Origin2[0])
	write_coord(Origin2[1])
	write_coord(Origin2[2] + 50)
	write_short(100)
	write_short(Smoke[Color])
	write_byte(100)		
	write_byte(TEFIRE_FLAG_ALPHA)	
	write_byte(1000)		
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_FIREFIELD)
	write_coord(Origin2[0])
	write_coord(Origin2[1])
	write_coord(Origin2[2] + 50)
	write_short(150)
	write_short(Smoke[Color])
	write_byte(10)		
	write_byte(TEFIRE_FLAG_ALLFLOAT | TEFIRE_FLAG_ALPHA)	
	write_byte(1000)		
	message_end()
	
	//client_print(id, print_chat, "Dias : I think Mr.Thomas should donate me more money...")
	emit_sound(Ent, CHAN_WEAPON, "weapons/sg_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

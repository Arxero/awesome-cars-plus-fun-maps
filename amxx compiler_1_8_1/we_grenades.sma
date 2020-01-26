/* Sublime AMXX Editor v2.3 ReCreated by AJW1337// */

#include <amxmodx>

/* Common include libraries */
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN  "Winter Environment [Grenades]"
#define VERSION "1.0"
#define AUTHOR  "Huehue"
#define GAMETRACKER "we_grenades"

#define OFFSET_WEAPON		41
#define OFFSET_LINUX		4

new g_iSprite

new g_iGrenades[][] =
{
	/* He Grenade */
	"models/we/v_snowball_he.mdl",
	"models/we/p_snowball_he.mdl",
	/* FlashBang */
	"models/we/v_snowball_fb.mdl",
	"models/we/p_snowball_fb.mdl",
	/* Smoke Grenade */
	"models/we/v_snowball_sg.mdl",
	"models/we/p_snowball_sg.mdl",
	/* World Model */
	"models/we/w_snowball.mdl"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(GAMETRACKER, AUTHOR, FCVAR_SERVER | FCVAR_SPONLY)
	set_cvar_string(GAMETRACKER, AUTHOR)

	register_forward(FM_SetModel, "FM__SetModel")
	RegisterHam(Ham_Think, "grenade", "CBase__Ham_Think_Nade", false)
	
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "CBase__Ham_DeployHe", true)
	RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "CBase__Ham_DeployFb", true)
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "CBase__Ham_DeploySg", true)
}

public plugin_precache()
{
	for (new i = 0; i < sizeof (g_iGrenades); i++)
	{
		if (file_exists(g_iGrenades[i]))
			precache_model(g_iGrenades[i])
		else
			log_amx("File ^"%s^" not found!", g_iGrenades[i])
	}

	g_iSprite = precache_model("sprites/we/frostgib.spr")
}

public FM__SetModel(iEntity, const szModel[])
{
	if (!pev_valid(iEntity))
		return FMRES_IGNORED

	new szClassname[32]
	pev(iEntity, pev_classname, szClassname, charsmax(szClassname))

	if (equal(szClassname, "grenade"))
	{
		engfunc(EngFunc_SetModel, iEntity, g_iGrenades[6]) /* [6] = World Model */

		if (equali(szModel, "models/w_hegrenade.mdl"))
			set_pev(iEntity, pev_skin, 0)
		else if(equali(szModel, "models/w_flashbang.mdl"))
			set_pev(iEntity, pev_skin, 1)
		else if(equali(szModel, "models/w_smokegrenade.mdl"))
			set_pev(iEntity, pev_skin, 2)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public CBase__Ham_Think_Nade(iEntity)
{
	if (pev_valid(iEntity))
	{
		new Float:flOrigin[3]
		pev(iEntity, pev_origin, flOrigin)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITETRAIL)
		engfunc(EngFunc_WriteCoord, flOrigin[0])
		engfunc(EngFunc_WriteCoord, flOrigin[1])
		engfunc(EngFunc_WriteCoord, flOrigin[2])
		engfunc(EngFunc_WriteCoord, flOrigin[0])
		engfunc(EngFunc_WriteCoord, flOrigin[1])
		engfunc(EngFunc_WriteCoord, flOrigin[2])
		write_short(g_iSprite)
		write_byte(9)
		write_byte(random_num(27, 30))
		write_byte(2)
		write_byte(10)
		write_byte(10)
		message_end()
	}
	
	return HAM_IGNORED
}

public CBase__Ham_DeployHe(iWeapon)
{
	new iPlayer = get_pdata_cbase(iWeapon, OFFSET_WEAPON, OFFSET_LINUX)
	
	if(is_user_alive(iPlayer))
	{
		set_pev(iPlayer, pev_viewmodel2, g_iGrenades[0])
		set_pev(iPlayer, pev_weaponmodel2, g_iGrenades[1])
	}
	
	return HAM_IGNORED
}

public CBase__Ham_DeployFb(iWeapon)
{
	new iPlayer = get_pdata_cbase(iWeapon, OFFSET_WEAPON, OFFSET_LINUX)
	
	if(is_user_alive(iPlayer))
	{
		set_pev(iPlayer, pev_viewmodel2, g_iGrenades[2])
		set_pev(iPlayer, pev_weaponmodel2, g_iGrenades[3])
	}
	
	return HAM_IGNORED
}

public CBase__Ham_DeploySg(iWeapon)
{
	new iPlayer = get_pdata_cbase(iWeapon, OFFSET_WEAPON, OFFSET_LINUX)
	
	if(is_user_alive(iPlayer))
	{
		set_pev(iPlayer, pev_viewmodel2, g_iGrenades[4])
		set_pev(iPlayer, pev_weaponmodel2, g_iGrenades[5])
	}
	
	return HAM_IGNORED
}

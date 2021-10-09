#include <amxmodx>
#include <engine>
#include <reapi>
#include <fakemeta>

new Float:g_fLastHF[MAX_PLAYERS + 1]
new g_iFartCount[MAX_PLAYERS + 1]
new g_sprGasPuffHF

new const g_szFartSounds[][] =
{
  "hazardous_farts/hazardous_fart.wav",
  "hazardous_farts/gasp1.wav",
  "hazardous_farts/gasp2.wav"
}
new const g_szSpriteFile[] = "sprites/gas_puff_hf.spr"

new g_szHFClassName[] = "hazardous fart"

new g_cvarHazardousFartsMax, g_cvarHazardousFartsLifeTime, g_cvarHazardousFartsDelay, g_cvarHazardousFartsDamage
new g_cvarHazardousFartsSelfDamage, g_cvarHazardousFartsTeamDamage

const TASKID_CREATE_FART = 36363636
const TASKID_REMOVE_FART = 37373737

const Float:FART_RADIUS = 101.0

public plugin_init()
{
	register_plugin("Hazardous Farts","1.0-AMXX Ported","KRoTaL") // Credits: Escapers Zone & Huehue for edits
	register_clcmd("hazardous_fart","cmdHazardousFart", ADMIN_ALL, "- makes you fart hazardously (bind a key to ^"hazardous_fart^")")

	g_cvarHazardousFartsMax = register_cvar("hazardousfarts_max", "5")
	g_cvarHazardousFartsDelay = register_cvar("hazardousfarts_delay", "10")
	g_cvarHazardousFartsLifeTime = register_cvar("hazardousfarts_lifetime", "30")
	g_cvarHazardousFartsDamage = register_cvar("hazardousfarts_damage", "20")
	g_cvarHazardousFartsSelfDamage = register_cvar("hazardousfarts_self_damage", "1")
	g_cvarHazardousFartsTeamDamage = register_cvar("hazardousfarts_team_damage", "1")

	register_event("ResetHUD","eResetHud","b")
	register_logevent("leRoundEnd", 2, "0=World triggered", "1=Round_End")
}
public plugin_precache()
{
	new szTempSound[48] = "sound/"
	for(new i = 0; i < sizeof(g_szFartSounds); i++)
	{
		szTempSound[6] = 0
		copy(szTempSound[6], charsmax(szTempSound) - 6, g_szFartSounds[i])

		if(file_exists(szTempSound))
		{
			precache_sound(szTempSound[6])
		}
	}
	precache_sound("player/headshot1.wav")
	g_sprGasPuffHF = precache_model(g_szSpriteFile)
}
 
public eResetHud(id)
{
	g_fLastHF[id] = 0.0
	g_iFartCount[id] = 0
}
public leRoundEnd()
{
	set_task(3.0, "kill_farts")
}
public cmdHazardousFart(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED

	if (get_gametime() < g_fLastHF[id])
	{
		new HFAvailable = floatround(g_fLastHF[id] - get_gametime())
		client_print(id, print_chat, "You can't make a hazardous fart now, you have to wait %i second(s).", HFAvailable)
	}
	else
	{
		emit_sound(id, CHAN_ITEM, g_szFartSounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		new origin[3]
		get_user_origin(id, origin)

		new Float:vDirection[3]
		VelocityByAim(id, 30, vDirection)

		vDirection[0] = -vDirection[0]
		vDirection[1] = -vDirection[1]
		vDirection[2] = -vDirection[2]

		for (new j = 0; j < 10; j++)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BLOODSTREAM)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2] - 10)
			write_coord(floatround(vDirection[0]) + random_num(-10, 10))
			write_coord(floatround(vDirection[1]) + random_num(-10, 10))
			write_coord(floatround(vDirection[2]) + random_num(-15, 15))
			write_byte(100)
			write_byte(random_num(100, 200))
			message_end()
		}

		create_fart(id)
		g_iFartCount[id]++

		if (g_iFartCount[id] > get_pcvar_num(g_cvarHazardousFartsMax))
		{
			new health = get_user_health(id) - random_num(5, get_pcvar_num(g_cvarHazardousFartsDamage))
			if (health > 0)
			{
				user_slap(id, health)
				client_print(id, print_chat, "Do not abuse the power of farts or you will pay the consequences!")
			}
			else
			{
				emit_sound(id, CHAN_ITEM, g_szFartSounds[random_num(1, 2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(TE_LAVASPLASH)
				write_coord(origin[0])
				write_coord(origin[1])
				write_coord(origin[2] - 10)
				message_end()
				user_kill(id)

				client_print(0, print_chat, "%n farted too hard and he blew up! Laugh at him! ", id)
			}
		}
		g_fLastHF[id] = get_gametime() + get_pcvar_float(g_cvarHazardousFartsDelay)
    }
	return PLUGIN_HANDLED
}

public create_fart(id)
{
	new Float:origin[3]
	entity_get_vector(id, EV_VEC_origin, origin)

	new FartEnt
	FartEnt = create_entity("info_target")

	if (FartEnt <= 0)
	{
		return PLUGIN_HANDLED_MAIN
	}

	DispatchKeyValue(FartEnt, "damagetype", "65536")
	DispatchSpawn(FartEnt)

	entity_set_int(FartEnt, EV_INT_spawnflags, SF_TRIGGER_HURT_CLIENTONLYTOUCH)

	entity_set_string(FartEnt, EV_SZ_classname, g_szHFClassName)

	new Float:MinBox[3]
	new Float:MaxBox[3]
	MinBox[0] = -80.0
	MinBox[1] = -80.0
	MinBox[2] = -80.0
	MaxBox[0] = 80.0
	MaxBox[1] = 80.0
	MaxBox[2] = 80.0

	entity_set_size(FartEnt, MinBox, MaxBox)
	entity_set_int(FartEnt, EV_INT_solid, 1)
	entity_set_float(FartEnt, EV_FL_dmg, 0.0)
	entity_set_edict(FartEnt, EV_ENT_owner, id)
	entity_set_origin(FartEnt, origin)

	new param[1]
	param[0] = FartEnt

	set_task(1.0, "fart_fume", TASKID_CREATE_FART + FartEnt, param, 1, "b")
	set_task(get_pcvar_float(g_cvarHazardousFartsLifeTime), "remove_fart", TASKID_REMOVE_FART + FartEnt, param, 1)

	return PLUGIN_CONTINUE
}
public remove_fart(param[1])
{
	new FartEnt = param[0]

	if(is_valid_ent(FartEnt))
		remove_entity(FartEnt)

	remove_task(TASKID_CREATE_FART + FartEnt)
	return PLUGIN_CONTINUE
}
public kill_farts()
{
	new iEntity = find_ent_by_class(-1, g_szHFClassName)
	while (iEntity > 0)
	{
		remove_entity(iEntity)
		remove_task(TASKID_CREATE_FART + iEntity)
		remove_task(TASKID_REMOVE_FART + iEntity)
		iEntity = find_ent_by_class(-1, g_szHFClassName)
	}
	return PLUGIN_CONTINUE
}
public fart_fume(param[1])
{
	new FartEnt = param[0]
	new Float:forigin[3], origin[3]
	new iOwner = entity_get_edict(FartEnt, EV_ENT_owner)

	entity_get_vector(FartEnt, EV_VEC_origin, forigin)
	FVecIVec(forigin, origin)

	new players[32], inum
	get_players(players,inum)

	for(new i = 0 ;i < inum; ++i)
	{
		message_begin(MSG_ONE, SVC_TEMPENTITY, {0,0,0}, players[i])
		write_byte(TE_FIREFIELD)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2] + 20)
		write_short(50)
		write_short(g_sprGasPuffHF)
		write_byte(10)
		write_byte(TEFIRE_FLAG_ALPHA)
		write_byte(20)
		message_end()

		new iVictim = -1

		while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, forigin, FART_RADIUS)) != 0)
		{
			if (!is_user_alive(iVictim)
				|| get_pcvar_num(g_cvarHazardousFartsSelfDamage) == 0 && iVictim == iOwner
				|| get_pcvar_num(g_cvarHazardousFartsTeamDamage) == 0 && get_user_team(iVictim) == get_user_team(iOwner)
				|| entity_get_float(iVictim, EV_FL_takedamage) == DAMAGE_NO)
				continue


			emit_sound(iVictim, CHAN_ITEM, g_szFartSounds[random_num(1, 2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			rg_dmg_radius(forigin, FartEnt, 0, get_pcvar_float(g_cvarHazardousFartsDamage), FART_RADIUS, DONT_IGNORE_MONSTERS, DMG_NERVEGAS)
		}
	}
	
	return PLUGIN_CONTINUE
}
 
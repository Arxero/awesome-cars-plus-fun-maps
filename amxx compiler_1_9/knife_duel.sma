#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Knife Duel"
#define VERSION "1.0"
#define AUTHOR "Alka"

#define CBASE_CURRWPN_ENT 373
#define OFFSET_ENT_TO_INDEX 43

new const g_szKnifeSound[] = "weapons/knife_hitwall1.wav";
new const g_szSpawnClassname[] = "info_player_deathmatch";

new Float:g_fHit[33];
new iHitCount[33];
new g_iChallenged, g_iChallenger;

new Float:g_vKnifeOrigin[2][3];
new bool:g_bInChallenge;
new bool:g_bProtect;
new g_iTimer;

enum _:max_cvars {
	
	CVAR_COUNT = 0,
	CVAR_TIMER,
	CVAR_MAXDISTANCE,
	CVAR_PROTECTION,
	CVAR_ANNOUNCE,
	CVAR_RESET
};
new g_Pcvar[max_cvars];

new g_iFwdSpawn;
new g_iMaxPlayers;

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_forward(FM_EmitSound, "fwd_EmitSound", 1);
	register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink_post", 1);
	RegisterHam(Ham_Killed, "player", "fwd_Killed", 1);
	unregister_forward(FM_Spawn, g_iFwdSpawn, 1);
	
	register_logevent("logevent_RoundEnd", 2, "1=Round_End", "1=Round_Draw");
	
	g_Pcvar[CVAR_COUNT] = register_cvar("kd_knifecount", "3");
	g_Pcvar[CVAR_TIMER] = register_cvar("kd_preparetime", "3");
	g_iTimer = get_pcvar_num(g_Pcvar[CVAR_TIMER]);
	g_Pcvar[CVAR_PROTECTION] = register_cvar("kd_protection", "1");
	g_Pcvar[CVAR_MAXDISTANCE] = register_cvar("kd_maxdistance", "600");
	g_Pcvar[CVAR_ANNOUNCE] = register_cvar("kd_announce", "1");
	g_Pcvar[CVAR_RESET] = register_cvar("kd_resethp", "0");
	
	g_iMaxPlayers = get_maxplayers();
}

public plugin_precache()
	g_iFwdSpawn = register_forward(FM_Spawn, "fwd_Spawn", 1);

public client_disconnect(id)
{
	if((id == g_iChallenged) || (id == g_iChallenger))
	{
		g_bInChallenge = false;
		g_bProtect = false;
	}
}

public fwd_Spawn(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED;
	
	static szClassname[32];
	pev(ent, pev_classname, szClassname, sizeof szClassname - 1);
	
	if(equal(szClassname, g_szSpawnClassname))
	{
		if(vec_null(g_vKnifeOrigin[0]))
		{
			pev(ent, pev_origin, g_vKnifeOrigin[0]);
		}
		else if(!vec_null(g_vKnifeOrigin[0]) && vec_null(g_vKnifeOrigin[1]))
		{
			static Float:vTmp[3];
			pev(ent, pev_origin, vTmp);
			
			if((300.0 <= vector_distance(g_vKnifeOrigin[0], vTmp) < 600.0))
				g_vKnifeOrigin[1] = vTmp;
		}
	}
	return FMRES_IGNORED;
}

public fwd_EmitSound(id, channel, const sound[])
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(!equal(sound, g_szKnifeSound))
		return FMRES_IGNORED;
	
	static Float:fGmTime;
	fGmTime = get_gametime();
	
	if((fGmTime - g_fHit[id]) >= 1.0)
	{
		iHitCount[id] = 0;
		g_fHit[id] = fGmTime;
	}
	++iHitCount[id];
	g_fHit[id] = fGmTime;
	
	if((iHitCount[id] >= get_pcvar_num(g_Pcvar[CVAR_COUNT])) && check_players() && !g_bInChallenge)
	{
		new iOpponent = get_opponent(3 - get_user_team(id));
		if(!iOpponent)
			return FMRES_IGNORED;
		
		fnChallenge(id, iOpponent);
		
		iHitCount[id] = 0;
	}
	return FMRES_IGNORED;
}

public fwd_PlayerPreThink_post(id)
{
	if(!is_user_alive(id) || !g_bInChallenge)
		return FMRES_IGNORED;
	
	static iWpn;
	iWpn = get_pdata_cbase(id, CBASE_CURRWPN_ENT);
	
	if(pev_valid(iWpn))
	{
		if(get_pdata_int(iWpn, OFFSET_ENT_TO_INDEX) != CSW_KNIFE)
			engclient_cmd(id, "weapon_knife");
	}
	
	static iOpponent;
	if(id == g_iChallenged)
		iOpponent = g_iChallenger;
	else
		iOpponent = g_iChallenged;
	
	if(!is_user_connected(iOpponent))
		return FMRES_IGNORED;
	
	if((fm_get_entity_distance(id, iOpponent) >= get_pcvar_float(g_Pcvar[CVAR_MAXDISTANCE])) && g_bProtect)
	{
		static Float:vVel[3];
		fm_get_speed_vector2(id, iOpponent, 100.0, vVel);
		
		set_pev(id, pev_velocity, vVel);
	}
	return FMRES_IGNORED;
}

public fwd_Killed(id, idattacker, shouldgib)
{
	if(!get_pcvar_num(g_Pcvar[CVAR_ANNOUNCE]))
		return HAM_IGNORED;
	
	if(check_players())
	{
		for(new i = 0 ; i <= g_iMaxPlayers ; i++)
		{
			if(!is_user_alive(i))
				continue;
			
			// client_print(i, print_chat, "* You can challenge other player to a knife duel by slashing the wall %d times.", get_pcvar_num(g_Pcvar[CVAR_COUNT]));
		}
	}
	return HAM_IGNORED;
}

public fnChallenge(id, opponent)
{
	new szName[32], szOppName[32];
	get_user_name(id, szName, sizeof szName - 1);
	get_user_name(opponent, szOppName, sizeof szOppName - 1);
	
	new szTitle[64];
	formatex(szTitle, sizeof szTitle - 1, "\r%s \yis challenging you to a knife duel", szName);
	
	new iMenu = menu_create(szTitle, "menu_MainHandler", 0);
	menu_additem(iMenu, "Accept", "1", 0, -1);
	menu_additem(iMenu, "No, thank you", "2", 0, -1);
	
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(opponent, iMenu, 0);
	
	client_print(0, print_chat, "* %s has challenged %s to a knife duel.", szName, szOppName);
	
	g_iChallenger = id;
	g_iChallenged = opponent;
	g_bInChallenge = true;
}

public menu_MainHandler(id, menu, item)
{
	if(!is_user_connected(id))
		return 1;
	
	new szData[6], iAccess, iCallBack;
	menu_item_getinfo(menu, item, iAccess, szData, sizeof szData - 1, _, _, iCallBack);
	
	new iKey = str_to_num(szData);
	
	new szName[32];
	get_user_name(id, szName, sizeof szName - 1);
	
	switch(iKey)
	{
		case 1:
		{
			client_print(0, print_chat, "* %s has accepted the knife duel!", szName);
			fnStartDuel();
		}
		case 2:
		{
			client_print(0, print_chat, "* %s has declined the knife duel!", szName);
			g_bInChallenge = false;
		}
	}
	return 1;
}

public fnStartDuel()
{
	if(!is_user_connected(g_iChallenged) || !is_user_connected(g_iChallenger))
		return;
	
	engfunc(EngFunc_SetOrigin, g_iChallenged, g_vKnifeOrigin[0]);
	engfunc(EngFunc_SetOrigin, g_iChallenger, g_vKnifeOrigin[1]);
	
	fm_entity_set_aim(g_iChallenged, g_iChallenger, 0);
	fm_entity_set_aim(g_iChallenger, g_iChallenged, 0);
	
	fm_set_user_godmode(g_iChallenged, 1);
	fm_set_user_godmode(g_iChallenger, 1);
	
	if(get_pcvar_num(g_Pcvar[CVAR_RESET]))
	{
		set_pev(g_iChallenged, pev_health, 100.0);
		set_pev(g_iChallenger, pev_health, 100.0);
	}
	set_task(1.0, "taskDuelThink", 'x', "", 0, "b", 0);
	
	if(get_pcvar_num(g_Pcvar[CVAR_PROTECTION]))
		g_bProtect = true;
}

public taskDuelThink()
{
	if(g_iTimer > 0)
	{
		set_hudmessage(255, 100, 0, -1.0, 0.3, 0, 6.0, 1.0, 0.1, 0.9, 1);
		show_hudmessage(0, "Countdown: %d", g_iTimer--);
	}
	else
	{
		set_hudmessage(255, 100, 0, -1.0, 0.3, 0, 6.0, 1.0, 0.1, 0.5, 1);
		show_hudmessage(0, "Knife Duel has started!");
		
		g_iTimer = get_pcvar_num(g_Pcvar[CVAR_TIMER]);
		remove_task('x');
		
		for(new i = 0 ; i <= g_iMaxPlayers ; i++)
		{
			if(!is_user_alive(i))
				continue;
			
			fm_set_user_godmode(i, 0);
		}
	}
}

public logevent_RoundEnd()
{
	g_bInChallenge = false;
	g_bProtect = false;
}

stock fm_entity_set_aim(id, ent, bone = 0)
{
	if(!is_user_connected(id) || !pev_valid(ent))
		return 0;
	
	new Float:vOrigin[3];
	pev(ent, pev_origin, vOrigin);
	
	new Float:vEntOrigin[3], Float:vAngles[3];
	
	if(bone)
		engfunc(EngFunc_GetBonePosition, id, bone, vEntOrigin, vAngles);
	else
		pev(id, pev_origin, vEntOrigin);
	
	vOrigin[0] -= vEntOrigin[0];
	vOrigin[1] -= vEntOrigin[1];
	vOrigin[2] -= vEntOrigin[2];
	
	new Float:v_length;
	v_length = vector_length(vOrigin);
	
	new Float:vAimVector[3];
	vAimVector[0] = vOrigin[0] / v_length;
	vAimVector[1] = vOrigin[1] / v_length;
	vAimVector[2] = vOrigin[2] / v_length;
	
	new Float:vNewAngles[3];
	vector_to_angle(vAimVector, vNewAngles);
	
	vNewAngles[0] *= -1;
	
	if(vNewAngles[1] > 180.0) vNewAngles[1] -= 360;
	if(vNewAngles[1] < -180.0) vNewAngles[1] += 360;
	if(vNewAngles[1] == 180.0 || vNewAngles[1] == -180.0) vNewAngles[1] = -179.9;
	
	set_pev(id, pev_angles, vNewAngles);
	set_pev(id, pev_fixangle, 1);
	
	return 1;
}

stock vec_null(Float:vec[3])
{
	if(!vec[0] && !vec[1] && !vec[2])
		return 1;
	
	return 0;
}

stock bool:check_players()
{
	new iNum[2];
	for(new i = 1 ; i <= g_iMaxPlayers ; i++)
	{
		if(!is_user_alive(i))
			continue;
		
		if(get_user_team(i) == 1)
			++iNum[0];
		else if(get_user_team(i) == 2)
			++iNum[1];
	}
	if((iNum[0] == 1) && (iNum[1] == 1))
		return true;
	
	return false;
}

stock get_opponent(team)
{
	for(new i = 0 ; i <= g_iMaxPlayers ; i++)
	{
		if(!is_user_alive(i))
			continue;
		
		if(get_user_team(i) == team)
			return i;
	}
	return 0;
}

stock fm_set_user_godmode(index, godmode = 0)
{
	set_pev(index, pev_takedamage, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM);
	return 1;
}

stock fm_get_speed_vector2(ent1, ent2, Float:speed, Float:new_velocity[3])
{
	if(!pev_valid(ent1) || !pev_valid(ent2))
		return 0;
	
	static Float:vOrigin1[3];
	pev(ent1, pev_origin, vOrigin1);
	static Float:vOrigin2[3];
	pev(ent2, pev_origin, vOrigin2);
	
	new_velocity[0] = vOrigin2[0] - vOrigin1[0];
	new_velocity[1] = vOrigin2[1] - vOrigin1[1];
	new_velocity[2] = vOrigin2[2] - vOrigin1[2];
	new Float:fNum = floatsqroot(speed * speed / (new_velocity[0] * new_velocity[0] + new_velocity[1] * new_velocity[1] + new_velocity[2] * new_velocity[2]));
	new_velocity[0] *= fNum;
	new_velocity[1] *= fNum;
	new_velocity[2] *= fNum;
	
	return 1;
}

stock Float:fm_get_entity_distance(ent1, ent2)
{
	if(!pev_valid(ent1) || !pev_valid(ent2))
		return 0.0;
	
	static Float:vOrigin1[3];
	pev(ent1, pev_origin, vOrigin1);
	static Float:vOrigin2[3];
	pev(ent2, pev_origin, vOrigin2);
	
	return vector_distance(vOrigin1, vOrigin2);
}

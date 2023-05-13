#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <engine>
#include <reapi>
#include <api_rounds>
#include <fdcc>

#if AMXX_VERSION_NUM < 183
    #include <dhudmessage>
#endif 

#define TASK_REVIVIR    3100
#define TASK_DHUDINFO     3200
//#define TASK_INVISIBILIDAD   3300
#define TASK_INMUNE     3400
#define INMUNE_TIME 4.0

new const INFOPLUGIN[3][] = { "Bate Loco", "v2.0", "FedeeRG4L" }

new const g_MdlBate[][] =
{ 
  "models/realg4life/p_bate_loco.mdl",
  "models/realg4life/v_bate_loco.mdl"
}

new const g_MdlHats[][] =
{ 
  "models/realg4life/hats/gorra_tt.mdl",
  "models/realg4life/hats/gorra_ct.mdl"
}

new const g_MdlPlayers[][] =
{
  "models/player/bateador_tt/bateador_tt.mdl",
  "models/player/bateador_ct/bateador_ct.mdl"
}

new const g_ComandosBloquear[][] =
{
  "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "radio1", "radio2", "radio3", "radio4",
  "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "vote", "roger", "enemyspot", "needbackup", 
  "sectorclear", "inposition", "reportingin", "getout", "negative", "enemydown", "usp", "glock", "deagle", "p228", 
  "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47","galil", "famas", "sg552", "m4a1", 
  "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren", "sgren", "defuser", "nvgs", 
  "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "12gauge", "autoshotgun", "smg", "mp", 
  "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550", "buyammo1", "buyammo2"
};

new const g_DeleteEntity[][] = 
{
  "armoury_entity",
  "func_bomb_target",
  "func_vip_safetyzone", 
  "func_escapezone",
  "func_hostage_rescue",
  "func_tank", 
  "func_tankmortar",
  "info_bomb_target", 
  "info_vip_start",
  "info_hostage_rescue",
  "game_player_equip",
  "hostage_entity", 
  "monster_scientist",  
  "player_weaponstrip", 
  "trigger_camera"
};

new const PREFIXBL[] = "^4[^3Alta-Fruta^4]^1"
new g_Bateado[33]
new g_EntHat[33]

enum _:DATOS_ALL
{
  LIVES
}

new g_Datos[MAX_PLAYERS + 1][DATOS_ALL];

new g_RondaFinish
new g_ConteoRevivir[MAX_PLAYERS + 1]
new g_ConteoInmunidad[MAX_PLAYERS + 1]
new g_MaxPlayers
new gp_CvarNoKillNoName
new bool:g_PlayerInmune[MAX_PLAYERS + 1]

new g_RoundWinT
new g_RoundWinCT

public plugin_init()
{
  register_plugin(INFOPLUGIN[0], INFOPLUGIN[1], INFOPLUGIN[2])

  RegisterHam(Ham_Killed, "player", "Forward_PlayerKilled" );
  RegisterHam(Ham_TraceAttack, "player", "Forward_PlayerTraceAttack")
  RegisterHam(Ham_Spawn, "player", "Forward_PlayerSpawn", 1)

  register_event("CurWeapon", "Current_Weapon", "be", "1=1", "2=29")
  register_event("Money", "Evento_Money", "b");
  register_event ("SendAudio" , "Evento_RoundWinT" , "a" , "2&%!MRAD_terwin");
  register_event ("SendAudio" , "Evento_RoundWinCT" , "a" , "2&%!MRAD_ctwin");

  register_logevent("EventRoundStart", 2, "0=World triggered", "1=Round_Start")
  register_logevent("EventRoundEnd", 2, "1=Round_End")

  register_touch("weaponbox", "player", "Block_Pickear_Armas");

  register_forward(FM_ClientKill, "Forward_ClientKill")

  Round_HookCheckWinConditions("OnCheckWinConditions");

  for(new i = 0; i < sizeof(g_ComandosBloquear); i++)
    register_clcmd(g_ComandosBloquear[i], "Cmd_Block");

  gp_CvarNoKillNoName = register_cvar("bl_nokill_noname", "1")

  g_MaxPlayers = get_maxplayers()

  new Entity = -1; 

  while ( ( Entity = find_ent_by_class( Entity, "armoury_entity" ) ) ) 
  { 
    remove_entity( Entity ); 
  }
}

public plugin_precache()
{
  CreateHiddenBuyZone();

  static i

  for(new i = 0; i < sizeof(g_MdlBate); i++)
    precache_model(g_MdlBate[i])

  for(i = 0; i < sizeof(g_MdlPlayers); i++)
    precache_model(g_MdlPlayers[i])

  for(i = 0; i < sizeof(g_MdlHats); i++)
    precache_model(g_MdlHats[i])
}

public client_putinserver(id)
{
  g_Datos[id][LIVES] = 0
  set_task(5.0, "DhudInfo", id+TASK_DHUDINFO,_,_, "b")
  CheckWinConditions();
}

public client_disconnected(id)
{
  if(pev_valid(g_EntHat[id]))
  {
    engfunc(EngFunc_RemoveEntity, g_EntHat[id]);
  }

  g_PlayerInmune[id] = false
  
  remove_task(id + TASK_REVIVIR)
  remove_task(id + TASK_INMUNE)
  remove_task(id + TASK_DHUDINFO)
  remove_task(id)
  CheckWinConditions();
}

public OnCheckWinConditions() {
  CheckWinConditions();
  return PLUGIN_HANDLED;
}

CheckWinConditions(pIgnorePlayer = 0) {
  new iPlayerCount = 0;
  new iAliveT = 0;
  new iAliveCt = 0;

  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (pPlayer == pIgnorePlayer) {
      continue;
    }

    if (!is_user_connected(pPlayer)) {
      continue;
    }

    new iTeam = get_member(pPlayer, m_iTeam);
    if (iTeam < 1 || iTeam > 2) {
      continue;
    }

    iPlayerCount++;

    if (!is_user_alive(pPlayer) && !g_Datos[pPlayer][LIVES]) {
      continue;
    }

    switch (iTeam) {
      case 1: iAliveT++;
      case 2: iAliveCt++;
    }
  }

  if (!iPlayerCount) {
    return;
  }

  if (!iAliveCt && !iAliveT) {
    Round_DispatchWin(3, 5.0);
  } else if (!iAliveCt) {
    Round_DispatchWin(1, 5.0);
  } else if (!iAliveT) {
    Round_DispatchWin(2, 5.0);
  }
}

public Forward_PlayerKilled(Victima, Atacante, shouldgib)
{
  if(!is_user_connected(Atacante) && g_Bateado[Victima])
  {
    static Nombre_Atacante[32], Nombre_Victima[32]

    get_user_name(g_Bateado[Victima], Nombre_Atacante, charsmax(Nombre_Atacante))
    get_user_name(Victima, Nombre_Victima, charsmax(Nombre_Victima))

    SetHamParamEntity(2, g_Bateado[Victima]);
    FDCC(g_Bateado[Victima], TEAM_COLOR, "%s You killed ^4%s ^1in one hit.", PREFIXBL, Nombre_Victima)
    FDCC(Victima, TEAM_COLOR, "%s The batter ^4%s ^1has killed you in one hit.", PREFIXBL, Nombre_Atacante)
  }

  set_task(1.0, "RevivirPlayer", Victima+TASK_REVIVIR, _, _, "b")

  g_ConteoRevivir[Victima] = 5
  g_Bateado[Victima] = false;

  CheckWinConditions();
}

public EventRoundStart()
{
  g_RondaFinish = 0

  for(new id = 1; id <= g_MaxPlayers; id++)
  {
   if(!is_user_alive(id)) 
     continue;
      
    g_Datos[id][LIVES] = 2
    //FDCC(id, TEAM_COLOR, "%s Tenes 2 vidas.", PREFIXBL)
  }
}

public EventRoundEnd()
{
  for(new id = 1; id <= g_MaxPlayers; id++)
  {
   if(!is_user_alive(id)) 
     continue;
      
    g_Datos[id][LIVES] = 2
    //FDCC(id, TEAM_COLOR, "%s Tenes 2 vidas.", PREFIXBL)
  }

  g_RondaFinish = 1
}

public Evento_RoundWinT()
{
  g_RoundWinT++
}

public Evento_RoundWinCT()
{
  g_RoundWinCT++
}

public RevivirPlayer(id)
{      
  id -= TASK_REVIVIR
  
  if(g_RondaFinish)
    return PLUGIN_HANDLED
  
  if(!g_Datos[id][LIVES])
  {
    FDCC(id, TEAM_COLOR, "%s You can no longer be revived, you have no lives.", PREFIXBL)
    remove_task(id+TASK_REVIVIR)
    return PLUGIN_HANDLED
  }
  
  g_ConteoRevivir[id]--
  
  set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 3.0, 1.0)
  show_hudmessage(id, "You will be revived in %d seconds", g_ConteoRevivir[id])

  if(g_ConteoRevivir[id]) {
    return PLUGIN_HANDLED
  }

  new team = get_user_team(id);

  if (team < 1 || team > 2) {
    remove_task(id+TASK_REVIVIR);
    g_Datos[id][LIVES] = 0;
    return PLUGIN_HANDLED;
  }
  
  static szRed, szGreen, szBlue

  switch(team)
  {
    case 1: szRed = 250,   szGreen = 20,   szBlue = 10
    case 2: szRed = 10,   szGreen = 20,   szBlue = 250
  }

  g_Datos[id][LIVES] -= 1
    
  FDCC(id, TEAM_COLOR, "%s You were revived, you have one less life.", PREFIXBL)
  g_PlayerInmune[id] = true
  ExecuteHamB(Ham_CS_RoundRespawn, id);
  ScreenFade(id, INMUNE_TIME, szRed, szGreen, szBlue, 120)
  set_task(1.0, "PlayerInmune", id+TASK_INMUNE, _, _, "b")
  set_user_rendering(id, kRenderFxGlowShell, szRed, szGreen, szBlue, kRenderTransAlpha, 20)
  g_ConteoInmunidad[id] = floatround(INMUNE_TIME)
  g_ConteoRevivir[id] = 0
  set_user_godmode(id, 1)
  
  remove_task(id+TASK_REVIVIR)

  return PLUGIN_HANDLED
}

public PlayerInmune(id)
{
  id -= TASK_INMUNE
  
  g_ConteoInmunidad[id]--
  
  set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 3.0, 1.0)
  show_hudmessage(id, "Your immunity ends in %d seconds", g_ConteoInmunidad[id])
  
  if(!g_ConteoInmunidad[id])
  {
    set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 3.0, 1.0)
    show_hudmessage(id, "YOUR IMMUNITY IS OVER")
    set_user_godmode(id, 0)
    set_user_rendering(id)
    give_item(id , "weapon_knife")
    g_PlayerInmune[id] = false
    remove_task(id+TASK_INMUNE)
    
    return PLUGIN_HANDLED
  }
  return PLUGIN_HANDLED
}

public Evento_Money(id)
{
  set_pdata_int(id, 115, 0);
    
  message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Money"), _, id);
  write_long(0);
  write_byte(1); 
  message_end();
}

public DhudInfo(id) 
{
  id -= TASK_DHUDINFO

  if (!is_user_connected(id)) {
    return PLUGIN_HANDLED;
  }

  new alive = is_user_alive(id);
  new spectMode = pev(id, pev_iuser1);
  new Spect = !alive && spectMode == OBS_IN_EYE ? pev(id, pev_iuser2) : 0;
  Spect = is_user_connected(Spect) ? Spect : 0;

  static title[128];
  copy(title, charsmax(title), "BATE LOCO");

  if (Spect) {
    format(title, charsmax(title), "%s^nSpectating PLAYER: %n", title, Spect);
  }

  set_dhudmessage(255, 255, 250, -1.0, Spect ? 0.14 : 0.04, 1, 8.0, 0.8, 5.0);
  show_dhudmessage (id, title);

  if (alive || Spect) {
    new lives = g_Datos[alive ? id : Spect][LIVES];

    set_dhudmessage(250, 200, 0, -1.0, 0.10, 1, 8.0, 0.8, 5.0);
    // show_dhudmessage (id, "%L [ %d ] | [ %d ] %L^n[ LIVES: %d/2 ]", LANG_PLAYER, "CTS", g_RoundWinCT, g_RoundWinT, LANG_PLAYER, "TERRORISTS", lives);
    show_dhudmessage (id, "[ LIVES: %d/2 ]", lives);
  }

  return PLUGIN_HANDLED
}

public Forward_UserInfoChanged(id,buffer) 
{  
  if(!is_user_connected(id))
    return FMRES_IGNORED;
  
  new name[32];
  new newname[32];
  
  get_user_name(id, name, charsmax(name));
  engfunc(EngFunc_InfoKeyValue, buffer, "name", newname, charsmax(newname));
  
  if(get_pcvar_num(gp_CvarNoKillNoName))
  {
    if(!equal(name,newname))
    {
      engfunc(EngFunc_SetClientKeyValue, id, buffer, "name", name);
      client_cmd(id, "name ^"%s^"", name);
      
      FDCC(id, TEAM_COLOR, "%s Tag change is disabled.", PREFIXBL);
      return FMRES_IGNORED;
    }
  }
  return FMRES_IGNORED;
}

public Forward_ClientKill(id)
{
  if(!is_user_alive(id))
    return FMRES_IGNORED

  if(get_pcvar_num(gp_CvarNoKillNoName))
  {
    FDCC(id, TEAM_COLOR, "%s You can't kill yourself right now", PREFIXBL)
    return FMRES_SUPERCEDE
  }
  return FMRES_IGNORED;
}

public Forward_PlayerTraceAttack(Victima, Atacante, float:damage, Float:direction[3], trace, bits)
{
  if(!is_user_alive(Atacante) || g_PlayerInmune[Victima])
  {
    return HAM_IGNORED;
  }

  static Team_A, Team_V

  Team_A = get_user_team(Atacante)
  Team_V = get_user_team(Victima)

  if(Team_A == 1 && Team_V == 1 || Team_A == 2 && Team_V == 2)
  {
    return HAM_IGNORED;
  }

  new Float:push[3], Float:velocity[3];
  entity_get_vector(Victima, EV_VEC_velocity, velocity)
  create_velocity_vector(Victima, Atacante, push);
  push[0] += velocity[0];
  push[1] += velocity[1];
  entity_set_vector(Victima, EV_VEC_velocity, push);
  g_Bateado[Victima] = Atacante;

  return HAM_SUPERCEDE;
}

public Forward_PlayerSpawn(id)
{
  if(!is_user_alive(id))
    return HAM_IGNORED

  strip_user_weapons(id)

  g_ConteoRevivir[id] = 0
  
  if(!g_PlayerInmune[id])
  {
    static szRed, szGreen, szBlue

    switch(get_user_team(id))
    {
      case 1: szRed = 250,   szGreen = 20,   szBlue = 10
      case 2: szRed = 10,   szGreen = 20,   szBlue = 250
    }

    //strip_user_weapons(id)
    set_task(1.0, "PlayerInmune", id+TASK_INMUNE, _, _, "b")
    ScreenFade(id, 6.0, szRed, szGreen, szBlue, 120)
    set_user_rendering(id, kRenderFxGlowShell, szRed, szGreen, szBlue, kRenderTransAlpha, 20)
    g_ConteoInmunidad[id] = 6
    set_user_godmode(id, 1)
    remove_task(id+TASK_REVIVIR)
  }
  else
  {
    //strip_user_weapons(id)
    give_item(id , "weapon_knife")
    remove_task(id+TASK_REVIVIR)
  }

  switch(get_user_team(id))
  {
    case 1:
    {
      cs_set_user_model(id, "bateador_tt")

      if(pev_valid(g_EntHat[id]))
      {
        engfunc(EngFunc_RemoveEntity, g_EntHat[id]);
      }

      g_EntHat[id] = engfunc(EngFunc_CreateNamedEntity,  engfunc(EngFunc_AllocString, "info_target"));
              
      set_pev(g_EntHat[id], pev_movetype, MOVETYPE_FOLLOW);
      set_pev(g_EntHat[id], pev_aiment, id);
      engfunc(EngFunc_SetModel, g_EntHat[id], g_MdlHats[0]);
    }
    case 2:
    {
      cs_set_user_model(id, "bateador_ct")

      if(pev_valid(g_EntHat[id]))
      {
        engfunc(EngFunc_RemoveEntity, g_EntHat[id]);
      }

      g_EntHat[id] = engfunc(EngFunc_CreateNamedEntity,  engfunc(EngFunc_AllocString, "info_target"));
              
      set_pev(g_EntHat[id], pev_movetype, MOVETYPE_FOLLOW);
      set_pev(g_EntHat[id], pev_aiment, id);
      engfunc(EngFunc_SetModel, g_EntHat[id], g_MdlHats[1]);
    }
  }

  switch(random_num(0, 15))
  {
    case 3, 9, 12:
    {
      FDCC(id, TEAM_COLOR, "%s MiniMOD ^4BATE LOCO^1 created by: ^4%s ^1- version: ^4%s^1.", PREFIXBL, INFOPLUGIN[2], INFOPLUGIN[1])
    }
  }
  return HAM_IGNORED 
}

public Current_Weapon(id)
{
  if(!is_user_alive(id))
    return PLUGIN_CONTINUE
    
  if(get_user_weapon(id) == CSW_KNIFE )
  {
    set_pev(id, pev_viewmodel2, g_MdlBate[1])
    set_pev(id, pev_weaponmodel2, g_MdlBate[0])
  }

  return PLUGIN_CONTINUE
}

public Block_Pickear_Armas(wpn, id)
{
  return PLUGIN_HANDLED;
}

public pfn_spawn(ent)
{
  if(!is_valid_ent(ent))
    return PLUGIN_CONTINUE;

  static classname[32];
  entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));

  for(new i = 0; i < sizeof(g_DeleteEntity); i++)
  {
    if(equal(classname, g_DeleteEntity[i]))
    {
      remove_entity(ent);
      return PLUGIN_HANDLED;
    }
  }

  return PLUGIN_CONTINUE;
}

public Cmd_Block(id)
{
  return PLUGIN_HANDLED;
}

stock create_velocity_vector(victim, attacker, Float:velocity[3])
{
  if(!is_user_alive(victim) || !is_user_alive(attacker))
    return 0;

  new Float:vicorigin[3];
  new Float:attorigin[3];
  entity_get_vector(victim   , EV_VEC_origin , vicorigin);
  entity_get_vector(attacker , EV_VEC_origin , attorigin);

  new Float:origin2[3];
  origin2[0] = vicorigin[0] - attorigin[0];
  origin2[1] = vicorigin[1] - attorigin[1];

  new Float:largestnum = 0.0;

  if(floatabs(origin2[0]) > largestnum)
    largestnum = floatabs(origin2[0]);
  if(floatabs(origin2[1]) > largestnum)
    largestnum = floatabs(origin2[1]);

  origin2[0] /= largestnum;
  origin2[1] /= largestnum;

  velocity[0] = ( origin2[0] * (100.0 * 3000) ) / entity_range(victim, attacker);
  velocity[1] = ( origin2[1] * (100.0 * 3000) ) / entity_range(victim, attacker);
  if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
    velocity[2] = random_float(400.0, 575.0);

  return 1;
}

stock ScreenFade(plr, Float:fDuration, red, green, blue, alpha)
{
  new i = plr ? plr : get_maxplayers();
  if( !i )
  {
    return 0;
  }
  
  message_begin(plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade"), {0, 0, 0}, plr);
  write_short(floatround(4096.0 * fDuration, floatround_round));
  write_short(floatround(4096.0 * fDuration, floatround_round));
  write_short(4096);
  write_byte(red);
  write_byte(green);
  write_byte(blue);
  write_byte(alpha);
  message_end();
  
  return 1;
}

CreateHiddenBuyZone() {
    new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"));
    dllfunc(DLLFunc_Spawn, pEntity);
    engfunc(EngFunc_SetSize, pEntity, {-8192.0, -8192.0, -8192.0}, {-8191.0, -8191.0, -8191.0});
}

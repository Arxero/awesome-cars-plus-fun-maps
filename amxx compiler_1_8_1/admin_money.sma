/*
 * AMX Mod plugin
 *
 * Admin Money, v1.0 CS
 *
 * (c) Copyright 2010 - AMX Mod Team
 * This file is provided as is (no warranties).
 *
 */

/*
 * Description:
 * This plugin allows an admin with the ADMIN_LEVEL_A flag to give or remove money
 * to/from a specified player, a team or to all players.
 * To remove money, simply use the argument "-" before the money ammout (f.e.: amx_money jack -200).
 *
 * Command:
 * amx_money <name|#userid|authid|@TEAM|*(all)> <money> - gives/removes money
 *
 * Requirements:
 * AMX Mod 2010.1 or higher to compile or correctly run this plugin on your server.
 * Counter-Strike or Condition Zero.
 *
 * Setup:
 * Extract the content of this .zip archive on your computer, then upload the "addons" folder
 * in your moddir (folder of your game). The non-existent files will be automatically added.
 * Add the plugin name in your plugins.ini file (or in another plugins file).
 *
 * Configuration:
 * You can enable if you want, the AMX logs registered in the AMX log folder.
 * To do that, just uncomment the #define USE_LOGS below, save the file, then recompile
 * it and replace the new .amx file in your plugins folder.
 * For information, this plugin can work with the colored admin activity feature, to enable this
 * thing, make sure your #define COLORED_ACTIVITY has been uncommented (amx/examples/include/amxconst.inc)
 * then recompile the plugin and replace the new .amx file on your server.
 * You can also modify the admin flag required for the command (see below) or use the
 * "amx_changecmdaccess" command (put it with the parameters in your amx.cfg for example).
 *
 * Credit:
 * f117bomb for made the original plugin.
 *
 * Changelog:
 * 1.0 CS  o improved version for CS or CZ only (by the AMX Mod Team)
 *           - added supreme admin support
 *           - added colored admin activity support
 *           - added #define USE_LOGS to enable/disable AMX logging
 *           - added "*" argument to the command (to make the action to all players)
 *           - added plugin auto lock (if the game mod running is not CS or CZ)
 *           - improved and cleaning up for all codes
 *           - added multilingual support
 * 0.9.9   o original version
 *
 */

/******************************************************************************/
// If you change one of the following settings, do not forget to recompile
// the plugin and to install the new .amx file on your server.
// You can find the list of admin flags in the amx/examples/include/amxconst.inc file.

#define FLAG_AMX_MONEY ADMIN_LEVEL_A

// Uncomment the following line to enable the AMX logs for this plugin.
//#define USE_LOGS

/******************************************************************************/

#include <translator>
#include <amxmodx>
#include <amxmisc>
#include <cstrike>

public plugin_init() {
  load_translations("admin_money")
  if((is_running("cstrike") || is_running("czero")) == false) {
    register_plugin(_T("Admin Money - Auto-Locked"), "1.0 CS", "AMX Mod Team")
    log_amx(_T("Admin Money: Plugin paused and locked (Counter-Strike or Condition Zero not running)."))
    pause("ae")
    return
  }
  register_plugin(_T("Admin Money"), "1.0 CS", "AMX Mod Team")
  register_concmd("amx_money", "cmdMoney", FLAG_AMX_MONEY, _T("<name|#userid|authid|@TEAM|*(all)> <money> - gives/removes money"))
}

public cmdMoney(id, iLevel, iCommandId) {
  if(!cmd_access(id, iLevel, iCommandId, 3))
    return PLUGIN_HANDLED

  new szTarget[32], szMoney[8], iPlayer
  read_argv(1, szTarget, charsmax(szTarget))
  read_argv(2, szMoney, charsmax(szMoney))
  new iMoney = str_to_num(szMoney)
  new bool:bRemoveStatus = bool:(szMoney[0] == '-')
  if(!bRemoveStatus && !(0 < iMoney < 16001)) {
    console_print(id, _T("The money parameter must be between 1 and 16000!"))
    return PLUGIN_HANDLED
  }
  new bool:bHasSupreme = bool:(get_user_flags(id) & ADMIN_SUPREME)
  new szAdminName[32], szPlayerName[32]
  if(id == 0) szAdminName = "SERVER"
  else get_user_name(id, szAdminName, charsmax(szAdminName))

  if(szTarget[0] == '*') {
    new iPlayers[32], iPlayersNum, iBlockedPlayersNum
    get_players(iPlayers, iPlayersNum, "ch")
    if(iPlayersNum > 0) {
      for(new i = 0; i < iPlayersNum; i++) {
        iPlayer = iPlayers[i]
        if((iPlayer != id) && (bHasSupreme == false) && (get_user_flags(iPlayer) & ADMIN_IMMUNITY)) {
          get_user_name(iPlayer, szPlayerName, charsmax(szPlayerName))
          console_print(id, _T("Player ^"%s^" has immunity."), szPlayerName)
          iBlockedPlayersNum++
          continue
        }
        cs_set_user_money(iPlayer, clamp(cs_get_user_money(iPlayer) + iMoney, 0, 16000))
      }

      if(iBlockedPlayersNum == iPlayersNum) {
        console_print(id, _T("That action can't be performed on selected players."))
        return PLUGIN_HANDLED
      }

      if(!bRemoveStatus) console_print(id, _T("Money given to all players ($%d)."), iMoney)
      else console_print(id, _T("Money removed from all players ($%d)."), iMoney)

      #if !defined COLORED_ACTIVITY
      if(!bRemoveStatus) show_activity(id, szAdminName, _T("give money to all players."))
      else show_activity(id, szAdminName, _T("remove money from all players."))
      #else
      if(!bRemoveStatus) show_activity_color(id, szAdminName, _T("give money to all players."))
      else show_activity_color(id, szAdminName, _T("remove money from all players."))
      #endif

      #if defined USE_LOGS
      if(id > 0) {
        new szAdminAuthID[24], szAdminIPAddress[24]
        get_user_authid(id, szAdminAuthID, charsmax(szAdminAuthID))
        get_user_ip(id, szAdminIPAddress, charsmax(szAdminIPAddress), 1)

        if(!bRemoveStatus) log_amx("Admin Money: ^"<%s><%d><%s><%s>^" give money to all players ($%d).",
        szAdminName, get_user_userid(id), szAdminAuthID, szAdminIPAddress, iMoney)
        else log_amx("Admin Money: ^"<%s><%d><%s><%s>^" remove money from all players ($%d).",
        szAdminName, get_user_userid(id), szAdminAuthID, szAdminIPAddress, iMoney)
      }
      else {
        if(!bRemoveStatus) log_amx("Admin Money: <SERVER> give money to all players ($%d).", iMoney)
        else log_amx("Admin Money: <SERVER> remove money from all players ($%d).", iMoney)
      }
      #endif
    }
    else {
      console_print(id, _T("No real player on the server."))
    }
  }
  else if(szTarget[0] == '@') {
    new iPlayers[32], iPlayersNum, iBlockedPlayersNum
    get_players(iPlayers, iPlayersNum, "cegh", szTarget[1])
    if(iPlayersNum > 0) {
      for(new i = 0; i < iPlayersNum; i++) {
        iPlayer = iPlayers[i]
        if((iPlayer != id) && (bHasSupreme == false) && (get_user_flags(iPlayer) & ADMIN_IMMUNITY)) {
          get_user_name(iPlayer, szPlayerName, charsmax(szPlayerName))
          console_print(id, _T("Player ^"%s^" has immunity."), szPlayerName)
          iBlockedPlayersNum++
          continue
        }
        cs_set_user_money(iPlayer, clamp(cs_get_user_money(iPlayer) + iMoney, 0, 16000))
      }

      if(iBlockedPlayersNum == iPlayersNum) {
        console_print(id, _T("That action can't be performed on selected players."))
        return PLUGIN_HANDLED
      }

      new szTeamName[20]
      switch(szTarget[1]) {
        case '0', 'u', 'U': copy(szTeamName, charsmax(szTeamName), "UNASSIGNED")
        case '1', 't', 'T': copy(szTeamName, charsmax(szTeamName), "TERRORISTS")
        case '2', 'c', 'C': copy(szTeamName, charsmax(szTeamName), "CTs")
        case '3', 's', 'S': copy(szTeamName, charsmax(szTeamName), "SPECTATORS")
      }

      if(!bRemoveStatus) console_print(id, _T("Money given to the %s ($%d)."), _T(szTeamName), iMoney)
      else console_print(id, _T("Money removed from the %s ($%d)."), _T(szTeamName), iMoney)

      #if !defined COLORED_ACTIVITY
      if(!bRemoveStatus) show_activity(id, szAdminName, _T("give money to the %s."), _T(szTeamName))
      else show_activity(id, szAdminName, _T("remove money from the %s."), _T(szTeamName))
      #else
      if(!bRemoveStatus) show_activity_color(id, szAdminName, _T("give money to the %s."), _T(szTeamName))
      else show_activity_color(id, szAdminName, _T("remove money from the %s."), _T(szTeamName))
      #endif

      #if defined USE_LOGS
      if(id > 0) {
        new szAdminAuthID[24], szAdminIPAddress[24]
        get_user_authid(id, szAdminAuthID, charsmax(szAdminAuthID))
        get_user_ip(id, szAdminIPAddress, charsmax(szAdminIPAddress), 1)

        if(!bRemoveStatus) log_amx("Admin Money: ^"<%s><%d><%s><%s>^" give money to the %s ($%d).",
        szAdminName, get_user_userid(id), szAdminAuthID, szAdminIPAddress, szTeamName, iMoney)
        else log_amx("Admin Money: ^"<%s><%d><%s><%s>^" remove money from the %s ($%d).",
        szAdminName, get_user_userid(id), szAdminAuthID, szAdminIPAddress, szTeamName, iMoney)
      }
      else {
        if(!bRemoveStatus) log_amx("Admin Money: <SERVER> give money to the %s ($%d).", szTeamName, iMoney)
        else log_amx("Admin Money: <SERVER> remove money from the %s ($%d).", szTeamName, iMoney)
      }
      #endif
    }
    else {
      console_print(id, _T("No real player in this team."))
    }
  }
  else {
    iPlayer = cmd_target(id, szTarget, 11)
    if(!iPlayer)
      return PLUGIN_HANDLED

    cs_set_user_money(iPlayer, clamp(cs_get_user_money(iPlayer) + iMoney, 0, 16000))

    get_user_name(iPlayer, szPlayerName, charsmax(szPlayerName))

    if(!bRemoveStatus) console_print(id, _T("Money given to %s ($%d)."), szPlayerName, iMoney)
    else console_print(id, _T("Money removed from %s ($%d)."), szPlayerName, iMoney)

    #if !defined COLORED_ACTIVITY
    if(!bRemoveStatus) show_activity(id, szAdminName, _T("give money to %s."), szPlayerName)
    else show_activity(id, szAdminName, _T("remove money from %s."), szPlayerName)
    #else
    if(!bRemoveStatus) show_activity_color(id, szAdminName, _T("give money to %s."), szPlayerName)
    else show_activity_color(id, szAdminName, _T("remove money from %s."), szPlayerName)
    #endif

    #if defined USE_LOGS
    new iPlayerUserID, szPlayerAuthID[24], szPlayerIPAddress[24]
    iPlayerUserID = get_user_userid(iPlayer)
    get_user_authid(iPlayer, szPlayerAuthID, charsmax(szPlayerAuthID))
    get_user_ip(iPlayer, szPlayerIPAddress, charsmax(szPlayerIPAddress), 1)

    if(id > 0) {
      new iAdminUserID, szAdminAuthID[24], szAdminIPAddress[24]
      if(iPlayer != id) {
        iAdminUserID = get_user_userid(id)
        get_user_authid(id, szAdminAuthID, charsmax(szAdminAuthID))
        get_user_ip(id, szAdminIPAddress, charsmax(szAdminIPAddress), 1)
      }
      else {
        iAdminUserID = iPlayerUserID
        szAdminAuthID = szPlayerAuthID
        szAdminIPAddress = szPlayerIPAddress
      }

      if(!bRemoveStatus) log_amx("Admin Money: ^"<%s><%d><%s><%s>^" give money to ^"<%s><%d><%s><%s>^" ($%d).",
      szAdminName, iAdminUserID, szAdminAuthID, szAdminIPAddress,
      szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress, iMoney)
      else log_amx("Admin Money: ^"<%s><%d><%s><%s>^" remove money from ^"<%s><%d><%s><%s>^" ($%d).",
      szAdminName, iAdminUserID, szAdminAuthID, szAdminIPAddress,
      szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress, iMoney)
    }
    else {
      if(!bRemoveStatus) log_amx("Admin Money: <SERVER> give money to ^"<%s><%d><%s><%s>^" ($%d).",
      szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress, iMoney)
      else log_amx("Admin Money: <SERVER> remove money from ^"<%s><%d><%s><%s>^" ($%d).",
      szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress, iMoney)
    }
    #endif
  }
  return PLUGIN_HANDLED
}

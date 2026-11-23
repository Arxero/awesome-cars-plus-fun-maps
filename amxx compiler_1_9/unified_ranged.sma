/* AMX Mod X script.
*
*   Throwing Knives (throwing_knives.sma)
*   Copyright (C) 2003-2004  -]ToC[-Bludy / jtp10181
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
****************************************************************************
*
*   Version 1.0.2 - Date: 10/09/2004
*
*   Original by -]ToC[-Bludy
*
*   Upgraded to STEAM and ported to AMXx by: jtp10181 <jtp@jtpage.net>
*   Homepage: http://www.jtpage.net
*
****************************************************************************
*
*   Admin Commands:
*
*     amx_tknives	- Toggles Throwing Knives On and Off
*
*   Client Commands:
*
*     throw_knife		- This is the command for everyone to throw knives
*     say /knifehelp		- Brings up knifehelp menu to help players bind keys
*     say /throwingknives	- Same as /knifehelp
*
*  CVARs: Paste the following into your amxx.cfg to change defaults.
*		must uncomment cvar lines for them to take effect
*
****************************************************************************
*  CVAR CONFIG BEGIN
****************************************************************************

// ******************  Throwing Knives Setup ******************

//Toggles Throwing Knives on and off (default 0) ( 1 or 0 )
//amx_throwknives 1

//The amount of ammo to be given at roundstart (default 5) ( 1 or higher )
//amx_knifeammo 5

//Force at which knives are thrown (default 1200) ( 200 or higher )
//amx_knifetossforce 1200

//Maximum amount of knives allowed at once (default 10) ( amx_knifeammo or higher )
//amx_maxknifeammo 20

//Damage dealt on a knife hit (default 25) ( 1 or higher )
//amx_knifedmg 25

//Toggles knife dropping on death on and off (default 1) ( 1 or 0 )
//amx_dropknives 1

//Toggles autoswitching to knife when bind is pressed (default 1) ( 1 or 0 )
//amx_knifeautoswitch 1

//Toggles logging kill as "throwing_knife" or "knife" (default 0) (1 = throwing_knife, 0 = knife)
//amx_tknifelog 1

****************************************************************************
*  CVAR CONFIG END
****************************************************************************
*
*  Additional info:
*
*	- You must bind a key to throw_knife
*	- You can no longer drop your knives on command, only when you die
*	- Team Attack system dropped, but it will obey the server friendlyfire cvar
*
*  NEW FEATURES:
*
*	- New knife model, more effecient, smaller file size, easier to download
*	- New contact system, knife will stick to whatever they hit
*	- New code which is less CPU intensive, less bugs, server crashing seems to be eliminated.
*
*  DESCRIPTION:
*
*     It was brought to my attention a few days ago that with the update to the 
*     AMX forums the file attached to the bottom of the forum topic had only an 
*     .amx file and no custom model.  This gave me the motivation to create a new 
*     model that was smaller and faster to download, and a brand new knife system 
*     to make the knives more realistic.  It took a few server crashes to get the 
*     code right, but it payed off in the end.  A few of my clan members and I 
*     played throwing knife darts on one of the 
*     players sprays to celebrate.
*             
*     The knives work a lot better than before, and they are a lot of fun to 
*     play with. So get your knives out and go Have Fun
*
*                 ******** Engine Module REQUIRED ********
*                   ******** FUN Module REQUIRED ********
*
*  Changelog:
*
*  v1.0.2 - JTP10181 - 10/09/04
*	- Support for AMXModX 0.20
*
*  v1.0.1 - JTP10181 - 08/11/04
*	- Some tweaks to make it work better on listenservers, changed engclient_cmd to client_cmd
*
*  v1.0 - JTP10181 - 07/05/04
*	- Removed some unneeded return statements
*	- Made it so the knives cannot be used before the round has started (freezetime)
*	- Added some extra checks on variables to be safe
*	- Redid the delay code so it did not use a task
*	- Changed authid arrays to be 34 usable chars for future compatibility
*
*  v0.9.8 - JTP10181 - 06/08/04
*	- Tweaked the help messages a little for the commands
*	- Removed all \ line breaks, not supported anymore.
*	- Somewhere I added the auto-switch feature but forgot to log it.
*
*  v0.9.7 - JTP10181 - 05/19/04
*	- Upgraded MOTD box to STEAM compatibility
*	- Fixed bugs that happened when amx_knifeammo is greater than amx_maxknifeammo
*	- Made checks to keep amx_knifeammo from being set higher than amx_maxknifeammo
*	- Started to reorganize code to make it easier to follow
*	- Changed a lot of PLUGIN_HANDLED to PLUGIN_CONTINUE
*	- Fixed bug with partial pickups not subtracting the correct ammount from the dropped ammo
*	- Hopefully fixed bug that would sometimes kill all the knife entities in the middle of a round
*	- Added logging to server logs for stats software
*	- Fixed bugs with scores being updated wrong
*
*  Below v0.9.6 was maintained by -]ToC[-Bludy
*
**************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>


#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <nvault>

#define RW_KNIFE 1
#define RW_AXE   2
#define RW_SHIV  3
#define RW_SHURIKEN 4
#define RW_KUNAI 5
#define RW_CALTROP 6
#define RW_CHAKRAM 7
#define CHAKRAM_OUT 0
#define CHAKRAM_AUTO 1
#define CHAKRAM_WALL 2
#define CHAKRAM_WALL_AUTO 3
#define CHAKRAM_RECALL 4
#define CHAKRAM_LOST 5
#define TASK_CHAKRAM_KNOCKBACK 24000

new bool:knifeout[33], bool:roundfreeze
new Float:tossdelay[33]
new ammo[33], holdammo[33], activeType[33], pendingType[33], lastAmmoRound[33]
new g_round, g_vault, g_poisonTaskSerial
new poisonStacks[33]
new Float:g_chakramHit[2049][33]
new g_chakramHits[2049][33]

stock get_max_ammo(type)
{
    switch(type) {
        case RW_AXE: return 3
        case RW_SHIV: return 10
        case RW_SHURIKEN: return 7
        case RW_KUNAI: return 6
        case RW_CALTROP: return 5
        case RW_CHAKRAM: return 1
        default: return get_cvar_num("amx_knifeammo")
    }
    return 5
}
stock get_damage(type)
{
    switch(type) {
        case RW_AXE: return 39
        case RW_SHIV: return 15
        case RW_SHURIKEN: return 10
        case RW_KUNAI: return 18
        case RW_CALTROP: return 20
        case RW_CHAKRAM: return 20
        default: return get_cvar_num("amx_knifedmg")
    }
    return 25
}
stock Float:get_delay(type)
{
    switch(type) {
        case RW_AXE: return 1.0
        case RW_SHIV: return 0.20
        case RW_SHURIKEN: return 0.67
        case RW_KUNAI: return 0.60
        case RW_CALTROP: return 0.90
        case RW_CHAKRAM: return 0.0
        default: return 0.50
    }
    return 0.50
}
stock get_force(type)
{
    switch(type) {
        case RW_AXE: return floatround(float(get_cvar_num("amx_knifetossforce")) * 1.35)
        case RW_SHIV: return floatround(float(get_cvar_num("amx_knifetossforce")) * 1.27)
        case RW_SHURIKEN: return floatround(float(get_cvar_num("amx_knifetossforce")) * 1.67)
        case RW_KUNAI: return get_cvar_num("amx_knifetossforce")
        case RW_CALTROP: return floatround(float(get_cvar_num("amx_knifetossforce")) * 0.55)
        case RW_CHAKRAM: return get_cvar_num("amx_chakram_speed")
        default: return get_cvar_num("amx_knifetossforce")
    }
    return 1200
}
stock get_projectile_model(type, model[], len)
{
    switch(type) {
        case RW_AXE: copy(model, len, "models/w_throwing_axe.mdl")
        case RW_SHIV: copy(model, len, "models/w_throwing_shiv.mdl")
        case RW_SHURIKEN: copy(model, len, "models/w_throwing_shuriken.mdl")
        case RW_KUNAI: copy(model, len, "models/w_throwing_kunai.mdl")
        case RW_CALTROP: copy(model, len, "models/w_throwing_caltrop.mdl")
        case RW_CHAKRAM: copy(model, len, "models/w_throwing_chakram.mdl")
        default: copy(model, len, "models/w_throwingknife.mdl")
    }
}
stock get_label(type, label[], len)
{
    switch(type) {
        case RW_AXE: copy(label, len, "throwing axes")
        case RW_SHIV: copy(label, len, "throwing shivs")
        case RW_SHURIKEN: copy(label, len, "throwing shurikens")
        case RW_KUNAI: copy(label, len, "throwing kunais")
        case RW_CALTROP: copy(label, len, "throwing caltrops")
        case RW_CHAKRAM: copy(label, len, "chakram")
        default: copy(label, len, "throwing knives")
    }
}
stock show_ammo(id)
{
    if (!is_user_connected(id)) return
    if (activeType[id] == RW_AXE)
        client_print(id, print_center, "You have %d throwing axes", ammo[id])
    else if (activeType[id] == RW_SHIV)
        client_print(id, print_center, "You have %d shivs", ammo[id])
    else if (activeType[id] == RW_SHURIKEN)
        client_print(id, print_center, "You have %d shurikens", ammo[id])
    else if (activeType[id] == RW_KUNAI)
        client_print(id, print_center, "You have %d kunais", ammo[id])
    else if (activeType[id] == RW_CALTROP)
        client_print(id, print_center, "You have %d caltrops", ammo[id])
    else if (activeType[id] == RW_CHAKRAM)
        client_print(id, print_center, "Chakram: %s", ammo[id] ? "READY" : "UNAVAILABLE")
    else
        client_print(id, print_center, "You have %d throwing %s", ammo[id], ammo[id] == 1 ? "knife" : "knives")
}
stock save_selection(id)
{
    if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) return
    new authid[35], key[40], value[8]
    get_user_authid(id, authid, charsmax(authid))
    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "STEAM_ID_LAN") || equal(authid, "VALVE_ID_LAN")) return
    formatex(key, charsmax(key), "%s", authid)
    num_to_str(activeType[id], value, charsmax(value))
    nvault_set(g_vault, key, value)
}
stock save_pending_selection(id, type)
{
    if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) return
    new authid[35], value[8]
    get_user_authid(id, authid, charsmax(authid))
    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "STEAM_ID_LAN") || equal(authid, "VALVE_ID_LAN")) return
    num_to_str(type, value, charsmax(value))
    nvault_set(g_vault, authid, value)
}

stock load_selection(id)
{
    activeType[id] = RW_KNIFE
    pendingType[id] = RW_KNIFE
    if (is_user_bot(id) || is_user_hltv(id)) return
    new authid[35], value[8]
    get_user_authid(id, authid, charsmax(authid))
    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "STEAM_ID_LAN") || equal(authid, "VALVE_ID_LAN")) return
    if (nvault_get(g_vault, authid, value, charsmax(value))) {
        new type = str_to_num(value)
        if (type >= RW_KNIFE && type <= RW_CHAKRAM)
            activeType[id] = pendingType[id] = type
    }
}
public player_death()
{
    new id = read_data(2)
    if (!is_user_connected(id) || !get_cvar_num("amx_dropknives") || !get_cvar_num("amx_throwknives") || ammo[id] <= 0) return

    new Float:origin[3], Float:velocity[3]
    entity_get_vector(id, EV_VEC_origin, origin)
    new ent = create_entity("info_target")
    if (!ent) return

    entity_set_string(ent, EV_SZ_classname, "ranged_pickup")
    entity_set_model(ent, "models/w_knifepack.mdl")
    new Float:mins[3] = {-1.0, -1.0, -1.0}, Float:maxs[3] = {1.0, 1.0, 1.0}
    entity_set_vector(ent, EV_VEC_mins, mins)
    entity_set_vector(ent, EV_VEC_maxs, maxs)
    entity_set_origin(ent, origin)
    entity_set_int(ent, EV_INT_effects, 32)
    entity_set_int(ent, EV_INT_solid, 1)
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
    entity_set_edict(ent, EV_ENT_owner, id)
    entity_set_int(ent, EV_INT_iuser1, activeType[id])
    entity_set_int(ent, EV_INT_iuser2, ammo[id])
    VelocityByAim(id, 400, velocity)
    entity_set_vector(ent, EV_VEC_velocity, velocity)
    holdammo[id] = ammo[id]
    ammo[id] = 0
}
public HandleSay(id)
{
    new speech[192]
    read_args(speech, charsmax(speech)); remove_quotes(speech)
    if (!equal(speech, "vote", 4) && ((containi(speech, "knife") != -1) || (containi(speech, "knives") != -1))) {
        client_print(id, print_chat, get_cvar_num("amx_throwknives") ? "[AMX] Ranged throwing weapons are ON - say /ranged" : "[AMX] Ranged throwing weapons are OFF")
    }
}
public check_knife(id)
{
    if (!get_cvar_num("amx_throwknives")) return
    knifeout[id] = (read_data(2) == CSW_KNIFE)
    if (knifeout[id]) show_ammo(id)
}
public kill_all_entity(classname[])
{
    new ent = find_ent_by_class(-1, classname), next
    while (ent > 0) {
        next = find_ent_by_class(ent, classname)
        if (equal(classname, "ranged_projectile")) stop_airborne_sound(ent)
        remove_entity(ent)
        ent = next
    }
}
public new_spawn(id)
{
    if (!is_user_alive(id)) return
    if (lastAmmoRound[id] != g_round) {
        ammo[id] = get_max_ammo(activeType[id])
        lastAmmoRound[id] = g_round
    } else if (activeType[id] == RW_KNIFE) {
        if (ammo[id] < get_cvar_num("amx_knifeammo")) ammo[id] = get_cvar_num("amx_knifeammo")
        if (ammo[id] > get_cvar_num("amx_maxknifeammo")) ammo[id] = get_cvar_num("amx_maxknifeammo")
    }
    tossdelay[id] = 0.0
    show_ammo(id)
}
public client_connect(id)
{
    ammo[id] = 0; holdammo[id] = 0; tossdelay[id] = 0.0
    knifeout[id] = false; lastAmmoRound[id] = -1
    load_selection(id)
}
public client_authorized(id) { load_selection(id); }
public client_disconnect(id)
{
    ammo[id] = 0; holdammo[id] = 0; tossdelay[id] = 0.0
    knifeout[id] = false; activeType[id] = RW_KNIFE; pendingType[id] = RW_KNIFE
    lastAmmoRound[id] = -1
    remove_task(2000 + id)
}
public round_start()
{
    roundfreeze = false
    g_round++
    for (new id=1; id<=32; id++) {
        if (!is_user_connected(id)) continue
        if (pendingType[id] < RW_KNIFE || pendingType[id] > RW_CHAKRAM)
            pendingType[id] = RW_KNIFE
        if (activeType[id] < RW_KNIFE || activeType[id] > RW_CHAKRAM)
            activeType[id] = RW_KNIFE
        if (pendingType[id] != activeType[id]) {
            activeType[id] = pendingType[id]
            client_print(id, print_chat, "[Ranged] Your selected weapon is now active: %s.", activeType[id] == RW_AXE ? "Axes" : activeType[id] == RW_SHIV ? "Shivs" : activeType[id] == RW_SHURIKEN ? "Shurikens" : activeType[id] == RW_KUNAI ? "Kunais" : activeType[id] == RW_CALTROP ? "Caltrops" : activeType[id] == RW_CHAKRAM ? "Chakram" : "Knives")
        }
        save_pending_selection(id, activeType[id])
        ammo[id] = get_max_ammo(activeType[id])
        lastAmmoRound[id] = g_round
        show_ammo(id)
    }
}
public round_end()
{
    roundfreeze = true
    kill_all_entity("ranged_projectile")
    kill_all_entity("ranged_pickup")
    kill_all_entity("throwing_knife")
    kill_all_entity("knife_pickup")
}
public ranged_menu(id)
{
    if (!is_user_connected(id)) return PLUGIN_HANDLED
    new title[128], menu
    formatex(title, charsmax(title), "\yRanged Weapons^n\wChoose your weapon")
    menu = menu_create(title, "ranged_menu_handler")
    new label[64]
    formatex(label, charsmax(label), "%sKnives%s", pendingType[id] == RW_KNIFE ? "\y" : "\w", pendingType[id] == RW_KNIFE ? " [SELECTED]" : "")
    menu_additem(menu, label, "1")
    formatex(label, charsmax(label), "%sAxes%s", pendingType[id] == RW_AXE ? "\y" : "\w", pendingType[id] == RW_AXE ? " [SELECTED]" : "")
    menu_additem(menu, label, "2")
    formatex(label, charsmax(label), "%sShivs%s", pendingType[id] == RW_SHIV ? "\y" : "\w", pendingType[id] == RW_SHIV ? " [SELECTED]" : "")
    menu_additem(menu, label, "3")
    formatex(label, charsmax(label), "%sShurikens%s", pendingType[id] == RW_SHURIKEN ? "\y" : "\w", pendingType[id] == RW_SHURIKEN ? " [SELECTED]" : "")
    menu_additem(menu, label, "4")
    formatex(label, charsmax(label), "%sKunais%s", pendingType[id] == RW_KUNAI ? "\y" : "\w", pendingType[id] == RW_KUNAI ? " [SELECTED]" : "")
    menu_additem(menu, label, "5")
    formatex(label, charsmax(label), "%sCaltrops%s", pendingType[id] == RW_CALTROP ? "\y" : "\w", pendingType[id] == RW_CALTROP ? " [SELECTED]" : "")
    menu_additem(menu, label, "6")
    formatex(label, charsmax(label), "%sChakram%s", pendingType[id] == RW_CHAKRAM ? "\y" : "\w", pendingType[id] == RW_CHAKRAM ? " [SELECTED]" : "")
    menu_additem(menu, label, "7")
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
    menu_display(id, menu)
    return PLUGIN_HANDLED
}
public ranged_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    new data[8], name[64], access, callback
    menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback)
    new choice = str_to_num(data)
    if (choice >= RW_KNIFE && choice <= RW_CHAKRAM) {
        // Persist the requested selection immediately, but keep the current
        // weapon/ammo unchanged until the next round starts.
        pendingType[id] = choice
        save_pending_selection(id, choice)
        if (choice == activeType[id]) {
            client_print(id, print_chat, "[Ranged] %s selected. It is already active.", choice == RW_AXE ? "Axes" : choice == RW_SHIV ? "Shivs" : choice == RW_SHURIKEN ? "Shurikens" : choice == RW_KUNAI ? "Kunais" : choice == RW_CALTROP ? "Caltrops" : choice == RW_CHAKRAM ? "Chakram" : "Knives")
        } else {
            client_print(id, print_chat, "[Ranged] %s selected. It will become active next round.", choice == RW_AXE ? "Axes" : choice == RW_SHIV ? "Shivs" : choice == RW_SHURIKEN ? "Shurikens" : choice == RW_KUNAI ? "Kunais" : choice == RW_CALTROP ? "Caltrops" : choice == RW_CHAKRAM ? "Chakram" : "Knives")
        }
    } else {
        client_print(id, print_chat, "[Ranged] Selection error: invalid menu item (%s).", data)
    }
    menu_destroy(menu)
    return PLUGIN_HANDLED
}
public poison_tick(data[])
{
    new victim = data[0]
    new attacker = data[1]
    if (!is_user_alive(victim)) {
        if (poisonStacks[victim] > 0) poisonStacks[victim]--
        if (poisonStacks[victim] <= 0 && is_user_connected(victim)) {
            poisonStacks[victim] = 0
            message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, victim)
            write_byte(0); write_string("dmg_rad"); message_end()
        }
        return
    }
    new hp = get_user_health(victim)
    if (hp <= 2) {
        if (is_user_connected(attacker) && attacker != victim) {
            set_user_frags(attacker, get_user_frags(attacker) + 1)
            new msgDeath = get_user_msgid("DeathMsg")
            set_msg_block(msgDeath, BLOCK_ONCE)
            user_kill(victim, 1)
            message_begin(MSG_ALL, msgDeath, {0,0,0}, 0)
            write_byte(attacker); write_byte(victim); write_byte(0); write_string("kunai_poison"); message_end()
        } else user_kill(victim, 1)
    } else {
        set_user_health(victim, hp - 2)
    }
    if (poisonStacks[victim] > 0) poisonStacks[victim]--
    if (poisonStacks[victim] <= 0) {
        poisonStacks[victim] = 0
        message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, victim)
        write_byte(0); write_string("dmg_rad"); message_end()
    }
}
public restore_slow(data[])
{
    new id = data[0]
    if (is_user_alive(id)) set_user_maxspeed(id, 250.0)
}
public apply_kunai_poison(victim, attacker)
{
    new data[2]
    data[0] = victim
    data[1] = attacker
    g_poisonTaskSerial++
    if (g_poisonTaskSerial > 2000000000) g_poisonTaskSerial = 1
    poisonStacks[victim] += 5
    message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, victim)
    write_byte(1); write_string("dmg_rad"); message_end()
    set_task(3.0, "poison_tick", 10000 + g_poisonTaskSerial, data, sizeof data, "a", 5)
}
// Airborne sound loop: each projectile owns its own task.
#define TASK_AIR_SOUND 10000
stock start_airborne_sound(ent)
{
    if (!is_valid_ent(ent)) return
    new type = entity_get_int(ent, EV_INT_iuser1)
    // No glaive loop for ordinary knives, shivs, kunais or caltrops.
    // Shuriken behavior is intentionally unchanged; chakram also loops while flying/recalling.
    if (type == RW_KNIFE || type == RW_SHIV || type == RW_KUNAI || type == RW_CALTROP) return
    remove_task(TASK_AIR_SOUND + ent)
    emit_sound(ent, CHAN_AUTO, "weapons/knife_arena/glaive_special.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
    new data[1]; data[0] = ent
    set_task(1.067, "airborne_sound_tick", TASK_AIR_SOUND + ent, data, sizeof data, "b")
}
public airborne_sound_tick(data[])
{
    new ent = data[0]
    if (!is_valid_ent(ent)) { remove_task(TASK_AIR_SOUND + ent); return; }
    new classname[32]
    entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname))
    if (!equal(classname, "ranged_projectile")) { remove_task(TASK_AIR_SOUND + ent); return; }
    emit_sound(ent, CHAN_AUTO, "weapons/knife_arena/glaive_special.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
stock stop_airborne_sound(ent)
{
    if (!is_valid_ent(ent)) return
    remove_task(TASK_AIR_SOUND + ent)
    emit_sound(ent, CHAN_AUTO, "weapons/knife_arena/glaive_special.wav", 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
}

// Apply Chakram return knockback one frame after touch. GoldSrc can overwrite
// player velocity during the touch/physics pass, so applying it immediately is unreliable.
public apply_chakram_knockback(data[])
{
    new victim = data[0]
    new owner = data[1]
    if (!is_user_alive(victim) || !is_user_alive(owner)) return

    new Float:ownerOrigin[3], Float:victimOrigin[3], Float:velocity[3]
    pev(owner, pev_origin, ownerOrigin)
    pev(victim, pev_origin, victimOrigin)

    // Always aim horizontally from the victim toward the owner's CURRENT position.
    // Do not use the victim's view angles or the Chakram's flight direction.
    new Float:dx = ownerOrigin[0] - victimOrigin[0]
    new Float:dy = ownerOrigin[1] - victimOrigin[1]
    new Float:horizontalLength = floatsqroot(dx * dx + dy * dy)

    if (horizontalLength > 1.0) {
        velocity[0] = (dx / horizontalLength) * 1100.0
        velocity[1] = (dy / horizontalLength) * 1100.0
    } else {
        velocity[0] = 0.0
        velocity[1] = 0.0
    }

    // Add a vertical component so grounded players are actually launched.
    new Float:dz = ownerOrigin[2] - victimOrigin[2]
    if (dz > 60.0) velocity[2] = floatmin(dz * 2.0, 450.0)
    else if (dz < -60.0) velocity[2] = floatmax(dz * 2.0, -450.0)
    else velocity[2] = 220.0

    // Clear on-ground before setting velocity; otherwise ground friction can
    // immediately cancel most of the horizontal impulse.
    new flags = pev(victim, pev_flags)
    set_pev(victim, pev_flags, flags & ~FL_ONGROUND)
    set_pev(victim, pev_velocity, velocity)
}

public vexd_pfntouch(toucher, touched)
{
    if (!is_valid_ent(toucher) || !get_cvar_num("amx_throwknives")) return
    new classname[32]
    entity_get_string(toucher, EV_SZ_classname, classname, charsmax(classname))
    new owner = entity_get_edict(toucher, EV_ENT_owner)
    new type = entity_get_int(toucher, EV_INT_iuser1)

    if (equal(classname, "ranged_pickup")) {
        if (!is_user_alive(touched) || activeType[touched] != type || ammo[touched] >= get_max_ammo(type)) return
        new amount = entity_get_int(toucher, EV_INT_iuser2)
        if (amount <= 0) amount = holdammo[owner]
        if (amount <= 0) { remove_entity(toucher); return; }
        new room = get_max_ammo(type) - ammo[touched]
        new take = amount < room ? amount : room
        ammo[touched] += take
        amount -= take
        entity_set_int(toucher, EV_INT_iuser2, amount)
        if (amount <= 0) remove_entity(toucher)
        show_ammo(touched)
        emit_sound(touched, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        return
    }
    if (!equal(classname, "ranged_projectile")) return

    if (type == RW_CHAKRAM) {
        new st=entity_get_int(toucher,EV_INT_iuser2)
        if(is_user_alive(touched)) {
            // GoldSrc may alter projectile velocity during any player touch.
            // Restore it even for owner/friendly-fire contacts so the chakram pierces cleanly.
            new Float:savedVelocity[3]
            entity_get_vector(toucher, EV_VEC_vuser3, savedVelocity)
            if (savedVelocity[0] == 0.0 && savedVelocity[1] == 0.0 && savedVelocity[2] == 0.0)
                entity_get_vector(toucher, EV_VEC_velocity, savedVelocity)

            // Physical contact with its owner during either return state is a catch.
            // Do this before the pass-through offset so a successful catch cannot
            // be pushed outside the recovery radius.
            if (owner == touched && (st == CHAKRAM_AUTO || st == CHAKRAM_RECALL)) {
                ammo[touched]=1
                tossdelay[touched]=get_gametime()+5.0
                show_ammo(touched)
                emit_sound(touched,CHAN_ITEM,"weapons/knife_deploy1.wav",1.0,ATTN_NORM,0,PITCH_NORM)
                stop_airborne_sound(toucher)
                remove_entity(toucher)
                return
            }

            // Keep the projectile on its own trajectory. GoldSrc can alter a
            // MOVETYPE_TOSS entity's velocity on player contact; restore it and
            // advance beyond the player's collision bounds so it cleanly pierces.
            new Float:speed = floatsqroot(savedVelocity[0]*savedVelocity[0] + savedVelocity[1]*savedVelocity[1] + savedVelocity[2]*savedVelocity[2])
            if (speed > 1.0) {
                new Float:origin[3]
                entity_get_vector(toucher, EV_VEC_origin, origin)
                origin[0] += savedVelocity[0] / speed * 20.0
                origin[1] += savedVelocity[1] / speed * 20.0
                origin[2] += savedVelocity[2] / speed * 20.0
                entity_set_origin(toucher, origin)
                entity_set_vector(toucher, EV_VEC_velocity, savedVelocity)
            }
            if(owner==touched) return
            // Outbound hits deal 17 damage without knockback. Automatic turnaround
            // and manual-recall hits deal the configured 20 damage, also without knockback.
            if(st!=CHAKRAM_OUT && st!=CHAKRAM_AUTO && st!=CHAKRAM_RECALL) return
            if(!get_cvar_num("mp_friendlyfire") && get_user_team(touched)==get_user_team(owner)) return
            if(toucher<=2048 && g_chakramHits[toucher][touched]>=2) return
            if(toucher<=2048 && g_chakramHit[toucher][touched] > 0.0 && g_chakramHit[toucher][touched] > get_gametime()-0.12) return
            if(toucher<=2048) {
                g_chakramHit[toucher][touched]=get_gametime()
                g_chakramHits[toucher][touched]++
            }
            // Match the other ranged throwables: custom fixed health subtraction.
            // Do NOT call Ham_TakeDamage; unified_melee treats knife-held attackers as melee.
            new dmg=(st==CHAKRAM_OUT ? 17 : get_cvar_num("amx_chakram_damage")),hp=get_user_health(touched)
            entity_set_float(touched,EV_FL_dmg_take,float(dmg)); emit_sound(touched,CHAN_ITEM,"weapons/knife_hit4.wav",1.0,ATTN_NORM,0,PITCH_NORM)
            if(hp<=dmg) {
                if(is_user_connected(owner)) {
                    set_user_frags(owner,get_user_frags(owner)+(get_user_team(touched)==get_user_team(owner)?-1:1))
                    new dm=get_user_msgid("DeathMsg"); set_msg_block(dm,BLOCK_ONCE); user_kill(touched,1)
                    message_begin(MSG_ALL,dm,{0,0,0},0); write_byte(owner); write_byte(touched); write_byte(0); write_string("chakram"); message_end()
                } else user_kill(touched,1)
            } else set_user_health(touched,hp-dmg)
            // Return/recall knockback is calculated from the owner's live position
            // on the next frame, after GoldSrc finishes the touch collision response.
            if ((st == CHAKRAM_AUTO || st == CHAKRAM_RECALL) && is_user_alive(owner) && is_user_alive(touched)) {
                new knockData[2]
                knockData[0] = touched
                knockData[1] = owner
                remove_task(TASK_CHAKRAM_KNOCKBACK + touched)
                set_task(0.01, "apply_chakram_knockback", TASK_CHAKRAM_KNOCKBACK + touched, knockData, sizeof knockData)
            }
            // Preserve the chakram's own flight vector independently of victim knockback.
            entity_set_vector(toucher, EV_VEC_vuser3, savedVelocity)
            return
        }
        if(st==CHAKRAM_OUT) entity_set_int(toucher,EV_INT_iuser2,CHAKRAM_WALL)
        else if(st==CHAKRAM_AUTO) entity_set_int(toucher,EV_INT_iuser2,CHAKRAM_WALL_AUTO)
        else if(st==CHAKRAM_RECALL) entity_set_int(toucher,EV_INT_iuser2,CHAKRAM_LOST)
        entity_set_int(toucher,EV_INT_movetype,MOVETYPE_NONE); entity_set_int(toucher,EV_INT_solid,SOLID_NOT)
        new Float:zero[3]={0.0,0.0,0.0}; entity_set_vector(toucher,EV_VEC_velocity,zero)
        stop_airborne_sound(toucher)
        emit_sound(toucher,CHAN_ITEM,"weapons/knife_arena/scythe_hitwall.wav",1.0,ATTN_NORM,0,PITCH_NORM)
        return
    }

    if (type == RW_CALTROP) {
        if (is_user_alive(touched)) {
            if (owner == touched) return
            if (!get_cvar_num("mp_friendlyfire") && get_user_team(touched) == get_user_team(owner)) return
            new planted = (entity_get_int(toucher, EV_INT_iuser3) == 1)
            new damage = planted ? 35 : 22
            new hp = get_user_health(touched)
            emit_sound(touched, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            if (hp <= damage) {
                if (is_user_connected(owner)) {
                    set_user_frags(owner, get_user_frags(owner) + 1)
                    new msgDeath = get_user_msgid("DeathMsg")
                    set_msg_block(msgDeath, BLOCK_ONCE)
                    user_kill(touched, 1)
                    message_begin(MSG_ALL, msgDeath, {0,0,0}, 0)
                    write_byte(owner); write_byte(touched); write_byte(0); write_string("caltrop"); message_end()
                } else user_kill(touched, 1)
            } else set_user_health(touched, hp - damage)
            // Only a planted caltrop (stepped on) deals 45 damage and slows.
            // A direct projectile hit deals 22 damage and never applies slow.
            if (planted && is_user_alive(touched)) {
                set_user_maxspeed(touched, 100.0)
                new slowData[1]; slowData[0] = touched
                remove_task(2000 + touched)
                set_task(3.0, "restore_slow", 2000 + touched, slowData, sizeof slowData)
            }
            remove_entity(toucher)
        } else {
            entity_set_int(toucher, EV_INT_iuser3, 1)
            entity_set_int(toucher, EV_INT_movetype, MOVETYPE_NONE)
            entity_set_int(toucher, EV_INT_solid, SOLID_TRIGGER)
            new Float:mins[3] = {-12.0, -12.0, -4.0}, Float:maxs[3] = {12.0, 12.0, 4.0}
            entity_set_vector(toucher, EV_VEC_mins, mins)
            entity_set_vector(toucher, EV_VEC_maxs, maxs)
            emit_sound(toucher, CHAN_ITEM, "weapons/knife_arena/axe_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        }
        return
    }

    if (type == RW_SHURIKEN && !is_user_alive(touched)) {
        // Let the engine perform grenade-style surface reflection (MOVETYPE_BOUNCE).
        // Do not rewrite the velocity here: doing so after touch causes surface sliding.
        new bounces = entity_get_int(toucher, EV_INT_iuser2) + 1
        entity_set_int(toucher, EV_INT_iuser2, bounces)
        emit_sound(toucher, CHAN_ITEM, "weapons/knife_arena/katana_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        if (bounces >= 10	) {
            new Float:origin[3], Float:velocity[3]
            entity_get_vector(toucher, EV_VEC_origin, origin)
            velocity[0] = 0.0
            velocity[1] = 0.0
            velocity[2] = 0.0
            entity_set_vector(toucher, EV_VEC_velocity, velocity)
            entity_set_int(toucher, EV_INT_movetype, MOVETYPE_NONE)
            entity_set_int(toucher, EV_INT_solid, SOLID_NOT)
            entity_set_int(toucher, EV_INT_iuser3, 4)
            stop_airborne_sound(toucher)
        } else {
            entity_set_int(toucher, EV_INT_iuser3, bounces)
        }
        // The next think runs after the engine's collision response.
        entity_set_int(toucher, EV_INT_iuser4, 1)
        return
    }

    if (is_user_alive(touched)) {
        if (type == RW_KNIFE && entity_get_int(toucher, EV_INT_movetype) == MOVETYPE_NONE) {
            // The thrower must also be able to recover a missed knife.
            if (activeType[touched] != RW_KNIFE || ammo[touched] >= get_cvar_num("amx_maxknifeammo")) return
            ammo[touched]++
            show_ammo(touched)
            emit_sound(touched, CHAN_ITEM, "weapons/knife_deploy1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            remove_entity(toucher)
            return
        }
        stop_airborne_sound(toucher)
        if (owner == touched) return
        new ricochets = entity_get_int(toucher, EV_INT_iuser3)
        remove_entity(toucher)
        if (!get_cvar_num("mp_friendlyfire") && get_user_team(touched) == get_user_team(owner)) return
        new damage = get_damage(type)
        if (type == RW_SHURIKEN) damage += ricochets * 10
        new health = get_user_health(touched)
        if (type == RW_KUNAI) apply_kunai_poison(touched, owner)
        // Preserve the damage amount in the entity damage field so popular
        // damager/HUD plugins can read and display the hit value, as the
        // original throwing-knives plugin did.
        entity_set_float(touched, EV_FL_dmg_take, float(damage))
        emit_sound(touched, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        if (health <= damage) {
            if (get_user_team(touched) == get_user_team(owner)) {
                set_user_frags(owner, get_user_frags(owner) - 1)
                client_print(owner, print_center, "You killed a teammate")
            } else set_user_frags(owner, get_user_frags(owner) + 1)
            new msgScore = get_user_msgid("ScoreInfo"), msgDeath = get_user_msgid("DeathMsg")
            set_msg_block(msgDeath, BLOCK_ONCE)
            set_msg_block(msgScore, BLOCK_ONCE)
            user_kill(touched, 1)
            message_begin(MSG_ALL, msgScore)
            write_byte(owner); write_short(get_user_frags(owner)); write_short(get_user_deaths(owner)); write_short(0); write_short(get_user_team(owner)); message_end()
            message_begin(MSG_ALL, msgScore)
            write_byte(touched); write_short(get_user_frags(touched)); write_short(get_user_deaths(touched)); write_short(0); write_short(get_user_team(touched)); message_end()
            message_begin(MSG_ALL, msgDeath, {0,0,0}, 0)
            write_byte(owner); write_byte(touched); write_byte(0); write_string(type == RW_AXE ? "axe" : type == RW_SHIV ? "shiv" : type == RW_SHURIKEN ? "shuriken" : type == RW_KUNAI ? "kunai" : type == RW_CALTROP ? "caltrop" : "knife"); message_end()
        } else set_user_health(touched, health - damage)
        // Apply axe knockback after damage handling so the touch/damage code
        // does not immediately overwrite the victim's velocity.
        if (type == RW_AXE && is_user_alive(touched) && is_user_alive(owner)) {
            new Float:attackerOrigin[3], Float:victimOrigin[3], Float:push[3]
            entity_get_vector(owner, EV_VEC_origin, attackerOrigin)
            entity_get_vector(touched, EV_VEC_origin, victimOrigin)
            push[0] = victimOrigin[0] - attackerOrigin[0]
            push[1] = victimOrigin[1] - attackerOrigin[1]
            new Float:length = floatsqroot(push[0] * push[0] + push[1] * push[1])
            if (length > 0.1) {
                push[0] = push[0] / length * 150.0
                push[1] = push[1] / length * 150.0
                push[2] = 0.0
                set_user_velocity(touched, push)
            }
        }
    } else {
        stop_airborne_sound(toucher)
        if (type == RW_KNIFE) {
            entity_set_int(toucher, EV_INT_movetype, MOVETYPE_NONE)
            entity_set_int(toucher, EV_INT_solid, SOLID_TRIGGER)
            new Float:pickupMins[3] = {-12.0, -12.0, -12.0}, Float:pickupMaxs[3] = {12.0, 12.0, 12.0}
            entity_set_vector(toucher, EV_VEC_mins, pickupMins)
            entity_set_vector(toucher, EV_VEC_maxs, pickupMaxs)
            emit_sound(toucher, CHAN_ITEM, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        } else {
            // Stick axes and shivs into walls/ground just like knives, but
            // keep them permanently non-pickup. MOVETYPE_NONE freezes them.
            entity_set_int(toucher, EV_INT_movetype, 0)
            entity_set_int(toucher, EV_INT_solid, SOLID_NOT)
            if (type == RW_SHIV)
                emit_sound(toucher, CHAN_ITEM, "weapons/knife_arena/claws_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            else if (type == RW_AXE)
                emit_sound(toucher, CHAN_ITEM, "weapons/knife_arena/axe_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            else if (type == RW_KUNAI)
                emit_sound(toucher, CHAN_ITEM, "weapons/knife_arena/axe_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            else if (type == RW_CALTROP)
                emit_sound(toucher, CHAN_ITEM, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        }
    }
}
public command_knife(id)
{
    if (!is_user_alive(id) || !get_cvar_num("amx_throwknives") || roundfreeze) return PLUGIN_HANDLED
    if (get_cvar_num("amx_knifeautoswitch")) {
        knifeout[id] = true
        client_cmd(id, "weapon_knife")
    }
    if (activeType[id]==RW_CHAKRAM && knifeout[id]) {
        new ce=find_ent_by_class(-1,"ranged_projectile")
        while(ce>0) {
            if(entity_get_edict(ce,EV_ENT_owner)==id && entity_get_int(ce,EV_INT_iuser1)==RW_CHAKRAM) {
                new st=entity_get_int(ce,EV_INT_iuser2)
                if(st==CHAKRAM_WALL || st==CHAKRAM_WALL_AUTO) {
                    new Float:po[3],Float:eo[3],Float:v[3]
                    entity_get_vector(id,EV_VEC_origin,po); entity_get_vector(ce,EV_VEC_origin,eo)
                    v[0]=po[0]-eo[0]; v[1]=po[1]-eo[1]; v[2]=po[2]-eo[2]
                    new Float:l=floatsqroot(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]); if(l<1.0) l=1.0
                    new Float:sp=float(get_cvar_num("amx_chakram_speed"))*0.35
                    v[0]=v[0]/l*sp; v[1]=v[1]/l*sp; v[2]=v[2]/l*sp
                    entity_set_vector(ce,EV_VEC_vuser1,v)
                    entity_set_vector(ce,EV_VEC_vuser2,po)
                    entity_set_float(ce,EV_FL_fuser1,l)
                    entity_set_int(ce,EV_INT_iuser2,CHAKRAM_RECALL)
                    entity_set_int(ce,EV_INT_movetype,MOVETYPE_FLY)
                    entity_set_int(ce,EV_INT_solid,SOLID_BBOX)
                    entity_set_float(ce,EV_FL_gravity,0.0)
                    entity_set_vector(ce,EV_VEC_velocity,v)
                    entity_set_vector(ce,EV_VEC_vuser3,v)
                    entity_set_float(ce,EV_FL_nextthink,get_gametime()+0.05)
                    start_airborne_sound(ce)
                    return PLUGIN_HANDLED
                }
            }
            ce=find_ent_by_class(ce,"ranged_projectile")
        }
    }
    if (!ammo[id]) { client_print(id, print_center, "You are out of ranged weapons"); return PLUGIN_HANDLED; }
    if (!knifeout[id]) return PLUGIN_HANDLED
    new Float:delay = get_delay(activeType[id])
    if (tossdelay[id] > get_gametime() - delay) return PLUGIN_HANDLED
    tossdelay[id] = get_gametime()
    ammo[id]--
    show_ammo(id)

    // Play the player's grenade-throw animation.
    entity_set_int(id, EV_INT_sequence, 57)
    entity_set_float(id, EV_FL_frame, 0.0)

    new Float:origin[3], Float:velocity[3], Float:angle[3]
    entity_get_vector(id, EV_VEC_origin, origin)
    entity_get_vector(id, EV_VEC_v_angle, angle)
    new ent = create_entity("info_target")
    if (!ent) return PLUGIN_HANDLED
    entity_set_string(ent, EV_SZ_classname, "ranged_projectile")
    new model[64]
    get_projectile_model(activeType[id], model, charsmax(model))
    entity_set_model(ent, model)
    new Float:mins[3] = {-1.0, -7.0, -1.0}, Float:maxs[3] = {1.0, 7.0, 1.0}
    entity_set_vector(ent, EV_VEC_mins, mins); entity_set_vector(ent, EV_VEC_maxs, maxs)
    angle[0] -= 90.0
    entity_set_origin(ent, origin); entity_set_vector(ent, EV_VEC_angles, angle)
    entity_set_int(ent, EV_INT_effects, 2)
    entity_set_int(ent, EV_INT_solid, 1)
    // Preserve native shuriken bouncing. Chakram is a custom gravity-free projectile.
    entity_set_int(ent, EV_INT_movetype, activeType[id] == RW_SHURIKEN ? MOVETYPE_BOUNCE : (activeType[id] == RW_CHAKRAM ? MOVETYPE_FLY : MOVETYPE_TOSS))
    if (activeType[id] == RW_CHAKRAM)
        entity_set_float(ent, EV_FL_gravity, 0.0)
    entity_set_edict(ent, EV_ENT_owner, id)
    entity_set_int(ent, EV_INT_iuser1, activeType[id])
    entity_set_int(ent, EV_INT_iuser2, 0)
    entity_set_int(ent, EV_INT_iuser3, 0)
    if (activeType[id] == RW_CHAKRAM) {
        for (new victim=1; victim<=32; victim++) {
            g_chakramHit[ent][victim]=0.0
            g_chakramHits[ent][victim]=0
        }
    }
    VelocityByAim(id, get_force(activeType[id]), velocity)
    entity_set_vector(ent, EV_VEC_velocity, velocity)
    start_airborne_sound(ent)
    if (activeType[id] == RW_SHURIKEN) {
        entity_set_vector(ent, EV_VEC_vuser1, velocity)
        entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01)
    } else if (activeType[id] == RW_CHAKRAM) {
        new Float:dir[3], Float:len=floatsqroot(velocity[0]*velocity[0]+velocity[1]*velocity[1]+velocity[2]*velocity[2])
        if(len<1.0) len=1.0
        dir[0]=velocity[0]/len; dir[1]=velocity[1]/len; dir[2]=velocity[2]/len
        entity_set_int(ent,EV_INT_iuser2,CHAKRAM_OUT); entity_set_vector(ent,EV_VEC_vuser1,dir); entity_set_vector(ent,EV_VEC_vuser2,origin); entity_set_vector(ent,EV_VEC_vuser3,velocity)
        entity_set_float(ent,EV_FL_nextthink,get_gametime()+0.05); tossdelay[id]=get_gametime()+5.0
    }
    return PLUGIN_HANDLED
}
public track_chakram(ent)
{
    if (!is_valid_ent(ent) || entity_get_int(ent, EV_INT_iuser1) != RW_CHAKRAM) return
    new st=entity_get_int(ent,EV_INT_iuser2), owner=entity_get_edict(ent,EV_ENT_owner)
    if (st==CHAKRAM_WALL || st==CHAKRAM_WALL_AUTO || st==CHAKRAM_LOST) return

    new Float:o[3],Float:v[3],Float:d[3],Float:base[3]
    entity_get_vector(ent,EV_VEC_origin,o)
    entity_get_vector(ent,EV_VEC_velocity,v)
    entity_get_vector(ent,EV_VEC_vuser1,d)
    entity_get_vector(ent,EV_VEC_vuser2,base)

    new Float:maxSpeed=float(get_cvar_num("amx_chakram_speed"))
    if (maxSpeed < 100.0) maxSpeed = 100.0
    new Float:range=float(get_cvar_num("amx_chakram_range"))
    if (range < 100.0) range = 100.0

    if (st==CHAKRAM_OUT) {
        new Float:x=o[0]-base[0],Float:y=o[1]-base[1],Float:z=o[2]-base[2]
        new Float:dist=floatsqroot(x*x+y*y+z*z)
        if (dist >= range) {
            // Turn around slowly, then accelerate smoothly back to full speed.
            entity_set_vector(ent, EV_VEC_vuser2, o)
            new Float:sp=maxSpeed*0.35
            v[0]=-d[0]*sp; v[1]=-d[1]*sp; v[2]=-d[2]*sp
            entity_set_vector(ent,EV_VEC_velocity,v)
            entity_set_int(ent,EV_INT_iuser2,CHAKRAM_AUTO)
        } else {
            // Fast outbound travel fades down as it approaches its turnaround range.
            new Float:factor=1.0
            if (dist > range*0.70) {
                factor=1.0-0.65*((dist-range*0.70)/(range*0.30))
            }
            new Float:sp=maxSpeed*factor
            v[0]=d[0]*sp; v[1]=d[1]*sp; v[2]=d[2]*sp
            entity_set_vector(ent,EV_VEC_velocity,v)
        }
    } else if (st==CHAKRAM_AUTO) {
        // Fixed reverse direction: no homing. Accelerate from 35% to 100%
        // over the first quarter of the original configured travel range.
        new Float:x=o[0]-base[0],Float:y=o[1]-base[1],Float:z=o[2]-base[2]
        new Float:travel=floatsqroot(x*x+y*y+z*z)
        new Float:factor=travel/(range*0.25)
        if (factor > 1.0) factor=1.0
        if (factor < 0.0) factor=0.0
        new Float:sp=maxSpeed*(0.35+0.65*factor)
        v[0]=-d[0]*sp; v[1]=-d[1]*sp; v[2]=-d[2]*sp
        entity_set_vector(ent,EV_VEC_velocity,v)

        // Catch is based on the owner's actual position; the projectile itself
        // never steers toward the owner.
        if (is_user_alive(owner)) {
            new Float:catchOrigin[3]
            entity_get_vector(owner,EV_VEC_origin,catchOrigin)
            new Float:cx=o[0]-catchOrigin[0],Float:cy=o[1]-catchOrigin[1],Float:cz=o[2]-catchOrigin[2]
            if (cx*cx+cy*cy+cz*cz < 67.0*67.0) {
                ammo[owner]=1; tossdelay[owner]=get_gametime()+5.0; show_ammo(owner)
                emit_sound(owner,CHAN_ITEM,"weapons/knife_deploy1.wav",1.0,ATTN_NORM,0,PITCH_NORM)
                stop_airborne_sound(ent); remove_entity(ent); return
            }
        }
    } else if (st==CHAKRAM_RECALL) {
        // Recall direction and destination are locked at the instant recall begins.
        // Speed starts reduced and accelerates toward full speed along that path.
        new Float:target[3]
        target[0]=base[0]; target[1]=base[1]; target[2]=base[2]
        new Float:remaining[3]
        remaining[0]=target[0]-o[0]; remaining[1]=target[1]-o[1]; remaining[2]=target[2]-o[2]
        new Float:remain=floatsqroot(remaining[0]*remaining[0]+remaining[1]*remaining[1]+remaining[2]*remaining[2])
        new Float:initial=entity_get_float(ent,EV_FL_fuser1)
        if (initial < 1.0) initial=remain
        new Float:progress=(initial-remain)/initial
        if (progress < 0.0) progress=0.0
        if (progress > 1.0) progress=1.0
        new Float:sp=maxSpeed*(0.35+0.65*progress)
        new Float:dirLen=floatsqroot(d[0]*d[0]+d[1]*d[1]+d[2]*d[2])
        if (dirLen > 0.001) {
            v[0]=d[0]/dirLen*sp; v[1]=d[1]/dirLen*sp; v[2]=d[2]/dirLen*sp
            entity_set_vector(ent,EV_VEC_velocity,v)
        }
        if (is_user_alive(owner)) {
            new Float:playerOrigin[3]
            entity_get_vector(owner,EV_VEC_origin,playerOrigin)
            new Float:px=o[0]-playerOrigin[0],Float:py=o[1]-playerOrigin[1],Float:pz=o[2]-playerOrigin[2]
            if (px*px+py*py+pz*pz < 167.0*167.0) {
                ammo[owner]=1; tossdelay[owner]=get_gametime()+5.0; show_ammo(owner)
                emit_sound(owner,CHAN_ITEM,"weapons/knife_deploy1.wav",1.0,ATTN_NORM,0,PITCH_NORM)
                stop_airborne_sound(ent); remove_entity(ent); return
            }
        }
    }

    // The chakram alone ignores gravity, including on manual recall.
    entity_set_float(ent,EV_FL_gravity,0.0)
    entity_set_vector(ent,EV_VEC_vuser3,v)
    entity_set_float(ent,EV_FL_nextthink,get_gametime()+0.05)
}

public track_shuriken_velocity(ent)
{
    if (!is_valid_ent(ent)) return
    if (entity_get_int(ent, EV_INT_iuser1) == RW_CHAKRAM) { track_chakram(ent); return; }
    if (entity_get_int(ent, EV_INT_iuser1) != RW_SHURIKEN) return
    if (entity_get_int(ent, EV_INT_movetype) == MOVETYPE_NONE) return

    // Keep native gravity and grenade-style bouncing; only correct the
    // post-bounce velocity when the engine produces a near-zero component.
    new Float:velocity[3], Float:previous[3]
    entity_get_vector(ent, EV_VEC_velocity, velocity)
    entity_get_vector(ent, EV_VEC_vuser1, previous)

    if (entity_get_int(ent, EV_INT_iuser4) == 1) {
        new Float:speed = floatsqroot(velocity[0]*velocity[0] + velocity[1]*velocity[1] + velocity[2]*velocity[2])
        if (speed > 1.0) {
            new Float:ax = floatabs(velocity[0]), Float:ay = floatabs(velocity[1]), Float:az = floatabs(velocity[2])

            // If the shuriken was travelling downward and the engine failed
            // to reflect it off the floor, restore an upward component.
            // Do not flatten the Z component on X/Y snaps: that caused it to
            // keep sliding/bouncing inside the floor instead of rising away.
            if (previous[2] < -20.0 && floatabs(velocity[2]) < 35.0) {
                velocity[2] = floatabs(previous[2]) * 0.80
            }

            // Assist only when the post-collision direction is already close
            // to an axis. Preserve deliberate off-axis throws and preserve Z
            // during horizontal-axis correction so ground bounces still work.
            new Float:adjustedSpeed = floatsqroot(velocity[0]*velocity[0] + velocity[1]*velocity[1] + velocity[2]*velocity[2])
            if (adjustedSpeed > 1.0) {
                ax = floatabs(velocity[0]); ay = floatabs(velocity[1]); az = floatabs(velocity[2])
                if (ax >= ay && ax >= az && ax > adjustedSpeed * 0.97) {
                    velocity[1] = 0.0
                } else if (ay >= ax && ay >= az && ay > adjustedSpeed * 0.97) {
                    velocity[0] = 0.0
                } else if (az >= ax && az >= ay && az > adjustedSpeed * 0.97) {
                    velocity[0] = 0.0
                    velocity[1] = 0.0
                }
            }
            entity_set_vector(ent, EV_VEC_velocity, velocity)
        }
        entity_set_int(ent, EV_INT_iuser4, 0)
    }

    // Save current flight velocity for the next collision correction.
    entity_set_vector(ent, EV_VEC_vuser1, velocity)
    entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.05)
}

public admin_tknife(id,level,cid){
	
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new authid[35],name[32]
	get_user_authid(id,authid,34)
	get_user_name(id,name,31)

	if(get_cvar_num("amx_throwknives") == 0){
		set_cvar_num("amx_throwknives",1)
		client_print(0,print_chat,"[AMXX] Admin has enabled throwing knives")
		console_print(id,"[AMXX] You have enabled throwing knives")
		log_amx("Admin: ^"%s<%d><%s><>^" enabled throwing knives",name,get_user_userid(id),authid)
	}
	else {
		set_cvar_num("amx_throwknives",0)
		client_print(0,print_chat,"[AMXX] Admin has disabled throwing knives")
		console_print(id,"[AMXX] You have disabled throwing knives")
		log_amx("Admin: ^"%s<%d><%s><>^" disabled throwing knives",name,get_user_userid(id),authid)
	}
	return PLUGIN_HANDLED
}


public knife_help(id)
{
	new len = 1024
	new buffer[1025]
	new n = 0

#if !defined NO_STEAM
	n += copy(buffer[n],len-n,"<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><body><pre>")
#endif

	n += copy( buffer[n],len-n,"To use your knives have to bind a key to:^n^n throw_knife^n^n")

	n += copy( buffer[n],len-n,"In order to bind a key you must open your console and use the bind command: ^n^n")

	n += copy( buffer[n],len-n,"bind ^"key^" ^"command^" ^n^n")

	n += copy( buffer[n],len-n,"In this case the command is ^"throw_knife^".  Here are some examples:^n^n")
	n += copy( buffer[n],len-n,"    bind f throw_knife         bind MOUSE3 throw_knife^n^n")

	n += copy( buffer[n],len-n,"- If a knife is thrown, you may pick it up when it stops moving ^n")
	n += copy( buffer[n],len-n,"- Knives are FF sensitive, you can hurt your teammates if FF is on^n")
	n += copy( buffer[n],len-n,"- Your knife ammo will show in the center of your screen^n")
	n += copy( buffer[n],len-n,"- You will get credit for knife kills on the scoreboard^n^n")

	n += copy( buffer[n],len-n,"Start your knifing and Have fun!")

#if !defined NO_STEAM
	n += copy( buffer[n],len-n,"</pre></body></html>")
#endif

	show_motd(id,buffer ,"Throwing Knife Help:")
	return PLUGIN_CONTINUE
}


public plugin_init()
{
    register_plugin("Ranged Throwing Weapons", "2.4", "OpenAI")
    server_print("[Ranged] Throwing weapons v2.4 loaded (X = throw_knife)")
    register_event("ResetHUD", "new_spawn", "b")
    register_event("CurWeapon", "check_knife", "b", "1=1")
    register_event("DeathMsg", "player_death", "a")
    register_logevent("round_start", 2, "1=Round_Start")
    register_logevent("round_end", 2, "1=Round_End")
    register_think("ranged_projectile", "track_shuriken_velocity")
    register_clcmd("throw_knife", "command_knife", 0, "- throws the selected ranged weapon")
    // X is normally bound to radio2. Hook that existing command instead of rebinding clients.
    register_clcmd("radio2", "command_knife", 0, "- throw selected ranged weapon")
    register_clcmd("say /ranged", "ranged_menu")
    register_clcmd("say_team /ranged", "ranged_menu")
    register_concmd("amx_tknives", "admin_tknife", ADMIN_LEVEL_C, "- toggles ranged throwing weapons on/off")
    register_clcmd("say /knifehelp", "knife_help")
    register_clcmd("say /throwingknives", "knife_help")
    register_clcmd("say", "HandleSay")
    register_cvar("amx_throwknives", "1", FCVAR_SERVER)
    register_cvar("amx_knifeammo", "5")
    register_cvar("amx_knifetossforce", "1200")
    register_cvar("amx_maxknifeammo", "10")
    register_cvar("amx_knifedmg", "25")
    register_cvar("amx_dropknives", "1")
    register_cvar("amx_knifeautoswitch", "1")
    register_cvar("amx_tknifelog", "0")
    register_cvar("amx_chakram_range", "600")
    register_cvar("amx_chakram_speed", "1200")
    register_cvar("amx_chakram_damage", "20")
    g_vault = nvault_open("ranged_weapon_selection")
    if (g_vault == INVALID_HANDLE) set_fail_state("Could not open ranged weapon nVault")
    check_cvars()
}
// X is handled by the default radio2 command hook registered in plugin_init.

public plugin_precache()
{
    precache_sound("weapons/knife_hitwall1.wav")
    precache_sound("weapons/knife_hit4.wav")
    precache_sound("weapons/knife_deploy1.wav")
    precache_sound("weapons/knife_arena/claws_hitwall.wav")
    precache_sound("weapons/knife_arena/axe_hitwall.wav")
    precache_sound("weapons/knife_arena/katana_hitwall.wav")
    precache_sound("weapons/knife_arena/axe_stab.wav")
    precache_model("models/w_knifepack.mdl")
    precache_model("models/w_throwingknife.mdl")
    precache_model("models/w_throwing_axe.mdl")
    precache_model("models/w_throwing_shiv.mdl")
    precache_model("models/w_throwing_shuriken.mdl")
    precache_model("models/w_throwing_kunai.mdl")
    precache_model("models/w_throwing_caltrop.mdl")
    precache_model("models/w_throwing_chakram.mdl")
    precache_sound("weapons/knife_arena/scythe_hitwall.wav")
    precache_sound("weapons/knife_arena/glaive_special.wav")
}
public plugin_end()
{
    if (g_vault != INVALID_HANDLE) nvault_close(g_vault)
}
public check_cvars()
{
    if (get_cvar_num("amx_knifeammo") > get_cvar_num("amx_maxknifeammo")) {
        server_print("[AMXX] amx_knifeammo cannot exceed amx_maxknifeammo; adjusting max.")
        set_cvar_num("amx_maxknifeammo", get_cvar_num("amx_knifeammo"))
    }
    if (get_cvar_num("amx_knifedmg") < 1) set_cvar_num("amx_knifedmg", 1)
    if (get_cvar_num("amx_knifetossforce") < 200) set_cvar_num("amx_knifetossforce", 200)
}
public plugin_modules()
{
    require_module("fun")
    require_module("engine")
    require_module("nvault")
}

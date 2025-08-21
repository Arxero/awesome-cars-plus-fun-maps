#include <amxmodx>
#include <cstrike>
#include <fun>
#include <deathrun_shop>
#include <deathrun_modes>

#define PLUGIN "Deathrun Shop: Items"
#define VERSION "0.1"
#define AUTHOR "Mistrick"

#pragma semicolon 1

#define MAX_USE 3

new g_iGrenadeUsed[33];
new g_iModeDuel;
new g_bDuel;
new g_iModeInvis;
new g_bInvis;
new is_healthBought[33];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
    
    dr_shop_add_item("Health", 1000, ITEM_TEAM_T|ITEM_TEAM_CT, 0, "ShopItem_Health", "ShopItem_CanBuy_Health");
    dr_shop_add_item("Gravity", 100, ITEM_TEAM_T|ITEM_TEAM_CT, 0, "ShopItem_Gravity");
    dr_shop_add_item("Grenade HE", 100, ITEM_TEAM_CT, 0, "ShopItem_GrenadeHE", "ShopItem_CanBuy_GrenadeHE");
}
public plugin_cfg()
{
    g_iModeDuel = dr_get_mode_by_mark("duel");
    g_iModeInvis = dr_get_mode_by_mark("invis");
}
public client_putinserver(id)
{
    g_iGrenadeUsed[id] = MAX_USE;
    is_healthBought[id] = false;
}
public Event_NewRound()
{
    arrayset(g_iGrenadeUsed, MAX_USE, sizeof(g_iGrenadeUsed));
    arrayset(is_healthBought, false, sizeof(is_healthBought));
}
public dr_selected_mode(id, mode)
{
    g_bDuel = (g_iModeDuel == mode) ? true : false;
    g_bInvis = (g_iModeInvis == mode) ? true : false;
}
public ShopItem_Health(id)
{
    is_healthBought[id] = true;
    client_print(id, print_chat, "You bougth health.");
    set_user_health(id, 100);
}
public ShopItem_Gravity(id)
{
    set_user_gravity(id, 0.5);
}
public ShopItem_GrenadeHE(id)
{
    g_iGrenadeUsed[id]--;
    give_item(id, "weapon_hegrenade");
}
public ShopItem_CanBuy_Health(id)
{
    if (g_bDuel) {
        return ITEM_DISABLED;
    }

    if (g_bInvis && cs_get_user_team(id) == CS_TEAM_T) {
        return ITEM_DISABLED;
    }

    if (is_healthBought[id]) {
        return ITEM_DISABLED;
    }

    if (get_user_health(id) >= 100)
    {
        client_print(id, print_chat, "You already have 100 or more HP.");
        return ITEM_DISABLED;
    }

    return ITEM_ENABLED;
}
public ShopItem_CanBuy_GrenadeHE(id)
{
    if(g_iGrenadeUsed[id] <= 0)
    {
        dr_shop_item_addition("\r[ALL USED]");
        return ITEM_DISABLED;
    }
    new szAddition[32]; formatex(szAddition, charsmax(szAddition), "\y[Have %d]", g_iGrenadeUsed[id]);
    dr_shop_item_addition(szAddition);
    return ITEM_ENABLED;
}

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>

public plugin_init() {
    register_plugin("Remove Spawn Weapons", "1.0", "Maverick");
    RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1);
    register_logevent("event_round_end", 2 ,"1=Round_End");
}


public OnPlayerSpawn(id) {
    set_task(0.5, "restore_weps", id);
}

public restore_weps(id) {
   give_item(id,"weapon_knife");
 
   if (get_user_flags(id) & ADMIN_RESERVATION) {
        cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
        give_item(id, "weapon_hegrenade");
        give_item(id, "weapon_flashbang");
        cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
        give_item(id, "weapon_smokegrenade");
    }
} 

public event_round_end() {
    new players[32], pnum, id; 
    get_players(players, pnum);

    for (new i = 0; i < pnum; i++) {
        id = players[i];
        strip_user_weapons(id);
    }

    return PLUGIN_CONTINUE;
}

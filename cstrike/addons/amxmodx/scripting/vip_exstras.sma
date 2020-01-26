#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <cstrike>

#define VIPFLAGS ADMIN_LEVEL_F          //add here who can use that feature by flag, checkout your users.ini to se what flag are available

public plugin_init() {
	register_plugin("VIP Extras", "6.9", "HNSWeed")
	RegisterHam(Ham_Spawn, "player", "SpawnBonus", 1)
}
public SpawnBonus(const id) {
	if(is_user_alive(id)) {
		if(get_user_flags(id) & VIPFLAGS) {
			switch(get_user_team(id)) {
				case 1: {
					give_item(id, "weapon_hegrenade")
					give_item(id, "weapon_flashbang")
					give_item(id, "weapon_flashbang")
					give_item(id, "weapon_smokegrenade")
					give_item(id, "item_assaultsuit")
				}
				case 2: {
					give_item(id, "weapon_hegrenade")
					give_item(id, "weapon_flashbang")
					give_item(id, "weapon_flashbang")
					give_item(id, "weapon_smokegrenade")
					give_item(id, "item_assaultsuit")
				}
			}
                        }
		}
	}
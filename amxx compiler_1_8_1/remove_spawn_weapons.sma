#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>

public plugin_init() {
 register_plugin("Remove Spawn Weapons", "1.0", "N/A")
 RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
}


public OnPlayerSpawn(id)
{
   set_task(0.5, "strip", id)
}

public strip(id)
{
   strip_user_weapons(id)
   give_item(id,"weapon_knife")
 
   if (get_user_flags(id) & ADMIN_RESERVATION)
   {
      cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
	   give_item(id, "weapon_hegrenade")
	   give_item(id, "weapon_flashbang")
	   cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
	   give_item(id, "weapon_smokegrenade")
   }
} 

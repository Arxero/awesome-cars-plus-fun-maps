/*****************************************************************************
 *      ZM VIP 2.0.0 inlcude file
 *      Author: aaarnas
 *
 *      To make extra items, classes controlable by ZM VIP, add:
 *      #include <zm_vip>
 *      at the end of other #include's in plugin .sma file. Then compile 
 *      plugin and add to server. You don't need to change anything. Just 
 *      include this file to plugin and go on. Easy!
 *
 *****************************************************************************
 *      Geek stuf:
 *      If you writing other plugins (not items or classes) or having problem 
 *      with compability error, you can disable it (if you know what you are 
 *      doing) by adding:
 *      #define ZM_VIP_DISABLE_AUTO_CONVERT
 *      at the top of plugin.
 *      For example, if you want to include <zm_vip> to extra item plugin and
 *      won't affect it to use with zombie VIP (left for main mod), add this
 *      define to the top of plugin and plugin will remains the same and you
 *      will be able to use all <zm_vip> natives and forwards.
 ****************************************************************************/
//----------------------------------------------------------------------------
// Natives
//----------------------------------------------------------------------------
/**
 *  Returns having player VIP flags. If @return > 0 - player is VIP.
 *  @id     - player id
 *	@return - vip flags (return 0 if player not connected)
 *  For flags values check vips.ini file or zm_vip.sma at line:
 *  "enum _:player_attributes"
 *  Example for check if player has VIP model attribute:
 *  if (zv_get_user_flags(id)&AT_VIP_MODEL)
 *
 *  If player is VIP:
 *  if (zv_get_user_flags(id))
 */
native zv_get_user_flags(id)

#define ZV_DURATION_IGNORE            -1
#define ZV_DURATION_PERMANENT         0
#define ZV_DURATION_TILL_DISCONNECT   ~'t'
#define ZV_DURATION_TILL_MAP          ~('t'|'m')
/**
 *  Set VIP flags for player.
 *  @id       - player id, 0 - all players
 *  @duration - time (in seconds), how long player will have VIP.
 *              Can be used ZV_DURATION_ constants.
 *  @flags    - flags, what attributes VIP player will have.
 *              All AT_ constants, or use AT_ALL for all attributes.
 *              If you want to just give a VIP status without any abbilities, use AT_NONE flag.
 *              Because VIP can't exist without any flags set, having only this dummy flag, player can
 *              remain in VIP status on the system.
 *  @return   - [true - VIP created/updated succesfully,
 *              false - used ZV_DURATION_IGNORE for player, that doesn't have VIP
 *                      or player is not connected to server]
 *
 *  NOTE: if id = 0, always returns true.
 *  Examples:
 *	If you want to set a new VIP:
 *      //player will get VIP privilegies for 2 days and only multijump and armor abbilities
 *      zv_set_user_flags(id, 60*60*24*2, AT_MULTIJUMP|AT_ARMOR)
 *      //player will get VIP all VIP privilegies for 30 days (1 month)
 *      zv_set_user_flags(id, 60*60*24*30, AT_ALL)
 *  Update existing:
 *      //update current user flags (adde extra gravity). Privilegie duration remains the same.
 *      //NOTE: if zv_set_user_flags(id, ZV_DURATION_IGNORE... will be called on player, that don't have privilegies
 *      //function will return false and no action will be taken. You need to set duration for first time.
 *      zv_set_user_flags(id, ZV_DURATION_IGNORE, zv_get_user_flags(id)|AT_EXTRA_GRAVITY)
 */
native zv_set_user_flags(id, duration, flags)

/**
 *  Remove player VIP privilegie
 *  @id          - player id, 0 - all players
 *  @return      - [true - success,
 *                  false - player not connected or doesn't have privilegies]
 *
 *  NOTE: if id = 0, always returns true.
 */
native zv_remove_user_flags(id)

/**
 *  Get count of currently existing registered VIPs
 *  @return       - VIP'S count;
 */
native zv_get_vips_num()

//----------------------------------------------------------------------------
// Attributes (Flags)
//----------------------------------------------------------------------------
#define AT_ALL                  0
#define AT_MULTIJUMP            (1<<0) // a
#define AT_ARMOR                (1<<1) // b
#define AT_UNLIMITED_CLIP       (1<<2) // c
#define AT_NO_FALL_DMG          (1<<3) // d
#define AT_DAMAGE_REWARD	(1<<4) // e
#define AT_EXTRA_DMG            (1<<5) // f
#define AT_EXTRA_HP             (1<<6) // g
#define AT_EXTRA_GRAVITY        (1<<7) // h
#define AT_EXTRA_FRAGS          (1<<8) // i
#define AT_EXTRA_KILL_AMMO      (1<<9) // j
#define AT_EXTRA_ARMOR          (1<<10) // k
#define AT_EXTRA_INFECT_AMMO    (1<<11) // l
#define AT_EXTRA_INFECT_HEALTH  (1<<12) // m
#define AT_EXTRA_ITEMS          (1<<12) // n
#define AT_VIP_MODEL            (1<<14) // o
#define AT_VIP_CLASS            (1<<15) // p
#define AT_CHATTAG              (1<<16) // q
#define AT_VIPINSCORE           (1<<17) // r
#define AT_CUSTOM_S     	(1<<18) // s
#define AT_CUSTOM_T		(1<<19) // t
#define AT_CUSTOM_U		(1<<20) // u
#define AT_CUSTOM_V		(1<<21) // v
#define AT_CUSTOM_W		(1<<22) // w
#define AT_CUSTOM_X		(1<<23) // x
#define AT_CUSTOM_Y		(1<<24) // y
#define AT_NONE                 (1<<25) // z

//////////////////////////////////////////////////////////////////////////////
///          Technical stuff, you don't need to do anything below          ///
//////////////////////////////////////////////////////////////////////////////
#pragma reqlib zm_vip
	#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib zm_vip
#endif
//Workaround for #elseif bug.
#if !(defined ZM_VIP_DISABLE_AUTO_CONVERT) && defined _zombieplague_included
	native zv_force_buy_extra_item(id, itemid, ignorecost = 0)
	native zv_get_extra_item_id(const name[])
	forward zv_extra_item_selected(id, itemid)
	native zv_register_extra_item(const name[], const description[], cost, team)
	native zv_register_extra_item2(const name[], cost, teams)
	native zv_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback)
	#define zp_force_buy_extra_item zv_force_buy_extra_item
	#define zp_get_extra_item_id zv_get_extra_item_id
	#define zp_extra_item_selected zv_extra_item_selected
	#define zp_register_extra_item zv_register_extra_item2
	#define zp_register_zombie_class zv_register_zombie_class
#endif
#if !(defined ZM_VIP_DISABLE_AUTO_CONVERT) && defined _zp50_items_included
	native zv_items_register(const name[], cost)
    #define zp_items_register zv_items_register
#endif
#if !(defined ZM_VIP_DISABLE_AUTO_CONVERT) && defined _zp50_class_zombie_included
	native zv_class_zombie_register(const name[], const description[], health, Float:speed, Float:gravity)
	#define zp_class_zombie_register zv_class_zombie_register
#endif
#if !(defined ZM_VIP_DISABLE_AUTO_CONVERT) && defined _zp50_class_human_included
	native zv_class_human_register(const name[], const description[], health, Float:speed, Float:gravity)
    #define zp_class_human_register zv_class_human_register
#endif
#if !(defined _zp50_items_included) && !(defined _zombieplague_included) && !(defined _zp50_class_zombie_included) && !(defined _zp50_class_human_included) && !(defined ZM_VIP_DISABLE_AUTO_CONVERT)
	#error "Unknown plugin type. ZM VIP can't do anything with this plugin, or #include <zm_vip> is not at the end of other includes. Plugin should be zombie/human class or extra item"
#endif
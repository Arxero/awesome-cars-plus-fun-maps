#if defined _vip_included
	#endinput
#endif
#define _vip_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib vip
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib vip
	#endif
#else
	#pragma library vip
#endif

/**
 * Checks whether a player is VIP or not
 * 
 * @param		id - Unique index of player
 * 
 * @return		True if VIP, false otherwise
 * 
 * @note		This could return false in client_connect(), client_authorized(), client_putinserver(), and client_disconnect().
 *			Use the vip_authorized(), vip_putinserver() and vip_disconnect() forwards instead.
 */
native is_user_vip(id);

/**
 * Called when a VIP player authorizes
 * 
 * @param		id - Unique index of player
 * 
 * @return		Return values are ignored
 */
forward vip_authorized(id);

/**
 * Called when a VIP player joins the server
 * 
 * @param		id - Unique index of player
 * 
 * @return		Return values are ignored
 */
forward vip_putinserver(id);

/**
 * Called when a VIP player disconnects
 * 
 * @param		id - Unique index of player
 * 
 * @return		Return values are ignored
 */
forward vip_disconnect(id);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

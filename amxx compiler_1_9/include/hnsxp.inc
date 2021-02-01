#if defined _hns_xp_included
	#endinput
#endif
#define _hns_xp_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib hns_xp
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib hns_xp
	#endif
#else
	#pragma library hns_xp
#endif

/*
 * Registers a new ability
 * 
 * @param		name - The name of the ability
 * 
 * @return		The pointer of that ability
 * 
 */
native hnsxp_register_ability(name[]);

/*
 * Registers a new item for an ability
 * 
 * @param		ability - The pointer of the ability
 * @param		name - The name of the item
 * @param		save_name - The name used to save for each client (must be unique amongst every other item for any ability and cannot be "xp")
 * @param		value_type - The type of value for this ability (eg. "%" for "32%", " HP" for "100 HP").
 * 				     This will be placed directly after the value of the item, so for example in the health, there was a space before HP.
 * @param		first_xp - The first xp to buy the first level
 * @param		xp_interval - The interval of xp between levels.
 * 				      Use a positive value for your own interval.
 * 				      Use XP_INTERVAL_NONE for the "first_xp" value as each interval.
 * 				      Use XP_INTERVAL_EXPONENTIAL for the xp to double for each level. (default)
 * @param		max_level - The maximum level for this item
 * @param		max_value - The value for this item that is used when the player has reached the maximum level
 * 
 * @return		The pointer of that item
 * 
 */

native hnsxp_register_item(const ability, const name[], const save_name[], const value_type[], const first_xp, const xp_interval, const max_level, const max_value);

/*
 * Adds a description to the ability.
 * 
 * @param		ability - The pointer of the ability
 * @param		description - The description of the ability (use multiple times for multiple lines).
 * 				      Has a character limit of 256.
 * 
 * @return		No return.
 * 
 */
native hnsxp_describe_ability(const ability, const description[]);

/*
 * Called whenever a player's level for a certain ability's item changes
 * 
 * @param		ability - The pointer of the ability
 * @param		item - The pointer of the item
 * @param		client - The player index who's level changed
 * @param		level - The level of the player's item for this ability.
 * 
 * @return		No return will change the action of this forward.
 * 
 */
forward hnsxp_update_user_level(const ability, const item, const client, const level);

/*
 * Returns a players XP points
 * 
 * @param		client - The player index to get points of
 * 
 * @return		The XP points of client
 * 
 */
native hnsxp_get_user_xp(const client);

/*
 * Sets <xp> points to client
 * 
 * @param		client - The player index to set points to
 * @param		xp - The amount of XP points to set to client
 * 
 * @return		The XP points of client
 * 
 */
native hnsxp_set_user_xp(const client, const xp);

/*
 * Returns a players XP points from a given authid
 * 
 * @param		authid - The authid of the player to get points from
 * 
 * @return		The XP points of the player
 * 
 */
native hnsxp_get_authid_xp(const authid[]);

/*
 * Sets <xp> points to client
 * 
 * @param		authid - The authid of the player to set points to
 * @param		xp - The amount of XP points to set to the player
 * 
 * @return		The XP points of the player
 * 
 */
native hnsxp_set_authid_xp(const authid[], const xp);

/*
 * Prints a message from the xp plugin
 * 
 * @param		receiver - The player index to print the message to (0 = everyone)
 * @param		message - The message to be printed (supports formatting and colorchat - ^1, ^3, ^4)
 * 
 * @return		No return.
 * 
 */
native hnsxp_print(const receiver, const message[], any:...);

#include <hnsxp_const>
#include <hnsxp_stocks>
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/

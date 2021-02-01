#if defined _agroups_included
    #endinput
#endif

#define _agroups_included

/** 
 * Gets total number of registered groups.
 *
 * @return				Number of groups.
 */
native agroups_get_groups_num()

/** 
 * Gets the number of online players in a specified group.
 * 
 * @param iGroup 		Group's index.
 * @return				-1 if the group doesn't exist, otherwise returns the number of players in the group.
 */
native agroups_get_players_in_group(group)

/** 
 * Get's the user group.
 * 
 * @param id 			Player's index.
 * @param group 		Buffer to store the group name in.
 * @param len 			Buffer length.
 * @return				-2 if the player is not connected, -1 if the player is not in a group, group's index otherwise.
 */
native agroups_get_user_group(id, group[] = "", len = 0)

/** 
 * Attempts to open the groups menu.
 * 
 * @param id 			Player's index.
 * @return				-2 if the player is not connected, 1 otherwise.
 */
native agroups_open_groups_menu(id)

/** 
 * Attempts to play the menu sound.
 * 
 * @param id 			Player's index.
 * @return				-2 if the player is not connected, 0 if the sound option is disabled, 1 otherwise.
 */
native agroups_play_menu_sound(id)

/** 
 * Updates the user's group.
 * 
 * @param id 			Player's index.
 * @return				-2 if the player is not connected, -1 if the player is not in a group, group's index otherwise.
 */
native agroups_update_user_group(id)
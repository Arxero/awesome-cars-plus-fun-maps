#if defined _becomevip_included
    #endinput
#endif

#define _becomevip_included

/** 
 * Checks whether a players has unlocked the VIP Plus option.
 * 
 * @param id			Player's index.
 * @return				True if he has, 0 if he hasn't.
 */
native bool:IsUserVip(id)

/** 
 * Gets number of kills needed to get VIP extras.
 * 
 * @return				Number of kills needed to get VIP extras.
 */
native GetKillsNeeded()

/** 
 * Gets the number of player's kills.
 * 
 * @param id			Player's index.
 * @return				Number of player's kills.
 */
native GetUserKills(id)

/** 
 * Gets the number of player's kills left.
 * 
 * @param id			Player's index.
 * @return				Number of player's kills left.
 */
native GetKillsLeft(id)

/** 
 * Gets the plugin prefix.
 * 
 * @param szPrefix		Buffer to store the prefix.
 * @param iPrefixLen	Prefix's buffer length.
 * @noreturn
 */
native GetVipPrefix(szPrefix[], iPrefixLen)

/** 
 * Gets the VIP flags that players will receive.
 * 
 * @param szFlags		Buffer to store the flags.
 * @param iFlagsLen		Flags' buffer length.
 * @noreturn
 */
native GetVipFlags(szFlags[], iFlagsLen)

/** 
 * Checks whether the plugin is using CSStats.
 * 
 * @return				True if it is, 0 if it isn't.
 */
native bool:UsingCsstats()

/** 
 * Checks whether the plugin is using HUD message.
 * 
 * @return				True if it is, 0 if it isn't.
 */
native bool:UsingHud()

/** 
 * Checks whether the plugin is using Steam.
 * 
 * @return				True if it is, 0 if it isn't.
 */
native bool:UsingSteam()

/** 
 * Checks whether the plugin is using Quick Save.
 * 
 * @return				True if it is, 0 if it isn't.
 */
native bool:UsingQuickSave()
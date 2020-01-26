#if defined _jctf_included
	#endinput
#endif

#define _jctf_included
#define _jctf_version 1.26
#pragma library jctf

/*
	These are parsed in the iEvent var of the jctf_flag() forward.
*/
enum
{
	/* Event		| Forward variables used by event	| Description of event											*/
	FLAG_STOLEN = 0,	/* iPlayer, iFlagTeam			| iPlayer got iFlagTeam's flag from their base							*/
	FLAG_PICKED,	/* iPlayer, iFlagTeam			| iPlayer picked iFlagTeam's flag from the ground						*/
	FLAG_DROPPED,	/* iPlayer, iFlagTeam			| iPlayer dropped the iFlagTeam's flag by dying, disconnecting or manually		*/
	FLAG_MANUALDROP,	/* iPlayer, iFlagTeam			| iPlayer dropped the iFlagTeam's flag manually (using /dropflag)				*/
	FLAG_RETURNED,	/* iPlayer, iFlagTeam, bAssist 	| iPlayer (bAssist ? "assisted on returning" : "returned") the iFlagTeam's flag	*/
	FLAG_CAPTURED,	/* iPlayer, iFlagTeam, bAssist	| iPlayer (bAssist ? "assisted on capturing" : "captured") the iFlagTeam's flag	*/
	FLAG_AUTORETURN,	/* iFlagTeam				| iFlagTeam's flag was automatically returned							*/
	FLAG_ADMINRETURN	/* iPlayer, iFlagTeam			| iFlagTeam's flag was returned by admin iPlayer using the command			*/
};

/**
 * This forward triggers when a team's flag changes status.
 * This forward also triggers, for example, when a flag is captured, for the
 * capturing player and also for the assisting ones, each having bAssist true/false acordingly.
 *
 * @param iEvent		The event triggered (list above)
 * @param iPlayer		Index of player
 * @param iFlagTeam	The flag's team
 * @param bool:bAssist	Is true if the iPlayer is an assisting player for iEvent, false if not.
 * @noreturn
 */
forward jctf_flag(iEvent, iPlayer, iFlagTeam, bool:bAssist);

/**
 * This native returns the player's team
 * NOTE: It doesn't check if player is actually a player, you could get plugin errors if you use it wrong.
 *
 * @param id		Index of player
 * @return			Index of team
 */
native jctf_get_team(id);

/**
 * This native returns if the player is carrying the flag
 * NOTE: It doesn't check if player is actually a player, you could get plugin errors if you use it wrong.
 *
 * @param id		Index of player
 * @return			1 if player is carying the flag, 0 otherwise
 */
native jctf_get_flagcarrier(id);

/**
 * This native returns the player's adrenaline amount.
 * NOTE: It doesn't check if player is actually a player, you could get plugin errors if you use it wrong.
 *
 * @param id		Index of player
 * @return			Amount of adrenaline player has
 */
native jctf_get_adrenaline(id);

/**
 * This native adds or substracts adrenaline from a player.
 * NOTE: This can be used to set adrenaline too, you can empty it using -100 or fill it using 100 as iAdd.
 * NOTE: It doesn't check if player is actually a player, you could get plugin errors if you use it wrong.
 *
 * @param id		Index of player
 * @param iAdd		How much adrenaline to add, can be negative to substract
 * @param szReason[]	(optional) if specified, it will print a center and console message to the player about amount received/lost
 * @noreturn
 */
native jctf_add_adrenaline(id, iAdd, szReason[] = "");

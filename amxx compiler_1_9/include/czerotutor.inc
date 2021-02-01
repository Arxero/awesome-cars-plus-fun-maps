/* AMX Mod X functions
*
* by Dark Style
*
* This file is provided as is (no warranties).
*/

#if defined _czerotutor_included
  #endinput
#endif
#define _czerotutor_included

enum
{
	NONE = 0,
	RED,
	BLUE,
	YELLOW,
	GREEN
}

/**
 * Create a tutor
 *
 * @param id		Player index.
 * @param color		Color of the text.
 * @param sound		Sound to play when display tutor.
 * @param time		Time to the tutor still alive.
 * @param input		Text to display in tutor.
 * @return			1 on success, 0 otherwise.
 */
native create_user_cztutor(id, color = GREEN, sound[] = "", Float:time = 0.0, const input[] = "");


/**
 * Remove player tutor.
 *
 * @param id		Player index.
 * @return			1 on success, 0 otherwise.
 */
native remove_user_cztutor(id);


/**
 * Check if a tutor is displaying to this player.
 *
 * @param id		Player index.
 * @return			Color of player tutor (If not exists will return NONE).
 */
native is_user_cztutor(id);

/* AMX Mod X
*   Fall Scream
*
* (c) Copyright 2006 by VEN
*
* This file is provided as is (no warranties)
*
*     REQUESTED by lastchapter
*
*     PLUGIN provides global fall scream sound
*
*     FAKEMETA module required
*
*     VERSIONS
*       0.3   - ambient entity changed to emit_sound
*               added option to set the sample time
*               sound water splash part is cutted out
*       0.2   - added "regular" fall support
*               improved custom sound support
*               improved vertigo-style maps detection
*               few optimizations
*       0.1   - first release
*/

#include <amxmodx>
#include <fakemeta>

#define PLUGIN_NAME "Fall Scream"
#define PLUGIN_VERSION "0.3"
#define PLUGIN_AUTHOR "VEN"

// OPTIONS BELOW

// comment to disable outside-map-fall scream (building, abyss, etc)
// note: that option fully independent from SCREAM_FALL_SPEED value
#define SCREAM_VERTIGO_STYLE

// player's minimal fall speed required for scream sound playback
#define SCREAM_FALL_SPEED 600

// scream sound filename, may be changed to the custom sound file
new g_sound_file[] = "ambience/fallscream.wav"

// sample playback time, useful to cut the sample, comment to disable
#define PLAYBACK_TIME 1.5

// OPTIONS ABOVE

new g_ent

#define EMIT_SCREAM emit_sound(g_ent, CHAN_STREAM, g_sound_file, VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
#define STOP_SCREAM emit_sound(g_ent, CHAN_STREAM, g_sound_file, VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM)

#define MAXPLAYERS 32
new bool:g_can_scream[MAXPLAYERS + 1]

public plugin_precache() {
	precache_sound(g_sound_file)
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	new ent = -1, message[24]
	new string_class[] = "classname"
	new entity_class[] = "ambient_generic"
	new sound_default[] = "ambience/fallscream.wav"
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, string_class, entity_class))) {
		pev(ent, pev_message, message, 23)
		if (equali(message, sound_default))
			return
	}

	register_forward(FM_PlayerPreThink, "forward_player_prethink")

#if !defined SCREAM_VERTIGO_STYLE
}

#else
	if (!engfunc(EngFunc_FindEntityByString, -1, string_class, "trigger_hurt"))
		return

	// since on de_vertigo map fall scream sound emits almost at the time when player dies
	// we disregard that insignificant delay - implementation would not worth a methods
	// v0.2 note: i tried to implement that delay and realized that there are no good ways
	register_event("DeathMsg", "event_vertigo_scream", "a", "1=0", "2!0", "4=trigger_hurt")
}

public event_vertigo_scream() {
	new id = read_data(2)
	if (g_can_scream[id])
		scream(id)
}

#endif

public forward_player_prethink(id) {
	if (!is_user_alive(id))
		return FMRES_IGNORED

	// not a typo: integer
	new fvel = pev(id, pev_flFallVelocity)

	if (g_can_scream[id]) {
		if (fvel >= SCREAM_FALL_SPEED) {
			g_can_scream[id] = false
			scream(id)
		}
	}
	else if (!fvel)
		g_can_scream[id] = true

	return FMRES_IGNORED
}

scream(id) {
	if (g_ent) {
#if defined PLAYBACK_TIME
		remove_task(g_ent)
#endif
		STOP_SCREAM
	}

	g_ent = id
	EMIT_SCREAM

#if !defined PLAYBACK_TIME
}
#else
	set_task(PLAYBACK_TIME, "task_cut_sample", g_ent)
}

public task_cut_sample() {
	STOP_SCREAM
	g_ent = 0
}
#endif

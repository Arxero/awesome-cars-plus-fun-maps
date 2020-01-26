/*****************************************************************************************
 *
 *	plugin_trail.sma
 *
 *	By Bahrmanou (amiga5707@hotmail.com)
 *
 *****************************************************************************************/
/*****************************************************************************************
 If some map cause problem (crash the server) because of too much precaches, create a file
 in your AmxModx configs folder named 'sensiblemaps.cfg' and add the map name (WITHOUT the
 extension '.bsp') in that file.
 So if the map is in the list, the plugin prevents trail sprites to be precached (i.e. the
 trails are DISABLED for this map.
 *****************************************************************************************/
#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGNAME		"plugin_trail"
#define VERSION			"1.3.1"
#define AUTHOR			"Bahrmanou"

#define ACCESS_LEVEL		ADMIN_RESERVATION
#define ACCESS_ADMIN		ADMIN_ADMIN

#define MAX_TEXT_LENGTH		200
#define MAX_NAME_LENGTH		40
#define MAX_PLAYERS		32
#define MAX_DISTANCE		300

#define CFG_FILE		"colors.cfg"
#define MAX_COLORS		200

#define DEF_TRAIL_LIFE		2

#define TASKID			1337	// change if it interfere with another plugin!
#define TICK			0.1

#define NUM_SPRITES		29

new bool:gl_parsed
new bool:gl_trail
new bool:gl_not_this_map

new gl_trail_life
new gl_trail_size[MAX_PLAYERS]
new gl_trail_brightness[MAX_PLAYERS]
new gl_trail_type[MAX_PLAYERS]

new gl_sprite_name[NUM_SPRITES][] = {
	"sprites/laserbeam.spr",
	"sprites/blueflare1.spr",
	"sprites/dot.spr",
	"sprites/flare5.spr",
	"sprites/flare6.spr",
	"sprites/plasma.spr",
	"sprites/smoke.spr",
	"sprites/xbeam5.spr",
	"sprites/xenobeam.spr",
	"sprites/xssmke1.spr",
	"sprites/zbeam3.spr",
	"sprites/zbeam2.spr",
	"sprites/trails/minecraft.spr",
	"sprites/trails/def_T.spr",
	"sprites/trails/love.spr",
	"sprites/trails/hp.spr",
	"sprites/trails/Biohazard.spr",
	"sprites/trails/CT.spr",
	"sprites/trails/lightning.spr",
	"sprites/trails/letters.spr",
	"sprites/trails/ice.spr",
	"sprites/trails/box.spr",
	"sprites/trails/zik.spr",
	"sprites/trails/vselennaya.spr",
	"sprites/trails/tok.spr",
	"sprites/trails/zet.spr",
	"sprites/trails/snow_white.spr",
	"sprites/trails/Shar.spr",
	"sprites/trails/present.spr"
}
new gl_sprite[NUM_SPRITES]
new gl_def_sprite_size[NUM_SPRITES] = {
	5, 12, 4, 16, 16, 6, 9, 4, 15, 14, 15, 20, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
}
new gl_def_sprite_brightness[NUM_SPRITES] = {
	160, 255, 200, 255, 255, 230, 150, 150, 240, 220, 200, 200, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160
}
	
new gl_players[MAX_PLAYERS]

new gl_player_position[MAX_PLAYERS][3]
new gl_timer_count[MAX_PLAYERS]
new gl_timer_limit

new gl_player_colors[MAX_PLAYERS][3]
new gl_color_names[MAX_COLORS][MAX_NAME_LENGTH]
new gl_colors[MAX_COLORS][3]
new gl_num_colors

public plugin_init() {
	register_plugin(PLUGNAME, VERSION, AUTHOR)
	register_concmd("amx_trail","cmdTrail", ACCESS_LEVEL,  "- ['on'|'off'|'1'|'0'] : enable/disable trails.")
	register_concmd("amx_trail_user","cmdUserTrail", ACCESS_LEVEL,  "- <name or #userid> <colorname | 'random' | 'off'> : set user trail.")
	register_concmd("amx_trail_type", "cmdTrailType", ACCESS_LEVEL, "- <type> : set trail type for all players.")
	register_concmd("amx_trail_life","cmdTrailLife", ACCESS_LEVEL,  "- [duration] : get/set trail duration, in seconds.")
	register_concmd("amx_trail_size","cmdTrailSize", ACCESS_LEVEL,  "- [size] : get/set trail size.")
	register_concmd("amx_trail_brightness","cmdTrailBrightness", ACCESS_LEVEL,  "- [brightness] : get/set trail brightness.")
	register_concmd("amx_trail_reload", "cmdReload", ACCESS_LEVEL, ": reload colors configuration file.")
	register_clcmd("say", "SayCmd", 0, "")
	
	gl_parsed = gl_trail = parse_file()
	if (!gl_sprite[0]) gl_trail = false

	gl_trail_life = DEF_TRAIL_LIFE
	gl_timer_limit = floatround(float(gl_trail_life)/TICK)
}

public plugin_modules() {
	require_module("engine")
}

public plugin_precache() {
	if (check_map()) {
		gl_not_this_map = true
		return
	}

	for (new i=0; i<NUM_SPRITES; i++) {
		gl_sprite[i] = precache_model(gl_sprite_name[i])
	}
}

public client_putinserver(id) {
	gl_trail_type[id] = gl_sprite[0]
	gl_trail_size[id] = gl_def_sprite_size[0]
	gl_trail_brightness[id] = gl_def_sprite_brightness[0]
}

public client_disconnect(id) {
	if (task_exists(TASKID+id)) remove_task(TASKID+id)
	gl_player_colors[id][0] = gl_player_colors[id][1] = gl_player_colors[id][2] = 0
}

/*****************************************************************************************
 *
 *	cmdTrail ['on'|'off'|'1'|'0'] : enable/disable trails.
 *
 *****************************************************************************************/
public cmdTrail(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED
	
	if (!gl_parsed) {
		console_print(id, "Trails are OFF because I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new str[5]
	read_argv(1, str, 4)
	if (equali(str, "on") || equali(str, "1")) {
		if (gl_trail) {
			console_print(id, "Trails are already enabled.")
		} else {
			gl_trail = true
			console_print(id, "Trails are now ENABLED.")
		}
	} else if (equali(str, "off") || equali(str, "0")) {
		if (!gl_trail) {
			console_print(id, "Trails are already disabled.")
		}else {
			gl_trail = false
			new playercount
			get_players(gl_players, playercount)
			for (new i=0; i<playercount; i++) {
				kill_trail_task(gl_players[i])
			}
			say_to_all("Your trail has been removed.", id)
			console_print(id, "Trails are now DISABLED.")
		}
	} else {
		if (gl_trail) {
			console_print(id, "Trails are ENABLED.")
		} else {
			console_print(id, "Trails are DISABLED.")
		}
	}
	
	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdUserTrail <name or #userid> <colorname | 'random' | 'off'> : set user trail.
 *
 *****************************************************************************************/
public cmdUserTrail(id, level, cid) {
	if (!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED

	if (!gl_parsed) {
		console_print(id, "Trails are OFF because I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new user[MAX_NAME_LENGTH+1], colorname[MAX_NAME_LENGTH]
	new plName[MAX_NAME_LENGTH+1]

	read_argv(1, user, MAX_NAME_LENGTH)
	read_argv(2, colorname, MAX_NAME_LENGTH-1)

	new player = cmd_target(id, user, 6)
	if (!player) {
		console_print(id, "Unknown player: %s", user)
		return PLUGIN_HANDLED
	}
	get_user_name(player, plName, MAX_NAME_LENGTH)
	if (access(player, ADMIN_IMMUNITY) && id!=player) {
		console_print(id, "You cannot do that to %s, you silly bear!", plName)
		return PLUGIN_HANDLED
	}
	if (!is_user_alive(player)) {
		console_print(id, "Only alive players, please!")
		return PLUGIN_HANDLED
	}

	if (equali(colorname, "off")) {
		if (!gl_player_colors[player][0] && !gl_player_colors[player][1] && !gl_player_colors[player][2]) {
			console_print(id, "The %s's trail is already off!", plName)
			return PLUGIN_HANDLED
		}
		kill_trail_task(player)
		console_print(id, "The %s's trail has been removed.", plName)
		client_print(player, print_chat, "Your trail has been removed.")
	} else if (equali(colorname, "random")) {
		do_trail(player, "", "")
		console_print(id, "%s has now a random color trail.", plName)
	} else {
		do_trail(player, colorname, "")
		console_print(id, "%s has now a %s trail.", plName, colorname)
	}

	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdTrailType <type> : set trail type (sprite) for all players
 *
 *****************************************************************************************/
public cmdTrailType(id, level, cid) {
	if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED
	
	if (!gl_parsed) {
		console_print(id, "Trails are OFF becaus I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new str[5], type
	read_argv(1, str, 4)
	type = str_to_num(str)
	if (type<1 || type>NUM_SPRITES) {
		console_print(id, "Type must be in [1,%d] range!", NUM_SPRITES)
		return PLUGIN_HANDLED
	}
	for (new i=0; i<MAX_PLAYERS; i++) {
		gl_trail_type[i] = gl_sprite[type-1]
		gl_trail_size[i] = gl_def_sprite_size[type-1]
		gl_trail_brightness[i] = gl_def_sprite_brightness[type-1]
	}
	restart_player_trail(id)
	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdTrailLife [duration] : get/set trail duration, in seconds.
 *
 *****************************************************************************************/
public cmdTrailLife(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

	if (!gl_parsed) {
		console_print(id, "Trails are OFF because I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new Str[3], life
	
	read_argv(1, Str, 2)
	if (!Str[0]) {
		console_print(id, "Trail life is currently %d seconds.", gl_trail_life)
		return PLUGIN_HANDLED
	}
	life = str_to_num(Str)
	if (life<1 || life>30) {
		console_print(id, "Trail life must be in [1,30] range!")
		return PLUGIN_HANDLED
	}
	gl_trail_life = life
	gl_timer_limit = floatround(float(life)/TICK)
	restart_players_trails()
	
	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdTrailSize [size] : get/set trail size.
 *
 *****************************************************************************************/
public cmdTrailSize(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

	if (!gl_parsed) {
		console_print(id, "Trails are OFF because I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new Str[3], size
	
	read_argv(1, Str, 2)
	if (!Str[0]) {
		console_print(id, "Your trail size is currently %d.", gl_trail_size[id])
		return PLUGIN_HANDLED
	}
	size = str_to_num(Str)
	if (size<1) {
		console_print(id, "Trail size must be positive!")
		return PLUGIN_HANDLED
	}
	gl_trail_size[id] = size
	restart_player_trail(id)

	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdTrailBrightness [brightness] : get/set trail brightness.
 *
 *****************************************************************************************/
public cmdTrailBrightness(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

	if (!gl_parsed) {
		console_print(id, "Trails are OFF because I couldn't read the config file '%s'!", CFG_FILE)
		return PLUGIN_HANDLED
	}
	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	new Str[3], bright
	
	read_argv(1, Str, 3)
	if (!Str[0]) {
		console_print(id, "Your trail brightness is currently %d.", gl_trail_brightness[id])
		return PLUGIN_HANDLED
	}
	bright = str_to_num(Str)
	if (bright<1 || bright>255) {
		console_print(id, "Brightness must be in [1,255] range!")
		return PLUGIN_HANDLED
	}
	gl_trail_brightness[id] = bright
	restart_player_trail(id)

	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	cmdReload : reload configuration file.
 *
 *****************************************************************************************/
public cmdReload(id, level, cid) {
	if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED

	if (gl_not_this_map) {
		console_print(id, "Trails are disabled for this map!")
		return PLUGIN_HANDLED
	}

	gl_parsed = parse_file()
	
	if (gl_parsed) {
		console_print(id, "Ok, configuration file successfuly reloaded.")
	} else {
		console_print(id, "Uh Oh...There was a problem! Please check your amx log file to know whats causing this.")
	}
	return PLUGIN_HANDLED
}

/*****************************************************************************************
 *
 *	sayCmd : say trail <[['light'|'dark'] colorname] | ['random'] | ['off'] | ['help']>
 *
 *****************************************************************************************/
public SayCmd(id, level, cid) {
	new args[128], msg[200], plName[MAX_NAME_LENGTH], colname[MAX_NAME_LENGTH], arg2[MAX_NAME_LENGTH], arg3[MAX_NAME_LENGTH], typenum
	
	read_args(args, 128)
	remove_quotes(args)

	if (equali(args, "trail", 5)) {
		if (!gl_trail) {
			client_print(id, print_chat, "Trails have been disabled.")
			return PLUGIN_HANDLED
		}
		if (gl_not_this_map) {
			client_print(id, print_chat, "Trails have been disabled for this map.")
			return PLUGIN_HANDLED
		}

		get_user_name(id, plName, MAX_NAME_LENGTH)
		if (!get_user_team(id) && !access(id, ADMIN_ADMIN)) {
			client_print(id, print_chat, "You must be playing!")
			return PLUGIN_HANDLED
		}
		
		if (!args[5]) {
			do_trail(id, "", "")
			return PLUGIN_HANDLED
		} else {
			parse(args[6], colname, MAX_NAME_LENGTH, arg2, MAX_NAME_LENGTH, arg3, MAX_NAME_LENGTH)
//			console_print(id, "restline = '%s'", restline)
			typenum = str_to_num(colname)
		}
		
		if (equali(colname, "off")) {
			if (!gl_player_colors[id][0] && !gl_player_colors[id][1] && !gl_player_colors[id][2]) {
				client_print(id, print_chat, "Your trail is already off!")
				return PLUGIN_HANDLED
			}
			kill_trail_task(id)
			client_print(id, print_chat, "Your trail was removed.")
			format(msg, 199, "%s's trail was removed.", plName)
			say_to_all(msg, id)
			return PLUGIN_HANDLED
		} else if (equali(colname, "random")) {
			do_trail(id, "", "")
			return PLUGIN_HANDLED
		} else if (equali(colname, "help")) {
			trail_help(id)
			return PLUGIN_HANDLED
		}
		
		if (typenum) {
			if (typenum<1 || typenum>NUM_SPRITES) {
				client_print(id, print_chat, "Type must be in the range [1,%d].", NUM_SPRITES)
				return PLUGIN_HANDLED
			}
			typenum--
			gl_trail_type[id] = gl_sprite[typenum]
			gl_trail_size[id] = gl_def_sprite_size[typenum]
			gl_trail_brightness[id] = gl_def_sprite_brightness[typenum]
			if (arg2[0]) {
				colname = arg2
				arg2 = arg3
			} else {
				if (!gl_player_colors[id][0] && !gl_player_colors[id][1] && !gl_player_colors[id][2]) {
					do_trail(id, "", "")
					return PLUGIN_HANDLED
				}
				new r = gl_player_colors[id][0]
				new g = gl_player_colors[id][1]
				new b = gl_player_colors[id][2]
				kill_trail_task(id)
				gl_player_colors[id][0] = r
				gl_player_colors[id][1] = g
				gl_player_colors[id][2] = b
				get_user_origin(id, gl_player_position[id])
				set_task(TICK, "check_position", TASKID+id, "", 0, "b")
				trail_msg(id)
				client_print(id, print_chat, "You have a trail of type %d.", typenum+1)
				format(msg, 199, "%s has a type %d trail.", plName, typenum+1)
				say_to_all(msg, id)
				return PLUGIN_HANDLED
			}
		}
		
		if (equali(colname, "dark")) {
			copy(colname, MAX_NAME_LENGTH-1, arg2)
			if (!colname[0]) {
				client_print(id, print_chat, "Specify a color name!")
				return PLUGIN_HANDLED
			}
			do_trail(id, colname, "dark")
		} else if (equali(colname, "light")) {
			copy(colname, MAX_NAME_LENGTH-1, arg2)
			if (!colname[0]) {
				client_print(id, print_chat, "Specify a color name!")
				return PLUGIN_HANDLED
			}
			do_trail(id, colname, "light")
		} 
		else {
			do_trail(id, colname, "")
		}
	}
	return PLUGIN_CONTINUE
}

/*****************************************************************************************
 *****************************************************************************************/
do_trail(id, colname[], intensity[]) {
	new i, msg[200]
	new name[33]
	
	get_user_name(id, name, 32)
	if (!colname[0]) {
		kill_trail_task(id)
		gl_player_colors[id][0] = random(256)
		gl_player_colors[id][1] = random(256)
		gl_player_colors[id][2] = random(256)
		get_user_origin(id, gl_player_position[id])
		set_task(TICK, "check_position", TASKID+id, "", 0, "b")
		trail_msg(id)
		client_print(id, print_chat, "You have a random color trail.")
		format(msg, 199, "%s has a random color trail.", name)
		say_to_all(msg, id)
		return
	}
	for (i=0; i<gl_num_colors; i++) {
		if (equali(colname, gl_color_names[i])) {
			new Float:intens, r, g, b
			if (equali(intensity, "dark")) {
				intens = 0.5
			} else if (equali(intensity, "light")) {
				intens = 2.0
			} else {
				copy(intensity, 1, "")
				intens = 1.0
			}
			kill_trail_task(id)
			r = floatround(float(gl_colors[i][0]) * intens)
			g = floatround(float(gl_colors[i][1]) * intens)
			b = floatround(float(gl_colors[i][2]) * intens)
			gl_player_colors[id][0] = min(r, 255)
			gl_player_colors[id][1] = min(g, 255)
			gl_player_colors[id][2] = min(b, 255)
			get_user_origin(id, gl_player_position[id])
			set_task(TICK, "check_position", TASKID+id, "", 0, "b")
			trail_msg(id)
			if (intensity[0]) {
				client_print(id, print_chat, "You have a %s %s trail.", intensity, colname)
				format(msg, 199, "%s has now a %s %s trail.", name, intensity, colname)
			} else {
				client_print(id, print_chat, "You have a %s trail.", colname)
				format(msg, 199, "%s has now a %s trail.", name, colname)
			}
			say_to_all(msg, id)
			return
		}
	}
	client_print(id, print_chat, "Sorry, %s, but I dont recognize the color '%s'!", name, colname)
	return
}

/*****************************************************************************************
 *****************************************************************************************/
public check_position(taskid) {
	new origin[3], id = taskid-TASKID
		
	if (!get_user_team(id)) {
		kill_trail_msg(id)
		return
	}

	get_user_origin(id, origin)
	if (origin[0]!=gl_player_position[id][0] || origin[1]!=gl_player_position[id][1] || origin[2]!=gl_player_position[id][2]) {
		if (get_distance(origin, gl_player_position[id])>MAX_DISTANCE || gl_timer_count[id] >= gl_timer_limit/2) {
			kill_trail_msg(id)
			trail_msg(id)
		}
		gl_player_position[id][0] = origin[0]
		gl_player_position[id][1] = origin[1]
		gl_player_position[id][2] = origin[2]
		gl_timer_count[id] = 0
	} else {
		if (gl_timer_count[id] < gl_timer_limit) gl_timer_count[id]++
	}
}

/*****************************************************************************************
 *****************************************************************************************/
kill_trail_task(id) {
	if (task_exists(TASKID+id)) remove_task(TASKID+id)
	kill_trail_msg(id)
	gl_player_colors[id][0] = gl_player_colors[id][1] = gl_player_colors[id][2] = 0
}

/*****************************************************************************************
 *****************************************************************************************/
kill_trail_msg(id) {
	gl_timer_count[id] = 0

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)	// TE_KILLBEAM
	write_short(id)
	message_end()
}

/*****************************************************************************************
 *****************************************************************************************/
trail_msg(id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)	// TE_BEAMFOLLOW
	write_short(id)
	write_short(gl_trail_type[id])
	write_byte(gl_trail_life*10)
	write_byte(gl_trail_size[id])
	write_byte(gl_player_colors[id][0])
	write_byte(gl_player_colors[id][1])
	write_byte(gl_player_colors[id][2])
	write_byte(gl_trail_brightness[id])
	message_end()

}

/*****************************************************************************************
 *****************************************************************************************/
restart_player_trail(id) {
	if (task_exists(TASKID+id)) {
		remove_task(TASKID+id)
		kill_trail_msg(id)
		get_user_origin(id, gl_player_position[id])
		set_task(TICK, "check_position", TASKID+id, "", 0, "b")
		trail_msg(id)
	}
}

/*****************************************************************************************
 *****************************************************************************************/
restart_players_trails() {
	new playercount
	
	get_players(gl_players, playercount)
	for (new i=0; i<playercount; i++) {
		restart_player_trail(gl_players[i])
	}
}

/*****************************************************************************************
 *****************************************************************************************/
say_to_all(msg[], id) {
	new playercount
	
	get_players(gl_players, playercount)
	for (new i=0; i<playercount; i++) {
		if (gl_players[i]!=id) client_print(gl_players[i], print_chat, msg)
	}
}

/*****************************************************************************************
 *****************************************************************************************/
trail_help(id) {
	new msg[200], clen=0
			
	console_print(id, "^nTrail Colors List:^n")
	for (new i=0; i<gl_num_colors; i++) {
		clen += format(msg[clen], 199-clen, "%s ", gl_color_names[i])
		if (clen > 80) {
			console_print(id, msg)
			copy(msg, 1, "")
			clen = 0
		}
	}
	console_print(id, "^nNOTE: All colors can be prefixed by the words 'light' or 'dark'.^n")
	console_print(id, "^nSay 'trail <color>' to get a colored trail.^nSay 'trail off' to turn trail off.")
	console_print(id, "Say 'trail <number> [color]' to change the look of the trail.^n")
	console_print(id, "^nExamples:")
	console_print(id, "    trail")
	console_print(id, "    trail off")
	console_print(id, "    trail tomato")
	console_print(id, "    trail 6 gold")
	console_print(id, "    trail 11 light blue")
	client_print(id, print_chat, "The colors list has been displayed in your console.")
}

/*****************************************************************************************
 *****************************************************************************************/
bool:parse_file() {
	new got_line, line_num=0,  len=0, parsed
	new r[3][4], g[3][4], b[3][4]
	new full_line[MAX_TEXT_LENGTH], rest_line[MAX_TEXT_LENGTH], cfgdir[MAX_TEXT_LENGTH], cfgpath[MAX_TEXT_LENGTH]
	
	gl_num_colors = 0
	get_configsdir(cfgdir, MAX_TEXT_LENGTH)
	format(cfgpath, MAX_TEXT_LENGTH, "%s/%s", cfgdir, CFG_FILE)
	if (!file_exists(cfgpath)) {
		log_amx("ERROR: Cannot find configuration file '%s'!", cfgpath)
		return false
	}
	got_line = read_file(cfgpath, line_num, full_line, MAX_TEXT_LENGTH, len)
	if (got_line <=0) {
		log_amx("ERROR: Cannot read configuration file '%s'!", cfgpath)
		return false
	}
	while (got_line>0) {
		if (!equal(full_line, "//", 2) && len) {
			strtok(full_line, gl_color_names[gl_num_colors], MAX_NAME_LENGTH, rest_line, MAX_TEXT_LENGTH, ' ', 1)
			copy(full_line, MAX_TEXT_LENGTH, rest_line)

			parsed = parse(full_line,r[0],3,g[0],3,b[0],3)
			if (parsed<3) {
				log_amx("ERROR: Not enough colors, line %d in configuration file '%s'!", 1+line_num, CFG_FILE)
				return false
			}
			gl_colors[gl_num_colors][0] = str_to_num(r[0])
			gl_colors[gl_num_colors][1] = str_to_num(g[0])
			gl_colors[gl_num_colors][2] = str_to_num(b[0])

			gl_num_colors++
			if (gl_num_colors>=MAX_COLORS) {
				log_amx("WARNING: Max colors reached in file '%s'!", CFG_FILE)
				return true
			}
		}
		line_num++
		got_line = read_file(cfgpath, line_num, full_line, MAX_TEXT_LENGTH, len)
	}
	return true
}

check_map() {
	new got_line, line_num, len
	new cfgdir[MAX_TEXT_LENGTH]
	new cfgpath[MAX_TEXT_LENGTH]
	new mapname[MAX_NAME_LENGTH]
	new txt[MAX_TEXT_LENGTH]

	get_configsdir(cfgdir, MAX_TEXT_LENGTH-1)
	get_mapname(mapname, MAX_NAME_LENGTH-1)

	format(cfgpath, MAX_TEXT_LENGTH, "%s/sensiblemaps.cfg", cfgdir)
	
	if (file_exists(cfgpath)) {
		got_line = read_file(cfgpath, line_num, txt, MAX_TEXT_LENGTH-1, len)
		while (got_line>0) {
			if (equali(txt, mapname)) return 1
			line_num++
			got_line = read_file(cfgpath, line_num, txt, MAX_TEXT_LENGTH-1, len)
		}
	}
	return 0
}
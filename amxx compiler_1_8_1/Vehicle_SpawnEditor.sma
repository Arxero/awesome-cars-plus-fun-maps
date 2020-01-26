#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Vehicle Spawn Editor"
#define VERSION "1957"
#define AUTHOR "GlobalModders.net"

new const SPAWNS_URL[] = "%s/vehicle_sp/%s.ini"

const MAX_SPAWNS = 128
const MAX_POINTS = 32

new g_spawns[MAX_SPAWNS][3], g_angles[MAX_SPAWNS][3], g_total_spawns, g_spawn_edit, g_spawns_r[MAX_SPAWNS][3], g_angles_r[MAX_SPAWNS][3];
new cache_spr_line

new const color_spawn[3] = {255,255,255}
new const color_point_edit[3] = {162,17,237}

// Task offsets
enum (+= 100)
{
	TASK_SHOW_SPAWNS = 2000
}
// IDs inside tasks
#define ID_SHOW_SPAWNS (taskid - TASK_SHOW_SPAWNS)

//######################################################################
// REG PLUGIN
//######################################################################
public plugin_precache()
{
	cache_spr_line = precache_model("sprites/laserbeam.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	// Cmd
	register_concmd("vehicle_spawneditor", "menu_main")
}


//######################################################################
// MENU MAIN
//######################################################################
public menu_main(id)
{
	// check is admin
	if (!check_user_admin(id)) return PLUGIN_HANDLED;
	
	// remove task
	if (task_exists(id+TASK_SHOW_SPAWNS)) remove_task(id+TASK_SHOW_SPAWNS)
	
	// set task show point
	if (task_exists(id+TASK_SHOW_SPAWNS)) remove_task(id+TASK_SHOW_SPAWNS)
	set_task(1.0, "task_show_spawns", id+TASK_SHOW_SPAWNS, _, _, "b")
	
	spawn_main(id)

	return PLUGIN_HANDLED;
}
public task_show_spawns(taskid)
{
	new id = ID_SHOW_SPAWNS
	spawn_show(id)
}
/*
public spans_show(id)
{
	if (!g_total_spawns) return;
	
	new color[3], start[3], end[3]
	for (new i=0; i<g_total_spawns; i++)
	{
		if (i==g_spawn_edit) color = color_point_edit
		else color = color_spawn
		start[0] = g_spawns[i][0]
		start[1] = g_spawns[i][1]
		start[2] = g_spawns[i][2]
		if (!is_point(start)) return;
		end = start
		start[2] -= 36
		end[2] += 36

		create_line_point(id, start, end, color)
	}
}*/

//######################################################################
// SPAWNS POINTS
//######################################################################
// ===================== SPAWN MAIN MENU =====================
public spawn_main(id)
{
	// remove spawns choose
	g_spawn_edit = -1
	
	// create menu
	new title[64]
	format(title, charsmax(title), "Vehicle Spawn Editor [%i/%i]", g_total_spawns, MAX_SPAWNS)

	new mHandleID = menu_create(title, "spawn_main_handler")
	menu_additem(mHandleID, "Add", "add", 0)
	menu_additem(mHandleID, "Edit", "edit", 0)
	menu_additem(mHandleID, "Save", "save", 0)
	menu_additem(mHandleID, "Load", "load", 0)
	menu_additem(mHandleID, "Delete", "del", 0)

	menu_display(id, mHandleID, 0)
}

public spawn_main_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		
		// remove task
		if (task_exists(id+TASK_SHOW_SPAWNS)) remove_task(id+TASK_SHOW_SPAWNS)
			
		return;
	}
	
	new itemid[32], itemname[32], access
	menu_item_getinfo(menu, item, access, itemid, charsmax(itemid), itemname, charsmax(itemname), access)
	menu_destroy(menu)
	
	if (equal(itemid, "add"))
	{
		spawn_create(id)
		return;
	}
	else if (equal(itemid, "edit"))
	{
		// set first value for g_spawn_edit
		g_spawn_edit = 0
		spawn_edit(id)
		return;
	}
	else if (equal(itemid, "save")) spawn_save()
	else if (equal(itemid, "load")) spawn_load()
	else if (equal(itemid, "del")) spawn_del(1)
	
	// show main menu
	spawn_main(id)
}

// ===================== spawn create =====================
public spawn_create(id)
{
	// remove spawns choose
	g_spawn_edit = -1
	
	// create menu
	new title[64]
	format(title, charsmax(title), "Add a spawn point [%i/%i]", g_total_spawns, MAX_SPAWNS)

	new mHandleID = menu_create(title, "spawn_create_handler")
	menu_additem(mHandleID, "Add current point", "add", 0)
	menu_additem(mHandleID, "Delete the point", "del", 0)

	menu_display(id, mHandleID, 0)
}
public spawn_create_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		// destroy menu
		menu_destroy(menu)
		// show menu main
		spawn_main(id)
		return;
	}
	
	new itemid[32], itemname[32], access
	menu_item_getinfo(menu, item, access, itemid, charsmax(itemid), itemname, charsmax(itemname), access)
	menu_destroy(menu)

	if (equali(itemid, "add")) spawn_create_add(id)
	else if (equali(itemid, "del")) spawn_del()

	// return menu create spawns
	spawn_create(id)
	
	return;
}

spawn_create_add(id)
{
	// check max points
	if (g_total_spawns>=MAX_SPAWNS)
	{
		new message[128]
		format(message, charsmax(message), "Max spawn point is %i, you can't add more.", MAX_SPAWNS)
		color_saytext(id, message)
		return;
	}
	
	// add current points
	new Float:originF[3], origin[3], Float:Angle[3];
	pev(id, pev_origin, originF)
	pev(id, pev_v_angle, Angle);
	origin[0] = floatround(originF[0])
	origin[1] = floatround(originF[1])
	origin[2] = floatround(originF[2])
	
	if (!is_point(origin) || !spawn_check_dist(originF))
	{
		new message[128]
		format(message, charsmax(message), "This position is too closer to other things.")
		color_saytext(id, message)
		return;
	}
	
	g_spawns[g_total_spawns][0] = origin[0]
	g_spawns[g_total_spawns][1] = origin[1]
	g_spawns[g_total_spawns][2] = origin[2]
	
	g_angles[g_total_spawns][0] = 0
	g_angles[g_total_spawns][1] = floatround(Angle[1])
	g_angles[g_total_spawns][2] = 0
	
	g_total_spawns ++
}

// ===================== spawn edit =====================
public spawn_edit(id)
{
	// check total
	if (!g_total_spawns)
	{
		new message[128]
		format(message, charsmax(message), "There is no spawn point.")
		color_saytext(id, message)
		spawn_main(id)
		return;
	}
	
	// create menu
	new title[64], item_name[4][64]
	format(title, charsmax(title), "Edit spawn point")
	format(item_name[0], 63, "Previous point")
	format(item_name[1], 63, "Next point")
	format(item_name[2], 63, "Update this point")
	format(item_name[3], 63, "Delete point")

	new mHandleID = menu_create(title, "spawn_edit_handler")
	menu_additem(mHandleID, item_name[0], "back", 0)
	menu_additem(mHandleID, item_name[1], "next", 0)
	menu_additem(mHandleID, item_name[2], "edit", 0)
	menu_additem(mHandleID, item_name[3], "del", 0)
	menu_display(id, mHandleID, 0)
}
public spawn_edit_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		// destroy menu
		menu_destroy(menu)
		// show menu main
		spawn_main(id)
		return;
	}
	
	new itemid[32], itemname[32], access
	menu_item_getinfo(menu, item, access, itemid, charsmax(itemid), itemname, charsmax(itemname), access)
	
	if (equal(itemid, "back")) spawn_edit_back()
	else if (equal(itemid, "next")) spawn_edit_next()
	else if (equal(itemid, "edit")) spawn_edit_edit(id, g_spawn_edit)
	else if (equal(itemid, "del")) spawn_edit_del(g_spawn_edit)
	
	menu_destroy(menu)
	
	// return menu
	spawn_edit(id)
}
spawn_edit_back()
{
	if (g_spawn_edit<=0) g_spawn_edit = g_total_spawns-1
	else g_spawn_edit --
}
spawn_edit_next()
{
	if (g_spawn_edit<0 || g_spawn_edit>=g_total_spawns-1) g_spawn_edit = 0
	else g_spawn_edit ++
}
spawn_edit_edit(id, point)
{
	// check value
	if (point<0 || point>=g_total_spawns) return;

	// get points
	new Float:originF[3], origin[3], Float:Angle[3];
	pev(id, pev_origin, originF)
	pev(id, pev_angles, Angle);
	origin[0] = floatround(originF[0])
	origin[1] = floatround(originF[1])
	origin[2] = floatround(originF[2])
	
	// check point
	if (!is_point(origin) || !spawn_check_dist(originF, point))
	{
		new message[128]
		format(message, charsmax(message), "This position is too closer to other things.")
		color_saytext(0, message)
		return;
	}
	
	// update
	g_spawns[point][0] = origin[0]
	g_spawns[point][1] = origin[1]
	g_spawns[point][2] = origin[2]
	
	g_angles[point][0] = 0
	g_angles[point][1] = floatround(Angle[1])
	g_angles[point][2] = 0
}
spawn_edit_del(spawn)
{
	// check value
	if (spawn<0 || spawn>=g_total_spawns) return;
	
	// del spawn point
	new spawn_r[3]
	g_spawns[spawn] = spawn_r
	
	// create g_spawns_r
	reset_spawn(1)
	new total_s, point[3], point2[3];

	for (new i=0; i<g_total_spawns; i++)
	{
		point[0] = g_spawns[i][0]
		point[1] = g_spawns[i][1]
		point[2] = g_spawns[i][2]
		
		point2[0] = g_angles[i][0]
		point2[1] = g_angles[i][1]
		point2[2] = g_angles[i][2]
		
		if (is_point(point))
		{
			g_spawns_r[total_s][0] = point[0]
			g_spawns_r[total_s][1] = point[1]
			g_spawns_r[total_s][2] = point[2]
			
			g_angles_r[total_s][0] = point2[0]
			g_angles_r[total_s][1] = point2[1]
			g_angles_r[total_s][2] = point2[2]
			
			total_s ++
		}
	}
	
	// update g_spawns
	spawn_del(1)
	for (new s=0; s<total_s; s++)
	{
		g_spawns[s][0] = g_spawns_r[s][0]
		g_spawns[s][1] = g_spawns_r[s][1]
		g_spawns[s][2] = g_spawns_r[s][2]
		
		g_angles[s][0] = g_angles_r[s][0]
		g_angles[s][1] = g_angles_r[s][1]
		g_angles[s][2] = g_angles_r[s][2]
	}
	g_total_spawns = total_s
	if (spawn) g_spawn_edit = spawn-1
}

// ===================== spawn save =====================
spawn_save()
{
	// check total
	if (!g_total_spawns)
	{
		new message[128]
		format(message, charsmax(message), "There is no point to save.")
		color_saytext(0, message)
		return;
	}

	// get url file
	new cfgdir[32], mapname[32], urlfile[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(urlfile, charsmax(urlfile), SPAWNS_URL, cfgdir, mapname)

	// save file
	if (file_exists(urlfile)) delete_file(urlfile)
	new lineset[128]
	for (new i=0; i<g_total_spawns; i++)
	{
		if (!g_spawns[i][0] && !g_spawns[i][1] && !g_spawns[i][2]) break;
		
		format(lineset, charsmax(lineset), "%i %i %i %i %i %i",g_spawns[i][0], g_spawns[i][1], g_spawns[i][2], g_angles[i][0], g_angles[i][1], g_angles[i][2])
		write_file(urlfile, lineset, i)
	}
	
	// show notice
	new message[128]
	format(message, charsmax(message), "Your spawn points have been saved.")
	color_saytext(0, message)
}

// ===================== spawn load =====================
spawn_load()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64], point[3], angle[3]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_URL, cfgdir, mapname)
	
	// check file exit
	if (!file_exists(filepath))
	{
		new message[128]
		format(message, charsmax(message), "Spawnpoint doesn't exist (%s)", filepath)
		color_saytext(0, message)
		return;
	}
	
	// first reset value
	reset_spawn()
	
	// Load spawns points
	new file = fopen(filepath,"rt"), row[6][6]
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		
		// invalid spawn
		if(!linedata[0] || str_count(linedata,' ') < 2) continue;
		
		// get spawn point data
		parse(linedata,row[0],5,row[1],5,row[2],5,row[3],5,row[4],5,row[5],5)
		
		// set spawnst
		point[0] = str_to_num(row[0])
		point[1] = str_to_num(row[1])
		point[2] = str_to_num(row[2])
		angle[0] = str_to_num(row[3])
		angle[1] = str_to_num(row[4])
		angle[2] = str_to_num(row[5])
		
		if (is_point(point))
		{
			g_spawns[g_total_spawns][0] = point[0]
			g_spawns[g_total_spawns][1] = point[1]
			g_spawns[g_total_spawns][2] = point[2]
			
			g_angles[g_total_spawns][0] = angle[0]
			g_angles[g_total_spawns][1] = angle[1]
			g_angles[g_total_spawns][2] = angle[2]
	
			// increase spawn count
			g_total_spawns ++
			if (g_total_spawns>=MAX_SPAWNS) break;
		}
	}
	if (file) fclose(file)
	
	// notice
	if (g_total_spawns)
	{
		new message[128]
		format(message, charsmax(message), "Spawn points have been loaded (%i point(s))", g_total_spawns)
		color_saytext(0, message)
	}
}

// ===================== spawn del all =====================
spawn_del(all=0)
{
	// check total
	if (!g_total_spawns)
	{
		new message[128]
		format(message, charsmax(message), "There is no spawn point to delete.")
		color_saytext(0, message)
		return;
	}
	
	// del all
	if (all)
	{
		reset_spawn()
	}
	// del newest points
	else
	{
		static reset[3]
		g_total_spawns --
		g_spawns[g_total_spawns] = reset
		g_angles[g_total_spawns] = reset
	}
}

// ===================== other function =====================
spawn_show(id)
{
	if (!g_total_spawns) return;
	
	new color[3], start[3], end[3]
	for (new i=0; i<g_total_spawns; i++)
	{
		if (i==g_spawn_edit) color = color_point_edit
		else color = color_spawn
		start[0] = g_spawns[i][0]
		start[1] = g_spawns[i][1]
		start[2] = g_spawns[i][2]
		if (!is_point(start)) return;
		end = start
		start[2] -= 36
		end[2] += 36

		create_line_point(id, start, end, color)
	}
}
spawn_check_dist(Float:origin[3], point=-1)
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	
	for (new i=0; i<g_total_spawns; i++)
	{
		if (i==point) continue;
		
		originE[0] = float(g_spawns[i][0])
		originE[1] = float(g_spawns[i][1])
		originE[2] = float(g_spawns[i][2])
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2)<=2*16.0)
		{
			// oz
			origin1 = origin
			origin2 = originE
			origin1[0] = origin2[0] = origin1[1] = origin2[1] = 0.0
			if (vector_distance(origin1, origin2)<=100.0) return 0;
		}
	}

	return 1;
}


//######################################################################
// FUNCTION MAIN
//######################################################################

reset_spawn(t=0)
{
	for (new s=0; s<MAX_SPAWNS; s++)
	{
		for (new i=0; i<3; i++)
		{
			if (t) g_spawns_r[s][i] = 0
			else g_spawns[s][i] = 0
		}
	}
	if (!t) g_total_spawns = 0
}


is_point(point[3])
{
	if (!point[0] && !point[1] && !point[2]) return 0
	return 1
}

create_line_point(id, const start[3], const end[3], const color[3])
{
	if (!is_user_connected(id)) return;
	
	message_begin(MSG_ONE, SVC_TEMPENTITY, {0,0,0}, id)
	write_byte(TE_BEAMPOINTS)	// temp entity event
	write_coord(start[0])		// startposition: x
	write_coord(start[1])		// startposition: y
	write_coord(start[2])		// startposition: z
	write_coord(end[0])		// endposition: x
	write_coord(end[1])		// endposition: y
	write_coord(end[2])		// endposition: z
	write_short(cache_spr_line)	// sprite index
	write_byte(0)			// start frame
	write_byte(0)			// framerate
	write_byte(10)			// life in 0.1's
	write_byte(15)			// line width in 0.1's
	write_byte(0)			// noise amplitude in 0.01's
	write_byte(color[0])		// color: red
	write_byte(color[1])		// color: green
	write_byte(color[2])		// color: blue
	write_byte(200)			// brightness
	write_byte(0)			// scroll speed in 0.1's
	message_end()
}
color_saytext(player, const message[], any:...)
{
	new text[256]
	format(text, charsmax(text), "%s",message)
	format(text, charsmax(text), "%s",check_text(text))
	
	new dest
	if (player) dest = MSG_ONE
	else dest = MSG_ALL
	
	message_begin(dest, get_user_msgid("SayText"), {0,0,0}, player)
	write_byte(1)
	write_string(text)
	message_end()
}
check_text(text1[])
{
	new text[256]
	format(text, charsmax(text), "%s", text1)
	
	replace_all(text, charsmax(text), ">x04", "^x04")
	replace_all(text, charsmax(text), ">x03", "^x03")
	replace_all(text, charsmax(text), ">x01", "^x01")

	return text
}
check_user_admin(id)
{
	if (get_user_flags(id) & ADMIN_KICK) return 1
	return 0;
}
str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

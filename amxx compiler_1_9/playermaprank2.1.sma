 /*
 *  AMX Mod X script
 *
 *	Player Map Rank
 *
 *	by Slurpy [COF](slurpy@clancof.net)
 *
 *		Thanks to:
 *      devicenull for his SQL tutorial
 *		p00h map_rate for amx that was the basis for this
 *      XxAvalanchexX for checking my original code
 *      ALOT of other AMXX scripters whose code I looked through to learn how to do this
 *
 *
 *  IF YOU ARE USING SQL
 *  ====================
 *	 map vote results saved into a MySQL database.
 *	 requires sql module enabled!
 *
 *	amx_sql_host, amx_sql_user, amx_sql_pass and amx_sql_db are set in
 *	$moddir/addons/amxx/configs/sql.cfg
 *
 *	How can I make my website with this?
 *       I have also attached a very basic php page that will display the results
 *
 *  IF YOU ARE NOT USING SQL
 *  ========================
 *	This will store the vote results in the addons\amxmodx\configs\maprank
 *	folder.  YOU MUST CREATE THE MAPRANK FOLDER BEFORE YOU INSTALL THIS!!!!
 *
 *	It will save the map rank results in a new file for each map by name.
 *
 *	EXAMPLE:
 *	addons\amxmodx\configs\maprank\de_dust.log
 *	Good = 1 Okay = 0 Bad = 0 Total votes = 1
 *	Good = 0 Okay = 0 Bad = 1 Total votes = 1
 *
 *  Cvars
 *  ========
 *  amx_mapvotemode 1 (no display), 2 (admin display only) or 3 (display all)
 *
 *  VERSIONS
 *  ========
 *  0.1	 First version
 *  0.2	 Added CVAR to allow setting voting results display to all/admins only/none
 *  0.3  Changed DB insert to pre MySQL 4.1 format ("insert or update" instead of "insert on duplicate")
 *  1.0  Changed to a full release and added language file support
 *  1.1  Added check so that vote will not occur is server is empty
 *  2.0  Added log file support for non-SQL servers
 *  2.1  Updated MySQL code to comply with amxx 1.7
 */

 // Uncomment for SQL version
 //#define USING_SQL

 #include <amxmodx>
 #if defined USING_SQL
 #include <dbi>
 #else
 #include <amxmisc>
 #endif

 #if defined USING_SQL
 new Sql:dbc
 new Result:result
 #endif
 new statea[3]
 new nowstate[3]
 new plnum
 new bshow = true
 new Float:total

 public plugin_init() {
	register_plugin("Player Map Rank","2.1","Slurpy [COF]")
	register_cvar("PlayerMapRank", "2.1",FCVAR_SERVER)
	register_dictionary("playermaprank.txt")
	register_menucmd(register_menuid("What do you think about "),(1<<0)|(1<<1)|(1<<2),"vote_count")
	set_task(10.0,"read_rate",777,"",0,"b")
	register_cvar("amx_mapvotemode", "3")
	#if defined USING_SQL
	set_task(0.1,"sql_init")
	#endif
 }

#if defined USING_SQL
//////////////////////////////////////////////////////////////////////////////////////////
//      Get SQL config info and connect to the database
//////////////////////////////////////////////////////////////////////////////////////////

 public sql_init() {
	new host[64], username[32], password[32], dbname[32], error[32]
	get_cvar_string("amx_sql_host",host,64)
	get_cvar_string("amx_sql_user",username,32)
	get_cvar_string("amx_sql_pass",password,32)
	get_cvar_string("amx_sql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if (dbc == SQL_FAILED)
	log_amx("[AMXX] SQL Connection Failed")
	else
	{
		dbi_query(dbc,"CREATE TABLE IF NOT EXISTS `maprank` ( `map_name` VARCHAR(32) NOT NULL,`good` INT NOT NULL, `okay` INT NOT NULL, `bad` INT NOT NULL, `total` INT NOT NULL, PRIMARY KEY(`map_name`))")
	}
 }
 #endif

 #if defined USING_SQL
//////////////////////////////////////////////////////////////////////////////////////////
//      Store map vote results into the database
//////////////////////////////////////////////////////////////////////////////////////////

 public sql_insert() {
	if (dbc == SQL_FAILED) return PLUGIN_CONTINUE
	new mapname[33]
	get_mapname(mapname,32)
	new totalint
	totalint = floatround(total)
	//Insert map information into the tables
	result = dbi_query(dbc,"SELECT * FROM maprank where map_name ='%s'",mapname)
	if (result == RESULT_FAILED){ //Problem with mysql
		log_amx("[playermaprank] MySQL Query failed")
		return PLUGIN_CONTINUE
	}else if (result == RESULT_NONE){ //not in db, set to 0
		result = dbi_query(dbc,"INSERT INTO maprank (map_name, good, okay, bad, total) values ('%s',%i,%i,%i,%i)",mapname,statea[0],statea[1],statea[2],totalint)
	}else{ //get totaltime from database
		result = dbi_query(dbc,"UPDATE maprank SET good=good+%i, okay=okay+%i, bad=bad+%i, total=total+%i WHERE map_name='%s'",statea[0],statea[1],statea[2],totalint,mapname)
	}
	dbi_free_result(result)
	return PLUGIN_CONTINUE
 }
 
#else
//////////////////////////////////////////////////////////////////////////////////////////
//      Write map vote results to file
//////////////////////////////////////////////////////////////////////////////////////////

 public write_log() {
	new mapname[33], configsDir[64], logdata[128]
	get_mapname(mapname,32)
	get_configsdir(configsDir, 63)
	new totalint
	totalint = floatround(total)
	//Insert map information into the logs
	format(configsDir, 63, "%s/maprank/%s.log", configsDir,mapname)
	format(logdata,127, "%L",LANG_SERVER,"DATA_LOGGED",statea[0],statea[1],statea[2],totalint)
	write_file( configsDir , logdata )
	return PLUGIN_HANDLED
 }
 #endif

 public ask_menu() {
	new menu[256]
	new mapname[33]
	get_mapname(mapname,32)
	plnum = 0
	nowstate[0] = 0
	nowstate[1] = 0
	nowstate[2] = 0
	//Display the voting menu
	format(menu,255,"%L",LANG_PLAYER,"ASK_VOTE",mapname)
	show_menu(0,(1<<0)|(1<<1)|(1<<2),menu,10)
	client_cmd(0,"spk Gman/Gman_Choose2")
	set_task(10.0,"end_conduct")
	client_print(0,print_chat,"%L",LANG_PLAYER,"CONDUCT")
 }

 public vote_count(id,key) {
	new name[32]
	get_user_name(id,name,31)

	if(key == 0) {
		if (get_cvar_num("amx_mapvotemode")== 1){ //no print
			statea[0]++
			nowstate[0]++
			return PLUGIN_CONTINUE
			} else if (get_cvar_num("amx_mapvotemode")== 2) {  //admin print
			new players[32], num
			get_players(players, num)
			new i
			for (i=0; i<num; i++)
			{
				if (!(get_user_flags(id)&ADMIN_IMMUNITY))     return PLUGIN_CONTINUE
				client_print(i,print_chat,"%L",LANG_PLAYER,"GOOD",name)
			}
			statea[0]++
			nowstate[0]++
			return PLUGIN_CONTINUE
			} else {
			client_print(0,print_chat,"%L",LANG_PLAYER,"GOOD",name)
			statea[0]++
			nowstate[0]++
			return PLUGIN_CONTINUE
		}

	}
	if(key == 1) {
		if (get_cvar_num("amx_mapvotemode")== 1){ //no print
			statea[1]++
			nowstate[1]++
			return PLUGIN_CONTINUE
			} else if (get_cvar_num("amx_mapvotemode")== 2) {  //admin print
			new players[32], num
			get_players(players, num)
			new i
			for (i=0; i<num; i++)
			{
				if (!(get_user_flags(id)&ADMIN_IMMUNITY))     return PLUGIN_CONTINUE
				client_print(1,print_chat,"%L",LANG_PLAYER,"MEDIUM",name)
			}
			statea[1]++
			nowstate[1]++
			return PLUGIN_CONTINUE
			} else {
			client_print(0,print_chat,"%L",LANG_PLAYER,"MEDIUM",name)
			statea[1]++
			nowstate[1]++
			return PLUGIN_CONTINUE
		}
	}
	if(key == 2) {
		if (get_cvar_num("amx_mapvotemode")== 1){ //no print
			statea[2]++
			nowstate[2]++
			return PLUGIN_CONTINUE
			} else if (get_cvar_num("amx_mapvotemode")== 2) {  //admin print
			new players[32], num
			get_players(players, num)
			new i
			for (i=0; i<num; i++)
			{
				if (!(get_user_flags(id)&ADMIN_IMMUNITY))     return PLUGIN_CONTINUE
				client_print(i,print_chat,"%L",LANG_PLAYER,"BAD",name)
			}
			statea[2]++
			nowstate[2]++
			return PLUGIN_CONTINUE
			} else {
			client_print(0,print_chat,"* %s selected So Bad..!!",name)
			client_print(0,print_chat,"%L",LANG_PLAYER,"BAD",name)
			statea[2]++

			nowstate[2]++
			return PLUGIN_CONTINUE
		}
	}
	plnum++
	return PLUGIN_CONTINUE
 }


 public end_conduct(id) {
	new Float:ans[3]
	new Float:tans[3]
	new name[32]
	get_user_name(id,name,31)

	if(nowstate[0] == 0) {
		nowstate[0] = 0
		}else {
		ans[0] = float(nowstate[0]) / float(plnum)
	}
	if(nowstate[2] == 0) {
		nowstate[2] = 0
		}else {
		ans[2] = float(nowstate[2]) / float(plnum)
	}
	ans[1] = 1.00 - (ans[0] + ans[2])
	total = float(statea[0] + statea[1] + statea[2])
	if(statea[0] == 0) {
		tans[0] = float(0)
		}else {
		tans[0] = float(statea[0]) / total
	}
	if(statea[2] == 0) {
		tans[2] = float(0)
		}else {
		tans[2] = float(statea[2]) / total
	}
	tans[1] = 1.00 - (tans[0] + tans[2])

	if (get_cvar_num("amx_mapvotemode")== 1){ //no print
		} else if (get_cvar_num("amx_mapvotemode")== 2) {  //admin print
		new players[32], num
		get_players(players, num)
		new i
		for (i=0; i<num; i++)
		{
			if (!(get_user_flags(id)&ADMIN_IMMUNITY))     return PLUGIN_CONTINUE
			client_print(i,print_chat,"%L",LANG_PLAYER,"TOTAL_RATE",tans[0],tans[1],tans[2])
		}
		} else {
		client_print(0,print_chat,"%L",LANG_PLAYER,"TOTAL_RATE",tans[0],tans[1],tans[2])
	}


	#if defined USING_SQL
	sql_insert()
	#else
	write_log()
	#endif
	return PLUGIN_CONTINUE
 }

 public read_rate() {
	new timeleft = get_timeleft()
	new numplayers = get_playersnum()

	if(bshow&&(timeleft>0)&&(timeleft<300)&&(numplayers>0)) {
		bshow = false
		ask_menu()
	}
 }


/*
 *	Ptahhotep's Team Balancer (PTB)
 *	Version 1.8b1
 *	AUTHOR: Ptahhotep (ptahhotep@planethalflife.com)
 *
 *  1.7b3   PTB converted for AMX Mod by OLO
 *  1.7b5   Modified for CS 1.6 by XAD.
 *          Thanks Redmist ("slot1" to close old-style-menus).
 *          Added fix by 'Panzermensh' for lost kill when moved
 *          (thanks r0otd0wn).
 *  1.7b6   Ported to AMX Mod X 0.16 by XAD.
 *          Changed config file path to configs/ptb.cfg
 *  1.7b7   Added admin immunity by Ingerfara. (Thanks to EpsychE and rootdown)
 *  1.7b8   JGHG: changed the path of ptb.cfg to use AMXx's default custom path.
 
 *  1.7b9.2 lantz69: 2005-10-03
 			- changed how players are transfered and cleaned up the code.
			- Players are now transfered without being killed and they also keep their weapons
			- lastRoundSwitched[id] is also updated at transfers. Before the amx_ptb playerfreq was broken

 *  1.7b9.3 lantz69: 2006-01-12
		- small fix for client_prints.

 *  1.8b1 lantz69: 2006-04-05
		- ptb.cfg is now back in addons/amxmodx/configs/
		- wtj.log is now in addons/amxmodx/logs/
		- using amxmodx function floatabs
		- added amxmodx 1.70 autochanneling for hud messages
		- admins with kick flag is able to join spec even if autojoin is enabled
		- new cvars ptb_switch_immunity and ptb_limitjoin_immunity. (in ptb.cfg)
		  Now it's easy to disable admins immunity.
		  
	* 1.8b2 lantz69: 2006-08-03
		- If player has defuse kit before a transfer it will be removed (thx teame06)
		- Added compile option #define SHOW_IN_HLSW To be able to remove transfers being showed in HLSW chat (Sug. Brad)
		
	* 1.8b3 lantz69: 2007-03-03
		- Fixed so you can have mp_roundtime to almost whatever you want and PTB will still work.
		Before PTB did not work if you had mp_roundtime set to 2.10 or 1.75 etc It had to be 1.5, 2.0, 2.5 etc
		- Added log_message to hlds logs when a player is transfered (player X joined team ..) for PsychoStats 3.X
		- Changed the time player is transfered from 4.0 to 4.5 seconds
		- Added cvar ptb_immunity_level so you dont need to recompile to change the admin flag for immunity
		- Added cvar ptb_access_level so you dont need to recompile to change the admin flag for access to ptb
		- Added cvar ptb_show_in_hlsw If you want to see Transfers made in the HLSW chat have this set to 1
		- Added the above cvars into ptb.cfg ptb_immunity_level, ptb_show_in_hlsw and ptb_access_level
		- Made all cvars use the new pcvars system.
		- Added protection for VIP to be transfered (Uncomment #define PTB_VIP_IMMUNITY in the source for this to work)
		
		*** TODO ******
		Make it MultiLingual
 */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>

// Uncomment for support immunity on VIP
//#define PTB_VIP_IMMUNITY

// Uncomment to activate log debug messages.
//#define PTB_DEBUG

// team ids
#define UNASSIGNED	 	0
#define TS 			1
#define CTS			2
#define AUTO_TEAM 		5

new const PTB_VERSION[] = "1.8b3"

// team selection control
new bool:PTB_LIMITJOIN = true // set limits on team joining
new PTB_LIMITAFTER = 0 // number of rounds after which teams limiting begins
new PTB_LIMITMIN = 0 // number of minimum players on map for team limiting
new PTB_MAXSIZE = 10 // maximum team size per team
new PTB_MAXDIFF = 2 // maximum team size difference
new PTB_AUTOROUNDS = 3 // number of first rounds into match, which allow autojoin only
new PTB_WTJAUTO = 3 // wtj tries needed to become autojoined
new PTB_WTJKICK = 5 // wtj tries needed to become kicked
new bool:PTB_KICK = true // kick for wtj counts
new bool:PTB_SAVEWTJ = false // save wtjs to wtj.log

// team balancing actions
new bool:PTB_SWITCH = true // switch/transfer players
new PTB_SWITCHAFTER = 0 // number of rounds after which switching begins
new PTB_SWITCHMIN = 3 // number of minimum players on map for switching
new PTB_SWITCHFREQ = 1 // relative next possible switch round
new PTB_PLAYERFREQ = 3 // relative next possible switch round for player
new PTB_FORCESWITCH = 3 // number of tries after which PTB switches alive, if neccessary
new bool:PTB_DEADONLY = false // switch dead only

// messages
new bool:PTB_TELLWTJ = true // tell about wtj tries
new bool:PTB_ANNOUNCE = true // announce team status at beginning of round
new bool:PTB_SAYOK = true // announce team status, if teams are alright
new bool:PTB_TYPESAY = true // use typesay

// team strength limits
new PTB_MAXSTREAK = 2 // max. allowed team win streak
new PTB_MAXSCORE = 2 // max. allowed team score difference
new Float:PTB_MINRATING = 1.5 // minimum critical team rating
new Float:PTB_MAXRATING = 2.0 // maximum critical team rating
new Float:PTB_SUPERRATING = 3.0 // super critical team rating
new PTB_MAXINCIDENTS = 50 // maximum kills + deaths before the score is divided by PTB_SCALEDOWN
new PTB_SCALEDOWN = 2 // divisor for kills and deaths, when PTB_MAXINCIDENTS is reached

// sorted player indices are 0-based
new sortedTeams[3][32]
new sortedValidTargets[3][32]
new validTargetCounts[3]

new teamKills[3]
new teamDeaths[3]
new teamScores[3]
new winStreaks[3]

new wtConditions[3]
new winnerTeam
new loserTeam

new Float:ctKD
new Float:tKD
new Float:ctStrength
new Float:tStrength
new Float:ctRating
new Float:tRating

// player arrays are 1-based, there is no player 0
new clientVGUIMenu[33][2]
new bool:isBeingTransfered[33]
new playerTeam[33]
new lastRoundSwitched[33]
new wtjCount[33]
new teamCounts[3]
new kills[33]
new deaths[33]

new roundCounter
new lastSwitchRound
new couldNotSwitchCounter

new lastTeamBalanceCheck[32]

//New auto-channeling system in amxmodx 1.70
new g_MyMsgSync

// pcvars
new saychat
new transfer_type
new switch_immunity
new limitjoin_immunity
new immunity_level
new access_level
new show_in_hlsw

public plugin_init(){
	register_plugin("Team Balancer",PTB_VERSION,"Ptahhotep")
	register_cvar("amx_ptb_version",PTB_VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	saychat = register_cvar("ptb_saychat", "1")
	transfer_type = register_cvar("ptb_transfer_type", "1")
	switch_immunity = register_cvar("ptb_switch_immunity", "1")
	limitjoin_immunity = register_cvar("ptb_limitjoin_immunity", "1")
	immunity_level = register_cvar("ptb_immunity_level", "o")
	access_level = register_cvar("ptb_access_level", "l")
	show_in_hlsw = register_cvar("ptb_show_in_hlsw", "1")
	
	register_menucmd(register_menuid("Team_Select",1),(1<<0)|(1<<1)|(1<<4),"teamselect")
	register_event("ShowMenu","menuclass","b","4&CT_Select","4&Terrorist_Select")
	register_clcmd("jointeam","jointeam")
	register_clcmd("team_join","team_join")
#if defined PTB_DEBUG
	register_clcmd("say /last","check_lasttransfer")
#endif
	register_event("SendAudio","round_end","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw") // Round End
	register_event("TeamScore","team_score","a") // Team Score
	register_event("RoundTime", "new_round", "bc") // Round Time
	register_event("DeathMsg","death_msg","a") // Kill
	register_event("TeamInfo","team_assign","a") // Team Assigment (also UNASSIGNED and SPECTATOR)
	register_event("TextMsg","team_join","a","1=1","2&Game_join_te","2&Game_join_ct") // Team Joining
	register_event("TextMsg","game_restart","a","1=4","2&#Game_C","2&#Game_w") // Game restart
	register_concmd("amx_ptb","admin_ptb",get_access_level_flag(),"- displays PTB options")
	
	new configsDir[64]
	get_configsdir(configsDir, 63)
	server_cmd("exec %s/ptb.cfg", configsDir) // Execute main configuration file

	//New auto-channeling system in amxmodx 1.70
	g_MyMsgSync = CreateHudSyncObj()

	
	// Init clients VGUI-menu setting
	// Set terminating 0 to allow use of char processing instead of string
	// to improve performance.
	for (new i=0;i<33;i++){
		clientVGUIMenu[i][0] = '0'
		clientVGUIMenu[i][1] = 0
	}

	return PLUGIN_CONTINUE
}

public get_immunity_level_flag()
{
	new flags[24]
	get_pcvar_string(immunity_level, flags, 23)
	
	return(read_flags(flags))
}

public get_access_level_flag()
{
	new flags[24]
	get_pcvar_string(access_level, flags, 23)
	
	return(read_flags(flags))
}


Float:fdivWorkaround(Float:nom, Float:denom){
	if ( denom == 0.0) return nom
	return floatabs(nom / denom)
}

doTypesay(string[], duration, r, g, b) {
	if (!PTB_TYPESAY) return
	//last parameter is not needed
	set_hudmessage(r, g, b, 0.05, 0.25, 0, 6.0, float(duration) , 0.5, 0.15, -1)
	//use this instead of show_hudmessage
	ShowSyncHudMsg(0, g_MyMsgSync, "%s", string)
}

say(string[]){
	if(get_pcvar_num(saychat) == 1 || get_pcvar_num(saychat) == 3){
		client_print(0,print_chat,string)
		server_print(string)
	}
}

bool:check_param_bool(param[])
	return (equali(param, "on") || equal(param, "1")) ? true : false

Float:check_param_float(param[],Float:n){
	new Float:a = floatstr(param)
	if (a < n) a = n
	return a
}

check_param_num(param[],n){
	new a = str_to_num(param)
	if (a < n) a = n
	return a
}

transferPlayer(id){

	if (!is_user_connected(id)) return
	if (isBeingTransfered[id]) return
	isBeingTransfered[id] = false
	
	new name[32], player_steamid[50], team_pre_transfer[12]
	get_user_name(id,name,31)
	get_user_authid(id, player_steamid, 49)
	get_user_team(id, team_pre_transfer, 11)
	
	if(cs_get_user_defuse(id))
     cs_set_user_defuse(id, 0);
	
	cs_set_user_team(id, (playerTeam[id]==TS) ? 2 : 1)
	cs_reset_user_model(id)

	// This must be done here or lastroundswithed will not be registered
	lastRoundSwitched[id] = roundCounter
	
	// This logs to hlds logs so Psychostats knows that the player has changed team (PS 3.X)
	//"LAntz69<9><STEAM_0:1:1895474><TERRORIST>" joined team "CT"  //This is how it will be outputted in hlds logs
	log_message("^"%s<%d><%s><%s>^" joined team ^"%s^"", 
		name, get_user_userid(id), player_steamid, team_pre_transfer, (playerTeam[id]==TS) ? "CT" : "TERRORIST" )
		
	if(get_pcvar_num(show_in_hlsw) == 1)
	{
		// This makes you able to see transfers with HLSW in the chat
		log_message("^"<><><>^" triggered ^"amx_chat^" (text ^"[PTB] Transfered %s to %s^")", 
			name, (playerTeam[id]==TS) ? "CT" : "TERRORIST" )
	}
	
#if defined PTB_DEBUG
	log_amx("Transfer player: %s lastRoundSwitched[id]: %i roundCounter:%i", name, lastRoundSwitched[id], roundCounter)
	client_print(0,print_chat,"Transfer player: %s lastRoundSwitched[id]: %i roundCounter:%i", name, lastRoundSwitched[id], roundCounter)
#endif
}

#if defined PTB_DEBUG
public check_lasttransfer(id) {
	new lasttransfer, text[255]
	lasttransfer = lastRoundSwitched[id]
	
	format(text,255,"LastRound transfered: %i", lasttransfer)
	say(text)
}
#endif

actAtEndOfRound(){
	if (!PTB_SWITCH) return
	// skip switching for the first few rounds
	if (roundCounter <= PTB_SWITCHAFTER) return
	// honor switch frequency setting
	if (roundCounter - lastSwitchRound < PTB_SWITCHFREQ) return
	// skip switching for a small number of players
	if (get_playersnum() < PTB_SWITCHMIN) return
	
	say("PTB: Round ended, checking teams.")
	checkTeamBalance()
	if (winnerTeam) {
		sortTeam(CTS)
		sortTeam(TS)
				
		// If they set the cvar(ptb_transfer_type) 1 or less than 2 or bigger than 3 
		// then standard transfers will be selected 
		if(get_pcvar_num(transfer_type) < 2 || get_pcvar_num(transfer_type) > 3){
			
		// This is the standard if it should be a swith of to players or just one transfer
		if (teamCounts[winnerTeam] <= teamCounts[loserTeam]) // Original formula
			doSwitch()
		else if (teamCounts[loserTeam] < teamCounts[winnerTeam]) // Original formula
			doTransfer()	
			
		}
		
		if(get_pcvar_num(transfer_type) == 2){
			
			// This is more agressive but not so much as the one below
			if (teamCounts[winnerTeam] < teamCounts[loserTeam])
				doSwitch()
					
			else if (teamCounts[loserTeam] <= teamCounts[winnerTeam])
				doTransfer()
		}
		
		if(get_pcvar_num(transfer_type) == 3){
			
			// This is the most agressive transfertype
			if ((teamCounts[winnerTeam]+(PTB_MAXDIFF/2)) < teamCounts[loserTeam])
				doSwitch()
					
			else if (teamCounts[loserTeam] <= (teamCounts[winnerTeam]+(PTB_MAXDIFF/2)))
				doTransfer()
		}

	}
}

createValidTargets(theTeam, bool:deadonly) {
	new n = 0
	for (new i = 0; i < teamCounts[theTeam]; ++i) {
		

#if defined PTB_VIP_IMMUNITY
		// If player is in the VIP team dont touch
		if (cs_get_user_vip(sortedTeams[theTeam][i])) continue
#endif
		
		// Protection for admins if ptb_switch_immunity 1
		if (get_user_flags(sortedTeams[theTeam][i])&get_immunity_level_flag() && (get_pcvar_num(switch_immunity) == 1)) continue
		// Dead only condition
		if ( deadonly && is_user_alive(sortedTeams[theTeam][i]) ) continue
		// Already switched or in PTB_PLAYERFREQ time condition
		if ((lastRoundSwitched[sortedTeams[theTeam][i]] == roundCounter) ||
			(roundCounter - lastRoundSwitched[sortedTeams[theTeam][i]] < PTB_PLAYERFREQ))	continue
		sortedValidTargets[theTeam][n++] = sortedTeams[theTeam][i]
	}
	validTargetCounts[theTeam] = n
}

sortTeam(theTeam) {
	// create list of players
	new n = 0, a = get_maxplayers()
	for (new i = 1; i <= a; ++i) {
		// Get only members of specified team
		if (playerTeam[i] != theTeam) continue
		sortedTeams[theTeam][n++] = i
	}
	// do a selection sort
	new swap, count = n
	for (new i = count-1; i > 0; --i){
		for (new k = i-1; k >= 0; --k){
			// compare players (kills better then other or if equal then with less deaths)
			if ( (kills[sortedTeams[theTeam][k]]<kills[sortedTeams[theTeam][i]])
				|| ( (kills[sortedTeams[theTeam][k]]==kills[sortedTeams[theTeam][i]])	&&
				(deaths[sortedTeams[theTeam][k]]>deaths[sortedTeams[theTeam][i]]))) {
				// swap
				swap = sortedTeams[theTeam][k]
				sortedTeams[theTeam][k] = sortedTeams[theTeam][i]
				sortedTeams[theTeam][i] = swap
			}
		}
	}
}

Float:score(team, toBeAdded=0, toBeRemoved=0){
	new Float:sumKD = 0.0
	new a = get_maxplayers()
	for (new i = 1; i <= a; ++i) {
		if ( (playerTeam[i]!=team&&i!=toBeAdded)	|| (i==toBeRemoved)	)
			continue
		sumKD += fdivWorkaround(float(kills[i]), float(deaths[i]))
	}
	new Float:strength = float(teamCounts[team])
	if (sumKD) strength *= sumKD
	return strength
}

doSwitch() {
	new text[256]
	//displayStatistics(0,true)
	// don't switch, if at least one team is empty
	if ( teamCounts[winnerTeam] == 0 || teamCounts[loserTeam] == 0 ) {
		copy(text,255, "PTB: Can't switch players, need players in each team.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	// don't switch, if winner is alone (RULER!!!)
	if (teamCounts[winnerTeam] == 1) {
		copy(text,255, "PTB: Won't switch players, best player makes the winning team.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	// don't switch, if both teams are full
	if (teamCounts[winnerTeam] >= PTB_MAXSIZE && teamCounts[loserTeam] >= PTB_MAXSIZE) {
		copy(text,255, "PTB: Can't switch players, both teams are full.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	if (!PTB_DEADONLY || couldNotSwitchCounter > PTB_FORCESWITCH) {
		// choose from random top or bottom x
		createValidTargets(winnerTeam, false)
		createValidTargets(loserTeam, false)

		if (validTargetCounts[winnerTeam] == 0 || validTargetCounts[loserTeam] == 0) {
			++couldNotSwitchCounter
			copy(text,255, "PTB: Can't switch players, need valid target in each team.")
			doTypesay(text, 5, 0, 255, 0)
			say(text)
			return
		}
	}
	else {
		//say("switch dead")
		createValidTargets(winnerTeam, true)
		createValidTargets(loserTeam, true)

		if (validTargetCounts[winnerTeam] == 0 || validTargetCounts[loserTeam] == 0) {
			if (++couldNotSwitchCounter > PTB_FORCESWITCH) {
				say("PTB: Couldn't switch dead, switching alive.")
				doSwitch()
				return
			}
			copy(text, 255,"PTB: Can't switch players, need valid target in each team.")
			doTypesay(text, 5, 0, 255, 0)
			say(text)
			return
		}
	}
	// Now search through the possible 1 to 1 swaps to equalize the strength as much as possible
	new Float:closestScore = floatabs(score(winnerTeam) - score(loserTeam))
	new Float:myScore, toLoser, toWinner
	new winner = 0
	new loser = 0
	for (new w = 0; w < validTargetCounts[winnerTeam]; ++w) {
		toLoser = sortedValidTargets[winnerTeam][w]
		for (new l = 0; l < validTargetCounts[loserTeam]; ++l) {
			toWinner = sortedValidTargets[loserTeam][l]
			myScore = floatabs(score(winnerTeam, toWinner, toLoser) - score(loserTeam, toLoser, toWinner))
			if (myScore < closestScore) {
				closestScore = myScore
				winner = toLoser
				loser = toWinner
			}
		}
	}
	if (winner == 0 && loser == 0) {
		copy(text, 255,"PTB: No switch would improve team balancing.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	couldNotSwitchCounter = 0
	lastSwitchRound = roundCounter
	new winnerName[32], loserName[32]
	get_user_name(winner,winnerName,31)
	get_user_name(loser,loserName,31)
	// if one team is full, first move the the player from the full team ...
	if (teamCounts[winnerTeam] >= PTB_MAXSIZE){
		transferPlayer(winner)
		transferPlayer(loser)
	}
	else {
		transferPlayer(loser)
		transferPlayer(winner)
	}
	format(text,255,"PTB: Switching %s with %s.",winnerName,loserName)
	
	if(get_pcvar_num(saychat) == 2 || get_pcvar_num(saychat) == 3){
	//say(text)
		//set_hudmessage(0, 255, 0, 0.05, 0.25, 0, 6.0, 5.0 , 0.5, 0.15, 1)
		//show_hudmessage(0, text )
		set_hudmessage(0, 255, 0, 0.05, 0.25, 0, 6.0, 5.0 , 0.5, 0.15, -1)
		ShowSyncHudMsg(0, g_MyMsgSync, "%s", text)
		client_print(0,print_chat,"PTB: Switching %s with %s.",winnerName,loserName)
	}else{
		doTypesay(text, 5, 0, 255, 0)
		client_print(0,print_chat,"PTB: Switching %s with %s.",winnerName,loserName)
		//say(text)
	}
}

doTransfer() {
	//displayStatistics(0,true)
	new text[256]
	if (teamCounts[winnerTeam] == 0) {
			copy(text,255, "PTB: Can't switch players, need players in each team.")
			doTypesay(text, 5, 0, 255, 0)
			say(text)
			return
	}
	if (teamCounts[loserTeam] >= PTB_MAXSIZE) {
		copy(text,255, "PTB: Can't transfer player, losing team is full.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	if (!PTB_DEADONLY || couldNotSwitchCounter > PTB_FORCESWITCH) {
		createValidTargets(winnerTeam, false)
		if (validTargetCounts[winnerTeam] == 0) {
			copy(text,255, "PTB: Can't transfer player, no valid target in winning team.")
			doTypesay(text, 5, 0, 255, 0)
			say(text)
			++couldNotSwitchCounter
			return
		}
	}
	else {
		//say("switch dead")
		createValidTargets(winnerTeam, true)
		if (validTargetCounts[winnerTeam] == 0) {
			if (++couldNotSwitchCounter > PTB_FORCESWITCH) {
				say("PTB: Couldn't transfer dead, transferring alive.")
				doTransfer()
				return
			}
			copy(text,255, "PTB: Can't transfer player, no valid target in winning team.")
			doTypesay(text, 5, 0, 255, 0)
			say(text)
			return
		}
	}
	new Float:closestScore = floatabs(score(winnerTeam) - score(loserTeam))
	new Float:myScore, toLoser
	new winner = 0
	for (new w = 0; w < validTargetCounts[winnerTeam]; ++w) {
		toLoser = sortedValidTargets[winnerTeam][w]
		myScore = floatabs(score(winnerTeam, 0, toLoser) - score(loserTeam, toLoser, 0))
		if (myScore < closestScore) {
			closestScore = myScore
			winner = toLoser
		}
	}
	if (winner == 0) {
		copy(text, 255,"PTB: No transfer would improve team balancing.")
		doTypesay(text, 5, 0, 255, 0)
		say(text)
		return
	}
	if ((teamCounts[winnerTeam] - 1) == 0) {
  	return
	}
 	if (teamCounts[loserTeam]+1-teamCounts[winnerTeam] >= PTB_MAXDIFF) {
  	return
	}

	couldNotSwitchCounter = 0
	new winnerName[32]
	get_user_name(winner,winnerName,31)
	transferPlayer(winner)
	format(text,255,"PTB: Transfering %s to the %s",winnerName, (winnerTeam == CTS) ? "Ts" : "CTs")
	
	if(get_pcvar_num(saychat) == 2 || get_pcvar_num(saychat) == 3){
	//say(text)
		//set_hudmessage(0, 255, 0, 0.05, 0.25, 0, 6.0, 5.0 , 0.5, 0.15, 1)
		//show_hudmessage(0, text )
		set_hudmessage(0, 255, 0, 0.05, 0.25, 0, 6.0, 5.0 , 0.5, 0.15, -1)
		ShowSyncHudMsg(0, g_MyMsgSync, "%s", text)
		client_print(0,print_chat,"PTB: Transfering %s to the %s",winnerName, (winnerTeam == CTS) ? "Ts" : "CTs")
	}else{
		doTypesay(text, 5, 0, 255, 0)
		client_print(0,print_chat,"PTB: Transfering %s to the %s",winnerName, (winnerTeam == CTS) ? "Ts" : "CTs")
		//say(text)
	}
}

checkTeamBalance() {

	get_time("%m/%d/%Y - %H:%M:%S",lastTeamBalanceCheck,31 )
	calcTeamScores()
	ctStrength = score(CTS)
	tStrength = score(TS)
	ctRating = fdivWorkaround(ctStrength, tStrength)
	tRating = fdivWorkaround(tStrength, ctStrength)
	wtConditions[TS] = 0
	wtConditions[CTS] = 0

	// compare scores for unequal rating scores
	if (teamScores[TS] - teamScores[CTS] > PTB_MAXSCORE && tRating >= PTB_MINRATING)
		wtConditions[TS]++

	if (teamScores[CTS] - teamScores[TS] > PTB_MAXSCORE && ctRating >= PTB_MINRATING)
		wtConditions[CTS]++

	// check streaks for unequal rating scores
	if (winStreaks[TS] > PTB_MAXSTREAK && tRating >= PTB_MINRATING)
		wtConditions[TS]++

	if (winStreaks[CTS] > PTB_MAXSTREAK && ctRating >= PTB_MINRATING)
		wtConditions[CTS]++

	// check ratings
	if (tRating >= PTB_MAXRATING)
		wtConditions[TS]++

	if (ctRating >= PTB_MAXRATING)
		wtConditions[CTS]++


	// check ratings
	if (tRating >= PTB_SUPERRATING)
		wtConditions[TS]++

	if (ctRating >= PTB_SUPERRATING)
		wtConditions[CTS]++


	// check team sizes for unequal ratings
	if (teamCounts[TS] > teamCounts[CTS] && tRating >= PTB_MINRATING)
		wtConditions[TS]++

	if (teamCounts[CTS] > teamCounts[TS] && ctRating >= PTB_MINRATING)
		wtConditions[CTS]++

	// check conditions
	if (wtConditions[TS] >= 2) {
		winnerTeam = TS
		loserTeam = CTS
	}
	else if (wtConditions[CTS] >= 2) {
		winnerTeam = CTS
		loserTeam = TS
	}
	else {
		winnerTeam = 0
		loserTeam = 0
	}
}

manageWtjFile(id) { 
		if (!PTB_SAVEWTJ) return     
		//say("Trying to write wtj.log ....") 
		//if (wtjCount[id] < 4) return 
		//say("wtj.log should be written to now ....") 
		new text[256], mapname[32], name[32], authid[32] 
		get_mapname(mapname,31) 
		get_user_name(id,name,31) 
		get_user_authid(id,authid,31) 
		format(text, 255, "%s <%s> %s", name, authid, mapname) 
		log_to_file("wtj.log", text) 
}  


public menuclass(id) {
	if (!isBeingTransfered[id]) return PLUGIN_CONTINUE
	client_cmd(id,"slot1")
	isBeingTransfered[id] = false
	return PLUGIN_CONTINUE
}

public jointeam(id) {
	new arg[2]
	read_argv(1,arg,1)
	if (isBeingTransfered[id]) return PLUGIN_HANDLED
	return checkTeamSwitch(id,str_to_num(arg)) // team is key pressed + 1
}

public teamselect(id,key) {
	
	return checkTeamSwitch(id,key+1) // team is key pressed + 1
}

checkTeamSwitch(id,iNewTeam) {
	
	// don't care where player joins
	if (!PTB_LIMITJOIN) return PLUGIN_CONTINUE
	// Protection for admins if ptb_limitjoin_immunity 1
	if (get_user_flags(id)&get_immunity_level_flag() && (get_pcvar_num(limitjoin_immunity) == 1)) return PLUGIN_CONTINUE
	// players is transfered so don't care with rest
	if (isBeingTransfered[id]) {
		//say("TRANSFER")
		isBeingTransfered[id] = false
		return PLUGIN_CONTINUE
	}
	//say("NO TRANSFER")
	// skip limiting for a few rounds into the map
	if (PTB_LIMITAFTER && roundCounter <= PTB_LIMITAFTER) return PLUGIN_CONTINUE
	// skip limiting for a small number of players
	if (get_playersnum() < PTB_LIMITMIN) return PLUGIN_CONTINUE

	new iOldTeam = playerTeam[id]
	
	// disallow free team choices in the first rounds of a map
	if (PTB_AUTOROUNDS && (iOldTeam==UNASSIGNED) && roundCounter<=PTB_AUTOROUNDS && !(get_user_flags(id) & ADMIN_KICK))
		iNewTeam = AUTO_TEAM
		
	// prevent unwanted rejoining of the same team ...
	if (iNewTeam == iOldTeam) {
		//say("Preventing rejoining of the same team.")
		client_print(id,print_chat,"PTB: Joining to the same team is not allowed...")
#if !defined MANUAL_SWITCH
		engclient_cmd(id,"chooseteam") // display menu again
#endif
		return PLUGIN_HANDLED
	}
	
	checkTeamBalance()
	//displayStatistics(0,true)

	// Player for sure was in CT or T team and now is joining to the opposite team
	if ((iNewTeam==CTS&&iOldTeam==TS)||(iNewTeam==TS&&iOldTeam==CTS)){
		// If someone is in new team and old team weren't full
		// and the winning team is a destination team or in
		// new team is more players than in old then treat it as wtj
		if ( teamCounts[iNewTeam]&&(teamCounts[iOldTeam]<PTB_MAXSIZE)&&
			((iNewTeam==winnerTeam)||(teamCounts[iNewTeam]>=teamCounts[iOldTeam])) ) {
			// player is wtjing
			new text[256],name[32]
			get_user_name(id,name,31)
			// Kick wtj player if reached set limit
			if (++wtjCount[id] >= PTB_WTJKICK && PTB_KICK) {
				format(text, 255, "PTB: Kicking %s for a WTJ count %d of %d.", name, wtjCount[id],PTB_WTJKICK )
				doTypesay(text, 5, 0, 255, 0)
				say(text)
				server_cmd("kick #%d",get_user_userid(id))
				return PLUGIN_HANDLED
			}
			// Announce about WTJ
			if (PTB_TELLWTJ) {
				if (iNewTeam == CTS) {
					format(text, 255, "PTB: The CTs are strong enough, %s (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)
					doTypesay(text, 5, 0, 50, 255)
				}
				else {
					format(text, 255, "PTB: The Ts are strong enough, %s (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)
					doTypesay(text, 5, 255, 50, 0)
				}
				say(text)
			}
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		// check for maximum team size
		if (teamCounts[iNewTeam] >= PTB_MAXSIZE) {
			client_print(id,print_chat,"PTB: Maximum team size prohibits team change.")
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		// check team size difference limits
		if ( teamCounts[iNewTeam]+1-teamCounts[iOldTeam] >= PTB_MAXDIFF ) {
			client_print(id,print_chat,"PTB: Maximum team size difference prohibits team change.")
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		return PLUGIN_CONTINUE // OK! He can join to the oppsoite team!!!
	}
	
	// Player is choosing his team for the first time!
	if (iNewTeam==CTS||iNewTeam==TS){
		// Get opposite team
		new opposingTeam = (iNewTeam==CTS)? TS : CTS
		// Players is joining to one team but the opposite is not full
		// and his team is bettter then opposite or has more players
		if (teamCounts[iNewTeam] && teamCounts[opposingTeam]<PTB_MAXSIZE &&
				 (iNewTeam==winnerTeam||(!winnerTeam&&teamCounts[iNewTeam]>teamCounts[opposingTeam]))) {
			new text[256],name[32]
			get_user_name(id,name,31)
			if (++wtjCount[id] >= PTB_WTJKICK && PTB_KICK) {
				format(text, 255, "PTB: Kicking %s for a WTJ count %d of %d.", name, wtjCount[id],PTB_WTJKICK)
				doTypesay(text, 5, 0, 255, 0)
				say(text)
				server_cmd("kick #%d", get_user_userid(id))
				return PLUGIN_HANDLED
			}
			if (iNewTeam==CTS) {
				if (wtjCount[id]>=PTB_WTJAUTO && is_user_connected(id)) {
					manageWtjFile(id)
					format(text, 255, "PTB: Forcing %s to the Ts (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)

					engclient_cmd(id,"jointeam","1")

					doTypesay(text, 5, 255, 50, 0)
					say(text)
				}
				else if (PTB_TELLWTJ) {
					format(text, 255, "PTB: The CTs are strong enough, %s (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)
					doTypesay(text, 5, 0, 50, 255)
					say(text)
#if !defined MANUAL_SWITCH
					engclient_cmd(id,"chooseteam") // display menu again
#endif
				}
			}
			else {
				if (wtjCount[id]>=PTB_WTJAUTO) {
					manageWtjFile(id)
					format(text, 255, "PTB: Forcing %s to the CTs (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)

					engclient_cmd(id,"jointeam","2")

					doTypesay(text, 5, 0, 50, 255)
					say(text)
				}
				else if (PTB_TELLWTJ) {
					format(text, 255, "PTB: The Ts are strong enough, %s (WTJ: %d/%d).", name, wtjCount[id],PTB_WTJKICK)
					doTypesay(text, 5, 255, 50, 0)
					say(text)
#if !defined MANUAL_SWITCH
					engclient_cmd(id,"chooseteam") // display menu again
#endif
				}
			}
			return PLUGIN_HANDLED
		}
		// check for maximum team size
		if (teamCounts[iNewTeam] >= PTB_MAXSIZE) {
			client_print(id,print_chat,"PTB: Maximum team size prohibits team join.")
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		// check team size difference limits
		if ( teamCounts[iNewTeam]-teamCounts[opposingTeam] >= PTB_MAXDIFF) {
			client_print(id,print_chat,"PTB: Maximum team size difference prohibits team join.")
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		return PLUGIN_CONTINUE // OK! He can join to the oppsoite team!!!
	}

	// He is choosing the AUTO-SELECT but he was already in game (He wants to play fair!)
	if (iNewTeam==AUTO_TEAM&&(iOldTeam==CTS||iOldTeam==TS)) {
		//say("Changing team automatically.")
		new opposingTeam = (iOldTeam==CTS) ? TS : CTS
		if (teamCounts[opposingTeam] && ( (teamCounts[opposingTeam]>=PTB_MAXSIZE)
				|| (iOldTeam==loserTeam) || (!loserTeam&&teamCounts[iOldTeam]<=teamCounts[opposingTeam])
				|| (teamCounts[opposingTeam]+1-teamCounts[iOldTeam]>=PTB_MAXDIFF)) ) {
			client_print(id,print_chat,"PTB: You have better stay in your current team...")
			return PLUGIN_HANDLED
		}
		client_print(id,print_chat,"PTB: You have been auto-assigned...")

		engclient_cmd(id,"jointeam",(opposingTeam==CTS)?"2":"1")

		return PLUGIN_HANDLED
	}
	// He is choosing the team for the first time with AUTO-SELECT (What a nice kid!)
	if (iNewTeam==AUTO_TEAM) {
		/* this is the "always smaller team" version
		if (teamCounts[CTS] < teamCounts[TS] || teamCounts[TS] >= PTB_MAXSIZE) iNewTeam = CTS
		else if (teamCounts[TS] < teamCounts[CTS] || teamCounts[CTS] >= PTB_MAXSIZE) iNewTeam = TS
		// both teams have same size ...
		else if (winnerTeam && teamCounts[loserTeam]<PTB_MAXSIZE) iNewTeam = loserTeam
		else if (teamCounts[TS] >= PTB_MAXSIZE) iNewTeam = CTS
		else if (teamCounts[CTS] >= PTB_MAXSIZE) iNewTeam = TS
		else iNewTeam = (random_num(0,100) < 50) ? CTS : TS
		*/
		// this version prefers the losing team (but still honors PTB_MAXDIFF)
		if (teamCounts[CTS] >= PTB_MAXSIZE) iNewTeam = TS
		else if (teamCounts[TS] >= PTB_MAXSIZE) iNewTeam = CTS
		else if (teamCounts[CTS]-teamCounts[TS] >= PTB_MAXDIFF) iNewTeam = TS
		else if (teamCounts[TS]-teamCounts[CTS] >= PTB_MAXDIFF) iNewTeam = CTS
		else if (winnerTeam) iNewTeam = loserTeam
		else if (teamCounts[CTS]<teamCounts[TS]) iNewTeam = CTS
		else if (teamCounts[TS]<teamCounts[CTS]) iNewTeam = TS
		// both teams have same size ...
		else iNewTeam = (random_num(0,100) < 50) ? CTS : TS
		// check for maximum team size
		if (teamCounts[iNewTeam]>=PTB_MAXSIZE) {
			client_print(id,print_chat,"PTB: Maximum team size prohibits team join.") // ??? - only a spectator???
#if !defined MANUAL_SWITCH
			engclient_cmd(id,"chooseteam") // display menu again
#endif
			return PLUGIN_HANDLED
		}
		client_print(id,print_chat,"PTB: You have been auto-assigned...")

		engclient_cmd(id,"jointeam",(iNewTeam==CTS)?"2":"1")

		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public team_score(){
	new arg[2]
	read_data(1,arg,1)
	teamScores[ ( arg[0] == 'T' ) ? TS : CTS ] = read_data(2)
}

public win_streaks(param[]){
	new winner = param[0]
	new looser = param[1]
	if (winStreaks[winner] < 0) {
		winStreaks[winner] = 1
		winStreaks[looser] = -1
	}
	else {
		winStreaks[winner]++
		winStreaks[looser]--
	}
	actAtEndOfRound()
}

public round_end(){
	new param[12]
	read_data(2,param,8)
	if (param[7]=='c') {//%!MRAD_ctwin
		param[0] = CTS
		param[1] = TS
	}
	else if (param[7]=='t') {//%!MRAD_terwin
		param[0] = TS
		param[1] = CTS
	}
	else
		return // %!MRAD_rounddraw (both teams have left the game)
	set_task(4.5,"win_streaks",0,param,2)
}

public new_round() {
	//if ( floatround(get_cvar_float("mp_roundtime") * 60.0) != read_data(1) ) return
	if ( floatround(get_cvar_float("mp_roundtime") * 60.0,floatround_floor) != read_data(1) ) return
	++roundCounter
	announceStatus()
}

// Happen only at team select (also auto-join)
public team_join() {
	new arg[32]
	read_data(3,arg,31)
	lastRoundSwitched[ get_user_index(arg) ] = roundCounter
}

// Can happen at begin of round or team select
public team_assign() {
	new arg[2], team
	new i = read_data(1)
	read_data(2,arg,1)
	if ( arg[0] == 'C'  )
		team = CTS
	else if ( arg[0] == 'T' )
		team = TS
	else
		team = UNASSIGNED
	teamCounts[playerTeam[i]]-- // Unregister from old team
	teamCounts[team]++ // Increase ammount in new team
	playerTeam[i] = team // Assign to new
}

public game_restart(){
	roundCounter = 0
	lastSwitchRound = 0
	couldNotSwitchCounter = 0
	teamKills[0] = teamKills[1] = teamKills[2] = 0
	teamDeaths[0] = teamDeaths[1] = teamDeaths[2] = 0
	teamScores[0] = teamScores[1] = teamScores[2] = 0
	winStreaks[0]	= winStreaks[1] = winStreaks[2] = 0
	wtConditions[0] = wtConditions[1] = wtConditions[2] = 0
	validTargetCounts[0] = validTargetCounts[1] = validTargetCounts[2] = 0
	new a = get_maxplayers()
	for (new i = 1; i <= a; ++i){
		kills[i] = 0
		deaths[i] = 0
		wtjCount[i] = 0
		lastRoundSwitched[i] = -999
	}
}

public death_msg(){
	new iWinner = read_data(1)
	new iLoser = read_data(2)
	if ( iWinner < 1 || iWinner > 32 || iLoser < 1 || iLoser > 32 )
		return
	if ( playerTeam[iWinner] == playerTeam[iLoser] )
		return // no TKS!!!
	kills[iWinner]++
	deaths[iLoser]++
	if (PTB_SCALEDOWN <= 1) return
	if (kills[iWinner] + deaths[iWinner] >= PTB_MAXINCIDENTS) {
		kills[iWinner] /= PTB_SCALEDOWN
		deaths[iWinner] /= PTB_SCALEDOWN
	}
	if (kills[iLoser] + deaths[iLoser] >= PTB_MAXINCIDENTS) {
		kills[iLoser] /= PTB_SCALEDOWN
		deaths[iLoser] /= PTB_SCALEDOWN
	}
}

calcTeamScores() {
	teamDeaths[UNASSIGNED] = 0
	teamDeaths[CTS] = 0
	teamDeaths[TS] = 0
	teamKills[UNASSIGNED] = 0
	teamKills[CTS] = 0
	teamKills[TS] = 0

	new team, a = get_maxplayers()
	for (new i = 1; i <= a; ++i) {
		team = playerTeam[i]
		teamKills[team] += kills[i]
		teamDeaths[team] += deaths[i]
	}

	ctKD = fdivWorkaround(float(teamKills[CTS]), float(teamDeaths[CTS]))
	tKD = fdivWorkaround(float(teamKills[TS]), float(teamDeaths[TS]))
}

announceStatus() {
	if (!PTB_ANNOUNCE) return
	checkTeamBalance()
	new text[256]
	if (winnerTeam == TS) {
		format(text, 255, "PTB: The COUNTER-TERRORIST team could use some support.")
		doTypesay(text, 5, 0, 50, 255)
		say("PTB: The COUNTER-TERRORIST team could use some support.")
	}
	else if (winnerTeam == CTS) {
		format(text, 255, "PTB: The TERRORIST team could use some support.")
		doTypesay(text, 5, 255, 50, 0)
		say("PTB: The TERRORIST team could use some support.")
	}
	else if (wtConditions[TS] > wtConditions[CTS]) {
		format(text, 255, "PTB: Observing TERRORIST team advantage.")
		doTypesay(text, 5, 255, 50, 0)
		say("PTB: Observing TERRORIST team advantage.")
	}
	else if (wtConditions[CTS] > wtConditions[TS]) {
		format(text, 255, "PTB: Observing COUNTER-TERRORIST team advantage.")
		doTypesay(text, 5, 0, 50, 255)
		say("PTB: Observing COUNTER-TERRORIST team advantage.")
	}
	else if (PTB_SAYOK) {
		format(text, 255, "PTB: Teams look fine, no action required.")
		doTypesay(text, 5, 200, 100, 0)
		say("PTB: Teams look fine, no action required.")
	}
}

public admin_ptb(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	new cmd[32], arg[32], lastcmd

	if ( read_argv(1,cmd,31) == 0 ) { // no command - plain amx_ptb
		//console_print(id,"PTB: Ptahhotep's Team Balancer %s", PTB_VERSION)
		//console_print(id,"PTB: (ptahhotep@planethalflife.com)")
		checkTeamBalance()
		displayStatistics(id)
		return PLUGIN_HANDLED
	}
	if (equali(cmd, "on") || equal(cmd, "1")) {
		PTB_LIMITJOIN = true
		PTB_SWITCH = true
		PTB_ANNOUNCE = true
		console_print(id,"PTB: Enabled all PTB actions.")
		return PLUGIN_HANDLED
	}
	if (equali(cmd, "off") || equal(cmd, "0")) {
		PTB_SWITCH = false
		PTB_ANNOUNCE = false
		PTB_LIMITJOIN = false
		console_print(id,"PTB: Disabled all PTB actions.")
		return PLUGIN_HANDLED
	}
	if (equal(cmd, "list") || equal(cmd, "help")) {
		console_print(id,"PTB: Available Commands:")
		console_print(id,"PTB: Team Join Control: ^"limitjoin^", ^"limitafter^", ^"limitmin^", ^"maxsize^", ^"autorounds^",")
		console_print(id,"PTB: ^"maxdiff^", ^"wtjauto^", ^"wtjkick^", ^"kick^", ^"savewtj^"")
		console_print(id,"PTB: Team Balancing Actions: ^"switch^", ^"switchafter^", ^"switchmin^", ^"switchfreq^", ^"playerfreq^",")
		console_print(id,"PTB: ^"forceswitch^", ^"deadonly^"")
		console_print(id,"PTB: Team Strength Limits: ^"maxstreak^", ^"maxscore^", ^"minrating^", ^"maxrating^", ^"superrating^"")
		console_print(id,"PTB: Messages: ^"tellwtj^", ^"announce^", ^"sayok^", ^"typesay^"")
		console_print(id,"PTB: Misc: ^"^", ^"status^", ^"list^", ^"help^", ^"on^", ^"off^", ^"save^", ^"load^"")
		console_print(id,"PTB: To view all PTB settings, type ^"amx_ptb status^".")
		console_print(id,"PTB: To view or change a single PTB setting, type ^"amx_ptb <setting> <on|off|value>^".")
		console_print(id,"PTB: For PTB statistics, simply type ^"amx_ptb^".")
		return PLUGIN_HANDLED
	}
	new arglen = read_argv(2,arg,31)
	new status = equal(cmd, "status")

	// team selection control
	if ( status ) console_print(id,"PTB: ---------- Team Selection Control ----------")
	
	// PTB_LIMITJOIN
	if ( (lastcmd = equal(cmd, "limitjoin")) && arglen ) PTB_LIMITJOIN = check_param_bool(arg)
	if ( status ||  lastcmd )	console_print(id,"PTB: (limitjoin) WTJ prevention is %s.", PTB_LIMITJOIN ? "ON" : "OFF")

	// PTB_LIMITAFTER
	if ( (lastcmd = equal(cmd, "limitafter")) && arglen )	PTB_LIMITAFTER = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id,"PTB: (limitafter) Team limiting starts after %d round(s).", PTB_LIMITAFTER)

	// PTB_LIMITMIN
	if ( (lastcmd = equal(cmd, "limitmin")) && arglen ) PTB_LIMITMIN = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id,"PTB: (limitmin) Team limiting needs at least %d player(s).", PTB_LIMITMIN)

	// PTB_MAXSIZE
	if ( (lastcmd = equal(cmd, "maxsize")) && arglen ) 	PTB_MAXSIZE = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id,"PTB: (maxsize) Maximum team size is %d player(s).", PTB_MAXSIZE)

	// PTB_MAXDIFF
	if ( (lastcmd = equal(cmd, "maxdiff")) && arglen ) PTB_MAXDIFF = check_param_num(arg,1)
	if ( status || lastcmd )	console_print(id,"PTB: (maxdiff) Maximum team size difference is %d.", PTB_MAXDIFF)

	// PTB_AUTOROUNDS
	if ( (lastcmd = equal(cmd, "autorounds")) && arglen )	PTB_AUTOROUNDS = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id, "PTB: (autorounds) First %d rounds no free team choice.", PTB_AUTOROUNDS)

	// PTB_WTJAUTO
	if ( (lastcmd = equal(cmd, "wtjauto")) && arglen )	PTB_WTJAUTO = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id,"PTB: (wtjauto) Auto-joining WTJ after %d tr(y/ies).", PTB_WTJAUTO)

	// PTB_WTJKICK
	if ( (lastcmd = equal(cmd, "wtjkick")) && arglen ) PTB_WTJKICK = check_param_num(arg,1)
	if ( status || lastcmd )	console_print(id,"PTB: (wtjauto) Auto-kicking WTJ after %d tr(y/ies).", PTB_WTJKICK)

	// PTB_KICK
	if ( (lastcmd = equal(cmd, "kick")) && arglen ) PTB_KICK = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (kick) WTJ kicking is %s.", PTB_KICK ? "ON" : "OFF" )

	// PTB_SAVEWTJ
	if (  (lastcmd = equal(cmd, "savewtj")) && arglen ) PTB_SAVEWTJ = check_param_bool(arg)
	if ( status || lastcmd ) 	console_print(id,"PTB: (savewtj) Saving to wtj.log is %s.", PTB_SAVEWTJ ? "ON" : "OFF");

	// team balancing actions
	if ( status ) console_print(id,"PTB: ---------- Team Balancing Actions ----------")

	// PTB_SWITCH
	if ( (lastcmd = equal(cmd, "switch")) && arglen ) PTB_SWITCH = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (switch) Team switching is %s.", PTB_SWITCH ? "ON" : "OFF")

	// PTB_SWITCHAFTER
	if ( (lastcmd = equal(cmd, "switchafter")) && arglen ) PTB_SWITCHAFTER = check_param_num(arg,0)
	if ( status || lastcmd ) console_print(id,"PTB: (switchafter) Switching starts after %d round(s).", PTB_SWITCHAFTER)

	// PTB_SWITCHMIN
	if ( (lastcmd = equal(cmd, "switchmin")) && arglen ) PTB_SWITCHMIN = check_param_num(arg,0)
	if ( status || lastcmd ) console_print(id,"PTB: (switchmin) Switching needs at least %d player(s).", PTB_SWITCHMIN)

	// PTB_PLAYERFREQ
	if ( (lastcmd = equal(cmd, "playerfreq")) && arglen )	PTB_PLAYERFREQ = check_param_num(arg,0)
	if ( status || lastcmd )	console_print(id,"PTB: (playerfreq) Individual players are switched every %d round(s) at maximum.", PTB_PLAYERFREQ)

	// PTB_SWITCHFREQ
	if (  (lastcmd = equal(cmd, "switchfreq")) && arglen )	PTB_SWITCHFREQ = check_param_num(arg,1)
	if ( status || lastcmd )	console_print(id,"PTB: (switchfreq) Switch occurs every %d round(s) at maximum.", PTB_SWITCHFREQ)

	// PTB_FORCESWITCH
	if ( (lastcmd = equal(cmd, "forceswitch")) && arglen )	PTB_FORCESWITCH = check_param_num(arg,0)
	if ( status || lastcmd ) console_print(id,"PTB: (forceswitch) Forcing switch after %d unsuccessful switch(es).", PTB_FORCESWITCH)

	// PTB_DEADONLY
	if ( (lastcmd =  equal(cmd, "deadonly")) && arglen ) 	PTB_DEADONLY = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (deadonly) Switching dead only is %s.",PTB_DEADONLY ? "ON" : "OFF" )

	// messages
	if ( status ) console_print(id,"PTB: ---------- Messages ----------")

	// PTB_TELLWTJ
	if ( (lastcmd =  equal(cmd, "tellwtj")) && arglen ) PTB_TELLWTJ = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (tellwtj) Telling about WTJ tries is %s.",PTB_TELLWTJ ? "ON" : "OFF")

	// PTB_ANNOUNCE
	if ( (lastcmd = equal(cmd, "announce")) && arglen ) PTB_ANNOUNCE = check_param_bool(arg)
	if ( status || lastcmd )  console_print(id,"PTB: (announce) Announcements are %s.",PTB_ANNOUNCE ? "ON" : "OFF")

	// PTB_SAYOK
	if ( (lastcmd = equal(cmd, "sayok")) && arglen ) PTB_SAYOK = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (sayok) ^"OK^" announcements are %s.",PTB_SAYOK ? "ON" : "OFF")

	// PTB_TYPESAY
	if ( (lastcmd = equal(cmd, "typesay")) && arglen ) PTB_TYPESAY = check_param_bool(arg)
	if ( status || lastcmd ) console_print(id,"PTB: (typesay) typesay usage is %s.",PTB_TYPESAY ? "ON" : "OFF")

	// team strength limits
	if ( status ) console_print(id,"PTB: ---------- Team Strength Limits ----------")

	// PTB_MAXSTREAK
	if ( (lastcmd = equal(cmd, "maxstreak")) && arglen ) PTB_MAXSTREAK = check_param_num(arg,1)
	if ( status || lastcmd )	console_print(id,"PTB: (maxstreak) Maximum accepted win streak is %d.", PTB_MAXSTREAK)

	// PTB_MAXSCORE
	if ( (lastcmd = equal(cmd, "maxscore")) && arglen )	PTB_MAXSCORE = check_param_num(arg,1)
	if ( status || lastcmd ) console_print(id,"PTB: (maxscore) Maximum accepted team score difference is %d.", PTB_MAXSCORE)

	// PTB_MINRATING
	if ( (lastcmd = equal(cmd, "minrating")) && arglen ) PTB_MINRATING = check_param_float(arg,1.0)
	if ( status || lastcmd ) 	console_print(id,"PTB: (minrating) Minimum critical strength rating is %.2f.",PTB_MINRATING)

	// PTB_MAXRATING
	if ( (lastcmd = equal(cmd, "maxrating")) && arglen ) PTB_MAXRATING = check_param_float(arg,1.0)
	if ( status || lastcmd ) 	console_print(id,"PTB: (maxrating) Maximum critical strength rating is %.2f.",PTB_MAXRATING)

	// PTB_SUPERRATING
	if ( (lastcmd = equal(cmd, "superrating")) && arglen ) PTB_SUPERRATING = check_param_float(arg,1.0)
	if ( status || lastcmd ) 	console_print(id,"PTB: (superrating) Super critical strength rating is %.2f.",PTB_SUPERRATING)

	// PTB_MAXINCIDENTS
	if ( (lastcmd = equal(cmd, "maxincidents")) && arglen )	PTB_MAXINCIDENTS = check_param_num(arg,1)
	if ( status || lastcmd ) 	console_print(id,"PTB: (maxincidents) Maximum incidents before internal player score scale down is %d.", PTB_MAXINCIDENTS)

	// PTB_SCALEDOWN
	if ( (lastcmd =  equal(cmd, "scaledown")) && arglen )	PTB_SCALEDOWN = check_param_num(arg,1)
	if ( status || lastcmd ) 	console_print(id,"PTB: (scaledown) Integer scale down factor for player scores is %d.", PTB_SCALEDOWN)

	// misc
	if ( status ) {
		console_print(id,"PTB: ---------- Misc ----------")
		console_print(id,"PTB: To enable or disable PTB, type ^"admin_ptb <on|1|off|0>^".")
		console_print(id,"PTB: To view or change a single PTB setting, type ^"amx_ptb <setting> <on|off|value>^".")
		console_print(id,"PTB: To view a brief overview of PTB commands, type ^"amx_ptb help^" or ^"amx_ptb list^".")
		console_print(id,"PTB: For PTB statistics, simply type ^"amx_ptb^".")
	}

	return PLUGIN_HANDLED
}

stock displayStatistics(id,bool:toLog = false) {
	//say("displayStatistics")
	new text[256]
	// time
	/*format(text, 255, "PTB: Statistics generated at: %s", lastTeamBalanceCheck)
	if (toLog) log_amx(text)
	console_print(id,text)*/
	// connected players
	format(text, 255, "PTB: Connected players: %d", get_playersnum())
	if (toLog) log_amx(text)
	console_print(id,text)
	// team sizes
	format(text, 255, "PTB: Team sizes: CTs %d, Ts %d", teamCounts[CTS], teamCounts[TS])
	if (toLog) log_amx(text)
	console_print(id,text)
	// team scores
	format(text, 255, "PTB: Team scores: CTs %d, Ts %d", teamScores[CTS], teamScores[TS])
	if (toLog) log_amx(text)
	console_print(id,text)
	// Kills:Deaths
	format(text, 255, "PTB: Team kills:deaths: CTs %d:%d, Ts %d:%d", teamKills[CTS], teamDeaths[CTS], teamKills[TS], teamDeaths[TS])
	if (toLog) log_amx(text)
	console_print(id,text)
	// Kills/Deaths
	format(text, 255, "PTB: Team kills/deaths: CTs %.2f, Ts %.2f", ctKD , tKD	)
	if (toLog) log_amx(text)
	console_print(id,text)
	// strength
	format(text, 255, "PTB: Team strengths: CTs %.2f, Ts %.2f",ctStrength , tStrength	)
	if (toLog) log_amx(text)
	console_print(id,text)
	// rating
	format(text, 255, "PTB: Team ratings: CTs %.2f, Ts %.2f",ctRating,tRating	)
	if (toLog) log_amx(text)
	console_print(id,text)
	// won rounds
	if (winStreaks[CTS] > 0) {
		format(text, 255, "PTB: Last %d round(s) won by CTs.", winStreaks[CTS])
		if (toLog) log_amx(text)
		console_print(id,text)
	}
	else if (winStreaks[TS] > 0) {
		format(text, 255, "PTB: Last %d round(s) won by Ts.", winStreaks[TS])
		if (toLog) log_amx(text)
		console_print(id,text)
	}

	// winning team
	switch(winnerTeam){
		case CTS: format(text, 255, "PTB: The CTs are the winning team.")
		case TS: format(text, 255, "PTB: The Ts are the winning team.")
		default: format(text, 255, "PTB: Teams are balanced.")
	}
	if (toLog) log_amx(text)
	console_print(id,text)

	/*format(text, 255, "PTB: These statistics might be already outdated.")
	if (toLog) log_amx(text)
	console_print(id,text)

	format(text, 255, "PTB: To view a brief overview of PTB commands, type ^"amx_ptb help^" or ^"amx_ptb list^".")
	if (toLog) log_amx(text)
	console_print(id,text)

	format(text, 255, "PTB: To view all PTB settings, type ^"amx_ptb status^".")
	if (toLog) log_amx(text)
	console_print(id,text)*/
}

public client_connect(id){
	kills[id] = 0
	deaths[id] = 0
	isBeingTransfered[id] = false
	playerTeam[id] = UNASSIGNED
	lastRoundSwitched[id] = -999
	wtjCount[id] = 0
	get_user_info(id,"_vgui_menus",clientVGUIMenu[id],1)
	clientVGUIMenu[id][0] = '0'

	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	kills[id] = 0
	deaths[id] = 0
	isBeingTransfered[id] = false
	playerTeam[id] = UNASSIGNED
	lastRoundSwitched[id] = -999
	wtjCount[id] = 0
	// redundant team size check
	teamCounts[UNASSIGNED] = 0
	teamCounts[CTS] = 0
	teamCounts[TS] = 0

	new a = get_maxplayers()
	for (new i = 1; i <= a; ++i)
		++teamCounts[playerTeam[i]]


	if (clientVGUIMenu[id][0] != '0') {
		set_user_info( id, "_vgui_menus", clientVGUIMenu[id] )
		clientVGUIMenu[id][0] = '0'
	}

	return PLUGIN_CONTINUE
}

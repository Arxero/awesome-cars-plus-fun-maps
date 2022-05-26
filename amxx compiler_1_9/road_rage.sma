/*
	This plugin allows players to start a vote for one or many rounds with knife and bunny hop.
    During roadrage round they can't take weapons from ground or buy also old ones are removed.
*/

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <engine>
#include <amxmisc>
#include <colorchat>

#define VERSION	"0.2"
#define PLUGIN "Roadrage"
#define AUTHOR "Maverick"

enum(+=100) {
	TASK_STRIP = 100,
	TASK_BACK
}

new yes = 0;
new no = 0;

new voteDelay;
new voteTime;
new isRoadRageOneRound;

new const tag[] = "[^1AMXX^4]^1";
new const rrTag[] = "^3Roadrage^1";
new const soundStartVote[] = "buttons/bell1.wav";
new const soundVoteSuccess[] = "sank_sounds/woo.wav";
new const soundVoteFail[] = "buttons/button10.wav";
new const soundStartRr[] = "misc/bipbip.wav";

new bool:isVoting = false;
new bool:isAllowedToVoteAgain = true;
new voteInitiator[64];
new bool:isRoadRageOn = false;
new bool:isRoadRageInProgress = false;
new bool:isRoadRageEndInitiated = false;

new const g_szMaps[][] =
{
	"most_wanted",
	"most_wanteD2",
	"fun_atraccions",
	"fun_box",
	"awesome_cars",
	"awesome_cars2",
	"nojarq_fun_zone",
	"fun_cars",
	"woohoo_cars",
	"he_offroad",
	"happyvalley_2nd_lt",
	"he_glass"
};

public plugin_precache() {
	precache_sound(soundStartVote);
	precache_sound(soundVoteSuccess);
	precache_sound(soundVoteFail);
	precache_sound(soundStartRr);
}

public plugin_init() {
    register_plugin( PLUGIN, VERSION, AUTHOR );

    // clcmds
    register_clcmd( "say /startrr", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );
    register_clcmd( "startrr", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );
    register_clcmd( "say /endrr", "EndRoadrage", ADMIN_ALL, "Starts a vote to end Roadrage mode" );
    register_clcmd( "endrr", "EndRoadrage", ADMIN_ALL, "Starts a vote to end Roadrage mode" );

    //Events
    register_event("HLTV","event_round_start","a","1=0","2=0");
	register_logevent("event_round_end", 2 ,"1=Round_End");
    register_event("CurWeapon","disarm","be","1=1");

    //CVARS
    voteDelay = register_cvar("rr_vote_delay","10.0");
    voteTime = register_cvar("rr_vote_time","5.0");
    isRoadRageOneRound = register_cvar("rr_one_round", "0");
}

public StartVote(id) {
    if (isVoting) {
        ColorChat(id, GREEN, "%s There is already a vote in progress started by ^3%s", tag, voteInitiator);
        return PLUGIN_HANDLED;
    } else if (!isAllowedToVoteAgain) {
        client_cmd(0, "speak ^"sound/%s^"", soundVoteFail);
        ColorChat(id, GREEN, "%s Not allowed to vote so soon again, wait ^4%d ^1seconds!", tag, get_pcvar_num(voteDelay));
        return PLUGIN_HANDLED;
    }
    
    if (isRoadRageInProgress && !isRoadRageEndInitiated) {
        ColorChat(id, GREEN, "%s %s is already in progress", tag, rrTag);
        return PLUGIN_HANDLED;
    }

    yes = no = 0;
    isVoting = true;
    isAllowedToVoteAgain = false;
    get_user_name(id, voteInitiator, 63);
    new g_menu

    if (isRoadRageEndInitiated) {
        ColorChat(0, GREEN, "%s A vote to end %s has been started by ^4%s", tag, rrTag, voteInitiator);
        g_menu = menu_create("Disable Roadrage mode?", "menu_handler");
    } else {
        ColorChat(0, GREEN, "%s A vote for %s has been started by ^4%s", tag, rrTag, voteInitiator);
        g_menu = menu_create("Enable Roadrage mode?", "menu_handler");
    }

    menu_additem(g_menu, "Yes", "1", 0);
    menu_additem(g_menu, "No", "2", 0);

    new players[32], pnum, tempId;
    get_players(players, pnum);

    for (new i = 0; i < pnum; i++) {
        tempId = players[i]; 
        client_cmd(tempId, "speak ^"sound/%s^"", soundStartVote);
        menu_display(tempId, g_menu, 0);
    }

    set_task(get_pcvar_float(voteDelay),"allow_to_vote_again");
    new menuParam[1];
    menuParam[0] = g_menu;
    set_task(get_pcvar_float(voteTime), "EndVote", 0, menuParam);
    return PLUGIN_HANDLED;
}

public EndVote(params[]) {
    ColorChat(0, GREEN, "%s Results from the vote: ^4%d - Yes ^1vs ^4%d - No", tag, yes, no);
    
    if (yes > no) {
        client_cmd(0, "speak ^"sound/%s^"", soundVoteSuccess);

        if (isRoadRageEndInitiated) {
            ColorChat(0, GREEN, "%s Due to the result of the vote, %s will be disabled next round", tag, rrTag);
            isRoadRageOn = false;
        } else {
            ColorChat(0, GREEN, "%s Due to the result of the vote, the next round/s will be %s", tag, rrTag);
            isRoadRageOn = true;
        }
    } else {
        client_cmd(0, "speak ^"sound/%s^"", soundVoteFail);
        ColorChat(0, GREEN, "%s Not enough ^4Yes ^1votes were cast for the vote to succeed", tag);
    }

    isVoting = false;
    voteInitiator = "";
    show_menu(0, 0, "^n", 1);
    menu_destroy(params[0]);
}

// handle menu click results
public menu_handler(id, menu, item) {
    new s_Data[6], s_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);  
    
    new key = str_to_num(s_Data);

    switch (key) {
		case 1: yes++;
		case 2: no++;
	}

    isVoting = false;
    return PLUGIN_HANDLED;
}

public allow_to_vote_again() {
	isAllowedToVoteAgain = true;
	return PLUGIN_HANDLED;
}

public event_round_start() {
    if (isRoadRageOn) {
        ColorChat(0, GREEN, "%s %s has started. Enjoy ^4no weapons ^1and ^4bunny hop^1! Say ^3/endrr ^1to end it.", tag, rrTag);
        client_cmd(0, "speak ^"sound/%s^"", soundStartRr);
        isRoadRageInProgress = true;
    }

    new players[32], pnum, id; 
    get_players(players, pnum); 

    for (new i = 0; i < pnum; i++) {
        id = players[i];

        if (task_exists(id+TASK_STRIP)) {
            // not removing the task cause grenades need to be replenished every round start
			// remove_task(id+TASK_STRIP);
		}

        if (task_exists(id+TASK_BACK)) {
			remove_task(id+TASK_BACK);
		}

        if (is_user_alive(id)) {
            if (isRoadRageOn) {
                set_task(1.2,"strip", id+TASK_STRIP);
            } else {
                set_task(1.0, "back_item", id+TASK_BACK);
            }
        }
    }

    return PLUGIN_CONTINUE;
}

public event_round_end() {
    if (isRoadRageInProgress && get_pcvar_num(isRoadRageOneRound)) {
        isRoadRageInProgress = false;
        // need to set this here because no one would make it false (disable) if its just one round
        isRoadRageOn = false;
    }

    // here we don't need to set isRoadRageOn because it will be set by the vote for EndRoadrage
    if (!isRoadRageOn && isRoadRageInProgress && isRoadRageEndInitiated) {
        isRoadRageInProgress = false;
        isRoadRageEndInitiated = false;
    }
}

// user started vote to end Roadrage mode
public EndRoadrage(id) {
    if (isRoadRageInProgress) {
        if (get_pcvar_num(isRoadRageOneRound)) {
            ColorChat(0, GREEN, "%s Can't vote to disable %s when its only for one round", tag, rrTag);
        } else {
            isRoadRageEndInitiated = true;
            StartVote(id);
        }
    }
}

// give user pistor according to their team after roadrage ends
public back_item(id) {
    id-=TASK_BACK;
    give_item(id, "weapon_knife");

    new szMap[32], bool:isKnifeMap
	get_mapname(szMap, charsmax(szMap))

	for(new i; i < sizeof(g_szMaps); i++)
	{
		if(equali(szMap, g_szMaps[i]))
		{
			isKnifeMap = true;
			break;
		}
	}

	if (isKnifeMap) {
		return;
	}

    give_vip_items(id);

    new CsTeams:current_team = cs_get_user_team(id);
	switch(current_team){
		case CS_TEAM_CT: {
			give_item(id,"weapon_usp");
			cs_set_user_bpammo(id, CSW_USP, 100);
		}
		case CS_TEAM_T: {
			give_item(id,"weapon_glock18");
			cs_set_user_bpammo(id, CSW_GLOCK18, 120);
		}
	}
}

// remove user weapons, but give him the VIP items if he is VIP
public strip(id) {
    id-=TASK_STRIP;
    strip_user_weapons(id);
    give_item(id,"weapon_knife");
    give_vip_items(id);

    give_item(id, "weapon_hegrenade");
    cs_set_user_bpammo(id, CSW_HEGRENADE, 50);
    give_item(id, "weapon_smokegrenade");
    cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 50);
}

public give_vip_items(id) {
    if (get_user_flags(id) & ADMIN_RESERVATION) {
        cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	    give_item(id, "weapon_hegrenade");
	    give_item(id, "weapon_flashbang");
	    cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	    give_item(id, "weapon_smokegrenade");
    }
}

// restrict use to buy weapons during roadrage
public CS_OnBuyAttempt(id) {
    if (isRoadRageInProgress) {        
	    client_print(id, print_center, "Buying weapons is not allowed during Roadage mode");
	    return PLUGIN_HANDLED;
    }

    return PLUGIN_CONTINUE;
}

// restrict user from getting any weapon from ground during roadrage
public disarm(id) {
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

	new weaponid, ammo, wep;
    new weaponName[32];

	weaponid = get_user_weapon(id, wep, ammo);
    get_weaponname(weaponid, weaponName, 31);
    new bool:isWepAllowed = equal(weaponName, "weapon_knife") || equal(weaponName, "weapon_smokegrenade") || equal(weaponName, "weapon_flashbang") || equal(weaponName, "weapon_hegrenade");
	
    if (task_exists(id+TASK_STRIP)) {
		// remove_task(id+TASK_STRIP);
	}

	if (isRoadRageInProgress && !isWepAllowed) {
		client_print(id, print_center, "Can't pick up weapons during Roadage mode");
		new params[2];
		params[0] = id;
		params[1] = weaponName[31];
        set_task(0.5,"strip", id+TASK_STRIP);
        // this for some odd reason crashes the server, therefore stip is used as an alternative
		// set_task(0.3,"drop_weapon", 0, params, 2, "a", 1);	
	}
	
	return PLUGIN_CONTINUE;
}

public drop_weapon(params[], id) {
	engclient_cmd(params[0], "drop", params[1]);
	
    return PLUGIN_HANDLED;
}

// add bunny hop during roadrage
public client_PreThink(id) {
	entity_set_float(id, EV_FL_fuser2, 0.0);

	if (isRoadRageInProgress && entity_get_int(id, EV_INT_button) & IN_JUMP) {
		new iFlags = entity_get_int(id, EV_INT_flags);

		if(iFlags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2 || !(iFlags & FL_ONGROUND)) {
			return;
        }

		new Float:fVelocity[3];
		entity_get_vector(id, EV_VEC_velocity, fVelocity);
		fVelocity[2] += 250.0;
		entity_set_vector(id, EV_VEC_velocity, fVelocity);
		entity_set_int(id, EV_INT_gaitsequence, 6);
	}
}

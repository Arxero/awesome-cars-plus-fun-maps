#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define VERSION	"0.1"
#define PLUGIN "Road Rage"
#define AUTHOR "Maverick"

new yes = 0;
new no = 0;

new voteDelay
new voteTime;

new gVoteMenu;

new bool:isVoting = false;
new bool:isAllowedToVoteAgain = true;
new voteInitiator[64];
new bool:isRoadRage = false;
new bool:isRoadRageInProgress = false;
new bool:isRoadRageOneRound = true;
new bool:isRoadRageEndInitiated = false;

new const tag[] = "[^1AMXX^4]^1";


public plugin_init() {
    register_plugin( PLUGIN, VERSION, AUTHOR );
    register_clcmd( "say /startrr", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );
    register_clcmd( "startrr", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );

    register_clcmd( "say /endrr", "EndRoadrage", ADMIN_ALL, "Starts a vote to end Roadrage mode" );
    register_clcmd( "endrr", "EndRoadrage", ADMIN_ALL, "Starts a vote to end Roadrage mode" );

    //Events
    register_event("HLTV","event_round_start","a","1=0","2=0");
	register_logevent("event_round_end", 2 ,"1=Round_End");
    register_event("CurWeapon","disarm","be","1=1");

    //CVARS
    voteDelay = register_cvar("RR_Vote_Delay","10.0");
    voteTime = register_cvar("RR_Vote_Time","5.0");
}

public StartVote(id) {
    if (isVoting) {
        ColorChat(0, GREEN, "%s There is already a vote in progress started by ^3%s", tag, voteInitiator);
        return PLUGIN_HANDLED;
    } else if (!isAllowedToVoteAgain) {
        ColorChat(0, GREEN, "%s Not allowed to vote so soon again", tag);
        return PLUGIN_HANDLED;
    }
    
    if (isRoadRageInProgress && !isRoadRageEndInitiated) {
        ColorChat(0, GREEN, "%s Roadrage is already in progress", tag);
        return PLUGIN_HANDLED;
    }

    yes = no = 0;
    isVoting = true;
    isAllowedToVoteAgain = false;
    get_user_name(id, voteInitiator, 63);

    if (isRoadRageEndInitiated) {
        ColorChat(0, GREEN, "%s A vote to end Roadrage has been started by ^3%s", tag, voteInitiator);
        gVoteMenu = menu_create("Disable Roadrage mode?", "menu_handler");
    } else {
        ColorChat(0, GREEN, "%s A vote for Roadrage has been started by ^3%s", tag, voteInitiator);
        gVoteMenu = menu_create("Enable Roadrage mode?", "menu_handler");
    }

    menu_additem(gVoteMenu, "Yes", "1", 0);
    menu_additem(gVoteMenu, "No", "2", 0);

    new players[32], pnum, tempId; 
    get_players(players, pnum); 

    for (new i = 0; i < pnum; i++) {
        tempId = players[i]; 
        menu_display(tempId, gVoteMenu, 0);
    }

    set_task(get_pcvar_float(voteDelay),"allow_to_vote_again");
    set_task(get_pcvar_float(voteTime), "EndVote");
    return PLUGIN_HANDLED;
}

public EndVote() {
    ColorChat(0, GREEN, "%s Results from the vote: ^4%d - Yes ^1vs ^4%d - No", tag, yes, no);
    
    if (yes > no) {
        ColorChat(0, GREEN, "%s Due to the result of the vote, the next round/s will be Roadrage", tag);
        isRoadRage = true;
    } else {
        ColorChat(0, GREEN, "%s Not enough ^4Yes ^1votes were cast for the vote to succeed", tag);
    }

    // client_print(0, print_console, "[AMXX] Votes yes: [ %d ]", yes);
    // client_print(0, print_console, "[AMXX] Votes no: [ %d ]", no);

    isVoting = false;
    voteInitiator = "";
    isRoadRageEndInitiated = false;
    show_menu(0, 0, "^n", 1);
    menu_destroy(gVoteMenu);
}

public menu_handler(id, menu, item) {
    new s_Data[6], s_Name[64], i_Access, i_Callback;
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);  
    
    new key = str_to_num(s_Data);

    switch (key) {
		case 1: yes++;
		case 2: no++;
	}

    isVoting = false;
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public allow_to_vote_again() {
	isAllowedToVoteAgain = true;
	return PLUGIN_HANDLED;
}

public event_round_start() {
    if (!isRoadRage) {
        return PLUGIN_HANDLED;
    }

    ColorChat(0, GREEN, "%s Roadrage has started. Enjoy ^4no weapons ^1and ^4bunny hop^1!", tag);
    isRoadRageInProgress = true;

    new players[32], pnum, id; 
    get_players(players, pnum); 

    for (new i = 0; i < pnum; i++) {
        id = players[i];
        set_task(0.1,"strip", id);
    }

    return PLUGIN_CONTINUE;
}

public event_round_end() {
    if (isRoadRage && isRoadRageInProgress && isRoadRageOneRound) {
        isRoadRage = false;
        isRoadRageInProgress = false;
    }
}

public EndRoadrage(id) {
    if (isRoadRage && isRoadRageInProgress && !isRoadRageOneRound) {
        isRoadRageEndInitiated = true;
        StartVote(id)
    }
}

// remove user weapons, but give him the VIP items if he is VIP
public strip(id) {
    strip_user_weapons(id)
    give_item(id,"weapon_knife");
 
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
    if (isRoadRage && isRoadRageInProgress) {        
	    client_print(id, print_center, "Buying weapons is not allowed during Roadage mode")
	    return PLUGIN_HANDLED;
    }

    return PLUGIN_CONTINUE;
}

// restrict use from getting any weapon from ground during roadrage
public disarm(id) {
	new weaponid, ammo, wep;
    new weaponName[32];

	weaponid = get_user_weapon(id, wep, ammo);
    get_weaponname(weaponid, weaponName, 31);
    new bool:isWepAllowed = equal(weaponName, "weapon_knife") || equal(weaponName, "weapon_smokegrenade") || equal(weaponName, "weapon_flashbang") || equal(weaponName, "weapon_hegrenade");
	
	if (isRoadRage && isRoadRageInProgress && !isWepAllowed) {
		client_print(id, print_center, "Can't pick up weapons during Roadage mode");
		new params[2];
		params[0] = id;
		params[1] = weaponName[31];
		set_task(0.2,"drop_weapon", 0, params, 2, "a", 1);	
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

	if (isRoadRage && isRoadRageInProgress && entity_get_int(id, EV_INT_button) & IN_JUMP) {
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

// public remover_entities_from_ground() {
//     new const g_szEntities[][] = { "player_weaponstrip", "game_player_equip", "armoury_entity" }

//     if (isRoadRage && isRoadRageInProgress) {        
//         for(new i, iEnt = -1; i < sizeof(g_szEntities); i++) {
// 	        iEnt = -1;
    
// 	        while((iEnt = find_ent_by_class(iEnt, g_szEntities[i])) > 0) {
// 	        	remove_entity(iEnt);
//             }
// 	    }
//     }
// }

// RegisterHam( Ham_Spawn, "weaponbox", "FwdSpawnWeaponbox", 1 );
// removes weapons drop
// public FwdSpawnWeaponbox( iEntity ) {
//     if (isRoadRage) {
//         set_pev( iEntity, pev_flags, FL_KILLME );
// 	    dllfunc( DLLFunc_Think, iEntity );
//     }

// 	return HAM_IGNORED;
// }

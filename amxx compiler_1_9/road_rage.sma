#include <amxmodx>
#include <amxmisc>
#include <colorchat>

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

new const tag[] = "[^1AMXX^4]";


public plugin_init() {
    register_plugin( PLUGIN, VERSION, AUTHOR );
    register_clcmd( "say /rr2", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );
    register_clcmd( "rr2", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );

    voteDelay = register_cvar("RR_Vote_Delay","10.0");
    voteTime = register_cvar("RR_Vote_Time","5.0");
}

public StartVote(id) {
    if (isVoting) {
        ColorChat(0, GREEN, "%s ^1There is already a vote going started by ^3%s", tag, voteInitiator);
        return PLUGIN_HANDLED;
    } else if (!isAllowedToVoteAgain) {
        ColorChat(0, GREEN, "%s ^1Not allowed to vote so soon again", tag);
        return PLUGIN_HANDLED;
    }

    yes = no = 0;
    isVoting = true;
    isAllowedToVoteAgain = false;
    get_user_name(id, voteInitiator, 63);
    ColorChat(0, GREEN, "%s ^1A vote for has been started by ^3%s", tag, voteInitiator);

    // Enable Road rage mode?
    gVoteMenu = menu_create("Are you sure about that?", "menu_handler");
	
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
    ColorChat(0, GREEN, "%s ^1Results from the vote: ^4%d - Yes ^1vs ^4%d - No", tag, yes, no);
    
    if (yes > no) {}

    client_print(0, print_console, "[AMXX] Votes yes: [ %d ]", yes);
    client_print(0, print_console, "[AMXX] Votes no: [ %d ]", no);

    isVoting = false;
    voteInitiator = "";
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

public allow_to_vote_again()
{
	isAllowedToVoteAgain = true;
	return PLUGIN_HANDLED;
}
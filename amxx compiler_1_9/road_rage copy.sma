#include <amxmodx>
#include <amxmisc>
#include <colorchat>

#define VERSION	"0.1"
#define PLUGIN "Road Rage"
#define AUTHOR "Maverick"

new yes = 0;
new no = 0;

// new voteDelay
new voteTime;
new gVoteMenu;
new bool:isVoting = false;
new voteInitiator[64];
new const tag[] = "[RR]";


public plugin_init() 
{
    register_plugin( PLUGIN, VERSION, AUTHOR );
    register_clcmd( "say /rr2", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );
    register_clcmd( "rr2", "StartVote", ADMIN_ALL, "Starts a vote for Roadrage mode" );


    // voteDelay = register_cvar("RR_Vote_Delay","120.0")
    voteTime = register_cvar("RR_Vote_Time","5.0")
}

public StartVote(id) 
{
    if (isVoting) 
    {
        // Example: format(dest, "Hello %s. You are %d years old", "Tom", 17).
        ColorChat(0, RED, "%s There is already a vote going started by %s", tag, voteInitiator);
        return PLUGIN_HANDLED;
    }

    yes = no = 0;
    isVoting = true;
    get_user_name(id, voteInitiator, 63);
    ColorChat(0, RED, "%s A vote for has been started by %s", tag, voteInitiator);

    // Enable Road rage mode?
    gVoteMenu = menu_create("Are you sure about that?", "menu_handler");
	menu_additem(gVoteMenu, "Yes", "1", 0);
	menu_additem(gVoteMenu, "No", "2", 0);

    new players[32], pnum, tempId; 
    get_players(players, pnum, "ch"); 

    for (new i = 0; i <= pnum; i++) {
        tempId = players[i]; 
        menu_display(tempId, gVoteMenu, 0);
    }

    set_task(5.0, "EndVote");
    return PLUGIN_HANDLED;
}

public EndVote() 
{
    isVoting = false;
    voteInitiator = "";
    menu_destroy(gVoteMenu);
    show_menu(0, 0, "^n", 1);
}

public menu_handler(id, menu, item)
{
    new s_Data[6], s_Name[64], i_Access, i_Callback;
	menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);  
    new key = str_to_num(s_Data);

    // client_print(0, print_console, "heyyyyyooo");

    switch (key) {
		case 1: yes++;
		case 2: no++;
	}

    client_print(0, print_console, "[AMXX] Votes yes: [ %d ]", yes);
    client_print(0, print_console, "[AMXX] Votes no: [ %d ]", no);

    isVoting = false;
    menu_destroy(menu);
	return PLUGIN_HANDLED;
}
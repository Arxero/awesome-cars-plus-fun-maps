 #include <amxmodx>

 //This will hold the VoteMenu
 new gVoteMenu;
 //This will hold the votes for each option
 new gVotes[2];
 //This determines if a vote is already happening
 new gVoting;

 public plugin_init()
 {
    //Register a way to get to your vote...
    register_clcmd( "start_vote","StartVote" );
 }
 public StartVote( id )
 {
    //If there is already a vote, don't start another
    if ( gVoting )
    {
        client_print( id, print_chat, "There is already a vote going." );
        //We return PLUGIN_HANDLED so the person does not get Unknown Command in console
        return PLUGIN_HANDLED;
    }

    //Reset vote counts from any previous votes
    gVotes[0] = gVotes[1] = 0;
    //Note that if you have more than 2 options, it would be better to use the line below:
    //arrayset( gVotes, 0, sizeof gVotes );

    //Store the menu in the global
    gVoteMenu = menu_create( "\rLook at this Vote Menu!:", "menu_handler" );

    //Add some vote options
    menu_additem( gVoteMenu, "Vote Option 1", "", 0 );
    menu_additem( gVoteMenu, "Vote Option 2", "", 0 );

    //We will need to create some variables so we can loop through all the players
    new players[32], pnum, tempid;

    //Fill players with available players
    get_players( players, pnum );

    //Start looping through all players to show the vote to
    for ( new i; i < pnum; i++ )
    {
        //Save a tempid so we do not re-index
        tempid = players[i];

        //Show the vote to this player
        menu_display( tempid, gVoteMenu, 0 );

        //Increase how many players are voting
        gVoting++;
    }

    //End the vote in 10 seconds
    set_task(10.0, "EndVote" );

    return PLUGIN_HANDLED;
 }
 public menu_handler( id, menu, item )
 {
    //If the menu was exited or if there is not a vote
    if ( item == MENU_EXIT || !gVoting )
    {
        //Note were not destroying the menu
        return PLUGIN_HANDLED;
    }

    //Increase the votes for what they selected
    gVotes[ item ]++;

    //Note were not destroying the menu
    return PLUGIN_HANDLED;
 }
 public EndVote()
 {
    //If the first option recieved the most votes
    if ( gVotes[0] > gVotes[1] )
        client_print(0, print_chat, "First option recieved most votes (%d )", gVotes[0] );

    //Else if the second option recieved the most votes
    else if ( gVotes[0] < gVotes[1] )
        client_print(0, print_chat, "Second option recieved most votes (%d )", gVotes[1] );

    //Otherwise the vote tied
    else
        client_print(0, print_chat, "The vote tied at %d votes each.", gVotes[0] );

    //Don't forget to destroy the menu now that we are completely done with it
    show_menu(0, 0, "^n", 1);
    menu_destroy( gVoteMenu );

    //Reset that no players are voting
    gVoting = 0;
 }
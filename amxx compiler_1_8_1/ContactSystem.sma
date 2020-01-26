#include < amxmodx >
#include < nvault_array >
#include < nvault_util >
#include < unixtime >
#include < hamsandwich >
#include < cromchat >

#define VERSION "2.0"

#define FLAG_VIEW ADMIN_RCON

enum
{
	MENU_ITEM_START_MESSAGE_PUBLIC = 0,
	MENU_ITEM_START_MESSAGE_PRIVATE
};

enum
{
	ITEM_VIEW = 0,
	ITEM_MARK_READ,
	ITEM_DELETE
};

enum
{
	ITEM_UNARCHIVE = 1,
	ITEM_DELETE_PERMANENT
};

enum
{
	PUBLIC_MENU = 0,
	PRIVATE_MENU,
	ARCHIVE_MENU
};

enum _:MessageStruct
{
	Message_Text[ 192 ],
	Message_Title[ 64 ],
	Message_Sender[ 32 ],
	Message_Reader[ 32 ],
	Message_To[ 32 ],
	Message_TimeStamp,
	Message_ReadTime,
bool:Message_Individual,
bool:Message_Read,
bool:Message_Removed
};

new const g_szCreateMessageCmd[ ][ ] =
{
	"say /contact",
	"say_team /contact",
	"say /ticket",
	"say_team /ticket"
};

new const g_szViewMessageCmd[ ][ ] =
{
	"say /view",
	"say_team /view",
	"say /tickets",
	"say_team /tickets"
};

new const g_szViewArchivedMsg[ ][ ] =
{
	"say /archive",
	"say_team /archive",
	"say /archived",
	"say_team /archived"
};

new const g_szSysPrefix[ ] = "[Contact System]";

new const g_szFileName[ ] = "StaffNames.ini";

new g_iVaultHandle;

new bool:g_bFirstSpawn[ 33 ];

new g_szTitle[ 33 ][ 64 ];
new g_szMsgTo[ 33 ][ 32 ];

new Array:g_aStaffInfo;

public plugin_precache( )
{
	g_aStaffInfo = ArrayCreate( 32 );

	ReadNames( );
}

public plugin_init( )
{
	register_plugin( "Contact/Ticket System", VERSION, "DoNii" );
	
	g_iVaultHandle = nvault_open( "contact_messages" );
	
	if ( g_iVaultHandle == INVALID_HANDLE )
	{
		set_fail_state( "Error opening nVault" );
	}
	
	new i;
	for( i = 0; i < sizeof g_szCreateMessageCmd; i++ )
	{
		register_clcmd( g_szCreateMessageCmd[ i ], "@OpenContactMenu" );
	}
	
	for( i = 0; i < sizeof g_szViewMessageCmd; i++ )
	{
		register_clcmd( g_szViewMessageCmd[ i ], "@ViewMessages" );
	}
	
	for( i = 0; i < sizeof g_szViewArchivedMsg; i++ )
	{
		register_clcmd( g_szViewArchivedMsg[ i ], "@ViewArchivedMessages" );
	}
	
	register_clcmd( "titlemessage", "@TitleEnter" );
	register_clcmd( "messagestart", "@MessageStart" );
	
	RegisterHam( Ham_Spawn, "player", "@Ham_Spawn", 1 );
}

public plugin_end( )
{
	nvault_close( g_iVaultHandle );
}

public client_connect( id )
{
	g_szTitle[ id ][ 0 ] = EOS;
	g_szMsgTo[ id ][ 0 ] = EOS;
	g_bFirstSpawn[ id ] = false;
}

@Ham_Spawn( id )
{
	if( ! is_user_alive( id ) || g_bFirstSpawn[ id ] || ~ get_user_flags( id ) & FLAG_VIEW )
	{
		return HAM_IGNORED;
	}

	g_bFirstSpawn[ id ] = true;

	nvault_close( g_iVaultHandle );
	new iVaultUtilityHandle = nvault_util_open( "contact_messages" );
	
	new iMessageCount = nvault_util_count( iVaultUtilityHandle );
	
	nvault_util_close( iVaultUtilityHandle ); 
	
	g_iVaultHandle = nvault_open( "contact_messages" );
	
	if( ! iMessageCount )
	{
		return HAM_IGNORED;
	}
	
	new eData[ MessageStruct ], szMsgId[ 5 ], szName[ 32 ], iNewMsgCount, iNewMsgIndividual;
	get_user_name( id, szName, charsmax( szName ) )
	
	for( new i = 1; i <= iMessageCount; i++ )
	{
		num_to_str( i, szMsgId, charsmax( szMsgId ) );
		nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
		
		if( eData[ Message_Removed ] || eData[ Message_Read ] )
		{
			continue;
		}
		
		if( eData[ Message_Individual ] )
		{
			if( equal( szName, eData[ Message_To ] ) )
			{
				iNewMsgIndividual++;
			}
			continue;
		}
		
		else
		{
			iNewMsgCount++;
		}
	}

	if( ! iNewMsgCount )
	{
		CC_SendMessage( id, "&x04%s &x01No new messages in &x04inbox", g_szSysPrefix );
		return HAM_IGNORED;
	}
	
	else
	{
		new szTitle[ 128 ];
		formatex( szTitle, charsmax( szTitle ), "Notifications:^n%d Message%s waiting to be seen", iNewMsgCount, iNewMsgCount != 1 ? "s" : "" );

		new iMenu = menu_create( szTitle, "OnNotifications_Handler" );
		menu_additem( iMenu, "Open Message Menu" );
		menu_display( id, iMenu, 0 );
	}
	return HAM_IGNORED;
}

public OnNotifications_Handler( id, iMenu, iItem )
{
	if( iItem == ITEM_VIEW )
	{
		@ViewMessages( id );
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

public @ViewArchivedMessages( id )
{
	if( ~ get_user_flags( id ) & FLAG_VIEW )
	{
		return PLUGIN_HANDLED;
	}

	nvault_close( g_iVaultHandle );
	new iVaultUtilityHandle = nvault_util_open( "contact_messages" );
	
	new iMessageCount = nvault_util_count( iVaultUtilityHandle );	
	nvault_util_close( iVaultUtilityHandle ); 
	
	g_iVaultHandle = nvault_open( "contact_messages" );
	
	new eData[ MessageStruct ], szMsgId[ 5 ], iArchivedMsg, szBuffer[ 64 ];
	
	new iMenu = menu_create( "Archived Messages", "OnMenuArchived_Handler" );
	
	for( new i = 1; i <= iMessageCount; i++ )
	{
		num_to_str( i, szMsgId, charsmax( szMsgId ) );
		nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
		
		if( eData[ Message_Removed ] )
		{
			formatex( szBuffer, charsmax( szBuffer ), "\dSender: %s | Title: %s", eData[ Message_Sender ], eData[ Message_Title ] );
			menu_additem( iMenu, szBuffer, szMsgId );
			
			iArchivedMsg++
		}
	}
	
	if( ! iArchivedMsg )
	{
		CC_SendMessage( id, "&x04%s &x01No Archived messages to display", g_szSysPrefix );
		return PLUGIN_HANDLED;
	}
	
	else
	{
		menu_display( id, iMenu, 0 );
	}
	
	return PLUGIN_CONTINUE;
}

public OnMenuArchived_Handler( id, iMenu, iItem )
{
	new iAccess, szMsgId[ 5 ], iCallback;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	menu_destroy( iMenu );
	
	new iMenu2 = menu_create( "Archived Message Options", "OnMenuArchivedOptions_Handler" );
	
	menu_additem( iMenu2, "View Archived Message", szMsgId );
	menu_additem( iMenu2, "UnArchive Message", szMsgId );
	menu_additem( iMenu2, "Delete Message", szMsgId );
	
	menu_display( id, iMenu2, 0 );
}	

public OnMenuArchivedOptions_Handler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}

	new iAccess, szMsgId[ 5 ], iCallback, eData[ MessageStruct ], iTimeStamp;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	
	if( ! nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ), iTimeStamp ) )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}

	switch( iItem )
	{
	case ITEM_VIEW:
		{
			new bool:bMessageRead = eData[ Message_Read ];
			
			new szFormatMessage[ 256 ], iYear, iMonth, iDay, iHour, iMinute, iSecond;
			remove_quotes( eData[ Message_Text ] );
			
			UnixToTime( eData[ Message_TimeStamp ], iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER );

			if( bMessageRead )
			{
				new iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2;
				UnixToTime( eData[ Message_ReadTime ], iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2, UT_TIMEZONE_SERVER );
				
				formatex( szFormatMessage, charsmax( szFormatMessage ), "Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: Yes<br>Read By: %s<br>Time Read: %02d/%02d/%d %02d:%02d:%02d", eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond, eData[ Message_Reader ], iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2 );
			}
			
			else
			{
				formatex( szFormatMessage, charsmax( szFormatMessage ), "Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: No", eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond );
			}
			show_motd( id, szFormatMessage, "Message" );
		}
		
	case ITEM_UNARCHIVE:
		{
			eData[ Message_Removed ] = false;
			
			nvault_set_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
			
			CC_SendMessage( id, "&x04%s &x01Message &x04#&x03%d &x01has been &x04un-archived", g_szSysPrefix, str_to_num( szMsgId ) );
		}
		
	case ITEM_DELETE_PERMANENT:
		{
			nvault_remove( g_iVaultHandle, szMsgId );
			
			CC_SendMessage( id, "&x04%s &x01Message &x04#&x03%d &x01has been &x04deleted", g_szSysPrefix, str_to_num( szMsgId ) );
		}
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

@OpenContactMenu( id )
{
	new iMenu = menu_create( "Contact the owner", "@OpenContactMenu_Handler" );

	menu_additem( iMenu, "Start a New Message [Public]" );
	menu_additem( iMenu, "Start a New Message [Private]" );
	menu_display( id, iMenu, 0 );
}

@OpenContactMenu_Handler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}
	
	switch( iItem )
	{
	case MENU_ITEM_START_MESSAGE_PUBLIC:
		{
			client_cmd( id, "messagemode titlemessage" );
		}
		
	case MENU_ITEM_START_MESSAGE_PRIVATE:
		{
			new iMenu2 = menu_create( "Select Staff Member", "OnMenuSelectStaff_Handler" );
			
			new szName[ 32 ];
			
			for( new i; i < ArraySize( g_aStaffInfo ); i++ )
			{
				ArrayGetString( g_aStaffInfo, i, szName, charsmax( szName ) );
				menu_additem( iMenu2, szName, szName );
			}
			
			menu_display( id, iMenu2, 0 );
		}
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

public OnMenuSelectStaff_Handler( id, iMenu, iItem )
{
	new iAccess, szName[ 32 ], iCallback;
	menu_item_getinfo( iMenu, iItem, iAccess, szName, charsmax( szName ), _, _, iCallback );
	
	copy( g_szMsgTo[ id ], charsmax( g_szMsgTo ), szName );
	
	client_cmd( id, "messagemode titlemessage" );
}	

@TitleEnter( id )
{		
	read_args( g_szTitle[ id ], charsmax( g_szTitle ) );
	client_cmd( id, "messagemode messagestart" );
}

@MessageStart( id )
{
	new szMessageCount[ 5 ];
	
	nvault_close( g_iVaultHandle );
	new iVaultUtilityHandle = nvault_util_open( "contact_messages" );
	
	new iMessageCount = nvault_util_count( iVaultUtilityHandle );
	iMessageCount += 1;
	
	nvault_util_close( iVaultUtilityHandle ); 
	
	g_iVaultHandle = nvault_open( "contact_messages" );
	
	num_to_str( iMessageCount, szMessageCount, charsmax( szMessageCount ) );
	
	new eData[ MessageStruct ];

	if( g_szMsgTo[ id ][ 0 ] )
	{
		trim( g_szMsgTo[ id ] );
		
		eData[ Message_Individual ] = true;
		eData[ Message_To ] = g_szMsgTo[ id ];
	}
	
	read_args( eData[ Message_Text ], charsmax( eData[ Message_Text ] ) );
	get_user_name( id, eData[ Message_Sender ], charsmax( eData[ Message_Sender ] ) );
	eData[ Message_Read ] = false;
	eData[ Message_Removed ] = false;
	eData[ Message_TimeStamp ] = get_systime( );
	
	remove_quotes( g_szTitle[ id ] );
	eData[ Message_Title ] = g_szTitle[ id ];
	
	nvault_set_array( g_iVaultHandle, szMessageCount, eData, sizeof( eData ) );
	
	CheckPlayers( );
	
	g_szTitle[ id ][ 0 ] = EOS;
	g_szMsgTo[ id ][ 0 ] = EOS;
}

@ViewMessages( id )
{
	if( ~ get_user_flags( id ) & FLAG_VIEW )
	{
		return PLUGIN_HANDLED;
	}
	
	new iMenu = menu_create( "Inbox Menu", "OnChooseWhichMenu_Handler" );
	
	menu_additem( iMenu, "Public Inbox" );
	menu_additem( iMenu, "Your Private Inbox" );
	menu_additem( iMenu, "Archive" );
	
	menu_display( id, iMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public OnChooseWhichMenu_Handler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}
	
	nvault_close( g_iVaultHandle );
	new iVaultUtilityHandle = nvault_util_open( "contact_messages" );
	
	new iVaultEntries = nvault_util_count( iVaultUtilityHandle ); 
	nvault_util_close( iVaultUtilityHandle ); 
	
	g_iVaultHandle = nvault_open( "contact_messages" );
	
	if( ! iVaultEntries )
	{
		CC_SendMessage( id, "&x04%s &x01No messages to display", g_szSysPrefix );
		return PLUGIN_HANDLED;
	}

	new iMenu2 = menu_create( "Messages:", "@ViewMessages_Handler" );
	
	new eData[ MessageStruct ], szMsgId[ 5 ], szMsgTitle[ 64 ], iMessages, szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );
	
	switch( iItem )
	{
	case PUBLIC_MENU:
		{	
			for( new i = 1; i <= iVaultEntries; i++ )
			{
				num_to_str( i, szMsgId, charsmax( szMsgId ) );
				nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
				
				if( ! eData[ Message_Removed ] && ! eData[ Message_Individual ] )
				{
					if( ! eData[ Message_Title ][ 0 ] || ! eData[ Message_Text ][ 0 ] )
					{
						continue;
					}
					
					formatex( szMsgTitle, charsmax( szMsgTitle ), "Sender: %s | Title: %s", eData[ Message_Sender ], eData[ Message_Title ] );
					menu_additem( iMenu2, szMsgTitle, szMsgId );
					
					iMessages++;
				}
			}
			
			if( ! iMessages )
			{
				CC_SendMessage( id, "&x04%s &x01No messages in inbox", g_szSysPrefix );
				return PLUGIN_HANDLED;
			}
			
			menu_display( id, iMenu2, 0 );
		}

	case PRIVATE_MENU:
		{			
			for( new i = 1; i <= iVaultEntries; i++ )
			{
				num_to_str( i, szMsgId, charsmax( szMsgId ) );
				nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
				
				if( ! eData[ Message_Removed ] && eData[ Message_Individual ] && equal( szName, eData[ Message_To ] ) )
				{		
					formatex( szMsgTitle, charsmax( szMsgTitle ), "Sender: %s | Title: %s", eData[ Message_Sender ], eData[ Message_Title ] );
					menu_additem( iMenu2, szMsgTitle, szMsgId );
					
					iMessages++;
				}
			}
			
			if( ! iMessages )
			{
				CC_SendMessage( id, "&x04%s &x01No messages in inbox", g_szSysPrefix );
				return PLUGIN_HANDLED;
			}
			
			menu_display( id, iMenu2, 0 );
		}
		
	case ARCHIVE_MENU:
		{
			@ViewArchivedMessages( id )
		}
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

@ViewMessages_Handler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{		
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}

	new iAccess, szMsgId[ 5 ], iCallback;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	menu_destroy( iMenu );
	
	new iMenuView = menu_create( "Message Options", "OnMenuViewHandler" );
	
	menu_additem( iMenuView, "View Message", szMsgId );
	menu_additem( iMenuView, "Mark as Read", szMsgId );
	menu_additem( iMenuView, "Remove/Archive Message", szMsgId );
	
	menu_display( id, iMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public OnMenuViewHandler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}

	new iAccess, szMsgId[ 5 ], iCallback, eData[ MessageStruct ], iTimeStamp;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	
	if( ! nvault_get_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ), iTimeStamp ) )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}
	
	switch( iItem )
	{
	case ITEM_VIEW:
		{
			new bool:bMessageRead = eData[ Message_Read ];
			
			new szFormatMessage[ 256 ], iYear, iMonth, iDay, iHour, iMinute, iSecond;
			remove_quotes( eData[ Message_Text ] );
			
			UnixToTime( eData[ Message_TimeStamp ], iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER );

			if( bMessageRead )
			{
				new iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2;
				UnixToTime( eData[ Message_ReadTime ], iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2, UT_TIMEZONE_SERVER );
				
				formatex( szFormatMessage, charsmax( szFormatMessage ), "Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: Yes<br>Read By: %s<br>Time Read: %02d/%02d/%d %02d:%02d:%02d", eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond, eData[ Message_Reader ], iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2 );
			}
			
			else
			{
				formatex( szFormatMessage, charsmax( szFormatMessage ), "Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: No", eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond );
				
				eData[ Message_Read ] = true;
				eData[ Message_ReadTime ] = get_systime( );
				get_user_name( id, eData[ Message_Reader ], charsmax( eData[ Message_Reader ] ) );
				
				nvault_set_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
			}
			show_motd( id, szFormatMessage, "Message" );
		}

	case ITEM_MARK_READ:
		{
			if( eData[ Message_Read ] )
			{
				CC_SendMessage( id, "&x04%s &x01Message has already been marked as &x04seen", g_szSysPrefix );
				
				menu_destroy( iMenu );
				return PLUGIN_HANDLED;
			}
			
			eData[ Message_Read ] = true;
			eData[ Message_ReadTime ] = get_systime( );
			get_user_name( id, eData[ Message_Reader ], charsmax( eData[ Message_Reader ] ) );
			
			nvault_set_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
			
			CC_SendMessage( id, "&x04%s Message &x04#&x03%d &x01has been marked as &x04read", g_szSysPrefix, str_to_num( szMsgId ) );
		}
		
	case ITEM_DELETE:
		{
			eData[ Message_Removed ] = true;
			nvault_set_array( g_iVaultHandle, szMsgId, eData, sizeof( eData ) );
			
			CC_SendMessage( id, "&x04%s Message &x04#&x03%d &x01has been &x04removed/archived", g_szSysPrefix, str_to_num( szMsgId ) );
		}
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

CheckPlayers( )
{
	new szPlayers[ 32 ], iNum, iTempId;
	get_players( szPlayers, iNum, "ch" );

	for( new i; i < iNum; i++ )
	{
		iTempId = szPlayers[ i ];

		if( get_user_flags( iTempId ) & FLAG_VIEW )
		{
			CC_SendMessage( iTempId, "&x04%s &x01New Message arrived!", g_szSysPrefix );
		}
	}
}

ReadNames( )
{
	new szFilename[ 256 ], szConfigsDir[ 128 ], szData[ 128 ];
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	formatex( szFilename, charsmax( szFilename ), "%s/%s", szConfigsDir, g_szFileName );
	
	new iFile = fopen( szFilename, "rt" );
	
	if( iFile )
	{		
		while( fgets( iFile, szData, charsmax( szData ) ) )
		{
			trim( szData );
			remove_quotes( szData );
			
			switch( szData[ 0 ] )
			{
			case EOS, '#', ';', '/':
				{
					continue;
				}
				
			default:
				{										
					ArrayPushString( g_aStaffInfo, szData );
				}
			}
		}
		fclose( iFile );
	}
	return PLUGIN_CONTINUE;
}
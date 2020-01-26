#include < amxmodx >
#include < amxmisc >
#include < unixtime >
#include < hamsandwich >
#include < cromchat >

#define PLUGIN_VERSION "3.1"

enum
{
	MENU_ITEM_START_MESSAGE_PUBLIC = 0,
	MENU_ITEM_START_MESSAGE_PRIVATE
};

enum
{
	ITEM_VIEW = 0,
	ITEM_MARK_READ,
	ITEM_ARCHIVE
};

enum
{
	ITEM_UNARCHIVE = 1,
	ITEM_DELETE
};

enum
{
	PUBLIC_MENU = 0,
	PRIVATE_MENU,
	ARCHIVE_MENU
};

enum _:Config
{
Float:MESSAGES_UPDATE_FREQUENCY,
	FLAG_VIEW_MESSAGES,
	COMMANDS_CREATE_MSG[ 32 ],
	COMMANDS_VIEW_MSG[ 32 ],
	COMMANDS_ARCHIVE_MENU[ 32 ],
	BACKGROUND_COLOR[ 15 ],
	TEXT_COLOR[ 15 ],
	MESSAGES_FILE[ 64 ],
	STAFF_FILE[ 64 ]
}

enum _:MessageStruct
{
	Message_Id,
	Message_Text[ 256 ],
	Message_Title[ 64 ],
	Message_Sender[ 32 ],
	Message_Reader[ 32 ],
	Message_To[ 32 ],
	Message_TimeStamp,
	Message_ReadTime,
bool:Message_Individual,
bool:Message_Read,
bool:Message_Archived
};

new const g_szSysPrefix[ ] = "[Report System]";

new Array:g_aMessages;
new Array:g_aStaffInfo;

new bool:g_bFirstSpawn[ 33 ];

new g_szTitle[ 33 ][ 64 ];
new g_szMsgTo[ 33 ][ 32 ];

new g_iConfig[ Config ];

new g_szConfigsDir[ 128 ];

public plugin_precache( )
{
	g_aStaffInfo = ArrayCreate( 32 );
	g_aMessages = ArrayCreate( MessageStruct );
	
	get_configsdir( g_szConfigsDir, charsmax( g_szConfigsDir ) );
	
	LoadConfig( );
	
	ReadNames( );
	LoadMessages( );
}

public plugin_init( )
{
	register_plugin( "Report System", PLUGIN_VERSION, "DoNii" );
	
	register_dictionary( "report_system.txt" );
	
	register_cvar( "report_system_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED );
	
	register_clcmd( "titlemessage", "@TitleEnter" );
	register_clcmd( "messagestart", "@MessageStart" );
	
	RegisterHam( Ham_Spawn, "player", "@Ham_Spawn", 1 );
	
	set_task( g_iConfig[ MESSAGES_UPDATE_FREQUENCY ], "LoadMessages", .flags="b" );
}

public plugin_end( )
{
	ArrayDestroy( g_aMessages );
	ArrayDestroy( g_aStaffInfo );
}

public client_connect( id )
{
	g_szTitle[ id ][ 0 ] = EOS;
	g_szMsgTo[ id ][ 0 ] = EOS;
	g_bFirstSpawn[ id ] = false;
}

@Ham_Spawn( id )
{
	if( ! is_user_alive( id ) || g_bFirstSpawn[ id ] || ~ get_user_flags( id ) & g_iConfig[ FLAG_VIEW_MESSAGES ] )
	{
		return HAM_IGNORED;
	}

	g_bFirstSpawn[ id ] = true;
	
	new iMessageCount = ArraySize( g_aMessages );
	
	if( ! iMessageCount )
	{
		return HAM_IGNORED;
	}
	
	new eData[ MessageStruct ], szMsgId[ 5 ], szName[ 32 ], iNewMsgCount, iNewMsgIndividual;
	get_user_name( id, szName, charsmax( szName ) )
	
	for( new i; i < ArraySize( g_aMessages ); i++ )
	{
		num_to_str( i, szMsgId, charsmax( szMsgId ) );
		ArrayGetArray( g_aMessages, i, eData );
		
		if( eData[ Message_Archived ] || eData[ Message_Read ] )
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
		CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "NO_NEW_MESSAGES" );
		return HAM_IGNORED;
	}
	
	else
	{
		new szTitle[ 128 ];
		
		if( iNewMsgCount == 1 )
		{
			formatex( szTitle, charsmax( szTitle ), "%L", id, "MESSAGES_WAITING_SINGULAR" );
		}
		
		else
		{
			formatex( szTitle, charsmax( szTitle ), "%L", id, "MESSAGES_WAITING_PLURAL", iNewMsgCount );
		}
		
		new iMenu = menu_create( szTitle, "OnNotifications_Handler" );
		
		new szItem[ 64 ];
		formatex( szItem, charsmax( szItem ), "%L", id, "OPEN_MESSAGE_MENU" );
		menu_additem( iMenu, szItem );
		
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
	if( ~ get_user_flags( id ) & g_iConfig[ FLAG_VIEW_MESSAGES ] )
	{
		return PLUGIN_HANDLED;
	}
	
	new eData[ MessageStruct ], szMsgId[ 5 ], iArchivedMsg, szBuffer[ 64 ];
	
	new szTitle[ 64 ];
	formatex( szTitle, charsmax( szTitle ), "%L", id, "ARCHIVED_MESSAGES" );
	
	new iMenu = menu_create( szTitle, "OnMenuArchived_Handler" );
	
	for( new i; i < ArraySize( g_aMessages ); i++ )
	{
		ArrayGetArray( g_aMessages, i, eData );
		
		if( eData[ Message_Archived ] )
		{
			formatex( szBuffer, charsmax( szBuffer ), "\d%L: %s | %L: %s", id, "SENDER", eData[ Message_Sender ], id, "TITLE", eData[ Message_Title ] );
			
			num_to_str( eData[ Message_Id ], szMsgId, charsmax( szMsgId ) );
			menu_additem( iMenu, szBuffer, szMsgId );
			
			iArchivedMsg++
		}
	}
	
	if( ! iArchivedMsg )
	{
		CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "NO_ARCHIVED_MESSAGES" );
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
	new iAccess, szMsgId[ 6 ], iCallback;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	menu_destroy( iMenu );
	
	new szTitle[ 64 ];
	formatex( szTitle, charsmax( szTitle ), "%L", id, "ARCHIVED_MENU_OPTIONS" );
	
	new iMenu2 = menu_create( szTitle, "OnMenuArchivedOptions_Handler" );
	
	new szItem[ 64 ];
	
	formatex( szItem, charsmax( szItem ), "%L", id, "VIEW_ARCHIVED_MESSAGE" );
	menu_additem( iMenu2, szItem, szMsgId );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "UNARCHIVE_ARCHIVED_MESSAGE" );
	menu_additem( iMenu2, szItem, szMsgId );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "DELETE_ARCHIVED_MESSAGE" );
	menu_additem( iMenu2, szItem, szMsgId );
	
	menu_display( id, iMenu2, 0 );
}	

public OnMenuArchivedOptions_Handler( id, iMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( iMenu );
		return PLUGIN_HANDLED;
	}

	new iAccess, szMsgId[ 6 ], iCallback, eData[ MessageStruct ];
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	
	new iMsgId = str_to_num( szMsgId );
	
	switch( iItem )
	{
	case ITEM_VIEW:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData )

				if( eData[ Message_Id ] == iMsgId )
				{
					new bool:bMessageRead = eData[ Message_Read ];
					
					new szFormatMessage[ 256 ], iYear, iMonth, iDay, iHour, iMinute, iSecond;
					
					UnixToTime( eData[ Message_TimeStamp ], iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER );

					if( bMessageRead )
					{
						new iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2;
						UnixToTime( eData[ Message_ReadTime ], iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2, UT_TIMEZONE_SERVER );
						
						formatex( szFormatMessage, charsmax( szFormatMessage ), "<body bgcolor=^"%s^"><font color=^"%s^">Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: Yes<br>Read By: %s<br>Time Read: %02d/%02d/%d %02d:%02d:%02d", g_iConfig[ BACKGROUND_COLOR ], g_iConfig[ TEXT_COLOR ], eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond, eData[ Message_Reader ], iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2 );
					}
					
					else
					{
						formatex( szFormatMessage, charsmax( szFormatMessage ), "<body bgcolor=^"%s^"><font color=^"%s^">Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: No", g_iConfig[ BACKGROUND_COLOR ], g_iConfig[ TEXT_COLOR ], eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond );
					}
					show_motd( id, szFormatMessage, "Message" );
				}
			}
		}
		
	case ITEM_UNARCHIVE:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData )
				
				if( eData[ Message_Id ] == iMsgId )
				{
					eData[ Message_Archived ] = false;
					
					UpdateData( eData[ Message_Id ], eData[ Message_Title ], eData[ Message_Text ], eData[ Message_Sender ], eData[ Message_Reader ], eData[ Message_To ], 
					eData[ Message_TimeStamp ], eData[ Message_ReadTime ], eData[ Message_Individual ], eData[ Message_Read ], eData[ Message_Archived ] );
					
					CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "MESSAGE_UNARCHIVED", str_to_num( szMsgId ) );
				}
			}
		}
		
	case ITEM_DELETE:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData )
				
				if( eData[ Message_Id ] == iMsgId )
				{
					DeleteData( eData[ Message_Id ] );
					
					CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "MESSAGE_DELETED", str_to_num( szMsgId ) );
				}
			}
		}
	}
	menu_destroy( iMenu );
	return PLUGIN_HANDLED;
}

@OpenContactMenu( id )
{
	new szTitle[ 64 ];
	
	formatex( szTitle, charsmax( szTitle ), "%L", id, "FILE_REPORT" );
	new iMenu = menu_create( szTitle, "@OpenContactMenu_Handler" );

	new szItem[ 64 ];
	
	formatex( szItem, charsmax( szItem ), "%L", id, "START_NEW_MSG_PUBLIC" );
	menu_additem( iMenu, szItem );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "START_NEW_MSG_PRIVATE" );
	menu_additem( iMenu, szItem );
	
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
			new szTitle[ 64 ];
			
			formatex( szTitle, charsmax( szTitle ), "%L", id, "SELECT_STAFF_MEMBER" );
			new iMenu2 = menu_create( szTitle, "OnMenuSelectStaff_Handler" );
			
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
	
	remove_quotes( g_szTitle[ id ] );
	
	if( ! g_szTitle[ id ][ 0 ] )
	{
		CC_SendMessage( id, "%L", id, "ENTER_TITLE" );
		client_cmd( id, "messagemode titlemessage" );
		
		return PLUGIN_HANDLED;
	}
	
	client_cmd( id, "messagemode messagestart" );
	return PLUGIN_CONTINUE;
}

@MessageStart( id )
{
    new eData[ MessageStruct ];
	
    read_args( eData[ Message_Text ], charsmax( eData[ Message_Text ] ) );
	remove_quotes( eData[ Message_Text ] );
	
	if( ! eData[ Message_Text ][ 0 ] )
	{
		CC_SendMessage( id, "%L", id, "ENTER_MESSAGE" );
		client_cmd( id, "messagemode messagestart" );
		
		return PLUGIN_HANDLED;
	}

	new iMsgCount = LoadMessages( );
	eData[ Message_Id ] = iMsgCount + 1;
	
	if( g_szMsgTo[ id ][ 0 ] )
	{
		trim( g_szMsgTo[ id ] );
		
		eData[ Message_Individual ] = true;
		eData[ Message_To ] = g_szMsgTo[ id ];
	}
	
	get_user_name( id, eData[ Message_Sender ], charsmax( eData[ Message_Sender ] ) );
	eData[ Message_Read ] = false;
	eData[ Message_Archived ] = false;
	eData[ Message_TimeStamp ] = get_systime( );
	
	remove_quotes( g_szTitle[ id ] );
	eData[ Message_Title ] = g_szTitle[ id ];
	
	ArrayPushArray( g_aMessages, eData );
	
	AddNewMessage( eData[ Message_Id ], eData[ Message_Title ], eData[ Message_Text ], eData[ Message_Sender ], eData[ Message_Reader ], 
	eData[ Message_To ], eData[ Message_TimeStamp ], eData[ Message_ReadTime ],
	eData[ Message_Individual ], eData[ Message_Read ], eData[ Message_Archived ] );
	
	CheckPlayers( );
	
	g_szTitle[ id ][ 0 ] = EOS;
	g_szMsgTo[ id ][ 0 ] = EOS;
	
	@OpenContactMenu( id );
	
	return PLUGIN_CONTINUE;
}

@ViewMessages( id )
{
	if( ~ get_user_flags( id ) & g_iConfig[ FLAG_VIEW_MESSAGES ] )
	{
		return PLUGIN_HANDLED;
	}
	
	new szTitle[ 64 ];
	
	formatex( szTitle, charsmax( szTitle ), "%L", id, "INBOX_MENU" );
	new iMenu = menu_create( szTitle, "OnChooseWhichMenu_Handler" );
	
	
	new szItem[ 64 ];
	
	formatex( szItem, charsmax( szItem ), "%L", id, "PUBLIC_INBOX" );
	menu_additem( iMenu, szItem );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "PRIVATE_INBOX" );
	menu_additem( iMenu, szItem );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "ARCHIVED_MESSAGES" );
	menu_additem( iMenu, szItem );
	
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

	new iMessageCount = ArraySize( g_aMessages );
	
	if( ! iMessageCount )
	{
		CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "NO_MESSAGES" );
		return PLUGIN_HANDLED;
	}

	new szTitle[ 32 ];
	
	formatex( szTitle, charsmax( szTitle ), "%L", id, "MESSAGES" );
	new iMenu2 = menu_create( szTitle, "@ViewMessages_Handler" );
	
	new eData[ MessageStruct ], szMsgId[ 5 ], szMsgTitle[ 64 ], iMessages, szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );
	
	switch( iItem )
	{
	case PUBLIC_MENU:
		{	
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData );
				
				if( ! eData[ Message_Archived ] && ! eData[ Message_Individual ] )
				{
					formatex( szMsgTitle, charsmax( szMsgTitle ), "%L: %s | %L: %s", id, "SENDER", eData[ Message_Sender ], id, "TITLE", eData[ Message_Title ] );
					
					num_to_str( eData[ Message_Id ], szMsgId, charsmax( szMsgId ) );
					menu_additem( iMenu2, szMsgTitle, szMsgId );
					
					iMessages++;
				}
			}
			
			if( ! iMessages )
			{
				CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "NO_MESSAGES_INBOX" );
				return PLUGIN_HANDLED;
			}
			
			menu_display( id, iMenu2, 0 );
		}
		
	case PRIVATE_MENU:
		{			
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData );
				
				if( ! eData[ Message_Archived ] && eData[ Message_Individual ] && equal( szName, eData[ Message_To ] ) )
				{		
					formatex( szMsgTitle, charsmax( szMsgTitle ), "Sender: %s | Title: %s", eData[ Message_Sender ], eData[ Message_Title ] );
					
					num_to_str( eData[ Message_Id ], szMsgId, charsmax( szMsgId ) );
					menu_additem( iMenu2, szMsgTitle, szMsgId );
					
					iMessages++;
				}
			}
			
			if( ! iMessages )
			{
				CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "NO_MESSAGES_INBOX" );
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

	new iAccess, szMsgId[ 6 ], iCallback;
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	menu_destroy( iMenu );
	
	new szTitle[ 64 ];
	
	formatex( szTitle, charsmax( szTitle ), "%L", id, "MESSAGE_OPTIONS" );
	new iMenuView = menu_create( szTitle, "OnMenuViewHandler" );
	
	new szItem[ 64 ];
	
	formatex( szItem, charsmax( szItem ), "%L", id, "VIEW_MESSAGE" );
	menu_additem( iMenuView, szItem, szMsgId );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "MARK_AS_READ" );
	menu_additem( iMenuView, szItem, szMsgId );
	
	formatex( szItem, charsmax( szItem ), "%L", id, "ARCHIVE_MESSAGE" );
	menu_additem( iMenuView, szItem, szMsgId );
	
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

	new iAccess, szMsgId[ 5 ], iCallback, eData[ MessageStruct ];
	menu_item_getinfo( iMenu, iItem, iAccess, szMsgId, charsmax( szMsgId ), _, _, iCallback );
	
	switch( iItem )
	{
	case ITEM_VIEW:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData );
				
				if( eData[ Message_Id ] == str_to_num( szMsgId ) )
				{
					new bool:bMessageRead = eData[ Message_Read ];
					
					new szFormatMessage[ 256 ], iYear, iMonth, iDay, iHour, iMinute, iSecond;
					
					UnixToTime( eData[ Message_TimeStamp ], iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER );

					if( bMessageRead )
					{
						new iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2;
						UnixToTime( eData[ Message_ReadTime ], iYear2, iMonth2, iDay2, iHour2, iMinute2, iSecond2, UT_TIMEZONE_SERVER );
						
						formatex( szFormatMessage, charsmax( szFormatMessage ), "<body bgcolor=^"%s^"><font color=^"%s^">Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: Yes<br>Read By: %s<br>Time Read: %02d/%02d/%d %02d:%02d:%02d", g_iConfig[ BACKGROUND_COLOR ], g_iConfig[ TEXT_COLOR ], eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond, eData[ Message_Reader ], iMonth2, iDay2, iYear2, iHour2, iMinute2, iSecond2 );
					}
					
					else
					{
						formatex( szFormatMessage, charsmax( szFormatMessage ), "<body bgcolor=^"%s^"><font color=^"%s^">Message: %s<br><br><br><br>Time Created: %02d/%02d/%d %02d:%02d:%02d<br>Read: No", g_iConfig[ BACKGROUND_COLOR ], g_iConfig[ TEXT_COLOR ], eData[ Message_Text ], iMonth, iDay, iYear, iHour, iMinute, iSecond );
						
						eData[ Message_Read ] = true;
						eData[ Message_ReadTime ] = get_systime( );
						get_user_name( id, eData[ Message_Reader ], charsmax( eData[ Message_Reader ] ) );
						
						UpdateData( eData[ Message_Id ], eData[ Message_Title ], eData[ Message_Text ], eData[ Message_Sender ], eData[ Message_Reader ], eData[ Message_To ], 
						eData[ Message_TimeStamp ], eData[ Message_ReadTime ], eData[ Message_Individual ], eData[ Message_Read ], eData[ Message_Archived ] );
					}
					show_motd( id, szFormatMessage, "Message" );
				}
			}
		}

	case ITEM_MARK_READ:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData );
				
				if( eData[ Message_Id ] == str_to_num( szMsgId ) )
				{
					if( eData[ Message_Read ] )
					{
						CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "ALREADY_MARKED_SEEN" );
						
						menu_destroy( iMenu );
						return PLUGIN_HANDLED;
					}
					
					eData[ Message_Read ] = true;
					eData[ Message_ReadTime ] = get_systime( );
					get_user_name( id, eData[ Message_Reader ], charsmax( eData[ Message_Reader ] ) );
					
					UpdateData( eData[ Message_Id ], eData[ Message_Title ], eData[ Message_Text ], eData[ Message_Sender ], eData[ Message_Reader ], eData[ Message_To ], 
					eData[ Message_TimeStamp ], eData[ Message_ReadTime ], eData[ Message_Individual ], eData[ Message_Read ], eData[ Message_Archived ] );
					
					CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "MARKED_SEEN", str_to_num( szMsgId ) );
				}
			}
		}
		
	case ITEM_ARCHIVE:
		{
			for( new i; i < ArraySize( g_aMessages ); i++ )
			{
				ArrayGetArray( g_aMessages, i, eData );
				
				if( eData[ Message_Id ] == str_to_num( szMsgId ) )
				{
					eData[ Message_Archived ] = true;
					
					UpdateData( eData[ Message_Id ], eData[ Message_Title ], eData[ Message_Text ], eData[ Message_Sender ], eData[ Message_Reader ], eData[ Message_To ], 
					eData[ Message_TimeStamp ], eData[ Message_ReadTime ], eData[ Message_Individual ], eData[ Message_Read ], eData[ Message_Archived ] );
					
					CC_SendMessage( id, "&x04%s %L", g_szSysPrefix, id, "MESSAGE_ARCHIVED", str_to_num( szMsgId ) );
				}
			}
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

		if( get_user_flags( iTempId ) & g_iConfig[ FLAG_VIEW_MESSAGES ] )
		{
			CC_SendMessage( iTempId, "&x04%s %L", g_szSysPrefix, iTempId, "NEW_MESSAGE_ARRIVED" );
		}
	}
}

ReadNames( )
{
	new szFilename[ 256 ], szData[ 128 ];
	get_configsdir( g_szConfigsDir, charsmax( g_szConfigsDir ) );
	formatex( szFilename, charsmax( szFilename ), "%s/%s", g_szConfigsDir, g_iConfig[ STAFF_FILE ] );
	
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

public LoadMessages( )
{
	ArrayClear( g_aMessages );

	new szFile[ 128 ], szData[ 256 ];
	
	formatex( szFile, charsmax( szFile ), "%s/%s", g_szConfigsDir, g_iConfig[ MESSAGES_FILE ] );
	
	new iFile = fopen( szFile, "rt" );
	
	if( iFile )
	{
		while( fgets( iFile, szData, charsmax( szData ) ) )
		{ 
			trim( szData );
			
			switch( szData[ 0 ] )
			{
			case EOS, '#', ';', '/': 
				{
					continue;
				}
				
			default:
				{
					new szId[ 6 ], szTitle[ 64 ], szBody[ 256 ], szSender[ 32 ], szReader[ 32 ], szTo[ 32 ], szTimeStamp[ 20 ], szReadTime[ 20 ], szIndividual[ 2 ], szRead[ 2 ], szRemoved[ 2 ];
					
					parse( szData, szId, charsmax( szId ), szTitle, charsmax( szTitle ), szBody, charsmax( szBody ), szSender, charsmax( szSender ), szReader, charsmax( szReader ), 
					szTo, charsmax( szTo ), szTimeStamp, charsmax( szTimeStamp ), szReadTime, charsmax( szReadTime ), szIndividual, charsmax( szIndividual ), szRead, charsmax( szRead ), 
					szRemoved, charsmax( szRemoved ) );
					
					new eData[ MessageStruct ];
					
					eData[ Message_Id ] = str_to_num( szId );
					
					copy( eData[ Message_Title ], charsmax( eData[ Message_Title ] ), szTitle );
					copy( eData[ Message_Text ], charsmax( eData[ Message_Text ] ), szBody );
					copy( eData[ Message_Sender ], charsmax( eData[ Message_Sender ] ), szSender );
					copy( eData[ Message_Reader ], charsmax( eData[ Message_Reader ] ), szReader );
					copy( eData[ Message_To ], charsmax( eData[ Message_To ] ), szTo );
					
					eData[ Message_TimeStamp ] = str_to_num( szTimeStamp );
					eData[ Message_ReadTime ] = str_to_num( szReadTime );
					
					eData[ Message_Individual ] = bool:str_to_num( szIndividual );
					eData[ Message_Read ] = bool:str_to_num( szRead );
					eData[ Message_Archived ] = bool:str_to_num( szRemoved );
					
					ArrayPushArray( g_aMessages, eData );
				}
			}
		}
		fclose( iFile );
	}
	
	new eData[ MessageStruct ], iHighest = 0;
	for( new i; i < ArraySize( g_aMessages ); i++ )
	{
		ArrayGetArray( g_aMessages, i, eData );
		
		if( eData[ Message_Id ] > iHighest )
		{
			iHighest = eData[ Message_Id ];
		}
	}
	
	return iHighest;
}

public UpdateData( iId, szTitle[ ], szText[ ], szSender[ ], szReader[ ], szTo[ ], iTimeStamp, iReadTime, bool:bIndividual, bool:bRead, bool:bRemoved )
{
	new const szTempFileName[ ] = "tempfile.ini";

	new szFormat[ 128 ], szData[ 512 ], szId[ 6 ];
	
	new szTempFilePath[ 256 ]; 
	formatex( szTempFilePath, charsmax( szTempFilePath ), "%s/%s", g_szConfigsDir, szTempFileName );
	
	formatex( szFormat, charsmax( szFormat ), "%s/%s", g_szConfigsDir, g_iConfig[ MESSAGES_FILE ] );
	new iFilePointer = fopen( szFormat, "rt" );
	
	if( iFilePointer )
	{
		new iInputFilePointer = fopen( szTempFilePath, "wt" );
		
		if( iInputFilePointer )
		{
			while( fgets( iFilePointer, szData, charsmax( szData ) ) )
			{
				trim( szData );
				
				parse( szData, szId, charsmax( szId ) );
				
				if( str_to_num( szId ) != iId )
				{
					fprintf( iInputFilePointer, "%s^n", szData );
				}
				
				else
				{
					fprintf( iInputFilePointer, "^"%d^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^"^n", iId, szTitle, szText, szSender, szReader, szTo, iTimeStamp, iReadTime, bIndividual, bRead, bRemoved ); // edit this one
				}
			}
			fclose( iInputFilePointer );
			fclose( iFilePointer );
			
			delete_file( szFormat );
			rename_file( szTempFilePath, szFormat, 1 );
		}
	}
	LoadMessages( );
}

public DeleteData( iId )
{
	new const szTempFileName[ ] = "tempfile.ini";

	new szFormat[ 128 ], szData[ 512 ], szId[ 6 ];
	
	new szTempFilePath[ 256 ]; 
	formatex( szTempFilePath, charsmax( szTempFilePath ), "%s/%s", g_szConfigsDir, szTempFileName );
	
	formatex( szFormat, charsmax( szFormat ), "%s/%s", g_szConfigsDir, g_iConfig[ MESSAGES_FILE ] );
	new iFilePointer = fopen( szFormat, "rt" );
	
	if( iFilePointer )
	{
		new iInputFilePointer = fopen( szTempFilePath, "wt" );
		
		if( iInputFilePointer )
		{
			while( fgets( iFilePointer, szData, charsmax( szData ) ) )
			{
				trim( szData );
				
				parse( szData, szId, charsmax( szId ) );
				
				if( str_to_num( szId ) != iId )
				{
					fprintf( iInputFilePointer, "%s^n", szData );
				}
			}
			fclose( iInputFilePointer );
			fclose( iFilePointer );
			
			delete_file( szFormat );
			rename_file( szTempFilePath, szFormat, 1 );
		}
	}
	LoadMessages( );
}

public AddNewMessage( iId, szTitle[ ], szText[ ], szSender[ ], szReader[ ], szTo[ ], iTimeStamp, iReadTime, bool:bIndividual, bool:bRead, bool:bRemoved )
{
	new szFormat[ 128 ];
	formatex( szFormat, charsmax( szFormat ), "%s/%s", g_szConfigsDir, g_iConfig[ MESSAGES_FILE ] );
	new iFile = fopen( szFormat , "r+" );

	new szByteVal[ 1 ], szNewLine[ 128 ];
	
	fseek( iFile , -1 , SEEK_END );
	fread_raw( iFile , szByteVal , sizeof( szByteVal ) , BLOCK_BYTE );
	fseek( iFile , 0 , SEEK_END );
	
	formatex( szNewLine, charsmax( szNewLine ), "%s^"%d^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^"", ( szByteVal[ 0 ] == 10 ) ? "" : "^n", iId, szTitle, szText, szSender, szReader, szTo, iTimeStamp, iReadTime, bIndividual, bRead, bRemoved ); 

	fputs( iFile , szNewLine );
	
	fclose( iFile );
	
	LoadMessages( );
}

public LoadConfig( )
{
	new szFile[ 128 ], szData[ 64 ];
	
	formatex( szFile, charsmax( szFile ), "%s/%s", g_szConfigsDir, "ReportSystem_Config.cfg" );
	
	new iFile = fopen( szFile, "rt" );
	
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
					new szKey[ 32 ], szValue[ 64 ];
					strtok( szData, szKey, charsmax( szKey ), szValue, charsmax( szValue ), '=' );
					trim( szKey ); 
					trim( szValue );
					
					remove_quotes( szKey );
					remove_quotes( szValue );
					
					if( ! szValue[ 0 ] )
					{
						continue;
					}
					
					if( equal( szKey, "MESSAGES_UPDATE_FREQUENCY" ) )
					{
						g_iConfig[ MESSAGES_UPDATE_FREQUENCY ] = _:str_to_float( szValue );
					}
					
					else if( equal( szKey, "FLAG_VIEW_MESSAGES" ) )
					{
						g_iConfig[ FLAG_VIEW_MESSAGES ] = read_flags( szValue );
					}
					
					else if( equal( szKey, "MESSAGES_FILE" ) )
					{
						copy( g_iConfig[ MESSAGES_FILE ], charsmax( g_iConfig[ MESSAGES_FILE ] ), szValue );
					}
					
					else if( equal( szKey, "STAFF_FILE" ) )
					{
						copy( g_iConfig[ STAFF_FILE ], charsmax( g_iConfig[ STAFF_FILE ] ), szValue );
					}
					
					else if( equal( szKey, "BACKGROUND_COLOR" ) )
					{
						copy( g_iConfig[ BACKGROUND_COLOR ], charsmax( g_iConfig[ BACKGROUND_COLOR ] ), szValue );
					}
					
					else if( equal( szKey, "TEXT_COLOR" ) )
					{
						copy( g_iConfig[ TEXT_COLOR ], charsmax( g_iConfig[ TEXT_COLOR ] ), szValue );
					}
					
					else if( equal( szKey, "COMMANDS_CREATE_MSG" ) )
					{
						while( szValue[ 0 ] != 0 && strtok( szValue, szKey, charsmax( szKey ), szValue, charsmax( szValue ), ',' ) )
						{
							trim( szKey ); 
							trim( szValue );
							
							new szCmd[ 32 ];
							formatex( szCmd, charsmax( szCmd ), "say %s", szKey );
							
							register_clcmd( szCmd, "@OpenContactMenu" );
						}
					}
					
					else if( equal( szKey, "COMMANDS_VIEW_MSG" ) )
					{
						while( szValue[ 0 ] != 0 && strtok( szValue, szKey, charsmax( szKey ), szValue, charsmax( szValue ), ',' ) )
						{
							trim( szKey ); 
							trim( szValue );
							
							new szCmd[ 32 ];
							formatex( szCmd, charsmax( szCmd ), "say %s", szKey );
							
							register_clcmd( szCmd, "@ViewMessages" );
						}
					}
					
					else if( equal( szKey, "COMMANDS_ARCHIVE_MENU" ) )
					{
						while( szValue[ 0 ] != 0 && strtok( szValue, szKey, charsmax( szKey ), szValue, charsmax( szValue ), ',' ) )
						{
							trim( szKey ); 
							trim( szValue );
							
							new szCmd[ 32 ];
							formatex( szCmd, charsmax( szCmd ), "say %s", szKey );
							
							register_clcmd( szCmd, "@ViewArchivedMessages" );
						}
					}
				}
			}
		}
		fclose( iFile );
	}
}
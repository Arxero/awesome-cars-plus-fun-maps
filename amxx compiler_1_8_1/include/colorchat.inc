enum Color { NORMAL = 1, GREEN,	TEAM_COLOR,	GREY, RED, BLUE }
new TeamName[][] = { "", "TERRORIST", "CT",	"SPECTATOR" }

ColorChat(id, Color:iType, const szMsg[], any:...)
{
	static szMessage[256]

	switch(iType)
	{
		case NORMAL: szMessage[0] = 0x01
		case GREEN: szMessage[0] = 0x04
		default: szMessage[0] = 0x03
	}

	vformat(szMessage[1], charsmax(szMessage), szMsg, 4)
	replace_all(szMessage, charsmax(szMessage), "!n", "^x01")
	replace_all(szMessage, charsmax(szMessage), "!t", "^x03")
	replace_all(szMessage, charsmax(szMessage), "!g", "^x04")
		
	static iTeam, ColorChange, iIndex, iMsgType
	szMessage[192] = EOS
	
	if(id)
	{
		iMsgType = MSG_ONE
		iIndex = id
	}
	else
	{
		iIndex = FindPlayer()
		iMsgType = MSG_ALL
	}
	
	iTeam = get_user_team(iIndex)
	ColorChange = ColorSelection(iIndex, iMsgType, iType)
	ShowColorMessage(iIndex, iMsgType, szMessage)
		
	if(ColorChange)
		Team_Info(iIndex, iMsgType, TeamName[iTeam])
}

ShowColorMessage(id, iType, szMessage[])
{
	message_begin(iType, get_user_msgid("SayText"), _, id)
	write_byte(id)		
	write_string(szMessage)
	message_end()
}

Team_Info(id, iType, iTeam[])
{
	message_begin(iType, get_user_msgid("TeamInfo"), _, id)
	write_byte(id)
	write_string(iTeam)
	message_end()
	return 1
}

ColorSelection(iIndex, iType, Color:Type)
{
	switch(Type)
	{
		case RED: return Team_Info(iIndex, iType, TeamName[1]);
		case BLUE: return Team_Info(iIndex, iType, TeamName[2]);
		case GREY: return Team_Info(iIndex, iType, TeamName[0]);
	}

	return 0
}

FindPlayer()
{
	static i
	i = -1

	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
			return i;
	}

	return -1
}
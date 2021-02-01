#if defined _menutime_included
    #endinput
#endif

#define _menutime_included

#define TASK_MENU_TIMEOUT 456522

stock menu_set_timeout(const id, const iMenu, const Float:fTime)
{
	static iArray[2], iTask
	
	iArray[0] = id
	iArray[1] = iMenu
	iTask = id + TASK_MENU_TIMEOUT
	
	remove_task(iTask)
	set_task(fTime, "RemoveMenu", iTask, iArray, sizeof(iArray))
}

public RemoveMenu(iArray[2])
{
	static iMenu[3], id
	
	id = iArray[0]
	iMenu[0] = iArray[1]
	
	if(player_menu_info(id, iMenu[2], iMenu[1]))
	{
		if(iMenu[1] == iMenu[0])
			show_menu(id, 0, "^n", 1)
	}
}
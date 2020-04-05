#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <colorchat>

#define PLUGIN  "Choose Camera View"
#define VERSION "1.0"
#define AUTHOR  "hackera457 @ AMXX-BG.info"

#define DEFAULT_CAMERA_TYPES 4

enum _:Cvars{
	
	USE_DEFAULT_CAMERA_CHOICE,
	DEFAULT_CAMERA_VIEW_TYPE,
	ONLY_ADMIN_USE_MENU,
	ADMIN_MENU_ACCESS
}

new const g_szCameraTypes[][]={
	
	"Normal Camera",
	"TopDown Camera",
	"UpLeft Camera",
	"3rd Person Camera"
}

new const g_szSayCommands[][]={
	
	"say /cam", "say_team /cam",
	"say /camera", "say_team /camera"	
	
}

new g_iUserCameraChoice[33]
new g_pCvars[Cvars]

public plugin_init()
{
		register_plugin(PLUGIN,VERSION,AUTHOR)
		
		register_cvar("hackera457_ccv",VERSION,FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
		
		g_pCvars[USE_DEFAULT_CAMERA_CHOICE] = register_cvar("ccv_user_default_camera_view","1");
		g_pCvars[DEFAULT_CAMERA_VIEW_TYPE] = register_cvar("ccv_default_user_camera_view","0")
		g_pCvars[ONLY_ADMIN_USE_MENU] = register_cvar("ccv_admin_use_only","0")
		g_pCvars[ADMIN_MENU_ACCESS] = register_cvar("ccv_admin_menu_access_flag","c")
		
		for(new i=0; i<4; i++)
			register_clcmd(g_szSayCommands[i],"cmdShowCamChoiceMenu")
		
		register_forward(FM_AddToFullPack, "Fwd_AddToFullPack", 1)
}

public plugin_precache()
{
    precache_model("models/rpgrocket.mdl")
}

public client_putinserver(id)
{
	if(get_pcvar_num(g_pCvars[USE_DEFAULT_CAMERA_CHOICE]))
		SetUserCamera(id, get_pcvar_num(g_pCvars[DEFAULT_CAMERA_VIEW_TYPE]))
	else
		g_iUserCameraChoice[id] = 0
}

public cmdShowCamChoiceMenu(id)
{
	if(get_pcvar_num(g_pCvars[ONLY_ADMIN_USE_MENU]))
	{
		static szAdminFlags[32]
		get_pcvar_string(g_pCvars[ADMIN_MENU_ACCESS], szAdminFlags, sizeof szAdminFlags -1)
		
		if(!(get_user_flags(id) & read_flags(szAdminFlags)))
		{
			ColorChat(id,TEAM_COLOR,"^4[CCV] ^1Only Admin/VIP can use camera menu!")
			return PLUGIN_HANDLED
		}
	}
	static szMenuTitle[128], szMenuItem[64], iMenu
	
	formatex(szMenuTitle, sizeof szMenuTitle -1,"\r[CCV] \yChoose your camera type:")
	iMenu = menu_create(szMenuTitle,"handlerCamChoiceMenu")
	
	for(new j=0; j < DEFAULT_CAMERA_TYPES; j++)
	{
		formatex(szMenuItem, sizeof szMenuItem -1,"\y%s %s",g_szCameraTypes[j],(g_iUserCameraChoice[id] == j ? "\r[SELECTED]":""))
		menu_additem(iMenu,szMenuItem)
	}
	
	menu_setprop(iMenu,MPROP_EXITNAME,"\rClose")
	menu_display(id,iMenu,0)
	
	return PLUGIN_HANDLED
}

public handlerCamChoiceMenu(id,iMenu,iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	
	if(g_iUserCameraChoice[id] == iItem)
	{
		ColorChat(id,TEAM_COLOR,"^4[CCV] ^1You have already choosed camera view!")
		return PLUGIN_HANDLED
	}
		
	SetUserCamera(id,iItem)
	client_cmd(id,"spk UI/buttonclickrelease.wav")
	ColorChat(id,TEAM_COLOR,"^4[CCV] ^1You choose ^3%s^1!",g_szCameraTypes[iItem])
	
	return PLUGIN_HANDLED
}

public Fwd_AddToFullPack (es_handle, e, ent, host, hostflags, player, pSe )
{
	if(player && (ent == host))
		set_es(es_handle, ES_RenderMode, kRenderNormal)
}

SetUserCamera(id,iCameraType)
{
	if(is_user_hltv(id) || is_user_bot(id))
		return;
		
	switch(iCameraType)
	{
		case 0: set_view(id,CAMERA_NONE)
		case 1: set_view(id,CAMERA_TOPDOWN)
		case 2: set_view(id,CAMERA_UPLEFT)
		case 3: set_view(id,CAMERA_3RDPERSON)
	}
	
	g_iUserCameraChoice[id] = iCameraType
}

 

#include <amxmodx>

#define PLUGIN "Trail Menu"
#define VERSION ""
#define AUTHOR ""
new menu

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR)
register_clcmd("say /trail", "go_menu")
register_clcmd("say_team /trail", "go_menu")

menu = menu_create("\rTrail Menu","func_menu");
menu_additem( menu, "\y[Trail]- \rTrail OFF")
menu_additem( menu, "\y[\rTrail\y]- \wLaser Beam")
menu_additem( menu, "\y[\rTrail\y]- \rBlue Flare")
menu_additem( menu, "\y[\rTrail\y]- \wDot")
menu_additem( menu, "\y[\rTrail\y]- \wFlare 1")
menu_additem( menu, "\y[\rTrail\y]- \wFlare 2")
menu_additem( menu, "\y[\rTrail\y]- \wPlasma") 
menu_additem( menu, "\y[\rTrail\y]- \wSmoke")
menu_additem( menu, "\y[\rTrail\y]- \wXbeam 1")
menu_additem( menu, "\y[\rTrail\y]- \wXenobeam")
menu_additem( menu, "\y[\rTrail\y]- \wXssmke 1")
menu_additem( menu, "\y[\rTrail\y]- \wZbeam 1")
menu_additem( menu, "\y[\rTrail\y]- \wZbeam 2")
menu_additem( menu, "\y[\rTrail\y]- \wMinecraft")
menu_additem( menu, "\y[\rTrail\y]- \wDef T")
menu_additem( menu, "\y[\rTrail\y]- \wLove‚") 
menu_additem( menu, "\y[\rTrail\y]- \wHP")
menu_additem( menu, "\y[\rTrail\y]- \wBiohazard")
menu_additem( menu, "\y[\rTrail\y]- \wCT")
menu_additem( menu, "\y[\rTrail\y]- \wLightning")
menu_additem( menu, "\y[\rTrail\y]- \wLetters")
menu_additem( menu, "\y[\rTrail\y]- \wIce")
menu_additem( menu, "\y[\rTrail\y]- \wBox")
menu_additem( menu, "\y[\rTrail\y]- \wZik")
menu_additem( menu, "\y[\rTrail\y]- \wVselennaya")
menu_additem( menu, "\y[\rTrail\y]- \wTok")
menu_additem( menu, "\y[\rTrail\y]- \wZet")
menu_additem( menu, "\y[\rTrail\y]- \wSnow White")
menu_additem( menu, "\y[\rTrail\y]- \wShar")
menu_additem( menu, "\y[\rTrail\y]- \wPresent")

menu_setprop( menu, MPROP_NEXTNAME, "Next")
menu_setprop( menu, MPROP_BACKNAME, "Back")
menu_setprop( menu, MPROP_EXITNAME, "Exit")

register_clcmd("Menu","go_menu");
}

public func_menu(id, menu, key)
{
key++
if(key==1) client_cmd(id, "say_team trail off")
if(key==2) client_cmd(id, "say_team trail 1")
if(key==3) client_cmd(id, "say_team trail 2")
if(key==4) client_cmd(id, "say_team trail 3")
if(key==5) client_cmd(id, "say_team trail 4")
if(key==6) client_cmd(id, "say_team trail 5")
if(key==7) client_cmd(id, "say_team trail 6")
if(key==8) client_cmd(id, "say_team trail 7")
if(key==9) client_cmd(id, "say_team trail 8")
if(key==10) client_cmd(id, "say_team trail 9")
if(key==11) client_cmd(id, "say_team trail 10")
if(key==12) client_cmd(id, "say_team trail 11")
if(key==13) client_cmd(id, "say_team trail 12")
if(key==14) client_cmd(id, "say_team trail 13")
if(key==15) client_cmd(id, "say_team trail 14")
if(key==16) client_cmd(id, "say_team trail 15")
if(key==17) client_cmd(id, "say_team trail 16")
if(key==18) client_cmd(id, "say_team trail 17")
if(key==19) client_cmd(id, "say_team trail 18")
if(key==20) client_cmd(id, "say_team trail 19")
if(key==21) client_cmd(id, "say_team trail 20")
if(key==22) client_cmd(id, "say_team trail 21")
if(key==23) client_cmd(id, "say_team trail 22")
if(key==24) client_cmd(id, "say_team trail 23")
if(key==25) client_cmd(id, "say_team trail 24")
if(key==26) client_cmd(id, "say_team trail 25")
if(key==27) client_cmd(id, "say_team trail 26")
if(key==28) client_cmd(id, "say_team trail 27")
if(key==29) client_cmd(id, "say_team trail 28")
if(key==30) client_cmd(id, "say_team trail 29")
}

public go_menu(id)
{
menu_display(id,menu)

return PLUGIN_HANDLED
}

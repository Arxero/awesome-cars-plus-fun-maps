#if defined _fm_cstrike_plugin_included
	#endinput
#endif

#define _fm_cstrike_plugin_included


#if AMXX_VERSION_NUM >= 175
	#pragma reqlib fm_cstrike
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib fm_cstrike
	#endif
#else
	#pragma library fm_cstrike
#endif


native fm_cs_get_no_knives();

native fm_cs_set_no_knives(noknives=0);

native fm_cs_set_user_zoom(client, type, mode);

native fm_cs_get_user_zoom(client);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/

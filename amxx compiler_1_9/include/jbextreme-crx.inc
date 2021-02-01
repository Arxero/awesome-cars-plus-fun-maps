#if defined _jbextreme_crx_included
    #endinput
#endif

#define _jbextreme_crx_included

#include <jbextreme-crx_const>

forward jb_simon_selected(id)
forward jb_simon_reset(JBSimonReset:reason)
native get_jail_day()
native get_players_in_team(CsTeams:team, bool:alive = false)
native bool:is_block_weapons_enabled()
native bool:is_box_started()
native bool:is_freeday_next()
native bool:is_global_freeday()
native bool:is_last_denied()
native bool:is_player_last(id)
native bool:is_simon_allowed()
native bool:is_user_freeday(id)
native bool:is_user_nomic(id)
native bool:is_user_revolt(id)
native bool:is_user_simon(id)
native bool:is_user_simon_talking(id)
native bool:is_user_simon_voice(id)
native bool:is_user_wanted(id)
native open_jail_doors()
native set_user_freeday(id, admin = 0)
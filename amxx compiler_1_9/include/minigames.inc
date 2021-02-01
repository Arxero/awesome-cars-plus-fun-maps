#if defined _minigames_included
  #endinput
#endif
#define _minigames_included

enum ( <<=1 )
{
	FLAG_OPENWORLD=1,
	FLAG_NODAMAGE,
	FLAG_TURNSYSTEM,
	FLAG_NOKNIFE,
	FLAG_RANDOMSPAWN,
	FLAG_NOCAGE,
	FLAG_REMOVEWEAPONBOX
}
enum 
{
	STATUS_AVAIBLE,
	STATUS_INSTALLING,
	STATUS_RUNNING
}

enum
{
	SELECT_AVAIBLE,
	SELECT_DISABLE,
	SELECT_DONTSHOW
}

native mg_add_gametype(name[32], flags)
	// Returns gametypeID

native mg_get_players(gameid, players[])
	// Returns playernum

native mg_get_randomspot(entity, Float:flOrigin[3])


native mg_get_type(id)
native mg_get_game(id)
native mg_get_gameid(id)
native mg_get_turn(game)

native mg_set_nextturn(gameid)

native mg_game_end(game, winner)

forward mg_game_select(type)
forward mg_game_stop(type, game, winner)
forward mg_game_turn(type, game, id, previd)

forward mg_player_spawn(type, game, id)
forward mg_player_leave(type, game, id)
forward mg_player_killed(type, game, victim, killer)

forward mg_game_start_pre(type, game, owner)
forward mg_game_start_post(type, game, owner)

forward mg_game_gamble_accept(type, game, id, cash)
forward mg_game_gamble_join(type, game, id, cash)
forward mg_game_gamble_amount(type, game, id, cash)
forward mg_game_gamble_win(type, game, id, cash)
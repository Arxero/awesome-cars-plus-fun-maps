#if defined _lottery_api_included
	#endinput
#endif

#define _lottery_api_included

// For the native lottery_set_description
const LOTTERY_COST = 0;
const LOTTERY_REWARD = 1;

// Set the description of the cost or reward (in format style).
native lottery_set_description(const Which = LOTTERY_COST, const Description[] = "", any:...);

// Set the number of options for the players to choose.
native lottery_set_options_num(const OptionsNum);

// Sets the minimun number of participants for the lottery.
native lottery_set_min_participants(const MinParticipants);

// Forces a lottery to start. Returns true on success, false if the lottery couldn't begin.
native bool:lottery_force_start();

// Returns the seconds (float with ms) remaining for the next lottery, 0.0 if a lottery is in progress.
// Returns < 0 if there is not a next lottery.
native Float:lottery_time_remaining();

// Called when a lottery is ready to start.
// This is the only correct place to call the natives lottery_set_*
// Return PLUGIN_HANDLED to stop the lottery from beginning.
forward lottery_start();

// Called when someone wants to participate. Here we must check if the player can pay.
// Return PLUGIN_HANDLED if the player can't pay.
forward lottery_check(id);

// After checking that the player can pay the lottery, this is called.
// Here we collect the cost from the player.
forward lottery_pay(id);

// This forward is called if someone payed to play but the lottery didn't start.
// Here we refund the cost to the player.
forward lottery_refund(id);

// This forward is called when a player won the lottery. Here we give the reward to the player.
forward lottery_give_reward(id);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10250\\ f0\\ fs16 \n\\ par }
*/

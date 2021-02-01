#if defined _hnsxp_stocks_included
	#endinput
#endif
#define _hnsxp_stocks_included

/*
 * Calculates the XP required to buy a certain item's level
 * 
 * @param		first_xp - The xp required for the first level
 * @param		interval - The interval between levels
 * @param		level - The level to find xp required
 * 
 * @return		Returns the XP required.
 * 
 */
stock hnsxp_calculate_xp(const first_xp, const interval, const level)
{
	if( level == 0 )
	{
		return 0;
	}
	
	new xp = first_xp;
	if( interval == XP_INTERVAL_EXPONENTIAL )
	{
		xp *= (1 << (level - 1));
	}
	else if( interval != XP_INTERVAL_NONE && interval > 0 )
	{
		xp += (interval * (level - 1));
	}
	
	return xp;
}

/* 
 * Calculates the value of the item based on the current level, max level, and max value.
 * 
 * @param		level - The level of which the value is being found
 * @param		max_level - The maximum level of the item
 * @param		max_value - The value acquired on the maximum level
 * 
 * @return		The value of the item for the given level
 * 
 */
stock hnsxp_calculate_value(const level, const max_level, const max_value)
{
	return (max_value * level / max_level);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/

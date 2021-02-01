/*
	    Bit functions
	
	  by  Lulu the hero
	(m_lajos@hotmail.com)

https://forums.alliedmods.net/showthread.php?t=144645
	
Last update(dd.mm.yyyy): 03.03.2011.

These set of stocks/defines ease up bit manipulations.

This file is provided as is (no warranties).
*/

#if defined _bit_included
	#endinput
#endif

#define _bit_included

#if cellbits == 32
	#define cellnibbles				8
	#define player_to_flag(%1)		(1 << (%1 & 31))
#else
	#define cellnibbles				16
	#define player_to_flag(%1)		(1 << %1)
#endif

#define bit_to_flag(%1)				(1 << %1)

#define COUNT_BIT					1
#define COUNT_NIBBLE				4

new const HEXCHARS[] = "0123456789ABCDEF";

/* ----- in the functions below %1 is the integer, %2 is the player's id/bitnumber ----- */

// Negate a bit - with XOR
#define toggle_player_flag(%1,%2)	(%1 = %1 ^ player_to_flag(%2))
#define toggle_flag(%1,%2)			(%1 = %1 ^ bit_to_flag(%2))

// Clear a bit - set it to 0 with NAND
#define clear_player_flag(%1,%2)	(%1 = %1 & ~player_to_flag(%2))
#define clear_flag(%1,%2)			(%1 = %1 & ~bit_to_flag(%2))

// Set a bit - set is to 1 with OR
#define set_player_flag(%1,%2)		(%1 = %1 | player_to_flag(%2))
#define set_flag(%1,%2)				(%1 = %1 | bit_to_flag(%2))

// Returns a bit's value - with AND
#define is_player_flag_set(%1,%2)	(%1 & player_to_flag(%2))
#define is_flag_set(%1,%2)			(%1 & bit_to_flag(%2))

// Converts the integer to a binary number string
// ( max string length is cellbits )
stock num_to_binstr(num, dest[], zero_fill = 0)
{
	dest[0] = 0;
	new len = (zero_fill ? cellbits : get_highest(num, COUNT_BIT));
	for(new i = 0; i < len; i++)
	{
		dest[len - i] = ((num >> i) & 1) + '0';
	}
	len++;
	dest[len] = 0;
	return len;
}

// Converts the integer to a hexadecimal number string
// ( max string length is cellnibbles )
stock num_to_hexstr(num, dest[], zero_fill = 0)
{
	dest[0] = 0;
	new len = (zero_fill ? cellnibbles : get_highest(num, COUNT_NIBBLE));
	for(new i = 0; i < len; i++)
	{
		dest[len - i] = HEXCHARS[((num >> (i << 2)) & 15)];
	}
	len++;
	dest[len] = 0;
	return len;
}

// Rotates an integer's bits to left
stock rol(integer, step = 1)
{
	if(step >= cellbits)
	{
		step = step % cellbits;
	}
	if(!step)
	{
		return integer;
	}
	new overflow = integer;
	integer <<= step;
	overflow >>= (cellbits - step);
	return integer | overflow;
}

// Rotates an integer's bits to right
stock ror(integer, step = 1)
{
	if(step >= cellbits)
	{
		step = step % cellbits;
	}
	if(!step)
	{
		return integer;
	}
	new overflow = integer;
	integer >>= step;
	overflow <<= (cellbits - step)
	return integer | overflow;
}

// Gets the highest bit/nibble
stock get_highest(integer, count_type = COUNT_BIT)
{
	new num = 0;
	if(integer) num++;
	while (integer >>= count_type)
	{
		num++;
	}
	return num;
}

// Counts the 1 bits in a number
stock count_bits(integer)
{
	new cnt;
	for(cnt = 0; integer; cnt++)
	{
		integer &= integer - 1;
	}
	return cnt;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1038\\ f0\\ fs16 \n\\ par }
*/

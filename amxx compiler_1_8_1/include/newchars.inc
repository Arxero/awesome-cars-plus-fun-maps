#if defined _newchars_included
	#endinput
#endif

#define _newchars_included

#if !defined _amxmodx_included
	#include <amxmodx>
#endif

new const chNewChars[] = {
	'π',
	'Û',
	'Í',
	'ø',
	'ü',
	'≥',
	'Ò',
	'Ê',
	'ú',
	
	'•',
	'”',
	' ',
	'Ø',
	'è',
	'£',
	'—',
	'∆',
	'å'
};

new const iUTF8_HEX[sizeof chNewChars][] = { 
	{0xFFFFFFC4,  0xFFFFFF85, 0}, 	// π
	{0xFFFFFFC3,  0xFFFFFFB3, 0}, 	// Û
	{0xFFFFFFC4,  0xFFFFFF99, 0},	// Í
	{0xFFFFFFC5,  0xFFFFFFBC, 0},	// ø
	{0xFFFFFFC5,  0xFFFFFFBA, 0},	// ü
	{0xFFFFFFC5,  0xFFFFFF82, 0},	// ≥
	{0xFFFFFFC5,  0xFFFFFF84, 0},	// Ò
	{0xFFFFFFC4,  0xFFFFFF87, 0},	// Ê
	{0xFFFFFFC5,  0xFFFFFF9B, 0},	// ú
	
	{0xFFFFFFC4,  0xFFFFFF84, 0}, 	// •
	{0xFFFFFFC3,  0xFFFFFF93, 0}, 	// ”
	{0xFFFFFFC4,  0xFFFFFF98, 0}, 	//  
	{0xFFFFFFC5,  0xFFFFFFBB, 0}, 	// Ø
	{0xFFFFFFC5,  0xFFFFFFB9, 0}, 	// è
	{0xFFFFFFC5,  0xFFFFFF81, 0}, 	// £
	{0xFFFFFFC5,  0xFFFFFF83, 0}, 	// —
	{0xFFFFFFC4,  0xFFFFFF86, 0}, 	// ∆
	{0xFFFFFFC5,  0xFFFFFF9A, 0} 	// å
};

stock newChar(const chWhich, sArray[], iLen){
	new bool:bCanBreak = false;
	for(new i = 0 ; i < sizeof chNewChars ; i ++){
		if(chNewChars[i] == chWhich){
			add(sArray, iLen, iUTF8_HEX[i]);
			bCanBreak = true;
		}
		if(bCanBreak) break;
	}
}

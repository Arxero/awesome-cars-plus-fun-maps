/*
	Model Changer

	by Hattrick
*/

#if defined _model_changer_included
	#endinput
#endif // defined _model_changer_included

#define _model_changer_included

#include "svn_version.inc"

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib model_changer

	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib model_changer
	#endif // !defined AMXMODX_NOAUTOLOAD
#else // AMXX_VERSION_NUM < 175
	#pragma library model_changer
#endif // AMXX_VERSION_NUM >= 175

/*
	Changes the player's model to the model you want.
*/
native set_user_model( _index, _model[ ] );

/*
	Receives the name of the player's model.
*/
native get_user_model( _index, _model[ ], _length );

/*
	Resets the player's model.
*/
native reset_user_model( _index );


/*
	Crypt
	v0.1
	by bugsy
*/

#if defined _crypt_included
	#endinput
#endif
#define _crypt_included

const CRYPT_MAX_LEN = 512;

enum CryptInfo
{
	C_Len,
	C_String[ CRYPT_MAX_LEN + 1 ],
	bool:C_IsEncrypted
}

stock CreateCrypt( Crypt[ CryptInfo ] , const szSource[] )
{
	if ( ( Crypt[ C_Len ] = strlen( szSource ) ) > CRYPT_MAX_LEN )
		return ( Crypt[ C_Len ] = 0 );
	
	Crypt[ C_IsEncrypted ] = false;
	return copy( Crypt[ C_String ] , clamp( Crypt[ C_Len ] , 1 , CRYPT_MAX_LEN ) , szSource );
}

stock CryptString( Crypt[ CryptInfo ] , const szKey[] )
{
	new iSrcPos , iKeyPos , iKeyLen;
	
	if ( !( iKeyLen = strlen( szKey ) ) )
		return 0;

	for ( iSrcPos = 0 , iKeyPos = 0 ; iSrcPos < Crypt[ C_Len ] ; iSrcPos++ )
	{
		Crypt[ C_String ][ iSrcPos ] = Crypt[ C_String ][ iSrcPos ] ^ szKey[ iKeyPos ];
	
		if ( ++iKeyPos == iKeyLen )
			iKeyPos = 0;
	}
	
	//I get a warning with: var = !var
	Crypt[ C_IsEncrypted ] = Crypt[ C_IsEncrypted ] ? false : true;

	return iSrcPos;
}  

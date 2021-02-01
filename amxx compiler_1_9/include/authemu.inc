#if defined _authemu_included
	#endinput
#endif

#define _authemu_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib authemu
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib authemu
	#endif
#else
	#pragma library authemu
#endif

#include <authemu_version.inc>

#if (AMXX_VERSION_NUM >= 183)
#pragma deprecated Use aci_tag instead it.
#define aci_packname aci_tag
#endif

/**
* enum authemu_os_type
*/
enum authemu_os_type
{
	aos_unknown,
	aos_win95,
	aos_win98,
	aos_winME,
	aos_winNT_4,
	aos_win2000,
	aos_winXP,
	aos_winXPx64Edition,
	aos_winServer2003,
	aos_winHomeServer,
	aos_win2003R2,
	aos_winVista,
	aos_winServer2008,
	aos_winServer2008R2,
	aos_win7,
	aos_winServer2012,
	aos_win8,
	aos_winServer2012R2,
	aos_win81,
	aos_winServer2016,
	aos_win10
};

/**
* enum authemu_client_info
*/
enum authemu_client_info
{
	/*
	* Description:      The build number.
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_build = 0,

	/*
	* Description:      The build hash. (NOTE: It's not unique ID of client)
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_hash,

	/*
	* Description:      Last unix-time when the client was updated.
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_lasttime_upd,

	/*
	* Description:      The tag name of the branch.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_tag,

	/*
	* Description:      This means that the client run on Steam.
	* Data type:        bool
	* Get params:       bool:aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_steam,

	/*
	* Description:      This means that the client run on '-beta'.
	* Data type:        bool
	* Get params:       bool:aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_beta,

	/*
	* Description:      This means that the client synchronized to depot.
	* Data type:        bool
	* Get params:       bool:aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_synchronized,

	/*
	* Description:      The unique hash ID of client.
	* Data type:        char [65]
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_unique_id,

	/*
	* Description:      Type of operating system that the client uses.
	* Data type:        enum authemu_os_type
	* Get params:       authemu_os_type:aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_OS_type,

	/*
	* Description:      Name of operating system that the client uses.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_OS_name,

	/*
	* Description:      The build OS number.
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_OS_build,

	/*
	* Description:      The number of the major version OS.
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_OS_majorVersion,

	/*
	* Description:      The number of the minor version OS.
	* Data type:        int
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type);
	*/
	aci_OS_minorVersion,

	/*
	* Description:      The brand name of the processor.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_CPU_name,

	/*
	* Description:      The ID of the processor 'AS IS'.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_CPU_id,

	/*
	* Description:      The brand name of the graphics processor.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_GPU_name,

	/*
	* Description:      The ID of the graphics processor 'AS IS'.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_GPU_id,

	/*
	* Description:      The name of the user agent who serves the client.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_useragent,

	/*
	* Description:      The branch name of the branch.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_branch,

	/*
	* Description:      The fork name of the branch if present.
	* Data type:        char *
	* Get params:       aemu_get_clientinfo(const index, authemu_client_info:aci_type, dest[], const lenght);
	*/
	aci_fork
};

/*
* Check if the client is authemu
*
* @param index           Client index
*
* @return                return true if so, false otherwise
*
*/
native bool:is_user_authemu(const index);

enum DAC_QueryType
{
	DAC_QUERY_DETECT = 0,
};

forward aemu_dac_query(const id, const DAC_QueryType:type);

/*
* Get the client info.
* @note: Use the aci_* authemu_client_info enum
*
* @param index           Client index
* @param type            Use the aci_* authemu_client_info enum
*
*/
native any:aemu_get_clientinfo(const index, const authemu_client_info:type, any:...);

/*
* Get the current game screen resolution of the client.
*
* @param index           Client index
* @param wide            Variable to store wide in
* @param tall            Variable to store tall in
*
* @return                return true if so, false otherwise
*
*/
native bool:aemu_get_game_screeninfo(const index, &wide = 0, &tall = 0);

/*
* Get the current desktop screen resolution of the client.
*
* @param index           Client index
* @param wide            Variable to store wide in
* @param tall            Variable to store tall in
*
* @return                return true if so, false otherwise
*
*/
native bool:aemu_get_desk_screeninfo(const index, &wide = 0, &tall = 0);

/*
* Gets the specified type of reason.
* @note: Use this native only inside the forward 'aemu_dac_query'
*
* @return                type of reason
*
*/
native aemu_dac_get_reason();

/*
* Gets the DAC name of the suspicious module.
* @note: Use this native only inside the forward 'aemu_dac_query' and for reason 2,3 only
*
* @param output          Buffer to copy module name to
* @param lenght          Maximum buffer size
* @param path            Provides full path of the module name
*
* @return                return true if so, false otherwise
*
*/
native bool:aemu_dac_get_module(output[], const lenght, bool:path = false);

/*
* Gets the DAC hash of the suspicious module.
* @note: Use this native only inside the forward 'aemu_dac_query' and for reason 2,3 only
*
* @return                return hash of the suspicious module
*
*/
native aemu_dac_get_module_hash();

/*
* Set's CVar filter that a client obliged to adhere is specified.
*
* @param index           Client index
* @note                  Set to 0 for use common filter
*
* @param name            CVar name
* @param value           CVar value
* @optional              Use min/max params instead value param for the same purpose,
*                        but with clamp filter as 'aemu_set_filter_cvar(id, "ex_interp", 0.01, 0.1)'
*
* @param max             The max threshold value of CVar
* @note                  If param is specified, then value param it's min threshold
*
*
* @noreturn
*
*/
native aemu_set_filter_cvar(const index, const name[], const Float:value /*const Float:min*/, const Float:max = -999.0 /* unset */);

/*
* Unset CVar filter
*
* @param index           Client index
* @note                  Set to 0 for use common filter
*
* @param name            CVar name
*
* @noreturn
*
*/
native aemu_unset_filter_cvar(const index, const name[]);

/**
* enum BranchType
*/
enum BranchType
{
	BRANCH_MASTER = 0,
	BRANCH_BETA,
	BRANCH_FORK,
};

/*
* Determine whether specified branch is in use.

* @param index           Client index
* @param type            Use the BRANCH_* BranchType enum
*
* @return                return true if so, false otherwise
*/
native bool:aemu_is_user_branch(const index, BranchType:type);

/*
* This is the callback from the module that gives major/minor versions for verifying compatibility for AuthEmu versions.
* If an AMXX plugin gets a failure, then you do need to upgrade to the latest version of the AuthEmu module or update the files included for AMXX plugins.
* Do not modify this!
*/
public __authemu_version_check(const majorVersion, const minorVersion)
{
	if (majorVersion != AUTHEMU_VERSION_MAJOR)
	{
		new temp[512];
		formatex(temp, sizeof temp - 1, "[AuthEmu]: Api major version mismatch; expected %d, real %d", AUTHEMU_VERSION_MAJOR, majorVersion);
		set_fail_state(temp);
		return;
	}

	if (minorVersion < AUTHEMU_VERSION_MINOR)
	{
		new temp[512];
		formatex(temp, sizeof temp - 1, "[AuthEmu]: Api minor version mismatch; expected at least %d, real %d", AUTHEMU_VERSION_MINOR, minorVersion);
		set_fail_state(temp);
		return;
	}
}

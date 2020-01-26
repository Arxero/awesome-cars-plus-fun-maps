#include <amxmodx>
#include <reapi>

new Float:g_flBoostCooldown[MAX_PLAYERS + 1];
new Float:cVal_flLeapCooldown, cVal_LeapPower, Float:cVal_flLeapHeight;

public plugin_init()
{
	register_plugin("[ReAPI] Knife Boost", "0.0.1", "blazz3r");
	
	bind_pcvar_float(register_cvar("leap_cooldown","3.0"), cVal_flLeapCooldown)
	bind_pcvar_num(register_cvar("leap_power","300"), cVal_LeapPower)
	bind_pcvar_float(register_cvar("leap_height","265.0"), cVal_flLeapHeight)
	
	RegisterHookChain(RG_CBasePlayer_PreThink, "RG__CBasePlayer_PreThink", .post = false)
}

public RG__CBasePlayer_PreThink(const id)
{
	if(!is_user_alive(id))
	{
		return;
	}

	static iCurWpnEnt, iWeapon, iButton, iOldButton
	iCurWpnEnt = get_member(id, m_pActiveItem);
	iWeapon = get_member(iCurWpnEnt, m_iId);

	if(iWeapon != CSW_KNIFE)
	{
		return;
	}

	iButton = get_entvar(id, var_button);
	iOldButton = get_entvar(id, var_oldbuttons);

	if(iButton & IN_ATTACK2 && !(iOldButton & IN_ATTACK2))
	{
		if(get_entvar(id, var_flags) & FL_ONGROUND)
		{
			return;
		}
		
		new Float:flCurrentTime = get_gametime();
		if((flCurrentTime - g_flBoostCooldown[id]) < cVal_flLeapCooldown)
		{
			return;
		}
		
		new Float:flVelocity[3];
		get_entvar(id, var_velocity, flVelocity);
		if(flVelocity[0] == 0.0 && flVelocity[1] == 0.0)
		{
			return;
		}
		
		g_flBoostCooldown[id] = flCurrentTime;
		
		new Float:flLeapVelocity[3];
		velocity_by_aim(id, cVal_LeapPower, flLeapVelocity);
	
		flLeapVelocity[2] = cVal_flLeapHeight;
	
		set_entvar(id, var_velocity, flLeapVelocity);	
	}
}
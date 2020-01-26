#include <amxmodx>
#include <fakemeta>

new p_flag

new const szKnifeModels[][][] =
{
    /*Pyt kym v_modela*/    /*Pyt kym p_modela*/
    {"models/karambit.mdl", "models/p_knife.mdl"}, //T Models
    {"models/butterfly.mdl", "models/p_knife.mdl"}  //CT Models
}

public plugin_init()
{
    register_plugin("Admin Knife Models", "1.0", "nEpBep3HuK")
    register_event("CurWeapon", "current_weapon", "b", "1=1", "2=29")
    p_flag = register_cvar("admin_knife_flag", "t") //Flag nujen za nojovite.
}

public plugin_precache()
    for(new i; i<sizeof(szKnifeModels); i++)
        for(new a; a<sizeof(szKnifeModels[]); a++)
            precache_model(szKnifeModels[i][a])

public current_weapon(id)
{
    new szFlag[8]
    get_pcvar_string(p_flag, szFlag, charsmax(szFlag))
    if(get_user_flags(id) & read_flags(szFlag))
    {
        switch(get_user_team(id))
        {
            case 1:
            {
                set_pev(id, pev_viewmodel2, szKnifeModels[0][0])
                set_pev(id, pev_weaponmodel2, szKnifeModels[0][1])
            }
            case 2:
            {
                set_pev(id, pev_viewmodel2, szKnifeModels[1][0])
                set_pev(id, pev_weaponmodel2, szKnifeModels[1][1])
            }
        }
    }
}
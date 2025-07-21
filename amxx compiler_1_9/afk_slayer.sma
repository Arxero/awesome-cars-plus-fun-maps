#include <amxmodx>  
#include <amxmisc>  
#include <hamsandwich>  
#include <fakemeta>  

#define TIME 30.0  

new Float:player_origin[33][3];  

public plugin_init()  
{  
    RegisterHam(Ham_Spawn, "player", "e_Spawn", 1);  
}  

public e_Spawn(id)  
{
    if(get_user_team(id) != 2)
        return;
    remove_task(id)  
    
    if(is_user_alive(id))  
    {  
        set_task(0.8, "get_spawn", id);  
    }
}  

public get_spawn(id)  
{
    pev(id, pev_origin, player_origin[id]);  
    set_task(TIME, "check_afk", id);  
}  

public check_afk(id)  
{  
    if(is_user_alive(id))  
    {  
        if(same_origin(id))  
        {  
            user_kill(id);  
            new name[33];  
            get_user_name(id, name, 32);  
            client_print(0, print_chat,  "%s was killed for AFK.", name); // fixed error here too  
        }  
    }  
}  

public same_origin(id)  
{  
    new Float:origin[3];  
    pev(id, pev_origin, origin);  
    for(new i = 0; i < 3; i++)  
        if(origin[i] != player_origin[id][i])  
        return 0;  
    return 1;  
} 
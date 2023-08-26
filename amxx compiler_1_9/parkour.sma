#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

// P.S. unreleased feature - ctrl slide after sprint-jump-etc, mb next time

#define PLUGIN                      "[Next21.ru] Parkour"
#define VERSION                     "2.4.2 - Cut and run" // Fixed by Bladefield on 22-09-2020 (second time)
#define AUTHOR                      "Chrescoe1, Next21 Team"


// Linux extra offsets
#define extra_offset_weapon         4
#define extra_offset_player         5


// CBasePlayerItem                              https://wiki.alliedmods.net/CBasePlayerItem_(CS)
#define m_flPinPulledOutTime        31      //  float   'Pinpull' grenade time, -1.0 - disabled
#define m_iId                       43      //  int  CSW_*.


// CBasePlayerWeapon                            https://wiki.alliedmods.net/CBasePlayerWeapon_(CS)
#define m_flNextPrimaryAttack       46      //  float    Soonest time ItemPostFrame will call PrimaryAttack.
#define m_flNextSecondaryAttack     47      //  float    Soonest time ItemPostFrame will call SecondaryAttack.
#define m_flTimeWeaponIdle          48      //  float    Soonest time ItemPostFrame will call WeaponIdle.
#define m_fInReload                 54      //  int      Are we in the middle of a reload ?


// CBaseMonster                                 https://wiki.alliedmods.net/CBaseMonster_(CS)
#define m_flNextAttack              83      //  float    Cannot attack again until this time.


// CBasePlayer                                  https://wiki.alliedmods.net/CBasePlayer_(CS)
#define m_iFOV                      363     //  int  Field of view.
#define m_pActiveItem               373     //  CBasePlayerItem*    (get_pdata_cbase)
#define m_pLastItem                 375     //  CBasePlayerItem*    (get_pdata_cbase)


// Resources
#define MODEL_V_STRLEN              64
#define MODEL_V                     "models/next21/v_actions_default.mdl"
// #define MODEL_V_CLIMBS              "models/next21/v_actions2.mdl"
#define SOUND_WALLJUMP              "next21/jump.wav"

// MODEL_V sequences
enum //MODEL_V_SEQUENCES:
{
    IDLE = 0,
    DEATH,
    DEATH_IDLE,
    SWIM,
    SPRINT_IDLE,
    JUMP_START,
    JUMP_IDLE,
    JUMP_END,
    PUNCH_HIT_1,
    PUNCH_HIT_2,
    PUNCH_MISS_1,
    PUNCH_MISS_2,
    CLIMB_L,
    CLIMB_H 
}

// My hull check types
enum{
    CHECK_NONE,
    CHECK_CLIMB,
    CHECK_WALL
}
#define CHECKHULL_MINCLIMBNORMAL    0.8             // climb only of floor normal(Z) >= 0.8
#define CHECKHULL_MINWALLNORMAL     0.2             // walljump only of wall normal(Z) < 0.2

// Server const
#define MAXPLAYERS                  33              // ServerSlots + 1
#define FOV_NORMAL                  90              // Default player FOV


// Player entity
#define ENTITY_REFERANCE_PLAYER     "player"        // Player entity classname


// Ability settings
#define SPRINT_TAPTIME              0.15            // Button taptime interval to enable sprint

// player normal maxspeed 260(with scout), limit cl_forwardspeed 450, >> we can add 190... 
#define SPRINT_SPEED_START          40.0            // default sprint speedup
#define SPRINT_SPEED_MAX            150.0           // max bonus sprint speedup by time
#define SPRINT_SPEED_MAXTIME        3.0             // time is here
#define SPRINT_ZVEL                 256.0            // if abs(velocity) > 256.0 - drop sprint


#define JUMP_PUSH_DEFAULT           250.0           // Default 'jump power'
#define JUMP_PUSH_MAX               100.0           // New add 'jump power'
#define JUMP_PUSH_MAXTIME           5.0             // Time to earn max push velocity ('jump power') (default=min, default*pushmax = max, rescaled by time 0..maxtime)

// #define CLIMB_STEP  -6.0
#define CLIMB_LOW                   16.0            // Low climb dist (Z)
#define CLIMB_HIGH                  32.0            // High climb dist (Z)

#define CLIMB_PUNSHANGLE            12.0            // Punch by angle[0]
#define CLIMB_PUSHFOW               200.0           // Forward push velocity (XY)
#define CLIMB_PUSHUPL               260.0           // Up push at CLIMB_LOW distance (Z)
#define CLIMB_PUSHUPH               330.0           // Up push at CLIMB_HIGH distance (Z)
#define CLIMB_LIMIT                 32.0            // Climb limit distance (Z)
#define PLAYER_SIZE_SIDE            12.0            // Dist to check climb free hull(XY)
#define CLIMB_FALLLIM               -650.0          // if you fall with velocity(Z) < -650 - you can't use climb

#define WALLJUMP_PUNCHANGLE         8.0             // Punch by angle[0]
#define WALLJUMP_PUSH               240.0           // Walljump push force (Z)
#define WALLJUMP_COUNT              2               // Walljumps count
#define WALLJUMP_CHECK_DIST         22.0            // Walljump max dist to wall (XY)
#define WALLJUMP_MINVEL             80.0            // Walljump min 'fallforce' to use; walljump only if velocity(Z) > WALLJUMP_MINVEL
#define WALLJUMP_FALLLIM            -300.0          // if you fall with velocity(Z) < -300 - you can't use walljump

#define FALL_VELOCITY               -250.0          // Z Velocity to enable fallhand state 

// View model controller
new 
    strUserModel[MODEL_V_STRLEN],
    strViewModel[MAXPLAYERS][MODEL_V_STRLEN],
    // strWeaponModel[MAXPLAYERS][MODEL_V_STRLEN],
    bool:hasNewView[MAXPLAYERS],
    userSprintSpeed[MAXPLAYERS];

// Lock stats
new 
    bool:isWalk[MAXPLAYERS],
    bool:isMove[MAXPLAYERS],
    bool:isLock[MAXPLAYERS];

new maxPlayers;

_UpdateViewModel(const iPlayer)
{
    // if(hasClimbModel[iPlayer])
    // {
    //     _UpdateClimbModel(iPlayer);
    //     return;
    // }

    pev(iPlayer,pev_viewmodel2,strUserModel,MODEL_V_STRLEN - 1);
    
    if(!equal(strUserModel, MODEL_V))
    {
        hasNewView[iPlayer] = true;
        pev(iPlayer, pev_viewmodel2, strViewModel[iPlayer], MODEL_V_STRLEN - 1);
        set_pev(iPlayer, pev_viewmodel2, MODEL_V);

        // pev(iPlayer, pev_weaponmodel2, strWeaponModel[iPlayer], MODEL_V_STRLEN - 1);
        // set_pev(iPlayer, pev_weaponmodel2, "");
        return true;
    }
    return false;
}

_DropViewModel(const iPlayer)
{
    if(!hasNewView[iPlayer])
    {
        return;
    }

    hasNewView[iPlayer] = false;
    set_pev(iPlayer, pev_viewmodel2, strViewModel[iPlayer]);
    // set_pev(iPlayer, pev_weaponmodel2, strWeaponModel[iPlayer]);
}

// _UpdateClimbModel(const iPlayer)
// {
//     pev(iPlayer,pev_viewmodel2,strUserModel,MODEL_V_STRLEN - 1);
    
//     if(!equal(strUserModel, MODEL_V_CLIMBS))
//     {
//         if(!equal(strUserModel, MODEL_V))
//         {
//             hasClimbModel[iPlayer] = true;
//             pev(iPlayer, pev_viewmodel2, strViewModel[iPlayer], MODEL_V_STRLEN - 1);

//             pev(iPlayer, pev_weaponmodel2, strWeaponModel[iPlayer], MODEL_V_STRLEN - 1);
//         }
//         set_pev(iPlayer, pev_viewmodel2, MODEL_V_CLIMBS);
//         set_pev(iPlayer, pev_weaponmodel2, "");

//         return true;
//     }
//     return false;
// }

// _DropClimbModel(const iPlayer)
// {
//     hasClimbModel[iPlayer] = false;
//     if(hasNewView[iPlayer])
//     {
//         _UpdateViewModel(iPlayer);
//     }
//     else
//     {
//         set_pev(iPlayer, pev_viewmodel2, strViewModel[iPlayer]);
//         set_pev(iPlayer, pev_weaponmodel2, strWeaponModel[iPlayer]);
//     }
// }

// Player speed controller
new 
    bool:hasNewSpeed[33],
    Float:fBaseSpeed[33],
    Float:fNewSpeed[33];

_SetPlayerSpeed(const iPlayer, const Float:fSpeedUp)
{
    // pev(iPlayer, pev_maxspeed, fBaseSpeed[iPlayer]);
    static Float:fUserSpeed;
    pev(iPlayer, pev_maxspeed, fUserSpeed);

    if(!hasNewSpeed[iPlayer])
    {
        fBaseSpeed[iPlayer] = fUserSpeed;
        hasNewSpeed[iPlayer] = true;
        fNewSpeed[iPlayer] = fBaseSpeed[iPlayer] + fSpeedUp;
    }
    else
    {
        if(fUserSpeed != fNewSpeed[iPlayer])
        {
            // client_print(iPlayer ,print_chat, "Something gonna wrong, reset speed");
            fBaseSpeed[iPlayer] = fUserSpeed;
        }

        fNewSpeed[iPlayer] = fBaseSpeed[iPlayer] + fSpeedUp;
    }
    _UpdateViewModel(iPlayer);
    set_pev(iPlayer, pev_maxspeed, fNewSpeed[iPlayer]);
    engfunc(EngFunc_SetClientMaxspeed, iPlayer, fNewSpeed[iPlayer]);
}

_DropPlayerSpeed(const iPlayer)
{
    hasNewSpeed[iPlayer] = false;
    set_pev(iPlayer, pev_maxspeed, fBaseSpeed[iPlayer]);
    engfunc(EngFunc_SetClientMaxspeed, iPlayer, fBaseSpeed[iPlayer]);
}

// _ControlPlayerSpeed(const iPlayer)
// {
//     if(!hasNewSpeed[iPlayer])
//         return;

//     static Float:fUserSpeed;
//     pev(iPlayer, pev_maxspeed, fUserSpeed);

//     if(fUserSpeed == 1.0)
//     {
//         hasNewSpeed[iPlayer] = false;
//         return;
//     }

//     if(fUserSpeed != fNewSpeed[iPlayer])
//     {
//         static Float:speedDifRange;
//         speedDifRange = fUserSpeed - fBaseSpeed[iPlayer];
//         _SetPlayerSpeed(iPlayer, fNewSpeed[iPlayer] + speedDifRange);
//     }
// }

// Ability controller
// new bool:_inAction[MAXPLAYERS];


new bool:_inSprint[MAXPLAYERS],
    bool:_inSwim[MAXPLAYERS],
    bool:_inJump[MAXPLAYERS],
    Float:fSprintStartTime[MAXPLAYERS],
    bool:_inClimb[MAXPLAYERS],
    Float:climbAnimTime[MAXPLAYERS],
    bool:_climbType[MAXPLAYERS],
    _climbAnim[MAXPLAYERS],
    _wallJumps[MAXPLAYERS],
    bool:_inFall[MAXPLAYERS],
    Float:_fallAnimTime[MAXPLAYERS];

_DropAllActions(const iPlayer)
{
    // if(!_inAction[iPlayer])
    // {
    //     return;
    // }


    if(_inSprint[iPlayer])
    {
        _inSprint[iPlayer] = false;
    }
    if(_inSwim[iPlayer])
    {
        _inSwim[iPlayer] = false;
    }
    if(_inJump[iPlayer])
    {
        _inJump[iPlayer] = false;
    }
    if(_inClimb[iPlayer])
    {
        _inClimb[iPlayer] = false;
    }
    if(hasNewView[iPlayer])
    {
        hasNewView[iPlayer] = false;
    }
    if(_inFall[iPlayer])
    {
        _inFall[iPlayer] = false;
    }
    // _inAction[iPlayer] = false;
}

// Walljump action
_setWallJump(const iPlayer, const iActiveItem)
{
    if(_inFall[iPlayer])
        _inFall[iPlayer] = false;

    if(_wallJumps[iPlayer] <= 0) return;
    //if(//_tryClimbAction(iPlayer, 0.0))

    static Float:vecVelocity[3];
    pev(iPlayer, pev_velocity, vecVelocity);
    if(vecVelocity[2] >= WALLJUMP_MINVEL || vecVelocity[2] < WALLJUMP_FALLLIM)
    {
        return;
    }

    static Float:vecOrigin[3];
    pev(iPlayer, pev_origin, vecOrigin);

    static Float:vecAimAngles[3];
    pev(iPlayer, pev_v_angle, vecAimAngles);

    static Float:vecFow[3];
    vecFow[0] = vecOrigin[0] + floatcos(vecAimAngles[1], degrees) * WALLJUMP_CHECK_DIST;
    vecFow[1] = vecOrigin[1] + floatsin(vecAimAngles[1], degrees) * WALLJUMP_CHECK_DIST;
    vecFow[2] = vecOrigin[2];

    if(isFreeHull(vecOrigin, vecFow, iPlayer, CHECK_WALL) == 1.0)
    {
        if(_inSprint[iPlayer])
        {
            _DropSprintAction(iPlayer, iActiveItem);
        }

        vecVelocity[2] = WALLJUMP_PUSH;

        set_pev(iPlayer, pev_velocity, vecVelocity);

        _wallJumps[iPlayer]--;

        emit_sound(iPlayer, CHAN_BODY, SOUND_WALLJUMP, 0.3, ATTN_NORM, 0, PITCH_LOW);

        client_print(iPlayer, print_center, "Walljumps Remain: %i", _wallJumps[iPlayer]);

        static Float:punchangle[3];
        pev(iPlayer, pev_punchangle, punchangle);

        if(punchangle[0] < WALLJUMP_PUNCHANGLE)
        {
            punchangle[0] = WALLJUMP_PUNCHANGLE;//punchangle[0] += WALLJUMP_PUNCHANGLE;//15.0;
            set_pev(iPlayer, pev_punchangle, punchangle);
        }


        _LockWeaponIdleAnimation(iActiveItem);
    }

}

// Climb action
_SetClimbAction(const iPlayer, const bool:climbType, const bool:isActionBlock, const Float:fGameTime, const iActiveItem)
{
    if(_inFall[iPlayer])
        _inFall[iPlayer] = false;

    climbAnimTime[iPlayer] = fGameTime;

    if(_inSprint[iPlayer])
    {
        _DropSprintAction(iPlayer, iActiveItem);
    }
    if(_inSwim[iPlayer])
    {
        _DropSwimAction(iPlayer, iActiveItem);
    }
    if(_inJump[iPlayer])
    {
        _DropJumpAction(iPlayer, iActiveItem);
    }

    _climbType[iPlayer] = climbType;

    static Float:zCheck[33], Float:vecOrigin[3];
    pev(iPlayer, pev_origin, vecOrigin);

    if(!_inClimb[iPlayer])
    {
        _inClimb[iPlayer] = true;
        zCheck[iPlayer] = vecOrigin[2];
    }
    else
    {
        if(floatabs(zCheck[iPlayer]-vecOrigin[2]) > CLIMB_LIMIT)
        {
            return;
        }
    }

    static Float:vecVelocity[3];
    pev(iPlayer, pev_velocity, vecVelocity);
    // client_print(0,print_chat,"%..1f",vecVelocity[2]);
    if(vecVelocity[2] > CLIMB_FALLLIM && vecVelocity[2] < (climbType ? CLIMB_PUSHUPL : CLIMB_PUSHUPH) )
    {
        if(!isActionBlock && (_UpdateViewModel(iPlayer) || vecVelocity[2] < 16.0 || fGameTime - climbAnimTime[iPlayer] > (( climbType ? 29 : 22 )/*frames in weapon sequence*/ / 30.0/*framerate...*/)) )
        {
            _climbAnim[iPlayer] = (climbType? CLIMB_H : CLIMB_L);
            // hasClimbModel[iPlayer] = true;
            PlayWeaponAnim(iPlayer, _climbAnim[iPlayer], true);
            _LockWeaponIdleAnimation(iActiveItem);
            climbAnimTime[iPlayer] = fGameTime;

            static Float:punchangle[3];
            pev(iPlayer, pev_punchangle, punchangle);

            // punchangle[0] += CLIMB_PUNSHANGLE;//5.0;
            if(punchangle[0] < CLIMB_PUNSHANGLE) 
            {
                punchangle[0] = CLIMB_PUNSHANGLE;
                set_pev(iPlayer, pev_punchangle, punchangle);
            }

        }

        static Float:vecAimAngles[3];
        pev(iPlayer, pev_v_angle, vecAimAngles);
        vecVelocity[0] = floatcos(vecAimAngles[1], degrees) * CLIMB_PUSHFOW;
        vecVelocity[1] = floatsin(vecAimAngles[1], degrees) * CLIMB_PUSHFOW;
        // client_print(0,print_chat,"%..1f",vecVelocity[2] );

        // static Float:delay[MAXPLAYERS];

        // if(delay[iPlayer] <fGameTime)
        // if( vecVelocity[2] < (climbType ? CLIMB_PUSHUPL : CLIMB_PUSHUPH)*0.8 )
        // {
            // delay[iPlayer] = fGameTime + 0.2;
        vecVelocity[2] = (climbType ? CLIMB_PUSHUPL : CLIMB_PUSHUPH);
        // }

        set_pev(iPlayer, pev_velocity, vecVelocity);
        // client_print(0,print_chat,"CLIMB");
    }
}

_UpdateClimbAction(const iPlayer, const iActiveItem)
{
    // client_print(0,print_chat,"update");
    PlayWeaponAnim(iPlayer, _climbAnim[iPlayer], false);

    
    _LockWeaponIdleAnimation(iActiveItem);

}

_DropClimbAction(const iPlayer, const iActiveItem)
{
    _DropViewModel(iPlayer);
    if(!isLock[iPlayer])
        _DeployActiveItem(iPlayer, iActiveItem);
    _inClimb[iPlayer] = false;
}


// Sprint action

_SetSprintAction(const iPlayer, const iActiveItem)
{
    if(_inFall[iPlayer])
        _inFall[iPlayer] = false;

    if(_inSprint[iPlayer])
    {
        return;
    }
    _SetPlayerSpeed(iPlayer, SPRINT_SPEED_START);
    fSprintStartTime[iPlayer] = get_gametime();
    _inSprint[iPlayer] = true;
    // client_print(0, print_chat, "Sprint start: %..3f %..3f", fBaseSpeed[iPlayer], fNewSpeed[iPlayer]);
    _UpdateViewModel(iPlayer);
    PlayWeaponAnim(iPlayer, SPRINT_IDLE, true);

    
    _LockWeaponIdleAnimation(iActiveItem);

}

_DropSprintAction(const iPlayer, const iActiveItem)
{
    if(!_inSprint[iPlayer])
    {
        return;
    }
    userSprintSpeed[iPlayer] = 0;
    _DropPlayerSpeed(iPlayer);
    _DropViewModel(iPlayer);
    _inSprint[iPlayer] = false;
    //client_print(iPlayer, print_chat, "Sprint stop; defspeed: %..3f", fBaseSpeed[iPlayer]);
    client_print(iPlayer, print_center, ""/*how to empty string?*/);
    if(!isLock[iPlayer])
    {
        //client_print(0,print_chat,"DROP SPRINT")
        _DeployActiveItem(iPlayer, iActiveItem);
    }
}

_UpdateSprintAction(const iPlayer, const iFlags, const iButtons, const iOldButtons, const iActiveItem)
{
    if((iFlags & FL_ONGROUND) && (iButtons & IN_JUMP) && !(iOldButtons & IN_JUMP))
    {
        _DropSprintAction(iPlayer, iActiveItem);
        _SetJumpAction(iPlayer, iActiveItem);
        //client_print(0,print_chat,"High jump");
    }
    else
    {
        userSprintSpeed[iPlayer] += 2;

        if (userSprintSpeed[iPlayer] < 200)
            userSprintSpeed[iPlayer] = 200;

        if (userSprintSpeed[iPlayer] > 400)
            userSprintSpeed[iPlayer] = 400;

        //Some of this was inspired in +Speed 1.17 by Melanie
        new Float:returnV[3], Float:Original[3]
        VelocityByAim ( iPlayer, userSprintSpeed[iPlayer], returnV )

        pev(iPlayer,pev_velocity,Original)
        
        //Avoid floating in the air and ultra high jumps
        if (vector_length(Original) < 600.0 || Original[2] < 0.0)
            returnV[2] = Original[2]
        
        set_pev(iPlayer,pev_velocity,returnV)


        /*
        static Float:fSprintTime;
        fSprintTime = floatmin(SPRINT_SPEED_MAXTIME, get_gametime() - fSprintStartTime[iPlayer]);
        _SetPlayerSpeed(iPlayer, SPRINT_SPEED_START + SPRINT_SPEED_MAX / SPRINT_SPEED_MAXTIME * fSprintTime);


        static Float:fSprintValue;
        fSprintValue = 100.0 / SPRINT_SPEED_MAXTIME * fSprintTime;
        static Float:fJumpValue;
        fJumpValue = 100.0 / JUMP_PUSH_MAXTIME * floatmin(JUMP_PUSH_MAXTIME, get_gametime() - fSprintStartTime[iPlayer]);
        client_print(iPlayer, print_center, "Sprint: %..2f, Jump: %..2f", fSprintValue, fJumpValue);
        */

        // client_print(0, print_center, "Sprint: %..3f %..3f", fBaseSpeed[iPlayer], fNewSpeed[iPlayer]);
        _UpdateViewModel(iPlayer);
        PlayWeaponAnim(iPlayer, SPRINT_IDLE, false);

        
        _LockWeaponIdleAnimation(iActiveItem);
    }
}

// Jump action

_SetJumpAction(const iPlayer, const iActiveItem)
{
    //client_print(0,print_chat,"SET JUMP %..1f",get_gametime());
    // if(_inJump[iPlayer])
    // {
    //     return;
    // }
    _inJump[iPlayer] = true;
    _UpdateViewModel(iPlayer);
    PlayWeaponAnim(iPlayer, JUMP_START, false);

    static Float:vecVelocity[3];
    pev(iPlayer, pev_velocity, vecVelocity);

    static Float:fSprintTime;
    fSprintTime = floatmin(JUMP_PUSH_MAXTIME, get_gametime() - fSprintStartTime[iPlayer]);
    vecVelocity[2] = JUMP_PUSH_DEFAULT + JUMP_PUSH_MAX / JUMP_PUSH_MAXTIME * fSprintTime;
    //client_print(iPlayer,print_chat, "Set jump action %..3f", vecVelocity[2]);
    set_pev(iPlayer, pev_velocity, vecVelocity);

    
    _LockWeaponIdleAnimation(iActiveItem);

    _inFall[iPlayer] = true;
    _fallAnimTime[iPlayer] = get_gametime() + 0.33; //10 frames / 30 fps
}

_DropJumpAction(const iPlayer, const iActiveItem)
{
    _inFall[iPlayer] = false;
    _inJump[iPlayer] = false;
    _DropViewModel(iPlayer);
    if(!isLock[iPlayer])
        _DeployActiveItem(iPlayer, iActiveItem);
    //client_print(0,print_chat,"DROP JUMP %..1f",get_gametime());
    // client_print(iPlayer, print_chat, "Drop jump action");
}

_UpdateJumpAction(const iPlayer, const iActiveItem)
{
    //client_print(0,print_chat,"UPDATE JUMP %..1f",get_gametime());
    // if(!_inJump[iPlayer])
    // {
    //     return;
    // }
    
    // _LockWeaponIdleAnimation(iActiveItem);
    // _UpdateViewModel(iPlayer);

    // if(pev(iPlayer,pev_sequence) != JUMP_START)
    // {
    // PlayWeaponAnim(iPlayer, JUMP_START, false);
    // }
    _UpdateFallAction(iPlayer, iActiveItem)
}


// Swim action
_SetSwimAction(const iPlayer, const iActiveItem)
{
    if(_inFall[iPlayer])
        _inFall[iPlayer] = false;

    if(_inSprint[iPlayer])
    {
        _DropSprintAction(iPlayer, iActiveItem);
        // client_print(0,print_chat,"SPRINT DROP");
    }
    if(_inJump[iPlayer])
    {
        _DropJumpAction(iPlayer, iActiveItem);
    }
    _UpdateViewModel(iPlayer);
    
    _LockWeaponIdleAnimation(iActiveItem);
    PlayWeaponAnim(iPlayer, SWIM, true);
    _inSwim[iPlayer] = true;
}

_DropSwimAction(const iPlayer, const iActiveItem)
{
    _inSwim[iPlayer] = false;
    _DropViewModel(iPlayer);
    if(!isLock[iPlayer])
        _DeployActiveItem(iPlayer, iActiveItem);
}

_UpdateSwimAction(const iPlayer, const iActiveItem)
{
    _UpdateViewModel(iPlayer);
    PlayWeaponAnim(iPlayer, SWIM, false);
    
    _LockWeaponIdleAnimation(iActiveItem);
}

// Fall action

_SetFallAction(const iPlayer, const iActiveItem)
{
    _inFall[iPlayer] = true;
    _fallAnimTime[iPlayer] = get_gametime() + 0.33; //10 frames / 30 fps
    PlayWeaponAnim(iPlayer, JUMP_START, true);
    _LockWeaponIdleAnimation(iActiveItem);
    _UpdateViewModel(iPlayer);
    //client_print(0,print_chat,"START FALL");
}

_DropFallAction(const iPlayer, const iActiveItem)
{
    //client_print(0,print_chat,"END FALL");
    _inFall[iPlayer] = false;
    _DropViewModel(iPlayer);
    if(!isLock[iPlayer])
        _DeployActiveItem(iPlayer, iActiveItem);
}


_UpdateFallAction(const iPlayer, const iActiveItem)
{
    if(_fallAnimTime[iPlayer] != 0.0 && _fallAnimTime[iPlayer] < get_gametime())
    {
        //client_print(0,print_chat,"IDLE FALL");
        _fallAnimTime[iPlayer] = 0.0;
        PlayWeaponAnim(iPlayer, JUMP_IDLE, true);
    }
    //client_print(0,print_chat,"UPDATE FALL");
    _UpdateViewModel(iPlayer);
    _LockWeaponIdleAnimation(iActiveItem);
}

// Some help functions
_DeployActiveItem(const iPlayer, const iActiveItem)
{
    //client_print(0,print_chat,"Deploy force");
    if( iActiveItem )
    {
        static Float:nextPAttack, Float:nextSAttack, Float:nextAttack;
        nextPAttack = get_pdata_float(iActiveItem, m_flNextPrimaryAttack, extra_offset_weapon);
        nextSAttack = get_pdata_float(iActiveItem, m_flNextSecondaryAttack, extra_offset_weapon);
        nextAttack = get_pdata_float(iPlayer, m_flNextAttack, extra_offset_player);
        ExecuteHamB(Ham_Item_Deploy, iActiveItem);
        set_pdata_float(iActiveItem, m_flNextPrimaryAttack, nextPAttack,extra_offset_weapon);
        set_pdata_float(iActiveItem, m_flNextSecondaryAttack, nextSAttack,extra_offset_weapon);
        set_pdata_float(iPlayer, m_flNextAttack, nextAttack,extra_offset_player);
    }

}

_LockWeaponIdleAnimation(const iActiveItem)
{
    if(iActiveItem)
    {
        if(get_pdata_float(iActiveItem, m_flTimeWeaponIdle, extra_offset_weapon) < 0.15)
        {
            set_pdata_float(iActiveItem, m_flTimeWeaponIdle, 1.0, extra_offset_weapon);
        }
    }
}

// Main actions controller
_Update_PK_Stats(const iPlayer)
{
    static Float: fGameTime;
    fGameTime = get_gametime();

    static Float:fMaxSpeed;
    pev(iPlayer, pev_maxspeed, fMaxSpeed);


    static iButtons, iOldButtons, iFlags, iMoveType;
    iButtons    =   pev( iPlayer,   pev_button      );
    iOldButtons =   pev( iPlayer,   pev_oldbuttons  );
    iFlags      =   pev( iPlayer,   pev_flags       );
    iMoveType   =   pev( iPlayer,   pev_movetype    );

    static bool:onGround;
    onGround  = ( (iFlags & FL_ONGROUND ) ? true : false );

    static bool:inWater;
    inWater   = ( (iFlags & FL_INWATER  ) ? true : false );

    static bool:isDucking;
    isDucking = ( (iFlags & FL_DUCKING  ) ? true : false );

    static bool:inAir;
    inAir = ( !onGround &&  !inWater && iMoveType != MOVETYPE_FLY && iMoveType != MOVETYPE_NOCLIP );

    static Float:vecfVelocity[3];
    pev(iPlayer, pev_velocity, vecfVelocity);

    static Float:fvelLen;
    fvelLen = vector_length(vecfVelocity);

    static iActiveItem;
    iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, extra_offset_player);

    if( iActiveItem < 0 || !pev_valid(iActiveItem) )
    {
        iActiveItem = 0;
    }


    // PK VALIDATION STATS CHECK
    static bool:isActionBlock;
    if((!inWater && (/*!isMove[iPlayer] ||*/ isMove[iPlayer] && isWalk[iPlayer])) || fMaxSpeed == 1.0 )//|| fvelLen < 18.0 )
    {
        // client_print(0,print_chat,"lock 1");
        isActionBlock = true;
    }
    // else
    // if( !inWater )//&& (iFlags & FL_DUCKING))
    // {
    //     isActionBlock = true;
    // }
    else
    if(iActiveItem)
    {
        // static Float:speed;

        // client_print(0,print_chat,"%..3f",get_pdata_float(iActiveItem, m_flNextPrimaryAttack, extra_offset_weapon));

        // In reloading
        if(get_pdata_int(iActiveItem, m_fInReload, extra_offset_weapon) == 1)
        {
            isActionBlock = true;
        }
        else 

        // In prim/sec weapon action
        if(get_pdata_float(iActiveItem, m_flNextPrimaryAttack, extra_offset_weapon) > -1.0)
        {
            isActionBlock = true;
        }
        else

        // In zoom or etc?
        if(get_pdata_int(iPlayer, m_iFOV, extra_offset_player) < FOV_NORMAL)
        {
            isActionBlock = true;
        }

        // Throwing grenade state?
        else
        {
            static iWeaponId;
            iWeaponId = get_pdata_int(iActiveItem, m_iId, extra_offset_weapon);

            if( ( iWeaponId == CSW_HEGRENADE || iWeaponId == CSW_FLASHBANG || iWeaponId == CSW_SMOKEGRENADE ) && get_pdata_float(iActiveItem, m_flPinPulledOutTime, extra_offset_weapon) != -1.0 )
            {
                isActionBlock = true;
            }
            else
            {
                isActionBlock = false;
            }
        }
    }
    else 
    {
        // PostJump?
        // isActionBlock = ( (jumpAnim_state[iPlayer] != JUMPSTATE_POST) ? true : false);
        isActionBlock = true;
    }

    isLock[iPlayer] = isActionBlock;

    if(isActionBlock)
    {
        // client_print(0,print_chat,"LOCK");
        if(_inSprint[iPlayer])
        {
            //client_print(0,print_chat,"SPRINT DROP 1");
            isLock[iPlayer] = false;
            _DropSprintAction(iPlayer, iActiveItem);
            isLock[iPlayer] = isActionBlock;
        }
        if(_inSwim[iPlayer])
        {
            _DropSwimAction(iPlayer, iActiveItem);
        }
        if(_inJump[iPlayer])
        {
            _DropJumpAction(iPlayer, iActiveItem);
        }
    }
    
    static bool:oldBtnFow[MAXPLAYERS];
    if(_inJump[iPlayer])
    {
        if(!inAir || inWater )
        {
            _DropJumpAction(iPlayer, iActiveItem);
        }
        else 
        {
            _UpdateJumpAction(iPlayer, iActiveItem);
            _UpdateFallAction(iPlayer, iActiveItem);
        }

    }
    else
    if(!isActionBlock && inWater)
    {
        if(_inFall[iPlayer])
            _DropFallAction(iPlayer, iActiveItem)
    
        static iWaterlevel;
        iWaterlevel = pev(iPlayer, pev_waterlevel);
        if(iWaterlevel > 2)
        {
            // isActionBlock = true;
            // client_print(0,print_chat,"2");
            if(!_inSwim[iPlayer])
            {
                _SetSwimAction(iPlayer, iActiveItem);
            }
            else
            {
                _UpdateSwimAction(iPlayer, iActiveItem);
            }
        }
        else
        if(_inSwim[iPlayer])
        {
            _DropSwimAction(iPlayer, iActiveItem);
        }
    }
    else 
    if(_inSwim[iPlayer])
    {
        _DropSwimAction(iPlayer, iActiveItem);
    }
    else if(!onGround)
    {
    	//client_print(iPlayer, print_chat, "Not On Ground %d %0.2f < %0.2f", isActionBlock, vecfVelocity[2], FALL_VELOCITY);
        if(!isActionBlock && vecfVelocity[2] < FALL_VELOCITY)
        {
            if(!_inFall[iPlayer])
                _SetFallAction(iPlayer, iActiveItem);
            else 
                _UpdateFallAction(iPlayer, iActiveItem);
        }
        else 
        if(_inFall[iPlayer])
        {
            _DropFallAction(iPlayer, iActiveItem);
        }
    }
    else 
    if(_inFall[iPlayer])
    {
        _DropFallAction(iPlayer, iActiveItem);
    }
    // client_print(0,print_chat,"Duck: %s",isDucking?"T":"F");

    static Float:oldKeyTime[MAXPLAYERS];

    if(floatabs(vecfVelocity[2]) < SPRINT_ZVEL && fvelLen > 18.0 && !inWater && !isDucking && (iButtons & IN_FORWARD))
    {
        oldBtnFow[iPlayer] = true;
        if(!isActionBlock)
        {
            if(_inSprint[iPlayer])
            {
                _UpdateSprintAction(iPlayer, iFlags, iButtons, iOldButtons, iActiveItem);
            }
            else
            {
                if(onGround && fGameTime - oldKeyTime[iPlayer] < SPRINT_TAPTIME)
                {
                    _SetSprintAction(iPlayer, iActiveItem);
                }
            }
        }
    }
    else
    if(oldBtnFow[iPlayer])
    { 
        if(!(iButtons & IN_FORWARD))
        {
            oldBtnFow[iPlayer] = false;
            oldKeyTime[iPlayer] = fGameTime;
        }
        if(_inSprint[iPlayer])
        {
            // client_print(0,print_chat,"%..1f",floatabs(vecfVelocity[2]) );
            isLock[iPlayer] = false;
            //client_print(0,print_chat,"SPRINT DROP 2");
            _DropSprintAction(iPlayer, iActiveItem);
            isLock[iPlayer] = isActionBlock;
        }
    }
    // client_print(iPlayer, print_center,"Lock: %s",isActionBlock?"T":"F");

    // if( (iButtons & IN_JUMP) && !(iOldButtons & IN_JUMP))
    // {

    // }
    if(iButtons & IN_JUMP)
    {
        // if(!_tryClimbAction(iPlayer, 8.0))
        // {
        if(!_tryClimbAction(iPlayer, 4.0))
        {
            if(_tryClimbAction(iPlayer, CLIMB_LOW))
            {
                _SetClimbAction(iPlayer, false, isActionBlock, fGameTime, iActiveItem);
            }
            else
            if(_tryClimbAction(iPlayer, CLIMB_HIGH))
            {
                _SetClimbAction(iPlayer, true, isActionBlock, fGameTime, iActiveItem);
            }
            else if(!inWater && !onGround && !(iOldButtons & IN_JUMP))
            {
                _setWallJump(iPlayer, iActiveItem);
            }
        }
        else if(!inWater && !onGround && !(iOldButtons & IN_JUMP))
        {
            _setWallJump(iPlayer, iActiveItem);
        }
            // else 
                // client_print(0,print_chat,"fail climb");
        // }
        // else client_print(0,print_chat,"no climb obj");g
    }
    if(!inAir && _wallJumps[iPlayer] < WALLJUMP_COUNT)
    {
        client_print(iPlayer, print_center, "");    //clear center msg?
        _wallJumps[iPlayer] = WALLJUMP_COUNT;
    }
    // if(hasClimbModel[iPlayer])
    if(_inClimb[iPlayer])
    {
        if(isActionBlock || !inAir )//|| (fGameTime - climbAnimTime[iPlayer] > 1.0) )
        {
            _DropClimbAction(iPlayer, iActiveItem);
        }
        else
        {
            _UpdateClimbAction(iPlayer, iActiveItem);
        }
    }

    if(_inSprint[iPlayer] && (iButtons & IN_JUMP) && (iFlags & FL_ONGROUND) )
    {
    	 _SetJumpAction(iPlayer, iActiveItem);
    }
    // client_print(iPlayer, print_center,"Block: %s",isActionBlock ? "T" : "F");
}

bool: _tryClimbAction(const iPlayer, const Float:checkUp)
{
    static Float:vecOrigin[3];
    pev(iPlayer, pev_origin, vecOrigin);

    static Float:vecMaxs[3];
    pev(iPlayer, pev_maxs, vecMaxs);

    static Float:vecMins[3];
    pev(iPlayer, pev_mins, vecMins);

    static Float:vecOrigin2[3];
    vecOrigin2[0] = vecOrigin[0];
    vecOrigin2[1] = vecOrigin[1];
    vecOrigin2[2] = vecOrigin[2];
    vecOrigin[2] += vecMaxs[2] + checkUp;
    if(isFreeHull(vecOrigin2, vecOrigin, iPlayer, CHECK_NONE) < 1.0)
    {
        return false;
    }

    static Float:vecAimAngles[3];
    pev(iPlayer, pev_v_angle, vecAimAngles);

    static Float:vecFow[3];


    vecFow[0] = vecOrigin[0] + floatcos(vecAimAngles[1], degrees) * PLAYER_SIZE_SIDE;
    vecFow[1] = vecOrigin[1] + floatsin(vecAimAngles[1], degrees) * PLAYER_SIZE_SIDE;
    vecFow[2] = vecOrigin[2];

    //if(_checkTraceHull(iPlayer, vecOrigin, vecFow,0,0,255))
    if(isFreeHull(vecOrigin, vecFow, iPlayer, CHECK_NONE) >= 1.0)
    {
        // client_print(iPlayer, print_center,"FREE");
        vecOrigin[0] = vecFow[0];
        vecOrigin[1] = vecFow[1];
        vecOrigin[2] = vecFow[2] - 24.0;
        static Float:res;
        res = isFreeHull(vecFow, vecOrigin, iPlayer, CHECK_CLIMB);
        // if(res!=0.0)
        //     client_print(0,print_chat,"%..3f %..5f",res,get_gametime());
        if(res!= 0.0)
        {
            // client_print(0,print_chat,"True %..3f %..5f",res,get_gametime());
            return true;
        }

        // return true;
        // //if(!_checkTraceHull(iPlayer, vecOrigin, vecFow,0,255,0))
        // if(isFreeHull(vecOrigin, vecFow))
        // {
        //     // ??? 
        //     client_print(0,print_chat,"can climb");
        //     return true;
        // }
    }
    // else
        // client_print(iPlayer, print_center,"STUCK");

    return false;
}


stock Float:isFreeHull(const Float:vecStart[3], const Float:vecEnd[3], const iEntity,  checkType){

    static iTr;
    iTr = create_tr2();

    engfunc(EngFunc_TraceHull, vecStart, vecEnd, DONT_IGNORE_MONSTERS, (pev(iEntity, pev_flags) & FL_DUCKING? HULL_HEAD:HULL_HUMAN), iEntity, iTr);

    static Float:flFraction;
    get_tr2(iTr, TR_flFraction, flFraction);

    if(checkType != CHECK_NONE)
    {
        if(flFraction >= 1.0) 
        {
            return 0.0;
        }

        static Float:vec3[3];
        get_tr2(iTr,TR_vecPlaneNormal, vec3);
        //if(vec3[2]!=0.0)

        free_tr2(iTr);
        if(checkType == CHECK_CLIMB)
        {
            if(vec3[2] < CHECKHULL_MINCLIMBNORMAL)//0.8)
            {
                return 0.0;
            }
            return 1.0;
        }
        else
        {
            // client_print(0,print_chat,"%..3f %..5f %..2f ",get_gametime(),vec3[2],flFraction);
            if(vec3[2] > CHECKHULL_MINWALLNORMAL)
            {
                return 0.0;
            }
            return 1.0;
            //return vec3[2];
        }
    }

    free_tr2(iTr);

    return flFraction;
}
// bool: _checkTraceHull(const iPlayer, const Float:vecStart[3], const Float:vecEnd[3],r,g,b)
// {
//     static HULL_TYPE;

//     //const Float:fOrigin[3],const Float:fOrigin2[3],const r,const g,const b,const lifetime,const width)
//     MSG_DrawLine(vecStart, vecEnd, r,g,b,100,30);
//     static iTrace;
//     iTrace = create_tr2();
//     //(const float *v1, const float *v2, int fNoMonsters, int hullNumber, edict_t *pentToSkip, TraceResult *ptr);
//     // engfunc(EngFunc_TraceHull, vecStart, vecEnd, 0, HULL_HEAD,iPlayer, iTrace);

//     static Float:fFraction;
//     get_tr2(iTrace, TR_flFraction, fFraction);

//     // if(!get_tr2(iTrace,TR_StartSolid) && !get_tr2(iTrace,TR_AllSolid) && get_tr2(iTrace,TR_InOpen))return false;
//     free_tr2(iTrace);
//     return (fFraction == 1.0 ? true : false);
// }

// STOCKS

// stock PlayClimbAnim(const iPlayer, const iSequence, const bool:isForce)
// {
//     if(!isForce && pev(iPlayer, pev_weaponanim) == iSequence)
//     {
//         return;
//     }

//     set_pev(iPlayer, pev_weaponanim, iSequence);

//     message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, iPlayer);
//     {
//         write_byte( iSequence   );
//         write_byte( 0           );
//     }
//     message_end();
// }
stock PlayWeaponAnim(const iPlayer, const iSequence, const bool: isForce)
{
    // if(hasClimbModel[iPlayer])
    // {
    //     return;
    // }

    if(!isForce && pev(iPlayer, pev_weaponanim) == iSequence)
    {
        return;
    }
    // client_print(0,print_chat,"%i",iSequence);
    set_pev(iPlayer, pev_weaponanim, iSequence);

    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, iPlayer);
    {
        write_byte( iSequence   );
        write_byte( 0           );
    }
    message_end();
}


// HAM

register_ham()
{
    RegisterHam(Ham_Player_PreThink, ENTITY_REFERANCE_PLAYER, "HookHam_Player_PreThink_Pre", false);
}

public HookHam_Player_PreThink_Pre(const iPlayer)
{
    if(!is_user_alive(iPlayer))
    {
        _DropAllActions(iPlayer);
        return HAM_IGNORED;
    }

    //set_pev(iPlayer, pev_health, 999.0);  // test lol
    // client_print(iPlayer, print_center, "Surf: %s",(pev(iPlayer, pev_flags) & FL_PARTIALGROUND) ? "True":"False");
    _Update_PK_Stats(iPlayer);
    return HAM_IGNORED;
}

// FAKEMETA

register_fm()
{
    register_forward(FM_CmdStart, "HookFM_CmdStart")
}

public HookFM_CmdStart(const iPlayer, const iHandle, const iSeed)
{
    if(!is_user_alive(iPlayer))
        return FMRES_IGNORED;

    static Float:fMoveF,Float:fMoveS;
    get_uc(iHandle, UC_ForwardMove, fMoveF);
    get_uc(iHandle, UC_SideMove, fMoveS);

    if(fMoveF == 0.0 && fMoveS == 0.0)
    {
        isMove[iPlayer] = false;

        if(isWalk[iPlayer])
        {
            isWalk[iPlayer] = false;
        }

        return FMRES_IGNORED;
    }

    isMove[iPlayer] = true;

    if(fMoveF < 0.0) fMoveF = -fMoveF;
    if(fMoveS < 0.0) fMoveS = -fMoveS;

    static Float:fMaxSpeed;
    pev(iPlayer, pev_maxspeed, fMaxSpeed);

    static Float:fWalkSpeed;
    fWalkSpeed = fMaxSpeed * 0.52;

    if(fMaxSpeed == 1.0 || fMoveF <= fWalkSpeed && fMoveS <= fWalkSpeed)
    {
        if(!isWalk[iPlayer])
        {
            isWalk[iPlayer] = true;
        }
    }
    else 
    {
        if(isWalk[iPlayer])
        {
            isWalk[iPlayer] = false;
        }
    }
    return FMRES_IGNORED;
}



// AMXX EVENTS

public plugin_precache()
{
    engfunc(EngFunc_PrecacheModel, MODEL_V);
    // engfunc(EngFunc_PrecacheModel, MODEL_V_CLIMBS);
    engfunc(EngFunc_PrecacheSound, SOUND_WALLJUMP);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");

    register_ham();
    register_fm();

    maxPlayers = get_maxplayers();
}

public Event_NewRound() {
	static iActiveItem;
    
	for(new i = 0; i < maxPlayers; i++)
	{
		if(!is_user_alive(i))
			continue;

		if(_inSprint[i])
        {
        	iActiveItem = get_pdata_cbase(i, m_pActiveItem, extra_offset_player);
        	if(iActiveItem > 0) {
	            isLock[i] = false;
	            _DropSprintAction(i, iActiveItem);
        	}
        }
	}
}

public client_disconnected(iPlayer)
{
    _DropAllActions(iPlayer);
}

public client_putinserver(iPlayer)
{
    _DropAllActions(iPlayer);
}

public IsAllowTouse(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_E)
		return true;

	return false;
}

// stock MSG_DrawLine(const Float:fOrigin[3],const Float:fOrigin2[3],const r,const g,const b,const lifetime,const width)
// {
//     static g_iBeamSprite;
//     if(!g_iBeamSprite)g_iBeamSprite = engfunc(EngFunc_PrecacheModel,"sprites/laserbeam.spr");

//     message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
//     write_byte(TE_BEAMPOINTS)
//     engfunc(EngFunc_WriteCoord, fOrigin[0])
//     engfunc(EngFunc_WriteCoord, fOrigin[1])
//     engfunc(EngFunc_WriteCoord, fOrigin[2])
//     engfunc(EngFunc_WriteCoord, fOrigin2[0])
//     engfunc(EngFunc_WriteCoord, fOrigin2[1])
//     engfunc(EngFunc_WriteCoord, fOrigin2[2])
//     write_short(g_iBeamSprite)
//     write_byte(0)
//     write_byte(1)
//     write_byte(lifetime)
//     write_byte(width)
//     write_byte(0)
//     write_byte(r)
//     write_byte(g)
//     write_byte(b)
//     write_byte(200)
//     write_byte(0)
//     message_end()
// }

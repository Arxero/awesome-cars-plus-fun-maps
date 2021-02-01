// I don't really know what this does.
#pragma library "knifeapi"

/**************************************************
 ************ API ENUMS AND STRUCTURES ************
 *************************************************/

enum KnifeProperties
{
    KN_STR_WeaponName,          // name of the weapon shown in the menu
    KN_STR_VModel,              // v_model path including models/
    KN_STR_PModel,              // p_model path including models/
    KN_STR_WModel,              // w_model path including models/
    KN_STR_DeploySound,         // deploy sound path
    KN_STR_SlashSound,          // slash sound path
    KN_STR_StabSound,           // stab sound path
    KN_STR_WhiffSound,          // whiff (air) sound path
    KN_STR_WallSound,           // wall hit sound path
    KN_STR_SpriteName,          // if you're using a custom sprite, change this to the .txt filename (weapon_custom for example) - DON'T CHANGE IF YOU'RE NOT USING A CUSTOM SPRITE!!!
    KN_CLL_Droppable,           // should be droppable?
    KN_CLL_PrimaryDamage,       // primary damage multiplier (1.0 - default damage, 2.0 - double damage etc.)
    KN_CLL_SecondaryDamage,     // secondary damage multiplier (1.0 - default damage, 2.0 - double damage etc.)
    KN_CLL_PrimaryNextAttack,   // time between primary attacks in seconds
    KN_CLL_SecondaryNextAttack, // time between secondary attacks in seconds
    KN_CLL_PrimaryRange,        // range of the primary attack
    KN_CLL_SecondaryRange,      // range of the secondary attack
    KN_CLL_PrimaryDamageDelay,  // delay between button press and the actual knife hit for primary damage
    KN_CLL_SecondaryDamageDelay,// ^ for secondary damage
    KN_CLL_PrimaryDmgBits,      // such as DMG_BULLET | DMG_ALWAYSGIB (makes the enemies explode), DMG_BULLET | DMG_NEVERGIB default
    KN_CLL_SecondaryDmgBits,    // ^ for secondary
    KN_CLL_TeamLock,            // if not 0, other team won't be able to pick up/deploy the knife
    KN_CLL_NextAttackDependency,// if true, a primary attack also modifies the secondary next attack by the same amount (and vice versa); true by default
    KN_CLL_IgnoreFriendlyFire   // ignore friendly fire?
};

enum _:ForwardReturns
{
	KnifeAction_Block = 5,
	KnifeAction_DoNothing
};

/****************************************
 ************ PLUGIN NATIVES ************
 ***************************************/

/* Knife_Register(): Registers a knife.

 * @params: See KnifeProperties, they're the same
 * @info: You can use additional settings with Knife_SetProperty
 * @return: (Int) Pointer to the knife
*/
native Knife_Register(
    const WeaponName[] = "New Knife",             
    const VModel[],                                     
    const PModel[] = "",
    const WModel[] = "",
    const DeploySound[] = "weapons/knife_deploy1.wav",
    const SlashSound[] = "weapons/knife_hit1.wav",
    const StabSound[] = "weapons/knife_stab.wav",
    const WhiffSound[] = "weapons/knife_slash1.wav",
    const WallSound[] = "weapons/knife_hitwall1.wav",
    Float:PrimaryDamage = 1.0, 
    Float:SecondaryDamage = 1.0
);

/* Knife_GetTotal(): Returns the amount of knives registered.

 * @info: Used for loops of knives: for(new i=1; i<=Knife_GetTotal(); i++)
 
 * @return: (Int) amount of knives registered
*/
native Knife_GetTotal();

/* Knife_GetProperty(): Retrieves a property of a knife from the KnifeProperties enum.

 * @param (Int) Knife: Knife index
 * @param (Int) Value: Value from the KnifeProperties enum
 * @params (any...): If you're using a value from KN_STR_X, the next two params are output string and buffer size,
        otherwise it's only the output cell to which the data is saved by reference
 
 * @return: (Int) 1 on success, 0 on failure/error
*/
native Knife_GetProperty(Knife, KnifeProperties:Value, any:...);

/* Knife_SetProperty(): Sets a property of a knife from the KnifeProperties enum.

 * @param (Int) Knife: Knife index
 * @param (Int) Value: Value from the KnifeProperties enum
 * @params (any...): String/cell with the value
 
 * @return: (Int) 1 on success, 0 on failure/error
*/
native Knife_SetProperty(Knife, KnifeProperties:Value, any:...);

/* Knife_PlayerGive(): Gives a knife to a player.

 * @param (Int) Player: Index of the player
 * @param (Int) Knife: Knife index
 * @param (bool) Set: If true, the player will automatically equip the knife
 
 * @return: (Int) 1 on success, 0 on failure/error
*/
native Knife_PlayerGive(Player, Knife, bool:Set = true);

/* Knife_PlayerGetCurrent(): Returns the current knife a player has equipped.

 * @param (Int) Player: Index of the player
 
 * @return: (Int) 0 - default knife, X - knife ID, -1 - error/failure
*/
native Knife_PlayerGetCurrent(Player);

/* Knife_PlayerSetCurrent(): Force-equips a knife on the player. Player must own the knife.

 * @param (Int) Player: Index of the player to give the knife to
 * @param (Int) Knife: Knife index
 
 * @return: (Int) 1 on success, 0 on failure/error
*/
native Knife_PlayerSetCurrent(Player, Knife);

/* Knife_PlayerHas(): Check whether a player has a knife.

 * @param (Int) Player: Index of the player
 * @param (Int) Knife: Knife index
 
 * @return: (Int) 1 on yes, 0 on failure/error/no
*/
native Knife_PlayerHas(Player, Knife);

/* Knife_PlayerSetLock(): Prevents a player from changing their knife.

 * @param (Int) Player: Index of the player
 * @param (Bool) Locked: Lock status - true: locked, false: unlocked
 
 * @return: nothing
*/
native Knife_PlayerSetLock(Player, bool:Locked);

/* Knife_PlayerGetLock(): Checks player's knife lock status.

 * @param (Int) Player: Index of the player
 
 * @return: (Bool) true: locked, false: unlocked
*/
native bool:Knife_PlayerGetLock(Player);

/* Knife_PlayerRemoveAll(): Removes all knives except default from the player.

 * @param (Int) Player: Index of the player
 
 * @return: nothing
*/
native Knife_PlayerRemoveAll(Player);

/**********************************
 ************ FORWARDS ************
 *********************************/ 

/* KnifeAction_ProcessAttack_Pre(): Called when an attack is about to happen.
        Pre hook: This gets called before the animation delay if there is any.
        You can block the action with KnifeAction_Block.
 * @param (Int) Player: Index of the player(attacker)
 * @param (Int) Knife: Knife index
 * @param (bool) PrimaryAttack: true: yes, false: no
*/
forward KnifeAction_ProcessAttack_Pre(Player, Knife, bool:PrimaryAttack);

/* KnifeAction_ProcessAttack_Post(): Called when an attack has happened.
        Post hook: This gets called after the animation delay, if there's any.
        You cannot block this forward. Block KnifeAction_DealDamage instead.
 * @param (Int) Player: Index of the player(attacker)
 * @param (Int) Victim: Player receiving the damage. If there was no player (wall/air slash), Victim is 0.
 * @param (Int) Knife: Knife index
 * @param (bool) PrimaryAttack: true: yes, false: no
 * @param (Vector) EndPoint: Ending point of the knife trace. This is the origin where the damage has happened.
        I recommend playing your custom sounds/showing various sprites using this.
 * @param (Vector) AimVector: Player's aiming direction
*/
forward KnifeAction_ProcessAttack_Post(Player, Victim, Knife, bool:PrimaryAttack, Float:EndPoint[3], Float:AimVector[3]);

/* KnifeAction_DealDamage(): Called right before an attack happening
        Pre hook: You can block the action with KnifeAction_Block.
 * @param (Int) Attacker: Index of the player(attacker)
 * @param (Int) Victim: Player receiving the damage
 * @param (Int) Knife: Knife index
 * @param (Float) Damage: Damage received with modifiers in mind (hitboxes/backstab/custom damage multiplier)
 * @param (bool) PrimaryAttack: true: yes, false: no
 * @param (Vector) EndPoint: Ending point of the knife trace. This is the origin where the damage has happened.
        I recommend playing your custom sounds/showing various sprites using this.
 * @param (Vector) AimVector: Player's aiming direction
 * @param (Int) Hitzone: Damage hitzone, such as HIT_HEAD.
*/
forward KnifeAction_DealDamage(Attacker, Victim, Knife, Float:Damage, bool:PrimaryAttack, DamageBits, bool:Backstab, 
    Float:EndPoint[3], Float:AimVector[3], Hitzone
);

/* KnifeAction_Deploy(): Called when a player draws a knife.
        Post hook: You cannot block this forward.
 * @param (Int) Attacker: Index of the player
 * @param (Int) Knife: Knife index
*/
forward KnifeAction_Deploy(Player, Knife);

/* KnifeAction_SoundPlay(): Called when a knife sound is about to play.
        Pre hook: You can block the action with KnifeAction_Block.
 * @param (Int) Player: Index of the player
 * @param (Int) Knife: Knife index
 * @param (String) Sound: Sound played
*/
forward KnifeAction_SoundPlay(Player, Knife, const Sound[]);

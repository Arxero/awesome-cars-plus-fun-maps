#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <nvault>
#include <engine>
#include <cstrike>


#define ACH_COUNT 100
#define ACH_MAX_PROGRESS 32767
#define ACH_VAULT_NAME "unified_melee_achievements"
#define ACH_0 0
#define ACH_1 1
#define ACH_2 2
#define ACH_3 3
#define ACH_4 4
#define ACH_5 5
#define ACH_6 6
#define ACH_7 7
#define ACH_8 8
#define ACH_9 9
#define ACH_10 10
#define ACH_11 11
#define ACH_12 12
#define ACH_13 13
#define ACH_14 14
#define ACH_15 15
#define ACH_16 16
#define ACH_17 17
#define ACH_18 18
#define ACH_19 19
#define ACH_20 20
#define ACH_21 21
#define ACH_22 22
#define ACH_23 23
#define ACH_24 24
#define ACH_25 25
#define ACH_26 26
#define ACH_27 27
#define ACH_28 28
#define ACH_29 29
#define ACH_30 30
#define ACH_31 31
#define ACH_32 32
#define ACH_33 33
#define ACH_34 34
#define ACH_35 35
#define ACH_36 36
#define ACH_37 37
#define ACH_38 38
#define ACH_39 39
#define ACH_40 40
#define ACH_41 41
#define ACH_42 42
#define ACH_43 43
#define ACH_44 44
#define ACH_45 45
#define ACH_46 46
#define ACH_47 47
#define ACH_48 48
#define ACH_49 49
#define ACH_50 50
#define ACH_51 51
#define ACH_52 52
#define ACH_53 53
#define ACH_54 54
#define ACH_55 55
#define ACH_56 56
#define ACH_57 57
#define ACH_58 58
#define ACH_59 59
#define ACH_60 60
#define ACH_61 61
#define ACH_62 62
#define ACH_63 63
#define ACH_64 64
#define ACH_65 65
#define ACH_66 66
#define ACH_67 67
#define ACH_68 68
#define ACH_69 69
#define ACH_70 70
#define ACH_71 71
#define ACH_72 72
#define ACH_73 73
#define ACH_74 74
#define ACH_75 75
#define ACH_76 76
#define ACH_77 77
#define ACH_78 78
#define ACH_79 79
#define ACH_80 80
#define ACH_81 81
#define ACH_82 82
#define ACH_83 83
#define ACH_84 84
#define ACH_85 85
#define ACH_86 86
#define ACH_87 87
#define ACH_88 88
#define ACH_89 89
#define ACH_90 90
#define ACH_91 91
#define ACH_92 92
#define ACH_93 93
#define ACH_ARMOR_ROBBER 95
#define ACH_STUBBORN 96
#define ACH_DEATH_DOESNT_WAIT 97
#define ACH_ADDICTION 98
#define ACH_SKULL_CRUSHER 99

new const g_AchNames[ACH_COUNT][] =
{
    "First Blood",
    "Getting Used To It",
    "Serial Killer",
    "Winning Streak",
    "Wall",
    "Not Today",
    "Backstabber",
    "I'm Tired",
    "Revenge",
    "Self Defence",
    "Ronin",
    "Omelette",
    "Knight",
    "Juggernaut",
    "Ninja",
    "Gangster",
    "Headsman",
    "Colossus",
    "Samurai",
    "Assassin",
    "Whirlwind",
    "Gladiator",
    "Necromancer",
    "Ironclad",
    "Butcher",
    "Broken Legs",
    "The Finisher",
    "One in a Million",
    "Double Kill",
    "Multitasking",
    "Mirror",
    "Bonk!",
    "Unfair",
    "Shadow",
    "Boneless",
    "Floor Inspector",
    "Not a Chance",
    "Not So Fast Now",
    "Bully",
    "Rose",
    "Nice Try",
    "Top #1 Gravity Hater",
    "Shadow Fight 2 Lynx",
    "Berserker",
    "The Perfect Counter",
    "King",
    "Shogun",
    "Thief",
    "Low Cortisol",
    "Two Birds, Two Stones",
    "Parry Master",
    "Unbreakable",
    "Friendship Issues",
    "Not Touching The Ground Yet",
    "Vertical Attack",
    "Neutralized",
    "Maniac",
    "What a Luck",
    "Insane Timing",
    "Tank",
    "Untouchable",
    "Spammer",
    "Leg Breaker",
    "High Risk, High Reward",
    "You Started It",
    "Team Work",
    "Collector",
    "Dead Ringer",
    "Sneaky Attack",
    "Bash",
    "Awesome Friendship",
    "Best Friends Forever",
    "The Perfect Team",
    "Micro-Bomb Combo",
    "Back Attack Combo",
    "Insane Damage",
    "I Believe I Can Fly",
    "Unstoppable Force",
    "Silent Reaper",
    "Immortal Swordsman",
    "Master Chef",
    "Dark Overlord",
    "Bone Breaker",
    "Apex Predator",
    "Home Run Hitter",
    "Head Splitter",
    "Titan's Bane",
    "Untouchable Daimyo",
    "Justice and Splendor",
    "Death's Herald",
    "Great Warrior",
    "Grim Reaper",
    "Champion of The Arena",
    "Wrath Demon",
    "Foot Work",
    "Armor Robber",
    "Stubborn",
    "Death Doesn't Wait",
    "Addiction",
    "Skull Crusher"
};
new const g_AchDescriptions[ACH_COUNT][] =
{
    "Get your first kill",
    "Get 10 kills",
    "Get 25 kills",
    "Win 3 rounds in a row",
    "Block 25 incoming attacks",
    "Successfully perform a parry",
    "Heavy attack someone from his back",
    "Exhaust 5 times in the same round",
    "Kill someone who killed you last round",
    "Get 5 kills with the knife",
    "Get 5 kills with the katana",
    "Get 5 kills with the pan",
    "Get 5 kills with the longsword",
    "Get 5 kills with the hammer",
    "Get 5 kills with the claws",
    "Get 5 kills with the bat",
    "Get 5 kills with the axe",
    "Get 5 kills with the greatsword",
    "Get 5 kills with the naginata",
    "Get 5 kills with the sais",
    "Get 5 kills with the glaive",
    "Get 5 kills with the gladius",
    "Get 5 kills with the scythe",
    "Get 5 kills with the gauntlets",
    "Get 5 kills with the cleaver",
    "Die 10 times from fall damage",
    "Execute an opponent using the cleaver",
    "Kill an opponent who has 1 HP",
    "Kill 2 opponents in the same round",
    "Kill 4 opponents in the same round",
    "Parry 5 incoming attacks in the same round",
    "Hit someone in the head 10 times using the pan",
    "Kill someone who is stunned",
    "Heavy attack 2 opponents in the back in the same round",
    "Get kicked into a wall and die",
    "Die from fall damage 20 times",
    "Hit an opponent 7 times in a row without taking damage",
    "Kill a katana user 5 times in a row without him killing you",
    "Kick someone into a wall 10 times",
    "Kill 10 people using thorns",
    "Parry a cleaver execution",
    "Die from fall damage 167 times",
    "Kill 10 people using the micro-bomb",
    "Get 10 kills while in berserk mode",
    "Execute a glaive user with the cleaver",
    "Be the last survivor in the round while using the longsword or greatsword",
    "Be the last survivor in the round while using the katana or naginata",
    "Kill an opponent with one attack after having dealt them no previous damage",
    "Successfully ignore 5 parries using the greatsword",
    "Kill 2 opponents in the same round using claws, sais or gauntlets",
    "Successfully parry 30 incoming attacks",
    "Successfully block 50 incoming attacks",
    "Use 15 kicks of any type on a teammate",
    "Kick someone while they're airborne",
    "Use the hammer's gravity attack 5 times",
    "Suppress a greatsword user and block or parry his attack while suppressed",
    "Get 100 kills",
    "Win the round with 1 HP",
    "Parry a glaive shockwave",
    "Take at least 401 damage in the same round and survive",
    "Win a round without taking any damage",
    "Win a 1v1 using only light attacks",
    "Perform an airborne down kick",
    "Successfully perform a back heavy attack 20 times",
    "Kill someone using the pan's parry damage",
    "Heavy attack someone who is stunned",
    "Get at least 10 kills with all weapons",
    "Successfully fake 10 deaths using the scythe",
    "Attack 15 opponents using the scythe while invisible",
    "Apply vulnerability to an already vulnerable opponent",
    "Apply vulnerability on your teammate and cause them to get killed while vulnerable",
    "Plant the micro-bomb on the same teammate 10 times",
    "Use the hammer's gravity attack on an opponent stunned by your teammate's back attack",
    "Low kick an opponent while the micro-bomb is planted on them",
    "Back heavy attack an opponent and back-kick them while stunned",
    "Hit a cleaver user stabbed by a longsword user while below 80 HP using the glaive",
    "Stay airborne for 10 uninterrupted seconds",
    "Win a 1v3 round",
    "Get 300 kills with the knife",
    "Get 300 kills with the katana",
    "Get 300 kills with the pan",
    "Get 300 kills with the longsword",
    "Get 300 kills with the hammer",
    "Get 300 kills with the claws",
    "Get 300 kills with the bat",
    "Get 300 kills with the axe",
    "Get 300 kills with the greatsword",
    "Get 300 kills with the naginata",
    "Get 300 kills with the sais",
    "Get 300 kills with the glaive",
    "Get 300 kills with the gladius",
    "Get 300 kills with the scythe",
    "Get 300 kills with the gauntlets",
    "Get 300 kills with the cleaver",
    "Kill an opponent using only kicks",
    "Steal a total of 200 AP using the Gladius",
    "Gain a total of 400 AP in the same round using the Gladius or Gauntlets",
    "Kill 3 opponents within 10 seconds",
    "Get 67 kills without leaving the server",
    "Perform 15 head hits with any attack in the same round"
};
new const g_AchTargets[ACH_COUNT] = {
    1, 10, 25, 3, 25, 1, 1, 5, 1, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 1, 1, 2, 4, 5, 10,
    1, 2, 1, 20, 7, 5, 10, 10, 1, 167, 10, 10, 1, 1, 1, 1,
    5, 2, 30, 50, 15, 1, 5, 1, 100, 1, 1, 401, 1, 1, 1, 20,
    1, 1, 10, 10, 15, 1, 1, 10, 1, 1, 1, 1, 1, 1, 300, 300,
    300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 1,
    200, 400, 3, 67, 15
};
new const g_AchCategories[ACH_COUNT] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3,
    1, 3, 4, 4, 2
};
new g_AchVault = INVALID_HANDLE;
new g_AchProgress[33][ACH_COUNT];
new bool:g_AchUnlocked[33][ACH_COUNT];
new g_AchRoundKills[33], g_AchRoundParries[33], g_AchRoundBackstabs[33], g_AchSpecialRoundKills[33];
new g_AchTotalKills[33], g_AchFallDeaths[33], g_AchWinStreak[33];
new g_AchLastRoundKiller[33], g_AchPreviousRoundKiller[33];
new g_AchWeaponKills[33][16];
new g_AchLastKiller[33], g_AchKillerStreak[33];
new g_AchMenuTarget[33];
new g_AchMenuCategory[33];
new Float:g_AchAirStart[33];
new bool:g_AchRoundTookDamage[33];
new g_AchDamageByOpponent[33][33];
new g_AchRoundDamageTaken[33];
new g_AchTeamWinStreak[33];
new g_AchTeamKicks[33];
new g_AchSameTeammateBomb[33][33];
new g_AchThornsKiller[33], g_AchStunnedHitBy[33], g_AchKickOwner[33], g_AchBonelessOwner[33], g_AchPanParryKiller[33];
new Float:g_AchBonelessUntil[33];
new g_AchKickOnlyOwner[33];
new bool:g_AchKickOnlyBroken[33];
new g_AchStunOwner[33];
new g_AchConsecutiveHits[33], g_AchLastHitVictim[33];
new bool:g_AchFallPending[33];
new g_AchBackComboVictim[33], g_AchBackstabOwner[33], g_AchVulnerabilityOwner[33], g_AchCleaverExecVictim[33];
new g_AchBombKiller[33];
new g_AchParryCount[33], g_AchBlockCount[33];
new g_AchRoundLightOnly[33];
new g_AchRoundTeamSize[33], g_AchRoundEnemySize[33];
new g_AchRoundLightHits[33], g_AchRoundAPGained[33];
new Float:g_AchRecentKillTimes[33][32];
new g_AchRecentKillVictims[33][32];
new g_AchRecentKillCount[33];
new bool:g_AchWallBounceLethal[33], bool:g_AchWallBouncePending[33];
new Float:g_AchWallBounceUntil[33];
new bool:g_AchRoundResultHandled;
#define ACH_DMG_WALL_BOUNCE (1<<27)
new bool:p4_g_Stunned[33];


#define MECH_STUN_TIME 2.5
#define MECH_WALL_DAMAGE 10.0
#define MECH_WALL_BOUNCE 0.55
#define MECH_CLASH_WINDOW 0.15
#define MECH_BACKKICK_RANGE 105.0
#define MECH_BACKKICK_DAMAGE 15.0
#define MECH_DOWNKICK_FORCE 520.0
#define MECH_DOWNKICK_FALL_SCALE 1.0
#define MECH_BACKSTAB_KNIFE_RANGE 48.0
#define MECH_BACKSTAB_KATANA_RANGE 90.0
#define MECH_BACKSTAB_SAIS_RANGE 48.0
#define MECH_BACKSTAB_GLAIVE_RANGE 125.0
#define MECH_BACKSTAB_GLADIUS_RANGE 65.0
#define MECH_TASK_STUN 28100

new Float:g_MechStunUntil[33]
new Float:g_MechLastAttack[33]
new Float:g_MechClashFxUntil[33]
new bool:g_MechHoldingWalk[33]
new bool:g_MechBackAttackHeld[33]
new bool:p5_g_bKeyDown[33];
// Previous raw CmdStart buttons for press/hold/release edge detection.
new p4_g_LastHookButtons[33]
new Float:g_MechLastDamage[33]
new bool:g_MechBackstab[33]
new bool:g_MechWasStunnedOnHit[33]
new bool:g_MechWallBounce[33]
new Float:g_MechWallCheckOrigin[33][3]
new Float:g_MechWallBounceUntil[33]
new bool:g_MechDownKickBounce[33]
new Float:g_MechDownKickUntil[33]
new Float:g_MechBackKickSlowUntil[33]
new Float:g_MechBackKickSlow = 110.0

#define PLUGIN "Unified Melee Combat"
#define VERSION "1.2"
#define AUTHOR "Mimou"


// ============================================================
// P7 PARRY / BLOCK / HEAVY CONFIGURATION AND STATE
// ============================================================

// CONFIGURATION
// ============================================================

// ---------------- PARRY ----------------

#define p7_PARRY_WINDOW       0.20
#define p7_PARRY_IMPULSE      100

#define p7_PARRY_R            255
#define p7_PARRY_G            200
#define p7_PARRY_B            5

// ---------------- BLOCK ----------------

#define p7_BLOCK_R             5
#define p7_BLOCK_G             240
#define p7_BLOCK_B             255

// ---------------- HEAVY ----------------

#define p7_HEAVY_COOLDOWN      6.0

// Purple countdown p7_text
#define p7_HEAVY_R             245
#define p7_HEAVY_G             5
#define p7_HEAVY_B             255

// ---------------- GENERAL ----------------

#define p7_GLOW_AMOUNT         20

// Task IDs
#define p7_TASK_PARRY          1000
#define p7_TASK_HEAVY          2000


// ============================================================
// STATES
// ============================================================

new bool:p7_g_bParry[33]
new bool:p7_g_bBlock[33]
new bool:p7_g_bHeavyCooldown[33]

new Float:p7_g_flHeavyEnd[33]

new bool:p7_g_bWaitingHeavyHit[33]
new bool:p6_g_bWaitingHeavyHit[33]


// ============================================================
// HUD
// ============================================================

new p7_g_msgSync


// ============================================================
// INIT
// ============================================================


public plugin_precache()
{
    p1_plugin_precache()
    p2_plugin_precache()
    p4_plugin_precache()
    p6_plugin_precache()
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    p1_plugin_init()
    p2_plugin_init()
    p3_plugin_init()
    p4_plugin_init()
    p5_plugin_init()
    p6_plugin_init()
    p7_plugin_init()
    ach_plugin_init()
}

// Forward AMXX lifecycle events to the prefixed melee module helpers.
public client_putinserver(id)
{
    p1_client_putinserver(id)
    p2_client_putinserver(id)
    p5_client_putinserver(id)
    p7_client_putinserver(id)
    p4_g_LastHookButtons[id] = 0
    ach_client_putinserver(id)
}



public client_authorized(id)
{
    ach_load(id)
}


#define p1_MELEE_KNIFE       0
#define p1_MELEE_KATANA      1
#define p1_MELEE_PAN         2
#define p1_MELEE_LONGSWORD   3
#define p1_MELEE_HAMMER      4
#define p1_MELEE_CLAWS       5
#define p1_MELEE_BAT         6
#define p1_MELEE_AXE         7
#define p1_MELEE_GREATSWORD  8
#define p1_MELEE_NAGINATA    9
#define p1_MELEE_SAIS       10
#define p1_MELEE_GLAIVE     11
#define p1_MELEE_GLADIUS    12
#define p1_MELEE_SCYTHE     13
#define p1_MELEE_GAUNTLETS  14
#define p1_MELEE_CLEAVER    15
#define p1_MELEE_COUNT      16

// Per-weapon model sequence map. Columns are logical slots:
// 0 idle, 1/2 slash, 3 draw, 4 stab, 5 stab-miss,
// 6/7 midslash, 8 parry. Change a row when a model uses different
// sequence numbers; every weapon defaults to the standard 0..8 order.
new const p1_AnimationMap[p1_MELEE_COUNT][9] =
{
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 6, 7, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 6, 7, 3, 4, 5, 6, 7, 7},
    {0, 6, 7, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 6, 7, 3, 4, 5, 6, 7, 8},
    {0, 1, 7, 2, 9, 8, 1, 9, 3},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 4, 3, 2, 7, 5, 6, 1},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8},
    {0, 1, 2, 3, 4, 5, 6, 7, 8}
}

new p1_g_SlashAnimStep[33]

#define p1_MODEL_KNIFE      "models/knife_arena/v_knife_placeholder.mdl"
#define p1_MODEL_KATANA     "models/knife_arena/v_katana.mdl"
#define p1_MODEL_PAN        "models/knife_arena/v_pan.mdl"
#define p1_MODEL_LONGSWORD  "models/knife_arena/v_longsword_placeholder.mdl"
#define p1_MODEL_HAMMER     "models/knife_arena/v_hammer.mdl"
#define p1_MODEL_CLAWS      "models/knife_arena/v_claws.mdl"
#define p1_MODEL_BAT        "models/knife_arena/v_bat_placeholder.mdl"
#define p1_MODEL_AXE        "models/knife_arena/v_axe_placeholder.mdl"
// New weapon identities reuse existing assets until dedicated assets are added.
#define p1_MODEL_SAIS       "models/knife_arena/v_sais_placeholder.mdl"
#define p1_MODEL_NAGINATA   "models/knife_arena/v_naginata.mdl"
#define p1_MODEL_GLADIUS    "models/knife_arena/v_gladius_placeholder.mdl"
#define p1_MODEL_SCYTHE     "models/knife_arena/v_scythe.mdl"
// Temporary model aliases: replace these four paths when dedicated models are installed.
#define p1_MODEL_GREATSWORD "models/knife_arena/v_greatsword.mdl"
#define p1_MODEL_GLAIVE     "models/knife_arena/v_glaive.mdl"
#define p1_MODEL_GAUNTLETS  "models/knife_arena/v_gauntlets.mdl"
#define p1_MODEL_CLEAVER    "models/knife_arena/v_cleaver.mdl"

// Per-weapon melee ranges in GoldSrc units. Tune independently.
#define p1_RANGE_KNIFE       50.0  // Default knife baseline
#define p1_RANGE_KATANA      67.0
#define p1_RANGE_PAN         63.0
#define p1_RANGE_LONGSWORD   76.0
#define p1_RANGE_HAMMER      73.0
#define p1_RANGE_CLAWS       48.0  // Same baseline as default knife
#define p1_RANGE_BAT         67.0
#define p1_RANGE_AXE         65.0
#define p1_RANGE_SAIS        50.0
#define p1_RANGE_NAGINATA    82.0
#define p1_RANGE_GLADIUS     56.0
#define p1_RANGE_SCYTHE      80.0
#define p1_RANGE_GREATSWORD  76.0
#define p1_RANGE_GLAIVE      82.0
#define p1_RANGE_GAUNTLETS   43.0
#define p1_RANGE_CLEAVER     65.0

// Crouch movement multiplier (1.0 = normal; >1.0 = faster).
#define p1_CROUCH_SPEED_MULT 1.00 // Disabled: crouching uses normal weapon speed.

// Hammer gravity toggles on each WALK-key press (not while held).
#define p1_HAMMER_GRAVITY_LOW  500.0
#define p1_HAMMER_GRAVITY_HIGH 1000.0
#define p1_HAMMER_MACE_LAND_WINDOW 1.25

// Per-weapon glow sprite paths. Replace these files with your own sprites.
#define p1_SPRITE_KNIFE     "sprites/knife_glow.spr"
#define p1_SPRITE_KATANA    "sprites/katana_glow.spr"
#define p1_SPRITE_PAN       "sprites/pan_glow.spr"
#define p1_SPRITE_LONGSWORD "sprites/longsword_glow.spr"
#define p1_SPRITE_HAMMER    "sprites/hammer_glow.spr"
#define p1_SPRITE_CLAWS     "sprites/claws_glow.spr"
#define p1_SPRITE_BAT       "sprites/bat_glow.spr"
#define p1_SPRITE_AXE       "sprites/axe_glow.spr"
#define p1_SPRITE_SAIS      "sprites/sais_glow.spr"
#define p1_SPRITE_NAGINATA  "sprites/naginata_glow.spr"
#define p1_SPRITE_GLADIUS   "sprites/gladius_glow.spr"
#define p1_SPRITE_SCYTHE    "sprites/scythe_glow.spr"
#define p1_SPRITE_GLAIVE    "sprites/glaive_glow.spr"
#define p1_SPRITE_GREATSWORD   "sprites/greatsword_glow.spr"
#define p1_SPRITE_GAUNTLETS "sprites/gauntlets_glow.spr"
#define p1_SPRITE_CLEAVER   "sprites/cleaver_glow.spr"

// Custom weapon sounds: each weapon has deploy, hit, slash-miss, hitwall, stab.
#define p1_SND_DIR "weapons/knife_arena/"


#define p1_DAMAGE_KNIFE_SLASH      15.0
#define p1_DAMAGE_KNIFE_STAB       65.0
#define p1_DAMAGE_KATANA_SLASH     14.0
#define p1_DAMAGE_KATANA_STAB      63.0
#define p1_DAMAGE_PAN_SLASH        15.0
#define p1_DAMAGE_PAN_STAB         65.0
#define p1_DAMAGE_LONGSWORD_SLASH  19.0
#define p1_DAMAGE_LONGSWORD_STAB   72.0
#define p1_DAMAGE_HAMMER_SLASH     18.0
#define p1_DAMAGE_HAMMER_STAB      70.0
#define p1_HAMMER_FALL_MIN_SPEED   220.0
#define p1_HAMMER_FALL_BONUS_STEP  100.0
#define p1_HAMMER_FALL_PER_STEP    0.15
#define p1_HAMMER_FALL_MAX_BONUS   2.00
#define p1_DAMAGE_CLAWS_SLASH      11.0
#define p1_DAMAGE_CLAWS_STAB       39.0
#define p1_DAMAGE_BAT_SLASH        14.0
#define p1_DAMAGE_BAT_STAB         62.0
#define p1_DAMAGE_AXE_SLASH        18.0
#define p1_DAMAGE_AXE_STAB         70.0
#define p1_DAMAGE_SAIS_SLASH       10.0
#define p1_DAMAGE_SAIS_STAB        64.0
#define p1_DAMAGE_NAGINATA_SLASH   17.0
#define p1_DAMAGE_NAGINATA_STAB    67.0
#define p1_DAMAGE_GLADIUS_SLASH    16.0
#define p1_DAMAGE_GLADIUS_STAB     66.0
#define p1_DAMAGE_SCYTHE_SLASH     18.0
#define p1_DAMAGE_SCYTHE_STAB      71.0
#define p1_DAMAGE_GREATSWORD_SLASH 24.0
#define p1_DAMAGE_GREATSWORD_STAB  79.0
#define p1_DAMAGE_GLAIVE_SLASH     17.0
#define p1_DAMAGE_GLAIVE_STAB      66.0
#define p1_DAMAGE_GAUNTLETS_SLASH  9.0
#define p1_DAMAGE_GAUNTLETS_STAB   36.0
#define p1_DAMAGE_CLEAVER_SLASH    17.0
#define p1_DAMAGE_CLEAVER_STAB     67.0

// New-weapon ability configuration.
#define p1_GLAIVE_BERSERK_HP        80
#define p1_GLAIVE_DAMAGE_BONUS      0.20
#define p1_GLAIVE_FREEZE_TIME       2.0
#define p1_GLAIVE_SHOCKWAVE_DELAY   1.0
#define p1_GLAIVE_SHOCKWAVE_RADIUS  867.0
#define p1_GLAIVE_SHOCKWAVE_PUSH    1250.0
#define p1_GLAIVE_SHOCKWAVE_UP      120.0
#define p1_GLAIVE_GLOW_BRIGHT       28
#define p1_GLAIVE_GLOW_FAINT        8
#define p1_GAUNTLETS_LIGHT_AP       5
#define p1_GAUNTLETS_HEAVY_AP       20
#define p1_GREATSWORD_PARRY_CHANCE  25
#define p1_CLEAVER_EXECUTE_HP       80
#define p1_CLEAVER_VULN_BONUS       0.15
#define p1_CLEAVER_GLOW_AMOUNT     18
#define p1_CLEAVER_EXECUTE_FLAG    (1<<28)
#define p1_GAUNTLETS_LIGHT_AP  5
#define p1_GAUNTLETS_HEAVY_AP  20

#define p1_SPEED_KNIFE      1.00
#define p1_SPEED_KATANA     0.05
#define p1_SPEED_PAN        1.25
#define p1_SPEED_LONGSWORD  2.67
#define p1_SPEED_HAMMER     2.90
#define p1_SPEED_CLAWS      0.01
#define p1_SPEED_BAT        2.00
#define p1_SPEED_AXE        2.45
#define p1_SPEED_SAIS       p1_SPEED_CLAWS
#define p1_SPEED_NAGINATA   2.67
#define p1_SPEED_GLADIUS    1.20
#define p1_SPEED_SCYTHE     p1_SPEED_AXE
#define p1_SPEED_GREATSWORD 5.00
#define p1_SPEED_GLAIVE     p1_SPEED_NAGINATA
#define p1_SPEED_GAUNTLETS  p1_SPEED_CLAWS
#define p1_SPEED_CLEAVER    p1_SPEED_AXE

// Per-weapon movement speeds (editable here).
#define p1_MOVE_KNIFE       280.0
#define p1_MOVE_KATANA      340.0
#define p1_MOVE_PAN         276.0
#define p1_MOVE_LONGSWORD   210.0
#define p1_MOVE_HAMMER      190.0
#define p1_MOVE_CLAWS       300.0
#define p1_MOVE_BAT         260.0
#define p1_MOVE_AXE         220.0
#define p1_MOVE_SAIS        290.0
#define p1_MOVE_NAGINATA    220.0
#define p1_MOVE_GLADIUS     235.0
#define p1_MOVE_SCYTHE      212.0
#define p1_MOVE_GREATSWORD  176.0
#define p1_MOVE_GLAIVE      245.0
#define p1_MOVE_GAUNTLETS   290.0
#define p1_MOVE_CLEAVER     240.0

#define p1_KATANA_SPEED          367.0
#define p1_KATANA_JUMP_MULT      1.67
// Pan parry (window/p1_cooldown/damage/knockback) is p1_now fully owned by
// parry.sma, which asks this plugin for the current weapon via the
// Melee_GetCurrent native below. Do not re-add pan-parry logic here -
// it will double-process alongside parry.sma.
#define p1_STAB_COOLDOWN         6.0
#define p1_CLAWS_STAB_COOLDOWN   3.0
#define p1_GAUNTLETS_STAB_COOLDOWN 3.0
#define p1_SAIS_STAB_COOLDOWN    6.0
#define p1_THORNS_DELAY          3.0
#define p1_THORNS_DAMAGE_MULT    0.50
#define p1_THORNS_HUD_R          190
#define p1_THORNS_HUD_G          255
#define p1_THORNS_HUD_B          50
#define p1_SUPPRESS_HUD_R        128
#define p1_SUPPRESS_HUD_G        0
#define p1_SUPPRESS_HUD_B        32
#define p1_VULN_DURATION         4.0
#define p1_VULN_MULTIPLIER       1.15
#define p1_MICRO_CHANCE          67
#define p1_MICRO_DELAY           3.5
#define p1_MICRO_STUN            2.0
#define p1_BAT_SLASH_KB         405.0
#define p1_BAT_STAB_KB           600.0
#define p1_BAT_STAB_UP           247.0
#define p1_REGEN_AMOUNT           4
#define p1_REGEN_INTERVAL        6.0
#define p1_MAX_MELEE_HEALTH    400
#define p1_MAX_ARMOR            100
#define p1_GLADIUS_FORTIFY_BONUS 20.0
#define p1_GLADIUS_STEAL_AMOUNT  25
#define p1_IN_SPEED            (1<<17)
#define p1_HITGROUP_HEAD         1

// Micro-bomb launch velocity. Height scales with velocity^2, so this is
// 2x the original 220.0 -> ~4x the original apex height (4x height needs
// only 2x velocity, not 4x). Tune this number directly if it looks off.
#define p1_MICRO_BOMB_LAUNCH_VEL 670.0
#define p1_MICRO_BOMB_DAMAGE     25.0

// Marks p1_a damage event as p1_a synthetic parry counter-hit coming from
// parry.sma, so this plugin (and other damage plugins) don't reprocess
// or overwrite it. Must match p1_DMG_PARRY_COUNTER in parry.sma and
// heavy_cooldown.sma exactly.
#define p1_DMG_PARRY_COUNTER   (1<<24)
#define p1_DMG_CUSTOM_MELEE    (1<<29)

new const g_MeleeNames[][] =
{
    "Knife", "Katana", "Pan", "Longsword", "Hammer", "Claws", "Bat", "Axe",
    "Greatsword", "Naginata", "Sais", "Glaive", "Gladius", "Scythe", "Gauntlets", "Cleaver"
}

new p1_g_Melee[33]                 // weapon active for the current round
new p1_g_PendingMelee[33]         // next-round selection
new bool:p1_g_HasPendingMelee[33]
new Float:p1_g_AnimLockUntil[33]
new bool:p1_g_bIdleAnimPlayed[33]
new bool:p1_g_AllowWeaponAnim[33]
new Float:p1_g_NextStab[33]
new Float:p1_g_SuppressedUntil[33]
new p1_g_ThornsSource[33]
new Float:p1_g_ThornsDamage[33]
new Float:p1_g_ThornsEndTime[33]
new p1_g_AttackType[33]       // 1 slash, 2 p1_stab
new p1_g_HitGroup[33]
new p1_g_HitVictim[33]
new bool:p1_g_Vulnerable[33]
new bool:p1_g_GlaiveBerserk[33]
new bool:p1_g_GlaiveFrozen[33]
new Float:p1_g_GlaiveFreezeEnd[33]
new Float:p1_g_GlaiveGlowBrightEnd[33]
new bool:p1_g_ShockwaveVictim[33]
new bool:p4_g_bGreatswordBypass[33]
new bool:p1_g_MicroBomb[33]
new p1_g_MicroBombOwner[33]
new Float:p1_g_BombEndTime[33]
new bool:p1_g_MicroStunned[33]
new p1_g_HammerGravity[33]    // 0 = 500, 1 = 1000
new p1_g_Vault
new p1_g_msgScreenFade
new p1_g_HealthHudSync
new p1_g_WeaponSprite[33]
new Float:p1_g_MaceLandUntil[33]
new bool:p1_g_HammerAirHit[33]
new bool:p4_g_ParryActive[33]
new bool:p4_g_ParryAttempt[33]
new p1_g_LastButtons[33]
new bool:p1_g_ReplacingSound[33]
new bool:p1_g_SuppressNextHitSound[33]

// Scythe Soul Reap state. The five-hit charge stays armed after first charge.
new p1_g_ScytheHits[33]
new bool:p1_g_ScytheCloaked[33]
new p1_g_ScytheCorpse[33]
new p1_g_ScytheOldEffects[33]
#define p1_SCYTHE_CHARGE_HITS 5
#define p1_SCYTHE_PROC_CHANCE 40
#define p1_SCYTHE_CLOAK_TIME 5.0
#define p1_SCYTHE_TASK_CLOAK 16000
new bool:p5_g_bBlockActive[33]; // declared here because the melee damage hook uses it above the block module
#define p1_TASK_WEAPON_SPRITE 77100
#define p1_SPRITE_MODEL "sprites/glow.spr"

new const p1_WeaponSounds[16][5][] = {
    {"", "", "", "", ""},
    {"weapons/knife_arena/katana_deploy.wav", "weapons/knife_arena/katana_hit.wav", "weapons/knife_arena/katana_slash.wav", "weapons/knife_arena/katana_hitwall.wav", "weapons/knife_arena/katana_stab.wav"},
    {"weapons/knife_arena/pan_deploy.wav", "weapons/knife_arena/pan_hit.wav", "weapons/knife_arena/pan_slash.wav", "weapons/knife_arena/pan_hitwall.wav", "weapons/knife_arena/pan_stab.wav"},
    {"weapons/knife_arena/longsword_deploy.wav", "weapons/knife_arena/longsword_hit.wav", "weapons/knife_arena/longsword_slash.wav", "weapons/knife_arena/longsword_hitwall.wav", "weapons/knife_arena/longsword_stab.wav"},
    {"weapons/knife_arena/hammer_deploy.wav", "weapons/knife_arena/hammer_hit.wav", "weapons/knife_arena/hammer_slash.wav", "weapons/knife_arena/hammer_hitwall.wav", "weapons/knife_arena/hammer_stab.wav"},
    {"weapons/knife_arena/claws_deploy.wav", "weapons/knife_arena/claws_hit.wav", "weapons/knife_arena/claws_slash.wav", "weapons/knife_arena/claws_hitwall.wav", "weapons/knife_arena/claws_stab.wav"},
    {"weapons/knife_arena/bat_deploy.wav", "weapons/knife_arena/bat_hit.wav", "weapons/knife_arena/bat_slash.wav", "weapons/knife_arena/bat_hitwall.wav", "weapons/knife_arena/bat_stab.wav"},
    {"weapons/knife_arena/axe_deploy.wav", "weapons/knife_arena/axe_hit.wav", "weapons/knife_arena/axe_slash.wav", "weapons/knife_arena/axe_hitwall.wav", "weapons/knife_arena/axe_stab.wav"},
    {"weapons/knife_arena/greatsword_deploy.wav", "weapons/knife_arena/greatsword_hit.wav", "weapons/knife_arena/greatsword_slash.wav", "weapons/knife_arena/greatsword_hitwall.wav", "weapons/knife_arena/greatsword_stab.wav"},
    {"weapons/knife_arena/naginata_deploy.wav", "weapons/knife_arena/naginata_hit.wav", "weapons/knife_arena/naginata_slash.wav", "weapons/knife_arena/naginata_hitwall.wav", "weapons/knife_arena/naginata_stab.wav"},
    {"weapons/knife_arena/sais_deploy.wav", "weapons/knife_arena/sais_hit.wav", "weapons/knife_arena/sais_slash.wav", "weapons/knife_arena/sais_hitwall.wav", "weapons/knife_arena/sais_stab.wav"},
    {"weapons/knife_arena/glaive_deploy.wav", "weapons/knife_arena/glaive_hit.wav", "weapons/knife_arena/glaive_slash.wav", "weapons/knife_arena/glaive_hitwall.wav", "weapons/knife_arena/glaive_stab.wav"},
    {"weapons/knife_arena/gladius_deploy.wav", "weapons/knife_arena/gladius_hit.wav", "weapons/knife_arena/gladius_slash.wav", "weapons/knife_arena/gladius_hitwall.wav", "weapons/knife_arena/gladius_stab.wav"},
    {"weapons/knife_arena/scythe_deploy.wav", "weapons/knife_arena/scythe_hit.wav", "weapons/knife_arena/scythe_slash.wav", "weapons/knife_arena/scythe_hitwall.wav", "weapons/knife_arena/scythe_stab.wav"},
    {"weapons/knife_arena/gauntlets_deploy.wav", "weapons/knife_arena/gauntlets_hit.wav", "weapons/knife_arena/gauntlets_slash.wav", "weapons/knife_arena/gauntlets_hitwall.wav", "weapons/knife_arena/gauntlets_stab.wav"},
    {"weapons/knife_arena/cleaver_deploy.wav", "weapons/knife_arena/cleaver_hit.wav", "weapons/knife_arena/cleaver_slash.wav", "weapons/knife_arena/cleaver_hitwall.wav", "weapons/knife_arena/cleaver_stab.wav"}
};

public p1_plugin_precache()
{
    precache_sound("weapons/knife_arena/axe_hitwall.wav")
    precache_model(p1_MODEL_KNIFE)
    precache_model(p1_MODEL_KATANA)
    precache_model(p1_MODEL_PAN)
    precache_model(p1_MODEL_LONGSWORD)
    precache_model(p1_MODEL_HAMMER)
    precache_model(p1_MODEL_CLAWS)
    precache_model(p1_MODEL_BAT)
    precache_model(p1_MODEL_AXE)
    precache_model(p1_MODEL_SAIS)
    precache_model(p1_MODEL_NAGINATA)
    precache_model(p1_MODEL_GLADIUS)
    precache_model(p1_MODEL_SCYTHE)
    precache_model(p1_MODEL_GREATSWORD)
    precache_model(p1_MODEL_GLAIVE)
    precache_model(p1_MODEL_GAUNTLETS)
    precache_model(p1_MODEL_CLEAVER)
    precache_model(p1_SPRITE_MODEL)
    precache_model(p1_SPRITE_KNIFE)
    precache_model(p1_SPRITE_KATANA)
    precache_model(p1_SPRITE_PAN)
    precache_model(p1_SPRITE_LONGSWORD)
    precache_model(p1_SPRITE_HAMMER)
    precache_model(p1_SPRITE_CLAWS)
    precache_model(p1_SPRITE_BAT)
    precache_model(p1_SPRITE_AXE)
    precache_model(p1_SPRITE_SAIS)
    precache_model(p1_SPRITE_NAGINATA)
    precache_model(p1_SPRITE_GLADIUS)
    precache_model(p1_SPRITE_GREATSWORD)
    precache_model(p1_SPRITE_GLAIVE)
    precache_model(p1_SPRITE_GAUNTLETS)
    precache_model(p1_SPRITE_CLEAVER)
    precache_model(p1_SPRITE_SCYTHE)
    for(new w = 1; w < p1_MELEE_COUNT; w++)
        for(new snd = 0; snd < 5; snd++)
            precache_sound(p1_WeaponSounds[w][snd])
    precache_sound("weapons/sg_explode.wav")
    precache_sound("weapons/knife_deploy1.wav")
    precache_sound("weapons/knife_hit1.wav")
    precache_sound("weapons/knife_hit2.wav")
    precache_sound("weapons/knife_hit3.wav")
    precache_sound("weapons/knife_hit4.wav")
    precache_sound("weapons/knife_hitwall1.wav")
    precache_sound("weapons/knife_slash1.wav")
    precache_sound("weapons/knife_slash2.wav")
    precache_sound("weapons/knife_stab.wav")
    precache_sound("player/die1.wav")

    precache_sound("weapons/knife_arena/glaive_berserk.wav")
}

public p1_plugin_init()
{

    register_clcmd("say /melee", "p1_cmd_melee")
    register_clcmd("say_team /melee", "p1_cmd_melee")
    register_clcmd("katana", "p1_cmd_katana")
    register_clcmd("pan", "p1_cmd_pan")
    register_clcmd("longsword", "p1_cmd_longsword")
    register_clcmd("hammer", "p1_cmd_hammer")
    register_clcmd("claws", "p1_cmd_claws")
    register_clcmd("bat", "p1_cmd_bat")
    register_clcmd("axe", "p1_cmd_axe")
    register_clcmd("greatsword", "p1_cmd_greatsword")
    register_clcmd("naginata", "p1_cmd_naginata")
    register_clcmd("sais", "p1_cmd_sais")
    register_clcmd("glaive", "p1_cmd_glaive")
    register_clcmd("gauntlets", "p1_cmd_gauntlets")
    register_clcmd("cleaver", "p1_cmd_cleaver")
    register_clcmd("gladius", "p1_cmd_gladius")
    register_clcmd("scythe", "p1_cmd_scythe")
    register_clcmd("knife", "p1_cmd_knife")

    register_event("CurWeapon", "p1_ev_CurWeapon", "be", "1=1", "2=29")
    register_logevent("p1_ev_RoundStart", 2, "1=Round_Start")
    register_message(get_user_msgid("WeaponAnim"), "p1_Message_WeaponAnim")
    register_forward(FM_CmdStart, "p1_fw_CmdStart")
    register_forward(FM_EmitSound, "p1_fw_EmitSound_Pre", 0)
    register_forward(FM_PlayerPreThink, "p1_fw_PlayerPreThink")
    set_task(0.10, "p1_UpdateWeaponSprites", p1_TASK_WEAPON_SPRITE, _, _, "b")
    set_task(0.10, "p1_UpdateAllAbilityGlows", 17777, _, _, "b")

    RegisterHam(Ham_Spawn, "player", "p1_fw_Spawn_Post", 1)
    RegisterHam(Ham_Killed, "player", "p1_fw_Killed_Post", 1)
    RegisterHam(Ham_TraceAttack, "player", "p1_fw_TraceAttack")
    RegisterHam(Ham_TakeDamage, "player", "p1_fw_TakeDamage")
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "p1_fw_PrimaryAttack_Pre")
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "p1_fw_PrimaryAttack_Post", 1)
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "p1_fw_SecondaryAttack_Pre")
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "p1_fw_SecondaryAttack_Post", 1)
    RegisterHam(Ham_Item_Deploy, "weapon_knife", "p1_fw_Deploy_Post", 1)
    RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "p1_fw_WeaponIdle_Post", 1)

    p1_g_msgScreenFade = get_user_msgid("ScreenFade")
    p1_g_HealthHudSync = CreateHudSyncObj()
    set_task(0.10, "p1_UpdateHealthHud", 17778, _, _, "b")
    p1_g_Vault = nvault_open("melee_selection")

    if(p1_g_Vault == INVALID_HANDLE)
        set_fail_state("Could not open melee_selection vault")

    // Exposes the player's selected p1_melee weapon (MELEE_* constant) to
    // other plugins. IMPORTANT: this plugin must be loaded BEFORE any
    // plugin that calls this native (parry.sma, heavy_cooldown.sma,
    // light_cooldown.sma) - put melee_menu.sma first in plugins.ini.
    register_native("Melee_GetCurrent", "p1_native_Melee_GetCurrent")
}

public p1_UpdateHealthHud(taskid)
{
    new players[32], count
    get_players(players, count, "a")
    for(new i = 0; i < count; i++)
    {
        new id = players[i]
        new hp = get_user_health(id)
        if(hp < 0) hp = 0
        set_hudmessage(255, 255, 255, 0.02, 0.90, 0, 0.0, 0.15, 0.0, 0.0, 3)
        ShowSyncHudMsg(id, p1_g_HealthHudSync, "HP: %d", hp)
    }
}

// Persistent colored glow sprite above each alive player's head. It is visible
// while the custom melee/knife is equipped; it hides while a firearm is held.
public p1_UpdateWeaponSprites(taskid)
{
    new players[32], count
    get_players(players, count, "a")
    for(new i = 0; i < count; i++)
    {
        new id = players[i]
        if(p1_g_ScytheCloaked[id])
        {
            if(pev_valid(p1_g_WeaponSprite[id]))
                set_pev(p1_g_WeaponSprite[id], pev_effects, EF_NODRAW)
            continue
        }
        if(get_user_weapon(id) != CSW_KNIFE)
        {
            if(pev_valid(p1_g_WeaponSprite[id])) set_pev(p1_g_WeaponSprite[id], pev_effects, EF_NODRAW)
            continue
        }

        new ent = p1_g_WeaponSprite[id]
        if(!pev_valid(ent))
        {
            ent = create_entity("env_sprite")
            if(!pev_valid(ent)) continue
            p1_g_WeaponSprite[id] = ent
            entity_set_string(ent, EV_SZ_classname, "unified_melee_weapon_sprite")
            entity_set_model(ent, p1_SPRITE_MODEL)
            set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
            set_pev(ent, pev_aiment, id)
            set_pev(ent, pev_owner, id)
            set_pev(ent, pev_scale, 0.25)
            set_pev(ent, pev_rendermode, kRenderTransAdd)
            set_pev(ent, pev_renderamt, 220.0)
            set_pev(ent, pev_frame, 0.0)
            set_pev(ent, pev_framerate, 10.0)
        }
        new spriteModel[64]
        switch(p1_g_Melee[id])
        {
            case p1_MELEE_KNIFE: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_KNIFE)
            case p1_MELEE_KATANA: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_KATANA)
            case p1_MELEE_PAN: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_PAN)
            case p1_MELEE_LONGSWORD: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_LONGSWORD)
            case p1_MELEE_HAMMER: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_HAMMER)
            case p1_MELEE_CLAWS: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_CLAWS)
            case p1_MELEE_BAT: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_BAT)
            case p1_MELEE_AXE: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_AXE)
            case p1_MELEE_GREATSWORD: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_GREATSWORD)
            case p1_MELEE_GAUNTLETS: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_GAUNTLETS)
            case p1_MELEE_SAIS: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_SAIS)
            case p1_MELEE_NAGINATA: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_NAGINATA)
            case p1_MELEE_GLADIUS: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_GLADIUS)
            case p1_MELEE_SCYTHE: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_SCYTHE)
            case p1_MELEE_GLAIVE: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_GLAIVE)
            case p1_MELEE_CLEAVER: copy(spriteModel, charsmax(spriteModel), p1_SPRITE_CLEAVER)
        }
        entity_set_model(ent, spriteModel)
        set_pev(ent, pev_effects, 0)
        new r, g, b
        switch(p1_g_Melee[id])
        {
            case p1_MELEE_KATANA: { r = 255; g = 200; b = 5; }       // gold
            case p1_MELEE_PAN: { r = 5; g = 240; b = 255; }          // cyan
            case p1_MELEE_LONGSWORD: { r = 30; g = 90; b = 255; }    // blue
            case p1_MELEE_HAMMER: { r = 30; g = 255; b = 70; }      // green
            case p1_MELEE_CLAWS: { r = 245; g = 5; b = 255; }        // purple
            case p1_MELEE_AXE: { r = 255; g = 20; b = 20; }          // red
            case p1_MELEE_KNIFE: { r = 67; g = 128; b = 0; }       // olive green
            case p1_MELEE_BAT: { r = 255; g = 125; b = 10; }         // orange
            case p1_MELEE_SAIS: { r = 190; g = 255; b = 50; }        // lemon green
            case p1_MELEE_NAGINATA: { r = 128; g = 0; b = 32; }      // maroon
            case p1_MELEE_GLADIUS: { r = 167; g = 167; b = 167; }    // silver
            case p1_MELEE_SCYTHE: { r = 167; g = 20; b = 255; }     // violet
            case p1_MELEE_GLAIVE: { r = 95; g = 210; b = 255; }     // sky blue
            case p1_MELEE_CLEAVER: { r = 175; g = 50; b = 45; }      // crimson
            case p1_MELEE_GREATSWORD: { r = 140; g = 95; b = 5; }     // brown
            case p1_MELEE_GAUNTLETS: { r = 240; g = 240; b = 240; }     // white
            default: { r = 255; g = 255; b = 255; }
        }
        new Float:color[3]
        color[0] = float(r); color[1] = float(g); color[2] = float(b)
        set_pev(ent, pev_rendercolor, color)
        new Float:origin[3]
        pev(id, pev_origin, origin)
        origin[2] += 72.0
        set_pev(ent, pev_origin, origin)
    }
}

public client_disconnected(id)
{
    // A disconnected killer cannot remain a Revenge target if their player
    // slot is later reused by someone else.
    for(new other=1;other<=32;other++)
    {
        if(g_AchLastRoundKiller[other]==id) g_AchLastRoundKiller[other]=0;
        if(g_AchPreviousRoundKiller[other]==id) g_AchPreviousRoundKiller[other]=0;
    }
    // Save achievement progress before player state is reset.
    ach_save(id)
    g_AchRecentKillCount[id]=0
    for(new k=0;k<32;k++) g_AchRecentKillTimes[id][k]=0.0
    arrayset(g_AchRecentKillVictims[id],0,32)
    remove_task(id+19000)
    // Selection is saved immediately on change and again at disconnect.
    p1_SaveMelee(id)
    p1_ScytheCleanup(id)
    p1_g_ScytheHits[id] = 0
    remove_task(id + 11000)
    p1_RemovePlayerTasks(id)
    if(pev_valid(p1_g_WeaponSprite[id])) remove_entity(p1_g_WeaponSprite[id])
    p1_g_WeaponSprite[id] = 0
    p1_g_Melee[id] = p1_MELEE_KNIFE
    p1_g_PendingMelee[id] = p1_MELEE_KNIFE
    p1_g_HasPendingMelee[id] = false
    p1_g_GlaiveBerserk[id] = false
    p1_g_GlaiveFrozen[id] = false
    remove_task(id + 15000)
}

stock p1_GetCombatMelee(p1_id)
{
    // Suppression disables abilities only. Keep the selected weapon identity
    // for damage, range, attack speed, stab cooldown and exhaustion handling.
    return (p1_id >= 1 && p1_id <= 32) ? p1_g_Melee[p1_id] : p1_MELEE_KNIFE
}

stock bool:p1_IsSuppressed(p1_id)
{
    return (p1_id >= 1 && p1_id <= 32 && get_gametime() < p1_g_SuppressedUntil[p1_id])
}

public p1_native_Melee_GetCurrent(plugin_id, numparams)
{
    new p1_id = get_param(1)
    if(p1_id < 1 || p1_id > 32 || !is_user_connected(p1_id))
        return p1_MELEE_KNIFE
    return p1_GetCombatMelee(p1_id)
}

public p1_client_putinserver(p1_id)
{
    p1_g_WeaponSprite[p1_id] = 0
    p1_g_ScytheHits[p1_id] = 0
    p1_g_ScytheCloaked[p1_id] = false
    p1_g_ScytheCorpse[p1_id] = 0
    p1_g_ScytheOldEffects[p1_id] = 0
    p1_g_Melee[p1_id] = p1_MELEE_KNIFE
    p1_g_PendingMelee[p1_id] = p1_MELEE_KNIFE
    p1_g_HasPendingMelee[p1_id] = false
    p1_g_GlaiveBerserk[p1_id] = false
    p1_g_GlaiveFrozen[p1_id] = false
    p1_g_GlaiveFreezeEnd[p1_id] = 0.0
    p1_g_GlaiveGlowBrightEnd[p1_id] = 0.0
    p1_g_ShockwaveVictim[p1_id] = false
    p1_g_NextStab[p1_id] = 0.0
    p1_g_SuppressedUntil[p1_id] = 0.0
    p1_g_ThornsSource[p1_id] = 0
    p1_g_ThornsDamage[p1_id] = 0.0
    p1_g_ThornsEndTime[p1_id] = 0.0
    p1_g_AttackType[p1_id] = 0
    p1_g_HitGroup[p1_id] = 0
    p1_g_HitVictim[p1_id] = 0
    p1_g_Vulnerable[p1_id] = false
    p1_g_GlaiveBerserk[p1_id] = false
    p1_g_GlaiveFrozen[p1_id] = false
    p1_g_GlaiveFreezeEnd[p1_id] = 0.0
    p1_g_GlaiveGlowBrightEnd[p1_id] = 0.0
    p1_g_ShockwaveVictim[p1_id] = false
    remove_task(p1_id + 15000)
    p1_g_MicroBomb[p1_id] = false
    p1_g_MicroBombOwner[p1_id] = 0
    p1_g_BombEndTime[p1_id] = 0.0
    p1_g_MicroStunned[p1_id] = false
    p1_g_HammerGravity[p1_id] = 0
    set_task(1.0, "p1_LoadMelee", p1_id)
}

public p1_client_disconnect(p1_id)
{
    p1_SaveMelee(p1_id)
    remove_task(p1_id + 11000)
    p1_RemovePlayerTasks(p1_id)
    p1_g_Melee[p1_id] = p1_MELEE_KNIFE
    p1_g_PendingMelee[p1_id] = p1_MELEE_KNIFE
    p1_g_HasPendingMelee[p1_id] = false
    p1_g_GlaiveBerserk[p1_id] = false
    p1_g_GlaiveFrozen[p1_id] = false
    remove_task(p1_id + 15000)
}

public p1_RemovePlayerTasks(p1_id)
{
    remove_task(p1_id + 1000)
    remove_task(p1_id + 2000)
    remove_task(p1_id + 3000)
    remove_task(p1_id + 4000)
    remove_task(p1_id + 5000)
    remove_task(p1_id + 6000)
    remove_task(p1_id + 7000)
    remove_task(p1_id + 8000)
    remove_task(p1_id + 9000)
    remove_task(p1_id + 12000)
    remove_task(p1_id + 13000)
    remove_task(p1_id + 14000)
}

public p1_SaveMelee(p1_id)
{
    if(p1_id < 1 || p1_id > 32 || p1_g_Vault == INVALID_HANDLE) return
    new p1_authid[35], key[64], value[16]
    get_user_authid(p1_id, p1_authid, charsmax(p1_authid))
    if(!p1_authid[0] || equal(p1_authid, "STEAM_ID_PENDING"))
    {
        if(is_user_connected(p1_id) && !task_exists(p1_id + 11000))
            set_task(1.0, "p1_RetrySaveMelee", p1_id + 11000)
        return
    }
    remove_task(p1_id + 11000)
    formatex(key, charsmax(key), "MELEE_V2_%s", p1_authid)
    new selection = p1_g_HasPendingMelee[p1_id] ? p1_g_PendingMelee[p1_id] : p1_g_Melee[p1_id]
    num_to_str(selection, value, charsmax(value))
    nvault_set(p1_g_Vault, key, value)
}

public p1_RetrySaveMelee(taskid)
{
    new p1_id = taskid - 11000
    if(is_user_connected(p1_id))
        p1_SaveMelee(p1_id)
}

public p1_LoadMelee(p1_id)
{
    if(!is_user_connected(p1_id)) return
    new p1_authid[35], key[64], value[16]
    get_user_authid(p1_id, p1_authid, charsmax(p1_authid))
    if(!p1_authid[0] || equal(p1_authid, "STEAM_ID_PENDING"))
    {
        set_task(1.0, "p1_LoadMelee", p1_id)
        return
    }
    formatex(key, charsmax(key), "MELEE_V2_%s", p1_authid)
    if(nvault_get(p1_g_Vault, key, value, charsmax(value)))
    {
        p1_g_Melee[p1_id] = str_to_num(value)
        if(p1_g_Melee[p1_id] < p1_MELEE_KNIFE || p1_g_Melee[p1_id] >= p1_MELEE_COUNT)
            p1_g_Melee[p1_id] = p1_MELEE_KNIFE
        p1_g_PendingMelee[p1_id] = p1_g_Melee[p1_id]
        p1_g_HasPendingMelee[p1_id] = false
    }
    else
    {
        // Migrate pre-16-weapon selections from the old numeric order.
        formatex(key, charsmax(key), "MELEE_%s", p1_authid)
        if(nvault_get(p1_g_Vault, key, value, charsmax(value)))
        {
            new oldSelection = str_to_num(value)
            switch(oldSelection)
            {
                case 8: p1_g_Melee[p1_id] = p1_MELEE_SAIS
                case 9: p1_g_Melee[p1_id] = p1_MELEE_NAGINATA
                case 10: p1_g_Melee[p1_id] = p1_MELEE_GLADIUS
                case 11: p1_g_Melee[p1_id] = p1_MELEE_SCYTHE
                default: p1_g_Melee[p1_id] = oldSelection
            }
            if(p1_g_Melee[p1_id] < p1_MELEE_KNIFE || p1_g_Melee[p1_id] >= p1_MELEE_COUNT)
                p1_g_Melee[p1_id] = p1_MELEE_KNIFE
            p1_SaveMelee(p1_id)
        }
    }
    p1_g_PendingMelee[p1_id] = p1_g_Melee[p1_id]
    p1_g_HasPendingMelee[p1_id] = false
    p1_ApplyMelee(p1_id)
}

public p1_ev_RoundStart()
{
    for(new id = 1; id <= 32; id++)
    {
        if(!is_user_connected(id) || !p1_g_HasPendingMelee[id])
            continue

        new nextMelee = p1_g_PendingMelee[id]
        if(nextMelee < p1_MELEE_KNIFE || nextMelee >= p1_MELEE_COUNT)
            nextMelee = p1_MELEE_KNIFE

        if(p1_g_Melee[id] != nextMelee)
        {
            p1_g_GlaiveBerserk[id] = false
            p1_g_GlaiveFrozen[id] = false
            p1_g_GlaiveFreezeEnd[id] = 0.0
            p1_g_GlaiveGlowBrightEnd[id] = 0.0
            remove_task(id + 15000)
            p1_g_Melee[id] = nextMelee
            p1_g_SlashAnimStep[id] = 0
            p1_g_NextStab[id] = 0.0
            p1_g_HammerGravity[id] = 0
        }

        p1_g_HasPendingMelee[id] = false
        p1_SaveMelee(id)
        if(is_user_alive(id))
        {
            p1_ApplyMelee(id)
            p7_UpdatePlayerGlow(id)
        }
    }
}

public p1_cmd_melee(p1_id)
{
    p1_ShowMeleeMenu(p1_id)
    return PLUGIN_HANDLED
}

public p1_ShowMeleeMenu(p1_id)
{
    new p1_menu = menu_create("\rMelee Weapons", "p1_MeleeMenuHandler")
    new p1_item[128]
    new const p1_Abilities[][] =
    {
        "Regeneration", "Speed", "Parry Damage", "Vulnerability",
        "Gravity Control", "Micro-bomb", "Knockback", "Lifesteal",
        "Block Breaker", "Suppression", "Thorns", "Berserk",
        "Fortification", "Soul Reap", "Iron Fist", "Execution"
    }

    for(new i = 0; i < p1_MELEE_COUNT; i++)
    {
        if((p1_g_HasPendingMelee[p1_id] ? p1_g_PendingMelee[p1_id] : p1_g_Melee[p1_id]) == i)
        {
            if(p1_g_HasPendingMelee[p1_id])
                formatex(p1_item, charsmax(p1_item), "%s \y[%s] \r[NEXT ROUND]", g_MeleeNames[i], p1_Abilities[i])
            else
                formatex(p1_item, charsmax(p1_item), "%s \y[%s] \y[ACTIVE]", g_MeleeNames[i], p1_Abilities[i])
        }
        else
            formatex(p1_item, charsmax(p1_item), "%s \y[%s]", g_MeleeNames[i], p1_Abilities[i])
        menu_additem(p1_menu, p1_item)
    }

    set_hudmessage(0, 100, 255, 0.02, 0.28, 0, 0.0, 5.0, 0.0, 0.0, -1)
    new shownMelee = p1_g_HasPendingMelee[p1_id] ? p1_g_PendingMelee[p1_id] : p1_g_Melee[p1_id]
    show_hudmessage(p1_id, "%s ability: %s", g_MeleeNames[shownMelee], p1_Abilities[shownMelee])
    menu_display(p1_id, p1_menu)
}

public p1_MeleeMenuHandler(p1_id, p1_menu, p1_item)
{
    if(p1_item != MENU_EXIT && p1_item >= 0 && p1_item < p1_MELEE_COUNT)
    {
        p1_SetMelee(p1_id, p1_item)
    }
    menu_destroy(p1_menu)
    return PLUGIN_HANDLED
}

public p1_cmd_knife(p1_id) { p1_SetMelee(p1_id, p1_MELEE_KNIFE); return PLUGIN_HANDLED; }
public p1_cmd_katana(p1_id) { p1_SetMelee(p1_id, p1_MELEE_KATANA); return PLUGIN_HANDLED; }
public p1_cmd_pan(p1_id) { p1_SetMelee(p1_id, p1_MELEE_PAN); return PLUGIN_HANDLED; }
public p1_cmd_longsword(p1_id) { p1_SetMelee(p1_id, p1_MELEE_LONGSWORD); return PLUGIN_HANDLED; }
public p1_cmd_hammer(p1_id) { p1_SetMelee(p1_id, p1_MELEE_HAMMER); return PLUGIN_HANDLED; }
public p1_cmd_claws(p1_id) { p1_SetMelee(p1_id, p1_MELEE_CLAWS); return PLUGIN_HANDLED; }
public p1_cmd_bat(p1_id) { p1_SetMelee(p1_id, p1_MELEE_BAT); return PLUGIN_HANDLED; }
public p1_cmd_axe(p1_id) { p1_SetMelee(p1_id, p1_MELEE_AXE); return PLUGIN_HANDLED; }
public p1_cmd_greatsword(p1_id) { p1_SetMelee(p1_id, p1_MELEE_GREATSWORD); return PLUGIN_HANDLED; }
public p1_cmd_naginata(p1_id) { p1_SetMelee(p1_id, p1_MELEE_NAGINATA); return PLUGIN_HANDLED; }
public p1_cmd_sais(p1_id) { p1_SetMelee(p1_id, p1_MELEE_SAIS); return PLUGIN_HANDLED; }
public p1_cmd_glaive(p1_id) { p1_SetMelee(p1_id, p1_MELEE_GLAIVE); return PLUGIN_HANDLED; }
public p1_cmd_gladius(p1_id) { p1_SetMelee(p1_id, p1_MELEE_GLADIUS); return PLUGIN_HANDLED; }
public p1_cmd_scythe(p1_id) { p1_SetMelee(p1_id, p1_MELEE_SCYTHE); return PLUGIN_HANDLED; }
public p1_cmd_gauntlets(p1_id) { p1_SetMelee(p1_id, p1_MELEE_GAUNTLETS); return PLUGIN_HANDLED; }
public p1_cmd_cleaver(p1_id) { p1_SetMelee(p1_id, p1_MELEE_CLEAVER); return PLUGIN_HANDLED; }

public p1_SetMelee(p1_id, p1_melee)
{
    if(!is_user_connected(p1_id) || p1_melee < p1_MELEE_KNIFE || p1_melee >= p1_MELEE_COUNT)
        return

    new currentChoice = p1_g_HasPendingMelee[p1_id] ? p1_g_PendingMelee[p1_id] : p1_g_Melee[p1_id]
    if(currentChoice == p1_melee)
    {
        client_print(p1_id, print_chat, "[Melee] %s is already selected.", g_MeleeNames[p1_melee])
        return
    }

    p1_g_PendingMelee[p1_id] = p1_melee
    p1_g_HasPendingMelee[p1_id] = true
    p1_SaveMelee(p1_id)
    client_print(p1_id, print_chat, "[Melee] %s selected. It will become active next round.", g_MeleeNames[p1_melee])
}


public p1_ev_CurWeapon(p1_id)
{
    if(!is_user_alive(p1_id)) return
    p1_ApplyMelee(p1_id)
}

// Suppress the engine's default server-side knife animations for custom melee
// weapons. Only WeaponAnim messages explicitly emitted by p1_PlayKnifeAnim pass.
public p1_Message_WeaponAnim(msgid, dest, id)
{
    if(id < 1 || id > 32 || !is_user_connected(id))
        return PLUGIN_CONTINUE

    if(!is_user_alive(id) || get_user_weapon(id) != CSW_KNIFE)
        return PLUGIN_CONTINUE

    if(p1_g_Melee[id] == p1_MELEE_KNIFE)
        return PLUGIN_CONTINUE

    if(p1_g_AllowWeaponAnim[id])
        return PLUGIN_CONTINUE

    return PLUGIN_HANDLED
}

// Replace GoldSrc's default knife sounds for custom melee weapons.
// The custom path table is the single source of truth; the recursion guard
// prevents our replacement emit_sound call from being intercepted again.
public p1_fw_EmitSound_Pre(entity, channel, const sample[], Float:volume, Float:attenuation, fFlags, pitch)
{
    new owner = entity
    if(entity < 1 || entity > 32)
    {
        if(!pev_valid(entity))
            return FMRES_IGNORED
        owner = pev(entity, pev_owner)
    }
    if(owner < 1 || owner > 32 || !is_user_connected(owner))
        return FMRES_IGNORED
    if(p1_g_ReplacingSound[owner])
        return FMRES_IGNORED

    // Dead Ringer-style drawback: footsteps remain audible while cloaked,
    // with half attenuation (approximately double audible distance).
    if(p1_g_ScytheCloaked[owner] && (containi(sample, "player/pl_step") == 0 ||
        containi(sample, "player/pl_tile") == 0 || containi(sample, "player/pl_wood") == 0 ||
        containi(sample, "player/pl_metal") == 0 || containi(sample, "player/pl_dirt") == 0 ||
        containi(sample, "player/pl_grate") == 0 || containi(sample, "player/pl_snow") == 0))
    {
        p1_g_ReplacingSound[owner] = true
        engfunc(EngFunc_EmitSound, entity, channel, sample, volume, attenuation * 0.5, fFlags, pitch)
        p1_g_ReplacingSound[owner] = false
        return FMRES_SUPERCEDE
    }
    if(get_user_weapon(owner) != CSW_KNIFE || p1_g_Melee[owner] == p1_MELEE_KNIFE)
        return FMRES_IGNORED
    if(containi(sample, "weapons/knife_") != 0)
        return FMRES_IGNORED

    new soundIndex = -1
    if(containi(sample, "knife_deploy") != -1)
        soundIndex = 0
    else if(containi(sample, "knife_hitwall") != -1)
        soundIndex = 3
    else if(containi(sample, "knife_hit") != -1)
        soundIndex = 1
    else if(containi(sample, "knife_slash") != -1)
        soundIndex = 2
    else if(containi(sample, "knife_stab") != -1)
        soundIndex = 4

    if(soundIndex == -1)
        return FMRES_IGNORED

    if(soundIndex == 1 && p1_g_SuppressNextHitSound[owner])
    {
        p1_g_SuppressNextHitSound[owner] = false
        return FMRES_SUPERCEDE
    }

    new soundPath[128]
    copy(soundPath, charsmax(soundPath), p1_WeaponSounds[p1_g_Melee[owner]][soundIndex])
    if(!soundPath[0])
        return FMRES_SUPERCEDE

    p1_g_ReplacingSound[owner] = true
    emit_sound(owner, channel, soundPath, volume, attenuation, fFlags, pitch)
    p1_g_ReplacingSound[owner] = false
    return FMRES_SUPERCEDE
}

public p1_fw_Deploy_Post(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(is_user_alive(p1_id))
    {
        p1_ApplyMelee(p1_id)
        p1_PlayKnifeAnim(p1_id, 3)
    }
    return HAM_IGNORED
}

public p1_fw_WeaponIdle_Post(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(!is_user_alive(p1_id) || get_user_weapon(p1_id) != CSW_KNIFE)
        return HAM_IGNORED

    // Never replace a slash/stab/draw/parry while its model sequence is
    // still playing. Once it finishes, send idle only once; repeatedly
    // restarting the idle sequence every WeaponIdle call causes viewmodel
    // shaking and prevents the idle sequence from completing.
    if(get_gametime() < p1_g_AnimLockUntil[p1_id])
        return HAM_IGNORED

    if(!p1_g_bIdleAnimPlayed[p1_id])
    {
        p1_PlayKnifeAnim(p1_id, 0)

        // Throttle the engine's idle callback so the same idle sequence
        // is not resent every frame. The viewmodel gets time to complete
        // and naturally loop its idle sequence.
        set_pdata_float(ent, 48, get_gametime() + 10.0, 4)
    }

    return HAM_IGNORED
}

public p1_fw_Killed_Post(p1_id, attacker, shouldgib)
{
    ach_on_death(p1_id)
    ach_on_kill(attacker, p1_id)
    g_AchKickOnlyOwner[p1_id] = 0
    g_AchKickOnlyBroken[p1_id] = false
    // A real death during the cloak must immediately discard the decoy body.
    p1_ScytheCleanup(p1_id)

    // Soul Reap: restore 150 HP for any genuine kill credited to the Scythe wielder,
    // regardless of weapon or damage type. Environmental deaths have no player attacker.
    if(attacker >= 1 && attacker <= 32 && attacker != p1_id &&
        is_user_connected(attacker) && p1_g_Melee[attacker] == p1_MELEE_SCYTHE)
    {
        new healedHealth = get_user_health(attacker) + 150
        if(healedHealth > p1_MAX_MELEE_HEALTH)
            healedHealth = p1_MAX_MELEE_HEALTH
        set_user_health(attacker, healedHealth)
    }

    return HAM_IGNORED
}

public p1_fw_Spawn_Post(p1_id)
{
    if(!is_user_alive(p1_id)) return
    p1_ScytheCleanup(p1_id)
    g_AchFallPending[p1_id]=false
    g_AchKickOwner[p1_id]=0
    g_AchBonelessOwner[p1_id]=0
    g_AchBonelessUntil[p1_id]=0.0
    g_AchKickOnlyOwner[p1_id]=0
    g_AchKickOnlyBroken[p1_id]=false
    g_AchStunOwner[p1_id]=0
    p1_g_ScytheHits[p1_id] = 0
    p1_g_AnimLockUntil[p1_id] = 0.0
    p1_g_bIdleAnimPlayed[p1_id] = false
    p1_g_AllowWeaponAnim[p1_id] = false
    p1_g_SuppressedUntil[p1_id] = 0.0
    p1_g_ThornsSource[p1_id] = 0
    p1_g_ThornsDamage[p1_id] = 0.0
    p1_g_ThornsEndTime[p1_id] = 0.0
    remove_task(p1_id + 12000)
    remove_task(p1_id + 13000)
    remove_task(p1_id + 14000)
    p1_g_NextStab[p1_id] = 0.0
    p1_g_Vulnerable[p1_id] = false
    p1_g_GlaiveBerserk[p1_id] = false
    p1_g_GlaiveFrozen[p1_id] = false
    p1_g_GlaiveFreezeEnd[p1_id] = 0.0
    p1_g_GlaiveGlowBrightEnd[p1_id] = 0.0
    p1_g_ShockwaveVictim[p1_id] = false
    remove_task(p1_id + 15000)
    p1_g_MicroBomb[p1_id] = false
    p1_g_MicroStunned[p1_id] = false
    p1_g_HammerGravity[p1_id] = 0
    p1_g_HammerAirHit[p1_id] = false
    p1_g_MaceLandUntil[p1_id] = 0.0
    p1_RemovePlayerTasks(p1_id)
    set_user_footsteps(p1_id, 0)
    set_user_gravity(p1_id, 1.0)
    set_task(0.3, "p1_ApplyMelee", p1_id)
}

public p1_ApplyMelee(p1_id)
{
    if(!is_user_alive(p1_id)) return
    if(get_user_weapon(p1_id) != CSW_KNIFE)
    {
        set_user_footsteps(p1_id, 0)
        set_user_gravity(p1_id, 1.0)
        set_pev(p1_id, pev_maxspeed, 0.0) // let the current firearm set its own speed
        return
    }

    new p1_model[64]
    switch(p1_g_Melee[p1_id])
    {
        case p1_MELEE_KNIFE: copy(p1_model, charsmax(p1_model), p1_MODEL_KNIFE)
        case p1_MELEE_KATANA: copy(p1_model, charsmax(p1_model), p1_MODEL_KATANA)
        case p1_MELEE_PAN: copy(p1_model, charsmax(p1_model), p1_MODEL_PAN)
        case p1_MELEE_LONGSWORD: copy(p1_model, charsmax(p1_model), p1_MODEL_LONGSWORD)
        case p1_MELEE_HAMMER: copy(p1_model, charsmax(p1_model), p1_MODEL_HAMMER)
        case p1_MELEE_CLAWS: copy(p1_model, charsmax(p1_model), p1_MODEL_CLAWS)
        case p1_MELEE_BAT: copy(p1_model, charsmax(p1_model), p1_MODEL_BAT)
        case p1_MELEE_AXE: copy(p1_model, charsmax(p1_model), p1_MODEL_AXE)
        case p1_MELEE_SAIS: copy(p1_model, charsmax(p1_model), p1_MODEL_SAIS)
        case p1_MELEE_NAGINATA: copy(p1_model, charsmax(p1_model), p1_MODEL_NAGINATA)
        case p1_MELEE_GLADIUS: copy(p1_model, charsmax(p1_model), p1_MODEL_GLADIUS)
        case p1_MELEE_SCYTHE: copy(p1_model, charsmax(p1_model), p1_MODEL_SCYTHE)
        case p1_MELEE_GREATSWORD: copy(p1_model, charsmax(p1_model), p1_MODEL_GREATSWORD)
        case p1_MELEE_GLAIVE: copy(p1_model, charsmax(p1_model), p1_MODEL_GLAIVE)
        case p1_MELEE_GAUNTLETS: copy(p1_model, charsmax(p1_model), p1_MODEL_GAUNTLETS)
        case p1_MELEE_CLEAVER: copy(p1_model, charsmax(p1_model), p1_MODEL_CLEAVER)
    }
    set_pev(p1_id, pev_viewmodel2, p1_model)

    // Pan and Claws have silent footsteps.
    if(p1_g_Melee[p1_id] == p1_MELEE_PAN || p1_g_Melee[p1_id] == p1_MELEE_CLAWS || p1_g_Melee[p1_id] == p1_MELEE_SAIS)
        set_user_footsteps(p1_id, 1)
    else
        set_user_footsteps(p1_id, 0)

    p1_ApplyGravity(p1_id)

    // Always set the selected melee weapon's speed. Never leave a previous
    // weapon's speed behind when changing weapons.
    new Float:p1_moveSpeed = p1_MOVE_KNIFE
    switch(p1_g_Melee[p1_id])
    {
        case p1_MELEE_KNIFE: p1_moveSpeed = p1_MOVE_KNIFE
        case p1_MELEE_KATANA: p1_moveSpeed = p1_MOVE_KATANA
        case p1_MELEE_PAN: p1_moveSpeed = p1_MOVE_PAN
        case p1_MELEE_LONGSWORD: p1_moveSpeed = p1_MOVE_LONGSWORD
        case p1_MELEE_HAMMER: p1_moveSpeed = p1_MOVE_HAMMER
        case p1_MELEE_CLAWS: p1_moveSpeed = p1_MOVE_CLAWS
        case p1_MELEE_BAT: p1_moveSpeed = p1_MOVE_BAT
        case p1_MELEE_AXE: p1_moveSpeed = p1_MOVE_AXE
        case p1_MELEE_SAIS: p1_moveSpeed = p1_MOVE_SAIS
        case p1_MELEE_NAGINATA: p1_moveSpeed = p1_MOVE_NAGINATA
        case p1_MELEE_GLADIUS: p1_moveSpeed = p1_MOVE_GLADIUS
        case p1_MELEE_SCYTHE: p1_moveSpeed = p1_MOVE_SCYTHE
        case p1_MELEE_GREATSWORD: p1_moveSpeed = p1_MOVE_GREATSWORD
        case p1_MELEE_GLAIVE: p1_moveSpeed = p1_MOVE_GLAIVE
        case p1_MELEE_GAUNTLETS: p1_moveSpeed = p1_MOVE_GAUNTLETS
        case p1_MELEE_CLEAVER: p1_moveSpeed = p1_MOVE_CLEAVER
    }
    set_pev(p1_id, pev_maxspeed, p1_moveSpeed)

    if(p1_g_Melee[p1_id] == p1_MELEE_KNIFE)
        p1_StartRegen(p1_id)
    else
        p1_StopRegen(p1_id)
}

public p1_StartRegen(p1_id)
{
    if(!is_user_alive(p1_id))
        return

    if(p1_g_Melee[p1_id] != p1_MELEE_KNIFE || get_user_weapon(p1_id) != CSW_KNIFE)
        return

    if(task_exists(p1_id + 9000))
        return

    set_task(p1_REGEN_INTERVAL, "p1_KnifeRegen", p1_id + 9000, _, _, "b")
}

public p1_StopRegen(p1_id)
{
    remove_task(p1_id + 9000)
}

public p1_KnifeRegen(taskid)
{
    new p1_id = taskid - 9000

    if(!is_user_alive(p1_id))
    {
        remove_task(taskid)
        return
    }

    if(p1_g_Melee[p1_id] != p1_MELEE_KNIFE || get_user_weapon(p1_id) != CSW_KNIFE)
    {
        remove_task(taskid)
        return
    }

    new p1_hp = get_user_health(p1_id)

    if(p1_hp < p1_MAX_MELEE_HEALTH)
    {
        p1_hp += p1_REGEN_AMOUNT

        if(p1_hp > p1_MAX_MELEE_HEALTH)
            p1_hp = p1_MAX_MELEE_HEALTH

        set_user_health(p1_id, p1_hp)
    }
}

public p1_ApplyGravity(p1_id)
{
    if(!is_user_alive(p1_id)) return
    if(p1_IsSuppressed(p1_id))
    {
        set_user_gravity(p1_id, 1.0)
        return
    }
    if(p1_g_Melee[p1_id] != p1_MELEE_HAMMER)
    {
        set_user_gravity(p1_id, 1.0)
        return
    }
    if(p1_g_HammerGravity[p1_id] == 0)
        set_user_gravity(p1_id, p1_HAMMER_GRAVITY_LOW / 800.0)
    else
        set_user_gravity(p1_id, p1_HAMMER_GRAVITY_HIGH / 800.0)
}

public p1_fw_CmdStart(p1_id, uc, seed)
{
    if(!is_user_connected(p1_id))
        return FMRES_IGNORED

    new p1_buttons = get_uc(uc, UC_Buttons)
    g_MechHoldingWalk[p1_id] = (p1_buttons & p1_IN_SPEED) != 0
    if(is_user_alive(p1_id) && Mech_IsStunned(p1_id))
    {
        if(get_gametime() >= g_MechStunUntil[p1_id]) Mech_ClearStun(p1_id)
        else
        {
            set_uc(uc, UC_Buttons, p1_buttons & ~(IN_ATTACK | IN_ATTACK2 | IN_USE))
            set_pev(p1_id, pev_maxspeed, 50.0)
        }
    }
    if(is_user_alive(p1_id) && (p1_buttons & (IN_ATTACK | IN_ATTACK2)))
        g_MechLastAttack[p1_id] = get_gametime()
    new bool:p1_isWalkPress = (p1_buttons & p1_IN_SPEED) && !(p1_g_LastButtons[p1_id] & p1_IN_SPEED)

    if(is_user_alive(p1_id) && !p1_IsSuppressed(p1_id) && get_user_weapon(p1_id) == CSW_KNIFE && p1_g_Melee[p1_id] == p1_MELEE_HAMMER && p1_isWalkPress)
    {
        p1_g_HammerGravity[p1_id] = 1 - p1_g_HammerGravity[p1_id]
        p1_ApplyGravity(p1_id)
        client_print(p1_id, print_center, "Hammer Gravity: %d", p1_g_HammerGravity[p1_id] ? floatround(p1_HAMMER_GRAVITY_HIGH) : floatround(p1_HAMMER_GRAVITY_LOW))
    }

    p1_g_LastButtons[p1_id] = p1_buttons
    return FMRES_IGNORED
}

public p1_fw_PrimaryAttack_Pre(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(!is_user_alive(p1_id) || get_user_weapon(p1_id) != CSW_KNIFE) return HAM_IGNORED
    p1_g_AttackType[p1_id] = 1
    p1_g_SuppressNextHitSound[p1_id] = false
    p6_g_bWaitingHeavyHit[p1_id] = false
    p7_g_bWaitingHeavyHit[p1_id] = false
    p1_g_HitVictim[p1_id] = 0
    p1_g_HitGroup[p1_id] = 0
    return HAM_IGNORED
}

public p1_fw_PrimaryAttack_Post(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(!is_user_alive(p1_id)) return HAM_IGNORED
    new Float:p1_mult = p1_GetAttackMultiplier(p1_id)
    p1_ScaleKnifeAttack(ent, p1_mult, true)
    if(get_user_weapon(p1_id) == CSW_KNIFE)
    {
        // Cycle through both slash and both midslash sequences.
        new logicalAnim
        switch(p1_g_SlashAnimStep[p1_id] % 4)
        {
            case 0: logicalAnim = 1
            case 1: logicalAnim = 2
            case 2: logicalAnim = 6
            default: logicalAnim = 7
        }
        p1_g_SlashAnimStep[p1_id]++
        p1_PlayKnifeAnim(p1_id, logicalAnim)
    }
    return HAM_IGNORED
}

public p1_fw_SecondaryAttack_Pre(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(!is_user_alive(p1_id) || get_user_weapon(p1_id) != CSW_KNIFE) return HAM_IGNORED
    new Float:p1_now = get_gametime()
    if(p1_now < p1_g_NextStab[p1_id]) return HAM_SUPERCEDE
    g_AchRoundLightOnly[p1_id]=0
    // Holding the dedicated +backattack bind + heavy attack triggers a directional backstab.
    if(g_MechBackAttackHeld[p1_id])
    {
        new Float:backRange = Mech_BackstabRange(p1_GetCombatMelee(p1_id))
        if(backRange > 0.0)
        {
            new backTarget = Mech_FindBehindTarget(p1_id, backRange)
            p1_g_AttackType[p1_id] = 2
            p1_g_SuppressNextHitSound[p1_id] = false
            p1_g_HitVictim[p1_id] = backTarget
            p1_g_HitGroup[p1_id] = 2
            // A missed back-attack is a feint: no stab cooldown and no heavy cooldown.
            // Only a confirmed target consumes the weapon's normal stab cooldown.
            if(backTarget)
            {
                new Float:backStabCooldown = p1_STAB_COOLDOWN
                if(p1_GetCombatMelee(p1_id) == p1_MELEE_SAIS) backStabCooldown = p1_SAIS_STAB_COOLDOWN
                p1_g_NextStab[p1_id] = p1_now + backStabCooldown
                p7_g_bWaitingHeavyHit[p1_id] = false
                new bool:wasBackstabParried = p4_g_ParryActive[backTarget]
                new bool:wasBackstabBlocked = p5_g_bBlockActive[backTarget]
                ach_on_backstab(p1_id, backTarget)
                g_MechBackstab[p1_id] = true
                new meleeType = p1_GetCombatMelee(p1_id)
                new Float:base = p1_GetBaseDamage(meleeType, true)
                ExecuteHamB(Ham_TakeDamage, backTarget, p1_id, p1_id, base, DMG_SLASH)
                g_MechBackstab[p1_id] = false
                if(!wasBackstabParried && !wasBackstabBlocked && is_user_alive(backTarget))
                    Mech_ApplyStun(backTarget, p1_id)
            }
            // Use the weapon-specific stab sound on a hit and slash-miss sound on a miss.
            new soundMelee = p1_GetCombatMelee(p1_id)
            new soundSlot = backTarget ? 4 : 2
            if(p1_WeaponSounds[soundMelee][soundSlot][0])
                emit_sound(p1_id, CHAN_WEAPON, p1_WeaponSounds[soundMelee][soundSlot], 1.0, ATTN_NORM, 0, PITCH_NORM)
            if(!backTarget)
                p7_g_bWaitingHeavyHit[p1_id] = false
            p1_PlayKnifeAnim(p1_id, backTarget ? 4 : 5)
            return HAM_SUPERCEDE
        }
    }
    p1_g_AttackType[p1_id] = 2
    p1_g_SuppressNextHitSound[p1_id] = false
    p1_g_HitVictim[p1_id] = 0
    p1_g_HitGroup[p1_id] = 0
    return HAM_IGNORED
}

public p1_fw_SecondaryAttack_Post(ent)
{
    if(!pev_valid(ent)) return HAM_IGNORED
    new p1_id = pev(ent, pev_owner)
    if(!is_user_alive(p1_id)) return HAM_IGNORED
    new Float:p1_mult = p1_GetAttackMultiplier(p1_id)
    p1_ScaleKnifeAttack(ent, p1_mult, false)
    if(get_user_weapon(p1_id) == CSW_KNIFE)
    {
        // TraceAttack runs during the swing: a player hit selects stab,
        // while a wall/empty stab selects the dedicated stab-miss sequence.
        p1_PlayKnifeAnim(p1_id, p1_g_HitVictim[p1_id] > 0 ? 4 : 5)
    }
    return HAM_IGNORED
}

public p1_ScaleKnifeAttack(ent, Float:p1_mult, bool:primary)
{
    new Float:p1_time = get_gametime()
    new Float:p1_next
    new p1_offset = primary ? 46 : 47
    p1_next = get_pdata_float(ent, p1_offset, 4)
    new Float:p1_remaining = p1_next - p1_time
    if(p1_remaining > 0.0)
        set_pdata_float(ent, p1_offset, p1_time + p1_remaining * p1_mult, 4)
    set_pdata_float(ent, 48, p1_time + p1_max_float(0.05, (get_pdata_float(ent, 48, 4) - p1_time) * p1_mult), 4)
}

Float:p1_max_float(Float:p1_a, Float:b)
{
    return p1_a > b ? p1_a : b
}

Float:p1_GetAttackMultiplier(p1_id)
{
    switch(p1_GetCombatMelee(p1_id))
    {
        case p1_MELEE_KATANA: return p1_SPEED_KATANA
        case p1_MELEE_PAN: return p1_SPEED_PAN
        case p1_MELEE_LONGSWORD: return p1_SPEED_LONGSWORD
        case p1_MELEE_HAMMER: return p1_SPEED_HAMMER
        case p1_MELEE_CLAWS: return p1_SPEED_CLAWS
        case p1_MELEE_BAT: return p1_SPEED_BAT
        case p1_MELEE_AXE: return p1_SPEED_AXE
        case p1_MELEE_SAIS: return p1_SPEED_SAIS
        case p1_MELEE_NAGINATA: return p1_SPEED_NAGINATA
        case p1_MELEE_GLADIUS: return p1_SPEED_GLADIUS
        case p1_MELEE_SCYTHE: return p1_SPEED_SCYTHE
        case p1_MELEE_GREATSWORD: return p1_SPEED_GREATSWORD
        case p1_MELEE_GLAIVE: return p1_SPEED_GLAIVE
        case p1_MELEE_GAUNTLETS: return p1_SPEED_GAUNTLETS
        case p1_MELEE_CLEAVER: return p1_SPEED_CLEAVER
    }
    return p1_SPEED_KNIFE
}

public p1_fw_TraceAttack(p1_victim, attacker, Float:damage, Float:direction[3], trace, damagebits)
{
    if(!is_user_alive(attacker) || !is_user_alive(p1_victim)) return HAM_IGNORED
    if(get_user_weapon(attacker) != CSW_KNIFE) return HAM_IGNORED

    // Measure horizontal reach from player origin to the actual trace impact.
    // Eye-to-impact distance includes the vertical view offset and made short-range
    // weapons behave as though they had much longer reach.
    new Float:attackerOrigin[3], Float:hitPosition[3]
    pev(attacker, pev_origin, attackerOrigin)
    get_tr2(trace, TR_EndPos, hitPosition)
    new Float:dx = attackerOrigin[0] - hitPosition[0]
    new Float:dy = attackerOrigin[1] - hitPosition[1]
    new Float:distance = floatsqroot(dx * dx + dy * dy)
    new Float:weaponRange = p1_GetWeaponRange(p1_GetCombatMelee(attacker))
    if(distance > weaponRange)
    {
        p1_g_HitVictim[attacker] = 0
        p1_g_SuppressNextHitSound[attacker] = true
        return HAM_SUPERCEDE
    }

    p1_g_HitVictim[attacker] = p1_victim
    p1_g_HitGroup[attacker] = get_tr2(trace, TR_iHitgroup)
    // Count the light slash when its trace reaches an opponent, even if that
    // opponent successfully parries or blocks the hit.
    if(p1_g_AttackType[attacker]==1 && get_user_team(attacker)!=get_user_team(p1_victim))
        g_AchRoundLightHits[attacker]++
    return HAM_IGNORED
}

Float:p1_GetWeaponRange(p1_melee)
{
    switch(p1_melee)
    {
        case p1_MELEE_KNIFE: return p1_RANGE_KNIFE
        case p1_MELEE_KATANA: return p1_RANGE_KATANA
        case p1_MELEE_PAN: return p1_RANGE_PAN
        case p1_MELEE_LONGSWORD: return p1_RANGE_LONGSWORD
        case p1_MELEE_HAMMER: return p1_RANGE_HAMMER
        case p1_MELEE_CLAWS: return p1_RANGE_CLAWS
        case p1_MELEE_BAT: return p1_RANGE_BAT
        case p1_MELEE_AXE: return p1_RANGE_AXE
        case p1_MELEE_SAIS: return p1_RANGE_SAIS
        case p1_MELEE_NAGINATA: return p1_RANGE_NAGINATA
        case p1_MELEE_GLADIUS: return p1_RANGE_GLADIUS
        case p1_MELEE_SCYTHE: return p1_RANGE_SCYTHE
        case p1_MELEE_GREATSWORD: return p1_RANGE_GREATSWORD
        case p1_MELEE_GLAIVE: return p1_RANGE_GLAIVE
        case p1_MELEE_GAUNTLETS: return p1_RANGE_GAUNTLETS
        case p1_MELEE_CLEAVER: return p1_RANGE_CLEAVER
    }
    return p1_RANGE_KNIFE
}


// Remove the old Necromancer kill-heal behavior. Scythe now uses Phantom Death.
public p1_ScytheCleanup(id)
{
    if(id < 1 || id > 32) return
    remove_task(id + p1_SCYTHE_TASK_CLOAK)
    if(pev_valid(p1_g_ScytheCorpse[id])) remove_entity(p1_g_ScytheCorpse[id])
    p1_g_ScytheCorpse[id] = 0
    if(p1_g_ScytheCloaked[id] && is_user_connected(id))
    {
        if(pev_valid(p1_g_WeaponSprite[id]))
            set_pev(p1_g_WeaponSprite[id], pev_effects, 0)
        set_pev(id, pev_effects, p1_g_ScytheOldEffects[id])
        set_pev(id, pev_rendermode, kRenderNormal)
        set_pev(id, pev_renderamt, 255.0)
        new Float:renderColor[3]
        renderColor[0] = 255.0; renderColor[1] = 255.0; renderColor[2] = 255.0
        set_pev(id, pev_rendercolor, renderColor)
        p1_ScytheScreenFade(id, false)
    }
    p1_g_ScytheCloaked[id] = false
}

stock p1_ScytheScreenFade(id, bool:enable)
{
    if(!is_user_connected(id) || !p1_g_msgScreenFade) return

    message_begin(MSG_ONE, p1_g_msgScreenFade, _, id)
    if(enable)
    {
        // Fade gently into a subtle violet overlay, then keep it until uncloak.
        write_short(1 << 10)
        write_short(5 * (1 << 12))
        write_short(0x0001 | 0x0004) // FFADE_OUT | FFADE_STAYOUT
        write_byte(105)
        write_byte(55)
        write_byte(155)
        write_byte(24)
    }
    else
    {
        // Fade the violet tint away instead of removing it abruptly.
        write_short(1 << 11)
        write_short(0)
        write_short(0x0000) // FFADE_IN
        write_byte(105)
        write_byte(55)
        write_byte(155)
        write_byte(24)
    }
    message_end()
}

public p1_ScytheUncloak(id)
{
    if(id < 1 || id > 32) return
    if(!p1_g_ScytheCloaked[id]) return
    p1_ScytheCleanup(id)
}

public p1_ScytheCloakExpired(taskid)
{
    new id = taskid - p1_SCYTHE_TASK_CLOAK
    if(id < 1 || id > 32 || !is_user_alive(id))
    {
        p1_ScytheCleanup(id)
        return
    }
    p1_ScytheUncloak(id)
}

stock p1_ScytheCreateCorpse(id)
{
    new modelName[32], modelPath[96]
    get_user_info(id, "model", modelName, charsmax(modelName))
    if(!modelName[0]) return 0
    formatex(modelPath, charsmax(modelPath), "models/player/%s/%s.mdl", modelName, modelName)

    new corpse = create_entity("info_target")
    if(!corpse) return 0
    entity_set_model(corpse, modelPath)
    new Float:origin[3], Float:angles[3], Float:mins[3], Float:maxs[3]
    pev(id, pev_origin, origin)
    pev(id, pev_angles, angles)
    pev(id, pev_mins, mins)
    pev(id, pev_maxs, maxs)
    set_pev(corpse, pev_angles, angles)
    set_pev(corpse, pev_mins, mins)
    set_pev(corpse, pev_maxs, maxs)
    // A visible tossable body gives the fake death a physical fall instead of
    // leaving a frozen standing duplicate at the player's feet.
    origin[2] += 8.0
    entity_set_origin(corpse, origin)
    set_pev(corpse, pev_movetype, MOVETYPE_TOSS)
    set_pev(corpse, pev_solid, SOLID_BBOX)
    set_pev(corpse, pev_gravity, 1.0)
    new Float:bodyVelocity[3]
    pev(id, pev_velocity, bodyVelocity)
    bodyVelocity[2] = 35.0
    set_pev(corpse, pev_velocity, bodyVelocity)
    set_pev(corpse, pev_sequence, (random_num(0, 1) == 0) ? 105 : 109) // Soul Reap fake-death sequence
    set_pev(corpse, pev_gaitsequence, 0)
    set_pev(corpse, pev_framerate, 1.0)
    set_pev(corpse, pev_frame, 0.0)
    set_pev(corpse, pev_animtime, get_gametime())
    set_pev(corpse, pev_owner, id)
    return corpse
}

stock p1_ScytheFakeDeath(id, attacker)
{
    ach_add(id,67,1);
    if(!is_user_alive(id) || p1_g_ScytheCloaked[id]) return

    p1_g_ScytheCorpse[id] = p1_ScytheCreateCorpse(id)
    p1_g_ScytheCloaked[id] = true
    // Keep the five-hit charge permanently armed after the first charge.
    // Subsequent fake deaths can proc again without another five-hit requirement.

    // Hide the real player entity explicitly. Render alpha alone is not
    // consistently respected for player entities by all GoldSrc clients.
    pev(id, pev_effects, p1_g_ScytheOldEffects[id])
    set_pev(id, pev_effects, p1_g_ScytheOldEffects[id] | EF_NODRAW)
    set_pev(id, pev_rendermode, kRenderTransAlpha)
    set_pev(id, pev_renderamt, 0.0)
    if(pev_valid(p1_g_WeaponSprite[id]))
        set_pev(p1_g_WeaponSprite[id], pev_effects, EF_NODRAW)
    p1_ScytheScreenFade(id, true)

    // DeathMsg is deliberately cosmetic only: no real death, score, or stats
    // are generated because the player entity never enters the death state.
    message_begin(MSG_ALL, get_user_msgid("DeathMsg"))
    write_byte(attacker)
    write_byte(id)
    write_byte(0)
    write_string("knife")
    message_end()

    emit_sound(id, CHAN_VOICE, "player/die1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
    remove_task(id + p1_SCYTHE_TASK_CLOAK)
    set_task(p1_SCYTHE_CLOAK_TIME, "p1_ScytheCloakExpired", id + p1_SCYTHE_TASK_CLOAK)
}

public p1_fw_TakeDamage(p1_victim, inflictor, attacker, Float:damage, damagebits)
{
    // Any real player hit breaks Soul Reap immediately, including ranged hits
    // and synthetic player-caused melee/kick damage. Environmental damage does not.
    if(p1_victim >= 1 && p1_victim <= 32 && p1_g_ScytheCloaked[p1_victim] &&
        attacker >= 1 && attacker <= 32 && attacker != p1_victim &&
        is_user_connected(attacker) && damage > 0.0)
        p1_ScytheUncloak(p1_victim)

    // Break cloak as soon as this player lands any damaging hit. This must
    // run before the non-knife and synthetic-damage early returns below.
    if(attacker >= 1 && attacker <= 32 && p1_g_ScytheCloaked[attacker] &&
        p1_victim >= 1 && p1_victim <= 32 && attacker != p1_victim &&
        is_user_connected(p1_victim) && damage > 0.0 &&
        get_user_team(attacker) != get_user_team(p1_victim))
    {
        ach_add(attacker,68,1)
        p1_ScytheUncloak(attacker)
    }

    if(p1_victim >= 1 && p1_victim <= 32 && damage > 0.0)
    {
        g_MechLastDamage[p1_victim] = get_gametime()
        g_MechWasStunnedOnHit[p1_victim] = (Mech_IsStunned(p1_victim) || p4_g_Stunned[p1_victim])
    }
    if(!is_user_alive(p1_victim)) return HAM_IGNORED
    if(!is_user_alive(attacker) || p1_victim == attacker)
    {
        if(damage > 0.0 && Mech_IsStunned(p1_victim)) Mech_ClearStun(p1_victim)
        return HAM_IGNORED
    }

    new bool:targetWasStunned = g_MechWasStunnedOnHit[p1_victim]
    // Preserve the stun source before Mech_ClearStun resets its live state.
    new stunOwnerAtHit = g_AchStunOwner[p1_victim]
    g_MechWasStunnedOnHit[p1_victim] = false
    if(targetWasStunned)
    {
        g_AchStunnedHitBy[p1_victim] = attacker

        // Team Work: only a real knife heavy/stab hit counts. Kicks, bombs,
        // parry counters and other synthetic damage must never unlock it.
        if(get_user_weapon(attacker) == CSW_KNIFE && p1_g_AttackType[attacker] == 2 &&
            !(damagebits & (p1_DMG_CUSTOM_MELEE | p1_DMG_PARRY_COUNTER)) &&
            g_AchStunOwner[p1_victim] > 0 && g_AchStunOwner[p1_victim] != attacker &&
            is_user_connected(g_AchStunOwner[p1_victim]) &&
            get_user_team(g_AchStunOwner[p1_victim]) == get_user_team(attacker))
            ach_set(attacker,65)

    }

    // Clash: two opposing attack inputs within 100ms cancel into a spark and separation.
    if(damage > 0.0 && get_user_weapon(attacker) == CSW_KNIFE && get_user_weapon(p1_victim) == CSW_KNIFE &&
        get_user_team(attacker) != get_user_team(p1_victim) &&
        get_gametime() - g_MechLastAttack[p1_victim] <= MECH_CLASH_WINDOW &&
        get_gametime() - g_MechLastAttack[attacker] <= MECH_CLASH_WINDOW &&
        get_gametime() >= g_MechClashFxUntil[attacker] && get_gametime() >= g_MechClashFxUntil[p1_victim])
    {
        new Float:ao[3], Float:vo[3], Float:sep[3]
        pev(attacker, pev_origin, ao); pev(p1_victim, pev_origin, vo)
        sep[0] = vo[0]-ao[0]; sep[1] = vo[1]-ao[1]; sep[2] = 0.0
        new Float:length = floatsqroot(sep[0]*sep[0] + sep[1]*sep[1])
        if(length > 0.1)
        {
            sep[0] = sep[0] / length * 90.0
            sep[1] = sep[1] / length * 90.0
        }
        sep[2] = 20.0
        new Float:attackerSep[3]
        attackerSep[0] = -sep[0]; attackerSep[1] = -sep[1]; attackerSep[2] = 20.0
        set_pev(attacker, pev_velocity, attackerSep)
        set_pev(p1_victim, pev_velocity, sep)
        g_MechClashFxUntil[attacker] = get_gametime() + 0.18
        g_MechClashFxUntil[p1_victim] = get_gametime() + 0.18
        new Float:sparkOrigin[3]
        sparkOrigin[0] = (ao[0] + vo[0]) * 0.5
        sparkOrigin[1] = (ao[1] + vo[1]) * 0.5
        sparkOrigin[2] = (ao[2] + vo[2]) * 0.5 + 24.0
        Mech_Spark(sparkOrigin)
        emit_sound(attacker, CHAN_ITEM, "weapons/knife_arena/axe_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        // Deliberately continue: a clash must not cancel either valid stab.
    }

    // A normal successful parry prevents all damage-side weapon effects.
    // Greatsword gets one 25% roll here so a bypassed hit still receives all
    // normal damage modifiers before the later parry hook plays its feedback.
    if(p4_g_ParryActive[p1_victim])
    {
        if(get_user_weapon(attacker) == CSW_KNIFE && p1_g_Melee[attacker] == p1_MELEE_GREATSWORD &&
            !p1_IsSuppressed(attacker) && !(damagebits & (p1_DMG_PARRY_COUNTER | p1_DMG_CUSTOM_MELEE)) &&
            random_num(1, 100) <= p1_GREATSWORD_PARRY_CHANCE)
            p4_g_bGreatswordBypass[p1_victim] = true
        else
            return HAM_IGNORED
    }

    // Glaive shockwave is a zero-damage synthetic attack. It still reaches
    // the parry hook, but must never trigger ordinary damage-side effects.
    if(p1_g_ShockwaveVictim[p1_victim])
    {
        SetHamParamFloat(4, 0.0)
        return HAM_IGNORED
    }

    // A real hit breaks stun, but a parried/zeroed hit does not.
    if(damage > 0.0 && targetWasStunned) Mech_ClearStun(p1_victim)

    // Count valid enemy damage events of any type toward the next charge.
    // Environmental and plugin-generated damage do not count as received hits.
    if(p1_g_Melee[p1_victim] == p1_MELEE_SCYTHE && !p1_g_ScytheCloaked[p1_victim] &&
        get_user_team(attacker) != get_user_team(p1_victim) && damage > 0.0 &&
        !p5_g_bBlockActive[p1_victim] &&
        !(damagebits & (DMG_FALL | DMG_DROWN | DMG_BURN | p1_DMG_CUSTOM_MELEE | p1_DMG_PARRY_COUNTER)))
    {
        if(p1_g_ScytheHits[p1_victim] < p1_SCYTHE_CHARGE_HITS)
            p1_g_ScytheHits[p1_victim]++
    }

    // Cleaver's conditional vulnerability and Longsword vulnerability also
    // affect non-knife damage sources. The two +15% effects stack additively.
    if(get_user_weapon(attacker) != CSW_KNIFE)
    {
        new Float:externalBonus = 0.0
        if(p1_g_Vulnerable[p1_victim]) externalBonus += p1_VULN_MULTIPLIER - 1.0
        if(p1_g_Melee[p1_victim] == p1_MELEE_CLEAVER && p1_CleaverHasLowOpponent(p1_victim)) externalBonus += p1_CLEAVER_VULN_BONUS
        if(externalBonus > 0.0) SetHamParamFloat(4, damage * (1.0 + externalBonus))
        return HAM_IGNORED
    }

    // Hammer's Minecraft-mace landing protection: only negate fall damage
    // shortly after a hammer user connects with an enemy while airborne.
    if((damagebits & DMG_FALL) && p1_g_HammerAirHit[p1_victim] && get_gametime() <= p1_g_MaceLandUntil[p1_victim])
    {
        SetHamParamFloat(4, 0.0)
        p1_g_HammerAirHit[p1_victim] = false
        return HAM_SUPERCEDE
    }

    // Plugin-generated kick/bomb damage must not be rewritten as knife damage
    // or recursively trigger the claws bomb planting logic.
    if(damagebits & p1_DMG_CUSTOM_MELEE)
        return HAM_IGNORED

    // Synthetic counter-hit from parry.sma's pan parry - let it through
    // with the raw damage parry.sma already set, don't recompute it.
    if(damagebits & p1_DMG_PARRY_COUNTER)
        return HAM_IGNORED

    new p1_melee = p1_GetCombatMelee(attacker)
    new bool:p1_stab = (p1_g_AttackType[attacker] == 2)

    new Float:p1_base = p1_GetBaseDamage(p1_melee, p1_stab)
    new Float:p1_finalDamage = p1_base
    new Float:p1_damageBonus = 0.0

    // Longsword vulnerability: +15% for four seconds.
    if(p1_g_Vulnerable[p1_victim]) p1_damageBonus += p1_VULN_MULTIPLIER - 1.0

    // Cleaver drawback: +15% incoming damage while any alive opponent is
    // at or below 80 HP. This stacks with Longsword vulnerability.
    if(p1_g_Melee[p1_victim] == p1_MELEE_CLEAVER && p1_CleaverHasLowOpponent(p1_victim))
        p1_damageBonus += p1_CLEAVER_VULN_BONUS

    // Glaive Berserk's +20% outgoing damage stacks additively with the
    // target's vulnerability effects (15 + 15 + 20 = 50%).
    if(p1_melee == p1_MELEE_GLAIVE && !p1_IsSuppressed(attacker) && p1_g_GlaiveBerserk[attacker] && get_user_health(attacker) <= p1_GLAIVE_BERSERK_HP)
        p1_damageBonus += p1_GLAIVE_DAMAGE_BONUS

    p1_finalDamage *= (1.0 + p1_damageBonus)

    new p1_hitgroup = p1_g_HitGroup[attacker]
    new bool:p1_head = (p1_hitgroup == p1_HITGROUP_HEAD)
    new bool:p1_targetStunned = targetWasStunned
    new bool:p1_back = p1_targetStunned ? false : p1_IsBackHit(p1_victim, attacker)
    if(p1_targetStunned) p1_head = false

    if(p1_head && p1_back)
        p1_finalDamage *= 7.0
    else if(p1_back)
        p1_finalDamage *= 4.0
    else if(p1_head)
        p1_finalDamage *= 3.0

    // Hammer's falling-damage bonus applies ONLY to a stab (secondary attack).
    // Slash hits and other damage events must never receive this bonus.
    if(p1_melee == p1_MELEE_HAMMER && p1_stab && !p1_IsSuppressed(attacker))
    {
        new Float:p1_velocity[3]
        pev(attacker, pev_velocity, p1_velocity)

        new Float:p1_fallSpeed = 0.0 - p1_velocity[2]
        if(p1_fallSpeed > p1_HAMMER_FALL_MIN_SPEED)
        {
            new Float:p1_steps = (p1_fallSpeed - p1_HAMMER_FALL_MIN_SPEED) / p1_HAMMER_FALL_BONUS_STEP
            new Float:p1_bonus = p1_steps * p1_HAMMER_FALL_PER_STEP

            if(p1_bonus > p1_HAMMER_FALL_MAX_BONUS)
                p1_bonus = p1_HAMMER_FALL_MAX_BONUS

            if(p1_bonus > 0.0)
            {
                // Count an actual gravity-boosted heavy hit, not a setting toggle.
                ach_add(attacker,54,1)
                // Teammate's back-attack must have caused the stun, and the
                // Hammer hit must receive the real falling-speed damage bonus.
                if(targetWasStunned && g_AchBackstabOwner[p1_victim] > 0 &&
                    stunOwnerAtHit == g_AchBackstabOwner[p1_victim] &&
                    g_AchBackstabOwner[p1_victim] != attacker &&
                    is_user_connected(g_AchBackstabOwner[p1_victim]) &&
                    get_user_team(g_AchBackstabOwner[p1_victim]) == get_user_team(attacker))
                    ach_set(attacker,72)
            }
            p1_finalDamage *= (1.0 + p1_bonus)
        }
    }

    // Cleaver execution: a stab instantly executes a target at <=80 HP.
    // Parry is still handled later by the normal parry hook; block bypass is
    // handled by the block hook's explicit execution exception.
    new bool:cleaverExecution = (p1_melee == p1_MELEE_CLEAVER && p1_stab &&
        get_user_health(p1_victim) <= p1_CLEAVER_EXECUTE_HP && !p1_IsSuppressed(attacker))
    if(cleaverExecution)
    {
        p1_finalDamage = float(get_user_health(p1_victim) + 1)
        SetHamParamInteger(5, damagebits | p1_CLEAVER_EXECUTE_FLAG)
    }

    // Gauntlets: restore armor to the attacker on successful hits.
    if(p1_melee == p1_MELEE_GAUNTLETS &&
        attacker != p1_victim &&
        get_user_team(attacker) != get_user_team(p1_victim) &&
        !p1_IsSuppressed(attacker) &&
        !p5_g_bBlockActive[p1_victim] &&
        damage > 0.0)
    {
        new armorGain = p1_stab ? p1_GAUNTLETS_HEAVY_AP : p1_GAUNTLETS_LIGHT_AP
        new oldArmor = get_user_armor(attacker)
        new currentArmor = oldArmor + armorGain
        if(currentArmor > p1_MAX_ARMOR) currentArmor = p1_MAX_ARMOR
        cs_set_user_armor(attacker, currentArmor, CS_ARMOR_VESTHELM)
        if(currentArmor > oldArmor)
            ach_track_ap_gain(attacker,currentArmor-oldArmor,false)
    }
    SetHamParamFloat(4, p1_finalDamage)

    // Sais Thorns: only a real, damaging stab triggers retaliation.
    // A parry was already rejected above; active blocks must not trigger it.
    if(p1_stab && p1_g_Melee[p1_victim] == p1_MELEE_SAIS &&
        p1_GetCombatMelee(p1_victim) == p1_MELEE_SAIS &&
        !p1_IsSuppressed(p1_victim) && !p5_g_bBlockActive[p1_victim] && p1_finalDamage > 0.0)
    {
        p1_StartThorns(attacker, p1_victim, p1_finalDamage * p1_THORNS_DAMAGE_MULT)
    }

    // Gladius Armor Steal is processed in the final damage hook, after
    // parry/block handling, so a parried or blocked stab cannot steal armor.

    // Naginata Suppression: the victim uses default-knife combat rules for 3s.
    // The selected weapon/model/sounds/sprite are left untouched.
    if(p1_melee == p1_MELEE_NAGINATA && p1_stab && !p1_IsSuppressed(attacker))
    {
        p1_g_SuppressedUntil[p1_victim] = get_gametime() + 3.0
        p1_ApplyGravity(p1_victim)
        p1_StopRegen(p1_victim)
        remove_task(p1_victim + 14000)
        set_task(0.1, "p1_SuppressionHUD", p1_victim + 14000, _, _, "b")
        p7_UpdatePlayerGlow(p1_victim)
    }

    if(p1_melee == p1_MELEE_HAMMER)
    {
        new Float:groundCheck[3]
        pev(attacker, pev_velocity, groundCheck)
        if(!(pev(attacker, pev_flags) & FL_ONGROUND) && groundCheck[2] < 0.0)
        {
            p1_g_HammerAirHit[attacker] = true
            p1_g_MaceLandUntil[attacker] = get_gametime() + p1_HAMMER_MACE_LAND_WINDOW
        }
    }

    if(p1_stab)
    {
        new Float:p1_cooldown = p1_STAB_COOLDOWN
        if(p1_melee == p1_MELEE_CLAWS)
            p1_cooldown = p1_CLAWS_STAB_COOLDOWN
        else if(p1_melee == p1_MELEE_GAUNTLETS)
            p1_cooldown = p1_GAUNTLETS_STAB_COOLDOWN
        else if(p1_melee == p1_MELEE_SAIS)
            p1_cooldown = p1_SAIS_STAB_COOLDOWN
        p1_g_NextStab[attacker] = get_gametime() + p1_cooldown

        if(p1_melee == p1_MELEE_LONGSWORD && !p1_IsSuppressed(attacker))
        {
            if(p1_g_Vulnerable[p1_victim])
                ach_set(attacker,69)
            if(get_user_team(attacker)==get_user_team(p1_victim))
                g_AchVulnerabilityOwner[p1_victim]=attacker
            p1_StartVulnerability(p1_victim)
        }

        if(p1_melee == p1_MELEE_CLAWS && !p1_IsSuppressed(attacker) && random_num(1, 100) <= p1_MICRO_CHANCE && !p1_g_MicroBomb[p1_victim])
            p1_PlantMicroBomb(p1_victim, attacker)

        if(p1_melee == p1_MELEE_AXE && !p1_IsSuppressed(attacker))
            p1_AxeHeal(attacker, p1_finalDamage)

        if(p1_melee == p1_MELEE_BAT && !p1_IsSuppressed(attacker))
            p1_ApplyBatKnockback(attacker, p1_victim, p1_BAT_STAB_KB, p1_BAT_STAB_UP)
    }
    else if(p1_melee == p1_MELEE_BAT && !p1_IsSuppressed(attacker))
    {
        p1_ApplyBatKnockback(attacker, p1_victim, p1_BAT_SLASH_KB, 25.0)
    }

    return HAM_IGNORED
}

Float:p1_GetBaseDamage(p1_melee, bool:p1_stab)
{
    switch(p1_melee)
    {
        case p1_MELEE_KNIFE: return p1_stab ? p1_DAMAGE_KNIFE_STAB : p1_DAMAGE_KNIFE_SLASH
        case p1_MELEE_KATANA: return p1_stab ? p1_DAMAGE_KATANA_STAB : p1_DAMAGE_KATANA_SLASH
        case p1_MELEE_PAN: return p1_stab ? p1_DAMAGE_PAN_STAB : p1_DAMAGE_PAN_SLASH
        case p1_MELEE_LONGSWORD: return p1_stab ? p1_DAMAGE_LONGSWORD_STAB : p1_DAMAGE_LONGSWORD_SLASH
        case p1_MELEE_HAMMER: return p1_stab ? p1_DAMAGE_HAMMER_STAB : p1_DAMAGE_HAMMER_SLASH
        case p1_MELEE_CLAWS: return p1_stab ? p1_DAMAGE_CLAWS_STAB : p1_DAMAGE_CLAWS_SLASH
        case p1_MELEE_BAT: return p1_stab ? p1_DAMAGE_BAT_STAB : p1_DAMAGE_BAT_SLASH
        case p1_MELEE_AXE: return p1_stab ? p1_DAMAGE_AXE_STAB : p1_DAMAGE_AXE_SLASH
        case p1_MELEE_SAIS: return p1_stab ? p1_DAMAGE_SAIS_STAB : p1_DAMAGE_SAIS_SLASH
        case p1_MELEE_NAGINATA: return p1_stab ? p1_DAMAGE_NAGINATA_STAB : p1_DAMAGE_NAGINATA_SLASH
        case p1_MELEE_GLADIUS: return p1_stab ? p1_DAMAGE_GLADIUS_STAB : p1_DAMAGE_GLADIUS_SLASH
        case p1_MELEE_SCYTHE: return p1_stab ? p1_DAMAGE_SCYTHE_STAB : p1_DAMAGE_SCYTHE_SLASH
        case p1_MELEE_GREATSWORD: return p1_stab ? p1_DAMAGE_GREATSWORD_STAB : p1_DAMAGE_GREATSWORD_SLASH
        case p1_MELEE_GLAIVE: return p1_stab ? p1_DAMAGE_GLAIVE_STAB : p1_DAMAGE_GLAIVE_SLASH
        case p1_MELEE_GAUNTLETS: return p1_stab ? p1_DAMAGE_GAUNTLETS_STAB : p1_DAMAGE_GAUNTLETS_SLASH
        case p1_MELEE_CLEAVER: return p1_stab ? p1_DAMAGE_CLEAVER_STAB : p1_DAMAGE_CLEAVER_SLASH
    }
    return p1_stab ? 65.0 : 15.0
}

bool:p1_IsBackHit(p1_victim, attacker)
{
    new Float:p1_vangles[3], Float:vorigin[3], Float:aorigin[3]
    pev(p1_victim, pev_angles, p1_vangles)
    pev(p1_victim, pev_origin, vorigin)
    pev(attacker, pev_origin, aorigin)

    new Float:p1_fwd[3]
    angle_vector(p1_vangles, ANGLEVECTOR_FORWARD, p1_fwd)

    new Float:p1_toAttacker[3]
    p1_toAttacker[0] = aorigin[0] - vorigin[0]
    p1_toAttacker[1] = aorigin[1] - vorigin[1]
    p1_toAttacker[2] = 0.0

    new Float:p1_len = floatsqroot(p1_toAttacker[0]*p1_toAttacker[0] + p1_toAttacker[1]*p1_toAttacker[1])
    if(p1_len <= 0.0) return false

    p1_toAttacker[0] /= p1_len
    p1_toAttacker[1] /= p1_len

    new Float:p1_dot = p1_fwd[0] * p1_toAttacker[0] + p1_fwd[1] * p1_toAttacker[1]
    if(p1_dot < -0.35)
        return true

    return false
}

public p1_StartVulnerability(p1_victim)
{
    p1_g_Vulnerable[p1_victim] = true
    remove_task(p1_victim + 2000)
    set_task(p1_VULN_DURATION, "p1_RemoveVulnerability", p1_victim + 2000)
    p1_UpdateGlow(p1_victim)
}

public p1_RemoveVulnerability(taskid)
{
    new p1_id = taskid - 2000
    if(!is_user_connected(p1_id)) return
    p1_g_Vulnerable[p1_id] = false
    p1_UpdateGlow(p1_id)
}

// Start/refresh a Sais Thorns countdown on the player who stabbed the Sais user.
// The effect stores half of the original stab's final damage.
public p1_StartThorns(p1_target, p1_source, Float:p1_damage)
{
    if(!is_user_alive(p1_target) || !is_user_alive(p1_source) || p1_damage <= 0.0)
        return

    p1_g_ThornsSource[p1_target] = p1_source
    p1_g_ThornsDamage[p1_target] = p1_damage
    p1_g_ThornsEndTime[p1_target] = get_gametime() + p1_THORNS_DELAY

    remove_task(p1_target + 12000)
    remove_task(p1_target + 13000)
    set_task(p1_THORNS_DELAY, "p1_ThornsRetaliate", p1_target + 12000)
    set_task(0.1, "p1_ThornsHUD", p1_target + 13000, _, _, "b")
    p7_UpdatePlayerGlow(p1_target)
}

public p1_ThornsHUD(taskid)
{
    new p1_target = taskid - 13000
    if(!is_user_alive(p1_target) || p1_g_ThornsEndTime[p1_target] <= 0.0)
    {
        remove_task(taskid)
        return
    }

    new Float:p1_remaining = p1_g_ThornsEndTime[p1_target] - get_gametime()
    if(p1_remaining <= 0.0)
    {
        show_hudmessage(p1_target, " ")
        remove_task(taskid)
        return
    }

    set_hudmessage(p1_THORNS_HUD_R, p1_THORNS_HUD_G, p1_THORNS_HUD_B,
        -1.0, 0.43, 0, 0.0, 0.12, 0.0, 0.0, 6)
    show_hudmessage(p1_target, "THORNS %.1f", p1_remaining)
}

public p1_ThornsRetaliate(taskid)
{
    new p1_target = taskid - 12000
    remove_task(p1_target + 13000)

    if(!is_user_alive(p1_target))
    {
        p1_g_ThornsSource[p1_target] = 0
        p1_g_ThornsDamage[p1_target] = 0.0
        p1_g_ThornsEndTime[p1_target] = 0.0
        return
    }

    new p1_source = p1_g_ThornsSource[p1_target]
    if(p1_source>=1 && p1_source<=32) g_AchRoundLightOnly[p1_source]=0
    g_AchThornsKiller[p1_target] = p1_source
    new Float:p1_damage = p1_g_ThornsDamage[p1_target]
    p1_g_ThornsSource[p1_target] = 0
    p1_g_ThornsDamage[p1_target] = 0.0
    p1_g_ThornsEndTime[p1_target] = 0.0
    show_hudmessage(p1_target, " ")
    p7_UpdatePlayerGlow(p1_target)

    // Keep the retaliation parriable/blockable through the normal damage hooks.
    // Cancel if the Sais owner is no longer alive, since the parry hook requires
    // a live melee attacker. The custom flag prevents weapon effects recursing.
    if(!is_user_alive(p1_source) || p1_damage <= 0.0)
        return

    emit_sound(p1_target, CHAN_WEAPON, p1_WeaponSounds[p1_MELEE_SAIS][4],
        1.0, ATTN_NORM, 0, PITCH_NORM)
    ExecuteHamB(Ham_TakeDamage, p1_target, p1_source, p1_source,
        p1_damage, DMG_CLUB | p1_DMG_CUSTOM_MELEE)
}

public p1_SuppressionHUD(taskid)
{
    new p1_id = taskid - 14000
    if(!is_user_alive(p1_id))
    {
        remove_task(taskid)
        return
    }

    new Float:p1_remaining = p1_g_SuppressedUntil[p1_id] - get_gametime()
    if(p1_remaining <= 0.0)
    {
        show_hudmessage(p1_id, " ")
        remove_task(taskid)
        p7_UpdatePlayerGlow(p1_id)
        return
    }

    set_hudmessage(p1_SUPPRESS_HUD_R, p1_SUPPRESS_HUD_G, p1_SUPPRESS_HUD_B,
        -1.0, 0.50, 0, 0.0, 0.12, 0.0, 0.0, 5)
    show_hudmessage(p1_id, "SUPPRESSED %.1f", p1_remaining)
}

public p1_PlantMicroBomb(p1_victim, owner)
{
    if(owner>=1 && owner<=32) g_AchRoundLightOnly[owner]=0
    if(owner>=1 && owner<=32 && p1_victim>=1 && p1_victim<=32 && get_user_team(owner)==get_user_team(p1_victim))
    {
        g_AchSameTeammateBomb[owner][p1_victim]++;
        if(g_AchSameTeammateBomb[owner][p1_victim]>g_AchProgress[owner][71])
        {
            g_AchProgress[owner][71]=g_AchSameTeammateBomb[owner][p1_victim];
            ach_save(owner);
        }
        if(g_AchSameTeammateBomb[owner][p1_victim]>=10) ach_set(owner,71);
    }
    p1_g_MicroBomb[p1_victim] = true
    p1_g_MicroBombOwner[p1_victim] = owner
    p1_g_BombEndTime[p1_victim] = get_gametime() + p1_MICRO_DELAY
    p1_UpdateGlow(p1_victim)
    remove_task(p1_victim + 3000)
    remove_task(p1_victim + 6000)
    set_task(0.1, "p1_BombHUD", p1_victim + 6000, _, _, "b")
    set_task(p1_MICRO_DELAY, "p1_MicroBombExplode", p1_victim + 3000)
}

public p1_BombHUD(taskid)
{
    new p1_id = taskid - 6000
    if(!is_user_alive(p1_id) || !p1_g_MicroBomb[p1_id])
    {
        remove_task(taskid)
        return
    }

    new Float:p1_explodeAt = p1_g_BombEndTime[p1_id] - get_gametime()
    if(p1_explodeAt < 0.0) p1_explodeAt = 0.0

    set_hudmessage(255, 0, 0, -1.0, 0.43, 0, 0.0, 0.12, 0.0, 0.0, 7)
    show_hudmessage(p1_id, "BOMB %.1f", p1_explodeAt)
}

public p1_MicroBombExplode(taskid)
{
    new p1_victim = taskid - 3000
    remove_task(p1_victim + 6000)

    if(!is_user_alive(p1_victim) || !p1_g_MicroBomb[p1_victim]) return

    new p1_bombOwner = p1_g_MicroBombOwner[p1_victim]
    g_AchBombKiller[p1_victim] = p1_bombOwner
    p1_g_MicroBomb[p1_victim] = false
    p1_g_MicroBombOwner[p1_victim] = 0
    p1_g_BombEndTime[p1_victim] = 0.0
    p1_UpdateGlow(p1_victim)

    emit_sound(p1_victim, CHAN_AUTO, "weapons/sg_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

    // The planted claws bomb deals real damage when it detonates.
    // Use DMG_CLUB so it is treated as melee-type damage by damage hooks.
    new p1_damageAttacker = is_user_connected(p1_bombOwner) ? p1_bombOwner : p1_victim
    if(p1_damageAttacker != p1_victim)
        ExecuteHamB(Ham_TakeDamage, p1_victim, p1_victim, p1_damageAttacker, p1_MICRO_BOMB_DAMAGE, DMG_CLUB | p1_DMG_CUSTOM_MELEE)
    else
        ExecuteHamB(Ham_TakeDamage, p1_victim, p1_victim, p1_victim, p1_MICRO_BOMB_DAMAGE, DMG_CLUB | p1_DMG_CUSTOM_MELEE)

    new Float:p1_vel[3]
    pev(p1_victim, pev_velocity, p1_vel)
    p1_vel[2] += p1_MICRO_BOMB_LAUNCH_VEL
    set_pev(p1_victim, pev_velocity, p1_vel)

    p1_g_MicroStunned[p1_victim] = true
    set_pev(p1_victim, pev_maxspeed, 80.0)
    set_pev(p1_victim, pev_button, 0)
    remove_task(p1_victim + 4000)
    set_task(p1_MICRO_STUN, "p1_RemoveMicroStun", p1_victim + 4000)
}

public p1_RemoveMicroStun(taskid)
{
    new p1_id = taskid - 4000
    if(!is_user_alive(p1_id)) return
    p1_g_MicroStunned[p1_id] = false
    set_pev(p1_id, pev_maxspeed, 250.0)
    p1_ApplyMelee(p1_id)
}

public p1_UpdateGlow(p1_id)
{
    if(!is_user_connected(p1_id)) return
    p7_UpdatePlayerGlow(p1_id)
}



stock bool:p1_CleaverHasLowOpponent(p1_id)
{
    if(!is_user_alive(p1_id)) return false
    new myTeam = get_user_team(p1_id)
    for(new target = 1; target <= 32; target++)
    {
        if(target == p1_id || !is_user_alive(target)) continue
        if(get_user_team(target) == myTeam) continue
        if(get_user_health(target) <= p1_CLEAVER_EXECUTE_HP) return true
    }
    return false
}

stock bool:p1_AnyAliveCleaverWielder()
{
    for(new id = 1; id <= 32; id++)
    {
        if(is_user_alive(id) && p1_g_Melee[id] == p1_MELEE_CLEAVER && get_user_weapon(id) == CSW_KNIFE)
            return true
    }
    return false
}

public p1_UpdateAllAbilityGlows(taskid)
{
    for(new id = 1; id <= 32; id++)
    {
        if(is_user_alive(id))
            p7_UpdatePlayerGlow(id)
    }
}

public p1_GlaiveShockwave(taskid)
{
    new owner = taskid - 15000
    if(!is_user_alive(owner) || p1_IsSuppressed(owner) || p1_g_Melee[owner] != p1_MELEE_GLAIVE ||
        !p1_g_GlaiveBerserk[owner] || get_user_health(owner) > p1_GLAIVE_BERSERK_HP)
        return

    new Float:origin[3]
    pev(owner, pev_origin, origin)

    // Built-in temp entities provide a blue pulse without custom resources.
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_DLIGHT)
    write_coord(floatround(origin[0]))
    write_coord(floatround(origin[1]))
    write_coord(floatround(origin[2] + 12.0))
    write_byte(18)
    write_byte(70)
    write_byte(190)
    write_byte(255)
    write_byte(8)
    write_byte(4)
    message_end()

    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_SPARKS)
    write_coord(floatround(origin[0]))
    write_coord(floatround(origin[1]))
    write_coord(floatround(origin[2] + 8.0))
    message_end()

    new Float:radiusSq = p1_GLAIVE_SHOCKWAVE_RADIUS * p1_GLAIVE_SHOCKWAVE_RADIUS

    for(new target = 1; target <= 32; target++)
    {
        if(target == owner || !is_user_alive(target)) continue
        new Float:targetOrigin[3]
        pev(target, pev_origin, targetOrigin)
        new Float:dx = targetOrigin[0] - origin[0]
        new Float:dy = targetOrigin[1] - origin[1]
        new Float:dz = targetOrigin[2] - origin[2]
        if(dx*dx + dy*dy + dz*dz > radiusSq) continue

        // Send a synthetic zero-damage melee hit through the normal parry
        // hook. Each target is processed independently; a parry only saves
        // that target from knockback, not anyone else in the radius.
        new bool:wasParrying = p4_g_ParryActive[target]
        p1_g_ShockwaveVictim[target] = true
        ExecuteHamB(Ham_TakeDamage, target, owner, owner, 1.0, DMG_CLUB | p1_DMG_CUSTOM_MELEE)
        p1_g_ShockwaveVictim[target] = false

        if(wasParrying) continue

        new Float:len = floatsqroot(dx*dx + dy*dy)
        if(len < 1.0) len = 1.0
        new Float:velocity[3]
        velocity[0] = dx / len * p1_GLAIVE_SHOCKWAVE_PUSH
        velocity[1] = dy / len * p1_GLAIVE_SHOCKWAVE_PUSH
        velocity[2] = p1_GLAIVE_SHOCKWAVE_UP
        set_pev(target, pev_velocity, velocity)
        Mech_ArmWallBounce(target, velocity)
    }
}

public p1_AxeHeal(p1_id, Float:damage)
{
    if(!is_user_alive(p1_id)) return
    new p1_heal = floatround(damage * 0.20, floatround_floor)
    if(p1_heal < 1) p1_heal = 1
    new p1_hp = get_user_health(p1_id) + p1_heal
    if(p1_hp > p1_MAX_MELEE_HEALTH) p1_hp = p1_MAX_MELEE_HEALTH
    set_user_health(p1_id, p1_hp)
}

public p1_ApplyBatKnockback(attacker, p1_victim, Float:power, Float:up)
{
    if(!is_user_alive(attacker) || !is_user_alive(p1_victim)) return
    new Float:p1_a[3], Float:v[3], Float:p1_vel[3]
    pev(attacker, pev_origin, p1_a)
    pev(p1_victim, pev_origin, v)
    p1_vel[0] = v[0] - p1_a[0]
    p1_vel[1] = v[1] - p1_a[1]
    p1_vel[2] = 0.0
    new Float:p1_len = floatsqroot(p1_vel[0]*p1_vel[0] + p1_vel[1]*p1_vel[1])
    if(p1_len <= 0.0) return
    p1_vel[0] = p1_vel[0] / p1_len * power
    p1_vel[1] = p1_vel[1] / p1_len * power
    p1_vel[2] = up
    set_pev(p1_victim, pev_velocity, p1_vel)
    Mech_ArmWallBounce(p1_victim, p1_vel)
}

public p1_PlayKnifeAnim(p1_id, logicalSlot)
{
    if(p1_id < 1 || p1_id > 32 || !is_user_connected(p1_id))
        return
    if(logicalSlot < 0 || logicalSlot > 8)
        return

    new melee = p1_g_Melee[p1_id]
    if(melee < 0 || melee >= p1_MELEE_COUNT)
        melee = p1_MELEE_KNIFE

    new Float:now = get_gametime()

    // Never let the idle callback replace an attack/draw/parry sequence while
    // it is playing. Attack animations themselves are never discarded by a
    // long global lock: every new attack sends its mapped sequence.
    if(logicalSlot == 0)
    {
        if(now < p1_g_AnimLockUntil[p1_id] || p1_g_bIdleAnimPlayed[p1_id])
            return
        p1_g_bIdleAnimPlayed[p1_id] = true
    }
    else
    {
        p1_g_bIdleAnimPlayed[p1_id] = false
        p1_g_AnimLockUntil[p1_id] = now + 0.85
    }

    // Allow only this explicitly mapped animation through the message filter.
    p1_g_AllowWeaponAnim[p1_id] = true
    message_begin(MSG_ONE, SVC_WEAPONANIM, _, p1_id)
    write_byte(p1_AnimationMap[melee][logicalSlot])
    write_byte(pev(p1_id, pev_body))
    message_end()
    p1_g_AllowWeaponAnim[p1_id] = false
}

public p1_GoldenFlash(p1_id)
{
    message_begin(MSG_ONE, p1_g_msgScreenFade, _, p1_id)
    write_short(1 << 10)
    write_short(1 << 10)
    write_short(0)
    write_byte(255)
    write_byte(215)
    write_byte(0)
    write_byte(40)
    message_end()
}

public p1_fw_PlayerPreThink(p1_id)
{
    if(!is_user_alive(p1_id)) return FMRES_IGNORED
    if(Mech_IsStunned(p1_id))
    {
        set_pev(p1_id, pev_maxspeed, 50.0)
        set_user_rendering(p1_id, kRenderFxGlowShell, 105, 120, 145, kRenderNormal, 24)
        new buttons = pev(p1_id, pev_button)
        set_pev(p1_id, pev_button, buttons & ~(IN_ATTACK | IN_ATTACK2 | IN_USE))
        return FMRES_IGNORED
    }
    else if(g_MechStunUntil[p1_id] > 0.0) Mech_ClearStun(p1_id)
    if(g_MechBackKickSlowUntil[p1_id] > get_gametime())
    {
        set_pev(p1_id, pev_maxspeed, g_MechBackKickSlow)
        return FMRES_IGNORED
    }
    else if(g_MechBackKickSlowUntil[p1_id] > 0.0)
    {
        // Restore the selected weapon's own movement speed, not a generic 250.
        g_MechBackKickSlowUntil[p1_id] = 0.0
        p1_ApplyMelee(p1_id)
    }

    if(p1_g_Melee[p1_id] == p1_MELEE_GLAIVE)
    {
        new bool:glaiveSuppressed = p1_IsSuppressed(p1_id)
        new glaiveHealth = get_user_health(p1_id)

        if(glaiveSuppressed)
        {
            // Suppression interrupts the freeze and pending shockwave but
            // does not reset Berserk unless the player heals above 80 HP.
            p1_g_GlaiveFrozen[p1_id] = false
            p1_g_GlaiveFreezeEnd[p1_id] = 0.0
            remove_task(p1_id + 15000)
            if(glaiveHealth > p1_GLAIVE_BERSERK_HP && p1_g_GlaiveBerserk[p1_id])
            {
                p1_g_GlaiveBerserk[p1_id] = false
                p1_g_GlaiveGlowBrightEnd[p1_id] = 0.0
            }
        }
        else if(glaiveHealth <= p1_GLAIVE_BERSERK_HP && !p1_g_GlaiveBerserk[p1_id])
        {
            p1_g_GlaiveBerserk[p1_id] = true

            emit_sound(p1_id, CHAN_ITEM, "weapons/knife_arena/glaive_berserk.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

            p1_g_GlaiveFrozen[p1_id] = true
            p1_g_GlaiveFreezeEnd[p1_id] = get_gametime() + p1_GLAIVE_FREEZE_TIME
            p1_g_GlaiveGlowBrightEnd[p1_id] = get_gametime() + p1_GLAIVE_FREEZE_TIME
            remove_task(p1_id + 15000)
            set_task(p1_GLAIVE_SHOCKWAVE_DELAY, "p1_GlaiveShockwave", p1_id + 15000)
        }
        else if(glaiveHealth > p1_GLAIVE_BERSERK_HP && p1_g_GlaiveBerserk[p1_id])
        {
            p1_g_GlaiveBerserk[p1_id] = false
            p1_g_GlaiveFrozen[p1_id] = false
            p1_g_GlaiveFreezeEnd[p1_id] = 0.0
            p1_g_GlaiveGlowBrightEnd[p1_id] = 0.0
            remove_task(p1_id + 15000)
        }
    }

    if(p1_g_GlaiveFrozen[p1_id])
    {
        if(get_gametime() < p1_g_GlaiveFreezeEnd[p1_id])
        {
            new Float:stopVelocity[3] = {0.0, 0.0, 0.0}
            set_pev(p1_id, pev_velocity, stopVelocity)
            set_pev(p1_id, pev_button, 0)
            return FMRES_IGNORED
        }
        p1_g_GlaiveFrozen[p1_id] = false
    }

    new bool:suppressed = p1_IsSuppressed(p1_id)
    if(p1_g_SuppressedUntil[p1_id] > 0.0 && !suppressed)
    {
        p1_g_SuppressedUntil[p1_id] = 0.0
        p1_ApplyMelee(p1_id)
        p7_UpdatePlayerGlow(p1_id)
    }

    if(suppressed)
    {
        // Suppression removes weapon abilities, not normal weapon stats.
        // Katana loses only its special speed/jump bonuses; other weapons
        // retain their ordinary movement speeds. Hammer gravity is suspended
        // by p1_ApplyGravity while preserving its selected low/high setting.
        p1_StopRegen(p1_id)
        if(get_user_weapon(p1_id) == CSW_KNIFE && p1_g_Melee[p1_id] == p1_MELEE_KATANA)
            set_pev(p1_id, pev_maxspeed, p1_MOVE_KATANA)
    }

    if(p1_g_MicroStunned[p1_id])
    {
        set_pev(p1_id, pev_button, 0)
        set_pev(p1_id, pev_maxspeed, 80.0)
        return FMRES_IGNORED
    }

    if(!suppressed && get_user_weapon(p1_id) == CSW_KNIFE && p1_g_Melee[p1_id] == p1_MELEE_KATANA)
    {
        new Float:katanaSpeed = p1_KATANA_SPEED
        set_pev(p1_id, pev_maxspeed, katanaSpeed)
        new p1_buttons = pev(p1_id, pev_button)
        new p1_oldbuttons = pev(p1_id, pev_oldbuttons)
        new p1_flags = pev(p1_id, pev_flags)
        if((p1_buttons & IN_JUMP) && !(p1_oldbuttons & IN_JUMP) && (p1_flags & FL_ONGROUND))
        {
            new Float:p1_vel[3]
            pev(p1_id, pev_velocity, p1_vel)
            p1_vel[0] *= p1_KATANA_JUMP_MULT
            p1_vel[1] *= p1_KATANA_JUMP_MULT
            set_pev(p1_id, pev_velocity, p1_vel)
        }
    }
    return FMRES_IGNORED
}

public p1_plugin_end()
{
    if(p1_g_Vault != INVALID_HANDLE)
        nvault_close(p1_g_Vault)
}







// ============================================================
// COMBAT EXPANSION: stun, clash, knockback wall bounce, backstab
// ============================================================


stock bool:Mech_IsStunned(id)
{
    return id >= 1 && id <= 32 && g_MechStunUntil[id] > get_gametime()
}

stock Mech_ClearStun(id)
{
    if(id < 1 || id > 32 || g_MechStunUntil[id] <= 0.0) return
    g_MechStunUntil[id] = 0.0
    if(!p4_g_Stunned[id]) g_AchStunOwner[id] = 0
    set_pev(id, pev_renderfx, kRenderFxNone)
    set_pev(id, pev_rendercolor, Float:{0.0, 0.0, 0.0})
    set_pev(id, pev_renderamt, 0.0)
    if(is_user_alive(id))
    {
        if(g_MechBackKickSlowUntil[id] > get_gametime())
            set_pev(id, pev_maxspeed, g_MechBackKickSlow)
        else if(!p5_g_bBlockActive[id])
            p1_ApplyMelee(id)
    }
    p7_UpdatePlayerGlow(id)
}

stock Mech_ApplyStun(id, stunOwner)
{
    if(!is_user_alive(id)) return
    g_MechStunUntil[id] = get_gametime() + MECH_STUN_TIME
    g_AchStunOwner[id] = stunOwner
    // A back-attack stun disables both defensive actions for its full duration.
    p4_g_ParryActive[id] = false
    p4_g_ParryAttempt[id] = false
    p5_ResetPlayerBlock(id)
    set_pev(id, pev_renderfx, kRenderFxGlowShell)
    set_pev(id, pev_rendercolor, Float:{105.0, 120.0, 145.0})
    set_pev(id, pev_renderamt, 24.0)
    set_pev(id, pev_maxspeed, 50.0)
}

stock Float:Mech_BackstabRange(melee)
{
    switch(melee)
    {
        case p1_MELEE_KNIFE: return MECH_BACKSTAB_KNIFE_RANGE
        case p1_MELEE_KATANA: return MECH_BACKSTAB_KATANA_RANGE
        case p1_MELEE_SAIS: return MECH_BACKSTAB_SAIS_RANGE
        case p1_MELEE_GLAIVE: return MECH_BACKSTAB_GLAIVE_RANGE
        case p1_MELEE_GLADIUS: return MECH_BACKSTAB_GLADIUS_RANGE
    }
    return 0.0
}

stock Mech_FindBehindTarget(id, Float:range)
{
    new players[32], count, target = 0
    get_players(players, count, "a")
    new Float:origin[3], Float:ang[3], Float:fwd[3], Float:to[3]
    pev(id, pev_origin, origin); pev(id, pev_v_angle, ang)
    angle_vector(ang, ANGLEVECTOR_FORWARD, fwd)
    new Float:best = range + 1.0
    for(new i=0;i<count;i++)
    {
        new other = players[i]
        if(other == id || get_user_team(other) == get_user_team(id)) continue
        new Float:o[3]; pev(other, pev_origin, o)
        to[0] = o[0]-origin[0]; to[1] = o[1]-origin[1]; to[2] = 0.0
        new Float:d = floatsqroot(to[0]*to[0] + to[1]*to[1])
        if(d < 1.0 || d > range || d >= best) continue
        to[0] /= d; to[1] /= d
        // A target behind the player's facing direction.
        if(fwd[0]*to[0] + fwd[1]*to[1] > -0.35) continue
        target = other; best = d
    }
    return target
}

stock Mech_Spark(Float:origin[3])
{
    // Match the Glaive shockwave's native spark effect (TE_SPARKS).
    new p4_origin[3]
    p4_origin[0] = floatround(origin[0])
    p4_origin[1] = floatround(origin[1])
    p4_origin[2] = floatround(origin[2])
    message_begin(MSG_PVS, SVC_TEMPENTITY, p4_origin)
    write_byte(TE_SPARKS)
    write_coord(p4_origin[0])
    write_coord(p4_origin[1])
    write_coord(p4_origin[2])
    message_end()
}


stock Mech_ArmWallBounce(id, Float:velocity[3])
{
    if(id < 1 || id > 32 || !is_user_alive(id)) return
    if(floatabs(velocity[0]) + floatabs(velocity[1]) < 80.0) return
    g_MechWallBounce[id] = true
    g_MechWallCheckOrigin[id][0] = velocity[0]
    g_MechWallCheckOrigin[id][1] = velocity[1]
    g_MechWallCheckOrigin[id][2] = velocity[2]
    g_MechWallBounceUntil[id] = get_gametime() + 0.40
}


#define p2_KICK_VMODEL "models/v_foot.mdl"
#define p2_KICK_PMODEL "models/ZombieKick.mdl"

#define p2_KICK_SOUND "kick/kick.wav"
#define p2_KICK_HIT_SOUND "kick/kick_stone1.wav"

#define p2_KICK_RANGE 220
#define p2_TASK_KICK 201456
#define p2_TASK_KICK_ANIM 202456
#define p2_TASK_KICK_HUD 203456
#define p2_DMG_CUSTOM_MELEE (1<<29)

// ============================================================
// KICK SETTINGS
// ============================================================

new Float:p2_g_KickKnockback = 467.0 // Configurable normal-kick knockback
new Float:p2_g_LowKickVerticalKnockback = 467.0 // Configurable upward-only low-kick force
new Float:p2_g_LowKickDamage = 15.0 // Low-kick damage (same as normal body kick)
new Float:p2_g_KickBodyDamage = 15.0
new Float:p2_g_KickHeadDamage = 30.0
new Float:p2_g_KickRecovery = 6.0 // Basic Kick
new Float:p2_g_LowKickRecovery = 8.0
new Float:p2_g_BackKickRecovery = 10.0
new Float:p2_g_KickGlobalDelay = 0.75
new Float:p2_g_DownKickForce = MECH_DOWNKICK_FORCE
new Float:p2_g_BackKickSlow = 110.0
new p2_g_KickType[33] // 0 basic, 1 low/down, 2 back

// ============================================================
// GLOBALS
// ============================================================

new p2_g_OldModel[33][64]

new p2_g_CanKick[33]
new p2_g_Kicking[33]
new Float:p2_g_KickEndTime[33]
new Float:p2_g_KickReadyAt[33][3]
new Float:p2_g_NextAnyKick[33]
new p2_g_IsUserAlive[33]

new p2_g_KickAnimEnt[33]
new p2_g_KickAvtEnt[33]

new p2_g_MaxPlayers
new p2_g_BotHamRegister

// ============================================================
// INIT
// ============================================================

public p2_plugin_init()
{
register_cvar("ka_downkick_force", "520.0")
register_cvar("ka_backkick_slow", "110.0")
register_cvar("ka_kick_global_delay", "0.75")
set_task(0.1, "p2_LoadKickCvars")

// C is normally bound to radio3. In Knife Arena the separate buy-menu
// plugin is disabled, so this plugin can handle radio3 as the kick command.
// Hook that existing command instead of
// rebinding C on every client. Keep kickass available for manual custom binds.
register_clcmd("radio3", "p2_cmd_kick")
register_clcmd("kickass", "p2_cmd_kick")
register_clcmd("+kickass", "p2_cmd_kick")
register_clcmd("-kickass", "p2_cmd_kick_release")
register_clcmd("+backattack", "Mech_BackAttackStart")
register_clcmd("-backattack", "Mech_BackAttackEnd")

register_event("DeathMsg", "p2_Event_Death", "a")
set_task(0.05, "Mech_CheckWallBounces", 28222, _, _, "b")
RegisterHam(Ham_Player_PreThink, "player", "p2_fw_KickFollow_Pre", 0)

RegisterHam(
	Ham_Spawn,
	"player",
	"p2_fw_PlayerSpawn_Post",
	1
)

register_logevent(
	"p2_round_start",
	2,
	"1=Round_Start"
)

register_logevent(
	"p2_round_end",
	2,
	"1=Round_End"
)

register_forward(
	FM_AddToFullPack,
	"p2_fw_AddToFullPack_Post",
	1
)

p2_g_MaxPlayers = get_maxplayers()

}

// ============================================================
// PRECACHE
// ============================================================

public p2_plugin_precache()
{
engfunc(
EngFunc_PrecacheModel,
p2_KICK_VMODEL
)

engfunc(
	EngFunc_PrecacheModel,
	p2_KICK_PMODEL
)

engfunc(
	EngFunc_PrecacheSound,
	p2_KICK_SOUND
)

engfunc(
	EngFunc_PrecacheSound,
	p2_KICK_HIT_SOUND
)

}

// ============================================================
// ROUND START
// ============================================================

public p2_round_start()
{

for(new p2_id = 1; p2_id <= p2_g_MaxPlayers; p2_id++)
{
	p2_g_CanKick[p2_id] = 1
	p2_g_Kicking[p2_id] = 0
}

}

// ============================================================
// ROUND END
// ============================================================

public p2_round_end()
{

for(new p2_id = 1; p2_id <= p2_g_MaxPlayers; p2_id++)
{
	p2_g_CanKick[p2_id] = 1
	p2_g_Kicking[p2_id] = 0
}

}

// ============================================================
// CLIENT CONNECT
// ============================================================

public p2_client_putinserver(p2_id)
{
    p2_g_IsUserAlive[p2_id] = 0
    p2_g_CanKick[p2_id] = 1
    p2_g_Kicking[p2_id] = 0

    if(!p2_g_BotHamRegister && is_user_bot(p2_id))
    {
        p2_g_BotHamRegister = 1

        set_task(
            0.1,
            "p2_Bot_RegisterHam",
            p2_id
        )
    }

}

// ============================================================
// CLIENT DISCONNECT
// ============================================================

public p2_client_disconnect(p2_id)
{
g_MechBackAttackHeld[p2_id] = false
p2_g_IsUserAlive[p2_id] = 0
p2_g_CanKick[p2_id] = 0
p2_g_Kicking[p2_id] = 0

remove_task(p2_id + p2_TASK_KICK)
remove_task(p2_id + p2_TASK_KICK_ANIM)
remove_task(p2_id + p2_TASK_KICK_HUD)

}

public p2_LoadKickCvars()
{
    p2_g_DownKickForce = get_cvar_float("ka_downkick_force")
    p2_g_BackKickSlow = get_cvar_float("ka_backkick_slow")
    g_MechBackKickSlow = p2_g_BackKickSlow
    p2_g_KickGlobalDelay = get_cvar_float("ka_kick_global_delay")
}

// ============================================================
// BOT HAM
// ============================================================

public p2_Bot_RegisterHam(p2_id)
{
RegisterHamFromEntity(
Ham_Spawn,
p2_id,
"p2_fw_PlayerSpawn_Post",
1
)
}

// ============================================================
// PLAYER SPAWN
// ============================================================

public p2_fw_PlayerSpawn_Post(p2_id)
{
if(!is_user_alive(p2_id))
return

p2_g_IsUserAlive[p2_id] = 1
// Do not reset kick cooldown on respawn; only initialize if not already cooling down.
if(!task_exists(p2_id + p2_TASK_KICK))
    p2_g_CanKick[p2_id] = 1
p2_g_Kicking[p2_id] = 0
remove_task(p2_id + p2_TASK_KICK_HUD)
set_task(0.1, "p2_ShowKickCountdown", p2_id + p2_TASK_KICK_HUD, _, _, "b")

}

// ============================================================
// DEATH
// ============================================================

public p2_Event_Death()
{
new p2_victim = read_data(2)

// Phantom Death broadcasts a cosmetic DeathMsg for the kill feed only.
// Do not let this unrelated kick module mark the still-living player dead.
if(p2_victim >= 1 && p2_victim <= 32 && p1_g_ScytheCloaked[p2_victim])
    return

if(p2_victim >= 1 && p2_victim <= p2_g_MaxPlayers)
{
	p2_g_IsUserAlive[p2_victim] = 0
	p2_g_Kicking[p2_victim] = 0
}

}

// ============================================================
// HIDE ANIMATION ENTITY
// ============================================================

public p2_fw_KickFollow_Pre(p2_id)
{
    if(!is_user_alive(p2_id) || !p2_g_Kicking[p2_id])
        return HAM_IGNORED
    if(!pev_valid(p2_g_KickAnimEnt[p2_id]))
        return HAM_IGNORED

    static Float:p2_origin[3], Float:p2_angles[3], Float:p2_velocity[3]
    pev(p2_id, pev_origin, p2_origin)
    pev(p2_id, pev_angles, p2_angles)
    pev(p2_id, pev_velocity, p2_velocity)
    set_pev(p2_g_KickAnimEnt[p2_id], pev_origin, p2_origin)
    set_pev(p2_g_KickAnimEnt[p2_id], pev_angles, p2_angles)
    set_pev(p2_g_KickAnimEnt[p2_id], pev_velocity, p2_velocity)
    return HAM_IGNORED
}

public p2_fw_AddToFullPack_Post(
es_handle,
e,
p2_ent,
host,
hostflags,
player,
pSet
)
{
if(host < 1 || host > 32)
return FMRES_IGNORED

if(!pev_valid(p2_ent))
	return FMRES_IGNORED

if(p2_g_KickAvtEnt[host] != p2_ent)
	return FMRES_IGNORED

set_es(
	es_handle,
	ES_Effects,
	get_es(es_handle, ES_Effects) | EF_NODRAW
)

return FMRES_IGNORED

}

// ============================================================
// KICK COMMAND
// ============================================================
//
// MANUAL BIND:
//
// Default C input: radio3, handled by p2_cmd_kick above.
// Custom kick bind example: bind v kickass.
//
// ============================================================

// Default controls are handled through their existing engine inputs:
// F = impulse 100 (parry), R = IN_RELOAD (backattack),
// K = +voicerecord/-voicerecord (hold/release block), C = radio3 (kick).
// Do not issue client-side bind commands; preserve each player's key layout.

public Mech_BackAttackStart(id)
{
    if(id >= 1 && id <= 32 && is_user_connected(id))
        g_MechBackAttackHeld[id] = true
    return PLUGIN_HANDLED
}

public Mech_BackAttackEnd(id)
{
    if(id >= 1 && id <= 32)
        g_MechBackAttackHeld[id] = false
    return PLUGIN_HANDLED
}

public p2_cmd_kick(p2_id)
{
if(!is_user_alive(p2_id))
return PLUGIN_HANDLED

if(p2_g_Kicking[p2_id]) return PLUGIN_HANDLED
new buttons = pev(p2_id, pev_button)
new kickType = 0
if(g_MechBackAttackHeld[p2_id]) kickType = 2 // Dedicated backattack bind takes priority over Ctrl.
else if(buttons & IN_DUCK) kickType = 1
new Float:now = get_gametime()
if(now < p2_g_NextAnyKick[p2_id] || now < p2_g_KickReadyAt[p2_id][kickType]) return PLUGIN_HANDLED
g_AchRoundLightOnly[p2_id] = 0
p2_g_NextAnyKick[p2_id] = now + p2_g_KickGlobalDelay
p2_g_KickType[p2_id] = kickType
new Float:recovery = kickType == 2 ? p2_g_BackKickRecovery : (kickType == 1 ? p2_g_LowKickRecovery : p2_g_KickRecovery)
if(kickType == 2 && p1_g_Melee[p2_id] == p1_MELEE_KATANA)
    recovery *= 0.60 // Katana recovers 40% faster after a back kick.
p2_g_KickReadyAt[p2_id][kickType] = now + recovery
p2_g_CanKick[p2_id] = 0
p2_g_Kicking[p2_id] = 1
p2_g_KickEndTime[p2_id] = now + 1.0

// Save current weapon view model.
pev(
	p2_id,
	pev_viewmodel2,
	p2_g_OldModel[p2_id],
	63
)

// Set attack delay.
p2_Set_Player_NextAttack(
	p2_id,
	0.75 + get_pdata_float(p2_id, 83, 5)
)

if(kickType != 2)
{
    set_pev(p2_id, pev_viewmodel2, p2_KICK_VMODEL)
    p2_Set_WeaponAnim(p2_id, 1)
    p2_Handle_PlayerAnim(p2_id)
}
else
{
    // Back kick deliberately leaves the viewmodel empty and slows the kicker.
    set_pev(p2_id, pev_viewmodel2, "")
    set_pev(p2_id, pev_maxspeed, p2_g_BackKickSlow)
    g_MechBackKickSlowUntil[p2_id] = now + 1.0
    emit_sound(p2_id, CHAN_BODY, p2_KICK_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
p2_Check_KickKnockback(p2_id)
remove_task(p2_id + p2_TASK_KICK_ANIM)
set_task(1.0, "p2_EndKickAnimation", p2_id + p2_TASK_KICK_ANIM)
remove_task(p2_id + p2_TASK_KICK)
set_task(recovery, "p2_Reset_Kick", p2_id + p2_TASK_KICK)

return PLUGIN_HANDLED

}


public p2_cmd_kick_release(p2_id)
{
    return PLUGIN_HANDLED
}

// ============================================================
// FIND TARGET / DAMAGE / KNOCKBACK
// ============================================================

public p2_Check_KickKnockback(p2_id)
{
new p2_target
new p2_body

// Find player directly under crosshair.
get_user_aiming(
	p2_id,
	p2_target,
	p2_body,
	p2_KICK_RANGE
)

new bool:p2_backKick = (p2_g_KickType[p2_id] == 2)
new bool:p2_lowKick = (p2_g_KickType[p2_id] == 1)
new bool:p2_bLowKick = p2_lowKick

// Airborne down-kicks get a forgiving target radius around the crosshair.
// This helps connect during close mid-fight movement without making grounded
// low-kicks unexpectedly magnetize to distant players.
if(p2_lowKick && !(pev(p2_id, pev_flags) & FL_ONGROUND))
{
    new Float:eye[3], Float:angles[3], Float:aimForward[3], Float:candidateOrigin[3]
    pev(p2_id, pev_origin, eye)
    pev(p2_id, pev_view_ofs, angles)
    eye[0] += angles[0]; eye[1] += angles[1]; eye[2] += angles[2]
    pev(p2_id, pev_v_angle, angles)
    angle_vector(angles, ANGLEVECTOR_FORWARD, aimForward)
    new Float:bestScore = 999999.0
    new players[32], count
    get_players(players, count, "a")
    for(new i = 0; i < count; i++)
    {
        new candidate = players[i]
        if(candidate == p2_id || get_user_team(candidate) == get_user_team(p2_id)) continue
        pev(candidate, pev_origin, candidateOrigin)
        new Float:dx = candidateOrigin[0] - eye[0]
        new Float:dy = candidateOrigin[1] - eye[1]
        new Float:dz = candidateOrigin[2] + 18.0 - eye[2]
        new Float:distance = floatsqroot(dx*dx + dy*dy + dz*dz)
        if(distance > 220.0 || distance < 1.0) continue
        new Float:dot = (aimForward[0]*dx + aimForward[1]*dy + aimForward[2]*dz) / distance
        if(dot < 0.72) continue
        // Lateral distance from the aim ray forms the forgiving radius.
        new Float:along = dx*aimForward[0] + dy*aimForward[1] + dz*aimForward[2]
        new Float:sideX = dx - along*aimForward[0]
        new Float:sideY = dy - along*aimForward[1]
        new Float:sideZ = dz - along*aimForward[2]
        new Float:side = floatsqroot(sideX*sideX + sideY*sideY + sideZ*sideZ)
        if(side > 58.0) continue
        new Float:score = distance + side*1.5
        if(score < bestScore)
        {
            bestScore = score
            p2_target = candidate
            p2_body = HIT_CHEST
        }
    }
}

// Kicking world geometry launches the kicker opposite their view direction:
// floor -> upward, wall -> backward, ceiling -> downward.
if(!p2_backKick && (p2_target < 1 || p2_target > p2_g_MaxPlayers || !is_user_alive(p2_target) || p2_target == p2_id))
{
    new Float:eye[3], Float:viewOfs[3], Float:viewAngles[3], Float:look[3], Float:solidEnd[3]
    pev(p2_id, pev_origin, eye); pev(p2_id, pev_view_ofs, viewOfs)
    eye[0] += viewOfs[0]; eye[1] += viewOfs[1]; eye[2] += viewOfs[2]
    pev(p2_id, pev_v_angle, viewAngles)
    angle_vector(viewAngles, ANGLEVECTOR_FORWARD, look)
    solidEnd[0] = eye[0] + look[0] * 125.0
    solidEnd[1] = eye[1] + look[1] * 125.0
    solidEnd[2] = eye[2] + look[2] * 125.0
    new solidTrace = create_tr2()
    engfunc(EngFunc_TraceLine, eye, solidEnd, IGNORE_MONSTERS, p2_id, solidTrace)
    new Float:solidFraction; get_tr2(solidTrace, TR_flFraction, solidFraction)
    new solidHit = get_tr2(solidTrace, TR_pHit)
    new bool:hitWorldSolid = (solidFraction < 1.0 && (solidHit == 0 || !is_user_connected(solidHit)))
    free_tr2(solidTrace)
    if(hitWorldSolid)
    {
        new Float:launch[3]
        launch[0] = -look[0] * 650.0
        launch[1] = -look[1] * 650.0
        launch[2] = -look[2] * 650.0
        set_pev(p2_id, pev_velocity, launch)
        // Keep the kick viewmodel and third-person kick animation visible;
        // p2_EndKickAnimation restores the original model after its normal duration.
        return
    }
}
if(!p2_backKick && (p2_target < 1 || p2_target > p2_g_MaxPlayers)) return
if(!p2_backKick && (!is_user_alive(p2_target) || p2_target == p2_id)) return
if(p2_backKick)
{
    if(get_gametime() - g_MechLastDamage[p2_id] <= 0.10) return
    // Search a narrow cone behind the player, independent of view direction.
    new Float:origin[3], Float:angles[3], Float:fwd[3], Float:other[3]
    pev(p2_id, pev_origin, origin); pev(p2_id, pev_v_angle, angles)
    angle_vector(angles, ANGLEVECTOR_FORWARD, fwd)
    p2_target = 0
    new players[32], count; get_players(players, count, "a")
    new Float:best = MECH_BACKKICK_RANGE + 1.0
    for(new i=0;i<count;i++)
    {
        new candidate=players[i]; if(candidate==p2_id || get_user_team(candidate)==get_user_team(p2_id)) continue
        pev(candidate, pev_origin, other)
        new Float:dx=other[0]-origin[0], Float:dy=other[1]-origin[1]
        new Float:dz=other[2]-origin[2]
        new Float:d=floatsqroot(dx*dx+dy*dy)
        // Wider vertical tolerance: a back-kick can catch targets slightly above head level.
        if(d>MECH_BACKKICK_RANGE || d>=best || d<1.0) continue
        if(dz < -48.0 || dz > 72.0) continue
        if((fwd[0]*dx+fwd[1]*dy)/d > -0.35) continue
        p2_target=candidate; best=d
    }
    if(!p2_target) return
}
if(p2_target < 1 || p2_target > p2_g_MaxPlayers || !is_user_alive(p2_target) || p2_target == p2_id) return
if(get_user_team(p2_id)==get_user_team(p2_target)) { g_AchTeamKicks[p2_id]++; if(g_AchTeamKicks[p2_id]>=15) ach_set(p2_id,52); }
else { g_AchKickOwner[p2_target]=p2_id; if(!(pev(p2_target,pev_flags) & FL_ONGROUND)) ach_set(p2_id,53); }
if(p2_bLowKick && !(pev(p2_id,pev_flags) & FL_ONGROUND) && (pev(p2_id,pev_button) & IN_DUCK)) ach_set(p2_id,62);
if(p2_backKick && Mech_IsStunned(p2_target) && g_AchBackComboVictim[p2_id]==p2_target) { ach_set(p2_id,74); g_AchBackComboVictim[p2_id]=0; }
if(p2_bLowKick && p1_g_MicroBomb[p2_target]) ach_set(p2_id,73);

// Extra view-cone check.
static Float:p2_TargetOrigin[3]

pev(
	p2_target,
	pev_origin,
	p2_TargetOrigin
)

if(!p2_backKick && !is_in_viewcone(
	p2_id,
	p2_TargetOrigin,
	1
))
{
	return
}

// ========================================================
// DAMAGE
// ========================================================

new Float:p2_Damage

if(p2_backKick)
{
    p2_body = HIT_HEAD
    p2_Damage = p2_g_KickHeadDamage
}
else if(p2_bLowKick)
{
    // Low-kick always deals 15 damage, regardless of the aimed hitgroup.
    p2_Damage = p2_g_LowKickDamage
}
else if(p2_body == HIT_HEAD)
{
    p2_Damage = p2_g_KickHeadDamage
}
else
{
    p2_Damage = p2_g_KickBodyDamage
}

new bool:p2_cleaverExecution = ((!p2_bLowKick || p2_backKick) && p2_body == HIT_HEAD &&
    p1_g_Melee[p2_id] == p1_MELEE_CLEAVER && get_user_health(p2_target) <= p1_CLEAVER_EXECUTE_HP &&
    !p1_IsSuppressed(p2_id))
if(p2_cleaverExecution)
    p2_Damage = float(get_user_health(p2_target) + 1)

// Kick damage is custom melee, so apply the same additive vulnerability
// and Glaive Berserk bonuses here instead of relying on the normal melee hook.
new Float:p2_damageBonus = 0.0
if(p1_g_Vulnerable[p2_target]) p2_damageBonus += p1_VULN_MULTIPLIER - 1.0
if(p1_g_Melee[p2_target] == p1_MELEE_CLEAVER && p1_CleaverHasLowOpponent(p2_target))
    p2_damageBonus += p1_CLEAVER_VULN_BONUS
if(p1_g_Melee[p2_id] == p1_MELEE_GLAIVE && !p1_IsSuppressed(p2_id) && p1_g_GlaiveBerserk[p2_id] && get_user_health(p2_id) <= p1_GLAIVE_BERSERK_HP)
    p2_damageBonus += p1_GLAIVE_DAMAGE_BONUS
p2_Damage *= (1.0 + p2_damageBonus)

new bool:wasKickParried = p4_g_ParryActive[p2_target]
new bool:wasKickBlocked = p5_g_bBlockActive[p2_target]
ExecuteHamB(
	Ham_TakeDamage,
	p2_target,
	p2_id,
	p2_id,
	p2_Damage,
	DMG_CLUB | p2_DMG_CUSTOM_MELEE | (p2_cleaverExecution ? p1_CLEAVER_EXECUTE_FLAG : 0)
)

// A parry/block is not a landed head hit and cancels kick knockback.
if(wasKickParried || wasKickBlocked) return
if(p2_body == HIT_HEAD && !p2_bLowKick)
{
    ach_add(p2_id,ACH_SKULL_CRUSHER,1)
}

// ========================================================
// 3D KNOCKBACK
// ========================================================
//
// IMPORTANT:
//
// There is NO forced +Z here.
//
// The vertical force depends on the actual vertical
// difference between kicker and p2_target.
//
// Therefore:
//
// Kicker above p2_target:
//     p2_target can be pushed downward.
//
// Kicker below p2_target:
//     p2_target can be pushed upward.
//
// Same height:
//     mostly horizontal.
//
// ========================================================

static Float:p2_KickerOrigin[3]
static Float:p2_TargetCenter[3]
static Float:p2_Velocity[3]

pev(
	p2_id,
	pev_origin,
	p2_KickerOrigin
)

pev(
	p2_target,
	pev_origin,
	p2_TargetCenter
)

// Aim at the approximate center of the p2_target.
p2_TargetCenter[2] += 18.0

if(p2_backKick)
{
    new Float:angles[3], Float:fwdVec[3]
    pev(p2_id, pev_v_angle, angles); angle_vector(angles, ANGLEVECTOR_FORWARD, fwdVec)
    p2_Velocity[0] = -fwdVec[0] * 367.0
    p2_Velocity[1] = -fwdVec[1] * 367.0
    p2_Velocity[2] = 467.0
}
else if(p2_bLowKick)
{
    // Airborne down-kick drives an airborne target sharply into the floor.
    new Float:targetVel[3]; pev(p2_target, pev_velocity, targetVel)
    if(!(pev(p2_id, pev_flags) & FL_ONGROUND) && (pev(p2_id, pev_button) & IN_DUCK) && !(pev(p2_target, pev_flags) & FL_ONGROUND))
    {
        p2_Velocity[2] = -p2_g_DownKickForce * MECH_DOWNKICK_FALL_SCALE
        g_MechDownKickBounce[p2_target] = true
        g_MechDownKickUntil[p2_target] = get_gametime() + 1.5
    }
    else
        p2_Velocity[2] = p2_g_LowKickVerticalKnockback
    p2_Velocity[0] = 0.0; p2_Velocity[1] = 0.0
}
else
{
    p2_Get_SpeedVector(
        p2_KickerOrigin,
        p2_TargetCenter,
        p2_g_KickKnockback,
        p2_Velocity
    )
}

// Apply the selected kick velocity.
set_pev(
	p2_target,
	pev_velocity,
	p2_Velocity
)
Mech_ArmWallBounce(p2_target, p2_Velocity)

// Back kick uses the regular kick sound only. Other kicks retain their
// normal impact sound in addition to the animation's kick sound.
if(!p2_backKick)
{
    emit_sound(p2_id, CHAN_ITEM, p2_KICK_HIT_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

}

// Knockback wall collision: detect a sudden horizontal stop while airborne/moving.
public Mech_CheckWallBounces()
{
    for(new id=1; id<=32; id++)
    {
        if(!is_user_alive(id)) continue
        new Float:vel[3], Float:org[3]
        pev(id, pev_velocity, vel)
        pev(id, pev_origin, org)

        if(g_MechDownKickBounce[id] && get_gametime() <= g_MechDownKickUntil[id] && (pev(id, pev_flags) & FL_ONGROUND))
        {
            vel[2] = 115.0
            set_pev(id, pev_velocity, vel)
            g_MechDownKickBounce[id] = false
        }
        if(get_gametime() > g_MechDownKickUntil[id]) g_MechDownKickBounce[id] = false

        if(!g_MechWallBounce[id]) continue
        if(get_gametime() > g_MechWallBounceUntil[id])
        {
            g_MechWallBounce[id] = false
            continue
        }

        // Trace using the original knockback vector, not current velocity:
        // GoldSrc may already have zeroed velocity after resolving the wall hit.
        new Float:knock[3]
        knock[0] = g_MechWallCheckOrigin[id][0]
        knock[1] = g_MechWallCheckOrigin[id][1]
        knock[2] = g_MechWallCheckOrigin[id][2]
        new Float:knockLen = floatsqroot(knock[0]*knock[0] + knock[1]*knock[1] + knock[2]*knock[2])
        if(knockLen < 1.0) { g_MechWallBounce[id] = false; continue; }
        new Float:end[3]
        end[0] = org[0] + knock[0] / knockLen * 28.0
        end[1] = org[1] + knock[1] / knockLen * 28.0
        end[2] = org[2] + knock[2] / knockLen * 28.0
        new trace = create_tr2()
        engfunc(EngFunc_TraceHull, org, end, IGNORE_MONSTERS, HULL_HUMAN, id, trace)
        new Float:fraction; get_tr2(trace, TR_flFraction, fraction)
        new Float:normal[3]; get_tr2(trace, TR_vecPlaneNormal, normal)
        new bool:hitWall = (fraction < 1.0 && floatabs(normal[2]) < 0.70)
        free_tr2(trace)

        if(hitWall)
        {
            g_AchWallBouncePending[id]=true;
            g_AchWallBounceUntil[id]=get_gametime()+3.0;
            g_AchWallBounceLethal[id]=false;
            g_AchFallPending[id]=false;
            if(g_AchKickOwner[id]>0)
            {
                ach_add(g_AchKickOwner[id],38,1);
                g_AchBonelessOwner[id]=g_AchKickOwner[id];
                g_AchBonelessUntil[id]=get_gametime()+3.0;
                g_AchKickOwner[id] = 0;
            }
            new Float:dot = knock[0]*normal[0] + knock[1]*normal[1] + knock[2]*normal[2]
            knock[0] = (knock[0] - 2.0*dot*normal[0]) * MECH_WALL_BOUNCE
            knock[1] = (knock[1] - 2.0*dot*normal[1]) * MECH_WALL_BOUNCE
            knock[2] = (knock[2] - 2.0*dot*normal[2]) * MECH_WALL_BOUNCE
            set_pev(id, pev_velocity, knock)
            ExecuteHamB(Ham_TakeDamage, id, 0, 0, MECH_WALL_DAMAGE, DMG_FALL | ACH_DMG_WALL_BOUNCE)
            g_MechWallBounce[id] = false
        }
    }
}

// ============================================================
// RESET KICK
// ============================================================

public p2_Reset_Kick(taskid)
{
    new p2_id = taskid - p2_TASK_KICK
    if(p2_id < 1 || p2_id > p2_g_MaxPlayers || !is_user_connected(p2_id))
        return
    p2_g_CanKick[p2_id] = 1
    p2_g_Kicking[p2_id] = 0
    if(g_MechBackKickSlowUntil[p2_id] > 0.0 && get_gametime() >= g_MechBackKickSlowUntil[p2_id])
    {
        g_MechBackKickSlowUntil[p2_id] = 0.0
        if(is_user_alive(p2_id) && !Mech_IsStunned(p2_id))
            p1_ApplyMelee(p2_id)
    }
}

// End the visible kick animation after one second, independently of the 8s cooldown.
public p2_EndKickAnimation(taskid)
{
    new p2_id = taskid - p2_TASK_KICK_ANIM
    if(p2_id < 1 || p2_id > p2_g_MaxPlayers || !is_user_connected(p2_id))
        return

    p2_g_Kicking[p2_id] = 0
    p2_Set_Entity_Invisible(p2_id, 0)
    p2_Set_Entity_Invisible(p2_g_KickAnimEnt[p2_id], 1)
    p2_Set_Entity_Invisible(p2_g_KickAvtEnt[p2_id], 1)
    set_pev(p2_id, pev_viewmodel2, p2_g_OldModel[p2_id])
}

// Green kick cooldown countdown, displayed above the heavy cooldown.
public p2_ShowKickCountdown(taskid)
{
    new id = taskid - p2_TASK_KICK_HUD
    if(id < 1 || id > 32 || !is_user_alive(id)) return
    new Float:now=get_gametime()
    new Float:a=p2_g_KickReadyAt[id][0]-now
    new Float:b=p2_g_KickReadyAt[id][1]-now
    new Float:c=p2_g_KickReadyAt[id][2]-now
    if(a<0.0) a=0.0; if(b<0.0) b=0.0; if(c<0.0) c=0.0
    if(a<=0.0 && b<=0.0 && c<=0.0) return
    set_hudmessage(0, 255, 0, -1.0, 0.075, 0, 0.0, 0.12, 0.0, 0.0, -1)
    show_hudmessage(id, "BASIC KICK %.1f | LOW KICK %.1f | BACK KICK %.1f", a, b, c)
}

// ============================================================
// PLAYER ANIMATION
// ============================================================

public p2_Handle_PlayerAnim(p2_id)
{
p2_Create_AvtEnt(p2_id)
p2_Create_AnimEnt(p2_id)

// Hide real player while animation entity is shown.
p2_Set_Entity_Invisible(
	p2_id,
	1
)

static Float:p2_Origin[3]
static Float:p2_Angles[3]
static Float:p2_Velocity[3]

pev(
	p2_id,
	pev_origin,
	p2_Origin
)

pev(
	p2_id,
	pev_angles,
	p2_Angles
)

pev(
	p2_id,
	pev_velocity,
	p2_Velocity
)

// Set animation entity position.
set_pev(
	p2_g_KickAnimEnt[p2_id],
	pev_origin,
	p2_Origin
)

p2_Angles[0] = 0.0
p2_Angles[2] = 0.0

set_pev(
	p2_g_KickAnimEnt[p2_id],
	pev_angles,
	p2_Angles
)

set_pev(
	p2_g_KickAnimEnt[p2_id],
	pev_velocity,
	p2_Velocity
)

// Attach avatar.
set_pev(
	p2_g_KickAvtEnt[p2_id],
	pev_aiment,
	p2_g_KickAnimEnt[p2_id]
)

p2_Set_Entity_Invisible(
	p2_g_KickAvtEnt[p2_id],
	0
)

p2_Set_Entity_Anim(
	p2_g_KickAnimEnt[p2_id],
	0,
	1
)

// Kick sound.
emit_sound(
	p2_id,
	CHAN_BODY,
	p2_KICK_SOUND,
	1.0,
	ATTN_NORM,
	0,
	PITCH_NORM
)

}

// ============================================================
// CREATE PLAYER AVATAR
// ============================================================

public p2_Create_AvtEnt(p2_id)
{
if(pev_valid(p2_g_KickAvtEnt[p2_id]))
return

p2_g_KickAvtEnt[p2_id] = engfunc(
	EngFunc_CreateNamedEntity,
	engfunc(
		EngFunc_AllocString,
		"info_target"
	)
)

if(!pev_valid(p2_g_KickAvtEnt[p2_id]))
	return

new p2_ent = p2_g_KickAvtEnt[p2_id]

set_pev(
	p2_ent,
	pev_classname,
	"kickavatar"
)

set_pev(
	p2_ent,
	pev_owner,
	p2_id
)

set_pev(
	p2_ent,
	pev_movetype,
	MOVETYPE_FOLLOW
)

set_pev(
	p2_ent,
	pev_solid,
	SOLID_NOT
)

// Get player model.
static p2_PlayerModel[64]

p2_fm_cs_get_user_model(
	p2_id,
	p2_PlayerModel,
	charsmax(p2_PlayerModel)
)

format(
	p2_PlayerModel,
	charsmax(p2_PlayerModel),
	"models/player/%s/%s.mdl",
	p2_PlayerModel,
	p2_PlayerModel
)

engfunc(
	EngFunc_SetModel,
	p2_ent,
	p2_PlayerModel
)

// Copy player appearance.
set_pev(
	p2_ent,
	pev_body,
	pev(p2_id, pev_body)
)

set_pev(
	p2_ent,
	pev_skin,
	pev(p2_id, pev_skin)
)

set_pev(
	p2_ent,
	pev_renderamt,
	pev(p2_id, pev_renderamt)
)

static Float:p2_Color[3]

pev(
	p2_id,
	pev_rendercolor,
	p2_Color
)

set_pev(
	p2_ent,
	pev_rendercolor,
	p2_Color
)

set_pev(
	p2_ent,
	pev_renderfx,
	pev(p2_id, pev_renderfx)
)

set_pev(
	p2_ent,
	pev_rendermode,
	pev(p2_id, pev_rendermode)
)

p2_Set_Entity_Invisible(
	p2_ent,
	0
)

}

// ============================================================
// CREATE KICK ANIMATION ENTITY
// ============================================================

public p2_Create_AnimEnt(p2_id)
{
if(pev_valid(p2_g_KickAnimEnt[p2_id]))
return

p2_g_KickAnimEnt[p2_id] = engfunc(
	EngFunc_CreateNamedEntity,
	engfunc(
		EngFunc_AllocString,
		"info_target"
	)
)

if(!pev_valid(p2_g_KickAnimEnt[p2_id]))
	return

new p2_ent = p2_g_KickAnimEnt[p2_id]

set_pev(
	p2_ent,
	pev_classname,
	"KickAnim"
)

set_pev(
	p2_ent,
	pev_owner,
	p2_id
)

set_pev(
	p2_ent,
	pev_movetype,
	MOVETYPE_TOSS
)

engfunc(
	EngFunc_SetModel,
	p2_ent,
	p2_KICK_PMODEL
)

engfunc(
	EngFunc_SetSize,
	p2_ent,
	Float:{-16.0, -16.0, -36.0},
	Float:{16.0, 16.0, 36.0}
)

set_pev(
	p2_ent,
	pev_solid,
	SOLID_NOT
)

engfunc(
	EngFunc_DropToFloor,
	p2_ent
)

p2_Set_Entity_Invisible(
	p2_ent,
	0
)

set_pev(
	p2_ent,
	pev_nextthink,
	get_gametime() + 0.1
)

}

// ============================================================
// WEAPON ANIMATION
// ============================================================

stock p2_Set_WeaponAnim(p2_id, anim)
{
set_pev(
p2_id,
pev_weaponanim,
anim
)

message_begin(
	MSG_ONE_UNRELIABLE,
	SVC_WEAPONANIM,
	_,
	p2_id
)

write_byte(anim)
write_byte(0)

message_end()

}

// ============================================================
// NEXT ATTACK
// ============================================================

stock p2_Set_Player_NextAttack(p2_id, Float:Time)
{
if(pev_valid(p2_id) != 2)
return

set_pdata_float(
	p2_id,
	83,
	Time,
	5
)

}

// ============================================================
// GET PLAYER MODEL
// ============================================================

stock p2_fm_cs_get_user_model(p2_id, Model[], Len)
{
if(!is_user_connected(p2_id))
return

engfunc(
	EngFunc_InfoKeyValue,
	engfunc(
		EngFunc_GetInfoKeyBuffer,
		p2_id
	),
	"model",
	Model,
	Len
)

}

// ============================================================
// INVISIBILITY
// ============================================================

stock p2_Set_Entity_Invisible(p2_ent, Invisible = 1)
{
if(!pev_valid(p2_ent))
return

if(!Invisible)
{
	set_pev(
		p2_ent,
		pev_renderamt,
		16.0
	)

	set_pev(
		p2_ent,
		pev_rendercolor,
		Float:{0.0, 0.0, 0.0}
	)

	set_pev(
		p2_ent,
		pev_renderfx,
		kRenderFxNone
	)

	set_pev(
		p2_ent,
		pev_rendermode,
		kRenderNormal
	)
}
else
{
	set_pev(
		p2_ent,
		pev_renderamt,
		0.0
	)

	set_pev(
		p2_ent,
		pev_rendercolor,
		Float:{0.0, 0.0, 0.0}
	)

	set_pev(
		p2_ent,
		pev_renderfx,
		kRenderFxNone
	)

	set_pev(
		p2_ent,
		pev_rendermode,
		kRenderTransAlpha
	)
}

}

// ============================================================
// ENTITY ANIMATION
// ============================================================

stock p2_Set_Entity_Anim(p2_ent, Anim, ResetFrame)
{
if(!pev_valid(p2_ent))
return

set_pev(
	p2_ent,
	pev_animtime,
	get_gametime()
)

set_pev(
	p2_ent,
	pev_framerate,
	1.5
)

set_pev(
	p2_ent,
	pev_sequence,
	Anim
)

if(ResetFrame)
{
	set_pev(
		p2_ent,
		pev_frame,
		0
	)
}

}

// ============================================================
// 3D SPEED VECTOR
// ============================================================

stock p2_Get_SpeedVector(
const Float:origin1[3],
const Float:origin2[3],
Float:speed,
Float:new_velocity[3]
)
{
new_velocity[0] = origin2[0] - origin1[0]
new_velocity[1] = origin2[1] - origin1[1]
new_velocity[2] = origin2[2] - origin1[2]

new Float:p2_Length

p2_Length = floatsqroot(
	new_velocity[0] * new_velocity[0] +
	new_velocity[1] * new_velocity[1] +
	new_velocity[2] * new_velocity[2]
)

if(p2_Length <= 0.0)
{
	new_velocity[0] = 0.0
	new_velocity[1] = 0.0
	new_velocity[2] = 0.0
	return
}

new Float:p2_Multiplier

p2_Multiplier = speed / p2_Length

new_velocity[0] *= p2_Multiplier
new_velocity[1] *= p2_Multiplier
new_velocity[2] *= p2_Multiplier


}






/*
 * ============================================================
 * LIGHT ATTACK EXHAUSTION
 * ============================================================
 *
 * The system has TWO completely separate values:
 *
 * 1. EXHAUSTION:
 *    Extra milliseconds added to the NORMAL knife light-attack
 *    interval.
 *
 * 2. REST:
 *    How long the player must stop making light attacks before
 *    the entire exhaustion chain is reset.
 *
 * ATTACK CHAIN:
 *
 * Attack 1-3 = normal
 * Attack 4   = +1x configured delay
 * Attack 5   = +2x configured delay
 * Attack 6   = +3x configured delay
 * ...
 * Attack 10  = normal / forced rest (per-weapon setting)
 *
 * Before exhaustion starts, a 1-second gap is enough to reset
 * the current chain.
 *
 * The damage movement slowdown is also removed.
 *
 * No custom resources are required.
 */

/* ============================================================
 * PER-WEAPON EXHAUSTION CONFIGURATION
 * All delay/rest values are milliseconds. Hit thresholds are per
 * selected melee weapon. Edit each weapon independently.
 * ============================================================ */
#define p3_KNIFE_EXHAUST_HITS       3
#define p3_KNIFE_EXHAUST_MS         37
#define p3_KNIFE_FORCED_HIT         10
#define p3_KNIFE_RESET_REST_MS      4000

#define p3_KATANA_EXHAUST_HITS      3
#define p3_KATANA_EXHAUST_MS        22
#define p3_KATANA_FORCED_HIT        10
#define p3_KATANA_RESET_REST_MS     4000

#define p3_PAN_EXHAUST_HITS         3
#define p3_PAN_EXHAUST_MS           43
#define p3_PAN_FORCED_HIT           10
#define p3_PAN_RESET_REST_MS        4000

#define p3_LONGSWORD_EXHAUST_HITS   1
#define p3_LONGSWORD_EXHAUST_MS     76
#define p3_LONGSWORD_FORCED_HIT     10
#define p3_LONGSWORD_RESET_REST_MS  4000

#define p3_HAMMER_EXHAUST_HITS      1
#define p3_HAMMER_EXHAUST_MS        80
#define p3_HAMMER_FORCED_HIT        10
#define p3_HAMMER_RESET_REST_MS     4000

#define p3_CLAWS_EXHAUST_HITS       3
#define p3_CLAWS_EXHAUST_MS         15
#define p3_CLAWS_FORCED_HIT         20
#define p3_CLAWS_RESET_REST_MS      6000

#define p3_BAT_EXHAUST_HITS         3
#define p3_BAT_EXHAUST_MS           57
#define p3_BAT_FORCED_HIT           10
#define p3_BAT_RESET_REST_MS        4000

#define p3_AXE_EXHAUST_HITS         2
#define p3_AXE_EXHAUST_MS           67
#define p3_AXE_FORCED_HIT           10
#define p3_AXE_RESET_REST_MS        4000

#define p3_SAIS_EXHAUST_HITS        3
#define p3_SAIS_EXHAUST_MS          16
#define p3_SAIS_FORCED_HIT          20
#define p3_SAIS_RESET_REST_MS       6000

#define p3_NAGINATA_EXHAUST_HITS    1
#define p3_NAGINATA_EXHAUST_MS      58
#define p3_NAGINATA_FORCED_HIT      10
#define p3_NAGINATA_RESET_REST_MS   4000

#define p3_GLADIUS_EXHAUST_HITS     2
#define p3_GLADIUS_EXHAUST_MS       35
#define p3_GLADIUS_FORCED_HIT       10
#define p3_GLADIUS_RESET_REST_MS    4000

#define p3_SCYTHE_EXHAUST_HITS      1
#define p3_SCYTHE_EXHAUST_MS        50
#define p3_SCYTHE_FORCED_HIT        10
#define p3_SCYTHE_RESET_REST_MS     4000

#define p3_GREATSWORD_EXHAUST_HITS      0
#define p3_GREATSWORD_EXHAUST_MS        500
#define p3_GREATSWORD_FORCED_HIT        5
#define p3_GREATSWORD_RESET_REST_MS     4000

#define p3_GLAIVE_EXHAUST_HITS      1
#define p3_GLAIVE_EXHAUST_MS        47
#define p3_GLAIVE_FORCED_HIT        10
#define p3_GLAIVE_RESET_REST_MS     4000

#define p3_GAUNTLETS_EXHAUST_HITS      6
#define p3_GAUNTLETS_EXHAUST_MS        18
#define p3_GAUNTLETS_FORCED_HIT        20
#define p3_GAUNTLETS_RESET_REST_MS     6000

#define p3_CLEAVER_EXHAUST_HITS      1
#define p3_CLEAVER_EXHAUST_MS        50
#define p3_CLEAVER_FORCED_HIT        10
#define p3_CLEAVER_RESET_REST_MS     4000


#define p3_PRE_EXHAUST_REST          1.0
#define p3_OFFSET_NEXT_PRIMARY      46
#define p3_OFFSET_NEXT_ATTACK       83
#define p3_OFFSET_VELOCITY          108
#define p3_LINUX_WEAPON              4
#define p3_LINUX_PLAYER              5

stock p3_GetExhaustHits(p3_melee)
{
    switch (p3_melee)
    {
        case p1_MELEE_KATANA: return p3_KATANA_EXHAUST_HITS;
        case p1_MELEE_PAN: return p3_PAN_EXHAUST_HITS;
        case p1_MELEE_LONGSWORD: return p3_LONGSWORD_EXHAUST_HITS;
        case p1_MELEE_HAMMER: return p3_HAMMER_EXHAUST_HITS;
        case p1_MELEE_CLAWS: return p3_CLAWS_EXHAUST_HITS;
        case p1_MELEE_BAT: return p3_BAT_EXHAUST_HITS;
        case p1_MELEE_AXE: return p3_AXE_EXHAUST_HITS;
        case p1_MELEE_SAIS: return p3_SAIS_EXHAUST_HITS;
        case p1_MELEE_NAGINATA: return p3_NAGINATA_EXHAUST_HITS;
        case p1_MELEE_GLADIUS: return p3_GLADIUS_EXHAUST_HITS;
        case p1_MELEE_SCYTHE: return p3_SCYTHE_EXHAUST_HITS;
        case p1_MELEE_GREATSWORD: return p3_GREATSWORD_EXHAUST_HITS;
        case p1_MELEE_GLAIVE: return p3_GLAIVE_EXHAUST_HITS;
        case p1_MELEE_GAUNTLETS: return p3_GAUNTLETS_EXHAUST_HITS;
        case p1_MELEE_CLEAVER: return p3_CLEAVER_EXHAUST_HITS;
    }
    return p3_KNIFE_EXHAUST_HITS;
}

stock p3_GetExhaustMs(p3_melee)
{
    switch (p3_melee)
    {
        case p1_MELEE_KATANA: return p3_KATANA_EXHAUST_MS;
        case p1_MELEE_PAN: return p3_PAN_EXHAUST_MS;
        case p1_MELEE_LONGSWORD: return p3_LONGSWORD_EXHAUST_MS;
        case p1_MELEE_HAMMER: return p3_HAMMER_EXHAUST_MS;
        case p1_MELEE_CLAWS: return p3_CLAWS_EXHAUST_MS;
        case p1_MELEE_BAT: return p3_BAT_EXHAUST_MS;
        case p1_MELEE_AXE: return p3_AXE_EXHAUST_MS;
        case p1_MELEE_SAIS: return p3_SAIS_EXHAUST_MS;
        case p1_MELEE_NAGINATA: return p3_NAGINATA_EXHAUST_MS;
        case p1_MELEE_GLADIUS: return p3_GLADIUS_EXHAUST_MS;
        case p1_MELEE_SCYTHE: return p3_SCYTHE_EXHAUST_MS;
        case p1_MELEE_GREATSWORD: return p3_GREATSWORD_EXHAUST_MS;
        case p1_MELEE_GLAIVE: return p3_GLAIVE_EXHAUST_MS;
        case p1_MELEE_GAUNTLETS: return p3_GAUNTLETS_EXHAUST_MS;
        case p1_MELEE_CLEAVER: return p3_CLEAVER_EXHAUST_MS;
    }
    return p3_KNIFE_EXHAUST_MS;
}

stock p3_GetForcedHit(p3_melee)
{
    switch (p3_melee)
    {
        case p1_MELEE_KATANA: return p3_KATANA_FORCED_HIT;
        case p1_MELEE_PAN: return p3_PAN_FORCED_HIT;
        case p1_MELEE_LONGSWORD: return p3_LONGSWORD_FORCED_HIT;
        case p1_MELEE_HAMMER: return p3_HAMMER_FORCED_HIT;
        case p1_MELEE_CLAWS: return p3_CLAWS_FORCED_HIT;
        case p1_MELEE_BAT: return p3_BAT_FORCED_HIT;
        case p1_MELEE_AXE: return p3_AXE_FORCED_HIT;
        case p1_MELEE_SAIS: return p3_SAIS_FORCED_HIT;
        case p1_MELEE_NAGINATA: return p3_NAGINATA_FORCED_HIT;
        case p1_MELEE_GLADIUS: return p3_GLADIUS_FORCED_HIT;
        case p1_MELEE_SCYTHE: return p3_SCYTHE_FORCED_HIT;
        case p1_MELEE_GREATSWORD: return p3_GREATSWORD_FORCED_HIT;
        case p1_MELEE_GLAIVE: return p3_GLAIVE_FORCED_HIT;
        case p1_MELEE_GAUNTLETS: return p3_GAUNTLETS_FORCED_HIT;
        case p1_MELEE_CLEAVER: return p3_CLEAVER_FORCED_HIT;
    }
    return p3_KNIFE_FORCED_HIT;
}

stock Float:p3_GetResetRest(p3_melee)
{
    switch (p3_melee)
    {
        case p1_MELEE_KATANA: return float(p3_KATANA_RESET_REST_MS) / 1000.0;
        case p1_MELEE_PAN: return float(p3_PAN_RESET_REST_MS) / 1000.0;
        case p1_MELEE_LONGSWORD: return float(p3_LONGSWORD_RESET_REST_MS) / 1000.0;
        case p1_MELEE_HAMMER: return float(p3_HAMMER_RESET_REST_MS) / 1000.0;
        case p1_MELEE_CLAWS: return float(p3_CLAWS_RESET_REST_MS) / 2000.0;
        case p1_MELEE_BAT: return float(p3_BAT_RESET_REST_MS) / 1000.0;
        case p1_MELEE_AXE: return float(p3_AXE_RESET_REST_MS) / 1000.0;
        case p1_MELEE_SAIS: return float(p3_SAIS_RESET_REST_MS) / 2000.0;
        case p1_MELEE_NAGINATA: return float(p3_NAGINATA_RESET_REST_MS) / 1000.0;
        case p1_MELEE_GLADIUS: return float(p3_GLADIUS_RESET_REST_MS) / 1000.0;
        case p1_MELEE_SCYTHE: return float(p3_SCYTHE_RESET_REST_MS) / 1000.0;
        case p1_MELEE_GREATSWORD: return float(p3_GREATSWORD_RESET_REST_MS) / 1000.0;
        case p1_MELEE_GLAIVE: return float(p3_GLAIVE_RESET_REST_MS) / 1000.0;
        case p1_MELEE_GAUNTLETS: return float(p3_GAUNTLETS_RESET_REST_MS) / 2000.0;
        case p1_MELEE_CLEAVER: return float(p3_CLEAVER_RESET_REST_MS) / 1000.0;
    }
    return float(p3_KNIFE_RESET_REST_MS) / 1000.0;
}

/*
 * ============================================================
 * PDATA
 * ============================================================
 *
 * CBasePlayerWeapon::m_flNextPrimaryAttack
 * CBasePlayer::m_flNextAttack
 *
 * Linux offsets are +4 for weapons and +5 for players.
 */



/* ============================================================
 * PLAYER STATE
 * ============================================================ */

new p3_g_iAttackCount[33][p1_MELEE_COUNT]

/*
 * Last successful knife primary attack.
 */
new Float:p3_g_flLastAttack[33][p1_MELEE_COUNT]

/*
 * Current amount of time the player must stop attacking
 * before the chain resets.
 */
new Float:p3_g_flRestRequired[33][p1_MELEE_COUNT]

/*
 * Hit #10 forced-rest state.
 */
new bool:p3_g_bForcedRest[33][p1_MELEE_COUNT]

new Float:p3_g_flForcedRestEnd[33][p1_MELEE_COUNT]


/* ============================================================
 * INIT
 * ============================================================ */

public p3_plugin_init()
{

    /*
     * PRE:
     * - Block the knife attack during forced rest.
     *
     * POST:
     * - Count the actual knife primary attack.
     * - Add exhaustion to CS's already-calculated attack timer.
     */
    RegisterHam(
        Ham_Weapon_PrimaryAttack,
        "weapon_knife",
        "p3_KnifePrimaryAttack_Pre",
        0
    )

    RegisterHam(
        Ham_Weapon_PrimaryAttack,
        "weapon_knife",
        "p3_KnifePrimaryAttack_Post",
        1
    )

    /*
     * Remove the normal damage movement slowdown.
     */
    RegisterHam(
        Ham_TakeDamage,
        "player",
        "p3_TakeDamage_Post",
        1
    )

    /*
     * Used for:
     * - forced-rest attack blocking as a second safeguard
     * - automatic rest recovery
     */
    register_forward(FM_CmdStart, "p3_fw_CmdStart")
}


/* ============================================================
 * KNIFE PRIMARY ATTACK - PRE
 * ============================================================ */

public p3_KnifePrimaryAttack_Pre(weapon)
{
    if (!pev_valid(weapon))
        return HAM_IGNORED

    new p3_id = pev(weapon, pev_owner)

    if (!is_user_alive(p3_id))
        return HAM_IGNORED

    new p3_melee = p1_g_Melee[p3_id]
    if (p3_melee < p1_MELEE_KNIFE || p3_melee >= p1_MELEE_COUNT)
        p3_melee = p1_MELEE_KNIFE

    /*
     * At hit #10 the player is forced to stop attacking for
     * exactly 4 seconds.
     *
     * Block the actual weapon attack here.
     */
    if (p3_g_bForcedRest[p3_id][p3_melee])
    {
        if (get_gametime() < p3_g_flForcedRestEnd[p3_id][p3_melee])
            return HAM_SUPERCEDE

        /*
         * The forced rest has ended.
         */
        p3_ResetWeapon(p3_id, p3_melee)
    }

    return HAM_IGNORED
}


/* ============================================================
 * KNIFE PRIMARY ATTACK - POST
 * ============================================================ */

public p3_KnifePrimaryAttack_Post(weapon)
{
    if (!pev_valid(weapon))
        return HAM_IGNORED

    new p3_id = pev(weapon, pev_owner)

    if (!is_user_alive(p3_id))
        return HAM_IGNORED

    new p3_melee = p1_g_Melee[p3_id]
    if (p3_melee < p1_MELEE_KNIFE || p3_melee >= p1_MELEE_COUNT)
        p3_melee = p1_MELEE_KNIFE

    /*
     * If the attack was supposed to be blocked, don't count it.
     */
    if (p3_g_bForcedRest[p3_id][p3_melee])
        return HAM_IGNORED

    // Count every real primary attack, including swings that miss.
    // Exhaustion is based on attack cadence, not successful damage.

    new Float:p3_now = get_gametime()

    /*
     * ========================================================
     * REST CHECK
     * ========================================================
     *
     * If the player already stayed away from attacking for the
     * complete required rest time, this attack begins a fresh
     * chain and is therefore Hit #1.
     */

    if (p3_g_iAttackCount[p3_id][p3_melee] > 0)
    {
        if ((p3_now - p3_g_flLastAttack[p3_id][p3_melee]) >= p3_g_flRestRequired[p3_id][p3_melee])
        {
            p3_ResetWeapon(p3_id, p3_melee)
        }
    }

    /*
     * ========================================================
     * COUNT THIS ATTACK
     * ========================================================
     */

    p3_g_iAttackCount[p3_id][p3_melee]++
    p3_g_flLastAttack[p3_id][p3_melee] = p3_now

    /*
     * ========================================================
     * HIT #1-3
     * ========================================================
     *
     * Completely normal attack speed.
     *
     * A 1-second gap is enough to reset the chain.
     */

    new p3_exhaustStart = p3_GetExhaustHits(p1_g_Melee[p3_id])
    if (p3_g_iAttackCount[p3_id][p3_melee] <= p3_exhaustStart)
    {
        p3_g_flRestRequired[p3_id][p3_melee] = p3_PRE_EXHAUST_REST

        return HAM_IGNORED
    }

    /*
     * ========================================================
     * HIT #10
     * ========================================================
     *
     * No extra exhaustion is added to hit #10.
     *
     * Instead, the player is forced to rest for 4 seconds.
     */

    new p3_attackCap = p3_GetForcedHit(p1_g_Melee[p3_id])
    if (p3_g_iAttackCount[p3_id][p3_melee] >= p3_attackCap)
    {
        p3_g_bForcedRest[p3_id][p3_melee] = true
        g_AchProgress[p3_id][7]++;
        if(g_AchProgress[p3_id][7]>=5) ach_set(p3_id,7);
        ach_save(p3_id);
        p3_g_flForcedRestEnd[p3_id][p3_melee] = p3_now + p3_GetResetRest(p1_g_Melee[p3_id])

        /*
         * Stop the knife immediately for the forced-rest period.
         *
         * These are relative times, which is exactly what the
         * Counter-Strike weapon/player pdata fields expect.
         */
        set_pdata_float(
            weapon,
            p3_OFFSET_NEXT_PRIMARY,
            p3_GetResetRest(p1_g_Melee[p3_id]),
            p3_LINUX_WEAPON
        )

        set_pdata_float(
            p3_id,
            p3_OFFSET_NEXT_ATTACK,
            p3_GetResetRest(p1_g_Melee[p3_id]),
            p3_LINUX_PLAYER
        )

        return HAM_IGNORED
    }

    /*
     * ========================================================
     * EXHAUSTION
     * ========================================================
     *
     * Hit 4 = level 1 = +15ms
     * Hit 5 = level 2 = +30ms
     * Hit 6 = level 3 = +45ms
     * ...
     * Hit 9 = level 6 = +90ms
     */

    new p3_exhaustionLevel =
        p3_g_iAttackCount[p3_id][p3_melee] - p3_exhaustStart

    new Float:p3_extraDelay =
        float(p3_exhaustionLevel * p3_GetExhaustMs(p1_g_Melee[p3_id])) / 1000.0

    /*
     * IMPORTANT:
     *
     * Counter-Strike has ALREADY calculated the normal knife
     * attack interval.
     *
     * We do NOT replace it.
     *
     * We simply add our tiny exhaustion delay to the existing
     * value.
     */

    new Float:p3_nextPrimary =
        get_pdata_float(
            weapon,
            p3_OFFSET_NEXT_PRIMARY,
            p3_LINUX_WEAPON
        )

    /*
     * In case a custom knife plugin leaves this timer at a
     * non-positive value, still make sure the added exhaustion
     * is applied.
     */
    if (p3_nextPrimary < 0.0)
        p3_nextPrimary = 0.0

    p3_nextPrimary += p3_extraDelay

    set_pdata_float(
        weapon,
        p3_OFFSET_NEXT_PRIMARY,
        p3_nextPrimary,
        p3_LINUX_WEAPON
    )

    /*
     * ========================================================
     * INDEPENDENT REST TIME
     * ========================================================
     *
     * Hit 4 = 2.00s
     * Hit 5 = 2.33s
     * Hit 6 = 2.67s
     * Hit 7 = 3.00s
     * Hit 8 = 3.33s
     * Hit 9 = 3.67s
     */

    p3_g_flRestRequired[p3_id][p3_melee] =
        p3_GetResetRest(p1_g_Melee[p3_id])

    if (p3_g_flRestRequired[p3_id][p3_melee] < p3_PRE_EXHAUST_REST)
        p3_g_flRestRequired[p3_id][p3_melee] = p3_PRE_EXHAUST_REST

    return HAM_IGNORED
}


/* ============================================================
 * CMD START
 * ============================================================ */

public p3_fw_CmdStart(p3_id, uc_handle, seed)
{
    if (!is_user_alive(p3_id))
        return FMRES_IGNORED

    new Float:p3_now = get_gametime()
    new p3_melee = p1_g_Melee[p3_id]
    if (p3_melee < p1_MELEE_KNIFE || p3_melee >= p1_MELEE_COUNT)
        p3_melee = p1_MELEE_KNIFE

    /*
     * ========================================================
     * FORCED REST
     * ========================================================
     */

    if (p3_g_bForcedRest[p3_id][p3_melee])
    {
        /*
         * Four seconds have elapsed.
         */
        if (p3_now >= p3_g_flForcedRestEnd[p3_id][p3_melee])
        {
            p3_ResetWeapon(p3_id, p3_melee)

            return FMRES_IGNORED
        }

        /*
         * Block IN_ATTACK while the forced rest is active.
         */
        new p3_buttons = get_uc(
            uc_handle,
            UC_Buttons
        )

        if (p3_buttons & IN_ATTACK)
        {
            p3_buttons &= ~IN_ATTACK

            set_uc(
                uc_handle,
                UC_Buttons,
                p3_buttons
            )

            return FMRES_HANDLED
        }

        return FMRES_IGNORED
    }

    /*
     * ========================================================
     * NORMAL REST RECOVERY
     * ========================================================
     *
     * This is checked continuously, so the reset happens as
     * soon as the player has genuinely stayed away from attacking
     * long enough.
     */

    if (p3_g_iAttackCount[p3_id][p3_melee] > 0)
    {
        if ((p3_now - p3_g_flLastAttack[p3_id][p3_melee]) >= p3_g_flRestRequired[p3_id][p3_melee])
        {
            p3_ResetWeapon(p3_id, p3_melee)
        }
    }

    return FMRES_IGNORED
}


/* ============================================================
 * REMOVE DAMAGE SLOWDOWN
 * ============================================================ */

public p3_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damagebits)
{
    if (!is_user_connected(victim))
        return HAM_IGNORED

    /*
     * Counter-Strike changes m_flVelocityModifier when a player
     * is damaged.
     *
     * 1.0 = full normal movement modifier.
     */
    set_pdata_float(
        victim,
        p3_OFFSET_VELOCITY,
        1.0,
        p3_LINUX_PLAYER
    )

    return HAM_IGNORED
}


/* ============================================================
 * RESET
 * ============================================================ */

p3_ResetWeapon(p3_id, p3_melee)
{
    if (p3_melee < p1_MELEE_KNIFE || p3_melee >= p1_MELEE_COUNT)
        return

    p3_g_iAttackCount[p3_id][p3_melee] = 0
    p3_g_flLastAttack[p3_id][p3_melee] = 0.0
    p3_g_flRestRequired[p3_id][p3_melee] = 0.0
    p3_g_bForcedRest[p3_id][p3_melee] = false
    p3_g_flForcedRestEnd[p3_id][p3_melee] = 0.0
}

p3_ResetPlayer(p3_id)
{
    for (new p3_melee = p1_MELEE_KNIFE; p3_melee < p1_MELEE_COUNT; p3_melee++)
        p3_ResetWeapon(p3_id, p3_melee)
}


/* ============================================================
 * PLAYER CONNECTION
 * ============================================================ */

public p3_client_putinserver(p3_id)
{
    p3_ResetPlayer(p3_id)
}

public p3_client_disconnect(p3_id)
{
    p3_ResetPlayer(p3_id)
}

public p3_client_death(p3_id)
{
    p3_ResetPlayer(p3_id)
}






// CONFIG
#define p4_PARRY_WINDOW 0.20
#define p4_PARRY_COOLDOWN 2.0
#define p4_STUN_TIME 0.50
#define p4_STUN_SPEED 100.0
#define p4_TASK_STUN 9100

#define p4_SOUND_PARRY "sound/parry.wav"
#define p4_SOUND_MISS "sound/parry_miss.wav"

new Float:p4_g_LastParry[33]
new Float:p4_g_AttackLockEnd[33]
#define p4_PARRY_ATTACK_LOCK 0.67

new Float:p4_g_PreStunSpeed[33]
new p4_g_msgScreenFade

// ==========================

public p4_plugin_init()
{

    register_clcmd("parry", "p4_cmd_parry")
    register_forward(FM_CmdStart, "p4_fw_CmdStart")
    register_forward(FM_PlayerPreThink, "p4_fw_PreThink")

    RegisterHam(Ham_TakeDamage, "player", "p4_fw_TakeDamage")
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "p4_fw_KnifeAttack")

    p4_g_msgScreenFade = get_user_msgid("ScreenFade")
}

// ==========================

public p4_plugin_precache()
{
    precache_sound("parry.wav")
    precache_sound("parry_miss.wav")

    precache_generic(p4_SOUND_PARRY)
    precache_generic(p4_SOUND_MISS)
}

// ==========================

public p4_cmd_parry(p4_id)
{
    if(!is_user_alive(p4_id) || Mech_IsStunned(p4_id)) return PLUGIN_HANDLED
    new Float:now = get_gametime()
    if(now - p4_g_LastParry[p4_id] >= p4_PARRY_COOLDOWN)
    {
        p4_g_LastParry[p4_id] = now
        p4_g_ParryActive[p4_id] = true
        p4_g_ParryAttempt[p4_id] = true
        p4_g_AttackLockEnd[p4_id] = now + p4_PARRY_ATTACK_LOCK
        p4_PlayKnifeAnim(p4_id)
        remove_task(p4_id)
        set_task(p4_PARRY_WINDOW, "p4_ParryMissCheck", p4_id)
    }
    return PLUGIN_HANDLED
}

public p4_fw_CmdStart(p4_id, uc_handle, seed)
{
    if(!is_user_alive(p4_id))
    {
        p4_g_LastHookButtons[p4_id] = 0
        return FMRES_IGNORED
    }

    new p4_handled = 0

    // --------------------------------------------------------
    // PARRY: same engine impulse used by the flashlight (F).
    // --------------------------------------------------------
    if(get_uc(uc_handle, UC_Impulse) == 100)
    {
        if(!Mech_IsStunned(p4_id))
        {
            new Float:p4_time = get_gametime()
            if(p4_time - p4_g_LastParry[p4_id] >= p4_PARRY_COOLDOWN)
            {
                p4_g_LastParry[p4_id] = p4_time
                p4_g_ParryActive[p4_id] = true
                p4_g_ParryAttempt[p4_id] = true
                p4_g_AttackLockEnd[p4_id] = p4_time + p4_PARRY_ATTACK_LOCK
                p4_PlayKnifeAnim(p4_id)
                set_task(p4_PARRY_WINDOW, "p4_ParryMissCheck", p4_id)
            }
        }
        set_uc(uc_handle, UC_Impulse, 0)
        p4_handled = 1
    }

    // --------------------------------------------------------
    // HELD INPUTS: R = +reload / IN_RELOAD (backattack).
    // K uses the default +voicerecord/-voicerecord command pair below.
    // Use pev_oldbuttons to detect press and release transitions.
    // Only consume these controls while the custom melee weapon is active.
    // --------------------------------------------------------
    new p4_buttons = get_uc(uc_handle, UC_Buttons)
    // Use the engine's pev_oldbuttons for normal previous-frame state. The
    // saved raw state restores the two intercepted bits, which the engine no
    // longer sees after we consume them from UC_Buttons.
    new p4_oldbuttons = pev(p4_id, pev_oldbuttons)
    p4_oldbuttons = (p4_oldbuttons & ~IN_RELOAD) | (p4_g_LastHookButtons[p4_id] & IN_RELOAD)
    p4_g_LastHookButtons[p4_id] = p4_buttons
    new bool:p4_isMelee = (get_user_weapon(p4_id) == CSW_KNIFE && !p1_IsSuppressed(p4_id))

    if(p4_isMelee)
    {
        // Backattack on R (+reload).
        if((p4_buttons & IN_RELOAD) && !(p4_oldbuttons & IN_RELOAD))
            Mech_BackAttackStart(p4_id)
        else if(!(p4_buttons & IN_RELOAD) && (p4_oldbuttons & IN_RELOAD))
            Mech_BackAttackEnd(p4_id)

        // Consume only R's reload button here. Z block is handled by radio1.
        if(p4_buttons & IN_RELOAD)
        {
            set_uc(uc_handle, UC_Buttons, p4_buttons & ~IN_RELOAD)
            p4_handled = 1
        }
    }
    else
    {
        // Clear stale held states if the player switches away from melee.
        if(g_MechBackAttackHeld[p4_id])
            Mech_BackAttackEnd(p4_id)
    }

    if(Mech_IsStunned(p4_id) && !p4_isMelee && (p4_buttons & IN_USE))
    {
        set_uc(uc_handle, UC_Buttons, p4_buttons & ~IN_USE)
        p4_handled = 1
    }

    return p4_handled ? FMRES_HANDLED : FMRES_IGNORED
}

// ==========================

public p4_ParryMissCheck(p4_id)
{
    if(p4_g_ParryAttempt[p4_id] && p4_g_ParryActive[p4_id])
    {
        emit_sound(p4_id, CHAN_AUTO, "parry_miss.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
    }

    p4_g_ParryActive[p4_id] = false
    p4_g_ParryAttempt[p4_id] = false
    p4_g_bGreatswordBypass[p4_id] = false
}

// ==========================

public p4_fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(!is_user_alive(victim) || !is_user_alive(attacker))
        return HAM_IGNORED

    // Custom melee retaliation (Sais Thorns / Claws micro-bomb) remains a
    // melee hit even if its owner switched weapons during the countdown.
    new bool:isMeleeAttack = (get_user_weapon(attacker) == CSW_KNIFE) || ((damagebits & p1_DMG_CUSTOM_MELEE) != 0)
    new bool:isBulletAttack = (damagebits & DMG_BULLET) != 0
    // Pan alone can parry bullets. Other weapons retain melee-only parrying.
    if(!isMeleeAttack && !(p1_GetCombatMelee(victim) == p1_MELEE_PAN && isBulletAttack))
        return HAM_IGNORED

    if(p4_g_ParryActive[victim])
    {
        // Cleaver execution attempt: the early melee hook may have returned
        // on the parry before it could attach the execution damage flag.
        if((damagebits & p1_CLEAVER_EXECUTE_FLAG) ||
            (get_user_weapon(attacker)==CSW_KNIFE && p1_g_Melee[attacker]==p1_MELEE_CLEAVER &&
             p1_g_AttackType[attacker]==2 && get_user_health(victim)<=p1_CLEAVER_EXECUTE_HP &&
             !p1_IsSuppressed(attacker) && !(damagebits & p1_DMG_CUSTOM_MELEE)))
            ach_set(victim,40)
        ach_on_parry(victim, p1_g_ShockwaveVictim[victim])
        new bool:shockwaveParry = p1_g_ShockwaveVictim[victim]
        new bool:greatswordBypass = p4_g_bGreatswordBypass[victim]
        if(greatswordBypass) ach_add(attacker,48,1);
        p4_g_bGreatswordBypass[victim] = false

        if(!greatswordBypass)
            SetHamParamFloat(4, 0.0)

        emit_sound(victim, CHAN_AUTO, "parry.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
        p4_GoldenFlash(victim)

        remove_task(victim + p7_TASK_PARRY)
        p7_g_bParry[victim] = true
        p7_UpdatePlayerGlow(victim)
        set_task(2.0, "p7_TaskEndParryGlow", victim + p7_TASK_PARRY)

        if(!shockwaveParry && p1_GetCombatMelee(victim) == p1_MELEE_PAN && is_user_alive(attacker) && !p1_IsSuppressed(victim))
        {
            new Float:counterDamage = damage * 0.25
            if(counterDamage > 0.0)
            {
                if(get_user_health(attacker)<=floatround(counterDamage)) g_AchPanParryKiller[attacker]=victim
                ExecuteHamB(Ham_TakeDamage, attacker, victim, victim, counterDamage, DMG_CLUB | p1_DMG_PARRY_COUNTER)
            }
        }

        p4_g_ParryActive[victim] = false
        p4_g_ParryAttempt[victim] = false

        // Shockwave parries only negate this target's knockback; they do not
        // stun the Glaive user. Greatsword bypass still produces normal parry
        // feedback, but the hit continues to damage the defender.
        if(!shockwaveParry)
            p4_StunPlayer(attacker, victim)

        if(greatswordBypass)
            return HAM_IGNORED
        return HAM_SUPERCEDE
    }

    return HAM_IGNORED
}

// ==========================

public p4_PlayKnifeAnim(p4_id)
{
    // Logical slot 8 is mapped independently for each weapon model.
    p1_PlayKnifeAnim(p4_id, 8)
}

// ==========================

public p4_GoldenFlash(p4_id)
{
    message_begin(MSG_ONE, p4_g_msgScreenFade, _, p4_id)

    write_short(1<<10) // duration
    write_short(1<<10) // hold
    write_short(0x0000)

    write_byte(255) // R
    write_byte(215) // G
    write_byte(0)   // B
    write_byte(40)  // alpha VERY slight

    message_end()
}

// ==========================

public p4_StunPlayer(p4_id, stunOwner)
{
    if(!is_user_alive(p4_id)) return
    remove_task(p4_id + p4_TASK_STUN)
    pev(p4_id, pev_maxspeed, p4_g_PreStunSpeed[p4_id])
    p4_g_Stunned[p4_id] = true
    g_AchStunOwner[p4_id] = stunOwner
    set_pev(p4_id, pev_maxspeed, p4_STUN_SPEED)
    new Float:punch[3]
    punch[0] = -8.0
    punch[1] = random_float(-4.0, 4.0)
    punch[2] = random_float(-2.0, 2.0)
    set_pev(p4_id, pev_punchangle, punch)
    set_task(p4_STUN_TIME, "p4_RemoveStun", p4_id + p4_TASK_STUN)
}

public p4_RemoveStun(taskid)
{
    new p4_id = taskid - p4_TASK_STUN
    if(p4_id < 1 || p4_id > 32) return
    p4_g_Stunned[p4_id] = false
    if(!Mech_IsStunned(p4_id)) g_AchStunOwner[p4_id] = 0
    if(is_user_alive(p4_id))
    {
        // Restore the correct custom melee movement speed, or the prior gun speed.
        if(get_user_weapon(p4_id) == CSW_KNIFE)
            p1_ApplyMelee(p4_id)
        else if(p4_g_PreStunSpeed[p4_id] > 0.0)
            set_pev(p4_id, pev_maxspeed, p4_g_PreStunSpeed[p4_id])
    }
}

// Block attack inputs for 1.0s after parry activation, while the animation
// plays freely. No weapon attack/idle timers are extended by this lock.
public p4_fw_PreThink(p4_id)
{
    if (!is_user_alive(p4_id))
        return FMRES_IGNORED

    if (get_gametime() < p4_g_AttackLockEnd[p4_id])
    {
        new p4_buttons = pev(p4_id, pev_button)
        p4_buttons &= ~(IN_ATTACK | IN_ATTACK2)
        set_pev(p4_id, pev_button, p4_buttons)
    }

    return FMRES_IGNORED
}

public p4_fw_KnifeAttack(ent)
{
    return HAM_IGNORED
}



// IMPORTANT: melee_menu.sma must be loaded BEFORE this plugin in
// plugins.ini. melee_menu.sma computes the real weapon damage on the
// same Ham_TakeDamage event; if this plugin's hook runs first, it will
// reduce the old default knife damage and melee_menu.sma will then
// overwrite it with the real value, making the reduction disappear.

/* =========================================================================
   CONFIGURATION - edit these values to tweak how the plugin behaves.
   No cvars, no config files - just recompile after changing a value.
   ========================================================================= */

// Block is toggled with the default Z / radio1 command.
// Once active it lasts at most 10 seconds, then requires 5 seconds to recharge.
#define p5_BLOCK_ACTIVATION_DELAY   0.5
#define p5_BLOCK_MAX_DURATION       10.0
#define p5_BLOCK_COOLDOWN           5.0

// 0.75 = take 75% less damage while block is ACTIVE
#define p5_BLOCK_DAMAGE_REDUCTION   0.75
#define p5_BLOCK_WALK_SPEED         130.0
#define p5_BLOCK_FLASH_R            0
#define p5_BLOCK_FLASH_G            180
#define p5_BLOCK_FLASH_B            255
#define p5_BLOCK_FLASH_ALPHA        67
#define p5_BLOCK_FLASH_TIME         0.15

#define p5_TASK_ACTIVATE   600000
#define p5_TASK_MAXEND     700000

#define p5_FFADE_IN        0x0001
#define p5_FFADE_MODULATE  0x0004

new bool:p5_g_bAttackLocked[33];
new Float:p5_g_flBlockReadyAt[33];
new p5_g_MsgScreenFade;

public p5_plugin_init()
{
    // Z's default radio1 command is sent to the server; no client bind changes.
    register_clcmd("radio1", "p5_CmdBlockToggle");

    RegisterHam(Ham_TakeDamage, "player", "p5_Fw_TakeDamage", 0);
    register_forward(FM_PlayerPreThink, "p5_Fw_PlayerPreThink");
    register_event("ResetHUD", "p5_EventResetHud", "be");
    p5_g_MsgScreenFade = get_user_msgid("ScreenFade");
}

public p5_client_putinserver(p5_id)
{
    p5_ResetPlayerBlock(p5_id);
}

public p5_client_disconnect(p5_id)
{
    p5_ResetPlayerBlock(p5_id);
}

public p5_EventResetHud(p5_id)
{
    p5_ResetPlayerBlock(p5_id);
}

public p5_CmdBlockToggle(p5_id)
{
    // Preserve the normal Z radio menu unless the player is actively using melee.
    if (!is_user_alive(p5_id) || get_user_weapon(p5_id) != CSW_KNIFE || p1_IsSuppressed(p5_id))
        return PLUGIN_CONTINUE;

    // Toggling an active block OFF immediately starts its recharge period.
    if (p5_g_bKeyDown[p5_id])
    {
        p5_EndBlock(p5_id, true);
        return PLUGIN_HANDLED;
    }

    new Float:now = get_gametime();
    if (now < p5_g_flBlockReadyAt[p5_id] || Mech_IsStunned(p5_id))
    {
        new Float:remaining = p5_g_flBlockReadyAt[p5_id] - now;
        if (remaining > 0.0)
            client_print(p5_id, print_center, "Block exhausted: %.1f seconds", remaining);
        return PLUGIN_HANDLED;
    }

    p5_g_bKeyDown[p5_id] = true;
    p5_g_bAttackLocked[p5_id] = true;
    remove_task(p5_id + p5_TASK_ACTIVATE);
    remove_task(p5_id + p5_TASK_MAXEND);
    set_task(p5_BLOCK_ACTIVATION_DELAY, "p5_TaskActivateBlock", p5_id + p5_TASK_ACTIVATE);

    return PLUGIN_HANDLED;
}

public p5_TaskActivateBlock(taskid)
{
    new p5_id = taskid - p5_TASK_ACTIVATE;
    if (!is_user_connected(p5_id) || !is_user_alive(p5_id) || Mech_IsStunned(p5_id) ||
        !p5_g_bKeyDown[p5_id] || get_user_weapon(p5_id) != CSW_KNIFE)
    {
        if (is_user_connected(p5_id) && p5_g_bKeyDown[p5_id])
            p5_EndBlock(p5_id, true);
        return;
    }

    p5_g_bBlockActive[p5_id] = true;
    p7_g_bBlock[p5_id] = true;
    set_user_maxspeed(p5_id, p5_BLOCK_WALK_SPEED);
    p7_UpdatePlayerGlow(p5_id);
    set_task(p5_BLOCK_MAX_DURATION, "p5_TaskMaxEndBlock", p5_id + p5_TASK_MAXEND);
    client_print(p5_id, print_center, "BLOCK ACTIVE - 10 seconds");
}

public p5_TaskMaxEndBlock(taskid)
{
    new p5_id = taskid - p5_TASK_MAXEND;
    if (is_user_connected(p5_id) && p5_g_bKeyDown[p5_id])
    {
        p5_EndBlock(p5_id, true);
        client_print(p5_id, print_center, "Block exhausted - 5 second cooldown");
    }
}

p5_EndBlock(p5_id, bool:startCooldown)
{
    p5_g_bKeyDown[p5_id] = false;
    p5_g_bBlockActive[p5_id] = false;
    p5_g_bAttackLocked[p5_id] = false;
    p7_g_bBlock[p5_id] = false;
    remove_task(p5_id + p5_TASK_ACTIVATE);
    remove_task(p5_id + p5_TASK_MAXEND);

    if (startCooldown)
        p5_g_flBlockReadyAt[p5_id] = get_gametime() + p5_BLOCK_COOLDOWN;

    if (is_user_connected(p5_id))
    {
        set_pev(p5_id, pev_maxspeed, 250.0);
        p7_UpdatePlayerGlow(p5_id);
    }
}

p5_ResetPlayerBlock(p5_id)
{
    p5_g_bKeyDown[p5_id] = false;
    p5_g_bBlockActive[p5_id] = false;
    p5_g_bAttackLocked[p5_id] = false;
    p5_g_flBlockReadyAt[p5_id] = 0.0;
    p7_g_bBlock[p5_id] = false;
    remove_task(p5_id + p5_TASK_ACTIVATE);
    remove_task(p5_id + p5_TASK_MAXEND);
    if (is_user_connected(p5_id))
    {
        set_pev(p5_id, pev_maxspeed, 250.0);
        p7_UpdatePlayerGlow(p5_id);
    }
}

public p5_Fw_PlayerPreThink(p5_id)
{
    if (!is_user_alive(p5_id))
        return FMRES_IGNORED;

    if (p5_g_bKeyDown[p5_id] && get_user_weapon(p5_id) != CSW_KNIFE)
        p5_EndBlock(p5_id, true);

    if (p5_g_bBlockActive[p5_id])
    {
        set_pev(p5_id, pev_maxspeed, p5_BLOCK_WALK_SPEED);
    }

    if (!p5_g_bAttackLocked[p5_id])
        return FMRES_IGNORED;

    new p5_buttons = pev(p5_id, pev_button);
    p5_buttons &= ~(IN_ATTACK | IN_ATTACK2);
    set_pev(p5_id, pev_button, p5_buttons);

    return FMRES_IGNORED;
}

public p5_Fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(is_user_alive(victim) && is_user_alive(attacker) && p5_g_bBlockActive[victim] && damage > 0.0) ach_on_block(victim)

    if (!is_user_alive(victim) || !p5_g_bBlockActive[victim])
        return HAM_IGNORED;

    if(is_user_alive(attacker) && get_user_weapon(attacker) == CSW_KNIFE)
    {
        if(p1_g_Melee[attacker] == p1_MELEE_GREATSWORD && !p1_IsSuppressed(attacker))
            return HAM_IGNORED;
        if(p1_g_Melee[attacker] == p1_MELEE_CLEAVER && !p1_IsSuppressed(attacker) &&
            p1_g_AttackType[attacker] == 2 && get_user_health(victim) <= p1_CLEAVER_EXECUTE_HP)
            return HAM_IGNORED;
    }
    if(damagebits & p1_CLEAVER_EXECUTE_FLAG)
        return HAM_IGNORED;

    // Only reduce melee damage - all the custom melee weapons live on
    // the knife slot, so this covers every one of them, not just bullets.
    if (!is_user_connected(attacker) ||
        (get_user_weapon(attacker) != CSW_KNIFE && !(damagebits & p1_DMG_CUSTOM_MELEE)))
        return HAM_IGNORED;

    new Float:p5_newDamage = damage * (1.0 - p5_BLOCK_DAMAGE_REDUCTION);
    SetHamParamFloat(4, p5_newDamage);

    p5_ScreenFlash(victim);

    return HAM_IGNORED;
}

p5_ScreenFlash(p5_id)
{
    message_begin(MSG_ONE_UNRELIABLE, p5_g_MsgScreenFade, _, p5_id)

    write_short(1<<10) // duration (0.5s)
    write_short(0)     // hold time (CRITICAL FIX)

    write_short(0)     // flags (NO MODULATE)

    write_byte(p5_BLOCK_FLASH_R)
    write_byte(p5_BLOCK_FLASH_G)
    write_byte(p5_BLOCK_FLASH_B)
    write_byte(p5_BLOCK_FLASH_ALPHA)

    message_end()
}








// p6 is part of this unified plugin, so it reads the p1 melee state directly.
// Do not declare Melee_GetCurrent as an external native here.
// Must match the p6_MELEE_CLAWS constant in melee_menu.sma.
#define p6_MELEE_CLAWS 5
#define p6_MELEE_GAUNTLETS 14

#define p6_HEAVY_COOLDOWN          6.0   // default heavy attack cooldown
#define p6_CLAWS_HEAVY_COOLDOWN    3.0
#define p6_GAUNTLETS_HEAVY_COOLDOWN 3.0

// Ignore parry.sma's synthetic pan counter-hit - it's not a real heavy
// attack landing. Must match p6_DMG_PARRY_COUNTER in parry.sma exactly.
#define p6_DMG_PARRY_COUNTER (1<<24)

new Float:p6_g_flHeavyCooldown[33];

new p6_g_msgStatusIcon;

public p6_plugin_precache()
{
    precache_generic("sprites/hvy_cooldown.spr");
}

public p6_plugin_init()
{

    p6_g_msgStatusIcon = get_user_msgid("StatusIcon");

    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "p6_KnifeSecondary");
    RegisterHam(Ham_TakeDamage, "player", "p6_PlayerTakeDamage");
}

public p6_KnifeSecondary(ent)
{
    new p6_id = pev(ent, pev_owner);

    if(!is_user_alive(p6_id))
        return HAM_IGNORED;

    if(get_gametime() < p6_g_flHeavyCooldown[p6_id])
        return HAM_SUPERCEDE;

    // Arm only a secondary/stab attempt. A later slash or kick must
    // never inherit this state if the stab misses.
    p6_g_bWaitingHeavyHit[p6_id] = true;

    return HAM_IGNORED;
}

public p6_PlayerTakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(damagebits & p6_DMG_PARRY_COUNTER)
        return HAM_IGNORED;

    // Kick and other synthetic melee damage must never start heavy cooldown.
    if(damagebits & p1_DMG_CUSTOM_MELEE)
        return HAM_IGNORED;

    if(!is_user_alive(attacker))
        return HAM_IGNORED;

    if(get_user_weapon(attacker) != CSW_KNIFE)
        return HAM_IGNORED;

    if(!p6_g_bWaitingHeavyHit[attacker])
        return HAM_IGNORED;

    p6_g_bWaitingHeavyHit[attacker] = false;

    new Float:p6_cooldown = p6_HEAVY_COOLDOWN;
    if(p1_g_Melee[attacker] == p6_MELEE_CLAWS)
        p6_cooldown = p6_CLAWS_HEAVY_COOLDOWN;
    else if(p1_g_Melee[attacker] == p6_MELEE_GAUNTLETS)
        p6_cooldown = p6_GAUNTLETS_HEAVY_COOLDOWN;

    p6_g_flHeavyCooldown[attacker] = get_gametime() + p6_cooldown;

    remove_task(attacker);
    p6_ShowHeavyCooldownIcon(attacker);
    set_task(p6_cooldown, "p6_RemoveHeavyCooldown", attacker);

    return HAM_IGNORED;
}

public p6_client_disconnect(p6_id)
{
    remove_task(p6_id);

    p6_HideHeavyCooldownIcon(p6_id);

    p6_g_bWaitingHeavyHit[p6_id] = false;
    p6_g_flHeavyCooldown[p6_id] = 0.0;
}

public p6_RemoveHeavyCooldown(p6_id)
{
    if(!is_user_connected(p6_id))
        return;

    p6_HideHeavyCooldownIcon(p6_id);
}

p6_ShowHeavyCooldownIcon(p6_id)
{
    message_begin(MSG_ONE, p6_g_msgStatusIcon, _, p6_id);
    write_byte(1);                    // Show
    write_string("hvy_cooldown");     // sprites/hvy_cooldown.spr
    write_byte(255);                  // Red
    write_byte(0);
    write_byte(0);
    message_end();
}

p6_HideHeavyCooldownIcon(p6_id)
{
    message_begin(MSG_ONE, p6_g_msgStatusIcon, _, p6_id);
    write_byte(0);                    // Hide
    write_string("hvy_cooldown");
    write_byte(0);
    write_byte(0);
    write_byte(0);
    message_end();
}







// ============================================================
public p7_plugin_init()
{

    // --------------------------------------------------------
    // PARRY
    // --------------------------------------------------------

    register_forward(FM_CmdStart, "p7_fw_CmdStart")

    // --------------------------------------------------------
    // HEAVY
    // --------------------------------------------------------

    RegisterHam(
        Ham_Weapon_SecondaryAttack,
        "weapon_knife",
        "p7_fw_KnifeSecondaryAttack"
    )

    RegisterHam(
        Ham_TakeDamage,
        "player",
        "p7_fw_TakeDamage"
    )

    // Last pre-damage hook: apply the global armor tiers after the melee,
    // parry and block hooks have adjusted or cancelled the incoming damage.
    RegisterHam(
        Ham_TakeDamage,
        "player",
        "p7_fw_ArmorReduction"
    )

    // --------------------------------------------------------
    // HUD synchronization
    // --------------------------------------------------------

    p7_g_msgSync = CreateHudSyncObj()

    // --------------------------------------------------------
    // RESET
    // --------------------------------------------------------

    register_event("ResetHUD", "p7_EventResetHUD", "be")
}


public p7_fw_CmdStart(p7_id, uc_handle, seed)
{
    if (!is_user_alive(p7_id))
        return FMRES_IGNORED

    // ========================================================
    // PARRY
    // ========================================================

    /*
     * The actual Parry plugin uses:
     *
     *     impulse 100
     *
     * to activate parry.
     *
     * IMPORTANT:
     * This glow plugin must be loaded BEFORE the actual
     * parry plugin in plugins.ini so that we see impulse 100
     * before the parry plugin changes it to 0.
     */

    if (get_uc(uc_handle, UC_Impulse) == p7_PARRY_IMPULSE)
    {
        p7_StartParryGlow(p7_id)
    }

    // ========================================================
    // HEAVY COOLDOWN HUD
    // ========================================================

    if (p7_g_bHeavyCooldown[p7_id])
    {
        p7_ShowHeavyCountdown(p7_id)
    }

    return FMRES_IGNORED
}


// ============================================================
// PARRY GLOW
// ============================================================

p7_StartParryGlow(p7_id)
{
    if (!is_user_alive(p7_id))
        return

    remove_task(p7_id + p7_TASK_PARRY)

    p7_g_bParry[p7_id] = true

    p7_UpdatePlayerGlow(p7_id)

    set_task(
        p7_PARRY_WINDOW,
        "p7_TaskEndParryGlow",
        p7_id + p7_TASK_PARRY
    )
}


public p7_TaskEndParryGlow(taskid)
{
    new p7_id = taskid - p7_TASK_PARRY

    if (!is_user_connected(p7_id))
        return

    p7_g_bParry[p7_id] = false

    p7_UpdatePlayerGlow(p7_id)
}


// ============================================================
// BLOCK
// ============================================================

// ============================================================
// HEAVY ATTACK DETECTION
// ============================================================

public p7_fw_KnifeSecondaryAttack(ent)
{
    if (!pev_valid(ent))
        return HAM_IGNORED

    new p7_id = pev(ent, pev_owner)

    if (!is_user_alive(p7_id))
        return HAM_IGNORED

    /*
     * The actual Heavy plugin prevents the secondary attack
     * if the cooldown is active.
     *
     * We keep our own copy of the cooldown end time.
     */

    if (get_gametime() < p7_g_flHeavyEnd[p7_id])
        return HAM_IGNORED

    /*
     * Right-click has been attempted.
     *
     * The cooldown does NOT start here.
     *
     * The real Heavy plugin starts it only when the attack
     * successfully damages somebody.
     */

    p7_g_bWaitingHeavyHit[p7_id] = true

    return HAM_IGNORED
}


// ============================================================
// DAMAGE
// ============================================================

public p7_fw_ArmorReduction(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(damagebits & p1_CLEAVER_EXECUTE_FLAG)
        return HAM_IGNORED

    if(!is_user_alive(victim) || damage <= 0.0)
        return HAM_IGNORED

    if(is_user_alive(attacker) && get_user_weapon(attacker) == CSW_KNIFE &&
        p1_g_Melee[attacker] == p1_MELEE_CLEAVER && !p1_IsSuppressed(attacker) &&
        p1_g_AttackType[attacker] == 2 && get_user_health(victim) <= p1_CLEAVER_EXECUTE_HP &&
        !(damagebits & p1_DMG_CUSTOM_MELEE))
        return HAM_IGNORED

    new armor = get_user_armor(victim)
    new Float:reduction = 0.0
    new Float:finalDamage = damage
    new Float:armorPercent = float(armor)
    if(armorPercent > float(p1_MAX_ARMOR)) armorPercent = float(p1_MAX_ARMOR)

    // Global armor tiers. Armor percentage is based on the 100 AP cap.
    if(armor > 0)
    {
        if(armorPercent >= 90.0) reduction = 40.0
        else if(armorPercent >= 75.0) reduction = 20.0
        else if(armorPercent >= 67.0) reduction = 15.0
        else if(armorPercent >= 30.0) reduction = 10.0
        else if(armorPercent >= 25.0) reduction = 7.0
        else if(armorPercent >= 15.0) reduction = 5.0
        else if(armorPercent >= 5.0) reduction = 3.0
        else reduction = 1.0

        // Gladius Fortification: +20 percentage points, not a relative bonus.
        if(p1_g_Melee[victim] == p1_MELEE_GLADIUS && !p1_IsSuppressed(victim))
        {
            reduction += p1_GLADIUS_FORTIFY_BONUS
            if(reduction > 100.0) reduction = 100.0
        }

        finalDamage = damage * (1.0 - reduction / 100.0)
        SetHamParamFloat(4, finalDamage)

        // Disable GoldSrc's separate vest absorption for this hit so the
        // configured tier is the exact total reduction, not an extra layer
        // stacked on top of vanilla armor protection. AP remains tracked below.
        cs_set_user_armor(victim, armor, CS_ARMOR_NONE)
    }

    // Final damage is now known after melee, parry, block and armor modifiers.
    // Soul Reap rolls on incoming enemy stabs after the five-hit charge; lethality is not required.
    if(is_user_alive(victim) && is_user_alive(attacker) && attacker != victim &&
        p1_g_Melee[victim] == p1_MELEE_SCYTHE &&
        p1_g_ScytheHits[victim] >= p1_SCYTHE_CHARGE_HITS &&
        get_user_weapon(attacker) == CSW_KNIFE && p1_g_AttackType[attacker] == 2 &&
        get_user_team(attacker) != get_user_team(victim) &&
        !(damagebits & (p1_DMG_CUSTOM_MELEE | p1_DMG_PARRY_COUNTER)) &&
        !p5_g_bBlockActive[victim] && !p1_IsSuppressed(victim) &&
        finalDamage > 0.0 && random_num(1, 100) <= p1_SCYTHE_PROC_CHANCE)
    {
        // If the triggering stab would be lethal, leave the Scythe user at
        // 1 HP so the engine does not complete a real death. Non-lethal stabs
        // retain their normal damage and can still trigger the disguise.
        if(finalDamage >= float(get_user_health(victim)))
        {
            new Float:survivalDamage = float(get_user_health(victim) - 1)
            if(survivalDamage < 0.0) survivalDamage = 0.0
            SetHamParamFloat(4, survivalDamage)
        }
        p1_ScytheFakeDeath(victim, attacker)
    }

    // Gladius Armor Steal: only at 0 AP, on a real successful stab. Run after
    // parry/block hooks; blocked and parried attacks do not steal armor.
    // Use the victim's armor at the start of this damage event, before this
    // hit's ordinary armor drain is applied.
    if(armor > 0 && is_user_alive(attacker) && attacker != victim &&
        get_user_weapon(attacker) == CSW_KNIFE &&
        p1_g_Melee[attacker] == p1_MELEE_GLADIUS &&
        !p1_IsSuppressed(attacker) && p1_g_AttackType[attacker] == 2 &&
        !(damagebits & p1_DMG_CUSTOM_MELEE) && damage > 0.0 &&
        get_user_armor(attacker) == 0 && !p5_g_bBlockActive[victim])
    {
        new stolen = armor < p1_GLADIUS_STEAL_AMOUNT ? armor : p1_GLADIUS_STEAL_AMOUNT
        new victimArmor = get_user_armor(victim)
        if(stolen > victimArmor) stolen = victimArmor
        if(stolen > 0)
        {
            set_user_armor(victim, victimArmor - stolen)
            new oldAttackerArmor = get_user_armor(attacker)
            new attackerArmor = oldAttackerArmor + stolen
            if(attackerArmor > p1_MAX_ARMOR) attackerArmor = p1_MAX_ARMOR
            set_user_armor(attacker, attackerArmor)
            if(attackerArmor > oldAttackerArmor)
                ach_track_ap_gain(attacker,attackerArmor-oldAttackerArmor,true)
        }
    }

    // Consume armor for every damage type, including melee, bullets,
    // explosions, throwables, fall and miscellaneous damage. AP loss equals
    // the amount of damage prevented, rounded up to at least 1 AP per hit.
    if(armor > 0)
    {
        new armorLoss = floatround(damage * reduction / 100.0, floatround_ceil)
        if(armorLoss < 1) armorLoss = 1

        // Gladius weakness: while the player has Gladius selected, incoming
        // damage consumes three times the normal AP amount. This applies
        // continuously, including while suppression is active.
        if(p1_g_Melee[victim] == p1_MELEE_GLADIUS)
            armorLoss *= 2

        new remainingArmor = get_user_armor(victim) - armorLoss
        if(remainingArmor < 0) remainingArmor = 0
        if(remainingArmor != get_user_armor(victim))
            cs_set_user_armor(victim, remainingArmor, CS_ARMOR_NONE)
    }

    return HAM_IGNORED
}


public p7_fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if (!is_user_alive(attacker))
        return HAM_IGNORED

    if (get_user_weapon(attacker) != CSW_KNIFE)
        return HAM_IGNORED

    // ========================================================
    // HEAVY COOLDOWN
    // ========================================================

    // Only real, successful knife stabs can trigger heavy cooldown.
    // Ignore synthetic kick damage, slash damage, and missed stabs.
    if ((damagebits & p1_DMG_CUSTOM_MELEE) ||
        p1_g_AttackType[attacker] != 2 ||
        damage <= 0.0)
        return HAM_IGNORED

    if (p7_g_bWaitingHeavyHit[attacker])
    {
        p7_g_bWaitingHeavyHit[attacker] = false

        /*
         * Start our synchronized 6-second cooldown.
         */
        p7_g_bHeavyCooldown[attacker] = true
        new Float:cooldown = ((p1_g_Melee[attacker] == p1_MELEE_CLAWS) ||
            (p1_g_Melee[attacker] == p1_MELEE_GAUNTLETS)) ? 3.0 : p7_HEAVY_COOLDOWN
        p7_g_flHeavyEnd[attacker] = get_gametime() + cooldown

        remove_task(attacker + p7_TASK_HEAVY)
        set_task(cooldown, "p7_TaskEndHeavyCooldown", attacker + p7_TASK_HEAVY)
    }

    return HAM_IGNORED
}


// ============================================================
// END HEAVY COOLDOWN
// ============================================================

public p7_TaskEndHeavyCooldown(taskid)
{
    new p7_id = taskid - p7_TASK_HEAVY

    if (!is_user_connected(p7_id))
        return

    p7_g_bHeavyCooldown[p7_id] = false
    p7_g_flHeavyEnd[p7_id] = 0.0

    /*
     * Make sure no old HUD message remains.
     */
    p7_ClearHeavyCountdown(p7_id)

    p7_UpdatePlayerGlow(p7_id)
}


// ============================================================
// HEAVY COOLDOWN HUD
// ============================================================

p7_ShowHeavyCountdown(p7_id)
{
    if (!is_user_alive(p7_id))
        return

    new Float:p7_remaining =
        p7_g_flHeavyEnd[p7_id] - get_gametime()

    if (p7_remaining <= 0.0)
    {
        p7_ClearHeavyCountdown(p7_id)
        return
    }

    /*
     * Display with one decimal place.
     *
     * Examples:
     *
     * HEAVY 3.0 (Claws / Gauntlets)
     * HEAVY 2.9
     * HEAVY 2.8
     * ...
     */

    new p7_text[64]

    formatex(
        p7_text,
        charsmax(p7_text),
        "HEAVY  %.1f",
        p7_remaining
    )

    /*
     * Purple p7_text at the top-center.
     *
     * x = -1.0  -> centered
     * y = 0.12   -> near top of screen
     */

    set_hudmessage(
        p7_HEAVY_R,
        p7_HEAVY_G,
        p7_HEAVY_B,
        -1.0,
        0.12,
        0,
        0.0,
        0.15,
        0.0,
        0.0,
        -1
    )

    ShowSyncHudMsg(
        p7_id,
        p7_g_msgSync,
        "%s",
        p7_text
    )
}


p7_ClearHeavyCountdown(p7_id)
{
    if (!is_user_connected(p7_id))
        return

    ClearSyncHud(
        p7_id,
        p7_g_msgSync
    )
}


// ============================================================
// PLAYER MODEL GLOW
// ============================================================
//
// Priority:
//
// 1. PARRY  = GOLD
// 2. BLOCK  = CYAN
// 3. No glow
//
// Heavy cooldown does NOT glow the player anymore.
//
// ============================================================

p7_UpdatePlayerGlow(p7_id)
{
    if(!is_user_connected(p7_id)) return

    // Back-attack stun glow: blue-grey shell remains visible for the full stun.
    if(Mech_IsStunned(p7_id))
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 105, 120, 145, kRenderNormal, 24)
        return
    }
    if(p1_g_ThornsEndTime[p7_id] > get_gametime())
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 190, 255, 50, kRenderNormal, p7_GLOW_AMOUNT)
        return
    }
    if(p1_g_SuppressedUntil[p7_id] > get_gametime())
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 128, 0, 32, kRenderNormal, p7_GLOW_AMOUNT)
        return
    }
    if(p1_g_MicroBomb[p7_id])
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16)
        return
    }
    if(p7_g_bParry[p7_id])
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, p7_PARRY_R, p7_PARRY_G, p7_PARRY_B, kRenderNormal, p7_GLOW_AMOUNT)
        return
    }
    if(p7_g_bBlock[p7_id])
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, p7_BLOCK_R, p7_BLOCK_G, p7_BLOCK_B, kRenderNormal, p7_GLOW_AMOUNT)
        return
    }

    // Glaive Berserk overrides both Cleaver glow states.
    if(is_user_alive(p7_id) && p1_g_Melee[p7_id] == p1_MELEE_GLAIVE && p1_g_GlaiveBerserk[p7_id] && get_user_health(p7_id) <= p1_GLAIVE_BERSERK_HP)
    {
        new amount = (get_gametime() <= p1_g_GlaiveGlowBrightEnd[p7_id]) ? p1_GLAIVE_GLOW_BRIGHT : p1_GLAIVE_GLOW_FAINT
        set_user_rendering(p7_id, kRenderFxGlowShell, 95, 210, 255, kRenderNormal, amount)
        return
    }

    // Crimson takes priority over Cleaver blue and applies to every low-health player.
    if(is_user_alive(p7_id) && get_user_health(p7_id) <= p1_CLEAVER_EXECUTE_HP && p1_AnyAliveCleaverWielder())
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 175, 50, 45, kRenderNormal, p1_CLEAVER_GLOW_AMOUNT)
        return
    }

    if(is_user_alive(p7_id) && p1_g_Melee[p7_id] == p1_MELEE_CLEAVER && get_user_weapon(p7_id) == CSW_KNIFE && p1_CleaverHasLowOpponent(p7_id))
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 30, 90, 255, kRenderNormal, 16)
        return
    }

    if(p1_g_Vulnerable[p7_id])
    {
        set_user_rendering(p7_id, kRenderFxGlowShell, 30, 90, 255, kRenderNormal, 16)
        return
    }

    set_user_rendering(p7_id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
}


// ============================================================
// RESET
// ============================================================

public p7_EventResetHUD(p7_id)
{
    p7_ResetPlayer(p7_id)
}


public p7_client_putinserver(p7_id)
{
    p7_ResetPlayer(p7_id)
}


public p7_client_disconnect(p7_id)
{
    p7_ResetPlayer(p7_id)
}


p7_ResetPlayer(p7_id)
{
    remove_task(p7_id + p7_TASK_PARRY)
    remove_task(p7_id + p7_TASK_HEAVY)

    p7_g_bParry[p7_id] = false
    p7_g_bBlock[p7_id] = false

    p7_g_bHeavyCooldown[p7_id] = false
    p7_g_bWaitingHeavyHit[p7_id] = false

    p7_g_flHeavyEnd[p7_id] = 0.0

    if (is_user_connected(p7_id))
    {
        set_user_rendering(
            p7_id,
            kRenderFxNone,
            0,
            0,
            0,
            kRenderNormal,
            0
        )

        p7_ClearHeavyCountdown(p7_id)
    }
}


// ============================================================================
// ACHIEVEMENTS
// ============================================================================

public ach_plugin_init()
{
    g_AchVault = nvault_open(ACH_VAULT_NAME);
    if(g_AchVault == INVALID_HANDLE) set_fail_state("Could not open achievement vault");
    register_clcmd("say", "ach_say_router");
    register_clcmd("say_team", "ach_say_router");
    register_logevent("ach_round_start", 2, "1=Round_Start");
    register_logevent("ach_ct_win", 2, "1=CTs_Win");
    register_logevent("ach_t_win", 2, "1=Terrorists_Win");
    register_logevent("ach_round_draw", 2, "1=Round_Draw");
    register_event("SendAudio", "ach_ct_win_audio", "a", "2=%!MRAD_ctwin")
    register_event("SendAudio", "ach_t_win_audio", "a", "2=%!MRAD_terwin")
    RegisterHam(Ham_TakeDamage, "player", "ach_damage_pre", 0);
    RegisterHam(Ham_TakeDamage, "player", "ach_damage_post", 1);
    set_task(0.25, "ach_airborne_check", 94821, _, _, "b");
}

public ach_client_putinserver(id)
{
    arrayset(g_AchProgress[id], 0, ACH_COUNT);
    for(new i=0;i<ACH_COUNT;i++) g_AchUnlocked[id][i]=false;
    g_AchTotalKills[id]=0; g_AchFallDeaths[id]=0; g_AchWinStreak[id]=0;
    g_AchLastRoundKiller[id]=0; g_AchPreviousRoundKiller[id]=0;
    g_AchConsecutiveHits[id]=0; g_AchLastHitVictim[id]=0; g_AchAirStart[id]=0.0;
    g_AchLastKiller[id]=0; g_AchKillerStreak[id]=0;
    g_AchRoundKills[id]=0; g_AchRoundParries[id]=0; g_AchRoundBackstabs[id]=0; g_AchSpecialRoundKills[id]=0;
    g_AchTeamWinStreak[id]=0; g_AchRoundTookDamage[id]=false; g_AchRoundDamageTaken[id]=0;
    g_AchRoundTeamSize[id]=0; g_AchRoundEnemySize[id]=0;
    g_AchRoundLightOnly[id]=1; g_AchRoundLightHits[id]=0; g_AchRoundAPGained[id]=0; g_AchFallPending[id]=false;
    g_AchBombKiller[id]=0; g_AchThornsKiller[id]=0; g_AchStunnedHitBy[id]=0;
    g_AchKickOwner[id]=0; g_AchBonelessOwner[id]=0; g_AchBonelessUntil[id]=0.0; g_AchPanParryKiller[id]=0;
    g_AchKickOnlyOwner[id]=0; g_AchKickOnlyBroken[id]=false; g_AchStunOwner[id]=0;
    g_AchBackComboVictim[id]=0; g_AchBackstabOwner[id]=0; g_AchVulnerabilityOwner[id]=0; g_AchCleaverExecVictim[id]=0;
    g_AchTeamKicks[id]=0; g_AchKillerStreak[id]=0;
    g_AchRecentKillCount[id]=0; for(new k=0;k<32;k++) g_AchRecentKillTimes[id][k]=0.0; arrayset(g_AchRecentKillVictims[id],0,32); remove_task(id+19000);
    g_AchWallBounceLethal[id]=false; g_AchWallBouncePending[id]=false; g_AchWallBounceUntil[id]=0.0;
    g_AchRoundLightHits[id]=0; g_AchRoundAPGained[id]=0;
    arrayset(g_AchDamageByOpponent[id],0,33);
    for(new other=1;other<=32;other++) g_AchSameTeammateBomb[id][other]=0;
    for(new w=0;w<16;w++) g_AchWeaponKills[id][w]=0;
    ach_load(id);
    if(!g_AchUnlocked[id][ACH_ADDICTION]) g_AchProgress[id][ACH_ADDICTION]=0;
}

stock ach_load(id)
{
    new auth[40], key[96], data[2048], pos=0;
    get_user_authid(id, auth, charsmax(auth));
    if(equal(auth,"STEAM_ID_PENDING") || equal(auth,"BOT")) return;
    formatex(key, charsmax(key), "P_%s", auth);
    if(nvault_get(g_AchVault,key,data,charsmax(data)))
    {
        for(new i=0;i<ACH_COUNT;i++)
        {
            new token[24];
            if(!parse(data[pos], token, charsmax(token))) break;
            new value=str_to_num(token);
            g_AchProgress[id][i]=value;
            if(value >= g_AchTargets[i]) g_AchUnlocked[id][i]=true;
            pos += strlen(token)+1;
        }
    }

    // One-time migration: Tank's old target was four opponents, and Vertical
    // Attack previously counted gravity toggles. Clear those legacy records
    // once, but preserve unlocks earned with the corrected implementation.
    new versionKey[96], version[8];
    formatex(versionKey,charsmax(versionKey),"ACH_SCHEMA_%s",auth);
    if(!nvault_get(g_AchVault,versionKey,version,charsmax(version)))
    {
        g_AchProgress[id][59]=0; g_AchUnlocked[id][59]=false;
        g_AchProgress[id][54]=0; g_AchUnlocked[id][54]=false;
        nvault_set(g_AchVault,versionKey,"2");
        ach_save(id);
    }

    // These are session- or round-scoped challenges; old incomplete progress
    // must never survive a reconnect or a changed requirement.
    if(!g_AchUnlocked[id][ACH_ADDICTION]) g_AchProgress[id][ACH_ADDICTION]=0;
    if(!g_AchUnlocked[id][ACH_DEATH_DOESNT_WAIT]) g_AchProgress[id][ACH_DEATH_DOESNT_WAIT]=0;
    if(!g_AchUnlocked[id][59]) { g_AchProgress[id][59]=0; g_AchUnlocked[id][59]=false; }
    if(!g_AchUnlocked[id][ACH_STUBBORN]) g_AchProgress[id][ACH_STUBBORN]=0;
    if(!g_AchUnlocked[id][ACH_SKULL_CRUSHER]) g_AchProgress[id][ACH_SKULL_CRUSHER]=0;
    // Clear partial progress from the previous Tank requirement and from
    // old Vertical Attack toggle-counting; preserve already-unlocked records.
    if(!g_AchUnlocked[id][59]) g_AchProgress[id][59]=0;
}

public ach_save(id)
{
    if(!g_AchVault || !is_user_connected(id)) return;
    new auth[40], key[96], data[2048], len=0;
    get_user_authid(id,auth,charsmax(auth));
    if(equal(auth,"STEAM_ID_PENDING") || equal(auth,"BOT")) return;
    for(new i=0;i<ACH_COUNT;i++)
    {
        new value=g_AchProgress[id][i];
        if((i==ACH_ADDICTION || i==59 || i==ACH_STUBBORN || i==ACH_SKULL_CRUSHER || i==ACH_DEATH_DOESNT_WAIT) && !g_AchUnlocked[id][i]) value=0;
        len += formatex(data[len],charsmax(data)-len,"%d ",value);
    }
    formatex(key,charsmax(key),"P_%s",auth);
    nvault_set(g_AchVault,key,data);
}

stock ach_schedule_death_window_expire(id)
{
    remove_task(id+19000);
    if(id<1 || id>32 || !is_user_connected(id) || g_AchRecentKillCount[id]<=0) return;
    new Float:delay=g_AchRecentKillTimes[id][0]+10.01-get_gametime();
    if(delay<0.05) delay=0.05;
    set_task(delay,"ach_death_window_expire",id+19000);
}

public ach_death_window_expire(taskid)
{
    new id=taskid-19000;
    if(id<1 || id>32 || !is_user_connected(id) || g_AchUnlocked[id][ACH_DEATH_DOESNT_WAIT]) return;
    new Float:now=get_gametime();
    new writeIndex=0;
    for(new k=0;k<g_AchRecentKillCount[id];k++)
    {
        if(now < g_AchRecentKillTimes[id][k] || now-g_AchRecentKillTimes[id][k] > 10.0) continue;
        g_AchRecentKillTimes[id][writeIndex]=g_AchRecentKillTimes[id][k];
        g_AchRecentKillVictims[id][writeIndex]=g_AchRecentKillVictims[id][k];
        writeIndex++;
    }
    g_AchRecentKillCount[id]=writeIndex;
    g_AchProgress[id][ACH_DEATH_DOESNT_WAIT]=writeIndex;
    ach_save(id);
    if(writeIndex>0) ach_schedule_death_window_expire(id);
}

stock ach_track_ap_gain(id, amount, bool:gladiusSteal)
{
    if(id<1 || id>32 || !is_user_connected(id) || amount<=0) return;
    if(gladiusSteal) ach_add(id,ACH_ARMOR_ROBBER,amount);
    g_AchRoundAPGained[id]+=amount;
    if(g_AchRoundAPGained[id]>=400) ach_set(id,ACH_STUBBORN);
    else if(!g_AchUnlocked[id][ACH_STUBBORN])
    {
        g_AchProgress[id][ACH_STUBBORN]=g_AchRoundAPGained[id];
        ach_save(id);
    }
}

stock ach_add(id, ach, amount=1)
{
    if(id<1 || id>32 || !is_user_connected(id) || ach<0 || ach>=ACH_COUNT || amount<=0 || g_AchUnlocked[id][ach]) return;
    g_AchProgress[id][ach] += amount;
    if(g_AchProgress[id][ach] > g_AchTargets[ach]) g_AchProgress[id][ach]=g_AchTargets[ach];
    if(g_AchProgress[id][ach] >= g_AchTargets[ach])
    {
        g_AchUnlocked[id][ach]=true;
        new name[32]; get_user_name(id,name,charsmax(name));
        static const rarityNames[][] = {"Common","Uncommon","Rare","Epic","Legendary"};
        new category = g_AchCategories[ach];
        new article[4];
        if(category == 1 || category == 3) copy(article,charsmax(article),"an");
        else copy(article,charsmax(article),"a");
        client_print_color(0, print_team_default, "^3%s^1 has got %s %s Achievement ^4[%s]^1.",
            name, article, rarityNames[category], g_AchNames[ach]);
    }
    ach_save(id);
}

stock ach_set(id, ach)
{
    if(id<1 || id>32 || ach<0 || ach>=ACH_COUNT) return;
    ach_add(id,ach,g_AchTargets[ach]);
}

public ach_cmd_menu(id)
{
    new menu=menu_create("Achievements", "ach_menu_handler");
    menu_additem(menu,"Common Achievements","0");
    menu_additem(menu,"Uncommon Achievements","1");
    menu_additem(menu,"Rare Achievements","2");
    menu_additem(menu,"Epic Achievements","3");
    menu_additem(menu,"Legendary Achievements","4");
    menu_setprop(menu,MPROP_EXITNAME,"Back");
    menu_display(id,menu);
    return PLUGIN_HANDLED;
}

public ach_menu_handler(id,menu,item)
{
    if(item==MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
    new data[8],access,callback; menu_item_getinfo(menu,item,access,data,charsmax(data),_,_,callback);
    new category=str_to_num(data);
    menu_destroy(menu);
    ach_show_category(id,id,category);
    return PLUGIN_HANDLED;
}

stock ach_show_category(viewer,target,category,page=0)
{
    if(viewer < 1 || viewer > 32 || !is_user_connected(viewer) ||
        target < 1 || target > 32 || !is_user_connected(target) ||
        category < 0 || category > 4)
        return;

    new title[64];
    static const titles[][]={"Common Achievements","Uncommon Achievements","Rare Achievements","Epic Achievements","Legendary Achievements"};
    formatex(title,charsmax(title),"%s",titles[category]);
    new menu=menu_create(title,"ach_category_handler");
    new item[64],info[8];

    for(new i=0;i<ACH_COUNT;i++)
    {
        // Insert the new Legendary pair after the existing special challenges
        // and immediately before Silent Reaper / the 300-kill weapon set.
        if(category==4 && i==78)
        {
            for(new special=ACH_DEATH_DOESNT_WAIT;special<=ACH_ADDICTION;special++)
            {
                formatex(item,charsmax(item),"%s %d/%d",g_AchNames[special],g_AchProgress[target][special],g_AchTargets[special]);
                num_to_str(special,info,charsmax(info));
                menu_additem(menu,item,info);
            }
        }
        if(g_AchCategories[i]!=category || i==ACH_DEATH_DOESNT_WAIT || i==ACH_ADDICTION) continue;
        // Keep menu rows short; the full explanation is printed privately in chat.
        formatex(item,charsmax(item),"%s %d/%d",g_AchNames[i],g_AchProgress[target][i],g_AchTargets[i]);
        num_to_str(i,info,charsmax(info));
        menu_additem(menu,item,info);
    }

    menu_setprop(menu,MPROP_EXITNAME,"Back");
    g_AchMenuTarget[viewer]=target;
    g_AchMenuCategory[viewer]=category;
    menu_display(viewer,menu,page);
}

public ach_category_handler(id,menu,item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ach_cmd_menu(id);
        return PLUGIN_HANDLED;
    }

    new data[8],access,callback;
    menu_item_getinfo(menu,item,access,data,charsmax(data),_,_,callback);
    new ach=str_to_num(data);
    new target=g_AchMenuTarget[id];
    new category=g_AchMenuCategory[id];
    new page=item / 7;
    menu_destroy(menu);

    if(ach>=0 && ach<ACH_COUNT && target>=1 && target<=32 && is_user_connected(target))
    {
        client_print(id,print_chat,"[Achievements] %s: %s (%d/%d)",
            g_AchNames[ach],g_AchDescriptions[ach],
            g_AchProgress[target][ach],g_AchTargets[ach]);
    }

    // Reopen the same category and page automatically after displaying the explanation.
    ach_show_category(id,id,category,page);
    return PLUGIN_HANDLED;
}

public ach_cmd_list(id)
{
    new args[64]; read_args(args,charsmax(args)); remove_quotes(args); trim(args);
    if(!args[0]) { ach_show_unlocked(id,id); return PLUGIN_HANDLED; }
    new target=cmd_target(id,args,0);
    if(!target) { client_print(id,print_chat,"[Achievements] Player not found."); return PLUGIN_HANDLED; }
    ach_show_unlocked(id,target);
    return PLUGIN_HANDLED;
}

public ach_say_router(id)
{
    new text[96]; read_args(text,charsmax(text)); remove_quotes(text); trim(text);
    if(equali(text,"/achieve")) { ach_cmd_menu(id); return PLUGIN_HANDLED; }
    if(equali(text,"/achievements")) { ach_show_unlocked(id,id); return PLUGIN_HANDLED; }
    if(containi(text,"/achievements ")==0)
    {
        new name[64]; copy(name,charsmax(name),text[14]); trim(name);
        new target=cmd_target(id,name,0);
        if(target) ach_show_unlocked(id,target);
        else client_print(id,print_chat,"[Achievements] Player not found.");
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}

stock ach_show_unlocked(viewer,target,page=0)
{
    if(viewer < 1 || viewer > 32 || !is_user_connected(viewer) ||
        target < 1 || target > 32 || !is_user_connected(target))
        return;

    new name[32],title[64],menu;
    get_user_name(target,name,charsmax(name));
    formatex(title,charsmax(title),"%s: Unlocked",name);
    menu=menu_create(title,"ach_unlocked_handler");

    new info[8],count=0;
    for(new i=0;i<ACH_COUNT;i++)
    {
        if(i==78)
        {
            for(new special=ACH_DEATH_DOESNT_WAIT;special<=ACH_ADDICTION;special++)
                if(g_AchUnlocked[target][special])
                {
                    num_to_str(special,info,charsmax(info));
                    menu_additem(menu,g_AchNames[special],info);
                    count++;
                }
        }
        if(i==ACH_DEATH_DOESNT_WAIT || i==ACH_ADDICTION || !g_AchUnlocked[target][i]) continue;
        num_to_str(i,info,charsmax(info));
        menu_additem(menu,g_AchNames[i],info);
        count++;
    }
    if(!count) menu_additem(menu,"No achievements unlocked yet","-1",0);

    menu_setprop(menu,MPROP_EXITNAME,"Close");
    g_AchMenuTarget[viewer]=target;
    menu_display(viewer,menu,page);
}

public ach_unlocked_handler(id,menu,item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[8],access,callback;
    menu_item_getinfo(menu,item,access,data,charsmax(data),_,_,callback);
    new ach=str_to_num(data);
    new target=g_AchMenuTarget[id];
    new page=item / 7;
    menu_destroy(menu);

    if(ach>=0 && ach<ACH_COUNT && target>=1 && target<=32 && is_user_connected(target))
        client_print(id,print_chat,"[Achievements] %s: %s",
            g_AchNames[ach],g_AchDescriptions[ach]);

    // Keep the target's unlocked-achievement list open after selecting a name.
    if(target>=1 && target<=32 && is_user_connected(target))
        ach_show_unlocked(id,target,page);
    return PLUGIN_HANDLED;
}


public ach_round_start()
{
    remove_task(98101);
    remove_task(98102);
    // Snapshot each player's killer from the previous round for Revenge.
    for(new id=1;id<=32;id++)
    {
        g_AchPreviousRoundKiller[id]=g_AchLastRoundKiller[id];
        g_AchLastRoundKiller[id]=0;
    }
    new players[32], playerCount;
    get_players(players,playerCount,"h");
        new ctCount=0, tCount=0;
    for(new i=0;i<playerCount;i++)
    {
        new player=players[i];
        if(cs_get_user_team(player)==CS_TEAM_CT) ctCount++;
        else if(cs_get_user_team(player)==CS_TEAM_T) tCount++;
    }
    g_AchRoundResultHandled=false;
    for(new id=1;id<=32;id++) if(is_user_connected(id))
    {
        if(!g_AchUnlocked[id][ACH_DEATH_DOESNT_WAIT] && g_AchRecentKillCount[id]>0 && get_gametime()<g_AchRecentKillTimes[id][0])
        {
            g_AchRecentKillCount[id]=0;
            g_AchProgress[id][ACH_DEATH_DOESNT_WAIT]=0;
            remove_task(id+19000);
        }
        g_AchRoundTeamSize[id]=(cs_get_user_team(id)==CS_TEAM_CT) ? ctCount : ((cs_get_user_team(id)==CS_TEAM_T) ? tCount : 0);
        g_AchRoundEnemySize[id]=(cs_get_user_team(id)==CS_TEAM_CT) ? tCount : ((cs_get_user_team(id)==CS_TEAM_T) ? ctCount : 0);
        g_AchRoundKills[id]=0; g_AchRoundParries[id]=0; g_AchRoundBackstabs[id]=0; g_AchSpecialRoundKills[id]=0;
        if(!g_AchUnlocked[id][7]) g_AchProgress[id][7]=0;
        if(!g_AchUnlocked[id][59]) g_AchProgress[id][59]=0;
        if(!g_AchUnlocked[id][ACH_STUBBORN]) g_AchProgress[id][ACH_STUBBORN]=0;
        if(!g_AchUnlocked[id][ACH_SKULL_CRUSHER]) g_AchProgress[id][ACH_SKULL_CRUSHER]=0;
        g_AchRoundTookDamage[id]=false; g_AchRoundDamageTaken[id]=0;
        g_AchFallPending[id]=false; g_AchPanParryKiller[id]=0; g_AchCleaverExecVictim[id]=0;
        g_AchRoundLightOnly[id]=1; g_AchRoundLightHits[id]=0; g_AchRoundAPGained[id]=0;
        arrayset(g_AchDamageByOpponent[id],0,33);
                g_AchKickOwner[id]=0; g_AchBonelessOwner[id]=0; g_AchBonelessUntil[id]=0.0; g_AchBackstabOwner[id]=0;
        g_AchKickOnlyOwner[id]=0; g_AchKickOnlyBroken[id]=false; g_AchStunOwner[id]=0;
        g_AchStunnedHitBy[id]=0; g_AchVulnerabilityOwner[id]=0; g_AchBombKiller[id]=0; g_AchThornsKiller[id]=0;
        g_AchWallBounceLethal[id]=false; g_AchWallBouncePending[id]=false; g_AchWallBounceUntil[id]=0.0;
        ach_save(id);
        client_print(id,print_chat,"Type /achieve to open achievements menu.");
    }
}
// Delay result evaluation by a frame so GoldSrc has completed its death-state
// updates before survivor counts are sampled. Log and audio events are both
// registered; the round-result guard ensures only one evaluation is applied.
public ach_ct_win() { remove_task(98101); set_task(0.1,"ach_ct_win_delayed",98101); }
public ach_t_win() { remove_task(98102); set_task(0.1,"ach_t_win_delayed",98102); }
public ach_ct_win_audio() { remove_task(98101); set_task(0.1,"ach_ct_win_delayed",98101); }
public ach_t_win_audio() { remove_task(98102); set_task(0.1,"ach_t_win_delayed",98102); }
public ach_ct_win_delayed() { ach_finish_round(CS_TEAM_CT); }
public ach_t_win_delayed() { ach_finish_round(CS_TEAM_T); }
public ach_round_draw()
{
    remove_task(98101);
    remove_task(98102);
    g_AchRoundResultHandled=true;
    for(new id=1;id<=32;id++) if(is_user_connected(id)) g_AchTeamWinStreak[id]=0;
}
stock ach_finish_round(CsTeams:winningTeam)
{
    // Prevent duplicate processing from the team-win log and SendAudio events.
    if(g_AchRoundResultHandled) return;
    g_AchRoundResultHandled=true;
    new teamAlive=0, enemyAlive=0;
    for(new other=1;other<=32;other++) if(is_user_alive(other))
    {
        if(cs_get_user_team(other)==winningTeam) teamAlive++;
        else if(cs_get_user_team(other)!=CS_TEAM_UNASSIGNED && cs_get_user_team(other)!=CS_TEAM_SPECTATOR) enemyAlive++;
    }
    for(new id=1;id<=32;id++) if(is_user_connected(id))
    {
        if(cs_get_user_team(id)==winningTeam)
        {
            g_AchTeamWinStreak[id]++;
            if(g_AchTeamWinStreak[id]>=3) ach_set(id,3);
            if(is_user_alive(id) && get_user_health(id)==1) ach_set(id,57);
            if(g_AchRoundLightOnly[id] && g_AchRoundLightHits[id]>0) ach_set(id,61);
            if(is_user_alive(id) && !g_AchRoundTookDamage[id]) ach_set(id,60);
            if(is_user_alive(id) && teamAlive==1 && enemyAlive==0 &&
                g_AchRoundTeamSize[id]>=2 && g_AchRoundKills[id]>=g_AchRoundEnemySize[id])
            {
                if(p1_g_Melee[id]==p1_MELEE_LONGSWORD) ach_set(id,45);
                if(p1_g_Melee[id]==p1_MELEE_KATANA) ach_set(id,46);
            }
            if(is_user_alive(id) && g_AchRoundTeamSize[id]==1 && g_AchRoundEnemySize[id]>=3)
                ach_set(id,77);
        }
        else g_AchTeamWinStreak[id]=0;
    }
}

stock ach_on_death(victim)
{
    if(victim<1 || victim>32) return;
    // A death breaks the Tank survival attempt; a respawn must start fresh.
    if(!g_AchUnlocked[victim][59])
    {
        g_AchRoundDamageTaken[victim]=0;
        g_AchProgress[victim][59]=0;
    }
    // Clear any earlier killer; ach_on_kill immediately below will restore
    // this only when the current death was caused by an opponent.
    g_AchLastRoundKiller[victim]=0;
    if(g_AchPanParryKiller[victim]>0) { ach_set(g_AchPanParryKiller[victim],64); g_AchPanParryKiller[victim]=0; }

    // Boneless belongs to the victim when the wall impact kills them or
    // the bounce causes a fall death within the short impact window.
    if(g_AchWallBouncePending[victim] && get_gametime()<=g_AchWallBounceUntil[victim] &&
        (g_AchWallBounceLethal[victim] || g_AchFallPending[victim]))
    {
        ach_set(victim,34);
        // If the wall-bounce death came from a kick and no other damage broke
        // the kick-only chain, credit the kicker for Foot Work as well.
        if(g_AchKickOnlyOwner[victim]>0 && !g_AchKickOnlyBroken[victim])
            ach_set(g_AchKickOnlyOwner[victim],94);
    }
    g_AchWallBounceLethal[victim]=false;
    g_AchWallBouncePending[victim]=false;
    g_AchWallBounceUntil[victim]=0.0;
    g_AchBonelessOwner[victim]=0;
    g_AchBonelessUntil[victim]=0.0;

    if(g_AchFallPending[victim])
    {
        g_AchFallPending[victim]=false; g_AchFallDeaths[victim]++;
        ach_add(victim,25,1); ach_add(victim,35,1); ach_add(victim,41,1);
    }
}

stock ach_on_kill(attacker,victim)
{
    if(attacker<1 || attacker>32 || victim<1 || victim>32 || attacker==victim || !is_user_connected(attacker)) return;
    if(get_user_team(attacker)==get_user_team(victim)) return;
    if(g_AchKickOnlyOwner[victim] == attacker && !g_AchKickOnlyBroken[victim])
        ach_set(attacker,94);
    if(g_AchBombKiller[victim]==attacker) { ach_add(attacker,42,1); g_AchBombKiller[victim]=0; }
    if(g_AchThornsKiller[victim]==attacker) { ach_add(attacker,39,1); g_AchThornsKiller[victim]=0; }
    if(g_AchStunnedHitBy[victim]==attacker) { ach_set(attacker,32); g_AchStunnedHitBy[victim]=0; }
    if(g_AchVulnerabilityOwner[victim]>0 && g_AchVulnerabilityOwner[victim]!=victim && p1_g_Vulnerable[victim]) { ach_set(g_AchVulnerabilityOwner[victim],70); g_AchVulnerabilityOwner[victim]=0; }
    g_AchTotalKills[attacker]++; g_AchRoundKills[attacker]++;
    ach_add(attacker,0,1); ach_add(attacker,1,1); ach_add(attacker,2,1);
    ach_add(attacker,ACH_ADDICTION,1);
    // Keep each distinct opponent killed in the last ten seconds. Repeated
    // kills on the same opponent do not inflate the three-opponent challenge.
    new Float:killNow=get_gametime();
    new victimUserid=get_user_userid(victim);
    new writeIndex=0;
    new bool:alreadyCounted=false;
    for(new k=0;k<g_AchRecentKillCount[attacker];k++)
    {
        if(killNow < g_AchRecentKillTimes[attacker][k] || killNow-g_AchRecentKillTimes[attacker][k] > 10.0) continue;
        g_AchRecentKillTimes[attacker][writeIndex]=g_AchRecentKillTimes[attacker][k];
        g_AchRecentKillVictims[attacker][writeIndex]=g_AchRecentKillVictims[attacker][k];
        if(g_AchRecentKillVictims[attacker][k]==victimUserid) alreadyCounted=true;
        writeIndex++;
    }
    if(!alreadyCounted && writeIndex<32)
    {
        g_AchRecentKillTimes[attacker][writeIndex]=killNow;
        g_AchRecentKillVictims[attacker][writeIndex]=victimUserid;
        writeIndex++;
    }
    g_AchRecentKillCount[attacker]=writeIndex;
    if(!g_AchUnlocked[attacker][ACH_DEATH_DOESNT_WAIT])
    {
        g_AchProgress[attacker][ACH_DEATH_DOESNT_WAIT]=writeIndex;
        if(writeIndex>=3)
        {
            ach_set(attacker,ACH_DEATH_DOESNT_WAIT);
            remove_task(attacker+19000);
        }
        else
        {
            ach_save(attacker);
            ach_schedule_death_window_expire(attacker);
        }
    }
    ach_add(attacker,56,1);
    new weapon=p1_g_Melee[attacker];
    if(weapon>=0 && weapon<16)
    {
        g_AchWeaponKills[attacker][weapon]++;
        if(weapon==p1_MELEE_CLAWS || weapon==p1_MELEE_SAIS || weapon==p1_MELEE_GAUNTLETS)
        {
            g_AchSpecialRoundKills[attacker]++;
            if(g_AchSpecialRoundKills[attacker]>=2) ach_set(attacker,49);
        }
        if(weapon<16) ach_add(attacker,9+weapon,1);
        ach_add(attacker,78+weapon,1);
        new bool:allTen=true;
        for(new w=0;w<16;w++) if(g_AchProgress[attacker][78+w]<10) allTen=false;
        if(allTen) ach_set(attacker,66);
    }
    if(g_AchRoundKills[attacker]>=2) ach_set(attacker,28);
    if(g_AchRoundKills[attacker]>=4) ach_set(attacker,29);
    if(g_AchCleaverExecVictim[attacker]==victim) { ach_set(attacker,26); g_AchCleaverExecVictim[attacker]=0; }
    if(Mech_IsStunned(victim)) ach_set(attacker,32);
    if(g_AchPreviousRoundKiller[attacker]==victim) ach_set(attacker,8);
    if(p1_g_Melee[victim]==p1_MELEE_KATANA)
    {
        if(g_AchLastKiller[attacker]==victim) g_AchKillerStreak[attacker]++;
        else { g_AchLastKiller[attacker]=victim; g_AchKillerStreak[attacker]=1; }
        if(g_AchKillerStreak[attacker]>=5) ach_set(attacker,37);
    }
    else { g_AchLastKiller[attacker]=0; g_AchKillerStreak[attacker]=0; }
    g_AchKillerStreak[victim]=0;
    if(p1_g_Melee[attacker]==p1_MELEE_SCYTHE && p1_g_ScytheCloaked[attacker]) ach_add(attacker,68,1);
    if(p1_g_Melee[attacker]==p1_MELEE_GLAIVE && p1_g_GlaiveBerserk[attacker]) ach_add(attacker,43,1);
    if(p1_g_Melee[attacker]==p1_MELEE_CLEAVER && p1_g_Melee[victim]==p1_MELEE_GLAIVE) ach_set(attacker,44);
    g_AchLastRoundKiller[victim]=attacker;
}

stock ach_on_parry(id,bool:shockwave)
{
    ach_set(id,5); g_AchParryCount[id]++; g_AchRoundParries[id]++;
    ach_add(id,50,1);
    if(g_AchRoundParries[id]>=5) ach_set(id,30);
    if(shockwave) ach_set(id,58);
}
stock ach_on_block(id)
{
    g_AchBlockCount[id]++; ach_add(id,4,1); ach_add(id,51,1);
}
stock ach_on_backstab(id,victim)
{
    ach_set(id,6); g_AchRoundBackstabs[id]++; ach_add(id,63,1); g_AchBackComboVictim[id]=victim; g_AchBackstabOwner[victim]=id;
    if(g_AchRoundBackstabs[id]>=2) ach_set(id,33);
}

public ach_damage_post(victim,inflictor,attacker,Float:damage,damagebits)
{
    // Tank: the player must accumulate at least 401 damage in this round
    // and still be alive after the damage event that reaches the threshold.
    if(victim>=1 && victim<=32 && is_user_connected(victim) && is_user_alive(victim) &&
        !g_AchUnlocked[victim][59] && g_AchRoundDamageTaken[victim]>=401)
    {
        ach_set(victim,59);
    }
}

public ach_damage_pre(victim,inflictor,attacker,Float:damage,damagebits)
{
    if(victim>=1 && victim<=32 && damage>0.0 && (damagebits & DMG_FALL) && !(damagebits & ACH_DMG_WALL_BOUNCE))
    {
        g_AchFallPending[victim]=true;
    }
    if(victim>=1 && victim<=32 && damage>0.0 && (damagebits & ACH_DMG_WALL_BOUNCE) &&
        get_user_health(victim)<=floatround(damage))
        g_AchWallBounceLethal[victim]=true;
    if(victim>=1 && victim<=32 && damage>0.0)
    {
        g_AchRoundTookDamage[victim]=true;
        g_AchRoundDamageTaken[victim]+=floatround(damage);
        if(!g_AchUnlocked[victim][59])
        {
            g_AchProgress[victim][59]=g_AchRoundDamageTaken[victim];
            if(g_AchProgress[victim][59]>g_AchTargets[59]) g_AchProgress[victim][59]=g_AchTargets[59];
        }

        // Foot Work: every damaging event must come from the same player's
        // active kick. A wall-impact fall caused by that recorded kick is
        // treated as part of the kick; any unrelated damage invalidates it.
        if(attacker>=1 && attacker<=32 && attacker!=victim && is_user_connected(attacker))
        {
            new bool:isKickDamage = (p2_g_Kicking[attacker] &&
                (damagebits & p2_DMG_CUSTOM_MELEE) &&
                g_AchKickOwner[victim] == attacker);

            if(isKickDamage)
            {
                if(g_AchKickOnlyOwner[victim] == 0)
                    g_AchKickOnlyOwner[victim] = attacker;
                else if(g_AchKickOnlyOwner[victim] != attacker)
                    g_AchKickOnlyBroken[victim] = true;
            }
            else
                g_AchKickOnlyBroken[victim] = true;
        }
        else
        {
            new bool:isKickWallImpact = ((damagebits & DMG_FALL) &&
                g_AchBonelessOwner[victim] > 0 &&
                g_AchKickOnlyOwner[victim] == g_AchBonelessOwner[victim] &&
                get_gametime() <= g_AchBonelessUntil[victim]);
            if(!isKickWallImpact)
                g_AchKickOnlyBroken[victim] = true;
        }
    }
    if(victim<1 || victim>32 || attacker<1 || attacker>32 || victim==attacker || damage<=0.0) return HAM_IGNORED;
    if(!is_user_connected(victim) || !is_user_connected(attacker)) return HAM_IGNORED;
    if((damagebits & p1_DMG_PARRY_COUNTER) && get_user_health(victim)<=floatround(damage)) g_AchPanParryKiller[victim]=attacker;
    if((damagebits & p1_CLEAVER_EXECUTE_FLAG) && attacker>=1 && attacker<=32) g_AchCleaverExecVictim[attacker]=victim;
    if(get_user_team(victim)==get_user_team(attacker)) return HAM_IGNORED;
    if(!(get_user_weapon(attacker)==CSW_KNIFE && p1_g_AttackType[attacker]==1 &&
        !(damagebits & (p1_DMG_CUSTOM_MELEE | p1_DMG_PARRY_COUNTER))))
        g_AchRoundLightOnly[attacker]=0;
    if(get_user_weapon(attacker)==CSW_KNIFE && !(damagebits & (p1_DMG_CUSTOM_MELEE | p1_DMG_PARRY_COUNTER)) && p1_g_HitGroup[attacker]==HIT_HEAD)
        ach_add(attacker,ACH_SKULL_CRUSHER,1);
    if(get_user_health(victim)<=floatround(damage))
    {
        if(g_AchDamageByOpponent[victim][attacker]==0) ach_set(attacker,47);
        if(get_user_health(victim)==1) ach_set(attacker,27);
    }
    if(p1_g_Melee[attacker]==p1_MELEE_GLAIVE && p1_g_Melee[victim]==p1_MELEE_CLEAVER &&
        get_user_health(attacker)<80 && p1_g_Vulnerable[victim]) ach_set(attacker,75);
    g_AchDamageByOpponent[victim][attacker]+=floatround(damage);
    if(g_AchLastHitVictim[attacker]==victim) g_AchConsecutiveHits[attacker]++;
    else { g_AchLastHitVictim[attacker]=victim; g_AchConsecutiveHits[attacker]=1; }
    if(g_AchConsecutiveHits[attacker]>=7) ach_set(attacker,36);
    g_AchConsecutiveHits[victim]=0; g_AchLastHitVictim[victim]=0;
    if(p1_g_Melee[attacker]==p1_MELEE_PAN && p1_g_HitGroup[attacker]==HIT_HEAD) ach_add(attacker,31,1);
    if(p1_g_Melee[attacker]==p1_MELEE_SCYTHE && p1_g_ScytheCloaked[attacker]) ach_add(attacker,68,1);
    if(p1_g_Melee[attacker]==p1_MELEE_GREATSWORD && p1_IsSuppressed(attacker) && (p4_g_ParryActive[victim] || p5_g_bBlockActive[victim])) ach_set(victim,55);
    return HAM_IGNORED;
}

public ach_airborne_check()
{
    for(new id=1;id<=32;id++) if(is_user_alive(id))
    {
        new flags=pev(id,pev_flags);
        if(!(flags & FL_ONGROUND) && !(flags & FL_INWATER))
        {
            if(g_AchAirStart[id]<=0.0) g_AchAirStart[id]=get_gametime();
            else if(get_gametime()-g_AchAirStart[id]>=10.0) ach_set(id,76);
        }
        else g_AchAirStart[id]=0.0;
    }
}

public plugin_end()
{
    if(g_AchVault != INVALID_HANDLE) nvault_close(g_AchVault);
}


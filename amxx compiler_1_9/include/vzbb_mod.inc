/*
---------------------------------------------------------
   #  #  #    #===    ###    ##    #
  #    ##     #===   #      #  #    #
   #   #      #===    ###    ##    #
---------------------------------------------------------
vzbb_mod.inc
Library by <VeCo>

<VeCo>'s Zombie BaseBuilder Mod 4.0

If you modify the code, please DO NOT change the author!
---------------------------------------------------------
Contacts:
e-mail: veco.kn@gmail.com
skype: veco_kn
---------------------------------------------------------
Changes log:
 -> v 1.0 = First release!
 -> v 1.1 = Fixed double user_infect_pre. The second is
	    changed to user_infect_post.
 -> v 3.0 = Defines changed to enums.
	    Added itemteam parameter in register_shop_item
	    function and TEAM_* enum.
	    Added set_user_zombie_class native.
	    Added user_uninfect native.
	    Added grab/release block forwards.
 -> v 3.4 = Added is_user_frozen_cool native.
	    Added user_freeze_cool_* forwards.
	    Added user_freeze_cool and user_unfreeze_cool
	    natives.
 -> v 3.5 = Added get_block_fun_type and set_block_fun_type
	    natives and BLOCKS_* enum.
	    Added get_deal_discount and is_deal_offer natives.
 -> v 3.8 = Added set_user_was_zombie native.
	    Added access parameters in register_zombie_class
	    and register_shop_item natives.
	    Fixed a typo.
	    Added FORWARD_CONTINUE define for the forward
	    block ability.
	    Added set_user_can_build native.
	    Added hide_barrierent and reset_barrierent natives.
	    Added update_user_hud_data forward and set_hud_cache_*
	    natives for it.
	    Added force_user_hud_data and force_weapon_menu natives.
 -> v 3.9 = Added user_uninfect_pre and user_uninfect_post forwards.
	    Added battle_phase_begin_admin forward.
	    Added fun_block_touch_pre and fun_block_touch_post forwards.
 -> v 4.0 = Added ability to block shop_item_selected forward. (and changed
	    the way Item Buy System works)
	    Added maxbuys parameter in register_shop_item and NO_MAX_BUYS
	    define for it.
	    Added restore_user_rendering native.
---------------------------------------------------------
Don't forget to visit http://www.amxmodxbg.org :)
---------------------------------------------------------
*/

#if defined _vzbb_mod_included
	#endinput
#endif

#define _vzbb_mod_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib vzbb_mod
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib vzbb_mod
	#endif
#else
	#pragma library vzbb_mod
#endif

/*=======================================================================
                           -= Define-и =- 
========================================================================*/

#define FORWARD_CONTINUE 777 // return ... (блокира forward)

#define NO_MAX_BUYS 0 // неограничен брой пъти купуване на итем

/*=======================================================================
                           -= Enum-и =- 
========================================================================*/

// Кога може да се ползва итема?
enum
{
	USE_BATTLE = 0,
	USE_BUILD,
	USE_BOTH
}

// Кой може да ползва итема?
enum
{
	TEAM_ZOMBIES = 1,
	TEAM_HUMANS,
	TEAM_BOTH
}

// Как се движи блока?
enum
{
	BLOCK_PULL = 1,
	BLOCK_PUSH
}

// Какъв режим се игра този рунд?
enum
{
	MODE_NORMAL = 0,
	MODE_INFECTION
}

// Каква граната е хвърлена?
enum
{
	NADE_HE = 1,
	NADE_SMOKE,
	NADE_FLASH
}

// Какъв тип забавен блок е това?
enum
{
	BLOCKS_NORMAL = 0,
	BLOCKS_YELLOW,
	BLOCKS_BLACK,
	BLOCKS_BLUE,
	BLOCKS_RED
}

/*=======================================================================
                           -= Нативи =- 
========================================================================*/

/* :: Регистрира нов зомби клас

#classname -  Името на зомби класа (пример: "Test Zombie")
#classinfo - Кратка информация относно зомби класа (пример: "g+ s-")
#classmdl - Модел на зомби класа (пример: "zombie" , трябва да се намира в models/player/име/име.mdl)
#classclawmdl - Модел на ръцете на зомби класа (пример: "claw" , трябва да се намира в models/име.mdl)
#health - Кръв на зомби класа (пример: 2000)
#gravity - Гравитация на зомби класа (пример: 0.5) (1.0 = 800 гравитаця , 0.5 = 400 гравитация ...)
#speed - Скорост на зомби класа (пример: 400.0) (0.0 = нормална скорост)
#access - Админ достъп нужен за избиране на класа (ADMIN_ALL - за всички)

::::: Фунцкията връща иднекса на класа. (int)
*/

native register_zombie_class(const classname[],const classinfo[], const classmdl[],const classclawmdl[], health,Float:gravity,Float:speed, access)

/* :: Регистрира нов итем в shop менюто

#itemname - Името на итема (пример: "Test Item")
#itemcost - Цена на итема (пример: 15)
#itemuse - Кога да може да се използва итема? (USE_BATTLE - в бойната фаза , USE_BUILD - в строителната фаза , USE_BOTH - и в двете фази)
#itemteam - Кой може да купува итема? (TEAM_ZOMBIES - зомбитата , TEAM_HUMANS - хората , TEAM_BOTH - всички)
#access - Админ достъп нужен за купуване на итема (ADMIN_ALL - за всички)
#maxbuys - Колко пъти да може да се купи итемът на рунд? (NO_MAX_BUYS - неограничен брой пъти)

::::: Фунцкията връща иднекса на итема. (int)
*/

native register_shop_item(const itemname[], itemcost, itemuse, itemteam, access, maxbuys)

/* :: Връща иднекса на класа на играча (-1 ако е Classic Zombie)

#id - индекс на играча

::::: Фунцкията връща иднекса на класа на играча. (int)
*/

native get_user_zombie_class(id)

/* :: Задава иднекса на класа на играча

#id - индекс на играча
#classid - индекс на зомби класа (-1 - Classic Zombie)
*/

native set_user_zombie_class(id,classid)

/* :: Връща съответна стойност ако играчът е зомби

#id - индекс на играча

::::: Фунцкията връща true ако е зомби и false - ако не е. (bool)
*/

native is_user_zombie(id)

/* :: Връща съответна стойност ако играчът е човек

#id - индекс на играча

::::: Фунцкията връща true ако е човек и false - ако не е. (bool)
*/

native is_user_human(id)

/* :: Връща стойността на кредитите на играч

#id - индекс на играча

::::: Фунцкията връща кредитите на играч. (int)
*/

native get_user_credits(id)

/* :: Задава стойността на кредитите на играч

#id - индекс на играча
#credits - стойността на кредитите, които искаме да зададем (използвайте с get_user_credits ако искате да прибавите/премахнете кредити на играч)
*/

native set_user_credits(id,credits)

/* :: Връща стойността на разстоянието на играч между последния блок, който е движел

#id - индекс на играча

::::: Фунцкията връща разстоянието на играч между последния блок, който е движел. (float)
*/

native get_user_block_distance(id)

/* :: Задава стойността на разстоянието на играч между последния блок, който е движел

#id - индекс на играча
#dist - стойността на разстоянието на играч между последния блок, който е движел, което искаме да зададем
*/

native set_user_block_distance(id,Float:dist)

/* :: Връща общия брой зомби класове, заредени в момента

::::: Фунцкията връща общия брой зомби класове, заредени в момента. (int)
*/

native get_total_zombie_classes()

/* :: Връща общия брой shop итеми, заредени в момента

::::: Фунцкията връща общия брой shop итеми, заредени в момента. (int)
*/

native get_total_shop_items()

/* :: Връща съответна стойност ако играчът може да строи в бойната фаза

#id - индекс на играча

::::: Фунцкията връща true ако играчът може да строи в бойната фаза и false - ако не може. (bool)
*/

native get_user_can_build_battle(id)

/* :: Задава стойността на играч, за да може да мести блокове и в бойната фаза (действа до стартирането на следващата бойна фаза)

#id - индекс на играча
#set - true : за да може да строи и false : за да не може
*/

native set_user_can_build_battle(id,set)

/* :: Връща индекс на ентитито на блока, който играчът мести в момента

#id - индекс на играча

::::: Фунцкията връща индекс на ентитито на блока, който играчът мести в момента. (int)
*/

native get_user_block_ent(id)

/* :: Задава индекс на ентитито на блока, който играчът мести в момента

#id - индекс на играча
#ent - индекс на ентитито
*/

native set_user_block_ent(id,ent)

/* :: Връща сътветна стойност ако е freezetime в момента

::::: Фунцкията връща true ако е и false - ако не е. (bool)
*/

native is_freezetime()

/* :: Връща оставащото време на строителната фаза

::::: Фунцкията връща оставащото време на строителната фаза в секунди. (int)
*/

native get_build_phase_remaining_time()

/* :: Връща сътветна стойност ако играчите могат да строят (ако в момента е строителната фаза)

::::: Фунцкията връща true ако могат и false - ако не могат. (bool)
*/

native user_can_build()

/* :: Задава дали играчите могат да строят (дали в момента е строителна фаза)

#build - true - ако могат, false - ако не могат
*/

native set_user_can_build(build)

/* :: Връща сътветна стойност на режима на игра в момента

::::: Фунцкията връща сътветна стойност на режима на игра в момента (MODE_NORMAL - нормален режим (с убийства) , MODE_INFECTION - режим с инфекции) . (int)
*/

native get_roundmode()

/* :: Връща съответна стойност ако играчът е бил зомби при раждането си

#id - индекс на играча

::::: Фунцкията връща true ако е бил зомби и false - ако не е бил. (bool)
*/

native was_user_zombie(id)

/* :: Задава стойност дали играчът е бил зомби при раждането си (ако е бил накрая на рунда ще бъде човек, използва се при инфекции)

#id - индекс на играча
#true - стойността - 1 ако е бил, 0 - ако не е
*/

native set_user_was_zombie(id,true)

/* :: Връща съответна стойност ако играчът е баннат (местенето на блоковете)

#id - индекс на играча

::::: Фунцкията връща true ако е и false - ако не е. (bool)
*/

native is_user_banned(id)

/* :: Връща стойността на оставащата кръв за взимане при горене

#id - индекс на играча

::::: Фунцкията връща стойността на оставащата кръв за взимане при горене. (int)
*/

native get_user_fire_duration(id)

/* :: Задава стойността на oставащата кръв за взимане при горене

#id - индекс на играча
#dist - стойността на oставащата кръв за взимане при горене, която искаме да зададем (1 - за да спрем горенето на играч)
*/

native set_user_fire_duration(id,duration)

/* :: Връща съответна стойност ако играчът е заледен

#id - индекс на играча

::::: Фунцкията връща true ако е и false - ако не е. (bool)
*/

native is_user_frozen(id)

/* :: Връща съответна стойност ако играчът е заледен (започва да се топи)

#id - индекс на играча

::::: Фунцкията връща true ако е и false - ако не е. (bool)
*/

native is_user_frozen_cool(id)

/* :: Запалва играч

#attacker - индекс на играча нападател
#victim - индекс на играча жертва
#duration - максимална кръв за взимане при горене (0 - стойността ще се взима от CVAR-a vzbb_grenade_fire_duration)
*/

native user_burn(attacker,victim,duration)

/* :: Заледява играч

#id - индекс на играча
*/

native user_freeze(id)

/* :: Заледява играч (играчът веднага започва да се топи)

#id - индекс на играча
*/

native user_freeze_cool(id)

/* :: Премахва заледяването на играч

#id - индекс на играча
*/

native user_unfreeze(id)

/* :: Премахва топенето на играч

#id - индекс на играча
*/

native user_unfreeze_cool(id)

/* :: Инфектира играч

#victim - индекс на жертвата
#infector - индекс на инфектиращия
*/

native user_infect(victim,infector)

/* :: Деинфектира играч

#id - индекс на играча
*/

native user_uninfect(id)

/* :: Връща забавния тип на блок

#ent - индекс на ентитито на блока

::::: Фунцкията връща забавния тип на блока (int)
*/

native get_block_fun_type(ent)

/* :: Задава забавен тип на блок

#ent - индекс на ентитито на блока
#funtype - забавен тип на блока
(BLOCKS_YELLOW - бързодвижещ се блок , BLOCKS_BLACK - недвижим блок;
BLOCKS_BLUE - забавящ блок , BLOCKS_RED - запалващ блок)
*/

native set_block_fun_type(ent,funtype)

/* :: Премахва забавния тип на блок

#ent - индекс на ентитито на блока
*/

native reset_block_fun_type(ent)

/* :: Връща стойността на намалението на "Round Deal" в съответния рунд

::::: Фунцкията връща стойността на намалението. (int)
*/

native get_deal_discount()

/* :: Връща съответна стойност дали итемът е в офертите на "Round Deal" в съответния рунд

::::: Фунцкията връща true ако е и false - ако не е. (bool)
*/

native is_deal_offer(itemid)

/* :: Премахва бариерата (ако има такава) */

native hide_barrierent()

/* :: Рестартира местоположението на бариерата (ако има такава) */

native reset_barrierent()

/* :: Задава текст за HUD-a на играчите, на мястото на HUD-a за режима (използвайте при update_user_hud_data forward-a)

#text - текстът (максимална дължина - 128 символа, стрингът трябва да е предварително форматиран)
*/

native set_hud_cache_text(text[])

/* :: Задава цвят (в RGB формат) за HUD-a на играчите, на мястото на HUD-a за режима (използвайте при update_user_hud_data forward-a)

#r - червен цвят
#g - зелен цвят
#b - син цвят
*/

native set_hud_cache_colors(r,g,b)

/* :: Задава условие за показване на HUD-a на играчите, на мястото на HUD-a за режима (използвайте при update_user_hud_data forward-a)

#condition - условие (използвайте true, за да се показва винаги при всички случаи)
*/

native set_hud_cache_condition(bool:condition)

/* :: Извиква фунцкията за показване на HUD-a на играчите */

native force_user_hud_data()

/* :: Извиква функцията за менюто за оръжия

#id - индекс на играча
*/

native force_weapon_menu(id)

/* :: Възвръща rendering-а на играча (полезно за премхване на glow и възвръщане на невидимостта на играча)

#id - индекс на играча
*/

native restore_user_rendering(id)

/*=======================================================================
                           -= Forward-и =- 
========================================================================*/

/* :: Извиква се при избиране на зомби клас

#id - индекс на играча
#classid - индекс на зомби класа
*/

forward zombie_class_selected(id,classid)

/* :: Извиква се при избиране на итем от shop менюто

#id - индекс на играча
#itemid - индекс на итема

:::::: Върнете стойност FORWARD_CONTINUE, за да блокирате купуването на даден итем.
*/

forward shop_item_selected(id,itemid)

/* :: Извиква се при теглене или бутане на блок

#id - индекс на играча
#pullpush_type - тип на местенето на блока (1 - теглене , 2 - бутане)

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward block_pull_push(id,pullpush_type)

/* :: Извиква се след започването на бойната фаза */

forward battle_phase_begin()

/* :: Извиква се след принудителното започване на бойната фаза от админ (с командата /start)

#id - индекс на администраторът, написал командата
 */

forward battle_phase_begin_admin(id)

/* :: Извиква се преди хвърляне на граната

#owner - индекс на притежателя на гранатата
#ent - индекс на ентитито на гранатата
#nade_type - тип на гранатата (1 - HE grenade (FireNade) , 2 - Smoke grenade , 3 - Flashbang (FrostNade))

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward nade_throw_pre(owner,ent,nade_type)

/* :: Извиква се след хвърляне на граната

#owner - индекс на притежателя на гранатата
#ent - индекс на ентитито на гранатата
#nade_type - тип на гранатата (1 - HE grenade (FireNade) , 2 - Smoke grenade , 3 - Flashbang (FrostNade))
*/

forward nade_throw_post(owner,ent,nade_type)

/* :: Извиква се преди всяко взимане на кръв при запалване на играч

#id -  индекс на играча
*/

forward user_burn_pre(id)

/* :: Извиква се след всяко взимане на кръв при запалване на играч

#id - индекс на играча
*/

forward user_burn_post(id)

/* :: Извиква се при премахването на горенето на играч

#id - индекс на играча
*/

forward user_remove_burn(id)

/* :: Извиква се преди замразяване на играч

#id - индекс на играча
*/

forward user_freeze_pre(id)

/* :: Извиква се след замразяване на играч

#id - индекс на играча
*/

forward user_freeze_post(id)

/* :: Извиква се преди премахването на замразяването на играч

#id - индекс на играча
*/

forward user_unfreeze_pre(id)

/* :: Извиква се след премахването на замразяването на играч

#id - индекс на играча
*/

forward user_unfreeze_post(id)

/* :: Извиква се преди играч да започне да се топи

#id - индекс на играча
*/

forward user_freeze_cool_pre(id)

/* :: Извиква се след като играч започне да се топи

#id - индекс на играча
*/

forward user_freeze_cool_post(id)

/* :: Извиква се преди играч да спре да се топи

#id - индекс на играча
*/

forward user_unfreeze_cool_pre(id)

/* :: Извиква се след като играч спре да се топи

#id - индекс на играча
*/

forward user_unfreeze_cool_post(id)

/* :: Извиква се преди инфектиране на играч

#victim - индекс на жертвата
#infector - индекс на инфектиращия

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward user_infect_pre(victim,infector)

/* :: Извиква се след инфектиране на играч

#victim - индекс на жертвата
*/

forward user_infect_post(victim)

/* :: Извиква се преди деинфектиране на играч

#id - индекс на играча

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward user_uninfect_pre(id)

/* :: Извиква се след деинфектиране на играч

#id - индекс на играча
*/

forward user_uninfect_post(id)

/* :: Извиква се преди взимане на блок

#id - индекс на играча

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward grab_block_pre(id)

/* :: Извиква се след взимане на блок

#id - индекс на играча

:::::: Върнете стойност FORWARD_CONTINUE, за да спрете изпълнението на forward-a.
*/

forward grab_block_post(id)

/* :: Извиква се преди пускането на блок

#id - индекс на играча
*/

forward release_block_pre(id)

/* :: Извиква се след пускането на блок

#id - индекс на играча
*/

forward release_block_post(id)

/* :: Извиква се при всяко обновяване на HUD-а на играчите

:::::: Върнете стойност FORWARD_CONTINUE, за да оставите работещ само HUD-a без другите функции на играчите в бойната фаза.
*/

forward update_user_hud_data()

/* :: Извиква се преди докосване на играч със забавен блок

#id - индекс на играча
#ent - индекс на ентитито на блока
#funtype - забавен тип на блока
(BLOCKS_YELLOW - бързодвижещ се блок , BLOCKS_BLACK - недвижим блок;
BLOCKS_BLUE - забавящ блок , BLOCKS_RED - запалващ блок)

:::: Върнете стойност FORWARD_CONTINUE, за да блокирате ефекта на забавния блок.
*/

forward fun_block_touch_pre(id,ent,funtype)

/* :: Извиква се след докосване на играч със забавен блок

#id - индекс на играча
#ent - индекс на ентитито на блока
#funtype - забавен тип на блока
(BLOCKS_YELLOW - бързодвижещ се блок , BLOCKS_BLACK - недвижим блок;
BLOCKS_BLUE - забавящ блок , BLOCKS_RED - запалващ блок)
*/

forward fun_block_touch_post(id,ent,funtype)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/

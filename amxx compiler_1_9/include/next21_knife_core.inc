#if defined _knife_core_included
  #endinput
#endif
#define _knife_core_included

#include <core>
#include <hud>

#define ITEM_CONTINUE			-1
#define ITEM_ALREADY_HAVE 		0
#define ITEM_NOT_AVAILABLE 		1
#define ITEM_DEAD			2
#define ITEM_ALIVE			3

enum _:Crosshair_States
{
	CrossOff,			// выключен совсем
	CrossHide,			// просто спрятан
	CrossDefault,			// стандартный, белый
	CrossCannot,			// красный, нельзя использовать абилити (хз по каким причинам)
	CrossFar,			// красный, цель слишком далеко
	CrossTime,			// крсаный, время перезарядки ещё не вышло
	CrossOk				// можно использовать абилити
}

/**
 * Вызывается перед тем ядро плагина меняет нож
 *
 * @param 	id				- Игрок
 * @param	knife_id			- id ножа, на который производится смена
 * @return		- указывайте PLUGIN_HANDLED, если нужно заблокировать смену ножа
 */
forward kc_change_knife_core_pre(id, knife_id)

/**
 * Вызывается после того как ядро плагина успешно сменит меняет нож
 *
 * @param 	id				- Игрок
 * @param	knife_id			- id ножа, на который производится смена
 */
forward kc_change_knife_core_pre(id, knife_id)

/**
 * Вызывается перед тем как игрок использует абилити
 *
 * @param 	id				- Игрок
 * @param	victim				- Жертва (если нету, то -1)
 * @return		- указывайте PLUGIN_HANDLED, если нужно заблокировать способность
 */
forward kc_ability_pre(id, victim)

/**
 * Вызывается после того как игрок использует абилити
 *
 * @param 	id				- Игрок
 * @param	victim				- Жертва (если нету, то -1)
 * @return		- 1
 */
forward kc_ability_post(id, victim)

/**
 * Регестрирует новый нож.
 *
 * @param 	menu_description		- Название ножа в главном меню.
 * @param	chat_description		- Описание ножа выводимое в чат, после его выбора.
 * @param	abilitycallback			- Функция, которая будет вызываться если возможно вызвать абилити.
 * @param	abilityreset			- Время перезарядки абилити (Float).
 * @param	hp				- Hp.
 * @param	gravity				- Гравитация (Float, от 0.0 до 1.0).
 * @param	speed				- Скорость (Float).
 * [@param]	knife_txt_name			- Устанавливает hud ножу.
 * [@param]	distmin				- Минимальная дистанция на которой работает нож (только если установлен hud ножу).
 * [@param] distmax				- Максимальная дистанция на которой работает нож (только если установлен hud ножу).
 * @return		- id ножа при успешной регистраци, в противном случае -1.
 */
native kc_register_knife(const menu_description[], const chat_description[], const abilitycallback[], const Float:abilityreset, const hp, const Float:gravity, const Float:speed, const knife_txt_name[] = "NULL", const Float:distmin = -1.0, const Float:distmax = -1.0)

/**
 * Регестрирует предмет для магазина.
 *
 * @param 	callback			- Функция, которая будет вызываться если возможно купить предмет (достаточно денег для покупки).
 * @param 	chat_text			- Сообщение которое будет выводится при удачной покупке предмета.
 * @param 	menu_text			- Название предмета в меню магазина.
 * @param 	cost				- Цена предмета.
 * @return		- 1 при успешной регистрации, в противном случае 0.
 */
native kc_register_shop_item(const callback[], const chat_text[], const menu_text[], const cost)

/**
 * Регестрирует дополнительный пункт в главном меню
 *
 * @param 	txt				- Название пункта в меню.
 * @param 	callback			- Функция, которая будет вызываться при нажатии на пункт меню.
 * @return		- 1 при успешной регистрации, в противном случае 0.
 */
native kc_register_custom_menu_item(const txt[], const callback[])

/**
 * Время когда в последний раз была использована абилити
 *
 * @param 	id				- Id игрока
 * @return		- Время когда в последний раз была использована абилити
 */
native Float:kc_get_ability_last_reset(const id)

/**
 * Получает информацию об абилити ножа.
 *
 * @param 	knife_id			- Id ножа.
 * @return		- [0] - время перезарядки абилити, [1] - Минимальная дистанция на которой работает абилити, [2] - Максимальная дистанция на которой работает абилити.
 */
native kc_get_info_ability(const knife_id, const Float:buffer[3])

/**
 * Возвращает id ножа, который есть у игрока.
 *
 * @param 	id				- Id игрока
 * @return		- Id ножа
 */
native kc_get_user_knife(const id)

/**
 * Устанавливает нож игроку.
 *
 * @param 	id				- Id игрока
 * @param 	knife_id			- Id ножа
 * @return		- 1 - нож установлен, 0 - ошибка
 */
native kc_set_user_knife(const id, const knife_id)

/**
 * Востанавливает стандартную скорость игрока исходя из того какой нож у него есть
 *
 * @param 	id				- Id игрока
 * @return		- 1
 */
native kc_reset_speed(const id)

/**
 * Востанавливает стандартную гравитацию игрока исходя из того какой нож у него есть
 *
 * @param 	id				- Id игрока
 * @return		- 1
 */
native kc_reset_gravity(const id)

/**
 * Устанавливает прицел игроку (кастомный прицел)
 *
 * @param 	id				- Id игрока
 * @param 	hide				- 0 - спрятать совсем, 1 - показать
 * @param 	state				- см Crosshair_States
 * @return		- 1
 */
native kc_set_crosshair(const id, const hide, const cross_state=CrossDefault)

/**
 * Получает состояние прицела игрока
 *
 * @param 	id				- Id игрока
 * @return		- 0 - спрятать совсем, 1 - спрятать, но в любой момент может быть показан, 2 - показать синий, 3 - показать красный
 */
native kc_get_crosshair(const id)

/**
 * Получает максимально возможно кол-во хп для игрока, зависит от ножа
 *
 * @param 	id				- Id игрока
 * @return		- кол-во hp
 */
native kc_get_user_max_hp(const id)

/**
 * Если идёт перезарядка абилки, то вернёт 1
 *
 * @param 	id				- Id игрока
 * @return		- 
 */
native kc_in_reloading(const id)

/**
 * Проверяют держит ли сейчас игрок определённый нож
 *
 * @param 	id				- Id игрока
 * @param 	knife id			- Id ножа
 * @return		- 1 - держит, 0 - какое-то другое оружие
 */
stock kc_is_user_has_knife(const id, const knife_id)
{
	if(kc_get_user_knife(id) != knife_id) return 0
	if(get_user_weapon(id) != CSW_KNIFE) return 0
	return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

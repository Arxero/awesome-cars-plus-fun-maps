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
	CrossOff,			// �������� ������
	CrossHide,			// ������ �������
	CrossDefault,			// �����������, �����
	CrossCannot,			// �������, ������ ������������ ������� (�� �� ����� ��������)
	CrossFar,			// �������, ���� ������� ������
	CrossTime,			// �������, ����� ����������� ��� �� �����
	CrossOk				// ����� ������������ �������
}

/**
 * ���������� ����� ��� ���� ������� ������ ���
 *
 * @param 	id				- �����
 * @param	knife_id			- id ����, �� ������� ������������ �����
 * @return		- ���������� PLUGIN_HANDLED, ���� ����� ������������� ����� ����
 */
forward kc_change_knife_core_pre(id, knife_id)

/**
 * ���������� ����� ���� ��� ���� ������� ������� ������ ������ ���
 *
 * @param 	id				- �����
 * @param	knife_id			- id ����, �� ������� ������������ �����
 */
forward kc_change_knife_core_pre(id, knife_id)

/**
 * ���������� ����� ��� ��� ����� ���������� �������
 *
 * @param 	id				- �����
 * @param	victim				- ������ (���� ����, �� -1)
 * @return		- ���������� PLUGIN_HANDLED, ���� ����� ������������� �����������
 */
forward kc_ability_pre(id, victim)

/**
 * ���������� ����� ���� ��� ����� ���������� �������
 *
 * @param 	id				- �����
 * @param	victim				- ������ (���� ����, �� -1)
 * @return		- 1
 */
forward kc_ability_post(id, victim)

/**
 * ������������ ����� ���.
 *
 * @param 	menu_description		- �������� ���� � ������� ����.
 * @param	chat_description		- �������� ���� ��������� � ���, ����� ��� ������.
 * @param	abilitycallback			- �������, ������� ����� ���������� ���� �������� ������� �������.
 * @param	abilityreset			- ����� ����������� ������� (Float).
 * @param	hp				- Hp.
 * @param	gravity				- ���������� (Float, �� 0.0 �� 1.0).
 * @param	speed				- �������� (Float).
 * [@param]	knife_txt_name			- ������������� hud ����.
 * [@param]	distmin				- ����������� ��������� �� ������� �������� ��� (������ ���� ���������� hud ����).
 * [@param] distmax				- ������������ ��������� �� ������� �������� ��� (������ ���� ���������� hud ����).
 * @return		- id ���� ��� �������� ����������, � ��������� ������ -1.
 */
native kc_register_knife(const menu_description[], const chat_description[], const abilitycallback[], const Float:abilityreset, const hp, const Float:gravity, const Float:speed, const knife_txt_name[] = "NULL", const Float:distmin = -1.0, const Float:distmax = -1.0)

/**
 * ������������ ������� ��� ��������.
 *
 * @param 	callback			- �������, ������� ����� ���������� ���� �������� ������ ������� (���������� ����� ��� �������).
 * @param 	chat_text			- ��������� ������� ����� ��������� ��� ������� ������� ��������.
 * @param 	menu_text			- �������� �������� � ���� ��������.
 * @param 	cost				- ���� ��������.
 * @return		- 1 ��� �������� �����������, � ��������� ������ 0.
 */
native kc_register_shop_item(const callback[], const chat_text[], const menu_text[], const cost)

/**
 * ������������ �������������� ����� � ������� ����
 *
 * @param 	txt				- �������� ������ � ����.
 * @param 	callback			- �������, ������� ����� ���������� ��� ������� �� ����� ����.
 * @return		- 1 ��� �������� �����������, � ��������� ������ 0.
 */
native kc_register_custom_menu_item(const txt[], const callback[])

/**
 * ����� ����� � ��������� ��� ���� ������������ �������
 *
 * @param 	id				- Id ������
 * @return		- ����� ����� � ��������� ��� ���� ������������ �������
 */
native Float:kc_get_ability_last_reset(const id)

/**
 * �������� ���������� �� ������� ����.
 *
 * @param 	knife_id			- Id ����.
 * @return		- [0] - ����� ����������� �������, [1] - ����������� ��������� �� ������� �������� �������, [2] - ������������ ��������� �� ������� �������� �������.
 */
native kc_get_info_ability(const knife_id, const Float:buffer[3])

/**
 * ���������� id ����, ������� ���� � ������.
 *
 * @param 	id				- Id ������
 * @return		- Id ����
 */
native kc_get_user_knife(const id)

/**
 * ������������� ��� ������.
 *
 * @param 	id				- Id ������
 * @param 	knife_id			- Id ����
 * @return		- 1 - ��� ����������, 0 - ������
 */
native kc_set_user_knife(const id, const knife_id)

/**
 * �������������� ����������� �������� ������ ������ �� ���� ����� ��� � ���� ����
 *
 * @param 	id				- Id ������
 * @return		- 1
 */
native kc_reset_speed(const id)

/**
 * �������������� ����������� ���������� ������ ������ �� ���� ����� ��� � ���� ����
 *
 * @param 	id				- Id ������
 * @return		- 1
 */
native kc_reset_gravity(const id)

/**
 * ������������� ������ ������ (��������� ������)
 *
 * @param 	id				- Id ������
 * @param 	hide				- 0 - �������� ������, 1 - ��������
 * @param 	state				- �� Crosshair_States
 * @return		- 1
 */
native kc_set_crosshair(const id, const hide, const cross_state=CrossDefault)

/**
 * �������� ��������� ������� ������
 *
 * @param 	id				- Id ������
 * @return		- 0 - �������� ������, 1 - ��������, �� � ����� ������ ����� ���� �������, 2 - �������� �����, 3 - �������� �������
 */
native kc_get_crosshair(const id)

/**
 * �������� ����������� �������� ���-�� �� ��� ������, ������� �� ����
 *
 * @param 	id				- Id ������
 * @return		- ���-�� hp
 */
native kc_get_user_max_hp(const id)

/**
 * ���� ��� ����������� ������, �� ������ 1
 *
 * @param 	id				- Id ������
 * @return		- 
 */
native kc_in_reloading(const id)

/**
 * ��������� ������ �� ������ ����� ����������� ���
 *
 * @param 	id				- Id ������
 * @param 	knife id			- Id ����
 * @return		- 1 - ������, 0 - �����-�� ������ ������
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

/**
 * ������: he_kill_him
 * ��������� �������� ������, ���� ����� ��������� � ��������� victim � ������� ������� timer ���� �� ������� ��� �� ����-�� ���������
 *
 * @param 	victim				- ������
 * @param	attacker			- ���������, ��� ���� ����� �������� ����
 * @param	timer				- ����� ��������
 * @return		- 1
 */
native ka_set_attacker(const victim, const attacker, const Float:timer)

/**
 * ������: next21_knife_flash
 * ���������, ������� �� ����� Flash �����
 *
 * @param 	id				- �����
 * @return		- true - �������, false - �� �������
 */
native bool:ka_is_flashed(const id)

/**
 * ������: next21_knife_fire
 * ���������, ����� �� �����, ������� ������� Fire �����
 *
 * @param 	id				- �����
 * @return		- true - �����, false - �� �����
 */
native bool:ka_is_burning(const id)

/**
 * ������: next21_knife_fire
 * ������������� ������� ������, ������� ��� ������� Fire �����
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_stop_fire(const id)

/**
 * ������: next21_knife_frost
 * ������������� ������
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_unfreez(const id)

/**
 * ������: next21_knife_frost
 * ������� �����, ����� ����� � ������ ���������
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_unchill(const id)

/**
 * ������: next21_knife_frost
 * ��������� ���� ����� ���������
 *
 * @param 	id				- �����
 * @return		- true - �������, false - �� �������
 */
native bool:ka_in_ffreez(const id)

/**
 * ������: next21_knife_frost
 * ��������� ���� ����� chilled
 *
 * @param 	id				- �����
 * @return		- true - �������, false - �� �������
 */
native bool:ka_in_fchill(const id)

/**
 * ������: next21_item_frost_gaz
 * ������������� ������
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_gren_unfreez(const id)

/**
 * ������: next21_item_frost_gaz
 * ������� �����, ����� ����� � ������ ���������
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_gren_unchill(const id)

/**
 * ������: next21_item_frost_gaz
 * ��������� ���� ����� ���������
 *
 * @param 	id				- �����
 * @return		- true - �������, false - �� �������
 */
native bool:ka_in_fgrenfreez(const id)

/**
 * ������: next21_item_frost_gaz
 * ��������� ���� ����� chilled
 *
 * @param 	id				- �����
 * @return		- true - �������, false - �� �������
 */
native bool:ka_in_fgrenchill(const id)

/**
 * ������: next21_knife_ninja
 * ���������, ��������� �� ����� � ����������� ��� ���
 *
 * @param 	id				- �����
 * @return		- true - � �����������, false - ���
 */
native bool:ka_in_ninja(const id)

/**
 * ������: next21_knife_ninja
 * ������� �����������, ���� ����� � ��� ���������
 *
 * @param 	id				- �����
 * @return		- true - � �����������, false - ���
 */
native ka_unset_ninja(const id)

/**
 * ������: next21_item_candy
 * ���������, ������ �� ����� ������ ����������� ���������
 *
 * @param 	id				- �����
 * @return		- true - ������, false - ���
 */
native bool:ka_is_in_candy(const id)

/**
 * ������: next21_item_stimpak
 * ��� ������ ����������� ��
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_use_regeneration(const id)

/**
 * ������: MindGames
 * �������� ����� �� ��������� ������
 *
 * @return		- ����� �� ��������� ������
 */
native ka_next_result_mg()

/**
 * ������: next21_item_frost_gaz
 * ���������, ������ �� ����� ������ ��������� �����
 *
 * @param 	id				- �����
 * @return		- true - ������, false - ���
 */
native bool:ka_frostgren_inhand(const id)

/**
 * ������: next21_item_frost_gaz
 * ���������, ������ �� ����� ������ ������� �����
 *
 * @param 	id				- �����
 * @return		- true - ������, false - ���
 */
native bool:ka_gazgren_inhand(const id)

/**
 * ������: next21_item_frost_gaz
 * �������� ���-�� ��������� ���� � ������
 *
 * @param 	id				- �����
 * @return		- true - ������, false - ���
 */
native ka_frostgren_ammo(const id)

/**
 * ������: next21_item_frost_gaz
 * �������� ���-�� ������� ���� � ������
 *
 * @param 	id				- �����
 * @return		- true - ������, false - ���
 */
native ka_gazgren_ammo(const id)

/**
 * ������: next21_item_frost_gaz
 * ������ ������ ��������� �����
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_frostgren_give(const id)

/**
 * ������: next21_item_frost_gaz
 * ������ ������ ������� �����
 *
 * @param 	id				- �����
 * @return		- 1
 */
native ka_gazgren_give(const id)

//native ka_play_anim(const id, const anim)
//native ka_stop_anim(const id)
native ka_stop_levitation(const id)

//-------------------------------------- hats ------------------------------------------------
/**
 * �������� ������ �����, ������� ������ �� ������ (���� ��� �����, �� � model ������������ "!NULL")
 *
 * @param 	id				- �����
 * @return	model	- ���������� ���� ��������� ��� ������
 * @return	len	- charsmax
 */
native ka_get_hat_model(const id, const model[], const len)

/**
 * ������������� ������ ����� ("!NULL" - ������ ����� � ������)
 *
 * @param 	id				- �����
 * @param	model				- ������ �����
 * @return		- 1 ��, 0 - ��� ����� �����
 */
native ka_set_hat_model(const id, const model[])

/**
 * ������ ����� ��������� (���� ��� ������)
 *
 * @param 	id				- �����
 * @param	mode				- 1 - ������, 0 - ��������
 * @return		- 1 ��, 0 - ��� ����� �����
 */
native ka_hide_hat(const id, const mode)

//-------------------------------------- advanced_render -------------------------------------
/**
 * ������������ ��������� ������
 *
 * @return		-	-1 ���� �� ��
 * 					> -1 ������ ��������� �������� ������, ������������ �������� id ��� �������� ����� ����� �������� ka_render_sub
 */
native ka_render_add(const index, const fx = kRenderFxNone, const r = 255, const g = 255, const b = 255, const render = kRenderNormal, const amount = 16)

/**
 * ������� ���� �� ����������
 *
 * @param 	id				- �����
 * @param 	handle			- Id ������������ ����� �� ������� ka_render_add
 * @return		-	-1 � ������ ����������� ��������� ����� ��� �������� shift ��������
 * 					 0 ��� ��� ��������� ����, ��������� ������� �� �����������
 * 					 1 ���� �����, ������ ��������
 */
native ka_render_sub(const id, const handle_add)

//-------------------------------------- /advanced_render -------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/

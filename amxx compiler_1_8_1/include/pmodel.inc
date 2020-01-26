#if defined P_MODEL_INCLUDED
#endinput
#endif
#define P_MODEL_INCLUDED

#include <fakemeta>
#include <cstrike>

stock __PlayerModels[33][64];
stock __SetClientKeyValue = INVALID_HANDLE;

/*
 * Precaches player model.
 * Also attempts to precache the "T" file if it exists.
 *
 * model[]    model name (e.g. "vip").
 * late       set to true if precaching model not in plugin_precache().
 *
 * @return    model index.
 */
stock PrecachePlayerModel(const model[], bool:late = false)
{
	new path[128], ret;
	formatex(path, charsmax(path), "models/player/%s/%s.mdl", model, model);
	late ? (ret = engfunc(EngFunc_PrecacheModel, path)) : (ret = precache_model(path));
	
	formatex(path, charsmax(path), "models/player/%s/%sT.mdl", model, model);
	
	if (file_exists(path))
		late ? engfunc(EngFunc_PrecacheModel, path) : precache_model(path);
	
	return ret;
}

/*
 * Initializes usage of player models.
 *
 * use      true - use player models, false - stop using player models.
 *
 * @NOTE    Must call before using SetPlayerModel(). Recommended in plugin_init().
 */
stock UsePlayerModels(bool:use = true)
{
	if (use)
	{
		if (__SetClientKeyValue == INVALID_HANDLE)
			__SetClientKeyValue = register_forward(FM_SetClientKeyValue, "__OnSetClientKeyValue");
	}
	else
	{
		if (__SetClientKeyValue != INVALID_HANDLE)
		{
			unregister_forward(FM_SetClientKeyValue, __SetClientKeyValue);
			__SetClientKeyValue = INVALID_HANDLE;
		}
	}
}

/*
 * Sets player model.
 *
 * client     player index.
 * model[]    model name (e.g. "vip"). Leave empty to reset model.
 */
stock SetPlayerModel(client, const model[] = "")
{
	model[0] != EOS ? copy(__PlayerModels[client], charsmax(__PlayerModels[]), model) : (__PlayerModels[client][0] = EOS);
	set_user_info(client, "model", model);
}

public __OnSetClientKeyValue(client, const buffer[], const key[], const value[])
{	
	if (__PlayerModels[client][0] == EOS || !(CS_TEAM_T <= cs_get_user_team(client) <= CS_TEAM_CT) || !equal(key, "model"))
		return FMRES_IGNORED;
	
	set_user_info(client, "model", __PlayerModels[client]);
	
	return FMRES_SUPERCEDE;
}
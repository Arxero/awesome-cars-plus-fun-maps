#if defined _crxknives_included
    #endinput
#endif

#define _crxknives_included

#if !defined _crxknives_const_included
    #include <crxknives_const>
#endif

/**
 * Called when the client's knife model is changed.
 *
 * @param id            Client index
 * @param knife         Knife index
 * @param onconnect     True if this was called when the client first joined, false otherwise
 * @noreturn
 */
forward crxknives_knife_updated(id, knife, bool:onconnect)

/**
 * Called when the client attempts to change his knife model.
 *
 * @param id            Client index
 * @param knife         Knife index
 * @return              PLUGIN_HANDLED to prevent the client from changing his knife,
 *                      PLUGIN_CONTINUE to allow the change
 */
forward crxknives_attempt_change(id, knife)

/**
 * Checks whether or not the client can use a knife skill according to the cvar "km_knife_only_skills"
 *
 * @param id            Client index
 * @return              True if he can, false otherwise
 */
native bool:crxknives_can_use_skill(id)

/**
 * Returns the integer value from a knife attribute.
 *
 * @param id            Client index
 * @param attribute     Knife attribute
 * @param dest          Integer variable to store the value in
 * @param playerid      If set to false, the "id" parameter will be treated as a knife index instead
 * @return              True if the client or knife has that attribute set, false otherwise
 */
native bool:crxknives_get_attribute_int(id, const attribute[], &dest, bool:playerid = true)

/**
 * Returns the float value from a knife attribute.
 *
 * @param id            Client index
 * @param attribute     Knife attribute
 * @param dest          Float variable to store the value in
 * @param playerid      If set to false, the "id" parameter will be treated as a knife index instead
 * @return              True if the client or knife has that attribute set, false otherwise
 */
native bool:crxknives_get_attribute_float(id, const attribute[], &Float:dest, bool:playerid = true)

/**
 * Returns the string value from a knife attribute.
 *
 * @note You can also return the knife name by using the "NAME" attribute.
 *
 * @param id            Client index
 * @param attribute     Knife attribute
 * @param dest          Buffer to store the value in
 * @param len           Max buffer length
 * @param playerid      If set to false, the "id" parameter will be treated as a knife index instead
 * @return              True if the client or knife has that attribute set, false otherwise
 */
native bool:crxknives_get_attribute_str(id, const attribute[], dest[], len, bool:playerid = true)

/**
 * Returns the total number of registered knives.
 *
 * @return              Total number of registered knives
 */
native crxknives_get_knives_num()

/**
 * Gets the client's current knife.
 *
 * @param id            Client index
 * @return              Client's knife index
 */
native crxknives_get_user_knife(id)

/**
 * Checks whether or not the client has access to the specified knife.
 *
 * @param id            Client index
 * @param knife         Knife index
 * @return              True if he has, false otherwise
 */
native bool:crxknives_has_knife_access(id, knife)

/**
 * Checks whether or not the knife index is valid.
 *
 * @param knife         Knife index
 * @return              True if it is, false otherwise
 */
native bool:crxknives_is_knife_valid(knife)
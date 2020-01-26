#if defined _ichat_included
  #endinput
#endif
#define _ichat_included

#define iChatIsUserVip( %1 ) iChatVipAction( %1, 0 )
#define iChatSetUserVip( %1 ) iChatVipAction( %1, 1 )
#define iChatRemoveUserVip( %1 ) iChatVipAction( %1, 2 )

/**
 * Send data to iChat main plugin
 * You can change the maximum number of datas. Deafult is 2 (0, 1). If more or less, it will be 0.
 * An exemble would be: iChatSendCustomData( id, 0, "Custom" );
 * You can't format, you have to use formatex before.
 *
 * @param iIndex		Index of the player wich the data will be send.
 * @param iTagNum		Custom tag index.
 * @param szData[ ]		The data to be send.
 */
native iChatSendCustomData( iIndex, iTagNum, szData[ ] );

/**
 * Check, set, or remove a VIP.
 * You have to reset all by yourself (at putinserver etc...).
 * It's not saved at map change.
 *
 * @param iIndex		Index of the player.
 * @param iAction		Action on the native:
 *							- 0: return if iIndex is VIP.
 *							- 1: set iIndex VIP.
 *							- 2: remove iIndex from VIPs.
 * @return iIndex's VIP status once the action done.
 */
native iChatVipAction( iIndex, iAction );

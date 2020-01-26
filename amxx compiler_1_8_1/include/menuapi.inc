#if defined __MENU_API_VERSION__
    #endinput
#endif

#define __MENU_API_VERSION__ 1.0.1

static const __msgShowMenu = 96;
static const __successSetName = 123321;

#define ITEM_EXIT 10
#define ITEM_NEXT 9
#define ITEM_BACK 8

#define __MENU_ITEMS_PER_PAGE 7
#define __MENU_ITEMS_PER_PAGEWC 9 //without controls

#define get_arg_string(%0,%1,%2) \
    for (new i = 0; i <= %2; i++) \
        if ((%1[i] = getarg(%0, i)) == EOS) break

#define arg_is_valid(%0) (%0[0] != __msgShowMenu && %0[1] != __successSetName)

enum MenuProps (+=1) {
    MENU_PROP_NUMFMT,
    MENU_PROP_NUMFMT_DISABLE,
    MENU_PROP_NOACCESS_FMT,
    MENU_PROP_EXIT,
    MENU_PROP_DISPLAY_PAGES,
    MENU_PROP_BACKNAME,
    MENU_PROP_NEXTNAME,
    MENU_PROP_EXITNAME,
    MENU_PROP_COPYRIGHT
};

enum any: __menuStruct {
    menuID,
    menuHandler,
    menuItems,
    menuExit,
    menuDisplayPages,

    menuTitle[196],
    menuNumFmt[12],
    menuNumFmtDisable[12],
    menuNoAccessFmt[64],
    menuBackName[64],
    menuNextName[64],
    menuExitName[64],
    menuCopyright[64]
};

enum any: __menuItemStruct {
    itemID,
    itemArrayID,
    itemAlias,
    itemAccess,
    itemCallback,
    itemName[128],
    itemTempName[128]
};

enum any: __playerDataStruct {
    playerCurrentMenu,
    playerMenuCurrentPage,
    playerCurrentRealKey[__MENU_ITEMS_PER_PAGEWC]
};

static Array: __menusList;
static __fmtTemp[128];
static __playerData[33][__playerDataStruct];
static __maxPlayers;

stock MenuCreate(handler[], title[], any:...) {
    if (!__menusList) {
        __menusList = ArrayCreate(__menuStruct);
        register_clcmd("menuselect", "__MenuSelectItem");
        register_message(__msgShowMenu, "__MessageShowMenuHandle");

        __maxPlayers = get_maxplayers();
    }

    if (get_func_id(handler, -1/*this*/) == INVALID_HANDLE) {
        return INVALID_HANDLE;
    }

    new sMenuTemp[__menuStruct];

    sMenuTemp[menuID] = ArraySize(__menusList);
    if ((sMenuTemp[menuHandler] = CreateOneForward(get_plugin(-1/*this*/), handler, FP_CELL, FP_CELL, FP_CELL)) == INVALID_HANDLE) {
        return INVALID_HANDLE;
    }
    
    new szTitle[196]; vformat(szTitle, charsmax(szTitle), title, 3);

    if (szTitle[0] == EOS) {
        return INVALID_HANDLE;
    }

    copy(sMenuTemp[menuTitle], charsmax(szTitle), szTitle);
    copy(sMenuTemp[menuNumFmt], charsmax(sMenuTemp[menuNumFmt]), "\r%i.");
    copy(sMenuTemp[menuNumFmtDisable], charsmax(sMenuTemp[menuNumFmtDisable]), "\d%i.");
    copy(sMenuTemp[menuNoAccessFmt], charsmax(sMenuTemp[menuNoAccessFmt]), "\d%s \r*");

    sMenuTemp[menuItems] = _:ArrayCreate(__menuItemStruct);

    sMenuTemp[menuExit] = true;
    sMenuTemp[menuDisplayPages] = true;
    copy(sMenuTemp[menuExitName], charsmax(sMenuTemp[menuExitName]), "Exit");
    copy(sMenuTemp[menuBackName], charsmax(sMenuTemp[menuBackName]), "Back");
    copy(sMenuTemp[menuNextName], charsmax(sMenuTemp[menuNextName]), "Next");

    ArrayPushArray(__menusList, sMenuTemp);
    return sMenuTemp[menuID];
}

stock MenuAddItem(const menuid, const alias, const name[], const access = INVALID_HANDLE, const callback[32] = "") {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(menuid, sMenuTemp)) {
        return INVALID_HANDLE;
    }

    new sItemTemp[__menuItemStruct];
    sItemTemp[itemID] = ArraySize(Array: sMenuTemp[menuItems]);
    sItemTemp[itemArrayID] = sMenuTemp[menuItems];
    sItemTemp[itemAlias] = alias;
    sItemTemp[itemAccess] = access;
    sItemTemp[itemCallback] = INVALID_HANDLE;
    if (get_func_id(callback, -1/*this*/) != INVALID_HANDLE && 
        (sItemTemp[itemCallback] = CreateOneForward(get_plugin(-1/*this*/), callback, FP_CELL, FP_CELL, FP_CELL)) == INVALID_HANDLE) {
        return INVALID_HANDLE;
    }
    copy(sItemTemp[itemName], charsmax(sItemTemp[itemName]), name);

    ArrayPushArray(Array: sMenuTemp[menuItems], sItemTemp);
    return sItemTemp[itemID];
}

stock MenuAddItemF(const menuid, const alias, const nameid, const access = INVALID_HANDLE, const callback[32] = "") {
    if (nameid != __successSetName) {
        return INVALID_HANDLE;
    }

    new iValue = MenuAddItem(menuid, alias, __fmtTemp, access, callback);
    __fmtTemp[0] = EOS;

    return iValue;
}

stock ItemFormat(const buffer[], any:...) {
    vformat(__fmtTemp, charsmax(__fmtTemp), buffer, 2);

    if (__fmtTemp[0] == EOS) {
        return INVALID_HANDLE;
    }

    return __successSetName;
}

stock bool: MenuDisplay(const player, const menu) {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(menu, sMenuTemp)) {
        return false;
    }

    if (!is_user_connected(player)) {
        return false;
    }

    new iPage = __playerData[player][playerMenuCurrentPage];
    if (iPage < 0) {
        return false;
    }

    new szBuffer[512], iLen, bitsKeys = MENU_KEY_0, iRetValue, iStart, iEnd, 
    iTotalPages, iTemp, iItems = ArraySize(Array: sMenuTemp[menuItems]), 
    iItemsPerPage = iItems > __MENU_ITEMS_PER_PAGEWC ? __MENU_ITEMS_PER_PAGE : __MENU_ITEMS_PER_PAGEWC;

    if ((iStart = iPage * iItemsPerPage) >= iItems) {
        iStart = iPage = __playerData[player][playerMenuCurrentPage] = 0;
    }

    if ((iEnd = iStart + iItemsPerPage) > iItems) {
        iEnd = iItems;
    }

    iTotalPages = iItems / iItemsPerPage + (iItems % iItemsPerPage ? 1: 0);

    if (iTotalPages > 1 && sMenuTemp[menuDisplayPages]) {
        iLen = formatex(szBuffer, charsmax(szBuffer), "\w%s \w\R(%i/%i )\w^n^n", sMenuTemp[menuTitle], iPage+1, iTotalPages);
    }
    else {
        iLen = formatex(szBuffer, charsmax(szBuffer), "\w%s^n^n", sMenuTemp[menuTitle]);
    }

    new sItemTemp[__menuItemStruct], iFmtType, szTempFormat[128];

    while (iStart < iEnd) {
        __GetItemData(menu, iStart, sItemTemp);
        iStart++;

        iRetValue = ITEM_ENABLED;
        sItemTemp[itemTempName][0] = EOS;

        if (sItemTemp[itemCallback]  != INVALID_HANDLE) {
            ExecuteForward(sItemTemp[itemCallback], iRetValue, player, menu, iStart-1);
            __GetItemData(menu, iStart-1, sItemTemp);
        }

        if (sItemTemp[itemAccess] != INVALID_HANDLE && ~get_user_flags(player) & sItemTemp[itemAccess]) {
            iRetValue = ITEM_DISABLED;
            copy(szTempFormat, charsmax(szTempFormat), sItemTemp[itemName]);
            __RemoveColorSymbols(szTempFormat, charsmax(szTempFormat));
            formatex(sItemTemp[itemTempName], charsmax(sItemTemp[itemTempName]), sMenuTemp[menuNoAccessFmt], szTempFormat);
        }

        iFmtType = iRetValue == ITEM_DISABLED ? menuNumFmtDisable : menuNumFmt;
        iRetValue == ITEM_DISABLED ? (bitsKeys &= ~(1 << iTemp)) : (bitsKeys |= (1 << iTemp));
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, sMenuTemp[iFmtType], ++iTemp);
        iFmtType = sItemTemp[itemTempName][0] == EOS ? itemName : itemTempName;
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen,
            "\w %s^n%s", sItemTemp[iFmtType], iStart == iEnd ? "^n" : ""
        );
        __playerData[player][playerCurrentRealKey][iTemp] = iStart - 1;
    }

    if (iItems > iItemsPerPage) {
        iFmtType = iPage ? menuNumFmt : menuNumFmtDisable;
        iPage ? (bitsKeys |= MENU_KEY_8) : (bitsKeys &= ~MENU_KEY_8);
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, sMenuTemp[iFmtType], ITEM_BACK);
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, "%s %s^n", iPage ? "\w" : "\d", sMenuTemp[menuBackName]);
        iFmtType = iEnd < iItems ? menuNumFmt : menuNumFmtDisable;
        iEnd < iItems ? (bitsKeys |= MENU_KEY_9) : (bitsKeys &= ~MENU_KEY_9);
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, sMenuTemp[iFmtType], ITEM_NEXT);
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, "%s %s^n", iEnd < iItems ? "\w" : "\d", sMenuTemp[menuNextName]);
    }

    if (bool:(sMenuTemp[menuExit])) {
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, sMenuTemp[menuNumFmt], 0);
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, "\w %s", sMenuTemp[menuExitName]);
    }
    else {
        bitsKeys &= ~MENU_KEY_0;
    }

    if (sMenuTemp[menuCopyright][0] != EOS) {
        iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen, "%s^n%s", bool:(sMenuTemp[menuExit]) ? "^n" : "", sMenuTemp[menuCopyright]);
    }

    __playerData[player][playerCurrentMenu] = menu;
    show_menu(player, bitsKeys, szBuffer);
    return true;
}

stock MenuClose(const player) {
    show_menu(player, 0, "^n", 1);
}

stock GetPlayerMenu(const player) {
    return __playerData[player][playerCurrentMenu];
}

stock GetPlayerMenuPage(const player) {
    new iPage = __playerData[player][playerMenuCurrentPage]
    return iPage != INVALID_HANDLE ? ++iPage : INVALID_HANDLE;
}

stock bool: MenuDestroy(const menu) {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(menu, sMenuTemp)) {
        return false;
    }

    for (new i = 1; i <= __maxPlayers; i++) {
        __playerData[i][playerCurrentMenu] = INVALID_HANDLE;
        __playerData[i][playerMenuCurrentPage] = 0;
    }

    ArrayDeleteItem(__menusList, menu);
    ArrayDestroy(Array: sMenuTemp[menuItems]);
    return true;
}

stock bool: MenuItemGetInfo(const menuid, const item, name[], const len, bool: removecolor = false, &alias = 0, &access = 0, &callback = 0) {
    new sItemTemp[__menuItemStruct];
    if (!__GetItemData(menuid, item, sItemTemp)) {
        return false;
    }

    copy(name, len, sItemTemp[itemName]);
    if (removecolor) {
        __RemoveColorSymbols(name, len);
    }
    alias = sItemTemp[itemAlias];
    access = sItemTemp[itemAccess];
    callback = sItemTemp[itemCallback];
    return true;
}

stock bool: MenuSetProp(const menuid, const MenuProps: prop, any:...) {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(menuid, sMenuTemp)) {
        return false;
    }

    new szBuffer[64];

    if (numargs() < 2) {
        return false;
    }

    switch (prop) {
        case MENU_PROP_NUMFMT: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuNumFmt], charsmax(sMenuTemp[menuNumFmt]), szBuffer);

            if (numargs() > 3) {
                get_arg_string(3, szBuffer, charsmax(szBuffer));
                if (arg_is_valid(szBuffer)) {
                    copy(sMenuTemp[menuNumFmtDisable], charsmax(sMenuTemp[menuNumFmtDisable]), szBuffer);
                }
            }
        }

        case MENU_PROP_NUMFMT_DISABLE: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuNumFmtDisable], charsmax(sMenuTemp[menuNumFmtDisable]), szBuffer);
        }

        case MENU_PROP_NOACCESS_FMT: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuNoAccessFmt], charsmax(sMenuTemp[menuNoAccessFmt]), szBuffer);
        }

        case MENU_PROP_EXIT: {
            sMenuTemp[menuExit] = getarg(2);
        }

        case MENU_PROP_DISPLAY_PAGES: {
            sMenuTemp[menuDisplayPages] = bool: getarg(2);
        }

        case MENU_PROP_BACKNAME: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuBackName], charsmax(sMenuTemp[menuBackName]), szBuffer);

            if (numargs() > 2) {
                get_arg_string(3, szBuffer, charsmax(szBuffer));
                if (arg_is_valid(szBuffer)) {
                    copy(sMenuTemp[menuNextName], charsmax(sMenuTemp[menuNextName]), szBuffer);

                    if (numargs() > 3) {
                        get_arg_string(4, szBuffer, charsmax(szBuffer));
                        copy(sMenuTemp[menuExitName], charsmax(sMenuTemp[menuExitName]), szBuffer);
                    }
                }
            }
        }

        case MENU_PROP_NEXTNAME: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuNextName], charsmax(sMenuTemp[menuNextName]), szBuffer);
        }

        case MENU_PROP_EXITNAME: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuExitName], charsmax(sMenuTemp[menuExitName]), szBuffer);
        }

        case MENU_PROP_COPYRIGHT: {
            get_arg_string(2, szBuffer, charsmax(szBuffer));
            copy(sMenuTemp[menuCopyright], charsmax(sMenuTemp[menuCopyright]), szBuffer);
        }

        default: return false;
    }

    ArraySetArray(__menusList, menuid, sMenuTemp);

    return true;
}

stock MenuSetItemName(const menu, const item, buffer[], any:...) {
    new sItemTemp[__menuItemStruct];
    if (!__GetItemData(menu, item, sItemTemp)) {
        return;
    }

    new szName[128];
    vformat(szName, charsmax(szName), buffer, 4);
    copy(sItemTemp[itemName], charsmax(sItemTemp[itemName]), szName);
    ArraySetArray(Array: sItemTemp[itemArrayID], item, sItemTemp);
}

static stock __GetMenuData(const menu, buffer[__menuStruct]) {
    if (menu < 0 || menu >= ArraySize(__menusList)) {
        return false;
    }

    ArrayGetArray(__menusList, menu, buffer);
    return true;
}

static stock __GetItemData(const menu, const item, buffer[__menuItemStruct]) {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(menu, sMenuTemp)) {
        return false;
    }

    if (item < 0 || item >= ArraySize(Array: sMenuTemp[menuItems])) {
        return false;
    }

    ArrayGetArray(Array: sMenuTemp[menuItems], item, buffer);

    new sItemTemp[__menuItemStruct];
    ArrayGetArray(Array: sMenuTemp[menuItems], item, sItemTemp);

    return true;
}

public __MenuSelectItem(const player) {
    new sMenuTemp[__menuStruct];
    if (!__GetMenuData(__playerData[player][playerCurrentMenu], sMenuTemp)) {
        return;
    }

    new iDummy, iMenu = sMenuTemp[menuID];
    new szArg[11]; read_argv(1, szArg, charsmax(szArg));
    new iKey = str_to_num(szArg), bool: bPagination = bool:(ArraySize(Array: sMenuTemp[menuItems]) -1 > __MENU_ITEMS_PER_PAGEWC);

    switch (iKey) {
        case ITEM_EXIT: {
            __playerData[player][playerCurrentMenu] = INVALID_HANDLE;
            __playerData[player][playerMenuCurrentPage] = 0;
        }

        case ITEM_BACK: {
            if (bPagination) {
                --__playerData[player][playerMenuCurrentPage];
                MenuDisplay(player, iMenu);
            }
            else {
                __playerData[player][playerCurrentMenu] = INVALID_HANDLE;
                __playerData[player][playerMenuCurrentPage] = 0;
                ExecuteForward(sMenuTemp[menuHandler], iDummy, player, iMenu, __playerData[player][playerCurrentRealKey][iKey]);
            }
        }

        case ITEM_NEXT: {
            if (bPagination) {
                ++__playerData[player][playerMenuCurrentPage];
                MenuDisplay(player, iMenu);
            }
            else {
                __playerData[player][playerCurrentMenu] = INVALID_HANDLE;
                __playerData[player][playerMenuCurrentPage] = 0;
                ExecuteForward(sMenuTemp[menuHandler], iDummy, player, iMenu, __playerData[player][playerCurrentRealKey][iKey]);
            }
        }

        default: {
            __playerData[player][playerCurrentMenu] = INVALID_HANDLE;
            __playerData[player][playerMenuCurrentPage] = 0;
            ExecuteForward(sMenuTemp[menuHandler], iDummy, player, iMenu, __playerData[player][playerCurrentRealKey][iKey]);
        }
    }
}

public __MessageShowMenuHandle(const msgid, const msgdest, const player) {
    __playerData[player][playerCurrentMenu] = INVALID_HANDLE;
    __playerData[player][playerMenuCurrentPage] = 0;
}

static stock __RemoveColorSymbols(buffer[], const len) {
    replace_all(buffer, len, "\w", "");
    replace_all(buffer, len, "\y", "");
    replace_all(buffer, len, "\r", "");
    replace_all(buffer, len, "\d", "");
}
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define pev_light	pev_iuser1

#if AMXX_VERSION_NUM < 183
#define client_disconnected client_disconnect
#endif

enum _:STRSPRPARAM {
	Float:RP_STR_CORDX,			//Координаты начала
	Float:RP_STR_CORDY,
	Float:RP_STR_CORDZ,
	Float:RP_END_CORDX,			//Координаты конца
	Float:RP_END_CORDY,
	Float:RP_END_CORDZ,
	RP_SEGMENT,				//Количество точек.
	bool:RP_CURVE,			//Кривизна.
	bool:RP_BLINK,			//Мерцание.
	bool:RP_COLOR_RAND,		//Цвет случайный/сохранённый (1/0)
	RP_COL_R,				//Если не случайный то тут сохранён цвет.
	RP_COL_G,
	RP_COL_B,
	bool:RP_START,
	RP_COLOR
};
new Array:g_ArrSprPar;
new g_PlArrParam[33][STRSPRPARAM];
new g_iCount;

new g_szSprite[][] = {
	"sprites/we/redspr.spr"
}

new g_szPathFile[256];
new g_szClassName[] = "class_light";

enum _:COLORTYPE {
	COL_R,
	COL_G,
	COL_B,
	COL_NAME[32]
}
new g_szColor[][COLORTYPE] = { // <= Цвета добавлять здесь. Но случайный не трогать и только после него!
	{0,0,0,			"Случаен"},
	{255,0,0,		"Червен"},
	{0,255,0,		"Зелен"},
	{0,0,255,		"Син"},
	{55,163,221,	"Светло синьо"},
	{235,206,41,	"Жълто"},
	{176,43,234,	"Пурпорен"}
}


public plugin_precache() {
	for(new i=0;i<sizeof(g_szSprite);i++)
		precache_model(g_szSprite[i]);
	
	g_ArrSprPar = ArrayCreate(STRSPRPARAM);
	ReadSaveParam();
}
public ReadSaveParam() {
	new szLoadDir[128],szMapName[64];
	get_mapname(szMapName,charsmax(szMapName));
	get_configsdir(szLoadDir, charsmax(szLoadDir));
	formatex(szLoadDir, charsmax(szLoadDir), "%s/WE_ChristmasLights",szLoadDir)
	if(!dir_exists(szLoadDir)) mkdir(szLoadDir);
	formatex(g_szPathFile, charsmax(g_szPathFile), "%s/%s.ini",szLoadDir,szMapName)

	if(file_exists(g_szPathFile)) {
		enum STRCORD {STR_X,STR_Y,STR_Z,END_X,END_Y,END_Z};
		new szParse[256],szCord[STRCORD][8],szSegment[8],szCurve[5],szBlink[5],szColRand[5],szColR[8],szColG[8],szColB[8];
		new ArrSprPar[STRSPRPARAM];
		
		new iLine, iNum;
		for(iLine = 0; read_file(g_szPathFile, iLine, szParse, charsmax(szParse), iNum); iLine++) {
			parse(szParse,
					szCord[STR_X],charsmax(szCord[]),
					szCord[STR_Y],charsmax(szCord[]),
					szCord[STR_Z],charsmax(szCord[]),
					
					szCord[END_X],charsmax(szCord[]),
					szCord[END_Y],charsmax(szCord[]),
					szCord[END_Z],charsmax(szCord[]),

					szSegment, charsmax(szSegment),
					szCurve, charsmax(szCurve),
					szBlink, charsmax(szBlink),
					szColRand, charsmax(szColRand),
					
					szColR, charsmax(szColR),
					szColG, charsmax(szColG),
					szColB, charsmax(szColB)
			);
		
			ArrSprPar[RP_STR_CORDX] = _:str_to_float(szCord[STR_X]);
			ArrSprPar[RP_STR_CORDY] = _:str_to_float(szCord[STR_Y]);
			ArrSprPar[RP_STR_CORDZ] = _:str_to_float(szCord[STR_Z]);
			
			ArrSprPar[RP_END_CORDX] = _:str_to_float(szCord[END_X]);
			ArrSprPar[RP_END_CORDY] = _:str_to_float(szCord[END_Y]);
			ArrSprPar[RP_END_CORDZ] = _:str_to_float(szCord[END_Z]);
			
			ArrSprPar[RP_SEGMENT] = _:str_to_num(szSegment);
			ArrSprPar[RP_CURVE] = _:str_to_num(szCurve);
			ArrSprPar[RP_BLINK] = _:str_to_num(szBlink);
			ArrSprPar[RP_COLOR_RAND] = _:str_to_num(szColRand);
			
			ArrSprPar[RP_COL_R] = _:str_to_num(szColR);
			ArrSprPar[RP_COL_G] = _:str_to_num(szColG);
			ArrSprPar[RP_COL_B] = _:str_to_num(szColB);
			
			new Float:fStart[3],Float:fEnd[3];
			
			fStart[0] = ArrSprPar[RP_STR_CORDX];
			fStart[1] = ArrSprPar[RP_STR_CORDY];
			fStart[2] = ArrSprPar[RP_STR_CORDZ];
			
			fEnd[0] = ArrSprPar[RP_END_CORDX];
			fEnd[1] = ArrSprPar[RP_END_CORDY];
			fEnd[2] = ArrSprPar[RP_END_CORDZ];
			
			calc_sprite(g_iCount,ArrSprPar[RP_CURVE],ArrSprPar[RP_BLINK],fStart,fEnd,ArrSprPar[RP_SEGMENT],-1,ArrSprPar[RP_COL_R],ArrSprPar[RP_COL_G],ArrSprPar[RP_COL_B],ArrSprPar[RP_COLOR_RAND]);
			ArrayPushArray(g_ArrSprPar, ArrSprPar);
			g_iCount++;
		}
	}
}
public WriteSaveParam() {
	if(file_exists(g_szPathFile)) delete_file(g_szPathFile);

	for(new i=0;i<ArraySize(g_ArrSprPar);i++) {
		new ArrSprPar[STRSPRPARAM];
		ArrayGetArray(g_ArrSprPar, i, ArrSprPar);
		
		new szSaveStr[1024];
		format(szSaveStr,charsmax(szSaveStr),
			"^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%.1f^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^"",
			ArrSprPar[RP_STR_CORDX],
			ArrSprPar[RP_STR_CORDY],
			ArrSprPar[RP_STR_CORDZ],
			
			ArrSprPar[RP_END_CORDX],
			ArrSprPar[RP_END_CORDY],
			ArrSprPar[RP_END_CORDZ],
			
			ArrSprPar[RP_SEGMENT],
			ArrSprPar[RP_CURVE],
			ArrSprPar[RP_BLINK],
			ArrSprPar[RP_COLOR_RAND],
			ArrSprPar[RP_COL_R],
			ArrSprPar[RP_COL_G],
			ArrSprPar[RP_COL_B]	
		);
		write_file(g_szPathFile, szSaveStr, i);
	}
}

public plugin_init() {
	register_plugin("Winter Environment [Lights]", "1.0", "Unknown [Edited by Huehue]" );
	register_menu("lightmenu", 1023, "lightmenu_function");
	register_think(g_szClassName, "LightThink" );
	
	register_clcmd("light","start_lightmenu");
}
public LightThink(iEnt) {
	if(!pev_valid(iEnt))
		return;
	
	set_rendering(iEnt,kRenderFxNone,random_num(0,200),random_num(0,200),random_num(0,200),kRenderTransAdd,255)
	set_pev( iEnt, pev_nextthink, get_gametime()+1.0);
}

public start_lightmenu(id) {
	if(~get_user_flags(id) & read_flags("gh"))
		return PLUGIN_HANDLED;
	
	lightmenu(id,true);
	return PLUGIN_HANDLED;
}
stock lightmenu(id,bool:first = false) {
	static menu[512],len;
	len = 0;
	if(first) {
		g_PlArrParam[id][RP_START] = false;
		g_PlArrParam[id][RP_SEGMENT] = 10;
		g_PlArrParam[id][RP_COLOR] = 0;
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "\rМеню гирлянд. Общо лампички \d[\r%d\d]^n\yБрой лампички в гирлянда \d[\r%d\d]^n^n",g_iCount,g_PlArrParam[id][RP_SEGMENT]+1);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \w%s^n",g_PlArrParam[id][RP_START] ? "Край":"Начало");
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wЦвят: \d[\y%s\d]^n",g_szColor[g_PlArrParam[id][RP_COLOR]][COL_NAME]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wДобави лампички^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wМахни лампички^n^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wФорма \d[\y%s\d]^n",g_PlArrParam[id][RP_CURVE] ? "Провесени":"Гладки");
	if(g_PlArrParam[id][RP_COLOR] == 0)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wБлещукане \d[\y%s\d]^n^n",g_PlArrParam[id][RP_BLINK] ? "Блещука":"Не блещука");
	else len += formatex(menu[len], charsmax(menu) - len, "^n^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wИзтрий последния^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \wИзтрий всички^n");
	len += formatex(menu[len], charsmax(menu) - len, "\r[9] \wЗапиши^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0] \wИзход");
	
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;
	show_menu(id, keys, menu, -1, "lightmenu");
	return PLUGIN_HANDLED;
}
public lightmenu_function(id,key) {
	switch(key) {
		case 0: {
			new Origin[3],Float:fOrigin[3];
			get_user_origin(id, Origin, 3);
			for(new i=0;i<sizeof(fOrigin);i++) 
				fOrigin[i] = float(Origin[i]);
			
			if(!g_PlArrParam[id][RP_START]) {
				g_PlArrParam[id][RP_START] = true;
				g_PlArrParam[id][RP_STR_CORDX] = _:fOrigin[0];
				g_PlArrParam[id][RP_STR_CORDY] = _:fOrigin[1];
				g_PlArrParam[id][RP_STR_CORDZ] = _:fOrigin[2];
			} else {
				g_PlArrParam[id][RP_START] = false;
				g_PlArrParam[id][RP_END_CORDX] = _:fOrigin[0];
				g_PlArrParam[id][RP_END_CORDY] = _:fOrigin[1];
				g_PlArrParam[id][RP_END_CORDZ] = _:fOrigin[2];
				new Float:fStart[3];
				fStart[0] = g_PlArrParam[id][RP_STR_CORDX];
				fStart[1] = g_PlArrParam[id][RP_STR_CORDY];
				fStart[2] = g_PlArrParam[id][RP_STR_CORDZ];

				calc_sprite(g_iCount,g_PlArrParam[id][RP_CURVE],g_PlArrParam[id][RP_BLINK],fStart,fOrigin,g_PlArrParam[id][RP_SEGMENT],g_PlArrParam[id][RP_COLOR]);
				
				if(g_PlArrParam[id][RP_COLOR] == 0) g_PlArrParam[id][RP_COLOR_RAND] = true;
				else {
					g_PlArrParam[id][RP_COLOR_RAND] = false;
					
					g_PlArrParam[id][RP_COL_R] = g_szColor[g_PlArrParam[id][RP_COLOR]][COL_R];
					g_PlArrParam[id][RP_COL_G] = g_szColor[g_PlArrParam[id][RP_COLOR]][COL_G];
					g_PlArrParam[id][RP_COL_B] = g_szColor[g_PlArrParam[id][RP_COLOR]][COL_B];
				}
				ArrayPushArray(g_ArrSprPar, g_PlArrParam[id]);
				g_iCount++;
			}
		}
		case 1: {
			if(g_PlArrParam[id][RP_COLOR]<sizeof(g_szColor)-1) {
				g_PlArrParam[id][RP_COLOR]++;
			} else g_PlArrParam[id][RP_COLOR] = 0;
		}
		case 2: {
			g_PlArrParam[id][RP_SEGMENT]++;
		}
		case 3: {
			if(g_PlArrParam[id][RP_SEGMENT] > 2)
				g_PlArrParam[id][RP_SEGMENT]--;
		}
		case 4: g_PlArrParam[id][RP_CURVE] = !g_PlArrParam[id][RP_CURVE];
		case 5: g_PlArrParam[id][RP_BLINK] = !g_PlArrParam[id][RP_BLINK];
		case 6: {
			new iSize = ArraySize(g_ArrSprPar);
			if(g_iCount == iSize && iSize != 0) {
				g_iCount--;
				new iEnt = FM_NULLENT;
				while((iEnt = find_ent_by_class( iEnt, g_szClassName))) {
					if(pev(iEnt,pev_light) == g_iCount) {
						set_pev(iEnt, pev_flags, FL_KILLME);
					}
				}
				ArrayDeleteItem(g_ArrSprPar,g_iCount);
			}
		}
		case 7: {
			ArrayClear(g_ArrSprPar);
			new iEnt = FM_NULLENT;
			while((iEnt = find_ent_by_class( iEnt, g_szClassName))) {
				set_pev(iEnt, pev_flags, FL_KILLME);
			}
			g_iCount = 0;
		}
		case 8: {
			WriteSaveParam();
			return PLUGIN_HANDLED;
		}
		case 9: return PLUGIN_HANDLED;
	}
	lightmenu(id);
	return PLUGIN_HANDLED;
}

public client_putinserver(id) {
	g_PlArrParam[id][RP_START] = false;
}
public client_disconnected(id) {
	g_PlArrParam[id][RP_START] = false;
}

stock calc_sprite(iNum,iCurve,iBlink,Float:fStart[3],Float:fEnd[3],iSegment,iColor,R=0,G=0,B=0,iRand=false) {
	new Float:newPoint[3],Float:vector[3],Float:fFistortion,Float:fCurve;

	new Float:fAllDist = get_distance_f(fEnd,fStart);
	new Float:fDist = fAllDist / iSegment;

	for(new i=0;i<sizeof(fStart);i++)
		vector[i] = (fEnd[i] - fStart[i])/fAllDist;
	
	fCurve = fAllDist/100*18/iSegment/2;
	
	for(new j=1;j<iSegment;j++) {
		for(new i=0;i<sizeof(fStart);i++) {
			newPoint[i] = vector[i] * fDist*j + fStart[i];
			
			if(iCurve) {
				if(fDist*j > fAllDist/2) {
					fFistortion += fCurve;
					newPoint[2] += fFistortion;
				} else if(fDist*j > fAllDist/2 - fDist/4) {
					fFistortion += -fCurve/2;
					newPoint[2] += fFistortion;
				} else {
					fFistortion += -fCurve;
					newPoint[2] += fFistortion;
				}
			}
		}
		create_sprite(iNum,iBlink,newPoint,iColor,R,G,B,iRand);
	}
	create_sprite(iNum,iBlink,fEnd,iColor,R,G,B,iRand);
	create_sprite(iNum,iBlink,fStart,iColor,R,G,B,iRand);		
}
stock create_sprite(iNum,iBlink,Float:vecOrigin[3],iColor,R=0,G=0,B=0,iRand = false) {
	static iszInfoTarget = 0; new iSprId = FM_NULLENT;
	if(iszInfoTarget || (iszInfoTarget = engfunc(EngFunc_AllocString, "env_sprite"))) iSprId = engfunc(EngFunc_CreateNamedEntity, iszInfoTarget);
	if(is_valid_ent(iSprId)) {
		set_pev(iSprId, pev_origin, vecOrigin);

		set_pev(iSprId, pev_solid, SOLID_NOT);
		set_pev(iSprId, pev_movetype, MOVETYPE_NONE);
		
		set_pev(iSprId, pev_framerate, 5.0);
		set_pev(iSprId, pev_scale, 0.15); 
		
		if(iColor > 0) {
			set_rendering(iSprId,kRenderFxNone,g_szColor[iColor][COL_R],g_szColor[iColor][COL_G],g_szColor[iColor][COL_B],kRenderTransAdd,255)
		} else if(iColor == 0 || iRand) {
			set_rendering(iSprId,kRenderFxNone,random_num(0,200),random_num(0,200),random_num(0,200),kRenderTransAdd,255)
		} else if(iColor == -1) {
			set_rendering(iSprId,kRenderFxNone,R,G,B,kRenderTransAdd,255)
		}
		engfunc(EngFunc_SetModel, iSprId, g_szSprite[random_num(0,charsmax(g_szSprite))]); 
		set_pev(iSprId, pev_classname, g_szClassName);
		
		set_pev(iSprId, pev_spawnflags, SF_SPRITE_STARTON);
		dllfunc(DLLFunc_Spawn, iSprId);
		
		set_pev(iSprId,pev_light,iNum);
		
		if(iBlink && iColor == 0 || iRand)
			set_pev( iSprId, pev_nextthink, get_gametime()+1.0);
	}
}


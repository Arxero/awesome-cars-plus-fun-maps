#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <xs>

#define FILE_DOMCFG "/advanced_func_vehicle/%s.cfg"

const m_iHeight = 37;
const m_iSpeed = 38;

new Float:defaultVtolVelocity;
new Float:defaultNOSVelocity;
new Float:defaultdriftForce;

new Float:defaultWeaponShellDelay;
new Float:defaultWeaponConcCannonDelay;
new Float:defaultWeaponGuidedMissileDelay;
new Float:defaultWeaponCarHornDelay;
new Float:defaultWeaponTruckHornDelay;
new Float:defaultWeaponShipHornDelay;

new explosion, explosion1, smoke, white, rocketsmoke;
new bool:endOfRound;
new bool:userAllowed[33];
new userVehicle[33];
new userControl[33];

new vehiclesSpawned;
new vehicleIds[64];
new Float:vehicleLastShootTime[64];
new bool:vehicleUsingNOS[64];

//config
enum _:vehicleWeapon {
	VWEAPON_NO = 0,
	VWEAPON_LMG1,
	VWEAPON_HMG1,
	VWEAPON_AUTO_CANNON,
	VWEAPON_MINIGUN,
	VWEAPON_SHELL_HEAT,
	VWEAPON_SHELL_AP,
	VWEAPON_SHELL_HE,
	VWEAPON_CONC_CANNON,
	VWEAPON_HORN,
	VWEAPON_TRUCK_HORN,
	VWEAPON_SHIP_HORN,
	VWEAPON_NOS,
	VWEAPON_GUIDED_MISSILE
};
new const vehicleWeaponNames[vehicleWeapon][] = {
	"NO",
	"LMG1",
	"HMG1",
	"AUTO_CANNON",
	"MINIGUN",
	"SHELL_HEAT",
	"SHELL_AP",
	"SHELL_HE",
	"CONC_CANNON",
	"HORN",
	"TRUCK_HORN",
	"SHIP_HORN",
	"NOS",
	"GUIDED_MISSILE"
};
new Trie:vehicleWeaponsConfig;

enum _:vehicleType {
	VTYPE_VEHICLE = 0,
	VTYPE_CAR,
	VTYPE_CAR_RWD,
	VTYPE_BIKE,
	VTYPE_APC,
	VTYPE_TANK,
	VTYPE_HELI,
	VTYPE_VTOL,
	VTYPE_PLANE,
	VTYPE_FIGHTERJET,
	VTYPE_BOAT,
	VTYPE_SHIP
};
new const vehicleTypeNames[vehicleType][] = {
	"VEHICLE",
	"CAR",
	"CAR_RWD",
	"BIKE",
	"APC",
	"TANK",
	"HELI",
	"VTOL",
	"PLANE",
	"FIGHTERJET",
	"BOAT",
	"SHIP"
};
new Trie:vehicleTypesConfig;

new vehicleNames[64][32];
new vehicleWeaponTypes[64];
new vehicleTypes[64];
new vehicleHPs[64];
new vehicleWPN1_0[64];
new vehicleWPN1_1[64];
new vehicleWPN1_2[64];

// map entity
new Float:vehicleDefaultHeights[64];
new Float:vehicleDefaultOrigins[64];
new Float:vehicleDefaultSpeeds[64];
new Float:vehicleDefaultRenderAmts[64];
new vehicleDefaultRenderModes[64];
new Float:vehicleDefaultRenderColors[64][3];

new vehicleCurrentHPs[64];

public plugin_init() {
	register_plugin("Advanced Func Vehicle", "1.0", "Retroyers");

	if (find_ent_by_class(-1, "func_vehicle") != 0) {
		
		new launchFixEnabled = register_cvar("afv_launch_fix_enabled", "1");
		if (get_pcvar_bool(launchFixEnabled)) {
			register_think("func_vehicle", "vehicleThink");
		}

		defaultWeaponShellDelay = get_pcvar_float(register_cvar("afv_default_weapon_shell_delay", "10.0"));
		defaultWeaponConcCannonDelay = get_pcvar_float(register_cvar("afv_default_weapon_conc_cannon_delay", "8.0"));
		defaultWeaponGuidedMissileDelay = get_pcvar_float(register_cvar("afv_default_weapon_guided_missile_delay", "20.0"));
		defaultWeaponCarHornDelay = get_pcvar_float(register_cvar("afv_default_weapon_car_horn_delay", "1.0"));
		defaultWeaponTruckHornDelay = get_pcvar_float(register_cvar("afv_default_weapon_truck_horn_delay", "1.0"));
		defaultWeaponShipHornDelay = get_pcvar_float(register_cvar("afv_default_weapon_ship_horn_delay", "1.0"));
		
		// defaults for sys_ticrate 100
		defaultVtolVelocity = get_pcvar_float(register_cvar("afv_default_vtol_velocity", "100.0"));
		defaultNOSVelocity = get_pcvar_float(register_cvar("afv_default_nos_velocity", "40.0"));
		defaultdriftForce = get_pcvar_float(register_cvar("afv_default_drift_force", "4.0"));

		vehicleWeaponsConfig = TrieCreate();
		vehicleTypesConfig = TrieCreate();

		for (new i = 0; i < vehicleWeapon; i++) {
			TrieSetCell(vehicleWeaponsConfig, vehicleWeaponNames[i], i);
		}
		for (new i = 0; i < vehicleType; i++) {
			TrieSetCell(vehicleTypesConfig, vehicleTypeNames[i], i);
		}

		RegisterHam(Ham_Use, "func_vehicle", "FuncVehicle_OnUse", 0);
		RegisterHam(Ham_OnControls, "func_vehicle", "FuncVehicle_OnControls", 1);

		register_logevent("round_start", 2, "1=Round_Start");
		register_logevent("round_end",2,"1=Round_End");
		register_forward(FM_CmdStart, "forward_cmdstart");
		register_forward(FM_PlayerPreThink, "forward_playerprethink");

		register_touch("*", "afv_shell_ap", "weaponTouchAp");
		register_touch("*", "afv_shell_heat", "weaponTouchHeat");
		register_touch("*", "afv_shell_he", "weaponTouchHe");
		register_touch("*", "afv_conc_cannon", "weaponTouchConcCannon");
		register_touch("*", "afv_guided_missile", "weaponTouchGuidedMissile");

		vehiclesSpawned = 0;

		new g_iTic = get_cvar_pointer("sys_ticrate");
		new iSysTicRate = get_pcvar_num(g_iTic);

		if (iSysTicRate > 0) {
			defaultVtolVelocity = defaultVtolVelocity * (iSysTicRate / 100.0);
			defaultNOSVelocity = defaultNOSVelocity * (iSysTicRate / 100.0);
			defaultdriftForce = defaultdriftForce / (iSysTicRate / 100.0);
		}

		load_config();
	}
	return PLUGIN_CONTINUE;
}

public plugin_natives() {
	register_library("advanced_func_vehicle");
	register_native("damageVehicle", "_damageVehicle");
	register_native("getUserDriving", "_getUserDriving");
}

public plugin_end() {
	TrieDestroy(vehicleWeaponsConfig);
	TrieDestroy(vehicleTypesConfig);
}

public pfn_spawn(ent) {
	if (!is_valid_ent(ent)) {
        return PLUGIN_CONTINUE;
	}

	static sz_classname[33];
	entity_get_string(ent, EV_SZ_classname, sz_classname, charsmax(sz_classname));

	if (equal(sz_classname, "func_vehicle")) {
		//server_print("spawned func vehicle %d %d", ent, vehiclesSpawned);
		vehicleIds[vehiclesSpawned] = ent;
		vehiclesSpawned++;
	}
	return PLUGIN_CONTINUE;
}

public vehicleThink(id) {
	static Float:launchTime;
	launchTime = get_ent_data_float(id, "CFuncVehicle", "m_flLaunchTime");
	if (launchTime != -1) {
		set_ent_data_float(id, "CFuncVehicle", "m_flLaunchTime", launchTime + ((get_gametime() - launchTime) / 40)); // divide less = add more = go further
	}
}

public round_start() {
	endOfRound = false;
	new index = 0;
	while (index < 63) {
		new burn_task_id = 8397 + index;
		if (task_exists(burn_task_id)) {
			remove_task(burn_task_id);
		}

		vehicleCurrentHPs[index] = vehicleHPs[index];

		if  (is_valid_ent(vehicleIds[index]) && strlen(vehicleNames[index]) > 0) {
			if (vehicleTypes[index] == VTYPE_CAR_RWD) {
				set_pev(vehicleIds[index], pev_basevelocity, {0.0, 0.0, 0.0}); //drift reset
			}

			new Float:vVehicleOrigin[3];
			entity_get_vector(vehicleIds[index], EV_VEC_origin, vVehicleOrigin);
			vVehicleOrigin[2] = vehicleDefaultOrigins[index];
			entity_set_origin(vehicleIds[index], vVehicleOrigin);

			set_pdata_float(vehicleIds[index], m_iHeight, vehicleDefaultHeights[index], 4);
			set_pdata_float(vehicleIds[index], m_iSpeed, vehicleDefaultSpeeds[index], 4);

			entity_set_vector(vehicleIds[index], EV_VEC_rendercolor, vehicleDefaultRenderColors[index]);
			entity_set_int(vehicleIds[index], EV_INT_rendermode, vehicleDefaultRenderModes[index]);
			entity_set_float(vehicleIds[index], EV_FL_renderamt, vehicleDefaultRenderAmts[index]);
		}
		index++;
	}
}

public round_end() {
	endOfRound = true;
}

public burn_vehicle(args[]) {
	if  (is_valid_ent(args[0])) { // vehicle_id
		new Float:vVehicleOrigin[3];
		entity_get_vector(args[0], EV_VEC_origin, vVehicleOrigin);

		entity_get_vector(args[0], EV_VEC_origin, vVehicleOrigin);	
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_SMOKE);
		engfunc(EngFunc_WriteCoord, vVehicleOrigin[0]);
		engfunc(EngFunc_WriteCoord, vVehicleOrigin[1]);
		engfunc(EngFunc_WriteCoord, vVehicleOrigin[2]);
		write_short(smoke);
		write_byte(125);
		write_byte(5);
		message_end();
	}
}

public FuncVehicle_OnUse(iVehicle, id) {
	static vIndex = -1;
	new index;
	while (index < 63) {
		if (iVehicle == vehicleIds[index]) {
			vIndex = index;
			break;
		}
		index++;
	}

	if (vehicleHPs[vIndex] <= 0) {
		return HAM_IGNORED; //not setup
	}

	if (vehicleCurrentHPs[vIndex] <= 0) {
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public FuncVehicle_OnControls(iVehicle, id) {
	if (endOfRound) {
		return HAM_IGNORED;
	}

	userVehicle[id] = iVehicle;
	if (cs_get_user_team(id) != CS_TEAM_SPECTATOR) {
		userAllowed[id] = true;
	} else {
		userAllowed[id] = false;
	}
	return HAM_IGNORED;
}

public plugin_precache() {  
	precache_sound ("advanced_func_vehicle/car_horn.wav");
	precache_sound ("advanced_func_vehicle/truck_horn.wav");
	precache_sound ("advanced_func_vehicle/ship_horn.wav");
	precache_model("models/rpgrocket.mdl");
	precache_sound("weapons/rocketfire1.wav");
	precache_sound("weapons/hks2.wav");
	precache_sound("ambience/biggun2.wav");
	precache_sound("ambience/biggun3.wav");
	precache_sound("debris/beamstart8.wav");
	precache_sound("weapons/mortarhit.wav");

	explosion = precache_model("sprites/fexplo.spr");
	explosion1 = precache_model("sprites/fexplo1.spr");
	smoke = precache_model("sprites/steam1.spr");
	white = precache_model("sprites/white.spr");
	rocketsmoke = precache_model("sprites/smoke.spr");

	return PLUGIN_CONTINUE;
}

public forward_cmdstart(id, uc_handle) {
	if (!endOfRound && userAllowed[id] && is_user_alive(id) && cs_get_user_driving(id) > 0) {
		static Button, OldButtons, fired_weapon;
		Button = get_uc(uc_handle, UC_Buttons);
		OldButtons = pev(id, pev_oldbuttons);
		fired_weapon = false;

		//get vehicle weapon type
		static targetname[32];
		static vIndex = -1;
		entity_get_string(userVehicle[id],EV_SZ_targetname,targetname,31);
		new index;
		while (index < 63) {
			if (strcmp(targetname,vehicleNames[index]) == 0) {
				vIndex = index;
				break;
			}
			index++;
		}

		if (vIndex < 0) {
			return FMRES_IGNORED;
		}
		if (vehicleCurrentHPs[vIndex] <= 0) {
			return FMRES_IGNORED;
		}

		static vWeapon;
		vWeapon = vehicleWeaponTypes[vIndex];
		static vType;
		vType = vehicleTypes[vIndex];
		
		// if (vehicleUsingNOS[vIndex] && (Button & IN_BACK)) {
		// 	new args[1];
		// 	args[0] = vIndex;
		// 	set_task(0.1, "turnOffNOS", 0, args, 1);
		// }

		// DRIFTING
		if (vType == VTYPE_CAR_RWD && (OldButtons & IN_FORWARD)) {
			if ((Button & IN_MOVELEFT) && (OldButtons & IN_MOVELEFT)) {
				new Float:vector[3];
				entity_get_vector(userVehicle[id], EV_VEC_angles, vector);
				engfunc(EngFunc_MakeVectors, vector);
				new Float:v_right[3];
				get_global_vector(GL_v_right, v_right);
				entity_get_vector(userVehicle[id], EV_VEC_velocity, vector);
				if (vector[2] == 0.0) {
					new Float:force = floatdiv(vector_length(vector), defaultdriftForce);
					vector[0] = v_right[0] * force;
					vector[1] = v_right[1] * force;
					set_pev(userVehicle[id], pev_basevelocity, vector);
				}
				return FMRES_IGNORED;
			}
			if ((Button & IN_MOVERIGHT) && (OldButtons & IN_MOVERIGHT)) {
				new Float:vector[3];
				entity_get_vector(userVehicle[id], EV_VEC_angles, vector);
				engfunc(EngFunc_MakeVectors, vector);
				new Float:v_right[3];
				get_global_vector(GL_v_right,v_right);
				entity_get_vector(userVehicle[id], EV_VEC_velocity, vector);
				if (vector[2] == 0.0) {
					new Float:force = floatdiv(vector_length(vector), defaultdriftForce) * -1.0;
					vector[0] = v_right[0] * force;
					vector[1] = v_right[1] * force;
					set_pev(userVehicle[id], pev_basevelocity, vector);
				}
				return FMRES_IGNORED;
			}
		}

		// RIGHT CLICK
		if ((Button & IN_ATTACK2) && !(OldButtons & IN_ATTACK2)) {
			switch (vWeapon) {
				case VWEAPON_SHELL_HEAT: {
					if (checkVehicleAngle(id) && checkDelay(id, vIndex, defaultWeaponShellDelay, true)) {
						fireShell(id, vIndex, "heat", 2500);
						fired_weapon = true;
					}
				}
				case VWEAPON_SHELL_AP: {
					if (checkVehicleAngle(id) && checkDelay(id, vIndex, defaultWeaponShellDelay, true)) {
						fireShell(id, vIndex, "ap", 2750);
						fired_weapon = true;
					}
				}
				case VWEAPON_SHELL_HE: {
					if (checkVehicleAngle(id) && checkDelay(id, vIndex, defaultWeaponShellDelay, true)) {
						fireShell(id, vIndex, "he", 2250);
						fired_weapon = true;
					}
				}
				case VWEAPON_CONC_CANNON: {
					if (checkVehicleAngle(id) && checkDelay(id, vIndex, defaultWeaponConcCannonDelay, true)) {
						client_print(id, print_chat, "[AFV] Firing concussion cannon");
						fireConcCannon(id, vIndex);
						fired_weapon = true;
					}
				}
				case VWEAPON_HORN: {
					if (checkDelay(id, vIndex, 3.0, false)) {
						emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/car_horn.wav", defaultWeaponCarHornDelay, ATTN_NORM, 0, PITCH_NORM);
						fired_weapon = true;
					}
				}
				case VWEAPON_TRUCK_HORN: {
					if (checkDelay(id, vIndex, 10.0, false)) {
						emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/truck_horn.wav", defaultWeaponTruckHornDelay, ATTN_NORM, 0, PITCH_NORM);
						fired_weapon = true;
					}
				}
				case VWEAPON_SHIP_HORN: {
					if (checkDelay(id, vIndex, 15.0, false)) {
						emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/ship_horn.wav", defaultWeaponShipHornDelay, ATTN_NORM, 0, PITCH_NORM);
						fired_weapon = true;
					}
				}
				case VWEAPON_NOS: {
					if (checkDelay(id, vIndex, 8.0, false) && !(Button & IN_BACK)) {
						vehicleUsingNOS[vIndex] = true;
						new Float:speed = vehicleDefaultSpeeds[vIndex];
						speed = floatadd(speed, floatmul(floatdiv(vehicleDefaultSpeeds[vIndex],100.0), defaultNOSVelocity));
						set_pdata_float(userVehicle[id], m_iSpeed, speed, 4);

						new args[1];
						args[0] = vIndex;
						set_task(3.0, "turnOffNOS", 0, args, 1);
						fired_weapon = true;
					}
				}
				case VWEAPON_GUIDED_MISSILE: {
					if (checkVehicleAngle(id) && checkDelay(id, vIndex, defaultWeaponGuidedMissileDelay, true)) {
						client_print(id, print_chat, "[AFV] Firing guided missile");
						fireGuidedMissile(id, vIndex);
						fired_weapon = true;
					}
				}
			}
		}
		
		if ((Button & IN_ATTACK2) && (OldButtons & IN_ATTACK2) && checkVehicleAngle(id)) {

			switch (vWeapon) {
				case VWEAPON_LMG1: {
					if (checkDelay(id, vIndex, 0.1, false)) {
						fireShot(id, vIndex, "afv_lmg1");
						fired_weapon = true;
					}
				}
				case VWEAPON_HMG1: {
					if (checkDelay(id, vIndex, 0.2, false)) {
						fireShot(id, vIndex, "afv_hmg1");
						fired_weapon = true;
					}
				}
				case VWEAPON_AUTO_CANNON: {
					if (checkDelay(id, vIndex, 0.8, false)) {
						fireShot(id, vIndex, "afv_auto_cannon");
						fired_weapon = true
					}
				}
				case VWEAPON_MINIGUN: {
					if (checkDelay(id, vIndex, 0.05, false)) {
						fireShot(id, vIndex, "afv_minigun");
						fired_weapon = true;
					}
				}
			}
		}

		if (fired_weapon) {
			vehicleLastShootTime[vIndex] = get_gametime();
		}

		// UP + DOWN
		if (vType != VTYPE_HELI && vType != VTYPE_VTOL) {
			return FMRES_IGNORED;
		}
		if ((Button & IN_ATTACK) && (OldButtons & IN_ATTACK)) {
			new Float:velocity[3] = {0.0, 0.0, 0.0};
			velocity[2] = defaultVtolVelocity;
			set_pev(userVehicle[id], pev_basevelocity, velocity);

			// new height logic
			new Float:vVehicleOrigin[3];
			new Float:vDefaultVehicleOrigin;
			entity_get_vector(userVehicle[id], EV_VEC_origin, vVehicleOrigin);
			vDefaultVehicleOrigin = vehicleDefaultOrigins[vIndex];

			if (vVehicleOrigin[2] > vDefaultVehicleOrigin) { // height should be higher than default;
				new Float:origin_difference = floatsub(vVehicleOrigin[2], vDefaultVehicleOrigin);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatadd(default_vehicle_height, origin_difference), 4);
			}
			else if (vVehicleOrigin[2] < vDefaultVehicleOrigin) {
				new Float:origin_difference = floatsub(vDefaultVehicleOrigin, vVehicleOrigin[2]);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatsub(default_vehicle_height, origin_difference), 4);
			}
			return FMRES_IGNORED;
		}
		else if ((Button & IN_DUCK) && (OldButtons & IN_DUCK)) {
			new Float:velocity[3] = {0.0, 0.0, 0.0};
			velocity[2] = -defaultVtolVelocity;
			set_pev(userVehicle[id], pev_basevelocity, velocity);

			// new height logic
			new Float:vVehicleOrigin[3];
			new Float:vDefaultVehicleOrigin;
			entity_get_vector(userVehicle[id], EV_VEC_origin, vVehicleOrigin);
			vDefaultVehicleOrigin = vehicleDefaultOrigins[vIndex];

			if (vVehicleOrigin[2] > vDefaultVehicleOrigin) { // height should be higher than default
				new Float:origin_difference = floatsub(vVehicleOrigin[2], vDefaultVehicleOrigin);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatadd(default_vehicle_height,origin_difference), 4);
			}
			else if (vVehicleOrigin[2] < vDefaultVehicleOrigin) {
				new Float:origin_difference = floatsub(vDefaultVehicleOrigin, vVehicleOrigin[2]);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatsub(default_vehicle_height,origin_difference), 4);
			}
			return FMRES_IGNORED;
		}
		else {
			set_pev(userVehicle[id], pev_basevelocity, {0.0, 0.0, 0.0});
		}
	}
	return FMRES_IGNORED;
}

public turnOffNOS(args[]) {
	if  (is_valid_ent(vehicleIds[args[0]])) {
		set_pdata_float(vehicleIds[args[0]], m_iSpeed, vehicleDefaultSpeeds[args[0]], 4);
		vehicleUsingNOS[args[0]] = false;
	}
}

public forward_playerprethink(id) {
	if (is_user_alive(id)) {
		if (userControl[id] && userControl[id] > 0) {
			new RocketEnt = userControl[id];
			if (is_valid_ent(RocketEnt)) {
				new Float:Velocity[3];
				VelocityByAim(id, 800, Velocity);
				entity_set_vector(RocketEnt, EV_VEC_velocity, Velocity);
				new Float:NewAngle[3];
				entity_get_vector(id, EV_VEC_v_angle, NewAngle);
				entity_set_vector(RocketEnt, EV_VEC_angles, NewAngle);
			}
			else {
				attach_view(id, id);
			}
		}
	}
	return FMRES_IGNORED;
}

public checkDelay(id, vIndex, Float:delay, showMessage) {
	if (get_gametime() > vehicleLastShootTime[vIndex] + delay) {
		return true;
	}
  	if (showMessage) {
		client_print(id,print_chat, "[AFV] Try again in %d seconds", floatround(vehicleLastShootTime[vIndex] + delay - get_gametime()+ 1));
	}
	return false; 
}

public checkVehicleAngle(id) {
	new Float:vViewAngles[3];
	entity_get_vector( id, EV_VEC_angles, vViewAngles);

	new Float:vVehicleAngles[3]	;
	entity_get_vector(userVehicle[id], EV_VEC_angles, vVehicleAngles);

	//fix Vehicle angle
	while (vVehicleAngles[1] >= 360) {
		vVehicleAngles[1] = vVehicleAngles[1] - 360;
	}
	while (vVehicleAngles[1] < 0) {
		vVehicleAngles[1] = vVehicleAngles[1] + 360;
	}
	vVehicleAngles[1] = vVehicleAngles[1] - 180; // tbc

	if (vViewAngles[1] < vVehicleAngles[1] - 45 || vViewAngles[1] > vVehicleAngles[1] + 45) {
		return false;
	}

	return true;
}

public _getUserDriving(plugin, params) {
	if (params != 1) {
		return PLUGIN_CONTINUE;
	}

	new vehicle_id = get_param(1);
	if (!vehicle_id) {
		return PLUGIN_CONTINUE;
	}

	return getUserDriving(vehicle_id);
}

public getUserDriving(vehicle_id) {
	static vIndex = -1;
	new index;
	while (index < 63) {
		if (vehicle_id == vehicleIds[index]) {
			vIndex = index;
			break;
		}
		index++;
	}

	if (vIndex < 0 || vehicleCurrentHPs[vIndex] <= 0) {
		return 0;
	}

	new i;
	for (i = 1;i <= 32; i++) {
		if (is_user_connected(i) && userVehicle[i] == vehicle_id && cs_get_user_driving(i) > 0) {
			return i;
		}
	}

	return 0;
}

public _damageVehicle(plugin, params) {
	if (params != 2) {
		return PLUGIN_CONTINUE;
	}

	new vehicle_id = get_param(1);
	if (!vehicle_id) {
		return PLUGIN_CONTINUE;
	}

	new weaponClass[16];
	get_string(2, weaponClass, 16);

	new Float:sourceOrigin[3];

	damageVehicle(vehicle_id, weaponClass, sourceOrigin);
	return PLUGIN_HANDLED;
}

public damageVehicle(vehicle_id, weaponClass[], Float:sourceOrigin[3]) {

	new damage = 0;
	new Float:damageMultipler = 1.0;
	new targetname[32];
	new vIndex = -1;
	entity_get_string(vehicle_id,EV_SZ_targetname,targetname,31);
	new index;
	while (index < 63) {
		if (vehicle_id == vehicleIds[index]) {
			vIndex = index;
			break;
		}
		index++;
	}

	if (vIndex < 0 || vehicleCurrentHPs[vIndex] <= 0) {
		return false;
	}

	// work out damage vs resistance
	//base damage vs VEHICLE
	if (equal(weaponClass, "afv_minigun")) {
		damage = 1;
	}
	else if (equal(weaponClass, "afv_lmg1")) {
		damage = 7;
	}
	else if (equal(weaponClass, "afv_hmg1")) {
		damage = 15;
	}
	else if (equal(weaponClass, "afv_auto_cannon")) {
		damage = 60;
	}
	else if (equal(weaponClass, "afv_shell_he")) {
		damage = 150;
	}
	else if (equal(weaponClass, "afv_shell_heat")) {
		damage = 200;
	}
	else if (equal(weaponClass, "afv_shell_ap")) {
		damage = 300;
	}
	else if (equal(weaponClass, "afv_conc_cannon")) {
		damage = 250;
	}
	else if (equal(weaponClass, "afv_guided_missile")) {
		damage = 400;
	}

	// ANTI
	else if (equal(weaponClass, "afv_av_mine")) {
		damage = 1000;
	}
	else if (equal(weaponClass, "afv_anti_materiel_round")) {
		damage = 150;
	}
	else if (equal(weaponClass, "afv_rocket") || equal(weaponClass, "afv_guided_rocket")) {
		damage = 200;
	}
	else if (equal(weaponClass, "rpg_rocket")) {
		damage = 200;
	}

	// LMG1 + MINIGUN do -75% damage to TANK and APC
	if (equal(weaponClass, "afv_lmg1") || equal(weaponClass, "afv_minigun")) {
		if(equal(vehicleTypes[vIndex], "TANK") || equal(vehicleTypes[vIndex], "APC")) {
			damageMultipler = floatsub(damageMultipler, 0.75);
		}
	}

	// all +50% damage to CAR + CAR_RWD + BIKE + HELI + VTOL + PLANE + FIGHTERJET
	if (equal(vehicleTypes[vIndex], "CAR") || equal(vehicleTypes[vIndex], "CAR_RWD") || equal(vehicleTypes[vIndex], "BIKE") || equal(vehicleTypes[vIndex], "HELI")
		 || equal(vehicleTypes[vIndex], "VTOL") || equal(vehicleTypes[vIndex], "PLANE") || equal(vehicleTypes[vIndex], "FIGHTERJET")
	) {
		damageMultipler = floatadd(damageMultipler, 0.50);
	}

	// HMG1 +20% damage to + HELI + VTOL + PLANE + FIGHTERJET
	if (equal(weaponClass, "afv_hmg1")) {
		if (equal(vehicleTypes[vIndex], "HELI") || equal(vehicleTypes[vIndex], "VTOL") || equal(vehicleTypes[vIndex], "PLANE") || equal(vehicleTypes[vIndex], "FIGHTERJET")) {
			damageMultipler = floatadd(damageMultipler, 0.20);
		}
	}

	// AUTO CANNON +20% to CAR + CAR_RWD + BIKE + VEHICLE
	if (equal(weaponClass, "afv_auto_cannon")) {
		if (equal(vehicleTypes[vIndex], "CAR") || equal(vehicleTypes[vIndex], "CAR_RWD") || equal(vehicleTypes[vIndex], "BIKE") || equal(vehicleTypes[vIndex], "VEHICLE")) {
			damageMultipler = floatadd(damageMultipler, 0.20);
		}
	}

	// HE does +30% to CAR + CAR_RWD + BIKE
	if (equal(weaponClass, "afv_shell_he")) {
		if (equal(vehicleTypes[vIndex], "CAR") || equal(vehicleTypes[vIndex], "CAR_RWD") || equal(vehicleTypes[vIndex], "BIKE")) {
			damageMultipler = floatadd(damageMultipler, 0.30);
		}
	}

	// AP does +30% to TANK + APC
	if (equal(weaponClass, "afv_shell_ap")) {
		if (equal(vehicleTypes[vIndex], "TANK") || equal(vehicleTypes[vIndex], "APC")) {
			damageMultipler = floatadd(damageMultipler, 0.30);
		}
	}

	// MISSLE +50% to TANK + APC
	if (equal(weaponClass, "afv_guided_missile")) {
		if (equal(vehicleTypes[vIndex], "TANK") || equal(vehicleTypes[vIndex], "APC")) {
			damageMultipler = floatadd(damageMultipler, 0.50);
		}
	}

	new Float:endOrigin[3]
	entity_get_vector(vehicle_id, EV_VEC_origin, endOrigin);
	
	// directional damage and pens for shells
	if (equal(weaponClass, "afv_shell_he") || equal(weaponClass, "afv_shell_heat") || equal(weaponClass, "afv_shell_ap")) {

		new Float:fVector[3];
		new Float:fAngle[3];

		new Float:vAngle[3];
		pev(vehicle_id, pev_angles, vAngle);
		while (vAngle[1] < 0.0) {
			vAngle[1] += 360.0;
		}
		while (vAngle[1] > 360.0) {
			vAngle[1] -= 360.0;
		}

		xs_vec_sub(sourceOrigin, endOrigin, fVector);
		vector_to_angle(fVector, fAngle);
		while (fAngle[1] < 0.0) {
			fAngle[1] += 360.0;
		}
		while (fAngle[1] > 360.0) {
			fAngle[1] -= 360.0;
		}

		if ((vAngle[1] - fAngle[1]) > 135 || (fAngle[1] - vAngle[1]) > 135) {
			// FRONT
			//server_print("target vehicle Direction: FRONT");
		} else if ((vAngle[1] - fAngle[1]) > 45 || (fAngle[1] - vAngle[1]) > 45) {
			// SIDE
			damageMultipler = floatadd(damageMultipler, 0.10);
			//server_print("target vehicle Direction: SIDE");
		} else {
			// REAR
			damageMultipler = floatadd(damageMultipler, 0.50);
			//server_print("target vehicle Direction: REAR");
		}
		// end directional

		// penetrating hits
		new Float:distance = get_distance_f(endOrigin, sourceOrigin);
		//server_print("target vehicle distance: %f", distance);
		if (distance < 400.0) {
			damageMultipler = floatadd(damageMultipler, 0.50);
			//server_print("target vehicle Direction: PEN HIT");
		}
	}

	damage = floatround(floatmul(float(damage), damageMultipler), floatround_ceil);

	if (damage < vehicleCurrentHPs[vIndex]) {
		vehicleCurrentHPs[vIndex] = vehicleCurrentHPs[vIndex] - damage;
	} else {
		vehicleCurrentHPs[vIndex] = 0;

		emit_sound(vehicle_id, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);
		emit_sound(vehicle_id, CHAN_VOICE, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // explosion sprite
		write_byte(TE_SPRITE);
		engfunc(EngFunc_WriteCoord, endOrigin[0]);
		engfunc(EngFunc_WriteCoord, endOrigin[1]);
		engfunc(EngFunc_WriteCoord, endOrigin[2] + 64);
		write_short(explosion);
		write_byte(40); //scale
		write_byte(240);
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // Blast wave
		write_byte(TE_BEAMCYLINDER);
		engfunc(EngFunc_WriteCoord, endOrigin[0]);
		engfunc(EngFunc_WriteCoord, endOrigin[1]);
		engfunc(EngFunc_WriteCoord, endOrigin[2]);
		engfunc(EngFunc_WriteCoord, endOrigin[0]);
		engfunc(EngFunc_WriteCoord, endOrigin[1]);
		engfunc(EngFunc_WriteCoord, endOrigin[2] + 320);
		write_short(white);
		write_byte(0);
		write_byte(0);
		write_byte(16);
		write_byte(128);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(192);
		write_byte(128);
		write_byte(0);
		message_end();

		// burn vehicle
		new args[1];
		args[0] = vehicle_id;
		new burn_task_id = 8397 + index;
		set_task( 2.5 , "burn_vehicle" , burn_task_id , args, 1, "b" );

		//darken vehicle
		//set_rendering( vehicle_id, kRenderFxNone , 1, 1, 1, kRenderTransColor, 255);
		new Float:renderColor[3];
		renderColor[0] = 1.0;
		renderColor[1] = 1.0;
		renderColor[2] = 1.0;

		entity_set_vector(vehicle_id, EV_VEC_rendercolor, renderColor);
		entity_set_int(vehicle_id, EV_INT_rendermode, kRenderTransColor);
		entity_set_float(vehicle_id, EV_FL_renderamt, 255.0);
	}
	return true;
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[]) {
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3];

	pev(id, pev_origin, vOrigin);
	pev(id, pev_angles, vAngle); // if normal entity ,use pev_angles

	angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward); //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight);
	angle_vector(vAngle,ANGLEVECTOR_UP, vUp);

	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up;
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up;
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up;
}

public fireShell(id, vIndex, shellType[], shellVelocity) {
	new weaponClass[16] = "afv_shell_";
	strcat(weaponClass, shellType, 16);

	new shellTypeU[8];
	copy(shellTypeU, 8, shellType);
	strtoupper(shellTypeU);
	client_print(id, print_chat, "[AFV] Firing %s shell", shellTypeU);

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_0[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_1[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_2[vIndex]); // up
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, firedOrigin[0]);
	engfunc(EngFunc_WriteCoord, firedOrigin[1]);
	engfunc(EngFunc_WriteCoord, firedOrigin[2]);
	write_short(explosion1);
	write_byte(64);
	write_byte(230);
	message_end();

	new Float:Angle[3];
	entity_get_vector(userVehicle[id], EV_VEC_v_angle, Angle);
	new RocketEnt = create_entity("info_target");
	entity_set_string(RocketEnt, EV_SZ_classname, weaponClass);
	entity_set_model(RocketEnt, "models/rpgrocket.mdl");
	entity_set_origin(RocketEnt, firedOrigin);

	new Float:MinBox[3] = {-1.0, -1.0, -1.0};
	new Float:MaxBox[3] = {1.0, 1.0, 1.0};
	entity_set_vector(RocketEnt, EV_VEC_mins, MinBox);
	entity_set_vector(RocketEnt, EV_VEC_maxs, MaxBox);

	set_rendering(RocketEnt, kRenderFxNone, 245, 212, 66, kRenderTransAdd, 255);
	entity_set_int(RocketEnt, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_float(RocketEnt, EV_FL_gravity, 0.4);
	entity_set_int(RocketEnt, EV_INT_solid, SOLID_BBOX);
	entity_set_edict(RocketEnt, EV_ENT_owner, id);

	new Float:Velocity[3];
	VelocityByAim(id, shellVelocity, Velocity); // 1800-3000
	entity_set_vector(RocketEnt, EV_VEC_velocity, Velocity);

	vector_to_angle(Velocity, Angle);
	entity_set_vector(RocketEnt, EV_VEC_angles, Angle);

	new Float:aVelocity[3];
	aVelocity[2] = 600.0; //spin shell
	entity_set_vector(RocketEnt, EV_VEC_avelocity, aVelocity);

	emit_sound(RocketEnt, CHAN_WEAPON, "ambience/biggun3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public fireConcCannon(id, vIndex) {

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_0[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_1[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_2[vIndex]); // up
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, firedOrigin[0]);
	engfunc(EngFunc_WriteCoord, firedOrigin[1]);
	engfunc(EngFunc_WriteCoord, firedOrigin[2]);
	write_short(smoke);
	write_byte(64);
	write_byte(10);
	message_end();

	new Float:Angle[3];
	entity_get_vector(userVehicle[id], EV_VEC_v_angle, Angle);
	new RocketEnt = create_entity("info_target");
	entity_set_string(RocketEnt, EV_SZ_classname, "afv_conc_cannon");
	entity_set_model(RocketEnt, "models/rpgrocket.mdl");
	entity_set_origin(RocketEnt, firedOrigin);
	entity_set_vector(RocketEnt, EV_VEC_angles, Angle);

	new Float:MinBox[3] = {-1.0, -1.0, -1.0};
	new Float:MaxBox[3] = {1.0, 1.0, 1.0};
	entity_set_vector(RocketEnt, EV_VEC_mins, MinBox);
	entity_set_vector(RocketEnt, EV_VEC_maxs, MaxBox);

	entity_set_int(RocketEnt, EV_INT_solid, 2);
	entity_set_int(RocketEnt, EV_INT_movetype, 5);
	entity_set_edict(RocketEnt, EV_ENT_owner, id);

	new Float:Velocity[3];
	VelocityByAim(id, 2000, Velocity);
	entity_set_vector(RocketEnt, EV_VEC_velocity, Velocity);
	set_rendering(RocketEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha,0);

	emit_sound(RocketEnt, CHAN_WEAPON, "debris/beamstart8.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(RocketEnt);
	write_short(rocketsmoke);
	write_byte(30);
	write_byte(16);
	write_byte(0); // r
	write_byte(255); // g
	write_byte(255); // b
	write_byte(200); // brightness
	message_end();

	return PLUGIN_HANDLED;
}

public fireGuidedMissile(id, vIndex) {

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_0[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_1[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_2[vIndex]); // up
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, firedOrigin[0]);
	engfunc(EngFunc_WriteCoord, firedOrigin[1]);
	engfunc(EngFunc_WriteCoord, firedOrigin[2]);
	write_short(smoke);
	write_byte(96); //scale
	write_byte(10);	//framerate
	message_end();

	new Float:Angle[3];
	entity_get_vector(userVehicle[id], EV_VEC_v_angle, Angle);
	new RocketEnt = create_entity("info_target");
	entity_set_string(RocketEnt, EV_SZ_classname, "afv_guided_missile");
	entity_set_model(RocketEnt, "models/rpgrocket.mdl");
	entity_set_origin(RocketEnt, firedOrigin);
	entity_set_vector(RocketEnt, EV_VEC_angles, Angle);

	new Float:MinBox[3] = {-1.0, -1.0, -1.0};
	new Float:MaxBox[3] = {1.0, 1.0, 1.0};
	entity_set_vector(RocketEnt, EV_VEC_mins, MinBox);
	entity_set_vector(RocketEnt, EV_VEC_maxs, MaxBox);

	entity_set_int(RocketEnt, EV_INT_solid, 2);
	entity_set_int(RocketEnt, EV_INT_movetype, 5);
	entity_set_edict(RocketEnt, EV_ENT_owner, id);

	new Float:Velocity[3];
	VelocityByAim(id, 800, Velocity);
	entity_set_vector(RocketEnt, EV_VEC_velocity, Velocity);
	set_rendering(RocketEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha,0);

	emit_sound(RocketEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_LOW);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(RocketEnt);
	write_short(rocketsmoke);
	write_byte(30); // life
	write_byte(16);
	write_byte(200); // g
	write_byte(200); // r
	write_byte(200); // b
	write_byte(200); // brightness
	message_end();

	entity_set_int(RocketEnt, EV_INT_rendermode, 1);
	attach_view(id, RocketEnt);
	userControl[id] = RocketEnt;

	return PLUGIN_HANDLED;
}

public weaponTouchAp(touched, toucher) {
	weaponTouch(touched, toucher, "afv_shell_ap", 60, 200, false);
	return PLUGIN_CONTINUE;
}
public weaponTouchHeat(touched, toucher) {
	weaponTouch(touched, toucher, "afv_shell_heat", 70, 300, false);
	return PLUGIN_CONTINUE;
}
public weaponTouchHe(touched, toucher) {
	weaponTouch(touched, toucher, "afv_shell_he", 80, 400, false);
	return PLUGIN_CONTINUE;
}
public weaponTouchConcCannon(touched, toucher) {
	weaponTouch(touched, toucher, "afv_conc_cannon", 90, 300, false);
	return PLUGIN_CONTINUE;
}
public weaponTouchGuidedMissile(touched, toucher) {
	weaponTouch(touched, toucher, "afv_guided_missile", 90, 200, true);
	return PLUGIN_CONTINUE;
}

public weaponTouch(touched, toucher, className[], maxDamage, damageRadius, guided) {
	remove_task(toucher);

	static Float:EndOrigin[3];
	entity_get_vector(toucher, EV_VEC_origin, EndOrigin);

	emit_sound(toucher, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(toucher, CHAN_VOICE, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // explosion sprite
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, EndOrigin[0]);
	engfunc(EngFunc_WriteCoord, EndOrigin[1]);
	engfunc(EngFunc_WriteCoord, EndOrigin[2] + 128);
	write_short(explosion);
	write_byte(30);
	write_byte(255);
	message_end();

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // smoke
	write_byte(TE_SMOKE);
	engfunc(EngFunc_WriteCoord, EndOrigin[0]);
	engfunc(EngFunc_WriteCoord, EndOrigin[1]);
	engfunc(EngFunc_WriteCoord, EndOrigin[2] + 256);
	write_short(smoke);
	write_byte(125);
	write_byte(5);
	message_end();

	static PlayerPos[3], distance, damage, attacker;
	for (new i = 1; i < 32; i++) {
		if (is_user_alive(i) == 1) {
			get_user_origin(i, PlayerPos);

			static NonFloatEndOrigin[3];
			NonFloatEndOrigin[0] = floatround(EndOrigin[0]);
			NonFloatEndOrigin[1] = floatround(EndOrigin[1]);
			NonFloatEndOrigin[2] = floatround(EndOrigin[2]);

			distance = get_distance(PlayerPos, NonFloatEndOrigin);
			if (distance <= damageRadius) { // damage radius
				message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i); // shake
				write_short(1<<14);
				write_short(1<<14);
				write_short(1<<14);
				message_end();

				damage = maxDamage - floatround(floatmul(float(maxDamage), floatdiv(float(distance), float(damageRadius))))
				attacker = entity_get_edict(toucher, EV_ENT_owner);

				if (!get_user_godmode(i)) {
					if (get_user_team(attacker) != get_user_team(i)) {
						if (damage < get_user_health(i)) {
							set_user_health(i, get_user_health(i) - damage);
						}
						else {
							set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
							user_kill(i, 1);
							set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

							message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"));  // Kill log in the top right
							write_byte(attacker); // Attacker
							write_byte(i); // Victim
							write_byte(0); // Headshot
							write_string(className);
							message_end();
							new userFrags = get_user_frags(attacker);
							userFrags = userFrags + 1;
							set_user_frags(attacker, userFrags);

							new money = cs_get_user_money(attacker);
							cs_set_user_money(attacker, money + 300);
						}
					}
					else {
						if (attacker == i) {
							if (damage < get_user_health(i)) {
								set_user_health(i, get_user_health(i) - damage);
							}
							else {
								set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
								user_kill(i, 1);
								set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

								message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg")); // Kill log in the top right
								write_byte(attacker); // Attacker
								write_byte(i); // Victim
								write_byte(0); // Headshot
								write_string(className);
								message_end();

								set_user_frags(attacker, get_user_frags(attacker) - 1);
								new money = cs_get_user_money(attacker);
								cs_set_user_money(attacker, money + 300);
							}
						}
						else {
							if (get_cvar_num("mp_friendlyfire")) {
								if (damage < get_user_health(i)) {
									set_user_health(i, get_user_health(i) - damage);
								}
								else {
									set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
									user_kill(i, 1);
									set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

									message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg")); // Kill log in the top right
									write_byte(attacker); // Attacker
									write_byte(i); // Victim
									write_byte(0); // Headshot
									write_string(className);
									message_end();

									set_user_frags(attacker, get_user_frags(attacker) - 1);
								}
							}
						}
					}
				}
			}
		}
	}

	// vehicle hit
	if  (is_valid_ent(touched)) {
		static sz_classname[33];
		entity_get_string(touched, EV_SZ_classname, sz_classname, charsmax(sz_classname));

		if (equal(sz_classname, "func_vehicle")) {
			new Float:vVehicleOrigin[3];
			entity_get_vector(userVehicle[entity_get_edict(toucher, EV_ENT_owner)], EV_VEC_origin, vVehicleOrigin);
			damageVehicle(touched, className, vVehicleOrigin);
		}
	}

	if (guided) {
		attach_view(entity_get_edict(toucher, EV_ENT_owner), entity_get_edict(toucher, EV_ENT_owner));
		userControl[entity_get_edict(toucher, EV_ENT_owner)] = 0;
	}

	remove_entity(toucher);
}

/* vehicle bullets */
stock Float:fpev(_index, _value) {
	static Float:fl;
	pev(_index, _value, fl);
	return fl;
}

stock fireShot(id, vIndex, weaponClass[]) {
	static damage = 1; // also minigun
	static shotSound[32];
	shotSound = "weapons/hks2.wav";

	if (strcmp(weaponClass, "afv_lmg1") == 0) {
		damage = 7;
	} else if (strcmp(weaponClass, "afv_hmg1") == 0) {
		damage = 40; // was 15
	} else if (strcmp(weaponClass, "afv_auto_cannon") == 0) {
		damage = 60;
		shotSound = "ambience/biggun2.wav";
	}

	static Float:playerAngle[3],Float:vecDirShooting[3];
	entity_get_vector(id, EV_VEC_angles, playerAngle);

	static Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_0[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_1[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_2[vIndex]); // up
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	playerAngle[0] *= -1.0;
	angle_vector(playerAngle, ANGLEVECTOR_FORWARD, vecDirShooting);

	//FIRE
	emit_sound(userVehicle[id], CHAN_WEAPON, shotSound, 0.6, ATTN_NORM, 0, PITCH_NORM);

	static tr, Float:vecEnd[3], pHit, Float:vecEndPos[3], Float:distance;
	tr = create_tr2();
	vecEnd[0] = firedOrigin[0] + (vecDirShooting[0] + random_float(-0.025, 0.025)) * 8192.0;
	vecEnd[1] = firedOrigin[1] + (vecDirShooting[1] + random_float(-0.025, 0.025)) * 8192.0;
	vecEnd[2] = firedOrigin[2] + (vecDirShooting[2] + random_float(-0.025, 0.025)) * 8192.0;

	distance = get_distance_f(firedOrigin, vecEnd);
	if (distance <= 25) {
		return false;
	}

	engfunc(EngFunc_TraceLine, firedOrigin, vecEnd, 0, id, tr);
	pHit = get_tr2(tr, TR_pHit);
	get_tr2(tr, TR_vecEndPos, vecEndPos);

	if (pHit == id) {
		return false;
	}

	if  (is_valid_ent(pHit)) {
		if (pHit == userVehicle[id]) {
			return false;
		}

		new sz_classname[33];
		entity_get_string(pHit, EV_SZ_classname, sz_classname, charsmax(sz_classname));

		if (equal(sz_classname, "func_vehicle")) {
			damageVehicle(pHit, weaponClass, firedOrigin);
		}
	}

	if (is_user_alive(pHit) && !get_user_godmode(pHit) && (get_user_team(id) != get_user_team(pHit))) {
		set_pev(pHit, pev_dmg_inflictor, id);
		ExecuteHamB(Ham_TraceBleed, pHit, damage, vecDirShooting, tr, DMG_BULLET)
		if (damage < get_user_health(pHit)) {
			set_user_health(pHit, get_user_health(pHit) - damage);
		}
		else {
			set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
			user_kill(pHit, 1);
			set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

			message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"));
			write_byte(id); // Attacker
			write_byte(pHit); // Victim
			write_byte(0); // Headshot
			write_string("machine gun");
			message_end();
			new userFrags = get_user_frags(id);
			userFrags = userFrags + 1;
			set_user_frags(id, userFrags);

			new money = cs_get_user_money(id);
			cs_set_user_money(id, money + 300);
		}
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_TRACER);
	engfunc(EngFunc_WriteCoord, firedOrigin[0]);
	engfunc(EngFunc_WriteCoord, firedOrigin[1]);
	engfunc(EngFunc_WriteCoord, firedOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecEndPos[0]);
	engfunc(EngFunc_WriteCoord, vecEndPos[1]);
	engfunc(EngFunc_WriteCoord, vecEndPos[2]);
	message_end();

	if (!pev_valid(pHit)) {
		pHit = 0;
	}
	if (ExecuteHam(Ham_IsBSPModel, pHit)) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_GUNSHOT);
		engfunc(EngFunc_WriteCoord, vecEndPos[0]);
		engfunc(EngFunc_WriteCoord, vecEndPos[1]);
		engfunc(EngFunc_WriteCoord, vecEndPos[2]);
		message_end();
	}

	free_tr2(tr);
	return true;
}

public load_config() {
	new filename[72];
	if (get_configfile(filename, 71)) {
		new filepointer = fopen(filename, "r");
		if (filepointer) {
			new readdata[128];
			new vehicle_name[32],vehicle_type[32],vehicle_wpn[32];
			new vehicle_hp[32], vehicle_wpn1_x[32], vehicle_wpn1_y[32], vehicle_wpn1_z[32];

			while (fgets(filepointer,readdata,127)) {
				parse(readdata, vehicle_name,31, vehicle_type,31, vehicle_hp,31, vehicle_wpn,31, vehicle_wpn1_x, 31, vehicle_wpn1_y, 31, vehicle_wpn1_z, 31);

				trim(vehicle_type);
				trim(vehicle_wpn);

				new id_index;
				while(id_index < 63) {
					new targetname[32];
					entity_get_string(vehicleIds[id_index],EV_SZ_targetname,targetname,31);
					if (strcmp(targetname,vehicle_name) == 0) {
						copy(vehicleNames[id_index], 31, vehicle_name);
						
						new vehicleType:vehicle_type_id;
						if (TrieGetCell(vehicleTypesConfig, vehicle_type, vehicle_type_id)) {
							vehicleTypes[id_index] = vehicle_type_id;
						} else {
							vehicleTypes[id_index] = VTYPE_VEHICLE;
						}

						new vehicleWeapon:vehicle_weapon_type_id;
						if (TrieGetCell(vehicleWeaponsConfig, vehicle_wpn, vehicle_weapon_type_id)) {
							vehicleWeaponTypes[id_index] = vehicle_weapon_type_id;
						} else {
							vehicleWeaponTypes[id_index] = VWEAPON_NO;
						}

						vehicleHPs[id_index] = str_to_num(vehicle_hp);
						vehicleWPN1_0[id_index] = str_to_num(vehicle_wpn1_x);
						vehicleWPN1_1[id_index] = str_to_num(vehicle_wpn1_y);
						vehicleWPN1_2[id_index] = str_to_num(vehicle_wpn1_z);

						//server_print("Loaded: %s - %d - %d - %d - %d - %d - %d", vehicleNames[id_index], vehicleTypes[id_index], vehicleHPs[id_index], vehicleWeaponTypes[id_index], vehicleWPN1_0[id_index], vehicleWPN1_1[id_index], vehicleWPN1_2[id_index])

						if  (is_valid_ent(vehicleIds[id_index])) {
							drop_to_floor(vehicleIds[id_index]); // quick fix for some BROKEN maps
							new args[1];
							args[0] = id_index;
							set_task(1.0, "delayedDroppedToFloor", 0, args, 1);
						}
					}
					id_index++;
				}
			}
			fclose(filepointer);
		}
	}
}

public delayedDroppedToFloor(args[]) {
	new id_index = args[0];

	vehicleDefaultHeights[id_index] = get_pdata_float(vehicleIds[id_index], m_iHeight, 4);

	new Float:vVehicleOrigin[3];
	entity_get_vector(vehicleIds[id_index], EV_VEC_origin, vVehicleOrigin);
	vehicleDefaultOrigins[id_index] = vVehicleOrigin[2];

	vehicleDefaultSpeeds[id_index] = get_pdata_float(vehicleIds[id_index], m_iSpeed, 4);

	// colors for darkening
	new Float:renderColor[3];
	entity_get_vector(vehicleIds[id_index], EV_VEC_rendercolor, renderColor);
	vehicleDefaultRenderColors[id_index] = renderColor;

	vehicleDefaultRenderModes[id_index] = entity_get_int(vehicleIds[id_index], EV_INT_rendermode);
	vehicleDefaultRenderAmts[id_index] = entity_get_float(vehicleIds[id_index], EV_FL_renderamt);

	//server_print("Map defaults  %s - height %f / origin %f / speed %f", vehicleNames[id_index], vehicleDefaultHeights[id_index], vehicleDefaultOrigins[id_index], vehicleDefaultSpeeds[id_index])
}

get_configfile(file[], len) {
	new map[36];
	get_mapname(map, 35);
	get_configsdir(file, len);
	format(file[strlen(file)], len - strlen(file), FILE_DOMCFG, map);
	return file_exists(file);
}


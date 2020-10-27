#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich> 
#include <fun>

#define FILE_DOMCFG "/advanced_func_vehicle/%s.cfg"

const m_iHeight = 37;
const m_iSpeed = 38;

new explosion, explosion1, smoke, white, rocketsmoke;
new bool:CanShoot[33];
new userVehicle[33];
new userControl[33];

new vehiclesSpawned;
new vehicleIds[64];
new Float:LastShootTime[64];

//config
new vehicleNames[64][32];
new vehicleWeaponTypes[64][32];
new vehicleTypes[64][32];
new vehicleHPs[64];
new vehicleWPN1_X[64];
new vehicleWPN1_Y[64];
new vehicleWPN1_Z[64];

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

	RegisterHam(Ham_Use, "func_vehicle", "FuncVehicle_OnUse", 0);
	RegisterHam(Ham_OnControls, "func_vehicle", "FuncVehicle_OnControls", 1);

	register_logevent("round_start", 2, "1=Round_Start");
	register_forward(FM_CmdStart, "forward_cmdstart");
	register_forward(FM_PlayerPreThink, "forward_playerprethink");

	vehiclesSpawned = 0;
	load_config();
	return PLUGIN_CONTINUE;
}

public pfn_spawn(ent) {
	if (!is_valid_ent(ent)) {
        return PLUGIN_CONTINUE;
	}

	static sz_classname[33];
	entity_get_string(ent, EV_SZ_classname, sz_classname, charsmax(sz_classname));

	if (equal(sz_classname, "func_vehicle")) {
		server_print("spawned func vehicle %d %d", ent, vehiclesSpawned);
		vehicleIds[vehiclesSpawned] = ent;
		vehiclesSpawned++;
	}
	return PLUGIN_CONTINUE;
}

public round_start() {
	new index = 0;

	while (index < 63) {
		new burn_task_id = 8397 + index;
		if (task_exists(burn_task_id)) {
			remove_task(burn_task_id);
		}

		vehicleCurrentHPs[index] = vehicleHPs[index];

		if  (is_valid_ent(vehicleIds[index]) && strlen(vehicleNames[index]) > 0) {
			set_pev(vehicleIds[index], pev_basevelocity, {0.0, 0.0, 0.0}); //drift reset

			new Float:vVehicleOrigin[3];
			entity_get_vector(vehicleIds[index], EV_VEC_origin, vVehicleOrigin);
			server_print("func vehicle origin 1 %f", vVehicleOrigin[2]);
			vVehicleOrigin[2] = vehicleDefaultOrigins[index];
			entity_set_origin(vehicleIds[index], vVehicleOrigin);
			server_print("func vehicle origin 2 %f", vVehicleOrigin[2]);

			new Float:vehicle_height = vehicleDefaultHeights[index];
			server_print("set default for %d %f", vehicleIds[index], vehicle_height);
			set_pdata_float(vehicleIds[index], m_iHeight, vehicle_height, 4);
			set_pdata_float(vehicleIds[index], m_iSpeed, vehicleDefaultSpeeds[index], 4);

			//set_rendering( vehicleIds[index], kRenderFxNone , 255, 255, 255, kRenderNormal, 16);
			entity_set_vector(vehicleIds[index], EV_VEC_rendercolor, vehicleDefaultRenderColors[index]);
			entity_set_int(vehicleIds[index], EV_INT_rendermode, vehicleDefaultRenderModes[index]);
			entity_set_float(vehicleIds[index], EV_FL_renderamt, vehicleDefaultRenderAmts[index]);
		}
		index++;
	}
}

public burn_vehicle(args[]) {
	if  (is_valid_ent(args[0])) { // vehicle_id
		new Float:vVehicleOrigin[3];
		entity_get_vector(args[0], EV_VEC_origin, vVehicleOrigin);

		entity_get_vector(args[0], EV_VEC_origin, vVehicleOrigin);	
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_SMOKE);
		write_coord(floatround(vVehicleOrigin[0]));
		write_coord(floatround(vVehicleOrigin[1]));
		write_coord(floatround(vVehicleOrigin[2]));
		write_short(smoke);
		write_byte(125);
		write_byte(5);
		message_end();
	}
}

public FuncVehicle_OnUse(iVehicle, id) {
	new vIndex = -1;
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
	userVehicle[id] = iVehicle;
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
	if (is_user_alive(id) && cs_get_user_driving(id) > 0) {
		new Button = get_uc(uc_handle, UC_Buttons);
		new OldButtons = pev(id, pev_oldbuttons);
		new fired_weapon = false;

		//get vehicle weapon type
		new targetname[32];
		new vIndex = -1;
		entity_get_string(userVehicle[id],EV_SZ_targetname,targetname,31);
		new index;
		while (index < 63) {
			if(strcmp(targetname,vehicleNames[index]) == 0) {
				vIndex = index;
				break;
			}
			index++;
		}

		if (vIndex < 0) {
			return PLUGIN_CONTINUE;
		}
		if (vehicleCurrentHPs[vIndex] <= 0) {
			return PLUGIN_CONTINUE;
		}

		new vWeapon[32];
		if (vIndex >= 0) {
			copy(vWeapon, 31, vehicleWeaponTypes[vIndex]);
		}

		new vType[32];
		if (vIndex >= 0) {
			copy(vType, 31, vehicleTypes[vIndex]);
		}

		// DRIFTING
		if (strcmp(vType, "CAR_RWD") == 0 && (OldButtons & IN_FORWARD)) {
			if ((Button & IN_MOVELEFT) && (OldButtons & IN_MOVELEFT)) {
				new Float:vector[3];
				entity_get_vector(userVehicle[id], EV_VEC_angles, vector);
				engfunc(EngFunc_MakeVectors, vector);
				new Float:v_right[3];
				get_global_vector(GL_v_right, v_right);
				entity_get_vector(userVehicle[id], EV_VEC_velocity, vector);
				if (vector[2] == 0.0) {
					new Float:force = floatdiv(vector_length(vector), 4.0);
					vector[0] = v_right[0] * force;
					vector[1] = v_right[1] * force;
					set_pev(userVehicle[id], pev_basevelocity, vector);
				}
				return PLUGIN_HANDLED;
			}
			if ((Button & IN_MOVERIGHT) && (OldButtons & IN_MOVERIGHT)) {
				new Float:vector[3];
				entity_get_vector(userVehicle[id], EV_VEC_angles, vector);
				engfunc(EngFunc_MakeVectors, vector);
				new Float:v_right[3];
				get_global_vector(GL_v_right,v_right);
				entity_get_vector(userVehicle[id], EV_VEC_velocity, vector);
				if (vector[2] == 0.0) {
					new Float:force = floatdiv(vector_length(vector),4.0) * -1.0;
					vector[0] = v_right[0] * force;
					vector[1] = v_right[1] * force;
					set_pev(userVehicle[id], pev_basevelocity, vector);
				}
				return PLUGIN_HANDLED;
			}
		}

		// RIGHT CLICK
		if((Button & IN_ATTACK2) && !(OldButtons & IN_ATTACK2)) {
			// Player presses right click
			if(strcmp(vWeapon,"SHELL_HEAT") == 0 || strcmp(vWeapon,"SHELL_AP") == 0 || strcmp(vWeapon,"SHELL_HE") == 0) {
				if (checkVehicleAngle(id) && checkDelay(id, vIndex)) {
					client_print(id, print_chat, "[AFV] Firing %s", vWeapon);

					new weaponClass[16];
					if(strcmp(vWeapon,"SHELL_HEAT") == 0) {
						weaponClass = "afv_shell_heat";
					} else if(strcmp(vWeapon,"SHELL_AP") == 0) {
						weaponClass = "afv_shell_ap";
					} else if (strcmp(vWeapon,"SHELL_HE") == 0) {
						weaponClass = "afv_shell_he";
					}
					fireShell(id, vIndex, weaponClass);
					fired_weapon = true;
				}
			}
			else if(strcmp(vWeapon,"CONC_CANNON") == 0) {
				if (checkVehicleAngle(id) && checkDelay(id, vIndex)) {
					client_print(id, print_chat, "[AFV] Firing %s", vWeapon);
					fireConcCannon(id, vIndex);
					fired_weapon = true;
				}
			}
			else if(strcmp(vWeapon, "HORN") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 3.0) {
					emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/car_horn.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
					fired_weapon = true;
				}
			}
			else if(strcmp(vWeapon,"TRUCK_HORN") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 10.0) {
					emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/truck_horn.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
					fired_weapon = true;
				}
			}
			else if(strcmp(vWeapon,"SHIP_HORN") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 15.0) {
					emit_sound(id, CHAN_ITEM, "advanced_func_vehicle/ship_horn.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
					fired_weapon = true;
				}
			}
			else if (strcmp(vWeapon, "NOS") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 10.0) {
					new Float:speed = vehicleDefaultSpeeds[vIndex];
					speed = floatadd(speed, floatmul(floatdiv(vehicleDefaultSpeeds[vIndex],100.0), 40.0));
					set_pdata_float(userVehicle[id], m_iSpeed, speed, 4);

					new args[1];
					args[0] = vIndex;
					set_task(3.0, "turnOffNOS", 0, args, 1);
					fired_weapon = true;
				}
			} else if (strcmp(vWeapon, "GUIDED_MISSILE") == 0) {
				if (checkVehicleAngle(id) && checkDelay(id, vIndex)) {
					client_print(id, print_chat, "[AFV] Firing %s", vWeapon);
					fireGuidedMissile(id, vIndex);
					fired_weapon = true;
				}
			}
			else {
				// do nothing
			}
		}

		if ((Button & IN_ATTACK2) && (OldButtons & IN_ATTACK2) && checkVehicleAngle(id)) {

			if (strcmp(vWeapon,"LMG1") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 0.1) {
					fireShot(id, vIndex, "afv_lmg1");
					fired_weapon = true;
				}
			} else if (strcmp(vWeapon,"HMG1") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 0.2) {
					fireShot(id, vIndex, "afv_hmg1");
					fired_weapon = true;
				}
			} else if (strcmp(vWeapon,"AUTO_CANNON") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 0.8) {
					//client_print(id, print_chat, "[AFV] Firing %s", vWeapon);
					//fire_auto_cannon(id, vIndex);
					fireShot(id, vIndex, "afv_auto_cannon");
					fired_weapon = true
				}
			} else if (strcmp(vWeapon,"MINIGUN") == 0) {
				if (get_gametime() > LastShootTime[vIndex] + 0.05) {
					fireShot(id, vIndex, "afv_minigun");
					fired_weapon = true;
				}
			}
		}

		if (fired_weapon) {
			LastShootTime[vIndex] = get_gametime();
		}

		// VTOL
		if (strcmp(vehicleTypes[vIndex],"HELI") != 0 && strcmp(vehicleTypes[vIndex],"VTOL") != 0) {
			return PLUGIN_CONTINUE;
		}
		else if ((Button & IN_ATTACK) && (OldButtons & IN_ATTACK)) {

			new Float:vVehicleVelocity[3];
			entity_get_vector( userVehicle[id], EV_VEC_velocity, vVehicleVelocity);
			vVehicleVelocity[2] = 100.0;
			entity_set_vector(userVehicle[id], EV_VEC_velocity, vVehicleVelocity);

			// new height logic
			new Float:vVehicleOrigin[3];
			new Float:vDefaultVehicleOrigin;
			entity_get_vector(userVehicle[id], EV_VEC_origin, vVehicleOrigin);
			vDefaultVehicleOrigin = vehicleDefaultOrigins[vIndex];

			if (vVehicleOrigin[2] > vDefaultVehicleOrigin) { // height should be higher than default;
				new Float:origin_difference = floatsub(vVehicleOrigin[2], vDefaultVehicleOrigin);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatadd(default_vehicle_height, origin_difference), 4);
				//server_print("set height up for %d %f", userVehicle[id], floatadd(default_vehicle_height, origin_difference));
			}
			else if(vVehicleOrigin[2] < vDefaultVehicleOrigin) {
				new Float:origin_difference = floatsub(vDefaultVehicleOrigin, vVehicleOrigin[2]);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatsub(default_vehicle_height, origin_difference), 4);
				//server_print("set height down for %d %f", userVehicle[id], floatsub(default_vehicle_height, origin_difference));
			}

			Button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, Button);

			return PLUGIN_HANDLED;
		}
		else if ((Button & IN_DUCK) && (OldButtons & IN_DUCK)) {

			new Float:vVehicleVelocity[3];
			entity_get_vector( userVehicle[id], EV_VEC_velocity, vVehicleVelocity);
			vVehicleVelocity[2] = -100.0;
			entity_set_vector(userVehicle[id], EV_VEC_velocity, vVehicleVelocity);

			// new height logic
			new Float:vVehicleOrigin[3];
			new Float:vDefaultVehicleOrigin;
			entity_get_vector(userVehicle[id], EV_VEC_origin, vVehicleOrigin);
			vDefaultVehicleOrigin = vehicleDefaultOrigins[vIndex];

			if (vVehicleOrigin[2] > vDefaultVehicleOrigin) { // height should be higher than default
				new Float:origin_difference = floatsub(vVehicleOrigin[2], vDefaultVehicleOrigin);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatadd(default_vehicle_height,origin_difference), 4);
				//server_print("set height up for %d %f", userVehicle[id], floatadd(default_vehicle_height,origin_difference));
			}
			else if(vVehicleOrigin[2] < vDefaultVehicleOrigin) {
				new Float:origin_difference = floatsub(vDefaultVehicleOrigin, vVehicleOrigin[2]);
				new Float:default_vehicle_height = vehicleDefaultHeights[vIndex];
				set_pdata_float(userVehicle[id], m_iHeight, floatsub(default_vehicle_height,origin_difference), 4);
				//server_print("set height down for %d %f", userVehicle[id], floatsub(default_vehicle_height,origin_difference));
			}

			Button &= ~IN_DUCK;
			set_uc(uc_handle, UC_Buttons, Button);

			return PLUGIN_HANDLED;
		}
		else {
			new Float:vVehicleVelocity[3];
			entity_get_vector( userVehicle[id], EV_VEC_velocity, vVehicleVelocity);
			vVehicleVelocity[2] = 0.0;
			entity_set_vector(userVehicle[id], EV_VEC_velocity, vVehicleVelocity);
		}
	}
	return PLUGIN_CONTINUE;
}

public turnOffNOS(args[]) {
	if  (is_valid_ent(vehicleIds[args[0]])) {
		set_pdata_float(vehicleIds[args[0]], m_iSpeed, vehicleDefaultSpeeds[args[0]], 4);
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

public checkDelay(id, vIndex) {
	if (get_gametime() < LastShootTime[vIndex] + 10.0) {
  		client_print(id,print_chat, "[AFV] Try again in %d seconds.",floatround( LastShootTime[vIndex] + 10.0 - get_gametime()+ 1));
		return false;
	} else {
		return true;
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

public damage_vehicle(vehicle_id, weaponClass[]) {
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

	if (vehicleCurrentHPs[vIndex] <= 0) {
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

	damage = floatround(floatmul(float(damage), damageMultipler), floatround_ceil);

	if (damage < vehicleCurrentHPs[vIndex]) {
		vehicleCurrentHPs[vIndex] = vehicleCurrentHPs[vIndex] - damage;
	} else {
		vehicleCurrentHPs[vIndex] = 0;

		// explosion
		new Float:EndOrigin[3];
		entity_get_vector(vehicle_id, EV_VEC_origin, EndOrigin);

		emit_sound(vehicle_id, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);
		emit_sound(vehicle_id, CHAN_VOICE, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // explosion sprite
		write_byte(TE_SPRITE);
		write_coord(floatround(EndOrigin[0]));
		write_coord(floatround(EndOrigin[1]));
		write_coord(floatround(EndOrigin[2]) + 64);
		write_short(explosion);
		write_byte(40); //scale
		write_byte(240);
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // Blast wave
		write_byte(21); // TE_BEAMCYLINDER
		write_coord(floatround(EndOrigin[0]));
		write_coord(floatround(EndOrigin[1]));
		write_coord(floatround(EndOrigin[2]));
		write_coord(floatround(EndOrigin[0]));
		write_coord(floatround(EndOrigin[1]));
		write_coord(floatround(EndOrigin[2]) + 320);
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

public fireShell(id, vIndex, weaponClass[]) {
	CanShoot[id] = false;

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_X[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_Y[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_Z[vIndex]); // up
	//get_offset_origin(userVehicle[id], firedOffset, firedOrigin);
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord(floatround(firedOrigin[0]));
	write_coord(floatround(firedOrigin[1]));
	write_coord(floatround(firedOrigin[2]));
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

	entity_set_int(RocketEnt, EV_INT_solid, 2);
	entity_set_int(RocketEnt, EV_INT_movetype, 5);
	entity_set_edict(RocketEnt, EV_ENT_owner, id);

	new Float:Velocity[3];
	VelocityByAim(id, 3000, Velocity); // 1800-3000
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

	CanShoot[id] = false;

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_X[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_Y[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_Z[vIndex]); // up
	//get_offset_origin(userVehicle[id], firedOffset, firedOrigin);
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	write_coord(floatround(firedOrigin[0]));
	write_coord(floatround(firedOrigin[1]));
	write_coord(floatround(firedOrigin[2]));
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
	CanShoot[id] = false;

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_X[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_Y[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_Z[vIndex]); // up
	//get_offset_origin(userVehicle[id], firedOffset, firedOrigin);
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	write_coord(floatround(firedOrigin[0]));
	write_coord(floatround(firedOrigin[1]));
	write_coord(floatround(firedOrigin[2]));
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

public pfn_touch(ptr, ptd) {

	new ClassName[32];
	if ((ptr > 0) && is_valid_ent(ptr)) {
		entity_get_string(ptr, EV_SZ_classname, ClassName, 31);
	}

	if (strfind(ClassName, "afv_") != -1) {
		if (equal(ClassName, "afv_shell_ap") || equal(ClassName, "afv_shell_heat") || equal(ClassName, "afv_shell_he") || equal(ClassName, "afv_conc_cannon") || equal(ClassName, "afv_guided_missile")) {

			remove_task(ptr);

			new Float:EndOrigin[3];
			entity_get_vector(ptr, EV_VEC_origin, EndOrigin);

			emit_sound(ptr, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(ptr, CHAN_VOICE, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);  // explosion sprite
			write_byte(TE_SPRITE);
			write_coord(floatround(EndOrigin[0]));
			write_coord(floatround(EndOrigin[1]));
			write_coord(floatround(EndOrigin[2]) + 128);
			write_short(explosion);
			write_byte(30);
			write_byte(255);
			message_end();

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY); // smoke
			write_byte(TE_SMOKE);
			write_coord(floatround(EndOrigin[0]));
			write_coord(floatround(EndOrigin[1]));
			write_coord(floatround(EndOrigin[2]) + 256);
			write_short(smoke);
			write_byte(125);
			write_byte(5);
			message_end();

			new maxdamage = 90; // 90-400 infantry dmg only
			new damageradius = 200;
			if (equal(ClassName, "afv_shell_heat")) {
				damageradius = 300;
			} else if (equal(ClassName, "afv_shell_he")) {
				damageradius = 400;
			}

			new PlayerPos[3], distance, damage;
			for (new i = 1; i < 32; i++) {
				if (is_user_alive(i) == 1) {
					get_user_origin(i, PlayerPos);

					new NonFloatEndOrigin[3];
					NonFloatEndOrigin[0] = floatround(EndOrigin[0]);
					NonFloatEndOrigin[1] = floatround(EndOrigin[1]);
					NonFloatEndOrigin[2] = floatround(EndOrigin[2]);

					distance = get_distance(PlayerPos, NonFloatEndOrigin);
					if (distance <= damageradius) {  // damage radius
						message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i);  // shake
						write_short(1<<14);
						write_short(1<<14);
						write_short(1<<14);
						message_end();

						damage = maxdamage - floatround(floatmul(float(maxdamage), floatdiv(float(distance), float(damageradius))))
						new attacker = entity_get_edict(ptr, EV_ENT_owner);

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
									write_string(ClassName);
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
										write_string(ClassName);
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
											//client_print(attacker, print_center, "You injured a teammate!");
										}
										else {
											set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
											user_kill(i, 1);
											set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

											message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg")); // Kill log in the top right
											write_byte(attacker); // Attacker
											write_byte(i); // Victim
											write_byte(0); // Headshot
											write_string(ClassName);
											message_end();

											set_user_frags(attacker, get_user_frags(attacker) - 1);
											//client_print(attacker, print_center, "You killed a teammate!");
										}
									}
								}
							}
						}
					}
				}
			}

			// vehicle hit
			if  (is_valid_ent(ptd)) {
				new sz_classname[33];
				entity_get_string(ptd, EV_SZ_classname, sz_classname, charsmax(sz_classname));

				if (equal(sz_classname, "func_vehicle")) {
					damage_vehicle(ptd, ClassName);
				}
			}

			if (equal(ClassName, "afv_guided_missile")) {
				attach_view(entity_get_edict(ptr, EV_ENT_owner), entity_get_edict(ptr, EV_ENT_owner));
				userControl[entity_get_edict(ptr, EV_ENT_owner)] = 0;
			}

			remove_entity(ptr);
		}
	}
}

/* vehicle bullets */
stock Float:fpev(_index, _value)
{
	static Float:fl;
	pev(_index, _value, fl);
	return fl;
}

stock fireShot(id, vIndex, weaponClass[]) {
	new damage = 1; // also minigun
	new shotSound[32];
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

	new Float:firedOrigin[3], Float:firedOffset[3];
	firedOffset[0] = float(vehicleWPN1_X[vIndex]); // forwards
	firedOffset[1] = float(vehicleWPN1_Y[vIndex]); // side
	firedOffset[2] = float(vehicleWPN1_Z[vIndex]); // up
	//get_offset_origin(userVehicle[id], firedOffset, firedOrigin);
	get_position(userVehicle[id], firedOffset[0], firedOffset[1], firedOffset[2], firedOrigin);

	playerAngle[0] *= -1.0;
	angle_vector(playerAngle, ANGLEVECTOR_FORWARD, vecDirShooting);

	//FIRE
	emit_sound(userVehicle[id], CHAN_WEAPON, shotSound, 0.6, ATTN_NORM, 0, PITCH_NORM);
	//set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_MUZZLEFLASH);

	static tr, Float:vecEnd[3], pHit, Float:vecEndPos[3];
	tr = create_tr2();
	vecEnd[0] = firedOrigin[0] + (vecDirShooting[0] + random_float(-0.025, 0.025)) * 8192.0;
	vecEnd[1] = firedOrigin[1] + (vecDirShooting[1] + random_float(-0.025, 0.025)) * 8192.0;
	vecEnd[2] = firedOrigin[2] + (vecDirShooting[2] + random_float(-0.025, 0.025)) * 8192.0;

	new Float:distance = get_distance_f(firedOrigin, vecEnd);
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
			damage_vehicle(pHit, weaponClass);
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

	tracer(firedOrigin, vecEndPos);
	gunshot(vecEndPos, pHit);
	free_tr2(tr);
	return true;
}

tracer(Float:startF[3], Float:endF[3]) {
	new start[3], end[3];
	FVecIVec(startF, start);
	FVecIVec(endF, end);
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); //  MSG_PAS MSG_BROADCAST
	write_byte(TE_TRACER);
	write_coord(start[0]);
	write_coord(start[1]);
	write_coord(start[2]);
	write_coord(end[0]);
	write_coord(end[1]);
	write_coord(end[2]);
	message_end();
}

gunshot(Float:originF[3], hit) {
	if (!pev_valid(hit)) {
		hit = 0;
	}
	if (!ExecuteHam(Ham_IsBSPModel, hit)) {
		return;
	}
	new origin[3];
	FVecIVec(originF,origin);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_GUNSHOT);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	message_end();
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

				new id_index;
				while(id_index < 63) {
					new targetname[32];
					entity_get_string(vehicleIds[id_index],EV_SZ_targetname,targetname,31)
					if (strcmp(targetname,vehicle_name) == 0) {
						copy(vehicleNames[id_index], 31, vehicle_name)
						copy(vehicleTypes[id_index], 31, vehicle_type)
						copy(vehicleWeaponTypes[id_index], 31, vehicle_wpn)

						vehicleHPs[id_index] = str_to_num(vehicle_hp);
						vehicleWPN1_X[id_index] = str_to_num(vehicle_wpn1_x);
						vehicleWPN1_Y[id_index] = str_to_num(vehicle_wpn1_y);
						vehicleWPN1_Z[id_index] = str_to_num(vehicle_wpn1_z);

						server_print("Loaded: %s - %s - %d - %s - %d - %d - %d", vehicleNames[id_index], vehicleTypes[id_index], vehicleHPs[id_index], vehicleWeaponTypes[id_index], vehicleWPN1_X[id_index], vehicleWPN1_Y[id_index], vehicleWPN1_Z[id_index])

						if  (is_valid_ent(vehicleIds[id_index])) {
							drop_to_floor(vehicleIds[id_index]); // quick fix for some BROKEN maps
							new args[1]
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

	new Float:vehicle_height = get_pdata_float(vehicleIds[id_index], m_iHeight, 4);
	vehicleDefaultHeights[id_index] = vehicle_height;

	new Float:vVehicleOrigin[3];
	entity_get_vector(vehicleIds[id_index], EV_VEC_origin, vVehicleOrigin)
	vehicleDefaultOrigins[id_index] = vVehicleOrigin[2];

	new Float:vVehicleSpeed = get_pdata_float(vehicleIds[id_index], m_iSpeed, 4);
	vehicleDefaultSpeeds[id_index] = vVehicleSpeed;

	// colors for darkening
	new Float:renderColor[3];
	entity_get_vector(vehicleIds[id_index], EV_VEC_rendercolor, renderColor);
	vehicleDefaultRenderColors[id_index] = renderColor;

	vehicleDefaultRenderModes[id_index] = entity_get_int(vehicleIds[id_index], EV_INT_rendermode);
	vehicleDefaultRenderAmts[id_index] = entity_get_float(vehicleIds[id_index], EV_FL_renderamt);

	server_print("Map defaults  %s - height %f / origin %f / speed %f", 
		vehicleNames[id_index], vehicleDefaultHeights[id_index], vehicleDefaultOrigins[id_index], vehicleDefaultSpeeds[id_index])
}

get_configfile(file[], len) {
	new map[36];
	get_mapname(map, 35);
	get_configsdir(file, len);
	format(file[strlen(file)], len - strlen(file), FILE_DOMCFG, map);
	return file_exists(file);
}

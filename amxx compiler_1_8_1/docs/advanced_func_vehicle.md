## Advanced Func Vehicle
With this plugin, vehicles will be able to get abilities not available to them previously, such as speed boost, horns, drift and vertical movement (for choppers), and shooting (choppers - `LMG1`, tanks - `canon`).

### Instalation
A short description of how to configure the plugin
1. [Download it.](https://github.com/Retroyers/advanced_func_vehicle)
2. Put all files according to the folder they are placed in.

### Configuration 

* Increase boost `speed` of the cars


      speed = 40.0 -> 1000.0

* Vertical speed of the choppers. Change up speed - `100` or down seed `-100`.

      vVehicleVelocity[2] = 100 -> 2000

* Drifting

      force 4.0 -> 0.4

* Cooldowns, change the value after `LastShootTime[vIndex] + ` in seconds.

      strcmp(vWeapon, "HORN")
      strcmp(vWeapon, "TRUCK_HORN")
      strcmp(vWeapon, "SHIP_HORN")
      strcmp(vWeapon, "NOS")
      checkDelay - method is for the canon tanks shooting cooldown

* Tank HP - edit the `1200` value. (300 + 30%) is one shoot, so `400` is 2 shots and `800` for 3 to destroy a vehicle.

      "tank1" "TANK" "1200" "SHELL_AP" "-230.0" "1.0" "48.0"


### Usage

* In Chopper go up with `mouse1` or down with `ctrl`, also `mouse2` on small choppers will shoot a machine gun.
* In cars `mouse2` depend on which car you are you will have **horn** or **speed boost**.
* In tanks `mouse2` to shoot the cannon and destroy other vehicles.
* In some cars also you will have the drift.

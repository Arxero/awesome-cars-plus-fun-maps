## Advanced Func Vehicle
With this plugin vehicles will be able to get abilities not avaiable to them previously, such as speed boost, horns, drift and vertical movement (for choppers) and shooting (choppers - `minigun`, tanks - `canon`).

### Instalation
A short description on how to confgure the plugin
1. [Download it.](https://github.com/Retroyers/advanced_func_vehicle)
2. Put all files according to the folder they are placed in.

### Configuration 

* Increase boost `speed` of the cars


      speed = 40.0 -> 400.0

* Vertical speed of the choppers. Change up speed - `100` or down seed `-100`.

      vVehicleVelocity[2] = 100 -> 1000

* Driftting

      force 4.0 -> 0.4

* Cooldowns, change the value after `LastShootTime[vIndex] + ` in seconds.

      strcmp(vWeapon, "HORN")
      strcmp(vWeapon, "TRUCK_HORN")
      strcmp(vWeapon, "SHIP_HORN")
      strcmp(vWeapon, "NOS")
      checkDelay - method is for the canon tanks shooting cooldown


### Usage

* In Chopper go up with `ctrl + mouse1` or down  with `ctrl + mouse2`, also `mouse2` on small choppers will shoot machine gun.
* In cars `mouse2` depend on which car you are you will have **horn** or **speed boost**.
* In tanks `mouse2` to shoot the cannon and destroy other vehicles.
* In some cars also you will have drift.

## Advanced Func Vehicle

A short description on how to confgure the plugin

### Instalation
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
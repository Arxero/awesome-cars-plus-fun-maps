![logo](https://i.imgur.com/mnAusIC.png)

# awesome-cars-plus-fun-maps
This is the Awesome Cars + Fun Maps as you see it today, I am sharing it with the world cause I do realize that one day it will not exist anymore and it would be a shame if all that effort spend in making it to be lost forever.

Visit our links
* [Forum](http://awesomecs.epizy.com/)
* [Old Forum](https://www.tapatalk.com/groups/awesomecs/)
* [Forum topic about this repo](http://awesomecs.epizy.com/viewtopic.php?f=2&t=1504)
* [Timeline](https://awesomecars-timeline.netlify.com/)
* [Wiki](https://awesomecars-wiki.netlify.com/)
* [Discord](https://discord.gg/aVUVup9)
* [Steam Group](https://steamcommunity.com/groups/awesomecars)
* [Facebook](https://www.facebook.com/awesomecarscs/)
* [YouTube](https://www.youtube.com/watch?v=8Mf8ZUnfMkA&list=PLRjQLmPQzOiHFQB0HW6FeURc_UH9UajA4)
* [Radio](https://zeno.fm/syntrwave/)
* [ac.gamewaver.com:27017](steam://connect/ac.gamewaver.com:27017)

[![Join us!](https://i.imgur.com/guPatOw.png)](steam://connect/ac.gamewaver.com:27017)


[![gametracker.com](https://cache.gametracker.com/server_info/ac.gamewaver.com:27017/b_560_95_1.png)](https://www.gametracker.com/server_info/ac.gamewaver.com:27017/)

[![gametracker.rs](https://banners.gametracker.rs/ac.gamewaver.com:27017/small/blue/banner.jpg)](https://www.gametracker.rs/server_info/ac.gamewaver.com:27017)

## Switch to Christmas Theme
You need to change those files to enable it:

### Plugins
[plugins.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/plugins.ini)
Go to [this line](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/7785c5a1ff57b610bafe34369d43eaddd3c2619a/cstrike/addons/amxmodx/configs/plugins.ini#L145) and uncomment all lines till [here](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/7785c5a1ff57b610bafe34369d43eaddd3c2619a/cstrike/addons/amxmodx/configs/plugins.ini#L156).

    present.amxx
    winter_environment.amxx
    crx_snow.amxx
    alt_end_round_sounds(beta).amxx
    ChristmasTree.amxx
    rainysnowy.amxx
    ny_snow.amxx
    we_player_models_ext.amxx ; comment models_menu.amxx for this to work 
    we_christmas_lights.amxx
    we_grenades.amxx
  
also comment 

    models_menu.amxx
    cso_emotion_v23.amxx
    TreeSpawner.amxx
    present_halloween.amxx
    death_ghost_halloween.amxx

### Maps
Edit [mapcycle.txt](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/mapcycle.txt) Just uncomment xmas maps in the bottom.

    cs_whiteXmas
    de_christmas
    xmas_crazytank
    xmas_lodge
    xmas_nipperhouse
    x-mas_tree

Do the same for [maps.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/maps.ini).

### Sounds
Edit [roundsound.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/roundsound.ini) just uncomment xmas sounds and comment the normal ones.

### Knife Models
Edit [KnifeModels.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/KnifeModels.ini) just uncomment xmas knifes and comment the normal ones.

### Weapon Models and Player skins

Edit [weapons_by_ThePro.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/weapons_by_ThePro.ini) and [models.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/models.ini) to accomodate for the christmas changes, just like in for sounds and knife config files.

## Switch to Halloween Theme
Enable these plugins in [plugins.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/plugins.ini)

    TreeSpawner.amxx
    present_halloween.amxx
    death_ghost_halloween.amxx ; comment death_ghost.amxx - only used model is different

Also uncomment those maps from `mapcycle.txt`

    blahhhh
    cs_evilcrazy
    cs_horror2
    de_halloween_night
    cs_rhs22

Do the same for [maps.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/maps.ini).



### Sounds
Edit [roundsound.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/roundsound.ini) just uncomment halloween sounds and comment the normal ones.

### Knife Models
Edit [KnifeModels.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/KnifeModels.ini) just uncomment halloween knifes and comment the normal ones.

### Weapon Models and Player skins

Edit [weapons_by_ThePro.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/weapons_by_ThePro.ini) and [models.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/models.ini) to accomodate for the halloween changes, just like in for sounds and knife config files.

Optinally you can edit [user_models.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/user_models.ini) for default vip/admins player skins so they don't have to select it every new map.

### Spooky Fog

For better spooky atmosphere you can use these commands in the console

    amx_fog 1 "0 0 0" 1 - Would make a black fog which you can hardly see.
    amx_fog 1 0 0 - Would use the default values for the fog.
    amx_fog 0 0 0 - Would turn the fog off.
    amx_fog 1 "116 137 147" 9 - Would make a realistic gray fog and it would be really hard to see anything.
    amx_fog 1 "0 0 200" 3 - Would make a cool blue fog.

## Make Admins and VIPs
Edit [users.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/users.ini), there are already added so you should be just fine following what is written in it.


After that edit [ap_prefixes.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/ap_prefixes.ini) to add them the right prefix.

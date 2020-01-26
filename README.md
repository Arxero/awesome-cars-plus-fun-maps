![logo](https://i.imgur.com/mnAusIC.png)

# awesome-cars-plus-fun-maps
This is the Awesome Cars + Fun Maps as you see it today, I am sharing it with the world cause I do realize that one day it will not exist anymore and it would be a shame if all that effort spend in making it to be lost forever.

Visit our links
* [Forum](https://awesomecs.syntrwave.com/)
* [Old Forum](https://www.tapatalk.com/groups/awesomecs/)
* [Forum topic about this repo](https://awesomecs.syntrwave.com/viewtopic.php?f=2&t=1504)
* [Timeline](https://awesomecars-timeline.netlify.com/)
* [Wiki](https://awesomecars-wiki.netlify.com/)
* [Discord](https://discord.gg/aVUVup9)
* [Steam Group](https://steamcommunity.com/groups/awesomecars)
* [Facebook](https://www.facebook.com/awesomecarscs/)
* [YouTube](https://www.youtube.com/watch?v=8Mf8ZUnfMkA&list=PLRjQLmPQzOiHFQB0HW6FeURc_UH9UajA4)
* [93.123.18.81:27017](steam://connect/93.123.18.81:27017)

[![Join us!](https://i.imgur.com/guPatOw.png)](steam://connect/93.123.18.81:27017)


[![gametracker.com](https://cache.gametracker.com/server_info/93.123.18.81:27017/b_560_95_1.png)](https://www.gametracker.com/server_info/93.123.18.81:27017/)

[![gametracker.rs](https://banners.gametracker.rs/93.123.18.81:27017/small/blue/banner.jpg)](https://www.gametracker.rs/server_info/93.123.18.81:27017)

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

## Make Admins and VIPs
Edit [users.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/users.ini), there are already added so you should be just fine following what is written in it.

After that edit [ap_prefixes.ini](https://github.com/Arxero/awesome-cars-plus-fun-maps/blob/master/cstrike/addons/amxmodx/configs/ap_prefixes.ini) to add them the right prefix.

# Knife Arena: Resource Audit

Plugin resources marked ✅ are present in the local server tree; unchecked plugin entries remain unverified and may be supplied by the base game. The map sections retain the dependencies that were missing before the four maps below were removed locally, for reference if those maps are added again.

## Missing for the plugins ([`unified_melee.amxx`], [`unified_ranged.amxx`])

### Models (`.mdl`)

- ✅ `cstrike/models/v_foot.mdl` (`unified_melee.amxx`)
- ✅ `cstrike/models/ZombieKick.mdl` (`unified_melee.amxx`)
- ✅ `cstrike/models/w_knifepack.mdl` (`unified_ranged.amxx`)

### Sprites (`.spr`)

- ✅ `cstrike/sprites/knife_glow.spr` (`unified_melee.amxx`)
- ✅ `cstrike/sprites/claws_glow.spr` (`unified_melee.amxx`)
- ✅ `cstrike/sprites/bat_glow.spr` (`unified_melee.amxx`)
- ✅ `cstrike/sprites/axe_glow.spr` (`unified_melee.amxx`)
- ✅ `cstrike/sprites/hvy_cooldown.spr` (`unified_melee.amxx`)
- `cstrike/sprites/glow.spr` (`unified_melee.amxx`; may be supplied by the base game)
- `cstrike/sprites/spark1.spr` (`unified_melee.amxx`; may be supplied by the base game)

### Sounds (`.wav`)

- ✅ `cstrike/sound/parry.wav` (`unified_melee.amxx`)
- ✅ `cstrike/sound/parry_miss.wav` (`unified_melee.amxx`)

## Map dependencies that were missing (maps removed locally)

### `ka_100x100`

Skybox textures (`.tga`):

- `cstrike/gfx/env/avantiup.tga`
- `cstrike/gfx/env/avantidn.tga`
- `cstrike/gfx/env/avantilf.tga`
- `cstrike/gfx/env/avantirt.tga`
- `cstrike/gfx/env/avantift.tga`
- `cstrike/gfx/env/avantibk.tga`

### `ka_dust_coliseum`

Skybox textures (`.tga`):

- `cstrike/gfx/env/fodesbk.tga`
- `cstrike/gfx/env/fodesdn.tga`
- `cstrike/gfx/env/fodesft.tga`
- `cstrike/gfx/env/fodeslf.tga`
- `cstrike/gfx/env/fodesrt.tga`
- `cstrike/gfx/env/fodesup.tga`

### `ka_moonlight_cso`

Skybox textures (`.tga`):

- `cstrike/gfx/env/Moonbk.tga`
- `cstrike/gfx/env/Moondn.tga`
- `cstrike/gfx/env/Moonft.tga`
- `cstrike/gfx/env/Moonlf.tga`
- `cstrike/gfx/env/Moonrt.tga`
- `cstrike/gfx/env/Moonup.tga`

Map thumbnails (`.tga`):

- `cstrike/gfx/thumbnails/maps/ka_moonlight_cso.tga`
- `cstrike/gfx/thumbnails/maps_wide/ka_moonlight_cso.tga`

Map overview files (`.bmp`, `.txt`):

- `cstrike/overviews/ka_moonlight_cso.bmp`
- `cstrike/overviews/ka_moonlight_cso.txt`

### `ka_ganton_gym`

Texture archives (`.wad`) referenced by `ka_ganton_gym.bsp`:

- `cstrike/developer.wad`
- `cstrike/czde_airstrip.wad`

## Decision / Solution

### Plugin Missing Files

The 10 plugin resources marked ✅ above (three models, five sprites, and two sounds) were found in the Desktop `cstrike` folder and copied to the matching paths in the local server `cstrike` tree. Their destinations were absent before copying, and the copied files were verified against the Desktop originals. `glow.spr` and `spark1.spr` were not part of this copy; they remain listed as possible base-game assets and have not been verified here.

### Map: `ka_100x100`

Removed locally: `maps/ka_100x100.bsp`, `.res`, and `.txt`, plus the 14 `sound/ambience/100*.wav` files listed only by this map's resource list. Its six skybox textures were already absent. No shared assets were removed.

### Map: `ka_dust_coliseum`

Removed locally: `maps/ka_dust_coliseum.bsp`, `.res`, and `.txt`, plus the seven `models/Xeroni/*.mdl` files listed only by this map's resource list. Its six skybox textures were already absent. No shared assets were removed.

### Map: `ka_moonlight_cso`

Removed locally: `maps/ka_moonlight_cso.bsp`, `.nav`, `.res`, `.txt`, and `_detail.txt`; `csoka_moonlight.wad`; and the five ambience sounds listed only by this map's resource list. Its skyboxes, thumbnails, and overview files were already absent. No shared assets were removed.

### Map: `ka_ganton_gym`

Removed locally: `maps/ka_ganton_gym.bsp`. Its required `developer.wad` and `czde_airstrip.wad` files were already absent, and no other Ganton Gym-specific files were found locally.

## Removed Files Confirmed Unreferenced

No references to these exact paths were found in the available plugin sources, configs, map resource lists, or installed AMXX plugin binaries. These files were removed locally. The similarly named `cstrike/models/knife_arena/v_claws.mdl` is a separate file referenced by `unified_melee.sma` and was preserved.

### Models (`.mdl`)

- `cstrike/models/Hangman/gallow.mdl`
- `cstrike/models/p_thompson_n.mdl`
- `cstrike/models/v_thompson_n.mdl`
- `cstrike/models/w_thompson_n.mdl`
- `cstrike/models/v_axe.mdl`
- `cstrike/models/v_bat.mdl`
- `cstrike/models/v_claws.mdl`

### Sounds (`.wav`)

- `cstrike/sound/Hangman/Kyrie.wav`
- `cstrike/sound/Hangman/kyrie_short.wav`
- `cstrike/sound/Hangman/kyrie_short2.wav`

### Sprites (`.spr`)

- `cstrike/sprites/axe.spr`
- `cstrike/sprites/bat.spr`
- `cstrike/sprites/claws.spr`
- `cstrike/sprites/knife.spr`

### Decision / Solution

Deleted the files listed above after checking for references.

## Friend's Knife Arena Plugin Recommendations

The Discord screenshot recommends disabling parachute, RTD, parkour, VIP-related extras and knife skins, automatic grenades, and runes. It also says to keep player models and suggests leaving the ghost plugin enabled. This section records how that advice maps to the current local plugin configuration; it is an analysis only, and no plugins were disabled as part of this review.

| Recommendation | Matching plugin(s) and current local status | Analysis |
| --- | --- | --- |
| Disable parachute; keep fall damage | `amx_parachute.amxx` is enabled globally in `plugins.ini`. | Disable the parachute plugin. Check the Knife Arena Hammer ability separately if fall damage must always apply: `unified_melee.sma` has an ability that can negate fall damage on landing. `fallscream_v03.amxx` only adds a scream sound; it is not a fall-damage plugin. |
| Disable RTD | `dice_main.amxx` is enabled globally; `roll_the_dice.amxx` is already commented out. | `dice_main.amxx` is the active RTD-related entry to review/disable. |
| Disable parkour | `parkour.amxx` is enabled globally in `plugins.ini`. | Disable it to remove the extra movement mechanics. |
| Disable VIP-related extras and knife skins, but keep player models | `amxxbg_vip_plugin.amxx`, `crx_knife_models.amxx`, and `crx_fast_knife.amxx` are enabled globally. `vip_exstras.amxx` and `teamknifes.amxx` are already commented out. `models_menu.amxx` is enabled. | Review/disable the active VIP and custom-knife plugins. Keep `models_menu.amxx` for player models. Keep `unified_melee.amxx` and `unified_ranged.amxx` in the Knife Arena map plugin list; they implement the mod's core abilities, not merely cosmetic knife skins. |
| Disable automatic grenades at round start | `amxxbg_vip_plugin.amxx` is enabled and its source grants VIP grenades on spawn. `road_rage.amxx` is also enabled and grants grenades during its Road Rage mode. | Disabling the VIP plugin addresses its spawn grenades. Disable `road_rage.amxx` only if the recommendation also intends to remove grenades supplied by that separate game mode. |
| Disable runes | The Runemod base, control, and active rune modules are enabled in `plugins.ini`. | Disable the active Runemod entries/modules as a group. |
| Leave the ghost plugin enabled | `death_ghost.amxx` is enabled globally; seasonal ghost variants are commented out. | This matches the follow-up message saying the ghost plugin should remain enabled. |

Plugin status above refers to the local configuration files inspected for this review, not a live-server check. Confirm the exact intended scope of “VIP related” and “auto grenades” before changing configs, since those labels can cover separate features/plugins.


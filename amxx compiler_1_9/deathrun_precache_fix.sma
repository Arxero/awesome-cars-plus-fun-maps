#include <amxmodx>
#include <fakemeta>

#define PLUGIN "UnPrecacher"
#define VERSION "1.0"
#define AUTHOR "ConnorMcLeod  "
/*
new UnprecacheList[][48] =
{
	"shield",
	"ambience/3dmbridge.wav",
	"ambience/3dmeagle.wav",
	"ambience/3dmstart.wav",
	"ambience/3dmthrill.wav",
	"ambience/alarm1.wav",
	"ambience/arabmusic.wav",
	"ambience/Birds1.wav",
	"ambience/Birds2.wav",
	"ambience/Birds3.wav",
	"ambience/Birds4.wav",
	"ambience/Birds5.wav",
	"ambience/Birds6.wav",
	"ambience/Birds7.wav",
	"ambience/Birds8.wav",
	"ambience/Birds9.wav",
	"ambience/car1.wav",
	"ambience/car2.wav",
	"ambience/cat1.wav",
	"ambience/chimes.wav",
	"ambience/cicada3.wav",
	"ambience/copter.wav",
	"ambience/cow.wav",
	"ambience/crow.wav",
	"ambience/dog1.wav",
	"ambience/dog2.wav",
	"ambience/dog3.wav",
	"ambience/dog4.wav",
	"ambience/dog5.wav",
	"ambience/dog6.wav",
	"ambience/dog7.wav",
	"ambience/doorbell.wav",
	"ambience/fallscream.wav",
	"ambience/guit1.wav",
	"ambience/kajika.wav",
	"ambience/lv1.wav",
	"ambience/lv2.wav",
	"ambience/lv3.wav",
	"ambience/lv4.wav",
	"ambience/lv5.wav",
	"ambience/lv6.wav",
	"ambience/lv_elvis.wav",
	"ambience/lv_fruit1.wav",
	"ambience/lv_fruit2.wav",
	"ambience/lv_fruitwin.wav",
	"ambience/lv_jubilee.wav",
	"ambience/lv_neon.wav",
	"ambience/Opera.wav",
	"ambience/rain.wav",
	"ambience/ratchant.wav",
	"ambience/rd_shipshorn.wav",
	"ambience/rd_waves.wav",
	"ambience/sheep.wav",
	"ambience/sparrow.wav",
	"ambience/thunder_clap.wav",
	"ambience/waterrun.wav",
	"ambience/wolfhowl01.wav",
	"ambience/wolfhowl02.wav",
	"de_torn/tk_steam.wav",
	"de_torn/tk_windStreet.wav",
	"de_torn/torn_AK-47.wav",
	"de_torn/torn_ambience.wav",
	"de_torn/torn_Bomb1.wav",
	"de_torn/torn_Bomb2.wav",
	"de_torn/torn_MGun1.wav",
	"de_torn/torn_Templewind.wav",
	"de_torn/torn_thndrstrike.wav",
	"de_torn/torn_water1.wav",
	"de_torn/torn_water2.wav",
	"events/enemy_died.wav",
	"events/friend_died.wav",
	"events/task_complete.wav",
	"events/tutor_msg.wav",
	"hostage/hos1.wav",
	"hostage/hos2.wav",
	"hostage/hos3.wav",
	"hostage/hos4.wav",
	"hostage/hos5.wav",
	"items/equip_nvg.wav",
	"items/kevlar.wav",
	"items/nvg_off.wav",
	"items/nvg_on.wav",
	"items/tr_kevlar.wav",
	"radio",
	"storm/thunder-theme.wav",
	"weapons/ak47-1.wav",
	"weapons/ak47-2.wav",
	"weapons/ak47_boltpull.wav",
	"weapons/ak47_clipin.wav",
	"weapons/ak47_clipout.wav",
	"weapons/aug-1.wav",
	"weapons/aug_boltpull.wav",
	"weapons/aug_boltslap.wav",
	"weapons/aug_clipin.wav",
	"weapons/aug_clipout.wav",
	"weapons/aug_forearm.wav",
	"weapons/awp1.wav",
	"weapons/awp_clipin.wav",
	"weapons/awp_clipout.wav",
	"weapons/awp_deploy.wav",
	"weapons/boltdown.wav",
	"weapons/boltpull1.wav",
	"weapons/boltup.wav",
	"weapons/c4_beep1.wav",
	"weapons/c4_beep2.wav",
	"weapons/c4_beep3.wav",
	"weapons/c4_beep4.wav",
	"weapons/c4_beep5.wav",
	"weapons/c4_click.wav",
	"weapons/c4_disarm.wav",
	"weapons/c4_disarmed.wav",
	"weapons/c4_explode1.wav",
	"weapons/c4_plant.wav",
	"weapons/clipin1.wav",
	"weapons/clipout1.wav",
	"weapons/de_clipin.wav",
	"weapons/de_clipout.wav",
	"weapons/de_deploy.wav",
	"weapons/deagle-1.wav",
	"weapons/deagle-2.wav",
	"weapons/elite_clipout.wav",
	"weapons/elite_deploy.wav",
	"weapons/elite_fire.wav",
	"weapons/elite_leftclipin.wav",
	"weapons/elite_reloadstart.wav",
	"weapons/elite_rightclipin.wav",
	"weapons/elite_sliderelease.wav",
	"weapons/elite_twirl.wav",
	"weapons/famas-1.wav",
	"weapons/famas-2.wav",
	"weapons/famas-burst.wav",
	"weapons/famas_boltpull.wav",
	"weapons/famas_boltslap.wav",
	"weapons/famas_clipin.wav",
	"weapons/famas_clipout.wav",
	"weapons/famas_forearm.wav",
	"weapons/fiveseven-1.wav",
	"weapons/fiveseven_clipin.wav",
	"weapons/fiveseven_clipout.wav",
	"weapons/fiveseven_slidepull.wav",
	"weapons/fiveseven_sliderelease.wav",
	"weapons/flashbang-1.wav",
	"weapons/flashbang-2.wav",
	"weapons/g3sg1-1.wav",
	"weapons/g3sg1_clipin.wav",
	"weapons/g3sg1_clipout.wav",
	"weapons/g3sg1_slide.wav",
	"weapons/galil-1.wav",
	"weapons/galil-2.wav",
	"weapons/galil_boltpull.wav",
	"weapons/galil_clipin.wav",
	"weapons/galil_clipout.wav",
	"weapons/generic_reload.wav",
	"weapons/generic_shot_reload.wav",
	"weapons/glock18-1.wav",
	"weapons/glock18-2.wav",
	"weapons/he_bounce-1.wav",
	"weapons/headshot2.wav",
	"weapons/hegrenade-1.wav",
	"weapons/hegrenade-2.wav",
	"weapons/m3-1.wav",
	"weapons/m3_insertshell.wav",
	"weapons/m3_pump.wav",
	"weapons/m4a1-1.wav",
	"weapons/m4a1_boltpull.wav",
	"weapons/m4a1_clipin.wav",
	"weapons/m4a1_clipout.wav",
	"weapons/m4a1_deploy.wav",
	"weapons/m4a1_silencer_off.wav",
	"weapons/m4a1_silencer_on.wav",
	"weapons/m4a1_unsil-1.wav",
	"weapons/m4a1_unsil-2.wav",
	"weapons/m249-1.wav",
	"weapons/m249-2.wav",
	"weapons/m249_boxin.wav",
	"weapons/m249_boxout.wav",
	"weapons/m249_chain.wav",
	"weapons/m249_coverdown.wav",
	"weapons/m249_coverup.wav",
	"weapons/mac10-1.wav",
	"weapons/mac10_boltpull.wav",
	"weapons/mac10_clipin.wav",
	"weapons/mac10_clipout.wav",
	"weapons/mp5-1.wav",
	"weapons/mp5-2.wav",
	"weapons/mp5_clipin.wav",
	"weapons/mp5_clipout.wav",
	"weapons/mp5_slideback.wav",
	"weapons/p90-1.wav",
	"weapons/p90_boltpull.wav",
	"weapons/p90_clipin.wav",
	"weapons/p90_clipout.wav",
	"weapons/p90_cliprelease.wav",
	"weapons/p228-1.wav",
	"weapons/p228_clipin.wav",
	"weapons/p228_clipout.wav",
	"weapons/p228_slidepull.wav",
	"weapons/p228_sliderelease.wav",
	"weapons/pinpull.wav",
	"weapons/ric_conc-1.wav",
	"weapons/ric_conc-2.wav",
	"weapons/ric_metal-1.wav",
	"weapons/ric_metal-2.wav",
	"weapons/scout_bolt.wav",
	"weapons/scout_clipin.wav",
	"weapons/scout_clipout.wav",
	"weapons/scout_fire-1.wav",
	"weapons/sg550-1.wav",
	"weapons/sg550_boltpull.wav",
	"weapons/sg550_clipin.wav",
	"weapons/sg550_clipout.wav",
	"weapons/sg552-1.wav",
	"weapons/sg552-2.wav",
	"weapons/sg552_boltpull.wav",
	"weapons/sg552_clipin.wav",
	"weapons/sg552_clipout.wav",
	"weapons/sg_explode.wav",
	"weapons/slideback1.wav",
	"weapons/sliderelease1.wav",
	"weapons/tmp-1.wav",
	"weapons/tmp-2.wav",
	"weapons/ump45-1.wav",
	"weapons/ump45_boltslap.wav",
	"weapons/ump45_clipin.wav",
	"weapons/ump45_clipout.wav",
	"weapons/usp1.wav",
	"weapons/usp2.wav",
	"weapons/usp_clipin.wav",
	"weapons/usp_clipout.wav",
	"weapons/usp_silencer_off.wav",
	"weapons/usp_silencer_on.wav",
	"weapons/usp_slideback.wav",
	"weapons/usp_sliderelease.wav",
	"weapons/usp_unsil-1.wav",
	"weapons/xm1014-1.wav"
}*/

new const UnprecacheModelList[][] =
{
	"models/w_antidote.mdl",
	"models/w_security.mdl",
	"models/w_longjump.mdl",
	"sprites/zerogxplode.spr",
	"sprites/WXplo1.spr",
	"sprites/steam1.spr",
	"sprites/bubble.spr",
	"sprites/bloodspray.spr",
	"sprites/blood.spr",
	"sprites/eexplo.spr",
	"sprites/fexplo.spr",
	"sprites/fexplo1.spr",
	"sprites/b-tele1.spr",
	"sprites/c-tele1.spr",
	"sprites/ledglow.spr",
	"sprites/laserdot.spr",
	"sprites/explode1.spr",
	"models/v_c4.mdl",
	"models/p_c4.mdl",
	"models/w_c4.mdl",
	"hostage",
	"models/bag.mdl",
	"models/bigtree.mdl",
	"models/fern.mdl",
	"models/grass.mdl",
	"models/lv_bottle.mdl",
	"models/orange.mdl",
	"models/pallet_with_bags.mdl",
	"models/pallet_with_bags2.mdl",
	"models/palmtree.mdl",
	"models/PG-150.mdl",
	"models/pshell.mdl",
	"models/rshell.mdl",
	"models/rshell_big.mdl",
	"models/player/guerilla",
	"models/player/sas",
	"models/player/gign",
	"models/player/vip",
	"models/player/leet"
}

new Unprecache, iModels, iSounds, iPModels, iPSounds, iPGenerics

public plugin_init() 
{
	register_plugin( PLUGIN, VERSION, AUTHOR )
	log_amx("Unprecached %i Models and %i Sounds", iModels, iSounds)
	log_amx("Precached Models: %i | Sounds: %i | Generic: %i", iPModels, iPSounds, iPGenerics)
}

public plugin_precache()
{
	//register_forward(FM_PrecacheSound, "fw_PrecacheSound")
	register_forward(FM_PrecacheModel, "fw_PrecacheModel")
	register_forward(FM_PrecacheGeneric, "fw_PrecacheGeneric")
}

public fw_PrecacheGeneric(szGeneric[])
{
	iPGenerics++
}

public fw_PrecacheModel(szModel[])
{
	Unprecache = 0
	
	for (new i = 0; i < sizeof(UnprecacheModelList); i++)
	{
		if (contain(szModel, UnprecacheModelList[i]) != -1)
		{
			Unprecache = 1
			iModels++
			break
		}
	}
	
	if (Unprecache)
	{
		return FMRES_SUPERCEDE
	}
	
	iPModels++
	
	return FMRES_IGNORED
}
/*
public fw_PrecacheSound( const Sound[] )
{
	Unprecache = 0

	for( new i = 0; i < sizeof( UnprecacheList ); i++ )
	{
		if( contain(Sound, UnprecacheList[i]) != -1 )
		{
			Unprecache = 1
			iSounds++
			break
		}
	}
	
	if( Unprecache ) 
	{
		return FMRES_SUPERCEDE
	}
	
	iPSounds++
	
	return FMRES_IGNORED
}
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/

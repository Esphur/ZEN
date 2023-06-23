#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

runDvars()
{
    game["strings"]["change_class"] = undefined; //Removes Class Change Text
    level.pers["meters"] = 10; //Meters required to kill.
    level.pers["almost_hit_sens"] = 2; //Almost hit sensitivity.
    level setClientDvar( "g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
    level setClientDvar( "g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    setDvarIfUninitialized( "class_change", 1 ); //Enables/Disabled Mid-Game CC
    setDvarIfUninitialized( "first_blood", 0 ); //Enables/Disabled First Blood
    setDvar( "safeArea_adjusted_horizontal", 0.85 );
    setDvar( "safeArea_adjusted_vertical", 0.85 );
    setDvar( "safeArea_horizontal", 0.85 );
    setDvar( "safeArea_vertical", 0.85 );
    setDvar( "scr_sd_multibomb", "1" );
    setDvar( "ui_streamFriendly", true );
    setDvar( "jump_slowdownEnable", 0 ); //Removes Jump Fatigue
    setDvar( "bg_surfacePenetration", 9999 ); //Wallbang Everything
    setDvar( "bg_bulletRange", 99999 ); //No Bullet Trail Limit
    setDvar( "sv_allowAimAssist", 1 ); //Aim Assist Enable/Disable
    setDvar( "bg_bounces", 2 ); //Allow Double Bouncing
    setDvar( "bg_elevators", 2 ); //Allow EZ Elevators
    setDvar( "bg_rocketJump", 1 ); //Allow Rocket Jumps
    setDvar( "bg_bouncesAllAngles", 1 ); //Allow Multi Bouncing
    setDvar( "bg_playerEjection", 0 ); //Removes Collision
    setDvar( "bg_playerCollision", 0 ); //Removes Ejection
    setDvar( "cg_newcolors", 0 );
    setDvar( "intro", 0 );
    setDvar( "cl_autorecord", 0 );
    setDvar( "snd_enable3D" , 1 );
    setDvar( "bg_fallDamageMaxHeight", 300 );
    setDvar( "bg_fallDamageMinHeight", 128 );
    setDvar( "scr_sd_timelimit", 2.5 ); //Stops unlimited time..
    setDvar( "cg_overheadnamessize", 0.80 );
    setDvar( "g_knockback", 1 );
	setDvar( "bg_surfacePenetration", 128 );
	setDvar( "player_sprintUnlimited", true );
	setDvar( "bg_viewKickMin", 2 );
	setDvar( "bg_viewKickMax", 10 );
	setDvar( "bg_viewKickRandom", 0.4 );
	setDvar( "bg_viewKickScale", 0.15 );
    setDvar( "bots_play_move", true );
    setDvar( "bots_play_fire", true );
    setDvar( "bots_play_take_carepackages", false );
    setDvar( "dbarriers", 1 );
    setDvar( "mantle_check_angle", 180 );
    setDvar( "mantle_view_yawcap", 180 );
    setDvar( "player_lean_rotate_right", 3 );
    setDvar( "player_lean_rotate_left", 3 );
    setDvar( "player_lean_shift_left", 20 );
    setDvar( "player_lean_shift_right", 20 );
    setDvar( "jump_ladderpushvel", 128 );
    setDvar( "jump_height", 39 );
    setDvar( "g_gravity", 800 );
    setDvar( "bg_shock_movement", 0 );
    setDvar( "player_backSpeedScale", 0.7 );
    setDvar( "player_useRadius", 128 );
    setDvar( "g_speed", 190 );
    setDvar( "sv_padpackets", 5000 );
    setDvarIfUninitialized( "eb_range", 0 );


}
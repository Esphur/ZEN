#include common_scripts\utility;
#include common_scripts\iw4x_utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;
getRandomHitloc()
{
	hitloc = [];
	hitloc[hitloc.size] = "j_hip_ri:right_leg_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_hip_le:left_leg_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_knee_ri:right_leg_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_spineupper:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_spinelower:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_mainroot:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_knee_le:left_leg_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_ankle_ri:right_foot:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_ankle_le:left_foot:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_clavicle_ri:torso_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_clavicle_le:torso_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_shoulder_ri:right_arm_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_shoulder_le:left_arm_upper:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_neck:neck:MOD_HEAD_SHOT:flesh_head";
	hitloc[hitloc.size] = "j_head:head:MOD_HEAD_SHOT:flesh_head";
	hitloc[hitloc.size] = "j_elbow_ri:right_arm_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_elbow_le:left_arm_lower:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_wrist_ri:right_hand:MOD_RIFLE_BULLET:flesh_body";
	hitloc[hitloc.size] = "j_wrist_le:left_hand:MOD_RIFLE_BULLET:flesh_body";

	return strTok( hitloc[ randomInt( hitloc.size ) ], ":" );
}

explosiveBullets()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	range = 1000; // make this a client adjustable variable

	for ( ;; )
	{
		self waittill( "weapon_fired", weapon );

		if ( !self redux\common::isAtLast() && level.gametype == "dm" )
			continue;

		if ( getWeaponClass( weapon ) != "weapon_sniper" )
			continue;

		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];

		foreach ( victim in level.players )
		{
			if ( !isAlive( victim ) )
				continue;

			if ( maps\mp\gametypes\_damage::isFriendlyFire( victim, self ) || victim == self )
				continue;

			if ( distance( destination, victim getOrigin() ) > range )
				continue;

			hitloc = getRandomHitloc();
			tag = victim getTagOrigin( hitloc[0] );
			mod = hitloc[2];
			fx = hitloc[3];
			offset_time = self getPing() * 4;

			victim thread [[level.callbackPlayerDamage]]( self, self, victim.health * 2, level.iDFLAGS_PENETRATION, mod, weapon, tag, tag, hitloc[1], offset_time );
			playFXOnTag( getFX( fx ), victim, tag );
		}
	}
}


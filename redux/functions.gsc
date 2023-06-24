#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;

illusion()
{
    self setSpawnWeapon(self getCurrentWeapon());
}

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
    

	range = getDvarInt( "eb_range" ); // handled by eb slider, still needs callback

	for ( ;; )
	{
		self waittill( "weapon_fired", weapon );

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

godMode()
{
    self endon( "disconnect" );
    self endon( "death" );

    self.health=self.maxhealth;

    if ( !self.pers["god_mode"] )
    {
        self.pers["god_mode"] = true;
        self.maxhealth = 900000;
    }
    else
    {
        self.pers["god_mode"] = false;
        self.maxhealth = 150;
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "God Mode: " + boolToText( self.pers["god_mode"] ) );
}

altSwapSave()
{
    self.pers["savedweapon"] = self getCurrentWeapon();
    self iPrintLnBold( "Alt Swap Saved: " + ( self.pers["savedweapon"] ) );
    wait 2;
    self iPrintLnBold( "Please change class and use the alt swap toggle." );
    wait 5;
}

altSwap()
{
    if ( !self.pers["altswap"] )
    {
        self.pers["altswap"] = true;
        self giveWeapon( self.pers["savedweapon"] );
    }
    else
    {
        self.pers["altswap"] = false;
        self takeWeapon( self.pers["savedweapon"] );
    }
    if ( self.pers["bool_text"] )
    {
        self iPrintLnBold( "Alt Swap: " + boolToText(self.pers["altswap"] ) );
        wait 2;
        self iPrintLnBold( "Alt Swap Weapon: " + ( self.pers["savedweapon"] ) );
        wait 5;
    }
}

altSwap2()
{
    {
        self giveWeapon( self.pers["savedweapon"] );
    }
}

oneManArmyAlt()
{
	self giveWeapon( "onemanarmy_mp" );
}

rightHandTk()
{
    if ( self.pers["glow_stick"] )
    {
        self iPrintLnBold( "Disable glowstick first." );
        return;
    }    
    if ( !self.pers["throwingknife_rhand_mp"] )
    {
        self.pers["throwingknife_rhand_mp"] = true;
        self takeWeapon( self GetCurrentOffhand() );
        self SetOffhandPrimaryClass( "throwingknife" );
        self giveWeapon( "usp_akimbo_xmags_mp" );
    }
    else
    {
        self.pers["throwingknife_rhand_mp"] = false;
        self takeWeapon( "usp_akimbo_xmags_mp" );
        self SetOffhandPrimaryClass( "other" );
        self maps\mp\perks\_perks::givePerk( maps\mp\gametypes\_class::cac_getPerk( self.class_num, 0 ) );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Right hand TK: " + boolToText( self.pers["throwingknife_rhand_mp"] ) );
}

giveGlowstick()
{
    if ( self.pers["throwingknife_rhand_mp"] )
    {
        self iPrintLnBold( "Disable right-hand throwing knife first." );
        return;
    } 
    if ( !self.pers["glow_stick"] )
    {
        self.pers["glow_stick"] = true;
        self takeWeapon( self GetCurrentOffhand() );
        self SetOffhandPrimaryClass( "other" );
        self giveWeapon( "usp_akimbo_silencer_mp" );
    }
    else
    {
        self.pers["glow_stick"] = false;
        self takeWeapon( "usp_akimbo_silencer_mp" );
        self SetOffhandPrimaryClass( "other" );
        self maps\mp\perks\_perks::givePerk( maps\mp\gametypes\_class::cac_getPerk( self.class_num, 0 ) );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Glowstick: " + boolToText( self.pers["glow_stick"] ) );
}

instantProneToggle()
{
    if ( !self.pers["ez_prone"] )
    {
        self.pers["ez_prone"] = true;
        self redux\cfg::instantProneCfg();
    }
    else
    {
        self.pers["ez_prone"] = false;
        self notify( "stop_prone" );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Easy Prone: " + boolToText(self.pers["ez_prone"] ) );
}

sohWepCheck()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self waittill( "weapon_change", weapon );
        if ( self.pers["allow_soh"] )
            self maps\mp\perks\_perks::givePerk( "specialty_fastreload" ); 
        else if ( !self.pers["allow_soh"] )
            self _unsetPerk( "specialty_fastreload" );
    }
}

sohToggle()
{
    if ( !self.pers["allow_soh"] )
    {
        self.pers["allow_soh"] = true;
        self maps\mp\perks\_perks::givePerk( "specialty_fastreload" );
    }
    else
    {
        self.pers["allow_soh"] = false;
        self _unsetPerk( "specialty_fastreload" );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Fast Reload: " + boolToText(self.pers["allow_soh"] ) );
}

maraToggle()
{
    if ( !self.pers["allow_fast_mantle"] )
    {
        self.pers["allow_fast_mantle"] = true;
        self maps\mp\perks\_perks::givePerk( "specialty_fastmantle" );
    }
    else
    {
        self.pers["allow_fast_mantle"] = false;
        self _unsetPerk( "specialty_fastmantle" );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Fast Mantle: " + boolToText(self.pers["allow_fast_mantle"] ) );

}

ufoMode()
{
    if ( !self.pers["allow_ufo"] ) 
    {
        self thread ufoMode2();
        self.pers["allow_ufo"] = true;  
        self disableweapons();
        self.owp=self getWeaponsListOffhands();
        foreach( w in self.owp )
        self takeweapon( w );
    } 
    else 
    { 
        self.pers["allow_ufo"] = false;
        self notify( "noclipoff" );
        self unlink();
        self enableweapons();
        foreach( w in self.owp )
        self giveweapon( w );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "UFO Mode: " + boolToText( self.pers["allow_ufo"] ) );
}

ufoMode2()
{ 
    self endon( "death" ); 
    self endon( "noclipoff" );

    if ( isdefined( self.newufo ) ) self.newufo delete(); 
        self.newufo = spawn( "script_origin", self.origin ); 
        self.newufo.origin = self.origin; 
        self playerlinkto( self.newufo );

    for( ;; )
    { 
        vec=anglestoforward( self getPlayerAngles() );
        if ( self FragButtonPressed() )
        {
            end=( vec[0]*60,vec[1]*60,vec[2]*60 );
            self.newufo.origin=self.newufo.origin+end;
        }
        else if ( self SecondaryOffhandButtonPressed() )
        {
            end=( vec[0]*10,vec[1]*10, vec[2]*10 );
            self.newufo.origin=self.newufo.origin+end;
        } 
        wait 0.05; 
    } 
}

superLadder()
{
    if ( !self.pers["allow_laddervelo"] )
    {
        self.pers["allow_laddervelo"] = true;
        setDvar( "jump_ladderPushVel",1024 );
    }
    else
    {
        self.pers["allow_laddervelo"] = false;
        setDvar( "jump_ladderPushVel",128 );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Super ladders: " + boolToText( self.pers["allow_laddervelo"] ) );
}

savePos()
{
	if ( !self isOnGround() )
	{
		self iPrintLnBold( "Can't save position here." );
		return;
	}

	self.pers["saved_position"] = spawnStruct();
	self.pers["saved_position"].origin = self getOrigin();
	self.pers["saved_position"].angles = self getPlayerAngles();

	self iPrintLnBold( "Saved position." );
}

loadPos()
{
	if ( !isDefined( self.pers["saved_position"] ) )
	{
		self iPrintLnBold( "No saved position found." );
		return;
	}

	self setOrigin( self.pers["saved_position"].origin );
	self setPlayerAngles( self.pers["saved_position"].angles );
	self iPrintLnBold( "Loaded position." );
}

forceSpawn()
{
    self setOrigin( self.pers["saved_position"].origin );
	self setPlayerAngles( self.pers["saved_position"].angles );
}

sndRoundReset()
{
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;
	game["roundsPlayed"] = 3;

	maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
	maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );

	wait .05;

	level notify( "updating_scores" );
	level endon( "updating_scores" );

	wait .05;

	self updateScores();
	self iPrintln( "Rounds Reset" );

}

ezMalaToggle()
{
    if ( !self.pers["ez_mala"] )
    {
        self.pers["ez_mala"] = true;
        self thread ezMala();
    }
    else
    {
        self.pers["ez_mala"] = false;
        self notify( "stop_ez_mala" );
    }
    if ( self.pers["bool_text"] )
        self iPrintLnBold( "EZ Mala: " + boolToText( self.pers["ez_mala"] ) );
}

ezMala()
{
    self endon( "disconnect" );
    self endon( "stop_ez_mala" );
    for ( ;; )
    {
        self waittill( "grenade_pullback", equipment );

        my_class = self.pers["class"];
        my_weapon = self getCurrentWeapon();
        old_ammo = self GetWeaponAmmoStock( my_weapon );
        old_clip = self GetWeaponAmmoClip( my_weapon );

        waitframe();

        self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], my_class );

        waitframe();

        self switchToWeapon( my_weapon );
        self SetWeaponAmmoStock( my_weapon, old_ammo );
        self SetWeaponAmmoClip( my_weapon, old_clip );

        if ( self.pers["allow_soh"] == false )
            self maps\mp\perks\_perks::givePerk( "specialty_fastreload" );
    }
}

thirdPersonToggle()
{
    if ( !self.pers["third_person"] )
    {
        self.pers["third_person"] = true;
        setDvar( "camera_thirdperson", 1 );
    }
    else
    {
        self.pers["third_person"] = false;
        setDvar( "camera_thirdperson", 0 );
    }

    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Third Person: " + boolToText( self.pers["third_person"] ) );
}

scavPack()
{
    self maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
    self playLocalSound( "scavenger_pack_pickup" );
}

dropWep()
{
	weapon = self getCurrentWeapon();

	if ( isKillstreakWeapon( weapon ) || isSubStr( weapon, "briefcase" ) )
	{
		self iPrintLn( "Can't drop this weapon." );
		return;
	}

	weapons = self getWeaponsListPrimaries();
	self dropItem( weapon );

	while ( self getCurrentWeapon() == "none" )
	{
		waitframe();
		self switchToWeapon( weapons[ randomInt( weapons.size ) ] );
	}
}

proneSpinToggle()
{
    if ( !self.pers["prone_spin"] )
    {
        self.pers["prone_spin"] = true;
        setDvar( "bg_prone_yawcap", 360 );
    }
    else
    {
        self.pers["prone_spin"] = false;
        setDvar( "bg_prone_yawcap", 85 );
    }

    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Prone Spins: " + boolToText( self.pers["prone_spin"] ) );
}

ladderSpinToggle()
{
    if ( !self.pers["ladder_spin"] )
    {
        self.pers["ladder_spin"] = true;
        setDvar( "bg_ladder_yawcap", 360 );
    }
    else
    {
        self.pers["ladder_spin"] = false;
        setDvar( "bg_ladder_yawcap", 100 );
    }

    if ( self.pers["bool_text"] )
        self iPrintLnBold( "Ladder Spins: " + boolToText( self.pers["ladder_spin"] ) );
}

oneBullet()
{
	self.nova = self getCurrentweapon();
	ammoW = self getWeaponAmmoStock( self.nova );
	ammoCW = self getWeaponAmmoClip( self.nova );
	self setweaponammostock( self.nova, ammoW );
    self setweaponammoclip( self.nova, ammoCW - 1 );
}

lastBullet()
{
	self.nova = self getCurrentweapon();
	weap = self getCurrentWeapon();
	self SetWeaponAmmoClip( weap, 1 );
}

doPredMala()
{
    Weap = self getCurrentWeapon();
    self takeWeapon( Weap );
    self GiveWeapon( "killstreak_predator_missile_mp" );
    self switchToWeapon( "killstreak_predator_missile_mp" );
    wait 0.1;
    self giveWeapon( Weap,0 );
}

doUavMala()
{
    Weap = self getCurrentWeapon();
    self takeWeapon( Weap );
    self GiveWeapon( "killstreak_uav_mp" );
    self switchToWeapon( "killstreak_uav_mp" );
    wait 0.1;
    self giveWeapon( Weap,0 );
}

doClaymoreMala()
{
    Weap = self getCurrentWeapon();
    self takeWeapon( Weap );
    self GiveWeapon( "claymore_mp" );
    self switchToWeapon( "claymore_mp" );
    wait 0.1;
    self giveWeapon( Weap,0 );
}

doBombMala()
{
    Weap = self getCurrentWeapon();
    self takeWeapon( Weap );
    self GiveWeapon( "briefcase_bomb_defuse_mp" );
    self switchToWeapon( "briefcase_bomb_defuse_mp" );
    wait 0.1;
    self giveWeapon( Weap,0 );
}





/*gFlip()
{
        my_weapon = self getCurrentweapon();
        stock = self getWeaponAmmoStock(my_weapon);
        clip = self getWeaponAmmoClip(my_weapon);
        self takeWeapon(my_weapon);
        self giveWeapon("cheytac_silencer_xmags_mp");
        self switchToWeapon("cheytac_silencer_xmags_mp");
        waitframe();
        waitframe();
        self takeWeapon("cheytac_silencer_xmags_mp");
        self giveWeapons(my_weapon);
        self setweaponammostock(my_weapon, stock);
        self setweaponammoclip(my_weapon, clip);
        self switchToWeapon(my_weapon);
}*/

/*instaswapcfg()
{
    for(;;)
    {
        self bindwait("instaswapcfg","+instaswap");
        if(self.menuopen == false)
        {
            self illusion();
            waitframe();
            self setSpawnWeapon(self getNextWeapon());
        }
    }
}*/

/*sentryCfg()
{
    setdvarifuni( "function_sentrydestroy",1 );
    for( ;; )
    {
        self notifyOnPlayerCommand( "sentrycfg", "+sentry" );
        self waittill( "sentrycfg" );
        self thread maps\mp\killstreaks\_autosentry::tryUseAutoSentry( self );
        self enableWeapons();
    }
}*/

/*sentryDest()
{
    setdvarifuni( "function_sentrydestroy",1 );
    for( ;; )
    {
        self thread maps\mp\killstreaks\_autosentry::tryUseAutoSentry( self );
        self enableWeapons();
    }
}*/

/*setclass( num )
{
	self maps\mp\gametypes\_class::setClass( "custom"+num );
	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], "custom"+num );
    self.pers["class"] = "custom"+num;
    self iPrintLn("test");
}*/
/*
bounceToggler()
{
	if(!self.bouncin)
	{
		self.bouncin = true;
		self thread BounceCreator();
		self thread DeletingB();
		self iPrintln("Bounce Creator: ^0On");
		self iPrintln("^0Crouch And Press [{+actionslot 3}] To Create Bounce");
		self iPrintln("^0Prone And Press [{+actionslot 3}] To Delete Bounce");
	}
	else
	{
		self.bouncin = false;
		self notify("stopdabouncin");
		self iPrintln("Bounce Creator: ^0Off");
	}
}

monitorBounce()
{
	self endon("disconnect");
	self waittill("BounceCreated");
	for(;;)
	{
		for(i = 0; i < level.B; i++)
		{
			if(distance(self.origin,level.BL[i]) < 70)
			{
				self thread forcePlayerBounce();
				if (self.vel[2] < 0 && self.canBounce == true) 
				{
				self SetVelocity( self.newVel );
				self.canBounce = false;
				wait .1;
				self.canBounce = true;
				}
			}
			wait 0.01;
		}
		wait 0.01;
	}
}

forcePlayerBounce()
{
	self thread dovariables();
	self thread detectVelocity();		
}

dovariables()
{
	self.vel = 0;
	self.newVel = 0;
	self.topVel = 0;
	self.canBounce = true;
}

detectVelocity()
{
	for(;;)
	{

		self.vel = self GetVelocity();

		if (!self isOnGround()) {
			self.newVel = (self.vel[0], self.vel[1], self Negate(self.vel[2]));
		}

		wait 0.001;
	}
}

Negate( vector ) // Credits go to CodJumper.
{
	self endon( "death" );
	negative = vector - (vector * 2.125);
	return( negative );
}

bounceCreator()
{
	self endon("disconnect");
	self endon("death");
	self endon("stopdabouncin");

	for(;;)
	{
		self notifyOnPlayerCommand("createbb","+actionslot 3");
	self waittill ("createbb");
		if (self GetStance() == "crouch")
		{
			self thread createBounce();
		}
	}
}

createBounce()
{
	level.BL[level.B] = self.origin;
	level.B++;
	self thread notifycreatedbounce();
	foreach(player in level.players)
		player notify("BounceCreated");
}

deletingB()
{
	self endon("disconnect");
	self endon("death");
	self endon("stopdabouncin");
	for(;;)
	{
			self notifyOnPlayerCommand("deld", "+actionslot 3");
		self waittill("deld");
		if (self GetStance() == "prone")
		{
            self DeleteAllB();
        }
	wait 0.02;
    }
}

DeleteAllB()
{
	for(i = 0; i < level.B; i++)
		level.BL[i] destroy();
	level.B = 0;
	foreach(player in level.players)
		player iprintlnBold("All Bounces Have Been ^0Deleted by: ^0" + self.name);
}

notifycreatedbounce()
{
	foreach(player in level.players)
		player iprintlnBold("A Bounce Has Been Spawned ^0On: ^0" + self.name);
}
/*


/*HostMigrationCFG() // cfg 
{
	setDvarIfUninitialized("HostMigration", "HostMigration");
	self notifyOnPlayerCommand("HostMigration", "+actionslot 1");
	setDvarIfUninitialized("HostMigrationState", "0");
	for (;;)
	{
		self waittill("HostMigration");
		setDvar("HostMigrationState", "0");
		self openPopupMenu(game["menu_hostmigration"]);
		self freezeControlsWrapper(true);
		wait 2;
		setDvar("HostMigrationState", "1");
		wait 2;
		self closePopupMenu();
		thread maps\mp\gametypes\_gamelogic::matchStartTimer("match_resuming_in", 2.0);
		wait 5;
		self freezeControlsWrapper(false);
	}
}

monitorObject(owner,name)
{
    self endon("explode");
    owner endon("disconnect");
    self iprintln("^0Throw a throwing knife closest to the bot!");
 
    nextFrame = undefined;
 
    while(true)
    {
        currentFrame = self.origin;
        waitframe();
        nextFrame = self.origin;
 
        if(distance(currentFrame,nextFrame) < 3)
            break;
    }
 
    if(!isDefined(nextFrame))
        return;
        
    foreach(player in level.players)
    {
        if(player == owner || level.teamBased && owner.pers["team"] == player.pers["team"] || !isAlive(player))
            continue;
 
        if(isDefined(player))
        {
            if (distance(player.origin , nextFrame) <= 1000) // <- range between object to player
            {
                player [[level.callbackPlayerDamage]](self, owner, 500, 0, "MOD_IMPACT",
                    name, player getTagOrigin("j_spineupper"), player getTagOrigin("j_spineupper"), "none", 0);
 
                break; //no collats
            }
        }
    }
}

shaxbar4()
{
	self endon("endbars4");
	for(;;)
	{
		self notifyonplayercommand("shaxbar4", "+actionslot 4");
		self waittill("shaxbar4");
		if(self.shax2 == false)
		{
			self.shax2 = true;
			self.shaxgun = self getcurrentWeapon();
			self setweaponammoclip(self.shaxgun, 0);
		}
		else if(self.shax2 == true)
		{
			self.shax2 = false;
			self takeweapon(self.shaxgun);
			wait 0.001;
			self thread barnigga();
			wait 3.1;
			self giveweapon(self.shaxgun);
			self setspawnweapon(self.shaxgun);
		}
	}
}
barnigga()
{
	wduration = 3.1;
	NSB = createPrimaryProgressBar( 25 );
	NSBText = createPrimaryProgressBarText( 25 );
	NSBText settext( &"MPUI_CHANGING_KIT" );
	NSB updateBar( 0, 1 / wduration );
	for ( waitedTime = 0;waitedTime < wduration && isAlive( self ) && !level.gameEnded;
	waitedTime += 0.05 )wait ( 0.05 ); //quando finisce
	NSB destroyElem();
	NSBText destroyElem();
}

laddaexp()
{
    self waittill("dpad_up");
    if(self isOnLadder())
    {
        self _enableWeapon();
        self _enableOffhandWeapons();
        self _enableWeaponSwitch();
        self _enableUsability();
        }
}

pickupradius()
{
	if ( self.yallpickup == 0 )
	{
		self.yallpickup = 1;
		self setClientDvar( "player_useRadius", "250" );
		self iPrintln("Pickup Radius: ^0250");
	}
else if ( self.yallpickup == 1 )
	{
		self.yallpickup = 2;
		self setClientDvar( "player_useRadius", "500" );
		self iPrintln("Pickup Radius: ^0500");
	}
else if ( self.yallpickup == 2 )
	{
		self.yallpickup = 3;
		self setClientDvar( "player_useRadius", "750" );
		self iPrintln("Pickup Radius: ^0750");
	}
else if ( self.yallpickup == 3 )
	{
		self.yallpickup = 4;
		self setClientDvar( "player_useRadius", "10000" );
		self iPrintln("Pickup Radius: ^01000");
	}
else if ( self.yallpickup == 4 )
	{
		self.yallpickup = 0;
		self setClientDvar( "player_useRadius", "150" );
		self iPrintln("Pickup Radius: ^0Default");
	}
}

instantoma()
{
	if(self.oma == 0)
	{
		self.oma = 1;
		self.pers["omadelay"] = 1.0;
		self iPrintln("Instant OMA Change: ^0On");
	}
	else
	{
		self.oma = 0;
		self.pers["omadelay"] = 3.0;
		self iPrintln("Instant OMA Change: ^0Off");
	}
}

yallinsta()
{    
	self iPrintln("^5Press [{+actionslot 1}] to Instaswap.");
    self endon ("disconnect");
	self endon ("StopInstaZZ");
    for(;;)
	{
		self notifyOnPlayerCommand("instaZZZ","+actionslot 1");
		self notifyOnPlayerCommand("instaZZZ","+instaswap");
		self waittill ("instaZZZ");
	
		nacmod = self getCurrentWeapon();
		
		if (nacmod == self.PrimaryWeapon)
		{
			Secondary = self.SecondaryWeapon;
			wait .05;
			self SetSpawnWeapon( secondary );
		}
		else if (nacmod == self.SecondaryWeapon)
		{
			Primary = self.PrimaryWeapon;
			wait .05;
			self SetSpawnWeapon( primary );
		}
	}
}



crosshairCp()
{
	self endon("drop_crate");
	for(;;)
	{
		self thread maps\mp\killstreaks\_airdrop::dropTheCrate( BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ] + (0,0,5), "airdrop", BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ], true, undefined, BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ] + (0,0,5) );
		self notify( "drop_crate" );
	}
	wait 0.1;
}*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;

runCfg()
{
    self thread thirdPersonCfg();
    self thread ezMalaCfg();
    self thread loadPosCfg();
    self thread savePosCfg();
	self thread ufoModeCfg();
	self thread maraCfg();
	self thread sohCfg();
    self thread instantProneCfg();
	self thread scavCfg(); 
    self thread ebCfg();
    self thread doPredMalaCfg();
    self thread doUavMalaCfg();
    self thread oneBulletCfg();
    self thread lastBulletCfg();
    self thread doClaymoreMalaCfg();
    self thread doBombMalaCfg();
    self thread toggleAirSpaceCfg();

}

thirdPersonCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "3rd", "+3rd" );
        self waittill( "3rd" );

        if( !self.pers["third_person"] )
        {
            self.pers["third_person"] = true;
            setDvar( "camera_thirdperson", 1 );
        }
        else
        {
            self.pers["third_person"] = false;
            setDvar( "camera_thirdperson", 0 );
        }
    }
}

ezMalaCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "ezMala", "+ezMala" );
        self waittill( "ezMala" );

        if( !self.pers["ez_mala"] )
        {
            self.pers["ez_mala"] = true;
            self redux\functions::ezMala();
        }
        else
        {
            self.pers["ez_mala"] = false;
            self notify( "stop_ez_mala" );
        }
    }
}

loadPosCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "load", "+load" );
        self waittill( "load" );

	    if ( !isDefined( self.pers["saved_position"] ) )
	    {
		    self iPrintLn( "No saved position found." );
		    return;
	    }

	    self setOrigin( self.pers["saved_position"].origin );
	    self setPlayerAngles( self.pers["saved_position"].angles );
    }
}

savePosCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "save", "+save" );
        self waittill( "save" );

	    if ( !self isOnGround() )
	    {
		    self iPrintLn( "Can't save position here." );
		    return;
	    }

	    self.pers["saved_position"] = spawnStruct();
	    self.pers["saved_position"].origin = self getOrigin();
	    self.pers["saved_position"].angles = self getPlayerAngles();

	    self iPrintLn( "Saved position." );
    }
}

ufoModeCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "ufo", "+ufo" );
        self waittill( "ufo" );

        if( !self.pers["allow_ufo"] ) 
        {
            self redux\functions::ufoMode2();
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
    }
}

maraCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "mara", "+mara" );
        self waittill( "mara" );

        if( !self.pers["allow_fast_mantle"] )
        {
            self.pers["allow_fast_mantle"] = true;
            self maps\mp\perks\_perks::givePerk( "specialty_fastmantle" );
        }
        else
        {
            self.pers["allow_fast_mantle"] = false;
            self _unsetPerk( "specialty_fastmantle" );
        }
    }
}

sohCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "soh", "+soh" );
        self waittill( "soh" );

        if( !self.pers["allow_soh"] )
        {
            self.pers["allow_soh"] = true;
            self maps\mp\perks\_perks::givePerk( "specialty_fastreload" );
        }
        else
        {
            self.pers["allow_soh"] = false;
            self _unsetPerk( "specialty_fastreload" );
        }
    }
}

instantProneCfg()
{
    self endon( "stop_prone" );
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "ezp", "+ezp" );
        self waittill( "ezp" );
        self setStance( "prone" );
    }
}

scavCfg()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self notifyOnPlayerCommand( "scav", "+scav" );
        self waittill( "scav" );
        {
            self maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
            self playLocalSound( "scavenger_pack_pickup" );
        }
    }
}

ebCfg()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
    

	range = 1500;// make this a client adjustable variable

	for ( ;; )
	{
        self notifyOnPLayerCommand( "eb", "+eb" );
        self waittill( "eb" );
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

			hitloc = redux\functions::getRandomHitloc();
			tag = victim getTagOrigin( hitloc[0] );
			mod = hitloc[2];
			fx = hitloc[3];
			offset_time = self getPing() * 4;

			victim thread [[level.callbackPlayerDamage]]( self, self, victim.health * 2, level.iDFLAGS_PENETRATION, mod, weapon, tag, tag, hitloc[1], offset_time );
			playFXOnTag( getFX( fx ), victim, tag );
		}
	}
}

doPredMalaCfg()
{
	self endon("+predmala");
	for(;;)
	{
		self notifyOnPlayerCommand("pmalabitch", "+predmala");
		self waittill("pmalabitch");
		{
          Weap = self getCurrentWeapon();
          self takeWeapon(Weap);
          self GiveWeapon( "killstreak_predator_missile_mp" );
          self switchToWeapon("killstreak_predator_missile_mp");
          wait 0.1;
          self giveWeapon(Weap,0);
		}
	}
}

doUavMalaCfg()
{
	self endon("+uavmala");
	for(;;)
	{
		self notifyOnPlayerCommand("uavmalabitch", "+uavmala");
		self waittill("uavmalabitch");
		{
          Weap = self getCurrentWeapon();
          self takeWeapon(Weap);
          self GiveWeapon( "killstreak_uav_mp" );
          self switchToWeapon("killstreak_uav_mp");
          wait 0.1;
          self giveWeapon(Weap,0);
		}
	}
}

doClaymoreMalaCfg()
{
	self endon("+claymala");
	for(;;)
	{
		self notifyOnPlayerCommand("claymala", "+claymala");
		self waittill("claymala");
		{
          Weap = self getCurrentWeapon();
          self takeWeapon(Weap);
          self GiveWeapon( "claymore_mp" );
          self switchToWeapon( "claymore_mp" );
          wait 0.1;
          self giveWeapon(Weap,0);
		}
	}
}

doBombMalaCfg()
{
    self endon( "disconnect" );
	for( ;; )
	{
		self notifyOnPlayerCommand( "bmalabitch", "+bombmala" );
		self waittill( "bmalabitch" );
		{
          Weap = self getCurrentWeapon();
          self takeWeapon( Weap );
          self GiveWeapon( "briefcase_bomb_defuse_mp" );
          self switchToWeapon( "briefcase_bomb_defuse_mp" );
          wait 0.1;
          self giveWeapon( Weap,0 );
		}
	}
}

 
oneBulletCfg()
{
    self endon( "disconnect" );
    for( ;; )
	{
        self notifyOnPlayerCommand( "1b", "+1b" );
        self waittill( "1b" );
		self.nova = self getCurrentweapon();
		ammoW = self getWeaponAmmoStock( self.nova );
		ammoCW = self getWeaponAmmoClip( self.nova );
		self setweaponammostock( self.nova, ammoW );
		self setweaponammoclip( self.nova, ammoCW - 1 );
	}
}

lastBulletCfg()
{
    self endon( "disconnect" );
    for( ;; )
	{
        self notifyOnPlayerCommand( "0b", "+0b" );
        self waittill( "0b" );
		self.nova = self getCurrentweapon();
		weap = self getCurrentWeapon();
		self SetWeaponAmmoClip( weap, 1 );
	}
}

rerepeat()
{
    self endon( "disconnect" );
	for( ;; )
	{
		self notifyOnPlayerCommand( "repeat", "+rerepeater" );
		self waittill( "repeat" );
		setDvar( "perk_weapReloadMultiplier", 0 );
		waitframe();
		setDvar( "perk_weapReloadMultiplier", 0.5 );
	}
}

toggleAirSpaceCfg()
{
    self endon( "disconnect" );
	for( ;; )
    {
        self notifyOnPlayerCommand( "airspace", "+airspace" );
		self waittill( "airspace" );
        if( !self.pers["airspace"] )
        {
            self.pers["airspace"] = true;
            self.littleBirds = 4;
		    self iPrintln( "Air Space Full: ^0ON" );
        }
        else
        {
            self.pers["airspace"] = false;
            self.littleBirds = 0;
		    self iPrintln( "Air Space Full: ^0OFF" );
        }
    }
}

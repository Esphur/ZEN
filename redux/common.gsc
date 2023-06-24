#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\functions;

init()
{
	if ( level.script == "oilrig" )
		thread createRamp( ( 1676, 1330, -70 ), ( 2489, 1844, 900 ) );

	level.onlineGame = true;
	level.rankedMatch = true;
	level.modifyPlayerDamage = ::modifyPlayerDamage;
	level.player_out_of_playable_area_monitor = 0;
	level.littleBirds = 4;

	level._effect["flesh_body"] = loadFX( "impacts/flesh_hit_body_fatal_exit" );
	level._effect["flesh_head"] = loadFX( "impacts/flesh_hit_head_fatal_exit" );
	
	// asset precaching
    if ( !isDefined( game["precachedAssets"] ) )
    {
        precacheMenu( "map_voting" );
        precacheMenu( "loadout" );
        precacheMenu( "loadout_select" );
        precacheMenu( "mod_options" );
        precacheMenu( "callvote" );

        precacheItem( "cheytac_irons_mp" );
        precacheItem( "ax50_mp" );
        precacheItem( "m200_mp" );
        precacheItem( "l115a3_mp" );
        precacheItem( "msr_mp" );

        game["precachedAssets"] = true;
    }

	level thread redux\voting::init();
	level thread onPlayerConnect();
	level thread redux\dvars::runDvars();

	if ( level.gametype == "sd" )
	{
		level waittill( "update_scorelimit" );
		setDvar( "ui_allow_teamchange", 0 );
		setDvar( "scr_sd_roundswitch", 0 );
	}
}

createRamp( top, bottom )
{
	blocks = ceil( ( distance( top, bottom ) ) / 30 );
	cx = top[0] - bottom[0];
	cy = top[1] - bottom[1];
	cz = top[2] - bottom[2];
	xz = cx / blocks;
	ya = cy / blocks;
	za = cz / blocks;
	angles = vectorToAngles( top - bottom );

	for ( b = 0; b < blocks; b++ )
	{
		block = spawn( "script_model", ( bottom + ( ( xz, ya, za ) * b ) ) );
		block.angles = ( angles[2], angles[1] + 90, angles[0] );
		block solid();
		block cloneBrushmodelToScriptmodel( level.airDropCrateCollision );
		waitframe();
	}

	block = spawn( "script_model", ( bottom + ( ( xz, ya, za ) * blocks ) - ( 0, 0, 5 ) ) );
	block.angles = ( angles[2], angles[1] + 90, 0 );
	block solid();
	block cloneBrushmodelToScriptmodel( level.airDropCrateCollision );
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		if ( !player isTestClient() )
		{
			if ( !isDefined( player.pers["loadout"] ) )
				player.pers["loadout"] = [];
			if ( !isDefined( player.pers["botmovement"] ) )
			    player.pers["botmovement"] = true;
			if ( !isDefined( player.pers["botaggression"] ) )
				player.pers["botaggression"] = true;
            if ( !isDefined( player.pers["botthief"] ) )
				player.pers["botthief"] = false;
			if ( !isDefined( player.pers["altswap"] ) )
				player.pers["altswap"] = false;
			if ( !isDefined( player.pers["ez_prone"] ) )
				player.pers["ez_prone"] = false;
			if ( !isDefined( player.pers["allow_soh"] ) )
				player.pers["allow_soh"] = true;
			if ( !isDefined( player.pers["allow_fast_mantle"] ) )
				player.pers["allow_fast_mantle"] = false;
			if ( !isDefined( player.pers["allow_ufo"] ) )
				player.pers["allow_ufo"] = false;
			if ( !isDefined( player.pers["allow_laddervelo"] ) )
				player.pers["allow_laddervelo"] = false;
			if ( !isDefined( player.pers["ez_mala"] ) )
				player.pers["ez_mala"] = false;
			if ( !isDefined( player.pers["third_person"] ) )
				player.pers["third_person"] = false;
			if ( !isDefined( player.pers["throwingknife_rhand_mp"] ) )
				player.pers["throwingknife_rhand_mp"] = false;
			if ( !isDefined( player.pers["glow_stick"] ) )
                player.pers["glow_stick"] = false;
			if ( !isDefined( player.pers["bool_text"] ) )
                player.pers["bool_text"] = true;
			if ( !isDefined( player.pers["god_mode"] ) )
                player.pers["god_mode"] = false;
			if ( !isDefined( player.pers["prone_spin"] ) )
                player.pers["prone_spin"] = false;
			if ( !isDefined( player.pers["ladder_spin"] ) )
                player.pers["ladder_spin"] = false;
			if ( !isDefined( player.pers["airspace"] ) )
                player.pers["airspace"] = false;

			player thread redux\commands::init();
			player thread redux\ui_callbacks::onScriptMenuResponse();

			player childthread beginAutoPlant();
			player childthread createText();
		}

		if ( level.gametype == "sd" )
			player thread onJoinedTeam();

		player thread onPlayerSpawned();
	}
}
rememberFunc()
{
    if ( self.pers["altswap"] == true )
        self thread altswap2();
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if ( !self isTestClient() )
		    self childthread sustainAmmo();
		    self childthread rememberFunc();
			self childthread zenPackText();
		    self childthread deathBarrierFix();
			self redux\cfg::runCfg();
			self redux\functions::forceSpawn();
			self redux\functions::explosiveBullets();
			self redux\functions::getRandomHitloc();

			self.hasRadar = true;
		    self.radarMode = "fast_radar";
			
		if ( self isTestClient() )
			self childthread botLogPosition();
			self redux\botFuncs::botRememberFunc();
	}
}

onJoinedTeam()
{
	self endon( "disconnect" );

    if ( self isTestClient() )
        self maps\mp\gametypes\_menus::addToTeam( "allies", true );
    else
        self maps\mp\gametypes\_menus::addToTeam( "axis", true );

	for ( ;; )
	{
		self waittill_any( "joined_team" );

		// failsafe
		if ( self isTestClient() && self.pers["team"] != "allies" )
			self [[level.allies]]();

		if ( !self isTestClient() && self.pers["team"] != "axis" )
			self [[level.axis]]();
	}
}

boolTextToggle()
{
	if ( !self.pers["bool_text"] )
	{
		self.pers["bool_text"] = true;
		self iPrintLnBold( "Toggle text has been turned on." );
	}
	else
	{
		self.pers["bool_text"] = false;
		self iPrintLn( "Toggle text has been turned off." );
	}
}

zenPackText()
{
	zen = createFontString( "consolefont", 1.2 );
    zen setPoint( "RIGHT", "CENTER", 56, 210 );
    zen setSafeText( "Press [{togglemenu}] to open Zen Pack." );
    zen fadeovertime( 1 );
}

deathBarrierFix()
{
	ents = getEntArray();
	for ( index = 0; index < ents.size; index++ )
	{
		self.fix = false;
				
		if ( isSubStr(ents[index].classname, "trigger_hurt" ) )
		{
			ents[index].origin = ( 0, 0, 10000 );
			setDvar( "dbarriers", "1" );
		}
	}
}

sustainAmmo()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill_notify_or_timeout( "reload", 10 );

		if ( !isAlive( self ) )
			continue;

		foreach ( weapon in self getWeaponsListAll() )
		{
			if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weapon ) )
				self setWeaponAmmoStock( weapon, weaponMaxAmmo( weapon ) );
			else
				self setWeaponAmmoClip( weapon, self getWeaponAmmoClip( weapon ) + 1 );
		}
	}
}

Select( eval, a, b )
{
	if ( eval )
		return a;

	return b;
}

modifyPlayerDamage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	if ( victim isTestClient() && ( !isDefined( sMeansOfDeath ) || sMeansOfDeath == "MOD_TRIGGER_HURT" ) )
	{
		victim thread botTeleportFix();
		return 0;
	}

	if ( sMeansOfDeath == "MOD_FALLING" )
		return Select( level.gametype == "sd", 0, iDamage );

	if ( isKillstreakWeapon( sWeapon ) )
		return 0;

	if ( eAttacker isTestClient() )
		return Select( victim isTestClient(), iDamage, iDamage * 0.25 );

	if ( sMeansOfDeath == "MOD_MELEE"
	        || sMeansOfDeath == "MOD_GRENADE"
	        || sMeansOfDeath == "MOD_GRENADE_SPLASH"
	        || sMeansOfDeath == "MOD_PROJECTILE"
	        || sMeansOfDeath == "MOD_PROJECTILE_SPLASH"
	        || sMeansOfDeath == "MOD_EXPLOSIVE"
	        || sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 1;

	if ( isSubStr( sWeapon, "gl_" ) && sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 99999;

	if ( isBulletDamage( sMeansOfDeath ) && getWeaponClass( sWeapon ) != "weapon_sniper" )
		iDamage = 1;

	// Mala fix
	if ( isBulletDamage( sMeansOfDeath ) && ( getWeaponClass( sWeapon ) == "weapon_grenade" || getWeaponClass( sWeapon ) == "weapon_explosive" ) )
		iDamage = 99999;

	if ( getWeaponClass( sWeapon ) == "weapon_sniper" || sWeapon == "throwingknife_mp" )
		iDamage = 99999;

	return iDamage;
}

consolePrint( head, msg )
{
	printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}

botTeleportFix()
{
	self setOrigin( self.lastOnGround + ( 0, 0, 10 ) );

	self.stop = true;
	self.bot.target = self;
	self.bot.towards_goal = undefined;
	self.bot.script_goal = undefined;

	self notify( "kill_goal" );
	self notify( "new_goal_internal" );
	self notify( "bad_path_internal" );

	wait 7;
	self.stop = undefined;
}

botLogPosition()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	if ( level.gametype == "sd" )
		self endon( "death" );

	self.lastOnGround = ( 0, 0, 0 );

	for ( ;; )
	{
		if ( self isOnGround() )
			self.lastOnGround = self.origin;

		wait 5;
	}
}

boolToText( bool )
{
    if ( bool )
        return "[^2On^7]";
    else
        return "[^1Off^7]";
}

beginAutoPlant()
{
	level endon( "game_ended" );
	level waittill( "spawned_player" );
	for ( ;; )
    {	
		if ( maps\mp\gametypes\_gamelogic::getTimeRemaining() < 5010 )
        {
			thread forceBombPlant();
			return;
		}
		wait 1;
	}
}

forceBombPlant()
{	
    if ( level.bombplanted )
        return;
	
    self thread maps\mp\gametypes\_hud_message::SplashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
    level thread teamPlayerCardSplash( "callout_bombplanted", self, self.pers["team"] );
    self thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
    self.bombPlantedTime = getTime();
    maps\mp\gametypes\_gamescore::givePlayerScore( "plant", self );	
    self playSound( "mp_bomb_plant" );
    leaderDialog( "bomb_planted" );

    if ( cointoss() )
    {
        level thread maps\mp\gametypes\sd::bombplanted( level.bombZones[0], undefined );
        level.bombZones[1] maps\mp\gametypes\_gameobjects::disableObject();
    }
	else
	{
        level thread maps\mp\gametypes\sd::bombplanted( level.bombZones[1], undefined );
        level.bombZones[0] maps\mp\gametypes\_gameobjects::disableObject();
    }
}

createText( font, fontscale, align, relative, x, y, sort, color, alpha, glowColor, glowAlpha, text ) 
{
    textElem = createFontString( font, fontscale );
    textElem setPoint( align, relative, x, y );
    textElem.sort = sort;
    textElem.type = "text";
    textElem setSafeText( text );
    textElem.color = color;
    textElem.alpha = alpha;
    textElem.glowColor = glowColor;
    textElem.glowAlpha = glowAlpha;
    textElem.hideWhenInMenu = true;
    return textElem;
}

overflowFixInit() 
{
    level.strings = [];
    level.overflowElem = createServerFontString( "default", 1.5 );
    level.overflowElem setSafeText( "overflow" );
    level.overflowElem.alpha = 0;
    thread overflowFixMonitor();
}

overflowFixMonitor() 
{
    for ( ;; ) 
    {
        level waittill( "string_added" );
        if ( level.strings.size >= 55 ) 
        {
            level.overflowElem clearAllTextAfterHudElem();
            level.strings = [];
            level notify( "overflow_fixed" );
        }
        wait 0.05;
    }
}

setSafeText( text )
{
    self.string = text;
    self setText( text );
    self thread fixString();
    self addString( text );
}

addString( string )
{
    level.strings[level.strings.size] = string;
    level notify( "string_added" );
}

fixString() 
{
    self notify( "new_string" );
    self endon( "new_string" );
    while( isDefined( self ) ) 
    {
        level waittill( "overflow_fixed" );
        self setSafeText( self.string );
    }
}

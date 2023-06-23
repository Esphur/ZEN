#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;


init()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	_ = [];
	_["suicide"] = ::_suicide;

	_["bottele"] = redux\botfuncs::botTele;
	_["botmovement"] = redux\botfuncs::botMoveFreeze;
	_["botaggression"] = redux\botfuncs::botFires;
	_["botthief"] = redux\botfuncs::botStealsCp;

	_["dropwep"] = redux\functions::dropWep;
	_["altswap"] = redux\functions::altSwap;
	_["altswapsave"] = redux\functions::altSwapSave;
	_["omaalt"] = redux\functions::oneManArmyAlt;
	_["ezprone"] = redux\functions::instantProneToggle;
	_["sohtoggle"] = redux\functions::sohToggle;
	_["maratoggle"] = redux\functions::maraToggle;
	_["ufomode"] = redux\functions::ufoMode;
	_["savepos"] = redux\functions::savePos;
	_["superladder"] = redux\functions::superLadder;
	_["loadpos"] = redux\functions::loadPos;
	_["roundreset"] = redux\functions::sndRoundReset;
	_["ezmala"] = redux\functions::ezMalaToggle;
	_["thirdperson"] = redux\functions::thirdPersonToggle;
	_["scavpack"] = redux\functions::scavPack;
	_["glowstick"] = redux\functions::giveGlowstick;
	_["rhtk"] = redux\functions::rightHandTk;
	_["godmode"] = redux\functions::godMode;
	_["bool"] = redux\common::boolTextToggle;
	_["pronespin"] = redux\functions::proneSpinToggle;
	_["ladderspin"] = redux\functions::ladderSpinToggle;
	_["onebullet"] = redux\functions::oneBullet;
	_["lastbullet"] = redux\functions::lastBullet;
	_["predmala"] = redux\functions::doPredMala;
	_["uavmala"] = redux\functions::doUavMala;
	_["bombmala"] = redux\functions::doBombMala;
	_["claymala"] = redux\functions::doClaymoreMala;


	

	//_["bouncer"] = redux\functions::bounceToggler;
	//_["setclass"] = redux\functions::setClass;
	//_["remember"] = redux\common::rememberFunc;
	//_["sentrydest"] = redux\functions::sentryDest;
	//_["glowstick"] = redux\functions::giveGlowstick;
	//_["xhaircp"] = redux\functions::crosshairCp;

	foreach ( name, func in _ )
		self childthread run( name, func );
}

run( name, func )
{
	self setClientDvar( name, "Script command" );
	self notifyOnPlayerCommand( name, name );

	for ( ;; )
	{
		self waittill( name );
		self thread [[func]]();
	}
}

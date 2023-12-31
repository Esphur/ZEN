#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;

botRememberFunc()
{
    if ( !self.pers["botmovement"] )
        setDvar( "bots_play_move", false );
    if ( self.pers["botmovement"] )
        setDvar( "bots_play_move", true );
    if ( self.pers["botaggression"] )
        setDvar( "bots_play_fire", false );
    if ( !self.pers["botaggression"] )
        setDvar( "bots_play_fire", true );
    if ( self.pers["botthief"] )
        setDvar( "bots_play_take_carepackages", true );
    if ( !self.pers["botthief"] )
        setDvar( "bots_play_take_carepackages", false );

    self childthread botForceSpawn();  
}

botTele()
{
    self.pers["bot_origin"] = self getOrigin();
    self.pers["bot_angles"] = self getplayerangles();
    waitframe();
    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ) )
        {
            level.players[i] setOrigin( self.pers["bot_origin"] );
            level.players[i] setPlayerAngles( self.pers["bot_angles"] );
        }

        if ( self.pers["botaggression"] )
            self childthread botFires();
        if ( self.pers["botmovement"] )    
            self childthread botMoveFreeze();       
    }
    self iPrintLnBold( "Bots Position: [^1Saved^7]" );
}

botForceSpawn()
{
    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ) )
        {
            level.players[i] setOrigin( self.pers["bot_origin"] );
            level.players[i] setPlayerAngles( self.pers["bot_angles"] );
        }
    }
}

botMoveFreeze()
{
    if ( self.pers["botmovement"] )
    {
        self.pers["botmovement"] = false;
        setDvar( "bots_play_move", false );
        self iPrintLnBold( "Bot Frozen" );
    }
    else
    {
        self.pers["botmovement"] = true;
        setDvar( "bots_play_move", true );
        self iPrintLnBold( "Bot Unfrozen" );
    }
}

botFires()
{
    if ( self.pers["botaggression"] )
    {
        self.pers["botaggression"] = false;
        setDvar( "bots_play_fire", false );
        self iPrintLnBold( "Bot is peaceful." );
    }
    else
    {
        self.pers["botaggression"] = true;
        setDvar( "bots_play_fire", true );
        self iPrintLnBold( "Bot is aggresive." );
    }
}

botStealsCp()
{
    if ( !self.pers["botthief"] )
    {
        self.pers["botthief"] = true;
        setDvar( "bots_play_take_carepackages", true );
        self iPrintLnBold( "Bot takes CP's." );
    }
    else
    {
        self.pers["botthief"] = false;
        setDvar( "bots_play_take_carepackages", false );
        self iPrintLnBold( "Bot ignores CP's." );
    }
}


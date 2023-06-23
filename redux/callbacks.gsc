#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;

level.ebRange = registerDvar("eb_range", "1000", 0, 2000, "Explosive Bullets Range");

ebRangeCallback()
{
    range = level.ebRange getInteger();

    // Do something with the updated range value
    // You can use the new range value in your existing code to adjust the behavior based on the client's chosen range
    // For example:
    if (range > 1500)
    {
        // Adjust behavior for range greater than 1500
    }
}

level thread ebRangeCallback();

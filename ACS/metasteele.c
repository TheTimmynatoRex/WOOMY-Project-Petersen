#library "metasino"
#include "zcommon.acs"

str FontZ[2] ={"0","1"};

function void DrawScanlines(void)
{
    int Y = Random(0, 240) << 16;
    int Alpha = FixedDiv(Random(25, 75), 100);
    
    // Scanlines
    SetFont("Line");
    HudMessage(s:"A"; HUDMSG_FADEOUT, 0, CR_WHITE, 0.0, Y, 0.05, 1.0, Alpha);
}

function void DrawBinary(void)
{
    int X = Random(-40, 320) << 16;
    int Y = Random(0, 240 / 6) << 16;
    int FadeInTime = 0.1;
    int FadeOutTime = 0.1;
    int Rows = Random(10, 30);
    str Binary;
    
    for (int i = 0; i < Rows; i++)
    {
        if (Random(0, 1))
            Binary = "1";
        else
            Binary = "0";
        
		SetFont("CYBRFONT");
        HudMessage(s:Binary; HUDMSG_FADEINOUT, 0, CR_WHITE, X, Y, 0.05, FadeInTime, FadeOutTime, 0.75);
        
        FadeInTime += 0.1;
        FadeOutTime += 0.1;
        Y += 8.0;
    }
}

script 362 (int pihua, int hunzhang)
{
    int FontX;
    int FontY;
    int FontTim;
    int Time;

    switch (pihua)
    {

    case 1:
        Time = 52;
        while (Time > 0)
        {
          SetHudSize(320, 240, false);

          // Scanlines
          if ((Timer() % 3) == 0)
            DrawScanlines();

        // Binary
          if ((Timer() % 3) == 0)
            DrawBinary();

          SetFont("CYBRBIG");
          FontX = random(0.00,320.00);
          FontY = random(0.00,240.00);
          hudmessage (s:FontZ[random(0,1)],s:"\n";
          1, 0,CR_WHITE, FontX, FontY, 0.1);
          delay(1);

          Time--;
          Delay(1);
        }
    break;

    case 4:
        Time = 25;
        while (Time > 0)
        {
          SetHudSize(320, 240, false);
          if ((Timer() % 3) == 0)
            { DrawScanlines(); }
          Time--;
          Delay(1);
        }
        break;

    case 6:
        Time = 70;
        while (Time > 0)
        {
          SetHudSize(320, 240, false);
          if ((Timer() % 3) == 0)
            { DrawScanlines(); }
          Time--;
          Delay(1);
        }
        break;
    }
}

script 361 ENTER
{
    int IntroChance;
    if (CheckInventory("ImAlive") == 0 && GameType() != GAME_TITLE_MAP)
    {
            FadeRange(64,255,64,1.00,0,0,0,0,3.50);
            ACS_ExecuteAlways(362,0,1,0,0);
            LocalAmbientSound("level/intro",127);
        GiveInventory("ImAlive",1);
    }
    else if (CheckInventory("ImAlive") == 1 && CheckInventory("AlreadyInLevel") == 0 && GameType() != GAME_NET_DEATHMATCH)
    // If the player isn't respawning but is entering a level fresh.
    {
        IntroChance = random(0,4);
        if (IntroChance == 4) { LocalAmbientSound("terminator/intro",127); }
    }
}
////////////////////////////////////////////////////////////////////////////////
// Health Warning Message
////////////////////////////////////////////////////////////////////////////////

// Display a warning message if the player goes under 25 health
Script "HealthWarning_Warn" ENTER
{
	if (GetActorProperty (0, APROP_HEALTH) <= 25 && !CheckInventory("PlayerHealthWarning"))
	{
		LocalAmbientSound("lowhealth", 127);
		GiveInventory("PlayerHealthWarning", 1);
		SetHudSize(320,200,1);
		SetFont("SmallFont");
		HudMessage(l:"Warning! Low health!"; HUDMSG_FADEINOUT, 99, CR_RED, 160.0, 155.0, 1.0, 0.01, 1.0);
		delay(1);
		HudMessage(l:"Warning! Low health!"; HUDMSG_FADEINOUT, 99, CR_RED, 160.0, 145.0, 1.0, 0.01, 1.0);
		delay(1);
		HudMessage(l:"Warning! Low health!"; HUDMSG_FADEINOUT, 99, CR_RED, 160.0, 153.0, 1.0, 0.01, 1.0);
		delay(1);
		HudMessage(l:"Warning! Low health!"; HUDMSG_FADEINOUT, 99, CR_RED, 160.0, 150.0, 1.0, 0.01, 1.0);
	}
	delay(1);
	restart;
}

// Make the player qualify for the message again if they go back above 25 health.
Script "HealthWarning_Clear" ENTER
{
	if (GetActorProperty (0, APROP_HEALTH) > 25 && CheckInventory("PlayerHealthWarning"))
	{
		TakeInventory("PlayerHealthWarning", 999);
	}
	delay(1);
	restart;
}

script 276 DEATH // Mostly the same, except for a few notable exclusions
{
        TakeInventory("ImAlive",1);
        delay(15);
        FadeRange(0,0,0,0,0,0,0,1.00,3.50);
        LocalAmbientSound("systemshutdown",150);
		SetFont("BIGFONT");
		HudMessage(s:"Critical system failure! User flatlined!"; HUDMSG_FADEINOUT, 1, CR_GREEN, 1.5, 0.5, 6.0);
}

script 360 respawn
{
	fadeto(255, 255, 255, 0.0, 0.0);
    ACS_ExecuteAlways(361,0,0,0);
	AmbientSound("systemreboot",150);
	SetFont("BIGFONT");
	HudMessage(s:"System rebooted! Stay off the hook!"; HUDMSG_FADEINOUT, 1, CR_GREEN, 1.5, 0.5, 6.0);
}
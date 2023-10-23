
// UI handler that draws the local player's closest thing
class JPFinderUIHandler : EventHandler
{
    // virtual UI size
    const UI_WIDTH = 400;
    const UI_HEIGHT = 300;
    const SPRITE_Z_OFFSET = 32;
    const CHECKBOX_START_X = 125;
    const CHECKBOX_START_Y = 45;
    const CHECKBOX_PADDING = 4;
    const CHECKBOX_SIZE = 20;
    // total # of types of things we can track
    const NUM_CHECKBOXES = 7;
    
    bool showConfigUI;
    ui bool initialized;
    ui Vector2 mouse;
    // category icons
    ui TextureID bonusIcon;
    ui TextureID powerUpIcon;
    ui TextureID secretIcon;
    ui TextureID monsterIcon;
    ui TextureID keyIcon;
    ui TextureID switchIcon;
    ui TextureID exitIcon;
    // checkbox icons
    ui TextureID boxIcon;
    ui TextureID checkIcon;
    
    override void OnRegister()
    {
        RequireMouse = true;
    }
    
    ui void Init()
    {
        // heretic & hexen
        if ( gameinfo.gametype == 2 || gameinfo.gametype == 4 )
        {
            bonusIcon = TexMan.CheckForTexture("PTN1A0", TexMan.Type_Sprite);
            powerUpIcon = TexMan.CheckForTexture("ARTISOAR", TexMan.Type_Any);
            secretIcon = TexMan.CheckForTexture("unknA0", TexMan.Type_Any);
            boxIcon = TexMan.CheckForTexture("ARTIBOX", TexMan.Type_Flat);
            checkIcon = TexMan.CheckForTexture("M_SLDKB", TexMan.Type_Any);
            // heretic-specific
            if ( gameinfo.gametype == 2 )
            {
                monsterIcon = TexMan.CheckForTexture("IMPXA2A8", TexMan.Type_Any);
                keyIcon = TexMan.CheckForTexture("CKYYB0", TexMan.Type_Any);
                switchIcon = TexMan.CheckForTexture("WALL45", TexMan.Type_WallPatch);
                exitIcon = TexMan.CheckForTexture("PATA00", TexMan.Type_Any);
            }
            // hexen-specific
            else
            {
                monsterIcon = TexMan.CheckForTexture("DEM2B2B8", TexMan.Type_Any);
                keyIcon = TexMan.CheckForTexture("KEY1A0", TexMan.Type_Any);
                switchIcon = TexMan.CheckForTexture("W_332", TexMan.Type_WallPatch);
                exitIcon = TexMan.CheckForTexture("W_256", TexMan.Type_Any);
            }
        }
        // doom = 1
        else
        {
            bonusIcon = TexMan.CheckForTexture("BON2D0", TexMan.Type_Any);
            powerUpIcon = TexMan.CheckForTexture("SOULA0", TexMan.Type_Any);
            secretIcon = TexMan.CheckForTexture("unknA0", TexMan.Type_Any);
            monsterIcon = TexMan.CheckForTexture("HEADC2C8", TexMan.Type_Any);
            keyIcon = TexMan.CheckForTexture("YKEYB0", TexMan.Type_Any);
            switchIcon = TexMan.CheckForTexture("SW1S0", TexMan.Type_WallPatch);
            boxIcon = TexMan.CheckForTexture("STPB0", TexMan.Type_Any);
            checkIcon = TexMan.CheckForTexture("M_SKULL1", TexMan.Type_Any);
            exitIcon = TexMan.CheckForTexture("EXIT1", TexMan.Type_WallPatch);
            // chex quest = 16
            if ( gameinfo.gametype == 16 )
            {
                monsterIcon = TexMan.CheckForTexture("SARGC2C8", TexMan.Type_Any);
                exitIcon = TexMan.CheckForTexture("END0", TexMan.Type_Any);
            }
        }
        initialized = true;
    }
    
    // draws icon, checkbox, and check at given slot #
    ui void DrawCheckBox(TextureID icon, int slot, String cvarChecked)
    {
        int x = CHECKBOX_START_X;
        int y = CHECKBOX_START_Y + (slot * CHECKBOX_SIZE) + (slot * CHECKBOX_PADDING);
        // icon
        // TODO: correct aspect scale within CHECKBOX_SIZE?
        Screen.DrawTexture(icon, false, x, y,
                           DTA_VirtualWidth, UI_WIDTH,
                           DTA_VirtualHeight, UI_HEIGHT,
                           DTA_DestWidth, CHECKBOX_SIZE,
                           DTA_DestHeight, CHECKBOX_SIZE,
                           // disregard sprite offsets
                           DTA_LeftOffset, 0,
                           DTA_TopOffset, 0);
        // checkbox off to right
        x += CHECKBOX_SIZE + CHECKBOX_PADDING;
        Screen.DrawTexture(boxIcon, false, x, y,
                           DTA_VirtualWidth, UI_WIDTH,
                           DTA_VirtualHeight, UI_HEIGHT,
                           DTA_DestWidth, CHECKBOX_SIZE,
                           DTA_DestHeight, CHECKBOX_SIZE);
        if ( !(CVar.FindCVar(cvarChecked).GetBool()) )
            return;
        Screen.DrawTexture(checkIcon, false, x + 2, y + 2,
                           DTA_VirtualWidth, UI_WIDTH,
                           DTA_VirtualHeight, UI_HEIGHT,
                           DTA_DestWidth, CHECKBOX_SIZE - 4,
                           DTA_DestHeight, CHECKBOX_SIZE - 4,
                           DTA_LeftOffset, 0,
                           DTA_TopOffset, 0);
    }
    
    override bool UiProcess(UiEvent e)
    {
        if ( !(showConfigUI) )
            return false;
        if ( automapactive )
            return false;
        // update mouse pos for UI drawing + checks
        mouse = (e.MouseX, e.MouseY);
        if ( e.Type == UiEvent.Type_LButtonDown )
            HandleUIClick();
        else if ( e.Type == UiEvent.Type_RButtonDown )
            SendNetworkEvent("TurnOffConfigUI");
        return false;
    }
    
    override void NetworkProcess(ConsoleEvent e)
    {
        // JPFinderHandler.Tick sends this event when local player's tracker
        // requests it, which in turn happens when JPSecretFinder fires
        if ( e.Name == "TurnOnConfigUI" )
        {
            showConfigUI = true;
            IsUiProcessor = true;
        }
        // UiProcess above sends this event when right mouse is clicked
        else if ( e.Name == "TurnOffConfigUI" )
        {
            showConfigUI = false;
            IsUiProcessor = false;
        }
    }
    
    // called by UiProcess
    ui void HandleUIClick()
    {
        int hoveredButtonSlot = GetHoveredButtonSlot();
        String cvarToChange;
        switch ( hoveredButtonSlot ) {
        case -1: { return; }
        case 0: { cvarToChange = "finder_find_bonuses"; break; }
        case 1: { cvarToChange = "finder_find_powerups"; break; }
        case 2: { cvarToChange = "finder_find_secrets"; break; }
        case 3: { cvarToChange = "finder_find_monsters"; break; }
        case 4: { cvarToChange = "finder_find_keys"; break; }
        case 5: { cvarToChange = "finder_find_switches"; break; }
        case 6: { cvarToChange = "finder_find_exits"; break; }
        }
        bool currentValue = CVar.FindCVar(cvarToChange).GetBool();
        CVar.FindCVar(cvarToChange).SetBool(!currentValue);
    }
    
    // returns slot # of box we're hovering, -1 if none
    ui int GetHoveredButtonSlot()
    {
        Vector2 v = RtV.RealToVirtual(mouse, UI_WIDTH, UI_HEIGHT);
        int minX = CHECKBOX_START_X + CHECKBOX_SIZE + CHECKBOX_PADDING;
        int maxX = minX + CHECKBOX_SIZE;
        if ( v.x > maxX || v.x < minX )
            return -1;
        if ( v.y < CHECKBOX_START_Y )
            return -1;
        int slot = int((v.y - CHECKBOX_START_Y) / (CHECKBOX_SIZE + CHECKBOX_PADDING));
        if ( slot > NUM_CHECKBOXES - 1 )
            return -1;
        return slot;
    }
    
    ui void DrawConfigUI()
    {
        DrawCheckBox(bonusIcon, 0, "finder_find_bonuses");
        DrawCheckBox(powerUpIcon, 1, "finder_find_powerups");
        DrawCheckBox(secretIcon, 2, "finder_find_secrets");
        DrawCheckBox(monsterIcon, 3, "finder_find_monsters");
        DrawCheckBox(keyIcon, 4, "finder_find_keys");
        DrawCheckBox(switchIcon, 5, "finder_find_switches");
        DrawCheckBox(exitIcon, 6, "finder_find_exits");
        // draw cursor?
        /*
        Vector2 v = RtV.RealToVirtual(mouse, UI_WIDTH, UI_HEIGHT);
        Screen.DrawTexture(bonusIcon, true, v.x, v.y,
                           DTA_VirtualWidth, UI_WIDTH,
                           DTA_VirtualHeight, UI_HEIGHT);
        */
    }
    
    ui Vector2 DrawThingIcon(PlayerPawn p, Actor closestThing)
    {
        if ( !closestThing )
            return (-1, -1);
        // get screen-space position of nearest thing
        Vector3 thingPos = closestThing.pos;
        thingPos.z += SPRITE_Z_OFFSET;
        Vector3 playerEye = p.pos;
        playerEye.z += p.ViewHeight;
        Vector3 wsv = mkCoordUtil.WorldToScreen(thingPos, playerEye, p.pitch, p.angle, p.roll, players[consoleplayer].fov);
        // quirk of above function: z > 1 when facing opposite direction
        if ( wsv.z > 1 )
            return (-1, -1);
        Vector2 v = mkCoordUtil.ToViewport(wsv);
        int x = int(v.x / Screen.GetWidth() * UI_WIDTH);
        int y = int(v.y / Screen.GetHeight() * UI_HEIGHT);
        double alpha = 0.5;
        TextureID itemTex = closestThing.CurState.GetSpriteTexture(0);
        // use an actual texture for switches
        if ( closestThing is "JPSwitchMarker" )
            itemTex = switchIcon;
        else if ( closestThing is "JPExitMarker" )
            itemTex = exitIcon;
        // center sprite
        x -= TexMan.GetSize(itemTex) / 2;
        Screen.DrawTexture(itemTex, true, x, y, DTA_Alpha, alpha,
                           DTA_VirtualWidth, UI_WIDTH,
                           DTA_VirtualHeight, UI_HEIGHT,
                           DTA_LeftOffset, 0,
                           DTA_TopOffset, 0);
        // return spot we drew at so distance # can draw near there
        Vector2 finalScreenPos = (x, y);
        return finalScreenPos;
    }
    
    ui void DrawDistanceToThing(Vector2 v, PlayerPawn p, Actor closestThing)
    {
        int distToThing = int((closestThing.pos - p.pos).Length());
        int normalcolor = 2;
        double alpha = 0.5;
        Screen.DrawText(smallfont, normalcolor, v.x, v.y - 8,
                        String.Format("%i", distToThing),
                        DTA_Alpha, alpha,
                        DTA_VirtualWidth, UI_WIDTH,
                        DTA_VirtualHeight, UI_HEIGHT);
    }
    
    override void RenderOverlay(RenderEvent e)
    {
        if ( !initialized )
            Init();
        if ( automapactive )
            return;
        // only draw if finder is up
        if ( !(players[consoleplayer].ReadyWeapon is "JPSecretFinder") )
            return;
        PlayerPawn p = players[consoleplayer].mo;
        JPFinderTracker tracker = JPFinderTracker(p.FindInventory("JPFinderTracker"));
        if ( !tracker )
            return;
        // draw valid closest thing
        Vector2 v = DrawThingIcon(p, tracker.closestThing);
        if ( CVar.FindCVar("finder_show_distance").GetBool() && v != (-1, -1) )
            DrawDistanceToThing(v, p, tracker.closestThing);
        if ( showConfigUI )
            DrawConfigUI();
    }
}

// the non-UI handler that handles world and player stuff
class JPFinderHandler : EventHandler
{
    const SWITCH_MARKER_HEIGHT = 8;
    
    override void WorldLoaded(WorldEvent e)
    {
        // find each secret sector and spawn a marker at its center
        for ( int i = 0; i < level.Sectors.Size(); i++ )
        {
            Sector s = level.Sectors[i];
            if ( !(s.isSecret()) )
                continue;
            float floorZ = -s.floorplane.D;
            Vector3 secCenter = (s.centerspot.x, s.centerspot.y, floorZ);
            JPSecretMarker m = JPSecretMarker(players[consoleplayer].mo.Spawn("JPSecretMarker", secCenter));
            m.sectorIndex = s.Index();
        }
        // find every interactive line and spawn a marker at its midpoint
        for ( int i = 0; i < level.Lines.Size(); i++ )
        {
            Line l = level.Lines[i];
            // use or shoot switches OR level exits
            // (hexen exit special: 74 (Teleport_NewMap))
            bool interactive = l.activation & SPAC_Use || l.activation & SPAC_Impact || l.special == 243 || l.special == 244 || l.special == 74;
            if ( !(interactive) )
                continue;
            // exclude doors with obvious textures
            String frontMidTex = TexMan.GetName(l.sidedef[0].GetTexture(1));
            String frontUpperTex = TexMan.GetName(l.sidedef[0].GetTexture(0));
            String frontLowerTex = TexMan.GetName(l.sidedef[0].GetTexture(2));
            if ( frontMidTex.MakeLower().IndexOf("door") != -1 )
                continue;
            if ( frontUpperTex.MakeLower().IndexOf("door") != -1 )
                continue;
            if ( frontLowerTex.MakeLower().IndexOf("door") != -1 )
                continue;
            Vector2 midpoint = (l.v1.p + l.v2.p) / 2;
            // spawn at an appropriate Z along line-wall
            double z;
            double frontHeight = l.frontsector.ceilingplane.D + l.frontsector.floorplane.D;
            if ( l.backsector )
            {
                double backHeight = l.backsector.ceilingplane.D + l.backsector.floorplane.D;
                if ( frontHeight <= backHeight )
                    z = l.frontsector.floorplane.D + SWITCH_MARKER_HEIGHT;
                else
                    z = l.backsector.floorplane.D + SWITCH_MARKER_HEIGHT;
            }
            else
                z = l.frontsector.ceilingplane.D + l.frontsector.floorplane.D + SWITCH_MARKER_HEIGHT;
            Vector3 lineCenter = (midpoint.x, midpoint.y, z);
            // spawn a switch marker vs an exit marker?
            bool isExit = l.special == 243 || l.special == 244 || l.special == 74;
            if ( !(isExit) )
            {
                // don't spawn if we're close enough to an existing switch marker
                // (would it be faster if we kept an array of them? only sometimes?)
                double checkHeight, checkRadius = 64;
                // ("ignorerestricted" param doesn't seem to do anything?)
                BlockThingsIterator thingFinder = BlockThingsIterator.CreateFromPos(lineCenter.x, lineCenter.y, lineCenter.z, checkHeight, checkRadius, false); 
                bool switchMarkerNearby = false;
                while ( thingFinder.Next() )
                {
                    if ( !(thingFinder.thing is "JPSwitchMarker") )
                        continue;
                    // see if distance is *actually* <=64
                    double d = (thingFinder.thing.pos - lineCenter).Length();
                    if ( d <= 64 )
                    {
                        switchMarkerNearby = true;
                        break;
                    }
                }
                if ( switchMarkerNearby )
                    continue;
            }
            if ( isExit )
            {
                players[consoleplayer].mo.Spawn("JPExitMarker", lineCenter);
            }
            else
            {
                JPSwitchMarker m = JPSwitchMarker(players[consoleplayer].mo.Spawn("JPSwitchMarker", lineCenter));
                m.lineIndex = l.Index();
            }
        }
    }
    
    override void WorldThingSpawned(WorldEvent e)
    {
        bool ignoreBonuses = CVar.FindCVar("finder_ignore_bonuses").GetBool();
        if ( ignoreBonuses && JPFinderTracker.isBonus(e.Thing) )
        {
            e.Thing.bCountItem = false;
            level.total_items--;
        }
    }
    
    override void WorldLinePreActivated(WorldEvent e)
    {
        if ( !(e.Thing is "PlayerPawn") )
            return;
        if ( !(e.ActivationType == SPAC_Use || e.ActivationType == SPAC_Impact) )
            return;
        int lineIndex = e.ActivatedLine.Index();
        JPFinderTracker tracker = JPFinderTracker(e.Thing.FindInventory("JPFinderTracker"));
        if ( !(tracker) )
            return;
        if ( tracker.linesInteracted.Find(lineIndex) != tracker.linesInteracted.Size() )
            return;
        tracker.linesInteracted.Push(lineIndex);
        //Console.Printf(String.Format("Player interacted with line %i for the first time", lineIndex)); // DEBUG
    }
    
    override void WorldTick()
    {
        JPFinderTracker tracker = JPFinderTracker(players[consoleplayer].mo.FindInventory("JPFinderTracker"));
        if ( !(tracker) )
            return;
        if ( tracker.toggleConfigUIRequested )
        {
            tracker.toggleConfigUIRequested = false;
            SendNetworkEvent("TurnOnConfigUI");
        }
    }
}

// item that sits in the player's inventory and finds the closest relevant thing
class JPFinderTracker : Inventory
{
    Actor closestThing;
    Array<int> linesInteracted;
    bool toggleConfigUIRequested;
    
    static bool isBonus(Actor a)
    {
        return a is "HealthBonus" || a is "ArmorBonus" || a is "CrystalVial";
    }
    
    override void Tick()
    {
        Super.Tick();
        // we may have been stripped from our owner by something like a
        // pistol start mod!
        if ( !(owner) )
            return;
        // finding things can get expensive, only do so if finder weapon is out
        if ( !(owner.player.ReadyWeapon is "JPSecretFinder") )
            return;
        bool findBonuses = CVar.FindCVar("finder_find_bonuses").GetBool();
        bool findPowerups = CVar.FindCVar("finder_find_powerups").GetBool();
        bool findSecrets = CVar.FindCVar("finder_find_secrets").GetBool();
        bool findMonsters = CVar.FindCVar("finder_find_monsters").GetBool();
        bool findKeys = CVar.FindCVar("finder_find_keys").GetBool();
        bool ignoreBonuses = CVar.FindCVar("finder_ignore_bonuses").GetBool();
        bool findSwitches = CVar.FindCVar("finder_find_switches").GetBool();
        bool findExits = CVar.FindCVar("finder_find_exits").GetBool();
        double finderRange = CVar.FindCVar("finder_range").GetFloat();
        BlockThingsIterator thingFinder = BlockThingsIterator.Create(owner, finderRange);
        Actor newClosestThing;
        double closestDistance = finderRange + 999;
        while ( thingFinder.Next() )
        {
            Actor t = thingFinder.thing;
            // filter out everything finder isn't ever concerned with
            if ( !(t.bCountItem || t is "JPSecretMarker" || t.bCountKill || t is "Key" || t is "JPSwitchMarker" || t is "JPExitMarker") )
                continue;
            // ignore stuff we're not trying to find
            if ( !(findBonuses) && JPFinderTracker.isBonus(t) )
                continue;
            else if ( !(findPowerups) && t.bCountItem && !(JPFinderTracker.isBonus(t)) )
                continue;
            else if ( !(findSecrets) && t is "JPSecretMarker" )
                continue;
            else if ( !(findSwitches) && t is "JPSwitchMarker" )
                continue;
            else if ( !(findExits) && t is "JPExitMarker" )
                continue;
            else if ( !(findMonsters) && t.bCountKill )
                continue;
            else if ( !(findKeys) && t is "Key" )
                continue;
            // ignore already-found secrets
            if ( t is "JPSecretMarker" )
            {
                Sector s = level.sectors[JPSecretMarker(t).sectorIndex];
                if ( !(s.isSecret()) && s.WasSecret() )
                    continue;
            }
            // ignore lines player has interacted with
            if ( t is "JPSwitchMarker" )
            {
                if ( linesInteracted.Find(JPSwitchMarker(t).lineIndex) != linesInteracted.Size() )
                    continue;
            }
            // ignore dead monsters
            if ( t.bCountKill && t.Health <= 0 )
                continue;
            // closest thing we've found?
            double dist = owner.Distance3D(t);
            if ( dist < closestDistance )
            {
                closestDistance = dist;
                newClosestThing = t;
            }
        }
        if ( !newClosestThing )
        {
            closestThing = NULL;
            return;
        }
        closestThing = newClosestThing;
        //Console.Printf(String.Format("closest thing is %s at %i, %i", closestThing.getClassName(), closestThing.pos.x, closestThing.pos.y)); // DEBUG
    }
}

class JPFinderMarker : Actor
{
    Default
    {
        +NOGRAVITY;
        -SOLID;
        RenderStyle "None";
    }
    
    States
    {
    Spawn:
        // actual (non-sprite) visual is set by HUD drawing
        unkn A -1;
        Stop;
    }
}

class JPSecretMarker : JPFinderMarker
{
    int sectorIndex;
}

class JPExitMarker : JPFinderMarker {}

class JPSwitchMarker : JPFinderMarker
{
    int lineIndex;
}

// weapon that grants secret finding HUD, actual work done in FinderUIHandler
class JPSecretFinder : WoomyWeapon
{
    Default
    {
        // NOTE: below seems to make only rocket launcher unselectable in UTNT?
        // UTNT's tntres.wad's keyconf defines its own slot numbers, which
        // includes slot 8 but not slot 5 (this method is deprecated)
		Tag "'Renzetti' Tracking Device";
		Inventory.PickupMessage "You got the Wakeman Corp. 'Renzetti' Tracking Device! Aren't you supposed to have this already?";
		Weapon.UpSound "TRACKPIK";
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
        Weapon.SlotNumber 0;
        Weapon.SelectionOrder 3701; // one higher than fist; lowest priority
		Scale 0.2;
    }
    
    States
    {
    Spawn:
        // defines althud icon
        fndp A -1;
        Stop;
    Ready:
		1PZ7 A 80 A_WeaponReady(WRF_NOFIRE|WRF_ALLOWZOOM);
		1PZ7 BC 2 { A_WeaponReady(WRF_NOFIRE|WRF_ALLOWZOOM); A_PlaySound ("TRACKDEV"); }
        1PZ7 D 1 A_WeaponReady(WRF_NOFIRE|WRF_ALLOWZOOM);
		Loop;
    Deselect:
        1PZ7 A 1 A_Lower (12);
        Loop;
    Select:
        1PZ7 A 1 A_Raise (12);
        Loop;
    Fire:
        TNT1 A 0;
        Goto Ready;
    }
    
    void ToggleConfigUI()
    {
        JPFinderTracker tracker = JPFinderTracker(owner.FindInventory("JPFinderTracker"));
        if ( tracker && !automapactive )
            tracker.toggleConfigUIRequested = true;
    }
}


Class Matrix4
{
	private double m[16];

	Matrix4 init()
	{
		int i;
		for ( i=0; i<16; i++ ) m[i] = 0;
		return self;
	}

	static Matrix4 create()
	{
		return new("Matrix4").init();
	}

	static Matrix4 identity()
	{
		Matrix4 o = Matrix4.create();
		for ( int i=0; i<4; i++ ) o.set(i,i,1);
		return o;
	}

	double get( int c, int r )
	{
		return m[r*4+c];
	}

	void set( int c, int r, double v )
	{
		m[r*4+c] = v;
	}

	Matrix4 add( Matrix4 o )
	{
		Matrix4 r = Matrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(j,i)+o.get(j,i));
		return r;
	}

	Matrix4 scale( double s )
	{
		Matrix4 r = Matrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(j,i)*s);
		return r;
	}

	Matrix4 mul( Matrix4 o )
	{
		Matrix4 r = Matrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(0,i)*o.get(j,0)+get(1,i)*o.get(j,1)+get(2,i)*o.get(j,2)+get(3,i)*o.get(j,3));
		return r;
	}

	Vector3 vmat( Vector3 o )
	{
		double x, y, z, w;
		x = get(0,0)*o.x+get(1,0)*o.y+get(2,0)*o.z+get(3,0);
		y = get(0,1)*o.x+get(1,1)*o.y+get(2,1)*o.z+get(3,1);
		z = get(0,2)*o.x+get(1,2)*o.y+get(2,2)*o.z+get(3,2);
		w = get(0,3)*o.x+get(1,3)*o.y+get(2,3)*o.z+get(3,3);
		return (x,y,z)/w;
	}

	static Matrix4 rotate( Vector3 axis, double theta )
	{
		Matrix4 r = Matrix4.identity();
		double s, c, oc;
		s = sin(theta);
		c = cos(theta);
		oc = 1.0-c;
		r.set(0,0,oc*axis.x*axis.x+c);
		r.set(1,0,oc*axis.x*axis.y-axis.z*s);
		r.set(2,0,oc*axis.x*axis.z+axis.y*s);
		r.set(0,1,oc*axis.y*axis.x+axis.z*s);
		r.set(1,1,oc*axis.y*axis.y+c);
		r.set(2,1,oc*axis.y*axis.z-axis.x*s);
		r.set(0,2,oc*axis.z*axis.x-axis.y*s);
		r.set(1,2,oc*axis.z*axis.y+axis.x*s);
		r.set(2,2,oc*axis.z*axis.z+c);
		return r;
	}

	static Matrix4 perspective( double fov, double ar, double znear, double zfar )
	{
		Matrix4 r = Matrix4.create();
		double f = 1/tan(fov*0.5);
		r.set(0,0,f/ar);
		r.set(1,1,f);
		r.set(2,2,(zfar+znear)/(znear-zfar));
		r.set(3,2,(2*zfar*znear)/(znear-zfar));
		r.set(2,3,-1);
		return r;
	}

	// UE-like axes from rotation
	static Vector3, Vector3, Vector3 getaxes( double pitch, double yaw, double roll )
	{
		Vector3 x = (1,0,0), y = (0,-1,0), z = (0,0,1);	// y inverted for left-handed result
		Matrix4 mRoll = Matrix4.rotate((1,0,0),roll);
		Matrix4 mPitch = Matrix4.rotate((0,1,0),pitch);
		Matrix4 mYaw = Matrix4.rotate((0,0,1),yaw);
		Matrix4 mRot = mRoll.mul(mYaw);
		mRot = mRot.mul(mPitch);
		x = mRot.vmat(x);
		y = mRot.vmat(y);
		z = mRot.vmat(z);
		return x, y, z;
	}
}


Class mkCoordUtil
{
	// view matrix setup mostly pulled from gutawer's code
	static Vector3 WorldToScreen( Vector3 vect, Vector3 eye, double pitch, double yaw, double roll, double vfov )
	{
		double ar = Screen.getWidth()/double(Screen.getHeight());
		double fovr = (ar>=1.3)?1.333333:ar;
		double fov = 2*atan(tan(clamp(vfov,5,170)*0.5)/fovr);
		float pr = level.pixelstretch;
		double angx = cos(pitch);
		double angy = sin(pitch)*pr;
		double alen = sqrt(angx*angx+angy*angy);
		double apitch = asin(angy/alen);
		double ayaw = yaw-90;
		// rotations
		Matrix4 mRoll = Matrix4.rotate((0,0,1),roll);
		Matrix4 mPitch = Matrix4.rotate((1,0,0),apitch);
		Matrix4 mYaw = Matrix4.rotate((0,-1,0),ayaw);
		// scaling
		Matrix4 mScale = Matrix4.identity();
		mScale.set(1,1,pr);
		// YZ swap
		Matrix4 mYZ = Matrix4.create();
		mYZ.set(0,0,1);
		mYZ.set(2,1,1);
		mYZ.set(1,2,-1);
		mYZ.set(3,3,1);
		// translation
		Matrix4 mMove = Matrix4.identity();
		mMove.set(3,0,-eye.x);
		mMove.set(3,1,-eye.y);
		mMove.set(3,2,-eye.z);
		// perspective
		Matrix4 mPerspective = Matrix4.perspective(fov,ar,5,65535);
		// full matrix
		Matrix4 mView = mRoll.mul(mPitch);
		mView = mView.mul(mYaw);
		mView = mView.mul(mScale);
		mView = mView.mul(mYZ);
		mView = mView.mul(mMove);
		Matrix4 mWorldToScreen = mPerspective.mul(mView);
		return mWorldToScreen.vmat(vect);
	}

	// thanks once again to gutawer for making this thing screenblocks-aware
	static Vector2 ToViewport( Vector3 screenpos, bool scrblocks = true )
	{
		if ( scrblocks )
		{
			int winx, winy, winw, winh;
			[winx,winy,winw,winh] = Screen.getViewWindow();
			int sh = Screen.getHeight();
			int ht = sh;
			int screenblocks = CVar.GetCVar("screenblocks",players[consoleplayer]).getInt();
			if ( screenblocks < 10 ) ht = (screenblocks*sh/10)&~7;
			int bt = sh-(ht+winy-((ht-winh)/2));
			return (winx,sh-bt-ht)+((screenpos.x+1)*winw,(-screenpos.y+1)*ht)*0.5;
		}
		else return ((screenpos.x+1)*Screen.getWidth(),(-screenpos.y+1)*Screen.getHeight())*0.5;
	}
}


Class RtV
{
	static Vector2 RealToVirtual(Vector2 r, double vw, double vh)
	{
		Vector2 v;
		double rw, rh;
		rw = Screen.GetWidth();
		rh = Screen.GetHeight();
		double realAspect = rw / rh;
		double virtualAspect = vw / vh;
		// pillarbox: aspect correct X axis
		if ( realAspect > virtualAspect )
		{
			// offset for aspect
			double pillarWidth;
			pillarWidth = ((rw * vh) / rh) - vw;
			pillarWidth /= 2;
			double croppedRealWidth = (rh * vw) / vh;
			v.x = vw / croppedRealWidth * r.x;
			v.x -= pillarWidth;
			v.y = (vh / rh) * r.y;
		}
		// letterbox: aspect correct Y axis (eg 5:4)
		else if ( realAspect < virtualAspect )
		{
			v.x = (vw / rw) * r.x;
			double letterBoxHeight;
			letterBoxHeight = ((rh * vw) / rw) - vh;
			letterBoxHeight /= 2;
			double croppedRealHeight = (rw * vh) / vw;
			v.y = vh / croppedRealHeight * r.y;
			v.y -= letterBoxHeight;
		}
		else
		{
			v.x = (vw / rw) * r.x;
			v.y = (vh / rh) * r.y;
		}
		return v;
	}
}

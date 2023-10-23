// minimap handler

Class MKMHandler : EventHandler
{
	// list contains a sector that belongs to each portal group
	// used to ease some portal-aware functions
	Array<int> psectors;

	// for minimap
	Array<int> ffsectors;

	Font StatFont;
	TextureID MiniBox[2];

	ui double mm_zoom;
	transient ui ThinkerIterator mi;	// for map markers
	// for interpolation
	ui double minimapzoom, oldminimapzoom;
	// minimap constants
	const CLIPDIST = 800;		// clip distance for minimap view, with rotation accounted
	const MAPVIEWDIST = 1132;	// maximum distance for something to be considered visible (rounded up CLIPDIST*sqrt(2))
	const HALFMAPSIZE = 40;		// half the size of the minimap draw region (unscaled)

	// minimap colors (thats a lot of 'em)
	ui int mm_colorset;
	ui Color mm_backcolor, mm_cdwallcolor, mm_efwallcolor, mm_fdwallcolor, mm_gridcolor, mm_interlevelcolor, mm_intralevelcolor, mm_lockedcolor, mm_notseencolor, mm_portalcolor, mm_secretsectorcolor, mm_secretwallcolor, mm_specialwallcolor, mm_thingcolor, mm_thingcolor_citem, mm_thingcolor_friend, mm_thingcolor_item, mm_thingcolor_monster, mm_thingcolor_ncmonster, mm_thingcolor_shootable, mm_thingcolor_vipitem, mm_thingcolor_missile, mm_tswallcolor, mm_unexploredsecretcolor, mm_wallcolor, mm_xhaircolor, mm_yourcolor;
	ui bool mm_displaylocks;

	// for flashing some elements in the hud
	ui int oldkills, olditems, oldsecrets;
	ui int oldtkills, oldtitems, oldtsecrets;
	transient ui int killflash, itemflash, secretflash;
	transient ui int tkillflash, titemflash, tsecretflash;

	Enum EMiniHUDFontColor
	{
		MCR_DEMOHUD,
		MCR_IBUKIHUD,
		MCR_SAYAHUD,
		MCR_KIRINHUD,
		MCR_MARISAHUD,
		MCR_VOIDHUD,
		MCR_WHITE,
		MCR_RED,
		MCR_GREEN,
		MCR_BLUE,
		MCR_YELLOW,
		MCR_CYAN,
		MCR_PURPLE,
		MCR_BRASS,
		MCR_SILVER,
		MCR_GOLD,
		MCR_MANA,
		MCR_CRIMSON,
		MCR_ELDRITCH,
		MCR_KINYLUM,
		MCR_NOKRON,
		MCR_NOKOROKINYLUM,
		MCR_DEMOBLUE,
		MCR_DEMOPINK,
		MCR_ORANGE,
		MCR_GRASS,
		MCR_MINT,
		MCR_AQUA,
		MCR_MAGENTA,
		MCR_PINK,
		MCR_CRYSTAL,
		MCR_FIRE,
		MCR_SULFUR,
		MCR_WITCH,
		MCR_CYANBLU,
		MCR_ICE,
		MCR_PURPUR,
		MCR_TOMATO,
		MCR_BLURP,
		MCR_PURB,
		MCR_FLASH,
		MCR_REDFLASH,
		NUM_MINIHUD_COLOR
	};

	// top stuff colors
	int mhudfontcol[NUM_MINIHUD_COLOR];
	String mhudfontcoln[NUM_MINIHUD_COLOR];
	int tclabel, tcvalue, tcextra, tccompl, tcsucks;

	override void OnRegister()
	{
		MiniBox[0] = TexMan.CheckForTexture("graphics/MinimapBox.png",TexMan.Type_Any);
		MiniBox[1] = TexMan.CheckForTexture("graphics/MinimapBoxThemed.png",TexMan.Type_Any);
		mhudfontcoln[MCR_DEMOHUD] = "MiniDemoHUD";
		mhudfontcoln[MCR_IBUKIHUD] = "MiniIbukiHUD";
		mhudfontcoln[MCR_SAYAHUD] = "MiniSayaHUD";
		mhudfontcoln[MCR_KIRINHUD] = "MiniKirinHUD";
		mhudfontcoln[MCR_MARISAHUD] = "MiniMarisaHUD";
		mhudfontcoln[MCR_VOIDHUD] = "MiniVoidHUD";
		mhudfontcoln[MCR_WHITE] = "MiniWhite";
		mhudfontcoln[MCR_RED] = "MiniRed";
		mhudfontcoln[MCR_GREEN] = "MiniGreen";
		mhudfontcoln[MCR_BLUE] = "MiniBlue";
		mhudfontcoln[MCR_YELLOW] = "MiniYellow";
		mhudfontcoln[MCR_CYAN] = "MiniCyan";
		mhudfontcoln[MCR_PURPLE] = "MiniPurple";
		mhudfontcoln[MCR_BRASS] = "MiniBrass";
		mhudfontcoln[MCR_SILVER] = "MiniSilver";
		mhudfontcoln[MCR_GOLD] = "MiniGold";
		mhudfontcoln[MCR_MANA] = "MiniMana";
		mhudfontcoln[MCR_CRIMSON] = "MiniCrimson";
		mhudfontcoln[MCR_ELDRITCH] = "MiniEldritch";
		mhudfontcoln[MCR_KINYLUM] = "MiniKinylum";
		mhudfontcoln[MCR_NOKRON] = "MiniNokron";
		mhudfontcoln[MCR_NOKOROKINYLUM] = "MiniNokorokinylum";
		mhudfontcoln[MCR_DEMOBLUE] = "MiniDemoBlue";
		mhudfontcoln[MCR_DEMOPINK] = "MiniDemoPink";
		mhudfontcoln[MCR_ORANGE] = "MiniOrange";
		mhudfontcoln[MCR_GRASS] = "MiniGrass";
		mhudfontcoln[MCR_MINT] = "MiniMint";
		mhudfontcoln[MCR_AQUA] = "MiniAqua";
		mhudfontcoln[MCR_MAGENTA] = "MiniMagenta";
		mhudfontcoln[MCR_PINK] = "MiniPink";
		mhudfontcoln[MCR_CRYSTAL] = "MiniCrystal";
		mhudfontcoln[MCR_FIRE] = "MiniFire";
		mhudfontcoln[MCR_SULFUR] = "MiniSulfur";
		mhudfontcoln[MCR_WITCH] = "MiniWitch";
		mhudfontcoln[MCR_CYANBLU] = "MiniCyanblu";
		mhudfontcoln[MCR_ICE] = "MiniIce";
		mhudfontcoln[MCR_PURPUR] = "MiniPurpur";
		mhudfontcoln[MCR_TOMATO] = "MiniTomato";
		mhudfontcoln[MCR_BLURP] = "MiniBlurp";
		mhudfontcoln[MCR_PURB] = "MiniPurb";
		mhudfontcoln[MCR_FLASH] = "MiniFlash";
		mhudfontcoln[MCR_REDFLASH] = "MiniRedFlash";
		for ( int i=0; i<NUM_MINIHUD_COLOR; i++ )
			mhudfontcol[i] = Font.FindFontColor(mhudfontcoln[i]);
		StatFont = Font.GetFont("MiniHUDOutline");
		if ( gameinfo.gametype&GAME_DoomChex ) tclabel = MCR_RED;
		else tclabel = MCR_YELLOW;
		tcvalue = MCR_WHITE;
		tcextra = MCR_IBUKIHUD;
		tccompl = MCR_BRASS;
		tcsucks = MCR_SAYAHUD;
	}

	// minimap helper code
	private ui void GetMinimapColors()
	{
		mm_colorset = am_colorset;
		switch ( mm_colorset )
		{
		case 1:
			// doom
			mm_backcolor = "00 00 00";
			mm_cdwallcolor = "fc fc 00";
			mm_efwallcolor = "bc 78 48";
			mm_fdwallcolor = "bc 78 48";
			mm_gridcolor = "4c 4c 4c";
			mm_interlevelcolor = 0;
			mm_intralevelcolor = 0;
			mm_lockedcolor = "fc fc 00";
			mm_notseencolor = "6c 6c 6c";
			mm_portalcolor = "40 40 40";
			mm_secretsectorcolor = 0;
			mm_secretwallcolor = 0;
			mm_specialwallcolor = 0;
			mm_thingcolor = "74 fc 6c";
			mm_thingcolor_citem = "74 fc 6c";
			mm_thingcolor_friend = "74 fc 6c";
			mm_thingcolor_item = "74 fc 6c";
			mm_thingcolor_monster = "74 fc 6c";
			mm_thingcolor_ncmonster = "74 fc 6c";
			mm_thingcolor_shootable = "74 fc 6c";
			mm_thingcolor_vipitem = "74 fc 6c";
			mm_thingcolor_missile = "74 fc 6c";
			mm_tswallcolor = "80 80 80";
			mm_unexploredsecretcolor = 0;
			mm_wallcolor = "fc 00 00";
			mm_xhaircolor = "80 80 80";
			mm_yourcolor = "ff ff ff";
			mm_displaylocks = false;
			break;
		case 2:
			// strife
			mm_backcolor = "00 00 00";
			mm_cdwallcolor = "77 73 73";
			mm_efwallcolor = "37 3b 5b";
			mm_fdwallcolor = "37 3b 5b";
			mm_gridcolor = "4c 4c 4c";
			mm_interlevelcolor = 0;
			mm_intralevelcolor = 0;
			mm_lockedcolor = "77 73 73";
			mm_notseencolor = "6c 6c 6c";
			mm_portalcolor = "40 40 40";
			mm_secretsectorcolor = 0;
			mm_secretwallcolor = 0;
			mm_specialwallcolor = 0;
			mm_thingcolor = "bb 3b 00";
			mm_thingcolor_citem = "db ab 00";
			mm_thingcolor_friend = "fc 00 00";
			mm_thingcolor_item = "db ab 00";
			mm_thingcolor_monster = "fc 00 00";
			mm_thingcolor_ncmonster = "fc 00 00";
			mm_thingcolor_shootable = "bb 3b 00";
			mm_thingcolor_vipitem = "db ab 00";
			mm_thingcolor_missile = "bb 3b 00";
			mm_tswallcolor = "77 73 73";
			mm_unexploredsecretcolor = 0;
			mm_wallcolor = "c7 ce ce";
			mm_xhaircolor = "80 80 80";
			mm_yourcolor = "ef ef ef";
			mm_displaylocks = false;
			break;
		case 3:
			// raven
			mm_backcolor = "6c 54 40";
			mm_cdwallcolor = "67 3b 1f";
			mm_efwallcolor = "d0 b0 85";
			mm_fdwallcolor = "d0 b0 85";
			mm_gridcolor = "46 32 10";
			mm_interlevelcolor = 0;
			mm_intralevelcolor = 0;
			mm_lockedcolor = "67 3b 1f";
			mm_notseencolor = "00 00 00";
			mm_portalcolor = "50 50 50";
			mm_secretsectorcolor = 0;
			mm_secretwallcolor = 0;
			mm_specialwallcolor = 0;
			mm_thingcolor = "ec ec ec";
			mm_thingcolor_citem = "ec ec ec";
			mm_thingcolor_friend = "ec ec ec";
			mm_thingcolor_item = "ec ec ec";
			mm_thingcolor_monster = "ec ec ec";
			mm_thingcolor_ncmonster = "ec ec ec";
			mm_thingcolor_shootable = "ec ec ec";
			mm_thingcolor_vipitem = "ec ec ec";
			mm_thingcolor_missile = "ec ec ec";
			mm_tswallcolor = "58 5d 56";
			mm_unexploredsecretcolor = 0;
			mm_wallcolor = "4b 32 10";
			mm_xhaircolor = "00 00 00";
			mm_yourcolor = "ff ff ff";
			mm_displaylocks = true;
			break;
		default:
			// gzdoom
			mm_backcolor = am_backcolor;
			mm_cdwallcolor = am_cdwallcolor;
			mm_efwallcolor = am_efwallcolor;
			mm_fdwallcolor = am_fdwallcolor;
			mm_gridcolor = am_gridcolor;
			mm_interlevelcolor = am_interlevelcolor;
			mm_intralevelcolor = am_intralevelcolor;
			mm_lockedcolor = am_lockedcolor;
			mm_notseencolor = am_notseencolor;
			mm_portalcolor = am_portalcolor;
			mm_secretsectorcolor = am_secretsectorcolor;
			mm_secretwallcolor = am_secretwallcolor;
			mm_specialwallcolor = am_specialwallcolor;
			mm_thingcolor = am_thingcolor;
			mm_thingcolor_citem = am_thingcolor_citem;
			mm_thingcolor_friend = am_thingcolor_friend;
			mm_thingcolor_item = am_thingcolor_item;
			mm_thingcolor_monster = am_thingcolor_monster;
			mm_thingcolor_ncmonster = am_thingcolor_ncmonster;
			mm_thingcolor_shootable = am_thingcolor;
			mm_thingcolor_vipitem = am_unexploredsecretcolor;
			mm_thingcolor_missile = am_specialwallcolor;
			mm_tswallcolor = am_tswallcolor;
			mm_unexploredsecretcolor = am_unexploredsecretcolor;
			mm_wallcolor = am_wallcolor;
			mm_xhaircolor = am_xhaircolor;
			mm_yourcolor = am_yourcolor;
			mm_displaylocks = true;
			break;
		}
	}
	private ui bool ShouldDisplaySpecial( int special )
	{
		// thanks graf/randi/whoever
		switch ( special )
		{
		// the following have (max_args < 0)
		// but we can't know this from zscript, so they're hardcoded here
		case Polyobj_StartLine:
		case Polyobj_ExplicitLine:
		case Transfer_WallLight:
		case Sector_Attach3dMidtex:
		case ExtraFloor_LightOnly:
		case Sector_CopyScroller:
		case Scroll_Texture_Left:
		case Scroll_Texture_Right:
		case Scroll_Texture_Up:
		case Scroll_Texture_Down:
		case Plane_Copy:
		case Line_SetIdentification:
		case Line_SetPortal:
		case Sector_Set3DFloor:
		case Sector_SetContents:
		case Plane_Align:
		case Static_Init:
		case Transfer_Heights:
		case Transfer_FloorLight:
		case Transfer_CeilingLight:
		case Scroll_Texture_Model:
		case Scroll_Texture_Offsets:
		case PointPush_SetForce:
			return false;
		}
		return true;
	}
	private ui bool CheckSectorAction( Sector s, out int special, bool useonly )
	{
		for ( Actor act=s.SecActTarget; act; act=act.tracer )
		{
			if ( (act.Health&(SectorAction.SECSPAC_Use|SectorAction.SECSPAC_UseWall) || !useonly)
				&& act.special && !act.bFRIENDLY )
			{
				special = act.special;
				return true;
			}
		}
		return false;
	}
	private ui bool RealLineSpecial( Line l, out int special )
	{
		if ( special && l.activation&SPAC_PlayerActivate )
			return true;
		if ( CheckSectorAction(l.frontsector,special,!l.backsector) )
			return true;
		return (l.backsector && CheckSectorAction(l.backsector,special,false));
	}
	private ui bool ShowTriggerLine( Line l )
	{
		if ( am_showtriggerlines == 0 ) return false;
		int special = l.special;
		if ( !RealLineSpecial(l,special) ) return false;
		if ( !ShouldDisplaySpecial(special) ) return false;
		if ( special && (am_showtriggerlines >= 2) ) return true;
		if ( !special || (special == Door_Open)
			|| (special == Door_Close)
			|| (special == Door_CloseWaitOpen)
			|| (special == Door_Raise)
			|| (special == Door_Animated)
			|| (special == Generic_Door) )
			return false;
		return true;
	}
	private ui bool CmpFloorPlanes( Line l )
	{
		return (l.frontsector.floorplane.Normal == l.backsector.floorplane.Normal)
			&& (l.frontsector.floorplane.D == l.backsector.floorplane.D);
	}
	private ui bool CmpCeilingPlanes( Line l )
	{
		return (l.frontsector.ceilingplane.Normal == l.backsector.ceilingplane.Normal)
			&& (l.frontsector.ceilingplane.D == l.backsector.ceilingplane.D);
	}

	private ui int CheckSecret( Line l )
	{
		if ( !mm_secretsectorcolor || !mm_unexploredsecretcolor )
			return 0;
		if ( l.frontsector && (l.frontsector.flags&Sector.SECF_WASSECRET) )
		{
			if ( am_map_secrets && !(l.frontsector.flags&Sector.SECF_SECRET) ) return 1;
			if ( (am_map_secrets == 2) && !(l.flags&Line.ML_SECRET) ) return 2;
		}
		if ( l.backsector && (l.backsector.flags&Sector.SECF_WASSECRET) )
		{
			if ( am_map_secrets && !(l.backsector.flags&Sector.SECF_SECRET) ) return 1;
			if ( (am_map_secrets == 2) && !(l.flags&Line.ML_SECRET) ) return 2;
		}
		return 0;
	}
	private ui bool CheckFFBoundary( Line l )
	{
		if ( ffsectors.Size() <= 0 ) return false;
		int frontidx = ffsectors.Find(l.frontsector.Index());
		int backidx = ffsectors.Find(l.backsector.Index());
		// no 3D floors, no boundary
		if ( (frontidx == ffsectors.Size()) && (backidx == frontidx) )
			return false;
		return true;
	}

	private ui void DrawMapLines( RenderEvent e, Vector2 basepos, double hs )
	{
		double zoomlevel = MKMUtility.Lerp(oldminimapzoom,minimapzoom,e.FracTic);
		double zoomview = MAPVIEWDIST*zoomlevel, zoomclip = CLIPDIST*zoomlevel;
		Vector2 cpos = MKMUtility.LerpVector2(players[consoleplayer].Camera.prev.xy,players[consoleplayer].Camera.pos.xy,e.FracTic);
		Sector csec = players[consoleplayer].Camera.CurSector;
		for ( int i=0; i<level.lines.Size(); i++ )
		{
			Line l = level.lines[i];
			if ( !(l.flags&Line.ML_MAPPED) && !level.allmap && !am_cheat ) continue;
			if ( (l.flags&Line.ML_DONTDRAW) && ((am_cheat == 0) || (am_cheat >= 4)) )
				continue;
			Vector2 rv1 = l.v1.p-cpos, rv2 = l.v2.p-cpos;
			bool isportal = false;
			Sector linesector;
			if ( l.sidedef[0].flags&Side.WALLF_POLYOBJ ) linesector = level.PointInSector(l.v1.p+l.delta/2.);
			else linesector = l.frontsector;
			isportal = (linesector.portalgroup!=csec.portalgroup);
			if ( isportal )
			{
				// portal displacement
				Vector2 pofs = MKMUtility.PortalDisplacement(csec,linesector);
				rv1 -= pofs;
				rv2 -= pofs;
			}
			Vector2 mid = (rv1+rv2)/2.;
			Vector2 siz = (abs(rv1.x-rv2.x),abs(rv1.y-rv2.y))/2.;
			if ( (((siz.x+zoomview)-abs(mid.x)) <= 0) || (((siz.y+zoomview)-abs(mid.y)) <= 0) )
				continue;
			// flip Y
			rv1.y *= -1;
			rv2.y *= -1;
			// rotate by view
			rv1 = Actor.RotateVector(rv1,e.ViewAngle-90);
			rv2 = Actor.RotateVector(rv2,e.ViewAngle-90);
			// clip to frame
			bool visible;
			[visible, rv1, rv2] = MKMUtility.LiangBarsky((-1,-1)*zoomclip,(1,1)*zoomclip,rv1,rv2);
			if ( !visible ) continue;
			// scale to minimap frame
			rv1 *= (HALFMAPSIZE/zoomclip)*hs;
			rv2 *= (HALFMAPSIZE/zoomclip)*hs;
			// offset to minimap center
			rv1 += basepos;
			rv2 += basepos;
			// get the line color
			Color col = mm_wallcolor;
			if ( (l.flags&Line.ML_MAPPED) || am_cheat )
			{
				int secwit = CheckSecret(l);
				int lock = MKMUtility.GetLineLock(l);
				if ( secwit == 1 ) col = mm_secretsectorcolor;
				else if ( secwit == 2 ) col = mm_unexploredsecretcolor;
				else if ( l.flags&Line.ML_SECRET )
				{
					if ( am_cheat && l.backsector && mm_secretwallcolor )
						col = mm_secretwallcolor;
					else col = mm_wallcolor;
				}
				else if ( mm_interlevelcolor
					&& ((l.special == Exit_Normal)
					|| (l.special == Exit_Secret)
					|| (l.special == Teleport_NewMap)
					|| (l.special == Teleport_EndGame)) )
					col = mm_interlevelcolor;
				else if ( mm_intralevelcolor &&
					(l.activation&SPAC_PlayerActivate)
					&& ((l.special == Teleport)
					|| (l.special == Teleport_NoFog)
					|| (l.special == Teleport_ZombieChanger)
					|| (l.special == Teleport_Line)) )
					col = mm_intralevelcolor;
				else if ( (lock > 0) && (lock < 256) )
				{
					let lcol = MKMUtility.GetLockColor(lock);
					if ( lcol ) col = lcol;
					else col = mm_lockedcolor;
				}
				else if ( mm_specialwallcolor && ShowTriggerLine(l) )
					col = mm_specialwallcolor;
				else if ( l.frontsector && l.backsector )
				{
					if ( !CmpFloorPlanes(l) ) col = mm_fdwallcolor;
					else if ( !CmpCeilingPlanes(l) ) col = mm_cdwallcolor;
					else if ( CheckFFBoundary(l) ) col = mm_efwallcolor;
					else
					{
						if ( (am_cheat == 0) || (am_cheat >= 4) )
							continue;
						col = mm_tswallcolor;
					}
				}
			}
			else col = mm_notseencolor;
			// draw the line
			if ( isportal )
			{
				col = Color((col.r+mm_portalcolor.r*7)/8,(col.g+mm_portalcolor.g*7)/8,(col.b+mm_portalcolor.b*7)/8);
				Screen.DrawThickLine(int(rv1.x),int(rv1.y),int(rv2.x),int(rv2.y),max(1.,hs*.25),col);
			}
			else Screen.DrawThickLine(int(rv1.x),int(rv1.y),int(rv2.x),int(rv2.y),max(1.,hs*.5),col);
		}
	}

	private ui void DrawMapMarkers( RenderEvent e, Vector2 basepos, double hs )
	{
		double zoomlevel = MKMUtility.Lerp(oldminimapzoom,minimapzoom,e.FracTic);
		double zoomview = MAPVIEWDIST*zoomlevel, zoomclip = CLIPDIST*zoomlevel;
		Vector2 cpos = MKMUtility.LerpVector2(players[consoleplayer].Camera.prev.xy,players[consoleplayer].Camera.pos.xy,e.FracTic);
		Sector csec = players[consoleplayer].Camera.CurSector;
		if ( !mi ) mi = ThinkerIterator.Create("MapMarker",Thinker.STAT_MAPMARKER);
		else mi.Reinit();
		MapMarker m;
		while ( m = MapMarker(mi.Next()) )
		{
			if ( m.bDORMANT ) continue;
			if ( m.args[1] && !(m.CurSector.moreflags&Sector.SECMF_DRAWN) ) continue;
			TextureID tx;
			if ( m.picnum.IsValid() ) tx = m.picnum;
			else tx = m.CurState.GetSpriteTexture(1);
			Vector2 sz = TexMan.GetScaledSize(tx);
			Vector2 scl;
			// seems to match automap scaling somewhat
			if ( m.Args[2] ) scl = (m.Scale/zoomlevel)*.15;
			else scl = m.Scale*.5;
			sz.x *= scl.x;
			sz.y *= scl.y;
			double radius = max(sz.x,sz.y);	// naive, I know
			if ( m.args[0] )
			{
				// oh bother, this will be dicks
				let ai = level.CreateActorIterator(m.args[0]);
				Actor a;
				while ( a = ai.Next() )
				{
					Vector2 rv = a.pos.xy-cpos;
					bool isportal = false;
					Sector sec = level.PointInSector(a.pos.xy);
					if ( sec.portalgroup != csec.portalgroup )
					{
						isportal = true;
						// portal displacement
						rv -= MKMUtility.PortalDisplacement(csec,sec);
					}
					if ( (((radius+zoomview)-abs(rv.x)) <= 0) || (((radius+zoomview)-abs(rv.y)) <= 0) )
						continue;
					// flip Y
					rv.y *= -1;
					// rotate by view
					rv = Actor.RotateVector(rv,e.ViewAngle-90);
					// scale to minimap frame
					rv *= (HALFMAPSIZE/zoomclip)*hs;
					// offset to minimap center
					rv += basepos;
					// draw
					Screen.DrawTexture(tx,false,rv.x,rv.y,DTA_ColorOverlay,isportal?Color(128,mm_portalcolor.r,mm_portalcolor.g,mm_portalcolor.b):Color(0,0,0,0),DTA_ScaleX,hs*scl.x,DTA_ScaleY,hs*scl.y,DTA_LegacyRenderStyle,m.GetRenderStyle(),DTA_Alpha,m.Alpha,DTA_FillColor,m.FillColor,DTA_TranslationIndex,m.Translation);
				}
				ai.Destroy();
				continue;
			}
			Vector2 rv = m.pos.xy-cpos;
			bool isportal = false;
			Sector sec = level.PointInSector(m.pos.xy);
			if ( sec.portalgroup != csec.portalgroup )
			{
				isportal = true;
				// portal displacement
				rv -= MKMUtility.PortalDisplacement(csec,sec);
			}
			if ( (((radius+zoomview)-abs(rv.x)) <= 0) || (((radius+zoomview)-abs(rv.y)) <= 0) )
				continue;
			// flip Y
			rv.y *= -1;
			// rotate by view
			rv = Actor.RotateVector(rv,e.ViewAngle-90);
			// scale to minimap frame
			rv *= (HALFMAPSIZE/zoomclip)*hs;
			// offset to minimap center
			rv += basepos;
			// draw
			Screen.DrawTexture(tx,false,rv.x,rv.y,DTA_ColorOverlay,isportal?Color(128,mm_portalcolor.r,mm_portalcolor.g,mm_portalcolor.b):Color(0,0,0,0),DTA_ScaleX,hs*scl.x,DTA_ScaleY,hs*scl.y,DTA_LegacyRenderStyle,m.GetRenderStyle(),DTA_Alpha,m.Alpha,DTA_FillColor,m.FillColor,DTA_TranslationIndex,m.Translation);
		}
	}

	override void RenderUnderlay( RenderEvent e )
	{
		// obviously, don't draw the minimap if the automap is open
		if ( automapactive ) return;
		GetMinimapColors();
		double hs = max(min(floor(Screen.GetWidth()/640.),floor(Screen.GetHeight()/360.)),1.);
		Vector2 ss = (Screen.GetWidth(),Screen.GetHeight())/hs;
		int yy = 20;
		int xx = int(ss.x-(20+(HALFMAPSIZE+2)*2));
		int theme = swwm_mmap_theme;
		if ( (theme < 0) || (theme > 39) ) theme = -1;
		if ( theme != -1 ) Screen.DrawTexture(MiniBox[1],false,xx,yy,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_SrcX,(theme%2)*85,DTA_SrcY,(theme/2)*85,DTA_SrcWidth,85,DTA_SrcHeight,85,DTA_DestWidth,85,DTA_DestHeight,85);
		else Screen.DrawTexture(MiniBox[0],false,xx,yy,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
		Vector2 basemappos = (xx+HALFMAPSIZE+2,yy+HALFMAPSIZE+2);
		Screen.Dim(mm_backcolor,1.,int((basemappos.x-HALFMAPSIZE)*hs),int((basemappos.y-HALFMAPSIZE)*hs),int(HALFMAPSIZE*2*hs),int(HALFMAPSIZE*2*hs));
		Screen.SetClipRect(int((basemappos.x-HALFMAPSIZE)*hs),int((basemappos.y-HALFMAPSIZE)*hs),int(HALFMAPSIZE*2*hs),int(HALFMAPSIZE*2*hs));
		// draw dat stuff
		DrawMapLines(e,basemappos*hs,hs);
		DrawMapMarkers(e,basemappos*hs,hs);
		// draw the player arrow
		Vector2 tv[3];
		tv[0] = (0,-4);
		tv[1] = (-3,2);
		tv[2] = (3,2);
		for ( int i=0; i<3; i++ ) tv[i] = (tv[i]+basemappos)*hs;
		for ( int i=0; i<3; i++ ) Screen.DrawThickLine(int(tv[i].x),int(tv[i].y),int(tv[(i+1)%3].x),int(tv[(i+1)%3].y),max(1.,hs*.5),mm_yourcolor);
		Screen.ClearClipRect();
		yy += ((HALFMAPSIZE+2)*2)+5;
		xx = int(ss.x-22);
		String str;
		int tclabel_c = swwm_mmap_label;
		if ( (tclabel_c < 0) || (tclabel_c > 39) ) tclabel_c = tclabel;
		if ( (level.total_monsters > 0) && am_showmonsters && !deathmatch )
		{
			str = String.Format("\c["..mhudfontcoln[tclabel_c].."]K \c-%d\c["..mhudfontcoln[tcextra].."]/\c-%d",level.killed_monsters,level.total_monsters);
			Screen.DrawText(StatFont,mhudfontcol[(level.killed_monsters>=level.total_monsters)?tccompl:tcvalue],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
			if ( killflash && (gametic < killflash) )
			{
				double alph = max((killflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d/%d",level.killed_monsters,level.total_monsters);
				int slashpos = str.IndexOf("/");
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str.Left(slashpos),DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			if ( tkillflash && (gametic < tkillflash) )
			{
				double alph = max((tkillflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d",level.total_monsters);
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			yy += StatFont.GetHeight()+2;
		}
		if ( (level.total_items > 0) && am_showitems && !deathmatch )
		{
			str = String.Format("\c["..mhudfontcoln[tclabel_c].."]I \c-%d\c["..mhudfontcoln[tcextra].."]/\c-%d",level.found_items,level.total_items);
			Screen.DrawText(StatFont,mhudfontcol[(level.found_items>=level.total_items)?tccompl:tcvalue],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
			if ( itemflash && (gametic < itemflash) )
			{
				double alph = max((itemflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d/%d",level.found_items,level.total_items);
				int slashpos = str.IndexOf("/");
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str.Left(slashpos),DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			if ( titemflash && (gametic < titemflash) )
			{
				double alph = max((titemflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d",level.total_items);
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			yy += StatFont.GetHeight()+2;
		}
		if ( (level.total_secrets > 0) && am_showsecrets && !deathmatch )
		{
			str = String.Format("\c["..mhudfontcoln[tclabel_c].."]S \c-%d\c["..mhudfontcoln[tcextra].."]/\c-%d",level.found_secrets,level.total_secrets);
			Screen.DrawText(StatFont,mhudfontcol[(level.found_secrets>=level.total_secrets)?tccompl:tcvalue],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
			if ( secretflash && (gametic < secretflash) )
			{
				double alph = max((secretflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d/%d",level.found_secrets,level.total_secrets);
				int slashpos = str.IndexOf("/");
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str.Left(slashpos),DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			if ( tsecretflash && (gametic < tsecretflash) )
			{
				double alph = max((tsecretflash-(gametic+e.FracTic))/25.,0.)**1.5;
				str = String.Format("%d",level.total_secrets);
				Screen.DrawText(StatFont,mhudfontcol[MCR_FLASH],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true,DTA_LegacyRenderStyle,STYLE_Add,DTA_Alpha,alph);
			}
			yy += StatFont.GetHeight()+2;
		}
		int sec;
		if ( am_showtime )
		{
			sec = Thinker.Tics2Seconds(level.maptime);
			str = String.Format("\c["..mhudfontcoln[tclabel_c].."]T \c-%02d\c["..mhudfontcoln[tcextra].."]:\c-%02d\c["..mhudfontcoln[tcextra].."]:\c-%02d",sec/3600,(sec%3600)/60,sec%60);
			Screen.DrawText(StatFont,mhudfontcol[((level.sucktime>0)&&(sec>=(level.sucktime*3600)))?tcsucks:((level.partime>0)&&(sec<=level.partime))?tccompl:tcvalue],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
			yy += StatFont.GetHeight()+2;
		}
		// don't show total time if it's equal to map time
		if ( am_showtotaltime && (level.totaltime != level.maptime) )
		{
			sec = Thinker.Tics2Seconds(level.totaltime);
			str = String.Format("\c["..mhudfontcoln[tclabel_c].."]TT \c-%02d\c["..mhudfontcoln[tcextra].."]:\c-%02d\c["..mhudfontcoln[tcextra].."]:\c-%02d",sec/3600,(sec%3600)/60,sec%60);
			Screen.DrawText(StatFont,mhudfontcol[tcvalue],xx-StatFont.StringWidth(str),yy,str,DTA_VirtualWidthF,ss.x,DTA_VirtualHeightF,ss.y,DTA_KeepRatio,true);
			yy += StatFont.GetHeight()+2;
		}
	}

	override void ConsoleProcess( ConsoleEvent e )
	{
		if ( e.Name ~== "swwmzoomin" ) mm_zoom = max(.5,mm_zoom-.25);
		else if ( e.Name ~== "swwmzoomout" ) mm_zoom = min(1.,mm_zoom+.25);
	}

	override void UiTick()
	{
		if ( mm_zoom == 0 ) mm_zoom = minimapzoom = oldminimapzoom = 1.;
		double desiredzoom = clamp(mm_zoom,.5,1.);
		if ( (minimapzoom != mm_zoom) || (oldminimapzoom != mm_zoom) )
		{
			oldminimapzoom = minimapzoom;
			double diff = .1*(desiredzoom-minimapzoom);
			minimapzoom += diff;
			if ( abs(minimapzoom-desiredzoom) <= .01 )
				minimapzoom = desiredzoom;
		}
		// stats flashing
		if ( level.killed_monsters > oldkills )
		{
			oldkills = level.killed_monsters;
			killflash = gametic+25;
		}
		if ( level.found_items > olditems )
		{
			olditems = level.found_items;
			itemflash = gametic+25;
		}
		if ( level.found_secrets > oldsecrets )
		{
			oldsecrets = level.found_secrets;
			secretflash = gametic+25;
		}
		if ( level.total_monsters > oldtkills )
		{
			oldtkills = level.total_monsters;
			tkillflash = gametic+25;
		}
		if ( level.total_items > oldtitems )
		{
			oldtitems = level.total_items;
			titemflash = gametic+25;
		}
		if ( level.total_secrets > oldtsecrets )
		{
			oldtsecrets = level.total_secrets;
			tsecretflash = gametic+25;
		}
	}

	private void SetupLockdefsCache( MKMCachedLockInfo cli )
	{
		for ( int i=0; i<Wads.GetNumLumps(); i++ )
		{
			String lname = Wads.GetLumpName(i);
			if ( !(lname ~== "LOCKDEFS") ) continue;
			String data = Wads.ReadLump(i);
			Array<String> lines;
			lines.Clear();
			data.Split(lines,"\n");
			bool valid = false;
			for ( int j=0; j<lines.Size(); j++ )
			{
				// strip leading whitespace
				while ( (lines[j].Left(1) == " ") || (lines[j].Left(1) == "\t") )
					lines[j] = lines[j].Mid(1);
				if ( lines[j].Left(10) ~== "CLEARLOCKS" )
				{
					for ( int k=0; k<cli.ent.Size(); k++ )
						cli.ent[k].Destroy();
					cli.ent.Clear();
				}
				else if ( Lines[j].Left(5) ~== "LOCK " )
				{
					Array<String> spl;
					spl.Clear();
					lines[j].Split(spl," ",TOK_SKIPEMPTY);
					// check game string (if any)
					if ( spl.Size() > 2 )
					{
						if ( (spl[2] ~== "DOOM") && !(gameinfo.gametype&GAME_Doom) ) continue;
						else if ( (spl[2] ~== "HERETIC") && !(gameinfo.gametype&GAME_Heretic) ) continue;
						else if ( (spl[2] ~== "HEXEN") && !(gameinfo.gametype&GAME_Hexen) ) continue;
						else if ( (spl[2] ~== "STRIFE") && !(gameinfo.gametype&GAME_Strife) ) continue;
						else if ( (spl[2] ~== "CHEX") && !(gameinfo.gametype&GAME_Chex) ) continue;
					}
					// valid lock, prepare it
					let li = new("MKMLIEntry");
					li.locknumber = spl[1].ToInt();
					li.hascolor = false;
					// see if there's a Mapcolor defined
					int k = j+1;
					for ( int k=j+2; k<lines.Size(); k++ )
					{
						// strip leading whitespace
						while ( (lines[k].Left(1) == " ") || (lines[k].Left(1) == "\t") )
							lines[k] = lines[k].Mid(1);
						if ( lines[k].Left(5) ~== "LOCK " )
							break;	// we reached the next lock
						if ( !(lines[k].Left(9) ~== "MAPCOLOR ") )
							continue;
						// here it is
						spl.Clear();
						lines[k].Split(spl," ",TOK_SKIPEMPTY);
						if ( spl.Size() < 4 ) break;
						li.hascolor = true;
						li.mapcolor = Color(spl[1].ToInt(),spl[2].ToInt(),spl[3].ToInt());
					}
					cli.ent.Push(li);
				}
			}
		}
	}

	override void WorldLoaded( WorldEvent e )
	{
		// check if this is loaded with base mods
		// also ensure we don't load inside the TITLEMAP
		bool bDeleteMe = (gamestate==GS_TITLELEVEL);
		for ( int i=0; i<AllClasses.Size(); i++ )
		{
			if ( (AllClasses[i].GetClassName() != 'SWWMHandler')	// SWWM and friends
				&& (AllClasses[i].GetClassName() != 'UnEventHandler') )	// UNDEATH
				continue;
			bDeleteMe = true;
			break;
		}
		if ( bDeleteMe )
		{
			Destroy();
			return;
		}
		if ( e.IsReopen ) return;
		// setup cached lockdefs data
		let cli = MKMCachedLockInfo.GetInstance();
		if ( cli.ent.Size() == 0 ) SetupLockdefsCache(cli);
		// keep a list of sectors containing 3D floors, for use by the minimap
		// also does the same for the portal group list
		ffsectors.Clear();
		psectors.Clear();
		for ( int i=0; i<level.sectors.Size(); i++ )
		{
			Sector s = level.sectors[i];
			if ( psectors.Size() <= s.portalgroup )
				psectors.Resize(s.portalgroup+1);
			psectors[s.portalgroup] = s.Index();
			if ( !s.Get3DFloorCount() ) continue;
			int realcount = 0;
			for ( int j=0; j<s.Get3DFloorCount(); j++ )
			{
				F3DFloor rover = s.Get3DFloor(j);
				if ( rover.flags&F3DFloor.FF_THISINSIDE ) continue;
				if ( !(rover.flags&F3DFloor.FF_EXISTS) ) continue;
				if ( rover.alpha == 0 ) continue;
				realcount++;
			}
			if ( !realcount ) continue;
			ffsectors.Push(s.Index());
		}
	}
}

// Misc. Utility code

Class MKMUtility
{
	static clearscope double lerp( double a, double b, double theta )
	{
		return a*(1.-theta)+b*theta;
	}
	static clearscope Vector2 LerpVector2( Vector2 a, Vector2 b, double theta )
	{
		return a*(1.-theta)+b*theta;
	}

	static clearscope int GetLineLock( Line l )
	{
		int locknum = l.locknumber;
		if ( !locknum )
		{
			// check the special
			switch ( l.special )
			{
			case FS_Execute:
				locknum = l.Args[2];
				break;
			case Door_LockedRaise:
			case Door_Animated:
				locknum = l.Args[3];
				break;
			case ACS_LockedExecute:
			case ACS_LockedExecuteDoor:
			case Generic_Door:
				locknum = l.Args[4];
				break;
			}
		}
		return locknum;
	}

	// Liang-Barsky line clipping
	static clearscope bool, Vector2, Vector2 LiangBarsky( Vector2 minclip, Vector2 maxclip, Vector2 v0, Vector2 v1 )
	{
		double t0 = 0., t1 = 1.;
		double xdelta = v1.x-v0.x;
		double ydelta = v1.y-v0.y;
		double p, q, r;
		for ( int i=0;i<4; i++ )
		{
			switch ( i )
			{
			case 0:
				p = -xdelta;
				q = -(minclip.x-v0.x);
				break;
			case 1:
				p = xdelta;
				q = (maxclip.x-v0.x);
				break;
			case 2:
				p = -ydelta;
				q = -(minclip.y-v0.y);
				break;
			case 3:
				p = ydelta;
				q = (maxclip.y-v0.y);
				break;
			}
			if ( (p == 0.) && (q<0.) ) return false;
			if ( p < 0 )
			{
				r = q/p;
				if ( r > t1 ) return false;
				else if ( r > t0 ) t0 = r;
			}
			else if ( p > 0 )
			{
				r = q/p;
				if ( r < t0 ) return false;
				else if ( r < t1 ) t1 = r;
			}
		}
		Vector2 ov0 = v0+(xdelta,ydelta)*t0;
		Vector2 ov1 = v0+(xdelta,ydelta)*t1;
		return true, ov0, ov1;
	}

	static clearscope bool IsValidLockNum( int l )
	{
		if ( (l < 1) || (l > 255) ) return true;
		return MKMCachedLockInfo.IsValidLock(l);
	}

	static clearscope Color GetLockColor( int l )
	{
		return MKMCachedLockInfo.GetLockColor(l);
	}

	// get how much a sector's physical position is offset by portals
	static Vector2 PortalDisplacement( Sector a, Sector b )
	{
		if ( a.portalgroup == b.portalgroup ) return (0,0);	// ez
		// we can't access level.displacements, so we gotta improvise
		Vector2 pdisp = b.centerspot-a.centerspot;
		Vector2 vdisp = level.Vec2Diff(a.centerspot,b.centerspot);
		return pdisp-vdisp;
	}
}

// cache data for manual lockdefs parsing nonsense
Class MKMLIEntry
{
	int locknumber;
	bool hascolor;
	Color mapcolor;
}

Class MKMCachedLockInfo : Thinker
{
	Array<MKMLIEntry> ent;

	static clearscope bool IsValidLock( int l )
	{
		let ti = ThinkerIterator.Create("MKMCachedLockInfo",STAT_STATIC);
		MKMCachedLockInfo cli = MKMCachedLockInfo(ti.Next());
		if ( !cli ) return false;
		for ( int i=0; i<cli.ent.Size(); i++ )
		{
			if ( cli.ent[i].locknumber == l )
				return true;
		}
		return false;
	}

	static clearscope Color GetLockColor( int l )
	{
		let ti = ThinkerIterator.Create("MKMCachedLockInfo",STAT_STATIC);
		MKMCachedLockInfo cli = MKMCachedLockInfo(ti.Next());
		if ( !cli ) return 0;
		for ( int i=0; i<cli.ent.Size(); i++ )
		{
			if ( (cli.ent[i].locknumber == l) && cli.ent[i].hascolor )
				return cli.ent[i].mapcolor;
		}
		return 0;
	}

	static MKMCachedLockInfo GetInstance()
	{
		let ti = ThinkerIterator.Create("MKMCachedLockInfo",STAT_STATIC);
		MKMCachedLockInfo cli = MKMCachedLockInfo(ti.Next());
		if ( cli ) return cli;
		cli = new("MKMCachedLockInfo");
		cli.ChangeStatNum(STAT_STATIC);
		return cli;
	}
}

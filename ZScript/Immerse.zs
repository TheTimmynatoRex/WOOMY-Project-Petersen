class ImmerseGlobal : Thinker
{
	Array<Sound> stepSounds;

	ImmerseGlobal Init()
	{
		ChangeStatNum(STAT_STATIC);
		return self;
	}

	static ImmerseGlobal Get()
	{
		ThinkerIterator it = ThinkerIterator.Create("ImmerseGlobal",STAT_STATIC);
		let p = ImmerseGlobal(it.Next());
		if (p == null)
		{
			p = new("ImmerseGlobal").Init();
		}
		return p;
	}
}


//===========================================================================
//
// Taken from Tilt++.pk3 and modified by Joshua Hard (josh771)
//
// Unified player camera tilting for strafing, moving, swimming and death
//
// Written by Nash Muhandes
//
// Feel free to use this in your mods. You don't have to ask my permission!
//
//===========================================================================

class ImmerseHandler : EventHandler
{
	override void PlayerEntered(PlayerEvent e)
	{
		players[e.PlayerNumber].mo.A_GiveInventory("Z_ImmerseMe", 1);
	}
	
	override void PlayerRespawned(PlayerEvent e)
	{
		players[e.PlayerNumber].mo.A_GiveInventory("Z_ImmerseMe", 1);
	}
}

class Z_ImmerseMe : CustomInventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}
	
	bool last_strafelean;
	bool last_leanleft;
	bool last_leanright;
	double leantilt;
	double leanlerp;
	double defaultattackzoffset;
	int leandelay;
	
	double last_offset_angle;
	double last_angle;
	double last_pitch;
	double angle_vel;
	double pitch_vel;
	double phase;
	
	double strafeInput;
	double moveTiltOsc, underwaterTiltOsc;
	double deathTiltOsc;
	double deathTiltRoll;
	double deathTiltAngle;
	double deathTiltPitch;
	double deathTiltAngleStart;
	double deathTiltPitchStart;
	double lastRoll;
	
	static const string[] floorTexture =
	{
		"FWATER1", "FWATER2", "FWATER3", "FWATER4",
		"FLOOR0_1", "FLOOR0_3", "FLOOR1_7", "FLOOR4_1",
		"FLOOR4_5", "FLOOR4_6", "TLITE6_1", "TLITE6_5",
		"CEIL3_1", "CEIL3_2", "CEIL4_2", "CEIL4_3",
		"CEIL5_1", "FLAT2", "FLAT5", "FLAT18",
		"FLOOR0_2", "FLOOR0_5", "FLOOR0_7", "FLAT5_3",
		"CRATOP1", "CRATOP2", "FLAT9", "FLAT17",
		"FLAT19", "COMP01", "GRNLITE1", "FLOOR1_1",
		"FLAT14", "FLAT5_5", "FLOOR1_6", "CEIL4_1",
		"GRASS1", "GRASS2", "RROCK16", "RROCK19",
		"FLOOR6_1", "FLOOR6_2", "FLAT10", "MFLR8_3",
		"MFLR8_4", "RROCK17", "RROCK18", "FLOOR0_6",
		"FLOOR4_8", "FLOOR5_1", "FLOOR5_2", "FLOOR5_3",
		"FLOOR5_4", "TLITE6_4", "TLITE6_6", "FLOOR7_1",
		"MFLR8_1", "CEIL3_5", "CEIL5_2", "CEIL3_6",
		"FLAT8", "SLIME13", "STEP1", "STEP2",
		"GATE1", "GATE2", "GATE3", "CEIL1_2",
		"CEIL1_3", "SLIME14", "SLIME15", "SLIME16",
		"FLAT22", "FLAT23", "CONS1_1", "CONS1_5",
		"CONS1_7", "GATE4", "FLAT4", "FLAT1",
		"FLAT5_4", "MFLR8_2", "FLAT1_1", "FLAT1_2",
		"FLAT1_3", "FLAT5_7", "FLAT5_8", "GRNROCK",
		"RROCK01", "RROCK02", "RROCK03", "RROCK04",
		"RROCK05", "RROCK06", "RROCK07", "RROCK08",
		"RROCK09", "RROCK10", "RROCK11", "RROCK12",
		"RROCK13", "RROCK14", "RROCK15", "RROCK20",
		"SLIME09", "SLIME10", "SLIME11", "SLIME12",
		"FLAT5_6", "FLOOR3_3", "FLAT20", "CEIL3_3",
		"CEIL3_4", "FLAT3", "FLOOR7_2", "DEM1_1",
		"DEM1_2", "DEM1_3", "DEM1_4", "DEM1_5",
		"DEM1_6", "CEIL1_1", "FLAT5_1", "FLAT5_2",
		"NUKAGE1", "NUKAGE2", "NUKAGE3", "BLOOD1",
		"BLOOD2", "BLOOD3", "SLIME01", "SLIME02",
		"SLIME03", "SLIME04", "SLIME05", "SLIME06",
		"SLIME07", "SLIME08", "SFLR6_1", "SFLR6_4",
		"SFLR7_1", "SFLR7_4", "LAVA1", "LAVA2",
		"LAVA3", "LAVA4", "F_SKY1"
	};

	//===========================================================================
	//
	//
	//
	//===========================================================================

	bool bIsOnFloor (void)
	{
		return (Owner.Pos.Z == Owner.FloorZ) || (Owner.bOnMObj);
	}

	bool bIsCrouching (void)
	{
		return Owner.GetCameraHeight() <= (Owner.player.mo.ViewHeight / 2);
	}

	double GetVelocity (void)
	{
		return Owner.Vel.Length();
	}

	int GetWaterLevel (void)
	{
		return Owner.WaterLevel;
	}

	bool bIsPlayerAlive (void)
	{
		return Owner.Health > 0;
	}
	
	double map(double v, double min1, double max1, double min2, double max2)
	{
		double ratio = (v - min1) / (max1 - min1);
		return (max2 - min2) * ratio + min2;
	}
	
	double lerp(double start, double dest, double amt)
	{
		return start + (dest - start) * amt;
	}

	//===========================================================================
	//
	//
	//
	//===========================================================================
	void Tilt_CalcViewRoll (void)
	{
		// CVARS ///////////////////////////////////////////////////////////////
		bool strafeTiltEnabled = sv_strafetilt;
		bool moveTiltEnabled = sv_movetilt;
		bool underwaterTiltEnabled = sv_underwatertilt;
		bool deathTiltEnabled = sv_deathtilt;
		double strafeTiltSpeed = sv_strafetiltspeed;
		double strafeTiltAngle = sv_strafetiltangle;
		bool strafeTiltReversed = sv_strafetiltreversed;
		double moveTiltScalar = sv_movetiltscalar;
		double moveTiltAngle = sv_movetiltangle;
		double moveTiltSpeed = sv_movetiltspeed;
		double underwaterTiltSpeed = sv_underwatertiltspeed;
		double underwaterTiltAngle = sv_underwatertiltangle;
		double underwaterTiltScalar = sv_underwatertiltscalar;
		
		bool realAimSpring = sv_realaimspring;
		bool realAimSwayEnabled = sv_realaimtoggle;
		double realAimSway = sv_realaimsway;
		double realAimRate = sv_realaimrate;
		
		bool syncMovetilt = sv_syncmovetilt;
		
		bool strafeLean = CVar.GetCVar('cl_strafelean',PlayerPawn(Owner).player).GetBool();
		double leanAngle = sv_leanAngle;

		// Shared variables we'll need later
		double r, v;

		//===========================================================================
		//
		// Strafe Tilting
		//
		//===========================================================================

		// normalized strafe input
		if (strafeTiltEnabled && bIsOnFloor() && bIsPlayerAlive())
		{
			int dir;
			if (strafeTiltReversed) dir = -1;
			else dir = 1;
			strafeInput = strafeTiltSpeed * (Owner.GetPlayerInput(INPUT_SIDEMOVE) / 10240.0);
			strafeInput *= strafeTiltAngle;
			strafeInput *= dir;

			// tilt!
			lastRoll += strafeInput;
		}

		//===========================================================================
		//
		// Movement Tilting
		//
		//===========================================================================

		if (moveTiltEnabled && !syncMoveTilt && bIsOnFloor() && bIsPlayerAlive())
		{
			// get player's velocity
			v = GetVelocity() * moveTiltScalar;

			// increment angle
			moveTiltOsc += moveTiltSpeed;

			// clamp angle
			if (moveTiltOsc >= 360. || moveTiltOsc < 0.)
			{
				moveTiltOsc = 0.;
			}

			// calculate roll
			r = Sin(moveTiltOsc);
			r *= moveTiltAngle;
			r *= v;

			// tilt!
			lastRoll += r;
		}

		//===========================================================================
		//
		// Underwater Tilting
		//
		//===========================================================================

		if (GetWaterLevel() >= 3 && underwaterTiltEnabled)
		{
			// fixed rate of 15
			v = 15. * underwaterTiltScalar;

			// increment angle
			underwaterTiltOsc += underwaterTiltSpeed;

			// clamp angle
			if (underwaterTiltOsc >= 360. || underwaterTiltOsc < 0.)
			{
				underwaterTiltOsc = 0.;
			}

			// calculate roll
			r = Sin(underwaterTiltOsc);
			r *= underwaterTiltAngle;
			r *= v;

			// tilt!
			lastRoll += r;
		}

		//===========================================================================
		//
		// Death Tilting
		//
		//===========================================================================

		if (!bIsPlayerAlive() && deathTiltEnabled)
		{
			double deathTiltSpeed = 1.0;
			owner.player.attacker = null;

			if (deathTiltRoll == 0)
			{
				// vary the angles
				deathTiltAngleStart = owner.angle;
				deathTiltPitchStart = owner.pitch;
				
				deathTiltAngle = frandom(-180.0, 180.0);
				deathTiltPitch = frandom(22.5, 90.0) * randompick(-1, 1);
				deathTiltRoll = frandom(22.5, 67.5) + abs(deathTiltAngle) * 0.5;
				deathTiltRoll *= randompick(-1, 1);
			}

			if (deathTiltOsc < 22.5)
			{
				deathTiltOsc += deathTiltSpeed;
			}

			r = Sin(deathTiltOsc);
			
			owner.A_SetAngle(r * deathTiltAngle + deathTiltAngleStart, SPF_INTERPOLATE);
			owner.A_SetPitch(r * deathTiltPitch + deathTiltPitchStart, SPF_INTERPOLATE);
			
			r *= deathTiltRoll;

			// tilt!
			lastRoll += r;
		}
		else
		{
			deathTiltOsc = 0;
			deathTiltRoll = 0;
		}
		
		//===========================================================================
		//
		// RealAim 2.0
		// Written by Joshua Hard (josh771)
		//
		//===========================================================================
		if (realAimSpring)
		{
			Vector2 impulse;
			if (bIsPlayerAlive())
				impulse =
				(
					-Owner.GetPlayerInput(MODINPUT_YAW) * 0.0001,
					Owner.GetPlayerInput(MODINPUT_PITCH) * 0.0001
				);
			else
				impulse = (0,0);
			
			angle_vel = (angle_vel + impulse.x) * 0.8;
			pitch_vel = (pitch_vel + impulse.y) * 0.8;
		}
		
		double offset_angle, offset_pitch;
		
		if (GetVelocity() > 0 && bIsOnFloor())
		{
			double mult = log(max(1.0001, GetVelocity()) * realAimRate);
			offset_angle = mult * (0.125 * realAimSway) * sin((phase * realAimRate) % 360);
			offset_pitch = mult * (0.125 * realAimSway) * sin((phase * 2 * realAimRate) % 360);
			phase += clamp(log(max(1.0001, GetVelocity())), 0.75, 1.75) * 7;
		}
		else
		{
			offset_angle = 0;
			offset_pitch = 0;
		}
		
		if (realAimSwayEnabled)
		{
			Owner.A_SetAngle(Owner.angle + angle_vel + offset_angle, SPF_INTERPOLATE);
			Owner.A_SetPitch(Owner.pitch + pitch_vel + offset_pitch, SPF_INTERPOLATE);
		}
		
		if (moveTiltEnabled && syncMoveTilt)
		{
			// calculate roll
			r = offset_angle * 30;
			r *= moveTiltAngle;
			
			lastRoll += r;
		}
		
		//===========================================================================
		//
		// Leaning
		// Written by Joshua Hard (josh771)
		//
		//===========================================================================
		if (bIsPlayerAlive())
		{
			PlayerInfo pi = PlayerPawn(Owner).player;
			
			let input = pi.cmd.buttons;
			let oldinput = pi.oldbuttons;
			
			bool strafe_left = (input & BT_MOVELEFT) && !(oldinput & BT_MOVELEFT);
			bool strafe_right = (input & BT_MOVERIGHT) && !(oldinput & BT_MOVERIGHT);
			bool unstrafe_left = !(input & BT_MOVELEFT) && (oldinput & BT_MOVELEFT);
			bool unstrafe_right = !(input & BT_MOVERIGHT) && (oldinput & BT_MOVERIGHT);
			
			bool lean_left = Owner.CheckInventory('BT_LeanLeft', 1);
			bool lean_right = Owner.CheckInventory('BT_LeanRight', 1);
			
			if (strafeLean && !last_strafelean)
			{
				if (input & BT_MOVELEFT)
				{
					leantilt -= leanAngle;
					if (bIsOnFloor())
						Owner.Thrust(12.0, Owner.angle + 90.0);
				}
				if (input & BT_MOVERIGHT)
				{
					leantilt += leanAngle;
					if (bIsOnFloor())
						Owner.Thrust(12.0, Owner.angle - 90.0);
				}
				Owner.speed = 0.0;
			}
			else if (strafeLean)
			{
				if (strafe_right || unstrafe_left)
				{
					leantilt += leanAngle;
					if (bIsOnFloor())
						Owner.Thrust(12.0, Owner.angle - 90.0);
				}
				if (strafe_left || unstrafe_right)
				{
					leantilt -= leanAngle;
					if (bIsOnFloor())
						Owner.Thrust(12.0, Owner.angle + 90.0);
				}
			}
			else if (last_strafelean)
			{
				if (pi.onground)
				{
					if (leantilt < 0.0)
						Owner.Thrust(12.0, Owner.angle - 90.0);
					else if (leantilt > 0.0)
						Owner.Thrust(12.0, Owner.angle + 90.0);
				}
				leantilt = 0.0;
				Owner.speed = 1.0;
			}
			else if ((lean_left && !last_leanleft) || (last_leanright && !lean_right))
			{
				leantilt -= leanAngle;
				if (bIsOnFloor())
					Owner.Thrust(12.0, Owner.angle + 90.0);
			}
			else if ((lean_right && !last_leanright) || (last_leanleft && !lean_left))
			{
				leantilt += leanAngle;
				if (bIsOnFloor())
					Owner.Thrust(12.0, Owner.angle - 90.0);
			}
			else if (!(lean_right || lean_left))
			{
				leantilt = 0.0;
			}
			last_strafelean = strafeLean;
			last_leanleft = lean_left;
			last_leanright = lean_right;
			
			PlayerPawn player = PlayerPawn(Owner);

			pi.viewz += map
			(
				abs(leanTilt),
				0.0,
				90.0,
				0.0,
				-player.viewheight * pi.CrouchFactor
			);
			player.attackzoffset = map
			(
				abs(leanTilt),
				0.0,
				90.0,
				defaultattackzoffset,
				Owner.height * -0.4
			);
			Owner.height = map
			(
				abs(leanTilt),
				0.0,
				90.0,
				player.FullHeight * pi.CrouchFactor,
				Owner.radius
			);
			Owner.scale.y = map
			(
				abs(leanTilt),
				0.0,
				90.0,
				1.0,
				double(Owner.radius) / player.FullHeight
			);
			if (abs(leanTilt) > 1.0 && bIsOnFloor())
			{
				leandelay = 9;
				Owner.vel *= 0.75;
			}
			else if (leandelay > 0)
			{
				leandelay--;
				Owner.vel *= 0.75;
			}
			leanlerp += (leantilt - leanlerp) * 0.1;
		}

		//===========================================================================
		//
		// Tilt Post Processing
		//
		//===========================================================================

		// Apply the sum of all rolling routines
		// (including after stabilization)
		Owner.A_SetRoll(lastRoll + leanlerp, SPF_INTERPOLATE);
		
		// Stabilize tilt
		lastRoll *= 0.75;
	}

	override void Tick(void)
	{
		if (Owner && Owner is "PlayerPawn")
		{
			if (defaultattackzoffset == 0)
				defaultattackzoffset = PlayerPawn(Owner).attackZOffset;
			Tilt_CalcViewRoll();
		}

		Super.Tick();
	}
	
//==============================================================================
//==============================================================================
	
	States
	{
	Use:
		TNT1 A 0;
		Fail;
	Pickup:
		TNT1 A 0
		{
			invoker.last_angle = angle;
			invoker.last_pitch = pitch;
			return true;
		}
		Stop;
	}
}

//===========================================================================
//
// Custom Widgets for Tilt++
// Adds tooltips to widgets
//
// Some redundant duplicates here but whatever; menus are painful to work
// with in general anyway. >:(
//
//===========================================================================

class OptionMenuItemTiltPlusPlusOption : OptionMenuItemOption
{
	String mTooltip;

	OptionMenuItemTiltPlusPlusOption Init(String label, String tooltip, Name command, Name values, CVar graycheck = null, int center = 0)
	{
		mTooltip = tooltip;
		Super.Init(label, command, values, graycheck, center);
		return self;
	}
}

class OptionMenuItemTiltPlusPlusSlider : OptionMenuItemSlider
{
	String mTooltip;

	OptionMenuItemTiltPlusPlusSlider Init(String label, String tooltip, Name command, double min, double max, double step, int showval = 1)
	{
		mTooltip = tooltip;
		Super.Init(label, command, min, max, step, showval);
		return self;
	}
}

//===========================================================================
//
// Tilt++ Menu
//
//===========================================================================

class TiltPlusPlusMenu : OptionMenu
{
	override void Drawer ()
	{
		Super.Drawer();

		String tt;

		if (mDesc.mSelectedItem > 0)
		{
			if (mDesc.mItems[mDesc.mSelectedItem] is "OptionMenuItemTiltPlusPlusOption")
			{
				tt = StringTable.Localize(OptionMenuItemTiltPlusPlusOption(mDesc.mItems[mDesc.mSelectedItem]).mTooltip);
			}

			if (mDesc.mItems[mDesc.mSelectedItem] is "OptionMenuItemTiltPlusPlusSlider")
			{
				tt = StringTable.Localize(OptionMenuItemTiltPlusPlusSlider(mDesc.mItems[mDesc.mSelectedItem]).mTooltip);
			}
		}

		if (tt.Length() > 0)
		{
			screen.DrawText (SmallFont, OptionMenuSettings.mFontColorValue,
				(screen.GetWidth() - SmallFont.StringWidth (tt) * CleanXfac_1) / 2,
				screen.GetHeight() - (SmallFont.GetHeight() * 8),
				tt,
				DTA_CleanNoMove_1, true);
		}
	}
}

class BT_LeanLeft : Inventory
{}

class BT_LeanRight : Inventory
{}

class LeaningHandler : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || !playeringame[e.Player] || !players[e.Player].mo)
			return;
			
		let player = players[e.Player].mo;
		
		if (e.Name ~== "lean_left" && player.health > 0)
			player.GiveInventory('BT_LeanLeft', 1);
		else if (e.Name ~== "unlean_left")
			player.TakeInventory('BT_LeanLeft', 1);
		else if (e.Name ~== "lean_right" && player.health > 0)
			player.GiveInventory('BT_LeanRight', 1);
		else if (e.Name ~== "unlean_right")
			player.TakeInventory('BT_LeanRight', 1);
	}
}
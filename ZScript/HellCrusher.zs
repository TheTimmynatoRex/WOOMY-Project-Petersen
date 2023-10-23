/////////////////////////////////////////////////////////////DASH

Class DEDashBar : Ammo {

	Default{
  Inventory.Amount 0;
  Inventory.MaxAmount 2;
  Ammo.BackpackAmount 0;
  Ammo.BackpackMaxAmount 2;
  }
}

Class DEDashJump : Inventory 						///Dash and double jump code by TheCamaleonMaligno ( https://www.youtube.com/watch?v=mTfGxY_Afhs )
{
	Double DashDir, DashSpeed;
	Int DashTics, DashCharge, AirTics;
	Bool DJump, Waiting;
	
	Default{
	+INVENTORY.UNDROPPABLE
	}
	
	Override Void Tick()
	{
		Super.Tick();
		If(!Owner || Owner && (!Owner.Player || Owner.Health<1)) Return;
		PlayerInfo P=Owner.Player;
		Int BT=P.cmd.buttons;
		Int DashMaxCharge=35;
		
		
		
		If(!Waiting && (BT & BT_USER4) && DashCharge>=DashMaxCharge/2 && !DashTics)
		{
			DashDir=0;
			If(BT & BT_FORWARD) DashDir=0;
			If(BT & BT_BACK) DashDir=180;
			If(BT & BT_MOVELEFT) DashDir=90;
			If(BT & BT_MOVERIGHT) DashDir=-90;
			If((BT & BT_FORWARD) && (BT & BT_MOVELEFT)) DashDir=45;
			If((BT & BT_FORWARD) && (BT & BT_MOVERIGHT)) DashDir=-45;
			If((BT & BT_BACK) && (BT & BT_MOVELEFT)) DashDir=180-45;
			If((BT & BT_BACK) && (BT & BT_MOVERIGHT)) DashDir=180+45;
			DashDir+=Owner.Angle;
			If(DashCharge<DashMaxCharge) { Waiting=True; DashCharge=0; }
			DashCharge=Max(0,DashCharge-DashMaxCharge/2);
			DashSpeed=35;
			DashTics=10;
			
			Owner.TakeInventory("DEDashBar",1,AAPTR_DEFAULT);
			
			Owner.A_SetBlend("White",0.1,20);
			Owner.A_StartSound("DashActivated",50,CHANF_OVERLAP);
			Owner.A_QuakeEx(2,2,2,15,0,1,"",QF_SCALEDOWN);
			Actor C=Spawn("DashCollisionChecker",Owner.Pos);
			C.bSolid=True;
			C.Master=Self;
			C.Target=Owner;
			C.A_SetSize(Owner.Radius,Owner.Height);
			C.bNoTImeFreeze=True;
			
		}
		If(DashTics)
		{
			//If(P.OnGround) {P.OnGround=False; Owner.AddZ(1); }
			DashTics--;
			Owner.VelFromAngle(DashSpeed,DashDir);
			If(DashTics<=5) DashSpeed*=0.8;
			Owner.Vel.Z=0;
			
			
		}
		
		If(P.onGround)
		{
			DJump=True;
			
			//AirTics=0;
		}
		Else If(!(Owner.GetPlayerInput(MODINPUT_OLDBUTTONS) & BT_JUMP) && (Owner.GetPlayerInput(MODINPUT_BUTTONS) & BT_JUMP) && DJump && AirTics>=5)
		{
		
			//Owner.Vel.Z=Max(Owner.Vel.Z+8,8);
			
			//Owner.A_StartSound("DoubleJump",69,CHANF_OVERLAP);
			
			DJump=False;
			
			
		}
		
		Else AirTics++;
		
		If(DashCharge<DashMaxCharge)
		{
			//GiveInventory("DEDashBar",2,AAPTR_DEFAULT);
			DashCharge++;
			If(DashCharge==DashMaxCharge && !P.OnGround){DashCharge=DashMaxCharge-1; GiveInventory("DEDashBar",2,AAPTR_DEFAULT);}

			If(DashCharge==DashMaxCharge)
			{
				Waiting=False;
				GiveInventory("DEDashBar",70,AAPTR_DEFAULT);
				Owner.A_StartSound("DashReady",69,CHANF_OVERLAP);
			}
		}
	}
}



Class DashCollisionChecker : Actor
{
	DEDashJump je;
	Override Void PostBeginPlay()
	{
		Super.PostBeginPlay();
		let sas=DEDashJump(Master);
		je=sas;
	}
	Override bool CanCollideWith(Actor other, bool passive)
	{
		If(Other==target || Other.bMissile)
		Return False;
		If(Pos.Z>Other.Pos.Z+Other.Height || Other.Pos.Z>Pos.Z+Height) Return False;
		If(Other.bSolid && Other.bShootable && Other.CanCollideWith(Self,0))
		Tracer=Other;
		Return False;
	}
	Override VOid Tick()
	{
		Super.TIck();
		If(!target || !je || je && !je.dashtics) { Destroy(); Return; }
		SetOrigin(Target.Pos+Target.Vel*0.1,0);
		Vel=Target.Vel;
		If(Tracer)
		{
			bThruActors=True;
			/*
			Let Cg=Weapon_Chaingun(Target.player.ReadyWeapon);
			If(Cg && Cg.Tracer)
			{
				bForcePain=True;
				Target.Vel*=0;
				Tracer.DamageMobj(Self,Target,75,'Normal',0,Target.Angle);
				Tracer.ApplyKickback(Target,Target,300,Target.Angle,'Normal',0);
				Tracer.A_TakeInventory("DashStun");
				Tracer.A_GiveInventory("DashStun");
				Target.A_StartSound("Weapons/DE/ChaingunShieldDash",9,CHANF_OVERLAP,0.5);
				Target.A_QuakeEx(1,1,1,8,0,1,"",QF_SCALEDOWN);
				Cg.DashImpact();
				Cg.DashImpact();
			}
			*/
			je.DashSpeed=0;
			Destroy();
		}
	}
}

/////////////////////////////Grenade

class Shoulder_Grenade_FX : Actor{
Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FORCEXYBILLBOARD
	+ZDOOMTRANS
	RenderStyle "Translucent";
	Alpha 0.50;
	}
	States{

		Spawn:
		TNT1 A 0;
		TNT1 A 0
		{
			for (int i = random(20,30); i > 0; i--)
			{
				A_SpawnItemEx("RocketSmokeTrail",0,0,0,frandom(-20,20),frandom(-20,20),frandom(-20,20));
			}
		}
		EXPL ABCDEF 1 Bright;
		Stop;
	}
}

class ExplosionAddG : Actor {
Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FORCEXYBILLBOARD
	+ZDOOMTRANS
	RenderStyle "Translucent";
	Alpha 0.50;
	}
	States{
		Spawn:
		TNT1 A 0;
		EXPL ABCDEF 1 Bright;
		Stop;
	}
}

/////////////////ICE

Class Ice_Grenade_Smoke : Actor
{
	Default
	{
  RenderStyle "Add";
  Alpha 0.4;
  VSpeed 1;
  +NOBLOCKMAP
  +NOCLIP
  +NOGRAVITY
  +DONTSPLASH
  +NOTELEPORT
  +FORCEXYBILLBOARD
  }
  States
  {
  Spawn:
    ICBB KL 10;
	ICBB MNO 3;
    Stop;
  }
}

class ICEExplosionAddG : Actor {
Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FORCEXYBILLBOARD
	+ZDOOMTRANS
	RenderStyle "Translucent";
	Alpha 0.50;
	}
	States{
		Spawn:
		TNT1 A 0;
		ICBX ABCDEF 1 Bright;
		Stop;
	}
}

class ICEExplosionShockWave : Actor 
{
	Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FLATSPRITE
	+ZDOOMTRANS
	RenderStyle "Add";
	Alpha 0.75;
	}
	States{
		Spawn:
		TNT1 A 0;
		TNT1 A 0 {A_SetRoll(Random(0,359)); A_SetPitch(Random(-90,90)); A_SetAngle(Random(0,359));}
		ICBX G 1 {A_SetScale(0.4); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(0.8); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(1.0); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(1.4); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(1.8); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(2.0); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(2.4); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(2.8); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(3.0); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(3.4); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(3.8); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(4.0); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(4.4); A_FadeOut(0.05);}
		ICBX G 1 {A_SetScale(4.8); A_FadeOut(0.05);}
		Stop;
	}
}

class ExplosiveDebrisICE : Actor
{
	Default
	{
	scale 0.30;
	radius 2;
	
	bouncefactor 0.6;
	wallbouncefactor 0.6;
	bouncecount 7;
	bouncetype "Doom";
	
	projectile;
	-NOGRAVITY
	-NOBLOCKMAP
	+NOTELEPORT
	+THRUACTORS
	+DROPOFF
	+FLOORCLIP
	-BOUNCEONACTORS
	+FORCEXYBILLBOARD
	}
	States{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItemEx("Ice_Grenade_Smoke",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		TNT1 A 1 A_Jump(10,"Death");
		TNT1 A 1;
		Loop;
	Death:
		TNT1 A 0 A_SpawnItemEx("Ice_Grenade_Smoke",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		TNT1 A 1;
		Stop;
		
	}	
}

class Ice_Grenade_FX : Actor{
Default
	{
	+NOGRAVITY
	+FORCEXYBILLBOARD
	+ZDOOMTRANS
	RenderStyle "Add";
	Alpha 0.50;
	}
	States{

		Spawn:
		TNT1 A 0;
		TNT1 A 0 A_StartSound("EquipmentIceExplode",0,0,1);
		/*
		TNT1 A 0
		{
			for (int i = random(20,30); i > 0; i--)
			{
				A_SpawnItemEx("Ice_Grenade_Smoke",0,0,0,frandom(-20,20),frandom(-20,20),frandom(-20,20));
			}
		}
		*/
		
		TNT1 A 0
		{
			for (int i = random(6,10); i > 0; i--)
			{
				A_SpawnItemEx("ICEExplosionAddG",frandom(-7,7),frandom(-7,7),frandom(-7,7),frandom(-18,18),frandom(-18,18),frandom(-18,18));
			}
		}
		
		TNT1 A 0
		{
			for (int i = random(2,5); i > 0; i--)
			{
				A_SpawnItemEx("ICEExplosionShockWave",0,0,0,0,0,0);
			}
		}
		
		TNT1 A 0
		{
			for (int i = random(15,20); i > 0; i--)
			{
				A_SpawnItemEx("ExplosiveDebrisICE",0,0,0,frandom(-30,30),frandom(-30,30),frandom(-30,30));
			}
		}
		
		ICBX ABCD 1 Bright;
		ICBX EF 1 Bright;
		Stop;
	}
}

/////////////////////////////Barrel

Class BarrelFX : Actor
{
  States
  {
  Spawn:
	TNT1 A 0;
	
	TNT1 A 0 A_StartSound("BarrelAdd",CHAN_5);
	TNT1 A 0 A_StartSound("BarrelDebris",CHAN_6);
	TNT1 A 0 A_StartSound("BarrelExplode",CHAN_7);
	TNT1 A 5;
	
	TNT1 A 0
		{
			for (int i = random(4,7); i > 0; i--)
			{
				A_SpawnItemEx("ExplosionAddG",frandom(-5,5),frandom(-5,5),frandom(-5,5),frandom(-15,15),frandom(-15,15),frandom(-15,15));
			}
		}
		
	TNT1 A 0
		{
			for (int i = random(1,3); i > 0; i--)
			{
				A_SpawnItemEx("ExplosionShockWave",0,0,0,0,0,0);
			}
		}
		
	TNT1 A 0
		{
			for (int i = random(6,13); i > 0; i--)
			{
				A_SpawnItemEx("ExplosiveDebris",0,0,0,frandom(-30,30),frandom(-30,30),frandom(-30,30));
			}
		}
	
	TNT1 A 0 A_SpawnItemEx("BarrelFire");
	TNT1 A 0 A_QuakeEx(1,1,1,10,0,500,"*");
	TNT1 A 60;
    Stop;
  }
}

Class AfterBarrelEX : Actor
{
	Default{
	Radius 0;
	Height 0;
	//-SOLID
	}
  States
  {
  Spawn:
	 BAR1 D -1;
    Stop;
  }
}

Class BarrelFire : Actor
{
	Default{
	+ZDOOMTRANS
	RenderStyle "Translucent";
	Alpha 0.50;
	}
	States
	{
	Spawn:
		FIRE ABCDEFGH 1 BRIGHT;
		Stop;
	}
}

/////////////////////////////Rocket

Class RocketSFX : Actor
{
Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FORCEXYBILLBOARD
	+ZDOOMTRANS
	RenderStyle "Translucent";
	Alpha 0.50;
	}
  States
  {
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_StartSound("RocketExplode",CHAN_5);
		TNT1 A 0 A_StartSound("RocketExplodeAdd",CHAN_6);
		TNT1 A 0 A_QuakeEx(1,1,1,10,0,500,"*");
		
		TNT1 A 0
		{
			for (int i = random(20,30); i > 0; i--)
			{
				A_SpawnItemEx("RocketSmokeTrail",0,0,0,frandom(-20,20),frandom(-20,20),frandom(-20,20));
			}
		}
		
		TNT1 A 0
		{
			for (int i = random(3,5); i > 0; i--)
			{
				A_SpawnItemEx("ExplosionAddG",frandom(-5,5),frandom(-5,5),frandom(-5,5),frandom(-15,15),frandom(-15,15),frandom(-15,15));
			}
		}
		
		TNT1 A 0
		{
			for (int i = random(1,3); i > 0; i--)
			{
				A_SpawnItemEx("ExplosionShockWave",0,0,0,0,0,0);
			}
		}
		
		TNT1 A 0
		{
			for (int i = random(5,15); i > 0; i--)
			{
				A_SpawnItemEx("ExplosiveDebris",0,0,0,frandom(-30,30),frandom(-30,30),frandom(-30,30));
			}
		}
		
		EXPL ABCDEF 1 Bright;
		
		TNT1 A 60;
		Stop;
  }
}

/////////////////////////////Genral

class ExplosionShockWave : Actor 
{
	Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FLATSPRITE
	+ZDOOMTRANS
	RenderStyle "Add";
	Alpha 0.75;
	}
	States{
		Spawn:
		TNT1 A 0;
		TNT1 A 0 {A_SetRoll(Random(0,359)); A_SetPitch(Random(-90,90)); A_SetAngle(Random(0,359));}
		EXPL G 1 {A_SetScale(0.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(0.6); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(0.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.2); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.6); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.2); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.6); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(3.0); A_FadeOut(0.05);}
		Stop;
	}
}

class BIGExplosionShockWave : Actor 
{
	Default
	{
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+DONTSPLASH
	+NOTELEPORT
	+NOGRAVITY
	+FLATSPRITE
	+ZDOOMTRANS
	RenderStyle "Add";
	Alpha 0.75;
	}
	States{
		Spawn:
		TNT1 A 0;
		TNT1 A 0 {A_SetRoll(Random(0,359)); A_SetPitch(Random(-90,90)); A_SetAngle(Random(0,359));}
		EXPL G 1 {A_SetScale(0.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(0.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(1.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(2.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(3.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(3.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(3.8); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(4.0); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(4.4); A_FadeOut(0.05);}
		EXPL G 1 {A_SetScale(4.8); A_FadeOut(0.05);}
		Stop;
	}
}

class ExplosiveDebris : Actor
{
	Default
	{
	scale 0.30;
	radius 2;
	
	bouncefactor 0.6;
	wallbouncefactor 0.6;
	bouncecount 7;
	bouncetype "Doom";
	
	projectile;
	-NOGRAVITY
	-NOBLOCKMAP
	+NOTELEPORT
	+THRUACTORS
	+DROPOFF
	+FLOORCLIP
	-BOUNCEONACTORS
	+FORCEXYBILLBOARD
	}
	States{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItemEx("RocketSmokeTrail",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		TNT1 A 1 A_Jump(10,"Death");
		Loop;
		
		
	Death:
		TNT1 A 0 A_SpawnItemEx("RocketSmokeTrail",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		TNT1 A 1;
		Stop;
		
	}	
}

Class StunMeDaddy : Powerup
{
	Override Void InitEffect()
	{
		special1=Max(Owner.Tics,5);
	}
	Override Void DoEffect()
	{
		If(Owner.Health>0)
		Owner.Tics=special1;
	}
}

Class ShockBeamGlow : EffectBase
{
	Default {
	Scale 0.16;
	Alpha 0.99;
	}
	Override Void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Alpha*=FRandom(0.66,1.0);
	}
	States
	{
	Spawn:
		FLRE A 2 Bright;
		Stop;
	}
}

class LMBDLib : Actor
{
    static void AlignToSlope(Actor self, double dAng, double dPitch)
    {
        vector3 fNormal = self.CurSector.FloorPlane.Normal;
        vector2 fNormalP1 = (fNormal.X != 0 || fNormal.Y != 0) ? (fNormal.X, fNormal.Y).Unit() : (0, 0);
        vector2 fNormalP2 = ((fNormal.X, fNormal.Y).Length(), fNormal.Z);
        double fAng = atan2(fNormalP1.Y, fNormalP1.X); // floor angle (not pitch!)
        double fPitch = -atan2(fNormalP2.X, fNormalP2.Y); // floor pitch
        double dDiff1 = sin(fAng - (dAng + dPitch));
        double dDiff2 = cos(fAng - dAng);
        self.A_SetPitch(fPitch * dDiff2 + dPitch);
        self.A_SetRoll(fPitch * dDiff1);
        self.angle = atan2(fnormalp1.y, fnormalp1.x);
        //self.Angle=dAng;
    }
	static vector2 FaceVector(vector3 source, vector3 dest)
	{

		double xx=source.x - dest.x;
		double yy=source.y - dest.y;
		double zz=source.z - dest.z;
		double a=VectorAngle(xx,yy);
		double p=-VectorAngle(sqrt((xx*xx)+(yy*yy)),zz);
		Return (a,p);
	}
	static double VectorLength(vector3 source, vector3 dest, bool usez=true)
	{
		If(usez)
		Return sqrt(
		(source.x - dest.x) * (source.x - dest.x) +
		(source.y - dest.y) * (source.y - dest.y) +
		(source.z - dest.z) * (source.z - dest.z));
		Return sqrt(
		(source.x - dest.x) * (source.x - dest.x) +
		(source.y - dest.y) * (source.y - dest.y));
	}
	static void A_SpawnActorLine(string classname, Vector3 pointA, Vector3 pointB, double units = 1)
	{
		// get a vector pointing from A to B
		let pointAB = pointB - pointA;

		// get distance
		let dist = pointAB.Length();

		// normalize it
		pointAB /= dist == 0 ? 1 : dist;

		// iterate in units of 'units'
		for (double i = 0; i < dist; i += units)
		{
			// we can now use 'pointA + i * pointAB' to
			// get a position that is 'i' units away from
			// pointA, heading in the direction towards pointB
			let position = pointA + i * pointAB;
			Spawn(classname, position);
		}
	}
	static bool CheckState(Actor Self, StateLabel st)
	{
		If(Self.FindState(st,1) && Self.InStateSequence(Self.CurState,Self.ResolveState(st)))
		Return True;
		Return False;
	}
	static state ChangeState(Actor Self,StateLabel st, Bool Force=False)
	{
		If(CheckState(Self,st)) Return Null;
		Else If(Self.FindState(st))
		{
			If(Force)
			Self.SetStateLabel(st);
			Return Self.ResolveState(st);
		}
		Return Null;
	}
	static bool CanBleed(Actor Self)
	{
		if(Self.bNoBlood || Self.bInvulnerable || (Self.bDormant && Self.bIsMonster) || GetDefaultByType(Self.GetBloodType(0)).bNoBlood)
		Return False;
		Return True;
	}
	static Actor SpawnBlood(Actor Self, Vector3 Pos, Double Scale=1.0, bool CheckBleed=True, Int BloodType=0)
	{
		
		Bool Bleed=True;
		If(CheckBleed) Bleed=LMBDLib.CanBleed(Self);
		If(Self && Bleed)
		{
			Actor Blod=Spawn(Self.GetBloodType(BloodType),Pos,ALLOW_REPLACE);
			If(Blod)
			{
				Blod.Translation=Self.BloodTranslation;
				If(Self.GetBloodType(0)=="Blood") //HLBlood
				Blod.A_SetScale(Scale);
			}
			Return Blod;
		}
		Return Null;
		
	}
	static Int HLExplode(actor self, actor inflictor, actor src, int damage=-1, int distance=-1, int flags=XF_HURTSOURCE,int fulldmgdist=0,name dmgtype='Nornmal')
	{
		if(!inflictor) inflictor=self;
		if(!src) src=self;
		int explodado=0;
		if(damage==-1) damage=self.ExplosionDamage;
		if(distance==-1) distance=self.ExplosionRadius;
		if(distance==-1) distance=self.ExplosionDamage; // if dist keeps giving -1, then use expdamage instead.
		Bool HurtSource=true;
		If(self.DontHurtShooter || !(flags & XF_HURTSOURCE)) HurtSource=False;
		for (let it = BlockThingsIterator.Create(self, distance); it.Next();)
		{
			Bool RadiusDmg=1;
			Bool DontHarmSpecies=1;
			If(self && it.thing)
			{
				RadiusDmg=self.bForceRadiusDmg || !it.thing.bNoRadiusDmg;
				DontHarmSpecies=it.thing.GetSpecies()==self.GetSpecies() && self.bDontHarmSpecies;
			}
			Bool Skip=False;
			actor src=self.target;
			if(flags && XF_NOTMISSILE) src=self;
			If(it.thing == src && !HurtSource) Skip=True;
			
			//src.a_log("hurtsource="..hurtsource.." src="..src.GetClassname().." ting="..it.thing.GetClassname().." skip="..skip);
			if (!skip && it.thing && self.Distance3D(it.thing)<=distance+it.thing.radius && self.CheckSight(it.thing) && RadiusDmg && !DontHarmSpecies && it.thing.health>0 && (it.thing.bShootable || it.thing.bVulnerable))
			{
				double dist=self.Distance3D(it.thing)-it.thing.radius-fulldmgdist;
				int dmg;
				If(dist<1)
				dmg=damage;
				Else
				{
					int antidist=int(distance-dist);
					//If(dist<=fulldmgdist) dmg=damage;
					//else
					dmg=damage*antidist/distance;
				}
				Vector3 OldVel=it.thing.Vel;
				double tcenter=it.thing.height/2;
				dmg=it.thing.DamageMobj(inflictor, src, dmg, dmgtype);
				If(!it.thing) Continue;
				Vector2 Dir=LMBDLib.FaceVector(self.pos,it.thing.pos+(0,0,tcenter));
				If(LMBDLib.CanBleed(it.thing) && dmg>0 && !self.bBloodLessImpact)
				{
					Double BDist=it.thing.Radius;
					Vector3 BPos=((Cos(Dir.X)*BDist)*Cos(-Dir.Y),(Sin(Dir.X)*BDist)*Cos(-Dir.Y),Sin(-Dir.Y)*BDist)+it.thing.Pos+(0,0,tcenter);
					it.thing.TraceBleedAngle(dmg,Dir.X+180,-Dir.Y);
					Double DS=Clamp(dmg/30,0.75,1.5);
					LMBDLib.SpawnBlood(it.thing,BPos,DS,false);
				}
				explodado++;
				it.thing.vel=OldVel;
				If(!it.thing.bDontThrust && !self.bNoDamageThrust)
				{
					Double Speed=dmg*25/it.thing.mass*-1;
					Vector3 Belu=((Cos(Dir.X)*Speed/2.)*Cos(-Dir.Y),(Sin(Dir.X)*Speed/2.)*Cos(-Dir.Y),Sin(-Dir.Y)*Speed);
					it.thing.vel+=Belu;
				}
				//self.a_Log("dmg: "..dmg);//.." dist3d: "..int(self.Distance3D(it.thing)).." dist: "..int(dist).." antidist: "..int(antidist).." fulldmgdist: "..fulldmgdist);
			}
		}
		Destructible.GeometryRadiusAttack(Self, inflictor, damage, distance, dmgtype, fulldmgdist); //idk if this works
		return explodado;
	}
	static void FireBullets(Actor Self, Vector2 Spread=(0,0),int numbullets=1, int dmg=3, class<actor>pufftype="BulletPuff", double range=0, /*class<actor>missile="BulletTracer" ,*/Vector3 Offsets=(0,0,0), Vector3 MOffsets=(0,0,32), Vector2 Multiplier=(1,3))
	{
		//A_FireBullets(7,5,7,dmg,flags:1,spawnheight:-4,3);
		If(!Range)
		range=PLAYERMISSILERANGE;
		Spread*=0.5;
		For(int i=0;i<numbullets;i++)
		{
			int dmge=int(dmg*FRandom(Multiplier.X,Multiplier.Y));
			//A_FireBullets(7,5,7,dmg,flags:1);
			Vector2 Dir=(Self.Angle+FRandom(-Spread.X,Spread.X),Self.Pitch+FRandom(-Spread.Y,Spread.Y));
			Actor Puff=Self.LineAttack(Dir.X,Range,Dir.Y,0,'Normal',"BulletPuff",LAF_NORANDOMPUFFZ,null,Offsets.Z,Offsets.X,Offsets.Y); //BlankPuff
			If(Puff)
			{
				LMBDLib.A_SpawnActorLine("HLHitscanBubble",Self.Pos+(RotateVector(MOffsets.XY,Dir.X),MOffsets.Z),Puff.Pos,10);
				/*
				If(Missile)
				{
					Self.SpawnMissileXYZ(Self.Pos+(RotateVector(MOffsets.XY,Dir.X),MOffsets.Z),Puff,Missile,true,Self);
				}
				*/
			}
			Self.LineAttack(Dir.X,Range,Dir.Y,dmge,'Normal',PuffType,LAF_NORANDOMPUFFZ,null,Offsets.Z,Offsets.X,Offsets.Y);
		}
	}
	static bool RandomChance(Int Chance, Int MaxChance=256)
	{
		If(Random(0,MaxChance)<=Chance)
		Return True;
		Return False;
	}
	static Bool V3InFOV(Vector3 Source, Vector3 Dest, Vector2 SrcDir, Vector2 FOV)
	{
		Vector2 Dir=LMBDLib.FaceVector(Dest,Source);
		If(abs(deltaangle(SrcDir.X,Dir.X))<=Fov.X && abs(deltaangle(SrcDir.Y,Dir.Y))<=FOV.Y)
		Return True;
		Return False;
	}
	Static Vector3 RotatedVec(Vector3 Offs=(0,0,0), Double Angle=0,Double Pitch=0,Double Roll=0)
	{
		/*Double Extra=(Offs.X*0.5)*Cos(Pitch);
		Offs.X+=Extra;
		Offs.Y*=0.5;*/
		
		Vector2 SSS=RotateVector((Offs.Y,Offs.Z),Roll);
		Offs.Y=SSS.X;
		Offs.Z=SSS.Y;
		Vector2 R=RotateVector((Offs.X*Cos(-Pitch) + Sin(Pitch)*Offs.Z,Offs.Y),Angle);
		Vector3 SpawnOffs=(R,Offs.Z*Cos(Pitch)  +  Offs.X*Sin(-Pitch));
		Return SpawnOffs;
	}
	static Vector3 Vec3ToDir(Double Speed, Double Angle, Double Pitch)
	{
		Return (
		(Cos(Angle)*Speed)*Cos(Pitch),
		(Sin(Angle)*Speed)*Cos(Pitch),
		Sin(-Pitch)*Speed);
	}
}

Class EffectBase : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOINTERACTION
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+DONTSPLASH
		+THRUACTORS
		+NOTRIGGER
		//-ACTIVATEPCROSS
		//-ACTIVATEIMPACT
		+NOBLOCKMAP
		+NOBLOCKMONST
		+NOTONAUTOMAP
		+CANNOTPUSH
		+ROLLSPRITE
		+INTERPOLATEANGLES
		Radius 0.5;
		Height 1;
		Gravity 0.66;
		Species "VFX";
	}
	States
	{
	Spawn:
		TNT1 A 10;
		Stop;
	}
}

Class LootItemIcon : EffectBase
{
	Default
	{
		RenderStyle "AddShaded";
		Alpha 0.99;
		Scale 0.11;
	}
	States
	{
	Spawn:
		LOOT A -1 Bright;
		Stop;
	}
}

Class PoisonDamageThing : Inventory
{
	Default
	{
		Inventory.Amount 175;
		Inventory.MaxAmount 175;
		Inventory.InterHubAmount 0; //this prevents it from traveling to new maps
		+NODAMAGETHRUST
		+BLOODLESSIMPACT //[AA] This flag doesn't do anything on inventory objects
		Damage 5;
		ReactionTime 30;
	}
	Override Void Tick()
	{
		Super.Tick();
		If(Level.isFrozen()) Return;  //GlobalFreeze || Level.Frozen			 Level.isFrozen()
		If(Owner)
		{
			If(Target && (Owner.IsFriend(Target) && Owner!=Target)) Destroy();
			Amount--;
			Special1++;
			/*
			If(Special1%ReactionTime==ReactionTime-1)
			{
				// [AA] This variable isn't defined anywhere, so I had to
				// comment it out for testing purposes.
				// Also it could be simplified to one line: bPAINLESS = hl_poisonhurt
				
				If(!hl_poisonhurt)
				bPainLess=True;
				Else
				bPainLess=False;
				Actor Src=Self;
				If(Target) Src=Target;
				LMBDLib.SpawnBlood(Owner,Owner.Pos+(RotateVector((Owner.Radius,0),Owner.AngleTo(Src,true)),Owner.Height/2),Clamp(damage/20,0.75,1.5));
				Owner.DamageMobj(Self,Src,Damage,DamageType);
			}
			*/
			If(Amount<1 || Owner && Owner.Health<1 || Owner Is "Shell") //Spore_Ammo				?
			Destroy();
		}
	}
}

/////////////////////////////////////////////////////////////Daul Grenade

Class Daul_Grenade : CustomInventory
{
	Ice_Bomb		IB_control;
	Flame_Belch		FB_control;
	
	bool LeftFire,RightFire		,IBFire,FBFire,		LCODgrenade,LCOflame,		RCODgrenade,RCOIce;
	int CooldownTimerGrenade;
	
	override void DoEffect()
	{
	
	if (!IB_control)
	{
	  IB_control = Ice_Bomb(owner.FindInventory("Ice_Bomb"));
	}
	RightFire = (IB_control && IB_control.RightFire);
	RCOIce = (IB_control && IB_control.RCOIce);
	
	if (!FB_Control)
	{
	  FB_Control = Flame_Belch(owner.FindInventory("Flame_Belch"));
	}
	LeftFire = (FB_Control && FB_Control.LeftFire); //will be set to true if FB_Control is not null and its LeftFire bool is true
	LCODgrenade = (FB_Control && FB_Control.LCODgrenade);
			
	
	
	
	
	super.DoEffect();
		if (CooldownTimerGrenade < 149)
		{
		CooldownTimerGrenade++;
		}
		
		if (CooldownTimerGrenade == 75)
		{
		Owner.A_StartSound("EquipmentGrenadeLauncherDoneCharging",0,0,1);
		}
		
		if (CooldownTimerGrenade == 149)
		{
		Owner.A_StartSound("EquipmentGrenadeLauncherDoneCharging",0,0,1);
			
			CooldownTimerGrenade = 150;
		}
	}
	
	Default{
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
	}
	
	States 
	{
	Use:
		TNT1 A 0 
		{
		if (invoker.CooldownTimerGrenade < 75)
		{
			A_StartSound("EquipmentGrenadeLauncherCantUse",0,0,1);
		}
		if (invoker.CooldownTimerGrenade >= 75)
		{
				invoker.CooldownTimerGrenade = invoker.CooldownTimerGrenade - 75; //75
				A_Overlay(-200,"LeftCannon");
				A_Overlay(-201,"RightCannon");
		}
			
	}
fail;
	
	Feel:
		TNT1 A 0 A_AlertMonsters;
		TNT1 A 0 A_QuakeEx(1,1,1,4,0,100,"*");
		Stop;
	
	
	
	
	
	LeftCannon:
		TNT1 A 0 A_Jumpif((invoker.LeftFire == true),"LeftLoop");
		TNT1 A 0 {invoker.FBFire = True;}
		
		TNT1 A 2 A_OverlayOffset(-200,0,32,WOF_INTERPOLATE);
		TNT1 A 0 A_StartSound("EquipmentMoveIn",0,CHANF_OVERLAP,.7);
		XSDL A 1 A_OverlayOffset(-200,-50,50,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-200,-25,40,WOF_INTERPOLATE);
		
	LeftCannonFire:
		TNT1 A 0 A_OverlayOffset(-200,-25,40,WOF_INTERPOLATE);
		
		TNT1 A 0 A_Jumpif((invoker.LeftFire == true),"LOverlaySkip");
		TNT1 A 0 A_Overlay(-203,"*");
	LOverlaySkip:
		
		TNT1 A 0 A_Overlay(-300,"Feel");
		TNT1 A 0 A_StartSound("EquipmentGrenadeLauncher",0,CHANF_OVERLAP,.7);
		TNT1 A 0 A_FireProjectile("Shoulder_Grenade",0,false,-5,10);
		XSDL B 1 A_OverlayOffset(-200,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDL C 1 A_OverlayOffset(-200,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDL D 1 A_OverlayOffset(-200,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDL E 1 A_OverlayOffset(-200,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 {invoker.FBFire = False;}
		TNT1 A 0 A_StartSound("EquipmentMoveOut",0,CHANF_OVERLAP,.7);
		XSDL A 1 A_OverlayOffset(-200,-5,32,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-200,-13,34,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-200,-25,40,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-200,-40,50,WOF_INTERPOLATE);
		Stop;
	LeftLoop:
		TNT1 A 1;
		TNT1 A 0 A_Jumpif((invoker.LeftFire == true),"LeftLoop");
		Goto LeftCannonFire;
		
		
		
		
		
	
	RightCannon:
		TNT1 A 0 A_Jumpif((invoker.RightFire == true),"RightLoop");
		TNT1 A 0 {invoker.IBFire = True;}
		TNT1 A 0 {invoker.LCOflame = false;}
	
		TNT1 A 0 A_OverlayOffset(-201,0,32,WOF_INTERPOLATE);
		TNT1 A 0 A_StartSound("EquipmentMoveIn",0,CHANF_OVERLAP,.7);
		XSDR A 1 A_OverlayOffset(-201,50,50,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-201,25,40,WOF_INTERPOLATE);
		
	RightCannonFire:
		TNT1 A 0 A_OverlayOffset(-201,25,40,WOF_INTERPOLATE);
		
		TNT1 A 0 A_Jumpif((invoker.RightFire == true),"ROverlaySkip");
		TNT1 A 0 A_Overlay(-204,"*");
	ROverlaySkip:
		
		TNT1 A 0 A_Overlay(-300,"Feel");
		TNT1 A 0 A_StartSound("EquipmentGrenadeLauncher",0,CHANF_OVERLAP,.7);
		TNT1 A 0 A_FireProjectile("Shoulder_Grenade",0,false,5,10);
		XSDR B 1 A_OverlayOffset(-201,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR C 1 A_OverlayOffset(-201,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR D 1 A_OverlayOffset(-201,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR E 1 A_OverlayOffset(-201,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 {invoker.IBFire = False;}
		TNT1 A 0 A_StartSound("EquipmentMoveOut",0,CHANF_OVERLAP,.7);
		XSDR A 1 A_OverlayOffset(-201,5,32,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-201,13,34,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-201,25,40,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-201,40,50,WOF_INTERPOLATE);
		Stop;
	RightLoop:
		TNT1 A 1;
		TNT1 A 0 A_Jumpif((invoker.RightFire == true),"RightLoop");
		TNT1 A 0 {invoker.LCOflame = True;}
		Goto RightCannonFire;
   }
}

class Shoulder_Grenade : Actor
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 50;
		Damage 100;
		DamageType "Explosive";
		+MISSILE
		+RANDOMIZE
		//+DEHEXPLOSION
		+FORCEXYBILLBOARD
		-NOGRAVITY
		+NODAMAGETHRUST
		
		
		bouncefactor 0.35; //.5
		wallbouncefactor 0.3; //.4
		bouncecount 4; //5
		bouncetype "Doom";
	}
	States
	{
	Spawn:
		XSDG A 5 A_SpawnItemEx("RocketSmokeTrail",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		Loop;
		
	Bounce:
	Death:
		TNT1 A 0 A_StartSound("EquipmentGrenadeLauncherTimer",0,0,1);
		XSDG A 20;
	XDeath:
		TNT1 A 0 A_SpawnItemEx("RocketSFX");
		TNT1 A 0 A_SpawnItemEx("Shoulder_Grenade_FX");
		
		TNT1 A 0 A_Explode(-1,-1,0);
		TNT1 A 1;
		Stop;
	}
}

////////////////////////Flame Belch

Class Flame_Belch : CustomInventory
{
	Daul_Grenade		DG_control;
	
	int CooldownTimerFlameBelch;
	
	bool LeftFire,FBFire,	LCODgrenade,LCOflame;

	override void DoEffect()
	{
	
	if (!DG_control)
		{
		  DG_control = Daul_Grenade(owner.FindInventory("Daul_Grenade"));
		}
		FBFire = (DG_control && DG_control.FBFire);
		LCOflame = (DG_control && DG_control.LCOflame);
	
	
	super.DoEffect();
		if (CooldownTimerFlameBelch < 200)
		{
		CooldownTimerFlameBelch++;
		}
		
		if (CooldownTimerFlameBelch == 200)
		{
		Owner.A_StartSound("EquipmentFlameBelchReady",0,0,1);
			CooldownTimerFlameBelch = 201;
		}
	}
	
	
	Default{
	Inventory.Amount 1;
	Inventory.MaxAmount 1;
	+INVENTORY.UNDROPPABLE
	}
	
	States 
	{

	Use:
		TNT1 A 0 
		{
		if (invoker.CooldownTimerFlameBelch < 200)
		{
			A_StartSound("EquipmentFlameBelchNotReady",0,0,1);
		}
		if (invoker.CooldownTimerFlameBelch == 201)
		{
			A_Overlay(-203,"LeftCannon");
			invoker.CooldownTimerFlameBelch = 0; //200
		}
			
	}
fail;
	
	
	Feel:
		TNT1 A 0 A_QuakeEx(1,1,1,30,0,100,"*");
		TNT1 A 0 A_AlertMonsters;
		Stop;
	
	LeftCannon:	
		TNT1 A 0 A_Jumpif((invoker.FBFire == true),"LeftLoop");
		TNT1 A 0 {invoker.LeftFire = True;}
		TNT1 A 0 {invoker.LCODgrenade = False;}
		
		TNT1 A 0 A_OverlayOffset(-203,0,32,WOF_INTERPOLATE);
		TNT1 A 0 A_StartSound("EquipmentMoveIn",0,CHANF_OVERLAP,.7);
		XSDL A 1 A_OverlayOffset(-203,-50,50,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-203,-25,40,WOF_INTERPOLATE);
		
	LeftCannonFire:
		TNT1 A 0 A_OverlayOffset(-203,-25,40,WOF_INTERPOLATE);
		
		TNT1 A 0 A_Jumpif((invoker.LCOflame == true),"Overlayskip");
		TNT1 A 0 A_Overlay(-200,"*");
	Overlayskip:
		
		TNT1 A 0 A_Overlay(-300,"Feel");
		TNT1 A 0 A_StartSound("EquipmentFlameBelch",0,CHANF_OVERLAP,.7);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL B 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		TNT1 A 0 A_FireProjectile("Flame_Belch_Fire",0,false,-10,10);
		XSDL C 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDL D 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDL E 1 A_OverlayOffset(-203,random(-1,1),random(31,33),WOF_INTERPOLATE);
		
		TNT1 A 0 {invoker.LeftFire = False;}
		
		TNT1 A 0 A_StartSound("EquipmentMoveOut",0,CHANF_OVERLAP,.7);
		XSDL A 1 A_OverlayOffset(-203,-5,32,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-203,-13,34,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-203,-25,40,WOF_INTERPOLATE);
		XSDL A 1 A_OverlayOffset(-203,-40,50,WOF_INTERPOLATE);
		Stop;
	LeftLoop:
		TNT1 A 1;
		TNT1 A 0 A_Jumpif((invoker.FBFire == true),"LeftLoop");
		TNT1 A 0 {invoker.LCODgrenade = True;}
		Goto LeftCannonFire;
   }
}

Class Flame_Belch_Fire : Actor
{
	Default
	{
  RenderStyle "Add";
  Alpha 0.4;
  Speed 75;
  PROJECTILE;
  Radius 10;
  Height 5;
  Damage 20;
  +RIPPER
  +NOGRAVITY
  +DONTSPLASH
  +NOTELEPORT
  +FORCEXYBILLBOARD
  }
  
  
  
  	Override Void Tick() { Super.Tick(); If(WaterLevel) Destroy(); }
	Override Bool CanCollideWith(Actor other, bool passive)
	{
		If(!passive && !other.bShootable) return false;
		return true;
	}
	Array <Actor> UwUr;
	Override int SpecialMissileHit (Actor victim)
	{
		If(Victim.bShootable && Victim.Health>0 && (Target && Victim!=Target))
		{
			Bool Recognized=false;
			Int Size=UwUr.Size();
			If(Size>0)
			For(int i=0;i<Size;i++)
			{
				If(UwUr[i]==Victim)
				{
					Recognized=True;
					Return 1;
				}
			}
			UwUr.Push(Victim);
			Int dmg=Damage;
			Int FinalDamage=Victim.DamageMobj(Self,Target,Damage,DamageType);

			If(Victim.Health>0)
			{
				Let Poison=Inventory(Victim.FindInventory("DEOnFire"));
				If(!Poison || Poison && Poison.Amount<=Poison.MaxAmount*0.75)
				{
					If(Poison) Poison.Destroy();
					Victim.A_GiveInventory("DEOnFire",175);
					Let Poison=Inventory(Victim.FindInventory("DEOnFire"));
					//Let Poison=Inventory(Spawn("DEOnFire",pos,ALLOW_REPLACE));
					If(Poison)
					{
						Poison.Owner=Victim;
						//Poison.Amount=Poison.MaxAmount=35*10;
						//Poison.ReactionTime=18*2;
						Poison.Target=Target;
					}
				}
			}
		}
		Return 1;
	}
  
  
  
  States
  {
	Spawn:
		FRFX ABCDEFGH 1 Bright A_SpawnItemEx("Flame_Belch_Fire_FX",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		TNT1 A 1 A_SpawnItemEx("Flame_Belch_Fire_Add",0,0,0,frandom(-10,10),frandom(-10,10),frandom(-10,10));
		TNT1 A 1;
		Stop;
	
	XDeath:
	Death:
		TNT1 A 1 A_SpawnItemEx("Flame_Belch_Fire_Add",0,0,0,frandom(-10,10),frandom(-10,10),frandom(-10,10));
		Stop;
  }
}

Class Flame_Belch_Fire_Add : Actor
{
	Default
	{
  RenderStyle "Add";
  Alpha 0.4;
  Speed 2;
  PROJECTILE;
  
  +NOGRAVITY
  +DONTSPLASH
  +NOTELEPORT
  +FORCEXYBILLBOARD
  }
  States
  {
  Spawn:
    FRFX IJKLMNOP 1 Bright A_SpawnItemEx("Flame_Belch_Fire_FX",0,0,0,frandom(-4,4),frandom(-4,4),frandom(-4,4));
    Stop;
  }
}

Class Flame_Belch_Fire_FX : Actor
{
	Default
	{
  RenderStyle "Add";
  Alpha 0.4;
  Scale 0.1;
  VSpeed 1;
  
  +NOGRAVITY
  +DONTSPLASH
  +NOTELEPORT
  +FORCEXYBILLBOARD
  }
  States
  {
  Spawn:
	TNT1 A 0 {A_SetRoll(Random(0,359)); A_SetPitch(Random(-90,90)); A_SetAngle(Random(0,359));}
    FLMF ABCDE 1 Bright;
	FLMF FABCDEF 1 Bright {A_SetScale(Scale.X+0.01); A_Fadeout(0.05);}
    Stop;
  }
}

Class DEOnFire : PoisonDamageThing
{
	Default
	{
		Inventory.Amount 175;
		Inventory.MaxAmount 175;
		Damage 0;
		ReactionTime 15;
		+PAINLESS
	}
	Actor Light;
	Override Void PostBeginPlay()
	{
		Inventory.PostBeginPlay();
		If(GetAge()>1) Return;
		If(!Owner) Return;
		Light=Spawn("PointLightFlickerAttenuated");
		Light.Args[0]=255;
		Light.Args[1]=64;
		Light.Args[2]=0;
		Light.Args[3]=Int(Owner.Radius);
		Light.Args[4]=Int(Owner.Radius+10);
	}
	Override Void OnDestroy()
	{
		If(Light) Light.Destroy();
		Super.OnDestroy();
	}
	Override Void Tick()
	{
		Inventory.Tick();
		If(IsFrozen()) Return;
		If(Owner)
		{
			If(Light) Light.SetOrigin(Owner.Pos+(0,0,Owner.Height/2),1);
			If(Target && (Owner.IsFriend(Target) && Owner!=Target || Target.waterlevel)) Destroy();
			Amount--;
			Special1++;
			If(Special1%ReactionTime==ReactionTime-1)
			{
				Actor Yea;
				Bool a;
				If(yea)
				Yea.Target=Target;
				special2++;
			}
			If(Owner && Special1%3==0)
			Owner.A_SpawnItemEx("Flame_Belch_Fire_FX",Owner.Radius,0,FRandom(0,Owner.Height),zvel:FRandom(0.5,1),FRandom(1,360),0,96);
			If(Amount<1 || Owner && Owner.Health<1 || Owner Is "Shell" || special2>=10) //Spore_Ammo			?
			Destroy();
		}
	}
	Int DmgRecieved;
	Int DmgScalation;
	Int BonusDrops;
	Override Void AbsorbDamage(int damage, name damagetype, out int newdamage, actor inflictor,actor source, int flags)
	{
		
		dmgrecieved+=newdamage;
		While(dmgrecieved>=25 && BonusDrops<5)
		{
			dmgrecieved-=25;
			If(dmgrecieved<0) dmgrecieved=0;
			BonusDrops++;
			Actor Yea; Bool a;
			If(yea) Yea.Target=Target;
		}
	}
}

////////////////////////Ice Bomb

Class Ice_Bomb : CustomInventory
{
	Daul_Grenade DG_control;
	
	int CooldownTimerIce;
	
	bool RightFire,IBFire,		RCODgrenade,RCOIce;
	
	override void DoEffect()
	{
	
	if (!DG_control)
		{
		  DG_control = Daul_Grenade(owner.FindInventory("Daul_Grenade"));
		}
		IBFire = (DG_control && DG_control.IBFire); //will be set to true if DG_control is not null and its LeftFire bool is true
		RCOIce = (DG_control && DG_control.RCOIce);
	
	super.DoEffect();
		if (CooldownTimerIce < 200)
		{
		CooldownTimerIce++;
		}
		
		if (CooldownTimerIce == 200)
		{
		Owner.A_StartSound("EquipmentIceBombReload",0,0,1);
			CooldownTimerIce = 201;
		}
	}
	
	Default{
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
	}
	
	States 
	{

	Use:
		TNT1 A 0 
		{
		if (invoker.CooldownTimerIce < 200)
		{
			A_StartSound("EquipmentIceBombFail",0,CHANF_OVERLAP,1);
		}
		if (invoker.CooldownTimerIce == 201)
		{
				A_Overlay(-204,"RightCannon");
				invoker.CooldownTimerIce = 0; //200
		}
			
	}
	fail;
	
	
	Feel:
		TNT1 A 0 A_QuakeEx(1,1,1,4,0,100,"*");
		TNT1 A 0 A_AlertMonsters;
		Stop;

	RightCannon:
		TNT1 A 0 A_Jumpif((invoker.IBFire == true),"RightLoop");
		TNT1 A 0 {invoker.RightFire = True;}
		TNT1 A 0 {invoker.RCODgrenade = False;}
	
		TNT1 A 0 A_OverlayOffset(-204,0,32,WOF_INTERPOLATE);
		TNT1 A 0 A_StartSound("EquipmentMoveIn",0,CHANF_OVERLAP,.7);
		XSDR A 1 A_OverlayOffset(-204,50,50,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-204,25,40,WOF_INTERPOLATE);
		
	RightCannonFire:
		TNT1 A 0 A_OverlayOffset(-204,25,40,WOF_INTERPOLATE);
		
		TNT1 A 0 A_Jumpif((invoker.RCOIce == true),"OverlaySkip");
		TNT1 A 0 A_Overlay(-201,"*");
	OverlaySkip:
		
		TNT1 A 0 A_Overlay(-300,"Feel");
		TNT1 A 0 A_StartSound("EquipmentIceBombFire",0,CHANF_OVERLAP,.7);
		TNT1 A 0 A_FireProjectile("Ice_Grenade",0,false,5,10);
		XSDR B 1 A_OverlayOffset(-204,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR C 1 A_OverlayOffset(-204,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR D 1 A_OverlayOffset(-204,random(-1,1),random(31,33),WOF_INTERPOLATE);
		XSDR E 1 A_OverlayOffset(-204,random(-1,1),random(31,33),WOF_INTERPOLATE);
		
		TNT1 A 0 {invoker.RightFire = False;}
		
		TNT1 A 0 A_StartSound("EquipmentMoveOut",0,CHANF_OVERLAP,.7);
		XSDR A 1 A_OverlayOffset(-204,5,32,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-204,13,34,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-204,25,40,WOF_INTERPOLATE);
		XSDR A 1 A_OverlayOffset(-204,40,50,WOF_INTERPOLATE);
		Stop;
	RightLoop:
		TNT1 A 1;
		TNT1 A 0 A_Jumpif((invoker.IBFire == true),"RightLoop");
		TNT1 A 0 {invoker.RCODgrenade = True;}
		Goto RightCannonFire;
   }
}

class Ice_Grenade : Actor
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 50;
		Damage 100;
		DamageType "Ice";
		+MISSILE
		+RANDOMIZE
		+FORCEXYBILLBOARD
		-NOGRAVITY
		+NODAMAGETHRUST
	}
	
	
	
	
	
	
	Actor Lite;
	Override Void OnDestroy()
	{
		If(Lite)
		Lite.Destroy();
		Super.OnDestroy();
	}
	
	Override Void Tick()
	{
		If(!Lite)
		{
			Lite=Spawn("PointLightAttenuated",Pos);
			Lite.Target=Self;
			Lite.Args[0]=128;
			Lite.Args[1]=128;
			Lite.Args[2]=255;
			Lite.Args[3]=52;
		}
		Else
		Lite.SetOrigin(Self.Pos,true);
		super.tick();
		If(!A_CheckFloor("Null"))
		{
			Angle+=10;
			Pitch-=20;
		}
		Actor Glow=Spawn("ShockBeamGlow",Pos);
		If(Glow)
		{
			Glow.Prev=Prev;
			Glow.Frame=1;
			Glow.A_SetScale(0.66);
			Glow.SetShade("AAAAFF");
			Glow.A_SetRenderStyle(0.99,STYLE_ADDSHADED);
			Glow.bNoTimeFreeze=True;
		}
		If(IsFrozen()) Return;
		If(Level.Time%2==0)
		{
			BOol a;
			Actor b;
			[a,b]=A_SpawnItemEx("Ice_Grenade_Smoke",0,0,0,FRandom(0,1),0,FRandom(0,1),FRandom(0,359),0);
			If(b)
			B.SetShade("DDDDFF");
		}
	}
	
	
	
	
	
	
	
	
	States
	{
	Spawn:
		ICBB A 5 A_SpawnItemEx("Ice_Grenade_Smoke",0,0,0,frandom(-2,2),frandom(-2,2),frandom(-2,2));
		Loop;
		
		Bounce:
		Death:
		TNT1 A 0 A_StartSound("EquipmentIceExplodeAdd",0,0,1);
		TNT1 A 0 A_SpawnItemEx("Ice_Grenade_FX");
		//TNT1 A 0 A_Explode(-1,-1,0);
		TNT1 A 20		{
			If(Lite)
			Lite.Destroy();
			bForcePain=True;
			Int ExpDmg=200;
			A_Explode(1,192,0,0,192);
			A_QuakeEx(1,1,1,25,0,1024,"",QF_SCALEDOWN,falloff:192);
			Actor Explo=Spawn("EquipmentIceBombSphere",Pos+(0,0,20),ALLOW_REPLACE);
			Explo.Scale*=1.5;
			SetShade("AAAAFF");
			//For(Int i=0;i<20;i++)
			//A_SpawnItemEx("CGShieldExplosionPuff",0,0,0,Frandom(0,20),0,FRandom(-20,20),FRandom(1,360),SXF_TRANSFERSTENCILCOL);
			//For(Int i=0;i<20;i++)
			//A_SpawnItemEx("IceChunk",0,0,0,Frandom(0,5),0,FRandom(0,5),FRandom(1,360));
			//A_StartSound("Explosion/Back",0,CHANF_OVERLAP);
			//A_StartSound("Equipment/IceBombExplode",0,CHANF_OVERLAP);
		}
		Stop;
	}
	Override Int DoSpecialDamage(Actor target, int damage, name damagetype)
	{
		If(Target.bIsMonster)
		Target.A_GiveInventory("IceBombFreezeme");
		Inventory Yea=Target.FindInventory("IceBombFreezeme");
		If(Yea)
		Yea.Target=Self.Target;
		Return Super.DoSpecialDamage(target,damage,damagetype);
	}
}

Class EquipmentIceBombSphere : EffectBase
{
	Default { Translation "Ice"; }
	States
	{
	Spawn:
		TNT1 A 2;
		NULL AAAAAAAA 1 Bright A_SetScale(Scale.X*1.2);
		NULL A 1 Bright A_SetScale(Scale.X*1.1);
		NULL A 1 Bright { A_FadeOut(0.33); A_SetScale(Scale.X*1.05); }
		NULL A 1 Bright { A_FadeOut(0.33); A_SetScale(Scale.X*1.025); }
		NULL A 1 Bright { A_FadeOut(0.33); A_SetScale(Scale.X*1.0125); }
		Stop;
	}
}

Class IceBombFreezeme : StunMeDaddy
{
	Default { Powerup.Duration -3; }
	Override Void Tick()
	{
		Super.Tick();
		If(Owner)
		{
			SetOrigin(Owner.pos,1);
			
			If(Level.Time%3==0)
			A_SpawnItemEx("Ice_Grenade_Smoke",Owner.Radius,0,FRandom(0,Owner.Height),zvel:FRandom(0.5,1),FRandom(1,360),frandom(0,3),96);
			
			If(Level.Time%70==0)
			A_StartSound("EquipmentIceAmbient",0,CHANF_OVERLAP);
		}
	}
	Override Void InitEffect()
	{
		LastEnemy=Owner;
		translation=owner.translation;
		Owner.A_SetTranslation("Ice");
		Super.InitEffect();
	}
	Override Void EndEffect()
	{
		A_StartSound("EquipmentIceMonsterBreak",0,CHANF_OVERLAP);
		If(Owner && Owner.Health>1)
		{
			owner.translation=translation;
			For(Int i=0;i<Owner.Radius;i+=2)
			Owner.A_SpawnItemEx("IceChunk",FRandom(0,Owner.Radius),0,FRandom(0,Owner.Height),FRandom(0,2),0,FRandom(0,2),FRandom(1,360));
		}
	}
	Override Void OwnerDied()
	{
		//A_Log("Is die");
		If(LastEnemy)
		{
			For(Int i=0;i<LastEnemy.Radius;i+=2)
			LastEnemy.A_SpawnItemEx("IceChunk",FRandom(0,Owner.Radius),0,FRandom(0,Owner.Default.Height),FRandom(0,2),0,FRandom(0,2),FRandom(1,360));
			LastEnemy.A_Fall();
			LastEnemy.SetState(LastEnemy.FindState("GenericFreezeDeath")+1);
			LastEnemy.bInvisible=True;
			Actor E=Spawn("asdDeleteMe");
			E.Target=LastEnemy;
		}
		Super.OwnerDied();
	}
	Override Void AbsorbDamage(int damage, name damagetype, out int newdamage, actor inflictor,actor source, int flags)
	{
		int dmg=newdamage;
		dmgrecieved+=dmg;
		h();
		NewDamage*=Int(1.25);
	}
	Int DmgRecieved;
	Int DmgScalation;
	Int BonusDrops;
	Void h()
	{
		While(dmgrecieved>=20 && BonusDrops<3)
		{
			dmgrecieved-=20;
			If(dmgrecieved<0) dmgrecieved=0;
			BonusDrops++;
			Actor Yea; Bool a;
			If(yea) Yea.Target=Target;
		}
	}
}

Class asdDeleteMe : Actor
{
	Default { +NOTIMEFREEZE }
	States
	{
	Spawn:
		TNT1 A 3 Nodelay;
		TNT1 A 0 { If(Target) { Target.A_StopAllSounds(); Target.Destroy(); } }
		Stop;
	}
}

//Footsteps (by TheZombieKiller and Agent_Ash)
class WoomyFootsteps : Actor
{
	PlayerPawn toFollow;
	PlayerInfo fplayer;
	protected int updateTics;
	protected transient CVar f_enabled_cache;	
	protected transient CVar f_vol_cache;
	protected transient CVar f_delay_cache;
	protected bool f_enabled;	
	protected double f_vol;
	protected double f_delay;
	
	Default { +NOINTERACTION }
	
	//attach PlayerPawn, load the texture/sound associated tables.
	void Init(PlayerPawn attached_player) { toFollow = attached_player; }

	override void Tick()
	{
		updateTics--;
		if(!toFollow) { destroy(); return; }
		//0) do nothing until updateTics is below 0
		if(updateTics > 0) return;
		//Cache cvars:
		if(f_enabled_cache == null) f_enabled_cache = CVar.GetCVar('evpcv_fs_enabled',fplayer);
		if(f_vol_cache == null) f_vol_cache = CVar.GetCVar('evpcv_fs_volume_mul',fplayer);
		if(f_delay_cache == null) f_delay_cache = CVar.GetCVar('evpcv_fs_delay_mul',fplayer);
		f_enabled = f_enabled_cache.GetBool();
		f_vol = f_vol_cache.GetFloat();
		f_delay = f_delay_cache.GetFloat();
		//1) Update the Footstep actor to follow Player.
		SetOrigin(toFollow.pos, false);
		floorz = toFollow.floorz;
		double playerVel2D = sqrt(toFollow.vel.x * toFollow.vel.x + toFollow.vel.y * toFollow.vel.y);
		//2) Only play footsteps when on ground, and if the player is moving fast enough.
		if(f_enabled &&(playerVel2D > 0.1)&&(toFollow.pos.z - toFollow.floorz <= 0))
		{			
			sound stepsound;			
			//current floor texture for the player:
			name floortex = name(Texman.GetName(toFollow.floorpic));
			//no sound if steppin on sky
			if(floorpic == skyflatnum) stepsound = "none";
			else stepsound = GetFlatSound(Texman.GetName(toFollow.floorpic));
			//sound volume is amplified by speed.
			double soundVolume = f_vol * playerVel2D * 0.12; //multiplied by 0.12 because raw value is too high to be used as volume
			//play the sound if it's non-null
			if(stepsound != "none") toFollow.A_StartSound(stepsound,CHAN_AUTO,CHANF_LOCAL|CHANF_UI,volume:soundVolume);
			//delay CVAR value is inverted, where 1.0 is default, higher means more frequent, smaller means less frequent
			double dmul = (2.1 - Clamp(f_delay,0.1,2));
			updateTics = (gameinfo.normforwardmove[0] - playerVel2D) * dmul;
		}
		else updateTics = 2;
		// no need to poll for change too often
	}
	
	// a totally ugly check for texture name:
	sound GetFlatSound(name texname)
	{
		//first check the all flat names array
		bool inlist = false;
		for(int i = 0; i < FLATS_NAMES.Size(); i++) 
		{ if(FLATS_NAMES[i] == texname) { inlist = true; break; } }
		// and return default sound if not found
		if(!inlist) return "step_default";
		//if found, check against each array with the names of differently sounding floors
		for(int i = 0; i < FLATS_WATER.Size(); i++) { if(FLATS_WATER[i] == texname) return "step_water"; }
		for(int i = 0; i < FLATS_SLIME.Size(); i++) { if(FLATS_SLIME[i] == texname) return "step_slime"; }
		for(int i = 0; i < FLATS_SLIMY.Size(); i++) { if(FLATS_SLIMY[i] == texname) return "step_slimy"; }
		for(int i = 0; i < FLATS_LAVA.Size(); i++) { if(FLATS_LAVA[i] == texname) return "step_lava"; }
		for(int i = 0; i < FLATS_ROCK.Size(); i++) { if(FLATS_ROCK[i] == texname) return "step_rock"; }
		for(int i = 0; i < FLATS_WOOD.Size(); i++) { if(FLATS_WOOD[i] == texname) return "step_wood"; }
		for(int i = 0; i < FLATS_TILEA.Size(); i++) { if(FLATS_TILEA[i] == texname) return "step_tilea"; }
		for(int i = 0; i < FLATS_TILEB.Size(); i++) { if(FLATS_TILEB[i] == texname) return "step_tileb"; }
		for(int i = 0; i < FLATS_HARD.Size(); i++) { if(FLATS_HARD[i] == texname) return "step_hard"; }
		for(int i = 0; i < FLATS_CARPET.Size(); i++) { if(FLATS_CARPET[i] == texname) return "step_carpet"; }
		for(int i = 0; i < FLATS_METALA.Size(); i++) { if(FLATS_METALA[i] == texname) return "step_metala"; }
		for(int i = 0; i < FLATS_METALB.Size(); i++) { if(FLATS_METALB[i] == texname) return "step_metalb"; }
		for(int i = 0; i < FLATS_DIRT.Size(); i++) { if(FLATS_DIRT[i] == texname) return "step_dirt"; }
		for(int i = 0; i < FLATS_GRAVEL.Size(); i++) { if(FLATS_GRAVEL[i] == texname) return "step_gravel"; }
		for(int i = 0; i < FLATS_SNOW.Size(); i++) { if(FLATS_SNOW[i] == texname) return "step_snow"; }
		return "step_default";
	}
	//The texture arrays are in Footsteps.zsc cuz the amount of textures is ridiculous
}

class WoomyFootstepsInit : EventHandler
{
    override void PlayerEntered(PlayerEvent e)
	{
        let steps = WoomyFootsteps(Actor.Spawn("WoomyFootsteps"));
		if(steps)
		{
			steps.Init(players[e.playerNumber].mo);
			steps.fplayer = players[e.playerNumber];
		}
	}
}

extend class WoomyFootsteps
{
	static const name FLATS_NAMES[] =
	{
		"FWATER1","FWATER2","FWATER3","FWATER4",
		"FLOOR0_1","FLOOR0_3","FLOOR1_7","FLOOR4_1","FLOOR4_5","FLOOR4_6",
		"TLITE6_1","TLITE6_5","CEIL3_1","CEIL3_2","CEIL4_2","CEIL4_3","CEIL5_1",
		"FLAT2","FLAT5","FLAT18",
		"FLOOR0_2","FLOOR0_5","FLOOR0_7",
		"FLAT5_3","CRATOP1","CRATOP2",
		"FLAT9","FLAT17","FLAT19",
		"COMP01","GRNLITE1","FLOOR1_1","FLAT14","FLAT5_5","FLOOR1_6",
		"CEIL4_1","GRASS1","GRASS2","RROCK16","RROCK19",
		"FLOOR6_1","FLOOR6_2","FLAT10",
		"MFLR8_3","MFLR8_4","RROCK17","RROCK18",
		"FLOOR0_6","FLOOR4_8","FLOOR5_1","FLOOR5_2","FLOOR5_3","FLOOR5_4",
		"TLITE6_4","TLITE6_6","FLOOR7_1","MFLR8_1","CEIL3_5",
		"CEIL5_2","CEIL3_6","FLAT8",
		"SLIME13","STEP1","STEP2",
		"GATE1","GATE2","GATE3",
		"CEIL1_2","CEIL1_3","SLIME14","SLIME15","SLIME16",
		"FLAT22","FLAT23","CONS1_1","CONS1_5","CONS1_7",
		"GATE4","FLAT4","FLAT1","FLAT5_4",
		"MFLR8_2","FLAT1_1","FLAT1_2","FLAT1_3","FLAT5_7","FLAT5_8",
		"GRNROCK","RROCK01","RROCK02","RROCK03","RROCK04","RROCK05","RROCK06","RROCK07","RROCK08",
		"RROCK09","RROCK10","RROCK11","RROCK12","RROCK13","RROCK14","RROCK15","RROCK20",
		"SLIME09","SLIME10","SLIME11","SLIME12","FLAT5_6","FLOOR3_3","FLAT20",
		"CEIL3_3","CEIL3_4","FLAT3","FLOOR7_2",
		"DEM1_1","DEM1_2","DEM1_3","DEM1_4","DEM1_5","DEM1_6",
		"CEIL1_1","FLAT5_1","FLAT5_2",
		"NUKAGE1","NUKAGE2","NUKAGE3","BLOOD1","BLOOD2","BLOOD3","SLIME01","SLIME02","SLIME03",
		"SLIME04","SLIME05","SLIME06","SLIME07","SLIME08",
		"SFLR6_1","SFLR6_4","SFLR7_1","SFLR7_4","LAVA1","LAVA2","LAVA3","LAVA4","F_SKY1",
		"ET_WFL","ET_BFL","ET_LFL","ET_AFL","ET_SFL1","ET_SFL2","CC_MFF",
		//Ancient Aliens
		"GRAYSLM1","GRAYSLM2","GRAYSLM3","GRAYSLM4",
		"PURPW1","PURPW2","PURPW3","PURPW4","PLOOD1","PLOOD2","PLOOD3",
		"ZO1_01","ZO1_02","ZO1_03","ZO1_99","MLAVA1","MLAVA2","MLAVA3","MLAVA4",
		//BTSX
		"FWATER02","FWATER03","FWATER04","FWATER05","FWATER06","FWATER07","FWATER08","FWATER09",
		"FWATER10","FWATER11","FWATER12","FWATER13","FWATER14","FWATER15","FWATER16","FWATER17","FWATER18","FWATER19",
		"FWATER20","FWATER21","FWATER22","FWATER23","FWATER24","FWATER25","FWATER26","FWATER27","FWATER28","FWATER29","FWATER30","FWATER31",
		"LAVA02","LAVA03","LAVA04","LAVA05","LAVA06","LAVA07","LAVA08","LAVA09",
		"LAVA10","LAVA11","LAVA12","LAVA13","LAVA14","LAVA15","LAVA16","LAVA17","LAVA18","LAVA19",
		"LAVA20","LAVA21","LAVA22","LAVA23","LAVA24","LAVA25","LAVA26","LAVA27","LAVA28","LAVA29","LAVA30","LAVA31",
		"NUKE02","NUKE03","NUKE04","NUKE05","NUKE06","NUKE07","NUKE08","NUKE09",
		"NUKE10","NUKE11","NUKE12","NUKE13","NUKE14","NUKE15","NUKE16","NUKE17","NUKE18","NUKE19",
		"NUKE20","NUKE21","NUKE22","NUKE23","NUKE24","NUKE25","NUKE26","NUKE27","NUKE28","NUKE29","NUKE30","NUKE31",
		"SLUDG02","SLUDG03","SLUDG04","SLUDG05","SLUDG06","SLUDG07","SLUDG08","SLUDG09",
		"SLUDG10","SLUDG11","SLUDG12","SLUDG13","SLUDG14","SLUDG15","SLUDG16","SLUDG17","SLUDG18","SLUDG19",
		"SLUDG20","SLUDG21","SLUDG22","SLUDG23","SLUDG24","SLUDG25","SLUDG26","SLUDG27","SLUDG28","SLUDG29","SLUDG30","SLUDG31",
		"SWATER1","SWATER4","COOLNT02","COOLNT03","COOLNT04","COOLNT05","COOLNT06","COOLNT07","COOLNT08","COOLNT09",
		"COOLNT10","COOLNT11","COOLNT12","COOLNT13","COOLNT14","COOLNT15","COOLNT16","COOLNT17","COOLNT18","COOLNT19",
		"BLOOD02","BLOOD03","BLOOD04","BLOOD05","BLOOD06","BLOOD07","BLOOD08","BLOOD09",
		"BLOOD10","BLOOD11","BLOOD12","BLOOD13","BLOOD14","BLOOD15","BLOOD16","BLOOD17","BLOOD18","BLOOD19",
		"BLOOD20","BLOOD21","BLOOD22","BLOOD23","BLOOD24","BLOOD25","BLOOD26","BLOOD27","BLOOD28","BLOOD29","BLOOD30","BLOOD31",
		//Eviternity and other OTEX-using maps
		"OBLODA01","OBLODA02","OBLODA03","OBLODA04","OBLODA05","OBLODA06","OBLODA07","OBLODA08",
		"OGOOPY01","OGOOPY02","OGOOPY03","OGOOPY04","OGOOPY05","OGOOPY06","OGOOPY07","OGOOPY08",
		"OICYWA01","OICYWA02","OICYWA03","OICYWA04","OICYWA05","OICYWA06","OICYWA07","OICYWA08",
		"OLAVAA01","OLAVAA02","OLAVAB01","OLAVAC01","OLAVAC02","OLAVAC03","OLAVAC04","OLAVAC05","OLAVAC06","OLAVAC07","OLAVAC08",
		"OLAVAD01","OLAVAD02","OLAVAD03","OLAVAD04","OLAVAD05","OLAVAD06","OLAVAD07","OLAVAD08",
		"OLAVAE01","OLAVAE02","OLAVAE03","OLAVAE04","OLAVAE05","OLAVAE06","OLAVAE07","OLAVAE08",
		"OLAVAF01","OLAVAF02","OLAVAF03","OLAVAF04","OLAVAF05","OLAVAF06","OLAVAF07","OLAVAE08","OLAVAE09","OLAVAE10",
		"ONUKEA01","ONUKEA02","ONUKEA03","ONUKEA04","ONUKEA05","ONUKEA06","ONUKEA07","ONUKEA08",
		"OPOOPY01","OPOOPY02","OPOOPY03","OPOOPY04","OPOOPY05","OPOOPY06","OPOOPY07","OPOOPY08",
		"OSLUDG01","OSLUDG02","OSLUDG03","OSLUDG04","OSLUDG05","OSLUDG06","OSLUDG07","OSLUDG08",
		"OTAR__01","OTAR__02","OTAR__03","OTAR__04","OTAR__05","OTAR__06","OTAR__07","OTAR__08",
		"OWATER01","OWATER02","OWATER03","OWATER04","OWATER05","OWATER06","OWATER07","OWATER08",
		//Bastion of Chaos (damnit Bridgeburner)
		"0BLODA01","0BLODA02","0BLODA03","0BLODA04","0BLODA05","0BLODA06","0BLODA07","0BLODA08",
		//Refracted Reality
		"BLDNUKE1","BLDNUKE2","BLDNUKE3","BLDNUKE4","BLOOD2A","BLOOD2B","BLOOD4","BLOOD5","BLOOD6",
		"CYWATR1","CYWATR2","CYWATR3","CYWATR4","FWATER5","FWATER6","FWATER7","FWATER8",
		"EGSLIME1","EGSLIME2","EGSLIME3","EGSLIME4","EQSLIME1","EQSLIME2","EQSLIME3","EQSLIME4",
		"NUKAGE2A","NUKAGE2B","PURPCRACK","SEWAGE1","SEWAGE2","SEWAGE3","SLIMAGE1","SLIMAGE2","SLIMAGE3","SLIMAGE4",
		"RACRAK20","RACRAK21","RACRAK22","RACRAK23","RACRAK24","ZFBCROK1","ZFBCROK2","ZFBCROK3","ZFBCROK4",
		"ZFBLAVA1","ZFBLAVA2","ZFBLAVA3","ZFBLAVA4","ZFGLAVA1","ZFGLAVA2","ZFGLAVA3","ZFGLAVA4",
		"ZFBWATR1","ZFBWATR2","ZFBWATR3","ZFBWATR4","ZFGWATR1","ZFGWATR2","ZFGWATR3","ZFGWATR4",
		"ZFILAVA1","ZFILAVA2","ZFILAVA3","ZFILAVA4","ZFKLAVA1","ZFKLAVA2","ZFKLAVA3","ZFKLAVA4",
		"ZFIWATR1","ZFIWATR2","ZFIWATR3","ZFIWATR4","ZFKWATR1","ZFKWATR2","ZFKWATR3","ZFKWATR4",
		"ZFPWATR1","ZFPWATR2","ZFPWATR3","ZFPWATR4","ZFWWATR1","ZFWWATR2","ZFWWATR3","ZFWWATR4",
		"ZFYWATR1","ZFYWATR2","ZFYWATR3","ZFYWATR4","ZFLWATR1","ZFLWATR2","ZFLWATR3","ZFLWATR4",
		"ZFRLAVA1","ZFRLAVA2","ZFRLAVA3","ZFRLAVA4",
		"ZFWCROK1","ZFWCROK2","ZFWCROK3","ZFWCROK4","ZFYCROK1","ZFYCROK2","ZFYCROK3","ZFYCROK4",
		"ZFOCROK1","ZFOCROK2","ZFOCROK3","ZFOCROK4","ZFLCROK1","ZFLCROK2","ZFLCROK3","ZFLCROK4",
		//Unfamiliar Episodes
		"BLAVA1","BLAVA2","BLAVA3","BLAVA4","BWATER1","BWATER2","BWATER3","BWATER4","HWATER1","HWATER2","HWATER3","HWATER4",
		"MINERAL1","MINERAL2","MINERAL3","MINERAL4","NUKE1","NUKE2","NUKE3","NUKE4","SEWER1","SEWER2","SEWER3","SEWER4",
		"GUTSN1","NFLESH1","NFLESH2","NFLESH5","NFLESH6","NFLESH9","OFLSHA01","OFLSHB01","OFLSHC01","OFLSHE01","OFLSHG01","OFLSHH01","OFLSHH02"
	};
		
	//"step_water"
	static const name FLATS_WATER[] =
	{
		"ET_WFL","FWATER2","FWATER3","FWATER4","PURPW1","PURPW2","PURPW3","PURPW4",
		"FWATER02","FWATER03","FWATER04","FWATER05","FWATER06","FWATER07","FWATER08","FWATER09",
		"FWATER10","FWATER11","FWATER12","FWATER13","FWATER14","FWATER15","FWATER16","FWATER17","FWATER18","FWATER19",
		"FWATER20","FWATER21","FWATER22","FWATER23","FWATER24","FWATER25","FWATER26","FWATER27","FWATER28","FWATER29",
		"FWATER30","FWATER31","SWATER1","SWATER4",
		"COOLNT02","COOLNT03","COOLNT04","COOLNT05","COOLNT06","COOLNT07","COOLNT08","COOLNT09",
		"COOLNT10","COOLNT11","COOLNT12","COOLNT13","COOLNT14","COOLNT15","COOLNT16","COOLNT17","COOLNT18","COOLNT19",
		"COOLNT20","COOLNT21","COOLNT22","COOLNT23","COOLNT24","COOLNT25","COOLNT26","COOLNT27","COOLNT28","COOLNT29",
		"COOLNT30","COOLNT31","OGOOPY01","OGOOPY02","OGOOPY03","OGOOPY04","OGOOPY05","OGOOPY06","OGOOPY07","OGOOPY08",
		"OICYWA01","OICYWA02","OICYWA03","OICYWA04","OICYWA05","OICYWA06","OICYWA07","OICYWA08",
		"OWATER01","OWATER02","OWATER03","OWATER04","OWATER05","OWATER06","OWATER07","OWATER08",
		"CYWATR1","CYWATR2","CYWATR3","CYWATR4","FWATER5","FWATER6","FWATER7","FWATER8",
		"ZFBWATR1","ZFBWATR2","ZFBWATR3","ZFBWATR4","ZFGWATR1","ZFGWATR2","ZFGWATR3","ZFGWATR4",
		"ZFIWATR1","ZFIWATR2","ZFIWATR3","ZFIWATR4","ZFKWATR1","ZFKWATR2","ZFKWATR3","ZFKWATR4",
		"ZFPWATR1","ZFPWATR2","ZFPWATR3","ZFPWATR4","ZFWWATR1","ZFWWATR2","ZFWWATR3","ZFWWATR4",
		"ZFYWATR1","ZFYWATR2","ZFYWATR3","ZFYWATR4","ZFLWATR1","ZFLWATR2","ZFLWATR3","ZFLWATR4",
		"HWATER1","HWATER2","HWATER3","HWATER4","FWATER1"
	};
	//"step_slime"
	static const name FLATS_SLIME[] =
	{
		"ET_BFL","ET_AFL","ET_SFL1","ET_SFL2","BLOOD1","BLOOD2","BLOOD3","GRAYSLM1","GRAYSLM2","GRAYSLM3","GRAYSLM4",
		"NUKAGE1","NUKAGE2","NUKAGE3","SLIME01","SLIME02","SLIME03","SLIME04","SLIME05","SLIME06","SLIME07","SLIME08",
		"NUKE02","NUKE03","NUKE04","NUKE05","NUKE06","NUKE07","NUKE08","NUKE09","CC_MFF",
		"NUKE10","NUKE11","NUKE12","NUKE13","NUKE14","NUKE15","NUKE16","NUKE17","NUKE18","NUKE19",
		"NUKE20","NUKE21","NUKE22","NUKE23","NUKE24","NUKE25","NUKE26","NUKE27","NUKE28","NUKE29","NUKE30","NUKE31",
		"SLUDG02","SLUDG03","SLUDG04","SLUDG05","SLUDG06","SLUDG07","SLUDG08","SLUDG09",
		"SLUDG10","SLUDG11","SLUDG12","SLUDG13","SLUDG14","SLUDG15","SLUDG16","SLUDG17","SLUDG18","SLUDG19",
		"SLUDG20","SLUDG21","SLUDG22","SLUDG23","SLUDG24","SLUDG25","SLUDG26","SLUDG27","SLUDG28","SLUDG29","SLUDG30","SLUDG31",
		"BLOOD02","BLOOD03","BLOOD04","BLOOD05","BLOOD06","BLOOD07","BLOOD08","BLOOD09",
		"BLOOD10","BLOOD11","BLOOD12","BLOOD13","BLOOD14","BLOOD15","BLOOD16","BLOOD17","BLOOD18","BLOOD19",
		"BLOOD20","BLOOD21","BLOOD22","BLOOD23","BLOOD24","BLOOD25","BLOOD26","BLOOD27","BLOOD28","BLOOD29","BLOOD30","BLOOD31",
		"0BLODA01","0BLODA02","0BLODA03","0BLODA04","0BLODA05","0BLODA06","0BLODA07","0BLODA08",
		"OBLODA01","OBLODA02","OBLODA03","OBLODA04","OBLODA05","OBLODA06","OBLODA07","OBLODA08",
		"ONUKEA01","ONUKEA02","ONUKEA03","ONUKEA04","ONUKEA05","ONUKEA06","ONUKEA07","ONUKEA08",
		"OPOOPY01","OPOOPY02","OPOOPY03","OPOOPY04","OPOOPY05","OPOOPY06","OPOOPY07","OPOOPY08",
		"OSLUDG01","OSLUDG02","OSLUDG03","OSLUDG04","OSLUDG05","OSLUDG06","OSLUDG07","OSLUDG08",
		"BLDNUKE1","BLDNUKE2","BLDNUKE3","BLDNUKE4","BLOOD2A","BLOOD2B","BLOOD4","BLOOD5","BLOOD6",
		"EGSLIME1","EGSLIME2","EGSLIME3","EGSLIME4","EQSLIME1","EQSLIME2","EQSLIME3","EQSLIME4",
		"NUKAGE2A","NUKAGE2B","PURPCRACK","SEWAGE1","SEWAGE2","SEWAGE3","SLIMAGE1","SLIMAGE2","SLIMAGE3","SLIMAGE4",
		"BWATER1","BWATER2","BWATER3","BWATER4","MINERAL1","MINERAL2","MINERAL3","MINERAL4",
		"NUKE1","NUKE2","NUKE3","NUKE4","SEWER1","SEWER2","SEWER3","SEWER4"
	};
	//"step_slimy"
	static const name FLATS_SLIMY[] =
	{
		"SFLR6_1","SFLR6_4","SFLR7_1","SFLR7_4","GUTSN1","NFLESH1","NFLESH2","NFLESH5",
		"NFLESH6","NFLESH9","OFLSHA01","OFLSHB01","OFLSHC01","OFLSHE01","OFLSHG01",
		"OFLSHH01","OFLSHH02"
	};
	//"step_lava"
	static const name FLATS_LAVA[]	=
	{
		"LAVA1","LAVA2","LAVA3","LAVA4","ET_LFL","ZO1_01","ZO1_02","ZO1_03","ZO1_99","MLAVA1","MLAVA2","MLAVA3","MLAVA4",
		"LAVA02","LAVA03","LAVA04","LAVA05","LAVA06","LAVA07","LAVA08","LAVA09",
		"LAVA10","LAVA11","LAVA12","LAVA13","LAVA14","LAVA15","LAVA16","LAVA17","LAVA18","LAVA19",
		"LAVA20","LAVA21","LAVA22","LAVA23","LAVA24","LAVA25","LAVA26","LAVA27","LAVA28","LAVA29","LAVA30","LAVA31",
		"OLAVAA01","OLAVAA02","OLAVAB01","OLAVAC01","OLAVAC02","OLAVAC03","OLAVAC04","OLAVAC05","OLAVAC06","OLAVAC07","OLAVAC08",
		"OLAVAD01","OLAVAD02","OLAVAD03","OLAVAD04","OLAVAD05","OLAVAD06","OLAVAD07","OLAVAD08",
		"OLAVAE01","OLAVAE02","OLAVAE03","OLAVAE04","OLAVAE05","OLAVAE06","OLAVAE07","OLAVAE08",
		"OLAVAF01","OLAVAF02","OLAVAF03","OLAVAF04","OLAVAF05","OLAVAF06","OLAVAF07","OLAVAE08","OLAVAE09","OLAVAE10",
		"ZFBLAVA1","ZFBLAVA2","ZFBLAVA3","ZFBLAVA4","ZFGLAVA1","ZFGLAVA2","ZFGLAVA3","ZFGLAVA4",
		"ZFILAVA1","ZFILAVA2","ZFILAVA3","ZFILAVA4","ZFKLAVA1","ZFKLAVA2","ZFKLAVA3","ZFKLAVA4",
		"ZFRLAVA1","ZFRLAVA2","ZFRLAVA3","ZFRLAVA4","BLAVA1","BLAVA2","BLAVA3","BLAVA4"
	};
	//"step_rock"
	static const name FLATS_ROCK[]	=
	{
		"FLAT1","FLAT1_1","FLAT1_2","FLAT5_4","FLAT5_7","FLAT5_8","MFLR8_2","GRNROCK",
		"RROCK01","RROCK02","RROCK03","RROCK04","RROCK05","RROCK06","RROCK07","RROCK08","RROCK09",
		"RROCK10","RROCK11","RROCK12","RROCK13","RROCK14","RROCK15","RROCK20",
		"SLIME09","SLIME10","SLIME11","SLIME12"
	};
	//"step_wood"
	static const name FLATS_WOOD[]	= { "CEIL1_1","FLAT5_1","FLAT5_2" };
	//"step_tilea"
	static const name FLATS_TILEA[] = { "FLOOR3_3","FLAT20","CEIL3_3","CEIL3_4","FLAT3" };
	//"step_tileb"
	static const name FLATS_TILEB[] =  { "DEM1_1","DEM1_2","DEM1_3","DEM1_4","DEM1_5","DEM1_6","FLOOR7_2" };
	//"step_hard"
	static const name FLATS_HARD[]	=
	{
		"FLOOR0_6","FLOOR4_8","FLOOR5_1","FLOOR5_2","FLOOR5_3","FLOOR5_4",
		"TLITE6_4","TLITE6_6","FLOOR7_1","MFLR8_1","CEIL3_5","CEIL3_6","CEIL5_2",
		"FLAT8","SLIME13"
	};
	//"step_carpet"
	static const name FLATS_CARPET[] = { "CEIL4_1","FLAT5_4","FLAT5_5","FLAT14","FLOOR1_1" };
	//"step_metala"
	static const name FLATS_METALA[] = { "CEIL1_2","CEIL1_3","GATE1","GATE2","GATE3","SLIME14","SLIME15","SLIME16","STEP1","STEP2" };
	//"step_metalb"
	static const name FLATS_METALB[] = { "CONS1_1","CONS1_5","CONS1_7","FLAT4","FLAT22","FLAT23","GATE4" };
	//"step-dirt"
	static const name FLATS_DIRT[]	= { "GRASS1","GRASS2","RROCK16","RROCK19","RROCK20" };
	//"step_gravel"
	static const name FLATS_GRAVEL[] = { "FLOOR6_1","FLOOR6_2","FLAT10","MFLR8_3","MFLR8_4","RROCK17","RROCK18" };
	//"step_snow"
	static const name FLATS_SNOW[] = { "FLAT5_6" };
}
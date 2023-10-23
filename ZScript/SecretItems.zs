Class SecretItemSpawner : EventHandler {
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < level.Sectors.Size(); i++)
		{
			// Grab the center point of all sectors in the map.
			let c = level.Sectors[i].centerspot;
			Vector3 spam3 = (c.x, c.y, level.Sectors[i].floorplane.ZAtPoint(c));
			
			// Is the selected sector a secret, and is its center point actually within playable space?
			if (level.IsPointInLevel(spam3) && level.Sectors[i].IsSecret())
			{
					{
						// Make sure the secret isn't a closed door like in E1M1, so the item has room to spawn.
						if (level.Sectors[i].floorplane.ZAtPoint(c) != level.Sectors[i].ceilingplane.ZAtPoint(c))
						{
							Actor newitem = Actor.Spawn("ItemCrate", spam3);
							
					}
				}
			}
		}
	}
}

Class CreditCardSpawnHandler : EventHandler
{
	Array<Actor> Things;
	
	override void WorldLoaded(WorldEvent e)
	{
		Things.Clear();
		
		// are we in single player? and are we re-entering a hub level?
		if (!multiplayer && !deathmatch && e.IsReopen == false)
		{
			for (int j = 0; j < 1; j++)
			{
				Vector3 checkpos = G_PickDeathmatchStart();
				
				// Means there is no deathmatch starts.
				if (checkpos ~== (0,0,0))
					return;
				
				// spawn a little sumptin'-sumptin'
				Actor n = Actor.Spawn("ByteSpawner", checkpos);
				if (n) Things.Push(n);
			}
		}
	}
}
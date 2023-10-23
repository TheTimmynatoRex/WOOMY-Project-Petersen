/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
 *
 * This file is a part of Tips.pk3.
 *
 * Tips.pk3 is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Tips.pk3 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Tips.pk3.  If not, see <https://www.gnu.org/licenses/>.
 */

/**
 * This class draws a note at the bottom of the screen.
 *
 * It respects tp_show_notes CVar.
 */
class woomy_tp_ListMenuNote : ListMenuItem
{

// public: /////////////////////////////////////////////////////////////////////

  woomy_tp_ListMenuNote init()
  {
    add("Fun fact: You are immune to splash damage, but the Nussbeisser\n"
		"Rocket Launcher still deals full damage to you, so watch out!");

    add("Fun fact: The Nussbeisser Rocket Launcher forces splash damage\n"
		"on enemies normally immune to them and also pierces through armor.");
		
    add("Fun fact: The Inkopolis Pistol has infinite ammo, meaning you'll\n"
		"never run out of ammo and have to resort to weak melee attacks.");
	
    add("Fun fact: There is a super-rare powerup called the Onukisphere that\n"
		"fully replenishes both your health and armor to 500%.");
		
    add("Fun fact: A recommended wads list is located inside the PK3. View it\n"
		"to see maps, monster packs and addons that the author recommends.");
		
    add("Fun fact: All versions of WOOMY have codenames, as a nod to Microsoft\n"
		"and their Windows system. This version, 3.2, is codenamed 'Aura'.");
		
    add("Fun fact: Did you know there's a Hi Hi Puffy AmiYumi companions mod?\n"
		"It comes bundled in the WOOMY Addons Pack alongside some other stuff.");
		
    add("Pro tip: To defeat the Cyberdemon, shoot at it until it dies.");
	
    add("'If you're seeing this, tell TDRR I said hi.' ~Yumi Yoshimura");
	
    add("In the far future, Jenny Wakeman-style robots will\n"
		"replace Terminator-style robots and cyborgs.");
		
	add("In the WOOMY timeline, Houzuki-Ida is the largest company on Earth.");
	
	add("'Fear leads to anger; Anger leads to hate.' ~Yoda");
	
	add("'Anything is possible!' ~Ami Onuki and Yumi Yoshimura");
	
    add("Fun fact: The seven difficulties are internally labeled\n"
		"Very Easy, Mild Easy, Easy, Medium, Hard, Very Hard, and Fuck You.");
		
    add("Fun fact: The Splattershot Handgun has a handy alt-fire in which it\n"
		"shoots an ink-beam that uses no ammo whatsoever.");
		
    add("'All these memories will be lost in time,\n"
		"like tears in the rain.' ~Roy Batty");
		
    add("'What are you doing in my swamp?' ~Shrek");
	
	add("Fun fact: This mod is best viewed in a 1920x1080 resolution.");
	
	add("'New weapons, synth music and anime companions!' ~Pega6us");
	
	add("Rip and tear, until it is done.");
	
	add("If this mod had a genre of some type, it'd be\n"
		"'Cyberpunk time travel with an overdose of pop culture references'.");
		
	add("Fun fact: Some parts of the mod can be customized to your liking.\n"
		"To do that, go to the Options Menu and select 'WOOMY Options'.");
		
	add("Fun fact: Tim Petersen lives in a colonized exoplanet called Nieue-Inkopolei,\n"
		"which is located in the VFTS-352 Star System in the Large Magellanic Cloud.");
		
	add("The most fitting wads for its made-up genre are\n"
		"AUGER;ZENITH, DTS-T, and Beyond Reality respectively.");
	
	add("'To infinity, and beyond!' ~Buzz Lightyear");
	
	add("Fun fact: The Nuclear Capacitor can upgrade almost all of the weapons\n"
		"in various ways, from increased fire rate to totally new modes. Try them all.");
		
	add("Fun fact: This mod is compatible with Lithium.\n"
		"Try it out to get the full Cyberpunk experience.");
		
	add("Fun fact: There is a Cyberpunk 2077 music addon available as a\n"
		"separate download due to the excessive file size.");
		
	add("'Been spending most our lives,\n"
		"living in a gangsta's paradise.' ~Coolio");
	
	add("'The internet is not something that you just dump something on.\n"
		"It's not a big truck; it's a series of tubes.' ~Ted Stevens");
	
	add("Fun fact: The Reaper Shop can be accessed through the PDA in your inventory,\n"
		"where you can buy almost all of the weapons and items in the mod.");
	
	add("'As long as the Scary Maze Game exists, humanity will go\n"
		"down a terrible, terrible path.' ~Timothy John Petersen, 2022");

    Super.Init();
    return self;
  }

  override
  bool, String GetString(int i)
  {
    // unused: i
    return true, "woomy_tp_ListMenuNote";
  }

// public: // ListMenuItem /////////////////////////////////////////////////////

  override
  void OnMenuCreated()
  {
    _iString = random(0, _strings.size() - 1);
  }

  override
  void Drawer(bool selected)
  {
    // unused: selected

    if (!woomy_tp_show_notes)
    {
      return;
    }

    int    width  = (Screen.GetWidth() / CleanXFac_1) * 3 / 4;
    let    lines  = NewSmallFont.BreakLines(_strings[_iString], width);
    int    nLines = lines.Count();
    double height = NewSmallFont.GetHeight();
    double y      = Screen.GetHeight() - MARGIN - height * nLines * CleanYFac_1;

    for (int i = 0; i < nLines; ++i)
    {
      double x = Screen.GetWidth() - MARGIN - lines.StringWidth(i) * CleanXFac_1;
      Screen.DrawText( NewSmallFont, Font.CR_WHITE, x, y, lines.StringAt(i)
                     , DTA_CleanNoMove_1, true
                     );
      y += height * CleanYFac_1;
    }
  }

// private: ////////////////////////////////////////////////////////////////////

  private ui
  void add(String s)
  {
    _strings.push(s);
  }

// private: ////////////////////////////////////////////////////////////////////

  const MARGIN = 10;

// private: ////////////////////////////////////////////////////////////////////

  /// Must contain at least 1 string.
  private ui Array<String> _strings;
  private ui uint          _iString;

} // class tp_ListMenuNote

class OptionMenuItemwoomy_tp_MenuInjector : OptionMenuItem
{

// public: /////////////////////////////////////////////////////////////////////

  void Init()
  {
    injectNote("MainMenu");
    injectNote("MainMenuTextOnly");
  }

// private /////////////////////////////////////////////////////////////////////

  /**
   * This function assumes that menu with name @a menuName exists and is a ListMenu.
   */
  void injectNote(String menuName)
  {
    let descriptor = ListMenuDescriptor(MenuDescriptor.GetDescriptor(menuName));

    bool   hasString;
    String string;
    [hasString, string] = descriptor.mItems[descriptor.mItems.size() - 1].GetString(0);

    if (hasString && string == "woomy_tp_ListMenuNote")
    {
      return;
    }

    descriptor.mItems.Push(new("woomy_tp_ListMenuNote").init());
  }

} // class OptionMenuItemtp_MenuInjector
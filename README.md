# Attack Speed Multiplier Iai Sheath Fix (Longsword)
- Enhances existing attack speed mutiplier mod to handle issue with mod conflict, in terms of Longsword Special Sheath. instead of forcing compatibilities, additional flag is added.

# Known Conflicts that has been addressed.
- Ignores Quick Sheath Decoration
- Faster Iai Sheathing Reduces Iai sheathing time for faster transitions. (+15%) [WpSeries-LongSword - By MoMo](https://www.nexusmods.com/monsterhunterwilds/mods/3744)

# Installation
- Requires latest Reframework [REFramework Nighly Release](https://github.com/praydog/REFramework-nightly/releases)
- Drag WeaponAttackSpeedMultiplier.lua inside SteamLibrary\steamapps\common\MonsterHunterWilds\reframework\autorun


# Implementation:

- Tracks Iai skill trigger
- Dynamically adds motion multiplier when Special Sheath is triggered.
- Multiplies the sheathing by the configured multiplier.

# Example:
- [https://youtu.be/O2xE-L-9D8k](https://youtu.be/O2xE-L-9D8k)

# Notes

- Recommended multipliers: x1.50.
- Setting excessively high multipliers (>1.50) may cause unexpected behavior / instant sheath.
- Works only with the LongSword (cHunterWp00Handling).

# Credits

PrayDog - REFramework – Essential framework for script injection and ImGui support.
MOMO - Original Mod.

> ⚠️ **WARNING**
>
> **I DO NOT CONDONE MULTIPLAYER CHEATING.**
>  
> I will **not** take any responsibility if you get **banned** or **reported**.

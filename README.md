# Spaghetti Belt Tools
## Belt Thread Upgrader
Ever tried to upgrade a belt coming off the middle of a bus? Or tried to upgrade a loop on Gleba while only having a limited number of turbo belts? A hundred clicks of an upgrade planner, only to realise you've made a mistake? No more, with this nifty little tool that'll upgrade all the belts connected to the selected belt with just one click. It is smart enough to only go up to the nearest splitter, and only upgrade belts of the same tier (i.e., only yellow belts, or only red belts). Alternate modes allow you to upgrade all the belts that are connected, regardless of type. Or downgrade the same. As an added bonus, you can have some truly monstrous belt spaghetti containing many thousands or even tens of thousands of belts, and you'll barely notice the performance even if you use a potato to run Factorio.

## Belt Thread Remover
Transitioning from the starter base to the mid-game base often leaves long belts that need to be removed between others, which can be tricky and time-consuming to remove without errors. This tool allows the user to select one or more belt pieces, and all belts that would be made redundant by removing the selected belts will be marked for deconstruction. An alternate mode allows all connected belts to be marked for deconstruction, regardless of uses.

# Mod compatibility
For modded belts to be supported by this mod, the modded belt **has** to be included in the default upgrade cycle. That is, upgrading (or downgrading) the modded belt with the default upgrade planner should have a result. In addition, to determine the relevant belt tier, I must unfortunately hard code it -- the [generic option](https://forums.factorio.com/viewtopic.php?t=126686) isn't available at the moment. Make an issue [here](https://github.com/Pietersielie/BeltUpgrader/issues/new) or on the [mod portal](https://mods.factorio.com/mod/BeltThreadUpgrades/discussion/684afd7a1698006dfe10a4c0) with the mod name and link to it, and I'll add compatibility for it. If a belt isn't supported yet, the game will provide a message to the user that the belt with name "belt name" isn't supported yet.

### Known issues with some mods
 - 5Dim's long underground belts are not supported when dealing with single type/tier upgrades, i.e., when left-clicking or Shift+left-clicking. Those long undergrounds are supported for the right-click operations. This is not currently planned to be changed or supported in the future. See [this discussion](https://mods.factorio.com/mod/BeltThreadUpgrades/discussion/684146ad2c77b05a06737884) for more detail.
 - Loaders are supported, however, they are prone to mod compatibility issues. If you experience an error with a loader, please let me know [here](https://mods.factorio.com/mod/BeltThreadUpgrades/discussion/684afd2534f071783e641c63).

# Usage instructions
## Belt Thread Upgrader
The functionality is accessed through a tool, which you can access through a keyboard shortcut (Ctrl+Shift+U by default) or by clicking on the Belt Thread Upgrader button on the shortcut bar.

Select a belt entity (or multiple) to upgrade the thread of.
**When in cursor:**
  - Select (by default, left mouse) to upgrade belts of the same tier connected to the selected belt.
  - Alternate select (by default, Shift+left mouse) to upgrade all belts connected to the selected belt, regardless of tier.
  - Reverse select (by default, right mouse) to downgrade belts of the same tier connected to the selected belt.
  - Alternate reverse select (by default, Shift+right mouse) to downgrade all belts connected to the selected belt, regardless of tier.

## User settings
There are a few user settings available (under the per player tab of mod settings).
  - You can select whether or not splitters will be included when upgrading connected belts of the same tier. Note that selecting a splitter will upgrade it, and its connected belts, regardless.
  - You can select whether or not belts that are marked for upgrade are considered to be of the tier they will be upgraded to, or the tier that they are. This only has an effect when selecting belts of the same tier.
  - You can select whether or not upstream sideloading belts (i.e., where more than one belt enters another belt) are considered connected or not. Note that downstream sideloading belts are always included. I can make this optional if the demand is there.
  - You can select whether or not selecting multiple belts only selects one belt thread (usually, the top left entity). By default, all belt threads selected will be included.

## Belt Thread Remover
The functionality is accessed through a tool, which you can access through a keyboard shortcut (Ctrl+Shift+D by default) or by clicking on the Belt Thread Remover button on the shortcut bar.

Select a belt entity (or multiple) to remove the thread of.

# Credits
Some credit has to be given to the good folk of [Bagelville](https://www.youtube.com/laurenceplays) for helping test the mod, suggesting functionality, as well as providing the idea in the first place. A full credit log is available on the relevant thread for the mod on the discord server.

# Alternatives
At the time that I started working on this mod, the [Belt Line Upgrade](https://mods.factorio.com/mod/BeltLineUpgrade) mod by Strayer_J was not updated for 2.0. This mod is built from scratch and uses a completely different method to build the belt network to Belt Line Upgrade. I have not done comprehensive performance tests, but some quick checks indicate that my method is between 5 and 10 times faster than the older mod's, in addition to having more functionality.
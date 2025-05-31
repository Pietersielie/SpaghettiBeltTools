# Belt Thread Upgrader
Ever tried to upgrade a belt coming off the middle of a bus? Or tried to upgrade a loop on Gleba while only having a limited number of turbo belts? A hundred clicks of an upgrade planner, only to realise you've made a mistake? No more, with this nifty little tool that'll upgrade all the belts connected to the selected belt with just one click. It is smart enough to only go up to the nearest splitter, and only upgrade belts of the same tier (i.e., only yellow belts, or only red belts). Alternate modes allow you to upgrade all the belts that are connected, regardless of type. Or downgrade the same. As an added bonus, you can have some truly monstrous belt spaghetti containing many thousands or even tens of thousands of belts, and you'll barely notice the performance even if you use a potato to run Factorio.

# Mod compatibility
For modded belts to be supported by this mod, the modded belt **has** to be included in the default upgrade cycle. That is, upgrading (or downgrading) the modded belt with the default upgrade planner should have a result. In addition, to determine the relevant belt tier, I must unfortunately hard code it -- the [generic option](https://forums.factorio.com/viewtopic.php?t=126686) isn't available at the moment. Make an issue on [Github](https://github.com/Pietersielie/BeltUpgrader) or here with the mod name and link to it, and I'll add compatibility for it.

# Usage instructions
The functionality is accessed through a tool, which you can access through a keyboard shortcut (Ctrl+Shift+U by default) or by clicking on the Belt Thread Upgrader button on the shortcut bar.

Select a belt entity to upgrade the thread of. It will always be the top left belt entity if multiple entities are selected.
**When in cursor:**
  - Select (by default, left mouse) to upgrade belts of the same tier connected to the selected belt.
  - Alternate select (by default, Shift+left mouse) to upgrade all belts connected to the selected belt, regardless of tier.
  - Reverse select (by default, right mouse) to downgrade belts of the same tier connected to the selected belt.
  - Alternate reverse select (by default, Shift+right mouse) to downgrade all belts connected to the selected belt, regardless of tier.

# Credits
Some credit has to be given to the good folk of Bagelville for helping test the mod, suggesting functionality, as well as providing the idea in the first place. A full credit log is available on the relevant thread for the mod on the discord server.

# Alternatives
At the time that I started working on this mod, the [Belt Line Upgrade](https://mods.factorio.com/mod/BeltLineUpgrade) mod by Strayer_J was not updated for 2.0. This mod is built from scratch and uses a completely different method to build the belt network to Belt Line Upgrade. I have not done comprehensive performance tests, but some quick checks indicate that my method is between 5 and 10 times faster than the older mod's.

Scripts to overlay mod files over game directories without changing the original files on Linux.

## Background

While [steamtinkerlaunch](https://github.com/sonic2kk/steamtinkerlaunch/) helps to setup the mod managers, Vortex did not start for me and current MO2 stable version (2.4.4) seems to work (shows a window) but does not support Starfield.
MO2 beta builds from their Discord with SF support did not work for me through wine.
Lastly, the new [NexusMods.App](https://github.com/Nexus-Mods/NexusMods.App) looks promising, but is only in very early development and while it shows a window for me, it cannot do much more for me at this time.

These scripts use overlayfs to layer mods in their directories over the original game folders, similar to MO2's virtual file system, to keep the game folder clean.

## Usage

`overlay-mods` will take all direct subdirectories of the first argument as layers and the second argument as the game directory - both the mount target and lowest layer.

```sh
overlay-mods path/to/mods path/to/game
```

Passing `-w` or `--writable` will additionally create directories as working dir and upper dir for overlayfs. All changes written to the mount target will be visible in the upperdir.

---

`sf-mods-overlay` utilises this specifically for Starfield.

```sh
# to mount:
sf-mods-overlay
# or
sf-mods-overlay 1

# to unmount:
sf-mods-overlay 0
```

This mounts mods in `rootmods`, `datamods` and `documentsdir` in `$MODDING_ROOT/Starfield` (default: `$HOME/Modding/Starfield`) over their respective targets in `$STEAM_LIBARY` (default: `$HOME/.local/share/Steam`) or `$PROTON_PFX` (default: `$STEAM_LIBRARY/steamapps/compatdata/1716740/pfx`).
Only the documentsdir within the proton prefix is mounted writable (e.g. for save games), so Steam won't be able to update the game while this mount is active.

<details><summary>Example rootmods structure (click to show)</summary>

```
$ lsd -gR --icon-theme=unicode rootmods
📂 '1. All In One Motion Blur Full OFF-290-1v1-1693729795'

rootmods/1. All In One Motion Blur Full OFF-290-1v1-1693729795:
📄 High.ini  📄 Low.ini  📄 Medium.ini  📂 ORG-Settings  📄 Ultra.ini

rootmods/1. All In One Motion Blur Full OFF-290-1v1-1693729795/ORG-Settings:
📄 High.ini  📄 Low.ini  📄 Medium.ini  📄 Ultra.ini

```

</details>

<details><summary>Example datamods structure (click to show)</summary>

(reduced output for some brevity; zip files are ignored)

```
$ lsd -gR --icon-theme=unicode datamods
📂 'BetterHUD - Location and XP-214-0-3-1693575029'             📂 'Compact Mission UI-682-1-4-1694710845'               📂 'StarUI HUD-3444-1-0-1695265662'
📄 'Cleanfield.v.1.7.2-Manual Install-88-1-7-2-1694893617.zip'  📂 'Keep Starfield Logo'                                 📄 'StarUI HUD-3444-1-0-1695265662.7z'
📂 'Compact Build Menu UI-3063-1-1-1695076070'                  📂 'Neutral LUTs - No Color Filters-323-1-4-1694299014'  📂 'StarUI Inventory-773-2-1-1694739455'
📂 'Compact Crafting UI-3274-1-4-1695406809'                    📂 'Smooth Ship Reticle-270-1-3-1694725962'              📂 starui-config
📂 'Compact Crew Menu UI-3014-1-3-1695161763'                   📂 'Starfield PS5 Icons-215-1-0-1693550783'

datamods/BetterHUD - Location and XP-214-0-3-1693575029:
📂 Interface

datamods/BetterHUD - Location and XP-214-0-3-1693575029/Interface:
📄 hudmessagesmenu.gfx  📄 hudmessagesmenu_lrg.gfx

datamods/Compact Build Menu UI-3063-1-1-1695076070:
📂 Interface

datamods/Compact Build Menu UI-3063-1-1-1695076070/Interface:
📄 workshopmenu.swf

datamods/Compact Crafting UI-3274-1-4-1695406809:
📂 Interface

datamods/Compact Crafting UI-3274-1-4-1695406809/Interface:
📄 armorcraftingmenu.swf  📄 drugscraftingmenu.swf  📄 foodcraftingmenu.swf  📄 industrialcraftingmenu.swf  📄 weaponscraftingmenu.swf

datamods/Compact Crew Menu UI-3014-1-3-1695161763:
📂 Interface

datamods/Compact Crew Menu UI-3014-1-3-1695161763/Interface:
📄 shipcrewmenu.swf

datamods/Compact Mission UI-682-1-4-1694710845:
📂 Interface

datamods/Compact Mission UI-682-1-4-1694710845/Interface:
📄 missionmenu.swf  📄 missionmenu_lrg.swf

datamods/Keep Starfield Logo:
📂 Interface

datamods/Keep Starfield Logo/Interface:
📄 mainmenu.swf

datamods/StarUI HUD-3444-1-0-1695265662:
📂 Interface

datamods/StarUI HUD-3444-1-0-1695265662/Interface:
📄 hudmenu.gfx      📄 hudrolloveractivationwidget.gfx      📄 hudrolloverwidget.gfx      📂 ItemSorter                  📄 'StarUI HUD Icons.swf'  📂 Translation
📄 hudmenu_lrg.gfx  📄 hudrolloveractivationwidget_lrg.gfx  📄 hudrolloverwidget_lrg.gfx  📄 'StarUI HUD (default).ini'  📂 'StarUI HUD Presets'

datamods/StarUI HUD-3444-1-0-1695265662/Interface/ItemSorter:
📄 NamesIndex_de.swf  📄 NamesIndex_es.swf  📄 NamesIndex_it.swf  📄 NamesIndex_pl.swf    📄 NamesIndex_zhhans.swf
📄 NamesIndex_en.swf  📄 NamesIndex_fr.swf  📄 NamesIndex_ja.swf  📄 NamesIndex_ptbr.swf

datamods/StarUI HUD-3444-1-0-1695265662/Interface/StarUI HUD Presets:
📄 'StarUI HUD - Authors Choice.ini'  📄 'StarUI HUD - Vanilla Extended.ini'  📄 'StarUI HUD - Vanilla.ini'

datamods/StarUI HUD-3444-1-0-1695265662/Interface/Translation:
📄 StarUI_HUD_en.txt

datamods/StarUI Inventory-773-2-1-1694739455:
📂 Interface

datamods/StarUI Inventory-773-2-1-1694739455/Interface:
📄 bartermenu.swf      📄 containermenu.swf      📄 inventorymenu.swf      📄 'StarUI Inventory (default).ini'  📄 'StarUI Inventory Icons.swf'
📄 bartermenu_lrg.swf  📄 containermenu_lrg.swf  📄 inventorymenu_lrg.swf  📄 'StarUI Inventory - FormIDs.txt'  📂 Translation

datamods/StarUI Inventory-773-2-1-1694739455/Interface/Translation:
📄 StarUI_Inventory_en.txt

datamods/starui-config:
📂 Interface

datamods/starui-config/Interface:
📄 'StarUI HUD.ini'  📄 'StarUI Inventory.ini'

```

</details>

<details><summary>Example documentsdir structure (click to show)</summary>

```
$ lsd -gR --icon-theme=unicode documentsdir
📂 customini

documentsdir/customini:
📄 StarfieldCustom.ini
```

</details>

## Caveats

- It is still a bit verbose.
- Mods have to be downloaded and extracted manually. Similar to a manual install.
- Folder and filenames might need to be in proper case.
- Filesystems with casefolding [are not supported by overlayfs](https://bugzilla.kernel.org/show_bug.cgi?id=216471). This was the case for me with a partition formatted by [HoloISO](https://github.com/HoloISO/holoiso) so might be an issue on the SteamDeck? Run `sudo tune2fs -l /dev/nvme1n1p7 | grep casefold` to check if it is active. **Solution:** use a SteamLibary on a different parition.
- Mount options have a size limit. As all mod folders are passed as a mount option to overlayfs, you may encounter this issue with too many mods. **Solution:** Use shorter folder names or fewer folders.
- Game and Data folders are mounted read-only. Steam won't be able to update the game with an active mount.
- Using the script as part of the Steam game launch command (i.e. `sf-overlay-mods %command%`) would be nice, but I could not get it to work yet.

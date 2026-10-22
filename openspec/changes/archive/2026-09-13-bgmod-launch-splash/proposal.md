## Why

Users often wonder whether `bgmod` scripts, environment variables, and mods (MangoHud, OptiScaler, Lossless Scaling, vkBasalt, Tweaks) were successfully loaded when launching a game from Steam or Heroic. Currently, unless MangoHud is explicitly active, there is no direct visual feedback that GOverlay applied any configurations.

A quick, non-blocking splash screen on game launch confirms visually to the user that GOverlay configurations have been applied and clearly lists each active module with a green checkmark.

## What Changes

- Add a new lightweight native binary `bgmod-splash` compiled alongside `bgmod` in the build system (`Makefile`).
- Display a centered, frameless, dark-themed splash window with the GOverlay logo, "Applying GOverlay Configurations", and a checklist showing only the currently active modules (`✔ MangoHud`, `✔ OptiScaler`, `✔ Lossless Scaling`, `✔ vkBasalt`, `✔ Environment Variables`).
- Auto-dismiss the splash after 2.5 seconds, or immediately if dismissed via click/keypress.
- In `bgmod.lpr`, check the launch splash preference from `bgmod.conf`, asynchronously fork `bgmod-splash` with arguments for enabled tools, and immediately continue to `execvpe` (100% non-blocking game startup).
- Add a new toggle item in GOverlay's Settings Menu (`settingsMenu`), positioned directly below "Create Steam shortcut", labeled "Show launch splash screen", checked by default.
- Persist the preference in `goverlay.conf` and `bgmod.conf` (`SHOW_LAUNCH_SPLASH=1`).

## Capabilities

### New Capabilities
- `bgmod-launch-splash`: Provides visual game startup confirmation via an asynchronous splash screen detailing active GOverlay modules, with user preference control in the GOverlay settings menu.

### Modified Capabilities
None.

## Impact

- **Build / Packaging**: New build target `bgmod-splash` added to `Makefile` and installed to `$(libexecdir)/bgmod-splash`.
- **Runtime**: `bgmod.lpr` gains logic to fork and execute `bgmod-splash` asynchronously before calling `execvpe`.
- **GUI**: `sidebar_nav.pas` and `overlayunit.pas` gain the menu item in `settingsMenu` with persistence in `goverlay.conf` and `bgmod.conf`.
- **User Experience**: Immediate visual feedback on game launch without delaying Proton or game execution.

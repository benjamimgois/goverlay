# Design

## Context

- bgmod (`bgmod.lpr`) derives `ConfigDir`, `SourceDir`, `IsPerGameProfile`, `BackupsDir`, `CentralLogDir` and `GameProfileName` from `ExtractFilePath(ParamStr(0))` at the top of the main block. `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf` and `plugins/` are read from `BgmodPath` directly.
- `ResolveGameDirectory` finds `GameDir` from the `.exe` argument (with launcher substitution), a native executable argument, a Lutris `rungameid`, `STEAM_COMPAT_INSTALL_PATH`, or the `TARGET_EXE`/`GAME_DIR` cache in the profile's `bgmod.conf`. Only the cache step depends on `ConfigDir`.
- GOverlay creates `gameconfig/<SanitizedName>/` and copies the bgmod binary there as soon as a game card is clicked, and silent saves while loading the card can already write a `bgmod.conf` for it.
- GOverlay knows the install path of each card: `<library>/common/<installdir>` for Steam, the game folder or `.AppImage` file for non-Steam folders (used for Heroic, Lutris and others).

## Goals / Non-Goals

**Goals:**
- One launch option for all games and all launchers.
- No migration: existing per-game launch options and folders keep working.

**Non-Goals:**
- Layering global and game settings (#418).
- Removing the per-game bgmod copies (still needed for explicit per-game launch options).
- Launcher-specific IDs (Steam AppID, Heroic app name, Lutris slug).

## Decisions

1. **Match by game directory, not by launcher ID.** A single rule for every launcher keeps maintenance low. Steam AppIDs would cover Steam only; Heroic and Lutris IDs are not known to GOverlay for folder-based cards. bgmod already needs `GameDir`; if it cannot be resolved, bgmod cannot install anything for the game either, so falling back to global adds no new failure mode.
2. **Explicit toggle, identity in a separate file.** Selecting a game card can already write a `bgmod.conf` (silent OptiScaler/vkNemu saves during loading), so the existence of `bgmod.conf` cannot mean "the user wants a game profile". The user decides via "Use game-specific settings" in the card context menu; GOverlay stores it with the install path in `goverlay-profile.conf` (`[Profile] NAME=`, `GAME_PATH=`, `ENABLED=`). A separate file also avoids hooking the ~40 code paths that write `bgmod.conf`. bgmod only considers folders with a `bgmod.conf`; an identity file must say `ENABLED=1`. Folders without an identity file (profiles from before this change) match only via the `GAME_DIR` cache, which bgmod writes solely when started from that per-game copy, i.e. after an explicit per-game launch option. Turning the toggle on clones the global configuration when the game has no `bgmod.conf` yet, and creates a minimal one when there is no global `bgmod.conf` to clone either. Card selection only refreshes `NAME`/`GAME_PATH` of an existing identity file. Alternatives: suppress the silent saves on card load (about 15 call sites, fragile) or infer a profile from enabled tools in `bgmod.conf` (unreliable, global MangoHud state is copied on click).
3. **Matching rule.** Candidates per profile: `GAME_PATH` from the identity file and the cached `GAME_DIR` from `bgmod.conf`. A directory candidate matches when the resolved `GameDir` equals it or lies below it; a file candidate (AppImage) matches the full resolved executable path. Paths are normalised with `realpath` (Steam library symlinks such as `~/.steam/steam`). `/` and `$HOME` are never accepted as candidates. The longest matching candidate wins; ties are resolved alphabetically by folder name and logged.
4. **Explicit path wins.** Resolution only runs when bgmod starts from `gameconfig/global/` or the legacy `bgmod/` folder.
5. **Opt-out.** `RUNTIME_PROFILE` in `[Config]` of the global `bgmod.conf`, default `1`. GOverlay mirrors it in `goverlay.conf` `[General] RuntimeProfile` and in the settings menu.
6. **Early game directory resolution.** In global mode with the setting on, `ResolveGameDirectory` runs before `bgmod.conf` is read, and the later call is skipped. After switching to a game profile, if no target executable is known yet, the cached `TARGET_EXE` of the selected profile is read.
7. **Profile switch.** A match sets `ProfileDir`/`ConfigDir` to the game folder, `SourceDir` via `GetGlobalBGModPath(ProfileDir)`, `IsPerGameProfile`, backups folder and the central log folder exactly as if bgmod had been started from the per-game copy.

## Risks / Trade-offs

- Two profiles pointing at overlapping paths: longest match wins, tie logged.
- Flatpak GOverlay writes host paths from `TConfigManager.GetHostDataDir`; Steam library paths come from the host home, so they match bgmod's view. Not verified on a Flatpak Steam.
- A game launched through a generic runner whose arguments do not reveal the game directory resolves to global. Same limitation as today for DLL installation.

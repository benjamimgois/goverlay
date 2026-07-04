## Why

The current single pristine cache `.bgmod_original` causes channel leaks between stable and bleeding-edge builds. When a user downloads bleeding-edge, the shared cache is overwritten, causing subsequently initialized or toggled-on games to receive the bleeding-edge version instead of stable (even when stable is selected). Additionally, all OptiScaler DLLs are copied to game folders during seeding, even if the user only wanted MangoHud or vkBasalt.

## What Changes

- Rename `.bgmod_original` to `optiscaler-stable` and introduce `optiscaler-edge` to separate the downloaded caches of both channels.
- Keep `bgmod/` as a template folder holding ONLY the wrapper launch scripts (`bgmod`, `bgmod-uninstaller`, and a default `goverlay.vars` baseline).
- Seeding / toggle-on of any tool (MangoHud/vkBasalt) will copy only the scripts from `bgmod/` (no OptiScaler DLLs copied).
- OptiScaler toggle ON will copy the DLLs and plugins from either `optiscaler-stable` or `optiscaler-edge` depending on the channel configured for the game.
- Update `optiscaler_update.pas`, `bgmod_resources.pas`, `sidebar_nav.pas`, `games_tab.pas`, `bgmod.lpr` and `bgmod-uninstaller.lpr` to support the new modular cache and sync system.

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier (e.g., user-auth, data-export, api-rate-limiting). Each creates specs/<name>/spec.md -->

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->
- `bgmod-update-optiscaler`: Cache and sync isolation between stable and bleeding-edge channels, copying OptiScaler files only when the tool is explicitly enabled.

## Impact

- `bgmod_resources.pas`: Startup initialization, cache path definitions, global sync logic.
- `optiscaler_update.pas`: Update checking and installation paths.
- `sidebar_nav.pas`: Seeding/copying logic on toggle ON.
- `games_tab.pas`: Game selection stable script seeding.
- `bgmod.lpr`: Launch wrapper backup/sync logic.
- `bgmod-uninstaller.lpr`: Standalone uninstaller cleanup DLL size checks.

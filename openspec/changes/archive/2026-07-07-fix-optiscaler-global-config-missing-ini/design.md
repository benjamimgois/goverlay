## Context

GOverlay configures OptiScaler through `bgmod.conf`, `fakenvapi.ini`, `goverlay.vars`, and `OptiScaler.ini` files. 

For game profiles, when the game is toggled, GOverlay clones the entire pristine directory structure (including `OptiScaler.ini` template) from the cache folder into the game config folder. 

For the global profile, GOverlay initializes the global directory `gameconfig/global/` using `InitializeGlobalConfigDirectory` which does not copy `OptiScaler.ini` template. During manual updates, `SyncPristineAssetsTo` copies dlls, plugins, and fakenvapi.ini but explicitly avoids copying `OptiScaler.ini` to protect user changes.

Because GOverlay's global config folder starts without `OptiScaler.ini`, `LoadOptiScalerConfig` fails to read it and falls back to default empty settings (Scale 1.0, checkboxes empty). Upon clicking Save, `SaveOptiScalerConfigCore` uses `TConfigFile.Load` to read the file, which returns `False` because the file is missing. As a result, the save logic is bypassed, and the file is never created.

## Goals / Non-Goals

**Goals:**
- Gracefully handle loading OptiScaler settings when `OptiScaler.ini` is missing by falling back to reading from the active channel's cache directory.
- Ensure `OptiScaler.ini` is seeded (copied from the cache folder) during saving if it does not already exist, so the user configuration can be updated and saved.

**Non-Goals:**
- Modifying `InitializeGlobalConfigDirectory` to copy `OptiScaler.ini` on startup (which could overwrite existing customized global profiles).
- Changing any other overlay loaders (vkBasalt, vkSumi, MangoHud) that do not exhibit this issue.

## Decisions

### Decision 1: Seeding template ini on save
When `OptiScalerIniPath` does not exist in `SaveOptiScalerConfigCore`, GOverlay will copy the default template `OptiScaler.ini` from the cache directory corresponding to the active channel (`GetBGModOriginalPath` for stable, `GetBGModOriginalEdgePath` for edge).
- **Alternatives considered**:
  - *Alternative A*: Generate the file from scratch inside Pascal.
    - *Drawback*: `OptiScaler.ini` has dozens of options and a specific structure, replicating it from scratch increases complexity and maintenance overhead.
  - *Alternative B*: Copy it from cache during startup.
    - *Drawback*: Can overwrite existing files or cause issues if the folder structure is not fully prepared yet. Seeding on-demand on save is safer and keeps initialization light.

### Decision 2: Cache loading fallback
In `LoadOptiScalerConfig`, if the file is missing in the destination, GOverlay will fall back to reading from the cache folder.
- **Alternatives considered**:
  - *Alternative A*: Fail silently and use hardcoded defaults.
    - *Drawback*: Leads to empty checkbox values and standard 1.0 scaling even if the cache default had something else, and it confuses the user.
  - *Alternative B*: Copy the file during load.
    - *Drawback*: Modifies disk state just from viewing the tab. It is cleaner to keep disk state unchanged until the user explicitly saves.

## Risks / Trade-offs

- **[Risk]** The cache folder does not contain `OptiScaler.ini` (e.g., download failed or corrupted).
  - *Mitigation*: The copy step will fail silently and the `Load` will still return `False` or fallback. GOverlay will safely use hardcoded defaults in Pascal as it does now.

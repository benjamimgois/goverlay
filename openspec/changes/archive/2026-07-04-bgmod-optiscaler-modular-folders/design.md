## Context

The current single pristine cache `.bgmod_original` is shared between stable and bleeding-edge builds. When a user downloads bleeding-edge, the cache is overwritten, causing subsequently initialized or toggled-on games to receive the bleeding-edge version instead of stable. Additionally, GOverlay copies all OptiScaler files to a game folder on first click, even if OptiScaler is disabled for that game (and they only want MangoHud/vkBasalt).

## Goals / Non-Goals

**Goals:**
- Separate download caches: `optiscaler-stable` (replaces `.bgmod_original`) and `optiscaler-edge`.
- Keep `bgmod/` strictly as a template for core wrapper files (`bgmod`, `bgmod-uninstaller`, `goverlay.vars` baseline).
- Copy only core scripts on first game selection or toggle ON.
- Copy OptiScaler DLLs/plugins only when the OptiScaler toggle is enabled.
- Allow `bgmod` wrapper and `bgmod-uninstaller` to resolve the correct channel template by reading the local `bgmod.conf`'s `OPT_CHANNEL`.

**Non-Goals:**
- Modifying how MangoHud or vkBasalt configuration is processed.

## Decisions

### 1. Channel-Isolated Caches
Rename `.bgmod_original` to `optiscaler-stable` and introduce `optiscaler-edge` in `~/.local/share/goverlay/`.
- **Why**: Keeps stable and bleeding-edge builds completely isolated in user space, preventing channel pollution.
- **Alternatives Considered**: Using a single directory with subfolders. Rejected because path manipulation across multiple files/scripts is less clean than swapping the base directory path.

### 2. Wrapper-Only `bgmod` Template Folder
The `bgmod/` directory in user space will contain only `bgmod`, `bgmod-uninstaller` and a baseline `goverlay.vars`. It will NOT contain `OptiScaler.dll` or FSR/XeSS files.
- **Why**: Allows first-time game seeding to only copy the lightweight launch scripts, preserving clean disk space and isolation.

### 3. Channel-Aware Copying on Toggle ON
Modify `CopyOptiScalerGameFiles` in `sidebar_nav.pas` to read `OPT_CHANNEL` from the game's `bgmod.conf` (if it exists) and copy from `optiscaler-stable` or `optiscaler-edge`.
- **Why**: Ensures that toggling OptiScaler ON installs the correct channel files chosen by the user.

### 4. Dynamic Path Resolution in standalone binaries
Update `GetGlobalBGModPath` in `bgmod.lpr` and `GetBGModPath` in `bgmod-uninstaller.lpr` to read `OPT_CHANNEL` from the local `bgmod.conf` in their directory. They will return `optiscaler-stable` (for stable/default) or `optiscaler-edge` (for bleeding-edge).
- **Why**: Standalone binaries must know which channel templates to use when syncing/validating proxy DLL sizes and directories during execution/uninstallation, without relying on GOverlay UI state.

## Risks / Trade-offs

- **[Risk]** Existing user configurations with old `.bgmod_original` directory.
  - *Mitigation*: In `bgmod_resources.pas` `InitializeBGModDirectory`, rename any legacy `.bgmod_original` folder to `optiscaler-stable` if `optiscaler-stable` doesn't exist yet. Wipe the old `.bgmod_original` directory.

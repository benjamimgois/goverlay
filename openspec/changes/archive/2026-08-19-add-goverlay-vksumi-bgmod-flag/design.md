## Context

See `proposal.md` for motivation. Currently `GOVERLAY_VKBASALT` is the only flag governing both vkBasalt and vkSumi post-processing layers in `bgmod.conf`. In `bgmod.lpr`, `GOVERLAY_VKBASALT=1` unconditionally copies `vkSumi.conf` and exports `ENABLE_VKSUMI=1`. Additionally, `SaveVkSumiConfig` in `overlay_config.pas` overwrites `GOVERLAY_VKBASALT` to `0` when disabled, causing mutual interference between the two tabs.

## Goals / Non-Goals

**Goals:**
- Add `GOVERLAY_VKSUMI` under `[Config]` in `bgmod.conf` and `data/bgmod/bgmod.conf`.
- Provide a clean helper function `IsVkSumiAtDefaults` in `overlay_config.pas` (or `overlayunit.pas`) that checks all 15 trackbar positions against `PARAMS[i].Default`.
- Update `SaveVkSumiConfig` to set `GOVERLAY_VKSUMI := 0` when all sliders are at default (and `enabled = false`) and `GOVERLAY_VKSUMI := 1` when any slider is customized (and `enabled = true`), without modifying `GOVERLAY_VKBASALT`.
- Update `bgmod.lpr` to independently read `GOVERLAY_VKSUMI`, manage `vkSumi.conf` in the game directory, and export `ENABLE_VKSUMI=1`.
- Align `sidebar_nav.pas`, `apputils.pas`, uninstaller logic, and automated tests.

**Non-Goals:**
- Altering vkBasalt effect selection or shaders syntax.
- Changing vkSumi color grading algorithms or parameter ranges.

## Decisions

### 1. Default Detection via `PARAMS[i].Default` comparison
- **Decision**: Evaluate all 15 trackbar values against `PARAMS[i].Default`. If all 15 equal their defaults, `GOVERLAY_VKSUMI` is set to `0` (disabled); otherwise `1` (enabled).
- **Rationale**: Clean, fully automatic, zero user friction. If a user resets or keeps default settings, no Vulkan layer overhead is incurred.
- **Alternatives Considered**:
  - *Explicit checkbox on vkSumi tab*: Adds UI clutter when neutral defaults already represent a disabled state.
  - *Checking if `vkSumi.conf` file exists*: The file exists globally even with default parameters, so checking values is more accurate.

### 2. Independent Injection and File Copying in `bgmod.lpr`
- **Decision**:
  - `GOverlayVkBasalt`: copies/deletes `vkBasalt.conf` and exports `ENABLE_VKBASALT=1`.
  - `GOverlayVkSumi`: copies/deletes `vkSumi.conf` and exports `ENABLE_VKSUMI=1`.
- **Rationale**: Isolates layer overhead, eliminates side-effects, and allows enabling vkBasalt, vkSumi, both, or neither.

### 3. Backwards Compatibility for Existing Game Configs
- **Decision**: If `GOVERLAY_VKSUMI` is missing from `bgmod.conf`, `bgmod.lpr` defaults it to `'0'`.
- **Rationale**: Avoids unexpected layer injection for legacy configs that only intended to run vkBasalt.

## Risks / Trade-offs

- [Risk] Missing `GOVERLAY_VKSUMI` key in older game configs → Mitigation: Safe fallback to `'0'` in `Ini.ReadString('Config', 'GOVERLAY_VKSUMI', '0')`.
- [Risk] Accidental vkSumi toggle on minor trackbar click → Mitigation: Resetting all sliders to default (or loading a default preset) immediately restores `GOVERLAY_VKSUMI=0`.

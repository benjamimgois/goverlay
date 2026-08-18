## Context

`bgmod` is the unified execution wrapper for GOverlay, managing configuration and environment variables via `bgmod.conf`.
The Lossless Scaling tab configures `lsfg-vk` settings that map directly to `LSFGVK_*` environment variables.
See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Unify Lossless Scaling configuration persistence directly in `bgmod.conf` under `[Config]` and `[Env]`.
- Support seamless loading and saving for both global (`gameconfig/global/bgmod.conf`) and per-game (`gameconfig/<game>/bgmod.conf`) profiles.
- Enable `bgmod.lpr` to export `LSFGVK_*` variables when `GOVERLAY_LOSSLESS=1`.
- Clean up `LSFGVK_*` keys when Lossless Scaling is disabled.

**Non-Goals:**
- Modifying OptiScaler, MangoHud, or vkBasalt configuration formats.
- Rewriting the UI layout of the Lossless Scaling tab.

## Decisions

### 1. Structure in `bgmod.conf`
- Under `[Config]`:
  - `GOVERLAY_LOSSLESS = 1` or `0`
- Under `[Env]`:
  - `LSFGVK_ENV = 1`
  - `LSFGVK_DLL_PATH = <path>`
  - `LSFGVK_MULTIPLIER = 2|3|4|5|6`
  - `LSFGVK_FLOW_SCALE = <float>` (e.g. `0.9` if < 100%)
  - `LSFGVK_PERFORMANCE_MODE = 1` (omitted if disabled)
  - `LSFGVK_HDR_MODE = 1` (omitted if disabled)
  - `LSFGVK_NO_FP16 = 1` (omitted if disabled)
  - `LSFGVK_PACING = vsync|mailbox|immediate|none` (omitted if auto)
  - `LSFGVK_GPU = <index>` (omitted if auto/-1)

### 2. Wrapper Export Logic (`bgmod.lpr`)
- `bgmod.lpr` checks `GOverlayLossless := Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0') = '1'`.
- In the environment variable export loop:
  `if (Key = 'MANGOHUD_CONFIGFILE') or (Key = 'DXIL_SPIRV_CONFIG') or (GOverlayLossless and (Pos('LSFGVK_', Key) = 1)) or GOverlayTweaks then`
- This ensures `LSFGVK_*` variables are exported when Lossless Scaling is enabled.

### 3. Cleanup on Deactivation
- When disabled or DLL invalid:
  - `Ini.WriteString('Config', 'GOVERLAY_LOSSLESS', '0');`
  - Delete all `LSFGVK_*` keys from `[Env]` to keep `bgmod.conf` clean and avoid unexpected variable leaks.

## Risks / Trade-offs

- [Risk] Existing `lossless_scaling.conf` files may be ignored → [Mitigation] On initial migration, if `bgmod.conf` doesn't have `LSFGVK_*` variables but `lossless_scaling.conf` exists, import the values into `bgmod.conf`.

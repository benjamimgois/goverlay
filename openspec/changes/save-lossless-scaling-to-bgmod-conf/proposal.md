## Why

Lossless Scaling (`lsfg-vk`) configuration operates entirely via `LSFGVK_*` environment variables. Currently, settings are stored in an isolated config file (`lossless_scaling.conf`). By storing Lossless Scaling settings directly in `bgmod.conf` under `[Config]` (`GOVERLAY_LOSSLESS=1/0`) and `[Env]` (`LSFGVK_*`), we establish a single source of truth, eliminate redundant files, natively support global and per-game profiles, and allow the `bgmod` execution wrapper to seamlessly inject the environment variables when launching games.

## What Changes

- Store Lossless Scaling toggle state (`GOVERLAY_LOSSLESS=1` or `0`) in `bgmod.conf` under the `[Config]` section.
- Store all active Lossless Scaling parameters (`LSFGVK_ENV=1`, `LSFGVK_DLL_PATH`, `LSFGVK_MULTIPLIER`, `LSFGVK_FLOW_SCALE`, `LSFGVK_PERFORMANCE_MODE`, `LSFGVK_HDR_MODE`, `LSFGVK_NO_FP16`, `LSFGVK_PACING`, `LSFGVK_GPU`) in `bgmod.conf` under the `[Env]` section.
- When Lossless Scaling is disabled, clean up/remove all `LSFGVK_*` keys from `[Env]` and set `GOVERLAY_LOSSLESS=0` in `[Config]`.
- Update `bgmod.lpr` to parse `GOVERLAY_LOSSLESS` from `[Config]` and automatically export all `LSFGVK_*` variables found in `[Env]` to the game execution environment.
- Update `lossless_scaling_tab.pas` to load from and save directly to `bgmod.conf` (both global `gameconfig/global/bgmod.conf` and per-game `gameconfig/<game>/bgmod.conf`).

## Capabilities

### New Capabilities
- `lossless-scaling-bgmod-sync`: Requirements and behavior for storing, loading, and exporting Lossless Scaling environment variables via `bgmod.conf` and the `bgmod` wrapper.

### Modified Capabilities

## Impact

- `lossless_scaling_tab.pas`: Replaces `lossless_scaling.conf` I/O with `bgmod.conf` `[Config]` and `[Env]` section manipulation.
- `bgmod.lpr`: Reads `GOVERLAY_LOSSLESS` and exports `LSFGVK_*` environment variables during wrapper startup.
- `games_tab.pas` / `overlay_config.pas`: Seamless compatibility with per-game and global profile paths.

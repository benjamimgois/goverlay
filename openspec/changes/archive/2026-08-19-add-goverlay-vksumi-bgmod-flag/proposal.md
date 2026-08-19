## Why

Currently, `bgmod.conf` uses a single `GOVERLAY_VKBASALT` flag to control both vkBasalt and vkSumi post-processing layers. This causes unnecessary overhead (injecting `ENABLE_VKSUMI=1` and copying `vkSumi.conf` even when all 15 vkSumi color grading sliders are at their neutral/default positions) and risks accidental cross-tab setting resets. Introducing a dedicated `GOVERLAY_VKSUMI` flag decouples vkSumi from vkBasalt, enabling intelligent, zero-overhead injection only when vkSumi parameters are actually customized.

## What Changes

- **New `GOVERLAY_VKSUMI` Config Flag**: Added to `bgmod.conf` template under `[Config]`.
- **Automatic Default Detection**: When saving vkSumi configuration, `GOVERLAY_VKSUMI` is set to `0` if all 15 parameter sliders match their default neutral positions; if any parameter is customized, `GOVERLAY_VKSUMI` is set to `1`.
- **Decoupled vkSumi Save**: `SaveVkSumiConfig` writes `GOVERLAY_VKSUMI` without overwriting or interfering with `GOVERLAY_VKBASALT`.
- **`bgmod` Injection Decoupling**: `bgmod.lpr` independently checks `GOVERLAY_VKBASALT` and `GOVERLAY_VKSUMI`, copying config files and exporting environment variables (`ENABLE_VKBASALT=1`, `ENABLE_VKSUMI=1`) strictly based on their respective flags.
- **Environment & Launcher Script Alignment**: Align shell templates, uninstaller cleanups, and tests to handle both flags independently.

## Capabilities

### New Capabilities
- `vksumi-bgmod-flag`: Dedicated `GOVERLAY_VKSUMI` configuration flag and automatic default detection logic for vkSumi post-processing injection.

### Modified Capabilities
<!-- No requirement changes to existing capability specs -->

## Impact

- `bgmod.conf` & `data/bgmod/bgmod.conf`: Added `GOVERLAY_VKSUMI=0`.
- `bgmod.lpr`: Reads `GOVERLAY_VKSUMI` and isolates `ENABLE_VKSUMI` export / `vkSumi.conf` copy.
- `overlay_config.pas`: Updates `SaveVkSumiConfig` and default detection logic.
- `overlayunit.pas`: Helper for determining if vkSumi sliders are at neutral defaults.
- `sidebar_nav.pas`: Decouples flag parsing and export generation.
- `tests/`: GUI and logic tests verifying flag behavior and slider default detection.

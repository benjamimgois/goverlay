# Proposal

## Why

Currently, frame generation options in GOverlay are split or limited to proprietary Windows-based binaries (`lsfg-vk` and `MAKO`, under a tab named "Lossless Scaling"). An open-source, driver-level implementation of AMD Fluid Motion Frames for Linux (`afmf-linux`) has emerged as a Vulkan implicit layer, providing native optical-flow frame generation without Windows DLL dependencies. Furthermore, `afmf-linux` is incompatible with concurrent frame generation or injection layers (such as `lsfg-vk` and OptiScaler). Unifying the tab as "Frame Interpolation" and integrating AFMF alongside LSFG and MAKO provides a cohesive frame generation suite while preventing conflicting tools from running concurrently.

## What Changes

- Rename the "Lossless Scaling" tab to **"Frame Interpolation"** across the GOverlay UI, page controls, and menus.
- Add **AFMF (AMD Fluid Motion Frames)** as a new selectable engine in the Method selector (`None`, `lsfg-vk`, `MAKO`, `AFMF`), ensuring mutual exclusivity among interpolation engines.
- Add an official banner/icon asset for the AFMF method (`method_afmf.png`) adhering to the existing visual styling used by `method_vkbasalt.png`, `method_lsfg.png`, and `method_mako.png` (squircle icon with uniform styling, active 100% brightness, dimmed 35% brightness when unselected).
- Add AFMF configuration cards dynamically displayed when AFMF is the active method:
  - **Performance & Search Mode**: `AFMF_PERFORMANCE_MODE` (auto, quality, performance), `AFMF_SEARCH_MODE` (auto, standard, high), `AFMF_FAST_MOTION_RESPONSE` (blend, repeat).
  - **Pacing & Cadence**: `AFMF_PACING` (toggle), `AFMF_PRESENT_MODE` (auto, keep), `AFMF_GOVERNOR` (toggle), `AFMF_MIN_FPS` (slider/spin).
  - **Optimizations & Compatibility**: `AFMF_HUD_DETECT` (toggle), `AFMF_GAMESCOPE` (toggle / auto-detected), `AFMF_DIRECT_INGEST` (toggle), `AFMF_DIRECT_OUTPUT` (toggle), `AFMF_STATIC_BLOCK_SAD` (slider).
  - **Diagnostics**: `AFMF_LOG` (level selector), `AFMF_PROFILE` (toggle).
- Add status detection for the `afmf-linux` Vulkan layer (`libafmf-linux.so` / `afmf-linux.json` under standard implicit layer directories).
- Implement a mutual conflict resolution dialog between AFMF and OptiScaler / DLSS Enabler:
  - If OptiScaler or DLSS Enabler is enabled when the user selects AFMF, display an alert dialog explaining the incompatibility and offering to disable OptiScaler (switching its radio to "None").
  - If AFMF is active and the user enables OptiScaler or DLSS Enabler, display a corresponding dialog offering to switch the Frame Interpolation method to "None".
- Update `bgmod.lpr` and environment variable serialization:
  - Support `INTERPOLATION_METHOD = afmf` in `bgmod.conf`.
  - When `afmf` is active, export `AFMF_ENABLE=1`, `DISABLE_LSFGVK=1` (as strongly recommended by upstream `afmf-linux`), and all configured `AFMF_*` environment variables.
  - Update launch splash display to indicate "AMD Fluid Motion Frames (AFMF)".
- Update PasCube / vkcube preview launch to include AFMF environment variables when AFMF is selected.

## Capabilities

### New Capabilities
- `afmf-frame-interpolation`: Manages detection, configuration cards, environment variable serialization, and execution of the `afmf-linux` Vulkan layer within GOverlay.

### Modified Capabilities
- `lossless-scaling-config`: Rename tab and references to "Frame Interpolation", expand the Method selector with the AFMF engine and custom icon banner, and implement mutual conflict handling between Frame Interpolation methods and OptiScaler.

## Impact

- **UI**: `lossless_scaling_tab.pas` (renamed or updated helper), `overlayunit.pas` (tab captions, page control references, conflict handling), `optiscaler_tab.pas` (conflict handling).
- **Backend**: `bgmod.lpr` (environment variable export, layer suppression, splash screen), `bgmod.conf` (`INTERPOLATION_METHOD=afmf` and `AFMF_*` keys).
- **Assets**: New icon `assets/icons/method_afmf.png` (and dimmed variant if generated at runtime or stored in assets).

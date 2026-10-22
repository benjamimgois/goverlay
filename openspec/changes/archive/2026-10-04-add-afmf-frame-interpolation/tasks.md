# Tasks

## 1. Assets and UI Renaming

- [x] 1.1 Create `assets/icons/method_afmf.png` matching the visual format and squircle style of `method_vkbasalt.png`, `method_lsfg.png`, and `method_mako.png`, and verify the PNG is readable and non-empty.
- [x] 1.2 Rename all UI captions, page control sheets, menu entries, and log messages from "Lossless Scaling" to "Frame Interpolation" in `overlayunit.pas`, `lossless_scaling_tab.pas`, and `sidebar_nav.pas`, and verify GOverlay compiles cleanly.

## 2. Method Selector and AFMF UI Cards

- [x] 2.1 Add `imAfmf` to `TInterpolationMethod` enum and integrate the AFMF radio button and banner image into the Method card in `lossless_scaling_tab.pas`.
- [x] 2.2 Build the AFMF configuration cards (Performance & Search Mode, Cadence & Pacing, Optimizations & Gamescope, Diagnostics) with responsive Material Design 3 card styling.
- [x] 2.3 Implement dynamic card visibility switching so AFMF cards are shown only when `imAfmf` is active, LSFG/MAKO cards are shown when `imLsfg`/`imMako` is active, and controls are disabled when `imNone` is active.
- [x] 2.4 Add `afmf-linux` Vulkan implicit layer status detection (`afmf-linux.json` and `libafmf-linux.so`) to the Software Status card with status indicator dot and path display.

## 3. Mutual Conflict Guard with OptiScaler

- [x] 3.1 Implement conflict confirmation dialog when selecting AFMF while OptiScaler or DLSS Enabler is active, switching OptiScaler to None upon user confirmation.
- [x] 3.2 Implement conflict confirmation dialog when activating OptiScaler or DLSS Enabler while AFMF is active, switching the Frame Interpolation method to None upon user confirmation.

## 4. Configuration Persistence and Execution Backend

- [x] 4.1 Implement persistence of `INTERPOLATION_METHOD = afmf` and all `AFMF_*` keys in `bgmod.conf` for both per-game and global profiles.
- [x] 4.2 Update `bgmod.lpr` to export `AFMF_ENABLE=1`, `DISABLE_LSFGVK=1`, and configured `AFMF_*` environment variables when `INTERPOLATION_METHOD=afmf`, and update the splash screen item to "AMD Fluid Motion Frames (AFMF)".
- [x] 4.3 Update PasCube and vkcube preview invocation in `overlayunit.pas` to include AFMF environment variables when previewing with AFMF selected.

## 5. Verification and Build Integrity

- [x] 5.1 Compile GOverlay and `bgmod` with `make` and verify that the build succeeds with no warnings or syntax errors.
- [x] 5.2 Verify that toggling between None, lsfg-vk, Mako, and AFMF persists cleanly to `bgmod.conf` and generates the correct launch environment.

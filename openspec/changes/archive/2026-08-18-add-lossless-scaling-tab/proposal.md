# Proposal: Add Lossless Scaling Tab under Upscalers

## Problem Statement
The open-source project `lsfg-vk` brings Lossless Scaling Frame Generation (LSFG) capabilities to Linux via Vulkan layers, controlled purely through environment variables (`LSFGVK_ENV=1`, `LSFGVK_DLL_PATH`, `LSFGVK_NO_FP16`, `LSFGVK_MULTIPLIER`, `LSFGVK_FLOW_SCALE`, `LSFGVK_PERFORMANCE_MODE`, `LSFGVK_PACING`, `LSFGVK_GPU`). 

Currently, GOverlay users can only configure OptiScaler / DLSS Enabler under the "Upscalers" sidebar item. Furthermore, the official GUI from `lsfg-vk` has a very simple, isolated layout lacking system integration (like auto-detecting Steam install paths, real GPU device detection, and command line preview) and does not adhere to GOverlay's modern design system.

## Proposed Solution
1. **Sidebar & Tab Navigation Restructuring**:
   - When the user clicks on the "Upscalers" item in the sidebar nav rail, display the top tab sheet bar with two tabs:
     - **OptiScaler** (existing `optiscalerTabSheet`)
     - **Lossless Scaling** (new `losslessScalingTabSheet`)
   - Maintain the standard GOverlay tab visibility switching pattern (mirroring the Post-processing `vkBasalt` / `vkSumi` tabs).

2. **Modernized GOverlay-Styled Interface (`lossless_scaling_tab.pas`)**:
   - Organize the interface into coherent GOverlay semantic cards (`StyleMainCard` / `StyleSubCard` with `#1A1E2E` background and `#202634` borders):
     - **General & Engine Setup Card**:
       - `Path to Lossless.dll` (`LSFGVK_DLL_PATH`) with a text input, browse file button (`📁`), an "Auto-detect from Steam" button (`~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll`), and a status badge indicator (green when found, red when missing).
     - **Frame Generation Core Card**:
       - `Multiplier` (`LSFGVK_MULTIPLIER`): Disjoint segment buttons or ComboBox with options `2x`, `3x`, `4x`.
       - `Flow Scale` (`LSFGVK_FLOW_SCALE`): Slider / Trackbar with live percentage label (`25%` to `100%` / `0.25` to `1.0`) and explanatory tooltip.
       - `Performance Mode` (`LSFGVK_PERFORMANCE_MODE`): Modern toggle switch / checkbox.
     - **Hardware & Pacing Card**:
       - `Disable FP16` (`LSFGVK_NO_FP16`): Toggle for compatibility with older / problematic GPUs.
       - `Pacing Mode` (`LSFGVK_PACING`): ComboBox with friendly options (`Auto / Recommended`, `VSync / FIFO`, `Mailbox / Fast Sync`, `Immediate / Uncapped`, `None`).
       - `Target GPU` (`LSFGVK_GPU`): ComboBox populated with real system GPU device names detected via `systemdetector.pas` (e.g. `Auto (Primary Device)`, `AMD Radeon 780M (iGPU)`, `NVIDIA GeForce RTX 4070 (dGPU)`).
     - **Live Command & Environment Preview Card**:
       - Interactive preview box displaying the exact environment variable string (`LSFGVK_ENV=1 ... %command%`) with a copy button.

3. **Settings Persistence & Per-Game Support**:
   - Persist settings in `~/.config/goverlay/lossless_scaling.ini` for global mode.
   - Integrate with `games_tab.pas` and `bgmod` to allow enabling and applying Lossless Scaling environment variables per game.

## Impact
- Expands GOverlay's upscaling and frame generation ecosystem to support Lossless Scaling (`lsfg-vk`).
- Improves usability with automatic Steam path detection and friendly GPU hardware labels.
- Integrates seamlessly with GOverlay's design system and per-game configuration architecture.

## Context

Goverlay currently provides a Lossless Scaling tab (`lossless_scaling_tab.pas`) and `bgmod` wrapper logic that generates legacy `lsfg.toml` (version = 1) files for the original `lsfg-vk` layer. The upstream project has since rebranded and evolved into MAKO (*Motion-Adaptive Kernel Orchestration*), which introduces standalone tarball releases, an automated installer, independent spatial upscaling (LS1 and MAKO Scaler), Adaptive Frame Generation, and a canonical `conf.toml` (version = 2) specification. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Replace `lsfg-vk` with MAKO Renderer across UI, config generators, launch runners, and dependency checkers.
- Provide automated dynamic download and headless installation during application boot via `TStartupDownloadThread` on the splash screen, identical to OptiScaler, DLSS-Enabler, and vkSumi.
- Provide on-demand update checking and reinstallation from the Lossless Scaling tab.
- Redesign the Lossless Scaling tab into three logical cards:
  - **Card 0 (Engine & Model)**: MAKO version status, Update/Install action buttons, and `Lossless.dll` inspection via `mako-cli inspect-dll`.
  - **Card 1 (Frame Generation)**: Fixed Multiplier (2x–5x) vs Adaptive Frame Generation (Target FPS 30–240, Max Multiplier, Steady 2x Cap), plus flow scale, FP16, and lighter model toggles.
  - **Card 2 (Spatial Scaling)**: Independent upscaler configuration (LS1 Quality/Performance, MAKO Scaler, Native, Scale Factor 1.0–2.0, Sharpness 0.0–1.0, Supersampling).
- Generate canonical `conf.toml` (version = 2) per game profile.
- Export necessary layer activation and isolation variables (`ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, `DISABLE_GAMESCOPE_WSI=1`, `DISABLE_LSFG=1`, `DISABLE_LSFGVK=1`).

**Non-Goals:**
- Managing or altering the proprietary `Lossless.dll` binary (users supply their own legal Steam copy).
- Supporting Steam Deck Decky Loader plugin installations inside Goverlay (MAKO Decky is managed directly through Decky Loader on SteamOS; Goverlay manages the desktop/standalone Vulkan layer).

## Decisions

### 1. Headless Installation Using Packaged `bin/mako-installer`
- **Choice**: Extract downloaded `MAKO-Renderer-*.tar.xz` into a temporary directory and invoke:
  `MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1 ./bin/mako-installer --install`
- **Rationale**: The official installer handles placing 64-bit (`.local/lib`) and 32-bit (`.local/lib32`) libraries, implicit layer JSON manifests (`.local/share/vulkan/implicit_layer.d`), desktop icons, and active state JSON (`.local/share/mako-render/active-renderer.json`) reliably without duplicating filesystem logic in Pascal.
- **Alternatives Considered**: Manually unpacking and moving `.so` and `.json` files. Rejected because it risks desynchronization with future release layout changes.

### 2. Startup Boot-Time Provisioning in `TStartupDownloadThread`
- **Choice**: Integrate `CheckAndInstallMako(False, @OnDownloadProgress)` inside `TStartupDownloadThread.Execute` in `overlayunit.pas`, allocating a progress bracket (e.g. 75%–95%) alongside OptiScaler, DLSS-Enabler, and vkSumi.
- **Rationale**: Ensures the layer is immediately ready on first launch without requiring the user to manually discover an install button or configure terminal commands.

### 3. Canonical `conf.toml` Version 2 Serialization
- **Choice**: Serialize game configurations to `conf.toml` containing:
  ```toml
  version = 2
  dll = "/path/to/Lossless.dll"
  allow_fp16 = true

  [[profile]]
  name = "Game"
  active_in = ["pascube", "vkcube", "<game_exe>"]
  multiplier = 2
  frame_generation_enabled = true
  frame_generation_refresh_threshold = 0
  base_fps_cap = 0
  flow_scale = 0.90
  performance_mode = false
  adaptive = false
  target_fps = 90
  adaptive_max_multiplier = 2
  adaptive_auto_base_fps_cap = false
  scaling_enabled = false
  scaling_method = "ls1"
  scaling_factor = 1.5
  scaling_sharpness = 0.8
  scaling_supersampling = false
  pacing = "none"
  ```
- **Rationale**: MAKO ignores unknown keys and strictly enforces `version = 2`. Writing canonical profiles ensures compatibility with both direct layer execution and `mako-ui` / `mako-cli`.

### 4. Integration with `mako-cli inspect-dll`
- **Choice**: When a valid DLL path is set, invoke `mako-cli inspect-dll -d <path>` and parse output lines (`LSFG FP32 Quality`, `LSFG FP16 Quality`, `LS1 Quality resources`) to populate visual status labels.
- **Rationale**: Gives users immediate, precise diagnostic feedback on whether their installed Steam copy of Lossless Scaling supports all engine capabilities.

## Risks / Trade-offs

- **[Risk]** Existing user configurations in `lsfg.toml` might be lost.
  - **Mitigation**: The config loader will inspect both `conf.toml` and existing `lsfg.toml` during transition, importing existing DLL paths, multipliers, and flow scales into the new format.
- **[Risk]** Conflicting LSFG layers present on the user's system.
  - **Mitigation**: Launch commands and `bgmod` will explicitly export `DISABLE_LSFG=1` and `DISABLE_LSFGVK=1` alongside `ENABLE_MAKO=1`.
- **[Risk]** Gamescope WSI FIFO collapse when frame generation is active.
  - **Mitigation**: Export `DISABLE_GAMESCOPE_WSI=1` and `MAKO_DISABLE_HDR_EXPOSURE=1` during launch, matching `mako-launch`'s proven safety boundary.

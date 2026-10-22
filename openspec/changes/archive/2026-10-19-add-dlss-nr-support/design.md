# Design

## Context

Goverlay currently manages multiple upscaling and frame generation methods in the OptiScaler tab (`optiscaler_tab.pas`), including OptiScaler, DLSS Enabler, and HelixSR. Each method manages its own companion libraries, configuration options, and game deployment logic.

NVIDIA DLSS 5 Neural Rendering (DLSS-NR) is now executable on AMD hardware via two open-source Vulkan projects:
- **RDNA4 (`mochizuki0323/DLSSNR-AMD`)**: Native implementation leveraging RDNA4 FP8 WMMA matrix instructions (`VK_KHR_cooperative_matrix`).
- **RDNA3 (`mauri870/DLSSNR-RDNA3`)**: Port emulating FP8 arithmetic across RDNA3 FP16 matrix instructions with constant-offset ALU rounding.

Both projects share the same runtime architecture, routes (`optiscaler`, `reshade-feeder`, `vulkan`, `dx9`), and require proprietary model weights extracted from NVIDIA's `nvngx_dlssnr.dll` (v310.9.16 or v310.8.0).

## Goals / Non-Goals

**Goals:**
- Add "DLSS-NR" as the fourth upscaler method in Goverlay's OptiScaler tab with visual radio selection and brightness highlighting.
- Provide automatic GPU architecture detection (RDNA3 vs RDNA4) with manual override.
- Provide automated downloading and caching of central runtime packages for both RDNA3 and RDNA4.
- Provide a one-time weights extraction tool from user-provided `nvngx_dlssnr.dll` into a shared central cache (`dlssnr.bin` and `dlssnr-small.bin`).
- Implement direct file deployment into game directories (proxy DLL, backend library, model binaries, and `dlssnr-amd.ini`), without calling external installer scripts.
- Display DLSS-NR version and readiness in the Home tab's Software Status.
- Expose key tuning parameters: Route, Model Version (New 310.9.16 vs Old 310.8.0), Model Resolution Scale (default 50% on RDNA3), Int4 Mixed, RenoDX Style, and Preprocess Auto-exposure.

**Non-Goals:**
- Compiling neural shader kernels from source (pre-built release packages are used).
- Distributing proprietary NVIDIA DLLs or weights directly with Goverlay.
- Supporting architectures older than RDNA3 (RDNA2, RDNA1, and older architectures lack the required matrix instruction hardware).

## Decisions

### Decision 1: Direct File Copy Deployment vs. Calling `install.sh`
- **Choice**: Direct file deployment managed by Goverlay Pascal backend.
- **Rationale**: Calling `install.sh` from Goverlay introduces shell quoting risks, environment discrepancies under Flatpak/Proton, and unwanted interactive terminal prompts. Direct file copy mirrors Goverlay's existing proven architecture for OptiScaler, HelixSR, and Lossless Scaling.
- **Alternatives Considered**: Spawning `bash install.sh` as a child process. Rejected due to brittle stdout parsing and inconsistency with existing codebase patterns.

### Decision 2: Central Storage and Shared Model Directory Structure
- **Choice**: Structure central cache under `~/.config/goverlay/dlss-nr/`:
  - `rdna4/`: Binaries, OptiScaler-NR, and ReShade feeder from `mochizuki0323/DLSSNR-AMD`.
  - `rdna3/`: Binaries, OptiScaler-NR, and ReShade feeder from `mauri870/DLSSNR-RDNA3`.
  - `models/`: Shared extracted `dlssnr.bin` and `dlssnr-small.bin` models.
- **Rationale**: Model weights are bit-identical between RDNA3 and RDNA4; storing them in a shared directory avoids duplicating 140MB+ model files and allows a single extraction step to serve both architectures.

```
~/.config/goverlay/dlss-nr/
├── models/
│   ├── dlssnr.bin             (Old model, 310.8.0)
│   └── dlssnr-small.bin       (New model, 310.9.16)
├── rdna3/
│   ├── goverlay.vars          (Version tags)
│   └── ...
└── rdna4/
    ├── goverlay.vars          (Version tags)
    └── ...
```

### Decision 3: GPU Architecture Detection Heuristic
- **Choice**: Enhance `systemdetector.pas` with a dedicated `DetectRDNAArchitecture: TRDNAArch` function:
  - Returns `rdna4` if renderer string matches `navi4`, `gfx12`, or `RX 9`.
  - Returns `rdna3` if renderer string matches `navi3`, `gfx11`, `RX 7`, `780M`, or `890M`.
  - Returns `rdnaUnsupported` otherwise.
- **Rationale**: Uses already verified Mesa/glxinfo strings in Goverlay. The UI architecture selector defaults to `Auto-detect (<detected>)` but allows the user to manually select RDNA3 or RDNA4.

### Decision 4: Adaptive Defaults based on Architecture
- **Choice**: Default Model Resolution Scale to 50% when RDNA3 is active, and 100% when RDNA4 is active.
- **Rationale**: Benchmark data shows RDNA3 requires ~56ms at 4K native, but dropping scale to 50% reduces compute time to ~16ms, making 1440p/4K playable.

## Risks / Trade-offs

- **[Risk: Incompatible or corrupted `nvngx_dlssnr.dll`]** → **Mitigation**: Implement strict SHA-256 validation against known hashes for 310.9.16 and 310.8.0 before saving models to central storage, displaying descriptive feedback if verification fails.
- **[Risk: Anti-cheat bans in multiplayer games]** → **Mitigation**: Add a prominent warning badge in the DLSS-NR configuration panel indicating that injected proxy DLLs carry ban risks and must only be used in single-player or offline titles.
- **[Risk: Flatpak sandbox confinement]** → **Mitigation**: Ensure all download and file operations use Flatpak-aware configuration paths via Goverlay's established path resolution helpers.

# Design

## Context

GOverlay currently provides a Method card in the OptiScaler tab with three options: "None", "OptiScaler", and "DLSS Enabler", serialized as `UPSCALER_TYPE` (0 = OptiScaler, 1 = DLSS Enabler, 2 = None). File assets for active methods are maintained centrally in `~/.local/share/goverlay/` and copied to game directories. HelixSR is an independent neural upscaler running DLSS Model E on AMD GPUs through D3D12 compute shaders.

See `proposal.md` for overall motivation.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated, balanced 4th slot in the Method card (`FOsUpscalerCard`) for HelixSR (`UPSCALER_TYPE = 3`).
- Maintain instant application startup by fetching the base HelixSR archive on splash without running time-consuming shader compilation.
- Implement an on-demand modal compilation runner when HelixSR is activated for the first time, reporting progress across compilation stages (weights extraction, HLSL generation, DXC compilation via Proton/Wine).
- Synchronize game files for both standard HelixSR (via OptiScaler 0.9.4 backend) and experimental Native DLSS (direct `dxgi.dll` loader + `nvngx.dll`).

**Non-Goals:**
- Distributing precompiled NVIDIA neural network weights or kernels (violates licensing; must be built locally on the user's hardware).
- Native Vulkan game support for HelixSR (HelixSR is strictly a Direct3D 12 compute shader pipeline).

## Decisions

### 1. HelixSR as a Top-Level Method vs. Sub-Toggle
- **Decision**: Add HelixSR as a 4th slot in Card 0 ("Method") rather than an internal toggle inside the OptiScaler spatial sub-card.
- **Rationale**: HelixSR represents an entirely distinct technology and pipeline (DLSS Model E compute shaders), complete with its own bundled OptiScaler version (0.9.4) and its own independent deployment mode (Native DLSS). Placing it at the Method level maintains a clean, balanced UI layout (4 equal slots) and avoids confusing channel overrides.
- **Alternatives Considered**: Adding a toggle "DLSS for Radeon" in `FOsSpatialSec`. Rejected because it creates conflicting channel dependencies with `optversionComboBox` and obscures the fact that HelixSR can run completely without OptiScaler in Native DLSS mode.

### 2. Startup Verification vs. On-Demand Compilation
- **Decision**: The startup splash screen (`TStartupDownloadThread`) only downloads and unpacks `HelixSR-<version>.zip` into `~/.local/share/goverlay/optiscaler-helixsr/`. The compilation step (which takes 1–2 minutes) is deferred until the user first selects the HelixSR method.
- **Rationale**: Running DXC shader compilation during application startup would freeze or severely delay launch times for users who may not intend to use HelixSR immediately.
- **Compilation Check**: The system inspects whether `amd_fidelityfx_dx12.dll` contains the `HXSRNET1` footer or whether `helixsr_weights.bin` and `helixsr_kernels.pak` exist in the runtime cache.

### 3. Compilation UI and Process Execution
- **Decision**: When an uncompiled HelixSR method is selected, show a modal dialog with a styled progress bar and stage status label. Execute `setup/helixsr_setup.py` (or `helixsr-setup.sh --yes`) in a background worker thread, parsing stdout lines to update progress smoothly:
  - Stage 1: DLSS reference library fetch (20%)
  - Stage 2: Weight tensor extraction (40%)
  - Stage 3: HLSL kernel generation (60%)
  - Stage 4: DXC compilation via Proton/Wine (85%)
  - Stage 5: Final packaging & verification (100%)

### 4. Game Deployment Modes
- **Decision**:
  - `UPSCALER_TYPE = 3` in `bgmod.conf`.
  - If `HELIXSR_NATIVE_DLSS = 1` (Native DLSS toggle active): deploy `dlss-loader/dxgi.dll` and `nvngx.dll` directly to the game folder. OptiScaler is bypassed.
  - Otherwise (default): deploy `OptiScaler.dll`, `fakenvapi.dll`, and `HelixSR/` containing `amd_fidelityfx_dx12.dll` and `helixsr.ini`. OptiScaler is configured with `Dx12Upscaler = fsr31`.

## Risks / Trade-offs

- **[Risk] Missing Proton/Wine on system**: The shader compiler (`dxc.exe`) requires Proton or Wine to run on Linux.
  - *Mitigation*: The compilation script scans known Steam Proton paths (`~/.steam/steam/steamapps/common/Proton*`) and system Wine. If none are found, GOverlay displays an informative error dialog explaining that Steam Proton or Wine is required.
- **[Risk] Anti-cheat bans with Native DLSS**: The experimental Native DLSS loader spoofs NVIDIA device IDs and signature validation.
  - *Mitigation*: Display a prominent single-player advisory next to the Native DLSS toggle warning against use in online multiplayer titles.
- **[Risk] RDNA 3 WaveSize detection**: When running behind OptiScaler with NVIDIA spoofing enabled, HelixSR may misidentify an RDNA 3 GPU and run 32-lane shaders instead of 64-lane shaders.
  - *Mitigation*: If the detected GPU is RDNA 3 / 3.5, GOverlay automatically ensures `[Compatibility] WaveSize = 64` is configured in `helixsr.ini`.

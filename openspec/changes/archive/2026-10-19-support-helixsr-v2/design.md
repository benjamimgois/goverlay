# Design

## Context

See `proposal.md` for motivation.
HelixSR 2.0.0 reorganizes its release package:
- FidelityFX neural upscaler and DLSS Frame Generation: `HelixSR-fsrfg/amd_fidelityfx_dx12.dll`, `HelixSR-fsrfg/helixsr.ini`, and `HelixSR-fsrfg/helixsr-fg/nvexec64.dll`.
- OptiScaler runtime: `helixsr-scaler/OptiScaler.dll` and companion libraries.
- Setup script: `helixsr-setup.sh` targets `$HERE/HelixSR-fsrfg` for shader compilation and weights injection.

Goverlay previously assumed a flat structure in `~/.local/share/goverlay/optiscaler-helixsr/`.

## Goals / Non-Goals

**Goals:**
- Eliminate missing library false positives on startup and stop re-download loops for HelixSR 2.0.
- Support both v2.0 (`HelixSR-fsrfg/`) and legacy v1.9.x (root DLL) layouts transparently.
- Synchronize compiled neural shaders between `HelixSR-fsrfg/` and the cache root so external tools, tests, and launchers find the active binaries.
- Deploy `helixsr-fg` to games during `bgmod` installation so DLSS Frame Generation works out-of-the-box on compatible DirectX 12 titles.
- Expose HelixSR v2 options (`Int8`, `NetworkResolution`, `Preset`) in Goverlay's MD3 UI and persist them in `helixsr.ini`.

**Non-Goals:**
- Re-architecting the upstream shader compilation pipeline.
- Removing backward compatibility for users running HelixSR 1.9.x.

## Decisions

### Decision 1: Dual-Path Resolution with Root Mirroring
- **Approach**: In `optiscaler_update.pas`, define `GetHelixSRFfxDllPath(const ARootPath: string): string` which checks `ARootPath/HelixSR-fsrfg/amd_fidelityfx_dx12.dll` first, then falls back to `ARootPath/amd_fidelityfx_dx12.dll`.
- Whenever `CheckAndInstallHelixSR` completes extraction, or whenever `CompileHelixSR` finishes building shaders into `HelixSR-fsrfg/amd_fidelityfx_dx12.dll`, copy the file and `helixsr.ini` to the cache root if `HelixSR-fsrfg/` is present.
- **Alternatives considered**: Only looking in `HelixSR-fsrfg/`. Rejected because it would break existing test fixtures, user setups with 1.9.x, and third-party integration scripts expecting `amd_fidelityfx_dx12.dll` at the root.

### Decision 2: Frame Generation Directory Deployment in `bgmod`
- **Approach**: In `bgmod.lpr`, during standard and native DLSS deployment, check if `SourceDir + 'HelixSR-fsrfg/helixsr-fg'` or `SourceDir + 'helixsr-fg'` exists. If found, copy the directory into `GameDir/HelixSR/helixsr-fg` (and `GameDir/helixsr-fg` for Native DLSS).
- **Alternatives considered**: Requiring users to run upstream `helixsr-setup.sh` per game manually. Rejected because Goverlay's primary design goal is automated, seamless game profile injection without manual command line execution.

### Decision 3: Configuration Persistence and UI Integration
- **Approach**: Add new configuration keys in `configkeys.pas`:
  - `HELIX_KEY_INT8 = 'Int8'`
  - `HELIX_KEY_NETWORK_RESOLUTION = 'NetworkResolution'`
  - `HELIX_KEY_FG_PRESET = 'Preset'`
- Parse and serialize these in `overlay_config.pas` under their upstream sections (`[Upscaling]` and `[DlssFrameGeneration]`).
- Expose these controls in `optiscaler_tab.pas` within the HelixSR configuration card (`FOsFakeSec`) using compact MD3 controls (`TComboBox` for resolution and presets).

## Risks / Trade-offs

- **[Risk]** Shader compilation in v2.0 modifies `HelixSR-fsrfg/amd_fidelityfx_dx12.dll`, leaving any previously mirrored root DLL out of sync.
  - **Mitigation**: In `CompileHelixSR`, re-copy `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` to root immediately after successful compilation.
- **[Risk]** Disk space usage from mirroring the 8MB DLL.
  - **Mitigation**: 8MB is trivial on modern systems, whereas maintaining the root file ensures absolute zero regressions across all existing code paths.

# Design

## Context
See `proposal.md` for background. HelixSR 3.1.0 and HelixSR Scaler 2.1.0 adopted a split architecture:
- `helixsr-scaler/OptiScaler.dll` is the dedicated OptiScaler build that includes custom pipeline integrations for HelixSR (HLX DLSS and HLX FSR 4).
- `helixsr-scaler/OptiScaler/` contains companion FidelityFX libraries, D3D12Core, XeSS shims, and OptiPatcher ASI.
- `HelixSR/helixsr.dll` contains the compiled DLSS Model E neural network upscaler.
- `HLX-FSR4/amd_fidelityfx_upscaler_dx12.dll` contains the compiled FSR 4 neural shader runtime.

In `bgmod.lpr` (UpscalerType = 3), the installation sequence currently checks `SourceDir + 'optiscaler/OptiScaler.dll'` before `helixsr-scaler/OptiScaler.dll`, ignores the `helixsr-scaler/OptiScaler/` folder, and expects the neural runtime at `SourceDir + 'amd_fidelityfx_dx12.dll'` or `HelixSR-fsrfg/`, causing standard OptiScaler v0.9.4 to be deployed instead of HelixSR Scaler 2.1, with the neural backend DLLs missing from the game directory.

## Goals / Non-Goals

**Goals:**
- Update `bgmod.lpr` to prioritize `helixsr-scaler/OptiScaler.dll` when installing HelixSR (UpscalerType = 3).
- Deploy `helixsr-scaler/OptiScaler/` directory contents to the game's `OptiScaler/` folder.
- Deploy `SourceDir + 'HelixSR/helixsr.dll'` into `GameDir/HelixSR/helixsr.dll` and `GameDir/HelixSR/helixsr_upscaler.dll`.
- Deploy `SourceDir + 'HLX-FSR4/amd_fidelityfx_upscaler_dx12.dll'` (or from `helixsr-scaler/OptiScaler/`) to the game's `OptiScaler/` or root when appropriate.
- Update `NeedsOptiScalerUpdate` in `bgmod.lpr` to recognize `helixsr-scaler/OptiScaler.dll` and ensure missing `helixsr.dll` triggers an update.
- Ensure `EnsureHelixSRCompanionLibraries` in `optiscaler_update.pas` does not replace `optiscaler/OptiScaler.dll` with standard OptiScaler if `helixsr-scaler/OptiScaler.dll` is present.

**Non-Goals:**
- Changing DLSS Enabler, DLSS-NR, or vanilla OptiScaler deployments.
- Changing the UI controls in the HelixSR tab of GOverlay.

## Decisions

### 1. Priority of `helixsr-scaler/OptiScaler.dll` in `bgmod.lpr`
- *Decision*: In `bgmod.lpr` under `UpscalerType = 3`, check `SourceDir + 'helixsr-scaler' + PathDelim + 'OptiScaler.dll'` FIRST before falling back to `optiscaler/OptiScaler.dll` or `OptiScaler.dll`.
- *Rationale*: In HelixSR 3.x, `helixsr-scaler/OptiScaler.dll` is the customized build with HLX DLSS/FSR 4 UI and backend dispatchers. The root or `optiscaler/` copies are generic OptiScaler builds.

### 2. Copying `helixsr-scaler/OptiScaler/` Directory
- *Decision*: If `DirectoryExists(SourceDir + 'helixsr-scaler' + PathDelim + 'OptiScaler')`, copy the directory contents into `IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler'`.
- *Rationale*: HelixSR Scaler 2.1 ships all its custom runtime components (`amd_fidelityfx_loader_dx12.dll`, `amd_fidelityfx_upscaler_dx12.dll`, `amd_fidelityfx_upscaler_dx12.amd.dll`, XeSS, D3D12Core) under `OptiScaler/`.

### 3. Deploying `HelixSR/helixsr.dll`
- *Decision*: Check `SourceDir + 'HelixSR' + PathDelim + 'helixsr.dll'`. When present, copy it to `GameDir + 'HelixSR/helixsr.dll'` and `GameDir + 'HelixSR/helixsr_upscaler.dll'`, while keeping legacy fallbacks (`HelixSR-fsrfg/amd_fidelityfx_dx12.dll` and `amd_fidelityfx_dx12.dll`).
- *Rationale*: HelixSR 3.1 setup scripts output the compiled runtime directly into `HelixSR/helixsr.dll`.

### 4. Updating `NeedsOptiScalerUpdate` candidate sizes
- *Decision*: Add `CandidatePath + 'helixsr-scaler' + PathDelim + 'OptiScaler.dll'` to the candidate sizes checked in `NeedsOptiScalerUpdate`.
- *Rationale*: Prevents `bgmod` from falsely considering `helixsr-scaler/OptiScaler.dll` as an alien or mismatched proxy when verifying existing installations.

## Risks / Trade-offs

- *Risk*: Legacy HelixSR 1.x or 2.x users might have the older folder structure (`HelixSR-fsrfg/`).
  - *Mitigation*: Fallback checks for `HelixSR-fsrfg/` and `amd_fidelityfx_dx12.dll` remain in place after the 3.x paths.

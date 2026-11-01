# Proposal

## Why

Following the HelixSR 3.1.0 and HelixSR Scaler 2.1.0 update, games launched with the HelixSR upscaler method fail to load the HelixSR upscaler backend in OptiScaler (falling back to generic FSR upscalers without HLX DLSS or HLX FSR 4 options). This occurs because `bgmod.lpr` prioritizes the legacy unspecialized `optiscaler/OptiScaler.dll` instead of `helixsr-scaler/OptiScaler.dll`, searches for runtime binaries in legacy `HelixSR-fsrfg/` or root paths instead of `HelixSR/helixsr.dll`, fails to deploy the companion `OptiScaler/` directory from `helixsr-scaler`, and `optiscaler_update.pas` continues copying the standard OptiScaler build from `optiscaler-stable` into `optiscaler/OptiScaler.dll`.

## What Changes

- **Update bgmod HelixSR deployment**:
  - In `bgmod.lpr` (UpscalerType = 3), prioritize `helixsr-scaler/OptiScaler.dll` and `helixsr-scaler/OptiScaler.ini` for deployment over the generic `optiscaler/OptiScaler.dll`.
  - Deploy the companion `helixsr-scaler/OptiScaler/` directory (containing `amd_fidelityfx_loader_dx12.dll`, `amd_fidelityfx_upscaler_dx12.dll`, `amd_fidelityfx_upscaler_dx12.amd.dll`, etc.) directly into the game's `OptiScaler/` directory.
  - Deploy `HelixSR/helixsr.dll` into the game's `HelixSR/` subdirectory as `helixsr.dll` and `helixsr_upscaler.dll`.
  - Update `NeedsOptiScalerUpdate` in `bgmod.lpr` to recognize `helixsr-scaler/OptiScaler.dll` file size and verify all required 3.x companion files.
- **Update optiscaler_update.pas helper sync**:
  - In `EnsureHelixSRCompanionLibraries`, do not overwrite `optiscaler/OptiScaler.dll` if `helixsr-scaler/OptiScaler.dll` is present, or ensure `helixsr-scaler/OptiScaler.dll` is preserved as the primary OptiScaler binary for HelixSR.
- **Recompile and deploy bgmod binary**:
  - Recompile `bgmod` and sync it to the global cache and per-game config directories so launch invocations immediately use the corrected installer.

## Capabilities

### Modified Capabilities
- `helixsr-runtime-management`: Update HelixSR runtime file synchronization and game directory deployment to support the HelixSR 3.1 / HelixSR Scaler 2.1 package layout, ensuring `helixsr-scaler/OptiScaler.dll`, `helixsr-scaler/OptiScaler/` directory, and `HelixSR/helixsr.dll` are correctly deployed.

## Impact

- `bgmod.lpr`: Standard HelixSR installation logic (UpscalerType = 3), integrity checks (`NeedsOptiScalerUpdate`), and proxy deployment.
- `optiscaler_update.pas`: Companion library synchronization and file layout promotion.
- `bgmod` binary: Built binary recompiled and distributed.

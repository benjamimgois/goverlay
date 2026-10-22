# Proposal: Fix HelixSR Startup Missing Library Toast and Companion Sync

## Why
When starting GOverlay after compiling HelixSR shaders, users receive a persistent warning notification: *"Could not download required libraries: HelixSR (OptiScaler & DLSS Model E runtime). Check your internet connection."*
This occurs because HelixSR v1.9.0 restructured its upstream release archive by separating the standalone FSR drop-in / shader setup (`HelixSR-1.9.0.zip`) from OptiScaler (`HelixSR-Scaler`), omitting the bundled `optiscaler/OptiScaler.dll`. GOverlay's startup check rigidly asserted that `optiscaler/OptiScaler.dll` must exist within the HelixSR archive, repeatedly triggering failed self-healing downloads and threatening to overwrite freshly compiled shaders.

## What Changes
- **HelixSR Runtime Completeness Definition**: Update startup verification and download checks so that `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh` define the core HelixSR runtime presence.
- **OptiScaler Companion Sync**: If `optiscaler/OptiScaler.dll` or `fakenvapi.dll` are not present in the HelixSR archive (as in HelixSR v1.9.0+), automatically synchronize them from the central stable OptiScaler cache (`optiscaler-stable`), mirroring the fallback pattern already used across other channels.
- **Preserve Compiled Shaders**: Ensure startup verification acknowledges existing compiled neural runtimes (`IsHelixSRCompiled`) so unnecessary re-downloads and false missing-component alerts are avoided.

## Capabilities

### Modified Capabilities
- `helixsr-runtime-management`: Update the startup verification requirement to define the primary HelixSR runtime by `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh`, and synchronize companion OptiScaler binaries from the stable OptiScaler cache when not bundled by upstream.
- `startup-libraries-verification`: Adjust the mandatory library checklist for HelixSR to avoid false-positive missing library notifications when HelixSR v1.9.0+ or compiled runtimes are present.

## Impact
- **Code**: `optiscaler_update.pas` (`GetMissingOptiScalerComponents`, `CheckAndInstallHelixSR`).
- **User Experience**: Eliminates spurious startup warning toasts when HelixSR is installed and compiled.
- **Backwards Compatibility**: Transparently works with both legacy HelixSR v1.8.x archives (which bundled `optiscaler/`) and v1.9.x+ archives (which separate it).

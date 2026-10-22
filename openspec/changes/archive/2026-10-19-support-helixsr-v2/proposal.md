# Proposal

## Why

Upstream HelixSR recently released version `v2.0.0`, restructuring its archive layout and uncoupling its runtime files into subdirectories (`HelixSR-fsrfg/` for the neural FidelityFX runtime and `helixsr-scaler/` for bundled OptiScaler components), as well as introducing integrated DLSS Frame Generation and new configuration parameters (`Int8`, `NetworkResolution`, `Preset`, `Memory`). Goverlay's verification, download installer, compilation verifier, and game launcher currently expect `amd_fidelityfx_dx12.dll` and `helixsr.ini` directly at the cache root, causing Goverlay to report missing mandatory libraries on every launch, enter an infinite re-download loop, fail extraction verification, and fail to deploy HelixSR into games. Supporting HelixSR v2.0.0 restores working installations, prevents re-download loops, ensures compiled neural shaders are properly recognized, and exposes the new v2.0 configuration options.

## What Changes

- Support the HelixSR v2.0.0 archive layout: recognize `amd_fidelityfx_dx12.dll` and `helixsr.ini` located in `HelixSR-fsrfg/` while maintaining backward compatibility with legacy v1.9.x layouts.
- In `CheckAndInstallHelixSR`, mirror/copy `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` and `HelixSR-fsrfg/helixsr.ini` to the cache root upon extraction so that legacy tools, tests, and launchers continue to operate seamlessly.
- Update `HasMissingMandatoryLibraries` and `home_tab.pas` status checks to recognize HelixSR whether `amd_fidelityfx_dx12.dll` is in `HelixSR-fsrfg/` or in the root directory.
- Update `IsHelixSRCompiled` to inspect the `HXSRNET1` neural network marker in `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` as well as the root DLL, and sync the compiled DLL with the root cache after on-demand compilation completes.
- Update `bgmod.lpr` to locate `amd_fidelityfx_dx12.dll` in either `HelixSR-fsrfg/` or root, deploy `HelixSR-fsrfg/helixsr-fg/` (containing `nvexec64.dll`) into the game directory for DLSS Frame Generation, and read `helixsr.ini` from `HelixSR-fsrfg/` if absent in root.
- Add configuration keys and UI options for HelixSR v2.0 parameters:
  - `Int8` (`auto`, `on`, `off`) in `[Upscaling]`
  - `NetworkResolution` (`fast`, `full`) in `[Upscaling]`
  - `Preset` (`c`, `full`) in `[DlssFrameGeneration]`
- Update unit tests in `tests/gui/gui_test_cases.pas` to verify startup detection and synchronization with both v2.0 (`HelixSR-fsrfg/`) and legacy structures.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `helixsr-runtime-management`: Update startup verification, cache extraction, neural compilation checks, deployment to games, and configuration persistence to support HelixSR v2.0.0 structure and options.

## Impact

- Modified files:
  - `optiscaler_update.pas`: Archive extraction, path resolution, `IsHelixSRCompiled`, and `HasMissingMandatoryLibraries`.
  - `home_tab.pas`: Status dot verification for HelixSR.
  - `bgmod.lpr`: Game deployment of HelixSR v2 DLLs, `helixsr-fg` directory, and `helixsr.ini`.
  - `configkeys.pas`: New config key constants for `Int8`, `NetworkResolution`, and `DlssFrameGeneration`.
  - `overlay_config.pas`: Serialization and deserialization of new `helixsr.ini` keys.
  - `optiscaler_tab.pas`: MD3 UI controls for new HelixSR options.
  - `tests/gui/gui_test_cases.pas`: Test cases for v2.0 archive layout and companion library synchronization.

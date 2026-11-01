# Tasks

## 1. Implement HelixSR 3.1 / Scaler 2.1 Deployment in bgmod

- [x] 1.1 In `bgmod.lpr` under `UpscalerType = 3`, prioritize `helixsr-scaler/OptiScaler.dll` and deploy `helixsr-scaler/OptiScaler/` directory into the game's `OptiScaler/` folder, verifying `test_bgmod` or build compilation succeeds.
- [x] 1.2 In `bgmod.lpr`, deploy `SourceDir + 'HelixSR/helixsr.dll'` to `GameDir/HelixSR/helixsr.dll` and `GameDir/HelixSR/helixsr_upscaler.dll`, maintaining legacy fallbacks.
- [x] 1.3 In `bgmod.lpr`, update `NeedsOptiScalerUpdate` to recognize `helixsr-scaler/OptiScaler.dll` file size and verify existence of required 3.x files.
- [x] 1.4 In `optiscaler_update.pas`, ensure `EnsureHelixSRCompanionLibraries` preserves `helixsr-scaler/OptiScaler.dll` when synchronizing companion libraries.

## 2. Recompile and Validate Deployment

- [x] 2.1 Recompile `bgmod` binary using `fpc` or `lazbuild` and verify exit code 0.
- [x] 2.2 Distribute the compiled `bgmod` binary to `~/.local/share/goverlay/optiscaler-helixsr/` and existing game config folders (`~/.local/share/goverlay/gameconfig/Stellar Blade_/`).
- [x] 2.3 Run existing test suite (`./tests_runner`) to verify no regressions in unit and logic test cases.

## 3. Fix Startup Fatal Error & Upstream Config Alignment

- [x] 3.1 In `bgmod.lpr`, do not override `FfxDx12Path` and `FfxDx12SRPath` to point to `HelixSR/helixsr.dll` (which is an NVNGX DLSS DLL in 3.x, causing null entrypoint crashes); keep them as `auto`.
- [x] 3.2 In `bgmod.lpr`, configure `OptiScaler.ini` with `Dx12Upscaler=dlss`, `[DLSS] HelixSR=true`, and `[Plugins] LoadAsiPlugins=true` matching HelixSR Scaler 2.1 architecture.
- [x] 3.3 In `bgmod.lpr`, prevent Step 8 from overwriting root native FidelityFX DLLs (`amd_fidelityfx_upscaler_dx12.dll`) when `UpscalerType = 3`, restoring original game DLLs from backup and purging duplicate root `plugins/OptiPatcher.asi`.
- [x] 3.4 Recompile `bgmod`, clean up Stellar Blade game directory, restore original root DLLs, and initialize clean `OptiScaler.ini`.

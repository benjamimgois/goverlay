# Tasks

## 1. Central Cache and Startup Verification

- [x] 1.1 Implement central path helper `GetBGModOriginalHelixSRPath` in `bgmod_resources.pas` pointing to `~/.local/share/goverlay/optiscaler-helixsr/`, verifying return path format.
- [x] 1.2 Implement archive download and extraction routine `CheckAndInstallHelixSR` in `optiscaler_update.pas` fetching the latest verified HelixSR release from GitHub.
- [x] 1.3 Hook `CheckAndInstallHelixSR` into startup splash verification in `overlayunit.pas` (`TStartupDownloadThread.Execute` and `HasMissingMandatoryLibraries`), verifying non-blocking splash progression.

## 2. Method Card UI Layout (4 Slots)

- [x] 2.1 Add `helixsrRadioButton` and `helixsrLogoImage` controls in `optiscaler_tab.pas` inside `FOsUpscalerCard`.
- [x] 2.2 Update `ReflowOptiScalerTabNew` in `optiscaler_tab.pas` to distribute four equal-width slots across full width `CW` (None, OptiScaler, DLSS Enabler, HelixSR).
- [x] 2.3 Implement event handlers `helixsrRadioButtonClick` and `helixsrLogoImageClick` in `overlayunit.pas` and update `UpdateUpscalerImageOpacity` in `optiscaler_tab.pas` to handle 4 logos.

## 3. On-Demand Neural Shader Compilation

- [x] 3.1 Implement compilation check helper `IsHelixSRCompiled` in `optiscaler_update.pas` validating `HXSRNET1` footer marker in `amd_fidelityfx_dx12.dll`.
- [x] 3.2 Create background compilation thread `THelixSRCompileThread` and progress dialog in `optiscaler_update.pas` parsing stdout progress stages from `helixsr_setup.py`.
- [x] 3.3 Hook compilation verification into `helixsrRadioButtonClick` in `overlayunit.pas` to trigger compilation dialog only when uncompiled, verifying smooth transition to active state.

## 4. Game Profile Configuration and File Synchronization

- [x] 4.1 Update `SaveOptiScalerConfig` and `LoadOptiScalerConfig` in `overlay_config.pas` to support `UPSCALER_TYPE = 3` and persist `HELIXSR_NATIVE_DLSS` setting.
- [x] 4.2 Add "Native DLSS" toggle control and single-player safety warning hint in `optiscaler_tab.pas` under HelixSR options.
- [x] 4.3 Update file deployment routines in `sidebar_nav.pas` (`CopyOptiScalerGameFiles`) and `bgmod.lpr` to synchronize standard HelixSR assets (`OptiScaler.dll`, `fakenvapi.dll`, `HelixSR/`) or Native DLSS assets (`dlss-loader/dxgi.dll`, `nvngx.dll`) into the game profile folder.

## 5. Automated Tests and Integration Verification

- [x] 5.1 Add GUI and serialization test cases in `tests/gui/` verifying 4-way method switching, `UPSCALER_TYPE=3` round-trip persistence, and Native DLSS toggle states.
- [x] 5.2 Build the project (`lazbuild goverlay.lpi`) and run the test suite (`./tests/gui/run_gui_tests.sh`) to verify zero regressions across existing upscaler methods.

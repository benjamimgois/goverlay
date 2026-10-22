# Tasks

## 1. Hardware Detection Updates

- [x] 1.1 Extend `DetectRDNAArchitecture` in `systemdetector.pas` with RDNA 4 PCI device IDs (Navi 44: `7590`, `7591`, `7592`, `7593`; Navi 48: `7500` through `7506`) and string markers (`rx 9060`, `rx 9070`, `navi 44`, `navi 48`, `navi44`, `navi48`), and verify compilation with `./build.sh --ws=qt6`
- [x] 1.2 Add logic test cases in `tests/logic/logic_test_cases.pas` verifying RDNA 4 detection for PCI ID `7590` and model strings, and verify with `./build_tests.sh && ./run_tests.sh`

## 2. Architecture-Aware Download & Extraction

- [x] 2.1 Refactor `ExtractDlssNrModel` and `CheckAndInstallDlssNr` in `optiscaler_update.pas` to determine the target architecture first (`rdna4` for RDNA 4, `rdna3` for RDNA 3) and download the matching runtime package into its respective directory (`dlss-nr-rdna4` or `dlss-nr-rdna3`)
- [x] 2.2 Add unit test coverage in `tests/logic/logic_test_cases.pas` verifying target architecture directory resolution and model placement for both RDNA 3 and RDNA 4, and verify tests pass

## 3. Configuration & Launcher Resolution

- [x] 3.1 Update `overlay_config.pas` and `optiscaler_tab.pas` to compute and write `DLSSNR_RESOLVED_ARCH` into `bgmod.conf` alongside `DLSSNR_ARCH`, and verify with logic test cases
- [x] 3.2 Update `bgmod.lpr` to resolve architecture via `DLSSNR_RESOLVED_ARCH` and sysfs device fallback when `DLSSNR_ARCH=0`, log the resolved channel in `bgmod.log`, and warn if fallback occurs
- [x] 3.3 Add test cases verifying `bgmod` architecture resolution for Auto-detect on RDNA 4 hardware, build all targets, and execute test suites to ensure zero regressions

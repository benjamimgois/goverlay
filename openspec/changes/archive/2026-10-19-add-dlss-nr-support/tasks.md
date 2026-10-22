# Tasks

## 1. System Detection and Configuration Keys

- [x] 1.1 Implement `DetectRDNAArchitecture` in `systemdetector.pas` returning `rdna3`, `rdna4`, or `rdnaUnsupported` based on DRM device and OpenGL renderer strings, and verify detection on the active GPU.
- [x] 1.2 Define configuration keys for DLSS-NR in `configkeys.pas` and `overlay_config.pas` (`DLSSNR_ARCH`, `DLSSNR_ROUTE`, `DLSSNR_MODEL`, `DLSSNR_SCALE`, `DLSSNR_INT4`, `DLSSNR_RENODX`, `DLSSNR_PREPROCESS`, etc.), verifying round-trip serialization.

## 2. Central Runtime Management and Model Extraction Backend

- [x] 2.1 Implement `CheckAndInstallDlssNr` in `optiscaler_update.pas` to fetch and unpack release archives for RDNA3 (`mauri870/DLSSNR-RDNA3`) and RDNA4 (`mochizuki0323/DLSSNR-AMD`) into `~/.config/goverlay/dlss-nr/<arch>/`.
- [x] 2.2 Implement one-time model weights extraction in `optiscaler_update.pas` accepting user's `nvngx_dlssnr.dll` (v310.9.16 or v310.8.0), executing `extract_model.sh`, verifying SHA-256 hashes, and storing `dlssnr.bin` and `dlssnr-small.bin` in central shared storage.
- [x] 2.3 Implement DLSS-NR version query and readiness status helpers in `optiscaler_update.pas` to feed the Home tab's Software Status card.

## 3. UI Implementation in OptiScaler Tab and Home Tab

- [x] 3.1 Expand the Method card in `optiscaler_tab.pas` to include the "DLSS-NR" radio button and logo image with active (100%) and dimmed (35%) states across five evenly spaced slots.
- [x] 3.2 Add the DLSS-NR options panel in `optiscaler_tab.pas` (Architecture selector with auto-detect default, Model DLL picker with status pill, Route selector, Model Version selector, Model Scale selector defaulting to 50% on RDNA3, Int4 Mixed toggle, RenoDX Style toggle, and Preprocess toggle).
- [x] 3.3 Update `home_tab.pas` to display "DLSS-NR" version, target architecture, and model readiness status in the Software Status list.

## 4. Game Profile Direct File Deployment and Uninstallation

- [x] 4.1 Implement direct-file deployment routine in `optiscaler_update.pas` / `games_tab.pas` copying proxy libraries, backend binaries, neural model weights, and generating `dlssnr-amd.ini` directly into the game folder with an install manifest.
- [x] 4.2 Implement uninstallation cleanup routine reading the game install manifest and removing all deployed DLSS-NR files when disabled.

## 5. Build, Verification, and Integration Testing

- [x] 5.1 Build Goverlay with `make` and verify that unit/GUI tests compile cleanly with no regressions in OptiScaler or HelixSR method handling.
- [x] 5.2 Test live UI interaction on host (verifying RDNA3 auto-detection on RX 7900 XTX, Method card reflow, and generated `dlssnr-amd.ini`).

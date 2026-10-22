# Tasks

## 1. Master Binary Resolution and Update Helpers

- [x] 1.1 Implement master binary candidate search functions in `bgmod_resources.pas` / `bgmod.lpr` checking system paths (`/usr/libexec/goverlay/`, `/usr/lib/goverlay/`, `/usr/local/libexec/goverlay/`), Flatpak host locations, and user template cache, verifying path resolution via logic tests.
- [x] 1.2 Implement atomic wrapper replacement helper (`.tmp` copy, `fpChmod(0755)`, `fpRename`) for `bgmod`, `bgmod-uninstaller`, and `bgmod-splash` with safe error handling, verifying atomic update logic via unit tests.

## 2. bgmod Self-Update Lifecycle & Re-Execution

- [x] 2.1 Integrate self-update check at `bgmod.lpr` startup, comparing `FileAge` and `FileSize` between running binary and discovered master binary when `BGMOD_UPDATED` environment variable is not set.
- [x] 2.2 Implement seamless re-execution (`fpexecv`) with `BGMOD_UPDATED=1` environment guard, argument forwarding, and log recording.

## 3. Splash Screen Integration

- [x] 3.1 Update `bgmod.lpr` splash checklist generation to append `'BGMod updated'` to `SplashItems` when an update occurred during the launch.

## 4. Verification and Testing

- [x] 4.1 Add automated test cases in `tests/logic/logic_test_cases.pas` verifying master path discovery, update detection logic, and splash items inclusion.
- [x] 4.2 Run complete test suite (`make test-logic` and `make test-gui`) and ensure 100% passing tests.

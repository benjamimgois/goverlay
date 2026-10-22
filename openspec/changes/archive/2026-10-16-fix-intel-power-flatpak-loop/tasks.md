# Tasks: Fix Intel CPU Power Monitoring Flatpak Loop

## 1. Event Handler Guards

- [x] 1.1 Add `if FLoadingConfig then Exit;` and `if IsRunningInFlatpak then Exit;` guards to `cpupowerCheckBoxClick` in [overlayunit.pas](file:///mnt/NVME/Software/goverlay/overlayunit.pas) and verify compilation with `./build.sh`.
- [x] 1.2 Add `if FLoadingConfig then Exit;` guard to `gamemodeCheckBoxClick` in [overlayunit.pas](file:///mnt/NVME/Software/goverlay/overlayunit.pas) and verify compilation with `./build.sh`.

## 2. Flatpak Manual Guidance & Strings

- [x] 2.1 Update `rsIntelFixNoFlatpak` in [goverlay_strings.pas](file:///mnt/NVME/Software/goverlay/goverlay_strings.pas) to include the actionable host terminal command for applying the udev rule.
- [x] 2.2 Update translation template [languages/goverlay.pot](file:///mnt/NVME/Software/goverlay/languages/goverlay.pot) and locale catalogs with the updated `rsIntelFixNoFlatpak` string.

## 3. Automated Tests & Verification

- [x] 3.1 Add automated test cases in [tests/gui/gui_test_cases.pas](file:///mnt/NVME/Software/goverlay/tests/gui/gui_test_cases.pas) verifying that `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick` do not trigger fix prompts when `FLoadingConfig = True` or when running under Flatpak simulation.
- [x] 3.2 Compile and run the test suite to verify all test cases pass without regressions.

## 1. Flatpak Manifest Isolation

- [x] 1.1 Remove `--filesystem=xdg-data/vulkan:create` from `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`, and verify neither manifest contains host Vulkan data filesystem access
- [x] 1.2 Bump application version to 1.9.2 in `constants.pas` and related version definitions

## 2. Startup Auto-installer Guards

- [x] 2.1 Add `if IsRunningInFlatpak then Exit;` guard to `CheckAndInstallVkSumi` in `optiscaler_update.pas` with logging, and verify it skips execution when running inside Flatpak
- [x] 2.2 Add `if IsRunningInFlatpak then Exit;` guard to `CheckAndInstallMako` in `optiscaler_update.pas` with logging, and verify it skips execution when running inside Flatpak

## 3. Download Hardening and Binary Validation

- [x] 3.1 Update `RunCurlWithProgress` in `optiscaler_update.pas` to include `--fail` (`-f`) flag so HTTP 4xx/5xx responses do not create error files
- [x] 3.2 Add helper function `IsValidSharedLibrary(const APath: string; AMinSizeBytes: Int64 = 65536): Boolean` in `optiscaler_update.pas` checking for minimum file size and ELF magic header bytes (`\x7fELF`)
- [x] 3.3 Enforce `IsValidSharedLibrary` in `CheckAndInstallVkSumi` before generating `vksumi.json`, deleting the target file and aborting manifest creation if validation fails

## 4. Legacy Corrupt Manifest Cleanup and Verification

- [x] 4.1 Add startup sanitation in `overlayunit.pas` or `optiscaler_update.pas` that checks if `~/.local/share/vulkan/implicit_layer.d/vksumi.json` points to an invalid or missing ELF file and removes the stale JSON to auto-repair affected machines
- [x] 4.2 Compile and build GOverlay (`lazbuild goverlay.lpi`), verifying clean compilation with zero errors

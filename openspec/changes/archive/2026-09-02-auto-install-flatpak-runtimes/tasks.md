## 1. Flatpak Manifests

- [x] 1.1 Add `add-extensions` entries for `MangoHud` and `vkBasalt` with `autodownload: true` in `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`, and verify YAML syntax
- [x] 1.2 Ensure `--filesystem=xdg-data/vulkan:create` or required filesystem permissions are present in the Flatpak manifests to allow writing user-space Vulkan layers

## 2. vkSumi Auto-Download & Registration

- [x] 2.1 Implement `CheckAndInstallVkSumi` in `optiscaler_update.pas` with curl progress reporting, release tag resolution, and fallback URLs
- [x] 2.2 Implement automatic `vksumi.json` generation in `~/.local/share/vulkan/implicit_layer.d/` pointing to `~/.local/share/goverlay/layers/vksumi/libVkLayer_vksumi.so`
- [x] 2.3 Integrate `CheckAndInstallVkSumi` into `TStartupDownloadThread.Execute` in `overlayunit.pas` with scaled progress percentages (OptiScaler 0–40%, DLSS Enabler 40–70%, vkSumi 70–95%, Finalize 95–100%)

## 3. Dependency Detection & UI State

- [x] 3.1 Update `CheckDependencies` in `goverlay_system.pas` to detect user-space vkSumi in `~/.local/share/vulkan/implicit_layer.d/vksumi.json` as satisfied in both Flatpak and native modes
- [x] 3.2 Verify Home tab module dots and dependency status reflect the installed vkSumi layer correctly

## 4. Documentation

- [x] 4.1 Update `README.md` to remove manual `flatpak install` commands for Vulkan layers and vkSumi, reflecting the automated out-of-the-box installation
- [x] 4.2 Update `CONTRIBUTING.md` Flatpak instructions to reflect the auto-downloaded extension behavior

## 5. Verification & Tests

- [x] 5.1 Run test suite (`tests/`) and verify application compilation and startup flow

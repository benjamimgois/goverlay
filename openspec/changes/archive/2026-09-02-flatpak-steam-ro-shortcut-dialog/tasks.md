## 1. Flatpak Manifest Permissions

- [x] 1.1 Update `flatpak/io.github.benjamimgois.goverlay.yml` to change Steam permissions from `:rw` to `:ro`
- [x] 1.2 Update `flatpak/io.github.benjamimgois.goverlay.nightly.yml` to change Steam permissions from `:rw` to `:ro`

## 2. Flatpak Steam Shortcut Dialog

- [x] 2.1 Add `rsSteamShortcutFlatpakInfo` English resource string in `goverlay_strings.pas`
- [x] 2.2 Update `Tgoverlayform.CreateSteamShortcutMenuItemClick` in `overlayunit.pas` to show instructions dialog when `IsRunningInFlatpak` is true

## 3. Verification

- [x] 3.1 Verify Flatpak manifests syntax and arguments
- [x] 3.2 Verify Pascal syntax and build / tests

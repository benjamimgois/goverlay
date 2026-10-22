## 1. Asset Creation and Packaging

- [x] 1.1 Create Steam Grid artwork assets (`cover.png` 600x900, `banner.png` 920x430, `hero.png` 1920x620, `logo.png` 640x360, `icon.png` 512x512) in `data/steam_grid/` and verify image dimensions.
- [x] 1.2 Update `Makefile` to install `data/steam_grid/` to `$(DESTDIR)$(prefix)$(datadir)/goverlay/data/steam_grid/` and handle uninstallation.

## 2. Helper Script Implementation

- [x] 2.1 Update `assets/goverlay-steam-shortcut.py` to compute 64-bit Grid IDs and 32-bit AppIDs, creating `<userdata>/<id>/config/grid/` artwork copies upon `add`.
- [x] 2.2 Update `assets/goverlay-steam-shortcut.py` to delete associated artwork files upon `remove`.
- [x] 2.3 Verify `assets/goverlay-steam-shortcut.py` manually with test arguments to ensure files are placed in `config/grid/` with exact Steam conventions.

## 3. GOverlay Integration and Build Verification

- [x] 3.1 Update `overlayunit.pas` to locate the `data/steam_grid` directory with local fallback and pass it to `goverlay-steam-shortcut.py`.
- [x] 3.2 Build GOverlay and test creating and removing a Steam shortcut, verifying the dialog messages and file structures.

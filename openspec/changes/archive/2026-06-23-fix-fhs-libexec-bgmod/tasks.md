## 1. Modify Installation Paths in Makefile

- [x] 1.1 Update the `install` target in `Makefile` to place `bgmod` and `bgmod-uninstaller` in `libexecdir/goverlay/`
- [x] 1.2 Update the `install` target in `Makefile` to delete `bgmod` and `bgmod-uninstaller` binaries from `datadir/goverlay/bgmod/` after copying data files

## 2. Update Binary Path Resolution in bgmod_resources.pas

- [x] 2.1 Update `InitializeBGModDirectory` in `bgmod_resources.pas` to copy `bgmod` and `bgmod-uninstaller` from GOverlay executable's directory (`ExtractFilePath(ParamStr(0))`) to `OriginalPath`

## 3. Verify and Compile

- [x] 3.1 Run `make` to compile the project
- [x] 3.2 Run a test installation with DESTDIR set to a temporary folder to verify file hierarchy compliance

## 1. Helper Functions Implementation

- [x] 1.1 Implement `GetGlobalBGModPath` to resolve the central/global `bgmod` directory
- [x] 1.2 Implement `NeedsLocalUpdate` to compare `goverlay.vars` contents between two folders
- [x] 1.3 Implement `CopyDirectoryFiltered` to sync files from global to local game config directory, excluding configuration files

## 2. OptiScaler Copy Logic Integration

- [x] 2.1 Add central-to-local sync check at the beginning of the OptiScaler copy block in `bgmod.lpr`
- [x] 2.2 Add conditional check before copying DLLs/files to the game directory
- [x] 2.3 Ensure `goverlay.vars` is copied to the game folder after installation/update is performed

## 3. Compilation and Verification

- [x] 3.1 Compile `bgmod` using `fpc`
- [x] 3.2 Verify that `bgmod` successfully skips copying files when versions match and DLLs exist
- [x] 3.3 Verify that updating `goverlay.vars` triggers a successful update/overwrite of files in the game folder

## 1. Implement Conditional Cleanup in bgmod

- [x] 1.1 Add `goverlay.vars` existence check before the OptiScaler disabled cleanup block in `bgmod.lpr`
- [x] 1.2 Add deletion of `goverlay.vars` at the end of the OptiScaler disabled cleanup block in `bgmod.lpr`

## 2. Implement Cleanup in bgmod-uninstaller

- [x] 2.1 Add deletion of `goverlay.vars` in `bgmod-uninstaller.lpr` uninstallation routine

## 3. Build and Verify

- [x] 3.1 Compile `bgmod` and `bgmod-uninstaller` using `fpc`
- [x] 3.2 Verify that running `bgmod` with OptiScaler disabled does not run cleanup or delete folders/files if `goverlay.vars` is missing
- [x] 3.3 Verify that running `bgmod` with OptiScaler disabled cleans up and deletes `goverlay.vars` if `goverlay.vars` is present

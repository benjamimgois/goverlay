## 1. Implement Binary Source Directory Helper

- [x] 1.1 Declare and implement `GetBGModBinariesSourceDir` in `bgmod_resources.pas` to resolve the helper binaries' location by checking `BinaryDir`, relative `lib/` directory, and `$APPDIR/lib/`.

## 2. Refactor Binary Copy in InitializeBGModDirectory

- [x] 2.1 Update `InitializeBGModDirectory` in `bgmod_resources.pas` to call `GetBGModBinariesSourceDir` and use the resolved path for copying `bgmod` and `bgmod-uninstaller`.
- [x] 2.2 Add warning logging if the helper binaries cannot be found in any of the resolved candidate directories.

## 3. Verification

- [x] 3.1 Compile the project using `make` to verify there are no compilation or syntax errors.
- [x] 3.2 Verify directory initialization and path resolution by running GOverlay.

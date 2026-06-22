## 1. Implement File Size Helper and Size Check in bgmod

- [x] 1.1 Add `GetFileSize` helper function to `bgmod.lpr`
- [x] 1.2 Add `IsGOverlayProxyFile` helper function to `bgmod.lpr`
- [x] 1.3 Update `SafeCleanOrRestore` in `bgmod.lpr` to check `IsGOverlayProxyFile` before deleting when no `.b` backup exists

## 2. Refactor Wrapper Active Proxy Backup/Cleanup Loop in bgmod

- [x] 2.1 Update the backup/cleanup loop in `bgmod.lpr` to only back up the active `DllName`
- [x] 2.2 Ensure inactive proxy DLLs are safely restored or skipped rather than unconditionally backed up

## 3. Refactor fgmod Script

- [x] 3.1 Update `data/fgmod/fgmod` to only back up/overwrite the active proxy DLL
- [x] 3.2 Update `data/fgmod/fgmod` to prevent unconditional deletion of inactive proxy DLLs

## 4. Compilation and Verification

- [x] 4.1 Run `make` to compile `bgmod` and `goverlay`
- [x] 4.2 Verify execution and check that third-party proxy DLLs are preserved

## 1. Rewrite stable tag discovery

- [x] 1.1 Replace two-pass stable tag matching with single-pass collection of all tags matching `^\d+\.\d+\.\d+(-\d+)?$`
- [x] 1.2 Sort collected tags numerically using `CompareVersions` (highest first)
- [x] 1.3 Return highest tag from sorted list

## 2. Rewrite bleeding-edge tag discovery

- [x] 2.1 Replace single-match edge tag matching with collection of all `^edge-` tags
- [x] 2.2 Strip `edge-` prefix, sort remaining numeric part with `CompareVersions`
- [x] 2.3 Return highest edge tag (with prefix) from sorted list

## 3. Fix version comparison in update check

- [x] 3.1 In `SyncUpdateUI`, replace `FLatestOptiTag <> CurrentVersion` with `CompareVersions` to only show update when remote > installed
- [x] 3.2 Handle `edge-` prefix stripping before comparison for bleeding-edge channel

## 4. Build and verify

- [x] 4.1 Compile with `make`

## 5. Auto-save channel on update completion

- [x] 5.1 In `UpdateButtonClick`, after successful install, write `OPT_CHANNEL` to both global and .bgmod_original bgmod.conf

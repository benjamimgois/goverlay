## 1. Implementation of Name Normalization

- [x] 1.1 Implement `NormalizeAppImageName` helper function in `games_tab.pas` to strip `.appimage`, platform, architecture, and version suffixes

## 2. Directory Scanning Logic Modification

- [x] 2.1 In `games_tab.pas` `LoadNonSteamFolders`, modify the file attribute checks to allow files with `.appimage` extension case-insensitively, setting `IsAppImage := True`
- [x] 2.2 In `games_tab.pas` `LoadNonSteamFolders`, assign `GameName` using the clean name returned by `NormalizeAppImageName` if the item is an AppImage file

## 3. Verification and Testing

- [x] 3.1 Verify that adding a non-Steam directory containing an AppImage file (e.g. `Dusklight-v1.4.1-linux-x86_64.appimage`) successfully renders a card with the clean title "Dusklight"
- [x] 3.2 Verify that the mouse hover tooltip of the AppImage card correctly shows "Dusklight" on the first line and the full absolute path of the file on the second line
- [x] 3.3 Verify that clicking the card successfully creates the configuration directory `~/.local/share/goverlay/gameconfig/dusklight/`

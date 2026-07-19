## 1. Path Resolution Updates in games_tab.pas

- [x] 1.1 Replace hardcoded NonSteamFile path in `RefreshGameCards` (line 1389) to use `TConfigManager.GetGoverlayFolder`
- [x] 1.2 Replace hardcoded NonSteamFile path in `AddNonSteamFolderClick` (line 2874) to use `TConfigManager.GetGoverlayFolder`
- [x] 1.3 Replace hardcoded NonSteamFile path in `RemoveFolderMenuItemClick` (line 2938) to use `TConfigManager.GetGoverlayFolder`
- [x] 1.4 Replace hardcoded NonSteamFile path in `ShowRemoveFoldersMenu` (line 2980) to use `TConfigManager.GetGoverlayFolder`

## 2. Verification and Testing

- [x] 2.1 Build GOverlay with the changes to verify compilation
- [x] 2.2 Verify that adding a non-Steam folder persists upon restarting GOverlay (native run)
- [x] 2.3 Verify that adding a non-Steam folder persists when simulated in Flatpak (using `FLATPAK_ID` environment variable)

## 1. Modify Cover Loading Logic

- [x] 1.1 In `games_tab.pas` `LoadNonSteamFolders`, check `IsAppImage` inside the `else` block when `HasCover` is false. If it is an AppImage, call `GenerateFallbackCover` and skip queueing it for download.

## 2. Verification and Testing

- [x] 2.1 Verify that the Pascal project builds successfully without syntax or type errors
- [x] 2.2 Verify that AppImage games render the generic fallback cover immediately on first load

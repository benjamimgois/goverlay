## 1. Implementation

- [x] 1.1 Replace the synchronous `GetReleaseNotes` and `ShowChangelogPopup` calls inside `whatsNewMenuItemClick` (line 8116) in `overlayunit.pas` with instantiating and starting `TChangelogFetchThread`

## 2. Verification

- [x] 2.1 Rebuild GOverlay to verify compilation passes
- [x] 2.2 Run GOverlay with offscreen rendering to verify it starts and doesn't crash on startup

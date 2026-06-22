## 1. Modify Queue Logic in games_tab.pas

- [x] 1.1 Update library scanning logic in `games_tab.pas` to format `PendingIDs` queue items as `AppID=GameName`

## 2. Refactor TCoverDownloadThread in games_tab.pas

- [x] 2.1 Parse `AppID` and `GameName` in `TCoverDownloadThread.Execute` using string helper parsing
- [x] 2.2 Add fallback logic to invoke `FForm.SearchWebCover` when CDN cover downloads fail in `TCoverDownloadThread.Execute`
- [x] 2.3 Generate a fallback cover (GOverlay icon centered on a dark background) at `OutPath` if both CDN and web searches fail

## 3. Verify and Compile

- [x] 3.1 Run `make` to compile `goverlay` and verify it compiles without errors


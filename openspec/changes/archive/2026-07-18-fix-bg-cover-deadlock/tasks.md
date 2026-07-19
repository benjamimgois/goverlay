## 1. Refactor Steam Cover Thread in games_tab.pas

- [x] 1.1 Declare the `DoGenerateFallback` method in `TCoverDownloadThread` in `games_tab.pas`
- [x] 1.2 Implement `TCoverDownloadThread.DoGenerateFallback` to call `GenerateFallbackCover`
- [x] 1.3 Update the fallback generation inside `TCoverDownloadThread.Execute` to invoke `Synchronize(@DoGenerateFallback)`

## 2. Refactor Non-Steam Cover Thread in games_tab.pas

- [x] 2.1 Declare the `DoGenerateFallback` method in `TNonSteamCoverThread` in `games_tab.pas`
- [x] 2.2 Implement `TNonSteamCoverThread.DoGenerateFallback` to call `GenerateFallbackCover`
- [x] 2.3 Update the fallback generation inside `TNonSteamCoverThread.Execute` to invoke `Synchronize(@DoGenerateFallback)`

## 3. Verification

- [x] 3.1 Build the GOverlay application to verify it compiles successfully
- [x] 3.2 Clear the cache directories and verify GOverlay launches and resolves cover fallbacks without deadlocks

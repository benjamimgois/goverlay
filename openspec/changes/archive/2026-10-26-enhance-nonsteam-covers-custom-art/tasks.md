# Tasks

## 1. Resilient Download and Cache Sanitation

- [x] 1.1 Update `DownloadSteamCover` and `SearchWebCover` in `games_tab.pas` to use `curl --fail`, download to temporary `.tmp` files, and validate image size (> 2048 bytes) before committing to cache.
- [x] 1.2 Add cache validation logic in `LoadSteamGames` and `TNonSteamCoverThread` in `games_tab.pas` to detect and automatically delete corrupt or truncated (<= 2048 bytes) cached files and trigger fallback or retry.

## 2. Aspect-Ratio Preserving Scaling (Center Crop / Aspect Fill)

- [x] 2.1 Implement `DrawCoverAspectFill` helper in `games_tab.pas` to calculate proportional center-cropped source rectangles for square (1:1) and widescreen (16:9) images.
- [x] 2.2 Update cover rendering calls in `TCoverDownloadThread`, `TNonSteamCoverThread`, and `LoadSteamGames` to use `DrawCoverAspectFill` instead of unconstrained `StretchDraw`.

## 3. Multi-Format & Local Artwork Resolution (Heroic, Lutris, Game Folder)

- [x] 3.1 Implement `ResolveNonSteamLocalCover` in `games_tab.pas` supporting `.png`, `.jpg`, and `.jpeg` extensions in `~/.cache/goverlay/nonsteam_covers/`.
- [x] 3.2 Add game directory lookup in `ResolveNonSteamLocalCover` checking `<SubPath>` for `cover.*`, `poster.*`, and `folder.*`.
- [x] 3.3 Add Heroic Games Launcher cover resolution in `ResolveNonSteamLocalCover` checking native and Flatpak Heroic config paths (`icons/<app_name>.*`) via `SubPath` and title matching.
- [x] 3.4 Add Lutris cover resolution in `ResolveNonSteamLocalCover` checking native and Flatpak Lutris paths (`coverart/<slug>.*` and `banners/<slug>.*`).
- [x] 3.5 Wire `ResolveNonSteamLocalCover` into card initialization in `LoadSteamGames` and `TNonSteamCoverThread` before remote download attempts.

## 4. Custom Cover Management via Context Menu

- [x] 4.1 Add "Set custom cover..." and "Reset cover art" menu items to `FGameCardMenu` in `games_tab.pas`.
- [x] 4.2 Implement custom cover selection dialog handler (`TOpenDialog`) to import image files into cache and refresh the card bitmap and sidebar thumbnail immediately.
- [x] 4.3 Implement cover reset action to delete cached files for the selected game and re-trigger local resolution or fallback generation.

## 5. Automated Verification & Test Coverage

- [x] 5.1 Add test cases in `tests/gui/gui_test_cases.pas` verifying corrupt cache file rejection, multi-format detection, aspect crop calculations, and custom cover menu action handling.
- [x] 5.2 Compile and run the test suites (`./tests/logic/logic_tests` and `./tests/gui/gui_tests`) to verify that all existing and new tests pass cleanly.

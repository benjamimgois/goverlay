## 1. Splash Screen Binary (bgmod-splash)

- [x] 1.1 Create `bgmod-splash` LCL project files (`bgmod_splash_src/bgmod_splash.lpr`, `bgmod_splash.lpi`, and main form) with frameless window styling, GOverlay branding, and dynamic checklist painting.
- [x] 1.2 Implement command line parameter parsing (`--game=`, `--item=`, `--duration=`), 2.5s auto-dismiss timer, and immediate dismiss on mouse click or Escape/Space/Enter key.
- [x] 1.3 Add `bgmod-splash` build and install targets to `Makefile` and verify it compiles cleanly with `lazbuild`.

## 2. Settings Menu Integration & Configuration

- [x] 2.1 Add `FLaunchSplashItem` (`TMenuItem`) to `settingsMenu` directly beneath `FCreateSteamShortcutItem` in `sidebar_nav.pas` and `overlayunit.pas`, with `AutoCheck := True`.
- [x] 2.2 Implement load, toggle, and save logic for `ShowLaunchSplash` in `goverlay.conf` (defaulting to True) and serialize `SHOW_LAUNCH_SPLASH` into `bgmod.conf`.

## 3. bgmod Wrapper Integration

- [x] 3.1 Update `bgmod.lpr` to read `SHOW_LAUNCH_SPLASH` from `bgmod.conf` (defaulting to `1`) and collect the list of actively enabled modules.
- [x] 3.2 Implement asynchronous `fpFork` dispatch of `bgmod-splash` with module arguments immediately prior to `execvpe`, verifying game execution remains completely non-blocking.

## 4. Testing & Verification

- [x] 4.1 Add GUI test cases in `tests/gui/gui_test_cases.pas` asserting `FLaunchSplashItem` presence in `settingsMenu`, its position under `FCreateSteamShortcutItem`, and config persistence.
- [x] 4.2 Verify full GUI test suite passes (`tests/gui/gui_tests --all`) and verify manual execution of `bgmod-splash` with mock items.

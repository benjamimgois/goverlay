# Tasks

## 1. bgmod

- [x] 1.1 Add `realpath`-based path normalisation and `FindRuntimeProfile` (identity file + cached `GAME_DIR`, longest match, `/` and `$HOME` rejected); verify with logic tests.
- [x] 1.2 Introduce `ProfileDir` and use it for `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf` and `plugins/`; verify existing bgmod tests still pass.
- [x] 1.3 In global mode with `RUNTIME_PROFILE` on, resolve the game directory early, switch profile paths on a match, skip the second resolution, and log the decision; verify with logic tests.

## 2. GOverlay

- [x] 2.1 Add `WriteGameProfileIdentity`/`RefreshGameProfileIdentity`/`IsGameProfileEnabled` and constants; enable on clone, refresh on card selection, "Use game-specific settings" card menu toggle; verify with GUI tests.
- [x] 2.2 Add the "Automatic game profile selection" settings toggle persisted to `goverlay.conf` and the global `bgmod.conf`; verify the build.
- [x] 2.3 Show the global launch command when the toggle is on; verify the GUI tests pass.

## 3. Verification

- [x] 3.1 Logic tests: match via identity, match via cached `GAME_DIR`, no match, disabled, folder without `bgmod.conf`, longest match, AppImage file, `ENABLED=0` overriding the cache.
- [ ] 3.2 Run `make test`. Logic suite 111/111 passes; the affected GUI tests pass individually (`--test=`), but the full GUI suite hangs on the development host in unrelated `poWaitOnExit` + `poUsePipes` callers (`curl`) once pipes shrink to one page, so it still needs a full run elsewhere.
- [x] 3.3 Manual check with the global launch command: Steam, Heroic and Lutris games each load their game profile when "Use game-specific settings" is on, and the global profile otherwise.

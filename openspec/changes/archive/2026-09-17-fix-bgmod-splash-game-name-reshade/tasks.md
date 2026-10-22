# Tasks

## 1. Implement Splash Game Title and ReShade Support in bgmod

- [x] 1.1 Declare `GameProfileName: string;` in `bgmod.lpr` and assign it from `ExtractFileName(TempStr)` at startup, decoupling profile identification from scratch parsing variables (`Key`, `Line`, `Val`). Verify compilation of variable declarations.
- [x] 1.2 Update splash title logic in `bgmod.lpr` to use `GameProfileName` instead of `Key` (with fallback to `TargetExeName` in global mode).
- [x] 1.3 Add `if GOverlayReshade then SplashItems.Add('ReShade');` in `bgmod.lpr` alongside `vkBasalt`.
- [x] 1.4 Compile `bgmod` via `make bgmod` and verify binary builds and syncs to `data/bgmod/bgmod`.

## 2. Testing and Validation

- [x] 2.1 Add unit tests in `tests/logic/logic_test_cases.pas` to verify that environment variables (including `VKSUMI_CONFIG_FILE`) in `bgmod.conf` do not corrupt the game profile name and that `GOVERLAY_RESHADE=1` causes ReShade to be included in splash items.
- [x] 2.2 Run test suite (`make test-logic` and `make test`) and verify all tests pass without errors.
- [x] 2.3 Verify `bgmod-splash` displays the correct game title and ReShade checklist item using a mock command invocation in xvfb.

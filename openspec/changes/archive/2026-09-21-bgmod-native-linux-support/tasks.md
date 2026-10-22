# Tasks: Native Linux Game Support for bgmod

## 1. Native Executable Resolution in bgmod & bgmod-uninstaller

- [x] 1.1 Implement `IsElfBinary` helper and `IsKnownWrapper` filter in `bgmod.lpr` to identify valid Linux executables and skip runtime wrappers (e.g. `_v2-entry-point`, `gamemoderun`, `env`, `sh`, `bash`).
- [x] 1.2 Extend `ResolveGameDirectory` in `bgmod.lpr` to resolve `TargetExeName` and `GameDir` from native Linux command-line arguments when no `.exe` is found, handling container boundaries (`--`).
- [x] 1.3 Implement identical native resolution logic (`IsElfBinary`, wrapper filters, and `ResolveGameDirectory`) in `bgmod-uninstaller.lpr`.

## 2. Configuration & Profiling Integration

- [x] 2.1 Update `conf.toml` profile generation in `bgmod.lpr` (for both `lsfg` and `mako`) so that native Linux executable names are populated in `active_in`.
- [x] 2.2 Cache resolved `TARGET_EXE` and `GAME_DIR` into `bgmod.conf` under `[Config]` in per-game profile mode.
- [x] 2.3 Update `lossless_scaling_tab.pas` in GOverlay to read `TARGET_EXE` from `bgmod.conf` when writing `conf.toml` from the GUI.

## 3. Native Linux Safety Guards

- [x] 3.1 Add guard in `bgmod.lpr` to bypass OptiScaler and ReShade Windows DLL copying/injection when a native Linux executable is detected.

## 4. Verification & Testing

- [x] 4.1 Add unit and logic test cases in `tests/logic/` covering native Linux executable detection, container `--` handling, and `conf.toml` `active_in` output.
- [x] 4.2 Compile binaries (`make bgmod bgmod-uninstaller`) and execute `make test-logic` to verify tests pass cleanly.

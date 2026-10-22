# Design

## Context

See `proposal.md - Why`. In NixOS build environments (`nix-build` / `nix develop`), the filesystem does not provide standard FHS directories like `/bin` or `/usr/bin`, except `/bin/sh` in some specific chroots, and strictly isolates environment variables.

Two logic tests currently fail when running `make test-logic`:
1. `TBgmodSupervisorTests.TestBgmodLaunchSplashGameTitleAndReShade` creates a mock `bgmod-splash` shell script with `#!/bin/sh` and expects `splash_args.txt` to be written when invoked asynchronously by `bgmod`.
2. `TBgmodSupervisorTests.TestBgmodNativeLinuxResolution` creates `_v2-entry-point` with `#!/bin/sh` and copies `MockExe` with `cp`, expecting exit code 0 when `bgmod` launches it.

## Goals / Non-Goals

**Goals:**
- Ensure all test-generated scripts use valid, discoverable interpreter paths (`FindTestHelperExecutable('sh')`).
- Ensure all external commands used in test runners (e.g. `cp`) are executed via `FindTestHelperExecutable`.
- Verify that `bgmod` execution of detached helpers like `bgmod-splash` retains a valid `PATH` in `execvpe`.

**Non-Goals:**
- Restructuring `bgmod` supervisor architecture or altering runtime application behavior on user machines.

## Decisions

### 1. Dynamic Shebang Resolution in Mock Scripts
- **Decision**: In tests where mock scripts are generated (`WriteLn(F, '#!/bin/sh')`), use `WriteLn(F, '#!' + FindTestHelperExecutable('sh'))` or fallback to `/bin/sh` if empty.
- **Rationale**: In Nixpkgs build sandboxes, `sh` is located in `/nix/store/.../bin/sh`. Using the dynamically resolved shell guarantees that the kernel's `execve` loader can execute the script.
- **Alternatives Considered**: Using `#!/usr/bin/env sh`. In Nix sandboxes, `/usr/bin/env` might also not exist unless coreutils is explicitly bridged. `FindTestHelperExecutable('sh')` queries the actual runtime `PATH`, providing the exact path in the environment.

### 2. Utility Invocations via FindTestHelperExecutable
- **Decision**: Wherever `TProcess.Executable := 'cp'` (or other helper) is used in tests, set `Proc.Executable := FindTestHelperExecutable('cp')`.
- **Rationale**: `TProcess` on Unix might not automatically resolve PATH if options or environment flags are used in certain Lazarus versions. Using full paths from `FindTestHelperExecutable` avoids `EProcess: Executable not found`.

### 3. Preserving PATH in bgmod Execvpe Environment
- **Decision**: In `bgmod.lpr`, verify that `EnvStrings` always contains `PATH` from `envp` so `execvpe` in `SpawnLaunchSplashAsync` and child executions can resolve commands if needed.
- **Rationale**: `bgmod.lpr` populates `EnvStrings` from `envp`, but we must ensure `PATH` is never cleared or overwritten.

## Risks / Trade-offs

- *[Risk]* If `FindTestHelperExecutable('sh')` returns empty string in an extremely stripped environment.
  - *Mitigation*: Fall back to `/bin/sh` when `FindTestHelperExecutable` returns empty.

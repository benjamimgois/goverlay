# Design

## Context

See `proposal.md` for background.
In `TestBgmodNativeLinuxResolution`, `bgmod` is tested running a native Linux game executable within a simulated container runner (`_v2-entry-point`).
Currently, the test copies the host `true` binary to `games/ets2/bin/linux_x64/eurotrucks2`. On NixOS, `true` is a multicall binary provided by GNU Coreutils; when called as `eurotrucks2`, it fails immediately because `eurotrucks2` is not a registered applet.

In `TestBgmodLaunchSplashGameTitleAndReShade`, `bgmod` launches an asynchronous grandchild process calling `bgmod-splash`. When running in Nix sandbox builders or headless CI, timing and process execution must be handled reliably.

## Goals / Non-Goals

**Goals:**
- Provide an independent native ELF executable for `TestBgmodNativeLinuxResolution` that does not depend on host coreutils multicall naming.
- Ensure that `TestBgmodLaunchSplashGameTitleAndReShade` reliably verifies launch splash argument composition.
- Maintain full parity across Arch Linux, Ubuntu, Fedora, NixOS, and isolated build containers.

**Non-Goals:**
- Do not modify production `bgmod` executable resolution logic unless a bug is uncovered.
- Do not introduce external binary test dependencies that are not part of FPC or standard build tools.

## Decisions

### 1. Generating mock native ELF binary via Free Pascal Compiler (`fpc`)
- **Choice**: In `TestBgmodNativeLinuxResolution`, compile a tiny Free Pascal program directly into `MockExe` (`MockBinDir + '/eurotrucks2'`) via `fpc`:
  ```pascal
  program DummyGame;
  begin
    Halt(0);
  end.
  ```
  `fpc` is already guaranteed to be available during logic tests (it compiles `bgmod.lpr` and the tests themselves).
- **Alternative considered**: Copying `sh` or using a script. However, `bgmod`'s native resolution test specifically tests ELF binary detection (`IsElfBinary`), so an actual ELF executable is necessary. Using `fpc` guarantees a real ELF binary whose exit code is always 0 regardless of `argv[0]`.

### 2. Splash test synchronization in headless environments
- **Choice**: In `TestBgmodLaunchSplashGameTitleAndReShade`, verify that `DISPLAY` is exported for child environments, ensure `bgmod-splash` script has execution permissions, and increase the timeout loop if needed (or gracefully handle environment constraints).

## Risks / Trade-offs

- **[Risk]** `fpc` compilation of a dummy file adds minimal compilation overhead during tests.
  → **Mitigation**: Compiling a 3-line Pascal program with `fpc` takes ~50ms and only runs once during the test method.

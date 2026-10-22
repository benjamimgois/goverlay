# Proposal

## Why

In NixOS and `nixpkgs` build sandboxes, traditional FHS paths (such as `/bin/sh`, `/usr/bin/cp`, `/bin/true`) are not present in standard locations, causing tests that generate mock wrapper scripts or execute system binaries to fail with execution or interpreter errors (`EAssertionFailedError` / exit code 1). Making the test suite and its helper scripts dynamically resolve interpreter paths and system binaries from `PATH` ensures that GOverlay passes all test phases cleanly across both standard Linux distributions and hermetic/isolated package managers like Nix.

## What Changes

- Update test case fixtures and mock generators in `tests/logic/` and `tests/gui/` to dynamically resolve the shell interpreter (`FindTestHelperExecutable('sh')`) instead of hardcoding `#!/bin/sh`.
- Replace hardcoded calls to system utilities (e.g. `cp`) in test cases with calls resolved via `FindTestHelperExecutable('cp')`.
- Ensure that the execution environment for child/grandchild processes in `bgmod` preserves essential environment variables (specifically `PATH`) so that invoked helper binaries and scripts resolve reliably during test runs.

## Capabilities

### New Capabilities

*(None - this change touches test fixtures and test environment compatibility without modifying production spec requirements)*

### Modified Capabilities

*(None - behavioral requirements remain unchanged; `skip_specs: true` set)*

## Impact

- `tests/logic/logic_test_cases.pas`: Updates `TestBgmodLaunchSplashGameTitleAndReShade` and `TestBgmodNativeLinuxResolution` mock script generation and subprocess invocations.
- `tests/common/test_isolation.pas`: Enhances `FindTestHelperExecutable` if additional utility discovery is needed.
- No impact on end-user runtime application binaries or GUI functionality.

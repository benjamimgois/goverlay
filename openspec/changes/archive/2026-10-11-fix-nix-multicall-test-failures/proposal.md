# Proposal

## Why

In Nixpkgs sandboxes, standard GNU Coreutils is built as a single multicall binary where utilities like `true` dynamically dispatch based on `argv[0]`. In `TestBgmodNativeLinuxResolution`, copying the host `true` binary to a mock game executable name (`eurotrucks2`) causes coreutils to reject execution with `coreutils: unknown program 'eurotrucks2'` and return exit code 1. Furthermore, in asynchronous detached helper tests like `TestBgmodLaunchSplashGameTitleAndReShade`, reliance on headless execution under Nix sandbox environments requires robust handling of mock generation and timeout polling. Fixing these test fixtures allows the test suite (`make test-logic` / Nixpkgs `checkPhase`) to pass hermetically across NixOS and all standard Linux distributions.

## What Changes

- Update `TestBgmodNativeLinuxResolution` to avoid copying the multicall host `true` binary; instead, compile or generate an independent native ELF binary (using `fpc` or a dedicated helper) whose execution is agnostic to `argv[0]`.
- Strengthen `TestBgmodLaunchSplashGameTitleAndReShade` to ensure mock splash generation, headless environment detection, and execution synchronization reliably complete inside build sandboxes.
- Ensure all test mocks operate cleanly in environments where coreutils utilities are multicall or strictly isolated.

## Capabilities

### New Capabilities

*(None - this change fixes test fixtures and environment compatibility without introducing new product capabilities)*

### Modified Capabilities

*(None - existing product specifications and runtime behaviors are preserved; `skip_specs: true` is configured)*

## Impact

- `tests/logic/logic_test_cases.pas`: Updates fixture setup for `TestBgmodNativeLinuxResolution` and `TestBgmodLaunchSplashGameTitleAndReShade`.
- No impact on end-user runtime application code or GUI workflows.

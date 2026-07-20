## Why

GOverlay currently lacks automated integration tests for its user interface. When new features are introduced, verify-testing is done manually, which is error-prone, time-consuming, and misses regressions in critical user flows. Adding an automated end-to-end GUI test suite running in a virtual display environment (Xvfb) will allow quick, repeatable testing of core settings, saving operations, and tab transitions.

## What Changes

- **Test Infrastructure**: Create a `tests/` directory to house automated test scripts.
- **E2E Test Runner**: Add a Python-based test runner that boots GOverlay inside `Xvfb` and simulates user events (keyboard/mouse inputs) to navigate the app and manipulate configs.
- **Config Verification**: Implement assertions that read the resulting configuration files (like `config.ini`, `OptiScaler.ini`, etc.) to verify they match expected settings.
- **CI/CD Integration**: Add a helper script to easily run the test suite locally or inside GitHub Actions.

## Capabilities

### New Capabilities
- `e2e-gui-testing`: Automated verification of LCL-based GOverlay user interface navigation, button states, tab switching, and config file generation.

### Modified Capabilities
- *(none)*

## Impact

- `tests/`: New directory containing scripts (`run_e2e_tests.py`, `requirements.txt`).
- No impact on core production GOverlay code.

## Why

During E2E integration tests, the GOverlay "What's new" release changelog popup is shown by default on first run because the `$HOME` directory is mock-empty. This popup overlay hijacks mouse clicks and window focus, preventing E2E tests from clicking the main tabs. Additionally, LCL window layout scaling must use separate rules for fixed-width components (left menu) and scaled components (right-side groupbox).

## What Changes

- **Avoid Changelog Popup**: Write a mock `config.ini` in the temporary `$HOME` folder before GOverlay starts, flagging the changelog for the current version as already seen.
- **Fixed vs Proportional Scaling**: Calculate clicks using absolute positions for the left-side fixed menu (width=211) and proportional geometry calculations for the right-side layout (Mesa radio button relative to the right border).

## Capabilities

### New Capabilities
- *(none)*

### Modified Capabilities
- `e2e-gui-testing`: The integration tests must mock initial state configurations to prevent interactive popups from blocking automated tests.

## Impact

- `tests/run_e2e_tests.py`: Writes mock `config.ini` and implements updated click coordinates logic.

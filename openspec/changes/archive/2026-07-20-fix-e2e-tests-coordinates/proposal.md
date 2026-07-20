## Why

The E2E test suite's simulated click coordinates fail on systems with fractional display scaling (HiDPI) or custom window manager decorations (such as title bar offsets under KDE Plasma). To ensure E2E tests are robust and reliable on different desktop environments, we need a dynamic scaling and sweep-based coordinate clicking system.

## What Changes

- **Automatic DPI Scaling**: Read the window's physical dimensions using `xdotool getwindowgeometry` and scale coordinates proportionally to the design size (1045x683).
- **Y-Offset Click Sweeps**: Automatically cycle through different Y-axis offsets when clicking toggles to tolerate title bars and theme-dependent border spacing, checking for file persistence success between clicks.

## Capabilities

### New Capabilities
- *(none)*

### Modified Capabilities
- `e2e-gui-testing`: The integration tests must adapt to fractional system scaling and title bar decorations.

## Impact

- `tests/run_e2e_tests.py`: Updated coordinate calculations and click implementation.

# Proposal

## Why

Issue #363 reported that MangoHud color options and OptiScaler "Force Reflex" revert to defaults or toggle unexpectedly. While key serialization was added previously, two core regressions remain in v1.9.4:
1. OptiScaler seeds `force_reflex=0` by default from the template `fakenvapi.ini`. GOverlay treats `HasKey('force_reflex=')` as `ForceReflexChecked := True`, causing "Force Reflex" to appear enabled by default on initial launch or re-seed, even though `0` means "Follow in-game setting" (unforced).
2. MangoHud's `HexToColor` helper crashes on valid configurations that use `#` prefix (e.g. `#FF0000`), spaces, or inline formatting, causing `LoadMangoHudConfig` to abort mid-stream and leaving subsequent colors and checkboxes in their uninitialized reset states.

## What Changes

- **OptiScaler Force Reflex Truth Alignment**: Decouple `force_reflex=0` from `ForceReflexChecked`. The toggle switch is only checked when `force_reflex` is explicitly set to `1` ("Force disable") or `2` ("Force enable"). Value `0` or key absence resolves to unchecked (`False`), matching upstream FakeNVAPI semantics.
- **Robust Hex & Color Parsing in MangoHud**: Update `HexToColor` in `mangohud_ui.pas` to safely sanitize strings (strip leading `#` and whitespace, validate length) and use `TryStrToInt` with a fallback color. Add per-line `try ... except` error isolation in `LoadMangoHudConfig` so formatting anomalies in single keys do not abort loading the entire configuration file.
- **Synchronized Toggle & AutoSave State**: Ensure `FfpscolorToggle` properly synchronizes with `fpscolorCheckBox` during load and that color picker changes immediately persist via AutoSave when FPS color customization is enabled.

## Capabilities

### New Capabilities
- `optiscaler-reflex-persistence`: Governs the persistence and UI state synchronization of FakeNVAPI's `force_reflex` parameter, ensuring that "Follow in-game setting" (`0`) is treated as unforced and that user toggle state is preserved across profile creation and template seeding.

### Modified Capabilities
- `mangohud-fps-colors`: Extends FPS color and threshold handling to safely parse hex values with `#` prefixes or whitespace without throwing unhandled conversion exceptions during configuration load.

## Impact

- `overlay_config.pas`: `LoadOptiScalerConfig` and `SaveOptiScalerConfigCore` handling of `force_reflex`.
- `mangohud_ui.pas`: `HexToColor` error resilience, `LoadMangoHudConfig` error trapping, and toggle synchronization.
- Automated tests: GUI and logic regression tests in `tests/gui/gui_test_cases.pas` and `tests/logic/logic_test_cases.pas`.

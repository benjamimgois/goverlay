## Context

See proposal.md for motivation and problem statement.

Currently, when the user selects the Latest FSR version (item index 0) in the OptiScaler tab, `overlay_config.pas` sets `Fsr4UpdateValue := 'true'`. During `SaveOptiScalerConfig`, `OptiCfg.SetValue(OPTI_KEY_FSR4_UPDATE, Fsr4UpdateValue)` writes `Fsr4Update=true` to `OptiScaler.ini`.

## Goals / Non-Goals

**Goals:**
- Update `SaveOptiScalerConfig` to assign `Fsr4UpdateValue := 'auto'` for Latest FSR version.
- Maintain backwards compatibility in `LoadOptiScalerConfig` so existing `OptiScaler.ini` files containing `Fsr4Update=true` or `Fsr4Update=auto` both resolve to Latest FSR version (index 0).
- Update the UI tooltip hint in `overlayunit.lfm` for `fsrversionComboBox` to mention `Fsr4Update=auto`.
- Update automated GUI unit tests in `tests/gui/gui_test_cases.pas`.

**Non-Goals:**
- Changing other OptiScaler settings such as `FsrAgilitySDKUpgrade` or `Fsr4ForceEnableInt8`.

## Decisions

### Decision 1: Default `Fsr4UpdateValue` to `'auto'` on Save
- **Rationale**: Setting `Fsr4Update=auto` allows OptiScaler to manage auto-updating FSR DLLs appropriately without hardcoding `true`.
- **Alternatives Considered**: Hardcoding `true` (deprecated) or adding a user toggle for `Fsr4Update` (unnecessary complexity).

### Decision 2: Dual check in `LoadOptiScalerConfig` for `true` and `auto`
- **Rationale**: Existing user `OptiScaler.ini` files may contain `Fsr4Update=true`. Checking `SameText(Value, 'auto') or SameText(Value, 'true')` ensures existing installations continue loading as Latest FSR version, and upon saving, GOverlay will rewrite the line to `Fsr4Update=auto`.

## Risks / Trade-offs

- [Risk] Legacy tests asserting `Fsr4Update=true` will fail.
  → *Mitigation*: Update `tests/gui/gui_test_cases.pas` to assert `Fsr4Update=auto`.

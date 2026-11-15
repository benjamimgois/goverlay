# Proposal

## Why

Users report in issue #463 that OptiScaler settings in the **global** configuration (`gameconfig/global/`), such as the OptiScaler branch (`OPT_CHANNEL`) and Force Reflex toggle (`fakenvapi.ini`), reset to default values whenever Goverlay starts.

During `FormCreate`, `LoadOptiScalerConfig` runs without `FLoadingConfig := True` and before `FOptiscalerUpdate` is initialized. Setting `optiscalerRadioButton.Checked := True` (and other upscaler radio buttons) fires `OnClick` handlers that reset `optversionComboBox.ItemIndex` to `0` (Stable) and call `SaveOptiScalerConfig(True)`, overwriting `gameconfig/global/bgmod.conf` mid-load. Additionally, `CopyOptiScalerGameFiles` unconditionally overwrites `fakenvapi.ini`, and enabling the Force Reflex toggle while `reflexComboBox` remains on index `0` ("Follow game setting") serializes `force_reflex=0`, which is reloaded as unchecked on restart.

## What Changes

- Guard `LoadOptiScalerConfig` (both in `FormCreate` and inside `TOptiScalerTabHelper.LoadOptiScalerConfig`) so programmatic UI updates do not trigger upscaler radio-button `OnClick` handlers or `SaveOptiScalerConfig` mid-load.
- Guard all upscaler radio-button click handlers (`optiscalerRadioButtonClick`, `dlssenablerRadioButtonClick`, `noneUpscalerRadioButtonClick`, `helixsrRadioButtonClick`, `dlssnrRadioButtonClick`) with `if FLoadingConfig then Exit;` (or suppress `OnClick` during load) and ensure `FOptiscalerUpdate` channel restoration does not get overwritten by startup initialization order.
- Update `CopyOptiScalerGameFiles` in `sidebar_nav.pas` so `fakenvapi.ini` (and `OptiScaler.ini`) are only seeded when missing, preserving user-configured `force_reflex` and latency settings.
- When the user enables the Force Reflex toggle (`forcereflexCheckBoxChange`) while `reflexComboBox.ItemIndex` is `0` ("Follow game setting"), default `reflexComboBox.ItemIndex` to `2` ("Force enable") so the enabled toggle persists across restarts instead of writing `force_reflex=0`.

## Capabilities

### New Capabilities

### Modified Capabilities
- `upscaler-channel-persistence`: Ensure global configuration channel (`OPT_CHANNEL`) is preserved across application startup and not overwritten by programmatic radio-button selection during `FormCreate` or profile load.
- `optiscaler-reflex-persistence`: Preserve `fakenvapi.ini` across `CopyOptiScalerGameFiles` seeding and ensure enabling the Force Reflex toggle selects an active forced mode (`Force enable`) when the mode combobox is still on `Follow game setting`.

## Impact

- `overlayunit.pas`: `FormCreate` (`FLoadingConfig` guard around `LoadOptiScalerConfig`), `*RadioButtonClick` handlers, and `forcereflexCheckBoxChange`.
- `optiscaler_tab.pas`: `TOptiScalerTabHelper.LoadOptiScalerConfig` (suppressing radio-button `OnClick` during UI population).
- `sidebar_nav.pas`: `TSidebarNavHelper.CopyOptiScalerGameFiles` (seed `fakenvapi.ini` only if absent).
- `tests/`: Regression tests covering global startup reload of `OPT_CHANNEL` and `force_reflex` persistence.

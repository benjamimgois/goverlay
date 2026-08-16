## Why

When an update is available for DLSS Enabler, the Software Status card on the Upscalers tab incorrectly appends the update arrow and target version string (`→ <new_version>`) to the **OptiScaler** label (e.g. `stable-0.9.4 → 4.8.13.19`), while the **DLSS Enabler** label continues to show only its installed version without any update indicator. The OptiScaler row should remain showing its installed stable version (e.g. `stable-0.9.4`), and the DLSS Enabler row should show the update notification (e.g. `4.8.12 → 4.8.13.19`).

## What Changes

- **Route Update Indication to DLSS Enabler**: In `TOptiScalerTabHelper.RefreshOsStatusDots` (`optiscaler_tab.pas`), check whether DLSS Enabler is the active upscaler (`dlssenablerRadioButton.Checked`).
  - When DLSS Enabler is active:
    - Keep the OptiScaler row (index 0) displaying its installed version in standard color (`PURPLE`) without the update notification arrow.
    - Display the update arrow and new tag (`<installed_ver> → <new_tag>`) in `CLR_UPDATE` on the DLSS Enabler row (index 2).
  - When standard OptiScaler is active:
    - Retain existing OptiScaler update indication logic on index 0 and `--` on index 2.
- **Automated GUI Test**: Add/update a test case in `tests/gui/gui_test_cases.pas` to ensure that when a DLSS Enabler update is found, the DLSS Enabler status row reflects `installed → latest` and OptiScaler remains untouched.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `upscalers-dlss-enabler`: Requirements for displaying update notifications specifically on the DLSS Enabler row in the Software Status card when DLSS Enabler is active.

## Impact

- `optiscaler_tab.pas`: `RefreshOsStatusDots` properly directs the update status string to `FOsStatVerLbls[2]` (DLSS Enabler) when `dlssenablerRadioButton` is checked, preserving `FOsStatVerLbls[0]` (OptiScaler) with its installed stable version.
- `tests/gui/gui_test_cases.pas`: Regression tests for DLSS Enabler update status display.

# Change Proposal: Fix DLSS Enabler Software Status UI

## Context
On branch `de-alternate`, when DLSS Enabler is selected on the Stable channel, the Software Status card in the OptiScaler tab displays 3 visual defects:

1. OptiScaler version row shows DLSS Enabler's build tag (`4.8.12`) instead of the OptiScaler stable version (`0.9.4`).
2. Streamline SDK row displays `—` with a gray dot because `streamlineVersionLabel` was not instantiated in `optiscaler_tab.pas`.
3. The "DLSS / FSR / XeSS" version label overlaps over the text "XeSS" due to hardcoded horizontal column positioning offsets.

## Proposed Changes

### 1. Update OptiScaler Version Loading (`optiscaler_update.pas`)
- Remove `optiScalerVersion=TagName` writing from `CheckAndInstallDlssEnabler`.
- Update `LoadVersionsFromFile` to retain the true OptiScaler version (`0.9.4` on stable) on the OptiScaler row when DLSS Enabler is active.

### 2. Instantiate Streamline Version Label (`optiscaler_tab.pas`)
- Add `streamlineVersionLabel := TLabel.Create(FForm);` in `InitOptiScalerTab` with `Parent := FOsUpscalerCard` and `Visible := False`.

### 3. Fix Layout Overlap (`optiscaler_tab.pas`)
- In `ReflowOptiScalerTabNew`, calculate `FOsStatVerLbls[i].Left` dynamically using `FOsStatNameLbls[i].Left + FOsStatNameLbls[i].Width + 8` to prevent text overlap.

## Non-Goals
- Modifying `bgmod.lpr` runtime script execution.

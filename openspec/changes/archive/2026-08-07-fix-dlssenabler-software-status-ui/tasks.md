# Implementation Tasks: Fix DLSS Enabler Software Status UI

- [x] 1. Update Version Resolution Logic
  - [x] 1.1 In `optiscaler_update.pas`, update `CheckAndInstallDlssEnabler` to not write `optiScalerVersion` tag into DLSS Enabler `goverlay.vars`.
  - [x] 1.2 In `optiscaler_update.pas`, update `LoadVersionsFromFile` to retain the OptiScaler stable version (`0.9.4`) when DLSS Enabler is active.

- [x] 2. Fix Label Instantiation and Layout
  - [x] 2.1 In `optiscaler_tab.pas`, instantiate `streamlineVersionLabel := TLabel.Create(FForm);` in `InitOptiScalerTab`.
  - [x] 2.2 In `optiscaler_tab.pas`, update `ReflowOptiScalerTabNew` to position version labels dynamically (`FOsStatNameLbls[i].Left + FOsStatNameLbls[i].Width + 8`).

- [x] 3. Build & Verification
  - [x] 3.1 Rebuild `goverlay` using `lazbuild -B goverlay.lpi`.
  - [x] 3.2 Verify that OptiScaler displays `0.9.4`, Streamline SDK displays `2.12.0`, and "DLSS / FSR / XeSS" has no label overlap.

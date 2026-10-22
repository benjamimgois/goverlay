## 1. OptiScaler Tab Toggles Implementation

- [x] 1.1 Add `toggle_switch` to `optiscaler_tab.pas` uses list, declare `TToggleSwitch` fields and `FOsToggles` list in `TOptiScalerTabHelper`.
- [x] 1.2 Initialize and link `TToggleSwitch` controls to `optipatcherCheckBox`, `spoofCheckBox`, `forceFsr4Int8CheckBox`, `emufp8CheckBox`, `forcereflexCheckBox`, and `forcelatencyflexCheckBox` in `InitOptiScalerTab`.
- [x] 1.3 Update `ReflowOptiScalerTabNew` to position the 6 toggle switches and align companion `FOsPatcherListBtn` 🔗 button seamlessly.
- [x] 1.4 Add synchronization loop in `LoadOptiScalerConfig` and `InitOptiScalerTab` using `SyncAllToggles`.

## 2. Verification and Testing

- [x] 2.1 Run `make test-logic` and verify all 14 logic test cases pass.
- [x] 2.2 Run `make test-gui` and verify all 83 GUI test cases pass.
- [x] 2.3 Build `make goverlay` release binary to verify clean compilation.

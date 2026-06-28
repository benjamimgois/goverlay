## 1. Custom Preset UI Synchronization & Handling

- [x] 1.1 Update `usercustomBitBtnClick` in `overlayunit.pas` to invoke `FMangoHudHelper.LoadMangoHudConfig` upon copying `custom.conf`.
- [x] 1.2 Update `PresetCardClick` and visual state logic in `mangohud_ui.pas` to verify `custom.conf` existence before marking the Custom card as active.
- [x] 1.3 Verify project build and test custom preset loading workflow.

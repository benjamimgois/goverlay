# Tasks

## 1. Data Model & Configuration Serialization

- [x] 1.1 Add `TimeFormat` field to `TMangoHudSettings` in `overlay_config.pas` and verify clean compilation
- [x] 1.2 Add `MANGO_KEY_TIME_FORMAT` constant in `configkeys.pas`
- [x] 1.3 Update `SaveMangoHudConfig` in `overlay_config.pas` to serialize `time_format=<format>` when `Settings.Time` is true
- [x] 1.4 Update `LoadMangoHudKeyValue` and `ResetMangoHudControls` in `mangohud_ui.pas` to parse and reset `time_format`

## 2. Time Format Dialog & Live Preview

- [x] 2.1 Implement `ShowTimeFormatDialog` modal dialog with preset dropdown, custom format input, help hint, and dynamic formatted preview
- [x] 2.2 Apply theme styling (dark/light) to the dialog and preview components

## 3. UI Integration & Layout Reflow

- [x] 3.1 Instantiate and place `FTimeConfigBtn` adjacent to `FtimeToggle` in `FExtSysCard`
- [x] 3.2 Update `ReflowExtrasTab` in `mangohud_ui.pas` to dynamically align `FTimeConfigBtn` to `FtimeToggle.Left + FtimeToggle.Width + 4`
- [x] 3.3 Wire `FTimeConfigBtn.Enabled` state to `timeCheckBox.Checked` in toggle synchronization and change callbacks
- [x] 3.4 Wire `FTimeConfigBtn` click event to open `ShowTimeFormatDialog` and persist the selected format string in helper state

## 4. Verification & Testing

- [x] 4.1 Build GOverlay with `lazbuild` and verify zero errors or warnings
- [x] 4.2 Verify round-trip MangoHud config generation with various format presets and custom format strings

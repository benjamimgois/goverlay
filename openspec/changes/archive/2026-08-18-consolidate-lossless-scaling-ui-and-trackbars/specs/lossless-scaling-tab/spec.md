## MODIFIED Requirements

### Requirement: Lossless Scaling Tab UI & Cards Layout
The Lossless Scaling tab (`losslessScalingTabSheet`) SHALL render inside a responsive scroll box with dark theme card styling (`StyleMainCard` / `StyleSubCard`), structured into two consolidated cards:
1. **LossLess Scaling Card**:
   - `logoImage`: Lossless Scaling application icon (`assets/icons/lossless_scaling.png`) positioned on the left.
   - `dllPathEdit`: Read-only path edit positioned to the right of the logo.
   - `browseDllBtn`: File picker button positioned to the right of `dllPathEdit`.
   - `dllStatusLabel`: Status label positioned below `dllPathEdit`. When `Lossless.dll` exists, displays `"● DLL file located"` in green. When missing, displays `"● Install Lossless scaling on steam or point the correct file path"` in red and styles `dllPathEdit` with an alert red background and border tint.
2. **Configuration Card**:
   - **Row 1**: Multiplier TrackBar (`multiplierTrackBar`, range 1 to 10) with dynamic value label (`multiplierValueLabel`, displaying `1x (Disabled)` or `Nx FPS`) on the left; Flow Scale TrackBar (`flowScaleTrackBar`, range 25 to 100) with dynamic value label (`flowScaleValueLabel`) on the right.
   - **Row 2**: Three inline toggle checkboxes: Performance Mode (`performanceModeCheckBox`), HDR Mode (`hdrModeCheckBox`), and Disable FP16 / Half-Precision (`noFp16CheckBox`).
   - **Row 3**: Pacing Mode dropdown (`pacingComboBox`) on the left; Target GPU Device dropdown (`gpuComboBox`) on the right.

#### Scenario: User adjusts Multiplier TrackBar
- **WHEN** the user sets `multiplierTrackBar.Position` to `1`
- **THEN** `multiplierValueLabel.Caption` displays `"1x (Disabled)"`
- **AND** downstream controls (Flow Scale, Performance Mode, HDR Mode, FP16, Pacing, GPU) are disabled
- **AND** `GOVERLAY_LOSSLESS` is set to `0`.

#### Scenario: User adjusts Multiplier TrackBar to 4x
- **WHEN** the user sets `multiplierTrackBar.Position` to `4`
- **THEN** `multiplierValueLabel.Caption` displays `"4x FPS"`
- **AND** downstream controls are enabled
- **AND** `GOVERLAY_LOSSLESS` is set to `1` and `multiplier = 4` is saved to `lsfg.toml`.

#### Scenario: Missing DLL file path
- **WHEN** `dllPathEdit` contains an invalid or non-existent file path
- **THEN** `dllStatusLabel.Caption` displays `"● Install Lossless scaling on steam or point the correct file path"` in red
- **AND** `dllPathEdit` renders with an alert red background and border.

#### Scenario: Viewing Lossless Scaling tab when Upscalers tool is disabled
- **WHEN** the Upscalers sidebar toggle is OFF
- **AND** the user views the Lossless Scaling tab
- **THEN** all controls remain disabled, but the entire tab background renders seamlessly with the active theme background color without gray background gaps.

#### Scenario: Resizing the main application window
- **WHEN** the main GOverlay window is resized
- **THEN** `ReflowLosslessScalingTab` recalculates panel dimensions and ensures `FLsBgPanel` spans the full viewport width and height.

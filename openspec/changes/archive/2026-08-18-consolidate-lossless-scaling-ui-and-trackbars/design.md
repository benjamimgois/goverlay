## Context
The Lossless Scaling tab in GOverlay previously used 3 stacked cards, had non-standard padding, used a dropdown for the multiplier, and lacked a dedicated status label for locating the DLL file.

## Decisions

### 1. Card Consolidation and Standardized Geometry
- **Layout Margins**:
  - `MARGIN = 4;`: Outer margin inside scroll box matching OptiScaler, MangoHud, VkBasalt tabs.
  - `GAP = 6;`: Gap between cards matching standard card spacing.
  - `PAD = 14;`: Inner horizontal padding inside cards for controls.
  - `ROW_H = 28;`: Control height.
- **Card 0: LossLess Scaling**:
  - Contains duck logo (`assets/icons/lossless_scaling.png`), DLL file path edit, file browser button, and visual status label (`FLsDllStatusLabel`).
- **Card 1: Configuration**:
  - **Row 1**: Multiplier TrackBar (1x..10x) and Flow Scale TrackBar (25%..100%).
  - **Row 2**: 3 Inline Toggles: Performance Mode, HDR Mode, Disable FP16 / Half-Precision.
  - **Row 3**: Pacing Mode dropdown and Target GPU Device dropdown.

### 2. Multiplier TrackBar
- Discrete range 1 to 10.
- Position 1 represents 1x (`1x (Disabled)`), disabling downstream controls and omitting `lsfg.toml` generation.
- Positions 2 to 10 represent `Nx FPS` (e.g. `2x FPS`, `3x FPS`, `4x FPS`).

### 3. DLL Status Label and Styling
- Displays `"● DLL file located"` in green when `Lossless.dll` is present.
- Displays `"● Install Lossless scaling on steam or point the correct file path"` in red when `Lossless.dll` is missing.

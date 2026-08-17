## ADDED Requirements

### Requirement: GPU Driver Auto Detected Label Centering and Font Styling
The "Auto Detected" indicator label in the GPU Driver section SHALL be horizontally centered relative to the driver logo image (`mesaImage` or `nvidiaImage`) and formatted with a reduced font size (`Font.Size := 8`).

#### Scenario: Auto Detected label displayed under MESA logo
- **WHEN** MESA driver is auto-detected and `autodetectmesaLabel` is visible
- **THEN** the center X coordinate of `autodetectmesaLabel` aligns with the center X coordinate of `mesaImage`.

#### Scenario: Auto Detected label displayed under Nvidia logo
- **WHEN** Nvidia driver is auto-detected and `autodetectnvLabel` is visible
- **THEN** the center X coordinate of `autodetectnvLabel` aligns with the center X coordinate of `nvidiaImage`.

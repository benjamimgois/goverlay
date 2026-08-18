# lossless-scaling-tab Specification (Delta)

## MODIFIED CAPABILITY
`lossless-scaling-tab`

## Requirements

### Requirement: Lossless Scaling Tab UI & Cards Layout
The Lossless Scaling tab (`losslessScalingTabSheet`) SHALL render inside a responsive scroll box with dark theme card styling (`StyleMainCard` / `StyleSubCard`).
The background panel (`FLsBgPanel`) SHALL always expand to cover at least the entire visible viewport height (`ClientHeight`) of the scroll box (`FLsScrollBox`), ensuring no unstyled or disabled viewport areas are visible when the tool is disabled or the window is resized.

#### Scenario: Viewing Lossless Scaling tab when Upscalers tool is disabled
- **WHEN** the Upscalers sidebar toggle is OFF
- **AND** the user views the Lossless Scaling tab
- **THEN** all controls remain disabled, but the entire tab background renders seamlessly with the active theme background color without gray background gaps.

#### Scenario: Resizing the main application window
- **WHEN** the main GOverlay window is resized
- **THEN** `ReflowLosslessScalingTab` recalculates panel dimensions and ensures `FLsBgPanel` spans the full viewport width and height.

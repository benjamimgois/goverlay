# Proposal: Contextual Flow & Grid (Adaptive Row - Option 2)

## Why

In MangoHud, the HUD orientation dictates which layout parameters are functional:
- In **Vertical** orientation (table mode), `table_columns` actively controls how metrics break into 1-6 columns, while `horizontal_stretch` is completely inoperable.
- In **Horizontal** orientation (continuous bar mode), `horizontal_stretch` actively controls whether the bar expands across the full screen width or hugs its content, while `table_columns` is completely inoperable.

Presenting both controls unconditionally causes user confusion, as adjusting columns in Horizontal mode produces zero visual change in the game, and toggling Horizontal Stretch in Vertical mode has no effect. Implementing **Option 2 (Adaptive Row)** provides a clean, clutter-free sub-card where the secondary row dynamically morphs to show only the applicable control based on the active orientation.

## What Changes

- Implement dynamic contextual visibility in `mangohud_ui.pas` within the `Flow & Grid` sub-card (`FVisFlowSec`):
  - When **Vertical** is selected: display the **Columns** controls (stepper `[-]`, count label, `[+]`, and mini-bars HUD indicator); hide the **Horizontal Stretch** controls.
  - When **Horizontal** is selected: display the **Horizontal Stretch** control (with clear labeling/toggle); hide the **Columns** controls.
- Update `ReflowVisualTab` to dynamically reposition and adjust the visible controls based on active orientation without leaving blank space or overlapping controls.
- Maintain seamless bidirectional state synchronization with legacy controls (`verticalRadioButton`, `horizontalRadioButton`, `horizontalstrechCheckBox`, `COLUMNS`) so that existing config reading, writing, and test suites continue to pass with zero regressions.

## Capabilities

### Modified Capabilities
- `mangohud-visual-modular-ui`: Update the Position & Layout card specification to mandate adaptive contextual rows for the Flow & Grid sub-card.

## Impact
- Files modified: `mangohud_ui.pas`.
- No breaking changes to MangoHud config file format or test suite contracts.

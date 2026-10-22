# vkbasalt-tab-layout-reflow Specification

## Purpose
Ensures the vkBasalt tab layout properly reflows and sizes its constituent cards (Reshade Effects, Built-in Effects, Toggle Key, Effect Pipeline) to fit entirely within the visible tab sheet area without clipping action buttons or controls.

## Requirements

### Requirement: vkBasalt Tab Activation Reflow
The system SHALL perform a layout reflow of `vkbasaltTabSheet` and the vkBasalt method view in the Post-processing tab whenever it becomes visible.

#### Scenario: Navigating to vkBasalt tab from sidebar
- **WHEN** user clicks on the "Post processing" sidebar navigation item or switches to `vkbasaltTabSheet` with `vkBasalt` method active
- **THEN** `ReflowReShadeTab` and `ReflowVkBasaltTab` are executed using the container's current dimensions.
- **AND** the Software Status card (`FStatusCard`) is hidden (`Visible := False`).
- **AND** the Effect Pipeline card (`FVkPipelineCard`) is anchored to the bottom of the tab view.
- **AND** the Built-in Effects card (`FVkBuiltinCard`) uses a compact vertical layout (height of 148px) to accommodate CAS, FXAA, SMAA, DLS, and Color LUT controls without unused bottom space, maximizing vertical space for `FVkReshadeCard`.

#### Scenario: Switching method to ReShade or None
- **WHEN** user selects `ReShade` or `None` in the Post-processing method card
- **THEN** `FStatusCard` becomes visible again at the bottom of the tab.
- **AND** `FVkPipelineCard` and `FVkBuiltinCard` are hidden.

#### Scenario: Window resize while vkBasalt tab is active
- **WHEN** the main window is resized while `vkBasalt` mode is active
- **THEN** `FVkReshadeCard` height adapts dynamically to fill remaining space while maintaining `FVkBuiltinCard` (148px) and `FVkPipelineCard` fully visible.

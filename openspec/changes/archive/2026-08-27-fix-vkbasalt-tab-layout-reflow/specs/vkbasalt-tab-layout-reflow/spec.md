## Purpose

Ensures the vkBasalt tab layout properly reflows and sizes its constituent cards (Reshade Effects, Built-in Effects, Toggle Key) to fit entirely within the visible tab sheet area without clipping action buttons at the bottom.

## ADDED Requirements

### Requirement: vkBasalt Tab Activation Reflow
The system SHALL perform a layout reflow of `vkbasaltTabSheet` whenever the tab becomes visible.

#### Scenario: Navigating to vkBasalt tab from sidebar
- **WHEN** user clicks on the "Post processing" sidebar navigation item or switches to `vkbasaltTabSheet`
- **THEN** `ReflowVkBasaltTab` is executed using the tab sheet's current width and height.
- **AND** the Toggle Key card (`FVkToggleCard`) and its action buttons (`FVkToggleCaptureBtn`, `FVkRestoreBtn`, `FVkReshadeSyncBtn`) are positioned strictly within `vkbasaltTabSheet.ClientHeight`.

#### Scenario: Window resize while vkBasalt tab is active
- **WHEN** the main window is resized while `vkbasaltTabSheet` is active
- **THEN** `FVkReshadeCard` height adapts proportionally while maintaining `FVkBuiltinCard` and `FVkToggleCard` fully visible at the bottom of the tab.

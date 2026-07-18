## Context

On the OptiScaler tab, when the bleeding-edge channel is selected, the FSR version dropdown is locked to "Latest". Storing the selection while hiding the dropdown and label helps streamline the UI. The "Force FSR4-i8" checkbox is displayed in place of the hidden combobox, using the same spatial slot. When the user switches back to the Stable channel, the dropdown and label are restored, and the "Force FSR4-i8" checkbox is hidden and returned to its default layout position.

## Goals / Non-Goals

**Goals:**
- Dynamically toggle visibility of `fsrversionLabel` and `fsrversionComboBox` based on the active update channel (`optversionComboBox`).
- Relocate and display `forceFsr4Int8CheckBox` in place of the version combobox when the bleeding-edge channel is active.
- Revert visibility and positions to their original stable channel defaults when switching back to the Stable channel.
- Automatically set FSR version to "Latest" (index 0) on the bleeding-edge channel.

**Non-Goals:**
- Modifying how settings are loaded or saved to configuration files.
- Modifying the styling or contents of the dropdowns or checkboxes themselves.

## Decisions

### Decision 1: Handle layout shifts in `fsrversionComboBoxChange`
We will centralize the coordinate shifts and visibility changes in the `fsrversionComboBoxChange` procedure in `overlayunit.pas`.
- *Rationale*: This procedure is already triggered on form load, configuration loaded events, and channel selection changes.
- *Alternatives considered*: Managing layout shifts in multiple event handlers (`optversionComboBoxChange`, `LoadOptiScalerConfig`). This would duplicate code and increase the risk of inconsistent UI states.

### Decision 2: Set coordinates dynamically using source controls
For positioning the `forceFsr4Int8CheckBox`, we will assign its `Left` directly from `fsrversionComboBox.Left` and its `Top` directly from `emufp8CheckBox.Top` instead of hardcoding absolute values.
- *Rationale*: This guarantees horizontal alignment between the two side-by-side checkboxes even if the Lazarus layout engine adjusts positions dynamically based on system DPI or theme fonts.

## Risks / Trade-offs

- **[Risk]** The checkbox and label visibility states could get out of sync on initial load.
  - *Mitigation*: Ensure `fsrversionComboBoxChange(nil)` is called at the end of the form's config loading cycle (which is already the case).

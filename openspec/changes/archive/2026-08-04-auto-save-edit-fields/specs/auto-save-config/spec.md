## MODIFIED Requirements

### Requirement: Automatic Configuration Persistence
GOverlay SHALL automatically save configuration changes to disk whenever the user modifies a UI control (checkbox, radio button, combobox, slider, text edit input, or color button) on any active tab.
GOverlay SHALL NOT require a manual "Save" button to persist configuration changes.

#### Scenario: Toggling a setting auto-saves
- **WHEN** user toggles a setting or selects a combobox option on any tab
- **THEN** GOverlay auto-saves the updated configuration to the active game or global profile immediately

#### Scenario: Dragging a slider or typing text uses debounced auto-save
- **WHEN** user drags a slider or types in any text edit box (`TCustomEdit`)
- **THEN** GOverlay debounces disk writes with a 300ms delay to prevent write thrashing

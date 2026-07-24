## ADDED Requirements

### Requirement: GUI test suite bidirectional round-trip verification
The GUI test suite SHALL execute configuration reload calls (`LoadMangoHudConfig`, `LoadOptiScalerConfig`, etc.) after saving configuration files in all tab test procedures and assert that UI controls match the reloaded file state.

#### Scenario: MangoHud tab round-trip testing
- **WHEN** GUI test cases modify MangoHud UI controls and execute `SaveMango`
- **THEN** test procedure calls `LoadMangoHudConfig` and asserts that all modified UI controls (comboboxes, color buttons, trackbars, spin edits, checkboxes) retain their expected values

#### Scenario: OptiScaler tab round-trip testing
- **WHEN** GUI test cases modify OptiScaler UI controls and save configuration
- **THEN** test procedure calls `LoadOptiScalerConfig` and asserts that all modified UI controls retain their expected values

### Requirement: Tab-switching persistence verification
The GUI test suite SHALL simulate switching between overlay tabs (e.g. MangoHud -> OptiScaler -> MangoHud) and verify that UI controls maintain their state without unexpected resets or leaks.

#### Scenario: Navigation tab switch persistence
- **WHEN** UI controls are modified, saved, and user navigates away to another sidebar tab and returns
- **THEN** all UI controls on the original tab retain their saved settings after the tab reload

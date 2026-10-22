## Purpose

Ensures that selecting a game card immediately updates and synchronizes the generated launch command for that specific game across the entire UI and dialogs.

## ADDED Requirements

### Requirement: Immediate launch command update on game card selection
The system SHALL recompute the active launch command immediately when a user clicks on a game card on the Games tab.

#### Scenario: User clicks game card and opens Finish dialog
- **WHEN** user clicks on a game card on the Games tab
- **THEN** system sets the active game context and immediately updates `FLaunchCommand` to reference the selected game's `bgmod` path
- **WHEN** user immediately clicks the `[✓ Finish]` button on the floating action dock without changing any settings
- **THEN** the finish configuration dialog displays the launch command pointing to the selected game rather than `global`

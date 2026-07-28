## ADDED Requirements

### Requirement: Thread-Safe AppImage Execution
The system SHALL ensure background thread creation in Unix AppImage environments uses `cmem` and handles thread creation exceptions gracefully.

#### Scenario: Background update thread spawn fails
- **WHEN** background update thread creation fails due to system OS or AppImage container limitations
- **THEN** the system logs a warning to stdout and safely skips the background update check without raising an unhandled GUI error dialog

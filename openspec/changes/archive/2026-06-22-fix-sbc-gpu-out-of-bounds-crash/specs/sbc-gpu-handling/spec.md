## ADDED Requirements

### Requirement: Graceful startup when no PCI GPU is detected
The system SHALL start up successfully and not crash with "List index (0) out of bounds" when no PCI GPU is detected.

#### Scenario: Startup with no PCI GPU
- **WHEN** the application starts up on a system with no PCI GPU
- **THEN** the system starts up normally without displaying any crash dialogs, and the GPU selection controls are left empty.

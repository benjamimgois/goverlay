# restrict-power-fix-to-intel

## Purpose
Restrict RAPL power monitoring controls and checks exclusively to Intel CPU architectures.

## Requirements

### Requirement: Restrict RAPL button visibility to Intel CPUs
The system SHALL hide `intelpowerfixBitBtn` on startup if the CPU is not a Genuine Intel CPU, even if `/sys/class/powercap/intel-rapl:0/energy_uj` exists.

#### Scenario: Hide button on AMD CPU
- **WHEN** GOverlay starts on an AMD CPU system where `/sys/class/powercap/intel-rapl:0/energy_uj` exists
- **THEN** `intelpowerfixBitBtn.Visible` is set to False

### Requirement: Restrict proactive check to Intel CPUs
The system SHALL NOT run the proactive check/dialog for RAPL file permissions when `cpupowerCheckBox` is clicked if the CPU is not a Genuine Intel CPU.

#### Scenario: Do not trigger fix on AMD CPU
- **WHEN** user clicks `cpupowerCheckBox` on an AMD CPU system
- **THEN** the system exits without checking RAPL file permissions or triggering the dialog

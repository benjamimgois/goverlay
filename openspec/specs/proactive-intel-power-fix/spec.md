# proactive-intel-power-fix

## Purpose
Proactively trigger the Intel CPU power fix dialog/flow when the CPU power checkbox is enabled if the power monitor file is not readable by the user.

## Requirements

### Requirement: Trigger power fix flow proactively when checkbox is checked
When the user clicks `cpupowerCheckBox` to check/enable it, the system SHALL check if the CPU power monitor file `/sys/class/powercap/intel-rapl:0/energy_uj` exists and is NOT readable by the current user. If so, the system SHALL trigger the Intel CPU power fix dialog/flow.

#### Scenario: Trigger fix flow
- **WHEN** user clicks `cpupowerCheckBox` (setting it to Checked = True), the file `/sys/class/powercap/intel-rapl:0/energy_uj` exists but is NOT readable
- **THEN** the system triggers `intelpowerfixBitBtnClick`

# persistent-intel-power-fix

## Purpose
A permanent, udev-based fix configuration system for Intel CPU power monitoring, enabling persistent read permissions on the Intel RAPL energy file across reboots, alongside startup check indicators and a temporary fallback choice.

## Requirements

### Requirement: Hide button if RAPL is unsupported
The system SHALL hide `intelpowerfixBitBtn` on startup if the path `/sys/class/powercap/intel-rapl:0/energy_uj` does not exist.

#### Scenario: Hide button on non-Intel CPU
- **WHEN** GOverlay starts on a system where `/sys/class/powercap/intel-rapl:0/energy_uj` does not exist
- **THEN** `intelpowerfixBitBtn.Visible` is set to False

### Requirement: Initialize button state on start
If the target RAPL energy file exists, the system SHALL check if the file is readable by the current user process. The system SHALL set `intelpowerfixBitBtn.ImageIndex` to `0` (active) if it is readable, and `1` (inactive) if it is not readable.

#### Scenario: Initialize active indicator
- **WHEN** GOverlay starts and `/sys/class/powercap/intel-rapl:0/energy_uj` is readable by the current user
- **THEN** `intelpowerfixBitBtn.ImageIndex` is set to 0

#### Scenario: Initialize inactive indicator
- **WHEN** GOverlay starts and `/sys/class/powercap/intel-rapl:0/energy_uj` is NOT readable by the current user
- **THEN** `intelpowerfixBitBtn.ImageIndex` is set to 1

### Requirement: Enable persistent or temporary power fix configuration
When the user clicks `intelpowerfixBitBtn` and the fix is inactive (ImageIndex is 1), the system SHALL prompt the user with choices to apply the fix:
- Permanent: Create a udev rule at `/etc/udev/rules.d/70-intel-rapl.rules` making permissions persist across reboots.
- Temporary: Apply `chmod` for the current session only.
- Cancel: No action.

#### Scenario: User configures permanent fix
- **WHEN** `intelpowerfixBitBtn` is clicked, user chooses Permanent, and authorizes pkexec
- **THEN** udev rule is written to `/etc/udev/rules.d/70-intel-rapl.rules` and `intelpowerfixBitBtn.ImageIndex` is set to 0

#### Scenario: User configures temporary fix
- **WHEN** `intelpowerfixBitBtn` is clicked, user chooses Temporary, and authorizes pkexec
- **THEN** chmod is executed for `/sys/class/powercap/intel-rapl:0/energy_uj` and `intelpowerfixBitBtn.ImageIndex` is set to 0

### Requirement: Remove persistent power fix configuration
When the user clicks `intelpowerfixBitBtn` and the persistent udev rule file exists, the system SHALL prompt the user to confirm removing the udev rule.

#### Scenario: User removes permanent fix
- **WHEN** `intelpowerfixBitBtn` is clicked, udev rule exists, user confirms removal, and authorizes pkexec
- **THEN** udev rule file `/etc/udev/rules.d/70-intel-rapl.rules` is deleted and `intelpowerfixBitBtn.ImageIndex` is set to 1
